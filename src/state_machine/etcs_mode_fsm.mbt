// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EtcsOperatingMode represents all 16 operating modes defined by Subset-026.
pub enum EtcsOperatingMode {
  FullSupervision // FS: Full supervision under ATP MA
  OnSight // OS: Driver drives on sight under 30 km/h
  StaffResponsible // SR: Driver responsible under 45 km/h
  Shunting // SH: Yard shunting mode under 30 km/h
  Reversing // RV: Reverse movement mode
  Sleeping // SL: Remote cab sleeping
  Standby // SB: Cab active, waiting for mode selection
  Trip // TR: Train emergency trip activated
  PostTrip // PT: Train stopped after emergency trip
  SystemFailure // SF: Hardware / software SIL4 fault
  Isolation // IS: ATP equipment isolated
  Unfitted // UN: Running on unfitted line
  LimitedSupervision // LS: Limited supervision under track circuit
  NonLeading // NL: Slave locomotive non-leading mode
  NationalSystem // SN: National legacy train control system
} derive(Eq, Debug)

///|
pub fn EtcsOperatingMode::code(self : EtcsOperatingMode) -> Int {
  match self {
    FullSupervision => 1
    OnSight => 2
    StaffResponsible => 3
    Shunting => 4
    Reversing => 5
    Sleeping => 6
    Standby => 7
    Trip => 8
    PostTrip => 9
    SystemFailure => 10
    Isolation => 11
    Unfitted => 12
    LimitedSupervision => 13
    NonLeading => 14
    NationalSystem => 15
  }
}

///|
pub fn EtcsOperatingMode::from_code(code : Int) -> EtcsOperatingMode {
  match code {
    1 => FullSupervision
    2 => OnSight
    3 => StaffResponsible
    4 => Shunting
    5 => Reversing
    6 => Sleeping
    7 => Standby
    8 => Trip
    9 => PostTrip
    10 => SystemFailure
    11 => Isolation
    12 => Unfitted
    13 => LimitedSupervision
    14 => NonLeading
    _ => NationalSystem
  }
}

///|
/// EtcsModeFsm executes transition table for ETCS 16-mode state machine.
pub struct EtcsModeFsm {
  mut current_mode : EtcsOperatingMode
} derive(Eq, Debug)

///|
pub fn EtcsModeFsm::new() -> EtcsModeFsm {
  { current_mode: Standby }
}

///|
pub fn EtcsModeFsm::mode(self : EtcsModeFsm) -> EtcsOperatingMode {
  self.current_mode
}

///|
pub fn EtcsModeFsm::evaluate_transition(
  self : EtcsModeFsm,
  valid_ma_received : Bool,
  trip_triggered : Bool,
  driver_ack : Bool,
  train_stopped : Bool,
) -> EtcsOperatingMode {
  if trip_triggered {
    self.current_mode = Trip
    return Trip
  }

  let next = match self.current_mode {
    Standby =>
      if valid_ma_received {
        FullSupervision
      } else {
        StaffResponsible
      }
    FullSupervision =>
      if !valid_ma_received {
        OnSight
      } else {
        FullSupervision
      }
    OnSight => if valid_ma_received { FullSupervision } else { OnSight }
    Trip => if train_stopped { PostTrip } else { Trip }
    PostTrip => if driver_ack { Standby } else { PostTrip }
    _ => self.current_mode
  }

  self.current_mode = next
  self.current_mode
}
