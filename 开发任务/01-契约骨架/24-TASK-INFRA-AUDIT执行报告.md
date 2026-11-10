# 24-TASK-INFRA-AUDIT 执行报告（R2）

任务：管理写审计模型与同事务审计 Hook 实现（为 INFRA-GUARD-R2 提供可调用、类型安全、fail-closed、同事务的审计能力）。

执行日期：2026-09-19。基线：21报告 §一（G1 冻结）+ 22报告 R1 + 23报告（INFRA-ACTOR R2）。

**R1 修订（2026-09-19）：审计对象身份与业务结果完整性闭环**——修正本报告初版审阅发现的
1 项 P0（快照对象集合未与 ManagementWriteOutcome 绑定）与 2 项 P1（objectType 可任意填写、
UPDATE before/after 集合可不一致）。§1—§30 为初版历史记录，其中 §2 差异清单的
"CFG05 after 与 CFG02 同列集"与"idSource/affectedIdsSource 仅描述性字段、运行时不校验集合"
两项表述已被 R1 取代，以文末 **R1 修订记录（§11 任务书 20 点）** 为准。

**R2 修订（2026-09-19）：审计对象 ID 规范化写入一致性收口**——修正 R1 审阅发现的写入面缺陷：
校验阶段已将 objectId 规范化（"007"→"7"），但 `indexByObjectId` 仍以原始字符串作 Map key，
UPDATE 两侧前导零文本形式不同时会割裂为两条变化日志。R1 修订记录保持有效，
文末另附 **R2 修订记录（任务书 §七 19 点）** 为最新口径。

---

## 1. TASK-INFRA-AUDIT 是否完成

**审计模型与生产 Hook 已实现**（本任务七项目标 1—7 全部落地并通过单元/契约/事务回滚测试）；
**具体业务 before/after 快照查询尚未实现**（属 GUARD-R2 与业务 ApplicationService 接线事项）；
76 个业务接口仍为 501 骨架；INFRA-GUARD-R2 尚未完成最终接线；真实 MySQL 事务/回滚/锁/HTTP 尚未验证。
**管理业务尚不可用**，本报告不以较低层验证结果宣称较高层级完成。

## 2. 编码前 15 项取证结果

| # | 取证项 | 真实证据（磁盘源码/DDL 实测） |
|---|--------|------------------------------|
| 1 | 两日志表实际字段 | `docs/开发基线/01-完整建表.sql`：`sys_oper_log`（L307起）`oper_id bigint AUTO_INCREMENT` 主键，含 `user_id bigint NULL`、`nick_name varchar(50) NULL '操作者当时显示名快照'`、`request_id varchar(64) ascii_bin NULL`、`oper_name varchar(50)`、`json_result varchar(2000)`；`sys_data_change_log`（L337起）`id bigint NOT NULL` **无 AUTO_INCREMENT**、`oper_id`、`description varchar(100)`、`old_data/new_data json NULL`、`changed_by varchar(64)`、`changed_nick_name varchar(64)`、`changed_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP`、`oper_ip varchar(128)`。实体 `SysDataChangeLog.java` 与之一致 |
| 2 | @Log/LogAspect/AsyncLogService 线程与事务边界 | `LogAspect` 为 `@AfterReturning`/`@AfterThrowing`（L71/L83），在 Controller 方法返回/抛出后触发，经 `AsyncLogService`（`@Async`，L24）异步落库——**与业务事务无关联** |
| 3 | 异步操作日志是否可能回滚后仍落库 | 可能：异步链路与事务边界无关、时序在方法返回后，不能承担"审计失败→业务回滚"的同事务语义（§十六 冻结：成功审计禁用该通道） |
| 4 | ManagementAuditHook 原物理签名 | 旧接口 5 参：`onManagementApplied(Long actorUserId, String requestId, String operationCode, ManagementWriteOutcome outcome, LocalDateTime committedAt)`；唯一调用点在 `ManagementGuardExecutor.doGuarded` 事务内、业务回调结果校验后、`increaseRevision` 前 |
| 5 | Executor 事务边界与调用顺序 | 单一 `TransactionTemplate`：锁 SYSTEM 行→回执判定→期望版本校验→溢出安全计算→业务回调→结果校验→审计钩子→revision CAS→回执写入→提交→提交后回填 committed 版本（G1 十六步的守卫段） |
| 6 | Callback/Outcome 能提供的数据 | `ManagementGuardCallback.execute(actorUserId)` 仅返回 `ManagementWriteOutcome{applied,id,affectedIds,managementRevision}`，**不含 before/after 快照**——快照必须由业务层在 B-LOC/A-LOC 取得后经 AuditIntent 装配（G1 §1.4/§1.5），本阶段 Executor 传 `intent=null` 占位 |
| 7 | ManagementOperation 实际枚举数量 | 恰 29 项：ORG×9（02/03/06/07/08/13/14/16/18）、ACL×7（02/03/04/06/07/08/10）、USR×6（03/04/05/06/09/10）、DIC×4（02/03/06/07）、CFG×3（02/03/05） |
| 8 | 与 21 报告 29 行映射表一致性 | 逐项核对严格一致：无缺项、无多余、无虚构新动作码 |
| 9 | 既有可复用写入方法 | `insertOperLog`（全切面列、无 user_id/nick_name/request_id、无 generatedKeys 回填）与 `insertDataChangeLog`（列集含 changed_nick_name/oper_ip）均不满足守卫最小写入需求 → 各新增一条既有表既有列的最小 INSERT（见 §19），不改动既有 statement |
| 10 | 同名生产 Hook 实现 | 原 `ManagementAuditHook` 仅有接口、无任何生产实现；本任务按 21 报告 §1.5 冻结名收敛为 `ManagementAuditHookR2` 并删除旧接口文件，全仓生产实现恰 1 个（`ManagementAuditWriter`），有类路径扫描测试与旧接口不存在测试双重门禁 |
| 11 | Mapper 是否返回影响行数 | 两表既有 insert 均返回 `int`，新增两条 likewise 返回 `int`，写入侧严格校验 `==1` |
| 12 | 审计写失败当前行为 | Executor 对旧 5 参 Hook 调用不捕获异常，异常上抛→TransactionTemplate 回滚（不吞错）；`auditHookFailureRollsBackEverything` 测试此前已固化该行为 |
| 13 | 现有日志是否可能记录敏感原值 | `LogAspect.EXCLUDE_PROPERTIES` 仅排除 `password/oldPassword/newPassword/confirmPassword`（fastjson 序列化过滤）；`token/sessionKey/initPassword/secret` 及 `jsonResult` 返回值序列化**无排除**，且 `@Async` 在事务外——既有通道存在原值入日志面，新链路以字段名禁列目录（§8）在写入前根断 |
| 14 | ActorContext 五字段允许性 | 实测字段：`actorUserId/actorName/sessionKey/authzVersion/requestId`。允许进入审计上下文：actorUserId、actorName、requestId（均为服务端可信派生值）；禁止：sessionKey（§六 绝对禁项）、authzVersion（系统版本量，非业务快照字段，不入两日志表） |
| 15 | requestId/actorUserId/actorName 可信来源 | requestId 来自 PRE-01A 解析校验的 `WriteMeta`（服务端生成/校验，Controller Body 不自报）；actorUserId/actorName 唯一来源为 `ActorContextPort.resolveActorContext`（23报告服务端会话推导），Executor 已强制十进制正数校验；浏览器/线程上下文自报 actor 一律无效（守卫测试以干扰值 7 证明） |

