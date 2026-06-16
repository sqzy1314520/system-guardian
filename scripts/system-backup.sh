#!/bin/bash
# system-backup.sh — 全局系统备份
# 用法: bash ~/.hermes/scripts/system-backup.sh
# 功能: 备份所有场景（control/work/study/recreation/shici/poetry）核心资产到 D 盘

set -e

# 检测真实系统家目录（抵抗 $HOME 重写）
REAL_HOME=$(getent passwd "$(whoami)" 2>/dev/null | cut -d: -f6)
[ -z "$REAL_HOME" ] && REAL_HOME="/home/sqzy"
HERMES_HOME="${REAL_HOME}/.hermes"
SNAPSHOT_DIR="/mnt/d/Hermes/backups/system-snapshot/$(date +%Y-%m-%d)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

echo "========================================"
echo "系统备份 · ${TIMESTAMP}"
echo "========================================"

# 创建快照目录
mkdir -p "${SNAPSHOT_DIR}"/{hermes,work,study,recreation,shici,poetry}

# 根配置 + control
echo "[1/4] 备份根配置 + control..."

cp "${HERMES_HOME}/SOUL.md" "${SNAPSHOT_DIR}/hermes/" 2>/dev/null && echo "  ✓ SOUL.md"
cp "${HERMES_HOME}/env-facts.md" "${SNAPSHOT_DIR}/hermes/" 2>/dev/null || echo "  - env-facts.md 不存在（跳过）"
cp "${HERMES_HOME}/config.yaml" "${SNAPSHOT_DIR}/hermes/" 2>/dev/null && echo "  ✓ config.yaml"
cp -r "${HERMES_HOME}/memories" "${SNAPSHOT_DIR}/hermes/" 2>/dev/null && echo "  ✓ memories/"
cp -r "${HERMES_HOME}/wiki" "${SNAPSHOT_DIR}/hermes/" 2>/dev/null && echo "  ✓ wiki/"
cp -r "${HERMES_HOME}/scripts" "${SNAPSHOT_DIR}/hermes/" 2>/dev/null && echo "  ✓ scripts/"
cp -r "${HERMES_HOME}/audit" "${SNAPSHOT_DIR}/hermes/" 2>/dev/null && echo "  ✓ audit/"
[ -f "${HERMES_HOME}/mnemosyne/data/mnemosyne.db" ] && cp "${HERMES_HOME}/mnemosyne/data/mnemosyne.db" "${SNAPSHOT_DIR}/hermes/" && echo "  ✓ mnemosyne.db"

# control profile（单独目录，不覆盖根SOUL）
mkdir -p "${SNAPSHOT_DIR}/control"
cp "${HERMES_HOME}/profiles/control/SOUL.md" "${SNAPSHOT_DIR}/control/" 2>/dev/null && echo "  ✓ control/SOUL.md"
cp "${HERMES_HOME}/profiles/control/config.yaml" "${SNAPSHOT_DIR}/control/" 2>/dev/null && echo "  ✓ control/config.yaml"
cp -r "${HERMES_HOME}/profiles/control/skills" "${SNAPSHOT_DIR}/control/" 2>/dev/null && echo "  ✓ control/skills/ (全局技能)"

# === 各场景 ===
echo "[2/3] 备份各场景..."
for prof in work study recreation shici poetry; do
  src="${HERMES_HOME}/profiles/${prof}"
  dst="${SNAPSHOT_DIR}/${prof}"
  if [ ! -d "${src}" ]; then
    echo "  - ${prof}: 目录不存在，跳过"
    continue
  fi
  mkdir -p "${dst}"
  cp "${src}/SOUL.md" "${dst}/" 2>/dev/null && echo "  ✓ ${prof}/SOUL.md"
  cp "${src}/config.yaml" "${dst}/" 2>/dev/null && echo "  ✓ ${prof}/config.yaml"
  [ -d "${src}/memories" ] && cp -r "${src}/memories" "${dst}/" && echo "  ✓ ${prof}/memories/"
  [ -d "${src}/skills" ] && cp -r "${src}/skills" "${dst}/" && echo "  ✓ ${prof}/skills/"
  [ -d "${src}/cron" ] && cp -r "${src}/cron" "${dst}/" 2>/dev/null && echo "  ✓ ${prof}/cron/"
  [ -f "${src}/state.db" ] && cp "${src}/state.db" "${dst}/" && echo "  ✓ ${prof}/state.db"
