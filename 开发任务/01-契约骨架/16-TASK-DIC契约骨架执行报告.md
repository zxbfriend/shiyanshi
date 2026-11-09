# 16-TASK-DIC 契约骨架执行报告

> 版本：TASK-DIC／2026-09-19／分支 cloud。基线：PKG-00（03 报告）+ PKG-01（04 报告）+ PRE-01A/B/C（06—09 报告）
> + TASK-SECURITY-P0-R1（11 报告）+ TASK-COMMON（12 报告）+ TASK-USR（13 报告）。
> 任务书：TASK-DIC 数据字典 9 条接口契约骨架接线（M01-058—M01-066，全部 ADJUST；DIC01—DIC09）。
> Git 状态：未提交（按任务书要求，不执行任何 git 提交/推送）。

## 一、是否完成

**完成（骨架层级）9/9。** 九条接口全部达到
`Controller → 冻结 Query/Command → DictType/DictDataApplicationService → 显式 SkeletonNotImplementedException("M01-0nn") → HTTP 501`
形态。未实现任何真实字典查询、写入、层级推导、缓存刷新或业务 SQL（本任务边界内不作为缺陷）。

关键不变量：

- **M01-066 权限口径保持**：未新增权限字符串、未降级为公开访问（专节见 §五.6）。
- **BLK-03（跨模块字典引用检查 / `DICT_KEY_IN_USE`）保持阻塞**：未发明 Port 签名、未留可用实现。
- **无字典缓存读写、无 SQL、无 Mapper 接触**：旧 `DictUtils`/`selectDictDataByType` 缓存链路未进入任何骨架入口。
- 非范围内旧路由（`export`/`check*`/`remove`/`refreshCache`/`optionselect`/`/type/{dictType}`/
  `/type/{dictType}/children/{parentValue}`）**逐字保持原状**。

## 二、9 条接口逐条结果

| 编号 | 契约号 | canonical 路由 | 权限注解 | Request | Response | Controller 出口 | 骨架状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| M01-058 | DIC01 | GET /system/dict/type/list | `system:dict:list` | `DictTypePageQuery` | `PageResult<DictTypeRow>` | `SysDictTypeController#list` → `pageDictTypes` | 501 明确未实现 |
| M01-059 | DIC02 | POST /system/dict/type | `system:dict:add` | `DictTypeCreateCommand` | `MutationResult` | `#add(@RequestBody …)` → `createDictType` | 501 明确未实现 |
| M01-060 | DIC03 | PUT /system/dict/type | `system:dict:edit` | `DictTypeUpdateCommand` | `MutationResult` | `#edit(@RequestBody …)` → `updateDictType` | 501 明确未实现 |
| M01-061 | DIC04 | GET /system/dict/type/{dictId} | `system:dict:query` | `DictTypeDetailQuery` | `DictTypeDetailView` | `#getInfo(@PathVariable String dictId)` → `getDictTypeDetail` | 501 明确未实现 |
| M01-062 | DIC05 | GET /system/dict/data/list | `system:dict:list` | `DictDataPageQuery` | `PageResult<DictDataRow>` | `SysDictDataController#list` → `pageDictDatas` | 501 明确未实现 |
| M01-063 | DIC06 | POST /system/dict/data | `system:dict:add` | `DictDataCreateCommand` | `MutationResult` | `#add(@RequestBody …)` → `createDictData` | 501 明确未实现 |
| M01-064 | DIC07 | PUT /system/dict/data | `system:dict:edit` | `DictDataUpdateCommand` | `MutationResult` | `#edit(@RequestBody …)` → `updateDictData` | 501 明确未实现 |
| M01-065 | DIC08 | GET /system/dict/data/{dictCode} | `system:dict:query` | `DictDataDetailQuery` | `DictDataDetailView` | `#getInfo(@PathVariable String dictCode)` → `getDictDataDetail` | 501 明确未实现 |
| M01-066 | DIC09 | GET /system/dict/data/type/{dictType}/tree | 无注解（已认证，见 §五.6） | `DictDataTreeQuery` | `List<DictOptionView>` | `#dictTypeTree(@PathVariable String dictType, DictDataTreeQuery query)` → `dictTypeTree` | 501 明确未实现 |

