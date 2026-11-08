# M02 前端批次 W1-01 · benchreactor-management 筛选 + 删除预检 + 图标列

## 1. 基本信息

| 项 | 内容 |
|---|---|
| 批次 | **W1-01**（总控 W1 序列编号；原编号「Batch 01」，文件名随总控 2026-10-06 表格更名，内容口径未变） |
| 模块 | M02 实验室与资源管理 · 设备型号库 |
| 页面 | `/settings/benchreactor-management` |
| 页面源码 | `futurefab-frontend/packages/app-smp-settings/src/views/benchreactor-management/` |
| 接口族 | `/device/benchreactor/*`（list、`{modelId}`、check-unique、`{modelId}/check-delete`、save POST/PUT、remove DELETE） |
| 后端入口（只读参考，本批未改） | `DevBenchReactorController.java`、`DevBenchReactorRow.java:31`（读口只有 `List<String> iconPaths`） |
| 开发人 | work1（不做最终测试结论） |
| 日期 | 2026-10-06（首轮实现于 2026-10-05 完成，本轮为 W1-01 复核并重新取证） |
| HEAD | `b9769b2a`（分支 `cloud`；复核时 HEAD 已从实现时的 `18b62175` 前移，前移提交为 M03-P01/M07/M06/M04 后端改动，与本批前端文件零交集，本轮已用 `git diff --numstat` 重新确认本批 6 个文件的行数增删与 §2 表内记录完全一致） |
| 是否提交 / 推送 | **未 `git add`、未 commit、未 push**；交付物 = 工作树改动 + 本 MD |
| 本批结论层级 | IMPLEMENTED + CONTRACT_TESTED + 生产构建通过；HTTP / 浏览器 / 数据库 / 现场 = **NOT_VERIFIED** |
| 七项目标复核结论 | 1、2（筛选参数对齐 / 单边日期不丢弃）由 HEAD 既有实现满足（`use-benchreactor-list.ts:36-41`，来自提交 `6bc6cb766`），本批**未重复实现**，改由测试钉住（见 §3.1、§4）；3、4、5（check-delete 预检与阻断提示、allowed=true 才 DELETE）为新增；6（iconPaths 真实缩略图 + 失败降级）为新增；7（守卫写双头）为新增短路强化 |
| 相关文档 | 同页面的守卫写/权限/国际化/视觉细则另见 `M02-benchreactor-management-前端交付与测试方案-20261005.md`；本 MD 可独立执行 |

---

## 2. 修改文件清单

本轮 `git diff --numstat` 实测：本批 6 个已跟踪文件 **+292/−25**，另有 1 个新增未跟踪文件 `benchreactor-delete.ts`。语言文件为跨批共用文件，本批只贡献其中一段 hunk。

