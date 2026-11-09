# 13-TASK-USR 契约骨架执行报告

> 版本：TASK-USR／2026-09-19／分支 cloud。基线：PRE-01B-R1（07 报告）+ TASK-COMMON（12 报告）+ SECURITY-P0-R1（11 报告）。
> 任务书：TASK-USR 用户与个人资料接口契约骨架补齐（10 接口＝8 ADJUST + 2 NEW 回归）。

## 一、是否完成

**完成（骨架层级）**。8 条 ADJUST 接口已按冻结契约建立 DTO/View → ApplicationService 骨架 → Controller 接线，统一显式 `SkeletonNotImplementedException → HTTP 501`；054/057 两条 NEW 接口回归通过、未重复建结构。未实现任何真实用户查询或写入（本任务边界内不作为缺陷）。

## 二、精确接口范围

| 编号 | 路由 | 处置 | 骨架出口 |
| --- | --- | --- | --- |
| M01-048 | GET /system/user/list | ADJUST | `listUsers(UserPageQuery) → PageResult<UserRow>`，501 |
| M01-049 | GET /system/user/{userId}（含兼容 "/"） | ADJUST | `getUserDetail(UserDetailQuery) → UserDetailView`，501 |
| M01-050 | POST /system/user | ADJUST | `createUser(UserCreateCommand) → MutationResult`，501 |
| M01-051 | PUT /system/user | ADJUST | `updateUser(UserUpdateCommand) → MutationResult`，501 |
| M01-052 | PUT /system/user/changeStatus | ADJUST | `changeUserStatus(UserStatusChangeCommand) → MutationResult`，501 |
| M01-053 | DELETE /system/user/{userIds} | ADJUST | `deleteUsers(UserDeleteCommand) → MutationResult`，501 |
| M01-055 | GET /system/user/profile | ADJUST | `getProfile(ProfileQuery) → ProfileView`，501 |
| M01-056 | PUT /system/user/profile | ADJUST | `updateProfile(ProfileUpdateCommand) → MutationResult`，501 |
| M01-054 | GET /system/user/editor-options | NEW（回归） | 既有 `editorOptions` 显式 501，未重复创建 |
| M01-057 | POST /system/user/{userId}/force-logout | NEW（回归） | 既有 `forceLogout` 显式 501，未重复创建 |

## 三、8 ADJUST + 2 NEW 数量说明

任务书开头痛查纠正：TASK-USR 精确范围为 **10 接口 = 8 ADJUST + 2 NEW**，不是此前 10 审计 task_packages 中估计的「3 NEW + 7 ADJUST」。经逐条核对 00 清单与 10 审计 `routeDisposition`：用户组 10 条中 NEW 仅 054/057 两条（均已在 PKG-01 建立骨架，本任务只回归验证），其余 8 条全部为 ADJUST。10 审计 task_packages TASK-USR 行与推荐顺序第 3 项已同步更正该数量口径。

## 四、新增/复用 DTO/View 与关键裁定

**新增 DTO（dto/m01，9 个）**：UserPageQuery、UserDetailQuery、UserCreateCommand、UserUpdateCommand、UserStatusChangeCommand、UserDeleteCommand、ProfileQuery、ProfileUpdateCommand、AuthorizationChange。

**新增 View（vo/m01）**：UserRow（Person 展开 + loginIp/loginCount/sessionVersion/audit/allowedActions）。

**复用并补齐**：UserDetailView（补 online/sessionVersion/avatarPreset/credentialVersion/labAuthorizationVersion/allowedActions 契约字段位，不计算真实值）、ProfileView（补 avatarPreset）。

