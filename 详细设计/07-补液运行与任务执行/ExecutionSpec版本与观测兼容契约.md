# ExecutionSpec 版本与观测兼容契约

版本 DD-20260917-G04。仅设计。本文是 execution.execution_spec 的版本分派和字段白名单权威；[泵速与恢复](泵速执行与设备恢复契约.md)提供执行语义，[JSON契约](数据库JSON与事务契约.md)提供引用对象叶子，[观测交接](业务观测采样与告警交接.md)提供采样证据模式。不得任选一份旧定义覆盖新版本。

## 1. 字段集合与必填条件

两个版本共同必有：schemaVersion、taskId、taskVersion、workflowOperationId、cultureId、planSnapshotId、version、hash、pumpRef、scaleRefs、materialSessionId、speedSelection、strategySnapshot、configurationRevisions、capabilityRevision、measurementPolicy、calculationId、targetGrams、resourceKeys、resourceClaims、authorizationEvidence。将旧稿的“taskId/taskVersion或workflowOperationId”“planSnapshotId/version/hash”明确为这些叶子，不接受带斜杠字段名。既有落盘v1如使用已冻结的等价结构，必须按其原schema读取与校验旧hash，不能按本次文字展开重写旧数据；实施前以真实已部署v1序列化测试样本确认适配，未确认不得迁移或启用v2。

| 字段组 | 条件/类型 |
| --- | --- |
| taskId、taskVersion、workflowOperationId | TASK来源前两者为ID/Version、后者null；WORKFLOW来源前两者null、后者ID；互斥且恰有一条来源；来源由服务器固定 |
| cultureId | 稳定ID，必须与来源对象一致 |
| planSnapshotId、version、hash | 存在方案来源时三项一起为ID/Version/64hex；合法无方案的工作流操作三项显式null，由原操作准入决定，不可用null绕过必需方案 |
| pumpRef、scaleRefs | 原DeviceRef及有序DeviceRef数组，真实使用的设备全量列入；不是任意展示编号 |
| materialSessionId | 涉及物料计量的当前合法session ID；必需但未知时BLOCKED，不造0 |
| speedSelection | 沿泵速契约 CODE/FIXED/STRATEGY 的判别对象及对应字段，未选分支字段不得混入 |
| strategySnapshot | STRATEGY必须完整M04冻结PUMP_SPEED包；其他分支null |
| configurationRevisions | 原设备/通讯配置版本快照，全资源一致可核验 |
| capabilityRevision、measurementPolicy | 核准能力版本及JSON契约完整MeasurementPolicy；缺安全字段不可启动 |
| calculationId、targetGrams | 原计算ID及正十进制g字符串，必须与计算/来源一致，不信前端提交量 |
| resourceKeys、resourceClaims | 固定资源键列表；resourceClaims=[{resourceKey:string,fence:十进制字符串}]，键集合相等且无重复，按resourceKey字典序固化 |
| authorizationEvidence | 原授权证据快照，不存token；不因历史证据存在就免当前启动准入 |

v1：schemaVersion=1，不允许sampleIdentityVersion；保持已存在执行原采样身份。
v2：schemaVersion=2，另必填且仅允许sampleIdentityVersion=2；其他字段及约束同上。数字版本是JSON整数，所有业务ID/对象版本为字符串。不认识版本或出现未知键拒绝新写；已存未知版本只显示“不支持/需升级”，禁止启动、恢复控制或重算结算。旧v1的可兼容读取不表示批准用不完整历史参数重新执行。

## 2. hash 与不可变性

### 2026-10-18工作流冻结接线边界

W03/W07独立预填充新写使用完整v1。M07-026将服务器分配的首次START commandId作为workflowOperationId；taskId/taskVersion、无方案的planSnapshotId/version/hash、calculationId显式null。目标量及CODE/FIXED速度来自已校验、持久化的用户操作意图；不生成假计算身份。执行先以NOT_STARTED写入run_execution（task_id=null、step_instance_id真实），与完整资源claims、PREPARED命令和完整事件在同一管理守卫事务提交。command.executionRef指向该EXECUTION的初始版本及完整spec_hash，不再hash选择快照/表单冒充执行规格。

