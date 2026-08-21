// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// CbtcVirtualBlock represents a virtual block / track circuit segment in a CBTC moving block system.
pub struct CbtcVirtualBlock {
  block_id : Int
  start_pos_m : Double
  end_pos_m : Double
  mut is_occupied : Bool
  mut occupying_train_id : Int
  mut axle_counter_count : Int
  mut cleared_by_interlocking : Bool
} derive(Eq, Debug)

///|
pub fn CbtcVirtualBlock::new(
  id : Int,
  start_m : Double,
  end_m : Double,
) -> CbtcVirtualBlock {
  {
    block_id: id,
    start_pos_m: start_m,
    end_pos_m: end_m,
    is_occupied: false,
    occupying_train_id: 0,
    axle_counter_count: 0,
    cleared_by_interlocking: true,
  }
}

///|
pub fn CbtcVirtualBlock::length_m(self : CbtcVirtualBlock) -> Double {
  self.end_pos_m - self.start_pos_m
}

///|
pub fn CbtcVirtualBlock::occupy(
  self : CbtcVirtualBlock,
  train_id : Int,
  axles : Int,
) -> Unit {
  self.is_occupied = true
  self.occupying_train_id = train_id
  self.axle_counter_count = axles
  self.cleared_by_interlocking = false
}

///|
pub fn CbtcVirtualBlock::release(self : CbtcVirtualBlock) -> Unit {
  self.is_occupied = false
  self.occupying_train_id = 0
  self.axle_counter_count = 0
  self.cleared_by_interlocking = true
}

///|
/// CbtcBlockManager manages contiguous virtual block track circuits along the line.
pub struct CbtcBlockManager {
  blocks : Array[CbtcVirtualBlock]
} derive(Eq, Debug)

///|
pub fn CbtcBlockManager::new(
  blocks : Array[CbtcVirtualBlock],
) -> CbtcBlockManager {
  { blocks, }
}

///|
pub fn CbtcBlockManager::find_block_at(
  self : CbtcBlockManager,
  pos_m : Double,
) -> CbtcVirtualBlock? {
  for i = 0; i < self.blocks.length(); i = i + 1 {
    let b = self.blocks[i]
    if pos_m >= b.start_pos_m && pos_m <= b.end_pos_m {
      return Some(b)
    }
  }
  None
}

///|
pub fn CbtcBlockManager::first_occupied_block_ahead(
  self : CbtcBlockManager,
  from_pos_m : Double,
) -> CbtcVirtualBlock? {
  for i = 0; i < self.blocks.length(); i = i + 1 {
    let b = self.blocks[i]
    if b.start_pos_m >= from_pos_m && b.is_occupied {
      return Some(b)
    }
  }
  None
}
