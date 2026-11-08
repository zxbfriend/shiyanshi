# M02 前端交付与测试方案：W1-02 —— lab-labbenchreactor 行操作可测性与验收辅助

## 一、基本信息

| 项 | 内容 |
| --- | --- |
| 模块 | M02 主数据（实验室实例侧 INS-01-01..07） |
| 页面 | `/setting/labs/deviceConfig/labbenchreactor`（台式反应器实例管理） |
| 接口族 | `/lab/labbenchreactor/*`（list / detail / edit-options / check-unique / check-vessel-no / check-controller-no / check-delete / POST / PUT / DELETE） |
| 批次名 | **W1-02** testability（可测性与验收辅助，不改业务语义；原编号「Batch 02」，按总控 2026-10-06 W1 序列更名，内容口径未变） |
| 执行人 | work1（前端分批开发） |
| 仓库根 | `D:/Code/zhixianweilai/yaoming-cloud` |
| 基线 HEAD | 实现与首轮验证在 `47ad1290`；**2026-10-06 更名复核在 `b9769b2a`**（其间前移的提交为 M03-P01 / M07 / M06 / M04 / M09 后端与文档改动，与本批 5 个前端文件零交集） |
| 是否提交 | **未提交**（`git diff --cached` 为空，无暂存） |
| 是否推送 | **未推送**（本批不 add / 不 commit / 不 push，等总控按批授权） |
| 交付日期 | 2026-10-06（首轮实现 2026-10-05，本轮为 W1-02 复核并重新取证，代码零改动） |
| 关联批次 | W1-01（`/settings/benchreactor-management`，型号侧，另一页面，互不影响） |

### 1.1 本批要解决的问题

work1 此前已完成该页「列表 + 新增」的浏览器验收，**修改 / 删除预检 / 删除执行 / 409 冲突** 四类用例长期卡在同一个原因：行内操作只有按钮文案，行复选框由 VXE 自渲染，自动化工具无法稳定定位到「某一条 reactorId 的那一行」，只能靠视觉坐标点，一改版就失效。

本批只补**定位入口和只读结论镜像**，让 work5 / work9 能把这四类用例跑成可重复的脚本；请求路径、payload、守卫头、revision 逻辑一律不动。

### 1.2 交付归属登记（必须如实说明）

本批 diff 不是单一会话产出的：

| 时段 | 内容 |
| --- | --- |
| 20:29:52–20:41:02 | 另一并发会话在同一批次范围内落地主体：新建 `test-ids.ts`、`grid.ts` 行/复选框 class 钩子、`index.vue` 工具栏与行内按钮 testid、弹窗字段 testid、结论镜像、`tests/lab-labbenchreactor-guarded-write.test.ts` 定位约定钉（另生成一份未带批次名的 MD，见 §7-B7） |
| 21:41 起（总控裁决 Batch 02 归 work1，并确认对端已停写） | work1 接管：**逐条审计**（含对 VXE / antd-vue 库源码的落点核对）+ **差额修补** + **独立重跑全部验证命令** |

work1 接管的修补点（本批我这一方的改动）：

1. `index.vue`：删除确认弹窗此前**没有任何稳定定位入口**（目标 3 未完成项）→ 改为向 SDK `messageBox.confirm` 传渲染函数，在内容节点上带出 `data-testid="lab-benchreactor-confirm-delete"`，文案一字不改。
2. `index.vue`：结论镜像 `data-last-delete-outcome` 此前在「上一次删除成功 → 本次用户取消」后仍停留在 `success`，脚本会把上一条结论误读成本条 → 进入删除流程即归零为 `idle`。
3. `test-ids.ts`：`WRITE_OUTCOME` 文档口径更正为**只覆盖删除链路**（原注释写「含新增、修改」与实际接线不符）；`EDITOR_DIALOG_CLASS` 落点注释更正为 `.vxe-modal--wrapper`（原写 `.vxe-modal--box`，按库源码核对是错的）。
4. `tests/...guarded-write.test.ts`：新增 2 条**页面行为层**用例（断言确认弹窗确实收到带 testid 的渲染函数；断言镜像按本次尝试归零），两条都做过变异红项自检（见 §4.5）。

---

## 二、修改文件清单

### 2.1 本批全部改动（工作区，未提交）

| 文件 | 变更 | 说明 |
| --- | --- | --- |
| `futurefab-frontend/packages/app-smp-settings/src/views/lab-labbenchreactor/test-ids.ts` | **新增** 156 行（未跟踪） | 定位属性值生成（纯函数，无副作用） |
| `.../lab-labbenchreactor/grid.ts` | +16 / −2 | `rowClassName` + checkbox 列 `className` 钩子 |
| `.../lab-labbenchreactor/index.vue` | +61 / −10（本批四文件合计 +337/−9 中的页面部分） | 工具栏 / 行内按钮 / 页面根镜像属性；删除确认渲染函数；镜像归零 |
| `.../lab-labbenchreactor/labbenchreactor-editor.vue` | +18 / −4 | 弹窗 class、6 个字段 testid、确定 / 取消按钮 testid |
| `futurefab-frontend/tests/lab-labbenchreactor-guarded-write.test.ts` | +251 | 定位约定钉 + 2 条页面行为用例 |

