# 25-TASK-INFRA-GUARD-R2 执行报告（R2）

- 任务：TASK-INFRA-GUARD-R2——管理守卫、类型化 AuditIntent 与事务时序最终接线；
  **R1 增补：TASK-INFRA-GUARD-R2-R1——修正去重门禁检测盲区与敏感失败日志边界；
  R2 增补：TASK-INFRA-GUARD-R2-R2——关闭 ManagementGuardedWrite 标记位置可绕过问题**
- 执行日期：2026-09-19（R1/R2 同日）
- 基线：PRE-01B-R1 + TASK-INFRA-ACTOR-R2 + TASK-INFRA-AUDIT-R2（三者均已收口）
- 层次声明：本报告全部结论为**单元/契约测试层级**（内存假 Mapper + 暂存式事务管理器），
  未连真实 Redis/MySQL/网关/JWT；不含任何业务 CRUD 实现。
- **R1 头注**：初版 §16/§18 的"Controller 文件出现 ManagementGuardExecutor 字符串即视为
  接线、整文件 @Log 批量收紧"口径**作废**（详见文末 R1 节）。R2 交付的守卫事务时序、
  AuditIntent 接线、Executor/Hook/Port 语义在 R1 中零改动。
- **R2 头注**：R1 的 `ManagementGuardedWriteArchTest` 只校验标记方法的 @Log 三属性、
  未校验标记位置，存在"ApplicationService 误标 + Controller 漏标 + 默认 @Log 保留"
  绕过路径；R2 补上"标记仅限 Controller（类级 @RestController/等价 @Controller
  反射判定）"结构化门禁（详见文末 R2 节）。R1-7 中 fixture 场景 7 的表述一并更正：
  该对端服务仅持有 Executor 类型引用、未调用 execute(...)，不构成真实守卫调用链证明。

---

## 1. 完成判定

任务书 §十五 九项条件全部满足（详见各节）：回调唯一签名、R2 类型化结果、Executor 传真实
intent、intent=null 生产占位 0 处、Hook 先于 CAS 先于回执、三类回滚、重放零副作用、
@Log 通用开关、全部门禁绿。**INFRA-GUARD-R2 判定：完成（单元/契约层级）。**

## 2. 编码前 20 项取证（以当时磁盘源码为准）

| # | 取证项 | 结论（修改前） |
|---|--------|----------------|
| 1 | Executor 完整时序 | resolveTrustedActor→Tx→锁SYSTEM→回执判定→版本校验→溢出检查→callback→validateOutcome→Hook(intent=null)→CAS→回执→提交→回填 |
| 2 | ActorContext 解析位置 | `resolveTrustedActor`（原 L140），事务开启之前，Port 单次解析 |
| 3 | Tx 开启 | TransactionTemplate.execute（原 L148），单事务包裹锁/回调/审计/CAS/回执 |
| 4 | SYSTEM 锁 | `selectRevisionForUpdate`（原 L203），事务内第一取锁点 |
| 5 | 回执判断 | `selectReceipt`（原 L228）：过期 409 / 四元组冲突 409 / 一致重放 return |
| 6 | callback 执行 | 原 L258 `callback.execute(actorUserId)`，版本校验通过之后 |
| 7 | outcome 校验与 revision 回填 | validateOutcome（原 L259）+ `setManagementRevision(newRevision)`（原 L260） |
| 8 | Hook 调用 | 原 L262-266，`new AuditWriteContext(..., intent=null 占位, ...)`，为全仓唯一 null 占位 |
| 9 | CAS | `increaseRevision`（原 L267），Hook 之后 |
| 10 | 回执写入 | `insertReceipt`（原 L272），CAS 之后、提交之前 |
| 11 | committed 回填 | 提交后 `RequestMetadataContext.putCommittedManagementRevision`（原 L160），重放同样回填 |
| 12 | intent=null 位置 | 唯一 1 处：Executor 原 L262-266（含 2 行占位注释） |
| 13 | Callback 物理签名与调用点 | `ManagementWriteOutcome execute(Long actorUserId)`；生产调用点=0（仅 Executor 定义）；测试调用点：ExecutorTest≈40 lambda、WiringTest 3、TxTest 1 |
| 14 | 两套结果模型职责 | GuardExecutionResult（outcome+replayed，守卫→应用层）；ManagementWriteOutcome（§17.1 冻结四字段，回执 JSON 载体）——均保留 |
| 15 | 29 Controller @Log 分布 | 29 个管理写对应 Controller 方法**全部无 @Log**（骨架期已摘除）；M01 十控制器残留 22 处 @Log 全挂未接守卫 legacy 方法；全仓控制器 @Log 共 120 处 |
| 16 | LogAspect 时机 | @Before 存 TIME_THREADLOCAL → @AfterReturning/@AfterThrowing 共走 handleLog（try/catch 吞异常 + finally remove）→ asyncLogService.saveSysLog(@Async) |
| 17 | 生产调用点存在性 | 无任何业务代码调用 `ManagementGuardExecutor.execute`（grep 证实）→ 本任务只迁移基础设施与测试，未创建假业务服务 |
| 18 | 第二套结果/回调模型 | 全仓主源码 grep：ManagementWriteOutcome/GuardExecutionResult/ManagementGuardCallback 各仅 guard 包一处定义，无平行模型 |
| 19 | 生产 Bean 唯一性 | `implements ActorContextPort`=1（M01ActorContextAdapter）、`implements ManagementAuditHookR2`=1（ManagementAuditWriter）、Executor 类定义=1；已由 GuardR2WiringContractTest 类路径扫描锁定 |
| 20 | 依赖旧签名的测试 | 即 #13 所列 3 个测试文件 + AuditLeakGuardMockTest（直调 Writer 构造 null-intent ctx，属旁路最后防线证明，保留）；common-log 模块无 src/test、pom 无 junit → @Log 测试落 system 模块 |