| # | 文件 | 本轮行数 | 改动点 |
|---|---|---|---|
| 1 | `packages/sdk-smp-api/src/benchreactor.ts` | +25/−0 | `BenchReactor.iconPaths?: string[]`（:21）；`BenchReactorDeletePrecheck`（:57）；`checkDelete(id, signal)` 只读 GET（:87） |
| 2 | `.../benchreactor-management/benchreactor-delete.ts` | 新增 | 纯函数：`isDeleteAllowed()`（只认显式 `allowed===true`）、`deleteBlockedReasonKeys()`（原因码→文案 key；未登记码原样透出；空码兜底 `reason.unknown`） |
| 3 | `.../benchreactor-management/index.vue` | +114/−19 | 预检接入（`precheckDeletes:181`、`remove:203`、确认框 `:241`）；阻断信息按型号逐行含 reasonCodes + referenceCount；图标 `iconUrls(paths):105` 收 `iconPaths` 并过滤未登记值；`failedIcons:100` + `onIconError:112` + 模板 `@error:423`；`prechecking`/`deleteBusy` 防连点；删除前 `ensureRevision():268` 短路 + `writeMeta(revision):281` |
| 4 | `.../benchreactor-management/grid.ts` | +2/−1 | 图标列 `field` → `iconPaths`（:37） |
| 5 | `.../benchreactor-management/benchreactor-editor.vue` | +10/−1 | 保存前 `ensureRevision()`（:194）+ `if (!revision)` 短路（:197）+ `writeMeta(revision)`（:211） |
| 6-7 | `packages/sdk-language/src/language/smp-settings/{cn,en}.ts` | cn 本批段 +11（`@@ -416,0 +419,11`）/ en 本批段 +14（`@@ -428,0 +433,14`） | `deleteBlocked`、`referenceCount`（`已被引用 {count} 处` / `referenced {count} time(s)`）、`revisionMissing`、`reason.{referenceExists,resourceInUse,dependencyUnavailable,notFound,permissionDenied,unknown}`。**同文件另有 Batch 03 venue 段（cn +2 / en +4，`@@365`、`@@375`），hunk 不重叠** |
| 8 | `tests/benchreactor-management.test.ts` | +129/−1 | 现 28 例：check-delete 线格式、预检决策矩阵、`iconPaths` 列形状、预检先于确认、引用数透出、版本短路、图标降级、倒置日期原样透传 |
| 9 | `tests/benchreactor-acceptance-precheck.test.ts` | +12/−3 | 页面接线钉住 `const revision = await ensureRevision();` / `if (!revision)` / `writeMeta(revision)` / 禁止 `writeMeta(await ensureRevision())` / `benchreactorApi.checkDelete(` / `isDeleteAllowed(result.data)` |

未触碰：后端 Java/Mapper/XML、SQL、`/lab/labbenchreactor/**`（那是上一轮 Batch 02 的范围，本轮未再改）、M03–M09、客户材料/history、他人在途 `.tmp-*.py`。共享文件 `src/shared/use-guarded-write.ts`、`use-benchreactor-list.ts` 本批只读复用未修改。

---

## 3. 功能改动说明

### 3.1 筛选参数对齐

**归属说明（不得冒充本批新增）**：`keyword` 与 `beginDate/endDate` 的逐边上送实现已在 HEAD 中存在（`use-benchreactor-list.ts:36-41`，来自提交 `6bc6cb766 修复M02设备型号台式反应器筛选参数`）。本批对该文件**零改动**，只做口径复核 + 契约测试钉住（`tests/benchreactor-management.test.ts` 的 `keeps the brand multi-select, keyword filter, flat date range` 与 `omits empty conditions so blank strings never reach the query`、`passes an inverted window through instead of silently reordering it`）。若总控需要本批对该文件提交 diff，答案是「无需改动，改动会与原实现重复」。

- 只发契约字段：`keyword`、`beginDate`、`endDate`、品牌多选 `brandList`（序列化为 `brandList[0]`、`brandList[1]`）。
- **不再发送** `description`、`params[beginTime]`、`params[endTime]`（测试逐条断言 URL 不含 `description=` 与 `params%5B`）。
- 单边日期：`a-range-picker` 配 `:allow-empty="[true, true]"`，`use-benchreactor-list.ts:38-41` 逐边判空后上送 → 单边 begin 或单边 end 都不会被前端丢弃。
- 重置：发空对象（四条件一个都不带）并从第一屏重查。
- 触底追加沿用已提交快照，草稿不参与。
- **倒置日期口径（本批唯一需说明项）**：
  1. 区间选择器的正常交互不会产出 `begin > end`；
  2. 契约测试已钉住**前端不擅自交换**（`tests/benchreactor-management.test.ts:322`），即若出现倒置值就原样交给后端裁决，不伪造前端结论；
  3. 后端若返回 400，走列表错误通道：`@load-error="onListError"`（`index.vue:412`）→ `index.vue:119` 写入 `error` → `useErrorMessage(error, dictError)`（`index.vue:314`）统一提示；已提交条件不被清空，页面不崩；
  4. 本批**未**新增"前端倒置校验+提示"，因为该值在 UI 上不可构造，属死代码。若总控要求支持手工输入并即时提示，需要先更换筛选控件形态，请另批下达。

