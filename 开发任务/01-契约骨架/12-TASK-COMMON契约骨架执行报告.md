# 12 - TASK-COMMON 执行报告：公共认证、会话、日志与权限上下文契约骨架补齐（12 条 ADJUST）

- 任务编号：TASK-COMMON
- 执行日期：2026-09-19
- 依据：`docs/开发任务/10-全接口契约骨架覆盖审计`（12 条 ADJUST 记录）、M01 详细设计 API01—API12/LOG01—LOG02/SEC01—SEC02 冻结契约、§17 类型口径、TASK-SECURITY-P0-R1 审阅通过结论、用户 TASK-COMMON 任务书（§一—§十六）
- 阶段定位：契约骨架阶段——只建立契约与调用层级，不实现认证、密码、会话、日志查询、权限计算业务
- Git 状态：未提交（按任务书要求，不执行任何 git 提交/推送）

## 一、任务是否完成

**完成。** 任务书 §一 目标达成：12 条 ADJUST 接口全部达到
`Controller → 冻结 Command/Query → ApplicationService → 显式 SkeletonNotImplementedException → HTTP 501`
的契约骨架形态；5 条既有 NEW（M01-002/003/004/006/074）回归无破坏；§十五 完成门禁 12 条全部满足（见 §十六）。

## 二、范围核对（§一/§二）

本次接线 12 条（全部为 ADJUST）：

| # | 接口 | canonical 路由 | 实际绑定（模块内路由） |
| --- | --- | --- | --- |
| 1 | M01-001 | POST /auth/login | auth：`@PostMapping("login")`（网关 /auth 前缀还原，EXACT） |
| 2 | M01-005 | PUT /system/user/profile/updatePwd | system：`PUT /user/profile/updatePwd` |
| 3 | M01-007 | PUT /system/user/resetPwd | system：`PUT /user/resetPwd` |
| 4 | M01-008 | GET /system/user/passwordValidity | system：`GET /user/passwordValidity` |
| 5 | M01-009 | PUT /system/user/passwordValidity | system：`PUT /user/passwordValidity` |
| 6 | M01-010 | DELETE /auth/logout | auth：`@DeleteMapping("logout")` |
| 7 | M01-011 | POST /auth/refresh | auth：`@PostMapping("refresh")` |
| 8 | M01-012 | POST /auth/unlockscreen | auth：`@PostMapping("/unlockscreen")` |
| 9 | M01-072 | GET /system/logininfor/list | system：`GET /logininfor/list` |
| 10 | M01-073 | GET /system/operlog/list | system：`GET /operlog/list` |
| 11 | M01-075 | GET /system/user/getInfo | system：`GET user/getInfo` |
| 12 | M01-076 | GET /system/menu/getRouters | system：`GET menu/getRouters` |

未重做 5 NEW（002/003/004/006/074），仅回归。未触碰其余 46 个 ADJUST、46 条未登记旧路由、数据库/开发基线 SQL、Vue、客户只读材料；未新增或修改任何 Mapper 接口/XML/SQL（`git status` 复核，见 §十七）。

## 三、10 审计报告统计勘误（§四）

先于代码修改完成：TASK-COMMON 任务包元数据由错误的"6 NEW+11 ADJUST"修正为 **17 = 5 NEW 已完成（002/003/004/006/074）+ 12 ADJUST**，MD 与 JSON 同步（内容条目与推荐顺序第 2 项）；未重新生成或改写其余 76 条记录。本次收尾再把 12 条记录状态由 PARTIAL_SKELETON 更新为严格枚举 COMPLETE_SKELETON（批次归属“TASK-COMMON 接线”记录在 suggestedFixTaskPackage 与 gapDescription 字段，不进入 conclusion 取值），统计 18→30 / 58→46（见 §十五、§十九）。

## 四、DTO / View 契约（§五）

新建 28 个契约文件（外部 DTO 一律非 Entity；所有外部 ID 为 String；时间统一 ISO 类型 `OffsetDateTime`/`LocalDate`；集合 null 安全默认空）：

