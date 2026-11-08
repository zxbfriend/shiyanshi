# M04 前端批次 W1-04 · 工艺模板（补液方案）版本身份/固定包信息只读展示 + 契约错误码可读提示

> 本 MD 由「批次 02（2026-10-05，原文件名 `M04-template-batch02-package-engineering-display-前端交付与测试方案-20261005.md`）」延续而来，
> 按总控 2026-10-06 的 W1 命名口径更名，并叠加 **W1-04 追加轮**（§2.2、§3.6、§4.2，测试用例增补在 §5.1 A6—A9 与 §5.2 B16—B19）。批次 02 已交付内容未被推翻，仅按新后端事实修正了 §3.1 的一处口径与 §7 的 R1 状态。

## 1. 基本信息

| 项 | 内容 |
|---|---|
| 批次 | **W1-04**（总控 2026-10-06 W1 序列表第 4 行：M04 工艺模板/模板版本页面 · 目标「schema2/engineering/hash 只读展示、错误提示」）；承接批次 02 同一页面同一范围 |
| 模块 | M04 工艺与方案管理 · 工艺模板（本期只有 FEEDING 一类有页面） |
| 页面 | `/settings/feeding-template-management`（路由 `packages/app-smp-settings/src/router/index.ts:488`，菜单组件 `process/feeding/index`） |
| 页面源码 | `futurefab-frontend/packages/app-smp-settings/src/views/feeding-template-management/` |
| 接口族 | `/system/process/templates/*`（`list`、`{templateId}`、`POST /`、`PUT /{id}`、`{id}/copies`、`{id}/status`、`{id}/delete`、`binding-preview`、`model-options`、`model-facts`、`feeding-resource-facts`、`candidates`） |
| 后端入口（只读参考，本批未改） | `ProcessTemplateController.java:42`（base `/process/templates`）、`ProcessTemplateApplicationApplicationServiceImpl.java`、`domain/vo/m04/VersionMeta.java`、`domain/vo/m04/TemplateDetailView.java` |
| 开发人 | work1（不做最终测试结论） |
| 日期 | 批次 02：2026-10-05；**W1-04 追加轮：2026-10-06 01:35—01:55** |
| HEAD | 批次 02 基线 `06ab969c`（开工前 `18b62175`，其间 `3868bc5c`/`def8bd53`/`660fd6d4`/`7f42eb2c`/`06ab969c` 均未触碰本批文件）。**W1-04 收口验证在 HEAD `96f85408`**，期间 `b913a42b`（M04_VERSION_V2 身份摘要）、`c6ec9958`/`0d5dc91e`（M07）、`96f85408`（M06 API10 provider）均为后端改动，未触碰 `futurefab-frontend/` |
| 是否提交 / 推送 | **未 `git add`、未 commit、未 push**；交付物 = 工作树改动 + 本 MD |
| 本批结论层级 | IMPLEMENTED + CONTRACT_TESTED + 生产构建通过；HTTP / 浏览器 / 数据库 / 现场 = **NOT_VERIFIED** |
| 七项目标口径复核 | 本批只有 4 项目标，逐条见 §3.5；其中「工程段字段展示」按契约**只能展示为未取得**，不可当作已完成取数 |

**本批最重要的三条结论（先读再测）**

1. 后端 M04-002/M04-004 的 HTTP 响应里**只有 `canonicalHash` 一个哈希类字段**（`VersionMeta.java:14-32`）。`packageSchemaVersion`、`packageHash`、`engineeringSchemaVersion`、`engineeringHash`、`workflowDefinition` 属固定包 Port 与 `prc_template_version` 列，**没有任何 M04 HTTP 接口透出**，本批按「不伪造工程段」的口径只列字段名并标注未取得。
2. M04 模板页的**四条写路径（新增/修改/复制/状态/删除）静态判定都会 400**：后端读口缺 `@CurrentManagementRevision` + 编辑器根本不发 `managementRevision`，而服务层无条件构造 `WriteMeta`。详见 §7 B1，属**总控裁决项**，本批未擅改后端、未伪造版本值。
3. 页面**存在**（不是 NO_UI），但 M04 其余五类模板（Config/Perfusion/Sampling/AutoControl 与版本列表页）**没有页面**，见 §3.4 范围声明。

---

## 2. 修改文件清单

工作树实测（`git diff --numstat` + `git status --short`，相对 HEAD `06ab969c`）：本批 5 个已跟踪文件 +239/−19，3 个新增未跟踪文件。

| # | 文件 | 状态 | 改动点（`+/-`） |
|---|---|---|---|
| 1 | `packages/sdk-smp-api/src/processTemplate.ts` | 修改 +35/−6 | `TemplateDetail.version` 由自造四字段改为具名 `TemplateVersionMeta`（对齐后端 `VersionMeta.java`）；删掉后端不存在的 `createdAt`/`createdByUserId`；新增 `TemplateChangeKind`、`TemplateCalculationProfile`；`TemplateDetail` 补 `applicability?`、`redactedPaths?` |
| 2 | `.../feeding-template-management/m04-version-identity.ts` | **新增** | 纯函数：`versionIdentityRows(meta, formatTime?)`（八行装配）、`shortHash()`（64 位哈希截断展示、title 保留全值）、`M04_PACKAGE_ONLY_FIELDS`（五个未透出字段名登记） |
| 3 | `.../feeding-template-management/m04-template-error.ts` | **新增** | 纯函数：`templateErrorCode()`（只从 `ApiError.errorCode` 取码）、`templateErrorKey()`、`templateErrorMessage()`；`M04_ERROR_KEYS` 13 个码、`M04_REQUESTED_ERROR_CODES` 六码清单 |
| 4 | `.../feeding-template-management/feeding-template-editor.vue` | 修改 +93/−8 | `versionMeta`/`identityRows` 状态（`:75-78`）；`describeError()`（`:81`）替换 5 处裸 `errorMessage`（`:312/:383/:497/:861/:919`）；`resetForm` 清空身份（`:781`）；`applyDetail` 只在非复制态持有版本身份（`:833`）；模板新增只读版本身份块（`:1013-1040`，testid `version-identity-title`/`version-item-<id>`/`version-package-note`）；新增对应 scoped 样式 |
| 5 | `.../feeding-template-management/index.vue` | 修改 +10/−5 | 引入 `templateErrorMessage`，新增 `describeError()`（`:65`）替换内联错误通道 `:227/:293` 与 `showError` 通道 `:333/:367`；本批未动其守卫写体（`:325/:361` 的 `managementRevision: revision.value` 口径见 §7 R1） |
| 6 | `packages/sdk-language/src/language/smp-settings/cn.ts` | 修改 +43/−0 | **本批段 `@@ -1642,0 +1656,30`（+30）**：16 个版本身份 key + 13 个错误码 key。其余 `+2`（:366 段）与 `+11`（:419 段）属批次 01/03 的在途改动，非本批 |
| 7 | `packages/sdk-language/src/language/smp-settings/en.ts` | 修改 +58/−0 | **本批段 `@@ -1695,0 +1714,40`（+40）**：同 key 英文，长句按 prettier 换行所以行数多于中文。`+4`/`+14` 同属批次 01/03 |
| 8 | `tests/m04-feeding-template-version-identity.test.ts` | **新增** | 17 例：八行顺序与取值、哈希截断/全值、时间格式化注入、null 不补值、未登记枚举原样透出、新增/复制不渲染、五字段防伪透出、六码 key 齐备且互不相同、取码只认 `ApiError.errorCode`、已登记码走固定口径、未登记码回落服务端 msg、中英目录 key 对称、页面接线源码钉（`v-if="identityRows.length"`、复制态清空、禁止硬编码 revision、禁止裸 `errorMessage`） |

