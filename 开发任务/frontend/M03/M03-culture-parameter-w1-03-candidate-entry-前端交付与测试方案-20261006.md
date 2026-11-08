# M03 培养参数候选快照 W1-03 —— 入口盘点、只读提示与错误码可读化前端交付与测试方案

## 1. 基本信息

| 项 | 内容 |
| --- | --- |
| 批次 | **W1-03**（原编号 Batch 05；总控 2026-10-06 W1 序列沿用同一 M03 范围并追加「P01 候选提示、P02-P04 不支持提示」目标，本轮据此补挂只读提示块） |
| 主题 | M03 culture-parameter：参数候选快照入口盘点与只读提示 |
| 模块 | M03 项目与培养管理（培养参数候选快照 / 审批生效子域） |
| 开发代理 | work1（仅前端开发/盘点，不出具最终测试结论） |
| 复核代理 | work5（按 §6 执行）、必要时 work9（真实浏览器与 Network 取证） |
| 编制日期 | 2026-10-06（W1-03 追加轮次实测于 01:15–01:25） |
| 仓库坐标 | 分支 `cloud`，HEAD `b9769b2a`（工作副本含其他 work 在途未提交改动，见 §2.6） |
| 交付形态 | 混合：已有页面做最小改动（错误码可读化 + 测试锚点 + **参数候选入口只读提示块**）；参数候选快照**操作入口**仍为 NO_UI；菜单可达性 **BLOCKED_MENU**（静态不可判定） |
| 验证层级 | 静态检索 + 只读源码核对 + `vue-tsc` 类型检查 + vitest + 本包生产构建（全部为编译/静态层） |
| 未验证层级 | HTTP_VERIFIED、BROWSER_VERIFIED、SQL/数据库、外部系统、现场验收：**NOT_VERIFIED**（本批零真实请求、零 SQL 执行） |
| 提交状态 | 按总控要求**未** `git add`、**未** commit、**未** push |

批次目标逐条状态（详见 §4、§7）：

| # | 总控目标 | 本批状态 |
| --- | --- | --- |
| 1 | M03 项目/培养/参数/快照/审批生效页面入口盘点 | **已完成盘点**：项目+培养+授权页存在；参数候选快照/审批生效 **NO_UI**；菜单 **BLOCKED_MENU** |
| 2 | API 封装盘点，仅必要时轻量封装 | **已盘点，零新增封装**：M03-P01—P04 无 HTTP 出口，封装即虚构 URL |
| 3 | 只读提示/状态文案挂载 | **W1-03 已挂载**：培养列表页新增只读入口说明块（P01 仅内部接线、P02—P04 未接线），见 §4.4；操作入口本身仍 NO_UI |
| 4 | 错误码可读化 | **部分实现**：本包无统一 block code 映射，故按总控许可在培养页 + 语言包补最小文案（24 个码） |
| 5 | 测试辅助 data-testid | **已实现**：列表页 9 个 + 编辑器 5 个，业务逻辑零变更 |

## 2. 页面 / 菜单 / API 盘点结果

以下每条结论都对应一条实际执行过的只读检索，未执行的动作不得写成已完成。

### 2.1 前端页面承载盘点（`route-paths.generated.ts:80-89` 为权威路由登记）

| 页面域 | 路由 path → 路由名（生成物行号） | 视图目录 | 结论 |
| --- | --- | --- | --- |
| 培养（CU02 列表） | `resource/culture/index` → `culture-management`（:82） | `app-smp-settings/src/views/culture-management/` | **存在**，本批唯一有实质改动的 M03 页面 |
| 项目 | `resource/project/index` → `project-management`（:85） | `views/project-management/` | 存在，本批**未改动**（不属参数候选链路） |
| 培养负责人/成员 | `resource/cultureleader/index`、`resource/culturemember/index`（:83-84） | `views/resource-culture*` | 存在（授权关系页） |
| 项目实验室/负责人/成员/标签 | `resource/project*`（:86-89） | `views/resource-project*` | 存在（授权关系页） |
| 批次 | `resource/batchleader/index`、`resource/batchmember/index`（:80-81） | `views/resource-batch*`、`views/batch-management/` | 存在 |
| **培养参数 / 参数候选 / 参数快照 / 生效包** | `grep -c "parameter" route-paths.generated.ts` = **0** | 无 | **NO_UI** |
| **审批生效（M06 审批承载）** | 无 | `grep -rl "审批" app-smp-settings/src/views/` = **0 文件** | **NO_UI**（与 M06 批口径一致） |

交叉检索（避免漏判）：

- `grep -rniE "参数候选\|候选快照\|parameterCandidate\|parameter-candidate\|effectivePackage\|effective_package\|参数包" packages/*/src` ⇒ **0 命中**（Batch 05 时点）。**W1-03 复核**：同命令现仅命中 work1 本批新增的两处——`views/culture-management/m03-parameter-entry.ts`（只读提示模块）与 `sdk-language/src/language/smp-settings/{cn,en}.ts` 的 `parameterPort*/parameterState*` 词条；`packages/sdk-smp-api/src` 与任何 `*.vue` 的请求层**仍为 0 命中**，即没有新增请求封装。
- `grep -rn "\"DIRECT\"\|'DIRECT'\|APPROVAL" packages/app-smp-settings/src packages/sdk-smp-api/src` ⇒ 3 命中，全部是 M04 补液模板的 `APPROVAL_CONTEXT_UNAVAILABLE` 错误码 key，**不存在** DIRECT/APPROVAL 业务状态展示。
- `app-smp-lab/src/views/culture-dashboard/index.vue` 含硬编码 mock 数组（`CULTURE_IDS`、`parameterOptions`），是原型残留，**不是** M03 参数候选承载点，本批未触碰、也未据其判定「存在页面」。
- `views/config-management`（系统参数配置）与 `detectionrule-management`、`pump-speed-management`（`noSpeedCandidate` 泵速候选文案，`smp-settings/cn.ts:1633`）均不属 M03 培养参数域，已排除误判。

### 2.2 后端 M03 参数候选链路的真实形态（只读核对，本批不改后端）

