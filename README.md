# System Guardian · 系统卫士 🇨🇳🌐

**Your Hermes Agent is fragile. One wrong config and it breaks.**  
**System Guardian hardens it in 3 minutes.**

*你的 Hermes Agent 很脆弱。一个配错就崩。System Guardian 3 分钟让它变硬。*

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Hermes Agent](https://img.shields.io/badge/Hermes%20Agent-v0.10%2B-blueviolet)](https://hermes-agent.nousresearch.com)
[![Skill](https://img.shields.io/badge/agentskills.io-compatible-orange)](https://agentskills.io)
![Last commit](https://img.shields.io/github/last-commit/sqzy1314520/system-guardian)

---

## What it looks like · 装完就这样

One command, 12 checks, 3 seconds. Your whole system health, at a glance.

```
═══════════════════════════════════════════
  执行纪律巡检 · 2026-06-16 14:17
═══════════════════════════════════════════

── 11. 外部记忆（Mnemosyne）——
✅ control: memory.provider = mnemosyne
✅ Mnemosyne 读写正常（写→读→删全链路验证）
── 12. 外部记忆治理合规 ——
✅ control: mnemosyne home → centralized ✓

  2项违规  2项警告
  ✅ 28  ⚠️ 2  ❌ 2

═══════════════════════════════════════════
  症候群诊断 · 不是多个独立问题，是一个根因。
═══════════════════════════════════════════
✅ 未检测到关联故障模式，各项指标独立健康。
```

---

## The problem · 你遇到的

| You installed Hermes and... | System Guardian solves it |
|----------------------------|--------------------------|
| "Where do I even start?" | 🏗️ **Build** — 3 questions, auto-setup. SOUL.md, config, .bashrc, all done. |
| "Is my system still healthy today?" | ✅ **Check** — One command, 6 dimensions, 3 seconds. External memory, cron, capabilities, compliance. |
| "Something broke. Where do I look?" | 🔍 **Diagnose** — 7-dimension deep probe with syndrome detection. Not symptoms → root cause. |
| "What can my agent actually do?" | 📋 **Capability** — See/Hear/Read/Speak/Create, one matrix. |

---

## 30-second quick start · 30秒上手

```bash
hermes skills install https://github.com/sqzy1314520/system-guardian/raw/main/SKILL.md
```

Then just say:

| You say | What happens |
|---------|-------------|
| "帮我建系统" / "Build my system" | 3 questions → full governance setup |
| "检查一下" / "Check health" | 6-dimension scan in 3 seconds |
| "查查哪里不对" / "Diagnose" | 7-dimension deep audit + syndrome detection *(L3)* |
| "我能做什么" / "What can you do" | Capability matrix |

No config files to edit. No YAML to write. Just talk to your agent.

---

## Editions · 版本

**Not "free = less, paid = more". Different problems need different tools.**

| | L1: Setup | L2: Daily | L3: Deep Diagnose |
|:---:|:---------:|:---------:|:-----------------:|
| Who needs it | Just installed Hermes, don't know where to start | Daily health check user | Something broke, need root cause |
| Build wizard | ✅ Full | ✅ Full | ✅ Full |
| Health check | — | ✅ 6 dimensions | ✅ 6 dimensions + auto script |
| Architecture audit | — | — | ✅ 7-dimension + triad report |
| Capability matrix | ✅ Full | ✅ Full | ✅ Full |
| One-click check script | — | — | ✅ `compliance-check.sh` |
| Syndrome detection | — | — | ✅ links symptoms → root cause |
| **Price** | **Free** | **Free** | **Sponsor** |

---

## Who's using it · 谁在用

- **智正行动 / 中国联通镇江分公司** — production-hardened Hermes governance since June 2026. 5 scenes (work/study/recreation/shici/control), shared memory database, 749 records, 7 cron jobs, 12-item compliance check.

*Using System Guardian in your org? [Let us know](https://github.com/sqzy1314520/system-guardian/issues) and we'll add you here.*

---

## Sponsor · 赞助

**Free edition works for daily use.** Upgrade to L3 when you hit a real problem — cron stopped, heartbeat timed out, version drift across scenes. L3 doesn't give you "more features". It gives you **root cause instead of symptoms**.

| Tier | Price | What you get |
|------|-------|-------------|
| ☕ Basic | 19.9 CNY / $5 USD | L3 skill pack: 7-dim audit + syndrome detection + scripts |
| 🏆 Deep | 199 CNY / $30 USD | L3 + 1-on-1 remote setup + custom rules |

- 🇨🇳 [爱发电](https://afdian.com/a/meijiexueAI)
- 🌐 [Buy Me a Coffee](https://buymeacoffee.com/sqzy1314520)

---

## Project structure

```
system-guardian/
├── SKILL.md                        ← L1+L2 (free) entry point
├── references/
│   ├── build-guide.md              ← Build wizard
│   ├── check-procedure.md          ← Self-check items
│   └── capability-guide.md         ← 5-dimension capability
├── premium/                        ← L3 (sponsor access)
│   ├── SKILL.md
│   ├── references/
│   │   ├── check-procedure.md      ← Full 12 items
│   │   ├── audit-protocol.md       ← 7-dimension audit
│   │   └── monetization-strategy.md
│   └── scripts/
│       ├── compliance-check.sh     ← One-click health check
│       ├── audit-report.sh         ← Audit report generator
│       └── syndrome-detect.sh      ← Syndrome → root cause
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## Community

- 🐛 [Report Issues](https://github.com/sqzy1314520/system-guardian/issues)
- 💬 [Hermes Agent Discord](https://discord.gg/nousresearch) — share in `#plugins-skills-and-skins`
- 📖 [Hermes Agent Docs — Skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)
- ⭐ [Star on GitHub](https://github.com/sqzy1314520/system-guardian)

---

## License

MIT — L1+L2 free edition. L3 requires sponsor access.

---

*Built with ❤️ for the Hermes Agent community. 为 Hermes Agent 社区而生。*
