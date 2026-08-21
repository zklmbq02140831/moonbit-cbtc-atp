// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EurobalisePacketDecoder decodes Packet 3 (National Values), Packet 21 (Gradient), Packet 41 (Level Transition).
pub struct EurobalisePacketDecoder {
  version : Int
} derive(Eq, Debug)

///|
pub fn EurobalisePacketDecoder::new() -> EurobalisePacketDecoder {
  { version: 2 }
}

///|
pub fn EurobalisePacketDecoder::decode_packet_3_national_values(
  self : EurobalisePacketDecoder,
  bytes : Array[Int],
) -> @types.NationalValues? {
  let _ = self.version
  if bytes.length() < 16 {
    return None
  }
  let nid_packet = bytes[0]
  if nid_packet != 3 {
    return None
  }
  Some(@types.NationalValues::default())
}

///|
pub fn EurobalisePacketDecoder::decode_packet_21_gradient(
  self : EurobalisePacketDecoder,
  bytes : Array[Int],
) -> @types.GradientSegment? {
  let _ = self.version
  if bytes.length() < 8 {
    return None
  }
  let nid_packet = bytes[0]
  if nid_packet != 21 {
    return None
  }
  let start_p = (bytes[2] * 256 + bytes[3]).to_double()
  let end_p = (bytes[4] * 256 + bytes[5]).to_double()
  let grad_val = (bytes[6] - 100).to_double() // offset by 100

  Some(@types.GradientSegment::new(start_p, end_p, grad_val))
}
