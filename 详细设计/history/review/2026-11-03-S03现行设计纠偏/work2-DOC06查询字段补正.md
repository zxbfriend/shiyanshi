# work2 · DOC-06 查询字段相关文档补正（2026-11-03）

> 本文件是 S03 汇总后 DOC-06 批的过程记录，不是现行契约。字段口径以第 8 节补丁建议经主 agent 合并进
> `docs/详细设计/07-补液运行与任务执行/` 现行专题后为准。本批只做文档与最小静态核对，未启服务、未编译、
> 未连库、未执行 SQL、未发 HTTP、未开浏览器、未操作设备，未暂存/提交/推送。

- 起止 HEAD：`0fdf86127`（开始与结束时一致，本批未产生提交）。
- 编辑归属结论：四个候选现行文件全部只出补丁建议，未直接修改（见第 1 节）。
- 本批五口：`GET /run/tasks/{id}`（M07-002）、`GET /run/tasks/{id}/executions`（M07-012）、
  `GET /run/tasks/{id}/logs`（M07-011）、`GET /run/executions/{id}`（M07-031）、
  `GET /run/executions/{id}/commands`（M07-014）。并行 20 口与异常处置三口只作为已有证据引用。

## 1. 复用依据与编辑归属判定

### 1.1 复用的已接受证据（不重做深度核验）

| 材料 | 用途 |
|---|---|
| `docs/history/2026-11-02-S03接口核验与纠偏/07-M07任务详情执行记录日志三口核验记录.md` | 002/012/011 已接受字段表、恒 null 登记、§9.3 D1—D4 差异、§14 三条设计纠偏建议 |
| `docs/history/2026-11-02-S03接口核验与纠偏/08-M07异常处置执行详情命令查询三口核验记录.md` | 031/014 已接受字段表、状态词表、§5.4／§6.4「不返回」清单、D5 childTaskId、D11 last_error、D13「设计未给字段表」 |
| `docs/history/review/2026-11-03-S03汇总/00-统一汇总与设计余项.md:37` | DOC-06 条目本身（查询字段固定 null、计算摘要/日志面不足、相关字段契约不完整） |
| `docs/history/2026-11-03-S03并行对齐/work1-任务与培养/20-口基础对齐清单与纠偏.md` | 已接受的 work1 结论（定位032 过期段属文档项、Controller 无注解不等于无鉴权） |

### 1.2 现行文件 git 状态、mtime 与并发核查（判定证据）

下表按两次快照分别记录，避免把 16:52 的观察当成 18:0x 的现状：

| 文件 | git 跟踪状态（实测） | 16:52 mtime | 18:0x mtime | 本批处置 |
|---|---|---|---|---|
| `任务页面与接口契约.md` | tracked（`git ls-files --error-unmatch` 通过；文件末次提交 `0cc980791`） | 14:12 且与 HEAD 一致 | **17:54，工作区 ` M`**（第三方/work1 并发编辑已落盘） | 只出补丁建议（维持） |
| `接口目录与契约定位.md` | tracked | 14:12 且与 HEAD 一致 | **18:01，工作区 ` M`** | 只出补丁建议（维持） |
| `物理接口与骨架字段设计.md` | tracked | 2026-10-23 11:06 | **17:54，工作区 ` M`** | 只出补丁建议（维持） |
| `设备命令契约.md` | tracked | 2026-11-02 17:55 | 2026-11-02 17:55（未变） | 只出补丁建议（维持） |

同目录另有 3 个未跟踪文件（`history/review/2026-11-01-源码路由对齐登记.md`、`取液取消复制与原调度事件交付契约.md`、
`各类任务与批量新增交付契约.md`），非本批产物，本批未触碰。

**原表述撤下（本轮第 2 轮自检发现的事实错误）**：第 1 轮正文写「`docs/详细设计/**` 全部处于未跟踪状态，因此无法用
git 区分 work1 的在途编辑」——**该前提不成立，已撤下**。上述四个文件都是 git 跟踪文件，16:52 时工作区内容与 HEAD
一致，git 当时就能证明「无人落笔」；当时的保守结论取自 mtime 核对，理由写错了但结论方向没错。

18:0x 复查证实保守结论是必要的：`git status --short -- docs/详细设计/07-补液运行与任务执行/` 现在有 6 个 ` M` 跟踪文件，
其中三个正是本批引用文件，编辑时间在 17:54—18:01（晚于本批第 1 轮写作）。若当时按「章节不同」直接改写现行文件，
现在就会与这批在途修改冲突。结论维持：现行文件零修改，全部补正文集中在第 8 节，标记「待主 agent 合并，尚未落盘」。

并发编辑对本批引用的影响（逐处复核结果，见 §1.3）：

- `任务页面与接口契约.md` 的 diff 只落在新行 15／35—47／80—89／127 四处（W03 连接批次的 complete/cancel/connect 段与
  room-options 行），字段字典与 API 表所在区域未被改写，只是整体下移 **+20 行**。
- `物理接口与骨架字段设计.md` 的 diff 只在 §4 权限补充（新行 114 附近，净 0 行），API31 行仍在 `:107`、原文未变。
- `接口目录与契约定位.md` 的 diff 为 7 处单行等量替换（58／85／144／293／299／347／399），净 0 行位移。
- 因此本批引用的**文字**未被并发修改推翻，只有**行号**需要重定位。

### 1.3 引用行号约定（本轮据并发变化重定位）

本记录指向 `任务页面与接口契约.md` 的行号，已在 2026-11-03 18:0x 快照按内容逐条重新定位（旧行号一律 +20），
并在引用处同时给出可在原文检索的**行名／语句名**（TaskView 行、Person 行、ConfirmationView 行、WriteMeta 行、
API02/API11/API12/API14/API31 行、「按规则补糖展示」段、`:396-403` startWithdrawal 语义表）。引用以名称为主、
行号为辅；主 agent 合并第 8 节补丁时，应按名称定位目标行，不要按本记录行号直接寻址——该文件仍在被并发编辑。

## 2. Work A：任务详情（M07-002）字段补正

响应类型 `domain.vo.m07.RunTaskDetailView`（`extends TaskView`，`+calculationSummary`、`+preExecutionWeightGrams`）。
赋值链：`RunTaskApplicationApplicationServiceImpl#getTask` → `selectTaskDetail`（`M07TaskQueryMapper.xml:109` 起的列清单）
→ `copyTaskView`（`:1438-1465`，24 个 setter）→ 详情再追加 4 项（`:350` safetyHandoff、`:353` startWithdrawal、
`:355` calculationSummary、`:356` preExecutionWeightGrams）。`TaskView` 声明 31 个字段：24 赋值 + 5 恒 null +
2 个共享声明（见 2.4）。

### 2.1 objectVersion 的真实来源（易误读项）

| 字段 | 类型/空值 | 含义 | 当前来源 | 与现行要求的关系 |
|---|---|---|---|---|
| `objectVersion` | string / 非 null（有行即有值） | 任务对象自身的版本号（十进制字符串），按对象乐观锁用于写请求体的 `expectedVersion` | `run_task.object_version`（`M07TaskQueryMapper.xml:109`，resultMap `:25`） | 它是**对象版本**，不是管理版本，也不是执行版本；三者区分见下面 2.1.1 |

补充事实：列表接口 `copyTaskView` 与详情共用同一赋值，`objectVersion` 在列表/详情同源；
`TaskLogView.objectVersion` 是 `run_event.object_version`（见 3.2），与任务对象版本不是同一轴；
`ExecutionDetailView` 内没有 `objectVersion` 字段。

#### 2.1.1 三类版本的区分（本批返修项一，撤下原「同源值」说法）

原表述「`objectVersion` 即页面发起守卫写时应回填的 `X-Management-Revision` 同源值」**错误，已撤下**。
现行契约把三个版本槽位分得很清楚：

