# M07 前端批次 03 · 残糖确认页面状态与动作入口对齐

> 本批结论先行：**NO_UI / BLOCKED_MENU 交付**。前端不存在 M07 培养运行（残糖/乳酸确认）页面、SDK 请求封装、路由与菜单登记，本批按总控规则「如果定位不到页面，允许该批以 NO_UI / BLOCKED_MENU 交付 MD，但不得强行造页面」执行，**未新增任何页面或路由**。
> 本批产出 = 1 份 MD（本文件）。后端契约、状态机、错误码与「动作入口不可建」的根因已逐条 file:line 登记，供总控裁决与后续批次立项。

## 1. 基本信息

| 项 | 内容 |
| --- | --- |
| 任务 | work1 前端分批开发：M02 / M04 / M07 / M09 页面补齐 |
| 批次 | Batch 03 / 4（Batch 01 M02、Batch 02 M04 已交付并回报） |
| 执行人 | work1（仅前端页面开发，不出具最终测试结论） |
| 批次目标（总控原文口径） | 残糖确认页面状态与动作入口对齐：展示 COUNTDOWN/CONFIRMED/CANCELLED/INVALIDATED；按后端状态开放确认/撤销入口；M05 来源缺口 / BLOCKED_M05 给出可读提示；409 / 版本冲突走刷新重试；守卫写携带双头 |
| 编制时间 | 2026-10-05 开始，2026-10-06 完成（文件名按总控规则固定为 20261005） |
| 仓库 / 分支 | `D:\Code\zhixianweilai\yaoming-cloud`，分支 `cloud` |
| 本批代码改动 | **无**（0 个源码/路由/菜单/测试文件变更） |
| 本批交付层级 | **NO_UI**（页面不存在）+ **BLOCKED_MENU**（无菜单登记）+ **BLOCKED_M05**（写路径后端失败关闭）；HTTP / 浏览器 / 数据库 / 外部设备 **NOT_VERIFIED** |
| 本批禁止并已遵守 | 不 git add、不 commit、不 push；不改后端/SQL/客户材料/history；不强行造页面；不接外部设备；不伪造测量结果；不发设备指令；不伪造 M05 样品校验通过 |
| 权威依据 | `docs/详细设计/07-补液运行与任务执行/任务页面与接口契约.md`、`培养运行操作页与独立入口.md`（DD-20260917，§9 明示「本文是目标设计，未实现页面或接口」）、`计量确认与补液计算契约.md`、`错误码全集.md`、`接口目录与契约定位.md` 定位017—021、`docs/开发基线/01-完整建表.sql`、`docs/开发任务/03-接线与阻塞记录/模块台账与其他/M07-残糖确认写路径批交接-20261005.md`（work10 后端批）、AGENTS.md §13.2/§13.3/§13.6 |

## 2. 修改文件清单

| # | 文件 | 类型 | 行数变化 | 说明 |
| --- | --- | --- | --- | --- |
| 1 | `docs/开发任务/frontend/M07/M07-run-glucose-batch03-confirmation-display-前端交付与测试方案-20261005.md` | 新建（本文件） | +1 | 批次 03 交付物 |

**未修改（本批刻意保持不动）**：`futurefab-frontend/**` 全部源码、路由、菜单、i18n 目录与测试。

**本批为取证只读读取的文件（未修改）**：

- 后端：`controller/run/RunMeasurementController.java`、`controller/run/RunCultureController.java`、`domain/vo/m07/{ConfirmationView,ConfirmationState,ConfirmationSourceSnapshot,GlucoseCandidateView,CultureBalanceView,Issue,Person,SourceRef}.java`、`domain/dto/m07/{ConfirmationCreateCommand,ConfirmationCancelCommand,ConfirmationDetailQuery,ManualResultCreateCommand}.java`、`domain/row/{M07ConfirmationDetailRow,M07ConfirmationWriteRow}.java`、`service/impl/application/m07/{RunMeasurementApplicationApplicationServiceImpl,RunCultureApplicationApplicationServiceImpl}.java`、`resources/mapper/system/RunConfirmationMapper.xml`、`src/test/resources/contract/skeleton-m07.json`
- 前端（存在性检索）：`packages/app-smp-lab/src/router/index.ts`、`packages/app-smp-lab/src/views/{culture-dashboard,lab-overview}`、`packages/sdk-smp-stores/src/{route-paths.generated.ts,navigation.ts,auxiliary-pages.ts}`、`packages/sdk-smp-api/src/guarded-write.ts`、`packages/sdk-smp-api/src/modules/`
- 文档/基线：`docs/详细设计/07-补液运行与任务执行/*`、`docs/开发基线/{01-完整建表,02-基础数据初始化}.sql`、`sql/seed/20261003_m09_menu_perms_install.sql`

