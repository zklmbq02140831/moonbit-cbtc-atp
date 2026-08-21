// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EbiSbiCurveCalculator generates spatial EBI and SBI braking curve profiles.
pub struct EbiSbiCurveCalculator {
  service_decel_mps2 : Double
  emergency_decel_mps2 : Double
} derive(Eq, Debug)

///|
pub fn EbiSbiCurveCalculator::new(
  sbi_a : Double,
  ebi_a : Double,
) -> EbiSbiCurveCalculator {
  { service_decel_mps2: sbi_a, emergency_decel_mps2: ebi_a }
}

///|
pub fn EbiSbiCurveCalculator::ebi_speed_at_distance(
  self : EbiSbiCurveCalculator,
  dist_to_eoa_m : Double,
) -> Double {
  if dist_to_eoa_m <= 0.0 {
    0.0
  } else {
    (2.0 * self.emergency_decel_mps2 * dist_to_eoa_m).sqrt()
  }
}

///|
pub fn EbiSbiCurveCalculator::sbi_speed_at_distance(
  self : EbiSbiCurveCalculator,
  dist_to_eoa_m : Double,
) -> Double {
  if dist_to_eoa_m <= 0.0 {
    0.0
  } else {
    (2.0 * self.service_decel_mps2 * dist_to_eoa_m).sqrt()
  }
}
