# M02 前端交付与测试方案：实验室台式反应器页面可测性与验收辅助

- 任务：M02 前端开发：实验室台式反应器页面行操作可测性与验收辅助优化（执行人 work5）
- 交付日期：2026-10-05
- 页面范围：`/setting/labs/deviceConfig/labbenchreactor` → 后端 `/lab/labbenchreactor/*`
- 契约依据：`docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md` 实例 01 台式（INS-01-01..07）、AGENTS.md §13.2 完成口径、§13.3 守卫写、§13.4 浏览器验收
- 本批性质：**纯可测性批次**。不新增业务功能、不改业务逻辑、不改请求路径/payload/headers/revision 逻辑、不改页面可见文案
- 本批状态：**IMPLEMENTED + CONTRACT_TESTED + 类型检查通过**。HTTP、浏览器、数据库一律**NOT_VERIFIED**，由 work9 按本文第五节执行后另行结论
- git 状态：未 `git add`、未 commit、未 push

---

## 一、模块信息

| 项 | 内容 |
|---|---|
| 所属模块 | M02 实验室与资源管理 / 实验室台式反应器（实例 01） |
| 前端应用包 | `@futurefab/ui-app-smp-settings` |
| 页面目录 | `futurefab-frontend/packages/app-smp-settings/src/views/lab-labbenchreactor/` |
| 后端接口 | `list`、`edit-options`、`{reactorId}`、`check-unique`、`check-vessel-no`、`check-controller-no`、`{reactorId}/check-delete`、`POST/PUT`、`DELETE /{reactorIds}` |
| 守卫写接口 | `POST`（新增）、`PUT`（修改）、`DELETE`（删除）三处 `@ManagementGuardedWrite` |
| 只读接口 | `list`、`edit-options`、`{reactorId}`、三个 `check-*`、`check-delete`（不带守卫写头） |
| 权限标识 | `lab:labbenchreactor:add` / `edit` / `remove` / `list`；泵连接按钮复用 `lab:pumpconnection:list` |
| 语言包命名空间 | `lab.benchreactor.*`（页面已注册，本批未新增词条） |
| 不在本批范围 | `/settings/benchreactor-management`、`/device/benchreactor/*`、M03–M09、后端 Java/Mapper/XML、SQL、客户材料、history |

### 本批要解决的问题

work1 已完成该页面「列表查询」「新增」的浏览器验收，**修改、删除预检、删除、409 冲突提示**四项长期阻塞，根因是：

1. 行内「修改 / 删除」按钮与行复选框由 `SmpScrollGrid`（内部 VXE Grid）渲染，DOM 上**没有任何业务标识**，自动化只能靠视觉坐标或按钮文案定位；
2. 行复选框的点击目标是 VXE 内部生成的 `.vxe-cell--checkbox`，页面拿不到该节点的任何稳定属性；
3. 成功 / 409 / 预检阻断这几类**结论只体现在 antd message 上**，而 message 3 秒自动消失、同一时刻只保留一条，自动化只能在提示消失前后赌时序，极易误判。

本批即为这三点补稳定定位入口，**不触碰任何业务判定**。

---

## 二、修改范围

### 2.1 修改文件清单（本批全部改动）

| # | 文件 | 类型 | 说明 |
|---|---|---|---|
| 1 | `packages/app-smp-settings/src/views/lab-labbenchreactor/test-ids.ts` | **新增**（约 155 行） | 定位属性值生成器：行/复选框 class、行内按钮 testid、弹窗与工具栏 testid、表单字段 testid、版本镜像与写结论镜像的归一函数。抽成独立 `.ts` 是为了让 node 环境单测能直接执行 |
| 2 | `.../lab-labbenchreactor/grid.ts` | 修改（+16/−4） | 新增 `rowClassName` 行级钩子；checkbox 列新增 `className` 函数。两者都带 `reactorId`，解决"复选框定位不到" |
| 3 | `.../lab-labbenchreactor/index.vue` | 修改（+41/−3） | 行内修改/删除按钮 testid、行操作区容器与 `data-reactor-id`/`data-asset-no`、工具栏三个按钮 testid、页面根 `data-testid`、版本与删除结论镜像 |
| 4 | `.../lab-labbenchreactor/labbenchreactor-editor.vue` | 修改（+18/−4） | 弹窗根 `class-name`、确定/取消按钮 testid、六个可写字段 testid |
| 5 | `tests/lab-labbenchreactor-guarded-write.test.ts` | 修改（+194） | 新增「可测性：稳定定位属性」6 个用例；SFC 行为测试桩放行新的 `./test-ids` 导入 |

