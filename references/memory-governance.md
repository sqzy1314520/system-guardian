# 三层记忆系统与闭环治理

## 三层记忆系统

Hermes 的记忆分三层，不是替代关系，是互补关系。

| 层级 | 名称 | 存储位置 | 管理规则 | 用途 |
|:----:|------|---------|---------|------|
| L1 | **内置记忆** | `MEMORY.md` / `USER.md` | 第15条：4h冷却期、95%溢出自救 | 核心架构规则、协作铁律、环境事实（每次对话自动注入） |
| L2 | **外部记忆** | `~/.hermes/mnemosyne/data/` (SQLite) | 第16条：5触发条件、禁止清单、source标签隔离 | 日常积累的偏好、决策、事实（按需recall） |
| L3 | **治理规则** | `memory-governance` skill | 3层闭环：开机预载/hook触发/合规审计 | 执行层——什么时候存、怎么读、什么不该存 |

### 三层关系

```
对话开始 → 内置记忆自动注入（L1）
    ↓
开机自检加载 memory-governance skill（L3）
    ↓
跨会话回忆：mnemosyne_recall(temporal_weight=0.8, limit=3) ← 新增
    ↓ 命中高权重近期记忆 → 主动报告"上次会话摘要"
用户输入 → on_turn_start hook 自动检测触发条件（L3）
    ↓ 命中纠正/偏好/决策
写入外部记忆 mnemosyne（L2，带 source 场景标签）
    ↓
compliance-check 每次启动审计（L3）：水位/活性/治理合规
```

> **跨会话回忆**（2026-06-18 新增）：解决「开机后不知道刚才在聊什么」的架构级缺陷。在加载 memory-governance skill 后、等待用户输入前，自动拉取最近4小时高权重外部记忆。详见 `memory-governance` skill 第九章「开机主动回忆」。

### 溢出自救

内置记忆水位超 95% 时——新信息自动写入外部记忆（L2），不占内置空间。不是降级，是分流。

### 场景隔离

所有场景共享同一个中央数据库，通过 `source` 字段逻辑隔离——读默认只读本场景，跨场景传 `source=None` 显式全库搜。

---


# 闭环治理机制

## 闭环治理机制

三层记忆系统之上，运行五套闭环治理机制，保证系统持续健康，不只是「当下没问题」。

### ① Goal 追踪系统

**定位：** 让系统自己判断「是否达成目标」，不等人看。

5 个预设目标定义在 `~/.hermes/audit/goals.yaml`。每次 compliance-check 后自动评估：

| Goal | 条件 | 类型 | 目标 |
|------|------|:----:|:----:|
| 系统全绿 | compliance-check 无违规 | streak | 连续7天 |
| 心跳新鲜 | HEARTBEAT 不超27h | streak | 连续7天 |
| 外部记忆可用 | mnemosyne 读写通过 | streak | 连续7天 |
| 定时任务在跑 | cron 有运行记录 | streak | 连续7天 |
| 版本锚一致 | 全场景版本号一致 | streak | 连续7天 |

连续达标天数写入 streak 文件，断一天归零。≥7天标记为 🏆 达成，写入 mnemosyne + ACHIEVED 通知文件，开机自检时主动报告。

### ①a 系统健康 SLA

Goal 只跟踪「是否达标」，SLA 定义「系统有多健康」。每日自检时自动计算，分三层：

| 等级 | 基础设施 | 生产质量 | 仓库健康 |
|:----:|:---------|:---------|:---------|
| **🟢 健康** | 心跳<2h，cron 有记录，版本锚一致，记忆水位<95% | 调用成功率≥95%，纠错率<10%（skill_log 近7天） | 角色匹配率100%，deprecated<5% |
| **🟡 降级** | 心跳>2h，或某 cron 异常 | 任一 domain 成功率 80-95%，或纠错率 10-30% | 匹配率<100%，或 deprecated>5% |
| **🔴 严重** | 心跳>6h，或关键 cron 连败3次 | 任一 domain 成功率<80%，或纠错率>30% | 匹配率<80% |

SLA 降级时通过三通道通知用户，同时写入 STATE.md。

**定位：** 过去7天趋势，不只看「现在绿不绿」。

每次 compliance-check 后，`state-summary.py` 从 mnemosyne 查询过去7天的 goal 记录，产出趋势视图：

```
Goal 达成趋势（过去7天）：
  06-10 ████████░░ 4/5
  06-11 ████████░░ 4/5
  06-12 █████████░ 5/5 ← 全绿
  ...
```

同时落盘到 `~/.hermes/audit/STATE.md`，随时可 `cat` 查看。

### ③ Maker-Checker 分离

**定位：** 不让同一个视角既做评估又做验证。

| 角色 | 评估内容 | 运行时机 |
|:----:|---------|---------|
| **Maker** | 表层：SOUL/approvals/HEARTBEAT/mnemosyne 存在性 | compliance-check 即时 |
| **Checker** | 深层：版本锚/cron活性/读写验证/Goal追踪 | 独立 cron + delegate_task 分流 |

两个角色读不同的数据源、在不同时间点运行、不知道对方的结果。结果不一致时交叉验证升级告警。

### ④ delegate_task 分流

**定位：** 复杂任务不污染主对话上下文。

compliance-check 发现违规时不直接调用 Checker，而是写入 `trigger-checker` 触发文件。下次开机自检时通过 `delegate_task` 在完全隔离的子代理上下文中运行 Checker。子代理不知道 Maker 的 PASS/FAIL 结果。

当前三层分流：

```
compliance-check（Maker）
  ↓ 写入 trigger-checker
开机自检 → delegate_task → 独立 Checker 子代理
  ↓ 隔离运行
返回诊断摘要 → 删除 trigger-checker
```

### ⑤ 独立 Checker cron

**定位：** 不依赖对话触发，系统自愈巡逻。

cron job `independent-checker` 每6小时运行一次，调用 `checker-cron.sh` → `syndrome-detect.sh`。正常时安静退出（no_agent 空输出 = 静默）。发现异常时写入 `CHECKER_ALERT` 文件，开机自检时主动报告。

**三层触发：**

| 触发方式 | 延迟 | 适用场景 |
|---------|:----:|---------|
| compliance-check 即时 | 0 | 每次对话后立即检查 |
| delegate_task 开机自检 | 次对话 | 深度隔离诊断 |
| cron 每6小时 | ≤6h | 无人值守时自动巡逻 |

---
