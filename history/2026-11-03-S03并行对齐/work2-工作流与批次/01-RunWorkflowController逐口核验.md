# RunWorkflowController 逐口核验（15 个 handler）

日期：2026-11-03。核验 HEAD：`8e7cd9267f71cd69f021f49c0fd6ee505dfbdbf3`。
性质：**静态源码核验**。不是 HTTP、数据库或设备验证。
身份：`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/run/RunWorkflowController.java::com.futurefab.system.controller.run.RunWorkflowController`
类级映射：`@RequestMapping("/run/workflows")`（`:39`）。`/run/**` 网关直通，外部路径与表内路径相同。
计数口径：**15 个 handler，15 条路由行**，与 `03-M07逐口核验状态与样例证据.md` §3.1 第 46—60 行一一对应，不新增接口。

## 0. 一页结论

| 分组 | 口数 | 已核到 | 一句话结论 |
|---|---|---|---|
| 契约 022 候选 | 1 | B／C／D（E 未达语句级） | 按 `subflowCode` 八路分派，W06 无候选口；末段 W03／W07／W05 共用一条平台链。候选 Port 与 `countActiveChannel` 的 SQL 本轮未展开 |
| 契约 023 启动 | 1 | B／C／D（E 未达语句级） | 按 `subflowCode` 十路分派；每个子流程一套独立守卫码与载荷；W02／W03／W08 各自转出。十路下游启动的内部与写入语句本轮未展开 |
| 契约 024 详情 | 1 | B／C／D／E | 先判「是否开始培养实例」，否则通用详情；通用详情按子流程追加五类上下文投影 |
| 契约 025 步骤 | 1 | B／C／D（E 未达语句级） | 三层分派（Controller／服务层／`updateW03Step`），批次成员与单实例走不同守卫码。写入语句 XML 与 `completeW03Connection` 写入集未展开 |
| 契约 026 操作 | 1 | B／C／D／E | **真实设备链上 `SET_AUTO` 分支当前固定拒绝**；可用操作只剩 `PRIME_START`／`PRIME_STOP`，且仅 W03／W07；开始培养实例在 Controller 层被拒。`run_command` 三条语句只到接口级 |
| 契约 027 取消 | 1 | B／C／D／E | 按子流程九路分派；W03／W07／W08 走资源守卫，直连取消与安全收尾两分支 |
| 小试结束培养 bench-end | 6 | 5 口 B／C／D／E；`bench-end-reasons` 为 B／C／D（E 只到 Port 类声明行） | 后端调用链已定位，**页面 0 引用**（页面走本页 Mock）。**设计明确不要求前端的只有停稳状态与停稳确认两口**（`小试结束培养接口契约.md:50` 的「最后两个接口」）；其余四口的逐口前端范围未核，见 `03-…md` §5 N-01 |
| 选择器 | 2 | B／C／D（E 未达语句级） | `sampling-slots` 只服务 W06；`room-options` 白名单四个子流程，不含 W03／W07／W08。两口的 M01／M02 适配器正文本轮未打开 |
| 开始培养会话恢复 SC-HTTP05 | 1 | B／C／D／E | 唯一 `write=true` 的读口：恢复时必须过会话归属人校验 |
| **合计** | **15** | **B15／C15／D15／E9** | E 未达语句级的 6 口：022、023、025、`bench-end-reasons`、`sampling-slots`、`room-options`（逐口依据见 `03-…md` §6.0.1） |

**「已核到」列的读法**：B／C／D 成立表示调用关系、正常分支与关键拒绝都实际读过；**E 只在本轮打开了 XML 语句正文或生产实现类内部实现行时才记 Y**，仅定位到 Port／实现类的类声明行不算。C 为 Y **不代表该口的每个分支都有成功路径**——026 的 `SET_AUTO` 与开始培养实例两个分支当前固定拒绝（§14），该事实单独登记，不并入「实现度」。

**本批未核（全部 15 口共有）**：响应字段与设计 `respFields` 逐项比对、行级数据范围实测、运行期行为。逐口另有专项 F，写在各自小节。

## 1. `benchEndReasonOptions` — GET `/run/workflows/bench-end-reasons`

| 项 | 值 |
|---|---|
| Controller | `:62`—`:67`：`@RequiresPermissions("run:workflow:query")`、`@CurrentManagementRevision`，方法体单行 `success(benchEndReasons.options())` |
| 设计位置 | `小试结束培养接口契约.md:45`（返回 `data:[{id, reason}]`，只返回启用项，带顶层 `managementRevision`）；`接口目录与契约定位.md:16`（2026-11-02 复判：专题 `line 45` 已含完整参数／响应／判权链） |
| 应用服务 | `service/application/m07/BenchEndCultureReasonService.java:23`—`:30` |
| 消费者 | **无 SDK、无页面**（见 `00-…md` §5） |

正常路径：

1. `:24` 调 `FormCandidateFactsPort#loadDictionaryCandidates(new DictionaryCandidateQuery(RequestMetadataContext.getRequestId(), "bench_end_culture_reason", false))`。第三个参数 `false` 的具体含义（是否包含停用项）来自 `DictionaryCandidateQuery` 定义，**本轮未逐字段读该 record 的组件顺序**，只确认传的是常量 `false`。
2. `:26` `facts == null` 或 `!facts.isAvailable()` → `FACTS_UNAVAILABLE`（HTTP 503）「常用异常结束原因暂不可读取」。
3. `:28`—`:29` 过滤 `!item.isDisabled()`，映射为 `ReasonOption(dictCode, label)`。
4. 无写库、无事务、无守卫。字典来源在 M01，本模块不维护选项。

语句与 Port：

| 调用点 | 类型 | 实现 |
|---|---|---|
| `:24` | Port | `service/impl/port/m01/M01FormCandidateFactsAdapter.java:74`（`implements FormCandidateFactsPort`） |

关键拒绝：

| # | 条件 | 位置 | 结果 |
|---|---|---|---|
| 1 | 字典来源不可用（null 或 `isAvailable()=false`） | `ReasonService:26` | `FACTS_UNAVAILABLE` 503 |
| 2 | 无权限 | Controller `:62` | 由安全框架拦在方法之前，具体响应体未核 |

观察：该口是唯一一个**不经过任何应用服务编排层**的 bench-end 入口，直接读 M01 字典 Port。历史记录 `docs/详细设计/07-补液运行与任务执行/history/review/2026-10-26-小试结束培养运行预检.md:8`、`:33` 记当时 `HTTP_VERIFIED` 仅覆盖「空列表分支」，本轮未复测，不上调。

未核（F）：字典项排序规则（是否由 M01 保证）；停用项的判定字段；`DictionaryCandidateQuery` 第三参数语义。**本口 E 记未核**：语句表只到 `M01FormCandidateFactsAdapter` 的类声明行（`:74` 为 `implements` 行），适配器正文与字典查询的 XML 均未打开。

## 2. `benchManualStopStatus` — GET `/run/workflows/bench-end-batches/{batchId}/simulation-manual-stop`

| 项 | 值 |
|---|---|
| Controller | `:70`—`:75`：`run:workflow:query`、`@CurrentManagementRevision` |
| 设计位置 | `小试结束培养接口契约.md:47` |
| 应用服务 | `service/application/m07/BenchEndCultureManualStopService.java` `status:65`—`:79`；共用 `inspect:139`—`:175` |
| 消费者 | 无 |

正常路径（`status`）：

1. `:66` `inspect(number(batchId), currentActor())`。`number` 只接受 `[1-9][0-9]*`，否则 `INPUT_INVALID`（400）。
2. `inspect` 五段校验：① 实例行存在且 `BenchEndCultureDefinition.matches(subflowCode, frozen, "NORMAL" 或 "ABNORMAL")`，否则 `NOT_FOUND` 404；② `executionMode=SIMULATION`、`finishType` 与分支一致、`batchWorkflowIds` 为数组且含本 id、异常批次必须单罐且 `batchRootWorkflowId` 等于本 id、`state=COMPLETED`、`applicationState=APPLIED`，任一不满足 → `STATE_CONFLICT` 409；③ 步骤数 3（正常）或 2（异常），`stepCode` 为 `START`／`COMPLETE_CULTURE`／`SHUTDOWN_DEVICE`，`COMPLETE_CULTURE` 必须 `COMPLETED`，正常分支还要求 `SHUTDOWN_DEVICE` 为 `SKIPPED`，否则 `FACTS_UNAVAILABLE` 503；④ 取 `completion_evidence`，正常分支要求 `action=SKIP`，异常分支要求 `BenchEndCulturePolicy.isEffectiveAbnormalEnd(form.abnormalEnd)`，且 `occupancyState` ∈ {`RELEASE_PENDING`, `RELEASED`}，否则 `STATE_CONFLICT` 409；⑤ `BenchEndCultureFactsPort#list(actor, labId, cultureId)` 必须唯一命中、`operationAllowed=true`、生命周期为 `FINISHED`（正常）或 `CANCELLED`（异常）、`controllerId` 与冻结一致，否则 `PERMISSION_DENIED` 403。
3. `:68` 计算 `confirmed`：`manualStopConfirmed=true` **且** `occupancyState=RELEASED` **且** `releaseEvidenceRef` 匹配正则 `M07:BENCH_END:SIMULATION:[0-9a-f]{64}`。三项全真才算已确认。
4. `:71` 未确认时追加校验：M02 事实的 `occupancyId` 非空、与冻结 `occupancyId` 相等、`occupancyState=RELEASE_PENDING`，否则 `VERSION_CONFLICT` 409「原控制器占用不在待释放状态」。
5. `:75` 返回 `BenchEndCultureManualStopStatus(batchId, cultureId, occupancyId, RELEASED 或 RELEASE_PENDING, occupancyVersion, stepObjectVersion, confirmed, "SIMULATION")`。纯读。

语句与 Port：

| 调用点 | 方法 | 语句／实现 |
|---|---|---|
| `inspect:140` | `RunWorkflowInstanceMapper#selectWorkflowInstanceDetail` | `RunWorkflowInstanceMapper.xml:89` |
| `inspect:155` | `RunWorkflowStepMapper#selectWorkflowSteps` | `RunWorkflowStepMapper.xml:118` |
| `inspect:168` | `BenchEndCultureFactsPort#list` | `service/impl/port/m03/M03BenchEndCultureFactsAdapter.java:23`（`implements`） |

关键拒绝：共 7 类（`input` 400／`NOT_FOUND` 404／状态 409／步骤 503／证据 409／权限 403／占用 409），逐条见上列第 1—4 步。

观察：`inspect` 用 `selectWorkflowInstanceDetail(id, null, null)`，**不带任何 lab／culture 范围条件**。范围与操作权完全依赖第 ⑤ 段的 `BenchEndCultureFactsPort#list`。这与 W03／W08 分支把范围写进 SQL 的做法不同，与 bench-end 其余五口一致（同为「先按主键读、再用 M03 事实做范围闸门」）。登记为形态差异，不判缺陷。

未核（F）：`BenchEndCultureDefinition.matches` 内部判定（subflow 与快照双条件）；`isEffectiveAbnormalEnd` 的判定细则；`string` 化后的 `occupancyVersion` 与 `facts.occupancyVersion()` 的类型一致性。

## 3. `confirmBenchManualStop` — POST 同一路径

| 项 | 值 |
|---|---|
| Controller | `:81`—`:87`：`run:workflow:operate`、`@ManagementGuardedWrite`，`WriteMeta` 由框架注入 |
| 设计位置 | `小试结束培养接口契约.md:48`（「重验已生效的异常原因／审批或正常 SKIP 证据、身份、原占用及安全事实，释放该成员原占用」） |
| 应用服务 | `BenchEndCultureManualStopService` `confirm:81`—`:91` → `apply:93`—`:135` |
| 守卫码 | `M07_BENCH_END_MANUAL_STOP`（`ManagementOperation.java:582`，值 `M07-BENCH-END-MANUAL-STOP`） |
| 消费者 | 无 |

