// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// RadioChannelQuality holds LTE-R / GSM-R signal metrics for RBC handover decisions.
pub struct RadioChannelQuality {
  rsrp_dbm : Double // Reference Signal Received Power
  rsrq_db : Double // Reference Signal Received Quality
  sinr_db : Double // Signal to Interference plus Noise Ratio
  handover_in_progress : Bool
} derive(Eq, Debug)

///|
pub fn RadioChannelQuality::new(
  rsrp : Double,
  rsrq : Double,
  sinr : Double,
) -> RadioChannelQuality {
  { rsrp_dbm: rsrp, rsrq_db: rsrq, sinr_db: sinr, handover_in_progress: false }
}

///|
pub fn RadioChannelQuality::is_usable(self : RadioChannelQuality) -> Bool {
  self.rsrp_dbm >= -110.0 && self.sinr_db >= -3.0
}
