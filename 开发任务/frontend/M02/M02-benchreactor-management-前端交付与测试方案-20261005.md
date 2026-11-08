# M02 设备型号台式反应器页面 · 前端交付与测试方案

## 1. 基本信息

| 项 | 内容 |
|---|---|
| 模块 | M02 实验室与资源管理 / 设备型号库 |
| 页面 | 设备型号台式反应器管理（`/settings/benchreactor-management`） |
| 页面源码 | `futurefab-frontend/packages/app-smp-settings/src/views/benchreactor-management/` |
| 所属应用包 | `@futurefab/ui-app-smp-settings`（微应用，由 portal `:5581` 加载） |
| 接口族 | `/device/benchreactor/*`（list、`{modelId}`、check-unique、`{modelId}/check-delete`、save POST/PUT、remove DELETE） |
| 后端入口 | `DevBenchReactorController.java`（check-delete 复用 `device:benchreactor:query`；三处 `@ManagementGuardedWrite`；`@DeleteMapping("/{modelIds}")`） |
| 契约依据 | `docs/详细设计/02-实验室与资源管理/设备型号库设计.md`（MDL-B01/B02 读口 `iconPaths`、MDL-B05 删除预检、第 34/48/58 行写入白名单）、`接口目录与契约定位.md`（定位 016）、`逐接口完整契约清单.md`（MDL-B05 样例）、PKG-00 冻结壳 `DeletePrecheckResult`、AGENTS.md §13.3 / §13.2 |
| 开发人 | work1（仅前端页面开发，不做最终测试结论） |
| 日期 | 2026-10-05 |
| HEAD | `12b3d49d`（分支 `cloud`）；`git rev-list --left-right --count origin/cloud...HEAD` = `3 0`（本地落后 3、领先 0） |
| 是否提交 / 推送 | **未 `git add`、未 commit、未 push**（任务明令禁止）；交付物 = 工作树改动 + 本 MD |
| 本批状态 | IMPLEMENTED + CONTRACT_TESTED + 生产构建通过；HTTP / 浏览器 / 数据库 / 现场 = **NOT_VERIFIED** |
| 测试执行人 | work5 按第 6 节逐项执行；work9 支援真实浏览器验收与 Network 取证 |

---

## 2. 修改范围

工作树实测（`git diff --stat -- futurefab-frontend`）：8 个已跟踪文件 +317/−25，另有 1 个新增未跟踪文件。

| # | 文件 | 类型 | 改动点 |
|---|---|---|---|
| 1 | `packages/sdk-smp-api/src/benchreactor.ts` | 修改 +25 | ① 读类型 `BenchReactor.iconPaths?: string[]`（第 21 行，注明 MDL-B01/B02 读口只有数组、无单值）；② 新增 `BenchReactorDeletePrecheck`（第 57 行，`allowed/reasonCodes/referenceCount/managementRevision`）；③ 新增 `checkDelete(id, signal)` 只读 GET（第 87–88 行），注释写明"依赖故障/404 由 request 抛错，调用方不得当成可删" |
| 2 | `packages/app-smp-settings/src/views/benchreactor-management/benchreactor-delete.ts` | **新增文件**（41 行，未跟踪） | `isDeleteAllowed()`：只认显式 `allowed === true`，`undefined/null/{}` 一律 false；`deleteBlockedReasonKeys()`：原因码→文案 key 映射（5 个已知码），未登记码原样透出，空码兜底 `reason.unknown` |
| 3 | `.../benchreactor-management/index.vue` | 修改 +133/−25 | ① `prechecking` + `deleteBusy` 入口压位；② `iconUrls()` 改收 `iconPaths` 数组并过滤未登记值；③ `failedIcons` + `onIconError()` 加载失败摘除；④ `targetLabel()` 统一型号名；⑤ `precheckDeletes()` 逐目标预检并组装"型号名：原因；已被引用 N 处"；⑥ `remove()` 先预检后 `Modal.confirm`，`allowed=false` 直接终止；⑦ 确认回调内 `ensureRevision()` 短路 + `writeMeta(revision)` + 回执覆盖 |
| 4 | `.../benchreactor-management/grid.ts` | 修改 +3/−2 | 图标列 `field: "iconPath"` → `"iconPaths"`（第 37–38 行），并加注释说明单值只存在于写口 |
| 5 | `.../benchreactor-management/benchreactor-editor.vue` | 修改 +11/−2 | 保存前 `const revision = await ensureRevision();`（第 194 行）与 `if (!revision)` 短路提示 `revisionMissing`（第 197 行），再 `writeMeta(revision)`（第 211 行）；成功仍 `emit("saved", result.managementRevision)` |
| 6 | `packages/sdk-language/src/language/smp-settings/cn.ts` | 修改 +11 | `settings-benchreactor` 段新增 `deleteBlocked`、`referenceCount`（`已被引用 {count} 处`）、`revisionMissing`、`reason.{referenceExists,resourceInUse,dependencyUnavailable,notFound,permissionDenied,unknown}` |
| 7 | `packages/sdk-language/src/language/smp-settings/en.ts` | 修改 +14 | 同上英文（`referenced {count} time(s)` 等） |
| 8 | `tests/benchreactor-management.test.ts` | 修改 +130 | 新增/加强用例（现 28 例）：check-delete 线格式（GET、无守卫头、响应壳字段）、预检决策矩阵、`iconPaths` 列形状、预检先于确认、引用数透出、版本短路、图标降级、倒置日期原样透传 |
| 9 | `tests/benchreactor-acceptance-precheck.test.ts` | 修改 +15 | 页面接线钉住：`const revision = await ensureRevision();`、`if (!revision)`、`writeMeta(revision)`、`not.toContain("writeMeta(await ensureRevision())")`、`benchreactorApi.checkDelete(`、`isDeleteAllowed(result.data)` |