### 3.2 删除预检 UI（MDL-B05）

- 删除入口（单行/批量）先逐目标发 `GET /device/benchreactor/{modelId}/check-delete`，**预检在确认弹窗之前**。
- 响应口径按当前裁决使用 PKG-00 冻结壳 `{ allowed, reasonCodes, referenceCount, managementRevision }`；`canDelete` 是 F3 裁决前旧措辞，未保留兼容分支（否则为死代码）。
- `allowed=false`：不发 DELETE、不弹确认；按型号逐行提示
  `删除预检未通过，未执行删除；<品牌> / <类别>：<原因文案>；已被引用 N 处`
  未登记原因码原样显示、空原因码兜底、绝不静默丢弃。
- `allowed=true`：进入确认框，确认后才发 `DELETE /device/benchreactor/{id1},{id2}`（ID 逗号连接，对齐后端 `Long[]`）。
- 预检是只读 GET，**不带**守卫写头；预检自身失败（404/5xx/中止）按错误终止删除，不视为"无引用可删"。
- 预检在途 `deleteBusy` 压住入口（disabled + loading），连点不起两轮。
- DELETE 仍带 `X-Request-Id` + `X-Management-Revision`；revision 来源=列表外壳顶层 → 上次写回执 → 缺失/吃过 409 时 `reloadRevision()` 兜底；**未硬编码、未借用无关模块**；**未**采用预检响应里嵌套的 `managementRevision`（依据 AGENTS.md §13.3；预检只是瞬时提示，正式删除仍在守卫事务内重验引用）。

### 3.3 图标列显示

- 根因：读口 `DevBenchReactorRow.java:31` 只有 `List<String> iconPaths`（旧 `icon_path` 由兼容层按逗号拆分），**不返回单值 `iconPath`**；HEAD 版本按 `row.iconPath` 取值，所以"有值不渲染"。本批改列绑 `iconPaths` 并逐元素解析，一行可显示多张。
- 资源路径沿用项目既有构建期登记表 `getDeviceIconUrl()`（`@futurefab/ui-sdk-smp-static-files`）；未登记历史值返回空串被过滤 → 空态，**不用占位图冒充真实设备图**。
- 加载失败安全降级：`@error="onIconError(url)"` 把失败地址加入 `failedIcons` 并从渲染中摘除；同行其余图标与文字照常，页面不崩溃、无破图。
- **BLOCKED_ASSET_BASE：不适用**。图标 URL 由构建产物决定，不依赖运行时可配置 base。判读规则：若浏览器里全部图标空白但 Network 无失败请求 → 是 bundle 未含本批改动，记 **BLOCKED_DEPLOY**；只有当登记表内确实缺该文件时才算资源问题，需在回报里点名缺失值。

### 3.4 守卫写核对

- 新增/修改/删除统一 `writeMeta(revision)` → 两个守卫头齐备；`X-Request-Id` 每次写重新生成（一次 HTTP 一个幂等键，不复用）。
- 缺 revision → 前端短路提示 `revisionMissing`，**不发写请求**。
- 409 由 `writeErrorMessage()` 分流：`MANAGEMENT_CONFLICT`/版本冲突给刷新重试口径并标脏版本（下次写前强制重取，不会拿旧值反复撞）；`REFERENCE_EXISTS` 给"存在受保护引用"口径，避免把引用保护误报成版本冲突。

---

## 4. 已执行验证命令与结果

**本轮复核 2026-10-05 23:16–23:2x，HEAD `18b62175`，工作目录 `futurefab-frontend/`**（下表全部为本轮实测输出；上一轮 20:19 的结果已被本轮覆盖取代）：

