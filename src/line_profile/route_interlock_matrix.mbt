// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// InterlockingRouteEntry defines route locking parameters between origin signal and destination signal.
pub struct InterlockingRouteEntry {
  route_id : Int
  origin_signal_id : Int
  destination_signal_id : Int
  route_length_m : Double
  is_route_locked : Bool
  flank_protection_active : Bool
} derive(Eq, Debug)

///|
pub fn InterlockingRouteEntry::new(
  r_id : Int,
  sig_orig : Int,
  sig_dest : Int,
  len_m : Double,
  locked : Bool,
  flank : Bool,
) -> InterlockingRouteEntry {
  {
    route_id: r_id,
    origin_signal_id: sig_orig,
    destination_signal_id: sig_dest,
    route_length_m: len_m,
    is_route_locked: locked,
    flank_protection_active: flank,
  }
}

///|
pub fn InterlockingRouteEntry::is_valid_for_train(
  self : InterlockingRouteEntry,
) -> Bool {
  self.is_route_locked && self.flank_protection_active
}
