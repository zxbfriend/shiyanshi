# INT-17｜work3｜M06-014 详情口补 managementRevision 外壳

日期：2026-10-07　·　基线：`4005594c`（= origin/cloud = 服务端 tip）　·　性质：小代码批（生产 1 处注解 + 契约测试）

## 0. 一句话结论

M06-011 详情口（`GET /process/approval/requests/{approvalId}`）现标 `@CurrentManagementRevision`，
由公共链在响应**顶层**带出当前 SYSTEM 管理版本，成为 M06-014 守卫写页面侧 `X-Management-Revision`
的唯一版本来源（AGENTS.md §13.3）。本批不写口加注、不改守卫语义、不改应用服务行为、不翻 M06-015，
也不动 M06-010/012/013。

依据 INT-14（`docs/开发任务/INT-14-M06-014-revision出口选择复核-20261007.md`，已入库 `4005594c`）：
推荐 M06-011 而非 M06-010——版本值取自 `sys_management_revision` 的固定 SYSTEM 单行，两口数值必然相同，
因此差别只在耦合面：审批动作页面本来就同页消费 M06-011 的详情快照与 M06-013 的预检摘要
（`ProcessApprovalQueryApplicationServiceImpl:147-184`，预检摘要同响应 `:166-183`），把版本出口钉在详情口不引入列表依赖，
且 501 失败关闭的影响半径只在本单详情。同模块先例是 M06-007／M06-008 已标该注解
（`M06ApprovalPolicyContractTest:127-136` 正向钉住）。

## 1. 开工门禁（实测）

| 判据 | 实测 |
|---|---|
| `git fetch origin` 后 `HEAD` | `4005594c368cab86f31b643edd9311049fdd3b3f` |
| `git rev-parse origin/cloud` | 同上 |
| `git ls-remote origin cloud` | 同上（服务端 tip 已核，非仅本地跟踪引用） |
| `git rev-list --left-right --count origin/cloud...HEAD` | `0 0` |
| `git status --short` 开工时 | ` M .gitignore`（并发会话所改，本批不 stage、不回退、不纳入提交） |
| INT-14 是否已提交 | 是（`4005594c`，仅该文档一笔），不与本批混提 |
| 前提复核 | `ProcessApprovalController` 详情口开工前无 `@CurrentManagementRevision`，INT-14 结论未过期 |
| 基线快进（复审补记） | 开工基线为 `4005594c`，落码期间主线快进到 `df113320`；§1.1 已复跑确认，新基线上定向套件结果一致（25 类／331 条／0 失败） |

### 1.1 落码期间发生的并发漂移（共享树，实测）

工作区改动期间 HEAD 被并发会话从 `4005594c` 推进到 `df113320`
（区间＝`e1a612eef` INT-15 M09 文档、`13b72e44c`/`f8a097447` 两个 merge、`df1133208` INT-18 M07 三文件）。
交集核对：`git diff --name-only 4005594c df113320` 命中 5 个路径（INT-15/16/18 三份文档＋
`RunCultureApplicationApplicationServiceImpl.java`＋`M07GlucoseCandidateQueryWiredContractTest.java`），
**与 M06 及本批三个文件零交集**；`git diff` 仍能干净列出本批注解 ⇒ 并发提交未重复做本批改动。
处置：在新树上**重跑任务书定向套件**，结果同为 `Tests run 331 / Failures 0 / Errors 0`、BUILD SUCCESS；
模块全量未在 `df113320` 上重测（该区间无 M06 文件，且并发会话此刻正在同一 `target/` 上跑测试，
surefire 报告目录已不可归属），见 §9。

## 2. 改动清单（全部落在 M06 本模块范围）

| 文件 | 落点 | 性质 |
|---|---|---|
| `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/ProcessApprovalController.java` | `:3` 新增 import；`:37-40` 类 Javadoc 增"版本来源"段；`:62-66` 方法 Javadoc + `@CurrentManagementRevision` | 生产：只补读口注解与注释，`@ManagementGuardedWrite`（`:111`）语义零改动 |
| `.../src/test/java/com/futurefab/system/contract/M06ApprovalActionLogWiredContractTest.java` | `:96-100` 常量；`:108-114` tearDown 清线程上下文；`:574-611` 负断言翻正；`:615-680` 4 条新外壳取证；`:716-734` 带拦截器 helper + Source 替身 | 测试：新增顶层版本正/负面，钉住 010/012/013 未被误改 |
| 本文档 | — | 交付 |

注解落点遵循同模块既有排版（`ApprovalPolicyController:55-57`：`@RequiresPermissions` →
`@CurrentManagementRevision` → `@GetMapping`），顺序与 M06-007 一致。

## 3. 实现要求逐条对账

1. **只给 M06-011 加注**：`ProcessApprovalController:66`。010/012/013 保持无注解，
   并由 `detailOutletIsTheRevisionSourceWhileTheOtherReadsStayUnannotated`（`:582`）反向钉住，
   防止后续被"顺手统一"。
