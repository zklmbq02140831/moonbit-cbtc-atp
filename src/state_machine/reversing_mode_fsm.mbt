// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ReversingSubFsm manages Reversing (RV) mode ($v \le 2.78$ m/s = 10 km/h, max distance 100m).
pub struct ReversingSubFsm {
  max_rv_speed_mps : Double // 2.78 m/s
  max_rv_distance_m : Double // 100.0 m
  mut rv_start_pos_m : Double
} derive(Eq, Debug)

///|
pub fn ReversingSubFsm::new() -> ReversingSubFsm {
  { max_rv_speed_mps: 2.78, max_rv_distance_m: 100.0, rv_start_pos_m: 0.0 }
}

///|
pub fn ReversingSubFsm::start_reversing(
  self : ReversingSubFsm,
  current_pos_m : Double,
) -> Unit {
  self.rv_start_pos_m = current_pos_m
}

///|
pub fn ReversingSubFsm::is_reversing_permitted(
  self : ReversingSubFsm,
  current_pos_m : Double,
  current_speed_mps : Double,
) -> Bool {
  let dist = (self.rv_start_pos_m - current_pos_m).abs()
  dist <= self.max_rv_distance_m && current_speed_mps <= self.max_rv_speed_mps
}
