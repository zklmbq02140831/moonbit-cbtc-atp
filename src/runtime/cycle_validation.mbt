// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// Validate telemetry before any line or braking calculation is attempted.
pub fn AtpCycleInput::validate(
  self : AtpCycleInput,
  max_speed_diff_mps : Double,
  max_position_diff_m : Double,
) -> Array[ValidationIssue] {
  let issues : Array[ValidationIssue] = Array::new()

  if !cycle_value_is_finite(self.position_m) ||
    !cycle_value_is_finite(self.speed_mps) ||
    !cycle_value_is_finite(self.odometer.nominal_pos) ||
    !cycle_value_is_finite(self.odometer.min_pos) ||
    !cycle_value_is_finite(self.odometer.max_pos) ||
    !cycle_value_is_finite(self.odometer.confidence_margin) ||
    !cycle_value_is_finite(self.channel_state_a.speed) ||
    !cycle_value_is_finite(self.channel_state_a.acceleration) ||
    !cycle_value_is_finite(self.channel_state_a.odometer.nominal_pos) ||
    !cycle_value_is_finite(self.channel_state_a.odometer.min_pos) ||
    !cycle_value_is_finite(self.channel_state_a.odometer.max_pos) ||
    !cycle_value_is_finite(self.channel_state_a.odometer.confidence_margin) ||
    !cycle_value_is_finite(self.channel_state_b.speed) ||
    !cycle_value_is_finite(self.channel_state_b.acceleration) ||
    !cycle_value_is_finite(self.channel_state_b.odometer.nominal_pos) ||
    !cycle_value_is_finite(self.channel_state_b.odometer.min_pos) ||
    !cycle_value_is_finite(self.channel_state_b.odometer.max_pos) ||
    !cycle_value_is_finite(self.channel_state_b.odometer.confidence_margin) ||
    !cycle_value_is_finite(max_speed_diff_mps) ||
    !cycle_value_is_finite(max_position_diff_m) {
    issues.push(ValidationIssue::new(ValidationIssueCode::NonFiniteInput))
  }

  if self.position_m < 0.0 {
    issues.push(ValidationIssue::new(ValidationIssueCode::NegativePosition))
  }
  if self.speed_mps < 0.0 {
    issues.push(ValidationIssue::new(ValidationIssueCode::NegativeSpeed))
  }
  if self.now_ms < 0 {
    issues.push(ValidationIssue::new(ValidationIssueCode::NegativeTimestamp))
  }
  if self.odometer.min_pos > self.odometer.max_pos ||
    self.odometer.confidence_margin < 0.0 {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::InvalidOdometerBounds),
    )
  }
  if self.channel_state_a.odometer.min_pos >
    self.channel_state_a.odometer.max_pos ||
    self.channel_state_a.odometer.confidence_margin < 0.0 ||
    self.channel_state_b.odometer.min_pos >
    self.channel_state_b.odometer.max_pos ||
    self.channel_state_b.odometer.confidence_margin < 0.0 {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::InvalidChannelOdometerBounds),
    )
  }
  if self.channel_state_a.direction != 1 || self.channel_state_b.direction != 1 {
    issues.push(ValidationIssue::new(ValidationIssueCode::UnsupportedDirection))
  }

  let speed_diff = (self.channel_state_a.speed - self.channel_state_b.speed).abs()
  if speed_diff > max_speed_diff_mps {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::ChannelSpeedDisagreement),
    )
  }
  let position_diff = (self.channel_state_a.odometer.nominal_pos -
  self.channel_state_b.odometer.nominal_pos).abs()
  if position_diff > max_position_diff_m {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::ChannelPositionDisagreement),
    )
  }
  if (
      self.channel_state_a.timestamp_ms < 0 ||
      self.channel_state_b.timestamp_ms < 0
    ) &&
    self.now_ms >= 0 {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::InvalidChannelTimestamp),
    )
  }
  if self.channel_state_a.timestamp_ms != self.now_ms ||
    self.channel_state_b.timestamp_ms != self.now_ms {
    issues.push(
      ValidationIssue::new(ValidationIssueCode::ChannelTimestampMismatch),
    )
  }
  if speed_diff <= max_speed_diff_mps && position_diff <= max_position_diff_m {
    let top_speed_diff_a = (self.speed_mps - self.channel_state_a.speed).abs()
    let top_speed_diff_b = (self.speed_mps - self.channel_state_b.speed).abs()
    let top_position_diff_a = (self.position_m -
    self.channel_state_a.odometer.nominal_pos).abs()
    let top_position_diff_b = (self.position_m -
    self.channel_state_b.odometer.nominal_pos).abs()
    if top_speed_diff_a > max_speed_diff_mps ||
      top_speed_diff_b > max_speed_diff_mps ||
      top_position_diff_a > max_position_diff_m ||
      top_position_diff_b > max_position_diff_m {
      issues.push(
        ValidationIssue::new(ValidationIssueCode::SharedTelemetryDisagreement),
      )
    }
  }
  issues
}

///|
fn cycle_value_is_finite(value : Double) -> Bool {
  !value.is_nan() && !value.is_inf()
}
