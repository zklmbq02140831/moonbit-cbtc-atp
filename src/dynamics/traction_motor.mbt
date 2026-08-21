// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TractionEnvelopeCalculator models traction force limits based on motor power and adhesion bounds.
pub struct TractionEnvelopeCalculator {
  params : @types.TrainParams
} derive(Eq, Debug)

///|
pub fn TractionEnvelopeCalculator::new(
  params : @types.TrainParams,
) -> TractionEnvelopeCalculator {
  { params, }
}

///|
pub fn TractionEnvelopeCalculator::max_traction_force_kn(
  self : TractionEnvelopeCalculator,
  speed_mps : Double,
) -> Double {
  if speed_mps <= 0.1 {
    return self.params.max_traction_force_kn
  }
  // Constant torque phase vs Constant power phase F = P / v
  let max_power_kw = self.params.max_traction_force_kn * 15.0 // Corner speed 15 m/s (54 km/h)
  let power_limited_force = max_power_kw / speed_mps
  if power_limited_force < self.params.max_traction_force_kn {
    power_limited_force
  } else {
    self.params.max_traction_force_kn
  }
}

///|
pub fn TractionEnvelopeCalculator::max_tractive_acceleration(
  self : TractionEnvelopeCalculator,
  speed_mps : Double,
) -> Double {
  let force_kn = self.max_traction_force_kn(speed_mps)
  let force_n = force_kn * 1000.0
  let mass_kg = self.params.effective_mass_kg()
  let accel = force_n / mass_kg
  if accel > self.params.max_acceleration {
    self.params.max_acceleration
  } else {
    accel
  }
}