正常路径：

1. `:83` `command == null` 或 `confirmed != TRUE` → `INPUT_INVALID` 400。
2. `:85` 解析 `expectedStepVersion`、`expectedOccupancyVersion`（`number` 校验正整数）。
3. `:86`—`:88` 组 payload：`batchId`、两个期望版本、`confirmed=true`、`executionMode=SIMULATION`。
4. `:89` `guard.execute(M07_BENCH_END_MANUAL_STOP, meta, payload, apply)`。
5. `apply:95` 再跑一次 `inspect`（**守卫内重验，不复用守卫外结果**），然后 `:98`—`:102` 做五项比对：步骤版本相等、`facts.occupancyVersion` 可解析且与入参相等、冻结 `occupancyId` 与事实相等、`occupancyState=RELEASE_PENDING`、证据里**尚无** `manualStopConfirmed`。任一不符 → `VERSION_CONFLICT` 409。第五项即防重放：已确认过的走回执，不再二次释放。
6. `:104`—`:107` 组 `BenchEndCultureFinishTarget(workflowId, stepInstanceId, workflowVersion, stepVersion, cultureId, labId, controllerId, facts.cultureVersion, occupancyId, occupancyVersion)`。
7. `:108` `BenchEndCultureFinishPort#releaseAfterManualStop(target)`。
8. `:109`—`:112` 校验回执：非空、`occupancyVersion == 入参+1`、`confirmedAt` 非空、`evidenceRef` 非空且匹配 `M07:BENCH_END:SIMULATION:[0-9a-f]{64}`。否则 `FACTS_UNAVAILABLE` 503「小试占用释放回执不完整」。
9. `:113`—`:119` 深拷贝原证据，写入 `manualStopConfirmed=true`、`occupancyState=RELEASED`、新 `occupancyVersion`、`confirmedAt`、`confirmedByUserId`、`confirmationSource=SIMULATION_MANUAL_OPERATOR`、`releaseEvidenceRef`。
10. `:120` `BenchEndCultureMapper#confirmManualStop(workflowId, stepInstanceId, stepVersion, canonical(updated), actorId)`，必须影响 1 行，否则 `VERSION_CONFLICT` 409 整体回滚。
11. `:123`—`:129` 追加本地事件 `BENCH_END_CULTURE_MANUAL_STOP_CONFIRMED`，`objectKind=WORKFLOW_STEP`，版本 `stepVersion+1`。
12. `:133` 审计前后快照（步骤对象），标题「工作流步骤/操作」。

语句与 Port：

| 调用点 | 方法 | 语句／实现 |
|---|---|---|
| `:108` | `BenchEndCultureFinishPort#releaseAfterManualStop` | M03 `CultureApplicationServiceImpl:1867`（该类在 `:136` 的 implements 列表内，**无独立 Adapter**） |
| `:120` | `BenchEndCultureMapper#confirmManualStop` | `BenchEndCultureMapper.xml:116` |
| `:126` | `M07RunEventFactWriter#appendLocal` | 写入 `run_event`（`RunEventMapper`），语句未逐行展开 |

关键拒绝：入参 400 ×1、`inspect` 的 404／409／503／403 全集（同 §2）、版本与状态 409 ×1（`:103`）、回执不完整 503 ×1（`:112`）、CAS 失败 409 ×1（`:122`）。

**语义边界（必须保留）**：这是**模拟确认**。证据里恒写 `"executionMode":"SIMULATION"`，事件与审计都带 `confirmationSource=SIMULATION_MANUAL_OPERATOR`。它**不证明真实设备已停稳，也不代表已下发停机命令**。真实停稳回读是另一条证据来源，本批未涉。

未核（F）：`releaseAfterManualStop` 在 M03 内部的占用释放规则、是否幂等、与资源守卫的关系；事件消费方。

## 4. `benchEndBatch` — GET `/run/workflows/bench-end-batches/{batchId}`

| 项 | 值 |
|---|---|
| Controller | `:90`—`:95`：`run:workflow:query`、`@CurrentManagementRevision` |
| 设计位置 | `小试结束培养接口契约.md:42` |
| 应用服务 | `BenchEndCultureBatchService` `read:89`—`:93`（`@Transactional(readOnly=true)`）→ `load:235`—`:284` → `project:285`—`:340` |
| 消费者 | 无（页面为 Mock） |

正常路径（`load`）：

1. `:236` `selectWorkflowInstanceDetail(root, null, null)`，为空 → `NOT_FOUND` 404。
2. `:239` `BenchEndCultureDefinition.matches(subflowCode, frozen, finishType)` 不成立 → 404。
3. `:241`—`:245` 六项形状校验：根快照 `batchRootWorkflowId` 等于入参、`workflowKind=end_cell_culture_small`、`executionMode=SIMULATION`、`finishType` ∈ {NORMAL, ABNORMAL}、`batchWorkflowIds` 为非空数组。任一不符 → `FACTS_UNAVAILABLE` 503。
4. `:247`—`:249` 成员 ID 解析为正整数，`ids[0]==root` 且无重复，否则 503。
5. `:251`—`:279` 逐成员：实例存在、`labId` 与 `subflowCode` 同根一致（否则 503）；快照的 `batchRootWorkflowId`／`batchWorkflowIds`／`finishType` 与根完全相等、`culture.objectId` 等于 `cultureId`（否则 503）；`BenchEndCultureFactsPort#list` 唯一命中且 `operationAllowed`（否则 404）；`controllerId` 与冻结一致（否则 404）；步骤数与 `stepCode` 序列匹配（否则 503）。
6. `:262`—`:267` **已退出选择的成员不阻断整批**：当 `finishType=NORMAL` 且成员 `state=CANCELLED`、`applicationState=NONE` 时，`removed=true`，`continue` 跳过，不回显该成员当前卡片。
7. `:280` 成员为空 → 404；`:281` 异常批次成员数不为 1 → 503。

正常路径（`project`）：

1. `:290` 只对 `state=OPEN` 的成员刷新卡片：取冻结 `card`，用 M03 事实重算 `dayCount`（计划开始日到今天，`Asia/Shanghai`）与 `plannedEndDate`。
2. `:297` `BenchEndCultureCandidateService#populateCurrentMetrics` 批量补在线／离线指标。**已终结成员不参与**（用冻结卡片，不依赖实时设备观测），与设计 `:42` 一致。
3. `:298`—`:335` 逐成员组 `Member`：步骤视图（`executionMode` 硬写 `SIMULATION`、`skipped` 由 `state=SKIPPED` 推导）、冻结步骤描述与实例逐个比对（`stepCode` 与 `definitionStepId`，否则 503）、`actor` 由 `actor_snapshot` 投影为 `Person`、`abnormalEnd` 由第 2 步表单快照投影。
4. `:336`—`:338` `phase` 四值推导：全部非 OPEN → 有 `COMPLETED` 则 `COMPLETED`，否则 `CANCELLED`；否则全部 OPEN 成员的**第 3 步**为 `IN_PROGRESS` 则 `SHUTDOWN_DEVICE`，否则 `COMPLETE_CULTURE`。
5. `:339` 返回 `BenchEndCultureBatchView(rootId, labId, phase, type, "SIMULATION", members)`。

语句与 Port：

| 调用点 | 方法 | 语句／实现 |
|---|---|---|
| `load:236`、`:252` | `RunWorkflowInstanceMapper#selectWorkflowInstanceDetail` | `RunWorkflowInstanceMapper.xml:89` |
| `load:261` | `BenchEndCultureFactsPort#list` | `M03BenchEndCultureFactsAdapter:23` |
| `load:272` | `RunWorkflowStepMapper#selectWorkflowSteps` | `RunWorkflowStepMapper.xml:118` |

关键拒绝：见上列 `load` 第 1—7 步，共 404 ×2、503 ×5、404 ×2（成员级 2 类）。

观察：`read` 标 `@Transactional(readOnly=true)`，但 `load` 的两次实例查询都不带范围条件；范围判定落在 `BenchEndCultureFactsPort#list` 的 `operationAllowed`。因此**「批次根行本身」不做 VIEW 范围判定**——一个有 lab 权限但无该培养权限的用户，会在成员级 404，而不是在根级 404。登记为形态差异。

未核（F）：`BenchEndCultureDefinition.matches` 的内部条件；`populateCurrentMetrics` 的指标来源与失败降级行为；`card` 冻结字段与当前卡片的字段差异。

## 5. `actBenchEndBatch` — POST `/run/workflows/bench-end-batches/{batchId}/actions`

| 项 | 值 |
|---|---|
| Controller | `:98`—`:104`：`run:workflow:operate`、`@ManagementGuardedWrite` |
| 设计位置 | `小试结束培养接口契约.md:43`（NEXT／COMPLETE／SKIP／CANCEL／REMOVE，携带本页全部活动成员及版本，移除只带一名且只能在第 2 步、至少保留一台） |
| 应用服务 | `BenchEndCultureBatchService` `act:95`—`:112` → `apply:114`—`:230` |
| 守卫码 | `M07_BENCH_END_STEP`／`M07_BENCH_END_CANCEL`／`M07_BENCH_END_REMOVE`／`M07_BENCH_END_COMPLETE`（`ManagementOperation.java:578`—`:580`，另 `:577` 为 COMPLETE） |
| 消费者 | 无 |

`act` 的入口校验（`:97`—`:110`）：

1. `action` ∉ {NEXT, COMPLETE, SKIP, CANCEL, REMOVE}，或 `members` 空 → `INPUT_INVALID` 400。
2. `action` ∈ {COMPLETE, SKIP, CANCEL} 且 `confirmed != TRUE` → 400「此操作需要二次确认」。**REMOVE 不要求二次确认**，与设计 `:43`「移除不额外要求二次确认」一致。
3. `:105` 按 action 选守卫码：NEXT→STEP、CANCEL→CANCEL、REMOVE→REMOVE，其余（COMPLETE／SKIP）→COMPLETE。**SKIP 与 COMPLETE 共用同一守卫码**。

`apply` 的校验（守卫内，`:115`—`:162`）：

1. `:117` 成员去重，重复或空 → 400。
2. `:121` `active` = `state=OPEN` 的成员；为空 → `STATE_CONFLICT` 409「批次没有待完成成员」。
3. `:123`—`:127` REMOVE：`supplied.size()==1`、`active.size()>1`、`batch.type()=="NORMAL"`、且被移除者必须在 active 内，任一不符 → 400。
4. `:128` 非 REMOVE：`active.size()==supplied.size()` 且 active 全覆盖，否则 400「请一次提交本页全部控制器及其版本」。
5. `:132` `stepIndex`：NEXT→1、COMPLETE／SKIP→2、其余→1（CANCEL／REMOVE 不使用）。
6. `:133` 非 NORMAL 批次只允许 CANCEL，否则 409「异常结束应通过原因及审批入口处理」。
7. `:135` NEXT 不得带 `confirmed`，否则 400。
8. `:137` COMPLETE／SKIP 不得带 `reason`，否则 400「正常结束不填写异常结束原因」。
9. `:140`—`:161` 逐成员：状态必须 `OPEN`、`applicationState=NONE`、`endedAt=null`（否则 409）；`expectedWorkflowVersion` 必须等于当前版本（否则 `VERSION_CONFLICT` 409）；CANCEL 要求成员至少一个步骤 `IN_PROGRESS`（否则 409）；其余动作校验第 `stepIndex` 步的 `stepId`／`expectedStepVersion`／`IN_PROGRESS`、前一步 `COMPLETED`、`startedAt` 非空、`endedAt` 空（否则 409），并校验 `activity.countPhysicalActivity(workflowId)==0`（否则 `RESOURCE_IN_USE` 409）。