**裁定记录**：
1. **M01-053 复用 MutationResult，不创建 DeleteResult**：冻结设计 USR06 输出即 `data W`（W={applied,id,affectedIds,managementRevision}），任务书 §五 允许「冻结设计明确 DeleteResult 等同 W 则复用」。evidence：Controller请求调用时序设计 USR06 输出定义 + PKG-00 MutationResult（vo/common）。
2. **AuthorizationChange 外部线型为 String**：M02-Q09 冻结 `labId:string / authType:"0"|"1"|"2"`；内部 `AuthorizationLevel` 枚举（Jackson 默认序列化为 NAME）与线型不一致，故 dto/m01 独立定义 String 线型 DTO，映射边界写入类 javadoc，实现阶段在 Port 边界转换。
3. **WriteMeta 按 TASK-COMMON 先例以 Command 体字段预留**（requestId/managementRevision），ADJUST 入口不接请求头装配；057（NEW）既有请求头装配不动。
4. **@Log 不挂骨架写入口**：LogAspect 会在 501 时仍写 sys_oper_log，违反「501 前无 DB/日志副作用」门禁；恢复实现时随业务一并接回。
5. **profile 旧顶层 roleGroup/postGroup 语义**：非冻结契约字段，骨架 View 白名单（§17.2 Profile）不含，测试断言随适配移除（见 §十四）。

## 五、ApplicationService 分包

- `UserApplicationService`（接口）+ `UserApplicationServiceImpl`：同一接口承接 6 条 CRUD 新方法（listUsers/getUserDetail/createUser/updateUser/changeUserStatus/deleteUsers）+ 既有 editorOptions/forceLogout，共 8 方法；**未新建第二个 UserCrudApplicationService**（§六）。
- `UserProfileApplicationService` + Impl（新建）：getProfile/updateProfile 两方法（§六）。
- 骨架实现类零字段（`getDeclaredFields().length==0` 断言锁定），每方法只抛 `SkeletonNotImplementedException("M01-nnn")`，无 null/空分页/固定成功返回（§七）。

## 六、Controller → ApplicationService 映射

| 入口 | 协作者 | 旧编排处置 |
| --- | --- | --- |
| SysUserController.list | userApplicationService.listUsers | startPage/preparePhoneQuery 链路移除 |
| SysUserController.getInfo(String)（049，含 "/" 与 "/{userId}" 双映射） | userApplicationService.getUserDetail | checkUserDataScope/selectUserById/roles/posts 自由结构移除；userId 为 String，根路径 null 不拆箱 |
| SysUserController.add | userApplicationService.createUser | 唯一性×3/encryptPassword/insertUser 移除 |
| SysUserController.edit | userApplicationService.updateUser | checkUserAllowed/checkUserDataScope/updateUser 移除 |
| SysUserController.changeStatus | userApplicationService.changeUserStatus | updateUserStatus 直写移除 |
| SysUserController.remove | userApplicationService.deleteUsers | ArrayUtils 自删校验/级联删移除；Path 逗号拆分仅做绑定 |
| SysProfileController.profile | userProfileApplicationService.getProfile | selectUserByUserName/role-post 拼接移除 |
| SysProfileController.updateProfile | userProfileApplicationService.updateProfile | 唯一性校验/updateUserProfile（含 cached password 回写）移除 |

049 兼容根路径 "/" 保留等待 TASK-ROUTE 裁决，两条路径均只进冻结 Query（§八）；本 Controller 已完成的 007/008/009/075、054/057 与 SysProfileController 的 005 updatePwd/006 passwordState/头像上传旧路由未改动（§八）；export/importData/deptUsers/authRole/deptTree 等未登记旧路由保持原样（§二十，属 TASK-ROUTE）。

## 七、权限口径（§九，不创造新权限字符串）

048 `system:user:list`、049 `system:user:query`（保留）、050 `system:user:add`、051/052 `system:user:edit`、053 `system:user:remove`；055/056 已认证本人，不附加管理员权限注解。反射断言锁定。

## 八、WriteMeta 预留（§十）

写接口 050/051/052/053/056 Command 均含 `requestId/managementRevision` 字段位；不接 ManagementGuardExecutor、幂等、CAS、审计、ActorContextPort。读接口 048/049/055 的 Query **不含** WriteMeta 字段（测试双向断言）。

## 九、安全边界逐条自查（§二 23 项）

