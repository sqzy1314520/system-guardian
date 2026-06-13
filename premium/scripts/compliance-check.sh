#!/bin/bash
# system-guardian-check.sh · 一键自检脚本
# 终端直接运行，无需加载 skill

HOME_DIR="${HOME}"
PASS=0; FAIL=0
ok() { echo -e "✅ $1"; PASS=$((PASS+1)); }
err() { echo -e "❌ $1"; FAIL=$((FAIL+1)); }

echo "═══════════════════════════════════════"
echo "  System Guardian 自检"
echo "═══════════════════════════════════════"
echo ""

# 1. 身份合规
if [ -f "$HOME_DIR/.hermes/SOUL.md" ]; then ok "宪法文件存在"; else err "宪法文件缺失"; fi

# 2. 审批配置
if grep -q "mode: manual" "$HOME_DIR/.hermes/config.yaml" 2>/dev/null || grep -q "mode: manual" "$HOME_DIR/.hermes/profiles/"*/config.yaml 2>/dev/null; then ok "审批已开启"; else err "审批未配置"; fi

# 3. 核心文件
if [ -f "$HOME_DIR/.hermes/scripts/compliance-check.sh" ]; then ok "自检脚本存在"; else err "自检脚本缺失"; fi
if [ -f "$HOME_DIR/.hermes/audit/content-anchors.md" ]; then ok "内容保险存在"; else err "内容保险缺失"; fi

# 4. 记忆水位
if [ -f "$HOME_DIR/.hermes/memories/MEMORY.md" ]; then
    size=$(wc -c < "$HOME_DIR/.hermes/memories/MEMORY.md" 2>/dev/null)
    if [ "$size" -lt 2200 ]; then ok "记忆水位正常"; else err "MEMORY.md 接近上限"; fi
else ok "无内置记忆"; fi

# 5. 场景完整性
SCENE_COUNT=0
for scene in work study recreation shici; do
    if [ -f "$HOME_DIR/.hermes/profiles/$scene/SOUL.md" ]; then SCENE_COUNT=$((SCENE_COUNT+1)); fi
done
ok "场景数: $SCENE_COUNT"

echo ""
echo "═══════════════════════════════════════"
echo "  结果: ✅ $PASS  ❌ $FAIL"
echo "═══════════════════════════════════════"
