// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// WheelSlideProtector (WSP) models anti-skid pneumatic dump valve modulation (UIC 541-05).
pub struct WheelSlideProtector {
  mut valve_venting_active : Bool
  mut vent_cycle_counter : Int
  slip_threshold : Double
} derive(Eq, Debug)

///|
pub fn WheelSlideProtector::new(slip_limit : Double) -> WheelSlideProtector {
  {
    valve_venting_active: false,
    vent_cycle_counter: 0,
    slip_threshold: slip_limit,
  }
}

///|
pub fn WheelSlideProtector::evaluate_wsp_action(
  self : WheelSlideProtector,
  wheel_speed_mps : Double,
  reference_radar_speed_mps : Double,
) -> Double {
  if reference_radar_speed_mps <= 0.1 {
    self.valve_venting_active = false
    return 1.0 // Full brake pressure
  }

  let slip_ratio = (reference_radar_speed_mps - wheel_speed_mps) /
    reference_radar_speed_mps
  if slip_ratio > self.slip_threshold {
    self.valve_venting_active = true
    self.vent_cycle_counter = self.vent_cycle_counter + 1
    0.3 // Vent brake cylinder pressure down to 30% to regain adhesion
  } else {
    self.valve_venting_active = false
    1.0 // Restore full brake pressure
  }
}
