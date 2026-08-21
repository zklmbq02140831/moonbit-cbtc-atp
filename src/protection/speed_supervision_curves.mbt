// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EtcsSupervisionProfile represents all 6 supervision speed boundaries defined by ETCS / CBTC standards.
pub struct EtcsSupervisionProfile {
  position_m : Double
  v_perm_mps : Double // Permitted speed
  v_ind_mps : Double // Indication speed (DMI warning prompt)
  v_warn_mps : Double // Warning speed (Audible alarm)
  v_sbi_mps : Double // Service Brake Intervention speed
  v_ebi_mps : Double // Emergency Brake Intervention speed
  v_trip_mps : Double // Absolute hardware trip speed
} derive(Eq, Debug)

///|
pub fn EtcsSupervisionProfile::new(
  pos : Double,
  v_perm : Double,
  v_ind : Double,
  v_warn : Double,
  v_sbi : Double,
  v_ebi : Double,
  v_trip : Double,
) -> EtcsSupervisionProfile {
  {
    position_m: pos,
    v_perm_mps: v_perm,
    v_ind_mps: v_ind,
    v_warn_mps: v_warn,
    v_sbi_mps: v_sbi,
    v_ebi_mps: v_ebi,
    v_trip_mps: v_trip,
  }
}

///|
/// EtcsSupervisionCalculator derives all 6 ETCS speed supervision boundaries at current train position s.
pub struct EtcsSupervisionCalculator {
  config : @types.SystemConfig
} derive(Eq, Debug)

///|
pub fn EtcsSupervisionCalculator::new(
  config : @types.SystemConfig,
) -> EtcsSupervisionCalculator {
  { config, }
}

///|
pub fn EtcsSupervisionCalculator::calculate_profile(
  self : EtcsSupervisionCalculator,
  pos_m : Double,
  base_permitted_mps : Double,
) -> EtcsSupervisionProfile {
  let dv_warn = self.config.overspeed_warn_margin
  let dv_sbd = self.config.service_brake_margin
  let dv_ebd = self.config.emergency_brake_margin
  let dv_trip = self.config.trip_margin

  let v_ind = base_permitted_mps
  let v_warn = base_permitted_mps + dv_warn
  let v_sbi = base_permitted_mps + dv_sbd
  let v_ebi = base_permitted_mps + dv_ebd
  let v_trip = base_permitted_mps + dv_trip

  EtcsSupervisionProfile::new(
    pos_m, base_permitted_mps, v_ind, v_warn, v_sbi, v_ebi, v_trip,
  )
}
