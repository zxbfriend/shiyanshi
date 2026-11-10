# FULL-VERIFY 事务专项缺口复核 — 2026-10-08

- 性质：**只读静态复核**（仅 git fetch/status/diff/log、读文件、grep/rg；未 add/commit/push/reset/stash/clean/pull/merge/rebase；未新增或修改任何测试/生产代码）
- 复核人：work7（只读复审角色）
- 复核对象：FULL-VERIFY 报告中列的两个“事务验证缺口”
  1. M06-011 详情外壳 `managementRevision` 专项
  2. M05 检测结果事实 Provider 专项
- 复核口径：以仓库内现有契约测试源码 + INT 文档为证据，判定缺口是否已被既有测试关闭。

> 说明：本工作树内未检索到字面为 `FULL-VERIFY` 或含“事务验证缺口”措辞的报告文件（Glob `*FULL*`/`*VERIFY*`、Grep `FULL-VERIFY|事务验证缺口|事务专项` 均无命中）。以下按用户给定的两条缺口描述逐项对照现有测试/文档证据；缺口①对应 INT-17 已落地事实，缺口②对应 INT-04 Provider 契约测试与 INT-13 登记的 `BLOCKED_DATA`。

---

## 一、M06-011 详情外壳 `managementRevision` 专项

### 结论：**已被 INT-17 关闭（CONTRACT_TESTED）**

承载测试：`futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/contract/M06ApprovalActionLogWiredContractTest.java`
关联文档：`docs/开发任务/03-接线与阻塞记录/INT接线记录/INT-17-M06-014详情口managementRevision外壳-20261007.md`

INT-17 起，该测试类除原 M06-012 只读契约外，额外承担 M06-011 详情口顶层 `managementRevision` 外壳取证，明确覆盖用户列的两点：

| 用户要求 | 测试证据（文件:行） | 判定 |
|---|---|---|
| M06-011 详情外壳 `managementRevision` | `detailHttpShellCarriesTopLevelManagementRevision`（:618-631）：挂生产同款 `ManagementRevisionPreResolver`，`$.managementRevision`=`"77"`，业务体 `$.data.row.approvalId`/`objectVersion` 同响应返回 | ✅ 已覆盖 |
| Source 缺失失败关闭 | `detailHttpStopsBeforeApplicationServiceWhenRevisionSourceMissing`（:638-650）：Source 未注册（`constantSource(null)`）→ HTTP 501 + `NOT_IMPLEMENTED` + `contractId=PRE-01A#ManagementRevisionSource` + 无 `$.data`，且 `verifyNoInteractions(aprRequestMapper, labAuthorizationService, logMapper)`（应用服务之前终止） | ✅ 已覆盖 |
| Source 非法失败关闭 | `detailHttpStopsBeforeApplicationServiceWhenRevisionValueIllegal`（:653-662）：Source 返回 `"-1"`（非 `^\d+$`）→ 同样 501 前置，不降级为无版本外壳 | ✅ 已覆盖 |

补充取证（范围隔离，防止误改外溢）：
- `detailOutletIsTheRevisionSourceWhileTheOtherReadsStayUnannotated`（:581-609）：正向钉住 `getApprovalRequestDetail` 标 `@CurrentManagementRevision` 为唯一版本出口，反向钉住 M06-010/012/013 不标该注解、M06-014 守卫写不标 `QUERY_CURRENT`、三个只读 DTO 不投影 `managementRevision`。
- `unannotatedActionLogOutletIsUnaffectedByTheMissingSource`（:668-679）：同一条缺 Source 链下 M06-012 仍走业务判定得 404、无顶层版本字段。

INT-17 §6 验证记录：该定向套件（`M06*` 等 25 类 / 331 条 / 0 失败 0 错误 0 跳过）在基线 `4005594c` 及并发漂移后的 `df113320` 上各跑一次均通过；本类 18→22 条（原 1 条翻正 + 新增 4 条外壳用例）。HTTP/浏览器层仍为 `NOT_VERIFIED`（standalone MockMvc，无网关/Nacos/真实 `WebMvcConfig`），菜单权限 `BLOCKED_MENU`。

**处置**：将 FULL-VERIFY 的“M06-011 详情外壳 managementRevision 专项”缺口标记为 **已被 INT-17 关闭**。剩余未验证面（HTTP 真请求、浏览器、菜单权限）属 INT-17 §6/§8 已登记的独立阻塞项，不在本缺口范畴。

---

## 二、M05 检测结果事实 Provider 专项

承载测试：`futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/contract/M05DetectionResultAdapterContractTest.java`（INT-04 契约测试）
关联文档：`docs/开发任务/03-接线与阻塞记录/INT接线记录/INT-04-DetectionResultPort-provider前置窗口-20261007.md`、`INT-13-M07-019-M05来源确认Aprime过渡-20261007.md`、`INT-09-M07-019-DET-I06字段缺口裁决包-20261007.md`

逐条核对用户列出的四条：

