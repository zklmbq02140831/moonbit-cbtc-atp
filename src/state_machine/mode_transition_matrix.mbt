// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ModeTransitionMatrix defines Subsystem-026 compliant 16-mode state transition guard table.
pub struct ModeTransitionMatrix {
  matrix_version : Int
} derive(Eq, Debug)

///|
pub fn ModeTransitionMatrix::new() -> ModeTransitionMatrix {
  { matrix_version: 1 }
}

///|
pub fn ModeTransitionMatrix::can_transition(
  self : ModeTransitionMatrix,
  from_mode : EtcsOperatingMode,
  to_mode : EtcsOperatingMode,
  train_speed_mps : Double,
) -> Bool {
  let _ = self.matrix_version
  match (from_mode, to_mode) {
    (Standby, FullSupervision) => true
    (Standby, StaffResponsible) => true
    (FullSupervision, OnSight) => true
    (OnSight, FullSupervision) => true
    (FullSupervision, Trip) => true
    (OnSight, Trip) => true
    (StaffResponsible, Trip) => true
    (Trip, PostTrip) => train_speed_mps <= 0.01
    (PostTrip, Standby) => train_speed_mps <= 0.01
    _ => false
  }
}
