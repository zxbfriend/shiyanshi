# M09 前端交付与测试方案：告警/通知状态与 monitorAck 只读展示（w5-01）

- 任务：M09 前端开发：告警/通知状态与 monitorAck 只读展示（执行人 work5）
- 交付日期：2026-10-06
- 模块：M09 告警与通知管理
- 契约依据：`docs/详细设计/09-告警与通知管理/审阅收尾完整字段字典.md`（四族状态枚举）、`数据库JSON与事务契约.md` §2（`result_ref.monitorAck` 叶子）、`页面与接口契约.md` API14（`executionAck`）、`错误码全集.md`、`审阅收尾准入与恢复契约.md`；AGENTS.md §13.2 完成口径、§13.4 浏览器验收
- 本批性质：**只读展示 + 文案口径 + 测试辅助**。不新增业务功能、不改任何请求路径/payload/headers、不触发任何外部调用、不伪造外部通知成功
- 本批状态：**IMPLEMENTED + CONTRACT_TESTED + 类型检查通过**。HTTP、浏览器、数据库一律 **NOT_VERIFIED**，由 work9 按本文第五节执行后另行结论
- git 状态：未 `git add`、未 commit、未 push

---

## 一、基本信息

| 项 | 内容 |
|---|---|
| 所属模块 | M09 告警与通知管理 |
| 前端应用包 | `@futurefab/ui-app-smp-settings` |
| SDK 包 | `@futurefab/ui-sdk-smp-api`（仅新增类型，无接口变更） |
| 页面目录 | `views/alarm-mail-delivery/`、`views/alarm-sms-delivery/`、`views/alarm-alarm-record/` |
| 新增共享模块 | `packages/app-smp-settings/src/shared/m09-{status,monitor-ack,test-ids}.ts`、`m09-{monitor-ack-panel,external-hint}.vue` |
| 守卫写接口 | **本批零改动**。告警处理/忽略仍走既有 `handleAlarmV2` + `useGuardedWrite` 基线校验 |
| 语言包 | **本批零改动**。新增文案一律用 `t(key, 中文兜底)` 形式，未登记 key 时回落中文（与仓库既有 `mail-delivery.*` 写法一致） |
| 明确不在本批范围 | M03全部页面/API（work1 在途）、M01/M02/M04/M05/M06/M07 页面、后端 Java/Mapper/XML、SQL、客户材料/history |

---

## 二、页面/菜单/API 盘点结果

### 2.1 页面与菜单（已存在，无需新建）

| 页面 | 路由 | 菜单组件 | view.vue | 本批是否改动 |
|---|---|---|---|---|
| 告警记录 | `alarm-alarm-record` | `alarm/alarmRecord/index` | 有 | **是**（接入 monitorAck 只读区块） |
| 邮件投递详情 | `alarm-mail-delivery` | `alarm/mailDelivery/index` | 有 | **是**（状态文案 + 提示 + testid） |
| 短信投递详情 | `alarm-sms-delivery` | `alarm/smsDelivery/index` | 有 | **是**（同上） |
| 告警邮件配置 | `alarm-alarm-mail-config` | — | 有 | 否 |
| 通知接收人 | `alarm-alarm-notify-receiver` | — | 有 | 否 |
| 通知规则 | `alarm-alarm-notify-rule` | `alarm/alarmNotifyRule/index` | 无（有 editor） | 否 |
| 站内通知 | `smp-notification` | — | 有 | 否 |
| 离线/声光/状态告警 | `lab-offlinealarm` / `lab-soundalarm` / `lab-statusalarm` | — | 无 | 否 |

盘点结论：**M09 告警/通知主页面均已存在且已注册路由**，本批**不新建任何大型页面**。

### 2.2 monitorAck 读口：**BLOCKED_DESIGN（重要）**

这是本批最重要的盘点结论，直接决定测试方案怎么写：

