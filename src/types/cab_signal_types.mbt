// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// DmiDisplayState contains data formatted for the Driver Machine Interface (DMI) screen.
pub struct DmiDisplayState {
  current_speed_kmh : Double
  permitted_speed_kmh : Double
  target_speed_kmh : Double
  release_speed_kmh : Double
  distance_to_eoa_m : Double
  active_mode_name : String
  atp_status_text : String
  audible_alarm_active : Bool
  visual_warning_active : Bool
  brake_command_active : Bool
} derive(Eq, Debug)

///|
pub fn DmiDisplayState::new(
  current_v : Double,
  permitted_v : Double,
  target_v : Double,
  release_v : Double,
  dist_eoa : Double,
  mode : String,
  status : String,
  alarm : Bool,
  warning : Bool,
  brake : Bool,
) -> DmiDisplayState {
  {
    current_speed_kmh: current_v * 3.6,
    permitted_speed_kmh: permitted_v * 3.6,
    target_speed_kmh: target_v * 3.6,
    release_speed_kmh: release_v * 3.6,
    distance_to_eoa_m: dist_eoa,
    active_mode_name: mode,
    atp_status_text: status,
    audible_alarm_active: alarm,
    visual_warning_active: warning,
    brake_command_active: brake,
  }
}
