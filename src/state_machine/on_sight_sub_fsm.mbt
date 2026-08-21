// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// OsSubState defines sub-states for On Sight (OS) driver sight driving mode under 30 km/h.
pub enum OsSubState {
  VisionScan
  RestrictedAdvance
  ObstacleAlert
  FullStop
} derive(Eq, Debug)

///|
pub fn OsSubState::from_code(code : Int) -> OsSubState {
  match code {
    1 => VisionScan
    2 => RestrictedAdvance
    3 => ObstacleAlert
    _ => FullStop
  }
}

///|
/// OnSightSubFsm manages On Sight driver mode restrictions.
pub struct OnSightSubFsm {
  mut sub_state : OsSubState
  max_os_speed_mps : Double // 8.33 m/s = 30 km/h
} derive(Eq, Debug)

///|
pub fn OnSightSubFsm::new() -> OnSightSubFsm {
  { sub_state: VisionScan, max_os_speed_mps: 8.33 }
}

///|
pub fn OnSightSubFsm::update(
  self : OnSightSubFsm,
  current_speed_mps : Double,
  obstacle_detected : Bool,
) -> OsSubState {
  if obstacle_detected {
    self.sub_state = ObstacleAlert
  } else if current_speed_mps <= 0.01 {
    self.sub_state = FullStop
  } else if current_speed_mps <= self.max_os_speed_mps {
    self.sub_state = RestrictedAdvance
  } else {
    self.sub_state = VisionScan
  }
  self.sub_state
}
