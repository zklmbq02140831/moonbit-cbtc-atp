// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// TsrPacketProcessor processes Subset-026 Packet 65/66 messages and updates TsrManager.
pub struct TsrPacketProcessor {
  tsr_mgr : TsrManager
} derive(Eq, Debug)

///|
pub fn TsrPacketProcessor::new(tsrs : TsrManager) -> TsrPacketProcessor {
  { tsr_mgr: tsrs }
}

///|
pub fn TsrPacketProcessor::process_packet_65(
  self : TsrPacketProcessor,
  pkt65 : @types.TsrPacket65Data,
  current_train_pos_m : Double,
) -> Unit {
  let start_p = current_train_pos_m + pkt65.d_tsr_m
  let end_p = start_p + pkt65.l_tsr_m
  let tsr = @types.TemporarySpeedRestriction::new(
    pkt65.nid_tsr,
    start_p,
    end_p,
    pkt65.v_tsr_mps,
    true,
    1,
  )
  self.tsr_mgr.add_tsr(tsr)
}

///|
pub fn TsrPacketProcessor::process_packet_66(
  self : TsrPacketProcessor,
  pkt66 : @types.TsrRevokePacket66Data,
) -> Bool {
  self.tsr_mgr.remove_tsr(pkt66.nid_tsr)
}
