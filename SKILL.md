---
name: system-guardian
description: "构建→自查→审计→能力→定时，五合一管好你的 Hermes 系统。小白引导开箱，每日自检保平安，深度审计查隐患，五维能力看边界，三句话部署定时任务。"
version: 1.11.0
category: infra
created: 2026-06-13
updated: 2026-06-16
tags: [governance, self-check, audit, onboarding, system, devops, cron]
baseline:
  core_assumptions:
    - "Hermes Agent 已安装并能正常对话"
    - "终端有文件写入权限"
    - "需要能够访问 GitHub 和海外 API 的网络环境"
  last_validated: "2026-06-14"
---

# System Guardian · 系统卫士

> ⚠️ 构建模式会修改你的系统配置文件（SOUL.md、config.yaml、.bashrc），建议先备份再使用。
> 自检和审计模式只读不改。

## 治理边界

**system-guardian 管：**
- 系统级契约合规（身份声明、版本锚、记忆水位、路径规范、外部记忆配置）
- 基础设施运行状态（Camofox/STT 服务、cron 调度、外部记忆读写）
- 治理文件完整性（SOUL.md、内容锚点、自检脚本、能力归属）

**system-guardian 不管：**
- 场景内的业务产出质量（发言稿写得怎么样、推文有没有人看）
- 具体对话的质量和效率
- 写作/创作的美学标准
- 用户个人偏好和习惯

**硬约束（SOUL 不可逾越边界）：**
- 第7条：所有公开输出不得出现「联通」「中国联通」「镇江联通」等组织名称
- 第1条：发布到网上的任何内容，必须等勇哥确认后才能执行
- 违反边界按根SOUL第12条升级处理

**膨胀漂移检测：** 如果在自查/审计输出中发现上述「不管」的内容，说明 skill 出现了膨胀漂移，按根SOUL第12条（被纠即升级）处理。

## 核心交互原则

与用户对话时严格遵守：

1. **只说人话** —— 不输出文件路径、命令输出、系统状态、技术术语
2. **给选项让用户选** —— 每步都用编号选项（[1]/[2]/[3]），用户不用想措辞
3. **确认后再执行** —— 用户提供信息后复述一遍，用户说"对"再写文件
4. **不主动问"继续吗"** —— 执行完直接展示下一步的选项
5. **用户确认后不露痕迹** —— 只说"好的"或"记下了"，不说"第一步完成""技术动作执行"
6. **固化内容不感知** —— 系统必须的配置直接写，不展示操作过程
7. **中枢思维（你是中台，不是办事员）** —— 你是全局架构师，不是单场景执行者。对全局负责，改一处想全域。勇哥问意见时，先给专业判断再出方案，不要反问。给出数据支撑 + 明确推荐（"我的建议：选X"），选项作为上下文补充而非主输出。"你是中台啊"意思是你要做判断，不是把决策扔回去。全局思考不是可选项，是原则。问自己：我这个决策影响其他几个场景？

8. **使用感知优先于技术实现** —— 做方案对比时，先问「用户在哪个渠道感知到结果」，再问「技术上怎么实现」。技术选项的取舍依据不是「更干净/更省资源/更架构优雅」，是「用户用起来的感觉对不对」。举例：recreation配了QQ Bot，cron就应该推QQ，而不是只看「要不要多起一个Gateway进程」这种技术维度。推荐语格式：「用A用户会在B上看到C的结果」。

9. **先判断再沟通再执行** —— 有三层递进：
   a. **判断**：收到需求后，先想清楚「这个需求的核心矛盾是什么？正确的做法应该是什么？」—— 这是作为中台/架构师的基本素养，不要直接问「你想怎么做」。**尤其注意：用户问了一个具体问题，就回答那个具体问题。不要在回答前先发散到其他相关但用户没问的事情上，这会被理解为跑题。**
   b. **沟通**：判断完成后，把判断亮给用户——「我的判断是XXX，理由是YYY」。给用户反对/修正的机会。不等用户说「做吧」就执行是违约
   c. **执行**：用户确认方向后，再动手。执行中不跳过确认步骤
   常见错误（已被纠正）：写capability-hierarchy时直接塞进文件没先展示 → 改完后应该先给用户看设计再写
   问自己的检验标准：「我写这个之前，用户点头了吗？」