## 3. 功能改动说明

### 3.1 为什么本批没有页面改动：前端承载面盘点（全部为「不存在」）

| 检索目标 | 检索范围 | 结果 |
| --- | --- | --- |
| `glucose` / `残糖` / `lactate` / `乳酸` / `manual-results` / `/run/` | `packages/*/src`、`packages/*/tests`（ts/vue/json） | 仅 4 处命中，全部属于 **M04 补液方案**页面的「补糖规则」文案（`feeding-template-editor.vue:1281-1282`、`sdk-language/.../smp-settings/{cn,en}.ts`），与 M07 残糖确认无关 |
| `COUNTDOWN` / `CONFIRMED` / `CANCELLED` / `INVALIDATED` | `packages/*/src` | **0 命中** |
| `confirmation` / `倒计时` | `packages/*/src` | 仅 M05 签批工作台（`app-smp-data/src/views/sign-workbench/*`、`sdk-smp-api/src/sign-console.ts`）与弹窗确认文案，非 M07 计量确认 |
| `sdk-smp-api` 内 M07 请求封装 | `src/*.ts` + `src/modules/`（alarm/detect/device/index/lab/monitor/resource/sdms/smp/subsystem/system） | **无 `run` 模块，无 M07-017—021/029/030 任何封装** |
| 前端路由 | `app-smp-lab/src/router/index.ts:7,12,19`（仅 `:labId/lab-overview`、`:labId/culture-dashboard`、通配兜底）；生成清单 `sdk-smp-stores/src/route-paths.generated.ts`、`navigation.ts`、`auxiliary-pages.ts` | **无 CultureOperations / RunTasks / RunWorkflows / glucose 任何路由或导航登记** |
| 页面目录 | `app-smp-settings/src/views`（87 个页面）、`app-smp-lab/src/views`（2 个）、`app-smp-data/src/views`（16 个） | **无 M07 培养运行/残糖确认页面目录** |
| 菜单登记 | `docs/开发基线/02-基础数据初始化.sql`（`sys_menu` 出现次数 0）；全仓 `INSERT INTO sys_menu` 仅 `sql/seed/20261003_m09_menu_perms_install.sql`（M09） | **无 M07 `run:glucose:*` 菜单/权限种子** |

结论：Batch 03 描述的「残糖确认页面」在当前前端仓库中**不存在承载点**。强行新建页面将违反总控规则「不得强行造页面」，且见 §3.6 的根因：即便建页，两个写动作入口也无法合法装配。

### 3.2 后端 M07 残糖/乳酸域 HTTP 契约现状（供后续批次立项，本批未接）

| 契约 | 方法 + 路径 | 权限 | 守卫写 | skeleton `wired` | 实现状态（源码判定） |
| --- | --- | --- | --- | --- | --- |
| M07-015 | `GET /run/cultures/{id}/balance` | `run:balance:query` | 否 | 缺（=false） | **501 显式骨架**：`RunCultureApplicationApplicationServiceImpl.java:273` `throw new SkeletonNotImplementedException("M07-015")` |
| M07-017 | `GET /run/cultures/{id}/glucose-candidates` | `run:glucose:query` | 否 | true | 双分支：`onlyConfirmed=true` 本地已确认行真实装配；否则候选主体依赖 M05 DET-I07 Port，未接入 503（`RunCultureApplicationApplicationServiceImpl.java:324-328`「M05 候选读取 Port（DET-I07）未接入，候选浏览暂不可用；已确认值可用 onlyConfirmed=true 查询」）**BLOCKED_M05** |
| M07-018 | `POST /run/manual-results` | `run:glucose:add` | **是**（:44） | true | **恒 503 失败关闭**：`requireM05SampleNoCleared`（`RunMeasurementApplicationApplicationServiceImpl.java:352-354`）「M05 全局样品号共同校验 Port 未接入，按契约不允许手工候选登记（BLOCKED：等待 M05 校验 Port 冻结；样品号 … 未写入）」**BLOCKED_M05** |
| M07-019 | `POST /run/confirmations` | `run:glucose:confirm` | **是**（:56） | true | MANUAL 源真实实现；**M05 源恒 503**（同类 :688-689 Port 未接入、:699-700「DET-I06 结果版本视图字段不足以冻结确认源快照（跨模块契约缺口）」）；非 g/L 单位 503（:661-664） |
| M07-020 | `POST /run/confirmations/{id}/cancel` | `run:glucose:confirm` 且本人 | **是**（:69） | true | 真实实现，三分支见 §3.3 |
| M07-021 | `GET /run/confirmations/{id}` | `run:glucose:query` | 否 | true | 真实实现，服务端倒计时（:211-236） |
| M07-029 | `GET /run/cultures/{id}/ledger` | `run:balance:query` | 否 | true | 真实实现（`ledgerMapper.selectCultureLedgerRows`） |
| M07-030 | `GET /run/cultures/{id}/glucose-history` | `run:glucose:query` | 否 | true | 真实实现（`selectConfirmedGlucoseRows` + `selectSettleCalculationRows`） |

