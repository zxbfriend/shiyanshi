# M09 `INPUT_INVALID` 未登记码名族 — 逐项预检（只读，无修复）

- 预检日期：2026-10-03
- 提预检背景：work3 收口核验发现 P1「M09-003 / M09 主源码 `INPUT_INVALID` 未登记码名族」
- 预检性质：**只读预检**。不改 Java / Mapper XML / SQL / 契约测试 / 现行契约文档；本轮只新增本文件并本地提交，不 push。
- 预检范围边界：**本文件不是 `FORBIDDEN_OR_NOT_FOUND` 问题，不与 B1-B9 裁决材料包混编**；仅讨论 `INPUT_INVALID` 码名族的登记与对齐。
- 禁止项（本轮与后续批次均遵守）：不全局替换 `INPUT_INVALID`；不触碰已推送的 M09-002 / M09-021 结果；不把 M01 的 `INPUT_INVALID` 口径套到 M09。

---

## 0. 基线快照（本轮实测，非沿用旧预检）

| 项 | 实测值 |
|---|---|
| 仓库根 | `C:/Users/THINK/Documents/GitHub/yaoming-cloud` |
| HEAD | `e22f42c8cafca7bbd1f15f7ae5d76dc7a5902a4a` |
| origin/cloud（fetch 后） | `e22f42c8cafca7bbd1f15f7ae5d76dc7a5902a4a`（与 HEAD 同点） |
| merge-base(HEAD, origin/cloud) | `e22f42c8` |
| ahead / behind | **0 / 0**（本轮无分叉，纯同步态） |
| 暂存区 / 已跟踪工作区 | 空 / 0 |
| 未跟踪材料 | 27 项（`??`），未纳入本提交 |

行号全部以本轮 `e22f42c8` blob 实测复算；历史 review 材料只作线索，不覆盖现行权威契约。

---

## 1. `INPUT_INVALID` 在 M09 权威面是否有登记

**结论：M09 权威面未登记 `INPUT_INVALID`。**

| 权威面 | 实测 |
|---|---|
| `docs/详细设计/09-告警与通知管理/错误码全集.md` | `INPUT_INVALID` **0 命中**（未登记）；`VALIDATION_FAILED` 登记于 `:21`、`:26`，HTTP **400** |
| `docs/00-开发基线/最终API基线.md`（M09 段自 `:4328` 起） | M09 段内 `INPUT_INVALID` **0 命中**；`VALIDATION_FAILED` 出现 10 处（`:4335/4347/4358/4393/4405/4417/4429/4441/4453/4488`） |
| `docs/00-开发基线/最终设计闭环矩阵.csv` | M09 共 21 行错误码登记，`INPUT_INVALID` **0 命中**；行索引 512—532 |
| `docs/开发任务/00-全接口契约骨架清单.json` / `.md` | `INPUT_INVALID` 大量命中（.md 415 处、.json 415 处），但**全部落在 M01—M07 侧**；M09 契约条目（API03 / API04 / API20 等）错误码字段只列已登记码族 |

**重要口径（不套用 M01）**：`INPUT_INVALID` 在 M01 权威面是**已登记码** —— `docs/详细设计/01-系统管理/错误码全集.md:16` 明确 `| INPUT_INVALID | 400 | 输入类型、必填、范围、精度或日期无效；定位字段并保留输入 |`。因此本问题**不是「全系统未登记码」，而是「M09 模块未登记、M09 主源码仍在抛」**的模块内登记缺口。M01 的登记事实**不能**推出 M09 可继续使用，也不能据此免除 M09 的对齐义务。

**枚举事实**：`futurefab-api/futurefab-api-system/.../error/FutureFabErrorCode.java`
- `:215` `INPUT_INVALID("INPUT_INVALID", 400, …, false)`
- `:335` `VALIDATION_FAILED("VALIDATION_FAILED", 400, …, false)`

两码 **HTTP 同为 400**，且 `:59` / `:119` 的类注释均把二者列为 400 通道 → **码名对齐 = errorCode 字符串变化，HTTP 状态不变**。

---

## 2. M09 主源码 `INPUT_INVALID` 命中清单与接口归属（当前树实测，共 107 处）