工作树核验：`git status --short` 中属于本批的仅上述 5 项（4 个 `M` + 1 个 `??`）。其余 `M`（`benchreactor-management/*`、`sdk-smp-api/src/benchreactor.ts`、`sdk-language/src/language/smp-settings/*`、`tests/benchreactor-*.test.ts`）与 `??`（`benchreactor-delete.ts`、`.tmp-*.py`）**均为他人在途改动，本批未触碰、未纳入**。

### 2.2 未改动（明确登记）

- 后端 Java / Mapper / XML、SQL：零改动。
- `sdk-smp-api`、`sdk-language`：**零改动**。本批不需要新增词条（全部复用页面已有 key），也不改任何请求封装 → 因此**未触发** `ui-sdk-smp-api` 的 `type-check` / `build-dts`。
- 共享组件 `SmpScrollGrid`、`SmpDialog`、`message-box`、`tips`：**零改动**。这是刻意的——共享组件被全站页面共用，为单页验收改它会放大风险面。故行/复选框定位改走 VXE 官方 `rowClassName` 与列 `className` 钩子（见 2.3）。

---

## 三、本轮可测性改动（work9 脚本入口）

统一前缀 `lab-benchreactor-`，全部集中在 `test-ids.ts`，改一处即全页生效。

### 3.1 行操作（第 1 类阻塞的解法）

| 目标 | 定位方式 | 说明 |
|---|---|---|
| 行容器 | `tr.lab-benchreactor-row--<reactorId>` | 由 `grid.ts` 的 `rowClassName` 生成 |
| 行操作区 | `[data-testid="lab-benchreactor-row-actions"]`，其上带 `data-reactor-id`、`data-asset-no` | 可反查业务主键 |
| 修改按钮 | `[data-testid="lab-benchreactor-row-edit-<reactorId>"]` | 行内按钮，**不依赖文案与坐标** |
| 删除按钮 | `[data-testid="lab-benchreactor-row-delete-<reactorId>"]` | 同上 |
| 行复选框单元格 | `td.lab-benchreactor-checkbox-cell--<reactorId>` | VXE 自渲染，只能走列 `className` |
| 行复选框点击目标 | `td.lab-benchreactor-checkbox-cell--<reactorId> .vxe-cell--checkbox` | VXE 内部 span，页面无法加属性 |

> `reactorId` 契约上是雪花 ID（纯数字），原样透出。`safeToken()` 会过滤非 `[A-Za-z0-9_-]` 字符并在过滤后为空时退回 `unknown`——定位失败表现为"找不到元素"，而不是"选中错误的行"。

### 3.2 工具栏与弹窗

| 目标 | 定位方式 |
|---|---|
| 新增 | `[data-testid="lab-benchreactor-add"]` |
| 批量删除 | `[data-testid="lab-benchreactor-batch-delete"]` |
| 泵的默认连接 | `[data-testid="lab-benchreactor-pump-connection"]` |
| 编辑弹窗根 | `.lab-benchreactor-editor-dialog`（落在 `.vxe-modal--box` 上） |
| 保存（确定） | `[data-testid="lab-benchreactor-editor-submit"]` |
| 取消 | `[data-testid="lab-benchreactor-editor-cancel"]` |
| 表单字段 | `[data-testid="lab-benchreactor-field-<字段名>"]`，字段名为契约名：`labId` / `assetNo` / `vesselNo` / `controllerNo` / `maxCapacity` / `modelId` |

> 字段按**契约字段名**而非 label 文案定位：中英文切换后 label 会变，字段名不会。
> `a-select` 的 `data-testid` 落在选择器根节点，选项在下拉浮层中（`transfer` 到 body），点选项时按可见文本选即可。