**注意（不改后端，仅登记）**：`RunCultureController.java:33,51,60` 的注释仍写 M07-015/029/030 为「契约骨架：应用服务显式 501」，但源码中仅 015 抛 `SkeletonNotImplementedException`，029/030 已接真实 Mapper。注释口径陈旧，登记为 R7。

### 3.3 状态机与「动作入口对齐」表（本批未实现，作为后续批次的验收标准）

`run_confirmation.state` 取值由 DDL 约束固定：`docs/开发基线/01-完整建表.sql:3140,3152` `ck_m07_confirmation_state` = `COUNTDOWN / CONFIRMED / CANCELLED / INVALIDATED`；`3154` `ck_m07_confirmation_deadline` 强制 `deadline_at = selected_at + 60s`；`3150` `uk_m07_confirmation_daily` + `3148` `active_slot` 生成列保证「本日每类最多一个 COUNTDOWN 或 CONFIRMED」。

| 状态 | 展示要求 | 可开放动作（前端入口） | 后端对该动作的实际判定 |
| --- | --- | --- | --- |
| COUNTDOWN | 显示服务器倒计时 | 「确认（到期完成）」与「撤销」**仅原确认人本人** | 撤销（`now<deadline_at`）→ CANCELLED，`invalid_reason` 固定 `OPERATOR_CANCELLED`（Impl:536-543）；到期（`now≥deadline_at`）→ 走 60s 完成事务（Impl:558-612） |
| CONFIRMED | 显示生效时刻 `confirmedAt` | **无任何动作入口** | 再次取消 → 409 STATE_CONFLICT「同日有效已确认值不可再次确认、编辑或撤回」（Impl:529-532） |
| CANCELLED | 终态，显示取消时刻与原因 | 无 | 再次取消 → 409 STATE_CONFLICT「该确认已终结（CANCELLED），不可重复处理」（Impl:530-532） |
| INVALIDATED | 终态，显示 `invalid_reason` 与「需重新选择来源」 | 无（须回到候选重选） | 同上，已终结 409 |

到期完成的**兜底触发不在后端本批**（work10 交接文档 §3.4 明示「021 查询懒完成或 job 扫描不在本批」）：用户确认离开页面后，该行会**保持 COUNTDOWN 直至后续交互**。这意味着前端倒计时归零**不得**自行改判为 CONFIRMED/INVALIDATED，必须重新调用 M07-021 取权威状态（这是本批最关键的对齐约束，登记为 R5）。

### 3.4 倒计时与快照展示口径（读口 M07-021 的真实能力边界）

- `remainingSeconds` 仅在 `state=COUNTDOWN` 且 `deadline_at` 非空时返回，且 `Math.max(0L, seconds)` 截断为 0、**不会为负**（Impl:1007-1015）。其他状态返回 `null` ⇒ 前端必须显示「—/无倒计时」，不得显示 0 或自行推算。
- `deadline` 由服务端时钟（注入 Clock，上海业务日基准）权威给出（Impl:230、`ConfirmationView.java:20-24`「刷新、换浏览器、关闭弹窗不重置」）⇒ 前端不得以本地时间起算 60s。
- `issues` 恒为空列表（Impl:235 `view.setIssues(new ArrayList<>())`，类级登记 :115「issues 恒为空列表（副状态码词表未在权威契约冻结）」）⇒ 前端**不能**依赖 `issues` 给出 M05 缺口提示，只能依赖 HTTP 错误码与 message。
- `sourceSnapshot` 的 13 个叶子（`ConfirmationSourceSnapshot.java:16-44`）中，手工来源下 `quality`/`status`/`detectorRef`/`eligibilityPolicy` 由后端显式置 `null`（Impl:676-681），M05 来源永不成功（§3.2）。⇒ 展示必须按契约「缺值不用 0 代替」（`ConfirmationSourceSnapshot.java:25`），原单位 `originalUnit` 原样透出，不得换算。

