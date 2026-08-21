// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AtpHardwareDiagnosticReport contains CPU temperature, supply voltage, and SIL4 voting diagnostics.
pub struct AtpHardwareDiagnosticReport {
  cpu_temp_celsius : Double
  supply_voltage_v : Double
  channel_a_alive : Bool
  channel_b_alive : Bool
  voter_relay_healthy : Bool
} derive(Eq, Debug)

///|
pub fn AtpHardwareDiagnosticReport::healthy_default() -> AtpHardwareDiagnosticReport {
  {
    cpu_temp_celsius: 45.0,
    supply_voltage_v: 24.0,
    channel_a_alive: true,
    channel_b_alive: true,
    voter_relay_healthy: true,
  }
}

///|
pub fn AtpHardwareDiagnosticReport::is_safe_to_run(
  self : AtpHardwareDiagnosticReport,
) -> Bool {
  self.cpu_temp_celsius <= 85.0 &&
  self.supply_voltage_v >= 18.0 &&
  self.supply_voltage_v <= 32.0 &&
  self.channel_a_alive &&
  self.channel_b_alive &&
  self.voter_relay_healthy
}
