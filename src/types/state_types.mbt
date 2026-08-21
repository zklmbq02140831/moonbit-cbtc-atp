// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// OdometerConfidence Interval represents position measurement accuracy bounds.
pub struct OdometerBounds {
  nominal_pos : Double // meters
  min_pos : Double // minimum estimated front position
  max_pos : Double // maximum estimated front position
  confidence_margin : Double // uncertainty margin in meters (+/-)
  slip_detected : Bool
  skid_detected : Bool
} derive(Eq, Debug)

///|
pub fn OdometerBounds::new(
  nominal : Double,
  margin : Double,
  slip : Bool,
  skid : Bool,
) -> OdometerBounds {
  {
    nominal_pos: nominal,
    min_pos: nominal - margin,
    max_pos: nominal + margin,
    confidence_margin: margin,
    slip_detected: slip,
    skid_detected: skid,
  }
}

///|
/// CabOperatingMode defines active driver control mode.
pub enum CabMode {
  AutomaticTrainOperation // ATO mode (automatic driving)
  AutomaticTrainProtection // ATP Manual (driver drives under ATP supervision)
  RestrictedManual // RM mode (low-speed sight driving under 25 km/h)
  OnSight // OS mode
  Shunting // SH mode
  NonLeading // NL mode
  StandbyCab // SB mode
  SystemFailure // SF mode
} derive(Eq, Debug)

///|
pub fn CabMode::from_int(code : Int) -> CabMode {
  match code {
    1 => AutomaticTrainOperation
    2 => AutomaticTrainProtection
    3 => RestrictedManual
    4 => OnSight
    5 => Shunting
    6 => NonLeading
    7 => StandbyCab
    _ => SystemFailure
  }
}

///|
/// TrainState represents instantaneous physical state of the train.
pub struct TrainState {
  timestamp_ms : Int64
  odometer : OdometerBounds
  speed : Double // m/s (instantaneous estimated speed)
  acceleration : Double // m/s^2
  cab_mode : CabMode
  direction : Int // 1 = forward, -1 = reverse, 0 = stationary
  door_open : Bool
  brake_applied : Bool
  emergency_brake_applied : Bool
} derive(Eq, Debug)

///|
pub fn TrainState::new(
  timestamp : Int64,
  odometer : OdometerBounds,
  speed : Double,
  accel : Double,
  mode : CabMode,
  dir : Int,
  door_open : Bool,
  brake : Bool,
  eb : Bool,
) -> TrainState {
  {
    timestamp_ms: timestamp,
    odometer,
    speed,
    acceleration: accel,
    cab_mode: mode,
    direction: dir,
    door_open,
    brake_applied: brake,
    emergency_brake_applied: eb,
  }
}

///|
/// SafetyAlertLog records security state changes and trip alerts.
pub struct SafetyAlertLog {
  timestamp_ms : Int64
  alert_code : Int
  severity : Int // 1 = Info, 2 = Warning, 3 = Service Brake, 4 = Emergency Trip
  message : String
  position_m : Double
  speed_mps : Double
} derive(Eq, Debug)

///|
pub fn SafetyAlertLog::new(
  ts : Int64,
  code : Int,
  sev : Int,
  msg : String,
  pos : Double,
  speed : Double,
) -> SafetyAlertLog {
  {
    timestamp_ms: ts,
    alert_code: code,
    severity: sev,
    message: msg,
    position_m: pos,
    speed_mps: speed,
  }
}
