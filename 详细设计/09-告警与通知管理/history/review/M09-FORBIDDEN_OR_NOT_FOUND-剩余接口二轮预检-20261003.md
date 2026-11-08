# M09 剩余 `FORBIDDEN_OR_NOT_FOUND` 使用点二轮只读预检（窄修批次边界）

预检日期：2026-10-03。基线：`HEAD = origin/cloud = 52d4156e`（`git rev-list --left-right --count origin/cloud...HEAD` = `0 0`，无分叉）。
跟踪区无修改（`git status --short` 仅 84 项未跟踪材料，全部保留、未清理、未 `git add`）；暂存区空。除本文件外本轮不新增/修改任何文件。

性质：**只读预检**。未修改 Java/XML/SQL/skeleton/菜单/前端/Nacos/网关，未执行 SQL，未发 HTTP，未做浏览器测试。
结论封顶口径：**`STATIC_VERIFIED`（文档↔基线↔骨架↔源码↔测试五方静态对齐）**。编译/契约测试/SQL/HTTP/浏览器/DB/外部系统一律 `NOT_VERIFIED`。

---

## 0. 范围与排除（按任务书执行，未自行扩范围）

**本轮只预检 M09 主源码与 M09 契约测试中残留的 `FORBIDDEN_OR_NOT_FOUND`。** 明确排除：

| 排除项 | 排除理由（事实来源） | 本轮动作 |
| --- | --- | --- |
| M09-002 的 `INPUT_INVALID` / `VALIDATION_FAILED` 形态校验口径 | 归 work2 | 不盘点、不判定、不提批次 |
| M09-002 / 008 / 012 | 已由 `ec0bb25e`（`fix(m09): 对齐 M09-002/008/012 读口错误码为契约登记的 NOT_FOUND`，2026-10-03 00:02）处理并在当前树核实为 `NOT_FOUND` | 只登记"已闭环"，**不重复开发** |
| M09-019 | 已由 `52d4156e`（2026-10-03 07:44）处理并核实 | 同上 |
| M09-020 / 021 | 第一轮已登记为 `8e0cc698` / `501497f2` 闭环，当前树该目录检索无该码 | 同上 |
| M09-009 | work7 在途实现 | 只判定窄修条件并登记，**不提实现、不改文件** |
| M09-003 | work3 已归档为"需裁决"（`M09-003-写路径行级可见性与授权边界预检-20261003.md` §5 B-6/B-7/B-9） | 仅登记"仍需裁决"，**不提出实现方案** |
| M05 / M03 自身登记口径中的该码 | `FORBIDDEN_OR_NOT_FOUND` 是 M05 登记码；M03 是 Port reasonCode 字符串常量 | 只列归属，禁入本模块批次 |

**任务范围冲突检查结论：无冲突。** 本轮交付物是一份新的 `history/review` 预检文档，与 work2（002 形态校验）、work7（009 实现）、work3（003 裁决材料）的在途文件集不重叠；本工作树 HEAD 未见其未提交改动。

---

## 1. 权威依据链（AGENTS.md §3 顺序，逐条实际打开）

