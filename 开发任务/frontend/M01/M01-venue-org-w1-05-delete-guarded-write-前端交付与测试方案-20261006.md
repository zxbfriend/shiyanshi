# M01 场地（venue）删除 ORG06 守卫写对齐 — W1-05 前端交付与测试方案（含 Batch 03 基线）

> 本 MD 由 `M01-venue-org-batch03-delete-guarded-write-前端交付与测试方案-20261005.md` 更名而来（总控 W1 批次编号口径：一页面一 MD，追加轮次写进同一文件）。§一~§九 的 Batch 03 内容保留为**基线**（W1-05 只做了三处必要调整：§5 用例编号连续重排、§7 B5 由「未做」改记「本批已解决」、§9 追加 W1-05 结论行），增量集中在带「W1-05」标记的小节：§2.1.2、§3.5—§3.8、§4.7—§4.8、§5.10—§5.13、§7 B5（基线项已被本批解决）+ B12—B15、§8 追加记录行、§9 追加结论行。

## 一、基本信息

| 项 | 内容 |
| --- | --- |
| 批次 | **W1-05**（总控 W1 串行第五批；基线 = Batch 03，同一页面同一 MD） |
| 执行人 | work1（仅前端页面开发，不做最终测试结论） |
| 模块 | M01 系统管理 / 场地管理 |
| 页面 | 子路由 `venue-management`（`packages/app-smp-settings/src/router/index.ts:64`），菜单组件 `smp/venue/index`（`route-paths.generated.ts:97`）；门户完整入口预计 `/settings/venue-management`，**以 work5 实测为准** |
| 接口族 | `/smp/venue/*`：`pageList`（读版本）、`POST/PUT /smp/venue`（M01-014/015）、`DELETE /smp/venue/{venueIds}`（**M01-018 / ORG06**）、`GET /smp/venue/{id}/delete-check`（ORG05 / 定位 017，本批仍未接） |
| Batch 03 目标 | 删除（含同页新增/修改、拖拽排序）守卫写对齐：带 `X-Request-Id` / `X-Management-Revision`、版本只来自列表外壳、**缺版本必须短路**、409 有刷新/重试口径、`REFERENCE_EXISTS` 有**场地口径**可读提示 |
| W1-05 目标 | 在上述基线上把**删除链路对齐到 ORG06 契约本体**：Path 段「逗号分隔正 ID，1–100 个」的形态闸、`DeleteResult.removedIds` 的**整棵子树**回执口径、删除前文案点明子树原子删除，并补 work5 可执行行内删除所需的稳定 `data-testid` 与结论镜像 |
| 分支 / HEAD | `cloud`；Batch 03 收口于 `def8bd53`，**W1-05 收口于 `becc0bb1`**（进场 `96f85408`，其间 `becc0bb1` 只新增一个 M03 盘点 MD，与本批文件零交集） |
| 工作区状态 | 未 `git add`、未 commit、未 push；暂存区为空 |
| 日期 | Batch 03 = 2026-10-05；W1-05 = 2026-10-06 |

### 1.1 本批要解决的问题（不是「加功能」，是补规则缺口）

场地页此前**已经**带守卫写头（`writeMeta(await ensureRevision())`），表面看符合 §13.3，但有两个真实缺口：

1. **缺版本不短路**：`ensureRevision()` 兜底读一次 `pageList` 后仍可能返回 `undefined`（外壳没带版本 / 那次读取失败）。旧写法把 `undefined` 一路交给 `writeHeaders`，它只会**省掉** `X-Management-Revision`，请求照发。后端 `WriteMetaArgumentResolver.java:47–49` 随即抛 `RequestMetaInvalidException` → **HTTP 400 + `errorCode=INPUT_INVALID`**，msg 是「管理写接口必须携带请求头 X-Management-Revision（十进制非负整数字符串）」。用户看到的是一句无法自助执行的开发口径，而 AGENTS.md §13.3 明确要求「拿不到 revision 时必须短路，不得发送写请求」。
2. **`REFERENCE_EXISTS` 提示是错误指引**：共用 `writeErrorMessage` 对 `REFERENCE_EXISTS` 的兜底文案是主数据页口径（「请先在实验组或实验室变更负责人后再操作」）。场地删除的被引用方是**实验室与设备**、且按整棵子树原子判定，让用户去变更负责人根本走不通。

### 1.2 后端契约事实（只读核对，本批未改任何后端文件）

| 事实 | 证据 |
| --- | --- |
| 删除是守卫写：`@ManagementGuardedWrite` + `system:venue:remove`，路径参数逗号分隔正 ID 1–100，无 Body | `SysVenueController.java:156–159`；`docs/详细设计/01-系统管理/接口目录与契约定位.md:113`（ORG06）；`Controller请求调用时序设计.md:26` 定位 018 |
| 版本唯一初始来源 = 根分页顶层 `managementRevision`（该读口**已**带） | `SysVenueController.java:61–64` `@CurrentManagementRevision`；`:58–59` 注释「本页是场地守卫写 M01-015 的 X-Management-Revision 唯一初始来源」 ⇒ **不是 BACKEND_CONTRACT_GAP** |
| `tree` / `detail` 不带顶层版本；`delete-check` 把版本放在 `data` 里 | `SysVenueController.java:81–83`、`:102–104`（`VenueDetailView` 无该字段）、`:112–114` + `VenueApplicationServiceImpl.java:351` |
| 缺 `X-Management-Revision` ⇒ 400 `INPUT_INVALID`（不是 409） | `WriteMetaArgumentResolver.java:47–49` + `RequestMetaExceptionHandler.java:33–39`；钉在 `M01OrgWiredWriteContractTest.java:2906–2916` |
| 版本不匹配 ⇒ 409 `MANAGEMENT_CONFLICT` + `currentManagementRevision` | `ManagementGuardExecutor.java:267–271`；`M01OrgWiredWriteContractTest.java:2886–2888` |
| 被引用 ⇒ 409，canonical `errorCode` **恰为 `REFERENCE_EXISTS`**，msg「场地或其子树被实验室/设备引用，无法删除」 | `FutureFabErrorCode.java:277`、`VenueApplicationServiceImpl.java:592`、`ManagementGuardExceptionHandler.java:34`；`M01OrgWiredWriteContractTest.java:1437` |
| 缺 `X-Request-Id` 时后端**会自造 UUID**（宽松），但文档要求写接口必填 | `RequestMetadataFilter.java:46–47` vs `详细设计.md:818` ⇒ 前端继续自带，不依赖后端兜底 |
| 场地**无独立排序接口**，前端 `sort` 复用 `PUT /smp/venue` 串行推进版本 | `sdk-smp-api/src/index.ts`（venueApi.sort 注释与实现）；后端无 `/sort` 映射 |
| **部门（org）删除不是守卫写**：M01-030 无 `@ManagementGuardedWrite` | `SysDeptController.java:191–193`；`M01OrgSkeletonContractTest.java:231` 仍断言 dept remove 未接线 ⇒ 本批**不给 dept 加守卫写短路**，见 §7 B2 |

**结论**：页面存在、读口存在、错误码存在 ⇒ Batch 03 不需要 `BLOCKED_MENU` / `BACKEND_CONTRACT_GAP` 兜底，按真实缺口实施最小改动。

### 1.3 W1-05 追加的后端契约事实（仍是只读核对，本批未改任何后端文件）

