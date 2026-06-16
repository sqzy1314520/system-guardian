# $HOME 重写陷阱 · 修复模式

## 根因

Hermes Agent 以 `--profile <name>` 启动时（Gateway 或 CLI），设置：

- `HERMES_HOME=/home/user/.hermes/profiles/<name>`
- `HOME=/home/user/.hermes/profiles/<name>/home`（模拟独立家目录进行 profile 隔离）

这是 Hermes **按设计** 的行为（Issue #8669）。但所有用 `$HOME` 拼路径找 Hermes 系统文件的脚本会因此指向错误路径。

## 社区标准（Issue #892 权威）

**不要自己发明路径方案。** 社区已经共识：

| | 标准写法 | 原理 |
|:----|---------|------|
| **Python** | `os.environ.get("HERMES_HOME", os.path.expanduser("~/.hermes"))` | Hermes 上下文中 `HERMES_HOME` 始终有值，fallback 不触发。独立运行时 `$HOME` 为真实家目录，`expanduser` 正确。 |
| **Bash** | `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"` | 同上。 |

**例外（需要真实 HOME 的场景）：** `.bashrc`、`hermes-global-status.py`、`paths.sh` 等跨上下文脚本，允许用 `getent passwd` 或 `pwd.getpwuid`（等价于社区的 `get_real_home()`）。

### 关键教训

2026-06-16 实战教训：先自己发明了 `pwd.getpwuid` 方案改了 35 个文件，被用户指出"符合官方标准吗"后才发现偏离了社区共识，回退又花了一轮。**涉及 `$HOME`/`HERMES_HOME`/profile 隔离的操作，先查社区 issue（#8669、#892）确认标准做法。**

## 诊断方法

```bash
# 检查 HOME 是否被重写
echo "HOME=$HOME"
getent passwd $(whoami) | cut -d: -f6  # 真实家目录

# 检查脚本中是否有 $HOME 依赖
grep -n '\${HOME}\|\$HOME' /path/to/script.sh | grep -i 'hermes\|soul\|\.hermes\|audit'
```

## 系统扫描方法论（2026-06-16 实战总结）

### 发现模式

`$HOME` 重写风险有 4 层表现，必须逐层排查：

| 层级 | 扫描目标 | 风险模式 | 扫描方法 |
|:----:|---------|---------|---------|
| L1 | `scripts/` 下 Python 脚本 | `expanduser("~/.hermes")`、`Path.home()/.hermes`、`os.environ.get('HOME')` | `grep -rn 'expanduser\|Path.home\|os.environ.get.*HOME'` |
| L2 | `scripts/` 下 Shell 脚本 | `$HOME/.hermes`、`~/.hermes` | `grep -rn '\$HOME.*\.hermes\|~/.hermes'` |
| L3 | SOUL.md 核心文件 | 启动指令中的 `~/.hermes/` 路径 | 全文搜索 `~/.hermes` 和 `$HOME/.hermes` |
| L4 | 全局 skill 的 scripts/ | 同上 L1+L2，但目录更深 | 遍历 `skills/*/*/scripts/` |

### 修复优先级

1. **🔴 高** — 直接读 `$HOME` 环境变量或 `Path.home()` 的（profile 模式下一定错）
2. **🟡 条件性** — `os.environ.get("HERMES_HOME", expanduser("~/.hermes"))` fallback（HERMES_HOME 未设置时才触发，实际安全，可保持）
3. **⚠️ 低** — 描述性/注释中的 `~/.hermes` 引用（不执行但可能误导）

### 统一修复方案

**Python：** 社区标准（Issue #892）
```python
HERMES_HOME = os.environ.get("HERMES_HOME", os.path.expanduser("~/.hermes"))
```
**不需要**用 `pwd.getpwuid` 替代 `expanduser`。

**Bash：** 社区标准
```bash
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
```
**不需要**用 `getent passwd` 获取真实 HOME 再拼路径。

**需要真实 HOME 的例外场景（用 `get_real_home()` 等价实现）：**
```python
# Python - 跨上下文脚本
import pwd
REAL_HOME = pwd.getpwuid(os.getuid()).pw_dir
```
```bash
# Bash - .bashrc / paths.sh
REAL_HOME=$(getent passwd "$(whoami)" 2>/dev/null | cut -d: -f6)
```

### 验证方法

```bash
# 确认全部清除
grep -rn 'expanduser.*\.hermes\|Path.home.*\.hermes\|os.environ.get.*HOME' scripts/ --include='*.py'
grep -rn '\$HOME.*\.hermes\|~/.hermes' scripts/ --include='*.sh'
grep -rn '~/.hermes' profiles/*/SOUL.md
# 以上仅应命中社区标准的 expanduser fallback 或已知安全的描述性文字
```

---

## 受影响的脚本/文件（已修复）

**总计 35 处文件，覆盖 scripts/ + SOUL.md + .bashrc + 全局 skill scripts/，零残留。**

### 第一批 2026-06-14（6 处）

