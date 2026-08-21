// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TargetDistanceCalculator computes dynamic braking target distance profile and release speed.
pub struct TargetDistanceCalculator {
  min_release_speed_mps : Double // e.g. 4.17 m/s = 15 km/h
} derive(Eq, Debug)

///|
pub fn TargetDistanceCalculator::new() -> TargetDistanceCalculator {
  { min_release_speed_mps: 4.17 }
}

///|
pub fn TargetDistanceCalculator::calculate_release_speed_mps(
  self : TargetDistanceCalculator,
  distance_to_eoa_m : Double,
) -> Double {
  if distance_to_eoa_m <= 20.0 {
    self.min_release_speed_mps
  } else if distance_to_eoa_m <= 100.0 {
    self.min_release_speed_mps + (distance_to_eoa_m - 20.0) * 0.05
  } else {
    self.min_release_speed_mps + 4.0
  }
}