| 版本 | 所在槽位 | 权威出处 | 当前源码事实 |
|---|---|---|---|
| 任务对象版本 | 响应 `TaskView.objectVersion`；写请求体 `expectedVersion` | `任务页面与接口契约.md:197`（WriteMeta 行：「expectedVersion在对象请求体」）、`:19`（M07-006 保留 expectedVersion 及 Header/WriteMeta 守卫） | CAS 条件为 `run_task.object_version = #{expectedVersion}`（`RunTaskMapper.xml:130/139/147/156/165/173`），与详情读出的 `objectVersion` 同源 |
| 管理守卫版本 | 读响应顶层 `managementRevision`；写请求头 `X-Management-Revision` | `任务页面与接口契约.md:197`；AGENTS.md §13.3（revision 必须来自当前页面对应列表/详情接口返回的顶层 `managementRevision`） | API001/002 的 Controller 带 `@CurrentManagementRevision`（`RunTaskController.java` 的 `pageTasks`/`getTask`），由响应外壳提供，不取自 `TaskView.objectVersion` |
| 执行对象版本 | 内部行字段 `current_execution_version`；对外未以 `objectVersion` 之名返回 | `M07TaskQueryMapper.xml` 的 `e.object_version AS current_execution_version`（列表/详情共用该投影） | 属执行行版本，不得当任务对象版本或管理版本使用；`ConfirmationView.objectVersion` 亦由 `:208`（ConfirmationView 行）明写「不是runtime或管理版本」 |

禁止事项：不得把对象版本当 `X-Management-Revision` 回填，也不得把顶层 `managementRevision` 当 `expectedVersion` 提交。
适用边界：上表只按任务详情/列表与其相关写口的现行契约表述，**不外推为所有接口的统一制式**——
其他对象（工作流步骤、培养运行、确认单、异常处理）各自的 expectedVersion 对照哪张表的版本列，以该接口自己的契约为准，本批未逐一核。

### 2.2 已登记的恒 null 字段（不等于业务不需要）

下表按三层分开表述，避免把源码注释当成现行契约裁决：**A 源码事实**（赋值链是否调用 setter、字段是否有来源、是否返回 null）、
**B 源码注释登记**（`RunTaskApplicationApplicationServiceImpl:111-131` 记录的实现者原因，只能证明「注释这么写」）、
**C 现行设计状态**（必须有现行契约或有效澄清直接证明才能写「契约未定义/未冻结」）。
「当前未赋值」是已证实事实，不因原因待确认而撤下；`AGENTS.md` §13.2/§10 口径：字段缺失属实现边界，
页面用 `labId`、「—」兜底只是展示处置，不消除契约缺口。

| 字段 | 类型/空值 | 含义 | A 源码事实 | B 注释登记的原因 | C 现行设计状态 |
|---|---|---|---|---|---|
| `labName` | string / 恒 null | 实验室名称展示事实 | `copyTaskView:1438-1465` 未调用该 setter，投影链无来源 | 注释 `:119-121` 登记为「跨模块展示事实，M02/M03 未提供冻结展示 Port」 | 设计要求列名（`:203` TaskView 行「labId/name」）。M02 自己的读口已把 `labName` 作为响应字段（`02-实验室与资源管理/实验室主数据逐接口契约.md:7/:27`），故不能据本批材料断言「现行契约未定义实验室名称」；M07 是否应内联该事实、走跨模块 Port 还是前端二次读取，本批未确认，属待主线核对 |
| `cultureCode` | string / 恒 null | 培养编号展示事实 | 同上，无赋值点 | 注释 `:119-121` 同一句登记 | 设计要求列名；另有一条可确认的源码事实：作为筛选参数传值时按 `DEPENDENCY_UNAVAILABLE`(503) 失败关闭，不静默忽略条件（同注释段） |
| `reactorCode` | string / 恒 null | 反应器编号展示事实 | 无赋值点 | 注释 `:119-121` 同一句登记（反应器事实属 M03 域） | 设计要求列名；`reactorCode` 一词在 M07 现行专题另见 `工作流与页面操作设计.md`，但该处是操作侧引用，未构成任务详情的取数来源，本批不据此判定契约已定或未定 |
| `reactorRef` | string / 恒 null | 反应器身份引用 | 无赋值点 | 注释 `:119-121` 同一句登记 | 设计要求列名（`:203` TaskView 行「reactorRef/code」）；不因页面未消费即视为不要求 |
| `applyState` | string / 恒 null | 审批决定交付后的业务生效态 | 无赋值点；`approvalId` 有值（当前活动候选行 `approval_id`） | 注释 `:114` 登记为「其取值词表在契约中未冻结」 | **注释的该句与现行材料不一致，本批已查实**：总体设计对 applyState 给了五种取值（`00-统一详细设计主文档.md:524/:733/:976`：PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN），M07 任务专题未引用或改写该词表。故不能写「契约未冻结」；准确表述是「M07 专题未指定该字段在本口的取值来源与映射，源码因此未赋值」。是否直接套用总体词表属主线核对，本批不新建客户题、也不断言必须新增机制 |
| `creator.displayName`、`modifier.displayName` | string / 恒 null | 人员显示名 | `person(...)` 装配（`:1529` 注释）只填 userId 与 kind，displayName 无来源 | 注释 `:122` 登记为「M01 显示名 Port 未冻结」 | 现行设计文面允许该字段为 null（`:204` Person 行「userId或null、displayName或null、kind:USER/SYSTEM；系统不填虚构0」），因此「恒 null」不违反设计文面；「M01 Port 未冻结」仅是注释登记，本批未审 M01 人员读口，不作为现行结论 |
| `baseState` | string / 非 null | 与设计并列的「基础态」 | `row.getBusinessState()`，与 `businessState` 同一来源（`:1448-1449`），两键恒等值 | 注释未单列该项 | 设计 `:203` TaskView 行同时列 `businessState`、`baseState`；两者是否要求独立语义，现行专题未给定义，本批不判定 |

### 2.3 calculationSummary：无计算时的结构与「声明/赋值」差

`CalculationApprovalSummary` 声明 13 个字段；`calculationSummary(row)`（`:1557-1588`）赋值 11 个；
`confirmationItem`、`confirmationCompletedAt` 全链无赋值点（源码事实）。类注释 `:128-129` 把原因登记为「快照子路径未冻结」；
本批在 M07 现行专题只检索到 `:168` 用中文要求展示「确认项目/时间」，未检索到该两项的字段名或快照子路径定义
（`confirmationItem` 一词在全 `docs/详细设计/**` 现行文件中零命中，历史目录除外）。因此「计算快照子路径未冻结」按注释登记保留，
不作为已确认的现行契约结论；两者是否等价，待主线按计算快照契约核对。

| 情形 | 当前返回形态 | 空值含义 |
|---|---|---|
| 任务无关联计算（`row.taskCalculationId == null`） | 返回**空对象**（非 null），13 个键全部为 null | 「没有计算事实」，不表示计算失败或计算被禁止 |
| 关联的计算行读不到（`selectCalculationById` 返回 null） | 同样返回空对象 | 「计算身份存在但行不可读」，与上一情形在响应内不可区分 |
| 计算行存在但快照解析失败 | 部分字段为 null（`readTree` 失败即跳过该分支） | 不表示原始 JSON 为空 |
| 有计算 | `calculationId`/`algorithmVersion`/`basisKind`/`basisGrams`/`preExecutionGrams`/`lowerOperator`/`lowerGl`/`targetGl`/`targetGrams`/`formulaCode`/`dayStartGrams` | 来源为 `run_calculation.input_snapshot`、`output_snapshot` 指定叶子；`dayStartGrams` 是 DAY_START 分支推演值，非直读列 |

设计要求但当前未返回（不得改写为「不返回即可满足需求」）：

| 要求出处 | 要求内容 | 当前状态 |
|---|---|---|
| `任务页面与接口契约.md:168`（「按规则补糖展示」段） | 按规则补糖展示「确认项目/时间」 | `confirmationItem`/`confirmationCompletedAt` 有键恒 null → 页面无法呈现，属已登记缺口 |
| `任务页面与接口契约.md:230`（API02 行「及精确计算/审批摘要」） | 审批摘要（**要求保留**） | 当前只有 `approvalId` 身份、`applyState` 有键不返回取值，无任何审批状态/结论字段 → 与「审批摘要」要求存在实差；归属沿用 `00-统一汇总与设计余项.md` 的 DOC-03 条目，更细 owner 待主线核对（见 §7 DOC06-D4） |
| `07-…md` §9.3 D2（已接受结论） | 摘要只装计算侧字段 | 与本批实测一致 |

