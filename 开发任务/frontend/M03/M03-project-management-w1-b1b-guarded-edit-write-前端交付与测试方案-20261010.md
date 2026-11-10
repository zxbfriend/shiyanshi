# M03 项目管理（project-management）前端批次 W1-B1b · M03-005 修改口改指守卫写双头与缺版本短路

> 本文件是**测试方案与交付登记**，不是验收结论。浏览器列全部 `NOT_VERIFIED`，由独立 work 只读复审后实跑回填。
> 对应后端批次：批 1（M03-005 P05 项目修改接线，见 `docs/开发任务/03-接线与阻塞记录/模块台账与其他/W1-501CLR-可达501分层盘点与裁决授权包-20261010.md` §6 批 1 与 §9）。

## 1. 基本信息

| 项 | 内容 |
| --- | --- |
| 执行人 | work1 |
| 日期 | 2026-10-10 |
| 覆盖页面 | 项目管理（M03）新增/修改弹窗 `project-editor.vue` |
| 覆盖写口 | M03-005 `PUT /resource/project/{projectId}`（本批从 legacy 裸 `PUT /resource/project` 改指新守卫口）；M03-004 `POST /resource/project` 行为不变 |
| 版本来源口 | `X-Management-Revision` ← 编辑取 M03-002 `GET /resource/project/{id}` 外壳顶层 `managementRevision`（`@CurrentManagementRevision`），新增取 M03-001 列表外壳；`expectedVersion`（对象并发版本）← 同详情响应体 `version` 字段（后端 `ProjectDetailView.version`），别无合法来源 |
| 依赖前端能力 | `packages/sdk-smp-api/src/guarded-write.ts`（`writeHeaders`：`X-Request-Id` 必发，revision 缺失则不发该头由后端 400）、`packages/app-smp-settings/src/shared/use-guarded-write.ts`（`ensureRevision`/`writeMeta`/`applyWrittenRevision`/`invalidateOnConflict`） |
| 交付状态口径 | 最高 `CONTRACT_TESTED`（vitest＋类型检查＋dts 重建）；HTTP / 浏览器 `NOT_VERIFIED`；后端 `IMPLEMENTED + CONTRACT_TESTED`；门户产物 `BLOCKED_DEPLOY`（源码改≠:5581 服务产物已重建） |

## 2. 本批修改文件清单（全部前端，零后端、零 SQL、零 Git 写操作）

| 文件 | 改动 |
| --- | --- |
| `packages/sdk-smp-api/src/project.ts` | `projectApi.save()` 编辑分支由 `PUT /resource/project` 改为 `PUT /resource/project/{projectId}`（`encodeURIComponent`，主键进路径，后端 Path 覆盖 Body）；入参类型补 `expectedVersion?: string`；`Project` 接口补 `version?: string` 并注释登记"详情外壳回带、M03-005 `expectedVersion` 唯一合法来源"；守卫写注释从"仅 M03-004"扩为 M03-004/M03-005 双口 |
| `packages/app-smp-settings/src/views/project-management/project-editor.vue` | 新增 `objectVersion` ref：`show()` 开窗前置空、`loadDetail()` 由 `data.version` 回填；保存前判据由"只有新增才短路"改为**新增与修改都是守卫写**——缺 `managementRevision` 一律短路，修改再额外要求详情回带的对象版本，缺失即短路并提示，不发请求、不猜 0、不沿用上一条；提交载荷在编辑分支带 `expectedVersion` |
| `packages/sdk-language/src/language/smp-settings/cn.ts`／`en.ts` | `settings-project.versionMissing` 中英双登记（沿用同模块既有 `missingDetail` 命名位） |
| `tests/project-management.test.ts` | 原"修改也走集合级路径"钉桩按新事实翻正为 `PUT /resource/project/1001`，并新增双头（`X-Request-Id`/`X-Management-Revision`）与体里 `expectedVersion` 断言；新增 `M03-005 guarded edit write (frontend leg)` 两条源码级钉桩（缺版本短路、不回落到 legacy 集合 PUT） |

未改：后端任何文件；legacy 裸 `PUT /resource/project`（`ResProjectController#edit(ResProject)`）**仍保留**——停口与前端改指必须同批协调，见盘点文档 §5 F-2；`packages/sdk-smp-api/src/modules/resource/project.ts:30 updateProject()` 是零引用旧导出，本批不动。

## 3 验证记录（原始退出码，管道末端码不作数）