命中分布（9 个 m09 服务实现文件）：

| 实现文件 | 涉及接口 | 命中数 | throw 站点（实测行号） |
|---|---|---|---|
| `AlarmRecordApplicationApplicationServiceImpl.java` | 001 / 002 / **003** | 17 | 003：`208,214,223,228,234,240,246` + helper `:667` 委托；001：`568,573,579,585,591,599,605` + `:615`；`:673` 为 javadoc 说明 |
| `AlarmMonitorPolicyApplicationApplicationServiceImpl.java` | 014 / 015 | 16 | 014：`92,97`；015：`166,172,177,189,196,202,208,280,316,334,338,377,389,398` |
| `AlarmNotificationApplicationApplicationServiceImpl.java` | 017 / 018 / 019 | 14 | 019：`178,190,195,207,214` + helper `500,509,520,530`；017：`452,457,463,468,477`；018：**0**（`getUnreadCount` 无命中） |
| `AlarmStatusConfigApplicationApplicationServiceImpl.java` | 008 / 009 | 15 | 008：`99,107,119`；009：`197,204,210,301,306,312,319,340,359,369,473,482` |
| `AlarmRuleApplicationApplicationServiceImpl.java` | **004** / 005 | 15 | 005：`164,170,222,252,258,264,270,279,288,376,394,398,408,417`；**004**：`596` |
| `AlarmSenderConfigApplicationApplicationServiceImpl.java` | 006 / 007 | 13 | 007：`106,116,122,128,135,266,452,463,468,479,483,532,541`；006：**0** |
| `AlarmOnlineConfigApplicationApplicationServiceImpl.java` | 010 / 011 | 10 | 010：`79,85,96,101,109,114,214,224,295,304`（读口 `getOnlineConfig` 含 `toOnlineRow:214/:224` 与 `parsePositiveDecimal:295/:304`）；011：**0**（`saveOnlineConfig` 仅抛 `SkeletonNotImplementedException("M09-011")`，无 `INPUT_INVALID` 命中） |
| `AlarmOfflineConfigApplicationApplicationServiceImpl.java` | 012 / 013 | 3 | 012：`71,190,199`（读口 `getOfflineConfig` 含 `parsePositiveDecimal:190/:199`）；013：**0**（`saveOfflineConfig` 仅抛 `SkeletonNotImplementedException("M09-013")`，无 `INPUT_INVALID` 命中） |
| `AlarmDeliveryApplicationApplicationServiceImpl.java` | **020** / 021 | 4 | **020**：`129,138`；021：**0**（已对齐，见 §4）；`:285`、`:424` 为说明性注释 |
| `AlarmSoundCommandApplicationApplicationServiceImpl.java` | 016 | 0 | — |

按接口汇总（throw 站点，未计注释/委托行）：

