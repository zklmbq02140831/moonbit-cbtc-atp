// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
fn measure(name : String, iterations : Int, work : () -> Int) -> Unit {
  let start = @bench.monotonic_clock_start()
  let checksum = work()
  let elapsed_us = @bench.monotonic_clock_end(start)
  let elapsed_s = elapsed_us / 1_000_000.0
  let ops_per_second = if elapsed_s <= 0.0 {
    0.0
  } else {
    iterations.to_double() / elapsed_s
  }
  println(
    "workload=" +
    name +
    ",iterations=" +
    iterations.to_string() +
    ",elapsed_us=" +
    elapsed_us.to_string() +
    ",ops_per_second=" +
    ops_per_second.to_string() +
    ",checksum=" +
    checksum.to_string(),
  )
}

///|
fn benchmark_tree(iterations : Int) -> Int {
  let segments : Array[@types.TrackSegment] = Array::new()
  for i = 0; i < 64; i = i + 1 {
    let start = (i * 250).to_double()
    segments.push(
      @types.TrackSegment::new(
        i,
        start,
        start + 250.0,
        30.0,
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
  let mut checksum = 0
  for i = 0; i < iterations; i = i + 1 {
    let position = (i % 16000).to_double()
    match tree.find_at(position) {
      Some(segment) => checksum = checksum + segment.segment_id
      None => ()
    }
  }
  checksum
}

///|
fn benchmark_packet(iterations : Int) -> Int {
  let parser = @balise.BaliseTelegramParser::new()
  let bytes = [
    0x00, 0x0C, 0x00, 0x05, 0x03, 0xE8, 0x13, 0x88, 0x05, 0x48, 0x64, 0x00, 0x10,
  ]
  let mut checksum = 0
  for i = 0; i < iterations; i = i + 1 {
    match parser.parse_packet_12(bytes, i.to_int64()) {
      Some(ma) => checksum = checksum + ma.ma_id
      None => ()
    }
  }
  checksum
}

///|
fn benchmark_braking(iterations : Int) -> Int {
  let integrator = @dynamics.BrakeIntegrator::new(
    @types.TrainParams::default_high_speed(),
  )
  let mut checksum = 0
  for _i = 0; _i < iterations; _i = _i + 1 {
    let curve = integrator.compute_ebd_curve(
      12000.0,
      0.0,
      1000.0,
      0.0,
      @types.RailCondition::from_int(1),
      5.0,
    )
    checksum = checksum + curve.points.length()
  }
  checksum
}

///|
fn benchmark_cycle(iterations : Int) -> Int {
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
  let input = @runtime.AtpCycleInput::new(
    1000.0, 20.0, odometer, 1000, state_a, state_b,
  )
  let engine = @runtime.AtpCycleEngine::new(
    @types.SystemConfig::default(),
    @types.TrainParams::default_high_speed(),
    0.5,
    1.0,
  )
  let mut checksum = 0
  for _i = 0; _i < iterations; _i = _i + 1 {
    let decision = engine.evaluate(
      input,
      ssp,
      @line_profile.TsrManager::new(),
      ma,
      @types.RailCondition::from_int(1),
    )
    checksum = checksum + decision.action.code()
  }
  checksum
}

///|
fn main {
  let tree_iterations = 20000
  let packet_iterations = 20000
  let braking_iterations = 100
  let cycle_iterations = 1000
  measure("segment_tree_query", tree_iterations, () => {
    benchmark_tree(tree_iterations)
  })
  measure("packet_12_decode", packet_iterations, () => {
    benchmark_packet(packet_iterations)
  })
  measure("ebd_curve", braking_iterations, () => {
    benchmark_braking(braking_iterations)
  })
  measure("full_atp_cycle", cycle_iterations, () => {
    benchmark_cycle(cycle_iterations)
  })
}
