// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AtpStateMachine implements EN50128 SIL4 safety-critical state transitions.
pub struct AtpStateMachine {
  mut current_state : @types.ATPState
  config : @types.SystemConfig
  alerts : Array[@types.SafetyAlertLog]
} derive(Eq, Debug)

///|
pub fn AtpStateMachine::new(config : @types.SystemConfig) -> AtpStateMachine {
  {
    current_state: @types.ATPState::from_int(0), // SystemInit
    config,
    alerts: Array::new(),
  }
}

///|
pub fn AtpStateMachine::state(self : AtpStateMachine) -> @types.ATPState {
  self.current_state
}

///|
pub fn AtpStateMachine::transition(
  self : AtpStateMachine,
  event : @types.ATPEvent,
  train_state : @types.TrainState,
  thresholds : @types.ProtectionThresholds,
) -> @types.ATPState {
  let now_ms = train_state.timestamp_ms
  let pos = train_state.odometer.nominal_pos
  let speed = train_state.speed

  let next_state = match (self.current_state, event.code()) {
    // From SystemInit (0)
    (s, 101) if s == @types.ATPState::from_int(0) =>
      @types.ATPState::from_int(1) // SelfTestPass -> Standby
    (s, 401) if s == @types.ATPState::from_int(0) =>
      @types.ATPState::from_int(7) // HardwareFailSignal -> HardwareFault

    // From Standby (1)
    (s, 102) if s == @types.ATPState::from_int(1) =>
      @types.ATPState::from_int(2) // CabActivated -> NormalOperating
    (s, 401) if s == @types.ATPState::from_int(1) =>
      @types.ATPState::from_int(7)

    // From NormalOperating (2)
    (s, 202) if s == @types.ATPState::from_int(2) =>
      @types.ATPState::from_int(3) // OverspeedWarn -> OverspeedWarning
    (s, 203) if s == @types.ATPState::from_int(2) =>
      @types.ATPState::from_int(4) // ServiceBrake -> ServiceBrakingTriggered
    (s, 204) if s == @types.ATPState::from_int(2) =>
      @types.ATPState::from_int(5) // EmergencyBrake -> EmergencyBrakingTriggered
    (s, 205) if s == @types.ATPState::from_int(2) =>
      @types.ATPState::from_int(6) // TripBoundary -> EmergencyTrip
    (s, 301) if s == @types.ATPState::from_int(2) =>
      @types.ATPState::from_int(6) // Rollback -> EmergencyTrip
    (s, 302) if s == @types.ATPState::from_int(2) =>
      @types.ATPState::from_int(5) // MaExpired -> EmergencyBrakingTriggered
    (s, 401) if s == @types.ATPState::from_int(2) =>
      @types.ATPState::from_int(7)

    // From OverspeedWarning (3)
    (s, 201) if s == @types.ATPState::from_int(3) =>
      @types.ATPState::from_int(2) // SpeedNormal -> NormalOperating
    (s, 203) if s == @types.ATPState::from_int(3) =>
      @types.ATPState::from_int(4) // ServiceBrake
    (s, 204) if s == @types.ATPState::from_int(3) =>
      @types.ATPState::from_int(5) // EmergencyBrake
    (s, 205) if s == @types.ATPState::from_int(3) =>
      @types.ATPState::from_int(6) // Trip

    // From ServiceBrakingTriggered (4)
    (s, 201) if s == @types.ATPState::from_int(4) &&
      speed <= thresholds.permitted_speed => @types.ATPState::from_int(2) // Speed dropped below perm -> Normal
    (s, 204) if s == @types.ATPState::from_int(4) =>
      @types.ATPState::from_int(5)
    (s, 205) if s == @types.ATPState::from_int(4) =>
      @types.ATPState::from_int(6)

    // From EmergencyBrakingTriggered (5) - Requires full stop to reset to standby/normal
    (s, 502) if s == @types.ATPState::from_int(5) && speed <= 0.05 =>
      @types.ATPState::from_int(1) // FullStopReached -> Standby
    (s, 205) if s == @types.ATPState::from_int(5) =>
      @types.ATPState::from_int(6)

    // From EmergencyTrip (6) - Irreversible without manual ack & full stop
    (s, 503) if s == @types.ATPState::from_int(6) && speed <= 0.01 =>
      @types.ATPState::from_int(1) // ResetCommandReceived -> Standby

    // HardwareFault (7)
    (s, 503) if s == @types.ATPState::from_int(7) =>
      @types.ATPState::from_int(0)
    _ => self.current_state
  }

  if next_state != self.current_state {
    let msg = "State transition: " +
      self.current_state.severity_level().to_string() +
      " -> " +
      next_state.severity_level().to_string()
    let log = @types.SafetyAlertLog::new(
      now_ms,
      event.code(),
      next_state.severity_level(),
      msg,
      pos,
      speed,
    )
    self.alerts.push(log)
    self.current_state = next_state
  }

  self.current_state
}

///|
pub fn AtpStateMachine::get_alerts(
  self : AtpStateMachine,
) -> Array[@types.SafetyAlertLog] {
  self.alerts
}
