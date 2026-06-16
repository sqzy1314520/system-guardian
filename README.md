# System Guardian · 系统卫士 🇨🇳🌐

> 构建 → 自查 → 审计 → 能力，四合一管好你的 Hermes 系统。
> **Build → Check → Audit → Capability — Four modes to govern your Hermes Agent.**

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Hermes Agent](https://img.shields.io/badge/Hermes%20Agent-v0.10%2B-blueviolet)](https://hermes-agent.nousresearch.com)
[![Skill](https://img.shields.io/badge/agentskills.io-compatible-orange)](https://agentskills.io)

---

## Why System Guardian?

Hermes Agent is powerful — but it's also **easy to break**.

New users install it and don't know: *"Where do I start? What do I configure? Is my agent secure?"*

Experienced users ask: *"Is everything still healthy? Did my cron jobs stop running? Did a config drift?"*

**System Guardian answers both.** One skill, three modes, from zero to production-hardened.

- 🏗️ **Build** — Three questions, one command, a fully governed Hermes Agent. SOUL.md, config.yaml, .bashrc, content anchors, compliance checks — all set up automatically.
- ✅ **Check** — Full health check. 6 dimensions: external memory, cron jobs, 5-dimension capability, channel connectivity, skills loading, compliance. 3 seconds.
- 🔍 **Audit** — 7-dimension deep architecture probe. Pipeline integrity, governance coverage, monitoring, routing, scheduling, foundations, memory governance. *(Premium)*
- 📋 **Capability** — See what your agent can (and cannot) do. Five dimensions: See, Hear, Read, Speak, Create.

---

## Demo

### One command, 10 checks, 3 seconds

![self-check-demo](screenshot-selfcheck.png)

*10-item health scan. 3 seconds. One command.*

### Capability matrix

```
╔══════════════════════════════════╗
║         Capability Matrix        ║
╠══════════════════════════════════╣
║ 👁️  See     ████████░░  80%     ║
║ 👂  Hear    ████████░░  80%     ║
║ 📖  Read    ██████████ 100%     ║
║ 🗣️  Speak   ██████████ 100%     ║
║ 🎨  Create  ██████░░░░  60%     ║
╚══════════════════════════════════╝
```

---

## Quick Start

```bash
hermes skills install https://github.com/sqzy1314520/system-guardian/raw/main/SKILL.md
```

Then just say:

| You Say | What Happens |
|---------|-------------|
| "帮我建系统" / "Build my system" | 3-question wizard → auto-configures Hermes governance |
| "检查一下" / "Check health" | 6-dimension health scan in 3 seconds |
| "查查哪里不对" / "Audit deep" | 6-dimension deep audit *(premium)* |
| "我能做什么" / "Capabilities" | See/Hear/Read/Speak/Create matrix |

---

## Editions

| Module | Free (MIT) | Premium (Sponsor) |
|--------|-----------|-------------------|
| 🏗️ Build wizard | ✅ Full | ✅ Full |
| ✅ Self-check | ✅ 6 dimensions | ✅ 6 dimensions + auto script |
| 🔍 Architecture audit | ❌ | ✅ 7-dimension + triad report |
| 📋 Capability matrix | ✅ Full | ✅ Full |
| 📜 One-click check script | ❌ | ✅ `compliance-check.sh` |
| 📜 Audit report script | ❌ | ✅ `audit-report.sh` |
| 🆕 All future updates | ✅ | ✅ |
| 👨‍💻 1-on-1 setup guidance | ❌ | ✅ Deep sponsor |

---

## Project Structure

```
system-guardian/
├── SKILL.md                        ← Free edition entry point
├── references/
│   ├── build-guide.md              ← Build mode walkthrough
│   ├── check-procedure.md          ← Self-check items (basic)
│   └── capability-guide.md         ← 5-dimension capability
├── premium/                        ← Premium (sponsor access)
│   ├── SKILL.md
│   ├── references/
│   │   ├── check-procedure.md      ← Full 10 items
│   │   ├── audit-protocol.md       ← 6-dimension audit
│   │   └── monetization-strategy.md
│   └── scripts/
│       ├── compliance-check.sh     ← One-click health check
│       └── audit-report.sh         ← Audit report generator
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## Sponsor · 赞助

| Tier | Price | What you get |
|------|-------|-------------|
| ☕ Basic | 19.9 CNY / $5 USD | Premium skill pack (audit + scripts) |
| 🏆 Deep | 199 CNY / $30 USD | Premium + 1-on-1 remote setup guidance |

- 🇨🇳 [爱发电](https://afdian.com/a/meijiexueAI)
- 🌐 [Buy Me a Coffee](https://buymeacoffee.com/sqzy1314520)

---

## Community

- 🐛 [Report Issues](https://github.com/sqzy1314520/system-guardian/issues)
- 💬 [Hermes Agent Discord](https://discord.gg/nousresearch) — share in `#plugins-skills-and-skins`
- 📖 [Hermes Agent Docs — Skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)
- ⭐ [Star on GitHub](https://github.com/sqzy1314520/system-guardian) — helps others find this!

---

## Topics

`hermes-agent` `agent-governance` `self-check` `ai-governance` `devops` `system-guardian` `agentskills` `nous-research`

---

## License

MIT — Free edition. Premium edition requires sponsor access.

---

*Built with ❤️ for the Hermes Agent community. 为 Hermes Agent 社区而生。*
