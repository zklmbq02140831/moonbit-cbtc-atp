// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// MaResolver maintains and validates active Movement Authority.
pub struct MaResolver {
  mut current_ma : @types.MovementAuthority?
  mut last_update_ms : Int64
  timeout_threshold_ms : Int64
} derive(Eq, Debug)

///|
pub fn MaResolver::new(timeout_ms : Int64) -> MaResolver {
  { current_ma: None, last_update_ms: 0, timeout_threshold_ms: timeout_ms }
}

///|
pub fn MaResolver::update_ma(
  self : MaResolver,
  ma : @types.MovementAuthority,
  now_ms : Int64,
) -> Unit {
  self.current_ma = Some(ma)
  self.last_update_ms = now_ms
}

///|
pub fn MaResolver::is_expired(self : MaResolver, now_ms : Int64) -> Bool {
  match self.current_ma {
    None => true
    Some(ma) =>
      !is_valid_ma(ma) ||
      now_ms < self.last_update_ms ||
      now_ms - self.last_update_ms > self.timeout_threshold_ms
  }
}

///|
pub fn MaResolver::get_active_eoa(self : MaResolver, now_ms : Int64) -> Double? {
  if self.is_expired(now_ms) {
    None
  } else {
    match self.current_ma {
      Some(ma) => Some(ma.eoa_position)
      None => None
    }
  }
}

///|
pub fn MaResolver::get_active_target_speed(
  self : MaResolver,
  now_ms : Int64,
) -> Double {
  if self.is_expired(now_ms) {
    0.0
  } else {
    match self.current_ma {
      Some(ma) => ma.target_speed
      None => 0.0
    }
  }
}

///|
pub fn MaResolver::get_active_route_speed_limit(
  self : MaResolver,
  now_ms : Int64,
) -> Double? {
  if self.is_expired(now_ms) {
    None
  } else {
    match self.current_ma {
      Some(ma) => Some(ma.route_speed_limit)
      None => None
    }
  }
}

///|
pub fn MaResolver::remaining_distance_to_eoa(
  self : MaResolver,
  current_pos : Double,
  now_ms : Int64,
) -> Double {
  match self.get_active_eoa(now_ms) {
    Some(eoa) => eoa - current_pos
    None => 0.0
  }
}

///|
fn is_valid_ma(ma : @types.MovementAuthority) -> Bool {
  ma.is_valid &&
  ma.timestamp_ms >= 0 &&
  ma.start_position.is_nan() == false &&
  ma.start_position.is_inf() == false &&
  ma.eoa_position.is_nan() == false &&
  ma.eoa_position.is_inf() == false &&
  ma.overlap_distance.is_nan() == false &&
  ma.overlap_distance.is_inf() == false &&
  ma.target_speed.is_nan() == false &&
  ma.target_speed.is_inf() == false &&
  ma.route_speed_limit.is_nan() == false &&
  ma.route_speed_limit.is_inf() == false &&
  ma.start_position >= 0.0 &&
  ma.eoa_position >= ma.start_position &&
  ma.overlap_distance >= 0.0 &&
  ma.target_speed >= 0.0 &&
  ma.route_speed_limit >= 0.0
}