| 事实 | 证据 |
|---|---|
| `monitorAck` **只写入、不读出** | 后端 `AlarmMonitorAcknowledgementService#buildResultRef` 只把它写进 `alarm_event.result_ref` |
| **没有任何读口 VO 透出 `resultRef` / `monitorAck`** | 已核 `AlarmDeliveryV2Controller`、`AlarmRecordV2Controller`、`AlarmNotificationV2Controller` 及其 VO（`AlarmDeliveryDetailView`、`AlarmMonitorPolicyView` 等），**均无 `resultRef`/`monitorAck` 字段** |
| 契约测试还专门断言审计快照不含 `result_ref` | `M09WiredNotificationReadContractTest#t13AuditSnapshotCarriesOnlySanitizedProjection` 把 `resultRef`/`result_ref` 列为**禁止出现的敏感串** |
| 后端 `revisionId` **恒为 null** | `buildResultRef` 里 `ack.putNull("revisionId")`，注释明确"如实置 null，不以猜测或读取配置伪造修订号" |

**因此**：
1. 前端**已按契约实现完整的 monitorAck 只读展示**（policyId/revisionId/state/occurredAt/evidence），但当前后端读口拿不到数据 → 组件会显示 **"尚无监控执行确认记录"**。
2. 这**不是前端缺陷**，而是 `BLOCKED_DESIGN`：读口未透出 monitorAck。**work9 测到"尚无执行确认"是符合当前契约的预期结果**，不得判为页面缺陷，也不得为了"看到内容"而放宽后端审计脱敏。
3. `revisionId=null → "未提供配置修订"` 这条口径**已按后端实际形态实现并被测试钉住**，一旦将来后端透出 monitorAck，该文案会自动生效。

### 2.3 可用的替代读口

`GET /alarm/v2/monitor-policy`（API14，`AlarmMonitorPolicyV2Controller`，权限 `alarm:monitorPolicy:query`）返回 `AlarmMonitorPolicyView`，含：
- `executionAck`：`MonitorExecutionAck` 枚举 **APPLIED / PENDING / UNKNOWN**（"配置已保存"与"执行侧待应用"的分离信号）
- `revisionId` / `version` / `mode` / `scope` / `allowedActions`

**前端无对应页面**（`monitor-policy` 未注册路由），本批**不新建**（任务书明确"不强行造大型页面"）→ 记 **NO_UI**，已在第六节登记。`presentExecutionAck()` 已实现该读口的文案口径，供后续页面直接复用。

---

## 三、修改文件清单

| # | 文件 | 类型 | 说明 |
|---|---|---|---|
| 1 | `packages/app-smp-settings/src/shared/m09-status.ts` | **新增**（约 300 行） | 四族状态枚举合并词典 + `presentStatus` / `isConfirmedSuccess` / `needsManualReview` / `externalHint` / `isForeignM09State` |
| 2 | `packages/app-smp-settings/src/shared/m09-monitor-ack.ts` | **新增**（约 250 行） | monitorAck 只读投影：`projectMonitorAck` / `evidenceSummary` / `presentExecutionAck`；含控制字符清洗与限长 |
| 3 | `packages/app-smp-settings/src/shared/m09-monitor-ack-panel.vue` | **新增**（约 200 行） | monitorAck 只读展示区块；不发请求 |
| 4 | `packages/app-smp-settings/src/shared/m09-external-hint.vue` | **新增**（约 45 行） | 外部依赖提示条，透出 `BLOCKED_EXTERNAL` 状态词；不发请求 |
| 5 | `packages/app-smp-settings/src/shared/m09-test-ids.ts` | **新增**（约 90 行） | 定位属性常量与生成函数（前缀 `m09-`） |
| 6 | `.../views/alarm-mail-delivery/view.vue` | 修改（+61/−30） | 状态文案换共享模块、外部提示、5 个 testid；**移除内联 5 值表** |
| 7 | `.../views/alarm-sms-delivery/view.vue` | 修改（+59/−30） | 同上 |
| 8 | `.../views/alarm-mail-delivery/index.vue` | 修改（+2/−0） | 详情按钮 testid（带 deliveryId） |
| 9 | `.../views/alarm-alarm-record/view.vue` | 修改（+7/−0） | 接入 `<M09MonitorAckPanel :ack="info.resultRef" />` |
| 10 | `packages/sdk-smp-api/src/modules/alarm/alarmDeliveryV2.ts` | 修改（+73/−0） | **纯类型新增**：`AlarmSourceRef` / `AlarmMonitorAck` / `AlarmEventResultRef` / `AlarmMonitorExecutionAck` / `AlarmMonitorPolicyView`；无接口函数变更 |
| 11 | `tests/m09-alarm-status-monitorack.test.ts` | **新增**（30 用例） | 见第五节 |

