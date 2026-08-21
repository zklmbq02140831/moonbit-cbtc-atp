// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ShuntingSubFsm manages Shunting (SH) yard switching operations ($v \le 30$ km/h).
pub struct ShuntingSubFsm {
  mut active : Bool
  max_shunt_speed_mps : Double // 8.33 m/s = 30 km/h
} derive(Eq, Debug)

///|
pub fn ShuntingSubFsm::new() -> ShuntingSubFsm {
  { active: false, max_shunt_speed_mps: 8.33 }
}

///|
pub fn ShuntingSubFsm::activate(self : ShuntingSubFsm) -> Unit {
  self.active = true
}

///|
pub fn ShuntingSubFsm::deactivate(self : ShuntingSubFsm) -> Unit {
  self.active = false
}

///|
pub fn ShuntingSubFsm::is_overspeed(
  self : ShuntingSubFsm,
  current_speed_mps : Double,
) -> Bool {
  self.active && current_speed_mps > self.max_shunt_speed_mps
}