1–2 仅建 DTO/View/AppService/Controller 接线与显式 501；3 无真实查询/写入；4 未调用 ISysUserService 业务方法（骨架入口方法体静态取证禁列 userService/roleService/deptService/postService/permissionService）；5–6 未调用 SysUserMapper，**无新增/修改 Mapper、XML、SQL**（本任务改动清单内 0 个 mapper 文件）；7–9 未接守卫执行器/ActorContextPort/审计钩子；10 未调用 M02 真实授权实现（AuthorizationChange 仅线型定义）；11 未读写 sys_user_lab 或实验室私有表；12 未生成初始密码；13 未发送通知；14 未撤销真实会话；15 未计算真实数据权限；16 未修改 Vue；17 未修改客户只读材料；18 未修改开发基线 SQL；19 未处理其他 38 条 PARTIAL；20 未处理 46 条未登记旧路由；21 未提交 Git；22 未执行 reset/checkout/restore/clean；23 已读 AGENTS.md 并逐条源码核对调用链。

## 十、是否仍调用旧 Service

接线方法体内旧 Service 调用已全部移除（M01UserSkeletonContractTest#wiredMethodsOnlyCallUserApplicationServices 逐方法禁列 token 断言）。Controller 保留的 userService 等字段仍被未登记旧路由（deptUsers/export/info/email/authRole 等）使用，属 TASK-ROUTE 范围，本任务不删。

## 十一、是否访问 Mapper/Redis/M02

否。501 在任何 DB/Redis/M02 调用之前抛出（骨架实现无协作者字段、方法体单行抛异常，MockMvc 验证 GET 绑定隐式消费路径同样 501）。

## 十二、是否接入 ManagementGuardExecutor

否。全仓骨架入口 0 引用（G8 口径复查），WriteMeta 仅字段位。

## 十三、修改文件清单

**新增（main，12）**：dto/m01 9 个（§四）+ vo/m01/UserRow.java + service/application/m01/UserProfileApplicationService.java + service/impl/application/m01/UserProfileApplicationServiceImpl.java。
**修改（main，6）**：service/application/m01/UserApplicationService.java、service/impl/application/m01/UserApplicationServiceImpl.java、vo/m01/UserDetailView.java、vo/m01/ProfileView.java、controller/SysUserController.java、controller/SysProfileController.java。
**测试**：新增 contract/M01UserSkeletonContractTest.java；适配 security/M01ResponseLeakGuardTest.java（049/055 入口改断言显式 501 + 冻结 View 白名单，原「响应无 password」防护语义不降级，SECURITY-P0-R1 全类通过）。
**文档**：docs/开发任务/10-全接口契约骨架覆盖审计.json/.md（仅 8 条记录允许字段 + 程序化统计 + TASK-USR 包行/推荐顺序第 3 项数量勘误）、本报告。
本任务未触碰：mapper/、resources/mapper/、domain 实体、futurefab-ui、docs/开发基线、客户只读材料、其他模块。

## 十四、测试数量与结果

`mvn -pl futurefab-modules/futurefab-system -am test`（离线）：**169 通过 / 0 失败 / 0 错误**。其中：
- M01UserSkeletonContractTest（新增）20 项：路由/动词/权限反射、8 入口 Controller→AppService 方法体取证（旧协作者禁列）、AppService 8+2 方法编号 501（含 null 入参）、MockMvc 8 入口 501 外壳（code/errorCode/contractId/requestId/无 data）、049 双路径 501、DTO/View 字段全集与禁止字段（password/sex/avatar/postIds/delFlag/params/nickName@056/userName@051）、外部 ID String/OffsetDateTime ISO/集合非 null、写 Command 预留 WriteMeta 且读 Query 无、骨架实现零字段、UserApplicationService 恰 8 方法无重复外壳、053 逗号绑定不进 Entity 链。
- M01SystemSkeletonContractTest 19 项（TASK-COMMON 回归）、M01ResponseLeakGuardTest 13 项（SECURITY-P0-R1 回归）全绿。
- `mvn -pl futurefab-auth -am test`：14 通过 / 0 失败（TokenControllerSkeletonContractTest 无回归）。
- `git diff --check`：退出码 0。