| 层 | 位置 | 状态 |
| --- | --- | --- |
| Port 接口 | `service/port/m03/ParameterPackagePort.java`（4 方法） | 接口 + Javadoc（`PublicInterfaceInventoryTest:215-216` 登记为内部方法） |
| Port 模型 | `service/port/m03/model/`：`ParameterCandidateCommand`/`ParameterCandidateResult`/`ParameterDecisionCommand`/`ParameterApplicationQuery`/`EffectivePackageQuery`/`EffectivePackageView` | 存在（命令/视图类型） |
| Port 实现 | `service/port/m03/ParameterPackagePortImpl.java:107`（提交 `b9769b2a M03-P01 参数候选固化最小接线`） | **P01 已实现**（`saveParameterCandidate:186`）；**P02 :953 / P03 :961 / P04 :972 一律 `throw ACTION_NOT_SUPPORTED`**，后端注释明写「未接线」 |
| HTTP 出口 | `grep -rniE "ParameterPackagePort\|parameter-candidate\|culture/parameter" --include=*.java */src/main/java/**/controller*/` ⇒ **0 命中**（全仓 controller 层） | **仍无 HTTP 出口**：P01 只能被其他后端服务内部调用，浏览器不可达 |
| 持久化 | `docs/开发基线/01-完整建表.sql:1986`（`res_culture_parameter_application`）、`:2007`（`res_culture_parameter_snapshot`）、`:2034`（`res_culture_parameter_state`）；`mapper/ResCultureParameter{Application,Snapshot,State}Mapper.java` | 表 + Mapper 存在（3868bc5c 五表基础层）。**W1-03 更新**：`ParameterPackagePortImpl:144-147` 已注入 `ResCultureMapper`/`SnapshotMapper`/`StateMapper`/`WorkflowReferenceMapper`，即持久化**有内部消费方**；Controller 层仍无消费方（故前端依然不可达） |
| 签名登记 | `src/test/.../PortSignatureSnapshotTest.java:76-79` 登记 M03-P01—P04 四个内部签名 | 与「内部 Port、非 HTTP」口径一致 |

⇒ **P01（saveParameterCandidate）/P02（applyParameterDecision）/P03（queryParameterApplication）/P04（readEffectivePackage）当前都不是浏览器可达接口。** 契约本身也规定 HTTP 不新增通用「应用任意模板」入口（`docs/详细设计/03-项目与培养管理/接口目录与契约定位.md` 定位001：内部方法与详情；`培养参数快照与审批生效收尾契约.md`）。因此：

- 本批**不**为参数候选新增任何 SDK 请求封装：没有真实 URL 可封，编造路径等于虚构接口。
- 本批**不**调用 P02/P03/P04，**不**做 APPLY，**不**展示「已生效/已应用/审批已创建」。
- 与总控前置背景的**坐标差异（已在 W1-03 复核时消解）**：上一轮在 HEAD `d52ccc36` 检索不到 `implements ParameterPackagePort`，登记为 R1 并请总控确认。**2026-10-06 复核时 HEAD 已前进到 `b9769b2a M03-P01 参数候选固化最小接线：只经M04取包复核、M06判策，不做APPLY不接M07`**，`git show --stat b9769b2a` 显示其改动为 `ParameterPackagePortImpl.java`（+977）、`ParameterCandidateResult.java`、`M03ParameterCandidateP01ContractTest.java`，即该提交确实在总控口径内、只是当时不在 work1 可见坐标。修正后的结论：**P01 有 Provider、但仍无 HTTP 出口**，因此「前端不新增请求封装、参数候选操作入口 NO_UI」的原判定不变，理由从「无实现」更新为「有内部实现但浏览器不可达」。

### 2.3 培养页现有 HTTP 出口与守卫分层（决定本批提示挂载位置）

`ResCultureController.java` 实测注解/路由映射：

| 契约号 | 路由 | 注解 | 前端是否调用 |
| --- | --- | --- | --- |
| M03-017 CU01 | `GET /resource/culture/list` | `@RequiresPermissions("resource:culture:list")` + `@CurrentManagementRevision`（:117） | 是（列表） |
| M03-018 CU02-R | `GET /resource/culture/{cultureId}` | `resource:culture:query` + `@CurrentManagementRevision`（:158） | 是（编辑/详情） |
| LEGACY-CULTURE-ADD/EDIT | `POST` / `PUT /resource/culture` | 仅 `@RequiresPermissions`，**无守卫** | 是（新增/修改仍走此口） |
| LEGACY-DEL-CULTURE | `DELETE /resource/culture/{cultureIds}` | 无守卫 | 是（批量删除） |
| LEGACY-EXIT-CULTURE | `PUT /resource/culture/exit` | 无守卫 | 是（退出培养） |
| 成员口（无契约号） | `GET/PUT /{cultureId}/members`、`/member-tree`、`/member-details` | 无守卫 | 是（成员/分享对话框） |
| M03-024 CU02-W | `POST /{cultureId}/mode` | 应用服务显式 **501 骨架** | 否 |
| M03-020/021/022/023/025/026 | `n-mark`、`basic-batch`、`delete-preview`(只读 POST)、`delete`、`withdraw`、`rebook` | `@ManagementGuardedWrite`（:260/:276/:319/:335/:351，delete-preview 除外） | **否（前端无调用方）** |
| M03-031 CU-W01 | `GET /{cultureId}/initial-weight` | 真实只读 + `@CurrentManagementRevision` | 否 |
| M03-032/033 CU-W02/R01 | `POST /{cultureId}/initial-weight-changes`、`/runtime-changes` | 应用服务显式 501 | 否 |
| M03-034/035/036 CU-R02/R03/R04 | `GET .../runtime-changes/current`、`.../{candidateId}`、`.../runtime-change-requests/{requestId}` | **真实只读链路** | 否（`grep -rn "runtime-change\|runtimeChange" packages/sdk-smp-api/src` ⇒ **0 命中**） |

⇒ 三个 M03 运行变更候选只读口（CU-R02/R03/R04，含「候选」语义、真实接线）目前**没有任何前端封装与页面**。这是本批最接近「参数候选入口」的现有能力，但它承载的是培养运行变更（编号/日期），不是参数包快照，且写口 CU-R01 仍是 501，因此不能据此建候选操作页（登记 R2，供总控决定是否另立批次做只读挂载）。

### 2.4 本批点名错误码的逐一可达性判定（M03 侧普查）

`service/impl/application/m03/` + `controller/ResCultureController.java` + `controller/ResProjectController.java` 的 `FutureFabErrorCode.*` 使用计数（实测）：

```
40 INPUT_INVALID   15 PERMISSION_DENIED   11 STATE_CONFLICT   10 VERSION_CONFLICT
 5 DEPENDENCY_UNAVAILABLE   4 FACTS_UNAVAILABLE   3 DELETE_SCOPE_CHANGED
 2 DEVICE_INVALID   2 CULTURE_CODE_CONFLICT   2 CODE_CONFLICT
 1 REFERENCE_EXISTS  1 PREVIEW_EXPIRED  1 PLAN_DEADLINE_PASSED
 1 LAB_AUTHORIZATION_UNAVAILABLE  1 DEVICE_OCCUPIED  1 BATCH_LIMIT_EXCEEDED
```

对本批点名的 11 个词：

