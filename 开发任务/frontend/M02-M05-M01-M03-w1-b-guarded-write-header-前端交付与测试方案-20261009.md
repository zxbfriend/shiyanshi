# M02/M05/M01/M03 前端批次 W1-B · 守卫写「版本 + 幂等键」断链修复（缺版本短路 / 双头真正发出 / 409 重取）

> 本文件是**测试方案与交付登记**，不是验收结论。浏览器列全部标记 `NOT_VERIFIED`，由独立 work 只读复审后实跑回填。
> 对应后端批次：批次 B（M02/M05 前后端守卫写链）；批次 A 的 M04 口径见 `M04-feeding-template-management-w1-a1-guarded-write-header-前端交付与测试方案-20261009.md`。

## 1. 基本信息

| 项 | 内容 |
| --- | --- |
| 执行人 | work1 |
| 日期 | 2026-10-09 |
| 覆盖页面 | ①检测操作台（M05）②打印机排版（M02）③实验室消耗规则（M02）④实验室通讯设置（M02）⑤检测项编辑（M02）⑥角色管理（M01）⑦项目管理（M03） |
| 覆盖写口 | M05-021 改样品号、M05-022 上传、M05-023 撤回；M02-112 排版保存；M02-243 消耗配置保存；M02 通讯设置保存；检测项新增/修改（POST+PUT 同出口）；M01-042 角色删除、M01-044 角色启停；M03-004 项目新增 |
| 版本来源口 | M05-006 `GET /detect/workbench/queue` 与 `GET /detect/workbench/results`（本批补 `@CurrentManagementRevision`）；M02-111 `GET /lab/printer/{id}/layout`；M02-241 `GET /lab/consumptionRule/config`；M01-039 `GET /system/role/list`；M03-001 `GET /resource/project/list`、M03-002 `GET /resource/project/{id}`；M02 检测项列表 `GET /device/detectoritem/list` |
| 依赖前端能力 | `packages/app-smp-settings/src/shared/use-guarded-write.ts`、`packages/sdk-smp-api/src/guarded-write.ts`（`writeHeaders`）、`packages/app-smp-data/src/workbench/guarded-revision.ts`（本批新增，工作台无 `t()` 依赖版） |
| 交付状态口径 | 最高 `CONTRACT_TESTED`（vitest + 类型检查 + dts 重建）；HTTP / 浏览器 `NOT_VERIFIED`；后端源码级 `IMPLEMENTED`；菜单/功能码授权仍 `BLOCKED_MENU`；门户产物 `BLOCKED_DEPLOY` |

## 2. 本批修改文件清单

### 2.1 前端生产代码

