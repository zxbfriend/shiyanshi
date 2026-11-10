# SMP 补料调度实现盘点与分阶段开发计划

> **For agentic workers:** 实施时使用 `superpowers:subagent-driven-development` 或 `superpowers:executing-plans` 逐项推进；以本计划的任务、文件归属和验收门槛组织工作。2026-10-21 已获全部四阶段业务代码、契约及隔离验证授权；不连接共享/dev/生产数据库、不调用真实设备或通知，暂不提交或推送。下文2026-10-20静态盘点保留为原始基线，当前实施和验证进展以§11.16及后续当日复验条目为准；第10节和早期记录保留对应快照。

**Goal:** 在现有 M07 任务、命令和资源基础上，实现小试二期与中试共用的调度、独立监控、停止确认及唯一计量闭环，并按设备组验证后启用。

**Architecture:** M07 唯一管理任务、业务状态、认可量和释放资格；调度唯一执行正常启动与调速；进程外补料监控独立读数并只请求保护停止；M02 及经核准的实际写入口承担设备适配、停止优先、旧写方隔离和原始反馈。M09 消费告警事实，不进入停料控制链。

**Tech Stack:** 当前仓库 Java 17、Spring Boot 4.0.6、Maven、MyBatis；业务前端为 Vue/TypeScript、pnpm 工作区。既有 `futurefab-monitor` 是 Spring Boot Admin，不能当作已交付的补料监控。

**Spec:** [完整版统一方案 V1.14](../../接口文档/SMP小试二期与中试补料调度统一方案.md)，以及本工作树的 [M07 接口目录](../../详细设计/07-补液运行与任务执行/接口目录与契约定位.md)、[任务状态](../../详细设计/07-补液运行与任务执行/任务状态调度与异常恢复.md)、[设备命令](../../详细设计/07-补液运行与任务执行/设备命令契约.md)、[计量](../../详细设计/07-补液运行与任务执行/计量确认与补液计算契约.md)、[泵速执行与恢复](../../详细设计/07-补液运行与任务执行/泵速执行与设备恢复契约.md)、[错误码](../../详细设计/07-补液运行与任务执行/错误码全集.md)。

## 1. 基线与证据范围

| 项目 | 本轮基线 |
| --- | --- |
| 检查日期 | 2026-10-20，Asia/Shanghai |
| 工作目录 | `D:\project\yaoming\SMP\wt-feeding-scheduler` |
| 分支 / HEAD | `codex/feeding-scheduler` / `5678c46d01b837745340632b79142f9b8ff774db` |
| 文档来源提交 | `cloud` 的 `021cfc1a97b5f46e03b3f09e61c55d0d56e0e9ef`，仅移植 18 份 FEED 文档 |
| 前端边界 | 本树未包含另一会话的 `0791c6d98` 前端提交；后续页面任务先核对整合基线，不在本计划中顺带合并 |
| 完整版 SHA-256 | `34b63159ca583db28f6d9e64582ec7068c0e2d5e7fbde5715df451573be65de2` |
| 盘点方式 | 文档、实现、调用点、Mapper、配置及测试文件静态核对；没有启动服务、连接数据库/设备或运行测试 |
| 证据结论 | “已有实现”仅指下表注明的代码范围；本轮所有编译、测试、HTTP、浏览器、真实接口和现场结果均为 `NOT_VERIFIED` |

完整版在仓库外，保留原路径作为依据，不复制为新的权威方案。本计划安排实现顺序，不更改正式契约、业务枚举、固定 JSON 或客户核准参数。其他工作树中的泵策略/监控算法不计入当前实现；如后续复用，先核对提交、契约差异和测试，再单独引入。

## 2. Global Constraints：实施约束

1. 同一物理资源组只有一个正常控制方；独立监控无 START、调速、最终业务状态和认可账写权限。
2. 监控、实际写入仲裁及停后独立读路径不能依赖调度进程存活。设备侧故障停料保障仍须按设备组验证，不默认新增一套现场软件。
3. HTTP 成功、ACCEPTED、设定值为零分别保留原语义，均不单独证明实际停料。
4. 未知 START 查原命令；NOT_FOUND 不证明未执行。停止请求、真实停料、认可量、观察闭合、业务终态和释放分别判断。
5. 首次实际开始须严格早于计划所属上海业务日下一日 00:00:00；已合法开始可跨午夜继续。STOP、查证和记录已发生事实不能被日界拦住。
6. 关联异常补料子任务独立准入并沿原计划日；不得继承父任务的首次开始事实。
7. 首次停止意图及其期限不得因重试、新原因、重启或午夜重新计时；迟到停止可推进收尾，不抹去超时历史。
8. 认可量由 M07 按原执行/段/来源唯一写账。未知量不填零，不对负向增量取绝对值，不跨容器会话直接相减。
9. W−R 及会做预填充已经确认；正常已填充管路残留可忽略，但异常余流、排空、旁路及换袋变化仍要核对。50g 不是 R 的默认值。
10. 首启、原袋续段和换袋续段的“所需量”比较口径、等值边界及额外余量仍待确认。T100/E99/确认60时，不能自行选择40g或39g作为准入值。
11. 恢复保留原 T、冻结策略、原终点、已认可量、校准有效性和历史活跃时长；原终点已达不重新开泵。
12. 少加误差严格大于5%是异常补充选项条件，不是正常完成允差、超量保护值或自动重试授权。
13. 现有 HTTP/NCS 码复用；新增20项是原因码。不得将它们直接当 HTTP 状态，也不得给固定 DTO/JSON 偷加字段。
14. M09 接收、通知或恢复失败不延迟停料；健康恢复、已读、静默、复位都不直接授权开泵。
15. 测试夹具与真实参数分离；缺必要配置时明确阻断。客户文档说明、代码核对、接口联调和现场验证分别登记。
16. SQL 如需变更，按字段字典、目标 DDL、唯一开发基线及来源清单同步；不执行历史脚本、不重跑现有库的空库建库流程。
17. 本期不启用旧未完成任务接续、W08 后续、连续泵速策略或默认外置泵/继电器控制。M08 不作为本次前置；开始培养的当天完成规则不被补料首启规则替换。

## 3. 现有实现与开发缺口

以下路径以仓库根为起点，行号按本轮 HEAD 记录。为控制表宽，使用这些明确前缀：

- `JAVA` = `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system`
- `XML` = `futurefab-modules/futurefab-system/src/main/resources/mapper`
- `TEST` = `futurefab-modules/futurefab-system/src/test/java/com/futurefab/system`
- `API` = `futurefab-api/futurefab-api-system/src/main/java/com/futurefab/system/api`

| ID / 能力 | 当前可复用实现及证据 | 尚未闭合的部分 | 安排 |
| --- | --- | --- | --- |
| GAP-01 任务创建及审批 | `JAVA/controller/run/RunTaskController.java:79`→`JAVA/service/impl/application/m07/RunTaskApplicationApplicationServiceImpl.java:476`→`JAVA/service/support/m07/M07TaskCreateService.java:215`；有请求身份、快照、审批及准入基础 | 不能从人工创建入口推导固定发生项、动态扫描和到期调度均已运行；`M07ApprovalDecisionService.java:179`/`RunTaskMapper.xml:83`的READY应用还须复核首启资格 | P1复核已有入口；P2、P3 |
| GAP-02 资源互斥与派发前守卫 | `JAVA/worker/m07/M07ResourceClaimWorker.java:157` 有 claim；审批、规格、来源及资源 guard 已有校验 | 本次未找到普通任务调度生产方调用 claim 的完整链；不得只建定时扫描便声称任务已执行 | P1 复用守卫；P2 接主链 |
| GAP-03 命令持久化、派发和未知查单 | `JAVA/worker/m07/M07CommandInvocationWorker.java`、`JAVA/service/support/m07/M07TaskPauseDispatcher.java:85`、`M07CommandQueryRecoveryExecutor.java`；暂停和部分工作流有实际调用链 | InvocationWorker:261当前仅允许普通任务STOP/SET_SPEED，START用于W03/W07步骤；预填充START不能算普通补料首启已实现。扫描支持范围也须同步 | P1 固化安全语义；P2 扩展 |
| GAP-04 真实首次开始日期 | 资源准入已有计划时刻检查；`JAVA/service/support/m07/M07ExceptionAutoCandidateFactory.java` 有异常子任务日期约束 | FEED 的权威首次开始证据、时间质量、实际入口到期拒绝、迟到回执和跨日竞争尚未形成完整链；PREPARED/INVOKING 不可代填 startedAt | P1、P2，P4 真实入口验证 |
| GAP-05 原因码 | `API/contract/error/FutureFabReasonCode.java:10` 仍是21项旧原因；`TEST/contract/FutureFabErrorCodeContractTest.java:59` 仍断言21项 | 文档新增20项尚未同步到枚举及生产消费链；需按通道处理、兼容旧21项，不能仅修改数量断言 | P1，后续分支逐项接入 |
| GAP-06 设备客户端与网关 | `JAVA/service/impl/port/m02/M02HttpDeviceCommandAdapter.java` 是默认关闭的固定 HTTP 客户端；保留 v1 参数白名单 | 客户服务适配、实际写入口仲裁、远端去重/到期约束和真实停止反馈不能由客户端证明；不能直接开配置投用 | P1 契约；P2 隔离实现；P4 联调 |
| GAP-07 规格及能力生产 | `JAVA/service/impl/port/m02/M02WorkflowPumpCommandSpecAdapter.java:60` 有资源映射读取基础 | configurationRevision、capabilityRevision、adapterInstanceId当前明确返回null，权威生产仍需补齐；缺失不得拼装为已核准ExecutionSpec | P1 承载；P2 生产链 |
| GAP-08 原始采样 | `JAVA/service/impl/port/m07/ExecutionSamplePortImpl.java` 及 M02 观测接收/存储/读数 Port 已有基础 | 基于业务数据库的读模型不等于业务 DB/调度故障时仍可达的独立读路径；序号、质量、覆盖缺口与真实计量范围仍须贯通 | P1 证据；P2 独立读；P4 源核验 |
| GAP-09 停止与暂停 | `JAVA/service/support/m07/M07PauseFinalizer.java`、`M07StopEvidenceAssembler.java:33`、`XML/system/RunExecutionSampleWriteMapper.xml:132` 有 STOP 证据组装及三表 PAUSED 写入 | 组装器先过滤 GOOD，再寻找合格子窗口；未证明完整观察范围无坏质量、缺口、后续新增量或再运行。系统进程内最终化不是独立监控 | **P1 优先** |
| GAP-10 暂停与继续不一致 | 上述 XML:143/147 写 `PROVISIONAL`；`JAVA/service/support/m07/M07ResumeExecutionFacts.java:37` 只接受 `NONE` | 新产生的暂停事实可能被继续入口拒绝。应统一暂停段认可、执行结算与恢复资格，不得简单放行 PROVISIONAL | **P1 优先** |
| GAP-11 余量与恢复策略 | `JAVA/service/support/m07/M07ResumeRemainingAmountPolicy.java`、`M07ResumePreparationPolicy.java`、`M07ResumeMaterialSessionFacts.java`、`TaskResumeCommandFactory.java` 已有恢复组装链 | 按 T−确认量恢复、用 initial−consumed 判可用量，不足以落实原终点和预填充后W−R；供料比较政策仍待确认；不能只换 targetGrams 便认为续接原策略 | **P1 阻断错误准入**；P3 完整恢复 |
| GAP-12 自动执行唯一认可账 | `XML/system/RunManualFeedMapper.xml` 支撑 W05 MANUAL_FEED；`M07TaskExceptionHandlingMapper.xml` 支撑 ADJUSTMENT/MANUAL_SUPPLEMENT | 自动采样/暂停链目前主要写任务、执行、段和事件；未找到自动 FEED 段认可→唯一账本→完成归并的完整生产链。异常更正入口不能替代它 | P1 建安全证据与认可边界；P2 接自动闭环 |
| GAP-13 资源释放及培养屏障 | `JAVA/worker/m07/M07ResourceReleaseWorker.java`、`JAVA/service/support/m07/M07ReleaseAuthorization.java`、`M07ReleaseProofService.java` 有 guard/fence、未决命令和证明校验 | 未找到自动正常完成→release 的完整生产调用链。工作流 NOT_SENT 取消的释放不能证明自动执行释放已接通 | P1 守卫反例；P2 接链 |
| GAP-14 泵策略控制循环 | 当前冻结策略、命令与计量模型可复用 | 限定当前源码未定位到 `M07PumpPhasePlanner` / `M07PumpMonitorEngine` 的实现；固定流量终点控制、二/三段及校准须落实并核查调用方 | P2 固定模式；P3 二/三段 |
| GAP-15 独立补料监控 | `futurefab-monitor/src/main/java/com/futurefab/modules/monitor/FutureFabMonitorApplication.java:12` 为 `@EnableAdminServer` | 未形成方案要求的进程外补料监控、持久活动登记、独立保护读停、停后观察和 DB 失效保护链 | P1 契约/纯判定；P2 进程与故障验证 |
| GAP-16 M09 交接 | `JAVA/service/port/m07/RunEventPublisherPort.java` 定义发布接口；M09 有通知配置与事件能力 | 未找到本链完整生产消费实现；现有 M07RuntimeFactOutbox 投递 M03，不等于 M09 告警已接。监控配置成功也不证明保护生效 | P2 最小交接；P3 完整页面/规则 |
| GAP-17 关闭段后的迟到证据 | `JAVA/service/impl/port/m07/ExecutionSamplePortImpl.java:88`在去重/落库前拒绝已关闭段；当前同序冲突仅留事件 | 此入口不能直接承接H08的历史迟到量/证据；需受控隔离保存和对账路径，不得为收历史数据而重新开放旧段控制 | P1隔离保存/反例；P2归并与当前保护 |

**盘点结论：**当前有可复用的任务与安全控制组件，但尚未形成统一方案的自动补料闭环。优先补齐各组件之间的状态、身份、证据和持久化交接，再做调度循环和设备接入；不从零重写审批、量账或资源框架。

## 4. Review Focus：最容易被现有分层测试漏掉的情况

| 关注点 | 必须证明的行为 | 归属 |
| --- | --- | --- |
| 23:59:59提交，次日才实际开始；回执晚到、时间回拨或错误时区 | 看实际发生证据；不倒填、不重发、不取消未知；实机入口拒绝迟到首次启动 | P1-03、P2-01；CASE-03/18 |
| 先出现稳定窗口，窗口后又余流、坏质量或再运行 | 不用早先合格子窗口盖掉后续异常；保留首次停止期限 | P1-04；CASE-04/09/10 |
| 系统真实写出PAUSED后再走继续入口 | 用真实写出的结算状态和段量作为输入，既不永远拒绝合法恢复，也不把暂估量当认可量 | P1-05；CASE-05/06 |
| A释放后B接管，再到达A的量或停料证据 | A的历史可对账；A的旧fence不得控制或释放B | P1-05、P2-02；CASE-10/G.3 |
| 健康/通知恢复，但STOP仍未知；调度/DB/本地存储失效 | 不自动解锁，必要停料不依赖通知或业务DB落库；不能证明归属时按核准保护范围处理 | P1-04/06、P2-02；CASE-08/11/12/19 |

## 5. 分阶段路线

| 阶段 | 交付目标与主要任务 | 进入/完成条件 |
| --- | --- | --- |
| **P1 安全基础与证据闭环** | 冻结缺失承载；同步20原因；落实真实首启日期判定；持久停止意图/首期限/多原因；修正观察与暂停恢复不一致；建立可重放反例测试。**不启用真实泵，不承诺已具备正常自动补料。** | 完成第6节任务和退出清单；未确认参数对应分支拒绝；没有用测试默认值放行生产路径 |
| **P2 单资源固定量最小闭环** | 从已批准任务开始，补资源claim→唯一START→实际反馈→核准固定流量→终点STOP→观察/认可账→业务归并/释放；同时建设独立监控进程、实际写入口仲裁的隔离实现及M09最小交接 | P1通过；在隔离环境用明确标识的模拟设备/观测提供方验证；调度进程退出后监控仍可停止并核验。真实写入继续关闭 |
| **P3 完整业务与策略** | 固定发生项和按规则补糖扫描、每日额度与统一队列；二段/三段校准；换袋及跨午夜恢复；取消和异常子链；来源恢复隔离；页面原因/物理/结算状态与告警完整交接 | P2闭环可重复；每分支具备相应核准/明确输入后开发正常路径，未确认分支保留阻断；完成相关软件测试和隔离HTTP/浏览器验证 |
| **P4 分设备接口联调与现场投用** | 小试二期/中试分别核对真实版本、映射、单位、健康契约、旧库依赖和全部写方；先只读核验，再按批准条件做停止/固定量/完整策略及故障试验；完成切换回退和人员交接 | 每设备组完成F.2/F.3适用项、CASE及专项证据；不以一种设备通过代表全部通过，不以模拟/接口成功代替实际停料与量账验收 |

客户资料确认从 P1 同步推进，不等到 P4 才启动。没有依据承诺固定人天或日历完成日；每个阶段按退出证据推进。P1/P2可先开发不依赖现场数值的机制，但不能因此关闭 CL/PAR 待确认项。

```mermaid
flowchart LR
    I["并行确认客户接口、参数与设备范围"] -.-> A
    A["P1 安全基础与证据闭环"] --> B["P2 单资源固定量隔离闭环"]
    B --> C["P3 业务、策略与恢复完整化"]
    C --> D["P4 分设备联调与现场投用"]
    I -.-> B
    I -.-> D
```

## 6. 第一阶段详细任务

第一阶段目标是交付**能够拒绝不安全准入、保持未知、按证据推进停止/计量里程碑且可重放验证的基础组件**。不要求此阶段新建全部业务页面或开通真实设备。先完成 P1-01，再按依赖并行；共享类型、Mapper、状态枚举由指定拥有方统一修改。

### P1-01 明确事实承载及版本边界

**修改/核对文件：**`docs/详细设计/07-补液运行与任务执行/数据库JSON与事务契约.md`、`设备命令契约.md`、`ExecutionSpec版本与观测兼容契约.md`、`现场能力核准矩阵.md`；M02 固定执行器 HTTP 契约及 M09 观测交接。涉及表字段时同步该目录 `10-审阅收尾完整目标表结构.sql`、字段字典、`docs/开发基线/`三份脚本及来源清单，先静态生成/核验。

**输入：**统一方案 CT-01—04、STOP-H01—08、既有 Issue/Outcome、CommandEvidence/StopEvidence、execution/segment/command及guard/fence。

**输出：**一份附在现行契约中的“逻辑事实→拥有方→现有/新增存储位置→DTO版本→生产者→消费者→并发/重放规则”表；逐项明确以下内容，不仅写抽象属性名：

- 权威首次开始事实、计划所属日与截止上下文；区分原任务首次启动与合法新段。
- 原停止意图、第一次触发时刻、核准期限、全部原因及触发/解除事实。
- 活动保护登记、当前资源/控制代次、监控与仲裁新段确认。
- 观察覆盖区间、缺口/异常、未决命令闭合证明、认可账水位与释放证明。
- 业务DB不可用时监控/仲裁所需的最小持久记录和恢复核对；存储自身失败时保持禁止正常写入并推进适用保护。

- [ ] 对照当前表/DTO逐项标明能否原样承载；固定v1未定义的字段禁止直接写入。
- [ ] 对确需扩展的项确定版本、唯一键、锁顺序及不可变历史兼容方案，并同步生产/消费契约；沿用已有身份，不另造平行任务状态机。
- [ ] 明确实际写入口如何取得可信首启截止上下文、拒绝已受理但过期的START；客户不具备时该真实模式保持不可用。
- [ ] 明确独立监控和实际仲裁的部署拥有方，不能仅放入 `futurefab-system` 的调度线程。
- [ ] 用序列化、旧版本拒绝/兼容、并发首次停止、进程重启回放样例检验契约；不能把逻辑字段登记当作数据库/客户接口已经支持。

**完成判据：**P1后续任务依赖的物理承载、版本、唯一键和拥有方已经确定；仍未确定则对应实现任务不能计为完成。新增类/Port的精确签名与序列化在本任务同步到现行契约，本计划不凭空宣布它们已存在。客户所需量、停止时限、健康语义等业务/现场输入不在本任务中自行决定。

### P1-02 同步原因码及通道处理

**文件：**修改 `API/contract/error/FutureFabReasonCode.java`、`TEST/contract/FutureFabErrorCodeContractTest.java`；新增 `TEST/contract/M07FeedingReasonCodeContractTest.java`（拟建），各实际生产/消费点按职责逐批接入。

**输入/输出：**消费正式错误码全集的20项精确名称及通道；输出原 Issue/Outcome/MonitorEvidence 等合法承载。保持旧21项语义及HTTP码集合；M09自有投递reasonCode不被来源故障替换。

- [ ] 先建立“原因→触发条件→承载→HTTP复用→阻断/保护动作→解除证据”的参数化断言，缺项测试应失败。
- [ ] 同步枚举、messageKey和使用方；基线范围为旧21项加新增20项，不能只将测试常数21改为41。
- [ ] 覆盖缺能力与已发生屏障故障、STOP未确认与超时、健康缺契约与健康失败的区别。
- [ ] 覆盖GET/成功预检返回业务阻断、原请求只读恢复、retryable=false及权限不泄露。
- [ ] 标记尚无实际检测生产方的原因；枚举测试通过不算全部20项运行场景已接通。

**验证：**第8节定向命令运行 `FutureFabErrorCodeContractTest,M07FeedingReasonCodeContractTest`，逐项校验通道和行为，不放宽HTTP/NCS定义。

### P1-03 实现首次实际开始日期与未知边界

**文件：**复用 `JAVA/service/impl/application/m07/RunTaskApplicationApplicationServiceImpl.java`的`precheckTasks`、`JAVA/service/support/m07/M07TaskCreateService.java`、`M07ExceptionAutoCandidateFactory.java`、`M07ApprovalDecisionService.java`，以及`JAVA/worker/m07/M07ResourceClaimWorker.java`、`M07CommandInvocationWorker.java`、`M07CommandReceiptApplyWorker.java`和`XML/system/RunTaskMapper.xml`；拟新增 `JAVA/service/support/m07/M07FirstStartAdmissionPolicy.java` 和对应 `TEST/service/support/m07/M07FirstStartAdmissionPolicyTest.java`。生产入口的适用分支必须逐一列出，工作流开始培养规则不能被整体替换。

**输入/输出：**P1-01确定的计划日、可信开始事实、时间质量、原命令状态与当前归属；输出合法首次开始、已合法开始后续流程、过期未开始拒绝、开始未知、已证实违规等判定与原原因承载。它只做准入/证据判定，不发命令。

- [ ] 用可控时钟覆盖23:59:59、小数秒日界及00:00:00；判定基于完整精度，不能按显示截断。
- [ ] 覆盖午夜前提交/客户次日执行、晚到的当日开始证据、错时区、时钟质量不足和回拨；无法证明合法开始时保留未知。
- [ ] 覆盖PREPARED未发送、INVOKING未知、NOT_FOUND；仅确定未开始且无已发/未知START时允许原守卫内DAY_CANCELLED。
- [ ] 按正式契约逐一接入预检、审批应用/入队、资源claim、首次派发和回执归并；GET/成功预检只读报告阻断，不写跨天取消。P2新增的普通任务START调用同一政策。
- [ ] 验证STOP、查证、合法跨午夜执行/续段、现场事实登记不被统一日期拦截；新补料子任务不继承父任务开始事实。

**完成判据：**本地守卫的负面测试通过；实际客户入口能力在P4验证前仍是 `NOT_VERIFIED`，不能将本地拒绝当作远端队列已撤销。

### P1-04 持久停止意图与完整观察核验

**文件：**复用 `JAVA/service/support/m07/TaskPauseIntentService.java`、`M07TaskPauseDispatcher.java`、`M07StopEvidenceAssembler.java`、`M07EvidenceValidator.java`、`M07PauseFinalizer.java`、`XML/system/RunExecutionSampleWriteMapper.xml`；P1-01决定新增承载后再限定对应Mapper/Repository。新增 `TEST/service/support/m07/M07StopIntentLifecycleTest.java`（拟建），扩展 `M07StopEvidenceAssemblerTest`、`M07PauseFinalizerTest`。

**输入/输出：**原段/命令/fence、首次停止意图和原始全范围观测；输出可重放停止记录、当前缺项、多原因及H02/H04核验结果。唯一业务归并仍由M07执行；纯核验组件可被P2独立监控使用，但不因此具备开泵或量账权限。

- [ ] 先重现“先稳定后异常”“先稳定后坏质量”“观察覆盖缺口”反例，禁止过滤掉坏证据后提前形成完整StopEvidence。
- [ ] 对终点/人工/监控并发STOP归并同段意图，固定第一次期限；重试、跨午夜、重启及迟到确认均不重置。
- [ ] 区分查单重试的`next_query_at`与首次停止核验期限；既有只扫描STOP已EXECUTED的暂停最终化任务不能漏掉FAILED/UNKNOWN停止升级。
- [ ] 分别处理真实停料、稳定量、观察完整及在途动作，不能用一个布尔值替代H01—H06。
- [ ] 对首次期限到达仍未停料生成超时并升级适用保护；后续停料保留历史超时。保护调用不等待M09通知。
- [ ] 核验原adapter/config/profile/身份及不可变证据；已确认事实后的新增量或证据失效追加事件，不改写历史hash。
- [ ] 用Repository测试替身验证恢复/幂等，再按P1-01的实际承载做隔离数据库验证；未真实执行SQL前仅报告单元/契约层。

### P1-05 统一暂停量、恢复准入与释放条件

**文件：**`JAVA/service/support/m07/M07ResumeExecutionFacts.java`、`M07ResumeRemainingAmountPolicy.java`、`M07ResumeMaterialSessionFacts.java`、`M07ResumePreparationPolicy.java`、`TaskResumeCommandFactory.java`、`M07ReleaseAuthorization.java`、`JAVA/worker/m07/M07ResourceReleaseWorker.java`；关联暂停/恢复Mapper和原有测试。拟新增 `TEST/service/support/m07/M07PauseResumeSafetyChainTest.java`。

**输入/输出：**P1-04停料/观察证据、当前段量及认可账水位、原冻结策略/终点、当前资源归属；输出暂停/计量/恢复/释放的各自资格，不建立第二套余额。

- [ ] 先用真实暂停写入结果串接恢复测试，重现PROVISIONAL与NONE不一致；根据P1-01明确的段认可/执行结算语义修复，不能直接删状态检查。
- [ ] 补原终点优先检查：T100/E99/已确认99时即使名义剩余1也不开泵；存在保护异常不得转正常完成。
- [ ] 区分W−R实际可用量与initial−consumed记录推算量；未核准替代来源不得混用。
- [ ] 供料比较政策未确认时返回明确配置/资格阻断，不判为已知供料不足，不选40/39或默认余量。该分支不计为正常恢复已实现。
- [ ] 实现按原execution/segment/来源唯一认可段量的服务入口、持久写入及重放校验，接通已有采样/暂停交接的有效分支；沿已有run_ledger所有权、事务与水位规则，不借人工追加冒充自动执行。P2普通任务自动完成复用该入口。
- [ ] 扩展H06反例：只有业务终态、只有停料、只有段量、观察未闭合、存在未决命令均不得释放。
- [ ] 覆盖A释放/B接管/迟到A证据：受控保存关闭段的隔离证据，不重开旧段；账与历史归A，旧身份不得操控B。P2接入完整后续对账及当前资源保护，P1缺资格时拒绝释放/写设备。

**完成判据：**安全拒绝与允许条件一致；完整换袋、新段监控/仲裁登记及阶段续接由P3实现，当前不满足的恢复路径保持关闭。

### P1-06 形成一套可重放的安全交接验证

**文件：**拟新增 `TEST/service/support/m07/M07FeedingSafetyReplayTest.java`；复用 `M07RuntimeFactFixture.java` 和现有设备/采样测试夹具。测试模拟器只在测试目录或显式隔离配置内，不成为生产故障时的兜底。

**输入/输出：**P1-02—05的原因、日期、命令及证据组件；输出每次场景的原身份、实际调用次数、里程碑、量账变更、资源状态和原因历史。

- [ ] 串接“原开始意图未知→必要STOP→真实停料→段量→观察→归并资格”，逐步断言，缺任一关键证据不得跨级。
- [ ] 注入重复/乱序/同序冲突、STOP应答丢失、迟到START、重启恢复及记录失败；证明没有第二次一次性START或重复量账。
- [ ] 模拟通知失败、业务DB暂不可用及保护存储不可用，验证各自阻断和保护职责；测试不能当作实机/进程独立性证明。
- [ ] 将CASE-03/04/05/09/10/18/19及G.3断言映射到具体测试方法；保留未覆盖的运行层条目。
- [ ] 检查后台真实路径与所有模拟器隔离；此阶段不启用生产调度开关、不调用客户接口。

### P1依赖与退出清单

顺序：`P1-01 → P1-02/03/04 → P1-05 → P1-06`。P1-02和P1-03可分人并行；P1-04与P1-05涉及相同证据/Mapper时先协调拥有方。技术承载未定只暂停相关持久化分支，原因码、纯日期政策及已知缺陷的反例测试可继续。

- [ ] 首次开始、首次停止期限和证据交接拥有明确的版本化承载，没有未经定义的JSON键。
- [ ] 新20原因在正确通道表达，旧HTTP/NCS及历史原因语义保持；尚无生产方的原因有明确后续任务。
- [ ] 日期/未知保护、完整观察反例、暂停状态不一致、原终点及资源迟到证据用例通过。
- [ ] 量未知不变为0，暂定不当作认可，停止/观察/未决命令未闭合不释放。
- [ ] 保护与通知、业务DB写入解耦的接口和故障行为明确；独立进程实测列入P2/P4，不在P1冒充通过。
- [ ] 定向测试实际执行且有用例数；涉及本阶段持久链的事务、唯一约束、并发及重启恢复完成隔离数据库验证，未执行不得标记对应持久闭环完成；不以纯字符串测试替代事务行为。
- [ ] 真实设备开关维持关闭；W/R、所需量政策、时限和能力缺项保留；没有新增现场默认值。

