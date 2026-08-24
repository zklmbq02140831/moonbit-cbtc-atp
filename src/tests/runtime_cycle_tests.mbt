// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
fn runtime_test_profile() -> @line_profile.StaticSpeedProfile {
  @line_profile.StaticSpeedProfile::new(
    [@types.PhysicalSpeedSegment::new(0.0, 20000.0, 40.0)],
    [@types.GradientSegment::new(0.0, 20000.0, 0.0)],
    [],
    [],
  )
}

///|
fn runtime_test_input(
  position : Double,
  speed : Double,
  timestamp : Int64,
) -> @runtime.AtpCycleInput {
  runtime_test_input_with_channel_timestamps(
    position, speed, timestamp, timestamp, timestamp,
  )
}

///|
fn runtime_test_input_with_channel_timestamps(
  position : Double,
  speed : Double,
  timestamp : Int64,
  channel_timestamp_a : Int64,
  channel_timestamp_b : Int64,
) -> @runtime.AtpCycleInput {
  let odometer = @types.OdometerBounds::new(position, 0.2, false, false)
  let state_a = @types.TrainState::new(
    channel_timestamp_a,
    odometer,
    speed,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let state_b = @types.TrainState::new(
    channel_timestamp_b,
    odometer,
    speed,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  @runtime.AtpCycleInput::new(
    position, speed, odometer, timestamp, state_a, state_b,
  )
}

///|
fn runtime_test_ma(
  timeout_ms : Int64,
  now_ms : Int64,
) -> @line_profile.MaResolver {
  runtime_test_ma_to_eoa(timeout_ms, now_ms, 12000.0)
}

///|
fn runtime_test_ma_to_eoa(
  timeout_ms : Int64,
  now_ms : Int64,
  eoa : Double,
) -> @line_profile.MaResolver {
  let resolver = @line_profile.MaResolver::new(timeout_ms)
  resolver.update_ma(
    @types.MovementAuthority::new(1, 0, 0.0, eoa, 0.0, 0.0, 40.0),
    0,
  )
  let _ = now_ms
  resolver
}

///|
fn runtime_test_decision_for_speed(speed : Double) -> @runtime.AtpCycleDecision {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  engine.evaluate(
    runtime_test_input(1000.0, speed, 1000),
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
}

///|
test "runtime cycle keeps a safe train in continue action" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1000),
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="1")
  inspect(decision.trace.state.severity_level(), content="2")
  inspect(decision.is_fail_safe(), content="false")
}

///|
test "runtime cycle escalates a trip boundary violation" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 50.0, 1000),
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.state.severity_level(), content="6")
  inspect(decision.trace.reason.code(), content="6")
}

///|
test "runtime cycle fails safe when movement authority is expired" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_metro(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 10.0, 7000),
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 7000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.is_fail_safe(), content="true")
  inspect(decision.trace.reason.code(), content="7")
}

///|
test "runtime cycle produces a deterministic trace" {
  let profile = runtime_test_profile()
  let input = runtime_test_input(2000.0, 30.0, 1000)
  let first = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  ).evaluate(
    input,
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  let second = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  ).evaluate(
    input,
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(first.action.code() == second.action.code(), content="true")
  inspect(
    first.trace.permitted_speed == second.trace.permitted_speed,
    content="true",
  )
  inspect(
    first.trace.reason.code() == second.trace.reason.code(),
    content="true",
  )
}

///|
test "runtime maps warning service and emergency thresholds" {
  inspect(runtime_test_decision_for_speed(41.5).action.code(), content="2")
  inspect(runtime_test_decision_for_speed(42.5).action.code(), content="3")
  inspect(runtime_test_decision_for_speed(43.5).action.code(), content="4")
}

///|
test "runtime keeps a trip latched across a later safe snapshot" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let profile = runtime_test_profile()
  let trip = engine.evaluate(
    runtime_test_input(1000.0, 50.0, 1000),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  let safe_after_trip = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1001),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1001),
    @types.RailCondition::from_int(1),
  )
  inspect(trip.action.code(), content="5")
  inspect(safe_after_trip.action.code(), content="5")
  inspect(safe_after_trip.trace.reason.code(), content="6")
}

///|
test "runtime trips when a stopped train is already beyond EOA" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 0.0, 1000),
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma_to_eoa(5000, 1000, 900.0),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.reason.code(), content="6")
}

///|
test "runtime rejects non finite telemetry" {
  let nan_input = runtime_test_input(0.0 / 0.0, 20.0, 1000)
  let infinity_input = runtime_test_input(1000.0, 1.0 / 0.0, 1000)
  let nan_issues = nan_input.validate(0.5, 1.0)
  let infinity_issues = infinity_input.validate(0.5, 1.0)
  inspect(nan_issues.length(), content="1")
  inspect(nan_issues[0].code.code(), content="7")
  inspect(infinity_issues.length(), content="1")
  inspect(infinity_issues[0].code.code(), content="7")
}