**auth 侧**（`futurefab-auth/.../domain/`）：
- `dto/m01/LoginCommand`{username,password,code,uuid,clientId,requestId}、`LogoutCommand`{requestId}、`TokenRefreshCommand`{requestId}、`ScreenUnlockCommand`{password,requestId}
- `vo/m01/LogoutResult`（空载荷，data=null）、`ScreenUnlockResult`（空载荷）、`TokenRefreshResult`{`expires_in`:Integer, `expiresAt`:OffsetDateTime}；001 响应复用既有 NEW 冻结 `LoginResult`（仅契约字段，不生成真实 token）

**system 侧**（`.../domain/dto/m01/`、`.../domain/vo/m01/`）：
- `ProfilePasswordUpdateCommand`{oldPassword,newPassword,confirmPassword,expectedCredentialVersion,requestId,managementRevision(预留)}
- `UserPasswordResetCommand`{userId:String,expectedCredentialVersion,requestId,managementRevision(预留)}——按冻结契约**删除 password 入参**
- `PasswordValidityQuery`{pageNum,pageSize}、`PasswordValiditySaveCommand`{validDays,remindDays,expectedPolicyVersion,requestId,managementRevision(预留)}
- `LoginLogPageQuery`/`OperLogPageQuery`（§17.2 冻结查询字段逐项展开，Query 不接受未定义字段）
- `CurrentIdentityQuery`/`CurrentRouteQuery`（空冻结 Query）
- `LoginLogRow`/`OperLogRow`（日志敏感字段只定义安全展示字段：OperLogRow 不含 operParam/jsonResult 原文）
- `PasswordValidityRow`（D4）+ `PasswordValidityPageResult`（顶层 validDays/remindDays/policyVersion/rows/total，不返回 data 包裹列表）
- `CurrentIdentityView`{user:ProfileView, roles:string[], permissions:string[], permissionRevision:string, password:冻结D1状态对象 PasswordStateView, allowedModules:string[]}
- `RouteNodeView`+`RouteMetaView` 完整展开，不引用 SysMenu
- `MutationResult` 复用既有冻结模型；075 的 `ProfileView` 沿用 SECURITY-P0-R1 安全 View 文件（§九）

全部 Command 不含 createBy/updateBy/delFlag/params；无 password/哈希/token 原文/challenge 原文响应字段（LoginResult 契约定义务字段除外，骨架 501 不产出）。

## 五、ApplicationService 分包（§六）

按任务书固定五服务，无巨型 Service、无平行体系（接口在 `service/application/m01/`，实现在 `service/impl/application/m01/`）：

| 服务 | 承接接口 |
| --- | --- |
| auth `AuthenticationApplicationService` | 001 login、012 unlockScreen |
| auth `SessionApplicationService` | 010 logout、011 refresh |
| system `PasswordManagementApplicationService` | 005/007/008/009 |
| system `SystemLogQueryApplicationService` | 072/073（074 由既有实现承接，本服务不重复建立，接口恰 2 方法有测试断言） |
| system `SecurityContextApplicationService` | 075 currentIdentity、076 currentRoutes |

## 六、骨架实现边界（§七）

每个骨架方法只含一条语句：`throw new SkeletonNotImplementedException("M01-nnn")`。测试断言三层：异常类型统一（复用 common-core 既有异常，未创建第二套）、contractId 逐接口精确、实现类声明字段数=0（无状态、无协作者）。未调用旧 Service/Mapper/Redis/TokenService，未校验密码、未生成 token、未修改会话、未查询日志/菜单，未返回 null/空集合/固定成功伪装。501 响应含 `errorCode=NOT_IMPLEMENTED` + `requestId`（RequestMetadataResponseAdvice 注入）+ `contractId` 可定位接口编号，不含堆栈与类名（GlobalExceptionHandler 统一映射，有直接调用断言测试）。

## 七、Controller 接线与旧编排移除（§八）