| 文件 | 改动 |
| --- | --- |
| `packages/sdk-smp-api/src/detectoritem.ts` | `save()` 声明了 `meta` 却从未发头 ⇒ 补 `headers: writeHeaders(meta)`（POST 新增与 PUT 修改同一出口，两者都是守卫写） |
| `packages/sdk-smp-api/src/project.ts` | 新增 `writeHeaders` 导入；`save()` 增 `meta?: GuardedWriteMeta` 并真正发头；注释登记 M03-004 版本来源 |
| `packages/sdk-smp-api/src/system.ts` | `roleApi.remove`、`roleApi.changeStatus` 增 `meta` 参数并发头（此前签名接了值就丢） |
| `packages/sdk-smp-api/src/workbench.ts`、`src/workbench-types.ts`、`src/modules/detect/workbench.ts` | M05-021/022/023 三个写口接 `GuardedWriteMeta` + `writeHeaders`；响应类型透出顶层 `managementRevision` |
| `packages/sdk-smp-api/src/modules/lab/printer.ts` | `savePrinterLayout` 接 `meta` 并发头；`getPrinterLayout` 注释登记为 M02-112 唯一版本来源 |
| `packages/sdk-smp-api/src/modules/lab/consumptionRule.ts` | `saveConsumptionRuleConfig` 接 `meta` 并发头 |
| `packages/sdk-smp-api/src/modules/lab/communication.ts` | 通讯设置保存口接 `meta` 并发头（批次 B 前半段） |
| `packages/app-smp-data/src/workbench/guarded-revision.ts` | **新增**：工作台页侧守卫写编排（capture / `ensureRevision` / `writeMeta` / `applyWrittenRevision` / 409 置陈旧 / 缺版本提示），刻意不依赖 `t()` 以便 node 侧直测 |
| `packages/app-smp-data/src/workbench/{bga,cedex,osmo,vicell}/use-workbench.ts`、`src/views/detect-workbench/index.vue` | 四个厂牌共用逻辑接同一编排：读队列/结果外壳捕获版本 ⇒ 缺版本短路 ⇒ 写口带 `writeMeta` ⇒ 回执覆盖本地版本 ⇒ 409 标陈旧后重取 |
| `packages/app-smp-settings/src/views/lab-printer/index.vue` | 排版弹窗新增 `layoutRevision` + `reloadLayoutRevision()`；打开弹窗时清空、以 M02-111 响应顶层版本为期望值；保存走 `ensureRevision` 短路 + `writeMeta` + `applyWrittenRevision` + `invalidateOnConflict` |
| `packages/app-smp-settings/src/views/lab-consumption-rule/use-consumption-rule.ts` | 同上，版本来源固定为本页 M02-241 配置读口；`reloadRevision()` 用当前 `labId/tabType` 重读同一口，不跨页签借版本 |
| `packages/app-smp-settings/src/views/role-management/index.vue` | 接 `useGuardedWrite`（版本源 = 本页 M01-039 列表外壳）；删除与启停两个确认回调改为 `ensureRevision ⇒ 缺版本短路 ⇒ writeMeta ⇒ 回执覆盖`；新增哨兵 `management-revision-missing` 避免同一失败弹两次提示；启停 catch 补 `invalidateOnConflict` |
| `packages/app-smp-settings/src/views/project-management/project-editor.vue` | 接 `useGuardedWrite`：编辑时取 M03-002 详情外壳版本、新增时取 M03-001 列表外壳版本；仅对守卫写的那一枪（新增）做缺版本短路，旧编辑口 PUT 未挂守卫故不额外阻断；回执覆盖本地版本 |
| `packages/app-smp-settings/src/views/detectoritem-management/detectoritem-editor.vue` | `writeMeta(await ensureRevision())` 改为先取值再判定：缺版本直接短路并提示，不再发必然 400 的请求 |
| `packages/app-smp-settings/src/components/communication-dialog/index.vue` | 通讯设置保存接线（批次 B 前半段） |
| `packages/sdk-language/src/legacy/{zh-CN,en-US}.ts` | `common.revisionMissing` 中英双目录登记 |

### 2.2 后端生产代码（1 个文件）

| 文件 | 改动 |
| --- | --- |
| `futurefab-modules/.../controller/DetWorkbenchController.java` | `queue`、`results` 两个只读口补 `@CurrentManagementRevision`，并在 javadoc 点名它们是 M05-021/022/023 期望版本的唯一合法来源。**未**放宽任何校验、**未**增删 `@ManagementGuardedWrite` |

### 2.3 前端测试（3 新 1 改）

| 文件 | 状态 |
| --- | --- |
| `futurefab-frontend/tests/flat-sdk-guarded-write-meta.test.ts` | **新增**，7 例：平层 SDK「声明 meta 却没发头」缺陷类回归 + 三个页面的版本来源与短路钉子 |
| `futurefab-frontend/tests/m05-workbench-guarded-write.test.ts` | **新增**，16 例：工作台读口捕获、缺版本短路、写口带头、回执覆盖、409 重取 |
| `futurefab-frontend/tests/m02-communication-guarded-write.test.ts` | **新增**，7 例（批次 B 前半段） |
| `futurefab-frontend/tests/settings-extracted-logic.test.ts` | 翻正 1 处替身：消耗规则读口替身补顶层 `managementRevision`（真身 M02-241 外壳确实带该字段）。**未删断言、未放宽期望**，只是把替身补齐到与契约一致 |

### 2.4 后端测试（1 新）