| 接口 | 方法 | 命中数 | 权威面是否已登记 `VALIDATION_FAILED` |
|---|---|---|---|
| M09-001 | `pageRecords`（经 `validatePageQuery` / `checkKeywordLength`） | 8 | ✅（CSV idx512） |
| M09-002 | `getRecord` | 0（已对齐，见 §4） | ✅（CSV idx513） |
| **M09-003** | **`handleRecord`** | **7 + 1 委托** | ✅（CSV idx514） |
| **M09-004** | `getRuleConfig`（经 `parseIntOrNull`） | **1** | ❌ **未登记**（CSV idx515） |
| M09-005 | `saveRules` | 14 | ✅（CSV idx516） |
| M09-006 | `getSenderConfig` | 0 | ❌ 未登记（CSV idx517）—无命中，无需动作 |
| M09-007 | `saveSenderConfig` | 13 | ✅（CSV idx518） |
| M09-008 | `getStatusConfig` | 3 | ✅（CSV idx519） |
| M09-009 | `saveStatusConfig` | 12 | ✅（CSV idx520） |
| M09-010 | `getOnlineConfig` | 10（6 形态 + `toOnlineRow:214/:224` + `parsePositiveDecimal:295/:304`） | ✅（CSV idx521） |
| M09-011 | `saveOnlineConfig` | 0（仅抛 `SkeletonNotImplementedException`，无 `INPUT_INVALID` 命中，移出可窄修清单） | ✅（CSV idx522） |
| M09-012 | `getOfflineConfig` | 3（1 形态 + `parsePositiveDecimal:190/:199`） | ✅（CSV idx523） |
| M09-013 | `saveOfflineConfig` | 0（仅抛 `SkeletonNotImplementedException`，无 `INPUT_INVALID` 命中，移出可窄修清单） | ✅（CSV idx524） |
| M09-014 | `getMonitorPolicy` | 2 | ✅（CSV idx525） |
| M09-015 | `saveMonitorPolicy` | 14 | ✅（CSV idx526） |
| M09-016 | `sound/off` | 0 | ✅（CSV idx527）—无命中，无需动作 |
| M09-017 | `pageNotifications`（经 `validatePageQuery`：`:452/:457/:463/:468/:477`） | 5 | ✅（CSV idx528） |
| M09-018 | `getUnreadCount` | 0 | ❌ 未登记（CSV idx529）—无命中，无需动作 |
| M09-019 | `markNotificationsRead`（含 `parsePositiveDecimal:500/:509`、`parseNonNegativeDecimal:520/:530` 四个 helper，经 `:209/:210/:288` 触发） | 9 | ✅（CSV idx530） |
| **M09-020** | `getDeliveryDetail` | **2** | ❌ **未登记**（CSV idx531） |
| M09-021 | `resendDelivery` | 0（已对齐） | ✅（CSV idx532） |

> 归属说明（避免误判）：`AlarmNotification...Impl` 的 `private void validatePageQuery`（`:448`—`:477`）实际调用点是 `pageNotifications`（`:114`），即归属 **M09-017**，不是 M09-018；M09-018 `getUnreadCount`（`:158`）无任何形态校验命中。另：`validatePageQuery` 之外的 `parsePositiveDecimal`（`:494`→`:500/:509`）、`parseNonNegativeDecimal`（`:515`→`:520/:530`）四个 parse helper 由 `markNotificationsRead`（`:209/:210/:288`）触发，归属 **M09-019**，不计入 017。

---

## 3. M09-003 `handleRecord` 形态校验逐项（重点）

`AlarmRecordApplicationApplicationServiceImpl.java`：

| 行 | 条件 | 性质 |
|---|---|---|
| `:208` | `command == null` | 纯形态（请求体非空） |
| `:214` | `expectedRaw == null` | 纯形态（必填） |
| `:223` | `Long.parseLong` 抛 `NumberFormatException` | 纯形态（非负整数字符串） |
| `:228` | `expectedVersion < 0` | 纯形态（取值范围） |
| `:234` | `action` 非 1/2 | 纯形态（枚举取值） |
| `:240` | `remark.length() > 500` | 纯形态（长度） |
| `:246` | `requestId == null` | 纯形态（幂等键必填） |
| `:667`→`:675` | `decimalId(raw,label)` 默认委托 `FutureFabErrorCode.INPUT_INVALID` | 委托点 |

**这 7 处全部位于守卫之前（`handleRecord` 自 `:203`，守卫入口在 `:260` 之后），属于纯入参形态校验**：不改变版本比较语义（版本比较在守卫内 CAS），不读库，不做权限判定（权限由守卫统一裁决），不产生审计与幂等副作用。改造只换 errorCode 常量，**HTTP 恒为 400**。

**委托关系关键事实（决定能否窄修）**：
- `:665-668` 两参 `decimalId(raw,label)` → 委托 `:675` 三参重载，**该两参重载的全部调用者只有 `:210`（M09-003 `handleRecord`）**；
- M09-002 的 `:171` 调用的是**三参重载**并显式传 `FutureFabErrorCode.VALIDATION_FAILED`（`:166` javadoc 亦写明「ID 形态拒绝取本接口登记的 VALIDATION_FAILED(400)」）。

→ **M09-003 与 M09-002 已通过重载分离，不存在「改一处影响 002」的耦合。**

