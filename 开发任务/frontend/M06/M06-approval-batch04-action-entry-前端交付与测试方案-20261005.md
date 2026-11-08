# M06 流程审批 · 审批页面入口盘点与动作入口前端契约对齐 · Batch 04 · 前端交付与测试方案

## 1. 基本信息

| 项 | 内容 |
|---|---|
| 批次 | Batch 04（M06 approval：审批页面入口盘点与动作入口前端契约对齐） |
| 执行人 | work1（前端分批开发，不出最终测试结论） |
| 日期 | 2026-10-05 |
| 页面/路由 | `/process/approval/*`（审批单）、`/lab/lab/{labId}/approval-policy`（审批政策）、UNKNOWN 对账 |
| 后端契约范围 | M06-001 ~ M06-015 |
| 交付类型 | **盘点 + 契约对齐说明 + 测试方案**（本批零代码改动，见 §2、§3.1） |
| 本批结论 | 五个子域全部 `NO_UI`；菜单入口 `BLOCKED_MENU`（无法从仓库证据判定，需运行库只读核验）；`NOT_VERIFIED` |
| 验证层级 | 已执行：静态盘点 + 编译/检查（见 §4）。未执行：HTTP、浏览器、SQL、外部系统 |
| 盘点时 HEAD | `def8bd53`（`git rev-parse --short HEAD`） |

### 1.1 盘点结论：M06 五个子域逐一判定

任务要求盘点：审批政策 / 审批单列表 / 审批详情 / 审批动作 / 人工对账。逐项结论如下，判据是同一组可复核的检索命令（原文见 §4.1）。

| 子域 | 设计入口 | 后端能力 | 前端路由 | 前端视图 | 前端 API 封装 | 状态 |
|---|---|---|---|---|---|---|
| 审批政策（实验室审批设置） | `详细设计.md` §5 M06-UI01（第 81 行） | M06-007/M06-008 读、M06-006/M06-009 写 | 无 | 无 | 无 | `NO_UI` |
| 审批单列表 | M06-UI02（第 93 行） | M06-010 | 无 | 无 | 无 | `NO_UI` |
| 审批详情（含只读关联对象） | M06-UI03（第 107 行） | M06-011、M06-012 | 无 | 无 | 无 | `NO_UI` |
| 审批动作（审核/批准/驳回/撤回 + 预检） | M06-UI03 按钮段（第 113 行） | M06-013 预检、M06-014 执行 | 无 | 无 | 无 | `NO_UI` |
| 人工对账（UNKNOWN 交付） | §5 **未定义该页面**（仅 UI01~UI04） | M06-001~M06-005 | 无 | 无 | 无 | `NO_UI` + 待裁决 R9 |
| 审批日志 | M06-UI04（第 115 行） | M06-012 | 无 | 无 | 无 | `NO_UI` |
| 直通审计 | — | M06-015 仍为骨架 501 | 无 | 无 | 无 | `NO_UI` + `BLOCKED`（后端） |

关键负面事实（全部为本轮实测，非沿用旧结论）：

- `futurefab-frontend/packages/sdk-smp-api/src/` 下不存在任何 M06 封装文件；`grep -rn "process/approval" packages/ tests/` 在**整个前端仓库零命中**。
- `grep -rniE "approval" packages/sdk-smp-api/src/` 只命中 `modules/detect/approvalrecord.ts`（`/detect/approval-record/*`），属 M05 检测结果签批记录，与 M06 无关，不可当 M06 入口。
- `packages/app-smp-settings/src/views/` 下无审批相关目录；`packages/app-smp-data/src/router/index.ts:77-80` 的 `detect-approval-record` 是唯一含 “approval” 字样的路由，同样属 M05。
- M06-UI01 设计要求「从 M02 实验室列表“审批流”打开」（`详细设计.md` 第 91 行）；`grep -rn "审批流" packages/app-smp-settings/src/views/lab-management/` 零命中 ⇒ 连入口按钮也不存在。
- 六个前端包（`app-smp-data`/`app-smp-lab`/`app-smp-settings`/`lib-smp-base`/`portal`/`sdk-*`）中，`grep -rlniE "process/approval|流程审批" packages/*/src` 零命中。
- 权限码 `process:approval:*`、`lab:approval:*` 在前端零引用；前端也没有 `futurefab.error.*` 通用错误文案目录（`grep -rn "futurefab.error" packages/` 零命中），因此 M06 错误码目前**没有任何前端渲染路径**。
- 网关源码 `nacos-config/futurefab-gateway-dev.yml:51` 已含 `Path=/alarm/**,/device/**,/lab/**,/detect/**,/resource/**,/smp/**,/process/**,...`，即 `/process/**` 路由源码存在；但仓库源码 ≠ 运行态（见 §7 B4）。