| 文件 | 状态 |
| --- | --- |
| `.../src/test/java/.../contract/M05WorkbenchRevisionSourceContractTest.java` | **新增**，4 例：`queue`/`results` 响应外壳顶层确实带 `managementRevision`，且未标 `@CurrentManagementRevision` 的口不得冒充版本源 |

### 2.5 明确未触碰

- `packages/sdk-smp-api/src/modules/**` 下 37 处旧写定义（批次 C 处置清单，见 §7）
- 任何后端 `RequestMeta` 校验、`@ManagementGuardedWrite` 注解、权限注解、CAS/幂等/引用保护口径
- `skeleton-*.json` 登记账本、数据库脚本、Nacos 与网关配置：本批零改动
- `docs/接口文档/` 等客户只读材料

## 3. 为什么这样改

### 3.1 真实缺陷不是「页面没带头」，而是 SDK 把版本吞了

后端 `WriteMetaArgumentResolver` 只认 Header。审计（网关路径逐条比对，见 §5.0 取证口径）发现两类断链：

1. **平层 SDK 声明了 `meta` 参数但请求里根本没组头**——`detectoritem.save`、`project.save`、`roleApi.remove`、`roleApi.changeStatus`。页面已经 `writeMeta(await ensureRevision())` 把值传进去，参数被静默丢弃，后端恒判 400 `INPUT_INVALID`，服务与库零触达。这类缺陷在页面侧完全看不出来，只在保存时报「输入无效」。
2. **写口是守卫写、页面完全没有版本源**——M05 工作台的三个结果动作（改样品号 / 上传 / 撤回）此前无处取版本，因为两个队列读口没标 `@CurrentManagementRevision`，外壳顶层不带版本。

### 3.2 版本只认本页读口外壳

AGENTS.md §13.3：不硬编码、不借无关模块、拿不到就短路。本批每条链路的版本源都写成该页自己的读口：

- 工作台：`queue` / `results` 外壳顶层版本（本批补注解后才有）
- 打印机排版：M02-111 排版读口响应
- 消耗规则：M02-241 配置读口响应，按当前 `labId + tabType`
- 角色：M01-039 列表外壳
- 项目：编辑用 M03-002 详情、新增用 M03-001 列表
- 检测项：M02 检测项列表外壳（弹窗经 `props.revision` 下传，本地缓存写在 `usePropRevision` 上）

`ensureRevision()` 只在本地不可信（没取到或刚吃过 409）时补一次同一读口，避免每次保存都多发一个请求。

### 3.3 缺版本短路，不发必然 400 的请求

`guard 前端拿不到 revision 时必须短路`：五个页面/编排统一在发请求前判定，提示键 `common.revisionMissing`（中英齐）。角色页两个确认框用哨兵异常避免「提示 + 业务失败」双弹。

### 3.4 409 与引用保护分流

`invalidateOnConflict(e)` 仅在 `ApiError.code === 409` 时把本地版本置陈旧，下次写前重取；`writeErrorMessage` 对 `REFERENCE_EXISTS` 给「先解除引用」口径而不是「刷新重试」。守卫写回执的顶层版本是当前版本权威来源，一律 `applyWrittenRevision` 覆盖本地值。

## 4. 已执行验证命令与结果（2026-10-09）

前端目录 `futurefab-frontend/`：

| 顺序 | 命令 | 结果 |
| --- | --- | --- |
| 1 | `pnpm --filter @futurefab/ui-sdk-smp-api type-check` | 0 error |
| 2 | `pnpm --filter @futurefab/ui-sdk-smp-api build-dts` | 通过（app 侧首轮 5 条 `TS2554 Expected 1 arguments, but got 2` 全部由陈旧 `dist-types` 造成，重建后消失） |
| 3 | `pnpm --filter @futurefab/ui-app-smp-settings type-check` | 0 error |
| 4 | `pnpm --filter @futurefab/ui-app-smp-data type-check` | 0 error |
| 5 | `npx vitest run tests/flat-sdk-guarded-write-meta.test.ts` | **7 / 7 通过** |
| 6 | `npx vitest run tests/m01-guarded-write-wiring.test.ts tests/m05-workbench-guarded-write.test.ts tests/m02-communication-guarded-write.test.ts` | **29 / 29 通过**（6 + 16 + 7） |
| 7 | `npx vitest run tests/settings-extracted-logic.test.ts` | **61 / 61 通过**（替身补齐前 2 例红） |
| 8 | `npx vitest run tests/edit-form-prefill.test.ts` | **21 / 21 通过**（本批一度因 `pageSize: 1` 触发后端白名单门禁，已改为 10） |
| 9 | `npx vitest run tests/`（全量） | Test Files **14 failed \| 107 passed (121)**；Tests **27 failed \| 1356 passed (1383)** |

