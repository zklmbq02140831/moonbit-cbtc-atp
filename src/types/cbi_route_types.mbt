// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SignalAspect defines trackside wayside optical signal lamp aspect.
pub enum SignalAspect {
  RedStop // Danger / Stop aspect
  YellowApproach // Proceed with caution / Prepare to stop
  DoubleYellow // Approach next signal at restricted speed
  GreenProceed // Proceed at maximum permitted line speed
  FlashingYellow // Diverging route ahead
} derive(Eq, Debug)

///|
pub fn SignalAspect::from_code(code : Int) -> SignalAspect {
  match code {
    1 => RedStop
    2 => YellowApproach
    3 => DoubleYellow
    4 => GreenProceed
    _ => FlashingYellow
  }
}

///|
/// CbiRouteStatus models interlocking route alignment, locking, and signal aspect.
pub struct CbiRouteStatus {
  route_id : Int
  entry_signal_id : Int
  exit_signal_id : Int
  aspect : SignalAspect
  route_locked : Bool
  detector_locking_active : Bool
} derive(Eq, Debug)

///|
pub fn CbiRouteStatus::new(
  r_id : Int,
  entry_sig : Int,
  exit_sig : Int,
  asp : SignalAspect,
  locked : Bool,
  detector : Bool,
) -> CbiRouteStatus {
  {
    route_id: r_id,
    entry_signal_id: entry_sig,
    exit_signal_id: exit_sig,
    aspect: asp,
    route_locked: locked,
    detector_locking_active: detector,
  }
}
