// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EurobalisePacket44Decoder unpacks custom data transmission packets from Eurobalises.
pub struct EurobalisePacket44Decoder {
  nid_xuser : Int
} derive(Eq, Debug)

///|
pub fn EurobalisePacket44Decoder::new() -> EurobalisePacket44Decoder {
  { nid_xuser: 100 }
}

///|
pub fn EurobalisePacket44Decoder::parse_packet_44(
  self : EurobalisePacket44Decoder,
  bytes : Array[Int],
) -> Array[Int]? {
  let _ = self.nid_xuser
  if bytes.length() < 6 {
    return None
  }
  let nid_packet = bytes[0]
  if nid_packet != 44 {
    return None
  }
  let payload : Array[Int] = Array::new()
  for i = 2; i < bytes.length(); i = i + 1 {
    payload.push(bytes[i])
  }
  Some(payload)
}
