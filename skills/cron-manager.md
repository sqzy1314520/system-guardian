---
name: cron-manager
description: 定时任务管理——创建向导、审计流程、常见错误排查。小白也能用，专家也能查。不负责 cron 的具体执行（那是 system-guardian HEARTBEAT 的事）。
version: 1.0.0
category: infra
capabilities: [infra]
domain: system
health: active
---

# Cron Manager · 定时任务管理

## 定位

管理 Hermes 定时任务（cron job）的创建、审计和排查。不执行具体 job——执行层的健康由 `system-guardian` 的心跳机制管。

---

## 模式一：创建向导（小白模式）

不懂 cron 表达式、不懂 profile、不懂 gateway？跟着三句话走。

**第一问：你要定时做什么？**

> A. 🔄 **跑个脚本**——定时执行某个脚本（如备份、监控检查）
> B. 🤖 **让AI干活**——定时让AI搜索信息、生成报告、发提醒
> C. 📢 **定时推送**——每天/每周固定发一条消息到微信或QQ

快速通道（匹配以下模式自动跳过三问）：

| 用户说 | 自动选择 | 默认参数 |
|--------|---------|---------|
| "每天看新闻/简报/早报" | Agent型 + 推送微信 | profile=work, 09:20, web工具集 |
| "监控/检查系统" | 脚本型 | profile=control, 每2h |
| "备份/清理" | 脚本型 | profile=control, 每周日03:00 |

**第二问：什么时间执行？**

| 用户说 | cron表达式 |
|--------|-----------|
| 每天早上9点 | `0 9 * * *` |
| 工作日10点半 | `30 10 * * 1-5` |
| 每2小时 | 每120分钟 |
| 每周一早上8点 | `0 8 * * 1` |

⚠️ 分钟不明确时（如"早上"），追问具体分钟。间隔型调度（"每3天"），确认起始日。

**第三问：推送到哪里？**（仅Agent型和推送型）

> A. 📱 **微信** — deliver=origin
> B. 📄 **本地文件** — deliver=local
> C. 🔇 **不用推送** — 出问题才通知（no_agent + silent exit）

### 新手引导

如果 `hermes-cron-tick.timer` 未运行，先部署：
1. 创建 `hermes-cron-tick.service`（oneshot）
2. 创建 `hermes-cron-tick.timer`（每分钟触发）
3. 启用 timer

---

## 模式二：审计流程（专家模式）

### 第一步：全层发现

```bash
hermes cron list                     # 当前 profile 的任务
hermes -p control cron list          # 跨 profile 检查
hermes -p work cron list
hermes -p recreation cron list
crontab -l 2>/dev/null               # 系统 crontab 旧条目
hermes cron status                   # 调度器运行状态
```

注意：`cronjob` CLI 工具只返回当前 profile 的 job。跨 profile 必须用 `hermes -p <profile> cron list`。

### 第二步：逐项检查

每个 cron job 检查：
- 脚本文件存在？
- 路径正确（绝对路径或 paths.sh 变量）？
- `enabled=true`, `state=scheduled`？
- last_run_at + last_status + last_error 有无异常

### 第三步：交叉比对

- 同一脚本在系统 crontab 和 Hermes cron 双注册？→ 保留 Hermes，清理系统
- 投递目标仍有效？通道是否配置？

### 第四步：导出报告

按场景分组呈现给用户：任务名 / 调度 / 末次运行 / 状态。

---

## 常见错误速查

| 错误特征 | 根因 | 修复 |
|---------|------|------|
| `'you passed .'` 或空模型名报错 | `model: null`，API 收到空字符串 | 补 model + provider/base_url |
| `Script not found:` + 路径 | 脚本在 centralized 目录但 cron 从 profile 的 `scripts/` 找 | 复制到 profile 目录 |
| `skill not found, skipping` | skill 名拼错或分类被空本地目录遮蔽 | 检查 external_dirs + 同名目录 |
| `Blocked: script path resolves outside` | 脚本是符号链接 | 物理复制到 profile 的 `scripts/` 目录 |
| `no delivery target resolved` | profile 未配 Gateway 通道 | 改为 `local` 或指定具体通道 |
| Agent 型 job last_run_at 始终 N/A | jobs.json 中 interval 格式错误 | `"every": N` → `"minutes": N` |
| no_agent 脚本报 `$HOME` 相关错误 | profile 模式下 `$HOME` 被重写 | 用 `pwd.getpwuid` 获取真实 HOME |

---

## 技术边界

- 只创建在 `control/cron/jobs.json` 中（中央集权架构）
- profile 自动判断：脚本型→control，Agent干活→work，推送型→按渠道
- 本模式只创建不管理。删除/暂停走 `hermes cron remove/pause`
- 不修改 systemd timer

---

## 已知限制

**interval 格式损坏会导致 scheduler 静默崩溃。**

`kind: interval` 必须使用 `minutes` 键，不是 `every`：
```json
{"kind": "interval", "minutes": 120}  ← 正确
{"kind": "interval", "every": 120}     ← 整个 scheduler 崩溃
```

排查：所有 job 的 `last_run_at` 均为 N/A → `grep "every" jobs.json`。