| 事实 | 证据 |
| --- | --- |
| ORG06 的 Path 段在 **Controller 只做逗号拆分**，正整数与数量校验在应用服务，且**在守卫之前**失败关闭 | `SysVenueController.java:156–163`（`:156 @ManagementGuardedWrite`、`:158 @DeleteMapping("/{venueIds}")`、`:163 venueIds.split(",")`）；`VenueApplicationServiceImpl.java:377`（空集 ⇒ `INPUT_INVALID`「场地ID不能为空」）、`:380–382`（`> DELETE_BATCH_MAX` ⇒「单次删除不能超过100个场地」）、`:393`（重复 ID ⇒ `venueIds[i]重复出现`）、`:395`（`positiveId(raw, "场地ID")`） |
| `DELETE_BATCH_MAX = 100` 是 §18 ORG06 冻结上限 | `VenueApplicationServiceImpl.java:127–128` |
| 守卫操作码确实是 ORG06，幂等/回执由守卫执行器承载 | `VenueApplicationServiceImpl.java:400`（`ManagementOperation.ORG06.getCode()`） |
| 删除回调是**整棵合并子树原子软删除**，不是单行删除 | `VenueApplicationServiceImpl.java:358`（口径注释）、`:567`（「解析合并子树（根 + 全部有效后代去重升序）→ 逐节点重验引用 → 逐节点软删除」）、`详细设计.md:874` |
| 回执 `DeleteResult` 三字段：`requestId` / `managementRevision` / **`removedIds`（非 null，元素为字符串业务主键，顺序与请求一致）** | `domain/vo/common/DeleteResult.java:20–74`（`:66–69` getter 保证非 null） |
| `removedIds` 实际写入的是**受影响集合**（可能多于请求条数） | `VenueApplicationServiceImpl.java:406`（`result.setRemovedIds(outcome.getAffectedIds())`）；`AuditPolicyRegistry.java:478`「输入解析 venueIds 首元素 / 实际删除 venueId 集合升序」 |
| 外壳顶层 `managementRevision` 与 `data.managementRevision` **同时存在**，页面继续只认顶层（Batch 03 口径不变） | `types.ts:9–12`（`ApiResult.managementRevision`：查询端点为当前值、守卫写为提交后新值）；控制器 `success(DeleteResult)` 把结果放 `data` |
| **组织侧（部门）删除仍是骨架**：M01-030 应用服务直接抛 `SkeletonNotImplementedException` | `DeptApplicationServiceImpl.java:300`；`SysDeptController.java:191–194`（`remove` 无 `@ManagementGuardedWrite`） ⇒ 见 §7 B13（口径不一致另见 §7 B2），W1-05 不动部门页 |

---

## 二、修改文件清单

### 2.1 本批改动（工作区，未提交）

| 文件 | 变更 | 说明 |
| --- | --- | --- |
| `packages/app-smp-settings/src/views/venue-management/venue-write-guard.ts` | **新增 54 行** | 页侧纯函数：`guardedWriteMeta()` 版本闸 + `venueWriteErrorMessage()` 409 分流。不碰请求路径/方法/载荷 |
| `packages/app-smp-settings/src/views/venue-management/index.vue` | +57 / −10 | 三个守卫写口接入版本闸；失败出口统一 `reportWriteError()`；移除无闸写法 |
| `packages/sdk-language/src/language/smp-settings/cn.ts` | +2 行（venue 键） | `settings-venue.message.revisionMissing` / `referenceBlocked`。**同文件另有 Batch 01 的 benchreactor 键增量，二者不重叠** |
| `packages/sdk-language/src/language/smp-settings/en.ts` | +4 行（venue 键，长串换行） | 同上英文版 |
| `tests/venue-delete-guarded-write.test.ts` | **新增 211 行 / 14 用例** | 真实导入 `venue-write-guard` + 真实 `writeHeaders` / `ApiError` + 真实双语目录，另加页面源码钉 |
| 已跟踪 3 文件合计 | 85 insertions(+), 10 deletions(-) | `git diff --stat` 口径 |

### 2.1.2 W1-05 增量（相对 §2.1 的 Batch 03 基线，工作区未提交）

`git diff --numstat` 对已跟踪文件是**跨批累计**口径（`index.vue` = Batch 03 + W1-05；`cn.ts` / `en.ts` 含 W1-01/02/03/04 在途键），故下表按**文件内区域**给出 W1-05 自己的增量，行号为收口时实测。

| 文件 | 状态 | W1-05 改动点 |
| --- | --- | --- |
| `.../venue-management/venue-test-ids.ts` | **新增 99 行** | `TESTID_PREFIX="venue"`、`safeToken()`、`PAGE_TEST_ID`、`ROW_ACTIONS_TEST_ID`、`rowDetails/rowEdit/rowDeleteTestId()`、`CONFIRM_DELETE_TEST_ID`、`DELETE_OUTCOME`（6 个 token，含 `invalid-id`）、`deleteOutcomeAttr()`、`revisionDataAttr()`、`removedCountDataAttr()`。只生成属性值，不碰请求 |
| `.../venue-management/venue-write-guard.ts` | 修改 +36（55 → 91 行） | 新增 `venueDeletePathId()`（ORG06 Path 形态闸）、`venueRemovedCount()`（只认 `data.removedIds`）、`venueDeleteOutcome()`（引用阻断 / 版本冲突 / 其他失败三分类）；`guardedWriteMeta`、`venueWriteErrorMessage` 语义**未动**（biome 收口只做换行折叠，见 §4.7 第 8 行） |
| `.../venue-management/index.vue` | 修改（累计 +127/−14 中的 W1-05 部分） | `h` 引入；`:55–70` 两个本页面模块的 import；`:403–404` 结论与条数归零；`:407–412` 形态闸在确认弹窗**之前**（`:408 if (!venueId) {`）；`:417` 弹窗内容节点 testid；`:432` `venueApi.remove(venueId, meta)`；`:435–443` 回执条数 + 分流成功文案；`:446` catch 里写结论镜像；`:567–570` 根节点 `data-testid` + 三个只读诊断属性；`:693/:713` 行操作区与行内删除按钮 testid |
| `packages/sdk-language/src/language/smp-settings/cn.ts` | 修改 +4 行（venue 段） | `deleteHint` 改写为 ORG06 子树口径；新增 `invalidVenueId`、`deletedWithCount` |
| `packages/sdk-language/src/language/smp-settings/en.ts` | 修改 +4 行（venue 段） | 同上英文，`deletedWithCount` 保留 `{count}` 插值 |
| `tests/venue-delete-guarded-write.test.ts` | 修改（211 → 400 行，14 → **30 用例**） | 追加 4 个 describe：ORG06 Path 形态闸（含后端源码反证 3 条）、回执 `removedIds` 口径、页面接线与镜像属性、双语键齐全；同时把 Batch 03 的两处目录断言从 `as any` 收口成具名形状 |
| `tests/venue-management.test.ts` | 修改 +3/−1 | **检测器修正**（非业务改动）：`f3437b047` 已删除场地详情的【显示顺序】字段，源码钉 `common.label.sortOrder` 属 HEAD 既有红，改为断言该标签**不再出现**，并写明归因（见 §4.6） |
| `packages/sdk-language/dist/index.js` | 重新构建（非源码，gitignore 外由构建产生） | 语言包 `main` 指 `dist/index.js`，不重建则新增文案进不了被服务的 bundle；重建后 `grep -c 整棵子树原子删除 dist/index.js` = 1 |

### 2.2 明确未改动（逐条核对）

- 后端 Java / Mapper / XML / `futurefab-api`：**0 改动**（只读引用证据见 §1.2）。
- SQL、`docs/开发基线/**`、客户只读材料、`history/**`：**0 改动**。
- `packages/sdk-smp-api/src/guarded-write.ts` 与 `index.ts`（venueApi 的 URL、方法、`writeHeaders(meta)` 组装）：**0 改动**——短路放在页面层，SDK 的「不伪造版本、缺头就省掉」行为保持原样。
- `packages/app-smp-settings/src/shared/use-guarded-write.ts`（多页共用）：**0 改动**。场地差异全部落在页面自己的 `venueWriteErrorMessage` 包装里，避免波及其它页。
- `views/dept-management/**`、`views/menu-management/**`：**0 改动**（见 §7 B2/B3）。
- `tests/venue-management.test.ts`：**0 改动**（Batch 03 口径；当时该文件有 1 条 HEAD 既有红，见 §4.6）。**W1-05 已改这 1 条检测器**，理由与归因见 §2.1.2 末行——不是代改他人业务，是把已删功能上的源码钉同步为反向断言。
- 页面可见文案：`deleteConfirm` / `deleteHint` / `deletedSuccessfully` 等原文一字未改；本批只**新增**两条键。（**W1-05 变更**：`deleteHint` 按 ORG06 子树口径改写，新增 `invalidVenueId` / `deletedWithCount`，`deleteConfirm` 与 `common.label.deletedSuccessfully` 仍不动，见 §3.6）
- **W1-05 同样未改**：`sdk-smp-api` 的 venueApi（URL / 方法 / `writeHeaders`）零改动；`use-guarded-write.ts` 零改动；`views/dept-management/**`、`views/menu-management/**` 零改动；后端与 SQL 零改动。

