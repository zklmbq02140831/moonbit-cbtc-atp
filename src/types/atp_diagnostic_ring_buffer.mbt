// Copyright 2026 CBTC ATP Project Authors.
// Licensed under the Apache License, Version 2.0.

///|
/// DiagnosticRingBuffer maintains black box crashdump memory ring buffer.
pub struct DiagnosticRingBuffer {
  capacity : Int
  buffer : Array[BlackBoxEventRecord]
} derive(Eq, Debug)

///|
pub fn DiagnosticRingBuffer::new(cap : Int) -> DiagnosticRingBuffer {
  { capacity: cap, buffer: Array::new() }
}

///|
pub fn DiagnosticRingBuffer::push_record(
  self : DiagnosticRingBuffer,
  rec : BlackBoxEventRecord,
) -> Unit {
  if self.buffer.length() >= self.capacity {
    let _ = self.buffer.pop()
  }
  self.buffer.push(rec)
}

///|
pub fn DiagnosticRingBuffer::size(self : DiagnosticRingBuffer) -> Int {
  self.buffer.length()
}