## 3. GuardExecutionResultR2 字段（§五）

`service/guard/GuardExecutionResultR2.java`（新增）：final 类；仅两字段
`ManagementWriteOutcome outcome` + `AuditIntent auditIntent`，private final、构造器 null
即 IllegalArgumentException 失败关闭、无 setter、无 Map/Object/Entity 载体、不含第二份
managementRevision（仍只能守卫生成）、不含 ActorContext/sessionKey/JWT/Token。
类 Javadoc 明示不得用作 Controller 响应。形态由反射测试精确锁定（§11 项 1）。

## 4. Callback 收敛（§六）

`ManagementGuardCallback` 唯一签名 `GuardExecutionResultR2 execute(ActorContext actorContext)`，
旧 `ManagementWriteOutcome execute(Long)` 已删除，无双载共存（反射测试：getDeclaredMethods()
长度==1 且参数为 ActorContext）。回调取得与 Executor 同一 ActorContext 实例（assertSame 证明），
Javadoc 冻结"只读、不得二次解析 Port、浏览器自报 actor 无效"。全部测试调用点已迁移。

## 5. Executor 时序对照（§四冻结 20 步）

实现后链路：Actor 解析（事务前）→ Tx → 锁 SYSTEM → 回执判定（过期/冲突/重放）→ 期望版本校验 →
溢出检查 → callback(B-LOC→业务写→A-LOC→组装 outcome→组装类型化 AuditIntent，归后续业务包) →
Executor 校验回调结果与 intent 非空 → 回填 outcome.managementRevision → 构造 AuditWriteContext
（真实 intent）→ 同事务 Hook → CAS → 回执 → 提交 → RequestMetadataContext 回填 →
返回 GuardExecutionResult。重放直接返回原回执，不执行回调/Hook/CAS/回执。
与任务书唯一差异（沿 R1 已登记）：溢出检查实测位于回执判定之前，仍满足"先于业务回调"，未改动。
审计未移到 CAS 或回执之后（callIndexOf 断言：auditHook < increaseRevision < insertReceipt < txCommit）。

## 6. Actor 单次解析证明

`callbackReceivesSameActorContextInstanceAndPortResolvesOnce`：Port 计数器 execute 前后恰为 1；
回调内 assertSame(Port 返回实例, 回调入参)，且回调执行时刻计数已为 1——回调无法也不需要
二次解析（回调签名不暴露 Port）。WiringTest 另证生产适配器链路解析失败发生在守卫零 DB 调用前。

