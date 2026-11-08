# M05 检测结果/检测记录 —— W5-01 状态展示与删除/错误提示 前端交付与测试方案

- **批次**：W5-01
- **模块**：M05（检测与数据签批）
- **范围**：检测项目 / 检测记录 / 检测结果页面的状态展示、删除与错误提示
- **执行**：work5（前端）
- **日期**：2026-10-06
- **验证层级**：源码 type-check + vitest（**HTTP / 浏览器 NOT_VERIFIED**，见「验证边界」）

---

## 1. 页面定位

M05 的页面**不在 `app-smp-settings`，而在 `app-smp-data`**（`@futurefab/ui-app-smp-data`）。任务书里给的 type-check 命令只列了 `ui-sdk-smp-api` 与 `ui-app-smp-settings`，本批额外把 `ui-app-smp-data` 也纳入必跑项——否则本批改动等于没做类型检查。

| 页面 | 路径 | 本批是否改 | 说明 |
|---|---|---|---|
| 检测记录（UI02） | `packages/app-smp-data/src/views/detection-record/index.vue` | ✅ | 主页面，状态展示核心 |
| 检测结果 | `packages/app-smp-data/src/views/detect-detresult/index.vue` | ✅ | 状态列 + 删除资格只读提示 |
| 检测结果详情抽屉 | `packages/app-smp-data/src/views/detect-detresult/view.vue` | ✅ | 状态/告警/签名 + 加载失败提示 |
| 检测项目（检项配置） | `packages/app-smp-settings/src/views/detectoritem-management/*` | ❌ 不改 | 删除与错误提示**已完整**（见 §4.1） |
| 检测工作台 | `packages/app-smp-data/src/views/detection-workbench/index.vue` | ❌ 不改 | 无删除入口，状态已走 `status-maps.ts`（见 §4.2） |
| 签批台 | `packages/app-smp-data/src/views/sign-workbench/*` | ❌ 不改 | 同上 |

---

## 2. 契约依据（全部为 M05 现行权威文件，未采信 history）

| 事实 | 来源 |
|---|---|
| `result_status` 12 值：`idle/stored/pending/testing/tested/uploaded/signed/reviewed/voided/timeout/exception/cancelled` | `M05完整目标字段字典.md:128` |
| `result_completeness`：`NONE/PARTIAL/COMPLETE/UNVERIFIED` | 同上 `:147` |
| `device_completion`：`NOT_FINISHED/FINISHED/UNKNOWN` | 同上 `:148` |
| `collection_state`：`UNVERIFIED/OPEN/RECONCILING/CLOSED/CLOSED_EXCEPTION` | 同上 `:149` |
| `item_outcome`：`VALUE/ERROR/NO_MEASUREMENT/UNKNOWN`，**历史值不自动核准** | 同上 `:184` |
| **"没有值不能显示 0，作废只改变有效性显示，原值在详情/日志中保留"** | `检测记录与结果操作设计.md` §1（`:21`） |
| **"前端不要把一个 resultStatus 字符串同时用作这些判断的全部依据"** | `05模块《详细设计.md》:363` |
| 右侧结果删除：**pending/testing + 二次确认**，逻辑隐藏 `del_flag=2`，非取消命令 | `检测记录与结果操作设计.md` §3/§5（`:41`、`:58`） |
| 通用 detresult/detresultitem/sample 新增/编辑/删除入口不再授予普通业务页面，**旧客户端缺版本拒绝而非降级** | 同上 `:95` |
| PARTIAL 必须显式显示，**不能变成 COMPLETE** | 同上 `:44` + 用例 M05-REC05（`:107`） |

---

## 3. 本批改动

### 3.1 新增文件（3）

| 文件 | 作用 |
|---|---|
| `packages/app-smp-data/src/shared/m05-result-status.ts` | 页内纯逻辑：五族状态词典 + 三态布尔 + 删除资格 + allowedActions + legacy 写拒绝识别 |
| `packages/app-smp-data/src/shared/m05-test-ids.ts` | 定位属性（前缀 `m05-`） |
| `tests/m05-result-status.test.ts` | 23 用例 |

**为什么抽独立 .ts**：`.vue` 里的模板表达式与组件内常量只有跑起来才执行得到，而"未知态不得显示成正常""没有值不能显示 0""不可删必须说清原因"恰恰是最容易被改坏、又最难在浏览器里复现的部分。

### 3.2 修改文件（4）

`detection-record/index.vue`、`detect-detresult/index.vue`、`detect-detresult/view.vue`、`tests/detection-record-scroll.test.ts`。

### 3.3 修掉的既有缺陷（7 项，均为读口展示层，不涉及写入）

