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
/// Validate all static profile geometry and speed values before supervision.
pub fn StaticSpeedProfile::is_valid(self : StaticSpeedProfile) -> Bool {
  if self.segments.length() == 0 {
    return false
  }
  for i = 0; i < self.segments.length(); i = i + 1 {
    let s = self.segments[i]
    if !ssp_finite(s.start_pos) ||
      !ssp_finite(s.end_pos) ||
      !ssp_finite(s.max_speed) ||
      s.start_pos < 0.0 ||
      s.end_pos < s.start_pos ||
      s.max_speed < 0.0 {
      return false
    }
  }
  for i = 0; i < self.gradients.length(); i = i + 1 {
    let g = self.gradients[i]
    if !ssp_finite(g.start_pos) ||
      !ssp_finite(g.end_pos) ||
      !ssp_finite(g.value) ||
      g.start_pos < 0.0 ||
      g.end_pos < g.start_pos {
      return false
    }
  }
  for i = 0; i < self.curvatures.length(); i = i + 1 {
    let c = self.curvatures[i]
    if !ssp_finite(c.start_pos) ||
      !ssp_finite(c.end_pos) ||
      !ssp_finite(c.radius) ||
      !ssp_finite(c.cant) ||
      c.start_pos < 0.0 ||
      c.end_pos < c.start_pos ||
      c.radius < 0.0 {
      return false
    }
    if c.radius > 0.1 && c.cant < -110.0 {
      return false
    }
  }
  for i = 0; i < self.switches.length(); i = i + 1 {
    let sw = self.switches[i]
    if !ssp_finite(sw.position_m) ||
      !ssp_finite(sw.normal_speed_limit) ||
      !ssp_finite(sw.reverse_speed_limit) ||
      sw.position_m < 0.0 ||
      sw.normal_speed_limit < 0.0 ||
      sw.reverse_speed_limit < 0.0 {
      return false
    }
  }
  true
}

///|
/// Return whether a physical speed segment covers the supplied chainage.
pub fn StaticSpeedProfile::has_physical_limit_at(
  self : StaticSpeedProfile,
  position : Double,
) -> Bool {
  if position.is_nan() || position.is_inf() || position < 0.0 {
    return false
  }
  for i = 0; i < self.segments.length(); i = i + 1 {
    let s = self.segments[i]
    if position >= s.start_pos && position <= s.end_pos {
      return true
    }
  }
  false
}

///|
fn ssp_finite(value : Double) -> Bool {
  !value.is_nan() && !value.is_inf()
}

///|
pub fn StaticSpeedProfile::get_physical_limit(
  self : StaticSpeedProfile,
  position : Double,
) -> Double {
  let mut limit = 1000.0
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
        let effective_cant = if cant_mm > 0.0 { cant_mm } else { c.cant }
        let radicand = c.radius * (effective_cant + 110.0)
        if radicand.is_nan() || radicand.is_inf() || radicand <= 0.0 {
          return 0.0
        }
        let limit_kmh = (radicand / 11.8).sqrt()
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
/// TurnoutType speed rating lookup function according to standard railway turnout geometry.
pub fn turnout_speed_rating_mps(turnout_ratio_code : Int) -> Double {
  match turnout_ratio_code {
    9 => 8.33 // No. 9 turnout (30 km/h)
    12 => 12.5 // No. 12 turnout (45 km/h)
    18 => 22.22 // No. 18 turnout (80 km/h)
    30 => 44.44 // No. 30 high-speed turnout (160 km/h)
    42 => 61.11 // No. 42 high-speed turnout (220 km/h)
    _ => 8.33
  }
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
