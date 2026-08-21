// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// FsSubState defines sub-states within Full Supervision (FS) operating mode.
pub enum FsSubState {
  Accelerating
  Coasting
  TargetApproaching
  TargetReached
} derive(Eq, Debug)

///|
pub fn FsSubState::from_code(code : Int) -> FsSubState {
  match code {
    1 => Accelerating
    2 => Coasting
    3 => TargetApproaching
    _ => TargetReached
  }
}

///|
/// FullSupervisionSubFsm manages internal state progression while in FS mode.
pub struct FullSupervisionSubFsm {
  mut sub_state : FsSubState
} derive(Eq, Debug)

///|
pub fn FullSupervisionSubFsm::new() -> FullSupervisionSubFsm {
  { sub_state: Coasting }
}

///|
pub fn FullSupervisionSubFsm::update(
  self : FullSupervisionSubFsm,
  accel_mps2 : Double,
  dist_to_eoa_m : Double,
  speed_mps : Double,
) -> FsSubState {
  if dist_to_eoa_m <= 50.0 {
    if speed_mps <= 0.05 {
      self.sub_state = TargetReached
    } else {
      self.sub_state = TargetApproaching
    }
  } else if accel_mps2 > 0.1 {
    self.sub_state = Accelerating
  } else {
    self.sub_state = Coasting
  }
  self.sub_state
}