1. `docs/README.md`（更新时间 2026-10-01，36 行）—— 日常入口已瘦身为 `01-需求文档.md` ＋ `02-详细设计.md` 两份，`详细设计/`、`00-开发基线/`、`开发任务/` 在 §11 登记为"证据和专题细节"。
2. `docs/02-详细设计.md`（版本 `DESIGN-20260925`）—— §5.9 M09 告警与通知职责；§2/§6/§7 应用查询端口做对象范围校验、写入口事务内重验权限/状态/版本/幂等；§10 验证分层口径。
3. M09 模块现行文件：`详细设计.md`、`接口目录与契约定位.md`（API03 行 23、API09 行 59）、`页面与接口契约.md`（`:109` 统一外壳行：`UNAUTHENTICATED / FORBIDDEN / NOT_FOUND｜401/403/404，按统一存在性隐藏策略`）、`错误码全集.md`（契约版本 `DD-20260913-R2`，21 行码表，`:18` = `NOT_FOUND｜404｜不存在或无对象读取范围；不泄露真实对象`）。
4. `docs/00-开发基线/最终API基线.md` —— `# M09（14 条）` 段自 `:4326` 起，接口段仅 001/002/003/004/006/007/008/010/012/014/017/018/020/021（**无 009/013/019 段**，与第一轮结论 D 一致）。
5. `docs/00-开发基线/最终设计闭环矩阵.csv` —— M09 行 513—533。
6. `docs/开发任务/00-全接口契约骨架清单.md` —— `## M09`（21 个接口）段自 `:9385` 起；009 段 `:9529`，错误码行 `:9542`。
7. `futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m09.json`（`expectedCount=21`，3405 行）—— 结构字段为 `id/wired/verb/path/ctrlFq/method/perm/svcFq/implFq/reqFq/respTypeFq/reqFields`，**不含错误码字段**：该码在本文件命中 0，`NOT_FOUND` 同样命中 0。→ 该文件只能作骨架/接线事实源，**不能作错误码口径来源**（登记落点事实，非冲突）。
8. 当前源码与契约测试（行号 §2 逐项列出，均以本轮读到的当前树为准）。

**结论 1：M09 全权威面对 `FORBIDDEN_OR_NOT_FOUND` 零登记。**

| 权威面 | 该码命中 | 命中归属 |
| --- | --- | --- |
| `docs/详细设计/09-告警与通知管理/**`（非 `history/`） | **0** | — |
| `最终API基线.md`（27 处） | 全部在 `:3731—:4030`，位于 `# M05（38 条）` 段（`:3722`）；M09 段（`:4326` 起）**0** | M05 |
| `最终设计闭环矩阵.csv`（45 处） | 全部在 `:399—:462`，模块列均为 `M05 检测与数据签批`；`grep FORBIDDEN_OR_NOT_FOUND \| grep M09` = **0** | M05 |
| `00-全接口契约骨架清单.md`（45 处） | 全部 `:7341—:8412`，M09 段自 `:9385` → **0**；`.json` 同 45 处同段 | M05 |
| `skeleton-m09.json` | **0**（不登记错误码） | — |

**结论 2：M09 每个残留点的应然码在登记集合中都已存在，且替换是 HTTP 状态中性的。**

| 接口 | 登记错误码集合（来源） | 含 `NOT_FOUND` | 含该码 |
| --- | --- | --- | --- |
| M09-003 `POST /alarm/v2/records/{alarmId}/handle` | `UNAUTHENTICATED、FORBIDDEN、NOT_FOUND、VALIDATION_FAILED、VERSION_CONFLICT、IDEMPOTENCY_CONFLICT、ALREADY_HANDLED`（CSV 行 515） | 是 | 否 |
| M09-009 `PUT /alarm/v2/status-config` | `UNAUTHENTICATED、FORBIDDEN、NOT_FOUND、VALIDATION_FAILED、ROW_SCOPE_MISMATCH、VERSION_CONFLICT`（CSV 行 521 ＋ 骨架清单 `:9542`，逐字一致） | 是 | 否 |

**结论 3（本轮新增关键事实，决定"文案不变"可判）：`ManagementGuardExceptionHandler` 的渲染语义使码名替换只改 `errorCode`。**
`service/guard/ManagementGuardExceptionHandler.java:32-44`（`@Order(HIGHEST_PRECEDENCE)`，显式避开 common-security 泛化 500 分支）：

```java
AjaxResult body = new AjaxResult(e.getHttpStatus(), e.getMessage()).put("errorCode", e.getErrorCodeValue());
return ResponseEntity.status(e.getHttpStatus()).body(body);
```

配合 `ManagementGuardRejectException.java:49-50`（`super(message)`）与 `:71/:77`（`errorCode` 取枚举 `getCode()`、`httpStatus` 取枚举 `getHttpStatus()`）：`msg` 来自抛点字面量，HTTP 来自枚举。而 `FutureFabErrorCode.java:209` `FORBIDDEN_OR_NOT_FOUND(..., 404, ...)` 与 `:237` `NOT_FOUND(..., 404, ...)` **同为 404**。因此 `FORBIDDEN_OR_NOT_FOUND → NOT_FOUND` 的实际差集只有响应体 `errorCode` 字符串；HTTP 状态与 `msg` 逐字不变。
另核：`futurefab.error.*` 两个 `messageKey` 在仓库内**无任何 `.properties/.yml/.json` 资源命中**（仅枚举内登记）→ 替换不涉及消息资源同步。

