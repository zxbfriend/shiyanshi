# M03 Controller 请求调用时序设计

## 2026-10-27 CU02-W基础与暂存补液联合保存

Controller按原权限接收路径cultureId及WriteMeta，转CultureApplicationService.patchBasic；feedingPlan为顶层可选字段，内部身份和元数据由路径/外层覆盖。服务按原M03_019执行一次SYSTEM守卫，幂等载荷包括方案正文；锁内重读培养并验证身份、实验室、状态、外层对象版本和方案旧培养/计划版本。携带方案仅允许未开流程的DRAFT/NOT_STARTED，后像必须有有效周期。

基础补丁非空时复用原prepare/apply：预约替换、基础CAS、计算规则和观测关联同事务；只有方案时跳过基础写入但保留全部准入校验。随后从当前培养事实取得修改后的对象/计划版本，调用补液服务的MANDATORY内部入口，按修改后流程、设备和周期验证并冻结方案；expectedSlotVersion仍是用户读取的原槽版本，不因设备改变重置。复用现有补液snapshot/state/application/workflow_reference写入，返回方案审计字段并合入同一RES_CULTURE审计快照，最后由外层守卫写审计、回执及管理版本。任一步异常整体回滚，不调用嵌套守卫，不发送任务或设备命令。批量和原独立补液请求维持各自事务，不能将两个HTTP请求当作联合事务。

## 项目检测规则补充（M03-046/047）

GET `ProjectDetectionRuleController.get` 解析路径/实验室 → 应用服务按项目普通可见及lab查看范围读取 → 项目参与lab/labType校验 → 有覆盖读M03配置、无覆盖经Port读取M02真实六项默认 → 带项目版本及顶层管理版本响应。

PUT `ProjectDetectionRuleController.save` 使用WriteMeta双头 → 应用服务形态校验及M02只读值域校验 → M03-047 SYSTEM守卫 → 项目锁内Q05资格+lab操作+项目参与关系+项目CAS → 项目版本+1与覆盖配置upsert → 前后审计及幂等回执同事务。锁序为SYSTEM守卫→project→project配置；不修改M02规则行。精确契约见[项目级检测规则配置契约](项目级检测规则配置契约.md)。

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-总纲与约定/00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

## 1. Controller入口逐项映射

### 2026-10-24 中试正常结束专用测试保存

Controller仍为M07步骤操作入口，不开放另一条人工结束中试通道。`M07-END-CULTURE-COMPLETE`锁SYSTEM并处理幂等后，经`PilotEndCultureFinishPort`先锁M03培养和原占用、复核实时身份/操作权/版本/日期，再由`PilotEndCultureReleasePort`锁M07实例与步骤并核验专用测试允许列表、全部模拟泵手动停止和任务/资源/命令/执行计数。M03更新FINISHED、释放原占用并同步观测关联；M07完成步骤和实例、追加本地事件；M03培养前后AuditIntent原样交守卫，审计与revision/回执同提交。后写失败整组回滚。此路径只允许明确配置的模拟测试培养，真实设备和异常审批另行接入；详见[M07契约](../07-补液运行与任务执行/中试结束培养接口契约.md)。

### 2026-10-13 M03-013/032/033 执行顺序

公开请求：Controller 鉴权与参数校验 → `CultureChangeCommandService` → 管理守卫锁 SYSTEM/校验幂等 → M02 锁实验室 → M03 锁培养/资格与版本预验 → 周期改变时锁 FEEDING 包槽位 → M07 锁 runtime/执行与任务屏障 → MODE 由 M02 锁设备/核对配置指纹 → 冻结 before/after/diff/政策及候选摘要 → M06 政策分流。

DIRECT 类分支同事务 CAS 生效并保存候选回执；APPROVAL 分支提交完整差异与分区展示快照并绑定审批。公开写继续使用现行请求制式，不放宽双头或版本校验。

决定回调：M06 投递 worker 在其领取事务之外调用 M03 Port → M03 同库事务先锁 SYSTEM → 查询候选身份/原回执 → 同上述顺序重验原申请人实时功能、身份、实验室、培养版本、M07 屏障和 MODE 固定设备 → 最后锁候选并重验 → 生效/驳回/冲突回执 → 成功审计 → SYSTEM revision CAS → 提交。依赖失败及后写异常回滚；可证明的前置业务拒绝持久化 CONFLICT，未知结果按原投递身份查询。

