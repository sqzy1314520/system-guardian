# 灾难恢复 · Disaster Recovery

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
