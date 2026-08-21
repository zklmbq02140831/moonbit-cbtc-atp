// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// PsdDoorState defines platform screen door interlock status.
pub enum PsdDoorState {
  DoorsClosedAndLocked
  DoorsOpening
  DoorsFullyOpen
  DoorsClosing
  DoorObstacleDetected
  EmergencyHandlePulled
} derive(Eq, Debug)

///|
pub fn PsdDoorState::from_code(code : Int) -> PsdDoorState {
  match code {
    1 => DoorsClosedAndLocked
    2 => DoorsOpening
    3 => DoorsFullyOpen
    4 => DoorsClosing
    5 => DoorObstacleDetected
    _ => EmergencyHandlePulled
  }
}

///|
/// PsdInterlockData holds platform screen door safety feedback signals.
pub struct PsdInterlockData {
  platform_id : Int
  door_state : PsdDoorState
  all_doors_closed_and_locked : Bool
  emergency_stop_button_active : Bool
} derive(Eq, Debug)

///|
pub fn PsdInterlockData::new(
  p_id : Int,
  st : PsdDoorState,
  closed : Bool,
  esb : Bool,
) -> PsdInterlockData {
  {
    platform_id: p_id,
    door_state: st,
    all_doors_closed_and_locked: closed,
    emergency_stop_button_active: esb,
  }
}