10. **渠道感知法则** —— 用户有微信（工作）/ 飞书（认知修炼）/  QQ（内容创作）三个感知渠道。推送、报告、提醒的选择顺序：用户期望的渠道 > 技术便捷性 > 系统统一性。不知道用户期望什么就问他，不要猜。这个法则是第8条「使用感知优先」的具体落地场景。

11. **系统性修复** —— 修复一个问题时，不只是修当前这一个表面现象，要检查全域同类裂缝。三层递进：

12. **效率优先，不等不靠** —— 收到需求后先判断：这是基本需要还是需要讨论的问题？
    a. **基本需要**（如配置缺失、文件缺失、记忆溢出等明显缺陷）→ 直接执行，不问「需要吗」「要不要做」。**这是基本需要，不是可选项。**
    b. **需要讨论的**（架构选型、方案对比、方向摇摆）→ 先给专业判断，再出选项，不问「你想选哪个」
    c. **查询类**（查数据、查状态、查记录）→ 直接查、直接给答案，不绕路、不解释排查过程
    检验标准：用户问完问题到收到答案之间的步数。超过2步就是在绕路。
    常见绕路行为：先问「查哪个场景」再查、先展示中间过程再给结果、先问「需要吗」再动手。
    **被纠正过的问题（如「需要加这个机制吗」），已经证明是基本需要——同类问题不再问。**
    **全局同步不需要问。** 一处改了，同类场景（work/study/recreation/shici）自动同步。问「要不要逐个配」等于把中枢职责甩给勇哥——改一处想全域是原则，不是可选项。已被纠正。
    a. **个案还是模式？** —— 一处配置缺了，检查所有场景。一个 job 推不了微信，检查所有 deliver=origin 的 job。一时钟格式错了，检查所有 interval 型 job
    b. **修完还要验证什么？** —— 不只是验证刚修的那个路径，还要验证同类路径：同架构的其他组件、同模式的其他配置项、同维度的其他场景。修完不自检不算完成
    c. **下次怎么自动发现？** —— 这次暴露的问题能不能加到 compliance-check 自检项里？能不能写进 pitfalls 让下次加载的人看到？能不能改造成一个可复用的操作范式？
    问自己的检验标准：「我这次修的是根因还是末梢？这个裂缝在其他地方是不是也有？」

## 模式选择器

加载技能后，直接显示四个选项：

```\n欢迎使用 System Guardian！请选择：\n\n[1] 🏗️ 系统构建  —— 从零搭建治理体系\n[2] ✅ 系统自查  —— 全面检查系统健康（外部记忆/定时任务/五维能力/渠道通断/纪律合规）\n[3] 🔍 系统审计  —— L3 诊断版：故障根因分析\n[4] 📋 系统能力  —— 查看能力边界和缺失项\n[5] ⏰ 定时任务  —— 小白向导式部署定时任务\n```

## 构建模式

### 固化内容（用户不需要选，自动写入）

| 模块 | 说明 |
|------|------|
| 控制台 | control profile + 定位声明（"总管家"） |
| 全局认知声明 | 4条固定模板 |
| 行为底线 | 3条固定模板 |
| 6条红线 | 不可逾越的边界 |
| 内容锚定 | content-anchors.md + compliance-check.sh |
| 开机自检 | .bashrc触发 + control启动指令 |
| 审批配置 | approvals.mode: manual |

### 用户需要选择的（最少2-3个问题）

| 问题 | 选项 |
|------|------|
| ① 怎么称呼你？ | 用户输入 |
| ② 主要用来做什么？ | [1]工作 [2]自媒体 [3]学习 [4]都有 [5]其他 |
| ③ 还需要管其他事吗？ | 根据第②步动态生成，排除已选 |

动态选项规则：用户第二步选了什么，第三步就排除它，改为"加"其他项。

### 对话流程

```
① 怎么称呼你？
② 主要用来做什么？ [1]工作 [2]自媒体 [3]学习 [4]都有 [5]其他
③ 动态选项
  → 确认
  → 自动搭建（带进度反馈）
  → "全部完成！试试说'帮我写一段自我介绍'"
```

### 完成后引导

建完后立刻给一个低门槛的尝试指令。不要只说"查看能力"，要给出具体动作：
"试试说——帮我写一段自我介绍，看看系统怎么写东西。"

