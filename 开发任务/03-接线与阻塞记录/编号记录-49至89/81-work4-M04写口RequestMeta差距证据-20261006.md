# 81 · work4｜M04 写口 RequestMeta / header 化差距证据包（2026-10-06）

执行人：work4（M04 + M07 owner）　复审：work8　默认不 push。
本批只取证与登记，**未改生产 Java、未改 Mapper XML、未改前端、未改 SQL 基线、未改公共错误码/Port 签名/共享注册表**。

## 0. 结论摘要

| 接口 | 路由（类级 `/process/templates`） | requestId 来源 | managementRevision 来源 | `@ManagementGuardedWrite` | `@CurrentManagementRevision` | 判定 |
|---|---|---|---|---|---|---|
| M04-006 创建 | POST `""`（Controller:119-120） | Body 字段 | Body 字段 | 无 | 无 | 守卫已接线，元数据未 header 化 |
| M04-007 修改 | PUT `/{templateId}`（:127-128） | Body 字段 | Body 字段 | 无 | 无 | 同上 |
| M04-008 复制 | POST `/{templateId}/copies`（:136-137） | Body 字段 | Body 字段 | 无 | 无 | 同上（且本条无可达成功路径，见 82 号 §3） |
| M04-009 启停 | PUT `/{templateId}/status`（:145-146） | Body 字段 | Body 字段 | 无 | 无 | 同上 |
| M04-010 删除 | POST `/{templateId}/delete`（:154-155） | Body 字段 | Body 字段 | 无 | 无 | 同上 |

一句话结论：M04 五条写口**确实走真实守卫链**（`ManagementGuardExecutor`），但**元数据来源与全系统 header 口径不一致**，并且**五条写口的读口不产出顶层 `managementRevision`**；两者叠加后，按当前前端代码静态推断"页面首笔写必 400"（§5，静态推断，未 HTTP 验证）。状态标记：`BLOCKED_DESIGN`（header 化属跨端契约变更，需总控授权）+ `NOT_VERIFIED`（HTTP/浏览器）。

## 1. 取证基线

- `git fetch origin` 单快照：`HEAD` = `origin/cloud` = `a033eb0e`，`--left-right --count` = `0 0`，`git status --short` 空，`df797b3d` 已在祖先链（`merge-base --is-ancestor` 通过）。
- 所有行号按该基线读取；`target/classes` 等构建产物不参与判定。

## 2. 后端事实

### 2.1 Controller 层：零 header 绑定、零标记注解

`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/ProcessTemplateController.java`

- `grep -c "@ManagementGuardedWrite\|@CurrentManagementRevision\|@RequestHeader"` = **0**（全类）。
- 五条写方法签名形如 `public AjaxResult createTemplate(@RequestBody TemplateCreateCommand command)`，Path 变量在方法体内回写 Body 同名字段（如 `:130` `templateUpdateCommand.setTemplateId(templateId)`），符合"Path 覆盖 Body"，但**没有任何一条从 Header 取 requestId/revision**。
- 类 Javadoc 自述口径：`:52-53` "requestId/managementRevision 由请求体承载，本入口不做 header 化"（各方法注释重复此话术）。即这是**已声明的差异**，不是漏写注释。

### 2.2 服务层：`WriteMeta` 由 Body 字段构造，且无服务端补号

`service/impl/application/m04/ProcessTemplateApplicationApplicationServiceImpl.java`

- 五条写口的构造点：`:290`（006）、`:316`（007）、`:347`（008）、`:368`（009）、`:386`（010），全部形如 `new WriteMeta(command.getRequestId(), command.getManagementRevision())`。
- 全文件 **0 处** `WriteMeta.newRequestId()` 调用（该静态方法是 `WriteMeta.java:64` 注释所述"Header 缺失时服务端补齐 requestId 的唯一入口"）⇒ 不存在"缺 header 就自动生成新号"的静默旁路，缺字段直接 400。
- 载荷摘要组成不一致（上一批已登记，本次复算仍在）：006=`{templateKind,templateName}`（`:292-293`）、007=`{templateId}`（`:318`）、008=`{sourceTemplateId,copySourceVersionId}`（`:349-350`）、009=`{templateId,status}`（`:370-371`）、010=`{templateId}`（`:388`）。

### 2.3 命令对象确有 Body 字段（`domain/dto/m04/`）

`TemplateCreateCommand` L25/L27、`TemplateUpdateCommand` L24/L26、`TemplateCopyCommand` L29/L31、`TemplateStatusChangeCommand` L16/L18、`TemplateDeleteCommand` L14/L16 均声明 `private String requestId; private String managementRevision;`。这与 `WriteMeta.java` 类注释第 12~14 行的口径冲突："字段只允许来自 Header……Body 不得覆盖 Header"。

