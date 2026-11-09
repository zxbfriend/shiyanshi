# S03 现行设计纠偏 · work1 第一批文档纠偏处置记录

- 日期：2026-11-03
- 范围：统一汇总 DOC-02—DOC-05 中「已有证据能够直接消解」的文档问题
- 处置子项：**共 12 项**（DOC-02 三项、DOC-03 四项、DOC-04 三项、DOC-05 两项）。四项为统一汇总的业务分组，12 为实际处置子项数，两者一一对应，无合并、无拆分。
- 性质：**文档纠偏**。只更正现行说明，不做接口验收，不新增业务决策题，不宣布 S03 通过
- 仓库：`D:\Code\zhixianweilai\yaoming-cloud`　起止 HEAD：`0fdf8612796f3503a9f04d63d186e6b4b9deaad4`（未变）

## 一、依据与判定口径

依据文件（相对本记录目录）：

- [统一汇总与设计余项.md](../2026-11-03-S03汇总/00-统一汇总与设计余项.md)（DOC-02—DOC-05 条目）
- [03-矛盾清单与共享文档逐行建议.md](../2026-11-03-S03并行对齐/work2-工作流与批次/03-矛盾清单与共享文档逐行建议.md)
- 主线复审：`docs/history/2026-11-02-S03主线复审/` 下 09、12、13、15、16、17 号
- 当前源码：仅做完成文档纠偏所需的**最小复核**（确认类、方法、分支、响应或字段来源）

判定口径：

1. 需求／有效澄清能确定的，按需求写；只有源码现状而无需求依据的，只写「当前实现事实」，并显式标注未验证层级。
2. 机制（锁、守卫、回执、租约、fence 等）不升格为客户规则；设计写过的机制不反过来要求业务补实现。
3. 未验证 ≠ 缺失、停用或阻塞；无前端调用 ≠ 接口停用。
4. 模拟成功、固定拒绝、停用、部分接线、运行未验证分别表述，不合并成「已完成」。
5. 历史段落保留原貌，更正以「现状订正」段就地追加，不全量重写历史行号。

## 二、逐项处置（12 项，全部 DOC-02—DOC-05 授权子项）

### DOC-02　过期实现定位

**DOC-02-①　定位032「仅缺语句／待接线」旧段**

- 位置：[接口目录与契约定位.md](../../../07-补液运行与任务执行/接口目录与契约定位.md) 定位032 补充段（032.1／032.2 两条）；[物理接口与骨架字段设计.md](../../../07-补液运行与任务执行/物理接口与骨架字段设计.md) API32 段
- 旧表述：「接口与 XML 已存在，仅缺语句」；「032.2（移交写）等运维范围权威判定到货后再接」；API32 段「在此之前 API32.2 不得接线，API32.1 只读列表可先行」
- 新表述：三处各加一段现状订正——032.1 的 `selectAssignments` Mapper 方法与 XML 语句**当前均已存在**；032.2 移交写**已接**管理守卫事务、锁内权威重验与逐行 CAS，缺 M02 权威证据时失败关闭；原排期句保留为历史登记并标注不再反映当前源码
- 依据：`RunExecutorAssignmentMapper#selectAssignments` 与 `RunExecutorAssignmentMapper.xml` 的 `selectAssignments` 语句；`RunExecutorAssignmentController#transferExecutorAssignment` → `RunExecutorAssignmentApplicationApplicationService#transferExecutorAssignment`

**DOC-02-②　W02 批次详情仍归属旧 Controller**

- 位置：[接口目录与契约定位.md](../../../07-补液运行与任务执行/接口目录与契约定位.md) M07 路由表「GET /run/workflow-batches/{batchId}」行；[Controller请求调用时序设计.md](../../../07-补液运行与任务执行/Controller请求调用时序设计.md) 第 3 步
- 旧表述：「PilotReplacementBatchController → PilotReplacementBatchService.getBatch」（读口直接归属 W02 旧控制器）
- 新表述：两处均加归属订正——该读口当前由 `WorkflowBatchQueryController` → `WorkflowBatchQueryService.getBatch` 统一入口按持久归属分派（开始培养 → W08 → W03 → W02 兜底）；**W02 分支**才是 `PilotReplacementBatchService.getBatch`，`PilotReplacementBatchController` 当前只承载 W02 的 `/steps` 与 `/cancel` 两条写路由，不再承载批次详情读
- 依据：`WorkflowBatchQueryService#getBatch` 的**前三路归属判断**（开始培养 → W08 → W03），W02 为兜底分支、不再执行第四次归属判断；`PilotReplacementBatchController` 现存路由

**DOC-02-③　SC 段旧 wired／移交说明与当前说明矛盾**

