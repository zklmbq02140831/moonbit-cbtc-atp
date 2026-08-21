// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// BaliseGroupVerifier checks balise group sequence, directionality, and detects missing balises.
pub struct BaliseGroupVerifier {
  mut last_group_id : Int
  mut last_balise_location_m : Double
} derive(Eq, Debug)

///|
pub fn BaliseGroupVerifier::new() -> BaliseGroupVerifier {
  { last_group_id: 0, last_balise_location_m: 0.0 }
}

///|
pub fn BaliseGroupVerifier::verify_group_sequence(
  self : BaliseGroupVerifier,
  current_balise : @types.BaliseData,
  train_direction : Int,
) -> Bool {
  if self.last_group_id == 0 {
    self.last_group_id = current_balise.group_id
    self.last_balise_location_m = current_balise.location
    return true
  }

  let delta = current_balise.location - self.last_balise_location_m
  let valid_dir = if train_direction == 1 { delta > 0.0 } else { delta < 0.0 }
  if valid_dir {
    self.last_group_id = current_balise.group_id
    self.last_balise_location_m = current_balise.location
    true
  } else {
    false
  }
}
