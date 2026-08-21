// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// LevelCrossingInterlockManager evaluates level crossing speed limits along the route.
pub struct LevelCrossingInterlockManager {
  crossings : Array[@types.LevelCrossingProtection]
} derive(Eq, Debug)

///|
pub fn LevelCrossingInterlockManager::new(
  cross_array : Array[@types.LevelCrossingProtection],
) -> LevelCrossingInterlockManager {
  { crossings: cross_array }
}

///|
pub fn LevelCrossingInterlockManager::get_crossing_limit_at(
  self : LevelCrossingInterlockManager,
  pos_m : Double,
) -> Double {
  let mut min_limit = 1000.0
  for i = 0; i < self.crossings.length(); i = i + 1 {
    let lx = self.crossings[i]
    if (pos_m - lx.location_m).abs() <= lx.warning_distance_m {
      let allowed = lx.allowed_speed_mps()
      if allowed < min_limit {
        min_limit = allowed
      }
    }
  }
  min_limit
}