### 1.2 后端能力事实表（本批契约对齐的依据）

| 契约 | method + path | 守卫注解 | 版本/幂等语义 | 接线状态 | 证据（`path:line`） |
|---|---|---|---|---|---|
| M06-001 | GET `/process/approval/deliveries/{id}/reconciliation-preview` | 无 | 只读 | 已接线（注释仍写 501，见 R2） | `ApprovalReconciliationController.java:40-43` |
| M06-002 | POST `/process/approval/deliveries/{id}/reconciliations` | **无 `@ManagementGuardedWrite`** | `requestId`/`managementRevision`/`baseDeliveryVersion` 走 **Body** | 已接线 | Controller:49-52；`ReconciliationCreateCommand.java:15-27` |
| M06-003 | POST `/process/approval/reconciliations/{id}/review` | 无 | `requestId`/`expectedVersion` 走 Body | 已接线 | Controller:58-61；`ReconciliationReviewCommand.java:15-25` |
| M06-004 | POST `/process/approval/reconciliations/{id}/withdraw` | 无 | `requestId`/`expectedVersion` 走 Body | 已接线 | Controller:67-70；`ReconciliationWithdrawCommand.java:13-19` |
| M06-005 | GET `/process/approval/reconciliations/{id}` | 无 | 只读 | 已接线 | Controller:76-79 |
| M06-006 | POST `/process/approval/policies/{labId}/activation` | **`@ManagementGuardedWrite`** | Header 权威，Body 自报值被覆盖 | 已接线 | `ApprovalPolicyController.java:44-53` |
| M06-007 | GET `/process/approval/scenes` | — | 带 `@CurrentManagementRevision`（顶层版本外壳） | 已接线 | `ApprovalPolicyController.java:57-61` |
| M06-008 | GET `/lab/lab/{labId}/approval-policy` | — | 带 `@CurrentManagementRevision` | 已接线 | `LabApprovalPolicyController.java:42-48` |
| M06-009 | PUT `/lab/lab/{labId}/approval-policy` | **`@ManagementGuardedWrite`** | Header 权威 | 已接线 | `LabApprovalPolicyController.java:53-60` |
| M06-010 | GET `/process/approval/requests` | — | **无** `@CurrentManagementRevision` | 已接线 | `ProcessApprovalController.java:51-53` |
| M06-011 | GET `/process/approval/requests/{approvalId}` | — | **无** | 已接线 | Controller:59-60 |
| M06-012 | GET `/process/approval/requests/{approvalId}/actions` | — | **无** | 已接线 | Controller:69-70 |
| M06-013 | POST `/process/approval/requests/{approvalId}/precheck` | 无（只读预检，不改状态） | 无守卫头要求 | 已接线 | Controller:79-84，注释第 77 行 |
| M06-014 | POST `/process/approval/requests/{approvalId}/actions` | **`@ManagementGuardedWrite`** | Header 唯一权威；缺 `X-Management-Revision` → 400 `INPUT_INVALID`；缺 `X-Request-Id` 由入口显式拒绝 | 已接线 | Controller:103-118 |
| M06-015 | GET `/process/approval/audit` | — | — | **仍为骨架 501** | Controller:119-121；`ProcessApprovalQueryApplicationServiceImpl.java:281` `throw new SkeletonNotImplementedException("M06-015")` |

M06 应用服务目录内**唯一**的 `SkeletonNotImplementedException` 抛出点是 `ProcessApprovalQueryApplicationServiceImpl.java:281`（本轮 `grep -rn "SkeletonNotImplemented" service/impl/application/m06/` 实测），因此 M06-001~M06-005 与 M06-010~M06-014 的接线状态可按上表采信。

## 2. 修改文件清单

**本批代码改动：0 个文件。** 唯一新增文件是本 MD 自身。

| 文件 | 类型 | 说明 |
|---|---|---|
| `docs/开发任务/frontend/M06/M06-approval-batch04-action-entry-前端交付与测试方案-20261005.md` | 新增 | 本交付物 |

未改动清单（明确声明，便于总控核对）：