控制器模块内映射保持 `/dict/type`、`/dict/data` 前缀（网关 `StripPrefix=1` 去掉 `/system`）；HTTP 动词与 canonical 一致。
`dictTypeTree` 沿用 TASK-ORG 的 `listUsers(@PathVariable … , DeptUserQuery query)` 装配惯例：Path 值为权威，控制器覆盖 Query
同名字段后再转发应用端口。

**冻结外壳差异登记**：逐条比对 00 机器清单（`interface_id`/`contract_id`/`permission`/`request_dto`/`response_vo`）与任务书
下发的冻结契约表，**九条完全一致，无出入**（含 066 的 `DictDataTreeQuery → List<DictOptionView>` 与 059/060/063/064 的
`MutationResult`）。响应外壳沿用 PKG-00/PRE-01A 既有实现（`AjaxResult` + `code/msg/requestId/managementRevision`，
分页体由 `PageResult` 承载 `rows/total/pageNum/pageSize`），未新建第二套外壳，故无 §二 层面的折中项（对比 17 报告 CFG05
`DeleteResult` 与目录文字差异那类问题，本包不存在）。10 审计对 066 的登记为「无注解 + permissionVerdict ABSENT」，
与本实现一致。

## 三、DTO / View 契约（全部非 Entity，外部 ID 一律 String）

新增 DTO（`domain/dto/m01`，9 个）：

- `DictTypePageQuery`{pageNum:Integer=1, pageSize:Integer=10, keyword:String, beginDate:LocalDate, endDate:LocalDate, status:String}
  ——§17.1 公共 Q+F 逐字段展开 + DIC01 的 `status` 可选 0/1；不含 `params[beginTime/endTime]`、`searchValue`、`createBy/updateBy/delFlag`。
- `DictTypeCreateCommand`{dictName, dictType, status, remark, requestId, managementRevision}——DictTypeSave 冻结字段全集；
  **不含 dictId**（新增不接受）、**不含 isEditable**（服务端固定写 Y）。
- `DictTypeUpdateCommand`{dictId:String, dictName, dictType, status, remark, requestId, managementRevision}——DictTypeSave + dictId。
- `DictTypeDetailQuery`{dictId:String}（§17.1 十进制字符串，避免 JS 大整数损失）。
- `DictDataPageQuery`{pageNum:Integer=1, pageSize:Integer=10, dictType, keyword, parentCode:String, parentKeyword, status}
  ——DIC05 只声明 Q，**不声明 F**（§21 该接口输入无 beginDate/endDate），无 `searchKey`/`parentValue` 自由键。
- `DictDataCreateCommand`{dictType, parentCode:String, dictLabel, dictValue, dictSort:Integer, status, requestId, managementRevision}
  ——DictDataSave 冻结字段；**isDefault 不入 Body**（本期不开放运行期设置入口，提交即按未知字段拒绝），
  `dictLevel`（后端推导）、`isEditable`（服务端判定）、`dictCode`（数据库生成）均不进入。
- `DictDataUpdateCommand`{dictCode:String, 同上 + requestId, managementRevision}——DictDataSave + dictCode；同样不含 isDefault/dictLevel。
- `DictDataDetailQuery`{dictCode:String}。
- `DictDataTreeQuery`{dictType:String, includeDisabled:boolean=false}——§21 DIC09：`includeDisabled` 默认 false，
  「仅编辑上下文允许 true」的判定属业务实现阶段。查询型，不携带 WriteMeta。

新增 View（`domain/vo/m01`，5 个）：

- `DictTypeRow`：§17.2 全字段 dictId/dictName/dictType/status/isEditable:String("Y"/"N")/remark/audit:AuditView/
  allowedActions:List\<String\>（null 安全归一空数组）；不继承 `SysDictType`。
- `DictTypeDetailView`：按 §17.2「DTO 继承指包含对应行全部展开字段」以**独立类全展开** DictTypeRow 字段
  （沿用 `ConfigDetailView`/`UserDetailView` 先例，不用继承，避免 View 间耦合）。