未触碰：后端 Java/Mapper/XML、SQL、M03/M05/M06/M07/M09 页面、客户只读材料、`docs/详细设计/history/**`、他人在途 `.tmp-*.py`。共享文件 `shared/format-time.ts`、`sdk-smp-api/src/client.ts` 本批只读复用未修改。

### 2.2 W1-04 追加轮改动的文件（与批次 02 同批文件，未新增文件）

相对 HEAD `96f85408` 的 `git diff --numstat` 是**批次 02 + W1-04 的累计值**；下表右列给出 W1-04 单批的实际增量。

| # | 文件 | 累计 `+/-` | W1-04 单批增量与改动点 |
|---|---|---|---|
| 1 | `.../feeding-template-management/m04-version-identity.ts` | 新增文件（未跟踪） | +37 行：`CanonicalHashDomainRow` 接口、`M04_CANONICAL_HASH_DOMAINS`（V1/V2 两代算法域，只读常量）、`hashDomainTestId()`；`M04_PACKAGE_ONLY_FIELDS` 注释补「0 VO / 0 controller 命中」的实测依据 |
| 2 | `.../feeding-template-management/m04-template-error.ts` | 新增文件（未跟踪） | +4 行：登记 `VERSION_CONFLICT → settings-feeding.errorVersionConflict`；文档注释改为**带命中计数的可达性分级**（应用服务 24/6/6/3/3/2/2、Port 17/3/2/5/1、`RESOURCE_FACTS_UNAVAILABLE` 两目录 0 命中、`PERMISSION_DENIED` 由鉴权层抛出） |
| 3 | `.../feeding-template-management/feeding-template-editor.vue` | +143/−8 | +50 行：版本身份块内新增 `version-hash-domains` 说明区（两代口径 + 归属不可判定 + 内容 schema 原值口径）、`M04_CANONICAL_HASH_DOMAINS as hashDomainRows`/`hashDomainTestId` 导入、对应 scoped 样式。累计值里 `+93/−8` 属批次 02 |
| 4 | `packages/sdk-language/src/language/smp-settings/cn.ts` | +96/−0 | 本批 +15 行、8 个 key（`hashDomainTitle`/`hashDomainLegacyTitle`/`hashDomainLegacyCovers`/`hashDomainV2Title`/`hashDomainV2Covers`/`hashDomainUndecidable`/`contentSchemaNote`/`errorVersionConflict`，落在 `settings-feeding` 段）。累计值含批次 01/02/03 与 W1-03（`settings-culture` 段）的在途 key |
| 5 | `packages/sdk-language/src/language/smp-settings/en.ts` | +130/−0 | 同 8 个 key 的英文，长句按 biome 换行故行数更多 |
| 6 | `tests/m04-feeding-template-version-identity.test.ts` | 新增文件（未跟踪） | +12 用例（17 → **29**）：新增 `describe` 两组，见 §4.2 V4 |

`packages/sdk-smp-api/src/processTemplate.ts`（累计 +35/−6）与 `index.vue`（累计 +10/−5）本轮**未再改动**；SDK 类型未变，故 `build-dts` 只为让 app 端解析到既有 `TemplateVersionMeta`（见 §4.2 V5）。


---

## 3. 功能改动说明

### 3.1 字段可得性矩阵（本批展示口径的依据）

| 任务要求的字段 | 后端真实出处 | 是否进 HTTP 响应 | 本批口径 |
|---|---|---|---|
| `canonicalHash` | `VersionMeta.java:26`；`toVersionMeta` `ProcessTemplateApplicationApplicationServiceImpl.java:1134-1146` | **是**（M04-002 `version.canonicalHash`） | 只读展示，截断「前 10…后 6」，完整值放 `title`；null 显示「接口未提供」 |
| `packageSchemaVersion` | 固定包 `TemplatePackage.java:23`，`TemplatePackagePortImpl` 导出/解释（Port 侧） | **否** | 不展示值。仅在说明条里列字段名 + 「不在本接口响应内，前端未取得」 |
| `packageHash` | `TemplatePackage.java:35`，`computeHash(...)` 摘要 | **否** | 同上 |
| `engineeringSchemaVersion` | `PrcTemplateVersionRow.java:59`（`prc_template_version.engineering_schema_version`） | **否**（`toVersionMeta` 未拷贝该列） | 同上 |
| `engineeringHash` | `PrcTemplateVersionRow.java:63`；已被折进 `canonicalHashV2(content, applicability, bindings, engineeringHash)`（应用服务 `:870-871` 写入 `version.canonical_hash`） | **否**（只以派生形式体现在 canonicalHash 里） | 同上；页面不声称拿到了工程段 |
| `workflowDefinition` | 固定包八键之一（`TemplatePackagePortImpl` 的 `computeHash` 入参） | **否** | 同上 |
| 附带真实可得：`versionNo`、`contentSchemaVersion`、`calculationProfile`、`changeKind`、`savedAt`、`savedByUserId`、`previousVersionId` | `VersionMeta.java:14-32` | **是** | 与 `canonicalHash` 同块展示；`nameSnapshot` 不重复展示（页头模板名已可见） |

补充事实（影响判读，不是本批改动）：HEAD 提交 `06ab969c` 把 schema1 历史固定包收口为**保留只读**，候选生效只认 schema2 完整包。因此任何「该版本已可被 M03 消费」的成功措辞都没有接口依据，本批文案特意写成「不代表已核验，也不代表可被 M03 消费」。

### 3.2 版本身份只读块（编辑器）

- 位置：`feeding-editor-header` 之后、`<a-tabs>` 之前（`feeding-template-editor.vue:1013`），只读、无控件、不参与提交体。
- 渲染条件：`v-if="identityRows.length"`，即**只有真正读到 `detail.version` 的编辑态**才出现；
  - 新增：`resetForm()` 后 `versionMeta` 为 null → 不渲染；
  - 复制：`applyDetail(detail, copy=true)` 显式置 null（`:833`）→ 不渲染（复制产出的是新草稿，来源版本身份不属于草稿，展示会误导）。
- 八行顺序固定（测试钉住）：版本号 → 内容 schema → 计算口径 → 产生方式 → 规范哈希 → 保存时间 → 保存人 → 前一版本。
- 缺失口径：后端 `null`/未下发一律 `value = null`，页面显示「接口未提供」；**不补 0、不补 "—、不猜测首版**（`previousVersionId=null` 历史未知与首版在当前契约下不可区分）。
- 时间：`savedAt` 是带时区 ISO8601，交给页面既有的 `formatLocalTime`（`shared/format-time.ts`）本地化，原始 ISO 串放 `title` 便于核对。
- 说明条（`data-testid="version-package-note"`）：列出五个未取得字段名，固定文案，不随接口值变化。

### 3.3 错误码可读提示