- `TokenController`：依赖收敛为 3 个 m01 ApplicationService（反射断言声明字段类型全集相等；SysLoginService/TokenService/AuthUtil/JwtUtils/LoginBody/UnLockBody 依赖全部移除）；010 的 requestId 由 `X-Request-Id` 必填 Header 装配进 LogoutCommand（无 Body）。
- `SysUserController`：007/008/009 改调 PasswordManagementApplicationService；075 改调 SecurityContextApplicationService，旧 `getSysAccountChrtype/initPasswordIsModify/passwordIsExpiration` 私有编排方法删除，tokenService/configService 字段移除（049 `getInfo(Long)`+UserDetailView 未动）。
- `SysProfileController`：005 改调 updateProfilePassword（本人接口，不附加权限注解）。
- `SysLogininforController`/`SysOperlogController`：072/073 list 改调 SystemLogQueryApplicationService，旧 `startPage()+Mapper` 查询编排移除。
- `SysMenuController`：076 改调 currentRoutes，不再经 menuService.buildMenus。
- 接线方法内无 DB 写、Redis 写、登录日志写发生在 501 之前；未捕获未实现异常转 200；Controller 不触碰 Mapper/Entity 拼装/固定成功。

**三项显式口径决定：**
1. **@Log 注解从 12 个接线端点移除**：`LogAspect` 会在异常响应（含 501）时仍写 `sys_oper_log`，与 §八 "501 前不产生日志写"冲突；操作日志记录属业务实现阶段恢复。
2. **072/073 超级管理员硬校验**：冻结口径为"超级管理员且 system:logininfor:list / system:operlog:list"（05 SEC-R7 指定 TASK-COMMON 接线时补齐）；沿用 074 既有先例，注解之外方法内 `SecurityUtils.isAdmin` 判否即抛 `NotPermissionException`（异常消息标识符，未创造新权限字符串）。
3. **075 兼容口径**：SECURITY-P0-R1 已交付的安全 View 文件保留复用，Controller 改调新 AppService 后不再从旧 LoginUser/SysUser 拼装。

## 八、12 接口最终权限口径（§十）

| 接口 | 最终注解/校验 | 与冻结设计关系 |
| --- | --- | --- |
| M01-001 | 无注解（PUBLIC，网关白名单 /auth/login） | 一致 |
| M01-005 | 无注解（已认证本人，不擅自加管理员权限） | 一致 |
| M01-007 | `@RequiresPermissions("system:user:edit")` | 一致 |
| M01-008 | `@RequiresPermissions("system:user:query")` | 一致 |
| M01-009 | `@RequiresPermissions("system:user:edit")` | 一致 |
| M01-010 | 无注解（AUTHENTICATED 会话型） | 一致 |
| M01-011 | 无注解（AUTHENTICATED_REFRESH_TOKEN） | 一致 |
| M01-012 | 无注解（AUTHENTICATED_LOCKED_SESSION） | 一致 |
| M01-072 | `@RequiresPermissions("system:logininfor:list")` + 方法内超管硬校验 | 复合口径"超级管理员且…"完整落地 |
| M01-073 | `@RequiresPermissions("system:operlog:list")` + 方法内超管硬校验 | 同上 |
| M01-075 | 无注解（AUTHENTICATED） | 一致 |
| M01-076 | 无注解（AUTHENTICATED） | 一致 |

未照搬旧注解覆盖新契约、未创造新权限字符串（072/073 异常消息使用 `system:logininfor:list:super-admin` / `system:operlog:list:super-admin` 标识符，与 074 既有先例同型）。

## 九、特殊接口措施（§九）