---

## 2. 剩余命中清单（分来源层，行号为当前树实测）

主源码 M09 命中 **4 处 / 2 文件 / 2 接口编号**；测试 **2 处 / 2 文件**；现行文档 **0**；历史与基线文档命中不参与口径判定。

| 层 | 文件:行 | 内容 | 接口 | 状态 |
| --- | --- | --- | --- | --- |
| 主源码 | `service/impl/application/m09/AlarmRecordApplicationApplicationServiceImpl.java:271` | 守卫提交后事务外回读 `current == null` | M09-003 | 残留（work3 裁决） |
| 主源码 | 同文件 `:294` | `writeHandle` 无锁预读 `pre == null` | M09-003 | 残留（work3 裁决） |
| 主源码 | 同文件 `:305` | `selectAlarmRecordForUpdate` 锁后 `locked == null` | M09-003 | 残留（work3 裁决） |
| 主源码 | `service/impl/application/m09/AlarmStatusConfigApplicationApplicationServiceImpl.java:268` | 守卫回调内 `countLabVisibleV2 == 0`（落台账前） | M09-009 | 残留（work7 在途） |
| 测试 | `src/test/.../contract/M09WiredRecordContractTest.java:1239` | `handleOfMissingRecordIsForbiddenOrNotFoundBeforeAnyLock` 码名断言（同法还断 0 次 runtime 锁、0 更新、`revision=10`、零收据/零审计、1 次回滚） | M09-003 | 残留 |
| 测试 | `src/test/.../contract/M09WiredStatusOnlineConfigContractTest.java:757` | 可见性未命中码名断言（同法还断零台账、零收据/零 operLog/零 changeLog、1 次回滚） | M09-009 | 残留 |
| 定义 | `futurefab-api/.../contract/error/FutureFabErrorCode.java:56, 209` | 枚举常量与 javadoc（404，标注"M05 及共用模块"） | 跨模块 | **保留，不得删除**（M05 主源码 `DetRecordApplicationServiceImpl:131,176,215,444`、`DetWorkbenchApplicationServiceImpl:144,194,263`、`SignActionConfirmation:67,137`、`domain/dto/m05/ReportJobDetailQuery:9` 仍在用） |
| 文档（现行） | M09 模块目录非 `history/` | 0 命中 | — | 无需批次 |
| 文档（基线/骨架） | `最终API基线.md`、`最终设计闭环矩阵.csv`、`00-全接口契约骨架清单.md/.json` | 27 / 45 / 45 / 45 处，全部 M05 段 | M05 | 禁入 M09 批次 |
| 文档（历史） | `history/review/M09-FORBIDDEN_OR_NOT_FOUND-剩余接口逐项预检-20261002.md`(14)、`history/review/M09-003-...-20261003.md`(4)、`03-项目与培养管理/history/review/二次复核-M03-f429cea3-20260929.md`(1)、`05-检测与数据签批/{错误码全集(1),详细设计(1),受控更正逐接口契约(2),history/review/M05-剩余功能开发验证记录(1)}` | 证据线索，不作权威 | M05/M03/M09 | 只读 |
| 未跟踪材料 | 仓库根 `M09-019-SELF-本地提交复核.md`(2) | 其它代理在途材料，非仓库内容 | — | 保留不动、不纳入提交 |

**已闭环对照（防重复开发，逐一在当前树核实）**：002 读口 `:185 NOT_FOUND`；008 读口 `:136 NOT_FOUND`；012 读口 `AlarmOfflineConfigApplicationApplicationServiceImpl.java:87 NOT_FOUND`；019 `AlarmNotificationApplicationApplicationServiceImpl.java:285 NOT_FOUND`；对应测试 `M09WiredRecordContractTest:937`（并新增 `assertEquals(404, ...)`）、`M09WiredStatusOnlineConfigContractTest:667`、`M09WiredOfflineMonitorConfigContractTest:613`、`M09WiredNotificationReadContractTest:1369` 均已改判 `NOT_FOUND`。

