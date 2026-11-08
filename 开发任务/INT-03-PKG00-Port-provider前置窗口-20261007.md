# INT-03｜PKG-00 / Port Provider 前置窗口交付报告（2026-10-07）

- 执行人：work9（Integration Owner，唯一执行人）｜复审：work5（只读）
- 基线：`HEAD = origin/cloud = 64b6c39c`（INT-02 已入库），`0 0`，工作区开工时干净
- 层级声明：**CONTRACT_TESTED**（适配器行为契约 + 登记面门禁；未起服务、未连库、未发真实请求）
- 本批定位：把"大家都卡住的跨模块事实源"集中打通——**落码 1 个最高杠杆 provider（W1），其余全部按 A/B/C 归类登记**，不把 provider 存在冒充接口完成。

## 0. 复审返工记录（work5 P1，2026-10-07）

work5 复审结论 `PASS_WITH_RISK`，P1：`BENCH_CONTROLLER` 白名单登记了 `controller_no`/`connection_name`，但原实现复用的 `selectControllerCapabilitiesByConnectionId`（M02-254 能力窄列投影，XML 实测只有 connection_id/lab_id/del_flag + 能力五列）不带这两列，导致登记路径恒 null（`connection_name` DDL NOT NULL，不能登记后返回空）。

**修法（work5 方案 1，已落地）**：`BENCH_CONTROLLER` 分支改用现成整行查询 `selectLabBenchReactorControllerByConnectionId`（XML 走 `LabBenchReactorControllerDetailVo` resultMap，实测真实带出 `controller_no`/`connection_name` 全行），零新增 SQL、零 DDL/签名/skeleton/注册表/前端改动。测试补强：BENCH_CONTROLLER 正常路径显式断言 `controller_no`="CT-001"、`connection_name`="1号台架主控" 非空等值（钉桩防回退），`stubRow` 与两处 `verify` 同步换用整行方法；其余断言（revision/labId/404/409/400）原样保留。ANALYZER/BENCH_CONTROLLER 的 lab 不匹配代表用例未新增（404 同码同文案语义已由 BENCH_REACTOR 代表用例钉住，属共享分支，不重复登记）。

### 0.1 第二次返工（work5 复核 FAIL → 总控裁决方案 B，已落地）

work5 对 P1 返工复核 **FAIL**：整行查询方向正确，但 BENCH_CONTROLLER 白名单仍登记了能力五列（`mfc_count`/`threshold_weight_g`/`temperature_control`/`weight_control`/`pressure_control`），而 `selectLabBenchReactorControllerByConnectionId` 的 SELECT（含 DetailVo include 片段）列面**根本不供应这五列**——一手核对片段列面：balance_id/connection_id/connection_name/controller_no/create_by/create_time/del_flag/lab_id/reactor_id/remark/status/update_by/update_time，无任何能力列。

**总控裁决·方案 B（已落地）**：保留整行查询，BENCH_CONTROLLER 白名单**收窄为 `controller_no` / `connection_name` 两条**身份列；能力五列不在 INT-03 登记范围（当前整行查询不供应），后续如消费方需要，另开 CAP-I01 字段路径扩展或专用投影窗口。

**硬规则（本批起生效并钉成静态门禁）**：**白名单必须等于所选语句能供应的字段集合**。新增静态钉桩用例 `benchControllerWhitelistIsCoveredByTheSuppliedStatement`：从适配器源码提取 BENCH_CONTROLLER 分支登记的路径集合（恰为两条），逐一对该语句的 SELECT 列面（含 include 片段解析）核对全部被供应；同时断言适配器已不再引用已弃用的能力窄列投影。`mfc_count` 成功断言已随白名单收窄删除，身份两列等值断言保留。

## 1. 已落码：W1 `M02DeviceConfigurationAdapter`（CAP-I01，IMPLEMENTED + CONTRACT_TESTED）

