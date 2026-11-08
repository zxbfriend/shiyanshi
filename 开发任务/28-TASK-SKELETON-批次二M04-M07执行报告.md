# 28-TASK-SKELETON 批次二（M04-M07）执行报告

任务包：全系统接口契约骨架补齐（TASK-SYS-SKELETON）批次二。
范围：M04 工艺与方案、M05 检测与数据签批、M06 流程审批、M07 补液运行与任务执行；M08 排除不变。
执行日期：2026-09-20。

## 1. 结果总览

| 模块 | 冻结接口 | 骨架落码 | blocked（登记） | 门禁条目=预期 | 类型类 | 应用服务/Impl | Controller |
|---|---|---|---|---|---|---|---|
| M04 | 23 | 16 | 7 | 16=16 ✅ | 187（dto16+vo171） | 1/1 | 1（新） |
| M05 | 64 | 58 | 6 | 58=58 ✅ | 120（dto48+vo72） | 10/10 | 10（8 改写+2 新） |
| M06 | 15 | 15 | 0 | 15=15 ✅ | 74（dto15+vo59） | 6/6 | 4（全新） |
| M07 | 35 | 33 | 2 | 33=33 ✅ | 127（dto33+vo94） | 8/8 | 8（全新，controller/run/） |
| 合计 | 137 | 122 | 15 | 全部命中 | 508 | 25/25 | 23 |

骨架层：Controller → 冻结 Request DTO/Command/Query → ApplicationService 接口 → Impl → 编号
`SkeletonNotImplementedException(contractId)` HTTP 501。本批次未实现任何真实 CRUD、业务编排、Mapper SQL、
Redis 写入或外部调用；管理写入口未接守卫执行器/审计意图/回执（零字段 Impl，仅显式 501）。

旧 Service 落点重定向 85 条（`service.I*Service`/`application.*` 冻结链 → `service.application.m0x.*ApplicationService`，
完整映射见 `_tmp_skelgen/gen/report.json` redirected 列）。

## 2. blocked 登记（15 条，登记后继续，未停留）

### M04-017～M04-023（7 条，Workflow 旧线）
原因：canonical 路由带 `/system` 服务前缀，与冻结 Controller 前缀（`/process/workflow`、`/lab/lab`）不一致；
且 `WorkflowNodeListVo`/`WorkflowNodeDetailVo`/`LabWorkflowConfigVo` 形状未逐项冻结；M04-019 brief/spec 请求类名冲突
（WorkflowNodeUpdateRequest vs WfInput）。待路由前缀裁决与 Vo 冻结后回补。

### M05（6 条，S1 阶段已登记，本批次维持）
- M05-006：BLOCKED_FIELD — columns/displayRows 叶子字段未在设计冻结。
- M05-024：BLOCKED_FIELD — exceptionType 取值域未枚举。
- M05-035/036/037：BLOCKED_COMPAT — COMPAT 入口整改口径未冻结（报告作业模式/导出模式/打印登记）。
- M05-064：BLOCKED_FIELD — 全局审计日志过滤叶子未逐项冻结。

### M07（2 条，S1 阶段已登记，本批次维持）
- M07-003：BLOCKED_FIELD — TaskCandidateResourceView 候选结构无字段级权威。
- M07-016：BLOCKED_FIELD — CultureWithdrawalResult 回执字段未逐字段枚举。

blocked 数与门禁锚点核对：各模块 `entries = brief − blocked` 程序化命中（skeleton-m04..m07.json expectedCount 同源）。

## 3. 生成期规范化登记（不改冻结事实，逐项可追溯）

### 3.1 路径变量绑定字段补齐（37 条）
canonical 路由占位符在 spec 提取时缺对应 request 字段 → 按路由补 `String`（`*Ids` 补 `List<String>`，Controller
以 splitCsv 绑定），字段 note 登记。M04×4（templateId）、M05×3（resultItemIds/signIds/assigneeIds）、
M06×5（id）、M07×25（id/stepId）。全清单：`_tmp_skelgen/gen/report.json` notes.autoAdded。

### 3.2 联合/未冻结形状类型 → Object（11 条）
- M04 `content/effectiveParameters/effectiveInput`：`SamplingContent|PumpSpeedContent|ConfigContent|PerfusionContent|AutoControlContent|FeedingContent`
  等联合（设计 04 §L1176 InputContent=可写叶子投影，根结构随类型而异）→ Object，成员记入 note。
- M04-011 `TemplateListRow.columns`：六类 Columns 联合 → Object。
- M05 `DetApprovalRecordDetailVo.result`（M05-019/M05-062）：`ResultRowView` 设计仅文字描述结果行、未逐项冻结 → Object。

