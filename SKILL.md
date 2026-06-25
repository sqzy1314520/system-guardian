---
name: system-guardian
description: "系统卫士 v3.0 -- 四阶段引导：搭建/日检/故障/成长。快速让新手跑起来，同时保留全部 10 项底层能力。构建/定时/目标功能已迁回，不再需要额外加载独立技能。"
version: 3.0.0
category: infra
created: 2026-06-13
updated: 2026-06-24
changelog:
  - 3.0.0: 四阶段重构——用户入口改为4个日常问题（搭建/日检/故障/成长）。底层10项能力全部保留。拆分出的cron-manager标记reference（迁回），system-onboarding标记deprecated（归档）。新增dispatch审计。42个reference精简为10个活跃。22条Pitfalls精简为12条活跃。
tags: [governance, self-check, audit]
baseline:
  core_assumptions:
    - "Hermes Agent 已安装并能正常对话"
    - "终端有文件写入权限"
    - "需要能够访问 GitHub 和海外 API 的网络环境"
  last_validated: "2026-06-14"

health: infrastructure

# System Guardian · 系统卫士

> ⚠️ 构建模式会修改你的系统配置文件（SOUL.md、config.yaml、.bashrc），建议先备份再使用。
> 自检和审计模式只读不改。

## 拆分说明

**v3.0 重构：** 系统卫士从「系统监控工具」进化为「新生入学指南」。10 项底层能力全部保留，用户入口改为 4 个日常问题。

| 阶段 | 导航 | 对应底层能力 |
|:----|:-----|:-----------|
| 🆕 我刚装好，帮我跑起来 | 快速搭建 | 构建+自查初始化+Gateway |
| ✅ 检查一下系统还好吗 | 日常日检 | 自查+心跳+Goal+SLA |
| 🔧 出问题了，帮我看看 | 故障处理 | 审计+症候群+dispatch审计 |
| 🚀 我想加个新功能 | 成长向导 | cron创建+配置管理+新profile |

已迁回的技能：`cron-manager` → reference（无独立逻辑），一次加载全管。

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
- 第7条：所有公开输出不得出现组织名称（通用约束，发布前用户确认）
- 第1条：发布到网上的任何内容，必须等勇哥确认后才能执行
- 违反边界按根SOUL第12条升级处理

**膨胀漂移检测：** 如果在自查/审计输出中发现上述「不管」的内容，说明 skill 出现了膨胀漂移，按根SOUL第12条（被纠即升级）处理。

**错误库（被纠即升级）：** 每次系统性错误（凭感觉操作导致连锁故障、违反自有规范等）记录到 `~/.hermes/audit/error-log.md`。每条记录包含：错误描述、根因分析、产出机制、修正行动。这是根SOUL第12条的执行层——不产出机制不算闭环。

## 核心交互原则

与用户对话时严格遵守：

1. **只说人话** —— 不输出文件路径、命令输出、系统状态、技术术语
2. **给选项让用户选** —— 每步都用编号选项（[1]/[2]/[3]），用户不用想措辞
3. **确认后再执行** —— 用户提供信息后复述一遍，用户说"对"再写文件
4. **不主动问"继续吗"** —— 执行完直接展示下一步的选项
5. **用户确认后不露痕迹** —— 只说"好的"或"记下了"，不说"第一步完成""技术动作执行"
6. **固化内容不感知** —— 系统必须的配置直接写，不展示操作过程
7. **中枢思维（你是中台，不是办事员）** —— 你是全局架构师，不是单场景执行者。对全局负责，改一处想全域。勇哥问意见时，先给专业判断再出方案，不要反问。给出数据支撑 + 明确推荐（"我的建议：选X"），选项作为上下文补充而非主输出。"你是中台啊"意思是你要做判断，不是把决策扔回去。全局思考不是可选项，是原则。问自己：我这个决策影响其他几个场景？

   **完成工作后必须主动验证。** 修了 A 场景的配置，切到 A 场景实测通不通。改了根 SOUL，确认其他场景启动时协议加载是否正常。不能在 control 改完就当完成了——目标场景没验证等于没修。验证三问：①我改了什么？②这个改动会影响哪些场景/服务？③我在目标场景/服务上验证了吗？

8. **使用感知优先于技术实现** —— 做方案对比时，先问「用户在哪个渠道感知到结果」，再问「技术上怎么实现」。技术选项的取舍依据不是「更干净/更省资源/更架构优雅」，是「用户用起来的感觉对不对」。举例：recreation配了QQ Bot，cron就应该推QQ，而不是只看「要不要多起一个Gateway进程」这种技术维度。推荐语格式：「用A用户会在B上看到C的结果」。

9. **先判断再沟通再执行** —— 有三层递进：
   a. **判断**：收到需求后，先想清楚「这个需求的核心矛盾是什么？正确的做法应该是什么？」—— 这是作为中台/架构师的基本素养，不要直接问「你想怎么做」。**尤其注意：用户问了一个具体问题，就回答那个具体问题。不要在回答前先发散到其他相关但用户没问的事情上，这会被理解为跑题。**
   b. **沟通**：判断完成后，把判断亮给用户——「我的判断是XXX，理由是YYY」。给用户反对/修正的机会。不等用户说「做吧」就执行是违约
   c. **执行**：用户确认方向后，再动手。执行中不跳过确认步骤
   常见错误（已被纠正）：写capability-hierarchy时直接塞进文件没先展示 → 改完后应该先给用户看设计再写
   问自己的检验标准：「我写这个之前，用户点头了吗？」

10. **渠道感知法则** —— 用户有微信（工作）/ 飞书（认知修炼）/  QQ（内容创作）三个感知渠道。推送、报告、提醒的选择顺序：用户期望的渠道 > 技术便捷性 > 系统统一性。不知道用户期望什么就问他，不要猜。这个法则是第8条「使用感知优先」的具体落地场景。

