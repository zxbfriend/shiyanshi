# M09 剩余 `FORBIDDEN_OR_NOT_FOUND` 使用点逐项预检（只读）

预检日期：2026-10-02。预检时点基线：`HEAD = origin/cloud = 0996bb6b`，跟踪区干净，暂存区空。
本文档只描述预检时点基线的事实；落盘时远端已前移（本提交受控 rebase 到 `f4e6501d` 之上），其中 `12b40bad` 已处理 021 形态校验错位，见 §5 发现① 的时点标注。

性质：**只读预检**。预检轮未修改任何 Java、XML、SQL、前端、Nacos 或网关文件，未提交实现（交付物仅本文件，按受控流程提交与推送）。
结论封顶口径：**静态核对通过（文档↔代码↔测试三方对齐检索）**。未编译、未跑测试（无代码变更，无必要）；HTTP/浏览器/数据库/外部系统一律 `NOT_VERIFIED`。

---

## 1. 权威依据与总体结论

按 `AGENTS.md` §3/§6 顺序取权威，未使用 history 覆盖现行契约：

1. `docs/README.md` → 现行权威入口登记；
2. `docs/详细设计/09-告警与通知管理/错误码全集.md`（契约版本 DD-20260913-R2）；
3. `docs/00-开发基线/最终API基线.md` 对应接口段；
4. `docs/00-开发基线/最终设计闭环矩阵.csv`（M09 行 513—533）与 `docs/开发任务/00-全接口契约骨架清单.md`（模块级接口逐条登记）；
5. 现行 Controller / ApplicationService / 契约测试中的实际抛码与断言。

**结论 A：`FORBIDDEN_OR_NOT_FOUND` 在 M09 全权威面零登记。**
- `错误码全集.md`（M09 现行 21 行码表）不含该码；`docs/详细设计/09-告警与通知管理/**` 全目录（含 `history/`）检索该字符串命中数为 0。
- `最终API基线.md` 与 `最终设计闭环矩阵.csv` 中该码只属于 M05（`## M05-*` 段，含 `M05-015/019/020/021/038…049` 等），骨架清单 JSON 的 45 处命中同样全部落在 M05 段。
- 因此 M09 代码里的 8 处 `FORBIDDEN_OR_NOT_FOUND` 是**跨模块借用的未登记码名**，不是 M09 契约口径。

**结论 B：M09 现行登记码对每个使用点都存在，且替换是 HTTP 状态中性的。**
`FutureFabErrorCode`（`futurefab-api/futurefab-api-system/src/main/java/com/futurefab/system/api/contract/error/FutureFabErrorCode.java`）：

| 码名 | 行号 | HTTP |
| --- | --- | --- |
| `FORBIDDEN_OR_NOT_FOUND` | 209 | 404 |
| `NOT_FOUND` | 237 | 404 |
| `INPUT_INVALID` | 215 | 400 |
| `VALIDATION_FAILED` | 335 | 400 |
| `ROW_SCOPE_MISMATCH` | 297 | 400 |
| `ALREADY_HANDLED` | 139 | 409 |
| `POLICY_UNVERIFIED` | 263 | 503 |

`FORBIDDEN_OR_NOT_FOUND → NOT_FOUND` 两码同为 404，外壳 `errorCode` 字符串变、状态码不变，属**低危窄修**（与已闭环的 M09-020 `8e0cc698`、M09-021 `501497f2` 同一口径）；文案必须逐字保持，以免削弱既有"不泄露存在性"断言。

**结论 C：`错误码全集.md` 中 `NOT_FOUND` 的登记语义正好覆盖这批使用点**：「不存在或无对象读取范围；不泄露真实对象」（404），即"越权与不存在同口径"本就由 `NOT_FOUND` 表达，无需 M05 的同义码。

**结论 D：M09-009 / 013 / 019 在 `最终API基线.md` 无独立接口段**（该文件 M09 只有 001/002/003/004/006/007/008/010/012/014/017/018/020/021）。这三个接口的登记错误码集合取 `最终设计闭环矩阵.csv` ＋ `00-全接口契约骨架清单.md`（两者逐字一致），再加 `错误码全集.md` 的码定义。这是登记落点差异，不是契约冲突。

---