写入（`:163`—`:229`）三支：

| action | 写什么 | 语句／Port |
|---|---|---|
| COMPLETE | 组 `BenchEndCultureFinishTarget` 列表（按 `cultureId` 排序）→ `BenchEndCultureFinishPort#completeNormally` → 校验回执 `executionMode=SIMULATION` 且 `cultureIds.size()==targets.size()`（否则 503）→ 逐成员 `updateStep(→COMPLETED)` ＋ `finishWorkflow`，各须影响 1 行 | M03 `CultureApplicationServiceImpl:1678`；`BenchEndCultureMapper.xml:16`（updateStep）、`:34`（finishWorkflow） |
| SKIP | 同上，改调 `skipNormally`，步骤终态 `SKIPPED` | M03 `:1686`；同上 |
| NEXT | 第 2 步 → `COMPLETED`、第 3 步 `PENDING`→`IN_PROGRESS`、`advanceWorkflow`，三步各须影响 1 行 | `BenchEndCultureMapper.xml:16`、`:27` |
| CANCEL | `RunWorkflowStepMapper#cancelOpenSteps`（≥1 行）＋ `RunWorkflowInstanceMapper#cancelWorkflowByVersion(CANCELLED, NONE)`（=1 行） | `RunWorkflowStepMapper.xml:63`、`RunWorkflowInstanceMapper.xml:37` |
| REMOVE | 同 CANCEL（成员级取消，不动整批） | 同上 |

COMPLETE／SKIP 写入的证据 JSON（`:185`—`:194`）固定字段：`executionMode=SIMULATION`、`deviceCommandSent=false`、`actualEndedAt`、`cultureLifecycleState=FINISHED`、`occupancyState`（SKIP 为 `RELEASE_PENDING`，COMPLETE 为 `RELEASED`）、`deviceShutdownConfirmed`（SKIP 为 `false`，COMPLETE 为 `true`）、递增后的 `cultureVersion` 与 `occupancyVersion`。

关键拒绝汇总：400 ×5、409 ×6、503 ×2（回执不完整）、`VERSION_CONFLICT` 409 ×若干（每条 CAS）。

观察一：`apply` 的 SKIP 与 COMPLETE **共用守卫码 `M07_BENCH_END_COMPLETE`**，两者靠证据里的 `action` 与 `occupancyState` 区分。回执重放时无法仅凭守卫码判断是「完成」还是「跳过」，须读证据。登记为观察，不判缺陷。

观察二：`affected.get(0)`（`:227`）作为 `ManagementWriteOutcome.id`，而 `affected` 在 REMOVE／CANCEL 分支按 `selected` 顺序追加、在 NEXT 分支追加两个 stepId。因此 `outcome.id` 的含义随 action 变化（实例 ID／步骤 ID）。回执消费方不能假定 `id` 恒为工作流 ID。登记为观察。

未核（F）：M03 三个 `finish*` 方法内部的培养生命周期与占用写入规则、是否幂等；`countPhysicalActivity` 的统计口径；`BenchEndCultureFinishReceipt` 的 `auditIntent` 是否覆盖全部成员。

## 6. `completeBenchAbnormally` — POST `/run/workflows/bench-end-batches/{batchId}/abnormal`

| 项 | 值 |
|---|---|
| Controller | `:107`—`:113`：`run:workflow:operate`、`@ManagementGuardedWrite` |
| 设计位置 | `小试结束培养接口契约.md:44`（`stepId`、期望流程／步骤版本、`reason`；服务端解析实验室审批政策，免审直接完成，需审批则创建 M06 申请并等待决定） |
| 应用服务 | `BenchEndCultureAbnormalService` `complete:83`—`:101` → `apply:103`—`:177` → `prepare:182`—`:234` |
| 守卫码 | `M07_BENCH_END_ABNORMAL_SUBMIT`（审批路由）或 `M07_BENCH_END_COMPLETE`（免审路由），在 `:98`—`:99` 按政策决定 |
| 消费者 | 无 |

正常路径：

1. `:85` `reason` 空或超 500 字 → `INPUT_INVALID` 400。
2. `:88` `currentActor()` 解析身份（会话或请求缺失 → `AUTH_DEPENDENCY_UNAVAILABLE` 503）。
3. `:89` 按 `command.stepId` 读步骤行，不存在或不属于该实例 → `NOT_FOUND` 404。
4. `:92`—`:94` 读表单快照里的 `abnormalEnd.policy`；**已有冻结政策则复用，否则在守卫外先跑一次 `prepare` 取政策**。这一步决定了后续用哪个守卫码。
5. `:95`—`:97` 组 payload：`workflowId`、`stepId`、两个期望版本、`reason`。
6. `:100` `guard.execute(operation, meta, payload, apply)`。
7. `apply:105` **守卫内再跑一次 `prepare`**，并 `:106`—`:109` 比对政策 `route`／`policyRevisionId`／`policyHash`，任一变化 → `VERSION_CONFLICT` 409「异常结束审批政策已变化，请刷新后重试」。
8. 审批路由（`:112`—`:145`）：组 `ApprovalSubmissionCommand`（`producer=M07`、`sceneCode=M06_SC047`、`sourceRequestId=requestId`、`changeKey=`M07-025:requestId`）→ `ApprovalSubmissionPort#submitApproval` → 校验回执（候选 ID／哈希／`approvalId` 正整数／政策修订一致／状态为 `PENDING_REVIEW` 或 `PENDING_APPROVAL`），否则 503 → `saveAbnormalCandidate` ＋ `awaitAbnormalApproval`，各须影响 1 行（否则 409）→ 事件 `BENCH_END_CULTURE_APPROVAL_SUBMITTED`。**不改变培养生命周期**（事件里显式写 `cultureLifecycleUnchanged=true`）。
9. 免审路由（`:146`—`:176`）：`route` ∉ {DIRECT, DIRECT_REASON} → `POLICY_UNVERIFIED` 503；组 `BenchEndCultureFinishTarget` → `BenchEndCultureFinishPort#completeAbnormally(target, reason, policy)` → 校验回执（`SIMULATION`、`cultureIds` 恰为 1 且等于本培养、`occupancyIds` 恰为 `[occupancyId]`、`actualEndedAt` 非空），否则 503 → `finishAbnormalStep` ＋ `finishAbnormalWorkflow`（否则 409）→ 事件 `BENCH_END_CULTURE_ABNORMAL_COMPLETED`。证据写 `cultureLifecycleState=CANCELLED`、`occupancyState=RELEASE_PENDING`、`deviceShutdownConfirmed=false`。

`prepare` 的校验（`:183`—`:233`）：实例存在且为异常结束分支（否则 404）、培养事实唯一且可操作（否则 404）、`state=OPEN`／`applicationState=NONE`／`endedAt=null`／版本相等（否则 409）、快照五项形状（否则 503）、M03 操作事实九项（设备类别、lab／culture、生命周期 ∈ {RUNNING, DELAYED}、对象版本、控制器、占用、`RUNNING` 占用态、计划结束日非空且不等于今天、计划结束日与快照一致、项目与批次非空，任一不符 → 409）、步骤恰为 2 且第 1 步 `COMPLETED`、第 2 步 `COMPLETE_CULTURE`＋`IN_PROGRESS`＋`startedAt` 非空＋`endedAt` 空＋`stepId`／版本相等（否则 409）、`countPhysicalActivity==0`（否则 `RESOURCE_IN_USE` 409）、表单尚无 `abnormalEnd`（否则 409「异常原因已经提交」）、政策可得（否则 `POLICY_UNVERIFIED` 503）。

语句与 Port：

| 调用点 | 方法 | 语句／实现 |
|---|---|---|
| `prepare:183` | `RunWorkflowInstanceMapper#selectWorkflowInstanceDetail` | `RunWorkflowInstanceMapper.xml:89` |
| `prepare:187` | `BenchEndCultureFactsPort#list` | `M03BenchEndCultureFactsAdapter:23` |
| `prepare:204` | `CultureOperationFactsPort#resolveCultureOperationFacts` | 生产实现未在本批展开（work1 侧同一 Port，本批只记调用点） |
| `prepare:217` | `RunWorkflowStepMapper#selectWorkflowSteps` | `RunWorkflowStepMapper.xml:118` |
| `apply:121` | `ApprovalSubmissionPort#submitApproval` | M06 侧，本批未展开 |
| `apply:134`、`:168` | `BenchEndCultureMapper#saveAbnormalCandidate`、`#awaitAbnormalApproval`、`#finishAbnormalStep`、`#finishAbnormalWorkflow` | XML `:42`、`:51`、`:57`、`:67` |
| `apply:153` | `BenchEndCultureFinishPort#completeAbnormally` | M03 `CultureApplicationServiceImpl:1767` |
| `apply:230` | `ApprovalPolicyPort#evaluateApprovalPolicy` | M06 侧，本批未展开 |

关键拒绝：404 ×2、400 ×1、503 ×4（身份／政策／回执／`POLICY_UNVERIFIED`）、409 ×7 类、`RESOURCE_IN_USE` 409 ×1。

**实现特征（须如实登记）**：`prepare` 在守卫**外**被调用一次（`:94`），在守卫**内**再调用一次（`:105`）。守卫外那次是为选守卫码，会真实读库并可能抛错（此时尚未进入守卫，不产生写入）。这不是重复写入，但意味着同一请求会执行两次 `prepare` 的只读开销，且两次之间政策可能变化——变化由 `:106` 的比对兜住，转 409。登记为观察。

未核（F）：M06 审批决定回投消费者与 `BenchEndCultureApprovalService` 的落地链（本批不核）；`policyHash` 的计算口径；`completeAbnormally` 在 M03 内部的生命周期／占用写入与幂等。

## 7. `samplingSlots` — GET `/run/workflows/sampling-slots`

| 项 | 值 |
|---|---|
| Controller | `:119`—`:124`：`run:workflow:query`、`@CurrentManagementRevision`，`labId` 为必填 query 参数 |
| 设计位置 | `接口目录与契约定位.md:73`（W06 读口的字段级说明）；`Controller请求调用时序设计.md:47`（Controller 核权限、服务核 M01 会话／M02 VIEW、小试上游类型与 M04 W06 定义） |
| 应用服务 | `service/application/m07/SamplingWorkflowSlotQueryService.java:34`—`:74` |
| 消费者 | `sdk-smp-api/src/run-workflow.ts:462` `samplingSlots`；页面 `views/feeding-workflow/start-candidates.ts` 使用 |

正常路径：

1. `:35` `labId` 必须匹配 `[1-9][0-9]*`，否则 `INPUT_INVALID` 400。
2. `:36`—`:38` 会话键与请求 ID 任一缺失 → `SESSION_INVALID` 401。
3. `:39`—`:43` `ActorContextPort#resolveActorContext`，返回 null 或 session／request 不一致或 `authzVersion` 非数字 → `AUTH_DEPENDENCY_UNAVAILABLE` 503。
4. `:44` 操作者 ID 必须为正整数，否则 503。
5. `:46` `SamplingLiquidSlotPort#listW06Slots(actorId, lab)`。**M02 先做 VIEW 权限判定**（注释 `:45` 明确「M02 checks current VIEW authorization before M07 probes lab configuration or M04 definitions」），本轮未打开该 Adapter 内部。
6. `:48`—`:50` 实验室上下文必须存在且 `labId` 一致，否则 503。
7. `:51` `labType != "1"` → `CONFIGURATION_INCOMPLETE` 409「W06仅支持小试上游实验室」。
8. `:53`—`:58` 解析 W06 工作流定义，null → 503；`subflowCode`／`labType`／步骤非空三项不符 → 409「实验室未配置有效W06工作流」。
9. `:60`—`:72` 逐槽位校验：非空且 `bottleId` 唯一（否则 503）；`bottleId` 为正整数；`liquidType` ∈ {`water`, 含 `alcohol`}、`selectable` 非 null、`unitCode` 非空、`rowNo`／`slotNo` 为正整数（否则 503）；`selectable=true` 时 `unavailableReason` 必须为空且 `resourceKey`／`channelCode`／`fullCapacityGrams>0`／`configurationRevision` 数字齐全；`selectable=false` 时 `unavailableReason` 必须非空。任一不符 → 503。
10. `:73` 返回 `List<SamplingLiquidSlot>`（含不可选项，带原因）。