`templateErrorMessage(reason, translate)`：先取 `ApiError.errorCode`（`client.ts:4-14`，后端 `ManagementGuardExceptionHandler.java:30-44` 与 `RequestMetaExceptionHandler.java:33-39` 都把 `errorCode` 放进响应外壳），命中登记表→固定口径；未登记→原样透出服务端 msg。**未知码绝不改写成成功或改写成别的语义。**

| 错误码 | HTTP | 本页链路是否真实可达（源码依据） | 文案要点 |
|---|---|---|---|
| `CONTENT_INVALID` | 400 | 码在 `FutureFabErrorCode.java:177`；抛出点在固定包 Port（`TemplatePackagePortImpl`），**M04 HTTP 是否命中待联调** | 固定包不合 schema，未解析；不降级解释 |
| `SCHEMA_UNSUPPORTED` | 400 | 同上（Port 侧，`TemplateDetailView` javadoc 已声明未知 schema 返回该码） | 暂不支持的 schema，前端不降级 |
| `SOURCE_VERSION_CONFLICT` | 409 | Port 侧（`FutureFabErrorCode.java:317`），HTTP 命中待联调 | 绑定来源版本已变化，重选来源 |
| `APPROVAL_CONTEXT_UNAVAILABLE` | 503 可重试 | Port 侧（`:145`） | 审批上下文暂不可用，**本次未执行** |
| `STATE_CONFLICT` | 409 | **可达**：应用服务 `:256`（绑定预览）、`:691/:711`（当前版本指针/乐观锁不匹配） | 已被其他操作修改，**本次未写入**，刷新重试 |
| `RESOURCE_FACTS_UNAVAILABLE` | 503 可重试 | `EngineeringBundleFactory`/M02 事实读取侧（`:283`） | 资源事实暂不可用，**本次未执行** |
| `INPUT_INVALID` | 400 | **可达**：应用服务 24 处 + `RequestMetaExceptionHandler`（写元数据缺失/非法也归这个码） | 请求不合契约，**本次未提交** |
| `SOURCE_STATE_CONFLICT` | 409 | 可达（`:251` 绑定来源必须启用） | 来源已禁用/删除 |
| `NAME_CONFLICT` | 409 | 可达（名称查重） | 同类型重名 |
| `ACTION_NOT_SUPPORTED` | 400 | 可达（应用服务 3 处） | 该模板类型不支持此操作 |
| `RESOURCE_MAPPING_UNRESOLVED` | 400 | 可达（应用服务 2 处） | 泵资源映射不完整 |
| `NOT_FOUND` | 404 | 可达（应用服务 6 处） | 记录不存在/已删除 |
| `PERMISSION_DENIED` | 403 | 网关/权限层通用 | 无权限 |
| `VERSION_CONFLICT`（**W1-04 新增登记**） | 409 | M04 侧唯一异常点 `TemplatePackagePortImpl:137`（Port 层，HTTP 命中未验证） | 模板对象版本与期望不符，**本次未写入**；刷新重试 |

关键区分：M04 的「模板已被他人改动」实际抛的是 `STATE_CONFLICT`（`writeUpdate:691` 实测），**不是** `VERSION_CONFLICT`；两者都登记但文案必须分开，避免把版本冲突误报成参数错误，也避免反过来。W1-04 的命中计数（HEAD `96f85408` 实测，含注释）：`service/impl/application/m04/` = INPUT_INVALID 24、STATE_CONFLICT 6、NOT_FOUND 6、NAME_CONFLICT 3、ACTION_NOT_SUPPORTED 3、SOURCE_STATE_CONFLICT 2、RESOURCE_MAPPING_UNRESOLVED 2；`service/port/m04/` = CONTENT_INVALID 17、APPROVAL_CONTEXT_UNAVAILABLE 5、SCHEMA_UNSUPPORTED 3、SOURCE_VERSION_CONFLICT 2、VERSION_CONFLICT 1；`RESOURCE_FACTS_UNAVAILABLE` 在两个目录 **0 命中**（契约要求登记，故保留文案）。

### 3.4 范围声明（为什么不做更多）

- M04 详细设计的 Config / Perfusion / Sampling / AutoControl 四类模板页与「模板版本列表 / 指定版本详情」（M04-003/M04-004）在前端**没有页面**；本批按「不强行造大页面」只在既有补液方案编辑器上做只读展示。
- SDK `processTemplateApi` 未封装 `/context`、`/{id}/versions`、`/versions/{versionId}`、`/sampling-resource-facts`；补这些封装需要新的调用方与测试口径，本批未补（避免造无人使用的死代码）。
- 前端路径写 `/system/process/templates/*`，后端 base 是 `/process/templates`（`ProcessTemplateController.java:42`），`/system` 前缀依赖网关路由；**源码层一致，运行态命中未验证**（BLOCKED_DEPLOY 风险，交给 work5/work9 用 Network 判定）。

### 3.5 四条目标逐条交付口径

| 目标 | 结论 |
|---|---|
| 1 只读展示六个字段（若存在版本详情面） | **部分交付**：`canonicalHash` 真实展示；另五个字段接口未透出，交付为「字段名 + 未取得」说明条，未伪造取值 |
| 2 六个错误码可读提示 | **交付**：13 码登记（含六码），可达性分级见 §3.3；CONTRACT_TESTED，HTTP 层由 work5 验证 |
| 3 页面不存在则 NO_UI/BLOCKED_MENU | **不适用**：页面存在（`/settings/feeding-template-management`）；M04 其余模板子页不存在，按 §3.4 记 NO_UI，不造页 |
| 4 不伪造工程段、不展示「已可被 M03 消费」成功态 | **遵守**：见 §3.1 末段与 `versionPackageNote` 文案；测试用例「版本行里绝不出现固定包/工程段的伪造取值」钉住 |

### 3.6 W1-04 追加轮：schema2 / engineering / hash 三条口径补齐（总控目标逐条）

总控 W1 表把 W1-04 目标写成「schema2/engineering/hash 只读展示、错误提示」。批次 02 已交付 hash 与 engineering 的「未取得」口径，本轮补齐剩下两处**只读说明**，不改任何取数与写路径。

**先给三条实测依据（全部为后端只读检索，本批未改后端）**：

| 事实 | 证据坐标 | 对前端口径的影响 |
|---|---|---|
| `VersionMeta` 仍是 10 个字段，无 `packageSchemaVersion`/`engineeringSchemaVersion`/`engineeringHash` | `domain/vo/m04/VersionMeta.java:14-32`（HEAD `96f85408` 复核） | 「engineering 只读展示」在 HTTP 侧**只能展示为未取得**，批次 02 的说明条口径不变、不升级 |
| `engineering_schema_version` 全仓 **0 个 VO、0 个 controller** 命中，只在应用服务写库时 `version.setEngineeringSchemaVersion(engineering.getSchemaVersion())`（`:867`） | `grep -rln engineeringSchemaVersion domain/vo/ controller/` ⇒ 空 | 前端**无法判定**当前版本属于 V1 还是 V2 域 |
| `b913a42b` 引入 `M04_VERSION_V2`：V1 = 内容+适配换行拼接 SHA256；V2 = 算法标识+内容+适配+绑定固定身份+`engineeringHash`；`isV2Domain(Integer esv) = esv != null`；后端注释明写「V1 与 V2 摘要不得互相强行比对相等」 | `service/support/m04/TemplateVersionCanonicalHasher.java:22-33、:42、:62-80、:90-95、:103-106` | 之前把 `canonicalHash` 一律读作「版本内容摘要」是不充分的：同一列可能是两代口径之一 |
| `CONTENT_SCHEMA_VERSION = 1`（新增写路径仍登记 1），schema 2 未出现在 HTTP | `service/impl/application/m04/ProcessTemplateApplicationApplicationServiceImpl.java:141`、`:859` | 「schema2 展示」= 展示后端透出的原值，并明写本页不推断 schema 2 已支持 |

