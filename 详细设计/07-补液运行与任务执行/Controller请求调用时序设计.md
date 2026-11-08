# M07 Controller 请求调用时序设计

## 2026-11-03 小试 W03/W07 无设备占位时序

新建 W03/W07 控制器逻辑通道实例不写 `executionMode=SIMULATION`。Controller 接收用户确认的装量及预填充量、泵速 → 应用服务校验权限、连接来源、通道身份、版本和原请求幂等 → 持久化工作流步骤及操作状态 → 启停回 `state=APPLIED`、`applicationState=APPLIED`；详情通过 `benchContext.primeState.pumps` 投影已记录的操作状态，`actualGrams` 为 null。W03 最终完成登记 `COMPLETED/APPLIED` 业务连接；W07 以该培养和控制器的有效 W03 连接为前置。取消、失败及并发仍按各自既有规则处理。

本条仅记录业务操作及无设备占位结果，不代表下发设备命令、收到设备回执或取得实际耗量；不改写旧模拟实例，也不改变中试和旧实体液瓶路径。此说明优先于下文与新建小试逻辑通道模式冲突的旧模拟时序，HTTP、浏览器和设备联调以实际验证为准。
> 2026-11-06／07 用户已确认中试 W01/W02 新流程使用正式业务链，设备未回读应标记未核实；W02 预填充只输入泵速并逐泵手动启停，无预填充时仅二次确认，不要求净重或跳过原因。下文 W01/W02 的 SIMULATION 专用调用、净重及恢复旧描述为当时实现或契约，不能覆盖[工作流最新业务规则](工作流与页面操作设计.md)；真实设备协议及调用时序仍须按接口证据落实。

2026-10-24 中试结束培养专项：M07-022/023/024/025/026/027按[中试结束培养接口契约](中试结束培养接口契约.md)分发。正常末步使用`M07-END-CULTURE-COMPLETE`：SYSTEM守卫 → M03培养与原占用锁/资格复核 → M07释放核验和实例/步骤锁 → M03培养终态/占用释放/观测关联 → M07步骤/实例/事件 → M03拥有的审计意图 → SYSTEM版本和幂等回执。按用户最新确认，新实例由后端冻结默认设备连接标记，可为当前有操作权的培养保存业务结果，不依赖专用培养ID列表；旧隔离模拟实例仍受原允许列表约束。两种路径的设备回执均明确保留SIMULATION来源，不能据此证明现场设备已停止。小试及W02时序不改。

同日最新确认的W01联动：新默认连接实例仅在最终完成或确认跳过时，同事务登记`run_culture_runtime`连接关联；中途及取消不登记。结束培养候选读取关联的W01，校同培养/反应器/占用和完整完成证据；023重验原实例版本并冻结内部来源；026、模式025及最终释放再次复核。默认连接来源不要求培养ID允许列表，实际写入能力仍标UNKNOWN。旧的无业务关联模拟实例才使用专用测试允许列表。页面不能传入内部来源引用，W02保存语义不改。

2026-10-24异常最终保存：M07-025只读分类DIRECT/DIRECT_REASON后，沿M07-END-CULTURE-COMPLETE调用M03异常保存；锁内再次比较政策。APPROVAL仍沿步骤守卫保存固定CULTURE候选。M06最终决定由原M07唯一提供方定向路由至中试结束消费者，先经后台资源事务保存原决定；固定M07_PILOT_END_CULTURE_APPLY消费者等待任务与泵停止后自动应用，M03培养/原占用锁先于M07实例/步骤锁。SYSTEM事件、原回执、培养CANCELLED及原占用释放同事务，不再要求人员再次点完成。API12仅查询原回执，不执行应用；真实设备仍待协议接入。具体状态与部署条件见中试专项契约。

正常结束启动的MODE_CONFIRM展示在023守卫回调内、实例/步骤写入前固定：M04识别当前已选补液节点 → M03-P04以M07-023读取当前FEEDING固定包 → 按固定泵编号或包内外置泵设备绑定匹配 → M02读取有权液袋及缺失料液名称 → 白名单字段写入模式步骤快照。未选补液不读取补液包，不要求地秤/泵速配置；功能名称来源缺失明确标注，不猜用途标签。024只投影已固定字段，026切手动保留这些字段，不为展示触发参数替换、换袋或计量写入。

