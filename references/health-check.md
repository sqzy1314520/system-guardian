# 健康检查 · Health Check

*本文件由 system-guardian 主 SKILL.md (v3.1.0) 拆分生成。加载方式：`skill_view("system-guardian", "references/health-check.md")`*

---

## 健康检查模式


> 对应阶段②「检查一下系统还好吗」。用户说这句话时进入此模式。
>
> **输出完报告后必须回到菜单。**

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

三项全通过 → 运行全功能健康检查，覆盖6个维度：

| 维度 | 检查内容 | 验证方法 |
|:----:|---------|---------|
| ① 外部记忆 | 3场景（control/researcher/writer）memory.provider + 数据库活性 + 读写状态验证 | `hermes -p <scene> memory status` + sqlite3 写→读→删 |
| ② 内置记忆 | MEMORY.md/USER.md 字符水位 + 95%溢出自救自动导流外部 | `bash compliance-check.sh` 第6项 |
| ③ 定时任务 | cron job 列表 + last_status + 调度有效性 | `hermes cron list` |
| ③ 五维能力 | 看(vision) + 听(STT) + 说(TTS) + 读(web/search) + 创(skills) | 工具导入 + 服务健康检查 |
| ④ 通道通断 | default gateway + 飞书通道 + 微信（待重连） | `hermes gateway status` |
| ⑤ 技能加载 | 全局 skill 总量 + researcher/writer 关键技能可达性 | `hermes skills list` |
| ⑥ 执行层健康 | researcher cron + writer cron 上次运行状态 | `hermes cron list` grep researcher/writer |
| ⑦ 纪律合规 | compliance-check 12项 | `bash compliance-check.sh` |

输出格式：一张表，每项绿/黄/红。绿=正常，黄=有告警但不阻塞，红=需修复。

**与审计模式（模式3）的区别：**

自查回答「系统现在好用吗」——功能可见性检查，覆盖广但不深。
审计回答「系统架构健康吗」——架构穿透性检查，7维度三幕法，发现裂缝分级定修复方向。

**症候群诊断（v1.10.0）：** compliance-check 运行后自动调用 `scripts/syndrome-detect.sh`，检测关联故障模式并指向根因。不重新检查各项，只读取已存在的文件做关联分析。目前支持3种症候群：

**Goal 评估（v1.11.0）：** compliance-check 运行后自动调用 `scripts/goal-eval.sh`，评估5个系统目标的达成状态。每个 goal 支持连续天数追踪（streak），达标 target_days 后自动标记 🏆 达成。评估结果持久化到 mnemosyne（source=__goal__）。目标定义在 `goals.yaml`。

| 症候群 | 症状组合 | 诊断 |
|--------|---------|------|
| 版本漂移 | 版本锚不一致 + 规则条数不一致 | 「改过根SOUL但忘了同步场景」 |
| 治理未初始化 | approvals缺失 + audit不完整 + 无锚点 | 「装完Hermes没跑构建」 |
| 调度停跳 | HEARTBEAT超27h + cron全部N/A | 「定时调度器崩了」 |
| 包干嫌疑 | dispatch日志无记录 + 近期有交付 | 「跳过了 agent 链自己干了」 |

症候群仅在 compliance-check 有违规或警告时触发。全部通过时跳过。

常见自查发现的黄/红项及处理方式见下方规律表。

### 审计发现的常见模式

审计过程中常见以下系统性裂缝：

| 裂缝类型 | 特征 | 修复方向 |
|---------|------|---------|
| 配置缺失 | approvals.mode 未配置、external_dirs 遗漏 | 补充显式基线声明 |
| 心跳停跳 | HEARTBEAT 超24h未更新、cron未注册 | 注册 no_agent 模式 cron job：审计脚本写心跳 + 监控脚本查心跳（双层保障） |
| 路径硬编码 | 脚本中 `/home/用户名/` 散落多处 | 创建 paths.sh 常量文件统一引用，加入第8项自检 |
| 占位符残留 | `/path/to/root` 等未替换 | 审查 MCP / config 中的占位符 |
| 版本漂移 | 各场景 SOUL.md 版本号不一致 | 统一到 control 维护 |
| **cron双注册** | 同一脚本同时在系统crontab和Hermes cron中运行 | 系统crontab清理旧条目，Hermes cron作为唯一管理入口 |
| **外部记忆断链** | Mnemosyne插件启用但工具未挂载、数据库无记录、场景未配 | 三层层级排查：plugin→known_plugin_toolsets→platform_toolsets→SOUL指令 |
| **$HOME 重写**（2026-06-16 新增） | profile mode 下 `~` 和 `$HOME` 被重写 | 见 `references/home-override-fix.md` 系统性扫描方法论 |