| 点名项 | 是否 `FutureFabErrorCode` 成员（实测行号） | M03 是否抛出 | 本批处置 |
| --- | --- | --- | --- |
| VERSION_CONFLICT | 是（`:337`，409） | 是（`CultureApplicationServiceImpl:284/426/844/904/983/1127`） | 登记文案 |
| ACTION_NOT_SUPPORTED | 是（`:131`，400） | **否**（`service/impl/application/m03` 包内 0 抛出点） | 仅登记文案，注明不可达。**W1-03 补充**：`service/port/m03/ParameterPackagePortImpl.java:953/961/972` 各抛 1 次，但那是**内部 Port 的失败关闭**，无 HTTP 出口 ⇒ 培养页仍收不到该码，提示块因此写成静态说明而非「响应驱动的错误提示」 |
| APPROVAL_CONTEXT_UNAVAILABLE | 是（`:145`，503） | **否** | 同上 |
| CONTENT_INVALID | 是（`:177`，400） | **否** | 同上 |
| SCHEMA_UNSUPPORTED | 是（`:299`，400） | **否** | 同上 |
| SOURCE_VERSION_CONFLICT | 是（`:317`，409） | **否** | 同上 |
| REQUEST_CONFLICT | 是（`:279`，409） | **否**（由守卫/幂等基础设施产生，M03 不直接抛） | 同上 |
| MANAGEMENT_CONFLICT | 是（`:225`，409） | **否**（守卫基础设施码） | 同上 |
| BLOCKED_M06 | **不是枚举成员** | — | **不建映射** |
| BLOCKED_M07 | **不是枚举成员** | — | **不建映射** |
| BLOCKED_M04_ENGINEERING_RESOLUTION | **不是枚举成员**；仓内最接近的是 `BLOCKED_M04_PUBLISH_ENGINEERING_WRITE`（`M04EngineeringBundleContractTest.java:48` 注释） | — | **不建映射** |

`grep -cE "BLOCKED_M0[467]" FutureFabErrorCode.java` = **0**；`grep -rl "BLOCKED_M06\|BLOCKED_M07\|BLOCKED_M04_ENGINEERING_RESOLUTION" --include=*.java` 只命中 M06 两个 Javadoc（`ApprovalReconciliationCommandApplicationServiceImpl.java:56`、`ProcessApprovalQueryApplicationServiceImpl.java:68,275`）。⇒ 这三个词是**后端任务登记词**，不会出现在响应外壳 `errorCode` 字段，给它们建前端映射等于伪造一条永不成立的提示链路（本批明确不做，改由测试 §6 C 组反向断言）。

另需诚实标注的可达性收缩：培养页当前**只在只读口上**能确定拿到带 `errorCode` 的外壳 —— `service/impl/m03/M03ListQuerySupport.java:59/78/97/118/136/177/186/194`（INPUT_INVALID）与 `:206`（NOT_FOUND）。新增/修改/删除/退出仍走 LEGACY 口的 `toAjax` 通道（无 `errorCode`），因此这些码的映射实际生效前提是接口切到 §2.3 的契约写口；文案登记不代表本页此刻可复现该提示（§7 BACKEND_NOT_VERIFIED）。

### 2.5 菜单与权限

- `grep -c "sys_menu" docs/开发基线/02-基础数据初始化.sql` = **0**；仓内唯一 `INSERT INTO sys_menu` 位于 `sql/seed/20261003_m09_menu_perms_install.sql`（M09）。⇒ 菜单为**运行库态**，静态不可判定，本批不得据源码声称菜单可达（**BLOCKED_MENU**，交 work5/work9 在真实门户核对）。
- 培养域权限位实测（前端 `session.has` + 后端注解）：`resource:culture:list/query/add/edit/remove/mode`。
- 参数候选域**没有**任何权限位、菜单项或 seed SQL。

### 2.6 工作副本在途状态（避免误认领）

`git status --short` 显示大量**非本批**的在途改动（benchreactor/venue/lab-labbenchreactor/feeding-template/alarm-* 等，属其他 work），其中 `packages/sdk-language/src/language/smp-settings/{cn,en}.ts` 为共享文件：本批只在该文件追加 `settings-culture.error*` 键，未回退、未改写他人 hunk（见 §5 V8 的 hunk 归属证明）。本批未 `git add`、未 commit。

## 3. 修改文件清单

| # | 文件 | 类型 | 说明 |
| --- | --- | --- | --- |
| 1 | `futurefab-frontend/packages/app-smp-settings/src/views/culture-management/m03-culture-error.ts` | 新增 | M03 培养页 code→可读文案纯函数映射（可达/仅登记两段） |
| 2 | `futurefab-frontend/packages/app-smp-settings/src/views/culture-management/m03-parameter-entry.ts` | 新增（W1-03） | 参数候选入口只读提示数据（P01—P04 四行 + 定位属性函数），零 import、无 URL |
| 3 | `futurefab-frontend/packages/app-smp-settings/src/views/culture-management/index.vue` | 修改（`+74/−10`） | 4 处错误通道改走 `describeError`；9 个 `data-testid`；**W1-03 追加只读提示块（+20 行模板 + 21 行样式）** |
| 4 | `futurefab-frontend/packages/app-smp-settings/src/views/culture-management/culture-editor.vue` | 修改（`+17/−4`） | 2 处错误通道改走 `describeError`；5 个 `data-testid` |
| 5 | `futurefab-frontend/packages/sdk-language/src/language/smp-settings/cn.ts` | 修改 | `settings-culture` 段新增 24 条错误码文案 + **W1-03 9 条提示文案**；本批在该文件内共 2 个 hunk，其余 hunk 属他人 |
| 6 | `futurefab-frontend/packages/sdk-language/src/language/smp-settings/en.ts` | 修改 | 同 key 英文镜像（`settings-culture` 键集对称，W1-03 后 cn 侧 76 键，含他人追加的 1 键；无重复键） |
| 7 | `futurefab-frontend/tests/m03-culture-candidate-entry.test.ts` | 新增（W1-03 扩充） | 22 条断言 = Batch 05 的 15 条 + W1-03 的 7 条（提示行覆盖/静态性/目录对称/中文口径/页面接线/testid 约定/项目页范围留痕） |
| 8 | `docs/开发任务/frontend/M03/M03-culture-parameter-w1-03-candidate-entry-前端交付与测试方案-20261006.md` | 更名 + 更新 | 本文件（原 `...batch05...20261006.md`，按总控 W1 序列更名） |

后端 Java / Mapper / XML、SQL、客户只读材料、history、M02/M04/M06/M07/M09 页面、`project-management/`：**零改动**。`packages/sdk-smp-api/`：**零改动**（未新增封装，故未改 SDK 类型，`build-dts` 本批不适用）。

## 4. 本轮功能 / 文案 / 提示改动

### 4.1 错误码可读化（目标 4）

新增 `m03-culture-error.ts`：

- `M03_READ_PATH_ERROR_CODES = ["INPUT_INVALID", "NOT_FOUND"]`：本页当前调用链可证抛出的码（§2.4 的 `M03ListQuerySupport` 行号）。
- `M03_REGISTERED_ONLY_ERROR_CODES`（22 项）：抛出点属 M03 契约写口或其他 M03 页面，本页此刻收不到；登记只为接口切换后不再裸透出，注释与 MD 同时声明「不代表已验证可达」。
- `cultureErrorCode()` 只从 `ApiError.errorCode` 取码（`client.ts:15-18` 从响应外壳读取），普通 `Error`、空串一律不猜码。
- `cultureErrorMessage(reason, translate)`：登记码 → 固定口径；未登记码 → 原样透出服务端 msg（不自造结论）。`translate` 由页面注入 `t(key, fallback)`，保持语言切换响应式，缺失词条自动回落服务端消息。
- 两段并集正好覆盖映射表（测试 §2 反向钉住），无第三类静默码。

