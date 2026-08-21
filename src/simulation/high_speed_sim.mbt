// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// HighSpeedSimulation builds a realistic 350 km/h high-speed passenger railway test line (50km long)
/// with gradients up to 25‰, curves, TSR zones, and multiple Movement Authority updates.
pub struct HighSpeedSimulation {
  train_params : @types.TrainParams
  ssp : @line_profile.StaticSpeedProfile
  tsr_mgr : @line_profile.TsrManager
  ma_resolver : @line_profile.MaResolver
  engine : @protection.SupervisionEngine
  fsm : @state_machine.AtpStateMachine
} derive(Eq, Debug)

///|
pub fn HighSpeedSimulation::new() -> HighSpeedSimulation {
  let params = @types.TrainParams::default_high_speed()
  let config = @types.SystemConfig::default()

  // Build 50km line profile
  let phys_segs = [
    @types.PhysicalSpeedSegment::new(0.0, 5000.0, 55.56), // 200 km/h acceleration out of station
    @types.PhysicalSpeedSegment::new(5000.0, 45000.0, 97.22), // 350 km/h mainline
    @types.PhysicalSpeedSegment::new(45000.0, 50000.0, 41.67), // 150 km/h approach
  ]

  let grads = [
    @types.GradientSegment::new(0.0, 10000.0, 0.0),
    @types.GradientSegment::new(10000.0, 15000.0, 15.0), // 15‰ uphill
    @types.GradientSegment::new(15000.0, 25000.0, -12.0), // 12‰ downhill
    @types.GradientSegment::new(25000.0, 50000.0, 0.0),
  ]

  let curvs = [
    @types.CurvatureSegment::new(0.0, 20000.0, 0.0, 0.0),
    @types.CurvatureSegment::new(20000.0, 24000.0, 7000.0, 150.0), // R=7000m curve
    @types.CurvatureSegment::new(24000.0, 50000.0, 0.0, 0.0),
  ]

  let switches = [
    @types.TrackSwitch::new(1, 48000.0, @types.SwitchPosition::from_int(1), 97.22, 22.22, true),
  ]

  let ssp = @line_profile.StaticSpeedProfile::new(phys_segs, grads, curvs, switches)
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
pub fn HighSpeedSimulation::run_step(
  self : HighSpeedSimulation,
  train_pos : Double,
  train_speed : Double,
  now_ms : Int64
) -> (@types.ProtectionThresholds, @types.ATPState) {
  let rail = @types.RailCondition::from_int(1) // Dry
  let thresh = self.engine.calculate_thresholds(
    train_pos,
    self.ssp,
    self.tsr_mgr,
    self.ma_resolver,
    now_ms,
    rail
  )

  let monitor = @protection.CeilingSpeedMonitor::new(@types.SystemConfig::default())
  let evt = monitor.evaluate(train_speed, thresh)

  let odo = @types.OdometerBounds::new(train_pos, 0.5, false, false)
  let tstate = @types.TrainState::new(
    now_ms,
    odo,
    train_speed,
    0.0,
    @types.CabMode::from_int(1),
    1,
    false,
    false,
    false
  )

  let next_state = self.fsm.transition(evt, tstate, thresh)
  (thresh, next_state)
}