## 3. 公共机制事实（决定"读口是否产出顶层 revision"）

| 机制 | 位置 | 事实 |
|---|---|---|
| 元数据校验 | `futurefab-common/futurefab-common-core/.../meta/WriteMeta.java:31-41` | requestId 必须匹配严格 8-4-4-4-12 UUID；revision 必须十进制非负整数且落 long 值域，否则 `RequestMetaInvalidException` |
| 非法映射 | `.../exception/RequestMetaInvalidException.java:8,22` | 固定 400 + `errorCode=INPUT_INVALID`（`RequestMetaConstants:29` = 字符串 `"INPUT_INVALID"`，与 `FutureFabErrorCode.INPUT_INVALID` 同码） |
| Header 解析器 | `.../resolver/WriteMetaArgumentResolver.java:38-52` | Controller 方法可声明 `WriteMeta` 形参，由解析器从 Header 取值；`:46` `X-Management-Revision` 缺失即 400；类注释"Header 为唯一权威来源，Body 不得覆盖" |
| 读口前置解析 | `futurefab-common/futurefab-common-security/.../interceptor/ManagementRevisionPreResolver.java:67-69` | **只有方法带 `@CurrentManagementRevision`** 才读取当前版本并写入上下文，否则直接放行 |
| 响应外壳 | `.../handler/RequestMetadataResponseAdvice.java:56-70` | 把上下文里的 `requestId`/`managementRevision` **平铺到外壳顶层**（AjaxResult/R/TableDataInfo 三分支） |
| 上下文语义 | `.../meta/RequestMetadataContext.java:62-84` | `putCurrentManagementRevision`（读口 QUERY_CURRENT）与 `putCommittedManagementRevision`（写口 MUTATION_COMMITTED）写同一个响应字段 |
| 提交回填 | `service/guard/ManagementGuardExecutor.java:175` | 守卫事务提交后调用 `putCommittedManagementRevision` ⇒ **M04 写口响应顶层其实带 revision** |
| 注解门禁作用域 | `src/test/.../ManagementGuardedWriteArchTest.java:71-99` | 单向校验"已标注方法必须在 Controller 上且 `@Log` 三属性必须关"；**不检查"执行守卫的写口是否已标注"** |

由此得出两条此前未写清的口径：

1. **M04 的读口不产出顶层 `managementRevision`**：`ProcessTemplateController` 的 11 个读方法（`:73/81/91/100/111/163/171/179/187/195/203`）全部无 `@CurrentManagementRevision`；M04 服务层也 0 处调用 `putCurrentManagementRevision`（`RequestMetadataContext` 在 M04 服务仅 `:8` 一条 import，无任何调用）。响应里只有 `data` 内的 `managementRevision`（`:1413` `result.setManagementRevision(...)`），不在顶层。
2. **M04 的写口响应顶层反而有 revision**（经 `ManagementGuardExecutor:175` 回填）。但这个值在当前前端链路上不可达：拿不到它的前提是"已经成功写过一次"，而首笔写需要它（§5）⇒ 环形依赖，实际不可用。

## 4. 其它模块对照（证明 M04 是个例，非全系统口径）

- M01：`SysUserController.java:163-164` `@RequestHeader("X-Request-Id")` + `@RequestHeader("X-Management-Revision")`；`:356-358` 注释明确"写元数据以 Header 为唯一权威并覆盖 Body 自报值，缺失/非法由 `WriteMeta` 参数解析器在进入方法体前终结"；读口 `:183` 带 `@CurrentManagementRevision`。
- M03：`ResCultureController.java:275/291/307/334/350/366` 以 `WriteMeta` 形参接收；`ResProjectController.java:82/110/232` 读口带 `@CurrentManagementRevision`。
- M05：`DetSignConsoleController.java:82-89/93-100` `@ManagementGuardedWrite` + `WriteMeta`。
- M09：`AlarmRuleV2Controller.java:47-53`、`AlarmMonitorPolicyV2Controller.java:47-53` 同口径。
- 全仓 Controller 中以 `WriteMeta writeMeta` 作方法形参的文件（`grep -rn "WriteMeta writeMeta" controller/`）覆盖 M01/M02/M06/M09 等多个入口，**`ProcessTemplateController` 不在其中**。

## 5. 前端事实与 P1 推断链

前端在仓库内：`futurefab-frontend/`（monorepo，非 `futurefab-ui/`）。

