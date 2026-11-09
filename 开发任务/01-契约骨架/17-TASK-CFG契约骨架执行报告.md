# 17-TASK-CFG 契约骨架执行报告

> 版本：TASK-CFG／2026-09-19／分支 cloud。基线：PKG-00（03 报告）+ PKG-01（04 报告）+ PRE-01A/B/C（06—09 报告）+ TASK-SECURITY-P0-R1（11 报告）+ TASK-COMMON（12 报告）+ TASK-USR（13 报告）。
> 任务书：TASK-CFG 参数配置 5 条接口契约骨架接线（M01-067—M01-071，全部 ADJUST）。
> Git 状态：未提交（按任务书要求，不执行任何 git 提交/推送）。

## 一、是否完成

**完成（骨架层级）5/5。** 五条接口全部达到
`Controller → 冻结 Query/Command → ConfigApplicationService → 显式 SkeletonNotImplementedException("M01-nnn") → HTTP 501`
形态。未实现任何真实配置查询、写入、缓存刷新或业务 SQL（本任务边界内不作为缺陷）。
M01-070 的 `system:config:query` 权限与 TASK-SECURITY-P0-R1 敏感值 fail-closed 语义保持，
BLK-04b（通用敏感键注册表）与 BLK-04c（M07 值域注册）均未实现、未发明清单。

## 二、5 条接口逐条结果

| 编号 | canonical 路由 | 权限注解 | Request | Response | Controller 出口 | 骨架状态 |
| --- | --- | --- | --- | --- | --- | --- |
| M01-067 | GET /system/config/list | `system:config:list` | `ConfigPageQuery` | `PageResult<ConfigRow>` | `SysConfigController#list(ConfigPageQuery)` → `listConfigs` | 501 明确未实现 |
| M01-068 | POST /system/config | `system:config:add` | `ConfigCreateCommand` | `MutationResult` | `#add(@RequestBody ConfigCreateCommand)` → `createConfig` | 501 明确未实现 |
| M01-069 | PUT /system/config | `system:config:edit` | `ConfigUpdateCommand` | `MutationResult` | `#edit(@RequestBody ConfigUpdateCommand)` → `updateConfig` | 501 明确未实现 |
| M01-070 | GET /system/config/{configId} | `system:config:query`（保持，不新增超管限制） | `ConfigDetailQuery` | `ConfigDetailView` | `#getInfo(@PathVariable String configId)` → `getConfigDetail` | 501 明确未实现 |
| M01-071 | DELETE /system/config/{configIds} | `system:config:remove` | `ConfigDeleteCommand` | `DeleteResult` | `#remove(@PathVariable String configIds)` → `deleteConfigs` | 501 明确未实现 |

控制器模块内映射保持 `/config` 前缀（网关补 `/system`）；HTTP 动词与 canonical 一致。

**冻结外壳差异登记**：00 机器清单 CFG05 的 `response_vo` 为 `DeleteResult`，接口目录/详细设计 §21 CFG05 文字描述为
`data W`（MutationResult 形态）。按任务书“以 00 清单与 PKG-00 公共契约为准、按冻结清单执行”，本次采用
`DeleteResult`（PKG-00 冻结字段 requestId/managementRevision/removedIds，其 javadoc 明确“领域设计已声明专用
*DeleteResult 时以专用类型为准”）。差异只登记不自行折中，需接口目录侧一次性确认（同 13 报告 §十九.4 的 053 裁定性质）。

## 三、DTO / View 契约（全部非 Entity，外部 ID 一律 String）

新增 DTO（`domain/dto/m01`，5 个）：

- `ConfigPageQuery`{pageNum:Integer=1, pageSize:Integer=10, keyword:String, beginDate:LocalDate, endDate:LocalDate, configType:String}
  ——§17 公共 Q+F 逐字段展开 + CFG01 的 `configType` 可选 Y/N；不继承 SysConfig，不含 params/searchValue/createBy/updateBy/delFlag。
- `ConfigCreateCommand`{configName, configKey, configValue, remark, requestId, managementRevision}
  ——ConfigSave 冻结字段全集；**不含 configId 与 configType**（configType 由服务端决定，自定义新增固定 N）。
- `ConfigUpdateCommand`{configId:String, configName, configKey, configValue, remark, requestId, managementRevision}
  ——ConfigSave + configId 必填；configKey 随 Body 携带但 PUT 不可改键（实现阶段按只读字段拒绝）。
- `ConfigDetailQuery`{configId:String}（§17.1 十进制字符串，避免 JS 大整数损失）。
- `ConfigDeleteCommand`{configIds:List\<String\>, requestId, managementRevision}——Path 逗号 ID 仅基本拆分绑定。

