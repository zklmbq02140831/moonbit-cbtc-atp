// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// WheelRailContactMechanics models Kalker linear creep theory for longitudinal creep force F_x = -f11 * xi.
pub struct WheelRailContactMechanics {
  kalker_coefficient_f11 : Double
} derive(Eq, Debug)

///|
pub fn WheelRailContactMechanics::new() -> WheelRailContactMechanics {
  { kalker_coefficient_f11: 1.2e7 }
}

///|
pub fn WheelRailContactMechanics::longitudinal_creep_force_kn(
  self : WheelRailContactMechanics,
  creep_ratio_xi : Double,
) -> Double {
  let force_n = self.kalker_coefficient_f11 * creep_ratio_xi
  force_n / 1000.0 // in kN
}