---

## 三、功能改动说明

### 3.1 版本闸：拿不到期望版本就不发请求

```ts
// venue-write-guard.ts
export function guardedWriteMeta(revision: string | undefined): GuardedWriteMeta | undefined {
  if (revision == null || revision === "") return undefined;
  return { requestId: requestId(), revision };
}
```

页面三个写口统一 `const meta = await metaForWrite(); if (!meta) { 提示并 return; }`：

| 写口 | 短路位置 | 短路后表现 |
| --- | --- | --- |
| 新增/修改（`venueApi.save`，M01-014/015） | 确认弹窗内、`saving/submitting` 置位之后但在 `PUT/POST` 之前 | **弹窗保持打开**，`modalError` 显示「未取到管理版本，已取消本次操作，请刷新列表后重试」，用户改完可直接再点，不必重填 |
| 删除（`venueApi.remove`，M01-018） | 用户点「确定」之后、`DELETE` 之前 | toast 同一口径，**不发 DELETE** |
| 拖拽排序（`venueApi.sort` → 串行 PUT） | 计算 `changes` 之前 | 整串 PUT 一条都不发；先把 DOM 还原回拖拽前状态并重新展开（与既有早退路径一致），再给同一提示 |

要点：短路只依赖 `ensureRevision()` 的一次兜底读取，**不在失败后再撞第二次**；`X-Request-Id` 仍由页面自带（每 HTTP 请求一个新键），版本仍只来自 `pageList` 顶层 `managementRevision` 或守卫写回执（`applyWrittenRevision`），无硬编码、无跨模块借版本。

### 3.2 409 分流：场地的引用保护说场地的话

```ts
function reportWriteError(error: unknown): string {
  invalidateOnConflict(error);   // 409 → 本地版本作废，下一次写前强制重取
  return venueWriteErrorMessage(error, t("settings-venue.message.referenceBlocked", …), writeErrorMessage);
}
```

| 后端返回 | 页面提示 | 依据 |
| --- | --- | --- |
| 409 `REFERENCE_EXISTS` | 「该场地或其下级场地仍被实验室或设备引用，请先解除关联：**场地或其子树被实验室/设备引用，无法删除**」（后半段是后端 detail，点名被阻塞对象） | `VenueApplicationServiceImpl.java:592` |
| 409 `MANAGEMENT_CONFLICT` | 沿用共用口径「数据已被他人修改，请刷新后重试」，同时把 detail（后端会带 `currentManagementRevision`）透出 | `ManagementGuardExceptionHandler.java:40–43` |
| 409 `REQUEST_CONFLICT` | 同上共用口径（不改语义，避免把幂等冲突说成数据被改） | `ManagementGuardExecutor.java:250,257` |
| 503 `MANAGEMENT_BUSY` / 其它非 409 | 交回共用 `errorMessage()`，不吞原始信息 | `ManagementGuardExecutor` 类注释 :48–49 |

后端 message 为空或等于通用兜底 `GENERIC_REQUEST_FAILURE`（「操作失败」）时，只留本地口径，不拼出「…」：操作失败」这种空冒号串。

### 3.3 为什么本批不接 `delete-check`（ORG05 / 定位 017）

后端确有场地删除预检接口 `GET /smp/venue/{id}/delete-check`（`SysVenueController.java:112–114`，返回体 `data.allowed/reasonCodes/managementRevision`），Batch 03 的目标清单里没有预检 UI 接入（那是 Batch 01 对 M02 型号页的要求），且接入它会新增一次读请求与一段新交互，属于扩大范围。**已登记为 §7 B1，等总控单独下发批次**。当前删除路径仍按「直接 DELETE，被引用时靠 409 `REFERENCE_EXISTS` 给可读提示」执行，符合本批目标 5。

### 3.4 与既有页面口径的关系

`lab-labbenchreactor` / `benchreactor-management` 已有同类本地短路（键 `lab.benchreactor.revisionMissing`）。本批把同一口径落到场地页，命名与文案结构对齐（「未取到管理版本，已取消本次…，请刷新…后重试」），但不共用键，避免跨模块文案耦合。

### 3.5 ORG06 Path 形态闸：非正整数 ID 不发 DELETE（W1-05）

后端事实见 §1.3，这里只说页面口径。`venueDeletePathId(id)` 只接受**纯十进制正整数串**（归一 `String(id).trim()` 后匹配 `^[1-9][0-9]*$`），其余（空、`0`、前导零、负号、小数、科学计数、空格、逗号、非数字、`NaN`）一律 `undefined`；页面在 `:408` 停下并给 `invalidVenueId`（「…缺少有效标识，已取消本次删除，请刷新列表后重试」）。

与 Batch 03 版本闸同理：契约不允许的请求就不发。差别在于这条**不需要额外请求**即可判定，所以放在确认弹窗**之前**（`:407` 早于 `:411` 的 `showConfirm`），避免用户点了删除、确认完，才被告知这条根本不该发。

数量维度：ORG06 允许 1–100 个 ID，**页面只提供单条删除**（`n=1`，`venueApi.remove` 在源码里只出现 1 处，无 `join(",")` 伪批量入口），天然落在窗口内；上限校验属于后端守卫前逻辑，前端不重复实现一个只有 1 个元素的计数检查。

### 3.6 整棵子树口径：删除前说范围，删除后只认回执（W1-05）

| 环节 | 本批口径 | 不做什么 |
| --- | --- | --- |
| 删除前（确认弹窗 `msg`） | `settings-venue.message.deleteHint` 改写为「将连同该场地下的**全部下级场地**一并删除（**整棵子树原子删除**，不做部分成功）；仍被实验室或设备引用的场地无法删除。」 | 不给具体条数：页面树是**可见节点**，后端子树是**有效后代**，两者可不等；把可见数当结论就是伪造 |
| 删除后（成功提示） | 取 `venueRemovedCount(result)`，即 `data.removedIds.length`：`>1` 时用 `deletedWithCount`「已删除 {count} 个场地（含该场地的下级场地）」；`1` 或 `undefined` 回落既有 `common.label.deletedSuccessfully` | 不在没有回执数据时声称数量；不把 `removedIds` 缺字段当成 0（`venueRemovedCount` 对非数组回吐 `undefined`）；不声称「实验室/设备侧已清理」这类引用之外的副作用 |
| 版本覆盖 | 仍只用外壳顶层 `managementRevision`（`applyWrittenRevision`），**不**从 `data.managementRevision` 取值 | 不引入两个版本来源，避免 §13.3「不得从无关处借版本」的变体 |

回执形状核对（源码级）：`ApiResult` 的 `data` 是 `DeleteResult`，顶层 `requestId` / `managementRevision` 由响应建议注入，因此**同一响应里两处都有版本号**。本批继续只认顶层，`data` 只用来取 `removedIds`；两处是否一致属 HTTP 层结论，交 work5（§7 B14、§5.11 第 5 步）。

### 3.7 可测性锚点与结论镜像（W1-05）

work5 此前的阻塞点是：行内删除按钮只能按文案坐标猜，删除结论只在 3 秒消失的 message 里。本批补：

- `venue-page`（根 `PageContainer`，走 Vue 属性透传，已核 `page-container/index.vue` 单根 `<component :is="tag">`）；
- `venue-row-actions` + 每行 `venue-row-details-<id>` / `venue-row-edit-<id>` / `venue-row-delete-<id>`；
- `venue-confirm-delete`（SDK 弹窗页面拿不到 footer DOM，属性只能带在 content 节点上，与 Batch 02 同法）；
- 根节点三个只读诊断属性：`data-management-revision`（当前期望版本）、`data-last-delete-outcome`（`idle / invalid-id / revision-missing / reference-blocked / conflict / success / failed`）、`data-last-removed-count`（回执条数，未取得为空串）。

