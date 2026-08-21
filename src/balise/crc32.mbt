// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EurobaliseCrc32 calculates Eurobalise checksum for telegram bitstream integrity.
pub struct EurobaliseCrc32 {
  polynomial : Int
} derive(Eq, Debug)

///|
pub fn EurobaliseCrc32::new() -> EurobaliseCrc32 {
  { polynomial: 0x04C11DB7 }
}

///|
pub fn EurobaliseCrc32::compute(
  self : EurobaliseCrc32,
  bytes : Array[Int],
) -> Int {
  let _ = self.polynomial
  let mut crc = 0xFFFFFFFF
  for i = 0; i < bytes.length(); i = i + 1 {
    let byte_val = bytes[i]
    crc = crc ^ byte_val
    for _j = 0; _j < 8; _j = _j + 1 {
      let mask = if (crc & 1) != 0 { 0x04C11DB7 } else { 0 }
      crc = (crc >> 1) ^ mask
    }
  }
  crc
}
