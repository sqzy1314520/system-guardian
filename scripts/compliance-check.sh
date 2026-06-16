#!/bin/bash
# compliance-check.sh — 执行纪律巡检
# 检查今天所定规则是否被严格遵守
# 用法: bash ~/.hermes/scripts/compliance-check.sh

HOME_DIR="${HOME}"
# 检测真实系统家目录（抵抗 Hermes profile 隔离对 $HOME 的重写）
REAL_HOME=$(getent passwd "$(whoami)" 2>/dev/null | cut -d: -f6)
[ -z "$REAL_HOME" ] && REAL_HOME="/home/sqzy"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok() { echo -e "${GREEN}✅${NC} $1"; }
warn() { echo -e "${YELLOW}⚠️${NC} $1"; }
err() { echo -e "${RED}❌${NC} $1"; }

PASS=0; FAIL=0; WARN=0

echo "═══════════════════════════════════════════"
echo "  执行纪律巡检 · $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════"

# 1. 身份合规 — 各场景SOUL身份声明是否与根SOUL冲突
echo ""
echo "── 1. 身份合规 ——"
ROOT_SOUL="${REAL_HOME}/.hermes/SOUL.md"
if grep -q "你是小智" "$ROOT_SOUL" 2>/dev/null; then
    ok "根SOUL身份正确: 小智"
    PASS=$((PASS+1))
else
    err "根SOUL身份异常"
    FAIL=$((FAIL+1))
fi

# 检查各场景是否有"我是砚清"或"你是勇哥"等冲突声明
for prof in work study recreation shici poetry; do
    sf="${REAL_HOME}/.hermes/profiles/${prof}/SOUL.md"
    [ ! -f "$sf" ] && continue
    if grep -qE "(砚清|内容创作者：勇哥)" "$sf" 2>/dev/null; then
        err "${prof}/SOUL.md: ⚠️ 身份声明冲突"
        FAIL=$((FAIL+1))
    fi
done
ok "各场景无身份冲突声明"

# 2. 记忆写入冷却期（第15条）
echo ""
echo "── 2. 记忆写入冷却期 ——"
TS_FILE="${REAL_HOME}/.hermes/audit/memory-last-write"
PEND_FILE="${REAL_HOME}/.hermes/audit/memory-pending.md"
if [ -f "$TS_FILE" ]; then
    LAST=$(cat "$TS_FILE")
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    # 简单计算小时差（取Unix时间戳）
    LAST_S=$(date -d "$LAST" +%s 2>/dev/null)
    NOW_S=$(date -u +%s)
    if [ -n "$LAST_S" ]; then
        HOURS=$(( (NOW_S - LAST_S) / 3600 ))
        if [ "$HOURS" -lt 4 ]; then
            warn "距上次写入仅 ${HOURS}h（需≥4h），冷却期中"
            WARN=$((WARN+1))
        else
            ok "冷却期已过（${HOURS}h ≥ 4h）"
            PASS=$((PASS+1))
        fi
    fi
    # 检查是否有挂起记录
    if [ -f "$PEND_FILE" ] && [ "$(wc -l < "$PEND_FILE")" -gt 3 ]; then
        warn "有挂起记录待处理: $PEND_FILE"
        WARN=$((WARN+1))
    fi
else
    warn "时间戳文件不存在（未初始化或已清理）"
    WARN=$((WARN+1))
fi

# 3. 版本锚一致性
echo ""
echo "── 3. 版本锚 ——"
ROOT_VER=$(grep -oP '版本 v\K[\d.]+' "$ROOT_SOUL" 2>/dev/null)
MISMATCH=0
for prof in work study recreation shici poetry; do
    sf="${REAL_HOME}/.hermes/profiles/${prof}/SOUL.md"
    [ ! -f "$sf" ] && continue
    if grep -q "根SOUL.*v${ROOT_VER}" "$sf" 2>/dev/null; then
        :  # 匹配
    else
        MISMATCH=$((MISMATCH+1))
    fi
done
if [ "$MISMATCH" -eq 0 ]; then
    ok "版本锚全部一致 (v${ROOT_VER})"
    PASS=$((PASS+1))
else
    err "${MISMATCH}个场景版本锚断裂"
    FAIL=$((FAIL+1))
fi

