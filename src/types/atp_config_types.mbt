// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// AtpKernelConfig holds SIL4 system parameters, tolerances, and calibration constants.
pub struct AtpKernelConfig {
  max_system_speed_mps : Double // Absolute max speed (e.g., 111.11 m/s = 400 km/h)
  wheel_diameter_nominal_m : Double // Nominal wheel diameter (e.g., 0.92 m)
  wheel_diameter_wear_limit_m : Double // Min worn wheel diameter (e.g., 0.84 m)
  tachometer_pulses_per_rev : Int // Encoder resolution (e.g., 1024 pulses)
  doppler_radar_frequency_hz : Double // Radar frequency
  radar_speed_scale_factor : Double
  position_confidence_grow_rate : Double // Margin grow rate per meter (e.g., 0.005)
  max_allowable_slip_ratio : Double // Max wheel slip ratio (0.15)
  max_allowable_skid_ratio : Double // Max wheel skid ratio (0.15)
  service_brake_response_s : Double // Service brake delay (s)
  emergency_brake_response_s : Double // Emergency brake delay (s)
  pneumatic_pipe_wave_speed : Double // Air pipe pressure wave speed (260 m/s)
  atp_cycle_time_ms : Int64 // Processing cycle time (e.g. 100 ms)
  watchdog_timeout_ms : Int64 // Watchdog timer (500 ms)
} derive(Eq, Debug)

///|
pub fn AtpKernelConfig::default_hsr() -> AtpKernelConfig {
  {
    max_system_speed_mps: 111.11,
    wheel_diameter_nominal_m: 0.92,
    wheel_diameter_wear_limit_m: 0.85,
    tachometer_pulses_per_rev: 1024,
    doppler_radar_frequency_hz: 24.125e9,
    radar_speed_scale_factor: 1.0,
    position_confidence_grow_rate: 0.005,
    max_allowable_slip_ratio: 0.15,
    max_allowable_skid_ratio: 0.15,
    service_brake_response_s: 1.2,
    emergency_brake_response_s: 0.8,
    pneumatic_pipe_wave_speed: 260.0,
    atp_cycle_time_ms: 100,
    watchdog_timeout_ms: 500,
  }
}

///|
pub fn AtpKernelConfig::default_metro() -> AtpKernelConfig {
  {
    max_system_speed_mps: 27.78,
    wheel_diameter_nominal_m: 0.84,
    wheel_diameter_wear_limit_m: 0.77,
    tachometer_pulses_per_rev: 512,
    doppler_radar_frequency_hz: 24.125e9,
    radar_speed_scale_factor: 1.0,
    position_confidence_grow_rate: 0.003,
    max_allowable_slip_ratio: 0.12,
    max_allowable_skid_ratio: 0.12,
    service_brake_response_s: 0.8,
    emergency_brake_response_s: 0.5,
    pneumatic_pipe_wave_speed: 260.0,
    atp_cycle_time_ms: 100,
    watchdog_timeout_ms: 500,
  }
}

///|
pub fn AtpKernelConfig::calc_effective_wheel_circumference(
  self : AtpKernelConfig,
  wear_ratio : Double, // 0.0 (new) to 1.0 (fully worn)
) -> Double {
  let diameter = self.wheel_diameter_nominal_m -
    (self.wheel_diameter_nominal_m - self.wheel_diameter_wear_limit_m) *
    wear_ratio
  3.141592653589793 * diameter
}