培养页接线（业务逻辑、请求序列、状态机全部不变）：

- `index.vue`：`dictError`（选项加载）、删除 `showError`、退出 `showError`、列表 `onListError` 共 4 处 `errorMessage(e)` → `describeError(e)`；顺带移除已不再使用的 `errorMessage` 直接导入。
- `culture-editor.vue`：详情加载与保存失败 2 处同样改为 `describeError(e)`。

### 4.2 只读提示文案口径（目标 3，本批以「口径 + 不伪造」交付）

因 §2.1 无候选状态可挂载，本批不新增区域、不建壳页面，改为交付可被 work5/后续批次直接引用的判定口径，并用测试钉住：

| 状态/情形 | 必须显示为 | 严禁显示为 |
| --- | --- | --- |
| P01 后端能力存在但无 HTTP 出口 | 「参数候选快照无浏览器可达接口」 | 「已提交候选」「已生成候选快照」 |
| P02/P03/P04（应用决定/回执查询/生效包读取） | 「暂不支持（ACTION_NOT_SUPPORTED 级），本页面未调用」 | 「应用成功」「回执已确认」 |
| DIRECT 档 | 「直发候选，尚未核验生效」 | 「已生效」「已应用」 |
| APPROVAL 档 | 「需审批，本页面未创建审批单」 | 「审批已创建」「审批已通过」 |
| `BLOCKED_M06` / `BLOCKED_M07` / `BLOCKED_M04_ENGINEERING_RESOLUTION` | 后端登记词；HTTP 响应不会出现 ⇒ 前端提示只能来自真实 `errorCode`（如 503 `DEPENDENCY_UNAVAILABLE`/`FACTS_UNAVAILABLE`/`APPROVAL_CONTEXT_UNAVAILABLE`） | 把登记词当作错误码映射 |
| schema1 历史包 / schema2 缺工程段 | schema1：仅保留只读解码，不可激活；schema2 缺工程段：失败关闭，提示「未写入」 | 「降级解释成功」「已按旧 schema 生效」 |

对应测试反向钉：培养页源码与本批语言包 `settings-culture` 段**不得**出现「已生效/已应用/审批已创建/已提交审批」，页面**不得**引用 `saveParameterCandidate`/`applyParameterDecision`/`queryParameterApplication`/`readEffectivePackage` 或任何 parameter/candidate/apply/effective URL，**不得**硬编码 `managementRevision`/`expectedVersion`。

### 4.3 测试锚点（目标 5）

| 位置 | data-testid |
| --- | --- |
| 检索输入框 | `culture-filter-search` |
| 查询 / 重置按钮 | `culture-btn-search` / `culture-btn-reset` |
| 新增按钮 | `culture-btn-add` |
| 批量设置成员 / 分享 / 删除 | `culture-btn-batch-member` / `culture-btn-batch-share` / `culture-btn-batch-delete` |
| 已选计数区域 | `culture-selected-count` |
| 表格容器 | `culture-grid` |
| 编辑器表单容器 | `culture-editor-form` |
| 编辑器字段 | `culture-field-code` / `culture-field-name` / `culture-field-mode` / `culture-field-special` |

未加锚点之处及原因：`SmpDialog` 的确认/取消按钮由 `sdk-smp-common` 内部渲染且只透传 `disabled/loading`（`dialog/index.vue:18-19`），无法挂 `data-testid`；本批不改 SDK（越界），work5/work9 改用可见文案「保存/取消」定位。行内操作按钮由 `SmpTableActions` 统一渲染，同理以文案定位。

### 4.4 参数候选入口只读提示块（W1-03，目标「P01 候选提示、P02-P04 不支持提示」）

总控本轮把目标具体化为两类提示，故按 §4.2 已登记的口径**挂载**，而不是继续只交口径：

- 数据源：`culture-management/m03-parameter-entry.ts` 导出 `M03_PARAMETER_NOTICE_ROWS` 四行（`P01` 状态 `INTERNAL_ONLY`；`P02/P03/P04` 状态 `NOT_WIRED`）与 `parameterNoticeTestId()`。**该模块零 import**（不含任何 SDK/API 引用），因此它不可能发起请求，只是静态说明；模块头注释登记后端证据行号（`ParameterPackagePortImpl.java:107/:186/:953/:961/:972`）。
- 渲染：`culture-management/index.vue` 在筛选区之后、表格之前插入 `.culture-parameter-notice` 块（`flex: 0 0 auto`，表格仍 `flex: 1 1 0`，布局不被挤压）。容器 `data-testid="culture-parameter-notice"`，逐行 `:data-testid="parameterNoticeTestId(row.port)"` ⇒ `culture-parameter-p01`…`p04`。
- 文案：`settings-culture.parameterNoticeTitle` / `parameterPortP01..P04` / `parameterStateInternalOnly` / `parameterStateNotWired` / `parameterStateNoReceipt` / `parameterNoticeNoConclusion`（cn/en 各 9 条，键集对称）。中文明说「后端仅内部 Port 接线，无对外接口」「返回 ACTION_NOT_SUPPORTED」，末句为「本页不输出候选固化成功、决定执行完毕或审批单建立之类的结论」。
- **不改变任何业务逻辑**：无新请求、无新路由、无状态机、无写口；`culture-editor.vue` 未加该块（候选属列表域上下文）。
- 范围决策（留痕，待总控裁决 R6）：**项目页 `project-management/index.vue` 未挂该提示**。依据是 `saveParameterCandidate` 的必填入参为 `cultureId`/`workflowNodeId`/`templateId`（`ParameterPackagePortImpl:190-192`），**没有 `projectId`**；在项目页挂候选提示等于暗示一个不存在的入口。已有测试 `项目页未挂该提示…` 钉住这一决策，若总控裁决要挂，改该测试与两页接线即可。

### 4.5 勘误（2026-10-14，总控 hold 车道，HEAD `59e840ec5`）

本轮前端红灯归因发现，本节交付面已被后续 M03 提交改写。只登记事实，不回退他人有意改动：