合计：`git diff --stat` 对本批 4 个已跟踪文件给出 **337 insertions(+), 9 deletions(-)**，另有 `test-ids.ts` 156 行未跟踪新文件。

### 2.2 明确未改动（逐条核对，防止「可测性改动顺手改了业务」）

- `.../lab-labbenchreactor/reactor-write.ts`（白名单裁剪、预检结论映射）—— 未动
- `packages/app-smp-settings/src/shared/use-guarded-write.ts` —— 未动
- `packages/sdk-smp-api/**`（`/lab/labbenchreactor/*` 请求封装、守卫头）—— 本批未动（工作区里 `sdk-smp-api/src/benchreactor.ts` 的改动属 Batch 01，与本页无关）
- `packages/sdk-smp-common/**`（`SmpDialog` / `SmpScrollGrid` / `messageBox`）—— 未动，只在页面侧用它们已有的钩子
- 后端 Java / Mapper / XML、SQL、Nacos 配置、`docs/开发基线/**` —— 未动
- `benchreactor-management/**`（型号页）—— 本批未动
- 客户只读材料与 `docs/**/history/**` —— 未动
- 他人在途文件（`.tmp-501-audit.py`、`.tmp-json-check.py`、`.tmp-setdiff.py`）—— 未 add、未清理

---

## 三、功能改动说明

### 3.1 命名与宿主约定（脚本按此写死，勿按文案找）

统一前缀 `lab-benchreactor-`（与型号页 `settings-benchreactor` 不撞车）。业务标识（`reactorId`）经 `safeToken()` 过滤为 `[A-Za-z0-9_-]`，空值退回 `unknown` —— **定位失败表现为「找不到」，不会表现为「选中错误的行」**。

| 目标 | 属性 | 预期 DOM 宿主（已按库源码核对） |
| --- | --- | --- |
| 页面根 | `data-testid="lab-benchreactor-page"` | `PageContainer` 根元素（该组件未关 `inheritAttrs`） |
| 页面根版本镜像 | `data-management-revision="<revision>"` | 同上，取不到版本时为 `unknown`（属性仍存在，便于断言负例） |
| 页面根删除结论镜像 | `data-last-delete-outcome="idle\|success\|precheck-blocked\|revision-missing\|conflict\|failed"` | 同上 |
| 表格根 | `data-testid="labbenchreactor-grid"`（对端写的常量？见注） | `SmpScrollGrid` 把 `$attrs` 转绑到 VxeGrid；**保底锚点是 SDK 自有 class `.smp-scroll-grid`** |
| 每一行 | `class="lab-benchreactor-row lab-benchreactor-row--<reactorId>"` | VXE `<tr>`（`rowClassName` 钩子，`body.js:911`）；VXE 同时给 `<tr rowid="<reactorId>">` |
| 行复选框单元格 | `class="lab-benchreactor-checkbox-cell lab-benchreactor-checkbox-cell--<reactorId>"` | VXE `<td>`（列 `className` 钩子，`body.js:303/703`）；**真正的点击目标仍是其内 `.vxe-cell--checkbox`** |
| 行内「修改」 | `data-testid="lab-benchreactor-row-edit-<reactorId>"` | antd `<button>`（`button.js:189` 合并 attrs） |
| 行内「删除」 | `data-testid="lab-benchreactor-row-delete-<reactorId>"` | 同上 |
| 行操作区 | `data-testid="lab-benchreactor-row-actions"` + `data-reactor-id` + `data-asset-no` | 页面自有 `<div class="reactor-actions">` |
| 工具栏新增 | `data-testid="lab-benchreactor-add"` | `<button>` |
| 工具栏批量删除 | `data-testid="lab-benchreactor-batch-delete"` | `<button>`（无勾选或写入中为 `disabled`） |
| 工具栏泵的默认连接 | `data-testid="lab-benchreactor-pump-connection"` | `<button>` |
| 编辑弹窗整体 | `class="smp-dialog lab-benchreactor-editor-dialog"` | VXE `.vxe-modal--wrapper`（`modal.js:1015`；**不是** `.vxe-modal--box`） |
| 弹窗字段 | `data-testid="lab-benchreactor-field-<契约字段名>"` | `a-input` → 真实 `<input>`（`vc-input/Input.js:140` 把 attrs 并入 inputProps）；`a-select` → **外层 `.ant-select` div**（`vc-select/BaseSelect.js:583/710`） |
| 弹窗确定（保存） | `data-testid="lab-benchreactor-editor-submit"` | `<button>` |
| 弹窗取消 | `data-testid="lab-benchreactor-editor-cancel"` | `<button>` |
| 删除确认内容 | `data-testid="lab-benchreactor-confirm-delete"` | SDK 弹窗 `.smp-confirm-content` 内的页面渲染函数节点 |

> 注：工具栏与页面根属性值绑的是 `test-ids.ts` 常量，`tests/` 已钉住「模板里的常量名 ↔ test-ids 里的值」两侧一致；改任何一侧都会红。

### 3.2 为什么复选框用 class 而不是 data-testid

