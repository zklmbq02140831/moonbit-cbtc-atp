// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// WheelDiameterAutoCalibrator updates wheel diameter based on precise track balise pair distances.
pub struct WheelDiameterAutoCalibrator {
  mut calibrated_wheel_diameter_m : Double
  nominal_wheel_diameter_m : Double
} derive(Eq, Debug)

///|
pub fn WheelDiameterAutoCalibrator::new(
  nominal_d_m : Double,
) -> WheelDiameterAutoCalibrator {
  {
    calibrated_wheel_diameter_m: nominal_d_m,
    nominal_wheel_diameter_m: nominal_d_m,
  }
}

///|
pub fn WheelDiameterAutoCalibrator::calibrate_from_balise_pair(
  self : WheelDiameterAutoCalibrator,
  actual_distance_between_balises_m : Double,
  measured_wheel_revolutions : Double,
) -> Double {
  if measured_wheel_revolutions <= 0.1 {
    return self.calibrated_wheel_diameter_m
  }

  let measured_circumference = actual_distance_between_balises_m /
    measured_wheel_revolutions
  let new_diameter = measured_circumference / 3.141592653589793
  self.calibrated_wheel_diameter_m = new_diameter
  self.calibrated_wheel_diameter_m
}