新增/补齐 View（`domain/vo/m01`）：

- `ConfigRow`（新建）：§17.2 全字段 configId/configName/configKey/configValue/configured/sensitive/configType/remark/audit:AuditView/allowedActions:List\<String\>；`allowedActions` null 安全归一空数组；不继承 `SysConfig`。
- `ConfigDetailView`（既有，最小补齐）：新增 §17.2 ConfigRow 契约字段位 `allowedActions:List<String>`（骨架返回空数组，取值属按钮策略业务规则），javadoc 收敛为“CFG04 冻结输出 data ConfigRow 的 View 形态”。
  **fail-closed 口径逐字保持**：`from(SysConfig)` 仍为唯一公共工厂，BLK-04b 未裁决前 `configValue` 恒 null、`sensitive=true`（“敏感或未分类”）、`configured` 真实；
  `from(SysConfig, boolean)` 的 false 回显通道保持包内私有，本次未放大为公共入口（有反射断言）。

审计结构复用既有 `AuditView`/`AuditViews`，未创建第二套。

## 四、ApplicationService 分包与方法

- 接口 `service/application/m01/ConfigApplicationService`（新建，恰 5 方法）：
  `listConfigs` / `createConfig` / `updateConfig` / `getConfigDetail` / `deleteConfigs`。
- 实现 `service/impl/application/m01/ConfigApplicationServiceImpl`（新建，`@Service`）：
  **声明字段数 = 0**（无 @Autowired、无协作者、无状态），每个方法体仅一条语句
  `throw new SkeletonNotImplementedException("M01-067..071")`，编号逐接口精确；null 入参同样抛 501。
- 未新建第二个配置服务端口；复用唯一 `SkeletonNotImplementedException`（common-core），未建平行异常/响应体系。

## 五、显式 501 与旧 Service / Mapper / Redis / 守卫边界

1. **旧 Service**：五条骨架入口方法体源码取证禁列 `configService`、`selectConfigById`、`selectConfigList`、
   `insertConfig`、`updateConfig(config`、`checkConfigKeyUnique`、`deleteConfigByIds`、`resetConfigCache`；
   Controller 已不再引用 `SecurityUtils`/`TableDataInfo`/`Validated`/`ConfigDetailView`。
   `configService` 字段仍保留，仅服务于未登记旧路由（export/configKey/refreshCache）。
2. **Mapper/XML/SQL**：零新增、零修改（改动清单内 0 个 mapper 文件、0 个 XML、0 行 SQL）。
3. **Redis/缓存**：骨架入口不读写参数缓存、不调用 `resetConfigCache`；501 在任何外部副作用之前抛出。
4. **守卫与幂等**：未接 `ManagementGuardExecutor`、不做 CAS/版本/幂等回执、不写 `sys_management_request`；
   068/069/071 仅以 Command 体字段预留 `requestId/managementRevision`（WriteMeta 契约位，ADJUST 入口不接请求头装配，
   与 12/13 报告同口径）；067/070 读接口 Query **不含** WriteMeta（测试双向断言）。
5. **@Log**：五条骨架入口不挂 `@Log`——`LogAspect` 会在 501 响应时仍写 `sys_oper_log`，与“501 前无 DB/日志副作用”门禁冲突
   （沿用 TASK-COMMON §七.1、TASK-USR §四.4 裁定）；随业务实现阶段评估恢复。非范围内旧路由的 `@Log` 原样保留。
6. **未实现的业务规则**（骨架禁止清单）：受保护键校验、键唯一性、删除限制（内置/已引用/敏感保留键 REFERENCE_EXISTS）、
   configType 服务端决定、缓存刷新、真实 CRUD、`allowedActions` 计算、分页与数据范围、时间左闭右开范围校验。
7. **BLK-04b/BLK-04c**：均未实现。未新增敏感键清单/注册表/分类服务，未新增 M07 业务参数值域注册，未把
   “未登记”当作“非敏感”；四道防线由 `ConfigDetailView` fail-closed + 反射断言 + View JSON 断言锁定。

## 六、Controller → ApplicationService 映射与旧编排移除