- 后端 Java、`docs/开发基线/*.sql`、`docs/接口文档/`、`docs/详细设计/**/history/**`、客户材料：全部未触碰。
- 前端 `packages/**`、`tests/**`：本批**零改动**（Batch 01~03 的在途文件保持原状，未被本批覆盖或回退）。
- `packages/sdk-smp-api/src/`：本批**未新增** M06 封装（决策依据见 §3.1）。

本批读过的关键证据文件（只读）：`ProcessApprovalController.java`、`ApprovalPolicyController.java`、`LabApprovalPolicyController.java`、`ApprovalReconciliationController.java`、`domain/dto/m06/Reconciliation*Command.java`、`ApprovalActionCommand.java`、`PolicyActivationCommand.java`、`domain/vo/m06/{ApprovalState,ApprovalRow,ApprovalActionResult,ApprovalPolicyView,PolicyActivationResult,IssueView,ScopeState}.java`、`futurefab-api/.../FutureFabErrorCode.java`、`futurefab-common-security/.../RequestMetadataResponseAdvice.java`、`docs/详细设计/06-流程审批管理/{详细设计,错误码全集,接口与审批生效契约}.md`、`docs/开发基线/{01-完整建表,02-基础数据初始化}.sql`、`nacos-config/futurefab-gateway-dev.yml`、前端 `packages/app-smp-{settings,data}/src/router/index.ts` 与 `views/` 目录清单。

## 3. 功能改动说明

### 3.1 为什么本批零代码（决策链，供总控复核或推翻）

任务条款：「若页面不存在：不新增大页面；输出 BLOCKED_MENU / NO_UI；只补必要 API 封装或测试方案」。逐条判据：

1. **五个子域全部无 UI、无路由、无入口**（§1.1 实测）。新增页面属于「大页面」，条款明确禁止。
2. **API 封装不是「必要」**：M06 前端零调用方。在没有视图与路由的前提下新增 `sdk-smp-api` 封装，产出的是无人调用的死代码，并且会预先替页面作者定死请求形态（分页外壳、Body 字段、守卫头策略），与真正接手 M06 UI 的 agent 产生文件冲突面。故按条款的第二分支交付**测试方案 + 契约对齐说明**（§3.2、§5）。
3. **不为 M06 提前扩展共享件**：`useGuardedWrite.writeErrorMessage` 目前只特判 `REFERENCE_EXISTS`。M06 需要分流的 `SOURCE_STATE_CONFLICT`/`VERSION_CONFLICT`/`POLICY_UNVERIFIED`/`OWNER_UNAVAILABLE`/`AUTHORIZATION_UNAVAILABLE`/`SELF_APPROVAL` 等口径属于 M06 页面语义，改共享 composable 会同时影响 M01~M05/M07/M09 全部调用方，属跨模块在途文件改动，应等页面落地时按页面局部分流（Batch 03 的 `venue-write-guard.ts` 就是同一策略的先例）。

若总控要求「先把 SDK 封装铺好」，请明确指定：封装边界（M06-001~015 全选还是只 006/008/009/010~014）、命名空间、以及是否允许我另建 `packages/sdk-smp-api/src/modules/process/` 目录。我按指示执行，不在本批自行扩张。

### 3.2 页面实现时必须对齐的前端契约（本批实际交付内容）

**(a) 守卫写只有三个，头要求不同对象**

| 写口 | 必须携带 | revision 来源（同页配对） | 短路规则 |
|---|---|---|---|
| M06-006 政策启用/暂停 | `X-Request-Id`、`X-Management-Revision` | M06-007 `GET /scenes` 顶层 `managementRevision` | 取不到版本 ⇒ 不发请求（AGENTS.md §13.3） |
| M06-009 政策整份保存 | 同上 | M06-008 `GET /{labId}/approval-policy` 顶层版本 | 同上 |
| M06-014 审批动作执行 | 同上 + Body `expectedObjectVersion` | **当前无配对读口**（M06-010/011/012 均无 `@CurrentManagementRevision`）⇒ 见 R1，需裁决 | 同上，不得从无关模块借版本 |

三个写口的 `X-Management-Revision`/`X-Request-Id` 都是**唯一权威**：Controller 会用 header 值覆盖 Body 自报值（`ApprovalPolicyController.java:50-52`、`ProcessApprovalController.java:113-116`）。前端不得只把 requestId 放 Body。

**(b) 对账三个写口（M06-002/003/004）不是守卫写**