| # | 命令 | 本轮结果 |
|---|---|---|
| 1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 退出 0，`vue-tsc --noEmit` 无报错 |
| 2 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 退出 0，无报错 |
| 3 | `pnpm run routes:check` | 退出 0（`tsx scripts/generate-route-paths.ts --check`） |
| 4 | `npx vitest run tests/benchreactor-acceptance-precheck.test.ts tests/benchreactor-management.test.ts` | **2 文件 / 33 用例全通过**（5 + 28），`Duration 1.50s` |
| 5 | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | 退出 0（本批改了 SDK 类型；app 经 `dist-types/index.d.ts` 解析 SDK，缺这步 app type-check 会报 `checkDelete`/`BenchReactorDeletePrecheck` 不存在。产物未被 git 跟踪） |
| 6 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 退出 0，`✓ built in 16.59s`，产物 `dist/benchreactor-management-gcUlT4zl.js` **26.77 kB / gzip 6.83 kB**；产物哈希与上一轮一致 ⇒ 证明本批代码在 HEAD 前移后未被他人改写 |
| 7 | 产物内容抽查 | 页面块含 `checkDelete` 调用 1 处、`iconPaths` 2 处、`referenceCount` 2 处、`ensureRevision` 2 处；`packages/sdk-smp-api/dist/index.js` 含 `/check-delete` 路径。`dist/` 已 gitignore |

附：`prettier --check` index.vue 通过；`biome check` index.vue 剩 2 项（format、organizeImports）经与 HEAD 版本同命令比对证明**改动前即存在**，本批引入的 `lint/style/useTemplate` 已修掉。

**W1-01 更名复核 2026-10-06 01:09–01:12，HEAD `b9769b2a`**（本轮全部为实测输出，代码零改动）：

- 第 1–3 行三条必跑命令重新执行，退出码 `API=0 / APP=0 / ROUTES=0`；
- 第 4 行 `npx vitest run tests/benchreactor-acceptance-precheck.test.ts tests/benchreactor-management.test.ts` → **2 文件 / 33 用例全通过**（5 + 28），`Duration 1.61s`；
- 第 5 行 `build-dts` 退出 0；第 6 行 app `build` 退出 0，产物 `dist/benchreactor-management-CEjhaWMj.js` **26.77 kB / gzip 6.82 kB**；
- 第 7 行 token 抽查在新产物上重跑：`checkDelete` 1 处、`iconPaths` 2 处、`referenceCount` 2 处、`ensureRevision` 2 处，`sdk-smp-api/dist/index.js` 含 `check-delete` 2 处 —— 与上一轮逐项一致；文件名哈希相对上一轮变化但体积与命中数不变，判定为同包内他人页面引起的模块图哈希漂移，**本批代码未被改写**；
- `git diff --numstat` 对本批 6 个已跟踪文件的增删行数（`+10/−1`、`+2/−1`、`+114/−19`、`+25/−0`、`+12/−3`、`+129/−1`）与 §2 表内记录完全一致，`benchreactor-delete.ts` 仍为未跟踪新增。
背景红（非本批，本轮未重跑全量）：`localization.test.ts`（112 条他域缺 key）、`workflow-management.test.ts`（M05 丢 `labTypeList`）。**work5 不要以全量 vitest 绿作为本批放行条件**；本批的判定面是第 4 行这 33 例。

---

## 5. 测试前置条件（执行 §6 前必读）

**服务与产物**

| 依赖 | 要求 | 不满足 |
|---|---|---|
| portal `:5581` | serve 预构建 hash bundle（不吃 HMR 源码），本批 chunk `benchreactor-management-gcUlT4zl.js` | BLOCKED_DEPLOY |
| 网关 `:9090` | `/dev-api/device/benchreactor/*` → `futurefab-system` | BLOCKED_DEPLOY |
| 后端 9201 | 已重启并加载 `check-delete` 路由；Nacos 配置已发布 | BLOCKED_DEPLOY |
| SDK 静态资源包 | `@futurefab/ui-sdk-smp-static-files` 已构建（图标登记表随包产出） | 见 3.3 判读规则 |
| 源码若有再变更 | 依次重跑 static-files build → sdk `build-dts` → app `build`，以新 chunk 为准 | — |

**账号**（禁止猜测或硬编码凭据，缺账号即阻塞）

