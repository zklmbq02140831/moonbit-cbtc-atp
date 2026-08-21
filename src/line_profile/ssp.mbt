// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// StaticSpeedProfile (SSP) represents combined envelope of physical speed limits, gradient limits,
/// curvature speed limits, and switch speed limits along the line.
pub struct StaticSpeedProfile {
  segments : Array[@types.PhysicalSpeedSegment]
  gradients : Array[@types.GradientSegment]
  curvatures : Array[@types.CurvatureSegment]
  switches : Array[@types.TrackSwitch]
} derive(Eq, Debug)

///|
pub fn StaticSpeedProfile::new(
  segments : Array[@types.PhysicalSpeedSegment],
  gradients : Array[@types.GradientSegment],
  curvatures : Array[@types.CurvatureSegment],
  switches : Array[@types.TrackSwitch],
) -> StaticSpeedProfile {
  { segments, gradients, curvatures, switches }
}

///|
pub fn StaticSpeedProfile::get_physical_limit(
  self : StaticSpeedProfile,
  position : Double,
) -> Double {
  let mut limit = 1000.0 // high default ceiling
  for i = 0; i < self.segments.length(); i = i + 1 {
    let s = self.segments[i]
    if position >= s.start_pos && position <= s.end_pos {
      if s.max_speed < limit {
        limit = s.max_speed
      }
    }
  }
  limit
}

///|
pub fn StaticSpeedProfile::get_gradient(
  self : StaticSpeedProfile,
  position : Double,
) -> Double {
  for i = 0; i < self.gradients.length(); i = i + 1 {
    let g = self.gradients[i]
    if position >= g.start_pos && position <= g.end_pos {
      return g.value
    }
  }
  0.0
}

///|
pub fn StaticSpeedProfile::get_curvature_speed_limit(
  self : StaticSpeedProfile,
  position : Double,
  cant_mm : Double,
) -> Double {
  for i = 0; i < self.curvatures.length(); i = i + 1 {
    let c = self.curvatures[i]
    if position >= c.start_pos && position <= c.end_pos {
      if c.radius > 0.1 {
        // Standard railway formula for max speed on curve with cant: v_max = sqrt((R * (h + 100)) / 11.8) in km/h
        let effective_cant = if cant_mm > 0.0 { cant_mm } else { c.cant }
        let limit_kmh = (c.radius * (effective_cant + 110.0) / 11.8).sqrt()
        let limit_mps = limit_kmh / 3.6
        return limit_mps
      }
    }
  }
  1000.0
}

///|
pub fn StaticSpeedProfile::get_switch_limit(
  self : StaticSpeedProfile,
  position : Double,
) -> Double {
  let mut limit = 1000.0
  for i = 0; i < self.switches.length(); i = i + 1 {
    let sw = self.switches[i]
    // Switch influence zone +/- 50m
    if (position - sw.position_m).abs() <= 50.0 {
      let allowed = sw.allowed_speed()
      if allowed < limit {
        limit = allowed
      }
    }
  }
  limit
}

///|
pub fn StaticSpeedProfile::get_effective_limit(
  self : StaticSpeedProfile,
  position : Double,
) -> Double {
  let phys = self.get_physical_limit(position)
  let curv = self.get_curvature_speed_limit(position, 0.0)
  let sw = self.get_switch_limit(position)
  let mut min_val = phys
  if curv < min_val {
    min_val = curv
  }
  if sw < min_val {
    min_val = sw
  }
  min_val
}
