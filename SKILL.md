---
name: system-guardian
description: "Build → Check → Audit. Three modes to govern your Hermes system: onboarding wizard, daily health check, deep architecture audit. 构建→自查→审计，三步管好你的 Hermes 系统。"
version: 1.0.0
author: 智正行动
license: MIT
metadata:
  hermes:
    tags: [governance, self-check, audit, onboarding, system]
    requires_toolsets: [terminal, file]
platforms: [linux, macos, windows]
---

# System Guardian · 系统卫士

> ⚠️ 构建模式会修改你的系统配置文件（SOUL.md、config.yaml、.bashrc），建议先备份再使用。

## 模式选择器

```
欢迎使用 System Guardian！请选择：

[1] 🏗️ 系统构建  —— 从零搭建治理体系
[2] ✅ 系统自查  —— 快速检查系统健康（基础版）
[3] 🔍 系统审计  —— 全面检查系统架构（完整版）
[4] 📋 系统能力  —— 查看能力边界和缺失项
```

## 模块说明

### 🏗️ 系统构建（完整开放）

三个问题+自动搭建。固化内容：控制台、宪法、红线、场景、审批、开机自检。详见 `skill_view(name="system-guardian", file_path="references/build-guide.md")`

### ✅ 系统自查（基础版3项）

| # | 检查项 | 说明 |
|---|--------|------|
| 1 | 身份合规 | SOUL.md 身份声明是否存在 |
| 2 | 审批配置 | config.yaml 中 approvals 是否为 manual |
| 3 | 核心文件 | 宪法、红线、自检脚本是否完整 |

基础版覆盖日常核心检查。完整版增加记忆水位、内容锚点、版本锚、脚本自校验等深度检查。

### 🔍 系统审计（完整版）

6 维度探针 + 三幕法报告。约束管道、控制治理、监督检查、协调路由、调度执行、基础完整性。此功能为完整版内容，赞助后可获取。

### 📋 系统能力（完整开放）

看、听、读、说、创五维能力展示。详见 `skill_view(name="system-guardian", file_path="references/capability-guide.md")`

## 前置条件

- Hermes Agent 已安装并能正常对话
- 终端有文件写入权限
- 需要能够访问 GitHub 和海外 API 的网络环境

---

## 获取完整版

基础版满足日常使用。如果你需要审计、深度自查和一键脚本，可以赞助获取完整版：

**完整版额外包含：**
- ✅ 自查扩展至 7 项（含记忆水位、内容锚点、版本锚）
- ✅ 6 维度架构审计 + 三幕法报告
- ✅ 一键自检脚本（终端直接运行）
- ✅ 审计报告自动生成
- ✅ 后续所有更新

☕ [国内赞助（爱发电）](链接) ｜ [海外赞助（Buy Me a Coffee）](链接) ｜ 深度赞助 199 元含一对一远程指导

## License

MIT