**据此新增的展示（编辑器版本身份块内，`data-testid="version-hash-domains"`）**：

1. 标题 `hashDomainTitle`：规范哈希的算法域（两代口径并存，本页只列口径，不判定本版本属于哪一代）。
2. 两行 `version-hash-domain-legacyV1` / `version-hash-domain-engineeredV2`：分别写明 V1 覆盖「内容 JSON + 适配 JSON 换行拼接 SHA256」、V2 覆盖「算法标识 + 内容 + 适配 + 绑定固定身份 + engineeringHash」，并各带自己的判定条件（`engineering_schema_version` 是否为 NULL）。
3. 末句 `version-hash-domain-undecidable`：判定列不在本接口响应内 ⇒ **不声称上面的哈希已覆盖工程段，两代摘要也不得互相比对相等**。
4. 末句 `version-content-schema-note`：「内容 schema」只显示后端原值；后端新增写路径当前登记为 1，schema 2 未出现在本接口，前端不推断为已支持。

**三条刻意不做的事**（work5 若发现以下任一项被做，即判为越界缺陷）：

- 不给 `canonicalHash` 行加「V1/V2」标签或颜色：归属不可判定，标注等于猜测。
- 不因为 `b913a42b` 存在就把 `canonicalHash` 文案升级为「已含工程段摘要」。
- 不在页面/SDK 里加 `engineeringSchemaVersion` 字段或从别的接口借值填补——`M04_PACKAGE_ONLY_FIELDS` 说明条继续只列名字不列值。

**错误提示侧的增量**：`VERSION_CONFLICT` 登记为 `settings-feeding.errorVersionConflict`（「模板对象版本与期望不符，本次未写入；请刷新后重试」）。可达性分级见 §3.3 更新行：该码在 M04 侧唯一异常点是 `TemplatePackagePortImpl:137`，属 Port 层，HTTP 是否命中未验证；M04 写路径 CAS 失败的**实际**码仍是 `STATE_CONFLICT`（应用服务 `:691`）。新增测试「每个登记码都是后端 `FutureFabErrorCode` 的真实枚举成员」把「不许给不存在的码编文案」钉住（读 `futurefab-api/futurefab-api-system/.../FutureFabErrorCode.java` 文本比对，只读）。


---

## 4. 已执行验证命令与结果

2026-10-05 23:41—23:47，工作目录 `futurefab-frontend/`（顺序即 work1 固定验证序：类型 → 路由 → 单测 → SDK dts → 生产构建）：

| 步 | 命令 | 结果 |
|---|---|---|
| 0 | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | exit 0（本批改了 SDK 类型；app 经 `dist-types/index.d.ts` 解析 SDK，缺这步 app type-check 会报 `TemplateVersionMeta` 不存在） |
| 1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | exit 0 |
| 1 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | exit 0（首轮报 1 项：`:title` 绑 `string \| null`，已按 `?? undefined` 收口后通过） |
| 1 | `pnpm run routes:check` | exit 0 |
| 1 | `npx vitest run tests/m04-feeding-template-version-identity.test.ts` | **1 文件 / 17 用例全通过** |
| 1（回归） | `npx vitest run tests/m04-...tests/benchreactor-management.test.ts tests/benchreactor-acceptance-precheck.test.ts tests/write-failure-feedback-sweep.test.ts` | **4 文件 / 88 用例全通过** |
| 1（回归） | `npx vitest run tests/m01-write-failure-feedback.test.ts tests/write-failure-feedback-sweep.test.ts` | 2 文件 / 46 用例全通过（写失败反馈口径未被本批改动破坏） |
| 1（回归） | `npx vitest run tests/benchreactor-management.test.ts tests/benchreactor-acceptance-precheck.test.ts tests/lab-labbenchreactor-guarded-write.test.ts tests/venue-delete-guarded-write.test.ts` | 4 文件 / 77 用例全通过（批次 01/03 在途改动仍绿） |
| 2 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | exit 0，`✓ built in 9.35s`，产物 `packages/app-smp-settings/dist/feeding-template-management-CjS1ELqp.js`（66.31 kB / gzip 13.83 kB）；`dist/` 已 gitignore |
| 3 | 产物符号抽检 `grep -c` on 上述 chunk | `versionIdentityTitle` 1、`versionPackageNote` 1、`errorStateConflict` 1、`engineeringSchemaVersion` 1（只出现在说明条字段名里）、`canonicalHash` 2 |
| 4 | `npx biome check`（项目 `lint:check` 的 biome 半） | 本批 3 个新增文件 **0 error**（两处 style 已用 `biome check --unsafe --fix` 就地修正，只作用于本批新文件） |
| 4 | `npx eslint` 同路径 | 0 error |
| 4 | `npx prettier --check` 同路径 | 与本批文件冲突：prettier 要求把长行折到 80 列，biome 又把折行版判为 `format` 违规；**二者互斥已实测**（对 `/tmp` 副本单向格式化后反向 check 各报 1 error）。仓库既有文件同样命中（未改动的 `views/workflow-management/index.vue` 也报 prettier warn）。本批选择满足 `lint:check` 实际执行的 biome + eslint，未随 prettier 改写 |

背景红（非本批引入，已核对与本批文件无关）：`tests/localization.test.ts` 1 例红（`provides named Chinese and English keys for every static translated phrase`），缺失清单里**没有任何 `feeding-template-management` 条目**（grep 计数 0），命中项集中在 `app-smp-data/detection-record`、`system-user` 等他域；同文件其余 7 例通过，其中包括 `keeps paired catalogs and interpolation parameters in sync` 与 `does not ship empty or untranslated English values` —— 这两例正是本批新增 cn/en key 的对称性守卫。`workflow-management.test.ts` 的 M05 `labTypeList` 红与本批无关。

**work5 不要以全量 vitest 绿作为本批放行条件**（背景红未清），只按下表判读本批两套用例 + 上述回归组合。

### 4.2 W1-04 追加轮验证序（2026-10-06 01:35—01:55，HEAD `96f85408`，目录 `futurefab-frontend/`）

