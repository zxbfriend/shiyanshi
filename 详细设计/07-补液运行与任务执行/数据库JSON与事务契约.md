# M07 数据库JSON与事务契约

## 2026-11-03 小试 W03/W07 无设备占位记录

新建控制器逻辑通道 W03/W07 的 `selection_snapshot` 保留培养、控制器、通道及必要来源身份，不写 `executionMode=SIMULATION`；预填充步骤 `form_snapshot.primeState` 保存用户输入的目标量、泵速及操作状态，详情以 `benchContext.primeState.pumps` 投影。`actualGrams` 为 null，保存的是业务操作记录，不是设备实测、消耗或设备执行回执。

W03 业务完成、启停和取消分别走 `M07-025-W03-FINISH`、`M07-026-BENCH-PRIME`、`M07-027-W03-CANCEL` 守卫；W07 逻辑通道启停复用 `M07-026-BENCH-PRIME`，步骤完成和取消仍走 W07 原守卫。启停 `APPLIED` 表示本地业务记录已应用；W03 业务连接完成为 `COMPLETED/APPLIED`，取消为 `CANCELLED/NONE`。权限、原请求幂等、身份、版本、并发及原事务边界仍须保持。

历史模拟实例继续按原 `simulationState` 和原守卫读取、回放，不改写历史。此条覆盖后文与新建小试逻辑通道模式和守卫码冲突的旧描述，不改变中试或旧实体液瓶路径。本次未执行 SQL，真实数据库、HTTP、浏览器及设备联调以实际验证为准。
> 2026-11-06／07 中试最新确认：W01/W02 新流程使用正式业务链，设备结果未核实时如实标记；W02 不输入预填充净重或跳过原因，也不要求人工输入实体袋编号。下文仅 SIMULATION、`primeGrams`、`skipReason`、`physicalItemKey` 等中试旧阶段字段要求不得当作新业务前置。公共字段及其他流程约束不因中试规则自动放宽；实际 JSON、数据库约束及旧数据处理须经相应设计和数据库负责人核对，不表示已执行数据库变更。业务规则见[工作流设计](工作流与页面操作设计.md)。

### 2026-10-21：异常安全交接详情只读投影