## 2. 逐项预检表

M09 主源码 `FORBIDDEN_OR_NOT_FOUND` 命中 8 处，分布于 4 个应用服务实现，覆盖 6 个接口编号（013 无命中）。

| 接口编号 | 当前代码位置 | 当前错误码与 HTTP | 当前权威登记错误码 | 是否可窄修 | 是否改变 HTTP 状态 | 是否涉及权限/行级可见性/不泄露语义 | 推荐后续批次顺序 | 不允许顺手改的文件与逻辑 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **M09-002** GET `/alarm/v2/records/{alarmId}` | `AlarmRecordApplicationApplicationServiceImpl.java:185`（`getRecordDetail`，vo==null） | `FORBIDDEN_OR_NOT_FOUND` / 404 | `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED`（基线 4347；CSV 行514） | 可，替换为 `NOT_FOUND` | 否（404→404） | 是。可见域在 SQL：`AlarmRecordMapper.xml:168-176` 含 `alarmDataScope`；功能权限在 Controller `@RequiresPermissions("alarm:alarmRecord:query")`（`AlarmRecordV2Controller.java:49`）；不泄露文案「告警记录不存在或不可见」 | 批次 A（与 008/012 同批，最低风险） | 不改 `alarmDataScope` 与列表可见域；不给端点增删权限；不改详情扩展（factSnapshot/deliveryRows/links）；不改 `del_flag` 语义 |
| **M09-003** POST `/alarm/v2/records/{alarmId}/handle` | 同文件 `:271`（守卫提交后回读 current）、`:294`（`writeHandle` 无锁预读）、`:305`（`FOR UPDATE` 锁后） | `FORBIDDEN_OR_NOT_FOUND` / 404 | `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, VERSION_CONFLICT, IDEMPOTENCY_CONFLICT, ALREADY_HANDLED`（基线 4358；CSV 行515） | 码名可窄修；**行级可见性另需裁决**（见 §5 发现②） | 否（404→404） | 是，但**可见域缺口**：`selectAlarmRecordV2ById`（XML 179-183）与 `selectAlarmRecordForUpdate`（XML 307-318）均无数据范围过滤，越权判定只靠端点权限 `alarm:alarmRecord:handle`（Controller:60）。文案已统一为「告警记录不存在或不可见」，实际"不可见"当前不成立 | 批次 C（与可见性裁决同批或其后；不得只改码名就宣称越权口径闭合） | 不改 T04 锁序（runtime→record）、`ALREADY_HANDLED`/`VERSION_CONFLICT`/CAS、投递取消 `cancelPendingByAlarmId`、命令收据与 before/after 审计、幂等四元组；本轮不得往写 SQL 加范围条件 |
| **M09-008** GET `/alarm/v2/status-config` | `AlarmStatusConfigApplicationApplicationServiceImpl.java:136`（`getStatusConfig`，`countLabVisibleV2==0`） | `FORBIDDEN_OR_NOT_FOUND` / 404 | `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED`（基线 4405；CSV 行520） | 可，替换为 `NOT_FOUND` | 否（404→404） | 是。实验室可见性在 SQL（`countLabVisibleV2(labId, authAdmin, authUserId)`），命中前不读配置行；权限 `lab:statusalarm:list`（`AlarmStatusConfigV2Controller.java:36`）；测试断言文案不泄露授权细节 | 批次 A | 不改"先验可见性再读行"的次序；不改 `@CurrentManagementRevision` 回显；不改 `ConfigApplyState/ConfigOrigin` 推导；不动整组非分页约束 |
| **M09-009** PUT `/alarm/v2/status-config` | 同文件 `:268`（守卫回调 `writeStatusConfig` 内，落台账前） | `FORBIDDEN_OR_NOT_FOUND` / 404 | `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, ROW_SCOPE_MISMATCH, VERSION_CONFLICT`（CSV 行521；骨架清单 9529 段；**基线无该接口段**） | 可，替换为 `NOT_FOUND` | 否（404→404） | 是。同一 `countLabVisibleV2` 可见性判定在守卫事务内、任何写入前；权限 `lab:statusalarm:edit`（Controller:45）＋ `@ManagementGuardedWrite`；拒绝时零台账、零收据、零审计 | 批次 D（与 008 同文件，可合批但需在报告区分两接口断言） | 不改 `COALESCE(row_version,0)` CAS、整批全有或全无、STATUS 台账唯一审计主体、`alarm_operator='<'` 与 `ck_m09_close_status_ready` 约束；不引入审批链 |
| **M09-012** GET `/alarm/v2/offline-config` | `AlarmOfflineConfigApplicationApplicationServiceImpl.java:87`（`getOfflineConfig`，`selectCultureLabForRead==null`） | `FORBIDDEN_OR_NOT_FOUND` / 404 | `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED`（基线 4429；CSV 行524） | 可，替换为 `NOT_FOUND` | 否（404→404） | 是。培养→实验室可见性在 SQL（带 `authAdmin/authUserId`），未命中不读阈值行（测试断言只 1 次触库）；权限 `lab:offlinealarm:list`（`AlarmOfflineConfigV2Controller.java:34`）；文案「培养不存在或无权访问」 | 批次 A | 不改 `scope` 组装与 `revisionId/version/approvalId=null` 的已登记偏差；不改 `enabled` 旧库编码映射（0→true/1→false/NULL→null）；不改 `editable=AuthUtil.hasPermi` 裁剪 `allowedActions` |
| **M09-013** PUT `/alarm/v2/offline-config` | **无使用点**：`saveOfflineConfig` 仍显式 501（`AlarmOfflineConfigApplicationApplicationServiceImpl.java:135-139`，`SkeletonNotImplementedException`） | 当前抛 501，不涉及该码 | `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, ROW_SCOPE_MISMATCH, VERSION_CONFLICT, IDEMPOTENCY_CONFLICT, POLICY_UNVERIFIED, DEPENDENCY_UNAVAILABLE`（CSV 行525，最终状态 `MISSING`；骨架清单 9597 段） | **不适用**（无码可替） | 不适用 | 不适用；实现时可见性失败必须直接用登记的 `NOT_FOUND`，不得再借 M05 同义码 | 批次 E（属 013 放行本身的前置阻塞：`alarm_config_revision` 台账、M06_SC046 审批链、整组修订 CAS 证据），**与错误码口径批次解耦** | 本轮不得实现 013；不得动 `selectCultureOfflineConfigForUpdate/insertConfigRevision/applyDirectRevision`；不得伪造审批链或修订台账；不得为"消码名"而部分放行 |
| **M09-017** GET `/alarm/v2/notifications` | **无使用点**（017 读链抛码为 `pageSiteNotifications` 的 `FORBIDDEN:406` 与 `validatePageQuery` 的 `INPUT_INVALID:452-477`，见 `AlarmNotificationApplicationApplicationServiceImpl.java`） | 不涉及该码 | `UNAUTHENTICATED, FORBIDDEN, VALIDATION_FAILED, DEPENDENCY_UNAVAILABLE`（基线 4453；CSV 行529）——**该接口未登记 `NOT_FOUND`** | **不适用** | 不适用 | 列表读按可见域返回集合，无单对象 404 语义；不得给分页查询补 `NOT_FOUND` | 无需批次 | 不得把 `M09WiredRecordContractTest` 的 404 断言误当作 017 口径；不得给 017 增登记码；不动受控明文搜索容量上限与解密匹配边界 |
| **M09-019** POST `/alarm/v2/notifications/read` | `AlarmNotificationApplicationApplicationServiceImpl.java:285`（守卫回调内，`selectNotificationsForUpdate` 未命中该 notifyId） | `FORBIDDEN_OR_NOT_FOUND` / 404 | `UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, VERSION_CONFLICT, IDEMPOTENCY_CONFLICT`（CSV 行531；骨架清单 9699 段；**基线无该接口段**） | 可，替换为 `NOT_FOUND` | 否（404→404） | 是，且**闭合**。收件人归属在 SQL（`selectNotificationsForUpdate(notifyIds, actorUserId)`），越权与不存在回同一码同一文案、整组拒绝不静默跳过；端点无 `@RequiresPermissions`（SELF 由身份约束，ADMIN 路径 `:184` 显式 `FORBIDDEN` 关闭） | 批次 B（SELF 路径已裁决放行 2026-10-02，单接口单文件，风险次于批次 A） | 不改 ADMIN 路径的 `FORBIDDEN` 门禁与措辞；不改 `expectedVersion` CAS、`COALESCE(row_version,0)`、已读不改首次 `read_time`、版本不递增；不改命令收据/幂等重放；不补 `smp:notification:edit` 菜单权限种子 |

