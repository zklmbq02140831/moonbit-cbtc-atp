// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// SegmentNode represents a node in a spatial binary search tree over line track segments.
pub enum SegmentNode {
  Leaf(Array[@types.TrackSegment])
  Node(Double, SegmentNode, SegmentNode) // split_point, left_child, right_child
} derive(Eq, Debug)

///|
/// SegmentTree provides O(log N) lookup for track segments given a track position s.
pub struct SegmentTree {
  root : SegmentNode
  total_length : Double
} derive(Eq, Debug)

///|
pub fn SegmentTree::build(segments : Array[@types.TrackSegment]) -> SegmentTree {
  if segments.length() == 0 {
    return { root: Leaf([]), total_length: 0.0 }
  }
  let mut max_pos = 0.0
  for i = 0; i < segments.length(); i = i + 1 {
    if segments[i].end_position > max_pos {
      max_pos = segments[i].end_position
    }
  }
  let root = build_node(segments)
  { root, total_length: max_pos }
}

///|
fn build_node(segs : Array[@types.TrackSegment]) -> SegmentNode {
  if segs.length() <= 4 {
    return Leaf(segs)
  }
  let mut min_p = segs[0].start_position
  let mut max_p = segs[0].end_position
  for i = 1; i < segs.length(); i = i + 1 {
    if segs[i].start_position < min_p {
      min_p = segs[i].start_position
    }
    if segs[i].end_position > max_p {
      max_p = segs[i].end_position
    }
  }
  let mid = (min_p + max_p) / 2.0
  let left_segs : Array[@types.TrackSegment] = Array::new()
  let right_segs : Array[@types.TrackSegment] = Array::new()
  for i = 0; i < segs.length(); i = i + 1 {
    if segs[i].start_position <= mid {
      left_segs.push(segs[i])
    }
    if segs[i].end_position >= mid {
      right_segs.push(segs[i])
    }
  }
  if left_segs.length() == segs.length() || right_segs.length() == segs.length() {
    return Leaf(segs)
  }
  Node(mid, build_node(left_segs), build_node(right_segs))
}

///|
pub fn SegmentTree::find_at(
  self : SegmentTree,
  position : Double
) -> @types.TrackSegment? {
  query_node(self.root, position)
}

///|
fn query_node(
  node : SegmentNode,
  position : Double
) -> @types.TrackSegment? {
  match node {
    Leaf(segs) => {
      for i = 0; i < segs.length(); i = i + 1 {
        if segs[i].contains(position) {
          return Some(segs[i])
        }
      }
      None
    }
    Node(mid, left, right) =>
      if position <= mid {
        let res = query_node(left, position)
        match res {
          Some(_) => res
          None => query_node(right, position)
        }
      } else {
        let res = query_node(right, position)
        match res {
          Some(_) => res
          None => query_node(left, position)
        }
      }
  }
}

///|
pub fn SegmentTree::query_range(
  self : SegmentTree,
  start_pos : Double,
  end_pos : Double
) -> Array[@types.TrackSegment] {
  let result : Array[@types.TrackSegment] = Array::new()
  collect_range(self.root, start_pos, end_pos, result)
  result
}

///|
fn collect_range(
  node : SegmentNode,
  start_p : Double,
  end_p : Double,
  out : Array[@types.TrackSegment]
) -> Unit {
  match node {
    Leaf(segs) =>
      for i = 0; i < segs.length(); i = i + 1 {
        let s = segs[i]
        if s.end_position >= start_p && s.start_position <= end_p {
          let mut found = false
          for j = 0; j < out.length(); j = j + 1 {
            if out[j].segment_id == s.segment_id {
              found = true
              break
            }
          }
          if !found {
            out.push(s)
          }
        }
      }
    Node(mid, left, right) => {
      if start_p <= mid {
        collect_range(left, start_p, end_p, out)
      }
      if end_p >= mid {
        collect_range(right, start_p, end_p, out)
      }
    }
  }
}
