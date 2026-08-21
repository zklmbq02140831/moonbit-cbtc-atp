// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// LevelCrossingState defines highway-rail grade crossing interlock status.
pub enum LevelCrossingState {
  OpenToHighway // Gate arms up, train speed restricted to 15 km/h
  ClosingInProcess // Warning bell active, gates lowering
  FullyClosedAndLocked // Gates down, train proceed at normal speed
  CrossingFault // Gate failure / obstacle detected
} derive(Eq, Debug)

///|
pub fn LevelCrossingState::from_code(code : Int) -> LevelCrossingState {
  match code {
    1 => OpenToHighway
    2 => ClosingInProcess
    3 => FullyClosedAndLocked
    _ => CrossingFault
  }
}

///|
/// LevelCrossingProtection describes level crossing location and warning activation distance.
pub struct LevelCrossingProtection {
  crossing_id : Int
  location_m : Double
  state : LevelCrossingState
  warning_distance_m : Double // Distance before crossing to activate warning
  max_crossing_speed_mps : Double // Speed allowed if open (e.g. 4.17 m/s = 15 km/h)
} derive(Eq, Debug)

///|
pub fn LevelCrossingProtection::new(
  id : Int,
  loc_m : Double,
  st : LevelCrossingState,
  warn_dist : Double,
) -> LevelCrossingProtection {
  {
    crossing_id: id,
    location_m: loc_m,
    state: st,
    warning_distance_m: warn_dist,
    max_crossing_speed_mps: 4.17,
  }
}

///|
pub fn LevelCrossingProtection::allowed_speed_mps(
  self : LevelCrossingProtection,
) -> Double {
  match self.state {
    FullyClosedAndLocked => 1000.0 // No extra restriction
    OpenToHighway | ClosingInProcess => self.max_crossing_speed_mps
    CrossingFault => 0.0 // Full stop required if fault
  }
}