数字纠偏：`07-M07任务详情执行记录日志三口核验记录.md` §4.4 记为「12 项」；本批按 VO 声明逐行数得 **13 个声明字段 / 11 个赋值 / 2 个从未赋值**。以本批实测为准，旧记录的 12 为口径差（未把某项计入），不改写旧文件，仅在此登记。

### 2.4 safetyHandoff 与 startWithdrawal 的职责边界（仅字段解释）

| 字段 | 类型/空值 | 含义 | 当前来源 | 与现行要求的关系 |
|---|---|---|---|---|
| `safetyHandoff` | `TaskSafetyHandoffView`（record，10 个组件）/ 当前详情**恒非 null** | 某次执行的释放与交接**历史证据投影**，不是设备准入 | `M07TaskHandoffProjection#evaluate`（`:17`，全部返回路径都产出对象；`getTask:350` 传入 `selectTaskHandoffEvents`） | 设计 `:205` TaskSafetyHandoffView 行已给全字段与「均为只读事实投影，不增加任务或资源状态」；`:215` 给六态语义 → 源码形状与设计同构 |
| `startWithdrawal` | `TaskStartWithdrawalView`（record，8 个组件）/ 可为 null | 一次**已核验的历史失败尝试**的撤回事实，不是新动作许可 | `M07TaskStartWithdrawalProjection#read`（`:16-33`） | 设计 `:396-403` 已给逐字段语义表 + `:405` 门禁说明 → 源码字段与设计一一对应 |

必须保留的读法（写进字段说明，防止误用）：

1. `startWithdrawal == null` 只表示「按 `M07_START_NOT_SENT_WITHDRAWN` 未定位到历史尝试」，不表示该任务从未启动失败；
   定位到但门禁不齐时返回的是 `verificationState=UNKNOWN` + `issues=[START_WITHDRAWAL_EVIDENCE_UNVERIFIED]`（`:34`），
   身份字段（executionId/attemptNo/commandId/safetyHandoff）在该分支为 null。
2. `verificationState=VERIFIED` 需同时满足：命令未调用、原执行 `NOT_STARTED`/`NONE`、段闭合、无冲突事实、撤回请求与
   双端撤回收据、H06 释放及最终释放双 ACK（设计 `:405`）。历史释放不代表设备当前空闲，也不放开 `allowedActions`。
3. `safetyHandoff` 的 `deviceFaultLockState`/`fieldLockState` 当前恒为 `UNKNOWN`（`view(...)` 构造器 `:86-89` 固定填该值，
   设计 `:205` 词表亦如此冻结），不得读成「无锁」；`localReleaseState=RELEASED` 也不等于任务可启动。
   三种内部形态须区分：证据事件列表为空 → `NOT_RELEASED`/`NOT_REQUESTED`；证据列表为 null（不可用）→
   `UNKNOWN`/`UNKNOWN` + `issues=[HANDOFF_EVIDENCE_UNAVAILABLE]`；解析异常 → `RELEASED`/`UNKNOWN` +
   `issues=[EXTERNAL_HANDOFF_UNVERIFIED]`。
4. 两个字段声明在**共享的** `TaskView`（`TaskView.java:17`、`:21`），故 M07-021/022 等列表行同样带这两个键且值为 null
   （静态结论：`TaskView` 无 `@JsonInclude`，全仓未发现全局 non-null 包含策略）。设计 `:203` 写「M07-002 详情另含可选
   safetyHandoff，列表和旧接口缺该字段时不推断交接成功」——当前实现是「键存在但为 null」而非「键缺失」；
   两种形态在语义上都不得被读成交接成功，但**形态与文面不符属已知差异**，不能靠改写文面消除。
5. `preExecutionWeightGrams`（详情顶层，`:356`）取 `calculationSummary.preExecutionGrams`，同一值在两处出现；
   其为 null 的含义与 2.3 的空对象情形相同，不代表「执行前重量业务上不需要」；设计 `:168` 明确要求「执行前当前重量为
   null 不显示实时值冒充执行快照」，即页面必须区分「null」与 0。

## 3. Work B：执行记录（M07-012）与日志（M07-011）

### 3.1 M07-012 执行记录与分段

| 字段 | 类型/空值 | 含义 | 当前来源 | 与现行要求的关系 |
|---|---|---|---|---|
| `TaskExecutionSummaryView.executionId` | string | 执行身份 | `selectTaskExecutionRows`（`M07TaskQueryMapper.xml:296-303`） | 设计 `:240` API12 行只写「分页→执行/分段/结算摘要」 |
| `attemptNo` | **Long** | 第几次尝试 | 同上 | 与 `TaskStartWithdrawalView.attemptNo`（`Integer`）类型不一致；本批只登记，不改动 |
| `physicalPhase`／`settlementState` | string | 该次执行的物理阶段／结算态 | 同上 | 摘要口径，非实时 |
| `targetGrams`／`confirmedGrams` | decimal | 定死目标量／已认可实际量 | 同上 | `confirmedGrams` 是认可量事实，不等于设备侧任何回读 |
| `activeMilliseconds`／`timeoutMilliseconds` | long | 实际运行时长／期限 | 同上 | 设计未给字段表（08 记录 D13 同源结论） |
| `startedAt`／`stoppedAt` | `OffsetDateTime`（可 null） | 起止时刻 | 同上 | `stoppedAt` null 只表示「未确认停下」，不表示仍在运行（可能 UNKNOWN） |
| `segments[]`：`segmentId`、`segmentNo`(Long)、`state`、`normalizedGrams`、`startedAt`、`stoppedAt`、`resumeReason` | 共 7 项 | 分段摘要 | `selectSegmentRows`（`:306-313`，8 列，`segment_no ASC`） | 与 API31 的分段视图（13 项，含 `startReadings`/`endReadings`/`rawDifferenceGrams`/`materialSessionId`/`direction`/`activeMilliseconds`）**字段面不同**：012 的分段没有前后读数、没有原始差值、没有物料会话身份 |

差异说明：设计 `:172` 的五页签里「糖信息」「数据曲线」所需的前后读数与原始差值只在 API31/API13 提供；页面若要在
执行记录页签内展示这些量，必须走 API31，不能期望 012 返回。这是字段面边界事实，不是缺陷判定，也不在本批提接口新增方案。

### 3.2 M07-011 日志：当前响应只有 7 列

| 字段 | 类型/空值 | 含义 | 当前来源 | 与现行要求的关系 |
|---|---|---|---|---|
| `eventId` | string | 事件身份 | `selectTaskLogRows`（`:287-293`） | 设计 `:239` API11 行只写「分页→事件倒序」 |
| `eventType` | string | 事件类型码 | 同上 | 词表由 `run_event` 事实决定，本批不扩展 |
| `objectKind`／`objectId` | string | 事件挂靠对象 | 同上（SQL 固定 `object_kind='TASK' AND object_id=#{taskId}`） | 即返回值恒为该任务本身，日志面不含执行/命令子对象事件 |
| `objectVersion` | string | 事件发生时的对象版本 | 同上 | 与 2.1 的 `TaskView.objectVersion` 不是同一时点 |
| `actorUserId` | string（可 null） | 操作人身份 | 同上 | 字段名是 `actorUserId`，响应内**没有** `actor` 对象，因此不存在 `actor.displayName`（连 null 键都没有）；设计 `:204` Person 行的口径不适用于本口 |
| `occurredAt` | `OffsetDateTime` | 发生时刻（UTC 存储，倒序 `occurred_at DESC, event_id DESC`） | 同上 | 与设计 `:170`「日志按occurredAt DESC,eventId DESC，与 M06 审批日志的正序不同」一致 |

明确不在当前响应的字段（不写「不需要」，只写「本口不返回」）：事件 `payload` 整棵树，以及 payload 内的
`change.before`／`change.after`／`result`——与 07 记录 §6.4 结论一致；`actor.displayName` 不存在于响应形状。
因此 011 目前不具备「变更前值/变更后值/执行结果」的展示能力；这是已登记缺口，归属现行设计字段表与后续批次，本批不新增字段定义。

## 4. Work C：执行详情（M07-031）与命令查询（M07-014）

### 4.1 M07-031（`ExecutionDetailView` 14 字段；正常路径 5 条只读 SELECT）