| 账号 | 权限 | 用于 |
|---|---|---|
| A | `device:benchreactor:query/add/edit/remove` + 目标实验室 | TC-01–TC-16、TC-18 |
| B | 有 `query`、无 `remove`（可另备无 `edit/add` 档） | 入口隐藏复核 |
| C（可选） | 无 `query` | TC-13 变体（预检 403 不得当成可删） |

**测试数据**：类别统一用 `ZZZ-TEST-20261005`（业务唯一键 `brand+category`），描述带 `work5-M02-batch01` 标记；需 1 条未被引用型号、1 条已被 `lab_bench_reactor` 引用型号；图标需三种形态各 1（登记内值 / 登记外历史值 / 空数组）。

**SQL**：只授权只读核验（live 为共享远端库，仓库 `nacos-config` 连接信息是过期副本）：

```sql
SELECT model_id, brand, category, description, icon_path, del_flag, update_time
  FROM dev_bench_reactor WHERE category = 'ZZZ-TEST-20261005' ORDER BY create_time DESC;
SELECT model_id, COUNT(*) FROM lab_bench_reactor WHERE model_id = <被引用型号> GROUP BY model_id;
SELECT request_id, management_revision, result_code, result_message
  FROM sys_management_request WHERE request_id IN (<抓到的 X-Request-Id>);
```

---

## 6. 给 work5 的详细测试方案（18 项逐项执行，每项必须回证据）

通用证据格式：页面名+步骤、method + 完整 URL、request headers（`X-Request-Id` / `X-Management-Revision` 实际值）、payload、response body、页面表现截图、Console 有无未捕获异常、操作前后 revision 对照、清理结果、结论状态词。

**TC-01 页面进入**
1. 账号 A 进入 `/settings/benchreactor-management`。
2. 预期：三个字典请求（`smp_brand_name`/`smp_capacity_type`/`smp_capacity_unit`）200；`GET /device/benchreactor/list?pageNum=1&pageSize=N` 200。
3. list 响应外壳顶层含 `managementRevision` 且非空（后续写请求的版本来源）。
4. 负例：阻断任一字典请求 → 可读错误、下拉不可用、编辑入口不放开、不白屏。
证据：首屏截图 + list 响应体（含 `managementRevision` 值）。

**TC-02 默认列表**
1. 无条件查询 → `list?pageNum=1&pageSize=N`，URL 不带任何筛选参数。
2. 列齐全（序号/图标/品牌/类别/容量单位/描述/更新人/更新时间/操作）；只有滚动加载一处分页，不得再出现分页条或 antd 分页。
证据：URL + 首屏截图。

**TC-03 keyword 筛选**
1. 输入 `  500L  `（带空格）→ 查询。
2. 预期 URL `keyword=500L`（trim 后），且**不含** `description=`、**不含** `params%5B`。
证据：URL 原文 + `total` 变化。

**TC-04 beginDate 单边**
1. 区间只填开始 `2026-07-01` → 查询。
2. 预期 URL 含 `beginDate=2026-07-01`，**不含** `endDate=`（单边不得被前端丢弃）。
证据：URL 原文 + 响应体片段。

**TC-05 endDate 单边**
1. 只填结束 `2026-07-31` → 预期 URL 含 `endDate=2026-07-31`、不含 `beginDate=`。
证据：URL 原文。

**TC-06 双边日期**
1. `2026-07-01` ~ `2026-07-31` → URL 同时含 `beginDate=2026-07-01&endDate=2026-07-31`（begin 在前）。
2. `total` 合理性：双边结果不多于任一单边结果。
证据：三条 URL 对照。

**TC-07 倒置日期**
1. 先确认 UI 是否可选出倒置值（`a-range-picker` 正常交互不能；若手工输入被控件自动归正，记 `NO_UI`）。
2. 若可构造（或通过 DevTools 改写 list 请求）：预期前端**不交换参数**，原样发出 `beginDate=2026-07-31&endDate=2026-07-01`。
3. 后端返回 400/参数校验错误时：页面必须**原文展示错误提示**（错误通道 `index.vue:119` → `useErrorMessage`），已提交条件不被清空，表格退回空态而非白屏。
4. 后端返回 200 空集时：显示空态，不报错。
证据：改写设置 + 请求 URL + 错误响应体 + 提示截图。