| # | 命令 / 检查 | 层级 | 结果 |
|---|---|---|---|
| V1 | `npx vitest run tests/m04-feeding-template-version-identity.test.ts` | 单元/静态钉 | **1 文件 / 29 用例全绿**（批次 02 的 17 例 + W1-04 的 12 例），`biome --write` 重排该文件后复跑仍 29/29 |
| V2 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 类型 | **exit 0** |
| V3 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 类型 | **exit 0**（收口轮）。中间 5 次重试为 **exit 2**，全部诊断都落在 `src/shared/m09-status.ts`（他人 M09 在途文件，`git status` 标 `??`，实测 01:41 时该文件 mtime 距当时 21 秒）：错误数 5 → 9 → 13 → 8 → 0。**本批 4 个文件在任何一次失败轮里都没有诊断条目** |
| V4 | `pnpm run routes:check` | 静态 | **exit 0** |
| V5 | `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` | SDK 类型产物 | **exit 0**（本批未改 SDK 类型，此步是 app 端解析 `TemplateVersionMeta` 的前置） |
| V6 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 生产构建（本包） | **exit 0**，产物 `packages/app-smp-settings/dist/feeding-template-management-B19sG9j9.js` **68.05 kB / gzip 14.21 kB**（批次 02 为 `CjS1ELqp` 66.31 kB / 13.83 kB；哈希与体积变化来自本批新增说明块，非他人页面改写） |
| V7 | 产物 token 抽检（同一 chunk `grep -o \| wc -l`） | 构建内容 | `version-hash-domains` 1、`hashDomainTitle` 1、`hashDomainUndecidable` 1、`contentSchemaNote` 1、`errorVersionConflict` 1、`versionPackageNote` 1、`engineeringSchemaVersion` 1（仍只出现在说明条字段名里，无取值） |
| V8 | 回归组合 `npx vitest run tests/m04-...tests/m01-write-failure-feedback.test.ts tests/write-failure-feedback-sweep.test.ts tests/localization.test.ts` | 单元 | **4 文件 / 83 用例：82 通过，1 红**（红项 `localization.test.ts > provides named Chinese and English keys for every static translated phrase`）。同文件 `keeps paired catalogs and interpolation parameters in sync`、`does not ship empty or untranslated English values` 两例**通过**，即本批 cn/en 对称性有守卫背书 |
| V9 | 背景红归属 `vitest run tests/localization.test.ts` 的 129 条缺失清单 `grep -ciE "hashDomain\|contentSchemaNote\|errorVersionConflict\|feeding"` | 归属证明 | **0**：缺失项全部落在 `app-smp-data/detect-detresult`、`detection-record`、`shared/m09-monitor-ack-panel.vue`、`alarm-*`、`lab-statusalarm`、`smp-notification`、`system-user`，无一指本批 |
| V10 | `npx biome check`（本批 4 个文件） | 风格（仓库 `lint:check` 实际执行的是 biome + eslint） | 两个 helper `.ts` **0 诊断**；`tests/m04-...test.ts` 经 `biome check --write` 后 **0 诊断**（该文件是本批自有未跟踪文件，可整体格式化）；`feeding-template-editor.vue` 报 `organizeImports` + `format` 两类错误，**属仓库既有风格债**：未经任何人修改的 `views/dept-management/index.vue` 同样报这两类，且本批新增行在 biome 的 format 差异里 **0 命中** |
| V11 | `npx prettier --check`（本批 3 个 `.ts`） | 风格（对照项） | 三个文件都报 warn。这是批次 02 §4 已实测的 **biome↔prettier 互斥**（printWidth 80 下两者对同一行长要求相反），仓库门禁取 biome。本批未做整文件 prettier 重排（共享文件禁止无范围格式化，AGENTS.md §12） |
| V12 | 后端只读检索（§3.6 四条事实 + §3.3 计数 + `ProcessTemplateController` 的注解清点） | 契约静态 | 与结论一致；**未修改任何后端文件**。附带事实：`ProcessTemplateController.java` 与 `service/impl/application/m04/` 本轮 `@ManagementGuardedWrite`/`@CurrentManagementRevision` **均 0 命中**（§7 R1 仍在） |

**层级声明**：以上全部落在 编译 / 类型 / 单元与静态钉 / 生产构建 四层。本批**没有** HTTP、浏览器、数据库或现场验收；`version-hash-domains` 是否真的渲染出来、四条文案在页面上是否可读，属 §5.4 D 组与 work9 的取证点。


---

## 5. 给 work5 的详细测试方案

### 5.0 前置条件（执行前必须逐条确认）

| 项 | 要求 |
|---|---|
| 服务 | 网关 + system 服务在线；用仓库 `nacos-config/` 判断路由**不可靠**（历史记录：真实数据源与配置以远端 Nacos 为准） |
| 前端产物 | portal `:5581` 提供的是**预构建 hash bundle，不是 HMR 源码**。必须先 `pnpm --filter @futurefab/ui-sdk-smp-api run build-dts` + `pnpm --filter @futurefab/ui-app-smp-settings run build`，再确认加载的 chunk 名为 `feeding-template-management-CjS1ELqp.js`（或本次重建后的新 hash）。旧 hash = 改动未生效，记 **BLOCKED_DEPLOY**，不得记页面缺陷 |
| 登录 | 账号需具备 `process:feeding:list/query/edit/add/changeStatus/remove`；缺权限记 **BLOCKED_MENU**，不要改前端权限判断 |
| 主数据 | 至少 1 条**已存在**的 FEEDING 模板（见 §6 取数 SQL）；无主数据记 **BLOCKED_DATA** |
| 观测 | 浏览器 Network 必须逐条记录 `GET /system/process/templates/{id}` 的 response body；400/409 的 `code`/`errorCode`/`msg` **只能从 Network 判读**（守卫拒绝是 WARN 级，不落日志文件） |

### 5.1 A 组 · 契约与静态（可离线复核）

| 编号 | 步骤 | 预期 |
|---|---|---|
| A1 | `npx vitest run tests/m04-feeding-template-version-identity.test.ts` | 批次 02 口径：**17/17**。**W1-04 追加后：29/29**（新增 12 例，见 D 组） |
| A2 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | exit 0 |
| A3 | `pnpm run routes:check` | exit 0 |
| A4 | 读 `VersionMeta.java:14-32` 与 `processTemplate.ts` 的 `TemplateVersionMeta` | 字段名/可空性逐项一致；FE 不再声明 `createdAt`/`createdByUserId` |
| A5 | 读 `TemplateDetailView.java` + `assembleDetail`（`:1150-1177`） | Detail 只有 `template/version/content/applicability/bindings/redactedPaths`，**无** package/engineering 字段 → 证明本批「未取得」文案是对的，不是漏做 |
| A6（W1-04） | `grep -rln "engineeringSchemaVersion" packages/app-smp-settings/src packages/sdk-smp-api/src` | **0 命中**（前端没有偷偷新增工程段字段）；`M04_PACKAGE_ONLY_FIELDS` 里只有字段名字符串 |
| A7（W1-04） | 读 `service/support/m04/TemplateVersionCanonicalHasher.java:22-33/42/62-80/90-95/103-106` | 与页面两条口径逐字对齐：V1=内容+适配；V2=`M04_VERSION_V2`+内容+适配+绑定固定身份+`engineeringHash`；域判定是 `engineering_schema_version != null`；后端自证「V1 与 V2 摘要不得互相强行比对相等」 |
| A8（W1-04） | `grep -n "CONTENT_SCHEMA_VERSION" service/impl/application/m04/ProcessTemplateApplicationApplicationServiceImpl.java` | `:141 = 1`、`:859` 写入 ⇒ 页面「schema 2 未出现在本接口，前端不推断为已支持」有据 |
| A9（W1-04） | `node -e` 或人工比对 `M04_ERROR_KEYS` 的 14 个码是否都在 `futurefab-api/futurefab-api-system/.../FutureFabErrorCode.java` 出现 | 全部命中（测试已自动钉：`每个登记码都是后端 FutureFabErrorCode 的真实枚举成员`）；若后端删码，该用例会红，属**期望的**失败 |

