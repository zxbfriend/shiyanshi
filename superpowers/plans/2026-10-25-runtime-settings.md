# Runtime Settings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. The user has authorized implementation in this conversation; do not add a new approval gate or commit changes.

**Goal:** 将当前反应器详情的运行中设备和计算规则修改接入真实候选、审批、生效及原请求恢复。

**Architecture:** M07 拥有培养设置候选和 M06_SC025/033 审批来源；通过 M03/M02/M09 端口读写各模块事实。复用现有管理守卫、M06 政策/提交/交付和任务计算，不将培养候选塞入任务候选表。保留余松现有弹窗模板和样式。

**Tech Stack:** Java 17 / Spring / MyBatis / MySQL；Vue 3 / TypeScript / Vitest。

**Spec:** `docs/详细设计/07-补液运行与任务执行/培养运行设置变更契约.md`，M03 培养基础变更候选契约，M06 审批场景映射。

## Global Constraints

- 保留共享工作区已有修改；不提交、推送、部署、执行数据库变更或真实设备动作。
- 新规则生效后未开始任务重算并重新判策；已开始/暂停/命令未知保留旧依据。
- 真实失败不回退 Demo，不以审批通过当作实际生效；缺源数据保持受阻。
- 静态、契约、目标数据库、HTTP、浏览器、设备验证分别记录。

## Review Focus

- 当前培养成员资格撤销：读取及生效重新鉴权（任务 1/2）。
- 配置字段 false/未知枚举/缺修订：false 保留，未知拒绝（任务 1）。
- 保存超时及跨实验室迟到响应：原请求恢复且不覆盖新上下文（任务 4）。
- 旧审批晚于新配置到达：旧候选不能重新生效（任务 2/3）。
- 任务启动与规则生效竞争：同一锁顺序，已开始冻结依据（任务 3）。

## Task 1: 真实规则上下文

Files: `service/port/m03/CultureFeedingConfigurationPort.java`、`service/impl/port/m03/M03CultureFeedingConfigurationAdapter.java`、`service/application/m07/RunCultureChangeApplicationService.java`、`service/impl/application/m07/RunCultureChangeApplicationServiceImpl.java`、`controller/run/RunCultureChangeController.java`（均在 futurefab-system Java 包下）；测试 `M07RuntimeCalculationContextTest.java`。

Interface: `readForRuntimeChange(String cultureId): Snapshot`；`calculationContext(String cultureId): Snapshot`；GET `/run/cultures/{id}/calculation-rule-changes/context`。

- [x] 写测试：当前成员/运行态、有版本有效配置、false 保留、停用/未知/缺版本拒绝、M07 Controller 同源 revision 注解。
- [x] 运行单类 Maven 测试，确认缺少 Controller/应用服务/适配器的编译失败（`.local-runtime-context-red.log`）。
- [x] 实现 M03 同事务真实读取，M07 转发，不伪造默认配置。
- [x] 后端 2 类 12 例通过；现有弹窗接入读口，前端 5 文件 61 例通过，SDK 声明及实验室类型检查通过。仅完成读取切片，未宣称写入完成。

Task 1 evidence: `.local-runtime-context-tests.log`、`.local-runtime-context-frontend.log`、`.local-runtime-context-typecheck.log`。前端 4 条新用例先失败，再通过；包含失败清空、培养不匹配与跨用户迟到响应。没有真实 HTTP/浏览器证据。

Ruling: 继续当前共享工作区的已有授权修改，不另起会丢失本轮未提交前提的 checkout；不提交、不推送。总清单和本计划共同记录工作，用户的直接实施要求优先于技能的再次计划确认/提交步骤。

## Task 2: 候选与审批

Files: 新增 M07 `RunCultureChangeCandidateMapper`、对应 XML/行模型、`M07CultureChangeCommandService`；扩展 `M07ApprovalDecisionService` 以 CULTURE 类型分派；新增 M03 生效 Port；同步模块字段字典/DDL 与开发基线来源；不执行 SQL。

Interface: M07 提交/活动/详情/本人原请求查询；稳定 candidateId/hash、培养及配置期望版本。M06 复用现有 policy/submit/deliver/query；M03 apply 只接受已验证的固定拥有方候选。

