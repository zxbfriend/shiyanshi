# INT-04 DetectionResultPort provider 前置窗口（2026-10-07）

- 执行人：work1（Integration Owner，接替 work9）
- 基线：`c45e06ef`（origin/cloud，开工检查 ahead/behind `0 0`，工作区干净）
- 本批性质：只提供 M05 侧 DET-I06/DET-I07 provider 前置，不改 M07 接口状态，不翻 skeleton wired
- 复审归属：交 work5 只读复审；PASS 前未 add / commit / push

## 1. 三个方法的实现状态

| Port 方法 | 契约编号 | 状态 | 说明 |
| --- | --- | --- | --- |
| `getResultRevision(ResultRevisionQuery)` | DET-I06 | IMPLEMENTED + CONTRACT_TESTED | 只按 `resultId + object_version` 精确命中；未命中即 `RESULT_PROJECTION_UNAVAILABLE`，绝不回退最新（有 never-用例钉住） |
| `queryEligibleResults(EligibleResultQuery)` | DET-I07 方法一 | IMPLEMENTED + CONTRACT_TESTED | 键集游标（`result_id` 升序）多取一条实测 `hasMore`；无对象范围或 `limit` 越界一律 `INPUT_INVALID` |
| `resolveEffectiveResult(EffectiveResultQuery)` | DET-I07 方法二 | IMPLEMENTED + CONTRACT_TESTED | `revision` 缺省解析当前有效版本；被替换版本输出 `effective=false + replacedBy`，不静默丢弃 |

提供方实现类：`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/port/m05/M05DetectionResultAdapter.java`（`@Component`，构造注入，只读、无事务、无外部副作用）。

## 2. 使用的 M05 表 / Mapper / 事实

只访问 M05 自有四表，未新增任何写入语句：

- `det_result`：`object_version`（当前有效版本）、`del_flag`、`result_status`、`completion_observed_at`、`sign_chain_state`、`active_sign_id`
- `det_result_revision`：`result_id + object_version` 唯一不可变行、`content_snapshot`（内含 `schemaVersion`/`items`/`contentHash`）
- `det_sample`：`culture_id`、`sample_id`、`del_flag`、`current_result_id`（样品当前结果谓词）
- `det_result_item`：`item_code`、`is_voided`、`item_outcome`、`numeric_value`、`unit`（单项合格谓词）

新增 M05 自有窄读口（只读，逐语句可检）：

- `mapper/M05DetectionResultFactsMapper.java`：`selectRevisionFacts` / `selectCurrentRevisionFacts` / `selectEligibleRevisions`
- `resources/mapper/detect/M05DetectionResultFactsMapper.xml`
- `domain/row/m05/ResultVersionFactsRow.java`

字段口径出处：

- `schemaVersion`：取自 `content_snapshot` 的 `schemaVersion`，只接受 1/2，核验逻辑沿用 M05 读侧既有 `ResultRevisionStore#validate` 与 `ResultRevisionPublisher#event`；该列不是物理列，基线 DDL 亦无。
- `value`：直接外发 `content_snapshot` 原文，不重排不改写。
- `observedAt`：取 `det_result.completion_observed_at`，按接收包 DATETIME(3) 归一 UTC 处理（`01-完整建表.sql` 列注释"本系统首次观测可信设备结束的时点"；同包 `source_observed_at` 注释"可信源发生时间归一 UTC；未知时区不得填"）；该列 NULL 时失败关闭，不以 `created_at`/`update_time` 或时区推断补位。
- `irreversible`：`sign_chain_state='VERIFIED'` 且 `active_sign_id` 非空且状态 ∈ {signed, reviewed}（即基线 `ck_m05_sign_ptr_state` 不变式）。
- 合格性词表：`result_status ∈ {tested, uploaded, signed, reviewed}` 中的四值取自契约 §6"M07 残糖确认用途补充"，作废/删除/异常/超时/取消项由 SQL 谓词排除；新鲜度与业务日策略属调用方核准规则，本 Port 不内置（`EligibleResultQuery` 冻结字段亦无 `asOf`/freshness，M07 侧以 `observedAt` 自行归日）。

## 3. 仍跳过项与原因

