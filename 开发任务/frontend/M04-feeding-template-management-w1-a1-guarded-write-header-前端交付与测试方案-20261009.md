# M04 前端批次 W1-A1 · 补液方案模板页守卫写头制式接线（缺版本短路 / 双头 / 409 刷新重试）

> 本文件是**测试方案与交付登记**，不是验收结论。浏览器列全部标记 `NOT_VERIFIED`，由独立 work 只读复审后实跑回填。
> 对应后端批次：批次 A（M04 权限与守卫元数据收口 + WriteMeta Header 制式）。

## 1. 基本信息

| 项 | 内容 |
| --- | --- |
| 执行人 | work1 |
| 日期 | 2026-10-09 |
| 页面 | 工艺模板管理（补液方案）`/settings/feeding-template-management` |
| 源码目录 | `futurefab-frontend/packages/app-smp-settings/src/views/feeding-template-management/` |
| 覆盖接口 | M04-006 新建（POST `/process/templates`）、M04-007 修改（PUT `/{id}`）、M04-008 复制（POST `/{id}/copies`）、M04-009 状态变更（PUT `/{id}/status`）、M04-010 删除（POST `/{id}/delete`）—— 5 条守卫写口 |
| 版本来源接口 | M04-011 列表 `GET /process/templates/list`（网关前缀后为 `/system/process/templates/list`，响应外壳顶层 `managementRevision`） |
| 依赖前端能力 | `packages/app-smp-settings/src/shared/use-guarded-write.ts`、`packages/sdk-smp-api/src/guarded-write.ts`（`writeHeaders`）、`pageRowsWithRevision` |
| 交付状态口径 | 最高 `CONTRACT_TESTED`（vitest + 类型检查 + 构建）；HTTP / 浏览器 `NOT_VERIFIED`；菜单权限 `BLOCKED_MENU` |

## 2. 本批修改文件清单

### 2.1 前端生产代码（4 个文件）

| 文件 | 改动 |
| --- | --- |
| `packages/app-smp-settings/src/views/feeding-template-management/index.vue` | 接入 `useGuardedWrite`：新增 `reloadRevision()`（重读列表口顶层 `managementRevision`）、`ensureRevision()` 短路口径 `abortForMissingRevision()`、写失败 `invalidateOnConflict(e)`；编辑器传 `:management-revision="revision"`，`@conflict="reload"` |
| `packages/app-smp-settings/src/views/feeding-template-management/feeding-template-editor.vue` | 新增 `props.managementRevision`；保存前校验为纯数字版本，缺失即不发请求；409/`MANAGEMENT_CONFLICT` 时 `emit("conflict")` 交列表页刷新版本 |
| `packages/app-smp-settings/src/views/feeding-template-management/m04-template-error.ts` | 批次 E 文档对齐：把「M04 写口当前未挂守卫」的过期说明改写为现行事实（5 口已挂 `@ManagementGuardedWrite`，`MANAGEMENT_CONFLICT` 与缺 `X-Management-Revision` 的 400 `INPUT_INVALID` 均为真实可达）；登记 `FORBIDDEN` / `AUTH_DEPENDENCY_UNAVAILABLE` 两个权限码口径 |
| `packages/sdk-language/src/language/smp-settings/cn.ts` / `en.ts` | 新增 3 个键：`errorForbidden`、`errorAuthDependencyUnavailable`、`revisionMissing` |

### 2.2 前端测试（1 改 1 新）

| 文件 | 状态 |
| --- | --- |
| `futurefab-frontend/tests/m04-guarded-write-wiring.test.ts` | 新增，6 例 |
| `futurefab-frontend/tests/m04-m09-blocked-hints.test.ts` | 翻正 1 例过期断言（原钉「当前未挂守卫」，现钉「已挂 + 真实可达」），并补 FORBIDDEN / AUTH_DEPENDENCY_UNAVAILABLE 双目录登记检查 |

### 2.3 明确未触碰

- `packages/sdk-smp-api/src/processTemplate.ts`（本批无需改：`writeHeaders` 已在，双头由页面喂值）
- 其他模块页面、其他业务模块的后端代码、`docs/接口文档/` 等客户只读材料
- `skeleton-m04.json` 登记账本（未改 wired 计数、未新增或伪造接口编号）
- 数据库脚本、Nacos 配置、网关配置：本批零改动

## 3. 功能改动说明（为什么这样改）

### 3.1 版本（revision）的唯一来源

AGENTS.md §13.3：`X-Management-Revision` 必须来自**本页对应列表/详情口返回的顶层 `managementRevision`**，不得硬编码、不得借无关模块。

