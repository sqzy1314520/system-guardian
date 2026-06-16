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

## 治理边界

**system-guardian 管：**
- 系统级契约合规（身份声明、版本锚、记忆水位、路径规范、外部记忆配置）
- 基础设施运行状态（服务健康、cron 调度、外部记忆读写）
- 治理文件完整性（SOUL.md、内容锚点、自检脚本）

**system-guardian 不管：**
- 场景内的业务产出质量（发言稿写得怎么样、推文有没有人看）
- 具体对话的质量和效率
- 写作/创作的美学标准
- 用户个人偏好和习惯

**违反边界：** 如果在自查/审计输出中发现上述不管的内容，说明 skill 出现了膨胀漂移，请报告 issue。

## 版本说明

system-guardian 分三层，对应三个不同的问题：

| 层级 | 解决什么问题 | 谁用 |
|:----:|------------|------|
| **L1 向导版** | 刚装好Hermes，不知道要配什么 | 新手 |
| **L2 稳定版** | 日常健康巡检，看看有没有出问题 | 所有用户 |
| **L3 诊断版** | 出故障了，需要根因分析和修复方案 | 需要排查的用户 |

L1 和 L2 完全免费，L3 赞助获取。

---

## 模式选择器

```
欢迎使用 System Guardian！请选择：

[1] 🏗️ 系统构建  —— 从零搭建治理体系
[2] ✅ 系统自查  —— 全面检查系统健康（外部记忆/定时任务/五维能力/渠道通断/纪律合规）
[3] 🔍 系统审计  —— L3 诊断版：故障根因分析
[4] 📋 系统能力  —— 查看能力边界和缺失项
```

## 模块说明

### 🏗️ 系统构建（L1/L2/L3 全开放）

三个问题+自动搭建。固化内容：控制台、宪法、红线、场景、审批、开机自检。详见 `skill_view(name="system-guardian", file_path="references/build-guide.md")`

### ✅ 系统自查（L2/L3 全开放）

**裸机检测（入口前置判断）：**

系统加载自查模式时，先做三个前置检查：

```
检查 1: SOUL.md 是否存在？
  → 否 → "你的系统还没建，需要先走构建模式。要帮你建吗？" → 跳转构建
  → 是 → 继续
检查 2: audit 目录是否存在？
  → 否 → "检测到你已有基础配置但未初始化自检系统，要一键补全吗？"
  → 是 → 继续
检查 3: compliance-hash.txt 是否存在？
  → 否 → "首次运行，正在初始化自检基线……"
  → 是 → 继续
```

三项全通过 → 运行 6 维度健康检查：

| 维度 | 检查内容 |
|:----:|---------|
| ① 外部记忆 | memory provider 配置 + 数据库活性 |
| ② 定时任务 | cron job 列表与运行状态 |
| ③ 五维能力 | 看/听/说/读/创 工具可用性 |
| ④ 渠道通断 | 微信/QQ Gateway 运行状态 |
| ⑤ 技能加载 | 关键技能可达性 |
| ⑥ 纪律合规 | 身份/版本锚/记忆水位/路径健康度等合规检查 |

输出一张健康表，每项绿/黄/红。

### 🔍 系统审计（L3 诊断版）

7维度架构穿透 + 三幕法报告。约束管道、控制治理、监督检查、协调路由、调度执行、基础完整性、外部记忆治理。此功能为 L3 诊断版内容，赞助后可获取。

### 📋 系统能力（L1/L2/L3 全开放）

看、听、读、说、创五维能力展示。详见 `skill_view(name="system-guardian", file_path="references/capability-guide.md")`

## 前置条件

- Hermes Agent 已安装并能正常对话
- 终端有文件写入权限
- 需要能够访问 GitHub 和海外 API 的网络环境

---

## 获取 L3 诊断版

L2 稳定版满足日常健康巡检。如果你经常排查故障、需要根因分析和一键脚本，升级到 L3 诊断版：

**L3 诊断版额外包含：**
- ✅ 7维度架构审计 + 三幕法报告（含症候群诊断）
- ✅ 一键自检脚本（compliance-check.sh，12项全自动 + 读写验证）
- ✅ 外部记忆读写状态验证
- ✅ 审计报告自动生成
- ✅ 后续所有更新

不是「功能更多」——是你遇到的问题不同，需要的能力不同。

☕ [国内赞助（爱发电）](https://afdian.com/a/meijiexueAI) ｜ [海外赞助（Buy Me a Coffee）](https://buymeacoffee.com/sqzy1314520) ｜ 深度赞助 199 元含一对一远程指导

## License

MIT