异常结束APPROVAL提交（2026-10-24）：原025以异常实例识别并将reason纳入指纹 → M07-025-END-CULTURE SYSTEM守卫 → 锁原实例、当前M03操作资格及祖先/开始/占用/日期重验 → 校冻结两步及原步骤版本 → 固定CULTURE候选/完整ChangeSnapshot → M06 API09按M06_SC047判策 → 仅APPROVAL走API10建单并核回显 → 同事务保存原末步候选、实例PENDING应用态、LOCAL事件、STEP审计及幂等回执。步骤不结束，培养/占用不写；其他流程不接受reason。免审批最终保存、决定回投及自动应用尚未接通。用户已确认最终批准且设备与任务停止后应自动应用，不再等待操作人点击。
## W08人工清理接线目标（2026-10-24）

本轮恢复W08人工清理，不恢复物理派发。候选022经可信HTTP身份→M02当前实验室VIEW/真实Waste槽位→M03培养范围、有效占用及feeding选择→M04 W08定义→M07正式连接/资源占用事实，返回可选性及M07管理版本；不在读口产生副作用。批写按服务端manifest恢复/锁定全部成员→当前权限、版本、配置及阶段全量校验→同一事务应用全部确认零量或取消→步骤/实例/事件/审计/幂等回执。失败全批回滚，取消不清零，原键重放不重复应用。目标及逐项实现状态以[页面W08](任务页面与接口契约.md#w08-当前页面接线目标2026-10-24)和[执行台账](history/review/2026-10-24-W08-接线执行台账.md)为准，不能将本节视为已运行证据。

## W03模拟完成与取消（2026-10-23 P07）

BenchConnectionBatchController的connect/complete或connect/cancel接双头/固定DTO → BenchConnectionBatchService专用模拟父守卫先恢复原回执 → 新apply复核全部原成员权限 → 稳定锁原manifest及全部步骤 → 全量prepare阶段/版本/历史/全泵停止/无真实物理记录 → 全部步骤及活动实例终态CAS → LOCAL关闭事件/全量workflow UPDATE审计/一份回执 → 当前权限复核 → 完整终态批详情。VIEW读保留关闭人与时间并校同源closure，终态动作清空；旧LIVE、单实例绕过与W02现有路由保持原门禁。接口、阶段与回执见[页面P07](任务页面与接口契约.md#2026-10-23-w03-模拟完成跳过与取消p07)。

## W03模拟启停（2026-10-23 P06）

原operations入口接双头 → 按持久W03批模式分派SIMULATION → 专属守卫恢复原回执或新apply → 当前全成员操作权限 → START检查开关及当前配置，STOP依原模拟状态 → 稳定锁实例/步骤与版本核验 → 模拟引擎逐泵状态机 → 步骤CAS/事件/审计 → 回执前权限重验 → 返回显式SIMULATED；前端随后GET整批。真实设备派发器不参与该分支；旧无模式实例不自动转模拟。协议见[页面P06](任务页面与接口契约.md#2026-10-23-w03-无设备模拟预填充p06)。

## W03装量确认（2026-10-23 P05）

专用`POST /run/workflow-batches/{batchId}/connect`解析双头与完整manifest → `M07-025-W03-CONNECT`守卫恢复原回执或新apply → 当前全成员M03操作权限 → M02配置重读及冻结身份/容量核验 → 稳定顺序锁M07实例/步骤 → 全量版本、CONNECT阶段及每瓶正整数装量校验 → 仅活动CONNECT步骤CAS、事件和步骤UPDATE审计 → 返回前重验当前权限 → 完整批详情推导PRIME_READY。失败不局部推进，原回放不重新写入。实体瓶身份后补，物料会话/泵命令保持关闭，详见[页面P05契约](任务页面与接口契约.md#2026-10-23-w03-整批装量确认p05)。

## W03批量启动与成员移除（2026-10-23 P04）

原023入口接收Header/WriteMeta及W03同lab多培养 → 一次父守卫回执查询 → 仅新apply稳定顺序锁M03全体培养，逐项真实准入及M02固定泵/液瓶锁读 → 全量预检通过才创建完整批次/步骤/事件/全量审计。原请求重放不重做准入或创建，查询当前全员权限后返回原批次。

唯一GET批详情按持久归属分派SC/W03/W02，逐一保持各拥有方的VIEW校验与顶层managementRevision，不能在权限/业务异常后改用另一实现。W03移除入口绑定双头及完整原manifest版本 → 父守卫 → M03全员当前范围锁读 → 稳定顺序锁全员workflow/steps → 阶段、末成员、版本及零物理历史全量验证 → 目标CAS取消/事件/审计 → 返回完整批详情。根取消不改变batchId，未发生物理副作用才可移除，不触发培养释放。字段及动作边界以[页面契约](任务页面与接口契约.md#2026-10-23-w03-当前页面批量启动与受控移除p04)为准。

## W06 选择上下文与页面真实接线（2026-10-23）

1. `GET /run/workflows/sampling-slots?labId`：Controller核`run:workflow:query`，公共QUERY_CURRENT前置解析器读取M07顶层管理版本；应用服务核M01当前会话 / request / authz，M02先校当前实验室VIEW并提供第1、2槽及真实控制器身份，再核M02小试上游类型、M04 W06启用定义、M03当前唯一培养及操作权限、M07同培养W03完成事实和同瓶在途换瓶。候选携可选性、核准克重及展示来源，不直查其他模块表。
2. 下一步发M07-023，携本读口版本和原始液瓶ID集合；管理守卫内按控制器去重重验培养与连接，锁读槽位并核对配置版本后创建真实两步实例和快照。新写指纹不包含可变PLC读数；原键回放仍校当前操作范围，不重复创建。
3. M07-024读详情及同模块新版本；M07-025按步骤版本依次NEXT开始步骤、COMPLETE开始步骤、NEXT换瓶步骤。推进前步骤须已完成；页面沿现有两步交互，不将这三次服务端步骤写暴露为新界面。
4. 换瓶完成只提交保留资源键及版本，后端确认原冻结集合非空唯一子集，全部预检后会话 / M02满瓶投影 / 步骤及实例APPLIED同事务。移除项留痕不应用，after满量来自服务端，不从浏览器计算值取数。
5. 取消二次确认后M07-027提交`cancelConfirm=true`、实例版本及管理双头。仅未应用且安全的实例取消；前端收到真实确认后清理当前选择，审计保留。未知写保留原键 / 版本 / 载荷并按账号、实验室隔离，禁止新键盲重发。

本接线不包含预填充、设备命令、耗材库存扣减、培养绑定或持续PLC采集。HTTP / 浏览器 / 数据库验收另按执行台账记录。

## M07-016 台式取测追加（2026-10-22）

1. 既有取测弹窗读取015余额及029账本（`entryKind=WITHDRAWAL`），由015顶层`managementRevision`和`data.objectVersion`分别取得管理/运行版本；不借用M03重量版本或其他模块revision。
2. `RunCultureController#appendWithdrawal`校功能权限`run:balance:append`，以Path绑定培养、WriteMeta双头绑定元数据；只调用`CultureWithdrawalService#append`。
3. 服务校正数克数、最多两位小数、正版本和存储范围；用培养ID、规范化金额及期望运行版本构造守卫指纹，沿`M07-016`进入SYSTEM管理守卫。操作者取守卫解析的可信会话。
4. 守卫回调经M03 `CultureOperationFactsPort(sourceModule=M07,sourceAction=M07-016)`重验当前操作范围；限定当前`BENCH_CONTROLLER`，核培养归属与M07运行行lab一致。锁`run_culture_runtime`并校`expectedRuntimeVersion`，缺行、无权、错误设备或过期版本在入账前拒绝。
5. 预分配账本ID，追加`run_ledger(WITHDRAWAL,MANUAL)`，`culture_delta_grams=-amountGrams`、`material_delta_grams=0`；计量证据固定可信操作者、服务端时间和前后运行版本。CAS增加`total_withdrawal_grams`、更新`last_ledger_id`并递增`object_version`，累计超出存储范围或CAS失败整事务回滚。
6. 同事务追加`WITHDRAWAL_APPENDED` LOCAL事件、RUN_LEDGER INSERT审计、管理revision及幂等回执；任何一项失败向公共守卫传播，不能返回部分成功。不发泵命令，不更改M03培养或物料袋投影。
7. 重放命中公共回执时不重做回调；先复核当前M03权限，再按原账ID精确读取并核培养/lab/原操作者/来源键/金额/完整内容hash/入账版本，返回原结果。页面对未知结果沿原双头、载荷、运行版本重放；明确冲突后才刷新并由用户重试。

本节状态仅`IMPLEMENTED`，验证结果另记；不能据此声称目标数据库事务、HTTP或浏览器验收通过。

## W02 整页模拟更换料液分派（2026-10-21，V4.2复核）

用户已确认整页所有所选泵统一推进、最终保存和取消；此前逐泵独立推进由本节覆盖。本轮为**IMPLEMENTED + CONTRACT_TESTED（本轮48类645例；SQL/真实HTTP/前端/设备未验证）**，前轮逐泵测试不证明本轮聚合。022～027既有功能权限及双头不放宽，新增PilotReplacementBatchController的三条公开路由；真实数据库/HTTP/浏览器/设备NOT_VERIFIED。

1. 原022 → PilotReplacementSourceService：M03当前操作范围/真实开始完成/有效占用/feeding → 当前完整P04、M04固定三步 → M02当前配置 → M07同lab/culture最新完整W01模拟连接及最终APPLIED旧袋。按真实binding配泵，缺糖浓度给显示issue。卡片及basicInfo提供真实反应器分组信息，实际重量缺映射时空值及原因，不假造观测。
2. 原023 → PilotReplacementStartService：校1～10个唯一pumpTargets和当前HTTP可信actor；完整父请求指纹进入一次M07-023-W02-BATCH SYSTEM守卫，全量来源预检后预分配所有ID，首ID=batchId；原子创建每泵子实例/三步、共同有序manifest、LOCAL事件/全量审计/回执。派生数据库request键不调用子guard，不改变HTTP元数据。重放按持久资源身份恢复全员并复核当前权限。
3. GET /run/workflow-batches/{batchId} → **2026-11-03 归属订正**：当前统一入口为 `WorkflowBatchQueryController` → `WorkflowBatchQueryService.getBatch`，按持久归属分派（开始培养 → W08 → W03 → W02 兜底）；下列为 W02 兜底分支的 `PilotReplacementBatchService.getBatch` 行为：先用原024核root的VIEW，核服务端root/manifest/实际成员一致后逐员用024权限及白名单详情；@CurrentManagementRevision返回顶层managementRevision。items按manifest，供前端按basicInfo反应器/培养分组；OPERATE只影响控制与型号选项，无操作权不剥夺已有查询权。
4. POST /run/workflow-batches/{batchId}/steps → operateBatchStep：功能权限和Header/WriteMeta → 当前HTTP身份/全员范围/精确成员及完整载荷 → 一次M07-025-W02-BATCH SYSTEM守卫 → 重读可信manifest，稳定ID顺序锁全部workflow及固定三步 → 校全部workflow/step预期版本 → 全员core.prepareBatchStepLocked（零CAS/事件/业务写） → 全部通过才apply所有成员并写全量审计和一份父回执。步骤2仅STAGED/NONE；最终全页COMPLETE/确认SKIP才同时COMPLETED/APPLIED，任一失败全批回滚。
5. 整页无任何PRIME_START而完成、或显式SKIP，须skipConfirm及原因；整页部分有预填充时可整体完成，未做成员写PAGE_PARTIAL_PRIME，不伪造skipConfirm。全部STOPPED/无未决前不最终保存。
6. 原026单泵operation → PilotReplacementSimulationService：START/STOP及精确pumpRef/当前步骤版本，独立M07-026-SIMULATION STEP审计和LOCAL回执；新START重验当前来源/最新W01及同泵跨实例busy。W01/W02均仅在无实测计量的模拟路径允许不同泵共模拟秤并行；同泵跨实例busy及真实计量排他不变。SAVE/直接START均核净重正整数1～100g。STOP仍核当前权限和冻结运行状态，不因方案漂移阻止安全停止；不进入真实dispatcher。
7. POST /run/workflow-batches/{batchId}/cancel → cancelBatch：cancelConfirm=true、全员expectedWorkflowVersion、全部当前权限 → M07-027-W02-BATCH同一守卫锁全员/步骤 → 全员prepareBatchCancelLocked验证停止/无未决 → 全部apply为CANCELLED/NONE，放弃本次全部暂存，保留原表单/事件/审计。任一仍运行或版本冲突整批拒绝；当前袋只继承最终APPLIED来源。
8. 原单实例025/027识别有manifest的W02后拒绝绕过整页，原024及单泵026保留；无manifest历史不从时间/请求身份猜批或迁移。批写重放后仍核全部当前权限，再读受控当前详情，不重做动作。所有本地应用、审计与父回执失败均传播并回滚，不用前端多请求拼装原子性。

本链只写模拟实例/步骤/LOCAL事实及管理回执；不调用真实Worker、不写materialSession/计量账/运行连接或计划。接口字段见[页面契约](任务页面与接口契约.md)，JSON/manifest及事务见[JSON契约](数据库JSON与事务契约.md)。

## W01及既有命令接线

2026-10-21 W01模拟接线：Controller保留原025/026/027路由、功能权限、Header权威及WriteMeta。应用分派从服务器已固定的SIMULATION实例识别本分支；025/027沿原管理操作码，026用独立内部M07-026-SIMULATION审计实际STEP更新，真实M07-026仍是COMMAND插入。所有模拟写在SYSTEM守卫回调中锁实例/三步、核对当前M03范围和必要冻结来源、全量校验后CAS步骤/实例、写独立LOCAL事件及公共审计/回执；没有真实派发器调用。重放后仍检查当前对象权限，typedPayload非空进入025指纹且W01拒绝该外来载荷。STOP及取消只核当前权限和原模拟状态，不被新方案阻止安全停止；新START/切自动/推进继续完整重验。024从最高已进入步骤投影最新模拟状态并保留前序完成快照，额外显示字段见页面契约。

2026-10-21 W01增补：M07-023按真实编码connect_feed_unit_pilot分派PilotWorkflowStartService，仍在既有SYSTEM守卫/幂等/审计事务内精确重验单培养、权限、开始完成、占用及方案代次，创建OPEN实例与固定三步，不创建物理就绪事实。M07-024先沿现有范围读取有权实例，再从冻结定义严格投影名称/说明/图示；模板ID、运行ID和M04来源hash分别核对，原始包不出响应。M07-027锁实例后仅为无推进/命令/执行/资源占用的W01草稿分派专用CAS取消，保留审计和表单；实际动作后的安全收尾未因本次开放。各分支最高验证层级为编译及定向契约测试，HTTP/实库/设备未验证。

2026-10-18 M07-026：双头/权限绑定→检查真实命令提供方与后台部署资格→守卫内锁工作流、经M03当前身份操作范围检查、校验步骤/实际M02核准规格、固定执行器/全资源/物料会话→完整v1 execution及PREPARED命令与事件同事务提交→专用协调器复用受控短事务CAS INVOKING→事务外M02调用→新资源事务落完整回执。提交后派发失败不撤销已提交意图、不改请求键。崩溃扫描仅拾取W03/W07有execution的PREPARED START/STOP，UNKNOWN沿原命令查单。具体字段/门禁以[ExecutionSpec增补](ExecutionSpec版本与观测兼容契约.md#2026-10-18工作流冻结接线边界)及[命令契约](设备命令契约.md)为准；未取得核准profile、实际版本/适配器或现场依赖时阻断；W08暂停。

## 开始培养专项增补（SC-20261017）

开始培养调用按专题第7～9节：现有Controller只鉴权/绑定，显式分派StartCultureWorkflowService；最终由StartCultureCompletionService经M03/M09 Port同库编排，必须获得RuntimeFact APPLIED才返回完成。设备采集/命令/重启在主业务事务外；批量取消先接受整组意图再安全收尾，不能逐个完成造成半组生效。

最新保存规则（2026-10-17）：小试、中试均只在第4步点击“完成”并成功提交后保存业务数据；未完成页面刷新或取消后从第1步重新开始，不恢复表单或中间步骤。操作审计和设备安全收尾保留，必须当天完成的限制不变。

步骤时间记录：四步分别记录服务端开始/结束时间及结束原因；刷新重开新建尝试，旧时间审计保留，未知结束时间不伪造。时间留痕不构成业务表单的中间保存点。

当前专题：[开始培养详细设计](开始培养工作流详细设计.md)；实施拆分：[开始培养开发计划](../../开发任务/小试中试开始培养开发计划-20261017.md)。本次仅文档补充，业务代码、数据库、设备操作均未执行。


> 2026-10-14 用户最新范围：M07-034/035 本期不启用，按停用入口登记，不进入本期接线与验收分母。M07-005～010、028、033 以 WriteMeta 头绑定请求身份及管理版本，路径对象覆盖 Body 同义对象字段；005～010 已接真实应用链，033 已接 M02 权威资格读取、整组原子移交及长期回执恢复，028 因真实重启协议和外部执行通道未交付而失败关闭。Controller 绑定、源码实现、依赖到货和运行验收不得混为同一状态。

本次入口绑定沿用公共 RequestMetadataFilter/WriteMetaArgumentResolver：显式请求 ID 必须合法，缺请求 ID 时公共层生成关联 ID，Body 不得成为身份来源；缺失或非法管理修订拒绝进入应用服务。前端仍必须发送两个头以维持重试身份。应用服务仍为 501 的方法不提前添加表示真实守卫接线的 `@ManagementGuardedWrite`；实际实现时同步接入管理守卫、审计及方法标记，不放宽任何现有元数据校验。

> INTEGRATION-20261010：Controller经现行应用服务完成权限、候选/审批、培养与资源版本校验后，按[任务执行接入契约](三类实验室任务执行接入契约.md)选择唯一执行路径。一期交已核准旧业务链并仅做投影；新执行路径先持久化执行段/命令，再经M02下发。回执未知先查原命令，停止与结算核准后才终结，不以HTTP成功直接完成任务。

每个入口的物理类型和Mapper三元组以[物理接口与骨架字段设计](物理接口与骨架字段设计.md)为准；本文中的`M07.定位xxx`是逻辑端口ID。

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

## 1. Controller入口逐项映射

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位001 | GET /run/tasks | 任务页面与接口契约.md | M07.定位001 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位002 | GET /run/tasks/{id} | 任务页面与接口契约.md | M07.定位002 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位003 | GET /run/task-candidates/resources | 任务页面与接口契约.md | M07.定位003 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位004 | POST /run/tasks/precheck | 任务页面与接口契约.md | M07.定位004 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位005 | POST /run/tasks | 任务页面与接口契约.md | M07.定位005 | CTRL-CMD / CTRL-QRY-RECOVERY | 无originalCreationRequestId走原守卫写；有值先分流只读恢复，权限/载荷/全部培养回执核对后返回原结果，零写入/零版本递增；见页面契约第三轮登记 |
| 定位006 | POST /run/tasks/{id}/changes | 任务页面与接口契约.md | M07.定位006 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位007 | POST /run/tasks/{id}/cancel-requests | 任务页面与接口契约.md | M07.定位007 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位008 | POST /run/tasks/{id}/pause | 任务页面与接口契约.md | M07.定位008 | CTRL-EXT | 意图先提交；事务外调用；UNKNOWN查单恢复 |
| 定位009 | POST /run/tasks/{id}/resume | 任务页面与接口契约.md | M07.定位009 | CTRL-EXT | 意图先提交；事务外调用；UNKNOWN查单恢复 |
| 定位010 | POST /run/tasks/{id}/exception-handling | 任务页面与接口契约.md | M07.定位010 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位011 | GET /run/tasks/{id}/logs | 任务页面与接口契约.md | M07.定位011 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位012 | GET /run/tasks/{id}/executions | 任务页面与接口契约.md | M07.定位012 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位013 | GET /run/executions/{id}/samples | 任务页面与接口契约.md | M07.定位013 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位014 | GET /run/executions/{id}/commands | 任务页面与接口契约.md | M07.定位014 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位015 | GET /run/cultures/{id}/balance | 任务页面与接口契约.md | M07.定位015 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位016 | POST /run/cultures/{id}/withdrawals | 任务页面与接口契约.md | M07.定位016 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位017 | GET /run/cultures/{id}/glucose-candidates | 任务页面与接口契约.md | M07.定位017 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位018 | POST /run/manual-results | 任务页面与接口契约.md | M07.定位018 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位019 | POST /run/confirmations | 任务页面与接口契约.md | M07.定位019 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位020 | POST /run/confirmations/{id}/cancel | 任务页面与接口契约.md | M07.定位020 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位021 | GET /run/confirmations/{id} | 任务页面与接口契约.md | M07.定位021 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位022 | GET /run/workflows/candidates | 任务页面与接口契约.md | M07.定位022 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |


| 定位023 | POST /run/workflows | 任务页面与接口契约.md | M07.定位023 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位024 | GET /run/workflows/{id} | 任务页面与接口契约.md | M07.定位024 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位025 | POST /run/workflows/{id}/steps/{stepId} | 任务页面与接口契约.md | M07.定位025 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位026 | POST /run/workflows/{id}/operations | 任务页面与接口契约.md | M07.定位026 | CTRL-EXT | 意图先提交；事务外调用；UNKNOWN查单恢复 |
| 定位027 | POST /run/workflows/{id}/cancel | 任务页面与接口契约.md | M07.定位027 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位028 | POST /run/services/{id}/restart | 任务页面与接口契约.md | M07.定位028 | CTRL-EXT | 意图先提交；事务外调用；UNKNOWN查单恢复 |
| 定位029 | GET /run/cultures/{id}/ledger | 任务页面与接口契约.md | M07.定位029 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位030 | GET /run/cultures/{id}/glucose-history | 任务页面与接口契约.md | M07.定位030 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位031 | GET /run/executions/{id} | 任务页面与接口契约.md | M07.定位031 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位032.1 | GET /run/executor-assignments | 审阅收尾执行器与接续契约.md | M07.定位032.1 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位032.2 | POST /run/executor-assignments/{resourceKey}/transfers | 审阅收尾执行器与接续契约.md | M07.定位032.2 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位033.1（M07-034） | POST /run/cultures/{id}/legacy-handovers | 审阅收尾执行器与接续契约.md | M07.定位033.1 | CTRL-CMD，2026-10-11本期排除 | 后续范围设计；本期不接管旧任务、不开放入口，仍501不计入本期接线缺口 |
| 定位033.2（M07-035） | POST /run/legacy-handovers/{id}/review | 审阅收尾执行器与接续契约.md | M07.定位033.2 | CTRL-CMD，2026-10-11本期排除 | 后续范围设计；本期不核准旧任务接管，不影响新系统执行器运维移交 |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| CMD-I01 | submitCommand | 设备命令契约.md | CTRL-EXT | 命令意图/fence先提交；ACCEPTED不等EXECUTED |
| CMD-I02 | queryCommand | 设备命令契约.md | CTRL-EXT | 仅查原commandId；NOT_FOUND不证明未执行 |
| RUN-OBS-I01 | appendExecutionSample | 业务观测采样与告警交接.md | CTRL-INTERNAL | 固定执行器身份、execution/segment/fence匹配；同键异hash留冲突 |
| RUN-B01 | applyCultureInputChange | ../03-项目与培养管理/模式与初始重量开发契约.md | CTRL-INTERNAL | candidateId幂等；与M03生效同本地事务；未开始计算失效 |
| RUN-EVT-I01 | publishRuntimeFact/resolveReleaseProof | ../03-项目与培养管理/运行事件资源释放与延期收尾契约.md | CTRL-INTERNAL | publish按sourceEventKey/hash/sequence单调且ACK与应用结果分开；release proof必须加入M03管理守卫事务，以W03冻结occupancy/device、runtime版本及活动guard/命令/执行完整计数失败关闭 |
| RUN-EVT-I02 | RuntimeFactProofPort.verifyRuntimeFact | ../03-项目与培养管理/运行事件资源释放与延期收尾契约.md 2026-10-15补充 | CTRL-INTERNAL | 仅M03 R03固定后台能力与同一资源事务；原事件列/正文/摘要与真实W03实例重核；缺源事件、未知类型或身份不符失败关闭 |

## 4. 模块内调用约束

- HTTP字段必须先映射为 M07 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

本文件自动登记 35 个目录内HTTP入口、0 个内部定位项、0 个尾部补登记入口。数量校验只防漏项；逐接口仍须以来源契约完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。

W05补充：022/023/024/025/027沿[W05逐接口契约](W05手工补料逐接口契约.md)分发；Controller不接Mapper。023在SYSTEM守卫内全量核验后创建每培养实例；025在同一守卫事务内重验权限/冻结来源、锁runtime，追加唯一来源账、CAS投影与步骤终态；027仅取消未提交W05。未知结果沿原双头与载荷重放，已完成不接受新键重复记录。

## FEED-20261020：原因与日期检查插入点

沿原认证、范围、请求身份/回执、版本及守卫时序，在合法预检、审批应用/入队和首次派发前复核[首次开始日期及恢复矩阵](任务状态调度与异常恢复.md#feed-20261020首次开始日期与原因判定)；实际首次启动入口还须M02/客户服务复核，Controller通过不等于设备准入。原请求只读恢复必须返回原结果，不以当前日期重新执行原动作。

GET与预检不写跨天取消；调度在原守卫内确认从未开始且无已发/未知命令才按DAY_CANCELLED关闭。原因与HTTP复用见[错误码全集](错误码全集.md)，已有证据校验专项400、权限/版本/幂等拒绝保持。允许已合法开始的原任务跨午夜收尾/续段，未知START查原身份，任何保护停止不因日界被拒绝。

## M07-RC01 运行规则读取（2026-10-26 增补）

RunCultureChangeController.calculationContext 检查 resource:culture:query，经应用服务调用 M03 CultureFeedingConfigurationPort。M03 在同一只读事务先验证当前身份的培养操作范围及 RUNNING/DELAYED，再读取有效配置和真实版本；响应顶层 CurrentManagementRevision 供后续 M07 写入口使用。缺配置、未知枚举、停用或版本缺失明确失败，不调用写守卫、不创建候选、不操作设备。现有 settings-dialog 经 cultureRuntimeApi.calculationRuleContext 消费本读口，提交审批链仍按专项契约继续实施。

M07-RC02—04：Controller.current/detail/originalRequest → RunCultureChangeApplicationService → M03 CultureOperationFactsPort逐次校验当前培养访问范围 → M07 RunCultureChangeCandidateMapper读取固定记录。原请求查询的actorId只来自SecurityUtils，不接浏览器传参；返回前核对候选cultureId/labId，PREPARED或损坏快照拒绝。历史回执查询不受RUNNING/DELAYED限制，也不重新执行原动作；当前无活动候选可返回空，读取失败必须传递错误。M06待审PENDING不展示为APPLIED。

M07-RC05：Controller.submitCalculation鉴权resource:culture:edit，Path培养ID、Body完整五字段与双期望版本、Header WriteMeta分别进入应用服务。NOT_SUPPORTED避免类级只读事务包住写守卫，ManagementGuardExecutor负责SYSTEM/幂等/版本/审计事务；M07固定候选并评估SC033。DIRECT/DIRECT_REASON调用M03配置CAS及M07任务屏障/重算/重新判策；APPROVAL只保存真实审批绑定。提交结果保留原回执，不把PENDING当作生效。M06 CULTURE交付复核固定身份后按SYSTEM→M03培养→M07运行/任务→候选CAS顺序执行，写前4xx冲突可结案，依赖/写入异常回滚；相同决定重放不重复重算。前端使用现有补液计算规则弹窗提交。


M07-RC06：Controller.deviceContext → RunCultureChangeApplicationService → M03 CultureRuntimeOperationPort；同一只读事务校验当前培养范围、运行状态、设备种类、占用和版本。读取不释放设备，不产生设备命令或更换提交。

## 2026-11-07 V5.1开始/结束生命周期消费

开始培养按本培养实际前置、确定计划与当日规则；按用户最新确认，小试和中试未完成时不产生首次开始事实，最终完成保存成功时在事务内处理首次及完成事实，并由M03处理培养状态。[开始主专题](开始培养工作流详细设计.md)拆分后的会话/接口事务/验收文件保持原编号；不改变其他工作流的启动审计。
小试/中试结束M07-022—027按[小试结束](小试结束培养接口契约.md)、[中试结束](中试结束培养接口契约.md)末节分类：结束延期先改计划、正常按已选环节操作记录、未执行任务提醒/确认后按原取消审批、执行/暂停补液先处理、执行取测继续。不得沿旧“全部活动任务/资源计数为0”统一拦截；执行取测保留其自有资源和冻结关联，Q-3-04按既有归属规则闭合。
完成/释放写M03前按当前生效计划和原占用复核，不把审批通过或设备切手动视为完成。跨期待审提前取消按Q-3-06继续原取消申请，获批且安全条件满足后CANCELLED，实际结束取申请内记录时间；其他结束仍按第7/44问；设备I/O事务外、状态及审计同事务。

## S04第2组增量时序（2026-11-07，目标未接线）

004/005：Controller鉴权/严格taskType绑定→现有应用服务按[参数契约](控制任务参数与执行交付契约.md)聚合M03范围/生效包、M02资源、M05结果→服务端唯一展开→预检只读/创建全量校验后同事务任务+适用审批+审计/原管理回执→响应。人工五类无工作流门槛，SAMPLING开始完成保持；当前真实实现仅FEEDING/SUGAR。

022—027自动控制：[四步契约](自动控制工作流与规则执行契约.md)→M07现有工作流/步骤Mapper，末步完成调用M03目标普通完成Port，监控任务+审计行锁同事务；真实服务重启/控制/检测HTTP事务外，按原执行身份回写真实结果。不得增加投递状态机或声称锁覆盖物理未确认窗口。

038—043：[LoadSample](LoadSample运行交付契约.md)Controller目标→M07应用服务全选权限/孔位/版本/占号/参数→原模式/耗材控制方→原记录/订单provider→M05 DET-I03/04/05→原BatchJob释放；无培养载体及provider缺口Q-2-03，不能虚构完整生产链。

044—046：[控制台](小试控制台操作与计量契约.md)Controller目标→M07应用服务范围/能力/动作校验→M02或原控制方Port→现有操作/审计；短事务与设备分离。计量真实认可后调用原累计通路，正常真取样仅一次、清洗不扣培养。具体源映射仍Q-2-04，编译/HTTP/浏览器/设备未验证。
