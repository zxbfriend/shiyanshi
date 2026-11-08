# M09-011 DEVICE SAVE_ONLY 设计裁决表（停止归档）

- **裁决日期**：2026-10-02
- **基线**：`origin/cloud = HEAD = 69167386`（ahead/behind = 0/0）
- **任务性质**：文档归档，非开发任务。本轮只新增本文件，不改任何 Java / XML / JSON / skeleton / 审计登记 / 菜单 / 权限种子 / 前端 / Nacos / 网关。
- **裁决人**：用户（本轮明确"停止、不开发、不 wired"）
- **依据锚点**：`docs/详细设计/09-告警与通知管理/页面与接口契约.md:163 (G01)`、`docs/详细设计/09-告警与通知管理/告警配置与审批生效契约.md:41 (§4)`、`docs/开发基线/01-完整建表.sql:3754-3790 (alarm_online_config)`、`AlarmOnlineConfigV2Controller.java:42-48`、`AlarmOnlineConfigApplicationApplicationServiceImpl.java:188-191`、`AlarmOnlineConfigMapper.java` / `AlarmOnlineConfigMapper.xml`、`ManagementOperation.java:448`、`ManagementOperationTest.java:131`、`skeleton-m09.json:2080`

---

## 1. 总判定

- **M09-011 = NEEDS_DESIGN_REGISTRATION / KEEP_501。**
- **不允许 `wired:true`。**
- **不允许编码开发。**
- **不允许添加 `M09_011` operationCode**（`ManagementOperation` 保持 169，登记数不动）。
- **不允许修改 `AuditPolicyRegistry`。**
- **不允许修改 `AlarmConfigRevisionService` / 新增 `KIND_ONLINE`**（其 javadoc"仅服务 005/009/015"不改）。
- **不允许修改 `skeleton-m09.json`**（011 的 `wired` 字段保持缺失）。
- 结论：维持现状（Controller 仅只读接线；保存侧继续显式 501），等待后续设计解锁条件冻结后再评估。

---

## 2. 已核实事实（静态核对，代码/契约/DDL 证据）

1. **应用服务仍抛 501**：`AlarmOnlineConfigApplicationApplicationServiceImpl.saveOnlineConfig`（:188-191）显式 `throw new SkeletonNotImplementedException("M09-011")`。
2. **Controller 缺守卫注解**：`AlarmOnlineConfigV2Controller.saveOnlineConfig`（:42-48）仅 `@RequiresPermissions("alarm:onlineConfig:edit")`，**无 `@ManagementGuardedWrite` / `WriteMeta`**；仅只读 `getOnlineConfig`（M09-010）标了 `@CurrentManagementRevision`。
3. **Mapper 无写链路**：`AlarmOnlineConfigMapper` + `AlarmOnlineConfigMapper.xml` 仅有只读投影 `selectOnlineRowsV2`，**无任何 INSERT/UPDATE/CAS 写语句**；无 operationCode / 审计策略登记。
4. **DDL 层 SAVE_ONLY 不需要 logic_profile_ref，但不足以支撑开发**：`alarm_online_config` 的 `ck_m09_close_online_mode` 仅在 `evaluation_state='VERIFIED'` 时强制 `logic_profile_ref IS NOT NULL`；`SAVE_ONLY` 无此约束；`ck_m09_close_online_scope` 令 `culture_id IS NULL ⟺ DEVICE`。因此 DEVICE+SAVE_ONLY 在**表结构上可独立成立**，但这只是必要条件，不是充分条件（见第 3、5 节）。
5. **无 DeviceIdleFactsPort / provider**：全仓检索无 `DeviceIdleFactsPort` 或等价接口；`service.port/m02` 已有 `DeviceReadingsPort / DeviceConfigurationPort / DeviceCapabilityPort` 等**均无实现**。契约 G01 要求的"设备空闲"是跨 M02（设备在场）+ M03/M07（培养运行/关联）的**聚合事实**，当前无任何模块提供该聚合。
6. **baseRevisionId 组级 CAS / 幂等 / 守卫双模形状未冻结**：`AlarmOnlineConfigSaveCommand` 已具备 `requestId / scope / baseRevisionId / reason / rows / managementRevision` 字段，但 `OnlineInput` **无 per-row `configId` / `expectedVersion`**，与 M09-009 状态配置的逐行 CAS 范式不同；在线保存需按契约 §4"一次全组生效"走**组级候选投影 + baseRevisionId 锁 CAS**，该形状、幂等短路与守卫双模（成功/失败闭合）**尚未在设计上冻结**。

---

## 3. 裁决口径

