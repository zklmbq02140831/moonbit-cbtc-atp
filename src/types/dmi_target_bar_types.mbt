// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// DmiTargetBarGraphic maps distance-to-target onto ERA DMI logarithmic target bar graphic (0..4000m).
pub struct DmiTargetBarGraphic {
  distance_to_target_m : Double
  logarithmic_fill_ratio : Double // 0.0 (0m) to 1.0 (4000m)
  target_speed_mps : Double
  is_target_visible : Bool
} derive(Eq, Debug)

///|
pub fn DmiTargetBarGraphic::new(
  dist_m : Double,
  target_v : Double,
) -> DmiTargetBarGraphic {
  let ratio = if dist_m <= 0.0 {
    0.0
  } else if dist_m >= 4000.0 {
    1.0
  } else {
    // Logarithmic scaling formula for ERA DMI target distance bar
    (dist_m / 4000.0).sqrt()
  }

  {
    distance_to_target_m: dist_m,
    logarithmic_fill_ratio: ratio,
    target_speed_mps: target_v,
    is_target_visible: dist_m <= 4000.0,
  }
}
