// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// OdometerConfidenceInterval maintains min and max odometer bounds d_min <= d_nominal <= d_max.
pub struct OdometerConfidenceInterval {
  nominal_position_m : Double
  min_position_m : Double
  max_position_m : Double
  uncertainty_window_m : Double
} derive(Eq, Debug)

///|
pub fn OdometerConfidenceInterval::new(
  nominal_m : Double,
  uncertainty_m : Double,
) -> OdometerConfidenceInterval {
  {
    nominal_position_m: nominal_m,
    min_position_m: nominal_m - uncertainty_m,
    max_position_m: nominal_m + uncertainty_m,
    uncertainty_window_m: 2.0 * uncertainty_m,
  }
}
