# M09 告警/通知/投递记录 —— W5-03 UNKNOWN/BLOCKED/ACK/monitorAck 展示 前端交付与测试方案

- **批次**：W5-03
- **模块**：M09（告警与通知管理）
- **范围**：告警/通知/投递记录页面的状态展示、ACK 与外部依赖提示
- **执行**：work5（前端）
- **日期**：2026-10-06
- **验证层级**：源码 type-check + vitest（**HTTP / 浏览器 NOT_VERIFIED**）

---

## 1. 与上一批次（W5-01 前身）的关系

M09 的状态词典、monitorAck 只读面板、外部提示条**已在上一批次交付**，本批**不重做**。本批做的是两件事：

1. **补上上一批次漏掉的 4 个页面**（见 §3.1）
2. **修掉一个高风险编码陷阱**（见 §2，本批最重要的发现）

已交付且本批**仅做回归确认、未改动**的部分：

| 模块 | 行数 | 状态 |
|---|---|---|
| `shared/m09-status.ts` | 317 →本批扩充 | 投递/尝试/事件/修订四族词典 + monitorAck + externalHint |
| `shared/m09-monitor-ack.ts` | 210 | monitorAck 只读投影 + evidence 安全摘要 |
| `shared/m09-monitor-ack-panel.vue` | 234 | monitorAck 展示区块（不发请求） |
| `shared/m09-external-hint.vue` | 56 | 外部依赖提示条（不发请求） |
| `tests/m09-alarm-status-monitorack.test.ts` | 30 用例 | 回归通过 |

---

## 2. 本批最重要的发现：两个 `enabled` 字段的编码**是相反的**

这是本批的核心价值，也是最容易埋雷的地方：

| 字段 | 字典原文 | `0` 含义 | `1` 含义 |
|---|---|---|---|
| `alarm_mail_config.enabled` | `是否启用（0启用 1停用）` | **启用** | 停用 |
| `alarm_notify_rule.enabled` | `0关闭或1开启；与旧离线enabled编码不同` | **关闭** | 开启 |
| `alarm_notify_rule.cycle_enabled` | `0关闭或1开启` | **关闭** | 开启 |

注意通知规则侧字典**自己写了"与旧离线 enabled 编码不同"**——说明这里历史上已经出过一次错。

**因此本批刻意写了两个函数而不是一个"通用开关"**：
- `presentEnabledFlag()` —— 邮件通道，0=已启用
- `presentNotifyRuleEnabled()` —— 通知规则，1=已开启

合并成一个映射就等于把两个相反的事实混成一张表，**用错一处就会把停用的通道显示成启用（或反之）**。单测专门锁住了这一点（断言两个函数对同一个 `"0"` 给出不同 label、且 i18n key 不同）。

---

## 3. 本批改动

### 3.1 页面盘点（7 个 M09 页面）

| 页面 | 上一批状态 | 本批 |
|---|---|---|
| `alarm-alarm-record/view.vue` | ✅ 已接入 | 回归确认 |
| `alarm-mail-delivery/{index,view}.vue` | ✅ 已接入 | 回归确认 |
| `alarm-sms-delivery/view.vue` | ✅ 已接入 | 回归确认 |
| **`alarm-alarm-mail-config/{index,view}.vue`** | ❌ **裸 `0`/`1`** | ✅ **本批修复** |
| `alarm-alarm-notify-receiver/*` | 无状态列 | 不改（见 §6.1） |
| `alarm-alarm-notify-rule/*` | 行内编辑网格，无状态列 | 不改（见 §6.1） |
| `smp-notification/index.vue` | 已正确处理已读态 | 不改（见 §6.2） |

### 3.2 修改（4）

| 文件 | 改动 |
|---|---|
| `shared/m09-status.ts` | 追加 `TogglePresentation`/`ToggleTone` 类型 + `presentEnabledFlag` / `presentNotifyRuleEnabled` / `presentEvaluationState` |
| `shared/m09-test-ids.ts` | 追加 `CHANNEL_ENABLED_TEST_ID` |
| `alarm-alarm-mail-config/index.vue` | 状态列改走受控词典 + testid；列标题与校验消息去掉裸编码 |
| `alarm-alarm-mail-config/view.vue` | 详情字段 `{{ info.status }}` → 受控文案 |

### 3.3 新增（1）

`tests/m09-alarm-channel-enabled.test.ts` —— 18 用例。

### 3.4 修掉的既有缺陷（3 项）

| # | 缺陷 | 位置 | 后果 |
|---|---|---|---|
| 1 | 列表状态列**直接渲染裸 `0`/`1`** | mail-config/index.vue | 界面上就是 `0` 或 `1`，操作者无法判断哪个是启用 |
| 2 | 列标题写成 `启用状态：0启用 1禁用` | 同上 | **把编码解释负担丢给读界面的人**——文案不该是数据字典的替代品 |
| 3 | 详情抽屉 `{{ info.status }}` | mail-config/view.vue | 抽屉里直接出现 `0`/`1` |

附带修掉表单校验消息 `启用状态：0启用 1禁用不能为空` 里的同一问题。

### 3.5 新增能力：`presentEvaluationState`

契约 `logic_profile_ref` 注明「核准外部告警逻辑及版本；**无则不得执行高级字段**」，错误码全集另有 `POLICY_UNAVAILABLE` / `POLICY_UNVERIFIED`（503，**不当成默认通过**）。

因此 `evaluation_state` 的 `SAVE_ONLY` **必须显示为「仅保存，未核准」（警示档），绝不能显示成"已生效"**。本批把该 helper 备好，W5-05 接入外部通道提示时会直接用到。

---

## 4. 一个类型设计决定（值得记录）