**第一批建议先做 P1-01 和 P1-02，同时为 GAP-09/10/11补失败测试。** 这是能立即开展、且能约束后续调度开发的范围；不建议先写轮询READY任务并开泵的定时器。

## 7. 后续阶段工作包与验收

### P2：单资源固定量闭环

- **P2-01 任务执行主链：**在现有任务/审批上增加明确的待执行扫描及资源claim调用；只选择核准的FIXED模式和一个资源组。持久化完整规格/命令后才事务外调用，应用真实开始反馈；未决START阻断新START。测试同培养顺序、共享资源竞争、声明前后崩溃和客户端超时。
- **P2-02 监控、仲裁与采样：**建立独立补料监控进程及受控原始读/停接口。若需新模块，可规划独立 `futurefab-feeding-monitor/`；具体包和部署由P1-01确认，不能仅重命名BootAdmin。监控活动集合持久化、跨午夜；实际写入口验证当前归属、停止锁和旧写方，并支持明确核准的去重/查单语义。以独立进程终止、业务DB不可用、旧命令迟到验证，而非只做方法Mock。
- **P2-03 自动计量与收尾：**复用P1唯一段量认可入口，补齐普通固定量任务的自动认可触发、最终量与允差判定、H02—H06正常收尾/释放编排和M03释放证明。按原身份恢复幂等；异常少加可完成保护验收，但不得标正常完成或跳过释放证明。
- **P2-04 最小告警交接：**实现M07来源事实→M09受控事件/Fact的生产消费、幂等及失败隔离；ruleKey经配置核准，通知失败不阻止STOP。可先用测试通知提供方验证，不发送真实消息。

P2退出：CASE-01/02/03/04/05/08/09/10/11/12/17/18/19的适用隔离场景通过。进程隔离、SQL事务、HTTP边界分别给证据；真实服务/设备、最终允差和最坏停料预算仍未因此通过。

### P3：业务与策略扩展

- **P3-01 任务来源和统一队列：**固定发生项、定量/规则补糖、人工系统执行及异常子任务逐入口核对；生成键、每日额度、审批应用和计划替换屏障一致；扫描周期与控制采样周期分别配置。关联CASE-01/07/16/18。
- **P3-02 二段/三段策略：**实现限幅、阶段边界、有效校准及精确理论时长；原策略公式不改，不能把70/15当默认值或把缺校准系数置1。若复用其他工作树算法须单独评审并重跑测试。关联CASE-05/13/17及XS-SCH专项。
- **P3-03 恢复、换袋和异常处置：**在P1状态和量账基础上接新段准备、基准冻结、监控/仲裁分别确认、资格重验、授权解锁及唯一启动；保留累计阶段和活跃时长。自动异常补充与人工已发生事实登记分开；不能借来源恢复绕过物理暂停恢复。所需量政策未确认的路径持续阻断。关联CASE-05/06/07/09/16/18。
- **P3-04 页面和告警：**核对已推送的前端提交及其他会话当前基线后再限定合入；展示物理/业务/结算状态、原计划日、可信startedAt、原因和允许动作。页面禁用不替代后端守卫；真实接口失败不回退Mock成功。完成权限、未知结果和跨午夜浏览器场景。

### P4：小试二期与中试分别验证、切换

按 `只读来源验证 → 核准停止能力与仲裁验证 → 固定量闭环 → 适用策略/恢复 → 最坏并发故障 → 切换演练` 推进，每个动作须具备客户批准条件。

- 分别核准客户服务/接口版本、OPC点表、称重位置/净毛重/单位/质量与时间戳；逐服务验证成功/失败响应、失败Data0、GET写操作隔离、批量部分成功和无参服务设备绑定。
- 小试旧服务的旧库和培养生命周期依赖单独解决；中试健康检查契约缺失不能用状态查询或小试URL补齐；服务启停不当任务暂停/恢复。
- 完成F.2逐设备启用记录和PAR-01—14适用项；未选的外置泵、继电器/报警器不因有接口文档就默认启用。
- 按CASE-11/12/13/14/15验证调度、监控、OPC服务、主机、网络、DB和存储故障的真实结果，记录共同故障未覆盖范围；测最大而非平均停止时间及追加量。
- 先停新准入，盘点旧/新/手动/备用写方及客户队列、未决命令与量账，再隔离切换；未知不自动移交、不接续旧未完成任务。回退不清保护、不回滚已发生量。
- 人员交接引用客户评审版 V1.14 §9.4.3；本计划不新增一套权限/责任表。

## 8. 验证执行方法

### 8.1 现有测试基础

以下为计划制定时定位的测试基础；当前实施结果见§10，不能沿用其他工作树历史通过数：

| 范围 | 现有测试，路径以TEST为前缀 |
| --- | --- |
| 原因/公共码 | `contract/FutureFabErrorCodeContractTest.java` |
| 派发与恢复 | `worker/m07/M07CommandInvocationWorkerCommandValidationTest.java`、`service/support/m07/M07TaskPauseDispatcherTest.java`、`M07WorkflowDispatchRecoveryTest.java` |
| 采样和暂停 | `service/impl/port/m07/ExecutionSamplePortImplTest.java`、`service/support/m07/M07StopEvidenceAssemblerTest.java`、`M07PauseFinalizerTest.java`、`worker/m07/M07PauseFinalizationTaskTest.java` |
| 继续准入 | `service/support/m07/TaskResumeIntentServiceTest.java`、`contract/M07ResumePreparationPolicyContractTest.java`、`M07ResumeRemainingAmountPolicyContractTest.java`及`M07TaskResumeFactsContractTest.java` |
| 设备适配 | `service/impl/port/m02/M02HttpDeviceCommandAdapterTest.java` |
| 释放/量账 | `contract/M07ReleaseProofFactsSqlMappingContractTest.java`、`M07CultureBalanceSqlMappingContractTest.java`、`M07ResourceConsumerWiredContractTest.java` |

先用当前路径实际产生的事实作跨组件测试，再用数据库唯一约束/并发与HTTP/进程测试证明运行行为。字符串/Mapper静态断言只证明映射约束，不替代事务原子性和真实状态推进。

### 8.2 命令和结果口径

在本工作树根执行。第一条仅包含现有测试；第二条为P1拟新增测试落地后执行。新测试未创建不能运行后将零用例当通过。

计划制定时shell未找到PATH可调用的`mvn`；本轮已使用已安装JDK17及Maven绝对路径执行，未新增安装。其他环境执行前按[本机启动说明](../../开发基线/本机启动.md)核对JDK 17及Maven的实际安装路径，用当前会话PATH或绝对`mvn.cmd`调用，并检查`java -version`、`mvn -version`。文档中的某台机器路径不是通用默认；不为本轮计划安装依赖或启动真实服务。当前POM未显式固定Surefire版本，执行时还须确认JUnit 5用例确实被发现。

```powershell
mvn -pl futurefab-modules/futurefab-system -am test "-Dtest=FutureFabErrorCodeContractTest,M07StopEvidenceAssemblerTest,M07PauseFinalizerTest,TaskResumeIntentServiceTest,M07TaskPauseDispatcherTest,M02HttpDeviceCommandAdapterTest" "-Dsurefire.failIfNoSpecifiedTests=false"

mvn -pl futurefab-modules/futurefab-system -am test "-Dtest=M07FeedingReasonCodeContractTest,M07FirstStartAdmissionPolicyTest,M07StopIntentLifecycleTest,M07PauseResumeSafetyChainTest,M07FeedingSafetyReplayTest" "-Dsurefire.failIfNoSpecifiedTests=false"
```

上游依赖模块可以不匹配这些测试，**system目标模块必须实际执行指定测试且用例数非零**；检查Surefire报告、原进程退出码及失败/跳过数。执行前确认测试不会连接共享开发库或真实外部服务；需要SQL验证时使用明确隔离的数据库，不能启动带真实dev配置的system后台任务当测试。

验证台账分别登记：静态检查、编译、单元/契约、隔离SQL、隔离HTTP/进程、浏览器、客户接口、现场。真实时限、秤精度、停止预算和设备保护只由后两层证据关闭。

### 8.3 统一验收覆盖

| 统一方案用例 | 主实现阶段 | 关键证据 |
| --- | --- | --- |
| CASE-01/02 | P2、P3、P4 | 生成/排队/映射/权限/互斥 |
| CASE-03/04/05 | P1基础，P2主链，P4实测 | 原命令、响应与质量、分段计量和物理对照 |
| CASE-06/07 | P1拒绝边界，P3完整流程，P4实测 | 监控/仲裁准备、恢复资格、异常子链及人工登记 |
| CASE-08/09/10 | P1判定，P2独立组件，P4实测 | 进度、首次停止期限、完整观察、唯一量账与当前归属 |
| CASE-11/12/13/14/15 | P2软件故障，P4设备/现场 | 故障范围、保护存储、实际停料预算、切换与锁存 |
| CASE-16 | P3及既有来源准入回归 | M05有效快照、来源恢复与物理恢复隔离 |
| CASE-17 | P2固定模式、P3扩展、P4逐设备 | 完整正常时间轴、账本水位及合法释放 |
| CASE-18/19 | P1基础，P2/P3全入口，P4实际入口 | 首启日期、20原因、多原因与跨午夜未知恢复 |
| G.3两类边界 | P1反例，P2/P3接链，P4可验证项 | A/B交接迟到证据；小数秒/时区/时钟质量/回拨 |

U-01—18、XS-SCH-01—34、REF-01—08、ZS-V01—10仍按统一方案关联，重叠证据不重复计数；本计划没有新增已通过的验收项。

## 9. 并行推进的外部输入与阻断项

| 输入 | 责任与关闭材料 | 阻断边界 |
| --- | --- | --- |
| 所需量比较、W/R来源及预填充后基准 | 工艺/计量、M07/M02；GY-01/03、CL-01、PAR-04的逐场景核准表 | 依赖其供料充足判断的正常启动/原袋/换袋恢复；不阻断原因和拒绝逻辑开发 |
| 首次开始权威时间与实际入口截止 | M02/客户服务、M07；CT-02/03、PAR-05，含队列到期拒绝及迟到事实 | 真实首次启动；本地政策可先验证，远端能力不默认存在 |
| 泵换算、范围、策略/校准及最终允差 | 工艺/设备、M02/M04/M07；CL-02、PAR-01/02/03/11 | 对应模式的正常执行与正常完成，不借旧参数或示例值补齐 |
| 监控/仲裁部署、独立读停与健康契约 | 双方服务/运维、M02/M07；CL-03/04、CT-01/02/04、PAR-06/07 | 真实设备启用；尤其不能用中试Running代替进度或healthcheck |
| 停止/观察期限与现场故障停料能力 | 客户自控/设备/计量；PAR-08/09/10/13、F.2实测及CASE-13 | 对应资源组投用；缺参数可验证阻断，不能宣称正常停止时限通过 |
| 恢复窗口、版本、旧写方隔离与回退 | 操作/运维、M07/M02/M03/M06；CL-05/06、PAR-12/14 | 对应恢复/切换路径；未知任务不移交、不清账、不自动开泵 |

## 10. 实施进度与验证记录（2026-10-21，持续实施）

沿用 `codex/feeding-scheduler`，基准 `5678c46d01b837745340632b79142f9b8ff774db`；全部成果未提交/未推送。保留原有README和计划修改，未操作共享/生产数据库、真实设备、真实通知或启动dev后台服务。以下替代本节此前按时间追加的中间记录，§1—9的实施依赖与阶段门槛不变。

### 10.1 阶段、真实调用链与当前缺口

| 阶段 | 已实施及调用链 | 尚未关闭的门槛与正在实施内容 |
| --- | --- | --- |
| P1 安全基础 | 首启/停止意图/观察JSON及版本同步字典、目标DDL、开发基线、来源摘要；旧21原因保留、新20原因登记。READY准入→原资源claim事务→执行/基准段/原START持久→事务外派发；原实际首启回执→严格纳秒事实归并→合法首启/保护STOP。停止保留首次期限和多原因；完整观察与全命令检查→唯一分段FEED→培养/物料投影；H08原执行隔离，未知/暂停不释放。人工原实测量确认复用同段FEED与原SETTLE，不清H08 | 权威首启时间、远端期限与旧队列能力、真实采样元数据仍须核准。当前扩展观察资格生产者及续段交接后需再跑整体回归，不能据此宣称P1所有验收已关闭 |
| P2 固定量闭环 | 普通固定量/策略初始流复用原claim/EXECUTE快照/资源守卫/唯一原命令；固定/二三段控制tick准备原SET_SPEED/STOP。普通采样与补偿入口→原停止核验→唯一FEED+SETTLE+终态；异常闭合保留PROVISIONAL，不提前认可。STOP_CONFIRMED候选扫描→原H06完整资源组释放→持久释放交接→写入口/独立监控双ACK。M07原事实outbox→M09入站→精确ACK。独立写入口/监控两个可执行进程、签名分权读停、原命令UNKNOWN不重发、持久日志/重启保护已实现 | 自动进度、实际首启与原件分页的生产outbox已接，实际SQL/故障回归继续；核准的quantity/active/coverage资格生产者在实施。还缺贯穿真实准备/派发/计量/释放的完整隔离业务链，不能以类存在或单包测试代替阶段完成 |
| P3 业务策略 | 固定与规则生成采用原SYSTEM事务消费者、M03精确历史应用原件→M04原包解码→核准时钟/D0展开→每日唯一generation ledger及明确BLOCKED；新Q31原件冻结当时权限/生命周期/版本，旧简化原件不洗成已核准。固定/二段/三段纯策略与控制已接，校准参数/窗口缺失不补k=1。恢复新段保持STARTING，保留原终点/目标/累积active。详情页显示原计划日、上海首启期限、实际首启确认、物理/计量状态及多原因，动作仍由服务端允许列表决定 | 原PAUSED→三方持久交接已接原恢复写入束、事务外派发和实际调用前重验；普通SET_SPEED目标量丢失问题已由调用链反例修复。续段活动登记识别、最终段释放及实际SQL整链仍在接，禁止释放PAUSED或直接清STOP。完整校准窗口/观察资格生产者在实施。D0、残糖确认模式、后台任务创建授权、供料比较/恢复原终点未核准路径继续BLOCKED；动态规则/换袋/异常子链的完整运行验收未关闭 |
| P4 接入与交付 | 小试二期/中试分别提供受控客户接口适配，保留原始成功/失败响应，Code200仅ACK；缺质量/实际动作/期限等能力时normal START/SET_SPEED保持BLOCKED。逐设备启用清单、显式参数输入、验收记录模板、独立写入口部署配置、切换回退和人员交接材料已补 | 无真实客户服务/设备/现场验收结论。需逐设备接口版本/点表/单位/净毛重/时间质量/读停路径/旧写方隔离/队列与停止预算核准，并具备明确现场操作授权；软件可执行验证继续，不因现场缺项终止开发 |

### 10.2 已实际执行的验证及限制

- 独立API/写入口/监控/客户适配四模块最近一次完整Maven共163项通过（在后续摘要兼容修复之前）；其后新增续段严格契约3项与写入口25项定向通过（含真实签名HTTP），不是与旧数简单相加。新增真实M07工厂→原M02客户端→签名写入口续段HTTP3项通过；原M07摘要与原HTTP报文摘要分别保留并严格映射，实际全业务SQL链仍未验收。续段M07客户端11项通过；恢复组件及接线合并检查106项通过后仍有后续改动，整体复验继续。网关双监听生产Main+阻塞TEST驱动实测独立STOP响应及强杀重启原UNKNOWN不重发通过；任务详情Controller→真实应用→安全投影MVC4项通过，均不代表生产部署。
- system在09:21完成统一编译3447个main/746个test（BUILD SUCCESS）；之后恢复接线等新增修改继续采用独立选源javac/JUnit验证，最终整树仍须重编译。此前大范围1913项回归未全绿：新增SYSTEM消费者夹具缺失已定向修复；3类旧静态测试当前11个失败方法在HEAD只读快照均重现（HEAD共12失败），保留日志，不改宽业务断言。原件读取另1项未改动历史重复查询计数问题单列，不能报告全套通过。
- MySQL8.4仅本机独立实例、新建 `feeding_validation_*` 库：当前01/02/03完整基线188表、核验无异常；最近安全/异常事务16项、正常收尾5项、监控释放6项通过。活动交接SQL首轮5/6中的Mockito重stub夹具触发null已修复，实际隔离重跑6/6通过；四包合计33项，不等于完整业务端到端验收。每轮都验证测试实例路径/端口并认证关闭，未触共享库。
- 前端42项单元测试通过；真实Chrome中实际详情组件+TEST HTTP正常/503两场景通过；当前列表/详情隔离组件构建通过。完整应用类型检查仍有其他现存组件31项诊断，当前变更文件未报错，不能扩称生产全量构建/真实部署浏览器验收通过。
- 客户接口仅TEST传输/响应样本/本机隔离进程验证，未调用真实客户端点；设备能力、真实最大停止时长/追加量、现场部署和投用均待输入及授权。

审计日志位于 `C:/Users/Evan Hou/.codex/visualizations/2026/10/19/01a1534c-e019-7f62-8ac7-f09c686bcdda`。每次新增实现后更新当前记录；测试层级分别登记，不用Mock/单元/Mapper结果替代HTTP、进程、设备或现场结论。


## 11. V4.1监控规则补齐工作包（2026-10-21，软件接线与分层验证）

