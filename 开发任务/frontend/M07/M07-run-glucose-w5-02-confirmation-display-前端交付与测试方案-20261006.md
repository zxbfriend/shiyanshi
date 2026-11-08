# M07 培养运行/残糖确认 —— W5-02 COUNTDOWN/CONFIRMED/取消/冲突提示 前端交付与测试方案

- **批次**：W5-02
- **模块**：M07（补液运行与任务执行）
- **范围**：残糖/乳酸确认的状态展示、倒计时、取消资格与冲突提示
- **执行**：work5（前端）
- **日期**：2026-10-06
- **验证层级**：源码 type-check + vitest（**HTTP / 浏览器 NOT_VERIFIED**）

---

## 1. 最重要的盘点结论：M07 前端页面**不存在**

任务书写的是"培养运行/残糖确认页面"，但**该页面在前端仓库里没有**：

| 检查项 | 结果 |
|---|---|
| `grep -rn '"/run/' packages/*/src` | **零命中** —— 没有任何前端代码消费 M07 接口 |
| `app-smp-lab/src/views/` | 只有 `lab-overview`、`culture-dashboard` 两个页面 |
| `app-smp-lab/src/router/index.ts` | 只有 `:labId/lab-overview`、`:labId/culture-dashboard` |
| SDK 是否有 run 模块 | 无（`modules/` 下只有 alarm/detect/device/lab/monitor/resource/sdms/smp/subsystem/system） |
| `app-smp-settings` 是否有运行/任务页 | 无（只有 `feeding-template-management`，那是 M04 工艺模板，不是 M07 运行） |

**后端则完全接线**（已核实，勿再猜）：

| 端点 | 状态 |
|---|---|
| `POST /run/manual-results`（M07-018 / API18） | ✅ 已接线 `@ManagementGuardedWrite` + `run:glucose:add` |
| `POST /run/confirmations`（M07-019 / API19） | ✅ 已接线 + `run:glucose:confirm` |
| `POST /run/confirmations/{id}/cancel`（M07-020 / API20） | ✅ 已接线（**且本人**由应用服务核验） |
| `GET /run/confirmations/{id}`（M07-021 / API21） | ✅ 已接线只读，`run:glucose:query` |
| `GET /run/cultures/{id}/glucose-candidates`（API17） | ✅ Controller 存在 |
| `GET /run/cultures/{id}/glucose-history`（API30） | ✅ Controller 存在 |
| `RunMeasurementApplicationApplicationServiceImpl` | ✅ **真实实现**（非 501 骨架），含上海业务日时区、60s deadline、每日唯一守卫 |

**因此本批的交付形态是「契约一致的能力层」，不是「改一个已有页面」**：
1. 补齐 SDK 契约绑定（此前完全缺失，导致页面即使建好也无 API 可调）
2. 补齐页内纯逻辑 + 定位属性 + 37 条单测，页面一旦落地即可直接接入
3. **不新建大型页面**——理由见 §6

---

## 2. 契约依据（全部为 M07 现行权威文件，未采信 history）

| 事实 | 来源 |
|---|---|
| `state` = `COUNTDOWN/CONFIRMED/CANCELLED/INVALIDATED` | `审阅收尾完整字段字典.md:145` |
| `active_slot` 生成列对 COUNTDOWN/CONFIRMED 占位 —— **本日每类最多一个倒计时或已确认** | 同上 `:153` |
| `deadline_at`：60 秒**服务器**截止（UTC） | 同上 `:149` |
| `analyte_kind` = `GLUCOSE/LACTATE`；`source_kind` = `M05/MANUAL` | 同上 `:139`、`:141` |
| "deadline=服务器时刻+60s……刷新、换浏览器、关闭弹窗**不重置**" | `计量确认与补液计算契约.md:25` |
| "取消须**原确认人**且 now<deadline……now≥deadline 时由同一行锁按服务器时刻尝试完成，**边界不受客户端倒计时控制**" | 同上 `:25` |
| "完成前复核……任一变化置 INVALIDATED 并说明，需要重选，不能从新结果偷换值" | 同上 `:25` |
| "跨午夜未完成的 COUNTDOWN 失效，不拿昨天结果确认今天" | 同上 `:25` |
| "同日有效已确认值不可再次确认/编辑/撤回，历史原样保留" | 同上 `:27` |
| "对 GLUCOSE_LACTATE 必须**两类同日都完成确认**后才能提供完整自动计算输入" | 同上 `:23` |
| `numericGl` **缺值不用 0 代替** | 同上 §1 |
| 409 三码（STATE/VERSION/REQUEST_CONFLICT）统一要求**不自动重试；纠正输入或刷新确认** | `错误码全集.md:29`、`:31`、`:33` |

