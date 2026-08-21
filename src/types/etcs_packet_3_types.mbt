// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EtcsPacket3NationalValues models Subset-026 Packet 3 (National Values configuration).
pub struct EtcsPacket3NationalValues {
  nid_packet : Int // 3
  v_nvshunt_mps : Double // Max speed in Shunting mode (m/s)
  v_nvstff_mps : Double // Max speed in Staff Responsible mode (m/s)
  v_nvonsight_mps : Double // Max speed in On Sight mode (m/s)
  v_nvlimsuper_mps : Double // Max speed in Limited Supervision mode (m/s)
  v_nvunfit_mps : Double // Max speed in Unfitted mode (m/s)
  v_nvrel_mps : Double // Release speed near EOA (m/s)
  d_nvroll_m : Double // Rollaway distance limit (m)
  t_nvovtrp_s : Int // Overlap release timer (s)
} derive(Eq, Debug)

///|
pub fn EtcsPacket3NationalValues::default() -> EtcsPacket3NationalValues {
  {
    nid_packet: 3,
    v_nvshunt_mps: 8.33,
    v_nvstff_mps: 12.50,
    v_nvonsight_mps: 8.33,
    v_nvlimsuper_mps: 27.78,
    v_nvunfit_mps: 27.78,
    v_nvrel_mps: 4.17,
    d_nvroll_m: 2.0,
    t_nvovtrp_s: 60,
  }
}