> 1—8 行的退出码当时未逐条记录（这正是 §4.1 要更正的缺陷之一）；第 9 行是全量运行，必为非 0。
> 补丁批次已按正确取码方式复跑，本补丁涉及的 9 个前端套件的逐文件结果与全量汇总见 §4.2。

后端目录（顺序 Maven，离线；退出码一律用 `; echo "MVN_EXIT=$?"` 紧跟 `mvn` 本体取，不得取管道末端的码，见 §4.1）：

| 命令 | surefire 正文 | 退出码 |
| --- | --- | --- |
| `mvn -o -pl futurefab-modules/futurefab-system -am test -Dtest="M05Workbench*,DetWorkbench*,*Workbench*" -Dsurefire.failIfNoSpecifiedTests=false` | `Tests run: 82, Failures: 0, Errors: 0, Skipped: 0`，含新增 `M05WorkbenchRevisionSourceContractTest` 4/4 与 `M05WorkbenchResultActionGuardedWriteContractTest` 35/35；日志尾部 `BUILD SUCCESS` | `MVN_EXIT=0`（**仅这条定向过滤跑为绿**） |
| `mvn -o -pl futurefab-modules/futurefab-system -am test`（全模块） | `Tests run: 4159, Failures: 2, Errors: 0, Skipped: 0`，日志正文 `BUILD FAILURE`；2 条红为 `.tmp-head-audit/` 影子副本双计数类（`M09SkeletonFiftyOneContractTest#blockedChannelPortsStillHaveZeroProvidersInProductionSource`、`GuardCallbackContextContractTest#bindingEntryPointIsPinnedToTheGuardExecutor`），失败正文都是同一路径出现两次（`expected [X.java] but was [X.java, X.java]`），两者扫描器均不属本批（rule 26 未改）。本批涉及的 `M05*` 与守卫执行器类在全量运行里为绿。 | **`MVN_EXIT=1`，全模块未通过，不得声明全量通过** |

> 本节当时的缺口：退出码一列缺失、`BUILD SUCCESS` 只属于上一行的定向过滤跑却与全模块失败同表并列，
> 造成对外汇报被读成"全量 BUILD SUCCESS"。更正与根因见 §4.1，复跑证据见 §4.2。

全量前端红文件清单（本批归因背景，非本批引入）：`config-management`、`detection-workbench-ui`、`dialog-pane-padding`、`dict-tag`、`iconfont-build`、`labgroup-management`、`localization`、`monitor-log`、`navigation`、`profile`、`scroll-pagination`、`settings-filter-toolbar`、`settings-merge-regressions`、`workflow-management`。

- 与 10-06 登记的 14 文件基线相比：`venue-management` 转绿、`settings-merge-regressions` 转红。后者正文为 `Error: Unexpected test import: ./venue-write-guard`，来自场地页在 `index.vue:54` 新引入的 `./venue-write-guard`，而 `settings-merge-regressions.test.ts` 的替身装载白名单未同步；两条红都不是本批文件命名，本批未触碰 venue 与场地测试替身。

### 4.1 勘误：为什么 4159/2 的失败被写成 BUILD SUCCESS（补丁批次，2026-10-09 晚）

结论：**全模块那次从来不是 BUILD SUCCESS，被写成 BUILD SUCCESS 是退出码取错 + 同表并列两点造成的，属记录缺陷，本补丁予以更正。全量存在失败时不得声明全量通过；本批与补丁批次的正确口径只有"定向绿 + 全模块红并逐条归因"。**

三条根因，按可复现程度排列：