| 项 | 内容 |
|---|---|
| 签名 | `m02.DeviceConfigurationPort#resolveDeviceConfiguration(DeviceConfigurationQuery)`——PKG-00 §6.2 冻结签名，**零签名变更**（`PortSignatureSnapshotTest` 原值通过） |
| 行为 | 按 `deviceRef{kind,id,labId}` 路由九张 M02 实例权威表（`lab_id bigint NOT NULL`，01-完整建表.sql 实测）做归属判决：不存在与「不属于声明 labId」统一 404 NOT_FOUND 同文案（87号 §1.3，不泄露归属差异）；事实源异常 503；入参形状与未知字段路径 400；`expectedManagementRevision` 非空即比对、不符 409 |
| 种类→表 | BENCH_REACTOR→lab_bench_reactor、INTEGRATED_REACTOR→lab_integrated_reactor、CONTAINER→lab_culture_container、FLOOR_SCALE→lab_floor_scale、DETECTOR→lab_detector、PERISTALTIC_PUMP→lab_peristaltic_pump、AIR_PUMP→lab_air_pump、**ANALYZER→lab_downstream_device**（依据其 `device_type` 列注释"其余为 dev_analyzer_model.device_type"）、BENCH_CONTROLLER→lab_bench_reactor_controller |
| 零新增 SQL | 全部复用各实例 Mapper 既有按 ID 只读语句（BENCH_CONTROLLER 用整行查询 `selectLabBenchReactorControllerByConnectionId`，能力窄列投影已弃用；见 §0/§0.1）；管理修订与守卫同源（`SysManagementRevisionMapper.selectCurrentRevision`） |
| 白名单 | 契约 §3"拥有方登记的字段路径白名单"——登记方即本提供方；**初版只登记各权威表实例列（路径名=基线列名，source=INSTANCE，unit=null 不伪造）**；ready=归属成立（值允许 null，未知历史值不补 0/false） |
| 解锁 | M09 DEVICE 首建 W3（守卫回调内追归属判决）前置就绪；M09 仍禁自推 kind→表（W4 边界由 `frozenDeviceKindDomainIsWiderThanThePinnedDeviceTables` 继续钉住） |
| 契约测试 | `M02DeviceConfigurationAdapterContractTest` 9 例（含二次返工新增的 BENCH_CONTROLLER 白名单-语句供应静态钉桩）：归属 OK 投影保序 / 归属不符与不存在同 404 同文案 / ANALYZER、BENCH_CONTROLLER 路由与身份列等值 / 未知路径 400 / requiredFields 形状（空、超 100、空白、去重）/ 修订冲突 409 与空值浏览 / 非法形状零 Mapper 触达 / 九种类全路由 / 白名单-语句供应相等钉桩 |

## 2. 同批登记面翻正（3 个测试 + 1 处 javadoc，全部因本批改动而必然漂移）

| 文件 | 翻正 |
|---|---|
| `FullSystemSkeletonGateTest`（m02 Mapper 白名单） | `PORT_ADAPTER_ALLOWED_MAPPERS["m02"]` 扩容 10 个 Mapper（九实例表 + SysManagementRevisionMapper），注释登记依据；禁令面（@Transactional/Async/Redis/RestTemplate/TokenService/@Log）适配器零命中 |
| `M09DeviceLabFactSourceContractTest` | `capI01…ButHasNoProvider` → `…AndInt03ProvidesTheAdapter`：零提供方断言翻正为"提供方恰为 M02 一个"；DeviceRef 形状、PKG-00 签名行、种类值域 9 值、W4 边界断言全部保留 |
| `M05WorkbenchAndReportBlockedEvidenceContractTest` | 六 Port 零实现断言改为：DeviceConfigurationPort 恰一（M02 适配器）+ 其余五 Port 仍零；M05-007 族阻塞不受影响（其阻塞是 queue_revision/position_evidence 读出口，与 CAP-I01 无关） |
| `CultureBindingFactsAdapter`（1 行 javadoc） | "DeviceConfigurationPort 全仓零实现"陈述因本批失真，更正为"归属判决已落地、本链路所需通道/配置版本核验字段不在其初版白名单内"；P-6 缺口实质不变 |

## 3. 逐类核查结论（派发 §三五个对象全覆盖）

### 3.1 M02/M09 DEVICE 首建
**答案：两者都缺，且本批补掉了 provider 这一环。** 缺 provider（已由 W1 落地）+ 缺 CAP-I01 归属判决**文档条款**（W2，87号 §1.2 明确属设计/总控文档窗口——失败码口径 §1.3 已在码内实现，W2 是把行为写进契约 §4）。M09 侧 W3/W4 维持"provider 就绪前不得落码"判定（87号：Body labId 自证=伪接线）。

### 3.2 M05/M07 检测结果事实源（`DetectionResultPort` DET-I06/I07）
M07 两个应用服务确以 `@Autowired(required=false)` 注入消费，provider 缺位期间恒 503。**A-类可行但语义重**：三方法（结果修订/合格结果分页/有效结果判定）承载 M05 签批域语义（sign_chain_state、更正链 replacedBy），需 M05 侧新 Mapper 查询与语义核对，不宜在本批半做——**登记为下一 Port 窗口首选**（A 类，由 M05 owner 或下批 integration 执行）。