## 7. intent 传递链

回调 `new GuardExecutionResultR2(outcome, intent)` → Executor `requireCallbackResult`
三重非空校验 → `new AuditWriteContext(..., auditIntent, ...)` → Hook。
`auditContextCarriesTrustedFieldsAndTypedIntent` assertSame 证明原样传递（不复制、不篡改）；
TxTest `typedIntentFromCallbackCommitsThroughProductionWriterInGuardTx` 证明生产 Writer
接受注册表合法意图并同事务落主记录+变更明细（operId 关联）。

## 8. intent=null 占位删除（§七）

原 Executor L262-266 占位与其注释已彻底删除。程序化检查：生产主源码 `intent = null`
赋值 0 处（Writer/Executor 的 `intent == null` 防御判断为比较，非赋值）。
AuditWriteContext Javadoc 同步为"R2 起守卫链路必传类型化意图，null 校验保留为旁路最后防线"。

## 9. 校验规则（§七 20 条要点）

Executor 新增防御校验：callbackResult null → ISE；outcome null → ISE；auditIntent null → ISE；
validateOutcome 保留 applied=true、managementRevision 必须 null（守卫唯一生成）、
id/affectedIds 十进制合法（非法 → INPUT_INVALID 回滚）。Hook 异常不捕获、直接上抛整体回滚。
幂等四元组、HMAC envelope、过期 requestId 规则、MANAGEMENT_BUSY 捕获范围
（PessimisticLockingFailureException|QueryTimeoutException）、24h 语义、SYSTEM 锁顺序零改动
（git diff 证实 NormalizedPayloadHasher/ManagementGuardConfig/回执实体未触碰）。

## 10. Hook-CAS-回执顺序

`happyPathQuadrupleCasAuditAndReceiptInOneTx`：txBegin < selectRevisionForUpdate < auditHook <
increaseRevision < insertReceipt < txCommit（测试基设 calls 序列断言）。

## 11. 三类回滚证明

1) 回调异常/伪成功（null/applied=false/预填版本/非法ID）→ txRollback、revision 不动、零回执、
零 Hook（auditHook 调用点为 0 断言）；2) Hook 失败（含生产 Writer 伪造标题失败关闭）→
revision/回执/审计整体回滚且 CAS 未触达；3) TxTest 段2/段4：审计中途失败与集合闭环不一致
均在首条 INSERT 前后失败关闭、暂存事务回滚。真实 MySQL 回滚未运行（见 24 节）。

## 12. 重放零副作用

replay 测试 secondRun calls 不含 increaseRevision/insertReceipt/auditHook；
callbackRan 布尔证明回调零执行（B-LOC/A-LOC 快照查询随回调归零）；auditSeen 清空后仍 0；
payload/版本冲突/过期/锁失败路径同证零回调零 Hook。

## 13. 冲突/过期/锁行为（§十 10 条）

MANAGEMENT_CONFLICT（回调前拒绝、回调零执行）、REQUEST_CONFLICT（改码/改载荷/过期重传，
过期回执不删不重放不覆盖、消息指引新 requestId）、24h 边界（前一秒可重放/整点即 409）、
BUSY(503,retryable,"提交结果未知"、禁"未生效"字样)、Long.MAX_VALUE 溢出先于回调——
全部沿 R1 测试迁移后保持绿。

## 14. 四元组/HMAC 无回归

回执 JSON 冻结四字段测试（resultJsonContainsExactlyFrozenFields）+ R2 增补
"auditIntent 不得进入回执 JSON"断言；NormalizedPayloadHasherTest 13 项无改动全绿。

## 15. @Log 最终方案（§九 方案A）

`@Log` 新增通用属性 `recordSuccess`，**默认 true（既有 120 处注解语义零变化）**；
LogAspect 在 handleLog 入口对"正常返回 + recordSuccess=false"短路（不落异步成功日志），
异常路径不受开关影响仍记录；短路仍经 finally 清理 TIME_THREADLOCAL（测试反射断言无残留）。
common-log 未新增任何对 system 业务包的 import（程序化 grep=0，system.api 领域类沿旧许）；
无 URL 硬编码、无 ThreadLocal 新用法。未按 URL/类名特判，纯注解声明式。

