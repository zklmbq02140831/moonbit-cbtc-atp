// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AirBrakePipeWaveModel simulates brake pipe pneumatic pressure wave propagation along long trains.
/// Standard propagation velocity v_wave \approx 250 - 280 m/s for pneumatic train pipes.
pub struct AirBrakePipeWaveModel {
  pipe_wave_speed_mps : Double // m/s
  cylinder_fill_rate : Double // kPa/s
} derive(Eq, Debug)

///|
pub fn AirBrakePipeWaveModel::new() -> AirBrakePipeWaveModel {
  { pipe_wave_speed_mps: 260.0, cylinder_fill_rate: 150.0 }
}

///|
/// Time delay for brake command to reach vehicle at distance x from lead locomotive.
pub fn AirBrakePipeWaveModel::propagation_delay_s(
  self : AirBrakePipeWaveModel,
  distance_from_cab_m : Double,
) -> Double {
  distance_from_cab_m / self.pipe_wave_speed_mps
}

///|
/// Brake cylinder pressure build-up ratio (0.0 to 1.0) at elapsed time t_elapsed for vehicle at position x.
pub fn AirBrakePipeWaveModel::cylinder_pressure_ratio(
  self : AirBrakePipeWaveModel,
  elapsed_s : Double,
  vehicle_pos_from_cab_m : Double,
  full_build_time_s : Double,
) -> Double {
  let delay = self.propagation_delay_s(vehicle_pos_from_cab_m)
  if elapsed_s <= delay {
    0.0
  } else {
    let t_active = elapsed_s - delay
    if t_active >= full_build_time_s {
      1.0
    } else {
      t_active / full_build_time_s
    }
  }
}
