// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TractionEffortNotchMapper calculates tractive force (in kN) for 8 driver throttle notches.
pub struct TractionEffortNotchMapper {
  max_traction_kn : Double
} derive(Eq, Debug)

///|
pub fn TractionEffortNotchMapper::new(
  max_kn : Double,
) -> TractionEffortNotchMapper {
  { max_traction_kn: max_kn }
}

///|
pub fn TractionEffortNotchMapper::notch_force_kn(
  self : TractionEffortNotchMapper,
  notch : Int, // Notch 0 to 8
) -> Double {
  if notch <= 0 {
    0.0
  } else if notch >= 8 {
    self.max_traction_kn
  } else {
    let ratio = notch.to_double() / 8.0
    self.max_traction_kn * ratio
  }
}
