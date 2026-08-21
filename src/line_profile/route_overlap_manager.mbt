// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// RouteOverlapManager manages EOA overlap length and timer-based overlap release.
pub struct RouteOverlapManager {
  overlap_distance_m : Double
  release_timer_s : Int
  mut timer_started_timestamp_ms : Int64
  mut overlap_released : Bool
} derive(Eq, Debug)

///|
pub fn RouteOverlapManager::new(
  d_overlap : Double,
  t_release : Int,
) -> RouteOverlapManager {
  {
    overlap_distance_m: d_overlap,
    release_timer_s: t_release,
    timer_started_timestamp_ms: 0,
    overlap_released: false,
  }
}

///|
pub fn RouteOverlapManager::start_timer(
  self : RouteOverlapManager,
  now_ms : Int64,
) -> Unit {
  self.timer_started_timestamp_ms = now_ms
  self.overlap_released = false
}

///|
pub fn RouteOverlapManager::check_release(
  self : RouteOverlapManager,
  now_ms : Int64,
) -> Bool {
  if self.timer_started_timestamp_ms == 0 {
    return false
  }
  let elapsed_s = (now_ms - self.timer_started_timestamp_ms) / 1000
  if elapsed_s >= self.release_timer_s.to_int64() {
    self.overlap_released = true
    true
  } else {
    false
  }
}
