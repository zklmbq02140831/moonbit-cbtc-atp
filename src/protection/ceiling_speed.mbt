// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// CeilingSpeedMonitor evaluates overspeed violations against ProtectionThresholds.
pub struct CeilingSpeedMonitor {
  config : @types.SystemConfig
} derive(Eq, Debug)

///|
pub fn CeilingSpeedMonitor::new(
  config : @types.SystemConfig,
) -> CeilingSpeedMonitor {
  { config, }
}

///|
pub fn CeilingSpeedMonitor::evaluate(
  self : CeilingSpeedMonitor,
  current_speed : Double,
  thresholds : @types.ProtectionThresholds,
) -> @types.ATPEvent {
  // Access config to prevent unused field warning
  let _ = self.config
  if current_speed >= thresholds.trip_speed {
    @types.ATPEvent::from_code(205)
  } else if current_speed >= thresholds.emergency_brake_speed {
    @types.ATPEvent::from_code(204)
  } else if current_speed >= thresholds.service_brake_speed {
    @types.ATPEvent::from_code(203)
  } else if current_speed >= thresholds.warning_speed {
    @types.ATPEvent::from_code(202)
  } else {
    @types.ATPEvent::from_code(201)
  }
}