**无码可替项**：M09-013 `PUT /alarm/v2/offline-config` 仍显式 501（`AlarmOfflineConfigApplicationApplicationServiceImpl.java:135-139` `SkeletonNotImplementedException("M09-013")`）；M09-011 维持 `KEEP_501` 裁决。第一轮已判定 017（列表读，无单对象 404 语义，且未登记 `NOT_FOUND`）不适用，本轮复核无变化。

---

## 3. 残留点逐项判定（接口 / 读写 / SELF-ADMIN 分支 / SQL 事实源 / 窄修条件）

| 维度 | **M09-009**（`:268`，1 处） | **M09-003**（`:271/:294/:305`，3 处） |
| --- | --- | --- |
| 端点 | `PUT /alarm/v2/status-config`，`AlarmStatusConfigV2Controller:45-47` = `@RequiresPermissions("lab:statusalarm:edit")` ＋ `@ManagementGuardedWrite` ＋ `@PutMapping` | `POST /alarm/v2/records/{alarmId}/handle`，`AlarmRecordV2Controller:60-61` = `@RequiresPermissions("alarm:alarmRecord:handle")` ＋ `@ManagementGuardedWrite` |
| 读/写性质 | 守卫写，拒绝发生在 `guardExecutor.execute(...)` 回调内、`alarmConfigRevisionService.recordApplied(...)`（`:274`）之前 → 零台账、零 CAS、零审计 | 守卫写：`:294` 与 `:305` 在回调内（锁序 T04：runtime→record），`:271` 在**守卫事务提交后**、`receipt()` 装配前（响应回读） |
| 可见性事实源 | `mapper/lab/LabStatusAlarmConfigMapper.xml:261-267 countLabVisibleV2`：`lab_lab.lab_id = #{labId} AND del_flag='0'` ＋ `:254-258 statusLabScope`（`authAdmin` 为空或 false 时 `lab_id IN (SELECT lab_id FROM sys_user_lab WHERE user_id=#{authUserId})`） | `mapper/alarm/AlarmRecordMapper.xml:179-183 selectAlarmRecordV2ById`（`where t.del_flag='0' and t.alarm_id=#{alarmId}`）与 `:307-319 selectAlarmRecordForUpdate`（`where alarm_id=#{alarmId} and del_flag='0' for update`）——**均无数据范围条件**；`:178` 注释自述"不加数据权限范围；偏差登记批次报告" |
| SELF/ADMIN 分支 | 有，且是**可见域**分支（`statusLabScope` 的 `authAdmin` 真/假两支），与 008 读口同一谓词（`AlarmStatusConfigApplicationApplicationServiceImpl:134`）。无 SELF/ADMIN 语义枚举 | 无 SELF/ADMIN 分支登记。契约的"SELF"层是**接收人资格**（`详细设计.md:57`：本人稳定ID ∈ 该告警接收人集合，仅 `recipient_state=KNOWN_EMPTY` 可退让）——work3 文档 A-2 已证实写路径全缺该闸；`alarmDataScope:68` 的 admin 分支只服务 001/002 读口，**不作用于** `:179`/`:307` 两条语句 |
| "不存在或无对象读取范围"语义是否被 SQL 支撑 | **支撑**。未命中即 0，判定在任何配置行读取与台账写入之前；文案「实验室不存在或无权访问」不泄露授权细节（008 已有对应不泄露断言 `:668`） | **不支撑**（`:271/:294/:305` 三条路径都可能命中列表可见域之外的行，"不可见"当前不成立）。同码同文案的读口 002 才真正具备该语义（`selectAlarmRecordDetail` 含 `alarmDataScope`） |
| 是否满足"仅码名替换、HTTP 状态与文案不变" | **满足**：枚举两码同 404（结论 3）、`msg` 来自抛点字面量不动、谓词与调用序不动、M05 仍用原码故枚举不动 | **码名层面同样满足**（同 404、文案不动），但**不具备独立窄修条件**：只改码名会把"不可见"写进口径，与 §3 work3 结论冲突 |
| 本轮结论 | 具备窄修条件，**但归 work7 在途，本轮不改**；以批次 R1 交 work6/work7 复核执行 | **必须先行裁决**（B-6 拒绝码分层、B-7 同权限旧入口、B-9 管理员资格豁免、A-2 接收人资格闸）；本轮只登记"仍需裁决"，不提出实现 |

