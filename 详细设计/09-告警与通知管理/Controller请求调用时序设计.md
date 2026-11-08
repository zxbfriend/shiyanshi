# M09 Controller 请求调用时序设计

2026-11-07 S04：API01/02按有权实验室查询完整相应告警，不叠加个人参与培养过滤；API03再核原接收人/KNOWN_EMPTY例外、当前处理权限及版本。个人待办原生140逐条核设备负责人、明确通知本人和当前处理资格，无培养也合法，M08不自行推断。API04/05先实验室范围再读写对应规则；phone只按原规则及合法接收人/现有联系方式，不写个人电话选项。规则保存不调用通道；真实电话适配/HTTP在业务事务外。Q-6-03整轮全失败不计、部分真实送达计一轮，同轮后续成功不重复计，不用旧计划轮次默认消耗额度。

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

每个入口的物理Controller、ApplicationService、DTO/VO、权限及Mapper三元组以[物理接口与骨架字段设计](物理接口与骨架字段设计.md)为准；本文表中的`M09.定位xxx`仍是逻辑端口ID，不替代物理方法名。

## 1. Controller入口逐项映射

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位001 | GET /alarm/v2/records | 页面与接口契约.md | M09.定位001 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位002 | GET /alarm/v2/records/{alarmId} | 页面与接口契约.md | M09.定位002 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位003 | POST /alarm/v2/records/{alarmId}/handle | 页面与接口契约.md | M09.定位003 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位004 | GET /alarm/v2/rules | AlarmRuleConfigQuery.labId必填；页面与接口契约.md | M09.定位004 | CTRL-QRY | getLabRuleConfig先核VIEW；读取当前LAB APPLIED规则及未应用目录模板；完整集合，无global生效回退/全局receiver继承 |
| 定位005 | PUT /alarm/v2/rules | labId与rules必填，原双头权威；页面与接口契约.md | M09.定位005 | CTRL-BATCH | 原ManagementGuardExecutor整批一次；实时MANAGE、全行LAB基线/版本/目录身份校验后逐规则不可变APPLIED修订；收据/审计同事务，不外发 |
| 定位006 | GET /alarm/v2/sender-config | 页面与接口契约.md | M09.定位006 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位007 | PUT /alarm/v2/sender-config | 页面与接口契约.md | M09.定位007 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位008 | GET /alarm/v2/status-config | 页面与接口契约.md | M09.定位008 | CTRL-QRY | 先当前VIEW，再原unitCode/必要rowNo/liquidType AND过滤，完整返回不分页；候选来自本lab/tab完整真实M02布局；非空旧unitId原INPUT_INVALID提示刷新，不作站位或编号解释 |
| 定位009 | PUT /alarm/v2/status-config | 页面与接口契约.md | M09.定位009 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位010 | GET /alarm/v2/online-config | 页面与接口契约.md | M09.定位010 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位011 | PUT /alarm/v2/online-config | 页面与接口契约.md | M09.定位011 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位012 | GET /alarm/v2/offline-config | 页面与接口契约.md | M09.定位012 | CTRL-QRY | 只读；实时核验超管事实后解析培养可见域；完整检项集合，组revisionId取OFFLINE:cultureId:detectClass最近APPLIED台账，不从单个检项行推断；无当前检项仍保留已保存集合身份；同scope在途仅approvalId/applyState，不换APPLIED基线/有效rows，异常或多候选拒绝 |
| 定位013 | PUT /alarm/v2/offline-config | 原WriteMeta双头；页面与接口契约.md | M09.定位013 | CTRL-APR | 原Offline应用/guard核当前资格与scope/base；新SC046创建PENDING/v1→真实M06 submit→同事务一次绑定approval/v1；PENDING不投影，返回模块AlarmConfigMutationResult；原UUID重放保持首次提交结果 |
| 定位014 | GET /alarm/v2/monitor-policy | 页面与接口契约.md | M09.定位014 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位015 | PUT /alarm/v2/monitor-policy | 页面与接口契约.md | M09.定位015 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位016 | POST /alarm/v2/sound/{deviceId}/off | 页面与接口契约.md | M09.定位016 | CTRL-EXT | 意图先提交；事务外调用；UNKNOWN查单恢复 |
| 定位017 | GET /alarm/v2/notifications | 页面与接口契约.md | M09.定位017 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位018 | GET /alarm/v2/notifications/unread-count | 页面与接口契约.md | M09.定位018 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位019 | POST /alarm/v2/notifications/read | 页面与接口契约.md | M09.定位019 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位020 | GET /alarm/v2/deliveries/{deliveryId} | 页面与接口契约.md | M09.定位020 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位021 | POST /alarm/v2/deliveries/{deliveryId}/resend | 页面与接口契约.md | M09.定位021 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

