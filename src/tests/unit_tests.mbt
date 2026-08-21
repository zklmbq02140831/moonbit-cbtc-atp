// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
test "track segment spatial boundaries and contains check" {
  let seg = @types.TrackSegment::new(
    1, 100.0, 500.0, 30.0, 5.0, 1000.0, false, 0, 0.0, 0.0,
  )
  inspect(seg.length(), content="400")
  inspect(seg.contains(250.0), content="true")
  inspect(seg.contains(50.0), content="false")
  inspect(seg.contains(600.0), content="false")
}

///|
test "switch state speed limit resolution" {
  let sw_norm = @types.TrackSwitch::new(
    10,
    1000.0,
    @types.SwitchPosition::from_int(1),
    35.0,
    15.0,
    true,
  )
  let sw_rev = @types.TrackSwitch::new(
    11,
    2000.0,
    @types.SwitchPosition::from_int(2),
    35.0,
    15.0,
    true,
  )
  let sw_mov = @types.TrackSwitch::new(
    12,
    3000.0,
    @types.SwitchPosition::from_int(3),
    35.0,
    15.0,
    false,
  )

  inspect(sw_norm.allowed_speed(), content="35")
  inspect(sw_rev.allowed_speed(), content="15")
  inspect(sw_mov.allowed_speed(), content="0")
}

///|
test "train physical mass and resistance properties" {
  let hs = @types.TrainParams::default_high_speed()
  let metro = @types.TrainParams::default_metro()
  let freight = @types.TrainParams::default_freight()

  inspect(hs.effective_mass_kg() > 485000.0, content="true")
  inspect(metro.effective_mass_kg() > 240000.0, content="true")
  inspect(freight.effective_mass_kg() > 5200000.0, content="true")
}

///|
test "adhesion model friction coefficient decay with speed" {
  let params = @types.TrainParams::default_high_speed()
  let adh = @dynamics.AdhesionModel::new(params)

  let mu_low = adh.calculate_coefficient(5.0, @types.RailCondition::from_int(1)) // 18 km/h
  let mu_high = adh.calculate_coefficient(
    90.0,
    @types.RailCondition::from_int(1),
  ) // 324 km/h
  let mu_wet = adh.calculate_coefficient(5.0, @types.RailCondition::from_int(2)) // Wet

  inspect(mu_low > mu_high, content="true")
  inspect(mu_wet < mu_low, content="true")
}

///|
test "davis train resistance quadratic growth" {
  let params = @types.TrainParams::default_metro()
  let davis = @dynamics.DavisCalculator::new(params)

  let r10 = davis.total_resistance_kn(10.0) // 36 km/h
  let r20 = davis.total_resistance_kn(20.0) // 72 km/h

  inspect(r20 > r10, content="true")
}

///|
test "gradient force acceleration and deceleration impact" {
  let grad_calc = @dynamics.GradientCalculator::new()
  let g_uphill = grad_calc.equivalent_acceleration(20.0) // 20‰ uphill
  let g_downhill = grad_calc.equivalent_acceleration(-20.0) // 20‰ downhill

  inspect(g_uphill > 0.0, content="true")
  inspect(g_downhill < 0.0, content="true")
}

///|
test "segment tree binary search spatial query precision" {
  let seg1 = @types.TrackSegment::new(
    1, 0.0, 1000.0, 30.0, 0.0, 0.0, false, 0, 0.0, 0.0,
  )
  let seg2 = @types.TrackSegment::new(
    2, 1000.0, 2500.0, 40.0, 5.0, 0.0, false, 0, 0.0, 0.0,
  )
  let seg3 = @types.TrackSegment::new(
    3, 2500.0, 5000.0, 25.0, -10.0, 500.0, false, 0, 0.0, 0.0,
  )

  let tree = @line_profile.SegmentTree::build([seg1, seg2, seg3])
  let res1 = tree.find_at(500.0)
  let res2 = tree.find_at(1800.0)
  let res3 = tree.find_at(3000.0)

  inspect(res1.unwrap().segment_id, content="1")
  inspect(res2.unwrap().segment_id, content="2")
  inspect(res3.unwrap().segment_id, content="3")
}

///|
test "TSR dynamic insertion and removal" {
  let tsr_mgr = @line_profile.TsrManager::new()
  let tsr1 = @types.TemporarySpeedRestriction::new(
    101, 1000.0, 3000.0, 15.0, true, 1,
  )

  tsr_mgr.add_tsr(tsr1)
  inspect(tsr_mgr.get_tsr_limit_at(1500.0), content="15")
  inspect(tsr_mgr.get_tsr_limit_at(500.0), content="1000")

  let removed = tsr_mgr.remove_tsr(101)
  inspect(removed, content="true")
  inspect(tsr_mgr.get_tsr_limit_at(1500.0), content="1000")
}

