# M03 批次/培养操作页 · 批次 C 旧写路由处置与前端迁移（work1，2026-10-09）

> 交付登记与测试方案，不是验收结论。浏览器列一律 `NOT_VERIFIED`。
> 派工依据（work5 转总控指令，原文）：「批次C。…优先核查：1. `projectApi.exit/remove`：页面调用点、后端实际路由及 canonical 替代。2. M09 旧版及 M04 遗留写入口：逐条落实已确认的 DISABLE/COMPAT 处置。3. M02-226 BODY-ONLY：核对权威契约，明确后再统一元数据制式。**无引用或网关无映射只是线索，不等于已获删除授权。仍有调用方时必须同步迁移，不能只摘后端映射制造 404。遇未裁事项仅暂停对应子项，继续无冲突部分。**」
> 本批未执行任何 Git 写操作；A/B 复审补丁的文件见 `W1-PATCH-AB-未决请求恢复与未编号读口权限-20261009.md`，两批不混。

## 1. 结论（一句话）

1. **子项 1（M03 旧写路由）**：批次页与培养页的旧写链已迁到 canonical「预览 → 确认 → 守卫写」三段式并接守卫头/缺版本短路；**项目管理页的两个旧调用点按指令暂停**（与批次 B 未提交文件同名冲突），只上报不动代码。
2. **子项 2（M09 旧版 / M04 遗留写入口）**：核查结果是**不存在"已确认的逐条 DISABLE/COMPAT 处置"**——权威文档只给了 M09 的总则（旧 Controller 仅作 COMPAT 适配）与 M04 的 `BLOCKED_REGISTERED`「只登记、不改代码、上报不自行裁决」。因此本批**不摘任何映射、不停任何口**，改为输出解锁清单（§6）。
3. **子项 3（M02-226 制式）**：权威契约**明文 BODY-ONLY**，后端实现与契约一致，**前端零调用方**，因此不存在"缺头缺陷"，也不需要"统一到头制式"的迁移动作；与 AGENTS.md §13.3 字面要求的冲突登记为待裁决（§6 第 4 条）。

## 2. 本批文件清单（批次 C 范围）

### 2.1 前端 SDK（`packages/sdk-smp-api/`）

| 文件 | 改动 |
| --- | --- |
| `src/guarded-delete.ts`（新增） | `DeletePreviewTarget/Blocker/DeletePreview` 类型 + `requestDeletePreview()`；注释登记关键差异：M03-006 发布顶层 `managementRevision`，M03-015/021 预览口**不发布** ⇒ 守卫删的期望版本必须取自**本页自己的列表读口** |
| `src/grant.ts`（新增） | `grantApi.exitPreview(type,id)`、`grantApi.exit(type,id,{requestId,managementRevision,expectedVersion})`；记录 M03-029 当前**无** `@ManagementGuardedWrite`，故元数据走 Body 而非头 |
| `src/batch.ts` | `deletePreview(id)` → `POST /resource/batch/{id}/delete-preview`；`remove(id,{expectedVersion,snapshotToken})` → `POST /resource/batch/{id}/delete`（BODY-ONLY，不发头）；**删除**旧批量 `remove(ids[])` 与 `exit(id)` 两个定义 |
| `src/culture.ts` | 同一形状，但 culture 删除口是头制式：`remove(id,payload,meta: GuardedWriteMeta)` + `headers: writeHeaders(meta)` |
| `src/index.ts` | 导出 `./guarded-delete`（缺该行会导致 `type DeletePreview` 在类型检查里找不到） |

### 2.2 前端页面与共享逻辑（`packages/app-smp-settings/`）

| 文件 | 改动 |
| --- | --- |
| `src/views/batch-management/index.vue` | 删除链改为 预览 → 确认框 → 守卫写；版本取自本页列表读口（`useGuardedWrite`），缺版本用 `REVISION_MISSING` 哨兵短路不发请求；阻塞原因用 `deleteBlockedMessage` 渲染；**移除工具栏批量删除按钮**（依据：M03-040/041 已停用 + 详细设计未给批量删除 UI） |
| `src/views/culture-management/index.vue` | 同上（culture 侧删除带守卫头） |
| `src/shared/grant-exit-facts.ts`（新增） | `readExitFacts(preview,{notDirect,versionMissing})`：`hasDirectMembership !== true` ⇒ 拒绝；预览缺 `target.version` ⇒ 拒绝；否则产出 `{allowed,expectedVersion}`。前端不复制状态机，只把预览事实转成下一次写的入参 |

### 2.3 文案（`packages/sdk-language/src/language/smp-settings/`）

