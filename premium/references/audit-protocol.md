# 审计模式 · 6维度探针

## 6维度

### ① 约束管道
检查 approvals.mode / tirith_enabled / .bashrc触发 / 跨profile守卫。

### ② 控制治理
检查 control 治理权声明 / 版本锚一致性。

### ③ 监督检查
检查审计日志 / 心跳 / cron job 状态。

### ④ 协调路由
检查 route_manager / external_dirs 配置。

### ⑤ 调度执行
检查各profile cron job 的 last_status 和 next_run。

### ⑥ 基础完整性
检查根SOUL 7个关键锚点（第3条/第4条/第5条/冲突裁决/边界/治理权/版本声明）。

## 三幕法报告

```
L1 纪律巡检  ✅ N  ⚠️ N  ❌ N
L2 架构探针  ✅ N  ⚠️ N  ❌ N

第一幕 · 肯定——做对了什么
第二幕 · 否定——发现的裂缝（严重度P0/P1/P2）
第三幕 · 再肯定——修复方向
```