镜像不参与任何请求、文案或状态机：每次进入 `remove()` 先归零（`:403–404`），取消弹窗停在 `idle`，所以脚本读到的永远是本次尝试的结论。分类口径与文案分流一致（`venueDeleteOutcome` 与 `venueWriteErrorMessage` 都以 `errorCode === "REFERENCE_EXISTS"` 区分引用阻断与版本冲突），二者若漂移会在同一批用例里互相暴露。

**边界**：镜像只覆盖删除链路。新增/修改（弹窗内 `modalError`）与拖拽排序仍无结果镜像，本批不扩。

### 3.8 本批刻意不做的事（W1-05）

| 没做的事 | 原因 |
| --- | --- |
| 给场地页加多选/批量删除 | ORG06 支持 1–100 是**后端能力**，前端要承载它需要选择态、部分失败口径与新文案；本批目标是守卫写对齐，不自造新交互（总控「不强行造页面」）。记为 §7 B12 盘点结论 |
| 接 `delete-check`（ORG05 / 定位 017）预检 | Batch 03 已裁决（§3.3）：预检返回的版本在 `data` 里，与页面期望版本来源不同轴，接它需要总控先定口径 |
| 给部门（org）页补守卫写短路 | `SysDeptController.java:191–194` 的 remove **没有** `@ManagementGuardedWrite`，且 `DeptApplicationServiceImpl.java:300` 仍是 `SkeletonNotImplementedException("M01-030")` ⇒ 页面上报的是 501 骨架，不是守卫写口径问题，见 §7 B13（并参 §7 B2 的口径不一致记录） |
| 把 ORG06 错误码登记成表 | 场地的写失败出口是 LEGACY `AjaxResult` + 守卫异常建议，可达码已由 `writeErrorMessage` / `venueWriteErrorMessage` 覆盖（409 两类 + 其余透出原文）；再叠一张本地码表就是无人使用的死代码 |
| 整文件重排 `index.vue` / 语言包 | biome↔prettier 互斥尚未由总控裁决（各批 MD 记为 open ruling R8，本 MD §4 第 8 行给了实测证据），只做本批新增行的局部合规 |

---

## 四、已执行验证命令与结果

顺序按总控四步规则；**全部通过后才创建本 MD**。

| # | 命令 | 结果 |
| --- | --- | --- |
| 1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 通过（`vue-tsc --noEmit --composite false`，退出 0，无输出）——本批未改 SDK，跑它只为确认无连带破坏 |
| 2 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 通过（退出 0）；改 import 折叠与格式化后**重跑再次退出 0**。**W1-05 同命令再次退出 0**（`:h`、两个新 import、镜像 state 与模板绑定均在 vue-tsc 覆盖内） |
| 3 | `pnpm run routes:check` | 通过（显式取退出码：`exit=0`） |
| 4 | `npx vitest run tests/venue-delete-guarded-write.test.ts` | **14 tests / 1 file 全绿** |
| 5 | `npx vitest run tests/venue-delete-guarded-write.test.ts tests/venue-management.test.ts tests/lab-labbenchreactor-guarded-write.test.ts tests/benchreactor-management.test.ts tests/benchreactor-acceptance-precheck.test.ts` | **84/85**：本批 14 + Batch 02 30 + Batch 01 28 + 5 全绿；唯一红是 `tests/venue-management.test.ts`（HEAD 既有，见 §4.6） |
| 6 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 通过：`✓ 692 modules transformed`、`✓ built in 15.32s`、退出 0；产物 `dist/venue-management-oG61rYUn.js` 22.78 kB / gzip 6.15 kB，且 `grep -l settings-venue.message.revisionMissing dist/` 命中该 chunk ⇒ 改动确实进了被服务的产物 |
| 7 | `npx prettier --check`（5 个文件） | 我的 2 个新文件：**All matched files use Prettier code style** ✅。剩余 warn 只有 `index.vue` / `cn.ts` / `en.ts` 三个既有文件；已逐处比对「prettier 想改的行」，**不含本批任何新增标识符**（`revisionMissing` / `referenceBlocked` / `venue-write-guard` / `metaForWrite` / `reportWriteError` / `guardedWriteMeta` / `venueWriteErrorMessage`），属他人既有行风格，不顺手整文件重排 |
| 8 | `npx biome check`（`index.vue` HEAD 副本 vs 工作区副本） | 两边都是 `Found 3 errors`（同一处 `organizeImports` + `format`），**本批 0 增量**。附带发现：仓库 `format`(prettier) 与 `lint:check`(biome) 对同一文件给出互斥要求（biome 要折叠多行签名、prettier 要换行），故本批新增文件按 `format` 脚本口径取 prettier 合规版，biome 侧仅剩 `noExplicitAny` 5 条 warning（与仓库既有测试同规则同级） |
| — | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | **本批未执行**：未新增/修改 `sdk-smp-api` 任何导出或类型，只 import 既有 `writeHeaders` / `ApiError` / `GENERIC_REQUEST_FAILURE` / `errorMessage` / `requestId`（`index.ts:4,8` 的 `export * from "./guarded-write"` / `"./client"` 已覆盖） |

### 4.1 验证分层结论（AGENTS.md §13.2 口径）

- 文档存在/链接检查：本 MD 内所有证据均为仓库内真实路径 + 行号
- 静态检查通过 ✅（prettier 新文件合规；biome 与 HEAD 计数一致）
- 编译（type-check）通过 ✅
- 单元 / 契约测试通过 ✅（14 条本批用例 + Batch 01/02 回归 63 条）
- 应用构建通过 ✅（产物含本批改动）
- SQL 在目标库执行 —— **未执行**
- HTTP 联调 —— **未执行，NOT_VERIFIED**
- 浏览器验收 —— **未执行，NOT_VERIFIED**
- 现场 / 生产验收 —— 未执行

本批状态：**`CONTRACT_TESTED`（静态 + 编译 + 契约测试）**。§1.2 的后端事实来自读源码与读设计文档，**不是 HTTP 实测**；§3.2 的提示文案拼装顺序需 work5 在浏览器里逐条确认。

> §4 / §4.1 / §4.5 / §4.6 的「14 条用例」是 **Batch 03 基线快照**；W1-05 收口轮同一批命令的结果见 §4.7（本批用例 30 条）与 §4.8（新断言的变异自检），层级结论上限不变，仍是 `CONTRACT_TESTED`。

### 4.5 红项自检（证明断言不是空跑）

| 变异 | 预期 | 实测 |
| --- | --- | --- |
| `guardedWriteMeta` 里把 `if (revision == null …)` 改成 `if (false && …)`（即恢复「无版本也组装」） | 「没有版本时不组装」变红 | 红：`expected { …(2) } to be undefined`（1 failed / 13 passed） |
| `save()` 短路分支里把 `modalError.value = revisionMissingMessage();` 换成 `modalError.value = "";` | 「三个守卫写口都先过短路闸，且闸在请求之前」变红 | 红：同一条用例失败（1 failed / 13 passed） |
| 删掉 `reportWriteError` 里的 `invalidateOnConflict(error);` | 「失败出口统一」与短路闸两条同时变红 | 红：2 条用例失败 |

三处变异均已回退；回退后重跑 §4 第 4 项 = 14/14 全绿，`git diff --stat` 与 §2.1 一致。

### 4.6 背景红与检测器漂移（Batch 03 未代改 → W1-05 逐条给出处置）

- `tests/venue-management.test.ts > venue management controls > opens the venue detail sidebar through the query action`（`tests/venue-management.test.ts:94` 断言 `venueSource` 含 `common.label.sortOrder`）。归因证据三条：
  1. `git show HEAD:…/venue-management/index.vue | grep -c common.label.sortOrder` = **0**，工作区版同为 0 ⇒ 断言在我进场之前就不可满足；
  2. 引入者明确：提交 `f3437b047`（10-05 17:17）「删除详情显示的【显示顺序】字段」，只改了 `index.vue`（−3 行），未同步这条源码钉；
  3. 本批 `index.vue` 的 diff 全部落在 `<script setup>` 段（hunk 头 47 / 74 / 79 / 328 / 379 / 460 等），**没有任何模板或 label 改动**。
  ⇒ 属他人 M01 详设改动遗留的测试漂移，Batch 03 未代改（也不通过删断言凑绿）。
