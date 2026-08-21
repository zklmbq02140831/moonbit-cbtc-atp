// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TrainBusTelegram represents a MVB / WTB train network bus packet for ATP sensor & actuator telemetry.
pub struct TrainBusTelegram {
  bus_id : Int
  cycle_seq_num : Int64
  timestamp_ms : Int64
  raw_wheel_pulses_channel_a : Int
  raw_wheel_pulses_channel_b : Int
  doppler_frequency_hz : Double
  brake_pipe_pressure_kpa : Double
  cylinder_pressure_kpa : Double
  traction_notch_percent : Double
  brake_notch_percent : Double
  emergency_brake_relay_closed : Bool
} derive(Eq, Debug)

///|
pub fn TrainBusTelegram::new(
  bus_id : Int,
  seq : Int64,
  ts : Int64,
  pulses_a : Int,
  pulses_b : Int,
  doppler : Double,
  pipe_press : Double,
  cyl_press : Double,
  trac_notch : Double,
  brake_notch : Double,
  eb_relay : Bool,
) -> TrainBusTelegram {
  {
    bus_id,
    cycle_seq_num: seq,
    timestamp_ms: ts,
    raw_wheel_pulses_channel_a: pulses_a,
    raw_wheel_pulses_channel_b: pulses_b,
    doppler_frequency_hz: doppler,
    brake_pipe_pressure_kpa: pipe_press,
    cylinder_pressure_kpa: cyl_press,
    traction_notch_percent: trac_notch,
    brake_notch_percent: brake_notch,
    emergency_brake_relay_closed: eb_relay,
  }
}