DATES本轮D0修正保留方案，按[日期影响契约](培养运行变更页面与接口契约.md)第3节取消方案来源未执行任务并按新方案生成；人工日历任务保留；D0提交/应用均核当前培养待审或执行中补液，不通过则拒绝。M06_SC028按实验室适用配置，一次联动一张审批单；本次方案变更取消/新增分别按原适用审批，新计划仅今天尚未到点及未来日期生成；不借系统跨天取消免审跳过人工方案变更审批。审计同事务，设备/HTTP事务外。其他非D0日期变更不据此扩展。

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位006 | GET /resource/project/list | 详细设计.md | M03.定位006 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位007 | GET /resource/project/{projectId} | 详细设计.md | M03.定位007 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位008 | GET /resource/project/options | 详细设计.md | M03.定位008 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位009 | POST /resource/project | 详细设计.md | M03.定位009 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位010 | PUT /resource/project/{projectId} | 详细设计.md | M03.定位010 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位011 | POST /resource/project/{projectId}/delete-preview | 详细设计.md | M03.定位011 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位012 | POST /resource/project/{projectId}/delete | 详细设计.md | M03.定位012 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位013 | GET /resource/batch/list | 详细设计.md | M03.定位013 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位014 | GET /resource/batch/{batchId} | 详细设计.md | M03.定位014 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位015 | GET /resource/batch/options | 详细设计.md | M03.定位015 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位016 | POST /resource/batch | 详细设计.md | M03.定位016 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位017 | PUT /resource/batch/{batchId} | 详细设计.md | M03.定位017 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位018 | POST /resource/culture/{cultureId}/mode | 详细设计.md | M03.定位018 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位019 | POST /resource/culture/{cultureId}/n-mark | 详细设计.md | M03.定位019 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位020 | POST /resource/batch/{batchId}/delete-preview | 详细设计.md | M03.定位020 | CTRL-PRE | 只读；当前Q21身份和删除功能权限；顶层managementRevision与签发令牌绑定同次读取版本；不锁定未来资格 |
| 定位021 | POST /resource/batch/{batchId}/delete | 详细设计.md | M03-016 | CTRL-BATCH | 双头WriteMeta；SYSTEM幂等守卫→新请求锁内Q21/令牌/引用/对象CAS→墓碑、审计、管理版本与回执同事务 |
| 定位022 | GET /resource/culture/list | 详细设计.md | M03.定位022 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位023 | GET /resource/culture/{cultureId} | 详细设计.md | M03.定位023 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位024 | PATCH /resource/culture/{cultureId} | 详细设计.md | M03.定位024 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位025 | POST /resource/culture/basic-batch | 详细设计.md | M03.定位025 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位026 | POST /resource/culture/{cultureId}/delete-preview | 详细设计.md | M03.定位026 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位027 | POST /resource/culture/{cultureId}/delete | 详细设计.md | M03.定位027 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位028 | POST /resource/culture/{cultureId}/withdraw | 详细设计.md | M03.定位028 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位029 | POST /resource/culture/{cultureId}/rebook | 详细设计.md | M03.定位029 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位030 | POST /resource/grants/query | 详细设计.md | M03.定位030 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位031 | POST /resource/grants/candidates | 详细设计.md | M03.定位031 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位032 | POST /resource/grants/save | 详细设计.md | M03.定位032 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位033 | POST /resource/{type}/{id}/exit-preview | 详细设计.md | M03.定位033 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位034 | POST /resource/{type}/{id}/exit | 详细设计.md | M03.定位034 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位035 | POST /resource/grants/selection-snapshot | 详细设计.md | M03.定位035 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

## 2. 目录尾部补登记入口

下列入口出现在目录的后续补登记区。本文给出稳定调用映射ID；原业务接口ID（如CU-R01、OBS-Q01）仍以对应来源契约为准，二者必须在实现清单中同时登记。