1. **管道洗掉了 Maven 的退出码**。当时的命令形如
   `mvn -o -pl futurefab-modules/futurefab-system test 2>&1 | tee /tmp/c3-full.log | grep -E "^Tests run|BUILD"`，
   `$?` 取到的是 `grep` 的码（命中即为 0），不是 Maven 的。命令后面再补 `; echo EXIT=$?` 也一样错。
2. **后台任务的"completed (exit code 0)"不是 Maven 的退出码**。包装命令末尾是 `echo`，shell 恒返回 0。
   本补丁复跑时同一天现场再现：任务通知写 `completed (exit code 0)`，同一份日志正文是
   `BUILD FAILURE` + `MVN_EXIT=1`（`.patch-m04-fullmodule.log` 第 4003、4019 行）。因此通知里的退出码不得当结论用。
3. **记录把"定向过滤跑的 BUILD SUCCESS"与"全模块 BUILD FAILURE"塞进同一张表且不带退出码列**，
   读的人只记住了 `BUILD SUCCESS` 四个字。已在上方表格拆出「surefire 正文 / 退出码」两列。

正确取码方式（本补丁起一律照此）：`mvn ... > 日志 2>&1; echo "MVN_EXIT=$?" >> 日志`，
即 `mvn` 与 `echo` 之间不得有管道或 `tail`；再单独核对日志正文的 `Tests run:` 汇总行与 `BUILD SUCCESS|FAILURE` 行，两者必须一致。

**第 4 条同源缺陷（补丁批次现场复现，必须一并更正）**：`pnpm --filter <包名>` 的选择器不匹配时，
只打印 `No projects matched the filters` 并**返回退出码 0**。批次 A 交付记录 §4 的第 1、2 行
（`pnpm --filter @futurefab/app-smp-settings run type-check`、`pnpm --filter sdk-language run type-check`）
用的包名都不是真名（真名是 `@futurefab/ui-app-smp-settings`、`@futurefab/ui-sdk-language`），
所以那两行"0 error / 通过"实为**未执行**，属假绿，已在批次 A 记录 §4.1 登记勘误，并在 §4.2 用正确包名复跑。
复现取证：`pnpm --filter sdk-language type-check > ../.probe-lang.log 2>&1; echo EXIT=$?` ⇒ `EXIT=0`，
日志含 1 行 `No projects matched the filters`、0 行 `vue-tsc`；换成正确名后日志出现 `> vue-tsc --noEmit --composite false`。
凡 `pnpm --filter` 类命令，除退出码外还要核对日志里是否真的出现了被调用的脚本行。

### 4.2 补丁批次复跑证据（2026-10-09 22:01 前后，同一工作副本）

