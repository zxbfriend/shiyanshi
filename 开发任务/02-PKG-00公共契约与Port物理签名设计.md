# PKG-00公共契约与Port物理签名设计

## V5.1只读事实与检测项编号增补（2026-11-07开发批）

| 提供方及物理签名 | 实际消费者与边界 |
| --- | --- |
| M02 `DeviceUsageDeviceFactsPort.readVisible(long actorUserId,Long labId,String detectClass) -> List<Device>`，`Device(detectorId,labId,detectClass,modelName,detectorCode)` | M05-069/070设备使用记录。实验室VIEW范围在M02 SQL读取标签前下推，明确空授权为空，权限或事实源失败抛DEPENDENCY_UNAVAILABLE；全局身份与空集合分开。只读取M02检测仪/型号/实验室，不以当前设备状态筛掉历史派发，不以当前设备标签集合代替M05历史派发范围。设备标签缺失仍保留M05自身已授权历史行，标签留空。 |
| M03 `AlarmCultureMemberFactsPort.read(long cultureId,long labId,LocalDate businessDate) -> Members`，`Members(cultureId,batchId,projectId,labId,sourceLevel,userIds)` | M09后台告警CULTURE_MEMBER来源。M03核实真实培养/批次/项目与实验室；先选培养→批次→项目最近非空MEMBER配置层，再按业务日过滤过期成员，截止当日有效。选定层成员失效不向上补位；不混入SHARE、负责人或M06审批回退规则，不读取姓名或凭据。读取失败抛异常，不能当KNOWN_EMPTY。 |
| M03 `AlarmCultureMemberFactsPort.filterAlarmVisibleUsers(long cultureId,long labId,List<Long> userIds) -> List<Long>` | M09多来源候选接收人的当前对象范围重验；逐稳定ID复用当前实时权限，培养与实验室范围同时成立。无浏览器会话也不能借角色配置授予跨培养访问；权限不可得抛异常，不生成空资格结论。账号与渠道偏好归M01。 |
| M02 `ManualResultItemPort.resolve(List<Long> itemIds) -> List<Item>`，`Item(itemId,itemCode,shortName,unit,sourceRevision)` | M07-018真实手工结果登记，在原SYSTEM守卫事务带锁冻结Cedex检项编号/简称/单位与修订。原生41的GLC/LAC分类只取真实itemCode前三位，不能以shortName猜测。新登记缺itemCode拒绝，旧已持久原文不补造、不重算。 |

上述为本轮源码接线合同；单元/契约、HTTP、浏览器及部署状态分别见本轮开发报告，合同登记本身不表示运行验收通过。

## 后台补液生成来源增补（FEED-20261021）

| 提供方 / Port 方法 | Request → Response | 入口与边界 |
| --- | --- | --- |
| M03 `CultureGenerationPlanPort.readEffectiveForGeneration` | `CultureGenerationPlanQuery` → `CultureGenerationPlanSet` | `BACKGROUND_ONLY`；仅 `M07_TASK_GENERATION` 已取得 SYSTEM 的实际事务，声明对象为原 culture、资源集仅 `CULTURE:<id>`。不构造 HTTP Actor/TrustedCultureContext。 |
| M03 `CultureGenerationFactsPort.readFacts` | `CultureGenerationFactsQuery` → `CultureGenerationFacts` | `BACKGROUND_ONLY`；仅原 `M07_TASK_GENERATION` SYSTEM 事务及精确培养/补料槽/快照/代次/摘要。返回真实项目、批次、培养版本和初始重量四列；同节点 SAMPLING 须核验其独立原生效槽、唯一 APPLIED 回执及 M04 包摘要。缺重量或取样包保持未知，不补零、不借旧映射。 |
| M03 `CultureGenerationFactsPort.readFactsForExecution` | `CultureExecutionFactsQuery(taskId,cultureId,labId,feedingSnapshotId,feedingGeneration,feedingPackageHash)` → `CultureGenerationFacts` | `BACKGROUND_ONLY`；精确 `M07_RESOURCE_CLAIM` 原taskId、SYSTEM锁、真实事务。真实workflowNodeId由M03原快照解析，不能借用连接工作流实例ID。重用原M03槽/快照/APPLIED回执/取样映射核验，不借生成用途、不反锁M03、不创建或改写候选。未安装默认拒绝。 |
| M04 `GenerationPackagePort.decodeForExecution` | `ExecutionPackageQuery(taskId,packageQuery)` → `TemplatePackage` | `BACKGROUND_ONLY`；同一原taskId的claim事务，逐字核原固定包schema2/3、来源与摘要；原decodeForGeneration仍拒claim。未安装默认拒绝。 |
| M04 `GenerationPackagePort.decodeForGeneration` | `GenerationPackageQuery` → `TemplatePackage` | 同一后台用途、培养及事务；按原 schema2/3、来源身份、工程段和既有 canonical hash 解释明确类别的 FEEDING 或 SAMPLING 固定包。六参请求显式携带 `templateKind`；原五参构造只表示既有 FEEDING。类别须与原包相同，不读模板 latest、不授任务创建权限。 |

M03 Query 为 `{cultureId,labId,maximumPlans}`；上限是整批读取边界，SQL 读取 `maximumPlans+1` 检测超限，超过即整批拒绝。Response 的 `plans` 是不可变完整集合；仅真实空集返回空，读取失败不得伪装为空。每项保留 `{cultureId,labId,cultureVersion,workflowNodeId,snapshotId,parameterGeneration,packageHash,activationReference,verifiedPackageJson}`。M04 Query 为 `{cultureId,workflowNodeId,snapshotId,expectedPackageHash,fixedPackage}`。以上类型均在各提供方 `service.port.m0x.model`，没有浏览器接口。

M03 先核培养归属，再读现行 FEEDING 槽、不可变快照和匹配 `culture + snapshot + generation + APPLIED` 的唯一应用历史；查询最多 2 条以识别异常重复。后续候选的 DISCARD/CONFLICT 会更新槽的最近回执，因此不得拿最近 `state.application_receipt` 代替原生效应用历史。所有来源只读，不增加下游锁之后反锁 M03 的路径。原件按精确字段/类型、重复键、尾随 JSON、schema 和摘要核验；ID 不容错转型，方案生效不等于 SYSTEM 生成任务获批。

读取实现精确区分正式 `ApplicationReceipt/PolicyEvidence` 与 Q31 直接保存的新 `Q31PlanActivationEvidence`。后者独立承载 `{schemaVersion:1,route:BYPASS_Q31,sourceAction:CULTURE_FEEDING_PLAN,cultureId,labId,workflowNodeId,snapshotId,packageHash,cultureStateAtDecision,actorUserId,cultureVersion,planVersion,managementRevision,requestId,requestKey,requestHash,decisionKey,decisionHash,decidedAt}`，不得转成 M06 DIRECT。producer 从已锁培养和当前可信请求固定当时 DRAFT/NOT_STARTED/EXPIRED、actor、版本与哈希，同一 policy 原样写入应用行和回执；消费方与不可变 snapshot/application 的 actor、请求身份、原版本、时刻逐项核对并重算摘要，不以当前培养状态倒推。旧 `BYPASS_Q31` 简化件缺历史事实仍明确阻断，禁止回填或洗成新证据。

M03 参数审批投递的 APPLY 分支、Q31 直接生效分支与 M06 的 SYSTEM 任务创建政策须分别核验，不能由某一个 Port 的状态概括整个 M03。Q31 方案生效并不授权后台创建免审批任务。签名快照和入口来源 roster 同批登记；软件隔离测试不代表真实数据库或现场验收。

## 开始培养专项增补（SC-20261017）

新增开始培养Port设计登记（尚未生成源码）：M02 StartCultureDevicePort.resolve/observe；M03 CultureStartRegistrationPort.prepare/apply、CultureStartProfilePort.readEffective、CultureStartCompletionPort.applyInCurrentTransaction；M09 StartCultureAlarmPort.preview/validateDraft/applyInitial。类型化Query/Command/Receipt字段、提供方、同事务要求及失败语义以专题第7.3节为主合同，模型归各owner的port/m0x/model。M07新增SC-HTTP01/02/03/04及现有022～028扩展仍须按开发计划登记机器台账/签名测试；不能因本篇旧SIGNATURE_READY标记认为新增项已编译或接线。

最新保存规则（2026-10-17）：小试、中试均只在第4步点击“完成”并成功提交后保存业务数据；未完成页面刷新或取消后从第1步重新开始，不恢复表单或中间步骤。操作审计和设备安全收尾保留，必须当天完成的限制不变。

步骤时间记录：四步分别记录服务端开始/结束时间及结束原因；刷新重开新建尝试，旧时间审计保留，未知结束时间不伪造。时间留痕不构成业务表单的中间保存点。

2026-10-17整体复审补充：按专题V05执行原请求只读恢复、页面会话竞争、步骤动作矩阵、非空访问唯一键及M09纯校验；小试不依赖中试配置初始化。已有输入冲突的首启前纠错路径列为SC-Q12，尚未核准。

当前专题：[开始培养详细设计](../详细设计/07-补液运行与任务执行/开始培养工作流详细设计.md)；实施拆分：[开始培养开发计划](小试中试开始培养开发计划-20261017.md)。本次仅文档补充，业务代码、数据库、设备操作均未执行。


版本：PKG00-SIGNATURE-20260918-01
状态：**`PKG00_SIGNATURE_READY`**
性质：开发前设计冻结；本文不表示任何Java、XML、SQL或POM已经修改。

## 1. 目的和边界

本文是[骨架文件所有权与并行任务包](01-骨架文件所有权与并行任务包.md)中PKG-00的可执行补充，解决“只有能力名、没有物理方法签名”的问题。开发人员生成接口时不得再自行决定类名、方法名、入参或返回类型。

PKG-00只交付：

1. `futurefab-api-system`中的错误码、认证内部HTTP契约及认证DTO/VO；
2. `futurefab-system`中的公共响应原始类型、`NoBody`、跨模块Port接口及Port模型；
3. `futurefab-auth`和`futurefab-system`对`futurefab-api-system`的显式依赖；
4. 编译级契约测试。

PKG-00不创建Controller、ServiceImpl、Port适配器、Mapper、XML、SQL和业务逻辑，不修改M08，不伪造成功返回。M08未来只能消费业务模块已经发布的事件，不成为当前Port编译依赖。

## 2. 包和依赖冻结

### 2026-11-07 P4反应器离线图来源目标（尚未编码）

原`m05.OfflineStatisticsSourcePort.reactorPoints(StatisticsSource.Query)->List<StatisticsSource.Point>`为已批准P4原设备详情离线区的具名只读目标；不新增服务、页面、存储或通用质量框架。恰好一个正cultureId，原合法limit/from/to，devices/sourceIds不授本用途筛选；empty itemIds是本培养真实出现项目，不借在线当前目录，也不改变P1.read空项目语义。