- `DictDataRow`：§17.2 全字段 dictCode/dictType/dictLabel/dictValue/parentCode:String(根 "0")/parentLabel/
  dictLevel:Integer/dictSort:Integer/status/isEditable/isDefault/audit/allowedActions；不继承 `SysDictData`，
  不含旧连表自由列 `parentValue`。
- `DictDataDetailView`：同上全展开（独立类）。
- `DictOptionView`：§21「DictOption 完整字段」7 项 id(=dictCode)/value(=dictValue)/label/parentCode/level:Integer/
  disabled:boolean/children:List\<DictOptionView\>（叶子返回空数组，不返回 null）；不引用旧内部类 `SysDictDataNode`。
  注：§17.2 通用 `Option` 的 `disabledReason` 未纳入——066 冻结输出为 §21 明确列举的 DictOption 形态。

审计结构复用既有 `AuditView`/`AuditViews`，未创建第二套。

## 四、ApplicationService 分包与方法

- 接口 `service/application/m01/DictTypeApplicationService`（新建，恰 4 方法）：
  `pageDictTypes` / `createDictType` / `updateDictType` / `getDictTypeDetail`。
- 接口 `service/application/m01/DictDataApplicationService`（新建，恰 5 方法）：
  `pageDictDatas` / `createDictData` / `updateDictData` / `getDictDataDetail` / `dictTypeTree`。
- 实现 `service/impl/application/m01/DictTypeApplicationServiceImpl`、`DictDataApplicationServiceImpl`（新建，`@Service`）：
  **声明字段数 = 0**（无 @Autowired、无协作者、无状态），每个方法体仅一条语句
  `throw new SkeletonNotImplementedException("M01-058".."M01-066")`，编号逐接口精确、无 `return`、null 入参同样抛 501。
- 按任务书要求新建两个 Dict 端口（原先不存在，属本任务所有权）。未新建第二套字典服务端口；
  复用唯一 `SkeletonNotImplementedException`（common-core），未建平行异常/响应体系。
  旧 `ISysDictTypeService`/`ISysDictDataService` 与 `SysDictTypeServiceImpl` 未被本任务修改。

## 五、显式 501 与旧 Service / Mapper / Redis / 守卫边界

1. **旧 Service**：九条骨架入口方法体源码取证禁列 `dictTypeService.`、`dictDataService.`、`startPage`、`getDataTable`、
   `TableDataInfo`、`PageHelper`、`SecurityUtils`、`Validated`、`DictUtils`、`resetDictCache`、`getDictCache`、
   `selectDictTypeById/List`、`selectDictDataById/List`、`insertDictType/Data`、`deleteDictTypeByIds/DataByIds`、
   `selectDictChildren`、`checkDictValueUnique`、`ExcelUtil`、`BeanUtils`、`SysDictDataNode`、`buildDictTypeTree`、
   `buildTwoLevelSupport`。控制器仍保留 `dictTypeService`/`dictDataService` 字段，**仅**服务于未登记旧路由
   （export/check*/remove/refreshCache/optionselect/type 系列）。
2. **Mapper/XML/SQL**：零新增、零修改（改动清单内 0 个 mapper 文件、0 个 XML、0 行 SQL）；骨架端口与实现的
   可执行代码经禁止词扫描（剥离注释后）不含 `Mapper`/`SqlSession`/`jdbcTemplate`/`DataSource`。
3. **Redis/字典缓存**：骨架入口不读写 `DictUtils` 缓存、不调用 `resetDictCache`、不清理键；501 在任何外部副作用之前抛出。
   旧 `/dict/data/type/{dictType}` 运行期读取链路（走缓存）保持原状，属未登记旧路由，处置归 TASK-ROUTE。
4. **守卫与幂等**：未接 `ManagementGuardExecutor`、不做 CAS/版本/幂等回执、不写 `sys_management_request`、
   不接 `@RequestHeader`/`WriteMetaArgumentResolver` 装配；059/060/063/064 仅以 Command 体字段预留
   `requestId/managementRevision`（WriteMeta 契约位，ADJUST 入口不接请求头装配，与 12/13/17 报告同口径）；
   058/061/062/065/066 读接口 Query **不含** WriteMeta（测试双向断言）。