未改动（任务禁止项，已核对）：后端 Java / Mapper / XML、SQL、`/lab/labbenchreactor/**`、M03–M09、客户材料、history、他人在途 `.tmp-501-audit.py` / `.tmp-json-check.py` / `.tmp-setdiff.py`。共享文件 `src/shared/use-guarded-write.ts` 与 `use-benchreactor-list.ts` 本批**只读复用，未修改**。

---

## 3. 本轮功能改动

### 3.1 删除预检 UI 接入（MDL-B05）

- 删除入口（单行 / 批量）先对每个目标发 `GET /device/benchreactor/{modelId}/check-delete`，**预检发生在确认弹窗之前**（`index.vue:181` → `index.vue:203` → `index.vue:241`）。
- 响应口径按当前裁决使用 PKG-00 冻结壳 `{ allowed, reasonCodes, referenceCount, managementRevision }`。任务书曾出现的 `canDelete` 属 2026-10-05 F3 裁决前旧措辞，**前端未保留 `canDelete` 兼容分支**（否则为死代码）。
- `allowed=false`：不发 DELETE、不弹确认；页面按型号逐行提示可读信息
  `删除预检未通过，未执行删除；<品牌> / <类别>：<原因文案>；已被引用 N 处`
  未登记原因码原样显示，空原因码走 `reason.unknown` 兜底，绝不静默丢弃。
- `allowed=true`：进入确认框，用户确认后才发 `DELETE /device/benchreactor/{id1},{id2}`（ID 逗号连接，对齐后端 `Long[]`）。
- 预检请求是只读 GET，**不带** `X-Request-Id` / `X-Management-Revision`。
- 预检本身失败（404 / 5xx / 网络中止）→ 提示错误并终止删除，**不视为"无引用可删"**。
- 预检在途时 `deleteBusy` 压住入口（disabled + loading），连点不会起两轮预检。
- DELETE 仍携带两个守卫头；revision 来源见 3.4。

### 3.2 图标列显示

- 根因：后端读口 `DevBenchReactorRow.java:31` 只有 `List<String> iconPaths`（旧 `icon_path` 由兼容层按逗号拆分），**不返回单值 `iconPath`**；HEAD 版本页面按 `row.iconPath` 取值，故"有值不渲染"。本批把工作树恢复为契约形状：列 `field` 与 slot 均用 `iconPaths`，逐元素解析，一行可显示多张。
- 资源路径规则沿用项目既有内置登记表：`getDeviceIconUrl()`（`@futurefab/ui-sdk-smp-static-files`，构建期打包），未登记历史值返回空串被过滤 → 该列退回空态，**不使用占位图冒充真实设备图**。
- 加载失败安全降级：模板 `@error="onIconError(url)"`（`index.vue:423`）把失败地址加入 `failedIcons`（`index.vue:100`），`iconUrls()` 过滤掉它（`index.vue:108`）；同行其余图标与文字照常渲染，页面不崩溃、无浏览器破图。
- **BLOCKED_ASSET_BASE：不适用**。URL 由构建产物决定，不依赖运行时可配置的静态资源 base；若 work5 在浏览器里看到全部图标空白但 Network 无失败请求，则说明所测 bundle 未包含本批改动（见第 5 节前置），应判 BLOCKED_DEPLOY 而非资源 base 缺失。

### 3.3 筛选参数核对（只核实，未重复大改）

