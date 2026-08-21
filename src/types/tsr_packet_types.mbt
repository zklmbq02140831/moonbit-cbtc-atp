// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TsrPacket65Data models Subset-026 Packet 65 (Temporary Speed Restriction).
pub struct TsrPacket65Data {
  nid_packet : Int // 65
  nid_tsr : Int // TSR ID
  d_tsr_m : Double // Distance to TSR start (m)
  l_tsr_m : Double // Length of TSR (m)
  v_tsr_mps : Double // TSR speed limit (m/s)
  q_front : Bool // Front of train or whole train restriction
} derive(Eq, Debug)

///|
pub fn TsrPacket65Data::new(
  tsr_id : Int,
  dist_m : Double,
  len_m : Double,
  speed_mps : Double,
  front : Bool,
) -> TsrPacket65Data {
  {
    nid_packet: 65,
    nid_tsr: tsr_id,
    d_tsr_m: dist_m,
    l_tsr_m: len_m,
    v_tsr_mps: speed_mps,
    q_front: front,
  }
}

///|
/// TsrRevokePacket66Data models Subset-026 Packet 66 (Revoke TSR).
pub struct TsrRevokePacket66Data {
  nid_packet : Int // 66
  nid_tsr : Int // TSR ID to revoke
} derive(Eq, Debug)

///|
pub fn TsrRevokePacket66Data::new(tsr_id : Int) -> TsrRevokePacket66Data {
  { nid_packet: 66, nid_tsr: tsr_id }
}
