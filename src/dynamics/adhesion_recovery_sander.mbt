// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AdhesionRecoverySander models automated sanding valve activation under low adhesion conditions.
pub struct AdhesionRecoverySander {
  mut sanding_active : Bool
  sand_adhesion_boost : Double // e.g. +0.05 friction coefficient boost
} derive(Eq, Debug)

///|
pub fn AdhesionRecoverySander::new() -> AdhesionRecoverySander {
  { sanding_active: false, sand_adhesion_boost: 0.05 }
}

///|
pub fn AdhesionRecoverySander::evaluate_sanding(
  self : AdhesionRecoverySander,
  current_adhesion : Double,
  min_required_adhesion : Double,
) -> Double {
  if current_adhesion < min_required_adhesion {
    self.sanding_active = true
    current_adhesion + self.sand_adhesion_boost
  } else {
    self.sanding_active = false
    current_adhesion
  }
}
