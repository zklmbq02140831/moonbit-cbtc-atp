// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TurnoutJunctionTopology models turnout facing/trailing point alignment and route locking.
pub struct TurnoutJunctionTopology {
  junction_id : Int
  switch_a : @types.TrackSwitch
  switch_b : @types.TrackSwitch?
  interlocked_route_id : Int
  is_facing_point : Bool
  route_locked : Bool
} derive(Eq, Debug)

///|
pub fn TurnoutJunctionTopology::new(
  j_id : Int,
  sw_a : @types.TrackSwitch,
  sw_b : @types.TrackSwitch?,
  route_id : Int,
  facing : Bool,
  locked : Bool,
) -> TurnoutJunctionTopology {
  {
    junction_id: j_id,
    switch_a: sw_a,
    switch_b: sw_b,
    interlocked_route_id: route_id,
    is_facing_point: facing,
    route_locked: locked,
  }
}

///|
pub fn TurnoutJunctionTopology::max_junction_speed(
  self : TurnoutJunctionTopology,
) -> Double {
  if !self.route_locked {
    return 0.0 // Fail-safe 0 km/h if route not locked by CBI
  }
  let speed_a = self.switch_a.allowed_speed()
  match self.switch_b {
    Some(sw) => {
      let speed_b = sw.allowed_speed()
      if speed_a < speed_b {
        speed_a
      } else {
        speed_b
      }
    }
    None => speed_a
  }
}
