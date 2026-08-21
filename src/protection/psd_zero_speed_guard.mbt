// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// PsdZeroSpeedGuard validates zero-speed threshold (v <= 0.05 m/s) before unlocking train doors.
pub struct PsdZeroSpeedGuard {
  max_door_unlock_speed_mps : Double // 0.05 m/s (~0.18 km/h)
} derive(Eq, Debug)

///|
pub fn PsdZeroSpeedGuard::new() -> PsdZeroSpeedGuard {
  { max_door_unlock_speed_mps: 0.05 }
}

///|
pub fn PsdZeroSpeedGuard::is_door_unlock_permitted(
  self : PsdZeroSpeedGuard,
  measured_speed_mps : Double,
  train_stopped : Bool,
) -> Bool {
  train_stopped && measured_speed_mps <= self.max_door_unlock_speed_mps
}