5. **@Log**：九条骨架入口不挂 `@Log`——`LogAspect` 会在 501 响应时仍写 `sys_oper_log`，与「501 前无 DB/日志副作用」
   门禁冲突（沿用 TASK-COMMON §七.1、TASK-USR §四.4、TASK-CFG §五.5 裁定）；随业务实现阶段评估恢复。
   非范围内旧路由（type/data 的 `export`、`remove`、`refreshCache`）的 `@Log` 与权限注解原样保留，有测试锁定。
6. **M01-066 安全口径（实际采用的现有安全机制）**：00 清单登记权限为「已认证且业务使用该字典或 system:dict:query」，
   10 审计判为 ABSENT（复合/会话型）。本实现：
   - 「已认证」由**既有**网关 `AuthFilter` 承担（`security.ignore.whites` 仅 `/auth/login`、`/auth/aad/**`，
     `/system/dict/**` 不在白名单，未登录请求在网关即被 401 拦截），因此控制器侧**保持无 `@RequiresPermissions` 注解**，
     与 10 审计的既有登记逐字一致；
   - 第二维「业务使用该字典 **或** `system:dict:query`」的 OR 复合判定需要权威「字典→业务字段/模块使用登记表」，
     该表在 05 审计中被判为「业务使用白名单无代码化落点」，契约未冻结；骨架阶段**不发明权限字符串**（如
     `system:dict:tree/option/use`）、不新增 `@Anonymous`/公开访问、不擅自要求 `system:dict:query`
     （那会把运行期下拉读取误判为无权限，属功能降级）；测试以「注解必须为空 + 源码无新权限串」双向锁定该口径。
   - 结论：066 的复合授权判定与 `includeDisabled` 的「仅编辑上下文」判定一并留待业务实现阶段（§十.2）。
7. **未实现的业务规则**（骨架禁止清单）：双唯一校验、`custom_+dictId` 编码生成、dictValue 缺省取 dictCode 十进制、
   两级层级一致性与「二级不得再有子级」、内置/基础项 isEditable=N 只读、isDefault 保留原值、软删过滤、
   `allowedActions` 计算、字典缓存重建、分页与排序、日期左闭右开范围校验、404/409 语义、`DICT_KEY_IN_USE`。
8. **BLK-03**：未实现。未新增引用检查方法、注册表或跨模块 Port 签名；两个端口代码层不含 `check*` 方法与
   `DICT_KEY_IN_USE`（注释中的规则说明不计，测试以剥离注释后的代码取证）。

## 六、Controller → ApplicationService 映射与旧编排移除

| 入口 | 协作者 | 移除的旧编排 |
| --- | --- | --- |
| `SysDictTypeController#list` | `dictTypeApplicationService.pageDictTypes` | `startPage()` + `dictTypeService.selectDictTypeList(SysDictType)` + `getDataTable`（`TableDataInfo` 外壳） |
| `#getInfo(String)` | `…getDictTypeDetail` | `dictTypeService.selectDictTypeById(Long)` 实体直出（`Long→String` 契约化，与 049/057/070 同法） |
| `#add` | `…createDictType` | `checkDictTypeUnique` + `setCreateBy(SecurityUtils…)` + `insertDictType` + `@Log` + `@Validated` |
| `#edit` | `…updateDictType` | `checkDictTypeUnique` + `setUpdateBy` + `updateDictType`（内含 `resetDictCache`）+ `@Log` + `@Validated` |
| `SysDictDataController#list` | `dictDataApplicationService.pageDictDatas` | `startPage()` + `selectDictDataList(SysDictData)` + `getDataTable` |
| `#getInfo(String)` | `…getDictDataDetail` | `selectDictDataById(Long)` 实体直出（`Long→String`） |
| `#add` | `…createDictData` | `checkDictValueUnique/checkDictLabelUnique` + `setCreateBy` + `insertDictData`（内含缓存写入）+ `@Log` |
| `#edit` | `…updateDictData` | 唯一性校验 + `setUpdateBy` + `updateDictData`（内含缓存刷新）+ `@Log` |
| `#dictTypeTree` | `…dictTypeTree` | `dictTypeService.selectDictDataByType`（DictUtils/Redis 缓存）+ 控制器本地 `buildTwoLevelSupport` 补值排序 + `buildDictTypeTree` 构树 + 内部类 `SysDictDataNode extends SysDictData`（Entity 直出） |