语句与 Port：

| 调用点 | Port | 实现 |
|---|---|---|
| `:46` | `SamplingLiquidSlotPort#listW06Slots` | `service/impl/port/m02/M02SamplingLiquidSlotAdapter.java:21` |
| `:49` | `LabWorkflowContextPort#resolveLabWorkflowContext` | 本批未展开 |
| `:54` | `WorkflowDefinitionPort#resolveForRun` | `service/impl/port/m04/*`，本批未展开 |

关键拒绝：400 ×1、401 ×1、503 ×6 类、409 ×2。

观察：该口**不接受任何筛选参数**，只按 `labId` 返回该实验室全部 W06 槽位；「Water／Alcohol」的区分靠返回项的 `liquidType` 字段，客户端自行分组。设计侧的 W06 读口见 `接口目录与契约定位.md:71`—`:75`（返回 `data: SamplingLiquidSlot[]` 与顶层 `managementRevision`），「Water/Alcohol、排除 Waste」的分组口径写在 `工作流与页面操作设计.md:147`。源码 `liquidType` 与该口径一致。

> 行号更正：本条初稿引 `接口目录与契约定位.md:50`—`:58`，实测该区间是本轮 HEAD 的 W08／W03 P07 段落（漂移），已改引上述两处。

未核（F）：`M02SamplingLiquidSlotAdapter#listW06Slots` 内部的权限与槽位集合规则；W06 定义「步骤非空」之外是否还要求固定 2 步（`startW05` 对 W05 有 2 步硬校验，W06 此处没有）。**本口 E 记未核**：上表的三行分别只到 Port 实现类的类声明行与「本批未展开」，未打开任何 XML 语句正文。

## 8. `roomOptions` — GET `/run/workflows/room-options`

| 项 | 值 |
|---|---|
| Controller | `:127`—`:133`：`run:workflow:query`、`@CurrentManagementRevision`，`labId` ＋ `subflowCode` 均必填 |
| 设计位置 | `接口目录与契约定位.md:430`（2026-10-21 V4.2 房间选项：`run:workflow:query`＋`CurrentManagementRevision`，复用候选范围后消费 M01 精确名称，不要求管理权限、不跨模块 Mapper）；`接口目录与契约定位.md:44`（中试结束培养「房间选项复用 `/run/workflows/room-options`」） |
| 应用服务 | `service/application/m07/PilotWorkflowRoomOptionService.java:28`—`:61` |
| 消费者 | `sdk-smp-api/src/run-workflow.ts:546` `roomOptions`；页面 `views/pilot-replace/index.vue` |

正常路径：

1. `:29` `labId` 正 bigint 校验，否则 400。
2. `:30`—`:32` `subflowCode` 白名单：`connect_feed_unit_pilot`、`replace_feed_liquid_pilot`、`end_culture_pilot`、`end_cell_culture_small`。其余（含 `null`、空串、W03、W07、W08、W05、W06）→ `INPUT_INVALID` 400「当前工作流没有可用的场地选项」。
3. `:33`—`:34` 复用 `RunWorkflowApplicationApplicationService#listWorkflowCandidates`，`relationFilter=ALL`。**场地范围完全继承候选口的范围判定**，本口不另做范围查询。
4. `:37`—`:40` 收集候选的 `venueId` 去重，null 跳过，每个必须是正 bigint。
5. `:41` 去重后 >500 → `CONFIGURATION_INCOMPLETE` 409「工作流房间数量超过完整选项上限」。
6. `:43` 空集合直接返回空列表（**不查名称**）。
7. `:44`—`:50` 二次解析身份（会话／请求缺失 → `SESSION_INVALID` 401；解析失败 → 503）。
8. `:51` `VenueNameReadPort#readNames(VenueNameReadQuery(actor, ids))`。
9. `:52` 返回 null、`rows` 为 null 或行数与 `ids.size()` 不等 → 503。
10. `:54`—`:59` 逐行：非空、`venueId` 在请求集合内、不重复、`issues` 非 null；`available=true` 必须有非空 `venueName`；`available=false` 必须无名称且有 issues。任一不符 → 503。
11. `:60` 返回 `List<WorkflowRoomOption(venueId, venueName, available, issues)>`。

语句与 Port：

| 调用点 | Port | 实现 |
|---|---|---|
| `:34` | 应用服务内部调用（非 Port） | `RunWorkflowApplicationApplicationServiceImpl#listWorkflowCandidates:276` |
| `:51` | `VenueNameReadPort#readNames` | `service/impl/port/m01/M01VenueNameReadAdapter.java:26` |

观察一：**源码白名单四值，两处最早的设计段只写两值。** `接口目录与契约定位.md:430`（段首标注 **2026-10-21** V4.2 房间选项）写「W01/W02可用，未知子流程拒绝」；`任务页面与接口契约.md:107`（所在节 **2026-10-21**）同样写「`subflowCode` 为 W01 或 W02」。此后 `接口目录与契约定位.md:44`（节标题 **2026-10-23** 中试结束培养候选接线）写「房间选项**复用** `/run/workflows/room-options`」，即加入 `end_culture_pilot`；`小试结束培养接口契约.md:39`（文件头 **2026-10-26**）加入 `end_cell_culture_small`。源码白名单是 `connect_feed_unit_pilot`（W01）、`replace_feed_liquid_pilot`（W02）、`end_culture_pilot`（中试结束）、`end_cell_culture_small`（小试结束）四项。

结论：按成文时间与适用范围核对，源码四项 ＝ 三个时间点各自新增一项的**并集**，后两段只扩展、未撤销前段，故这是**早期段落未回写的过期口径（文档演进）**，不是需要裁决的设计冲突，也不是源码越界。**不判缺陷、不据此改白名单、不改设计文档、不新增客户问题**；文档补正建议见 `03-…md` §3.3。本批未取得客户 V4.2 原件对结束培养房间选项的确认时点，该点属未核。

观察二：本口**两次解析身份**（候选口内部一次 `resolveCandidateActor`，本口 `:47` 再一次）。这是为了租户/授权版本在两次调用之间不漂移，代价是同一请求两次 Port 调用。登记为观察。

未核（F）：`M01VenueNameReadAdapter` 内部对不可用场地的判定；500 上限的来源依据（常量硬编码 `:41`）。**本口 E 记未核**：`VenueNameReadMapper` 的 XML 未打开，适配器只定位到类声明行，另一行是应用服务内部调用、不属 Port／语句证据。

## 9. `listWorkflowCandidates` — GET `/run/workflows/candidates`（M07-022）

| 项 | 值 |
|---|---|
| Controller | `:140`—`:147`：`run:workflow:query`、`@CurrentManagementRevision`。`workflowKind != null` → `startCulture.candidates(...)`，否则 → `runWorkflow…listWorkflowCandidates(...)` |
| 设计位置 | `接口目录与契约定位.md:292`—`:299`（含 2026-10-18 W07 补充、2026-10-25 W05 补充） |
| 应用服务 | `RunWorkflowApplicationApplicationServiceImpl#listWorkflowCandidates:276`—`:404`；开始培养分支 `StartCultureApplicationService#candidates:85`—`:136` |
| 消费者 | `runWorkflowApi.candidates:485`（6 个页面）＋ `startCultureApi.candidates:293`（开始培养页） |

分派表（`:279`—`:301`）：

| 顺序 | 条件 | 去向 |
|---|---|---|
| 1 | `subflowCode=waste_clear_small`（W08） | `wasteClearCandidates.list` |
| 2 | `subflowCode=W03` | `benchConnectionCandidates.list` |
| 3 | `subflowCode=W02` | `w02CandidateReader.list` |
| 4 | `labId` 先做正 bigint 归一（`:285`） | — |
| 5 | `subflowCode=replace_feed_liquid_pilot` | `pilotReplacementSources.list` |
| 6 | `subflowCode=connect_feed_unit_pilot` | `pilotWorkflowCandidates.list` |
| 7 | `subflowCode=end_culture_pilot` | `pilotEndCultureCandidates.list` ＋ `pilotEndCultureCardMetrics.populate` |
| 8 | `subflowCode=end_cell_culture_small` | `benchEndCultureCandidates.list` |
| 9 | `subflowCode ∈ {W07, W05}` | 落第 10 段的平台链（`feedingRefill=true`） |
| 10 | 其余（含 `null`、W06） | `INPUT_INVALID` 400「当前候选查询仅支持W03连接与W07补料单元液体补充」 |
| — | `workflowKind != null` | 在 Controller 层先被截走，走开始培养候选，**不进本方法** |

第 10 段之后的共用链（`:302`—`:403`）：

1. `:302` `relationFilter` 归一：`ALL`／`所有`／空 → ALL；`PLAN_CONFIGURED`／`方案已设置` → PLAN_CONFIGURED；其他 → 400「W03候选暂不支持该关联筛选条件」。
2. `:303` `resolveCandidateActor()`，null → `AUTH_DEPENDENCY_UNAVAILABLE` 503。
3. `:313` `W03CandidateCulturePort#listW03CandidateCultures`，null 或 `rows` 为 null → 503「W03候选培养事实不可用」。
4. `:318` `resolveLabWorkflowContext`：上下文 null 或 `labId` 不符 → 503；`labType != "1"`（常量 `SMALL_SCALE_UPSTREAM_LAB_TYPE = "1"`，`:157`）→ `CONFIGURATION_INCOMPLETE` 409「W03仅支持小试上游实验室」。**注意这条限制对 W07／W05 同样生效。**
5. `:319` `workflowDefinitionConfigured(labId, labType, subflowCode)`：`WorkflowDefinitionPort#resolveForRun`，返回定义且 `subflowCode` 匹配且步骤非空才算配置好；捕获 `NOT_FOUND`／`CONFIGURATION_INCOMPLETE` 转 false，其他错误继续抛。
6. `:321`—`:401` 逐候选：`cultureCode` 关键字过滤（大小写敏感 `contains`）；W07 的 `cultureId` 精确过滤；`runtime` 解析（W05 为 null，W07 用 controller 维度，其余用 reactor 维度）；`planConfigured = definitionConfigured && (manual || runtime != null && runtime.isReady())`；W07／W05 读 `run_culture_runtime` 判 `connectionWorkflowId` 非空；`PLAN_CONFIGURED` 过滤；组装 `WorkflowCandidateView`（cultureId、cultureCode、deviceId、deviceCode、planConfigured、selectable、unavailableReason）。
7. `:348`—`:399` W07 专属：`benchConnectionCandidates.feedUnitForRefill` 取补料单元；`configured` = 定义已配且 unit 无 issue 且至少一个槽位 `CONFIGURED`；`controllerReady` = runtime 连接 ID 与候选控制器相等且通道非空且（ready 或 issue 全为 `PUMP_BINDING_INCOMPLETE`）；`completedConnection` 要求源 W03 实例 `COMPLETED`＋`APPLIED`、同培养同 lab、`connectionGeneration>0`、快照 `connectionId` 一致、`feedUnitMode=CONTROLLER_CHANNEL`；逐槽位判 `CONFIGURED`／容量非空／通道归属／`countActiveChannel==0`。**逻辑通道显式置 `feedingSlots=[]`，注释说明「逻辑通道不是旧液瓶记录，绝不以通道 ID 冒充 bottle_config 主键」**。
8. `:396` W07 旧瓶位分支：`feedingSlotCandidates.read(...)`。