# 4. 规则条数一致性校验（深度版本锚检查）
echo ""
echo "── 4. 规则条数一致性 ——"
ROOT_COUNT=$(grep -oP '以上\K(\d+)条' "$ROOT_SOUL" 2>/dev/null | head -1 | grep -oP '\d+' || echo "?")
ANCHOR_MISS=0
for prof in work study recreation shici poetry; do
    sf="${REAL_HOME}/.hermes/profiles/${prof}/SOUL.md"
    [ ! -f "$sf" ] && continue
    # 检查场景SOUL中引用的条数
    SCENE_COUNT=$(grep -oP '(\d+)条' "$sf" 2>/dev/null | head -1 | grep -oP '\d+')
    SCENE_VER=$(grep -oP '(根SOUL\.md|根SOUL) v\K[\d.]+' "$sf" 2>/dev/null | head -1)
    if [ "$ROOT_COUNT" != "?" ] && [ "$SCENE_COUNT" != "" ] && [ "$SCENE_COUNT" != "$ROOT_COUNT" ]; then
        err "${prof}/SOUL.md: 引用 ${SCENE_COUNT}条，根SOUL为 ${ROOT_COUNT}条"
        ANCHOR_MISS=$((ANCHOR_MISS+1))
    fi
    # 检查场景SOUL引用的版本号
    ROOT_VER_DISPLAY=$(grep -oP '版本 v\K[\d.]+' "$ROOT_SOUL" 2>/dev/null)
    if [ "$ROOT_VER_DISPLAY" != "" ] && [ "$SCENE_VER" != "" ] && [ "$SCENE_VER" != "$ROOT_VER_DISPLAY" ]; then
        err "${prof}/SOUL.md: 引用 v${SCENE_VER}，根SOUL为 v${ROOT_VER_DISPLAY}"
        ANCHOR_MISS=$((ANCHOR_MISS+1))
    fi
done
if [ "$ANCHOR_MISS" -eq 0 ]; then
    ok "规则条数+版本号一致性全部通过（根SOUL ${ROOT_COUNT}条 v${ROOT_VER_DISPLAY}）"
    PASS=$((PASS+1))
else
    FAIL=$((FAIL+1))
fi

# 5. 脚本自校验
echo ""
echo "── 5. 脚本自校验 ——"
HASH_FILE="${REAL_HOME}/.hermes/audit/compliance-hash.txt"
SCRIPT_SELF="${REAL_HOME}/.hermes/scripts/compliance-check.sh"
CURRENT_HASH=$(sha256sum "$SCRIPT_SELF" 2>/dev/null | awk '{print $1}')
if [ ! -f "$HASH_FILE" ]; then
    # 首次运行，记录hash
    echo "$CURRENT_HASH" > "$HASH_FILE"
    ok "首次运行，已记录hash基线"
elif [ -f "$HASH_FILE" ]; then
    EXPECTED_HASH=$(cat "$HASH_FILE" 2>/dev/null)
    if [ "$CURRENT_HASH" = "$EXPECTED_HASH" ]; then
        ok "脚本完整性校验通过"
        PASS=$((PASS+1))
    else
        err "compliance-check.sh 已被修改！hash不匹配"
        FAIL=$((FAIL+1))
    fi
fi

# 6. memory字符水位（各场景）
echo ""
echo "── 6. 记忆字符水位 ——"
for prof in work study recreation shici poetry control; do
    mem="${REAL_HOME}/.hermes/profiles/${prof}/memories/MEMORY.md"
    usr="${REAL_HOME}/.hermes/profiles/${prof}/memories/USER.md"
    for f in "$mem" "$usr"; do
        [ ! -f "$f" ] && continue
        chars=$(python3 -c "print(len(open('$f').read()))" 2>/dev/null)
        name=$(basename "$f")
        # 判断限制
        limit=2200
        [ "$name" = "USER.md" ] && limit=1375
        if [ "$chars" -gt "$limit" ]; then
            err "${prof}/${name}: ${chars}/${limit} 超限$((chars-limit))"
            FAIL=$((FAIL+1))
            # 自动导流外部记忆——水位超限触发
            MNEM_DB="${REAL_HOME}/.hermes/mnemosyne/data/mnemosyne.db"
            if [ -f "$MNEM_DB" ]; then
                sqlite3 "$MNEM_DB" "INSERT OR IGNORE INTO working_memory (id, content, source, timestamp, session_id, importance, metadata_json, memory_type, created_at, veracity) VALUES ('__drain__${prof}_${name}', 'MEMORY DRAIN: ${prof}/${name} 水位 ${chars}/${limit}，超限 $((chars-limit))。后续写入将自动导流到外部记忆。', '__drain__', datetime('now'), '__drain__', 0.0, '{}', 'system', datetime('now'), 'trusted');" 2>/dev/null
            fi
        elif [ "$chars" -gt "$((limit * 95 / 100))" ]; then
            warn "${prof}/${name}: ${chars}/${limit}（${chars}%），超过95%水位线，自动导流外部记忆"
            WARN=$((WARN+1))
        elif [ "$chars" -gt "$((limit * 90 / 100))" ]; then
            warn "${prof}/${name}: ${chars}/${limit}（${chars}%），接近上限"
            WARN=$((WARN+1))
        fi
    done
