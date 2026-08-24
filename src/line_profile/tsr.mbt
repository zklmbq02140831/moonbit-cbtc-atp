// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TsrManager manages temporary speed restrictions received via radio/balise.
pub struct TsrManager {
  active_tsrs : Array[@types.TemporarySpeedRestriction]
} derive(Eq, Debug)

///|
pub fn TsrManager::new() -> TsrManager {
  { active_tsrs: Array::new() }
}

///|
pub fn TsrManager::add_tsr(
  self : TsrManager,
  tsr : @types.TemporarySpeedRestriction,
) -> Unit {
  // Replace existing TSR if ID matches, else push
  for i = 0; i < self.active_tsrs.length(); i = i + 1 {
    if self.active_tsrs[i].tsr_id == tsr.tsr_id {
      self.active_tsrs[i] = tsr
      return
    }
  }
  self.active_tsrs.push(tsr)
}

///|
pub fn TsrManager::remove_tsr(self : TsrManager, tsr_id : Int) -> Bool {
  let mut idx = -1
  for i = 0; i < self.active_tsrs.length(); i = i + 1 {
    if self.active_tsrs[i].tsr_id == tsr_id {
      idx = i
      break
    }
  }
  if idx >= 0 {
    let _ = self.active_tsrs.remove(idx)
    true
  } else {
    false
  }
}

///|
pub fn TsrManager::get_tsr_limit_at(
  self : TsrManager,
  position : Double,
) -> Double {
  let mut min_limit = 1000.0
  for i = 0; i < self.active_tsrs.length(); i = i + 1 {
    let t = self.active_tsrs[i]
    if t.active &&
      (
        t.start_position.is_nan() ||
        t.start_position.is_inf() ||
        t.end_position.is_nan() ||
        t.end_position.is_inf() ||
        t.speed_limit.is_nan() ||
        t.speed_limit.is_inf() ||
        t.start_position > t.end_position ||
        t.speed_limit < 0.0
      ) {
      return 0.0
    }
    if t.active && position >= t.start_position && position <= t.end_position {
      if t.speed_limit < min_limit {
        min_limit = t.speed_limit
      }
    }
  }
  min_limit
}

///|
pub fn TsrManager::get_all_active_in_range(
  self : TsrManager,
  start_pos : Double,
  end_pos : Double,
) -> Array[@types.TemporarySpeedRestriction] {
  let result = Array::new()
  for i = 0; i < self.active_tsrs.length(); i = i + 1 {
    let t = self.active_tsrs[i]
    if t.active && t.end_position >= start_pos && t.start_position <= end_pos {
      result.push(t)
    }
  }
  result
}