- [ ] 测试同键重放/不同载荷冲突、同培养活动槽、DIRECT/APPROVAL、撤回和迟到交付、版本冲突及回滚。
- [x] RC-01候选表、M07行模型/Mapper；原请求按actor+request唯一，活动培养槽和审批ID唯一；候选路由/决定用固定身份CAS，7例实际MyBatis/H2测试通过。尚非完整写服务测试。
- [x] Controller/应用服务/SDK接入活动、详情、本人原请求读取；范围/跨实验室/失权/损坏记录/错误透传6例通过，原上下文5例回归通过，SDK5例通过。
- [x] M03内部`CultureRuntimeCalculationPort`复核原申请人权限/范围和双版本，同事务CAS配置与培养版本；8例真实SQL/回滚测试通过。候选工厂输出SC033真实培养审阅及RECALCULATE_UNSTARTED影响，M06提供方验证通过；本批5类86例通过，`.local-runtime-calculation-approval-tests.log`。
- [x] 内部提交与CULTURE审批决定已调用M03生效和M07任务重算；候选、配置、任务、真实审批、事件、审计、回执及版本同事务。保留原提交回执和固定决定重放，写前业务冲突与依赖故障分别处理；定向验证见下方最新记录。
- [x] M07-RC05公开提交和SDK写入已接；Controller/应用服务/守卫调用及审批拥有方有定向测试。当前设置弹窗已接此写口，保留开始前的原PATCH恢复。

## Task 3: 生效影响

Files: M07 变更服务/任务 Mapper/计算服务；M03 培养和计算配置 Port；M02 目标设备事实及占用、M09 版本事件。

- [ ] 测试计算变更只重算未开始任务；暂停、已发未知命令、已有物理事实不改；taskId/日额度/历史不变。
- [ ] 新计算快照固定新配置版本和合法当前输入；替换活动任务候选并重新走 M06 政策，输入缺失保持不可执行。
- [x] 内部真实输入组装与重算持久化已接通：读取原申请人当前方案权限、SMP账本或可信外部计量、同日M05/人工确认；新GENERATE/UPDATE候选按新政策直接生效或保持待审，缺输入保持阻断。`M07RuntimeCalculationInputs`与`M07RuntimeTaskRecalculation`已有定向验证；尚未连接公开设置提交和完整审批回投。
- [x] SC033派生TASK候选已接现有M07审批分派及具名资源消费者；复核原申请人/政策/场景、当前配置与真实重算输入，精确CAS生效，DISCARD保持held，依赖故障保留原候选重试。CULTURE公开提交和交付未接通前仍不能启用页面写入。
- [x] 内部任务屏障锁定安全未开始任务、清旧目标/活动指针并失效旧待审候选，保留身份/日期/额度和物理历史；实际Mapper/H2的6例通过，`.local-runtime-calculation-task-tests.log`。尚未接公开生效和后续重新判策，不能单独宣称重算闭环。
- [x] 复用F01—F04的规则变更GENERATE纯计算完成5例验证；固定新配置/培养版本和候选身份，当前量不替换F02初始量。真实输入组装/持久化调用仍未接通，不能单独宣称重算闭环。
- [ ] 测试设备变更与启动竞争、目标占用、方案/连接失效、旧告警事件水位；同事务失败无部分生效。

## Task 4: 现有弹窗接线

Files: SDK 新增培养运行设置客户端；`settings-dialog.vue`、`replacement-dialog.vue`、既有 `state.ts`；实际 SFC 测试 `reactor-runtime-write-boundary.test.ts`。

- [x] 计算规则用真实context回填五字段/版本，提交固定原请求，按M07候选状态展示审批与终态；不把本地缓存当作审核状态。
- [x] 计算规则详情失败保留候选ID；未知结果先查本人原请求，确认NOT_FOUND后才重放原双头与载荷。M06撤回沿实际allowedActions和同源修订，保留未知原撤回；用户/实验室/培养变化拒绝旧响应和后续写入。
- [x] 计算规则保留现有字段、摘要、按钮和样式，仅接真实状态/刷新/撤回。实际SFC与SDK等5文件85例通过；SDK声明构建与实验室vue-tsc退出0。
- [ ] 设备更换弹窗的真实候选/生效/审批链继续实施。
- [ ] 条件允许时执行真实HTTP/浏览器；本轮指定本机端口9090/8081/8082/5173/3000无监听，未执行真实业务或数据库操作。