**契约测试侧（`M09WiredRecordContractTest`）需同步改的断言**：
- `:990-997` 用例 `handleShapeRejectionStillUsesPreExistingCodeAfterDetailAlignment`：`:996` 断言 `service.handleRecord(shapeCommand("abc","0",1))` 返回 `INPUT_INVALID` —— 该用例标题与断言在 003 对齐后必然失效，须随批改；
- `:1098—1113`（9 条 `handleRecord` 形态断言）、`:1149`（另一条）。

> 注意不要与本文件混淆：`M09WiredRecordContractTest:956-967,980,1357` 已是 `VALIDATION_FAILED`（M09-002 对齐产物，来自已推送提交 `3b7ded84`），**本次不动**。

> **同文件 M09-001 提醒**：`M09WiredRecordContractTest` 同一测试文件还含 **M09-001** 的 7 条 `pageRecords` 形态断言（与 003 同文件但不同接口）。BATCH-1 改 003 时**只动 003 的断言（`:996,1098-1113,1149`），不得误改 001 的 7 条**；001 不在本码名族批次内。

---

## 4. 已完成的先例（只作先例，不反向推出其它接口结论）

| 先例 | 实现 | 证据 |
|---|---|---|
| **M09-002 详情形态校验** | ID 形态拒绝取 `VALIDATION_FAILED(400)` | 源码 `AlarmRecord...Impl:171`（三参重载）、`:166` javadoc；测试 `M09WiredRecordContractTest:956-967`、`:980` 断言 `assertEquals(400, shape.getHttpStatus())`、`:1357`；提交 `3b7ded84` |
| **M09-021 T12** | 缺 requestId / ID 形态 / 越界 → `VALIDATION_FAILED(400)`；非 FAILED 分支 → `DELIVERY_NOT_FAILED(409)` | 源码 `AlarmDelivery...Impl:220`（缺 requestId）、`:432`/`:441`（ID 形态/越界，经 `parsePositiveDecimal` helper，见 `:423-424` javadoc）；非 FAILED 分支 `:282-287`；测试 `M09WiredDeliveryResendContractTest:660` 断言 `DELIVERY_NOT_FAILED + 409`（「不再用未登记的 INPUT_INVALID」） |

> **先例归纳（M09-021 修正后）**：按调用点选择接口登记码，不全局替换——M09-021 的「非 FAILED」分支走 `DELIVERY_NOT_FAILED(409)`，**不是** `VALIDATION_FAILED` 先例；只有缺 requestId / ID 形态 / 越界才取 `VALIDATION_FAILED(400)`。

**可复用规则（5 条，从先例归纳，不是新权威契约）**：
1. 两码同为 400 → 对齐只变 `errorCode` 字符串，**HTTP 不变**，前端 400 分支不受影响；
2. 拒绝码在**调用点**选定，`decimalId` 一类 helper 已提供重载传参 → 不新增全局常量；
3. 对齐前须确认**该接口在权威面已登记目标码**；未登记的接口不得直接改；
4. 契约测试中断言 `errorCode` 的用例必须**同批改**；
5. **禁止全局替换**：`ManagementGuardExecutor:147/152/333/341`、`NormalizedPayloadHasher:104`（含 `:92` 复用同一拒绝常量）、`M05SignPreviewBodyAdvice:64` 也用 `INPUT_INVALID`，且守卫为**跨模块共享**（M01/M02 亦消费）；`common-core` / `common-security` 中的 `RequestMeta` / `WriteMeta` 相关使用点（如 `RequestMetaInvalidException`、写元校验拦截器）同样消费该码。全局替换会外溢到其它模块，本码名族严格按调用点逐一登记。

---

## 5. 可窄修项 / 不可窄修项

### 5.1 可窄修（权威面已登记 `VALIDATION_FAILED`，HTTP 400 不变，helper 不跨接口）
M09-001、M09-003、M09-005、M09-007、M09-008、M09-009、M09-010、M09-012、M09-014、M09-015、M09-017、M09-019。

其中涉及权限/上下文语义、**不建议当纯字符串替换**的两处（属「形态+策略」混合，建议单独复核后再动）：
- `AlarmNotification...Impl:457`「SELF 上下文不允许按接收人关键词筛选」、`:463`「site 通道不支持按投递状态筛选」、`:468`「email/sms 通道不支持按已读状态筛选」、`:477`「keyword 与 contentKeyword/recipientKeyword 不可同传」—— 与 017 查询上下文策略耦合；
- `AlarmNotification...Impl:207`「已读条目不得为 null」、`:214`（批量条目约束）—— 与 019 批量标读的条目规则耦合。

