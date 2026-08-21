// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SpeedMarginComparator applies hysteresis band to prevent warning & brake chatter oscillations.
pub struct SpeedMarginComparator {
  hysteresis_band_mps : Double // e.g. 0.5 m/s
  mut last_evaluated_event_code : Int
} derive(Eq, Debug)

///|
pub fn SpeedMarginComparator::new(
  hysteresis_mps : Double,
) -> SpeedMarginComparator {
  { hysteresis_band_mps: hysteresis_mps, last_evaluated_event_code: 201 }
}

///|
pub fn SpeedMarginComparator::update_last_event(
  self : SpeedMarginComparator,
  code : Int,
) -> Unit {
  self.last_evaluated_event_code = code
}

///|
pub fn SpeedMarginComparator::compare_with_hysteresis(
  self : SpeedMarginComparator,
  current_v_mps : Double,
  limit_v_mps : Double,
) -> Bool {
  if self.last_evaluated_event_code == 202 {
    current_v_mps >= limit_v_mps - self.hysteresis_band_mps
  } else {
    current_v_mps >= limit_v_mps
  }
}
