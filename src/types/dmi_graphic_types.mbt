// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// DmiColorZone represents DMI speed dial color region for driver supervision.
pub enum DmiColorZone {
  Grey // Normal operation below permitted speed
  Yellow // Approaching target / Overspeed warning zone
  Orange // Service brake intervention zone
  Red // Emergency brake intervention zone
  DarkRed // Emergency trip / Hardware fault
} derive(Eq, Debug)

///|
pub fn DmiColorZone::code(self : DmiColorZone) -> Int {
  match self {
    Grey => 1
    Yellow => 2
    Orange => 3
    Red => 4
    DarkRed => 5
  }
}

///|
pub fn DmiColorZone::from_code(code : Int) -> DmiColorZone {
  match code {
    1 => Grey
    2 => Yellow
    3 => Orange
    4 => Red
    _ => DarkRed
  }
}

///|
/// DmiSpeedometerGauge contains angles and values for rendering DMI speed dial arc graphics.
pub struct DmiSpeedometerGauge {
  current_speed_kmh : Double
  permitted_speed_kmh : Double
  warning_speed_kmh : Double
  sbd_speed_kmh : Double
  ebd_speed_kmh : Double
  dial_max_speed_kmh : Double // e.g. 400 km/h
  pointer_angle_deg : Double // Dial pointer angle in degrees (0..240)
  active_color_zone : DmiColorZone
} derive(Eq, Debug)

///|
pub fn DmiSpeedometerGauge::new(
  current_v_mps : Double,
  thresh : ProtectionThresholds,
  dial_max_kmh : Double,
) -> DmiSpeedometerGauge {
  let curr_kmh = current_v_mps * 3.6
  let perm_kmh = thresh.permitted_speed * 3.6
  let warn_kmh = thresh.warning_speed * 3.6
  let sbd_kmh = thresh.service_brake_speed * 3.6
  let ebd_kmh = thresh.emergency_brake_speed * 3.6

  let angle = curr_kmh / dial_max_kmh * 240.0
  let zone = if curr_kmh >= ebd_kmh {
    Red
  } else if curr_kmh >= sbd_kmh {
    Orange
  } else if curr_kmh >= warn_kmh {
    Yellow
  } else {
    Grey
  }

  {
    current_speed_kmh: curr_kmh,
    permitted_speed_kmh: perm_kmh,
    warning_speed_kmh: warn_kmh,
    sbd_speed_kmh: sbd_kmh,
    ebd_speed_kmh: ebd_kmh,
    dial_max_speed_kmh: dial_max_kmh,
    pointer_angle_deg: angle,
    active_color_zone: zone,
  }
}
