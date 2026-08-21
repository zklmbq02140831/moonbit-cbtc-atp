// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// BaliseRfidAntenna evaluates RF signal strength (RSSI) and filters adjacent track cross-talk.
pub struct BaliseRfidAntenna {
  min_rssi_dbm : Double
} derive(Eq, Debug)

///|
pub fn BaliseRfidAntenna::new() -> BaliseRfidAntenna {
  { min_rssi_dbm: -75.0 }
}

///|
pub fn BaliseRfidAntenna::is_signal_valid(
  self : BaliseRfidAntenna,
  rssi_dbm : Double,
) -> Bool {
  rssi_dbm >= self.min_rssi_dbm
}
