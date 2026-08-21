// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EurobalisePacket41Decoder parses Packet 41 (ETCS Level Transition Order).
pub struct EurobalisePacket41Decoder {
  version : Int
} derive(Eq, Debug)

///|
pub fn EurobalisePacket41Decoder::new() -> EurobalisePacket41Decoder {
  { version: 2 }
}

///|
pub fn EurobalisePacket41Decoder::decode_packet_41(
  self : EurobalisePacket41Decoder,
  bytes : Array[Int],
) -> @types.EtcsPacket41Data? {
  let _ = self.version
  if bytes.length() < 8 {
    return None
  }
  let nid_packet = bytes[0]
  if nid_packet != 41 {
    return None
  }
  let target_level = bytes[2]
  let dist_m = (bytes[3] * 256 + bytes[4]).to_double()
  let ack_m = (bytes[5] * 256 + bytes[6]).to_double()

  Some(@types.EtcsPacket41Data::new(target_level, dist_m, ack_m))
}