| # | 缺陷 | 位置 | 后果 |
|---|---|---|---|
| 1 | 结果状态用 `dict-tag`，字典未登记时**英文编码原样透出** | detresult/index.vue `cell3` | 页面出现 `archived_v2` 这类裸值，且看起来像已知状态 |
| 2 | 结果状态 `label()` 兜底 `String(value)`，同样透出英文 | detection-record `label()` | 同上 |
| 3 | `resultCompleteness`/`deviceCompletion`/`collectionState` **直接渲染英文原值** | detection-record 详情区 | 详情页出现 `PARTIAL` / `UNVERIFIED` / `NOT_FINISHED` |
| 4 | `isAlarm`/`isVoided` formatter `cellValue===true \|\| ==="1" ? 是 : 否`，**null 落进"否"** | detection-record `itemColumns` | **凭空断言"没有告警/未作废"**，直接违反「没有值不能显示 0」 |
| 5 | 签名状态 `signBy && signTime ? "已签名" : "未签名"` | detresult/view.vue | 只有 `signBy`、缺 `signTime` 时**把已签名说成未签名** |
| 6 | 是否告警 `{{ info.isAlarm }}` 原样渲染 | detresult/view.vue | 界面出现 `true`/`1` |
| 7 | 详情抽屉加载失败只 `console.error`，**页面无任何提示** | detresult/view.vue `open()` | 用户看到一片空白抽屉，以为"这条记录没数据" |

补充：`open()` 另补了空壳检测——后端返回 `{}` 时显式报「未取到检测结果详情」，不再让"没有数据"看起来像正常。

### 3.4 新增的只读提示（3）

| 提示 | 位置 | 为什么需要 |
|---|---|---|
| 证据质量 `UNVERIFIED` | 检测记录详情区 | 原先只有一行 descriptions-item，视觉上与普通字段无差别 |
| **可用受控动作为空** | 检测记录详情区 | 后端 `allowedActions` **恒为空列表**（`M05WiredRecordReadContractTest` 冻结现状：动作链未经新契约核验）。前端必须说清"去工作台/签名台"，**不得回退成按钮默认可点** |
| 删除资格 | 检测记录详情区 + 检测结果页工具栏 | 见 §5 |

---

## 4. 明确不改的部分（附理由，避免被当成漏做）

### 4.1 检测项目页（`detectoritem-management`）

删除与错误提示**已完整**，无需改动：
- `Modal.confirm` 二次确认，且按单选/批量分别给文案（`:169-190`）
- 删除期间 `deleteDialog.update({ okButtonProps: { loading } })` 置 loading（`:196-217`）
- 失败走 `showError(writeErrorMessage(e), false)`，`writeErrorMessage` 对 409 会标脏并给刷新/重试口径
- `onScopeDispose` 里 `deleteDialog?.destroy()`（`:243`），无弹窗泄漏

**该页也没有状态列**——检项配置本身无状态字段（`grid.ts` 全部列为 `detectClass`/`itemCnName`/`itemEnName`/`itemCode`/`unit`/`groupName` 等静态属性）。故"检测项目页状态展示"一项**无对应契约字段，非遗漏**。

### 4.2 检测工作台 / 签批台

状态展示已走 `workbench/status-maps.ts`（含中文别名归一），且有 `canVoid`/`isSlotClearable` 等动作可用性判定，**不重复造第二套词典**。两页均**无删除按钮**（grep 确认），符合契约 §5「右侧删除入口在 UI03」。

### 4.3 不渲染删除按钮（本批最重要的克制）

契约要求删除"pending/testing + 二次确认 + 预览签发五分钟一次性 `confirmationToken`"，但后端：
- `DELETE /detect/detresult/{resultId}`（M05-027）→ `DetResultApplicationServiceImpl:23` **显式 `throw new SkeletonNotImplementedException("M05-027")`**
- `POST /detect/workbench/results/preview-delete`（M05-028）→ `DetWorkbenchController:447` 注释明写**应用服务显式 501**
- SDK **未暴露**这两个接口（grep `previewResultDelete` / `results/preview-delete` 零命中）

因此本批**只给只读资格说明，不渲染可点击删除按钮**。理由：渲染一个必然 501 的删除按钮，等于给出"点了就能删"的错误暗示；且 `describeDeleteEligibility()` 判定为"可删"也不代表动作可用——真正的可删还要过预览令牌。

---

## 5. 删除口径的前后端事实对照

| 事实 | 状态 |
|---|---|
| `ResultDeleteCommand` 契约字段（`resultId`/`expectedObjectVersion`/`confirmationToken`/`requestId`/`managementRevision`） | ✅ 已定义 |
| M05-027 应用服务实现 | ❌ 显式 501 |
| M05-028 预览令牌签发 | ❌ 显式 501 |
| SDK 侧删除/预览接口 | ❌ 未暴露 |
| 前端删除按钮 | ❌ 不渲染（本批刻意） |
| 前端只读资格提示 | ✅ 本批新增 |

**结论**：本批交付的是**契约一致的前端只读层**。后端补齐 M05-027/028 后，前端只需接上令牌流程即可，无需推翻现有展示。

