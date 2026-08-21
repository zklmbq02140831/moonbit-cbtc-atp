// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// Packet3NationalValuesProcessor applies Subset-026 Packet 3 parameters to system configuration.
pub struct Packet3NationalValuesProcessor {
  mut current_national_values : @types.EtcsPacket3NationalValues
} derive(Eq, Debug)

///|
pub fn Packet3NationalValuesProcessor::new() -> Packet3NationalValuesProcessor {
  { current_national_values: @types.EtcsPacket3NationalValues::default() }
}

///|
pub fn Packet3NationalValuesProcessor::update(
  self : Packet3NationalValuesProcessor,
  nv : @types.EtcsPacket3NationalValues,
) -> Unit {
  self.current_national_values = nv
}

///|
pub fn Packet3NationalValuesProcessor::get_active_nv(
  self : Packet3NationalValuesProcessor,
) -> @types.EtcsPacket3NationalValues {
  self.current_national_values
}