### 3.5 错误码可读提示与 409 处理口径（本批给出规格，未落代码）

M07 模块码→HTTP 状态（`docs/详细设计/07-补液运行与任务执行/错误码全集.md:9,11,12,28,30,31,33`）：

| 码 | HTTP | 本域触发点（file:line） | 前端应给出的可读提示方向 | 重试语义 |
| --- | --- | --- | --- | --- |
| DEPENDENCY_UNAVAILABLE | 503 | :352(018 M05 样品号校验)、:663(非 g/L 换算未核准)、:688/:699(M05 源快照)、`RunCulture…Impl:327`(DET-I07 候选) | 「M05 样品/结果校验能力未接入，本次登记/确认未生效」——必须明说**未写入**，不得写成失败可重试成功 | 「先查原请求结果；确认未生效且依赖恢复后按原键」；保留非敏感草稿 |
| VERSION_CONFLICT | 409 | :410(运行版本)、:526(确认对象版本)、:543/:571/:588(并发)、:600(完成回滚)、:636(手工候选版本) | 「对象已被他人或服务器改变，请刷新后重新确认」 | **刷新重试**：重新读取事实后由用户明确提交，不自动覆盖（`培养运行操作页与独立入口.md:48`） |
| STATE_CONFLICT | 409 | :422(同日槽位)、:440/:445(写入/并发槽位)、:530(已 CONFIRMED/已终结)、:632(候选归属不一致) | 「本培养本业务日该指标类已有倒计时或已生效确认」/「该确认已终结」 | 不自动重试；立即撤去动作入口并重新读取 |
| PERMISSION_DENIED | 403 | :522(取消须原确认人本人)、:1003 培养不在可操作范围、:956/:988 身份缺失 | 「无权限：撤销必须由原确认人本人操作」 | 不自动重试；403 后清除该组件敏感缓存（`…独立入口.md:48`） |
| RESOURCE_IN_USE | 409 | :302/:323(样品号已被占用，含 M05 保留值) | 「样品号已被占用，未登记」 | 不自动重试 |
| CONFIGURATION_INCOMPLETE | 409 | :292(018 无运行守卫)、:406(019 无运行守卫)、:594(020 完成时守卫行缺失) | 「该培养当前无运行守卫（未连接），不可确认」 | 不自动重试；纠正配置 |
| CALCULATION_PRECONDITION_FAILED | **422** | :653(候选缺项)、:658(数值缺失或为负) | 「所选指标项缺失或数值非法，不可确认」；契约要求「不得补 0」（`错误码全集.md:9`） | 纠正输入 |
| NOT_FOUND | 404 | :628(手工候选不存在)、`notFound("确认")`:219/:225/:510/:517/:710 | 不存在与范围外**统一 404 不泄露存在性**（Impl:207 注释） | 刷新列表 |

### 3.6 阻断「动作入口」的真实根因：两个版本号没有 HTTP 出口（本批核心发现）

守卫写链本身可用（`writeHeaders`，`sdk-smp-api/src/guarded-write.ts:20-27`：`X-Request-Id` 必带、revision 缺失时**不发该头**由后端 400 明确拒绝，不伪造版本）。但即使新建页面，M07-019 与 M07-020 的**业务版本号无法取得**：

