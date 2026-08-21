// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EurobalisePacket65Decoder parses Packet 65 (TSR Data) and Packet 66 (Revoke TSR).
pub struct EurobalisePacket65Decoder {
  version : Int
} derive(Eq, Debug)

///|
pub fn EurobalisePacket65Decoder::new() -> EurobalisePacket65Decoder {
  { version: 2 }
}

///|
pub fn EurobalisePacket65Decoder::decode_packet_65(
  self : EurobalisePacket65Decoder,
  bytes : Array[Int],
) -> @types.TsrPacket65Data? {
  let _ = self.version
  if bytes.length() < 10 {
    return None
  }
  let nid_packet = bytes[0]
  if nid_packet != 65 {
    return None
  }
  let tsr_id = bytes[2] * 256 + bytes[3]
  let dist_m = (bytes[4] * 256 + bytes[5]).to_double()
  let len_m = (bytes[6] * 256 + bytes[7]).to_double()
  let speed_mps = bytes[8].to_double() / 3.6
  let q_front = bytes[9] == 1

  Some(@types.TsrPacket65Data::new(tsr_id, dist_m, len_m, speed_mps, q_front))
}

///|
pub fn EurobalisePacket65Decoder::decode_packet_66(
  self : EurobalisePacket65Decoder,
  bytes : Array[Int],
) -> @types.TsrRevokePacket66Data? {
  let _ = self.version
  if bytes.length() < 4 {
    return None
  }
  let nid_packet = bytes[0]
  if nid_packet != 66 {
    return None
  }
  let tsr_id = bytes[2] * 256 + bytes[3]
  Some(@types.TsrRevokePacket66Data::new(tsr_id))
}
