// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TrackCircuitCarrierFrequency defines jointless track circuit carrier frequencies (e.g. ZPW-2000A).
pub enum TrackCircuitCarrier {
  Freq1700Hz
  Freq2000Hz
  Freq2300Hz
  Freq2600Hz
  FreqUnknown
} derive(Eq, Debug)

///|
pub fn TrackCircuitCarrier::from_int(code : Int) -> TrackCircuitCarrier {
  match code {
    1700 => Freq1700Hz
    2000 => Freq2000Hz
    2300 => Freq2300Hz
    2600 => Freq2600Hz
    _ => FreqUnknown
  }
}

///|
/// TrackCircuitCodeRate maps low-frequency modulation code rates to target speed aspects.
pub struct TrackCircuitCodeRate {
  code_rate_hz : Double // Modulation frequency in Hz (e.g. 10.3Hz, 14.7Hz, 25.7Hz, 29.0Hz)
  speed_limit_mps : Double // Allowed speed limit for this code rate
  signal_aspect_name : String
} derive(Eq, Debug)

///|
pub fn TrackCircuitCodeRate::new(
  code_hz : Double,
  speed_mps : Double,
  aspect : String,
) -> TrackCircuitCodeRate {
  {
    code_rate_hz: code_hz,
    speed_limit_mps: speed_mps,
    signal_aspect_name: aspect,
  }
}

///|
pub fn TrackCircuitCodeRate::default_tvm430_table() -> Array[
  TrackCircuitCodeRate,
] {
  [
    TrackCircuitCodeRate::new(29.0, 97.22, "Green350"),
    TrackCircuitCodeRate::new(25.7, 83.33, "Green300"),
    TrackCircuitCodeRate::new(22.3, 69.44, "Green250"),
    TrackCircuitCodeRate::new(19.1, 55.56, "Green200"),
    TrackCircuitCodeRate::new(15.9, 44.44, "Yellow160"),
    TrackCircuitCodeRate::new(14.7, 33.33, "Yellow120"),
    TrackCircuitCodeRate::new(13.6, 22.22, "Yellow80"),
    TrackCircuitCodeRate::new(11.4, 12.50, "Yellow40"),
    TrackCircuitCodeRate::new(10.3, 0.00, "RedStop"),
  ]
}
