// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// EuroradioMessageType defines Subset-026 radio message IDs between RBC and onboard ATP.
pub enum EuroradioMsgType {
  Msg3MovementAuthority // RBC -> Train: MA update
  Msg8Acknowledge // Train -> RBC: MA acknowledgment
  Msg15PositionReport // Train -> RBC: Periodic position report
  Msg16PositionReportAck // RBC -> Train: Position report receipt
  Msg24GeneralMessage // General data packet
  Msg33RadioInfillMA // RBC -> Train: Radio infill MA
  Msg38InitiateSession // RBC <-> Train: Radio session handshake
} derive(Eq, Debug)

///|
pub fn EuroradioMsgType::from_code(code : Int) -> EuroradioMsgType {
  match code {
    3 => Msg3MovementAuthority
    8 => Msg8Acknowledge
    15 => Msg15PositionReport
    16 => Msg16PositionReportAck
    24 => Msg24GeneralMessage
    33 => Msg33RadioInfillMA
    _ => Msg38InitiateSession
  }
}

///|
/// RadioMessageHeader contains GSM-R / LTE-R session metadata.
pub struct RadioMessageHeader {
  msg_type : EuroradioMsgType
  rbc_id : Int
  train_id : Int
  seq_number : Int64
  timestamp_ms : Int64
  session_active : Bool
} derive(Eq, Debug)

///|
pub fn RadioMessageHeader::new(
  m_type : EuroradioMsgType,
  rbc : Int,
  train : Int,
  seq : Int64,
  ts : Int64,
  active : Bool,
) -> RadioMessageHeader {
  {
    msg_type: m_type,
    rbc_id: rbc,
    train_id: train,
    seq_number: seq,
    timestamp_ms: ts,
    session_active: active,
  }
}