- **W1-05 对本条的处置（检测器修正，非业务改动）**：把 `tests/venue-management.test.ts:94` 的源码钉由「必须含 `common.label.sortOrder`」改为「**不得**含 `t("common.label.sortOrder")`」，并在钉旁留一行归因注释指向 `f3437b047`。理由：这条断言守的不变量是「详情页不再显示顺序字段」，`f3437b047` 之后正确的钉法是反向；改判既不是删断言凑绿，也不是把他人缺陷留给下一批。改后该文件全绿（§4.7 V5），且反向钉在本批 `index.vue` 上仍然成立（本批 diff 无任何 label 改动）。
- 全量套件在 Batch 02 交付时实测为 **14 文件 / 25 条红**（清单与逐条归因见 `M02-lab-labbenchreactor-batch02-testability-前端交付与测试方案-20261005.md` §4.6），本批新增的 `venue-delete-guarded-write.test.ts` 为 14 条全绿，`localization.test.ts` 的失败输出里**没有任何 venue 键**（新增双语键已进目录）。
- work5 执行本批时请以 **§4.7 的 V4–V8 行为准**（V4 = 本批 30 条用例；V5 = M01 回归；V8 = 被服务产物），**不得以全量绿为前置条件**。

### 4.7 W1-05 收口轮验证（2026-10-06，HEAD `becc0bb1`）

进场 HEAD = `96f85408`；其间 `becc0bb1`「docs(M03): 登记P02 APPLY前置盘点与阻塞报告」`git show --stat` = 1 个新 MD，与本批文件零交集。全部命令在收口 HEAD 重跑：

| # | 命令 | 结果 |
| --- | --- | --- |
| V1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 退出 **0**（本批未改 SDK 类型） |
| V2 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 退出 **0** |
| V3 | `pnpm run routes:check` | 退出 **0** |
| V4 | `npx vitest run tests/venue-delete-guarded-write.test.ts` | **30/30 全绿**（1 文件） |
| V5 | `npx vitest run tests/venue-delete-guarded-write.test.ts tests/venue-management.test.ts tests/dept-management.test.ts tests/m01-write-failure-feedback.test.ts tests/write-failure-feedback-sweep.test.ts` | **5 文件 / 100 用例全绿**（`venue-management.test.ts` 的 HEAD 既有红已由本批检测器修正转为全绿，见 §4.6） |
| V6 | `npx vitest run tests/benchreactor-management.test.ts tests/benchreactor-acceptance-precheck.test.ts tests/lab-labbenchreactor-guarded-write.test.ts tests/m03-culture-candidate-entry.test.ts tests/m04-feeding-template-version-identity.test.ts` | **5 文件 / 114 用例全绿**（W1-01~W1-04 交付未被本批共享的语言包改动破坏） |
| V7 | `pnpm --filter @futurefab/ui-sdk-language run build` | 退出 **0**；`grep -c "整棵子树原子删除" packages/sdk-language/dist/index.js` = **1**。必需：该包 `main` 指 `dist/index.js`，不重建则新文案进不了被门户服务的 bundle |
| V8 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 退出 **0**，`✓ built in 16.23s`；产物 `dist/venue-management-D-KD8keh.js` 25.79 kB / gzip 7.00 kB（Batch 03 时 22.78 kB，增量即本批三个函数 + 镜像绑定） |
| V9 | 产物符号抽检（同一 chunk） | `venueDeletePathId` 2、`data-last-delete-outcome` 2、`data-last-removed-count` 2、`row-delete-` 1、`confirm-delete` 1、`deletedWithCount` 1、`invalidVenueId` 1 ⇒ 改动进了被服务产物。**中文文案不在该 chunk 属预期**：语言包是独立 bundle（同 chunk 内 `顶级场地` 计数同为 0），文案层由 V7 + V10 的目录断言覆盖 |
| V10 | `npx biome check`（4 个文件） | 本批自有 3 个文件（`venue-test-ids.ts`、`venue-write-guard.ts`、`venue-delete-guarded-write.test.ts`）**0 error**（`--write` 收口后复检）；`tests/venue-management.test.ts` 仍报 `organizeImports` + `format` 2 项——已用 `git show HEAD:` 副本实测**同两条**（HEAD_BIOME=1），且 biome 建议的改写行数里**不含本批任何新增行**（`grep -c` 命中 0），故不整文件重排。本批顺带把该文件里的 `as any` 目录断言收口成具名形状，biome `noExplicitAny` 从 5 条降到 **0** 条 |
| V11 | `npx eslint` 同路径 | 退出 **0**（`tests/` 被 eslint 配置忽略，输出 2 条 informational warning；biome 是测试文件唯一门禁） |
| — | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | **本批未执行**：`sdk-smp-api` 无任何导出/类型改动，`GuardedWriteMeta`、`ApiError`、`writeHeaders` 均为既有导出 |
| 补 | 本 MD 自身的 prettier 口径 | `npx prettier --check` 对本 MD 报 warn，但**同目录 15 份交付 MD 全部同样报 warn**；仓库 `format` 脚本的覆盖范围是 `futurefab-frontend/package.json:27` 的 `packages/**` + `tests/**` + `scripts/**`，**不含 `docs/**`** ⇒ 文档不在门禁内，不为凑 prettier 绿重排表格 |

### 4.8 W1-05 红项自检（证明新断言不是空跑）

| 变异（临时改真实源码，跑完即回退） | 预期 | 实测 |
| --- | --- | --- |
| `venueDeletePathId` 的 `return /^[1-9][0-9]*$/.test(raw) ? raw : undefined` → `return raw`（即非正整数也放行） | 「契约外的形态一律拒绝」变红 | 红：`expected '' to be undefined`（1/30 失败项之一） |
| `venueRemovedCount` 的 `Array.isArray(ids) ? ids.length : undefined` → `: 0`（缺字段补 0） | 「外壳缺字段或形状不合时回吐 undefined，绝不补 0」变红 | 红：`expected +0 to be undefined`；两轮变异合计 **2 failed / 28 passed** |
| 删掉根节点 `:data-last-delete-outcome="deleteOutcomeAttr(lastDeleteOutcome)"` 一行 | 「根节点镜像版本、结论与回执条数」变红 | 红：1 failed / 29 passed，`expected '<script setup…' to contain ':data-last-delete-outcome="deleteOutc…'` |

三处变异均已回退，并用 `diff` 证明回退后文件与变异前**逐字节一致**（`GUARD_REVERT_IDENTICAL` / `INDEX_REVERT_IDENTICAL`），回退后重跑 V4 = 30/30 全绿。

---

## 五、给 work5 的详细测试方案

### 5.0 测试前置（不满足直接记 BLOCKED_DEPLOY / BLOCKED_MENU，不得判页面缺陷）

1. 前端必须**重建产物**后再验：portal `:5581` 提供的是预构建哈希包，改源码不等于线上生效。**顺序不可颠倒**：先 `pnpm --filter @futurefab/ui-sdk-language run build`（本批三条新文案在语言包，其 `main` 指 `dist/index.js`），再 `pnpm --filter @futurefab/ui-app-smp-settings run build`；然后确认加载的 chunk 名是 `venue-management-*.js`（本批收口时为 `venue-management-D-KD8keh.js`）。任一步跳过 ⇒ 标 `BLOCKED_DEPLOY`，不得据此判「文案没生效」为页面缺陷（见 §7 B15）。
2. 网关 `:9090` 与 system 服务在跑，场地路由可达；菜单实际下发 `/settings/venue-management` 入口——取不到入口标 `BLOCKED_MENU`。
3. 登录账号需 `system:venue:list / add / edit / remove` 权限；缺哪个就只跑能跑的用例并标 `BLOCKED_MENU`。
4. 主数据见 §6，缺一即 `BLOCKED_DATA`，不得跳过断言。
5. 每条用例都要抓 HTTP method + URL + 请求头（重点 `X-Request-Id` / `X-Management-Revision`）+ response body，并记录是否出现 400 `INPUT_INVALID`。

### 5.1 TC-VENUE-DELETE-OK 正常删除（守卫写两头齐全）

