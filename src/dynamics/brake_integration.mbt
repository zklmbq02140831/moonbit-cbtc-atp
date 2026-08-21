// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// BrakeIntegrator performs dynamic multi-stage backward integration of train speed curves.
pub struct BrakeIntegrator {
  params : @types.TrainParams
  adhesion : AdhesionModel
  davis : DavisCalculator
  gradient : GradientCalculator
} derive(Eq, Debug)

///|
pub fn BrakeIntegrator::new(params : @types.TrainParams) -> BrakeIntegrator {
  {
    params,
    adhesion: AdhesionModel::new(params),
    davis: DavisCalculator::new(params),
    gradient: GradientCalculator::new(),
  }
}

///|
/// Calculate total effective deceleration at position s, speed v, and brake mode.
pub fn BrakeIntegrator::effective_deceleration(
  self : BrakeIntegrator,
  speed_mps : Double,
  gradient_per_thousand : Double,
  rail : @types.RailCondition,
  is_emergency : Bool,
  brake_phase_ratio : Double, // 0.0 to 1.0 representing brake pressure build-up
) -> Double {
  let base_decel = if is_emergency {
    self.params.emergency_brake_decel_base
  } else {
    self.params.service_brake_decel_base
  }
  let max_adh_decel = self.adhesion.max_adhesion_deceleration(speed_mps, rail)
  let mut mechanical_decel = base_decel * brake_phase_ratio
  if mechanical_decel > max_adh_decel {
    mechanical_decel = max_adh_decel
  }
  let resistance_decel = self.davis.resistance_deceleration(speed_mps)
  let grad_accel = self.gradient.equivalent_acceleration(gradient_per_thousand)
  let total = mechanical_decel + resistance_decel - grad_accel
  if total < 0.1 {
    0.1
  } else {
    total
  }
}

///|
/// Compute backward integration for Emergency Braking Distance (EBD) curve from target position backwards.
pub fn BrakeIntegrator::compute_ebd_curve(
  self : BrakeIntegrator,
  target_pos : Double,
  target_speed : Double,
  start_pos : Double,
  gradient_per_thousand : Double,
  rail : @types.RailCondition,
  step_ds : Double,
) -> @types.DynamicBrakeCurve {
  let curve = @types.DynamicBrakeCurve::new("EBD", target_pos, target_speed)
  if start_pos >= target_pos {
    return curve
  }
  let delay = self.params.emergency_brake_delay_s
  let build_t = self.params.emergency_brake_build_time_s
  let mut curr_pos = target_pos
  let mut curr_v = target_speed
  let mut accum_t = 0.0

  curve.add_point(
    @types.CurvePoint::new(
      curr_pos,
      curr_v,
      self.effective_deceleration(
        curr_v, gradient_per_thousand, rail, true, 1.0,
      ),
      0.0,
    ),
  )

  while curr_pos > start_pos {
    curr_pos = curr_pos - step_ds
    if curr_pos < start_pos {
      curr_pos = start_pos
    }
    let decel = self.effective_deceleration(
      curr_v, gradient_per_thousand, rail, true, 1.0,
    )
    let v_next_sq = curr_v * curr_v + 2.0 * decel * step_ds
    let v_next = v_next_sq.sqrt()
    let avg_v = (curr_v + v_next) / 2.0
    let dt = step_ds / (if avg_v < 0.1 { 0.1 } else { avg_v })
    accum_t = accum_t + dt
    curr_v = v_next
    curve.add_point(@types.CurvePoint::new(curr_pos, curr_v, decel, accum_t))
  }

  let delay_margin = curr_v * delay + 0.5 * curr_v * build_t
  curve.set_total_distance(target_pos - start_pos + delay_margin)
  curve
}

///|
/// Compute backward integration for Service Braking Distance (SBD) curve.
pub fn BrakeIntegrator::compute_sbd_curve(
  self : BrakeIntegrator,
  target_pos : Double,
  target_speed : Double,
  start_pos : Double,
  gradient_per_thousand : Double,
  rail : @types.RailCondition,
  step_ds : Double,
) -> @types.DynamicBrakeCurve {
  let curve = @types.DynamicBrakeCurve::new("SBD", target_pos, target_speed)
  if start_pos >= target_pos {
    return curve
  }
  let delay = self.params.service_brake_delay_s
  let build_t = self.params.service_brake_build_time_s
  let mut curr_pos = target_pos
  let mut curr_v = target_speed
  let mut accum_t = 0.0

  curve.add_point(
    @types.CurvePoint::new(
      curr_pos,
      curr_v,
      self.effective_deceleration(
        curr_v, gradient_per_thousand, rail, false, 1.0,
      ),
      0.0,
    ),
  )

  while curr_pos > start_pos {
    curr_pos = curr_pos - step_ds
    if curr_pos < start_pos {
      curr_pos = start_pos
    }
    let decel = self.effective_deceleration(
      curr_v, gradient_per_thousand, rail, false, 1.0,
    )
    let v_next_sq = curr_v * curr_v + 2.0 * decel * step_ds
    let v_next = v_next_sq.sqrt()
    let avg_v = (curr_v + v_next) / 2.0
    let dt = step_ds / (if avg_v < 0.1 { 0.1 } else { avg_v })
    accum_t = accum_t + dt
    curr_v = v_next
    curve.add_point(@types.CurvePoint::new(curr_pos, curr_v, decel, accum_t))
  }

  let delay_margin = curr_v * delay + 0.5 * curr_v * build_t
  curve.set_total_distance(target_pos - start_pos + delay_margin)
  curve
}