API08/10/12读配置与其写口使用同一现有实时超管事实服务，撤权后不能继续以会话旧角色放大对象范围。API12在原应用服务只读REPEATABLE_READ事务内读取检项与组台账，避免组版本和行值来自不同读快照；顶层配置revisionId是下一次API13的baseRevisionId，项目行revisionId保留各自生效历史，二者不能混用。管理修订仍取同模块读响应顶层managementRevision，不与配置修订混用。

G07为设计字段迁移：原settings lab-statusalarm页面及其真实SDK须同步候选、筛选和行校验；行标识继续configId或bottleId及原版本，不改为unitCode。没有旧条件的原lab/tab读继续；旧条件不能被忽略而返回扩大集合。API08仍不写阈值，完整粘贴预览不受当前筛选缩窄。

API06/07共享发件配置仍走原唯一Sender应用；读真实单例及MAIL APPLIED基线，写在原M09-007同一守卫事务提交完整MAIL修订、active_revision_id/行版本、原审计/回执及SYSTEM，不把台账缺口留给前端补版本。scope及首建约束见JSON契约，配置保存不代表外部通道已验证。

API13仍由原Controller→AlarmOfflineConfigApplicationApplicationService.saveOfflineConfig，模块返回AlarmConfigMutationResult不改公共MutationResult/原guard四字段。M03初次来源固定M09/M09-013且取原守卫actor，M06后台决定的祖先和原提交UUID来自原冻结changeSnapshot/sourceRequestId。薄M09OfflineConfigApprovalAdapter只桥原precheck/deliver/query；SYSTEM→M03当前源锁（APPLY）→本scope/revision锁、完整投影/状态CAS/原回执与M09_013七列UPDATE审计在原应用同事务。DISCARD只终结候选不改阈值，不因当前申请人失权或培养结束卡住已形成的DISCARD；签审前当前源冲突仍按M06原规则拒绝。query只读，原决定重放不二次投影/审计/管理版本；seal能力未因此推定已实现。

API04由真实SDK显式labId进入AlarmRuleV2Controller→AlarmRuleApplicationApplicationService.getLabRuleConfig→M09LabRuleSnapshots；LAB scope固定为LAB:<labId>:RULE:<ruleId>。API05先完成形状规范化，原guard回调内重验可变角色事实、MANAGE与全部对象版本，再recordAppliedScoped逐条保存；任一失败全回滚，同原请求重放不二写。旧规则config/list/detail/export及可合法映射的增改路径委托同一LAB应用，不能另走全局写；旧DELETE兼容缺口单列，不把删除解释为停用。未应用模板revisionId=null，保存前不触发通知。

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| INT01 | receiveEvent | 页面与接口契约.md、数据库JSON与事务契约.md | CTRL-INTERNAL | 仅登记生产方；同源键同hash幂等，异hash/未知schema阻断 |
| 定位022 | INT02 applyConfigDecision | 页面与接口契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位023 | INT03 reconcileDelivery | 页面与接口契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位024 | INT04 evaluateDeadline | 页面与接口契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| INT05 | acknowledgeMonitor | 页面与接口契约.md | CTRL-INTERNAL | 仅可信M02/M07来源；ACK落库但不改候选配置内容 |

## 4. 模块内调用约束

- HTTP字段必须先映射为 M09 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

本文件自动登记 21 个目录内HTTP入口、3 个内部定位项、0 个尾部补登记入口。数量校验只防漏项；逐接口仍须以来源契约完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。
