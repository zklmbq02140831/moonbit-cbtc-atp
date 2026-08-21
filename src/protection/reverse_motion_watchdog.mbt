// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ReverseMotionWatchdog monitors unintended roll-away or reverse movement during station dwell.
pub struct ReverseMotionWatchdog {
  allowed_reverse_limit_m : Double
  mut standby_pos_m : Double
} derive(Eq, Debug)

///|
pub fn ReverseMotionWatchdog::new(limit_m : Double) -> ReverseMotionWatchdog {
  { allowed_reverse_limit_m: limit_m, standby_pos_m: 0.0 }
}

///|
pub fn ReverseMotionWatchdog::arm_standby_pos(
  self : ReverseMotionWatchdog,
  pos_m : Double,
) -> Unit {
  self.standby_pos_m = pos_m
}

///|
pub fn ReverseMotionWatchdog::is_roll_away_detected(
  self : ReverseMotionWatchdog,
  current_pos_m : Double,
) -> Bool {
  let delta = self.standby_pos_m - current_pos_m
  delta > self.allowed_reverse_limit_m
}