| 项 | 命令 | 正文（逐字） | 退出码 |
| --- | --- | --- | --- |
| 后端定向（M04 三套件 + 骨架门禁） | `mvn -o -q -pl futurefab-modules/futurefab-system test -Dtest='M04PermissionEnforcementContractTest,M04TemplateWriteGuardedContractTest,M04WriteMetaHeaderContractTest,FullSystemSkeletonGateTest' -Dsurefire.failIfNoSpecifiedTests=false` | `Tests run: 19`／`36`／`5`／`10`，各自 `Failures: 0, Errors: 0, Skipped: 0` | `MVN_EXIT=0` |
| 后端全模块 | `mvn -o -pl futurefab-modules/futurefab-system -am test`（日志 `.patch-m04-fullmodule.log`） | `Tests run: 4162, Failures: 2, Errors: 0, Skipped: 0`，`BUILD FAILURE`；2 条红仍是 §4 那两条影子副本双计数类（`PRUNED_DIRS` / `SCAN_PRUNE` 均未剪 `.tmp-head-audit`），未删该目录、未改扫描器 | `MVN_EXIT=1`（**全模块红，未通过**） |
| 后端新增 3 例是否真被执行 | 读 `target/surefire-reports/TEST-...M04PermissionEnforcementContractTest.xml` | `pumpOptionDoorsRequireFeedingQueryCodeBeforeAnyRead`、`pumpOptionDoorsReadCatalogOnlyAfterTheQueryCodePasses`、`copyFailsClosedWhenSourceKindDriftsInsideTheTransaction` 三条 testcase 节点存在（该类 16→19） | — |
| 前端全量 | `npx vitest run`（日志 `.patch-fe-full.log`） | `Test Files 14 failed \| 109 passed (123)`；`Tests 27 failed \| 1366 passed (1393)` | `FE_EXIT=1` |
| 前端补丁与批次 C 套件 | 同上单次全量运行内的逐文件行 | 9 个文件全绿：`guarded-write-unknown-outcome (6)`、`flat-sdk-guarded-write-meta (7)`、`m05-workbench-guarded-write (16)`、`m02-communication-guarded-write (7)`、`batch-management (10)`、`culture-management (8)`、`m03-culture-candidate-entry (22)`、`m03-grant-exit-facts (4)`、`settings-extracted-logic (61)` | — |
| SDK 产物与逐包类型检查（用真实包名，日志 `.patch-fe-build.log`） | `pnpm --filter @futurefab/ui-sdk-smp-api build-dts` → `... ui-sdk-smp-api type-check` → `... ui-app-smp-settings type-check` → `... ui-app-smp-data type-check` → `pnpm --filter @futurefab/ui-sdk-language type-check` | 五步日志正文均出现被调用的脚本行（`vue-tsc ...` 等），无 `No projects matched` | `DTS_EXIT=0`、`SDK_TC_EXIT=0`、`SETTINGS_TC_EXIT=0`、`DATA_TC_EXIT=0`、`LANG_TC_EXIT=0`（前一次用错包名的 `sdk-language` 步骤是假绿，已在 §4.1 第 4 条勘误） |
| 应用生产构建（日志 `.patch-app-build.log`） | `pnpm --filter @futurefab/ui-app-smp-settings build` | `✓ built in 16.25s`；产物 chunk 名 `batch-management-BWEEdm0q.js`、`culture-management-Bq3N9NfR.js`、`feeding-template-management-CNcA0St0.js`、`use-guarded-write-GzOGMFa6.js` | `APP_BUILD_EXIT=0`（这只证明可构建，门户 :5581 仍供旧哈希包 ⇒ `BLOCKED_DEPLOY`） |

- 前端 14 个红文件清单与 §4 登记的基线**逐条同名**（`config-management`、`detection-workbench-ui`、`dialog-pane-padding`、`dict-tag`、`iconfont-build`、`labgroup-management`、`localization`、`monitor-log`、`navigation`、`profile`、`scroll-pagination`、`settings-filter-toolbar`、`settings-merge-regressions`、`workflow-management`），非本补丁引入。- 与 work5 当日实测的 15 文件 / 29 例相比少 1 文件 2 例（差额在 `config-management`）。本补丁未触碰配置管理页面与其源码，差额应属共享工作副本其他在途面变动，请复审方按当前树复核，不得由我方单方面判定已收敛。
- 分级口径不变：以上只支撑 `IMPLEMENTED` + `CONTRACT_TESTED`。SQL、HTTP、浏览器、设备与现场一律 `NOT_VERIFIED` / `BLOCKED_*`。

## 5. 给独立复审 work 的测试方案

### 5.0 前置条件

1. 后端 `futurefab-system` 需重启到含本批 `DetWorkbenchController` 改动的构建，否则工作台读口仍不带版本 ⇒ 表现按 `BLOCKED_DEPLOY` 记录，不得当作前端缺陷。
2. 门户 :5581 提供的是**已构建哈希包**，不是 HMR 源码。本批未重建应用产物（最后一次构建早于本批），浏览器验收前必须先跑构建并核对 chunk 名，否则测到的是旧包。
3. `packages/sdk-smp-api` 的 `dist`/`dist-types` 为 gitignore 产物；本批已重建 `dist-types`（类型检查依赖它），运行时 `dist` 需随应用构建一并重建。
4. 取证口径（每条必录）：页面名 + 步骤、HTTP method + URL、请求头（重点 `X-Request-Id` / `X-Management-Revision`）、request payload、response body、后端日志是否出现 `RequestMetaInvalidException` / `GlobalExceptionHandler`、测试数据是否清理。注意守卫拒绝只在 WARN 日志与响应体里，`sys_management_request` 只存成功回执。