正常路径（`RunExecutionApplicationApplicationServiceImpl#getExecutionDetail`，方法顺序即调用顺序）实际经过 5 条只读 SELECT，
全部用实际 Mapper 与方法名列出：

| 序号 | 用途 | 方法（接口#语句） | XML 位置 | 是否在 PHY 清单内 |
|---|---|---|---|---|
| 1 | 范围闸门（执行归属 + 可见实验室/培养） | `RunExecutionSampleMapper#selectExecutionScopeRow` | `RunExecutionSampleMapper.xml:37` | 否 |
| 2 | 执行主行（11 列） | `RunExecutionMapper#selectExecutionDetail` | `RunExecutionMapper.xml:26` | **是** |
| 3 | 分段全事实（含前后读数绑定所需列） | `RunExecutionSegmentMapper#selectExecutionSegments` | `RunExecutionSegmentMapper.xml:26` | **是** |
| 4 | 异常处理身份 | `RunExceptionHandlingMapper#selectHandlingIdByExecutionId` | `RunExceptionHandlingMapper.xml:10` | 否 |
| 5 | 关联账本身份 | `RunLedgerMapper#selectLedgerIdsByExecutionId` | `RunLedgerMapper.xml:86` | 否 |

清单口径：`物理接口与骨架字段设计.md:107` 的 API31 行**已列第 2、3 两项**（`RunExecutionMapper#selectExecutionDetail`；
`RunExecutionSegmentMapper#selectExecutionSegments`），因此分段查询不是缺项，不得重复列为缺项。真正未进清单的是
第 1、4、5 三项（范围闸门、异常处理身份、关联账本身份）。类注释 `:105-107` 只登记了第 4、5 两项为「PHY API31 清单外
自有表补充」，未把范围闸门计入该口径。

数量适用条件：上述「5 条」指**正常路径**（范围闸门命中、主行存在、推导权限通过）在源码中的静态调用序列，
不是数据库运行实测；提前拒绝或主行不存在时不会走完——范围闸门失败即 404、可信身份或权限缺失即 403、
`selectExecutionDetail` 返回 null 即 404，其后三段查询不发生。方法体内没有按数据分支增减 SELECT 条数的条件查询
（`stopEvidence` 的有无是对主行列的解析，不额外查库）。本批未执行 SQL，实际每次请求的数据库往返数与是否命中连接池
均属 NOT_VERIFIED；权限范围解析另经 `SmpPermissionService#resolveScope`，其是否另有查询本批未核。

| 字段 | 类型/空值 | 含义 | 当前来源 | 与现行要求的关系 |
|---|---|---|---|---|
| `executionId`／`attemptNo`(Long)／`physicalPhase`／`settlementState` | string/Long | 执行身份与阶段事实 | `selectExecutionDetail` | 设计 `:259` API31 行「固定执行规格、前后量、分段、停止证据、异常处理和账本关联」 |
| `targetGrams`／`confirmedGrams` | decimal | 目标量／认可实际量 | 同上 | `confirmedGrams` 是**服务端认可量**，不等于任何设备回读 |
| `startedAt`／`stoppedAt` | `OffsetDateTime`（可 null） | 起止时刻 | 同上 | `stoppedAt` null 时停止证据恒 null（`:101-102`），读作「无停止事实」而非「未停止即仍在跑」 |
| `executionSpec` | `ExecutionSpecView`（22 字段，可 null） | 固定执行规格白名单投影 | `execution_spec` JSON 按白名单手工映射（`:92-99`） | 解析或绑定失败时整体置 null，`specHash` 仍如实返回：**null 不证明原始 JSON 为空**，只证明当前投影链无法安全映射；`planSnapshotVersion`←叶 `version`、`planHash`←叶 `hash`；`strategySnapshotVersionId` 取 STRATEGY 分支冻结叶子；v1 行的 `sampleIdentityVersion`/`authorizationEvidence` 缺键置 null，不按版本补造 |
| `specHash` | string（64 位小写 hex） | 规格哈希 | `spec_hash BINARY(32)` 转码（`:100`） | 编码选择属实现说明，须与列内字节一致才可比对；本批未做运行比对 |
| `segments[]`（13 字段） | 含 `startReadings`/`endReadings`/`rawDifferenceGrams`/`activeMilliseconds` | 分段全事实 | 按冻结叶子 `{feeding,reactor,theoreticalReactorGrams,capturedAt}` 绑定（`:103-104`） | 解析失败置 null；`segment_no ASC` |
| `stopEvidence` | `StopEvidenceView`（8 字段）／可 null | 实际停稳与观察证据 | `stop_evidence` 键名与 VO 一致直接绑定（`:101-102`） | 与 `stopped_at` 的联动规则见上；「未停止时停止证据与停止时刻为 null」为冻结显示规则 |
| `handlingId` | string／可 null | 关联异常处理身份 | `run_exception_handling`（`uk_m07_handling_execution` 至多一条；`decimal(null)` → null） | **只给身份，不给异常内容**；异常内容属异常处置口，本口不展开 |
| `relatedLedgerIds` | string[]／**恒非 null 数组** | 关联账本身份列表 | `run_ledger` 按 `ledger_id ASC`（`ledgerIds:573-581`） | **只给身份，不给账本数值**；当前实现在无关联时返回空数组 `[]`，不是 null——空数组读作「查得无关联」，与「未查询」在响应内不可区分，属字段面事实 |

### 4.2 M07-014（`ExecutionCommandView` 15 字段，SQL 14 列）

来源：`selectExecutionCommandPage`（`RunCommandMapper.xml:34-41`，`WHERE c.execution_id`，`ORDER BY created_at ASC, command_id ASC`）
→ `commandView`（`:389-411`）。该文件 `:45` 注释明写「锁读全事实投影：`payload_hash`/`parameters` 仅在此投影出现」，
即本口**不返回** `payload_hash`、`parameters`、`result_evidence` 整棵树、`next_query_at`、`attempt_count`（与 08 记录 §6.4 一致）。

| 字段 | 类型/空值 | 含义 | 当前来源 | 与现行要求的关系 |
|---|---|---|---|---|
| `commandId`／`requestId`／`resourceKey`／`operation` | string | 命令身份、请求键、资源与动作 | 命令表列 | 设计 `:242` API14 行「阶段/时间/请求及回读速度/结果」 |
| `state` | string | 命令生命周期状态（含 `PREPARED`、`INVOKING`、`EXECUTED` 等） | 同上 | **`EXECUTED` 不等于补量到账**：到账事实只看 `confirmedGrams` 与结算态，不看命令状态 |
| `queryResult` | string（当前恒非 null） | **查询动作的查询态**，不是设备结果 | 有值逐字输出；缺值时按冻结词表派生：`state=PREPARED` → `NOT_SENT`，其余（含 `INVOKING` 在途）→ `UNKNOWN`（`:85-87`） | 设计 `设备命令契约.md:84-95` 列「`queryResult` 提交未查可 null，查询必须返回明确枚举」→ 当前实现选择派生枚举而非 null，语义更强，但须写明它是查询态投影；`:41` 明确「`NOT_FOUND` 仅为查无网关记录，不能证明从未物理执行」，`:97`「禁止伪造 `NOT_FOUND`」，本批原文复述，不作推断 |
| `deviceCommandId` | string／可 null | 网关侧命令身份 | 命令表列 | null 只表示未记录到网关身份，不表示设备未收到 |
| `fence`／`configurationRevision`／`adapterInstanceId` | string／可 null | 围栏、配置版本、适配器实例 | 同上 | 属设备侧身份事实；本批未与设备日志核对（NOT_VERIFIED） |
| `requestedSpeedReadback` | decimal／可 null | 下发速度的回读值 | `result_evidence.readings` 中 `metricCode=ACTUAL_SPEED` **恰一行**时取归一化 `value`；零行或多行 → null（`:88-90`、`speedReadback:414-431`） | null 有三种互不可区分的成因：无 readings、无该指标、多行（源码类注释登记为「多行选择规则未冻结」，故不虚构；该登记未作现行契约结论）；`readings` 完整树不在本响应展开 |
| `createdAt`／`invokedAt`／`resolvedAt` | `OffsetDateTime`／后两者可 null | 创建、发起、闭合时刻 | 命令表列 | `resolvedAt` null ≠ 命令失败；`invokedAt` null 与 `queryResult=NOT_SENT` 同源事实 |
| `lastError` | string／可 null | 最后一次错误原文 | 命令表列原样返回 | 字段名不证明其内容安全，也不证明含敏感信息（08 记录 D11：内容性质未核）。本批不提出脱敏方案，只保留「内容未核」 |