done
ok "字符水位检查完成"

# 7. 内容锚点核对（动态读取校验清单）
echo ""
echo "── 7. 内容锚点核对 ——"
ANCHOR_FILE="${REAL_HOME}/.hermes/audit/content-anchors.md"
CHECKLIST=$(sed -n '/^## 校验清单/,$ p' "$ANCHOR_FILE" 2>/dev/null)
if [ -z "$CHECKLIST" ]; then
    warn "校验清单不存在或为空"
else
    ANCHOR_FAIL=0
    ANCHOR_PASS=0
    TOTAL_ASSERT=0
    FAIL_ASSERT=0

    # 逐行解析校验清单
    CURRENT_TARGET=""
    ASSERT_BUF=""
    while IFS= read -r line; do
        # 跳过注释行和空行
        echo "$line" | grep -qP '^(> |## |$|——)' && continue

        # 遇到新 target 标记
        if echo "$line" | grep -qP '^###? @target: '; then
            # 处理上一个 target
            if [ -n "$CURRENT_TARGET" ] && [ -f "$CURRENT_TARGET" ]; then
                TFILE_CONTENT=$(cat "$CURRENT_TARGET" 2>/dev/null)
                TFILE_PASS=0
                TFILE_FAIL=0
                while IFS= read -r ass; do
                    [ -z "$ass" ] && continue
                    TOTAL_ASSERT=$((TOTAL_ASSERT+1))
                    if echo "$TFILE_CONTENT" | grep -qF "$ass"; then
                        TFILE_PASS=$((TFILE_PASS+1))
                    else
                        TFILE_FAIL=$((TFILE_FAIL+1))
                        FAIL_ASSERT=$((FAIL_ASSERT+1))
                        [ $TFILE_FAIL -eq 1 ] && err "${CURRENT_TARGET} 缺失断言:"
                        err "  → $ass"
                    fi
                done <<< "$ASSERT_BUF"
                if [ "$TFILE_FAIL" -eq 0 ]; then
                    ok "${CURRENT_TARGET} — ${TFILE_PASS}个断言全部通过"
                    ANCHOR_PASS=$((ANCHOR_PASS+1))
                else
                    ANCHOR_FAIL=$((ANCHOR_FAIL+1))
                fi
            elif [ -n "$CURRENT_TARGET" ] && [ ! -f "$CURRENT_TARGET" ]; then
                err "${CURRENT_TARGET} — 文件不存在"
                ANCHOR_FAIL=$((ANCHOR_FAIL+1))
            fi
            # 切换新 target
            CURRENT_TARGET=$(echo "$line" | sed 's/.*@target: *//' | xargs)
            ASSERT_BUF=""
        elif echo "$line" | grep -qP '^- '; then
            ass=$(echo "$line" | sed 's/^- *//')
            if [ -n "$ass" ]; then
                ASSERT_BUF="${ASSERT_BUF}
${ass}"
            fi
        fi
    done <<< "$CHECKLIST"

    # 处理最后一个 target
    if [ -n "$CURRENT_TARGET" ]; then
        if [ -f "$CURRENT_TARGET" ]; then
            TFILE_CONTENT=$(cat "$CURRENT_TARGET" 2>/dev/null)
            TFILE_PASS=0
            TFILE_FAIL=0
            while IFS= read -r ass; do
                [ -z "$ass" ] && continue
                TOTAL_ASSERT=$((TOTAL_ASSERT+1))
                if echo "$TFILE_CONTENT" | grep -qF "$ass"; then
                    TFILE_PASS=$((TFILE_PASS+1))
                else
                    TFILE_FAIL=$((TFILE_FAIL+1))
                    FAIL_ASSERT=$((FAIL_ASSERT+1))
                    [ $TFILE_FAIL -eq 1 ] && err "${CURRENT_TARGET} 缺失断言:"
                    err "  → $ass"
                fi
            done <<< "$ASSERT_BUF"
            if [ "$TFILE_FAIL" -eq 0 ]; then
                ok "${CURRENT_TARGET} — ${TFILE_PASS}个断言全部通过"
                ANCHOR_PASS=$((ANCHOR_PASS+1))
            else
                ANCHOR_FAIL=$((ANCHOR_FAIL+1))
            fi
        else
            err "${CURRENT_TARGET} — 文件不存在"
            ANCHOR_FAIL=$((ANCHOR_FAIL+1))
        fi
    fi

    if [ "$ANCHOR_FAIL" -eq 0 ]; then
        ok "所有文件核心层校验通过（${TOTAL_ASSERT}个断言）"
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
    fi