- 位置：[接口目录与契约定位.md](../../../07-补液运行与任务执行/接口目录与契约定位.md)「开始培养专项增补（SC-20261017）」段；[开始培养工作流详细设计.md](../../../07-补液运行与任务执行/开始培养工作流详细设计.md) §7 开头句
- 旧表述：「新口机器台账/DTO/SQL/SDK仍待SC-00/01实施，不将本段计为wired」；「后续机器台账登记为新增 planned/disabled/unwired 后才能接线」
- 新表述：两处各加现状订正——SC-HTTP02／03／04 由 `StartCultureSessionController` 承载，SC-HTTP01 与 SC-HTTP05 分别由 `WorkflowBatchQueryController` 与 `RunWorkflowController#startCultureSession` 承载，SDK `packages/sdk-smp-api/src/start-culture.ts` 已有对应封装；同时写明本订正**只更正「是否已接线」这一状态，不表示开始培养已验收通过**，目标数据库、HTTP、浏览器与设备联调均未验证
- 依据：三个 Controller 的 `@RequestMapping`／`@PostMapping`／`@GetMapping` 路由；SDK `start-culture.ts` 五个请求封装

### DOC-03　已有契约内部表述

**DOC-03-①　任务修改入口「直接生效或审批」与申请链不一致**

- 位置：[接口目录与契约定位.md](../../../07-补液运行与任务执行/接口目录与契约定位.md) 定位006 的 `M07-API06` 行
- 旧表述：「允许修改字段+WriteMeta→candidate/审批或直接生效」
- 新表述：改为「允许修改字段+reason（去空白1—500字）+WriteMeta→candidate/真实审批，审批前不生效」，并指向 [任务页面与接口契约.md](../../../07-补液运行与任务执行/任务页面与接口契约.md)「2026-10-26 运行任务修改必须说明原因并审批」段为该口径的**唯一权威处**（该段已写明 reason 校验、SC001/SC005 须由 M06 真实政策判到 APPROVAL、DIRECT／DIRECT_REASON／BYPASS_Q31 或缺失政策返回 POLICY_UNVERIFIED、审批前旧参数保持）
- 依据：需求澄清决策记录 Q31（审批口径做成实验室流程设置可配置项）；任务页面与接口契约.md 同名节；`M07TaskChangeService#change` 的 `requireReason` 与 `requireApproval` 调用；`RuntimeChangeApprovalRequirement.requireApproval` 非 APPROVAL 抛 POLICY_UNVERIFIED；`ApprovalPolicyRoute` 值域
- 处理说明：接口目录**不再复述细则**，只作摘要与指向，避免形成第二处口径

**DOC-03-②　026 动作串名与拒绝分支登记错误**

- 位置：[开始培养工作流详细设计.md](../../../07-补液运行与任务执行/开始培养工作流详细设计.md) M07-026 行；[接口目录与契约定位.md](../../../07-补液运行与任务执行/接口目录与契约定位.md) `M07-API26` 行；[任务页面与接口契约.md](../../../07-补液运行与任务执行/任务页面与接口契约.md) `M07-API26` 行与「2026-10-21 W01模拟响应与动作」段的 026 句
- 旧表述：「action=SAMPLE_PRIME_START/SAMPLE_PRIME_STOP」；接口目录「operation:SET_AUTO/PRIME_START/PRIME_STOP」（漏 SET_MANUAL）；`SET_AUTO` **笼统写为固定拒绝** `CONFIGURATION_INCOMPLETE`
- 新表述：分两层更正。**动作词层**——本口当前实现的 operation 字面量为 `SET_MANUAL`／`SET_AUTO`／`PRIME_START`／`PRIME_STOP`，不存在 `SAMPLE_PRIME_START`／`SAMPLE_PRIME_STOP`；该词表是**入口支持的联合词表**，不表示每种工作流都可使用全部动作，具体适用分支另按专题。**拒绝范围层**——`SET_AUTO` 的拒绝按分派层次限定：(a) 开始培养实例走同一路由时在 Controller 层固定拒绝 `CONFIGURATION_INCOMPLETE`（SC-Q04／SC-Q09 取样预填充与 OPC 重启协议待确认），不生成命令意图、不发设备命令；(b) 逻辑 W07、W03 模拟与 W02 中试模拟各自只接受 `PRIME_START`／`PRIME_STOP`，不提供 `SET_AUTO`，仅 W01 模拟接受；(c) 继续落入普通实机路径的实例，先校验 pumpRef 与设备命令／派发依赖可用性，之后才由 `SET_AUTO` 拒绝 `CONFIGURATION_INCOMPLETE`，该路径其他失败可能返回 `INPUT_INVALID`／`DEPENDENCY_UNAVAILABLE`，不承诺一律返回该码。202 只表示意图受理，不表示设备动作完成；模拟分支返回 `state=SIMULATED`／`executionMode=SIMULATION` 同样不代表真实设备执行
- 依据：`RunWorkflowApplicationApplicationServiceImpl#operateWorkflow` 的分派顺序（`SET_MANUAL` → 结束培养模式 → 词表校验 → W08 拒 → 逻辑 W07 → W03 模拟 → 中试/W01 模拟 → 普通实机路径 → `SET_AUTO` 拒绝）；`RunWorkflowController#operateWorkflow` 的 `startCulture.owns(id)` 拒绝；`W07LogicalChannelExecutionService#operateWorkflow` 与 `BenchConnectionBatchService#operateSimulation` 各只接受 `PRIME_START`／`PRIME_STOP`；`PilotWorkflowSimulationService#operationLocked` 接受 `SET_AUTO`；`PilotReplacementSimulationService#operationLocked` 只接受 `PRIME_START`／`PRIME_STOP`
- 辨析：同文件 §固定步骤表的 `SAMPLE_PRIME` 是**步骤码**（START → INOCULATION → SAMPLE_PRIME → DEVICE_CONFIRM），与本次 operation 字面量无关，未改动；开始培养页面的 `SIMULATE_PRIME_START`／`SIMULATE_PRIME_STOP`／`SIMULATE_CONFIRM` 属 SC 步进动作词表，与本口 operation 不是同一套，保留说明

