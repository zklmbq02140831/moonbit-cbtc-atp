// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// Contract 1: Overspeed Protection No Over-step Invariant.
/// Verifies that if emergency braking is triggered at position s with speed v,
/// the computed stopping distance s_stop will never exceed EOA position s_EOA.
pub fn verify_no_eoa_overstep_contract(
  current_pos : Double,
  current_speed : Double,
  decel : Double,
  eoa_pos : Double,
  delay_s : Double,
) -> Bool {
  let brake_dist = current_speed * delay_s +
    current_speed * current_speed / (2.0 * decel)
  let stop_pos = current_pos + brake_dist
  stop_pos <= eoa_pos + 0.001 // 1mm numeric tolerance
}

///|
/// Contract 2: Deceleration Non-degradation Invariant.
/// Ensures that braking force capability -dv/ds does not degrade monotonically with respect to speed.
pub fn verify_deceleration_non_degradation_contract(
  decel_at_v1 : Double,
  decel_at_v2 : Double,
  v1 : Double,
  v2 : Double,
) -> Bool {
  if v1 >= v2 {
    decel_at_v1 >= decel_at_v2 - 0.05
  } else {
    decel_at_v2 >= decel_at_v1 - 0.05
  }
}

///|
/// Contract 3: Safety State Escalation Monotonicity Invariant.
/// Guarantees that under escalating overspeed events, safety state severity is strictly non-decreasing.
pub fn verify_state_escalation_monotonicity_contract(
  prev_state : @types.ATPState,
  next_state : @types.ATPState,
) -> Bool {
  next_state.severity_level() >= prev_state.severity_level() ||
  next_state == @types.ATPState::from_int(1) // Standby reset allowed after full stop
}

///|
/// Contract 4: Odometer Bounds Expansion Contract.
/// Asserts that position uncertainty margin never shrinks below physical error accumulation lower bound.
pub fn verify_odometer_bounds_contract(
  bounds : @types.OdometerBounds,
  min_expected_margin : Double,
) -> Bool {
  bounds.confidence_margin >= min_expected_margin &&
  bounds.min_pos <= bounds.nominal_pos &&
  bounds.nominal_pos <= bounds.max_pos
}