- 前置：D1（无引用、无子节点的叶子场地）。
- 步骤：列表定位该场地行 → 点删除 → 确认弹窗点「确定」。
- 期望：`DELETE /dev-api/system/smp/venue/{venueId}`，**无 Body**；请求头含 `X-Request-Id`（UUID）与 `X-Management-Revision`（等于当前外壳版本）；response `code=200`，`data=true`，顶层 `msg` 为场地删除成功口径；页面提示「删除成功」并自动刷新；`data` 里若带 `managementRevision`，本地缓存应跟进（下一次写用新版本）。

### 5.2 TC-VENUE-NOREV 缺版本短路（本批核心负例，必须零请求）

- 制造方式（选一，并记录用了哪种）：(a) 在 DevTools 里 block 掉 `pageList` 后刷新页面，使外壳版本从未取到，且已有版本被清空——若 UI 无法清空则改用 (b) 断网瞬间点删除 / (c) 让 `pageList` 返回不带 `managementRevision` 的壳。
- 期望（三条缺一即判缺陷）：
  1. Network 里**没有任何 `DELETE /smp/venue/` 请求**（这是 §13.3 短路的唯一硬证据）；
  2. 页面出现「未取到管理版本，已取消本次操作，请刷新列表后重试」；
  3. 后端不产生 400：`sys_management_request` 里**不出现新的成功回执行**（守卫写回执与业务同事务提交，被拒的请求根本不落表），且 `sys_venue` 中目标场地 `del_flag` 仍为 `0`。
- 注意：`sys_management_request` 只有 `actor_user_id / request_id / operation_code / payload_hash / result_json / create_time / expires_at` 七列，**没有 http_status 与 error_code**，因此它只能证明「有没有真的写成功」，**不能**用来查 400/409；且守卫类 400/409 是 WARN 级、**不落日志文件**。所以本用例的硬证据是第 1 条（Network 零请求）+ 第 3 条（回执表零新增 + del_flag 未变）；不得因「日志里没报错」就判定通过。

### 5.3 TC-VENUE-REFEXISTS 引用保护提示可读

- 前置：D2（被实验室或设备引用的场地）。
- 期望：`DELETE` 返回 **409**，body `errorCode="REFERENCE_EXISTS"`，`msg` 含「场地或其子树被实验室/设备引用，无法删除」；页面文案为「**该场地或其下级场地仍被实验室或设备引用，请先解除关联**：…」，**不得**出现「变更负责人」这类主数据口径；弹窗/行数据保持原状，场地未被删除（刷新后仍在）。

### 5.4 TC-VENUE-SUBTREE 子树引用同样阻塞

- 前置：D3（父场地本身无引用，但其子场地被引用）。
- 期望：对 D3 的 DELETE 返回 409 `REFERENCE_EXISTS`（整棵子树原子判定），提示同 5.3；数据库无半删状态：只读核验父/子场地 `del_flag` 均保持原值。

### 5.5 TC-VENUE-CONFLICT 409 MANAGEMENT_CONFLICT 刷新重试

- 制造：两处会话/两次操作之间让版本落后（例如先在另一标签页删一条，再回到本页用旧版本删 D1）。
- 期望：409 + `errorCode="MANAGEMENT_CONFLICT"` + body 带 `currentManagementRevision`；页面提示「数据已被他人修改，请刷新后重试」（不透出主数据页文案）；随后再次点删除时，页面应**先重取版本**再发请求（Network 里能看到一次 `pageList` 或等价读口，且 DELETE 头里的版本是新的）；第二次成功 ⇒ 判定「作废 + 重取」链路成立。

### 5.6 TC-VENUE-SAVE-NOREV 新增/修改缺版本时不丢表单

- 制造同 5.2，改为在编辑弹窗点「保存」。
- 期望：无 `POST/PUT /smp/venue` 请求；弹窗**保持打开**且已填内容不丢，弹窗内错误区显示「未取到管理版本…」；恢复版本后再点保存应正常写入（200 + 回执 `managementRevision`）。

### 5.7 TC-VENUE-DRAG-NOREV 拖拽排序一条都不发

- 制造同 5.2，改为拖动同级场地行。
- 期望：Network 里 **0 条 `PUT /smp/venue`**；表格视觉顺序回到拖拽前（DOM 已还原）且展开状态正常；提示「未取到管理版本…」；随后恢复版本再拖，应看到按序串行 PUT 且每条头里版本递增。

### 5.8 TC-VENUE-REG 回归（既有能力未被本批破坏）

- 正常删除 / 新增 / 修改 / 拖拽排序各一条成功路径（5.1 之外补齐）；
- 场地详情侧边栏打开正常（注意：详情里**不再显示「显示顺序」字段**是 `f3437b047` 的产品改动，属预期，不得判缺陷；该处对应的测试漂移见 §4.6）；
- 场地树与 `可选场地 tree(excludeId)` 编辑器上级选择正常；
- 分页 / 关键字筛选 / 展开收起正常。

### 5.9 TC-VENUE-PERM 权限与入口

- 无 `system:venue:remove` 账号：删除入口不出现或点击后直接 return（**不得**发出 DELETE）；
- 无 `system:venue:list`：页面应停在权限拒绝态而不是拿不到版本后反复发写请求。

### 5.10 TC-VENUE-SUBTREE-CONFIRM 删除前必须看到子树口径（W1-05）

1. 进 `/settings/venue-management`，展开树，找一个**有下级**的场地行（记为 `P`）。
2. 用 `venue-row-delete-<P.venueId>` 点删除（不要用文案定位）。
3. 断言弹窗内容节点 `[data-testid="venue-confirm-delete"]` 存在，且文案含「全部下级场地」「整棵子树原子删除」。
4. **此步不得出现任何具体条数**：若页面显示「将删除 N 个」，判 FAIL（前端无有效后代数据，属伪造）。
5. 点取消：`venue-page` 的 `data-last-delete-outcome` 应保持 `idle`，Network 里**没有** `DELETE /smp/venue/*`。

### 5.11 TC-VENUE-DELETE-RECEIPT 回执 removedIds 决定成功文案（W1-05，本批核心新用例）

1. 账号需 `system:venue:remove`；用 §6 的 `P`（含 ≥1 个下级、整条子树无引用）。
2. 确认删除，抓 Network：`DELETE /system/smp/venue/<P.venueId>`，请求头两条齐全，**无 Body**。
3. 记录 response body：顶层 `managementRevision` 与 `data.removedIds`。
4. 断言三件：
   - 提示文案与 `data.removedIds.length` 一致（`>1` 时是「已删除 {count} 个场地（含该场地的下级场地）」，`==1` 时是通用「删除成功」）；
   - `venue-page[data-last-removed-count]` **等于** `removedIds.length`（不是 1，除非接口真返回 1）；
   - `venue-page[data-last-delete-outcome]` = `success`。
5. 若响应把版本只放在 `data.managementRevision` 而顶层为空 ⇒ 记 **BACKEND_CONTRACT_GAP**（页面只认顶层是既定口径，不由前端自行改），不要判页面缺陷。
6. 若 `removedIds` 字段缺失（后端未填）：文案应回落通用「删除成功」且 `data-last-removed-count` 为**空串**；此时判 PASS（负例口径正确），并在备注记「回执未带集合」。

### 5.12 TC-VENUE-REFBLOCKED-MIRROR 引用阻断与版本冲突在镜像上可区分（W1-05）

1. 用被引用的场地（§6 D4）删除 ⇒ 409 `REFERENCE_EXISTS`：文案为场地口径；`data-last-delete-outcome` = `reference-blocked`。
2. 用两个浏览器/两个会话制造版本落后（先在另一会话完成一次写）⇒ 409 非 `REFERENCE_EXISTS`：`data-last-delete-outcome` = `conflict`，且下一次写前自动重取版本。
3. 两者**必须不同**：若都记成 `conflict` 或都记成 `failed`，判 FAIL（分类漂移）。
4. 顺带确认 `data-management-revision` 在 409 后仍是**旧值或空**（页面做过期标记而非乱改），不得出现硬编码数字。

### 5.13 TC-VENUE-BADID 非正整数 ID 的形态闸（W1-05，构造型用例）