| 入口 | 协作者 | 移除的旧编排 |
| --- | --- | --- |
| `list` | `configApplicationService.listConfigs` | `startPage()` + `configService.selectConfigList(SysConfig)` + `getDataTable` |
| `getInfo(String)` | `configApplicationService.getConfigDetail` | `configService.selectConfigById(Long)` + Controller 内 `ConfigDetailView.from` 出口映射（映射职责回落 View 的 `from`，实现阶段由服务调用） |
| `add` | `configApplicationService.createConfig` | `checkConfigKeyUnique` + `setCreateBy(SecurityUtils…)` + `insertConfig` |
| `edit` | `configApplicationService.updateConfig` | `checkConfigKeyUnique` + `setUpdateBy` + `updateConfig` |
| `remove` | `configApplicationService.deleteConfigs` | `Long[]` 拆分 + `deleteConfigByIds`（级联/缓存清理） |

070 的 `configId` 由 `Long` 改为 `String`（§17.1 外部 ID 契约化，与 049/057 同法）；旧路由
`POST /config/export`、`GET /config/configKey/{configKey}`、`DELETE /config/refreshCache` **逐字保持原状**（未登记旧路由处置归 TASK-ROUTE）。

## 七、文件清单

**新增（main，8）**：`domain/dto/m01/{ConfigPageQuery,ConfigCreateCommand,ConfigUpdateCommand,ConfigDetailQuery,ConfigDeleteCommand}.java`、
`domain/vo/m01/ConfigRow.java`、`service/application/m01/ConfigApplicationService.java`、
`service/impl/application/m01/ConfigApplicationServiceImpl.java`。

**修改（main，2）**：`controller/SysConfigController.java`（5 条入口接线 + 类 javadoc）、
`domain/vo/m01/ConfigDetailView.java`（补 `allowedActions` 契约字段位与 javadoc，fail-closed 逻辑未改）。

**测试（2）**：新增 `src/test/java/com/futurefab/system/contract/M01ConfigSkeletonContractTest.java`（19 用例）；
**协调说明**：`src/test/java/com/futurefab/system/security/M01ResponseLeakGuardTest.java` 的 **M01-070 段（仅该段 3 处）** 做同步适配——
该文件的 070 断言原本通过反射取 `getInfo(Long)` 并调用旧出口映射，签名契约化（`Long→String`）后同类无法编译，
会阻塞整个 system 测试源集。适配后语义**不降级**：新增“入口显式 501 且旧 `selectConfigById` 一旦被触达即 AssertionError 失败”断言，
并把原方案 A 白名单 JSON 断言（`configValue` 不回显、`sensitive=true`、`configured` 真实、`configId` 字符串）
改为对冻结 `ConfigDetailView.from(...)` 序列化结果断言；`configDetailRequiresFrozenPermission` 仅改参数类型，
注解值断言不变。同类的 049/055/075/大整数/时区/null 段与其他任务文件未触碰。此文件在任务书允许清单之外，
特此显式登记为跨任务共享回归夹具的必要适配。

**文档**：本报告。未修改 `docs/开发任务/10-全接口契约骨架覆盖审计.md/.json`（见 §十一）。

## 八、测试内容（M01ConfigSkeletonContractTest，19 用例）

1. 5 条路由 + HTTP 动词 + 参数类型反射契约；2. 5 条冻结权限注解（070 恰 `system:config:query`）；
3. 5 条骨架入口无 `@Log`、旧路由 `@Log` 保留；4. 方法体源码取证只调 `configApplicationService.*` 且禁列旧协作者；
5. 未登记旧路由（export/configKey/refreshCache）实现原样 + `selectConfigById` 已从控制器消失；
6. AppService 5 方法逐编号 501；7. Controller/服务 null 入参统一 501；8. 实现零字段 + 接口恰 5 方法 + 无嵌套结果结构；
9. MockMvc 5 条路由 501 外壳（`code=501`、`errorCode=NOT_IMPLEMENTED`、`contractId`、`requestId` 为字符串、无 `data`/`rows`/`total`/`removedIds`）——无伪成功；
10. 070 HTTP 响应体不含配置原文与 `configValue`；11. 071 逗号拆分绑定与 null 集合归一；
12. 5 个 DTO 字段全集 = 冻结契约；13. Body 禁止 `configType/configId@068/createBy/updateBy/delFlag/params/searchValue/password/token`；
14. 写 Command 预留 WriteMeta、读 Query 无 WriteMeta；15. 外部 ID String / 日期 LocalDate / pageNum Integer 类型断言；
16. `ConfigRow`+`ConfigDetailView` 字段全集、无内部字段、不继承 `SysConfig`、集合非 null；
17. `ConfigDetailView.from(config)` 仍 fail-closed（JSON 无原文、`configValue:null`、`allowedActions:[]`、`configId:"3"`）；
18. 原值回显通道 `from(config,false)` 仍非公共 + 公共工厂唯一 + `ConfigRow` JSON 不含原文；
19. TASK-COMMON/TASK-USR 入口无回归（048 绑定与权限、075 无注解、`UserApplicationService` 恰 8 方法、异常体系唯一）+ 审计结构复用 `AuditView`。

