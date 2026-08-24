# Benchmark report

This report records a local reference measurement of the deterministic ATP kernel. It is not a portability claim or a safety certification result.

## Environment

- Date: 2026-08-24
- OS: Microsoft Windows 10.0.26200, x64
- CPU environment: `Intel64 Family 6 Model 186 Stepping 2, GenuineIntel`, 16 logical processors
- MoonBit: `moon 0.1.20260824 (dae026a 2026-08-24)`
- Compiler: `moonc v0.10.10+f8a486b6f (2026-08-21)`
- Target: native, release mode
- Command: `moon run benchmarks/atp_benchmark --target native --release`

## Workloads

Each workload uses fixed input data and reports a checksum so the optimizer cannot discard the calculation. The three samples below were run sequentially in the same workspace. `ops_per_second` is calculated by the benchmark program from the measured monotonic-clock duration.

| Workload | Iterations | Sample 1 ops/s | Sample 2 ops/s | Sample 3 ops/s | Checksums |
|---|---:|---:|---:|---:|---:|
| Segment tree lookup | 20,000 | 31,540,766.44 | 51,124,744.38 | 49,578,582.05 | 533,922 |
| Packet 12 decode | 20,000 | 21,077,036.57 | 28,901,734.10 | 30,688,967.32 | 100,000 |
| EBD curve calculation | 100 | 6,570.04 | 5,862.66 | 6,796.76 | 220,100 |
| Full ATP cycle | 1,000 | 2,236,135.96 | 1,590,330.79 | 2,254,283.14 | 1,000 |

The exact output of sample 1 was:

```text
workload=segment_tree_query,iterations=20000,elapsed_us=634.0999999999999,ops_per_second=31540766.44062451,checksum=533922
workload=packet_12_decode,iterations=20000,elapsed_us=948.9,ops_per_second=21077036.568658445,checksum=100000
workload=ebd_curve,iterations=100,elapsed_us=15220.6,ops_per_second=6570.043230884459,checksum=220100
workload=full_atp_cycle,iterations=1000,elapsed_us=447.2,ops_per_second=2236135.95706619,checksum=1000
```

Re-run the command on the target machine before using these numbers for capacity planning. A benchmark result is meaningful only together with the toolchain, backend, compiler mode, input sizes and checksum shown above.