**DOC-03-③　027 返回状态形态登记错误**

- 位置：[开始培养工作流详细设计.md](../../../07-补液运行与任务执行/开始培养工作流详细设计.md) M07-027 行；[接口目录与契约定位.md](../../../07-补液运行与任务执行/接口目录与契约定位.md) `M07-API27` 行
- 旧表述：「→interactionState、pendingCommands、restartRequired」；「未闭合返回 202，安全完成返回 200」
- 新表述：订正为本口当前响应为 `ActionResult`（`requestId`／`objectId`=工作流ID／`objectVersion`／`state`／`applicationState`／`issues`／`relatedIds`），**不按 202／200 区分状态**，也**无 `pendingCommands` 字段**；会话侧投影另见专题 §7
- 依据：`RunWorkflowApplicationApplicationServiceImpl#cancelWorkflow` 返回体装配
- 辨析：同文件候选读口与 `StartCandidate` DTO 中的 `restartRequired` 属**候选读取字段**，与本口响应无关，未改动

**DOC-03-④　SC 回执字段、状态描述超出当前投影**

- 位置：[开始培养工作流详细设计.md](../../../07-补液运行与任务执行/开始培养工作流详细设计.md) SC-HTTP04 行；同文件 §6 状态语义段
- 旧表述：「requestState=NOT_FOUND/PENDING/APPLIED/REJECTED/UNKNOWN」（五态）
- 新表述：订正为本口当前 `requestState` **只产出 `UNKNOWN` 与 `APPLIED` 两态**——按 (actor, requestId) 查不到回执行返回 `requestState=UNKNOWN`、`workflowIds=[]`、`reasonCode=ORIGINAL_REQUEST_NOT_SETTLED`（缺失不证明原写未执行，不得据此授权新的 COMPLETE）；查到回执返回 `APPLIED` 并带 `pageSessionId`／`workflowIds`／`batchId`／`pageSession`。§6 段的客户端处置规则**保留为语义规则**，同时标注当前实现只产出这两态
- 依据：`StartCultureApplicationService#receipt`；`StartCultureWorkflowMapper.xml#findReceipt`（按 actor 与 requestId 查 `run_start_culture_receipt`）

### DOC-04　W03 连接批次契约

**DOC-04-①　补齐已定位的 LIVE cancel 分支契约**

- 位置：[任务页面与接口契约.md](../../../07-补液运行与任务执行/任务页面与接口契约.md) W03 批次接口表 cancel 行
- 旧表述：cancel 行只写模拟语义（「保留历史装量和模拟启停记录」），实机分支无描述
- 新表述：cancel 行加分支说明（按批次根行冻结的 `selection_snapshot.executionMode` 分派，请求体不参与分派），并新增「2026-11-03 W03 实机草稿取消分支（LIVE）」节，登记**已定位**的实机分支行为：活动成员的当前及后续未完成步骤与实例转 `CANCELLED`／`NONE`、写同一可信 `endedAt`、留下 `closure.executionMode="LIVE"`、`kind="CANCELLED"`、`skipped=false`、`skipReason=null` 与操作者身份；**取消是业务登记，不代表设备已停**，本口不派发设备命令；四项物理历史前置（执行／命令／未决占用／物料会话）须全部为空，这是「尚未产生物理事实」的必要条件，不等于已具备真实设备联调；已移除成员只交 workflow 及其版本、不得提交步骤字段；本节只登记分支行为，运行、数据库、浏览器与设备联调**均未验证**
- 依据：`BenchConnectionLiveCancelService`（分派条件、`closure` 写入、四项 `count*` 前置校验、已移除成员步骤字段校验）

**DOC-04-②　统一 confirm 两种 rows 形态的说明位置**