### 3.3 结论镜像（第 3 类阻塞的解法）

挂在页面根节点 `[data-testid="lab-benchreactor-page"]` 上，**只读镜像，不参与任何请求**：

| 属性 | 取值 | 用途 |
|---|---|---|
| `data-management-revision` | 当前 `managementRevision` 的安全 token；**取不到时为 `unknown`（属性仍存在）** | 不开 Network 即可断言"页面手上有没有版本"，负例也能断言 |
| `data-last-delete-outcome` | `idle` / `success` / `precheck-blocked` / `revision-missing` / `conflict` / `failed` | 删除结论，不再依赖会消失的 message |

`writeOutcomeAttr()` 对任何未知值一律降级为 `failed`，**绝不把服务端文案原样写进 DOM 属性**（防属性注入）。

> 这两个属性是**镜像而非替代**：message 提示照旧弹出，页面行为、节奏、文案完全未变。脚本建议优先断言这两个稳定 token，message 仅作辅助取证。

### 3.4 守卫写与业务逻辑保持不变（逐条核对）

- 请求路径、方法、payload、headers：**零改动**。
- 缺 revision 短路：`ensureRevision()` 后 `revision == null || revision === ""` 即提示并 `return`，不发写请求 —— 保留。
- 409：`invalidateOnConflict(e)` + `writeErrorMessage(e)` 分流，弹窗不关闭 —— 保留。
- `X-Request-Id` / `X-Management-Revision`：仍由 `writeMeta(revision)` 统一携带，每次写重新生成 —— 保留。
- 写动作互斥：`if (deleting.value) return;` 与 `finally` 复位 —— 保留。
- 唯一的行为性新增：`lastDeleteOutcome.value = ...` 共 5 处**纯赋值**，不改变任何分支走向。
- 测试已钉住上述口径（`可测性改动不得改动请求与守卫写口径` 用例）。

---

## 四、已执行验证命令与结果

均在 `futurefab-frontend/` 目录执行。**按"代码 → 验证 → 建本文档"顺序执行，前两步全绿后才创建本 MD。**

| # | 命令 | 结果 |
|---|---|---|
| 1 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | ✅ 通过（`vue-tsc --noEmit --composite false`，无输出即无错） |
| 2 | `pnpm run routes:check` | ✅ 通过（`tsx scripts/generate-route-paths.ts --check`，无差异输出） |
| 3 | `npx vitest run tests/lab-labbenchreactor-guarded-write.test.ts` | ✅ 通过：**1 文件 / 28 用例全绿**（原 22 + 新增 6） |
| 4 | `npx vitest run tests/lab-settings-regressions.test.ts tests/lab-management.test.ts tests/lab-management-display.test.ts tests/lab-instance-shell.test.ts` | ✅ 通过：**4 文件 / 30 用例全绿**（邻近页面回归，无回归） |
| 5 | `npx prettier --check`（`test-ids.ts`、`grid.ts`） | ✅ 通过（`test-ids.ts` 首轮报格式问题，已 `--write` 修正并复跑第 1、3 项仍全绿） |

**未执行**（如实登记）：
- `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` / `build-dts` —— **本批未改 SDK 与 API 封装**，无触发条件。
- 生产构建 `pnpm --filter @futurefab/ui-app-smp-settings run build` —— 本批未跑。**work9 浏览器验收前必须先构建**，因为 portal 跑的是预构建产物、不吃源码（见 5.0）。
- HTTP / 浏览器 / SQL —— 全部未执行。

分层结论：**静态检查通过 + 编译（type-check）通过 + 契约测试通过**。按 AGENTS.md §13.2，**不得**据此宣称 `HTTP_VERIFIED` / `BROWSER_VERIFIED`。

---

## 五、给 work9 的浏览器测试方案

### 5.0 测试前置（不满足直接记 BLOCKED_DEPLOY / BLOCKED_MENU，不得判页面缺陷）