物料session由M07按当前培养/实验室/实际资源锁读ACTIVE唯一事实；M02提供的工作流泵规格新增可空executionProfile（内部DTO增补，现有Port方法签名不变），是核准计量/配置事实束，字段严格为scaleRefs、measurementPolicy、configurationRevisions、resourceKeys、materialResourceKey、timeoutMilliseconds。前四项沿本契约既有叶子；materialResourceKey定位M07真实装载会话，timeoutMilliseconds为正bigint十进制字符串，必须来自核准期限，不能设默认。完整核准策略、能力版本、实际配置版本及适配器身份任一缺失即阻断，不用SYSTEM管理版本或controllerNo代替。

当前M02旧通道主档只能提供静态泵绑定及速度范围，**尚无核准profile/实际配置元数据的权威生产链**；不得因DTO可承载就声称生产事实已提供。应由M02明确其核准存储/来源及真实适配器登记后的同代关联，M07不从M02 Mapper取数或从页面接收这些事实。本批保留这些字段unknown，隔离测试使用合成profile，不发布到运行配置。

PRIME_STOP定位本步骤唯一原执行，复用完整规格/哈希/目标/物料及claims，并核对原START的配置和适配器；不重算、不增加执行尝试、不用新fence解释旧执行。存在其他未决命令时先按原身份核对，不盲目补发。仅当完整停止/计量/监控证据满足后，独立安全收尾链才可关闭执行和释放资源，本批命令回执不替代该链。

SET_AUTO不带目标量，而当前v1和run_execution要求正目标量，两者没有可直接复用的非计量规格。本批将其标CONFIGURATION_INCOMPLETE，需确认非计量执行承载后再实现，不填1g或复用无关执行。重复预填充尝试同样不得绕过原执行安全收尾。本段不批准v2启用、不迁移旧数据，W08继续暂停。

spec_hash覆盖完整规范execution_spec（包括schemaVersion、resourceClaims，v2还含sampleIdentityVersion），不把spec_hash自身放入JSON，也不把后续命令/状态/修正速度混进原spec。对象键按字典序，无空白UTF-8、无BOM/末尾换行；十进制字符串沿公共规范；null与缺键严格区分；业务数组顺序由对应schema固定，不能统一排序所有数组。规范规则变化必须新schema，不在v1/v2同版本里静默换算法。

旧执行保留原JSON、原hash、原source_sequence；校验由其原版本编码器承担。v2样本raw_readings使用观测交接的v2且identityVersion=2；v1执行不接v2样本、不补boot/event证据。OBSERVATION_ALARM payload v2是独立事件版本，发送器仍抽取其中m09Event v1交M09；不能因spec升版升级所有JSON列。

## 3. 升级和回退门禁

先部署读端/执行恢复器/样本写入器的v1+v2识别和测试，再对新执行开启v2。新版本尚未全链路支持时不创建v2执行；已有v1执行继续其原规则直至结束，不切换同一执行身份策略。发布记录包含消费者版本、schema支持集合和启用证据，不以M08是否部署作为门禁。

关闭v2新建开关不等于可以卸载v2读端。存在v2运行/暂停/未知命令或待结算时禁止降级控制器；历史v2仍需可读、可核验的兼容读取服务，不能仅以活动执行清零删除历史解析能力。任何版本升级不减弱固定单执行器、fence和停泵证据要求。

## 4. 固定测试向量及验收

下列是**hash子集测试向量，不是可启动ExecutionSpec**，用于验证版本字段和resourceClaims是否被摘要覆盖。规范串不含换行：

V1：`{"resourceClaims":[{"fence":"7","resourceKey":"pump:1"}],"schemaVersion":1}`
SHA256：`1ccfe3a0994532359cce158b085c88c46dfd4bf79995db7169020a10e74a9344`

V2：`{"resourceClaims":[{"fence":"7","resourceKey":"pump:1"}],"sampleIdentityVersion":2,"schemaVersion":2}`
SHA256：`4c7388af6481b7d36e9ff5780df2cce8190d5f0eeef6fc4b3f0e1b84a405555c`

G04-A01：同合法完整spec仅改变schemaVersion/增加sampleIdentityVersion，hash必须变化；改变fence也变化；仅调整对象键输入次序规范后hash相同。合法完整fixture须由核准设备/方案配置生成并冻结，不能用上述子集启动。
G04-A02：v1夹带新键、v2缺identityVersion、错误类型、未知v3及样本版本不匹配拒绝；不产生命令。
G04-A03：旧v1字节/hash回读不变；升级期间v1/v2并行执行各自保持原身份，重复样本只计一次。
G04-A04：M09仍接Event v1；M08禁用不影响样本/曲线；v2未知命令阻断降级。