| 原条款 | 现状 | 归因 | 处置 |
| --- | --- | --- | --- |
| §4.3「新增按钮 `culture-btn-add`」 | 页面无该按钮，`canAdd` 一并消失 | `7b2f0f9af`（2026-10-14，zou jun）说明「统一草稿及各生命周期状态文案与权限显隐」 | 判为 M03 车道有意改动，**未恢复**；§4.3 该行仅按历史登记保留，以本行为准 |
| §4.3「编辑器字段 `culture-field-special`」 | testid 消失，`isSpecial` 同时从页面与 SDK 撤除（`sdk-smp-api` 内 0 命中） | `2ea37f172`（2026-10-13，zou jun）明文「培养编辑移除特殊培养字段，小试固定普通培养」 | 有契约理由的有意改动，**未恢复**。遗留不一致：库表 `01-完整建表.sql:1711 is_special` 与 Java `ResCulture`/`M03CultureQueryRow`/`CultureRow` 仍持有该字段，前端已无读写口，列入待通报事项 |
| §4.4 参数候选只读提示块 | 曾被整块删除，本轮按 §4.4 原口径挂回 | `7b2f0f9af` 提交说明未提及候选提示，属**无声删除**，且未同步 `tests/m03-culture-candidate-entry.test.ts` 钉桩，vitest 自删除日起持续红 | 恢复为零 import 的静态说明块，不改取数与写路径；改动**未提交**，等总控确认是否维持 M03 车道的新口径 |
| §4.3 锚点清单 | 现存但未登记：`culture-btn-batch-edit`、`culture-btn-compare` | M03 后续批次新增的批量修改与对比交互 | 补登记，供 work5/work9 定位 |

层级不因本勘误升级：恢复与红灯收口只到**静态 + vitest**（`tests/culture-management.test.ts`、`tests/m03-culture-candidate-entry.test.ts`、`tests/m03-grant-exit-facts.test.ts` 全绿）；HTTP、浏览器、真库仍为 `NOT_VERIFIED`，R1—R7 待裁决项继续有效。

## 5. 已执行验证命令与结果

| # | 命令 / 检查 | 层级 | 结果 |
| --- | --- | --- | --- |
| V1 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 编译/类型 | **exit=0**（本批未改 SDK，仍按要求执行确认基线） |
| V2 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 编译/类型 | **exit=0**，0 条 `error TS` |
| V3 | `pnpm run routes:check` | 静态一致性 | **exit=0**（本批未新增路由） |
| V4 | `npx vitest run tests/m03-culture-candidate-entry.test.ts tests/culture-management.test.ts` | 单元/静态钉 | Batch 05 轮：**2 文件 / 23 用例全绿**（15 + 8）。W1-03 追加后重跑：**2 文件 / 30 用例全绿**（22 + 8），见 V11 |
| V5 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 生产构建（本包） | **exit=0** |
| V6 | `npx vitest run`（全量，改前/改后各一次） | 回归对照 | 改前 `106 文件 / 1121 用例 / 28 失败`；改后 `1153 用例 / 28 失败`。失败数不变、通过数 +32（含本批 15）⇒ 本批未引入新红；28 条红全部属其他 work 在途（清单见 V7） |
| V7 | 红项归属核对：`npx vitest run tests/localization.test.ts \| grep -ci culture` | 归属证明 | **0**：该套件缺词全部指向 `lab-statusalarm/*`、`smp-notification/*`、`system-user/*`、`venue` 等他人文件，无一指向我新增的 `settings-culture.error*`（配套 cn/en 键集对称，见 V9） |
| V8 | `git diff -U0 -- .../smp-settings/cn.ts \| grep "^@@"` | hunk 归属 | 本批仅 `@@ -1275,0 +1289,28 @@`（`settings-culture` 段）一个 hunk 属 work1；其余 hunk（`:366/:419/:1684` 附近）为 venue/benchreactor/M04 的在途改动，未改写、未回退 |
| V9 | Python 抽取 `settings-culture` 键集比对 cn/en | i18n 对称 | cn 66 键 / en 66 键 / 差集 **空**；其中本批错误码键 24 条 |
| V10 | 后端只读检索（§2.2/§2.3/§2.4 全部 grep 与行号核对） | 契约静态 | 与结论一致；未修改任何后端文件 |

**W1-03 追加轮（2026-10-06 01:15–01:25，HEAD `b9769b2a`）**：

| # | 命令 / 检查 | 层级 | 结果 |
| --- | --- | --- | --- |
| V11 | `npx vitest run tests/m03-culture-candidate-entry.test.ts tests/culture-management.test.ts` | 单元/静态钉 | **2 文件 / 30 用例全绿**（本批套件 22 = 原 15 + W1-03 新增 7；培养页原 8 无回归） |
| V12 | 三条必跑命令（api type-check / app type-check / `routes:check`） | 编译/类型/静态 | 追加提示块后重跑：**exit=0 / 0 / 0** |
| V13 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 生产构建（本包） | **exit=0**，产物 `dist/culture-management-C1Yj7xSX.js` 31.45 kB / gzip 7.63 kB |
| V14 | 产物抽查（同一产物内 grep） | 构建内容 | `culture-parameter-notice` 5 处、`culture-parameter-` 6 处（含运行时拼接用的前缀 1 处）、`settings-culture.parameterPort` 4 处 ⇒ 提示块确已进入被服务的页面块。行级定位值是运行时由 `parameterNoticeTestId()` 拼出，产物里只有前缀，完整值 `culture-parameter-p01..p04` 只出现在浏览器 DOM（work9 取证点） |
| V15 | Python 抽取 `settings-culture` 键集比对 cn/en | i18n 对称 | W1-03 后 **cn 76 / en 76，差集为空，无重复键**（V9 记录的 66 键为 Batch 05 时点；本批 +9 提示键，另 1 个非本批键由他人在同段追加） |
| V16 | `npx prettier --check`（本批新增两文件） | 风格 | `m03-parameter-entry.ts`、`tests/m03-culture-candidate-entry.test.ts` ⇒ **All matched files use Prettier code style**；`index.vue` 的 prettier 差异仅在 `:8` 与 `:247-253`（HEAD 版本同命令即有 27 行差异，属他人在途风格），本批新增的模板/样式区**零差异**；`cn.ts` 内本批的 `errorManagementConflict` 换行已按 prettier 口径合行 |
| V17 | `npx vitest run tests/localization.test.ts \| grep -ciE "culture\|parameterNotice\|parameterPort\|parameterState"` | 归属证明 | **0**（该套件仍报 123 条缺词，无一指本批键；1 红为背景红） |

**W1-03 收口轮（2026-10-06 01:30，HEAD `0d5dc91e`）**：交付前 HEAD 又前进一个提交（`0d5dc91e M07 preparePlanReplacement SQL 映射与屏障 CAS 契约增强`，`git show --stat` 显示只新增 1 个后端测试文件 `M07PlanReplacementSqlMappingContractTest.java`，与本批前端文件零交集），故在本批全部检查重跑一次，不使用 `b9769b2a` 的旧结果：

| # | 命令 / 检查 | 层级 | 结果 |
| --- | --- | --- | --- |
| V18 | `pnpm --filter @futurefab/ui-sdk-smp-api run type-check` | 类型 | **exit=0** |
| V19 | `pnpm --filter @futurefab/ui-app-smp-settings run type-check` | 类型 | **exit=0** |
| V20 | `pnpm run routes:check` | 静态 | **exit=0** |
| V21 | `npx vitest run tests/m03-culture-candidate-entry.test.ts tests/culture-management.test.ts` | 单元/静态钉 | **2 文件 / 30 用例全绿**（22 + 8，与 V11 同） |
| V22 | §2.2 与 D4 的两段后端只读 `grep` | 契约静态 | Port 层命中行号在 `0d5dc91e` 未漂移（`:871/:875/:955/:963/:974`）；`service/impl/application/m03/` 仍无 `ACTION_NOT_SUPPORTED` 等五码 ⇒ 本批文案口径不变 |

