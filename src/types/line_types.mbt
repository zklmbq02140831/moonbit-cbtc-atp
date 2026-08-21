// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TrackSegment represents a contiguous section of railway track defined by start position,
/// end position, physical speed limit, gradient, curvature, and turnout state.
pub struct TrackSegment {
  segment_id : Int
  start_position : Double // in meters
  end_position : Double // in meters
  speed_limit : Double // in m/s
  gradient : Double // per-thousand (‰), positive for uphill, negative for downhill
  curvature_radius : Double // in meters, 0.0 means straight track
  is_tunnel : Bool
  switch_id : Int // 0 if no switch/turnout present
  switch_position : Double // relative position within segment
  max_switch_speed : Double // in m/s if switch diverging
} derive(Eq, Debug)

///|
pub fn TrackSegment::new(
  segment_id : Int,
  start_pos : Double,
  end_pos : Double,
  speed_limit : Double,
  gradient : Double,
  curvature : Double,
  is_tunnel : Bool,
  switch_id : Int,
  switch_pos : Double,
  max_switch_speed : Double,
) -> TrackSegment {
  {
    segment_id,
    start_position: start_pos,
    end_position: end_pos,
    speed_limit,
    gradient,
    curvature_radius: curvature,
    is_tunnel,
    switch_id,
    switch_position: switch_pos,
    max_switch_speed,
  }
}

///|
pub fn TrackSegment::length(self : TrackSegment) -> Double {
  self.end_position - self.start_position
}

///|
pub fn TrackSegment::contains(self : TrackSegment, pos : Double) -> Bool {
  pos >= self.start_position && pos <= self.end_position
}

///|
/// GradientSegment describes track inclination across spatial bounds.
pub struct GradientSegment {
  start_pos : Double
  end_pos : Double
  value : Double // gradient in per-thousand (‰)
} derive(Eq, Debug)

///|
pub fn GradientSegment::new(
  start_pos : Double,
  end_pos : Double,
  value : Double,
) -> GradientSegment {
  { start_pos, end_pos, value }
}

///|
/// CurvatureSegment describes track horizontal radius across spatial bounds.
pub struct CurvatureSegment {
  start_pos : Double
  end_pos : Double
  radius : Double // meters, 0.0 for tangent track
  cant : Double // track superelevation in mm
} derive(Eq, Debug)

///|
pub fn CurvatureSegment::new(
  start_pos : Double,
  end_pos : Double,
  radius : Double,
  cant : Double,
) -> CurvatureSegment {
  { start_pos, end_pos, radius, cant }
}

///|
/// PhysicalSpeedSegment represents maximum design speed limit for a line section.
pub struct PhysicalSpeedSegment {
  start_pos : Double
  end_pos : Double
  max_speed : Double // m/s
} derive(Eq, Debug)

///|
pub fn PhysicalSpeedSegment::new(
  start_pos : Double,
  end_pos : Double,
  max_speed : Double,
) -> PhysicalSpeedSegment {
  { start_pos, end_pos, max_speed }
}

///|
/// SwitchState represents the status of a track turnout.
pub enum SwitchPosition {
  Normal // Main line position
  Reverse // Diverging line position
  Moving // Transitioning
  Unknown // Fault or unknown state
} derive(Eq, Debug)

///|
pub fn SwitchPosition::from_int(code : Int) -> SwitchPosition {
  match code {
    1 => Normal
    2 => Reverse
    3 => Moving
    _ => Unknown
  }
}

///|
pub struct TrackSwitch {
  switch_id : Int
  position_m : Double
  state : SwitchPosition
  normal_speed_limit : Double // m/s
  reverse_speed_limit : Double // m/s
  locked : Bool
} derive(Eq, Debug)

///|
pub fn TrackSwitch::new(
  switch_id : Int,
  position_m : Double,
  state : SwitchPosition,
  normal_speed : Double,
  reverse_speed : Double,
  locked : Bool,
) -> TrackSwitch {
  {
    switch_id,
    position_m,
    state,
    normal_speed_limit: normal_speed,
    reverse_speed_limit: reverse_speed,
    locked,
  }
}

///|
pub fn TrackSwitch::allowed_speed(self : TrackSwitch) -> Double {
  match self.state {
    Normal => self.normal_speed_limit
    Reverse => self.reverse_speed_limit
    Moving | Unknown => 0.0
  }
}

///|
/// BaliseType indicates the role of a trackside transponder.
pub enum BaliseType {
  Fixed // Static location & speed profile balise
  Switchable // Signal aspect / MA infill balise
  Infill // Mid-block update balise
  Psd // Platform screen door synchronization balise
} derive(Eq, Debug)

///|
pub fn BaliseType::from_int(code : Int) -> BaliseType {
  match code {
    1 => Fixed
    2 => Switchable
    3 => Infill
    _ => Psd
  }
}

///|
pub struct BaliseData {
  balise_id : Int
  group_id : Int
  location : Double // track position in meters
  balise_type : BaliseType
  direction : Int // 1 for nominal, -1 for reverse, 0 for both
  telegram_bytes : Array[Int]
} derive(Eq, Debug)

///|
pub fn BaliseData::new(
  balise_id : Int,
  group_id : Int,
  location : Double,
  balise_type : BaliseType,
  direction : Int,
  telegram_bytes : Array[Int],
) -> BaliseData {
  { balise_id, group_id, location, balise_type, direction, telegram_bytes }
}
