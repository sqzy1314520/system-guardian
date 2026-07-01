# Pitfalls · 实战陷阱

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


---
*本文件由 system-guardian 主 SKILL.md 拆分生成。*