`SmpScrollGrid` 的复选框由 VXE 自己渲染，其单元格 vnode 只合并 `class` 与事件（`cell.js` 的 `renderCheckboxCell` 不接收列 `attrs`），页面拿不到它的 DOM，也挂不上属性。VXE 官方开放的行/列 class 钩子是唯一不改 SDK 的通路，因此：

- 行容器：`rowClassName` → `<tr class="...--row--<id>">`
- 复选框单元格：列 `className`（函数式，`getPropClass` 支持）→ `<td class="...--checkbox-cell--<id>">`
- 点击目标仍是 `<td class="...--checkbox-cell--<id>"> .vxe-cell--checkbox`

### 3.3 结论镜像的用途与边界

成功 / 冲突 / 预检阻断 / 缺版本短路这几类结论目前只体现在 antd message 上，3 秒即逝且同屏只留一条，脚本靠轮询文案断言很容易读空或读错条。镜像把这些结论以固定 token 复制到页面根属性上：

- **只写属性，不新增提示、不改文案、不参与任何请求或状态机**；
- **只覆盖列表页删除链路**（进入即归零 → 预检阻断 / 缺版本 / 成功 / 409 / 其他失败）；
- 新增与修改的结果仍只看弹窗自己的提示与弹窗是否关闭，本属性**不代表**它们（`test-ids.ts` 注释已按此更正）。

### 3.4 守卫写与业务逻辑保持不变（逐条核对）

| 约束 | 核对结果 |
| --- | --- |
| 请求路径与方法 | `checkCanDelete(reactorId)`、`delLabbenchreactor(reactorIds, writeMeta(revision))`、`updateLabbenchreactor(payload as …, meta)` 全部未动 |
| payload | `reactor-write.ts` 白名单裁剪未动；本批不新增任何字段进载荷 |
| 守卫头 | `use-guarded-write.ts` 未动；`X-Request-Id` 仍每次写现生成 |
| revision 来源 | 仍取列表外壳顶层 `managementRevision`（`pageRowsWithRevision`），未硬编码、未从无关模块借 |
| 缺 revision 短路 | 页面与弹窗都保留 `revision == null || "" → msgError + return`，且发生在发请求之前 |
| 409 处理 | `invalidateOnConflict(e)` + `writeErrorMessage(e)` 分流（`REFERENCE_EXISTS` vs 版本冲突）未动 |
| 写动作互斥 | `if (deleting.value) return;` 仍在 |
| 可见文案 | 确认提示、`确定` / `取消`、`批量删除` 等文案一字未改 |

以上每一条都在 `tests/lab-labbenchreactor-guarded-write.test.ts` 的「可测性改动不得改动请求与守卫写口径」用例里钉住。

---

## 四、已执行验证命令与结果

验证顺序按总控规定的四步执行；**全部通过后才创建本 MD**。

