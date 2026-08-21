// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// DualChannelVoter implements SIL4 2-out-of-2 (2o2) cross-comparison voting between Channel A and Channel B.
pub struct DualChannelVoter {
  channel_a_state : AtpStateMachine
  channel_b_state : AtpStateMachine
  max_allowed_speed_diff_mps : Double
  max_allowed_pos_diff_m : Double
} derive(Eq, Debug)

///|
pub fn DualChannelVoter::new(
  config : @types.SystemConfig,
  max_v_diff : Double,
  max_p_diff : Double,
) -> DualChannelVoter {
  {
    channel_a_state: AtpStateMachine::new(config),
    channel_b_state: AtpStateMachine::new(config),
    max_allowed_speed_diff_mps: max_v_diff,
    max_allowed_pos_diff_m: max_p_diff,
  }
}

///|
/// Perform cross-channel 2o2 voting and return unified fail-safe state output.
pub fn DualChannelVoter::vote(
  self : DualChannelVoter,
  event_a : @types.ATPEvent,
  event_b : @types.ATPEvent,
  state_a : @types.TrainState,
  state_b : @types.TrainState,
  thresh_a : @types.ProtectionThresholds,
  thresh_b : @types.ProtectionThresholds,
) -> @types.ATPState {
  let v_diff = (state_a.speed - state_b.speed).abs()
  let p_diff = (state_a.odometer.nominal_pos - state_b.odometer.nominal_pos).abs()

  // Disagree beyond SIL4 bounds triggers HardwareFault
  if v_diff > self.max_allowed_speed_diff_mps ||
    p_diff > self.max_allowed_pos_diff_m {
    let fail_evt = @types.ATPEvent::from_code(401) // HardwareFailSignal
    let _ = self.channel_a_state.transition(fail_evt, state_a, thresh_a)
    let _ = self.channel_b_state.transition(fail_evt, state_b, thresh_b)
    return @types.ATPState::from_int(7) // HardwareFault
  }

  let out_a = self.channel_a_state.transition(event_a, state_a, thresh_a)
  let out_b = self.channel_b_state.transition(event_b, state_b, thresh_b)

  // Fail-safe principle: Pick higher severity level between Channel A and Channel B
  if out_a.severity_level() >= out_b.severity_level() {
    out_a
  } else {
    out_b
  }
}
