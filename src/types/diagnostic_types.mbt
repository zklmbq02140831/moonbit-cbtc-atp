// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// HardwareSensorStatus represents diagnostic status of onboard sensors.
pub struct HardwareSensorStatus {
  wheel_encoder_1_ok : Bool
  wheel_encoder_2_ok : Bool
  doppler_radar_ok : Bool
  balise_antenna_ok : Bool
  radio_modem_a_ok : Bool
  radio_modem_b_ok : Bool
  brake_pressure_sensor_ok : Bool
} derive(Eq, Debug)

///|
pub fn HardwareSensorStatus::healthy_default() -> HardwareSensorStatus {
  {
    wheel_encoder_1_ok: true,
    wheel_encoder_2_ok: true,
    doppler_radar_ok: true,
    balise_antenna_ok: true,
    radio_modem_a_ok: true,
    radio_modem_b_ok: true,
    brake_pressure_sensor_ok: true,
  }
}

///|
pub fn HardwareSensorStatus::is_all_healthy(
  self : HardwareSensorStatus,
) -> Bool {
  self.wheel_encoder_1_ok &&
  self.wheel_encoder_2_ok &&
  self.doppler_radar_ok &&
  self.balise_antenna_ok &&
  self.radio_modem_a_ok &&
  self.radio_modem_b_ok &&
  self.brake_pressure_sensor_ok
}