### 4.3 五口共同的读回约束（须写入现行字段说明）

1. 查询结果 ≠ 设备执行结果；命令状态 ≠ 补量到账；`NOT_FOUND` ≠ 从未执行；投影为 null ≠ 原始数据为空。
2. `confirmedGrams`/`normalizedGrams` 是服务端认可量事实，设备侧证据须走 013/014 与停止证据。
3. 五口均为只读投影，不放开 `allowedActions`，不构成设备准入或启动授权。

## 5. Work D：既有证据纠偏（child_task_id）

| 项 | 内容 |
|---|---|
| 原表述 | 「`child_task_id` 全系统只写不读」 |
| 补正表述 | 该说法过强。`M07StoppedReleaseMapper.xml#selectHandling` 的投影**明确包含 `childTaskId`**，属内部/数据库层读取；准确表述应为「写入方与内部读取存在，但五口查询响应与页面尚未形成可回读、可跳转的父—子任务链路」 |
| 依据 | 08 记录 D5 已接受结论 + 本批对该 XML 语句的复核；异常子任务无自身执行时，设计 `:172` 要求「清楚标注父记录链接，不伪造子执行」 |
| 归属 | 页面回读与跳转缺口保持为**已登记差异**（归属现行设计字段表 + 前端消费者批次）；本批不新增接口、不给页面方案、不据此判定为缺陷或客户问题 |

## 6. 原表述 → 补正表述 → 依据（本批字段说明纠偏集）

