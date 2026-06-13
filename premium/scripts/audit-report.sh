#!/bin/bash
# system-guardian-audit.sh · 审计报告生成脚本

echo "═══════════════════════════════════════"
echo "  System Guardian 审计报告"
echo "  生成时间: $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════"
echo ""

# L1 纪律巡检
echo "── L1 纪律巡检 ──"
[ -f ~/.hermes/SOUL.md ] && echo "  ✅ 宪法存在" || echo "  ❌ 宪法缺失"
[ -f ~/.hermes/scripts/compliance-check.sh ] && echo "  ✅ 自检脚本存在" || echo "  ❌ 自检脚本缺失"
grep -q "mode: manual" ~/.hermes/config.yaml 2>/dev/null && echo "  ✅ 审批已开启" || echo "  ❌ 审批未配置"

echo ""
echo "── L2 架构探针 ──"
SCENE_COUNT=$(find ~/.hermes/profiles -name "SOUL.md" -maxdepth 2 2>/dev/null | wc -l)
echo "  🔍 场景数量: $SCENE_COUNT（含control）"

CRON_COUNT=$(hermes cron list 2>/dev/null | grep -c "job_id" || echo 0)
echo "  🔍 Cron job数: $CRON_COUNT"

echo ""
echo "═══════════════════════════════════════"
echo "  审计完成"
echo "═══════════════════════════════════════"