本轮只计算上述SHA256向量；完整序列化fixture、应用解析及设备恢复用例未执行。


### 2026-10-18 初始计量与后续消费门禁

工作流 NOT_STARTED→STARTING 的数据库 CAS 新增前置：current_segment_id 指向同 execution 的第 1 个 OPEN 段，物料会话及起始读数非空、方向已经核准。CAS 不命中不得将命令推进 INVOKING，更不能调用设备。M07-026 已在同一守卫事务内按 M02 核准的设备类型、设备 ID、通道、指标和配置版本读取唯一 GOOD 首次计量事实，校验方向、新鲜度及来源后，原子写入 execution、首个 OPEN 分段和 current_segment_id。工作流 v1 专用实时监控及完整停止结算消费者仍须独立实现和验收。

工作流 `START` 设备命令的可信 `EXECUTED` 回执只接受 `queryResult=RUNNING`；该回执仅闭合命令，不直接猜测执行已进入 HIGH/LOW，也不替代后续采样与监控状态机。

现有 ExecutionSamplePortImpl 仅接受 v2 身份载荷；工作流仍冻结 v1，不得强行接入、伪填 sourceEvidence 或把 task 的 PAUSED 消费者当成 workflow 结算。首段读取使用独立 M02 工作流计量事实 Port 和冻结的 metric/channel/configuration 绑定，不猜测 WEIGHT 指标、秤适配器与命令适配器同一身份、默认皮重或源序列；该接线不等于实时采样、停止确认或结算链已经完成。

完整停止结算需要原 STOP 执行回执、实际停速及同代稳定样本、停后监控截止、物料会话、唯一账本来源键，同事务关闭段/固化停止证据/写 PRIME 账/推进结算，再由受控释放链复核资源。数据库现行 entry_kind 使用 PRIME，不能虚构 PRIME_FILL 枚举。软件消费者未接通和现场证据缺失必须分别报告。

### 2026-10-23 W07 停止结算消费者

`M07WorkflowSettlementTask` 有界扫描 W07 已执行 STOP 且当前段仍 OPEN、结算为 NONE 的执行，每条候选独立事务重新锁读。`M07WorkflowSettlementFinalizer` 核对原执行/fence/适配器与活动 FEED_BOTTLE 会话，复用冻结停止判据及已持久化样本；窗口不足继续等待，不制造停止证据。执行与分段 CAS、会话消耗 CAS、PRIME 账和审计事实同事务提交，失败全部回滚；关闭段及唯一来源键 `M07:WORKFLOW:PRIME:{executionId}` 防止重复结算。

PRIME 的培养增量为 0、物料增量为认可消耗量，会话保持 ACTIVE。计量证据 kind=MEASURED，业务日取实际停泵时刻的上海日期；未变更培养运行投影，其前后投影版本显式为空。此消费者不释放资源，后续仍由受控释放链复核。实现与定向测试不替代目标数据库、HTTP、浏览器及真实设备验收。

### 2026-10-23 W07 已结算资源组释放

`M07WorkflowResourceReleaseTask` 扫描 STOPPED/CONFIRMED 且仍有 WORKFLOW 占用的 W07 执行。仅以原完整规格及摘要构造声明，逐资源保留原 fence；实际释放委托 `M07ResourceReleaseWorker` 的同一受控事务，SYSTEM 首锁后重新核完整占用集合、执行器归属纪元、未决命令、逐资源版本和停止证据。任一失败整组回滚，重复扫描已释放执行不再命中。

九键 release_evidence 的形状和 STOP_CONFIRMED 词表不变，每个资源各有一份证据。控制器/秤等关联资源允许追溯同一工作流执行的主泵 STOP，但必须核验完整 v1 ExecutionSpec/hash、workflow 真实归属、CONFIRMED 结算及主泵和关联资源各自的 resourceClaims/fence；不能凭同实验室、相同设备或相同数字 fence 推导关联。原同资源命令路径仍按既有校验执行，NOT_SENT 不借用该关联规则。