追加 helper 时**没有复用现有的 `StatusPresentation`**，而是新定义了 `TogglePresentation`。两个原因：

1. `StatusPresentation.hint` 是为投递状态机设计的（"避免把 UNKNOWN 说成正常"），开关类没有这类口径，硬填一个 hint 只是废话；
2. `StatusTone` 里**没有 `warning`**（只有 `pending/running/success/danger/unknown/neutral`），而"仅保存、未核准"必须落在警示档。强行复用会把 `warning` 塞进一个语义不匹配的联合类型里。

这个决定是**被 type-check 逼出来的**（首次实现直接复用 `StatusPresentation`，`app-smp-settings` type-check 报 13 条 TS2741/TS2322）。改法是给开关类独立类型，`tone` 直接对齐 `StatusTag` 的 list_class 档位，**未改动任何既有 `StatusTone` 成员**（避免影响上一批已交付代码）。

---

## 5. 验证结果

### 5.1 编译/检查（4/4 全绿）

| 命令 | 结果 |
|---|---|
| `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | ✅ |
| `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | ✅（首次失败，见 §4；修复后 `EXIT=0` / 0 error） |
| `pnpm run routes:check` | ✅（`ROUTES_EXIT=0`） |
| `npx prettier --check`（5 个本批文件） | ✅ |

本批未改 SDK 导出，故**不需要** `build-dts`。

### 5.2 单测（48/48 绿）

| 套件 | 结果 |
|---|---|
| `tests/m09-alarm-channel-enabled.test.ts`（新增） | ✅ **18/18** |
| `tests/m09-alarm-status-monitorack.test.ts`（上一批，回归） | ✅ **30/30** |

单测覆盖的关键断言：

- `presentEnabledFlag("0") === 已启用`（反直觉编码）、`presentEnabledFlag("1") === 已停用`
- 缺值显示「未知启用状态」，**不落进「已停用」**（那等于凭空断言通道被关了）
- 契约外编码（`"Y"`）标为 unknown 并保留原值
- **`presentNotifyRuleEnabled` 与 `presentEnabledFlag` 对同一 `"0"` 必须给出不同 label 与不同 key**
- `SAVE_ONLY` 的 label 必须含「未核准」，且 key 不得与 `VERIFIED` 相同
- 源码断言：列标题/校验消息不再含裸编码、详情不再出现 `{{ info.status }}`
- **回归**：上一批的 `presentStatus` 四族词典、`isForeignM09State`（ACKNOWLEDGED/STALE 外来值登记）、`externalHint` 契约均未被破坏

---

## 6. 明确不改的部分（附理由，避免被当成漏做）

### 6.1 通知规则页与接收人页无状态列

- `alarm-alarm-notify-rule/grid.ts` 的 6 列是 `ruleCode` / `alarmModule` / 是否通知 / 通知方式 / 频率上限 / 接收人，**全部是行内编辑控件**，`enabled` 与 `evaluationState` 只作为表单字段存在，不作为裸值列渲染。
- `alarm-alarm-notify-receiver` grep `field:` / `enabled` / `status` **零命中**——该页没有需要受控化的状态列。

`presentNotifyRuleEnabled` 与 `presentEvaluationState` 已备好，**待这些页面改为列表展示时直接接入**。

### 6.2 站内通知页已正确处理已读态

`smp-notification/index.vue` 的 `isUnread(row)` 用 `String(row.isRead) !== "1"` 判定，并有 `formatReadStatus` 文案函数——**逻辑正确，无缺陷**，不改。

---

## 7. 验证边界（请勿越界解读）

- 本批为**源码级 + vitest** 验证，**未跑 `vite build`、未起服务、未做浏览器联调**。
- 标签配色与列宽调整**未经浏览器确认**。
- `enabled` 语义取自字段字典与后端 VO，**未经真实响应确认**（无联调）。
- 上一批遗留事实不变：**monitorAck 当前必然显示"尚无执行确认记录"**（后端只写不读），这是**符合契约的预期，不是缺陷**。

---

## 8. 需要 work9 人工验收的重点（3 条）

1. **先跑 `vite build`**（本批未跑），确认 `m09-channel-enabled` testid 在产物中可查。
2. **核对编码**：把某行 `status` 改成 `0`，确认列表与抽屉都显示「已启用」；改成 `1` 显示「已停用」；**清空确认显示「未知启用状态」而非「已停用」**。
3. **确认列标题已简化**为「启用状态」，不再承担编码解释职责。

---

## 9. 需总控裁决（2 项）

1. **通知规则列表是否需要展示 `enabled` / `evaluationState` 只读列？** 当前该页是行内编辑网格，没有只读状态列。若产品要求"一眼看出哪些规则未核准"，需另开批次加列（本批已备好 helper）。
2. **`ALARM 未接入 M09 共享模块的 3 个页面是否需要统一？** 本批只修了唯一有裸值缺陷的 mail-config；另两个页面（notify-receiver / notify-rule）当前无状态列，**无缺陷可修**。

---

## 10. git 状态（本批文件，未 add / 未 commit / 未 push）

```
 M futurefab-frontend/packages/app-smp-settings/src/shared/m09-status.ts
 M futurefab-frontend/packages/app-smp-settings/src/shared/m09-test-ids.ts
 M futurefab-frontend/packages/app-smp-settings/src/views/alarm-alarm-mail-config/index.vue
 M futurefab-frontend/packages/app-smp-settings/src/views/alarm-alarm-mail-config/view.vue
?? futurefab-frontend/tests/m09-alarm-channel-enabled.test.ts
```

**禁改模块核查**：本批**零触碰** M01 / M02 / M03 / M04 页面。
工作树中 `culture-management/*` 与 `m03-*.ts` 的改动仍为 **work1 的在途 M03 批次**，本批未参与、未代改。