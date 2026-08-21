// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SystemFailureFsm manages SIL4 hardware / software fault latching state.
pub struct SystemFailureFsm {
  mut fault_latched : Bool
  mut failure_code : Int
} derive(Eq, Debug)

///|
pub fn SystemFailureFsm::new() -> SystemFailureFsm {
  { fault_latched: false, failure_code: 0 }
}

///|
pub fn SystemFailureFsm::trigger_fault(
  self : SystemFailureFsm,
  code : Int,
) -> Unit {
  self.fault_latched = true
  self.failure_code = code
}

///|
pub fn SystemFailureFsm::is_fault_active(self : SystemFailureFsm) -> Bool {
  self.fault_latched
}