## 十五、M01-054/057 回归结果

两条 NEW 接口未重复创建 DTO/View/AppService 方法（接口方法总数断言=8）；`editorOptions → M01-054`、`forceLogout → M01-057` 显式 501 断言通过；其请求头装配与既有注解未改动。

## 十六、TASK-COMMON 回归结果

12 条 ADJUST（001/005/007/008/009/010/011/012/072/073/075/076）契约测试 M01SystemSkeletonContractTest 19 项全绿；SysUserController 075 `getInfo()` 无参方法保持 TASK-COMMON 接线原样（编辑过程中曾误删并已恢复，反射+MockMvc 断言锁定）。PRE-01A/B 相关 meta/guard 测试类全部通过。

## 十七、审计统计变化（程序化实算）

10 审计 `interfaces[].conclusion` 重算：COMPLETE_SKELETON 30→**38**、PARTIAL_SKELETON 46→**38**、其余状态 0、合计 76。JSON `status_counts`/`summary.statusCounts` 与 MD 判定分布/§四表同源刷新；8 条记录 conclusion 严格为枚举值 `COMPLETE_SKELETON`，无括号追加（MD 正则后验 non-strict=0）。

## 十八、未执行环境验证（验证层级声明）

本报告仅声明至：**静态检查 + 编译 + 单元测试通过**层级。未执行：真实 MySQL/Redis/JWT 联调、HTTP 端到端、浏览器验收、M02/AAD/SDMS 外部系统联调；不得引用为上述任一层级通过。

## 十九、下一步建议

1. 剩余 38 条 PARTIAL 按所有权并行：**TASK-ORG(14) ∥ TASK-ACL(10) ∥ TASK-DIC(9) ∥ TASK-CFG(5)**（10 审计§十三；R1 勘误见§二十）。
2. TASK-ROUTE：46 条未登记旧路由处置 + M01-049 根路径 "/" 收敛裁决。
3. G-阶段门三项裁决前，本批骨架不得进入真实实现（守卫接线/审计映射/SEC-I01/实验室范围）。
4. 实现阶段回填事项已逐条写入 8 条审计记录 gapDescription；053 结果类型裁定（复用 W）需接口目录侧同步确认一次。

## 二十、TASK-USR-R1 勘误记录（2026-09-19）

- 问题：本报告 §十九 与 10 审计 task_packages/推荐顺序沿用了审计初稿的后续任务包数量估计 **ORG(13)/ACL(8)**，与 PARTIAL_SKELETON=38 不一致（13+8+9+5=35）。
- 实算（从 10 审计 `interfaces[]` 的 `conclusion==PARTIAL_SKELETON` + `suggestedFixTaskPackage` 程序化计算，无遗漏无重复）：**TASK-ORG=14**（M01-014/015/016/018/019/020/024/025/026/028/030/031/032/033）、**TASK-ACL=10**（M01-036/037/039/040/041/042/043/044/045/046）、**TASK-DIC=9**（M01-058..066）、**TASK-CFG=5**（M01-067..071），合计 **38**。
- 连带勘误：TASK-ORG 包行旧措辞「9 NEW已完成+13 ADJUST骨架建立」、TASK-ACL 包行「5 NEW已完成+8 ADJUST」与组内实算（ORG 8 NEW/14 ADJUST、ACL 3 NEW/10 ADJUST）不符，已按实算改写为「待 TASK-ORG/TASK-ACL 补齐骨架」；JSON 推荐顺序第 3 项「用户CRUD 7条」沿用旧估计同步更正（该包已完成，不影响其 8 条结论）。
- 影响面：仅文档计数措辞；**TASK-USR 代码、8 条记录结论、38/38 总统计与 interfaces[] 归属均未改动**；其余状态计数不变。
