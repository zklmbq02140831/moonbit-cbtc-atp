// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TrackCircuitCodeMap resolves maximum speed limit from legacy TVM / CTCS-2 track circuit modulation frequencies.
pub struct TrackCircuitCodeMap {
  code_table : Array[@types.TrackCircuitCodeRate]
} derive(Eq, Debug)

///|
pub fn TrackCircuitCodeMap::new(
  table : Array[@types.TrackCircuitCodeRate],
) -> TrackCircuitCodeMap {
  { code_table: table }
}

///|
pub fn TrackCircuitCodeMap::resolve_speed_limit_mps(
  self : TrackCircuitCodeMap,
  code_rate_hz : Double,
) -> Double {
  for i = 0; i < self.code_table.length(); i = i + 1 {
    let entry = self.code_table[i]
    if (entry.code_rate_hz - code_rate_hz).abs() <= 0.5 {
      return entry.speed_limit_mps
    }
  }
  0.0 // Fail-safe default: stop if code rate unknown
}
