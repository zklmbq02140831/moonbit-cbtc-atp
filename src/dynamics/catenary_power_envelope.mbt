// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// CatenaryPowerEnvelope models AC 25kV / DC 1500V catenary voltage drop and traction power limits.
pub struct CatenaryPowerEnvelope {
  nominal_voltage_v : Double
  min_usable_voltage_v : Double
} derive(Eq, Debug)

///|
pub fn CatenaryPowerEnvelope::ac_25kv() -> CatenaryPowerEnvelope {
  { nominal_voltage_v: 25000.0, min_usable_voltage_v: 19000.0 }
}

///|
pub fn CatenaryPowerEnvelope::voltage_derating_factor(
  self : CatenaryPowerEnvelope,
  measured_voltage_v : Double,
) -> Double {
  if measured_voltage_v >= self.nominal_voltage_v {
    1.0
  } else if measured_voltage_v <= self.min_usable_voltage_v {
    0.0
  } else {
    (measured_voltage_v - self.min_usable_voltage_v) /
    (self.nominal_voltage_v - self.min_usable_voltage_v)
  }
}