11. **系统性修复** —— 修复一个问题时，不只是修当前这一个表面现象，要检查全域同类裂缝。三层递进：
    a. **个案还是模式？** —— 一处配置缺了，检查所有场景。一个 job 推不了微信，检查所有 deliver=origin 的 job。一时钟格式错了，检查所有 interval 型 job
    b. **修完还要验证什么？** —— 不只是验证刚修的那个路径，还要验证同类路径：同架构的其他组件、同模式的其他配置项、同维度的其他场景。修完不自检不算完成
    c. **下次怎么自动发现？** —— 这次暴露的问题能不能加到 compliance-check 自检项里？能不能写进 pitfalls 让下次加载的人看到？能不能改造成一个可复用的操作范式？
    问自己的检验标准：「我这次修的是根因还是末梢？这个裂缝在其他地方是不是也有？」

12. **效率优先，不等不靠** —— 收到需求后先判断：这是基本需要还是需要讨论的问题？
    a. **基本需要**（如配置缺失、文件缺失、记忆溢出等明显缺陷）→ 直接执行，不问「需要吗」「要不要做」。**这是基本需要，不是可选项。**
    b. **需要讨论的**（架构选型、方案对比、方向摇摆）→ 先给专业判断，再出选项，不问「你想选哪个」
    c. **查询类**（查数据、查状态、查记录）→ 直接查、直接给答案，不绕路、不解释排查过程
    检验标准：用户问完问题到收到答案之间的步数。超过2步就是在绕路。
    常见绕路行为：先问「查哪个场景」再查、先展示中间过程再给结果、先问「需要吗」再动手。
    **被纠正过的问题（如「需要加这个机制吗」），已经证明是基本需要——同类问题不再问。**
    **全局同步不需要问。** 一处改了，同类场景（control/work/recreation）自动同步。问「要不要逐个配」等于把中枢职责甩给勇哥——改一处想全域是原则，不是可选项。已被纠正。

13. **操作前置查证（SOUL 12a）** —— 涉及以下任何一项的操作，必须先联网查证 Hermes 官方文档或社区 issue，确认副作用后再执行，不得凭感觉或经验判断：
    - `{HERMES_HOME}/home/` 目录的创建、修改、删除
    - `$HOME`、`PATH`、`HERMES_HOME` 等环境变量的修改
    - 系统目录（`/etc`、`/usr`、`/opt` 等）的写操作
    - 配置项的含义不明确时直接 `config set`
    - 任何涉及 profile 隔离机制的路径操作
    查证后必须向勇哥简要说明「我查到了什么、打算怎么做、有无已知副作用」，确认后再执行。
    **关键教训（2026-06-16）：** 修改 `$HOME` 重写相关代码前，先查社区 issue（#8669、#892）确认社区标准做法。不要自己发明方案——你以为是对的可能是偏离正统的。被用户指出"符合官方标准吗"才发现方向错了，光是回退就花了大量时间。

14. **调查优先于修复（2026-06-18 纠正）** —— 遇到系统故障时，先查官方文档和社区 issue 再动手，这是普适原则，不只限于 12a 的路径操作。三层递进：
    a. **查官方方案**：搜索 Hermes 官方文档 + 相关 GitHub issue，理解设计意图和已知陷阱。不要凭记忆判断——「我记得」「我觉得」「应该是」必须先验证
    b. **理解设计意图**：找到官方方案后，先理解「为什么这样设计」，再考虑「怎么改」。不要对抗设计（如把 `$HOME` 重写当 bug 修），要在设计框架内解决问题
    c. **简化后再执行**：找到官方方案后，检查自己的实现是否可以简化。去掉多余的判断条件，用最直接的方式落地。勇哥原话：「解决问题去哪查询官方的解决方案后执行。简化一下。」
    **典型错误（2026-06-18）：** soul-audit.py 心跳不更新 → 先查了文件差异但没查官方 issue → 写了一个复杂条件判断（`if 'profiles/' in HERMES_HOME...`）→ 被指出应该先查社区 → 发现 Issue #8669 官方方案是 `pwd.getpwuid` → 简化为 4 行代码。问题从查看到解决用了三轮，如果第一轮就查官方方案只需一轮。

15. **系统级设计优于逐个补丁（2026-06-18 纠正）** —— 当同一个模式反复出错时，不要逐个修，停一步，设计一个防止这类问题复发的系统。判断标准：
    - 同一个问题出现在 ≥3 个不同地方 → 不是个案，是系统缺陷
    - 用户说「你每次都是这样」→ 你的修复模式错了，需要换方法
    - 用户说「能不能上心点」→ 你在打补丁而不是建系统
    **案例（2026-06-18）：** 4 个 cron job 出问题（soul-audit 路径错、recreation 学习笔记 API 拒、2 个占位桩、1 个脚本缺失）→ 逐个修每一处 → 被纠正「头痛医头脚痛医脚」→ 改为 cron 统一执行器模式（cron-wrapper.sh）：调度层 exit=0，API 失败在脚本层消化+重试+写告警，开机自检报告。从逐个修到建系统，从 5 个补丁到 1 个架构。

16. **坦诚优先，编造是红线（2026-06-21 纠正）** —— 不知道就说不知道，做不到就说做不到。三条铁律：
    a. **看不到的内容不编。** 所有工具都无法访问一篇文章时，不根据搜索结果摘要拼凑内容。诚实报告「当前无法访问这篇内容，原因：xx」。比编一个看起来有用的答案重要一百倍。
    b. **不确定的判断不说。** 没有基于实际材料得出的判断，不输出成「可能」「大概率」「应该是」的表述。不确定就是不确认，直接说不确定。
    c. **被纠正不解释。** 用户指出错误后，不找理由不解释——直接归入 15c 错误分类，出修复措施。

## 模式选择器

加载技能后，直接显示四个选项：

```
你好，我是 System Guardian。告诉我你想做什么？

[1] 🆕 我刚装好，帮我跑起来
[2] ✅ 检查一下系统还好吗
[3] 🔧 出问题了，帮我看看
[4] 🚀 我想加个新功能
```