1. **必须先构建**（本批未跑 build）：portal `:5581` serve 的是预构建 hash bundle，不吃源码 HMR。在 `futurefab-frontend/` 执行：
   ```
   pnpm --filter @futurefab/ui-sdk-smp-static-files build
   pnpm --filter @futurefab/ui-sdk-smp-api run build-dts
   pnpm --filter @futurefab/ui-app-smp-settings run build
   ```
   构建后请确认产物 chunk 内含字符串 `lab-benchreactor-row-edit-` 与 `lab-benchreactor-editor-submit`，以此确认新代码已进包。**未确认这两串字符串就不要开始验收。**
2. 后端 `futurefab-system`（9201）已启动且加载 `/lab/labbenchreactor/*`；网关、菜单、权限按现网。
3. 主数据：**至少 1 条未被引用的台式反应器**（用于删除）、**1 条已被引用的**（用于预检阻断）。缺后者 → 记 **BLOCKED_DATA**，禁止把"预检返回 200 / allowed=true"当成阻断用例通过。
4. 打开 DevTools：**Network（勾 Preserve log）+ Console**，Console 清空后再开始；每条用例截图。

### 5.1 TC-ENTER 页面进入

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 登录后进入 `/setting/labs/deviceConfig/labbenchreactor` | 页面渲染，无未捕获异常，Console 无红色报错 |
| 2 | 定位页面根 | `[data-testid="lab-benchreactor-page"]` 存在且可见 —— **这是本批新增的验收锚点** |
| 3 | 看 Network | `GET /lab/labbenchreactor/list?pageNum=1&pageSize=N` 200；`GET /lab/lab/list`（实验室下拉）200 |
| 4 | 看 list 响应外壳 | 顶层含 `code/rows/total/managementRevision`，`managementRevision` 非空 |
| 5 | 断言版本镜像 | 页面根的 `data-management-revision` 等于第 4 步 `managementRevision` 的实际值 |
| 6 | 断言初始结论镜像 | `data-last-delete-outcome` 为 `idle` |

证据：截图 1 张 + list 响应 body + 两个 data 属性的实际值。

### 5.2 TC-LIST 列表与筛选

| 步 | 操作 | 期望（URL 精确核对） |
|---|---|---|
| 1 | 选实验室 + 输入资产/罐体关键字 + 点查询 | URL 出现 `labId=`、`keyword=<trim后>`、`pageNum`、`pageSize`；**不出现** `searchKey`、`params[` |
| 2 | 只填修改时间开始日期 | 出现 `startDate=` 与 `timeField=updateTime`，**不出现** `endDate=` |
| 3 | 只填结束日期 | 只有 `endDate=`，单边日期不得被前端丢弃 |
| 4 | 点重置 | 发空条件（无 labId/keyword/日期），从第一屏重查 |
| 5 | 断言行定位可用 | 任取一行，能用 `tr.lab-benchreactor-row--<reactorId>` 定位到，且该行内 `[data-testid="lab-benchreactor-row-edit-<reactorId>"]` 与 `...-row-delete-...` 均存在 |
| 6 | 空结果 | 空态提示，不报错、不白屏 |

证据：每步 Network 请求 URL 原文 + 行定位截图（含 testid 实际值）。

### 5.3 TC-CREATE 新增

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 点 `[data-testid="lab-benchreactor-add"]` | 弹窗出现，根节点 class 含 `lab-benchreactor-editor-dialog` |
| 2 | 填字段 | 按 `[data-testid="lab-benchreactor-field-labId"]` 等 6 个字段定位填充 |
| 3 | 点 `[data-testid="lab-benchreactor-editor-submit"]` | 先发 `check-unique` / `check-vessel-no` / `check-controller-no` 三个只读校验 |
| 4 | 观察写请求 | `POST /lab/labbenchreactor`，headers 含 `X-Request-Id`、`X-Management-Revision`（= 页面根 `data-management-revision`），body 仅含 `labId/assetNo/vesselNo/controllerNo/modelId/maxCapacity/remark`，**不含** `reactorId`、`brand`、`category` 等只读派生字段 |
| 5 | 成功 | 提示"新增成功"；列表刷新；`data-management-revision` 更新为回执 `managementRevision` |

