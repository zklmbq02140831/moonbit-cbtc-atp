// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// CouplerForceModel calculates inter-car draft (tension) and buff (compression) forces in long trains.
pub struct CouplerForceModel {
  coupler_stiffness_k : Double // N / m
  coupler_damping_c : Double // Ns / m
} derive(Eq, Debug)

///|
pub fn CouplerForceModel::new() -> CouplerForceModel {
  { coupler_stiffness_k: 5.0e6, coupler_damping_c: 1.5e5 }
}

///|
pub fn CouplerForceModel::calculate_coupler_force_kn(
  self : CouplerForceModel,
  delta_x_m : Double,
  delta_v_mps : Double,
) -> Double {
  let f_spring = self.coupler_stiffness_k * delta_x_m
  let f_damper = self.coupler_damping_c * delta_v_mps
  let total_n = f_spring + f_damper
  total_n / 1000.0 // in kN
}