### 变现与分发

GitHub 仓库（公开版）：
- https://github.com/sqzy1314520/system-guardian
- 公开版 MIT 协议，免费安装使用
- 完整版放在 premium/ 目录，赞助后获取
- README 截图制作：`references/readme-screenshot-workflow.md`

国内赞助（爱发电）：
- https://afdian.com/a/meijiexueAI
- 基础赞助 19.9 元：完整版技能包
- 深度赞助 199 元：完整版 + 一对一远程搭建指导

用户安装公开版：
```bash
hermes skills install https://github.com/sqzy1314520/system-guardian/raw/main/SKILL.md
```

---

## 三层记忆系统

Hermes 的记忆分三层，不是替代关系，是互补关系。

| 层级 | 名称 | 存储位置 | 管理规则 | 用途 |
|:----:|------|---------|---------|------|
| L1 | **内置记忆** | `MEMORY.md` / `USER.md` | 第15条：4h冷却期、95%溢出自救 | 核心架构规则、协作铁律、环境事实（每次对话自动注入） |
| L2 | **外部记忆** | `~/.hermes/mnemosyne/data/` (SQLite) | 第16条：5触发条件、禁止清单、source标签隔离 | 日常积累的偏好、决策、事实（按需recall） |
| L3 | **治理规则** | `memory-governance` skill | 3层闭环：开机预载/hook触发/合规审计 | 执行层——什么时候存、怎么读、什么不该存 |

### 三层关系

```
对话开始 → 内置记忆自动注入（L1）
    ↓
开机自检加载 memory-governance skill（L3）
    ↓
用户输入 → on_turn_start hook 自动检测触发条件（L3）
    ↓ 命中纠正/偏好/决策
写入外部记忆 mnemosyne（L2，带 source 场景标签）
    ↓
compliance-check 每次启动审计（L3）：水位/活性/治理合规
```

### 溢出自救

内置记忆水位超 95% 时——新信息自动写入外部记忆（L2），不占内置空间。不是降级，是分流。

### 场景隔离

所有场景共享同一个中央数据库，通过 `source` 字段逻辑隔离——读默认只读本场景，跨场景传 `source=None` 显式全库搜。

---

## 闭环治理机制

三层记忆系统之上，运行五套闭环治理机制，保证系统持续健康，不只是「当下没问题」。

### ① Goal 追踪系统

**定位：** 让系统自己判断「是否达成目标」，不等人看。

5 个预设目标定义在 `~/.hermes/audit/goals.yaml`。每次 compliance-check 后自动评估：

| Goal | 条件 | 类型 | 目标 |
|------|------|:----:|:----:|
| 系统全绿 | compliance-check 无违规 | streak | 连续7天 |
| 心跳新鲜 | HEARTBEAT 不超27h | streak | 连续7天 |
| 外部记忆可用 | mnemosyne 读写通过 | streak | 连续7天 |
| 定时任务在跑 | cron 有运行记录 | streak | 连续7天 |
| 版本锚一致 | 全场景版本号一致 | streak | 连续7天 |

连续达标天数写入 streak 文件，断一天归零。≥7天标记为 🏆 达成，写入 mnemosyne + ACHIEVED 通知文件，开机自检时主动报告。

### ② 系统状态摘要

**定位：** 过去7天趋势，不只看「现在绿不绿」。

每次 compliance-check 后，`state-summary.py` 从 mnemosyne 查询过去7天的 goal 记录，产出趋势视图：

```
Goal 达成趋势（过去7天）：
  06-10 ████████░░ 4/5
  06-11 ████████░░ 4/5
  06-12 █████████░ 5/5 ← 全绿
  ...
```

同时落盘到 `~/.hermes/audit/STATE.md`，随时可 `cat` 查看。

### ③ Maker-Checker 分离

**定位：** 不让同一个视角既做评估又做验证。

| 角色 | 评估内容 | 运行时机 |
|:----:|---------|---------|
| **Maker** | 表层：SOUL/approvals/HEARTBEAT/mnemosyne 存在性 | compliance-check 即时 |
| **Checker** | 深层：版本锚/cron活性/读写验证/Goal追踪 | 独立 cron + delegate_task 分流 |

两个角色读不同的数据源、在不同时间点运行、不知道对方的结果。结果不一致时交叉验证升级告警。