- 已确认页面只发契约字段：`keyword`、`beginDate`、`endDate`，品牌多选 `brandList`（序列化为 `brandList[0]`、`brandList[1]`）。
- URL 不出现 `description=`，也不出现 `params[beginTime]` / `params[endTime]` 旧协议（测试逐条断言）。
- `a-range-picker` 配 `:allow-empty="[true, true]"`，`use-benchreactor-list.ts:38-41` 逐边判空后上送 → **单边 beginDate / 单边 endDate 不会被前端丢弃**。
- 倒置窗口：区间选择器本身不会产出 `begin > end`；本批新增用例钉住前端**不擅自交换**，原样交给后端裁决（`tests/benchreactor-management.test.ts` 第 322 行用例）。
- 重置发空对象（四个条件一个都不带）并从第一屏重查；触底追加沿用已提交快照，草稿不参与。

### 3.4 守卫写核对

- 新增 / 修改 / 删除三条写链统一 `writeMeta(revision)` → `X-Request-Id` + `X-Management-Revision`。
- revision 来源顺序：列表外壳顶层 `managementRevision` → 上一次守卫写回执覆盖 → 本地缺失或吃过 409 时 `reloadRevision()` 兜底重取。**无硬编码、无跨模块借值**。**未**采用预检响应里嵌套的 `data.managementRevision`（AGENTS.md §13.3 要求来自页面对应读口顶层；预检只是瞬时提示，正式删除仍在守卫事务内重验引用）。
- 缺 revision 时前端短路并提示 `settings-benchreactor.revisionMissing`，不发缺头写请求。
- `X-Request-Id` 每次 `writeMeta()` 调用重新生成（一次 HTTP 一个幂等键，不复用）。
- 409 由 `writeErrorMessage()` 分流：`REFERENCE_EXISTS` 给"存在受保护引用"口径；版本/请求冲突（`MANAGEMENT_CONFLICT`）才给刷新重试口径，并把本地版本标脏，下一次写前强制重取，不会拿旧值反复撞。

---

## 4. 已执行验证（命令 + 结果，2026-10-05 20:09 于 `futurefab-frontend/` 执行）

| 步骤 | 命令 | 结果 |
|---|---|---|
| 1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 通过（`vue-tsc --noEmit` 无输出） |
| 1 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 通过 |
| 1 | `pnpm run routes:check` | 通过（`generate-route-paths.ts --check` 无差异） |
| 1 | `npx vitest run tests/benchreactor-acceptance-precheck.test.ts tests/benchreactor-management.test.ts` | **2 文件 / 33 用例全通过** |
| 1（回归） | `npx vitest run tests/benchreactor-management.test.ts tests/benchreactor-acceptance-precheck.test.ts tests/lab-labbenchreactor-guarded-write.test.ts` | **3 文件 / 54 用例全通过** |
| 2 | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | 通过（本批改了 SDK 类型，app 经 `dist-types/index.d.ts` 解析 SDK；产物目录未被 git 跟踪，工作树保持干净） |
| 3 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 通过，`✓ built in 16.18s`；产物 `packages/app-smp-settings/dist/benchreactor-management-gcUlT4zl.js`（26.77 kB / gzip 6.83 kB）。产物内确认含 `benchreactorApi.checkDelete`、`referenceCount`、`iconPaths`、`ensureRevision`；`packages/sdk-smp-api/dist/index.js` 含 `/check-delete` URL。`dist/` 已 gitignore |
| 附 | `npx prettier --check .../benchreactor-management/index.vue` | 通过。`cn.ts` / `en.ts` / 两个测试文件在 HEAD 就已不合规（他人在途风格），未整文件重排以免放大 diff |
| 附 | `npx biome check .../benchreactor-management/index.vue` | 剩 2 项（format、organizeImports）。已用 `git show HEAD:该文件 > 临时文件` 跑同一命令比对，证明改动前即存在；本批引入的 `lint/style/useTemplate` 已修掉，临时文件已删除 |

背景红（**不属于本批**，如实登记、未代改）：
- `tests/localization.test.ts` 1 红：112 条缺失 key 全属 `detection-record`、`alarm-mail-delivery`、`alarm-record` 等他域，无一条 benchreactor，数量与既有基线一致。
- `tests/workflow-management.test.ts` 2 红：M05 工艺流程 composable 丢弃 `labTypeList`。

分层结论：静态检查通过 + 编译（type-check）通过 + 生产构建通过 + 契约测试通过。**未执行 HTTP、未执行浏览器、未执行 SQL**，按 AGENTS.md §13.2 不得据此宣称 `HTTP_VERIFIED` / `BROWSER_VERIFIED`。

---

## 5. 测试前置条件

**5.1 服务与环境**

