---
name: system-guardian
description: "System self-check, audit, heartbeat monitoring, and goal evaluation. Run compliance checks, trigger syndrome diagnostics, maintain system heartbeat. 系统自查、审计、心跳监控与目标评估。"
version: 2.0.0
author: 智正行动
license: MIT
metadata:
  hermes:
    tags: [governance, self-check, audit, system, devops]
platforms: [linux, macos, windows]
---

# System Guardian · 系统卫士

> ⚠️ 构建模式会修改你的系统配置文件，建议先备份再使用。
> 自检和审计模式只读不改。

## 核心功能

| 功能 | 说明 |
|------|------|
| ✅ 系统自查 | 全功能健康检查：记忆水位 / 定时任务 / 五维能力 / 渠道通断 / 纪律合规 |
| 🔍 系统审计 | L3 深度诊断：7 维度三幕法架构穿透，症候群关联分析 |
| 💓 心跳监控 | HEARTBEAT 双层保障，系统健康自检信号 |
| 🎯 目标管理 | 5 个预设目标 + 自定义目标，连续达标追踪 |

## 配套技能

从 v2.0.0 开始，原 system-guardian 拆分为四个独立技能：

| 技能 | 职责 | 适用场景 |
|:----|:----|:--------|
| **system-guardian**（本技能） | 自检 + 审计 + 心跳 + Goal 评估 | 日常系统健康检查 |
| **cron-manager** | 定时任务创建、审计、排查 | 需管理 cron job 时 |
| **system-onboarding** | 首次开箱引导、构建配置 | 新装 Hermes 后首次使用 |
| **goal-tracker** | 目标的设定、查看、删除 | 管理系统目标时 |

## 模式选择

加载技能后：

```
[1] ✅ 系统自查  —— 全面检查系统健康
[2] 🔍 系统审计  —— 深度架构诊断
[3] 📋 系统能力  —— 查看能力边界和缺失项
```

### 自查模式

6 维度健康检查：

| 维度 | 检查内容 |
|:----:|---------|
| ① 外部记忆 | Mnemosyne 活性 + 读写验证 |
| ② 内置记忆 | 字符水位 + 溢出自救 |
| ③ 定时任务 | cron 列表 + 调度有效性 |
| ④ 五维能力 | 看/听/说/读/创 |
| ⑤ 渠道通断 | Gateway 运行状态 |
| ⑥ 纪律合规 | 身份/版本锚/路径/脚本/锚点 |

### 审计模式

7 维度架构穿透，L3 诊断版：故障根因分析、症候群检测、Goal 评估。

## HEARTBEAT 双层保障

```
 soul-daily-audit  ──>  writes HEARTBEAT  ──>  monitor checks freshness
 (每天 cron)                                  (每2小时)
```

## 安装

```bash
hermes skills install https://github.com/sqzy1314520/system-guardian/raw/main/SKILL.md
```

## 前置条件

- Hermes Agent 已安装
- 终端有文件写入权限
- 需要能够访问 GitHub 和海外 API 的网络环境

## License

MIT