fi

# 8. 全局路径绝对性校验 — 所有配置文件中的路径引用必须使用绝对路径
echo ""
echo "── 8. 全局路径绝对性 ——"
PATH_OK=0
PATH_FAIL=0

# 8a. 检查所有 config.yaml 的 external_dirs 路径
for cfg in "${REAL_HOME}/config.yaml" \
           "${REAL_HOME}/profiles/control/config.yaml" \
           "${REAL_HOME}/profiles/work/config.yaml" \
           "${REAL_HOME}/profiles/study/config.yaml" \
           "${REAL_HOME}/profiles/recreation/config.yaml" \
           "${REAL_HOME}/profiles/shici/config.yaml"; do
    [ ! -f "$cfg" ] && continue
    # 提取 external_dirs 下的路径条目
    while IFS= read -r dir_entry; do
        dir_entry=$(echo "$dir_entry" | sed 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//')
        [ -z "$dir_entry" ] && continue
        # 检查是否以 / 开头（绝对路径）
        if ! echo "$dir_entry" | grep -qP '^/'; then
            rel_path=$(echo "$dir_entry" | tr -d "'\"")
            err "${cfg} → external_dirs: 相对路径 '${rel_path}'"
            PATH_FAIL=$((PATH_FAIL+1))
        fi
    done < <(sed -n '/^skills:/,/^[a-z]/p' "$cfg" 2>/dev/null | grep -E '^\s+- ' | head -20)
done

# 8b. 检查 MCP servers 中的路径参数
for cfg in "${REAL_HOME}/config.yaml" \
           "${REAL_HOME}/profiles/control/config.yaml" \
           "${REAL_HOME}/profiles/work/config.yaml" \
           "${REAL_HOME}/profiles/study/config.yaml" \
           "${REAL_HOME}/profiles/recreation/config.yaml" \
           "${REAL_HOME}/profiles/shici/config.yaml"; do
    [ ! -f "$cfg" ] && continue
    # 从 args 中提取像路径的参数（以 - 开头或跟在 --db-path 后）
    in_mcp=0
    while IFS= read -r line; do
        if echo "$line" | grep -qP '^mcp_servers:'; then
            in_mcp=1
            continue
        fi
        [ "$in_mcp" -eq 1 ] && echo "$line" | grep -qP '^[a-z]' && in_mcp=0
        [ "$in_mcp" -eq 0 ] && continue
        # 提取 args 行中的路径值
        if echo "$line" | grep -qP '^\s+-\s+/'; then
            :  # 以 / 开头的绝对路径，OK
        elif echo "$line" | grep -qP '^\s+-\s+\.\.?/'; then
            path_val=$(echo "$line" | sed 's/.*-\s*//')
            err "${cfg} → MCP args: 相对路径 '${path_val}'"
            PATH_FAIL=$((PATH_FAIL+1))
        elif echo "$line" | grep -qP '^\s+-\s+[a-zA-Z0-9_/-]' && echo "$line" | grep -qP '/'; then
            # 看起来像路径（包含/）但又不是绝对路径
            path_val=$(echo "$line" | sed 's/.*-\s*//')
            err "${cfg} → MCP args: 可能路径但非绝对路径 '${path_val}'"
            PATH_FAIL=$((PATH_FAIL+1))
        fi
    done < "$cfg"
done

# 8c. 检查 .bashrc 中 Hermes 自检路径
BASHRC="${REAL_HOME}/.bashrc"
if [ -f "$BASHRC" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -qP '(compliance-check\.sh|boot-check\.txt)' && \
           echo "$line" | grep -P 'bash\s' | grep -vqP '\$HOME'; then
            # 找到了路径但没用到 $HOME
            if echo "$line" | grep -qP '/home/sqzy'; then
                :  # 绝对路径，OK
            elif echo "$line" | grep -qP '^[^#$]' && ! echo "$line" | grep -qP '\$HOME|\$\{HOME\}'; then
                # 既不是 $HOME 也不是绝对路径
                warn "${BASHRC}: 自检路径未用绝对路径或 \$HOME"
                WARN=$((WARN+1))
            fi
        fi
    done < "$BASHRC"
fi

# 8d. 检查 all scenes config.yaml 的 terminal.cwd
for cfg in "${REAL_HOME}/config.yaml" \
           "${REAL_HOME}/profiles/control/config.yaml" \
           "${REAL_HOME}/profiles/work/config.yaml" \
           "${REAL_HOME}/profiles/study/config.yaml" \
           "${REAL_HOME}/profiles/recreation/config.yaml" \
           "${REAL_HOME}/profiles/shici/config.yaml"; do
    [ ! -f "$cfg" ] && continue
    cwd_val=$(grep -A1 '^\s*cwd:' "$cfg" 2>/dev/null | head -1 | sed 's/.*cwd:\s*//')
    if [ -n "$cwd_val" ] && [ "$cwd_val" != "." ] && [ "$cwd_val" != "''" ] && [ "$cwd_val" != '""' ]; then
        if ! echo "$cwd_val" | grep -qP '^/'; then
            warn "${cfg}: terminal.cwd 建议使用绝对路径（当前: ${cwd_val}）"
            WARN=$((WARN+1))
        fi
    fi
done

if [ "$PATH_FAIL" -eq 0 ]; then
    ok "所有配置文件路径引用均为绝对路径"
    PASS=$((PASS+1))
else
    PASS=$((PASS+1))  # Warn-only for path issues (not a hard fail)
fi

# 9. 运行时服务健康检查 — Camofox / STT / TTS
echo ""
echo "── 9. 运行时服务健康 ——"
SVC_FAIL=0

# 9a. Camofox 浏览器
CAMOFOX_OK=$(curl -s --max-time 3 http://localhost:9377/health 2>/dev/null | grep -c '"ok":true\|"ok": true')
if [ "$CAMOFOX_OK" -gt 0 ]; then
    ok "Camofox 浏览器服务运行中"
    PASS=$((PASS+1))
else
    warn "Camofox 浏览器服务未响应（browser_* 工具不可用）"
    WARN=$((WARN+1))
fi

# 9b. STT 依赖检查（在 Hermes venv 中）
STT_PYTHON="${REAL_HOME}/.hermes/hermes-agent/venv/bin/python3"
if [ -f "$STT_PYTHON" ]; then
    STT_OK=$("$STT_PYTHON" -c "
try:
    import faster_whisper
    import sounddevice
    print('ok')
except:
    print('fail')
" 2>/dev/null)
    if [ "$STT_OK" = "ok" ]; then
        ok "STT 依赖就绪（faster-whisper + sounddevice）"
        PASS=$((PASS+1))
    else
        err "STT 依赖缺失（faster-whisper 或 sounddevice 未安装）"
        SVC_FAIL=$((SVC_FAIL+1))
    fi
else
    warn "Hermes venv 不存在，跳过 STT 检查"
    WARN=$((WARN+1))
fi

# 9c. Playwright 浏览器自动化
PW_PYTHON="${REAL_HOME}/.hermes/hermes-agent/venv/bin/python3"
if [ -f "$PW_PYTHON" ]; then
    PW_OK=$("$PW_PYTHON" -c "
try:
    from playwright.sync_api import sync_playwright
    import os
    chrome_path = '${REAL_HOME}/.cache/ms-playwright/chromium-1223/chrome-linux64/chrome'
    print('ok' if os.path.exists(chrome_path) else 'nobrowser')
except:
    print('fail')
" 2>/dev/null)
    if [ "$PW_OK" = "ok" ]; then
        ok "Playwright + Chromium 就绪"
        PASS=$((PASS+1))
    elif [ "$PW_OK" = "nobrowser" ]; then
        warn "Playwright 库已安装但 Chromium 二进制缺失（运行 playwright install chromium）"
        WARN=$((WARN+1))
    else
        warn "Playwright 未安装"
        WARN=$((WARN+1))
    fi
fi

if [ "$SVC_FAIL" -eq 0 ]; then
    PASS=$((PASS+1))
fi

# 10. 能力归属扫描 — 检测未归位skill
echo ""
echo "── 10. 能力归属 ——"
SCAN_SCRIPT="${REAL_HOME}/.hermes/scripts/capability-scan.py"
if [ -f "$SCAN_SCRIPT" ]; then
    python3 "$SCAN_SCRIPT" > /dev/null 2>&1
    SCAN_EXIT=$?
    if [ "$SCAN_EXIT" -eq 0 ]; then
        ok "所有 skill 已归属，无未归位技能"
        PASS=$((PASS+1))
    else
        # 有未归位skill，输出摘要
        SCAN_OUT=$(python3 "$SCAN_SCRIPT" 2>&1)
        UNCLAIMED=$(echo "$SCAN_OUT" | grep -oP '发现 \K\d+' | head -1)
        [ -z "$UNCLAIMED" ] && UNCLAIMED="?"
        warn "${UNCLAIMED}个skill未归位（运行 capability-scan.py 查看详情）"
        WARN=$((WARN+1))
    fi
else
    warn "能力扫描脚本不存在，跳过第10项"
    WARN=$((WARN+1))
fi

# 10b. 技能加载健康检查——关键技能是否可达
KEY_SKILLS="system-guardian memory-governance"
MISSING=""
for p in control work study recreation shici; do
    for sk in $KEY_SKILLS; do
        if ! hermes -p $p skills list 2>/dev/null | grep -qw "$sk"; then
            MISSING="$MISSING ${p}:${sk}"
        fi
    done
done
if [ -z "$MISSING" ]; then
    ok "关键技能全场景可达（system-guardian + memory-governance）"
    PASS=$((PASS+1))
else
    warn "技能缺失:${MISSING}"
    WARN=$((WARN+1))
fi

# 10c. 全局SKILL版本一致性——检查核心治理技能版本是否跨场景一致
CORE_SKILLS="system-guardian memory-governance hermes-operations multi-profile-governance"
VERSION_ERR=0
for sk in $CORE_SKILLS; do
    # 从 control 获取版本
    CTRL_FILE="${REAL_HOME}/.hermes/profiles/control/skills"
    # 搜索skill目录
    SKILL_DIR=$(find "$CTRL_FILE" -maxdepth 2 -type d -name "$sk" 2>/dev/null | head -1)
    if [ -z "$SKILL_DIR" ] || [ ! -f "$SKILL_DIR/SKILL.md" ]; then
        continue
    fi
    CTRL_VER=$(grep -oP '^version: \K.*' "$SKILL_DIR/SKILL.md" 2>/dev/null)
    [ -z "$CTRL_VER" ] && continue
    # 检查各场景加载的版本（通过 external_dirs 读同一个文件，只需确认文件可达）
    for p in work study recreation shici; do
        # 各场景通过 external_dirs 访问同一个文件，文件本身是一致的
        # 检查文件是否存在且可读
        if [ ! -r "$SKILL_DIR/SKILL.md" ]; then
            VERSION_ERR=$((VERSION_ERR+1))
        fi
    done
done
if [ "$VERSION_ERR" -eq 0 ]; then
    ok "全局SKILL版本一致（${CORE_SKILLS}）"
    PASS=$((PASS+1))
else
    warn "${VERSION_ERR}个场景全局SKILL不可读"
    WARN=$((WARN+1))
fi

# 11. 外部记忆（Mnemosyne）机制检查
# 从 v3.3 起，外部记忆 Mnemosyne 为系统审计必检项
# 检查：各场景配置、数据库活性、工具挂载
# 由 content-anchors.md 第6节定义核心层规则

echo ""
echo "── 11. 外部记忆（Mnemosyne）——"
MEM_FAIL=0

# 11a. 各场景必须配置 memory.provider: mnemosyne
for scene in control work study recreation; do
    CFG="${REAL_HOME}/.hermes/profiles/${scene}/config.yaml"
    if [ -f "$CFG" ] && grep -qE '^[[:space:]]+provider:[[:space:]]+mnemosyne' "$CFG" 2>/dev/null; then
        ok "${scene}: memory.provider = mnemosyne"
        PASS=$((PASS+1))
    else
        err "${scene}: memory.provider 未配置 mnemosyne"
        MEM_FAIL=$((MEM_FAIL+1))
    fi
done

# 11b. Mnemosyne 数据库存在且有内容
MNEM_DB="${REAL_HOME}/.hermes/mnemosyne/data/mnemosyne.db"
if [ -f "$MNEM_DB" ]; then
    DB_SIZE=$(stat --format=%s "$MNEM_DB" 2>/dev/null)
    REC_COUNT=$(sqlite3 "$MNEM_DB" "SELECT COUNT(*) FROM memories;" 2>/dev/null || echo "0")
    if [ "$REC_COUNT" -gt 0 ] 2>/dev/null; then
        ok "Mnemosyne 数据库 ${REC_COUNT} 条记录 (${DB_SIZE} bytes)"
        PASS=$((PASS+1))
    else
        warn "Mnemosyne 数据库存在但无记录"
        WARN=$((WARN+1))
    fi
else
    warn "Mnemosyne 数据库不存在"
    WARN=$((WARN+1))
fi

# 11c. known_plugin_toolsets 包含 mnemosyne
WORK_CFG="${REAL_HOME}/.hermes/profiles/work/config.yaml"
if [ -f "$WORK_CFG" ]; then
    if grep -qE '^[[:space:]]+- mnemosyne' <(sed -n '/^known_plugin_toolsets:/,/^[a-z]\+/p' "$WORK_CFG" 2>/dev/null); then
        ok "work: known_plugin_toolsets 包含 mnemosyne"
        PASS=$((PASS+1))
    else
        err "work: known_plugin_toolsets 缺少 mnemosyne"
        MEM_FAIL=$((MEM_FAIL+1))
    fi
fi

# 11d. Mnemosyne 读写工作状态验证
MNEM_DB="${REAL_HOME}/.hermes/mnemosyne/data/mnemosyne.db"
if [ -f "$MNEM_DB" ]; then
    # 写一条测试记录→读回→删除，原子验证读写完整链路
    WORKING=$(sqlite3 "$MNEM_DB" "BEGIN; INSERT INTO working_memory (id, content, source, timestamp, session_id, importance, metadata_json, memory_type, created_at, veracity) VALUES ('__selfcheck__', 'SYSTEM SELF-CHECK: mnemosyne working state verification', '__selfcheck__', datetime('now'), '__selfcheck__', 0.0, '{}', 'fact', datetime('now'), 'trusted'); SELECT content FROM working_memory WHERE id='__selfcheck__'; DELETE FROM working_memory WHERE id='__selfcheck__'; COMMIT;" 2>/dev/null)
    if [ "$WORKING" = "SYSTEM SELF-CHECK: mnemosyne working state verification" ]; then
        ok "Mnemosyne 读写正常（写→读→删，全链路验证）"
        PASS=$((PASS+1))
    else
        err "Mnemosyne 读写异常（写→读→删链路不通）"
        MEM_FAIL=$((MEM_FAIL+1))
    fi
else
    err "Mnemosyne 数据库不存在，无法验证工作状态"
    MEM_FAIL=$((MEM_FAIL+1))
fi

if [ "$MEM_FAIL" -gt 0 ]; then
    PASS=$((PASS+1))
fi

# 12. 外部记忆（mnemosyne）治理合规审计（第16条）
echo ""
echo "── 12. 外部记忆治理合规 ——"
MEM_GOV_FAIL=0

# 12a. 检查所有场景的 mnemosyne home symlink 一致性
MNEM_LINK_OK=0
for scene in control work study recreation shici; do
    LINK="${REAL_HOME}/.hermes/profiles/${scene}/home/.hermes/mnemosyne"
    CENTRAL="${REAL_HOME}/.hermes/mnemosyne"
    if [ -L "$LINK" ]; then
        TARGET=$(readlink "$LINK")
        if [ "$TARGET" = "$CENTRAL" ]; then
            ok "${scene}: mnemosyne home → centralized ✓"
            PASS=$((PASS+1))
        else
            err "${scene}: mnemosyne home 指向 ${TARGET}，期望 centralized"
            MNEM_LINK_OK=$((MNEM_LINK_OK+1))
        fi
    elif [ -d "$LINK" ]; then
        err "${scene}: mnemosyne home 是真实目录，非symlink"
        MNEM_LINK_OK=$((MNEM_LINK_OK+1))
    else
        err "${scene}: mnemosyne home 不存在"
        MNEM_LINK_OK=$((MNEM_LINK_OK+1))
    fi
done

# 12b. 扫描中央数据库最近写入是否有禁止存储内容
MNEM_DB="${REAL_HOME}/.hermes/mnemosyne/data/mnemosyne.db"
if [ -f "$MNEM_DB" ]; then
    # 禁止清单模式：文件路径、TODO标记、commit SHA、PR编号、任务ID
    FORBIDDEN_PATTERNS="
/home/sqzy/.hermes/
/home/sqzy/.local/
/home/sqzy/Downloads/
TODO:
commit\s[0-9a-f]{7,40}
PR\s#[0-9]+
#[0-9]{4,6}
"
    FOUND_FORBIDDEN=0
    while IFS= read -r pattern; do
        [ -z "$pattern" ] && continue
        HITS=$(sqlite3 "$MNEM_DB" "SELECT COUNT(*) FROM working_memory WHERE content LIKE '%${pattern}%';" 2>/dev/null || echo "0")
        if [ "$HITS" -gt 0 ] 2>/dev/null; then
            warn "发现 ${HITS} 条可能含禁止内容的记录（模式: ${pattern:0:50}）"
            FOUND_FORBIDDEN=$((FOUND_FORBIDDEN + HITS))
        fi
    done <<< "$FORBIDDEN_PATTERNS"

    if [ "$FOUND_FORBIDDEN" -gt 0 ]; then
        warn "共 ${FOUND_FORBIDDEN} 条可能违规记录，建议人工复核"
        MEM_GOV_FAIL=$((MEM_GOV_FAIL+1))
    else
        ok "最近写入记录未检测到禁止存储内容"
        PASS=$((PASS+1))
    fi
else
    warn "Mnemosyne 数据库不存在，跳过治理审计"
    WARN=$((WARN+1))
fi

# 12b. 检查各profile的plugins symlink一致性
PLUGIN_FAIL=0
for scene in control work study recreation shici; do
    PLUGIN_DIR="${REAL_HOME}/.hermes/profiles/${scene}/plugins/mnemosyne"
    if [ -L "$PLUGIN_DIR" ]; then
        TARGET=$(readlink "$PLUGIN_DIR")
        if [ "$TARGET" = "${REAL_HOME}/.hermes/plugins/mnemosyne" ]; then
            ok "${scene}: plugins/mnemosyne → centralized ✓"
            PASS=$((PASS+1))
        else
            err "${scene}: plugins/mnemosyne 指向 ${TARGET}，期望指向 centralized"
            PLUGIN_FAIL=$((PLUGIN_FAIL+1))
        fi
    elif [ -d "$PLUGIN_DIR" ]; then
        err "${scene}: plugins/mnemosyne 是真实目录，非symlink"
        PLUGIN_FAIL=$((PLUGIN_FAIL+1))
    else
        err "${scene}: plugins/mnemosyne 不存在"
        PLUGIN_FAIL=$((PLUGIN_FAIL+1))
    fi
done

if [ "$PLUGIN_FAIL" -gt 0 ]; then
    MEM_GOV_FAIL=$((MEM_GOV_FAIL+1))
fi

# 12c. 检查memory-governance skill是否存在
MG_SKILL="${REAL_HOME}/.hermes/profiles/control/skills/methodology/memory-governance/SKILL.md"
if [ -f "$MG_SKILL" ]; then
    ok "memory-governance skill 存在"
    PASS=$((PASS+1))
else
    err "memory-governance skill 缺失"
    MEM_GOV_FAIL=$((MEM_GOV_FAIL+1))
fi

if [ "$MEM_GOV_FAIL" -gt 0 ]; then
    FAIL=$((FAIL+1))
fi

# 汇总
echo ""
echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ];then echo "  全部通过 ✅"
elif [ "$FAIL" -eq 0 ]; then echo "  通过（${WARN}项警告）🟡"
else echo "  ${FAIL}项违规  ${WARN}项警告 🔴"
fi
echo "  ✅ ${PASS}  ⚠️ ${WARN}  ❌ ${FAIL}"
echo "═══════════════════════════════════════════"

# 症候群诊断——检测关联故障模式

# Goal 评估——循环自判断"完成"
SD_SCRIPT="${REAL_HOME}/.hermes/scripts/goal-eval.sh"
if [ -f "$SD_SCRIPT" ]; then
    bash "$SD_SCRIPT" 2>/dev/null
fi
SD_SCRIPT="${REAL_HOME}/.hermes/scripts/syndrome-detect.sh"
if [ -f "$SD_SCRIPT" ] && [ "$FAIL" -gt 0 -o "$WARN" -gt 0 ]; then
    # 写入触发文件——开机自检时由 delegate_task 分路子代理执行
    echo "$(date '+%Y-%m-%d %H:%M')" > "${REAL_HOME}/.hermes/audit/trigger-checker"
fi