M07-002的 `safetyHandoff` 是现有run_event原件的即时只读视图，字段见[任务页面与接口契约](任务页面与接口契约.md#2-公共dto)，不写JSON列、不增加表/账或业务状态。授权任务详情定位原current_execution_id后，仅查询同task/execution/lab/culture的H06释放、原SETTLED、外部交接outbox/ACK及其原登记证据；禁止以当前设备guard的新owner替代原释放事实，也不返回其身份。原件完整规范hash、源事件键、原执行/最终段/规格和两个回执槽均须核验，缺失或冲突保留UNKNOWN；外部失败不回写任务ERROR为已处理。本地释放原件与外部请求/ACK仍分别沿原事务提交和事务外重试。设备锁事实无有权来源时只报告UNKNOWN，不能从FREE、无记录或健康恢复推断无锁/可启动。

当前查询和严格释放codec只读取原START登记请求/双ACK及同执行的SETTLED、H06、释放outbox/ACK六类原件；不查询资源guard，不锁定或修改新owner。PUBLISHED不能代替完整持久ACK；ACK须绑定原出站eventId/hash、完整releaseRequestHash和两个有效回执槽。重复候选、缺原件、异身份或不支持的续段释放来源均保留UNKNOWN。此能力已接实际M07-002调用链并完成隔离SQL、回环HTTP和浏览器分层验证；M02故障锁/现场锁的有权读取生产者及续段释放读投影兼容仍是软件缺口，不能按无记录或已有监控续段能力自动补齐。

2026-10-24 W01与中试结束培养默认连接增补：新W01的`selection_snapshot`在既有schema1上冻结布尔值`deviceConnectionAssumed=true`和`businessConnectionOnComplete=true`，新结束实例冻结前者；两者均由服务端产生，页面不能指定。只在W01最终完成/确认跳过的原管理守卫事务内建立/推进`run_culture_runtime`连接业务关联。设备回执仍SIMULATION，物理writer/readiness仍UNKNOWN，readiness证据的UNVERIFIED依赖记录`DEVICE_CONNECTION_ASSUMED_FOR_BUSINESS_TEST`。原实例/步骤/事件、runtime连接版本任一写失败整体回滚；取消不建runtime，不覆盖其他连接，不重置累计量或确认指针。只读连接方案投影对W01 schema1输出既有WorkflowDefinition的槽位字段，原存储快照不改。详见[最新业务规则](工作流与页面操作设计.md#w01与中试结束培养的默认设备连接业务联动2026-10-24最新确认)。其他流程JSON与SQL语义不变。

## 中试结束培养异常审批与自动应用（2026-10-24）

正常结束的模式步骤在创建时从M03唯一生效CONFIG冻结每个内置PUMPn的functionName、configWorkflowNodeId、configSnapshotId及configParameterGeneration；只匹配同反应器身份，不按外置设备ID或用途码猜泵号。补料泵保留原FEEDING料液/液袋展示，Nothing不作为补料功能名，实际占位冲突拒绝。完整固定包不输出给前端，详情不随全局模板修改而刷新旧显示快照；无合法来源保持null及displayIssues。不增加表列或前端选择交互。

仅`end_culture_pilot_abnormal`使用末步`form_snapshot.abnormalEnd`：`candidate`保存固定CULTURE引用及完整审阅副本，`policy`保存原审批政策证据，另存`reason/approvalId/approvalState/sourceRequestId/submittedBy/submittedAt`。APPROVAL提交另冻结`assumedDeviceState`，明确设备SIMULATION来源；候选版本不随后续步骤版本推进。DIRECT/DIRECT_REASON由原最终管理守卫直接保存CANCELLED，approvalId为null、approvalState为NOT_REQUIRED。

M06最终决定完整保存于`decision`，应用证据保存于`receipt`。APPLY先固化APPROVED/PENDING，仍保留运行培养及占用；DISCARD只取消本次结束尝试，保存DISCARDED回执，培养不变。API12只查原回执；后台固定用途`M07_PILOT_END_CULTURE_APPLY`处理已持久决定，SYSTEM→M03培养/原占用→M07实例/步骤。资源未停保留PENDING；安全时同事务保存培养CANCELLED、原占用释放、观测绑定关闭、步骤COMPLETED、实例COMPLETED/APPLIED、服务器实际完成时间、APPLIED回执及SYSTEM事件。明确版本/状态冲突回滚后另事务保存步骤UNKNOWN、实例NEEDS_RECONCILIATION/CONFLICT及冲突回执，不能把培养误改已取消。无用户管理回执、不递增SYSTEM管理版本、不伪造用户会话或设备命令。

2026-10-24晚用户确认两个时间分开：仅异常结束最终APPLIED时，实例`ended_at`取冻结的最终审批决定`decision.decidedAt`，用于完成页操作结束时间；末步`ended_at`、证据`completedAt`、占用释放及回执`effectiveAt`取安全停止后最终保存的服务器时间；培养实际结束通常同此，Q-3-06提前取消跨期例外取申请内记录时间，审批决定另记。审批通过但资源未停止时仍保持原PENDING，不提前填实例结束时间。DISCARD/CONFLICT仍记录实际处理时间，不套用审批通过展示规则。

本功能不增表列，不执行SQL，不改变W02及小试JSON。源码、契约测试与实际部署分开报告；详细字段与证据见[中试结束培养接口契约](中试结束培养接口契约.md)。
## W08人工整批清理（2026-10-24）

复用run_workflow_instance、run_workflow_step、run_event及M02液瓶现有零量CAS，不增加表列、不执行SQL。原selection_snapshot的批次清单、瓶及配置来源不可变；最终step_2表单记录原选择值、实际确认前值、人工确认后0和同源closure（确认/取消、确认瓶/移除瓶、可信用户、服务端起止时间）。移除成员与取消成员不写M02零量；确认成员终态COMPLETED/APPLIED，其他成员CANCELLED/NONE。完整批次phase由共同closure决定，不能将合法的移除混合终态判成未完成。

父SYSTEM管理守卫负责原键回执、权限/版本、稳定锁全体实例与步骤、M02精确配置及资源重验，全量预检后应用。M02人工零量Port要求已有事务并只执行精确配置/映射版本CAS；不创建物料session，不伪造MaterialObservation执行/归档观测，不产生PLC命令。前后量、步骤CAS、实例终态、本地事件、全体实例UPDATE审计及幂等回执属于同一本地事务，失败传播并整体回滚；原键恢复不重复清零。HTTP载荷及细节见[任务4契约](任务页面与接口契约.md#w08整批完成与取消任务4)。数据库回滚与并发效果须真实联调验证，Mock行为测试不替代。

## W03 模拟终结（2026-10-23 P07）

复用现有实例state/application_state/ended_at与步骤form_snapshot/completion_evidence，不增表列、不执行SQL。完成/跳过为COMPLETED/NONE，整批取消为CANCELLED/NONE；不能调用会产生真实连接待应用语义的通用完成Mapper。活动成员当前关闭步骤保存同源SIMULATION closure，含可信批次/原manifest/关闭requestId/USER操作者/结束时间/是否跳过与原因；保留已确认CONNECT及模拟历史。取消CONNECT阶段时未来PRIME只记录取消，不制造开始时间或预填充事实；已移除成员保持原记录。

守卫`M07-025-W03-SIMULATION-FINISH`或`M07-027-W03-SIMULATION-CANCEL`采用原请求完整载荷；一次SYSTEM事务先全量核权限，再按稳定顺序锁完整原manifest实例和步骤，校版本/模式/阶段/历史及全停/零真实物理记录，全量prepare后才apply。主审计为全部本次活动RUN_WORKFLOW_INSTANCE UPDATE，绑定OUTCOME_AFFECTED_IDS；步骤及LOCAL事件同事务保存。CAS、事件、审计或回执失败须回滚，不以Mock证明实库回滚。原请求重放返回原结果并复核当前权限，新键不能改写终态。

读端区分W03_MEMBER_REMOVED和整页模拟取消，不能仅凭CANCELLED判断移除；闭合批跨成员元数据必须一致，混合终态或损坏closure拒绝。终态模拟步骤支持只读历史投影且动作为空。通信引用不删除，现有M07通信事实将COMPLETED/CANCELLED+NONE判closed。没有真实连接/计划/物料副作用；具体HTTP及恢复见[页面P07](任务页面与接口契约.md#2026-10-23-w03-模拟完成跳过与取消p07)。

## W03 模拟启停（2026-10-23 P06）

按最新用户授权，复用selection_snapshot固定新批executionMode，PRIME_FILL.form_snapshot.simulationState保存模拟逐泵状态、请求参数及服务端操作时刻；不增表列，不执行SQL。模拟操作不可写CONNECT原装量确认快照、M02配置、真实命令或物料消耗。

新建模拟批沿用P04的通信使用引用登记（lab_communication_usage）及LOCAL启动事件；这不等于修改实验室默认连接或产生真实设备动作。模拟启停自身只更新以下M07步骤/事件/审计。

一次`M07-026-W03-SIMULATION`守卫：查询原回执；新apply先当前批成员权限/合法状态和必要配置核验，再锁读批实例及目标步骤，校模式/版本/精确泵身份并执行模拟状态变更；CAS PRIME_FILL并追加事件、STEP UPDATE审计。原键回放不重复状态变更，返回前重验当前权限。审计绑定OUTCOME_ID=实际PRIME_FILL步骤ID，不借真实run_command审计。

SIMULATION保留明确标记且actualGrams=null，不能把目标量、运行时长或Speed码转换为实际消耗；物理瓶身份后补不影响隔离模拟，但不能据模拟创建真实material session。开关只控制新模拟批和新的START；原已运行模拟泵的STOP按持久模式及原参数处理。具体API与重入字段见[页面P06](任务页面与接口契约.md#2026-10-23-w03-无设备模拟预填充p06)。

## W03 装量确认（2026-10-23 P05）

复用现有`run_workflow_step.form_snapshot`，不新增表列、不执行SQL。CONNECT rows以冻结resourceKey/bottleId关联：before保留来源观测快照，after.loadedGrams为人工确认量；另记录可信确认人/时间。槽位bottleId不等于实体瓶身份，不得用槽位、设备型号或虚构sessionId创建物料会话。

一次`M07-025-W03-CONNECT`守卫，全体当前M03权限、M02配置事实及稳定顺序M07实例/步骤锁读，全量prepare通过后才CAS所有活动CONNECT步骤并追加事件和审计。移除成员保持历史不变，workflow OPEN/NONE不为虚构批版本而改写。审计`OUTCOME_AFFECTED_IDS`只绑定实际变更的CONNECT步骤ID，类型RUN_WORKFLOW_STEP/UPDATE；本地异常回滚。真实数据库并发及回滚须另行验证，不以Mock证明。

此提交不写M02配置、material session、物料账、设备命令、FIRST事实或正式连接。具体载荷、阶段与原键恢复见[页面接口P05](任务页面与接口契约.md#2026-10-23-w03-整批装量确认p05)。真实实体瓶身份与物料会话后补前，新批次泵操作保持拒绝；不改变无manifest历史流程安全停止路径。

## W03 批量登记与成员移除（2026-10-23 P04）

不增表/列，不执行SQL。复用`run_workflow_instance.selection_snapshot`登记`batchRootWorkflowId/batchWorkflowIds/batchRequestId`，原有培养/占用/设备/固定通道事实保持；原始有序manifest不可变，不按时间/用户猜测拼批。无manifest历史不自动迁移。冻结`benchContext`按[页面字段契约](任务页面与接口契约.md#2026-10-23-w03-当前页面批量启动与受控移除p04)白名单投影，不出原始方案/会话凭据。根被移除仍为稳定锚点，活动集合由服务端当前状态和移除事件判断，不信客户端缩减的清单。

启动一次`M07-023-W03-BATCH`守卫：按稳定ID顺序锁培养、全量准入后预分配实例身份，再统一创建、START完成/CONNECT准备、事件/通信关联、全量实例INSERT审计及一份父回执。`WORKFLOW_STARTED`审计事件键含可信workflowId分量，避免父requestId多成员碰唯一键；不新增FIRST或伪造物理连接。原请求回放不再次准入/创建，返回前核当前对象权限。

移除一次`M07-027-W03-MEMBER-REMOVAL`守卫：先按当前M03操作范围锁读全体，再稳定顺序锁全体实例/步骤，校完整预期版本及CONNECT阶段，证明不存在任何命令（含已完成）、执行或物理资源历史；目标之外至少一名活动成员。仅目标实例CAS为CANCELLED/NONE，追加移除事件及实例UPDATE审计；不物理删除、不释放M03占用。任何本地失败整笔回滚。带manifest的单对象步骤/取消不能旁路整页，物理执行和后续整批步骤不在P04范围。

共享审计码：`M07-023-W03-BATCH`使用`OUTCOME_AFFECTED_IDS`审计全部真实RUN_WORKFLOW_INSTANCE INSERT；`M07-027-W03-MEMBER-REMOVAL`使用`OUTCOME_ID`审计目标实例UPDATE。不借W02模拟码，不改变原单对象政策。

## W06 冻结展示与满瓶确认（2026-10-23）

W06为实验室级两步工作流，无培养补量、无预填充命令。启动原请求指纹仅包含稳定的`subflowCode/labId/bottleIds`，槽位观测和定义只在新写守卫回调内读取、重验并冻结；同键同载荷回放不因随后满瓶更新或定义变化另建实例，异载荷仍冲突，当前实验室操作权仍须重验。

`selection_snapshot`为真实`SamplingLiquidSlot`数组。换瓶步骤`form_snapshot.rows[]`保持`resourceKey/before/after`结构：

- `before`固定原`plcValueGrams`（可空、零、有符号小数）、`fullCapacityGrams`、`configurationRevision`，以及可空的`controllerNo/unitCode/channelCode/rowNo/slotNo/bottleName/bottleCapacityMl/iconUrl/readingQuality/observedAt/observedRevision/standardSource`。
- `before.consumable`保留原槽位身份语义（`id`为液瓶槽位ID，不冒充耗材型号ID），含`kind/physicalItemKey/capacityValue/capacityUnit=g/revision`，增加真实`description/iconUrl/bottleCapacityMl`。容积mL不换算为重量g。
- 完成只保留最终确认子集的行，原`before`深拷贝保留不被当前主数据覆盖，`after.loadedGrams`只取服务端冻结满瓶克重；`materialSessionIds`关联真实会话，`applicationState=APPLIED`。
- `removedResourceKeys`记录原选但未最终应用的资源；它们不新建会话、不更新M02当前量。实例同时CAS为`COMPLETED/APPLIED`。

旧快照缺字段保持缺失，不回查当前控制器 / 图片补造历史。typed `ResourceSnapshot/ConsumableRef`与JSON同步增加可空展示字段，不改变其他流程原字段含义。`plcValueGrams`是兼容名称，不据此宣称实时PLC采集已接通；来源质量、时刻和人工换瓶确认必须区别。

## W02 整页批次、暂存与最终应用（2026-10-21，V4.2复核）

本轮用户确认整页全部泵统一推进/最终保存/取消，取代此前逐泵独立推进。本节为**IMPLEMENTED + CONTRACT_TESTED（本轮48类645例；SQL/真实HTTP/前端/设备未验证）**；不增表/列，不执行SQL，不把前轮逐泵测试计作本轮聚合通过。真实HTTP/浏览器/数据库/设备NOT_VERIFIED；仅replace_feed_liquid_pilot/SIMULATION，其他flow的物理袋、materialSession及计量规则不变。

定义快照schema1、repeatable=true、M04 SourceRef/hash/version及labType=3，固定START/REPLACE_BAG/PRIME_FILL含真实定义步骤ID/顺序/名称/说明/图示。selection_snapshot保留culture SourceRef/版本、reactor DeviceRef、occupancyId/state/version、真实startCompletedWorkflowId/At、完整当前feedingPlan及cultureCode/cultureMode/plannedStartDate/feedingConfiguration；W02另含executionMode=SIMULATION、connectionWorkflowId/connectionObjectVersion、replacementPump、bagBefore及可空sourceReplacementWorkflowId/sourceReplacementVersion。外置关联仅按P04 EXTERNAL_PUMP的pumpNo/pumpId，糖浓度取同pumpNo的medium.concentrationGl，不按用途/数组序号猜。

启动在一次M07-023-W02-BATCH SYSTEM守卫中完成全量预检，预分配全部workflowId，首ID为batchId。按2026-10-29用户确认，新批次仅选择一台反应器，可选择其全部合法泵，不再固定10泵上限；此前跨反应器历史批次仍按冻结清单恢复。每个子实例selection固定相同batchRootWorkflowId=batchId及非空、有序、唯一的batchWorkflowIds，首项为root；原HTTP父键为batchRequestId。实例request_id沿稳定派生UUID（父键＋资源键），selectionRequestId与该行相同，actor_snapshot.requestId保持父键，不保存会话令牌，不改HTTP元数据或逐泵另启公共guard。manifest是服务端可信成员关系，不能仅凭相同时间/actor/request猜测拼批；无manifest旧历史不回填为新批次。全员清单在每个成员重复保存，较大批次的数据库容量与性能尚未验收。

批入口先核当前HTTP身份与全部成员范围，重读root/manifest及实际完整成员集合；同lab、创建来源、模式、root和有序清单一致且无额外/缺失成员。SYSTEM锁后按稳定ID顺序锁全部成员及其固定三步，校验全员expectedWorkflowVersion/expectedStepVersion，再由core.prepareBatchStepLocked/prepareBatchCancelLocked进行全量无业务写校验，全部成功才调用prepared.apply。CAS、实例/步骤、LOCAL事件、公共全量审计和父回执同事务；任一本地失败整批回滚，不能用事务包住“校验一条写一条”替代prepare全量校验。单泵operations保持独立，带manifest实例的单对象steps/cancel拒绝绕过批入口。

批steps用M07-025-W02-BATCH、批取消用M07-027-W02-BATCH，保留旧单对象政策；审计before/after覆盖所有实际步骤或实例ID，outcome.affectedIds完整。父完整载荷指纹保护集合、顺序、版本及参数；同键同原载荷恢复一次原动作，异载荷冲突，重放后核全部当前权限并返回受控当前批详情。affectedIds可由公共writer按数值归一化，成员回显必须按持久manifest匹配，不拿数组位置猜resource。管理版本与各成员对象版本分别校验，不创造缺来源的batchVersion。

form_snapshot仍为schemaVersion/workflowKind/stepCode/rows。REPLACE_BAG SAVE仅型号配置及装载草稿；整页COMPLETE为所有成员生成各自bagAfter、独立服务端loadingRecordId/confirmedAt/confirmedBy，步骤完成证据applicationState=NONE，所有实例OPEN/NONE，事件BAG_CHANGE_STAGED。PRIME_FILL进入复制bagAfter和自身单泵simulationState，之后只改当前步骤，不覆盖前序完成快照。只有最后整页COMPLETE/确认SKIP在全员STOPPED/无未决后一次使所有成员COMPLETED/APPLIED，并发布LOCAL BAG_REPLACED/REPLACEMENT_COMPLETED；不允许单个成员提前应用。

整页无任何预填充或显式SKIP须二次确认及原因；部分成员有PRIME_START时整体COMPLETE，未做成员表单/完成证据写completionBasis=PAGE_PARTIAL_PRIME、pageHasPrime=true、memberHasPrime=false，skipped=false，不制造skipConfirm或该泵启动历史。每成员完成事实仍如实反映自身动作。新的W02模拟START只要求同泵跨实例无RUNNING/未决，不以共用模拟秤禁止不同泵并行；W01原共秤策略和真实计量规则保持。

bagBefore/After沿18字段白名单：loadingRecordId/materialModelId/description/model/iconPath/capacityGrams/tareGrams/residualGrams/loadedGrams/quantityBasisGrams/consumedGrams/remainingGrams/remainingRatio/lowRemaining/quantityBasisSource/executionMode/confirmedAt/confirmedBy。首袋基数capacity、loaded和确认三字段空；新袋基数loadedGrams，loaded正整数且≤capacity。余量=基数−当袋认可消耗，比例除capacity，低于residual告警；模拟无认可消耗为0但不是现场0，不把prime请求量当actualGrams或真实消耗。无实体袋ID、真实materialSession/ledger引用。

任意未最终完成批次取消须cancelConfirm=true、全部实例版本及当前操作权，锁全员并prepare确认全部STOPPED/无未决后一次CANCELLED/NONE。保留步骤2暂存、原表单、事件/审计，但公开replacementApplied=false，暂存after不作为有效当前袋；新开批从START重来，继承最近最终APPLIED袋。currentBag只读state=COMPLETED/application_state=APPLIED/ended_at非空且REPLACE_BAG完整确认来源，排除OPEN/CANCELLED暂存。安全STOP/取消及已暂存后安全收尾不因来源漂移失效，新START仍核当前方案及最新W01。

分组头basicInfo仅白名单显示真实冻结cultureCode/计划日序/反应器编号规格等；重量无核准来源时读数null及issue，不造毛重/皮重。全链不写真实command/execution/material/ledger、M03运行投影或计划，actualGrams=null；真实协议/计量另行核准验收。

## W01显式模拟JSON扩展（2026-10-21）

不增表/列。selection_snapshot增加不可变executionMode=LIVE/SIMULATION，以及真实cultureCode/cultureMode/plannedStartDate、feedingConfiguration显示快照；首次装载量不新增。SIMULATION仅由服务端显式开关在新建时固定，客户端不指定；旧无标记记录沿LIVE语义。

模拟步骤form_snapshot增加服务端simulationState（schemaVersion1、mode=SIMULATION、servicesConnected、配置来源、培养/计算显示配置、pumps[]、history[]）。MODE NEXT从冻结方案及M02配置初始化；PRIME NEXT复制模式完成状态，之后只更新当前步骤，不修改已完成MODE表单。pumps含稳定模拟资源键、真实配置引用、MANUAL/AUTO、STOPPED/RUNNING、unresolved、操作计数及请求量/速度/起止时间；history保存显式simulated回执、上限1000，达到上限拒绝、不截断。actualGrams=null。

完成证据保留标准completedBy/completedAt/skipped/commandIds/materialSessionIds/ledgerIds/applicationState/issues，并增加executionMode/simulated/state/at/actorUserId/requestId；模拟的真实命令/会话/账本引用均为空。PILOT_SIMULATION_*事件只LOCAL保留审计，不以真实运行事件交给计划或培养事实消费者。M07-026-SIMULATION独立登记STEP更新审计，原M07-026的COMMAND插入政策不放宽。

## W01业务启动快照增补（2026-10-20）

W01的definition_snapshot严格使用下文schema1白名单：definition SourceRef来自M04子流程ID及真实定义hash/version，repeatable=false按单次连接规则，steps固定START/MODE_CONFIRM/PRIME_FILL且保留真实说明及可空图示，applicability取M04实际labType。不直接把Java对象任意序列化作为新模式。

W01 selection_snapshot在schema1核心字段上登记本用途扩展：occupancyId/occupancyState/occupancyVersion、startCompletedWorkflowId/startCompletedAt、feedingPlan（M03-P04已核验的生效包、快照、代次、activation与捕获设备），用于后续核对真实准入来源。culture为带实际对象版本的SourceRef，reactor固定INTEGRATED_REACTOR身份；pumps在尚未解析可信泵资源时为null，不以空数组表示完整无泵配置。actor仅持久化公共Actor白名单，禁止sessionKey。启动不创建物料会话、执行或连接完成事实。

## W05人工补料技术补充（2026-10-18）

按[W05逐接口契约](W05手工补料逐接口契约.md)复用workflow/step/ledger/runtime，不增表列。selection_snapshot固定channels（bottleId/resourceKey/liquidType/configurationRevision/reactorId/pumpId/channelCode）及connectionWorkflowId；step_2行before使用既有ResourceSnapshot，after只接resourceKey/feedGrams。MANUAL_FEED账source_kind=WORKFLOW，source_event_key按workflow/step/resourceKey唯一。物料增量为0，无execution/materialSession。账本、runtime CAS、步骤、实例APPLIED、管理回执与审计同提交。内容hash为规范化人工证据JSON的SHA256，保留操作者、请求、来源与服务端时间，不伪造PLC证据。

## 开始培养专项增补（SC-20261017）

开始培养新增START_CULTURE_SMALL/PILOT及schemaVersion=2类型化步骤，旧W01—W08/schema1不重解释；交互状态、组/成员、每培养完成唯一记录、重量来源设计见专题第6～8节。最终完成为同库原子写M03/M09/M07并应用START_COMPLETED；物理动作仍独立三段事务。字段字典/DDL/机器schema尚未实施，不可把本文旧枚举直接当支持新流程。

最新保存规则（2026-10-17）：小试、中试均只在第4步点击“完成”并成功提交后保存业务数据；未完成页面刷新或取消后从第1步重新开始，不恢复表单或中间步骤。操作审计和设备安全收尾保留，必须当天完成的限制不变。

步骤时间记录：四步分别记录服务端开始/结束时间及结束原因；刷新重开新建尝试，旧时间审计保留，未知结束时间不伪造。时间留痕不构成业务表单的中间保存点。

当前专题：[开始培养详细设计](开始培养工作流详细设计.md)；实施拆分：[开始培养开发计划](../../开发任务/小试中试开始培养开发计划-20261017.md)。本次仅文档补充，业务代码、数据库、设备操作均未执行。


> 2026-09-17 OBS模式增补：[业务观测采样与告警交接](业务观测采样与告警交接.md)为sample.raw_readings v2及OBSERVATION_ALARM事件payload v2的固定白名单；旧v1继续双读，不得向v1直接加未知键。执行spec增加sampleIdentityVersion=2的版本化扩展，仅新执行启用，其他字段/事件类型维持本文件原模式。

2026-09-10。补充[314列字典](数据库模型与字段字典.md)，不允许实现以任意JSON替代必需的类型校验。除execution.execution_spec、sample.raw_readings和OBSERVATION_ALARM payload按明确版本契约支持v2，以及下文人工TaskSpec和生成评估的版本化扩展外，其余JSON schemaVersion固定1；未知键拒绝，字符串/数值长度沿接口及来源模式；服务端生成引用和证据。业务事实写后不可改，变更投影与可靠投递字段除外。

## 1. 通用值对象

| 对象 | 固定叶子 |
| --- | --- |
| Actor | kind:USER/SYSTEM、userId:string/null、displayName:string/null、sourceModule:string、purpose:string、managementRevision:string、evaluatedAt:ISO；不含session凭据 |
| SourceRef | ownerModule:string、objectKind:string、objectId:string、objectVersion:string/null、contentHash:64hex/null；未核准来源版本不得填0 |
| Reading | M02完整Reading字段；补充normalization:{mode:NET_DIRECT/GROSS_MINUS_TARE/UNKNOWN,tareGrams:decimal/null,direction:CONSUMED_INCREASES/SUPPLY_DECREASES/UNKNOWN,precisionGrams:decimal/null,profileRevision:string/null}；原值单位不覆盖 |
| Speed | kind:CODE/FIXED/STRATEGY、code:string/null、fixedGramsPerMin:decimal/null、strategyVersionId:string/null、strategySnapshot:M04完整PUMP_SPEED/null、sourceRef:SourceRef |
| MeasurementPolicy | profileId/revision:string、direction、netMode、precisionGrams、freshnessSeconds、stability:{sampleCount:integer,minSeconds:decimal,toleranceGrams:decimal}、stop:{speedTolerance:decimal,speedUnit:string,minSeconds:decimal,sampleCount:integer,postMonitorSeconds:decimal}、calibration:{bufferSeconds:decimal,kMin:decimal,kMax:decimal}/null、capabilityEvidence:SourceRef；未核准字段为null并导致BLOCKED，不填默认通过值 |
| Outcome | state:string、targetId:string、targetVersion:string/null、occurredAt:ISO、evidenceHash:string、issues:[{code,message}] |
| ResourceSnapshot | deviceRef、pumpNo、medium:{id,name,isSugarFeed,concentrationGl,revision}、consumable:{kind,id,physicalItemKey,capacityValue,capacityUnit,tareGrams,minimumValue,minimumUnit,revision}、configurationRevision、capabilityRevision、measurementPolicy；W07换瓶before另含可空plcValueGrams（g，来自冻结M02槽位的换瓶前量，仅展示，不作为实时/GOOD证据）；直接引用M02/M04真实值，未知保留null |

W07 的 before.consumable 另可含 iconUrl，为换瓶启动时从 M02 耗材型号冻结的图片路径；未知 null。实例详情增加 displayContext（reactorSpecText/reactorIconPath/reactorDisplayIssue/currentNetGrams/netWeightSource/netWeightIssue），用于授权后的当前只读展示，不属于冻结 ExecutionSpec、不修改既有 selection_snapshot 或计量事实。规格由 M02 独立展示 Port 提供；净量复用 M07 培养量查询并保留 BENCH_LEDGER 来源及缺失原因，页面标为理论量，不冒充 PLC 实测。展示依赖不可用返回相应 issue，不移除已核准安全操作。

所有hash覆盖规范化UTF-8 JSON：对象键字典序、数组按模式固定业务顺序、十进制规范字符串、明确null与缺键、时间统一UTC毫秒Z；不hash显示格式或任意序列化空格。规范版本随schema保存；请求与源版本不一致返回冲突，不拿最新快照替代。

MeasurementPolicy.stability沿用上表三个既有字段，不新增JSON叶子或版本：`toleranceGrams`为g，`sampleCount`为有效样本条数，`minSeconds`为实际样本时间跨度s。停止确认时极差≤toleranceGrams、数量≥max(stability.sampleCount,stop.sampleCount)、跨度≥max(stability.minSeconds,stop.minSeconds)且来源/质量/覆盖合格才通过；具体值待核准，缺值不默认。旧系统地秤精度阈值、最近5条和至少5秒的含义与证据边界见[设备命令契约§4](设备命令契约.md#4-停止证据与结算)及统一方案F.3.1；不能把旧等待时长当样本跨度，亦不能用精度字段静默填充容差。此次仅明确既有字段语义，无数据库结构变更。

## 2. 每列JSON模式

2026-10-27小试结束培养专用扩展：`end_cell_culture_small` 可复用同一三步定义，正常运行三步、异常运行前两步。该模块快照另存 `sourceDefinition`（完整 M04 定义、原始步骤码及真实 hash/version），上述 `steps` 是实际运行步骤投影，保留原步骤ID、说明、图示并转换业务步骤码。实例仍保存原子流程ID/编码/来源hash，选择快照保存 `finishType`。不改共享定义、不接管未标识分支的历史实例；不扩展其他工作流白名单。详见[小试结束培养接口契约](小试结束培养接口契约.md#工作流定义与分支2026-10-27)。

| 表.字段 | 完整结构/来源 | 可变性 |
| --- | --- | --- |
| runtime.readiness_evidence | {schemaVersion,dependencies:[{code,state:VERIFIED/UNVERIFIED/FAILED,sourceRef,issues}],evaluatedAt} | 投影可更新并写事件 |
| runtime.plan_barrier_evidence | {schemaVersion,sourceEventId,oldPlan:SourceRef,newPlan:SourceRef,expectedCultureVersion,barrierVersion,affectedTaskIds,issues} | 屏障当前进度，历史进event |
| workflow.definition_snapshot | {schemaVersion,definition:SourceRef,nodeId,subflowId,subflowCode,repeatable,steps:[{stepId,stepCode,order,name,description,imageRef}],applicability}；M04导出固定内容 | 不可变 |
| workflow.actor_snapshot | Actor | 不可变 |
| workflow.selection_snapshot | {schemaVersion,culture:SourceRef,reactor:DeviceRef,pumps:[ResourceSnapshot],selectionRequestId,actor:Actor} | 不可变 |
| step.form_snapshot | {schemaVersion,workflowKind:W01…W08,stepCode,rows:[{resourceKey,before:ResourceSnapshot/null,after:{mediumId,materialModelId,physicalItemKey,loadedGrams,primeGrams,speed:Speed}/null}],skipReason:null/string}；各步骤仅允许页面白名单子集，before均服务器读取 | 草稿可改且加version，提交后固定 |
| step.completion_evidence | {schemaVersion,completedBy:Actor,completedAt,skipped:boolean,commandIds[],materialSessionIds[],ledgerIds[],applicationState,issues[]} | 完成事实固定；投影回执另写event |
| material.resource_snapshot | ResourceSnapshot，含本次实际装载来源；与initial_grams明确分离 | 不可变 |
| manual_result.items_snapshot | {schemaVersion,dilution:"1",items:[{itemId,itemCode,detectorItemId,shortName,unit,rawText,numericValue,sourceRevision}],reservation:{reservationId,normalizedSampleNo,sourceModule:"M07",acceptedAt}} | 本期登记后不开放编辑，version=1；2026-11-07新登记itemCode必须来自M02当前Cedex主数据，旧原文缺失不补造 |
| confirmation.source_snapshot | {schemaVersion,source:SourceRef,itemId,analyteKind,shortName,rawText,numericGl,originalUnit,completedAt,quality,status,sampleNo,position,detectorRef:null/DeviceRef,eligibilityPolicy,checkedAt} | 选中即固定，失效不改原值 |
| calculation.input_snapshot | [CalculationInput](计量确认与补液计算契约.md)全部字段；mediumSnapshot为ResourceSnapshot.medium，volumeEvidence为Reading或{kind:"SMP_LEDGER",initialSource:SourceRef,ledgerThroughId,totalFeedGrams,totalWithdrawalGrams,writerMode} | 不可变 |
| calculation.output_snapshot | {schemaVersion,targetGrams,unquantizedTargetGrams,actualGrams,glucoseAfterGl,sugarMassBeforeG,sugarMassAfterG,completionPct,formulaCode,dimensionSteps:[{label,expression,substitutions:{key:decimal},result,unit}],issues[]} | 不可变 |
| task.task_spec | [TaskSpec](任务页面与接口契约.md)，speedSelection固定Speed；resourceSnapshots完整，plan使用SourceRef；含scopeRules:{queueScope:CULTURE,feedingCompletionPolicy:TERMINAL_INCLUDES_CANCEL,dailyGenerationPolicy:ONCE_PER_RULE_DAY,revision} | 仅未开始且合法候选生效可替换，旧版进candidate/event |
| candidate.before_snapshot | {schemaVersion,taskVersion,businessState,admitted,schedulerHeld,taskSpec}或新建null | 不可变 |
| candidate.after_snapshot | {schemaVersion,actionKind,taskSpec,cancelReason:null/string,expectedTargetVersion,approvalSceneCode} | 不可变 |
| candidate.decision_snapshot | M06固定Decision DTO；直批分支为{schemaVersion,kind:"DIRECT_POLICY",policyId,policyRevisionId,entry,resolutionRules,evaluatedAt,actor}，不造M06审批ID | 不可变 |
| candidate.application_receipt | Outcome，必须包括targetVersion、真实生效时刻、candidateHash、decisionVersion；未决为null | 最终结果一旦写入不可改 |
| generation.evaluation_snapshot | {schemaVersion,rule:SourceRef,plan:SourceRef,confirmationIds[],feedingTaskSet:[{taskId,version,state,openSupplementIds[]}],threshold:{value,unit,sourceRef}/null,scopeRules,calculationId,issues[],evaluatedAt} | 当前评估可变，每次语义变化先存event |
| execution.execution_spec | [ExecutionSpec版本契约](ExecutionSpec版本与观测兼容契约.md)的v1/v2全部字段（已包含resourceClaims，禁止重复定义）；策略理论时限及修正速度在event追加，不改原spec | 不可变 |
| execution.stop_evidence | {schemaVersion,profile:MeasurementPolicy,stopCommandIds[],actualStopReading:Reading,stableReadings:Reading[],stoppedAt,postMonitorUntil,verifiedByAdapter,issues[]} | 首次确认固定，后续补充追加event |
| segment.start_readings/end_readings | {schemaVersion,feeding:Reading,reactor:Reading/null,theoreticalReactorGrams:decimal/null,capturedAt} | 起/止各写一次，修订进账不改raw |
| command.parameters | {schemaVersion,deviceRef,operation,targetGrams:null/decimal,speed:null/{requestedValue,unit,code},desiredMode:null/"AUTO",executionRef,capabilityRevision,resourceClaims:[{resourceKey,fence}]}；只允许操作所属参数，含凭据即拒绝 | 不可变 |
| command.result_evidence | {schemaVersion,resultCode,deviceCommandId,acceptedAt:null/ISO,executedAt:null/ISO,readings:Reading[],queryResult,adapterInstanceId,configurationRevision,fence,payloadHash} | 当前核对投影，每次新证据写event |
| guard.release_evidence | {schemaVersion,ownerKind,ownerId,fence,reason:NOT_SENT/STOP_CONFIRMED,commandIds[],stopEvidenceRef:null/SourceRef,verifiedAt,verifiedByAdapter} | 每次释放保存对应fence，历史进event |

跨 M03 的 `RUN-EVT-I01 resolveReleaseProof` 只允许在 M03 管理守卫活动事务内调用。新建 W03 连接的 `selection_snapshot` 必须同时冻结 `occupancyId` 与主设备 `deviceRef`；M07 以该快照、`run_culture_runtime.object_version`、培养下活动资源守卫、未决命令及未结算执行的一次一致视图生成内容寻址的 `proofRef`。任一活动计数非零返回 `released=false` 与受控原因。历史 W03 快照仅缺 `deviceRef` 时，可由同一快照的合法 `benchReactorId` 还原 `BENCH_CONTROLLER:<id>`，但原始冻结 `occupancyId` 必须完整并与请求一致；缺失冻结占用返回 `RESOURCE_FACTS_UNAVAILABLE`，不能把调用方传入的当前占用视为已核验事实。管理守卫标记只证明调用来源，不是占用行锁证明。培养归属、运行版本、连接工作流身份、快照格式、设备身份和活动计数任一缺失或非法均失败关闭，不修改历史 JSON，不按“无数据即空闲”处理。当前未接入运行中培养释放消费链；后续消费方仍须在同事务锁定并核验 M03 当前占用。该证明只供同一管理守卫事务内的 M03 释放动作消费，不是跨事务长期票据。
| sample.raw_readings | {schemaVersion,readings:Reading[],commandId,executionId,segmentId,stage,activeMilliseconds,adapterInstanceId,fence} | 不可变 |
| handling.exception_snapshot | {schemaVersion,events:[SourceRef],targetGrams,rawStopEvidence,originalMeasurement,measurementPolicy} | 不可变 |
| handling.speed_snapshot | Speed，AUTO必填，其余null | 不可变 |
| ledger.measurement_evidence | {schemaVersion,kind:MEASURED/MANUAL/ADJUSTMENT,source:SourceRef,readings:Reading[],confirmedBy:Actor/null,reason:null/string,amountGrams,beforeProjectionVersion,afterProjectionVersion} | 不可变 |
| event.payload | {schemaVersion,eventType,object:SourceRef,actor:Actor,change:{before:null/object,after:null/object},relatedRefs:SourceRef[],result:Outcome/null}；对象具体形状限本表模式，未知事件拒绝消费 | 不可变；publish_*及last_error可变 |

Q01/Q02/Q04均已确认：queueScope固定CULTURE，feedingCompletionPolicy固定TERMINAL_INCLUDES_CANCEL，dailyGenerationPolicy固定ONCE_PER_RULE_DAY；服务端设置并拒绝其他值，不提供实验室自行切换入口。

2026-10-21 生成评估 v2：`generation.evaluation_snapshot` 保留上表 v1 全部叶子，新增 `generationPolicy:{kind:FIXED_FEEDING/FIXED_SUGAR/DAILY_SUGAR_RULE,connectionGeneration:string,connectionWorkflowId:string,runtimeVersion:string,dayOrigin:{reference,hash}/null,residualConfirmation:{reference,hash}/null,clockQualificationReference:string,feedingFacts:[{taskId:string,parentTaskId:string/null,state,handlingAccepted,settlementState,unsettledCommands}]/null}`；补料链任务身份统一保存为十进制字符串；原链未知保存 null，不用空集合冒充完整。来源 v1 不写入新键，服务端验证后生成 v2。政策引用不是审批证明，只记录受控提供方的原依据；发生评估时刻与下一次检查必须显式提供，不补默认时钟误差。动态评估区间的两端均须在同一上海业务日。

`evaluation_hash` 为完整 v2 评估剔除易变 `evaluatedAt` 后的规范 UTF-8 SHA-256；同一来源与判定重试不因当前时间改变而重复写版本。语义改变时先以 `M07_GENERATION_EVALUATED` 本地事件保存原账本身份、版本、摘要及完整原 JSON 字符串，再在同一事务 CAS 更新未占额度记录。已有 `task_id` 不清空、不覆盖、不重置 generationKey；当前实现不创建任务，只保存 BLOCKED/NOT_NEEDED，缺后台创建授权固定原因 `SYSTEM_GENERATION_APPROVAL_UNAVAILABLE`。原因是评估内部状态，不新增 HTTP 主错误码。唯一消费者与表权限见公共实现结构的 `M07_TASK_GENERATION` 登记。

DAY_START使用相同计算容器，任务/目标/浓度字段不适用时null、purpose=DAY_START，formulaCode及dimensionSteps固定日初净量/证据。不得省略未知标记而生成当前时刻的伪午夜读数。GLC/LAC确认的confirmedAt在后续源失效时保留；INVALIDATED可有或没有confirmedAt，不能清除已经发生的确认时刻。

### 2026-11-07 D0实际展开日期叶

新发生项的原`generation.evaluation_snapshot` v2在既有`generationPolicy`内增加必填`dayZero:YYYY-MM-DD`，表示**该次评估实际使用的M03当前持久计划开始日**；不把它记成观察当天或旧批准文件日期。与同一快照的培养/方案/规则/业务日共同固定，用于识别原具体相对日序及D0变更后已执行具体计划的识别，未执行方案任务按Q-3-02取消/新生成。该叶经原内部Evaluation承接，缺真实日期时不得创建声称已完整评估的新发生项。日期来源、当前结束日限制及已建任务防重见[调度§2](任务状态调度与异常恢复.md#2026-11-07-d0修正后的发生项来源与防重)。

既有v1/v2原JSON、generationKey、evaluationHash和批准原件不补写、不重算；新叶只参与新原件的原规范化摘要。旧记录缺叶只能以当时固定、绑定及引用/摘要一致的核准来源还原，缺证据明确拒绝依赖该日序的变更/生成，不用当前D0猜测。无需新增列或schema版本。此处只补持久化契约，不表示当前writer、生成及RULE消费者已经实现或测试通过。

## 3. 原子业务事务

### PLAN_RULE生成目标的同事务保存（2026-10-26）

正式创建规则任务时，原GENERATE计算的精确`targetGrams`同时写入已有`run_task.target_grams`，与原候选、GENERATE快照及生成记录同事务提交。DIRECT和PENDING_REVIEW均保存；后者仍保持`admitted=0`、`scheduler_held=1`，必须分别满足既有任务审批及独立执行准备批准。EXECUTE仍按原确认输入重算并比较锁内任务目标和ExecutionSpec；缺目标、批准缺失或不一致不准开泵。不得在claim中自动补写历史缺值，不扩大额度。AMOUNT/PERCENT维持原执行计算规则，本修复无新增字段、DDL或数据回填。

### M07-016 人工取测账及原请求恢复（2026-10-22）

`CultureWithdrawalService`使用现有表，不增加列。只接受台式`BENCH_CONTROLLER`当前有操作范围的培养；在SYSTEM守卫回调内锁其M07 runtime并校期望版本。一个原子提交包含人工账、运行累计/CAS、LOCAL事件、公共审计、管理revision和幂等回执。人工取测不产生设备命令、物料消耗、M03业务变更或新的理论计算。

- `source_event_key="M07:WITHDRAWAL:"+可信actorUserId+":"+原requestId`；`source_kind=MANUAL`、`source_id=ledger_id`，ID由SnowflakeId生成。`execution_id/material_session_id/adjusts_ledger_id/calculation_id`为空，`culture_delta_grams`为本次正金额的相反数，`material_delta_grams=0`。
- `measurement_evidence`沿§2模式：`schemaVersion=1`、`kind=MANUAL`；`source={ownerModule:M07,objectKind:LEDGER,objectId:ledgerId,objectVersion:"1",contentHash:null}`；`readings=[]`、`confirmedBy`为可信Actor、`reason=null`、`amountGrams`为正十进制字符串、`beforeProjectionVersion/afterProjectionVersion`为原运行版本及其加一。Actor不包含会话密钥。
- `occurred_at/recorded_at`取同一服务端时刻并截断为毫秒；`business_date`取该时刻上海日期。CAS正向增加`total_withdrawal_grams`、设置`last_ledger_id`并递增`object_version`，不覆盖累计量。金额与累计量须落在`DECIMAL(20,6)`范围；0行或审计/事件失败使整个事务失败。
- 该来源`content_hash`为以下完整不可变内容对象的规范化UTF-8 SHA-256：`{ledgerId,cultureId,labId,entryKind,sourceKind,sourceId,sourceEventKey,executionId:null,materialSessionId:null,adjustsLedgerId:null,cultureDeltaGrams,materialDeltaGrams,measurementEvidence,calculationId:null,actorUserId,businessDate,occurredAt,recordedAt}`。ID均为字符串；两项金额去尾随零并用普通十进制字符串；时间为UTC ISO毫秒值；JSON按既有`M07RunEventFactWriter.canonical`规范化。hash不只覆盖计量JSON，也不包含自身。此规则仅适用于新M07-016来源，不批量重算其他来源账本。
- `run_event`使用`event_type=WITHDRAWAL_APPENDED`、`object_kind=LEDGER`、对象ID=新账ID/version=1、同一来源键、`publish_state=LOCAL`。payload沿§2完整事件信封：`change.before=null`、`change.after=measurement_evidence`、`relatedRefs=[]`，result为`APPLIED`且绑定账ID/version/发生时间/账hash；`payload_hash`仍覆盖完整payload。
- 公共幂等回执命中后不再次执行回调；M03当前操作权限仍重验，再精确读原账并核培养/lab/actor/来源键/金额/完整hash/原入账版本。不按当前累计或最新运行版本重建原结果，不把requestId当成对象授权凭据。公共回执到期后的规则沿既有守卫，唯一来源键继续阻止同一来源重复入账。

源码`IMPLEMENTED`；此契约不代表已执行数据库或验证事务回滚，相关运行证据另行登记。

### 2026-10-15 CultureRuntimeFact 来源事实与核验证明

`FIRST_WORKFLOW_STARTED` 使用 M03 运行事实契约的完整 `CultureRuntimeFact` 模式1作为 `run_event.payload`，不套用普通审计的 change 信封。其 `payload_hash` 与正文 `payloadHash` 同值，精确定义为删除正文自身 `payloadHash` 后规范 JSON 的 SHA-256；这是该事件模式的自摘要规则，其他审计事件仍遵守下文完整信封摘要规则。

M07-023 创建真实 W03 实例后分别分配两个事件ID：原 `WORKFLOW_STARTED` 审计事件保留；完整运行事实独立追加，`source_event_key = SHA256("M07\n" + sourceEventId)`，来源对象固定 `WORKFLOW/本次workflowId/1`。事实正文、列身份/版本、发生时刻和 W03 的冻结培养、占用、设备一致；生产时间保持 UTC 毫秒精度。只在该管理守卫事务中追加，追加成功后才调用 M03 R01，同库事务任一失败全部回滚。首次写 `LOCAL`，M03 返回匹配的持久收件回执后仅将投递字段改为 `PUBLISHED`；这只代表收件，不代表培养状态已应用。重放读取原正文，不重分ID、不替换摘要或序列。

`RUN-FACT-Q01` 提供方为 `M07RuntimeFactProofAdapter → M07RuntimeFactAuthority`，消费方为 M03 R03。入口必须是公共资源事务的 `M03_RUNTIME_RECONCILE` 固定能力、实际活动事务且已取得 SYSTEM 锁；普通活动事务、HTTP守卫身份或自报模块不能代替。按 M03 已锁定收件/占用之后锁读 M07 原事件与 W03 实例，验证源列和正文摘要、`WORKFLOW_STARTED` 的无步骤启动语义、实际 W03 启动时刻及当前实例归属/版本。当前只支持 `FIRST_WORKFLOW_STARTED`；旧审计事件、无源事件、缺占用/设备、其他类型以及取消/待对账工作流均失败关闭。`sourceCurrentVersion` 取同一 W03 的 `object_version`，与原事件版本独立。证明规范字段与摘要引用以 M03 2026-10-15 合同为准，不增加表结构，不签发长期授权票据。

### 2026-11-07 所选工作流完整完成事实的当前读

原`RuntimeFactProofPort.hasCompletedSelectedWorkflow(String cultureId,String expectedLabId,List<String> selectedNodeIds)`供M03截止判定及CONFIG/PERFUSION保存/P02读取本节点完成事实；真实培养、实验室及所选节点来自调用方M03原锁内持久事实，不来自Body自报。无需新增Port、DTO或反向回调M03，M07只读自身实例、定义/选择快照及步骤原件，核同培养/lab、真实节点归属、完整完成及非历史SIMULATION事实。

以下锁序与当前读仅适用于保存/P02等写前核验及截止写判定：调用方沿原同库活动事务，先取得`SYSTEM → lab → culture/原occupancy`锁，再进入M07。提供方按`workflow_id`及其步骤稳定顺序执行`SELECT … FOR UPDATE`当前读后核完整实例/步骤；不能只做普通SELECT存在性判断。在MySQL普通RR事务中，早先普通读可能已经固定快照，随后取得SYSTEM锁不会刷新该快照，不能把锁前不可见的真实完成误判为未完成。只锁M07自己实际核验的原记录，不反向取M03锁，不另开`REQUIRES_NEW`、修改隔离配置或增加授权票据。

新plans GET只作已授权持久事实的读取展示，不锁SYSTEM、不改revision，允许原只读事务快照，不在只读事务执行FOR UPDATE，也不承诺后续写资格。原提供方按真实只读/写事务语义选择原普通读/锁定当前读查询，不新增Port参数、客户端布尔或框架；GET来源故障同样不得伪装false，真正写仍按上段锁序重验。

确实没有匹配的完整已选流程事实才返回false，合法其他节点或未完成实例不冒充匹配；声称已完整完成的原件损坏、同一记录的节点/培养/lab身份矛盾、所需步骤证据不完整或读取失败按现行依赖/源冲突拒绝，不降为false，不据此容许改已完成参数或将培养过期。`verifySelectedWorkflowCompletion`的真实完成消费者仍沿原预锁/来源版本及同事务回执，不能用此boolean代替完成应用。当前provider已经有只读核验且无反调，但上述逐实例/步骤**锁定当前读尚未实现/未验**；本段为设计补齐，不宣称目标SQL或事务并发通过。

### 2026-10-11人工创建来源与长期回执

2026-10-11复审残余（事件身份与摘要一致性）：人工创建事件的event_id只由M07应用服务注入的com.futurefab.common.core.utils.uuid.SnowflakeId.nextId分配，不接受HTTP/Port外部传入值，不拿任务ID、requestId或时间戳代替；唯一冲突整组回滚，不覆盖旧事件。恢复读取原event_id，不重新分配。SQL列object_kind/object_id/object_version必须与payload.object的objectKind/objectId/objectVersion同值（JSON的ID/版本按十进制字符串承载）；人工创建初始版本为1，不借恢复时的最新任务版本改写创建事件。

本表payload_hash的“事件完整内容”精确指完整payload JSON信封，而非仅change.after，也不是全数据库行；包括schemaVersion/eventType/object/actor/change/relatedRefs/result所有模式叶子及null，排除独立SQL列event_id/payload_hash和可变publish_*等投递列。写侧与恢复核验侧使用相同规范化规则：对象键递归字典序、数组保留合同业务顺序、数值沿现行十进制规范、字符串用合法JSON转义、无额外格式空白，UTF-8字节SHA256，存原始32字节。不能直接hash数据库JSON返回的格式化文本；先解析并规范化，再重算。列与信封冗余身份/版本、真实归属另做一致性校验，不因为未纳入摘要就允许列被篡改；不一致或重算摘要不符按恢复事实损坏503拒绝。本规则与既有计量事件完整payload规范化后sha256的取证口径一致，实施批仍须用实际转义/排序/列-信封不一致夹具核验，不直接复制未经测试的序列化细节。两份事件字典对“完整内容”的说明以本段为准；不改表结构或对历史其他事件批量重算。

2026-10-11复审补正（创建事件必填列）：下文每培养创建事件的event_id由服务端现行ID来源分配，actor_user_id取真实创建者；object_version取object_id所指首个任务本次创建提交的版本（初始1），不得拿管理revision代替。payload_hash为完整规范化事件payload字节的SHA256原始32字节，写入BINARY(32)，不是businessPayloadHash或intentId，也不使用HMAC。occurred_at取本次创建事实时间，按UTC及DATETIME(3)精度写入，payload.change.after.createdAt表示同一时刻；多培养同一请求使用同一事实时间。publish_state=LOCAL、publish_attempts=0，next_publish_at/published_at/last_error为null。DDL中这些必填列没有可依赖的默认值，插入语句须显式映射；event_id、归属、任务版本或完整payload不可得时整组拒绝，不补零值。实施批以BoundSql/映射及真实写链用例核验全部必填列、摘要和时间一致性；未执行目标库SQL不得称约束已验证。

新人工USER/COPY的task_spec使用schemaVersion=2，保持原TaskSpec叶子并增加creationSource={schemaVersion:1,intentId:64hex,originalRequestId:UUID,actorUserId:正十进制字符串,addOnce:boolean,businessPayloadHash:64hex,rowId:正十进制字符串,sourceTaskId:ID或null}。哈希只覆盖冻结业务载荷（含addOnce、原复制源和固定行顺序），不含恢复参数、当前管理版本、返回值或显示名；采用现行规范化规则及独立命名空间，禁HMAC混代。COPY的sourceTaskId与parent_task_id一致。合法候选修改可替换任务参数，但必须原样保留creationSource；v1历史只读，不补造来源，自动任务维持原模式。

businessPayloadHash比较原提交的合法输入，不以恢复时重新解析的最新方案/设备状态或当前时刻计算；IMMEDIATE首次解析出的计划时刻存入原TaskSpec，重试不重新取now。原载荷请求中没有的服务端派生事实由原结果固定，不要求客户端补交。恢复前仍重验所有目标的当前阅读/操作范围，不能只验证回执操作者而泄露已失权任务。

首次创建按每个培养各写一条run_event：event_type=M07_MANUAL_TASK_CREATED、object_kind=TASK、object_id为该培养本次首个稳定任务ID、culture_id/lab_id为该培养真实归属、source_event_key="M07_CREATE|"+intentId+"|"+cultureId、publish_state=LOCAL（11字符前缀＋64hex意图＋1字符分隔符＋最长19字符正BIGINT培养ID，总长度不超过95字符）。payload仍使用本表事件schema1，change.after的该事件专用对象为{intentId,originalRequestId,actorUserId,cultureId,cultureIds:[整次请求升序且去重ID],businessPayloadHash,addOnce,taskIds:[本培养升序ID],createdAt,originalResult:整次原创建响应}，其他事件不得复用此扩展。多培养只用一个同库事务，SYSTEM→实验室→培养升序及下层完整锁集合；各培养事件、全部task/candidate、管理回执和审计同提交，任一失败整组回滚。单培养也使用含cultureId的同一键格式，不另设兼容分支。领域回执保留期不随管理回执过期，仍有任务或恢复用途不得清理。

恢复从已验证操作者和originalCreationRequestId推导intentId，用提交业务载荷解析的培养集合逐一构造精确source_event_key查询领域回执；只读事务不改事件/不重新审批。2026-10-11第四轮判定优先级：① 全无命中统一404，不证明原请求未提交，也不证明输入集合正确；禁止自动补任务。② 有命中先验证事件schema、操作者/意图绑定及字段合法性，损坏为503 RESOURCE_FACTS_UNAVAILABLE；从命中事件取得原cultureIds，先重验原全集当前对象权限，无权同404。多个命中事件的原全集/hash/原结果互相矛盾属于持久事实损坏，503。③ 权限与事件可信后，提交培养全集与原cultureIds不相等，或提交businessPayloadHash与原摘要不相等，一律409 REQUEST_CONFLICT；不能把删掉/增加培养的输入误报“部分事件丢失”。④ 仅在提交集合/hash与原记录相等后，按原全集精确键补齐读取，任一事件/任务缺失、taskIds/creationSource不对应才503；全部核齐返回原结果。不得部分返回、不扫全表Java过滤、不按客户端taskIds选择记录。

该合同无需新增表/列，但新schema、事件类型、DTO与精确键查询DAO必须随真实创建消费链同批实现和测试；文档定义不证明已有SQL。只读恢复只属于原创建者本人：intentId含真实actorUserId，不接受代填原actor或把原请求ID当授权凭据。原创建者停用/失权时，其他当前有权人员通过既有任务列表/详情与审计查询核对实际结果，不冒充原作者调用恢复，也不把“另行新增一次”作为未知结果的恢复办法。

| 事务 | 需要同一提交的对象 | 禁止 |
| --- | --- | --- |
| 新任务请求 | task预分配、candidate、generation/creation去重、事件 | 开启设备后再插任务 |
| 变更申请 | candidate原快照、task scheduler_held、事件 | 直接覆盖原量/原计划时间再等待审核 |
| 决定应用 | candidate最终回执、task参数/版本/状态、解除hold、事件 | ACK在写入前返回，旧决定重放生成第二任务 |
| 连接完成 | workflow/step完成、runtime连接代次、生成事件 | 逐次点击重复生成 |
| 抢占开始 | 顺序复核、全部guard owner/fence、execution/segment、PREPARED命令、task phase | 只锁泵漏共用秤，或网络等待持SYSTEM锁 |
| 发出物理调用 | command INVOKING持久化后出事务调用；回执新事务写command及事件 | 调用成功但无持久化意图 |
| 60s完成 | confirmation、runtime当前确认指针、审计事件 | 浏览器计时直接更新浓度 |
| 计量结算 | ledger唯一来源、calculation、runtime投影、material投影、execution/task结算状态、事件 | 先累加再尝试插去重记录 |
| 异常处理 | handling、确需的独立更正/手工ledger及计算、原task状态、AUTO子candidate/task、事件；原FEED/SETTLE/释放若已存在须精确复用 | 原task已处理但子任务创建丢失，或已先结算/释放后重复原量/SETTLE/FREE、重占旧设备 |
| 资源释放 | 物理停止/完整观察、唯一安全结算、原命令闭合、guard当前epoch确认、owner清空、新版本和原释放事件；ERROR可保留待处理 | 仅lease超时/业务ERROR就FREE，或强制等待ERROR_HANDLED代替独立安全资格 |

run_event兼审计/发件箱。LOCAL表示仅内部审计，不要求原审计行外部发布；PENDING/RETRY按next_publish_at扫描，按该事件类型约定的接收方ACK后PUBLISHED，不表示M08/M09全部消费。FEEDING_SAFETY_FACT按下述专用模式等待M09持久收件确认；其他原代理ACK语义不变。消费外部M05/M06/M03事件以owner+eventId构成source_event_key，在改变本地投影的同一事务插入，重复同hash返回原结果，异hash留冲突并停止。跨网络交易不使用数据库分布式事务假定一次成功，靠持久化回执和查询补偿。

2026-10-16 M05结果消费实施映射：固定消费者 `M07ResultChangedConsumer` 使用公共资源事务用途 `M07_RESULT_CHANGED_CONSUME`，同一 SYSTEM 锁下通过 M05 `getResultRevision` 重取精确版本，支持完整 schema1/2。入站 `payloadHash` 是 `NormalizedPayloadHasher.canonicalJson(Event.payload)`（完整 ResultSnapshot，包含其 contentHash）的 UTF-8 SHA-256；它不是 contentHash，也不是整个发布信封的摘要。M05 接收桥接器核对原信封身份后映射冻结 DTO；M07 再复算精确快照摘要。浏览器无此写入口，不伪造用户身份。

消费行 `source_event_key=M05:<revision事件ID>`，`event_type=M05_RESULT_CHANGED`、`object_kind=DETECTION_RESULT`（新增本地审计对象种类，现有列无枚举CHECK）、对象ID/version对应M05结果精确身份；`payload_hash`仍是本表完整事件信封的SHA-256，不能直接填入站hash。信封 `change.after` 为 `{sourceModule,eventId,resultId,revision,incomingHash,sourceSchemaVersion,sourceContentHash,confirmationIds,historicalCalculationIds,affectedTaskIds}`，ID数组均为十进制字符串，`result.state=APPLIED`。精确来源和历史计算引用保留，`run_calculation`/`run_ledger`内容不改。冲突另追加 `M05_RESULT_CHANGED_CONFLICT`，键为 `M05_CONFLICT:` 加原事件键、入站hash、结果ID、版本按换行串联的SHA-256，after保留入站身份及originalEventId/originalIncomingHash，`result.state=CONFLICT`；返回未受理而不抛异常回滚冲突行。

只失效同结果 `source_version < incoming revision` 的 COUNTDOWN/CONFIRMED，保留原source_snapshot与confirmed_at；旧INVALIDATED确认仍可关联历史计算。通过计算确认ID、task当前计算及活动候选计算、generation确认集合定位影响；尚无物理开始的任务递增object_version并记录失效原因，活动候选INVALIDATED；仅当前候选指针命中本事务预先锁定的失效候选ID集合时清指针及该候选带来的scheduler_held，其他已有held保持，不新增会阻断正常变更/取消的held。未执行生成记录INVALIDATED但保留task_id与generation_key，不恢复当天生成额度。持久INVALIDATED确认与资源占用前gate持续拒绝旧计算；已准入READY任务仍可按原权限及审批修改或取消，修改参数本身不重建旧计算或恢复源资格。未准入的pending CREATE保持失效历史，当前无原地恢复/取消入口，不宣称全部任务可恢复。已执行计算/任务不回写、不停泵、不撤销账。乱序旧事件不能使更高版本确认回退。

真实 `M07ResourceClaimWorker` 在资源占用前通过 `M07DetectionSourceStartGate` 重验冻结检测来源仍CONFIRMED、M05精确版本仍effective及相应指标可用；无检测来源的任务不增加检测依赖。首次任务START派发链仍未接通，本改动不制造设备命令。跨服务作废与物理发泵的并发屏障、目标MySQL事务/锁及真实broker投递仍须单独联调验收。

数据库CHECK覆盖单行枚举/非负/互斥；跨行授权、只读JSON、hash重算、源版本真实性、引用归属、状态迁移、物理停止证据均由领域服务落实。仅CHECK通过绝不等于满足物理执行条件。

## M07-Q07 运行数据保留与受控归档（2026-09-11已确认）

- 用户在逐项问答中同意“运行数据暂不自动删除、允许受控归档”。保留原始采样、设备命令及回执、任务事件、结算账本和更正记录，不擅自抽样丢弃原始证据，不设置未经确认的删除期限。
- 正在执行、UNKNOWN、未结算及尚未完成事件交付的数据保持在线；活动资源归属、递增fence、当前物料session和有效基线等继续在线支撑安全与计算，不因归档重置身份或计数。
- 已结束历史可受控归档，但仍须可按当前权限查询、追溯、恢复并识别原命令、事件和结算键；不能因归档重复执行、重复累计或把旧请求当作新请求。查询归档失败不等于历史不存在。
- run_event的审计内容与投递状态分别处理；PENDING/RETRY等尚未完成交付的记录保持在线。PUBLISHED表示该事件模式约定的接收方确认，普通代理确认不宣称所有消费者已处理；FEEDING_SAFETY_FACT的专用M09持久收件确认也不表示通知已发送。归档后仍须支持消费者按原事件身份补取和去重。用于安全事实待交接的LOCAL源及其子事件在交接未完成前均保留；其他仅内部审计的LOCAL事件按其业务是否终结判断，不等待不存在的外部ACK。
- 高频采样先按实际培养数、采样频率、运行时长、记录大小及副本/备份测算容量，再分层归档。复制、完整性核对及恢复验证通过后，才切换历史读取位置；不能销毁唯一原件或丢失关联证据。
- 自动删除期限以后另行确认；本次归档授权不包含销毁历史。M01 HTTP回执原24小时规则不变，长期运行领域记录及幂等依据不随之清理。
- 本轮三项业务决定已齐备：Q05固定单执行器部署；Q06历史只读及双人核准接续基线；Q07运行数据暂不自动删除。具体部署、接管、基线存储、归档/恢复、容量及验收仍需技术收尾，其他审阅事项不因此标为关闭。未执行SQL、导入、代码开发、归档或设备操作。


## 2026-09-11审阅收尾衔接

当前技术补充见[审阅收尾执行器与接续契约.md](审阅收尾执行器与接续契约.md)；完整物理结构以[审阅收尾字典](审阅收尾完整字段字典.md)及该字典链接的最新DDL为准。本文保留此前版本设计，冲突处按该补充执行。实施前必须完成领域实现、隔离迁移和对应CLOSE验收，不代表现已运行。


## 2026-10-16 检测来源模式与同任务恢复

新M05 confirmation.source_snapshot schemaVersion=2沿模式1所有固定叶子，增加mappingSource:SourceRef和evidenceQuality。映射SourceRef为M03/PARAMETER_SNAPSHOT/生效snapshotId/parameterGeneration/packageHash；来源结果SourceRef独立指向M05精确结果版本及contentHash。quality=UNKNOWN及position=null只是未知保留，不能当测量GOOD或伪造检测位置。模式1历史双读，不回写。

RECOVER_SOURCE candidate.after_snapshot为{schemaVersion:1,actionKind:"RECOVER_SOURCE",taskSpec,expectedTargetVersion,expectedRuntimeVersion,reason,plannedAt,targetGrams,approvalSceneCode}；before_snapshot保留原任务冻结投影；candidateHash=规范化after_snapshot UTF-8 SHA-256。M06收到完整ChangeSnapshot审阅信封，其candidateHash引用该拥有方摘要而不自摘要。

恢复后的TaskSpec采用schemaVersion=3：沿原TaskSpec1/2固定内容，增加sourceRecovery:{schemaVersion:1,candidateId,calculationId,previousCalculationId}；currentCalculationId和run_task.calculation_id均指向新不可变计算。旧taskSpec进候选与事件，旧run_calculation原样保留。run_generation仍保存原task_id、generation_key及失效历史，恢复不写它、不自动再生成同日规则任务。

2026-10-26 SC033计算规则重算增补：新的TaskSpec使用schemaVersion=4，增加`runtimeCalculationChange:{schemaVersion:1,cultureCandidateId,taskCandidateId,calculationId,previousCalculationId,configVersion}`，非空ID/版本为字符串。只有从未计算、无计算引用的任务首次计算时，`previousCalculationId`为显式null，不伪造旧计算ID；其他重算仍须指向真实原计算。`currentCalculationId`及run_task.calculation_id在真正生效时指向新计算；原sourceRecovery引用留在原候选/TaskSpec历史，不再授权本次替换。拥有方新候选仍为UPDATE，after额外固定runtimeCalculationChange、cultureContext、initiatorUserId、expectedRuntimeVersion、approvalSceneCode及新的taskSpec/targetGrams。其摘要和审批必须绑定整个after，不能按普通UPDATE直接生效；专用交付复核配置、输入、资格和新候选身份，再用SC033任务CAS应用。公开提交、专用审批回投及现有设置弹窗写入口已接线；实际联调状态见[培养运行设置变更契约](培养运行设置变更契约.md)。

SC033任务屏障另在当前task_spec暂存内部字段`runtimeCalculationHold:{schemaVersion:1,cultureCandidateId,heldTaskVersion,originalAdmitted,originTaskVersion}`。ID/版本使用字符串，originalAdmitted为0或1。首次屏障保存原准入值和版本；连续变更时必须核验当前held版本、候选原因、admitted=0和scheduler_held=1后继承原值，不得用临时admitted=0误判新建审批。原已准入的FEEDING/SUGAR走SC001/SC005，原未准入走SC002/SC006，均重新读取当前政策。缺失或不匹配的屏障依据使整个生效事务回滚。新候选待生效的taskSpec移除该字段；固定计算输入及旧候选保留历史依据。该字段由拥有方写入，不属于前端可编辑参数。

M05结果更正命中处于上述屏障内的任务时，照常失效旧候选，但保留scheduler_held=1及CALCULATION_RULE_CHANGED候选前缀，并附记M05_RESULT_CHANGED原因；heldTaskVersion随任务版本同步增加，originalAdmitted和originTaskVersion保持不变。不得把规则重算屏障释放为普通检测来源恢复。其他任务仍沿原检测更正路径处理。

schema4当前来源权威：同任务/培养的APPLIED候选、固定after摘要、生效回执和任务版本必须一致，并核对同任务GENERATE计算的输入摘要、算法及evaluationStamp中的培养变更候选、配置和培养版本；只有全部通过才替代run_generation历史来源。启动、检测更正影响和使用统计共用该验证。再次来源恢复会移除当前runtimeCalculationChange，反向规则变更移除sourceRecovery；两种活动引用同时存在为损坏事实，不可放行。2026-10-26定向7类49例通过，含生产Mapper在隔离H2查询、真实校验器及边界替身测试；H2提供JSON函数与正BIGINT的UNSIGNED类型适配，未修改生产SQL，不能等同目标MySQL或真实设备验收。

schema4 TASK审批增补：before增加approvalPolicy，固定提交时route/policyRevisionId/policyHash；after/hash保持先前定义，不把后来政策重新写入候选。M07_SOURCE_RECOVERY_APPLY固定消费者允许本类型候选，先核验原申请人、场景、政策及候选身份，再按SYSTEM→M03/lab→runtime→task→candidate锁序执行；当前配置和真实输入不符返回CONFLICT，依赖故障保留重试。discardResult只清除精确候选指针并保留held/未准入/空目标，旧目标不恢复。相同投递与决定返回原回执，CULTURE设置提交与回投仍需另行实现。详见《培养运行设置变更契约》。

新计算、新候选、任务CAS、审计与管理回执在HTTP SYSTEM守卫事务同提交。新审批决定由固定M07SourceRecoveryDecisionConsumer经M07_SOURCE_RECOVERY_APPLY后台能力取得SYSTEM，依次锁runtime、task、candidate，再重验当前版本/计划日/确认来源/计量/所有START历史及活动占用；不在数据库事务中调用设备。pending CREATE的当前版本可以大于1，恢复APPLY统一递增当前版本并准入，DISCARD仅关闭新候选而保留来源失效状态。

只有精确APPLIED RECOVER_SOURCE候选、候选摘要、应用回执和当前TaskSpec.sourceRecovery/计算指针一致时，启动gate才以新计算来源取代历史generation确认集合；缺失/篡改事实仍失败关闭。原generation不删除，非恢复任务保持原来源查询。后续M05变化按当前计算/当前活动候选定位未来影响；不能从历史generation重新把已替代来源当当前来源。已开始/账本保持只读追溯。

## FEED-20261020：原因承载与首次开始事实

[错误码全集](错误码全集.md)登记20项新原因字符串，不因此升级本文固定JSON结构，也不新增任务业务状态。使用原Issue、Outcome.issues、readiness_evidence依赖issues及监控MonitorEvidence.issues；页面Issue的额外定位字段不能直接复制进仅允许code/message的嵌套数组。StopEvidence含未解除阻断项时不得标完整确认；历史已确认对象和hash不为补新原因而回写。

首次开始日期从既有生效计划/发生项确定；startedAt须是已核准真实开始事实的投影，不能由PREPARED/INVOKING时间填充。跨天关闭与普通命令进入共用原任务/资源守卫，事务内重验无开始事实、无已发/未知开始命令及计划版本；发生竞争时保留未知而不提前取消/释放。仅靠本地事务仍不能证明远端不会迟到启动，实际入口约束见[设备命令契约](设备命令契约.md)。

原因证据沿当前SourceRef/relatedRefs、执行/命令、原始采样及profile引用关联，核对实际发生与接收时刻，保留多原因和原停止期限。缺少承载首次期限、权威开始时刻或客户截止上下文的具体路径，实施前须明确存储/DTO版本及并发回放规则；本次不把这些逻辑属性宣称为已存在的新JSON键，也不改旧schema或历史hash。未知仍为未知，原因解除以新的事实/事件表示，不删原故障。

## FEED-20261021：安全证据物理承载与独立v1模式

本节落实上述FEED-20261020承载缺口中的三个内部证据对象。主目标DDL及唯一开发基线增加三个`JSON NULL`列，不增加表、任务业务状态或现场默认参数；M07仍是唯一写拥有方。它们各自使用独立`schemaVersion=1`，不是向既有`CommandParameters`、`CommandEvidence`或`StopEvidence` v1追加未知键。数据库JSON类型不替代应用层的精确键集、类型、身份和来源核验；不接受浏览器/普通HTTP请求自报完整证据。尚无证据时保存SQL NULL，不写空对象或伪造已确认值。

| 逻辑事实 | 物理位置 / 受控生产与消费 | 精确v1模式 |
| --- | --- | --- |
| 真实首次开始事实 | `run_execution.first_start_evidence`；M07按原开始命令核验实际反馈后持久化，日期政策及恢复准入消费 | `{schemaVersion:1,taskId:string,firstStartCommandId:string,occurredAt:{reportedAt:ISO,earliestPossibleAt:ISO,latestPossibleAt:ISO,qualificationReference:string},receivedAt:ISO,evidenceReference:string,approvedProfileReference:string}` |
| 原段停止意图 | `run_execution_segment.stop_intent`；M07在原执行/段/资源守卫下归并，停止派发、期限核验及恢复屏障消费 | `{schemaVersion:1,identity:{executionId:string,segmentId:string,fence:string,adapterInstanceId:string,configurationRevision:string,profileId:string,profileRevision:string},firstRequestedAt:ISO,confirmationDeadline:ISO/null,causes:[{code:string,sourceRef:string,sourceHash:64hex,occurredAt:ISO}],timeoutObservedAt:ISO/null}` |
| 全范围观察覆盖 | `run_execution_segment.observation_coverage`；内部受控监控生产，M07锁读来源与原归属后应用，停止证据组装/最终化消费 | `{schemaVersion:1,executionId:string,segmentId:string,fence:string,adapterInstanceId:string,configurationRevision:string,profileId:string,profileRevision:string,coveredFrom:ISO,coveredThrough:ISO,state:COMPLETE/INCOMPLETE/UNKNOWN,issues:[string],sourceEvidenceRef:string,rawSourceHash:64hex}` |

`ISO`为带偏移的ISO-8601实际时刻，持久化保持源时间精度；Java内部记录可用`Instant`及长整型ID，JSON里的身份/版本字符串按既有受控模式保存。`64hex`为对应来源规范化内容的SHA-256，不能使用任意追踪ID替代。空值只允许上表明确声明的位置；无法形成完整合法对象时保留SQL NULL或沿原事件/原始样本承载未知，不把缺项改成默认事实。

**首次开始：**结构对应`M07FirstStartAdmissionPolicy.ActualStartEvidence/TimeEvidence`。`taskId`必须关联本行`execution.task_id`，`firstStartCommandId`必须关联本任务/执行的原首次开始命令及真实操作语义。`occurredAt`的上下界和`qualificationReference`用于证明源时钟质量；不能用`receivedAt`、HTTP受理时刻、PREPARED/INVOKING时间或设定值回读代替。可信的违规开始事实也须原样保留并按`TASK_START_DATE_VIOLATION`保护；来源/时钟不足时不能伪造合法开始或填充`started_at`。该列是首次可信事实，续段、重启和迟到重复反馈不得覆盖；同身份内容矛盾须保留冲突原件及事件，不能以最后写入者获胜。保留源精度的JSON是日界判定依据，既有`DATETIME(3)`投影不承担更高精度证据的替代职责。

**停止意图：**结构对应`M07StopIntentLifecycle.Intent/Identity/Cause`。首次写入固定原执行、原段、fence、适配器/配置及核准profile身份，同时锚定`firstRequestedAt`；同段并发原因在该身份下归并，原首期限不因追加原因、重试、重启或跨午夜重新计时。`causes`非空，以`code+sourceRef`识别重复来源，同身份不同摘要/发生时刻保留冲突而不覆盖旧原因。未取得核准停止时限时`confirmationDeadline=null`，不得据此伪造停止确认、恢复或释放资格；必要STOP仍可沿核准路径下发。后续补齐核准时限只能从原`firstRequestedAt`计算期限，不能从补齐时刻重新计时；已有期限不得改写。达到原期限但尚未确认停料时，首次登记`timeoutObservedAt`，迟到停止可推进收尾但不删除超时历史。`next_query_at`仍只是原命令下一次查证调度时间，不能替代本期限。

**观察覆盖：**结构对应`M07StopEvidenceAssembler.CoverageEvidence`，`state`是证据完整性，不是新增任务状态。完整覆盖必须具有一致的执行/段/fence、适配器、配置和核准profile身份，覆盖区间与本次STOP/观察要求一致，且`issues`为空；`INCOMPLETE/UNKNOWN`或缺失覆盖均不得组装完整停止确认。`rawSourceHash`绑定交付的完整原始STOP回执及全部原始样本，不能先过滤坏质量、缺口、后续新增量或再运行后再生成“完整”摘要。摘要按`rawEvidenceHash`的`{stopResultEvidence,samplePayloads}`信封计算：对象键规范化，样本按规范文本排序且保留重复项，对规范UTF-8内容取SHA-256并输出64位小写十六进制；新增或变更样本使旧覆盖摘要失效。`sourceEvidenceRef`必须可追溯到受控监控的持久事实，并由M07核对来源和身份；单纯客户端提交一个COMPLETE标签不构成证明。该列不把系统进程内组装器升级为进程外独立补料监控。

**并发、历史与边界：**三列只能在当前M07执行/段及资源守卫、版本条件下由受控生产路径写入；未知开始不允许提前取消/释放，首次事实和首停止锚点不能被重放覆盖。观察覆盖可按新受控事实更新当前完整性投影，但先前原件及摘要沿不可变事件/来源保存；已确认StopEvidence及历史hash不回写。A旧段迟到事实可进入受控隔离保存和对账，不能借新增列重新打开A控制权限或影响已接管的B。新增空列不等于事实生产、独立进程、M02真实截止入口或数据库事务已经验证；实际入口截止协议、活动登记/仲裁存储和剩余CT事项仍按对应契约推进，不能因本节落列而整体标为完成。


## P2-04：FEEDING_SAFETY_FACT 专用载荷 v1（2026-10-21）

仅适用 `run_event.event_type=FEEDING_SAFETY_FACT`，不扩大旧审计事件或 OBSERVATION_ALARM 模式。完整固定结构为：

```text
{
  schemaVersion:1, eventType:"FEEDING_SAFETY_FACT",
  source:{eventId:string,labId:string,cultureId:string,objectId:string,objectVersion:string,
          sourceEventKey:string,occurredAt:UTC毫秒ISO,payloadHash:64hex,payload:原审计JSON对象},
  mapping:{sourceEventType:SAMPLE_CONFLICT|MONITOR_ANOMALY_EVALUATED|M07_JITTER_OBSERVATION_EVALUATED,labId:string,ruleKey:string≤20,
           revision:string≤100,approvalReference:string≤100,approvalHash:64hex},
  m09Payload:{schemaVersion:1,canonicalVersion:1,ruleKey:string,
              conditionKey:null,sourceSequence:null,fact:M09既有Fact v1}
}
```

SAMPLE_CONFLICT 分支承接当前已落库六字段审计包 `{schemaVersion,eventType,object,actor,change,result}`；result 必须恰含 `conflictFlag=SAMPLE_CONFLICT/sourceSequence:64hex/existingSampleId:string/incomingPayloadHash:64hex/rawPayloadRef:string`。object 的执行ID/版本匹配原行，SYSTEM actor、空 before/after、空 relatedRefs 保持该生产者实际模式。原键为 `M07:SAMPLE_CONFLICT:`＋`SHA256(executionId+"|"+sourceSequence+"|"+incomingPayloadHash)`，原包摘要必须重算一致。实验室、培养、发生时刻继承已校验执行归属后写入的原行，不从 title、请求或映射推导。

新增两类来源保持各自信封：MONITOR_ANOMALY_EVALUATED 使用本文件下述七字段严格模式，reasons 至少含 NCS008/NCS009/NCS031/NCS032/MONITOR_UNAVAILABLE 之一；NORMAL_ENDPOINT 与 JITTER_OBSERVATION_REQUIRED 可共存但不投影为告警。M07_JITTER_OBSERVATION_EVALUATED 使用下述六字段模式，只有 PERSISTENT_JITTER 进入交接并投影 NCS030。解析必须重算完整原件摘要、验证 actor/归属/版本/原键；不能仅凭 event_type 字符串放行。缺核准映射仍 WAITING_MAPPING，初次抖动和恢复候选不交接。

子行 `object_kind=EXECUTION`，lab/culture/object/version/occurredAt 均匹配冻结 source；唯一键为 `FEEDING_SAFETY_FACT:<原eventId>`。子行 payload_hash 覆盖整个规范子包；M09 EventEnvelope.payloadHash 独立覆盖规范 m09Payload；Fact.source.hash 指向原审计包摘要，三者不得混用。发送前重新验证原包、映射及所有派生 M09 叶子，未知键/类型/版本/身份冲突阻断交接。来源原包内的 rawPayloadRef 仍受保护，仅保留在 M07 子包，不进入 M09 Fact。

M09 Fact 保持完整既有白名单：source=M07/RUN_EVENT/原eventId/对象版本/原hash；scope=CULTURE及真实lab/culture；actor=SYSTEM；direction=ERROR；policyRef=M09/RULE_MAPPING/核准引用/修订/核准hash；aliasRuleKeys 仅包含同一核准 ruleKey。entityLabels 为四个显式null叶子的对象，commandEvidence/links 为[]，无本次事实的数量、任务、阶段等字段为null，不伪造阈值、命令结果或恢复状态。这里只接受内部核准映射提供方，不增加 HTTP 输入、自由规则匹配或客户端自报核准能力。

source/子包/映射一经冻结不覆盖。生产事务锁原 LOCAL 行并按唯一子键去重；原行未有映射或不可校验时仅用 next_publish_at/publish_attempts/last_error 记录 WAITING_MAPPING/INVALID_SOURCE/RETRY，保持原 LOCAL 及 payload/hash。子包 PENDING/RETRY 的发布确认和重试需事件类型、eventId、原payloadHash、原publishAttempts全部匹配，事务外调用 M09。详见[业务观测采样与告警交接](业务观测采样与告警交接.md#p2-04一次性安全事实的可靠交接2026-10-21)。本模式不新增表、设备参数默认值或停止职责，亦不因契约和代码登记而表示数据库/现场联调完成。

## 2026-10-21：持久样本驱动的正常控制事务

- 新增固定后台用途 `M07_EXECUTION_CONTROL`，消费者 `M07ExecutionControlWorker`，独立原始 Bean 由 `M07ExecutionControlConfiguration` 装配并交既有 `ResourceTransactionExecutor` 颁发、密封能力。不得借用 `RESOURCE_CLAIM` 或 HTTP 身份。持久事实为已提交的 `run_execution_sample.sample_id`，固定 executor、assignmentEpoch、完整资源键及版本必填；无锁定位只声明锁集。
- 实际锁序为 SYSTEM → culture runtime → task/workflow → execution → 全部分段 → assignment/guard → 全部原命令及资源未决命令 → 唯一认可账。当前正常控制仅接任务 FEED 执行，不把工作流步骤套为任务首启；工作流仍走其明确步骤契约。
- 同事务复核当前 task/execution/segment 指针、任务 `EXECUTING`、整体 `NONE`、原 owner/fence/worker、原适配器与配置、完整冻结 spec。TASK 或 EXECUTION 任一 `NEEDS_RECONCILIATION`、PAUSE_REQUESTED/PAUSED/STOPPING/UNKNOWN，均不产生正常调速或 START。
- 控制样本须为本段最新已提交 ID，原 canonical payload/hash 一致；逐段原始样本的精确 observedAt 水位同时核验，不能把迟到的新 ID 当作更新物理事实。历史已认可量仍只读原 run_ledger；即时量＝逐段唯一认可历史量＋当前段核准方向下的实际重量变化，不写成已认可量，也不另建量账。活跃时长使用历史 CLOSED 段实际累计加本段实际累计，不按墙钟暂停时长重算。
- `ExecutionControlAuthority` 是内部受控事实口，不是前端 DTO：必须绑定 execution/segment/sampleId/fence、原 adapter/config、spec/sample 两摘要、受控评估时刻、核准政策引用及摘要、独立监控登记；量程、固定模式终点和宽限、运行速度回读容差、校准窗口及停止确认期限只使用明确核准事实。运行速度回读容差不得借用 STOP 零速容差；未知不填默认值。缺真实生产方时正常控制保持关闭。
- 正常阶段仅在原实际首启证据、原已执行 START/SET_SPEED、同源实际速度回读均成立后推进。PREPARED 不推进阶段；已执行的目标速度尚未由实际回读确认时等待，不重复发 SET_SPEED。未决 START/SET_SPEED/UNKNOWN 阻断调速，达到真实终点或活跃超时仍可准备独立 STOP；已有 STOP 待核对不生成替代 STOP，不重置首次停止期限。首次日期限制只限制实际首次开始，不限制已合法开始任务后续跨日运行。
- 新物理意图仍写原 `run_command` PREPARED，事务提交后交原 `M07TaskPauseDispatcher`/`M07CommandInvocationWorker` 派发；不在持锁事务执行设备 I/O。STOP 请求只推进 STOPPING、保存多原因停止意图与原资源占用，不表示停料、结算或释放。
- 不可变本地事件 `EXECUTION_CONTROL_EVALUATED` 使用 source key `M07:EXECUTION_CONTROL_EVALUATED:<sampleId>`；同一已处理样本不重复调速或延长 STOP。事件记录 sample/hash/精确时刻、specHash、政策/监控引用、实际累计观察量、历史/本段 active、目标阶段/速度、命令 ID 和原因。它是控制审计事实，不是认可量或 M09 告警已发布证明。
- `M07ExecutionControlTask` 轮转扫描并在事务返回后派发原已提交命令；`m07.execution-control.worker.cron` 未配置时为禁用值 `-`。现场启用必须明确该调度周期及适用性；cron 不证明采样覆盖，也不替代停止确认预算。静态映射与隔离模拟测试不等于真实数据库、设备或现场验收。

### 同事务正常收尾与原量暂记

原样本写入与原补偿任务通过 `M07PauseFinalizer` 分派：`PAUSE_REQUESTED` 保留既有暂停链，`STOPPING` 交 `M07NormalStopFinalizer` 核全 STOP/coverage/命令/段量。两者复用同一 `M07SegmentRecognition`，不另建第二账；完整正常结果与异常 PROVISIONAL 承载见[计量契约](计量确认与补液计算契约.md#2026-10-21正常终点收尾与异常原量冻结)。

`M07_EXECUTION_SETTLED` 与 `M07_EXECUTION_PROVISIONAL` 为 LOCAL 事件，source key 分别是 `M07:M07_EXECUTION_SETTLED:<executionId>`、`M07:M07_EXECUTION_PROVISIONAL:<executionId>`（沿现行 writer 的 `M07:` + eventType + identity 规范），object=原 EXECUTION/递增后版本。result 保存 `segmentId/stopCommandId/stopEvidenceHash/coverageHash/measuredTotalGrams/segmentGrams/settlementState/ledgerId/calculationId/finalAmountReason`；未认可或未计算时对应 ID 为 null。具有最终允差核准时同时记录 `finalPolicyReference/finalPolicyHash/minimumFinalGrams/maximumFinalGrams`，缺核准不能补默认值。正常结果 finalAmountReason=null；可信少加/超量分别为 NCS033/NCS009。并存故障和原停止期限/超时仍保存在原 stop_intent，不被收尾事件清除。这两类 LOCAL 审计事件尚未登记为新的 M09 自动映射，不能宣称告警已送达。

SYSTEM异常安全结算继续使用同一六字段LOCAL信封及原source key，result新模式显式`schemaVersion=2/outcome=ERROR`，精确18键：`schemaVersion,outcome,segmentId,stopCommandId,stopEvidenceHash,coverageHash,measuredTotalGrams,segmentGrams,settlementState,ledgerId,calculationId,finalPolicyReference,finalPolicyHash,minimumFinalGrams,maximumFinalGrams,finalAmountReason,calculateGlucoseChange,jitterObservationReason`。ID为正十进制字符串、摘要为64位小写SHA-256、量为十进制字符串，`settlementState=CONFIRMED`、两个账/计算ID不得为空；`calculateGlucoseChange`必须为真实核准布尔值，不填人工confirmedBy/handlingId。最终上下界已核准时保留原值；异常结算无该范围时两者均为null，不能据此产生最终量误差结论。finalAmountReason只能null/NCS033/NCS009且必须与原核准范围和实测量一致；jitterObservationReason只能null/NCS030，抖动恢复候选不是此异常收尾来源。范围不完整、未知键、重复键、版本溢出/未知版本或尾随JSON均拒绝。正常旧SYSTEM结果和人工首次认可旧结果模式保留原样，不为旧原件补键或改hash。`M07MonitorReleaseCodec`严格按上述分支校验后才能沿原外部交接，result schema2本身不证明已释放或告警送达。

安全PAUSED取消使用同一LOCAL `M07_EXECUTION_SETTLED` 信封/source key，result显式 `schemaVersion=3/outcome=CANCEL`，精确16键：`schemaVersion,outcome,segmentId,stopCommandId,stopEvidenceHash,coverageHash,measuredTotalGrams,segmentGrams,settlementState,ledgerId,calculationId,finalPolicyReference,finalPolicyHash,calculateGlucoseChange,cancelCandidateId,cancelCandidateHash`。其中ID为正十进制字符串，四个摘要字段为64位小写SHA-256，量为非负十进制字符串，`settlementState=CONFIRMED`；ledgerId引用原末段唯一FEED，calculationId引用原执行唯一SETTLE，候选ID/hash绑定本次直接取消或原审批决定。直接路由actor为原USER，审批APPLY为SYSTEM；不添加正常允差/finalAmountReason、人工handlingId或confirmedBy字段，不冒充异常补料处理。`M07MonitorReleaseCodec`按精确字段和版本校验，未知键、错误摘要/候选、未知或溢出版本均拒绝；旧模式不改写。

对应生产写口为 `M07PausedTaskCancelFinalizer` 与 `M07PausedTaskCancelMapper.finalizeCancellation(Write)`。先锁runtime及task，再按既有完整资源/命令/段账门禁证明真正安全PAUSED；原部分量已认可，所以只写SETTLE和last_calculation_id，不再次写FEED或累加培养/物料投影。原任务及执行版本、末段、USER_PAUSE、NONE、真实stop_evidence/stopped_at、候选槽和唯一SETTLE必须同时匹配后，才以同事务多表CAS更新task=CANCELLED/CONFIRMED/ended_at和execution=STOPPED/CANCEL/CONFIRMED；该UPDATE预期两行。任一校验/唯一约束/CAS或事件落库失败整体回滚。资源owner/fence/HELD不在该SQL中修改；提交后的既有释放消费者仍重验原结算与全部安全证据，再执行FREE和外部双ACK交接。原READY任务级直接/审批取消SQL不再接受PAUSED，避免绕过整体收尾。

实际量最终计算写`run_calculation` purpose=SETTLE、source_event_key=`M07:EXECUTION:SETTLE:<executionId>`，沿原`(source_event_key,purpose)`唯一约束。同事务核原计算与冻结目标相等、追加认可账与培养/物料投影、更新last_calculation_id，再CAS任务/执行/段；不写resource FREE、不直接发送设备命令。正常完成保留EXECUTED条件，异常安全结算允许业务仍ERROR；实际量CONFIRMED不代表异常已处理或达到正常目标。PROVISIONAL分支只冻结原段最终读数/原差/归一量/实际活跃时长和真实停止证据，e.confirmed_grams/e.active_milliseconds保持既有认可历史，取得可信原量认可后再并入一次；确需人工确认时不得跳过，也不因段CLOSED自动成为可恢复或可释放。ERROR先安全结算已接已知闭合命令分支；核准隔离UNKNOWN命令的生产证据分支仍未接，不因有结果schema而放行。

## 2026-10-21：独立监控 LOCAL 登记与原件来源

以下五种事件复用 `run_event` 的既有六字段审计包 `{schemaVersion,eventType,object,actor,change,result}`，发布状态固定 LOCAL，不自动进入 M09 映射。它们是内部事实，不能作为新增 HTTP 输入模式；payload_hash 覆盖整个规范审计包。未知字段不据此扩展旧 CommandEvidence、StopEvidence 或原样本模式。完整网络模式及锁序见[独立补料监控进程与保护通道契约](独立补料监控进程与保护通道契约.md)。

| event_type | 原对象、唯一来源与 result |
| --- | --- |
| `MONITOR_REGISTRATION_REQUESTED` | object=原 COMMAND/原命令版本；source key=`M07:MONITOR_REGISTRATION_REQUESTED:`＋`SHA256(commandId+"|"+commandPayloadHash)`。result=`{schemaVersion:1,commandId:string,commandPayloadHash:64hex,registrationHash:64hex,registration:FEED-SAFETY-V1完整Registration,gatewayInstanceId:string,monitorInstanceId:string}`。完整 Registration 包括原执行/段/资源集合/specHash/fence/适配器/配置、计划日/首启截止及显式批准事实。 |
| `MONITOR_REGISTRATION_ACKNOWLEDGED` | object 和 key 的原命令身份同上，key 中类型改为本事件。result=`{schemaVersion:1,commandId:string,commandPayloadHash:64hex,registrationHash:64hex,gateway:RegistrationReceipt,monitor:RegistrationReceipt}`。两端同原摘要、不同明确核准实例且 durable=true，网络后再锁定原命令/执行/段才可写入；最终 START 事务仍须重验。 |
| `MONITOR_EVIDENCE_RECEIVED` | object=原 EXECUTION；source key=`M07:MONITOR_EVIDENCE_RECEIVED:`＋`SHA256(registrationHash+"|"+position)`。result=`{schemaVersion:1,registrationHash:64hex,registrationId:string,identity:ProtectionIdentity,entry:JournalFact,pageSource:Proof,sourceStorageHealthy:boolean,coverageState:"UNKNOWN"}`。position 是该 registration 独立导出序号，entry 同时保留原全局日志位置/摘要与完整 body，不能截断或把缺页当连续覆盖。 |
| `MONITOR_SAMPLE_PROJECTED` | object=同原 EXECUTION；source key 与原件使用同 registrationHash/position，类型改为本事件。result=`{schemaVersion:1,registrationHash:64hex,entryHash:64hex,sampleId:string,samplePayloadHash:64hex,actualActivitySource:Proof,metricAndTimeQualification:Proof}`。仅原唯一 ExecutionSamplePort 返回 APPENDED/DUPLICATE 且无冲突时持久，防止重复投影；它不证明量已认可、停止已确认或观察覆盖 COMPLETE。 |
| `MONITOR_SAMPLE_EXCLUDED` | object=同原 EXECUTION；source key=`M07:MONITOR_SAMPLE_EXCLUDED:`＋`SHA256(registrationHash+"|"+position)`。result=`{schemaVersion:1,registrationHash:64hex,entryHash:64hex,reason:"BEFORE_SEGMENT_INVOKED",exclusionBasisHash:64hex,originalInvocation:{commandId:string,commandPayloadHash:64hex,invokedAt:ISO瞬间,commandResultHash:64hex,registrationEventId:string,registrationEventHash:64hex,ackEventId:string,ackEventHash:64hex}}`。exclusionBasisHash 覆盖 originalInvocation 规范对象；commandResultHash 覆盖完整原结果证据规范对象。仅完整原件、准确原起始命令及原登记/双ACK均通过校验，且整个 GOOD 原包严格位于原调用之前才持久。它不产生 sampleId、有效样本、覆盖或量账。 |

登记原件与双 ACK 分别由两个短事务持久；二者之间的 HTTP 不持有 M07 事务。请求/摘要/首次计划日和真实首启不因重试修改；单侧 ACK、无实例回执、网络失败与异包冲突都不能放行 START。必要 STOP 与命令查证不等待登记、分页收件或 M09 通知。

原件收件与合格 raw v2 的唯一 Port 投影在原执行锁内处理。缺资格来源时仍可收件并返回 BLOCKED_METADATA，既有原件可在资格补齐后重放；存储失败回滚且不返回成功游标。收件、投影、完整分页或日志 storageHealthy=true 均不能自行写 COMPLETE observation_coverage。当前仅登记软件实现与隔离验证边界，不将空列、LOCAL 事件或测试提供方提升为设备/现场已核准。

收件事务每次按原 journal position 扫描最多100条未投影原观察，空页也重试；遇最旧未决资格即停止后续样本推进，原件仍可继续接收。依次使用原资格生产者及唯一采样Port，raw/投影回执同事务提交；重启只从已有 run_event 重建待投影集合，不新增表或第二份量账。只有绑定相同 registration、entryHash、原执行归属的投影回执或本次重验原起始命令/双ACK所得相同 exclusionBasisHash 的明确排除事实可退出该集合。排除事实异包或依据冲突不得覆盖；未知命令、原计数落后、原阶段不符、跨段及关闭段仍按原规则阻断。详细判据见[业务观测采样与告警交接 P2-02](业务观测采样与告警交接.md#p2-02独立监控原件收件2026-10-21)。

排除依据的 `commandPayloadHash` 绑定原命令意图及登记；原 `resultEvidence.payloadHash` 必须按去掉自身摘要字段的结果 JSON 独立重算，不能与命令 `payload_hash` 混比。`originalInvocation.commandResultHash` 是完整原结果（含其自身摘要）的规范 SHA256，保留现有字段及版本；结果正文变化但未重新形成有效结果摘要时不能产生或复用排除事实。

2026-10-23 续段排除分支：上表 `MONITOR_SAMPLE_EXCLUDED.result.reason` 仅增加 `PREVIOUS_SEGMENT_BEFORE_CONTINUATION_INVOKED`。以原续段 SET_SPEED 为依据时，`originalInvocation` 在公共字段之外必须含 `previousRegistrationId:string,previousIdentity:完整ProtectionIdentity,continuationHash:64hex`；三者取自完整重验的原 ContinuationRequest，并参与 exclusionBasisHash。该请求的 resumeRequestId 必须与原命令一致。新原因只适用于原 `ownership=MISMATCH` 且 observedIdentity 完整等于该 previousIdentity；外层 observedAt、同包全部读数时间加核准误差及全部 receivedAt 均严格早于原 invokedAt，GOOD、原资源、原请求/双 ACK 和已执行命令结果要求不变。原 MATCH 的 BEFORE_SEGMENT_INVOKED 分支保留；未知、异执行/段/fence/资源、跨边界或坏质量不得排除。在本次续段扩展中，SQL 待投影集合仅识别上述两个精确原因且匹配本次重验所得 exclusionBasisHash；新执行接管的第三个原因及附加依据见下一段。既有续段排除缺上述依据时不重写旧事件或补 hash，保持冲突/待核对；首段公共依据不变。


2026-10-24 新执行接管前原包排除：新执行登记后、原 START 实际调用前，设备可能仍报告已释放的上一执行身份。仅在全部原资源的前一 fence（恰为新 fence−1）指向同一个历史释放原件，原登记、认可结算、资源释放、外部 gateway/monitor 双 ACK 经原交接投影完整核验，且双 ACK 不晚于新登记时刻时，才允许使用该历史身份。原、新执行必须不同，设备、控制器、适配器、配置、主资源和完整资源集合必须一致，每项 fence 恰递增 1。`ownership=MISMATCH` 且 observedIdentity 完整等于该已释放身份，外层 observedAt、全部 GOOD 读数加核准时钟误差和全部 receivedAt 均严格早于新 START 原 invokedAt，才记录 `PREVIOUS_EXECUTION_BEFORE_START_INVOKED`。原件即使迟到仍完整保留；不能改成 MATCH，不贡献样本、运行时间、覆盖或量账。新 START 必须具有已执行原结果、新登记与双 ACK，未知结果、未释放或缺 ACK、等于/跨越调用边界、坏质量及其他身份继续保护阻断。

该分支的 `originalInvocation` 在公共字段外增加 `previousReleasedIdentity:完整ProtectionIdentity`、`previousReleaseEvidence:按原eventId升序冻结的历史交接原件快照对象`；完整原件及其摘要一并参与 exclusionBasisHash，每次扫描重读并核对原释放事实，依据变化不得复用旧排除。SQL 队列只识别三个精确排除原因及本次重验所得相同 exclusionBasisHash，不建立通用忽略名单。读取历史原件时数据库故障必须向外传播并回滚收件事务，不能吞为“资格尚未就绪”或返回成功游标。历史投影用的查询 DTO 只提供历史执行上下文，不写任务状态；结算、释放和双 ACK 必须来自原件。

`MONITOR_EVIDENCE_RECEIVED.entry` 沿用完整 JournalFact，续段原首条 kind 为 CONTINUATION、body 为完整 ContinuationRequest；前段导出链也可包含该请求，必须匹配其 previousRegistrationId/previousIdentity。CONTINUATION_READY 的 body 为完整独立监控 ContinuationReceipt，只能归 nextRegistration。收件需重验同实验室/培养的本地原请求及双 ACK，READY 与本地 monitor 原回执逐项相等且 MONITOR_READY/durable；不合成 REGISTER、不改 MISMATCH，不以原件接收代替采样、覆盖或开泵许可。全部事件仍用既有表及 LOCAL 信封，原件/排除/投影在原事务内保持原子性；数据访问失败回滚，不返回成功游标。

### 独立保护释放专用 outbox

`MONITOR_RELEASE_HANDOFF` 使用单独固定载荷，不改变旧六字段审计包：

```text
{schemaVersion:1,eventType:"MONITOR_RELEASE_HANDOFF",
 release:Snapshot,registration:Snapshot,acknowledgement:Snapshot,settlement:Snapshot,
 request:FEED-SAFETY-V1完整ReleaseRequest}
Snapshot={eventId:string,labId:string,cultureId:string,eventType:string,
 objectKind:string,objectId:string,objectVersion:string,sourceEventKey:string,
 occurredAt:ISO,payloadHash:64hex,actorUserId:string/null,payload:原完整审计包}
```

四份Snapshot依次为原完整H06 `M07_RESOURCE_RELEASED`、原登记请求、原登记双ACK、原`M07_EXECUTION_SETTLED`；原行身份、来源键、actor和完整摘要必须重验，不接受仅类型名相同的对象。该settlement是实际量及安全结算来源，目标规则允许任务仍ERROR，不能用缺少人工handling拒绝完整安全来源，也不能伪造confirmedBy/handlingId补齐外壳。出站行source_event_key=`MONITOR_RELEASE_HANDOFF:<原释放eventId>`，对象/版本/实验室/培养沿原释放EXECUTION，payload_hash覆盖全部快照及完整请求。原释放result的sourceEventHash/segmentId/stopEvidenceHash/coverageHash与原结算逐项一致；旧缺项保持WAITING_RELEASE_PROOF，不伪造新模式或历史hash。

registration/acknowledgement快照按原最终结算段选择：初始登记为`MONITOR_REGISTRATION_REQUESTED/ACKNOWLEDGED`，续段为`MONITOR_CONTINUATION_REQUESTED/ACKNOWLEDGED`。续段快照保留原完整ContinuationRequest及双ContinuationReceipt，不改写为初始登记外壳；ReleaseRequest使用其中nextRegistration的原身份，仍完整核验continuationHash和原命令。现有Snapshot完整保留eventType及payload，外层schemaVersion=1不增加字段、不重写历史JSON。读投影还逐项对照四份本地原件和出站快照，不能只凭ReleaseRequest相等忽略被替换的原件。

PENDING/RETRY 的发送在事务外进行；完整网关/监控双回执持久为六字段 LOCAL 事件 `MONITOR_RELEASE_ACKNOWLEDGED`，source key=`M07:MONITOR_RELEASE_ACKNOWLEDGED:<原handoffEventId>`，result=`{schemaVersion:1,handoffEventId:string,handoffPayloadHash:64hex,releaseRequestHash:64hex,gateway:ReleaseReceipt,monitor:ReleaseReceipt}`。追加此事件和原 outbox 的 PUBLISHED CAS 在同一短事务；CAS 条件包含原 eventId、类型、尝试次数及 payload_hash。失败保留原不可变请求和原来源，不能将网络返回当本地持久成功。

本专用类型与 LOCAL 回执均不进入 M03/M09 既有扫描白名单，不新增表或第二套释放状态机。独立保护是否解除只认原共享协议的实际匹配 ACK；本地资源 FREE、outbox 待发、业务数据库恢复和健康恢复均不能替代。严格来源、分支与调度开关见[保护通道契约第10节](独立补料监控进程与保护通道契约.md#10-本地释放到独立保护解除的可靠交接)。


### 2026-10-21：原结算事件驱动 TASK 整组资源释放

`M07ResourceReleaseTask`仅无锁发现候选，不写状态、不访问设备。显式部署开关`m07.resource-release.worker.cron`缺失时为`-`（不启用）；必须提供原固定`m07.command-dispatch.executor-id`，不推断采样周期、停止期限或核准参数。目标候选要求原执行实际量CONFIRMED、STOPPED及全部安全证据完整，并存在同原执行安全结算版本的`M07_EXECUTION_SETTLED`；任务ERROR可仍待人工处理，必须交回原H06 worker锁内重新判定。现候选SQL及锁内资格已包含ERROR；扫描同时纳入已ERROR且原执行STOPPING/ERROR的停止最终化，PAUSED不由此释放。只有同一不可变SETTLED与当前完整安全事实能进入释放事务；不能只靠状态或扫描命中绕过锁内证据。

释放内部请求增加 `releaseEvidenceByResource`，不改外部 `ReleaseEvidence v1` 九键合同。其 key 集合与版本/fence map 及原冻结 `ExecutionSpec.resourceKeys/resourceClaims` 完全相同。每项 `stopEvidenceRef.contentHash` 为原 `stop_evidence` 规范化 SHA-256，`objectVersion` 为原最终执行版本，`commandIds` 指向原实际 STOP 集合，不生成新的秤 STOP。原 STOP 可证明附属资源时，必须核验完整原命令信封摘要、原执行 `contentHash=specHash`、冻结设备/能力/配置来源及完整各资源 fence。所有实际操作仍在原 `M07_RESOURCE_RELEASE` 用途同一事务完成；锁序为 SYSTEM → runtime → task/workflow → executions → segments → assignment/guards → commands → ledger，扫描不持有任何反向行锁。

新增完整整组释放事件仍用 `eventType=M07_RESOURCE_RELEASED`、`publish_state=LOCAL`。仅新完整分支采用 `object={kind:EXECUTION,id:原executionId,version:原最终executionVersion}`，事件幂等键为 `M07:M07_RESOURCE_RELEASED:<原最终结算eventId>`。旧事件格式不得自动升级为完整外部释放证明。`result` 精确键如下：

| 键 | 类型与来源 |
| --- | --- |
| `schemaVersion` | 整数 `1` |
| `ownerKind` | `EXECUTION` |
| `ownerId`、`executionId` | 同一原执行正整数十进制字符串 |
| `sourceEventId`、`sourceEventHash` | 原不可变 `M07_EXECUTION_SETTLED` 的事件 ID 与完整信封规范化 SHA-256；不是扫描/调度触发 ID |
| `segmentId` | 原最终分段正整数十进制字符串 |
| `executionSpecHash`、`stopEvidenceHash`、`coverageHash` | 原执行 spec、原停止证据、原完整受控覆盖 JSON 的规范化 SHA-256，小写 64hex |
| `releasedResources` | 按资源键排序的完整数组；每项精确 `resourceKey/fence/objectVersion`，后两者为原 fence、释放后 guard 版本的正整数十进制字符串 |
| `releaseEvidenceByResource` | 相同完整 key 集合的对象，各值为核验后原 v1 九键 JSON 对象 |

同事务重验原结算事件完整hash、实验室/培养/执行/版本、原分段/STOP/覆盖hash、当前段唯一认可账与总量。原量不变的后续handling不推进execution版本，避免破坏原SETTLED关联。若在本地H06前发生一次合法人工改量，仅允许当前ERROR_HANDLED版本恰为原结算版本+1，且原最终段/全部关闭分段/原STOP/coverage未变、没有后续物理运行、handling内容hash及原FEED→ADJUSTMENT全链一致；原SETTLED.measuredTotalGrams仍与原物理FEED合计核对，当前投影与更正后合计核对。释放事件使用当前执行版本，原sourceEventId/hash保持不变；外部消费者只接同版本或该相邻版本的完整H06原件，不能将泛化`<=`当授权。人工原量首次认可新增的`M07_EXECUTION_SETTLED`保持公共证据键，并在真实人工分支保留`confirmedBy/handlingId/finalPolicyReference/finalPolicyHash/calculateGlucoseChange`；明确核准布尔值和实际量是SETTLE前提。ERROR自动安全结算复用公共来源模式与真实SYSTEM身份，不补造人工键；之后handling复用已有唯一结算原件，不为人工处理另造同执行第二份SETTLE或释放来源。旧无SETTLE或缺原证据事件保持等待，不补造来源。

FREE 与此不可变事件同事务提交后才允许进程外交接证明 `resourcesReleased=true`；网关和监控的原登记、原 releaseRequest 与两个实际 ACK 由后续持久交接链核验。不能把 LOCAL 事件等同已完成双 ACK，也不能在本地 FREE 提交前对外声明资源已释放。

### ERROR安全收尾先释放：事务与幂等边界

本节原命令闭合按[设备命令H06](设备命令契约.md#2026-10-21-h06-停止后资源释放资格)核验；ERROR最终释放可采用核准隔离证明闭合原命令的后续物理作用风险，不能将历史UNKNOWN伪造为成功。客户侧在途处置、旧写权撤销、历史实际量与归属任一不可证仍阻断；不扩展暂停续段或其他释放分支。

1. 原安全结算事务沿runtime→task→execution→segments及既有资源/命令/ledger锁序，重验真实STOP、最低安全观察/完整coverage、全部原命令闭合、无未归属变化和可信实际量。仅在同事务完成原唯一FEED、SETTLE、培养/物料/活跃时长投影及`M07_EXECUTION_SETTLED`后，才能形成ERROR + STOPPED + CONFIRMED安全结算组合；仍PROVISIONAL或NEEDS_RECONCILIATION不得声明安全收尾。状态都是既有状态，不增表列、账或状态机。
2. 后续H06事务只释放原执行仍持有的完整资源集合，原guard/fence逐项CAS并与上述12键`M07_RESOURCE_RELEASED`同提交；原结算eventId/hash是唯一释放来源，不能用handlingId、调度轮次或当前时间换键重复释放。再沿原固定请求做网关/监控解除交接。任一外部失败保留原请求、证据和旧保护，新owner必须另取得合法claim及登记；不因本地FREE直接放开实际写入口。
3. 人工处理另沿原任务/培养事务读取原已认可量和不可变结算/释放证明，写唯一handling及确需的补充子候选/任务或独立更正账。原量不变时不重复FEED/SETTLE、累计时长或资源FREE；不得重占旧guard或发送原执行命令。所有异常处理任务均按确认实际量评估严格>5%的补充资格，不按故障码筛成“仅堵塞”。子任务须独立审批/准入/claim，不能复制父执行owner/fence或借父释放证明启泵。
4. ERROR及同培养前序/关联补料队列仍保留，设备故障/现场锁独立保留。其他培养只可通过自身合法绑定、健康、资源和实际入口准入使用完成交接的设备。迟到事实沿H08保存原包/冲突并核当前归属；旧结算/释放原件不回写，旧任务对账不能修改或停止新owner设备。

本批已接已知闭合命令下的ERROR自动可信量结算、原H06扫描/锁内资格、schema2来源重放及handling幂等分流。已CONFIRMED人工处理读取原结算事件与唯一VALID SETTLE关联，源码不读取或重占旧资源guard；未知/损坏原件仍阻断。核准隔离UNKNOWN命令的证据入口尚未接，不能将该目标分支登记完成；定向测试、隔离SQL、HTTP/浏览器及现场分别按实际证据更新，不改变DDL或现场参数。

### 2026-10-21：独立监控活动与证据轮询专用 outbox

生产入口为 `M07MonitorActivityTask`。三个专用类型 `MONITOR_PROGRESS_HANDOFF/MONITOR_FIRST_START_HANDOFF/MONITOR_EVIDENCE_POLL` 不进入 M03/M09/释放 outbox 白名单。payload 精确为 `{schemaVersion:1,eventType,source:Snapshot/null,registration:Snapshot,acknowledgement:Snapshot,firstStartEvidence:string/null,request}`，Snapshot 复用上文原行身份、完整原审计包和 hash；request 分别是 FEED-SAFETY-V1 的 ProgressUpdate/FirstStartUpdate/EvidencePullRequest。FIRST 的 firstStartEvidence 是正式 codec 的原规范首启事实；PROGRESS/POLL 该键为 null，POLL 的 source 为 null。进度/首启 source key 为 `<专用类型>:<原sourceEventId>`；轮询为 `MONITOR_EVIDENCE_POLL:<原登记eventId>:<原登记publish_attempts>`，同次请求不可换键或改 cursor。

运行控制进度接正式 `EXECUTION_CONTROL_EVALUATED.change.after` schema2；停止观察进度（正常终点、异常停止及人工暂停）接下述 `M07_STOP_OBSERVATION_PROGRESS.change.after` schema1。首启接完整的原 RECORDED/STOP_REQUIRED 事实并再查同 execution 首份持久事实。七字段 appendStrict 原信封与六字段本地事实原信封各按其精确形状校验，不混用。首次事实 JSON 的数据库格式化不改变其规范 hash，原发生时间保留纳秒。

停止观察事实由 `M07StopMonitorProgressProducer` 在原 runtime/task/execution/segment 锁内产生，复用 `M07MonitorActivityTask` 扫描和原活动/上下文 outbox，不新建量账或传输协议。LOCAL 六字段原信封的 eventType 为 `M07_STOP_OBSERVATION_PROGRESS`，object 为当前 EXECUTION、actor 为 SYSTEM；`before/result=null`，`change.after` 精确字段为 `schemaVersion:1,registrationId,registrationHash,executionId,segmentId,physicalPhase,controlledAt,observedAt,stopCommandId,stopRequestId,stopPayloadHash,stopParameters,stopResultEvidence,stopCreatedAt,stopInvokedAt,stopIntent,observationSource,stopSource,independentSource,independentRequestSource,pausedSource,qualification`。非空 Source 使用完整原事件 Snapshot；`qualification` 为原核准指标/时间资格 Proof。source key 为 `M07:M07_STOP_OBSERVATION_PROGRESS:<SHA256(registrationHash + "|" + 原OBSERVATION entryHash)>`，固定长度满足现有 `run_event.source_event_key VARCHAR(128)`，不扩列；两份完整原始摘要仍保留并由 codec 回算来源键。相同独立原件只能形成一次进度，不因扫描、重试或发送刷新时间。

`stopSource` 必须是准备当前原 STOP 的真实已提交事件：人工暂停为 `M07_TASK_PAUSE_REQUESTED`；正常终点或运行异常为同命令的 `EXECUTION_CONTROL_EVALUATED(state=STOP_PREPARED,desiredPhase=STOPPING)`，逐项核验原采样 ID/hash、全部停止原因、原登记和身份；独立保护停止为 `MONITOR_STOP_RECONCILED`，还须将其原接收证据保存在 `independentSource`，若该证据为 STOP_RECEIPT，`independentRequestSource` 必须是配对原 STOP_REQUEST。非独立来源的这两键必须为 null。原请求/回执、归并 eventId/hash、同 STOP 命令和全部原因必须一致，归并不得推迟首次时刻或期限。`pausedSource` 仅 PAUSED 时为原 `M07_EXECUTION_PAUSED`，其他时候为 null。

该事实还须绑定同身份完整资源占用、原 EXECUTED STOP 的实际 STOPPED 结果及摘要、原 stopIntent 首次时刻/核准期限，以及新的合格独立 OBSERVATION 原件。STOPPING 的原资源仍为 STOPPING；PAUSE_REQUESTED/PAUSED 的原资源仍为 HELD。指标角色、单位、源 boot/序号、GOOD、时间质量和完整指标集合仍走正式核准提供方；实际泵速非零、坏质量或暂停闭段后的实际活跃计数变化不能产生停止观察进度。STOPPING/PAUSE_REQUESTED 保留 OPEN；PAUSED 必须同时有 CLOSED、原认可暂停事件及 ledgerId。CLOSED 段只做观察资格复核，不再写执行采样或量账。

进度继续经过同登记前序排序、精确原上下文 ACK 和原 ProgressUpdate；独立监控进度超时不放宽，不能凭 PAUSED/STOPPING 字符串免检。正常终点后的控制不再调速，但有真实停后观察时应按同一机制交接，不能因缺少后续调速事件而误报进度停滞。停止稳定、完整停后观察、首次期限、异常处理和释放条件不由观察进度替代；新原因保留在原 stopIntent，不将异常停止改成正常完成。

LOCAL 六字段 `MONITOR_ACTIVITY_ACKNOWLEDGED` 的 result 精确为 `{schemaVersion:1,activityType,registrationHash,requestHash,outbox:Snapshot,receipt,ingestion}`，source key=`M07:MONITOR_ACTIVITY_ACKNOWLEDGED:<原outboxEventId>`。receipt 为实际相应协议回执或完整 EvidencePage。进度/首启 ingestion=null；页 ingestion=`{nextCursor,nextHash,rawAccepted,projectedSamples,coverageState:UNKNOWN,blockers:[string]}`。本地原始页 ingestion、ACK 追加及原请求 PUBLISHED CAS 同事务；网络在事务外。cursor/hash 必须由同 registration 原页的持久 ACK 导出，不能从最大 sampleId、当前时间或别的登记推算。保留原页用于后续明确资格下重放，PUBLISHED 不表示 raw v2 已投影或观察覆盖已完成。

LOCAL 来源仅允许更新 publish_attempts/next_publish_at/last_error 作为待交接调度元数据，不能改来源 payload/hash。进度同登记严格前序交接；轮询有界且同登记单在途。原 START/SET_SPEED/STOP、计量与资源状态仍由原 M07 事务负责，独立进度/采样回交失败不妨碍必要 STOP。完整职责及启用项见[保护通道契约第11节](独立补料监控进程与保护通道契约.md#11-已提交控制事实与原始页的自动交接)。

### 2026-10-21：核准配置 schema2 与实际控制资格

`M07ApprovedExecutionProfileLoader` 继续要求受控绝对路径和文件 SHA-256 固定摘要，启动时一次性载入不可变 Catalog。schema1 原字段保持精确兼容，不从旧配置补运行允差或结算布尔值。schema2 在原字段上增加以下两个键；整项显式 `null` 表示该资格未核准，相应业务保持阻断：

| 对象 | 精确字段与规则 |
| --- | --- |
| `controlAuthority` | `actualSpeedToleranceGramsPerMinute` 为明确非负十进制字符串；`source` 为完整核准 Proof。不得复用停止速度容差 |
| `finalPolicy` | `minimumFinalPercentOfTarget/maximumFinalPercentOfTarget` 为明确有序十进制字符串；`calculateGlucoseChange` 必须是布尔值；`physicalAfterMetric` 与 `source` 必须显式存在 |
| `physicalAfterMetric` | 精确字段为 `role/resourceKey/deviceRef/metricCode/unit/source/sourceRevision/netMode/tareGrams/precisionGrams/profileRevision`。role 必须为 `REACTOR_MASS`，unit 为 `g`；来源及资源属于同核准 binding，净量方式仅接受明确 `NET_DIRECT/GROSS_MINUS_TARE`。`true` 必填，`false` 必须显式 `null` |

`M07ActiveMonitorRegistrationResolver` 只读取当前 execution/segment 的原 REQUEST/双 ACK 与原命令，检查 canonical hash、同原 COMMAND 版本、完整冻结资源及稳定身份。首段按 MONITOR_REGISTRATION_REQUESTED/ACKNOWLEDGED 绑定原 START；续段按 MONITOR_CONTINUATION_REQUESTED/ACKNOWLEDGED 及原 SET_SPEED 绑定 continuation.nextRegistration，不借旧段 ACK。续段复用同一严格 ActivityCodec 与原 ContinuationEvidence，不另造弱解析。返回 request/ACK eventId/hash及真实 acknowledgementEventType；内部兼容字段 startCommandId 在续段指原恢复命令，不伪造新首次开始。当前命令版本可在登记后推进，不能改原ACK版本。该 resolver 不重新登记、不宣称健康、不因核准期限过期抹掉原保护事实；双ACK只证明原监控接管，必要取证/停止不等ACTIVATED，正常写和恢复进度仍按原ACTIVATED门禁及核准时钟重验。

采样资格及执行策略核准另调用同一 Resolver 的 `approvalSource`：首段以原登记的核准 source 为准；续段登记 source 始终保留 `M07:CONTINUATION:<commandId>` 恢复资格 Proof，不能改写为首段 source。通过原 `M07_CONTINUATION_ELIGIBLE`、REQUEST 的 sourceEventId/hash、完整 ContinuationRequest、sourceFacts 规范摘要，逐段追溯 previousRegistrationId/完整 identity、previousRegistrationHash、前段 REQUEST/双 ACK 的 eventId/hash，直到原 START 登记。每层核验同任务/执行/实验室/培养、冻结 spec、全资源/fence、控制器/适配器/配置，以及未变的 profile、clockQualification、readStopAuthorization、计划日和首启期限；拒绝断链、重复段、跨作用域和替换核准。原 sourceFacts v1/v2 依现有版本读取，不补默认字段；不重新计算或复制量账。

`selectContinuationApprovalSource` 仅查精确 sourceEventKey 的 `LOCAL/COMMAND/SYSTEM/M07_CONTINUATION_ELIGIBLE` 原件；续段双 ACK 使用包含 `MONITOR_CONTINUATION_ACKNOWLEDGED` 的 `selectMonitorActivityRegistrationFact`，不得误用仅登记/释放 ACK 的 release 查询。核准文件只与追溯取得的首段 source 比较，不能仅凭同设备、当前续段 source 字符串或健康成功选择配置。缺来源追溯时继续阻断采样/控制资格，原停止保护事实保留。

`M07ApprovedExecutionAuthority` 同时提供控制与结算资格：样本须是同执行/段原已提交 GOOD v2 原件，并关联唯一 `MONITOR_SAMPLE_PROJECTED` 的实际活跃及计量/时间资格、原 `MONITOR_EVIDENCE_RECEIVED` 的 Observation 原件；核对全部原读数、质量、时序、来源、登记及完整摘要，不能仅按 payload 自报 active 授权。配置启用由 `m07.approved-execution-profiles.enabled` 和既有资源事务开关共同控制；回调只读已加载参数与持久事实，不在事务中读文件或调用设备。

控制成功事务仅在上述原登记来源齐全时产出 `EXECUTION_CONTROL_EVALUATED.change.after` schema2，精确 29 键为：`schemaVersion/sampleId/sampleHash/segmentId/observedAt/executionSpecHash/policyReference/policyHash/monitorRegistrationReference/state/desiredPhase/commandId/desiredGramsPerMinute/cumulativeObservedGrams/currentSegmentActiveMilliseconds/closedSegmentsActiveMilliseconds/reasons/calibrationEvidenceHash/executionId/fence/adapterInstanceId/configurationRevision/sourceCommandId/sourceSequence/controlledAt/registrationId/registrationHash/registrationAckEventId/registrationAckHash`。`sourceCommandId` 是原实际样本命令，`commandId` 是本次新准备命令、可为 null；`sourceSequence` 来自原样本数据库事实，不能用事件 ID 替代。`controlledAt` 保存原评估 Instant 纳秒文本，不能用 DB 毫秒时刻或观测时刻冒充。旧 schema1 仅保留原审计语义，不成为进度授权。

### 校准采纳原件（EXECUTION_CALIBRATION_ADOPTED）

三段校准的显式系数与修正时限使用独立 `run_event` 原件，不扩写上述 29 键，也不更改原 `ExecutionSpec/spec_hash`。完整信封仍为 `appendStrict` 的七键；`eventType=EXECUTION_CALIBRATION_ADOPTED`，对象 `EXECUTION`，actor 为原资源事务的 `SYSTEM/M07_EXECUTION_CONTROL`，`change.before=null`、`relatedRefs=[]`、`result=null`，本地状态 `LOCAL`。唯一来源键固定为 `M07:EXECUTION_CALIBRATION_ADOPTED:<executionId>:<segmentId>`。读取按唯一来源键取得完整原行，不过滤掉错误状态或归属后将其当成不存在；必须核整行归属、版本、完整信封规范 hash 与 SYSTEM 用途。

`change.after` schema1 精确 16 键：`schemaVersion,executionId,segmentId,fence,adapterInstanceId,configurationRevision,executionSpecHash,adoptedAt,policy,profile,window,plan,speedResolution,sample,sourceCommand,adoption`。schemaVersion 仅精确整数 1；拒绝重复键、未知字段、尾随 JSON 及非字符串身份。时间保存原 ISO Instant 纳秒文本；DB 毫秒事件时刻只能与其投影核对，不替代 `adoptedAt` 或原观测时刻。

| 子对象 | 精确字段与语义 |
| --- | --- |
| policy | `reference,hash,monitorRegistrationReference,registrationId,registrationHash,acknowledgementEventId,acknowledgementEventHash,acknowledgementEventType`；来自本次同源 Approval，登记与原 ACK 全绑定 |
| profile | `bufferMilliseconds,minimumWindowMilliseconds,kMin,kMax,sourceRef,sourceHash`；显式核准校准窗口及系数范围，无历史默认值 |
| window | `fromActiveMilliseconds,throughActiveMilliseconds,normalizedDeltaGrams,sourceRef,sourceHash`；仅完整良好、实际活跃的原窗口，sourceRef 为 `M07:CALIBRATION_WINDOW:<execution>:<segment>:<firstSample>:<lastSample>`，摘要涵盖原样本/实际原命令、阶段与连续来源证明 |
| plan | `targetGrams,endpointGrams,maximumGramsPerMinute,calibrationBoundaryGrams,highBoundaryGrams,minimumCalibrationMilliseconds,calibrationGramsPerMinute,highGramsPerMinute,lowGramsPerMinute,coefficient,theoreticalSeconds,timeoutSeconds,timeoutGraceSeconds`；原目标/阶段边界及修正速度，宽限仍来自冻结策略 |
| speedResolution | null 表示没有可用的显式量化授权，不能擅自舍入；否则精确 `incrementGramsPerMinute,roundingMode,sourceRef,sourceHash` |
| sample | `sampleId,sampleHash,observedAt,sourceSequence,activeMilliseconds,cumulativeGrams`；本次真实已持久控制样本和观察进度，不是认可量或 FEED 账 |
| sourceCommand | `commandId,requestId,commandHash,resultHash,executedAt`；样本对应原已执行命令，完整意图与实际回执摘要分别绑定 |
| adoption | `state,phase,commandId,requestId,commandHash,createdAt`；state 仅 `SPEED_PREPARED/PHASE_CONFIRMED`，phase 仅 `HIGH/LOW`；前者绑定同事务已插入的真实新 SET_SPEED 原件，后者绑定已执行原命令及真实速度确认，不虚构新命令 |

所有 ID、配置版本、毫秒计数为十进制字符串，克量和速度为精确十进制字符串；`coefficient/theoreticalSeconds/timeoutSeconds` 各为 `{numerator,denominator}`，两者均最简正整数字符串，禁止浮点或显示舍入。读取复核 `k=Δm×60000/[qC×(through−from)]`、核准范围、修正速度上限、理论校准时长及修正后总时长、原宽限之和；并与冻结规格和完整核准输入精确重放结果一致，不凭一份自洽 JSON 声称外部原件已核准。

`M07CalibrationAdoptionWriter.persist(Input,resultingExecutionVersion)` 只能在原实际 `M07_EXECUTION_CONTROL` 资源事务中调用，校验 SYSTEM 锁、真实样本 ID、执行器及完整资源声明。`SPEED_PREPARED` 与本次命令同版本，`PHASE_CONFIRMED` 使用实际阶段 CAS 后的版本；命令、阶段、首份原件和原控制事件共同提交或回滚。已有首份原件只核对并返回原 eventId，不覆盖首次样本/采纳时刻。后续生产 Authority 通过专用 Mapper 读取并核对首件后才返回校准 Approval；旧控制事件原件可按既有严格来源链重放，不回填伪造历史首件。跨段复用未核准仍阻断；此原件不授予 START、解除保护、资源释放或认可补入量的权限。实际代码测试、隔离 SQL 与设备验证分别登记，不以本节定义代替通过证据。

## 2026-10-21：监控异常判定原件登记

`MONITOR_ANOMALY_EVALUATED` 是 M07 受控执行事务产生的 LOCAL 事实，复用 `run_event`，不新增表或量账，不改变旧样本/命令 JSON。它沿 `M07RunEventFactWriter.appendStrict` 的七字段 envelope schemaVersion=1：`{schemaVersion,eventType,object,actor,change,relatedRefs,result}`；判定放 `change.after`，`change.before=null`、`relatedRefs=[]`、`result=null`。不得按上文六字段登记回执模式解析，也不能将 LOCAL 解释为 M09 已接收。

| 来源项 | 固定契约 |
| --- | --- |
| 原对象与键 | object为原EXECUTION及同事务转换后版本；identity为原sampleId；source_event_key=`M07:MONITOR_ANOMALY_EVALUATED:<sampleId>`。actor保留真实SYSTEM用途`M07_EXECUTION_CONTROL`、管理版本及评估时间；不借页面身份。 |
| `change.after` schema1 | 精确叶子：`schemaVersion,sampleId,sampleHash,executionSpecHash,segmentId,sourceCommandId,controlledAt,evaluation,reasons`。ID为十进制字符串，hash为64位小写SHA-256；sourceCommandId指原样本所依据的已执行START/SET_SPEED，不是本次新准备的STOP；controlledAt保留评估时刻原ISO精度，不替代样本实际采样时刻。 |
| 判定来源 | 正常`evaluation` schema1保留`policy,samples[{sampleId,sampleHash}],continuitySource,continuityHash,blockers`；仅JITTER_OBSERVATION_REQUIRED时另有`trigger:{schemaVersion:2,start:Sample,end:Sample}（旧schema1保留读取）`，没有`input`整段历史副本。真正采用原已确认阶段边界时可附`phaseBoundary:{sampleId,sampleHash,confirmedPhase,source:{reference:"M07:EXECUTION_CONTROL_EVALUATED:<eventId>",revision:"1",hash:原完整信封hash}}`；不匹配实际trigger.start的历史边界不得附带。缺窗口核准分支仅保存`schemaVersion,blockers`；解析/资格失败分支保存`schemaVersion,blocker,failureType`，不得吞为正常结果或量0。 |
| 原因与事务 | reasons保留本次判定及并发终点/超时/超量等全部原因；STOP命令准备、stop_intent与该事实在同一原资源事务提交，失败回滚。初始抖动`JITTER_OBSERVATION_REQUIRED`仅是内部停止观察原因；持续观察异常才是NCS030。其他沿NCS009/031/032与MONITOR_UNAVAILABLE，不新增第21项共享原因或HTTP码。 |
| 消费边界 | 该事件只是判定/动作意图原件，不是实际停料、原量认可、COMPLETE覆盖、控制进度ACK或告警送达证明。FEEDING_SAFETY_FACT 仅接受上文明确列出的异常原因及核准映射；不因该事实存在便进入 monitor progress/actual-start。初次抖动与正常终点自身不告警。 |

`policy`精确12字段沿FeedingAnomalyEvaluator.Policy：`monitorIntervalSeconds,jitterCheckFactor,jitterFactor,jitterObserveSeconds,jitterScaleFactor,backflowFactor,clogCheckFactor,clogFactor,precisionGrams,originalTargetGrams,overAmountPct,source`。`Sample`保留`identity,phase,commandId,commandedGramsPerMinute,totalGrams,observedAt,sourceSequence,quality,source`；identity为`executionId,segmentId,materialSessionId,adapterInstanceId,configurationRevision,deviceRef,sourceBootId,unit,metricCode`。ID/配置版本为十进制字符串；observedAt为原ISO纳秒字符串；deviceRef与source沿共享DeviceRef/Proof契约，数值不由当前配置回填。trigger的start/end必须可由原sampleId/hash及原登记核验；不得信任外部自报触发锚点或修改历史hash。恢复沿原policy和start计算原J，不按当前参数重算新的阈值。phaseBoundary须回读原PHASE_CONFIRMED schema2事件，核样本、原已执行命令、执行/段/fence/spec、登记及完整hash；只允许STARTING→CALIBRATION/HIGH、CALIBRATION→HIGH、HIGH→LOW对应的原边界投影（共享计算类型用CALIBRATING表示校准）。原raw不改写；仅窗口start真正命中该边界时适用，后续滚动窗口不继承旧boundary，其他样本仍按原phase严格核对。

同一原sample只形成一个原判定身份；重试、晚到及重新收件不改变原窗口、触发基准或首次停止期限。窗口资格缺失时运行保护停止；确知处于该阶段/命令窗口初期且跨度尚未足够时只等待样本，超量、执行超时、数据时效等其他保护仍运行。过时仍无可比边界、缺口或资格失效不能无限归为初期等待，按MONITOR_UNAVAILABLE保护并留原blocker。文档登记及源码调用存在均不等于此整链已验证，测试与现场证据分别登记。

## 2026-10-21：抖动观察结论与独立STOP归并原件

`M07_JITTER_OBSERVATION_EVALUATED` 沿 `appendLocal` 六字段 schema1 信封，object=原 EXECUTION、actor=SYSTEM，change.before/after=null、change.relatedRefs=[]。result 精确为 `{schemaVersion:1,state,executionId,segmentId,fence,executionSpecHash,triggerEventId,triggerEventHash,stopCommandId,stopEvidenceHash,physicalStoppedAt,observedThrough,continuityReference,continuityHash,observations:[{sampleId,sampleHash}]}`。state 仅对形成原件的 RECOVERY_ELIGIBLE/PERSISTENT_JITTER；前者不是 START 或自动解除人工锁许可，后者才投影 NCS030。source_event_key=`M07:M07_JITTER_OBSERVATION_EVALUATED:`＋SHA256(规范 result)。原触发起点/阈值、物理停料与覆盖原件核对后形成结论；WAIT/BLOCKED 维持保护，不能伪造已观察完成。

`MONITOR_STOP_RECONCILED` 沿 `appendStrict` 七字段 schema1 信封，object=当前原 EXECUTION/同事务版本，actor=真实 SYSTEM、purpose=M07_EXECUTION_CONTROL，change.before=null、relatedRefs=[]、result=null。source_event_key=`M07:MONITOR_STOP_RECONCILED:<原MONITOR_EVIDENCE_RECEIVED eventId>`，change.after 精确为 `{schemaVersion:1,sourceEventId,sourceEventHash,registrationId,registrationHash,segmentId,protectionKey,requestKey,requestPayloadHash,stopIntentHash,commandId,state,physicalStopConfirmed:false,mergedAt}`，state 为 STOP_PREPARED/STOP_ALREADY_PENDING。ID用正十进制字符串、摘要为64位小写SHA-256、mergedAt保留原Instant；原件规范hash绑定整个信封。

停止回交仅使用原 RAW 的 STOP_REQUEST/STOP_RECEIPT；回执必须配对原请求，核 registration/完整 identity、保护键、请求键及 requestPayloadHash。receipt 的 ACCEPTED/LOCKED 等请求状态不转成物理STOPPED。原件、双登记ACK及当前资源/执行/段重验后，stop_intent、STOPPING、guard与必要STOP命令、归并marker同事务提交；任何冲突回滚。重复原件只返回原commandId，不重建意图/命令；marker重放也必须验证SYSTEM用途、原信封/源hash及原STOP完整参数/hash。缺已调用 START 或已确认 SET_SPEED 来源时可持久保护而不写完成marker，后续依原键重试；不把 PREPARED 当已执行。旧段/旧fence无当前控制权。

本归并按 M07StopIntentLifecycle.mergeOriginalFacts 合并原最早首次意图、全部原因及原期限：存在明确期限只保留/缩短，未知不得按 receivedAt 或补造核准时限。monitor profile 的时限来源与 execution 冻结 measurement profile 身份分别核对，不要求两者ID相同，也不互相替代。MONITOR_STOP_RECONCILED 是 LOCAL 内部业务归并证明，不进入 M09/M03 或采样投影白名单，不写认可量、COMPLETE覆盖或释放事实。

#### 2026-10-24 独立保护告警来源

`M07_INDEPENDENT_PROTECTION_ALARM` 是独立保护请求经过上述原身份、注册双ACK、完整资源和原请求核验后，在同一资源事务内通过 `appendLocal` 保存的六字段 schema1 信封。它与停止归并证明分开，不把 `MONITOR_STOP_RECONCILED` 当告警或实际停料回执。object、lab、culture、version、occurredAt 均沿原 `MONITOR_EVIDENCE_RECEIVED/STOP_REQUEST` 行；source key=`M07:M07_INDEPENDENT_PROTECTION_ALARM:<原STOP_REQUEST eventId>`。处理 STOP_RECEIPT 时使用已核对的配对请求，因此请求/回执重放不重复告警来源。

`result` 精确为 `{schemaVersion:1,sourceEventId,sourceEventHash,registrationHash,requestHash,physicalStopConfirmed:false,request}`；`request` 保留共享 StopRequest 原件及全部原因/各原因引用、摘要、发生时刻，`requestHash` 覆盖该规范原件。不得将回交时间替换原首次停止时间或期限。原停止保护始终按既有归并链处理；该告警事实不生成量账、停止确认、解除锁或恢复许可。

仅包含至少一项核准告警原因时产生该来源：NCS008/009/013/030/031/032、MONITOR_UNAVAILABLE、EXECUTION_PROGRESS_STALLED、START_UNCONFIRMED、TASK_START_DATE_VIOLATION、STOP_CONFIRMATION_TIMEOUT、UNEXPECTED_RESTART、STOP_BARRIER_FAILED、CALIBRATION_INVALID、SERVICE_HEALTH_FAILED、POST_STOP_FLOW_ABNORMAL、EVIDENCE_CONFLICT。这份名单仅定义交接能力，不证明每项已有设备事实生产者。仅正常终点、人工暂停或初次抖动观察不产生该告警。原件保留全部并发原因，M09摘要仅投影明确准入原因。

该来源进入既有 FEEDING_SAFETY_FACT 扫描及严格 codec，必须另有实验室＋该事件类型的核准 ruleKey 映射。缺项为 WAITING_MAPPING，不能借用其他事件映射。原 LOCAL 和唯一 PENDING/RETRY 子事实分开留存；M09持久收件ACK及幂等重放不表示真实通知成功。无新表或量账。

### 本次完善的版本与生产者边界

抖动观察原件记录一次真实结论，不能作为永久开泵许可。固定原触发窗口起点/J下的合格周期满足恢复判据，RECOVERY_ELIGIBLE即记录本次抖动已恢复；其他安全门禁满足时调度立即续补，不额外等待完整策略抖动观察期。最低安全观察、实际停料/量认可、完整覆盖、命令闭合及新段双ACK等仍逐项核验；尚未满足时保持保护并在最终准入实时重验，不能凭旧记录无条件开泵。合法续段重新建立本段窗口，不用旧起点/J判正常补料下降为“反弹”；撤销原反弹另待确认/重新计完整观察期的策略。未恢复而到期仍超原J且全期覆盖合格，才按持续异常报NCS030；缺覆盖不制造告警。原恢复/持续原件及hash保留，采用资格在原事务重验，不覆盖原结果或重置首次STOP期限。

完整独立异常上下文、校准窗口和自动恢复协调仍按[保护通道§15](独立补料监控进程与保护通道契约.md#15-生产证据缺口及当前开发边界2026-10-21)分项补生产链。独立指标角色/首反馈已接独立固定摘要文件与Monitor/Main，采用下述命名EVIDENCE，不向旧Registration/CommandParameters/M09固定JSON添键或改旧hash；配置支持不等于M07跨设备样本投影或物理覆盖COMPLETE，字段/类存在也不等于现场核准。

## 2026-10-21：独立监控首反馈原件

沿FEED-SAFETY-V1既有`EvidenceRecord`，外层schemaVersion=1、kind=`FIRST_RUNNING_FEEDBACK_QUALIFIED`、registrationId/完整identity为原登记、recordedAt=原qualifiedAt、bodyHash为完整body的UTF-8 SHA-256。body封闭字段为`{schemaVersion:1,registrationHash,policyHash,observationHash,feedbackAnchor,runningObservedAt,qualifiedAt,qualification}`；三个hash均64位小写SHA-256，qualification为原核准Proof，时间保留完整Instant。registrationHash与observationHash分别绑定完整规范Registration/Observation；policyHash绑定独立批准文件的完整原字节，不复用M07配置schema3或样本身份版本。

独立进程先可靠保存原Observation，再追加此EVIDENCE后才确认首反馈；失败保持未确认并保护。feedbackAnchor为原可信实际开始或合法新段registeredAt，不能用收到事实/日志落盘/HTTP调用时间替代；runningObservedAt必须来自所绑定实际反馈原样本，且不早于锚点；qualifiedAt不早于原样本且不得晚于原首反馈期限。新段不复制旧段证明。

重放必须核原登记/完整identity、原文件hash、原Observation及其所有所需读数、核准有效期和原qualifiedAt；不合格只使此反馈证明无效并保留保护，不能跳过后续原STOP/receipt或重置首次停止期限。原文件变更不得重解释旧证明。既有导出链及`MONITOR_EVIDENCE_RECEIVED`可以保留完整原件，但localCoverageComplete、收到该证明或其本地持久化均不授予M07物理采样覆盖、认可量、STOP确认、资源释放或恢复权限；不新增M09事实白名单、不新增表。

M07停止覆盖遍历可以保留窗口内的`FIRST_RUNNING_FEEDBACK_QUALIFIED`非采样原件，避免合法首反馈留证阻塞紧随其后的停止收尾。此处严格核封闭结构及摘要、同一原登记、此前已独立通过M07采样资格的完整Observation、原首启或续段registeredAt锚点、原采样时间和首反馈期限；复用FEED-SAFETY协议编解码，不改原报文字节。policyHash与qualification仍是独立监控的来源声明，本处不重新核准独立批准文件、不据其建立实际运行或实际停止资格，也不贡献样本数量或覆盖时长。各Observation的正式资格、实际STOP、完整观察及释放门禁分别核验；坏质量、缺覆盖和未知事实仍拒绝。


## 2026-10-23：续段握手首锁与恢复扫描职责复核

`M07ContinuationRegistrationStore` 的 prepare/acknowledge/requireActivationEligible/activated 是短事务，网络仍在事务外。其共用 `M07ContinuationRegistrationAccess` 在任何 runtime/task/execution/segment 锁前取得真实 `sys_management_revision(SYSTEM) FOR UPDATE`，SYSTEM 行缺失即拒绝，实际基线 revision=0 合法但不得伪造。最终调用仍复用原 `M07_COMMAND_INVOCATION` 能力及完整资源、命令、双 ACK/激活门禁；握手留证不自行递增管理版本，不构成新的物理写权限。

`selectPreparedWorkflowCommands` 归属 `RunWorkflowExecutionMapper` 的 M07 工作流窄读投影，按原 W03/小试供液步骤、PREPARED、START/STOP、游标和 LIMIT 筛选；`RunCommandMapper` 继续只访问 run_command。扫描只返回原 commandId，不加行锁、不创建命令、不处理 UNKNOWN，实际派发仍在原受控事务中重验。

本次登记仅对应既有生产入口：run_execution（固定任务准备/工作流执行）、run_execution_sample（原采样写口）、run_generation（任务生成幂等评估，不生产 connection_generation）、执行器整组交接及其成员、开始培养会话/步骤访问/成员/回执。检测用途 Query 的 labId 为有权限和范围校验的输入，不是培养归属输出。来源恢复和开始培养五个管理操作沿已有守卫、权限及审计链；所有登记保持逐文件/逐语句精确闭合，不授予新增设备能力，不修改表结构、停止期限、计量或释放条件。验证结果单独记录，不以静态登记替代 SQL、设备或现场验收。

### 2026-10-23 准备来源与覆盖投影增补

不增表列。原LOCAL事件`M07_FIXED_TASK_PREPARED.change.after`追加`preparationEvidence`，精确键为`schemaVersion:1,baseline:string,baselineCapturedAt:Instant,baselineOldestObservedAt:Instant,supplyIdentity:SessionIdentity,supplyInput:Input`。后两者为原W−R准入事实束，包含原会话/版本/袋身份、预填充、残余量、比较政策、原称重来源及有效时间；不包含执行结果。启动前Authority核原事件信封、摘要、SYSTEM/M07_RESOURCE_CLAIM来源和当前原对象。旧事件缺束不得补造后启动。

新增LOCAL事件`M07_OBSERVATION_COVERAGE_UPDATED`，对象EXECUTION，result精确顶层键`schemaVersion:1,coverage:CoverageEvidence v1,sourceFacts:object`；sourceFacts保存registrationHash、stopCommandId、stopResultHash、observationPolicyReference/Hash、qualifiedSamples及连续journal原件索引。事件身份取result规范化SHA256，与当前OPEN段observation_coverage的CAS同事务。保留原CoverageEvidence v1叶子、首次停止期限和唯一量账约束。

覆盖重放先重新验证当前原件及完整来源，再按严格解码后的CoverageEvidence比较当前投影；MySQL JSON的对象键序和格式空白变化不代表覆盖事实变化，不重复写入同一事件。事实比较不得替代原件重验，不接受未知字段、损坏原件或推算的未来覆盖；覆盖范围、状态、问题、原身份或来源摘要变化时仍须执行原CAS及事件事务。

### 2026-10-23：同袋恢复供料原件

既有 `M07_CONTINUATION_ELIGIBLE` 的外层事件及 `ContinuationRequest` 保持原版本；仅 `result.sourceFacts.schemaVersion=2` 在原 v1 完整键集（适用时含 `jitterRecovery`）上增加必填 `supplyAdmission`。该内层原件精确键为 `schemaVersion:1,input,readings,recognizedGrams,endpointRemainingGrams`。`input` 是经核准的 `M07SupplyAdmissionPolicy.Input`，含原会话/版本/物料身份、明确比较依据、原预填充和袋残余量、当前 W 及完整来源 Proof；`readings` 是本次 M02 `Facts`（读数集合、配置版本、秤键及固定 capturedAt）。十进制采用文本，时间保留原始精度；不借数据库 JSON 数值或毫秒投影重新生成原始读数。后两项是原唯一量账的累计认可投影和本次终点剩余量，不建立第二套余额。

原事务先创建新段及 PREPARED 命令，再持久化该原件，最后才 CAS 清除旧暂停投影。原件完整规范化摘要进入原 eligibility Proof，旧 STOP、完整观察、FEED 及命令闭合依据一起保留。接收续段上下文只接受 v1 原键集或 v2 明确扩展，不把未知版本、缺字段或任意附加键静默兼容。FIXED 激活及最终派发须从原事件取回 v2 供料快照、核验原摘要并在同一锁事务重验当前来源有效期、称重新鲜度、物料版本、认可量和新段基准；旧 FIXED v1 没有供料原件，不能据旧 ACK 或激活记录放行。STRATEGY 原契约不借此次 FIXED 扩展获得任何新权限。

基线Reading沿M02正式十进制字符串契约生产rawValue/value和normalization.tareGrams/precisionGrams，null仍为null。不得以起终归一化格式差异为由放宽原件匹配。M02数据库DECIMAL末尾补零可精确去除后用于W−R数值校验，不舍入有效小数，不改原始基线和证据摘要。

### 2026-10-23：续段上下文事务可见性与解析复用

`M07MonitorContextStore.continuation` 与 `progress` 使用独立入口的 `READ_COMMITTED` 短事务。定位原命令/执行的非锁定读可能先于 runtime 首锁；等待首锁期间已提交的原上下文 PUBLISHED 状态及精确 LOCAL ACK，必须在获锁后重新读取可见。Spring REQUIRED 加入既有事务时不会改变其隔离级别，因此入口明确拒绝未知隔离级别或 REPEATABLE_READ 外层事务，不默默沿用旧快照，也不把原 ACK 缺失当成成功。原业务锁序、完整历史来源校验、唯一量账及设备网络调用在事务外的边界保持不变。

续段可复用同一 Store 运行进度路径已严格解析的上下文前缀；复用条件是本次重新读取的原行完整身份、原始 payload 字节、摘要、时间及发布状态指纹完全一致。每次仍读取全部前序上下文、各自原来源及各自精确 LOCAL ACK，核对同实验室/培养/对象/版本、原登记/身份、完整版本链和不可变策略。来源/ACK 完整原行指纹、批准 monitor 身份及向前时钟均相同时，才可复用已经完成的解析校验；缺原件、变化、回滚后不同前缀或时钟回退必须重新严格校验或拒绝。缓存最多保留 64 个登记，不产生新的事实权威，不省略 ACK，不授予恢复、启动、计量认可或资源释放权限。

前序来源与 ACK 在同一原事务中按完整链的精确 source eventId、request eventId 分别批量读取，避免逐版本数据库往返；空 ID 集合不得变为全表读取。返回行按原 eventId 或精确 ACK sourceEventKey 关联，重复、意外行、缺原来源或缺已发布版本的 ACK 均拒绝，不按返回顺序配对。完整身份、payload、摘要、发布时间状态及原链校验不因批量化省略，链连接可复用同一已严格解码对象计算的 contextHash。

末版仍待 ACK 时，所有原件与链校验通过后，可在现有有限解析缓存中保留其前方已发布、已完成来源和 ACK 校验的不可变前缀及长度；末版不获得已认可标记。原事务退出或回滚不赋予该缓存授权。下一事务仍完整重读当前链、来源和 ACK，仅当相同长度前缀的全部原行指纹、monitor 身份及向前时钟均匹配时复用该前缀的校验计算；新尾段、变化前缀或回滚后缺行按原规则冷验或拒绝。该缓存不改变任何登记时刻、保护间隔、首次停止期限或进度事实。

隔离验证分别记录单元、真实 MySQL 提交/回滚及并发测试。历史原件只读校验耗时用于定位实现开销，不能作为完整恢复、设备或现场验收通过的证明；保护进度与首次停止期限不因性能优化而放宽。

### 2026-10-23：续段前最后一份未回执上下文的精确补交接

暂停期间的真实停止观察可能在续段握手前提交最后一份上下文，而其独立监控回执仍在传输中。`M07MonitorContextStore.continuation` 在原身份锁事务中重新读取并严格核对完整前段链、每份来源和已发布版本的精确 LOCAL ACK；仅最后一份原行处于 PENDING/RETRY 且全部原件校验通过时，才以专用结果携带该已提交原行退出并回滚当前事务。不得把中间未回执版本、PUBLISHED 但缺 ACK、身份不符、原件篡改或断链当作这一可补交接分支。

`M07MonitorContextOutbox.ensureContinuation` 只对该精确末版执行一次事务外重放，发送原 payload、取得真实独立监控回执，再经原 Store 持久化精确 ACK。之后重新进入原续段事务，重验全部当前事实，才允许生成新段上下文；既有并发 ACK 按同一原请求幂等核对。若重验时出现另一份未回执末版、事实变化或网络失败，本次继续失败并留给原 PREPARED 命令扫描重试，不无界循环，不造 ACK，不忽略新末版，不在锁事务中调用 HTTP。该补交接不生成新的业务意图、量账、启动或释放权限，首次停止期限及原保护要求保持不变。

### 2026-10-23 异常AUTO子任务参数一致性

沿现有task_spec与candidate.afterSnapshot结构，不新增表或字段。ERROR_SUPPLEMENT服务端生成来源仍为`creationSource={schemaVersion:1,kind:ERROR_SUPPLEMENT,sourceTaskId,handlingId,originalRequestId,actorUserId}`；源task与handling身份可追溯，原任务不可改写。子任务calculationType固定AMOUNT，amountGrams=targetGrams=本次核准正整数额外量，percentValue/concentrationRule/ruleId为null；materialSessionId/currentCalculationId为null，待独立准入和EXECUTE计算产生。速度采用本次申请，原方案来源及计划日保留并独立检查，不能继承原执行开始事实、owner或fence。候选摘要覆盖完整修正后的子TaskSpec；审批仍走M06_SC009。


2026-10-24真实窗口确认：新M07 trigger schema2与独立JITTER_TRIGGER_EVIDENCE schema2均保留真实start/end；实际跨度达到配置周期，按真实时长计算原J。重放需验证其是原样本集中不晚于终点减周期的最近合格起点、原身份和完整覆盖。旧schema1继续要求原精确周期，不能静默按新规则重解释。抖动观察原件仍保存真实observedThrough，不制造整秒点、未来覆盖或自动恢复许可；不存在新增量账或新增表。

### M07-010 异常处理的审计对象与原回执（2026-10-24）

异常处理管理写的 `outcome.id` 是原任务 ID，`affectedIds` 仅包含原任务及本次实际新增的 AUTO 子任务（至多一个）。handling、量账和计算 ID 是领域关联身份，不得混入受影响任务集合。M07-010 显式登记 `OUTCOME_AFFECTED_IDS`：before 必须恰为原任务，after 必须与该受影响任务集合完全相等；原任务记 UPDATE，AUTO 子任务记 INSERT，新增对象不得伪造 before。仅本操作补充审计白名单 `actual_grams`，用于保留原认可量与确认量。通用单对象、其他批量及权限校验不变。

`M07_TASK_EXCEPTION_HANDLED` 在原管理事务内，以既有 schemaVersion=1 事件信封的 `result` 保存完整 ActionResult。原请求重放从原 sourceEventKey 读取该不可变回执，核对管理守卫的可信操作者、任务身份、版本、事件摘要、信封和受影响任务集合；不重新创建子任务或量账，不按 ID 排序猜测 handling/child 身份。旧事件缺少精确 result 时明确阻断重放，不推算成功。事件原有 change、handling 和 child 关联保持。此变更不新增表或列。

#### 2026-10-24 启动登记能力拒绝告警

`MONITOR_REGISTRATION_REJECTED` 是 SYSTEM/EXECUTION 的 LOCAL 原件，采用既有六字段 envelope；object 绑定原执行及其当前版本。result schemaVersion=1，固定字段为 schemaVersion、taskId、executionId、segmentId、commandId、commandPayloadHash、registrationHash、gatewayInstanceId、capabilityEvidence。各 ID 使用正整数字符串，摘要使用原规范 SHA-256；source_event_key 为 `M07:MONITOR_REGISTRATION_REJECTED:<canonical(result)的SHA-256>`。occurredAt 保留网关 evidence.evaluatedAt，不以入库时间改写。

capabilityEvidence 为共享严格版本原件，绑定原 registrationId/identity/registrationHash/evaluatedAt、原因 DEVICE_STOP_CAPABILITY_UNVERIFIED、精确 defect（STOP_APPROVAL_MISSING、STOP_APPROVAL_NOT_YET_VALID 或 STOP_APPROVAL_EXPIRED）、mappingSource 及适用的 approvalSource。由经认证且验签的网关409响应收取，再在原任务/执行/段/命令锁内复核；普通HTTP失败、未签名拒绝、其他业务拒绝不得冒充此原因。此原件不代表实际开泵、实际停料、计量确认或资源释放。

原件可经原 FeedingSafetyFactProducer/outbox/M09 持久收件交接，仍需要该实验室+MONITOR_REGISTRATION_REJECTED 的明确核准映射。缺映射只延期LOCAL交接，不造默认通知规则。启动前拒绝后的任务退回及NOT_SENT收尾，须遵守原命令未调用与完整控制权交接规则；不能借告警写入伪造STOPPED或FEED。

## 2026-10-24 M03 免审方案来源交接

M03 DIRECT 应用回执新增 schema2 + directDecision，审批/Q31原schema1不改。M07不新增量账或状态机；只从 M03 当前回调原件读取新方案/代次/摘要和事实，管理守卫与资源事务不得并存。原资源链与精确补液候选管理链分别核验实际上下文，SYSTEM 生成用途的审计引用仍关联原 M03 决定；不能把回调标记当物理设备反馈。后台重放需 M03 完整核对 schema2 原件，不把 JSON存在或approvalId=null当作免审通过。物理表结构不变；字段和摘要见 M03同日正式契约。

## 2026-10-24启动前未调用撤回与NOT_SENT释放原件

本节落实已确认的“启动前停料能力明确拒绝、全部原件证明从未开泵后撤回并返回 READY”。所有事件沿用 `run_event`，不新增表或列，不形成第二套量账。除专用 outbox 外均为既有六字段 SYSTEM/LOCAL 信封；ID 为正整数字符串，摘要为规范 SHA-256，未知字段和缺失字段均拒绝。

| 事件 | 对象与 result 固定字段 | 原件及事务要求 |
| --- | --- | --- |
| MONITOR_NOT_SENT_WITHDRAWAL_REQUESTED | COMMAND；`{schemaVersion:1,commandId,commandPayloadHash,withdrawalHash,withdrawal,gatewayInstanceId,monitorInstanceId}` | 原 registration 请求已持久化、原 typed refusal 合格、START 未调用；冻结同一 withdrawal，不因重试刷新 requestedAt |
| MONITOR_NOT_SENT_WITHDRAWAL_ACKNOWLEDGED | COMMAND；`{schemaVersion:1,commandId,commandPayloadHash,withdrawalHash,gateway,monitor}` | 两端独立持久撤回收据均绑定同 registration/identity/withdrawalHash，endpointId 精确匹配，withdrawn/noInvocation 均明确 true；真实 completedAt 不得晚于受控收取时刻 |
| M07_RESOURCE_RELEASED 的 NOT_SENT 分支 | EXECUTION；`{schemaVersion:2,releaseBasis:"NOT_SENT",ownerKind:"EXECUTION",ownerId,executionId,sourceEventId,sourceEventHash,segmentId,executionSpecHash,commandId,commandPayloadHash,withdrawalHash,releasedResources,releaseEvidenceByResource}` | sourceEventId/sourceEventHash 精确指向上述撤回双 ACK；完整资源 group 的原 fence 与版本逐项复核；H06 与 task/segment 收口同事务 |
| M07_START_NOT_SENT_WITHDRAWN | COMMAND；`{schemaVersion:1,commandId,commandPayloadHash,executionId,taskId,releaseEventId,withdrawalHash}` | 精确绑定原 PREPARED/attempt_count=0 命令、原 H06 释放及撤回请求；不能使其他 PREPARED/UNKNOWN 免于核对 |

COMMAND 三类原件的 source_event_key 为 `M07:<eventType>:sha256(commandId+"|"+commandPayloadHash)`，object_version 沿原命令版本。NOT_SENT 释放来源键为 `M07:M07_RESOURCE_RELEASED:<withdrawalAckEventId>`，对象版本沿原执行；`releasedResources` 每项固定为 `{resourceKey,fence,objectVersion}`，`releaseEvidenceByResource` 使用既有九键 NOT_SENT 证据，不扩写 guard.release_evidence。

NOT_SENT 释放的 change.before 固定为 `{ownerKind:"EXECUTION",ownerId,physicalStatesByResource}`；after 固定为 `{ownerKind:null,physicalState:"FREE",releaseEvidencePresent:true,releaseReason:"NOT_SENT",stopEvidenceRefPresent:false,fenceRetained}`。资源键集必须与原登记、冻结 executionSpec 及原 claim 集完全相同。所有释放证据生成后才读取本次受控释放时刻，不能将后生成证据冒充该时刻之前已核准。持久 DATETIME(3) 投影比较按其毫秒精度，原 JSON 真实时刻不改写。

该分支的专用 outbox 使用：

```text
{schemaVersion:2,eventType:"MONITOR_RELEASE_HANDOFF",
 release:Snapshot,registration:Snapshot,withdrawalRequest:Snapshot,
 withdrawalAcknowledgement:Snapshot,request:ReleaseRequest}
```

Snapshot 沿既有完整原事件快照格式。出站 source_event_key 仍为 `MONITOR_RELEASE_HANDOFF:<releaseEventId>`；原 H06 提交后才能生产，网关 `/release`、监控 `/release` 均确认后才写既有 schema1 `MONITOR_RELEASE_ACKNOWLEDGED`。ReleaseRequest 使用 NOT_SENT，stopConfirmed=false，notSentEvidence 精确引用 `M07:NOT_SENT_WITHDRAWAL:<commandId>`、原撤回事件版本及 withdrawalHash。其余交接布尔值来自“无调用、无计量债务、已完成本地 H06”的事实，不代表虚构观察或结算。该 outbox 不附 settlement；实际停止分支原 schema1、真实停止/覆盖/结算校验完全保留。

H06 本地状态：task 保留 admitted=1，转 READY，current_execution_id=NULL，reason=DEVICE_STOP_CAPABILITY_UNVERIFIED，版本递增；原 execution 仍 NOT_STARTED/NONE，原 START 仍 PREPARED/attempt_count=0，原空段 CLOSED/active_milliseconds=0。无 first_start_evidence、stopped_at、终量、观察覆盖、FEED 或 SETTLE。资源释放、空段关闭、task CAS、原 H06 与 disposition 同事务；失败整笔回滚。外部撤回墓碑不回滚，重放使用原请求，不能重新激活旧尝试。

后续 attempt 只在旧撤回、原 H06 和最终释放双 ACK 完整时核准；连续 attempt_no 递增，不覆盖历史。新任务版本须重新获得自身核准配置。后续正常/异常/取消收尾中，旧 CLOSED 空段只有完整退役证明且无任何运行、停止、覆盖或量账事实时才属于未运行历史。缺证明、身份冲突、UNKNOWN 或时序未知继续阻断。

### 独立网关只读释放取证（2026-10-25）

`M07ReleaseEvidenceService`仅读取现有原件，不新增表、量账或run_event写schema。`RunEventMapper.selectReleaseEvidenceOriginal(eventId)`为无FOR UPDATE的纯SELECT，限定LOCAL的H06释放、SETTLE、原登记／双ACK、续段登记／双ACK和NOT_SENT撤回／双ACK事件；`selectMonitorReleaseBySourceKey`读取原冻结handoff。服务在REQUIRES_NEW、READ_ONLY、REPEATABLE_READ事务内比较handoff嵌入的每项Snapshot与真实已提交原行完全一致，并复用原codec重验来源、资源全集、fence、版本及全部原请求。原件缺失、不匹配或事务读取失败不产生取证成功。

正常停止与NOT_SENT仍使用上述各自原schema；只读取证不能把schema2的撤回材料补成schema1 SETTLE。返回的取证回执不持久化为新的H06或业务批准，不确认外部已释放，也不代替现有MONITOR_RELEASE_ACKNOWLEDGED双端交接。详细传输鉴权、部署参数及客户安装消费见《M02受控补料写入口部署契约》的只读释放取证小节。

### 2026-10-25 已确认：续段三方交接完成进度

用户确认：已持久化、精确绑定原续段命令的三方交接完成事实，可以作为一次独立监控控制进度证据。此证据只证明该交接步骤已完成，不证明设备实际运行、实际补量、实际停料或恢复已完成；不放宽采样、计量、首反馈、首次停止期限或资源释放要求，不解除既有保护、故障锁及人工暂停／取消。

1. 来源仅为原 `MONITOR_CONTINUATION_ACTIVATED` 本地不可变事件。须同时核验同一原 `MONITOR_CONTINUATION_REQUESTED`、网关／监控持久双ACK、网关ACTIVATED收据及原命令ID／请求摘要／execution／segment／fence／资源／配置与实例。仅有准备、受理或MONITOR_READY不能形成此进度。
2. 复用 `MONITOR_PROGRESS_HANDOFF` 及 schema2 原件封装，不新增量账、表、任务状态或原因码。source和activation均指同一ACTIVATED原件；registration／acknowledgement保留原请求与双ACK，firstStartEvidence必须为null。原outbox对象保持ACTIVATED来源的COMMAND及原命令身份。
3. ProgressUpdate.sequence使用原ACTIVATED事件ID，occurredAt使用该事件真实持久发生时间，proof绑定该原件摘要；不以发送、重试、重启或ACK时刻改写。该事件发生前的原登记、首次开始及首次反馈锚点保持不变。迟到进度不能清除已触发的保护或延后首次停止期限。
4. 调用顺序：原上下文持久ACK、原双登记ACK及实际ACTIVATED收据持久提交后，M07调用原进度outbox针对该事件可靠投递；保留原初始续段上下文及其ACK，追加精确绑定原ACTIVATED事件的一份上下文修订，延续原哈希链；原计量、策略、STARTING命令及未取得实际反馈的事实保持不变，controlledAt使用原事件时间，不创建采样或运行窗口。取得该修订的独立持久ACK后再投递进度；重放使用同一原修订和时间，不刷新进度时间。取得并持久保存匹配进度收据后，才继续原M02正常写入口的最终命令门禁。无发布方、原件不符、网络／DB结果未知、ACK缺失或冲突都保留原PREPARED命令待核对，不先发SET_SPEED。
5. 投递在业务事务外；出箱与ACK各自使用原事务、摘要及CAS，重放只使用同一原件和幂等键。若另一消费者已持久完成，须核对原ACK、原请求摘要和原outbox身份才能认可，不凭PUBLISHED字符串通过。后台扫描继续补偿原进度出箱，不补造激活来源。
6. 后续真正的采样控制评估、实际运行反馈、异常监控及停止观察仍走原合格来源。交接进度不代替它们，也不能作为心跳循环续报。独立监控仍按原核准最大控制间隔保护；超过实际能力的运行延迟另作性能／部署验证，不能通过延长参数或伪造进度隐藏。

本条为用户确认的安全证据边界，不是客户接口能力确认。代码及各层测试记录见原开发计划本轮回归，不代表真实设备或现场验收通过。

续段交接可复用同一进程已经逐项验证的上下文原件与持久ACK解析结果。每次仍重读请求、原来源和LOCAL ACK，按完整原文与身份／scope／hash／时间／发布状态核对；任一变化、缺件、缺段、重复或外来原件、回滚后不匹配、时钟回退都不能借缓存通过，必须重新核验或保持阻断。缓存只减少重复解析，不替代DB中的真实提交或独立回执，不作为控制进度，不延长任何安全期限。

### 2026-10-26 交接并发与原件读取性能

ACTIVATED上下文生产使用READ_COMMITTED，按培养运行、任务、执行、分段、原命令的既有锁序串行重验原身份后登记，防止同步恢复与后台补偿重复插入同一不可变来源。网络调用仍在该事务外。同步发布遇到并发失败时，只可重读同一outbox及已持久原ACK，完整核验原身份、摘要和typed receipt；缺失或冲突仍阻断，不凭PUBLISHED字符串放行。

续段登记Store的prepare、acknowledge、requireActivationEligible及activated四个独立事务同样使用READ_COMMITTED。入口在SYSTEM锁之前的只读定位不能使等待者继续使用旧的一致性快照；取得既有锁后必须看到前一持有者已经提交的REQUEST、双ACK和ACTIVATED原件，并完整校验后幂等返回。不能吞掉唯一键冲突后伪造成功，也不允许新建请求绕过原命令。最终调用事务、供料核验、保护锁及三方交接条件不因该隔离级别修正而放宽。

普通任务的阶段SET_SPEED也须在物理调用前完成原SPEED_PREPARED进度及上下文交接。只读定位必须得到唯一LOCAL控制事件，精确绑定新命令ID；沿原progress outbox发布并核对原上下文ACK及typed ProgressReceipt，缺件、重复来源、冲突或未知结果均不得调用设备。重放只能确认同一原outbox及原ACK，不换身份、时间或命令。

该进度将独立监控的命令阶段临时置为STARTING并清除旧运行窗口锚点，保留原已核实命令身份及全部目标、计量、策略参数；这只是“切速后阶段尚未确认”，不是任务重新开始，也不声称新命令已执行。新命令的合格实际反馈形成原PHASE_CONFIRMED后，才建立新命令和新阶段窗口。切换期间原目标超量、反馈质量、控制进度期限及必要停止继续有效，不把旧高速理论量套在已降速读数上，也不将该进度当作可循环续报的心跳。

run_event新增idx_m07_event_type_scope(event_type,publish_state,object_kind,object_id)。它只优化原件检索，不筛除未知来源、不修改采样资格、唯一性、覆盖范围、首次期限或量账规则。字段字典、目标DDL、开发基线及来源摘要同步；隔离新库仍按01/02/03安装，未对共享库执行DDL。

### 2026-10-26 用户已确认：明确上一段的调用前原件允许继续检查后包

窄分支及全部资格条件见[业务观测采样与告警交接](业务观测采样与告警交接.md)同名条目。仅在既有ingestion.blockers中返回诊断字符串 CONTINUATION_PRECALL_OBSERVATION_PENDING，继续保留QUALIFICATION_INVALID、OLDER_OBSERVATION_PENDING及OBSERVATION_COVERAGE_UNQUALIFIED；不是新增NCS原因码、任务状态、表、字段或第二套量账。

原件仍以原registrationHash、journal position、entryHash及原正文保存在run_event，每次重放重新读取并核验原命令、登记与双ACK。不为该分类写MONITOR_SAMPLE_EXCLUDED或MONITOR_SAMPLE_PROJECTED，原件不能从停止覆盖链中消失。后包只经正式资格生产者及唯一采样Port生成原投影回执。DB错误继续回滚原件、投影及游标ACK事务；typed运输收据或诊断分类均不证明实际停止、完整覆盖或释放。


### 2026-10-26 工作流 v1 受控停止覆盖

工作流 v1 可在原完整 execution_spec 中固化可选 `observationPolicy`，其自身 schemaVersion=1；不改变任务 v2 资格，也不宣称原始采样身份 v3 已支持。该对象来自核准的 M02 execution_profile_json，随完整 spec_hash 固化，不能由页面或收尾器临时补造。缺少该策略的历史 v1 不自动补参数或生成 COMPLETE。

策略精确字段为 `schemaVersion,reference,maximumGapMillis,maximumCaptureDelayMillis,maximumSkewMillis,metrics`。最大间隔为正整数毫秒，接收延迟及角色时间偏差为非负整数毫秒，全部须明确核准，无默认值。metrics 精确包含 FEEDING_MASS 与 ACTUAL_SPEED 两个角色；每项精确字段为 `role,deviceKind,deviceId,labId,metricCode,unit,source,sourceRevision,configurationRevision`。称重单位为 g，实际泵反馈单位必须与原 measurementPolicy.stop.speedUnit 相同；命令设定、ACK及健康接口不能替代实际泵角色。客户映射、各时间参数及逐设备取值仍待配置、接口及现场核验。

受控首段 start_readings 保留原形状并增加 `workflowMeteringFact:{factId,factHash}`，feeding.source 使用与不可变首次事实 sourceInstanceId 一致的核准来源，事实身份不再占用 Reading.source；历史前缀 M02_WORKFLOW_METERING_FACT 仍只读兼容，不改历史数据。运行读数经 M02 正式 DeviceReadingsPort 获取，按冻结设备、实验室、指标、配置及来源核验；v1 样本仍为 schemaVersion=1，新增 observationPolicyHash，保存完整真实称重与实际泵角色。不得把轮询次数当作采样序号，也不得把段累计 activeMilliseconds 解释成真实设备计时器。

收取在事务外执行，受控样本写入前依次重锁 runtime、workflow、execution、全部 segment 并核对原 spec_hash/fence/worker。完整载荷摘要相同才幂等；同来源身份但摘要不同，保留 SAMPLE_CONFLICT，并持久 BAD 的观测失败标记。读数失败标记仅记录本地失败事实，readings为空、feedingScaleGrams为空，不伪装物理测量；缺失/坏质量/冲突阻断覆盖，不被后续好读数静默抹掉。

停止结算事务从原 STOP 与本段所有原件重新生成 CoverageEvidence v1，经既有 writeObservationCoverage 对 OPEN/current segment、执行版本及 fence CAS 写 observation_coverage，并同事务追加 LOCAL 的 M07_WORKFLOW_OBSERVATION_COVERAGE_UPDATED，引用样本ID及原件摘要。完整输入摘要沿用共享 rawEvidenceHash，覆盖原STOP和全部样本。证明的起终点取各核准角色真实时间交集，检查 STOP 锚点、逐流严格前进、序号重复、缺口、接收延迟、时间偏差及尾部陈旧；不插值、不推算未来覆盖。覆盖只证明观测完整，实际停料、稳定窗口和计量仍由共享停止组装及校验器独立核实。

PRIME 沿用原 run_ledger 及原唯一来源键，无第二套量账。measurementEvidence.source 指向 EXECUTION_SEGMENT，readings 精确保存该段起点和最终稳定读数；source.contentHash 覆盖 startReadings、endReadings、stopEvidence、observationCoverage。endReadings.capturedAt 保存最后合格读数的原 observedAt，而非停泵时刻。覆盖、停止结算、物料消耗、唯一PRIME及本地事件在同一原事务；任一CAS/写入失败整体回滚，资源释放仍走H06完整资格。