| V23 | `pnpm --filter @futurefab/ui-app-smp-settings run build` | 生产构建（本包） | **exit=0**，产物仍为 `dist/culture-management-C1Yj7xSX.js` 31.45 kB / gzip 7.63 kB，与 V13/V14 完全同名同尺寸 ⇒ `0d5dc91e` 未改动本包页面块内容 |

V14 的产物内 token 抽查（`culture-parameter-notice` 5、`culture-parameter-` 6、`settings-culture.parameterPort` 4）以同一哈希产物为准，未在收口轮重复 grep。

**关于 V5 的一次非本批失败记录（必须留痕）**：本批首次 `build` 曾失败，报错为 `src/views/alarm-sms-delivery/view.vue(25,20): error TS2339: Property 'deliveryNeedsExternalHint' does not exist ...`，随后一次重试改报 `alarm-mail-delivery/index.vue`。两处都是 `git status` 中标 `M` 的 M09 告警页在途文件（另有 `shared/m09-status.ts`、`shared/m09-external-hint.vue`、`shared/m09-test-ids.ts` 等未跟踪新增），与本批文件无交集；重试后 `exit=0`（V5）。判定：**其他 work 的在途编译红，非本批引入**，但本批不为该红背书，work5 复核时应先确认告警页在途改动已收敛。

未运行：`lint:check` / `format:check`（仓内 biome↔prettier 互斥口径仍未裁决，已作为遗留项登记，不属本批范围）；`build-dts`（本批未触碰 SDK 类型，无 dts 变更）；任何 HTTP 请求、浏览器操作与 SQL 执行。

## 6. 给 work5 的详细测试方案

work5 的任务是复核**盘点结论**与**最小改动的正确性**，不是给不存在的候选页编造用例。

### 6.1 A 组 · 入口与菜单可达性（真实环境）

| 用例 | 步骤 | 期望 | 证据形式 |
| --- | --- | --- | --- |
| A1 | 门户登录后打开左侧菜单与全局搜索，检索「参数候选 / 快照 / 生效 / parameter」 | 无任何 M03 参数候选入口（**若出现入口，本批 NO_UI 判定作废，立即回报总控**） | 菜单截图 + 搜索面板截图 |
| A2 | 进入「培养ID管理」页（`resource/culture/index`） | 页面正常加载列表；`data-testid="culture-grid"` 可定位 | DOM 截图 + testid 命中记录 |
| A3 | 逐一确认 §4.3 的 14 个 testid 在真实 DOM 存在 | 全部命中（列表 9 + 编辑器 5） | `querySelector` 计数输出 |
| A4 | 核对页面可见文案不含「已生效 / 已应用 / 审批已创建」 | 0 命中 | 页面全文本导出 |

### 6.2 B 组 · 现有培养功能回归（零业务变更验证）

| 用例 | 步骤 | 期望 |
| --- | --- | --- |
| B1 | 检索（`culture-filter-search`）→ 查询（`culture-btn-search`） | 列表按条件刷新；翻页不丢条件 |
| B2 | 重置（`culture-btn-reset`） | 草稿条件清空，列表回第一屏 |
| B3 | 新增（`culture-btn-add`）→ 填 `culture-field-code` + 选 `culture-field-mode` → 保存 | 成功提示，列表出现新行；`culture-field-special` 开关不影响其余字段 |
| B4 | 行内「修改」→ 改别名 → 保存 | 详情先落地再开窗（无空窗闪烁） |
| B5 | 勾选行 → `culture-btn-batch-member` / `culture-btn-batch-share` | 对话框批量标题正确；未选负责人行时按钮禁用 |
| B6 | `culture-btn-batch-delete` → 确认 | 删除成功后从第一屏重载；`culture-selected-count` 清零 |
| B7 | 无 `resource:culture:remove` 权限账号登录 | 删除入口不可见（不是「可见但报错」） |

### 6.3 C 组 · 本批改动本体（错误码可读化 + 不伪造）

| 用例 | 构造方式 | 期望 | 关键点 |
| --- | --- | --- | --- |
| C1 | 列表页 URL 手工改 `pageSize=7`（非法分页值） | 提示「请求内容不合契约（缺字段或格式不符），本次未提交」，不再是裸服务端串 | 证明 `INPUT_INVALID` 映射生效（`M03ListQuerySupport:78`） |
| C2 | 以不存在的 cultureId 直接请求编辑器详情（或删后旧窗口保存） | 「记录不存在、已删除或不在可见范围，请刷新列表」 | `NOT_FOUND` 映射（`M03ListQuerySupport:206`） |
| C3 | 未登记码（例如其他模块的 `REFERENCE_EXISTS` 场景在本页出现） | **原样透出服务端 msg**，不得显示本批任一口径文案 | 未登记码不猜语义 |
| C4 | 切英文重复 C1/C2 | 英文文案正确，且与本批 `en.ts` 条目逐字一致 | 目录对称 |
| C5 | 全程开 Network 面板跑完 B1—B6 | **不得出现**任何含 `parameter`/`candidate`/`apply`/`effective` 的请求 URL；写请求仍只有 `POST/PUT/DELETE /resource/culture*` 与成员口 | 钉住「未调用 P02/P03/P04、未做 APPLY」 |
| C6 | 检查任一写请求的 request payload 与 headers | 无 `managementRevision`/`expectedVersion` 的硬编码值；本批未新发守卫写请求 | §13.3 不伪造版本 |
| C7 | 断网或后端停服务制造真实失败 | 提示走 msg 回落，页面不显示「已生效」类结论 | 失败关闭口径 |

判定口径：C5/C6 是本批最关键的两条 —— 它们证明前端**没有**把候选/应用链路的缺失伪装成可操作。若 work5 在 Network 里看到任何 APPLY 类调用，即为 FAIL 并回报。

### 6.3b E 组 · 参数候选入口只读提示块（W1-03 新增，浏览器/静态均可）

