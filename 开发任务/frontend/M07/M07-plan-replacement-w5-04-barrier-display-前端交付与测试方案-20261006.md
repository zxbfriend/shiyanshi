# M07 方案替换屏障 —— W5-04 preparePlanReplacement 屏障状态只读提示 前端交付与测试方案

- **批次**：W5-04
- **模块**：M07（补液运行与任务执行），消费方为 M03-P02
- **范围**：方案替换屏障状态的只读展示口径
- **执行**：work5（前端）
- **日期**：2026-10-06
- **验证层级**：源码 type-check + vitest（**HTTP / 浏览器 NOT_VERIFIED**）

---

## 1. 最重要的盘点结论：屏障**没有任何 HTTP 读口**

任务书要求做"preparePlanReplacement 屏障状态只读提示"，但该屏障**在浏览器侧完全不可见**。已逐层核实：

| 检查项 | 结果 |
|---|---|
| `grep -rn "preparePlanReplacement\|planReplacement" packages/*/src`（前端） | **零命中** —— 无任何前端消费 |
| `grep -rn "plan-replacement\|planReplacement" --include=*Controller.java` | **零命中** —— **无 Controller 暴露** |
| 后端调用链 | `PlanReplacementBarrierProvider`（`service/impl/port/m07/`）实现 `PlanReplacementPort` |
| 调用时机 | **M03-P02 `applyParameterDecision` 的 APPLY 分支**，"同库 preparePlanReplacement 屏障" |

也就是说：**它是 M03 → M07 的同库内部 Port，调用发生在 M03 审批生效的事务内部**，不是浏览器可调用的接口。前端拿不到独立的屏障状态。

**因此本批交付的是「契约一致的前端只读投影 + 无读口提示」**，而不是一个能显示实时屏障的页面。

---

## 2. 契约依据（以**后端源码**为准，比文档更权威）

任务书与设计文档描述较粗，实际枚举以 Java 源码冻结：

| 事实 | 来源 |
|---|---|
| `PlanReplacementState` = **`READY` / `BLOCKED` / `CONFLICT` / `UNAVAILABLE`** | `service/port/m07/model/PlanReplacementState.java` |
| READY：安全前置满足，屏障可建立，允许 M03 继续切换指针 | 同上 |
| BLOCKED：存在执行中/暂停/结果未知/未结算任务，**旧方案继续有效** | 同上 |
| CONFLICT：期望版本/快照/包摘要不符，**不建立屏障**，给出当前版本 | 同上 |
| UNAVAILABLE：能力未接入；`resourcesVerified=false`「**表示未核验，不伪装已核验**」 | 同上 + `PlanReplacementReceipt.java` |
| 六个原因码 | `service/support/m07/PlanReplacementBarrierApplicationServiceImpl.java:75-90` |
| `barrierVersion` / `currentVersion` / `resourcesVerified` **可空**，其余列表字段非 null | `PlanReplacementReceipt.java` |
| 入参 9 个必填标识 + hash64 校验，不合即 `INPUT_INVALID` 失败关闭 | `PlanReplacementBarrierProvider.validate` |
| **"绝不把审批通过当作可立即替换"** | `03-项目与培养管理/培养参数快照与审批生效收尾契约.md` §3 |

六个原因码（原文常量）：

```
OBJECT_VERSION_CONFLICT
BARRIER_ALREADY_REPLACING
TASK_IN_FLIGHT_BLOCKS_REPLACEMENT
RUNTIME_NOT_INITIALIZED
BARRIER_EVIDENCE_UNREADABLE
BARRIER_CAS_MISS
```

---

## 3. 本批改动

### 3.1 新增（3）

| 文件 | 作用 |
|---|---|
| `packages/app-smp-lab/src/shared/m07-plan-barrier.ts` | 只读投影：四态词典 + 六原因码 + `projectBarrier()` + `isReplacementAllowed()` + 无读口提示 |
| `packages/app-smp-lab/src/shared/m07-test-ids.ts`（追加） | `PLAN_BARRIER_HINT_TEST_ID` / `PLAN_BARRIER_STATE_TEST_ID` |
| `tests/m07-plan-barrier.test.ts` | 22 用例 |

### 3.2 修改页面

**无。** 理由见 §6。

---

## 4. 三个关键设计决策

### ① `UNAVAILABLE` 绝不显示成"就绪"

契约明写 UNAVAILABLE 时 `resourcesVerified=false`「表示未核验，不伪装已核验」。本模块把 UNAVAILABLE 独立成「屏障能力未接入，未核验」（中性档），与 READY 的绿色「可替换」在 tone、key、文案三处全部分开，并有单测锁住。

### ② `resourcesVerified` 保持**三态**而非布尔

契约里它可空。所以本模块用 `boolean | null`：
- `null` = 后端未给出 → **不得当成已核验**
- `false` = 明确未核验（UNAVAILABLE 时的取值）
- `true` = 已核验

