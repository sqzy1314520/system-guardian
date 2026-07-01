# 五维能力自检与 Token 优化

## 实操提示：五维能力自检 + Token 优化

每次全检时按以下顺序检查，避免路径陷阱：

1. 听 — 用 venv 的 Python 检查 STT
2. 看 — curl 检查 Camofox 浏览器服务
3. 说 — 直接调用 text_to_speech
4. 读 — 调用 web_search 和 web_extract
5. 创 — 写作技能直接可用

**Token 优化：** 各场景默认加载全部 31 个工具集，但 control 管理场景不需要 browser/vision/tts 等。通过 `enabled_toolsets` 限定到 11 个核心工具集可省 64% 工具 schema token。详见 `references/token-optimization-toolset-trimming.md`。

<!-- 版本对比已迁出到 GitHub README -->