## 16. 29 接口是否已启用去重及原因

**未启用，机制已具备，逐业务接入时启用。** 取证（§2 项 13/15/17）：29 个管理写 Controller
方法骨架期即无 @Log，且当前无任何生产代码调用 Executor——不存在"保持异步成功日志开启"
的已接线方法，去重无可启对象。本任务不批量改 Controller 注解（任务书禁止）。
契约测试 `controllersWiredToGuardExecutorMustNotKeepAsyncSuccessLogging` 预先锁定：
任何 Controller 源文件一旦引用 ManagementGuardExecutor，其 @Log 必须显式
recordSuccess=false，未来接入时自动强制。

## 17. 生产文件清单（6）

1. service/guard/GuardExecutionResultR2.java（新增）
2. service/guard/ManagementGuardCallback.java（签名收敛）
3. service/guard/ManagementGuardExecutor.java（接线：同实例传递、三重校验、真实 intent、删占位、Javadoc）
4. service/audit/model/AuditWriteContext.java（仅 Javadoc 同步）
5. service/audit/ManagementAuditWriter.java（仅 2 处注释/异常消息措辞，逻辑零改动——单列声明见 19）
6. common-log：annotation/Log.java + aspect/LogAspect.java（recordSuccess 通用开关）

## 18. 测试文件清单（5）

1. ManagementGuardExecutorTest.java（24→27 项：全部迁移新签名；null-intent 测试反转为
typed-intent assertSame；新增 R2 同实例/单次解析、回调唯一签名、ResultR2 构造防御 3 项）
2. M01ActorContextGuardWiringTest.java（3 处回调迁移）
3. ManagementAuditWriterTxTest.java（4→5 项：第 1 段改写为守卫链+生产 Writer 伪造标题回滚，
新增合法意图全绿提交段）
4. GuardR2WiringContractTest.java（新增 5 项：intent=null 赋值 0 处、Executor 接线源码扫描、
ResultR2 精确形态、Port/Hook/Executor 实现恰一、@Log 接线契约）
5. LogRecordSuccessDedupContractTest.java（新增 4 项：默认值 true、三态行为、ThreadLocal 无残留）

## 19. 是否修改 Writer 或 29 策略

Writer：**未改任何逻辑**。仅 2 处注释/Javadoc 与 1 条异常消息措辞（"尚未装配（接线事项）"→
"R2 链路必传、缺失即旁路调用"），属接线后语义同步，防陈旧文档误导；单列于此以透明。
AuditPolicyRegistry/29 策略/值规范化组件：零改动（AuditPolicyRegistryTest 30 项、
ManagementAuditWriterOutcomeClosureTest 29 项无回归）。

## 20. 是否修改 Controller / 501 骨架 / 业务服务 / SQL / 前端 / 客户材料

全部未修改：git status 证实本任务改动文件仅 §17/§18 清单；零 Controller、零 501 转真实业务、
零假业务服务、零库表/基线 SQL、零 Vue、零客户只读材料；回执 JSON 结构、错误码枚举
（FutureFabErrorCode diff=0）、ManagementGuardConfig、NormalizedPayloadHasher 均未触碰。

## 21. 测试数

定向 R2 五组 = **44/44 绿**（Executor 27 + Wiring 3 + Tx 5 + R2Contract 5 + Log 4）；
system 全量 **399/399 绿**（基线 386 + 净增 13）；auth **14/14 绿**。

## 22. 两模块结果（串行）

`mvn -pl futurefab-modules/futurefab-system -am test -o`：BUILD SUCCESS（399 项 0 失败 0 错误）；
`mvn -pl futurefab-auth -am test -o`：BUILD SUCCESS（14 项）。日志中适配器 ERROR 行为
fail-closed 测试的预期输出。无 Maven 环境失败。

## 23. git diff --check

exit 0，无空白错误。

## 24. 未运行的真实验证（不得宣称完成）