1. **不做调用者授权**：Port 文档与本批工单均规定授权属消费方；provider 未引入数据范围判定。M07 两个消费方保留其自身 `resolveScope` 与守卫判定。
2. **不输出候选"排除原因"**：契约 §2 期望 `queryEligibleResults` 输出候选 ID/版本及排除原因，但 PKG-00 冻结的 `EligibleResultSet` 无对应字段。本批不擅自扩模型，不合格项只在 SQL 侧排除，模型缺口登记为遗留裁决。
3. **不冻结 `det_result_revision` 的写入面**：全仓 `insertRevision` 只有两处可达路径，实际业务写入仅 `DetResultCorrectionApplicationServiceImpl:512`（`CORRECTION_APPROVED`）；`INITIAL`/`BASELINE` 版本写入尚未接线。因此提供方是**结构解锁**，真实库中候选集合在版本写入接线前大概率为空——这是 `BLOCKED_DATA`，不是本批可用"返回可变当前值"绕过的缺口。
4. **不改 M07-019 的 503**：`RunMeasurementApplicationApplicationServiceImpl` 在 Port 已注入后仍无条件 `DEPENDENCY_UNAVAILABLE`（DET-I06 视图字段不足以冻结确认源快照，缺 itemId/shortName/unit/sampleNo）。属跨模块契约缺口，本批只以测试钉住该 503 不被顺手删除或放宽。
5. **不精确化 `irreversible` 的"运行引用"支**：M05 无法在不直读 M07 `run_confirmation` 的前提下证明"已被运行引用"，故该布尔按已证实下界输出（可能低估），登记为遗留裁决。
6. **空白 `detectionItemCode` 语义**：契约只写"为空时返回对象范围内全部合格候选"，未区分空白串。本批把纯空白视为缺省（返回全部），不做猜测性报错，登记为实现解释项。

## 4. 是否改了签名 / SQL 基线 / skeleton / 共享注册表 / 前端

| 禁改面 | 结论 | 证据 |
| --- | --- | --- |
| Port 物理签名 | 未改 | `PortSignatureSnapshotTest` 6/0/0 通过；新增反射用例断言三方法签名与 `DetectionResultPort.class.getDeclaredMethods().length == 3` |
| PKG-00 文档 | 未改 | `git status --short -- docs` 除本交付文件外为空 |
| SQL 开发基线 | 未改 | `docs/开发基线/` 无变更；只新增 mapper XML 只读 SELECT |
| skeleton wired | 未改 | `contract/skeleton-m*.json` 全部未变更；新增用例断言任何骨架清单都不含 `M05DetectionResultAdapter` / `DetectionResultPort` |
| 共享注册表（INT-01 守卫审计操作码） | 未改 | `ManagementOperationTest` 3/0/0、`AuditPolicyRegistryTest` 8/0/0 未改动即通过 |
| 前端 | 未改 | `futurefab-ui/` 无变更 |
| M07 接口状态 | 未改 | 两个 M07 消费方源码零改动（本批 diff 不含 `application/m07`） |
| 跨模块 Mapper | 未读 | 新增用例断言适配器 Mapper 导入集合恰为 `["M05DetectionResultFactsMapper"]` |

门禁扩容（唯一门禁改动，窄扩容，总规则不变）：`FullSystemSkeletonGateTest`
- `PORT_ADAPTER_MODULES` 增 `"m05"`（授权出处：2026-10-07 INT-04 批次）
- `PORT_ADAPTER_ALLOWED_MAPPERS` 增 `"m05" -> ["M05DetectionResultFactsMapper"]`
- 未登记模块/M08/其他 Mapper 越界仍逐条检出；同批把 `M05WorkbenchAndReportBlockedEvidenceContractTest` 中 `DetectionResultPort` 的"零 provider"断言翻正为"恰好 M05 一个"，其余四个零实现 Port 与 M07 消费方证据断言原样保留。

## 5. M07 消费方状态

- M07-015 糖耗候选浏览：提供方已存在，`detectionResultPort == null` 的 503 短路在生产 Spring 上下文下不再触发；但本批未做 HTTP/浏览器验证，状态维持 **NOT_VERIFIED**（真实数据还受 §3.3 版本写入未接线限制）。
- M07-018/M07-019 确认写口：M05 源分支仍为 **503 依赖阻塞**（契约字段缺口），维持原登记；本批以测试钉住不得删除。
- 两个消费方均未因 provider 存在而被标记 wired 或完成。

## 6. 测试结果（分层）

