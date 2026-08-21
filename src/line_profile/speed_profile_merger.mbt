// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SpeedProfileMerger merges Static Speed Profile (SSP), TSRs, and Axle Load Speed Limits.
pub struct SpeedProfileMerger {
  ssp : StaticSpeedProfile
  tsr_mgr : TsrManager
} derive(Eq, Debug)

///|
pub fn SpeedProfileMerger::new(
  ssp : StaticSpeedProfile,
  tsrs : TsrManager,
) -> SpeedProfileMerger {
  { ssp, tsr_mgr: tsrs }
}

///|
pub fn SpeedProfileMerger::get_composite_limit_at(
  self : SpeedProfileMerger,
  position_m : Double,
  axle_load_tonnes : Double,
) -> Double {
  let ssp_v = self.ssp.get_effective_limit(position_m)
  let tsr_v = self.tsr_mgr.get_tsr_limit_at(position_m)

  // Axle load penalty: > 23t reduces max speed to 120 km/h (33.33 m/s)
  let axle_v = if axle_load_tonnes > 23.0 { 33.33 } else { 1000.0 }

  let mut min_v = ssp_v
  if tsr_v < min_v {
    min_v = tsr_v
  }
  if axle_v < min_v {
    min_v = axle_v
  }
  min_v
}
