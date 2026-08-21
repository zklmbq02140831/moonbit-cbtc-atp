// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// DmiAreaLayout defines screen coordinate bounds for ERA DMI layout areas (Area A - F).
pub struct DmiAreaLayout {
  area_a_speedometer_width : Int
  area_b_target_bar_height : Int
  area_c_driver_msg_rows : Int
  area_d_controls_active : Bool
  area_e_mode_icon_id : Int
  area_f_status_icon_id : Int
} derive(Eq, Debug)

///|
pub fn DmiAreaLayout::era_standard() -> DmiAreaLayout {
  {
    area_a_speedometer_width: 320,
    area_b_target_bar_height: 240,
    area_c_driver_msg_rows: 4,
    area_d_controls_active: true,
    area_e_mode_icon_id: 101,
    area_f_status_icon_id: 201,
  }
}