补充事实（支持"无 helper 外溢"判定）：`check_index_coverage`（project `D-Code-zhixianweilai-yaoming-cloud`，generation `2026-10-03T00:08:02Z`，7 个证据路径 `no_recorded_issue`、freshness `metadata_changed` → 结论以源码为准）＋ `trace_path(direction=inbound)` 显示 `writeStatusConfig` 与 `writeHandle` 各只有 2 个调用方（自身应用服务方法 → 对应 V2 Controller），即四处抛点**均为内联，无共享 helper 外溢**；同文件同谓词的另一支（008）已由 `ec0bb25e` 改判，不产生跨接口连带断言。

---

## 4. 推荐批次顺序与每批最小文件白名单（本轮不执行）

前提：禁止全局替换（四处抛点分属 2 个接口，登记集合互不相同：003 有 `ALREADY_HANDLED`、009 有 `ROW_SCOPE_MISMATCH`）；禁止把码名对齐说成越权闭合。

**R1｜M09-009 码名对齐（窄修，1 行主源码 ＋ 1 处断言）**
- 属主：work7（其 009 实现批次内顺带，或收口后单独一次提交）；本轮**不执行**。
- 白名单（2 文件）：
  1. `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/application/m09/AlarmStatusConfigApplicationApplicationServiceImpl.java`（仅 `:268` 一行枚举名）
  2. `futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/contract/M09WiredStatusOnlineConfigContractTest.java`（仅 `:757`；建议同法补一条 `assertEquals(404, e.getHttpStatus())`，口径照 `52d4156e`）
- 禁入：`LabStatusAlarmConfigMapper.xml`（含 `statusLabScope`/`countLabVisibleV2`）、Controller 权限与 `@ManagementGuardedWrite`、`recordApplied` 台账序、`updateStatusAlarmQuantityWithVersionV2` 的 `COALESCE(row_version,0)` CAS 与 `alarm_operator='<'`/`ck_m09_close_status_ready`、整批全有或全无、`@CurrentManagementRevision` 回显、008 读口任何断言。
- 验证：`mvn -pl futurefab-modules/futurefab-system -am test`（定向须带 `failIfNoSpecifiedTests=false`）＋ 邻近回归 `M09WiredStatusOnlineConfigContractTest` 全类。

**R2｜M09-003 拒绝码口径（裁决门后）**
- 门禁：work3 的 B-6/B-7/B-9 与 A-2 必须先有裁决结论；其中 B-6 的倾向是"不可见/不存在合并 404 `NOT_FOUND`、资格不符 403 `FORBIDDEN`"——即 003 不是一次码名替换能收口的批次。
- 裁决后白名单预告（**不作为本轮建议，仅供 work6 排期**）：`AlarmRecordApplicationApplicationServiceImpl.java:271,294,305` ＋ `M09WiredRecordContractTest.java:1239`（方法名 `handleOfMissingRecordIsForbiddenOrNotFoundBeforeAnyLock` 需同步改名，否则文档↔测试口径漂移）。若裁决同时收紧可见域，则跨层文件（`AlarmRecordMapper.xml`、专用范围片段）属另一批次，不得并入 R2 顺手改。
- 禁入：T04 锁序、`ALREADY_HANDLED`/`VERSION_CONFLICT`/CAS、`cancelPendingByAlarmId`、命令收据与 before/after 审计、幂等四元组、旧入口 `/alarm/alarmRecord/**`（B-7 单列）。

**R3｜无批次项（保持现状）**
- M09-013：维持 501 与 `BLOCKED`，实现轮直接使用登记的 `NOT_FOUND`，不安排替换。
- M09-017：不适用（无该码、未登记 `NOT_FOUND`）。
- M05 / M03 该码使用点：M05 自身登记口径，禁入；M03 `MemberIdentityFactsPolicy.RC_FORBIDDEN_OR_NOT_FOUND`（`:57/:167/:273` ＋ 2 处测试）是跨模块 Port reasonCode 字符串，改名等同契约变更，需另立轮次。