| 原表述（出处） | 补正表述 | 依据 |
|---|---|---|
| `:203` TaskView 行把 `labId/name`、`cultureId/code`、`reactorRef/code`、`applyState` 并列列出，未注明当前可得性 | 同一行补注：这五个展示/审批事实在 M07-002/021 当前恒未赋值（源码事实）；成因只按「源码注释登记为……」引用，不写成已确认的契约结论；null 不是「不需要」 | `copyTaskView:1438-1465`；类注释 `:114`、`:119-121`（注释登记）；反证材料 `00-统一详细设计主文档.md:976`（applyState 有五种取值）与 `02-…/实验室主数据逐接口契约.md:7`（labName 在 M02 读口已定义） |
| `:203` 用「列表和旧接口**缺该字段**时不推断交接成功」描述 safetyHandoff | 补正为两种形态均不得推断成功，并写明当前实现是列表行**键存在值为 null**（非键缺失） | `TaskView.java:17/:21`；Jackson 包含策略检索结果（无全局 non-null，`TaskView` 无注解） |
| `:230` API02「ID→TaskView及精确计算/**审批摘要**」 | 补正说明（**原设计要求保留**，只追加当前实现说明）：审批侧只给 `approvalId` 身份、`applyState` 当前不返回取值、无审批状态字段；计算摘要在无计算时为空对象而非 null。不得读成「只返回审批身份即满足原设计」 | `:350-356`、`calculationSummary:1557-1588` |
| `:168` 详情展示口径列出「确认项目/时间」 | 补正说明：`confirmationItem`/`confirmationCompletedAt` 有键恒 null，页面当前无法呈现；成因按类注释登记为「快照子路径未冻结」引用，该原因是否仍适用于现行契约本批未确认 | VO 无赋值点；类注释 `:128-129` |
| `:239` API11「分页→事件倒序」 | 补正字段面：本口仅 7 列（`eventId`/`eventType`/`objectKind`/`objectId`/`objectVersion`/`actorUserId`/`occurredAt`），不返回 payload 及 `change.before/after`/`result`，响应内不存在 `actor.displayName` | `M07TaskQueryMapper.xml:287-293`；`TaskLogView`（7 字段）；07 记录 §6.4 |
| `:240` API12「分页→执行/分段/结算摘要」 | 补正字段面：分段摘要 7 项，不含前后读数/原始差值/物料会话；这些量只在 API31 分段视图 | `:296-313`；`TaskExecutionSegmentSummary`（7 字段）vs `ExecutionSegmentView`（13 字段） |
| `:242` API14「分页→阶段/时间/请求及回读速度/结果」 | 补正语义：`queryResult` 是查询态投影（派生规则须成文），不是设备结果；`requestedSpeedReadback` 仅在恰一行时取值；本口不返回 `payload_hash`/`parameters`/`result_evidence` 树 | `:85-90`、`commandView:389-411`、`speedReadback:414-431`；`RunCommandMapper.xml:45` |
| `:259` API31「ID→固定执行规格、前后量、分段、停止证据、异常处理和账本关联」 | 补正字段面：异常处理与账本只给**身份**（`handlingId`/`relatedLedgerIds`），不给内容；`executionSpec`/`stopEvidence`/分段读数在解析失败时为 null 且 `specHash` 仍返回 | `:92-107`；`ExecutionDetailView`（14 字段） |
| `物理接口与骨架字段设计.md:107` API31 行只列 2 条语句，易被读成「清单缺分段查询」 | 补正：该 2 条即主行 `selectExecutionDetail` 与分段 `selectExecutionSegments`，**分段已在清单内**；缺口是范围闸门、异常处理身份、关联账本身份三条只读语句未进清单，其中后两条已由源码类注释登记为清单外补充，范围闸门那条未登记 | 该文件 API31 行原文；`getExecutionDetail` 调用序列；类注释 `:105-107` |
| 07 记录 §4.4「计算摘要 12 项」 | 本批实测 13 声明／11 赋值／2 从未赋值；以实测数字为准，旧记录不改 | `CalculationApprovalSummary.java:16-40`；`calculationSummary:1557-1588` |

## 7. 保留的设计—源码差异与归属（本批不消除）

| 编号 | 差异 | 归属 |
|---|---|---|
| DOC06-D1 | `labName`/`cultureCode`/`reactorCode`/`reactorRef` 当前恒未赋值（源码事实）；M07 任务详情未取这些跨模块展示事实。成因仅按类注释 `:119-121` 登记引用，且 labName 在 M02 自有读口已定义，注释原因是否仍适用本批未确认 | 归属沿用现记录（M02/M03 展示事实 + 主 agent 裁决）；不因原因待确认而撤下「未赋值」事实 |
| DOC06-D2 | `applyState` 恒未赋值；类注释 `:114` 称词表未冻结，但总体设计 `00-统一详细设计主文档.md:976` 已给五种取值 → 属**注释与现行材料的冲突**，不是「契约缺口」 | 待主线核对（M06/审批契约 owner + 总设计入口）；本批不新增客户决策题 |
| DOC06-D3 | `confirmationItem`/`confirmationCompletedAt` 有键恒 null，设计要求展示「确认项目/时间」；现行专题未给该两项字段名或快照子路径（全目录零命中，历史除外） | 计算快照子路径归属现行设计字段表 owner；原因按注释登记引用 |
| DOC06-D4 | API02 的「审批摘要」要求保留；当前只返回身份、无审批状态字段 → 实差继续存在，不以说明文字消解 | 归属沿用 `00-统一汇总与设计余项.md` 的 DOC-03 条目；本批未在该汇总中找到更细的 owner 依据，具体落点标待主线核对，不新建 owner 结论 |
| DOC06-D5 | `baseState` 与 `businessState` 同源同值，是否要求独立语义未定 | 现行设计字段表 owner |
| DOC06-D6 | 011 无 payload／`change.before/after`／`result`，`:172` 五页签与 011 字段面不匹配 | 现行设计字段表 + 后续接线批次 |
| DOC06-D7 | `safetyHandoff`/`startWithdrawal` 声明在共享 `TaskView`，与「详情另含」文面形态不同 | 主 agent 合并时定：改文面或改实现，本批不代选 |
| DOC06-D8 | API31 正常路径 5 条只读 SELECT vs PHY 清单 2 条（清单缺范围闸门、异常处理身份、关联账本身份三项；分段查询并不缺）；`attemptNo` 在 `TaskExecutionSummaryView` 为 Long、在 `TaskStartWithdrawalView` 为 Integer | 源码注释/PHY 清单 owner；类型统一属后续批次 |
| DOC06-D9 | 设计文档冻结的包名 `service.impl.run`/`domain.vo.run`（`物理接口与骨架字段设计.md:11-12`）与源码实际 `service.impl.application.m07`/`domain.vo.m07` 不一致 | 现行设计文件命名段 owner（本批只登记观察，未升级缺陷） |
| DOC06-D10 | `接口目录与契约定位.md` 各行号相对 08 记录已漂移（约 −31），定位块只有一行表格、无字段表 | 属 DOC-02/行号纠偏，非本批处置 |

## 8. 待主 agent 合并，尚未落盘（精确补丁建议）

以下均**未写入**现行文件。合并顺序建议：先按 DOC-02—05 收口同文件改动，再套本批补丁，避免行号与相邻句子冲突。

### 8.1 `docs/详细设计/07-补液运行与任务执行/任务页面与接口契约.md`

1. 目标行：`:203`（TaskView 行）。插入位置：该行末尾（「…不推断交接成功」之后，仍在同一表格单元内）。
   建议正文：
   `字段可得性：M07-002/021 当前不返回 labName、cultureCode、reactorCode、reactorRef、applyState 及 Person.displayName（投影链无赋值点，字段恒为 null）。源码注释把这些成因登记为跨模块展示 Port、显示名 Port 与审批取值词表未冻结；该登记不构成本契约的现行结论——applyState 的取值在总体设计已给五种（PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN），labName 在 M02 自有读口已定义，故本行只登记「当前未返回」，成因待主线按跨模块契约核对。null 表示当前投影缺该事实，不表示业务上不需要，也不得由页面用 ID 或「—」兜底后视为已满足。baseState 与 businessState 当前同源同值，是否要求独立语义未定。`
   依据：`copyTaskView:1438-1465`（源码事实）；类注释 `:114`、`:119-122`（注释登记）；`00-统一详细设计主文档.md:976`、`02-实验室与资源管理/实验室主数据逐接口契约.md:7`（反证材料）。
2. 目标行：`:203` 末段。原句：`列表和旧接口缺该字段时不推断交接成功`。建议正文：
   `列表和旧接口不承载交接事实：当前实现把 safetyHandoff、startWithdrawal 声明在共享 TaskView 上，列表行以「键存在且值为 null」的形态出现，语义上与「键缺失」同样不得推断交接成功或设备可用。`
   依据：`TaskView.java:17/:21`；全仓 Jackson 包含策略检索未见全局 non-null、`TaskView` 无 `@JsonInclude`（静态结论，运行层 NOT_VERIFIED）。
3. 目标行：`:205`（TaskSafetyHandoffView 行）末尾。建议正文：
   `M07-002 详情恒返回该对象，对象存在不是释放证据：无交接事件时取 NOT_RELEASED/NOT_REQUESTED，证据不可用时取 UNKNOWN/UNKNOWN 并附 HANDOFF_EVIDENCE_UNAVAILABLE，外部核验异常时取 RELEASED/UNKNOWN 并附 EXTERNAL_HANDOFF_UNVERIFIED；只有 localReleaseState=RELEASED 且 externalHandoffState=ACKNOWLEDGED 且 issues 为空才构成完整历史证据。deviceFaultLockState/fieldLockState 在当前投影恒 UNKNOWN，不得读成无锁。`
   依据：`M07TaskHandoffProjection:17-19/:22/:25/:80/:86-89`（全部路径都产出对象，无 null 返回）；设计 `:205/:215`。
4. 目标行：`:396-403` 表格之后（`:405` 门禁段末尾）。建议正文：
   `startWithdrawal 为 null 表示按 M07_START_NOT_SENT_WITHDRAWN 未定位到历史尝试，不表示该任务没有启动失败；定位到但证据不齐时返回 verificationState=UNKNOWN 且 executionId/attemptNo/commandId/safetyHandoff 为 null、issues 含 START_WITHDRAWAL_EVIDENCE_UNVERIFIED。VERIFIED 与 UNKNOWN 的判定门禁见上段，历史读投影不放开动作与准入。`
   依据：`M07TaskStartWithdrawalProjection:16-34`。
5. 目标行：`:168`。原句：`按规则补糖展示下限、目标浓度、确认项目/时间、日初/执行前重量、选定依据、公式及实际目标`。
   建议在其后追加注记：
   `当前投影边界：确认项目/时间（confirmationItem、confirmationCompletedAt）有键但当前不返回取值，页面无法呈现；源码注释把成因登记为计算快照子路径未冻结，本契约不据此改写展示要求。无关联计算或计算行不可读时 calculationSummary 返回空对象而非 null，两种情形在响应内不可区分；preExecutionWeightGrams 与 calculationSummary.preExecutionGrams 同值。`
   依据：`calculationSummary:1557-1588`（源码事实）；`getTask:355-356`；类注释 `:128-129`（注释登记，非现行结论）。
6. 目标行：`:230`（API02 行）。原句：`ID→TaskView及精确计算/审批摘要`。**该行不改写**（保留原设计要求），
   只在其后追加明确标注的当前实现说明：
   `当前实现说明（不改变上行要求）：计算侧已返回 calculationId、algorithmVersion、basisKind、basisGrams、preExecutionGrams、lowerOperator、lowerGl、targetGl、targetGrams、formulaCode、dayStartGrams；confirmationItem 与 confirmationCompletedAt 有键但当前不返回取值。审批侧当前只返回 approvalId 身份，applyState 有键但当前不返回取值，响应内没有任何审批状态或审批结论字段。`
   追加一句差异钉桩：`「精确计算/审批摘要」中的审批摘要部分尚未由本口满足，该要求继续保留；本说明只登记当前返回范围，不定义审批摘要必须新增哪些字段。`
   依据：`getTask:350-356`、`calculationSummary:1557-1588`、`copyTaskView:1460-1461`（approvalId 有值）；07 记录 §9.3 D2。
7. 目标行：`:239`（API11 行）。原句：`分页→事件倒序`。建议正文：
   `分页→事件倒序（occurredAt DESC,eventId DESC）；本口字段面为 eventId、eventType、objectKind、objectId、objectVersion、actorUserId、occurredAt 七项，事件 payload 及 change.before/change.after/result 不在响应内，响应无 actor 对象（因此不存在 displayName）`
   依据：`M07TaskQueryMapper.xml:287-293`；`TaskLogView`；07 记录 §6.4。
8. 目标行：`:240`（API12 行）。原句：`分页→执行/分段/结算摘要`。建议正文：
   `分页→执行/分段/结算摘要；分段摘要只含 segmentId、segmentNo、state、normalizedGrams、startedAt、stoppedAt、resumeReason，不含起止读数、原始差值与物料会话身份，这些量由 API31 分段视图提供`
   依据：`M07TaskQueryMapper.xml:296-313`；`TaskExecutionSegmentSummary` vs `ExecutionSegmentView`。
9. 目标行：`:242`（API14 行）。原句：`分页→阶段/时间/请求及回读速度/结果`。建议正文：
   `分页→阶段/时间/请求及回读速度/查询态。queryResult 是查询动作态而非设备执行结果：证据有值逐字输出，缺值时 PREPARED→NOT_SENT、其余含 INVOKING→UNKNOWN；requestedSpeedReadback 仅在 readings 中 ACTUAL_SPEED 恰一行时取值，零行或多行为 null；本口不返回 payload_hash、parameters、result_evidence 整棵树、next_query_at、attempt_count。NOT_FOUND 仅表示查无网关记录，不能证明从未物理执行。`
   依据：`:85-90`、`commandView:389-411`、`speedReadback:414-431`；`RunCommandMapper.xml:45`；`设备命令契约.md:41/:84-95/:97`。
10. 目标行：`:259`（API31 行）。原句：`ID→固定执行规格、前后量、分段、停止证据、异常处理和账本关联`。建议正文：
    `ID→固定执行规格、前后量、分段、停止证据、异常处理与账本的关联身份。handlingId、relatedLedgerIds 只给身份不给内容；executionSpec、stopEvidence、分段读数在解析或绑定失败时置 null，此时 specHash 仍如实返回，null 不表示原始 JSON 为空；stoppedAt 为 null 时停止证据恒 null。`
    依据：`:92-107`；`ExecutionDetailView`。

### 8.2 `docs/详细设计/07-补液运行与任务执行/接口目录与契约定位.md`

11. 目标：定位011（API11）、定位012（API12）、定位014（API14）、定位031（API31）四处块。当前每块只有一行
    表格（来源 + API/method/path/输入输出/权限），无字段表，因此不能就地改写字段。建议正文（每块末尾加同一式注记）：
    `字段面见《任务页面与接口契约.md》§8 注记（本批合并后指向实际章节名），本定位块不重复展开字段。`
    依据：本批实测该文件 418 行、四个定位块均无字段行；避免创建平行权威契约（指令 §六）。
12. 目标：定位002 块（`:116/:120`）。建议正文追加：
    `详情字段可得性以《任务页面与接口契约.md》TaskView 行的可得性注记为准。`
    依据：同 8.1 第 1 项。

### 8.3 `docs/详细设计/07-补液运行与任务执行/物理接口与骨架字段设计.md`

13. 目标行：`:107`（API31 Mapper 行）。原句：`RunExecutionMapper#selectExecutionDetail`；
    `RunExecutionSegmentMapper#selectExecutionSegments`。建议在该行末尾追加：
    `；正常路径另有三条只读语句：范围闸门 RunExecutionSampleMapper#selectExecutionScopeRow、异常处理身份 RunExceptionHandlingMapper#selectHandlingIdByExecutionId、关联账本身份 RunLedgerMapper#selectLedgerIdsByExecutionId（后两项源码类注释已登记为清单外补充）。此处的语句数量口径指源码正常路径的静态调用序列；提前拒绝（范围/权限/主行不存在）时后续语句不发生，非数据库运行实测。`
    依据：`getExecutionDetail` 方法调用序列、上述四个 XML 语句位置、类注释 `:105-107`。
    范围限定：本条只补查询清单说明，不涉及事务、锁、权限模型或一致性改造要求；分段查询原清单已有，不重复列。
14. 目标行：`:24`（API02 VO 行）。建议正文追加：
    `CalculationApprovalSummary 的字段清单与可得性以《任务页面与接口契约.md》注记为准（本批登记：13 个声明字段中 confirmationItem、confirmationCompletedAt 无赋值点）。`
    依据：`CalculationApprovalSummary.java:16-40`；`calculationSummary:1557-1588`。
15. 观察项（不建议本批改写）：`:11-12` 冻结包名 `service.impl.run`/`domain.vo.run` 与源码 `service.impl.application.m07`/`domain.vo.m07` 不一致；`:126` 要求「清单不得再出现 TBD-MISSING、未解释 null」。归属该文件 owner，本批只登记 DOC06-D9。

### 8.4 `docs/详细设计/07-补液运行与任务执行/设备命令契约.md`

16. 目标：`:84-95` CommandEvidence 表 `queryResult` 行。原句：`提交未查可null，查询必须返回明确枚举`。建议正文追加：
    `API14 响应投影当前不把该字段留 null：证据缺值时按 state 派生（PREPARED→NOT_SENT，其余含 INVOKING→UNKNOWN），因此页面读到的 NOT_SENT/UNKNOWN 是投影结论，不等同于网关回执原文；NOT_FOUND 仅在证据存在时使用，且仍不证明从未物理执行。`
    依据：`:85-87`；`设备命令契约.md:41/:97`。
17. 目标：`:84-95` 表 `readings` 行。建议正文追加：
    `API14 只透出 metricCode=ACTUAL_SPEED 恰一行时的归一化 value 作为 requestedSpeedReadback；readings 完整树不随本口返回。`
    依据：`:88-90`、`speedReadback:414-431`。

## 9. 自检与静态校验

- 校验脚本：`temp/work2/s03-doc06/check-doc06.mjs`（表格列数一致性、分隔行存在、空单元格、未填文本、
  引用路径存在性、关键论断齐备、禁用措辞）。
- 实际输出（第 1 轮 DOC-06 写作完成时）：`LINES=329`、`ISSUE_TOTAL=5`，分布 `{"PLACEHOLDER":5}`，
  `TABLE_COL_MISMATCH=0`、`TABLE_NO_SEPARATOR=0`、`EMPTY_CELL=0`、`PATH_NOT_FOUND=0`、`MISSING_CLAIM=0`、
  `FORBIDDEN_PHRASE=0`；进程 `EXIT=0`（脚本设计为恒返回 0，故以计数为准，不以退出码作通过依据）。
- 该检查器的 `PLACEHOLDER` 断言会命中记录自身的复述用词，所以计数随正文增长变化（返修中途复跑为 7）。
  逐条判读后确认全部是自述用词或对现行契约原文的引用，非未填内容；本轮把复述触发词的句子改为不复述，
  终态计数与逐行归属以 §12 为准，检查器断言集合未放宽。
- 第 1 轮曾发现并修正三处本批自身错误（如实登记）：`relatedLedgerIds` 误写为「无关联为 null」（实为空数组）；  API31 分段语句名误写为 `selectExecutionSegmentRows`（实为 `selectExecutionSegments`）；
  `safetyHandoff` 的「UNKNOWN/null」笼统表述未按证据空/不可用/异常三态拆开。另修正客户只读件路径书写（补料非补液）。
- 两轮自检：第 1 轮核字段来源与源码一致、四类依据是否混写、null／空对象／键缺失是否区分、是否误称设备成功；
  第 2 轮核摘要—正文—差异表—未处理项一致、表格空白、未填残留、HEAD 与引用文件并发变化。
- 返修轮（17:26 起）另用 `temp/work2/s03-doc06-rework/check-rework.mjs` 复核四项定向修正：它除表格与路径检查外，
  还逐条断言三类版本用词、API31 五条具名语句与「已有两项／需补三项」、「A/B/C」三列齐备、
  未标注来源的同类「原因式措辞」出现次数、
  API02 原句保留与「当前实现说明」存在、§11 处置表四行齐备。实际输出见 §12。
- 第 2 轮「HEAD 与引用文件并发变化」这项检查本轮**查出实质问题**（不是走过场）：HEAD 仍为 `0fdf86127` 未变，
  但 `docs/详细设计/07-补液运行与任务执行/` 在 17:54—18:01 被并发编辑，`任务页面与接口契约.md` 下移 +20 行。
  本记录对该文件的全部行号引用已按内容逐条重定位（共 45 处替换，见 §1.2/§1.3 与 §11 补行），
  并核出第 1 轮 §1.2 的「未跟踪」前提是错的，已撤下。引用的**文字**经 diff 核对未被并发修改推翻。

## 10. 分层状态（按 AGENTS.md §13.2）

| 对象 | 状态 |
|---|---|
| 本批文档与字段说明 | 已落盘于本记录（历史过程件，非现行契约） |
| 现行专题补正文本 | 未落盘，标记「待主 agent 合并」 |
| 字段来源静态核对 | 已做（Controller 响应类型 → VO → 应用服务赋值 → Mapper 列） |
| 编译／测试／SQL／HTTP／浏览器／设备／现场 | 全部 NOT_VERIFIED（本批按指令未执行，无阻塞归因） |

## 11. 本轮返修处置（2026-11-03 17:26 起，四项定向返修）

| 原问题 | 修正位置 | 修正结果 | 仍未确认内容 |
|---|---|---|---|
| 一、§2.1 把 `TaskView.objectVersion` 说成「守卫写应回填的 `X-Management-Revision` 同源值」 | §2.1 表格行、补充事实、新增 §2.1.1；全文检索确认无第二处该说法 | 该说法已撤下。三类版本分开：对象版本＝`run_task.object_version`，按 `:197`（WriteMeta 行）/`:19`（M07-006 段）用于写请求体 `expectedVersion`（CAS 证据 `RunTaskMapper.xml:130-173`）；管理版本＝响应顶层 `managementRevision`（`RunTaskController` 的 `pageTasks`/`getTask` 带 `@CurrentManagementRevision`，AGENTS §13.3）；执行版本＝`run_execution.object_version`（`current_execution_version`），对外不以 `objectVersion` 之名返回。已注明不外推为统一制式 | 其他对象写口（步骤、培养运行、确认单、异常处理）的 `expectedVersion` 各对照哪张表的版本列，本批未逐一核 |
| 二、§8.3 第 13 条把「分段前后读数绑定查询」列为清单缺项，而 PHY 清单已有该语句 | §4.1 标题与来源段（改为五条具名语句表）、§6 对应行、§7 DOC06-D8、§8.3 第 13 条 | 清单已有项写明为 `RunExecutionMapper#selectExecutionDetail` 与 `RunExecutionSegmentMapper#selectExecutionSegments`；需补三项为 `RunExecutionSampleMapper#selectExecutionScopeRow`、`RunExceptionHandlingMapper#selectHandlingIdByExecutionId`、`RunLedgerMapper#selectLedgerIdsByExecutionId`。「5 条」限定为正常路径静态调用序列，提前拒绝时后续语句不发生，非数据库运行实测；补丁只补清单说明，不含事务/锁/权限/一致性要求 | 真实数据库往返数、连接池行为及 `SmpPermissionService#resolveScope` 是否另有查询，本批未运行验证 |
| 三、多处把源码注释的「Port 未冻结／词表未冻结」直接当作现行设计状态与缺口成因 | §2.2 表头与七行（改为 A 源码事实／B 注释登记／C 现行设计状态三列）、§2.3 关于确认项目/时间两句、§4.2 `requestedSpeedReadback` 行、§6 两行、§7 DOC06-D1/D2/D3、§8.1 第 1/5 条补丁正文 | 已降级：`labName`/`cultureCode`/`reactorCode`/`reactorRef`/`displayName`/`confirmationItem`/`confirmationCompletedAt`/多行选择规则一律写成「源码注释登记为……」，并把已证实的「当前未赋值／恒 null」事实保留。仍有现行依据的两项已单独标注：`displayName` 允许为 null 是 `:204` Person 行设计文面；`applyState` 出现**反向证据**——总体设计 `00-统一详细设计主文档.md:524/:733/:976` 已给 PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN 五种取值，与注释「词表未冻结」冲突，故改为「M07 专题未指定本口取值来源与映射」。`labName` 在 M02 自有读口已定义（`实验室主数据逐接口契约.md:7/:27`）一并登记 | 注释原因是否仍适用于现行契约（需按跨模块 Port 与审批契约核对）、applyState 能否直接套用总体词表、M01 显示名读口的可得性——本批未做跨模块审计，也未新增客户决策题或「必须新建 Port」的断言 |
| 四、§8.1 第 6 条把 API02 的「精确计算/审批摘要」整句替换成「精确计算摘要与审批身份」，等于用实现边界覆盖设计要求 | §8.1 第 6 条、§2.3「设计要求但当前未返回」表第二行、§6 API02 行、§7 DOC06-D4 | 该行改为「原句不改写」，只追加明确标注的当前实现说明：列出 11 个已返回计算字段、`confirmationItem`/`confirmationCompletedAt` 当前不返回取值、审批侧只有 `approvalId`、`applyState` 当前不返回取值、无任何审批状态字段，并钉桩「审批摘要要求尚未由本口满足」；未自行定义审批摘要必须新增哪些字段，未宣布只给身份即可满足 | 审批摘要的字段落点与更细归属：本批只沿用 `00-统一汇总与设计余项.md` 的 DOC-03 条目，其余标待主线核对，未新建 owner 结论 |
| 补（非指令四项，本轮第 2 轮自检查出）：§1.2 断言 `docs/详细设计/**` 全部未跟踪、无法用 git 区分在途编辑；且全文行号沿用第 1 轮快照 | §1.2 整节重写（改为 git 跟踪状态表 + 两次快照 mtime + diff 落点核对）、新增 §1.3 引用约定、§9 自检项、§2.1.1/§2.2/§2.3/§2.4/§3/§4/§6/§7/§8/§11 内 45 处行号替换 | 「未跟踪」前提**撤下**：四个引用文件均为 git tracked 文件（`git ls-files --error-unmatch` 通过，末次提交 `0cc980791`），16:52 时内容与 HEAD 一致，git 当时即可证明无人落笔；结论方向（现行文件零修改、只出补丁）不变且被 17:54—18:01 的并发 ` M` 证实必要。行号按内容重定位：`任务页面与接口契约.md` 一律 +20（177→197、183→203、184→204、185→205、188→208、195→215、148→168、150→170、152→172、210→230、219→239、220→240、222→242、239→259、376-383→396-403、385→405），引用同时给出行名；`物理接口与骨架字段设计.md:107/:11-12`、`设备命令契约.md:41/:84-95/:97` 经 diff 核对位置与文字均未变 | 该目录仍在被并发编辑，主 agent 合并第 8 节时应按名称定位目标行，不得按本记录行号直接寻址；`接口目录与契约定位.md` 本轮被改 7 处单行（净 0 位移），本批未引用其行号，故未逐行复核其内容是否影响 DOC-02 结论 |

说明：四处原错误只在 §2.1.1 与本节作为「已撤下／已修正」的历史记录出现，正文其余位置不再保留未标识的错误说法；
§1.2 的「未跟踪」错误同样只在 §1.2 的撤下句与本节补行中出现，正文其余处无残留。
本轮未新增接口核查、未扩大为深度代码审计、未修改现行设计与任何源码。

## 12. 返修轮校验实际输出

| 命令 | LINES | ISSUE_TOTAL | 分布 | 退出码 |
|---|---|---|---|---|
| `node temp/work2/s03-doc06-rework/check-rework.mjs` | 438 | 0 | 全类别为 0：`TABLE_COL_MISMATCH=0`、`EMPTY_CELL=0`、`TABLE_NO_SEPARATOR=0`、`PATH_NOT_FOUND=0`（`PATHS_CHECKED=7`）、`R1/R2/R4_*_missing=0`、`R3_UNATTRIBUTED_UNFROZEN=0`、`REWORK_TABLE_INCOMPLETE=0`、`C1_*`（本轮新增的并发核查断言）全部为 0 | 0（脚本恒返回 0，不作为通过依据） |
| `node temp/work2/s03-doc06/check-doc06.mjs` | 438 | 1 | `PLACEHOLDER=1`，命中在 §8.3 第 15 项引用 `物理接口与骨架字段设计.md:126` 的契约原文处；其余类别为 0 | 0 |

说明计数口径：原检查器的 `PLACEHOLDER` 断言会匹配记录自身的用词，第 1 轮与返修中途复跑曾分别得到 5、7 条。
本轮把 §9/§12 里复述触发词的句子改写为不复述（见下条），只保留一处对现行契约原文的引用，
故终态为 1 条。这一改动没有放宽检查器（脚本文件本身未改断言集合，只改被检文档的措辞），
剩余 1 条是引用原文，不是未填内容。

逐条判读（不笼统称误报）：

- 首轮跑返修检查器时 `R3_UNATTRIBUTED_UNFROZEN=1`，唯一命中是 §9 里描述该检查项自身的那一行（自指命中）。
  已把 §9 的措辞改为「未标注来源的同类『原因式措辞』」，检查器不复述原三字，故终态归零。
  这一改动只是消除自指，不改变断言本身；正文 §2.2/§2.3/§4.2/§6/§7/§8 中同类措辞仍全部保持
  「源码注释登记为……」的引用形态，且检查器对 A/B/C 三列齐备的断言未放宽。
- `C1_*` 断言是本轮为并发核查新增：核 §1.2 的「未跟踪」错误前提是否已标注撤下、§1.3 引用约定与 git 证据是否齐备、
  第 1 轮旧行号是否仍以引用形式残留、重定位后的新行号是否各至少出现一次。首轮即核出两处漏改的 API12 旧行号
  （§3.1 与 §6 各一处，旧值需 +20），补改后归零——即该断言并非摆设，实际抓到了错。
- 返修过程中自查并修正的本轮自身错误：§2.1 的「同源值」说法（返修项一）；§8.3 第 13 条把已在清单内的分段查询列为缺项（返修项二）；
  §8.1 第 6 条整句替换 API02 要求（返修项四）；§2.2/§2.3/§7 把注释原因当作现行结论（返修项三）；
  以及 §1.2 的「全部未跟踪」错误前提与全文旧行号（本轮第 2 轮自检，见 §11 补行）。