1. **M07-019 需要 `expectedRuntimeVersion`**（`ConfirmationCreateCommand.expectedRuntimeVersion`；`RunMeasurementApplicationApplicationServiceImpl.java:371` 强制 `parsePositiveLong`，:408 不匹配即 409 VERSION_CONFLICT）。全仓唯一暴露 runtime `objectVersion` 的 VO 是 `CultureBalanceView.java:17-18`（注释明示「供 API16/API19 的 expectedRuntimeVersion」），而该视图的出口 **M07-015 是 501 骨架**（Impl:273）。`domain/vo/m07/` 下再无第二个含 runtime 版本的 VO（`grep -rln RuntimeVersion domain/vo/m07/` 仅命中 `CultureBalanceView.java`）。
2. **M07-020 需要 `expectedVersion`**（`ConfirmationCancelCommand.expectedVersion`；Impl:524-527 不匹配即 409）。HTTP 唯一可能来源是 `ConfirmationView.objectVersion`（`ConfirmationView.java:24,46-47`，DDL 有列、XML 有投影：`RunConfirmationMapper.xml:49` `c.object_version`），但**两个装配点都未调用 `view.setObjectVersion(...)`** —— `getConfirmation`（Impl:227-235）与 `executionView`（Impl:712-720）均只设 confirmationId/state/deadline/remainingSeconds/sourceSnapshot/actor/confirmedAt/issues（`grep -n setObjectVersion` 在 Impl 内只命中行对象 :336/:461/:549/:577/:606/:871 与 `SourceRef` :1141，无一处命中 ConfirmationView）。⇒ **响应里的 `objectVersion` 恒为缺失**。
3. 按 AGENTS.md §13.3「不得硬编码 revision、不得从无关模块借 revision、拿不到时必须短路不发写请求」，前端**不得**用猜测值 `1` 或从其他模块借版本填这两个字段。因此确认/撤销入口在当前契约下只能建为「永远短路 + 提示不可用」的假入口，属误导实现，本批拒绝。
4. 同时，`controller/run/` 目录内 `grep -rn CurrentManagementRevision` **零命中**（4 处命中全是 `RunMeasurementController.java:27` 的批注文案与 3 个 `@ManagementGuardedWrite`）。⇒ 残糖确认域没有任何读口在响应顶层返回 `managementRevision`，守卫写所需的第二个头同样无本页面自有出口。§13.3 规定此时应「优先核对后端 Controller 是否缺少 `@CurrentManagementRevision`」，本批依「不改后端」只登记不修（R1、R2、R3）。

### 3.7 后续批次（非本批）应当满足的守卫写口径

- 页面自有读口必须先能返回顶层 `managementRevision`（后端补 `@CurrentManagementRevision`，参照 `DevDetectorController.java:159` 已落地的同类做法）。
- `expectedRuntimeVersion` / `expectedVersion` 必须有真实 HTTP 出口（015 落地，或 021 装配补 `setObjectVersion`）。
- 前端在两个版本号与 revision 任一缺失时**短路不发**，并给出「未取得对象版本，暂不可提交」的可读原因，绝不发缺头请求让后端 400 兜底当作正常流程。
- 提交 409 后：保留可保留的非敏感输入供比较 → 重新读取 → 由用户明确提交，不自动覆盖（`培养运行操作页与独立入口.md:48`）。

### 3.8 四条批次目标逐条交付口径

| # | 总控目标 | 本批状态 | 依据 |
| --- | --- | --- | --- |
| 1 | 展示 COUNTDOWN/CONFIRMED/CANCELLED/INVALIDATED 四态 | **NO_UI**（无页面可展示）；取值集合、约束与语义已 §3.3 登记 | `01-完整建表.sql:3140,3152`、`ConfirmationState.java:15` |
| 2 | 按后端状态开放确认/撤销动作入口 | **BLOCKED**：019 缺 `expectedRuntimeVersion` 出口、020 缺 `objectVersion` 出口（§3.6） | Impl:371/408、Impl:227-235/712-720、`RunConfirmationMapper.xml:49` |
| 3 | M05 来源缺口 / BLOCKED_M05 可读提示 | **规格已交付（§3.5）**、实现 NO_UI；且后端 `issues` 恒空，提示只能来自 HTTP 错误码（§3.4） | Impl:352-354/688-689/699-700、`RunCulture…Impl:324-328`、`M07-残糖确认写路径批交接-20261005.md` §3.1/3.2/3.5 |
| 4 | 409 / 版本冲突走刷新重试；守卫写携带双头 | **规格已交付（§3.5/§3.7）**、实现 NO_UI；双头工具已存在且行为正确（不发伪造头） | `guarded-write.ts:16-27`、AGENTS.md §13.3 |

## 4. 已执行验证命令与结果

本批**零源码改动**，故不适用构建/单测；验证对象是「页面不存在」与「契约事实」两类断言，全部为只读检索与静态阅读。