| 步骤 | 命令 | 结果 |
| --- | --- | --- |
| 定向单测 | `pnpm exec vitest run --config vitest.config.ts tests/project-management.test.ts` | `Tests 11 passed (11)`，`VITEST_EXIT=0` |
| 相关面复跑 | 同上＋`tests/flat-sdk-guarded-write-meta.test.ts` | `Test Files 2 passed (2)`，`Tests 18 passed (18)`，`VITEST_EXIT=0` |
| 反空转（变异） | 临时把 `save()` 的编辑分支改回集合路径 `"/resource/project"` | `Tests 2 failed \| 9 passed (11)`，`VITEST_EXIT=1`；红的是 `Project backend contract > keeps query fields…` 与 `M03-005 guarded edit write > sends the edit to the id-scoped guarded door`——正是这两条该红 |
| 还原 | 由 `/tmp` 备份 `cp` 回写 | `sha1 8ebb21c1f9c7…` 与变异前一致，复跑回到 `11 passed` |
| SDK 类型检查 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | `SDK_TC=0` |
| 语言包类型检查 | `pnpm --filter @futurefab/ui-sdk-language run type-check` | `LANG_TC=0` |
| SDK dts 重建 | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | `DTS=0` |
| 宿主应用类型检查 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 首跑 `APP_TC=1`：`src/router/index.ts(501,13)` 路由名不在联合类型内 ⇒ 系 `sdk-smp-stores` 的 `dist-types` 陈旧，`pnpm --filter @futurefab/ui-sdk-smp-stores run build-dts`（`STORES_DTS=0`）后该错消失；复跑仍 `APP_TC2=1`，唯一残留是 `src/views/lab-labbenchreactor/reactor-write.ts(110,23): Cannot find name 'source'`——该文件属他 lane 在途未提交改动，非本批范围（AGENTS 规则 26 越界不修，已上报总控） |
| 全量前端单测 | `pnpm run test:unit`（根工作区） | `Test Files 15 failed \| 109 passed (124)`；`Tests 33 failed \| 1366 passed (1399)`，`VITEST_EXIT=1` |

## 4 全量 33 红的归因取证（不把"面不交集"当证据）

基线复算：**把本批 5 个前端文件临时回退到 `HEAD` 版本**（先 `cp` 备份并 `sha1sum` 校验，回退用 `git show HEAD:<path> > <path>`，随后原样还原并逐一比对 sha1），只跑那 15 个红文件：

- 基线（无本批改动）：`Test Files 15 failed (15)`，`Tests 33 failed \| 172 passed (205)`，`VITEST_EXIT=1`
- 加回本批改动后（同 15 文件＋本批 2 文件）：`Test Files 15 failed \| 2 passed (17)`，`Tests 33 failed \| 190 passed (223)`，`VITEST_EXIT=1`

即 **33 红在有无本批改动下逐条同数同文件**，全部先于本批存在；本批新增 18 例（11＋7）全绿，未新增任何红。红文件清单（供 owner lane 认领）：`lab-labbenchreactor-guarded-write`(6，与其 `reactor-write.ts` 编译错同源)、`monitor-log`(4)、`dialog-pane-padding`(4)、`settings-merge-regressions`(3)、`dict-tag`(3)、`config-management`(2)、`settings-filter-toolbar`(2)、`workflow-management`(2)、`detection-workbench-ui`/`iconfont-build`/`labgroup-management`/`localization`/`navigation`/`profile`/`scroll-pagination` 各 1。

## 5 仍未验证 / 阻塞

- `HTTP_VERIFIED`、`BROWSER_VERIFIED`：未做。需真实网关＋后端服务＋登录态，取一次 M03-002 详情的 `version`，改一笔并核 `X-Request-Id`/`X-Management-Revision` 请求头、`MANAGEMENT_CONFLICT`/`VERSION_CONFLICT` 外壳与 409 后重取版本。
- 门户产物：`:5581` 供的是预构建哈希包，本批未重跑应用构建，故页面实际未变（`BLOCKED_DEPLOY`）。
- `BLOCKED_DESIGN`/待裁决：legacy 裸 `PUT /resource/project` 是否停口（盘点文档 §5 F-2）；`modules/resource/project.ts` 旧导出是否清理。
- 数据库：本批零 SQL；后端 CAS/唯一索引仅在契约测试层，真实 MySQL `NOT_VERIFIED`。

## 6 独立复审（2026-10-10 已收）

独立复审 work 结论：**PASS，无阻塞缺陷**。逐项目视复核要点：

- 契约对齐：后端 `ResProjectController.java:236 @PutMapping("/{projectId}")` ↔ 前端 `project.ts:123` 编码 id 路径；`WriteMeta` 以头覆盖 Body（`:241-242`），`expectedVersion` 只从 Body 读（`ResProjectApplicationServiceImpl.java:331`）。
- 版本来源：前端 `objectVersion` 唯一填充点是 M03-002 详情 `data.version`（`project-editor.vue:180`），开窗清零（`:155`），不猜 0、不借他模块版本。
- 短路纪律：缺 revision 与缺 objectVersion 均在发请求前 `return`（`:229-234`、`:237-243`）；`guarded-write.ts:24` 缺 revision 不发头，不伪造。
- 附带伤害：diff 仅本批 5 文件，只增不删；`updateProject` 全库零调用方，属实。
- 复现实跑：`project-management`(11) + `flat-sdk-guarded-write-meta`(7) = `Tests 18 passed (18)`，`VITEST_EXIT=0`。
- 33 红归因：复审认可"回退 5 文件复跑仍同 15 文件 33 红"的隔离法，并另行抽查两红文件确为无关漂移（pump-speed/password-validity/workflow-editor 列表与 operlog 路由）。
- 层级口径：文档只到 `CONTRACT_TESTED`，无 overclaim。

非阻塞观察（记入待办，不改本批）：幂等恢复重放沿用详情加载时的旧 `expectedVersion`，会得到 `VERSION_CONFLICT`——失败安全方向，可在 HTTP 验收批一并确认是否需要刷新后重试策略。
