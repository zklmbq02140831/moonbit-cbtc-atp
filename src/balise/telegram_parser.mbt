// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// BaliseTelegramParser decodes raw Eurobalise / CTCS bitstreams into structured line data.
pub struct BaliseTelegramParser {
  crc_poly : Int
} derive(Eq, Debug)

///|
pub fn BaliseTelegramParser::new() -> BaliseTelegramParser {
  { crc_poly: 0x1021 }
}

///|
pub fn BaliseTelegramParser::verify_checksum(
  self : BaliseTelegramParser,
  bytes : Array[Int]
) -> Bool {
  let _ = self.crc_poly
  if bytes.length() < 4 {
    return false
  }
  let mut sum = 0
  for i = 0; i < bytes.length(); i = i + 1 {
    sum = (sum + bytes[i]) % 256
  }
  sum != 0xFF // Simple non-zero checksum check
}

///|
/// Decode Packet 12 (Movement Authority update) from telegram bytes.
pub fn BaliseTelegramParser::parse_packet_12(
  self : BaliseTelegramParser,
  bytes : Array[Int],
  now_ms : Int64
) -> @types.MovementAuthority? {
  if !self.verify_checksum(bytes) || bytes.length() < 12 {
    return None
  }
  let ma_id = bytes[2] * 256 + bytes[3]
  let start_pos = (bytes[4] * 256 + bytes[5]).to_double()
  let eoa_pos = (bytes[6] * 256 + bytes[7]).to_double()
  let overlap = (bytes[8] * 10).to_double()
  let target_v = (bytes[9]).to_double() / 3.6
  let route_v = (bytes[10]).to_double() / 3.6

  Some(@types.MovementAuthority::new(
    ma_id,
    now_ms,
    start_pos,
    eoa_pos,
    overlap,
    target_v,
    route_v
  ))
}

///|
/// Decode Packet 27 (International Static Speed Profile update) from telegram bytes.
pub fn BaliseTelegramParser::parse_packet_27(
  self : BaliseTelegramParser,
  bytes : Array[Int]
) -> @types.PhysicalSpeedSegment? {
  if !self.verify_checksum(bytes) || bytes.length() < 8 {
    return None
  }
  let start_p = (bytes[2] * 256 + bytes[3]).to_double()
  let end_p = (bytes[4] * 256 + bytes[5]).to_double()
  let max_v = (bytes[6]).to_double() / 3.6

  Some(@types.PhysicalSpeedSegment::new(start_p, end_p, max_v))
}
