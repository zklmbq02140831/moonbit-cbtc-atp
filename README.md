# `moonbit-cbtc-atp`

> **moonbit轨道交通列车自动保护(ATP)超速防护与动态制动曲线算子**
> **Train-borne CBTC/CTCS Automatic Train Protection (ATP) Overspeed Protection & Dynamic Braking Curve Kernel in MoonBit**

[![CI](https://github.com/zklmbq02140831/moonbit-cbtc-atp/actions/workflows/ci.yml/badge.svg)](https://github.com/zklmbq02140831/moonbit-cbtc-atp/actions)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![MoonBit Version](https://img.shields.io/badge/MoonBit-0.10.8%2B-brightgreen)](https://www.moonbitlang.com/)

---

## 📖 项目简介 (Project Overview)

`moonbit-cbtc-atp` 是基于 **CBTC / CTCS 体系 (IEEE 1474 / EN50128 SIL4 级要求)** 的标准车载 ATP（列车自动保护）超速防护计算内核。

本内核完全使用 **MoonBit 原生语言** 编写，专为轨道交通（高速铁路 350km/h、城轨 CBTC 80km/h、重载铁路 90km/h）提供高性能、高安全性、确定性的超速防护算法与动态制动曲线算子。根据移动授权（Movement Authority, MA）与临时限速（Temporary Speed Restriction, TSR），实时计算紧急制动曲线（EBD）、常用制动曲线（SBD）以及安全包络线。

---

## 🌟 核心特性 (Key Technical Features)

1. **确定性线路由数据结构与线段树检索 (`src/line_profile/`)**
   - 采用空间线段树（Segment Tree）与 MoonBit 确定性模式匹配，实现 $O(\log N)$ 级别的物理限速、坡度（Gradient）、曲率（Curvature）、分流道岔（Switch）快速区间检索。
   - 动态合成静态速度剖面（Static Speed Profile, SSP）与临时限速（TSR）叠加防护。

2. **多阶段减速度动态积分算子 (`src/dynamics/`)**
   - **轮轨粘着系数衰减模型**：遵循 UIC/EN 标准粘着曲线 $\mu(v) = \mu_0 \cdot \frac{1 + a_1 v}{1 + a_2 v} \cdot \eta_{\text{rail}}$。
   - **戴维斯阻力方程 (Davis Equation)**：$R(v) = A + Bv + Cv^2$ 评估列车机械与空气动力学运行阻力。
   - **坡度等效加速度**：$g_{\text{grad}} = g \cdot \sin(\theta) \approx 9.81 \cdot \frac{\text{gradient}}{1000}$。
   - **多阶段后向数值积分算子**：考虑制动响应延迟 $t_{\text{delay}}$ 及制动气压建立阶段 $t_{\text{build}}$，基于辛普森（Simpson）与后向微分步长倒推计算精确的 $v_{\text{ebd}}(s)$ 与 $v_{\text{sbd}}(s)$ 速度剖面。

3. **EN50128 SIL4 级安全状态机 (`src/state_machine/`)**
   - 严格守卫的状态迁移逻辑：`SystemInit` $\to$ `Standby` $\to$ `NormalOperating` $\to$ `OverspeedWarning` $\to$ `ServiceBrakingTriggered` $\to$ `EmergencyBrakingTriggered` $\to$ `EmergencyTrip` / `HardwareFault`。
   - **双通道 2o2 交叉冗余表决**：仿真模拟通道 A 与通道 B 的数据交叉比对，实现故障安全（Fail-Safe）原则。

4. **形式化契约与安全不变量验证 (`src/spec/spec.mbt`)**
   - **契约 1 (超速防护无越界契约)**：对于任意列车状态 $(s, v)$，若触发紧急制动，保证列车完全停稳位置 $s_{\text{stop}} \le s_{\text{EOA}}$。
   - **契约 2 (减速度不退化契约)**：制动减速度 slope $-dv/ds$ 随制动能力单调性校验。
   - **契约 3 (状态递进单调性契约)**：超速等级递增时安全状态严禁非法退化。
   - **契约 4 (定位不确定度边界契约)**：测速定位信赖区间 $[s_{\min}, s_{\max}]$ 不可越界。

5. **全场景仿真与 100+ 单元测试 (`src/simulation/` & `src/tests/`)**
   - 提供高铁 350km/h 陡坡场景、城轨 CBTC 80km/h 密头间距场景、重载 90km/h 大延迟场景仿真测试。

---

## 🏗️ 模块结构 (Architecture & Directory Layout)

```
moonbit-cbtc-atp/
├── .github/workflows/ci.yml     # 自动化 CI 校验 (moon fmt / moon info / moon test)
├── moon.mod                     # MoonBit 模块定义文件
├── moon.pkg                     # 根包配置
├── LICENSE                      # Apache-2.0 开源协议
├── README.md                    # 项目中文与英文说明文档
└── src/
    ├── types/                   # 核心数据结构与 SIL4 枚举定义
    │   ├── line_types.mbt       # 线路、坡度、曲率、道岔、应答机数据结构
    │   ├── train_types.mbt      # 列车质量、阻力系数、粘着参数
    │   ├── state_types.mbt      # 定位信赖区间、列车实时状态、安全日志
    │   ├── curve_types.mbt      # 动态制动曲线节点、MA/TSR 数据结构
    │   └── atp_types.mbt        # SIL4 安全状态与事件枚举
    ├── line_profile/            # 线路剖面与限速引擎
    │   ├── segment_tree.mbt     # 空间线段树 $O(\log N)$ 检索
    │   ├── ssp.mbt              # 静态速度剖面 (SSP) 合成
    │   ├── tsr.mbt              # 临时限速 (TSR) 动态管理
    │   └── ma.mbt               # 移动授权 (MA) 校验与 EOA 提取
    ├── dynamics/                # 列车动力学与制动积分算子
    │   ├── adhesion.mbt         # 轮轨粘着系数衰减模型
    │   ├── davis.mbt            # Davis 运行阻力计算
    │   ├── gradient_force.mbt   # 坡度等效加速度
    │   └── brake_integration.mbt# 后向多阶段数值积分算子
    ├── protection/              # 超速防护与安全包络线计算
    │   ├── supervision.mbt      # 动态防护阈值 ($v_{warn}, v_{sbd}, v_{ebd}, v_{trip}$)
    │   ├── odometer.mbt         # 测速定位空转打滑检测与误差膨胀
    │   └── ceiling_speed.mbt    # 顶板速度实时比较器
    ├── state_machine/           # SIL4 安全状态机与双通道表决
    │   ├── safety_fsm.mbt       # 确定性状态迁移逻辑
    │   └── redundancy.mbt       # 双通道 2o2 交叉冗余表决
    ├── balise/                  # 应答机与无线 Telegram 解析
    │   ├── telegram_parser.mbt  # Eurobalise / CTCS 报文位流解析 (Packet 12/27)
    │   └── radio_infill.mbt     # 无线通信超时 Watchdog 校验
    ├── spec/                    # 形式化规范与安全契约
    │   └── spec.mbt             # 超速无越界、减速不退化形式化不变量
    ├── simulation/              # 轨道交通多场景仿真引擎
    │   ├── high_speed_sim.mbt   # 350 km/h 高铁仿真场景
    │   ├── metro_sim.mbt        # 80 km/h 城轨 CBTC 仿真场景
    │   ├── freight_sim.mbt      # 90 km/h 重载铁路仿真场景
    │   └── runner.mbt           # 统一仿真测试汇总器
    └── tests/                   # 单元测试集
        └── unit_tests.mbt       # 100+ 覆盖率单元测试
```

---

## 🛠️ 构建与测试指南 (Build & Test Instructions)

### 1. 环境准备 (Prerequisites)
安装最新版 **MoonBit 工具链** (建议 0.10.8 及以上版本)：
```bash
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
```

### 2. 代码检查与格式化 (Format & Check)
运行标准代码格式化与接口检查：
```bash
moon fmt
moon info
```

### 3. 运行单元测试与形式化契约 (Run Tests)
```bash
moon test
```

---

## 📝 来源说明与版权 (Source Attribution & License)

- **来源说明**：本项目为 **开源创新大赛 OSC 2026** 完全原创制作，100% 由 MoonBit 编写，核心动力学公式与安全状态机参考 IEEE 1474 / EN50128 国际轨道交通信号规范。
- **开源协议**：本项目基于 [Apache-2.0 License](LICENSE) 协议开源。
