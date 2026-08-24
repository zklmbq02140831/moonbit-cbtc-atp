// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AtpCycleEngine orchestrates one deterministic ATP decision.
pub struct AtpCycleEngine {
  priv supervisor : @protection.SupervisionEngine
  priv ceiling : @protection.CeilingSpeedMonitor
  priv voter : @state_machine.DualChannelVoter
  priv max_speed_diff_mps : Double
  priv max_position_diff_m : Double
  priv mut initialized : Bool
  priv mut last_timestamp_ms : Int64
  priv mut fault_latched : Bool
  priv mut fault_reason : AtpReasonCode?
  priv mut fault_issues : Array[ValidationIssue]
  priv mut fault_position_m : Double
} derive(Eq, Debug)

///|
pub fn AtpCycleEngine::new(
  config : @types.SystemConfig,
  params : @types.TrainParams,
  max_speed_diff_mps : Double,
  max_position_diff_m : Double,
) -> AtpCycleEngine {
  let startup_issues : Array[ValidationIssue] = Array::new()
  if !config.is_valid() || !params.is_valid() {
    startup_issues.push(
      ValidationIssue::new(ValidationIssueCode::InvalidConfiguration),
    )
  }
  {
    supervisor: @protection.SupervisionEngine::new(config, params),
    ceiling: @protection.CeilingSpeedMonitor::new(config),
    voter: @state_machine.DualChannelVoter::new(
      config, max_speed_diff_mps, max_position_diff_m,
    ),
    max_speed_diff_mps,
    max_position_diff_m,
    initialized: false,
    last_timestamp_ms: -1,
    fault_latched: startup_issues.length() > 0,
    fault_reason: if startup_issues.length() > 0 {
      Some(InvalidInput)
    } else {
      None
    },
    fault_issues: startup_issues,
    fault_position_m: 0.0,
  }
}

///|
/// Evaluate a complete cycle using only the supplied snapshot and profiles.
pub fn AtpCycleEngine::evaluate(
  self : AtpCycleEngine,
  input : AtpCycleInput,
  ssp : @line_profile.StaticSpeedProfile,
  tsr : @line_profile.TsrManager,
  ma : @line_profile.MaResolver,
  rail : @types.RailCondition,
) -> AtpCycleDecision {
  if self.fault_latched {
    let reason = match self.fault_reason {
      Some(value) => value
      None => HardwareFault
    }
    return self.fail_safe_latched(input, reason)
  }
  let issues = input.validate(self.max_speed_diff_mps, self.max_position_diff_m)
  if issues.length() > 0 {
    return self.latch_fail_safe(input, InvalidInput, issues)
  }

  if self.last_timestamp_ms >= 0 && input.now_ms < self.last_timestamp_ms {
    issues.push(ValidationIssue::new(ValidationIssueCode::TimestampRollback))
    return self.latch_fail_safe(input, InvalidInput, issues)
  }
  self.last_timestamp_ms = input.now_ms

  if !ssp.is_valid() {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::InvalidStaticSpeedProfile),
    )
    return self.latch_fail_safe(input, InvalidInput, issues)
  }
  if !ssp.has_physical_limit_at(input.channel_state_a.odometer.max_pos) ||
    !ssp.has_physical_limit_at(input.channel_state_b.odometer.max_pos) {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::MissingStaticSpeedCoverage),
    )
    return self.latch_fail_safe(input, InvalidInput, issues)
  }

  if ma.get_active_eoa(input.now_ms) is None {
    return self.latch_fail_safe(input, MovementAuthorityUnavailable, issues)
  }

  let thresholds_a = self.supervisor.calculate_thresholds(
    input.channel_state_a.odometer.max_pos,
    ssp,
    tsr,
    ma,
    input.now_ms,
    rail,
  )
  let thresholds_b = self.supervisor.calculate_thresholds(
    input.channel_state_b.odometer.max_pos,
    ssp,
    tsr,
    ma,
    input.now_ms,
    rail,
  )
  let mut event_a = self.ceiling.evaluate(
    input.channel_state_a.speed,
    thresholds_a,
  )
  let mut event_b = self.ceiling.evaluate(
    input.channel_state_b.speed,
    thresholds_b,
  )
  if thresholds_a.margin_to_eoa <= 0.0 {
    event_a = @types.ATPEvent::from_code(205)
  }
  if thresholds_b.margin_to_eoa <= 0.0 {
    event_b = @types.ATPEvent::from_code(205)
  }

  if !self.initialized {
    let _ = self.voter.vote(
      @types.ATPEvent::from_code(101),
      @types.ATPEvent::from_code(101),
      input.channel_state_a,
      input.channel_state_b,
      thresholds_a,
      thresholds_b,
    )
    let _ = self.voter.vote(
      @types.ATPEvent::from_code(102),
      @types.ATPEvent::from_code(102),
      input.channel_state_a,
      input.channel_state_b,
      thresholds_a,
      thresholds_b,
    )
    self.initialized = true
  }

  let state = self.voter.vote(
    event_a,
    event_b,
    input.channel_state_a,
    input.channel_state_b,
    thresholds_a,
    thresholds_b,
  )
  let thresholds = conservative_thresholds(
    input.position_m,
    thresholds_a,
    thresholds_b,
  )
  let reason = reason_from_events(event_a, event_b, state)
  let action = action_from_state(event_a, event_b, state)
  { action, trace: trace_from_thresholds(thresholds, state, reason), issues }
}