### 5.4 TC-UPDATE 修改（**原阻塞项，本批重点**）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 点某行 `[data-testid="lab-benchreactor-row-edit-<reactorId>"]` | **能稳定点到**（这是本批解开的阻塞）；弹窗打开，`GET /lab/labbenchreactor/<reactorId>` 200，表单回填正确 |
| 2 | 改 `assetNo`（或 `maxCapacity`）为新值 | 字段值变化被正确回显 |
| 3 | 点 `[data-testid="lab-benchreactor-editor-submit"]` | 三个 `check-*` 携带 `reactorId=<当前>`（用于排除自身） |
| 4 | 观察写请求 | `PUT /lab/labbenchreactor`，body 含 `reactorId`，两个守卫头齐全 |
| 5 | 成功 | 提示"修改成功"；列表刷新；该行 `assetNo` 已更新；版本镜像更新 |
| 6 | 回归点取消 | 点 `[data-testid="lab-benchreactor-editor-cancel"]` 应直接关闭弹窗且**不发任何写请求** |

证据：PUT 的 method+URL+headers+payload+response body + 修改前后同一行 `assetNo` 对照 + 编辑按钮 testid 实际值。

### 5.5 TC-PRECHECK 删除预检（**原阻塞项**）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 勾选一行复选框 | **能稳定勾选**：先定位 `td.lab-benchreactor-checkbox-cell--<reactorId>`，再点其内 `.vxe-cell--checkbox`（本批解开的阻塞） |
| 2 | 断言勾选生效 | 该 `<tr>` 获得 `row--checked` class；工具栏 `[data-testid="lab-benchreactor-batch-delete"]` 由 disabled 变可用 |
| 3 | 对**已被引用**的行点删除 | Network 出现 `GET /lab/labbenchreactor/<reactorId>/check-delete`；方法 **GET**；headers **不含** `X-Management-Revision` / `X-Request-Id`（只读接口） |
| 4 | 看预检响应 | HTTP 200，body 形如 `{"code":200,"data":{"allowed":false,"reasonCodes":["REFERENCE_EXISTS"],...}}` |
| 5 | **断言结论镜像** | 页面根 `data-last-delete-outcome` 等于 **`precheck-blocked`**（本批新增，替代对瞬时 message 的赌时序） |
| 6 | 看页面提示 | 提示含"删除预检未通过，未执行删除" + 原因文案 |
| 7 | 看 Network | **不得出现 DELETE** |
| 8 | 对**未被引用**的行点删除 | `allowed=true` → 进入确认弹窗，此时仍未发 DELETE；`data-last-delete-outcome` 仍为 `idle` |
| 9 | 批量勾选（含 1 条被引用 + 1 条可删） | 对每个目标各发一次 `check-delete`；只要一条 `allowed=false`，整批阻断、不进确认、不发 DELETE；`data-last-delete-outcome` = `precheck-blocked` |
| 10 | 预检失败注入（阻断 `check-delete` 使其 500/404/离线） | 页面提示错误并终止删除；**不得**进入确认、不得发 DELETE、不得当成"无引用可删"；`data-last-delete-outcome` = `failed` |
| 11 | 异常响应形状 | `allowed=false` 且 `reasonCodes` 为空 → 显示兜底文案；返回未登记原因码（如 `LOCKED_BY_X`）→ 原样显示该码，不空白 |

### 5.6 TC-DELETE 删除执行（**原阻塞项**）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 预检通过后在确认弹窗点取消 | **不发 DELETE**；`data-last-delete-outcome` 保持 `idle` |
| 2 | 再点删除并确认 | `DELETE /lab/labbenchreactor/<reactorIds>`（多 ID **逗号连接**），两个守卫头齐全 |
| 3 | **断言结论镜像** | 页面根 `data-last-delete-outcome` 等于 **`success`**；提示"删除成功" |
| 4 | 列表变化 | 目标行消失，`total` 减少；`tr.lab-benchreactor-row--<被删id>` 不再存在 |
| 5 | 版本镜像 | `data-management-revision` 更新为删除回执携带的值 |

### 5.7 TC-REF-REFUSED 被引用禁止删除

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 选一条已被 `lab_bench_reactor` 引用的记录 | 确认其占用状态（列表「状态」列显示使用中/已预约） |
| 2 | 点删除并确认 | `check-delete` 返回 `allowed=false` |
| 3 | 断言 | **不发 DELETE**；提示含引用保护原因；`data-last-delete-outcome` = `precheck-blocked` |
| 4 | 该行仍在列表 | 记录未被删除 |