| 文件 | 原问题 | 最终方案 |
|------|--------|---------|
| `scripts/compliance-check.sh` | `$HOME` 拼接路径 ×15 | `getent` 获取真实 HOME（跨上下文脚本） |
| `scripts/system-backup.sh` | `$HOME` | `$REAL_HOME` |
| `scripts/docker-exec.sh` | `$HOME` | `$REAL_HOME` |
| `profiles/work/scripts/route_manager.sh` | `$HOME` | `$REAL_HOME` |
| `scripts/soul-audit.py` | `os.environ.get('HOME')` | `pwd.getpwuid` |
| `scripts/hermes-global-status.py` | 同上 | 同上 |

### 第二批 2026-06-16 🔴 高风险脚本 → 社区标准（7 处）

| 文件 | 原问题 | 社区标准 |
|------|--------|---------|
| `scripts/soul-audit.py` (centralized) | `os.environ.get('HOME')` ×5 | `os.environ.get("HERMES_HOME", expanduser("~/.hermes"))` |
| `scripts/move-rec-to-work.py` | `Path.home() / ".hermes"` | 同上 |
| `scripts/migrate-cron-jobs.py` | `Path.home() / ".hermes"` | 同上 |
| `scripts/scan-architecture.sh` | `$HOME/.hermes/profiles` | `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"` |
| `scripts/config-sync.sh` | `$HOME/.hermes` ×3 | 同上 |
| `skills/.../hermes-architecture-audit/scripts/soul-audit.py` | 同上 centralized | `expanduser` 标准 |
| `skills/.../hermes-profile-architecture/scripts/soul-audit.py` | 同上 centralized | `expanduser` 标准 |

### 第三批 2026-06-16 🟡 条件性风险 → 社区标准（5 处）

| 文件 | 原 fallback（本来就安全，但统一标准） | 社区标准 |
|------|-------------------------------------|---------|
| `scripts/audit-log.py` | `expanduser("~/.hermes")` | `os.environ.get("HERMES_HOME", expanduser("~/.hermes"))` |
| `scripts/integrity-audit.py` | 同上 | 同上 |
| `scripts/integrity-check.py` | 同上 | 同上 |
| `scripts/security-scan.py` | 同上 | 同上 |
| `scripts/capability-scan.py` | 同上 | 同上 |

### 第四批 2026-06-16 🔴 核心系统文件（3 处）

| 文件 | 原问题 | 改为 |
|------|--------|------|
| `profiles/control/SOUL.md` | 启动指令中 9 处 `~/.hermes/` | 绝对路径 `/home/user/.hermes/`（agent terminal 执行不受 `~` 影响） |
| `profiles/work/SOUL.md` | 路由表中 6 处 `bash ~/.hermes/...` | 绝对路径 |
| `.bashrc` | Hermes 自检段 `$HOME/.hermes/` | `getent` 获取真实 HOME（跨上下文） |

### 第五批 2026-06-16 🔴 全局 skill 脚本（7 处）

| 文件 | 原问题 | 社区标准 |
|------|--------|---------|
| `skills/infra/terminal-audit-system/scripts/security-scan.py` | `expanduser("~/.hermes")` | `os.environ.get("HERMES_HOME", expanduser("~/.hermes"))` |
| `skills/infra/terminal-audit-system/scripts/integrity-check.py` | `expanduser("~/.hermes")` ×2 | 同上 |
| `skills/methodology/learning-mode/scripts/feishu-send.py` | `expanduser("~/.hermes/...")` | 同上 |
| `skills/methodology/skill-architecture-map/scripts/scan-architecture.sh` | `$HOME/.hermes` | `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"` |
| `skills/infra/system-backup/scripts/system-backup.sh` | `$HOME` | `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"` |
| `skills/hermes/github/github-auth/scripts/gh-env.sh` | `$HOME/.hermes/.env` | `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"` |
| `skills/infra/hermes-architecture-audit/scripts/skill-health-check.py` | `os.environ.get('HOME')` | `os.environ.get("HERMES_HOME", expanduser("~/.hermes"))` |

### 第六批 2026-06-16 🟡 第三方 skill 文档/示例（17 处）

godmode（8 个文件 12 处）、google-workspace（1 处）、touchdesigner（1 处）、hermes-architecture-audit/SKILL.md（2 处）、hermes-operations/SKILL.md（1 处）

全部统一到社区标准 `expanduser("~/.hermes")` 或 `$HOME/.hermes`。

## 验证方法

修复后运行 `compliance-check.sh`，确认：
- 身份合规 → ✅ 根SOUL身份正确
- 版本锚 → 显示完整版本号而非空
- 内容锚点 → 能找到校验清单并验证断言
- 第 8 项（全局路径绝对性）→ ✅ 全部通过
- 第 12 项（外部记忆治理）→ 检查 mnemosyne home symlink 一致性

路径规范权威依据：`~/.hermes/audit/path-standards.md`（头部标准依据节，引用 Issue #892 / #8669）
