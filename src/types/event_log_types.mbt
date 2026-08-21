// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// BlackBoxEventRecord models crash recorder event log entry.
pub struct BlackBoxEventRecord {
  event_id : Int64
  timestamp_ms : Int64
  event_code : Int
  train_speed_mps : Double
  train_position_m : Double
  atp_state_code : Int
  driver_cab_mode_code : Int
  brake_status_mask : Int
  payload_param1 : Double
  payload_param2 : Double
} derive(Eq, Debug)

///|
pub fn BlackBoxEventRecord::new(
  id : Int64,
  ts : Int64,
  code : Int,
  speed : Double,
  pos : Double,
  state : Int,
  mode : Int,
  brake : Int,
  p1 : Double,
  p2 : Double,
) -> BlackBoxEventRecord {
  {
    event_id: id,
    timestamp_ms: ts,
    event_code: code,
    train_speed_mps: speed,
    train_position_m: pos,
    atp_state_code: state,
    driver_cab_mode_code: mode,
    brake_status_mask: brake,
    payload_param1: p1,
    payload_param2: p2,
  }
}
