// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EtcsPacket41Data models Subset-026 Packet 41 (Level Transition Order).
pub struct EtcsPacket41Data {
  nid_packet : Int // 41
  target_etcs_level : Int // Level 0, 1, 2, 3
  d_leveltr_m : Double // Distance to level transition (m)
  l_ack_m : Double // Driver acknowledgment distance
} derive(Eq, Debug)

///|
pub fn EtcsPacket41Data::new(
  level : Int,
  dist_m : Double,
  ack_m : Double,
) -> EtcsPacket41Data {
  {
    nid_packet: 41,
    target_etcs_level: level,
    d_leveltr_m: dist_m,
    l_ack_m: ack_m,
  }
}