### 3.3 同名类跨契约统一（19 条）
- 字段集并集（先出现字段保留原类型）：M05 DetApprovalRecordQuery、DetWorkbenchActionRequest、
  ResultCorrectionMutationResult、WorkbenchSubmitResponse、DetApprovalRecordVo、ReportJobView；M06 ReconciliationMutationResult；
  M07 ResourceSnapshot、MediumRef、ConsumableRef、MeasurementPolicy、StabilityCriteria、StopCriteria、CalibrationCriteria、
  ConfirmationView、Reading、WorkflowStepView。
- 字段类型冲突统一 Object：M05 `WorkbenchSampleMutationResult.outcome`（String/DeleteOutcome/ClearOutcome 跨契约不一致，
  DeleteOutcome/ClearOutcome 枚举仍独立生成）。

### 3.4 枚举取值表合并（2 条）
- BatchItemStatus（M07-023 处）→ APPLIED|PENDING|REJECTED|UNKNOWN|SUCCEEDED|FAILED|SKIPPED。
- SegmentState（M07-031 处）→ OPEN|CLOSED|UNKNOWN|ACTIVE|SEALED|VOID。
业务实现阶段应按最终裁决收窄取值域；骨架保留并集不虚构。

### 3.5 Java 关键字字段改名（3 条）
M04-002 `ConfigLoops.do/PidSet.do/PerfLoops.do` → `doValue`（`do` 为保留字；线上传输名保持 "do"，
业务实现阶段以 @JsonProperty 回填）。

### 3.6 共享/嵌套类型规范化
- `Issue`（设计 05 §L319 冻结 `{code,path,message}`）→ 挂载于 M05-015，供 M05-015/021/025/027/031/047 的
  issues/exclusions 引用共用（vo.m05 单类）。
- 嵌套冻结类 `DetWorkbenchOptionsVo.Option`（M05-018）→ 顶层扁平类 `DetWorkbenchOptionsVoOption`（Java 不允许点号类名，note 保留原名）。

### 3.7 与存量代码的编译级冲突处理（M05 集中）
- 同简名异包 import 冲突（17 个入口）：旧 Det*Controller 已 import `domain.dto.X` 同名类型，生成方法签名的请求类型
  改用全限定名并去除生成侧 single-type-import（否则 javac「引用不明确」）。清单：report.json notes collisionFqcn
  （M05-008/010/011/015/021/022/023/025/026/039/040/041/042/043/044/047/061）。
- 同形旧入口覆盖（1 条）：M05-027 `DELETE /detect/detresult/{resultId}` 与旧 `remove DELETE /{resultIds}`
  映射模板同形（占位符名不同）→ 生成入口覆盖旧方法块，否则 Spring Ambiguous mapping（MockMvc 门禁实测先以 200 暴露、
  修正后 501 通过）。

## 4. 生成器缺陷修复（本批次内，均已反例证实）

1. 联合/未冻结类型未降级 → 编译非法（真实编译失败反例后修复）。
2. 关键字字段名 → 编译失败反例（PidSet `private PidValues do;`）。
3. 点号嵌套类名 → 编译失败反例（`DetWorkbenchOptionsVo.Option.java`）。
4. 新 Controller 多服务接线缺失 → 编译失败反例（ApprovalReconciliationController 等「找不到符号」）。
5. 同简名 import 冲突 → 编译失败反例（DetWorkbenchController 等「引用不明确」）。
6. 同形旧路由并存 → M05 checkHttp501 真实 HTTP 违例捕获（M05-027 expected 501 but was 200），修复后转绿。
以上均为真实检出，非零命中预锁。

## 5. 验证分层

| 层级 | 结果 |
|---|---|
| 静态/程序化 | testgen：M04 16=16、M05 58=58、M06 15=15、M07 33=33；problems=0、conflicts=0；blocked=15 与登记一致 |
| 编译 | `mvn -pl futurefab-modules/futurefab-system -am test-compile -o` BUILD SUCCESS |
| 单元/契约 | M04-M07SkeletonContractTest（路由/权限、接线与签名、逐编号 501 反射、DTO/View 形状、MockMvc standalone 501 信封）各 5/5；FullSystemSkeletonGateTest 4/4；SkeletonEngineShadowFixtureTest 6/6 → 30/30 |
| 全模块回归 | `mvn -pl futurefab-modules/futurefab-system -am test -o` Tests run: 454, Failures: 0, Errors: 0（批次一 434 + 本批次 20） |
| 未执行 | 真实 MySQL/Redis/网关/浏览器联调未运行，不作任何高于单元/契约层的完成宣称 |

## 6. 遗留与后续

- M04-017～023：待 `/system` 前缀与 Controller 前缀裁决 + 三个 Workflow Vo 冻结后回补（登记于 26 清单 blocked 处置）。
- 3.2/3.3/3.4 的 Object/并集承载项：业务实现阶段回填具体形状/取值域，不得在骨架阶段臆造。
- 管理写契约（writeMeta）入口全部维持「显式 501，零守卫接线」，守卫/审计接线属业务批次。
- 批次三（M09 + 跨模块 Port 收口）见 29 报告；全系统对账见 30 报告。