若现网无被引用数据 → 记 **BLOCKED_DATA**，写明缺失的主数据项，**不得**以 allowed=true 代替。

### 5.8 TC-GUARD-NOREV 缺 revision 短路（负例）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | DevTools 阻断 list 请求，使页面拿不到顶层 `managementRevision`；刷新页面 | `data-management-revision` 为 **`unknown`**（属性仍在） |
| 2 | 直接点保存 | 页面先补读一次版本；仍取不到则提示"未取到管理版本，已取消本次保存…" |
| 3 | **断言结论镜像** | 编辑器不发 POST/PUT；页面根 `data-management-revision` 仍为 `unknown` |
| 4 | 删除路径重复第 1–3 步 | 点删除 → `data-last-delete-outcome` 等于 **`revision-missing`**；**不发 DELETE**，且**不得**提示"删除成功" |

> 该负例必须在 request 拦截层做（阻断或改写 list 响应），**不得**为通过测试而放宽后端 `RequestMeta` 或删除 `@ManagementGuardedWrite`。

### 5.9 TC-CONFLICT 409 冲突提示（**原阻塞项**）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 用 map-local 或响应改写，把 list 返回的 `managementRevision` 固定为一个**旧值** | 页面根 `data-management-revision` 随之变为旧值 |
| 2 | 点保存提交 | 后端返回 409 / `MANAGEMENT_CONFLICT`；页面提示必须是"刷新…重试"口径 |
| 3 | 断言弹窗状态 | 编辑弹窗**不关闭**（用户还能改完再提交） |
| 4 | 再点一次保存 | **请求前必须重取一次版本**（Network 出现新的 list 请求），且新写请求的 `X-Management-Revision` 为**新值**而非旧值 |
| 5 | 断言幂等键 | 两次写请求的 `X-Request-Id` **不相同**（每次写重新生成） |
| 6 | 删除路径重复第 1–5 步 | `data-last-delete-outcome` 等于 **`conflict`**；重试成功后变为 **`success`**；全程**不得**在失败时提示"删除成功" |

### 5.10 TC-PERM 权限与菜单

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 无 `lab:labbenchreactor:remove` 角色 | 行内删除按钮、工具栏批量删除不可达 |
| 2 | 无 `edit` / `add` | 行内修改按钮、工具栏新增按钮相应消失 |
| 3 | 菜单入口 | 记录菜单是否已挂载该页面；缺菜单/入口 → 标 **BLOCKED_MENU**，不得用直接改 URL 替代验收 |

### 5.11 TC-DATA 测试数据与清理

**清理既有遗留（优先）**
- work1 遗留未清理数据：`W1-M02-AC-01` / `reactor_id=1304543080464125952`。
- 若仍存在，**优先用页面删除流程清理**（走 5.6），顺带当作一次删除验收。
- 若该行已被引用导致删不掉 → 在报告里写明"数据保留 + 原因"，并标注 reactorId，**不得静默遗留**。

**本批新增数据**
- 前缀建议：`W5-M02-LAB-*`（资产编号 `assetNo`、罐体编号 `vesselNo`、控制器编码 `controllerNo` 均用此前缀，便于识别与批量清理）。
- 例：`assetNo=W5-M02-LAB-A01`、`vesselNo=W5-M02-LAB-V01`、`controllerNo=W5-M02-LAB-C01`、`maxCapacity=100`。

**清理要求**
- 每个用例结束即清理；新增用例产生的数据必须在用例内删除。
- 清理完成后重新查询，确认 `tr.lab-benchreactor-row--<reactorId>` 已不存在。
- 只读核验 SQL（**仅在已授权时执行，禁止任何写操作**）：
  - `SELECT reactor_id, lab_id, asset_no, vessel_no, controller_no, occupancy, del_flag, update_time FROM lab_bench_reactor WHERE asset_no LIKE 'W5-M02-LAB-%' OR asset_no = 'W1-M02-AC-01' ORDER BY create_time DESC;`
  - `SELECT request_id, management_revision, result_code, result_message FROM sys_management_request WHERE request_id IN (<本次抓到的 X-Request-Id>);`
    说明：守卫写的 400/409 拒绝**只进 WARN 日志、不落服务日志文件**，必须靠这张表取证。
  - 注意：live 数据源是共享远端库，仓库 `nacos-config` 里的连接信息是过期副本，勿据此连库。