- 位置：[任务页面与接口契约.md](../../../07-补液运行与任务执行/任务页面与接口契约.md) 顶部概述句；同文件「W03 整批装量确认（P05）」段
- 旧表述：顶部只写逻辑通道形态（`channelId`／`slotCode`），P05 段只写实体瓶形态（`bottleId`／`resourceKey`），两处分散易被读成互斥
- 新表述：顶部概述改为「按成员类型提交装量确认」并指向 P05 段；P05 段声明为**本口唯一权威描述**，给出两形态对照表（逻辑通道成员／实体瓶成员各自的 rows 元素与覆盖校验），并写明同一行混用两套键即拒绝、确认只完成业务连接确认步骤、不写正式连接、不产生设备动作
- 依据：`BenchConnectionBatchService` 的 confirm 成员分型与装量校验

**DOC-04-③　保留 complete 的模拟边界**

- 位置：[任务页面与接口契约.md](../../../07-补液运行与任务执行/任务页面与接口契约.md) W03 批次接口表 complete 行；同页「模拟终态不写…」段
- 旧表述：只写「仅PRIME_READY」「普通COMPLETE支持部分泵做过模拟预填充」，未说明适用范围；补记写成「完成结果是模拟终态登记，**不写正式连接标志**」，同页旧段亦笼统写「模拟终态不写正式连接标志」
- 新表述：加订正——本口**只服务冻结为 `SIMULATION` 的批次**，实机批次不走本口。完成结果**按成员类型区分**：非取消且属于逻辑通道成员（`feedUnitMode=CONTROLLER_CHANNEL`）时保存**培养运行中的业务连接关联**，并按对应实现把 `applicationState` 标为 `APPLIED`；其余成员只做终态登记（`applicationState=NONE`），不写业务连接关联。共同边界：完成证据仍标 `executionMode=SIMULATION`、`simulated=true`，`commandIds`／`materialSessionIds`／`ledgerIds` 均为空，不产生设备命令、物料会话或物料账，也不写 FIRST_WORKFLOW_STARTED 与计划生成事件。**业务连接关联不等于真实设备连接已验证**：现场写入能力依赖 `FIELD_WRITER_CAPABILITY` 仍为 `UNVERIFIED`，不得据 `APPLIED` 声称现场写入能力或物理动作成功。同页旧段的笼统表述同步改为按成员类型区分，并把「正式连接」这一含混词换为「业务连接关联」／「最终业务连接关联」
- 依据：`BenchConnectionBatchService#finalizeSimulation` 的 `applyConnection = !cancel && isLogicalUnit(row)` 分支（逻辑成员走 `saveBusinessConnection`＋`completeLogicalConnection`，其余走 `closeWorkflow`）、`saveBusinessConnection`（写连接运行关联，依赖项 `FIELD_WRITER_CAPABILITY` 置 `UNVERIFIED`）、`completionEvidence`（`simulated=true`，`commandIds`／`materialSessionIds`／`ledgerIds` 空数组）、`isLogicalUnit`（`feedUnitMode=CONTROLLER_CHANNEL`）；`BenchConnectionBatchService#confirm` 的注释「No M02 writes, material session, ledger or device command」
- 未改：`confirm` 段的「不写最终业务连接关联」边界（仅统一术语，未改语义）；`cancel` 路径的 `applyConnection` 恒为 false，不套用 complete 的业务连接保存结论；本页头部 2026-11-01 用户确认口径原文保留未改写。（本条「complete 只服务 SIMULATION 批次」与「完成证据恒标 simulated」两点，已因代码更新按 §七 订正。）

### DOC-05　适用范围纠偏

**DOC-05-①　room-options 白名单旧表述与后续扩展统一**

- 位置：[接口目录与契约定位.md](../../../07-补液运行与任务执行/接口目录与契约定位.md) 房间选项登记段；[任务页面与接口契约.md](../../../07-补液运行与任务执行/任务页面与接口契约.md) room-options 行
- 旧表述：接口目录「W01/W02可用」；任务页面「subflowCode为W01或W02」
- 新表述：接口目录加订正——上句是 2026-10-21 的当时范围，后续两处设计各新增一个子流程且**均未撤销前者**（2026-10-23 中试结束培养 `end_culture_pilot`、2026-10-26 小试结束培养 `end_cell_culture_small`）；任务页面行改为列全四个码并注明其余子流程拒绝
- 依据：`PilotWorkflowRoomOptionService#list` 白名单四项
- 未改：中试／小试结束培养契约两处原已按各自子流程码登记，核对后与源码一致，无需改动

**DOC-05-②　「不要求前端改交互」例外只能覆盖两个模拟人工停止端点**

