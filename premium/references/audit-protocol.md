# 审计模式 · 三幕法输出 + 7维度探针

## 7维度探针

| 维度 | 检查内容 | 验证方法 |
|------|---------|---------|
| 1. 约束管道 | approvals.mode、Tirith、.bashrc自检、跨profile守卫 | grep config.yaml + 检查守卫实际拦截 |
| 2. 控制治理 | control治理权声明、版本锚一致性 | 各场景SOUL.md 版本号比对 |
| 3. 监督检查 | audit目录完整性、HEARTBEAT新鲜度、agent.log存在性 | ls audit/ + 计算HEARTBEAT时效 |
| 4. 协调路由 | route_manager.sh、external_dirs配置、场景边界 | 检查文件存在性 + config.yaml |
| 5. 调度执行 | cron job 列表、last_status、memory-pending.md | cronjob list + cat 暂存文件 |
| 6. 基础完整性 | 根SOUL关键锚点、content-anchors断言 | compliance-check.sh 自动验证 |
| 7. 外部记忆 | 场景 memory.provider、数据库活性、工具挂载 | compliance-check 第11项 + sqlite3 count |

## 输出格式（三幕法）

### 第一幕：肯定——做对了什么
列举系统中正确的管道、治理、监督、完整性成果。

### 第二幕：否定——发现的裂缝（严重度分级）

| 等级 | 含义 | 响应时间 |
|------|------|---------|
| P0 | 系统功能受阻 | 立即修复 |
| P1 | 长期运行隐患 | 当天修复 |
| P2 | 配置/风格问题 | 按需修复 |
| P3 | 信息残留 | 顺手清理 |

### 第三幕：再肯定——修复方向（优先级建议）

表格列示：裂缝 → 修复动作 → 优先级 → 预估时长