它们**没有** `@ManagementGuardedWrite`，幂等键与版本走 **Body**：`requestId` + `managementRevision`（M06-002 另有 `baseDeliveryVersion`；M06-003/004 用 `expectedVersion`）。前端在这里的正确做法是：照常生成 `requestId` 并回填 Body，**不要**假设后端会因缺守卫头返回 400；`X-Management-Revision` 对它们不生效。

**(c) 状态与按钮显示只能来自后端字段**

- 审批四态：`ApprovalState = PENDING_REVIEW / PENDING_APPROVAL / APPROVED / CANCELLED`；生效状态另用 `ApplyState`。`详细设计.md` 第 63 行明确「APPROVED 并不意味着任务已执行或设备已停」，页面必须分开标注，不得把 APPROVED 渲染成「已生效/执行成功」。
- 按钮由 `allowedActions` 驱动，禁用原因取 `issues[]`（`code` + `message`）；`详细设计.md` 第 113 行原文：「不从前端按钮计算最终资格」。前端只按 `allowedActions` 展示，不重算状态机（AGENTS.md §9）。**取值路径注意**：列表行是 `ApprovalRow.allowedActions`（`ApprovalRow.java:60`），而详情 `ApprovalDetailView` 顶层没有该字段（其实列：`row / policySnapshot / changeSnapshot / submissionReason / cancelKind / supersedesApprovalId / precheck`，`ApprovalDetailView.java:14-26`），必须读 `detail.row.allowedActions` 与 `detail.row.issues`，写成 `detail.allowedActions` 会得到 undefined 并静默隐藏全部按钮。
- 驳回/撤回必填原因（`REASON_REQUIRED` 400），通过批注可空；终态只有关闭；撤回仅申请人、且仅未决。
- 场景目录 `ScopeState = SUPPORTED / OWNER_GATED / EXCLUDED`，`EXCLUDED` 不得显示为「免审批」（第 91 行：场景未接入不表示默认免审批）。

**(d) 错误码可读提示分流表（M06 页面必须实现，前端不得改后端码）**

| errorCode | HTTP | 语义 | 前端口径 |
|---|---|---|---|
| `INPUT_INVALID` | 400 | 缺/非法 `X-Management-Revision`（守卫层，M06 文档未登记，见 R5） | 「未取到管理版本」，不发写请求即不会遇到 |
| `MANAGEMENT_CONFLICT` | 409 | 全局管理版本 CAS 失败（守卫层，M06 文档未登记，见 R5） | 提示刷新/重试，并把本地版本标记过期后重取 |
| `REQUEST_CONFLICT` | 409 | 同 `X-Request-Id` 复用冲突 | 不重发同一 requestId，重新组织一次新请求 |
| `VERSION_CONFLICT` | 409 | 对象/配置版本事实不匹配 | 重新读取并对比，**不自动覆盖**新配置 |
| `SOURCE_STATE_CONFLICT` | 409 | 状态顺序不满足（如 M06-009：ENABLED 根禁止整份替换，须先 PAUSE） | 必须读后端 message 并展示；**不可**诱导用户「刷新重试」（这不是版本竞争，重试走不通） |
| `CULTURE_CODE_CONFLICT` | 409 | 培养 ID 候选重复，不能通过/生效 | 显示后端原文，禁用通过按钮，保留驳回入口 |
| `POLICY_UNVERIFIED` | 503 | 政策未核准（2026-10-04 裁决 C 保持本码） | 「政策尚未核准」，可查原请求结果，不降级为 DIRECT |
| `AUTHORIZATION_UNAVAILABLE` / `OWNER_UNAVAILABLE` | 503 | 依赖不可用/无合格审批人 | 可重试口径：「依赖未就绪，请稍后重试」，先查原请求是否已生效 |
| `SELF_APPROVAL` / `STAGE_ACTOR_CONFLICT` | 403 | Q01 审核人≠批准人 / 阶段身份冲突 | 明示「需由不同人员处理」，不给出重试按钮 |
| `ACTIVE_CHANGE_EXISTS` | 409 | 已有在途变更 | 显示原单入口，不重复提交 |

`APPROVAL_TERMINAL` **不是** canonical 码（`FutureFabErrorCode.java` 零命中，M06 `错误码全集.md` 亦无），它只作为 precheck 响应 `issues[].code` 出现（`ProcessApprovalQueryApplicationServiceImpl.java:175`、`:255`）。前端必须把它当**预检原因文本**渲染，而不是当 HTTP 错误分支处理——写成 `errorCode === "APPROVAL_TERMINAL"` 的分支永远不会命中。