### 5.1 A 组 · 契约与静态（可离线复核）

| 用例 | 操作 | 期望 |
| --- | --- | --- |
| A1 头真的发出 | `npx vitest run tests/flat-sdk-guarded-write-meta.test.ts` | 7/7；POST/PUT/DELETE 三动词都带 `X-Management-Revision`，URL 与方法逐项对齐（`/dev-api/device/detectoritem`、`/dev-api/resource/project`、`/dev-api/system/role/3%2C4`、`/dev-api/system/role/changeStatus`） |
| A2 不伪造版本 | 同上「反例」例 | 无 meta 时只发 `X-Request-Id`，`X-Management-Revision` 必须 `undefined` |
| A3 版本源不跨模块 | 静态读三个页面 | 检测项读 `detectoritemApi.list`、项目读 `projectApi.list/detail`、角色读 `roleApi.list`，无字面量版本号、无自拼 `X-*` 头 |
| A4 缺版本短路 | 静态 + `settings-extracted-logic` | 五个入口都在发请求前 `return`，提示键 `common.revisionMissing` 中英齐 |
| A5 工作台版本源 | `M05WorkbenchRevisionSourceContractTest` | 4/4；`queue`/`results` 外壳顶层带版本，其余口不得冒充 |
| A6 分页白名单 | `tests/edit-form-prefill.test.ts` | 21/21；候选读取不得用 10/20/50/100 之外的 pageSize |

### 5.2 B 组 · HTTP + 浏览器（结论只允许写实测状态）

| 用例 | 页面与步骤 | 期望 | 状态词 |
| --- | --- | --- | --- |
| B1 工作台读版本 | 进入检测操作台 | `GET /detect/workbench/queue`（网关不加 `/system` 前缀）200，外壳顶层含 `managementRevision` | NOT_VERIFIED |
| B2 改样品号 M05-021 | 行内编辑样品号保存 | `PUT /detect/workbench/result/{id}/sample-no` 200，头含双头；回执覆盖后第二次操作带新版本 | NOT_VERIFIED |
| B3 上传 M05-022 | 结果上传 | `PUT .../upload` 200 | NOT_VERIFIED |
| B4 撤回 M05-023 | 送检人本人撤回 | `PUT .../withdraw` 200；非本人按后端判据拒绝 | NOT_VERIFIED / BLOCKED_DATA（需造 tested 状态数据） |
| B5 打印机排版 M02-112 | 排版弹窗保存 | `POST /lab/printer/{id}/layout` 200，版本来自 M02-111 读口 | NOT_VERIFIED |
| B6 消耗规则 M02-243 | 选实验室+页签后保存 | 保存口带 `X-Management-Revision`，值等于本配置读口外壳值 | NOT_VERIFIED |
| B7 检测项新增 | 新增一个 `QA-W1B-` 前缀检测项 | `POST /device/detectoritem` 200（本批前恒 400） | NOT_VERIFIED |
| B8 检测项修改 | 改名称/单位保存 | `PUT /device/detectoritem` 200 | NOT_VERIFIED |
| B9 角色删除 | 勾选非 1 号角色删除 | `DELETE /system/role/{ids}` 200，被引用时 409 `REFERENCE_EXISTS` 走「先解除引用」文案 | NOT_VERIFIED |
| B10 角色启停 | 停用/启用 | `PUT /system/role/changeStatus` 200；已分配用户的角色停用被后端阻断 | NOT_VERIFIED |
| B11 项目新增 M03-004 | 新建项目 | `POST /resource/project` 200 | NOT_VERIFIED |
| B12 缺头负例 | DevTools 删 `X-Management-Revision` 重放 B7 | 400 `INPUT_INVALID`，页面不得显示成功 | NOT_VERIFIED |
| B13 409 后重取 | 两会话并发（B5 或 B7） | 首次 409 → 本地版本置陈旧 → 用户重试成功且带新版本 | NOT_VERIFIED |
| B14 写失败无脏数据 | B12/B13 负例后回列表 | 无新增/变更记录，测试数据清理完毕 | NOT_VERIFIED |