### 5.2 B 组 · HTTP + 浏览器（本批展示面）

| 编号 | 操作 | 预期与记录点 |
|---|---|---|
| B1 | 进入 `/settings/feeding-template-management`，Network 看列表请求 | 记录 `GET /system/process/templates/list` 的 response 顶层**是否有 `managementRevision`**。预期（源码判定）：**没有** → 这是 §7 R1 的证据，必须原样记录，不要手工补值 |
| B2 | 点任一行「编辑」 | Network 出现 `GET /system/process/templates/{templateId}`；response `data.version` 含 `versionId/versionNo/contentSchemaVersion/canonicalHash/...` |
| B3 | 看对话框头部下方的「版本身份（只读）」块（testid `version-identity-title`） | 八个条目 testid `version-item-versionNo` … `version-item-previousVersionId` 全部存在；值与 B2 的 response 逐字段一致（`canonicalHash` 为「前10…后6」，鼠标悬停 title 为完整 64 位小写十六进制；`savedAt` 显示本地时间，悬停为原始 ISO） |
| B4 | 校验未透出说明条（testid `version-package-note`） | 文案列出 `packageSchemaVersion / packageHash / engineeringSchemaVersion / engineeringHash / workflowDefinition` 五个名字，且**五个名字后面没有任何值**；不得出现「校验通过」「已可被 M03 消费」等成功口径 |
| B5 | 关闭后点「新增」 | 版本身份块**不渲染**（`identityRows.length === 0`），页面不报错 |
| B6 | 选一行点「复制」 | 同样不渲染版本身份块（复制是新草稿）；若这里显示了来源版本号，判为缺陷 |
| B7 | 构造缺字段（用已有版本内容 JSON 手工删一个必填字段发 PUT，或按 B9 触发） | 400 + `errorCode=INPUT_INVALID` → 页面显示「请求内容不合契约（缺字段或格式不符），本次未提交」，不是浏览器 `undefined`、不是裸英文堆栈 |
| B8 | 两个浏览器同开一个模板，A 先保存成功后 B 再保存（若写通道可用；不可用则改走 `binding-preview` 让来源版本前移） | 后发方 409 + `errorCode=STATE_CONFLICT` → 文案「模板已被其他操作修改或状态已变化，本次未写入；请刷新列表后重试」；**文案不得说成参数错误** |
| B9 | 用禁用的泵速策略模板做绑定预览 | 409 + `SOURCE_STATE_CONFLICT` → 「绑定来源已禁用或已删除，请改选可用来源」 |
| B10 | 制造同名（同 templateKind 下重名）保存 | 409 + `NAME_CONFLICT` → 「同类型模板名称已存在，请更换名称」 |
| B11 | 未登记码兜底：用 DevTools 把某次失败的 response `errorCode` 改成不存在的值重放（或记录一次未知码自然返回） | 页面原样透出服务端 `msg`，不套用本批任何固定口径 |
| B12 | 语言切 EN | 八行标签、说明条、错误文案全部变英文；`versionPackageNote` 末尾带一个空格再接字段名（拼接不粘连） |
| B13 | 列表页「启用/禁用」「删除」的失败提示（同样按 §7 R1 预期失败） | 走 `showError(describeError(e))`，文案同 B7/B8 口径；确认**不是** `showError(errorMessage(e))` 的裸服务端文本 |
| B14 | 控制台 | 无 Vue 渲染错误、无 `TypeError`；`RequestMetaInvalidException` 不应出现在页面日志（守卫拒绝只 WARN） |
| B15 | 页面回归 | 原有功能不受影响：筛选、泵行、补料任务、补糖规则、规格文本、保存按钮禁用逻辑与改动前一致（对照批次 01 的回归清单口径） |
| B16（W1-04） | 编辑态滚动到版本身份块下方，取 testid `version-hash-domains` | 块内两条 `version-hash-domain-legacyV1`、`version-hash-domain-engineeredV2` 都存在且各自说明覆盖段；两条文本**不随 B2 的 response 变化**（静态说明） |
| B17（W1-04） | 同块读 `version-hash-domain-undecidable` 与 `version-content-schema-note` | 前者必须出现「不声称…已覆盖工程段」「不得互相比对相等」两处口径；后者必须出现「schema 2 未出现在本接口」。**若页面给 `canonicalHash` 打上 V1/V2 标签，判为越界缺陷** |
| B18（W1-04） | Network 面板复跑 B2/B16/B17 | 说明块渲染**不产生任何新请求**（`m04-version-identity.ts` 只有 `import type`，无请求层）；对照 A6 |
| B19（W1-04） | 切 EN 复跑 B16/B17 | 两代口径与两条末句英文齐全，无回落中文、无缺 key |

**判读边界**：B3/B4 通过只能声明 **HTTP_VERIFIED**；要声明 BROWSER_VERIFIED 必须附截图 + Network 请求头/体/响应原文；本批**不含**现场/生产验收。

### 5.3 C 组 · 只读数据库核验（不得写库）

```sql
-- C1 找一条有版本身份的 FEEDING 模板（列名对齐 docs/开发基线/01-完整建表.sql）
SELECT t.template_id, t.template_name, t.status, t.current_version_id, t.object_version
FROM prc_template t
WHERE t.template_kind = 'FEEDING' AND t.del_flag = '0'
ORDER BY t.update_time DESC LIMIT 5;

-- C2 版本行的身份列：canonical_hash / calculation_profile / change_kind / saved_at / saved_by_user_id
--    engineering_schema_version、engineering_hash 也在同一张表，但不在 HTTP 响应里（本批说明条的依据）
SELECT v.version_id, v.version_no, v.previous_version_id, v.content_schema_version,
       v.calculation_profile, v.canonical_hash, v.change_kind, v.saved_at, v.saved_by_user_id,
       v.engineering_schema_version, v.engineering_hash
FROM prc_template_version v
WHERE v.version_id = ${C1.current_version_id};

-- C3 浏览器 B3 的逐字段核对：HTTP version.* 必须与 C2 完全一致；
--    若页面显示了 C2 里为空但接口给了值的字段，判为前端伪造（缺陷）。

-- C4 写路径核验（配合 §7 R1）：确认本批测试期间 M04 模板没有被新写入
SELECT version_id, version_no, change_kind, created_request_id
FROM prc_template_version
WHERE template_id = ${C1.template_id}
ORDER BY version_no DESC;
```

不得执行任何 UPDATE/DELETE；不得为造数据插入主数据前先征得总控同意（本模块主数据建议走 §6）。

---

## 6. 测试数据建议