**(e) 不在前端伪造拥有方业务结果**

- 「已生效/冲突/失败/待核实」只渲染后端 `applyState`，不由前端根据 `state === APPROVED` 推导。
- 待办内容不可在审批页编辑（第 38 行）：要改候选必须走「撤回未决单 → 来源模块重新校验生成新单」，前端不得提供原地改候选的入口。
- 审批单不可空白新建（第 105 行：截图“新增”不意味着可以在 M06 空白造审批单）⇒ 列表页不得放「新增」。
- 对账 `resolution` 只有 `VERIFY_APPLIED / SEAL_NOT_APPLIED`，双人核准（`review` 的 `APPROVE/REJECT`）必须不同人；前端不得用「同一人已提交」推测核准结果，也不得以 worker 未跑为由显示成功。

## 4. 已执行验证命令与结果

四条必须验证命令，均在 `D:\Code\zhixianweilai\yaoming-cloud\futurefab-frontend` 执行，HEAD `def8bd53`：

| # | 命令 | 结果 |
|---|---|---|
| 1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 退出 0，`vue-tsc --noEmit --composite false` 无报错 |
| 2 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 退出 0，同上无报错 |
| 3 | `pnpm run routes:check` | 退出 0（`tsx scripts/generate-route-paths.ts --check`），路由表与快照一致 ⇒ 佐证本批未增删路由 |
| 4 | `npx vitest run tests/venue-delete-guarded-write.test.ts tests/benchreactor-management.test.ts tests/benchreactor-acceptance-precheck.test.ts tests/lab-labbenchreactor-guarded-write.test.ts` | `Test Files 4 passed (4)` / `Tests 77 passed (77)`（5+14+28+30） |

本批无新增代码，故**未新增 vitest 文件**（第 4 条按「any new vitest」口径，用 work1 现有 4 套件证明基线绿）。同时说明：全量 `npx vitest run` 存在他人归属的背景红（本会话已按 §4.6 归属法核对，不在本批范围内），**不得**以全量绿作为本批放行条件。

### 4.1 盘点命令原文（可复核，全部为本轮实测）

```bash
# 均在 futurefab-frontend/ 下执行；输出为「零命中」即 §1.1 结论成立
grep -rn "process/approval" packages/ tests/                                  # 零命中
grep -rlniE "process/approval|流程审批" packages/*/src                         # 零命中
grep -rniE "approval" packages/sdk-smp-api/src/                                # 仅 detect/approvalrecord.ts
grep -rn "approval-policy" packages/ tests/                                    # 零命中
grep -rn "process:approval\|lab:approval" packages/ tests/                     # 零命中
grep -rn "futurefab.error" packages/                                           # 零命中
grep -rn "审批流" packages/app-smp-settings/src/views/lab-management/           # 零命中
ls packages/app-smp-settings/src/views/ | grep -i appro                        # 零命中
```

后端证据命令：

```bash
# m06 应用服务目录内唯一骨架抛出点
grep -rn "SkeletonNotImplemented" futurefab-modules/.../service/impl/application/m06/   # 仅 :281
# APPROVAL_TERMINAL 只作为 precheck issue code
grep -rn "APPROVAL_TERMINAL" --include=*.java futurefab-modules futurefab-common futurefab-api
```

### 4.2 层级声明

- 本批做到：静态盘点（文档存在性 + 代码检索 + 注解事实）与编译/检查通过。
- 本批未做：HTTP 请求、浏览器操作、SQL 执行、外部系统联调。
- 因此本批对 M06 前端的判定只能是 `NO_UI` / `NOT_VERIFIED`，**不得**表述为「M06 前端可用」「已对齐」或「验收通过」。

## 5. 给 work5 的详细测试方案

### 5.1 A 组：本批唯一可执行项（阻塞事实核验，非功能验收）