- 统一 header 工具存在且被广泛使用：`packages/sdk-smp-api/src/guarded-write.ts:20-27` `writeHeaders()` 发 `X-Request-Id`（缺失时前端生成）与 `X-Management-Revision`（缺失则**不发该头**，交由后端 400，前端不伪造版本）。引用它的 sdk 文件 **37** 个（benchreactor/calibrationObject/consumableMaster/containerspec/correction/detectoritem/devairpum/devAnalyzerModel/devdetector/devfloorscale/devperistalticpump/dictData/dictType/feedMedium/integratedreactor/lab/liquidBag 等）。
- **M04 是未接入方**：`packages/sdk-smp-api/src/processTemplate.ts` 的 create/copy/update/changeStatus/delete 调用只传 `{ method, data }`（`:312/316-318/322/329/336`），**0 处** `headers`/`writeHeaders`；命令类型把 `requestId?`、`managementRevision?` 声明为 Body 字段（`:252-253/266-267/273-274`）。
- 列表页：`packages/app-smp-settings/src/views/feeding-template-management/index.vue:50` `const revision = ref<string>()`（初值 undefined）；`:281-283` 只在 `result.managementRevision != null` 时赋值，而该字段按 §3-1 后端根本不产出；`:324-325`（启停）与 `:360-361`（删除）把 `managementRevision: revision.value` 放进 Body。
- 编辑页：`feeding-template-editor.vue:883` `const requestId = uuid()`，`:894/905/914` 三处只把 `requestId` 放 Body，**完全不传 managementRevision**。

**推断链（静态）**：读口不产出顶层 revision → 列表页 `revision.value` 恒 undefined → 写请求 Body 缺 `managementRevision` → `WriteMeta` 构造期 `RequestMetaInvalidException`（400 `INPUT_INVALID`，见 `:290/316/347/368/386` 的构造点）→ 首笔写失败；编辑页路径缺同一字段，结论相同。**反向检查**：唯一能给出顶层 revision 的写响应（§3-2 的 `:175` 回填）需要先有一次成功写，故不构成出路；`MANAGEMENT_CONFLICT` 分支也不产出可用于首写的顶层值。

状态：`NOT_VERIFIED`（未发过真实 HTTP，未在浏览器操作）。上表全部为源码级事实 + 一条静态推断，静态推断部分不得当作 HTTP 验收结论。

## 6. 差距清单（登记，不实施）

| # | 差距 | 落地需要的动作 | 归属/授权 |
|---|---|---|---|
| G1 | 五条写口无 `@ManagementGuardedWrite` 标记 | 补注解；同时受 `ManagementGuardedWriteArchTest` 的 `@Log` 三属性约束（现有 `@Log` 写法需逐条核对） | M04 生产码，需开发批授权 |
| G2 | requestId/revision 从 Body 取，与全系统 Header 唯一权威口径冲突 | Controller 改 `WriteMeta` 形参或 `@RequestHeader`，删命令 DTO 的两个 Body 字段（或保留但被 Header 覆盖） | `BLOCKED_DESIGN`：跨端契约变更，需总控协调 |
| G3 | 11 个读口无 `@CurrentManagementRevision`，顶层 revision 缺失 | 逐读口补注解 + 外壳契约测试（可抄 `M07ReadManagementRevisionShellContractTest`） | M04 生产码，建议与 G2 同批 |
| G4 | 前端 M04 未接 `writeHeaders`，编辑页不传 revision | `processTemplate.ts` 五个写口切 `headers: writeHeaders(meta)`，页面接读口 revision | 前端范围，work4 不改 |
| G5 | 幂等载荷摘要只含部分字段（007 仅 templateId） | 扩摘要字段会改变客户端超时重试的语义（重放成功 → 冲突失败） | `BLOCKED_DESIGN`：四条写口共同裁决，上一批已登记 |

建议落地顺序（保持 fail-closed）：G3 → G1 → G2（后端一次改齐，禁止放宽 `WriteMeta` 校验）→ G4（前端切换）→ G5 单独裁决。任何一步都不允许以"前端问题"为由放宽后端 RequestMeta 校验或删除守卫。

## 7. 本批未触碰范围

未改 Controller/Service/DTO/Mapper/XML/SQL 基线/前端文件；未动 `FutureFabErrorCode`、`ManagementOperation`、`AuditPolicyRegistry`、Port 签名与 `PortSignatureSnapshotTest`；未动 M01/M02/M03/M05/M06/M09 生产码；未读 history 与客户只读材料作为设计依据。SQL、HTTP、浏览器、Nacos、网关、外部系统一律 `NOT_VERIFIED`。