关键拒绝：400 ×3（relationFilter、subflowCode 不支持、cultureId 非法）、503 ×3、409 ×1。

观察：**W06（`liquid_supply_sampling_unit_small`）没有候选口**。它落进第 10 段的 400。W06 的选择事实走 `GET /run/workflows/sampling-slots`（§7）。因此 W06「有选择器但无候选」不是缺口，是分工；但任何按「所有子流程都有候选口」做覆盖率统计的口径都会把 W06 误判成缺失。

未核（F）：`w03CandidateCulturePort.listW03CandidateCultures` 与 `resolveW03CandidateCultures` 两个方法的关系与内部权限；`M07FeedingSlotCandidateReader#read` 内部；`countActiveChannel` 的 SQL。**本口 E 记未核**：本节未列语句表，候选 Port、runtime 读取与 `countActiveChannel` 三条都只到调用点，没有一条打开到 XML 语句或适配器实现正文。

## 10. `startCultureSession` — GET `/run/workflows/start-culture/sessions/{pageSessionId}`（SC-HTTP05）

| 项 | 值 |
|---|---|
| Controller | `:150`—`:157`：`run:workflow:query`、`@CurrentManagementRevision`；`labId`、`workflowKind` 必填 |
| 设计位置 | `开始培养工作流详细设计.md:302`（SC-HTTP05）。`接口目录与契约定位.md:116` 只列 SC-HTTP01～04，**未列 05**；`:9` 已按专题补给 05 的链接 |
| 应用服务 | `StartCultureApplicationService#recoverySession:147`—`:158` |
| 消费者 | `startCultureApi.session:275` |

正常路径：

1. `:149` `workflowKind` 必须是 `SMALL`，否则 `INPUT_INVALID` 400「INPUT_INVALID: workflowKind」。
2. `:150` `actor()`；`id(labId)`；`lab(actor, lab, kind)` —— 内含 `scope()`（lab 不在 `operableLabIds` 且非 `allAccess` → `LAB_FORBIDDEN`，经 `reject:476` 落 **409**）与 `labType` 校验（小试要求 `"1"`，否则 `LAB_TYPE_NOT_SUPPORTED` → 409）。
3. `:152` `authorizedSession(actor, id(pageSessionId), lock=false, write=true)`。**第三个参数 `write=true` 是本口与批次读口的关键差异**：它强制 `row.actorUserId == actor` 的归属人校验，不符 → `PAGE_SESSION_OWNER_MISMATCH` → 经 `reject` 落 **409**。
4. `:153` 会话的 `labId` 与 `workflowKind` 必须与入参相等，否则 `NOT_FOUND` 404。
5. `:154`—`:156` 状态快照里的 `workflowIds` 与实际成员集合必须**数量相等且集合相等**，否则 `STATE_CONFLICT` 409「session members inconsistent」。
6. `:157` 返回 `sessionView(row)`：`pageSessionId`、`sessionVersion`、`entryBusinessDate`、`entryDeadlineAt`、`state`、`timing`、`workflowIds`、`batchId`。纯读（`@Transactional(readOnly=true)`）。

语句：

| 调用点 | 方法 | 语句 |
|---|---|---|
| `:152`→`authorizedSession:447` | `StartCultureWorkflowMapper#session` | `StartCultureWorkflowMapper.xml:5`（`lock=false` 故不加 `FOR UPDATE`） |
| 同上 | `#members` | `StartCultureWorkflowMapper.xml:22` |

关键拒绝：400 ×1、409 ×4（lab 范围／lab 类型／归属人／成员不一致）、404 ×2（会话不存在／入参不符）、503 ×1（身份不可用）。

观察：设计 `:249` 写「校验会话 owner、实验室范围、类型及全部成员培养可见权限」。源码一致：`authorizedSession` 第四段逐成员 `permissions.canViewCulture`，不可见 → `NOT_FOUND` 404。

未核（F）：`sessionView` 内 `timing` 对 `store.visitOutcome` 的逐成员查询成本与结果语义；`StartCultureSessionState.restore` 对历史快照版本的兼容。

## 11. `startWorkflows` — POST `/run/workflows`（M07-023）

| 项 | 值 |
|---|---|
| Controller | `:166`—`:175`：`run:workflow:start`、`@ManagementGuardedWrite`；`workflowKind != null` → `startCulture.start(..., writeMeta)`；否则把 `requestId`／`managementRevision` 回填进命令再调 `runWorkflow…startWorkflows` |
| 设计位置 | `接口目录与契约定位.md:302`—`:306`；W05 载荷见 `W05手工补料逐接口契约.md` |
| 应用服务 | `RunWorkflowApplicationApplicationServiceImpl#startWorkflows:499`—`:525`；开始培养分支 `StartCultureApplicationService#start:180`—`:220` |
| 消费者 | 13 个 SDK 成员共用该路由（见 `00-…md` §5） |

分派表（`:501`—`:524`）：

| 顺序 | 条件 | 去向 | 守卫码 |
|---|---|---|---|
| 0 | 外层事务已存在 | `INPUT_INVALID` 400「工作流写入入口不支持在已有事务内调用」（`requireFreshUsageTransaction:2233`） | — |
| 1 | `channelTargets != null` 且 `subflowCode != W07` | 400「控制器通道选择仅适用于小试补料单元液体补充」 | — |
| 2 | `subflowCode=replace_feed_liquid_pilot` | `pilotReplacementStart.start` | 内部自定 |
| 3 | `pumpTargets != null` | 400「泵选择载荷仅适用于中试更换料液」 | — |
| 4 | `connect_feed_unit_pilot` | `pilotWorkflowStart.start` | 内部自定 |
| 5 | `end_culture_pilot` | `pilotEndCultureStart.start` | 内部自定 |
| 6 | `end_cell_culture_small` | `benchEndCultureStart.start` | `M07_BENCH_END_START` |
| 7 | `W05` | `startW05:646` | `M07_023` |
| 8 | `W06` | `startW06Workflows:528` | `M07_023` |
| 9 | `W07` 且 `channelTargets != null` | `w07LogicalChannels.startWorkflows` | `M07_023_W07_BATCH` |
| 10 | `W07` 且 `bottleIds != null` | `startW07Workflows:562` | `M07_023`（逐槽位独立） |
| 11 | `W08` | `wasteClearBatches.start` | `M07_023_W08_BATCH` |
| 12 | `W03` | `benchConnectionBatches.start` | `M07_023_W03_BATCH` |
| 13 | 其他 | 400「不支持的工作流启动类型」 | — |

三条分支的载荷与前置（举例，不展开全部十路）：

- **W06**（`:528`—`:559`）：`requestId`／`labId` 必填；`requireW06LabOperation` 实验室操作权；`bottleIds` 1—10 且不重复；幂等指纹**只含** `subflowCode`＋`labId`＋`bottleIds`（注释 `:541` 明确「满瓶投影和实时观测变化不能改变原请求身份」）；守卫内再验一次 lab 操作权、实验室上下文、`SamplingLiquidSlotPort#resolveW06Slots`、M04 定义、`createW06Workflow:1003`；返回单项 `APPLIED`。
- **W07 旧瓶位**（`:562`—`:638`）：`cultureIds` 与 `bottleIds` 各 1—10 且培养不重复；`resolveW03CandidateCultures` 行数必须等于请求数；每条培养必须已连接 W03、runtime ready；逐槽位校验「实验室唯一／反应器唯一／通道属 W03 冻结」；**逐槽位独立守卫**，多槽位时行级 `requestId = UUID.nameUUIDFromBytes(requestId + ":W07:" + bottleId)`；单槽失败按 `state=REJECTED` 或 `UNKNOWN`（≥500 视为不确定）记入 items，遇 `UNKNOWN`／`MANAGEMENT_CONFLICT`／`REQUEST_CONFLICT` 后 `halt=true`，余项记 `PENDING`。这是**部分成功**语义，与 W08「一次父守卫登记」相反。
- **W08**（`:641`—`:644`）：直接转 `WasteClearBatchService#start`，父守卫 `M07_023_W08_BATCH`，不逐瓶提交。

关键拒绝：400 ×6 类（外层事务、通道载荷、泵载荷、不支持的 subflowCode、条数上限、重复）、503 ×若干、`CONFIGURATION_INCOMPLETE` 409（未连接、定义不可用、通道不属冻结）、`PERMISSION_DENIED` 403（培养不在操作范围）。

观察一：Controller 第 `:171`—`:174` 行对两个分支传参方式不同——开始培养分支直接把 `writeMeta` 交给服务，通用分支把两个头回填进命令对象。结果一致（服务都从命令取），但**通用分支的 `requestId` 是从 `WriteMeta` 复制的，若框架未注入则命令里为 null**，守卫会以 `REQUEST_CONFLICT` 或 400 拒绝。登记为形态差异，不判缺陷。

观察二：`requireFreshUsageTransaction` 与 `cancelWorkflow` 的 `requireNoOuterTransaction` 是两套等价检查（一个在 `startWorkflows` 首行、一个在 `cancelWorkflow` 中段），文案不同。同一类边界两种写法。

未核（F）：`pilotReplacementStart`、`pilotWorkflowStart`、`pilotEndCultureStart`、`benchEndCultureStart`、`benchConnectionBatches.start`、`wasteClearBatches.start`、`w07LogicalChannels.startWorkflows` 的内部规则（本批只在必要时点名，不展开）；W05／W07 的 Port 实现细节。**本口 E 记未核**：本节按分派表与三条载荷分支取证，未列出任何 XML 语句行，`createW06Workflow` 等写入只到调用点。

## 12. `getWorkflowInstance` — GET `/run/workflows/{id}`（M07-024）

| 项 | 值 |
|---|---|
| Controller | `:178`—`:186`：`run:workflow:query`、`@CurrentManagementRevision`；`startCulture.owns(id)` 为真 → `startCulture.detail(id)`，否则回填 `id` 后调通用详情 |
| 设计位置 | `接口目录与契约定位.md:308`—`:312`；`开始培养工作流详细设计.md:295`（返回每次访问的时间与原因等） |
| 应用服务 | 通用：`RunWorkflowApplicationApplicationServiceImpl#getWorkflowInstance:1097`—`:1257`；开始培养：`StartCultureApplicationService#detail:223`—`:224` |
| 消费者 | `runWorkflowApi.detail:656`（4 个页面）＋ `startCultureApi.detail:341`（开始培养页、`reactor-link.vue`） |

Controller 层分派的关键点：

- `startCulture.owns(id)` = `store.byWorkflow(id(id)) != null`（`StartCultureApplicationService:78`）。`id(String)` 要求正十进制，**非数字 id 在此处即抛 `INPUT_INVALID` 400**，早于通用服务的 `workflowId()`（同样 400，但文案不同：「工作流实例ID必须为十进制字符串」vs「INPUT_INVALID: positive identity required」）。
- 因此**同一个 400 有两个来源**，日志里需按文案区分。同理适用于 §5 的步骤口与 §6 的操作口、§7 的取消口。

通用详情的正常路径（`:1099`—`:1257`）：

