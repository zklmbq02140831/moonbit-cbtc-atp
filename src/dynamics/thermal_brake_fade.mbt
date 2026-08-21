// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ThermalBrakeFadeModel computes friction disc brake thermal accumulation and fade coefficient.
pub struct ThermalBrakeFadeModel {
  mut disc_temp_celsius : Double
  heat_dissipation_rate : Double // °C / s
  fade_onset_temp_celsius : Double // °C (e.g. 400°C)
} derive(Eq, Debug)

///|
pub fn ThermalBrakeFadeModel::new() -> ThermalBrakeFadeModel {
  {
    disc_temp_celsius: 20.0,
    heat_dissipation_rate: 0.5,
    fade_onset_temp_celsius: 400.0,
  }
}

///|
pub fn ThermalBrakeFadeModel::update_temperature(
  self : ThermalBrakeFadeModel,
  brake_force_kn : Double,
  speed_mps : Double,
  dt_s : Double,
) -> Double {
  let heat_input = brake_force_kn * speed_mps * 0.002 // Heating factor
  let cooling = self.heat_dissipation_rate * dt_s
  self.disc_temp_celsius = self.disc_temp_celsius + heat_input * dt_s - cooling
  if self.disc_temp_celsius < 20.0 {
    self.disc_temp_celsius = 20.0
  }
  self.disc_temp_celsius
}

///|
pub fn ThermalBrakeFadeModel::fade_multiplier(
  self : ThermalBrakeFadeModel,
) -> Double {
  if self.disc_temp_celsius <= self.fade_onset_temp_celsius {
    1.0
  } else {
    let delta = self.disc_temp_celsius - self.fade_onset_temp_celsius
    let fade = 1.0 - delta * 0.001
    if fade < 0.6 {
      0.6
    } else {
      fade
    }
  }
}
