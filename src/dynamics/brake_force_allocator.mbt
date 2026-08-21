// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// BrakeForceAllocator manages dynamic blending of electric regenerative braking and pneumatic friction braking.
pub struct BrakeForceAllocator {
  max_electric_brake_kn : Double
  max_pneumatic_brake_kn : Double
  catenary_voltage_available : Bool
} derive(Eq, Debug)

///|
pub fn BrakeForceAllocator::new(
  max_elec_kn : Double,
  max_pneu_kn : Double,
) -> BrakeForceAllocator {
  {
    max_electric_brake_kn: max_elec_kn,
    max_pneumatic_brake_kn: max_pneu_kn,
    catenary_voltage_available: true,
  }
}

///|
/// Allocate requested total brake force (in kN) between electric and pneumatic braking channels.
/// Returns (electric_force_kn, pneumatic_force_kn).
pub fn BrakeForceAllocator::allocate(
  self : BrakeForceAllocator,
  requested_force_kn : Double,
  speed_mps : Double,
) -> (Double, Double) {
  // Regenerative brake fades out below 10 km/h (2.78 m/s)
  let electric_usable = if self.catenary_voltage_available && speed_mps > 2.78 {
    self.max_electric_brake_kn
  } else {
    0.0
  }

  if requested_force_kn <= electric_usable {
    (requested_force_kn, 0.0)
  } else {
    let pneu_needed = requested_force_kn - electric_usable
    let final_pneu = if pneu_needed > self.max_pneumatic_brake_kn {
      self.max_pneumatic_brake_kn
    } else {
      pneu_needed
    }
    (electric_usable, final_pneu)
  }
}