| # | 命令 / 检查 | 层级 | 结果 |
| --- | --- | --- | --- |
| V1 | `grep -rn "glucose\|残糖\|manual-results\|/run/\|乳酸\|lactate" --include=*.ts --include=*.vue --include=*.json packages/*/src packages/*/tests` | 静态检索 | 6 命中，全部为 M04 补液方案文案（`feeding-template-editor.vue:1281-1282` + `smp-settings/{cn,en}.ts`），无 M07 承载 |
| V2 | `grep -rn "COUNTDOWN\|CONFIRMED\|INVALIDATED" packages/*/src` | 静态检索 | 0 命中 |
| V3 | `ls packages/sdk-smp-api/src/modules` | 静态检索 | 无 `run` 目录 ⇒ 无 M07 请求封装 |
| V4 | `grep -n "path" packages/app-smp-lab/src/router/index.ts` | 静态检索 | 仅 `:labId/lab-overview`、`:labId/culture-dashboard`、`:pathMatch(.*)*` 三条 |
| V5 | `grep -rn "run\|glucose" packages/sdk-smp-stores/src/{navigation.ts,auxiliary-pages.ts,route-paths.generated.ts}` | 静态检索 | 0 命中（清单无 M07 条目） |
| V6 | `grep -c "sys_menu" docs/开发基线/02-基础数据初始化.sql`；`grep -rln "INSERT INTO sys_menu" --include=*.sql .` | 基线检索 | 前者 0；后者仅 `sql/seed/20261003_m09_menu_perms_install.sql` ⇒ BLOCKED_MENU 有静态依据 |
| V7 | `pnpm run routes:check`（`futurefab-frontend/`） | 静态检查 | **exit=0 通过**（路由清单与生成物一致，本批未触碰） |
| V8 | `grep -rn "@ManagementGuardedWrite\|CurrentManagementRevision" controller/run/` | 后端静态 | 守卫写 3 处（`RunMeasurementController.java:44,56,69`）；`@CurrentManagementRevision` **0 处** |
| V9 | `grep -n "setObjectVersion" service/impl/application/m07/…Impl.java domain/vo/m07/ConfirmationView.java` | 后端静态 | ConfirmationView 只有 setter 定义（:47），Impl 内无对视图的赋值 ⇒ §3.6 第 2 条成立 |
| V10 | 读 `docs/开发基线/01-完整建表.sql:3129-3156`、`RunConfirmationMapper.xml:48-57`、`skeleton-m07.json`（017—021 wired=true，015 无 wired） | 契约静态 | 与 §3.2/§3.3 一致 |
| V11 | 读 `docs/开发任务/03-接线与阻塞记录/模块台账与其他/M07-残糖确认写路径批交接-20261005.md`（work10 批，后端层级 IMPLEMENTED+CONTRACT_TESTED，全链 NOT_VERIFIED） | 交叉印证 | 与本批静态判定无冲突；未据此把任何后端事项宣称为已联调 |

未运行：前端 `type-check` / `build-dts` / 生产构建 / vitest（无源码改动，运行它们对本批结论无增量证据；仓库基线由 Batch 02 回报时的绿灯记录覆盖）。未执行任何 SQL、未发起任何 HTTP 请求。

## 5. 给 work5 的详细测试方案

**本批无 UI，不存在浏览器验收对象。** work5 的任务是复核「NO_UI 判定是否成立」与「契约登记是否属实」，而不是给不存在的页面编造用例。

### 5.1 A 组 · NO_UI 判定复核（离线可执行，全部只读）

| 用例 | 步骤 | 期望 |
| --- | --- | --- |
| A1 | 重跑 §4 V1—V5 五条前端检索 | 命中集合与 §3.1 表格完全一致，无 M07 页面/封装/路由 |
| A2 | 打开门户 `:5581`，遍历左侧菜单与全局搜索 | 检索「残糖/确认/培养运行/run」无任何 M07 入口（**若发现入口，本批判定作废，立即回报总控**） |
| A3 | `pnpm run routes:check` | exit=0（确认 work1 未改路由） |
| A4 | `git status --short` 与 §2 文件清单比对 | 除本 MD 外无 work1 新增/修改的前端文件 |

### 5.2 B 组 · 契约事实复核（后端侧，只读，不改代码）