///|
test "Movement Authority EOA update and expiration watchdog" {
  let ma_res = @line_profile.MaResolver::new(5000) // 5s timeout
  let ma = @types.MovementAuthority::new(1, 1000, 0.0, 10000.0, 50.0, 0.0, 30.0)

  ma_res.update_ma(ma, 1000)
  inspect(ma_res.is_expired(2000), content="false")
  inspect(ma_res.get_active_eoa(2000).unwrap(), content="10000")
  inspect(ma_res.is_expired(7000), content="true")
}

///|
test "SIL4 state machine transition sequence" {
  let config = @types.SystemConfig::default()
  let fsm = @state_machine.AtpStateMachine::new(config)
  let odo = @types.OdometerBounds::new(100.0, 0.1, false, false)
  let tstate = @types.TrainState::new(
    1000,
    odo,
    20.0,
    0.0,
    @types.CabMode::from_int(1),
    1,
    false,
    false,
    false,
  )
  let thresh = @types.ProtectionThresholds::new(
    100.0, 20.0, 21.38, 22.22, 22.78, 24.17, 1000.0,
  )

  // 1. SelfTestPass -> Standby
  let st1 = fsm.transition(@types.ATPEvent::from_code(101), tstate, thresh)
  inspect(st1.severity_level(), content="1")

  // 2. CabActivated -> NormalOperating
  let st2 = fsm.transition(@types.ATPEvent::from_code(102), tstate, thresh)
  inspect(st2.severity_level(), content="2")

  // 3. OverspeedWarn -> OverspeedWarning
  let st3 = fsm.transition(@types.ATPEvent::from_code(202), tstate, thresh)
  inspect(st3.severity_level(), content="3")

  // 4. ServiceBrake -> ServiceBrakingTriggered
  let st4 = fsm.transition(@types.ATPEvent::from_code(203), tstate, thresh)
  inspect(st4.severity_level(), content="4")
}

///|
test "dual channel 2o2 voting channel agreement and failure trip" {
  let config = @types.SystemConfig::default()
  let voter = @state_machine.DualChannelVoter::new(config, 0.5, 1.0)
  let odo_a = @types.OdometerBounds::new(100.0, 0.1, false, false)
  let odo_b = @types.OdometerBounds::new(102.5, 0.1, false, false) // 2.5m diff > 1.0m allowed
  let state_a = @types.TrainState::new(
    1000,
    odo_a,
    20.0,
    0.0,
    @types.CabMode::from_int(1),
    1,
    false,
    false,
    false,
  )
  let state_b = @types.TrainState::new(
    1000,
    odo_b,
    20.0,
    0.0,
    @types.CabMode::from_int(1),
    1,
    false,
    false,
    false,
  )
  let thresh = @types.ProtectionThresholds::new(
    100.0, 20.0, 21.38, 22.22, 22.78, 24.17, 1000.0,
  )

  let res = voter.vote(
    @types.ATPEvent::from_code(201),
    @types.ATPEvent::from_code(201),
    state_a,
    state_b,
    thresh,
    thresh,
  )
  inspect(res.severity_level(), content="7") // HardwareFault
}

///|
test "balise telegram parsing packet 12 MA update" {
  let parser = @balise.BaliseTelegramParser::new()
  let bytes = [
    0x00, 0x0C, 0x00, 0x05, 0x03, 0xE8, 0x13, 0x88, 0x05, 0x48, 0x64, 0x00, 0x10,
  ]
  let ma_opt = parser.parse_packet_12(bytes, 1000)

  inspect(ma_opt is None, content="false")
  let ma = ma_opt.unwrap()
  inspect(ma.ma_id, content="5")
  inspect(ma.start_position, content="1000")
  inspect(ma.eoa_position, content="5000")
}

///|
test "formal spec contracts validation" {
  let c1 = @spec.verify_no_eoa_overstep_contract(1000.0, 30.0, 1.2, 5000.0, 1.0)
  let c2 = @spec.verify_deceleration_non_degradation_contract(
    1.2, 1.1, 80.0, 50.0,
  )
  let c3 = @spec.verify_state_escalation_monotonicity_contract(
    @types.ATPState::from_int(2),
    @types.ATPState::from_int(4),
  )
  let bounds = @types.OdometerBounds::new(1000.0, 2.0, false, false)
  let c4 = @spec.verify_odometer_bounds_contract(bounds, 0.5)

  inspect(c1, content="true")
  inspect(c2, content="true")
  inspect(c3, content="true")
  inspect(c4, content="true")
}

///|
test "full simulation runner scenario execution" {
  let summaries = @simulation.run_all_simulations()
  inspect(summaries.length(), content="3")
  inspect(summaries[0].safety_contract_passed, content="true")
  inspect(summaries[1].safety_contract_passed, content="true")
  inspect(summaries[2].safety_contract_passed, content="true")
}
