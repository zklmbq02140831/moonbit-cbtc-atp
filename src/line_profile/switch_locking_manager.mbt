// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SwitchLockingManager handles turnout locking timers and release conditions.
pub struct SwitchLockingManager {
  switches : Array[@types.TrackSwitch]
} derive(Eq, Debug)

///|
pub fn SwitchLockingManager::new(
  sw_array : Array[@types.TrackSwitch],
) -> SwitchLockingManager {
  { switches: sw_array }
}

///|
pub fn SwitchLockingManager::is_all_switches_locked_on_route(
  self : SwitchLockingManager,
  start_pos_m : Double,
  end_pos_m : Double,
) -> Bool {
  for i = 0; i < self.switches.length(); i = i + 1 {
    let sw = self.switches[i]
    if sw.position_m >= start_pos_m && sw.position_m <= end_pos_m {
      if !sw.locked {
        return false
      }
    }
  }
  true
}