| 用例 | 核验点 | 期望 |
| --- | --- | --- |
| B1 | `RunMeasurementController.java:44,56,69` | 018/019/020 三个写口均带 `@ManagementGuardedWrite`；021 无守卫注解、只读 |
| B2 | `controller/run/` 内 `@CurrentManagementRevision` | 0 命中（R3 成立） |
| B3 | Impl:227-235 与 712-720 | 两个视图装配点均无 `setObjectVersion`（R1 成立） |
| B4 | Impl:273（RunCulture） | 仅 M07-015 抛 `SkeletonNotImplementedException`；029/030 已接 Mapper（R7 注释陈旧成立） |
| B5 | Impl:352-354、661-664、688-689、699-700；`RunCulture…Impl:324-328` | 四处 M05 相关失败关闭均为 DEPENDENCY_UNAVAILABLE(503)，且文案声明「未写入/暂不可用」 |
| B6 | Impl:1007-1015 | `remainingSeconds` 仅 COUNTDOWN 非空，负值截断为 0 |
| B7 | Impl:235 + 类注释 :115 | `issues` 恒空列表 |
| B8 | `01-完整建表.sql:3140,3148,3150,3152,3154` | 四态 CHECK、`active_slot` 生成列、同日唯一槽位、60s deadline CHECK 与代码一致 |

### 5.3 C 组 · 只读数据库核验（**不得写库；需总控授权后执行**）

```sql
-- C1 表与约束就位（只读）
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'run_confirmation' ORDER BY ORDINAL_POSITION;
SELECT CONSTRAINT_NAME, CHECK_CLAUSE FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
 WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME LIKE 'ck_m07_confirmation%';

-- C2 状态分布（只读，无数据即说明后端写路径从未真实执行）
SELECT state, COUNT(*) AS n FROM run_confirmation GROUP BY state;

-- C3 倒计时一致性（只读）
SELECT confirmation_id, state, selected_at, deadline_at, confirmed_at, object_version, invalid_reason
  FROM run_confirmation
 WHERE TIMESTAMPDIFF(SECOND, selected_at, deadline_at) <> 60;   -- 期望 0 行

-- C4 权限/菜单是否已安装（只读；期望 0 行 ⇒ 印证 BLOCKED_MENU）
SELECT menu_id, menu_name, perms FROM sys_menu WHERE perms LIKE 'run:glucose:%' OR path LIKE '%run%';
```

判定口径：C2/C3 返回 0 行只能说明**未真实执行过写入**，不得据此判定功能正常；C4 返回 0 行支持本批 BLOCKED_MENU 结论。

### 5.4 work5 不得做的事

- 不得因 work1 交付 MD 就出具「残糖确认功能通过」结论；本批可宣称项见 §9。
- 不得通过 SQL 直插 `run_confirmation` 造数来「测出」页面（表有 `uk_m07_confirmation_request`、`active_slot`、deadline CHECK，插入口径与业务事务不等价）。
- 不得为让页面出现而要求 work1 补一个只有假按钮的壳（§3.6 根因未解即建页 = 误导实现）。
- 不得放宽后端 `WriteMeta` 校验、不得删除 `@ManagementGuardedWrite` 来「让写口通起来」（AGENTS.md §13.3）。

## 6. 测试数据建议

- **本批无需前端测试数据**（无页面）。
- 后续批次（真正建残糖确认页时）的前置数据条件，现阶段只能由后端联调自然产生，**不得手工 SQL 造**：
  1. 一个 `run_culture_runtime` 守卫行存在（否则 019 恒 409 CONFIGURATION_INCOMPLETE「培养未连接」，Impl:406）；
  2. 一条 MANUAL 手工候选行（**当前不可能**：018 恒 503，§3.2）；
  3. 一条 M05 结果版本行（**当前不可能**：DET-I06/DET-I07 Port 未接入）。
- 由此可推出：即使页面建成，**唯一可端到端演示的路径当前也不存在**（019 的 MANUAL 源需要有 018 的产物，而 018 恒 503）。请在 §9 结论中保留这条判断。
- 单位口径：手工候选指标单位仅接受 `g/L` 原值，其他单位 503（Impl:661-664）；建议测试值统一 g/L，不测试换算。

## 7. 已知风险 / 阻塞

