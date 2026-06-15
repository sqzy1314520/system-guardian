#!/usr/bin/env python3
"""Generate terminal screenshot for system-guardian README."""
from PIL import Image, ImageDraw, ImageFont
import os

W, H = 960, 680
BG = (18, 18, 18)
GREEN = (0, 200, 100)
WHITE = (220, 220, 220)
YELLOW = (220, 180, 60)
GRAY = (100, 100, 100)
RED = (220, 60, 60)
CYAN = (80, 200, 220)

# Try to get a monospace font
font_path = None
for p in [
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
    "/usr/share/fonts/truetype/ubuntu/UbuntuMono-R.ttf",
    "/usr/share/fonts/TTF/DejaVuSansMono.ttf",
    "/usr/share/fonts/noto/NotoSansMono-Regular.ttf",
]:
    if os.path.exists(p):
        font_path = p
        break

if not font_path:
    font = ImageFont.load_default()
else:
    font = ImageFont.truetype(font_path, 18)

img = Image.new("RGB", (W, H), BG)
draw = ImageDraw.Draw(img)

def text(x, y, txt, color=WHITE, font=font):
    draw.text((x, y), txt, fill=color, font=font)

# Title bar
text(20, 15, "sqzy@LAPTOP-ROTFFHRE:~$ bash compliance-check.sh", GREEN)

# Header
text(20, 52, "═" * 68, GRAY)
text(20, 52, "  执行纪律巡检 · 2026-06-15 17:19", CYAN)
text(20, 74, "═" * 68, GRAY)

# Section 1
text(20, 100, "── 1. 身份合规 ──", WHITE)
text(200, 100, "  ✅ 根SOUL身份正确: 小智", GREEN)
text(200, 122, "  ✅ 各场景无身份冲突声明", GREEN)

# Section 2
text(20, 152, "── 2. 记忆写入冷却期 ──", WHITE)
text(280, 152, "  ✅ 冷却期已过（57h ≥ 4h）", GREEN)

# Section 3
text(20, 180, "── 3. 版本锚 ──", WHITE)
text(220, 180, "  ✅ 版本锚全部一致 (v3.3)", GREEN)

# Section 4
text(20, 208, "── 4. 规则条数一致性 ──", WHITE)
text(250, 208, "  ✅ 15条 v3.3 全部通过", GREEN)

# Section 5
text(20, 236, "── 5. 脚本自校验 ──", WHITE)
text(240, 236, "  ✅ 脚本完整性校验通过", GREEN)

# Section 6
text(20, 272, "── 6. 记忆字符水位 ──", WHITE)
text(240, 272, "  ⚠️ recreation/MEMORY.md: 2062/2200，接近上限", YELLOW)
text(240, 294, "  ✅ 字符水位检查完成", GREEN)

# Section 7
text(20, 324, "── 7. 内容锚点核对 ──", WHITE)
text(240, 324, "  ✅ 7份核心文件，64个断言全部通过", GREEN)

# Section 8
text(20, 360, "── 8. 全局路径绝对性 ──", WHITE)
text(260, 360, "  ✅ 所有路径均为绝对路径", GREEN)

# Section 9
text(20, 396, "── 9. 运行时服务健康 ──", WHITE)
text(260, 396, "  ⚠️ Camofox 浏览器服务未响应", YELLOW)
text(260, 418, "  ✅ STT / Playwright / Chromium 就绪", GREEN)

# Section 10
text(20, 448, "── 10. 能力归属 ──", WHITE)
text(240, 448, "  ✅ 所有 skill 已归属，无未归位技能", GREEN)

# Footer
text(20, 490, "═" * 68, GRAY)
text(20, 490, "  通过（3项警告）🟡  ✅ 11  ⚠️ 3  ❌ 0", CYAN)
text(20, 515, "═" * 68, GRAY)

# Blinking cursor
draw.rectangle([200, 550, 208, 568], fill=GREEN)

# Bottom bar
text(20, 590, "System Guardian v1.0  |  10 checks in 0.3s  |  hermes skills install ...", GRAY)

output_path = "/tmp/system-guardian/screenshot-selfcheck.png"
img.save(output_path)
print(f"Saved to {output_path}")
print(f"Size: {img.size}")
