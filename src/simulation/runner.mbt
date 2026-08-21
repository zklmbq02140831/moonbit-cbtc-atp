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

  summaries
}
