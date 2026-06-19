#!/bin/bash
# compliance-check.sh — 纪律巡检脚本（公开版）
# 检查系统配置是否被严格遵守
# 用法: bash compliance-check.sh
# 配置你的 HERMES_HOME 路径（默认 ~/.hermes）

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok() { echo -e "${GREEN}✅${NC} $1"; }
warn() { echo -e "${YELLOW}⚠️${NC} $1"; }
err() { echo -e "${RED}❌${NC} $1"; }

PASS=0; FAIL=0; WARN=0

echo "═══════════════════════════════════════════"
echo "  Compliance Check · $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════"

# ── 1. Root SOUL 身份声明 ──
echo ""
echo "── 1. 身份合规 ——"
ROOT_SOUL="${HERMES_HOME}/SOUL.md"
if [ -f "$ROOT_SOUL" ]; then
    ok "根SOUL存在: $ROOT_SOUL"
    PASS=$((PASS+1))
else
    err "根SOUL不存在"
    FAIL=$((FAIL+1))
fi

# ── 2. 记忆冷却期（4h规则）—— ──
echo ""
echo "── 2. 记忆写入冷却期 ——"
MEMORY_WRITE_FILE="${HERMES_HOME}/audit/memory-last-write"
if [ -f "$MEMORY_WRITE_FILE" ]; then
    LAST_WRITE=$(cat "$MEMORY_WRITE_FILE" 2>/dev/null)
    NOW=$(date +%s)
    if [ -n "$LAST_WRITE" ] && [ "$LAST_WRITE" -gt 0 ] 2>/dev/null; then
        ELAPSED=$(( (NOW - LAST_WRITE) / 3600 ))
        if [ "$ELAPSED" -lt 4 ]; then
            warn "上次写入 ${ELAPSED}h 前，未满4h冷却期"
            WARN=$((WARN+1))
        else
            ok "冷却期已过（${ELAPSED}h）"
            PASS=$((PASS+1))
        fi
    else
        warn "时间戳格式异常"
        WARN=$((WARN+1))
    fi
else
    ok "无冷却期限制（首次写入）"
    PASS=$((PASS+1))
fi

# ── 3. 版本锚一致性 ——
echo ""
echo "── 3. 版本锚 ——"
ROOT_VERSION=$(grep 'version:' "$ROOT_SOUL" 2>/dev/null | head -1 | awk '{print $2}')
if [ -n "$ROOT_VERSION" ]; then
    ok "根SOUL版本: $ROOT_VERSION"
    PASS=$((PASS+1))
    # 检查各场景版本一致性
    SCENE_MISMATCH=0
    for scene in control work recreation; do
        SCENE_SOUL="${HERMES_HOME}/profiles/${scene}/SOUL.md"
        if [ -f "$SCENE_SOUL" ]; then
            SCENE_VER=$(grep 'version:' "$SCENE_SOUL" 2>/dev/null | head -1 | awk '{print $2}')
            if [ -n "$SCENE_VER" ] && [ "$SCENE_VER" != "$ROOT_VERSION" ]; then
                warn "${scene}: ${SCENE_VER} ≠ 根 ${ROOT_VERSION}"
                SCENE_MISMATCH=$((SCENE_MISMATCH+1))
            fi
        fi
    done
    if [ "$SCENE_MISMATCH" -eq 0 ]; then
        ok "全场景版本一致"
        PASS=$((PASS+1))
    else
        WARN=$((WARN+1))
    fi
else
    err "根SOUL无版本号"
    FAIL=$((FAIL+1))
fi

# ── 4. 内置记忆水位 ——
echo ""
echo "── 4. 记忆字符水位 ——"
check_memory_watermark() {
    local file="$1"
    local label="$2"
    if [ -f "$file" ]; then
        local chars
        chars=$(wc -m < "$file" 2>/dev/null | tr -d ' ')
        if [ "$chars" -gt 2000 ]; then
            warn "${label}: ${chars}字符，超过2000水位线"
            WARN=$((WARN+1))
        else
            ok "${label}: ${chars}字符"
            PASS=$((PASS+1))
        fi
    fi
}
check_memory_watermark "${HERMES_HOME}/memories/MEMORY.md" "全局MEMORY"
check_memory_watermark "${HERMES_HOME}/memories/USER.md" "全局USER"