### 3.3 M07 十个零 provider Port（work4 清单）
- **B 类（PKG-00 载体窗口）**：`RunEventPublisherPort`（R-1：`RunEvent` 缺 labId/cultureId/objectKind/objectId/objectVersion/actorUserId/requestId 载体位 + eventId String↔BIGINT 类型错配，不可派生 6 列）、`ExecutionSamplePort`（R-2：缺 segmentId/observedAt/stage/quality + 适配器身份，且 `run_execution_sample` 零写语句）。
- **C 类（owner 裁决）**：CultureExecutionBarrier/CultureInputBarrier/CultureRuntime（M03-013/032/033 消费，屏障与生效语义属 M07 owner）、PlanGeneration/RunDeadlineFacts/DetectionReservation/DetectionResultChange（分别需代次裁决 R-7、M05 事实源、执行域范围裁决）、m07.ApprovalDecisionPort（M06 回投契约）。

### 3.4 M03/M09 九码（INT-01 之后真正剩下什么）
操作码与审计策略已就位（INT-01）；**剩余=纯实现层**：M03-004/005 契约方言写语句重写（legacy 直收/CAS 谓词）、M03-013/032/033 候选写 DAO（U5）+ M07 屏障 Port（U3）、M03-011 的 m02 四 Port（U3）、M03-027 按 targetType 的 member 写链、M09-011/013 四条契约语句+台账绑定（U4）+ INT02 provider（D-6）。**无一项再被注册表挡住**。

### 3.5 M06-015 owner audit
确需新跨模块 Port（三侧端口目录实测无审计投影口，89号 §6）。**未落码**，PKG-00 签名窗口建议见 §5。

## 4. 验证（全部 EXIT=0，JDK Dragonwell 17.0.19）

| # | 范围 | 结果 |
|---|---|---|
| 1 | 单类 `M02DeviceConfigurationAdapterContractTest` | **8 / 0 / 0 / 0** |
| 2 | M02+M05+M09 三套件 + 五共享门禁 | **1494 / 0 / 0 / 0**（含翻正后的 `PortSignatureSnapshotTest` 6 例原值通过＝零签名变更证据） |
| 3 | 全模块 `mvn -o -pl futurefab-modules/futurefab-system -am test` | **3616 / 0 / 0 / 0**（INT-02 tip 3608 + 新增 8 例，无未解释差值） |

## 5. PKG-00 签名窗口建议（本批未落码，待总控开窗）

1. **SK-9 新 Port（M06-015）**：建议 `m06.ApprovalOwnerAuditProjectionPort#projectOwnerAuditReceipts(OwnerAuditProjectionQuery): List<OwnerAuditProjectionView>`；Query{ownerModule, sourceRequestId, requestId?}，View{ownerModule, sourceRequestId, operationCode, receiptSnapshot, occurredAt}（字段以窗口冻结为准）；提供方=M03/M07/M09 owner，消费方=M06-015。
2. **R-1**：`RunEvent` 补 labId/cultureId/objectKind/objectId/objectVersion/actorUserId/requestId；eventId String→BIGINT 对齐（或列改造，窗口二选一）。
3. **R-2**：`ExecutionSampleCommand` 补 segmentId/observedAt/stage/quality + 适配器身份；sourceSequence long→VARCHAR(128)。
4. **U1'**：INT02 的 M09→M06 交付方向补入冻结 Port 总表（纯登记不改签名）。
5. **SK-6**：`ReplaceUserLabsCommand` 补 actorUserId/operation 冻结行。

## 6. 遗留决策清单（需总控/设计，本批未自裁）

| # | 事项 | 状态 |
|---|---|---|
| 1 | W2：CAP-I01 归属判决写入契约 §4（行为已按 87号 §1.3 落码，缺文档条款） | BLOCKED_DESIGN（文档窗口） |
| 2 | CAP-I01 白名单初版口径：列名路径 + INSTANCE 来源 + ready=归属成立；确认前 M09 W3 传参须用本白名单 | 待总控/设计确认 |
| 3 | DetectionResultPort provider（解锁 M07 恒 503 两处） | A 类，登记为下一 Port 窗口首选 |
| 4 | R-1/R-2/R-3/R-7、D-1/D-6/D-8、SK-1~SK-10 | 沿总盘点登记，未变 |

## 7. 状态与 NOT_VERIFIED

- 本批唯一接口级产出=W1 provider：**IMPLEMENTED + CONTRACT_TESTED**；`DeviceConfigurationPort` 的消费方 M09-014/011/013 等**全部维持 501/BLOCKED_*，不因 provider 存在升档**。
- 其余登记项：BLOCKED_DESIGN（W2、R-1/R-2 载体、M05 复合口径）/ BLOCKED_EXTERNAL（DeviceCommand、执行器域）/ BLOCKED_DATA（候选事实源缺数据）/ BLOCKED_MENU（种子已由 INT-02 部分解除，run 族页面仍缺）/ NOT_VERIFIED（全部）。
- SQL 目标库执行 / HTTP / 浏览器 / Nacos / 网关 / 外部系统：**NOT_VERIFIED**。