066 的 `SysDictDataNode` 内部类与两个私有方法**随接线一并删除**（删除后无任何引用点），未保留死代码；
控制器 import 收敛掉 `Comparator/HashMap/LinkedHashMap/Map/BeanUtils/Validated/TableDataInfo/SecurityUtils`。
非范围内旧路由逐字保持原实现：`POST /dict/type/export`、`GET /dict/type/checkDictNameUnique`、
`DELETE /dict/type/{dictIds}`、`DELETE /dict/type/refreshCache`、`GET /dict/type/optionselect`、
`POST /dict/data/export`、`GET /dict/data/checkValueUnique`、`GET /dict/data/checkLabelUnique`、
`GET /dict/data/type/{dictType}`、`GET /dict/data/type/{dictType}/children/{parentValue}`、`DELETE /dict/data/{dictCodes}`
（未登记旧路由整体处置归 TASK-ROUTE，本任务不扩大范围）。

## 七、文件清单

**新增（main，18）**：

- `domain/dto/m01/{DictTypePageQuery,DictTypeCreateCommand,DictTypeUpdateCommand,DictTypeDetailQuery,`
  `DictDataPageQuery,DictDataCreateCommand,DictDataUpdateCommand,DictDataDetailQuery,DictDataTreeQuery}.java`（9）
- `domain/vo/m01/{DictTypeRow,DictTypeDetailView,DictDataRow,DictDataDetailView,DictOptionView}.java`（5）
- `service/application/m01/{DictTypeApplicationService,DictDataApplicationService}.java`（2）
- `service/impl/application/m01/{DictTypeApplicationServiceImpl,DictDataApplicationServiceImpl}.java`（2）

**修改（main，2）**：

- `controller/SysDictTypeController.java`（058/059/060/061 接线 + 类内 javadoc；`-` import 收敛、`-` add/edit 的 `@Log`/`@Validated`）
- `controller/SysDictDataController.java`（062/063/064/065/066 接线；删除 3 个只服务于旧 066 的私有成员；
  `-` add/edit 的 `@Log`/`@Validated`）

合计 diff：2 files changed, 98 insertions(+), 160 deletions(-)。

**测试（1 新增）**：`futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/contract/M01DictSkeletonContractTest.java`
（26 用例）。**无清单外文件改动**：`M01ResponseLeakGuardTest` 与既有 COMMON/USR/CFG/ORG/ACL 契约测试均未引用 Dict
类型（已全仓 grep 核对），签名契约化不产生跨任务夹具编译阻塞，故本次无需 17 报告 §七 那类必要适配。

**文档**：本报告。未修改 `docs/开发任务/10-全接口契约骨架覆盖审计.md/.json`（见 §十一）。

## 八、测试内容（M01DictSkeletonContractTest，26 用例）

1. 9 条路由 + HTTP 动词 + 参数类型反射契约；2. 两个控制器的模块内 `@RequestMapping` 前缀（`/dict/type`、`/dict/data`）；
3. 8 条冻结权限注解逐值断言（`system:dict:list/query/add/edit`，恰一个值）；
4. 066 保持「无 `@RequiresPermissions`」+ 源码无未登记权限串/无 `@Anonymous`；
5. 9 条骨架入口无 `@Log`，旧路由 `@Log`（type/data 的 export、remove、refreshCache）逐条保留；
6. 方法体源码取证：9 个入口只调 `dict*ApplicationService.*` 且禁列 30+ 旧协作者 token；
7. 066 Path 权威覆盖 Query 且覆盖发生在转发之前；8. 11 处未登记旧路由实现原样 + `SysDictDataNode`/`buildDictTypeTree`/
   `buildTwoLevelSupport` 已从代码（剥注释）消失；9. 端口与实现的可执行代码不含 DictUtils/Redis/Mapper/SqlSession/@Autowired；
