// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// CurvePoint represents a discrete node (position, speed) on a deceleration or speed profile curve.
pub struct CurvePoint {
  position : Double // meters
  speed : Double // m/s
  deceleration : Double // m/s^2 at this point
  time_to_target : Double // seconds remaining to target point
} derive(Eq, Debug)

///|
pub fn CurvePoint::new(
  pos : Double,
  speed : Double,
  decel : Double,
  time : Double,
) -> CurvePoint {
  { position: pos, speed, deceleration: decel, time_to_target: time }
}

///|
/// DynamicBrakeCurve contains sequence of interpolated curve points representing EBD/SBD/Warn limits.
pub struct DynamicBrakeCurve {
  curve_type : String // "EBD", "SBD", or "WARN"
  points : Array[CurvePoint]
  target_position : Double // EOA or TSR target position
  target_speed : Double // m/s at target
  mut total_distance : Double // meters from curve start to target
} derive(Eq, Debug)

///|
pub fn DynamicBrakeCurve::new(
  ctype : String,
  target_pos : Double,
  target_v : Double,
) -> DynamicBrakeCurve {
  {
    curve_type: ctype,
    points: Array::new(),
    target_position: target_pos,
    target_speed: target_v,
    total_distance: 0.0,
  }
}

///|
pub fn DynamicBrakeCurve::add_point(
  self : DynamicBrakeCurve,
  pt : CurvePoint,
) -> Unit {
  self.points.push(pt)
}

///|
pub fn DynamicBrakeCurve::set_total_distance(
  self : DynamicBrakeCurve,
  dist : Double,
) -> Unit {
  self.total_distance = dist
}

///|
pub fn DynamicBrakeCurve::get_total_distance(
  self : DynamicBrakeCurve,
) -> Double {
  self.total_distance
}

///|
/// ProtectionThresholds summarizes the current speed limit boundaries at train position s.
pub struct ProtectionThresholds {
  position : Double // meters
  permitted_speed : Double // m/s (Static / Dynamic profile permitted speed)
  warning_speed : Double // m/s (Overspeed Warning intervention threshold)
  service_brake_speed : Double // m/s (Full Service Brake intervention threshold)
  emergency_brake_speed : Double // m/s (Emergency Brake intervention threshold)
  trip_speed : Double // m/s (SIL4 Emergency Trip boundary threshold)
  margin_to_eoa : Double // meters remaining to EOA
} derive(Eq, Debug)

///|
pub fn ProtectionThresholds::new(
  pos : Double,
  permitted : Double,
  warning : Double,
  sbd : Double,
  ebd : Double,
  trip : Double,
  eoa_margin : Double,
) -> ProtectionThresholds {
  {
    position: pos,
    permitted_speed: permitted,
    warning_speed: warning,
    service_brake_speed: sbd,
    emergency_brake_speed: ebd,
    trip_speed: trip,
    margin_to_eoa: eoa_margin,
  }
}

///|
/// MovementAuthority (MA) defines the authority granted by trackside ATS/CBI/ZC.
pub struct MovementAuthority {
  ma_id : Int
  timestamp_ms : Int64
  start_position : Double // meters
  eoa_position : Double // End of Authority position in meters
  overlap_distance : Double // safety overlap margin beyond EOA
  target_speed : Double // target speed at EOA (usually 0.0 m/s for red signal)
  route_speed_limit : Double // maximum speed allowed along the route
  is_valid : Bool
} derive(Eq, Debug)

///|
pub fn MovementAuthority::new(
  ma_id : Int,
  ts : Int64,
  start_pos : Double,
  eoa_pos : Double,
  overlap : Double,
  target_v : Double,
  route_v : Double,
) -> MovementAuthority {
  {
    ma_id,
    timestamp_ms: ts,
    start_position: start_pos,
    eoa_position: eoa_pos,
    overlap_distance: overlap,
    target_speed: target_v,
    route_speed_limit: route_v,
    is_valid: true,
  }
}

///|
/// TemporarySpeedRestriction (TSR) structure.
pub struct TemporarySpeedRestriction {
  tsr_id : Int
  start_position : Double // meters
  end_position : Double // meters
  speed_limit : Double // m/s
  active : Bool
  reason_code : Int // e.g. 1 = Maintenance, 2 = Weather, 3 = Defect
} derive(Eq, Debug)

///|
pub fn TemporarySpeedRestriction::new(
  id : Int,
  start_p : Double,
  end_p : Double,
  limit : Double,
  active : Bool,
  reason : Int,
) -> TemporarySpeedRestriction {
  {
    tsr_id: id,
    start_position: start_p,
    end_position: end_p,
    speed_limit: limit,
    active,
    reason_code: reason,
  }
}