`cn.ts` / `en.ts`：新增 `deleteBlocked`、`exitNoDirectMembership`、`exitPreviewInvalid`，`deleteConfirm` 改单数语义。

### 2.4 测试（`futurefab-frontend/tests/`）

| 文件 | 状态 |
| --- | --- |
| `m03-grant-exit-facts.test.ts`（新增） | 4 例：`readExitFacts` 三个分支 + 逐页源码钉子（`deletePreview`、`grantApi.exitPreview`、`preview?.snapshotToken`、`not.toContain("btn-batch-delete")`） |
| `batch-management.test.ts` | 翻正为 canonical 链（10 例） |
| `culture-management.test.ts` | 翻正为 canonical 链（8 例） |
| `m03-culture-candidate-entry.test.ts` | 方法串翻正 `GET,GET,GET,GET,GET,PUT,POST,PUT,PUT,POST,POST,POST,POST,POST`，并钉 BODY-ONLY：`expect(fetcher.mock.calls[9][1].headers["X-Management-Revision"]).toBeUndefined()`（22 例） |

## 3. 后端路由核对（逐条读码，不靠"网关没映射"当删除依据）

| 前端调用 | 后端映射 | 证据 |
| --- | --- | --- |
| `POST /resource/batch/{id}/delete-preview` | 存在，M03-015 已接线，可删时签发 10 分钟快照令牌 | `ResBatchController.java:56`（类级 `/resource/batch`）、`:256` |
| `POST /resource/batch/{id}/delete` | 存在，M03-007 守卫写（`BatchApplicationServiceImpl#delete` 取 Body 元数据） | `ResBatchController.java:270` |
| `POST /resource/culture/{id}/delete-preview` / `/delete` | 存在，M03-021 预览 + CU03 守卫写 | `ResCultureController.java:73`、`:318`、`:333` |
| `POST /resource/{type}/{id}/exit-preview` / `/exit` | 存在，M03-028 只读预览 + M03-029 单语句 CAS | `ResGrantController.java:30`、`:63`、`:74`（**该类两口均无 `@ManagementGuardedWrite`**） |
| 旧 `PUT /resource/batch/exit`、`PUT /resource/culture/exit` | **仍在**，停用态返回 400 `PROTOCOL_UPGRADE_REQUIRED` + contractId | `ResBatchController.java:201`、`ResCultureController.java:251` |

⇒ 迁移后的四条 canonical 链都有真实映射；两条旧退出口**保持原状**（未摘、未改），前端不再调用它们。

## 4. 已执行验证（2026-10-09，命令 + 退出码 + 正文）

| 命令 | 正文 | 退出码 |
| --- | --- | --- |
| `npx vitest run`（全量，日志 `.patch-fe-full.log`） | `Test Files 14 failed \| 109 passed (123)`；`Tests 27 failed \| 1366 passed (1393)`；本批 4 个文件同趟全绿：`batch-management (10)`、`culture-management (8)`、`m03-culture-candidate-entry (22)`、`m03-grant-exit-facts (4)` | `FE_EXIT=1`（14 个红文件与批次 B 登记基线逐条同名，非本批引入） |
| `pnpm --filter @futurefab/ui-sdk-smp-api build-dts` | 通过（必须真包名，见补丁记录 §4.1 第 4 条假绿勘误） | `DTS_EXIT=0` |
| `pnpm --filter @futurefab/ui-{sdk-smp-api,app-smp-settings,app-smp-data} type-check`、`pnpm --filter @futurefab/ui-sdk-language type-check` | 日志正文均出现实际 `vue-tsc` 行，无 `No projects matched` | 四个 `*_EXIT=0` |
| `pnpm --filter @futurefab/ui-app-smp-settings build` | `✓ built in 16.25s`，chunk：`batch-management-BWEEdm0q.js`、`culture-management-Bq3N9NfR.js`、`use-guarded-write-GzOGMFa6.js` | `APP_BUILD_EXIT=0` |
| 后端 | 本批**零后端改动**，沿用补丁批次的复跑结果（定向 19/36/5/10 `MVN_EXIT=0`；全模块 4162/2 `MVN_EXIT=1`，2 条红为 `.tmp-head-audit/` 影子副本双计数） | — |

## 5. 状态口径（AGENTS.md §13.2）