## 阶段① 快速搭建（旧「构建模式」）

用户说"我刚装好"或"帮我搭起来"时进入此阶段。

执行链：输入 API Key → 选择模型 → 配置通道（可跳过）→ 选择用途 → 命名 → 自动初始化 compliance-check → 启动 gateway → 推送"搭好了"

用户不需要理解 profile、toolset、env、systemd。全部背后配好。

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

<!-- 变现策略已迁出到 GitHub README -->

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
跨会话回忆：mnemosyne_recall(temporal_weight=0.8, limit=3) ← 新增
    ↓ 命中高权重近期记忆 → 主动报告"上次会话摘要"
用户输入 → on_turn_start hook 自动检测触发条件（L3）
    ↓ 命中纠正/偏好/决策
写入外部记忆 mnemosyne（L2，带 source 场景标签）
    ↓
compliance-check 每次启动审计（L3）：水位/活性/治理合规
```

> **跨会话回忆**（2026-06-18 新增）：解决「开机后不知道刚才在聊什么」的架构级缺陷。在加载 memory-governance skill 后、等待用户输入前，自动拉取最近4小时高权重外部记忆。详见 `memory-governance` skill 第九章「开机主动回忆」。

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

### ①a 系统健康 SLA

Goal 只跟踪「是否达标」，SLA 定义「系统有多健康」。每日自检时自动计算，分三层：

| 等级 | 基础设施 | 生产质量 | 仓库健康 |
|:----:|:---------|:---------|:---------|
| **🟢 健康** | 心跳<2h，cron 有记录，版本锚一致，记忆水位<95% | 调用成功率≥95%，纠错率<10%（skill_log 近7天） | 角色匹配率100%，deprecated<5% |
| **🟡 降级** | 心跳>2h，或某 cron 异常 | 任一 domain 成功率 80-95%，或纠错率 10-30% | 匹配率<100%，或 deprecated>5% |
| **🔴 严重** | 心跳>6h，或关键 cron 连败3次 | 任一 domain 成功率<80%，或纠错率>30% | 匹配率<80% |

SLA 降级时通过三通道通知用户，同时写入 STATE.md。

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

## 阶段③ 故障处理（互动式入口）

模式选择器中的 [3] 🔧 出问题了，帮我看看 — 用户选择此项后，先提问，不自查。

```
🔧 出问题了，帮我看看

请告诉我你遇到了什么问题？比如：

• "发不了消息了"        → 查 gateway + 通道
• "搜索搜不到东西"      → 查 Exa key + web_search
• "系统好像变慢了"      → 查 cron + 心跳
• "cron 好像没跑"      → 查 cron 状态
• "研究员/写稿手没反应"  → 查 researcher/writer profile
• 或者直接描述你看到的异常
```

根据用户说的问题定向诊断，不跑全量自查。诊断完成后展示结果，然后回到菜单：

```
还需要我做什么？

[1] 🆕 我刚装好，帮我跑起来
[2] ✅ 再检查一下
[3] 🔧 出问题了，帮我看看
[4] 🚀 我想加个新功能
```

## 自查模式

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

## 目标管理

> 对应阶段②日检报告的 Goal 状态 + 阶段④对话注册新目标。

### 通过对话设定新目标

任何对话中说了以下内容，自动触发目标注册流程：

> "定个新目标" / "加个目标" / "设定目标" / "我要达成……"

### 注册流程（三问）

**第一问：目标名称 + 条件**

用户说目标名称和评估条件。例如：

> "系统全绿连续7天"

**第二问：目标天数**

> "7天" / "30天" / "一直保持"

**第三问：确认**

复述目标 → 用户说"对" → 写入 `goals.yaml` → 初始化 streak 文件 → 告知已注册。

### 自动写入内容

```yaml
  - id: custom-{日期}-{序号}
    name: 用户说的目标名称
    desc: 用户说的条件
    type: streak
    target_days: 用户说的天数
    eval: "CUSTOM"
    streak_file: "${REAL_HOME}/.hermes/audit/streak-custom-{id}"
```

### 查看目标

说"查看目标"或"目标状态"时，展示 goal-eval.sh 的最新输出。

### 删除目标

说"删掉XX目标"时，确认后从 `goals.yaml` 移除该条目并清理 streak 文件。

### 已有预设目标

5 个预设目标不需要手动注册：

| Goal | 条件 | 目标 |
|------|------|:----:|
| 系统全绿 | compliance-check 无违规 | 7天 |
| 心跳新鲜 | HEARTBEAT 不超27h | 7天 |
| 外部记忆可用 | mnemosyne 读写通过 | 7天 |
| 定时任务在跑 | cron 有运行记录 | 7天 |
| 版本锚一致 | 全场景版本号一致 | 7天 |

自定义目标和预设目标一起评估，一起展示在 Goal 状态表中。

---

## 灾难恢复

### 备份覆盖范围

`system-backup.sh` 每日凌晨5点自动运行（cron job `daily-backup`），备份以下数据到 `${ARCHIVE_BASE:-~/archive}/backups/system-snapshot/YYYY-MM-DD/`：

| 数据 | 备份方式 |
|:----|:--------|
| SOUL.md / config.yaml / .env 配置 | 文件复制 |
| MEMORY.md / USER.md | 文件复制 |
| scripts/ | 整目录复制 |
| audit/（自查/状态/错误库） | 整目录复制 |
| **mnemosyne.db**（外部记忆） | 文件复制 ✅ 本次新增 |
| **各场景 state.db**（会话历史） | 文件复制 ✅ 本次新增 |
| **各场景 cron/jobs.json**（定时任务定义） | 整目录复制 ✅ 已有 |

D 盘常驻镜像：`${ARCHIVE_BASE:-~/archive}/backups/audit/`（非快照版本，随时可查看）

### 恢复三种场景

详见 `references/disaster-recovery-restore.md`：

| 场景 | 操作 |
|:----|:-----|
| A：单个文件误删 | `cp 备份/DATE/hermes/xxx ~/.hermes/` |
| B：数据库损坏 | `cp 备份/DATE/hermes/mnemosyne.db ~/.hermes/mnemosyne/data/` |
| C：全量恢复 | 恢复根配置 + 数据库 + 各场景 |

---

## 实操提示：五维能力自检 + Token 优化

每次全检时按以下顺序检查，避免路径陷阱：

1. 听 — 用 venv 的 Python 检查 STT
2. 看 — curl 检查 Camofox 浏览器服务
3. 说 — 直接调用 text_to_speech
4. 读 — 调用 web_search 和 web_extract
5. 创 — 写作技能直接可用

**Token 优化：** 各场景默认加载全部 31 个工具集，但 control 管理场景不需要 browser/vision/tts 等。通过 `enabled_toolsets` 限定到 11 个核心工具集可省 64% 工具 schema token。详见 `references/token-optimization-toolset-trimming.md`。

<!-- 版本对比已迁出到 GitHub README -->

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

### skills list 管道输出不可用（统计陷阱）

`hermes skills list` 输出是**表格格式**（带 `┃` `┏` `┡` 等 Unicode 表格字符），不是 bullet 列表。

```bash
# ❌ 错误：统计不到任何结果
hermes skills list 2>&1 | grep -c '•'

