// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TrackChainagePoint maps physical WGS84 geographic coordinate to track line chainage kilometer post (KM post).
pub struct TrackChainagePoint {
  chainage_m : Double // Track position in meters (e.g. K125+400 = 125400m)
  latitude : Double // WGS84 deg
  longitude : Double // WGS84 deg
  altitude_m : Double
  track_line_id : Int // Line ID (e.g. 1 = Down line, 2 = Up line)
} derive(Eq, Debug)

///|
pub fn TrackChainagePoint::new(
  chainage : Double,
  lat : Double,
  lon : Double,
  alt : Double,
  line_id : Int,
) -> TrackChainagePoint {
  {
    chainage_m: chainage,
    latitude: lat,
    longitude: lon,
    altitude_m: alt,
    track_line_id: line_id,
  }
}

///|
/// StationPlatformLocation describes platform screen door (PSD) interlock and stopping alignment bounds.
pub struct StationPlatformLocation {
  station_id : Int
  station_name : String
  platform_start_m : Double
  platform_stop_center_m : Double
  platform_end_m : Double
  stopping_tolerance_m : Double // e.g. +/- 0.5m for PSD alignment
  psd_door_count : Int
  psd_interlock_closed : Bool
} derive(Eq, Debug)

///|
pub fn StationPlatformLocation::new(
  station_id : Int,
  name : String,
  start_m : Double,
  center_m : Double,
  end_m : Double,
  tol_m : Double,
  doors : Int,
) -> StationPlatformLocation {
  {
    station_id,
    station_name: name,
    platform_start_m: start_m,
    platform_stop_center_m: center_m,
    platform_end_m: end_m,
    stopping_tolerance_m: tol_m,
    psd_door_count: doors,
    psd_interlock_closed: true,
  }
}

///|
pub fn StationPlatformLocation::is_aligned(
  self : StationPlatformLocation,
  train_front_pos_m : Double,
  train_length_m : Double,
) -> Bool {
  let train_center_pos = train_front_pos_m - train_length_m / 2.0
  (train_center_pos - self.platform_stop_center_m).abs() <=
  self.stopping_tolerance_m
}
