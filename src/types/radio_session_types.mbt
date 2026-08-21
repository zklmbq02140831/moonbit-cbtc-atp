// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// RadioSessionState represents EURORADIO GSM-R / LTE-R connection state.
pub enum RadioSessionState {
  Disconnected
  HandshakeInProgress
  SessionEstablished
  SessionDegraded
  SessionTerminated
} derive(Eq, Debug)

///|
pub fn RadioSessionState::from_code(code : Int) -> RadioSessionState {
  match code {
    0 => Disconnected
    1 => HandshakeInProgress
    2 => SessionEstablished
    3 => SessionDegraded
    _ => SessionTerminated
  }
}

///|
/// RadioSessionContext manages communication session keys and sequence counters.
pub struct RadioSessionContext {
  session_id : Int64
  rbc_identifier : Int
  mut session_state : RadioSessionState
  mut tx_seq_number : Int64
  mut rx_seq_number : Int64
  mut last_rx_timestamp_ms : Int64
} derive(Eq, Debug)

///|
pub fn RadioSessionContext::new(
  session_id : Int64,
  rbc_id : Int,
) -> RadioSessionContext {
  {
    session_id,
    rbc_identifier: rbc_id,
    session_state: Disconnected,
    tx_seq_number: 1,
    rx_seq_number: 0,
    last_rx_timestamp_ms: 0,
  }
}

///|
pub fn RadioSessionContext::update_state(
  self : RadioSessionContext,
  new_state : RadioSessionState,
  now_ms : Int64,
) -> Unit {
  self.session_state = new_state
  self.last_rx_timestamp_ms = now_ms
}

///|
pub fn RadioSessionContext::next_tx_seq(self : RadioSessionContext) -> Int64 {
  let seq = self.tx_seq_number
  self.tx_seq_number = self.tx_seq_number + 1
  seq
}

///|
pub fn RadioSessionContext::record_rx_seq(
  self : RadioSessionContext,
  rx_seq : Int64,
  now_ms : Int64,
) -> Unit {
  self.rx_seq_number = rx_seq
  self.last_rx_timestamp_ms = now_ms
}