| # | 命令 | 结果 |
| --- | --- | --- |
| 1 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check`（`vue-tsc --noEmit --composite false`） | 通过（无输出、退出 0） |
| 2 | `pnpm run routes:check`（`tsx scripts/generate-route-paths.ts --check`） | 通过 |
| 3 | `npx vitest run tests/lab-labbenchreactor-guarded-write.test.ts` | **30 tests / 1 file 全绿**（对端 28 + work1 新增 2） |
| 4 | `npx vitest run tests/lab-labbenchreactor-guarded-write.test.ts tests/benchreactor-management.test.ts tests/benchreactor-acceptance-precheck.test.ts` | **63 tests / 3 files 全绿**（Batch 01 无回归） |
| 5 | `npx vitest run tests/lab-instance-shell.test.ts tests/lab-settings-regressions.test.ts tests/lab-management.test.ts tests/lab-management-display.test.ts tests/labgroup-management.test.ts` | 44/45 通过，**1 红为 `labgroup-management.test.ts`，非本批引入**（详见 §4.6） |
| 6 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 通过，`✓ built in 18.05s`，产物 `dist/lab-labbenchreactor-D9bBlKWC.js` 33.68 kB / gzip 8.47 kB |
| 7 | `npx prettier --check`（4 个已跟踪文件 + `test-ids.ts`） | `index.vue` / `labbenchreactor-editor.vue` / 测试文件报 warn；**已用 `git show HEAD:<path>` 落临时副本跑同一命令核对，HEAD 即不合规**，属他人在途风格。为不放大 diff 未整文件重排。`grid.ts`、`test-ids.ts` 合规 |
| 8 | `npx biome check`（同上文件集，`--max-diagnostics=300`） | 与 HEAD 逐项对比：`organizeImports 4`、`format 4`、`useLiteralKeys 1`、`noUnusedFunctionParameters 2`、`noNonNullAssertion 2`、`useIterableCallbackReturn 1` **数量完全一致**；仅 `noExplicitAny` 76 → 79（grid.ts 新增 2 个 `({ row }: any)` 回调、测试里 1 个 `as any`），与该组文件既有 76 条同规则、同级别（warn），新建的 `test-ids.ts` 自身 0 findings |
| 9 | `npx vitest run`（全量，本批 MD 定稿后补跑并核对） | **1052 passed / 25 failed，14 个文件红**；本批与 Batch 01 的三个文件在同一轮里全绿（`lab-labbenchreactor-guarded-write` 30、`benchreactor-management` 28、`benchreactor-acceptance-precheck` 5）。25 条红项逐条归因见 §4.6，**无一涉及本批 5 个文件** |
| — | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | **本批未执行**：本批未改 `sdk-smp-api` 任何类型（Batch 01 已执行过并留在盘上）；若后续批次改 SDK 类型需重跑 |

### 4.1 验证分层结论（按 AGENTS.md §13.2 口径）

- 静态检查通过 ✅
- 编译（type-check）通过 ✅
- 契约 / 单元测试通过 ✅
- SQL 在目标库执行 —— 未执行
- HTTP 联调 —— **未执行，NOT_VERIFIED**
- 浏览器验收 —— **未执行，NOT_VERIFIED**
- 现场 / 生产验收 —— 未执行

本文档所有结论止于「编译 + 契约测试」层。**§3.1 的 DOM 宿主列是靠读 VXE / antd-vue 源码得出的预期，不是浏览器实测证据**；work5 / work9 必须以 TC-01 为第一道闸。

### 4.5 红项自检（证明新用例不是空断言）

| 变异 | 预期 | 实测 |
| --- | --- | --- |
| 注释掉 `index.vue` 的 `lastDeleteOutcome.value = WRITE_OUTCOME.IDLE;` | 「结论镜像按本次尝试归零」变红 | 红（`expected 'success' to be 'idle'`） |
| 把删除确认改回裸字符串 `proxy.$modal.confirm(t(...))` | 「删除确认走带 testid 的渲染函数」变红 | 红（`expect(typeof content).toBe("function")` 失败） |

两处变异均已回退，回退后重跑 §4 第 3–4 项全绿。

### 4.7 W1-02 更名复核（2026-10-06 01:12–01:14，HEAD `b9769b2a`，代码零改动）

| 复核项 | 本轮实测 |
| --- | --- |
| 三条必跑命令（api type-check / app type-check / `routes:check`） | 退出码 `0 / 0 / 0`（本轮 W1 序列在 `b9769b2a` 同一坐标实测） |
| §4 第 3 项 `vitest tests/lab-labbenchreactor-guarded-write.test.ts` | **30 tests / 1 file 全绿**，`Duration 1.97s` |
| §4 第 4 项 三文件合跑（本批 + W1-01 两个文件） | **63 tests / 3 files 全绿**（W1-01 无回归） |
| §4 第 5 项 五文件合跑 | **44 passed / 1 failed（45）**，唯一红项仍是 `tests/labgroup-management.test.ts:204` 的 `applies the draft filters on search and freezes them as the submitted snapshot`（`expected { beginDate: '2026-01-01', …(1) } to deeply equal { groupName: 'Quality', …(4) }`）—— 属 §4.6 已登记的他人在途红，**不涉及本批任何文件** |
| §4 第 6 项 app `build` | 退出 0；产物 `dist/lab-labbenchreactor-HXQjE-Gs.js` **33.68 kB / gzip 8.47 kB**，与首轮记录的体积完全一致（文件名哈希随同包他人页面漂移） |
| 定位属性接线抽查 | `index.vue` 8 处、`labbenchreactor-editor.vue` 8 处 `data-testid`，`test-ids.ts` 仍为未跟踪新增，`grid.ts` 走 className 钩子故 0 处（符合 §3 设计） |

结论：本批在 W1 序列下**无需补代码**；§4 原表全部结论在当前 HEAD 上仍然成立。


### 4.6 背景红（全量 `npx vitest run` 的 14 文件 / 25 条，逐条归因，均未代改）

归因方法（三步，可复核）：

1. `git status --short` 在当前工作区里**只有** Batch 01（`benchreactor-management/**`、`sdk-smp-api/src/benchreactor.ts`、`sdk-language/.../smp-settings/{cn,en}.ts`、`tests/benchreactor-*.test.ts`）与 Batch 02（`lab-labbenchreactor/**`、`tests/lab-labbenchreactor-guarded-write.test.ts`）两组文件；下表 14 个红文件断言的页面**没有一个出现在工作区 diff 里**。
2. 全量日志里 `grep -i benchreactor` 只命中 4 行，且全是 `✓`（通过）行 ⇒ 25 条红项的失败文本没有一条指向本批页面。
3. 两条「计数型」红项做了定点核对（见下表 dialog-pane-padding / dict-tag 行）：把 `dialogPages` 的判定条件 `<SmpDialog` 在 `benchreactor-management/` 下逐个文件对 HEAD 计数比对，`benchreactor-editor.vue` = 1、`index.vue` = 0，**与 HEAD 完全一致**，多出的 1 个弹窗来自他人 in-flight 的 `workflow-management/workflow-editor.vue`（dict-tag 的 received 差异行同样指向该文件）。

| 红文件 | 条数 | 失败签名 | 归因 |
| --- | --- | --- | --- |
| `tests/monitor-log.test.ts` | 4 | `/dev-api/system/operlog` vs `/dev-api/monitor/operlog`、`changeSort is not a function` | 日志迁移工作，文件不在本批 diff |
| `tests/dialog-pane-padding.test.ts` | 4 | `expected 29 to be 28`、`workflow-management/index.vue` 缺 `smp-overlay-pane` | 他人 workflow 弹窗改动；本批 `<SmpDialog` 计数与 HEAD 一致（见上文第 3 步） |
| `tests/dict-tag.test.ts` | 3 | received 多出 `system-user/password-validity.vue`、`pump-speed-management/index.vue`，缺 `workflow-management/index.vue` | 他人 themed-tag 铺开进度，与本批无关 |
| `tests/workflow-management.test.ts` | 2 | 提交快照丢 `labTypeList` | workflow 页面在 HEAD 状态，非本批 |
| `tests/settings-filter-toolbar.test.ts` | 2 | `smp-notification` 工具栏负 margin / 8px 间距 | smp-notification 页面，非本批；同文件 `lab-benchreactor` 用例为 `✓` |
| `tests/config-management.test.ts` | 2 | 提交快照字段不符 | config-management，非本批 |
| `tests/venue-management.test.ts` | 1 | 缺 `common.label.sortOrder` | venue 页面，属 Batch 03 范围，本批未触碰 |
| `tests/scroll-pagination.test.ts` | 1 | `expected 10 to be 14` | SDK 滚动分页口径，非本批 |
| `tests/profile.test.ts` | 1 | 缺 `padding: 8px 10px` | profile 页面，非本批 |
| `tests/navigation.test.ts` | 1 | 顶级目录顺序（实验室A 位置） | 路由/菜单顺序，非本批；本批 `pnpm run routes:check` 通过 |
| `tests/localization.test.ts` | 1 | 缺命名 i18n key 清单（`alarm-mail-delivery`、`alarm-sms-delivery` 等） | 告警页面缺 key；清单内无 `lab.benchreactor.*`，本批未新增文案 key |
| `tests/labgroup-management.test.ts` | 1 | 页面已发平铺 `beginDate/endDate`，测试仍断言 `params.beginTime/endTime` | labgroup 页面与测试均在 HEAD 状态 ⇒ HEAD 既有红，归 M01 实验组 |
| `tests/iconfont-build.test.ts` | 1 | 注册图标 31 vs 期望 19 | 图标清单，非本批（本批未引入任何图标） |
| `tests/detection-workbench-ui.test.ts` | 1 | 作废/撤回图标名断言不匹配 | M05 工作台，非本批 |

结论：这 25 条属**共享工作区的他人 in-flight / HEAD 既有红**，本批既未修复也未回退，按 §13.1「不跨模块修改」原样保留，交总控协调。本批自身口径以 §4 第 1–6、9 行为准。


---

## 五、给 work5 的详细测试方案

### 5.0 测试前置（不满足直接记 BLOCKED_DEPLOY / BLOCKED_MENU，不得判页面缺陷）

1. **portal `:5581` 服务的是预构建 hash bundle，不吃源码 HMR**。本批改动必须重建后才可能在浏览器看到：
   - `pnpm --filter @futurefab/ui-app-smp-settings run build`（本批产物：`dist/lab-labbenchreactor-D9bBlKWC.js`）
   - 若先前批次已改 SDK：`pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` + 相应包构建
2. 后端 `futurefab-system`(9201) 需已重启并加载 `/lab/labbenchreactor/*` 全部路由（含 `check-delete`）；网关 `:9090` `/dev-api` 与菜单、权限按现网。
3. 主数据：见 §六。**缺被引用样本 → 记 BLOCKED_DATA**，禁止把「预检返回 200」当用例通过。
4. 全程开 DevTools Network（Preserve log）+ Console；每条用例留截图与 HAR。
5. 账号需具备 `lab:labbenchreactor:edit` / `:remove`；缺权限 → `v-hasPermi` 会把按钮连 testid 一起移除，属 **BLOCKED_MENU/权限**，不是定位缺陷。

### 5.1 TC-LOC-01 定位宿主核验（本批地基，必须先跑）

在页面 Console 逐条执行，记录「属性是否存在 + 宿主节点标签 + class」：

| 断言 | 期望宿主 |
| --- | --- |
| `[data-testid="lab-benchreactor-page"]` | 页面根元素存在，且带 `data-management-revision`（数字串或 `unknown`）与 `data-last-delete-outcome="idle"` |
| `document.querySelectorAll('tr.lab-benchreactor-row').length` | 等于当前可视行数 |
| 任一 `tr.lab-benchreactor-row--<reactorId>` 的 `rowid` 属性 | 等于同一 reactorId（VXE 原生锚点，互为交叉验证） |
| `td.lab-benchreactor-checkbox-cell--<reactorId>` 内含 `.vxe-cell--checkbox` | 是 |
| `[data-testid="lab-benchreactor-row-edit-<reactorId>"]` | `<button>`（`type="link"`） |
| `[data-testid="lab-benchreactor-field-assetNo"]` | **`<input>`**，可直接 fill |
| `[data-testid="lab-benchreactor-field-labId"]` | **外层 `.ant-select`**（不是 `<input>`）；要输入需再进 `.ant-select-selection-search-input` |
| `.vxe-modal--wrapper.lab-benchreactor-editor-dialog` | 打开修改弹窗后存在（注意是 wrapper 层，不是 `.vxe-modal--box`） |

**判定**：任一宿主与期望不符 → 本批判 FAIL 并回 work1（不要自行改选择器约定）；若全部因未重建 bundle 而取不到 → `BLOCKED_DEPLOY`。

### 5.2 TC-UPDATE 修改链路（原阻塞项，本批重点）

1. 记下目标行 `reactorId`（从行 `rowid` 或 `data-reactor-id` 读）。
2. 点 `[data-testid="lab-benchreactor-row-edit-<id>"]`。
3. Network 应出现：`GET /dev-api/lab/labbenchreactor/<id>`（详情）+ `GET /dev-api/lab/labbenchreactor/edit-options?labId=...`。
4. 断言弹窗存在：`.vxe-modal--wrapper.lab-benchreactor-editor-dialog`，标题为「修改实验室台式反应器」。
5. 改 `[data-testid="lab-benchreactor-field-maxCapacity"]` 为不同正整数。
6. 点 `[data-testid="lab-benchreactor-editor-submit"]`。
7. Network 断言 `PUT /dev-api/lab/labbenchreactor`：request headers 必含 `X-Request-Id`（UUID，非硬编码）与 `X-Management-Revision`（等于操作前页面根镜像值或其后的新值）；payload **只含**白名单字段（`reactorId/labId/assetNo/vesselNo/controllerNo/modelId/maxCapacity/remark`），**不得出现** `brand/category/capacityUnit/description/occupancy/status`。
8. 响应 200 → 弹窗关闭、列表 reload、页面根 `data-management-revision` 变为新值。
9. Console 无 `RequestMetaInvalidException` / `GlobalExceptionHandler` 异常栈。

### 5.3 TC-DELETE 删除执行（原阻塞项）

1. 用**未被引用**的实例行，点 `[data-testid="lab-benchreactor-row-delete-<id>"]`。
2. 断言确认弹窗：内含 `[data-testid="lab-benchreactor-confirm-delete"]`，文案仍是「确定要删除该台式反应器吗？请确认当前反应器没有被使用或预约。」
3. 在该弹窗 `.vxe-modal--footer` 内按顺序取按钮（**第一个=取消，第二个=确定**；SDK 自渲染，无 testid，见 §7-B6）。点确定。
4. Network 断言顺序：`GET .../labbenchreactor/<id>/check-delete` → `DELETE /dev-api/lab/labbenchreactor/<id>`，DELETE 必须带 `X-Request-Id` + `X-Management-Revision`。
5. 断言页面根 `data-last-delete-outcome="success"`（不依赖 3 秒即逝的 message）。
6. 列表刷新后该行消失；`data-management-revision` 已变。

### 5.4 TC-DELETE-BATCH 行复选框 + 批量删除（原阻塞项）

1. 勾选两条**未被引用**实例：点 `td.lab-benchreactor-checkbox-cell--<id> .vxe-cell--checkbox`。
2. 断言工具栏 `[data-testid="lab-benchreactor-batch-delete"]` 由 `disabled` 变为可点。
3. 点批量删除 → 确认弹窗（同 TC-DELETE 步骤 2–3）。
4. Network 断言：`check-delete` **每个 id 各一次**（两条即两次），随后**只发一次** `DELETE /dev-api/lab/labbenchreactor/<id1>,<id2>`（逗号路径），带两个守卫头。
5. 断言 `data-last-delete-outcome="success"`，两条记录都不在列表。
6. 勾「全选表头」再取消全选，确认按钮回到 `disabled`。

### 5.5 TC-PRECHECK-BLOCKED 预检 allowed=false

1. 用**已被 M07 运行/实验引用**的实例行，点行内删除并确认。
2. Network 断言：`GET .../<id>/check-delete` 返回 **HTTP 200 且 `data.allowed=false`**（这是合法阻断结果，不得当接口错误）。
3. **必须没有任何 `DELETE` 请求**（Preserve log 里核对，一条都不许有）。
4. 断言页面根 `data-last-delete-outcome="precheck-blocked"`，并出现「删除预检未通过，未执行删除」+ 映射后的原因文案（`REFERENCE_EXISTS` 走「存在受保护引用」口径，不得说成「数据已被他人修改」）。
5. 记录返回的 `reasonCodes` 原值；出现未登记原因码时页面应透出原码而不是空白。

### 5.6 TC-GUARD-NOREV 缺 revision 短路（负例）

1. 制造条件（任一）：断网/DevTools 拦截使 `GET /lab/labbenchreactor/list` 失败后刷新页面且不再成功；或在无列表数据的首屏直接触发删除。
2. 点行内删除并确认。
3. 断言：`data-last-delete-outcome="revision-missing"`；**Network 无任何 PUT/POST/DELETE 写请求**；提示含「未取到管理版本，已取消本次删除，请刷新列表后重试」。
4. 同法验弹窗：打开修改弹窗→ 让列表读取失败 → 点 `[data-testid="lab-benchreactor-editor-submit"]` → 不发 PUT，弹窗不关。

### 5.7 TC-CONFLICT 409 MANAGEMENT_CONFLICT（原阻塞项）

1. 打开修改弹窗（记下页面根 revision，例如 `R1`）。
2. 用另一个已登录会话（或 read-only SQL 核验辅助）先推进管理版本到 `R2`。
3. 回到本会话点保存 → 期望 `PUT` 带 `X-Management-Revision: R1` → 返回 409 / `MANAGEMENT_CONFLICT`。
4. 断言：提示含「刷新」「重试」口径；**弹窗不关闭**（表单内容还在）；无成功提示；页面根 `data-last-delete-outcome` 不用于本用例（新增/修改不在镜像范围），改以提示与请求结果断言。
5. 再次点保存 → 断言重试前**重取了一次版本**（多一次 `GET .../list`），`X-Management-Revision` 变成新值（不等于 `R1`），且 `X-Request-Id` 与上一次不同。
6. 后端日志核对：400/409 守卫拒绝属 WARN 级、不落日志文件；需要证据时对 `sys_management_request` 做**只读 SELECT**（见 §6.3）。

### 5.8 TC-MIRROR-RESET 结论镜像归零（work1 本批修补点）

1. 删除一条未引用实例 → `data-last-delete-outcome="success"`。
2. 再点另一条的删除 → 在确认弹窗点**取消**。
3. 断言 `data-last-delete-outcome="idle"`（若仍是 `success`，说明上一条结论冒充了这一条 → 本用例判 FAIL，是 work1 本批要修的缺陷）。
4. 同法：勾选无记录时点批量删除应直接 return，不产生任何请求。

### 5.9 TC-REG-LIST / TC-REG-CREATE 回归（此前已验收项）

- 列表筛选（实验室、资产/罐体编码关键字、修改时间单端）与滚动分页取数不变；
- 新增链路（工具栏 `[data-testid="lab-benchreactor-add"]` → 填字段 → submit）仍成功，POST 带守卫头；
- 占用状态：`IN_USE/RESERVED/IDLE/UNKNOWN` 显示正确，未知不得显示为空闲；
- 语言切到 EN 后：按钮 testid、行 class、字段 testid **不变**（脚本不得依赖 label 文案）。

### 5.10 TC-PERM 权限与入口

- 无 `lab:labbenchreactor:edit` 权限账号：`[data-testid*="row-edit"]` 应整体不在 DOM；无 `:remove`：行内删除与批量删除都不在。
- 判定为 BLOCKED_MENU / 权限缺失，不判定位缺陷。

---

## 六、测试数据建议

### 6.1 主数据清单（缺一即记 BLOCKED_DATA，不得跳过断言）

| 用途 | 数量 | 要求 |
| --- | --- | --- |
| 删除执行 | ≥1 | 未被任何业务引用，`occupancy` 空闲 |
| 批量删除 | ≥2 | 均未被引用，**属同一实验室**（便于一次勾选） |
| 预检阻断 | ≥1 | 被 `lab_run_measurement` / M07 运行或预约引用（触发 `REFERENCE_EXISTS`） |
| 409 冲突 | 1 份 + 第二会话 | 两条可修改实例，或用第二会话/只读 SQL 观察推进版本 |
| 占用展示 | 各 1 | `IN_USE` / `RESERVED` / `IDLE` / 非法或 null 值（走 UNKNOWN 分支） |
| 雪花 ID 稳定性 | ≥1 | `reactorId` 为 19 位纯数字（本批 class/testid 对纯数字原样透出，不做精度转换） |
| 数据权限 | 1 | 另一实验室的实例，用于验证非授权账号看不到 |

### 6.2 构造方式

- 新增实例走页面（`lab-benchreactor-add`），**不要直接 INSERT 业务表**（会绕开管理版本推进与审计）。
- 「被引用」样本由真实业务操作产生（M07 排程/运行绑定该反应器），不得手改外键。
- 测试后清理：删除本批新建实例，确认列表恢复原状并记录清理后的 `data-management-revision`。

### 6.3 可选只读 SQL（仅核验，不改数据）

```sql
-- 守卫写请求留痕核验（400/409 不落日志文件，只能这样取证）
SELECT request_id, result_code, error_code, create_time
FROM sys_management_request
WHERE create_time >= '<测试开始时间>'
ORDER BY create_time DESC;

-- 管理版本当前值（注意：managementRevision 是全局 SYSTEM 计数器，不是按模块隔离）
SELECT * FROM sys_management_revision;
```

现网数据源是共享远端库（仓库 `nacos-config` 内是过期副本）；SQL 只允许 SELECT。

---

## 七、已知风险与阻塞

| 编号 | 事项 | 影响 / 处置 |
| --- | --- | --- |
| B1 | 本批**未做 HTTP、未做浏览器、未执行 SQL**；§3.1 宿主列是读库源码得到的预期 | 全部浏览器结论 `NOT_VERIFIED`；TC-LOC-01 是第一道闸，宿主不符即回 work1 |
| B2 | `a-select` 的 testid 落在外层 `.ant-select`，不在 `<input>` | 脚本按 `<input>` 找 labId / modelId 会取不到；须先进 `.ant-select-selection-search-input`，属脚本适配，不改代码 |
| B3 | 复选框定位依赖 VXE 列 `className` 的函数式支持 | 已核 `body.js:303/703` + `dom.js getPropClass`；公司分支升级可能变化，届时以 `.vxe-cell--checkbox` + `<tr rowid>` 兜底 |
| B4 | `customConfig.storage=true` 会缓存列布局 | 若本地缓存导致列顺序变化，行/复选框仍靠 `--<reactorId>` class 与 `rowid` 定位，不受影响；建议测试前清一次表格自定义 |
| B5 | 结论镜像**只覆盖删除链路** | 新增 / 修改仍只看提示文案与弹窗是否关闭；若总控要求全链路镜像，需另开批次（会牵动弹窗与页面的状态传递） |
| B6 | 删除确认弹窗的确定 / 取消按钮**无 testid**（SDK `messageBox` 自渲染，不在本批可改范围） | 脚本只能在含 `lab-benchreactor-confirm-delete` 的弹窗 footer 内按顺序取（第一个取消、第二个确定）；若要 testid 需改 `sdk-smp-common/message-box.ts`，属跨模块协调 |
| B7 | 同一批次出现了两份交付文档：并发会话生成的 `M02-lab-labbenchreactor-前端交付与测试方案-20261005.md`（未带批次名、方案写给 work9）与本批指定名文档 | 两份都不是我删的范围。**请总控裁决是否废弃旧名**；work1 未删除、未改名他人文件 |
| B8 | 早前指令禁止触碰 `/lab/labbenchreactor/**`，本批由总控显式开禁 | 范围严格限定在这 4+1 个文件；`lab-labbenchreactor` 之外的实例页（pump、airpump 等）未动 |
| B9 | 已知未修的前端可疑点（本批按「不改业务语义」原则未动，登记待裁决） | 弹窗 `loadEditOptions()` 请求失败时 `modelOptions=[]`，随后提交必然被判「所选型号不可作为当前引用保存」，会把「候选读取失败」伪装成「型号不可选」。修法需引入候选加载失败态，属业务语义变更 → 待总控开批 |
| B10 | 背景红：全量套件 14 个文件 / 25 条红项（含 `labgroup-management` 筛选契约、workflow/日志/图标/i18n 等） | 非本批引入，逐条归因见 §4.6，未代改；work5 执行本批用例时**不要**以全量绿为前置条件，以 §4 第 3–4、9 行的本批文件绿为准 |
| B11 | 型号侧 `benchreactor-editor.vue` 仍提交 `iconPath`（Batch 01 登记的待裁决 1） | 与本批无关，仍待裁决 |

---

## 八、work5 测试记录区（work5 填写）

| 用例 | 执行环境（bundle / chunk） | 命令或操作 | HTTP 结果 | 关键头 / payload | 断言结果 | 判定（CONTRACT/HTTP/BROWSER/阻塞码） | 证据 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TC-LOC-01 定位宿主核验 | | | | | | | |
| TC-UPDATE 修改 | | | | | | | |
| TC-DELETE 删除执行 | | | | | | | |
| TC-DELETE-BATCH 批量删除 | | | | | | | |
| TC-PRECHECK-BLOCKED 预检阻断 | | | | | | | |
| TC-GUARD-NOREV 缺版本短路 | | | | | | | |
| TC-CONFLICT 409 | | | | | | | |
| TC-MIRROR-RESET 镜像归零 | | | | | | | |
| TC-REG-LIST / TC-REG-CREATE 回归 | | | | | | | |
| TC-PERM 权限与入口 | | | | | | | |

补充记录：

- Console 异常（`RequestMetaInvalidException` / `GlobalExceptionHandler` / 业务异常）：
- 未预检就发出 DELETE 的观察：有 / 无（若有必须贴 Network 截图）
- 测试数据是否清理：是 / 否（清理后 revision：______）
- 其他会话 / 其他页面的并发干扰：

---

## 九、最终结论区（由总控 / work5 / work9 填写，work1 不做最终结论）

| 范围 | 结论 |
| --- | --- |
| 本批静态检查 + 编译 + 契约测试 | **通过**（§4，work1 于 HEAD `47ad1290` 独立重跑；63 tests 全绿） |
| `data-testid` / class 是否真的在浏览器 DOM 生效 | `NOT_VERIFIED`（待 TC-LOC-01） |
| 修改 / 删除 / 批量删除 / 预检阻断 / 缺版本 / 409 浏览器验收 | `NOT_VERIFIED`（本批只是让它们**变得可测**，本身未测） |
| 数据库核验 | `NOT_VERIFIED`（未执行 SQL） |
| HTTP 联调 | `NOT_VERIFIED`（未执行） |
| 本批是否可判定页面完成 | **不可**；须 work5 按 §五 逐项回证据、work9 出浏览器结论 |
| 待总控裁决 | B5（镜像是否覆盖新增/修改）、B6（确认按钮 testid 是否开 SDK 批次）、B7（旧名 MD 是否废弃）、B9（候选加载失败被伪装成型号不可选） |
| 提交状态 | 未 add / 未 commit / 未 push；等总控按批授权 |
