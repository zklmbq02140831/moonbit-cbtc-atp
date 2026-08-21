// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ATPState represents SIL4 EN50128 safety state machine states.
pub enum ATPState {
  SystemInit
  Standby
  NormalOperating
  OverspeedWarning
  ServiceBrakingTriggered
  EmergencyBrakingTriggered
  EmergencyTrip
  HardwareFault
} derive(Eq, Debug)

///|
pub fn ATPState::from_int(code : Int) -> ATPState {
  match code {
    0 => SystemInit
    1 => Standby
    2 => NormalOperating
    3 => OverspeedWarning
    4 => ServiceBrakingTriggered
    5 => EmergencyBrakingTriggered
    6 => EmergencyTrip
    _ => HardwareFault
  }
}

///|
pub fn ATPState::severity_level(self : ATPState) -> Int {
  match self {
    SystemInit => 0
    Standby => 1
    NormalOperating => 2
    OverspeedWarning => 3
    ServiceBrakingTriggered => 4
    EmergencyBrakingTriggered => 5
    EmergencyTrip => 6
    HardwareFault => 7
  }
}

///|
/// ATPEvent defines inputs that trigger state transitions.
pub enum ATPEvent {
  SelfTestPass
  CabActivated
  CabDeactivated
  SpeedNormal
  OverspeedWarnDetected
  ServiceBrakeThresholdExceeded
  EmergencyBrakeThresholdExceeded
  TripBoundaryExceeded
  RollbackDetected
  MaExpired
  BaliseMissing
  HardwareFailSignal
  DriverAckPressed
  FullStopReached
  ResetCommandReceived
} derive(Eq, Debug)

///|
pub fn ATPEvent::from_code(code : Int) -> ATPEvent {
  match code {
    101 => SelfTestPass
    102 => CabActivated
    103 => CabDeactivated
    201 => SpeedNormal
    202 => OverspeedWarnDetected
    203 => ServiceBrakeThresholdExceeded
    204 => EmergencyBrakeThresholdExceeded
    205 => TripBoundaryExceeded
    301 => RollbackDetected
    302 => MaExpired
    303 => BaliseMissing
    401 => HardwareFailSignal
    501 => DriverAckPressed
    502 => FullStopReached
    _ => ResetCommandReceived
  }
}

///|
pub fn ATPEvent::code(self : ATPEvent) -> Int {
  match self {
    SelfTestPass => 101
    CabActivated => 102
    CabDeactivated => 103
    SpeedNormal => 201
    OverspeedWarnDetected => 202
    ServiceBrakeThresholdExceeded => 203
    EmergencyBrakeThresholdExceeded => 204
    TripBoundaryExceeded => 205
    RollbackDetected => 301
    MaExpired => 302
    BaliseMissing => 303
    HardwareFailSignal => 401
    DriverAckPressed => 501
    FullStopReached => 502
    ResetCommandReceived => 503
  }
}

///|
/// SystemConfig summarizes ATP kernel configuration constants.
pub struct SystemConfig {
  overspeed_warn_margin : Double // m/s (e.g. 1.38 m/s = 5 km/h)
  service_brake_margin : Double // m/s (e.g. 2.22 m/s = 8 km/h)
  emergency_brake_margin : Double // m/s (e.g. 2.78 m/s = 10 km/h)
  trip_margin : Double // m/s (e.g. 4.17 m/s = 15 km/h)
  ma_timeout_ms : Int64 // ms (e.g. 5000 ms)
  odometer_slip_limit : Double // max allowed slip ratio (e.g. 0.15)
  rollback_distance_limit : Double // meters (e.g. 0.5m)
  redundancy_mode_2o2 : Bool // True for 2-out-of-2 voting requirement
} derive(Eq, Debug)

///|
pub fn SystemConfig::default() -> SystemConfig {
  {
    overspeed_warn_margin: 1.38,
    service_brake_margin: 2.22,
    emergency_brake_margin: 2.78,
    trip_margin: 4.17,
    ma_timeout_ms: 5000,
    odometer_slip_limit: 0.15,
    rollback_distance_limit: 0.5,
    redundancy_mode_2o2: true,
  }
}
