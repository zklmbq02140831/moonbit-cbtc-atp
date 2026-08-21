// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// Packet27SspBuilder converts Packet 27 sub-segments into StaticSpeedProfile physical segments.
pub struct Packet27SspBuilder {
  ssp_base : StaticSpeedProfile
} derive(Eq, Debug)

///|
pub fn Packet27SspBuilder::new(base : StaticSpeedProfile) -> Packet27SspBuilder {
  { ssp_base: base }
}

///|
pub fn Packet27SspBuilder::apply_packet_27(
  self : Packet27SspBuilder,
  pkt27 : @types.EtcsPacket27Data,
  current_train_pos_m : Double,
) -> Array[@types.PhysicalSpeedSegment] {
  let _ = self.ssp_base
  let segs : Array[@types.PhysicalSpeedSegment] = Array::new()
  for i = 0; i < pkt27.sub_segments.length(); i = i + 1 {
    let sub = pkt27.sub_segments[i]
    let start_p = current_train_pos_m + sub.d_static_m
    let end_p = if i + 1 < pkt27.sub_segments.length() {
      current_train_pos_m + pkt27.sub_segments[i + 1].d_static_m
    } else {
      start_p + 10000.0
    }
    segs.push(
      @types.PhysicalSpeedSegment::new(start_p, end_p, sub.v_static_mps),
    )
  }
  segs
}