上述七处在 HTTP 层面仍是 400，但**文案与策略语义不变、只换码名**；如需进一步区分，应另立裁决，不在本码名族批次内处理。

> **数据异常 fail-closed 单列提醒**：M09-010 读口 `getOnlineConfig` 经 `toOnlineRow` 的 `:214`「evaluation_state 缺失」、`:224`「无法解析校验状态」属**服务端数据异常 fail-closed**（DB 脏值，非前端入参形态错误），不应归入「纯入参形态校验」窄修批次，须单列或另立裁决，不得与 010 其它纯形态命中混同批处理。M09-012 的 `:190/:199`（`parsePositiveDecimal`）为纯形态，可随 012 窄修。

### 5.2 不可窄修（权威面未登记 `VALIDATION_FAILED`，必须先裁决）
| 接口 | 命中 | 阻塞原因 | 可选路径 |
|---|---|---|---|
| **M09-004** `getRuleConfig` | 1（`:596`） | CSV idx515 = `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND`，无 `VALIDATION_FAILED`；`错误码全集` 亦无该接口登记 | ①先在 CSV/API 基线/骨架清单为 004 增列 `VALIDATION_FAILED`；②沿用 `INPUT_INVALID` 并同时补登记；③改用其它已登记码。**三选一须裁决** |
| **M09-020** `getDeliveryDetail` | 2（`:129`,`:138`） | CSV idx531 = `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, DEPENDENCY_UNAVAILABLE`，无 `VALIDATION_FAILED` | 同上 |

> M09-006（idx517）、M09-018（idx529）也未登记 `VALIDATION_FAILED`，但二者**源码 0 命中**，本轮无需动作，仅为「后续若新增形态校验」的登记提示。

### 5.3 共享 helper 是否阻断按接口窄修
- **003 可独立窄修**：`decimalId` 两参重载的唯一调用者是 003 的 `:210`（002 走三参）。✅
- **各文件内 helper 多为该文件的两个接口共用**（如 `parsePositiveDecimal` 同时服务读口与写口）。判定：只要该文件的**两个接口都登记了 `VALIDATION_FAILED`**，共用无风险；只要有一个未登记，就不得在该 helper 内统一替换 —— 此时应在调用点传参，而非改 helper 默认值。
- **跨模块共享的 `INPUT_INVALID` 使用点不得动**（守卫与 hasher，见 §4 规则 5）。
- **必须同步修订的说明性注释**：`AlarmRecord...Impl:670-674` 现写「M09 权威面…只给 M09-002 登记 VALIDATION_FAILED(400)…M09-003 写路径继续取原码」—— **该表述与当前 CSV 不符**（003 已登记 `VALIDATION_FAILED`，005/007/008/009/010/011/012/013/014/015/017/019 亦均已登记），属会误导后续实现的事实错误，须随 003 对齐一并更正。

---

## 6. 推荐批次顺序与最小文件白名单（建议拆批，非开工授权）