本包依据客户需求说明书V4.1-1013 §1.6.7、现行M04 Q09与完整版统一方案V1.15 §8.1.1；原计划HEAD/阶段基线保持，不将新依据冒充原V1.14已包含。同步正式[泵速监控规则](../../详细设计/07-补液运行与任务执行/泵速执行与设备恢复契约.md#4-读数窗口与监控)与[独立监控契约§13](../../详细设计/07-补液运行与任务执行/独立补料监控进程与保护通道契约.md#13-v41抖动返水堵塞与量保护的接线约束2026-10-21)。本包已由文档核对进入 Java 生产接线和分层验证；既有§10实测记录保留其原范围，不把本包新增结果与旧计数相加或替代逐设备核准。

| 工作项 | 确定规则与开发边界 | 必须补的行为/集成证据 |
| --- | --- | --- |
| MON-V41-01 终点/超量 | E范围99—100%、最多1位小数；实际≥T×E/100停止；超量严格>T×(1+p/100)，独立于正常终点和抖动观察。E95只可作为非法输入反例，不作为有效恢复算例 | E99/99.5/100与非法95；终点等号停止、超量等号不触发；越过终点的同一样本仍保留超量原因；T100/E99/认可99不开泵，名义余1不等于恢复许可 |
| MON-V41-02 堵塞/返水 | 堵塞HIGH起、LOW继续，CALIBRATION禁用；理论量>2×精度且实际<理论×factor。返水也HIGH起，窗口系数与jitter.checkFactor相同，负增量≤负阈值包含等号 | 两个严格堵塞边界；HIGH/LOW切换与校准负例；返水−0.19/−0.20/−0.21及0、正值；不另存可漂移返水窗口，不取abs或用旧窗口跨段 |
| MON-V41-03 抖动停止/观察 | 从CALIBRATION检查；Q09实际/理论同Δj窗口并取max阈值。先实际停料再开始观察；固定触发窗口起点+原J，≤满足本次恢复数值条件，其余安全门禁齐备即时调度续段，不额外等整个抖动观察期；初始JITTER_OBSERVATION_REQUIRED与持续NCS030分开，采样/覆盖资格不默认 | 原1000/J10、触发980、回993即时安全续段；稳定980不恢复，持续未恢复至截止且覆盖合格才NCS030。新段新窗不按旧J判断正常下降；门禁缺失仍保护并最终实时重验；独立监控不发START |
| MON-V41-04 原因/恢复并发 | 原段全部原因及最初停止意图/nullable deadline一致持久；人工暂停/取消/现场锁、其他保护、未决命令及原终点优先于抖动恢复 | 人工暂停与抖动同时发生、观察中超量/返水、重启/午夜/新原因；不能自动清人工锁或覆盖旧原因；调度续段完整握手与最终门禁 |
| MON-V41-05 独立停止回交 | 已接有界原件scanner→既有密封control入口→Reconciler→同事务stop_intent/STOPPING/必要STOP/LOCAL marker→事务外dispatcher；原identity/原键/hash与双ACK严格重验，不伪USER_PAUSE或EXECUTED | 独立监控触发→业务DB故障→DB恢复→原意图多原因/首期限归并→实际停料/计量/观察→原最终化；重放不重复命令/量账，未知期限不补造 |
| MON-V41-06 资格与现场 | 公式/范围已明确；具体参数、方向/单位、精度、可信时钟、采样覆盖和设备profile须显式核准，无默认值；固定观察基准与原J已有业务确认 | 纯政策反例→实际生产调用点→隔离SQL/签名HTTP/进程故障→小试/中试各设备实测；各层单列，软件通过不关闭现场能力项 |
| MON-V41-07 ERROR安全释放与人工处理分离 | 原异常任务实际停料、稳定/完整规定观察、实际量唯一认可、段关闭、命令闭合/隔离及旧控制权撤销交接后可先释放设备，不等ERROR_HANDLED；保留异常待办、设备故障/现场锁及培养队列/子链约束 | 任一安全事实缺失拒绝；健康已释放设备允许其他培养新claim，FREE但有锁拒绝；原任务释放后处理不重占旧设备/重复FEED或SETTLE；所有异常量明确后统一>5%判断 |

实施顺序仍属P2/P3安全闭环、P4逐设备核准：先用反例冻结原事实输入及判定，再接既有唯一STOP/量账/资源消费者，接原件回交与恢复门禁，最后运行完整故障链。固定触发窗口起点与原J已确认，缺实际采样/覆盖/设备核准资格的自动恢复仍保持BLOCKED_INPUT；必要STOP、原始留证和其他已核准保护不等待该缺项。不得滚动更换观察基准、把零设定当物理停止、或把sample GOOD/健康成功当COMPLETE覆盖。新增MONITOR_ANOMALY_EVALUATED按正式JSON契约登记为LOCAL七字段信封，判定保留在change.after；STOP/intent同事务、不新增量账。需验证初期窗口等待与过时缺边界/gap保护、初始停止与NCS030分离、全原因/首期限以及原件重放；各层结果登记如下，不能以软件结果关闭现场项。


### 11.1 当前接线与验证边界

- 抖动初触发、返水/堵塞、终点/超量原件已接原控制事务；终点与异常可共存，保留全部原原因。停后观察已接原最终化：先物理STOP和合格覆盖，再用原固定触发起点/J判定；候选非告警，持续异常NCS030不重置首期限。SYSTEM自动恢复及续段全门禁仍在开发中，不能视观察候选为开泵许可。
- M09可靠交接已显式扩到异常NCS008/009/031/032/MONITOR_UNAVAILABLE与持续观察NCS030；初始抖动候选排除。缺核准映射仍WAITING_MAPPING。没有真实通知或现场验收结论。
- 独立STOP回交新增 codec/Reconciler/扫描任务/条件装配及4个专用查询、1个状态CAS；使用已有purpose、stop_intent和run_event，无新表/量账。隔离Java停止回交27项通过，覆盖无GOOD样本、原UNKNOWN START、双ACK缺失、旧owner、最早期限/多原因、请求及回执重放、损坏pending STOP hash、伪SYSTEM marker和原EXECUTED STOP不新建命令。续段当前段resolver/BoundSql21项及续段activity8项通过：保留原START来源，续段返回真实原SET_SPEED及ACK类型，拒借旧段ACK；同原gateway先进阶段仅证历史接管，progress仍需原ACTIVATED。三组本轮合跑56/56、0跳过，源码编译成功；日志 `independent-stop-final-custody-green-compile.log` / `independent-stop-final-custody-green-junit.log`，不与前次25/26/48项重复累加。
- `M07MonitorAnomalyPersistenceIT` 已在本会话隔离MySQL执行5/5通过，当前188表基线安装，覆盖阶段/原命令查询、独立STOP原件查询/配对/去重、意图与STOPPING CAS回滚/提交、旧版本/旧段拒绝和未知期限保留；日志 `feeding-runtime/monitor-anomaly-persistence-junit.log`。这是具体Mapper/事务验证，不是DB故障→真实设备停止→完整收尾整链验收。部署开关、设备参数、来源质量和现场能力仍不补默认值。
- 最新M09异常交接隔离复验12/12通过，其中实际MySQL持久化7项、codec5项，覆盖NCS008/009/031/032/MONITOR_UNAVAILABLE、持续NCS030、候选排除及同一事实多原因；fresh188表基线、核验无异常、测试实例认证关闭，日志 `feeding-runtime/monitor-alarm-persistence-junit.log`。不与前次同类SQL数累计，不代表真实通知或现场通过。
- 12:10快照独立四模块完整Maven198/198通过：API61、gateway70、monitor48、customer-adapter19，0失败/错误/跳过，日志 `feeding-anomaly-independent-maven-recheck.log`。该结果在后续feedback草稿之前，不是当前全部未完成源码的最终验证；后续修改需再编译/测试。

SYSTEM抖动恢复的实现边界已明确，当前实现/验证另待稳定登记：必须在同一M07_EXECUTION_CONTROL原资源事务核唯一抖动原因、最新原固定基准恢复候选、实际STOP、完整覆盖及命令闭合，唯一FEED认可后形成PAUSED/RECOVERY原件；专用CAS只允许原owner/fence/租约不变的STOPPING→HELD，再准备原bundle的新段与continuation。任何缺项或并发原因整组回滚。HELD不等于释放或开泵授权，独立停止锁仍须双ACK/activate及最终派发门禁；通用resume只认HELD，人工M07-009权限不放宽，不伪装USER_PAUSE。

### 11.2 尚未完成的软件生产链与核准输入

下表保留文档完善批的软件缺口快照，不把缺生产调用链的项目归为“仅待现场”。用户已明确恢复全部四阶段编码；后续实际接线和验证进展见11.5，下表旧“草稿/未接线”不得替代新证据，但也不能因新类存在直接标完成。

| 工作项 | 当前证据与未完成点 | 下一步关闭要求 |
| --- | --- | --- |
| 独立异常上下文生产者 | 仅有Installation SPI/纯判定器和测试实现；原Registration/Progress不携完整原T/E、基准/方向、认可历史量、物料会话、实际阶段/原命令及窗口锚点 | 从已批准持久事实形成身份/hash精确绑定的可靠独立上下文；验证DB失联/进程重启仍可用，不复制量账、不制造目标/阶段/参数。缺项继续BLOCKED |
| 跨设备metric与首反馈 | FeedingFeedbackAuthority接口及ApprovedMetricFeedbackInstallation草稿已在工作树，7例真实RED为2通过/5预期失败；后续loader草稿未完成验证，尚未接Monitor/Main和首反馈持久重放 | 独立固定摘要核准输入、明确设备/资源/单位/boot/角色和运行判据；真实秤通过，外来设备/缺绑定拒绝，0速/错误单位/START前原反馈不确认运行；续段与重启不借旧证据/重置期限，旧schema1 hash保持 |
| 校准窗口生产证据 | 已有冻结校准参数及纯策略；完整原窗口/k/实际阶段的生产闭环仍待补齐 | 显式核准buffer、窗口/活跃量、量化和k范围/复用条件；按原样本/命令关联，缺项不补k=1、不当已校准 |
| SYSTEM抖动恢复协调 | 原观察接线已完成，恢复数值成立→唯一原段认可→原资源保留→新段准备与实际三方交接的整体协调未形成可运行整链；专用状态写入仍有stub、恢复Mapper缺XML，最新写入束改动未完成复验 | 原事务重验唯一抖动原因、当前恢复事实及全部停止/量/规定观察/命令条件，齐备即时续段、不额外等完整抖动观察期；其他门禁缺失保持保护并最终实时重验。成功续段新窗不引用旧J；持续未恢复到期且覆盖合格才NCS030，不保留反弹重计时/报警时机待确认旧政策；并发人工/取消/其他原因阻断。补实际Authority→观察→原bundle→SQL→双ACK/activate→真实派发的反例与整链证据 |
| ERROR安全释放及释放后人工处理 | 现M07StoppedReleaseEligibility只认EXECUTED/ERROR_HANDLED/CANCELLED；现ERROR收尾、认可量、段关闭、释放扫描/证明及人工处理的整链尚未按本次目标同步 | 同步安全收尾与唯一认可、原资源候选/资格和受控释放交接，不仅扩状态集合；ERROR未人工处理但安全事实齐备可释放。处理入口读历史原件、不要求旧guard仍在、不重复FEED/SETTLE；补料子任务新claim。反例覆盖设备故障/现场锁仍阻断、A占用B等待非执行异常、同培养/子链继续阻断、DB故障后原异常补录而非重开 |
| 外部核准与整链验收 | 未调用真实客户端点，客户适配仍缺真实质量/时间/序号、点表和停止能力批准 | 软件生产链补齐后再开展隔离端到端、客户接口、逐设备现场，分层保留证据；任何层缺失不得伪造GOOD/COMPLETE或启用 |

以上不改变正常调度唯一START/SET_SPEED、独立监控只STOP/留证、M02实际入口仲裁、M07唯一状态/量账/释放和M09仅通知的边界。现有STOP原件回交与其他必要保护继续沿已核准通路工作，不等待新反馈功能或通知。当前文档完善未新增测试通过结论，也未改变客户原文、DDL或共享20项原因定义。

### 11.3 稳定判断参数文档补充（2026-10-21）

按用户要求，在统一方案F.3.1明确PAR-04-ST01/02/03，复用MeasurementPolicy.stability的toleranceGrams/sampleCount/minSeconds；极差、有效样本数和实际时间跨度联合判定，停止侧样本/跨度有更大要求时共同满足。中试参考文档的地秤精度阈值、最近5条和停后至少5秒仅作历史依据，等待5秒不直接证明样本跨度，结束后续监120秒亦不替代；现场值全部待确认/待核准，无默认。同步设备命令、JSON、泵速、逐设备清单及CASE075；本次文档补充不新增schema/DDL，也不代表代码、客户接口或现场验收通过。后续实施按CASE075验证等号、缺值、漂移、缓存、完整覆盖及停止交接，不将三个数字单独达标当安全释放。

### 11.4 本次业务口径确认与验证待办（2026-10-21）

本节保留此前文档修订批的范围记录；“仅修订文档”不再是当前开发授权限制，后续接续实现见11.5。

本次仅修订方案与对应文档，不继续新增代码。ERROR与物理UNKNOWN/STOPPING可并列展示；停止、量/规定观察、安全释放和人工异常处理分别推进。全部安全收尾及旧控制权撤销交接完成后设备可先释放，ERROR人工待办仍保留；设备故障锁/现场锁、同培养队列和关联子链不因此解除。所有异常结束且实际量明确后统一判断严格>5%，不按异常类型排除，也不以该比例替代安全收尾。不同培养对健康已释放设备重新准入；被占用时等待，不制造未执行任务的执行异常。

抖动恢复已经明确：原1000g/J10g、980g触发、993g数值恢复，其余门禁齐备即调度续段，不为观察期余额继续等待；规定停止观察/稳定仍按核准profile完成，不能默认120秒/5秒。门禁暂缺继续保护并最终实时重验；成功续段按新段/阶段重建新窗，正常下降不适用旧起点/J。删除反弹后重新计时、NCS030时机待确认的旧政策。迟到调速仅为停止屏障/隔离的技术故障验收，不作为正常业务流。

待执行验证引用[验收矩阵](../../详细设计/07-补液运行与任务执行/验收与实施顺序.md)CASE048/058/059/062/068/069/074及新增CASE089—092：逐项缺证据拒绝ERROR释放、旧fence不能影响新owner、设备FREE但故障锁未清仍拒启动、释放后重复处理不重复FEED/SETTLE、子任务重新claim、DB恢复只补原异常。文档静态核对与后续单元/SQL/HTTP/进程/浏览器/现场分别记录；本次不增加任何测试通过数，§10及§11.1原验证数字保持原快照范围。

### 11.5 恢复全部四阶段开发后的接续记录（2026-10-21）

用户已结束暂停编码，继续沿本计划实施，不新建计划或工作树。分支仍为`codex/feeding-scheduler`，既有未提交修改保留；本批不提交、推送、调用真实设备或连接共享库。下列证据均是有范围的当前源码验证，不能推为四阶段全部完成。

| 工作包 | 当前实际接线及已执行验证 | 尚需关闭 |
| --- | --- | --- |
| 最新抖动判据 | `FeedingAnomalyEvaluator.observeJitter`保留合格恢复事实；未续段又出现不利样本时BLOCKED，不把已恢复历史改成全期未恢复/NCS030。真实RED后`jitter-latest-policy-green`28项通过 | 实际主循环、独立监控及新段窗口的联合故障验证，不能只凭纯判定器验收 |
| SYSTEM恢复事务及入口 | 补齐`M07ResumeStateWriter.persistJitter`、专用Mapper/XML、同owner STOPPING→HELD、严格新段CAS，以及原密封控制Worker的协调入口和显式cron扫描；不新增purpose或放宽人工恢复。`jitter-scanner-green`14项当前源协调/映射/扫描测试通过 | 独立登记双ACK/activate及最终设备写入的完整SQL/HTTP链；租约、物料、当前恢复资格及并发原因仍实时重验 |
| 恢复真实SQL | 新`M07JitterRecoveryPersistenceIT`4项在本机独立MySQL8.4、新`feeding_validation_*`库和188表三脚本基线通过；覆盖认可暂停提交/回滚、坏candidate拒绝、不同资源各自fence、续段原件绑定及旧版本拒绝。首次实测发现附属秤fence错误等同执行fence，已修正后GREEN；日志`feeding-runtime/jitter-persistence-green-junit.log` | 这是4项Mapper/事务验证；同轮11项协调单测不重复计入SQL数，不代表真实补料或现场通过。实例核端口/数据目录并认证关闭 |
| ERROR安全结算与释放 | 已推进系统可信量结算、ERROR扫描/资格、释放后handling幂等及严格schema2来源；首批7项正常/ERROR收尾SQL在同样隔离基线通过，日志`feeding-runtime/error-safe-release-sql-current-junit.log` | 后续来源/人工更正并发已有新增修改，旧7项不是最终所有源码验证；最新8项SQL、外部解除/新owner及HTTP整链继续复验。UNKNOWN隔离无核准typed原件时仍阻断 |
| 实际反馈与独立上下文 | 生产Main严格配置下原HTTP夹具失败已复现；补显式TEST指标/feedback/anomaly输入后，真实签名HTTP及监控子进程1项通过。完整独立上下文正补版本化协议、持久接收与M07原事实生产链 | 原Registration/Progress及schema1 hash保持；HTTP夹具通过不等于完整上下文已生产接通，DB离线/重放仍须独立验证 |
| 校准生产证据 | 当前Authority校准窗口、原调速采纳来源及速率校验定向109项通过；新增绑定原样本/登记的typed校准拒绝，Worker停止保护正在接入 | 显式k/修正理论时限的不可变采纳事实与真实切阶段仍在补；未核准跨段复用保持阻断，不补k=1 |
| P3生成快照队列规则 | 生产`M07TaskGenerationSourceAdapter`在固定发生项/固定补糖/动态规则的原评估快照写入服务端固定`scopeRules.revision="1"`；`M07GenerationLedgerService`仅接受queueScope、feedingCompletionPolicy、dailyGenerationPolicy、revision四个字符串键及版本1，缺版本、错误版本或额外策略键均在写`run_generation`前失败关闭。真实RED为12项中2项预期失败，实现后聚焦Maven 12/12通过，0失败/错误/跳过 | 只关闭Q01/Q02/Q04快照防漂移，不授SYSTEM任务创建权限；D0、残糖确认模式、同日检测/补料链及后台创建授权缺项继续BLOCKED。还须完整SQL、队列准入和动态规则业务链验收 |
| P4客户适配离线预检 | 新`CustomerOpcConfigurationCheckMain`以受控绝对配置和显式READ_ONLY/PROTECTIVE_STOP模式执行只读配置/能力检查，不连接客户端点；缺配置/能力非0阻断，READ_ONLY无STOP批准仅报告`BLOCKED_EXTERNAL`，完整STOP配置也只报告`CONFIGURED_REQUIRES_RUNTIME_VALIDITY`。当前源离线Maven中customer-adapter 23/23、依赖API 95/95、gateway 70/70通过，审计`p4-customer-adapter-preflight-final.*`已冻结 | 仍未调用真实设备、共享库或通知；真实点表、质量/时间、实际运行/停止反馈、设备健康、部署和现场验收全部保持`BLOCKED_EXTERNAL`，不能由离线预检关闭 |
| P2上一owner释放交接门禁 | 候选资源按`resourceKey + retained fence`核唯一上一owner释放证明及gateway/monitor双ACK，首次使用fence=0允许；缺失、冲突、损坏记录均在任务/guard/START写入前拒绝。Gate 5/5、Preparation 21/21及隔离MySQL 2/2通过，见`p2-release-admission-freeze-report.md` | 只证明上一owner交接准入；真实设备释放、部署后旧写方隔离及现场切换仍未验证 |
| P2固定量Worker装配与ExecutionSpec输入 | 启用固定量Worker现在要求恰好一个Provider和Authority，缺失或重复启动即失败；当前源装配回归17/17通过。新增`M07FixedExecutionCalculationInputProducer`只从typed facts形成schema2、24叶子、确定性JSON/hash，4/4通过，不读取latest/now或补默认值。生产链审计再次确认Provider/Authority无实现Bean、typed producer无生产调用点，装配fail-closed 5/5及producer 4/4通过，见`fixed-execution-spec-production-chain-audit.md` | 完整ExecutionSpec事实加载、weightBasis/physicalBefore/volumeEvidence、预填充W/R/current material、供料比较政策、合格基线、资源/profile及实际入口批准仍缺；不存在不依赖这些输入的诚实最小接线，继续阻断，不用测试Provider或静态Bean冒充生产链 |
| 独立监控首段/续段上下文 | 已把原T/E/p、方向/基准、认可历史、物料会话、实际阶段、原命令及窗口锚点交给版本化上下文；续段经原事务/业务序锁、可靠outbox、签名transport、精确LOCAL ACK、激活及最终派发重验。修复认可账键漏executionId及合法换袋新会话误阻断。86源独立编译通过；聚合488例中487通过，唯一测试夹具错误修正后所属Store 29/29通过；签名HTTP独立复验2/2通过，见`feeding-continuation-context-freeze-summary.md` | context专用真实事务/CAS/回放及并发问题已由下一行关闭；完整DB失联+Main重启+续段派发组合、新续段完整HTTP仍待验证，metric/channel/time/quantity policy缺核准时继续阻断 |
| 独立上下文真实事务与并发 | 新`M07MonitorContextPersistenceIT`以真实Context/RunEvent SQL、Spring事务代理和MySQL RR行锁验证首写/精确LOCAL ACK/重放、原件与回执冲突、CAS/回滚、续段旧ACK及并发。真实RED 16项中15通过，异源第二事务因锁前RR旧快照错误成功；`progress`改为READ_COMMITTED并显式核当前隔离级别，生产`ensureProgress`仍要求外部无事务，未知/RR外层直接调用失败关闭。GREEN单元5/5、隔离MySQL17/17、链仅revision[1,2]，实例认证关闭，见`feeding-context-persistence-freeze-summary.md` | 未改SQL/DDL/首段/续段/ACK业务规则；完整DB失联+独立Main重启+续段派发组合及新续段完整HTTP仍待验证。原RED本地日志被GREEN覆盖，报告只保留root执行结果，不重造原日志 |
| 独立上下文失库重启组合 | 新`M07PersistedContextRestartHttpTest`用真实签名HTTP和真实MonitorMain子进程验证revision1→2 durable ACK后，注入M07 Store不可用、强杀并以同目录重启Main、不重送context；恢复后原progress按registration/revision/hash校验，旧source拒绝，新合格异常保持原identity且coverage=false，独立读/STOP继续并保留首次期限。最终当前源隔离编译通过、1/1 GREEN，见`feeding-context-restart-freeze-summary.md` | 业务库故障为明确DataAccessResourceFailureException注入，网关在JUnit进程，设备为显式TEST驱动；不等同真实数据库停机、客户设备物理停泵或释放验收，新续段完整HTTP仍需随正式采样身份接线验证 |
| P3 Q02统一队列 | `countBlockingTasks`移除错误的全局`admitted=1`过滤；更早的PENDING_REVIEW/PENDING_APPROVAL保留队列位置，同培养、plannedAt/taskId顺序、活动态和终态边界不变。隔离MySQL188表基线真实RED 3/3失败、GREEN 3/3通过，实例认证关闭，见`p3-q02-unified-queue-sql-final.md` | 仅关闭Q02 SQL谓词；SYSTEM创建授权、D0、残糖确认模式、动态补糖计算及完整调度到设备链仍未关闭 |
| P1计量未确认原因投影 | 新增20项原因码生产链矩阵；已把任务或当前执行的`settlement_state=PROVISIONAL`去重投影为`METERING_UNCONFIRMED`，不伪造EVIDENCE_CONFLICT、不改变人工处理/结算/释放规则。真实RED精确复现2项缺失，Maven聚焦11/11通过且18模块BUILD SUCCESS，见`p1-metering-unconfirmed-projection-freeze.md` | DEVICE_STOP_CAPABILITY_UNVERIFIED、SERVICE_HEALTH_FAILED、UNEXPECTED_RESTART、POST_STOP_FLOW_ABNORMAL、STOP_BARRIER_FAILED仍无专用生产方；其余局部链按矩阵继续补真实触发、承载和解除证据，不能为覆盖枚举而伪造事实 |
| 原因码前置事实核对 | `PROTECTION_LATCHED`不能从不可变历史`stop_intent`或候选语义`scheduler_held`推断当前锁；`RESUME_BASELINE_INVALID`现仅有即时通用拒绝，没有baseline identity/version/hash及不可变评估结果。两项均未制造RED或修改代码 | 先补M07归并的保护锁active/cleared+release evidence，以及恢复评估原件含baseline/recognized-ledger引用与decision/reasons；在稳定事实出现前不得投影或改变恢复权限 |
| 实际反馈与采样资格审计 | 生产链已追到独立monitor首反馈/journal→M07 activity分页原件→`MONITOR_EVIDENCE_RECEIVED`→可选QualificationProvider→ExecutionSamplePort v2严格校验/幂等/冲突；system 68/68、monitor 46/46通过。确认`M07MonitorSampleQualificationProvider`无生产实现，RawReading及provider签名缺原设备/通道、原时间文本/时区/精度、归一化和精确command/phase/context/window绑定；配置schema3不等于ExecutionSpec/sample/source identity v3，见`actual-feedback-sampling-production-chain-audit.md` | 先扩正式原始采样与上下文绑定契约并明确客户适配器/M02/M07各自提供字段；若要跨设备聚合，须先定义新sample/source identity版本并同步ExecutionSpec、JSON/Port、DB重放和迁移门禁。现阶段不能用测试lambda、健康成功、ACK、0设定或任意非零读数接生产 |

所有日志和逐源摘要保存在原审计目录`C:/Users/Evan Hou/.codex/visualizations/2026/10/19/01a1534c-e019-7f62-8ac7-f09c686bcdda`。本节继续随实际结果更新；整树编译、完整隔离业务链、HTTP、进程、浏览器、客户接口和现场验证分层登记，不用上述定向结果替代。

本批后续验证快照：`feeding-resumed-system-test-compile.log`于15:34记录18模块Maven `test-compile` BUILD SUCCESS，system3460 main/767 test；这是编译，未执行全部单测。后续上下文、队列和原因投影改动完成后，`M07TaskSafetyProjectionTest`聚焦Maven于2026-10-22 14:53再次完成18模块BUILD SUCCESS并执行11/11通过。独立上下文并发修复合入后，root于2026-10-22 21:19执行18模块`test-compile`，3473个main、793个test源码BUILD SUCCESS；失库重启组合测试加入后于21:35再次增量执行，3473个main、794个test源码BUILD SUCCESS。该结果仍只是最新源码编译，不冒充全量单测。`resumed-control-recovery-current`当前源67项通过，覆盖监控判据、控制、typed校准拒绝→原STOP、SYSTEM恢复协调/状态、映射和扫描；它替代本批重叠的28/11/14/34等单包回归计数，不累加。`feeding-runtime/error-safe-release-sql-final-current-junit.log`最新8项真实SQL通过，替代先前7项，实例认证关闭。结构同步脚本18项通过（`feeding-resumed-schema-tests.log`），首轮沙箱临时目录权限错误已改用工作树内测试临时目录复验，不修改生产结构来迁就环境。

继续开发项：独立异常上下文首段/续段、真实事务/CAS/回放和失库重启保护组合均已接证据，剩余新续段完整HTTP需与正式采样身份一起复验；固定量完整ExecutionSpec事实加载、预填充W/R/current material和供料比较政策仍须显式核准输入，不借最终允差；实际反馈需要先补正式原始采样及context/command/window绑定契约；校准与ERROR软件链按下述已接结果继续做组合故障验证；新增原因码矩阵中无生产方或仅有底层保护语义的项目须先形成稳定active/cleared或评估原件。以上被业务契约输入阻断的软件项不能用默认值或测试实现打通；设备点表、能力和真实现场值保持外部阻断。

本批继续接通结果：校准采纳事实已由真实Authority计算后，在原控制事务的SET_SPEED准备或实际阶段确认成功之后写入；命令插入/阶段CAS失败不留采纳事实，当前源校准组合131项由负责包复验，根侧最终整树编译仍待上下文包合入后重跑。固定量模式新增独立版本化`fixedProtection`输入，普通调速缺p保持阻断，已达终点则保留STOP并归并MONITOR_UNAVAILABLE；严格超量边界及原来源证据定向37项通过，日志`fixed-overfeed-evidence-current-run.log`。ERROR详情已接通授权查询、六类原件投影、SDK和实际详情页；当前后端查询30项、SDK/UI32项、真实回环HTTP9项、隔离SQL3项及浏览器2场景分别通过，重叠项不累加，M02故障锁/现场锁无可信生产来源时仍显示UNKNOWN，续段/旧缺证释放不冒充已支持。

P3队列规则版本修复后的聚焦Maven同时完成当前共享快照3472个main、788个test源码编译并通过上述12项；其范围只覆盖生成来源快照与账本入口，不能替代整树全量单测。首轮GREEN复验曾被并行新增测试的`int`/`Long`编译错误阻断，文件更新后重跑已清零；该中间阻断不记为产品失败。P4离线预检不触网、不输出端点或审批内容，真实设备和现场状态仍保持未验证。

校准采纳首轮真实SQL运行未进入测试方法：隔离MySQL及188表基线正常，MyBatis夹具缺少`RunCommandMapper.M07CommandStateRowResult`导致3项在建图阶段失败，实例已认证关闭；该结果仅记录为测试基础设施缺口。夹具按真实依赖顺序补入Mapper后，在新建隔离库重跑3/3通过，覆盖唯一source key及精确JSON、污染原件仍返回并由严格读取拒绝、失败CAS事务回滚；日志`feeding-runtime/calibration-adoption-sql-current-junit.log`，测试实例认证关闭。固定模式终点和二/三段策略E的范围分开：策略E继续99—100%，固定模式仅消费其明确核准终点，不从历史测试值或其他模式补默认。

### 11.6 测试环境与夹具修复后的复验（2026-10-22）

详见[测试复验记录](../../开发基线/开发包/补料调度-测试复验记录-20261022.md)。HEAD仍为5678c46d01b837745340632b79142f9b8ff774db；未提交、推送或更改生产安全逻辑。修复活动SQL夹具的显式上下文依赖，新增缺上下文不发进度的真实SQL反例；修复窗口资格正例缺跨流时间批准和原阶段锚点；修复Windows测试子进程清理与退出后日志锁交接的有界等待。所有独占、签名、身份、停止、量账和释放守卫保留。

JDK回环故障已确认通过测试会话参数 `-Djdk.net.unixdomain.tmpdir=D:/project/yaoming/SMP/tmp/j17` 解决，不更改全局环境。独立API95/95、Gateway70/70、Monitor最终93/93、客户适配23/23分别通过；HTTP/子进程均为本机TEST服务，不能替代客户接口和现场。隔离MySQL全新188表基线83/83通过，包含活动9项、上下文17项等；旧库固定测试ID冲突未删除数据，另建feeding_validation_1792679638复验，结束后正常shutdown及33087端口无监听。

当前M07广泛回归最终执行2446项：2440通过、6失败、0错误、0跳过（22:52:52，`outputs/feeding-test-20261022/30-m07-final.log`）。三个静态契约类仍未关闭：守卫引用登记1项、命令DAO语句/单表边界2项、运行行创建预检的插入面/操作集合/labId来源3项；未删除测试或放宽白名单。此前窗口资格与重启锁交接错误均在最终整批通过。不得把该批次描述为全量后端或全部调度验收通过。

前端恢复本机固定版本依赖链接和pnpm8.6.2工具，业务workspace链接指向当前worktree，依赖声明/锁文件未改。7文件116/116通过；实验室应用vue-tsc退出0无诊断；SDK API、静态资源、语言、stores、common及实验室应用完整构建均退出0。没有新增浏览器交互验收。所有结果按层独立记录，不与旧包计数叠加；真实设备、现场、完整业务生产输入及上述静态职责门禁继续保留未关闭状态。


### 11.7 六项静态门禁修复与扩大回归（2026-10-23）

详见[六项门禁修复与复验](../../开发基线/开发包/补料调度-六项门禁修复与复验-20261023.md)。原六项已复现并逐入口核对，确认两处实现问题：工作流跨表恢复扫描放错单表命令 DAO；续段握手独立事务缺统一 SYSTEM 首锁。已分别迁移到既有工作流执行 Mapper，并在 Access 的任何业务行锁前取得实际 SYSTEM 行锁。真实基线 revision=0 合法，缺行仍拒绝；不递增管理版本，不改双 ACK/激活、命令身份、计量或释放规则。

其余守卫角色、run 插入面、操作集合与 labId 输入来源按已存在消费者同步精确登记；新增面钉到 12 个 Mapper.statement。扩大回归另外暴露 5 项公共夹具/登记过期，已核对并同步固定消费者装配、真实锁读次数、已有管理操作精确集合及总数；未放宽生产能力封口、权限或单表门禁。

最终定向306/306通过；扩大整体回归2696/2696通过，0失败/错误/跳过（`09-regression-final.log`），含全部原 M07 回归及公共资源事务、管理守卫、开始培养。独立 SQL 14 类84/84通过，含新增 SYSTEM 行锁争用测试；混合08批次曾因旧操作总数断言失败，该项在最终09批次已通过，不将08整批记作Maven成功。测试库按utf8mb4在全新隔离库安装正式188表基线；专用MySQL正常shutdown，临时私密连接副本已删除。前端7文件116/116通过，无前端源码修改，不新增浏览器结论。

验证代码快照为HEAD5678c46d01b837745340632b79142f9b8ff774db上的累积未提交工作树，`outputs/feeding-fix-20261023/source-snapshot.json`覆盖4606个源码/资源文件，本次17个代码/测试修改另有清单。定向与整体用例不重复累计。未提交、推送、创建PR或连接真实设备/通知；原生产输入、设备能力与现场验收缺口仍保留，不因门禁翻绿宣称四阶段全部交付。

独立模块最终复验（`10-independent.log`）：API95/95、Gateway70/70、Monitor93/93、客户适配23/23，Maven退出0。本机签名HTTP/进程与TEST驱动通过，不代表客户接口或现场通过；4606文件源码/资源快照最终无漂移。


### 11.8 隔离HTTP与实际浏览器查询联调（2026-10-23）

[本轮联调记录](../../开发基线/开发包/补料调度-隔离HTTP与浏览器联调记录-20261023.md)：定向HTTP/停止/恢复/释放组件153/153，安全查询编译/投影14/14，独立网关/监控/续段三方交接真实进程3/3，前端7文件116/116通过；这些批次有重叠，不累计为不同用例。实际任务页面和SDK源码连真实Controller/Application/查询Mapper/新隔离SQL，5种状态22项浏览器断言通过；保留未确认停料禁止恢复、ERROR释放后待处理、外部交接和锁未知、缺实际首启不推断等边界。浏览器发现EXECUTED裸枚举，补“已完成”标签后在真实页面复验。

新增src/test只读Main和前端测试夹具。状态/原释放事件由显式TEST夹具预置，不是调度执行产生；管理写一律TEST边界403。实际浏览器恢复POST带原请求ID/管理版本/载荷，被拒绝后任务仍PAUSED、版本3，SQL仍5条预置命令和0量账。不能报告成功恢复、实际H06释放、生产M01鉴权或完整端到端通过。

完整业务链仍NOT_VERIFIED：M07FixedTaskPreparationProvider/Authority无生产实现，M07MonitorSampleQualificationProvider无生产提供方；前者须闭合固定ExecutionSpec事实及W/R/供料比较等核准来源，后者须闭合原设备/通道/时间、命令/阶段/context/window与原件版本。以上是明确软件/输入契约缺口，不仅是现场阻断；不可用当前状态夹具或测试lambda补成生产成功。之后需在真正隔离的身份/审批/设备输入下串同一任务的准入→claim→唯一启动→实际采样→STOP/完整观察→唯一量账→续段/释放双ACK。客户接口、设备与现场仍未验证，未提交或推送。

本轮实验室应用vue-tsc退出0无诊断；查询Java/Vite/隔离MySQL已全部关闭，三个本轮端口无监听，临时私密配置删除。原后端4606文件快照无漂移，新测试Main和前端测试/标签变动另有哈希；未提交推送。

### 11.9 固定任务Provider/Authority与正式采样接续（2026-10-23，实施中）

- 已新增生产固定准备Provider/Authority、显式独占首启来源、启动前Authority、实际首启来源与有界投影入口；复用原claim、回执、计量和资源框架。当前仅支持明确核准的单原生g供料秤，不把来源配置当设备结果。
- 已新增正式采样资格生产者，保留真实共享v2原包身份及实际有效运行计数；异设备boot/sequence、通道和非原生单位组合仍是软件接线缺口，不能归为已支持或只待现场。
- 已补原收尾扫描缺失的observation_coverage生产链：原STOPPED、资格、连续原始日志和真实共同时间覆盖，CAS与LOCAL事实同事务。Timeline和生产Authority反例通过；持久化收尾整链仍须继续。
- 当前43项定向测试通过，另3项停止覆盖Authority测试通过，范围有明确日志；M07 Maven回归2412项中2411通过、1项新增只读Provider/配置类未登记，已分类登记，待重跑。不能沿用早先52项覆盖本批所有修改。
- 隔离SQL `M07ApprovedFixedClaimPersistenceIT`已从初始READY任务/M02传感输入/M03重量/物料/通讯映射，经真实Provider、Authority、M03/M02提供方及原资源事务生成唯一PREPARED START、执行、首段和EXECUTE计算；重复claim拒绝。没有预写执行结果，未启动设备。日志38-fixed-claim-sql.log。SQL运行发现并修复原生DECIMAL末尾零误拒，另补读数格式测试及版本溢出反例。
- 同一任务已在隔离真实组合中完成登记/上下文交接、签名HTTP START EXECUTED、实际首次开始归并及正式采样驱动 STARTING→HIGH。实际链发现并修复控制器设备类型接入、START/RUNNING回执语义及原命令时间SQL投影缺失；对应47、52、59、65批定向测试通过，批次重叠不累计。第66批仍在运行验证，不能据此宣称整链通过。
- **仍未完成：**连续控制与独立监控、STOP/覆盖/唯一量账、恢复和完整释放的隔离组合；新增HTTP/浏览器完整执行链尚NOT_VERIFIED。此前只读状态夹具不得计为本链证据。当前缺项继续作为软件开发/验证工作，不标等待现场。11.8关于Provider/Authority未实现的描述是当时快照，当前进展以本节为准。

具体配置、限制与逐轮证据见开发包《补料调度-固定任务与正式采样接线-20261023》。不提交、推送或接真实设备。

本节后续进展：72批36/36定向通过（含原守卫登记失败项）；73批新隔离库同一真实TEST任务已完成持续控制→正常终点STOP_PREPARED→签名STOP EXECUTED→STOPPING。停止覆盖尚未生成，计量与释放仍未通过；命令切换附近原件时间资格、68批控制进度交接超期仍待核对。未将测试入口调整、部分HTTP成功或STOPPING当成完整链路通过。各批测试不重复累计。

继续接线：已修复监控判定原件误拒、停止前原包迟到绑定、毫秒计数混入称重窗口和结算尾零精度误拒；测试 ID 重绑定误改观察参数也已单独修复。79批24/24、89批28/28、96批34/34是不同范围的定向证据，不重复累计。91批已落真实 INCOMPLETE 覆盖；92/93批只读回滚诊断不能当成完成与释放成功。最新正常执行回归正在运行，完整异常停止/恢复/释放与后续 HTTP/浏览器仍为软件实施验证项。详见接线记录“停止覆盖与收尾接续”，不将剩余软件缺口标成等待现场。

### 11.10 停止覆盖、恢复及实际HTTP/浏览器接续（2026-10-23，实施中）

- 首次实际开始归并补齐已有task.started_at的同事务CAS；释放使用原STOP原件的精确时刻并核对数据库毫秒投影，同一毫秒内真实迟到START仍拒绝。无新增表或字段。101批30项、107批71项为相应定向证据，不与重叠批次累计。
- 113批独立超量场景已真实完成ERROR、确认计量、唯一FEED/SETTLE、整组FREE及外部双ACK，未等待人工handling。此前正常场景10.1g超过TEST最终上界而保留ERROR，不作为正常通过。
- `M07_STOP_OBSERVATION_PROGRESS`已接入原STOPPING、PAUSE_REQUESTED及PAUSED观察链，源幂等键采用原登记与原件的组合摘要，保留完整原件和重算校验。43项定向、10项真实SQL及17项守卫登记检查通过（有重叠，不累加）。128/130/132批失败保留为修复前证据。
- 已修复进度查询遍历已交接历史的执行计划问题；同库EXPLAIN约617ms→14ms，最终SQL已在上述10项隔离SQL中复验。上下文进度重复解析原历史引起超时，改为每事务重读原行、逐行指纹核对后只复用解析结果；篡改、回滚、淘汰等62项定向通过。未放宽3秒TEST进度门槛、原件链或双ACK。
- live30浏览器暂停已实际到PAUSED，完成原STOP、完整观察和唯一分段量认可。live29/31暴露并发缺口：STOP尚未回执时先收的原件暂不合格，游标推进后缺少自动重投影，导致覆盖永久缺包。STOP意图至调用前的原命令时间归属已先红后绿，31项通过。现已补每次POLL（包括空页）的原位置有界重投影，最旧未决原件阻止后包抢先推进计数；仅原登记、双ACK和原START/续段SET_SPEED共同证明的调用前原件可记录LOCAL排除事实，原件保留且不计入覆盖或量账。当前53项单元/契约、4项隔离SQL通过；实际生产Provider的数据库访问失败原样向上传播并回滚，不冒充元数据不合格。完整链待本轮复验，未宣称所有并发时序通过。
- TEST实际STOP回执时刻已改为不早于它所依据的实际读数，29项定向通过；新段首次采样等待改为逐段起算，2项通过，独立监控首次期限保持原值。live28发生约一小时的运行时间跳跃并事务超时，未作为通过证据。
- 到期保护证据`STOP_CONFIRMATION_DEADLINE_REACHED`严格核原请求/回执、身份、摘要、首次期限及已归并原因，可保留在覆盖原件链中，但不贡献样本或观察时间、不解除异常；补收尾扫描拒绝原因日志，32项定向通过，完整HTTP故障链待复验。
- FIXED恢复接通原T/E、显式同袋供料审批、实时M02预读及原事务重验，sourceFacts v2保留供料证据，并在续段激活及最终实际写入口重验来源/会话/量/基线/有效期。供料统一定向109/109为当前范围证据；真实HTTP续段仍待通过。未核准比较口径、旧首启审批和换袋仍不得借用该授权。
- 续段最终释放登记、双ACK交接及页面投影已补代码，69项定向和4项真实SQL通过；live30真实恢复仍503，新段SET_SPEED未执行。后续真实MySQL复现：默认RR在等待原runtime锁后仍看不到刚提交的前段ACK。续段上下文事务已改为READ_COMMITTED并拒绝不兼容外层事务，原来源scope与精确ACK校验保留，64项定向及23项独立SQL通过；137版只读档案在已有运行进度解析前缀后首次续段核验约738ms，全冷重放约2.9s，不能作为实际恢复通过或全冷性能保证。派发拒绝保留内部根因且不向HTTP暴露底层消息，37项定向通过。
- 实际续段接线复核另发现：正式采样和执行Authority误要求续段eligibility来源等于首段profile来源；Resolver还误用仅登记首段ACK的释放查询读取续段ACK。已补原登记/双ACK/eligibility链的核准来源追溯及正确ACK读取，75项定向、4项隔离SQL通过；不改写续段来源或删除来源校验。真实续段首样、持续控制、最终停止和释放仍须整链复验。
- **最新正常完整链：**169批/live32从初始事实、实际START、持续控制到原终点STOP，完成实际停止、完整观察、唯一FEED/SETTLE、整组资源FREE和外部双ACK。实际量10.000000g，任务EXECUTED，FEED=1、SETTLE=1、人工handling=0。172批真实页面显示“已完成/已停料/已认可”，详情RELEASED/ACKNOWLEDGED。
- **最新异常完整链：**173批/live33仅在TEST设备输入注入超量，实际12.300000g，最终ERROR/STOPPED/CONFIRMED，FEED=1、SETTLE=1、人工handling=0、整组FREE和双ACK；175批浏览器确认异常状态与资源释放分离。现场锁/设备故障锁页面保持UNKNOWN，未伪造已解除。
- 176批保护协议、受控网关、独立监控及客户适配器四模块Maven回归281/281通过（95、70、93、23），0失败/错误/跳过。该批不覆盖system中的后续重投影、续段事务修改，也不替代客户设备或现场验收。

- 180批当前源码Maven clean编译及指定调度/资源/管理守卫/命令回归2986/2986通过，0失败/错误/跳过。181批17类隔离SQL初轮100项执行通过，但固定准入测试因双构造器未被JUnit实例化；改为单默认构造器及显式TEST live工厂后，在新独立数据库重跑101/101通过，0失败/跳过。182批工厂身份/参数保持测试1/1通过。上述数量各自报告，不与定向批次累加。
- 183批/live34首次反馈被正确拒绝：TEST驱动把START首次物理转换时刻错误写为读数之后的确认时刻。185批先复现失败，修复为START记录实际转换再读反馈，STOP仍在取得停止反馈后确认；186批6/6通过，未改生产时间校验。该变更仅涉及TEST驱动与测试，180批生产代码快照仍适用。
- 187批/live35暴露原件重投影的新生产问题：原调用排除证明错误混比命令意图摘要与结果证据摘要，导致启动前原件永久阻止后续采样。独立监控触发进度保护停止；失败数据库及日志保留，未记为正常或恢复通过。已补独立摘要重算及反例，57项定向及4项独立SQL通过；不移除原件完整性校验。该生产修复发生于180批之后，整体结果须按当前变更范围重新核验。
- 190批/live36从实际START运行到HIGH，浏览器暂停HTTP202后完成实际停料、观察及唯一段量认可，进入PAUSED；恢复HTTP503。只读原件核对定位TEST网关未装配`requireContinuation`和`requireContinuationActivation`，默认拒绝发生于12:28:57.831，进度超时首次12:28:58.952，不能把后者当成该503根因。现补基于真实M07续段原件的TEST权限校验；生产默认拒绝保持。192/193批保存暂停页面、HTTP202及503响应，实际续段和最终释放尚未通过。

- live36所缺TEST网关续段校验已接入，读取真实REQUEST/ELIGIBLE、原STOP及覆盖、唯一FEED和新上下文ACK；`test-continuation-authority-green.log`25/25通过。此边界仅是TEST本机网关，不替代客户网关配置验收。
- 194批/live37浏览器暂停HTTP202后再次真实PAUSED；恢复HTTP503，原新段SET_SPEED未调用。只读原件确认前段第144版上下文在续段事务中尚为PENDING，真实ACK随后提交；该次续段事务约360ms，不能归因为全冷解析慢。已补合法末版的事务外原件交接：原事务核完整来源/链/身份后，只有单一PENDING/RETRY尾版可补发，真ACK落库后仅重验一次；内链缺ACK、PUBLISHED缺ACK或新并发尾版仍阻断。`context-tail-unit-green.log`75/75、`context-tail-sql-green.log`25/25通过，包含真实无ACK及并发时序。
- 已关闭段的重投影不再重复查询运行投影资格；完整原件、接收游标和停止观察原件链仍保留，不为关闭段新增运行样本。`monitor-closed-reprojection-green.log`66/66、对应SQL5/5通过。
- 生产已有`M07PreparedStopDispatchTask`扫描原PREPARED STOP和SET_SPEED，缺项是隔离Main未装配，现已接入。`prepared-resume-recovery`定向60/60、隔离SQL2/2及197批Main装配19/19通过；仍只允许未调用原命令重试，UNKNOWN/已调用命令不能重发。TEST扫描周期不作为生产部署默认值或已核准参数。
- 已修复真实续段协议收件：CONTINUATION/CONTINUATION_READY严格重验完整原REQUEST、双ACK及监控回执。仅对已执行续段命令调用前、精确匹配previousIdentity的完整GOOD原件记录LOCAL排除，原MISMATCH不改写且不贡献样本/覆盖/量账；SQL同步两个精确排除原因。`monitor-continuation-current-green.log`70/70、`monitor-continuation-old-identity-sql-green.log`6/6通过；后者采样Port为明确测试替身，不能替代完整续段。
- 首反馈留证落入紧随其后的STOP覆盖区间时，原实现误将FIRST_RUNNING_FEEDBACK_QUALIFIED当未知证据拒绝。纯wire codec移至既有feeding-safety API，M07严格核同登记、完整已合格OBS、原锚点及时间，仅作非采样留证，不重新核准独立policy、不赋予运行/停止/覆盖权限。`first-feedback-coverage-green.log`57/57、`first-feedback-coverage-process.log`1/1真实独立进程验证通过；首次运行缺JDK短管道参数的环境失败单独保留，不记为实现失败或通过。
- 198批/live38已由浏览器完成暂停HTTP202、真实PAUSED；恢复HTTP202及原SET_SPEED实际执行，新段原件、首样和首反馈已接收。但交接前的旧段MISMATCH原件进入固定量监控历史列表，原`PersistedContextAnomalyAuthority.points`对整列要求新段MATCH，导致后续合格新段读数仍被拒绝，触发`ANOMALY_QUALIFICATION_UNAVAILABLE / FIXED_AMOUNT_FACTS_UNQUALIFIED`保护停止。202批HTTP、201/203批页面和原日志/库保留，不记为恢复整链通过。现FIXED按最新完整合格原包计算当前累计量，保留最新坏包拒绝、同源冲突及时间倒退检查；32/32定向通过。STRATEGY按真实阶段/命令窗口限定原包，跨锚点包拒绝，非运行阶段只判断累计量；去重前先核完整包全部指标。后续49/49定向通过，与32项属于不同快照，不累加。
- 204批/live39已实际续段，固定量资格问题未再发生；原续段登记至首进度仍超过TEST的3秒控制期限，独立监控按原期限保护停止。210批只读SQL确认ERROR/STOPPED/CONFIRMED、2.100000g、FEED=2、SETTLE=1、整组FREE和释放交接ACK。该结果是异常安全收尾证据，未取得正常恢复完成或最终释放页面证据。
- 前段上下文来源及ACK已从逐版查询改为三次完整批量原件查询，按精确身份组装并拒绝缺件、重复及外来件；每事务仍读取全部原件、状态及完整指纹，仅复用已验证解析结果。99/99单元/Mapper、26/26隔离SQL通过。185版档案的ACK后重验约104ms，冷进程首次全链校验约3833ms；不能将warm性能或局部测试当作3秒部署预算已满足。
- 211批/live40尚未操作暂停，在HIGH约150秒时M07入库处理耗时3548ms，覆盖原3秒进度期限，触发EXECUTION_PROGRESS_STALLED。期间独立监控仍约220ms采样，762次OBS对应762次固定量决策，无资格异常。待投影SQL的处置子查询被优化器改成历史表扫描，现改为两个精确来源键关联并使用已有唯一索引；同原件warm查询125–134ms降至47–51ms，8/8隔离SQL通过，无DDL或门槛变更。此结果只证明已消除一项持续开销，不证明3548ms尖峰已完全解决。
- 213批/live41浏览器暂停HTTP202、实际PAUSED，恢复HTTP202且原SET_SPEED实际执行；原登记13:51:53.532Z、首反馈13:51:56.4599429Z，13:51:56.6785845Z按原3秒期限保护停止。217批只读SQL确认ERROR/STOPPED/CONFIRMED、2.700000g、FEED=2、SETTLE=1、整组FREE及释放交接ACK各一条。215/216批保留暂停页面与HTTP记录；未取得正常恢复完成或最终释放页面证据。重复校验与证据拉取的累计开销仍在修复，原登记、首停期限及全部安全门禁不变。
- 后续等价性能修复：三处只需验证来源却丢弃`encode`结果的调用改为原`validateSource`，校验内容不变；137/137聚合定向、26/26SQL通过，同一185版档案首次续段896ms降至691ms。独立`/evidence`复用已验证导出前缀、只解析新增原件，44/44单元及2/2真实独立进程通过，覆盖续段两侧、重启逐字等价、日志损坏、身份/游标/页上限及导出期间独立追加。以上是分包快照，不与旧99项、旧32/49项或后续整体回归相加。
- **当前暂停恢复完整链：**218批/live42从实际START、高速补料，经浏览器暂停202、实际PAUSED和恢复202后，新段实际SET_SPEED及首反馈/正式采样成立，14:10:56Z进入HIGH；按原终点于14:13:27Z发STOP，14:13:41Z完成EXECUTED/STOPPED/CONFIRMED。实际累计10.000000g、两条FEED、一份SETTLE、人工handling=0；225批只读SQL确认整组FREE及释放/交接/ACK各一条。224批最终页面显示“已完成/已停料/已认可”，详情RELEASED/ACKNOWLEDGED，控制台0 error。现场锁与设备故障锁仍UNKNOWN，不宣称解除。原3秒控制期限及所有资格不变；退出码0。该证据不扩展为冷重启在3秒内完成的保证或现场验收。

- **同一生产快照的正常复验：**226批/live43完成实际START、正式采样连续控制、原终点STOP、实际停止及完整观察，最终EXECUTED/STOPPED/CONFIRMED、10.000000g、FEED=1、SETTLE=1、人工handling=0、整组FREE和释放交接ACK。229批最终真实页面显示“已完成/已停料/已认可”，详情RELEASED/ACKNOWLEDGED，控制台0 error；Main退出0。
- **同一生产快照的超量复验：**230批/live44只在TEST设备物理输入注入超量，独立监控记录NCS009并停止，最终ERROR/STOPPED/CONFIRMED、12.300000g、FEED=1、SETTLE=1、人工handling=0、整组FREE和释放交接ACK。232批真实页面保留异常且显示已释放，控制台0 error；Main退出0。不把异常资源释放写成异常已人工处理或设备故障锁已解除。
- **最终扩大回归：**233批Maven clean编译及调度、资源、管理守卫、命令相关回归3044/3044通过；234批保护协议、受控网关、独立监控、客户适配器四模块310/310通过（95、70、122、23）；236批五个补料页面/SDK定向文件61/61通过，均0失败/错误/跳过。236批首次命令因本机缺少`node_modules/.bin`未执行测试；随后使用已安装pnpm8.6.2调用现有Vitest入口执行，未修改依赖或测试门槛。各层分别报告，不与旧批次重复累计。
- **隔离SQL组合复验：**18类联合首轮108/110，失败日志保留为235批。根因是抖动恢复测试遗留自己的PREPARED命令995000704，后续全局扫描器正确读取后改变测试分页。只为该测试和扫描测试增加按本次成功插入的command_id、execution_id、request_id精确清理，生产SQL、扫描次数及断言不改。237批重新编译通过；238批在全新`feeding_validation_1792766347539`库安装正式01/02/03基线后110/110通过，0失败/中止/跳过。旧失败库未清除。233之后仅上述两份IT修改；239批源码快照及差异记录将测试变化与未改变的生产代码分开，3044项结果不声称覆盖后来修改的IT，后者以238批为准。

当前固定量正常补料、超量异常安全收尾、人工暂停恢复至原终点三条链已取得完整隔离HTTP/浏览器证据。三段校准、SYSTEM抖动自动恢复、其他异常/物料组合及独立设备原始身份等能力仍按各自证据登记，不能从这三条链推导全部四阶段或全部场景通过。前述逐批记录中的“待复验”描述保留对应快照，当前三场景以live42—44为准。上述日志均位于`outputs/feeding-http-browser-20261023/`；具体HTTP、浏览器和数据库证据见[联调记录](../../开发基线/开发包/补料调度-隔离HTTP与浏览器联调记录-20261023.md)。所有执行结果和量账由正式业务链生成，TEST只提供初始审批、参数、M01身份边界及设备物理输入。真实设备、共享数据库、生产通知和现场验收均未执行；不提交、推送或创建PR。

### 11.11 四阶段重新核对与接续修复（2026-10-23，实施中）

本节替代§10、§11.2及早期逐批记录作为当前剩余工作的索引；旧记录保留其代码快照和证据时间，不据历史缺项重复开发。核对基线：分支`codex/feeding-scheduler`，HEAD `5678c46d01b837745340632b79142f9b8ff774db`，500个工作区路径、索引为空；239批4653个后端源码/资源/POM摘要与核对时一致。此次修复开始后以新的测试和源码快照为准。

用户已授权接续全部具备条件的软件工作。优先顺序为三段校准、独立抖动恢复、暂停后取消、异常补料；之后推进不依赖未确认输入的其余缺口。沿现有量账、状态机和资源守卫，保持首次开始日、未知命令、首次停止期限、真实覆盖、双ACK及释放边界。未确认参数、跨段校准和换袋政策不补默认值；不连接真实设备或共享数据库，不提交、推送或创建PR。

| 阶段/工作包 | 本次确认的剩余软件缺口 | 待验证项 | 业务输入/客户现场阻塞 |
| --- | --- | --- | --- |
| P1 原因与证据 | 2026-10-24复核：UNEXPECTED_RESTART和STOP_BARRIER_FAILED已有独立监控生产判定及持久STOP多原因；PROTECTION_LATCHED已有网关当前状态→POLL ACK原件→M07当前身份投影；RESUME_BASELINE_INVALID已由TaskResumeIntentService真实捕获原守卫拒绝并在回滚后调用Recorder重锁留证，不能再笼统列为无生产者。DEVICE_STOP_CAPABILITY_UNVERIFIED已由M02原注册权威核验的强类型拒绝证据持久化，并接M07身份校验、NOT_SENT撤回及M09映射交接；194新隔离SQL11/11及196原件/接线76/76。仍缺SERVICE_HEALTH_FAILED、POST_STOP_FLOW_ABNORMAL所依赖的核准健康与停后余流判据，缺依据不制造特定原因 | 已有Monitor/Gateway/Projection/Recorder单元及保护状态隔离SQL证据；恢复基线拒绝已有关联入口测试，但完整拒绝→另事务持久→页面及故障重启场景仍待验证。首启跨日、迟到/未知、停止/观察/释放组合和M09端到端仍分层复验 | 实际停止能力、服务健康语义、停后余流阈值与故障锁权威来源须核准；缺值继续保护，不能把通用MONITOR_UNAVAILABLE改称已证实的特定故障，也不从历史stop_intent/schedulerHeld推断当前锁 |
| P2 固定量闭环及告警 | 核准文件/pin的FeedingSafetyRuleMappingProvider已存在；独立保护请求经原身份核验后保存原件并交既有outbox/M09，缺映射保持WAITING_MAPPING。NOT_SENT双端撤回、原H06及双ACK、新版本重核准后attempt2实际启动/收尾已接线，不造首次开始或停止/量账事实。各精确原因见P1 | live42—44正常/超量/人工暂停恢复通过；not-sent-http-v8第二尝试实际10g、唯一量账/完整释放及故障回滚2/2。§11.11.9真实33088业务DB进程中断、离线122条原件归并及ERROR安全计量/释放通过。237协议342/342包含网关/监控Main故障；§11.11.10已补真实仅M07调度JVM强杀、独立读停及原DB重建后的计量/释放完整链。纯246b产物的迟到HTTP及STOP故障4场景已全部通过（109893ms，0跳过/0失败）：原START/SET_SPEED在独立STOP后到达M02均409且物理写不增，原M07命令UNKNOWN、查单未知、资源保留；STOP实际失败/超时后经真实反馈、完整观察、唯一FEED/SETTLE及双ACK释放形成ERROR收尾，保留NCS013及首次期限。该证据不覆盖已进入下游driver.write的在途物理调用撤销；仍须逐设备核准该能力 | 客户M09核准映射及渠道参数、真实设备接口和部署授权；当前TEST映射/接收不发送真实通知 |
| P3-A 三段校准（优先） | 已修复合法非采样原件识别、真实校准采纳、命令精度门禁及重复解析/读取耗时；未知证据仍拒绝，不再重复列为未实现 | 165最终代码完整隔离链通过：真实120s校准、单次校准采纳、HIGH/LOW、正常终点、10g、单FEED/SETTLE及整组释放ACK，进程退出0。浏览器及其他校准故障组合分开待验 | 校准窗口/范围必须核准；跨段复用或重建规则未确认，保持阻断 |
| P3-B 独立抖动恢复（优先） | 原窗/J/身份交接、多来源一致性、较早原停止时间、SYSTEM续段及旧包重投影均已接线；不删原因、不伪造M07触发 | 164最新完整隔离链通过：真实触发/停料、原候选重验、SYSTEM续段、双ACK、10g、两段FEED/单SETTLE、整组FREE及释放ACK。进程故障组合和浏览器仍单列待验 | 候选出现后反弹的重新观察/报警时机仍待确认；不自行报持续NCS030 |
| P3-C 暂停后取消（优先） | Direct/审批安全收尾生产者已接通，沿原停止/观察、唯一FEED及SETTLE关闭，不再列为仅改任务状态 | 026/028已有实际HTTP/浏览器及释放证据；本轮整体回归复验其SQL/事务，不将旧页面结果冒充最新浏览器复验 | 不以取消推断实际停料；缺最终计算输入仍阻断 |
| P3-D 异常补料（优先） | AUTO整数克、严格>5%、独立子任务身份、审计、SC009修复专用CAS及真实M06提交/签审/投递已接通；MANUAL保留原小数精度。生产运行仍须当前子任务自身核准的准备来源，不能复用父批准 | auto-child-v6及197：正式HTTP生成、实际claim/START、9g、唯一FEED/SETTLE、完整释放双ACK及真实任务页面通过。232新库SC009批准/拒绝/事件故障回滚与SC048合并5/5；两批证据边界不同，不累加为同一条生产动态核准全链 | 子任务自身执行/物料/供料比较核准输入仍必需；多段人工改量/手补的物料分摊政策未确认，不能将差额分给第一袋 |
| P3-E 生成/计算/替换 | SYSTEM生成、任务/日额度、M03候选POST、SC019初始化/SC048替换独立政策、M06签审/免审证据、M04实际激活、M07替换/派生及不可变回执均已接。新增PERCENT/RULE生产扫描、F02/F03/F04独立EXECUTE及M03/M04原件窄Port；RULE核当前M05确认、唯一量账和原最小阈值，并严格比较实时计算/批准ExecutionSpec/原任务额度目标。未核准来源仍阻断 | direct-p01-sql-final 10/10；232审批链合并5/5；229正式候选HTTP10/10及230候选组件浏览器通过，边界同前。RULE/PERCENT最新局部回归102/102、真实M07 SQL7/7；上游M03/M05为明确TEST原件，另有实际Port行为测试。rule-process曾完成10g/唯一FEED及SETTLE/整组释放；TEST Main已改用正式scanner。纯246b最终复跑发现首启前原读数、首启后封装外壳阻塞投影队头的生产问题，已按§11.11.11窄修并定向63/63通过；新修复快照的完整RULE进程仍待复验。PERCENT/RULE本次浏览器未验 | D0、残糖/规则输入、供料比较及逐任务执行准备批准按契约核准；外部量账源未接，AUTO不继承父任务批准。仅补液方案入口获准，其余六类配置页及连续式不扩入本次；不将TEST读取或批准输入当现场就绪 |
| P4 客户适配与交付 | 客户适配已按现有证据实现受控只读/安全STOP及原件归档；正常START/SET_SPEED、权威query和合格反馈受下游契约输入阻断，不用TEST实现兜底。v2单原包资格已有；采样身份多流v3尚未核准，配置schema3/4不代替它。独立入口部署契约、显式配置校验、实例目录隔离及切换回退步骤已补，部署参数与容量仍须按目标环境验证 | 隔离接口、进程、部署故障、切换回退和容量；现场按逐设备启用清单分别验收 | 实际接口版本/鉴权、命令幂等/查询/时效/回执、映射/单位/质量/时间/序号、运行/停料反馈及健康契约、旧写方隔离和操作授权 |

`maximum-active-bindings=1`为当前单资源组进程边界，可按资源组部署多个独立进程，不把单进程多绑定列为必修缺陷。配置schema3/4不等于采样身份v3已接线。

本轮开始时的历史粗估（随本节新增完成证据已过时，不能作为当前剩余工期）：当时可执行编码及定向验证15–25人日、完整隔离验证10–15人日，合计25–40人日；业务/协议确认后条件性软件12–22人日；现场每设备组4–6人日，联合切换回退2–3人日。1人日按8小时，验证场景存在复用，不与各代理估算机械叠加。两条有效并行工作线连同集成，当前可做部分约3–5周；输入及时的全部软件约5–8周，客户等待和上游改造另计。随真实失败测试及实现证据修订估算。

本轮执行分工：校准、独立抖动、暂停取消分别拥有相应源码与测试；主代理负责异常补料、计划/契约同步和串行构建/隔离验证。共享API先统一，禁止并发构建覆盖target。执行日志与新快照保存于`outputs/feeding-gap-repair-20261023/`。本节初始静态发现尚未记为修复或验证通过。

#### 11.11.1 优先修复与当前证据（2026-10-24，继续实施）

- P3-A已修复校准窗口误拒：对正常首反馈及异常监控判定原件严格核验身份、原OBS、策略来源和时间；EVIDENCE不贡献校准时间、实际量或采样。未知/保护/停止证据仍拒绝。实际三段全程及校准结果采纳仍待本轮隔离进程验证。
- P3-B已增加独立监控原触发窗口/J的完整交接，并核对原执行命令、实际RUNNING反馈、冻结规格、资源、速度和物料身份；同一原窗的双来源可归并，其他原因仍阻断SYSTEM恢复。原件唯一性、篡改拒绝和回滚已做真实SQL。完整SYSTEM新段、双ACK及最终释放仍待隔离链验证。
- P3-C已接Direct/审批暂停取消的安全收尾生产者：沿原STOP及完整覆盖、唯一FEED认可和SETTLE关闭剩余计划，再由原资源释放链处理；新增CANCEL交接事件严格版本，不造STOP、不重复入FEED。当前SQL证据证明原子性和CAS，不代表HTTP/浏览器已通过。
- P3-D已修正AUTO子任务为自身AMOUNT和amountGrams/targetGrams，清除父PERCENT/RULE参数；用户本轮明确AUTO仅整数克，MANUAL保留最多6位小数，已同步后端、SDK、页面和正式契约。少加判断使用原T/M精确比较 `(T-M)×100 > T×5`；展示字段仍保留原6位四舍五入。释放消费者同步核验原目标、原量和该边界，不依赖显示值判断资格。
- P2核准告警映射已增加受控文件及固定SHA-256生产装配，严格匹配实验室/源事件；缺映射继续WAITING_MAPPING，不提供默认规则键。正式加载器→M07 outbox→M09持久化收件/重放/失败重试在新隔离库7/7通过（017批）；通知接收人边界仍是TEST替身，没有发送真实通知。016批重用旧测试库导致固定TEST主键冲突，保留失败记录；新库复验未改变业务校验。
- 当前联合编译/定向回归012批349/349（API 3、monitor 7、system 339）通过；013批四类真实MySQL21/21通过，含暂停取消5项、独立抖动原件3项。上述快照早于释放消费者精确5%后续修改，后者另有140/140定向结果，下一次联合回归须纳入。AUTO前端23/23通过（009批），取消HTTP入口权限/版本头7/7通过（015批）；均不重复累计，也不替代实际HTTP执行和浏览器验收。
- P3-E自动生成/日额度、公式生产者及M03限定方案替换仍在编码；剩余P1精确原因、P2进程故障组合、P4可执行部署验证继续按本节表格推进。没有将软件缺口改记为客户现场阻塞；未提交或推送。

#### 11.11.2 实际链继续验证与新确认（2026-10-24，实施中）

- P3-C暂停后取消已取得完整隔离证据：026批实际START→浏览器暂停202→合格停料/观察→浏览器取消200；CANCELLED/STOPPED/CONFIRMED、4.000000g、FEED=1、SETTLE=1、人工handling=0，整组FREE、独立交接ACK。028批页面显示已取消，控制台0 error。修复M02释放消费者仅接受UUID、误拒正式调度的`m07-fixed-start:<原commandId>`：只新增精确原START身份格式，不接受任意requestId，24项回归通过。旧022失败记录保留，不算通过。
- P3-D用户明确AUTO整数克、MANUAL最多6位；补实际JDBC DATE回归，原实现`java.sql.Date.toInstant()`抛错，改为保留原日历日，034红/035绿7项。不能把原计划日移动到今日。异常实际读故障后的HTTP处理及AUTO子任务仍在验证。
- P3-E固定PERCENT执行已接原初始重量与同一F02计算内核，保留批准target与精度量化核对；早期019红/020绿47项由2026-10-24生产扫描及SQL证据更新：PERCENT/RULE/AMOUNT合并7/7真实M07 SQL，HTTP及浏览器不由该SQL结果替代。RULE独立EXECUTE与原任务额度目标绑定、自动生成及M03限定替换的当前证据和边界见上表。
- P1当前保护锁由M02当前状态回执及最新poll投影，不由历史STOP或schedulerHeld推断；036真实SQL发现JSON null变字符串，修正后037批3/3通过，未知新回执不会回退旧LATCHED。STOP_BARRIER_FAILED及停后实际再运行的精确原因已有独立定向回归，尚待合并后的完整进程验证；现场锁和设备故障锁仍不推断。
- P3-A真实三段前两次因TEST设备双时钟/量化矛盾安全停止；修正测试时基而未放宽生产计时。033批进一步证实精确整秒窗口不可得导致MONITOR_UNAVAILABLE。用户明确采用真实窗口/实际时长后，已同步统一方案、M04 Q09及M07契约，API窗口/原件/观察043批34/34通过；旧schema1留证仍按原精确周期，新trigger schema2保留真实端点和原J，不改配置/采样身份版本。
- 044批三段进入CALIBRATING后，约55s因逐点重复读取整段历史导致控制进度超原3s期限，独立监控报EXECUTION_PROGRESS_STALLED并安全收尾ERROR；本批不算正常校准通过。正在实现同事务批量读取原样本/资格/原始journal/命令，逐点校验及晚到篡改防护保留，不通过延长期限解决。
- 本节新记录位于outputs/feeding-gap-repair-20261023。分层报告，定向结果不与历史3044项重复累计；完整三段、SYSTEM抖动恢复、AUTO子任务、生成/替换SQL及进程故障组合仍未宣称完成。未连接真实设备、共享数据库或真实通知，未提交、推送或创建PR。
#### 11.11.3 AUTO审计、生成及替换事务复验（2026-10-24，实施中）

- P3-D修复M07-010真实AUTO审计对象冲突：affectedIds仅包含父任务及可选子任务；父任务UPDATE、子任务INSERT，处理单/量账/计算ID只保留relatedIds。审计白名单补入本动作实际使用的actual_grams；原事件同事务保存完整ActionResult，重放核对原身份、摘要及任务集合，不再靠排序猜ID。057定向78/78通过；060实际读故障及063 HTTP/浏览器证明AUTO整数9g提交成功、原ERROR任务转ERROR_HANDLED、新子任务READY、重复请求回原回执且无重复处理/量账。子任务实际启动与执行未验证；不计为AUTO全闭环完成。正式JSON事务及任务页面契约已同步。
- P3-E 059新隔离库生成3/3通过：真实M06政策/审批、SYSTEM任务创建、日额度、并发去重及失败事务回滚。079替换/审批9/9通过：原待审任务和审批来源失效、新任务与额度同事务生成，失败回滚旧任务/审批/屏障。发现并修复M06读取MySQL HEX大写摘要导致等值原候选误拒；75批先红。替换测试的M03已核准来源明确为TEST Port，不能替代M03正式APPLY端到端验证。
- P3-A 070/080仍因完整历史校验耗时触发原3s进度保护，已保留失败证据。调用内解析复用没有解决全部瓶颈；新增规范化JSON共用输出缓冲，保持原排序/数字/转义及摘要字节，078相关100/100通过。后续批量读取及090结果见下文，尚未宣称完整三段成功。
- P3-B 072独立抖动实际触发停止，但未完成SYSTEM恢复，最终ERROR安全收尾；不是恢复通过。已修正TEST策略显式calibration:null，并接入原判断结果的只读诊断，继续定位阻塞。
- 上述均为owned MySQL/TEST设备、原生产写入链；没有更新执行状态来制造成功，没有延长停止或进度期限。整体回归尚未覆盖本节最终修改，定向批次不重复累计。无提交、推送或真实设备操作。
本节继续：独立抖动已查明并修复窗口末点采样时刻误等于触发判断时刻的问题，083先红、084相关48/48通过，保留controlledAt/recordedAt/原因时刻严格一致及原期限。086实际已生成RECOVERY_ELIGIBLE候选，但后续SYSTEM恢复仍被守卫拒绝。运行监控的长窗口仍逐点查询，087用例复现121点触发123次样本查询；改为同事务批量原件读取后089相关104/104通过，每点核验未删除。090完成真实120s校准并产生HIGH调速命令，随后因TEST装配缺少普通调速原事实门禁退出；已补装现有生产门禁，完整三段待重跑。085/086/088的安全ERROR收尾保留为失败证据，不计正常校准或恢复通过。

- 091定位SYSTEM恢复请求把当前纳秒时刻误作基线捕获时刻，与毫秒开始时刻冲突。改为使用已核验原读数的receivedAt；不修改原读数、不造未来开始时刻。092先红、093相关49/49通过。
- 094实际完成抖动候选消费、SYSTEM暂停与续段开泵，但后续调速时迟到旧包阻塞重投影，导致停止覆盖无法闭合。095新增失败用例后，097相关60/60通过：仅原件证明完整包早于当前已执行命令、且存在当时已执行前命令的专用分支，保留未合格原件并继续检查后包；一般未知/缺元数据/存储异常仍不得越过。覆盖仍逐条验证区间原件，旧包不变成样本或排除事实。098完整独立抖动链通过：实际停止观察、原候选重验、SYSTEM暂停、唯一续段、HIGH/LOW、正常终点、最终观察、10.000000g、FEED=2、SETTLE=1、handling=0、整组FREE及交接ACK。该批是命名管道/HTTP TEST设备及独立监控进程验证，不是现场验收。
- 099完成120s真实校准，但修正速度5.6254375超出CMD-I01最多6位小数，设备调用被拒且命令UNKNOWN；保留失败原件并结束该失败TEST进程。100先红，修正为命令准备前检查可表示精度，无核准量化规则则校准失败保护；TEST三段显式加入0.001g/min、DOWN及TEST来源，不作为客户默认。102相关55/55通过，含停止区间未投影原件仍阻断的用例。103统一源码编译通过；101全system单元/契约回归及新的三段完整进程复验待本轮结果。

#### 11.11.4 整体回归与三段后段性能（2026-10-24，实施中）

- 104已完成真实120s校准、高速和低速命令实际执行，但后段发生`EXECUTION_PROGRESS_STALLED`，最终ERROR、9.900000g、计量CONFIRMED；不是正常三段通过。原停止意图明确是控制进度超原3s期限，不能把9.9g误解释成最终允差失败。116正在记录完整JFR定位，未延长保护期限或改变终点/允差。
- 105重新编译当前3517个主源码和857个测试源码通过。101全system单元/契约为9468发现、6跳过、9388通过、74失败；包含25项沙箱回环失败。107允许本机回环后重跑原失败29类，405项中380通过、25失败；不是全量全绿。已按精确类型同步M06方案替换来源依赖、M03事务用途/Mapper方法、M07暂停取消锁读者，以及区分M07策略监控与M09应用事件；未开放通用依赖或删除守卫。剩余全局骨架、其他模块登记及并行成果差异继续逐项记录，不能直接改计数。
- 108在同一个新隔离库运行23类SQL共126项，99通过、27失败：1项为旧准入测试缺少M03_FEEDING_PLAN_APPLY装配，26项为其他测试遗留固定原件ID冲突。仅补测试装配、不删除既有原件；113为上下文测试另建新库，26/26通过。114新库复验准入、生成、替换和培养详情30/30通过，其中详情仅补测试所缺的配置Mapper，不改生产空值/安全逻辑。以上批次重叠，不累计为新增用例。
- 106前端11个文件154/154通过，覆盖AUTO表单、任务、执行人、工作流、策略和培养补料方案。115协议102/102、网关72/72、独立监控128/128、客户适配器23/23通过，共325项。109的Windows长临时路径回环失败、110的PowerShell参数拆分失败及111的旧schema1断言失败均保留；115使用短测试临时目录并把抖动原件断言同步schema2，原窗口/阈值/原因摘要验证保留。
- 当前证据仅适用于明确TEST参数、独占MySQL和测试设备；客户接口及现场投用仍未验收。AUTO子任务实际执行、M03正式APPLY全链仍不能由局部SQL或已有页面结果代替。未提交、推送或创建PR。

- 116单独运行完成120s校准、HIGH、LOW和NORMAL_ENDPOINT停止，完整安全收尾却判ERROR：实际9.900000g低于TEST最终策略99.75%对应9.975g。此批未出现104的控制进度停止，不把两次失败混为同因。118用例先红后仅将THREE_STAGE_NORMAL的显式TEST终点改100%，最终允差、超量阈值与进度/停止期限不变；122完整链复验进行中。JFR记录保留，用于区分原件重验耗时与真实保护触发，不把安全ERROR计为正常通过。
- 复核M06登记时发现M03参数决定接收端只接受六字段冻结政策，真实M06提交生产者输出七字段（包含`entry`及单元素`entries`镜像）。120用实际M06序列化方法构造原件后复现拒绝，并证明缺少镜像反而被旧实现接受；修正为精确七字段、schema1、单元素及完整相等后，121相关27/27通过，含缺失、空、多元素及冲突拒绝。M06接口/字段字典同步既有生产形状；M07 journal同名entry只作精确登记，不视为审批政策读取。该跨模块行为测试仍不替代M03→M06→M07全SQL/HTTP验收。

- 122以100%终点正常停泵，最终实际10.100000g超过独立最终允差上限10.040g，M07正确收尾ERROR（最终量原因NCS009），不是运行5%超量触发，也不是进度超时。TEST低速20%/min与0.1g测试秤及该最终允差组合不能稳定满足正常用例；124先红后仅将显式TEST低速改5%/min，保留终点100%、最终99.75%～100.4%及所有安全期限。不把这些TEST取值作为客户默认。
- 116的JFR显示校准每次重验重复解析相同原始样本；123新增用例证明两次重验解析同一原文4次。复用既有有界解析缓存（只按完整原文，不缓存资格结论），保持逐事务重读、原件归属/质量/摘要/时间和完整覆盖检查；124校准相关50项通过，新正常场景低速断言为预期失败，修改后由125统一编译和后续整体回归复验。没有通过延长3s控制期限处理耗时。

- 125统一编译通过。126全system：9474发现、6跳过、9468执行、9445通过、23失败；测试期间126-source-snapshot的666个工作区变更文件无漂移（该清单包含保留的并行成果，不作为本次提交归属清单）。127最新22类SQL100/100通过，加上独立新库113上下文26/26，覆盖23类126项；此处为不同类集合，不把114的重叠结果再次累计。128三段完成阶段切换后仍因EXECUTION_PROGRESS_STALLED安全停止，实际9.900000g、ERROR；不计正常通过。
- 126剩余失败分层：全局骨架/路由/适配器登记5项；M02设备、观测、DTO及服务目录登记5项；M03旧宽口提供方登记1项；M04/M07表、Mapper、Port、控制器及守卫清单6项；M05占用与队列写入面2项；M09提供方与审计计数2项；骨架锚点同源重算1项。上述22项涉及当前工作区多模块并行成果，必须核对真实契约和生成来源，未直接改数字、删除扫描或放宽边界；不能宣称全局门禁通过。另1项ReactorModelQueryServiceTest仅整组执行失败、单独通过，原因为入组前残留PageHelper线程上下文；补测试前后清理后，133带污染上下文的82项相关回归通过，保留方法内“非法参数拒绝后不得留分页”的断言。

- 128末段每次控制仍重复解析整段历史。129用真实控制入口复现相同采样两次判断被解析4次；控制器新增仅按完整原文索引的有界解析复用，并把同一只读解析结果用于水位及监控窗口判断。每轮仍重新读取预检及事务内原件，质量变化、原文/摘要不一致均拒绝，资格和业务结论不缓存。130统一编译通过；132暴露新测试对两次原件读取计数少算，按预检/锁内两处核对后修正测试；133相关82/82通过。131因编译尚未结束发生ClassNotFound，保留失败记录，不作为业务失败或通过证据。134单独复验三段完整链及JFR性能中；3s控制进度、15s首次停止期限和最终允差未改变。

- 134在LOW阶段再次触发进度保护，且收尾出现重复覆盖事件，未完成正常链。136新增实际覆盖生产者测试先红：MySQL JSON格式重排使原字符串比较误判覆盖变化；改为重新核准全部原件后按严格解码的CoverageEvidence比较，既有原件缺失仍拒绝，不重复插入同一审计键。137编译通过；140覆盖/原反馈/抖动触发/轮询/培养输入提供方100/100通过，141新隔离库原登记、续段、游标、在途排他及重放18/18通过。
- 134的停止前JFR及138实际SQL计划确认轮询登记ACK的OR关联未利用唯一来源键；同一隔离库查询约390ms。以相同登记类型及精确原ACK键关联后，139实际计划为唯一键单行查找，约3ms；LOCAL状态、类型对应、单在途请求限制保留，无表结构或参数变更。142重新运行完整三段进程链中。
- M03ClosureEvidenceContractTest旧零提供方登记与M07接口目录2026-10-15的RUN-B01接线记录冲突；已改为精确唯一CultureInputBarrierPortImpl路径，其他三条旧宽口继续零提供方。140已覆盖该登记及实现行为；不因此扩大为全局21项其他登记均已复审或通过。

- 142未再发生覆盖重复插入，但仍在LOW触发EXECUTION_PROGRESS_STALLED，安全收尾ERROR、9.100000g，不能计正常通过。原件统计为CALIBRATING 385条、HIGH 242条、LOW 144条；相同校准命令在采纳重验时绕过已有事务批次，且实时采样与原校准journal共用解析缓存造成相互驱逐。143/144先复现逐条命令读取及journal重复解析；改为复用本事务命令批次，并将实时采样解析与journal解析分别有界保存，仍以完整原文索引、逐事务重读及重验，不缓存资格/决策、不改变原观察范围。145编译通过，146校准/控制/停止覆盖105/105通过；147完整三段进程链复验中。

- 147实际完成120s校准→HIGH→LOW→NORMAL_ENDPOINT停止→完整收尾；保留旧测试末尾错误事件名导致的非零退出。实际DB已为EXECUTED/CONFIRMED/STOPPED、10.000000g、单段、FEED=1、SETTLE=1、handling=0、正式EXECUTION_CALIBRATION_ADOPTED=1、资源2/2 FREE、MONITOR_RELEASE_ACKNOWLEDGED=1。148使用正式事件名只读复核同一批原件及四个实际阶段，全部符合；没有改数据库状态或重新造执行结果。TEST断言改引用M07CalibrationAdoptionFact.EVENT_TYPE，149单文件编译通过。分层结论：三段实际隔离运行及持久收尾已验证，147原测试进程仍如实记为末尾断言FAIL，148为只读复验PASS；不能改写147日志为全绿。150正复验最新代码的独立抖动恢复链。

- 150完成SYSTEM恢复及续段HIGH/LOW，但最终STOP后的原采样入库被活跃时长回退拒绝，保持STOPPING及资源占用；未计恢复全闭环通过。151诊断另复现独立监控先停止、调度稍后对同窗留证时，错误强制调度controlledAt等于合并后首次时间。152新增用例先红；修正为各自原时间核验、原窗口一致且合并首次时间为可信两者最早时刻，原期限不延后；154相关52/52通过。缺独立原件及无法解释的更早时间继续阻断。
- 155诊断复现续段停止失败：STOP回看按旧包时间选到更早HIGH命令，使原先未合格的旧包重新投影，触发真实活跃时长回退拒绝并回滚原件页。156新增测试先红；修正为只选STOP紧邻的前一物理命令，早于该命令调用的完整包仍保留为PREVIOUS_COMMAND_OBSERVATION_PENDING。活跃时长单调、原件不排除、完整停止覆盖及未知命令保护均保留。158的49项中48通过、1项因错误工作目录找不到Mapper；不是全通过，将从模块目录复验。153/157的不存在测试类选择错误也保留，不作为业务测试结果。159统一编译中，完整抖动恢复及最新整体回归待结果。

- 159统一编译通过；160从正确模块目录复验停止、采样、原抖动窗口、首次意图及SYSTEM协调115/115通过。161已修复停止覆盖并完成安全收尾，但实际9.900000g低于原最终下限9.975g，正确进入ERROR，不计正常通过。162先复现正常场景TEST参数不匹配；163仅显式调整二段TEST终点100%、高速占90%、低速5%/min，最终99.75%～100.4%、运行超量5%、3s进度及15s首次停止期限不变，参数测试2/2通过，不作为客户默认。
- 164以正式类（无诊断覆盖）完成独立抖动完整链，实际10.000000g、两段FEED/单SETTLE、无人工处理、整组FREE和释放ACK，进程退出0。165以同一最终生产代码完成真实120s校准→HIGH→LOW→NORMAL_ENDPOINT→完整停料观察、单次校准采纳、10.000000g、单FEED/SETTLE、整组FREE和释放ACK，进程退出0。147/148及098旧证据不再代替本次最终快照；两批不是新的业务HTTP/浏览器或现场验收。
- 166保存666个既有工作区变更文件摘要（包括保留的并行成果，不作为提交归属清单）。实时验证期间生产及测试源码无漂移；仅开发计划更新当前索引。167全system回归、168/169分库SQL回归进行中，结果未出前不宣称整体通过。
#### 11.11.5 本轮最终复验结论（2026-10-24）

- 以166源码快照对应最终生产/测试代码为依据：159统一编译及163最终TEST参数编译通过；164独立抖动、165三段校准完整隔离进程均退出0。原件、实际量、唯一量账、停止覆盖、整组资源和释放交接均来自正式调用链，无执行状态SQL夹具、默认客户参数或安全门槛放宽。
- 167全system单元/契约：9485发现、6跳过、9479执行、9458通过、21失败、0中止。比126关闭M03旧宽口登记、Reactor分页线程污染两项，没有新增失败。失败清单保存在`outputs/feeding-gap-repair-20261023/167-remaining-failures.txt`；不得表述为全量通过。
- 剩余21项软件验收缺口：全局骨架/适配器/跨模块引用/M08范围/路由登记5项，M02设备来源/目录/观测/配置/DTO门禁5项，M04/M07表/Port/守卫/写面/控制器登记6项，M05占用/队列写入面2项，M09提供方/审计登记2项，骨架锚点同源计数1项。它们涉及当前保留的跨模块成果，尚须依据正式契约逐项复核，不能直接认定全部是测试过时、照实际数字放行或删除扫描；不能归类为客户现场阻塞。
- 6项跳过均来自`M05SampleMutationMySqlTest`的`futurefab.test.m05.mysqlConfig`显式启用条件，本次未提供该专用配置；没有转连dev库。168新隔离库22类100/100、169另一个新隔离库上下文26/26，合计23类126项通过，0跳过/中止/失败；类集合不重叠，不与旧113/127重复累计。任务生成、方案替换、审批/原件、上下文、恢复和收尾事务均在本轮SQL集合复验。
- 166至最终回归结束的生产/测试源码无漂移，仅计划和现场交接材料更新进度，170核验记录留存。前端106的154项和协议/网关/独立监控/适配器115的325项未在本轮重复运行；对应模块后续无修改，仍按原批次证据报告，不混作新通过数。
- AUTO审计/HTTP/浏览器处理、原回执重放和子任务READY按057/060/063证据登记；AUTO子任务实际执行仍未验证。生成/替换SQL不替代M03正式APPLY全链HTTP/浏览器，164/165也不替代新页面、客户接口或现场验收。当前仍未完成全部四阶段，§11.11表中的其余软件和验证缺口继续保留。
- 同步泵速恢复契约、业务观测交接契约和逐设备交接材料；未改目标DDL、未增加数据库结构、未写入真实设备/共享库/真实通知。HEAD仍为`5678c46d01b837745340632b79142f9b8ff774db`，索引为空，无提交、推送或PR。

#### 11.11.6 回归登记、独立保护告警及完整业务链接续（2026-10-24，实施中）

- 原167批21项失败按正式契约复核：M02/M05精确来源/DTO/读写边界登记及新增防回归测试120项定向通过；全局门禁、anchors同源生成和M05/M07骨架25项定向通过。发现M07-036真实编号冲突，保留正式时间线036，检测来源恢复登记037；没有以扩大白名单或机械更新总数替代核对。统一177编译及全部回归尚未完成前不宣称21项整体关闭。
- M03补料方案读取泵候选时跨读M02/M07私有Mapper已改为owner窄Port，保留占用/未知拒绝并覆盖泵所有已登记通道；具体契约和行为测试同批同步，无DDL。M03正式APPLY同事务替换及AUTO子任务真实执行验证继续推进，不由局部生成/READY结果代替。
- 独立保护停止虽已归并原原因，旧告警扫描未接这条来源。171/172先红，新增M07_INDEPENDENT_PROTECTION_ALARM的严格原件生产及原outbox/M09交接，174相关76项通过；176在全新本机独占库运行8项真实SQL/M09持久收件/重放通过。原件保留全部原因，STOP_REQUEST/配对STOP_RECEIPT使用原请求身份去重；初次抖动/正常终点不造异常告警。缺实验室＋事件核准映射仍WAITING_MAPPING，接收人处理是TEST边界，未发送真实通知。
- 175首次SQL启动被本机回环网络沙箱拒绝（10013），未连接成功；授权隔离实例范围内重试的176才是有效SQL结果。173曾因新增测试行未设置publishAttempts导致1项测试失败，修正测试元数据后174通过，原失败日志保留。
- 当前P1核对撤销“七项均缺生产者”的旧笼统表述，已有实际再运行、屏障拒绝、当前保护锁及恢复基线拒绝链分别登记；仍缺的三项来源及其他故障组合保持软件/输入缺口，不将其标为现场已验证。未提交、推送或创建PR。

- 177统一编译通过；181全system回归9500发现、6跳过、9494执行、9489通过、5失败。原21项已在本批不再失败，新增5项为M03 owner窄Port引入后的M07守卫引用/Mapper/输入来源登记4项，以及新告警SQL旧断言1项；核对只读职责后精确登记，188相关43/43通过。未宣称最新工作区整体全绿，后续新增原件与历史告警仍须联合编译/回归。187因遗漏测试javaagent导致附加失败已终止，未计通过。
- M03正式APPLY生产链新增FINISHED及未知培养状态拒绝，保留正式五种可配置状态；184新隔离库5/5验证真实M03/M07/M06同事务替换、重复回执及失败回滚。尚不替代正式workflow HTTP/浏览器。
- 新独立告警交接查出缺核准映射时延期SQL漏登记新事件，191真实SQL先红（8/9），修复后192新库9/9；原payload不变、缺映射无outbox且按CAS延期。新DEVICE_STOP_CAPABILITY_UNVERIFIED原件的M09严格schema及篡改拒绝190批52/52通过，数据库交接继续验证。
- AUTO已从父ERROR安全收尾经正式HTTP生成子任务并实际启动；尚未完整成功。隔离组装先后正确阻断父批准误用、decimal string格式与已变更物料版本；已改TEST批准冻结当前真实原件，不改生产安全门槛。还发现StartAuthority对同值BigDecimal使用equals导致合法JSON重放误拒，以及新任务采样队头未衔接前owner释放身份，分别按精确数值与原释放双ACK/新START前时间边界修复。未用SQL改执行状态，尚未计AUTO全闭环通过。

- AUTO v6已完成真实全闭环及HTTP查询：父READ_FAILURE安全收尾→M07-010创建9g子任务/幂等重放→子任务自身明确TEST批准（旧父批准拒绝）→claim/START/实际反馈/原终点/停止覆盖/FEED=1、SETTLE=1/整组释放及双端ACK。实际9.000000g、EXECUTED/STOPPED/CONFIRMED；子任务1311396370197700609。197浏览器验证真实任务列表与详情一致、allowedActions为空、锁状态UNKNOWN保留、控制台error=0。该层级不代表生产自动生成批准或客户现场验收；后续DB异常传播修复另做定向和整体回归。
- DEVICE_STOP_CAPABILITY_UNVERIFIED原件至M09的194新隔离SQL11/11通过（193两个测试复用同一固定原件键被唯一约束正确拒绝，仅改为独立测试身份）。195审查新增失败用例发现gatewayInstanceId交接约束比现有批准profile严格，按原512字符/非空/无NUL、原值保留口径修复，196映射/codec/接线76/76通过；没有改变已批准身份或截短字符串。
- M03完整审批核对发现M06成员资格/owner预检仍为恒拒绝占位，现行详细设计已规定成员、角色、阶段权限及BATCH→PROJECT条件，因此作为可开发软件缺口继续实现，不能标为等待现场。正式候选保存HTTP/页面映射另按现行Q33边界核对，不创建测试专用APPLY接口冒充正式入口。


### 11.11.7 2026-10-24新增确认与接线进度（开发中）

- 用户确认：实际开泵前能力核验被拒绝，只有原命令、网关日志及登记交接共同证明从未启动，才可撤回原登记并释放本次资源，任务回到READY、设备准入不通过。保留失败尝试及原因，不记已执行异常。未知结果继续保护。数据库`admitted`仍表示业务候选审批已生效，不能置0冒充业务审批失效；设备准入拒绝与它分开处理。
- 软件实现必须先完成gateway/monitor原登记撤回及防迟到登记持久证据，再经H06原NOT_SENT收尾、最终外部双ACK。不得伪填stoppedAt/FEED/SETTLE或STOP_CONFIRMED；没有这些撤回证据的旧PREPARED命令仍未决。
- 用户确认：仅开放培养补液方案初始化/替换入口。新增受控POST候选路由，INIT使用SC019，MODIFY新增SC048。两种政策独立核准；其他原排除配置页保持原范围。审批场景种子47→48，不新增业务表或默认政策。
- 新入口SDK定向及既有补液编辑回归212：49/49通过。209后端红测确认原来不存在候选HTTP入口；213联合编译进行中。入口、签批、免审批同事务生效、AUTO SC009最终审批、真实SQL/HTTP/浏览器均继续分项验证，不计为已完成。
- 实际发现的待修软件缺口：AUTO子任务REPAIR_PENDING_REVIEW与普通CREATE生效SQL不兼容；P01免审批分支原先只挂候选且无同事务生效。这两项继续实现，不能归为等待现场，也不能用TEST单独批准或局部P02测试代替。


### 11.11.8 2026-10-24 M06 当前签审与 AUTO 审批链（分层证据）

- 已接 M03 当前 MEMBER/业务日枚举，M01 启用账号与阶段功能码、M02 OPERATE 交集；M06 使用原冻结政策的 BATCH/PROJECT 与责任分离。M03/M07 owner 预检分别实现，读 allowedActions 与写 owner-first 原事务复验共用实际判据。缺依赖仍失败关闭，无合格人不自动批准。成员查询故障不能当作空集合降级。
- 209 定向回归 67/67（成员/读写消费及原 M06 合约）；208 独占 SQL 3/3（真实成员、到期、撤销、祖先冲突）。不将其称为完整 HTTP 签批。
- SC009 实际链发现并修复：AUTO factory 的原 executable JSON 不能充作 M06 ChangeSnapshot；delivery INSERT 缺 NOT NULL updated_at；普通 CREATE SQL 未覆盖 REPAIR_PENDING_REVIEW。新增正式审阅视图，保留可执行原件摘要；delivery 两时间同取实际决定时刻；独立精确 SC009/ERROR_SUPPLEMENT 原件校验及 repair CAS，不扩大普通 CREATE 状态。
- 217 新隔离库 3/3：真实 factory→M06 政策/提交→成员/owner 原件核验→签批回调→投递→M07 批准/拒绝及原件事件失败回滚。218 原件/factory 14/14，包含场景/来源/父任务/原请求/摘要/taskSpec 篡改拒绝及后续 taskSpec 改变后的原回执重放。214/216 为保留的真实红测证据。
- 随后已将 SC009 SQL 测试源码提升为正式 executeApprovalAction 和真实管理守卫/审计/回执，正在复验，不能把 217 回调级结果用于新代码快照。正式 HTTP 元数据、浏览器审批及 M03 INIT/MODIFY 全链由后续集成验证。以上未连接真实设备、未发送通知、未提交或推送。

- 220 正式 `executeApprovalAction`＋真实 SYSTEM 管理守卫/管理回执/审计 SQL 已复验 3/3，原键重放不重复创建 delivery。当前进一步提升为 M06 正式 Controller＋请求元数据过滤器/WriteMeta/resolver 的 MockMvc HTTP＋SQL 验证，尚未报告通过；该层级仍与真实浏览器、网络部署及现场分开。

- 226 已完成该层级提升：SC009 正式 M06 Controller＋请求元数据/WriteMeta＋真实管理守卫、审计和 SQL 3/3；缺请求头拒绝，原请求重放不重复投递。224 红测识别“已批准 ERROR_SUPPLEMENT 子任务后续取消错误套用 SC009 CREATE”及 owner 读取故障异常分类缺失，修复后225为11/11，227相关回归118/118。CREATE原件身份、父任务、摘要和精确 REPAIR_PENDING_REVIEW CAS 继续保留，后续修改/取消使用自身正式场景。
- 232 新独占库合并复验5/5（SC048两项＋SC009三项，不与226重复累加）：SC048由正式培养候选 application service、SYSTEM guard及真实审计建立P01候选，真实M06政策/提交、MEMBER枚举、M03 owner预检和正式Controller MockMvc签审形成决定，再由实际delivery、M03 P02及M07替换链生效。批准后代次3、旧未开始任务取消、原回执affectedTaskIds=1、旧snapshot身份一致、屏障OPEN，重复投递不重放副作用；拒绝保留旧有效方案及原任务。未以SQL设置APPROVED或运行结果。
- 230为测试漏装ResCultureChangeCandidateMapper导致2项失败，231补装后2/2；232进一步验证原替换回执和屏障，并复验共享签审helper。M04模板/流程读取、M01会话与功能权、M02操作范围、明确TEST批准政策及生成绑定仍为输入边界。新候选提交本批为application＋SQL，审批为MockMvc HTTP＋SQL；不代替TCP/浏览器部署与现场验收。SC048的实际候选HTTP/浏览器由并行集成批单独登记。

### 11.11.9 2026-10-24 真实业务数据库进程故障隔离验证

- 新建并核验独占 `127.0.0.1:33088`、全新 datadir、启动时间、mysqld 父子进程及 `@@port/@@datadir`，未停止或改动原33087实例。测试helper默认仍33087，仅显式33088且符合固定outputs路径、TEST用途标记时允许第二实例；错误端口、共享/越界路径及缺用途标记负向测试2/2。
- `M07OwnedDatabaseFailureMain` 复用原 NORMAL fixture、正式 claim/START/实际反馈、M02网关、进程外独立监控、证据收取、停止归并、量账与释放组件。实际运行后杀掉该新实例真实mysqld进程，业务Mapper发生连接拒绝；独立进程仍持续读TEST设备、以 `EXECUTION_PROGRESS_STALLED` 请求保护停止并落盘原件。没有用Mock异常代替本次数据库故障，没有用SQL修改执行结果。
- 成功批 `outputs/mysql-process-fault-1792832255178` 进程退出0。数据库恢复前留存122条原始journal事实；同datadir重启恢复后，正式M07将这122条各收取一次，归并首次停止 `2026-10-24T08:58:32.183936300Z` 与原期限 `2026-10-24T08:58:47.183936300Z`，均未重置。原实际任务最终 `ERROR/CONFIRMED/STOPPED`、实际0.500000g、FEED=1、SETTLE=1、execution=1、资源2/2 FREE、释放双端ACK=1、独立保护告警原件=1。错误业务结果保留，未因已安全释放而改为正常完成。
- 证据：该目录 `execution/execution-events.ndjson`、`execution/offline-evidence.json`、`execution/final-result.json`、`final-readonly-sql.txt`及启动/崩溃恢复日志。TEST参数/设备模拟不作为客户默认或实际现场能力；本次只证明明确场景下真实DB进程中断、独立读停及恢复后的生产链归并，不替代其他部署拓扑与设备验收。
- 前两批失败证据保留：`mysql-process-fault-1792831978063` 为脚本未识别Windows mysqld父子进程，未进入补料；`mysql-process-fault-1792832082612` 已真实断库并保护停止，但TEST误断言MONITOR_UNAVAILABLE，实际正式原因是控制进度失联；恢复脚本还把TIME_WAIT误判为监听占用。仅修正TEST判据及精确监听检查，无生产门槛放宽。最终新增33088实例已按核验身份正常关闭，文件保留。


### 11.11.10 2026-10-24 仅M07调度JVM退出及原执行恢复验证

- `M07SchedulerProcessFailureMain` 是独立TEST进程编排：M02网关和TEST物理设备在父JVM，实际 `FeedingMonitorMain` 在单独JVM，M07正式claim、唯一START、实际首反馈及后续消费组件在另一个可终止JVM。实际START已执行且泵速大于0后，仅强杀M07子进程；未终止网关、监控或数据库。各进程PID和实际故障时刻保存在 `execution-events.ndjson`。
- 恢复装配只读取原部署输入文件、固定SHA-256、原profile和数据库：`loadExisting/assembleExisting` 不插入初始任务、不修改原批准时间、不重建登记、不再次claim或派发START。原source/profile与原DB执行共同供既有生产消费者验证；量账和资源事实仍由正式M07事务产生。
- 成功批 `outputs/mysql-process-fault-1792833020885/scheduler-execution` 总进程退出0。M07 PID 69496在 `2026-10-24T09:15:31.269568800Z` 被强杀，父网关/设备PID49612、监控PID47016仍存活；独立监控实际读停后以 `EXECUTION_PROGRESS_STALLED` 留存24条离线原件。原首次停止 `2026-10-24T09:15:33.213288600Z`、确认期限 `2026-10-24T09:15:48.213288600Z` 均未改变。
- 新M07进程从原数据库继续收取、核验、归并和收尾：24条离线原件各接收一次；原任务 `179283331987710`、执行 `179283331987780` 最终ERROR/CONFIRMED/STOPPED，实际0.100000g、execution=1、START=1、FEED=1、SETTLE=1、两资源FREE且owner为空、释放交接及ACK各1、独立保护告警原件1。TEST设备实际回执只有原START产生一次RUNNING；恢复期间正式STOP允许执行，不把合法停止误判为重复启动。
- 证据包括 `final-result.json`、`TEST-physical-writes.json`、`offline-evidence.json`、原profile/source及元数据摘要、`m07-start.log`、`m07-recover.log`、网关/监控journal与目录上层 `scheduler-final-readonly-sql.txt`。独占33088及其新datadir已核验并正常关闭，33087未受影响。未以状态夹具补齐故障结果；TEST输入不能作为客户参数或现场验收。
- 三次前置失败保留在同目录的 `scheduler-execution-before-kill-failed`、`scheduler-execution-overbroad-test-failed`、`scheduler-execution-journal-read-failed`：分别为测试在首启后等待一个完整tick才触发故障导致保护先发生、把合法STOP计入禁止第二次写入、Windows活跃journal独占锁禁止测试直接读取。后两次实际业务链已安全闭合，但不记为测试通过；最终仅修TEST故障触发和证据断言，不放宽安全条件。
- 本次运行使用235生产编译产物与私有TEST overlay。完成后另将原Main的 `runUntilClosed` 单样本直调改为正式 `M07ExecutionControlTask.evaluatePendingSamples`：启动前采集样本继续被原生产规则拒绝，正式扫描器保留未决并等待下一真实合格点，不将拒绝当测试进程崩溃。该两行TEST驱动变化不影响上述故障类执行路径，统一编译和RULE最终复验由后续批次登记。迟到HTTP、停止失败恢复的全业务组合仍单列待验证。


### 11.11.11 2026-10-24 首启原始包封装边界与投影队头修复

- 纯246b完整RULE复跑保留真实失败：原START调用09:31:17.162Z、实际执行17.211Z；第一包全部原始采集/收到时刻17.161Z且实际泵速/有效计数为0，但Observation封装时刻17.165525700Z已过调用。旧BEFORE_SEGMENT_INVOKED严格外壳判据未命中，资格提供者又将首启前读数作为当前运行样本拒绝，投影队头因此反复阻塞后续17.429Z等真实运行原包。独立监控在09:31:19.528216600Z以EXECUTION_PROGRESS_STALLED保护停止。失败运行自然达到TEST260秒界限后退出1，未改DB结果、未记为安全收尾通过。
- 这是生产投影分类缺口；此前TEST Main单样本直调退出已由正式scanner驱动修复，但scanner并不能自行解开此队头问题。原件证据为 outputs/feeding-gap-repair-20261023/rule-246b-final-process.log、rule-246b-first-originals.json 及该批原始journal。
- 增加严格FIRST_START_PRECALL_OBSERVATION_PENDING分类：唯一原首段START、原登记及双ACK、EXECUTED结果摘要、全部原始时刻加核准误差早于调用、完整核准指标/单位/身份/质量且实际静止均验证后，只允许继续检查后包。旧包未投影、未排除、不计量、不计覆盖；现有排除规则不改，未知命令/缺ACK/错原命令/跨边界/坏质量/迟到receivedAt继续阻断。停止覆盖仍逐原件核验。
- start-boundary-red.log证明正例在修复前失败、负例通过；start-boundary-green-module.log为修复后4类定向63/63，无跳过。首次green在仓库根目录运行的1项XML相对路径失败已用正确system工作目录复验，不改断言。当前为私有javac覆盖层结果，统一编译、受影响SQL、整体回归及完整RULE进程尚待后续批次，不把旧246b结果当本修复已验。

### 11.12 2026-10-24 代码优先接续：剩余项重新分类

#### 11.12.0 运维发布与释放取证接续核对（2026-10-24）

用户要求集中列明确认事项，继续协议无关代码，全面回归后置。三项当前阻塞及建议统一登记在[逐设备启用与现场交接§5.1](../../开发基线/开发包/补料调度-逐设备启用与现场交接.md)：PUB-01正式发布身份／权限及生产调用者、PUB-02持久安装提供方、REL-01客户适配网关访问M07原释放记录的权威通道。这些仍是待接通的软件／部署边界，不等于已经完成的代码只缺现场测试；也不是要求客户设备额外开放释放接口。已有受控发布授权继续有效，不重复询问是否允许发布。

不依赖这三项确认的修复：`restorePublished`改为在不可见暂存目录核完整原授权历史、连续版本、摘要及唯一UUID，全部通过后比较原快照并一次安装。坏后批不暴露前批内容；并发发布改变目录时拒绝覆盖；同UUID不能授权另一版本。未增加默认Authority、业务权限、HTTP发布入口或设备能力，不改变停止／恢复／量账／释放门禁。新增三项反例先在旧共享产物失败（9项中6通过、3失败），新代码私有javac编译及目录／发布定向15/15通过，0跳过，证据`260-publication-history-red.log`、`260-publication-history-green.log`及`260-publication-source-snapshot.json`。配置／五消费者的受影响复验单列记录，不复用此前72项宣称本修复已经全面验证。

同一私有编译覆盖层的配置／五消费者六类受影响测试32/32通过、0跳过，日志`260-publication-consumers.log`；与目录／发布15项不重复。其余生产类沿用256共享编译产物，本次未重新运行Maven全模块编译，不能把私有javac覆盖层结果写成新全模块编译结果。

本次尚未执行全面回归、安装服务进程持久化／断电验证、客户释放取证HTTP及浏览器／现场验收。确认实际协议后继续实现具体适配及生产装配；不得由测试Authority或单纯Proof字段检查代替它们。保留工作区，暂不提交、推送或创建PR。

用户明确后续优先补齐生产代码；全面回归、完整浏览器及部署验收后置。本节接续原计划，不新建计划。251联合编译、252全system9629/9629（另6项旧库跳过）及已启动的253分组SQL33类165/165已收尾；它们是当时快照证据，不覆盖本节后续新代码。未启动新一轮全面回归或长期RULE验收。

| 分类 | 已核实的事实及接续工作 |
| --- | --- |
| 尚未接通：动态任务执行准备 | AMOUNT/PERCENT/RULE/AUTO消费者有生产装配，M03/M04/M05 Port有真实调用者；唯一准备目录仍启动读取具体taskId/version/hash，生成/AUTO分配新ID后没有批准发布者。Provider及四类后续Authority各复制旧目录，只换Provider不足。用户已允许受控部署发布；本轮已接统一不可变目录、五消费者及M07PreparationPublicationService/启动原件恢复。项目无现成运维授权和持久安装提供方，Authority默认缺失，真实发布保持阻断；不能借SysConfig权限或把M06业务审批当作设备、物料、独立监控批准。 |
| 可直接补齐：客户原始读取 | 客户文档已说明秤读取接口；已补独立显式配置的原始只读入口、真实有界HTTP和原件归档，保持RAW_UNQUALIFIED，不连接生产采样/量账。PILOT pump7/8已分离读写配置并接通只读，7/8写能力继续阻断；257当前产物定向HTTP/配置子进程33/33通过。 |
| 已完成小包：候选回执 | 正式候选组件接严格回执判定：历史回执不冒充待审，不完整PENDING保留原UUID及输入重试；初始化提示指向已开放入口。254先红2项、修复后相关51/51通过，类型检查单列；不改变SC019/SC048政策。 |
| 已实现、仅补必要定向验证 | 首启前raw/调用后封包的窄分支已有生产实现及63项定向结果；已补正式qualification→唯一SamplePort的真实SQL两项，覆盖保留原包/后包唯一投影、重放与事务失败回滚；first-start-packet-sql-v2两项通过，258新联合产物相关9项SQL再次通过。此前使用资格替身的结果不冒充此链。 |
| 已接通、全面验证后置 | 正常启调、停止、暂停/继续、SYSTEM恢复、暂停后取消、FEED/SETTLE与H06/双ACK均有Spring扫描或正式HTTP入口；安全原因中已具判据的生产者和M09告警交接已接通。最终RULE正常长链、组合故障、新页面与部署验收仍单列待验，不重复整套未受影响测试。 |
| 业务/协议阻塞 | 健康与停后余流判据、抖动候选反弹时机、跨段校准/换袋及多袋量分摊、供料比较和逐设备实际启停/查单/时间质量/在途处置仍未确认。客户adapter的权威release取证/安装源另核契约；缺正式来源不得仅验证Proof形状就开放释放。 |

并行文件归属：客户adapter及其契约由原global工作包维护；首启定向SQL由原m07工作包维护；候选前端与主计划由root维护。保持所有其他会话修改，暂不提交、推送或创建PR，不连接真实设备、共享/生产库或真实通知。

#### 11.12.1 本轮代码与必要验证结果

- 统一准备目录：`M07ApprovedPreparationCatalog`按(taskId,taskVersion)保留原filePin和独立Approval，准备Provider、首次开始事实、最终START、实际首反馈及恢复供料五个消费者均由生产配置注入同一实例；冻结spec消费者继续用原版本，不跟随任务的新版本。目录只追加；冲突/版本错误/持久回调失败不部分生效，并发只一批提交，提交前读者看旧快照。
- 受控发布：`M07PreparationPublicationService`实际Bean先恢复原授权历史；发布先核运维授权，再严格加载原文件，在目录提交前持久原发布并校回执，之后才切换。原请求可重放，坏文件、未知原件及重入拒绝。没有安装Authority的生产行为是明确阻断，TEST实现不作为真实发布方。当前仍需实际运维授权/持久安装适配；这不自动产生M06以外的安全批准。
- 客户适配：三类秤入口为`CustomerScaleProbeMain`，已接配置→有界GET→原始归档→候选解析；PILOT7/8只读经原probe可达。原始数据仍无采样资格/认可量/停止证明；客户release缺独立安装端权威取证协议，继续拒绝。
- 候选前端：正式组件接`feedingCandidateReceiptMessage`，历史原回执正确展示；缺PENDING审批ID、未知/冲突回执保留原请求及输入。254先红后相关51/51、定向vue-tsc退出0；不改INIT/替换独立政策。
- 256联合test-compile成功（19模块，1分50秒）。257新共享产物：准备目录/五消费者/发布/扫描/精确锁序及恢复契约72/72，客户只读HTTP和配置子进程33/33。258全新独占SQL库9/9，覆盖AMOUNT/PERCENT/RULE准备及首启真实资格→采样/重放/回滚。源与编译层分开记录，不累计此前49/36/6等重叠定向数量。
- 本节后续代码未跑全面回归、完整RULE正常长链、新浏览器及部署验收；不把252整体结果或253的165项当作这些新增代码全部已验。下一轮依次检查完整代码快照的单元/契约和SQL、受控发布真实安装方与新生成/AUTO接续、正常/异常/暂停恢复/取消/释放组合HTTP和浏览器、隔离部署/切换回退；客户接口和现场验收仍须参数、能力与明确操作授权。

#### 首启原包窄修的必要定向SQL补验（全面回归后置）

- 新增 `M07FirstStartPacketProjectionPersistenceIT` 两项短程测试，复用真实approved claim、原登记/双ACK、M02签名HTTP实际START及TEST物理设备反馈。采集调用前真实静止读数后，TEST控制外壳封装时机复现原边界；没有改原采样时间或以SQL插入EXECUTED/执行结果。
- 真正 `M07ApprovedMonitorSampleQualificationProvider`＋原登记Resolver＋`ExecutionSamplePortImpl`＋真实Mapper事务完成资格和唯一采样持久化。旧包全文/摘要保留，无排除/采样回执；后包原时间、原值、原命令绑定唯一写入。空页、重新装配消费者及整页重放均不重复写样本，未生成覆盖、量账或释放事实。
- 反例为仅该TEST execution的 `run_execution_sample` INSERT trigger抛错，明确断言错误链命中指定故障；原收件/采样/投影回执一起回滚，移除TEST故障后原页重试恰好一次。未用mock异常冒充此SQL故障。
- 最终证据 `outputs/feeding-gap-repair-20261023/first-start-packet-sql-v2.log`：2/2、0跳过、0失败，8388ms，独占库 `feeding_validation_1792836336177`，纯251生产产物＋该新TEST类私有编译。v1为同两项初轮，不重复累加；v2增加精确故障来源断言。未修改业务代码；未跑完整正常补料或新增全量回归。最新用户要求已将全面回归集中后置，RULE最终验收仍待执行。

### 11.13 2026-10-25 受控发布、持久安装与独立释放取证（生产接线及定向验证）

用户已确认三项按建议实施，实际身份及部署参数仍待配置；继续必要定向验证，全面回归、浏览器／现场验收后置。§11.12的“无具体Authority／安装方／取证协议”旧状态由本节替代；不据此改变其他业务待确认项或设备投用状态。

| 工作包 | 实际生产调用链 | 配置与安全边界 |
| --- | --- | --- |
| PUB-01 专用运维发布 | 部署打包工具`M07PreparationPublicationPackageMain`→带原UUID／身份／时刻的签名收件包→`M07PreparationPublicationTask`→原`M07PreparationPublicationService`→五消费者共享目录 | 专用`M07_EXECUTION_PREPARATION_PUBLISH`部署grant，显式身份、密钥、有效期和active；先鉴权再读原件，不借业务账号／M06／SysConfig，不生成独立安全批准。无配置不启用。 |
| PUB-02 持久安装 | `M07PreparationInstallation`实现Authority→原件路径与pin复核／同步→独占`publication.log`强制落盘→原回执→目录原子切换；重启核原权限范围、密钥指纹、签名、版本、回执及全部保留文件 | 分离安装／收件目录、cron、时差及grant均必填。保留内容摘要路径原文件，坏尾／未知耐久性拒绝新发布，不自动删原件或重置历史。active=false可保留原历史核验，不允许新发布。 |
| REL-01 独立释放取证 | `CustomerOpcInstallation.requireRelease`→显式专用客户端→签名`/feeding-safety/v1/release-evidence`→M07独立只读事务重读原H06／handoff及关联LOCAL原行→既有正常STOP或NOT_SENT codec→绑定原登记／完整请求／H06来源的签名回执→原网关释放 | 实际服务身份、adapter作用域、权威实例、监听／客户端点、密钥、超时和时差显式配置；取证不改状态、不产生量账或第二套释放资格。无配置、缺原件、冲突、错误身份或服务未知保持拒绝。 |

配套改动仅新增M07 owner纯SELECT及部署操作原件日志，无业务表结构变更；system新增customer-adapter的test-scope依赖供正式组合IT，未引入生产客户驱动依赖。正常START／调速、权威query、实际反馈资格仍受各自客户协议和逐设备核准约束，不能因取证链完成而放行。

最终定向证据：265联合19模块test-compile通过，2分22秒，涵盖Clock显式限定及两个拆分正式IT；262为前序编译、262b为customer最后测试源码增量编译，不重复计算构建范围。263联合产物system发布／目录／五消费者／取证两类66/66，customer与共享协议六类57/57；266最终共享产物新增配置context3/3（默认关闭、缺参数拒绝、多Clock正确装配）。system共69项，customer／API57项，两集合及新增3项不重叠，均0跳过；不累加旧私有层9／10／15／32／57及私有context3等重复结果。265之后这66项对应源码未变，仅新增context和IT；未以旧252全面回归替代本轮验证。精确源码摘要见`266-production-wiring-source-snapshot.json`。

269又以265共享产物复验取证Service／真实TCP两类10/10（4852ms），替代263的同10项，不额外累加。该工作包证据详见`269-release-evidence-verification.md`；本轮三项整体范围及边界见`269-production-wiring-verification.md`。

必要真实SQL＋HTTP已完成：267 `M07ReleaseEvidencePersistenceIT`正常闭环1/1、退出0、221648ms，从实际START按原TEST 10g／3g/min执行，停止和完整观察、唯一FEED=1／SETTLE=1、H06后，客户`CustomerOpcInstallation`实际签名取证一次，才完成网关／监控释放双ACK；最终EXECUTED、10.000000g、整组FREE。268 `M07NotSentReleaseEvidencePersistenceIT`另独占schema 1/1、退出0、10005ms，真实能力拒绝、原撤回双ACK、H06注入SQL故障回滚及原件重试后，同一客户安装取证一次再外部释放；原execution保持NOT_STARTED、没有物理正常写／FEED／SETTLE。没有用SQL设置执行结果或用状态夹具替代取证链，TEST参数不是默认配置。

已保留实际失败：安装方初轮Windows锁内另开句柄读日志失败，改为原锁定channel读取；AppContainer临时目录改名拒绝仅通过使用工作区TEST临时目录复验，不降级为复制或绕过校验；客户初轮因误写测试类名导致discovery失败，改正确类名后才有57项有效结果。264 SQL第一次在33087连接10061即退出，尚未建库／执行用例，不计SQL失败或通过。原33087含241个历史隔离库，正常恢复至10:19:33Z才ready；保留数据未清库。267／268采用项目原有已获准的独占33088流程，新目录`outputs/mysql-process-fault-1792923458402/data`，核端口／进程／datadir及TEST用途，每类独立新schema并核hash安装同一01／02／03基线。两测试完成后已再次核身份并正常关闭33088，原33087保留。未放宽已有目标守卫或转连dev／共享库。

后续全面SQL清单已显式34→36类，两新取证IT各独立schema；33087 runner同步已声明的customer test依赖classpath。仅检查脚本语法及清单，不启动全面回归。独立只读复审核对专用授权、持久原件、未知保护、H06及NOT_SENT证据和生产装配，未发现需立即修复项；静态复审不代替测试或部署验收。

仍未开展最新全面回归、完整RULE长链复验、全浏览器、断电／目标部署、切换回退或客户现场验收。业务待确认继续包括健康／停后余流判据、抖动候选反弹、跨段校准／换袋分摊、供料比较、客户启停／查单／时间质量及在途处置；不补默认值或伪造能力。暂不提交、推送或创建PR。

### 11.14 2026-10-25 四阶段剩余生产代码与输入重新核对（只读审计）

依据原P1—P4任务、§11.11—11.13最新实现及正式契约，复核生产配置、真实调用者和客户适配。HEAD仍为5678c46d01b837745340632b79142f9b8ff774db，工作区745个变更路径、索引为空；保留全部已有修改。本轮仅核对并更新本节，不编码、不执行新测试或全面回归，不连接数据库、设备或通知，不提交／推送。以下是当前剩余项索引，不能再从原始GAP表或旧批次说明重复认定缺口。 本节保留当时审计快照；其中生成批准运行时更新及免审批预核准入口现已按§11.15实施，不再作为当前未开发项。

#### 11.14.1 待开发的代码／接线，与依赖分开

| 项目／阶段 | 已核实尚未实现的部分 | 依赖与当前边界 |
| --- | --- | --- |
| 生成批准的运行时受控更新／P3 | `M07TaskGenerationConfiguration`只启动加载生成批准，`M07TaskGenerationSourceAdapter`以List.copyOf冻结，再按culture/lab/snapshotId/parameterGeneration/packageHash精确匹配。新初始化／替换产生新snapshot后，若未部署对应生成批准则DAY_ORIGIN_POLICY_UNAVAILABLE。本轮PUB更新的是逐task执行准备，没有更新此目录。 | 属于可继续开发的免重部署能力：先同步受控更新契约，再接不可变生成批准目录及真实发布者，保留独立D0／残糖／算法核准，不由M06自动批准。现行《任务状态调度与异常恢复》明确允许启动装载，因此是当前能力边界，不是现代码违反契约；按原方式受控重部署仍可接续。不能把它称为普通任务准备发布已覆盖。 |
| 客户正常控制／P4 | `CustomerOpcInstallation.requireNormal`仍明确拒绝，`CustomerOpcDriver.write`只支持受控STOP，正常START／SET_SPEED未接到真实客户服务。 | 依赖首次开始到期拒绝、旧写屏障、在途处置、实际回执及泵换算协议；确认后仍须编写适配与生产接线，不是只差现场测试。 |
| 客户权威查单／P4 | `CustomerOpcDriver.query`返回null，未实现按原命令身份取得权威结果。 | 需原request／command／fence查询及UNKNOWN／NOT_FOUND／执行时刻语义；不把查不到作为从未执行。 |
| 客户实际反馈及秤资格生产／P2、P4 | `CustomerOpcDriver.read`仍给Ownership.UNKNOWN及空readings，STOP受理也不产生实际停料事实。三类`CustomerScaleProbe`仅原始读取归档，controlQualified恒false，未接合格原件至M02观测入口／独立监控。 | 依赖客户源设备、指标、原时间、质量、boot／序号、实际泵速／有效运行计数及称重口径。已有M02投影读取和M07 qualification→SamplePort不等于客户采集已实现。 |
| 特定健康／余流原因生产／P1、P3、P4 | SERVICE_HEALTH_FAILED及POST_STOP_FLOW_ABNORMAL有原因承载，但没有可按正式核准判据触发的专用生产者及该来源后续交接链。 | 先核准判据／输入；不能将通用UNKNOWN、HTTP成功或旧示例换名成已证实的特定故障。既有其他保护与告警链保持。 |
| 换袋恢复、跨段校准及多段人工分配／P3 | replacement身份结构和通用恢复守卫已存在；已安装的`M07ApprovedResumeSupplyAuthority`只批准原袋。新袋批准／新基准与策略接续、多段首次更正／手补物料分配的完整允许路径仍未完成。 | 依赖下节明确业务政策。单段人工处理及同袋恢复已有实现，不能重复列为全部未开发；不把量分给第一袋、不自动复用旧校准。 |

本次未在已接通的P1—P3主链中发现新的独立NOOP／Skeleton／恒拒绝占位；该表不能据此变成全部代码已完成的声明。采样多流v3及PLC外部量账见下文条件边界，不按当前单原包v2／SMP首批范围列为必修缺陷。

#### 11.14.2 已有实现，仅待进一步验证

- P1：最新快照整体回归，以及首启日界、未知／迟到命令、首次停止期限、完整观察和释放的组合；恢复拒绝留证到页面、重启和M09的组合证据仍需逐场景补齐。已有具体原因和安全主链不重复记作待开发。
- P2：正常、超量、暂停恢复、迟到HTTP、停止异常、真实DB／M07进程退出已有分层证据；最新完整快照及组合故障／容量仍待复验。PUB安装在新生成／AUTO任务上的连续接续、目标存储异常／断电及历史恢复仍需集成验证；本轮目录／签名／文件重启测试不替代这些场景。
- P3：首启封包边界修复后，完整RULE正常长链仍待重跑；PERCENT／RULE、三段校准、SYSTEM抖动恢复及完整初始化／替换／签批的新浏览器和故障组合分开待验。实际AUTO、同袋恢复、暂停取消、SC019／SC048／SC009已有实现，不再笼统列为未接线。
- P4：已实现的原始只读／受控STOP／释放取证还需实际接口、目标身份／网络／存储、异机TLS代理、容量、部署、切换回退和逐设备现场验收。尚无实现的正常控制和采样不能放进“仅待验证”。
- 本轮PUB-01、PUB-02、REL-01均已接真实生产调用者并有§11.13定向证据；不再沿用§11.12的“缺安装提供方／释放取证协议”旧状态。现场未配置不等于这三项代码未完成。

#### 11.14.3 需要业务／工艺确认的规则

| 事项 | 具体未确定内容 |
| --- | --- |
| 供料充足比较 | 首启、原袋恢复、换袋恢复分别比较原目标、名义剩余还是终点剩余；采用≥还是>、是否额外余量。W−R及先预填充已确认，不重复询问。 |
| 正常完成允差 | 最终认可量的合格口径、上下界及等值边界；不能复用运行超量p、终点E或异常少加严格>5%。 |
| 抖动候选反弹 | 已出现恢复候选、尚未真正续补前再次超过原J时，何时重新开始／结束观察、何时允许报警；当前保持保护，不自行报持续抖动。 |
| 换袋／跨段校准 | 新袋及基准如何交接，何时复用或重建原校准，阶段和历史有效运行时长如何延续。 |
| 多段更正／人工补量 | 已认可段、待核对段及不同物料会话之间如何分配人工量，首次更正和调整的依据及范围。单段已有入口不等于多袋分配已批准。 |
| 健康／停后异常余流 | 哪些健康状态构成真实故障，允许余流与异常余流的计量基准、阈值、窗口及故障锁／解除来源；与客户接口返回字段联合核准。 |

具体数值由逐设备参数表核准，包括稳定三参数、最低停止／停后观察、时间质量、校准范围、泵能力和最终允差等；不重新发明已确认的判断公式，也不填示例默认值。

#### 11.14.4 所需客户接口资料与现场能力依据

| 资料包 | 必须说明的内容及对应开发 |
| --- | --- |
| 正常命令／权威查单 | 各实验室实际服务版本、URL／鉴权、请求响应原样例；命令唯一键及幂等保留范围、按原命令查单、ACK／ACCEPTED／实际执行／失败／UNKNOWN／NOT_FOUND语义，首次实际发生时刻及排队超期拒绝。用于START／调速和query适配。 |
| 原始采集及计量身份 | 设备／通道／点位／角色对应、原单位、净毛重／皮重／方向、精度；原采样时刻／时区／分辨率／质量、boot／源序号，实际速度／有效运行计数及失效表示。用于RawReading资格生产，而非以本地接收时间补原时刻。 |
| 泵换算与校准能力 | 目标补量百分比计算后的g/min如何转换为客户设定，转速／流量范围、限幅／精度、密度等适用换算及实际校准依据。PILOT7／8当前仅只读，不默认开放写。 |
| 安全停料与控制权 | 独立STOP／读停、故障停料、实际停泵反馈、最坏停止时间／追加量、旧写方隔离、已进入driver的在途命令处置、epoch／fence与现场故障锁／复位。不能仅凭本地网关阻挡迟到入口证明下游能撤销在途物理写。 |
| 健康及服务依赖 | 小试／中试各自健康接口和进度字段语义、失败／Data0／部分成功及陈旧值处理，小试旧库／培养生命周期依赖、中试健康协议及服务启停条件。不能移用另一实验室URL或将Running当健康／进度。 |

部署配置另列，不算新业务规则或缺代码：PUB专用实际身份／密钥／原有效期／目录／cron，REL权威及客户端身份／adapter范围／端点／密钥／时差／超时，逐设备profile及现场批准、SC019／SC048／SC009实际政策配置、M09映射／接收人／渠道及运维责任。未填写仍关闭／拒绝；不把TEST身份及通知替身用于生产。

范围边界：现行首批只启用已核准SMP量账，PLC／外部权威投影未接；若选择该模式，须先核准EXT02单写者／对账与接口，再开发来源适配。当前sampleIdentity v2仅支持核准单原包、原生控制单位；跨设备多流v3／非原生单位须先确认正式身份和归一化契约再开发，配置schema3／4不等于支持v3。连续式、其他六类配置页、旧未完成任务自动接续、W08及M08不在本次已确认范围，不列为漏做。

### 11.15 2026-10-25 生成批准运行时受控更新及预核准入口（代码与定向验证）

本工作包接续§11.14的生成目录缺口，不重做前四阶段计划。用户确认免审批初始化／替换增加提交前预核准准备入口，正式生效仍保持方案指针、旧任务处理、新任务生成同事务。HEAD仍为5678c46d01b837745340632b79142f9b8ff774db；沿用原worktree／分支，保留现有修改，未提交、推送或创建PR。

#### 11.15.1 已接通的生产代码及边界

- 生成批准由`M07GenerationApprovalCatalog`按culture/lab/snapshot/parameterGeneration/packageHash完整绑定，单次消费使用同一不可变快照；`M07TaskGenerationConfiguration`和原`M07TaskGenerationSourceAdapter`共享该目录。启动显式批准仍兼容，运行时追加不需要重建Provider。
- `M07GenerationPublicationService`复用既有部署发布描述、授权和持久回执模型；`M07GenerationInstallation`、打包工具、Spring装配和扫描入口接通。GEN与逐任务EXEC采用不同专用权限、签名域、加载器及安装目录；复用持久引擎，不建立第二套量账或第二个执行准备Authority Bean。整批核验、原件持久保存后才切换，失败不部分可见；历史授权／摘要／连续记录核验后重启重建。实际身份、目录、密钥、时间及扫描计划仍必须显式配置。
- M03正式Controller／应用服务／Port／Mapper新增`POST .../candidates/prepare`、`GET .../candidates/{candidateId}/approval-material`、`POST .../candidates/{candidateId}/discard-preparation`；前端正式候选组件与SDK已接通。准备冻结原输入、实际候选ID及生成绑定为PREPARED，不改变effective、不取消旧任务、不生成任务或业务审批。撤销以原候选、摘要及版本CAS，保留原件和旧方案。
- 原提交入口接预登记身份，重验原输入、creator／lab、槽位与来源、当前初始化／替换政策和任务屏障；原P02保持同事务。FEEDING DIRECT未准备的普通Port保存统一拒绝，不保留内部绕过。APPROVAL原路径继续使用已保存候选及其独立政策。
- prepare与commit使用不同管理UUID；通用管理请求actor+requestId唯一规则未放宽。M03原持久身份核验后，在当前CANDIDATE守卫／原actor／实际事务内建立专用同步scope，精确关联原candidate/hash/package/preparation request；M06仍只在CANDIDATE生效，原Evidence.requestId及decisionKey保持原准备UUID，managementRevision来自当前commit。PREPARE／DISCARD仅可读取及锁定政策，不产生DirectDecision；finally清理scope。未知结果按原阶段UUID、正文及版本重放。
- 新任务生成后仍须SC003及按真实taskId／version／hash独立核准的逐任务执行准备发布。显式空启动只在`allow-empty-startup=true`且对应受控EXEC发布已启用时允许；空目录不产生批准，任何缺项保持拒绝。原Provider、全部Authority及资源claim使用同一批准目录。

#### 11.15.2 数据结构与正式契约

复用M03快照／状态表，无新增表，总数仍188。快照新增可空JSON `preparation_input`，保存schemaVersion=1的原输入和拟用代次；旧行不回填虚构原输入，状态增加PREPARED。实体、Mapper/XML、JSON契约、两份字段字典、M03目标DDL、01完整建表、03核验、开发基线说明和来源清单同步；02未变。新隔离schema均按hash一致的01／02／03安装。

M01动作／审计登记、M03候选时序与接口、M06专用桥接、M07生成与准备发布、M02安装边界、设备启用／交接材料已同步。外部统一方案追加同日确认，不改客户原文或已存在安全要求。

来源清单仍存在本轮前已有的非本工作包漂移：RM-01统一反应器型号目标DDL实际SHA256与清单不一致（实际64A3547F95849B7FF1ECEE2D57868B486192107214E9720E7CC16C165F009192，清单17305AA2194B0D6409953712A519EF5AB86FE3742534C7D7CF6480A5455DD872）。未擅自改该DDL或按当前文件重签；不能宣称全部19个来源摘要通过。M03本次来源及三份安装副本一致，实际fresh安装通过；此差异留待原模块核对，不用来阻断本工作包独立验证。

#### 11.15.3 本次最终定向证据（分层、去重）

| 层级 | 对应最终源码／日志 | 实际结果与限制 |
| --- | --- | --- |
| 后端编译 | `283-shared-test-compile.log`，2026-10-25 20:23:10 | 19模块Maven离线test-compile，3566 main／912 test，退出0／BUILD SUCCESS；不是执行全部测试。其后仅新增M06两项负例，单类javac退出0（284-m06-test-compile.log），生产源码未改。 |
| 单元／契约 | `284-generation-final-targeted.log`、`289-preparation-entry-adapter-targeted.log` | 两组独立测试分别61/61、10/10，共71/71、0跳过；GEN目录／发布／安装／重启／权限隔离、两Authority装配、准备身份／入口及M06普通与桥接反例。替代270／277及诊断overlay重复结果，不累加。 |
| 前端 | `283-candidate-ui-targeted.log`、`283-candidate-ui-typecheck.log` | 候选入口6与原方案47，共53/53；Vue-tsc退出0。测试参数均TEST输入，不是生产默认值。 |
| 真实隔离SQL＋正式Controller | `284-m03-preparation-shared.log`、`285-m03-direct-shared.log`、`286-m03-approved-shared.log`、`287-m03-http-shared.log` | Prep3／Direct6／Approved2／HTTP2，共13/13、0跳过，全部基于283共享产物，无overlay。覆盖INIT／MODIFY、缺批准回滚保留PREPARED、撤销、独立GEN发布后同事务生效／生成、回执重放和无权限拒绝；不是纯Mapper存在性验证。 |
| 隔离进程＋真实TEST设备HTTP | `284-generation-init.log`、`288-generation-modify.log` | 真实SC019初始化／SC048替换、缺GEN时原P02回滚、运行时签名GEN发布后原delivery ACK并生成、SC003、缺逐任务准备拒绝、独立EXEC签名发布、原Provider／Authorities／claim、网关＋独立监控双登记、实际TEST M02 START及首运行反馈，两链2/2、0跳过。任务分别1311829709761466368／1311830346762997760，各firstStarts=1。停止在实际EXECUTING／资源HELD／ledger0，不伪造量账或FREE，不代表整次补料、收尾、释放验收。 |
| 定向浏览器 | `285-candidate-preparation-browser-live/http.ndjson`、`285-browser-discard-snapshot.yml`、`285-browser-discard.png` | 正式Vue组件／SDK／Controller／guard／audit／隔离SQL；TEST只提供来源目录与身份。页面prepare→PREPARED、读取材料、未发布GEN时提交拒绝DAY_ORIGIN_POLICY_UNAVAILABLE、撤销成功；旧effective、taskCount1、applicationCount0保持，revision与slot各按真实事务递增。仅替换页面上述入口，未声称完整浏览器验收或页面正向发布执行。 |

本工作包测试结束后，33088已按原PID／开始时间／监听子进程／INI／datadir再次核验并正常关闭；浏览器桥接及5841 Vite也已停止，原33087保留，未删除测试数据。SQL与进程两组各用独占33088严格核PID／exe／INI／datadir及TEST标识，每类新schema；浏览器使用既有33087另建freshschema，同样先核port／datadir与安装摘要。没有调用真实设备、共享库或通知；实际设备HTTP为明确标识的隔离TEST实现。

真实失败保留：最初缺M01动作／审计登记与当前准备／提交UUID桥接被guard拒绝，已在实际负责层修复，未放宽通用幂等和安全门禁；旧测试读取M06 payload、重复安装、缺资源键及缺monitor终点属于TEST输入接线，均修正来源和装配后以共享产物复验。275／279等失败、270／280—282私有诊断不重复计最终通过。浏览器首个Vite在沙箱显示ready但宿主回环超时，停原进程后以同一loopback TEST配置启动宿主才正常；唯一浏览器console错误是favicon.ico 404，无业务JS错误。

#### 11.15.4 当前剩余项

本工作包的目录更新与预核准生产链已实现并完成上述必要定向验证。最终文件摘要记录在`289-generation-preparation-source-snapshot.json`（76文件，含复用helper及正式契约；整文件摘要不将既有修改归属本工作包）。最后7类专用桥接／管理与审计修复另做只读复审，未发现有依据的必须修复问题；静态结论不替代上述执行验证。全面回归按用户要求后置，不能把本工作包完成写成全部四阶段验收完成。

- 仅待进一步验证：最新完整快照的P1—P4回归；生成后完整补料／异常停止／恢复／计量／H06释放与取证的组合；RULE完整长链、各策略／AUTO与初始化替换的完整浏览器；持久安装目标盘故障／断电、重启及部署切换／回退。原§11.14.2的其他未验证项保留。
- 待业务确认：§11.14.3仍有效；生成目录可发布不补D0、残糖、算法或审批政策；抖动候选反弹、特定健康／停后余流判据、换袋及跨段校准、多段人工归属、供料比较继续阻断相应允许路径。
- 客户协议／现场：§11.14.4及客户正常START/SET_SPEED、权威命令query、合格采样来源／时间／质量映射等仍需正式资料；已完成软件发布接线不等于这些驱动已可用。实际发布身份和部署参数待配置；不伪造设备能力或现场验收。
### 11.16 2026-10-25 最新快照整体回归（进行中）

用户本轮授权开始整体测试；沿用隔离库、TEST设备及原计划，不提交／推送。§11.15保留当时源码与定向证据，本轮新增修复后结果不得沿用旧计数冒充最终整体通过。

已执行首轮：290联合19模块编译通过；system 9706项，9686通过、14失败、6跳过；前端2870项，2847通过、23失败。故障日志全部保留。后续针对实际原因修复，不删除断言或放宽安全要求：

- M03新增Port原四参数违反单模型请求规范，改为`PreparedFeedingCandidateCommand(command,candidateId,candidateHash,preparationRequestId)`，同步PKG-00、调用者与签名快照，不给通用Port增加多参数例外。
- PREPARE／撤销动作、23列快照、两条Mapper CAS及应用方法面同步精确登记；保留全部白名单、审计字段、绑定及数量相等检查。旧DIRECT保存测试改核其未预登记时必须拒绝，仍验证审批影响冻结。
- Windows TEST进程清理捕获原Process的实际后代，等待原子JVM及launcher退出并关闭流，再交JUnit清理日志。不忽略TempDir删除失败、不调整生产停止或释放规则；覆盖独立监控TEST与真实执行TEST宿主。
- 前端旧接口封锁测试仅按已开放的补液路径精确登记；两份SFC测试接入真实`use-reactor-form`及TEST翻译依赖，候选测试显式提供TEST泵事实，不能恢复生产默认泵；补中英文`occupancyUnknown`词条。
- RULE实际浏览器运行发现只读摘要将JSON字符串数值映射为0。298先增两项真实应用服务调用测试复现（字符串1000.125被读为0、非法值被读为0），再修正只读数字解析：数值及有效十进制字符串精确读取，坏值／对象／布尔保留null，不伪造0；不影响控制计算或量账。26项读契约测试转绿。

当前分层结果：294前端全量225文件／2870项全部通过；292独立安全协议106、gateway80、monitor131、customer40（合计357）通过、0跳过。291首轮7项Java loopback失败由向Surefire子JVM传现有短TEST临时目录修复，未改传输安全逻辑。私有修复层294／296只用于诊断，不能替代最终299共享编译及其后回归。

39类SQL清单已核对实际类面，每类独立freshschema。初选33088时，部分旧测试按固定33087目标安全拒绝；按原严格33087入口重跑，不改守卫。初轮唯一非目标拒绝是NOT_SENT两例实际业务链后TEST monitor.log清理占用，应用结果和清理结果分开记录，最终须重跑新清理实现。当前39类及重跑的结果以290／295原始日志保留，汇总不得将首次环境拒绝计成业务失败或将旧私有层当最终通过。

297 RULE_NORMAL已按真实时钟跑完START、实际反馈、10.000000g、唯一FEED1／SETTLE1、STOPPED、CONFIRMED、资源释放及外部ACKNOWLEDGED，进程退出0。正式任务页面从执行中到已执行、安全交接已完成均实际回读；此轮页面曾暴露上述数值读问题，不能将其称为全字段已验收。截图树297-rule-running／completed-browser.yml及原HTTP审计保存。TEST模板／授权／设备物理实现均明确标识，不是生产默认值或真实设备验收。

正在执行299最终共享编译，随后复验受影响SQL、system整体、剩余安全组合与浏览器。客户接口／业务待确认／现场条件仍按§11.14.3—4；不得因本轮模拟通过解除外部阻塞。
#### 11.16.1 后续真实结果与交接进度修复（仍在验证）

- 306轮system实际9712项：9705通过、1失败、6跳过。唯一失败为新增交接进度发布回执的重放身份核验；原件恢复不携带可变publishAttempts，已修正该回执校验并以307定向11/11复验。不得将其描述为当前整体9712项全绿。6跳过属于未启用独立M05 MySQL配置的原测试。
- 306轮隔离SQL补跑：生成运行时目录、方案替换生成、任务生成、监控activity、续段来源、独立抖动交接六组通过。39类清单中NOT_SENT撤回后的完整正常执行仍需复验；其余分组结果按290／295／300／306去重引用，不累计重跑次数。
- 303真实时钟链：SYSTEM抖动恢复、运行超量、采集失败保护通过；三段正常流程、AUTO子任务及302暂停恢复仍出现EXECUTION_PROGRESS_STALLED，未放宽maximumControlGap。AUTO已真实建立并启动子任务，不能据此称子任务完整执行通过。
- 暂停恢复308轮实际失败：交接进度与独立监控当前上下文的source／controlledAt不一致，M02继续保留PREPARED且未下发续段SET_SPEED；不是设备现场阻塞。用户确认增加真实三方交接完成进度证据后，补齐ACTIVATED原件绑定、上下文哈希链修订、独立持久ACK及最终命令门禁。原STARTING、原计量和策略保持，既不制造实际运行反馈，也不延长首次反馈／停止期限或解除已锁定保护。309先增加测试复现缺失门禁，310修复后31/31；新增真实MonitorExecutionContexts消费断言随311共享编译及后续验证复验。
- 独立数据库故障测试已记录DB失联时离线保护证据，但TEST数据库恢复等待45秒超时，恢复实际就绪较晚；未形成最终恢复验收。调度进程单独退出、暂停取消浏览器、剩余组合及最终整体回归仍未完成。

311共享编译与本修复端到端验证进行中。所有结果限隔离TEST设备／freshschema；没有真实设备、共享数据库或真实通知；未提交／推送。参考参数均不成为生产默认值。此前11.16中“正在执行299”是历史进度，以上后续记录覆盖当前状态。
#### 11.16.2 用户确认的续段进度及真实恢复复验

用户确认“已持久化、精确绑定原命令的三方交接完成事实”可计一次进度。生产链已接为：原ACTIVATED原件与双登记ACK核验、上下文revision2及previousContextHash、独立上下文持久ACK、原PROGRESS出站及持久回执、M02最终门禁。新增上下文仍STARTING且不增加commandExecutedAt、实际量、运行窗口或首次开始事实；不延长首次反馈或停止期限，不解除已锁定保护。正式方案与五份契约同步。311共享19模块test-compile通过；311相关94项通过；313真实XML解析先复现来源过滤漏登记ACTIVATED，补齐后314映射2/2通过。独立监控消费者仍严格要求source／controlledAt精确对应最新上下文，未绕过其校验。

314浏览器暂停和恢复均返回202（来自正式管理守卫／Controller／SQL）；已确认停料、完整观察后实际续段SET_SPEED执行，再收到合格HIGH反馈。后续原终点停止时证据归并耗时增长，EXECUTION_PROGRESS_STALLED于14:25:06Z触发，实测总量10.100000g也超出本次明确TEST最终允差上限10.040g（不是运行超量阈值）。最终ERROR／CONFIRMED、安全释放及外部ACK均落账；这证明实际恢复与异常安全收尾，不代表正常完成。312此前缺来源映射的503与314原始失败均保留，不能用局部94项替代此结果。314源码整体hash保存在314-activation-source-snapshot.json。

315串行复验中，独立抖动恢复完整执行及释放通过；三组受影响SQL（activity、独立抖动交接、续段批准来源）通过。THREE_STAGE_NORMAL首个子Shell未取得隔离数据库身份查询结果，未启动场景，属于TEST启动失败而不是三段算法结论；尚待单独重跑。AUTO实际生成、独立批准并开泵后，扫描器仍引用父任务旧消费者，控制评估被原资源事务身份门禁拒绝；已修正TEST宿主在安装子任务消费者后重建扫描器，尚未共享编译／端到端复验。生产身份校验不改。

停止性能修复316目前仅私有诊断层：新样本超出原coverage.coveredThrough时，仍真实追加样本，直接等待原停止扫描器刷新覆盖，避免对已知过时覆盖反复加载全段历史尝试收尾。等于终点、较早及乱序样本仍走原完整最终化；不删除原件、推算覆盖或放宽期限。先增真实Port边界测试复现，修复后30/30；正式采样及计量契约同步。当前NOT_SENT及system批次仍使用314共享代码，不将316私有层结果归为共享回归。需后续共享编译和停止全链验证。
#### 11.16.3 共享快照与后续复验（2026-10-25 22:55）

315系统整体回归：9714 found、9708 started/successful、6 skipped、0 failed；6跳过均来自缺显式M05 MySQL测试配置的原条件类。39类SQL按290／295／300／306／315最新结果去重均通过，清单315-sql-deduplicated-results.json；不叠加重跑计数，不将这些历史分批结果表述为317全部最新代码已整套SQL通过。315独立抖动恢复完整执行及释放通过，NOT_SENT撤回两项通过，其中真实NORMAL任务补料／停止／计量／释放通过。

317共享19模块test-compile通过（3567主源、913测试源）；包含停止超覆盖快速保留与AUTO扫描器接线修复。受影响13类220/220、0跳过（317-affected-tests-retry.log），覆盖采样、正常/暂停最终化、完整停止证据、观察进度、续段上下文／回执／缓存。首次317参数文件中的Windows反斜线导致ClassNotFoundException，仅修正TEST argfile路径为正斜线后重跑，不改生产类路径或忽略失败。317-final-source-snapshot.json保存本次相关文件整体摘要；315整体回归结果不冒充317完整回归。

318 AUTO_CHILD实际通过：父任务ERROR／CONFIRMED并释放后，真实异常处理HTTP以原UUID重放并生成唯一AUTO子任务；明确9g独立批准，拒绝借父批准。子任务真实START及HIGH、补9.000000g、EXECUTED／STOPPED／CONFIRMED、唯一FEED1／SETTLE1、资源释放及外部ACKNOWLEDGED，父子HTTP关联核对通过，进程退出0。无SQL状态结果夹具或生产参数默认值。中间曾因原读取失败未知证据而继续等待，后续合格覆盖形成后才收尾；未放宽未知证据规则。

本轮故障专用33088恢复进程已于22:49按实际子PID11124／父32904、原exe／INI及SQL port/datadir重新核验后正常关闭；旧owned-instance.json仍是被杀原PID，不为绕过守卫伪造更新。原33087保留，TEST数据未删除。数据库故障恢复验收本身仍因先前TEST readiness 45s超时未通过；离线保护原证据有效，不合并为恢复通过。

319三段真实校准／高速／低速／最终收尾及性能记录进行中。新快照暂停恢复整链（含浏览器）、暂停后取消浏览器、调度进程退出、数据库恢复故障及切换部署仍待验证。客户接口、现场及未知规则继续按11.14保留；本节是软件测试进度，不是四阶段验收完成。

319三段串行复验通过（2026-10-25 23:01）：真实120s校准、HIGH、LOW、终点STOP、完整观察、10.000000g、EXECUTED、FEED1／SETTLE1、资源释放及外部ACK，退出0；319-three-stage-normal.log与同名JFR保留。不修改原3s进度保护、首次反馈／停止期限或最终允差，不用旧303失败覆盖此次结果；旧失败仍保留。320新共享版本浏览器暂停恢复正在执行。

#### 11.16.4 续段冷验证耗时及当前新快照（23:25）

320浏览器恢复保留真实失败：原续段登记已提交，新上下文revision1已有独立持久ACK；但原监控在三方交接完成前对旧段产生EXECUTION_PROGRESS_STALLED新STOP，网关正确中止续段，未下发正常开泵。gateway原件显示该原因发生于15:04:02.808Z，原新段registeredAt为15:03:59.805Z；无双ACK／ACTIVATED原件。后续缺ACK的取证继续拒绝，不用伪造ACK或延长3s保护化解。待修复为交接验证成本，不增加早期“准备进度”或取消既有保护。

已实现验证结果复用：ACK持久化时验证并记录本进程的原请求／实际DB来源／LOCAL ACK完整指纹；交接仍全量重读并核对这些当前原件，只有完全匹配且时间未回退才省重复解析。缓存不提供业务事实、不计进度、不替代DB提交；原件变更／缺失／外来／重复／回滚后不符仍重验或阻断。321先增首次交接测试复现8条已验证回执仍重复冷解析，随后90/90定向通过。323另增真实MySQL JSON格式差异反例（快照紧凑文本与DB读回文本不同），已改为使用实际DB来源暖验证指纹。322共享19模块test-compile通过；324最终两主类及一测试类共享javac通过，受影响222/222、0跳过，未用私有层冒充该共享结果。独立监控及JSON契约同步。

325数据库故障在全新独占33088实例执行：此前45s TEST MySQL readiness不足已改为90s启动等待，仅属测试基础设施；不修改任何生产控制／反馈／停止期限。已观察实际DB停止、独立离线保护及DB真实重启，最终恢复／计量／释放尚在验证。原33087保持不动。此后须重跑浏览器恢复、暂停取消、调度进程退出，并完成最终受影响回归与源快照记录。没有提交／推送／PR，没有真实设备、共享库或真实通知。
#### 11.16.5 实际故障通过与停止热点后续修复（23:49）

325 DB故障在全新专用33088上通过：真实数据库进程停止，M07无法取得业务DB时独立监控仍采集／停止并持久原件；重启数据库后沿原STOP首时间15:26:17.7808554Z与期限15:26:32.7808554Z恢复归并，未重置期限。最终ERROR／STOPPED／CONFIRMED、0.300000g、安全释放，final-result.json及原offline-evidence完整保留，进程退出0。

326调度进程单独退出通过：只杀TEST M07子PID17300，网关／TEST设备进程59860与独立监控52724继续工作；独立读停形成原STOP及期限，M07重启后归并原链，未重复START，最终ERROR／STOPPED／CONFIRMED、0.100000g并释放。证据在outputs/mysql-process-fault-1792941705667/scheduler-execution；运行时使用共享classes，无旧私有overlay。33088保留待最终正常关闭，原33087不动。

327浏览器暂停／恢复均202、实际续段SET_SPEED与HIGH通过，旧段冷验证停滞未再发生；但终点后的完整正常收尾仍失败，按ERROR安全释放。不可据此写“暂停恢复至正常完成已验收”。此前314／320／327失败均保留。新327共享快照原件／ACK缓存已通过真实MySQL格式校验，不把321私有层当最终结果。

性能定位使用319原JFR，按实际STOP时刻分开分析：主线程停后采样热点集中JSON规范化及原样本解析，分析见328-three-stage-hotpaths.log；原30MB JFR保留，临时257MB导出JSON已删除。328原始摘要重复解析计数测试先红，随后按固定规范化信封字节直接组合已校验的规范样本，保留排序、重复项、数字、Unicode和转义，旧摘要逐字节兼容测试通过。329覆盖排序先复现同一原行重复读取，再在单次调用内解析并排序，不删任一原样本或改变STOP锚点／来源资格校验。129/129定向通过；330两生产类及三测试类共享javac通过。没有改原3s保护、采样缺口、完整观察、最终允差或释放条件。

TEST宿主对“请求正常却安全ERROR”的结果只增加原始失败标记及可选浏览器读回保留窗口，仍抛原AssertionError／退出失败，不改执行状态或计量结果。330最新共享版本真实浏览器暂停恢复及JFR正在执行；最终整体回归、暂停取消浏览器及受影响SQL尚需执行，现场／客户阻塞仍按11.14保留。
#### 11.16.6 2026-10-26 续段并发及停止读取性能修复（验证中）

330、333暂停恢复实际运行仍保留失败，不计正常通过。333已安全ERROR／确认／释放，但同步恢复曾返回503；真实日志定位同步与后台重复插入ACT上下文唯一键。334新增锁序和隔离级别测试先失败，335新增并发ACK重放及真实索引测试先失败。修复ACT上下文READ_COMMITTED及既有业务锁序，并在竞争已完成时严格复核同一持久ACK。337定向75/75通过，0跳过。

333慢调用记录：selectSegmentRequests累计27721ms（257次），selectSampleQualification累计7111ms（74次）；真实EXPLAIN证实ORDER BY/LIMIT选择PRIMARY扫描。补齐事件类型／状态／对象索引，未增加默认值、期限或容差。目标DDL、字段字典、基线及来源摘要已同步。338新建隔离库索引／outbox事务验证进行中；更新后暂停恢复、暂停取消浏览器及最终快照全面回归仍待验证。原315整体结果不冒充当前修改已全面通过。

#### 11.16.7 00:34 测试续报：取消闭环通过、恢复读数边界待确认

338新建隔离库：M07MonitorActivityPersistenceIT 11/11通过，含新增原件检索索引；345基线同步18/18通过。343首次Python临时目录被沙箱拒绝，改用本工作区明确TEST临时目录后复验，不改生产实现。347在339实际累积原件上EXPLAIN ANALYZE选择idx_m07_event_type_scope，2条原登记候选，实际总耗时1.28ms；不将该单次结果作为现场容量保证。M07来源及01/02/03三个artifact摘要一致；RM-01已有漂移仍不改动。

342定向75/75通过，含真正区分旧PENDING快照和另一发布者已提交PUBLISHED／attempt+1快照的ACT进度ACK重放；只核对不变原件及真实typed receipt，不以重试次数差异否定同一已提交ACK，也不凭状态通过。346共享19模块test-compile通过（本次incremental显示已最新，不宣称重新编译全部主源）。

344真实浏览器与HTTP暂停202、稳定观察后PAUSED、取消200；最终CANCELLED／STOPPED／CONFIRMED、2.900000g、唯一FEED1／SETTLE1，local RELEASED及external ACKNOWLEDGED。设备/现场故障锁查询仍UNKNOWN，不据本地资源释放推断故障锁已解除。344-pause-cancel-browser.yml及HTTP审计保存，进程退出0。

339恢复HTTP202，但原件中出现交接期间旧身份读数，资格拒绝后最旧原件阻断后包，触发进度保护；420秒测试期限内未能收尾，退出1。未伪造投影、覆盖或完成。自动审批拒绝了把所有QUALIFICATION_INVALID都允许后包推进的泛化补丁，未实施；正式采样契约仍规定一般未知及跨边界阻断。已集中请求确认仅针对原续段明确上一段身份、全采样时间早于新调用而接收稍晚的窄分支；待答复前不扩大原有例外。340候选测试暴露该边界，保留失败证据。

348最终快照整体单元/契约回归进行中。349受影响5类真实SQL 46项中45通过、1失败：未启动撤回后NORMAL重试安全关闭为ERROR；与整体回归同时运行，尚未证明是否负载影响，须串行复验，禁止直接归因为环境或调大期限。350按原PID／UTC启动时间／exe／INI及SQL真实datadir核对后正常关闭本轮33088专用实例，未删除数据；33087保留。首轮关闭校验失败源于PowerShell将JSON UTC自动转换后再次按本地解析，改为读取原JSON时间字符串精确核对，未修改原marker绕过校验。

348整体结果：9724 found、9717 successful、6 skipped、1 failed；唯一失败为本轮新增泛化候选测试，期待普通未知身份也允许后包推进。该期待与正式独立监控第8节及业务采样契约的通用阻断要求冲突，不是已确认的生产需求。已修正测试同时断言：已识别PreviousCommandObservation可检查后包，普通未知身份仍阻断且原件保留；生产reproject逻辑未修改。352该类23/23通过，0跳过。这个修正只涉及本轮新增断言，未删除原测试或弱化生产校验；窄续段业务分支继续待用户答复。348旧失败原始日志保留，不宣称348退出0或当前已重跑整套。353-current-source-snapshot.json记录当前源码／基线摘要及边界，351未启动撤回完整执行正在串行复验。

#### 11.16.8 00:42 本轮可执行验证结果

351未启动撤回串行复验2/2通过，0跳过、退出0。其正常重试实际START／HIGH、终点STOP、完整观察、EXECUTED／CONFIRMED、10.000000g、唯一FEED1／SETTLE1、本地释放及外部ACK均通过；原未启动尝试仍NOT_STARTED、无first_start_evidence。349原失败的真实停止原因经355只读SQL确认EXECUTION_PROGRESS_STALLED，首次停止及15s期限原件保留。351证明无并行整套回归时该链可通过，不等同于已证明所有负载条件满足现场运行能力，也不删除349失败。349／351按唯一用例取最终结果，受影响5类46项均已有成功证据，不叠加两项重跑数量。

348是本轮整体快照结果：9724 found／9717 pass／6 skip／1 fail，唯一新测试期待已按正式契约纠正，352该类23/23通过；修正后未再次运行未受影响整套测试，不将348改写为退出0。6跳过仍为缺显式futurefab.test.m05.mysqlConfig的M05条件MySQL类；不补共享dev配置运行。前端2870/2870及独立模块357/357为292／294相应源码快照结果，此后本轮未改其生产内容。39类SQL历史分批证据仍见315去重清单，本轮只重跑受影响范围。325真实DB退出恢复、326真实调度JVM退出恢复、318 AUTO及319三段完整链为各自快照通过，不能冒充最新客户接口或现场验收。

仍未通过：339暂停恢复完整链。明确上一段、全部采样在新调用前但接收稍晚的续段原件处理边界等待用户确认；通用未知身份、跨调用、坏质量、缺覆盖继续阻断。未实施被自动审批拒绝的泛化QUALIFICATION_INVALID例外，未补默认参数、延长期限或伪造覆盖。待确认后须补窄分支原件/并发/重放测试及真实恢复链复验；若仍不允许，则该场景按现有保护与人工核对处理，不宣称恢复通过。客户接口、部署及现场仍按11.14的外部阻塞清单，不声明四阶段验收完成。

工作区改动和空索引保留，暂未提交／推送／创建PR。所有真实设备、共享／生产DB和真实通知均未调用；本次Vite及TEST运行入口已结束，33088专用故障库正常关闭并保留数据，原33087未关闭。

#### 11.16.9 2026-10-26 已确认窄续段原件分支，实施及复验中

用户允许明确上一段、所有采样早于原新段调用但接收稍晚的原件保持未决，同时继续检查各自合格后包。统一方案及采样／独立监控／JSON正式契约已同步；不实施此前被拒绝的泛化QUALIFICATION_INVALID处理。357 GOOD用例先失败，358定向32/32通过；跨调用、未知身份、缺ACK、未知命令、坏质量、外来资源及未来接收均保持原拒绝。359新隔离库原件／回滚／重放10/10通过，网络和采样Port仍为明示TESTdouble，不称物理执行通过。

只新增既有ingestion.blockers诊断字符串，不加NCS码、表、字段或量账；原件不写排除或投影回执。339原件核对还包含采样已晚于SET_SPEED调用的旧身份读数，该条不属于用户本次允许范围，继续阻断；不能宣称本次确认会让339历史原件通过。360编译及新真实暂停恢复链待复验。

360共享19模块增量test-compile通过；361受影响4类104/104通过，0跳过，含原通用未知身份阻断、正式资格生产者和停止覆盖拒绝；362隔离SQL11/11通过，含359同批重投影10项及既有续段SYSTEM锁序竞争1项，不重复累计。364-narrow-source-snapshot.json保存本次源码／正式契约／统一方案摘要。原规则全文集中在正式采样契约，方案和其他契约引用职责边界，避免复制出多套权威。363新任务浏览器暂停202、实际完整观察后PAUSED、恢复202及真实HIGH已通过，完整计量和释放仍在等待，不能据此宣称恢复整链完成。

363当前共享代码真实暂停恢复链已完整通过，退出0：浏览器暂停202、实际停料及完整观察后PAUSED；恢复202、原SET_SPEED实际执行、新段合格首反馈／采样及HIGH；原终点停止后完整观察，最终EXECUTED／STOPPED／CONFIRMED，10.000000g，两段FEED、一份SETTLE，local RELEASED／external ACKNOWLEDGED。原首次开始时间保持，未提前释放、未改容差或期限、无人工handling。363-pause-resume-final-browser.yml及366-real-final-http-facts.json保存真实最终页面／HTTP。设备故障锁仍UNKNOWN，不把释放当成锁解除。

367核对该实际运行的ACK原件，窄分类命中数为0；因此363证明当前代码的正常暂停恢复整链，不声称此运行覆盖了人为延迟旧包分支。窄分支正反例由358／361证明，真实原件持久／回滚／重放由359／362证明，各层严格分开。339旧场景里的调用后旧身份数据仍不适用新例外，保留失败证据。当前365整体回归进行中，不能借104项定向结果替代其退出码。

#### 11.16.10 2026-10-26 当前窄分支完成及最终回归

用户确认的明确旧段调用前／接收稍晚分支已IMPLEMENTED、CONTRACT_TESTED；原件不投影／不排除／不计量，通用未知及采样达到或晚于调用继续阻断，覆盖区间含未投影原件仍不释放。正式采样契约为规则正文，统一方案、独立监控及JSON事务契约已同步职责和引用。无新表、字段、NCS原因、默认值、截止时间或容差变更。

365最终共享快照整体单元／契约回归：9735 found、9729 started/successful、6 skipped、0 failed，进程退出0。6跳过为缺显式futurefab.test.m05.mysqlConfig的M05条件MySQL类。冻结的364源码与正式契约摘要在整体回归期间未变化；104定向项与整体结果重叠，不累计总数。360共享19模块增量test-compile通过；362隔离SQL11/11通过（含359的10项及SYSTEM原锁序竞争1项），不重复计数。

363当前代码正常暂停恢复链为HTTP_VERIFIED＋BROWSER_VERIFIED：10.000000g、两段FEED、一份SETTLE，EXECUTED／STOPPED／CONFIRMED、local RELEASED及external ACKNOWLEDGED；最后HTTP200及完整页面留证。367核对新窄分类实际命中0，不把正常浏览器场景当作窄分支注入覆盖，正反例和持久回滚／重放证据分别见361及362。339调用后旧身份场景依旧保留失败，不纳入获准例外，也不伪造恢复通过。

本次边界不再等待业务确认。现场参数、客户接口、逐设备能力核准、负载及部署验收仍按原外部清单保留，未宣称四阶段全部验收完成。未连接真实设备、共享／生产DB或真实通知，暂未提交／推送／创建PR。已退出本次363设备／监控／M07及Vite TEST实例；保留33087和原始数据。

### 11.17 2026-10-26 cloud兼容整合（未提交，扩大回归未全绿）

按用户授权在原worktree/分支合并origin/cloud `ff083fc8a`，HEAD仍`5678c46d0`，保留MERGE_HEAD，未提交/推送/PR。78个原改动重叠路径中41个手工冲突已逐文件处理，Git未合并条目0；870份原源文件与原始备份均保留。详细修改、备份位置和逐层结果见[cloud兼容整合记录](../03-接线与阻塞记录/日期型报告/20261026-cloud兼容整合记录.md)。

生产兼容保留任务完整H06，并接工作流冻结完整资源与各自fence；工作流结算改为消费原段持久覆盖，无覆盖仍保护。保留暂停取消与结束培养审批、采样历史/当前锁序、续段及原件资格，前端保留cloud布局与补液候选入口。合并基线实际192表，补登记cloud既有两表来源，不增加猜测设备参数；48场景、28步骤，精确hash及静态校验同步。

验证：19模块test-compile通过，后续6个测试宿主定向javac通过；最终关键303/303、前端100/100、基线脚本19/19、真实隔离SQL15/15（均0跳过/失败）。隔离SQL包含正常10.000000g补料、唯一FEED/SETTLE、释放及客户安装取证HTTP；不代表客户设备。旧363浏览器不适用于本合并快照，本轮浏览器NOT_VERIFIED。

扩大测试首轮11689项、11464成功/16跳过/209失败；原失败43类复验586项535成功/51失败，其中1项后续关键定向关闭，尚有50项未关闭，完整清单见整合记录。不得将其统一归咎测试或自行更新全部白名单。工作流v1称重生产者仍缺受控覆盖生成到H06的完整链，属于软件缺口；已消费覆盖不等于生产者已贯通。AUTO/RULE/校准/抖动/替换及完整浏览器还需合并后验收，客户现场阻塞仍按原清单保留。暂未宣称兼容回归全部通过或四阶段全部完成。


### 11.18 2026-10-26 原50项关闭与v1受控停止覆盖接线

后续三个实际执行场景及任务页面复验见11.19；11.18的整体回归对应当时源码，不反填后续测试宿主修改。

11.17保留合并首轮历史；其50项失败及v1软件缺口以本节后续证据更新。原50项独立复现后已关闭，区分旧测试宿主/契约登记不同步与实际实现问题。精确同步权限、分页、容量、Q31生产者及门禁登记；修复Q31与M06证据分别解析、培养结束审批支持件边界及前端控制器身份跳转。不放宽未知JSON、权限、完整哈希或安全门禁。

工作流v1生产链已接通：M02核准观测策略及泵/秤绑定冻结→首次计量原件→正式读数Port→原锁序采样及失败标记→原STOP与完整覆盖资格→覆盖CAS/LOCAL事件→共享停止稳定验证→同事务既有PRIME/物料结算→原H06门禁。W07新启动缺核准策略明确阻断，必要STOP保留；STOPPING采用原执行/OPEN段/worker/fence/版本CAS，不代表已停料。缺覆盖、坏质量、未知状态和冲突保持保护。未扩展采样身份为v3，未把元数据时长称为设备计数。

M02配置、M07设备命令/JSON事务/字段字典及M03快照契约同步。无表/字段/索引变更，合并基线仍192表、48审批场景、28工作流步骤。分类和日志见[修复记录](../03-接线与阻塞记录/日期型报告/20261026-cloud回归修复与工作流v1停止覆盖记录.md)。

最终验证：19模块test-compile成功；系统整体11,706/11,706、0失败/跳过；前端260文件3,499/3,499；独立四模块357/357。401定向与20条件SQL和整体重叠，不重复累计。新增v1真实隔离SQL3/3验证事务提交/回滚/重放、CAS及缺覆盖拒绝，使用明示TEST STOP输入，不冒充设备执行。原15项补料隔离SQL通过，包含正常10g、唯一FEED/SETTLE及释放/安装取证HTTP；首轮新增v1失败记录保留，以后续3项结果关闭。结构脚本19/19、来源hash及契约锚点通过。

按阶段：第一阶段本轮受影响安全/证据回归通过；第二阶段原补料隔离链与新增v1覆盖持久链有分层证据；第三阶段合并后AUTO/RULE、三段校准、独立抖动、初始化/替换及完整恢复等HTTP/浏览器矩阵仍待验收；第四阶段独立模块/适配单元通过，客户接口、逐设备核准、部署负载和现场验收待外部条件。未验收不直接等于未开发，单元/SQL通过不等于四阶段验收完成。

本轮明确的软件缺口已关闭；后续完整HTTP/浏览器及部署验证若发现实现缺口，继续按原计划修复。客户参数、身份/映射、时间质量、反馈/释放取证及真实设备授权仍按启用清单逐项核准，不补默认值。未连接真实设备、共享/生产DB或真实通知。HEAD/MERGE_HEAD未变、未合并条目0，暂未提交/推送/PR。

### 11.19 2026-10-26 三场景及现有任务页面隔离复验

基于c204ab715及三处未提交TEST宿主修复，NORMAL、PAUSE_RESUME、OVER_AMOUNT均由实际生产组件驱动TEST设备，完成停止、观察、计量与释放，并逐个连接现有任务页复核。正常10.000000g、FEED1/SETTLE1；暂停恢复10.000000g、FEED2/SETTLE1，页面暂停与恢复均202、实际PAUSED时不释放、原首次开始时间保持；超量12.300000g、NCS009、ERROR/STOPPED/CONFIRMED，释放双ACK后仍HANDLE_EXCEPTION且禁恢复。各场景人工处理0，设备/现场锁UNKNOWN不自动解除。

首两次NORMAL失败原件保留：隔离宿主缺正式计量Mapper、原监控上下文ACK超时。补齐已有Mapper并在TEST Main的设备调用前仅对同一原上下文HTTP超时做有界重放，验证错误及超时耗尽继续失败，不重试设备命令、不调期限或容差。三个TEST源码编译通过，相关10项定向用例通过；不是新整体回归，不改生产源码。正常/暂停恢复检查后进程退出0，超量保留600秒HTTP供查看，记录时尚未退出。

记录见[三场景隔离联调](../../开发基线/开发包/补料调度-三场景隔离联调记录-20261026.md)，原件在outputs/manual-feeding-20261026。仅33087真实核验datadir的独立MySQL和每场景新库，未连接dev、真实设备或真实通知。页面复用现有任务组件和正式SDK/Controller，但HTTP内层为TEST MVC身份容器，不等于完整门户、登录/AOP、页面创建审批全流程或客户现场验收。新TEST修复与记录暂未提交/推送。

### 11.20 2026-10-26 页面方案、审核、生成至释放的两条隔离正向链

需审核模式INITIAL-03/REPLACE-02均从现有候选组件/SDK实际提交，经M03管理守卫、独立GEN签名发布、SC019/SC048正式审核与原交付、P02生效/任务生成、独立SC003审核、逐任务EXEC签名发布、原Provider/claim及实际TEST设备执行，达到10.000000g、唯一FEED1/SETTLE1、EXECUTED/STOPPED/CONFIRMED、local RELEASED/external ACKNOWLEDGED，现有任务页参数和终态复核。替换旧任务及旧SC003均CANCELLED，新任务只生成一条。最后只读SQL核对每次START/SET_SPEED/STOP各1且EXECUTED、资源两项FREE、参数应用各1。

本轮仅TEST宿主接线：复用runClaimed完整循环；HTTP绑定实际生成任务；展示Mapper副本沿已有公共DTO查询口径，而原证据Mapper仍严格；旧生成/替换SQL宿主补齐cloud新增用途登记，不改变生产密封/安全校验。12项定向测试通过、七个TEST源码编译通过；初始化首轮用途缺登记、INITIAL-02展示缺口、替换首轮测试旧任务ID断言失败的原件均保留，以新库正向复验关闭。不声称重新跑过整体回归。

详情见[方案审批生成执行隔离联调记录](../../开发基线/开发包/补料调度-方案审批生成执行隔离联调记录-20261026.md)，证据在outputs/plan-to-execution-20261026。M04源记录、用户权限与核准政策为显式TEST输入；M06使用正式HTTP/Controller/应用服务但非完整门户审核页登录。DIRECT免审批预登记、PERCENT/RULE/AUTO、其他策略、真实接口/设备及部署验收不由本轮替代。仅33087已核验datadir的每轮新库，无dev、真实设备或真实通知；生产源码、DDL及安全契约未改，未提交/推送/PR。

### 11.21 2026-10-26 免审批初始化/替换及PERCENT、RULE、AUTO隔离闭环

承接11.20，DIRECT_INITIAL、DIRECT_REPLACE、PERCENT、RULE-02、AUTO_CHILD-02五条链均实际执行并完成计量和资源释放，证据见[免审批与多来源任务隔离联调记录](../../开发基线/开发包/补料调度-免审批与多来源任务隔离联调记录-20261026.md)及outputs/extended-feeding-20261026。免审批先PREPARED、独立GEN发布后按原身份APPLIED；缺GEN保持原方案/任务不变，不产生SC019/SC048，任务SC003批准及独立EXEC仍分别要求。PERCENT实际GENERATE/EXECUTE均F02；RULE真实每日Worker生成且重扫不重复，SC004审核后GENERATE/EXECUTE均F03。四个方案场景新任务各实际10g、FEED1/SETTLE1、STOPPED/CONFIRMED、释放双ACK和资源FREE。

RULE首轮暴露生产创建器漏存已有额度目标。新增测试先复现，再仅为PLAN_RULE在原生成事务写入精确target_grams，待审核仍不准入，锁内重算与ExecutionSpec/任务目标比较不变；同步字段字典、计量及JSON事务契约，无DDL/表列新增或历史回填。AMOUNT/PERCENT原执行重算边界保持。

AUTO父任务真实读取异常认可0.3g、安全收尾并释放→正式异常处理HTTP及原请求重放→唯一9g子任务→独立批准签名及受控发布（重放不重复）→实际执行9g、独立FEED/SETTLE、双ACK释放。父任务ERROR_HANDLED；父子各自量账合计9.3g，资源FREE，设备/现场锁UNKNOWN保持。首轮AUTO在START调用后物理切换前读到父身份，系统正确阻断；失败原件保留。仅TEST正向设备读取增加有界真实物理交接等待，超时仍保留旧身份；不排除跨调用边界包、不改生产归属校验、不伪造反馈或时间。

本轮主类/TEST编译及54项受影响定向测试通过，0失败/跳过；红绿灯、实际事件、浏览器及最终只读SQL均保存。该54项已包含7项目标和13项HTTP用例，不重复累计；不是11.18整体回归的新结果。四个方案场景进程退出0；AUTO最终HTTP查看窗口限600秒，或通过已保存原件结束查看后关闭。完整门户登录/AOP、审批页面、其他异常/策略、全面回归及部署验收仍待相应验证；客户参数、真实接口、设备和现场条件继续按原阻塞清单。未连接dev/真实设备/真实通知，未提交、推送或创建PR。

### 11.22 2026-10-26 整体回归及完整门户任务页联调

19模块Maven主/测试编译通过；系统11714项、前端260文件3499项、四个补料独立模块357项通过，均0失败/跳过。前端首轮1项普查超时，原断言/5秒限制保持，单独及低并发整体复验关闭。隔离SQL首轮40类180项、137通过/43失败；补齐TEST消费者登记、同步正式192表断言、非链接临时目录及按类独立新库，最后HTTP故障类改用现有生产采样扫描入口且断言观察阶段禁止普通写入，全部43项关闭；180为唯一用例数，不将重跑叠加或宣称最后一次共库180全绿。无生产安全门禁、时间或DDL放宽。

完整门户基座、原登录/会话/路由/菜单及实验室任务页已实际启动；重建缺失共享库和过期SDK，修复缺失导出导致的启动失败。身份、菜单及实验室为显式TEST提供方，业务经真实Controller/守卫/SQL。修复TEST恢复供料消费者只绑定最初夹具、未共享运行时批准目录的问题，生产配置原已正确使用共享目录；相关54项定向与新增显式场景1项另有证据，不重复计入整体总数。

PORTAL_INITIAL-04实际初始化/GEN发布/SC019交付→任务生成/SC003/EXEC发布→设备启动→完整门户任务页暂停→实际停止观察→同页恢复/新段交接→HIGH/LOW→终点与计量/释放，最终10g、FEED2/SETTLE1、EXECUTED/STOPPED/CONFIRMED、双ACK释放和资源FREE。PORTAL_REPLACE-OVER实际SC048替换取消旧任务及旧审批、新任务独立执行后TEST突增触发NCS009，认可12.9g、FEED1/SETTLE1、安全释放后，门户“仅登记”异常转ERROR_HANDLED；唯一处理记录，原释放事实及量账不变。另保留暂停后取消已安全结算/释放，以及并行负载超过3秒进度期限导致的真实保护停止原件，不将后者计为正常恢复通过。

详细记录及证据分层见[整体回归与完整门户联调记录](../../开发基线/开发包/补料调度-整体回归与完整门户联调记录-20261026.md)，原件outputs/full-portal-regression-20261026。**整体回归与现有门户任务页链路通过，完整门户连续业务链仍NOT_VERIFIED：** 当前无通用M06审批列表/审核/批准操作页及路由，正式种子也无相应菜单权限；不能用TEST控制按钮或审批HTTP代替正式审批页。现有培养/反应器入口的完整读取及方案操作、真实隔离认证/网关/AOP、完整TypeScript和部署验收仍待对应验证；M06页面/菜单属于软件缺口，不归为客户现场阻塞。未自行设计审批政策或给生产授权。客户设备/参数/现场要求不变，未连接dev/真实设备/真实通知，未提交、推送或创建PR。

### 11.23 2026-10-26 M06正式审批页、冻结内容及门户审批闭环

M06 SDK/正式操作页、用途实验室、过滤分页、冻结前后快照/差异/日志、预检及审核/批准/驳回/撤回已接线；`process/approval/index`映射设置子应用`approval-requests`。权限与allowedActions取交集，阶段资格/责任分离/政策/锁内重验仍由既有M06承载。写元数据只取详情外壳；先同步持久留存原用户、UUID、版本及正文，再派发，未知结果刷新后仍只能原请求重试。M02用途候选复用真实VIEW范围，不默认选择实验室或政策。受控菜单包新增M06六行/五个既有码、双次新库安装不重复，不自动授角色权限；192表及DDL不变。

真实联调修复两处生产缺口：M03原补液审批快照前后/差异硬编码为空，现从提交时已核验M04原包及原effective不可变快照完整固定，不从现行配置重建旧单；M06活动槽查询未用生成键，已APPLIED历史错误永久阻断新申请，现按既有owner_module+active_change_key查询，未知/待生效/未决交付及并发唯一兜底保持。公共候选/方案模型复用，旧反应器入口与原请求存储兼容；存储失败不派发，合法摘要按大小写无关的同一摘要比较。

`M06_CHAIN_06`实际从真实门户M06菜单、登录/会话/路由和角色SQL投影，完成SC019页面审核→真实初始化APPLIED/生成旧待审任务→原M03服务提交替换→独立GEN发布→SC048页面审核→旧任务及旧SC003取消/只生成一条新任务→新SC003页面审核→独立逐任务EXEC签名发布→原Provider/claim/唯一START/实际TEST反馈→HIGH/LOW/终点→完整停后观察/计量/释放。最终新任务1312130597524787200为EXECUTED/STOPPED/CONFIRMED、10.000000g、FEED1/SETTLE1、无人工处理、资源FREE及独立释放ACK；初始化/替换application各一份。注入SC048真实成功响应丢失后，刷新重放保留同一actor/UUID/版本/正文并返回同一actionId，无重复application、审批决定或任务。无审核权限403、缺管理头400均留证。

监控证据导出重复编码放大已先红修复：完整页符合原786432字节限制时一次构建，超大原件拒绝/分页/游标/原始哈希保持。独立模块132/132通过，含真实回环进程重启和停止保护；前端269项定向及后续16项（部分重叠）、设置包最终类型/构建、SDK及app-lab构建通过。M03相关84项含新增8项、历史原包输入3类SQL14/14、活动槽真实SQL9/9及相关契约52/52、菜单兼容12/12分别留证，不重复累加。

保留初始交接超原3秒期限而未达完整覆盖/资源保持STOPPING的负例，及串行TEST循环积压触发保护后安全释放的负例，不计正常通过。最终TEST宿主使用真实M07MonitorActivityTask独立工作器及明确的5条传输页/100ms调度，全部原件经原游标交接；不生成替代心跳、不跳采样、不改变业务监控参数、1秒HTTP超时、3秒进度限制或首次停止期限。并行负载与现场容量仍需独立验收。

用户本轮明确选择“仅完成M06审批页，旧菜单保持”：M03/M07旧根及角色绑定不迁移，不用临时菜单/权限伪装完整培养导航。培养页新增正式候选入口代码，旧菜单起点连续导航仍NOT_VERIFIED；本轮M03上游为明确TEST来源调用真实服务生成，不能替代培养页面验收。真实SSO/网关鉴权部署、全部政策/来源/异常页面矩阵、客户接口/逐设备核准及现场投用继续分层保留。M06本体软件缺口及本轮发现的冻结快照/活动槽缺口已关闭，不宣称四阶段全部验收完成。

最终整体复核：19模块主/测试编译通过；系统既有固定清单11710发现、11694通过、16数据库条件跳过，0失败/中止；本轮私有SQL14+9项另列，不等同覆盖全部跳过项。前端最终266文件3527/3527、独立监控最终132/132通过。系统首轮执行目录错误、前端新增弹窗间距登记/Node DOM装配错误均保留原件并复验关闭，未放宽断言。补充未知原请求重试遇403仍保留、首次确定拒绝可清理、匹配回执才解除的页面真实函数测试3项先红后绿，已纳入前端整体；该分支不冒充完整浏览器权限撤销注入。最终监控预编码长度筛选仍保持原字节/游标/原件规则，正常链输入有同快路径审计，当前132项通过。

详见[本轮接线及隔离记录](../../开发基线/开发包/补料调度-M06审批门户接线与隔离验证记录-20261026.md)。原件outputs/m06-portal-chain-20261026；未连接dev/真实设备/真实通知，确认正常收尾后关闭TEST执行/监控宿主。暂未提交、推送或创建PR。


### 11.24 2026-10-26：合并远端 cloud 与兼容核验

- 合并前调度分支 `4c7116961`；远端 `cloud` 核对为 `abe46a2fc`，新增32个提交（20个普通提交、12个合并提交），保留调度分支3个独有提交。16处文本冲突按双方当前调用链合并，不覆盖暂停取消结算、统一计算公式、停止证据、资源释放及独立核准要求。
- 保留M06审批入口及旧菜单边界；合入cloud的培养运行设置、泵连接及检测链路。数据库来源清单与DDL精确表集合统一为193表，基础审批场景48条；来源/产物摘要静态一致。未执行合并后建库或操作已有数据库。
- 19模块主/测试编译通过。后端当前常规测试首次11911项发现、16项条件跳过、11843项成功、52项失败：归因为沙箱回环/文件系统限制、RC与跨拥有方Port登记未同步、检测夹具缺新增Port依赖及审计分类计数合并错误。核对正式契约、真实Mapper/事务边界后精确补登记和夹具；17个失败类定向复验128/128通过。保留其余负向门禁，不因注册表更新宣称运行验收通过。
- 前端首次282文件回归：278文件通过，4文件失败（4项断言失败及1个缺依赖套件）；本地回环权限复验2文件4/4通过，补齐已锁定splitpanes 3.1.5并核对cloud工作流模板后，6文件118/118通过。快照仍精确比较，没有删除业务或安全断言；未更改依赖声明/锁文件。未重复运行未受影响的整套测试，定向数量不可重复累加为新增覆盖。
- 安全结构静态测试19/19、反应器型号静态测试11/11及RC生成器只读检查通过。原18601个未跟踪文件中18600个字节未变；唯一变化是随已合入脚本运行重新生成的Python缓存。隔离数据库、证据、私有配置未纳入提交。
- 本次仅完成代码合并、编译与上述静态/定向验证；合并后SQL安装、HTTP/完整门户、真实认证部署和现场设备验收均未重做，原阻塞及待确认业务参数继续保留。原始日志及范围/保护核验保存在 `outputs/cloud-merge-20261026-latest/`，不提交该目录，不推送。

### 11.25 2026-10-26 cloud合入后隔离回归及门户复验

承接11.24的adf54ba1d，本轮对每次新建的193表隔离库重新验证，原始证据在outputs/post-cloud-validation-20261026，详见[cloud合入后回归与门户复验记录](../../开发基线/开发包/补料调度-cloud合入后回归与门户复验记录-20261026.md)。不连接dev、共享/生产DB、真实设备或真实通知，不迁移旧菜单，未提交/推送/PR。

按阶段接续结果：第一阶段补足实际SYSTEM竞争下续段Store旧快照问题（四个独立事务明确READ_COMMITTED），完整身份、双ACK、锁序及原命令仍必需；第二阶段完整TEST设备正常链及超量链完成，重放/故障原件保留；第三阶段新增阶段SET_SPEED前的原SPEED_PREPARED上下文/进度确认门禁，独立旧窗口先关闭，新窗口仍由新命令合格PHASE_CONFIRMED建立；另修复一页中途闭段后仍使用旧OPEN对象的投影问题，所有原件先留存，闭段后停止继续投影，不修改旧失败库或放宽H06摘要校验。第四阶段本轮仅为隔离软件及现有门户验证，真实认证、客户设备和现场启用仍保留原核准条件。

已取得：前端282文件/3747测试、独立四模块358测试、条件SQL22例均通过；41类190个唯一持久化用例首轮160通过/30失败，经4类夹具/登记修正后逐类新库复验通过，数量不重复累加。系统常规回归中间快照11898项实际执行通过、16条件项跳过；其后ACK补强与批内收尾补丁以105和24项定向测试通过，三类实际SQL复验为2/26/11例通过。Maven19模块test-compile成功，后续批内收尾Java17定向编译成功。最后代码摘要已冻结为outputs/post-cloud-validation-20261026/final-source-snapshot.json，最后一次system-final-snapshot.log发现11916项、跳过16项条件测试、实际执行11900项全部通过，0失败/中止；执行前后源码摘要无漂移，中间轮次不重复累加。

实际链：PORTAL_M06_02完成SC019初始化、SC048替换、旧任务及旧SC003取消、新SC003审核、独立GEN/EXEC发布至10g、FEED1/SETTLE1和双端释放；审核丢响应后按原请求精确重放。OVER_AMOUNT_01完成12.3g/NCS009、ERROR/CONFIRMED、安全释放，仍保留异常待处理。HTTP_PAUSE_06在最终批内关闭补丁下完成初始化/替换、独立批准、真实暂停恢复、HIGH/LOW/终点至10g、FEED2/SETTLE1及完整两资源FREE，H06与外部双ACK均有实际SQL原件，人工处理0。该末轮为HTTP，未再次打开浏览器；不得表述为最终门户浏览器全验收完成。

PORTAL_PAUSE_01/03/04及HTTP_PAUSE_05的正常场景失败如实保留：分别为证据积压保护、切速旧窗口误判、停后进度保护及闭段后覆盖摘要变化。PORTAL_PAUSE_02虽最终安全正常释放，但恢复HTTP503不算页面全程通过。后续新库正向复验只关闭对应根因，不改旧失败记录。重型构建与回归并发期间的延迟不可通过放宽首次期限或采样质量解决；隔离宿主页批量20仅为TEST配置，不作为生产默认值。

仍待区分：最后补丁后的完整浏览器终态、三段/SYSTEM抖动/PERCENT/RULE/AUTO/免审批及DB/JVM故障的最后快照整链复验，不能由本轮单元/SQL证据代替。真实SSO/网关、部署、逐设备参数/身份/映射/时间质量/实际反馈和现场释放取证仍属外部条件；旧菜单未授权迁移不计为已完成连续门户导航。未确认业务与现场参数继续阻断，不补默认值。


11.25最后补记：最后快照的M07MonitorActivityPersistenceIT在新库再次11/11通过，OVER_AMOUNT_02也在新33088库实际12.3g/NCS009、FEED1/SETTLE1、ERROR/STOPPED/CONFIRMED、完整资源FREE及双端释放ACK，进程退出0。HTTP_PAUSE_06为10g正常终态和FEED2/SETTLE1，同样有完整释放原件。源码摘要无漂移、diff检查通过。本轮前端测试服务和代理已关闭，未再新开浏览器；未操作用户原5839页面。最后浏览器终态与其他未重跑整链仍按上述待验证项保留，本轮不宣称全部四阶段已验收。

2026-10-29 复验补记：在合入 cloud 的 d584ced48 及既有未提交工作区修改上，19 模块 test-compile 成功，续段、切速交接、闭段投影及相关定向单元测试 234/234 通过（含 2 项本次另行保留的 M05 隔离目标测试）。发现空库初始化的结束培养种子与节点非空及全局唯一约束冲突；修复为小试、中试共用 end_culture 一级节点、按二级流程实验室类型区分，保持原约束及各自步骤。三个全新隔离库均原样安装正式 01/02/03 并核验 193 表、48 场景；续段 SYSTEM 竞争 2/2、监控上下文 26/26、监控活动 11/11 通过。共享节点 M04 定向单元 23/23、节点选择 2/2，实际隔离 SQL 核验两种实验室可选节点及四组子流程；未重跑完整门户、真实设备和现场验收。证据位于 outputs/mysql-scheduler-recheck-1793239513389；未连接 dev 或共享库。

### 11.28 继电器范围调整（2026-10-28）

用户最新要求：继电器只按客户开关 HTTP 接口接入人工开启/关闭；移除此方案此前设计的继电器映射确认、M07 资源仲裁、独立状态读取及自动释放逻辑。相关历史验证只说明当时的实验，不再代表当前实现。设备所属实验室权限、原有管理守卫与操作审计保留；开启直接操作，关闭先提示确认，接口受理不等同独立物理状态。补料泵的调度、停止与释放规则不因本次调整改变。

本次验证：前端定向测试 45/45；继电器客户接口假服务测试 7/7；专用隔离 MySQL 与假服务的权限、审计、重放和调用链测试 1/1；通讯配置定向测试 30/30；补料安全接口及网关测试分别为 106/106 和 80/80。后端 19 模块 `test-compile` 通过，因现存生成文件只读跳过了主资源复制，因此不等于完整常规构建。未进行完整浏览器、真实客户服务及设备联调；服务地址与超时须由部署提供，现场设备参数仍须确认。