> 工作树中 `benchreactor-management/*`、`culture-management/*`、`feeding-template-management/*`、`venue-management/*`、`sdk-language/smp-settings/*`、`sdk-smp-api/src/{benchreactor,processTemplate}.ts`、`lab-labbenchreactor/*` 及多个 `tests/*` 均为**其他 work 在途改动**，本批零触碰。**M03（culture-management / m03-culture-error.ts / m03-culture-candidate-entry.test.ts）为 work1 在途，本批已核未触碰。**

---

## 四、本轮改动详解

### 4.1 状态文案：四族枚举合并（原两处内联表各自只有 5 值）

原`alarm-mail-delivery/view.vue` 与 `alarm-sms-delivery/view.vue` 各自内联同一份 5 值表（`PENDING/SENDING/SUCCEEDED/FAILED/UNKNOWN`），存在两个问题：

1. **漏值**：投递枚举还有 `SKIPPED`/`CANCELLED`，尝试枚举还有 `INVOKING`——这些值原来直接**原样透出英文枚举**，没有中文口径；
2. **空值误导**：`if (!value) return "-"` —— 空状态显示 `-`，会被读成"没有异常"，而不是"状态未知"。

现在两页共用 `presentStatus()`，四族枚举全覆盖，且空值/未登记值一律归 `UNKNOWN`：

| 状态 | 文案 | tone | 契约出处 |
|---|---|---|---|
| `PENDING` | 待发送 | pending | delivery_state / attempt_state |
| `SENDING` | 发送中 | running | delivery_state |
| `INVOKING` | 调用中 | running | **attempt_state 独有**（T06：意图先提交，事务外调用） |
| `SUCCEEDED` | 已成功 | success | delivery/attempt_state |
| `APPLIED` | 已应用 | success | process_state / revision_state / monitorAck.state / executionAck |
| `FAILED` | 已失败 | danger | delivery/attempt/monitorAck |
| `BLOCKED` | 已阻断 | danger | **process_state 独有** |
| `IGNORED` / `RECEIVED` / `DISCARDED` / `CONFLICT` | 已忽略 / 已接收 / 已废弃 / 冲突 | — | process_state / revision_state |
| `SKIPPED` / `CANCELLED` | 已跳过 / 已取消 | neutral | delivery_state |
| `UNKNOWN` | **未知** | **unknown** | 全族 |

三条硬规则（已测）：
- `UNKNOWN` 的 tone 是 `unknown` 而**非** `success`，hint 明写"需人工核实；不代表成功，也不代表失败"；
- `isConfirmedSuccess()` **只认 APPLIED/SUCCEEDED**，`UNKNOWN`/`PENDING`/`INVOKING` 一律 false——调用方不得用"不是失败"推导"已成功"；
- `needsManualReview()` 把 `UNKNOWN` 计入人工核实。

### 4.2 关于 ACKNOWLEDGED / STALE：显式登记为**非 M09 枚举**

任务书点名的 8 个状态里，这两个**不属于 M09**，已用 `isForeignM09State()` 显式登记，并在测试中钉住"不得被拼成看起来像 M09 成功态的文案"：