真实数据里 `venueId` 恒为正整数，本用例只能在**受控注入**下跑（例如 work9 用脚本把一行列表数据的 `venueId` 临时改成 `"0"` 或非数字串）：

1. 点删除后**不出现确认弹窗**，直接给「该场地记录缺少有效标识…请刷新列表后重试」。
2. Network **零请求**（既无 DELETE 也无 `pageList` 补版本读取）。
3. `data-last-delete-outcome` = `invalid-id`。
4. 无法安全构造时记 **NOT_VERIFIED**（本批已给契约测试层证据），不得改判为页面缺陷或前端失败。

### 5.14 每条用例统一记录模板

`用例号 / 页面 / HTTP method+URL / 请求头(X-Request-Id, X-Management-Revision) / request payload / response body(errorCode+msg) / 页面文案实测 / sys_management_request 只读核验结果 / 测试数据是否已清理 / 结论(CONTRACT_TESTED→HTTP_VERIFIED→BROWSER_VERIFIED 或 BLOCKED_*)`

---

## 六、测试数据建议

### 6.1 主数据清单

| 编号 | 需要什么 | 用途 | 缺失时 |
| --- | --- | --- | --- |
| D1 | 叶子场地，无实验室/设备引用，父级为顶级 | TC-VENUE-DELETE-OK、CONFLICT | `BLOCKED_DATA` |
| D2 | 直接被实验室或设备引用的场地 | TC-VENUE-REFEXISTS | `BLOCKED_DATA` |
| D3 | 父场地自身无引用、其子场地被引用 | TC-VENUE-SUBTREE | `BLOCKED_DATA` |
| D4 | 同一父级下 ≥3 个同级场地 | TC-VENUE-DRAG-NOREV / 排序回归 | `BLOCKED_DATA` |
| D5 | 一个可安全删除的临时场地（用例内自建自清） | 5.6/5.7 的写成功路径 | 用 UI 现建 |

命名建议统一前缀 `QA-B03-`，便于清理与复核；D2/D3 必须落在**测试专用实验室/设备**上，禁止动生产引用关系。

### 6.2 构造方式

1. 用页面「新增」建 D1/D4/D5（同时验 5.6 成功路径）；
2. D2/D3 由 SDMS/实验室配置页把测试实验室挂到该场地（或已有既有数据可复用，复用前先只读确认引用属实）；
3. 版本落后场景（5.5）用两个浏览器标签页制造，不做数据库改写。

### 6.3 可选只读 SQL（仅核验，不改数据；写操作一律禁止）

```sql
-- 目标场地与子树状态（del_flag：0 存在 / 2 删除；判定 D1/D2/D3 前置与用例后效）
SELECT venue_id, parent_id, ancestors, venue_name, venue_code, order_num, status, del_flag
FROM sys_venue WHERE venue_name LIKE 'QA-B03-%';

-- 守卫写成功回执（该表与业务同事务提交：被 400/409 拒掉的请求不落表）
-- 用途一：确认「短路 / 被拒」用例确实没有写入 ⇒ 期望窗口内零新增行
-- 用途二：确认成功用例确实落库 ⇒ 期望出现 ORG06 动作编码的新行
SELECT actor_user_id, request_id, operation_code, create_time, expires_at
FROM sys_management_request
WHERE create_time > NOW() - INTERVAL 1 HOUR
ORDER BY create_time DESC LIMIT 50;
-- 注意：本表没有 http_status / error_code 列，不能用来「查 400/409」；
-- 状态码与 canonical errorCode 只能从浏览器 Network 的 response body 取证。

-- 当前全局管理版本（managementRevision 是单一 SYSTEM 计数器，可与页面外壳顶层值比对）
SELECT scope_key, revision, update_time FROM sys_management_revision WHERE scope_key = 'SYSTEM';
```

注意：实际数据源是共享远端库，仓库 `nacos-config/` 是陈旧副本；连接信息以运行服务生效配置为准，**不得猜测凭据**。

---

## 七、已知风险与阻塞

| # | 事项 | 状态 / 需要谁的决策 |
| --- | --- | --- |
| B1 | 后端有 `GET /smp/venue/{id}/delete-check`（ORG05 / 定位 017），前端未接预检 UI：被引用只能在删除 409 后得知，而不是删除前提示 | 本批目标未含预检 ⇒ **未做**；请总控单列一批（可复用 Batch 01 的 check-delete UI 口径） |
| B2 | 部门（org）删除 M01-030 **不是**守卫写（`SysDeptController.java:191–193` 无 `@ManagementGuardedWrite`），但 `dept-management` 前端已在发 `writeMeta/revision` 头 | 属后端接线与契约不一致，**work1 不改后端、不猜口径**；需后端（work4）确认 M01-030 是否应升级为守卫写。在此之前本批故意不给 dept 加短路 |
| B3 | 同一「缺版本不短路」签名在全仓仍有 **68 处 / 约 35 个页面**（`grep -rn "writeMeta(await ensureRevision())" packages/app-smp-settings/src/views/`）：`menu-management`×2、`role-management`、`lab-*` 系列、`*-management` 主数据系列、`dict-*`、`alarm-*` 等；其中 `alarm-alarm-record/view.vue`、`lab-statusalarm/index.vue` 是**同一文件内部分写口已有闸、部分没有** | 跨模块/他人文件，需总控按页面分批授权清扫（建议按「有守卫写标注的接口」优先级排）。本批只清扫 venue 一页三处 |
| B4 | 场地删除无并发互斥：`remove()` 无 `deleting` 标志，快速双击会发两条 DELETE，第二条大概率 409 `MANAGEMENT_CONFLICT`（不会二次删除，但提示会让人误解为「被人改了数据」） | 本批目标未含交互互斥，**未改**；与 Batch 02 的 `if (deleting.value) return;` 口径不同源，建议并入下一批 |
| B5 | ~~场地页仍**无稳定 data-testid**~~ → **W1-05 已解决**：`venue-page` / `venue-row-actions` / `venue-row-details-{id}` / `venue-row-edit-{id}` / `venue-row-delete-{id}` / `venue-confirm-delete`（见 §3.7）。仍缺的是**批量选择态**与 SDK 弹窗按钮锚点（B6） | 基线项，本批转为已交付；work5 改用 testid 定位，不再按文案定位 |
| B6 | SDK 确认弹窗（`showConfirm`）的取消/确定按钮无 testid，页面只能锚内容节点 | 需一个 `sdk-smp-common` 批次，本批禁改 SDK |
| B7 | `venueWriteErrorMessage` 依赖后端 `msg` 可读性；`FutureFabErrorCode.REFERENCE_EXISTS` 的 `messageKey=futurefab.error.reference_exists` **在仓库内没有任何 i18n 定义**（唯一出现就是枚举行），实际文案来自抛异常时的中文字面量 | 后端文案国际化事项，属后端范围；英文环境下会得到中文 detail。请总控转后端确认是否补 messageKey |
| B8 | 拖拽排序复用 `PUT /smp/venue` 串行推进：任一中间条失败会出现「部分已改、部分未改」，页面提示只覆盖最后一条错误 | 后端未提供批量原子排序接口（§1.2）；页面侧本批未扩大改动。若要消除该窗口需后端补接口 |
| B9 | 本批只做到 `CONTRACT_TESTED`；HTTP / 浏览器 / 数据库层 **NOT_VERIFIED** | work5 按 §5 执行，work9 做真实浏览器验收 |
| B10 | 背景红：`tests/venue-management.test.ts` 1 条（`f3437b047` 删了「显示顺序」字段但没同步源码钉）—— **W1-05 已按 §4.6 口径把该钉反向化，该文件现全绿**；全量套件另有 14 文件 / 25 条红，`tests/localization.test.ts` 仍报 1 条（129 个缺失键，输出里**无任何 venue / settings-venue 键**） | 其余红项非本批引入、非本批可归因，未代改、未删断言（证据与清单见 §4.6）。work5 不得以全量绿为前置 |
| B11 | `sdk-language/.../smp-settings/{cn,en}.ts` 是 Batch 01 与 Batch 03 共用的**同一未提交文件** | 同一执行人（work1），无跨代理冲突；提交时若按批次切分，需总控指定切分方式（本批未 `add`） |
| B12 | **ORG06 的 1–100 批量容量在前端无载体**：后端 `venueIds.split(",")` + `DELETE_BATCH_MAX = 100` 支持一次删多条，但场地页是树形单行操作，没有任何多选/批量删除入口（§3.8）。本批只把 Path 形态闸收紧到「单个正整数」，未自造选择态 | **盘点结论 = `NO_UI`**（能力存在、入口不存在）。是否补批量删除需产品/总控裁决交互口径（部分失败如何呈现、回执 `removedIds` 与选择集不一致时说什么），不由 work1 猜 |
| B13 | 组织（dept）侧与场地侧**不同源**：`SysDeptController.remove` 无 `@ManagementGuardedWrite`（`:191–194`），且 `DeptApplicationServiceImpl.deleteDept` 仍抛 `SkeletonNotImplementedException("M01-030")`（`:300`）⇒ 组织删除在链路上是 501，不是「守卫写没对齐」 | 本批目标「场地/组织管理页面」只做了**场地**一侧；组织一侧属后端未实现（work4 范围），work1 不改后端、不给一个必然 501 的链路补短路。需总控向 work4 确认 M01-030 排期 |
| B14 | 删除成功回执里，页面**只认顶层 `managementRevision`**；若后端把版本只写进 `data.managementRevision`（LEGACY `AjaxResult` 不保证带顶层字段），则下一次写会走「兜底重取列表」而不是直接用回执 | `NOT_VERIFIED`：本批未做 HTTP 实测。work5 按 §5.11 第 5 步记录，出现该形态记 `BACKEND_CONTRACT_GAP`，不判页面缺陷 |
| B15 | 新文案住在 `@futurefab/ui-sdk-language` 的 `smp-settings/{cn,en}.ts`，该包 `main` 指向 `dist/index.js` ⇒ **改源码不等于线上生效**：必须先 `pnpm --filter @futurefab/ui-sdk-language run build`，再重建 `app-smp-settings`，portal `:5581` 才会发到带新文案的产物。本批已按此顺序重建（§4.7 V7/V8） | work5/work9 若跳过语言包重建，会在页面上看到「文案没变」的假缺陷；已在 §5.0 前置条件里写明 |

