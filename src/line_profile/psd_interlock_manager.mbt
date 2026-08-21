// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// PsdInterlockManager enforces zero speed permissive interlock when PSD doors are open.
pub struct PsdInterlockManager {
  platform : @types.StationPlatformLocation
  psd_data : @types.PsdInterlockData
} derive(Eq, Debug)

///|
pub fn PsdInterlockManager::new(
  plat : @types.StationPlatformLocation,
  psd : @types.PsdInterlockData,
) -> PsdInterlockManager {
  { platform: plat, psd_data: psd }
}

///|
pub fn PsdInterlockManager::evaluate_permissive_speed(
  self : PsdInterlockManager,
  train_pos_m : Double,
  train_length_m : Double,
) -> Double {
  if self.platform.is_aligned(train_pos_m, train_length_m) {
    if self.psd_data.all_doors_closed_and_locked {
      1000.0 // Normal proceed
    } else {
      0.0 // Interlock trip if doors open or emergency stop pressed
    }
  } else {
    1000.0
  }
}
