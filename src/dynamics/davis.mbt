// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// DavisCalculator evaluates train mechanical and aerodynamic running resistance.
/// Davis Equation: R(v) = A + B*v + C*v^2 (N/tonne or N)
pub struct DavisCalculator {
  params : @types.TrainParams
} derive(Eq, Debug)

///|
pub fn DavisCalculator::new(params : @types.TrainParams) -> DavisCalculator {
  { params, }
}

///|
pub fn DavisCalculator::specific_resistance_n_per_tonne(
  self : DavisCalculator,
  speed_mps : Double,
) -> Double {
  let v_kmh = speed_mps * 3.6
  self.params.davis_a +
  self.params.davis_b * v_kmh +
  self.params.davis_c * v_kmh * v_kmh
}

///|
pub fn DavisCalculator::total_resistance_kn(
  self : DavisCalculator,
  speed_mps : Double,
) -> Double {
  let r_spec = self.specific_resistance_n_per_tonne(speed_mps)
  let force_n = r_spec * self.params.total_mass_tonnes
  force_n / 1000.0
}

///|
pub fn DavisCalculator::resistance_deceleration(
  self : DavisCalculator,
  speed_mps : Double,
) -> Double {
  let force_kn = self.total_resistance_kn(speed_mps)
  let force_n = force_kn * 1000.0
  let mass_kg = self.params.effective_mass_kg()
  force_n / mass_kg
}
