// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// ETCSLevel represents train control system operating level.
pub enum ETCSLevel {
  Level0 // Unfitted line
  Level1 // Balise-based intermittent ATP
  Level2 // Radio-based continuous CBTC / CTCS-3 ATP
  Level3 // Moving block radio ATP with train integrity
  LevelNtc // National Train Control (legacy)
} derive(Eq, Debug)

///|
pub fn ETCSLevel::from_int(code : Int) -> ETCSLevel {
  match code {
    0 => Level0
    1 => Level1
    2 => Level2
    3 => Level3
    _ => LevelNtc
  }
}

///|
/// NationalValues defines system safety factors broadcast by trackside.
pub struct NationalValues {
  nv_id : Int
  v_nvsupervision : Double // Maximum speed limit in unfitted mode (m/s)
  v_nvonsight : Double // OnSight mode ceiling speed (m/s)
  v_nvlimsuperv : Double // Limited supervision speed (m/s)
  v_nvshuntoffset : Double // Shunting mode ceiling speed (m/s)
  t_nvovtrp : Int64 // Overlap release timer (ms)
  d_nvovtrp : Double // Overlap distance (m)
  t_nvcontact : Int64 // Max communication loss time before trip (ms)
  m_nvcontact : Int // Communication loss reaction (0 = Train trip, 1 = Apply service brake)
  m_nvderun : Int // Driver entry reaction
} derive(Eq, Debug)

///|
pub fn NationalValues::default() -> NationalValues {
  {
    nv_id: 1,
    v_nvsupervision: 41.67, // 150 km/h
    v_nvonsight: 8.33, // 30 km/h
    v_nvlimsuperv: 27.78, // 100 km/h
    v_nvshuntoffset: 8.33, // 30 km/h
    t_nvovtrp: 60000,
    d_nvovtrp: 200.0,
    t_nvcontact: 5000,
    m_nvcontact: 0,
    m_nvderun: 1,
  }
}

///|
/// BaliseHeader defines standard Eurobalise telegram header fields.
pub struct BaliseHeader {
  q_updown : Int // 1 = Up link (track to train), 0 = Down link
  m_version : Int // System version
  q_media : Int // Media type (0 = Balise, 1 = Loop)
  n_pig : Int // Position in balise group (0..7)
  n_total : Int // Total balises in group
  m_dup : Int // Duplication status
  m_mcount : Int // Message count
  nid_c : Int // Country identifier
  nid_bg : Int // Balise group identifier
  q_link : Int // Link quality
} derive(Eq, Debug)

///|
pub fn BaliseHeader::new(
  q_updown : Int,
  m_version : Int,
  q_media : Int,
  n_pig : Int,
  n_total : Int,
  m_dup : Int,
  m_mcount : Int,
  nid_c : Int,
  nid_bg : Int,
  q_link : Int,
) -> BaliseHeader {
  {
    q_updown,
    m_version,
    q_media,
    n_pig,
    n_total,
    m_dup,
    m_mcount,
    nid_c,
    nid_bg,
    q_link,
  }
}