| 批次 | 内容 | 最小文件白名单 | 前置 |
|---|---|---|---|
| **BATCH-0** | 本预检文档落盘（仅登记，不决策） | 本 `history/review` 文件 | 无（本轮已完成） |
| **BATCH-1** | **M09-003**（7 处 + `:667` 委托 + `:670-674` 注释更正） | `AlarmRecordApplicationApplicationServiceImpl.java`；`M09WiredRecordContractTest.java`（`:996,1098-1113,1149`） | 无新增登记需求（003 已登记 VF）；**本批不依赖 B1-B9 行级可见性裁决**（纯码名，不动权限/版本/可见性）；⚠ 同测试文件含 **M09-001 的 7 条断言**，**改 003 时不得误改 001** |
| **BATCH-2** | 008/009 + 010、012 两个读口 | `AlarmStatusConfig / AlarmOnlineConfig / AlarmOfflineConfig …Impl.java` + 对应 3 个契约测试 | 各接口已登记 VF；间接依赖 B1-B9 的闸门序裁决（009 写口在守卫回调内）才决定是否顺带调整抛点位置；011/013 仅抛 `SkeletonNotImplementedException("M09-011"/"M09-013")`，无 `INPUT_INVALID` 命中，已移出本批次与可窄修清单 |
| **BATCH-3** | 005（AlarmRule）、007（AlarmSenderConfig） | 两个 Impl + `M09WiredConfigContractTest.java` | 已登记 VF；005 涉及整组校验与 `ROW_SCOPE_MISMATCH` 语义，须先确认 `B-1—B-9` 中同批口径 |
| **BATCH-4** | 014/015、017/019 | 两个 Impl + `M09WiredNotificationReadContractTest.java` | **建议在 B-1—B-9 裁决后**再动 019（其校验与 `expectedVersion`、SELF 身份上下文相邻） |
| **BATCH-5（受裁决阻塞）** | **004、020 的登记口径** | 先只裁决与登记：`最终设计闭环矩阵.csv`、`最终API基线.md`、骨架清单、错误码全集；裁决后再动 2 个 Impl | **必须先裁决**：004/020 未登记 `VALIDATION_FAILED`，禁止直接改码；不得顺手补登记 |
| 无动作 | 002、021（已对齐）、006、016、018（0 命中） | — | — |

**批次纪律**：不全局替换；不改守卫/hasher 等跨模块共享点；不改 M01 的 `INPUT_INVALID` 口径；不触碰已推送的 M09-002 / 021 结果；不随码名批次顺手改 SQL、可见性或权限。

---

## 7. 必须等 B1-B9 / 行级可见性裁决后再动的事项

1. **009 / 019 的抛点位置**：这些写口形态校验位于守卫 `doGuarded` 回调内或与之相邻，闸门序（B-4）裁决会影响「形态校验 vs 资格/状态判定」谁先返回；码名可在裁决后统一换，但**不要提前挪位置**。M09-011 / M09-013 写口仅抛 `SkeletonNotImplementedException`，无 `INPUT_INVALID` 命中，不参与本码名族批次。
2. **004 / 020 的登记口径**（BATCH-5）必须由需求方/授权设计人裁决，本文只登记不代决。
3. **管理员接收人资格、行级可见性**相关改动与本码名族正交，不得合并批次。

---

## 8. 本轮结论

- M09 权威面**未登记** `INPUT_INVALID`（`错误码全集` 0 命中；API 基线 M09 段、闭环矩阵、骨架清单 M09 条目亦均无）；M01 有登记，**不可套用**。
- M09 主源码共 **107 处**命中，覆盖 **14 个接口**（004、020 持未登记缺口；006/011/013/018 为 0 命中；011/013 仅抛 `SkeletonNotImplementedException`，无 `INPUT_INVALID` 命中，已移出可窄修清单）。
- **M09-003 的 7 处 + 1 委托是可窄修的**：纯入参形态校验、位于守卫之前、HTTP 400 不变、helper 已按接口分离、权威面已登记 `VALIDATION_FAILED`、契约测试断言同批改即可。
- **004 / 020 因权威面未登记，必须先裁决**；不得直接替换码名，也不得由本预检代作业务裁决。
- 共享 helper 分析结论：**003 可独立窄修**；全局替换被跨模块守卫阻断，明令禁止。
- 存在 1 处会误导后续实现的**事实错误注释**（`AlarmRecord...Impl:670-674`），须随 BATCH-1 更正。

---

## 9. 分层口径（本轮封顶）

- **STATIC_VERIFIED**：本文件全部 git 状态、行号、权威面登记核对、命中清单与接口归属、helper 调用关系、契约测试断言位置 —— 均经独立 `rg` / 源码读取 / CSV+JSON 解析 / 只读 git 命令核对，且全部以本轮 `e22f42c8` blob 复算。
- **NOT_VERIFIED / NOT_RUN**：**编译、契约测试、SQL、EXPLAIN、HTTP、浏览器、DB、Maven** —— 本轮**一项也未执行**。契约测试断言位置为静态定位，未运行。
- 特别声明：M09 仍受 `BLOCKED_MENU` / `NO_UI` 约束；本副本前端无 `/alarm/v2/*` 调用点**仅证明该副本未发现消费者，不构成无 HTTP 暴露的证据**。
- 本文为**预检材料**；真正业务/设计裁决仍归需求方或获授权设计负责人，本文不代决。

