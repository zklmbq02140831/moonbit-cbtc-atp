// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// MountainRailSimulation models mountain passenger line with 35‰ continuous grades and R=400m tight curves.
pub struct MountainRailSimulation {
  train_params : @types.TrainParams
  ssp : @line_profile.StaticSpeedProfile
  tsr_mgr : @line_profile.TsrManager
  ma_resolver : @line_profile.MaResolver
  engine : @protection.SupervisionEngine
  fsm : @state_machine.AtpStateMachine
} derive(Eq, Debug)

///|
pub fn MountainRailSimulation::new() -> MountainRailSimulation {
  let params = @types.TrainParams::default_metro()
  let config = @types.SystemConfig::default()

  let phys_segs = [
    @types.PhysicalSpeedSegment::new(0.0, 20000.0, 33.33), // 120 km/h
  ]

  let grads = [
    @types.GradientSegment::new(0.0, 5000.0, 0.0),
    @types.GradientSegment::new(5000.0, 15000.0, 35.0), // 35‰ steep grade
    @types.GradientSegment::new(15000.0, 20000.0, -30.0),
  ]

  let curvs = [
    @types.CurvatureSegment::new(0.0, 8000.0, 0.0, 0.0),
    @types.CurvatureSegment::new(8000.0, 12000.0, 400.0, 120.0), // R=400m curve
    @types.CurvatureSegment::new(12000.0, 20000.0, 0.0, 0.0),
  ]

  let switches : Array[@types.TrackSwitch] = Array::new()
  let ssp = @line_profile.StaticSpeedProfile::new(
    phys_segs, grads, curvs, switches,
  )
  let tsr_mgr = @line_profile.TsrManager::new()
  let ma_resolver = @line_profile.MaResolver::new(config.ma_timeout_ms)

  {
    train_params: params,
    ssp,
    tsr_mgr,
    ma_resolver,
    engine: @protection.SupervisionEngine::new(config, params),
    fsm: @state_machine.AtpStateMachine::new(config),
  }
}

///|
pub fn MountainRailSimulation::run_step(
  self : MountainRailSimulation,
  train_pos : Double,
  train_speed : Double,
  now_ms : Int64,
) -> (@types.ProtectionThresholds, @types.ATPState) {
  let rail = @types.RailCondition::from_int(3) // Damp with leaves
  let thresh = self.engine.calculate_thresholds(
    train_pos,
    self.ssp,
    self.tsr_mgr,
    self.ma_resolver,
    now_ms,
    rail,
  )

  let monitor = @protection.CeilingSpeedMonitor::new(
    @types.SystemConfig::default(),
  )
  let evt = monitor.evaluate(train_speed, thresh)

  let odo = @types.OdometerBounds::new(train_pos, 0.8, false, false)
  let tstate = @types.TrainState::new(
    now_ms,
    odo,
    train_speed,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )

  let next_state = self.fsm.transition(evt, tstate, thresh)
  (thresh, next_state)
}