| 用例 | 步骤 | 期望 | 关键点 |
| --- | --- | --- | --- |
| E1 | 打开 `/resource/culture/index`，观察筛选区与表格之间 | 出现只读说明块（`culture-parameter-notice`），标题为「参数候选快照入口状态（只读说明，非操作入口）」 | 挂载位置正确，不遮挡表格、不改变表头高度 |
| E2 | 检查说明块内四条行的定位属性 | DOM 上依次为 `culture-parameter-p01`、`p02`、`p03`、`p04`（值由 `parameterNoticeTestId()` 运行时拼出，产物里只有前缀） | work9 需用 `take_snapshot`/DOM 取证，不能只看构建产物 |
| E3 | 读 P01 行文案 | 含「后端仅内部 Port 接线，无对外接口」「不发起该调用，也不显示固化结果」 | 与 §2.2 的 `b9769b2a` 事实一致，不暗示可用 |
| E4 | 读 P02/P03/P04 行文案 | 三行均为「未接线/ACTION_NOT_SUPPORTED」级；P03 单独说明「回执由 P02 产生」 | 三条不可用理由不被合并成一句笼统提示 |
| E5 | 全页文字搜索 | **不得**出现「已生效」「已应用」「审批已创建」「已提交审批」「快照已保存」「决定已执行」等结论词（说明块自身是否定句式，需人工判定语境） | 只读说明不得反向变成结论 |
| E6 | 切英文重载 E1—E4 | 四条行与末句英文齐全，无缺 key 回落到中文 | `en.ts` 9 条键已登记（V15 对称） |
| E7 | Network 面板复跑 E1—E4 | 说明块渲染**不产生任何新请求**（`m03-parameter-entry.ts` 零 import，只读渲染） | 与 C5 互相印证：提示是静态说明，不是接口轮询 |

### 6.4 D 组 · 静态与后端只读复核（离线可执行）

| 用例 | 步骤 | 期望 |
| --- | --- | --- |
| D1 | 重跑 §2.1 的三条前端检索 | 命中集合与 §2.1 表格一致（候选/快照/审批生效 0 承载） |
| D2 | `grep -rln "implements ParameterPackagePort" --include=*.java .` + `git show --stat b9769b2a` | **W1-03 更新口径**：应命中 `service/port/m03/ParameterPackagePortImpl.java`（`b9769b2a` 已落）。Batch 05 时该检索为 0 命中，当时登记为 R1；现 R1 已消解（§2.2）。若 work5 环境仍 0 命中，说明其坐标落后于 `b9769b2a`，按落后坐标回报 |
| D3 | `grep -n "parameter\|candidate\|apply\|effective" controller/ResCultureController.java` | 0 命中（无 HTTP 出口） |
| D4 | 分两段 `grep`：(a) `grep -roh "FutureFabErrorCode\.[A-Z_0-9]*" service/impl/application/m03/ \| sort \| uniq -c`；(b) `grep -n "ACTION_NOT_SUPPORTED\|APPROVAL_CONTEXT_UNAVAILABLE" service/port/m03/ParameterPackagePortImpl.java` | **W1-03 更新口径（复核于 HEAD `0d5dc91e`）**：(a) 段计数与 §2.4 表一致，且 `ACTION_NOT_SUPPORTED/CONTENT_INVALID/SCHEMA_UNSUPPORTED/SOURCE_VERSION_CONFLICT/APPROVAL_CONTEXT_UNAVAILABLE` 在该目录 **0 抛出点**；(b) 段在 Port 层命中 5 行——`:871` `issue("approvalContext", APPROVAL_CONTEXT_UNAVAILABLE, "政策要求提交审批单，但 M06 API10 submitApproval 提供方本批未接入…未建审批单、未伪造 approvalId")`、`:875` `issue("outcome", ACTION_NOT_SUPPORTED, "本批不做 APPLY…生效只能由 M03-P02 决定；DIRECT/DIRECT_REASON 档位本批不写豁免 policyEvidence 与 application 回执")`（P01 固化成功时也会带的**问题项**，不是异常），以及 `:955/:963/:974` 三处 `throw reject(ACTION_NOT_SUPPORTED, …)`（P02/P03/P04 未接线）。结论：这五个码只存在于 Port 内部，与「培养页写口是 LEGACY `toAjax`、外壳无 `errorCode`」并不冲突（§2.4）；前端不得据此声称页面能收到它们 |
| D5 | `grep -c "BLOCKED_M0[467]" FutureFabErrorCode.java` | 0（登记词非错误码） |
| D6 | `npx vitest run tests/m03-culture-candidate-entry.test.ts tests/culture-management.test.ts tests/localization.test.ts` | 前两文件全绿；localization 的红必须仍不含 culture（V7 同口径） |
| D7 | `git status --short` 与 §3 清单比对 | 除 §3 七个文件外，无 work1 新增/修改 |

### 6.5 work5 不得做的事

- 不得因本批交付 MD 就出具「M03 参数候选功能通过」结论；本批可宣称项见 §10。
- 不得为让候选入口「出现」而要求 work1 补壳页面或假按钮（§2.2 根因未解即建页 = 误导实现）。**W1-03 只补了只读说明块，没有补任何操作入口**；说明块不得被改造成「按钮 + 假成功提示」。
- 不得通过 SQL 直插 `res_culture_parameter_{snapshot,state,application}` 造数来测页面：端口无 HTTP 出口时前端无读取链路，插入口径与业务事务不等价。
- 不得放宽后端 Port 契约、不得要求新增通用「应用任意模板」HTTP 接口来迁就前端（契约明文禁止）。
- 不得把 §5 的静态/编译结果当作 HTTP_VERIFIED 或 BROWSER_VERIFIED。

## 7. NO_UI / BLOCKED_MENU / BACKEND_NOT_VERIFIED 项

