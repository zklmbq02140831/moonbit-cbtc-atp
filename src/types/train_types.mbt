// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TrainParams defines the physical, mechanical, and aerodynamic parameters of a train.
pub struct TrainParams {
  train_id : Int
  train_length : Double // meters
  total_mass_tonnes : Double // metric tonnes
  rotating_mass_factor : Double // e.g. 1.08 for 8% extra inertia
  max_service_speed : Double // m/s (e.g., 350 km/h = 97.22 m/s)
  max_traction_force_kn : Double // kN
  max_acceleration : Double // m/s^2
  service_brake_decel_base : Double // m/s^2 (nominal full service brake)
  emergency_brake_decel_base : Double // m/s^2 (nominal emergency brake)
  service_brake_delay_s : Double // seconds ($t_{bd\_sbd}$)
  emergency_brake_delay_s : Double // seconds ($t_{bd\_ebd}$)
  service_brake_build_time_s : Double // seconds to build full pressure
  emergency_brake_build_time_s : Double // seconds to build full pressure
  davis_a : Double // Davis constant resistance term A (N/tonne or N)
  davis_b : Double // Davis speed linear term B (N/(km/h))
  davis_c : Double // Davis speed quadratic aerodynamic term C (N/(km/h)^2)
  adhesion_mu0 : Double // nominal dry adhesion coefficient (e.g., 0.15 - 0.25)
  adhesion_a1 : Double
  adhesion_a2 : Double
} derive(Eq, Debug)

///|
/// Construct train dynamics values for integration tests and controlled deployments.
pub fn TrainParams::new(
  train_id : Int,
  train_length : Double,
  total_mass_tonnes : Double,
  rotating_mass_factor : Double,
  max_service_speed : Double,
  max_traction_force_kn : Double,
  max_acceleration : Double,
  service_brake_decel_base : Double,
  emergency_brake_decel_base : Double,
  service_brake_delay_s : Double,
  emergency_brake_delay_s : Double,
  service_brake_build_time_s : Double,
  emergency_brake_build_time_s : Double,
  davis_a : Double,
  davis_b : Double,
  davis_c : Double,
  adhesion_mu0 : Double,
  adhesion_a1 : Double,
  adhesion_a2 : Double,
) -> TrainParams {
  {
    train_id,
    train_length,
    total_mass_tonnes,
    rotating_mass_factor,
    max_service_speed,
    max_traction_force_kn,
    max_acceleration,
    service_brake_decel_base,
    emergency_brake_decel_base,
    service_brake_delay_s,
    emergency_brake_delay_s,
    service_brake_build_time_s,
    emergency_brake_build_time_s,
    davis_a,
    davis_b,
    davis_c,
    adhesion_mu0,
    adhesion_a1,
    adhesion_a2,
  }
}

///|
/// Validate the physical ranges used by the braking and resistance models.
pub fn TrainParams::is_valid(self : TrainParams) -> Bool {
  train_finite(self.train_length) &&
  train_finite(self.total_mass_tonnes) &&
  train_finite(self.rotating_mass_factor) &&
  train_finite(self.max_service_speed) &&
  train_finite(self.max_traction_force_kn) &&
  train_finite(self.max_acceleration) &&
  train_finite(self.service_brake_decel_base) &&
  train_finite(self.emergency_brake_decel_base) &&
  train_finite(self.service_brake_delay_s) &&
  train_finite(self.emergency_brake_delay_s) &&
  train_finite(self.service_brake_build_time_s) &&
  train_finite(self.emergency_brake_build_time_s) &&
  train_finite(self.davis_a) &&
  train_finite(self.davis_b) &&
  train_finite(self.davis_c) &&
  train_finite(self.adhesion_mu0) &&
  train_finite(self.adhesion_a1) &&
  train_finite(self.adhesion_a2) &&
  self.train_length > 0.0 &&
  self.total_mass_tonnes > 0.0 &&
  self.rotating_mass_factor >= 1.0 &&
  self.max_service_speed > 0.0 &&
  self.max_traction_force_kn > 0.0 &&
  self.max_acceleration > 0.0 &&
  self.service_brake_decel_base > 0.0 &&
  self.emergency_brake_decel_base >= self.service_brake_decel_base &&
  self.service_brake_delay_s >= 0.0 &&
  self.emergency_brake_delay_s >= 0.0 &&
  self.service_brake_build_time_s >= 0.0 &&
  self.emergency_brake_build_time_s >= 0.0 &&
  self.davis_a >= 0.0 &&
  self.davis_b >= 0.0 &&
  self.davis_c >= 0.0 &&
  self.adhesion_mu0 > 0.0 &&
  self.adhesion_mu0 <= 1.0 &&
  self.adhesion_a1 >= 0.0 &&
  self.adhesion_a2 >= 0.0
}