**差异清单（21 报告 vs DDL vs 源码）**：
- 会话中曾出现一份与磁盘矛盾的 `sys_data_change_log` 旧版 DDL 快照（AUTO_INCREMENT/text/username 列）——以本会话对 `01-完整建表.sql` 的直接读取为准（json 列、无 auto_increment、changed_by/changed_nick_name），未据此做"修复"；
- `USR10`（重置密码类动作）快照登记 `tableName=sys_user`（`password_version/init_password_status` 等为 sys_user 列）——21 报告行未显式给物理表名，属**实现层裁决**，未新增表/字段；
- `CFG05`（物理删除）after 白名单与 CFG02 同列集、不含 `del_flag`——物理删除无逻辑删除位，属裁决；
- 21 报告 §1.4 各行 `idSource/affectedIdsSource` 为**描述性冻结字段**（业务层取数指引），运行时对象标识一律以 `AuditSnapshot.objectId` 承载（类型化模型不建第二套 ID 字段）。

## 3. 最终审计模型类及字段

`com.futurefab.system.service.audit.model`（类名与字段逐字取自 21 报告 §1.5，未建平行模型）：

- `AuditFieldValue { String field; String value; }`（value 允许 null=该字段无值；渲染时省略键）
- `AuditSnapshot { String objectType; String objectId; List<AuditFieldValue> values; }`（values 拒绝 null 与 null 元素，防御性拷贝后不可变）
- `AuditIntent { List<AuditSnapshot> before; List<AuditSnapshot> after; String auditTitle; String businessType; }`（before/after 拒绝 null；新增场景 before=空列表永不 null；不可变）
- `AuditWriteContext { Long actorUserId; String actorName; String requestId; ManagementOperation operation; ManagementWriteOutcome outcome; AuditIntent intent; LocalDateTime committedAt; String newManagementRevision; }`（八字段构造器；intent 仅接线前允许 null 占位）
- `AuditOperLogRecord`（sys_oper_log 最小行载体：operId/title/businessType/operName/nickName/status/operTime/userId/requestId/jsonResult）

任务书 §五 列举的 AuditField/AuditSubject 等若与冻结物理名不同，一律按冻结名实现（§1.5 无独立 AuditField/AuditSubject 类，对应物即 AuditFieldValue/AuditSnapshot）；`operationCode/主对象类型/主对象ID/affectedIds/actorUserId/actorName/requestId/before/afterSnapshot` 全部有明确承载位：operation 枚举、objectType、objectId、`ManagementWriteOutcome.affectedIds`、ctx 三字段、before/after 列表。

**类型化门禁测试**：反射断言全部模型实例字段类型 ∈ {String, Long, LocalDateTime, ManagementOperation, ManagementWriteOutcome, AuditIntent, List}，禁 Map/Object/Entity 承载（`AuditModelTest`）。

## 4. ManagementAuditHook 最终物理签名

`com.futurefab.system.service.guard.ManagementAuditHookR2`（21 报告 §1.5 冻结名）：

```java
void onManagementApplied(AuditWriteContext ctx);
```

Javadoc 冻结契约：只读 ctx；必须在调用方守卫事务内同步执行；异常一律上抛触发整体回滚；幂等重放路径不得调用；生产实现全局恰一个。旧 5 参接口 `ManagementAuditHook` 文件已删除，全仓无残留引用（程序化 grep 验证），测试以 `Class.forName(...ManagementAuditHook)` 抛 `ClassNotFoundException` 固化"无第二套"。

## 5. 唯一生产实现及依赖列表

`ManagementAuditWriter`（`@Component`，实现 `ManagementAuditHookR2`）。构造依赖恰 4 项（有白名单反射测试）：

1. `SysOperLogMapper`（仅调 `insertManagedOperLog`）
2. `SysDataChangeLogMapper`（仅调 `insertManagedChangeLog`）
3. `SnowflakeId`（common-core 既有，应用侧生成 `sys_data_change_log.id`）
4. `ObjectMapper`（快照稳定序列化）

无 Redis/HTTP 客户端/Feign/M02—M09 领域 Port/`AsyncLogService` 依赖；无 `@Async`、无任何 `@Transactional`（传播行为含 REQUIRES_NEW）注解——均有反射与源码检索门禁（§14 门 6/7 实测通过）。

## 6. 29 个 operationCode 映射完整性

`AuditPolicyRegistry`（EnumMap 静态注册）：29 项全部注册、每项唯一映射（auditTitle/businessType/businessAction/subjectType/tableName/changeOperation/idSource/affectedIdsSource/beforeFields/afterFields/maskingPolicy），无默认兜底；`require(null/未登记)` 在任何写前抛错失败关闭；类加载期三重静态门禁（数量=29、与 `ManagementOperation.values()` 全覆盖、无重复登记）。

`AuditPolicyRegistryTest` 以显式 29 行期望表（code|auditTitle|businessType|tableName|changeOperation|before|after）逐项核对 21 报告 §1.4 冻结映射，非仅断言数量；同时程序化核对 `ManagementOperation` 枚举与注册表 29/29 一一对应（§十四 门 4 另有 grep 计数=29）。

`changeOperation` 语义：INSERT（新增）/UPDATE（修改，USR10=UPDATE）/DELETE（删除，批量逐对象一行）；`businessType` 为 §1.4 冻结 String 十进制，物理列 `business_type int`，写库前 `Integer.parseInt`（映射说明即此，未改契约语义）。

## 7. before/after 快照生成责任边界

- 业务 B-LOC（写前）/A-LOC（写后）取数与 `AuditIntent` 装配由**业务 ApplicationService + INFRA-GUARD-R2** 完成，本任务未实现任何业务查询；
- 生产 Writer 绝不查询业务表（测试 Proxy 对 `insertManagedOperLog/insertManagedChangeLog` 之外任何 Mapper 方法调用抛 `AssertionError`，证明"Hook 内不读业务 Mapper 生成快照"，§十二 34）；
- 接线前 Executor 传 `intent=null`（代码内注释标注 GUARD-R2 接线事项），Writer 对 null intent 在**任何数据库写入前**抛 `IllegalStateException` 失败关闭——不存在绕过类型化意图偷写半成品审计的路径；
- `GuardExecutionResultR2`（R2 回调返回类型）属 GUARD-R2 接线事项，本阶段不创建半成品类。

## 8. 字段白名单和脱敏规则

`AuditFieldCatalog`：字段名（小写去下划线精确匹配，不误伤派生合法名）禁列目录——password 族（password/password_hash/init_password/old_password/new_password 等）、credential、credential_version、token、jwt、session_key、redis_key、hmac_key/receipt_hmac_key、secret、client_secret、private_key、config_value（原文列名）、login_ip/login_date/login_count；公共审计列（create_by/create_time/update_by/update_time/ancestors/active* 等）禁入快照。异常消息只含规则说明与字段名，绝不含字段值（该规则是 §12-35 HTTP 防泄漏的前提）。

`ManagementAuditWriter.validateSnapshots`：字段名 ∈ 该 operation 的 before/after 白名单、字段名唯一、objectId 十进制且唯一；新增场景 before 必须空列表、变更/删除场景 before/after 缺一即拒绝；底层组件（目录/编解码）的 `IllegalArgumentException` 统一收敛为 Writer 失败关闭 `IllegalStateException`（消息只传播规则文本）。

快照渲染 `LinkedHashMap` 固定键序 = `objectType, objectId, 白名单登记序`，null 值省略键 → 同一逻辑输入字节稳定（测试以乱序输入同输出证明）。

## 9. config_value 摘要规则

