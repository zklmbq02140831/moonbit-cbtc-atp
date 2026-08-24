// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ValidationIssueCode identifies an input condition that prevents a safe cycle.
pub enum ValidationIssueCode {
  NegativePosition
  NegativeSpeed
  NegativeTimestamp
  InvalidOdometerBounds
  ChannelSpeedDisagreement
  ChannelPositionDisagreement
  NonFiniteInput
  TimestampRollback
  InvalidStaticSpeedProfile
  InvalidChannelTimestamp
  ChannelTimestampMismatch
  SharedTelemetryDisagreement
  MissingStaticSpeedCoverage
  InvalidConfiguration
  InvalidChannelOdometerBounds
  UnsupportedDirection
} derive(Eq, Debug)

///|
pub fn ValidationIssueCode::code(self : ValidationIssueCode) -> Int {
  match self {
    NegativePosition => 1
    NegativeSpeed => 2
    NegativeTimestamp => 3
    InvalidOdometerBounds => 4
    ChannelSpeedDisagreement => 5
    ChannelPositionDisagreement => 6
    NonFiniteInput => 7
    TimestampRollback => 8
    InvalidStaticSpeedProfile => 9
    InvalidChannelTimestamp => 10
    ChannelTimestampMismatch => 11
    SharedTelemetryDisagreement => 12
    MissingStaticSpeedCoverage => 13
    InvalidConfiguration => 14
    InvalidChannelOdometerBounds => 15
    UnsupportedDirection => 16
  }
}

///|
/// ValidationIssue is a stable, machine-readable input validation result.
pub struct ValidationIssue {
  code : ValidationIssueCode
} derive(Eq, Debug)

///|
pub fn ValidationIssue::new(code : ValidationIssueCode) -> ValidationIssue {
  { code, }
}

///|
/// AtpCycleInput is the immutable telemetry snapshot consumed by one ATP cycle.
pub struct AtpCycleInput {
  position_m : Double
  speed_mps : Double
  odometer : @types.OdometerBounds
  now_ms : Int64
  channel_state_a : @types.TrainState
  channel_state_b : @types.TrainState
} derive(Eq, Debug)

///|
pub fn AtpCycleInput::new(
  position_m : Double,
  speed_mps : Double,
  odometer : @types.OdometerBounds,
  now_ms : Int64,
  channel_state_a : @types.TrainState,
  channel_state_b : @types.TrainState,
) -> AtpCycleInput {
  { position_m, speed_mps, odometer, now_ms, channel_state_a, channel_state_b }
}

///|
/// AtpAction is the command-level result of one safety cycle.
pub enum AtpAction {
  Continue
  Warning
  ServiceBrake
  EmergencyBrake
  FailSafeTrip
} derive(Eq, Debug)

///|
pub fn AtpAction::code(self : AtpAction) -> Int {
  match self {
    Continue => 1
    Warning => 2
    ServiceBrake => 3
    EmergencyBrake => 4
    FailSafeTrip => 5
  }
}

///|
/// AtpReasonCode explains why a decision was emitted.
pub enum AtpReasonCode {
  NormalCycle
  OverspeedWarning
  ServiceBrakeRequired
  EmergencyBrakeRequired
  TripBoundaryExceeded
  MovementAuthorityUnavailable
  InvalidInput
  HardwareFault
} derive(Eq, Debug)

///|
pub fn AtpReasonCode::code(self : AtpReasonCode) -> Int {
  match self {
    NormalCycle => 1
    OverspeedWarning => 2
    ServiceBrakeRequired => 3
    EmergencyBrakeRequired => 4
    TripBoundaryExceeded => 6
    MovementAuthorityUnavailable => 7
    InvalidInput => 8
    HardwareFault => 9
  }
}

///|
/// DecisionTrace exposes the values needed by a DMI, logger, or test harness.
pub struct DecisionTrace {
  position_m : Double
  permitted_speed : Double
  warning_speed : Double
  service_brake_speed : Double
  emergency_brake_speed : Double
  trip_speed : Double
  margin_to_eoa : Double
  state : @types.ATPState
  reason : AtpReasonCode
} derive(Eq, Debug)

///|
pub struct AtpCycleDecision {
  action : AtpAction
  trace : DecisionTrace
  issues : Array[ValidationIssue]
} derive(Eq, Debug)

///|
pub fn AtpCycleDecision::is_fail_safe(self : AtpCycleDecision) -> Bool {
  match self.action {
    FailSafeTrip => true
    _ => false
  }
}
