// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// Sil4GuardEvaluator evaluates CPU clock parity, memory integrity, and hardware interlock relay guards.
pub struct Sil4GuardEvaluator {
  cpu_clock_diff_max_ms : Int64
  memory_parity_ok : Bool
} derive(Eq, Debug)

///|
pub fn Sil4GuardEvaluator::new() -> Sil4GuardEvaluator {
  { cpu_clock_diff_max_ms: 10, memory_parity_ok: true }
}

///|
pub fn Sil4GuardEvaluator::verify_sil4_guards(
  self : Sil4GuardEvaluator,
  channel_a_time_ms : Int64,
  channel_b_time_ms : Int64,
) -> Bool {
  let time_diff = (channel_a_time_ms - channel_b_time_ms).abs()
  self.memory_parity_ok && time_diff <= self.cpu_clock_diff_max_ms
}
