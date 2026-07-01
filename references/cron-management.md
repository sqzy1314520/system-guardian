# 定时任务管理 · Cron Management

## 定时任务创建向导

## 定时任务模式

> 对应阶段④「我想加个新功能」：对话驱动的 Cron 创建向导。

> 小白向导式部署定时任务。不懂 cron 表达式、不懂 profile、不懂 gateway？
> 跟着问三句话，帮你建好。三种模式：脚本型 / Agent型 / 推送型。

加载本模式后，执行以下流程。**一次只问一个问题，等回复再问下一个。**

### 第一问：你要定时做什么？（三选一）

> A. 🔄 **跑个脚本**——定时执行某个脚本（如备份、监控检查）
> B. 🤖 **让AI干活**——定时让AI搜索信息、生成报告、发提醒（最常用）
> C. 📢 **定时推送**——每天/每周固定发一条消息到微信或QQ
>
> （也可以直接说你想干什么，听不懂再追问）

模板匹配（快速通道）——当用户说的内容匹配以下模式，跳过三问直接进入参数补全：

| 用户说 | 自动选择 | 默认参数 |
|--------|---------|---------|
| "每天看新闻/简报/早报" | Agent型 + 推送微信 | profile=work, 09:20 MF, web工具集 |
| "监控/检查系统" | 脚本型 | profile=control, 每2h |
| "每天学英语/读书" | Agent型 + 推送QQ | profile=recreation, 12:30 |
| "备份/清理" | 脚本型 | profile=control, 每周日03:00 |
| "写学习笔记/总结" | Agent型 | profile=study, 21:00 local |

### 第二问：什么时间执行？

让用户直接用自然语言说，例如：
- "每天早上9点" → `0 9 * * *`
- "工作日10点半" → `30 10 * * 1-5`
- "每2小时" → 每120分钟
- "每周一早上8点" → `0 8 * * 1`

⚠️ 防错：分钟不明确时（如"早上"），追问具体分钟。
⚠️ 防错：间隔型调度（"每3天"），确认起始日。

### 第三问：推送到哪里？（仅 Agent 型和推送型需要问）

> A. 📱 **微信** —— profile=work, deliver=origin
> B. 💬 **QQ** —— profile=recreation, deliver=qqbot
> C. 📄 **本地文件** —— deliver=local（不推送）
> D. 🔇 **不用推送** —— 出问题才通知（no_agent + silent exit）

⚠️ 防错：选 QQ 但 recreation gateway 不在运行 → 提示先启动。
⚠️ 防错：选微信但 work gateway 不在运行 → 提示先启动。

### 参数补全

根据第一问的选择，补充以下参数：

**脚本型（A）：**
- 脚本路径（支持拖拽）
- 是否需要特定工作目录
- ⚠️ 自动检查脚本是否在 `control/scripts/` 目录内，不在则复制进去

**Agent型（B）：**
- 描述要让AI做什么
- 是否需要加载特定 SKILL
- 工具集选择（默认 web+file+terminal）
- ⚠️ prompt 超过500字建议精简

**推送型（C）：**
- 推送内容文本
- ⚠️ 周期型内容（如每日早安）建议改用 Agent 型

### 执行创建

```bash
hermes -p control cron create \
  --name "任务名" \
  --schedule "cron表达式" \
  --prompt "prompt内容" \
  --profile <自动判断> \
  --deliver <用户选择> \
  --toolsets web,terminal,file
```

创建后验证：`hermes -p control cron list` 确认在列。
告知用户下次执行时间。可选：问要不要立即跑一次测试。

### 新手引导

如果 `hermes-cron-tick.timer` 未运行（`systemctl --user list-timers | grep hermes-cron-tick` 无结果），先提示：
> "你的定时任务系统还没启动，需要先部署。要我帮你部署吗？"
>
> 用户确认后自动执行：
> 1. 创建 `hermes-cron-tick.service`（oneshot）
> 2. 创建 `hermes-cron-tick.timer`（每分钟触发）
> 3. 停止 control gateway（如运行）
> 4. 启用 timer

### 技术边界

- 只创建在 `control/cron/jobs.json` 中（中央集权架构），不写 work/study 的 jobs.json
- profile 自动判断：脚本型→control，Agent干活→work（默认），推送型→按渠道
- 本模式只创建不管理。删除/暂停走 `hermes cron remove/pause`
- 不修改 systemd timer——timer 是基础设施，本模式只管新增 job
- **output 持久化**：script 型（no_agent）输出自动落盘到 `cron/output/<job_id>/<timestamp>.md`。建议将 output 目录映射到 Windows 盘（${D_DRIVE:-D:\\data}\\cron-output\\），方便直接查看

### 参考

- 定时任务全面审计流程参见「审计模式」中的 cron 审计指引
- Hermes cron 命令行参考：`hermes cron --help`
- 旧版→新版 cron 迁移：skill_view(name='system-guardian', file_path='references/old-to-new-cron-migration.md')
- Cron 统一执行器脚本：`skill_view(name='system-guardian', file_path='scripts/cron-wrapper.sh')`（no_agent wrapper 模式，调度层永远 exit=0，API 失败自动重试+写 CRON_ALERT）
- no_agent→Agent 模式转换指南：`skill_view(name='system-guardian', file_path='references/no-agent-to-agent-conversion.md')`

### 已知限制

**`hermes cron tick` 两类 job 都能执行——之前误判为"只能执行脚本型"是因为 schedule 格式损坏导致 scheduler 静默崩溃。**

2026-06-16 排查发现：`hermes cron tick` 在 jobs.json 中任意 job 的 `kind: interval` 格式错误时（如将 `minutes` 键误写为 `every`），整个 cron scheduler 在 `compute_next_run()` 阶段抛出 `KeyError: 'minutes'` 并崩溃，表现为 tick 命令 exit=0 但无任何 job 执行。

**修复后验证：** 修复 memory-watchdog 的 schedule 格式（`{"every": 120}` → `{"minutes": 120}`）后，`hermes cron tick` 成功执行 agent 型 job（每日学习笔记，profile=study，last_status=ok）。

| job类型 | cron tick（schedule 格式正确时） | gateway cron scheduler |
|---------|--------------------------------|----------------------|
| no_agent=true（脚本） | ✅ 可执行 | ✅ 可执行 |
| no_agent=false（Agent） | ✅ 可执行 | ✅ 可执行 |

**注意：如果 cron tick 表现为 exit=0 但 job 不执行（last_run_at 始终 N/A），优先排查 jobs.json 中所有 job 的 schedule 格式是否正确，而不是假设 cron tick 不支持 agent 型。**

**输出落盘：** 无论脚本型还是 Agent 型，hermes cron tick 会自动将 stdout 写入 `cron/output/<job_id>/<timestamp>.md`。通过符号链接 `cron/output/ → ${ARCHIVE_BASE:-~/archive}/cron-output/` 可在 Windows 资源管理器直接查看。

---


## Cron 审计指引


