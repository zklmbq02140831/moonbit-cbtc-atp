// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TemporarySpeedProfileBuilder constructs multi-zone TSR and ESR envelopes.
pub struct TemporarySpeedProfileBuilder {
  tsr_mgr : TsrManager
} derive(Eq, Debug)

///|
pub fn TemporarySpeedProfileBuilder::new(
  tsrs : TsrManager,
) -> TemporarySpeedProfileBuilder {
  { tsr_mgr: tsrs }
}

///|
pub fn TemporarySpeedProfileBuilder::evaluate_envelope(
  self : TemporarySpeedProfileBuilder,
  start_pos_m : Double,
  end_pos_m : Double,
) -> Array[@types.TemporarySpeedRestriction] {
  self.tsr_mgr.get_all_active_in_range(start_pos_m, end_pos_m)
}
