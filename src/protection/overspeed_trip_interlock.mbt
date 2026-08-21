// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// OverspeedTripHardwareInterlock provides fail-safe hardware trip cut-off signal.
pub struct OverspeedTripHardwareInterlock {
  config : @types.SystemConfig
} derive(Eq, Debug)

///|
pub fn OverspeedTripHardwareInterlock::new(
  config : @types.SystemConfig,
) -> OverspeedTripHardwareInterlock {
  { config, }
}

///|
pub fn OverspeedTripHardwareInterlock::should_trip_hardware_relay(
  self : OverspeedTripHardwareInterlock,
  current_v_mps : Double,
  permitted_v_mps : Double,
) -> Bool {
  let trip_threshold_mps = permitted_v_mps + self.config.trip_margin
  current_v_mps >= trip_threshold_mps
}