**执行顺序建议：R1（可在 work7 的 009 批次内闭环）→ R2（裁决门后）→ R3（随各自放行批次）。** 不建议把 R1/R2 合并为一次提交：009 无裁决依赖，003 有，合并会让 009 被 003 阻塞。

---

## 5. 附带发现（只登记，不在预检轮改动）

① **P2｜`docs/README.md` 已无 M09（乃至任何模块）入口条目**。36 行版本只登记两份日常文档，模块契约降级为"证据与专题细节"（§11）。AGENTS.md §3 要求的"以 `docs/README.md` 为权威层级入口"在本轮只能通过 `02-详细设计.md` §5.9 间接落到 M09。属文档导航落点问题，应归文档轮，**不得为此改代码**。

② **P2｜`skeleton-m09.json` 不承载错误码**（0 处 `NOT_FOUND`、0 处该码，结构无该字段）。第一轮把它与"39 门禁"并列作 M09 口径来源之一，容易误读；实际 M09 接口错误码的登记三源是 `错误码全集.md` ＋ CSV ＋ 骨架清单 MD（本轮已验证 CSV/骨架清单对 009 逐字一致）。

③ **P2｜`最终API基线.md` 仍缺 M09-009/013/019 接口段**（`# M09（14 条）`，`:4326` 起，见 §1 第 4 项）。与第一轮发现④同源，未变。

④ **P2｜CSV/骨架清单登记的实现类包路径与代码现状漂移**（`service.impl.AlarmXxxApplicationServiceImpl` vs 实际 `service.impl.application.m09.AlarmXxxApplicationApplicationServiceImpl`）。不影响口径，属文档维护轮。

⑤ **P2｜M09-009 的 `OPERATE` 层级观察（不属错误码口径，不排批次）**：`页面与接口契约.md:61` 与 `接口目录与契约定位.md:59` 对 API09 记 `OPERATE`，而 `statusLabScope`（XML `:254-258`）只按 `sys_user_lab` 成员关系过滤，未读 `auth_type`；端点侧只有 `lab:statusalarm:edit`。这与本轮码名判定无关（码名替换不改谓词），但会影响 work7 的 009 实现收口口径；若确为缺口，属 M09-009 实现批次的裁决项，**不得由 R1 顺手改 SQL**。

⑥ **登记而非结论**：M09-003 的行级可见性缺口、接收人资格全缺、同权限旧入口旁路（`AlarmRecordController.java:83-89` → `AlarmRecordServiceImpl.java:99-137`）已由 work3 的 `M09-003-写路径行级可见性与授权边界预检-20261003.md` A-2/A-5/B-3/B-6/B-7/B-9 逐项登记，本轮**不重复推导、不提出修法**。

---

## 6. 分层口径声明

- 可以宣称：`STATIC_VERIFIED`（一轮清单 vs 当前树逐项复核；五方权威面对该码的登记/未登记静态对齐；窄修条件的枚举 HTTP 与异常渲染链静态核对）。
- 仅静态核对：009 的窄修可行性、003 的裁决依赖关系。
- `NOT_VERIFIED`（本轮未做，不得冒充）：编译、契约测试、`mvn -pl ... -am test`、SQL 在 MySQL 执行、真实 HTTP、浏览器、外部通道/设备、现场/生产验收。
- 未解决项：M09-003 拒绝码分层与可见域（待 work3 裁决）；M09-009 码名对齐（待 work7 批次）；M09-013 `BLOCKED`；M09 全模块继续受 `BLOCKED_MENU`（`docs/开发基线/02-基础数据初始化.sql` 无告警菜单/权限种子）约束，任何窄修后 HTTP/浏览器验收仍封顶 `IMPLEMENTED + CONTRACT_TESTED`。
- 交付：本文件；提交方式=显式路径 `git add`，仅本文档；**不 push、不 rebase、不 merge**，交 work6 复核。
