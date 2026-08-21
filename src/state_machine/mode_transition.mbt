// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// OperatingModeManager manages ETCS / CBTC driver operating mode transitions.
pub struct OperatingModeManager {
  mut active_mode : @types.CabMode
} derive(Eq, Debug)

///|
pub fn OperatingModeManager::new() -> OperatingModeManager {
  { active_mode: @types.CabMode::from_int(7) } // StandbyCab (7)
}

///|
pub fn OperatingModeManager::get_mode(
  self : OperatingModeManager,
) -> @types.CabMode {
  self.active_mode
}

///|
pub fn OperatingModeManager::request_transition(
  self : OperatingModeManager,
  target_mode : @types.CabMode,
  train_speed : Double,
  driver_ack : Bool,
) -> Bool {
  if train_speed <= 0.01 || driver_ack {
    self.active_mode = target_mode
    true
  } else {
    false
  }
}
