// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// UnintendedMovementProtection monitors un-commanded train motion while stationary with brakes released.
pub struct UnintendedMovementProtection {
  max_unintended_dist_m : Double // 0.5m
  mut locked_pos_m : Double
  mut protection_armed : Bool
} derive(Eq, Debug)

///|
pub fn UnintendedMovementProtection::new() -> UnintendedMovementProtection {
  { max_unintended_dist_m: 0.5, locked_pos_m: 0.0, protection_armed: false }
}

///|
pub fn UnintendedMovementProtection::arm_protection(
  self : UnintendedMovementProtection,
  pos_m : Double,
) -> Unit {
  self.locked_pos_m = pos_m
  self.protection_armed = true
}

///|
pub fn UnintendedMovementProtection::disarm_protection(
  self : UnintendedMovementProtection,
) -> Unit {
  self.protection_armed = false
}

///|
pub fn UnintendedMovementProtection::check_unintended_movement(
  self : UnintendedMovementProtection,
  current_pos_m : Double,
) -> Bool {
  if !self.protection_armed {
    false
  } else {
    let delta = (current_pos_m - self.locked_pos_m).abs()
    delta > self.max_unintended_dist_m
  }
}