| 调用映射ID | HTTP入口 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- |
| CU-W01 | GET /resource/culture/{cultureId}/initial-weight | M03.CU-W01 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| CU-W02 | POST /resource/culture/{cultureId}/initial-weight-changes | M03.CU-W02 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| CU-R01 | POST /resource/culture/{cultureId}/runtime-changes | M03.CU-R01 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| CU-R02 | GET /resource/culture/{cultureId}/runtime-changes/current | M03.CU-R02 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| CU-R03 | GET /resource/culture/{cultureId}/runtime-changes/{candidateId} | M03.CU-R03 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| CU-R04 | GET /resource/culture/{cultureId}/runtime-change-requests/{requestId} | M03.CU-R04 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| CU06 | GET /resource/culture/device-associations | M03.CU06 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| CU07-P | GET /resource/culture/{cultureId}/finish-precheck | M03-045 | CTRL-READ | 校验培养可见范围与实验室操作权，经M07只读Port聚合当前事实；仅RUNNING且上海业务日等于生效结束日为正常、RUNNING提前为异常，DELAYED或错过结束日须先主动改计划并生效；前置及任务按M07实际已选/执行分类，不按全部任务清空判断。两类主设备仍提示必须走完整结束工作流；跨期待审关联Q-3-06，预检不写终态或释放 |
| CU07 | POST /resource/culture/{cultureId}/finish | M03-045 | CTRL-WRITE | 小试BENCH_CONTROLLER与中试INTEGRATED_REACTOR均拒绝旧人工结束写口；其他原允许设备类型沿用WriteMeta双头、锁培养/占用、重算结束类型与M07 ReleaseProof，安全收口后写终态和释放占用 |
| BIND-Q01 | GET /resource/culture/{cultureId}/observation-bindings | M03.BIND-Q01 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| 定位001 | M03-P01 saveParameterCandidate | 培养参数快照与审批生效收尾契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位002 | M03-P02 applyParameterDecision | 培养参数快照与审批生效收尾契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| INT-M03-R03 | reconcileRuntimeEvent | 运行事件资源释放与延期收尾契约.md，2026-10-15补充 | CTRL-INTERNAL | SYSTEM/lab/培养/原收件锁→原请求回执重放→原文及索引验真/占用→M07权威证明→原事件状态/占用/CAS回执；受控内部消费实现已接线，自动恢复调度与实库联调未验证 |
| 定位003 | M03-P03 queryParameterApplication | 培养参数快照与审批生效收尾契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位004 | M03-P04 readEffectivePackage | 培养参数快照与审批生效收尾契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位005 | M03-P05 WorkflowReference.checkRemoval | 培养参数快照与审批生效收尾契约.md | CTRL-INTERNAL | 仅可信M04调用；全历史引用不明时禁止删除 |
| CHG-I01 | prepareCultureChange | 培养基础变更候选与生效契约.md | CTRL-INTERNAL | M03拥有方内部；固定before/after/impact/hash |
| CHG-I02 | attachApproval | 培养基础变更候选与生效契约.md | CTRL-INTERNAL | 相同绑定幂等；禁止候选换审批单 |
| CHG-I03 | applyCultureChange | 培养基础变更候选与生效契约.md | CTRL-INTERNAL | 固定决定；APPLIED/CONFLICT/UNKNOWN持久回执 |
| CHG-I04 | queryCultureChange | 培养基础变更候选与生效契约.md | CTRL-INTERNAL | 只查原候选/决定，不写业务字段 |
| CHG-I05 | sealCultureChange | 培养基础变更候选与生效契约.md | CTRL-INTERNAL | 双人核准后永久封禁；迟到apply不可复活 |
| BIND-I01 | publishBindingRevision | 观测时培养关联与历史修订契约.md | CTRL-INTERNAL | 完整修订原子发布；可信调用/核准证据 |
| BIND-I02 | resolveAt | 观测时培养关联与历史修订契约.md | CTRL-INTERNAL | 按发生时刻和指定修订解析；UNKNOWN不当空闲 |
| BIND-I03 | listRevisions | 观测时培养关联与历史修订契约.md | CTRL-INTERNAL | 设备通道连续游标，不用全库最大ID |
| RUN-B01 | applyCultureInputChange | 模式与初始重量开发契约.md | CTRL-INTERNAL | 与M03生效同本地事务；candidateId幂等；使未开始计算失效 |

## 4. 模块内调用约束

B06/B07：删除预览先按当前会话的删除功能权限及 Q21 三类身份核验，再确认空批次与下游引用，签发十分钟令牌；响应顶层管理版本取签发令牌的同一读取值。确认删除先解析双头 WriteMeta、路径 ID 与目标版本，校验令牌结构、签名、目标及操作者绑定；随后进入 M03-016 守卫，按既有“回执冲突/重放→SYSTEM 版本”顺序执行。仅新请求回调按 SYSTEM→批次→项目顺序锁内重读 Q21 身份，复核功能权限、令牌有效期/管理及对象版本、当前未删除培养与下游引用，再执行对象版本 CAS。删除后必须读回真实墓碑作为审计后像，任何审计、CAS 或回执失败均回滚。成功重放直接返回首次墓碑版本和管理版本，不因对象已删除或预览过期重做业务；删除不级联培养，不清除历史。