| 值 | 真实归属 | M09 侧对应语义 |
|---|---|---|
| `ACKNOWLEDGED` | M06 `apr_delivery.state`（`06/审阅收尾完整字段字典.md`） | `executionAck: APPLIED` |
| `STALE` | M02 `reading_quality`（GOOD/STALE/BAD/UNKNOWN）与 M05 受控更正终态 | **无**。且 `02/在线业务观测存储与查询契约.md` 明文要求"**不能创造 M09 未定义 STALE 枚举**" |

前端遇到这两个值时显示"未知"并保留原值供排查，**不伪造**一个像模像样的 M09 成功/失败文案。

### 4.3 monitorAck 只读展示

`projectMonitorAck()` 把 `result_ref`（或已取出的 `monitorAck`）投影成可直接渲染的只读视图：

| 展示项 | 实现 |
|---|---|
| `policyId` | 原样透出（清洗控制字符 + 限长 64） |
| `revisionId` | **为空时固定显示"未提供配置修订"**；有值才显示真实修订号 |
| `state` | 走 `presentStatus()`，UNKNOWN 带口径说明 |
| `occurredAt` | 原样透出（限长 40） |
| `evidence` | **白名单字段**拼摘要：`module / kind`、`id`、`v{version}`、`hash 前8位…` |

**`revisionId=null` 的处理是本批最关键的口径**：后端 `buildResultRef` 恒 `putNull("revisionId")`，所以前端
- 显示 **"未提供配置修订"**（`REVISION_NOT_PROVIDED_TEXT`）；
- 当 `state=APPLIED` 但修订号缺失时，`pendingExecution=true` → 组件额外挂 **"配置已保存，但执行侧未提供配置修订号，不能据此认定配置已完整生效"** 警告条（`data-testid="m09-monitor-ack-pending-execution"`）；
- **绝不**显示成"配置已完整生效/已应用"。

**evidence 安全边界（白名单式，非黑名单）**：`evidenceSummary()` 只 `safeText()` 取 `module/kind/id/version/hash` 五个字段拼接，**不遍历对象、不 `JSON.stringify`**。因此即使后端将来在 evidence 里多带 `content`/`payloadJson`/`credential`/`phone`/`stackTrace` 等字段，也**不可能**被拼进摘要。测试已逐个断言这些敏感串不出现。另做控制字符清洗（`\u0000-\u001f\u007f`）与限长（摘要 <200 字符）。

### 4.4 外部依赖提示

`externalHint()` 覆盖任务书要求的 4 种情况，统一 `blocking: "BLOCKED_EXTERNAL"`，文案显式带状态词（供 work9 直接断言，不解析中文）：

| 依赖 | 文案 | 要点 |
|---|---|---|
| `channel-not-approved` | 外部通道未核准 | 地址/鉴权/字段映射/查单能力未核准，**保持 BLOCKED，不用 Mock 冒充送达** |
| `query-unavailable` | 查单能力不可用 | UNKNOWN 无法自动核实，**不得盲目补发** |
| `actor-unavailable` | 操作者身份不可核验 | 已 fail-closed：**不写入、不伪造已确认** |
| `not-actually-delivered` | 通知未真实投递 | 仅落站内记录，**不得据此宣称已通知到人** |

接入点：邮件/短信投递详情在 `delivery.state` 命中 `needsManualReview()`（UNKNOWN/FAILED/BLOCKED/CONFLICT）时显示"通知未真实投递"提示条。**组件内零请求**，已测（断言组件源码不含 `request(`/`axios`/`fetch(`/`sendMail`/`sendSms`）。

### 4.5 定位属性（前缀 `m09-`，与 M02 的 `lab-benchreactor-` 区分）

