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

  let st1 = fsm.transition(@types.ATPEvent::from_code(101), tstate, thresh)
  inspect(st1.severity_level(), content="1")

  let st2 = fsm.transition(@types.ATPEvent::from_code(102), tstate, thresh)
  inspect(st2.severity_level(), content="2")

  let st3 = fsm.transition(@types.ATPEvent::from_code(202), tstate, thresh)
  inspect(st3.severity_level(), content="3")

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
test "physics unit conversions speed distance acceleration" {
  let spd = @types.Speed::from_kmh(360.0)
  inspect(spd.to_mps(), content="100")
  inspect(spd.to_kmh(), content="360")

  let dist = @types.Distance::from_km(2.5)
  inspect(dist.to_meters(), content="2500")

  let mass = @types.Mass::from_tonnes(500.0)
  inspect(mass.to_kg(), content="500000")
}

///|
test "hardware sensor diagnostics status check" {
  let sensor = @types.HardwareSensorStatus::healthy_default()
  inspect(sensor.is_all_healthy(), content="true")
}

///|
test "pneumatic brake pipe wave propagation delay" {
  let wave_model = @dynamics.AirBrakePipeWaveModel::new()
  let delay_head = wave_model.propagation_delay_s(0.0)
  let delay_tail = wave_model.propagation_delay_s(520.0)

  inspect(delay_head, content="0")
  inspect(delay_tail > 1.9, content="true")
}

///|
test "traction motor force speed envelope" {
  let params = @types.TrainParams::default_high_speed()
  let trac = @dynamics.TractionEnvelopeCalculator::new(params)

  let f_low = trac.max_traction_force_kn(5.0)
  let f_high = trac.max_traction_force_kn(80.0)

  inspect(f_low, content="300")
  inspect(f_high < f_low, content="true")
}

///|
test "rollback detector unintended reverse movement" {
  let rb = @protection.RollbackDetector::new(0.5) // 0.5m limit
  rb.set_standby_position(1000.0)

  let ok_move = rb.check_movement(999.7, 1) // 0.3m reverse < 0.5m limit
  let alarm_move = rb.check_movement(999.3, 1) // 0.7m reverse > 0.5m limit

  inspect(ok_move, content="false")
  inspect(alarm_move, content="true")
}

///|
test "equivalent gradient smoothing over train length" {
  let grads = [
    @types.GradientSegment::new(0.0, 100.0, 0.0),
    @types.GradientSegment::new(100.0, 300.0, 20.0),
  ]
  let eval = @line_profile.GradientProfileEvaluator::new(grads)
  let i_equiv = eval.equivalent_gradient_over_length(200.0, 200.0, 10.0)

  inspect(i_equiv > 0.0, content="true")
  inspect(i_equiv < 20.0, content="true")
}

///|
test "track circuit code map TVM430 resolution" {
  let map = @line_profile.TrackCircuitCodeMap::new(
    @types.TrackCircuitCodeRate::default_tvm430_table(),
  )
  let v_29hz = map.resolve_speed_limit_mps(29.0)
  let v_15hz = map.resolve_speed_limit_mps(15.9)

  inspect(v_29hz > 90.0, content="true")
  inspect(v_15hz > 40.0, content="true")
}

///|
test "brake force blending allocator" {
  let allocator = @dynamics.BrakeForceAllocator::new(150.0, 200.0)
  let (elec, pneu) = allocator.allocate(250.0, 20.0) // 250 kN total requested

  inspect(elec, content="150")
  inspect(pneu, content="100")
}

///|
test "WSP anti-skid modulation response" {
  let wsp = @dynamics.WheelSlideProtector::new(0.12)
  let ratio_normal = wsp.evaluate_wsp_action(20.0, 20.0)
  let ratio_skid = wsp.evaluate_wsp_action(15.0, 20.0) // 25% slip > 12% limit

  inspect(ratio_normal, content="1")
  inspect(ratio_skid, content="0.3")
}

///|
test "target distance release speed calculation" {
  let tdc = @protection.TargetDistanceCalculator::new()
  let v_rel_near = tdc.calculate_release_speed_mps(15.0)
  let v_rel_far = tdc.calculate_release_speed_mps(200.0)

  inspect(v_rel_near > 4.0, content="true")
  inspect(v_rel_far > v_rel_near, content="true")
}

///|
test "radio session state context sequence tracking" {
  let ctx = @types.RadioSessionContext::new(1001, 5)
  let seq1 = ctx.next_tx_seq()
  let seq2 = ctx.next_tx_seq()

  inspect(seq1, content="1")
  inspect(seq2, content="2")
}

///|
test "cbtc virtual block occupancy management" {
  let b = @line_profile.CbtcVirtualBlock::new(101, 100.0, 500.0)
  b.occupy(201, 8)
  inspect(b.is_occupied, content="true")

  b.release()
  inspect(b.is_occupied, content="false")
}

///|
test "thermal brake disc temperature and fade factor" {
  let thermal = @dynamics.ThermalBrakeFadeModel::new()
  let temp = thermal.update_temperature(200.0, 30.0, 10.0)
  let fade = thermal.fade_multiplier()

  inspect(temp > 20.0, content="true")
  inspect(fade <= 1.0, content="true")
}

///|
test "catenary voltage derating factor" {
  let cat = @dynamics.CatenaryPowerEnvelope::ac_25kv()
  let f_full = cat.voltage_derating_factor(25000.0)
  let f_low = cat.voltage_derating_factor(22000.0)

  inspect(f_full, content="1")
  inspect(f_low < 1.0, content="true")
}

///|
test "emergency trip relay manager reset guard" {
  let trip_mgr = @protection.EmergencyTripManager::new()
  trip_mgr.trigger_trip()
  inspect(trip_mgr.is_tripped(), content="true")

  let reset_fail = trip_mgr.attempt_reset(5.0) // Failed reset while moving at 5 m/s
  inspect(reset_fail, content="false")

  trip_mgr.register_driver_ack()
  let reset_ok = trip_mgr.attempt_reset(0.0) // Reset succeeds at full stop (0 m/s) with driver ack
  inspect(reset_ok, content="true")
}

///|
test "unintended movement protection watchdog" {
  let ump = @protection.UnintendedMovementProtection::new()
  ump.arm_protection(500.0)

  let safe_move = ump.check_unintended_movement(500.2) // 0.2m move <= 0.5m
  let trip_move = ump.check_unintended_movement(500.8) // 0.8m move > 0.5m

  inspect(safe_move, content="false")
  inspect(trip_move, content="true")
}

///|
test "full 11 scenario simulation runner execution" {
  let summaries = @simulation.run_all_simulations()
  inspect(summaries.length(), content="11")
  inspect(summaries[0].safety_contract_passed, content="true")
  inspect(summaries[1].safety_contract_passed, content="true")
  inspect(summaries[2].safety_contract_passed, content="true")
  inspect(summaries[3].safety_contract_passed, content="true")
  inspect(summaries[4].safety_contract_passed, content="true")
  inspect(summaries[5].safety_contract_passed, content="true")
  inspect(summaries[6].safety_contract_passed, content="true")
  inspect(summaries[7].safety_contract_passed, content="true")
  inspect(summaries[8].safety_contract_passed, content="true")
  inspect(summaries[9].safety_contract_passed, content="true")
  inspect(summaries[10].safety_contract_passed, content="true")
}
