// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SubwayDenseHeadwaySimulation models 90-second dense headway CBTC subway corridor.
pub struct SubwayDenseHeadwaySimulation {
  train_params : @types.TrainParams
  ssp : @line_profile.StaticSpeedProfile
  tsr_mgr : @line_profile.TsrManager
  ma_resolver : @line_profile.MaResolver
  engine : @protection.SupervisionEngine
  fsm : @state_machine.AtpStateMachine
} derive(Eq, Debug)

///|
pub fn SubwayDenseHeadwaySimulation::new() -> SubwayDenseHeadwaySimulation {
  let params = @types.TrainParams::default_metro()
  let config = @types.SystemConfig::default()

  let phys_segs = [
    @types.PhysicalSpeedSegment::new(0.0, 10000.0, 22.22), // 80 km/h
  ]

  let grads = [@types.GradientSegment::new(0.0, 10000.0, 0.0)]

  let curvs = [@types.CurvatureSegment::new(0.0, 10000.0, 0.0, 0.0)]

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
pub fn SubwayDenseHeadwaySimulation::run_step(
  self : SubwayDenseHeadwaySimulation,
  train_pos : Double,
  train_speed : Double,
  now_ms : Int64,
) -> (@types.ProtectionThresholds, @types.ATPState) {
  let rail = @types.RailCondition::from_int(1) // Dry
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

  let odo = @types.OdometerBounds::new(train_pos, 0.1, false, false)
  let tstate = @types.TrainState::new(
    now_ms,
    odo,
    train_speed,
    0.0,
    @types.CabMode::from_int(1),
    1,
    false,
    false,
    false,
  )

  let next_state = self.fsm.transition(evt, tstate, thresh)
  (thresh, next_state)
}
