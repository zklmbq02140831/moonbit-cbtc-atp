# Benchmark report

This report records a local reference measurement of the deterministic ATP kernel. It is not a portability claim or a safety certification result.

## Environment

- Date: 2026-08-24
- OS: Microsoft Windows 10.0.26200, x64
- CPU environment: `Intel64 Family 6 Model 186 Stepping 2, GenuineIntel`, 16 logical processors
- MoonBit: `moon 0.1.20260819 (fc2a4ee 2026-08-19)`
- Compiler: `moonc v0.10.9+6e6c44045 (2026-08-19)`
- Target: native, release mode
- Command: `moon run benchmarks/atp_benchmark --target native --release`

## Workloads

Each workload uses fixed input data and reports a checksum so the optimizer cannot discard the calculation. The three samples below were run sequentially in the same workspace. `ops_per_second` is calculated by the benchmark program from the measured monotonic-clock duration.

| Workload | Iterations | Sample 1 ops/s | Sample 2 ops/s | Sample 3 ops/s | Checksums |
|---|---:|---:|---:|---:|---:|
| Segment tree lookup | 20,000 | 32,927,230.82 | 47,904,191.62 | 26,899,798.25 | 533,922 |
| Packet 12 decode | 20,000 | 19,784,350.58 | 31,842,063.37 | 21,717,884.68 | 100,000 |
| EBD curve calculation | 100 | 5,439.90 | 6,177.00 | 6,151.08 | 220,100 |
| Full ATP cycle | 1,000 | 1,926,411.10 | 1,789,228.84 | 2,008,838.89 | 1,000 |

The exact output of sample 1 was:

```text
workload=segment_tree_query,iterations=20000,elapsed_us=607.4,ops_per_second=32927230.819888048,checksum=533922
workload=packet_12_decode,iterations=20000,elapsed_us=1010.8999999999999,ops_per_second=19784350.578692257,checksum=100000
workload=ebd_curve,iterations=100,elapsed_us=18382.699999999997,ops_per_second=5439.897294739076,checksum=220100
workload=full_atp_cycle,iterations=1000,elapsed_us=519.1,ops_per_second=1926411.0961279138,checksum=1000
```

Re-run the command on the target machine before using these numbers for capacity planning. A benchmark result is meaningful only together with the toolchain, backend, compiler mode, input sizes and checksum shown above.
