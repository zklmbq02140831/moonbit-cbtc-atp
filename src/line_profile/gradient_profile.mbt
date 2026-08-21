// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// GradientProfileEvaluator computes physical and equivalent gradient profile over train length L.
pub struct GradientProfileEvaluator {
  gradients : Array[@types.GradientSegment]
} derive(Eq, Debug)

///|
pub fn GradientProfileEvaluator::new(
  grads : Array[@types.GradientSegment],
) -> GradientProfileEvaluator {
  { gradients: grads }
}

///|
/// Instantaneous gradient value at point s.
pub fn GradientProfileEvaluator::get_gradient_at(
  self : GradientProfileEvaluator,
  pos : Double,
) -> Double {
  for i = 0; i < self.gradients.length(); i = i + 1 {
    let g = self.gradients[i]
    if pos >= g.start_pos && pos <= g.end_pos {
      return g.value
    }
  }
  0.0
}

///|
/// Equivalent gradient i_equiv over train length from train tail (front_pos - train_length) to front_pos:
/// i_equiv = (1 / L) * \int_{s - L}^{s} i(x) dx
pub fn GradientProfileEvaluator::equivalent_gradient_over_length(
  self : GradientProfileEvaluator,
  front_pos : Double,
  train_length : Double,
  step_ds : Double,
) -> Double {
  if train_length <= 1.0 {
    return self.get_gradient_at(front_pos)
  }
  let tail_pos = front_pos - train_length
  let mut sum = 0.0
  let mut curr = tail_pos
  let num_steps = ((front_pos - tail_pos) / step_ds).to_int()
  if num_steps <= 0 {
    return self.get_gradient_at(front_pos)
  }

  for i = 0; i < num_steps; i = i + 1 {
    let g = self.get_gradient_at(curr)
    sum = sum + g * step_ds
    curr = curr + step_ds
  }

  sum / train_length
}
