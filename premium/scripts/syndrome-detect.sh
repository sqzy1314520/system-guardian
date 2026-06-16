#!/bin/bash
# syndrome-detect.sh — 症候群诊断仪
# 在 compliance-check 之后运行，检测关联故障模式并指向根因。
# 用法: bash ~/.hermes/scripts/syndrome-detect.sh
# 不重新检查各项，只读取已存在的文件和状态做关联分析。

REAL_HOME=$(getent passwd "$(whoami)" 2>/dev/null | cut -d: -f6)
[ -z "$REAL_HOME" ] && REAL_HOME="$HOME"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ok() { echo -e "${GREEN}✅${NC} $1"; }
warn() { echo -e "${YELLOW}⚡${NC} $1"; }
diag() { echo -e "${CYAN}🔍${NC} $1"; }

ROOT_SOUL="${REAL_HOME}/.hermes/SOUL.md"
AUDIT_DIR="${REAL_HOME}/.hermes/audit"
HEARTBEAT_FILE="${AUDIT_DIR}/HEARTBEAT"
MNEM_DB="${REAL_HOME}/.hermes/mnemosyne/data/mnemosyne.db"

echo ""
echo "═══════════════════════════════════════════"
echo "  症候群诊断 · $(date '+%Y-%m-%d %H:%M')"
echo "  不是多个独立问题，可能是一个根因。"
echo "═══════════════════════════════════════════"

FOUND_ANY=false

# ============================================================
# 症候群一：版本漂移
# 症状：版本锚不一致 + 规则条数不一致
# 诊断：改过根SOUL但忘了同步各场景SOUL
# ============================================================
ROOT_VER=$(grep -oP '版本 v\K[\d.]+' "$ROOT_SOUL" 2>/dev/null)
SCENE_MISMATCH=0
for scene in work study recreation shici poetry; do
    sf="${REAL_HOME}/.hermes/profiles/${scene}/SOUL.md"
    [ ! -f "$sf" ] && continue
    if ! grep -q "根SOUL.*v${ROOT_VER}" "$sf" 2>/dev/null; then
        SCENE_MISMATCH=$((SCENE_MISMATCH+1))
    fi
done

if [ "$SCENE_MISMATCH" -gt 0 ] && [ -n "$ROOT_VER" ]; then
    FOUND_ANY=true
    echo ""
    echo "═══ 症候群：版本漂移 ═══"
    warn "症状：${SCENE_MISMATCH}个场景SOUL版本锚未同步"
    warn "      根SOUL v${ROOT_VER}，场景未更新"
    diag "诊断：你改过根SOUL（版本号变更）但忘了同步各场景SOUL.md"
    diag "修复：sed -i 's/旧版本号/${ROOT_VER}/g' 各场景SOUL.md"
    echo ""
fi

# ============================================================
# 症候群二：治理未初始化
# 症状：approvals.mode 未配置 + audit 目录不完整 + 无锚点
# 诊断：系统装完Hermes后没跑过构建
# ============================================================
APPROVALS_OK=false
ANCHOR_OK=false
AUDIT_OK=false

grep -q 'approvals.mode.*manual\|mode:.*manual' "${REAL_HOME}/.hermes/profiles/control/config.yaml" 2>/dev/null && APPROVALS_OK=true
[ -f "${AUDIT_DIR}/content-anchors.md" ] && ANCHOR_OK=true
[ -d "$AUDIT_DIR" ] && AUDIT_OK=true

if ! $APPROVALS_OK && ! $ANCHOR_OK && ! $AUDIT_OK; then
    FOUND_ANY=true
    echo ""
    echo "═══ 症候群：治理未初始化 ═══"
    warn "症状：approvals.mode 未配置 + audit 目录不完整 + 无内容锚点"
    diag "诊断：系统装完Hermes后没跑过构建模式"
    diag '修复：说"帮我建系统"，走一遍构建向导'
    echo ""
elif ! $APPROVALS_OK && ! $AUDIT_OK; then
    FOUND_ANY=true
    echo ""
    echo "═══ 症候群：治理未初始化 ═══"
    warn "症状：approvals.mode 未配置 + audit 目录不完整"
    diag "诊断：构建模式可能中途中断或未完成"
    diag '修复：说"帮我建系统"，检查构建是否完整'
    echo ""
fi

# ============================================================
# 症候群三：调度停跳
# 症状：HEARTBEAT 超24h + cron job 未运行
# 诊断：定时调度器可能崩了
# ============================================================
HEARTBEAT_STALE=false
if [ -f "$HEARTBEAT_FILE" ]; then
    HB_TIME=$(cat "$HEARTBEAT_FILE" 2>/dev/null | grep -oP '\d{4}-\d{2}-\d{2} \d{2}:\d{2}')
    if [ -n "$HB_TIME" ]; then
        HB_EPOCH=$(date -d "$HB_TIME" +%s 2>/dev/null)
        NOW_EPOCH=$(date +%s)
        if [ -n "$HB_EPOCH" ]; then
            HOURS_SINCE=$(( (NOW_EPOCH - HB_EPOCH) / 3600 ))
            [ "$HOURS_SINCE" -gt 27 ] && HEARTBEAT_STALE=true
        fi
    fi
fi

# 检查 cron job 是否运行
CRON_STATE="${REAL_HOME}/.hermes/profiles/control/state.db"
CRON_DEAD=true
if [ -f "$CRON_STATE" ]; then
    JOB_COUNT=$(sqlite3 "$CRON_STATE" "SELECT COUNT(*) FROM cron_jobs WHERE state='scheduled';" 2>/dev/null || echo "0")
    [ "$JOB_COUNT" -gt 0 ] 2>/dev/null && CRON_DEAD=false
fi

if $HEARTBEAT_STALE && $CRON_DEAD; then
    FOUND_ANY=true
    echo ""
    echo "═══ 症候群：调度停跳 ═══"
    warn "症状：HEARTBEAT 超 ${HOURS_SINCE}h + cron job 全部未运行"
    diag "诊断：定时调度器可能崩了（hermes-cron-tick.timer 未运行或 schedule 格式损坏）"
    diag "排查：systemctl --user status hermes-cron-tick.timer"
    diag "排查：检查 jobs.json 中 interval job 是否有 minutes 键（不是 every）"
    echo ""
elif $HEARTBEAT_STALE; then
    FOUND_ANY=true
    echo ""
    echo "═══ 症候群：调度停跳 ═══"
    warn "症状：HEARTBEAT 超 ${HOURS_SINCE}h 未更新"
    diag "诊断：soul-daily-audit cron job 未在预期时间执行"
    diag "排查：确认 hermes-cron-tick.timer 是否在运行"
    echo ""
fi

# ============================================================
# 汇总
# ============================================================
if ! $FOUND_ANY; then
    echo ""
    ok "未检测到关联故障模式，各项指标独立健康。"
    echo ""
fi

echo "═══════════════════════════════════════════"
exit 0
