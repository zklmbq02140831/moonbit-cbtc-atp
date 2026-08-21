// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EtcsPacket44CustomData models Subset-026 Packet 44 (Data Transmission for national system).
pub struct EtcsPacket44CustomData {
  nid_packet : Int // 44
  nid_xuser : Int
  payload_bytes : Array[Int]
} derive(Eq, Debug)

///|
pub fn EtcsPacket44CustomData::new(
  user_id : Int,
  bytes : Array[Int],
) -> EtcsPacket44CustomData {
  { nid_packet: 44, nid_xuser: user_id, payload_bytes: bytes }
}