| 目标 | 定位方式 |
|---|---|
| 投递详情抽屉根 | `[data-testid="m09-delivery-view"]` |
| 抽屉状态头 | `[data-testid="m09-delivery-status-header"]` |
| 投递状态取值 | `[data-testid="m09-delivery-state"]` |
| 投递尝试表 | `[data-testid="m09-delivery-attempts"]` |
| 列表详情按钮 | `[data-testid="m09-delivery-view-<deliveryId>"]` |
| monitorAck 区块 | `[data-testid="m09-monitor-ack"]` |
| ├ 尚无确认（负例） | `[data-testid="m09-monitor-ack-absent"]` |
| ├ 待应用警告 | `[data-testid="m09-monitor-ack-pending-execution"]` |
| ├ policyId / revisionId / state | `m09-monitor-ack-policy-id` / `-revision-id` / `-state` |
| ├ 状态口径说明 | `[data-testid="m09-monitor-ack-hint"]` |
| └ evidence 摘要 | `[data-testid="m09-monitor-ack-evidence"]` |
| 外部提示条 | `[data-testid="m09-external-hint-<dependency>"]` |

`deliveryViewTestId()` / `externalHintTestId()` 非法字符清洗后为空则退回 `unknown`——定位失败表现为"找不到"，不会"选中错误的行"。

---

## 五、已执行验证命令与结果

均在 `futurefab-frontend/` 执行。**严格按"代码 → 编译/检查 → 建本文档"顺序，前四项全绿后才创建本 MD。**

| # | 命令 | 结果 |
|---|---|---|
| 1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | ✅ 通过 |
| 2 | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | ✅ 通过（本批改了 SDK 类型，`dist-types/` 已刷新；该目录 gitignore，工作树干净） |
| 3 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | ✅ 通过（必须在 build-dts 之后跑：app 经 SDK `dist-types/index.d.ts` 解析，不看源码） |
| 4 | `pnpm run routes:check` | ✅ 通过 |
| 5 | `npx vitest run tests/m09-alarm-status-monitorack.test.ts` | ✅ 通过：**1 文件 / 30 用例全绿** |
| 6 | `npx prettier --check`（本批 7 个新文件） | 首轮 6 个不合规 → 已 `--write`，复跑第 3、5 项仍全绿 |

**测试发现并已修复的 2 个真实缺陷**（如实登记，均为本批自身代码）：
1. `needsManualReview(undefined)` 原返回 `false` —— 会导致"标签显示未知、审核提示说不用看"的自相矛盾。已改为空值也返回 `true`。
2. `projectMonitorAck({})` 原返回 `present: true` —— 读口给了空壳时页面会渲染一片空白。已改为空对象也返回 `present: false`。

**回归检查（如实登记，未代改）**：
- `tests/monitor-log.test.ts` **4 个红**（日志查询字段/时间区间/排序冻结）。已核：该测试**对本批改动零引用**（`grep` 计数 0），且属仓库既有红基线，**非本批引入**。
- 其余邻近套件（`lab-statusalarm`、`lab-labbenchreactor-guarded-write`）随本批 30 用例一并绿（共 32 passed）。

**未执行**：生产构建、HTTP、浏览器、SQL —— 全部未执行。
分层结论：**静态检查通过 + 编译（type-check）通过 + 契约测试通过**。按 AGENTS.md §13.2，**不得**据此宣称 `HTTP_VERIFIED` / `BROWSER_VERIFIED`。

---

## 六、NO_UI / BLOCKED_MENU / BLOCKED_EXTERNAL / BLOCKED_DESIGN 登记