| 依赖 | 要求 | 不满足时的状态词 |
|---|---|---|
| portal | `:5581`，serve **预构建 hash bundle**（不吃 HMR 源码）。本批产物基线 `dist/benchreactor-management-gcUlT4zl.js` | BLOCKED_DEPLOY |
| 网关 | `:9090`，`/dev-api/device/benchreactor/*` 路由到 `futurefab-system` | BLOCKED_DEPLOY |
| 后端 | `futurefab-system` 9201 **已重启并加载 `check-delete` 路由**；Nacos 配置已发布 | BLOCKED_DEPLOY |
| SDK 静态资源 | `@futurefab/ui-sdk-smp-static-files` 已构建（图标登记表随包产出） | BLOCKED_ASSET_BASE（仅当登记表本身缺项时） |
| 若源码再变更 | 重跑 `pnpm --filter @futurefab/ui-sdk-smp-static-files build` → `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` → `pnpm --filter @futurefab/ui-app-smp-settings run build`，并以新 chunk 名为准 | — |

**5.2 账号与权限**（禁止猜测或硬编码凭据；缺账号即 BLOCKED_MENU/BLOCKED_DATA）

| 账号 | 所需权限 | 用于 |
|---|---|---|
| A（完整） | `device:benchreactor:query` / `add` / `edit` / `remove`，且已分配目标实验室 | TC-01–TC-18 |
| B（受限） | 有 `query`，**无** `remove`（再备一档无 `edit`/`add`） | TC-19 权限用例 |
| C（可选） | **无** `query` | TC-13 步骤 4（预检 403 不得当成可删） |

注意：此前 HTTP 验证中 `/dev-api/...` 未登录会返回 canonical `401 令牌不能为空`，所以任何 HTTP 取证都必须在真实登录态下进行。

**5.3 测试数据**

- 前缀约定：类别用 `ZZZ-TEST-20261005`（型号业务唯一键是 `brand + category`），描述字段带同一批次标记，便于定位与清理。
- 必需主数据：① 至少 1 条**未被引用**型号（可删）；② 至少 1 条**已被 `lab_bench_reactor` 引用**的型号（用于 allowed=false）。缺 ② → 记 **BLOCKED_DATA**，禁止用"预检返回 200 且 allowed=true"顶替 allowed=false 用例。
- 图标：至少 1 条 `iconPaths` 为登记表内值（如 `icons/image/002-SUB-250L.png`）、1 条为登记外历史值、1 条为空数组。

**5.4 是否需要 SQL**：只需**只读核验**（禁止任何写操作）。live 数据源是共享远端库，仓库 `nacos-config` 内的连接信息是过期副本，勿据此连库。

```sql
-- 预检阻断与删除结果取证
SELECT model_id, brand, category, capacity_unit, description, icon_path, del_flag, update_time
  FROM dev_bench_reactor WHERE category = 'ZZZ-TEST-20261005' ORDER BY create_time DESC;

-- 被引用事实（allowed=false 必须有这条支撑）
SELECT model_id, COUNT(*) FROM lab_bench_reactor WHERE model_id = <被引用型号> GROUP BY model_id;

-- 守卫写 400/409 只进 WARN 日志、不落服务日志文件，必须靠这张表取证
SELECT request_id, management_revision, result_code, result_message
  FROM sys_management_request WHERE request_id IN (<本次抓到的 X-Request-Id>);
```

---

## 6. 详细测试方案（work5 逐项执行，每项必须回证据）

通用证据格式（每条用例都要交）：页面名 + 操作步骤、HTTP method + 完整 URL、request headers（重点 `X-Request-Id` / `X-Management-Revision` 实际值）、request payload、response body、页面表现截图、Console 是否报错、操作前后 revision 对照、数据清理结果、结论状态词。

### TC-01 页面进入
1. 账号 A 登录 → 进入 `/settings/benchreactor-management`。
2. 预期请求：`GET /dev-api/system/dict/data/type/smp_brand_name`、`smp_capacity_type`、`smp_capacity_unit` 均 200；`GET /dev-api/device/benchreactor/list?pageNum=1&pageSize=<N>` 200。
3. 预期响应外壳：顶层含 `code / rows / total / managementRevision`，`managementRevision` 为**非空字符串**（后续所有写请求的版本来源）。
4. 页面表现：三个下拉有选项；字典就绪前编辑入口不放开。
5. 负例：DevTools 阻断任一字典请求 → 页面显示可读错误，不白屏、不静默可写。
6. 证据：首屏截图 + list 响应 body（含 `managementRevision` 值）。