- 位置：[小试结束培养接口契约.md](../../../07-补液运行与任务执行/小试结束培养接口契约.md) 末段
- 旧表述：「不要求现有前端新增页面或修改交互」（紧接在两句总结之后，句义易被读成覆盖整表）
- 新表述：加订正——该句的主语是上表**末两行**（模拟人工停稳状态、模拟人工停稳确认），仅覆盖这两口；上表前四口（批次详情、整页推进/最终完成/取消/移除、异常原因及送审/免审完成、常用异常结束原因）**没有逐口的「不要求前端」表述**，其页面用途与逐口前端范围属**未核**；专题头部「前端页面和交互本轮不改」是 2026-10-26 的本轮开发范围声明（与接口目录「只开发中试W01与结束培养后端，前端设计/交互不改」同类），不得读成上述四口永久不需要前端，也不得由零页面引用反推这四口已停用
- 依据：原文句主语结构（紧邻两句针对末两行）；接口目录同类范围声明

## 三、未处理与未核项

| 项 | 状态 | 原因（精确） | 归属 |
| --- | --- | --- | --- |
| API27 各分支的物理事实前提与「设备动作后安全取消」当前可用范围 | 未核（NOT_VERIFIED） | 已确认 W01 实机分支为 `PilotWorkflowDraftCancelService`，其拒绝语义为「仅未推进且无任何物理动作或资源占用的W01草稿允许此取消」，与任务页面 §2026-10-21 的 W01 范围表述一致，故该句未改动；判定 API27 在 W06／W02／W05／中试结束培养／W07 逻辑通道各分支的可取消范围须做设备链与幂等深审，超出本批授权 | M07 专题 owner（S04 前） |
| DOC-01 共享统计（60口表合计、AND/OR、W03 四口与新增原因选项） | 未承接 | 统一汇总明示由主 agent 管理 | 主 agent |
| DOC-06 查询字段固定 null、计算摘要/日志面不足、相关字段契约不完整 | 未承接 | 本批范围限于 DOC-02—DOC-05 | M07 专题 owner |
| DES-01—DES-06 | 未承接 | 本批只做 DOC-02—DOC-05 的文档纠偏 | 后续批次 |
| 开始培养目标数据库／HTTP／浏览器／设备联调 | NOT_VERIFIED | 本批未启动服务、未连库、未发 HTTP、未开浏览器、未操作设备 | S04 |
| 各订正段中「已接线」的运行有效性 | NOT_VERIFIED | 只做了静态源码核对，未做运行层验证；不得据本记录称接口完成或验收通过 | S04 |
| 定位032 移交写的 M02 权威判定来源 | 待接 | 源码在缺权威证据时失败关闭，但权威判定方与口径属 M02 范围，本批不核 | M02 owner |

## 四、自检

### 第一轮：逐项对照证据回读

- 只处理授权子项：DOC-02 三项、DOC-03 四项、DOC-04 三项、DOC-05 两项，**共 12 项**，全部落在统一汇总 DOC-02—DOC-05 的授权条目内；DOC-01、DOC-06、DES 类未触碰。
- 是否改变原有业务含义：未改需求侧语义。需求／有效澄清能定的（Q31 审批口径）按需求写；只有源码现状的写成「当前实现事实」并标未验证层级。
- 是否把机制或源码现状误写为需求：未。锁、守卫、逐行 CAS、`requireApproval` 等一律写在「依据」列而非契约条款列；契约列只写接口行为。
- 模拟成功是否被误写为设备成功：未。complete 明确「只服务冻结为 SIMULATION 的批次」，且其业务连接关联只对逻辑通道成员成立、现场写入能力依赖仍为 `UNVERIFIED`、完成证据仍为 `simulated=true`；LIVE 取消明确「是业务登记，不代表设备已停，本口不派发设备命令」；模拟停稳两口明确「不代表读到了真实停稳信号」。
- 入口与专题是否仍有矛盾：已逐处对齐——批次详情（接口目录 ↔ 时序设计）、API06（接口目录 ↔ 任务页面 §2026-10-26）、room-options（接口目录 ↔ 任务页面 ↔ 中试契约 ↔ 小试契约）、026／027／SC-HTTP04（接口目录 ↔ 开始培养专题 ↔ 任务页面）。定向返修后 026 的 SET_AUTO 分层表述在三处（接口目录 `M07-API26`、开始培养专题 M07-026、任务页面 `M07-API26`）一致。
- 定向返修专项核对：`SET_AUTO` 是否按分派范围描述——是，已按 Controller 拒绝／模拟分支／普通实机路径三层分开，未把实机路径拒绝外推为整路由固定拒绝；联合动作词表是否被误写成所有分支均可用——否，已写明「不表示每种工作流都可使用全部动作，具体适用分支另按专题」；逻辑成员业务连接保存是否准确——是，按 `applyConnection` 分支区分；是否仍把模拟 APPLIED 理解为设备成功——否，已写明 `FIELD_WRITER_CAPABILITY` 仍为 `UNVERIFIED`、`simulated=true`、不得据 `APPLIED` 声称现场写入能力或物理动作成功；complete、confirm、cancel 是否分清——是，complete 区分成员类型、confirm 仅确认装量不写最终业务连接、cancel 路径不套用 complete 结论；本页旧句与新句是否仍矛盾——已消除，原「模拟终态不写正式连接标志」泛化句已改为按成员类型区分。