2. **写口不加 QUERY_CURRENT**：`@ManagementGuardedWrite`（`:111`）与 `WriteMeta` 首位形参（`:113`）
   未动；新增断言 `assertNull(actionWrite.getAnnotation(CurrentManagementRevision.class))`——
   写响应版本必须是提交后版本（MUTATION_COMMITTED 由应用服务回填），读注解会冒充当前值。
3. **应用服务行为不变**：`ProcessApprovalQueryApplicationServiceImpl` 零改动；版本由前置解析器写入
   `RequestMetadataContext`，`RequestMetadataResponseAdvice` 复制到外壳顶层，不进业务投影。
4. **DTO 不投影版本**：`ApprovalDetailView` / `ApprovalPrecheckResult` / `ApprovalActionView`
   仍无 `managementRevision` 字段（同一测试内断言），页面不得从 `data` 里猜版本。
5. **测试必须挂真实前置解析器**：新增 `mvcWithRevisionSource(String)`（`:716`）在 standalone 链上
   `.addInterceptors(new ManagementRevisionPreResolver(constantSource(revision)))`，
   与生产 `WebMvcConfig:41-43` 注册的同一前置解析器同型；本类原有不带拦截器的 `mvc()`（`:697`）
   只服务原 404 同形断言，未用于任何版本外壳断言——这正是 INT-14 §3 记下的假绿陷阱
   （旧 `:610-620` helper 没挂拦截器）。

## 4. 既有负断言翻正说明

原方法 `readOutletsSupplyNoManagementRevisionWhileTheActionWriteRequiresIt` 对四个读口一律
`assertNull(...QUERY_CURRENT)`，并登记"审批动作页面拿不到版本、前端必须短路"。该方法改名为
`detailOutletIsTheRevisionSourceWhileTheOtherReadsStayUnannotated`，处置为：

- `getApprovalRequestDetail`：`assertNull` → `assertNotNull`（本批唯一翻正点，即任务书"只翻 M06-014 对应点"）；
- `pageApprovalRequests` / `listApprovalActions` / `precheckApprovalAction`：保持 `assertNull`，文案改为
  "不属本批 revision 出口，不得被顺手翻正"；
- 守卫写侧三条断言（`@ManagementGuardedWrite`、`WriteMeta` 形参、DTO 无版本字段）全部保留并加严一条
  （写口禁标 QUERY_CURRENT）。

其它 M06 测试文件无需翻正：`M06ApprovalActionGuardedWriteContractTest` 只用
`getCurrentManagementRevision()` 断 409 冲突回执；`M06ApprovalPolicyContractTest:127-136` 只覆盖 007/008。
全仓无固定"读注解数量"的门禁（`FullSystemSkeletonGateTest`、`ManagementGuardedWriteArchTest` 均无该计数）。

## 5. 新增取证（CONTRACT_TESTED 层）

| 用例（`:行`） | 断言 |
|---|---|
| `detailHttpShellCarriesTopLevelManagementRevision`（`:619`） | 挂拦截器 + Source="77"：`$.managementRevision`=77，业务体 `$.data.row.approvalId`=8100、`objectVersion`=1 同响应返回 |
| `detailHttpStopsBeforeApplicationServiceWhenRevisionSourceMissing`（`:639`） | Source 未注册：HTTP 501 + `NOT_IMPLEMENTED` + `contractId=PRE-01A#ManagementRevisionSource` + 无 `$.data`，且 `verifyNoInteractions(aprRequestMapper, labAuthorizationService, logMapper)` |
| `detailHttpStopsBeforeApplicationServiceWhenRevisionValueIllegal`（`:654`） | Source 返回 `-1`（非 `^\d+$`）：同样 501 前置于应用服务，不降级为无版本外壳 |
| `unannotatedActionLogOutletIsUnaffectedByTheMissingSource`（`:669`） | 同一条缺 Source 链下 M06-012 仍走业务判定得 404、无顶层版本字段——本批范围没有外溢 |
| `detailOutletIsTheRevisionSourceWhileTheOtherReadsStayUnannotated`（`:582`） | 注解面正反对照（见 §4） |

## 6. 验证分层（不得越级宣称）

| 层级 | 结果 |
|---|---|
| 编译 | 通过（Maven `-o -pl futurefab-modules/futurefab-system -am`，MVN_EXIT=0） |
| 定向契约套件 | 通过 **2 次**（`4005594c`＋本批工作区、以及并发漂移后的 `df113320`＋本批工作区）：任务书指定 `-Dtest="M06*,*Approval*,FullSystemSkeletonGateTest,PortSignatureSnapshotTest,ManagementGuardedWriteArchTest,ManagementOperationTest,AuditPolicyRegistryTest"` ⇒ **25 个测试类 / 331 条 / 0 失败 0 错误 0 跳过**（本批净增 4 条：原 1 条翻正为 1 条 + 新增 4 条外壳用例；`M06ApprovalActionLogWiredContractTest` 18→22） |
| 模块全量 | `3689 条 / 0 失败 / 1 错误`，唯一错误为**本机环境既有红**、非本批引入，明细与归属见 §9 |
| SQL 执行 | 不涉及（零 SQL/XML 改动） |
| HTTP 真实请求 | **NOT_VERIFIED**（standalone MockMvc，无网关、无 AOP 权限拦截、无真实 `WebMvcConfig` 注册证据） |
| 浏览器验收 | **NOT_VERIFIED**，且本副本前端无 `/process/approval/requests` 调用点（`futurefab-frontend` 全仓检索 0 命中；仅有 `packages/app-smp-data/src/views/detect-approval-record/m06-blocked.ts` 的阻塞文案映射，非调用点） |
| 菜单/权限 | **BLOCKED_MENU**：`process:approval:*` 权限种子仍 0 行，页面入口未配 |

