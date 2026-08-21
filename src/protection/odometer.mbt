// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// OdometerTracker models odometer accumulation, slippage/skid detection, and safe position expansion.
pub struct OdometerTracker {
  mut accumulated_pos : Double
  mut confidence_margin : Double
  mut prev_timestamp_ms : Int64
  mut prev_raw_speed : Double
  slip_ratio_limit : Double
} derive(Eq, Debug)

///|
pub fn OdometerTracker::new(
  start_pos : Double,
  start_margin : Double,
  slip_limit : Double
) -> OdometerTracker {
  {
    accumulated_pos: start_pos,
    confidence_margin: start_margin,
    prev_timestamp_ms: 0,
    prev_raw_speed: 0.0,
    slip_ratio_limit: slip_limit,
  }
}

///|
pub fn OdometerTracker::update(
  self : OdometerTracker,
  raw_wheel_speed : Double,
  doppler_radar_speed : Double?,
  now_ms : Int64
) -> @types.OdometerBounds {
  if self.prev_timestamp_ms == 0 {
    self.prev_timestamp_ms = now_ms
    self.prev_raw_speed = raw_wheel_speed
    return @types.OdometerBounds::new(
      self.accumulated_pos,
      self.confidence_margin,
      false,
      false
    )
  }

  let dt = (now_ms - self.prev_timestamp_ms).to_double() / 1000.0
  self.prev_timestamp_ms = now_ms

  let mut slip = false
  let mut skid = false
  let mut effective_v = raw_wheel_speed

  match doppler_radar_speed {
    Some(v_doppler) => {
      let diff = (raw_wheel_speed - v_doppler).abs()
      if v_doppler > 0.1 {
        let ratio = diff / v_doppler
        if ratio > self.slip_ratio_limit {
          if raw_wheel_speed > v_doppler {
            slip = true
          } else {
            skid = true
          }
          effective_v = v_doppler
        }
      }
    }
    None => ()
  }

  let ds = effective_v * dt
  self.accumulated_pos = self.accumulated_pos + ds
  // Uncertainty margin grows by 0.5% of distance traveled per step + base 0.01m
  self.confidence_margin = self.confidence_margin + ds * 0.005 + 0.001
  self.prev_raw_speed = effective_v

  @types.OdometerBounds::new(
    self.accumulated_pos,
    self.confidence_margin,
    slip,
    skid
  )
}

///|
pub fn OdometerTracker::reset_at_balise(
  self : OdometerTracker,
  balise_pos : Double,
  balise_accuracy : Double
) -> Unit {
  self.accumulated_pos = balise_pos
  self.confidence_margin = balise_accuracy
}