- 真实 MySQL：守卫单事务（锁/CAS/回滚原子性）、审计落库、回执持久化
- 真实 Redis/网关/JWT：ActorContext 端到端解析、会话替换 401 链路
- 真实 Feign：AsyncLogService→remoteLogService 的 recordSuccess 短路后端到端行为
- 容器装配：@Component/@Autowired 生产上下文启动验证（架构测试锁形，非启动验证）
- @Log 逐业务启用：属未来业务包接入守卫时事项
以上均只能报告到"单元/契约测试通过"层。

## 25. 剩余阻塞项

无本任务范围阻塞。登记事项：① 76 个 501 骨架等待逐业务包接线（B-LOC/A-LOC 查询实现归业务包）；
② @Log 去重启用随业务接线发生；③ 过期回执物理清理调度仍未建（沿 R1 边界，非本任务）。

## 26-27. 可否开始第一个业务包 / 推荐包及理由

**可以**。三条基础设施链（ACTOR/AUDIT/GUARD-R2）已全部收口且互证接线闭合。
推荐 **M01 ORG02（新增场地 Venue）**：注册表/快照/ID 绑定策略已有 TxTest 级合法意图样板
（VENUE 域最小、单对象 INSERT、before=空列表），29 Controller 骨架与 WriteMeta 通道就绪，
可在最小面上完成 B-LOC/A-LOC→outcome→intent 的首个生产闭环。

## 28. Git 未提交确认

未执行任何 git add/commit/push/reset/checkout/restore/clean；全部改动保留在工作区；
未触碰其他会话的 `_tmp_*` 文件与客户只读材料。

## 29. §八 Executor 禁项合规

新增代码未引入：查业务表、按 outcome 猜快照、DTO 反射生成审计、Map/Entity 审计输入通道、
修改 intent、补造 before/after、空快照默认降级——Executor 仅原样透传 intent；
快照/标题校验全部在 Writer 冻结语义内（既有测试无回归）。

## 30. 设计文档与记忆同步

本报告即 §十二 允许新建的过程文档；未修订活跃设计文档（实现与 §1.5/§六/§九 冻结口径一致，
无需勘误）；项目记忆已更新 GUARD-R2 完成状态。

## 31. 结论分层

- 文档/静态检查：通过（取证表 §2、程序化检查全 0 违规）
- 编译：system/common-log 主源码 + 测试源码通过
- 单元/契约测试：44（定向）+ 399（system 全量）+ 14（auth）全部通过
- SQL 执行 / HTTP 联调 / 外部系统 / 现场验收：**未运行**，不作任何宣称

---

# R1 节：TASK-INFRA-GUARD-R2-R1 修正去重门禁检测盲区与敏感失败日志边界

## R1-1. R1 是否完成

**完成**。P0（文件级扫描漏检）、P1×2（误伤 legacy 方法 / recordSuccess=false 失败面仍序列化请求响应原文）三项缺陷全部收口，未实现任何真实业务。

## R1-2. 原门禁为何漏检（作废口径登记）

初版 `GuardR2WiringContractTest.controllersWiredToGuardExecutorMustNotKeepAsyncSuccessLogging` 以"Controller 源文件是否 `contains("ManagementGuardExecutor")` 字符串"判定接线，与冻结分层 **Controller → ApplicationService → ManagementGuardExecutor** 直接冲突：真实接线时 Executor 引用封装在 ApplicationService 层，Controller 文件零命中 → 门禁**空转漏检**；且一旦命中即以整文件为单位要求全部 `@Log` 含 `recordSuccess=false` → **误伤同文件未接守卫的 legacy 方法**；逐行 `indexOf` 截断注解文本也构成"截断注解"脆弱判定。该测试与"Controller引用Executor即接线"口径（原 §16 契约测试预锁、§18 第⑤项）**一并作废**。

## R1-3. 最终方法级机制

- 新增生产标记注解 `com.futurefab.system.service.guard.ManagementGuardedWrite`：`@Target(METHOD)`、`@Retention(RUNTIME)`、**零成员**（不携带业务数据），仅标注 Controller 管理写方法；放在 system 守卫包内，不引入反向依赖。
- 新增架构测试 `com.futurefab.system.contract.ManagementGuardedWriteArchTest`（10 项）：Spring 类路径扫描**候选枚举** + 运行时反射（`Method#isAnnotationPresent`/`getAnnotation(Log.class)` 读属性**实际值**）做判定；核心规则零依赖源码字符串。Spring 无方法级 TypeFilter，候选枚举用 include-all TypeFilter 后反射定位，判据仍是方法注解事实（防降级断言见 R1-9 附加项"扫描器防空转"）。
- 接线判据=方法注解；禁止 URL/文件字符串扫描判接线（任务书 §二-⑤⑥⑦ 全部满足）。