- **方案 A（推荐方向，未来）**：新增 `DeviceIdleFactsPort`（内部 Port），由 M02/M03/M07 未来提供空闲事实；无 provider 时 M09-011 保存 **fail-closed**（依赖未知 → 503 / `BLOCKED_DEPENDENCY`，状态竞争 → 409 `STATE_CONFLICT`）。优点：不越界、边界干净，符合 `AGENTS.md §8` 与既有 Port 规约。缺点：本批只能做 fail-closed，不形成生产可保存成功路径。
- **方案 B（禁止）**：M09 直接窄读 M02/M03/M07 内部表判断空闲。**否决**——违反 Port 规约（"消费者不得注入提供方数据访问层、内部表或实现类"）与 `AGENTS.md §8` 跨模块边界，且会把本应归属他模块的状态判定复制进 M09。
- **CULTURE scope = BLOCKED_M06**：培养在线变更走 `M06_SC045`（`INT02` 审批链），`ApprovalDecisionPort` / `AlarmConfigDecisionPort` 无实现 → 保持 501。
- **VERIFIED = BLOCKED_INPUT**：需核准 `logic_profile_ref` / profile，缺 → 保持 501；客户端**严禁写 VERIFIED / profile**（`OnlineInput` 注释已冻结该规则），不伪造 VERIFIED。
- **生产空闲事实缺 provider**：即使接线，DEVICE 保存成功路径仍 **BLOCKED_EXTERNAL / BLOCKED_DEPENDENCY**（运行时恒 503）。
- **KIND_ONLINE 仅未来 011 真开发时补**：`alarm_config_revision.config_kind` CHECK 虽已允许 `ONLINE`，但**本轮不得提前在 `AlarmConfigRevisionService` 加 `KIND_ONLINE`**。

---

## 4. 为什么不允许 wired:true

1. **项目没有"仅 fail-closed 就标 wired"的先例**：`wired:true` 在本仓语义是"真实 Controller→ApplicationService→Mapper/Port 链路已接、且本地可完成部分已达成"。
2. **M09-016 保持 501**：纯外部设备命令、无本地可完成部分，接线前提不成立时不翻 wired，是同类 fail-closed 场景的现行处置。
3. **M09-021 是"本地可完成部分完成后才 wired"**：021 先交付了本地 CAS + attempt 证据（`b0d2ac25c`），外部发送才另列 BLOCKED。011 不同——其"空闲校验"是**写库前置门**，本地写无法在不校验空闲的情况下独立成立，因此没有可先行 wired 的"本地可完成部分"。
4. **现在标 wired:true 会让骨架门禁沉默失败**：`FullSystemSkeletonGateTest` 按"501 抛出数 vs 方法数"识别未接线骨架；过早 wired 会掩盖"设计未闭合"，把 NEEDS_DESIGN_REGISTRATION 伪装成已实现，违反 `AGENTS.md §13.2` 完成判定口径。

---

## 5. 后续解锁条件（开发前必须先冻结）

1. `DeviceIdleFactsPort` 接口签名与 **provider 归属**（M02 单点 / M03 或 M07 单点 / M09 侧新聚合 Port 由三方填充）——必须裁决由谁拥有"设备空闲"事实。
2. **baseRevisionId 组级 CAS** 形状（组级锁 + 全有或全无投影，还是逐行 CAS）。
3. **幂等规则**（requestId 收据短路语义、同键异内容冲突码口径）。
4. **守卫双模形状**（成功路径 + 失败闭合/依赖未知的响应契约）。
5. **DIRECT / SAVE_ONLY 子集边界**（哪些字段允许直存、哪些高级字段仅存不执行、`logic_profile_ref` 恒 NULL 的约束落点）。
6. 未来 **KIND_ONLINE 台账规则**（scope_key 语义 = DEVICE+deviceKind+deviceId 且 culture_id 空、快照白名单列、与 `ALARM_CONFIG_REVISION` 对象族复用确认）。
7. 是否补 **alarm 菜单/权限种子**（当前 `02-基础数据初始化.sql` alarm 权限/菜单 0 命中 → 补齐才能解锁 HTTP/浏览器）。

> 审计若未来真开发（预告，非本轮）：`ManagementOperation` 追加 `M09_011`（169→170）、`AuditObjectType` **沿用 `ALARM_CONFIG_REVISION`**（不新增枚举，护 `AuditPolicyRegistryTest` 的 allOf 覆盖闭合）、idBinding `OUTCOME_ID`(revision_id)、deleteKind `NONE`、businessType `UPDATE`，并同步 `ManagementOperationTest` / `AuditPolicyRegistryTest` / `skeleton` / 新增契约测试。此属解锁后批次，本轮一律不动。

---

## 6. 分层状态（本轮口径，不得冒充更高层）

| 维度 | 状态 |
|------|------|
| 实现 | **NOT_IMPLEMENTED / NEEDS_DESIGN_REGISTRATION / KEEP_501** |
| 文档 / 静态核对 | **STATIC_VERIFIED（仅本裁决文档存在、代码/DDL/契约事实已逐项核对）** |
| 编译 / 契约测试 | NOT_VERIFIED（本轮未编译、未跑测试） |
| HTTP_VERIFIED | **NOT_VERIFIED** |
| BROWSER_VERIFIED | **NOT_VERIFIED** |
| DB_VERIFIED | **NOT_VERIFIED** |
| 外部 / provider | **BLOCKED_EXTERNAL / BLOCKED_DEPENDENCY** |
| CULTURE 审批链 | BLOCKED_M06（M06_SC045 / INT02 未接线） |
| VERIFIED 核准 | BLOCKED_INPUT（logic_profile_ref / profile 未核准） |

---

## 附：与根级草稿的关系

仓库根存在同名未跟踪草稿 `M09-011-DEVICE-SAVE_ONLY-设计裁决表-20261002.md`（噪音文件，本轮不清理、不纳入提交）。本 `history/review/` 文件为正式归档副本，二者内容以本文件为准；根级草稿是否删除由用户另行处置。