| 状态 | 对象 | 说明 | 处置 |
|---|---|---|---|
| **BLOCKED_DESIGN** | `monitorAck` 读口 | 后端只写不读：无任何读口 VO 透出 `result_ref`/`monitorAck`；契约测试还把 `result_ref` 列为审计快照**禁止出现的敏感串**（`M09WiredNotificationReadContractTest#t13`）。前端已按契约实现完整只读展示，当前必然显示"尚无执行确认记录" | 已实现 + 记录。**需总控裁决**：是否在 M09 读口 VO 暴露**脱敏后的** monitorAck 投影（policyId/state/occurredAt/evidence 摘要，不含 result_ref 原文）。**work9 测到"尚无确认"是预期结果，不得判为缺陷** |
| **NO_UI** | 监控策略页（API14 `/alarm/v2/monitor-policy`） | 后端只读+ 守卫写接口均已接线，前端**无页面、未注册路由** | 本批**不新建大型页面**（任务书明确要求）。`presentExecutionAck()` 已实现该读口文案口径，后续补页面可直接复用 |
| **BLOCKED_EXTERNAL** | 外部通道（邮件/短信/声光） | 外部 URL/鉴权/字段映射/查单能力未获客户核准 | 页面按 `needsManualReview()` 显式挂提示条，**不伪造送达**。本批**未接任何真实外部调用** |
| **BLOCKED_EXTERNAL** | actor 不可用 | 后端 fail-closed：`REASON_ACTOR_UNAVAILABLE`，零写、不伪造 ACK | 前端文案已覆盖（`actor-unavailable` 提示），本批无页面触发该路径 |
| **BLOCKED_MENU** | 无 | 本批涉及的 3 个页面路由与菜单组件均已存在（`alarm-alarm-record` / `alarm-mail-delivery` / `alarm-sms-delivery`） | 无 |

---

## 七、给 work9 的浏览器测试方案

### 7.0 测试前置

1. **必须先构建**（本批未跑 build）：portal 跑预构建产物、不吃源码 HMR。在 `futurefab-frontend/` 执行：
   ```
   pnpm --filter @futurefab/ui-sdk-smp-static-files build
   pnpm --filter @futurefab/ui-sdk-smp-api run build-dts
   pnpm --filter @futurefab/ui-app-smp-settings run build
   ```
   构建后确认产物含字符串 `m09-monitor-ack`、`m09-delivery-state` 再开始验收。
2. 后端 `futurefab-system`（9201）已启动；账号需有 `smp:notification:query` 与 `alarm:alarmRecord:query` 权限。
3. DevTools：Network（勾 Preserve log）+ Console；每条用例截图。

### 7.1 TC-ENTRY 页面入口与菜单（对应第六节"记录是否完整"）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 进入 `/setting/alarm-mail-delivery` | 页面渲染，Console 无红色报错 |
| 2 | 进入 `/setting/alarm-sms-delivery` | 同上 |
| 3 | 进入告警记录页并打开任一条详情抽屉 | 抽屉打开，出现 `[data-testid="m09-monitor-ack"]` 区块 |
| 4 | 若菜单不可达 | 记 **BLOCKED_MENU** 并写明缺哪个菜单/权限，**不得**用直接改 URL 替代验收结论 |

### 7.2 TC-LIST 列表打开

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 邮件/短信投递列表加载 | `GET /alarm/v2/notifications?channel=email|sms&pageNum=1&pageSize=N` 200 |
| 2 | 状态列取值 | 有中文文案，无裸英文枚举 |
| 3 | 点详情 | `[data-testid="m09-delivery-view-<deliveryId>"]` 可稳定点击，抽屉打开 |

### 7.3 TC-STATUS 状态展示（对应要求 3）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 打开一条 `state=UNKNOWN` 的投递详情 | `[data-testid="m09-delivery-state"]` 显示 **"未知"**；**不得**显示"已成功" |
| 2 | 同上，看状态头 | `[data-testid="m09-delivery-status-header"]` 存在且文案与状态一致 |
| 3 | 找一条 `attempt_state=INVOKING` 的尝试记录 | 尝试表显示 **"调用中"**（不是原始 `INVOKING`） |
| 4 | 找 `FAILED` / `BLOCKED` | 显示"已失败" / "已阻断" |
| 5 | 造一条后端返回未登记状态（如 `state="WHAT"`） | 页面显示"未知"，**不报错、不显示原始枚举当正常态** |
| 6 | 若数据里出现 `ACKNOWLEDGED` / `STALE` | 显示"未知"（这两个不是 M09 枚举），**记录实际行为** |

### 7.4 TC-MONITORACK monitorAck 展示（对应要求 4、5、6）

