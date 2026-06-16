# 错误库

> 每一条错误记录的「机制」字段比「错误描述」更重要——不产出机制就不算闭环。
> 根SOUL第12条：被纠即升级。

---

## 001 | $HOME 重写触发连锁故障

**日期：** 2026-06-16
**纠正人：** 勇哥
**严重度：** P1（系统性知识缺失导致的反复故障）

### 错误描述

为修复 faster-whisper 模型缓存路径问题，凭感觉在各场景 `{HERMES_HOME}/home/` 目录下创建了 `.cache` symlink。此操作触发了 Hermes 的 `get_subprocess_home()` 机制，导致所有子进程（terminal、cron、code_execution）的 `$HOME` 被重写为 profile home。后续所有 `~/` 路径指向错误位置，引发一系列连锁故障（pip 装错位置、模型找不到、脚本跑偏）。

### 根因分析

1. **知识缺失**：不知道 `get_subprocess_home()` 的存在和工作机制——它检查 `{HERMES_HOME}/home/` 是否存在，存在则子进程 $HOME 指向此目录。这是 Hermes profile 隔离的设计特性，不是 bug。
2. **未查证直接执行**：涉及 `{HERMES_HOME}/home/`、`$HOME`、环境变量的操作，没有先查官方文档或社区 issue，凭感觉就动手。
3. **违反自有规范**：path-standards.md 明确写着"所有路径必须使用绝对路径"，但创建 symlink 时用了 `~/.cache` 而非 `/home/sqzy/.cache`。自己写的规范自己不执行。
4. **未 trace 完整调用链**：建目录前没有 trace 三条子进程路径——terminal（local.py:234）、cron（scheduler.py:1042）、code_execution（code_execution_tool.py:1269），不知道它们都依赖 `get_subprocess_home()`。

### 产出机制

1. **根SOUL第12a条（操作前置查证规则）**：涉及 `{HERMES_HOME}/home/`、`$HOME`、环境变量、profile 隔离路径的操作，必须先联网查 Hermes 官方文档或社区 issue，确认副作用后再执行。
2. **path-standards.md 补充**：所有路径绝对化，涉及 profile 隔离的路径操作需附录 A 检查清单。
3. **compliance-check 第8项**：检查所有路径引用是否为绝对路径。

### 修正行动

- 恢复各场景 `home/` 目录，正确初始化 `.cache` symlink（用绝对路径）
- `compliance-check.sh` 的 `REAL_HOME` 模式已在用，保持
- 学习 Hermes 官方架构文档 + Profile 机制 + Issue #8669、#27250

### 是否复现

未验证（需长期观察）
