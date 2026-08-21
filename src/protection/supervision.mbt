// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SupervisionEngine computes speed limits and dynamic braking curves at current position s.
pub struct SupervisionEngine {
  config : @types.SystemConfig
  params : @types.TrainParams
  integrator : @dynamics.BrakeIntegrator
} derive(Eq, Debug)

///|
pub fn SupervisionEngine::new(
  config : @types.SystemConfig,
  params : @types.TrainParams
) -> SupervisionEngine {
  {
    config,
    params,
    integrator: @dynamics.BrakeIntegrator::new(params),
  }
}

///|
/// Calculate ProtectionThresholds for train at front position s.
pub fn SupervisionEngine::calculate_thresholds(
  self : SupervisionEngine,
  train_pos : Double,
  ssp : @line_profile.StaticSpeedProfile,
  tsr_mgr : @line_profile.TsrManager,
  ma_resolver : @line_profile.MaResolver,
  now_ms : Int64,
  rail : @types.RailCondition
) -> @types.ProtectionThresholds {
  let ssp_limit = ssp.get_effective_limit(train_pos)
  let tsr_limit = tsr_mgr.get_tsr_limit_at(train_pos)
  let permitted = if tsr_limit < ssp_limit { tsr_limit } else { ssp_limit }

  // Check EOA restriction
  let eoa = ma_resolver.get_active_eoa(now_ms)
  let eoa_margin = match eoa {
    Some(pos) => pos - train_pos
    None => 0.0
  }

  // Calculate dynamic curve limits if target speed at EOA is zero
  let grad = ssp.get_gradient(train_pos)
  let warn = permitted + self.config.overspeed_warn_margin
  let sbd_speed = permitted + self.config.service_brake_margin
  let ebd_speed = permitted + self.config.emergency_brake_margin
  let trip_speed = permitted + self.config.trip_margin

  if eoa_margin > 0.0 && eoa_margin < 2000.0 {
    let ebd_curve = self.integrator.compute_ebd_curve(
      eoa.unwrap(),
      0.0,
      train_pos,
      grad,
      rail,
      5.0
    )
    let sbd_curve = self.integrator.compute_sbd_curve(
      eoa.unwrap(),
      0.0,
      train_pos,
      grad,
      rail,
      5.0
    )

    let ebd_dynamic_v = get_curve_v_at(ebd_curve, train_pos)
    let sbd_dynamic_v = get_curve_v_at(sbd_curve, train_pos)

    let final_ebd = if ebd_dynamic_v < ebd_speed { ebd_dynamic_v } else { ebd_speed }
    let final_sbd = if sbd_dynamic_v < sbd_speed { sbd_dynamic_v } else { sbd_speed }
    let final_warn = if final_sbd - 0.5 < warn { final_sbd - 0.5 } else { warn }
    let final_perm = if final_warn - 0.5 < permitted { final_warn - 0.5 } else { permitted }

    @types.ProtectionThresholds::new(
      train_pos,
      if final_perm < 0.0 { 0.0 } else { final_perm },
      if final_warn < 0.0 { 0.0 } else { final_warn },
      if final_sbd < 0.0 { 0.0 } else { final_sbd },
      if final_ebd < 0.0 { 0.0 } else { final_ebd },
      trip_speed,
      eoa_margin
    )
  } else {
    @types.ProtectionThresholds::new(
      train_pos,
      permitted,
      warn,
      sbd_speed,
      ebd_speed,
      trip_speed,
      eoa_margin
    )
  }
}

///|
fn get_curve_v_at(curve : @types.DynamicBrakeCurve, pos : Double) -> Double {
  let pts = curve.points
  if pts.length() == 0 {
    return 1000.0
  }
  for i = 0; i < pts.length(); i = i + 1 {
    if (pts[i].position - pos).abs() <= 5.0 || pts[i].position <= pos {
      return pts[i].speed
    }
  }
  pts[0].speed
}
