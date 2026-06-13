---
name: system-guardian-premium
description: "Build → Check → Audit. Premium version with full 7-item health check, 6-dimension audit, and one-click scripts. 完整版：自查7项+审计6维度+一键脚本。"
version: 1.0.0
author: 智正行动
license: Proprietary
---

# System Guardian · 系统卫士（完整版）

包含全部四个模块，所有功能完整开放。

## 自查模式（完整7项）

| # | 检查项 | 说明 |
|---|--------|------|
| 1 | 身份合规 | SOUL.md 身份声明是否正确 |
| 2 | 冷却期 | 记忆写入是否遵守4小时间隔 |
| 3 | 版本锚 | 各场景版本号是否一致 |
| 4 | 内容锚点 | 核心文件的43个断言是否完整 |
| 5 | 脚本自校验 | 自检脚本sha256是否与基线一致 |
| 6 | 记忆水位 | MEMORY.md(2200字)是否接近上限 |
| 7 | 审批配置 | approvals.mode 是否为 manual |

## 审计模式（完整6维度）

```
① 约束管道   → approvals/Tirith/跨profile守卫
② 控制治理   → control治理权/版本锚
③ 监督检查   → 审计日志/心跳/cron状态
④ 协调路由   → route_manager/external_dirs
⑤ 调度执行   → 各profile cron job状态
⑥ 基础完整性 → 根SOUL关键锚点7项
```

输出三幕法报告：肯定→否定→修复方向。

## 一键脚本

```bash
# 自检脚本——终端直接运行，无需加载skill
bash system-guardian-check.sh

# 审计脚本——生成完整审计报告
bash system-guardian-audit.sh
```