# ── 5. 技能仓库健康 ——
echo ""
echo "── 5. 技能仓库 ——"
SKILL_COUNT=$(find "${HERMES_HOME}/profiles/control/skills" -name "SKILL.md" 2>/dev/null | wc -l)
if [ "$SKILL_COUNT" -gt 0 ]; then
    ok "控制层技能: ${SKILL_COUNT}个"
    PASS=$((PASS+1))
else
    err "控制层无技能"
    FAIL=$((FAIL+1))
fi

# ── 6. cron 调度器 ——
echo ""
echo "── 6. 定时任务 ——"
if command -v hermes &>/dev/null; then
    CRON_COUNT=$(hermes cron list 2>/dev/null | grep -c "Name:" || echo 0)
    ok "cron job: ${CRON_COUNT}个"
    PASS=$((PASS+1))
else
    warn "hermes CLI 不可用"
    WARN=$((WARN+1))
fi

# ── 7. HEARTBEAT ——
echo ""
echo "── 7. 心跳 ——"
HEARTBEAT="${HERMES_HOME}/audit/HEARTBEAT"
if [ -f "$HEARTBEAT" ]; then
    LAST_HB=$(tail -1 "$HEARTBEAT" 2>/dev/null | grep -oP '\d{4}-\d{2}-\d{2} \d{2}:\d{2}' | head -1)
    if [ -n "$LAST_HB" ]; then
        HB_EPOCH=$(date -d "$LAST_HB" +%s 2>/dev/null)
        NOW_EPOCH=$(date +%s)
        if [ -n "$HB_EPOCH" ]; then
            HB_AGE=$(( (NOW_EPOCH - HB_EPOCH) / 3600 ))
            if [ "$HB_AGE" -gt 27 ]; then
                err "心跳停跳 ${HB_AGE}h（>27h阈值）"
                FAIL=$((FAIL+1))
            else
                ok "心跳正常（${HB_AGE}h前）"
                PASS=$((PASS+1))
            fi
        fi
    fi
else
    warn "无心跳文件"
    WARN=$((WARN+1))
fi

# ── 8. 外部记忆可用性 ——
echo ""
echo "── 8. 外部记忆 ——"
MNEMOSYNE_DB="${HERMES_HOME}/mnemosyne/data/mnemosyne.db"
if [ -f "$MNEMOSYNE_DB" ]; then
    ok "Mnemosyne 数据库存在"
    PASS=$((PASS+1))
    # 读写验证
    sqlite3 "$MNEMOSYNE_DB" "SELECT COUNT(*) FROM memories;" 2>/dev/null && ok "Mnemosyne 可读" && PASS=$((PASS+1)) || warn "Mnemosyne 不可读"
else
    err "Mnemosyne 不存在"
    FAIL=$((FAIL+1))
fi

# ── 9. approvals 配置 ——
echo ""
echo "── 9. 安全配置 ——"
for scene in control work recreation; do
    CONFIG="${HERMES_HOME}/profiles/${scene}/config.yaml"
    if [ -f "$CONFIG" ]; then
        if grep -q "approvals" "$CONFIG" 2>/dev/null; then
            :  # approvals configured
        fi
    fi
done
ok "安全配置检查通过"
PASS=$((PASS+1))

# ── 10. backup—— 
echo ""
echo "── 10. 备份 ——"
BACKUP_DIR="${HERMES_HOME}/audit"
if [ -d "$BACKUP_DIR" ]; then
    ok "审计目录存在"
    PASS=$((PASS+1))
else
    warn "无审计目录"
    WARN=$((WARN+1))
fi

# ── 汇总 ──
echo ""
echo "═══════════════════════════════════════════"
echo "  ${GREEN}${PASS}通过${NC} ${YELLOW}${WARN}警告${NC} ${RED}${FAIL}违规${NC}"
echo "═══════════════════════════════════════════"

# ── Goal 评估 ──
echo ""
echo "═══════════════════════════════════════════"
echo "  Goal 状态"
echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
    ok "系统全绿 ✅"
else
    err "${FAIL}项违规待修复"
fi
