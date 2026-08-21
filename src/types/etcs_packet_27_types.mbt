// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EtcsPacket27SubSegment describes a single speed section inside Packet 27.
pub struct EtcsPacket27SubSegment {
  d_static_m : Double
  v_static_mps : Double
  q_front : Bool
} derive(Eq, Debug)

///|
pub fn EtcsPacket27SubSegment::new(
  dist_m : Double,
  speed_mps : Double,
  front : Bool,
) -> EtcsPacket27SubSegment {
  { d_static_m: dist_m, v_static_mps: speed_mps, q_front: front }
}

///|
/// EtcsPacket27Data models Subset-026 Packet 27 (International Static Speed Profile).
pub struct EtcsPacket27Data {
  nid_packet : Int // 27
  sub_segments : Array[EtcsPacket27SubSegment]
} derive(Eq, Debug)

///|
pub fn EtcsPacket27Data::new(
  segs : Array[EtcsPacket27SubSegment],
) -> EtcsPacket27Data {
  { nid_packet: 27, sub_segments: segs }
}