### ④ delegate_task 分流

**定位：** 复杂任务不污染主对话上下文。

compliance-check 发现违规时不直接调用 Checker，而是写入 `trigger-checker` 触发文件。下次开机自检时通过 `delegate_task` 在完全隔离的子代理上下文中运行 Checker。子代理不知道 Maker 的 PASS/FAIL 结果。

当前三层分流：

```
compliance-check（Maker）
  ↓ 写入 trigger-checker
开机自检 → delegate_task → 独立 Checker 子代理
  ↓ 隔离运行
返回诊断摘要 → 删除 trigger-checker
```

### ⑤ 独立 Checker cron

**定位：** 不依赖对话触发，系统自愈巡逻。

cron job `independent-checker` 每6小时运行一次，调用 `checker-cron.sh` → `syndrome-detect.sh`。正常时安静退出（no_agent 空输出 = 静默）。发现异常时写入 `CHECKER_ALERT` 文件，开机自检时主动报告。

**三层触发：**

| 触发方式 | 延迟 | 适用场景 |
|---------|:----:|---------|
| compliance-check 即时 | 0 | 每次对话后立即检查 |
| delegate_task 开机自检 | 次对话 | 深度隔离诊断 |
| cron 每6小时 | ≤6h | 无人值守时自动巡逻 |

---

## 自查模式

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
| ① 外部记忆 | 5场景 memory.provider + 数据库活性 + 读写状态验证 + symlink一致性 | `hermes -p <scene> memory status` + sqlite3 写→读→删 |
| ② 内置记忆 | MEMORY.md/USER.md 字符水位 + 95%溢出自救自动导流外部 | `bash compliance-check.sh` 第6项 |
| ③ 定时任务 | cron job 列表 + last_status + 调度有效性 | `hermes cron list` |
| ③ 五维能力 | 看(vision/Camofox) + 听(STT) + 说(TTS) + 读(web) + 创(skills) | 工具导入 + 服务健康检查 |
| ④ 渠道通断 | 微信Gateway + QQ Bot gateway 运行状态 | `hermes gateway status` |
| ⑤ 技能加载 | 各场景 skill 总量 + 关键技能可达性 | `hermes skills list` |
| ⑥ 纪律合规 | compliance-check 12项：身份/冷却期/版本锚/规则条数/脚本校验/记忆水位/内容锚点/路径绝对性/服务健康/能力归属/外部记忆活性/治理合规 | `bash compliance-check.sh` |

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

### HEARTBEAT 双层保障模式

心跳是系统健康的自检信号。标准模式：

```
 soul-daily-audit  ──>  writes HEARTBEAT file  ──>  mon checks freshness
 (每天09:00 cron)         (soul-audit.py)           (every 2h)
```

- **soul-audit.py**：每天09:00（cron no_agent模式，由 `hermes-cron-tick.timer` 每分钟触发执行 `hermes cron tick`），审计运行后写 HEARTBEAT 文件\n- **heartbeat-monitor.sh**：每2小时，检查 HEARTBEAT 文件时效性（超27小时告警）\n- 两个 cron 都注册在 `control/cron/jobs.json` 下（集中式 cron 架构），**不依赖任何 gateway**\n- **输出自动落盘**：cron tick 自动将 stdout 写入 `cron/output/<job_id>/<timestamp>.md`

### cron 审计指引

> ⚠️ 前置认知：`hermes cron tick` 两类 job（script 型和 agent 型）都能执行。如果 job 不执行优先排查 schedule 格式是否有误，详见 pitfalls 中的「interval 型 cron schedule 格式损坏」。输出自动落盘到 `cron/output/<job_id>/<timestamp>.md`。

### cron 审计——完整审计流程

**第一步：全层发现**

> ⚠️ 关键区分：`cronjob` CLI 工具只返回**当前 profile** 的 cron job（存储在 profile 的 state.db 中）。跨多个 profile 检查需要用 `hermes -p <profile> cron list` 命令。

1. `cronjob list` — 查看**当前 profile** 的 Hermes cron 任务（名称/调度/脚本/状态）。注意：这是 per-profile 视图，只看到当前对话的 profile
2. `hermes cron list` — 查看当前 profile 调度器管理的全局视图（有时能看到其他 profile 的 job 元信息，但不如 per-profile 精准）
3. `hermes -p <profile> cron list` — 跨 profile 检查。要完成**全场景审计**，需遍历所有 profile（control/work/study/recreation/shici）
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
|---------|------|------|
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