### TC-02 默认列表
1. 不填条件直接查询。预期 `list?pageNum=1&pageSize=N`，**不带**任何筛选参数。
2. 表格列齐全：序号、图标、品牌、类别、容量单位、描述、更新人、更新时间、操作；行数 = `total` 首屏量。
3. 只有滚动加载一处分页，**不得**同时出现分页条/antd 分页。
4. 证据：URL 原文 + 首屏截图。

### TC-03 keyword 筛选
1. 关键字输入 `  500L  `（带前后空格）→ 查询。预期 URL `keyword=500L`（已 trim）。
2. 预期 URL **不含** `description=`、**不含** `params%5B`。
3. 证据：URL 原文 + 响应 `total` 变化。

### TC-04 beginDate 单边
1. 区间选择器只填开始日期 `2026-07-01` → 查询。
2. 预期 URL 含 `beginDate=2026-07-01`，**不含** `endDate=`（单边不得被前端丢弃）。
3. 后端按左闭窗口筛选；记录返回 `total` 与首条 `updateTime`。
4. 证据：URL 原文 + 响应 body 片段。

### TC-05 endDate 单边
1. 只填结束日期 `2026-07-31` → 查询。预期 URL 含 `endDate=2026-07-31`，**不含** `beginDate=`。
2. 证据：URL 原文。

### TC-06 双边日期
1. 填 `2026-07-01` ~ `2026-07-31` → 查询。预期 URL 同时含 `beginDate=2026-07-01&endDate=2026-07-31`，顺序为 begin 前 end 后。
2. 与 TC-04/TC-05 的 `total` 做包含关系合理性判断（双边不应多于单边）。
3. 证据：三条 URL 对照截图。

### TC-07 倒置日期
1. UI 说明：`a-range-picker` 不允许直接选出 `begin > end`，本用例通过 DevTools 改写请求或后端 mock 验证透传口径。
2. 预期：前端**不擅自交换**参数（契约测试已钉住原样透传），由后端裁决返回空集或参数校验错误。
3. 页面表现：空结果时显示空态；后端报参数错误时原文透出提示，不得白屏。
4. 若 UI 根本无法构造 → 记 `NO_UI`，并附契约测试通过截图代替。
5. 证据：改写后的 URL + 响应 body + 页面截图。

### TC-08 重置
1. 先填品牌多选 + keyword + 双边日期并查询；再点"重置"。
2. 预期新请求：四个条件**一个都不带**（空串会筛掉全部结果），并从第一屏重查。
3. 表单态：品牌多选清空、keyword 空、区间清空。
4. 证据：重置前后两条 URL 对照。

### TC-09 图标列显示
1. 观察一条 `iconPaths` 含登记表内值的行 → 缩略图**实际渲染出来**（这是本批缺陷修复点）。
2. 观察 `iconPaths` 长度 ≥ 2 的行 → 多张横排、列宽 72 内不换行不重叠。
3. 观察 `iconPaths` 含未登记历史值的行 → 该值不显示、列退回空态，**不出现占位图**。
4. 观察 `iconPaths` 为空数组的行 → 空态。
5. 失败注入：DevTools 阻断某图标请求 → 失败那张从渲染中摘除，同行其余图标与文字正常，Console 无未捕获异常，页面不崩溃。
6. 若所有图标都空白且 Network 无失败请求 → 判 BLOCKED_DEPLOY（bundle 未含本批改动），先按 5.1 重建再测。
7. 证据：四种行各 1 张截图 + 步骤 5 的阻断设置与截图 + 该行 list 响应中的 `iconPaths` 原文。

### TC-10 新增
1. 点新增，填品牌 / 类别（`ZZZ-TEST-20261005`）/ 容量单位 / 描述。
2. 预期校验请求：`GET /device/benchreactor/check-unique?brand=<v>&category=<v>`，**不带 modelId**。
3. 重复用例：提交与既有 `brand+category` 相同 → check-unique 非 200，页面**原文**显示"台式反应器型号已存在"，此时**不得**发出 POST。
4. 正常提交：`POST /device/benchreactor`，headers 含 `X-Request-Id`、`X-Management-Revision`（= 当前列表顶层值）；payload 为 `{brand, category, capacityUnit, description}`（图标字段见第 8 节待裁决 1），**不含 modelId**。
5. 响应：`data.applied=true` 且带 `managementRevision`；页面提示成功、列表刷新；记录写前/写后 revision。
6. 证据：check-unique 与 POST 两条完整证据 + revision 前后对照。