---

## 八、work5 测试记录区（work5 填写，work1 不预填结论）

| 用例号 | 执行人 | 日期 | HTTP method+URL | X-Request-Id | X-Management-Revision | response errorCode / msg | 页面文案实测 | 结论（HTTP_VERIFIED / BROWSER_VERIFIED / BLOCKED_*） | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-VENUE-DELETE-OK |  |  |  |  |  |  |  |  |  |
| TC-VENUE-NOREV |  |  |  |  |  |  |  |  |  |
| TC-VENUE-REFEXISTS |  |  |  |  |  |  |  |  |  |
| TC-VENUE-SUBTREE |  |  |  |  |  |  |  |  |  |
| TC-VENUE-CONFLICT |  |  |  |  |  |  |  |  |  |
| TC-VENUE-SAVE-NOREV |  |  |  |  |  |  |  |  |  |
| TC-VENUE-DRAG-NOREV |  |  |  |  |  |  |  |  |  |
| TC-VENUE-REG |  |  |  |  |  |  |  |  |  |
| TC-VENUE-PERM |  |  |  |  |  |  |  |  |  |
| TC-VENUE-SUBTREE-CONFIRM (W1-05 §5.10) |  |  |  |  |  |  |  |  |  |
| TC-VENUE-DELETE-RECEIPT (W1-05 §5.11) |  |  |  |  |  |  |  |  |  |
| TC-VENUE-REFBLOCKED-MIRROR (W1-05 §5.12) |  |  |  |  |  |  |  |  |  |
| TC-VENUE-BADID (W1-05 §5.13) |  |  |  |  |  |  |  |  |  |

后端日志 / 表核验记录（`RequestMetaInvalidException`、`GlobalExceptionHandler`、`sys_management_request` 查询结果）：

数据清理确认（`QA-B03-*` 是否已全部移除、引用是否已解除）：

---

## 九、最终结论区（由总控 / work5 / work9 填写，work1 不做最终结论）

| 范围 | 层级 | 结论 | 证据 |
| --- | --- | --- | --- |
| 场地删除守卫写两头 + 缺版本短路 | 静态 / 编译 / 契约测试 | work1 自述：通过（见 §4 第 1–6 项） | 本 MD §4 |
| 场地删除守卫写两头 + 缺版本短路 | HTTP 联调 | 待 work5 | §5.1 / §5.2 记录 |
| 场地删除守卫写两头 + 缺版本短路 | 浏览器验收 | 待 work9 | §5 全量记录 |
| 同页新增/修改与拖拽排序短路 | HTTP / 浏览器 | 待 work5 / work9 | §5.6 / §5.7 |
| 部门（org）删除守卫写口径 | 未开始 | `BACKEND_CONTRACT_GAP` 待裁决（B2） | `SysDeptController.java:191–193` |
| 场地 check-delete 预检 UI | 未开始 | 待总控下发批次（B1） | `SysVenueController.java:112–114` |
| 全仓其余 68 处缺版本短路 | 未开始 | 待总控清扫排期（B3） | §7 B3 |
| **W1-05** ORG06 Path 形态闸（非正整数不发 DELETE） | 静态 / 编译 / 契约测试 | work1 自述：通过 | §3.5、§4.7 V4、§4.8 变异 1 |
| **W1-05** 子树口径文案 + 回执 `removedIds` 计数 | 静态 / 编译 / 契约测试 | work1 自述：通过（**仅**到契约层：文案键与计数来源已断言，真实条数未测） | §3.6、§4.7 V4/V7/V9 |
| **W1-05** 子树口径文案 + 回执 `removedIds` 计数 | HTTP / 浏览器 | **`NOT_VERIFIED`** | 待 work5 §5.10 / §5.11、work9 |
| **W1-05** 删除结论镜像（`data-last-delete-outcome` / `data-last-removed-count` / `data-management-revision`） | 静态 / 契约测试 | work1 自述：通过（属性拼装与归零已断言） | §3.7、§4.7 V4/V9 |
| **W1-05** 删除结论镜像 | 浏览器 | **`NOT_VERIFIED`** | 待 work5 §5.12 用真实 409 两类分别核验 |
| **W1-05** 行内删除 `data-testid`（含确认弹窗内容节点） | 静态 / 契约测试 | work1 自述：通过；SDK 按钮锚点仍缺（B6） | §3.7、§4.7 V9 |
| **W1-05** 被服务产物已含本批改动 | 构建 | work1 自述：通过（`venue-management-D-KD8keh.js` 25.79 kB / gzip 7.00 kB） | §4.7 V8 |
| **W1-05** 被服务产物已含本批改动 | 部署生效 | **`BLOCKED_DEPLOY`**（仓库构建通过 ≠ portal `:5581` 已换包；语言包 `dist` 需在部署侧同步重建） | §5.0 第 1 条、§7 B15 |
| **W1-05** ORG06 1–100 批量容量 | 前端入口 | **`NO_UI`**（盘点结论，未自造交互） | §3.8、§7 B12 |
| **W1-05** 组织（org）删除对齐 | 未开始 | `BACKEND_CONTRACT_GAP`：M01-030 仍 501 且无守卫写注解 ⇒ work4 范围 | §7 B13、`DeptApplicationServiceImpl.java:300` |

禁止把本 MD 的「契约测试通过」上调为 HTTP / 浏览器 / 现场验收通过。

**本批新增的禁用措辞（work5 / work9 记录时同样适用）**：

- 不得写「子树已按预期删除 N 个」，除非 N **逐项来自 response 的 `data.removedIds`**（页面文案同源；`removedIds` 缺失时页面回落通用「删除成功」，此时结论只能写「回执未带集合」）。
- 不得写「守卫写已在后端生效」「产物已上线」：本批只证明仓库内构建产物含改动（§4.7 V8/V9），portal 换包属 `BLOCKED_DEPLOY`。
- 不得写「引用之外的副作用已核验」：场地删除只核验了「被引用 ⇒ 409 阻断」，实验室/设备侧数据是否受影响不在本批断言范围内（§3.6 第二行「不做什么」）。