**关键预期：当前后端读口不透出 monitorAck（第六节 BLOCKED_DESIGN），所以第 2 步应显示"尚无执行确认记录"。这是符合契约的结果，不是缺陷。**

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 打开告警详情抽屉 | `[data-testid="m09-monitor-ack"]` 区块存在 |
| 2 | 看区块内容 | **当前预期**：显示 `[data-testid="m09-monitor-ack-absent"]`"尚无监控执行确认记录"+ 说明"没有执行确认事实不代表已生效"。**若真的看到了完整 ACK 字段，请立即回传——说明后端已透出，需同步更新本文档结论** |
| 3 | 用 DevTools 响应改写，**模拟**后端未来透出 `{monitorAck:{policyId:"P1",revisionId:null,state:"APPLIED",occurredAt:"2026-10-06T00:00:00Z",evidence:{module:"M09",kind:"COMMAND",id:"P1",version:"1",hash:"3f2a9c1b4d5e6f70"}}}` | `revisionId` 区显示 **"未提供配置修订"**（`m09-monitor-ack-revision-id`）；state 显示"已应用"；**同时**出现 `m09-monitor-ack-pending-execution` 警告条 |
| 4 | 同上但把 `revisionId` 改为 `"998877"` | 显示 `998877`，且**不再**出现待应用警告条 |
| 5 | 同上但 `state="UNKNOWN"` | state 显示"未知"，`m09-monitor-ack-hint` 含"需人工核实" |
| 6 | 第 3 步的 evidence | 摘要形如 `M09 / COMMAND · P1 · v1 · hash 3f2a9c1b…`；**hash 只显示前 8 位** |
| 7 | **泄漏检查**（要求 6）：在响应里给 evidence 塞入敏感字段（`content`/`body`/`payloadJson`/`credential`/`phone`/`email`/`stackTrace`），刷新 | `[data-testid="m09-monitor-ack-evidence"]` 的文本里**不得**出现正文、手机号、邮箱、凭据、堆栈任何片段。**这是本批最需要人工肉眼确认的一条** |

### 7.5 TC-EXTERNAL 外部依赖提示（对应要求 7、8）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 打开一条 `state=UNKNOWN`/`FAILED` 的投递详情 | 出现 `[data-testid="m09-external-hint-not-actually-delivered"]`，描述含 **"状态：BLOCKED_EXTERNAL"** |
| 2 | 打开一条 `state=SUCCEEDED` 的投递详情 | **不**出现该提示条（成功态不骚扰） |
| 3 | 确认提示条文案 | 含"仅落了站内记录，未向外部通道真实投递"；**不得**出现"已通知到人" |
| 4 | actor 不可用 / 通道未核准文案核对 | 本批页面**不触发**这两条路径；文案已实现在 `m09-status.ts`，核对源码即可（不必构造数据） |

### 7.6 TC-NO-EXTERNAL-CALL 确认未触发真实外部调用（对应要求 9）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 全程 Network 面板过滤 `smtp`/`mail`/`sms`/`http` 出站请求 | **零**外部域名请求；只有本站 `/alarm/v2/*` 读口 |
| 2 | 打开/关闭详情抽屉、切列表 | 不得出现任何写请求（GET 之外的方法）；本批为纯只读展示 |
| 3 | Console | 无未捕获异常、无"模拟投递成功"类日志 |

### 7.7 TC-GUARD 守卫写回归（确认本批未破坏既有链路）

| 步 | 操作 | 期望 |
|---|---|---|
| 1 | 告警详情点"处理"/"忽略" | 仍走 `POST /alarm/v2/records/{id}/handle`，带 `X-Request-Id` / `X-Management-Revision`，body 含 `expectedVersion` |
| 2 | 版本漂移时提交 | 仍弹原"已被他人更新（版本已变化）"提示并阻止提交，**备注保留** |
| 3 | 缺版本时提交 | 仍弹"未取得管理版本或记录行版本，已阻止提交" |

### 7.8 测试数据建议