## R1-4. 三属性规则（冻结）

被 `@ManagementGuardedWrite` 标记的方法若同时标注 `@Log`，必须**同时**：`recordSuccess=false` ∧ `isSaveRequestData=false` ∧ `isSaveResponseData=false`。语义：同事务类型化审计是成功管理写的唯一权威审计（§二-⑧）；异步 `@Log` 通道只保留失败日志，且失败日志不得序列化请求参数（operParam）/响应结果（jsonResult）原文——收口 P1 敏感失败面（`isSaveRequestData/isSaveResponseData` 在异常路径同样生效，见 R1-6）。注解无 @Log 直接放行。后续业务包接入规范：Controller 方法加标记 + 上述三属性组合，一次性通过门禁。

## R1-5. legacy 行为不受影响

未标记方法的 `@Log` 语义零变化：默认与显式 `recordSuccess=true` 成功照常记、失败照常记、请求/响应照常序列化（`LogRecordSuccessDedupContractTest` 新增/强化用例证明）。禁止文件级批量关闭由 `legacyMethodInMixedClassIsNotCollaterallyFlagged`（同 Controller 守卫+legacy 混合法通过）锁定。

## R1-6. 敏感失败日志边界证明（§五-9/10）

- `threeFlagsOffFailureLogPersistsNoRequestOrResponsePayload`：三属性 false 的失败日志**仍落库**（status=FAIL、errorMsg 保留定位信息），但 `operParam=null` ∧ `jsonResult=null`。
- `legacyDefaultFailureLogStillSerializesRequestDataUnaffected`：legacy 默认注解失败日志仍含请求参数序列化——证明收紧只作用于标记方法，切面对未标记入口零波及。

## R1-7. 是否仍要求 Controller 引用 Executor

**否**。且新增**反向分层护栏**：`productionControllersDoNotReferenceGuardExecutorDirectly` 断言生产 Controller 源码零出现 `ManagementGuardExecutor`（该检查只防"为过门禁直连执行器"的架构越界，**不是接线判据**；接线判据唯一为方法注解）。fixture 场景 7（`DelegatingController` 零引用执行器、`GuardUsingApplicationService` 持有 Executor 字段）证明：方法级判据在 Controller 文件零命中的真实分层下仍精确命中接线方法，而字符串判据在该场景必然漏检。

## R1-8. 修改文件清单（R1 全部 5 个）

| 文件 | 动作 |
|---|---|
| `service/guard/ManagementGuardedWrite.java` | 新增（生产，纯标记注解） |
| `test: service/guard/GuardR2WiringContractTest.java` | 删 1 项文件级 contains 测试（5→4），Javadoc 登记作废 |
| `test: futurefab/guardr2/fixture/GuardedWriteFixtures.java` | 新增（7 组合法/非法样板；故意放 `com.futurefab.system` 之外防生产扫描污染） |
| `test: contract/ManagementGuardedWriteArchTest.java` | 新增（10 项反射/结构化门禁测试） |
| `test: contract/LogRecordSuccessDedupContractTest.java` | 增 2 项 + 强化默认用例断言（4→6） |

生产改动仅此 1 个新注解文件；Executor/Hook/Port/Writer/模型/logback/守卫时序**零改动**（§二-⑨）。

## R1-9. 新增测试场景 ↔ 任务书 §五 12 项映射