现有资源事务声明只有一个 assignmentEpoch；本入口仅处理归属同一执行器、同一纪元的完整资源组，不猜测或改写不同纪元。不同纪元、UNKNOWN、未决命令、监控未结束、组成员漂移均保留占用并记录失败。释放只影响 M07 物理资源，不释放 M03 培养占用、不关闭活动物料会话，也不代替用户点击工作流完成。

### 2026-10-23 工作流 v1 停后采样连续性

工作流 v1 采样候选及写入件均覆盖 STARTING/CALIBRATING/HIGH/LOW/STOPPING 的 OPEN 当前分段，关闭段、UNKNOWN 或已 STOPPED 不继续追加。事务外读取 M02 后，锁内重新核验阶段及原规格摘要、执行器和 fence，防止将扫描后失效的绑定读数写入。读数观察时间按冻结 measurementPolicy.freshnessSeconds 判新鲜度，边界值可用，超限拒绝。

新写 Reading 的 rawValue/value 使用十进制字符串，rawValue 未提供时显式 null，与停止证据校验器相同；不得将 BigDecimal 自动序列化的 JSON number 当成已通过的停止读数。既有样本不改写摘要和载荷，不因格式不合格制造成功结算。

采样扫描默认由每 5 秒改为每秒，继续允许配置 m07.workflow-v1-sample.worker.cron；已有显式 5 秒配置不会被源码默认值覆盖，需部署时单独核对。轮询不是设备刷新，不因轮询频率提高而生成新序列或复制样本；相同 M02 sourceSequence 仍只认可一次。每秒调度亦不保证所有短窗口可满足：真实读数频率、调度延迟、冻结样本数/最小跨度/postMonitorSeconds 必须共同满足；窗口内样本不足时继续保留占用，不放宽判据、不延长冻结窗口或使用窗外读数凑数。

### 2026-10-23 当前 W07 页面启停许可

按用户确认，以当前页面及其既有 allowedOperations 消费为准，不新增前端交互或接口字段。预填充进行中步骤只有在无执行、无物理命令时返回 PRIME_START；唯一现存执行处于 STARTING/CALIBRATING/HIGH/LOW/STOPPING、无未决命令且没有已执行 STOP 时，仅返回 PRIME_STOP。STOP 已执行而仍在等待稳定计量/释放，或执行已 STOPPED/UNKNOWN、来源不完整或有多个执行时，返回空列表，不再提示重复启停。

详情查询按步骤非锁读持久事实，只提供操作提示；M07-026 在原守卫事务和当前步骤执行锁读后复用同一策略重新验证，过期页面请求拒绝且不新占资源、不创建额外命令。原权限、双头/幂等、完整规格、固定执行器及资源校验保持不变。完成/跳过仍使用既有安全门，不将操作列表为空等同于结算或资源释放成功。该补正仅覆盖 W07，W03 及中试保持原行为。

### 2026-10-23 当前 W07 页面取消安全收尾

以当前页面既有取消提示为准：已提交的业务事实不撤销。M07-027 对 W07 在原守卫事务内复核停止、结算、关闭分段、未决命令及工作流资源占用；事实不可读拒绝，存在未完成安全事实时返回 STATE_CONFLICT，保持原实例状态和版本，不将运行中实例切到页面无法再停止的 NEEDS_RECONCILIATION。用户仍可按原页面停止、刷新并在安全释放后重新取消；不新增前端操作，不因点击取消伪造 STOP 命令或停泵回执。

`M07WorkflowCancelFinalizationTask` 每轮有界扫描 100 条已有 W07 取消待核对记录，每条独立事务先取得 SYSTEM 首锁，再锁读当前实例及同版本 WORKFLOW_CANCEL_PENDING 原事件。仅匹配工作流、实验室、培养、对象版本及真实申请人的持久取消意图；其他原因的 NEEDS_RECONCILIATION 不得自动取消。再次通过安全事实校验后，以版本及原事件 ID 双重约束更新 CANCELLED/NONE、结束时间和对象版本，仅取消 PENDING/IN_PROGRESS 步骤，并同事务写入关联原请求事件的 WORKFLOW_CANCEL_FINALIZED 事实。CAS、步骤或事件写入失败整体回滚。

工作器不释放资源、不发设备命令，不撤销已完成的换瓶/物料事实。缺实际停止证据、结算或释放的旧取消记录继续保留待核对，不把后台扫描等同于已解决设备未知结果。定向测试不替代数据库 SQL、HTTP、浏览器或设备验收。