### 测试侧配套断言（同批窄修需一并改，逐点定位）

| 接口 | 测试位置 | 内容 |
| --- | --- | --- |
| 002 | `M09WiredRecordContractTest.java:117`（类注释）、`:937`（码名＋404 断言）、`:1309`（MockMvc `$.errorCode` 值＋`status().isNotFound()`） | 3 处 |
| 003 | 同文件 `:1239`（码名，另断言"不存在目标不得锁 runtime、零更新、事务回滚"） | 1 处 |
| 008 | `M09WiredStatusOnlineConfigContractTest.java:667`（码名＋文案不泄露＋只 `countLabVisibleV2` 触库） | 1 处 |
| 009 | 同文件 `:757`（码名＋零台账/零审计/1 次回滚） | 1 处 |
| 012 | `M09WiredOfflineMonitorConfigContractTest.java:613`（码名＋只 1 次触库） | 1 处 |
| 019 | `M09WiredNotificationReadContractTest.java:1369`（码名，说明"越权与不存在同口径，不静默跳过"） | 1 处 |

合计主源码 8 处、测试 8 处（另有 1 处 javadoc）。**已知非命中项**：`M09WiredDeliveryResendContractTest` 与 `AlarmDeliveryApplicationApplicationServiceImpl` 已无该码（020 `8e0cc698`、021 `501497f2` 闭环）。