---

## 6. 验证结果

### 6.1 编译/检查（5/5 全绿）

| 命令 | 结果 |
|---|---|
| `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | ✅ |
| `pnpm --filter @futurefab/ui-app-smp-data run type-check`（**本批新增，因页面在此包**） | ✅ |
| `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | ✅ |
| `pnpm run routes:check` | ✅ |
| `npx prettier --check`（7 个本批文件） | ✅ |

未改 SDK 类型输出，故本批**不需要** `build-dts`。

### 6.2 单测

| 套件 | 结果 |
|---|---|
| `tests/m05-result-status.test.ts`（新增） | ✅ **23/23** |
| `tests/detection-record-scroll.test.ts`（改） | ✅ **19/19** |
| `tests/detection-record-api.test.ts` | ✅ |
| `tests/m05-options.test.ts` | ✅ |
| `tests/legacy-detection.test.ts` | ✅ |

### 6.3 改测试时抓到的自身问题（2 项，已修）

1. **`detection-record-scroll.test.ts` 一度 10 红** —— 该套件用 `compileScript` + 自建 `require` 桩来执行 SFC，新增的 `@/shared/*` import 未注册导致 `Unexpected import`。已在 harness 注册**真实**模块（而非新桩），顺带让"未知状态不得显示成已知语义"也受该套件约束。
2. **一处断言写错方法** —— 曾对被桩成恒等函数的 `t()` 断言文案。已改为对真实词典实现断言，并在用例里注明原因，避免后人再踩。

### 6.4 既有基线红（非本批引入，未代改）

`tests/detection-workbench-ui.test.ts` 的 `uses the requested edit, void and withdraw icons` 1 红：期望 `key: "void"` 后跟 `icon: "cancellation"`，实际未匹配。**该套件所测的 `detection-workbench/index.vue`、`ui-icons.ts` 与本批零改动**（`git status` 已核），属既有基线红。

另：全量前端基线为 **14 文件 / 26 用例失败**（见项目记忆），本批未扩大该基线。

---

## 7. 验证边界（请勿越界解读）

- 本批为**源码级 + vitest** 验证，**未跑 `vite build`、未起服务、未做 HTTP/浏览器联调**。
- 页面实际渲染效果（标签配色、抽屉错误横幅、长文案换行）**未经浏览器确认**。
- `t(key, defaultMessage)` 的真实回落行为**未经运行时确认**（单测里 `t` 被桩成恒等函数），文案断言已改为对词典实现断言以规避该盲区。

---

## 8. 需要 work9 人工验收的重点（4 条）

1. **先构建再看**：本批未跑 `vite build`，需确认产物含 `m05-result-status` 且 `@/shared/*` 别名在打包后能解析。
2. **状态未登记时的显示**：用 DevTools 把某行 `resultStatus` 改成 `archived_v2`、把 `resultCompleteness` 清空，确认列表显示「未知状态（原值：archived_v2）」、详情显示「未知完整性」而**不是**英文原值或空白。
3. **三态布尔必须肉眼确认**：把某条结果的 `isVoided` 置 `null`，确认结果项表格显示「未知」而**不是「有效」**——这是本批修的头号契约违背。
4. **签名状态**：构造只有 `signBy`、无 `signTime` 的响应，确认详情显示「签名状态未知」而**不是「未签名」**。

---

## 9. 需总控裁决（1 项）

**`allowedActions` 恒为空列表**（后端 `M05WiredRecordReadContractTest` 冻结现状，明文写"任何人把它改成看起来可用的固定动作组都属伪造 Completion"）。

本批前端已按"空即不可用、引导去工作台/签名台"实现只读提示。请裁决：是保持现状直到动作链接管，还是需要另开任务补 `allowedActions` 的后端投影。**前端不自行推断动作可用性**，故此项不阻塞本批交付。

---

## 10. git 状态（本批文件，未 add / 未 commit / 未 push）

```
 M futurefab-frontend/packages/app-smp-data/src/views/detect-detresult/index.vue
 M futurefab-frontend/packages/app-smp-data/src/views/detect-detresult/view.vue
 M futurefab-frontend/packages/app-smp-data/src/views/detection-record/index.vue
 M futurefab-frontend/tests/detection-record-scroll.test.ts
?? futurefab-frontend/packages/app-smp-data/src/shared/          (m05-result-status.ts, m05-test-ids.ts)
?? futurefab-frontend/tests/m05-result-status.test.ts
```

**禁改模块核查**：本批**零触碰** M01 / M02 / M03 / M04 页面。
工作树中另有 `culture-management/{index,culture-editor}.vue` 与 `m03-culture-error.ts`、`m03-parameter-entry.ts` 的改动 —— 经核为 **work1 的在途 M03 批次**（文件名前缀为 `m03-`，非本批产物），**本批未参与、未代改**。