| # | 用户要求 | 测试证据（文件:行） | 是否覆盖 |
|---|---|---|---|
| ① | 精确版本不存在不得回退最新 | `getResultRevisionMissingVersionFailsClosedWithoutFallingBackToLatest`（:213-226）：`selectRevisionFacts(7001,2)` 返回 null → `RESULT_PROJECTION_UNAVAILABLE`/503，且 `verify(factsMapper, never()).selectCurrentRevisionFacts(...)` 与 `never().selectEligibleRevisions(...)`（绝不回退当前有效版本或候选集） | ✅ 已覆盖 |
| ② | 候选分页 `hasMore` | `queryEligibleResultsProjectsRowsAndKeepsStableCursor`（:287-311）：limit=2 取 3 行只发 2 行，`assertTrue(set.isHasMore())` + `set.getNextCursor()="11"`；`queryEligibleResultsExhaustsCursorWithoutTruncation`（:313-328）：末页 `hasMore=false` + `nextCursor=null` | ✅ 已覆盖 |
| ③ | 被替换版本 `effective=false` + `replacedBy` | `resolveEffectiveResultKeepsSupersededVersionTraceable`（:388-401）：旧版本 `assertFalse(view.isEffective())` + `assertEquals("5", view.getReplacedBy())`（指向当前有效版本，保留可追溯） | ✅ 已覆盖 |
| ④ | `BLOCKED_DATA` / `content_snapshot` 写入方缺失 | 该类中**无**对应断言。Grep `content_snapshot`/`BLOCKED_DATA`/`写入方` 在 `M05DetectionResultAdapterContractTest` 内 0 命中。事实：唯一候选生产者 M05-048 仍 501（skeleton），`det_result_revision.content_snapshot` 今天无生产写入来源，属 `BLOCKED_DATA`，由 `INT-13`（:5/56）、`INT-09`（:232/310）、`M07ConfirmationSourceFieldGapContractTest`（:103/317）登记，但**未**在 Provider 契约测试中作为断言落地 | ❌ 未覆盖 |

### 结论：**部分关闭 — ①②③ 已闭，④ 未闭**

- ①②③ 三条行为契约已由 `M05DetectionResultAdapterContractTest`（INT-04）静态 + 契约测试覆盖（方法名与断言直接对应）。
- ④ `content_snapshot` 写入方缺失 / `BLOCKED_DATA` **未**被该 Provider 测试覆盖。它是一项数据层阻塞事实（缺 M05-048 落码），不是 Provider 读侧行为，按现有纪律应由数据/接口 owner 以 `BLOCKED_DATA` 登记追踪，而非塞进 Provider 读取契约测试。FULL-VERIFY 的“M05 Provider 专项”缺口若含第④条，则**不能整体判为已闭**；建议将④从“Provider 契约测试缺口”拆出，单列为 `BLOCKED_DATA` 跟踪项（owner：M05/M07，关联 INT-13/INT-09）。

---

## 三、总控回报（按用户要求）

1. **M06-011 缺口是否已闭**：已闭 — 标记“已被 INT-17 关闭”（CONTRACT_TESTED；HTTP/浏览器/菜单仍为 NOT_VERIFIED/BLOCKED_MENU，属 INT-17 已登记的独立阻塞面）。
2. **M05 Provider 缺口是否已闭**：部分关闭 — ①②③ 已闭；④ `content_snapshot` 写入方缺失 / `BLOCKED_DATA` 未覆盖，建议拆为独立 `BLOCKED_DATA` 跟踪项，故该缺口整体**未闭**。
3. **修改文件清单**：本报告为本次复核唯一新增文件 `docs/开发任务/04-运行验收准备/FULL-VERIFY-事务专项缺口复核-20261008.md`（交付物，未提交）。**未修改任何测试/生产/契约/SQL/DDL 文件**，未改 `M06ApprovalActionLogWiredContractTest`、`M05DetectionResultAdapterContractTest` 或其他任何源码。
4. **测试是否运行**：**未运行 Maven**。依据：用户授权“不跑 Maven 也可以”；静态证据已充分（方法名 + 断言直接对应三条要求）；INT-17 §6 已记录该 M06 类定向套件 0 失败（可作为 CONTRACT_TESTED 已验证的既往证据）。如总控要求运行态确认，可用：
   `mvn -o -pl futurefab-modules/futurefab-system -am test -Dtest="M06ApprovalActionLogWiredContractTest,M05DetectionResultAdapterContractTest" -Dsurefire.failIfNoSpecifiedTests=false`
   （注意：模块全量曾有一例环境红 `M05WorkbenchAndReportBlockedEvidenceContractTest`（前端 `node_modules` 悬空符号链接），不在上述 `-Dtest` 范围，不影响这两类结果。）
5. **git status**：
   - `M .gitignore`（开工前既存的用户无关修改，本批未触碰、未纳入）
   - 本次新增（未跟踪、未 stage）：`docs/开发任务/04-运行验收准备/FULL-VERIFY-事务专项缺口复核-20261008.md`
   - `HEAD` = `24a6df9afcefa0a0f753067f003ecd5cc069ce6b`，与 `origin/cloud` 一致，ahead-behind `0 0`。
   - 未执行 add/commit/push/reset/stash/clean/pull/merge/rebase。

---

## 四、待总控裁决

- 是否认可“M06-011 缺口=已被 INT-17 关闭”的标记。
- 是否认可将 M05 Provider 第④条（`content_snapshot` 写入方缺失 / `BLOCKED_DATA`）从“Provider 契约测试缺口”拆出，单列 `BLOCKED_DATA` 跟踪（关联 INT-13/INT-09，owner M05/M07），从而将 FULL-VERIFY 的 M05 Provider 缺口口径由“整体未闭”改为“行为契约已闭、数据层另列阻塞”。
- 本报告文件按交付要求新增，是否纳入提交由总控决定（本次未提交）。
