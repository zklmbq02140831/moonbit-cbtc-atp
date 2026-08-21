// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AxleCounterSectionManager manages axle counter track sections along the line corridor.
pub struct AxleCounterSectionManager {
  sections : Array[@types.AxleCounterSection]
} derive(Eq, Debug)

///|
pub fn AxleCounterSectionManager::new(
  sec_array : Array[@types.AxleCounterSection],
) -> AxleCounterSectionManager {
  { sections: sec_array }
}

///|
pub fn AxleCounterSectionManager::find_section_by_id(
  self : AxleCounterSectionManager,
  sec_id : Int,
) -> @types.AxleCounterSection? {
  for i = 0; i < self.sections.length(); i = i + 1 {
    if self.sections[i].section_id == sec_id {
      return Some(self.sections[i])
    }
  }
  None
}

///|
pub fn AxleCounterSectionManager::is_all_clear(
  self : AxleCounterSectionManager,
) -> Bool {
  for i = 0; i < self.sections.length(); i = i + 1 {
    if !self.sections[i].is_clear() {
      return false
    }
  }
  true
}