| 命令 | 结果 |
| --- | --- |
| `-Dtest=M05DetectionResultAdapterContractTest`（RED，桩实现） | Tests run 20 / Failures 7 / Errors 9 / BUILD FAILURE（全部因提供方未实现、m05 未入白名单、窄读口无 select） |
| `-Dtest=M05DetectionResultAdapterContractTest`（GREEN） | Tests run 21 / 0 / 0 |
| `-Dtest=M05DetectionResultAdapterContractTest,M05WorkbenchAndReportBlockedEvidenceContractTest,FullSystemSkeletonGateTest,PortSignatureSnapshotTest` | Tests run 54 / Failures 0 / Errors 0 / Skipped 0 / BUILD SUCCESS |
| `-Dtest=ManagementGuardedWriteArchTest,ManagementOperationTest,AuditPolicyRegistryTest,M05*,M07*` | Tests run 666 / Failures 0 / Errors 0 / Skipped 0 / BUILD SUCCESS |
| `mvn -o -pl futurefab-modules/futurefab-system -am test`（全模块） | **Tests run 3638 / Failures 0 / Errors 0 / Skipped 0 / BUILD SUCCESS**（Total time 47s） |

命令形态：`mvn -o -pl futurefab-modules/futurefab-system -am test -Dtest="..." -Dsurefire.failIfNoSpecifiedTests=false`。

归因说明：`c45e06ef` 基线全模块为 3617 例（INT-04 复审工单确认口径），本批新增 21 例（新契约测试类），终值 3638 例，增量已闭合，无未解释增量。

达成的最高验证层级：**CONTRACT_TESTED（含源级 SQL 静态核验）**。

## 7. NOT_VERIFIED 清单

- `NOT_VERIFIED`：SQL 在目标数据库执行（本模块契约测试全程不连库，窄读 SQL 只有源级核验；列名/ resultMap 构造映射未运行时验证）
- `NOT_VERIFIED`：Spring 真实上下文装配（provider 是否被两个 M07 消费方按 `@Autowired(required=false)` 成功注入）
- `NOT_VERIFIED`：HTTP 联调（M07-015 候选读口端到端）
- `NOT_VERIFIED`：浏览器验收（无任何 UI 变更，亦未做页面操作）
- `NOT_VERIFIED`：Nacos 配置发布 / 网关重载 / 服务重启（本批无配置改动，运行环境未动）
- `BLOCKED_DATA`：`det_result_revision` 的 `INITIAL`/`BASELINE` 写入未接线，真实候选数据大概率为空
- `BLOCKED_EXTERNAL`：无（本批不涉设备或外部系统）

## 8. 遗留决策清单

| 级别 | 事项 | 需要谁裁决 |
| --- | --- | --- |
| P1 | `observedAt` 采用 `completion_observed_at` 并归一 UTC 的口径是否批准（依据为列注释与同包 `source_observed_at`/`ResultRevisionPublisher` 先例，非逐字条文） | 总控 / M05 文档窗口 |
| P1 | `irreversible` 的"已被运行引用"一支在 M05 侧不可证：接受下界输出，还是新增 M07→M05 反查 Port，或改契约字段语义 | 总控 |
| P1 | `getResultRevision` 对已 `del_flag='2'` 结果的历史读取是否允许（本批按 §4"精确旧版本保留"允许，由消费方授权决定可见性） | 总控 / 安全 |
| P2 | 契约 §2 要求候选输出"排除原因"，`EligibleResultSet` 无字段：扩模型还是收敛契约文字 | 文档窗口 |
| P2 | `det_result_revision` 版本写入（`INITIAL`/`BASELINE`）未接线，属 M05 侧独立缺口，需排期 | 总控排期 |
| P2 | `DetResultCorrectionApplicationServiceImpl:512` 写入的 `eventKind=CORRECTION_APPROVED` 不在 `ResultRevisionStore.EVENTS` 词表内（该词表含 `CORRECTION_APPLIED`）；本批适配器未沿用该词表校验以免误杀既有行，但两处口径不一致属同源缺陷 | M05 缺陷窗口（本批未修，仅登记） |
| P2 | 空白 `detectionItemCode` 视为缺省的实现解释 | 文档窗口 |
| P2 | INT-03 遗留四项继续有效：ANALYZER 未过滤 `device_type`、provider 不做调用者授权、`SysManagementRevisionMapper` 直读收敛、W2 CAP-I01 归属判决文档条款 | 后续窗口 |
