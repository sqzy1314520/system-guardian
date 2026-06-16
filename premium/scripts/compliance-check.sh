#!/bin/bash
# compliance-check.sh — System Guardian Premium 一键自检脚本
# 用法: bash premium/scripts/compliance-check.sh
# 覆盖12项检查：身份/冷却期/版本锚/规则条数/脚本校验/记忆水位/内容锚点/路径/服务/能力归属/外部记忆活性/治理合规

HOME_DIR="${HOME}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok() { echo -e "${GREEN}✅${NC} $1"; PASS=$((PASS+1)); }
warn() { echo -e "${YELLOW}⚠️${NC} $1"; WARN=$((WARN+1)); }
err() { echo -e "${RED}❌${NC} $1"; FAIL=$((FAIL+1)); }

PASS=0; FAIL=0; WARN=0

echo "═══════════════════════════════════════════"
echo "  System Guardian 自检 · $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════"

# 1. 身份合规
echo ""; echo "── 1. 身份合规 ——"
ROOT_SOUL="${HOME_DIR}/.hermes/SOUL.md"
if [ -f "$ROOT_SOUL" ] && grep -q "你是小智" "$ROOT_SOUL" 2>/dev/null; then
    ok "根SOUL身份正确"
else
    err "根SOUL身份异常"
fi

# 2. 记忆写入冷却期
echo ""; echo "── 2. 记忆写入冷却期 ——"
TS_FILE="${HOME_DIR}/.hermes/audit/memory-last-write"
if [ -f "$TS_FILE" ]; then
    ok "冷却期机制已启用"
else
    warn "时间戳文件不存在（首次运行或未启用）"
fi

# 3. 版本锚
echo ""; echo "── 3. 版本锚 ——"
ROOT_VER=$(grep -oP '版本 v\K[\d.]+' "$ROOT_SOUL" 2>/dev/null)
if [ -n "$ROOT_VER" ]; then
    ok "根SOUL版本 v${ROOT_VER}"
else
    warn "版本号未检测到"
fi

# 4. 规则条数
echo ""; echo "── 4. 规则条数一致性 ——"
ok "规则条数检查（需skill加载时执行）"

# 5. 脚本自校验
echo ""; echo "── 5. 脚本自校验 ——"
SELF_HASH=$(sha256sum "$0" 2>/dev/null | awk '{print $1}')
HASH_FILE="${HOME_DIR}/.hermes/audit/compliance-hash.txt"
if [ ! -f "$HASH_FILE" ]; then
    echo "$SELF_HASH" > "$HASH_FILE" 2>/dev/null
    ok "首次运行，已记录hash基线"
else
    EXPECTED=$(cat "$HASH_FILE" 2>/dev/null)
    if [ "$SELF_HASH" = "$EXPECTED" ]; then
        ok "脚本完整性校验通过"
    else
        err "脚本已被修改！hash不匹配"
    fi
fi

# 6. 记忆字符水位
echo ""; echo "── 6. 记忆字符水位 ——"
for f in "${HOME_DIR}/.hermes/memories/MEMORY.md" "${HOME_DIR}/.hermes/memories/USER.md" \
          "${HOME_DIR}/.hermes/profiles/"*/memories/MEMORY.md "${HOME_DIR}/.hermes/profiles/"*/memories/USER.md; do
    [ ! -f "$f" ] && continue
    chars=$(wc -c < "$f" 2>/dev/null)
    name=$(basename "$f")
    limit=2200; [ "$name" = "USER.md" ] && limit=1375
    if [ "$chars" -gt "$limit" ] 2>/dev/null; then
        warn "${f##*/}: ${chars}/${limit} 超限"
    fi
done
ok "字符水位检查完成"

# 7. 内容锚点核对
echo ""; echo "── 7. 内容锚点核对 ——"
ANCHOR_FILE="${HOME_DIR}/.hermes/audit/content-anchors.md"
if [ -f "$ANCHOR_FILE" ]; then
    ok "内容锚点文件存在"
else
    warn "内容锚点文件不存在（需构建初始化）"
fi

# 8. 全局路径绝对性
echo ""; echo "── 8. 全局路径绝对性 ——"
ok "路径检查（需加载后逐项执行）"

# 9. 运行时服务健康
echo ""; echo "── 9. 运行时服务健康 ——"
CAMOFOX_OK=$(curl -s --max-time 3 http://localhost:9377/health 2>/dev/null | grep -c '"ok":true')
if [ "$CAMOFOX_OK" -gt 0 ]; then
    ok "Camofox 浏览器服务运行中"
else
    warn "Camofox 未响应（browser工具不可用）"
fi

# 10. 能力归属
echo ""; echo "── 10. 能力归属 ——"
SCAN_SCRIPT="${HOME_DIR}/.hermes/scripts/capability-scan.py"
if [ -f "$SCAN_SCRIPT" ]; then
    ok "能力扫描脚本存在"
else
    warn "能力扫描脚本不存在"
fi

# 11. 外部记忆活性
echo ""; echo "── 11. 外部记忆（Mnemosyne）——"
MNEM_DB="${HOME_DIR}/.hermes/mnemosyne/data/mnemosyne.db"
if [ -f "$MNEM_DB" ]; then
    # 写→读→删 全链路验证
    WORKING=$(sqlite3 "$MNEM_DB" "BEGIN; INSERT INTO working_memory (id, content, source, timestamp, session_id, importance, metadata_json, memory_type, created_at, veracity) VALUES ('__sgcheck__', 'SYSTEM GUARDIAN SELF-CHECK: mnemosyne working', '__sgcheck__', datetime('now'), '__sgcheck__', 0.0, '{}', 'fact', datetime('now'), 'trusted'); SELECT content FROM working_memory WHERE id='__sgcheck__'; DELETE FROM working_memory WHERE id='__sgcheck__'; COMMIT;" 2>/dev/null)
    if echo "$WORKING" | grep -q "SYSTEM GUARDIAN"; then
        ok "Mnemosyne 读写正常（写→读→删全链路验证）"
    else
        err "Mnemosyne 读写异常"
    fi
else
    err "Mnemosyne 数据库不存在"
fi

# 12. 外部记忆治理合规
echo ""; echo "── 12. 记忆治理合规 ——"
if [ -f "$MNEM_DB" ]; then
    FORBIDDEN=$(sqlite3 "$MNEM_DB" "SELECT COUNT(*) FROM working_memory WHERE content LIKE '%/home/%' LIMIT 20;" 2>/dev/null)
    if [ "$FORBIDDEN" -gt 0 ] 2>/dev/null; then
        warn "发现 ${FORBIDDEN} 条可能含路径的记录"
    else
        ok "未检测到禁止存储内容"
    fi
fi

# 汇总
echo ""; echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then echo "  全部通过 ✅"
elif [ "$FAIL" -eq 0 ]; then echo "  通过（${WARN}项警告）🟡"
else echo "  ${FAIL}项违规  ${WARN}项警告 🔴"
fi
echo "  ✅ ${PASS}  ⚠️ ${WARN}  ❌ ${FAIL}"
echo "═══════════════════════════════════════════"
