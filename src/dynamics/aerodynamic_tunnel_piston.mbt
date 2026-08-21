// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TunnelPistonWaveModel computes aerodynamic drag surge when high speed train enters single track tunnel.
pub struct TunnelPistonWaveModel {
  air_density_kg_m3 : Double // 1.225 kg/m3
  train_cross_section_m2 : Double // e.g. 12.5 m2
  tunnel_cross_section_m2 : Double // e.g. 50.0 m2
} derive(Eq, Debug)

///|
pub fn TunnelPistonWaveModel::new(
  train_area : Double,
  tunnel_area : Double,
) -> TunnelPistonWaveModel {
  {
    air_density_kg_m3: 1.225,
    train_cross_section_m2: train_area,
    tunnel_cross_section_m2: tunnel_area,
  }
}

///|
pub fn TunnelPistonWaveModel::peak_pressure_wave_kpa(
  self : TunnelPistonWaveModel,
  speed_mps : Double,
) -> Double {
  let blockage_ratio = self.train_cross_section_m2 /
    self.tunnel_cross_section_m2
  let p_pa = 0.5 *
    self.air_density_kg_m3 *
    speed_mps *
    speed_mps *
    blockage_ratio /
    (1.0 - blockage_ratio)
  p_pa / 1000.0 // in kPa
}
