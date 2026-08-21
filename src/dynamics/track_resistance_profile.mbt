// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// IntegratedTrackResistanceEvaluator computes total specific resistance w_total = w_0 + w_i + w_r (in N/kN).
pub struct IntegratedTrackResistanceEvaluator {
  davis_calc : DavisCalculator
  gradient_force_calc : GradientCalculator
} derive(Eq, Debug)

///|
pub fn IntegratedTrackResistanceEvaluator::new(
  davis : DavisCalculator,
  grad : GradientCalculator,
) -> IntegratedTrackResistanceEvaluator {
  { davis_calc: davis, gradient_force_calc: grad }
}

///|
pub fn IntegratedTrackResistanceEvaluator::total_resistance_force_kn(
  self : IntegratedTrackResistanceEvaluator,
  equivalent_gradient_per_thousand : Double,
  speed_mps : Double,
) -> Double {
  let davis_kn = self.davis_calc.total_resistance_kn(speed_mps)
  let grad_accel = self.gradient_force_calc.equivalent_acceleration(
    equivalent_gradient_per_thousand,
  )
  let mass_kg = self.davis_calc.params.effective_mass_kg()
  let grad_force_kn = mass_kg * grad_accel / 1000.0
  davis_kn + grad_force_kn
}
