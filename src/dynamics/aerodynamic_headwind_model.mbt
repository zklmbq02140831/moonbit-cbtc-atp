// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AerodynamicHeadwindModel computes relative wind drag F_wind = 0.5 * rho * (v + v_headwind)^2 * A * Cd.
pub struct AerodynamicHeadwindModel {
  air_density_kg_m3 : Double // 1.225
  frontal_area_m2 : Double // 12.0
  drag_coefficient_cd : Double // 0.25
} derive(Eq, Debug)

///|
pub fn AerodynamicHeadwindModel::new(
  area_m2 : Double,
  cd : Double,
) -> AerodynamicHeadwindModel {
  {
    air_density_kg_m3: 1.225,
    frontal_area_m2: area_m2,
    drag_coefficient_cd: cd,
  }
}

///|
pub fn AerodynamicHeadwindModel::headwind_force_kn(
  self : AerodynamicHeadwindModel,
  train_speed_mps : Double,
  headwind_speed_mps : Double,
) -> Double {
  let relative_v = train_speed_mps + headwind_speed_mps
  let force_n = 0.5 *
    self.air_density_kg_m3 *
    relative_v *
    relative_v *
    self.frontal_area_m2 *
    self.drag_coefficient_cd
  force_n / 1000.0 // in kN
}