| 用途 | 建议值 | 说明 |
|---|---|---|
| 邮件投递（UNKNOWN） | 触发一次外部依赖不可用场景 | 验证"未知"不显示成成功 |
| 邮件/短信投递（SUCCEEDED） | 需现场通道已核准 | 若通道未核准 → **BLOCKED_EXTERNAL**，记录即可，**不得伪造** |
| 站内通知 | 正常触发 | 用于列表与详情打开 |
| 告警记录 | 触发一条含关联信息的告警 | 用于详情抽屉与 monitorAck 区块 |
| monitorAck 场景 | **无需真实数据**，用 DevTools 响应改写模拟（7.4 第 3–6 步） | 后端当前不产出可读 ACK |

**清理**：本批为只读展示，不新增数据。既有测试数据由work9 按上一批（`W1-M02-AC-01` 已软删）情况核对，**不在本批范围**。

### 7.9 每条用例必须交回

1. 页面名称与操作步骤；2. HTTP method + 完整 URL；3. request headers；4. response body；5. **页面关键区域截图（状态区/ monitorAck 区块/ 外部提示条）**；6. Console 是否有异常；7. 是否触发真实外部调用；8. 结论状态词（AGENTS.md §13.2 之一）。

禁止：以单元/契约测试或静态检查通过代替浏览器验收；不得用较低层级结果宣称较高层级完成。

---

## 八、work9 测试记录区

| 用例 | 结论状态 | 证据 | 备注 |
|---|---|---|---|
| TC-ENTRY 页面入口与菜单 | | | |
| TC-LIST 列表打开 | | | |
| TC-STATUS 状态展示 | | | |
| TC-MONITORACK monitorAck 展示 | | |重点：第 2 步应为"尚无确认"；第 7 步泄漏检查 |
| TC-EXTERNAL 外部依赖提示 | | | |
| TC-NO-EXTERNAL-CALL 无外部调用 | | | |
| TC-GUARD 守卫写回归 | | | |

---

## 九、最终结论区（work9 填写）

- 实际执行用例数 / 通过数：
- 分层结论（勾选）：`HTTP_VERIFIED` ☐ `BROWSER_VERIFIED` ☐ `NOT_VERIFIED` ☐
- 阻塞项（勾选）：`BLOCKED_DATA` ☐ `BLOCKED_MENU` ☐ `BLOCKED_DEPLOY` ☐ `BLOCKED_EXTERNAL` ☐ `BLOCKED_DESIGN` ☐
- **monitorAck 是否真的拿不到数据**（若看到完整 ACK 请注明）：
- 遗留数据与原因：
- 与本文档不符的实际行为（如有，注明用例号与差异）：
- 结论（禁止使用"全部完成"等笼统措辞）：

---

## 十、未验证 / 待裁决

1. **BLOCKED_DESIGN（需总控裁决）**：monitorAck 只写入不读出。是否在 M09 读口 VO 暴露**脱敏后**的 monitorAck 投影？前端已实现完整只读展示，随时可接。
2. **NO_UI**：监控策略页（API14）前端无页面。`presentExecutionAck()` 已备好口径，待裁决后补页面。
3. **BLOCKED_EXTERNAL**：外部通道未核准，邮件/短信/声光均未真实投递；本批未接任何外部调用。
4. **NOT_VERIFIED**：本批全部 HTTP、浏览器、数据库、外部系统与现场验收均未执行；**生产构建亦未执行**。
5. **投递尝试 `responseSummary` / `responseCode` 仍原样展示**：本批未改这两列。它们来自 `alarm_delivery_attempt`，契约上属于"同次尝试结果单向终结"的摘要，非正文/凭据；若 work9 认为仍需脱敏，请回传，本批可追加。
6. **既有背景红（他人 drift，未代改）**：`tests/monitor-log.test.ts` 4 红（本批零引用，已核）；`tests/localization.test.ts`、`tests/workflow-management.test.ts` 等仓库既有基线红。