1. `:1101` `workflowId(query.id ?? query.workflowId)`：空 → 400「工作流实例ID不能为空」；非十进制 → 400。
2. `:1104` `resolveScope(viewLabIds, visibleCultureIds)`。**返回 false 时抛 `notFound`（404），不是 403**——`resolveScope:2476` 对「操作者不可得」抛 `PERMISSION_DENIED` 403，但「有操作者、两个范围都空」返回 false，由调用方转 404。这是本条与 `resolveScope` 内部两处不同码的分界。
3. `:1108` `selectWorkflowInstanceDetail(workflowId, 范围, 范围)`，为空 → 404「工作流实例不存在或不在可读范围」。
4. `:1114` `pilotWorkflowTime(subflowCode)`：中试四码（`connect_feed_unit_pilot`、`replace_feed_liquid_pilot`、`end_culture_pilot_normal`、`end_culture_pilot_abnormal`）用 `PilotWorkflowTimestampViews.Instance`，其余用 `WorkflowInstanceView`。
5. `:1116`—`:1133` 基础字段：`workflowId`、`cultureId`、`labId`、`subflowCode`、`state`、`applicationState`、`objectVersion`、`actor`、`startedAt`、`endedAt`。`actor` 对 W07 有旧格式兼容：`actor_snapshot` 若含 `actorUserId` 而无 `userId`，就地转成 `Person{userId, displayName, kind=USER}`（`:1125`—`:1130`）。
6. `:1134`—`:1154` W07 专属：`controllerNo`；若 `feedUnitMode=CONTROLLER_CHANNEL` 则 `W07LogicalChannelSupport#validateSelection` 校验后填 `deviceId` 与 `logicalFeedingSlot`（此时 `mass=null`）；`bottle.reactorId` 合法才作为展示 ID，非法时**不阻断**（注释「展示缺失不得阻断原 STOP」）；`workflowDisplayReader.read` 补展示上下文。
7. `:1158`—`:1174` 中试结束培养：`PilotWorkflowFrozenStepProjector.populate`、`PilotEndCultureContextProjector.project`、卡片指标、`PilotEndCultureModeService.project`、异常分支 `pilotEndCultureAbnormal.project`、`executionMode` 取快照；`pilotEndCultureCancel.assertCurrentAccess` 的 **403／404 被降级为 `endCultureCanOperate=false`**（只影响按钮，不影响读取）。
8. `:1175`—`:1182` W01 中试连接补料：冻结步骤投影 ＋ `executionMode` ＋ `pilotContext`。
9. `:1183`—`:1208` W02 中试更换料液：有 `batchRootWorkflowId` 则填 `batchId`；冻结步骤投影；`pilotReplacementSimulation.assertCurrentAccess` 的 403／404 降级为 `replacementCanOperate=false`（注释 `:1193` 明确「The existing query scope authorized frozen history; losing OPERATE only removes controls/options」）；`OPEN` 且可操作时才读新袋候选（`readBagCandidates`），候选归属不完整 → `FACTS_UNAVAILABLE` 503；`executionMode` 硬写 `SIMULATION`。
10. `:1209`—`:1212` `steps(workflowId, pilotTime)`；`executionMode` 回填到每个步骤；`pumpRefs` 由 `selection.channels` 推出（若 `bottle` 存在则只保留匹配项）；`allowedOperations = allowedWorkflowOperations(state, steps)`。
11. `:1213`—`:1224` W07 物理链：若当前步骤为 `IN_PROGRESS` 的预填充步，用 `M07WorkflowPrimeOperationPolicy.resolve` 重算允许操作（输入为步骤执行束、命令计数、未决命令计数、已执行停止数）。
12. `:1225`—`:1234` 模拟流程（非结束培养）：`pumpRefs` 取更换泵或首个泵；按活动步骤给 `SET_AUTO`／`PRIME_START`／`PRIME_STOP`；不可操作或无活动步骤 → 空。
13. `:1235`—`:1241` 结束培养：`pumpRefs` 取模式泵；仅当可操作、模式非空、存在 `MODE_CONFIRM` 的 `IN_PROGRESS` 步骤、实例 `OPEN` 时给 `SET_MANUAL`。
14. `:1242` W03 批次成员：`benchConnectionBatches.populate(view, row)` 补批次上下文。
15. `:1243`—`:1255` W07 逻辑通道：`projectContext` ＋ 从第 2 步表单快照取 `loadedGrams`（已完成）或 `lastConfirmedGrams`（未完成）回填 `logicalFeedingSlot.mass`。

语句：

| 调用点 | 方法 | 语句 |
|---|---|---|
| `:1108` | `RunWorkflowInstanceMapper#selectWorkflowInstanceDetail` | `RunWorkflowInstanceMapper.xml:89`（含范围片段） |
| `:1157`→`steps:2414` | `RunWorkflowStepMapper#selectWorkflowSteps` | `RunWorkflowStepMapper.xml:118` |
| `:1161`、`:1177`、`:1188` | 同上一句（冻结步骤再读一次） | 同上 |
| `:1220`—`:1223` | `workflowExecutions.selectStepExecutions`、`countWorkflowCommands`、`countUnresolvedWorkflowCommands`、`countExecutedStepStops` | XML `:9`、`:16` 等 |

关键拒绝：400 ×2（空 id、非十进制）、403 ×1（操作者不可得）、404 ×2（两范围皆空、行缺失或范围外）、503 ×1（新袋候选不完整）。**降级不拒绝**的两处：中试结束与 W02 的操作权 403／404 只清空 `allowedOperations`。

观察：本条与 §4 的 bench-end 详情在范围口径上不同——本口把 `viewLabIds`／`visibleCultureIds` **写进 SQL**，bench-end 只按主键读再用 M03 事实做闸门。同一模块两种做法并存，登记为形态差异。

未核（F）：`PilotWorkflowFrozenStepProjector`、`PilotEndCultureContextProjector`、`PilotEndCultureModeService`、`PilotEndCultureAbnormalService.project`、`PilotReplacementContextProjector`、`PilotWorkflowContextProjector`、`W07LogicalChannelSupport` 七个投影的内部字段级规则；`workflowDisplayReader.read`；`readBagCandidates` 的候选口径。

## 13. `operateWorkflowStep` — POST `/run/workflows/{id}/steps/{stepId}`（M07-025）

| 项 | 值 |
|---|---|
| Controller | `:189`—`:200`：`run:workflow:operate`、`@ManagementGuardedWrite`；`startCulture.owns(id)` → `startCulture.step(id, stepId, cmd.startCulture(), writeMeta)`，否则回填 `id`／`stepId`／两个头 → 通用步骤 |
| 设计位置 | `接口目录与契约定位.md:314`—`:318`（`action:SAVE/NEXT/COMPLETE/SKIP`）；`开始培养工作流详细设计.md:296`（`action=VALIDATE_NEXT/BACK/SKIP/CONFIRM/COMPLETE` 等） |
| 应用服务 | 通用：`RunWorkflowApplicationApplicationServiceImpl#operateWorkflowStep:1302`—`:1357`；开始培养：`StartCultureApplicationService#step:226`—`:230` → `act:235`—`:316` |
| 消费者 | `runWorkflowApi.step:716`（3 个页面）＋ `startCultureApi.step:357` |

**同一路由两套动作词表**（这是本口最重要的结构事实）：

| 实例归属 | 词表 | 依据 |
|---|---|---|
| 开始培养实例（`run_start_culture_session` 有该 workflow） | `VALIDATE_NEXT`／`BACK`／`SKIP`／`CONFIRM`／`COMPLETE`／`SIMULATE_PRIME_START`／`SIMULATE_PRIME_STOP`／`SIMULATE_CONFIRM` | `act` 的 `switch`（`:264`—`:295`），其他动作 → 400「INPUT_INVALID: unsupported action」 |
| 其他实例 | `SAVE`／`NEXT`／`COMPLETE`／`SKIP`（W03 通用链）；各子流程另有自己的分支 | `:1386`—`:1392` |

三份写法各不相同：`接口目录与契约定位.md:318` 只写四个动作；`开始培养工作流详细设计.md:296` 写五个动作并含 `pageSessionId`／`visitNo`；源码开始培养分支实际接受**八个**（多出 `SIMULATE_PRIME_START`／`SIMULATE_PRIME_STOP`／`SIMULATE_CONFIRM`）。三者互不覆盖。**登记为设计内部不一致（并叠加一处设计未覆盖源码存在项），不自行选边**（依据：现行 AGENTS §6 文档冲突与权威顺序；旧稿此处引作「AGENTS §2.3」，该编号在现行文件不存在，见 `03-…md` §10.1；另有用户本轮明确指令「仍不能解释的列出精确冲突和影响，由主 agent 汇总」）。逐条建议见 `03-…md` §3.1 与 §6.4。

通用链的正常路径：

1. `:1304` `requireFreshUsageTransaction`，外层事务已存在 → 400。
2. `:1307` `stepId` 由 `stepId ?? stepInstanceId` 取；`:1308` `requestId` 与 `expectedVersion` 必填，否则 400。
3. `:1309` `selectWorkflowInstanceDetail(workflowId, null, null)` 作为 marker（无范围条件，仅用于判形状）。
4. `:1310` `requireSingleWasteInstance(marker)`：W08 **批次成员** → `STATE_CONFLICT` 409「废液清理批次须通过整批入口处理，不允许单瓶推进或取消」。W08 单实例（无 `batchRootWorkflowId`）放行。
5. `:1311` `isLogicalW07(marker)`。
6. `:1312`—`:1316` 组 payload：`workflowId`、`stepInstanceId`、`action`、`expectedVersion`、`rows`、`skipReason`、`skipConfirm`、可选 `typedPayload`。注释 `:1315` 说明「W01 rejects this foreign payload; retain it in the digest so replay cannot bypass that rejection」。
7. `:1317`—`:1320` `scopedEndCultureWorkflow(workflowId)`；若有 `reason` 但不是中试异常结束 → 400「异常结束原因仅适用于中试异常结束培养」。
8. `:1321`—`:1328` 结束培养实例额外把 `pageSessionId`／`visitNo`／两个期望版本／`completeConfirm`／`reason` 放进 payload。
9. `:1329`—`:1337` 选守卫码：`finalEnd` → `M07_END_CULTURE_COMPLETE`；非结束培养 → `M07_025`；其他结束培养 → `M07_025_END_CULTURE`。`finalEnd` = 中试正常结束的末步（`COMPLETE_CULTURE`）或异常结束的直通判定。
10. `:1338`—`:1341` 回调分派：异常直通 → `pilotEndCultureAbnormal.completeDirect`；正常末步 → `pilotEndCultureComplete.complete`；逻辑 W07 → `w07LogicalChannels.updateStep`；其余 → `updateW03Step`。
11. `:1342` 逻辑 W07 事后 `assertCurrentAccess`（回执重放也走到这里）。
12. `:1343`—`:1347` 回执重放：非逻辑路径下重读实例，W06 需再验实验室操作权。
13. `:1348`—`:1355` 回读步骤行组 `WorkflowStepView`；模拟实例补 `executionMode=SIMULATION`；结束培养补 `executionMode` 并`assertCurrentAccess`。

`updateW03Step`（`:1359`—`:1435`）的二级分派：

| 顺序 | 条件 | 去向 |
|---|---|---|
| 1 | `selectWorkflowForUpdate` 为空 | 404 |
| 2 | 中试异常结束 | `pilotEndCultureAbnormal.submitLocked` |
| 3 | `PilotEndCultureCancelService.supports` | `pilotEndCultureMode.completeLocked` |
| 4 | `isBenchBatch` | `STATE_CONFLICT` 409「批次连接步骤须使用整页受控入口」 |
| 5 | W08 批次（再判一次） | 409（`requireSingleWasteInstance`） |
| 6 | `replace_feed_liquid_pilot` | `requireSingleReplacementInstance` → `pilotReplacementSimulation.stepLocked` |
| 7 | W01 且为模拟 | `pilotWorkflowSimulation.stepLocked` |
| 8 | W05／W06／W07／W08 | 各自 `updateW05`／`updateW06Step`／`updateW07Step`／`updateW08Step` |
| 9 | 非 W03 或状态非 OPEN／IN_PROGRESS | 409「当前工作流状态不允许步骤操作」 |
| 10 | W03 通用动作 | `SAVE`（PENDING／IN_PROGRESS 保持）、`NEXT`（PENDING→IN_PROGRESS）、`COMPLETE`（IN_PROGRESS→COMPLETED）、`SKIP`（PENDING→SKIPPED，需 `skipConfirm=true` 且 `skipReason` 非空）；其他 → 400「步骤动作或跳过确认无效」 |

