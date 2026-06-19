---
name: goal-tracker
description: 目标管理——通过对话设定新目标、查看目标状态、删除目标。评估逻辑由 system-guardian 的 compliance-check + goal-eval.sh 执行。
version: 1.0.0
category: infra
capabilities: [infra]
domain: system
health: active
---

# Goal Tracker · 目标管理

## 定位

管理用户设定的系统目标。只处理"设定/查看/删除"的对话流程，不执行实际评估。
评估由 `system-guardian` 的 `compliance-check.sh` 触发 `goal-eval.sh` 完成。

---

## 预设目标

以下 5 个目标预设，不需要手动注册，开机即追踪：

| Goal | 条件 | 目标天数 |
|------|------|:--------:|
| 系统全绿 | compliance-check 无违规 | 7天 |
| 心跳新鲜 | HEARTBEAT 不超27h | 7天 |
| 外部记忆可用 | mnemosyne 读写通过 | 7天 |
| 定时任务在跑 | cron 有运行记录 | 7天 |
| 版本锚一致 | 全场景版本号一致 | 7天 |

---

## 对话注册（三问）

触发词：`定个新目标` / `加个目标` / `设定目标` / `我要达成……`

**第一问：目标名称 + 条件**

> "系统全绿连续7天"

**第二问：目标天数**

> "7天" / "30天" / "一直保持"

**第三问：确认**

复述目标 → 用户说"对" → 写入 `goals.yaml` → 初始化 streak 文件。

自动写入格式：
```yaml
  - id: custom-{日期}-{序号}
    name: 用户说的名称
    desc: 用户说的条件
    type: streak
    target_days: 用户说的天数
    eval: "CUSTOM"
    streak_file: "${REAL_HOME}/.hermes/audit/streak-custom-{id}"
```

---

## 查看目标

说"查看目标"或"目标状态"时，展示 goal-eval.sh 的最新输出。

---

## 删除目标

说"删掉XX目标"时，确认后从 `goals.yaml` 移除条目并清理 streak 文件。

---

## 与 system-guardian 的分工

| 职责 | 谁管 |
|:----|:----:|
| 设定/查看/删除的对话流程 | goal-tracker |
| 实际评估（跑脚本、写streak、判断达成） | system-guardian (goal-eval.sh) |
| 达成后的通知推送（ACHIEVED 文件） | system-guardian (开机自检) |
| 目标数据持久化（goals.yaml） | 共享文件，两方读写 |
