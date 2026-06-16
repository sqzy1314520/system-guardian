---
name: system-guardian-premium
description: "System Guardian Premium — full 12-item health check, 7-dimension audit, one-click scripts. 完整版：12项自查+7维度审计+一键脚本。"
version: 1.1.0
author: 智正行动
license: Proprietary
---

# System Guardian · 系统卫士（L3 诊断版）

L3 诊断版用于故障排查和根因分析。不是"功能更多"，是你遇到的问题不同，需要的能力不同。

包含：12项自查 + 7维度审计 + 一键脚本 + 症候群诊断。

## 自查模式（完整12项）

| # | 检查项 | 说明 |
|---|--------|------|
| 1 | 身份合规 | 根SOUL身份声明 + 各场景无冲突 |
| 2 | 记忆冷却期 | 内置记忆写入是否遵守4h间隔 |
| 3 | 版本锚 | 各场景SOUL版本号是否一致 |
| 4 | 规则条数 | 各场景引用条数与根SOUL一致 |
| 5 | 脚本自校验 | 自检脚本sha256与基线一致 |
| 6 | 记忆水位 | MEMORY.md/USER.md 字符水位 |
| 7 | 内容锚点 | 核心文件断言逐条核对（66+断言） |
| 8 | 路径绝对性 | 所有配置文件路径引用为绝对路径 |
| 9 | 服务健康 | Camofox/STT/Playwright 运行状态 |
| 10 | 能力归属 | skill 归位审计 |
| 11 | 外部记忆活性 | Mnemosyne provider + 数据库 + 读写验证 |
| 12 | 记忆治理合规 | 禁止内容扫描 + symlink一致性 |

## 审计模式（完整7维度）

```
① 约束管道   → approvals/Tirith/跨profile守卫/自检
② 控制治理   → control治理权/版本锚一致性
③ 监督检查   → audit目录/HEARTBEAT/agent.log
④ 协调路由   → external_dirs/场景边界
⑤ 调度执行   → 各profile cron job/last_status
⑥ 基础完整性 → 根SOUL关键锚点/断言
⑦ 外部记忆   → provider配置/数据库活性/工具挂载
```

输出三幕法报告：肯定→否定（P0/P1/P2/P3分级）→修复方向。

## 一键脚本

```bash
# 自检脚本——终端直接运行，无需加载skill
bash premium/scripts/compliance-check.sh

# 审计脚本——生成完整审计报告
bash premium/scripts/audit-report.sh
```

## 外部记忆读写验证

一键脚本第11项内置写→读→删原子操作，验证 mnemosyne 是否真正可用。
