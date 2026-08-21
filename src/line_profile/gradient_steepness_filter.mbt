// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// VerticalCurveSegment models vertical parabolic transition curve between two track gradients.
pub struct VerticalCurveSegment {
  start_pos_m : Double
  end_pos_m : Double
  initial_gradient_per_thousand : Double
  final_gradient_per_thousand : Double
  vertical_radius_m : Double
} derive(Eq, Debug)

///|
pub fn VerticalCurveSegment::new(
  start_m : Double,
  end_m : Double,
  g1 : Double,
  g2 : Double,
  r_vert : Double,
) -> VerticalCurveSegment {
  {
    start_pos_m: start_m,
    end_pos_m: end_m,
    initial_gradient_per_thousand: g1,
    final_gradient_per_thousand: g2,
    vertical_radius_m: r_vert,
  }
}

///|
pub fn VerticalCurveSegment::interpolated_gradient(
  self : VerticalCurveSegment,
  pos_m : Double,
) -> Double {
  if pos_m <= self.start_pos_m {
    self.initial_gradient_per_thousand
  } else if pos_m >= self.end_pos_m {
    self.final_gradient_per_thousand
  } else {
    let ratio = (pos_m - self.start_pos_m) / (self.end_pos_m - self.start_pos_m)
    self.initial_gradient_per_thousand +
    ratio *
    (self.final_gradient_per_thousand - self.initial_gradient_per_thousand)
  }
}
