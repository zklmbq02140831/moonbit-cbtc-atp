// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
fn main {
  let odometer = @types.OdometerBounds::new(1000.0, 0.2, false, false)
  let state_a = @types.TrainState::new(
    1000,
    odometer,
    20.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let state_b = @types.TrainState::new(
    1000,
    odometer,
    20.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    1000.0, 20.0, odometer, 1000, state_a, state_b,
  )
  let ssp = @line_profile.StaticSpeedProfile::new(
    [@types.PhysicalSpeedSegment::new(0.0, 20000.0, 40.0)],
    [@types.GradientSegment::new(0.0, 20000.0, 0.0)],
    [],
    [],
  )
  let ma = @line_profile.MaResolver::new(5000)
  ma.update_ma(
    @types.MovementAuthority::new(1, 0, 0.0, 12000.0, 0.0, 0.0, 40.0),
    0,
  )
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    input,
    ssp,
    @line_profile.TsrManager::new(),
    ma,
    @types.RailCondition::from_int(1),
  )
  println(
    "action_code=" +
    decision.action.code().to_string() +
    ",state_severity=" +
    decision.trace.state.severity_level().to_string() +
    ",permitted_mps=" +
    decision.trace.permitted_speed.to_string() +
    ",eoa_margin_m=" +
    decision.trace.margin_to_eoa.to_string() +
    ",reason_code=" +
    decision.trace.reason.code().to_string(),
  )
}