10. 9 个端口方法逐编号 501；11. 端口/控制器 null 入参同样显式 501；12. 实现类零字段、只实现 1 个端口、代码层
    无 `return null`/`return new`/`setApplied`/`TODO`，端口方法数恰 4/5、无嵌套结果结构、异常体系唯一；
13. 每个骨架方法体恰一条 `throw`、编号精确、无 `return`（不伪成功）；
14. 058/061/059/060 的 HTTP 501 外壳（`code=501`、`errorCode=NOT_IMPLEMENTED`、`contractId`、`requestId` 为字符串、
    `msg` 文本、无 `data`/`rows`/`total`/`applied`/`objectVersion`）——无伪成功；
15. 062/065/063/064/066 同上（含 X-Request-Id 合法 UUID 回显）；16. 五条读路径响应体不含 Entity 类名/`dictValue`/
    `delFlag`/`params`，写路径响应体不含 `createBy`/`isDefault`；
17. 11 条旧路由方法签名仍存在 + 9 条骨架入口无 DELETE 绑定；18. 9 个 DTO 字段全集 = 冻结契约（逐集合等值）；
19. Body/Query 禁止 `createBy/updateBy/delFlag/params/searchKey/searchValue/orderByColumn/isAsc/parentValue` 等，
    `isDefault/dictLevel/isEditable` 不入 Body，062 不声明 F，066 不携带 WriteMeta；20. Query 默认值（pageNum=1、
    pageSize=10、includeDisabled=false）；21. 写 Command 预留 `requestId/managementRevision:String`、读 Query 无
    WriteMeta、控制器与实现不装配守卫/幂等；22. 外部 ID 全 String、日期 LocalDate、分页/层级/排序 Integer；
23. 5 个 View 字段全集 = 冻结契约、无内部列、不继承 `SysDictType/SysDictData/BaseEntity`；
24. `audit` 复用 `AuditView`、`allowedActions`/`children` null 安全（空数组而非 null）、`disabled` 默认 false；
25. BLK-03 未实现：6 个类代码层不含 `DICT_KEY_IN_USE`/引用检查 Port 名，端口无 `check*` 方法；
26. TASK-COMMON/USR/CFG 入口无回归（048/067 绑定与权限、075 无注解、`UserApplicationService` 恰 8 方法、
    `ConfigApplicationService` 恰 5 方法）。

## 九、验证结果（分层记录）

| 层级 | 结果 |
| --- | --- |
| 静态检查（`git diff` 通读自有 2 个控制器改动 + 新文件 import/签名/注解一致性核对） | **通过** |
| 结构自查（新测试与 2 个控制器大括号/引号配平脚本校验） | **通过** |
| `git diff --check` | **通过**（退出码 0，无空白错误） |
| 9 个编号逐项扫描 | 9/9 均存在精确 `SkeletonNotImplementedException("M01-058..066")`，与方法一一对应 |
| 00 清单/任务书冻结表逐项比对 | 9/9 一致（路由、动词、权限、Request DTO、Response VO），无出入需折中 |
| 编译（`mvn -pl futurefab-modules/futurefab-system -am -DskipTests compile`） | **未运行**（任务书协调约束：四包并行期间禁止 Maven，由协调者统一时段执行） |
| 单元/契约测试（`mvn -pl futurefab-modules/futurefab-system -am test`，含 PRE-01A/B、SECURITY-P0-R1、COMMON/USR/CFG/ORG/ACL 回归） | **未运行**，待统一时段 |
| SQL 执行、服务启动、网关/JWT、HTTP-浏览器联调、外部系统 | **未执行** |