`AuditValueCodec.configValueDigest`：不保存原文；冻结格式
`{"value_masked":"***","value_sha256_12":"<SHA-256 hex 前12位>","value_length":<字符数>}`，
不依赖 BLK-04b 即可安全落审计；CFG 行白名单只放行 `config_value_digest` 字段名，`config_value` 本身在禁列目录；异常/日志不输出原值（测试断言摘要不含原值、形状匹配正则、不同值摘要不同）。

## 10. 长文本截断和摘要规则

`AuditValueCodec.truncate`：>512 字符 → 前 512 + `…#s2:<SHA-256 hex 前16>`（截断不静默，摘要可复核）；渲染端对每个字段值防御性再截断（600 字符输入测试验证列内不超长）。列宽物理截断：oper_name≤50、changed_by≤64、json_result≤2000。禁 JVM 默认行为入审计：禁实体 toString、禁堆栈/SQL 原文（消息模板测试 + 禁列目录）。

## 11. affectedIds、ID、时间规范化规则

- ID 一律十进制 String（`requireDecimalId` 拒绝非 `\d+`，禁 JSON number）；
- 集合主键 `sortedDistinctIds`：BigInteger 数值升序 + 去重（`1,9,10,100` 测试固化，非字典序）；
- 时间冻结 `Asia/Shanghai`、格式 `yyyy-MM-dd HH:mm:ss`（`formatDateTime/formatDate`；JVM 默认时区改 `America/New_York` 下输出不变）；`changed_at` 以 `Timestamp.valueOf(committedAt)` 无时区漂移写入；审计时刻=守卫事务统一取时（与回执 create_time/expires_at 同一 `now`，测试断言）；
- null 与字段不存在唯一规则=省略键（§8）；before/after 字段集合由 operationCode 白名单决定（§6）。

## 12. sys_oper_log 写入方式

每次管理写成功恰好 1 行：`insertManagedOperLog`（XML 见 §19），列=既有列最小子集
`title, business_type, oper_name, nick_name, status, oper_time, user_id, request_id, json_result`；
title/business_type 只允许注册表冻结值（ApplicationService 伪冒即拒）；status=0（成功）；oper_time=committedAt；json_result=回执冻结四字段的稳定序列化摘要（不含载荷原文）；**nick_name=NULL 裁决**：ActorContext 仅提供 actorName（登录名/显示名不可区分），禁猜显示名快照列，可信操作者以 oper_name+user_id 承载。影响行数≠1 或 oper_id 未回填 → 抛错回滚。

## 13. sys_data_change_log 写入方式

逐对象 1 行（before/after 按 objectId 配对取并集，数值升序）：`insertManagedChangeLog`，列=
`id, table_name, record_id, oper_id, operation, description, old_data, new_data, changed_by, changed_at`；
id=应用侧 `SnowflakeId.nextId()`（DDL 无 AUTO_INCREMENT，字段字典 §3.19 裁决）；old_data=before 快照序列化（新增=NULL）、new_data=after 快照序列化；description=注册表 businessAction；changed_by=actorName（≤64 截断）；changed_nick_name/oper_ip 不写（NULL 裁决，同 §12）。影响行数≠1 → 抛错回滚。

## 14. oper_id 取得方式

`insertManagedOperLog` 声明 `useGeneratedKeys="true" keyProperty="operId"`，AUTO_INCREMENT 主键**同事务 INSERT 后即时回填**，全部变更明细行引用同一 operId 建立关联；回填缺失（null）视同写入失败失败关闭。无异步二次查询、无跨事务取号。

## 15. 同事务和 fail-closed 证明

三层证据（均不连真实 MySQL）：
1. **代码结构**：Writer 无独立事务/异步注解（§5），由 `ManagementGuardExecutor` 的唯一 `TransactionTemplate` 承载；Executor 对 Hook 调用零捕获；
2. **生产 Writer 接入真实 Executor 链**（`ManagementAuditWriterTxTest`）：intent=null → Writer 在任何审计写入前抛错 → 断言 `txRollback`、revision 不提交（维持 4→4）、回执零提交、两日志表零写入行；
3. **模拟 R2 接线时序**：同一 `TransactionTemplate` 内业务 CAS + 回执暂存 + 合法意图审计；审计中途失败（change 影响 0 行）→ 业务版本与回执整体回滚（revision 维持 5、回执为空、`txRollback`、无 `txCommit`）；成功路径则业务+审计一起提交（revision 5→6、回执 1、oper 1、change 1）。
另有既有 `auditHookFailureRollsBackEverything`（钩子抛错→全回滚）与 Proxy 假 Mapper 的越界方法调用即 `AssertionError` 机制，共同构成"不吞错、不降级、不半成品提交"的 fail-closed 证明。

## 16. 重放、失败与成功审计语义

- 首次成功：同事务恰 1 次成功审计（`auditContexts.size()==1` 断言）；
- 幂等重放：不执行 callback、不递增 revision、**不重复写审计**（`replayReturnsOriginalReceiptAndBackfillsOriginalRevision` 断言重放路径审计计数 0）、返回原回执；
- 版本冲突（MANAGEMENT_CONFLICT）、REQUEST_CONFLICT、INPUT_INVALID（未登记动作码/非法ID）路径：审计上下文计数 0，不写任何成功审计（对应测试断言已固化）；
- 系统异常失败审计：沿用既有 `@Log`/`LogAspect`/`AsyncLogService` 异步边界（§2 取证 2/3/13），与本成功审计**不混同**，本报告不声称异步失败审计与业务同事务。

## 17. 是否使用异步或独立事务

否。生产实现无 `@Async`、无任何事务传播注解（构造与逐方法反射测试断言）；不调用 `AsyncLogService`（依赖白名单 + 源码检索）；测试运行亦不启真实容器。

## 18. 是否修改 ManagementGuardExecutor

修改性质=§十一 许可的 Hook 签名收敛最小编译适配，幂等四元组/SYSTEM 锁/CAS/回执格式/重放规则/事务顺序零改动。逐行清单：

| 位置 | 改动 |
|------|------|
| L19 | 新增 `import ...service.audit.model.AuditWriteContext;` |
| L73/L85 | 字段与构造参数类型 `ManagementAuditHook` → `ManagementAuditHookR2`（@Nullable 语义不变） |
| L121-123 | 执行入口拒绝消息更新为 `ManagementAuditHookR2 尚无实现...`（拒绝行为不变） |
| L148-149 | `transactionTemplate.execute` lambda 传入 `actor.getActorName()`（新增一个参数） |
| L164-180 | `resolveTrustedActor` 返回类型 `String`→`ActorContext`（原 null/十进制校验逐条保留） |
| L182-197 | 新增私有 `requireTrustedActorUserId(ActorContext)`：正数与溢出校验（原逻辑等价迁移） |
| L199 | `doGuarded` 签名增加 `String actorName` 参数 |
| L262-266 | 审计钩子调用改单参：`auditHook.onManagementApplied(new AuditWriteContext(actorUserId, actorName, writeMeta.getRequestId(), ManagementOperation.fromCode(operationCode), outcome, null, now, Long.toString(newRevision)))`，位置不变（业务回调结果校验后、`increaseRevision` 前）；`intent=null` 占位注释标注 GUARD-R2 接线事项 |
| 类 javadoc | Hook 引用名更新 + null 占位语义说明 |

行为保持证明：`ManagementGuardExecutorTest` 既有 23 项全绿（含 PRE-01B 幂等/CAS/回滚/冲突/溢出/BUSY 语义回归，§十二 38）+ 新增 1 项（`auditContextCarriesTrustedFieldsWithNullIntentBeforeWiring`：ctx 八字段逐项断言 actorUserId=42/actorName=requestId=operation 枚举=committedAt 统一取时=newManagementRevision="6"/intent=null）。

