// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// MetroSimulation models 80 km/h dense urban CBTC metro line with 90-second headways,
/// platform screen door protection, frequent TSR updates, and short inter-station distances.
pub struct MetroSimulation {
  train_params : @types.TrainParams
  ssp : @line_profile.StaticSpeedProfile
  tsr_mgr : @line_profile.TsrManager
  ma_resolver : @line_profile.MaResolver
  engine : @protection.SupervisionEngine
  fsm : @state_machine.AtpStateMachine
} derive(Eq, Debug)

///|
pub fn MetroSimulation::new() -> MetroSimulation {
  let params = @types.TrainParams::default_metro()
  let config = @types.SystemConfig::default()

  // 10km metro corridor with 5 stations
  let phys_segs = [
    @types.PhysicalSpeedSegment::new(0.0, 2000.0, 22.22), // 80 km/h
    @types.PhysicalSpeedSegment::new(2000.0, 4000.0, 22.22),
    @types.PhysicalSpeedSegment::new(4000.0, 6000.0, 22.22),
    @types.PhysicalSpeedSegment::new(6000.0, 8000.0, 22.22),
    @types.PhysicalSpeedSegment::new(8000.0, 10000.0, 22.22),
  ]

  let grads = [
    @types.GradientSegment::new(0.0, 3000.0, 0.0),
    @types.GradientSegment::new(3000.0, 5000.0, -30.0), // 30‰ steep downhill into tunnel
    @types.GradientSegment::new(5000.0, 7000.0, 25.0), // 25‰ uphill out of tunnel
    @types.GradientSegment::new(7000.0, 10000.0, 0.0),
  ]

  let curvs = [
    @types.CurvatureSegment::new(0.0, 4000.0, 0.0, 0.0),
    @types.CurvatureSegment::new(4000.0, 4500.0, 300.0, 100.0), // Sharp R=300m metro curve
    @types.CurvatureSegment::new(4500.0, 10000.0, 0.0, 0.0),
  ]

  let switches = [
    @types.TrackSwitch::new(
      1,
      1500.0,
      @types.SwitchPosition::from_int(1),
      22.22,
      9.72,
      true,
    ),
    @types.TrackSwitch::new(
      2,
      8500.0,
      @types.SwitchPosition::from_int(2),
      22.22,
      9.72,
      true,
    ),
  ]

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
pub fn MetroSimulation::run_step(
  self : MetroSimulation,
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

  let odo = @types.OdometerBounds::new(train_pos, 0.2, false, false)
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
