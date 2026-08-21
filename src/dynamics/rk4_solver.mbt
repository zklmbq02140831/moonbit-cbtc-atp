// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// Rk4DifferentialBrakeSolver implements 4th-order Runge-Kutta integration for velocity profiles.
pub struct Rk4DifferentialBrakeSolver {
  step_size_ds : Double
} derive(Eq, Debug)

///|
pub fn Rk4DifferentialBrakeSolver::new(
  ds : Double,
) -> Rk4DifferentialBrakeSolver {
  { step_size_ds: ds }
}

///|
/// Solve dv/ds = -a(v, s) / v using RK4 step
pub fn Rk4DifferentialBrakeSolver::step_backward(
  self : Rk4DifferentialBrakeSolver,
  current_v : Double,
  decel_func : (Double) -> Double,
) -> Double {
  let h = self.step_size_ds
  if current_v <= 0.01 {
    return (current_v * current_v + 2.0 * decel_func(current_v) * h).sqrt()
  }

  let k1 = decel_func(current_v) / current_v
  let v_mid1 = current_v + 0.5 * h * k1
  let k2 = decel_func(v_mid1) / (if v_mid1 < 0.1 { 0.1 } else { v_mid1 })
  let v_mid2 = current_v + 0.5 * h * k2
  let k3 = decel_func(v_mid2) / (if v_mid2 < 0.1 { 0.1 } else { v_mid2 })
  let v_end = current_v + h * k3
  let k4 = decel_func(v_end) / (if v_end < 0.1 { 0.1 } else { v_end })

  let slope = (k1 + 2.0 * k2 + 2.0 * k3 + k4) / 6.0
  current_v + h * slope
}