**装配影响说明（供 R2 参考）**：`ManagementGuardConfig` 注入唯一实现后，接线前任何经守卫的管理写在 Writer 处失败关闭（原为"无实现→入口拒绝"，现为"有实现→意图未装配拒绝"），两者同为 fail-closed，行为中性（当前无生产业务写调用方）。

## 19. 是否修改 Mapper/XML

仅按 §九/§十三 许可为既有两张审计表各补一条最小写入 statement（纯新增，未触碰既有 statement；`git diff --stat` 实测 4 文件 +37 行、0 删除、0 修改行）：

- `SysOperLogMapper.java` + `SysOperLogMapper.xml` — `insertManagedOperLog`：

```sql
insert into sys_oper_log(title, business_type, oper_name, nick_name, status, oper_time,
                         user_id, request_id, json_result)
values (#{title}, #{businessType}, #{operName}, #{nickName}, #{status}, #{operTime},
        #{userId}, #{requestId}, #{jsonResult})
-- useGeneratedKeys="true" keyProperty="operId"
```

- `SysDataChangeLogMapper.java` + `SysDataChangeLogMapper.xml` — `insertManagedChangeLog`：

```sql
INSERT INTO sys_data_change_log
    (id, table_name, record_id, oper_id, operation, description, old_data, new_data, changed_by, changed_at)
VALUES
    (#{id}, #{tableName}, #{recordId}, #{operId}, #{operation}, #{description},
     #{oldData}, #{newData}, #{changedBy}, #{changedAt})
-- id 应用侧雪花生成，无 generatedKeys
```

两表既有列全覆盖，未新增列。既有 `insertDataChangeLog` 的 id 传值方式与 DDL 无 AUTO_INCREMENT 的口径矛盾不在本任务处置范围，已登记 §27。

## 20. 是否修改数据库结构或基线 SQL

否。`docs/开发基线/**` 与全部 DDL 零改动（`git status --short -- docs/开发基线` 为空），未新增表/字段，未执行任何 SQL。

## 21. 新增和修改文件清单

生产新增（`futurefab-system`）：
- `service/audit/`：`AuditFieldCatalog.java`、`AuditValueCodec.java`、`AuditPolicy.java`、`AuditPolicyRegistry.java`、`ManagementAuditWriter.java`
- `service/audit/model/`：`AuditFieldValue.java`、`AuditSnapshot.java`、`AuditIntent.java`、`AuditWriteContext.java`、`AuditOperLogRecord.java`
- `service/guard/ManagementAuditHookR2.java`（新增）；`service/guard/ManagementAuditHook.java`（**删除**，旧接口收敛）

生产修改：
- `service/guard/ManagementGuardExecutor.java`（§18 逐行清单）
- `mapper/SysOperLogMapper.java`、`resources/mapper/system/SysOperLogMapper.xml`
- `mapper/SysDataChangeLogMapper.java`、`resources/mapper/system/SysDataChangeLogMapper.xml`

测试新增：`AuditPolicyRegistryTest`、`AuditValueCodecTest`、`model/AuditModelTest`、`ManagementAuditWriterTest`、`ManagementAuditWriterTxTest`、`AuditLeakGuardMockTest`
测试修改：`ManagementGuardExecutorTest`（Hook 桩收敛为单参 lambda + auditContexts 记录 + 1 项新测试）、`M01ActorContextGuardWiringTest`（同签名适配）
文档新增：本报告。

工作区中其余 M/?? 条目（Controller、其他 Mapper、docs、并行会话文件等）均为本任务开始前既有变更，本任务未触碰；未清理任何非本任务 `_tmp` 文件。

## 22. 新增测试数量及覆盖关系

新增测试 44 项 = 43（6 个新文件）+ 1（Executor 新用例），对 §十二 38 条要求覆盖映射：

| §十二 要求 | 承载测试 |
|---|---|
| 1 生产实现恰 1 | RegistryTest 类路径扫描 + 旧接口不存在断言 |
| 2/4/5 29 全注册/标题类型/白名单一致 | RegistryTest 29 行显式期望表逐项 |
| 3 未登记码失败关闭 | RegistryTest + WriterTest(null op) + Executor 既有 INPUT_INVALID 用例（§38 无回归） |
| 6-10 password/token/sessionKey/HMAC 键/config_value 原文禁入 | WriterTest 14 禁列逐一 + CodecTest 禁列判定（sessionKey/session_key 同禁、派生合法名不误伤）+ config 摘要测试 |
| 11/12/13/14/15/16/17 摘要稳定/512 截断/ID String/去重升序/时区固定/顺序稳定/null 稳定 | CodecTest（时区改 JVM 默认美东不变、数值序 1,9,10,100 等）+ WriterTest 渲染字节稳定/省略键/防御截断 |
| 18 禁 Entity 输入 | AuditModelTest 反射类型白名单（Map/Object/Entity 拒） |
| 19/20/21/22/23/24 正常主记录/明细/0 行失败关闭/写异常上抛 | WriterTest（happy path 逐列、批量升序、operResult=0/changeResult=0、DataAccessException/QueryTimeoutException 直抛） |
| 25/26/27 审计失败→业务回滚/不写 revision/不写回执 | ManagementAuditWriterTxTest 三用例（§15） |
| 28/29 重放不重复审计/冲突与输入失败不写成功审计 | ManagementGuardExecutorTest 既有断言（auditSeen/auditContexts 计数） |
| 30/31/32/33/34 无 @Async/无 REQUIRES_NEW/无 Redis·HTTP·M02 依赖/不调 AsyncLogService/不读业务 Mapper | WriterTest 架构禁令反射 + Proxy 越界方法即 AssertionError + §十四 门 6/7 grep |
| 35 HTTP 不泄漏审计载荷 | AuditLeakGuardMockTest（MockMvc+GlobalExceptionHandler 真实通道，毒化载荷 canary 禁入响应体，3 用例） |
| 36 INFRA-ACTOR 39 项无回归 | 全量运行（适配器 27 + HTTP 5 + wiring 3 + revision 4 全绿） |
| 37 76 条 501 骨架无回归 | 全量运行（contract/M01ResponseLeakGuard 等既有类全绿） |
| 38 PRE-01B 幂等/CAS 无回归 | ManagementGuardExecutorTest 24 项全绿 |

全部测试为内存假 Mapper/JDK Proxy/暂存式事务管理器/standalone MockMvc，未连接真实 MySQL/Redis/外部系统。

## 23. system 测试实际结果

`mvn -pl futurefab-modules/futurefab-system -am test`（离线）：**Tests run: 354, Failures: 0, Errors: 0, Skipped: 0，BUILD SUCCESS**（基线 310 + 本任务 44，无回归）。

## 24. auth 测试实际结果

`mvn -pl futurefab-auth -am test`（离线）：**Tests run: 14, Failures: 0, Errors: 0，BUILD SUCCESS**，无回归。

## 25. git diff --check 结果

无空白错误（仅 3 个既有文档的 CRLF→LF 转换提示，属并行工作区既有文件，非本任务修改）。

## 26. 未执行的真实 MySQL/HTTP/并发验证