///|
test "runtime rejects a timestamp rollback within one engine" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let profile = runtime_test_profile()
  let _ = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1000),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 999),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 999),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.reason.code(), content="8")
  inspect(decision.issues[0].code.code(), content="8")
}

///|
test "runtime evaluates channel speed snapshots independently" {
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
    50.0,
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
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    40.0,
    1.0,
  )
  let decision = engine.evaluate(
    input,
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.reason.code(), content="6")
}

///|
test "runtime latches an invalid input before accepting later data" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let profile = runtime_test_profile()
  let first = engine.evaluate(
    runtime_test_input(-1.0, 20.0, 1000),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  let second = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1001),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1001),
    @types.RailCondition::from_int(1),
  )
  inspect(first.action.code(), content="5")
  first.issues.push(first.issues[0])
  inspect(second.action.code(), content="5")
  inspect(second.trace.reason.code(), content="8")
  inspect(second.issues.length(), content="1")
  inspect(second.issues[0].code.code(), content="1")
  let third = engine.evaluate(
    runtime_test_input(0.0 / 0.0, 20.0, 1002),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1002),
    @types.RailCondition::from_int(1),
  )
  inspect(third.trace.position_m, content="0")
}

///|
test "runtime latches movement authority loss before accepting later data" {
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let profile = runtime_test_profile()
  let first = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1000),
    profile,
    @line_profile.TsrManager::new(),
    @line_profile.MaResolver::new(5000),
    @types.RailCondition::from_int(1),
  )
  let second = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1001),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1001),
    @types.RailCondition::from_int(1),
  )
  inspect(first.action.code(), content="5")
  inspect(second.action.code(), content="5")
  inspect(second.trace.reason.code(), content="7")
}

///|
test "runtime rejects malformed static speed profiles" {
  let malformed = @line_profile.StaticSpeedProfile::new(
    [@types.PhysicalSpeedSegment::new(100.0, 0.0, 40.0)],
    [@types.GradientSegment::new(0.0, 100.0, 0.0)],
    [],
    [],
  )
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(50.0, 20.0, 1000),
    malformed,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.reason.code(), content="8")
  inspect(decision.issues[0].code.code(), content="9")
}

///|
test "runtime rejects a valid profile without coverage at the train position" {
  let profile = @line_profile.StaticSpeedProfile::new(
    [@types.PhysicalSpeedSegment::new(0.0, 100.0, 40.0)],
    [@types.GradientSegment::new(0.0, 100.0, 0.0)],
    [],
    [],
  )
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1000),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.reason.code(), content="8")
  inspect(decision.issues[0].code.code(), content="13")
}

///|
test "runtime rejects channel timestamps that do not match the cycle" {
  let input = runtime_test_input_with_channel_timestamps(
    1000.0, 20.0, 1000, 999, 1000,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="1")
  inspect(issues[0].code.code(), content="11")
}

///|
test "runtime rejects invalid system configuration at construction" {
  let config = @types.SystemConfig::new(
    0.0 / 0.0,
    2.22,
    2.78,
    4.17,
    5000,
    0.15,
    0.5,
    true,
  )
  let engine = @runtime.AtpCycleEngine::new(
    config,
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1000),
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.reason.code(), content="8")
  inspect(decision.issues[0].code.code(), content="14")
}

///|
test "runtime rejects invalid train dynamics at construction" {
  let params = @types.TrainParams::new(
    101,
    200.0,
    450.0,
    1.08,
    97.22,
    300.0,
    0.65,
    0.0 / 0.0,
    1.2,
    1.2,
    0.8,
    2.0,
    1.0,
    1.2,
    0.015,
    0.00028,
    0.22,
    0.005,
    0.01,
  )
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    params,
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(1000.0, 20.0, 1000),
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.issues[0].code.code(), content="14")
}

///|
test "runtime uses the forward edge of odometer uncertainty for EOA" {
  let odometer = @types.OdometerBounds::new(999.0, 2.0, false, false)
  let state = @types.TrainState::new(
    1000,
    odometer,
    0.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    999.0, 0.0, odometer, 1000, state, state,
  )
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    input,
    runtime_test_profile(),
    @line_profile.TsrManager::new(),
    runtime_test_ma_to_eoa(5000, 1000, 1000.0),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.trace.reason.code(), content="6")
}

///|
test "runtime rejects unsafe curvature cant before taking a cycle" {
  let profile = @line_profile.StaticSpeedProfile::new(
    [@types.PhysicalSpeedSegment::new(0.0, 20000.0, 40.0)],
    [@types.GradientSegment::new(0.0, 20000.0, 0.0)],
    [@types.CurvatureSegment::new(0.0, 1000.0, 100.0, -120.0)],
    [],
  )
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let decision = engine.evaluate(
    runtime_test_input(100.0, 20.0, 1000),
    profile,
    @line_profile.TsrManager::new(),
    runtime_test_ma(5000, 1000),
    @types.RailCondition::from_int(1),
  )
  inspect(decision.action.code(), content="5")
  inspect(decision.issues[0].code.code(), content="9")
}
