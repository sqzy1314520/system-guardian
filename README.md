# System Guardian · 系统卫士

**Your Hermes Agent. Four dialogues. Full health.**
*你的 Hermes Agent。四句对话，全维健康。*

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Hermes Agent](https://img.shields.io/badge/Hermes%20Agent-v0.10+-blueviolet)](https://hermes-agent.nousresearch.com)
[![Last commit](https://img.shields.io/github/last-commit/sqzy1314520/system-guardian)](https://github.com/sqzy1314520/system-guardian)

---

## What it looks like · 跑起来就这样

```
你好，我是 System Guardian。告诉我你想做什么？

[1] 🆕 我刚装好，帮我跑起来
[2] ✅ 检查一下系统还好吗
[3] 🔧 出问题了，帮我看看
[4] 🚀 我想加个新功能
```

---

## Quick start · 30 秒上手

### Option A: Install as a Hermes skill

```bash
hermes skills install https://github.com/sqzy1314520/system-guardian/raw/main/SKILL.md
```

Then just say to your agent:

| You say | What happens |
|---------|-------------|
| "帮我跑起来" | Stage 1: Enter API key → choose model → done |
| "检查一下" | Stage 2: 12-dimension health check in 3 seconds |
| "出问题了" | Stage 3: Interactive diagnosis — tell me what happened |
| "加个定时任务" | Stage 4: 3-question wizard creates a cron job |

### Option B: Run standalone

```bash
# Clone the repo
git clone https://github.com/sqzy1314520/system-guardian.git
cd system-guardian
# Load as a skill
hermes skills install ./SKILL.md
```

---

## ✨ v3.0 New Features

| Before v3.0 | After v3.0 |
|-------------|------------|
| One mode: self-check | Four modes: setup / daily-check / diagnosis / features |
| 12-dimension check | 12 dimensions + syndrome diagnosis + Goal tracking |
| No guided setup | Interactive 3-question setup wizard |
| No cron creation | Dialog-driven cron job creator |
| 10 internal Pitfalls | 50+ community Pitfalls (sanitized) |
| ─ | **Physical Gate system** (quality constraints) |

---

## 🧱 Physical Gate System (原创质量约束)

Not "how to do it" instructions — "what you can't skip" constraints.

| Gate | Rule |
|------|------|
| 🚪 Process Gate | No article structure before intake analysis. No structure design before material filtering. |
| 📦 Material Gate | Label every material as usable/needs-verify/unusable before deriving structure. |
| ✅ Delivery Gate | No "done" without cover + illustrations + audio + checklist. User wants confirmation, not completion. |
| 📋 Audit Gate | Every dispatch must log task ID / time / role / tools / duration. |

---

## 12-dimension Health Check

| # | Dimension | What it checks |
|---|-----------|----------------|
| 1 | Identity | SOUL consistency across profiles |
| 2 | Version Anchors | All profiles reference the same root SOUL version |
| 3 | Memory Level | MEMORY.md / USER.md within character limits |
| 4 | Path Standards | No hardcoded paths in scripts |
| 5 | Pipeline Config | approvals, content anchors, compliance hash |
| 6 | Skill Health | Availability + completeness check |
| 7 | Cron State | All cron jobs running correctly |
| 8 | External Memory | Mnemosyne read/write verification |
| 9 | Gateway Status | Default gateway + message channels up |
| 10 | HEARTBEAT | Last audit < 27h ago |
| 11 | Capabilities | Vision / STT / TTS / Search / Skills availability |
| 12 | SLA | Overall health grade (🟢/🟡/🔴) |

---

## 🏗 Architecture

```
┌─────────────────────────────────────┐
│        System Guardian              │
├─────────────────────────────────────┤
│         Four-stage Navigation       │
│  [1] Setup ── [2] Check ── [3] Diag │
│              [4] Features           │
├─────────────────────────────────────┤
│      Underlying 12-dimension Check  │
├─────────────────────────────────────┤
│   Syndrome Diagnosis / Maker-Checker│
├─────────────────────────────────────┤
│    Physical Gates / Cron Management │
├─────────────────────────────────────┤
│   50+ Community Pitfalls (curated)  │
└─────────────────────────────────────┘
```

---

## License · 许可

MIT — do whatever you want, just don't blame us if something breaks.

---

## Contributing · 贡献

PRs welcome. Especially:
- New Pitfalls from your own experience
- Translation improvements
- Reference implementations for other agent frameworks

Built with ❤️ from Hermes Agent ecosystem.