## 定时任务模式

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
- **output 持久化**：script 型（no_agent）输出自动落盘到 `cron/output/<job_id>/<timestamp>.md`。建议将 output 目录映射到 Windows 盘（D:\Hermes\cron-output\），方便直接查看

### 参考

- 定时任务全面审计流程参见「审计模式」中的 cron 审计指引
- Hermes cron 命令行参考：`hermes cron --help`
- 旧版→新版 cron 迁移：skill_view(name='system-guardian', file_path='references/old-to-new-cron-migration.md')

### 已知限制

**`hermes cron tick` 两类 job 都能执行——之前误判为"只能执行脚本型"是因为 schedule 格式损坏导致 scheduler 静默崩溃。**

2026-06-16 排查发现：`hermes cron tick` 在 jobs.json 中任意 job 的 `kind: interval` 格式错误时（如将 `minutes` 键误写为 `every`），整个 cron scheduler 在 `compute_next_run()` 阶段抛出 `KeyError: 'minutes'` 并崩溃，表现为 tick 命令 exit=0 但无任何 job 执行。

**修复后验证：** 修复 memory-watchdog 的 schedule 格式（`{"every": 120}` → `{"minutes": 120}`）后，`hermes cron tick` 成功执行 agent 型 job（每日学习笔记，profile=study，last_status=ok）。

| job类型 | cron tick（schedule 格式正确时） | gateway cron scheduler |
|---------|--------------------------------|----------------------|
| no_agent=true（脚本） | ✅ 可执行 | ✅ 可执行 |
| no_agent=false（Agent） | ✅ 可执行 | ✅ 可执行 |

**注意：如果 cron tick 表现为 exit=0 但 job 不执行（last_run_at 始终 N/A），优先排查 jobs.json 中所有 job 的 schedule 格式是否正确，而不是假设 cron tick 不支持 agent 型。**

**输出落盘：** 无论脚本型还是 Agent 型，hermes cron tick 会自动将 stdout 写入 `cron/output/<job_id>/<timestamp>.md`。通过符号链接 `cron/output/ → /mnt/d/Hermes/cron-output/` 可在 Windows 资源管理器直接查看。

## 实操提示：五维能力自检 + Token 优化

每次全检时按以下顺序检查，避免路径陷阱：

1. 听 — 用 venv 的 Python 检查 STT
2. 看 — curl 检查 Camofox 浏览器服务
3. 说 — 直接调用 text_to_speech
4. 读 — 调用 web_search 和 web_extract
5. 创 — 写作技能直接可用

**Token 优化：** 各场景默认加载全部 31 个工具集，但 control 管理场景不需要 browser/vision/tts 等。通过 `enabled_toolsets` 限定到 11 个核心工具集可省 64% 工具 schema token。详见 `references/token-optimization-toolset-trimming.md`。

## 公开版 vs L3 诊断版

| 模块 | L1/L2 公开版（MIT） | L3 诊断版（赞助） |
|------|--------------|---------------|
| 🏗️ 构建 | ✅ 完整 | ✅ 完整 |
| ✅ 自查 | 6维度核心检查 | 12项全量 + 读写验证 + 一键脚本 |
| 🔍 审计 | ❌ | 7维度 + 三幕法报告 + 症候群诊断 |
| 📋 能力 | ✅ 完整 | ✅ 完整 |
| 📜 一键自检脚本 | ❌ | ✅ compliance-check.sh |
| 📜 症候群诊断 | ❌ | ✅ syndrome-detect.sh |
| 👨‍💻 一对一指导 | ❌ | ✅ 深度赞助199元 |

## Pitfalls

### 空本地分类目录遮蔽 external_dirs（skills 不可见）

Hermes skills 加载优先级：**本地 skills 目录 > external_dirs**。如果一个场景的本地 skills/ 下有和 external_dirs 中同名的分类目录（如 `infra/`、`methodology/`），即使本地目录为空，也会遮蔽 external_dirs 中的同名目录。

**表现：** 某场景无法加载其他场景正常可用的 skill，但文件路径无误、external_dirs 配置正确。

