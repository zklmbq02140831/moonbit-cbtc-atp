// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EtcsPacket15Data represents Subset-026 Packet 15 (Level 2/3 Movement Authority).
pub struct EtcsPacket15Data {
  nid_packet : Int // 15
  q_dir : Int
  l_packet : Int
  q_scale : Int
  v_ema_mps : Double // End of Movement Authority speed
  t_ema_s : Int // Time limit of EMA
  d_ref_m : Double // Reference position
} derive(Eq, Debug)

///|
pub fn EtcsPacket15Data::new(
  q_dir : Int,
  v_ema : Double,
  t_ema : Int,
  d_ref : Double,
) -> EtcsPacket15Data {
  {
    nid_packet: 15,
    q_dir,
    l_packet: 32,
    q_scale: 1,
    v_ema_mps: v_ema,
    t_ema_s: t_ema,
    d_ref_m: d_ref,
  }
}
