// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// GradientProfileSmoother smooths multi-segment track gradients over moving windows.
pub struct GradientProfileSmoother {
  window_length_m : Double
} derive(Eq, Debug)

///|
pub fn GradientProfileSmoother::new(
  window_m : Double,
) -> GradientProfileSmoother {
  { window_length_m: window_m }
}

///|
pub fn GradientProfileSmoother::smooth_gradient(
  self : GradientProfileSmoother,
  evaluator : GradientProfileEvaluator,
  front_pos_m : Double,
) -> Double {
  evaluator.equivalent_gradient_over_length(
    front_pos_m,
    self.window_length_m,
    10.0,
  )
}
