// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
fn trace_from_thresholds(
  thresholds : @types.ProtectionThresholds,
  state : @types.ATPState,
  reason : AtpReasonCode,
) -> DecisionTrace {
  {
    position_m: thresholds.position,
    permitted_speed: thresholds.permitted_speed,
    warning_speed: thresholds.warning_speed,
    service_brake_speed: thresholds.service_brake_speed,
    emergency_brake_speed: thresholds.emergency_brake_speed,
    trip_speed: thresholds.trip_speed,
    margin_to_eoa: thresholds.margin_to_eoa,
    state,
    reason,
  }
}

///|
fn fail_safe_trace(
  position_m : Double,
  reason : AtpReasonCode,
) -> DecisionTrace {
  {
    position_m,
    permitted_speed: 0.0,
    warning_speed: 0.0,
    service_brake_speed: 0.0,
    emergency_brake_speed: 0.0,
    trip_speed: 0.0,
    margin_to_eoa: 0.0,
    state: @types.ATPState::from_int(7),
    reason,
  }
}