### TC-11 修改
1. 编辑 TC-10 新建的型号 → `GET /device/benchreactor/{modelId}` 200，表单回填正确。
2. `check-unique` 必须带 `modelId=<当前>`（排除自身）；把 brand+category 改成另一已存在组合应被拒并原文提示。
3. `PUT /device/benchreactor`，payload 含 `modelId`，带两个守卫头；成功后回执 revision 覆盖本地值。
4. 图标选择器行为（**只记录，不下结论**）：改选图标并保存后，重新读取该行的 `iconPaths` 是否变化。当前设计契约是图标只读，预期为"不变化"；若产品希望可写，走第 8 节待裁决 1。
5. 证据：detail / check-unique / PUT 三条证据 + 保存前后同一行 `iconPaths` 对照。

### TC-12 删除预检 allowed=true
1. 对**未被引用**型号点删除。
2. 预期请求：`GET /device/benchreactor/{modelId}/check-delete`；method **GET**；headers **不含** `X-Management-Revision`、**不含** `X-Request-Id`。
3. 预期响应：`{"code":200,"data":{"allowed":true,"reasonCodes":[],"referenceCount":0,"managementRevision":"..."}}`（`reasonCodes` 恒不为 null）。
4. 页面表现：进入确认框（标题为单条确认文案），此时**仍未发 DELETE**。
5. 证据：check-delete 的 method+URL+headers+body + 确认框截图。

### TC-13 删除预检 allowed=false
1. 对**已被引用**型号点删除。
2. 预期响应：`{"allowed":false,"reasonCodes":["REFERENCE_EXISTS"],"referenceCount":2,...}`，HTTP 仍是 200（合法预检结果，不是错误）。
3. 页面提示必须含三段可读信息：型号标识（`品牌 / 类别`）、引用保护文案、`已被引用 2 处`。
4. 预期 Network **无 DELETE 请求**、确认框**不弹出**。
5. 变体 A：无 `query` 权限账号 → check-delete 返回 403 → 页面按错误终止删除，不得当成可删。
6. 变体 B：`reasonCodes` 为空但 `allowed=false` → 页面显示兜底"删除被阻止"，不得空白。
7. 变体 C：未登记原因码（如 mock `LOCKED_BY_X`）→ 原样显示该码。
8. 变体 D：阻断 check-delete 使其 5xx/超时 → 页面提示错误并终止删除，不发 DELETE。
9. 证据：主用例 + 四个变体各一套 Network/截图。

### TC-14 删除成功
1. 承接 TC-12，在确认框点"确认删除"。
2. 预期请求：`DELETE /device/benchreactor/<modelId>`（批量时 `.../<id1>,<id2>`，逗号连接），headers 含 `X-Request-Id`、`X-Management-Revision`。
3. 取消分支：预检通过后点"取消" → **不发 DELETE**（记录勾选是否保留，只记录不判缺陷）。
4. 预期响应：200 且 `data.managementRevision` 比写前大；页面 `deletedSuccessfully`、列表刷新、该行消失、`total` 减少。
5. 证据：DELETE 完整证据 + 删除后 list 响应 + revision 前后对照。

### TC-15 被引用不删除（并发保护）
1. 前置：型号 X 当前**无**引用 → 预检 `allowed=true`，停在确认框。
2. 另一会话（或 work9 协助）用 X 建一条实验室实例引用，然后点"确认删除"。
3. 预期：后端在守卫事务内重验引用 → 返回 409 且 canonical errorCode `REFERENCE_EXISTS`。
4. 页面提示必须是"存在受保护引用…"口径，**不得**显示成"数据已被他人修改，请刷新重试"。
5. 预期数据未被删除（用 5.4 的 `dev_bench_reactor` 只读查询确认 `del_flag` 未变）。
6. 证据：预检响应 + DELETE 409 响应体 + `sys_management_request` 查询结果 + 页面提示截图 + 引用解除后的再次删除（清理）。

### TC-16 缺 revision 短路
1. 构造版本不可得：DevTools 改写 list 响应去掉顶层 `managementRevision`（或阻断 list 后直接操作），保持编辑弹窗打开。
2. 点保存 / 点确认删除。
3. 预期页面提示 `未取到管理版本，已取消本次…请刷新列表后重试`；**Network 不得出现 POST/PUT/DELETE**。
4. 反证：确认代码路径未把 `await ensureRevision()` 结果直接塞进 `writeMeta`（契约测试已钉住），work5 只需证明"无写请求发出"。
5. 证据：改写设置截图 + 提示截图 + Network 面板（无任何写请求）。

### TC-17 409 冲突提示
1. 构造陈旧版本：改写 list 响应使 `managementRevision` 比服务端真实值小 1，然后提交新增/修改。
2. 预期：后端 409 `MANAGEMENT_CONFLICT`，页面提示刷新/重试口径（`settings-config.configSaveConflict`）。
3. 关键断言：**下一次**写请求前必须重新取版本，`X-Management-Revision` 变成服务端真实值，而不是重复使用同一个旧值再撞一次。
4. 同值重复 requestId 重放：同一 payload 用同一 `X-Request-Id` 连发两次 → 第二次应命中幂等（不二次落库）。
5. 证据：两次写请求的 headers 对照 + 409 响应体 + `sys_management_request` 行 + 数据最终只有一条。