若压成布尔，`null` 会被 `=== true` 判成"未核验"，但若有人写成 `!!raw.resourcesVerified` 就会变成"已核验"——**这正是契约要防的伪造**。

### ③ `isReplacementAllowed()` 只认 `READY && resourcesVerified === true`

其余一律 `false`。契约要求"消费方（M03）不得据其它旁路快照自行推断可替换"，所以**不得用"不是 BLOCKED"推导"可以替换"**——单测专门断言了 `READY` 但 `resourcesVerified` 为 `null`/`false` 时必须拒绝。

---

## 5. 验证结果

### 5.1 编译/检查（4/4 全绿，均已取到明确 exit code）

| 命令 | exit | 结果 |
|---|---|---|
| `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | **0** | ✅ |
| `pnpm --filter @futurefab/ui-app-smp-lab run type-check` | **0** | ✅ |
| `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | **0** | ✅ |
| `pnpm run routes:check` | **0** | ✅ |
| `npx prettier --check`（3 个本批文件） | — | ✅ |

本批未改 SDK，故**不需要** `build-dts`。

### 5.2 单测（59/59 绿）

| 套件 | 结果 |
|---|---|
| `tests/m07-plan-barrier.test.ts`（新增） | ✅ **22/22** |
| `tests/m07-confirmation.test.ts`（W5-02 回归） | ✅ **37/37** |

单测覆盖的关键断言：

- 四态全覆盖；**`UNAVAILABLE` 与 `READY` 的 key/tone/文案全不相同**
- BLOCKED 摘要必须含「旧方案继续有效」；CONFLICT 有 `currentVersion` 时须回显、无则**不得出现 "null"**
- 六个原因码全覆盖；**闭集外的码不编造解释**，保留原值并提示核对后端版本
- 缺省的 4 个列表字段一律 `[]`，**永不为 null**
- `resourcesVerified` 三态；`projectBarrier(null)` 不抛异常
- `isReplacementAllowed`：READY+verified 才放行；READY+未核验、四种非 READY、null/undefined 全部拒绝

---

## 6. 明确不改页面的理由

1. **无读口**（§1）——页面拿不到屏障状态，任何"屏障状态展示"都只能是编造。
2. **禁止反推**——契约明写"绝不把审批通过当作可立即替换"。若在 M03 参数审批页显示"方案已替换"，就是把 `outcome: APPLIED` 当成屏障 READY，这正是契约要防的伪造 Completion。
3. **本批已在代码里给出正确做法**：`NO_BARRIER_READ_PORT_HINT` 明确告知"审批通过 ≠ 方案已立即替换，实际结果以培养运行页的生效方案快照为准"，并配了 testid。**待后端补读口 + 页面落地后直接接入。**

---

## 7. 验证边界（请勿越界解读）

- 本批为**源码级 + vitest** 验证，**未跑 `vite build`、未起服务、未做浏览器联调**。
- 投影函数的输入类型来自**后端 Java 源码**，**未经真实响应确认**（该接口无 HTTP 读口，无法联调）。
- 枚举与原因码以后端源码为准；若后端后续新增枚举值，前端会显示「未知状态（原值：xxx）」而非错误解读——这是刻意的失败关闭行为。

---

## 8. 后续落地时需注意（3 条）

1. **后端补读口后**，在本模块基础上新增 SDK 绑定即可，投影逻辑无需重写。
2. **READY 也不等于已替换**：READY 只表示"屏障可建立、允许 M03 切换指针"，真正生效仍要看培养运行页的生效方案快照。
3. **接入时不要把 `resourcesVerified` 压成布尔**，三态是契约的一部分。

---

## 9. 需总控裁决（1 项）

**是否为 `preparePlanReplacement` 屏障增加 HTTP 只读口？** 当前它只在 M03-P02 APPLY 的同库事务内被调用，前端因此永远无法展示实时屏障状态。选项：
- (a) 保持纯内部 Port，前端长期显示"无读口"提示（当前实现）
- (b) 新增只读端点供培养运行页查询屏障状态（需后端另开任务）

**前端建议 (a)**：屏障本质是"审批生效时的一次性事务前置检查"，把它做成可长期查询的读口价值有限，且会引入"查询到的屏障状态是否仍有效"的新问题（快照过期）。**但这属产品/架构决策，请总控裁决。**

---

## 10. git 状态（本批文件，未 add / 未 commit / 未 push）

```
?? futurefab-frontend/packages/app-smp-lab/src/shared/m07-plan-barrier.ts
 M futurefab-frontend/packages/app-smp-lab/src/shared/m07-test-ids.ts
?? futurefab-frontend/tests/m07-plan-barrier.test.ts
```

**禁改模块核查**：本批**零触碰** M01 / M02 / M03 / M04 页面，也未触碰任何 `.vue` 页面文件。
工作树中 `culture-management/*` 与 `m03-*.ts` 的改动仍为 **work1 的在途 M03 批次**，本批未参与、未代改。