---

## 3. 不在本模块范围的同码使用点（仅登记，禁止在本模块批次改动）

`FORBIDDEN_OR_NOT_FOUND` 是 **M05 登记码**，以下使用点属其自身权威口径，M09 窄修批次不得触碰：

- M05 主源码：`DetRecordApplicationServiceImpl.java:131,176,215,444`；`DetWorkbenchApplicationServiceImpl.java:144,194,263`；`SignActionConfirmation.java:67,137`；`domain/dto/m05/ReportJobDetailQuery.java:9`（javadoc）。
- M03 跨模块身份事实策略（字符串常量，非枚举借用）：`service/support/m03/MemberIdentityFactsPolicy.java:57`（`RC_FORBIDDEN_OR_NOT_FOUND`）、`:167`、`:273`；配套测试 `M03MemberIdentityFactsContractTest.java:127,214`、`MemberIdentityFactsAdapterContractTest.java:283`。
- M05 测试断言若干：`M05SignConfirmationTest`、`M05SignPreviewWiringTest`、`M05WiredRecordOptionContractTest`、`M05WiredRecordReadContractTest`、`M05WiredWorkbenchReadContractTest`。

M03 该常量为 Port 契约的 reasonCode 字符串，改名等同跨模块契约变更，需另立轮次。

---

## 4. 推荐批次顺序与理由

1. **批次 A（3 个只读接口，状态中性，可见性已在 SQL 闭合）**：002 / 008 / 012 → `NOT_FOUND`，含各自 5 处测试点与 1 处 javadoc。
2. **批次 B（1 个守卫写接口，口径已闭合）**：019 → `NOT_FOUND`，1 处测试点；与已裁决的 SELF 路径同文件，回归半径最小。
3. **批次 C（写路径 + 可见性裁决）**：003 三处 → `NOT_FOUND`；**先取得行级可见性裁决**（见发现②），否则只算码名对齐，不得宣称"越权同 404"已成立。
4. **批次 D**：009 → `NOT_FOUND`（与 008 同文件；建议与批次 A 分离提交，保持"一接口一断言集"可复核）。
5. **批次 E**：013 保持 501，实现轮直接使用 `NOT_FOUND`；不安排替换批次。
6. 全程禁止全局替换：8 处主源码分属 6 个接口，登记集合互不相同（003 有 `ALREADY_HANDLED`、009/013 有 `ROW_SCOPE_MISMATCH/POLICY_UNVERIFIED`、017 无 `NOT_FOUND`）。

---