### HEARTBEAT 双层保障模式

心跳是系统健康的自检信号。标准模式：

```
 soul-daily-audit  ──>  writes HEARTBEAT file  ──>  mon checks freshness
 (每天09:00 cron)         (soul-audit.py)           (every 2h)
```

- **soul-audit.py**：每天09:00（cron no_agent模式，由 `hermes-cron-tick.timer` 每分钟触发执行 `hermes cron tick`），审计运行后写 HEARTBEAT 文件
- **heartbeat-monitor.sh**：每2小时，检查 HEARTBEAT 文件时效性（超27小时告警）
- 两个 cron 都注册在 `control/cron/jobs.json` 下（集中式 cron 架构），**不依赖任何 gateway**
- **输出自动落盘**：cron tick 自动将 stdout 写入 `cron/output/<job_id>/<timestamp>.md`

### cron 审计指引

> ⚠️ 前置认知：`hermes cron tick` 两类 job（script 型和 agent 型）都能执行。如果 job 不执行优先排查 schedule 格式是否有误，详见 pitfalls 中的「interval 型 cron schedule 格式损坏」。输出自动落盘到 `cron/output/<job_id>/<timestamp>.md`。

### cron 审计——完整审计流程

**第一步：全层发现**

> ⚠️ 关键区分：`cronjob` CLI 工具只返回**当前 profile** 的 cron job（存储在 profile 的 state.db 中）。跨多个 profile 检查需要用 `hermes -p <profile> cron list` 命令。

1. `cronjob list` — 查看**当前 profile** 的 Hermes cron 任务（名称/调度/脚本/状态）。注意：这是 per-profile 视图，只看到当前对话的 profile
2. `hermes cron list` — 查看当前 profile 调度器管理的全局视图（有时能看到其他 profile 的 job 元信息，但不如 per-profile 精准）
3. `hermes -p <profile> cron list` — 跨 profile 检查。要完成**全场景审计**，需遍历所有 profile（control/work/recreation）
4. **并行方案（推荐）**：用 `delegate_task` 并行查多个 profile——每个子任务跑 `hermes -p <scene> cron list`，汇总返回。当前用户 max_concurrent_children=3，分两批可覆盖全场景
5. `crontab -l 2>/dev/null` — 查看系统 crontab 是否有旧条目（双注册冲突源头）
6. `ls /etc/cron.d/ /etc/cron.hourly/ /etc/cron.daily/ 2>/dev/null` — 查看系统 cron 目录
7. `hermes cron status` — 确认 Hermes cron 调度器正在运行
8. 检查各场景 `profiles/{scene}/cron/jobs.json` — 旧版 cron 存储（JSON 格式，work/study/recreation 可能仍在使用）

**第二步：逐项激活条件检查**
对每个 cron 任务检查：
- 脚本文件存在？
- 脚本引用路径是否正确（绝对路径或 paths.sh 变量）？
- Hermes cron：`enabled=true`, `state=scheduled`？
- 系统 crontab：路径是绝对路径？
- 脚本权限：可执行？
- 环境依赖：$HOME 是否被 profile 隔离重写？
- last_run_at + last_status + last_error 是否有异常

**第三步：交叉比对**
- 同一脚本是否在两个 cron 层中同时注册（系统 crontab 和 Hermes cron 各有一条）？→ 保留 Hermes cron 管理入口，清理系统 crontab 旧条目
- 投递目标（deliver）是否仍有效？weixin/lark/feishu 通道是否配置？

**第四步：逐条确认**
按场景分组，向用户逐条呈现：
- 任务名 + 调度 + 末次运行时间 + 状态
- 已稳定运行的标记 ✅，有异常标记 ❌ 并说明原因
- 用户说"留"则跳过，"删"则移除
- 用户说"查查原因"则深入调查（agent.log、输出日志、脚本内容）

**常见 cron 错误模式：**