因此 M06-011 的口径是 `IMPLEMENTED + CONTRACT_TESTED`；M06-014 的"页面可取到 revision"只是**后端出口已具备**，
不等于前端已接线，也不等于 014 可浏览器验收。

## 7. 本批未做（明确不动的面）

- M06-015 直通审计：仍 `wired=false`、仍按本编号 501（`assertStillSkeleton` 断言未动）。
- M06-010 列表口加注（INT-14 判为"可选加固"，且实返 `AjaxResult{data:PageResult}` 与
  `接口与审批生效契约.md:7` 规定的 `TableDataInfo` 列表外壳有口径差，须另批裁决）。
- 跨模块同型口（M05/M07/M09 的详情/列表读口）：一个未动。
- `ManagementOperation` / `AuditPolicyRegistry` / `AuditObjectType`：0 改动（无新增操作码与审计族）。
- Port 签名 / `PortSignatureSnapshotTest` / `FullSystemSkeletonGateTest`：0 改动，两者在本批套件内复跑通过。
- SQL / Mapper XML / skeleton json / 前端 / 菜单权限种子：0 改动。

## 8. 落码后续前置（下一批才做，本批不触碰）

1. **前端 revision 接线**：审批动作页面须先调 M06-011 详情口取顶层 `managementRevision`，
   再随 `X-Request-Id` 一起发给 M06-014；取不到必须短路，不得硬编码或跨模块借值（AGENTS.md §13.3）。
2. **HTTP 联调**：需要网关 + Nacos + 服务实例，属 `BLOCKED_DEPLOY` 面，未联调前 014 封顶 CONTRACT_TESTED。
3. **菜单与权限种子**：`process:approval:list/query/review/approve/withdraw` 仍 0 行，浏览器验收前置。
4. **可选加固 M06-010**：若要列表口也带版本，须先裁 `TableDataInfo` 外壳顶层字段口径
   （INT-14 §2.3），本批已把"010 未标注"钉成断言，翻正时须同批改该测试。

## 9. 模块全量复跑结果与唯一红归属

命令：`mvn -o -pl futurefab-modules/futurefab-system -am test`（同一基线 `4005594c` + 本批工作区改动）。

- 结果：**Tests run 3689 / Failures 0 / Errors 1 / Skipped 0**，BUILD FAILURE 由这 1 条错误触发。
- 唯一错误：`M05WorkbenchAndReportBlockedEvidenceContractTest#pdfRenderingLibraryIsAbsentWhileExcelRenderingAlreadyExists`
  ⇒ `java.io.UncheckedIOException: java.nio.file.NoSuchFileException:
  <repo>/futurefab-frontend/node_modules/axios`。
- 归属（本机环境，非本批、非仓库状态）：该用例对 `REPO_ROOT` 做 `Files.walk(root, 4)`，
  会走进前端 `node_modules` 里的悬空符号链接。实测 `futurefab-frontend/node_modules/axios`
  是指向 `/c/node_modules/axios` 的 symlink，而该目标在本机不存在（`ls: /c/node_modules: No such file`），
  且 `git ls-files futurefab-frontend/node_modules` 命中 0 个文件（未被 git 跟踪）。
  因此在未含本批改动的基线上同样会失败——本批 3 个改动文件既不含该 M05 用例，也不含任何前端文件。
- 处置：按跨模块边界纪律，本批**不修**该用例、不建目录、不改符号链接；仅在 M06 侧登记现象，
  需由 M05 owner 或环境维护方处理（可行修法属其范围，例如 walk 前过滤符号链接或忽略未跟踪目录）。
- 定向套件口径不受影响：任务书指定套件 **25 类 / 331 条 / 0 失败 0 错误 0 跳过**，
  其中 `M06ApprovalActionLogWiredContractTest` 18→22 条（+4 新外壳用例，原 1 条翻正改名）。


## 10. 复审要点（交 work7 / work5 只读）

1. `git diff --name-only` 是否只有 §2 三个文件（`.gitignore` 是并发会话的既有改动，不在本批范围）。
2. 注解是否只落在 M06-011，写口是否仍只有 `@ManagementGuardedWrite`。
3. 版本外壳断言是否全部走 `mvcWithRevisionSource`（挂真实前置解析器），未复用不挂拦截器的 `mvc()`。
4. 类 Javadoc 与方法注释是否避免出现门禁按全文子串匹配的守卫执行器类名字面量
   （`ManagementGuardedWriteArchTest` 的禁令是子串匹配，注释里写也算违例；本批已复跑该门禁 14 条通过）。
