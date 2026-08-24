# moonbit-cbtc-atp

[![CI](https://github.com/zklmbq02140831/moonbit-cbtc-atp/actions/workflows/ci.yml/badge.svg)](https://github.com/zklmbq02140831/moonbit-cbtc-atp/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-stable-brightgreen.svg)](https://www.moonbitlang.com/)

`moonbit-cbtc-atp` 是一个纯 MoonBit 的 CBTC/CTCS 车载 ATP 计算内核，提供线路限速合成、移动授权检查、动态制动曲线、超速防护、双通道状态评估和确定性仿真能力。

The library is designed for reproducible algorithm validation and control-system prototyping. It does not access hardware, network services, wall-clock time, or random sources during a safety calculation.

## 用途与边界

适用场景包括：

- CBTC 城轨和 CTCS/ETCS 干线 ATP 算法验证；
- 高速、城轨、重载和复杂坡度线路的制动曲线仿真；
- 线路剖面、临时限速、MA/EOA 和 Eurobalise 报文的纯 MoonBit 测试；
- 为 DMI、黑匣子记录器或上层控制器提供确定性的周期决策输入。

本项目是算法与仿真参考实现，不是已认证的铁路安全产品，也不包含真实列车硬件驱动、通信栈、联锁接口或部署审批材料。使用者应在目标线路、车辆和安全标准环境中独立完成系统级验证。

## 核心能力

| Package | Responsibility |
|---|---|
| `src/types` | 线路、列车、单位、MA/TSR、ATP 状态和诊断数据类型 |
| `src/line_profile` | SSP、TSR、MA、坡度、道岔、区间树和线路约束 |
| `src/dynamics` | 粘着、Davis 阻力、坡度、牵引、气制动和 EBD/SBD 积分 |
| `src/protection` | 防护阈值、超速比较、测速误差、回溜和制动联锁 |
| `src/state_machine` | ATP 状态迁移、故障升级和 2oo2 通道比较 |
| `src/balise` | Eurobalise/CTCS 报文及无线填充数据解析 |
| `src/runtime` | 将遥测、线路、MA/TSR 和状态机组合为一次 ATP 周期 |
| `src/simulation` | 高速、城轨、重载、隧道、风雪和密头时距场景 |

## 快速运行

### 环境

使用 MoonBit 官方 stable 工具链：

```bash
moon version --all
```

### 检查、构建和测试

```bash
moon fmt --check
moon check --target all --deny-warn
moon test --target all --deny-warn
moon build --target all
```

### 运行最小示例

```bash
moon run examples/quick_start --target native
```

示例会构造一条固定线路和一份有效 MA，运行一次 ATP 周期并输出动作、状态、允许速度、EOA 距离和原因码：

```text
action_code=1,state_severity=2,permitted_mps=40,eoa_margin_m=10999.8,reason_code=1
```

动作编码为 `1=Continue`、`2=Warning`、`3=ServiceBrake`、`4=EmergencyBrake`、`5=FailSafeTrip`。所有速度使用 m/s，位置使用 m；`timestamp_ms` 是由调用方提供的非负单调毫秒时间戳。

## 运行时周期 API

`src/runtime` 将一次计算组织为以下顺序：

```text
telemetry + dual-channel state
        -> input validation
        -> SSP ∧ TSR ∧ MA/EOA
        -> SBD/EBD and odometer bounds
        -> state machine + 2oo2 comparison
        -> decision + thresholds + reason code
```

无效位置、负速度、时间倒退、无效线路剖面、无效测距边界、双通道超差或 MA 不可用会返回 `FailSafeTrip`，并通过 `ValidationIssue` / `AtpReasonCode` 保留可审计原因。输入/线路/MA 故障会锁存当前 `AtpCycleEngine` 的 fail-safe 输出；恢复策略由上层控制器通过重新建立运行时实例和人工复位流程负责。正常输入的结果由显式参数决定，不依赖平台时间或随机数。

当前运行时周期只接受前向 MA 语义（两个通道的 `direction` 必须为 `1`）；反向或未知方向会 fail-safe，避免把前向 EOA/SSP 解释错误。

## 仓库结构

```text
.
├── src/                         # MoonBit library packages
│   ├── types/                   # Domain types and units
│   ├── line_profile/            # SSP, TSR, MA and spatial queries
│   ├── dynamics/                # Train dynamics and braking integration
│   ├── protection/              # Supervision and safety boundaries
│   ├── state_machine/           # ATP FSM and 2oo2 voting
│   ├── balise/                  # Telegram decoders
│   ├── runtime/                 # One-cycle ATP orchestration
│   ├── simulation/              # Deterministic route scenarios
│   └── tests/                   # Unit, boundary and invariant tests
├── examples/quick_start/        # Runnable native example
├── benchmarks/atp_benchmark/    # Deterministic local benchmark runner
├── docs/benchmarks.md            # Recorded reference measurements
├── .github/workflows/ci.yml     # Stable-toolchain CI matrix
├── moon.mod                     # Module metadata
├── LICENSE                      # Apache-2.0
└── README.md
```

## 测试与持续集成

测试覆盖核心线路查询、动力学、状态机、报文解码、动态阈值、失效输入、时间边界、重叠/反向区间和重复计算确定性。GitHub Actions 在 Ubuntu、macOS 和 Windows 上执行全目标检查、测试、构建、格式/接口 diff 检查以及最小示例 smoke check。

本地完整门禁：

```bash
moon fmt --check
moon check --target all --deny-warn
moon test --target all --deny-warn
moon build --target all
moon info
moon run examples/quick_start --target native
```

## 基准

基准程序使用固定输入和 checksum，测量线路区间查询、Packet 12 解码、EBD 曲线和完整 ATP 周期。已记录的三次本地 native release 测量见 [`docs/benchmarks.md`](docs/benchmarks.md)。这些数字只用于同工具链和同输入规模下的参考比较，不能替代目标设备上的容量评估。

```bash
moon run benchmarks/atp_benchmark --target native --release
```

## 许可证

本项目以 [Apache License 2.0](LICENSE) 发布。标准名称和公式仅用于说明算法设计依据；将本库用于实际控制系统时，使用者仍需完成独立的安全论证、测试和合规审查。