- 001 保持 canonical /auth/login，经 AuthenticationApplicationService 显式 501，不影响 002/003/004（三者的挑战/续跑链路文件未动，测试回归 501 正常）。
- 005/007/009 预留 WriteMeta 契约位置（command.managementRevision:String + javadoc 声明骨架不校验、不接守卫）；当前不接 ManagementGuardExecutor、不修改密码配置历史表、不生成回执。
- 008/072/073 查询不要求 WriteMeta；072/073 冻结分页 Query + PageResult rows/total 外壳；008 用专用 PasswordValidityPageResult 顶层外壳；三者均明确 501、不返回空分页。
- 010/011/012 不删刷 Redis key、不生成 token、不校验真实密码、不返回固定 revoked/refreshed/unlocked=true。
- 076 不调旧菜单 Service、不返回旧 RouterVo（RouterVo 类归旧路由处置 TASK-ROUTE）。

## 十、测试与执行结果（§十一 24 项）

新增 2 个契约测试类、改造 1 个既有测试类，共 33 个用例全绿：

- `futurefab-auth/src/test/.../TokenControllerSkeletonContractTest.java`（14 用例）：MockMvc 501（001/010/011/012 + 002/003/004 回归，断言 code/errorCode/contractId/requestId/data 缺失）；Controller 仅依赖 3 个 m01 AppService（含无反射旧字段）；路由/参数/返回类型反射契约；骨架 null 入参仍统一 501；骨架实现 0 字段；DTO 字段逐项=冻结设计；TokenRefreshResult 契约类型；GlobalExceptionHandler 直调 501 脱敏断言。**执行结果：Tests run: 14, Failures: 0, Errors: 0。**
- `futurefab-system/src/test/.../contract/M01SystemSkeletonContractTest.java`（19 用例）：8 条 system 入口路由+HTTP 动词反射契约；权限注解冻结口径（005/075/076 无注解、007/009 system:user:edit、008 system:user:query、072/073 list 注解）；072/073 非超管先抛 NotPermissionException、超管达 501；MockMvc 501（008 GET 绑定、072/073、075/076 无旧拼装）；8 个 AppService 方法含 null 入参统一 501；骨架实现 0 字段；SystemLogQueryApplicationService 恰 2 方法（074 不重复）；接线方法体源码取证——必调对应 AppService 且不再引用 tokenService/configService/menuService/startPage/RouterVo/LoginUser 等旧协作者；Command/Query 字段全集=冻结契约且无 createBy/updateBy/delFlag/params；View 外部 ID String、时间 OffsetDateTime/LocalDate、集合非 null；ProfileView 无 password/token/challengeToken、075 password 槽位=D1 状态对象。**执行结果：Tests run: 19, Failures: 0, Errors: 0。**
- `M01ResponseLeakGuardTest`（SECURITY-P0-R1 回归，13 用例全绿）：userController 装配随接线更新（去除已删除字段），075 段改写为显式 501 + 不再拼装旧 LoginUser 双断言。**R1 无回归。**
- 既有 `AuthContractReflectionTest`、`CommonResponseShellTest`、guard 全套等**全部通过**：system 模块合计 `Tests run: 149, Failures: 0, Errors: 0`。

§十一 24 项逐条覆盖映射：12 路由/方法/权限（两测试类反射契约）；参数冻结 DTO + 返回契约类型（assertFields/绑定断言）；Controller→AppService（方法体源码取证 + MockMvc 501）；AppService 统一 501/不伪成功（直调 + HTTP）；登录不调密码校验/TokenService、logout/refresh/unlock 不访问 Redis、日志列表不调 Mapper、075/076 不调旧权限/菜单 Service（骨架实现 0 字段 + Controller 接线依赖断言 + 方法体取证；骨架在进入任何旧协作者前即抛出）；写接口不调 ManagementGuardExecutor、查询不要求 WriteMeta、写接口 WriteMeta 预留正确（§九/§十断言+代码审查）；响应无 password/token/challenge 原文（View 字段断言 + LeakGuard 回归）；外部 ID String/时间 ISO（类型断言）；5 个既有 NEW 仍 501（auth 测试回归 + PasswordState 骨架既有测试）；SECURITY-P0-R1/PRE-01A/PRE-01B-R1 无回归（149 全绿）；其余 46 个 ADJUST Controller 未修改（git diff 文件清单核对）；无新增 Mapper/XML/SQL（git status 核对）。

