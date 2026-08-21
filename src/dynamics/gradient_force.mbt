// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// GradientCalculator computes equivalent acceleration/deceleration due to track inclination.
/// Formula: g_grad = g * sin(\theta) \approx 9.81 * (gradient_per_thousand / 1000.0)
pub struct GradientCalculator {
  g : Double
} derive(Eq, Debug)

///|
pub fn GradientCalculator::new() -> GradientCalculator {
  { g: 9.81 }
}

///|
pub fn GradientCalculator::equivalent_acceleration(
  self : GradientCalculator,
  gradient_per_thousand : Double
) -> Double {
  self.g * (gradient_per_thousand / 1000.0)
}

///|
pub fn GradientCalculator::equivalent_gradient_force_kn(
  self : GradientCalculator,
  gradient_per_thousand : Double,
  mass_tonnes : Double
) -> Double {
  let accel = self.equivalent_acceleration(gradient_per_thousand)
  let force_n = mass_tonnes * 1000.0 * accel
  force_n / 1000.0
}