## Self-review

本计划涵盖两种运行变更；远程服务/预填充/理论总重仍按总清单跟踪。单项读取、禁止本地成功、DDL 静态通过均不是完整接入证据。现已核实 `run_task_candidate.task_id` 为必填且仅允许任务动作；M03 候选 schema 也不承载计算规则。任务2使用M07自有`run_culture_change_candidate`，不伪造taskId或改用M03场景。当前已接公开计算规则提交、CULTURE审批交付及任务重算同事务、SDK写入；计算规则当前弹窗已接写入与恢复；缺GENERATE基线任务及DEVICE分支继续实施。以下较早验证记录保留当时范围，以最新证据为当前状态。

Task 2 partial evidence: `.local-runtime-candidate-read-tests.log`（18/18）、`.local-runtime-candidate-sdk-tests.log`（5/5）；`scripts/sync_runtime_change_baseline.py`定向一致且第二次无改动。保留既有两张未登记M02定义（原SQL192/来源190，现193/191），不得称全量基线一致。新SQL没有在目标数据库执行。

SDK声明及实验室类型检查退出0：`.local-runtime-candidate-sdk-typecheck.log`、`.local-runtime-candidate-lab-typecheck.log`；未修改本批页面模板/样式。提交/生效调用链接好前，不把现有弹窗切成可成功写入。

2026-10-26本批最终验证：`.local-runtime-calculation-integrated-tests.log`，9类106例，0失败/错误/跳过，Maven退出0；含M03配置生效8例、M07固定候选3例、任务屏障6例、规则变更计算5例、原来源恢复计算/应用和M06政策/提交回归。仅内部能力`CONTRACT_TESTED`；公开写入、审批交付、任务新候选持久化与当前弹窗仍未完成。未执行目标MySQL、HTTP、浏览器或设备操作。

后续内部重算验证：`.local-runtime-reevaluation-typed-ports-tests.log`，8类145例，0失败/错误/跳过，BUILD SUCCESS。覆盖真实输入组装、任务重算/判策/保存、实际Mapper屏障、M03原申请人方案读取及M02中试培养基名称读取。两项Port均改为项目要求的单个类型化Query/Response，未豁免Port签名检查。SDK声明类型检查退出0（`.local-runtime-task-sdk-typecheck.log`）。没有原GENERATE基线的任务目前明确阻断，仍须补完整真实输入来源。

已补充新TaskSpec生效校验：只接受同任务/培养的APPLIED候选、固定摘要和生效回执，并校验当前GENERATE计算的摘要、配置与培养版本；启动、结果更正影响及使用统计共同复用该判断。来源恢复替换规则重算时移除旧活动引用，历史仍保留。`.local-runtime-calculation-authority-tests-final.log`，7类49例，0失败/错误/跳过，Maven退出0；生产Mapper在隔离H2执行（提供JSON函数和正BIGINT的UNSIGNED类型适配，生产SQL未替换），含启动/更正处理和原来源恢复回归。公开提交、专用审批回投和现有弹窗写链仍为未完成项。MySQL/HTTP/浏览器/设备仍NOT_VERIFIED。

后续TASK审批回投验证：`.local-runtime-task-decision-complete.log`，7类47例，0失败/错误/跳过，Maven退出0。包括真实M07拥有方分派/输入比较/幂等回执逻辑与边界替身9例、生产Mapper/H2屏障及拒绝CAS9例，以及既有审批/来源恢复/后台消费者来源回归。修复M06大写摘要回投被拒、同一重量JSON类型变化误判、重复决定时间序列化比较误判。保留当前页面模板与样式；未提交、部署、执行目标数据库或设备操作。此批仅关闭SC033派生TASK候选的审批子链；CULTURE提交/回投、完整生效事务、缺GENERATE基线的真实输入、SDK和现有弹窗写链仍须继续。


