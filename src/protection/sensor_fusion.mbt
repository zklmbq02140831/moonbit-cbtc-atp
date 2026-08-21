// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// OdometerSensorFusion fusses wheel tachometer, Doppler radar, and accelerometer inputs.
pub struct OdometerSensorFusion {
  mut filtered_speed_mps : Double
  mut filtered_pos_m : Double
  wheel_weight : Double
  radar_weight : Double
} derive(Eq, Debug)

///|
pub fn OdometerSensorFusion::new() -> OdometerSensorFusion {
  {
    filtered_speed_mps: 0.0,
    filtered_pos_m: 0.0,
    wheel_weight: 0.4,
    radar_weight: 0.6,
  }
}

///|
pub fn OdometerSensorFusion::update_fusion(
  self : OdometerSensorFusion,
  v_wheel : Double,
  v_radar : Double?,
  dt_s : Double,
) -> Double {
  let v_fused = match v_radar {
    Some(vr) => self.wheel_weight * v_wheel + self.radar_weight * vr
    None => v_wheel
  }
  self.filtered_speed_mps = v_fused
  self.filtered_pos_m = self.filtered_pos_m + v_fused * dt_s
  self.filtered_speed_mps
}