- HTTP字段必须先映射为 M03 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 管理写时序不得重排公共守卫链：幂等回执冲突/重放判定 → SYSTEM全局管理版本判定 → 新请求业务回调。删除预览快照令牌的结构、签名与绑定校验在守卫链之前完成（失败即400/403，不进入事务）；令牌有效期与当前删除事实复核放在新请求回调内，全局版本与范围同时漂移时先返回MANAGEMENT_CONFLICT。成功回执的同键同载荷重放不得因令牌此后过期或对象已删除而失败。口径见[详细设计](详细设计.md)7.4与[开发任务/65号](../../开发任务/03-接线与阻塞记录/65-M03项目删除M03-006-007批次交付-20261004.md)§1第5—6项。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

本文件自动登记 30 个目录内HTTP入口、5 个内部定位项、8 个尾部补登记入口。数量校验只防漏项；逐接口仍须以来源契约完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。

## 2026-10-25 补液预核准准备与同事务生效

本节新增3个预核准准备HTTP入口，并扩展原补液候选submit输入；早期自动登记数量不包含本次增补。Controller只判权限、解析WriteMeta／DTO并交原应用服务，不读写Mapper或生成核准原件。完整DTO、Result和字段位置以[培养参数快照与审批生效收尾契约](培养参数快照与审批生效收尾契约.md)及现行字段字典为准。

| 入口及调用者 | 实际调用顺序与事务要求 |
| --- | --- |
| POST `.../plans/feeding/candidates/prepare` → `ResCultureController.prepareFeedingCandidate` → `CultureFeedingCandidateApplicationService.prepare` | 双管理头／edit → 原管理幂等与SYSTEM版本 → 对象及实验室范围 → lab／M06政策根／culture／slot锁 → SC019 INIT或SC048 MODIFY当前明确DIRECT政策 → 模板三字段或手工`plan`互斥，模板经M04精确导出，手工方案由服务端校验并经M04冻结，均复核固定包 → 固化候选snapshot、原输入及拟生效代次 → slot CAS至PREPARED → 原审计及回执。全过程不改effective指针／原任务、不创建新任务或M06单。 |
| GET `.../candidates/{candidateId}/approval-material` → `feedingApprovalMaterial` → `approvalMaterial` | edit及原申请人／对象／实验室范围 → 读原snapshot与preparation_input → 复核原requestKey／requestHash、候选摘要、M04冻结来源及槽位 → 返回PreparationResult和顶层managementRevision；只读，不默认核准D0、算法或执行准备。 |
| POST `.../candidates/{candidateId}/discard-preparation` → `discardFeedingPreparation` → `discardPreparation` | 双管理头／edit → 原幂等及SYSTEM版本 → 范围 → lab／政策根／culture／slot锁 → 原候选／摘要／版本、PREPARED且无审批单 → CAS DISCARDED → 原审计及回执；不撤销已生效方案或任务。 |
| 原POST `.../candidates` → `submitFeedingCandidate` → `submit` | 共同输入及互斥的模板三字段或手工`plan`；DIRECT另须成组提供prepared三字段并引用原准备，原输入／冻结来源仍一致且expectedSlotVersion为准备后版本 → 新请求的双头、幂等、范围及原锁序 → 重新核当前SC019／SC048政策及准备原件 → 原M06明确DIRECT决定 → 原P02／M04校验／M07屏障与独立生成批准 → 旧任务处理／新任务生成／槽位生效CAS与application同事务提交。任一失败整体回滚，不先返回APPLIED再补批准。 |

prepare的原UUID只作为preparationRequestId关联，正式submit使用自己的原UUID及最新同模块managementRevision；准备、提交及撤销结果未知分别保留该次原请求／载荷重放，不换键重做。材料历史阶段不恢复原候选权限，不将PREPARED当PENDING／M06待审或M07任务业务状态。旧候选preparation_input保持NULL，不回填或推造准备。

原APPROVAL仍经真实M06送审／决定投递，DIRECT／DIRECT_REASON只新增前置准备，不改变其最终同事务生效。生成批准的受控发布与任务执行准备的受控发布均在各自部署通道完成，不借这些HTTP入口写任意批准JSON；新task产生后仍必须有自身执行准备和原执行门禁，不能因方案生效直接开泵。实际验证按开发计划分层登记，不以类／路由或表字段存在代替调用链通过。

### 2026-10-25 准备与正式提交的请求身份边界

`prepare`与正式`submit`必须使用不同的`X-Request-Id` UUID；管理回执按可信`actorUserId + requestId`唯一定位，operationCode／载荷是冲突校验内容，不能靠切换操作码复用UUID。撤销准备同样是独立管理写；各操作结果未知时仅重放该操作原UUID和原载荷。正式提交body的`preparationRequestId`仍为原准备UUID，不改为本次提交UUID。