- 后端 `ProcessTemplateController` 列表口已标 `@CurrentManagementRevision`，响应外壳顶层带该字段（本批实测在 `M04WiredReadPathContractTest` / `M03WiredReadContractTest` 钉住）。
- SDK `processTemplateApi.list` 走 `pageRowsWithRevision`，把外壳顶层版本透出给页面。
- 页面 `revision` ref 只在这条链上被赋值；`reloadRevision()` 重新读列表口，不读别的模块。

### 3.2 缺版本必须短路，不许硬打

`index.vue` 状态变更与删除的确认回调：

```ts
const currentRevision = await ensureRevision();
if (!currentRevision) {
  toggleDialog = undefined;      // 关闭确认框
  abortForMissingRevision();     // 提示“未取到管理版本，已取消本次操作，请刷新列表后重试”
  return;                        // 不发这一枪
}
```

编辑器 `save()` 同样先校验 `props.managementRevision` 是纯数字，否则直接给出本地提示、不发请求。
理由：后端 `WriteMetaArgumentResolver` 缺 `X-Management-Revision` 恒定抛 `RequestMetaInvalidException` → 400 `INPUT_INVALID`，前端把它当业务失败展示会误导用户，也会掩盖真正的契约缺口。

### 3.3 双头由页面喂值、SDK 组头

页面构造 `requestId`（UUID）与 `managementRevision`，SDK `writeHeaders()` 组 `X-Request-Id` + `X-Management-Revision`。Header 为权威：Body 里同名字段只是命令对象的一部分，后端以 Header 覆盖（`M03WriteMetaHeaderContractTest` / `M04WriteMetaHeaderContractTest` 已钉）。

### 3.4 409 冲突刷新重试

`invalidateOnConflict(e)` 在 `ApiError.code === 409` 或 `errorCode === "MANAGEMENT_CONFLICT"` 时把本地版本标记为陈旧，下一次操作前重新 `reloadRevision()`；编辑器冲突通过 `emit("conflict")` → 列表页 `@conflict="reload"` 触发整页重载。文案走 `m04-template-error.ts` 映射，不吞后端明细。

## 4. 已执行验证命令与结果（2026-10-09，目录 `futurefab-frontend/`）

| 顺序 | 命令 | 结果 |
| --- | --- | --- |
| 1 | `pnpm --filter @futurefab/app-smp-settings run type-check`（或等价 vue-tsc 定向检查） | 0 error |
| 2 | `pnpm --filter sdk-language run type-check` | 通过 |
| 3 | `routes:check` | 通过 |
| 4 | `npx vitest run --config vitest.config.ts tests/m04-guarded-write-wiring.test.ts` | **6 / 6 通过** |
| 5 | `npx vitest run --config vitest.config.ts tests/m04-m09-blocked-hints.test.ts` | **8 / 8 通过** |
| 6 | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | 通过（`dist-types` 已 gitignore，未产生跟踪文件变更；此前 app 侧类型报错即由该陈旧产物导致） |
| 7 | `npx vitest run --config vitest.config.ts`（全量） | Test Files **14 failed \| 104 passed (118)**；Tests **27 failed \| 1326 passed (1353)** |
| 8 | 应用构建（`app-smp-settings` 生产构建） | 退出码 0 |
| 9 | `packages/sdk-language` dist 重建 | 已重建，含 3 个新键 |

全量红文件清单（本批归因背景，非本批引入）：
`config-management`、`detection-workbench-ui`、`dialog-pane-padding`、`dict-tag`、`iconfont-build`、`labgroup-management`、`localization`、`monitor-log`、`navigation`、`profile`、`scroll-pagination`、`settings-filter-toolbar`、`settings-merge-regressions`、`workflow-management`。

- 本批两个测试文件在同一次全量运行里均为绿（`✓ m04-guarded-write-wiring (6)`、`✓ m04-m09-blocked-hints (8)`）。
- 失败正文全部指向日志迁移列表、场地（venue）编辑、实验室组分页快照、参数配置快照、弹窗内边距与图标登记，**无一条命名 `feeding-template`**。
- 与既有基线（`venue-management` 在红、`settings-merge-regressions` 不在红）相比成员有 1 进 1 出的变化，属其他 work 在途改动，已按实际测量重报，不沿用旧清单。

### 4.1 后端证据补记与勘误指针（补丁批次 2026-10-09）

- 本节 §4 只登记了前端命令与结果；批次 A 的后端数字（定向 698 条 0 失败、system 模块全量 4155 条 2 失败）当时只写在提交正文 `3e892628` 里，**没有逐字 surefire 行、没有退出码**，且"全量 4155/2"那次实为 `BUILD FAILURE`。
- 提交正文已入库不可改（Git 由用户操作），因此在此登记勘误：全量存在失败，批次 A 不得被读成"全模块通过"；可用口径只有 `IMPLEMENTED` + `CONTRACT_TESTED` + 定向绿 + 全模块 2 条已归因红。
- 退出码取错的根因（管道 `tee|grep` 使 `$?` 取到 `grep` 的码、后台任务通知的 `exit code 0` 属包装 shell）与正确取码方式，统一登记在
  `M02-M05-M01-M03-w1-b-guarded-write-header-前端交付与测试方案-20261009.md` §4.1；补丁批次按该口径复跑的逐字证据见同文件 §4.2（后端定向 19/36/5/10，`MVN_EXIT=0`；全模块 4162/2，`MVN_EXIT=1`）。