---

## 3. 本批改动

### 3.1 新增（4）

| 文件 | 作用 |
|---|---|
| `packages/sdk-smp-api/src/modules/run/measurement.ts` | **SDK 契约绑定**（此前完全缺失）：API17/18/19/20/21/30 + `ConfirmationView` / `ConfirmationCreateCommand` / `ConfirmationSourceSnapshot` / `GlucoseCandidate` 等类型 |
| `packages/app-smp-lab/src/shared/m07-confirmation.ts` | 页内纯逻辑：四态词典、指标类、采样质量、换算值三态、倒计时、取消资格、双指标就绪、409 冲突口径 |
| `packages/app-smp-lab/src/shared/m07-test-ids.ts` | 定位属性（前缀 `m07-`） |
| `tests/m07-confirmation.test.ts` | 37 用例 |

### 3.2 修改（1）

`packages/sdk-smp-api/src/modules/index.ts` —— 追加 `export * as runMeasurementApi from "./run/measurement"`。

### 3.3 SDK 绑定的关键设计决策（3 项，均有契约依据）

**① 倒计时只读服务端 `remainingSeconds`，不用本地时钟推算**
契约明写"边界不受客户端倒计时控制"。若服务端未返回 `remainingSeconds`（如 `undefined`/`"abc"`），本批实现**显示"正在获取服务器剩余时间…"而非用 `deadline - Date.now()` 算一个数** —— 后者会让页面显示服务端并未承诺的数字，且刷新后跳变。

**② `numericGl` / `valueGl` 缺值与真实的 0 严格区分**
`presentGlucoseValue(0)` → `"0 g/L"`，`presentGlucoseValue(null)` → `"未取到值"`。两者 `missing` 分别为 `false`/`true`。契约 §1 只说"缺值不用 0 代替"，但反过来"把 0 当缺值"同样是错的——0 g/L 是合法读数。

**③ `glucose:add` 与 `glucose:confirm` 是两个权限**
手工候选登记（API18）要 `run:glucose:add`，确认（API19/20）要 `run:glucose:confirm`。有确认权**不代表**能手工登记，页面不能只判一个权限就全放行。

---

## 4. 单测覆盖的关键用例（37 条，节选）

| 组 | 覆盖点 |
|---|---|
| 状态词典 | 四值全覆盖；COUNTDOWN≠CONFIRMED（tone 与 key 都不同）；未命中值不冒充已知；缺值显式为未知 |
| 指标类 | GLUCOSE=残糖、LACTATE=乳酸；`LACTIC`（易混淆拼写）判为未知 |
| 换算值 | 缺值不显示 0；**真实 0 与缺值严格区分**；`"3.4567"` 不四舍五入成 `3.46`；`"N/A"` 不被当数字打印 |
| 倒计时 | 读服务端剩余秒数；**服务端缺值时不本地推算**；`0`/负数标记 elapsed 但**不改写 state**；四终态各有独立解释 |
| 取消资格 | 原确认人可取消；**他人不可**；数字 ID 与字符串 ID 也能匹配；CONFIRMED/CANCELLED/INVALIDATED 均不可取消；过截止不可取消；**actor 缺失时失败关闭** |
| 双指标 | 须两类同日 CONFIRMED；COUNTDOWN 不算；INVALIDATED 不算（槽位可重选）；**跨日确认不算今天**；两类全空时 missing 顺序稳定 |
| 409 冲突 | 四码全覆盖且 `retryable` 全为 `false`；说清"刷新什么"；**优先透出后端点名对象的消息**；未知错误安全兜底 |

---

## 5. 验证结果

### 5.1 编译/检查（6/6 全绿）