**TC-08 重置**
1. 填品牌多选 + keyword + 双边日期并查询 → 点重置。
2. 预期新请求四个条件一个都不带（空串会筛掉全部结果），从第一屏重查；表单三项清空。
证据：重置前后 URL 对照。

**TC-09 图标列显示**
1. 登记内值行（如 `icons/image/002-SUB-250L.png`）→ 缩略图**真实渲染**（本批缺陷修复点）。
2. `iconPaths` 长度 ≥ 2 → 多张横排，列宽 72 不换行不重叠。
3. 登记外历史值 → 不显示、列退回空态，**不得出现占位图**。
4. `iconPaths` 为空数组 → 空态。
5. DevTools 阻断某图标请求 → 失败那张摘除，同行其余图标与文字正常，Console 无未捕获异常。
6. 若全部图标空白且 Network 无失败请求 → 判 BLOCKED_DEPLOY，按第 5 节重建后再测。
证据：四种形态各 1 张截图 + 对应 list 响应里的 `iconPaths` 原文 + 步骤 5 阻断设置截图。

**TC-10 新增**
1. 填品牌 / 类别 `ZZZ-TEST-20261005` / 容量单位 / 描述。
2. 预期 `GET /device/benchreactor/check-unique?brand=<v>&category=<v>`，**不带 modelId**。
3. 重复提交（与既有 brand+category 相同）→ 非 200，页面**原文**显示"台式反应器型号已存在"，此时**不得**发 POST。
4. 正常提交 `POST /device/benchreactor`：headers 含两个守卫头（revision = 当前列表顶层值），payload `{brand, category, capacityUnit, description}`（图标字段表现见第 8 节待裁决），**不含 modelId**。
5. 响应 `data.applied=true` 且带 `managementRevision`；提示成功、列表刷新；记录写前/写后 revision。
证据：check-unique + POST 全套证据 + revision 对照。

**TC-11 修改**
1. 编辑 TC-10 型号 → `GET /device/benchreactor/{modelId}` 200，表单回填正确。
2. `check-unique` 必须带 `modelId=<当前>`；改成另一已存在组合应被拒并原文提示。
3. `PUT /device/benchreactor`：payload 含 `modelId`，带两个守卫头；成功回执 revision 覆盖本地值。
4. 图标选择器（**只记录不结论**）：改选图标保存后重读该行 `iconPaths` 是否变化（当前设计契约为只读，预期不变化）。
证据：detail / check-unique / PUT 证据 + 保存前后 `iconPaths` 对照。

**TC-12 删除预检 allowed=true**
1. 对未被引用型号点删除。
2. 预期 `GET /device/benchreactor/{modelId}/check-delete`，method GET，headers **不含** `X-Management-Revision`、**不含** `X-Request-Id`。
3. 响应 `{"allowed":true,"reasonCodes":[],"referenceCount":0,...}`（HTTP 200）。
4. 页面进入确认框，此时**仍未发 DELETE**。
证据：check-delete 全套证据 + 确认框截图。

**TC-13 删除预检 allowed=false**
1. 对已被引用型号点删除 → 响应 HTTP 200、`{"allowed":false,"reasonCodes":["REFERENCE_EXISTS"],"referenceCount":2,...}`。
2. 页面提示必须含三段：型号标识（`品牌 / 类别`）、引用保护文案、`已被引用 2 处`。
3. Network **不得出现 DELETE**，确认框**不得弹出**。
4. 变体：无 `query` 账号 → 403 → 按错误终止删除，不得当成可删；`reasonCodes` 为空但 allowed=false → 兜底"删除被阻止"；未登记原因码（mock `LOCKED_BY_X`）→ 原样显示；check-delete 5xx/超时 → 终止删除。
证据：主用例 + 四个变体各一套 Network/截图。