### 第二轮：交付检查

- 文档链接与表格：见下方实际计数。
- 空白错误：第一次 `git diff --check` 在接口目录报出 3 处 trailing whitespace（本批改写的 M07-API06／API26／API27 三行沿用了该文件既有的行尾空格写法），已把这 3 行行尾空格清除；复跑 `git diff --check` 无输出、退出码 `0`。该文件含行尾空格的行数由 HEAD 的 28 行降为 25 行，未新增。
- 摘要、正文与处置表一致：本记录第二列的「旧表述／新表述」与现行文件实际文本逐条比对一致；订正标记日期统一为 2026-11-03（初稿曾误写 2026-11-04，已全部改正）。**处置子项计数在标题、摘要、逐项处置与自检四处一致，均为 12 项**（DOC-02 三项、DOC-03 四项、DOC-04 三项、DOC-05 两项）。
- 残留模板占位、错误计数、旧结论：已全量检索 07 专题现行文件的 `SAMPLE_PRIME_START`／`SAMPLE_PRIME_STOP`、`pendingCommands`／`restartRequired`、`仅缺语句`／`待接线`／`不得接线`、`审批或直接生效`、`不将本段计为wired`；命中的剩余项逐处确认为**引用的历史原句或刻意保留的否定式说明**，无一处仍作现行结论。
- 并发：HEAD 起止均为 `0fdf8612796f3503a9f04d63d186e6b4b9deaad4`，期间无他人提交触及本批目标文件；07 专题目录下另有他人在途新增未跟踪文件（`history/review/2026-11-01-源码路由对齐登记.md`、`取样取消复制与原调度事件交付契约.md`、`各类任务与批量新增交付契约.md`），本批未触碰、未覆盖；同目录下另见他人产物 `work2-DOC06查询字段补正.md`，本批未触碰。

检查命令与实际计数（读实际计数，未只看退出码）：

```
node temp/work1/s03/check-doc.mjs \
  "docs/详细设计/07-补液运行与任务执行/接口目录与契约定位.md" \
  "docs/详细设计/07-补液运行与任务执行/开始培养工作流详细设计.md" \
  "docs/详细设计/07-补液运行与任务执行/任务页面与接口契约.md" \
  "docs/详细设计/07-补液运行与任务执行/Controller请求调用时序设计.md" \
  "docs/详细设计/07-补液运行与任务执行/小试结束培养接口契约.md" \
  "docs/详细设计/07-补液运行与任务执行/物理接口与骨架字段设计.md" \
  "docs/history/review/2026-11-03-S03现行设计纠偏/work1-第一批文档纠偏.md"
```

实际执行记录：

1. 首跑（6 个修改文件，不含本记录）：`FILES=6 BAD_LINKS=0 BAD_TABLE_ROWS=0`，退出码 `0`。
2. 次跑（含本记录共 7 份）：`FILES=7 BAD_LINKS=21 BAD_TABLE_ROWS=0`，退出码 `0`。**该次报出 21 条坏链**——本记录的相对路径层级多算了一级（记录位于 `docs/history/review/2026-11-03-S03现行设计纠偏/`，到 `docs/详细设计/...` 应为三级而非四级，到汇总目录应为一级而非两级）。已逐条改正路径层级。
3. 复跑（7 份）：`FILES=7 BAD_LINKS=0 BAD_TABLE_ROWS=0`，退出码 `0`。
4. 定向返修后复跑（同一 7 份，命令不变）：`FILES=7 BAD_LINKS=0 BAD_TABLE_ROWS=0`，退出码 `0`；`git diff --check -- "docs/详细设计/07-补液运行与任务执行/"` 无输出、退出码 `0`。

**该脚本在 `BAD_LINKS>0` 时退出码仍为 0**，故上述计数均以实际输出为准，未以退出码代替判定。

## 五、声明

- 未改业务代码、测试、前端、SQL、配置、源码注释、客户原件、需求副本、AGENTS.md、记忆文件、主 agent 的统一汇总与 65 口快照、阶段覆盖表、章节覆盖明细、阶段计划、work2 产物及其他 agent 在途文件。
- 未启动服务、未编译、未运行测试、未连接数据库、未执行 SQL、未发送 HTTP、未打开浏览器、未操作设备；未暂存、未提交、未推送、未创建 PR；未另派子 agent。
- 本批为文档纠偏，**不增加「已完成接口」数量**，不构成接口验收结论。

## 六、定向返修处置表（2026-11-03第二轮，依据主线复审 `主线复审-work1第一批.md`）

