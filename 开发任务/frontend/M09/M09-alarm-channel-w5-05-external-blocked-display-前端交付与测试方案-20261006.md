# M09 外部通道 —— W5-05 外部通道未核准/查单不可用/actor 不可用提示 前端交付与测试方案

- **批次**：W5-05
- **模块**：M09（告警与通知管理）
- **范围**：外部依赖未核实时的分类提示
- **执行**：work5（前端）
- **日期**：2026-10-06
- **验证层级**：源码 type-check + vitest（**HTTP / 浏览器 NOT_VERIFIED**）

---

## 1. 本批最重要的发现：四种依赖在界面上**完全无法区分**

外部依赖提示组件与四类文案（`channel-not-approved` / `query-unavailable` / `actor-unavailable` / `not-actually-delivered`）**在上一批次就已存在**，但两个投递详情页是这么用的：

```vue
<M09ExternalHint dependency="not-actually-delivered" :active="..." />
```

**硬编码**。后果是契约里的另外三种依赖——通道未核准、查单不可用、actor 不可用——**永远不会出现在界面上**。操作者无论遇到哪种外部故障，只会看到"通知未真实投递"，**不知道该找谁、该做什么**。

这直接抵消了上一批次建四类文案的意义：文案写得再准，页面不选就等于没写。

**本批交付**：`resolveExternalDependency()` —— 从**证据**（错误码 / reasonCode）判定依赖类型，替换硬编码。

---

## 2. 契约依据

判定依据是**契约错误码闭集**，不是猜测（`09-告警与通知管理/错误码全集.md`）：

| 错误码 / reasonCode | 契约口径 | 映射到 |
|---|---|---|
| `DEPENDENCY_UNAVAILABLE`（503） | 依赖读取不可用；**失败关闭**，保留非敏感草稿 | `query-unavailable` |
| `EXTERNAL_RESULT_UNKNOWN`（outcome） | `outcome=UNKNOWN` 明确展示，**不提供重复发送成功提示** | `query-unavailable` |
| `POLICY_UNAVAILABLE` / `POLICY_UNVERIFIED`（503） | 政策未核准；**不当成默认通过** | `channel-not-approved` |
| `RECIPIENT_UNKNOWN`（503） | 无法解析合法接收人；**不任意替代** | `channel-not-approved` |
| 含 `ACTOR` 的码 | 身份 fail-closed | `actor-unavailable`（**最高优先级**） |
| 以上皆无、但投递未达成功闭集 | — | `not-actually-delivered`（最保守兜底） |

四类提示的 `blocking` 统一为 `BLOCKED_EXTERNAL`（契约要求页面原样透出，**不得自行降级为"已完成"**）。

### 2.1 两条关键设计约束

**① 不根据 `delivery.state` 反推依赖类型。**
状态是**结果**，依赖类型是**原因**。`UNKNOWN` 可能是查单不可用，也可能是通道未核准——猜错会让操作员找错方向。所以 `resolveExternalDependency(evidence, state)` 只在**没有任何可判定证据**时，才用 `state` 走"是否需要提示"的兜底判断。

**② actor 优先级最高。**
身份 fail-closed 属最严重的阻断，若同时存在其它依赖码，应显示 actor 不可用（找对人比找全原因重要）。

---

## 3. 本批改动

### 3.1 修改（3）

| 文件 | 改动 |
|---|---|
| `shared/m09-status.ts` | 追加 `resolveExternalDependency()` |
| `alarm-mail-delivery/view.vue` | `dependency` 硬编码 → `:dependency="deliveryExternalDependency"` |
| `alarm-sms-delivery/view.vue` | 同上 |

### 3.2 新增（1）

`tests/m09-external-blocked-hint.test.ts` —— 18 用例。

### 3.3 修掉的既有缺陷（1 类，2 处）

| 缺陷 | 位置 | 后果 |
|---|---|---|
| 外部依赖类型硬编码为"未真实投递" | mail-delivery/view.vue:24、sms-delivery/view.vue:24 | 另外三种依赖**永不显示**，操作者无法定位故障方 |

**未改动**：`M09ExternalHint` 组件本身与四类文案表（本批只补"怎么选"，不改"选什么"）。

---

## 4. 测试抓到的自身 bug（1 个，已修）

`resolveExternalDependency` 的证据递归**漏掉了数组里的裸字符串**：