| ID | 事项 | 类别 | 处置 |
| --- | --- | --- | --- |
| N1 | 参数候选快照申请/应用/回执/生效包读取的**页面与操作区域** | **NO_UI** | 依 §2.1/§2.2 证据判定，不建页面、不放按钮；W1-03 只挂载了只读说明块（§4.4），说明块不是入口 |
| N2 | M03-P01—P04 的 SDK 请求封装 | **NO_UI（接口面不存在）** | 无真实 URL，禁止虚构封装；`m03-parameter-entry.ts` 零 import 即为该约束的实现证据 |
| N3 | M03 审批生效承载（`审批` 关键字 0 视图、`approval` 0 SDK 模块） | **NO_UI** | 与 M06 批口径一致 |
| N4 | 菜单/权限入口是否真实可达 | **BLOCKED_MENU** | 基线无 `sys_menu` 插入，只能真实环境核（A1/A2） |
| B1 | `ACTION_NOT_SUPPORTED/CONTENT_INVALID/SCHEMA_UNSUPPORTED/SOURCE_VERSION_CONFLICT/APPROVAL_CONTEXT_UNAVAILABLE/REQUEST_CONFLICT/MANAGEMENT_CONFLICT` 在 M03 链路的可达性 | **BACKEND_NOT_VERIFIED** | 仅登记文案；未 HTTP 复现（D4 可复核 0 抛出点） |
| B2 | 写口（新增/修改/删除/退出）响应是否带 `errorCode` 外壳 | **BACKEND_NOT_VERIFIED** | 现走 LEGACY `toAjax`，本批映射在写口上可能不命中而回落 msg |
| B3 | 「P01 最小接线已本地提交待复测/push」与 work1 可见坐标的差异 | **已由 `b9769b2a` 消解**（原 R1 坐标差） | Batch 05 时主副本与链接工作树均无 Provider；2026-10-06 复核时 `b9769b2a` 已在 HEAD，含 `ParameterPackagePortImpl`（+977）与 `M03ParameterCandidateP01ContractTest`（+983）。后端契约测试是否真绿属 work5/后端批 |
| R1 | 参数候选 **HTTP 出口**缺失（Provider 已有，Controller 零命中；前端任何提示都无法端到端验证） | 阻塞（后端契约缺口） | 转总控/后端批；本批不动后端，也不为「让提示可端到端」而虚构 URL |
| R2 | CU-R02/R03/R04 三个**已接线只读**候选口无前端承载 | 范围裁决 | 若总控要「候选只读展示」，这是唯一现有出口；建议另立批次评估 |
| R3 | 培养页写口仍是 LEGACY 无守卫 POST/PUT/DELETE/exit，6 个 `@ManagementGuardedWrite` 契约写口无调用方 | 跨批缺口 | 属仓内「缺 revision 短路」同一失效类，待总控排守卫写接线批次（本批不越界改请求链） |
| R4 | `SmpDialog` 不透传 `data-*`，弹窗按钮无法挂 testid | 测试辅助缺口 | 需 SDK 批次改 `sdk-smp-common`，本批不越界 |
| R5 | 全量 vitest 28 条红 + 本包 `build` 曾因 M09 在途文件失败一次 | 共享工作副本噪声 | 归属已证（V6/V7、§5 留痕）；work5 复测前先确认在途收敛 |
| R6 | `biome`↔`prettier` 口径冲突未裁决 | 工具链遗留 | 本批只对自己新建的两个文件跑 `prettier --check`（V16），未整文件重排他人风格区 |
| R7 | 项目页是否也应挂参数候选提示（总控目标写的是「项目/培养参数/候选快照页面」） | 范围裁决（待总控） | work1 依 `saveParameterCandidate` 无 `projectId` 入参，判定**只挂培养页**（§4.4），并已用测试钉住该决策；若总控裁决要挂项目页，改 `m03-culture-candidate-entry.test.ts` 的「项目页未挂该提示」一例并复用同一数据源即可 |

## 8. 测试数据建议

- 本批**不需要**新的 M03 主数据：改动只涉及提示与锚点，用现有培养行即可完成 B1—B7。
- 错误提示构造建议（只走界面/请求参数，不写库）：
  - `INPUT_INVALID`：非法 `pageSize`（非 10/20/50/100）或 `pageNum<1`、日期区间起 > 止（`M03ListQuerySupport:59/78/118`）。
  - `NOT_FOUND`：已删除的 cultureId（`M03ListQuerySupport:206`）。
  - `PERMISSION_DENIED`：换无 `resource:culture:*` 的账号（注意 403 也可能由注解层直接产出，非应用服务码）。
  - 其余码（`VERSION_CONFLICT` 等）当前**无法从本页构造**（§2.3 写口未接线），不要为此手工改库。
- **禁止**手工 INSERT/UPDATE `res_culture_parameter_*` 或 `run_*` 造候选数据：没有 Provider 与读取链路，插库只能造出「页面读不到的行」，会诱导出不成立结论。
- 单位/精度：本批不涉及数值展示，无单位口径风险。

## 9. work5 测试记录区

（由 work5 回填；work1 不预填任何结果。）

| 用例 | 执行日期 | 环境 | 结果（PASS/FAIL/BLOCKED） | 证据（截图/Network 记录/命令输出） | 备注 |
| --- | --- | --- | --- | --- | --- |
| A1—A4 |  |  |  |  |  |
| B1—B7 |  |  |  |  |  |
| C1—C7 |  |  |  |  |  |
| E1—E7 |  |  |  |  |  |
| D1—D7 |  |  |  |  |  |

## 10. 最终结论区（由总控/work5 回填，work1 不自行判完成）

**work1 本批可以宣称完成的事项（仅此五项）**：

1. M03 项目/培养/参数/候选快照/审批生效的前端承载面盘点已完成并有检索证据（§2.1、§2.3），参数候选快照与审批生效子域结论为 **NO_UI**，菜单可达性为 **BLOCKED_MENU**。
2. API 封装盘点已完成，且明确**未新增**任何请求封装：M03-P01—P04 无 HTTP 出口（§2.2；P01 的 Provider 自 `b9769b2a` 起存在但只能被后端内部调用），前端封装即虚构 URL。
3. 培养页错误码可读化已实现并通过编译与单元层验证（§4.1、§5 V1—V5），14 个 `data-testid` 已挂载，业务逻辑与请求序列零变更（V6 回归对照：通过数增加、失败数不变）。
4. 「不伪造」口径已交付并被测试钉住：不调用 P02/P03/P04、不做 APPLY、不显示已生效/已应用/审批已创建、BLOCKED_* 登记词不建映射、不硬编码 revision（§4.2、§6.3 C5/C6）。
5. **W1-03：参数候选入口只读说明块已按口径挂载**（§4.4）——P01 记为「仅内部接线、无对外接口」，P02/P03/P04 记为「未接线（ACTION_NOT_SUPPORTED）」，四行带 `culture-parameter-p01..p04` 定位属性；cn/en 各 9 键对称（V15）；模块零 import 故不产生请求（V14/E7）；`vitest` 22 例含本批 7 例全绿（V11），三条必跑命令与本包构建均 exit=0（V12/V13）。层级仍是**编译 + 契约测试**，不是浏览器验收。

**work1 明确不得被宣称的事项**：

- 不得写「参数候选快照入口已上线」「候选状态展示已完成」「DIRECT/APPROVAL 已按契约展示」——只有只读说明块，无任何操作入口。
- 不得写「错误码可读化已端到端验证」——只到类型检查/构建/vitest 层，无 HTTP 与浏览器证据（AGENTS.md §13.2、§13.7）。
- 不得写「写口失败提示已全部可读」——新增/修改/删除/退出仍走 LEGACY 口，`errorCode` 外壳是否出现未验证（B2）。
- 不得写「M03-P01 已联调」或「P01 能力可被前端消费」——Provider 存在但 HTTP 出口为 0（B3/R1）；也不得反向写「P01 未实现」，该说法已被 `b9769b2a` 推翻。
- 不得把说明块的渲染（V14 产物抽查）当作 E1—E6 的浏览器验收证据。
- 不得把 §5 的静态与编译结果当作 SQL 执行、HTTP 可达或现场验收。

**待总控裁决**：R1（候选 HTTP 出口缺口，是否推进后端接线）、R2（是否用 CU-R02/R03/R04 现有只读口另立「候选只读展示」前端批次）、R3（培养页写口切契约守卫写 + 缺 revision 短路的批次归属）、R4（`SmpDialog` 是否开放 `data-*` 透传）、R5（M09 在途编译红的收敛窗口，影响 work5 能否稳定复跑本包构建）、R7（项目页是否也挂候选提示；work1 依 P01 入参无 `projectId` 判定不挂）。这六项未解前，M03 参数候选快照的前端操作型批次不应开工。
