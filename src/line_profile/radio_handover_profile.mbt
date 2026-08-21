// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// RadioHandoverProfileZone defines RBC boundary handover zones along line corridor.
pub struct RadioHandoverProfileZone {
  zone_id : Int
  start_pos_m : Double
  end_pos_m : Double
  current_rbc_id : Int
  target_rbc_id : Int
} derive(Eq, Debug)

///|
pub fn RadioHandoverProfileZone::new(
  z_id : Int,
  start_m : Double,
  end_m : Double,
  rbc_curr : Int,
  rbc_targ : Int,
) -> RadioHandoverProfileZone {
  {
    zone_id: z_id,
    start_pos_m: start_m,
    end_pos_m: end_m,
    current_rbc_id: rbc_curr,
    target_rbc_id: rbc_targ,
  }
}

///|
pub fn RadioHandoverProfileZone::in_handover_zone(
  self : RadioHandoverProfileZone,
  pos_m : Double,
) -> Bool {
  pos_m >= self.start_pos_m && pos_m <= self.end_pos_m
}
