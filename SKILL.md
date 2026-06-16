---
name: system-guardian
description: "Build → Check → Audit. Four modes to govern your Hermes system: onboarding wizard, health check, deep audit, capability matrix. 构建→自查→审计→能力，管好你的 Hermes 系统。"
version: 1.1.0
author: 智正行动
license: MIT
metadata:
  hermes:
    tags: [governance, self-check, audit, capability, system]
    requires_toolsets: [terminal, file]
platforms: [linux, macos, windows]
---

# System Guardian · 系统卫士

> ⚠️ 构建模式会修改你的系统配置文件（SOUL.md、config.yaml、.bashrc），建议先备份再使用。

## 模式选择器

```
欢迎使用 System Guardian！请选择：

[1] 🏗️ 系统构建  —— 从零搭建治理体系
[2] ✅ 系统自查  —— 全面检查系统健康（外部记忆/定时任务/五维能力/渠道通断/纪律合规）
[3] 🔍 系统审计  —— 架构级深度检查（完整版）
[4] 📋 系统能力  —— 查看能力边界和缺失项
```

## 模块说明

### 🏗️ 系统构建（完整开放）

三个问题+自动搭建。固化内容：控制台、宪法、红线、场景、审批、开机自检。详见 `skill_view(name="system-guardian", file_path="references/build-guide.md")`

### ✅ 系统自查（完整开放）

全功能健康检查，覆盖6个维度：

| 维度 | 检查内容 |
|:----:|---------|
| ① 外部记忆 | memory provider 配置 + 数据库活性 |
| ② 定时任务 | cron job 列表与运行状态 |
| ③ 五维能力 | 看/听/说/读/创 工具可用性 |
| ④ 渠道通断 | 微信/QQ Gateway 运行状态 |
| ⑤ 技能加载 | 关键技能可达性 |
| ⑥ 纪律合规 | 身份/版本锚/记忆水位/路径健康度等合规检查 |

输出一张健康表，每项绿/黄/红。

### 🔍 系统审计（完整版）

7维度架构穿透 + 三幕法报告。约束管道、控制治理、监督检查、协调路由、调度执行、基础完整性、外部记忆治理。此功能为完整版内容，赞助后可获取。

### 📋 系统能力（完整开放）

看、听、读、说、创五维能力展示。详见 `skill_view(name="system-guardian", file_path="references/capability-guide.md")`

## 前置条件

- Hermes Agent 已安装并能正常对话
- 终端有文件写入权限
- 需要能够访问 GitHub 和海外 API 的网络环境

---

## 获取完整版

基础版满足日常健康检查。如果你需要深度审计和一键脚本，可以赞助获取完整版：

**完整版额外包含：**
- ✅ 7维度架构审计 + 三幕法报告
- ✅ 一键自检脚本（compliance-check.sh，12项全自动）
- ✅ 外部记忆读写状态验证
- ✅ 审计报告自动生成
- ✅ 后续所有更新

☕ [国内赞助（爱发电）](https://afdian.com/a/meijiexueAI) ｜ [海外赞助（Buy Me a Coffee）](https://buymeacoffee.com/sqzy1314520) ｜ 深度赞助 199 元含一对一远程指导

## License

MIT