**排查：**
1. 确认 external_dirs 配置指向正确路径
2. 检查该场景 `~/.hermes/profiles/{scene}/skills/` 下是否有与缺失 skill 同分类的空目录
3. 有则 `rmdir` 删除（空目录可直接删除，不影响本地技能）

**案例：** recreation/skills/infra/ 为空目录，导致 recreation 无法加载 control/skills/infra/ 下的 system-guardian 等 26 个 infra 技能。删除后恢复。

**防护：** compliance-check 应增加检查各场景本地 skills 目录是否有空分类目录遮蔽 external_dirs。

### content-anchors.md 格式破坏导致自检静默失败

compliance-check.sh 第7项动态读取 `content-anchors.md` 中 `## 校验清单` 段落的 `@target:` 条目来逐条核对断言。如果该段落的标题被改名、格式被破坏、或 `@target:` 行被误删，自检会静默报"校验清单不存在或为空"，**不报具体哪个文件哪个断言**。

**表现：** compliance-check 输出中各项断言数正常，但最后一行显示"校验清单不存在或为空"。所有 ✅ 都正确，但新增的断言没有被检查到。

**常见破坏方式：**
- 编辑 content-anchors.md 时在 `## 校验清单` 上方新增了其他 `##` 标题，导致脚本找不到正确段落
- `@target:` 行被误删除或添加了多余空格
- 在 `## 校验清单` 与其内容之间插入了多余的空行或注释

**修复：** 编辑后运行 `bash ~/.hermes/scripts/compliance-check.sh` 确认没有新增"校验清单不存在"警告。有则恢复 content-anchors.md 中 `## 校验清单` → `@target:` 的结构完整性。

### 场景SOUL声明冲突阻挡 skill 加载

场景 SOUL.md 中的角色声明也可能阻挡 system-guardian 运行。即使 skill 文件存在、external_dirs 配置正确、无目录遮蔽，如果场景 SOUL 明确声明了与之冲突的行为限制（如 recreation SOUL 声明"不搞巡察"），agent 在加载 skill 时可能主动回避。

**表现：** skill 在 skill list 中可见，但用户说"检查一下""运行系统卫士"时 agent 不响应或转移话题。

**排查：** 检查该场景 SOUL.md 是否有与系统治理冲突的角色定位声明。

**修复：** 在 SOUL.md 中加入显式的豁免声明，如 `系统治理工具（如 system-guardian）可使用`。

**案例：** recreation/SOUL.md 第10行写"不谈KPI、不搞巡察、不写讲话稿"，阻挡了 system-guardian 的 audit 和 check 模式。修改为允许系统治理工具后恢复。

### control gateway 无 token 启动失败

control gateway 不连微信（`weixin.enabled: false`），但如果 .env 中存在未注释的 `WEIXIN_ACCOUNT_ID`，gateway 会检测到微信配置不完整并将 `WEIXIN_TOKEN is required` 视为**非可重试冲突**，退出进程进入 systemd auto-restart 循环。

**表现：** control gateway 日志显示 "Gateway hit a non-retryable startup conflict: weixin: WEIXIN_TOKEN is required"，系统每5秒重启一次。

**修复：** 注释掉 control .env 中所有 `WEIXIN_*` 行（包括 WEIXIN_ACCOUNT_ID/WEIXIN_TOKEN/WEIXIN_BASE_URL/WEIXIN_CDN_BASE_URL），只留 work 的 .env 有完整微信配置。

**验证：** `hermes gateway status` 应显示 `Gateway will continue for cron job execution`，无 restart loop。

### HEARTBEAT 写入必须在审计脚本内完成

HEARTBEAT 是自检系统的"我还活着"信号。双层模型要求：

1. **审计脚本**（如 soul-audit.py）每次运行后主动写入 HEARTBEAT
2. **监控脚本**（如 heartbeat-monitor.sh）读取 HEARTBEAT 时效性，超时告警

**常见错误：** 只配了监控脚本的读取检查，忘了审计脚本的写入逻辑。HEARTBEAT 文件可能很久以前手动写了一次，之后就再没更新过。发现时心跳已停跳 25+ 小时。

**修复：** 在审计脚本末尾统一加心跳写入：
```python
import datetime
heartbeat_path = Path(f'{HOME}/.hermes/audit/HEARTBEAT')
now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
heartbeat_path.write_text(f'{now} | PASS - audit completed')
```