2026-10-26 SC033提交与培养审批最新验证：`.local-culture-calculation-final.log`，9类64例，0失败/错误/跳过，Maven退出0；包括真实Controller/应用服务/命令服务调用、候选生产SQL与Spring事务、M03配置SQL、CULTURE和TASK审批、原请求/原决定重放、权限/政策拒绝、任务及审计异常回滚。M03/M06/任务/审计等部分边界使用替身，不能宣称真实服务联调。SDK 8例通过（`.local-culture-calculation-sdk-final.log`），SDK类型检查退出0（`.local-culture-calculation-sdk-types-final.log`），使用本机缓存pnpm 8.6.2。前一次全AuditPolicyRegistryTest仍有既存M02-010白名单不一致：HEAD生产定义含controller_id，HEAD测试期望未含；保留未改，记录`.local-culture-decision-tests.log`，不得称全量审计测试通过。本次精确验证新增两策略、完整注册及绑定分布。M07-RC05后端/SDK为IMPLEMENTED + CONTRACT_TESTED；现有弹窗未接写口，MySQL/HTTP/浏览器/设备NOT_VERIFIED。未提交、推送、部署或执行目标数据库。


## 2026-10-26：无原计算的任务与页面重算结果提示

- `M07RuntimeCalculationInputs` 为尚无计算引用的 schema2 AMOUNT/PERCENT 任务组装首次输入：使用任务已冻结且与当前有效方案一致的唯一泵资源、真实料液/计量策略，以及当前初始重量修订和认可账本。缺精度、资源变化、外控当前重量缺观测继续阻断；已有计算引用损坏不得走首次计算路径。
- 新 GENERATE 与原任务 UPDATE 候选照常重新判策；`previousCalculationId` 显式 null，不伪造旧计算。同步 SDK 类型、专用审批比较及启动来源验证；计算 stamp 固定 TASK_SPEC 来源与原任务身份。任务锁读补回真实 calculation_id，覆盖“列有旧引用、JSON 无引用”的损坏情形。
- 当前计算规则弹窗的任务提示改为统计服务端实际 PENDING_REVIEW/PENDING_APPROVAL；此前仅判断 PENDING 会漏报。现有模板与样式保持不变。
- 后端 7 类 65 例通过，0 失败/错误/跳过，Maven 退出 0（`.local-runtime-first-calculation-final.log`）；包含实际 Mapper/H2 读取与屏障、真实算术/输入、拥有方审批及边界替身。前端实际 SFC 与 SDK 共 42 例通过（`.local-runtime-first-calculation-frontend.log`），SDK 声明构建及实验室 vue-tsc 退出 0（`.local-runtime-first-calculation-types.log`）。差异检查通过。
- 本批为 `IMPLEMENTED + CONTRACT_TESTED`；MySQL、HTTP、浏览器与设备仍 `NOT_VERIFIED`。自动 RULE 生成依据缺口（非新增人工 RULE 功能）、EXTERNAL 新观测、缺输入后恢复链以及 DEVICE 运行变更仍需继续，不将本批作为整体完成证据。未提交、推送、部署、执行目标数据库变更或设备命令。

## 2026-10-26：当前更换反应器弹窗的真实上下文

- 新增 M07-RC06 GET `/run/cultures/{id}/device-changes/context`，由既有应用服务复用 M03 当前操作范围、培养版本、主设备和运行占用查询。现有 replacement-dialog 已调用 SDK，校验同培养/实验室/当前设备及同源管理版本；读取失败清空候选并保留重试，未开始培养仍走原 PATCH。
- 当前用户、实验室或培养切换后，不接纳迟到读取、写入反馈或导航；原已发出的请求仍保留，旧弹窗可关闭。缺容量显示“—”，不再填 15L。未改模板布局、样式，也未恢复旧页面。
- `IMPLEMENTED + CONTRACT_TESTED` 仅指上述上下文读取和界面保护。后端 3 类 29 例通过，Maven 退出 0（`.local-runtime-device-context-backend-final.log`）；前端 4 文件 69 例通过（`.local-runtime-device-context-frontend-final.log`）；SDK 声明构建、最终实验室类型检查退出 0（`.local-runtime-device-context-types.log`、`.local-runtime-device-context-types-final.log`）。差异检查通过。首轮后端失败来自测试替身重复设异常时提前抛错，已修正测试设置并重跑通过。
- DEVICE 的真实提交、审批和占用交接仍未完成；已询问用户旧设备未开始任务是取消还是保留受阻待迁移，等待答复，未擅自选择。执行中、暂停、未知命令或未结算物理事实禁止更换的既定约束继续保留。HTTP/浏览器/设备 `NOT_VERIFIED`，未提交、部署或执行目标数据库变更。