# ✅ 正确
hermes skills list 2>&1 | grep -c 'enabled'
```

**排查：** 如果 compliance-check 或其他脚本中 skills 统计结果为 0，优先检查统计方法而非怀疑 skills 加载失败。

### state.db 无 `cron_jobs` 表——脚本查询静默失败

**表现：** `goal-eval.sh` 和 `syndrome-detect.sh` 的 cron 活性检查一直报 ❌，但 `cronjob list` 显示 job 在跑且有记录。

**根因：** 新版 Hermes `state.db` 中 **不存在** `cron_jobs` 表。`SELECT COUNT(*) FROM cron_jobs` 静默返回空，`grep -q 1` 永远失败。旧版 Hermes 曾将 cron 存在 SQLite 中，新版用独立 `cronjob` 工具管理。

**排查：** `sqlite3 "$STATE_DB" ".tables" | grep cron` → 空输出即确认。

**修复：** 改用 `sessions` 表近24小时活跃度判断：
```bash
sqlite3 "$STATE_DB" "SELECT COUNT(*) FROM sessions WHERE started_at > $(date +%s) - 86400;"
```
此条已同时修复 `goal-eval.sh`（`cron-active`）和 `syndrome-detect.sh`（`C2`）。

### state.db 体积膨胀（双重 FTS5 正常累积）

`~/.hermes/profiles/{scene}/state.db` 是 Hermes 的 SQLite 会话存储库。每条消息建两个全文索引——这是架构设计，不是泄漏：

```
messages（原始文本）
  ↓ INSERT trigger 自动同步
  ├── messages_fts         标准 FTS5（英文分词）
  └── messages_fts_trigram  trigram tokenizer（CJK 中文分词）
```

**正常体积基线：** ~10,000 条消息 ≈ 100-150MB（约 12.5KB/条）。recreation（约 200 条）≈ 2.5MB 可作为对照基线。curator 每 7 天自动清理超过 30 天的旧会话（`stale_after_days: 30`）。

**如果体积需要控制：**
```bash
hermes sessions stats           # 查统计
hermes sessions prune --older-than 30 --yes  # 清理旧会话
hermes sessions optimize         # 合并 FTS5 索引碎片 + VACUUM
```

**排查：** 先确认是否有超过 30 天的会话——没有说明 curator 正常工作。体积大只是使用量大，不是泄漏。

### gateway status 返回全局视图

`hermes -p <scene> gateway status` 返回的是**所有 profile 的 gateway 进程**，不是当前 profile 的。PID 排序顺序不同会让人误以为数据异常。

**排查：** 用 `ps aux | grep 'gateway run'` 查看实际进程分布。没有 gateway 进程的场景（如 shici）不需要怀疑——该场景不走消息通道。

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

**修复：** 在审计脚本末尾统一加心跳写入。注意：cron no_agent 模式在 profile 下 `$HOME` 被重写，**不能用 `Path.home()` 或 `os.environ['HOME']` 拼系统路径**。用 Issue #8669 官方 `get_real_home()` 模式：
```python
import datetime, pwd, os
from pathlib import Path
# Issue #8669: pwd.getpwuid 绕过 profile $HOME 重写
REAL_HOME = pwd.getpwuid(os.getuid()).pw_dir
HEARTBEAT = Path(f'{REAL_HOME}/.hermes/audit/HEARTBEAT')
now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
HEARTBEAT.write_text(f'{now} | PASS - audit completed')
```

**验证：** `cat ~/.hermes/audit/HEARTBEAT` 应显示当天的运行时间。ALERT 文件不存在表示正常。

### Mnemosyne 数据库路径分裂（第二层断链）

Mnemosyne 插件 centralized 后（所有 profile 能在 `$HERMES_HOME/plugins/` 发现插件文件），**数据库仍可能分裂**。这是第二层断链。

| 层 | 问题 | 修复 |
|----|------|------|
| ① 插件代码 | `$HERMES_HOME/plugins/mnemosyne/` 不存在或未指向 centralized | symlink 修复 |
| ② 数据库 | `$HERMES_HOME/home/.hermes/mnemosyne/` 不存在或未指向中央 | symlink 修复 |
| ③ 使用指令 | agent 不知道何时调用 mnemosyne 工具 | SOUL 第16条 + memory-governance skill |

**修复——逐场景建软链：**
```bash
for scene in control work study recreation shici; do
  mkdir -p "${HERMES_HOME}/.hermes/profiles/$scene/home/.hermes"
  ln -sfn "${HERMES_HOME}/.hermes/mnemosyne" "${HERMES_HOME}/.hermes/profiles/$scene/home/.hermes/mnemosyne"