按M05原读取权限、真实培养及每条实际检测lab先授权；读取每个真实result当前不可变revision并由原EffectiveResultReader核完整原件/更正链，保留独立复测/原unit/dayNumber，不用样品current_result指针或新字典抹历史。正常/缺测、质量、时刻、nullable单位/日序及有限白名单输出唯一沿[M08聚合§11](../详细设计/08-数据统计与工作台/工作台与反应器聚合设计.md#11-原反应器详情离线图切片目标合同尚未实现)。完整性故障不能当UNKNOWN/空成功；raw metadata不出HTTP，M08不重写M05核验规则。原Point复用，不扩ComparisonResult质量字段或新业务枚举。本节仅目标登记，当前Port/提供方/API10/真实页新消费尚未接线，NOT_IMPLEMENTED，未运行测试。

### 2026-11-07 CONFIG/PERFUSION最终正文与P2来源设计目标（尚未编码）

| 原能力/具名来源 | 最小目标及限制 |
| --- | --- |
| M03 `ParameterPackagePort.saveFixedParameterCandidate(FixedParameterCandidateCommand)` | 返回原ParameterCandidateResult。新m03.model命令仅actorUserId/requestId/sourceAction/cultureId/workflowNodeId/templateKind、expectedCultureVersion/expectedPlanVersion/expectedSlotVersion、可空expectedSourceObjectVersion（新选/更换模板必填）、可空confirmedPresetConflicts（原确认的精确预设源/泵集合）、reason和原TemplatePackage fixedPackage；只允许原具名CONFIG/PERFUSION源App，不是HTTP接收浏览器固定包。源App按最终正文调用原M04.freezeCulturePlan；原Impl decode并核cult/node/kind/设备/来源后复用原候选固化、判策、建单/槽CAS，不另起持久/政策流程。旧saveParameterCandidate仍exportForCandidate后走原步骤，FEEDING不放宽。 |
| CONFIG/PERFUSION写来源 | 原CONFIG技术操作M03-CONFIG-PRESET-SAVE及目标PERFUSION技术操作M03-PERFUSION-PRESET-SAVE分别限对应kind/节点；M06源矩阵分别SC017/036与SC018/037，changeKey为PLAN:<cultureId>:<nodeId>:<kind>，原actor/UUID/context身份精确相等。只新增必要具名写来源，不增加审批状态/级数/令牌。候选提交审计复用原槽位八字段UPDATE、真实RES_CULTURE目标，完整正文留原快照；SYSTEM/槽位/候选/审计同事务。 |
| 原M04 `TemplatePackagePort.freezeCulturePlan(CulturePlanFreezeCommand)` | 签名保持不变；CONFIG/PERFUSION完整content及绑定沿原Normalizer，统一型号/medium标签/取测绑定由各拥有方真实读取，不信浏览器工程证明。合法NA草稿计划版本可0，不套正ID限制；其他ID/对象/槽/模板版本沿原规则。来源保留与新选模板分开，不强制旧合法DEVICE_DEFAULT重选模板，也不授予新默认构造。 |
| M03 `StatisticsCultureOriginPort.readComparison(List<Long> cultureIds)` | 设计目标返回原List<Origin>，只P2已授权data:batchComparison:query及当前统计对象/lab范围。原read保持不依赖参数包；专用读取再核当前已选PERFUSION唯一有效槽、原APPLIED application/包，填真实initialMediumName/snapshotId/generation。无有效槽三null；有包仅label未知保留真实快照/代次；坏指针/缺原件/多源不空成功，不读最新模板/字典。 |

最终正文请求摘要覆盖原全部实际content/绑定/来源、期望版本及原因；旧候选/包hash不重写。Q-R05确认影响仅记新采纳方原candidate_identity/application JSON的selectionImpacts，具体schema2/精确旧源及路径沿参数契约；不自动派生另一套旧方生效包、不清整槽/实际连接/旧任务。旧v1 hash不变，当前消费、新生成与已有task冻结用途明确分开，不新表/状态机/联合审批。PERFUSION基线由同一M03事务在当前已选CONFIG节点中定位真实唯一有效包，不能拿PERFUSION node查CONFIG或客户端自报基线。P04按effective_snapshot_id/generation取原APPLIED应用，不让最近DISCARD/CONFLICT抹掉仍合法有效包。详细规则与HTTP目标沿[原参数收尾契约](../详细设计/03-项目与培养管理/培养参数快照与审批生效收尾契约.md)。以上均不修改当前接口源码/SDK/登记wired或测试快照。

### 2026-11-07 原审批对账拥有方交接目标（尚未编码）

原m03/m07/m09 `ApprovalDecisionPort`设计目标增加`resolveDecisionApplication(m06.model.ApprovalDecisionResolutionCommand)->m06.model.ApprovalDecisionResolutionReceipt`；原deliver/query签名及旧payload/hash保持不变。完整最小字段、真实(approvalId,decisionVersion)身份、双人原记录、VERIFY只读与SEAL同锁永久回执见[M06原对账最小交接](../详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#2026-11-07-原对账最小交接设计目标尚未接线)，不新建worker、状态机、token或哈希收据平台，不另造originalDecisionKey。当前接口源码未增加该方法，禁止default空结果/假封禁；不计wired、测试或运行通过。

### 2026-11-07 M05整结果作废SC052目标交接（尚未编码）

现行M06 schema1/三个owner保持不变；目标扩展只包含M05/DETECTION_RESULT/SC052，schema2及必要relatedResult沿[M05结果操作第7节](../详细设计/05-检测与数据签批/检测记录与结果操作设计.md#7-sc052最小目标交接仅设计未编码未安装)及M06接口契约目标段。未来由M05拥有方的`m05.ApprovalDecisionPort`引用原M06 `ApprovalDecisionCommand/ApprovalDecisionQuery/DeliveryResult`并提供同名`deliverDecision/queryDecisionApplication`，不复制共享模型、不让M06访问M05 Mapper。签审前置复用原ApprovalOwnerPrecheckPort具名M05目标，当前功能/结果读取资格不能省。

M05候选必须先有合法不可变持久原件；原成功签批、实际结果revision、指标更正申请和M06副本不代替。原同库事务/实际VOID审计/长期原请求恢复与来源键按上述唯一专题；没有新投递状态机、回执平台、任意回调或设备联动。该目标接口及模型尚无源码，存储结构不在本轮DDL授权，保持NOT_IMPLEMENTED，不加入现有wired或测试通过统计。

### 2026-11-07 培养历史读取设计目标（尚未编码）

M03-048/049/050沿原培养历史专题第8节交接，不新建历史框架或存储。共享请求仅定义一次：`m03.model.CultureHistoryPageQuery{cultureId:ID,pageNum:int,pageSize:int}`和`m03.model.HistoryCultureQuery{cultureId:ID}`；身份与权限来自原可信会话和各拥有方，不接受客户端actor/source/范围。

| 原Port的新增设计目标 | 返回类型 | 当前消费者/状态 |
| --- | --- | --- |
| `m07.CultureRuntimePort.readFeedingHistory(CultureHistoryPageQuery)` | `PageResult<m07.model.FeedingHistoryRow>` | M03-050 feeding；NOT_IMPLEMENTED |
| `m07.CultureRuntimePort.readTaskHistory(CultureHistoryPageQuery)` | `PageResult<m07.model.TaskHistoryRow>` | M03-050 tasks；NOT_IMPLEMENTED |
| `m07.CultureRuntimePort.readWorkflowHistory(CultureHistoryPageQuery)` | `PageResult<m07.model.WorkflowHistoryRow>` | M03-050 workflows；NOT_IMPLEMENTED |
| `m07.CultureRuntimePort.readHistoryBalance(HistoryCultureQuery)` | `m07.model.HistoryBalance` | M03-048/049当前净重，复用原M07-015计算/源权限；NOT_IMPLEMENTED |
| `m05.OfflineStatisticsSourcePort.readCultureSamplingHistory(CultureHistoryPageQuery)` | `PageResult<m05.model.SamplingHistoryRow>` | M03-050 sampling完整发送事实；NOT_IMPLEMENTED |
| `m05.OfflineStatisticsSourcePort.readHistoryCellMetrics(HistoryCultureQuery)` | `m05.model.HistoryCellMetrics` | M03-048/049最近有效Vi-CELL指标；NOT_IMPLEMENTED |

PageResult复用现有公共分页对象，不使用HTTP TableDataInfo或Map退化。逐字段、时间/单位、逐源鉴权、当前有效包和缺失/故障语义唯一沿[培养历史专题](../详细设计/03-项目与培养管理/培养历史双入口与只读详情契约.md#8-历史用途最小物理交接设计收口尚未编码)。原publishRuntimeFact/resolveReleaseProof及P1/P2统计用途不改；当前源码签名与旧快照未因本文自动扩展，禁止default空实现。实现、编译、测试、HTTP/浏览器分别登记。

### 2026-10-13 M03 培养变更提供方登记

本次由用户授权 M03-013/032/033 必要跨 owner 实现；不新增 HTTP 入口。以下调用加入拥有方同库事务，消费者不得直读提供方表。

| Port / 方法 | 提供方 | 事务与失败约束 |
| --- | --- | --- |
| `m01.DeferredActorPermissionPort.allowed(long actorUserId, String permission)` | `M01DeferredActorPermissionProvider` | SYSTEM 锁下读取原申请人的当前账号、有效角色/菜单权限；仅允许培养 mode/edit，失效返回 false，事实不可得抛异常；不伪造在线会话 |
| `m02.CultureChangeDevicePort.lockLab(long labId)` | `M02CultureChangeDeviceProvider` | 要求调用方事务，锁定启用实验室；在培养锁之前调用 |
| `m02.CultureChangeDevicePort.readConfigModel(long labId, String deviceKind, long deviceId)` | 同上 | B12培养CONFIG保存/生效复核实际设备型号。返回原Port嵌套`ConfigModel(long labId,String deviceKind,long deviceId,String modelKind,long modelId)`；小试取控制器自身型号（BENCH_CONTROLLER_MODEL），中试取集成反应器型号（INTEGRATED_MODEL），不拿小试罐体替代控制器。校验同实验室、未删除、启用和正型号ID；依赖故障不补空。调用方负责当前培养权限，本方法不要求HTTP会话、不授予设备操作权；完整型号能力沿原TemplateModelResourcePort。提供方测试先证真实缺方法RED，声明本身不代表接通或运行验收。 |
| `m02.CultureChangeDevicePort.requireReactor(long labId, long deviceId)` | 同上 | 在培养与 M07 runtime 锁之后锁定本实验室启用集成反应器及未删除型号；限中试类型 3/4，返回不含凭据的 SHA-256 配置指纹；型号表无启用字段，不虚构该字段 |
| `m07.M07CultureChangeSupportPort.prepareDateChange(Long cultureId)` | `M07CultureChangeSupportProvider` | 写前锁定可取消任务并拒绝有物理事实/不可取消任务；不先取消部分任务 |

`requireReady` 必须先锁 runtime，再检查物理阶段、STOPPED 停止/结算证据、任务状态、资源持有和未知命令。日期预验与实际取消均在同一 SYSTEM 事务中完成。

M06 可信内部决定由 M03 原子维护候选回执、培养、审计及 SYSTEM revision：前置业务拒绝保存 CONFLICT；依赖故障及写入后的异常整体回滚。成功审计复用唯一 `ManagementAuditHookR2`，身份取不可变候选原申请人并实时复核资格、请求号取 M06 内部决定；这是内部决定的可信上下文，不代表公开写接口可省略 ActorContext/WriteMeta。重复决定返回原回执、不重复审计或递增版本。

| 内容 | 物理位置 | 约束 |
| --- | --- | --- |
| 错误码 | `futurefab-api/futurefab-api-system/src/main/java/com/futurefab/system/api/contract/error/FutureFabErrorCode.java` | 纯Java枚举，不依赖Spring |
| 认证Feign契约 | `futurefab-api/futurefab-api-system/src/main/java/com/futurefab/system/api/contract/auth/RemoteAuthContractService.java` | `@FeignClient`；内部返回沿用`R<T>` |
| 认证模型 | `futurefab-api/futurefab-api-system/src/main/java/com/futurefab/system/api/contract/auth/model/**` | 不复用Entity、LoginUser、Map或Object |
| 公共响应 | `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/common/**` | 仅HTTP/Application响应模型，不进入Mapper参数 |
| 无Body标记 | `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/common/NoBody.java` | 零字段、单例语义，不作为路径ID或Query替代物 |
| Port | `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/port/m0x/**` | 接口按实际实现方归包 |
| Port模型 | `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/port/m0x/model/**` | 不依赖Controller、Mapper、Entity、ServiceImpl |
| Port适配器 | `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/port/m0x/**` | 不属于PKG-00，由PKG-01—08实现 |

依赖方向固定为：`futurefab-auth -> futurefab-api-system <- futurefab-system`；`futurefab-auth`和`futurefab-system`互不直接依赖。Port位于当前单体的`futurefab-system`，消费者只能依赖接口，不能注入提供方Mapper或Impl。

## 3. 公共类型逐字段冻结

以下字段名和Java类型固定。数组永不返回`null`；ID和版本使用`String`，防止前端精度丢失；时间由领域VO使用带时区ISO-8601字符串或`OffsetDateTime`，公共外壳不重复定义时间。

| 类型 | 固定字段 | 说明 |
| --- | --- | --- |
| `PageResult<T>` | `List<T> rows; long total; int pageNum; int pageSize` | 页码从1开始；先鉴权/过滤再计数分页 |
| `BatchResult<T>` | `String batchRequestId; List<T> items` | 每个item必须带稳定客户端行键或业务键；部分成功语义由`T`表达 |
| `MutationResult` | `boolean applied; String requestId; String managementRevision; String objectId; String objectVersion; Long credentialVersion; Long policyVersion; String nextAction; List<String> warnings` | 仅与具体动作有关的可选字段可为null；`applied=true`只表示业务提交已生效，不表示设备已执行 |
| `DeleteResult` | `String requestId; String managementRevision; List<String> removedIds` | 批量删除默认全成全败；逐项跳过的接口必须使用专用结果，不滥用本类 |
| `DeletePrecheckResult` | `boolean allowed; List<String> reasonCodes; long referenceCount; String managementRevision` | 只是瞬时提示，正式删除事务内必须重验 |
| `DisabledEndpointResult` | `boolean disabled; String reasonCode; String replacementRoute; String message` | `disabled`固定为true；只用于明确停用的兼容入口 |
| `BatchMutationResult` | `String requestId; List<MutationResult> results` | 用于同语义批量写；异构逐项结果继续使用领域专用类型 |
| `BinaryFileResponse` | `String fileName; String contentType; long contentLength; String sha256; Resource resource` | `Resource`为Spring只读流；Controller设置响应头并流式输出，禁止返回服务器路径或凭据 |
| `NoBody` | 无字段 | 只标识协议无Body；不得代替Path、Query或Header |

约束：

- `MutationResult`的可选字段禁止用空字符串占位；不适用时为null且不序列化。
- `BinaryFileResponse.resource`不得被JSON序列化；它只在Controller适配层消费。下载权限在打开流前重新校验。
- 领域设计已经声明专用`*MutationResult`、`*DeleteResult`或`*View`时，以专用类型为准，不强行压成公共外壳。
- 公共HTTP成功外壳仍由现有`R/AjaxResult/TableDataInfo`适配；Port不得返回这些HTTP类型。

## 4. 错误码物理契约

`FutureFabErrorCode`的每一项固定四个字段：`String code`、`int httpStatus`、`String messageKey`、`boolean retryable`。生成来源是M01—M07、M09八份`错误码全集.md`中“HTTP或通道”为三位HTTP状态的去重并集，冻结计数107；枚举常量名与`code`完全一致，`messageKey`按`futurefab.error.<小写code>`生成。

`FutureFabReasonCode`只收上述八份全集中明确标为非HTTP运行/投递/结果原因的21个码，字段为`String code`、`ReasonChannel channel`、`String messageKey`。`ReasonChannel={RUNTIME,DELIVERY,MONITORING,OUTCOME,ADMISSION}`；原因码只能进入业务结果、事件或issues，不得直接充当HTTP状态。M05 `NOT_PREPARED`表示订单查询尚无dispatch的结果事实，固定归`OUTCOME`，不表示失败、取消或准入拒绝。

规则：

1. 同名码的HTTP状态不一致、重试语义不一致、HTTP码总数不是107或原因码总数不是21时，PKG-00失败，不允许“取第一个”。
2. `retryable=true`只表示依赖恢复并完成原请求结果核验后可以按原幂等键重试，不表示客户端立即自动重发。
3. `issues/reasonCode`是领域事实，不自动转换成HTTP错误。
4. `ACTION_DENIED`只允许旧M03 HTTP适配器映射，canonical接口统一使用`PERMISSION_DENIED`；它不进入公共枚举。接口清单中的旧值已经同步纠正。
5. `NOT_IMPLEMENTED`不是生产业务错误或原因码。骨架阶段使用独立的`SkeletonNotImplementedException`，由统一异常处理器映射为HTTP 501及`errorCode=NOT_IMPLEMENTED`；该映射在所有环境注册，生产安全性由构建门禁保证：异常引用和可达调用点必须均为0。

## 5. M01认证I01—I05物理签名

### 5.1 接口文件

`RemoteAuthContractService`固定五个方法：

| 契约 | HTTP | Java方法 | Body | Header | `R<T>`中的T |
| --- | --- | --- | --- | --- | --- |
| I01 | `POST /internal/auth/verify` | `verifyCredential` | `AuthCredentialVerifyRequest` | `from-source`内部调用凭据 | `AuthCredentialVerifyResponse` |
| I02 | `POST /internal/auth/activate` | `activateSession` | `AuthSessionActivateRequest` | `from-source`、`X-Auth-Proof` | `AuthSessionActivateResponse` |
| I03 | `POST /internal/auth/session/validate` | `validateSession` | `AuthSessionValidateRequest` | `from-source` | `AuthSessionValidateResponse` |
| I04 | `POST /internal/auth/password/complete` | `completePassword` | `AuthPasswordCompleteRequest` | `from-source`、`X-Auth-Proof` | `AuthPasswordCompleteResponse` |
| I05 | `POST /internal/auth/session/revoke` | `revokeSession` | `AuthSessionRevokeRequest` | `from-source` | `AuthSessionRevokeResponse` |

网关必须拒绝外部访问`/system/internal/auth/**`。`X-Auth-Proof`不得写日志、回浏览器或作为业务JWT使用。

### 5.2 认证模型字段

| 类型 | 固定字段 |
| --- | --- |
| `AuthCredentialVerifyRequest` | `String username; String password; AuthVerifyMode mode; String sessionKey; String requestId` |
| `AuthCredentialVerifyResponse` | `String userId; String userName; PasswordStateView password; String authProof` |
| `AuthSessionActivateRequest` | `String userId; long verifiedCredentialVersion; long verifiedPolicyVersion; String sessionKey; String requestId; String ipaddr; String browser; String os; boolean skipWarning` |
| `AuthSessionActivateResponse` | `String userId; String userName; long sessionVersion; long credentialVersion; PasswordStateView password` |
| `AuthSessionValidateRequest` | `String userId; String sessionKey; long credentialVersion; long sessionVersion; String requestId` |
| `AuthSessionValidateResponse` | `boolean valid; PasswordState passwordState; String permissionRevision` |
| `AuthPasswordCompleteRequest` | `String userId; long verifiedCredentialVersion; String newPassword; String confirmPassword; String requestId` |
| `AuthPasswordCompleteResponse` | `boolean applied; long credentialVersion; PasswordNextAction nextAction` |
| `AuthSessionRevokeRequest` | `String userId; String sessionKey; String requestId; SessionRevokeReason reason` |
| `AuthSessionRevokeResponse` | `boolean revoked; long sessionVersion` |
| `PasswordStateView` | `PasswordState passwordState; LocalDate effectiveDate; LocalDate expiresDate; Integer remainingDays; int validDays; int remindDays; long policyVersion; long credentialVersion` |

枚举固定：`AuthVerifyMode={LOGIN,UNLOCK}`；`PasswordState={INITIAL,EXPIRED,EXPIRING,VALID}`；`PasswordNextAction={LOGIN_REQUIRED}`；`SessionRevokeReason={LOGOUT,LOCK,RESET,DISABLE,REPLACED}`。I01在UNLOCK成功时`authProof=null`，LOGIN成功时必有；I04响应的`nextAction`固定`LOGIN_REQUIRED`。

## 6. 76个内部契约的Port物理签名

表中`m0x`表示`com.futurefab.system.service.port.m0x`；Request/Response与接口同属该包的`model`子包。每行只能实现一次。字段以本表右列和对应`design_refs`共同冻结；二者冲突时停止开发并修订设计，禁止在代码里猜。

### 6.1 M01（8个，含5个认证HTTP契约）

I01—I05按第5节落地。其余3个本地Port：

| ID | 物理签名 | 核心字段 |
| --- | --- | --- |
| SEC-I01 | `m01.ActorContextPort#resolveActorContext(ActorContextQuery) -> ActorContext` | Query=`requestId/sessionKey`；结果=`actorUserId/actorName/sessionKey/authzVersion/requestId/labScopes`，浏览器actor字段无效 |
| SEC-I02 | `m01.FunctionPermissionPort#checkFunctionPermission(FunctionPermissionQuery) -> FunctionPermissionDecision` | `ActorContext/permissionCode/objectHint?` -> `allowed/reasonCode/authzVersion` |
| SEC-I03 | `m01.ManagementRevisionPort#verifyManagementRevision(ManagementRevisionQuery) -> ManagementRevisionDecision` | `expectedManagementRevision/requestId` -> `matched/currentManagementRevision`；不替代领域版本 |

### 6.2 M02（13个）

| ID | 物理签名 | 核心模型字段 |
| --- | --- | --- |
| AUTH-I01 | `m02.LabAuthorizationPort#prepareUserEdit(UserLabEditQuery) -> UserLabEditPreparation` | `targetUserId/deptId/operation/actorContext` -> `laboratories/defaultLabIds/currentLabIds/currentAuthorizations/hasUnmanagedAuthorizations/authorizationVersion`；operation=`USER_CREATE/USER_UPDATE/USER_DELETE` |
| AUTH-I02 | `m02.LabAuthorizationPort#replaceUserLabs(ReplaceUserLabsCommand) -> UserLabAuthorizationResult` | 目标用户、期望授权版本、直接授权集合、requestId -> `applied/authorizationVersion/currentAuthorizations/managementRevision` |
| AUTH-I03 | `m02.LabAuthorizationPort#removeUserLabs(RemoveUserLabsCommand) -> UserLabAuthorizationResult` | 目标用户集合、期望版本、requestId；只清直接授权，不动负责人 |
| ENG-I01(SVC-M02-E01) | `m02.EngineeringResolutionPort#resolveEngineering(EngineeringResolutionQuery) -> EngineeringResolution` | `scope/expectedManagementRevision/purpose/requiredPaths` -> `state/modelSnapshot/instanceSnapshot/effectiveProfile/effectiveHash/issues/managementRevision` |
| CAP-I01 | `m02.DeviceConfigurationPort#resolveDeviceConfiguration(DeviceConfigurationQuery) -> DeviceConfigurationView` | `context/deviceRef/requiredFields/expectedManagementRevision?` -> 配置值、单位、来源、ready/issues |
| CAP-I02 | `m02.DeviceCapabilityPort#resolveIntegratedCapabilities(IntegratedCapabilityQuery) -> CapabilityView` | `context/labId/modelId/integratedId?/expectedManagementRevision?` |
| CAP-I03 | `m02.DeviceCapabilityPort#resolvePumpConfiguration(PumpConfigurationQuery) -> PumpConfigurationView` | 泵号必须升序且完整覆盖`1..pumpCount`，缺号/重号进入issues |
| M02-INT-06 | `m02.BenchControllerRuntimePort#resolveBenchControllerRuntime(BenchControllerRuntimeQuery) -> BenchControllerRuntimeView` | `contextRef/labId/(connectionId或reactorId二选一)/expectedManagementRevision?/includeFeedingSlots=false` -> 真实controllerNo、能力、称重身份、固定通道/速度；反应器零/多条连接ready=false不猜选。2026-10-23 W03新apply可在活动写事务内设置includeFeedingSlots=true，由M02稳定顺序锁读实际补料槽位及精确通道，返回feedingSlots（BenchConnectionBottle：稳定身份、真实泵/培养基、核准g容量、可空可信当前量及质量/观测时间/配置代次）。默认不锁液瓶、不读取PLC；不将容积转换质量，不将读数当已确认装载 |
| M02-INT-08 | `m02.WorkflowPumpCommandSpecPort#resolveWorkflowPumpCommandSpec(WorkflowPumpCommandSpecQuery) -> WorkflowPumpCommandSpec` | `labId/connectionId/pumpId/channelCode/expectedManagementRevision?` -> 已固定泵的设备身份、资源键、速度范围与配置/能力修订；只读配置事实，不调用设备 |
| M02-INT-07 | `m02.LabWorkflowContextPort#resolveLabWorkflowContext(LabWorkflowContextQuery) -> LabWorkflowContext` | `contextRef/labId` -> M02真实启用实验室的`labType(1/2/3/4)`与管理修订；供M07以真实类型选择M04工作流定义，禁止按流程名猜测或直读`lab_lab` |
| M02-PILOT-01 | `m02.PilotWorkflowResourcePort#resolveReactors(PilotWorkflowResourceQuery) -> PilotWorkflowResourceView` | M07-022/023固定消费者；可信actor+labId+M03有权培养设备ID集合，返回同实验室中试反应器编号/型号/规格/房间ID/真实型号图标及配置issues，不声明物理readiness；Query/View在m02.model |
| M02-PILOT-02 | `m02.PilotWorkflowConfigurationPort#readConfiguration(PilotWorkflowConfigurationQuery) -> PilotWorkflowConfigurationView` | W01模式页/预填充页配置消费者；可信当前actor、labId、integratedId及服务器从冻结FEEDING包取得的bagIds/externalPumpIds。M02核对当前会话/操作权限、归属及外置泵未连接其它活动反应器，返回内外置泵、全局液袋当前配置及两秤rawPrecision；外置无关联量程保持未知。不含通讯凭据，不声明真实模式/停止/已执行，不按顺序猜方案固定泵。Query/View在m02.model，四参Query构造保留；模拟回执在M07独立标记 |
| M01-PILOT-ROOM-01 | `m01.VenueNameReadPort#readNames(VenueNameReadQuery) -> VenueNameReadView` | 内部精确房间名称读取，purpose=M07_PILOT_ROOM_OPTIONS；绑定当前HTTP可信actor，最多500个去重正bigint ID，仅读M01正常未删除sys_venue。M07须先从当前实验室有权反应器候选提取roomIds，M01不跨表推定实验室归属；不暴露场地管理列表或要求system:venue:list。每ID明确返回可用名称或不可用原因，不虚构缺失名称，不将故障伪装空结果。Query/View均在m01.model，唯一方法一参一出；新增后Port接口总数65 |
| M02-PILOT-03 | `m02.PilotWorkflowConfigurationPort#readBagCandidates(PilotWorkflowBagCandidatesQuery) -> PilotWorkflowBagCandidatesView` | W02新袋型号候选：绑定真实当前actor及目标中试实验室OPERATE后读取全局未删除液袋型号。只返回型号/描述/容量g/皮重g/残余及图标等配置，不生产实体袋身份、装载量或设备事实；完整集合最多500条，超过时明确拒绝而非静默截断。无型号返回空集合，依赖失败不冒充无数据。Query/View均在m02.model；不改变readConfiguration原语义 |
| OBS-I01 | `m02.ObservationIntakePort#receiveObservation(ObservationEnvelope) -> ObservationReceipt` | `receiptId/state/processVersion/observationId?/duplicate/reasonCode?`；持久化后才ACK |
| ResolveConsumption | `m02.ConsumptionResolutionPort#resolveConsumption(ConsumptionResolutionQuery) -> ConsumptionResolution` | `labId/tabType/selectedCardKeys/configurationRevision` -> 去重升序消耗项 |
| getEffectiveCommunication | `m02.CommunicationConfigurationPort#getEffectiveCommunication(EffectiveCommunicationQuery) -> EffectiveCommunicationConfig` | 精确`deviceKind/deviceId/requiredRevision`，不得回退最新配置 |
| reportAppliedConfiguration | `m02.CommunicationConfigurationPort#reportAppliedConfiguration(ConfigurationApplyReport) -> ConfigurationApplyReceipt` | `desiredRevision/adapterInstanceId/result/errorCode/observedAt` -> `accepted/duplicate/appliedRevision/applyState/reasonCode` |

### 6.3 M03（21个）

2026-10-22 FEED 普通固定量执行准备新增 `CU-EXEC-W01`：`m03.CultureExecutionWeightPort#readExactForExecution(CultureExecutionWeightQuery) -> CultureExecutionWeightSnapshot`。Query 为 `taskId/cultureId/labId/expectedCultureVersion/expectedInitialWeightRevision`；Snapshot 为同一原行的 `cultureId/labId/cultureVersion/initialWeightRevision/initialGrams/effectiveAt/sourceCandidateId`。仅在 `M07_RESOURCE_CLAIM`、SYSTEM 锁和活动事务内按原任务身份读取，依赖当前 M03 重量变更同 SYSTEM 串行屏障；不反向锁 M03 培养，不读请求用户会话，不接受 latest/0 版本。不完整或版本变化返回 `RESOURCE_FACTS_UNAVAILABLE`，读取失败返回 `DEPENDENCY_UNAVAILABLE`。旧 `CultureInitialWeightPort` 继续只服务显示，不扩字段；本口不承担 M07 的 START、监控、供料或授权准入。源码调用和单元/MyBatis 验证不代表真实数据库并发或设备验收。

| ID | 物理签名 | 关键约束 |
| --- | --- | --- |
| M03-P01 | `m03.ParameterPackagePort#saveParameterCandidate(ParameterCandidateCommand) -> ParameterCandidateResult` | 固定候选、版本、hash、审批分支和issues |
| M03-P01-PREPARE | `m03.ParameterPackagePort#prepareFeedingCandidate(ParameterCandidateCommand) -> ParameterCandidateResult` | 只固化免审补液原候选、PREPARED与独立核准材料，不生效或生成任务；HTTP_ONLY，当前PREPARE管理守卫与原事务必需 |
| M03-P01-COMMIT | `m03.ParameterPackagePort#submitPreparedFeedingCandidate(PreparedFeedingCandidateCommand) -> ParameterCandidateResult` | 单一model请求含`command,candidateId,candidateHash,preparationRequestId`；重验原准备、当前CANDIDATE守卫及独立批准后，沿P02同事务生效；HTTP_ONLY，不降低M06精确桥接及任务安全屏障 |
| M03-P02 | `m03.ParameterPackagePort#applyParameterDecision(ParameterDecisionCommand) -> ParameterDecisionResult` | `decisionKey/hash/version`幂等；APPLY切指针并提升generation |
| M03-P03 | `m03.ParameterPackagePort#queryParameterApplication(ParameterApplicationQuery) -> ParameterDecisionResult` | 只查原提交；依赖故障不得伪装NOT_FOUND |
| M02-PILOT-04 | `m02.PilotWorkflowConfigurationPort#readMediumNames(PilotWorkflowMediumNamesQuery) -> PilotWorkflowMediumNamesView` | 当前培养基名称补充查询：Query固定可信actorContext、labId、mediumIds；保留当前会话、实验室OPERATE及中试类型校验。View.rows逐请求ID返回MediumName及明确issues；缺名称不是空成功，依赖故障仍失败。M07仅在冻结方案缺名称时采用，并标记M02_CURRENT_CONFIGURATION；不改变物理状态或工作流模拟语义 |
| M03-P04 | `m03.ParameterPackagePort#readEffectivePackage(EffectivePackageQuery) -> EffectivePackageView` | 精确generation和快照；不暴露通用任意模板读取 |
| M03-P04-SC033 | `m03.ParameterPackagePort#readForRuntimeCalculation(RuntimeCalculationPackageQuery) -> EffectivePackageView` | 运行计算规则拥有方事务中的精确方案读取。Query内selection沿EffectivePackageQuery，initiatorUserId仅来自守卫/不可变候选；限定M07_CULTURE_CALCULATION_CHANGE，复核原申请人当前M03范围、有效槽位、快照/回执及M04摘要，不借后台登录会话。仅增加内部读口，不开放HTTP任意actor读取 |
| M03-P06 | `m03.CultureOperationFactsPort#resolveCultureOperationFacts(CultureOperationFactsQuery) -> CultureOperationFactsView` | M07固定来源用途＋当前操作者范围；返回同一培养读投影的lab/project/batch、三轴版本、生命周期、设备和计划日期，不代替M07运行/方案/资源准入 |
| M03-PILOT-01 | `m03.PilotWorkflowCultureFactsPort#listCandidates(PilotWorkflowCultureQuery) -> PilotWorkflowCultureList` | M07-022/023及W01模拟025/026/027复用；可信actor+labId+可空节点ID+可选精确cultureId，返回独立操作资格、占用及版本、真实开始完成、计划开始日、真实culture_mode、节点选择及FEEDING生效指针/代次。仅精确培养且指定节点时附FeedingConfiguration；纯权限/取消/STOP查询不读显示配置，以免显示故障阻安全收尾；保留19/18/16参构造。Query/List在m03.model，不改小试或M05语义 |
| M03-PILOT-01-W01 | `m03.PilotWorkflowCultureFactsPort#listW01Candidates(PilotWorkflowCultureQuery) -> PilotWorkflowCultureList` | W01列表专用只读方法，不接受精确cultureId；保留已授权但个别事实不完整的培养并标记待核验，提交与启动仍按原严格入口重验。接口默认方法委托listCandidates，M03生产实现覆盖隔离读取 |
| M03-PILOT-01-W02 | `m03.PilotWorkflowCultureFactsPort#listW02Candidates(PilotWorkflowCultureQuery) -> PilotWorkflowCultureList` | W02列表专用只读方法，不接受精确cultureId；沿用W01的单条事实不完整隔离，精确培养及写入仍使用严格读取。接口默认方法委托listCandidates，M03生产实现覆盖隔离读取 |
| M03-PILOT-02 | `m03.PilotWorkflowMemberDisplayPort#read(PilotWorkflowMemberDisplayQuery) -> PilotWorkflowMemberDisplayView` | M07-022候选展示；输入actorContext/labId/cultureIds，先经SEC-I01绑定当前HTTP会话/请求，再核可见培养归属；有效MEMBER按培养→批次→项目首个非空层回退，M01名册缺名保留稳定ID/来源/原因，500分块不截断，依赖故障不假空；Query/View在m03.model，无业务写 |
| M03-PILOT-END-01 | `m03.PilotEndCultureFinishPort#completeNormally(PilotEndCultureFinishCommand) -> PilotEndCultureFinishResult` | M07-END-CULTURE-COMPLETE守卫内MANDATORY事务；命令由M07冻结引用构造，M03锁培养和原占用并重验权限/日期/版本，再回调M07释放核验；新实例允许服务端默认连接标记，旧隔离实例才校验测试名单；设备证据仍SIMULATION。M03保存FINISHED与RELEASED、同步观测关联，返回服务器实际结束时刻和M03拥有的AuditIntent；M07原样转交守卫，不嵌套管理写 |
| M03-PILOT-END-02 | `m03.PilotEndCultureFinishPort#completeAbnormally(PilotEndCultureAbnormalFinishCommand) -> PilotEndCultureFinishResult` | 同一最终守卫内MANDATORY；要求原因及当前DIRECT/DIRECT_REASON政策，M03锁培养/原占用后回调M07检查全部任务与泵停止；仅中试异常尝试保存CANCELLED，审计仍由原管理守卫完成 |
| M03-PILOT-END-03 | `m03.PilotEndCultureFinishPort#completeApprovedAbnormally(PilotEndCultureApprovedFinishCommand) -> PilotEndCultureFinishResult` | 仅固定后台用途M07_PILOT_END_CULTURE_APPLY，持久事实ID为原候选步骤ID；SYSTEM→M03培养/占用→M07实例/步骤。无交互会话、不伪造GuardCallbackContext；原最终决定及版本核验后自动保存CANCELLED/释放占用/关闭关联。已知资源未停返回null且零写，依赖失败抛出。实际结束时间取保存时服务器时间，SYSTEM事件与原决定/回执同事务 |
| M03-PILOT-END-04 | `m03.PilotEndCultureConfigPort#read(PilotEndCultureConfigQuery) -> PilotEndCultureConfigView` | 仅中试结束培养泵展示；actor/lab/culture/reactor/expectedCultureVersion绑定当前操作范围和版本，M03只查询培养已选节点的唯一CONFIG生效指针，再经P04固定M07-END-CULTURE-DISPLAY用途核验完整包。无指针config=null，来源非唯一拒绝；不读取全局模板、补写方案或引入前端字段。模型归m03.model，完整包留后端 |
| M02-PILOT-OBS-01 | `m02.PilotWorkflowCurrentObservationPort#read(PilotWorkflowCurrentObservationQuery) -> PilotWorkflowCurrentObservationView` | M07结束培养候选/详情只读展示；输入当前可信actor和M03/M02已核验lab/culture/reactor身份。M02复用当前/历史培养VIEW与实验室VIEW权限、已核准测点连接、OBS-Q01当前值及检测项名称；只显示MATCHED同培养同实验室、VALID/GOOD/NORMAL当前值，质量/冲突及时间保留，不取lastGood。现有通道生产者仅覆盖已核准罐重秤，不把反应器ID当测量设备ID，不补造pH/DO/温度等未登记来源。模型位于m02.model，不调用M08应用 |
| M07-PILOT-END-01 | `m07.PilotEndCultureReleasePort#authorizeRelease(PilotEndCultureReleaseQuery) -> PilotEndCultureReleaseView` | 仅上述守卫及同一活动事务，位于M03培养/占用锁之后；核对默认连接标记或旧测试名单、冻结引用/版本、最终步骤、全部模拟泵停止（正常结束还须手动）及任务/资源/命令/执行计数。返回明确SIMULATION释放引用；不扩大既有小试CultureRuntimePort释放证明，也不代表真实设备验收 |
| M07-PILOT-END-02 | `m07.PilotEndCultureReleasePort#authorizeApprovedRelease(PilotEndCultureApprovedFinishCommand) -> PilotEndCultureReleaseView` | 仅M07_PILOT_END_CULTURE_APPLY、M03培养/原占用锁后；重读原APPROVED/APPLY候选及决定，核验冻结引用、默认设备状态和实际活动计数。已知未停返回null，未知事实抛错，安全时返回明确SIMULATION引用；不适用于小试或其他后台用途 |
| M03-P05(M03-API03) | `m03.WorkflowReferencePort#checkRemoval(WorkflowRemovalQuery) -> WorkflowRemovalResult` | `actorContext/labId/nodeIds/managementRevision` -> `complete/results[nodeId,hasAnyCultureReference]` |
| CHG-I01 | `m03.CultureChangePort#prepareCultureChange(CultureChangePrepareCommand) -> CultureChangeCandidate` | sceneCode由公开操作服务端映射，拒绝未知字段 |
| CHG-I02 | `m03.CultureChangePort#attachApproval(CultureChangeApprovalCommand) -> CultureChangeApprovalBinding` | 同候选不能换审批单 |
| CHG-I03 | `m03.CultureChangePort#applyCultureChange(CultureChangeDecisionCommand) -> CultureChangeReceipt` | 返回APPLIED/CONFLICT/UNKNOWN或持久封禁回执 |
| CHG-I04 | `m03.CultureChangePort#queryCultureChange(CultureChangeReceiptQuery) -> CultureChangeReceipt` | 查询不写业务字段 |
| CHG-I05 | `m03.CultureChangePort#sealCultureChange(CultureChangeSealCommand) -> CultureChangeReceipt` | 证据不足不得封禁；已APPLIED只返原回执 |
| BIND-I01 | `m03.CultureBindingPort#publishBindingRevision(BindingRevisionCommand) -> BindingRevisionResult` | `requestId/expectedRevisionNo/device/channel/intervals`，同键异载荷冲突 |
| BIND-C01 | `m02.ObservationBindingConfigurationPort#resolveCultureChannels(ObservationBindingConfigurationQuery) -> ObservationBindingConfigurationView` | M03 主设备/实验室身份→M02 自有明确连接与核准通道快照；当前只支持集成反应器 floor_scale_id 罐重秤，不猜控制器、补料秤或检测样品关系；空列表仅表示无可发布测点 |
| BIND-I02 | `m03.CultureBindingPort#resolveAt(BindingResolveQuery) -> BindingResolution` | `MATCHED/UNASSOCIATED/UNKNOWN/AMBIGUOUS`，UNKNOWN不当空闲 |
| BIND-I03 | `m03.CultureBindingPort#listRevisions(BindingRevisionPageQuery) -> BindingRevisionPage` | 连续修订游标，`limit<=500` |
| RUN-B01 | `m07.CultureInputBarrierPort#applyCultureInputChange(CultureInputChangeCommand) -> CultureInputChangeReceipt` | 物理签名及7个输入字段见§6.7；M07实现，与M03生效加入同一受控事务 |
| INT-M03-R01 | `m03.CultureRuntimeReceiptPort#acceptRuntimeFact(RuntimeFact) -> RuntimeFactReceipt` | 先持久化RECEIVED；乱序BLOCKED，同键异内容冲突 |
| INT-M03-R02 | `m03.CultureRuntimeReceiptPort#queryRuntimeReceipt(RuntimeReceiptQuery) -> RuntimeFactReceipt` | `sourceModule/sourceEventId/payloadHash`精确查询 |
| INT-M03-R03 | `m03.CultureRuntimeReceiptPort#reconcileRuntimeEvent(RuntimeReconcileCommand) -> RuntimeFactReceipt` | 必须携权威来源证明，不跨越BLOCKED前驱 |
| M03-API01 | `m03.ResourceUsageGuardPort#queryUnfinishedLabBusiness(UnfinishedLabBusinessQuery) -> UnfinishedLabBusinessFacts` | 未结束项目/批次/培养三主键去重；未知503不猜0 |
| M03-API02 | `m03.ResourceUsageGuardPort#checkDeviceUsage(DeviceUsageQuery) -> DeviceUsageDecision` | 完整事实不可得则失败关闭，不返回UNKNOWN且blocked=false |
| M03-W03-01 | `m03.W03CandidateCulturePort#listW03CandidateCultures(W03CandidateCultureQuery) -> W03CandidateCultureList`; `m03.W03CandidateCulturePort#resolveW03CandidateCultures(W03CandidateCultureQuery) -> W03CandidateCultureList` | 默认返回当前可见范围内已核准、未删除、绑定台式反应器且状态为NOT_STARTED/RUNNING/DELAYED的培养，独立返回operationAllowed、计划开始日、开始完成实例/时间、FEEDING生效快照/代次；可见不代替可操作。resolve按精确培养重验，ID不等同控制器connectionId。2026-10-23新增permissionOnly=false默认模式，仅resolve且精确非空cultureIds可设true：按当前可信身份、未删/归属、当前VIEW/OPERATE及三级有效MEMBER核权限，不依赖生命周期/旧方案准入，仅供原请求回放后的当前权限复核及受控移除；不据此启动或授予命令资格。默认list/启动仍严格完整准入 |

### 6.4 M04（3个）

| ID | 物理签名 | 关键约束 |
| --- | --- | --- |
| M04-SVC01 | `m04.TemplatePackagePort#exportForCandidate(TemplateExportQuery) -> TemplatePackage` | 在共同守卫内导出完整固定包，不写培养、不下设备 |
| M04-SVC02 | `m04.TemplatePackagePort#validateForActivation(TemplateActivationQuery) -> ActivationValidation` | 工程/设备/审批未知均阻断，不写双方主表 |
| M04-SVC03 | `m04.TemplatePackagePort#decodeFixedPackage(FixedPackageDecodeQuery) -> TemplatePackage` | 只解释传入固定包，不按templateId追当前版本 |
| M04-SVC04 | `m04.WorkflowDefinitionPort#resolveForRun(WorkflowDefinitionQuery) -> WorkflowDefinition` | 只读解析实验室绑定的启用工作流定义；子流程唯一匹配实验室类型、步骤从1连续；不读培养或设备、不写运行事实 |
| M04-WF-COMPAT-01 | `m04.WorkflowDefinitionPort#isStartCultureNode(String) -> boolean` | 保留既有 public default 只读签名；M03 开始培养准入按已选节点 ID 核验是否为启用的 start_culture 节点，不改调用方或生产实现 |
| M04-WF-EC-01 | `m04.WorkflowDefinitionPort#inspectFeedingSelection(WorkflowFeedingSelectionQuery) -> WorkflowFeedingSelectionView` | 请求为已选节点ID集合，响应feedingSelected；中试结束培养按真实feeding编码识别连接前置条件，不依赖安装ID；未知节点拒绝，停用不抹除已有选择，仅读M04节点表 |

2026-10-20 用户确认兼容边界：为保持其他模块现有调用，以上 M04-WF-COMPAT-01 保留原方法名、单个 `String nodeId` 参数、原始 `boolean` 返回类型及默认方法形态。生产实现只在节点存在、status=`0`、nodeCode=`start_culture` 时返回 true；缺失、停用或其他节点返回 false，非法 ID 仍按原参数错误拒绝，读取故障不能伪装成 false。接口默认方法原有 false 兜底保持，不能据其认定真实提供方已完成节点核验。

本项是**唯一明确登记的既有签名兼容例外**，不推广到同接口其他方法、同名的其他接口、其他 default 方法或新增 Port。公共快照继续固定全部方法及精确入参/返回类型；DTO形状检查仅对“完整声明类 + 方法名 + String参数 + boolean返回值”精确匹配的这一项使用兼容判据，并另行检查 public/default 形态与真实提供方行为。其余方法仍使用既有请求/结果对象规范。无新增 HTTP、DTO、数据库字段或业务写入。

### 6.5 M05（9个）

| ID | 物理签名 | 关键约束 |
| --- | --- | --- |
| DET-I01 | `m05.DetectionExecutionPort#validateDetectionCandidate(DetectionCandidateQuery) -> DetectionCandidateValidation` | 只读预检，不预占、不派发 |
| DET-I02 | `m07.DetectionReservationPort#reserveDetectionOrder(DetectionReservationCommand) -> DetectionReservation` | M07拥有reservation |
| DET-I03 | `m05.DetectionExecutionPort#prepareDetection(DetectionPrepareCommand) -> DetectionPreparation` | 固定样品/能力/派发快照，结果PREPARED |
| DET-I04 | `m05.DetectionExecutionPort#executePreparedDetection(PreparedDetectionCommand) -> DetectionExecutionReceipt` | 先持久化INVOKING，事务外调用设备 |
| DET-I05 | `m05.DetectionExecutionPort#getDetectionProgress(DetectionProgressQuery) -> DetectionProgress` | 只查原order/dispatch，不触发新检测 |
| DET-I06 | `m05.DetectionResultPort#getResultRevision(ResultRevisionQuery) -> ResultRevisionView` | 精确不可变版本，不回退最新 |
| DET-I07 | `m05.DetectionResultPort#queryEligibleResults(EligibleResultQuery) -> EligibleResultSet`；`#resolveEffectiveResult(EffectiveResultQuery) -> EffectiveResultView` | M05提供、M07消费；schema2不得被旧消费者截断 |
| INT01-receiveEvent | `m09.EventIngestionPort#receiveEvent(EventEnvelope) -> EventReceipt` | M05是事件源，M09实现接收方Port |
| M09-M05-DEADLINE-FACTS | `m05.DetectionDeadlineFactsPort#pageDeadlineFacts(DetectionDeadlineFactQuery) -> DeadlineFactPage` | M05提供稳定分页事实，M09消费 |

### 6.6 M06（4个）

| ID | 物理签名 | 关键约束 |
| --- | --- | --- |
| M06-INT-API09-evaluateApprovalPolicy | `m06.ApprovalPolicyPort#evaluateApprovalPolicy(ApprovalPolicyQuery) -> ApprovalPolicyDecision` | 场景和值域由可信生产方固定；政策未知时失败关闭 |
| M06-INT-API10-submitApproval | `m06.ApprovalSubmissionPort#submitApproval(ApprovalSubmissionCommand) -> ApprovalSubmissionResult` | 同producer/sourceRequestId长期去重；不同载荷冲突 |
| M06-INT-API11-deliverDecision | `m03/m07/m09.ApprovalDecisionPort#deliverDecision(ApprovalDecisionCommand) -> DeliveryResult` | 根据`ownerModule`路由唯一实现；至少一次投递，核对echo身份 |
| M06-INT-API12-queryDecisionApplication | `m03/m07/m09.ApprovalDecisionPort#queryDecisionApplication(ApprovalDecisionQuery) -> DeliveryResult` | 只查原提交，不重发物理命令；查库失败不解释为NOT_FOUND |

`ApprovalDecisionCommand`和`DeliveryResult`字段严格采用M06内部契约原文：delivery/approval/decision/candidate/owner/target/impact/**policySnapshot**/**initiatorUserId**/decidedAt及证据结构，不允许用`Map`缩写。`policySnapshot`为`apr_request.policy_snapshot`的冻结 JSON 原文；拥有方只能核验其与交付身份、场景和政策修订的一致性，不得依据当前政策、浏览器输入或重新查询结果改写该证据。`initiatorUserId`为审批单提交时冻结的可信发起人 ID，供拥有方本地审计及 M07 屏障调用，不得替换为投递 worker 或当前会话身份。

### 6.7 M07（12个）

| ID | 物理签名 | 关键约束 |
| --- | --- | --- |
| CMD-I01 | `m02.DeviceCommandPort#submitCommand(DeviceCommand) -> DeviceCommandReceipt` | ACCEPTED不等于EXECUTED；同键异载荷拒绝 |
| CMD-I02 | `m02.DeviceCommandPort#queryCommand(DeviceCommandQuery) -> DeviceCommandReceipt` | UNKNOWN先查；NOT_FOUND不证明设备未执行 |
| RUN-OBS-I01 | `m07.ExecutionSamplePort#appendExecutionSample(ExecutionSampleCommand) -> ExecutionSampleReceipt` | 2026-10-15确认载体字段=`executionId/segmentId/sourceSequence:string/observedAt/stage/quality/payloadHash/samplePayload`；同execution/sourceSequence同hash返回原sampleId，异hash留冲突 |
| RUN-B01 | `m07.CultureInputBarrierPort#applyCultureInputChange(CultureInputChangeCommand) -> CultureInputChangeReceipt` | 输入=`cultureId/candidateId/operation/expectedCultureVersion/newCultureVersion/oldWeightRevision?/newWeightRevision?`；operation=`MODE/INITIAL_WEIGHT`，candidateId同时为幂等键；与M03表中的同一物理方法，不重复定义 |
| RUN-EVT-I01 | `m07.CultureRuntimePort#publishRuntimeFact(RuntimeFact) -> RuntimePublishReceipt`；`#resolveReleaseProof(ReleaseProofQuery) -> ReleaseProof` | M03不重建另一套设备锁表 |
| RUN-EVT-I02 | `m07.RuntimeFactProofPort#verifyRuntimeFact(RuntimeFactProofQuery) -> RuntimeFactProof` | M03 R03 受控后台事务内核验 M07 原事实及当前来源对象；仅 FIRST_WORKFLOW_STARTED |
| M07-INT-01 | `m07.ApprovalDecisionPort#deliverDecision(ApprovalDecisionCommand) -> DeliveryResult`；`#queryDecisionApplication(ApprovalDecisionQuery) -> DeliveryResult` | 与M06 API11/12共享模型；SC033派生的TASK UPDATE按runtimeCalculationChange固定引用分派，由具名M07SourceRecoveryDecisionConsumer/M07_SOURCE_RECOVERY_APPLY核验并应用，不借普通UPDATE绕过held/原申请人/当前输入检查；CULTURE分派尚待实现 |
| M07-INT-02 | `m07.PlanGenerationPort#reconcilePlanGeneration(PlanGenerationCommand) -> PlanGenerationReceipt` | M03拥有最终方案指针，M07不改`res_culture` |
| M07-INT-03 | `m07.CultureExecutionBarrierPort#getCultureExecutionBarrier(CultureExecutionBarrierQuery) -> CultureExecutionBarrier` | unknown/未结束执行/占用证据均阻断释放 |
| M07-INT-04 | `m07.DetectionResultChangePort#consumeResultChanged(ResultChangedEvent) -> ResultChangedReceipt` | M05精确版本事件；历史计算不改，未来准入失效 |
| M07-INT-05 | `m02.DeviceReadingsPort#resolveExecutionReadings(ExecutionReadingsQuery) -> ExecutionReadings` | 固定设备/指标/配置/asOf；缺字段、单位或质量不生成有效输入 |
| M07-INT-06 | `m02.MaterialObservationPort#applyMaterialObservation(MaterialObservationCommand) -> MaterialObservationReceipt` | 旧session回报拒绝，不覆盖新瓶投影 |
| M07-INT-07 | `m07.RunEventPublisherPort#publishRunEvent(RunEvent) -> RunEventPublishReceipt` | broker ACK不表示所有消费者完成；M08/M09失败不回滚已落账业务 |

### 6.7A M02 声光报警器命令端口（3个，2026-10-13 M09-016 联合接线增补）

| ID | 物理签名 | 关键约束 |
| --- | --- | --- |
| SND-CMD-I01 | `m02.SoundAlarmCommandPort#resolveTargetFacts(SoundAlarmTargetQuery) -> SoundAlarmTargetFacts` | HTTP_ONLY，M09-016 守卫回调内调用；不存在/已软删/主键不一致返回 `null`（消费侧统一 404 同文案「声光报警器不存在或无权访问」，不泄露「存在但不归属」差异）；`status` 越出 0正常/1停用 按 RESOURCE_FACTS_UNAVAILABLE 失败关闭，不猜测停用态 |
| SND-CMD-I02 | `m02.SoundAlarmCommandPort#submitCommand(SoundAlarmCommand) -> SoundAlarmCommandReceipt` | 显式 OFF 意图（非 toggle）；守卫事务提交后派发（§25.2 禁止持锁守卫事务内远程调用/设备命令）；EXT-07 现场通道未核准期间 DEPENDENCY_UNAVAILABLE 失败关闭，不得伪造 ACCEPTED/EXECUTED，不得发送未经验证的开关序列 |
| SND-CMD-I03 | `m02.SoundAlarmCommandPort#queryCommand(SoundAlarmCommandQuery) -> SoundAlarmCommandReceipt` | 原命令身份查单，不换键重发；UNKNOWN 先查一次；NOT_FOUND 不证明设备未执行 |

与 `DeviceCommandPort`（CMD-I01/I02）的分界：`DeviceCommand` 是 M07 补液定制模型（必填 `fence/operation/parametersPayload`），声光 OFF 意图塞不进该模型，故为 M09-016 新建独立端口与模型族（`service.port.m02.model.SoundAlarm*`），**不改 `DeviceCommandPort` 现有签名**；两族 Receipt 同守"ACCEPTED 不等于 EXECUTED"语义。目标解析走 M02 权威表 `lab_sound_alarm` 既有按主键只读语句（`selectLabSoundAlarmByAlarmId`），零新增 SQL；实验室可见性判定在 M09 消费侧用 `LabStatusAlarmConfigMapper.countLabVisibleV2` 完成，不跨模块读表。`submitCommand`/`queryCommand` 的来源分类见 §6.9 2026-10-13 增补（有意不列入精确方法清单）。

### 6.8 M09（5个）

| ID | 物理签名 | 关键约束 |
| --- | --- | --- |
| INT01 | `m09.EventIngestionPort#receiveEvent(EventEnvelope) -> EventReceipt` | 持久化`alarm_event`后ACK；EventReceipt={receiptId,state:ACCEPTED/DUPLICATE/CONFLICT/REJECTED,duplicate,reasonCode?,sourceModule,sourceEventId,payloadHash}；同源同hash幂等、异hash冲突留证，BLOCKED重放仍REJECTED |
| INT02 | `m09.AlarmConfigDecisionPort#applyConfigDecision(AlarmConfigDecisionCommand) -> AlarmConfigDecisionReceipt` | scope串行锁＋base revision CAS，一组配置不可部分生效 |
| INT03 | `m09.DeliveryReconciliationPort#reconcileDelivery(DeliveryReconcileCommand) -> DeliveryReconcileReceipt` | 输入=`deliveryId/expectedVersion/requestId/actorUserId/reason/providerRef?`；输出=`deliveryId/state/attemptId?/evidenceRef?/version`；只能通过核准查单能力核实，禁止手传SUCCESS |
| INT04 | `m09.DeadlineEvaluationPort#evaluateDeadline(DeadlineEvaluationCommand) -> DeadlineEvaluationResult` | 输入=`jobKey/businessDate/sourceSnapshotVersion/requestId/cursor?/limit`；输出=`eventIds/skipped[{sourceId,reasonCode}]/nextCursor?`；批上限500，稳定游标 |
| INT05 | `m09.MonitorAcknowledgementPort#acknowledgeMonitor(MonitorAcknowledgeCommand) -> MonitorAcknowledgeReceipt` | 执行ACK与候选配置内容分离 |

M09 `evaluateDeadline`另外消费三个事实源，不增加71计数：

- `m03.ResourceDeadlineFactsPort#pageDeadlineFacts(ResourceDeadlineFactQuery) -> DeadlineFactPage`
- `m05.DetectionDeadlineFactsPort#pageDeadlineFacts(DetectionDeadlineFactQuery) -> DeadlineFactPage`
- `m07.RunDeadlineFactsPort#pageDeadlineFacts(RunDeadlineFactQuery) -> DeadlineFactPage`

`DeadlineFactPage`固定包含`List<DeadlineFact> rows/String nextCursor/boolean hasMore/String sourceSnapshotVersion`；三方的`DeadlineFact`必须包含`sourceId/factType/dueAt/businessDate/sourceVersion/payloadHash`，M09不得查询M08统计表代替权威事实源。

### 6.9 Port逐方法来源分类（HTTP_ONLY / BACKGROUND_ONLY / BOTH）

#### 2026-10-12 液瓶联合接线增补

| 能力 | 冻结物理签名 | 输入与成功输出 | 调用前置与失败 |
| --- | --- | --- | --- |
| M03 液瓶培养关联 | `m03.BottleCultureAssociationPort#listCurrentCultures(BottleCultureAssociationQuery) -> BottleCultureAssociationView` | `labId,connectionId` -> 完整 `cultureIds`（空集合不表示槽位空闲） | HTTP_ONLY；M02-252/253 守卫回调及活动事务；同连接不同实验室/非法身份事实为 RESOURCE_FACTS_UNAVAILABLE；读取故障为 DEPENDENCY_UNAVAILABLE |
| M07 液瓶槽位占用 | `m07.BottleSlotOccupationPort#requireFreeSlots(BottleSlotOccupationQuery) -> BottleSlotOccupationView` | `labId,connectionId,resourceKeys` -> 全量逐键 `resources[{resourceKey,physicalState,fence,objectVersion}]`；缺仲裁行标 NO_GUARD，代次为 null，不伪造 FREE；M03 培养关联一致性在调用前独立完成，不传递未消费的 cultureIds | HTTP_ONLY；M02-252/253 守卫回调及活动事务；当前事务主键锁读、完整工作流/任务/命令/物料事实；明确占用409，UNKNOWN/不完整503，提供方故障503；不新开事务/不调用设备/不写占用 |

输入/输出类均归提供方 `service.port.m03.model` 或 `service.port.m07.model`。HTTP_ONLY 两口不能被后台资源事务、普通外层事务或无来源直接调用。模块 Mapper 白名单只增补 M03BottleCultureAssociationMapper、M07BottleSlotOccupationMapper 与 M07 已有主键仲裁锁读 RunResourceGuardMapper；不授予跨模块表直读。签名快照同批登记两接口，不改变既有接口签名。

依据《00-开发实现结构与事务编排约定》2026-10-11双入口合同第三轮"受控入口、来源与失败边界"：每个受影响Port在此逐方法登记调用来源分类，提供方在方法入口按分类断言来源，不把"有任一事务"视为授权。分类语义：

- **HTTP_ONLY**：只接受管理守卫回调来源，入口用`GuardCallbackContext.requireGuardCallback(expectedOperationCode, consumerLabel)`精确匹配动作码；后台资源事务入口进入即拒绝。用户/授权管理Port与既有运行/屏障Port不得整体放开为其他类。
- **BACKGROUND_ONLY**：只接受`ResourceTransactionExecutor`后台用途，入口用`ResourceTransactionContext.requirePurpose(expectedPurpose)`并复核事务/fence/assignmentEpoch；无上下文或守卫回调来源进入即拒绝。本批尚无此类Port方法（M07 `run_resource_guard`占用转换DAO随work1真实消费者同批登记）。
- **BOTH**：先判上下文种类，再走各自完整分支；没有有效上下文、或守卫回调与后台上下文同时出现均拒绝；"缺身份"（无来源）与"错误用途"（`requirePurpose`不符）四态运行用例由`ResourcePortOriginContractTest`覆盖。BOTH不等于两边都放宽，各自仍走完整来源核验。
- **POST_COMMIT**（2026-10-13）：物理网络提交/查询必须在声明事务提交后、无管理守卫/后台上下文及活动事务时，由登记的固定执行器协调器调用；无上下文本身不授权。`M07TaskPauseDispatcher` 只消费 `M07CommandInvocationWorker` 对已提交 PREPARED STOP 重验后生成的调用快照，M02 仍必须以真实传输认证和网关事实校验固定执行器/fence/配置。不得将端口放进 BOTH 事务持锁回调。缺提供方不做模拟成功。

精确方法清单（与`ResourcePortOriginContractTest.ROSTER`一致，Port方法增删必须同批改此表与测试登记）：

| Port#方法 | 提供方 | 来源分类 | 用途/操作码约束 |
| --- | --- | --- | --- |
| `m03.BottleCultureAssociationPort#listCurrentCultures` | M03 | HTTP_ONLY | M02-252/253 守卫回调及活动事务；检查当前培养占用身份完整性 |
| `m07.BottleSlotOccupationPort#requireFreeSlots` | M07 | HTTP_ONLY | M02-252/253 守卫回调及活动事务；SYSTEM 后按实际资源主键锁读，全事实核验 |
| `m03.ResourceUsageGuardPort#queryUnfinishedLabBusiness` | M03 | BOTH | 纯读，HTTP守卫态与后台持SYSTEM锁态均可用；缺可信ActorContext为`INPUT_INVALID` |
| `m03.ResourceUsageGuardPort#checkDeviceUsage` | M03 | BOTH | 阻断矩阵未冻结时两支均抛`DEPENDENCY_UNAVAILABLE`，不得返回放行 |
| `m02.DeviceCommandPort#submitCommand` | M02 | POST_COMMIT | 固定 `M07TaskPauseDispatcher` 在独立调用前声明事务提交后派发，受理≠执行 |
| `m02.DeviceCommandPort#queryCommand` | M02 | POST_COMMIT | 固定执行器以原命令身份查单；不得在持锁事务内网络等待，不重发物理动作 |
| `m02.SoundAlarmCommandPort#resolveTargetFacts` | M02 | HTTP_ONLY | M09-016 守卫回调及活动事务；`lab_sound_alarm` 主键窄读，不存在/软删不可见 |
| `m02.DeviceReadingsPort#resolveExecutionReadings` | M02 | BOTH | 执行读数解析，只读投影，条件登记（随work1实际调用点收敛） |
| `m02.LabAuthorizationPort#prepareUserEdit` | M02 | HTTP_ONLY | 用户实验室授权管理口，不放开后台 |
| `m02.LabAuthorizationPort#replaceUserLabs` | M02 | HTTP_ONLY | 同上 |
| `m02.LabAuthorizationPort#removeUserLabs` | M02 | HTTP_ONLY | 同上 |
| `m01.ActorContextPort#resolveActorContext` | M01 | HTTP_ONLY | 身份解析，守卫内部使用 |
| `m01.ManagementRevisionPort#verifyManagementRevision` | M01 | HTTP_ONLY | 版本核验，HTTP写专属 |
| `m01.FunctionPermissionPort#checkFunctionPermission` | M01 | HTTP_ONLY | 功能权限判定，不放开后台 |
| `m07.CultureRuntimePort#publishRuntimeFact` | M07 | HTTP_ONLY | 运行事实发布，维持原守卫上下文要求 |
| `m07.CultureRuntimePort#resolveReleaseProof` | M07 | HTTP_ONLY | 释放证明解析，维持原守卫上下文要求 |
| `m07.RuntimeFactProofPort#verifyRuntimeFact` | M07 | BACKGROUND_ONLY | 仅 `M03_RUNTIME_RECONCILE`，真实活动事务及已取得 SYSTEM 锁；核验持久来源事实、当前 W03 归属与冻结占用，不信任调用方 sourceProof |

未列入本表的方法一律按HTTP_ONLY对待（维持原守卫上下文要求，后台入口调用即被`requireGuardCallback`拒绝），新增BACKGROUND_ONLY/BOTH必须在此登记并同步`ResourcePortOriginContractTest`精确清单。

#### 2026-10-13 声光关闭命令联合接线增补（M09-016）

`m02.SoundAlarmCommandPort#submitCommand` 与 `#queryCommand` 是有意不列入精确方法清单的两个方法：管理写设计禁止在持锁守卫事务内进行远程调用或设备命令（详细设计 §25.2），二者由 M09-016 应用服务在守卫事务提交后于同一 HTTP 请求线程派发/查单，调用时既无守卫回调上下文、也无后台用途上下文，不适用 HTTP_ONLY/BACKGROUND_ONLY/BOTH 任一分类，故不登记 `ResourcePortOriginContractTest` 精确清单（该清单按端口声明方法全集登记，部分登记会打破"增删方法必须同批改登记"的闭合断言）。EXT-07 现场通道未核准期间提供方对二者失败关闭（DEPENDENCY_UNAVAILABLE），不为"看起来接线"放行；真实派发/查单能力随 EXT-07 核准批次落地时，必须同批在此表登记二者来源分类并同步测试清单，不得沿用本条豁免。

## 7. Port模型实施规则

1. 一个方法只有一个Request和一个Response；参数较少也不得退化成多个裸`String`。
2. ID、版本、时间、金额/数量和枚举禁止使用`Object`；扩展业务载荷使用明确版本化模型，不使用无约束`Map`。
3. Port Request必须携必要的可信上下文或其引用，但不得接受浏览器自报actor、ownerModule、sceneCode替代服务端推导。
4. 查询Port不得产生业务写；写Port必须由提供方应用服务拥有事务，消费者不得直接写提供方表。
5. Port异常统一抛领域异常并携`FutureFabErrorCode`；不得返回`null`、`false`或空列表伪装依赖故障。
6. 同一模型跨多个Port共享时只定义一次：审批的`ApprovalDecisionCommand/Query/DeliveryResult`、运行事实的`RuntimeFact`、事件的`EventEnvelope/EventReceipt`、截止事实模型均按提供方包归属并被其他Port引用。
7. 所有Request/Response/枚举必须有字段级Javadoc，标明必填、可空、单位、长度和值域；Lombok只减少样板，不替代契约说明。

## 8. 明确未实现状态

PKG-00只创建接口，不创建默认实现。PKG-01—08创建业务骨架时，尚未补充的应用方法和Port适配器必须抛`SkeletonNotImplementedException(contractId)`；禁止：

- 返回HTTP 200、`applied=true`、0、空集合或null；
- 写占位SQL或`SELECT 1`；
- 以随机ID、当前时间或内存Map伪造回执；
- catch异常后转空结果；
- 为通过启动而创建`@Primary`空实现。

生产准入扫描必须匹配异常类引用和`NOT_IMPLEMENTED`文本，结果均为0；未通过时不可部署。

## 9. PKG-00验收门禁

| 门禁 | 通过条件 |
| --- | --- |
| 文件归属 | 只修改第2节路径和两个获准POM；业务模块Controller/Impl/Mapper/SQL变更为0 |
| 错误码 | 8份错误码全集中HTTP码107、非HTTP原因码21；各自唯一；HTTP/重试语义冲突0；`ACTION_DENIED` canonical命中0 |
| 认证 | I01—I05方法5、Request 5、Response 5；路由/方法/Header与第5节完全一致 |
| 内部契约 | 73个契约ID每个命中一次，遗漏0、重复0；三个附加截止事实源不计入73 |
| 公共类型 | 8个响应原始类型和`NoBody`各一个定义；泛型参数不产生重复文件 |
| 依赖 | auth/system均显式依赖api-system；auth与system互相依赖0；Port依赖Controller/Mapper/Entity/Impl为0 |
| M08边界 | Java import、Maven依赖、Port包、DTO包中`m08`命中0；允许文档说明未来事件消费 |
| 编译 | `mvn -pl futurefab-api/futurefab-api-system,futurefab-auth,futurefab-modules/futurefab-system -am -DskipTests compile`通过 |
| 契约测试 | 公共类型序列化、认证注解反射与降级脱敏、错误码唯一性、Port完整方法类型签名、高风险详细模型字段快照、递归依赖边界和真实M08包资源扫描通过 |
| 未实现状态 | PKG-00没有实现类；后续骨架未实现点显式抛异常，不存在伪成功 |

## 10. 给执行工具的PKG-00提示词
### M02-227 联合后端接线增补（2026-10-12）

M07 新增 `ControllerCommandFactsPort#lockAndCheck(ControllerCommandFactsQuery)->ControllerCommandFacts`，单 Request/Response 均位于 `service.port.m07.model`。Query 固定 labId/connectionId；Response 固定 labId/connectionId/factsVersion/blocked/completeness。来源为 HTTP_ONLY M02-227 守卫回调，必须活动事务，禁止普通调用、异步传播或自造 GuardCallbackContext；身份只从冻结上下文取。能力只锁定本次控制器规范主键并读事实，不发命令、不释放或转移占用；仅 FREE 首建可 INSERT 互斥行，存量 upsert 不改变原状态。Port 签名名册由 49 接口增至 50，其他签名不变。

M03 `DeviceUsageQuery.expectedLabId` 是该窄分支的附加服务端归属证据，由 M02 已锁的连接行填入，不接受浏览器 Body。API02 其他用途仍按原契约失败关闭，不能据本批声明全部设备在用矩阵已实现。细节以 M02 工程逐接口契约 4.2 为准。


> 只执行PKG-00，不写业务逻辑。先完整阅读`docs/开发任务/02-PKG-00公共契约与Port物理签名设计.md`、`01-骨架文件所有权与并行任务包.md`、`00-全接口契约骨架清单.json`和`docs/详细设计/00-开发实现结构与事务编排约定.md`。严格按物理路径创建错误码、M01 I01—I05认证契约、8个公共响应类型、NoBody、76个内部契约对应的Port及模型，并只修改获准的两个POM。不得创建Controller、Impl、Mapper、XML、SQL或M08类型，不得返回伪成功。完成后执行第9节全部门禁并输出文件清单、契约ID映射、编译结果和任何未解决冲突；发现设计冲突立即停止，不在代码中自行取舍。

## 11. 结论
### 2026-10-13 通讯删除联合提供方增补

| 提供方 | Port 物理签名 | 真实事实边界 |
| --- | --- | --- |
| M05 | `CommunicationUsageFactsPort#evaluateCommunicationUsage(CommunicationUsageQuery)->CommunicationUsageFacts` | M05 自有样品、结果、派发事实；只在 SYSTEM 首锁所属事务读取 |
| M07 | `CommunicationUsageFactsPort#evaluateCommunicationUsage(CommunicationUsageQuery)->CommunicationUsageFacts` | M07 自有工作流、任务、命令、执行、会话与资源占用；未知不当空闲 |
| M02 | `CommunicationUsageRegistrationPort#registerDetectorUsage(CommunicationDetectorUsageCommand)->CommunicationUsageRegistrationReceipt` | 检测写方同事务追加真实关联，不接受自报已结束状态 |
| M02 | `CommunicationUsageRegistrationPort#registerResourceUsage(CommunicationResourceUsageCommand)->CommunicationUsageRegistrationReceipt` | 运行写方同事务追加；先有受控接入映射，再核完整资源覆盖 |

事实请求和响应共享模型位于 `service.port.m02.model`，登记命令/回执同包；不依赖 Controller、Mapper、Entity 或 support 实现。适配器签名凭证仅用于 M02 内部接入服务，不进入上述 Port。Port 名册实际 55 个能力接口，单请求/单响应门禁同步；既有签名不变。OBS-I01 提供方委托 M02 接收引擎，可信上下文不能由普通调用构造。此登记是源码/契约层交付，不代表 SQL、设备或部署通过。


### 2026-10-13 M06-015 拥有方审计只读提供方增补

| 提供方 | 物理签名 | 来源 |
| --- | --- | --- |
| M03 | `DirectAuditQueryPort#queryDirectAudit(OwnerAuditQuery)->OwnerAuditResult` | 基础候选与参数应用的固定 policy_evidence，均只读自有表 |
| M07 | `DirectAuditQueryPort#queryDirectAudit(OwnerAuditQuery)->OwnerAuditResult` | 自有任务候选 source_request_id 与 decision_snapshot |
| M09 | `DirectAuditQueryPort#queryDirectAudit(OwnerAuditQuery)->OwnerAuditResult` | 自有配置修订 decision_snapshot 与固定 content_json 范围 |

共享 Query/Record/Result 位于 `service.port.m06.model`。Query.approvalId 仅由 M06 按同一拥有方与原请求读取真实 apr_request 后填入；提供方仍核对象范围。提供方不采信 Query.authorizedLabIds 的授权声明，不把 M03/M09 散列请求键冒充原请求。Record.sourceRequestId/mode 与行为者 kind/姓名仅取持久证据；旧 schema1 缺项留空并提示。方法仍为一 Request 一 Response，Result.records 只承载查到的候选证据；超过一条拒绝，不新增列表 HTTP 或混合分页。能力接口总数由 55 增为 58，签名快照与三个 Mapper 精确白名单同批维护。

上述是源码与契约登记，不证明完整 schema2 写方、真库、HTTP 或部署已通过。

PKG-00已经从“文件所有权计划”补齐到“可直接生成的物理签名设计”。下一步可以执行PKG-00代码骨架，但只有在用户明确通知开始写代码后才能实施；在此之前不得启动Java/POM修改。


### P2-04 / INT01 回执身份补齐（2026-10-21）

内部共享 `m09.model.EventReceipt` 保留原四种状态及 receiptId/duplicate/reasonCode，新增 sourceModule/sourceEventId/payloadHash 三字段，由持久收件身份及原存储摘要产生。CONFLICT回传原存储hash，不伪装入站包已被接受；BLOCKED同hash重放仍REJECTED，保留原result_ref原因，不重新应用或改写原行。M07新的安全事实发布器只接受三字段与本包一致且稳定receiptId匹配的ACCEPTED/DUPLICATE；旧实现缺字段的回执不被当作可信ACK，继续RETRY。既有构造/访问方法保持兼容，此调整不变更EventIngestionPort方法签名、公开HTTP DTO、EventEnvelope或既有JSON输入白名单。持久收件不等于通知或设备执行完成。


### 2026-10-24 M06 当前成员资格与源预检窄 Port

- `m03.ApprovalMemberCandidatesPort#load(Query)->Candidates`：Query 是 cultureId/projectId/batchId/labId/businessDate；Candidates 分别返回 batchMembers/projectMembers。提供方 `M03ApprovalMemberCandidatesAdapter` 只依赖 `MemberIdentityFactsMapper` 三个精确查询：当前祖先验证、当前批次 MEMBER 枚举、当前项目 MEMBER 枚举；不访问 M06 表，不判定审批通过，不把故障当空集。
- M06 通过原 `m01.DeferredActorPermissionPort#allowed(long,String)` 精确复用当前启用账号及功能权限，新增消费仅允许 `process:approval:review`、`process:approval:approve`，由 M06 与 M02 当前 OPERATE 求交、排除申请人/前阶段人。管理员功能权限不能代替 MEMBER 资格。
- `m06.ApprovalOwnerPrecheckPort` 的精确 M03/M07 提供方和源字段以各 owner 当前契约为准；M06 只调用 Port，不跨 owner Mapper。读 precheck 无锁，写 lockAndPrecheck 要求真实活动事务；签审锁序按 M06 接口与审批生效契约的 2026-10-24 段落执行。

## 2026-10-24 补液候选 DIRECT 精确增补

- M06 DirectParameterDecisionPort：withDecision(ApprovalPolicyQuery,String,String,Function<Evidence,T>)->T、requireCurrent(Evidence)->void、requireOriginal(Evidence)->void。同步能力回调，不是通用审批放行接口；精确证据格式与绑定见 M03/M06同日契约。
- M04 GenerationPackagePort：新增 decodeForDirectCandidate(DirectCandidatePackageQuery)->TemplatePackage；单 Model Request，未接入默认拒绝。原 decodeForGeneration 签名/权限保留。
- M03 ApplicationReceipt：schema1审批/既有Q31不变；DIRECT schema2携带必须精确校验的directDecision。没有新增数据库列或执行状态。


### 2026-10-26 cloud兼容整合：既有培养基名称窄读签名登记

保留远端已有 `M02 PilotWorkflowConfigurationPort.readMediumNames(ActorContext, String labId, List<String> mediumIds) -> List<MediumName>`。这是既有精确签名登记，返回行固定 `mediumId/name/issues`，不泛化为其他Port可使用多参数或任意集合。来源为中试W01显示与结束培养泵列表；M02提供方继续核验可信当前身份、实验室操作范围、严格ID与引用存在性，不授予实际写设备、计量或停止能力。签名快照逐方法校验该例外的参数、泛型返回及原方法集合；其他Port仍执行单Model输入输出规则。

## 2026-11-07 V5.1完整已选工作流完成的同库契约

本增补依据原生29—34及M03现行运行契约；M03继续独占培养生命周期与D0，M07只证明自身原件。精确增补如下，全部abstract、必须配真实提供方，不提供默认空方法：

- CultureOperationFactsPort.lockForWorkflowCompletion(CultureOperationFactsQuery) -> CultureOperationFactsView。使用既有模型，View新增List<String> selectedWorkflowNodeIds，取M03实际workflow_selection_json。原SYSTEM守卫内按实验室、培养、原主占用顺序预锁；批量全部预锁后才取得M07实例/步骤锁。
- CultureRuntimeReceiptPort.applySelectedWorkflowCompletion(String cultureId,String workflowId,String workflowVersion,String expectedCultureVersion,String expectedPlanVersion,String occupancyId) -> void。参数来自实际完成实例及预锁版本，不来自客户端自签证明；原M07请求事务内应用，M03状态及审计同事务，失败整体回滚。
- RuntimeFactProofPort.verifySelectedWorkflowCompletion(String cultureId,String workflowId,String workflowVersion) -> void。核实例属于当前培养的实际已选节点、步骤身份/顺序/合法跳过/完成时刻及精确CAS后版本；按各原流程的PENDING/APPLIED语义核验，不给所有流程新增APPLIED硬前置。
- RuntimeFactProofPort.hasCompletedSelectedWorkflow(String cultureId,String expectedLabId,List<String> selectedNodeIds) -> boolean。截止应用持M03锁传实际选择；已知无匹配才false，未知/损坏抛异常，不作为释放依据。
- RuntimeFactProofPort.requireFirstWorkflowStartedFact(String cultureId) -> 既有RuntimeFact。只读M07已持久化的原FIRST，核原列、正文、hash和真实步骤，不在读取时合成事件。真实首次完成调用方缺生产时由该业务分支复用原生产者记真实事实。

FIRST可能在完成事务内才追加，不强制等待后台APPLIED。完成应用在同库原事务收件并按原证明受控应用FIRST，再重读实际版本进行正式RUNNING转换；原事件身份、真实发生时刻和原版本不改，已存在BLOCKED只按既有合法重基线条件处理，不能以放宽校验跳过。不得从完成guard借伪造R03 SourceProof，不新增事件枚举/表/重试状态机。重复请求和稍后同原件投递沿现有幂等回执，不能重复审计或重复推进对象版本。

同步FIRST在已持原SYSTEM/培养/占用及event行锁后，只以event原object_version进行具名应用CAS；不新增租约领取或令牌。旧worker既有lease SQL不扩用到本同步路径。RECEIVED/BLOCKED一次CAS为APPLIED并保留原回执历史，APPLIED重投核原消费水位，任一写失败同原M07事务回滚。

上述为本轮实现冻结契约；实际源码/行为测试/HTTP验证进度见开发报告，签名登记本身不等于实现完成。签名门禁仅为上述精确方法登记多参数/void窄例外，其他Port不扩散例外。

## 2026-11-07 API15在线趋势只读来源增补

范围由V5.1《18-反应器》6835—6839、有效第78问1438—1448及已确认结束截止4892—4900确定，现行M08统计专题落实：当前列选日/未选上海当天、每次一天，D-1合并真实D0之前时间，实际结束包含截止；不套用P1采样或改设备历史归属。

原OnlineStatisticsSourcePort增加嵌套`ComparisonTrendQuery(long cultureId,long itemId,String unit,LocalDateTime fromInclusive,LocalDateTime toExclusive,LocalDateTime throughInclusive,LocalDateTime afterObservedAt,Long afterSourceId,int limit)`。UTC日窗口半开，throughInclusive只为真实结束时刻、未知为null；双空游标表示首次，后续为最后真实点，limit复用原离线技术分段500，不是业务频率或结果截断。

对应精确只读方法为`comparisonTrend(ComparisonTrendQuery) -> List<StatisticsSource.Point>`；需先实际行为RED，再与真实提供方同窗声明abstract，不增加默认空方法。历史培养/实验室授权、原单位、日窗及实际结束过滤在源候选排名/冲突判定之前；同刻冲突不能被技术分段或以主键择优掩盖。消费者在原只读事务内取全合法范围，复用原API15/Point/图表，不新增存储、令牌、统计写职责或物理动作。

## 2026-11-07 SC046原审批快照透传与事实用途

原共享ApprovalDecisionCommand增加`changeSnapshot:String`及`sourceRequestId:String`，仅M09+SC046由原M06 ApprovalDeliveryExecutor直接复制当前原审批行已冻结的change_snapshot文本及source_request_id，APPLY/DISCARD及同原交付重放均保持原文。sourceRequestId是原提交身份，不能以本次交付追踪requestId替换或从不可逆摘要猜造。不是浏览器输入、不重建祖先、不新建审批事实查询Port；其他owner不填这两字段，null不序列化，保持M03/M07既有决定JSON与原摘要/重放语义。SC046必须严格核原快照中的候选、schema、四级祖先与决定身份。投递物理签名不变，不增加状态、表或身份机制。

原M03 CultureOperationFactsPort仅增加M09/M09-013用途，必须在原管理写事务及同名守卫回调内，以原冻结actor查询培养祖先；不借M07成员资格授予M09权限，不要求离线告警无关的工作流选择与占用。M09仍核自身当前实验室操作权/培养可见范围。原ApprovalCultureSourcePort只增加精确M09+M06_SC046+ALARM_CONFIG组合，仍逐项核原冻结祖先与当前真实归属；不接受其他M09用途，不制造后台会话。

本段为内部技术接线差异，不新增业务规则；实现、实际测试和未验证范围分别记录在本轮开发报告。

## 2026-11-07 批次对比在线配对只读来源增补

M02原OnlineStatisticsSourcePort拟增加精确方法`comparisonValues(long cultureId, java.time.LocalDateTime anchorAt) -> List<ComparisonOnlineValue>`，后者为该Port嵌套record(itemId:String,label:String可空,unit:String可空,point:原StatisticsSource.Point可空)。anchorAt为UTC真实BGA完成锚/实际结束截止后的合法上界，可空；无锚只返回本培养真实指标/原单位元数据，不取当前值凑配对。

每指标/原单位返回锚前最近真实观测，value与o.unit成对，原sourceId/sourceVersion/time/quality保持；不设最大间隔、不平均、不退旧GOOD、不按接收时间剔除迟到真实观测。itemId来自原核准mapping.item_id，label仅按该稳定ID补原名称，缺字典标签不抹历史。读取前核培养历史权限，实际来源lab范围进入SQL且先于排名/最近选择；无授权拒绝、真无来源空列表、依赖故障或不能裁决的原冲突抛原领域错误，不默认空、不按ID任选冲突值。

这是原统计提供方的一项必要窄查询，不改变OBS采集/核准/冲突协议，不新增表、枚举、快照、租约或幂等收据。新增模型仅为上述字段，不扩散成其他Port多参数/集合的通用许可。先真实RED再实现，当前登记不代表代码接线或运行验收。

M09必要只读提供方`CurrentCultureOnlineBoundsPort.readCurrentCulture(long cultureId) -> List<Bound>`；Bound为同Port嵌套record，字段cultureId/deviceKind/deviceId/configId/itemId/unit/lowerLimit/upperLimit/rowVersion/revisionId均原字符串/可空值。M03原统计Origin合同提供历史读范围/lab交集与当前绑定，M09仅查自有当前CULTURE集合，不继承DEVICE、不读旧绑定阈值、不输出通道/接收人。失败与已知空分开；实际消费者为M08 API14。只有该只读查询冻结，不扩大SC开始培养Port的继承/应用职责。详细边界见M09现行告警配置专题及B10报告，先真实RED后实现，不把接口声明当成功链路。

## 2026-11-07 D0修正的原服务窄增补（B08）

Q-3-02最新答复替代本节旧UPDATE改期语义：原D0拦截保留，方案来源未执行任务取消后新生成，人工日历任务保留，已执行具体计划不再生成；取消/新增沿原审批。下列方法保留为原服务适配入口，返回ID仅表示其注明事实，不能表达完整取消/新建审批结果；调用链和生成身份须按本轮目标另核，不将旧实现标为已落实。

原M07CultureChangeSupportPort保留四个既有方法；两项D0用途：

- `prepareD0Change(Long cultureId, LocalDate beforeD0, LocalDate afterD0, LocalDate afterEnd) -> List<String>`：原M03锁/事务内核本培养就绪及分类，返回本次分类需取消ID作为影响预览，不表示已取消。
- `applyD0Change(CultureOperationFactsView currentCulture, Long cultureCandidateId, LocalDate beforeD0, LocalDate afterD0, LocalDate afterEnd, String reason, Long actorUserId, String requestId) -> List<String>`：同原M03应用事务，View从拥有方已锁行投影真实祖先/当前版本/状态/日期，不能从Body造事实；身份取原候选/可信决定，不造HTTP会话。M07逐任务核归属、执行事实和版本，返回仅已实际取消ID，需审候选由原任务查询投影。

后台生成的原CultureGenerationFacts、原无会话审批ApprovalCultureSourcePort.Facts各追加plannedStartDate/plannedEndDate（LocalDate可空，取M03本培养持久值，不借核准配置或计划默认值补齐）。原构造可保留未知null语义，不作可用日期；read/lockAndRead方法不增加。M07审批决定先原SYSTEM/lab→M03源锁，再任务/候选锁，不把活动事务当已持首锁证明。

仅新D0任务候选after_snapshot增加`cultureDateChange:{cultureId,candidateId,beforeD0,afterD0,afterEndDate}`，均原件身份/日期；本次方案变更不再生成UPDATE改时间候选；旧`M07:TaskCandidate:UPDATE:D0:v1`仅用于历史解码，不作为新方案变更写入目标；CANCEL既有引用`M07:TaskCandidate:CANCEL:D0:v1`保留，新增任务仍按原CREATE协议核验。M06原结构/正文/祖先/候选身份交叉校验不放宽，M07重新核完整after摘要及当前源/目标事实，标记本身不是授权。普通手工v1不变。

旧UPDATE来源保留历史；本次取消来源沿原字段`M03-D0:{原培养候选ID}:TASK:{taskId}:CANCEL`，最长58字，复用原source_request_id唯一约束；活动changeKey仍TASK:taskId。requestId继续原可信请求追踪，同来源先核完整原候选再重放，不分配新键或新候选来恢复未知。新generationPolicy仅补实际dayZero，旧键/正文/hash不改；旧具体日序只从当时固定生成/可验证核准来源取，缺证据不猜当前D0。不得将仅ruleId重复当所有多日发生项都已执行。

上述只冻结必要现有类型/方法/JSON差异，不建新服务框架、存储、业务状态、租约或令牌；必须先RED再同批连上原生成、调度、审批和查询消费者，未连线不能报实现完成。

## 2026-11-07 P2设备标签原Port精确窄读

原m02.OnlineStatisticsSourcePort增加abstract comparisonDevice(ComparisonDeviceQuery)->ComparisonDevice。原嵌套record Query为(cultureId:long,labId:long,deviceKind:String,deviceId:long)；结果为(deviceKind:String,deviceId:String,code:String,serialNo:String,metadataStatus:String)。实际消费者为原M08 API14列及API16重验/Excel，原趋势接口不增加此依赖。只读真实BENCH_CONTROLLER.controller_no或INTEGRATED_REACTOR.device_no；无合法序列号来源保持null，不取串口、资产号或设备ID代替。沿当前读取READY/UNAVAILABLE语义，非新业务状态；不能披露标签时code/serialNo为空，原培养/lab403/404不降为空。确切实现与分层验证见B03b/B10及02逐轮结果，不以Port声明当实际接通。
