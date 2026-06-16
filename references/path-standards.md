# Hermes 系统路径编写规范

> 版本：v1.0 | 创建：2026-06-14 | 维护：control
> 违反本规范的自检不通过（第8项·全局路径绝对性）

## 一、核心原则

**所有路径必须使用绝对路径。** 在整个 Hermes 系统中，不允许出现：
- 相对路径（`./scripts/xxx`、`../config.yaml`）
- 依赖 `$HOME` 但未考虑 profile 隔离的路径
- 占位符路径（如 `/path/to/root`）

唯一例外：`.bashrc` 中的自检脚本可以使用 `$HOME/.hermes/...` 模式（因为 `.bashrc` 在 WSL 启动时执行，不受 Hermes profile 隔离影响）。

## 二、$HOME 陷阱

### 问题
Hermes 以 `--profile <name>` 启动时，会将 `$HOME` 重写为 `$HERMES_HOME/home/`（如 `/home/sqzy/.hermes/profiles/work/home/`）。这是 profile 隔离的正常行为，但：

```bash
# ❌ 这样写会爆炸
SCRIPT_DIR="$HOME/.hermes/scripts"     # 指向错误的目录
```

### 验证
```bash
# WSL 启动后检查
echo $HOME                              # → /home/sqzy
hermes -p work chat -c "echo \$HOME"    # → /home/sqzy/.hermes/profiles/work/home/
```

## 三、Bash 脚本规范

### ✅ 正确写法：source paths.sh

所有 Bash 脚本第一段必须是：

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/paths.sh"
```

然后使用 paths.sh 中定义的变量：

| 变量 | 对应路径 |
|------|---------|
| `$REAL_HOME` | 系统真实家目录（如 `/home/sqzy`） |
| `$HERMES_ROOT` | `$REAL_HOME/.hermes` |
| `$HERMES_SCRIPTS` | `$HERMES_ROOT/scripts` |
| `$HERMES_AUDIT` | `$HERMES_ROOT/audit` |
| `$HERMES_SOUL` | `$HERMES_ROOT/SOUL.md` |
| `$HERMES_VENV_PYTHON` | `$REAL_HOME/.hermes/hermes-agent/venv/bin/python3` |
| `$CONTROL_SKILLS` | `$HERMES_ROOT/profiles/control/skills` |
| `$STUDY_PROFILE` | `$HERMES_ROOT/profiles/study` |
| 各场景 | 对应 profiles 目录 |

### ❌ 错误写法

```bash
# ❌ 硬编码用户名
HERMES_HOME="/home/sqzy/.hermes"

# ❌ 依赖被重写的 $HOME
SCRIPT_PATH="$HOME/.hermes/scripts/xxx"

# ❌ 死回退值
REAL_HOME=$(some_command) || REAL_HOME="/home/sqzy"

# ❌ 不用 paths.sh 自己写 getent
MY_HOME=$(getent passwd $(whoami) | cut -d: -f6)  # 每次重复写
```

## 四、Python 脚本规范

### ✅ 正确写法

```python
#!/usr/bin/env python3
import os, pwd
HOME = pwd.getpwuid(os.getuid()).pw_dir
ROOT_DIR = Path(f'{HOME}/.hermes')
SCRIPT_DIR = Path(f'{HOME}/.hermes/scripts')
```

`pwd.getpwuid(os.getuid()).pw_dir` 在任何环境下（包括 Hermes profile 隔离）都能拿到真实家目录。

### ❌ 错误写法

```python
# ❌ 依赖 HOME 环境变量（会被重写）
HOME = os.environ.get('HOME', '/home/sqzy')

# ❌ 硬编码用户名
HOME = "/home/sqzy" 
```

## 五、Config YAML 规范

### external_dirs

所有 `skills.external_dirs` 条目必须为绝对路径：

```yaml
# ✅ 正确
skills:
  external_dirs:
    - /home/sqzy/.hermes/profiles/control/skills

# ❌ 错误
skills:
  external_dirs:
    - ./skills
    - ~/.hermes/profiles/control/skills
```

### MCP servers 路径参数

所有文件系统路径参数必须为绝对路径：

```yaml
# ✅ 正确
mcp_servers:
  filesystem:
    args:
      - -y
      - '@modelcontextprotocol/server-filesystem'
      - /home/sqzy                          # 绝对路径

# ❌ 错误
mcp_servers:
  filesystem:
    args:
      - -y
      - '@modelcontextprotocol/server-filesystem'
      - /path/to/root                       # 占位符
```

### terminal.cwd

```yaml
# ✅ 正确（"." 表示当前工作目录，允许）
terminal:
  cwd: .

# ✅ 正确（绝对路径）
terminal:
  cwd: /home/sqzy/project

# ❌ 错误
terminal:
  cwd: ./projects    # 相对路径
```

## 六、Skills（技能库）规范

skills 是会被分发到其他系统的，**禁止硬编码 `/home/sqzy`**。

```markdown
# ✅ 正确：用描述性语言
运行以下命令检查 faster-whisper 是否安装：
```
pip list | grep -i -E "whisper|sounddevice"
```

# ❌ 错误：硬编码用户名路径
运行以下命令：
```
/home/sqzy/.hermes/hermes-agent/venv/bin/pip list | grep -i -E "whisper|sounddevice"
```
```

如果技能必须引用 Hermes 路径，使用 `$HERMES_HOME` 或 `~/.hermes/` 等环境变量，并注明环境假设。

## 七、迁移清单

从旧代码迁移到新规范的检查项：

- [ ] `grep -rn '/home/sqzy' ~/.hermes/scripts/` — 确认已全部替换为 paths.sh 变量
- [ ] `grep -rn '/path/to/' ~/.hermes/` — 确认无占位符路径
- [ ] `grep -rn 'os.environ.get.*HOME' ~/.hermes/scripts/*.py` — 确认用 pwd 替代
- [ ] 新脚本第一件事：source paths.sh（bash）或 pwd.getpwuid（python）
- [ ] 新技能：不使用 `/home/sqzy` 硬编码路径

## 八、自检保障

本规范由 compliance-check.sh 第8项（全局路径绝对性）自动检查：
- 扫描所有 config.yaml 的 external_dirs → 必须是绝对路径
- 扫描所有 config.yaml 的 MCP args → 不能有相对路径或占位符
- 扫描 .bashrc 自检路径 → 必须用 $HOME 或绝对路径
- 扫描所有 terminal.cwd → 不能有相对路径（"." 除外）
- 扫描所有 Python 脚本 → 禁止 `os.path.expanduser("~/.hermes")`，必须用 `os.environ.get("HERMES_HOME", os.path.expanduser("~/.hermes"))`