因此本报告只宣称到「静态检查通过」层级，**不宣称编译或通过测试通过**，待协调者统一时段回填实测结果后方可升级。
静态自查重点核对的编译风险：新 DTO/View 与被测类型同包同名、控制器删除私有内部类后无残留引用、
`SysDictDataController` 保留 `ArrayList/List/StringUtils/SysDictData`（旧 `dictType()` 与 export 仍在用）、
移除 `Comparator/HashMap/LinkedHashMap/Map/BeanUtils/Validated/TableDataInfo/SecurityUtils` 七个已无引用的 import、
`SysDictTypeController` 的 `@RequestMapping` 通配 import 下注解可用、
新测试仅引用已完成任务的公开类型（`SysUserController`/`UserPageQuery`/`UserApplicationService`/
`SysConfigController`/`ConfigPageQuery`/`ConfigApplicationService`/`AuditView`）。

## 十、阻塞与挂账项（非骨架缺口）

1. **BLK-03**（M02/M04 跨模块字典消费引用注册）未冻结 → 060 类型键修改、064 自定义值改动的 `DICT_KEY_IN_USE`
   引用检查无法实现；本包未发明 Port 签名，接线位为两个 Mutation 端口的实现阶段前置校验。
2. **066 复合授权口径**未冻结 → 「业务使用该字典」缺权威使用登记表，OR 判定与 `includeDisabled=true` 的
   「仅编辑上下文」判定留待业务实现阶段；届时需在 ApplicationService 侧接判定，而非回到控制器硬编码权限串。
3. 字典缓存重建（`DictUtils`/Redis 键与 `refreshCache` 的新契约化归口）、`isDefault` 的运行期策略、
   二级层级一致性校验、`allowedActions` 计算、分页排序与时间范围校验、404/409 语义 → 业务实现阶段。
4. 前端 `futurefab-ui` 的字典模块仍按旧契约调用（Entity 平铺、`params[beginTime/endTime]`、`searchKey`、
   `dictValue` 原值、旧 `tree` 返回 `SysDictDataNode` 结构、`isDefault` 出现在表单 Body），新契约字段化后必然不兼容，
   需后续联调阶段适配（本任务未改 Vue）。
5. 10 审计中 9 条记录的状态（PARTIAL_SKELETON → SKELETON_WIRED）与 `applicationServiceSkeleton` 等字段需重算：
   本任务不修改 10 审计文件（§十一）。
6. 46 条未登记旧路由（含 dict 的 11 条）处置归 TASK-ROUTE。

## 十一、边界确认

- 未修改 `docs/开发任务/10-全接口契约骨架覆盖审计.md/.json` 与 00/01/02/05—13 号文档（只读）；10 审计统计未由本任务
  刷新，9 条记录状态更新请由协调者在统一收口时按程序化实算处理，避免与并行写者冲突。
- 未触碰仓库根 `_tmp_*` 文件（其他审计会话产物）。
- 未修改 SysVenue/SysDept/SysGroup/SysMenu/SysRole/SysConfig/SysUser 控制器及其 DTO/View/ApplicationService/测试；
  未修改 `ISysDictTypeService`/`ISysDictDataService` 及 `SysDictTypeServiceImpl`/`SysDictDataServiceImpl`；
  未修改 Mapper、Mapper XML、SQL、Redis、Vue、开发基线、客户只读材料。
- 编辑前重读了两个控制器的当前内容，改动为逐方法替换，未整体重写、未格式化他人变更。
- 未执行任何 `mvn` 命令；仅执行只读 `git status`/`git diff`/`git diff --check`。
- 未执行 `git commit`/`git push`/创建 PR；未执行 `checkout`/`reset`/`stash`/清理他人变更。

## 十二、结论

**9/9 完成**：M01-058—M01-066 已达冻结契约骨架形态并逐编号显式 501；M01-066 保持「已认证（网关 AuthFilter）+
无新增权限字符串」的冻结复合口径；BLK-03 跨模块字典引用检查未实现、未发明签名；无字典缓存读写、无 SQL、
无 Mapper/Redis 接触、无真实字典业务逻辑；非范围内旧路由与 TASK-COMMON/USR/CFG/ORG/ACL 既有接线未被触碰；
编译与测试结果待协调者统一 Maven 时段回填（当前仅静态检查通过）。