---

## 10. 勘误记录（work8 复核，2026-10-03，本提交）

本轮为同一 `history/review` 文档的**同文件勘误**，仅修正文档内错误归属与先例口径，不改任何 Java / Mapper XML / SQL / 契约测试 / 现行契约，不 push。基线提交 `e2be8aba`。

### 10.1 修复的 P1（work8 复核 3 条）
1. **M09-017 命中数错报（P1-1）**：§2 汇总表 `M09-017` 由 **9 → 5**（实际仅 `validatePageQuery` 的 `:452/:457/:463/:468/:477` 五处，唯一调用点 `pageNotifications:114`，归属 017）；`parsePositiveDecimal:500/:509`、`parseNonNegativeDecimal:520/:530` 四个 helper 改归 **M09-019**（经 `:209/:210/:288` 触发）。受影响处：§2 汇总表、§2 归属说明一并校正。
2. **M09-011 / M09-013 归属错误（P1-2）**：移除 011/013 的 `INPUT_INVALID` 命中归属（`saveOnlineConfig:188-190`、`saveOfflineConfig:136-138` 仅抛 `SkeletonNotImplementedException`）；原归 011 的 `:214/:224/:295/:304` 改归 **010** 读口，原归 013 的 `:190/:199` 改归 **012** 读口；接口数 **16 → 14**；§5.1 可窄修清单删除 011/013；§6 BATCH-2 由「010/011、012/013 同文件对」改为「**010、012 两个读口**」；§7 删除 011「抛点在守卫回调内需等闸门序裁决」表述；补充 `:214/:224` 属服务端数据异常 fail-closed 单列提醒。
3. **M09-021 先例标签错误（P1-3）**：§4 先例表修正——缺 requestId / ID 形态 / 越界走 `VALIDATION_FAILED(400)`，非 FAILED 分支走 `DELIVERY_NOT_FAILED(409)`（证据 `M09WiredDeliveryResendContractTest:660` 断言 `DELIVERY_NOT_FAILED + 409`），不再是「非 FAILED 取 VALIDATION_FAILED」先例；保留「按调用点选择接口登记码，不全局替换」归纳。

### 10.2 一并修复的 P2
- §5.1 行号文案错位：`:457`=SELF 上下文、`:463`=site 通道不支持按投递状态筛选、`:468`=email/sms 通道不支持按已读状态筛选、`:477`=keyword 互斥（原先 `:463/:468` 标签互换）。
- §4 共享点清单补充 `NormalizedPayloadHasher:92` 及 `common-core`/`common-security` 中 `RequestMeta`/`WriteMeta` 相关使用点，强化「禁止全局替换」。
- §3 / §6 提醒：`M09WiredRecordContractTest` 同文件含 **M09-001 的 7 条断言**，BATCH-1 改 003 时不得误改 001。

### 10.3 修正后关键口径
- **接口数**：14（原 16，移除 011/013 两个 0 命中 skeleton 写口）。
- **M09-017 命中数**：5；**M09-019 命中数**：9（5 内联 + 4 helper）。
- **M09-010 命中数**：10（原 6）；**M09-012 命中数**：3（原 1）；M09-011/M09-013：0。
- **BATCH-2 范围**：008/009 + 010、012 两个读口（不含 011/013）。
- **主源码命中总数仍为 107 处**（仅重归属，未增减）。

### 10.4 分层口径（本勘误封顶）
- **STATIC_VERIFIED**：所有行号、归属、计数、先例证据均经源码复算核对（含 `AlarmNotification`/`AlarmOnlineConfig`/`AlarmOfflineConfig`/`AlarmDelivery` 四个 Impl 实测）。
- **NOT_VERIFIED / NOT_RUN**：编译、契约测试、SQL、HTTP、浏览器、DB、Maven——本轮**一项也未执行**；Java 源文件**未改动**。