| 用例 | 步骤 | 期望 | 层级上限 |
|---|---|---|---|
| TC-M06-INV-01 | 复跑 §4.1 全部前端检索命令 | 全部零命中 ⇒ M06 前端确实 `NO_UI` | 静态检查 |
| TC-M06-INV-02 | 读 `ApprovalPolicyController.java:44`、`LabApprovalPolicyController.java:56`、`ProcessApprovalController.java:103` | 恰好 3 个 `@ManagementGuardedWrite`；其余 M06 写口无该注解 | 静态检查 |
| TC-M06-INV-03 | 读 `ApprovalPolicyController.java:57`、`LabApprovalPolicyController.java:44`、`ProcessApprovalController.java` 全部 GET | 只有 M06-007/M06-008 带 `@CurrentManagementRevision`；M06-010/011/012/015 不带 ⇒ R1 成立 | 静态检查 |
| TC-M06-INV-04 | `grep -n "APPROVAL_TERMINAL" FutureFabErrorCode.java` | 零命中（不是 canonical 码） | 静态检查 |
| TC-M06-INV-05 | 后端契约测试：对 M06-014 发缺 `X-Management-Revision` 的请求 | 400 canonical `INPUT_INVALID`，不进应用服务 | `CONTRACT_TESTED`（MockMvc 上限即此） |

A 组结论用途：证明本批的 `NO_UI` 与 R1/R4 判定成立。**不得**把 A 组任何一条写成 M06 功能通过。

### 5.2 B 组：M06 页面实现后的验收模板（当前不可执行，全部标 `NOT_VERIFIED`）

前置：只有页面与路由真实存在、且真实构建产物被门户加载后才执行。每条记录须含：页面名 + 操作步骤、HTTP method + URL、请求头（尤其 `X-Request-Id`/`X-Management-Revision`）、request payload、response body、DB 证据、测试数据清理结果。

| 用例 | 子域 | 步骤要点 | 期望 |
|---|---|---|---|
| TC-M06-UI-01 | 审批政策读 | 从实验室入口打开设置页 | M06-008 返回外壳顶层 `managementRevision` 与 `objectVersion`；场景按 `sortOrder` 全量展示，`EXCLUDED` 显示未接入说明 |
| TC-M06-UI-02 | 审批政策写（正常） | 改档位后保存 | PUT 带两个守卫头；`requestId` 每次新生成；Body `expectedObjectVersion` 等于读到的版本；成功后用回执 `managementRevision` 覆盖本地值 |
| TC-M06-UI-03 | 审批政策缺版本 | 清空本地版本后保存 | **不发 PUT**（短路），显示「未取到管理版本」；Network 面板该请求不存在 |
| TC-M06-UI-04 | 审批政策 409 | 他端先改，用旧版本保存 | 409 `VERSION_CONFLICT`，本地输入保留供对比，不自动覆盖 |
| TC-M06-UI-05 | ENABLED 根整份替换 | 根为 ENABLED 时直接保存档位变更 | 409 `SOURCE_STATE_CONFLICT`，提示「须先 PAUSE」；不得显示「刷新重试」 |
| TC-M06-UI-06 | 政策启停 | M06-006 启用/暂停 | 头来自 M06-007；回执 `PolicyActivationResult.managementRevision` 覆盖本地版本；`duplicate=true` 时不重复提示成功 |
| TC-M06-UI-07 | 审批单列表筛选 | 实验室必选、一级/二级联动（换一级清二级）、日期只填一侧、日期区间倒置 | 单侧日期按半开区间保留；倒置必须前端拒绝；`submittedAt DESC, approvalId DESC`；请求失败显示重试而非空列表 |
| TC-M06-UI-08 | 详情按钮 | 分别取 PENDING_REVIEW / PENDING_APPROVAL / APPROVED / CANCELLED 四种 `state` | 按钮严格等于 `allowedActions`；终态只有「关闭」；禁用原因显示 `issues[].message` |
| TC-M06-UI-09 | 动作写 | 审核通过 → 批准通过 | 两次 M06-014 各自新 `requestId`；`expectedObjectVersion` 来自上一条回执 `objectVersion`；页面文案不出现「已生效」直到 `applyState` 为已生效 |
| TC-M06-UI-10 | 驳回必填 | 驳回时空原因 | 不发请求或后端 400 `REASON_REQUIRED`，两种都要有可读提示 |
| TC-M06-UI-11 | 预检不改状态 | 调 M06-013 后再读列表 | `state`/`objectVersion` 不变（预检只读） |
| TC-M06-UI-12 | 日志 | 打开日志弹窗 | 按 `occurredAt ASC, actionId ASC` 全量显示，不截断为最近 N 条、不分页 |
| TC-M06-UI-13 | 503 依赖不可用 | 触发 `POLICY_UNVERIFIED` / `AUTHORIZATION_UNAVAILABLE` | 提示「政策未核准」「依赖未就绪请稍后重试」；先查原请求结果，不自动重发同键 |
| TC-M06-UI-14 | 同一 requestId 重放 | 用已成功的 `requestId` 再发 M06-014 | 409 `REQUEST_CONFLICT` 或幂等回执，二者都不产生第二次业务动作 |

