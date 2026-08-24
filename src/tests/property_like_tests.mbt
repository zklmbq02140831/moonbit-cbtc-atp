// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
test "dynamic protection thresholds preserve intervention ordering" {
  let supervisor = @protection.SupervisionEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_metro(),
  )
  let ssp = @line_profile.StaticSpeedProfile::new(
    [@types.PhysicalSpeedSegment::new(0.0, 10000.0, 30.0)],
    [@types.GradientSegment::new(0.0, 10000.0, 0.0)],
    [],
    [],
  )
  let ma = @line_profile.MaResolver::new(5000)
  ma.update_ma(
    @types.MovementAuthority::new(3, 0, 0.0, 10000.0, 0.0, 0.0, 30.0),
    1000,
  )
  for position in [0.0, 100.0, 1000.0, 9999.0] {
    let thresholds = supervisor.calculate_thresholds(
      position,
      ssp,
      @line_profile.TsrManager::new(),
      ma,
      1000,
      @types.RailCondition::from_int(1),
    )
    inspect(
      thresholds.permitted_speed <= thresholds.warning_speed &&
      thresholds.warning_speed <= thresholds.service_brake_speed &&
      thresholds.service_brake_speed <= thresholds.emergency_brake_speed &&
      thresholds.emergency_brake_speed <= thresholds.trip_speed,
      content="true",
    )
  }
}

///|
test "movement authority timeout boundary is deterministic" {
  let resolver = @line_profile.MaResolver::new(5000)
  resolver.update_ma(
    @types.MovementAuthority::new(8, 0, 0.0, 1000.0, 0.0, 0.0, 20.0),
    1000,
  )
  inspect(resolver.is_expired(6000), content="false")
  inspect(resolver.is_expired(6001), content="true")
  inspect(resolver.remaining_distance_to_eoa(500.0, 6001), content="0")
}

///|
test "movement authority route limit caps the synthesized permitted speed" {
  let supervisor = @protection.SupervisionEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_metro(),
  )
  let ssp = @line_profile.StaticSpeedProfile::new(
    [@types.PhysicalSpeedSegment::new(0.0, 10000.0, 30.0)],
    [@types.GradientSegment::new(0.0, 10000.0, 0.0)],
    [],
    [],
  )
  let ma = @line_profile.MaResolver::new(5000)
  ma.update_ma(
    @types.MovementAuthority::new(11, 0, 0.0, 10000.0, 0.0, 0.0, 20.0),
    1000,
  )
  let thresholds = supervisor.calculate_thresholds(
    100.0,
    ssp,
    @line_profile.TsrManager::new(),
    ma,
    1000,
    @types.RailCondition::from_int(1),
  )
  inspect(thresholds.permitted_speed, content="20")
}

///|
test "segment range result is deterministic and duplicate free" {
  let segments : Array[@types.TrackSegment] = Array::new()
  for i = 0; i < 12; i = i + 1 {
    let start = (i * 100).to_double()
    segments.push(
      @types.TrackSegment::new(
        i,
        start,
        start + 100.0,
        20.0,
        0.0,
        0.0,
        false,
        0,
        0.0,
        0.0,
      ),
    )
  }
  let tree = @line_profile.SegmentTree::build(segments)
  let first = tree.query_range(250.0, 850.0)
  let second = tree.query_range(250.0, 850.0)
  inspect(first.length(), content="7")
  inspect(first == second, content="true")
}