| 命令 | 结果 |
|---|---|
| `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | ✅ |
| **`pnpm --filter @futurefab/ui-sdk-smp-api run build-dts`** | ✅ **本批必须**：改了 SDK 导出，未先重建 dts 会让下游 app 误报 |
| `pnpm --filter @futurefab/ui-app-smp-data run type-check` | ✅ |
| **`pnpm --filter @futurefab/ui-app-smp-lab run type-check`** | ✅ **本批新增**：M07 逻辑落在 app-smp-lab |
| `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | ✅ |
| `pnpm run routes:check` | ✅ |
| `npx prettier --check`（5 个本批文件） | ✅ |

### 5.2 单测

| 套件 | 结果 |
|---|---|
| `tests/m07-confirmation.test.ts`（新增） | ✅ **37/37** |
| W5-01 + W5-02 合并回归（5 个套件） | ✅ **82/82** |

---

## 6. 明确不新建页面的理由

任务书允许范围内本可新建残糖确认页，但**本批刻意不建**，理由：

1. **M07 页面归属未裁决**。契约《培养运行操作页与独立入口》把页面放在"培养运行操作页"这一个综合页里，该页同时承载残糖/乳酸、重量取测、培养告警、监控声光、执行曲线等 M07 + M09 + M03 的联合内容（`:19-46`）。**单独造一个残糖确认页会与该设计冲突**，且很可能与 work1/其他 work 的 M07 页面批次撞车。
2. **依赖的前置上下文未就绪**。确认需要 `cultureId` + `expectedRuntimeVersion` + 完整运行上下文，这些来自 M03 培养运行变更接口与 M02 设备上下文；缺了它们页面只能做成假数据演示。
3. **超出资深前端批次的合理边界**。任务书对 W5-02 的措辞是"状态展示、取消/冲突提示"，属展示层；能力层（本批）已备齐，页面落地是独立任务。

**如需本批就出页面，请先裁决页面归属与路由**，再单独开工。

---

## 7. 验证边界（请勿越界解读）

- 本批为**源码级 + vitest** 验证，**未跑 `vite build`、未起服务、未做 HTTP/浏览器联调**。
- 因**无页面消费**，SDK 绑定的 6 个端点**未经任何真实请求验证**——类型与路径来自契约与后端 Controller 源码，**未经运行时确认**。
- 倒计时**未在浏览器验证过真实跳动**；单测只锁住了"读服务端值、不本地推算、不改写状态"这三条口径。
- `build-dts` 已跑，故 SDK 类型产物是最新的；但 `dist-types` 是 gitignore 产物，**未提交**。

---

## 8. 需要 work9 / 后续页面批次关注（4 条）

1. **建页面前先跑 `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts`**，否则 app 侧会误报 `runMeasurementApi` 不存在。
2. **倒计时必须轮询 API21**，不能只在本地 `setInterval` 减秒 —— 服务端才是权威。
3. **`elapsed=true` 只用于提示用户刷新**，绝不可用它把 `state` 从 COUNTDOWN 改写成 CONFIRMED（契约：边界不受客户端倒计时控制）。
4. **跨午夜场景要专门验**：把 `deadline` 改成一个已过去的跨日时刻，确认页面提示 CROSS_MIDNIGHT_HINT 而不是把昨天的值当今天确认。

---

## 9. 需总控裁决（2 项）

1. **M07 前端页面归属未定**（见 §6）：`培养运行操作页` 是 M07 单独一个综合页，还是拆到各 work？现有 work4/work9 等是否已有在途 M07 页面批次？**建议先裁决归属再开工，避免撞车。**
2. **`feeding-template-management`（app-smp-settings）的模块归属**：该页含 `GLUCOSE`/`GLUCOSE_LACTATE` 计算模式选择（`feeding-template-editor.vue:1281-1282`），但它是 **M04 工艺方案模板**，不是 M07 运行。本批**未触碰**该页；若总控认为它属 M07 范围，请另行派单。

---

## 10. git 状态（本批文件，未 add / 未 commit / 未 push）

```
 M futurefab-frontend/packages/sdk-smp-api/src/modules/index.ts
?? futurefab-frontend/packages/sdk-smp-api/src/modules/run/         (measurement.ts)
?? futurefab-frontend/packages/app-smp-lab/src/shared/             (m07-confirmation.ts, m07-test-ids.ts)
?? futurefab-frontend/tests/m07-confirmation.test.ts
```

**禁改模块核查**：本批**零触碰** M01 / M02 / M03 / M04 页面。
工作树中 `culture-management/*` 与 `m03-*.ts` 的改动仍为 **work1 的在途 M03 批次**，本批未参与、未代改。