## 九、验证结果（分层记录）

| 层级 | 结果 |
| --- | --- |
| 静态检查（git diff 通读 + import/签名/注解一致性核对） | **通过** |
| `git diff --check` | **通过**（退出码 0，无空白错误） |
| 5 个编号逐项扫描 | 5/5 均存在精确 `SkeletonNotImplementedException("M01-067..071")` |
| 编译（`mvn -pl futurefab-modules/futurefab-system -am -DskipTests compile`） | **未运行**（任务书 §六 协调约束：四包并行期间禁止 Maven，由协调者统一时段执行） |
| 单元/契约测试（`mvn -pl futurefab-modules/futurefab-system -am test`，含 SECURITY-P0-R1 / COMMON / USR / PRE-01A/B 回归） | **未运行**，待统一时段 |
| SQL 执行、服务启动、网关/JWT、HTTP-浏览器联调、外部系统 | **未执行** |

因此本报告只宣称到“静态检查通过”层级，**不宣称编译或通过测试通过**，待协调者统一时段回填实测结果后方可升级。
静态自查已重点核对的编译风险：新 DTO/View 与被测类型同名同包、`ConfigDetailView` 新增 `List/ArrayList` import、
控制器移除 `TableDataInfo/SecurityUtils/Validated/ConfigDetailView` 未用 import 并新增 `ArrayList` import、
`M01ResponseLeakGuardTest` 使用已存在的 `Function/Map/SkeletonNotImplementedException/assertThrows` import、
新测试仅引用已完成任务的公开类型（`SysUserController`、`UserPageQuery`、`UserApplicationService`、`AuditView`）。

## 十、阻塞与挂账项（非骨架缺口）

1. **BLK-04b**（敏感键权威分类：注册表或 sys_config 敏感性列）未冻结 → 067/070 普通配置值回显继续 fail-closed 挂起，
   前端表单原值为空属预期保守代价；落地接线位为 `ConfigDetailView.from(config, false)` 与 `ConfigRow.configValue` 赋值点。
2. **BLK-04c**（补糖轮询等 M07 业务参数值域注册）未冻结 → 069 实现阶段前 M01 不猜阈值。
3. 业务键注册规则（新增键是否允许）、受保护键→专用服务转办（密码四政策键走 API09）、`REFERENCE_EXISTS` 删除限制、
   缓存失效与 `sys_management_revision` 记账、`allowedActions` 计算、分页/数据范围与时间范围校验 → 业务实现阶段。
4. 071 外壳 `DeleteResult` 与目录文字 `data W` 的差异需接口目录侧一次性确认（§二）。
5. 前端 `futurefab-ui/src/api/system/config.js` 与 `views/system/config/index.vue` 仍按旧契约（Entity 平铺、`configValue` 原值、
   `refreshCache`/`configKey` 旧路由）调用，需后续联调阶段适配（本任务未改 Vue）。
6. 46 条未登记旧路由与 `configKey` 取值口的敏感透传风险处置归 TASK-ROUTE（本任务只保持原状，不扩大范围）。

## 十一、边界确认

- 未修改 `docs/开发任务/10-全接口契约骨架覆盖审计.md/.json` 与 05—13 号报告（只读）；10 审计统计未由本任务刷新，
  5 条记录状态更新请由协调者在统一收口时按程序化实算处理，避免与并行写者冲突。
- 未触碰仓库根 `_tmp_*` 文件（其他审计会话产物）。
- 未修改 SysVenue/SysDept/SysGroup/SysMenu/SysRole/SysDictType/SysDictData/SysUser 控制器及其 DTO/View/ApplicationService/测试；
  未修改 Mapper、Mapper XML、SQL、Redis、Vue、开发基线、客户只读材料。
- 未执行 `git commit`/`git push`/创建 PR；未执行 `checkout`/`reset`/`stash`/清理他人变更。
- 唯一清单外文件改动为 §七 登记的 `M01ResponseLeakGuardTest` 070 段必要适配（编译阻塞所致，语义不降级）。

## 十二、结论

**5/5 完成**：M01-067—071 已达冻结契约骨架形态并显式 501；M01-070 权限 `system:config:query` 与 TASK-SECURITY-P0-R1
fail-closed 敏感值口径保持且由测试锁定；BLK-04b/BLK-04c 未实现；无真实配置 CRUD、无缓存刷新、无 SQL；
编译与测试结果待协调者统一 Maven 时段回填（当前仅静态检查通过）。