done
```

> 实测（2026-06-17）：5场景 home/.hermes/ 全缺，但 plugins/mnemosyne centralized 软链正常——典型第二层断链。建链后 compliance-check 第12项自动变绿。

**验证：**
```bash
for scene in control work study recreation shici; do
  echo "$scene → $(readlink -f ~/.hermes/profiles/$scene/home/.hermes/mnemosyne)"
done
# 所有应指向: ${HERMES_HOME}/.hermes/mnemosyne
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

### Cron no_agent 脚本双版本漂移 + `$HOME` 重写陷阱 + 占位桩误报 ok

**表现：** cron job `last_status=error` 或 `ok` 但 HEARTBEAT 不更新、输出写到错误目录。自查心跳停跳但 cron 显示执行了。

**根因：** 两个问题叠加——

1. **双版本不同步**：cron 的 `no_agent=true` 模式从 **profile 的 `scripts/` 目录**加载脚本（如 `profiles/control/scripts/soul-audit.py`），而集中版在 `~/.hermes/scripts/soul-audit.py`。这两个版本会各自演化，cron 跑的是旧版。

2. **`$HOME` 重写**：profile 模式下 `$HOME` 和 `HERMES_HOME` 均被重写。脚本用 `os.environ.get('HOME')` 或 `Path.home()` 拼接路径时指向 profile 的 home 目录而非真实家目录——心跳写到了 `~/.hermes/home/.hermes/audit/` 而非 `~/.hermes/audit/`。

> **⚠️ 2026-06-18 深度发现：`pwd.getpwuid` 修复后 cron no_agent 运行时仍可能失败。** 脚本手动运行验证通过（`python3 soul-audit.py` → HEARTBEAT 正确写入），但 cron 同一脚本（`no_agent=true`，`profile=control`）运行时报 `FileNotFoundError`，路径解析为 `${HERMES_HOME}/.hermes/profiles/control/home/.hermes/SOUL.md`。根因不明——`pwd.getpwuid(os.getuid()).pw_dir` 在 cron subprocess 上下文中可能返回了 profile 重写后的路径，而非真实 `${HERMES_HOME}`。**排查顺序：** 先确认 `cron job` 的 `script` 字段指向哪个脚本文件（`hermes cron list` 查看 Script 路径），检查该文件是否存在、是否被意外回退到了旧版。

**排查：**
```bash
# 检查双版本差异
diff ~/.hermes/profiles/control/scripts/soul-audit.py ~/.hermes/scripts/soul-audit.py
# 比较修改时间
ls -la ~/.hermes/profiles/control/scripts/soul-audit.py ~/.hermes/scripts/soul-audit.py
# 检查是否有 $HOME 依赖（profile 模式下一定错）
grep -n 'os.environ.get.*HOME\|Path.home\|expanduser.*\.hermes' ~/.hermes/profiles/control/scripts/soul-audit.py
```

**修复三步（2026-06-18 实战验证）：**
```bash
# 1. 同步双版本——集中版覆盖 profile 版
cp ~/.hermes/scripts/soul-audit.py ~/.hermes/profiles/control/scripts/soul-audit.py

# 2. 修复路径写法——profile 模式下用真实 HOME 拼系统路径
# Python 跨上下文脚本用 pwd.getpwuid 获取真实 HOME:
import pwd
REAL_HOME = pwd.getpwuid(os.getuid()).pw_dir
BASE = Path(f'{REAL_HOME}/.hermes')

# 3. 验证：手动跑一次
python3 ~/.hermes/profiles/control/scripts/soul-audit.py
cat ~/.hermes/audit/HEARTBEAT   # 应显示当前时间
```

**防护：** 每次修改 centralized 脚本后同步到对应 profile 的 scripts/。或者将 cron job 的 `script` 路径改为 centralized 的绝对路径（如 `${HERMES_HOME}/.hermes/scripts/soul-audit.py`），避免双版本问题。

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

### API 内容过滤导致 agent 型 cron job 静默失败

**表现：** agent 型 cron job last_status=error，错误信息包含 `Content Exists Risk` 或 `400`。

**根因：** DeepSeek 等 LLM API 提供商内置内容安全过滤器。当 cron job 的 prompt 或 session_search 返回的内容触发过滤时，API 返回 400 而非正常响应。

**排查：** 检查 cron output 文件中的 error 段。区分「API 拒绝」和「本地配置错误」。

**防范：**
1. agent 型 cron job 通过 `cron-wrapper.sh` 执行（no_agent 模式），调度层不受 API 错误影响
2. wrapper 内置重试逻辑，API 波动自动消化
3. 两次失败写 CRON_ALERT，开机自检报告

**极少数情况下可能需要换模型提供商来绕过内容过滤。**

**理论：** Hermes profile 模式下 `$HOME` 被重写为 `{HERMES_HOME}/home/`。这是 **intentional** 设计（Issue #8669），不是 bug。

**社区标准做法（Issue #892）：**

- **Python：** `os.environ.get("HERMES_HOME", os.path.expanduser("~/.hermes"))` — 优先读 `HERMES_HOME` 环境变量，fallback 到 `expanduser`。在 Hermes 上下文里 `HERMES_HOME` 始终有值，fallback 不会触发；在独立运行时 `$HOME` 就是真实家目录，`expanduser` 正确。
- **Bash：** `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"`

**例外（需要真实 HOME 的场景）：** `.bashrc`、`hermes-global-status.py`、`paths.sh` 等跨上下文脚本允许用 `getent passwd` 或 `pwd.getpwuid`（等价于社区的 `get_real_home()`）。

**关键教训（2026-06-16）：** 不要自己发明方案。涉及 `$HOME`/`HERMES_HOME`/profile 隔离的操作前，先查社区 issue（#8669、#892）确认标准做法。这次先用了 `pwd.getpwuid` 改了 35 个文件，被用户指出"符合官方标准吗"后发现方向错了，回退到 `expanduser` 标准又花了一轮时间。**先查再改，不自己发明方案。**

