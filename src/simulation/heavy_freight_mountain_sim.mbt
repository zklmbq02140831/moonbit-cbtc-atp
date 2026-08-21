// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// HeavyFreightMountainSimulation models 5,000t freight train on steep 25‰ mountain downgrade.
pub struct HeavyFreightMountainSimulation {
  train_params : @types.TrainParams
  ssp : @line_profile.StaticSpeedProfile
  tsr_mgr : @line_profile.TsrManager
  ma_resolver : @line_profile.MaResolver
  engine : @protection.SupervisionEngine
  fsm : @state_machine.AtpStateMachine
} derive(Eq, Debug)

///|
pub fn HeavyFreightMountainSimulation::new() -> HeavyFreightMountainSimulation {
  let params = @types.TrainParams::default_freight()
  let config = @types.SystemConfig::default()

  let phys_segs = [
    @types.PhysicalSpeedSegment::new(0.0, 30000.0, 22.22), // 80 km/h max
  ]

  let grads = [
    @types.GradientSegment::new(0.0, 5000.0, 0.0),
    @types.GradientSegment::new(5000.0, 20000.0, -25.0), // 25‰ steep downhill
    @types.GradientSegment::new(20000.0, 30000.0, 0.0),
  ]

  let curvs = [@types.CurvatureSegment::new(0.0, 30000.0, 0.0, 0.0)]

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
pub fn HeavyFreightMountainSimulation::run_step(
  self : HeavyFreightMountainSimulation,
  train_pos : Double,
  train_speed : Double,
  now_ms : Int64,
) -> (@types.ProtectionThresholds, @types.ATPState) {
  let rail = @types.RailCondition::from_int(2) // Wet
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

  let odo = @types.OdometerBounds::new(train_pos, 1.0, false, false)
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