| 复审编号 | 修改章节 | 最终表述 | 依据 | 保留边界 |
| --- | --- | --- | --- | --- |
| W1-01 | 接口目录 `M07-API26` 行；开始培养专题 M07-026 行；任务页面 `M07-API26` 行与「2026-10-21 W01模拟响应与动作」段 026 句；本记录 DOC-03-② | operation 为**入口联合词表** `SET_MANUAL`／`SET_AUTO`／`PRIME_START`／`PRIME_STOP`，不表示每种工作流都可使用全部动作，具体适用分支另按专题。`SET_AUTO` 按三层分派限定：(a) 开始培养实例在 Controller 层固定拒绝 `CONFIGURATION_INCOMPLETE`（SC-Q04／SC-Q09）；(b) 逻辑 W07、W03 模拟、W02 中试模拟各只接受 `PRIME_START`／`PRIME_STOP`，仅 W01 模拟接受 `SET_AUTO`；(c) 落入普通实机路径者先校验 pumpRef 与设备命令／派发依赖可用性，再由 `SET_AUTO` 拒绝 `CONFIGURATION_INCOMPLETE`，其他失败可能为 `INPUT_INVALID`／`DEPENDENCY_UNAVAILABLE`，不承诺一律返回该码。202 仅表示意图受理 | `RunWorkflowApplicationApplicationServiceImpl#operateWorkflow` 分派顺序；`RunWorkflowController#operateWorkflow` 的 `startCulture.owns(id)` 拒绝；`W07LogicalChannelExecutionService#operateWorkflow`；`BenchConnectionBatchService#operateSimulation`；`PilotWorkflowSimulationService#operationLocked`；`PilotReplacementSimulationService#operationLocked` | 未展开逻辑 W07 内部、全部模拟引擎或设备链；未新增业务规则；模拟不等于真实设备执行、202 不等于设备动作完成、SC 步进动作词与本口 operation 不是同一套，均保留 |
| W1-02 | 任务页面 complete 行；同页「模拟终态不写…」段；同页 026 模拟段、confirm 段与 rows 形态段的连接术语；本记录 DOC-04-③ | complete 仍**只服务冻结为 `SIMULATION` 的批次**。按成员类型区分：非取消且逻辑通道成员（`feedUnitMode=CONTROLLER_CHANNEL`）保存**培养运行中的业务连接关联**并标 `applicationState=APPLIED`；其余成员只做终态登记、`applicationState=NONE`、不写业务连接关联。共同边界：完成证据仍 `executionMode=SIMULATION`、`simulated=true`，`commandIds`／`materialSessionIds`／`ledgerIds` 为空，不产生设备命令、物料会话或物料账，不写 FIRST_WORKFLOW_STARTED 与计划生成事件。**业务连接关联不等于真实设备连接已验证**：`FIELD_WRITER_CAPABILITY` 仍为 `UNVERIFIED`，不得据 `APPLIED` 声称现场写入能力或物理动作成功。旧泛化句已同步改写 | `BenchConnectionBatchService#finalizeSimulation` 的 `applyConnection = !cancel && isLogicalUnit(row)`；`#saveBusinessConnection`；`#completionEvidence`；`#isLogicalUnit`；`#confirm` 注释 | confirm 边界未动（仅统一术语为「最终业务连接关联」）；cancel 路径 `applyConnection` 恒为 false，未套用 complete 结论；本页头部 2026-11-01 用户确认口径原文保留；未新增模拟规则、未改业务代码。（本行关于 complete 适用范围与 `simulated` 标记的两点，已因代码更新按 §七 订正；成员类型区分与 FIELD_WRITER_CAPABILITY 边界不变。）
| W1-03 | 本记录头部「处置子项」、§二 标题、§四 第一轮与第二轮自检 | 处置子项**共 12 项**（DOC-02 三项、DOC-03 四项、DOC-04 三项、DOC-05 两项）；四项为业务分组，12 为处置子项数，一一对应，未合并、未拆分 | 统一汇总 DOC-02—DOC-05 条目与本记录 §二 实际子项清单 | 原授权范围未变；未新增业务问题 |
| 文字修正 | 本记录 DOC-02-② 依据行 | 改为「`WorkflowBatchQueryService#getBatch` 的**前三路归属判断**（开始培养 → W08 → W03），W02 为兜底分支、不再执行第四次归属判断」 | `WorkflowBatchQueryService#getBatch` 当前实现 | 正文「开始培养 → W08 → W03 → W02 兜底」的正确说明保留；未重新核查全部批次分支 |

## 七、代码更新后的一致性订正（2026-11-03 第三轮）

触发：按「更新代码到最新版本」执行拉取，`cloud` 分支从 `0fdf8612796f3503a9f04d63d186e6b4b9deaad4` 快进到 `19a7bf9a450fd41a6fa4781f3d2bda757a7e0e27`（origin/cloud 的 15 个提交）。其中 `89c4a443d fix: 恢复小试补料连接完成记录`、`c63e96a14 feat: record bench feed unit connection operations`、`33e01f308 merge: integrate cloud and bench workflow changes` 改动了 `BenchConnectionBatchService`、`BenchConnectionBatchController` 与 `RunWorkflowApplicationApplicationServiceImpl`，**使本记录此前基于旧源码的三处表述失效**。以下为逐处订正；只改表述，不改业务语义，不新增业务规则。

