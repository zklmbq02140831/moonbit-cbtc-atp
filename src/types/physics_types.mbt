// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SpeedUnit conversions and operations.
pub struct Speed {
  mps : Double // meters per second
} derive(Eq, Debug)

///|
pub fn Speed::from_mps(mps : Double) -> Speed {
  { mps, }
}

///|
pub fn Speed::from_kmh(kmh : Double) -> Speed {
  { mps: kmh / 3.6 }
}

///|
pub fn Speed::to_mps(self : Speed) -> Double {
  self.mps
}

///|
pub fn Speed::to_kmh(self : Speed) -> Double {
  self.mps * 3.6
}

///|
/// DistanceUnit conversions and operations.
pub struct Distance {
  meters : Double
} derive(Eq, Debug)

///|
pub fn Distance::from_meters(m : Double) -> Distance {
  { meters: m }
}

///|
pub fn Distance::from_km(km : Double) -> Distance {
  { meters: km * 1000.0 }
}

///|
pub fn Distance::to_meters(self : Distance) -> Double {
  self.meters
}

///|
pub fn Distance::to_km(self : Distance) -> Double {
  self.meters / 1000.0
}

///|
/// AccelerationUnit conversions.
pub struct Acceleration {
  mps2 : Double // m/s^2
} derive(Eq, Debug)

///|
pub fn Acceleration::from_mps2(mps2 : Double) -> Acceleration {
  { mps2, }
}

///|
pub fn Acceleration::to_mps2(self : Acceleration) -> Double {
  self.mps2
}

///|
/// ForceUnit conversions.
pub struct Force {
  kn : Double // kilo-Newtons
} derive(Eq, Debug)

///|
pub fn Force::from_kn(kn : Double) -> Force {
  { kn, }
}

///|
pub fn Force::from_newtons(n : Double) -> Force {
  { kn: n / 1000.0 }
}

///|
pub fn Force::to_kn(self : Force) -> Double {
  self.kn
}

///|
pub fn Force::to_newtons(self : Force) -> Double {
  self.kn * 1000.0
}

///|
/// MassUnit conversions.
pub struct Mass {
  tonnes : Double
} derive(Eq, Debug)

///|
pub fn Mass::from_tonnes(t : Double) -> Mass {
  { tonnes: t }
}

///|
pub fn Mass::from_kg(kg : Double) -> Mass {
  { tonnes: kg / 1000.0 }
}

///|
pub fn Mass::to_tonnes(self : Mass) -> Double {
  self.tonnes
}

///|
pub fn Mass::to_kg(self : Mass) -> Double {
  self.tonnes * 1000.0
}

///|
/// TrackVector2D for spatial track coordinates.
pub struct TrackVector2D {
  x : Double
  y : Double
} derive(Eq, Debug)

///|
pub fn TrackVector2D::new(x : Double, y : Double) -> TrackVector2D {
  { x, y }
}

///|
pub fn TrackVector2D::distance_to(
  self : TrackVector2D,
  other : TrackVector2D,
) -> Double {
  let dx = self.x - other.x
  let dy = self.y - other.y
  (dx * dx + dy * dy).sqrt()
}