| 错误特征 | 根因 | 修复 |
|---------|------|---------|
| `'you passed .'` 或空模型名报错 | `model: null`，API 收到空字符串 | 补 model + provider/base_url 字段 |
| `Script not found:` + 路径 | 脚本在 centralized `~/.hermes/scripts/` 但 cron 从 profile 的 `scripts/` 找 | 建软链或改为绝对路径 |
| `skill not found, skipping` | skill 名拼错或分类被空本地目录遮蔽 | 检查 external_dirs + 同名目录 |
| `Blocked: script path resolves outside the scripts directory` | 脚本是符号链接，Hermes 安全策略阻止跨目录脚本执行 | 把脚本物理复制到 profile 的 `scripts/` 目录，不要用软链 |
| `no delivery target resolved for deliver=origin` | profile 未配置 Gateway 通道，`origin` 找不到推送目标 | 确认该 profile 的 Gateway 是否运行；无则改为 `local` 或指定具体通道 |
| **Agent 型 job last_run_at 始终为 N/A，cron tick exit=0 但不执行** | **schedule 格式损坏**——jobs.json 中任一个 interval job 的 `kind: interval` 缺少 `minutes` 键（如误写成 `every`），导致 `compute_next_run()` 崩溃，scheduler 静默挂起 | 检查 `jobs.json` 中所有 `kind=interval` 的 job，确保格式为 `{\"kind\": \"interval\", \"minutes\": N}` 而非 `{\"every\": N}` |

**跨 profile cron 管理：** `cronjob` 工具只操作当前 profile 的 cron/jobs.json。要修其他 profile 的 cron：切换到目标 profile 执行 `cronjob`，或直接编辑目标 `profiles/{scene}/cron/jobs.json`（需 `cross_profile=True`）。

**第五步：整理输出**
汇总：总任务数 / 正常运行 / 已暂停 / 有异常 / 待首次

完整版审计使用6维度探针，参考 `references/audit-protocol.md`。


---

## 审计常见模式

### 审计发现的常见模式

审计过程中常见以下系统性裂缝：

| 裂缝类型 | 特征 | 修复方向 |
|---------|------|---------|
| 配置缺失 | approvals.mode 未配置、external_dirs 遗漏 | 补充显式基线声明 |
| 心跳停跳 | HEARTBEAT 超24h未更新、cron未注册 | 注册 no_agent 模式 cron job：审计脚本写心跳 + 监控脚本查心跳（双层保障） |
| 路径硬编码 | 脚本中 `/home/用户名/` 散落多处 | 创建 paths.sh 常量文件统一引用，加入第8项自检 |
| 占位符残留 | `/path/to/root` 等未替换 | 审查 MCP / config 中的占位符 |
| 版本漂移 | 各场景 SOUL.md 版本号不一致 | 统一到 control 维护 |
| **cron双注册** | 同一脚本同时在系统crontab和Hermes cron中运行 | 系统crontab清理旧条目，Hermes cron作为唯一管理入口 |
| **外部记忆断链** | Mnemosyne插件启用但工具未挂载、数据库无记录、场景未配 | 三层层级排查：plugin→known_plugin_toolsets→platform_toolsets→SOUL指令 |
| **$HOME 重写**（2026-06-16 新增） | profile mode 下 `~` 和 `$HOME` 被重写 | 见 `references/home-override-fix.md` 系统性扫描方法论 |


---

## HEARTBEAT 双层保障

HEARTBEAT 双层保障模式

心跳是系统健康的自检信号。标准模式：

```
 soul-daily-audit  ──>  writes HEARTBEAT file  ──>  mon checks freshness
 (每天09:00 cron)         (soul-audit.py)           (every 2h)
```

- **soul-audit.py**：每天09:00（cron no_agent模式，由 `hermes-cron-tick.timer` 每分钟触发执行 `hermes cron tick`），审计运行后写 HEARTBEAT 文件
- **heartbeat-monitor.sh**：每2小时，检查 HEARTBEAT 文件时效性（超27小时告警）
- 两个 cron 都注册在 `control/cron/jobs.json` 下（集中式 cron 架构），**不依赖任何 gateway**
- **输出自动落盘**：cron tick 自动将 stdout 写入 `cron/output/<job_id>/<timestamp>.md`