**完成的全系统扫描方法论：** `references/home-override-fix.md` 记录了四层系统扫描（L1 scripts → L2 SOUL.md → L3 .bashrc/config → L4 skill scripts）、修复优先级、统一修复方案、35 处修复全清单和零残留验证。

**完整实战案例：** `references/home-override-system-scan-2026-06-16.md`

### compliance-check.sh hash 管理——合法修改后及时对齐

**表现：** 自查报告显示「❌ compliance-check.sh 已被修改！hash不匹配」，但实际 diff 是合法的内容更新（新增检查项、修复路径写法），无恶意篡改。

**根因：** 修改 compliance-check.sh 后，未同步更新 `~/.hermes/audit/compliance-hash.txt`（由 `sha256sum compliance-check.sh > compliance-hash.txt` 生成）。

**快速判断方法：**
```bash
# 仅末尾追加了新检查项？→ 合法更新
**快速判断方法：**
```bash
# 查看变化性质——仅末尾追加了新检查项？→ 合法更新
diff -u <备份>/compliance-check.sh compliance-check.sh

# 区分模式：
#   - 追加新 `── N. 名称` 检查段 → 合法升级，仅需对齐 hash
#   - 修改前50行的逻辑/阈值代码  → 真违规，需走第12条升级
```

**修复：**
```bash
sha256sum ~/.hermes/scripts/compliance-check.sh | awk '{print $1}' > ~/.hermes/audit/compliance-hash.txt
```

更新后告知用户「这是合法修改的 hash 对齐，不是违规」。不需要走第12条升级流程。

**防护：** 修改 compliance-check.sh 后，把更新 hash 作为 commit/操作的最后一个步骤。或者将 hash 校验改为「允许预定义多版本 hash」（主版本 + 补丁版本），降低此类噪音。

**实战案例（2026-06-18）：** 自查报 compliance-check.sh hash 不一致，diff 发现是6.16修 $HOME 重写时新增了第13项「路径写法合规」检查，属于主动升级。更新 hash 后下一轮自查即变绿。

### 停而不删——服务停止后残留自愈陷阱\n\n**表现：** 停止了不需要的服务，但几分钟后它又自动运行了。停了一个进程后以为问题解决了，但下次重启又回来。\n\n**根因：** systemd 设了 `Restart=always`，`systemctl stop` 只是临时停止——systemd 检测到退出后 5 秒自动拉起来。停止不等于删除。\n\n**修复——四步彻底清除：**\n1. `systemctl --user stop <service>`\n2. `systemctl --user disable <service>`\n3. `rm -f ~/.config/systemd/user/<service>`\n4. `systemctl --user mask <service>`  （软链到 /dev/null，永远无法启动）\n\n**排查三层：** 同一场景还有 cron job 吗？配置引用残留吗？文件目录残留吗？\n\n**教训（2026-06-20）：** Restart=always 的服务必须彻底摘除。停而不删等于没修。\n\n### 脚本占位桩在错误 profile 目录（cron 跑到空壳但显示 ok）

**表现：** cron job `last_status=ok`，但实际没做任何有用工作。

**根因：** `no_agent=true` 脚本型 cron job 从 profile 的 `scripts/` 目录加载脚本。如果该目录下是 62B 的占位桩（`echo "此脚本尚未实现"`），而真实实现在其他目录（如 `control/scripts/` 或 `~/.hermes/scripts/`），cron 跑的是空壳。`exit=0` 导致 `last_status=ok`，但真实逻辑从未执行。

### 停而不删——服务停止后残留自愈陷阱

**表现：** 停止了不需要的服务（如 study gateway），但几分钟后它又自动运行了。或者停了一个进程后以为问题解决了，但下次重启又回来。

**根因：** systemd 服务如果设了 `Restart=always`，`systemctl stop` 只是临时停止——systemd 检测到服务退出后 5 秒会自动拉起来。停止不等于删除、不等于禁用。

**正确流程——四步彻底清除：**
```bash
systemctl --user stop hermes-gateway-study.service     # 1. 停止
systemctl --user disable hermes-gateway-study.service   # 2. 禁用（移除自动启动链接）
rm -f ~/.config/systemd/user/hermes-gateway-study.service  # 3. 删 service 文件
systemctl --user mask hermes-gateway-study.service       # 4. 屏蔽（软链到 /dev/null，永远无法启动）
systemctl --user daemon-reload                          # 5. 重载
```

**排查——是否存在同类残留的三层检查：**
1. 还有没有同一场景的 cron job 在跑？（`hermes -p study cron list`）
2. 还有没有同一场景的配置引用？（`.env`、`config.yaml` 中的残留配置）
3. 还有没有同一场景的文件/目录残留？（`profiles/study/` 是否该清理）

**根因：** 只看到了"症状被消除了"（服务暂时停了），没检查"架构残留是否还有"。Restart=always 的服务不是临时停就能解决的——必须彻底摘除。

**排查标志：**
```bash
# 查看 no_agent 脚本实际内容
cat ~/.hermes/profiles/work/scripts/policy-scan.sh
# 只有几行 echo = 占位桩