**验证：** `cat ~/.hermes/audit/HEARTBEAT` 应显示当天的运行时间。ALERT 文件不存在表示正常。

### Mnemosyne 数据库路径分裂（第二层断链）

Mnemosyne 插件 centralized 后（所有 profile 能在 `$HERMES_HOME/plugins/` 发现插件文件），**数据库仍可能分裂**。这是第二层断链。

| 层 | 问题 | 修复 |
|----|------|------|
| ① 插件代码 | `$HERMES_HOME/plugins/mnemosyne/` 不存在或未指向 centralized | symlink 修复 |
| ② 数据库 | `$HERMES_HOME/home/.hermes/mnemosyne/` 不存在或未指向中央 | symlink 修复 |
| ③ 使用指令 | agent 不知道何时调用 mnemosyne 工具 | SOUL 第16条 + memory-governance skill |

**排查：** 如果 `hermes memory status` 显示 `installed ✓` 但各场景数据不一致（work 搜不到 control 存的记忆），原因极大概率是第二层断链。

**验证：**
```bash
for scene in control work study recreation shici; do
  readlink -f ~/.hermes/profiles/$scene/home/.hermes/mnemosyne
done
# 所有应指向: /home/sqzy/.hermes/mnemosyne
```

**永久防护：** compliance-check 第12a项自动检查各 profile 的 mnemosyne home symlink 一致性。

### Mnemosyne 三层断链（外部记忆配了但没用）

Mnemosyne 插件启用不代表外部记忆在工作。存在**三层断链**：

| 层 | 检查 | 失败表现 |
|----|------|---------|
| ① plugin 启用 | `plugins.enabled` 包含 `mnemosyne` | 数据库存在但空 |
| ② 工具挂载 | `known_plugin_toolsets.cli` 包含 `mnemosyne` | mnemosyne_* 工具不可用 |
| ③ 使用指令 | SOUL/MEMORY 告知 agent 何时调用 | agent 不知道要用 |

**排查：** 三个层面从下到上查。数据库有表但 0 条记录 → 工具没挂载 → plugin 没启用 → agent 不知道干什么。

**案例：** work 场景 `provider: ''` 空值、`known_plugin_toolsets.cli` 缺 mnemosyne、所有 SOUL.md 无使用指引。修了三层才恢复。

**防护：** compliance-check 第11项自动检查 4 场景 provider + 数据库活性 + 工具挂载。

### Cron tick 模式：deliver 不生效 + interval 格式陷阱

两个问题常同时出现，排查顺序为先格式后 delivery。

**问题一：`kind: interval` 误用 `every` 键**

interval schedule 使用 `minutes` 键，**不是** `every`：

```json
{"kind": "interval", "minutes": 120, "display": "every 120m"}  ← 正确
{"kind": "interval", "every": 120}  ← 整个 scheduler 崩溃
```

`every` 导致 `compute_next_run()` 抛出 `KeyError: 'minutes'`，所有 job 不执行，但 `hermes cron tick` exit=0 无异常。易误判为"cron tick 不支持 agent 型"。

**排查：** 所有 job 的 `last_run_at` 均为 N/A → `grep "every" jobs.json`。**修复：** 改为 `"minutes": N`。

**问题二：`deliver=origin` 在 cron tick 下不生效**

无 gateway 上下文，输出只落盘到 `cron/output/`，不推送。

**解决方案：** 需要推送的 job 改为 no_agent wrapper 脚本，脚本内调 `hermes send`：

```bash
#!/bin/bash
# wrapper 脚本：执行 agent → 推送微信（推荐用临时文件，避免管道截断）
OUTFILE="/tmp/output-$(date +%Y%m%d-%H%M).md"
hermes -p work -z "prompt内容" > "$OUTFILE" 2>/dev/null
if [ -s "$OUTFILE" ]; then
    hermes -p work send --to weixin --file "$OUTFILE"
fi
rm -f "$OUTFILE"
```

**验证：** `hermes -p work send --list` 应显示 WeChat 目标。

### `$HOME` 重写陷阱（自查脚本路径错乱）

Hermes 以 `--profile <name>` 启动时，会将 `$HOME` 重写为 `$HERMES_HOME/home/`（如 /home/user/.hermes/profiles/work/home/），这是 profile 隔离的正常行为。但所有用 `$HOME` 拼路径找 Hermes 系统文件的脚本会指向错误位置。