**TC-14 删除成功**
1. 承接 TC-12 点确认 → `DELETE /device/benchreactor/<modelId>`（批量为 `.../<id1>,<id2>` 逗号连接），带两个守卫头。
2. 取消分支：预检通过后点取消 → 不发 DELETE（勾选是否保留只记录不判缺陷）。
3. 响应 200 且 `data.managementRevision` 大于写前值；`deletedSuccessfully`、列表刷新、该行消失、`total` 减少。
证据：DELETE 证据 + 删除后 list 响应 + revision 对照。

**TC-15 被引用不删除（并发）**
1. 型号 X 预检 `allowed=true` 后停在确认框；另一会话为 X 建一条实验室实例引用；再点确认删除。
2. 预期后端守卫事务内重验引用 → 409 且 canonical errorCode `REFERENCE_EXISTS`。
3. 页面提示必须是"存在受保护引用…"口径，**不得**显示成"数据已被他人修改，请刷新重试"。
4. 只读 SQL 确认 `del_flag` 未变（数据未被删除）。
证据：预检响应 + 409 响应体 + `sys_management_request` 行 + 提示截图 + 解除引用后再删（清理）。

**TC-16 缺 revision 短路**
1. 构造版本不可得：DevTools 改写 list 响应去掉顶层 `managementRevision`（或阻断 list 后直接操作），弹窗保持打开。
2. 点保存 / 点确认删除 → 页面提示 `未取到管理版本，已取消本次…请刷新列表后重试`。
3. **Network 不得出现 POST/PUT/DELETE**。
证据：改写设置 + 提示截图 + Network 面板（无写请求）。

**TC-17 409 冲突提示**
1. 改写 list 响应使 `managementRevision` 比服务端真实值小 1 → 提交新增/修改 → 409 `MANAGEMENT_CONFLICT`。
2. 页面提示刷新/重试口径；**下一次**写请求前必须重新取版本（头里的 revision 变成真实值），不得重复用同一旧值再撞。
3. 幂等：同一 `X-Request-Id` 重放两次同 payload → 第二次命中幂等，数据不二次落库；连续两次不同写操作 `X-Request-Id` 必须不同。
证据：两次写请求 headers 对照 + 409 响应体 + `sys_management_request` + 最终仅一条数据。

**TC-18 测试数据清理**
1. 删除本轮全部 `ZZZ-TEST-20261005` 型号；TC-15 建的实例引用必须先解除。
2. 只读复核该 category 的行 `del_flag` 全部删除态或不存在。
3. 无法清理必须写明"保留原因 + 残留主键"，禁止用 SQL 写操作代劳。
证据：清理前后 SQL 结果截图 + 残留清单（如有）。

---

## 7. 测试数据建议（含清理方式）

| 数据 | 建议值 | 用途 | 清理 |
|---|---|---|---|
| 测试类别 | `ZZZ-TEST-20261005` | 唯一键 `brand+category` 定位 | TC-18 |
| 测试品牌 | 复用字典既有值 | 不新增字典项 | 不动字典 |
| 描述标记 | `work5-M02-batch01` | SQL/截图核对 | 随型号删除 |
| 被引用型号 | 现网已有引用关系者优先 | TC-13 / TC-15 | 先解除引用再删 |
| 图标三形态 | 登记内值 / 登记外历史值 / 空数组 | TC-09 | 只读观察 |

---

## 8. 已知风险 / 阻塞