以下仅到"静态检查 + 单元/契约 + 暂存事务模拟"层，**未**宣称通过：
- 真实 MySQL：AUTO_INCREMENT oper_id 并发回填、JSON 列写入、重复键、锁等待/死锁路径、真实回滚留痕；
- 真实 HTTP：管理写全链路 501→业务响应（76 接口仍骨架，无生产调用方）；
- 真实并发：同 requestId 竞态重放、版本竞争；
- 真实 Nacos/网关链路：HMAC 密钥注入、sessionKey 派生。
雪花 ID 的 datacenterId/machineId 生产配置注入亦属接线事项（测试用 1,1）。

## 27. 剩余阻塞和待裁决事项

1. **GUARD-R2 接线**（计划内，非阻塞）：B-LOC/A-LOC 业务快照查询、AuditIntent 装配、`GuardExecutionResultR2` 创建与 Executor→Writer 真实意图贯通；
2. **@Log 切面去重**（21 报告 §四，待 R2 裁决）：共享层无扩展点且 common-log 不在本任务允许清单——当前 76 接口为 501 骨架、无真实双写；R2 接入时须裁决"已接线管理写 Controller 摘除 @Log 或共享层提供排除钩子"，避免同事务成功审计 + 异步切面双写 sys_oper_log；
3. **既有 `insertDataChangeLog` 与 DDL 口径矛盾**（id 传值 vs 无 AUTO_INCREMENT）：登记不改动，属业务日志链路既有问题，非本任务边界；
4. nick_name/changed_nick_name=NULL、USR10 tableName、CFG05 无 del_flag 已按裁决落地（§2/§12/§13），如需变更须在 R2 前改注册表单点。

无错误码枚举改动、无新建错误码（现有 `ManagementGuardRejectException`/FutureFabErrorCode 完全够表达）。

## 28. 是否可以进入 INFRA-GUARD-R2

**可以**。R2 所需的全部本层依赖已就绪且类型安全：单方法冻结 Hook、八字段 AuditWriteContext、四模型、29/29 策略注册表、唯一生产 Writer、两表最小写入与同事务回滚语义。R2 工作=业务快照装配与接线（§27-1/2），且现状 fail-closed 保证任何未接线的管理写不可能偷跑半成品审计。

## 29. 是否触碰具体业务 CRUD、76 个 Controller、M02 或 Vue

否。未新增/修改任何 Controller、业务 DTO/View、业务 ApplicationService、用户/角色/菜单/组织/字典/配置业务 Mapper/XML、ActorContext 与 M01ActorContextAdapter、M02—M09、Vue、客户只读材料、数据库表结构；未新增任何 HTTP 接口（29 项映射未扩为接口，§八-7/8）。`git status` 路径核对见 §21。

## 30. Git 未提交确认

未执行任何 `git commit`/`git push`/`git reset`/`git checkout`/`git clean`/`git restore`；全部产出停留在工作区，由用户决定后续处置。

---

### §十四 验证命令执行记录（串行）

| # | 命令/检查 | 结果 |
|---|-----------|------|
| 1 | system -am test | 354/354 BUILD SUCCESS（离线 -o；无 target 权限环境失败） |
| 2 | auth -am test | 14/14 BUILD SUCCESS |
| 3 | git diff --check | 通过（无空白错误） |
| 4 | 枚举 vs 注册表 29/29 | `grep -c "put(map, ManagementOperation." = 29` + RegistryTest 全覆盖断言通过 |
| 5 | 生产 Hook 实现数 | 主源码 `implements ManagementAuditHookR2` 恰 1（ManagementAuditWriter）；旧接口无残留引用；测试扫描断言通过 |
| 6 | @Async/REQUIRES_NEW | service/audit 与 Hook 接口零命中 |
| 7 | Redis/HTTP/M02 依赖 | 零 import（唯一命中为注册表中描述性 subjectType 文案字符串，非依赖） |
| 8 | 生产源码敏感禁列 | config_value 仅以摘要策略与禁列目录名出现，无原值写入路径（§9/§8 测试） |
| 9 | Controller/业务 SQL/Vue/基线/客户材料 | `git status --short` 对受保护路径为空（本任务视角）；既有 M 条目为任务前变更 |
| 10 | 业务 CRUD | 未实现（§29） |

---

# R1 修订记录：审计对象身份与业务结果完整性闭环（任务书 §十一 20 点）

## R1-1. R1 是否完成

**完成（静态/单元/契约层）**。P0（对象集合未绑定 outcome）与两项 P1（objectType 任意填写、
UPDATE 两侧集合可不一致）已在 `ManagementAuditWriter` 的任何审计数据库写入之前集中闭环，
并有专项测试组证明。未开始 INFRA-GUARD-R2，未实现任何具体业务 CRUD。

## R1-2. 初版 P0/P1 根因

- **P0 根因**：初版 Writer 只校验快照自身形态（objectType 非空、objectId 十进制、侧内去重、
  字段白名单）与 before/after 空/非空规则，从未把 `ctx.getOutcome()` 的 id/affectedIds 与快照
  对象集合比较——即"快照里有什么就审计什么"，业务层可漏审（outcome 有 2 个对象只快照 1 个）、
  多审/串审（快照放入 outcome 之外的对象）而不被发现；`idSource/affectedIdsSource` 只是描述文本，
  无机器可执行约束。
- **P1(objectType) 根因**：`AuditSnapshot.objectType` 为非空自由字符串，渲染时直接透传，
  无 canonical 域约束，可写中文标题/表名/任意文本。
- **P1(UPDATE 两侧) 根因**：before/after 各自独立校验，无"两侧对象集合都等于 expected 因而
  必相一致"的闭合规则；逻辑删除同样不设两侧对齐。

## R1-3. 29 项 ID 绑定策略最终统计

`AuditPolicy.idBinding`（枚举 `AuditIdBinding`，构造器拒绝 null，无任何默认兜底）：

| 绑定类型 | 数量 | 行 |
|----------|------|----|
| OUTCOME_ID（expected={outcome.id}；affectedIds 空或恰=[id] 否则矛盾） | 22 | ORG02/03/07/08/13/14、ACL02/03/04/06/07/08、USR03/04/05/09、DIC02/03/06/07、CFG02/03 |
| OUTCOME_AFFECTED_IDS（expected=规范化 affectedIds 非空；id 必填且 ∈ expected） | 5 | ORG06、ORG16、ACL10、USR06、CFG05 |
| OUTCOME_ID_WITH_SIDE_EFFECT_IDS（expected={id}；affectedIds=副作用对象集仅结构校验） | 1 | ORG18（21报告 L106：实际解除的子部门/挂用户重挂对象 ID） |
| OUTCOME_ID_WITH_COUNT_RECEIPT（expected={id}；affectedIds=被撤销会话数，允许 0，非对象集） | 1 | USR10（21报告 L119：被撤销会话数（回执 affectedIds）） |

后两类是 §三"确有依据的显式类型"：其 21 报告冻结行的 affectedIds 语义不是主对象集合，
不能并入 OUTCOME_ID 的矛盾规则，也不能按 expected 比较；依据已在枚举 Javadoc、注册表行与
本报告逐条登记。**29/29 全部有明确绑定，无一项落入"无法唯一确定→默认放行"**（§三 阻塞清单=空）。

## R1-4. canonicalObjectType 完整映射

`AuditObjectType` 枚举（9 值，取自 21报告 §1.4 对象族列）：
VENUE（ORG02/03/06）、DEPT（ORG07/08/18）、GROUP（ORG13/14/16）、MENU（ACL02/03/04）、
ROLE（ACL06/07/08/10）、USER（USR03/04/05/06/09/10）、DICT_TYPE（DIC02/03）、
DICT_DATA（DIC06/07）、CONFIG（CFG02/03/05）。
运行时规则：快照 objectType 必须**严格等于**枚举名（禁中文标题/表名/自由文本/空）；
`subjectType` 冻结中文文本仅保留展示，不再作任何校验依据；渲染 old_data/new_data 时
一律使用注册表 canonical 值（`renderSnapshot(..., policy.getObjectType().name())`），
不盲信快照输入。`RegistryTest` 断言 9 族全覆盖 + 29 行逐行期望列。