///|
pub fn TrainParams::default_high_speed() -> TrainParams {
  {
    train_id: 101,
    train_length: 200.0,
    total_mass_tonnes: 450.0,
    rotating_mass_factor: 1.08,
    max_service_speed: 97.22, // 350 km/h
    max_traction_force_kn: 300.0,
    max_acceleration: 0.65,
    service_brake_decel_base: 0.9,
    emergency_brake_decel_base: 1.2,
    service_brake_delay_s: 1.2,
    emergency_brake_delay_s: 0.8,
    service_brake_build_time_s: 2.0,
    emergency_brake_build_time_s: 1.0,
    davis_a: 1.2,
    davis_b: 0.015,
    davis_c: 0.00028,
    adhesion_mu0: 0.22,
    adhesion_a1: 0.005,
    adhesion_a2: 0.01,
  }
}

///|
pub fn TrainParams::default_metro() -> TrainParams {
  {
    train_id: 201,
    train_length: 140.0,
    total_mass_tonnes: 220.0,
    rotating_mass_factor: 1.10,
    max_service_speed: 22.22, // 80 km/h
    max_traction_force_kn: 240.0,
    max_acceleration: 1.0,
    service_brake_decel_base: 1.0,
    emergency_brake_decel_base: 1.3,
    service_brake_delay_s: 0.8,
    emergency_brake_delay_s: 0.5,
    service_brake_build_time_s: 1.5,
    emergency_brake_build_time_s: 0.8,
    davis_a: 1.8,
    davis_b: 0.02,
    davis_c: 0.0004,
    adhesion_mu0: 0.18,
    adhesion_a1: 0.004,
    adhesion_a2: 0.008,
  }
}

///|
pub fn TrainParams::default_freight() -> TrainParams {
  {
    train_id: 301,
    train_length: 800.0,
    total_mass_tonnes: 5000.0,
    rotating_mass_factor: 1.05,
    max_service_speed: 25.0, // 90 km/h
    max_traction_force_kn: 600.0,
    max_acceleration: 0.25,
    service_brake_decel_base: 0.45,
    emergency_brake_decel_base: 0.65,
    service_brake_delay_s: 3.5,
    emergency_brake_delay_s: 2.2,
    service_brake_build_time_s: 6.0,
    emergency_brake_build_time_s: 3.5,
    davis_a: 1.5,
    davis_b: 0.025,
    davis_c: 0.0005,
    adhesion_mu0: 0.14,
    adhesion_a1: 0.003,
    adhesion_a2: 0.009,
  }
}

///|
pub fn TrainParams::effective_mass_kg(self : TrainParams) -> Double {
  self.total_mass_tonnes * 1000.0 * self.rotating_mass_factor
}

///|
fn train_finite(value : Double) -> Bool {
  !value.is_nan() && !value.is_inf()
}

///|
/// AdhesionCondition represents track rail surface condition.
pub enum RailCondition {
  Dry
  Wet
  DampWithLeaves
  Icy
} derive(Eq, Debug)

///|
pub fn RailCondition::from_int(code : Int) -> RailCondition {
  match code {
    1 => Dry
    2 => Wet
    3 => DampWithLeaves
    _ => Icy
  }
}

///|
pub fn RailCondition::adhesion_multiplier(self : RailCondition) -> Double {
  match self {
    Dry => 1.0
    Wet => 0.75
    DampWithLeaves => 0.45
    Icy => 0.30
  }
}