done

# === 生成文档 ===
echo "[3/3] 生成文档..."
SIZE=$(du -sh "${SNAPSHOT_DIR}" 2>/dev/null | cut -f1)
COUNT=$(find "${SNAPSHOT_DIR}" -type f | wc -l)

cat > "${SNAPSHOT_DIR}/README.md" << EOF
# 系统快照 $(date +%Y-%m-%d)

## 一句话恢复
\`\`\`bash
rsync -av --exclude='.env' "${SNAPSHOT_DIR}/" ~/.hermes/
\`\`\`

## 内容
- 文件数: ${COUNT}
- 总大小: ${SIZE}
- 备份时间: ${TIMESTAMP}

## 包含
- 根SOUL · 全局配置 · 记忆 · Wiki · 审计日志 · mnemosyne.db
- control 全局技能库
- 各场景（work/study/recreation/shici/poetry）的 SOUL/config/memories/skills/cron/state.db

## 不包含
- .env（API key）— 需重新配置
- 缓存/日志文件

## 手动恢复
见 RESTORE.md
EOF

cat > "${SNAPSHOT_DIR}/RESTORE.md" << 'EOF'
# 手动恢复步骤

## 前置
确认备份日期正确，Hermes 未运行。

## 场景A：文件被误删（某个脚本/SOUL.md/config.yaml）
```bash
# 恢复单个文件
cp /mnt/d/Hermes/backups/system-snapshot/YYYY-MM-DD/hermes/scripts/xxx.sh ~/.hermes/scripts/
```

## 场景B：state.db / mnemosyne.db 损坏
```bash
# 恢复整个数据库
cp /mnt/d/Hermes/backups/system-snapshot/YYYY-MM-DD/hermes/mnemosyne.db ~/.hermes/mnemosyne/data/

# 恢复某个场景的会话
cp /mnt/d/Hermes/backups/system-snapshot/YYYY-MM-DD/work/state.db ~/.hermes/profiles/work/
```

## 场景C：全量恢复
```bash
# 恢复根配置 + 数据库
cp snapshot_dir/hermes/SOUL.md ~/.hermes/SOUL.md
cp snapshot_dir/hermes/config.yaml ~/.hermes/config.yaml
cp snapshot_dir/hermes/mnemosyne.db ~/.hermes/mnemosyne/data/mnemosyne.db
cp -r snapshot_dir/hermes/memories ~/.hermes/
cp -r snapshot_dir/hermes/scripts ~/.hermes/

# 恢复各场景
for prof in work study recreation shici poetry; do
  [ -d "snapshot_dir/$prof" ] && {
    cp -r "snapshot_dir/$prof/"* ~/.hermes/profiles/$prof/
  }
done
```

## 注意事项
- 不恢复 .env（API key 需重新配置）
- 恢复后需重启 Hermes
- 恢复前建议先对当前 state.db 做一次备份
EOF

echo ""
echo "========================================"
echo "备份完成"
echo "  位置: ${SNAPSHOT_DIR}/"
echo "  文件: ${COUNT} 个"
echo "  大小: ${SIZE}"
echo "========================================"

# === D盘常驻镜像 ===
echo ""
echo "[4/4] 同步 audit 常驻镜像到 D 盘..."
cp -r "${HERMES_HOME}/audit" "${SNAPSHOT_DIR}/../" 2>/dev/null && echo "  ✓ /mnt/d/Hermes/backups/audit/"
echo "  ✓ 完成"