### TC-18 测试数据清理
1. 删除本轮全部 `ZZZ-TEST-20261005` 型号（走页面删除流程即可）。
2. TC-15 建的实验室实例引用必须先解除，再删除型号。
3. 只读复核：5.4 第一条 SQL 中该 category 的行 `del_flag` 全部为删除态或不存在。
4. 无法清理时（如受引用阻塞）**必须写明保留原因与残留主键**，不得静默遗留。
5. 证据：清理前后 SQL 结果截图 + 残留清单（如有）。

### TC-19 权限与菜单
1. 账号 B（无 `remove`）：勾选列与操作列删除项**不出现**，批量删除按钮不可达。
2. 账号 B（无 `edit`/`add`）：对应入口消失。
3. 菜单：确认该页面菜单/入口已挂载；缺菜单只能用 URL 直达时，结论记 **BLOCKED_MENU**，不得当成浏览器验收通过。
4. 证据：各角色截图 + 403/无按钮表现 + 角色权限配置来源。

### TC-20 国际化文案
1. 切英文复跑 TC-12–TC-17 的提示断言，核对：`deleteBlocked`、`referenceCount`（"referenced {count} time(s)"）、`revisionMissing`、`reason.*` 六项均有译文且 `{count}` 正确插值。
2. 界面不得出现裸 key（`settings-benchreactor.xxx`）。
3. 判定缺 key 前注意：页面文案也经 `sdk-language/src/legacy/*.ts` 兜底解析，只查 `smp-settings/cn-*.ts` 会得出假缺陷。
4. 证据：中英各一组提示截图。

### TC-21 视觉与交互
1. 预检/删除在途：入口 disabled + loading；连点不产生第二轮 check-delete（请求数 = 目标数）。
2. 确认弹窗在途时取消键禁用，结束后恢复；关闭后 `deleteDialog` 释放，可再次操作。
3. 批量确认文案中型号列表可读、超长不破版。
4. 图标列宽 72：多张不换行、不挤压相邻列。
5. 证据：各步骤截图 +（步骤 1）Network 请求计数。

---

## 7. 测试数据建议与清理方式

| 数据 | 建议值 | 用途 | 清理 |
|---|---|---|---|
| 测试类别 | `ZZZ-TEST-20261005` | 所有新建型号；与业务唯一键 `brand+category` 绑定，便于定位 | TC-18 页面删除 |
| 测试品牌 | 沿用字典内既有值（如 `smp_brand_name` 中任一） | 避免新增字典项污染 | 不动字典 |
| 描述标记 | `work5-M02-20261005` | 便于 SQL 与截图核对 | 随型号删除 |
| 被引用型号 | 复用现网已有引用关系的型号；无则新建实例引用 | TC-13 / TC-15 | 先解除实例引用，再删型号 |
| 图标行 | 登记内值 `icons/image/002-SUB-250L.png`、登记外历史值、空数组各 1 | TC-09 | 只读观察，不改数据 |

清理原则：删除类用例本身即清理；无法清理必须写"保留原因 + 残留主键"；禁止用 SQL 写操作代劳（本方案只授权只读核验）。

---

## 8. 已知风险与阻塞