///|
fn AtpCycleEngine::latch_fail_safe(
  self : AtpCycleEngine,
  input : AtpCycleInput,
  reason : AtpReasonCode,
  issues : Array[ValidationIssue],
) -> AtpCycleDecision {
  self.fault_latched = true
  self.fault_reason = Some(reason)
  self.fault_issues = issues.copy()
  self.fault_position_m = safe_fault_position(input.position_m)
  fail_safe_decision(self.fault_position_m, reason, self.fault_issues.copy())
}

///|
fn AtpCycleEngine::fail_safe_latched(
  self : AtpCycleEngine,
  input : AtpCycleInput,
  reason : AtpReasonCode,
) -> AtpCycleDecision {
  let _ = input
  fail_safe_decision(self.fault_position_m, reason, self.fault_issues.copy())
}

///|
fn safe_fault_position(position_m : Double) -> Double {
  if position_m.is_nan() || position_m.is_inf() || position_m < 0.0 {
    0.0
  } else {
    position_m
  }
}

///|
fn fail_safe_decision(
  position_m : Double,
  reason : AtpReasonCode,
  issues : Array[ValidationIssue],
) -> AtpCycleDecision {
  { action: FailSafeTrip, trace: fail_safe_trace(position_m, reason), issues }
}

///|
fn reason_from_events(
  event_a : @types.ATPEvent,
  event_b : @types.ATPEvent,
  state : @types.ATPState,
) -> AtpReasonCode {
  match state.severity_level() {
    7 => HardwareFault
    6 => TripBoundaryExceeded
    5 => EmergencyBrakeRequired
    4 => ServiceBrakeRequired
    3 => OverspeedWarning
    _ => reason_from_event_codes(event_a.code(), event_b.code())
  }
}

///|
fn reason_from_event_codes(code_a : Int, code_b : Int) -> AtpReasonCode {
  let code = if code_a >= code_b { code_a } else { code_b }
  match code {
    201 => NormalCycle
    202 => OverspeedWarning
    203 => ServiceBrakeRequired
    204 => EmergencyBrakeRequired
    205 => TripBoundaryExceeded
    _ => HardwareFault
  }
}

///|
fn action_from_state(
  event_a : @types.ATPEvent,
  event_b : @types.ATPEvent,
  state : @types.ATPState,
) -> AtpAction {
  match state.severity_level() {
    7 => FailSafeTrip
    6 => FailSafeTrip
    5 => EmergencyBrake
    4 => ServiceBrake
    3 => Warning
    _ => action_from_event_codes(event_a.code(), event_b.code())
  }
}

///|
fn action_from_event_codes(code_a : Int, code_b : Int) -> AtpAction {
  let code = if code_a >= code_b { code_a } else { code_b }
  match code {
    201 => Continue
    202 => Warning
    203 => ServiceBrake
    204 => EmergencyBrake
    205 => FailSafeTrip
    _ => FailSafeTrip
  }
}

///|
fn conservative_thresholds(
  position : Double,
  a : @types.ProtectionThresholds,
  b : @types.ProtectionThresholds,
) -> @types.ProtectionThresholds {
  @types.ProtectionThresholds::new(
    position,
    a.permitted_speed.min(b.permitted_speed),
    a.warning_speed.min(b.warning_speed),
    a.service_brake_speed.min(b.service_brake_speed),
    a.emergency_brake_speed.min(b.emergency_brake_speed),
    a.trip_speed.min(b.trip_speed),
    a.margin_to_eoa.min(b.margin_to_eoa),
  )
}