- **上表第 1、2 行是假绿，更正如下**：当时写的是 `pnpm --filter @futurefab/app-smp-settings run type-check` 与 `pnpm --filter sdk-language run type-check`，
  两个包名都不是真名（真名 `@futurefab/ui-app-smp-settings`、`@futurefab/ui-sdk-language`）。pnpm 对不匹配的过滤器只打印
  `No projects matched the filters` 并**返回 0**，因此这两行"0 error / 通过"实为**未执行**。
  补丁批次已用正确包名复跑：`ui-sdk-smp-api build-dts`／`ui-sdk-smp-api`／`ui-app-smp-settings`／`ui-app-smp-data`／`ui-sdk-language` 四个 type-check
  全部退出码 0 且日志正文出现实际调用的 `vue-tsc` 行；`app-smp-settings` 生产构建 `APP_BUILD_EXIT=0`（`✓ built in 16.25s`）。
  逐字记录与取证见上面 §4.2 引用文件同段的"SDK 产物与逐包类型检查""应用生产构建"两行（日志 `.patch-fe-build.log`、`.patch-app-build.log`，均为 gitignore 的 `*.log` 临时件，只在工作副本可读，不入 Git）。
- 第 3 行 `routes:check` 经查为根 `package.json:31` 真实脚本（`tsx scripts/generate-route-paths.ts --check`），不属假绿；
  第 8 行"应用构建退出码 0"由补丁批次用正确过滤器复跑后同样成立。

## 5. 给独立复审 work 的测试方案

### 5.0 前置条件（逐条确认后才能跑）

1. 后端 `futurefab-system` 服务已重启到含本批改动的构建（否则 `BLOCKED_DEPLOY`，页面表现不代表源码）。
2. 登录账号需具备 M04 功能码；**当前 36 个 `process:{kind}:{action}` 功能码未播种到菜单/权限表 → 预期 `BLOCKED_MENU`**。若以超级管理员（全权限）跑通，只证明链路，不证明授权项已交付。
3. 端口 5581 门户提供的是**已构建的哈希包**，不是 HMR 源码。改动后必须重新构建并核对 chunk 名：
   - `packages/app-smp-settings/dist/feeding-template-management-BWEkUYID.js`
   - `packages/app-smp-settings/dist/use-guarded-write-D2KauXrr.js`
4. **已知陈旧产物**：`packages/sdk-smp-api/dist/index.js`（文件日期 10-05）含 `X-Management-Revision`，但对 `pump-count-options` / `pump-speed-options` 两条入口 0 命中，而 `src/processTemplate.ts` 有 2 处。浏览器验收前需重建 SDK，否则泵数/转速下拉在页面上不可达，这属产物陈旧而非本批缺陷。

### 5.1 A 组 · 契约与静态（可离线复核，无需环境）

| 用例 | 操作 | 期望 |
| --- | --- | --- |
| A1 缺版本短路 | 静态读 `index.vue`：状态变更/删除确认回调在 `ensureRevision()` 返回空值时 `return` | 无请求发出；提示文案键 `settings-feeding.revisionMissing` 中英双目录均在 |
| A2 双头组装载荷 | 单测已断言 fetch 头 | `X-Request-Id` 为各次操作对应 UUID，`X-Management-Revision: "77"` |
| A3 版本不硬编码 | 全文检索页面 | 无字面量版本号；编辑器不出现 `expectedSourceObjectVersion: <数字>` |
| A4 冲突刷新 | `invalidateOnConflict` 判定 409/`MANAGEMENT_CONFLICT` | 本地版本置陈旧，下次操作前重读列表口 |
| A5 错误码登记 | `m04-template-error.ts` | `STATE_CONFLICT`/`VERSION_CONFLICT`/`MANAGEMENT_CONFLICT`/`RESOURCE_FACTS_UNAVAILABLE`/`ACTION_NOT_SUPPORTED`/`FORBIDDEN`/`AUTH_DEPENDENCY_UNAVAILABLE` 均有稳定键且中英目录齐 |

### 5.2 B 组 · HTTP + 浏览器（本批目标页面，结论只允许写实测状态）

统一取证口径：每条记录 页面名 + 步骤、HTTP method+URL、请求头（重点 `X-Request-Id` / `X-Management-Revision`）、request payload、response body、后端日志是否出现 `RequestMetaInvalidException` / `GlobalExceptionHandler`、数据是否清理。