## R1-5. outcome.id / affectedIds 规范化规则

统一规范化域（`ManagementAuditWriter.requirePositiveDecimal/normalizedPositiveIds`，
非字符串包含判断）：正则十进制数字 → BigInteger；必须 **>0 且 ≤ Long.MAX_VALUE**（溢出失败）；
输出 BigInteger 规范字符串（去前导零，007→7）；集合去重后 **BigInteger 数值升序**。
快照 objectId 同域规范化后比较。USR10 计数回执单列：恰一项、非负十进制（允许 0，
冻结语义=会话数而非对象 ID）。矛盾检查：OUTCOME_ID 下 affectedIds 规范化后必须 空 或
=[id]；OUTCOME_AFFECTED_IDS 下 id 必须 ∈ 规范化 affectedIds。

## R1-6. 四类操作的快照集合规则

- **INSERT**：before 必空；after 对象集合 严格全等 expected；
- **UPDATE（含启停/强退/本人资料）**：before=expected 且 after=expected（两侧全等 ⇒ 一致，
  缺项/多项/串项/两侧不一致四类全部写前失败）；
- **逻辑删除（ORG06/16/18、ACL10、USR06，deleteKind=LOGICAL）**：同 UPDATE 集合规则，
  after 按白名单体现 `del_flag`（USR06 另有 `lab_removed_count`）；
- **物理删除（CFG05，deleteKind=PHYSICAL）**：before=expected（删除前白名单整行）、
  after 必空、变更明细 `new_data=NULL`、`old_data` 有值；删除回执 {ids,count} 由
  outcome/幂等回执与 json_result 承载，**不伪造"删除后实体"**。
逐规则实现于 `validateSnapshotSetClosure`，均有专项测试（R1-11 对照）。

## R1-7. CFG05 最终裁决与依据

**物理删除**。三重独立权威佐证（非注册表自证）：
① 21报告 L126 CFG05 行 A-LOC 列原文"删除回执{ids,count}（**sys_config 物理删，无 del_flag**）"；
② 05-PKG-01 差异审计："sys_config 无 del_flag：物理删即永久"；
③ 开发基线 `01-完整建表.sql` L266—279 `sys_config` 列集无 del_flag，
`SysConfigMapper.xml` deleteConfigByIds（L116—121）为真 delete 语句。
落地：注册表 CFG05 after 白名单改空列表、deleteKind=PHYSICAL；Writer 物理删除分支
after 非空即"物理删除…不得伪造删除后实体"失败；old_data=删除前 CONFIG 白名单整行、
new_data=NULL。00清单（M01-071·ADJUST·CONTRACT_FROZEN·deleteConfigByIds）与裁决一致，
无需登记设计阻塞。

## R1-8. Writer 如何防漏审、多审、串审

漏审：expected 唯一来自注册表绑定 + 冻结 outcome，快照少一个对象 → 集合不全等 → 写前失败
（`batchMissingObjectFailsClosed`、`singleObjectMissingSnapshotSideFailsClosed`）。
多审：快照多出 outcome 之外对象 → `batchExtraObjectFailsClosed`、`singleObjectExtraSnapshotFailsClosed`。
串审：快照对象与 outcome 不对应（换 ID）→ `updateBeforeAfterSetsDivergingFromEachOtherFailClosed`、
`insertSnapshotForDifferentObjectThanOutcomeFailsClosed`、`forceLogoutSessionCountNeverEntersExpectedObjectSet`。
另有 outcome.id↔affectedIds 矛盾（`batchOutcomeIdNotInAffectedSetIsContradictionAndFailsClosed`）、
applied=false、管理版本分叉、批量空集/物理删空回执等前置门。全部失败不写任何审计行。

## R1-9. 校验是否全部位于首条审计 INSERT 之前

是。`onManagementApplied` 内顺序：policy→intent→actor/必填→`validateOutcomeBinding`→
`validateIntentAgainstPolicy`→`validateSnapshots`×2→`validateSnapshotSetClosure`→
**然后才是** `writeOperLog`（程序化取证：ManagementAuditWriter.java L117/L121 校验早于
L123 写入）。每个失败测试的 `expectFailClosed` 助手统一断言 operRows/changeRows 均空
（§八-18/19）；TxTest 第 4 段进一步证明集合不一致时守卫事务回滚且**两表零写入尝试**。

## R1-10. 新增与修改文件（恰 10 个 + 本报告）

新增：`service/audit/AuditIdBinding.java`、`AuditObjectType.java`、`AuditDeleteKind.java`、
测试 `ManagementAuditWriterOutcomeClosureTest.java`。
修改：`service/audit/AuditPolicy.java`（+3 机器字段+null 拒收）、`AuditPolicyRegistry.java`
（29 行逐行补三列；CFG05 after 白名单改空）、`ManagementAuditWriter.java`（R1 集中校验）、
测试 `ManagementAuditWriterTest.java`（canonical 化+批量 outcome 绑定）、`AuditPolicyRegistryTest.java`
（期望表扩三列+分布/无兜底 2 项）、`ManagementAuditWriterTxTest.java`（canonical+第 4 段回滚证明）。
`ManagementGuardExecutor` **零改动**（mtime 取证见 R1-16）。

## R1-11. 新增/修改测试数量（§八 25 项对照）

新测试类 23 项 + RegistryTest 扩 2 项 + TxTest 扩 1 项 = **新增 26**；修改 WriterTest 16 项、
TxTest 既有 3 项、RegistryTest 期望表 1 项。§八 逐项映射：
1=R1-单对象成功、2/3=missing/extra、4=batchExact、5/6=batchMissing/Extra、7=batchDuplicate、
8=batchDuplicateAndUnordered（字节稳定）、9=invalidIdForms（含 0/负数/溢出/非十进制）、
10=updateBeforeAfter、11=logicalDeleteSideSetMismatch、12=physicalDeleteCarriesBeforeOnly、
13=physicalDeleteWithFabricatedAfter（+EmptyAffectedIds 共 3 项物理删除专项）、
14/15=snapshotObjectTypeMustEqualRegistryCanonical（中文/表名括注/表名/空/敏感文本/空白 6 例）、
16=renderedObjectTypeAlwaysComesFromRegistry（+leadingZeroObjectId 规范化）、
17=appliedFalse（+revDiverging 共 2 项结果一致性）、18/19=expectFailClosed 统一断言全失败零写入、
20=TxTest.outcomeSnapshotSetMismatchRollsBack…、21=idBindingAndCanonical…OnEveryRow、
22=policyConstructorRejectsMissingMachineFieldsWithoutDefault、
23/24/25=INFRA-ACTOR 32 项（27+5）、Guard 全家（含 Executor 24 幂等/CAS）、
76 条 501 骨架契约测试——全部在全量门禁中零回归。

## R1-12. system 测试实际结果

`mvn -pl futurefab-modules/futurefab-system -am test -o`：**Tests run: 380, Failures: 0,
Errors: 0, Skipped: 0，BUILD SUCCESS**（354 基线 + 26 新增，无回归）。

## R1-13. auth 测试实际结果

`mvn -pl futurefab-auth -am test -o`：**Tests run: 14, Failures: 0, Errors: 0，BUILD SUCCESS**。