### 5.3 C 组 · 只读数据库核验（不得写库，未连库即报「未执行」）

- `SELECT request_id, action, result_code, management_revision FROM sys_management_request ORDER BY id DESC LIMIT 30;` 只核对 B 组成功回执是否落，不改。
- `dev_detector_item` / `sys_role` / `res_project` / 打印机排版与消耗规则表：确认 B5—B11 各产生预期行数；未产生时区分 400 / 403 / 409。
- 本批**未连库、未执行任何 SQL**，因此只报「静态检查 + 契约测试通过」，不报建库或迁移通过。

## 6. 测试数据建议

- 统一前缀 `QA-W1B-`，便于 B14 清理与跨批次区分。
- 工作台需要 `tested` 状态结果才能跑 B2/B3/B4；缺主数据时标 `BLOCKED_DATA`，不得改状态字段造数据。
- 并发用例用两个浏览器会话，不用同会话双击代替（幂等键每次点击新生成）。

## 7. 已知风险 / 阻塞与登记（未修，需裁决）

1. **批次 C 待处置清单**：审计在 154 条守卫写口中确认前端仍有 37 处**旧 `modules/**` 重复写定义**不带版本头（`device/*`、`smp/*`、`system/*`、`resource/project`、`lab/lab` 等）。逐条核对后判定：这些定义要么无页面引用，要么指向网关不再映射的死路径（如裸 `/role`、`/config`、`/menu`、`/dict/data`、`/dept`），属批次 C 的 REUSE/ADJUST/COMPAT/DISABLE 处置范围，未经裁决不得自行停用。
2. **仍无前端调用者的守卫写口 59 条**（`alarm/v2/*`、`m06` 审批动作、部分 `lab/*` 设备实例口等）：`NO_UI` / `BLOCKED_MENU`，不是本批缺陷。
3. **死路由**：`projectApi.exit → POST /resource/project/{id}/exit` 映射已被 M03-029 接管、`projectApi.remove → DELETE /resource/project/{ids}` 现只返回 400 `PROTOCOL_UPGRADE_REQUIRED`；两处页面仍在调用，属批次 C 处置。
4. **BODY-ONLY 守卫写**：`POST /system/lab/engineering/profiles`（M02-226）后端不接 `WriteMeta`，与本批「头为权威」口径不一致，保留待裁决。
5. `BLOCKED_MENU`：36 个 M04 功能码与 M02/M05 若干动作码未播种到菜单权限表，授权账号不可用，B 组多条需以超级管理员跑通并注明「只证明链路，不证明授权交付」。
6. `BLOCKED_DEPLOY`：本批只到源码 + 契约测试，Nacos、网关、服务发布与应用产物构建均未做。
7. 全量 vitest 14 个红文件与全模块 2 条双计数红属其他 work 在途/影子副本，未据此判本批失败，也未要求先清红。
8. 前端不实现状态机与冲突仲裁：409 之后是否允许覆盖由后端裁决，页面只做刷新重试与短路。

## 8. 复审 work 测试记录区（由独立 work 回填）

| 用例 | 执行人 | 实测 URL/方法 | 请求头摘要 | response 摘要 | 状态词 | 证据（截图/日志） |
| --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |

## 9. 最终结论区（由总控/独立 work 回填，work1 不自行判完成）

- 可宣称完成：守卫写双头在 7 个页面、11 条写口上**源码级接通**（`IMPLEMENTED`），并由 30 例前端契约测试 + 4 例后端契约测试钉住（`CONTRACT_TESTED`）。
- 仅 `CONTRACT_TESTED`：A1—A6、B1—B14、C 组全部。
- `NOT_VERIFIED`：所有 HTTP / 浏览器 / 数据库项。
- `BLOCKED_MENU`：授权账号与功能码播种；`BLOCKED_DEPLOY`：网关/Nacos/服务/产物；`BLOCKED_DATA`：B4 工作台 tested 态主数据。
- 待裁决：§7 第 1、3、4 条（批次 C 处置与 BODY-ONLY 口径）。
