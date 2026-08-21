// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AdhesionModel calculates effective wheel-rail adhesion coefficient as a function of speed.
/// Standard EN/UIC formula: \mu(v) = \mu_0 * (1 + a1 * v) / (1 + a2 * v) * rail_condition_multiplier
pub struct AdhesionModel {
  params : @types.TrainParams
} derive(Eq, Debug)

///|
pub fn AdhesionModel::new(params : @types.TrainParams) -> AdhesionModel {
  { params, }
}

///|
pub fn AdhesionModel::calculate_coefficient(
  self : AdhesionModel,
  speed_mps : Double,
  rail : @types.RailCondition,
) -> Double {
  let v_kmh = speed_mps * 3.6
  let mu_base = self.params.adhesion_mu0 *
    (1.0 + self.params.adhesion_a1 * v_kmh) /
    (1.0 + self.params.adhesion_a2 * v_kmh)
  let mult = rail.adhesion_multiplier()
  mu_base * mult
}

///|
pub fn AdhesionModel::max_adhesion_force_kn(
  self : AdhesionModel,
  speed_mps : Double,
  rail : @types.RailCondition,
) -> Double {
  let mu = self.calculate_coefficient(speed_mps, rail)
  let g = 9.81
  let mass_tonnes = self.params.total_mass_tonnes
  let force_n = mu * mass_tonnes * 1000.0 * g
  force_n / 1000.0 // in kN
}

///|
pub fn AdhesionModel::max_adhesion_deceleration(
  self : AdhesionModel,
  speed_mps : Double,
  rail : @types.RailCondition,
) -> Double {
  let mu = self.calculate_coefficient(speed_mps, rail)
  let g = 9.81
  mu * g / self.params.rotating_mass_factor
}