数据库证据口径（重要，避免写不存在的列）：`sys_management_request` **不是错误日志表**，只登记成功的守卫写回执，`sys_management_revision` 是单行 `scope_key='SYSTEM'` 的全局计数器（真实列：`scope_key,revision,update_time`）。因此 400/409 的**状态码与 errorCode 只能来自浏览器 Network**；DB 侧只能证明「写没落地」「版本没被推进」「出现了回执行」。执行任何 SQL 前先 `DESC` 目标表，且只跑只读 SELECT（需总控批准）。

## 6. 测试数据建议

- 场景初数据：`docs/开发基线/02-基础数据初始化.sql` 已插入 `M06_SC001`~`M06_SC0NN`（第 6 行起，含 `scopeState=SUPPORTED/EXCLUDED`）。**注意：该文件不含任何 `sys_menu` 种子 INSERT**（本轮 `grep -rlnE "insert into sys_menu" docs/` 零命中，`sys_menu` 只在 `01-完整建表.sql:103` 建表），所以「菜单是否存在」无法从仓库判定，必须在运行库只读核验（见 §7 B1）。
- 审批单主数据：**不能手工造**。`详细设计.md` 第 105 行明确 M06 不空白造单，申请必须由来源模块（M07 任务 / M03 培养 / M04 工艺）的具体业务操作产生。work5 需先在来源模块触发一条需政策的动作，再回审批列表取单。
- 四个状态覆盖：需要同时准备 `PENDING_REVIEW`、`PENDING_APPROVAL`、`APPROVED`（含 `applyState` 已生效与未生效各一）、`CANCELLED` 四条真实单，才能跑 TC-M06-UI-08/09。
- 双人条件：`SELF_APPROVAL` 用例需要两个不同账号（Q01 审核人≠批准人）；本 PC 单账号无法验收，属 `BLOCKED_DATA`。
- 政策未核准条件：`POLICY_UNVERIFIED` 需要一个 readiness 非 READY 的实验室。
- 只读核验 SQL 模板（列名已按 `docs/开发基线/01-完整建表.sql` 核对，勿增列）：

```sql
-- 全局管理版本（单行 scope_key='SYSTEM'）
SELECT scope_key, revision, update_time FROM sys_management_revision WHERE scope_key = 'SYSTEM';

-- 审批单事实（列名已核对：state / apply_state / object_version / supersedes_approval_id 真实存在）
SELECT approval_id, lab_id, scene_code, state, apply_state, object_version, supersedes_approval_id
  FROM apr_request WHERE lab_id = :testLabId ORDER BY submitted_at DESC LIMIT 20;

-- 交付与对账（apr_delivery 主键 delivery_id；state / object_version / unknown_since / query_attempts 均已核对存在）
SELECT delivery_id, approval_id, state, object_version, decision_version, unknown_since, query_attempts
  FROM apr_delivery WHERE state = 'UNKNOWN' ORDER BY unknown_since DESC LIMIT 20;
-- apr_reconciliation 已核对列：reconciliation_id, delivery_id, approval_id, decision_version, resolution,
--   base_delivery_version, evidence_hash, reason, submitted_by, submitted_at, reviewed_by, reviewed_at,
--   state, owner_receipt, resolved_at, object_version, active_delivery_id
SELECT reconciliation_id, delivery_id, approval_id, resolution, base_delivery_version, state,
       submitted_by, reviewed_by, object_version
  FROM apr_reconciliation WHERE approval_id = :testApprovalId;
```

上表列名逐条对照 `docs/开发基线/01-完整建表.sql`（`apr_request` 36 列、`apr_delivery` 19 列、`apr_reconciliation` 24 列）实测提取，未使用任何推测列名；执行前仍建议 `DESC` 目标表复核运行库版本。**测试数据一律加可识别前缀并事后清理**：业务库是共享 dev 远端库，不是本地库。

## 7. 已知风险 / 阻塞