1. **待裁决：编辑表单仍提交 `iconPath`，与设计契约冲突。** `设备型号库设计.md` 第 34/48/58 行明确图标只读、客户端不得提交 `icon_path`；后端 `DevBenchReactorCreateCommand` / `UpdateCommand` 实测只有 `brand/category/capacityUnit/description(/modelId)`。当前 `benchreactor-editor.vue` 保留图标选择器并提交 `iconPath`（被 Jackson 静默丢弃 → 选了图标保存后不生效）。请总控裁决：移除前端图标写入口（纯前端但属产品可见行为变更，超本批范围）或后端补写白名单（后端改动，本批禁止）。未裁决前保持现状。
2. **风险：`iconPaths` 修复历史上被回退过两次**（`24bbffec` 从 SDK 类型移除 `iconPaths`、`32789f48` 把页面绑回单值 `iconPath`），与读口 `DevBenchReactorRow.java:31` 矛盾，也正是本批"有值不渲染"的根因。复核点：`grid.ts` 图标列 field 必须是 `iconPaths`，`index.vue` slot 必须是 `iconUrls(row.iconPaths)`。若再次被改回单值，缺陷复发。
3. **倒置日期未加前端提示（有意为之）**：UI 不可构造该值，加校验即死代码；口径为原样透传 + 后端错误走列表错误通道展示（见 3.1、TC-07）。若总控要求即时提示，需更换筛选控件形态并另批下达。
4. **BACKEND_CONTRACT_GAP：无。** check-delete 已按 PKG-00 冻结壳返回 `allowed/reasonCodes/referenceCount/managementRevision`；`canDelete` 属被取代旧措辞，前端未做兼容分支，也不应为此在后端补别名。
5. **BLOCKED_ASSET_BASE：不适用**（理由见 3.3，含与 BLOCKED_DEPLOY 的区分规则）。
6. **BLOCKED_DEPLOY**：源码与本批构建已完成，但 portal bundle 是否已发布、网关路由、9201 是否重启加载 check-delete 未由本批验证 —— 第 5 节是放行前置。
7. **NOT_VERIFIED**：本批全部 HTTP、浏览器、数据库、外部系统、现场验收未执行。
8. **共享工作树**：HEAD 已从 `12b3d49d` 前进到 `47ad1290`（他人在 M04/M06/M07 提交），本批 8 个改动文件与新增文件仍**只在工作树**、`12b3d49d..HEAD` 无前端路径交叉。work5 复测前请重新 `git status --short` 确认未被覆盖。
9. **既有背景红**：`localization.test.ts`（112 条他域缺 key）、`workflow-management.test.ts`（M05 丢 `labTypeList`），非本批引入、未代改。
10. **不在本批范围**：`/lab/labbenchreactor/**`（实验室实例侧）、兄弟型号页同类 `iconPath` 单值读法。

---

## 9. work5 测试记录区（work5 填写，work1 不代填）

| 用例 | 日期 | 结论状态词 | 证据编号 | Console 未捕获异常 | 偏差/阻塞说明 |
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
| TC-15 被引用不删除 | | | | | |
| TC-16 缺 revision 短路 | | | | | |
| TC-17 409 冲突提示 | | | | | |
| TC-18 测试数据清理 | | | | | |

状态词取值限定：`IMPLEMENTED` / `CONTRACT_TESTED` / `HTTP_VERIFIED` / `BROWSER_VERIFIED` / `BLOCKED_DATA` / `BLOCKED_MENU` / `BLOCKED_DEPLOY` / `BLOCKED_EXTERNAL` / `NO_UI` / `NOT_VERIFIED`。

---

## 10. 最终结论区（work5 执行后填写；work1 留空，不做最终测试结论）

- 可以宣称完成的事项：（待填）
- 仅代码 / 契约测试完成的事项：TC-01–TC-18（当前层级 = CONTRACT_TESTED + 生产构建通过）
- HTTP 已验证但未浏览器验收：（待填）
- 浏览器已验证：（待填）
- 数据 / 菜单 / 部署 / 外部阻塞：（待填；已知候选 BLOCKED_DEPLOY、TC-13/TC-15 的 BLOCKED_DATA）
- 仍需裁决事项：第 8 节 1（图标写入白名单）、3（倒置日期是否需要前端即时提示）
- 禁止措辞：未取得 HTTP + 浏览器 + 数据库 + 外部系统 + 现场证据前，不得写"全部完成""上线完成"。