| 项 | 建议 |
|---|---|
| 首选 | 直接复用库里已有的 FEEDING 模板（§5.3 C1）。本批是只读展示，不需要新数据 |
| 若无任何模板 | **不要用 UI 新建造数**：写路径按 §7 R1 静态判定会 400。可选两条路，且都要先报备：(a) 走 `docs/开发基线/02-基础数据初始化.sql` 是否已含 M04 种子（本批未核，需 work5 实跑核验 SQL）；(b) 用 curl 手工发 `POST /system/process/templates`，body 带合法 `requestId`（UUID）与 `managementRevision`（十进制字符串，取自 `sys_management_revision` 的 `SYSTEM` 行当前值）——注意这属于**人工代跑写接口**，验证完要记录并清理 |
| 期望有 `previousVersionId` 的样本 | 需要一条**编辑过至少两次**的模板；只有一条首版本时 `previous_version_id` 必为 null，此时 B3 应显示「接口未提供」，不要判缺陷 |
| 期望 `savedByUserId=null` 的样本 | 历史作者未知场景，页面显示「接口未提供」即正确 |
| 哈希样本 | 任选一条：`canonical_hash` 是 64 位小写十六进制；页面截断显示不影响全值核对（title） |
| 清理方式 | 本批纯只读，无新增数据需清理。若走了 (b) 人工 curl 造数，记下 templateId，交总控决定是否删除；work1 不代为删除 |

---

## 7. 已知风险 / 阻塞

| 编号 | 事项 | 层级 | 说明与建议 |
|---|---|---|---|
| **R1** | **M04 模板四条写路径静态判定全部 400**（本批新发现，非本批引入） | IMPLEMENTED 判定：源码链；预期 HTTP = 400 INPUT_INVALID，待 work5 证实 | 证据链：① 读口 `pageTemplates`（`ProcessTemplateController.java:141-146`）与 `getTemplateDetail`（`:59-66`）**都没有** `@CurrentManagementRevision`，而响应 Advice 只在 `RequestMetadataContext` 有值时填 `managementRevision`（`ManagementRevisionPreResolver.java:60-68`）→ 外壳无该字段；② `index.vue:282-284` 因此拿不到 revision，状态/删除请求体 `managementRevision` 为 undefined；③ 编辑器 `save()`（`feeding-template-editor.vue:881-913`）**根本没发** `managementRevision` 字段；④ 服务层无条件 `new WriteMeta(cmd.getRequestId(), cmd.getManagementRevision())`（`:290/:316/:347/:368/:386`），`WriteMeta` 构造器对 null/非十进制串直接抛 `RequestMetaInvalidException`（`WriteMeta.java:31-41`）→ 400 + `errorCode=INPUT_INVALID`。**这符合 AGENTS.md §13.3 描述的「读口没给 revision 就先核对 Controller 是否缺 `@CurrentManagementRevision`」的处置方向**：本批未改后端、未硬编码 revision、未从别的模块借 revision、未放宽校验。建议总控裁决：后端在 M04-011（或 M04-002）加 `@CurrentManagementRevision` 并补契约测试，另批给前端下达「编辑器补齐 revision + 缺失短路」的任务 **W1-04 复核补充（HEAD `96f85408`）**：`ProcessTemplateController.java` 与 `service/impl/application/m04/` 的 `@ManagementGuardedWrite`/`@CurrentManagementRevision` 命中数均为 **0**，即 M04 写路径目前**根本没挂守卫注解**，400 的直接来源是 `WriteMeta` 构造校验（④）而非守卫拦截器。这既没有推翻 R1 的结论，也说明「补 revision 短路」的前端任务要等守卫/读口口径确定后再下达，本批仍按 §13.3 不硬编码、不借值 |
| **R2** | 工程段/固定包五个字段无 HTTP 出口 | 契约缺口（记录，不改） | 若业务确实要在页面上看 `packageHash`/`engineeringHash`，需要后端把它们加进 `VersionMeta` 或新开版本详情接口——属后端契约变更，本批不自造展示值。当前交付口径见 §3.1 |
| R3 | `CONTENT_INVALID`/`SCHEMA_UNSUPPORTED`/`SOURCE_VERSION_CONFLICT`/`APPROVAL_CONTEXT_UNAVAILABLE` 只在固定包 Port 抛出，M04 HTTP 路径是否命中未证 | NOT_VERIFIED | 本批只登记文案；work5 若发不出该码，记「不可达（Port 码）」，不要记前端失败。可达码集合见 §3.3 表右列 |
| R4 | `redactedPaths` 后端恒为 `List.of()`（`assembleDetail:1176`） | 记录 | SDK 类型本批已补 `redactedPaths?`，但页面不展示（任务未要求）。裁剪提示待后端真实填充后再做 |
| R5 | 前端路径带 `/system` 前缀，后端 base 无该前缀 | BLOCKED_DEPLOY 风险 | 依赖网关路由；本批只证源码一致。work5 若 404 且路由未发布，记 BLOCKED_DEPLOY，不记页面缺陷 |
| R6 | M04 控制器 16 个方法注释都写「契约骨架：应用服务显式 501」，实际只剩 M04-016 抛 `SkeletonNotImplementedException` | 后端文档漂移（记录，不改） | 与批次 04 的 M06 注释漂移同类。请总控转后端收口注释，避免 work5 按「501」预期判读 |
| R7 | 版本块缺 `aria`/视觉基线未定；说明条为纯文本，未做可折叠 | 设计待裁决 | 需要视觉稿或交互口径时另批下达，本批不自定义设计 |
| R8 | prettier 与 biome 互斥（§4 步 4 实测） | 工具链 | 本批按项目实际门禁 `lint:check`（biome + eslint）交付；若总控要求 prettier-clean，需要同时决定 `lint:check` 怎么改，否则任何单向格式化都会把另一向判红 |
| **R9**（W1-04） | `canonicalHash` 的算法域（V1 / `M04_VERSION_V2`）**前端不可判定** | 契约缺口（记录，不改） | 判定列 `engineering_schema_version` 不在 `VersionMeta`，且全仓 0 VO / 0 controller 命中（A7 证据）。页面因此只列两代口径、不给单条哈希打标签。若总控要「按版本标注摘要代次」，需后端在 M04-002/M04-004 增 `engineeringSchemaVersion` 或 `canonicalAlgorithm` 字段（与 R2 同一变更单），另批下达 |
| **R10**（W1-04） | 「schema2」目前只在设计文档与 Port 侧存在，HTTP 与写路径仍是 schema 1 | 记录 | `ProcessTemplateApplicationApplicationServiceImpl.java:141/:859` 实测 `CONTENT_SCHEMA_VERSION = 1`。本批交付的是「显示后端原值 + 明写不推断 schema 2」；**不得**被读成「M04 页面已支持 schema 2 展示」 |
| **R11**（W1-04） | `96f85408` 落了 M06 API10 审批提交 provider，但 `ParameterPackagePortImpl:871-872` 仍写「M06 API10 submitApproval 提供方本批未接入」 | 后端时序待确认 | 不影响本批与 W1-03 的前端口径（两者只依赖「M04 工程段/M03 候选无 HTTP 出口」这一事实，均未因此变更）。请总控与 M03/M06 批确认 M03-P01 是否已改接该 provider，避免 work5 按旧注释判读 APPROVAL 档 |
| **R12**（W1-04） | 本批验证窗口内 `app-smp-settings` 包级 type-check 一度被他人 `src/shared/m09-status.ts`（未跟踪在途文件）判红 | 共享工作副本干扰（已自行收敛） | 见 V3：错误数 5→9→13→8→0，全程无一条诊断落在本批文件；收口轮 exit 0。work5 复跑若再遇此红，先按 V3 方法（`grep -oE "^src/[^(]+" \| uniq -c`）归属，不要回改本批文件 |

---

## 8. work5 测试记录区