| 编号 | 事项 | 归属 | 状态 |
|---|---|---|---|
| B1 | M06 无前端页面、无路由、无 API 封装、无实验室列表「审批流」入口 | 前端（待页面任务） | `NO_UI` |
| B2 | 菜单行是否存在无法从仓库判定：`docs/` 内零 `insert into sys_menu`，只有建表 | 总控/后端 | `BLOCKED_MENU`（需运行库只读 SELECT 或菜单管理页核验） |
| B3 | 人工对账（M06-001~005）后端已接线，但 `详细设计.md` §5 未定义任何对账页面 | 需求/设计 | 待裁决 R9 |
| R1 | M06-014 是守卫写，但 M06-010/011/012 读口都不带 `@CurrentManagementRevision` ⇒ 审批动作页没有合规的同页版本来源（§13.3 禁止从无关模块借；借 M06-007/008 是否算同模块需裁决） | 后端/总控 | 待裁决 |
| R2 | `ApprovalReconciliationController` 类注释与逐方法注释仍写「应用服务显式 501」（第 26、40、49、58、67、76 行），但两个对账应用服务实测零 `SkeletonNotImplemented`、共 868 行真实实现 ⇒ 注释与实现不一致 | 后端（我不改） | 待后端修正 |
| R3 | M06-015 直通审计仍 501（`ProcessApprovalQueryApplicationServiceImpl.java:281`） | 后端 | `BLOCKED` |
| R4 | `APPROVAL_TERMINAL` 非 canonical 码，只存在于 precheck `issues[].code`（含 `APPROVAL_VERSION_MISSING`） | 前端实现时 | 已记录，见 §3.2(d) |
| R5 | M06 `错误码全集.md` 未登记守卫层的 `MANAGEMENT_CONFLICT` 与 `INPUT_INVALID`（`grep` 零命中），但三个守卫写必然可能返回它们 | 文档/总控 | 待裁决 |
| R6 | 对账闭环的 `RESOLVED`/`STALE` 写入依赖 `ApprovalDeliveryWorkerTask`，配置项 `approval.delivery.worker.enabled` 默认关闭 ⇒ 对账后生效状态不会自然推进 | 运行环境 | `BLOCKED_DEPLOY`（需确认运行实例是否开启） |
| R7 | 前端无 `futurefab.error.*` 通用文案目录，各页各自拼装提示；M06 码若沿用现状会继续分散 | 前端治理 | 待裁决 |
| R8 | 网关 `/process/**` 路由仅在仓库源码中确认（`futurefab-gateway-dev.yml:51`）；运行态 Nacos 与网关是否已发布/重启未核验 | 后端/运维 | `NOT_VERIFIED` |
| B4 | 本批零代码 ⇒ Batch 01~03 的在途改动未被本批触碰；未 `git add`、未 commit、未 push | work1 | 见 §8 |

## 8. work5 测试记录区

（以下由 work5 填写，work1 不代填、不预判结论）

| 用例 | 执行命令/步骤 | 实际结果 | 判定（CONTRACT_TESTED / HTTP_VERIFIED / BLOCKED_* / NOT_VERIFIED） | 记录人 | 日期 |
|---|---|---|---|---|---|
| TC-M06-INV-01 | | | | | |
| TC-M06-INV-02 | | | | | |
| TC-M06-INV-03 | | | | | |
| TC-M06-INV-04 | | | | | |
| TC-M06-INV-05 | | | | | |
| TC-M06-UI-01 ~ 14 | 页面未实现 ⇒ 当前不可执行 | | `NOT_VERIFIED` | | |

背景红归属核对（如需）：`git rev-parse --short HEAD` ＋ `git show HEAD:<file>` 对比 + 逐文件失败数恒定法，见 `M02-lab-labbenchreactor-batch02-…` MD §4.6。

## 9. 最终结论区

（本节由 work5/总控填写；work1 只声明本批口径）

**work1 声明：**

- 本批交付为**盘点与契约对齐说明**，代码改动 0 文件，验证层级为「静态检查 + 编译/检查通过」。
- M06 五个子域（审批政策 / 审批单列表 / 审批详情 / 审批动作 / 人工对账）在真实前端仓库中**均无页面、无路由、无 API 封装、无入口**，状态 `NO_UI`；菜单存在性 `BLOCKED_MENU`（仓库无菜单种子可证）。
- M06 前端**未做任何 HTTP、浏览器或数据库验收**，一律 `NOT_VERIFIED`，不得被引用为「M06 前端完成」。
- 未 `git add`、未 commit、未 push；Batch 01~03 的在途文件保持原状。
- 需总控裁决：R1（M06-014 版本来源）、R9/B3（对账页面是否设计）、R5（文档补登记守卫层码）、以及是否需要我先铺 M06 SDK 封装（§3.1）。

**work5 结论：**（待填）

**总控结论：**（待填）
