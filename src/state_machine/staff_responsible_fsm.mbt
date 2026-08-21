// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SrSubFsm manages Staff Responsible (SR) mode state progression ($v \le 45$ km/h = 12.5 m/s).
pub struct StaffResponsibleSubFsm {
  max_sr_speed_mps : Double // 12.5 m/s = 45 km/h
  mut driver_override_acknowledged : Bool
} derive(Eq, Debug)

///|
pub fn StaffResponsibleSubFsm::new() -> StaffResponsibleSubFsm {
  { max_sr_speed_mps: 12.5, driver_override_acknowledged: false }
}

///|
pub fn StaffResponsibleSubFsm::acknowledge_sr_mode(
  self : StaffResponsibleSubFsm,
) -> Unit {
  self.driver_override_acknowledged = true
}

///|
pub fn StaffResponsibleSubFsm::is_speed_permitted(
  self : StaffResponsibleSubFsm,
  current_speed_mps : Double,
) -> Bool {
  self.driver_override_acknowledged &&
  current_speed_mps <= self.max_sr_speed_mps
}