1. **待裁决：型号编辑表单仍提交 `iconPath`，与设计契约冲突。** `设备型号库设计.md` 第 34/48/58 行明确"图标只读、不允许表单写入、客户端不得提交 capacity、icon_path"，后端 `DevBenchReactorCreateCommand` / `UpdateCommand` 实测只有 `brand/category/capacityUnit/description(+requestId/managementRevision[/modelId])`；而 `benchreactor-editor.vue` 仍保留图标选择器并提交 `iconPath`（Jackson 静默丢弃 → 用户选图标、保存后不生效）。请总控裁决：移除前端图标写入入口（纯前端，但属产品可见行为变更，超出本批"图标列显示修复"范围），或后端把图标纳入写白名单（后端改动，本批禁止）。**未裁决前保持现状**，work5 在 TC-11 步骤 4 只记录实际行为。
2. **风险：`iconPaths` 修复历史上被回退过两次。** `24bbffec`（"列表与图标对齐旧协议"）从 SDK 类型移除 `iconPaths`，`32789f48`（"列表恢复旧图标路径"）把页面绑回单值 `iconPath`；两者与读口 `DevBenchReactorRow.java:31`（只有 `List<String> iconPaths`）矛盾，也正是本批 brief 所述"有值不渲染"的根因。本批工作树已按契约恢复。**若后续再有提交把它改回单值，缺陷会复发** —— 复核点：`grid.ts` 图标列 field 必须是 `iconPaths`，`index.vue` slot 必须是 `iconUrls(row.iconPaths)`。
3. **BACKEND_CONTRACT_GAP：无。** check-delete 已按 PKG-00 冻结壳返回 `allowed/reasonCodes/referenceCount/managementRevision`；`canDelete` 属被取代的旧措辞，前端未做兼容分支，也不应为此在后端补别名。
4. **口径留痕（可能被复核质疑）**：DELETE 使用的 revision 取自列表外壳顶层 / 上一次写回执，**未**采用预检响应嵌套的 `data.managementRevision`。依据 AGENTS.md §13.3。若总控要求"以预检回执版本为准"，需另行改码，本批未擅自更改。
5. **BLOCKED_DEPLOY**：源码 + 构建已完成，但 portal 加载的 bundle、网关路由、后端 9201 是否已发布/重启未由本批验证；第 5.1 节是 work5 的放行前置。
6. **BLOCKED_ASSET_BASE：不适用**（理由见 3.2）。仅当出现"所有图标空白且 Network 无失败请求"时，才需区分 BLOCKED_DEPLOY 与登记表缺项。
7. **NOT_VERIFIED**：本批全部 HTTP、浏览器、数据库、外部系统、现场验收均未执行。
8. **不在本批范围（仅登记）**：兄弟型号页若仍按单值 `iconPath` 读图标列，存在同样缺陷；`/lab/labbenchreactor/**` 属实验室实例侧，本批未触碰（任务禁止项）。
9. **既有背景红**：`localization.test.ts`（112 条他域缺失 key）、`workflow-management.test.ts`（M05 丢 `labTypeList`）。非本批引入，未代改。
10. **共享工作树风险**：HEAD 为 `12b3d49d`，本地落后 `origin/cloud` 3 个提交；本批未提交，任何他人在同目录的提交都可能与本批文件交叉，work5 复测前请重新确认 `git status`。

---

## 9. work5 测试记录区（由 work5 填写，work1 不代填）

| 用例 | 执行日期 | 结论状态词 | 证据编号/文件 | Console 是否有未捕获异常 | 偏差或阻塞说明 |
|---|---|---|---|---|---|
| TC-01 页面进入 | | | | | |
| TC-02 默认列表 | | | | | |
| TC-03 keyword 筛选 | | | | | |
| TC-04 beginDate 单边 | | | | | |
| TC-05 endDate 单边 | | | | | |
| TC-06 双边日期 | | | | | |
| TC-07 倒置日期 | | | | | |
| TC-08 重置 | | | | | |
| TC-09 图标列显示 | | | | | |
| TC-10 新增 | | | | | |
| TC-11 修改 | | | | | |
| TC-12 预检 allowed=true | | | | | |
| TC-13 预检 allowed=false | | | | | |
| TC-14 删除成功 | | | | | |
| TC-15 被引用不删除（409） | | | | | |
| TC-16 缺 revision 短路 | | | | | |
| TC-17 409 冲突提示 | | | | | |
| TC-18 测试数据清理 | | | | | |
| TC-19 权限与菜单 | | | | | |
| TC-20 国际化文案 | | | | | |
| TC-21 视觉与交互 | | | | | |

状态词只能取：`IMPLEMENTED` / `CONTRACT_TESTED` / `HTTP_VERIFIED` / `BROWSER_VERIFIED` / `BLOCKED_DATA` / `BLOCKED_MENU` / `BLOCKED_DEPLOY` / `BLOCKED_EXTERNAL` / `NO_UI` / `NOT_VERIFIED`。

---

## 10. 最终结论区（work5 执行完毕后填写；本批 work1 留空，不做最终测试结论）

- 可以宣称完成的事项：（待 work5 填写）
- 仅代码 / 契约测试完成的事项：TC-01–TC-21 全部（当前层级 = CONTRACT_TESTED + 生产构建通过）
- HTTP 已验证但未做浏览器验收的事项：（待填）
- 浏览器已验证事项：（待填）
- 数据 / 菜单 / 部署 / 外部系统阻塞事项：（待填；已知候选 = BLOCKED_DEPLOY、TC-13 引用的 BLOCKED_DATA）
- 仍需产品或设计裁决事项：第 8 节 1（图标写入白名单）、4（DELETE 版本来源口径）
- 禁止措辞：未获 HTTP + 浏览器 + 数据库 + 外部系统 + 现场证据前，不得使用"全部完成""上线完成"。
