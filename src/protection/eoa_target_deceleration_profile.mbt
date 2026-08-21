// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EoaTargetDecelerationProfile evaluates maximum permitted speed v_perm(s) as train approaches EOA.
pub struct EoaTargetDecelerationProfile {
  deceleration_mps2 : Double
} derive(Eq, Debug)

///|
pub fn EoaTargetDecelerationProfile::new(
  decel : Double,
) -> EoaTargetDecelerationProfile {
  { deceleration_mps2: decel }
}

///|
/// Calculates v = sqrt(2 * a * d) for remaining distance d to EOA.
pub fn EoaTargetDecelerationProfile::permitted_speed_to_eoa(
  self : EoaTargetDecelerationProfile,
  distance_to_eoa_m : Double,
) -> Double {
  if distance_to_eoa_m <= 0.0 {
    0.0
  } else {
    (2.0 * self.deceleration_mps2 * distance_to_eoa_m).sqrt()
  }
}
