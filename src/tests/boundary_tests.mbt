// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
test "runtime accepts a consistent telemetry snapshot" {
  let odometer = @types.OdometerBounds::new(1000.0, 0.2, false, false)
  let state_a = @types.TrainState::new(
    2000,
    odometer,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let state_b = @types.TrainState::new(
    2000,
    odometer,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    1000.0, 25.0, odometer, 2000, state_a, state_b,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="0")
}

///|
test "runtime rejects negative position and speed" {
  let odometer = @types.OdometerBounds::new(0.0, 0.2, false, false)
  let state = @types.TrainState::new(
    2000,
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
    -1.0, -0.1, odometer, 2000, state, state,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="2")
  inspect(issues[0].code.code(), content="1")
  inspect(issues[1].code.code(), content="2")
}

///|
test "runtime rejects invalid timestamp and odometer bounds" {
  let odometer = @types.OdometerBounds::new(100.0, -1.0, false, false)
  let state = @types.TrainState::new(
    -1,
    odometer,
    10.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    100.0, 10.0, odometer, -1, state, state,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="3")
  inspect(issues[0].code.code(), content="3")
  inspect(issues[1].code.code(), content="4")
  inspect(issues[2].code.code(), content="15")
}

///|
test "runtime rejects two-channel position and speed disagreement" {
  let odometer_a = @types.OdometerBounds::new(1000.0, 0.2, false, false)
  let odometer_b = @types.OdometerBounds::new(1002.0, 0.2, false, false)
  let state_a = @types.TrainState::new(
    2000,
    odometer_a,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let state_b = @types.TrainState::new(
    2000,
    odometer_b,
    26.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    1000.0, 25.0, odometer_a, 2000, state_a, state_b,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="2")
  inspect(issues[0].code.code(), content="5")
  inspect(issues[1].code.code(), content="6")
}

///|
test "runtime rejects top level telemetry that disagrees with both channels" {
  let odometer = @types.OdometerBounds::new(1000.0, 0.2, false, false)
  let state = @types.TrainState::new(
    2000,
    odometer,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    1002.0, 30.0, odometer, 2000, state, state,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="1")
  inspect(issues[0].code.code(), content="12")
}

///|
test "runtime rejects invalid channel odometer bounds" {
  let valid_odometer = @types.OdometerBounds::new(1000.0, 0.2, false, false)
  let invalid_odometer = @types.OdometerBounds::new(1000.0, -1.0, false, false)
  let state_a = @types.TrainState::new(
    2000,
    invalid_odometer,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let state_b = @types.TrainState::new(
    2000,
    valid_odometer,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    1,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    1000.0, 25.0, valid_odometer, 2000, state_a, state_b,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="1")
  inspect(issues[0].code.code(), content="15")
}

///|
test "runtime rejects reverse and unknown directions" {
  let odometer = @types.OdometerBounds::new(1000.0, 0.2, false, false)
  let reverse = @types.TrainState::new(
    2000,
    odometer,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    -1,
    false,
    false,
    false,
  )
  let unknown = @types.TrainState::new(
    2000,
    odometer,
    25.0,
    0.0,
    @types.CabMode::from_int(2),
    0,
    false,
    false,
    false,
  )
  let input = @runtime.AtpCycleInput::new(
    1000.0, 25.0, odometer, 2000, reverse, unknown,
  )
  let issues = input.validate(0.5, 1.0)
  inspect(issues.length(), content="1")
  inspect(issues[0].code.code(), content="16")
}

///|
test "movement authority rejects a timestamp that moves backwards" {
  let resolver = @line_profile.MaResolver::new(5000)
  resolver.update_ma(
    @types.MovementAuthority::new(9, 1000, 0.0, 2000.0, 0.0, 0.0, 20.0),
    1000,
  )
  inspect(resolver.is_expired(999), content="true")
  inspect(resolver.get_active_eoa(999) is None, content="true")
}

///|
test "movement authority rejects a reversed authority envelope" {
  let resolver = @line_profile.MaResolver::new(5000)
  resolver.update_ma(
    @types.MovementAuthority::new(10, 1000, 2000.0, 1000.0, 0.0, 0.0, 20.0),
    1000,
  )
  inspect(resolver.get_active_eoa(1000) is None, content="true")
}

///|
test "invalid active speed restriction is fail safe" {
  let manager = @line_profile.TsrManager::new()
  manager.add_tsr(
    @types.TemporarySpeedRestriction::new(7, 100.0, 50.0, -2.0, true, 3),
  )
  inspect(manager.get_tsr_limit_at(75.0), content="0")
}

///|
test "segment tree honours exact endpoints and range de-duplication" {
  let first = @types.TrackSegment::new(
    1, 0.0, 100.0, 20.0, 0.0, 0.0, false, 0, 0.0, 0.0,
  )
  let second = @types.TrackSegment::new(
    2, 100.0, 200.0, 15.0, 0.0, 0.0, false, 0, 0.0, 0.0,
  )
  let tree = @line_profile.SegmentTree::build([first, second])
  inspect(tree.find_at(0.0) is Some(_), content="true")
  inspect(tree.find_at(200.0) is Some(_), content="true")
  inspect(tree.query_range(50.0, 150.0).length(), content="2")
  inspect(tree.query_range(150.0, 50.0).length(), content="0")
}

///|
test "telegram decoders reject truncated and unknown packets" {
  let parser = @balise.BaliseTelegramParser::new()
  inspect(parser.parse_packet_12([0x00, 0x0C], 1000) is None, content="true")
  inspect(parser.parse_packet_27([0x00, 0x1B, 0x00]) is None, content="true")
  let decoder = @balise.EurobalisePacketDecoder::new()
  inspect(
    decoder.decode_packet_3_national_values([99, 0, 0, 0]) is None,
    content="true",
  )
  inspect(
    decoder.decode_packet_21_gradient([3, 0, 0, 0, 0, 0, 0, 0]) is None,
    content="true",
  )
}

///|
test "telegram decoders reject a corrupted checksum" {
  let parser = @balise.BaliseTelegramParser::new()
  let corrupted = [
    0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF3,
  ]
  inspect(parser.verify_checksum(corrupted), content="false")
  inspect(parser.parse_packet_12(corrupted, 1000) is None, content="true")
}

///|
test "emergency trip state remains latched after normal speed event" {
  let config = @types.SystemConfig::default()
  let fsm = @state_machine.AtpStateMachine::new(config)
  let odometer = @types.OdometerBounds::new(100.0, 0.1, false, false)
  let state = @types.TrainState::new(
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
  let thresholds = @types.ProtectionThresholds::new(
    100.0, 10.0, 11.0, 12.0, 13.0, 14.0, 1000.0,
  )
  let _ = fsm.transition(@types.ATPEvent::from_code(101), state, thresholds)
  let _ = fsm.transition(@types.ATPEvent::from_code(102), state, thresholds)
  let _ = fsm.transition(@types.ATPEvent::from_code(205), state, thresholds)
  let final_state = fsm.transition(
    @types.ATPEvent::from_code(201),
    state,
    thresholds,
  )
  inspect(final_state.severity_level(), content="6")
}
