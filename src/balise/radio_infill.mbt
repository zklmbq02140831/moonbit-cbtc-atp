// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// RadioInfillWatchdog monitors wireless CBTC radio link heartbeat and updates MA infills.
pub struct RadioInfillWatchdog {
  mut last_radio_heartbeat_ms : Int64
  radio_timeout_limit_ms : Int64
} derive(Eq, Debug)

///|
pub fn RadioInfillWatchdog::new(timeout_ms : Int64) -> RadioInfillWatchdog {
  { last_radio_heartbeat_ms: 0, radio_timeout_limit_ms: timeout_ms }
}

///|
pub fn RadioInfillWatchdog::record_heartbeat(
  self : RadioInfillWatchdog,
  now_ms : Int64,
) -> Unit {
  self.last_radio_heartbeat_ms = now_ms
}

///|
pub fn RadioInfillWatchdog::is_radio_lost(
  self : RadioInfillWatchdog,
  now_ms : Int64,
) -> Bool {
  if self.last_radio_heartbeat_ms == 0 {
    false
  } else {
    now_ms - self.last_radio_heartbeat_ms > self.radio_timeout_limit_ms
  }
}

///|
pub fn RadioInfillWatchdog::process_infill_ma(
  self : RadioInfillWatchdog,
  infill_ma : @types.MovementAuthority,
  ma_resolver : @line_profile.MaResolver,
  now_ms : Int64,
) -> Bool {
  self.record_heartbeat(now_ms)
  ma_resolver.update_ma(infill_ma, now_ms)
  true
}