## 十一、验证命令与实际执行（§十二）

| 命令 | 结果 |
| --- | --- |
| `mvn -pl futurefab-modules/futurefab-system -am test` | BUILD SUCCESS；system 模块 Tests run: 149, Failures: 0, Errors: 0（含上游 common/auth 依赖模块编译） |
| `mvn -pl futurefab-auth -am test` | BUILD SUCCESS；Tests run: 14, Failures: 0, Errors: 0 |
| `git diff --check` | 退出码 0，无空白错误 |

## 十二、验证层级声明

- 静态检查：通过（DTO/View/Service/Controller 契约反射测试）。
- 编译：通过（auth + system 及依赖模块）。
- 单元/MockMvc 契约测试：通过（standalone MockMvc 走真实 RequestMetadataFilter + 三个 ControllerAdvice，501 外壳为实测输出）。
- **未执行**：真实 MySQL、真实 Redis、真实 JWT、浏览器/HTTP 联调、外部系统联调——按骨架阶段边界，12 条入口现在返回显式 501，**系统暂不能用于完整浏览器登录联调，这是任务书预期的结果**（"先建全接口骨架、后填业务逻辑"）。不宣称任何更高完成层级。

## 十三、futurefab-auth 测试基建说明

auth 模块此前无测试目录与测试依赖；为落实任务书 §十一"5 个既有 NEW 仍 501 + 4 条新接线的 MockMvc 断言"，在 `futurefab-auth/pom.xml` 增加 `spring-boot-starter-test`（test scope，与 system 模块同法）。不改运行时代码、不引第三方框架。

## 十四、遗留/待实现事项（不构成骨架缺口）

1. 12 条入口的业务实现（真实校验密码/签发轮换 token/Redis 会话/日志 SQL/权限与路由计算）——实现阶段按 05 §9 与 02 冻结签名接线。
2. @Log 操作日志注解在业务实现阶段评估恢复（现属外部副作用，骨架禁止）。
3. 072/073 的日志内容脱敏投影细则、BLK-04b/04c 分类裁决仍挂账（10 审计 blockers 不变）。
4. RouterVo、SysLoginService、LoginBody 等旧类仍服务旧路由，处置归 TASK-ROUTE。
5. 前端仍按旧契约调用登录/登出/刷新——冻结契约变更需前端适配，属后续联调阶段事项（本任务不改 Vue）。

## 十五、审计状态更新（§十四）

`10-全接口契约骨架覆盖审计.json` + `.md` 同步更新：仅 TASK-COMMON 任务包数量勘误（§三）+ 这 12 条记录的 DTO/View、ApplicationService（接口/骨架实现路径）、currentCallChain、notImplementedStatus、权限口径（072/073）、writeMeta 预留、evidencePathsAndLines、conclusion→严格枚举 COMPLETE_SKELETON（批次归属由 suggestedFixTaskPackage“TASK-COMMON已完成契约骨架接线…”承载，见 §十九勘误说明）、gapDescription 改写为实现阶段事项；统计 statusCounts/status_counts/summary 与 MD 判定分布、四节表、六节引言一致更新为 **COMPLETE_SKELETON 30 / PARTIAL_SKELETON 46**（76 条记录总数不变）。其余 64 条接口记录逐字段未改动（diff 复核）。

## 十六、完成门禁核验（§十五 12 条）

1. 12 条全部到达显式 501（MockMvc+直调断言）——满足。
2. 未实现任何认证/密码/会话/日志/权限业务（骨架方法单语句）——满足。
3. §四 统计勘误先于代码完成，MD/JSON 同步——满足。
4. DTO/View 14 条字段规则逐项满足且有测试锁定——满足。
5. 五服务分包与 §六 一致，无巨型 Service/平行体系——满足。
6. 复用唯一 SkeletonNotImplementedException，未建第二套——满足。
7. Controller 接线且不直连旧 Service/Mapper/Redis/TokenService——满足（§十方法体+字段断言）。
8. 未接入 ManagementGuardExecutor，WriteMeta 仅预留字段——满足。
9. 未新增/修改 Mapper 接口、XML、SQL、数据库、基线、Vue、客户只读材料——满足。
10. 其余 46 ADJUST、5 NEW、46 旧路由未触碰——满足。
11. §十二 三条验证命令实际执行且全绿——满足。
12. 未提交 Git、未执行破坏性 git 操作——满足。