正式生效只在当前`M03-FEEDING-CANDIDATE`管理守卫及活动事务内，由`M03PreparedFeedingCommitScope`精确桥接已持久校验的原准备快照：同actor、培养／节点、candidateId／candidateHash／packageHash及原准备UUID均匹配，原输入、槽位和来源再次核验。M06免审Evidence及`decisionKey=M06:DIRECT:<candidateId>:<原准备UUID>`保留原准备身份；Evidence的managementRevision取当前正式提交守卫锁定版本。桥接只在当前同步回调有效并随退出清理，不把PREPARE变为生效权限，不放宽M07独立批准、执行准备、停止和释放条件。详细规则见M03《培养参数快照与审批生效收尾契约》及M06《接口与审批生效契约》同日增补；本节登记协议，不宣称运行验证通过。

## 2026-11-07 V5.1日期与生命周期调用增补

CU-R01/CU-R02—04仍沿[培养运行变更契约](培养运行变更页面与接口契约.md)；D0修改原因/三项联动及适用审批，提交和应用均经M07核当前培养待审/执行中补液，日期/依赖任务影响/审计同事务。Q-3-02替代旧82/84原任务重排：方案来源未执行任务取消后新生成；人工日历任务保留，已执行具体计划不补做，取消/新增审批沿原规则。
INT-M03-R01原`CultureRuntimeReceiptPort`具名增加`applySelectedWorkflowCompletion`同库消费，完整签名、可信来源、返回及失败见[运行事件契约](运行事件资源释放与延期收尾契约.md)末节；无新HTTP路由。FIRST只操作留痕，不自动转培养RUNNING；开始/结束完成仍保留其本身事实和时刻。
M03-P04原`ParameterPackagePort.readEffectivePackage`的M07-022/023扩大到其对应Config/灌注固定槽位，仅由可信Bean按真实节点固定用途；不接受客户端templateKind授权，不借FEEDING用途。精确登记见[参数快照契约](培养参数快照与审批生效收尾契约.md)末节；源码尚未改。
培养管理批量仅DRAFT（原生草稿补充），不因为未开始仍能单条编辑而允许其批量；开始过的安全编辑屏障保持，不把RUNNING触发点更正理解成开放已操作培养的基础直写。

## M03-048—050 历史只读目标时序（2026-11-07）

目标Controller沿现有M03查询分层：校验筛选/分页/原功能权限→M03应用查询取当前lab/对象/SHARE交集→M03 Mapper先范围过滤再count/分页→经M02标签、M07余额/历史记录、M05取测结果及本模块有效参数包窄读Port组装。直接ID入口重复验权，来源自验实际记录权限；不跨模块Mapper、不发送设备动作、不初始化方案或影响revision。
048先M03自有范围/筛选/count/分页，再对有权页经M07/M05历史用途读取净重及指标；049重新判权后只读基本/工艺/本培养有效方案；050按section仅读所属分页及total，分区故障明确不可用，主身份/授权失败整口拒绝。详见[历史查询唯一契约第8节](培养历史双入口与只读详情契约.md#8-历史用途最小物理交接设计收口尚未编码)：M07三类记录分别走具名只读方法，M05取测以完整发送事实为基集；不调用对方Controller/Mapper，不建统一历史存储。目标共享签名已登记PKG历史小节，P04 M03-049只读用途与参数契约共同落实；目标文档登记不代表源码或验收已实现。

## M03-051—054 最终正文目标时序（未编码）

GET先原培养读范围→自有有效/候选槽位及原APPLIED应用→原M04固定包核验/真实型号显示；顶层同M03 revision，不锁SYSTEM/改数据，本节点快照只用于展示。PUT Controller仅原鉴权/参数/双头→同M03源App原Guard→SYSTEM/lab/culture后当前节点完成/版本/型号核验→最终content经原M04.freezeCulturePlan→原P01共同候选固化/判策/提交；DIRECT/APPROVAL分别按原契约，不以待审提交当已生效。

普通M06 APPLY在原参数P02事务重核完整原件、当前资格/版本/设备/型号、本节点当前完成事实、PERFUSION真实Config基线；明确业务漂移原CONFLICT，依赖故障回滚，不经设备I/O。所有实际状态/审计同事务，M07完成当前读与GET只读区分沿原专题。目标字段、命令和来源矩阵仅引用原参数合同/PKG，当前HTTP与消费者尚未完整接线、测试由work1后续按实际快照执行。