## 5. 附带发现（只登记，不在预检轮修改）

① **P2｜`INPUT_INVALID` 同属 M09 未登记码**（与已登记的 `VALIDATION_FAILED` 400 / `ROW_SCOPE_MISMATCH` 400 同状态）。预检时点基线（`0996bb6b`）的 4 个应用服务大量形态校验抛 `INPUT_INVALID`：`AlarmNotificationApplicationApplicationServiceImpl.java:178,190,195,207,214,452,457,463,468,477,500,509,520,530`、`AlarmStatusConfigApplicationApplicationServiceImpl.java:100,108,120,198,205,211`、`AlarmOfflineConfigApplicationApplicationServiceImpl.java:71,190,199`、`AlarmRecordApplicationApplicationServiceImpl.java:208,214,223,228,234,240,246`。
**M09-021 的 T12 形态校验残留不作为当前树事实**：那是预检时点旧基线（`0996bb6b`）的残留，已由后续提交 `12b40bad`（`fix(m09): 对齐 M09-021 形态校验错误码为契约登记的 VALIDATION_FAILED`，已在 `origin/cloud`）处理 —— resend 的缺 `requestId` 与正十进制解析改判 `VALIDATION_FAILED`，且该 helper 已收窄为仅服务 resend。仍在登记范围内的同码残留是 **M09-020 读口**：远端 tip 的 `AlarmDeliveryApplicationApplicationServiceImpl#getDeliveryDetail`（`:129` 缺 deliveryId、`:138` 形状非法）仍抛 `INPUT_INVALID`。替换与否属独立裁决（`INPUT_INVALID → VALIDATION_FAILED` 同为 400，但 `INVALID_ARGUMENT` 也在 M09 登记为 400，需逐接口选定一个），不得为改 020 而使 021 已收口的口径漂移。

② **P1｜M09-003 写路径行级可见性缺口**：`selectAlarmRecordV2ById`（XML 179-183）与 `selectAlarmRecordForUpdate`（XML 307-318）无数据范围条件，`writeHandle` 与守卫后回读因此可命中列表可见域之外的记录，而文案与测试都写"不可见"。与 021 轮登记的 `selectDeliveryResendLock` 行级可见性同类，但 003 影响面更大（写 + CAS + 投递取消 + 审计）。收紧需在 Mapper 增加范围参数并改 XML，属跨层变更，**必须由裁决指定**，不得随错误码批次顺手改。

③ **P2｜CSV/骨架清单登记的实现类路径与代码现状漂移**：CSV 行514/515/520/521/524/525/529/531 记 `com.futurefab.system.service.impl.AlarmXxxApplicationServiceImpl`，实际类在 `com.futurefab.system.service.impl.application.m09.AlarmXxxApplicationApplicationServiceImpl`。属文档定位漂移，不影响错误码口径；应在文档维护轮统一，不得为此改代码包结构。

④ **P2｜`最终API基线.md` 缺 M09-005/009/011/013/015/016/019 接口段**（本轮预检涉及 009/013/019）。当前取 CSV＋骨架清单＋`错误码全集.md` 三源一致即视为登记成立；基线补段应由文档轮负责，实现轮不得自行"补码"。

---

## 6. 口径声明

- 本轮交付物只有本文件；可宣称完成：`静态核对通过（只读预检）`。
- 未做：编译、契约测试、SQL 执行、HTTP、浏览器、外部系统/设备、现场验收 —— 全部 `NOT_VERIFIED`。
- M09 全模块继续受 `BLOCKED_MENU` 约束（`docs/开发基线/02-基础数据初始化.sql` 无告警菜单/权限种子），002/003/008/009/012/019 的 HTTP 与浏览器验收在任何窄修批次后仍封顶 `IMPLEMENTED + CONTRACT_TESTED`。
- 013 维持 `BLOCKED`（缺整组修订台账与审批链证据），011 维持既有 `KEEP_501` 裁决，019 ADMIN 路径维持 `BLOCKED_MENU`。
- 后续批次必须逐接口执行"权威登记核对 → 单点替换 → 同点断言同步 → 实跑该接口契约测试 ＋ 邻近回归（带 `-am`）"，禁止全局替换，禁止把码名对齐说成越权闭合。