## 十七、修改文件清单

**新增（38）**：auth `domain/dto/m01/{LoginCommand,LogoutCommand,TokenRefreshCommand,ScreenUnlockCommand}.java`、`domain/vo/m01/{LogoutResult,ScreenUnlockResult,TokenRefreshResult}.java`、`service/application/m01/{AuthenticationApplicationService,SessionApplicationService}.java`、`service/impl/application/m01/{AuthenticationApplicationServiceImpl,SessionApplicationServiceImpl}.java`、`src/test/.../TokenControllerSkeletonContractTest.java`；system `domain/dto/m01/{ProfilePasswordUpdateCommand,UserPasswordResetCommand,PasswordValidityQuery,PasswordValiditySaveCommand,LoginLogPageQuery,OperLogPageQuery,CurrentIdentityQuery,CurrentRouteQuery}.java`、`domain/vo/m01/{PasswordValidityRow,PasswordValidityPageResult,LoginLogRow,OperLogRow,CurrentIdentityView,RouteMetaView,RouteNodeView}.java`、`service/application/m01/{PasswordManagementApplicationService,SystemLogQueryApplicationService,SecurityContextApplicationService}.java`、对应 3 个 Impl、`src/test/.../M01SystemSkeletonContractTest.java`。

**修改（9）**：`TokenController.java`、`SysUserController.java`、`SysProfileController.java`、`SysLogininforController.java`、`SysOperlogController.java`、`SysMenuController.java`、`futurefab-auth/pom.xml`、`M01ResponseLeakGuardTest.java`、10 审计 MD+JSON。

## 十八、下一步

按用户确认顺序：进入 **TASK-USR**（用户 CRUD 7 条）；随后 TASK-ORG ∥ TASK-ACL ∥ TASK-DIC ∥ TASK-CFG 按文件所有权并行补齐；TASK-ROUTE 处置登记与 G-阶段门三项裁决保持挂账。

## 十九、R1 勘误：conclusion 严格枚举化（TASK-COMMON-R1）

TASK-COMMON 收尾时曾把 12 条记录的 conclusion 写为扩展文本 `COMPLETE_SKELETON（TASK-COMMON接线）`，违反"conclusion 必须是六个合法枚举值之一、字段内不得追加说明文字"的口径，导致对 `interfaces[].conclusion` 严格等值实算只得 18，与 summary.statusCounts/status_counts 的 30 不一致。

修正（仅文档，无源码改动）：

1. `10-…审计.json`：12 条（M01-001/005/007/008/009/010/011/012/072/073/075/076）conclusion 收敛为严格枚举 `COMPLETE_SKELETON`；其余字段未动。
2. `10-…审计.md`：12 个接口节标题与 12 行 `**conclusion**` 字段同步收敛，与 JSON 完全同源；汇总叙述（判定分布、四节表中的"18 NEW + TASK-COMMON 12 条"）保留为说明文字，不属于状态字段。
3. 批次归属不丢失：仍由每条记录的 `suggestedFixTaskPackage`（"TASK-COMMON已完成契约骨架接线；业务实现阶段按 05 §9 接线验证"）与任务包描述、推荐顺序第 2 项承载。

复核结果：JSON 可解析；76 条记录 conclusion 严格等值实算 = {COMPLETE_SKELETON: 30, PARTIAL_SKELETON: 46}，与 summary.statusCounts、status_counts、MD 判定分布一致；非法枚举值 0；扩展文本作为字段取值在 JSON/MD/本报告残留 0（本报告仅本节引号内保留一次历史缺陷原文引用，非字段取值）。