## R1-14. git diff --check 结果

通过（exit 0；仅 3 个既有文档的 CRLF→LF 转换提示，均为任务前并行工作区文件，非 R1 修改）。

## R1-15. 是否修改 ManagementGuardExecutor 及原因

**未修改**。R1 校验全部落在 Writer 侧（outcome/ctx 均为只读输入），Hook 签名、守卫时序、
事务模板、CAS、回执语义零变化，测试编译无需改动 Executor（mtime 取证证实 R1 窗口内该文件未动）。

## R1-16. 是否修改数据库结构/Controller/业务 SQL/Vue/客户材料

否。R1 窗口触碰文件恰为审计包 6 main + 4 test + 本报告（mtime 全列表取证）；
未新建表/列/错误码/HTTP 接口；未改 ManagementWriteOutcome 冻结四字段、ActorContext 五字段、
M02、开发基线 SQL、客户只读材料；`git diff --check` 与受保护路径核对通过。

## R1-17. 未执行的真实 MySQL/事务/HTTP 验证

真实 MySQL（回滚留痕、JSON 列、AUTO_INCREMENT 并发回填、锁竞争）、真实 HTTP 全链路、
真实 Redis/网关环境**均未执行**；R1 证明止于"静态检查 + 单元/契约 + 暂存式事务模拟"层。
业务快照的 B-LOC/A-LOC 真实取数（含物理删除前整行读取）待 GUARD-R2/业务接线后验证。

## R1-18. 是否可正式关闭 TASK-INFRA-AUDIT

**可以按 R1 口径正式关闭**（限定：静态/单元/契约/暂存事务层）。初版 P0/P1 三项全部修正并有
专项测试；29/29 机器可执行绑定与 canonical 族闭合；签名、事务、幂等、CAS、回执、ActorContext、
错误码、表结构全部保持任务书 §二 不变式。真实环境验证按 R1-17 如实登记为未完成，不构成回退理由。

## R1-19. 是否可进入 INFRA-GUARD-R2

**可以**（并同步满足此前"待 R2 审阅通过"的串行前置——本条即审计层收口）。R2 所需输入已完备：
冻结 Hook 单方法、八字段上下文、29/29 绑定策略、canonical 域、集合闭环 Writer 与回滚证明；
R2 事项清单不变（B-LOC/A-LOC 快照装配与 AuditIntent 接线、@Log 切面去重裁决，见 §27）。

## R1-20. Git 未提交确认

未执行任何 `git commit`/`git push`/`git reset`/`git checkout`/`git clean`/`git restore`；
R1 全部产出停留在工作区，未提交。

### §十 门禁执行记录（R1 串行）

| # | 检查 | 结果 |
|---|------|------|
| 1 | system -am test | 380/380 BUILD SUCCESS（离线） |
| 2 | auth -am test | 14/14 BUILD SUCCESS |
| 3 | git diff --check | exit 0 |
| 4 | 29/29 ID 绑定 | 注册表内 idBinding 登记恰 29 + RegistryTest 分布断言（22/5/1/1）通过 |
| 5 | 29/29 canonicalObjectType | 注册表内 canonical 登记恰 29 + 9 族全覆盖断言通过 |
| 6 | Writer outcome↔快照严格集合比较存在 | `requireSetEquals` 4 调用点（INSERT/PHYSICAL/UPDATE 两侧），非字符串包含判断 |
| 7 | UPDATE before/after 一致规则 | `validateSnapshotSetClosure` before=after=expected 双断言 + 专项测试 |
| 8 | 物理删除专项测试 | `physicalDelete*` 3 项（成功/伪造 after 失败/空回执失败）通过 |
| 9 | 身份校验全在首条审计 INSERT 前 | Writer L117/L121 校验早于 L123 writeOperLog + 每失败测试两表零写入断言 + TxTest 第 4 段 |
| 10 | Hook 仍唯一同步实现、无独立事务/异步 | `implements ManagementAuditHookR2` 主源码恰 1；audit 包 @Async/@Transactional/REQUIRES_NEW 零命中 |
| 11 | 未改 Controller/业务 SQL/Vue/基线/客户材料/Executor/Outcome | R1 窗口 mtime 文件列表恰 10 个审计包文件 + 本报告 |

---

# R2 修订记录：审计对象 ID 规范化写入一致性收口（任务书 §七 19 点）

## R2-1. R2 是否完成

**完成**。canonical objectId 已收敛为单一函数并在集合比较、before/after 索引、record_id、
JSON 渲染全链路同源；"007"/"7" 割裂写入路径已封死；新增 6 项测试，
串行门禁 **system 386/386、auth 14/14、git diff --check exit 0** 全绿。

## R2-2. 初版问题根因

R1 校验区（`validateSnapshots`/`snapshotIds`/`requireSetEquals`）全部工作在规范化域，
但写入侧 `indexByObjectId` 直接用 `snapshot.getObjectId()` 原始串作 Map key，
且 `AuditValueCodec.sortedDistinctIds` 仅按**原字符串**去重（`requireDecimalId` 不折叠前导零）。
于是 before="007"、after="7"、outcome.id="7" 时：闭环校验通过（两侧规范化后同为 {7}），
写入阶段却得到 `{"007":before快照}` 与 `{"7":after快照}` 两个键，
union 迭代产出 **两条割裂的 sys_data_change_log**（一条 old_data 有值/new_data NULL，
另一条相反），同一业务对象的变更事实被拆成两行。

## R2-3. canonical ID 唯一函数及调用位置

`ManagementAuditWriter#canonicalSnapshotObjectId(String)`（L292-295，
内部即 R1 的 `requirePositiveDecimal`，同一十进制/long 范围/去前导零规则与失败关闭消息），
调用点恰 4 处，全部快照 objectId 消费路径同源：

| 调用点 | 位置 | 用途 |
|--------|------|------|
| `snapshotIds` | L286 | 集合闭环比较（before/after vs expected） |
| `validateSnapshots` | L349 | 同侧规范化重复检测（首条 INSERT 前） |
| `indexByObjectId` | L449 | **写入 Map key（R2 收口点）** |
| `renderSnapshot` | L481 | old_data/new_data JSON 的 objectId 渲染 |

record_id 不再独立取 ID：`writeChangeLogs` 对 canonical key 集合排序后
`Long.parseLong(objectId)`（key 已无/不可能有前导零文本变体）。
outcome 侧 `validateOutcomeBinding`→`requirePositiveDecimal(outcome.id)` 与
`normalizedPositiveIds(affectedIds)` 与本函数共用同一底层规则，比较与写入同域。

## R2-4. indexByObjectId 最终实现

```java
private Map<String, AuditSnapshot> indexByObjectId(List<AuditSnapshot> snapshots)
{
    Map<String, AuditSnapshot> map = new LinkedHashMap<>();
    for (AuditSnapshot snapshot : snapshots)
    {
        String canonicalId = canonicalSnapshotObjectId(snapshot.getObjectId());
        AuditSnapshot previous = map.put(canonicalId, snapshot);
        if (previous != null)
        {
            throw new IllegalStateException("Snapshot 规范化后对象ID重复（如 \"007\" 与 \"7\" 等价），"
                    + "守卫失败关闭: " + canonicalId);
        }
    }
    return map;
}
```

非 writeChangeLogs 外层临时替换字符串；重复检测为纵深防御（正常输入已在
`validateSnapshots` 首条 INSERT 前拦截，写入期键空间已无重复可能）。

## R2-5. before/after 不同文本形式如何合并

