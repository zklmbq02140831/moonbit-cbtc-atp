// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EmergencyTripManager manages SIL4 hardware trip solenoid relays and reset interlocks.
pub struct EmergencyTripManager {
  mut trip_relay_cut_off : Bool
  mut manual_ack_received : Bool
} derive(Eq, Debug)

///|
pub fn EmergencyTripManager::new() -> EmergencyTripManager {
  { trip_relay_cut_off: false, manual_ack_received: false }
}

///|
pub fn EmergencyTripManager::is_tripped(self : EmergencyTripManager) -> Bool {
  self.trip_relay_cut_off
}

///|
pub fn EmergencyTripManager::trigger_trip(self : EmergencyTripManager) -> Unit {
  self.trip_relay_cut_off = true
  self.manual_ack_received = false
}

///|
pub fn EmergencyTripManager::register_driver_ack(
  self : EmergencyTripManager,
) -> Unit {
  self.manual_ack_received = true
}

///|
pub fn EmergencyTripManager::attempt_reset(
  self : EmergencyTripManager,
  train_speed_mps : Double,
) -> Bool {
  if self.trip_relay_cut_off &&
    self.manual_ack_received &&
    train_speed_mps <= 0.001 {
    self.trip_relay_cut_off = false
    self.manual_ack_received = false
    true
  } else {
    false
  }
}