第 10 支的写入：

1. `:1393` `expectedVersion` 与行 `objectVersion` 比对，不等 → `VERSION_CONFLICT` 409。
2. `:1397` 组表单快照 `{schemaVersion:1, workflowKind:W03, stepCode, rows, skipReason}`。
3. `:1400` `updateWorkflowStepByVersion(...)`，不等于 1 → 409。
4. `:1402` `terminalStep` = 终态且 `countStepsAfter==0`；为真时 `:1407` 调 `completeW03Connection`（`:1698`—`:1789`，本批只核到调用点与「返回 `connectionGeneration`」）。
5. `:1411`—`:1425` 写 `run_event`，`eventType=WORKFLOW_STEP_UPDATED`，幂等键 `M07:WORKFLOW_STEP:{workflowId}:{stepId}:{requestId}`，须 1 行。
6. `:1429`—`:1433` 审计前后快照，标题「工作流步骤/操作」。

关键拒绝（通用链）：400 ×4（外层事务、缺 requestId／expectedVersion、动作非法、reason 误用）、404 ×3、409 ×6 类（W08 批次、bench 批次、状态、版本、CAS、W02 批次）、503 ×若干（子流程内部）。

观察一：`requireSingleWasteInstance` 在 `:1310` 与 `updateW03Step:1368` 被调用两次，第二次对已通过第一次的 W08 单实例是幂等的，但两次之间状态可能变化——第二次发生在 `FOR UPDATE` 之后，是真正的并发闸门。登记为实现细节，不判缺陷。

观察二：开始培养分支的 `act` 在失败时不会产生部分写入，因为它把「状态机推进」与「逐成员 `transition`」放在同一守卫回调内，任一 `require` 失败即整体回滚。这与 §5 的 bench-end 批量语义不同（后者也是全批回滚，但用 `affected` 逐个 CAS）。

未核（F）：`pilotEndCultureAbnormal.submitLocked`／`pilotEndCultureMode.completeLocked`／`pilotReplacementSimulation.stepLocked`／`pilotWorkflowSimulation.stepLocked`／`w07LogicalChannels.updateStep`／`updateW05`／`updateW06Step`／`updateW07Step`／`updateW08Step` 九个下游分支的内部规则；`completeW03Connection` 的完整写入集；`act` 内 `StartCulturePolicy.requireAction` 的动作矩阵。**本口 E 记未核**：`updateWorkflowStepByVersion`、`run_event` 写入与 `completeW03Connection` 均按调用点与须影响行数记录，对应 XML 正文本轮未打开。

## 14. `operateWorkflow` — POST `/run/workflows/{id}/operations`（M07-026，`202 ACCEPTED`）

| 项 | 值 |
|---|---|
| Controller | `:206`—`:219`：`run:workflow:operate`、`@ManagementGuardedWrite`、`@ResponseStatus(HttpStatus.ACCEPTED)`。`startCulture.owns(id)` → 直接抛 `ManagementGuardRejectException(CONFIGURATION_INCOMPLETE, "SC-Q04/SC-Q09：取样预填充或OPC重启协议待确认，当前未发出设备命令")` |
| 设计位置 | `接口目录与契约定位.md:320`—`:324`（`operation:SET_AUTO/PRIME_START/PRIME_STOP`，→ 202）；`开始培养工作流详细设计.md:297`（`action=SAMPLE_PRIME_START/SAMPLE_PRIME_STOP`，202 只表示意图受理） |
| 应用服务 | `RunWorkflowApplicationApplicationServiceImpl#operateWorkflow:1789`—`:1829`；`prepareW03Command:1923`—`:2066` |
| 消费者 | `runWorkflowApi.operate:742`（`pilot-replace`、`feeding-workflow/connection.ts`、`feeding-liquid-replenishment`、`pilot-connect/workflow.ts`、`bench-connection-workflow.ts`） |

正常路径（通用链）：

1. `:1791` `requireFreshUsageTransaction`。
2. `:1794` `requestId`／`expectedVersion` 必填，否则 400「物理操作缺少requestId、expectedVersion或pumpRef」。
3. `:1796`—`:1799` `operation` 大写归一；`SET_MANUAL` 单独走 `operateEndCultureMode`（中试结束培养专用，见下）；其余只允许 `SET_AUTO`／`PRIME_START`／`PRIME_STOP`，否则 400。
4. `:1800` `selectWorkflowInstanceDetail(workflowId, null, null)`。
5. `:1801` W08 → `STATE_CONFLICT` 409「废液清理仅记录人工确认，不支持设备启停」。
6. `:1803` 逻辑 W07 → `w07LogicalChannels.operateWorkflow`（**整条真实设备链不经过下面的守卫码 `M07_026`**）。
7. `:1806` W03 显式模拟实例 → `benchConnectionBatches.operateSimulation`（注释 `:1804`：「开关关闭也不会跌入真实设备链」）。
8. `:1809` 中试模拟流程 → `operatePilotSimulation`。
9. `:1811` `pumpRef` 必填，否则 400。
10. `:1812` `workflowDeviceCommand == null` → `DEPENDENCY_UNAVAILABLE` 503「设备命令提供方未部署：缺核准网关配置，不能创建不可派发的命令意图」。
11. `:1814` `workflowDispatcher == null` → 503「工作流派发消费者未部署」；`assertAvailable()`。
12. `:1816` **`SET_AUTO` 恒定拒绝**：`CONFIGURATION_INCOMPLETE` 409「SET_AUTO非计量执行规格尚缺核准契约，不能伪造正目标量」。
13. `:1817`—`:1822` 组 payload（`workflowId`、`operation`、`expectedVersion`、`pumpRef`、`speed`、`primeGrams`）→ `guard.execute(M07_026, ..., prepareW03Command)`。
14. `:1823` `workflowDispatcher.dispatchPrepared(commandId)`。**派发异常被吞**（注释 `:1824`：「Intent committed: keep original request identity for reconciliation.」）——即「意图已提交，派发失败不回滚、不改请求身份」。
15. `:1825`—`:1828` 回读命令行组 `ActionResult`：`state` 取命令行状态（缺失时 `PREPARED`），`applicationState` 恒 `PENDING`。

`prepareW03Command` 的实质内容（`:1923`—`:2066`）：

1. `:1926` 若是 W03 批次成员，先 `authorizePhysicalMember`；`:1929` 再核冻结归属未变（`cultureId` 与 `selectionSnapshot` 均相同，否则 409「批次成员冻结归属已变化」）；`:1932` `assertPhysicalMember`。
2. `:1933` 只允许 W03／W07 且状态 OPEN／IN_PROGRESS，否则 409。
3. `:1935`—`:1937` `CultureOperationFactsPort` 核培养当前操作范围，lab／culture 不匹配 → `PERMISSION_DENIED` 403。
4. `:1938` `PRIME_START` 时培养生命周期 ∈ {NOT_STARTED, RUNNING, DELAYED}，否则 409。
5. `:1939`—`:1941` 工作流版本比对，不等 → 409。
6. `:1943` 快照必须有 `connectionId` 与 `channels` 数组，否则 `CONFIGURATION_INCOMPLETE` 409。
7. `:1948` `pumpRef` 三字段齐全，否则 400。
8. `:1952`—`:1955` 请求泵必须在冻结通道内且 `pumpType` 一致，否则 `PERMISSION_DENIED` 403「请求泵不属于工作流启动时固定的通道」。
9. `:1956` W07 还要求泵与通道等于 `selection.bottle`，否则 403。
10. `:1959`—`:1967` `WorkflowPumpCommandSpecPort#resolveWorkflowPumpCommandSpec`，规格必须与冻结设备身份完全一致且六个字段非空，否则 `RESOURCE_FACTS_UNAVAILABLE` 503。
11. `:1968` `validateWorkflowCommand`（`:2087`）。
12. `:1969` 控制器身份必须等于 `BENCH_CONTROLLER:{connectionId}`，否则 503。
13. `:1971`—`:1973` 取活动步骤（`FOR UPDATE`），无步骤 → 409；`validateOperationStep`（`:2097`）校验操作与步骤码匹配。
14. `:1976` 锁步骤执行束；`:1978` W07 用 `M07WorkflowPrimeOperationPolicy.resolve` 再判一次，不符 → 409。
15. `PRIME_START`：已有执行 → 409「本步骤已有物理执行，必须核对原执行，不能重复预填充」；冻结 `executionSpec` profile；W07 缺 `observationPolicy` → 503。
16. `PRIME_STOP`：必须**唯一**原执行（否则 409）；校验原执行的配置修订、适配器实例、`pumpRef`、能力修订全部一致（否则 `VERSION_CONFLICT` 409）；`markStopping` 须 1 行（否则 409）。
17. `:2008` 冻结资源组必须完整覆盖泵与控制器且无重复，否则 503。
18. `:2012`—`:2016` 逐资源键取固定执行器归属（必须 `ENABLED` 且同 lab），`assertExecutor`。
19. `:2017` 存在未决命令 → 409「存在未决物理命令，须先按原身份查单」。
20. `:2019` `claimResource` 逐键取 fence。
21. `:2022`—`:2061` 写 `run_workflow_execution`（新执行）、初始计量段、`run_command`（`insertCommand` 须 1 行）、注册通信资源用量、追加 `COMMAND_PREPARED` 事件。
22. `:2063` 审计快照（`RUN_COMMAND`）。

`SET_MANUAL` 支（`operateEndCultureMode:1842`—`:1866`）：`expectedVersion == Long.MAX_VALUE` → 409「模式确认版本已耗尽」；`scopedEndCultureWorkflow` 为空 → 400「切手动仅用于中试结束培养」；守卫码 `M07_026_SIMULATION`；回执 `state=SIMULATED`、`applicationState=APPLIED`、`executionMode=SIMULATION`。

语句：

| 调用点 | 方法 | 语句 |
|---|---|---|
| `:1800`、`:1925`、`:1927` | `selectWorkflowInstanceDetail`／`selectWorkflowForUpdate` | XML `:89`／`:33` |
| `:1971` | `selectActiveWorkflowStepForUpdate` | `RunWorkflowStepMapper.xml:24` |
| `:1976` | `lockStepExecutions` | 执行束，未逐行展开 |
| `:2056` | `RunCommandMapper#insertCommand`（接口 `:57`） | XML 未在本批展开 |
| `:1998`、`:1825` | `selectCommandForDispatch`（接口 `:39`） | 同上 |
| `:2017` | `selectUnsettledCommandsForUpdate`（接口 `:81`） | 同上 |

关键拒绝：400 ×5、403 ×4、409 ×10 类、503 ×6 类。

**结论级事实（须原样保留，不得改写为「已实现」）**：