①标记+无@Log 允许 ②三属性false 允许 ③recordSuccess 默认 true 拒 ④isSaveRequestData=true 拒 ⑤isSaveResponseData=true 拒 ⑥同Controller混合法不误伤 ⑦分层接线（Controller 零引用）仍方法级可识别 ⑧recordSuccess=false 成功不落异步日志（既有用例回归） ⑨失败仍写且 operParam/jsonResult 均空 ⑩默认与显式 true legacy 行为不变（成功+失败两用例） ⑪TIME_THREADLOCAL 成功短路与异常路径均清理（既有用例+新增用例双断言） ⑫Executor/Hook/Port 唯一性无回归（GuardR2WiringContractTest 4/4 绿）。附加：注解形态反射（METHOD/RUNTIME/零成员）、生产标记方法零违规+扫描器防空转、Controller 分层护栏。**共 12 新增用例（ArchTest 10 + Dedup 2），核心属性规则全部反射读取实际值。**

## R1-10. 门禁结果（R1 重跑）

| 检查 | 结果 |
|---|---|
| system 全量（`-pl futurefab-modules/futurefab-system -am test -o`） | **410/410**（399 −1 作废文件级 +10 ArchTest +2 Dedup） |
| auth 全量 | **14/14** |
| `git diff --check` | exit 0 |
| 旧门禁残留（`controllersWiredToGuardExecutor`/`contains("ManagementGuardExecutor")` 于测试源码） | 0 |
| 生产 `@ManagementGuardedWrite` 标记方法数 | 0（骨架未接业务，符合预期；检测有效性由 fixture 证明） |
| Mapper XML / 基线 SQL / futurefab-ui / 客户只读材料 git 改动 | 0 |

## R1-11. 未运行环境验证（不变）

真实 MySQL/Redis/HTTP/网关/并发/现场验收一律未执行；"接守卫的管理写"生产调用点仍为零，三属性规则当前为**预锁门禁**，首个业务包接线时自动生效。

## R1-12. 可否关闭 GUARD-R2 进入首个业务包

**可以**。R1 关闭后 GUARD-R2 三层（初版/R1）门禁缺陷清零：去重机制具备**方法级、反射判定、失败面脱敏、legacy 零波及**四项性质；后续以 ORG02（新增场地 Venue）为首个业务包，按 R1-4 接入规范落地首个生产标记方法。

---

# R2 节：TASK-INFRA-GUARD-R2-R2 关闭标记位置可绕过问题

## R2-1. R1 已解决与 R2 补上的维度

R1 已解决：文件级 contains 判据的漏检/误伤（作废登记见 R1-2）与 @Log 三属性失败面脱敏（R1-4/R1-6）。R1 遗留缺陷：契约声明"仅允许标注 Controller 方法"仅写在 Javadoc，架构测试未验证标记方法所属类是否为真实 Controller——声明与门禁脱节。

## R2-2. 原绕过路径（任务书 §一）

① ApplicationService 方法误加 `@ManagementGuardedWrite`；② 对应 Controller 方法不加标记；③ Controller 保留默认 `@Log`；④ R1 生产扫描只对"标记方法"检查三属性，未标记的 Controller 默认 @Log 完全合法 → 扫描空转通过，重复成功审计与失败参数泄漏门禁被绕过。R2 后：标记一旦落在非 Controller 类即计违规（位置门禁），误标不能替代正标；漏标场景由"业务包接线必须让标记命中真实 @RestController 方法"的接入规范（R1-4）+ 本位置门禁共同封堵。

## R2-3. Controller 结构化判定方式

`isControllerStereotyped(Class)`：`type.isAnnotationPresent(RestController.class) || type.isAnnotationPresent(Controller.class)`——纯类注解运行时反射事实。项目取证：生产 89/89 Controller 均 @RestController、零裸 @Controller；@Controller 作为等价 Spring Controller 元注解一并接受（fixture 场景 10 证明放行）。禁止且已证伪的判据：类名含 "Controller"（fixture `FakeControllerNameOnly` 名称命中、注解未命中 → 必拒，测试 `controllerNameWithoutStereotypeIsStillRejected`）、目录名、源码字符串。

## R2-4. 非 Controller 标记的拒绝与违规信息

`illegalMarkedMethods` 升级为两维校验（位置 + 三属性），位置违规消息格式：
`类全名#方法名：ManagementGuardedWrite 只能标注 Controller 方法（类无 @RestController/@Controller 结构事实）`。
fixture 场景 8（普通类）、场景 9（ApplicationService，绕过路径原型）各产生恰一条含类名+方法名+原因的违规；生产扫描测试更名为 `productionMarkedMethodsSatisfyPositionAndLogAttributeGates`，对全部生产标记类同时校验两维。

