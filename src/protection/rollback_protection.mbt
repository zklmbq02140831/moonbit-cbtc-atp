// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// RollbackDetector monitors train direction and movement distance when stationary or advancing.
pub struct RollbackDetector {
  mut initial_pos_m : Double
  mut max_reverse_dist_m : Double
  allowed_rollback_limit_m : Double
} derive(Eq, Debug)

///|
pub fn RollbackDetector::new(limit_m : Double) -> RollbackDetector {
  {
    initial_pos_m: 0.0,
    max_reverse_dist_m: 0.0,
    allowed_rollback_limit_m: limit_m,
  }
}

///|
pub fn RollbackDetector::set_standby_position(
  self : RollbackDetector,
  pos_m : Double,
) -> Unit {
  self.initial_pos_m = pos_m
  self.max_reverse_dist_m = 0.0
}

///|
pub fn RollbackDetector::check_movement(
  self : RollbackDetector,
  current_pos_m : Double,
  expected_direction : Int, // 1 = Forward, -1 = Reverse
) -> Bool {
  let delta = current_pos_m - self.initial_pos_m
  if expected_direction == 1 && delta < 0.0 {
    let reverse_dist = delta.abs()
    if reverse_dist > self.max_reverse_dist_m {
      self.max_reverse_dist_m = reverse_dist
    }
    reverse_dist > self.allowed_rollback_limit_m
  } else if expected_direction == -1 && delta > 0.0 {
    let forward_dist = delta.abs()
    if forward_dist > self.max_reverse_dist_m {
      self.max_reverse_dist_m = forward_dist
    }
    forward_dist > self.allowed_rollback_limit_m
  } else {
    false
  }
}