# 检查真实版本是否存在
diff ~/.hermes/profiles/work/scripts/policy-scan.sh ~/.hermes/profiles/control/scripts/policy-scan.sh
# 文件大小差异巨大（62B vs 1622B） = 占位桩未被替换
```

**修复：** 将真实脚本复制到 cron 使用的 profile 目录，或用绝对路径指向 centralized 版本。

**防护：** cron 审计排查逻辑新增——`last_status=ok` 的 no_agent job 也要验证脚本内容不是占位桩。对比文件大小是否合理。

### Agent 型 cron job：DeepSeek API "Content Exists Risk" 400 错误

**表现：** agent 型 cron job 报错 `RuntimeError: Error code: 400 - {'error': {'message': 'Content Exists Risk'}}`。其它 job 正常，同 profile 手工运行正常。

**根因：** DeepSeek API 内置内容安全过滤器。当 agent 型 cron job 用 `session_search` 检索近 2 天的会话注入 prompt 时，如果会话内容包含系统内部信息（路径修改、配置变更、权限操作等），DeepSeek 的安全策略直接拒绝服务。`Content Exists Risk` 不在官方 Error Codes 列表中（[api-docs.deepseek.com](https://api-docs.deepseek.com/quick_start/error_codes)），属于不公开的安全拦截。

**排查标志：**
```bash
# 查看 cron job 输出（如 D 盘映射）
ls -lt ${ARCHIVE_BASE:-~/archive}/cron-output/<job_id>/
cat ${ARCHIVE_BASE:-~/archive}/cron-output/<job_id>/*.md | grep -A5 "Error"

# 对比：同 prompt 手动在 CLI 跑
hermes -p <profile> chat -q "执行学习笔记任务"  # 通常能成功
```

**修复方案（选一）：**

| 方案 | 操作 | 影响 |
|------|------|------|
| ① per-job model override | `hermes cron edit <job_id> --model anthropic/claude-sonnet-4 --provider anthropic` | 绕过 DeepSeek 过滤器，该 job 走其他模型 |
| ② 精简 prompt 的 session_search 范围 | 限制只搜索 1 天、排除系统操作类会话 | 仍有触发风险 |
| ③ 改用 no_agent wrapper 模式 | 写 shell wrapper 调 API 绕过 Hermes 的 session_search 注入 | 需要额外脚本维护 |

**官方依据：** Hermes Issue #27530 确认 cron job 支持 per-job model/provider 覆盖。DeepSeek 官方无关闭安全过滤器的选项。。

### compliance-check 身份声明检查伪阳性（2026-06-22 发现）

**表现：** 自查第1项报 `work/SOUL.md: ⚠️ 身份声明冲突`，但场景SOUL中并无实际冲突声明。

**根因：** `grep -qE "(砚清|内容创作者：勇哥)"` 模式过于宽泛。根SOUL的全局认知声明中举例说明了冲突场景（`如"你是勇哥""你是砚清"等`），grep 匹配了例举文字中的"砚清"而非真实身份声明。

**修复：** 改为行首锚定 `grep -qE "^(你是|我是)?(砚清|内容创作者：勇哥)"`，排除例举文字中的匹配。

**注意：** 修改 compliance-check.sh 后需同步 `compliance-hash.txt`，否则下次自检报 script hash 不匹配。

### compliance-check 规则条数检查伪阳性（2026-06-22 发现）

**表现：** 自查第4项报 `work/SOUL.md: 引用 12条，根SOUL为 16条`，但场景SOUL实际内容与根SOUL一致。

**根因：** 根SOUL版本锚用 `以上\K(\d+)条`（匹配"以上16条"），场景SOUL用 `(\d+)条`（无"以上"前缀）。场景SOUL中的 `12条` 来自 `按第12条升级`，被 `(\d+)条` 先匹配到，输出12而非16。两个检查使用了不一致的 grep 模式。

**修复：** 场景SOUL的 grep 改为 `以上\K(\d+)条`，与根SOUL保持一致。

**检查：** 修改后运行 `bash compliance-check.sh` 确认第4项变绿。

### content-anchors.md 同步陷阱——修改根SOUL后锚点漂移（2026-06-22 发现）

**表现：** 修改根SOUL.md后（如更新场景数量、增删边界约束段），compliance-check 第7项报「缺失断言」，但文件内容逻辑正确。

**根因：** `content-anchors.md` 中保存了每个文件的断言基线。根SOUL更新后，文件内容与锚点断言不一致——锚点仍引用旧版内容。这不是文件"错了"，是锚点版本同步滞后。

**典型场景：**
- 根SOUL从"协调5个场景"改为"协调6个场景" → 锚点断言仍期望 "协调5个"
- 根SOUL新增 shici 场景边界段 → 锚点断言 "不与其他场景产生任何关联" 在文件中不存在

**修复步骤：**
1. 运行 `bash compliance-check.sh` 查看缺失断言的完整列表
2. 编辑 `~/.hermes/audit/content-anchors.md`，更新对应文件的断言到当前版本
3. 再次运行 compliance-check.sh 确认全部通过

**防护：** 修改根SOUL（或任何被锚定的核心文件）后，立即运行一次 compliance-check 检查锚点状态。

### Checker 报告「版本漂移」但实际是 SOUL 文件丢失/损坏（2026-06-24 发现）

**表现：** `checker-cron.sh` 症候群诊断报告「版本漂移 —— 1个场景未同步 v3.9」，但实际根因不是版本号过时，而是 **profile 目录被删除**或 **SOUL.md 内容被清空为默认系统提示词**。

**关键区分信号：**

| 症候群报告 | 实际可能性 | 排查方向 |
|-----------|-----------|---------|
| 「版本漂移——1个场景未同步」 | SOUL.md 不存在 | `ls ~/.hermes/profiles/{scene}/SOUL.md` — 文件缺失即确认 |
| 「版本漂移——1个场景未同步」 | SOUL.md 内容被清空 | `wc -l` 显示 0 行或仅含默认系统提示词 — 文件损坏 |
| 「版本漂移——1个场景未同步」 | 版本号确实过时 | grep 版本锚行确认，修复方向为标准场景同步 |

**诊断三步：**
1. 检查 HEARTBEAT 是否为 `errors: True` → soul-audit.py 已捕获异常
2. `wc -l ~/.hermes/profiles/{scene}/SOUL.md` → 0 行 = 文件损坏/空；文件不存在 = profile 丢失
3. `ls -lt ${ARCHIVE_BASE:-~/archive}/backups/system-snapshot/ | head -3` → 确认最近备份日期

**修复：** 从最近备份恢复 SOUL.md。若备份不包含目标文件（目录结构变更导致），重建该 profile 的 SOUL.md 并确保版本锚与根SOUL对齐。

**实战案例（2026-06-24）：** recreation profile 目录整删 + work/SOUL.md 被清为默认系统提示词 → HEARTBEAT `errors: True` → 备份 6 天前，recreation SOUL 可恢复，work SOUL 可恢复。详见 `references/soul-corruption-recovery-2026-06-24.md`。

**防护方向：** 症候群诊断脚本应区分「文件缺失」「文件损坏」「版本过时」三类异常，而非统一报「版本漂移」。

### `.bashrc` 路径合规白名单

**表现：** 第8节（全局路径绝对性）报 `⚠️ ${HERMES_HOME}/.bashrc: 自检路径未用绝对路径或 $HOME`，但 `.bashrc` 实际用的是 `$REAL_HOME_HERMES` 变量（通过 `getent passwd` 获取真实家目录）。

**根因：** section 8c 只识别 `$HOME` 和 `/home/用户名` 两种合法路径写法，未识别跨上下文脚本常用的自定义变量。

**判断方法：** 变量定义是否在文件头部且路径来源可靠（`getent passwd` 是跨上下文真实家目录的标准做法）。是则走白名单，不是则要求改为绝对路径或 `$HOME`。

**修复：** 在 section 8c 的 grep 条件中追加 `|\\$REAL_HOME_HERMES` 到白名单。2026-06-17 实测已修复。

## 前置条件

- Hermes Agent 已安装并能正常对话
- 终端有文件写入权限
- 需要能够访问 GitHub 和海外 API 的网络环境

## 参考资料

- 构建模式完整引导流程：`skill_view(name="system-guardian", file_path="references/build-guide.md")`
- 自查模式检查项：`skill_view(name="system-guardian", file_path="references/check-procedure.md")`
- 五维能力详情与分级模型：`skill_view(name="system-guardian", file_path="references/capability-guide.md")` + `audit/capability-hierarchy.md`
- 效率优化手册：P0 工具集裁剪 + P1 合并调用 + P2 分流策略：`skill_view(name="system-guardian", file_path="references/efficiency-playbook.md")`
- `$HOME` 重写陷阱修复模式（含四层扫描方法论 + 35 处修复清单）：`skill_view(name="system-guardian", file_path="references/home-override-fix.md")`
- 全系统扫描实战案例（2026-06-16）：`skill_view(name="system-guardian", file_path="references/home-override-system-scan-2026-06-16.md")`
- 路径编写规范（含标准依据、社区 issue 索引）：`~/.hermes/audit/path-standards.md`
- 变现与分发策略：`skill_view(name="system-guardian", file_path="references/monetization-strategy.md")`
- 审计模式完整流程：`skill_view(name="system-guardian", file_path="references/audit-protocol.md")`
- Cron 审计实战记录：skill_view(name='system-guardian', file_path='references/cron-full-audit-2026-06-14.md')
- Cron 架构解耦实战（2026-06-16）：skill_view(name='system-guardian', file_path='references/cron-architecture-decouple-2026-06-16.md')
- Cron delivery wrapper 模式：skill_view(name='system-guardian', file_path='references/cron-delivery-wrapper-pattern.md')
- Cron wrapper 三层保护模型：skill_view(name='system-guardian', file_path='references/cron-wrapper-pattern.md')
- 旧版cron→新版cron迁移指引：skill_view(name='system-guardian', file_path='references/old-to-new-cron-migration.md')
- 实战案例·2026-06-15 全系统审计：skill_view(name='system-guardian', file_path='references/audit-example-2026-06-15.md')
- README 终端截图制作：skill_view(name='system-guardian', file_path='references/readme-screenshot-workflow.md')
- Cron 架构决策日志：skill_view(name='system-guardian', file_path='references/cron-architecture-decision-log.md')
- $HOME 重写认知避坑指南（判断准则 + 时间线 + 根因分析）：`skill_view(name='system-guardian', file_path='references/home-override-cognitive-guide.md')`
- $HOME 重写调试指南：skill_view(name='system-guardian', file_path='references/hermes-home-rewrite-debug.md')
- Profile 隔离安全操作指南（$HOME重写/路径规范/官方推荐方案）：`skill_view(name='system-guardian', file_path='references/profile-isolation-safety.md')`
- 错误库：`~/.hermes/audit/error-log.md`（每次系统性错误记录——被纠即升级，不产出机制不算闭环）
- 灾难恢复指南：`skill_view(name='system-guardian', file_path='references/disaster-recovery-restore.md')`
- 假阳性处理协议：`skill_view(name='system-guardian', file_path='references/false-positive-protocol.md')`
- Hermes 架构学习笔记（Profile隔离/日志/Session/Gateway/Skills）：skill_view(name='system-guardian', file_path='references/hermes-architecture-insights-2026-06-16.md')
- Loop Engineering 深度学习笔记：`skill_view(name='system-guardian', file_path='references/loop-engineering-notes.md')`
- Goal 系统架构与 Maker-Checker 分离：`skill_view(name='system-guardian', file_path='references/goal-system.md')`
- Goal 评估脚本：`skill_view(name='system-guardian', file_path='scripts/goal-eval.sh')`
- 状态摘要脚本：`skill_view(name='system-guardian', file_path='scripts/state-summary.py')`
- 系统漏洞扫描方法论：`skill_view(name='system-guardian', file_path='references/system-vulnerability-scan.md')`
- HEARTBEAT 写入陷阱修复实战（2026-06-18 soul-audit.py 双版本 + $HOME 重写根因）：`skill_view(name='system-guardian', file_path='references/cron-script-home-rewrite-fix-2026-06-18.md')`
- Cron 全场景审计实战记录（2026-06-18 审计了全部 14 个 cron job，发现 5 个异常项）：`skill_view(name='system-guardian', file_path='references/cron-full-audit-2026-06-18.md')`
- Cron 统一执行器模式（调度层与业务层分离 + no_agent wrapper + CRON_ALERT 告警机制）：`skill_view(name='system-guardian', file_path='references/cron-unified-wrapper-pattern.md')`
- SOUL 文件损坏恢复实战（2026-06-24 recreation 目录删除 + work SOUL 清空）：`skill_view(name='system-guardian', file_path='references/soul-corruption-recovery-2026-06-24.md')`