| 编号 | 旧表述（已失效） | 新表述（合并后源码事实） | 依据 |
| --- | --- | --- | --- |
| C-01 | complete 口「只服务冻结为 `SIMULATION` 的批次，实机批次在本口固定被拒」 | complete 口只服务**记录模式**批次——旧模拟批次（冻结为 `SIMULATION`）或业务模式批次（逻辑通道成员且未冻结执行模式）；不属记录模式的批次在本口被拒。守卫码按是否旧模拟批次分派：旧模拟批次 `M07-025-W03-SIMULATION-FINISH`，业务模式 `M07-025-W03-FINISH` | `BenchConnectionBatchService#finalizeSimulation` 的 `isRecordedMode` 前置校验与 `legacySimulation` 守卫码分派；`#isRecordedMode`＝`isSimulation`∨`isBusinessMode`；`#isBusinessMode`＝批次∧逻辑通道成员∧执行模式为空 |
| C-02 | 完成证据「仍标 `executionMode=SIMULATION`、`simulated=true`」 | 完成证据的 `executionMode=SIMULATION` 与 `simulated=true` **只在旧模拟批次分支写入**；业务模式分支的完成证据不标 simulated。两分支共同边界仍为 `commandIds`／`materialSessionIds`／`ledgerIds` 空数组、`FIELD_WRITER_CAPABILITY=UNVERIFIED`、不产生设备命令/物料会话/物料账 | `#completionEvidence` 改为条件写入（`if("SIMULATION".equals(closure.executionMode))`）；`closure.executionMode` 改为按 `simulation` 条件写入 |
| C-03 | cancel 口「按批次原执行模式分派两条分支」 | cancel 口先判是否记录模式：记录模式走取消链（守卫码再按是否旧模拟批次分 `M07-027-W03-SIMULATION-CANCEL`／`M07-027-W03-CANCEL`），非记录模式（实机）走 `M07-027-W03-LIVE-CANCEL` 实机草稿取消；实机分支仍限全部成员为逻辑通道、无物理执行/命令/未决占用/物料会话，模拟批次误入实机分支被拒 | `BenchConnectionBatchController#cancel` → `BenchConnectionLiveCancelService#dispatch` 的 `isRecordedMode` 分派；`#cancel` 的实机守卫校验；`#finalizeSimulation` 的 cancel 守卫码分派 |
| C-04 | 026 措辞「W03 模拟」 | 026 的 W03 分支判定由 `isSimulation` 扩为 `isRecordedMode`（含业务模式批次），该分支仍只接受 `PRIME_START`／`PRIME_STOP`；三处登记同步改为「W03 记录模式」 | `RunWorkflowApplicationApplicationServiceImpl#operateWorkflow` 的 `benchConnectionBatches.isRecordedMode(benchMarker)` 分派；`BenchConnectionBatchService#operateSimulation` 的 operation 白名单 |

未受影响的既定结论（复核后保持原样）：`applyConnection = !cancel && isLogicalUnit(row)`、逻辑成员保存业务连接关联并标 `APPLIED`、其余成员终态登记 `NONE`、`isLogicalUnit`＝`feedUnitMode=CONTROLLER_CHANNEL`、`FIELD_WRITER_CAPABILITY=UNVERIFIED`、普通实机路径 `SET_AUTO` 仍在 pumpRef 与依赖可用性校验之后拒绝 `CONFIGURATION_INCOMPLETE`、各模拟分支的 operation 集合不变。

合并过程与可回溯性：

- 拉取前发现 6 个文件与远端变更重叠（4 个为本记录涉及的 07 专题，2 个为其他 agent 在途），已完整备份至 `temp/pull-20261103/backup/` 与 `temp/pull-20261103/local-changes.patch`（temp 目录已被 `.gitignore` 忽略）。
- 合并采用「先恢复重叠文件 → `git merge --ff-only origin/cloud` → `git apply --3way` 按 hunk 级三方重放本地改动」，6 个文件全部 **cleanly applied**，无冲突标记残留；暂存区已复位为 0，未提交、未推送。
- 合并前存在一个 5 小时未动的 0 字节 `.git/index.lock`（无 `git.exe` 进程），确认为陈旧锁后删除，未触碰其他 worktree（`C:/Users/micrown/.codex/worktrees/...`、`D:/Code/ff-cloud-20261022`、`D:/Code/zhixianweilai/yaoming-cloud-push-f2ae9fd06` 均未操作）。
- 本轮只改表述，未改业务代码、测试、前端、SQL、配置与源码注释；未启服务、未编译、未跑测试、未连库、未执行 SQL、未发 HTTP、未开浏览器、未操作设备。