## 2026-10-26：连续规则变更保留原准入，检测更正保留规则屏障

- 修复任务首次重算受阻或待审批后，再次改规则误用临时 admitted=0 的问题。内部 runtimeCalculationHold 固定原准入状态与原版本，连续变更校验当前版本和候选原因后继承；已准入 FEEDING/SUGAR 重新走 SC001/SC005，未准入走 SC002/SC006。待生效新规格清除内部标记，旧候选及固定输入保留历史。
- M05 检测结果更正仍失效相关审批候选，但规则重算任务保留 held 和培养候选原因，内部版本随任务版本同步；不误放行为普通检测来源恢复。普通任务的检测更正路径保持原行为。
- 当前代码人工新建 SUGAR 仅支持 AMOUNT，RULE/PERCENT 只可编辑已有自动规则任务。未发现 PlanGenerationPort 的生产实现；缺少自动 RULE 的真实生成计算及最小量评估属于生成拥有方缺口，不新增人工 RULE 输入或合成历史。
- IMPLEMENTED + CONTRACT_TESTED：最终后端 10 类 89 例，0 失败、错误或跳过，Maven 退出 0（.local-runtime-admission-source-final.log）。覆盖实际 Mapper/H2 的连续重算、缺输入、待审批、检测更正交叉、版本与事务回滚，以及审批/来源恢复回归。H2 为 JSON 函数提供适配，不能等同 MySQL 验收。前一批 7 类 69 例也通过（.local-runtime-admission-final.log）；最终证据以 89 例为准。
- 本批未修改页面模板、样式或交互。差异检查通过。MySQL、HTTP、浏览器及设备 NOT_VERIFIED；未提交、推送、部署、执行目标数据库变更或设备操作。缺输入后的专用重试链、EXTERNAL 新观测与 DEVICE 写入仍未完成；DEVICE 未开始任务处置问题继续等待用户答复。

## 2026-10-26：审批生效回查补齐任务重算结果提示

- 发现并修复：直接提交会提示待审批/受阻任务数量，但审批后刷新及未知提交按原请求恢复只提示规则已生效，遗漏派生任务结果。当前弹窗本就会在生效后关闭，因此没有新增实时状态面板，也未把刷新变成写入。
- CultureSettingChangeView/SDK 增加只读 taskEffects。直接生效取原提交回执；审批生效通过原拥有方回执 ID、培养、实验室、候选和事件键查询真实生效事件，校验摘要及原结果后返回固定任务重算结果。缺失/损坏返回错误。共享 M06 DeliveryEvidence、原回执与事件不修改。
- 当前 runtime-calculation 复用现有消息和关闭交互，在直接提交、审批刷新及原请求恢复时统一提示“生效时”待审批/缺输入受阻数量，当前进展指向任务列表。页面模板、样式、字段与按钮保持不变；缺结果保留原候选和错误供刷新，不重复提交。
- IMPLEMENTED + CONTRACT_TESTED：后端 3 类 34 例通过，Maven 退出 0（.local-runtime-task-effects-backend.log）；包含生产 Mapper/H2 对生效事件范围和回执 ID 的实际读取测试，以及摘要损坏/缺事件拒绝。前端 3 文件 58 例通过（.local-runtime-task-effects-frontend-final.log），SDK 声明及实验室 vue-tsc 退出 0（.local-runtime-task-effects-types.log）；差异检查通过。
- 本机 9090/8081/8082/5173/3000 未监听，MySQL、HTTP、浏览器和设备仍 NOT_VERIFIED。未提交、推送、部署或执行目标数据库变更/设备动作。恢复触发方式已询问自动重算还是用户主动重试，等待答复；DEVICE 未开始任务处置问题也仍待答复。两项确认未到前，相关写入分支不推定实现，整体目标保持进行中。