| 编号 | 执行时间 | 环境/产物 hash | 结果（PASS/FAIL/BLOCKED_*） | 证据（截图 / Network 请求头+体+响应 / SQL 输出） | 备注 |
|---|---|---|---|---|---|
| A1 |  |  |  |  |  |
| A2 |  |  |  |  |  |
| A3 |  |  |  |  |  |
| A4 |  |  |  |  |  |
| A5 |  |  |  |  |  |
| A6 |  |  |  |  | W1-04：前端工程段字段 0 命中 |
| A7 |  |  |  |  | W1-04：两代摘要口径逐字对齐 |
| A8 |  |  |  |  | W1-04：`CONTENT_SCHEMA_VERSION = 1` |
| A9 |  |  |  |  | W1-04：登记码 ⊆ 后端枚举 |
| B1 |  |  |  |  | 顶层是否有 `managementRevision`（R1 关键证据） |
| B2 |  |  |  |  |  |
| B3 |  |  |  |  | 八行逐字段对照 |
| B4 |  |  |  |  | 说明条只列名不给值 |
| B5 |  |  |  |  |  |
| B6 |  |  |  |  |  |
| B7 |  |  |  |  |  |
| B8 |  |  |  |  |  |
| B9 |  |  |  |  |  |
| B10 |  |  |  |  |  |
| B11 |  |  |  |  |  |
| B12 |  |  |  |  |  |
| B13 |  |  |  |  |  |
| B14 |  |  |  |  |  |
| B15 |  |  |  |  |  |
| B16 |  |  |  |  | W1-04：两条算法域行存在且静态 |
| B17 |  |  |  |  | W1-04：归属不可判定 + schema 原值口径 |
| B18 |  |  |  |  | W1-04：Network 无新请求 |
| B19 |  |  |  |  | W1-04：EN 齐全 |
| C1 |  |  |  |  |  |
| C2 |  |  |  |  |  |
| C3 |  |  |  |  |  |
| C4 |  |  |  |  |  |
| R1 复核 |  |  |  |  | 四条写路径实际返回码与 `errorCode` |

---

## 9. 最终结论区（由总控/work5 回填，work1 不自行判完成）

| 项 | 口径 |
|---|---|
| 可宣称完成（本批） | IMPLEMENTED + CONTRACT_TESTED（批次 02 的 17 例 + **W1-04 的 12 例 = 29 例**）+ 生产构建通过（`feeding-template-management-B19sG9j9.js` 68.05 kB / gzip 14.21 kB） |
| 仅代码/契约测试完成 | 版本身份只读块、错误码→文案映射（**W1-04 起 14 码，含 `VERSION_CONFLICT`**）、SDK `TemplateVersionMeta` 对齐、**W1-04：两代摘要算法域与内容 schema 原值的只读说明块** |
| HTTP 待验证 | B1—B13、B16—B19、C1—C4 |
| 浏览器待验证 | B3—B6、B12、B15、**B16—B18（说明块渲染与「无新请求」）**、**B19（EN）** |
| 阻塞/裁决事项 | **R1（写路径 revision 来源缺失；W1-04 复核：M04 侧守卫注解命中数为 0，400 直接来自 `WriteMeta` 校验）**、R2（工程段字段无 HTTP 出口）、R5（网关前缀需运行态确认）、R6（后端 501 注释漂移）、R7（视觉口径）、R8（格式化工具链互斥）、**R9（`canonicalHash` 代次前端不可判定）**、**R10（schema 2 未进 HTTP 与写路径）**、**R11（M06 API10 provider 已落库但 M03 Port 注释未更新，待总控与后端批确认）**、**R12（共享工作副本内他人在途文件曾致本包 type-check 判红，已自行收敛）** |
| 未运行事项 | 数据库写入、外部系统（M03 固定包消费）、现场验收 —— 一律 NOT_VERIFIED |
| 禁止措辞 | 不得因本批交付而称 M04 模板「新增/编辑可用」、不得称「工程包信息已展示」、不得称「已可被 M03 消费」；**W1-04 追加**：不得称「页面已按版本标注摘要代次」、不得称「已支持 schema 2 展示」、不得把 `VERSION_CONFLICT` 文案说成 M04 写路径实测返回码（实测 CAS 失败码是 `STATE_CONFLICT`） |

## 10. 勘误（2026-10-14，总控 hold 车道，HEAD `59e840ec5`）

**事件**：`9c034358e`（2026-10-10，zou jun，`fix(m04): 补齐补液方案列表反应器与规格展示`）把本批交付的**只读版本身份块与规范哈希域说明块整块删除**（`feeding-template-editor.vue` −132 行、0 新增：`versionMeta`/`identityRows` 状态、`applyDetail` 复制态置 null、`resetForm` 清空、`v-if="identityRows.length"` 模板块、`version-hash-domains` 说明区及 scoped 样式），提交说明写作「移除编辑弹窗中的内部版本身份展示」。该提交**未同步**本批钉桩测试 `tests/m04-feeding-template-version-identity.test.ts`，其自述验证只覆盖 type-check 与 build、未跑 vitest，因此前端全量套从该日起持续红 2 例。

**冲突点（列明，不自行拼接两版）**：现行 `M04-前端开发交接文档-20261009.md` §5.6 FE06 首句明文「保留 feeding-template-management 现有列表、编辑器、糖日期区间工具、**版本身份**及错误映射」（2026-10-09，早于该删除一天）；后端 `ProcessTemplateApplicationApplicationServiceImpl.java:2242 detail.setVersion(toVersionMeta(version))` 与 SDK `processTemplate.ts:196 TemplateVersionMeta`、`configTemplate.ts:74 version` 均未变，即读契约仍供该数据。`9c034358e` 的删除既无契约变更依据，也无客户澄清记录条目（`需求澄清决策记录.md` 内「版本身份」0 命中）。

**本轮处置**：按 §3.2/§3.6 已交付规格把该只读展示块恢复回 `feeding-template-editor.vue`（内容与 `9c034358e^` 逐字一致，仅撤销 UI 删除，`9c034358e` 的列表展示与规格快照服务端冻结等改动全部保留未动）。恢复体仍是**只读、无控件、不参与提交体**。改动**未提交**。

**若总控确认「应当下线」**：需同批处理，不能只留现状——① 翻正 `tests/m04-feeding-template-version-identity.test.ts` 的两条挂载断言（现绿）；② 更新本文档 §3.2/§3.6 与 §5.2 B3/B4/B5/B6/B16；③ 更新交接文档 §5.6 FE06 的「保留…版本身份」；④ 处置随之失去消费者的脚手架：`m04-version-identity.ts`、`M04_PACKAGE_ONLY_FIELDS`、`settings-feeding` 里 `version*`/`hashDomain*`/`contentSchemaNote` 共 cn/en 各 18 个键（恢复后这些模块与键的唯一消费者就是本只读块，一旦确认下线即成死代码/死键）。裁决前本车道不再改动该页。

**层级不因恢复升级**：本次只到静态 + vitest + 类型 + 本包构建（`tests/m04-feeding-template-version-identity.test.ts` 29/29，`@futurefab/ui-app-smp-settings` type-check 与 build 退出码 0）；§5.2 B 组（含 B3/B4/B16）与 §5.3 C 组仍为 **NOT_VERIFIED**，不得因代码回到交付态而宣称浏览器已验收。