| 用例 | 步骤 | 期望 HTTP 与响应 | 状态词 |
| --- | --- | --- | --- |
| B1 列表取版本（M04-011） | 进入页面 | `GET /system/process/templates/list` 200，**外壳顶层含 `managementRevision`** | NOT_VERIFIED |
| B2 新建（M04-006） | 新建补液模板并保存 | `POST /system/process/templates` 200，头含双头；`sys_management_request` 出现成功回执 | NOT_VERIFIED |
| B3 修改（M04-007） | 编辑既有模板保存 | `PUT /system/process/templates/{id}` 200 | NOT_VERIFIED |
| B4 复制（M04-008） | 复制为新版本 | `POST /system/process/templates/{id}/copies` 200。**注意：该口当前无可达成功路径**——泵速策略按定位008 拒绝复制、其余四类无内容规范化器、FEEDING 依赖 M02 工程段事实源；实测到 503/业务拒绝即符合现状，不得判为前端缺陷 | BLOCKED_DATA / BLOCKED_EXTERNAL（依定位008 说明） |
| B5 状态变更（M04-009） | 启停用 | `PUT /system/process/templates/{id}/status` 200 | NOT_VERIFIED |
| B6 删除（M04-010） | 列表删除并确认 | `POST /system/process/templates/{id}/delete` 200 | NOT_VERIFIED |
| B7 缺头负例 | DevTools 里删掉 `X-Management-Revision` 重放 B5 | 400 `INPUT_INVALID`，页面走映射文案，不得显示“成功” | NOT_VERIFIED |
| B8 Header/Body 冲突 | Body 内 `managementRevision` 改成别的值，头保持真值 | 以 Header 为准；若版本不符则 409 `MANAGEMENT_CONFLICT` | NOT_VERIFIED |
| B9 同键重放 | 用同一 `X-Request-Id` 连发两次 B5 | 第二次走幂等回执口径，不产生第二条模板版本 | NOT_VERIFIED |
| B10 409 后刷新重试 | 先并发改一次使版本陈旧，再执行 B5 | 首次 409 → 页面自动刷新版本 → 用户重试成功 | NOT_VERIFIED |
| B11 权限负例 | 用无 `process:feeding:update` 的账号保存 | 403 `FORBIDDEN`，页面提示“权限未配置”口径 | BLOCKED_MENU（授权项未播种，无法构造） |
| B12 写失败无脏数据 | B7/B8 负例后回列表 | 无新增/变更记录；测试数据清理完毕 | NOT_VERIFIED |

### 5.3 C 组 · 只读数据库核验（不得写库，未连库即报“未执行”）

- `SELECT * FROM sys_management_request ORDER BY id DESC LIMIT 20;` 只看回执是否落，不改。
- `prc_template` / `prc_template_version`：确认 B2—B6 各产生预期行数，未产生时区分 400/403/409。
- 未执行时只能报“静态检查通过”，不得报“建库/迁移通过”。

## 6. 测试数据建议

- 模板名用可识别前缀 `QA-W1A1-`，便于 B12 清理与跨批次区分。
- 反应类型/型号/泵参数沿用页面已有候选；若泵数或转速下拉为空，先核对 5.0 第 4 条的 SDK 产物是否重建，不要当成后端缺陷。
- 同一模板的并发操作用两个浏览器会话（B10），不要用同一会话连续双击代替。

## 7. 已知风险 / 阻塞

1. `BLOCKED_MENU`：36 个 `process:{kind}:{action}` 功能码未进菜单权限初始化包，服务端强制判权已实现但页面无授权账号可用。交付需批次 D 的授权包。
2. `BLOCKED_DEPLOY` 风险：本批仅源码 + 契约测试，网关/Nacos/服务发布未做。
3. SDK dist 陈旧（5.0 第 4 条）会让浏览器验收误判两条下拉口。
4. 全量 vitest 14 个红文件属其他 work 在途面，未据此判本批失败，也未要求先清红。
5. 前端不实现状态机与冲突仲裁：409 后是否允许覆盖由后端裁决，页面只做刷新重试。

## 8. 复审 work 测试记录区（由独立 work 回填）

| 用例 | 执行人 | 实测 URL/方法 | 请求头摘要 | response 摘要 | 状态词 | 证据（截图/日志） |
| --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |

## 9. 最终结论区（由总控/独立 work 回填，work1 不自行判完成）

- 可宣称完成：（待回填）
- 仅 `CONTRACT_TESTED`：A1—A5、B1—B10、C 组全部
- `NOT_VERIFIED`：所有 HTTP / 浏览器 / 数据库项
- `BLOCKED_MENU`：B11 与功能码授权交付
- 待裁决：见 `docs/详细设计/04-工艺与方案管理/history/review/20261009-M04未编号HTTP入口登记差异.md`