| ID | 事项 | 类别 | 处置 |
| --- | --- | --- | --- |
| R1 | **M07-020 的 `expectedVersion` 无 HTTP 出口**：`ConfirmationView.objectVersion` 在 `getConfirmation`（Impl:227-235）与 `executionView`（Impl:712-720）两处装配均未赋值，尽管 DDL 有列、XML 有投影（`RunConfirmationMapper.xml:49`） | BLOCKED（后端契约缺口） | 转总控/work10。前端不猜测版本号、不硬编码 1（AGENTS §13.3） |
| R2 | **M07-019 的 `expectedRuntimeVersion` 唯一出口 M07-015 是 501 骨架**（Impl:273），`domain/vo/m07/` 内无第二个暴露 runtime 版本的 VO | BLOCKED（后端契约缺口） | 转总控/work10，与 work10 交接文档 §4「015 balance 卡总控裁决」合并裁决 |
| R3 | `controller/run/` 无 `@CurrentManagementRevision`，残糖确认域读口不返回顶层 `managementRevision` ⇒ 守卫写第二个头无自有出口 | BLOCKED（后端契约缺口） | 转总控；修法参照 `DevDetectorController.java:159`，并需契约测试证明外壳带该字段 |
| R4 | M07-018 手工候选登记恒 503（M05 全局样品号共同校验 Port 未声明，Impl:352-354） | **BLOCKED_M05** | 非前端可解；等 M05 校验 Port 冻结（work10 交接 §3.1） |
| R5 | 到期完成无兜底触发（021 不懒完成、无 job）⇒ 离开页面后行长期停留 COUNTDOWN | 设计风险 | 前端后续批次实现时**必须**「倒计时归零只重读 021，不改判状态」；本轮仅登记 |
| R6 | `ConfirmationView.issues` 恒空 ⇒ M05 缺口提示只能依赖 HTTP 码/消息 | 契约风险 | 后续批次提示文案须走错误码映射，不得指望 `issues` |
| R7 | `RunCultureController.java:33,51,60` 注释仍称 015/029/030 为 501 骨架，与源码（仅 015 为 501）不符 | 文档陈旧 | 本批不改后端；建议 work10 顺手更正注释，不影响结论 |
| R8 | 前端无任何 `run:glucose:*` 菜单/权限种子（`02-基础数据初始化.sql` 无 `sys_menu` 插入） | BLOCKED_MENU | 需总控决定菜单/权限安装批次；届时另立前端批次 |
| R9 | M07 残糖域属「培养运行操作页 CultureOperations」这一**目标设计**（`培养运行操作页与独立入口.md:9` 明示未实现），单点建「残糖确认页」与该设计的区域化承载结构冲突 | 范围/设计裁决 | 建议总控先裁决页面承载形态（独立页 vs CultureOperations 的 glucose 区），再排前端批次 |
| R10 | 本批验证层级仅为静态检索与文档阅读 | 口径约束 | 不得据此宣称任何 HTTP/浏览器/数据库/外部系统结论 |

## 8. work5 测试记录区

（由 work5 回填；work1 不预填任何结果。）

| 用例 | 执行日期 | 环境 | 结果（PASS/FAIL/BLOCKED） | 证据（命令输出/截图/HTTP 与 response body） | 备注 |
| --- | --- | --- | --- | --- | --- |
| A1 |  |  |  |  |  |
| A2 |  |  |  |  |  |
| A3 |  |  |  |  |  |
| A4 |  |  |  |  |  |
| B1—B8 |  |  |  |  |  |
| C1—C4 |  |  |  |  | 需总控授权（只读 SELECT） |

## 9. 最终结论区（由总控/work5 回填，work1 不自行判完成）

**work1 本批可以宣称完成的事项（仅此三项）**：

1. M07 残糖/乳酸确认域的前端承载面盘点已完成，结论 **NO_UI + BLOCKED_MENU**（§3.1，A1/A2/C4 可复核）。
2. 后端 M07-015/017/018/019/020/021/029/030 的状态、守卫属性、wired 标记与四态状态机已按 file:line 登记（§3.2、§3.3）。
3. 四条批次目标的**可执行规格**（状态展示口径、动作入口判定、错误码→提示与重试语义、守卫双头与短路规则）已交付（§3.4、§3.5、§3.7），可作为后续前端批次与 work9 浏览器验收的判据。

**work1 明确不得被宣称的事项**：

- 不得写「残糖确认页面已完成/可操作」「四态展示已实现」「确认与撤销入口已对齐」——页面不存在，本批为 NO_UI。
- 不得写「守卫写双头已接线」——前端无该域任何请求封装。
- 不得写「M05 缺口提示已上线」——§3.5 是规格，非实现。
- 不得写「后端 M07 写路径已联调」——work10 批自身声明 SQL/HTTP/浏览器/设备均 NOT_VERIFIED。
- 不得把本批的静态检查（§4）当作 HTTP_VERIFIED 或 BROWSER_VERIFIED（AGENTS.md §13.2、§13.7）。

**待总控裁决**：R1、R2、R3（三个版本号/修订号 HTTP 出口缺口）、R8（菜单与权限安装批次）、R9（CultureOperations 承载形态）。这五项未解前，M07 残糖确认的前端批次不应开工。
