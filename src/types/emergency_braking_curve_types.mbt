// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// BrakingCurvePoint represents a discrete (distance, speed) coordinate on the EBI/SBI curve.
pub struct BrakingCurvePoint {
  position_m : Double
  allowed_speed_mps : Double
} derive(Eq, Debug)

///|
pub fn BrakingCurvePoint::new(
  pos_m : Double,
  speed_mps : Double,
) -> BrakingCurvePoint {
  { position_m: pos_m, allowed_speed_mps: speed_mps }
}

///|
/// DynamicBrakingCurveHolder contains calculated EBI/SBI curve points array.
pub struct DynamicBrakingCurveHolder {
  target_position_m : Double
  target_speed_mps : Double
  curve_points : Array[BrakingCurvePoint]
} derive(Eq, Debug)

///|
pub fn DynamicBrakingCurveHolder::new(
  t_pos : Double,
  t_speed : Double,
  pts : Array[BrakingCurvePoint],
) -> DynamicBrakingCurveHolder {
  { target_position_m: t_pos, target_speed_mps: t_speed, curve_points: pts }
}