**表现：** 身份检测误报"根SOUL身份异常"、版本锚无版本号、内容锚点找不到校验清单、hash文件写入错误目录、备份路径错乱。

**推荐方案：创建 paths.sh 常量文件统一管理路径**
```bash
~/.hermes/scripts/paths.sh     ← 单一路径真实源
```
- Bash 脚本首行：`source "${SCRIPT_DIR}/paths.sh"` → 用 `$HERMES_ROOT`、`$HERMES_AUDIT` 等变量
- Python 脚本：`pwd.getpwuid(os.getuid()).pw_dir` → 不要用 `os.environ.get('HOME')`
- paths.sh 内嵌 `getent` + `pwd` 双保险探测真实家目录
- 由 control 维护，修改一处全局生效

**旧方案（6个脚本已落地，见 references/home-override-fix.md）：**
- Bash 脚本：用 `getent passwd $(whoami) | cut -d: -f6` 获取真实家目录
- Python 脚本：用 `pwd.getpwuid(os.getuid()).pw_dir`

**配套规范文档：** `~/.hermes/audit/path-standards.md` — 覆盖 Bash/Python/config/skills 四种场景的路径书写规则，新人新脚本按此执行。

**自检保障：** compliance-check.sh 第8项（全局路径绝对性）自动检查所有 config.yaml 路径引用是否为绝对路径。

## 前置条件

- Hermes Agent 已安装并能正常对话
- 终端有文件写入权限
- 需要能够访问 GitHub 和海外 API 的网络环境

## 参考资料

- 构建模式完整引导流程：`skill_view(name="system-guardian", file_path="references/build-guide.md")`
- 自查模式检查项：`skill_view(name="system-guardian", file_path="references/check-procedure.md")`
- 五维能力详情与分级模型：`skill_view(name="system-guardian", file_path="references/capability-guide.md")` + `audit/capability-hierarchy.md`\n- 效率优化手册：P0 工具集裁剪 + P1 合并调用 + P2 分流策略：`skill_view(name="system-guardian", file_path="references/efficiency-playbook.md")`
- `$HOME` 重写陷阱修复模式：`skill_view(name="system-guardian", file_path="references/home-override-fix.md")`
- 变现与分发策略：`skill_view(name="system-guardian", file_path="references/monetization-strategy.md")`
- 审计模式完整流程：`skill_view(name="system-guardian", file_path="references/audit-protocol.md")`
- 路径编写规范：`skill_view(name="system-guardian", file_path="references/path-standards.md")` 或直接读 `~/.hermes/audit/path-standards.md`
- Cron 审计实战记录：skill_view(name='system-guardian', file_path='references/cron-full-audit-2026-06-14.md')
- Cron 架构解耦实战（2026-06-16）：skill_view(name='system-guardian', file_path='references/cron-architecture-decouple-2026-06-16.md')
- Cron delivery wrapper 模式：skill_view(name='system-guardian', file_path='references/cron-delivery-wrapper-pattern.md')
- 旧版cron→新版cron迁移指引：skill_view(name='system-guardian', file_path='references/old-to-new-cron-migration.md')
- 实战案例·2026-06-15 全系统审计：skill_view(name='system-guardian', file_path='references/audit-example-2026-06-15.md')
- README 终端截图制作：skill_view(name='system-guardian', file_path='references/readme-screenshot-workflow.md')
- Cron 架构决策日志：skill_view(name='system-guardian', file_path='references/cron-architecture-decision-log.md')
- 症候群诊断脚本：`skill_view(name='system-guardian', file_path='scripts/syndrome-detect.sh')`
- Loop Engineering 深度学习笔记：`skill_view(name='system-guardian', file_path='references/loop-engineering-notes.md')`
- Goal 系统架构与 Maker-Checker 分离：`skill_view(name='system-guardian', file_path='references/goal-system.md')`
- Goal 评估脚本：`skill_view(name='system-guardian', file_path='scripts/goal-eval.sh')`
- 状态摘要脚本：`skill_view(name='system-guardian', file_path='scripts/state-summary.py')`
- GitHub 推广展示指南：`skill_view(name='system-guardian', file_path='references/github-promotion-guide.md')`