- `IMPLEMENTED` + `CONTRACT_TESTED`：批次页、培养页的删除/退出写链迁移（源码接真实 canonical Controller 路由，vitest 44 例钉住）。
- `NOT_VERIFIED`：全部 HTTP、浏览器、数据库；未连库、未发真实请求、未操作页面。
- `BLOCKED_DEPLOY`：门户 :5581 仍供旧哈希包；本批虽已产出新构建（§4 chunk 名），但未替换部署产物、未重启服务。
- `BLOCKED_MENU`：M03 删除/退出功能码与 36 个 M04 码未播种；`process:workflow:query/edit` 全仓 SQL 仅 `sql/sys_menu.sql:112` 的 `:list`，遗留口对非超管本就应 403（既有事实，本批未改）。
- `NO_UI`：M02-226 工程资料保存口前端零调用点（`grep -rn "engineering/profiles|engineeringProfile|expectedProfileVersion" packages/ tests/` ⇒ 0 命中）。

## 6. 解锁清单（未裁事项，仅暂停对应子项）

1. **项目管理页旧调用点迁移（子项 1 未完部分）**：`projectApi.exit → POST /resource/project/{id}/exit`（M03-029 已接管该语义）、`projectApi.remove → DELETE /resource/project/{ids}`（现只返 400 `PROTOCOL_UPGRADE_REQUIRED`）。页面 `views/project-management/*` 与 `sdk-smp-api/src/project.ts` 都是**批次 B 未提交文件**，按「涉及 A/B 同文件先报告协调」暂停。解锁需要：批次 B 交 work5 复审并提交后，同批改 `project.ts` + 项目页 + 对应测试（复用本批 `grant-exit-facts.ts` 已经验过的读事实模式）。
2. **M09 旧版 V1 写口**：`物理接口与骨架字段设计.md:7-8` 只给总则「旧 Controller 仅作 COMPAT 协议适配，必须调用同一个 `I*ApplicationService`」，`skeleton-m09.json` 无逐条 DISABLE/COMPAT 标记（全文仅 `:898 "disabledReason"` 一处字段名，不是路由处置）。V1 口在后端仍在映射（`AlarmRecordController.java:38` 等），网关 `/alarm/**` 无 StripPrefix 仍可达，且 `alarm-alarm-record`、`alarm-alarm-mail-config`、`alarm-alarm-notify-receiver`、`alarm-alarm-notify-rule` 四个页面有真实调用点 ⇒ **不得只摘映射**。解锁需要：逐条给出 V1→V2 的 COMPAT 语义核对（是否已共用同一 ApplicationService）+ 是否下线的裁决；裁决后前端才有迁移目标。
3. **M04 遗留写口（M04-017~022）**：`接口目录与契约定位.md:164-178` 明文「本批只登记，不改代码、不翻 wired」，并指出收口只有两条路：按 §11.2 改造并走再生链，或在文档面显式分离登记为 COMPAT；还牵动 `FullSystemSkeletonGateTest`、`SkeletonAnchorRecomputeContractTest`、`port-closure-anchor.json` 的字面量与 `ManagementGuardedWriteArchTest` 门禁面 ⇒ 需共享窗口授权，本批不动。
4. **M02-226 BODY-ONLY**：契约已明确（`工程资料维护与解析逐接口契约.md:96-98` 公共字段在 Body；`:58-60` 引 §1 原文「不再同时要求同名版本 Header」），后端 `LabEngineeringProfileController.java:64-71` 无 `WriteMeta` 形参、`WriteMetaArgumentResolver.java:31` 只对 `WriteMeta` 类型生效 ⇒ 实现与契约一致。剩余唯一未决：AGENTS.md §13.3 的通用"两头"要求与模块契约的 BODY-ONLY 谁优先。**建议口径**（待裁决）：以模块权威契约为准，§13.3 对这类明文 BODY-ONLY 口按"Body 携元数据"解释；将来该页建前端时不得按头制式发。
5. **守卫写事务口径**：`insertReceipt` 与业务写同在 `ManagementGuardExecutor.java:163-164` 的单个 `TransactionTemplate` 内（无 `REQUIRES_NEW`、无 afterCommit），该事实支撑了补丁 1 的"同键重放安全"，但也意味着回执与业务写不可分离——如设计要"回执先落、业务可失败"，需另行裁决（本批只陈述现状）。

## 7. 纪律声明

- 未删除 `.tmp-head-audit/`；未修改任何扫描器/门禁文件；未放宽权限、版本、幂等或失败关闭要求。
- 未摘除任何后端映射；旧 `exit` 停用口保持返回 400 `PROTOCOL_UPGRADE_REQUIRED`。
- 未执行 `git add/commit/push/pull/merge/rebase/reset/stash/restore/checkout/clean`；证据日志均为仓库根被 `.gitignore:86 *.log` 忽略的临时文件，不入提交。