```ts
{ reasonCodes: ["POLICY_UNVERIFIED"] }   // ← 漏判，返回 null
{ reasonCodes: [{ issueCode: "..." }] }  // ← 能判对
```

根因：`collect()` 遇到数组会递归，但遇到**字符串元素**时直接 `return`（因为它不是 object）。这意味着最常见的 `reasonCodes: string[]` 形状**永远判不出依赖类型**——而漏判的后果是"本该显示的依赖提示不出现"，属于静默失败。

已修为在 `collect()` 里单独处理字符串元素，并由单测锁住（同时新增"闭集外的码不得被牵强解释"这条断言）。

---

## 5. 验证结果

### 5.1 编译/检查（4/4 全绿，均取到明确 exit code）

| 命令 | exit | 结果 |
|---|---|---|
| `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | **0** | ✅ |
| `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | **0** | ✅ |
| `pnpm --filter @futurefab/ui-app-smp-lab run type-check` | **0** | ✅ |
| `pnpm run routes:check` | **0** | ✅ |
| `npx prettier --check`（4 个本批文件） | — | ✅ |

本批未改 SDK 导出，**不需要** `build-dts`。

### 5.2 单测

| 套件 | 结果 |
|---|---|
| `tests/m09-external-blocked-hint.test.ts`（新增） | ✅ **18/18** |
| **W5-01~W5-05 全量回归（10 个套件）** | ✅ **174/174** |

### 5.3 单测覆盖要点

- 四个错误码族各自映射到正确依赖；actor 优先级压过 `DEPENDENCY_UNAVAILABLE`
- 嵌套位置（`issues[]` / `resultRef.evidence` / `reasonCodes[]`）均能命中
- **闭集外的码返回 `null`**（不编造依赖类型）
- 无证据时按 `state` 走保守兜底；`SUCCEEDED`/`APPLIED` **不提示**
- 四种依赖的 label 必须**互不相同**（否则分类无意义）；`blocking` 全部为 `BLOCKED_EXTERNAL`
- 四个 testid 互不相同
- 源码断言：两页均不再含 `dependency="not-actually-delivered"`，且提示仍受 `needsManualReview` 门控

---

## 6. 验证边界（请勿越界解读）

- 本批为**源码级 + vitest** 验证，**未跑 `vite build`、未起服务、未做浏览器联调**。
- 错误码取值来自 M09 错误码全集；**未经真实响应确认**。若后端实际返回的 `reasonCode` 命名与文档不同，判定会落到 `null`（不提示）——**这是刻意的失败关闭**，但需联调确认命名一致。
- 标签样式与提示条位置**未经浏览器确认**。

---

## 7. 需要 work9 人工验收的重点（3 条）

1. **先跑 `vite build`**（本批未跑），确认两个投递详情页的产物包含 resolver 逻辑。
2. **造四种证据各验一次**：把某条投递的 `result_ref.issues` 分别塞入 `DEPENDENCY_UNAVAILABLE` / `POLICY_UNVERIFIED` / `ACTOR_UNAVAILABLE`，刷新后确认提示条文案**随之变化**（这是本批的核心验收点）。
3. **确认已确认成功时不打扰**：`state=SUCCEEDED` 的投递不应出现任何外部依赖提示。

---

## 8. 需总控裁决（1 项）

**投递详情页是否还应显示"未真实投递"这一兜底提示？**
当前设计：无证据且投递未成功时显示"通知未真实投递"。另一种做法是**无证据就不提示**（更保守，但操作者会失去"这里需要人工看一眼"的信号）。

**前端当前取前者**（有提示优于无提示，且文案已声明"不得据此宣称已通知到人"，不会误导）。若总控倾向后者，改 `resolveExternalDependency` 兜底分支为 `return null` 即可，单测已覆盖两种行为的断言位置。

---

## 9. git 状态（本批文件，未 add / 未 commit / 未 push）

```
 M futurefab-frontend/packages/app-smp-settings/src/shared/m09-status.ts
 M futurefab-frontend/packages/app-smp-settings/src/views/alarm-mail-delivery/view.vue
 M futurefab-frontend/packages/app-smp-settings/src/views/alarm-sms-delivery/view.vue
?? futurefab-frontend/tests/m09-external-blocked-hint.test.ts
```

**禁改模块核查**：本批**零触碰** M01 / M02 / M03 / M04 页面。
工作树中 `culture-management/*` 与 `m03-*.ts` 的改动仍为 **work1 的在途 M03 批次**，本批未参与、未代改。