1. M07-026 在真实设备链上**只能执行 `PRIME_START`／`PRIME_STOP`，且只限 W03／W07**。`SET_AUTO` 与 W08 恒拒绝，其余子流程落 `STATE_CONFLICT`。因此设计 `接口目录与契约定位.md:324` 写的「`operation:SET_AUTO/PRIME_START/PRIME_STOP`」中，`SET_AUTO` 当前不可用。
2. 对**开始培养实例**，本口在 Controller 层直接拒绝（`CONFIGURATION_INCOMPLETE`），文案点名 `SC-Q04`（取样预填充协议）与 `SC-Q09`（OPC 服务身份／健康观测／重启协议）两项待确认。这是「协议待确认」型拒绝，不是「未实现」，也不是「必须客户补协议」——归属方本批未核，见 `03-…md` §2。
3. `202` 只代表**命令意图已提交**。派发失败被吞，回执 `applicationState=PENDING`。不能据此认为设备已动作。
4. 逻辑 W07 与两类模拟实例**不经过 `M07_026` 守卫码**，分别走 `M07_026_W03_SIMULATION` 等专用码。按守卫码统计覆盖会把它们算成缺口。

未核（F）：`workflowDeviceCommand`／`workflowDispatcher` 的部署条件与配置项；`M07WorkflowPrimeOperationPolicy.resolve` 的判定矩阵；`WorkflowExecutionSpecFreezer` 与 `M07CommandInvocationWorker.hash` 的规范形；`claimResource` 的 fence 语义；`insertCommand`／`selectCommandForDispatch`／`selectUnsettledCommandsForUpdate` 三条语句的具体 SQL（**本批只在 Mapper 接口定位，未打开对应 XML**，故这三条只到「接口级」而非「语句级」）。

## 15. `cancelWorkflow` — POST `/run/workflows/{id}/cancel`（M07-027）

| 项 | 值 |
|---|---|
| Controller | `:221`—`:232`：`run:workflow:operate`、`@ManagementGuardedWrite`（**无 `@ResponseStatus`**）；`startCulture.owns(id)` → `startCulture.cancel(id, cmd.startCulture(), writeMeta)`，否则回填三字段 → 通用取消 |
| 设计位置 | `接口目录与契约定位.md:326`—`:330`；`开始培养工作流详细设计.md:298`（未闭合 202、安全完成 200、重复返回原回执） |
| 应用服务 | `RunWorkflowApplicationApplicationServiceImpl#cancelWorkflow:2153`—`:2194`；`cancelConnectedWorkflow:2239`—`:2393` |
| 消费者 | `runWorkflowApi.cancel:763`（`waste-liquid-clear`、`manual-feed`、`feeding-liquid-replenishment`）＋ `startCultureApi.cancel:397` |

正常路径：

1. `:2156` `workflowId` 归一，非法 → 400。
2. `:2157` `requestId`／`expectedVersion` 必填，否则 400。
3. `:2159` marker 查询；`:2160` `requireSingleWasteInstance`（W08 批次成员 → 409）。
4. `:2161` `isLogicalW07`。
5. `:2166` `requireNoOuterTransaction()`（`:2208`—`:2216`）：外层事务已存在 → 400，文案明确「守卫事务必须由本入口自行开启，否则按持有者的资源集合枚举不再完整（失败关闭：零锁读、零释放、零写入）」。
6. `:2168` `guard.execute(M07_027, ..., 回调)`：逻辑 W07 → `w07LogicalChannels.cancelWorkflow`；否则 `cancelConnectedWorkflow`。
7. `:2173` 重读实例，为空 → 404。
8. `:2175`—`:2178` 事后校验：逻辑 W07 的 `assertCurrentAccess`；中试结束培养的 `assertCurrentAccess`；W06 的实验室操作权。
9. `:2179`—`:2192` 回执：`objectId=workflowId`、`objectVersion` 取**重读后**的版本、`state`／`applicationState` 取重读值；模拟流程追加 `executionMode=SIMULATION` 并 `assertPilotSimulationAccess`。

`cancelConnectedWorkflow` 的分派（`:2242`—`:2393`）：

| 顺序 | 分支 | 行为 |
|---|---|---|
| 1 | `selectWorkflowForUpdate` 为空 | 404 |
| 2 | 中试结束培养（`PilotEndCultureCancelService.supports`） | `pilotEndCultureCancel.cancelLocked` |
| 3 | `isBenchBatch` | 409「批次成员只能通过受控移除入口处理」 |
| 4 | W08 批次 | 409（`requireSingleWasteInstance`） |
| 5 | W06 | 需 `cancelConfirm=true`（否则 400）；状态必须 OPEN／IN_PROGRESS 且 `applicationState=NONE`（否则 409）；版本比对（否则 409）；`countUnsafeWorkflowCompletionFacts==0`、`countWorkflowCommands==0`、`countW06MaterialSessions==0`（否则 409「W06已有应用事实或设备活动，不能按未保存流程取消」）；`cancelOpenSteps` ＋ `cancelWorkflowByVersion(CANCELLED, NONE)` |
| 6 | W02 | `requireSingleReplacementInstance`（批次成员 → 409「本次更换料液须通过整页批次接口统一推进或取消」）→ `pilotReplacementSimulation.cancelLocked` |
| 7 | W01（`connect_feed_unit_pilot`） | 模拟 → `pilotWorkflowSimulation.cancelLocked`；否则 `pilotWorkflowDraftCancel.cancelLocked` |
| 8 | W05 | `manualOperationScope(..., "M07-027")`；状态必须 OPEN／IN_PROGRESS（否则 409「已提交的手工补料不可取消」）；版本比对；`cancelOpenSteps` ＋ `cancelWorkflowByVersion` |
| 9 | 非 W03／W07／W08 | 409「当前取消实现仅支持W03/W07/W08工作流」 |
| 10 | W03／W07／W08 通用链 | 见下 |

第 10 支（`:2291`—`:2392`）：

1. `:2291` 状态必须 OPEN／IN_PROGRESS，否则 409。
2. `:2293` 版本比对，不等 → `VERSION_CONFLICT` 409。
3. `:2296`—`:2304` W07 额外：`countUnsafeWorkflowCompletionFacts` 为 null → `RESOURCE_FACTS_UNAVAILABLE` 503「W07取消所需停止、结算及资源释放事实不可核验」；非 0 或存在未决命令 → 409「请先停止预填充并等待安全结算和资源释放后再取消」。
4. `:2314` `releaseAuthorization.lockOwnedGuardRows("WORKFLOW", workflowId)` 取本次完整资源集合（非锁窄读→去重→ASCII 排队→逐键主键锁读→锁内逐行重核）。
5. `:2315`—`:2320` 分流判据：`commandCount==0` 且所有守卫行 `provesNotSent` → `releasableDraftClaims`；`guards.isEmpty() || releasableDraftClaims` → `directCancel`。
6. `:2321`—`:2323` `targetState` = `CANCELLED` 或 `NEEDS_RECONCILIATION`；`applicationState` = `NONE`／`UNKNOWN`（有 `UNKNOWN` 物理态时）／`PENDING`。
7. `:2325`—`:2341` 可释放草稿：逐守卫行生成 `NOT_SENT` 证据并 `authorizeAndRelease`（与后台核准释放同一套逐行资格校验＋版本／fence 双 CAS）。
8. `:2342`—`:2352` 非直连：`HELD` 行 `markGuardStoppingByVersion`，CAS 失败 → 409「资源守卫已变化」。
9. `:2353` `cancelWorkflowByVersion(...)` 须 1 行，否则 409。
10. `:2356` 直连时 `cancelOpenSteps`。
11. `:2359`—`:2370` 事件 `WORKFLOW_CANCELLED`（直连）或 `WORKFLOW_CANCEL_PENDING`，幂等键 `M07:{eventType}:{requestId}`。
12. `:2376`—`:2381` 审计前后快照，标题「工作流/取消」。
13. `:2383`—`:2388` `ResourceTransactionRejectException` 就地翻译为守卫拒绝（原码原文外抛），整组回滚、占用保持。

语句：

| 调用点 | 方法 | 语句 |
|---|---|---|
| `:2159`、`:2173`、`:2242` | `selectWorkflowInstanceDetail`／`selectWorkflowForUpdate` | XML `:89`／`:33` |
| `:2255` | `countUnsafeWorkflowCompletionFacts` | `RunWorkflowStepMapper.xml:75` |
| `:2256`、`:2315` | `countWorkflowCommands` | `RunWorkflowStepMapper.xml:9` |
| `:2301` | `countUnresolvedWorkflowCommands` | `RunWorkflowStepMapper.xml:16` |
| `:2257` | `countW06MaterialSessions` | `RunWorkflowInstanceMapper.xml:59` |
| `:2261`、`:2284`、`:2356` | `cancelOpenSteps` | `RunWorkflowStepMapper.xml:63` |
| `:2262`、`:2285`、`:2353` | `cancelWorkflowByVersion` | `RunWorkflowInstanceMapper.xml:37` |

关键拒绝：400 ×4（id、缺参、外层事务、W06 缺确认）、404 ×3、409 ×11 类、503 ×2。

观察一：**本条回执的 `state`／`applicationState` 取自重读行，不是取自 `outcome`**。因此「安全收尾」分支返回的是 `NEEDS_RECONCILIATION`／`PENDING`，与「直连取消」的 `CANCELLED`／`NONE` 在响应体上可区分。设计 `开始培养工作流详细设计.md:298` 写「未闭合返回 202，安全完成返回 200」——**源码在 Controller 上没有按此区分 `@ResponseStatus`**（本口没有 `@ResponseStatus`，落默认 200）。这是设计—源码差异，登记见 `03-…md` §2 的 D-02。

观察二：`M07_027` 一个守卫码覆盖 9 类子流程，实际分支靠方法内 `subflowCode` 判断。按守卫码统计会得到「M07-027 已实现」的印象，但 9 条分支的实现深度不同（例如 W05 分支无审计前后快照，传的是空列表 `:2287`）。登记为观察。

未核（F）：`releaseAuthorization`（`M07ReleaseAuthorization`）的 `provesNotSent`、`notSentEvidenceFor`、`authorizeAndRelease` 内部规则；`lockOwnedGuardRows` 的锁协议实现；`pilotEndCultureCancel`／`pilotReplacementSimulation`／`pilotWorkflowSimulation`／`pilotWorkflowDraftCancel`／`w07LogicalChannels` 五个下游；`markGuardStoppingByVersion` 的 SQL。

## 16. 横向对照（15 口共性）

| 维度 | 事实 |
|---|---|
| 权限码 | 11 口用 `run:workflow:query`／`run:workflow:operate`／`run:workflow:start` 三个码；本类**没有**独立的 bench-end 权限码，bench-end 六口复用 `run:workflow:query`／`operate` |
| 管理版本 | 读口全部带 `@CurrentManagementRevision`；写口全部带 `@ManagementGuardedWrite`，`WriteMeta` 由框架注入。**没有例外** |
| 外层事务 | `startWorkflows` 与 `operateWorkflowStep` 用 `requireFreshUsageTransaction`；`cancelWorkflow` 用 `requireNoOuterTransaction`；`operateWorkflow` 未显式检查，但 `prepareW03Command` 内的 `FOR UPDATE` 依赖同一假设。**这是三条不同写法的同一约束**，登记为风格不统一，不判缺陷 |
| 范围判定 | 两种并存：024／025／026／027 把范围写进 SQL 或经 `CultureOperationFactsPort`；bench-end 六口只按主键读 + `BenchEndCultureFactsPort#list` 做闸门。同一模块两种做法 |
| 拒绝降级 | 三处把 403／404 降级为「不给按钮」而不是拒绝：024 的中试结束、024 的 W02、W03 批次的动作集（`05-…md` §5.4）。这是既有设计，不是缺陷 |
| 模拟标识 | 所有模拟路径在响应或证据里写 `executionMode=SIMULATION`；bench-end 六口恒为 `SIMULATION`，`actBenchEndBatch` 的证据另有 `deviceCommandSent=false` |
| 消费者 | bench-end 六口 **0 页面引用**；其余 9 口都有真实页面 |
| 运行层 | 15 口全部 `NOT_VERIFIED`：未编译、未单测、未连库、未发 HTTP、未开浏览器、未连设备 |
