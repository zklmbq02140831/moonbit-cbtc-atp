// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AxleCounterDetectorHead defines double-head inductive wheel sensor (Head A and Head B).
pub struct AxleCounterDetectorHead {
  detector_id : Int
  location_m : Double
  head_a_pulse_count : Int
  head_b_pulse_count : Int
  wheel_direction_forward : Bool
  sensor_fault : Bool
} derive(Eq, Debug)

///|
pub fn AxleCounterDetectorHead::new(
  id : Int,
  loc_m : Double,
) -> AxleCounterDetectorHead {
  {
    detector_id: id,
    location_m: loc_m,
    head_a_pulse_count: 0,
    head_b_pulse_count: 0,
    wheel_direction_forward: true,
    sensor_fault: false,
  }
}

///|
/// AxleCounterSectionEvaluator keeps axle count balance (In_Count - Out_Count = 0).
pub struct AxleCounterSection {
  section_id : Int
  entry_detector_id : Int
  exit_detector_id : Int
  mut axles_in : Int
  mut axles_out : Int
  mut section_occupied : Bool
} derive(Eq, Debug)

///|
pub fn AxleCounterSection::new(
  sec_id : Int,
  entry_id : Int,
  exit_id : Int,
) -> AxleCounterSection {
  {
    section_id: sec_id,
    entry_detector_id: entry_id,
    exit_detector_id: exit_id,
    axles_in: 0,
    axles_out: 0,
    section_occupied: false,
  }
}

///|
pub fn AxleCounterSection::record_axle_in(self : AxleCounterSection) -> Unit {
  self.axles_in = self.axles_in + 1
  self.section_occupied = true
}

///|
pub fn AxleCounterSection::record_axle_out(self : AxleCounterSection) -> Unit {
  self.axles_out = self.axles_out + 1
  if self.axles_in <= self.axles_out {
    self.axles_in = 0
    self.axles_out = 0
    self.section_occupied = false
  }
}

///|
pub fn AxleCounterSection::is_clear(self : AxleCounterSection) -> Bool {
  !self.section_occupied && self.axles_in == self.axles_out
}