两侧索引 key 均为 canonical 值：before="007"→键 "7"，after="7"→键 "7"，
union 集合 `{"7"}` 恰一个元素 → **恰一条** sys_data_change_log，
record_id=7，old_data 与 new_data 都非 NULL，两侧 JSON 的 objectId 均渲染 "7"
（测试 1/2：`updateBeforeLeadingZeroAfterCanonicalMergesIntoOneChangeLog` 及反向，
测试 6：跨侧混合 "007","008" vs "7","8" → 每 canonical ID 恰一条）。
快照输入对象保持不可变，未修改原 `AuditSnapshot`。

## R2-6. 同侧等价重复如何失败关闭

`validateSnapshots` 用 `canonicalSnapshotObjectId` 做 seen 集合判重
（R1 已是规范化域，R2 收敛到同一函数名），before 或 after 同侧 "007"+"7"
在集中校验区（L121-125，先于 L127 writeOperLog / L400 insertManagedOperLog）
抛 `IllegalStateException("…Snapshot 对象ID重复…")`，两审计表零写入尝试
（测试 3/4 各自断言消息与零写入）。

## R2-7. 批量 affectedIds 如何规范化去重

`normalizedPositiveIds`：逐项 `requirePositiveDecimal` → canonical →
`sortedDistinctIds` 去重升序。outcome("007", affected=["007","7","8"]) 规范化为
id="7"、affected=["7","8"]，json_result 承载 `"affectedIds":["7","8"]`，
expected 集合无重复键 → 快照侧每 canonical ID 恰一条变更日志（测试 5）。
ORG18 副作用集、USR10 计数回执的规范化路径同样走该函数，绑定分布未动。

## R2-8. 是否保证每个 canonical ID 恰写一条变化日志

**是**。写入迭代域 = `indexByObjectId(before) ∪ indexByObjectId(after)` 的 canonical key
排序去重集；索引函数对重复 canonical key 失败关闭；闭环校验保证两侧键集各等于
expected（PHYSICAL 时 after 空）。同一业务对象无论输入多少种前导零文本形式，
只存在一个键位 → 恰一行（测试 1/2/5/6 从单对象与批量两维度证明）。

## R2-9. 修改文件清单

| 文件 | 变更 |
|------|------|
| `service/audit/ManagementAuditWriter.java` | 新增 `canonicalSnapshotObjectId`；`indexByObjectId` canonical key + 重复失败关闭；`snapshotIds`/`validateSnapshots`/`renderSnapshot` 改调同一函数；类 Javadoc 增 ⑦ |
| `test/.../audit/ManagementAuditWriterOutcomeClosureTest.java` | 文末新增 R2 §四 6 项测试 + 2 个助手 + 类 Javadoc R2 段 |
| `docs/开发任务/01-契约骨架/24-TASK-INFRA-AUDIT执行报告.md` | 本报告升级 R2（标题、头注、本修订记录） |

mtime 窗口（21:25 后）取证：本任务源码触碰仅上述前两文件；
`ManagementAuditWriterTest.java`/`TxTest`/`AuditPolicyRegistry*` 等 21:02-21:21 文件为 R1 前序交付；
`logs/*.log` 为测试运行产物，非编辑。

## R2-10. 新增/修改测试数

新增 6（ClosureTest：跨侧合并×2、同侧等价重复×2、批量 affectedIds 去重×1、
批量跨侧混合形式×1）；修改 1 文件（该测试类本体）。
ClosureTest 23→29 项。

## R2-11. system 测试结果

`mvn -pl futurefab-modules/futurefab-system -am test`（离线）：
**Tests run: 386, Failures: 0, Errors: 0, Skipped: 0，BUILD SUCCESS**
（基线 380 + 本任务 6，无回归）。

## R2-12. auth 测试结果

`mvn -pl futurefab-auth -am test`（离线）：**Tests run: 14, Failures: 0, Errors: 0，BUILD SUCCESS**，无回归。

## R2-13. git diff --check 结果

exit 0，无空白错误（仅 3 个既有文档 CRLF→LF 转换提示，属任务前并行工作区文件，非本次修改）。

## R2-14. 是否修改 ManagementGuardExecutor 或 29 项策略

否。`git diff --stat` 对 Executor 为空；`AuditIdBinding` 分布（22/5/1/1）、
`AuditObjectType` 9 族 canonical、`AuditDeleteKind`（LOGICAL×5/PHYSICAL×CFG05）
与 29 行注册表映射一律未动（RegistryTest 8 项含分布断言全绿）；Hook 签名不变。

## R2-15. 是否修改 Controller、业务 SQL、数据库结构、Vue 或客户材料

否。未触碰任何 Controller、业务 ApplicationService/Mapper/XML、ActorContext、
M02、Vue、`docs/开发基线/`、客户只读材料；无新表/列/错误码/HTTP 接口。
CFG05 物理删除语义（before 有值/after 空/new_data=NULL）无回归
（`physicalDelete*` 3 项测试保持通过）。

## R2-16. 未执行的真实 MySQL/HTTP 验证

仍未执行（如实登记）：真实 MySQL 下 old_data/new_data JSON 列落盘与
AUTO_INCREMENT oper_id 回填、重复键/锁等待路径、真实回滚留痕；
真实 HTTP 管理写全链路（76 接口仍 501 骨架、intent=null 占位 fail-closed 不变）；
真实并发竞态；Nacos/网关密钥接线。以上均属 GUARD-R2 接线后的联调层验证事项。

## R2-17. 是否可以关闭 TASK-INFRA-AUDIT

**可以关闭**。初版（模型+注册表+唯一 Writer+两表最小写入+同事务语义）、
R1（对象身份闭环）与 R2（canonical 写入一致性）三层缺陷均已收口，
本层遗留事项（B-LOC/A-LOC 装配、@Log 去重裁决）本就归属 INFRA-GUARD-R2，
不构成 AUDIT 层未闭环项。

## R2-18. 是否可以进入 INFRA-GUARD-R2

**可以**。R2 交付后 Writer 对"合法意图"的判定与写入完全类型安全且规范化同源，
intent=null 占位 fail-closed 保证接线前不存在半成品审计路径；
GUARD-R2 工作仍为业务快照装配（B-LOC/A-LOC 查询）与 Executor→Writer 意图贯通。

## R2-19. Git 未提交确认

未执行任何 `git commit`/`git push`/`git reset`/`git checkout`/`git clean`/`git restore`；
R2 全部产出停留在工作区，由用户决定后续处置。

### R2 程序化门禁执行记录（任务书 §六，串行）

| # | 检查 | 结果 |
|---|------|------|
| 1 | system -am test（离线） | 386/386 BUILD SUCCESS |
| 2 | auth -am test（离线） | 14/14 BUILD SUCCESS |
| 3 | git diff --check | exit 0 |
| 4 | indexByObjectId 使用 canonical ID | L449 `canonicalSnapshotObjectId` 作唯一 put key |
| 5 | writeChangeLogs 无原始 objectId 作 Map key 路径 | 主源码 `getObjectId()` 出现点仅 L286/L349/L449/L481，全部包在 canonical 函数内 |
| 6 | before/after 同一 canonical ID 恰一条变化记录 | 测试 1/2/6 + record_id 取自 canonical key 断言 |
| 7 | 重复检测先于 insertManagedOperLog | 校验区 L121-125 < writeOperLog L127 < INSERT L400；测试 3/4 两表零写入尝试 |
| 8 | CFG05/绑定分布/同事务回滚/既有骨架无回归 | `physicalDelete*`、RegistryTest 分布断言、TxTest 4 项、全量 386 绿 |