**每条用例必须交回**
1. 页面名称与操作步骤；
2. HTTP method + 完整 URL；
3. request headers（重点 `X-Request-Id`、`X-Management-Revision` 实际值）；
4. request payload；
5. response body；
6. 操作前/后 `data-management-revision` 与 `data-last-delete-outcome` 的对照；
7. 后端日志是否出现 `RequestMetaInvalidException`、`GlobalExceptionHandler` 或业务异常；
8. 测试数据清理结果（或保留原因）；
9. 结论状态词（AGENTS.md §13.2 之一）。

禁止：以单元/契约测试或静态检查通过代替浏览器验收结论；不得用较低层级结果宣称较高层级完成。

---

## 六、测试记录区（work9 填写）

| 用例 | 结论状态 | 证据（截图/请求 URL） | 备注 |
|---|---|---|---|
| TC-ENTER 页面进入 | | | |
| TC-LIST 列表与筛选 | | | |
| TC-CREATE 新增 | | | |
| TC-UPDATE 修改 | | | 原阻塞项 |
| TC-PRECHECK 删除预检 | | | 原阻塞项 |
| TC-DELETE 删除执行 | | | 原阻塞项 |
| TC-REF-REFUSED 被引用禁止删除 | | | 缺数据记 BLOCKED_DATA |
| TC-GUARD-NOREV 缺 revision 短路 | | | 负例 |
| TC-CONFLICT 409 冲突提示 | | | 原阻塞项 |
| TC-PERM 权限与菜单 | | | |
| TC-DATA 清理 | | | W1-M02-AC-01 + W5-M02-LAB-* |

---

## 七、最终结论区（work9 填写）

- 实际执行用例数 / 通过数：
- 分层结论（勾选）：`HTTP_VERIFIED` ☐ `BROWSER_VERIFIED` ☐ `NOT_VERIFIED` ☐
  阻塞项（勾选）：`BLOCKED_DATA` ☐ `BLOCKED_MENU` ☐ `BLOCKED_DEPLOY` ☐ `BLOCKED_EXTERNAL` ☐
- 遗留数据与原因：
- 与本文档不符的实际行为（如有，注明用例号与差异）：
- 结论（禁止使用"全部完成"等笼统措辞）：

---

## 八、未验证 / 待裁决

1. **NOT_VERIFIED（本批全部）**：HTTP、浏览器、数据库、外部系统与现场验收均未执行。本批只到"静态检查 + type-check + 契约测试"。
2. **BLOCKED_DEPLOY**：本批**未执行生产构建**。portal 跑预构建产物，work9 验收前必须先构建并确认产物含 `lab-benchreactor-row-edit-`（见 5.0 第 1 步）。
3. **依赖共享组件内部类名**：复选框点击目标 `.vxe-cell--checkbox`、弹窗根 `.vxe-modal--box` 来自 VXE / `SmpDialog` 的内部实现。本批刻意不改共享组件，故这两处依赖内部类名。**若后续升级 VXE 导致这两个类名变化，只需改 work9 脚本的这两行选择器，不需改页面。** 行级/按钮级定位全部走本批自有属性，不受影响。
4. **结论镜像的定位**：`data-last-delete-outcome` 只覆盖**删除**路径。新增/修改的成功与冲突结论仍需从 message 或 Network 取证（本批未在编辑器侧加镜像，以避免跨组件事件接线扩大改动面）。若 work9 认为新增/修改也需要稳定 token，可提下一批次补。
5. **既有背景红（他人 drift，未代改）**：`tests/localization.test.ts`、`tests/workflow-management.test.ts` 等基线红不在本批范围，也未被本批触碰。
6. **待裁决（无）**：本批未发现前端与设计契约冲突。