// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SimulationSummary collects test run metrics across all simulation environments.
pub struct SimulationSummary {
  sim_name : String
  total_steps : Int
  max_speed_reached : Double
  min_margin_to_eoa : Double
  alerts_count : Int
  safety_contract_passed : Bool
} derive(Eq, Debug)

///|
pub fn SimulationSummary::new(
  name : String,
  steps : Int,
  max_v : Double,
  min_margin : Double,
  alerts : Int,
  passed : Bool,
) -> SimulationSummary {
  {
    sim_name: name,
    total_steps: steps,
    max_speed_reached: max_v,
    min_margin_to_eoa: min_margin,
    alerts_count: alerts,
    safety_contract_passed: passed,
  }
}

///|
pub fn run_all_simulations() -> Array[SimulationSummary] {
  let summaries : Array[SimulationSummary] = Array::new()

  // 1. High speed sim
  let hs = HighSpeedSimulation::new()
  let hs_ma = @types.MovementAuthority::new(
    1, 0, 0.0, 45000.0, 50.0, 0.0, 97.22,
  )
  hs.ma_resolver.update_ma(hs_ma, 1000)
  let (hs_thresh, hs_state) = hs.run_step(10000.0, 90.0, 2000)
  let hs_contract = @spec.verify_no_eoa_overstep_contract(
    10000.0, 90.0, 1.2, 45000.0, 0.8,
  )
  summaries.push(
    SimulationSummary::new(
      "HighSpeedRail350",
      100,
      hs_thresh.permitted_speed,
      hs_thresh.margin_to_eoa,
      hs.fsm.get_alerts().length(),
      hs_contract && hs_state != @types.ATPState::from_int(7),
    ),
  )

  // 2. Metro sim
  let metro = MetroSimulation::new()
  let metro_ma = @types.MovementAuthority::new(
    2, 0, 0.0, 5000.0, 20.0, 0.0, 22.22,
  )
  metro.ma_resolver.update_ma(metro_ma, 1000)
  let (metro_thresh, metro_state) = metro.run_step(2000.0, 20.0, 2000)
  let metro_contract = @spec.verify_no_eoa_overstep_contract(
    2000.0, 20.0, 1.3, 5000.0, 0.5,
  )
  summaries.push(
    SimulationSummary::new(
      "MetroCBTC80",
      100,
      metro_thresh.permitted_speed,
      metro_thresh.margin_to_eoa,
      metro.fsm.get_alerts().length(),
      metro_contract && metro_state != @types.ATPState::from_int(7),
    ),
  )

  // 3. Freight sim
  let freight = FreightSimulation::new()
  let freight_ma = @types.MovementAuthority::new(
    3, 0, 0.0, 20000.0, 100.0, 0.0, 25.0,
  )
  freight.ma_resolver.update_ma(freight_ma, 1000)
  let (freight_thresh, freight_state) = freight.run_step(5000.0, 22.0, 2000)
  let freight_contract = @spec.verify_no_eoa_overstep_contract(
    5000.0, 22.0, 0.65, 20000.0, 2.2,
  )
  summaries.push(
    SimulationSummary::new(
      "HeavyHaulFreight90",
      100,
      freight_thresh.permitted_speed,
      freight_thresh.margin_to_eoa,
      freight.fsm.get_alerts().length(),
      freight_contract && freight_state != @types.ATPState::from_int(7),
    ),
  )

  // 4. Mountain sim
  let mountain = MountainRailSimulation::new()
  let mountain_ma = @types.MovementAuthority::new(
    4, 0, 0.0, 15000.0, 30.0, 0.0, 33.33,
  )
  mountain.ma_resolver.update_ma(mountain_ma, 1000)
  let (mountain_thresh, mountain_state) = mountain.run_step(6000.0, 25.0, 2000)
  let mountain_contract = @spec.verify_no_eoa_overstep_contract(
    6000.0, 25.0, 1.0, 15000.0, 1.0,
  )
  summaries.push(
    SimulationSummary::new(
      "MountainRail120",
      100,
      mountain_thresh.permitted_speed,
      mountain_thresh.margin_to_eoa,
      mountain.fsm.get_alerts().length(),
      mountain_contract && mountain_state != @types.ATPState::from_int(7),
    ),
  )

  // 5. Tunnel sim
  let tunnel = TunnelSimulation::new()
  let tunnel_ma = @types.MovementAuthority::new(
    5, 0, 0.0, 20000.0, 40.0, 0.0, 69.44,
  )
  tunnel.ma_resolver.update_ma(tunnel_ma, 1000)
  let (tunnel_thresh, tunnel_state) = tunnel.run_step(7000.0, 65.0, 2000)
  let tunnel_contract = @spec.verify_no_eoa_overstep_contract(
    7000.0, 65.0, 1.1, 20000.0, 0.9,
  )
  summaries.push(
    SimulationSummary::new(
      "TunnelPassage250",
      100,
      tunnel_thresh.permitted_speed,
      tunnel_thresh.margin_to_eoa,
      tunnel.fsm.get_alerts().length(),
      tunnel_contract && tunnel_state != @types.ATPState::from_int(7),
    ),
  )

  // 6. Tram sim
  let tram = UrbanTramSimulation::new()
  let tram_ma = @types.MovementAuthority::new(
    6, 0, 0.0, 4000.0, 10.0, 0.0, 13.89,
  )
  tram.ma_resolver.update_ma(tram_ma, 1000)
  let (tram_thresh, tram_state) = tram.run_step(1000.0, 10.0, 2000)
  let tram_contract = @spec.verify_no_eoa_overstep_contract(
    1000.0, 10.0, 1.4, 4000.0, 0.4,
  )
  summaries.push(
    SimulationSummary::new(
      "UrbanTram50",
      100,
      tram_thresh.permitted_speed,
      tram_thresh.margin_to_eoa,
      tram.fsm.get_alerts().length(),
      tram_contract && tram_state != @types.ATPState::from_int(7),
    ),
  )

  // 7. Heavy freight mountain sim
  let hfm = HeavyFreightMountainSimulation::new()
  let hfm_ma = @types.MovementAuthority::new(
    7, 0, 0.0, 20000.0, 80.0, 0.0, 22.22,
  )
  hfm.ma_resolver.update_ma(hfm_ma, 1000)
  let (hfm_thresh, hfm_state) = hfm.run_step(8000.0, 18.0, 2000)
  let hfm_contract = @spec.verify_no_eoa_overstep_contract(
    8000.0, 18.0, 0.6, 20000.0, 2.5,
  )
  summaries.push(
    SimulationSummary::new(
      "HeavyFreightMountain25",
      100,
      hfm_thresh.permitted_speed,
      hfm_thresh.margin_to_eoa,
      hfm.fsm.get_alerts().length(),
      hfm_contract && hfm_state != @types.ATPState::from_int(7),
    ),
  )

  // 8. Blizzard sim
  let ewb = ExtremeWeatherBlizzardSimulation::new()
  let ewb_ma = @types.MovementAuthority::new(
    8, 0, 0.0, 30000.0, 60.0, 0.0, 55.56,
  )
  ewb.ma_resolver.update_ma(ewb_ma, 1000)
  let (ewb_thresh, ewb_state) = ewb.run_step(12000.0, 45.0, 2000)
  let ewb_contract = @spec.verify_no_eoa_overstep_contract(
    12000.0, 45.0, 0.5, 30000.0, 1.8,
  )
  summaries.push(
    SimulationSummary::new(
      "ExtremeWeatherBlizzard200",
      100,
      ewb_thresh.permitted_speed,
      ewb_thresh.margin_to_eoa,
      ewb.fsm.get_alerts().length(),
      ewb_contract && ewb_state != @types.ATPState::from_int(7),
    ),
  )

  // 9. Crosswind sim
  let hsc = HighSpeedCrosswindSimulation::new()
  let hsc_ma = @types.MovementAuthority::new(
    9, 0, 0.0, 50000.0, 100.0, 0.0, 97.22,
  )
  hsc.ma_resolver.update_ma(hsc_ma, 1000)
  let (hsc_thresh, hsc_state) = hsc.run_step(18000.0, 50.0, 2000)
  let hsc_contract = @spec.verify_no_eoa_overstep_contract(
    18000.0, 50.0, 1.2, 50000.0, 0.8,
  )
  summaries.push(
    SimulationSummary::new(
      "HighSpeedCrosswind350",
      100,
      hsc_thresh.permitted_speed,
      hsc_thresh.margin_to_eoa,
      hsc.fsm.get_alerts().length(),
      hsc_contract && hsc_state != @types.ATPState::from_int(7),
    ),
  )

  // 10. Heavy haul coal line sim
  let hhc = HeavyHaulCoalLineSimulation::new()
  let hhc_ma = @types.MovementAuthority::new(
    10, 0, 0.0, 40000.0, 120.0, 0.0, 25.0,
  )
  hhc.ma_resolver.update_ma(hhc_ma, 1000)
  let (hhc_thresh, hhc_state) = hhc.run_step(15000.0, 20.0, 2000)
  let hhc_contract = @spec.verify_no_eoa_overstep_contract(
    15000.0, 20.0, 0.6, 40000.0, 2.0,
  )
  summaries.push(
    SimulationSummary::new(
      "HeavyHaulCoalLine90",
      100,
      hhc_thresh.permitted_speed,
      hhc_thresh.margin_to_eoa,
      hhc.fsm.get_alerts().length(),
      hhc_contract && hhc_state != @types.ATPState::from_int(7),
    ),
  )

  // 11. Subway dense headway sim
  let sdh = SubwayDenseHeadwaySimulation::new()
  let sdh_ma = @types.MovementAuthority::new(
    11, 0, 0.0, 8000.0, 15.0, 0.0, 22.22,
  )
  sdh.ma_resolver.update_ma(sdh_ma, 1000)
  let (sdh_thresh, sdh_state) = sdh.run_step(3000.0, 18.0, 2000)
  let sdh_contract = @spec.verify_no_eoa_overstep_contract(
    3000.0, 18.0, 1.3, 8000.0, 0.5,
  )
  summaries.push(
    SimulationSummary::new(
      "SubwayDenseHeadway80",
      100,
      sdh_thresh.permitted_speed,
      sdh_thresh.margin_to_eoa,
      sdh.fsm.get_alerts().length(),
      sdh_contract && sdh_state != @types.ATPState::from_int(7),
    ),
  )

  summaries
}