## R2-5. fixture 实际证明范围（如实收口）

场景 7 对端服务更名为 `ApplicationServiceHoldingExecutorType`：只持有 `ManagementGuardExecutor` 类型字段、**未调用 execute(...)**。其证明范围=「Executor 类型引用位于下层时，方法级判据仍精确命中 @RestController 标记方法；文件级 contains 判据在此漏检」；**不证明真实守卫调用链**（初版 R1-7 "接线藏在 ApplicationService"的措辞已更正）。测试名改为 `delegatingControllerMarkerIsIdentifiedWithoutExecutorReference`。真实接线闭环（Controller→ApplicationService→Executor.execute 实调用）由首个业务包 ORG02 落地时验证。

## R2-6. 当前生产标记数量与口径边界

生产 `@ManagementGuardedWrite` 标记方法 **0** 处（grep 复核=0）。据此：位置+三属性门禁当前均为**预锁机制**，只宣称"门禁机制已建立且经 fixture 反例证明检测有效"，不宣称任何真实业务调用链已验证（任务书 §三-8）。

## R2-7. 修改文件清单（R2 全部 4 个）

| 文件 | 动作 |
|---|---|
| `service/guard/ManagementGuardedWrite.java` | 仅 Javadoc：位置约束与 R2 结构化判定登记（METHOD/RUNTIME/零成员形态不变） |
| `test: futurefab/guardr2/fixture/GuardedWriteFixtures.java` | 7 组 Controller 形态样板补类级 @RestController；服务样板更名+证明范围注释；新增场景 8-11（普通类/ApplicationService/裸@Controller/伪名） |
| `test: contract/ManagementGuardedWriteArchTest.java` | 校验器升级两维；新增 4 项位置测试；2 项更名；10→14 |
| 本报告 | 标题升 R2 + 头注 + 本 R2 节 |

LogAspect、ManagementGuardExecutor、幂等/CAS/审计/回执事务核心、@Log 注解属性、legacy 语义：**零修改**（mtime 取证：Executor 21:51/LogAspect 21:53 均早于本轮全部编辑 22:5x；本轮 git 改动仅上表文件）。

## R2-8. 门禁结果（R2 重跑）

| 检查 | 结果 |
|---|---|
| system 全量 | **414/414**（410 + ArchTest 4 项新增） |
| auth 全量 | **14/14** |
| `git diff --check` | exit 0 |
| ArchTest 定向 | 14/14（含非 Controller 必拒×3、@Controller 等价放行×1、生产双维扫描×1） |
| 生产 Controller 直接引用 ManagementGuardExecutor | 0（分层护栏测试持续绿） |
| 生产 @ManagementGuardedWrite 标记数 | 0（预锁，不伪称业务链已验证） |
| Mapper XML / 基线 SQL / futurefab-ui / 客户只读材料 git 改动 | 0 |
| 76 条 501 骨架回归 | 全绿（全量 suite 内含 6 个 SkeletonContractTest） |

## R2-9. 未运行环境验证（不变）

真实 MySQL/Redis/HTTP/网关/并发/现场验收一律未执行；异步 @Log 端到端落库、审计两表真实写入仍属后续联调事项。

## R2-10. GUARD-R2 基础设施关闭条件与 ORG02 接入条件

**GUARD-R2 四层（初版/R1/R2）缺陷清零，基础设施可关闭**：去重门禁现已具备方法级判定、位置限定 Controller、三属性失败面脱敏、legacy 零波及、fixture 反例防空转五项性质。**ORG02 接入条件**：① Controller 管理写方法标 `@ManagementGuardedWrite` + @Log 三属性 false 组合（报告 R1-4 规范）；② ApplicationService 内实调 `ManagementGuardExecutor.execute`，回调返回 outcome+类型化 AuditIntent（VENUE/新增 单对象 before=空列表样板已在 TxTest 存在）；③ B-LOC/A-LOC 真实查询实现归业务包。首个生产标记方法落地时，本预锁门禁自动转为实检。
