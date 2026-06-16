# Changelog

## v1.16.0 (2026-06-16)
- path-standards.md: 新增「标准依据」节，引用 Hermes Issue #892/#8669 确认 `expanduser("~/.hermes")` 为社区标准 fallback
- $HOME 重写陷阱 pitfall: 统一到社区标准模式（`os.environ.get("HERMES_HOME", expanduser("~/.hermes"))` / `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"`）
- 新增系统性扫描方法论: 四层扫描 + 修复优先级 + 批量修复验证流程
- compliance-check: 新增第13项「路径写法合规」自动扫描

## v1.1.0 (2026-06-16)

- 自查模式重新定义：基础3项 → 6维度全功能健康检查（外部记忆/定时任务/五维能力/渠道通断/技能加载/纪律合规）
- 审计模式扩展：6维度 → 7维度，新增外部记忆治理维度
- 新增读写验证：compliance-check 第11项内置 mnemosyne 写→读→删原子操作
- premium 完整版同步更新：12项自查 + 7维度审计
- 公开版 README 与 SKILL.md 描述对齐
- 新增治理边界声明：管什么/不管什么

## v1.2.0 (2026-06-16)

- 分层重构：Free/Premium 拆分 → L1向导版/L2稳定版/L3诊断版
- 认知分层：按「解决什么问题」切割，而非「多少功能」
- 描述全部改用层级语言，premium 改称 L3 诊断版

## v1.0.0 (2026-06-13)

- 构建模式：三问题自动搭建
- 自查模式：基础3项（公开版）/ 完整7项（赞助版）
- 审计模式：6维度探针 + 三幕法报告（赞助版）
- 能力模式：看听读说创五维展示
- 一键脚本：compliance-check.sh / audit-report.sh（赞助版）
