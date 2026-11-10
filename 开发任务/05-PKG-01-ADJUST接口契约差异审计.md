# PKG-01 M01 58 个 ADJUST 接口契约差异审计

版本：AUDIT-20260918-02（R2 修订） · 日期：2026-09-18 · 分支：cloud
范围：M01 中 `route_disposition=ADJUST` 的 58 个接口（18 个 NEW 与 M08 不在本批）。
性质：只审计，不修改任何 Java/XML/Vue/SQL；未执行任何数据库或运行联调。
R2 修订：结论口径按查询/写接口拆分；BLK-01 重定性为公共实现前置项 PRE-01（依据 PKG-00 设计 §3：HTTP 成功外壳继续由 R/AjaxResult/TableDataInfo 适配，非设计未决）；删除 BLK-05（政策版本权威已定：sys_config 键 `sys.account.passwordPolicyVersion`，初始值 1，策略保存同事务递增）；BLK-04 拆为 04a 已冻结/04b、04c 未冻结；删除 OBS-1（M01-034 canonical 路径统一为 POST /system/smp/labgroup/resolve-members，与当前 Controller 和清单一致）；修正 M01-009 的政策版本依据引用。

权威输入：00-全接口契约骨架清单.json（冻结物理签名）、接口目录与契约定位、物理接口与骨架字段设计、Controller 请求调用时序设计、详细设计 §17/§22/§23、00-全接口契约骨架问题收口决策 §3。
核查方法：五路并行源码核查（auth／用户与资料／组织三域／菜单与角色／字典·配置·日志），全部结论带 文件:行号 证据；当前代码状态含工作树中 PKG-00/PKG-01 未提交骨架改动。

## 1. 审计结论

- **58/58 全部处置为 B（ADAPTER_REQUIRED）**。判定口径按接口类型区分，且可复核：24 个 GET 查询接口的 B 判定依据是命名 Query/View 缺失（Entity/Map 绑定入参、实体直出或自由结构响应）、权限与数据范围收紧、脱敏、分页排序口径四类差距，不要求 WriteMeta/幂等/管理守卫；34 个非 GET 接口（其中 31 个管理写接口）在前四类之上还要求 WriteMeta 合并（X-Request-Id/X-Management-Revision/Path 覆盖 Body/未知字段拒绝）、requestId 幂等回执、managementRevision/乐观锁 CAS、SYSTEM 管理守卫与同事务审计，现状同样全部缺失。**没有任何一条 ADJUST 链路今天可直接满足冻结契约**，故 A=0。
- **C=0**：M01 的 COMPAT/DISABLE 记录数为 0（清单 summary），且 §22 把"保留旧入口"的旁路（/role/dataScope、/role/authUser/*、/user/authRole、updateSort、字典 DELETE、clean/unlock、export、InnerAuth 入口等）全部登记在 canonical 之外——不在这 58 条内。58 条 canonical 路径与现有路由完全重合，设计明确要求原地调整+前后端同批升级（详细设计 §17："不能假设旧客户端无改动即可兼容"），不存在"必须保留旧契约入口另立 canonical"的接口。旁路收口单列 TASK-L。
- **D=0**：每条接口的适配路径（DTO/View/守卫/回执/权限）均已冻结可判定；设计缺口不影响"如何适配"的决定，只影响个别子能力（跨模块引用检查、敏感键注册）的实现完备性，已单列开发前阻塞项 BLK-02、BLK-03、BLK-04b/04c 并给出解决方式。响应外壳差距不属于设计未决：依据 PKG-00 设计 §3，HTTP 成功外壳继续由现有 R/AjaxResult/TableDataInfo 适配，定名为公共实现前置项 PRE-01（TASK-0 内容）。
- P0 泄漏与破坏性差异集中在：password 哈希随 SysUser 实体序列化外泄（M01-049/055/075）、配置详情无鉴权+敏感原文（M01-070）、登录/改密/重置密码语义与凭据版本链路缺失（M01-001/005/007）、PUT /user 口令回写通道（M01-051）、原子创建缺历史/认证状态（M01-050）。
- 角色 data_scope 权威模型（sys_role_data_scope 为权威、data_scope 列仅投影）与现状（只写列、role_dept 走旁路）冲突，属结构性迁移（TASK-D），涉及数据权限全局回归。
- 全部 Mapper 接口方法与 XML statement 经核对照存在（清单登记名一致）；缺口集中在 Service 未调用（deleteSysVenueByVenueIds、deleteSysGroupByGroupIds、updateDictDataType 之外的引用检查、selectMemberDetailsByGroupId）与排序/过滤口径，而非 statement 缺失。

## 2. 处置与风险统计

| 处置 | 数量 | 风险 | 数量 |
| --- | ---: | --- | ---: |
| A DIRECT_COMPATIBLE | 0 | P0 | 9 |
| B ADAPTER_REQUIRED | 58 | P1 | 33 |
| C CANONICAL_ENDPOINT_REQUIRED | 0 | P2 | 16 |
| D DESIGN_BLOCKED | 0 | 合计 | 58 |

合计 58，与清单 JSON M01 ADJUST=58 严格一致；NEW 18 条未计入。

## 3. 58 个接口完整明细

### M01-001　POST /auth/login

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API01 |
| 当前 Controller | com.futurefab.auth.controller.TokenController#login |
| 当前实际路由 | POST /auth/login（auth 服务内 POST "login"，TokenController 无类级前缀，网关 /auth/** StripPrefix=1） |
| 当前权限 | 无注解；网关白名单 security.ignore.whites 含 /auth/login（PUBLIC 语义一致） |
| 冻结权限 | PUBLIC |
| 当前请求类型 | LoginBody 实体直收（仅 username/password；前端已送 code/uuid 但后端忽略） |
| 冻结 Request | LoginCommand |
| 当前响应类型 | R<?>，data=Map{access_token,expires_in}（TokenService.createToken 生成） |
| 冻结 Response | LoginResult |
| 当前 Service 调用 | SysLoginService#login（契约登记复用，实现远未满足契约） |
| 当前 Mapper/XML | NOT_APPLICABLE（认证边缘入口，不直连 M01 Mapper） |
| 调用链摘要 | TokenController.login→SysLoginService.login→RemoteUserService.getUserInfo→SysPasswordService.validate(Redis pwd_err_cnt)→recordLogininfor+recordLoginInfo→TokenService.createToken |
| 已确认兼容调用方 | futurefab-ui api/login.js:login、store/modules/user.js（登录页/401 重登） |
| 主要差距 | 验证码 code/uuid、clientId、requestId 未纳入 LoginCommand；网关 CaptchaProperties 与登录校验链路断开（code 从不校验）；凭据通过即签发 720 分钟业务令牌：无 outcome 三分支（AUTHENTICATED/CHANGE_REQUIRED/EXPIRY_WARNING）、无 5 分钟受限挑战、无首密/到期强制改密判定；未调用 I01 verifyCredential/I02 activateSession；login_count、pwd_err_cnt 计数口径与契约（格式/验证码错误不计口令失败）不一致；响应为匿名 Map，非命名 LoginResult；password 状态（D1）不回传；无 X-Request-Id；重复提交无幂等 |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-auth/src/main/java/com/futurefab/auth/controller/TokenController.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/dto/m01/LoginCommand.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/vo/m01/LoginResult.java（已存在，接线）<br>futurefab-auth/src/main/java/com/futurefab/auth/service/SysLoginService.java |
| 文件所有者建议 | PKG-01（auth 7 入口相关文件归 M01 包） |
| 实现注意事项 | 保留 POST /login 路由；新建 LoginCommand+扩展 AuthChallengeApplicationService 或 SysLoginService.login 编排改走 I01/I02；响应 LoginResult（auth vo/m01 已存在未接线）。旧前端必须同批升级（§17 不得假设旧客户端兼容）。 |
| 最小验证方式 | auth 编译+反射断言映射/参数类型；契约测试：outcome 三分支快照、LoginResult 字段、验证码错误不计口令失败用例；HTTP 冒烟联调层后补；`mvn -pl futurefab-auth -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位001；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-005　PUT /system/user/profile/updatePwd

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API05 |
| 当前 Controller | com.futurefab.system.controller.SysProfileController#updatePwd |
| 当前实际路由 | PUT /system/user/profile/updatePwd（内部 /user/profile/updatePwd） |
| 当前权限 | 无权限注解，登录态+会话用户（AUTHENTICATED_SELF 语义一致） |
| 冻结权限 | AUTHENTICATED_SELF |
| 当前请求类型 | Map<String,String>{oldPassword,newPassword} 明文旧口令上行 |
| 冻结 Request | ProfilePasswordUpdateCommand |
| 当前响应类型 | AjaxResult 无 data（toAjax/success 自由结构） |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysUserService#resetUserPwd（仅更新口令+pwd_update_date） |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#resetUserPwd（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysProfileController.updatePwd→校验 oldPassword(matchesPassword)→userMapper.resetUserPwd→tokenService.setLoginUser(不清会话) |
| 已确认兼容调用方 | api/system/user.js:updateUserPwd:91、views/profile 改密页 |
| 主要差距 | 缺 confirmPassword/expectedCredentialVersion/requestId；未知字段不拒绝；无历史 10 次复用比对（sys_user_password_history 表在基线，链路未写）；无 credentialVersion CAS；改密后不撤销其它会话（契约要求同事务撤销）；无 MutationResult{applied,credentialVersion} |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysProfileController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ProfilePasswordUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ProfilePasswordUpdateCommand；建议在 system 侧新建 PasswordCommandApplicationService（或扩展现有 UserApplicationService）编排历史比对+I05 revokeSession。 |
| 最小验证方式 | 契约测试：未知字段拒绝、版本冲突 VERSION_CONFLICT、历史复用 PASSWORD_REUSED、会话撤销副作用边界（Redis 操作不入本地事务断言）；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位005；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-007　PUT /system/user/resetPwd

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API07 |
| 当前 Controller | com.futurefab.system.controller.SysUserController#resetPwd |
| 当前实际路由 | PUT /system/user/resetPwd |
| 当前权限 | @RequiresPermissions("system:user:edit")（注解一致；缺目标可管理+超管保护调用链） |
| 冻结权限 | system:user:edit |
| 当前请求类型 | SysUser 实体直收（userId+password 明文由前端传入） |
| 冻结 Request | UserPasswordResetCommand |
| 当前响应类型 | toAjax(int)（{code,msg}，无 data=W） |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysUserService#resetUserPwd |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#resetUserPwd（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysUserController.resetPwd→userMapper.resetUserPwd(按 userId 无条件更新) |
| 已确认兼容调用方 | api/system/user.js:resetUserPwd:48（当前送随机前端密码，服务端不生成） |
| 主要差距 | 契约 Body 为 userId/expectedCredentialVersion/requestId，删除旧 body.password（旧客户端传密码须 INPUT_INVALID）——请求语义破坏性变更；未调 checkUserAllowed/checkUserDataScope：可重置超管/越权目标；初始口令未服务端生成、未写密码历史/认证状态、未撤销目标会话；无 MutationResult{applied,credentialVersion} |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/UserPasswordResetCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 UserPasswordResetCommand；Controller 收敛到应用服务：checkUserAllowed+checkUserDataScope+策略口令生成+I05 撤销。前端重置密码对话框同批改为"服务端生成回显一次性口令"或不回显（契约不返回初始明文）。 |
| 最小验证方式 | 用例：传 password 即 INPUT_INVALID、重置超管 PERMISSION_DENIED、credentialVersion 冲突、目标会话撤销；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位007；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-008　GET /system/user/passwordValidity

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API08 |
| 当前 Controller | com.futurefab.system.controller.SysUserController#getPasswordValidity |
| 当前实际路由 | GET /system/user/passwordValidity |
| 当前权限 | @RequiresPermissions("system:user:query")（一致） |
| 冻结权限 | system:user:query |
| 当前请求类型 | 无参（内部 new SysUser()，不接收 deptId/关键字分页参数） |
| 冻结 Request | PasswordValidityQuery |
| 当前响应类型 | AjaxResult 手工 put{validDays,remindDays,rows,total}，rows=List<SysUser>（selectUserVo 列不含 password） |
| 冻结 Response | List<PasswordValidityRow> |
| 当前 Service 调用 | ISysUserService#selectUserList（@DataScope）+ISysConfigService#selectConfigByKey |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#selectUserList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysUserController.getPasswordValidity→startPage→selectUserList→sys_config 读政策键 |
| 已确认兼容调用方 | api/system/user.js:getPasswordValidity:139、views/system/user 密码有效性页 |
| 主要差距 | 缺 PasswordValidityQuery 命名（pageNum/pageSize 允许值 10/20/50/100 校验）；响应缺 policyVersion；rows 为 SysUser 实体（应 PasswordValidityRow 白名单）；政策与列表非同一一致性快照（两次独立读）；排序非 user_id ASC；未过滤含停用口径说明（当前 selectUserList 已含 del_flag=0 停用账号 ✓） |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/PasswordValidityQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/PasswordValidityRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 PasswordValidityQuery/PasswordValidityRow；应用服务一次性读政策版本+列表快照（同连接一致性读）。 |
| 最小验证方式 | 契约测试：外壳字段齐备(rows/total/validDays/remindDays/policyVersion)、pageSize 非法值 INPUT_INVALID；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位008；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-009　PUT /system/user/passwordValidity

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API09 |
| 当前 Controller | com.futurefab.system.controller.SysUserController#savePasswordValidity |
| 当前实际路由 | PUT /system/user/passwordValidity |
| 当前权限 | @RequiresPermissions("system:user:edit")——冻结要求 Q06 仅超级管理员，缺失 |
| 冻结权限 | system:user:edit |
| 当前请求类型 | Map<String,Integer>{validDays,remindDays}（可空跳过、无 1-100/1-15 值域校验） |
| 冻结 Request | PasswordValiditySaveCommand |
| 当前响应类型 | success() 无 data |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysConfigService#saveConfigValueByKey |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysConfigMapper#updateConfigValueByKey（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysUserController.savePasswordValidity→saveConfigValueByKey×2(两键分两次写)→Redis 同步 |
| 已确认兼容调用方 | api/system/user.js:savePasswordValidity:148 |
| 主要差距 | 权限差异：无超级管理员校验（PERMISSION_DENIED 应可判定）；两键分两次写、无政策版本行先锁→可部分成功（契约禁止）；缺 expectedPolicyVersion CAS 与 requestId 幂等；输出缺 {applied,policyVersion} |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/PasswordValiditySaveCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysConfigServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysConfigMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysConfigMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 PasswordValiditySaveCommand；政策版本权威存储为 sys_config 键 sys.account.passwordPolicyVersion（初始值 1，策略保存同事务递增，依据《数据库表结构与字段字典》§sys.account 键表与开发基线 02-基础数据初始化.sql 固定种子）；SYSTEM 管理写事务仍按 sys_management_revision 固定 SYSTEM 行加锁并校验 expectedManagementRevision，再原子写两键＋政策版本递增。 |
| 最小验证方式 | 用例：非超管 403、版本冲突 VERSION_CONFLICT、同键异载荷 REQUEST_CONFLICT、部分写回滚断言；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位009；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-010　DELETE /auth/logout

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API10 |
| 当前 Controller | com.futurefab.auth.controller.TokenController#logout |
| 当前实际路由 | DELETE /auth/logout |
| 当前权限 | 无注解+Authorization 解析（AUTHENTICATED 语义一致） |
| 冻结权限 | AUTHENTICATED |
| 当前请求类型 | HttpServletRequest 取 Bearer；无 X-Request-Id |
| 冻结 Request | LogoutCommand |
| 当前响应类型 | R.ok() data=null |
| 冻结 Response | LogoutResult |
| 当前 Service 调用 | SysLoginService#logout（仅记日志）+AuthUtil.logoutByToken→TokenService.delLoginUser |
| 当前 Mapper/XML | NOT_APPLICABLE（认证边缘入口，不直连 M01 Mapper） |
| 调用链摘要 | TokenController.logout→按 JWT user_key 直接删 login_tokens:{uuid} 单键→sysLoginService.logout(用户名日志) |
| 已确认兼容调用方 | api/login.js:logout:42、store/modules/user.js:LogOut |
| 主要差距 | X-Request-Id 契约必填但未读，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；按 token 删缓存而非 sessionKey 匹配：新会话被旧令牌退出误删的风险（契约：不匹配只删旧缓存不碰新 key）；过期/撤销令牌幂等 200 与伪造 401 的区分未实现（当前任意可解析 token 均 200） |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-auth/src/main/java/com/futurefab/auth/controller/TokenController.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/dto/m01/LogoutCommand.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/vo/m01/LogoutResult.java<br>futurefab-auth/src/main/java/com/futurefab/auth/service/SysLoginService.java |
| 文件所有者建议 | PKG-01（auth 7 入口相关文件归 M01 包） |
| 实现注意事项 | 新建 LogoutCommand（token/sessionKey/requestId 合并）；delLoginUser 改 sessionKey 匹配+代次语义（对接 I05）。 |
| 最小验证方式 | 用例：旧 key 不匹配不清新 key、过期令牌 200、伪造 401、同 requestId 幂等；`mvn -pl futurefab-auth -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位010；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-011　POST /auth/refresh

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API11 |
| 当前 Controller | com.futurefab.auth.controller.TokenController#refresh |
| 当前实际路由 | POST /auth/refresh |
| 当前权限 | 无注解+token；冻结要求 AUTHENTICATED_REFRESH_TOKEN（不创建新 token 的专用上下文）未表达 |
| 冻结权限 | AUTHENTICATED_REFRESH_TOKEN |
| 当前请求类型 | 仅 Authorization；X-Request-Id 契约必填未读 |
| 冻结 Request | TokenRefreshCommand |
| 当前响应类型 | R.ok() data=null（缓存未命中也 200——契约应 401） |
| 冻结 Response | TokenRefreshResult |
| 当前 Service 调用 | TokenService#refreshToken（纯缓存续 TTL） |
| 当前 Mapper/XML | NOT_APPLICABLE（认证边缘入口，不直连 M01 Mapper） |
| 调用链摘要 | TokenController.refresh→getLoginUser→命中 refreshToken(重置 expireTime)；不查库、不验状态 |
| 已确认兼容调用方 | api/login.js:refreshToken:17（request.js 拦截器 401 前重试路径需核对） |
| 主要差距 | 未校验用户状态/凭据版本/锁定/到期（"只要缓存存在就续期"正是契约禁止项）；不返回 data={expires_in,expiresAt}；miss 应 SESSION_INVALID 401；未区分 refresh token 与业务 token 上下文 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-auth/src/main/java/com/futurefab/auth/controller/TokenController.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/dto/m01/TokenRefreshCommand.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/vo/m01/TokenRefreshResult.java<br>futurefab-auth/src/main/java/com/futurefab/auth/service/TokenService.java |
| 文件所有者建议 | PKG-01（auth 7 入口相关文件归 M01 包） |
| 实现注意事项 | 新建 TokenRefreshCommand/TokenRefreshResult；经 I03 validateSession 后 TTL 续期；TokenService 拆分 refresh 专用路径。 |
| 最小验证方式 | 用例：禁用/改密/锁定用户续期被拒 401/423、成功返回 expiresAt、sessionVersion 与 login_count 不变；`mvn -pl futurefab-auth -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位011；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-012　POST /auth/unlockscreen

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | API12 |
| 当前 Controller | com.futurefab.auth.controller.TokenController#unlockScreen |
| 当前实际路由 | POST /auth/unlockscreen |
| 当前权限 | 登录态（AUTHENTICATED_LOCKED_SESSION 语义未显式校验"锁屏会话"上下文） |
| 冻结权限 | AUTHENTICATED_LOCKED_SESSION |
| 当前请求类型 | UnLockBody{password}；requestId 契约必填未收 |
| 冻结 Request | ScreenUnlockCommand |
| 当前响应类型 | R.ok() data=null |
| 冻结 Response | ScreenUnlockResult |
| 当前 Service 调用 | SysLoginService#unlock |
| 当前 Mapper/XML | NOT_APPLICABLE（认证边缘入口，不直连 M01 Mapper） |
| 调用链摘要 | TokenController.unlockScreen→SecurityUtils.getUsername→RemoteUserService.getUserInfo→matchesPassword |
| 已确认兼容调用方 | api/login.js:unlockScreen:33、views/lock.vue（锁屏页） |
| 主要差距 | 不读写 LOGIN 失败窗口（Q10 与登录合并计数缺失）：锁屏口令可无限暴破；锁定/凭据已改/会话被替换的 423/401 分支未实现；旧公网入口 GET /system/logininfor/unlock/{userName} 仍可用（SysLogininforController:77-84）且前端 handleUnlock 在用——§22 要求关闭，属旁路收口任务（与 M01-072 同批） |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-auth/src/main/java/com/futurefab/auth/controller/TokenController.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/dto/m01/ScreenUnlockCommand.java<br>futurefab-auth/src/main/java/com/futurefab/auth/domain/vo/m01/ScreenUnlockResult.java<br>futurefab-auth/src/main/java/com/futurefab/auth/service/SysLoginService.java |
| 文件所有者建议 | PKG-01（auth 7 入口相关文件归 M01 包） |
| 实现注意事项 | 新建 ScreenUnlockCommand{password,requestId}；复用 I01 mode=UNLOCK（authProof=null）。 |
| 最小验证方式 | 用例：失败计入 LOGIN 窗口、达阈值 423、成功 data=null 不发新会话、旧 unlock GET 网关拒绝；`mvn -pl futurefab-auth -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位012；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#7-外部接口明细；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-014　POST /system/smp/venue

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG02(定位014) |
| 当前 Controller | com.futurefab.system.controller.SysVenueController#add |
| 当前实际路由 | POST /system/smp/venue（内部 /smp/venue） |
| 当前权限 | @RequiresPermissions("system:venue:add")（一致） |
| 冻结权限 | system:venue:add |
| 当前请求类型 | SysVenue 实体直收（@RequestBody，无 @Validated） |
| 冻结 Request | VenueSaveCommand |
| 当前响应类型 | toAjax(int) 无 data=W |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysVenueService#insertSysVenue |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysVenueMapper#insertSysVenue, checkVenueNameUnique, checkVenueCodeUnique, selectSysVenueByVenueId（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysVenueController.add→insertSysVenue(雪花ID/ancestors 计算/checkVenueUnique/delFlag=0)→SysVenueMapper.insertSysVenue（查重 checkVenueNameUnique/checkVenueCodeUnique 在 Service 自定义校验） |
| 已确认兼容调用方 | api/smp/venue.js:addVenue:29 |
| 主要差距 | 实体直收：venueCode 等只读/生成字段可被客户端注入（READ_ONLY_FIELD 未拒）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计；Service 无 @Transactional：主表写+查重竞态 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysVenueController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/VenueSaveCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysVenueServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysVenueMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysVenueMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 VenueSaveCommand；add/edit 共 Command；接 SYSTEM 守卫+W 回执{applied,id,affectedIds,managementRevision}。 |
| 最小验证方式 | 用例：未知/只读字段拒绝、重名 NAME_CONFLICT、父不存在 NOT_FOUND、幂等重放回执；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位014；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-015　PUT /system/smp/venue

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG03(定位015) |
| 当前 Controller | com.futurefab.system.controller.SysVenueController#edit |
| 当前实际路由 | PUT /system/smp/venue |
| 当前权限 | system:venue:edit（一致） |
| 冻结权限 | system:venue:edit |
| 当前请求类型 | SysVenue 实体直收 |
| 冻结 Request | VenueSaveCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysVenueService#updateSysVenue |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysVenueMapper#updateSysVenue, selectSysVenueList, selectSysVenueByVenueId（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysVenueController.edit→updateSysVenue（仅改本节点，不重挂子树 ancestors） |
| 已确认兼容调用方 | api/smp/venue.js:updateVenue:38 |
| 主要差距 | 移动父级不改写后代 ancestors（契约：子树重挂同事务、祖先链重写覆盖全部后代、防环 TREE_CYCLE）——现实现会产生脏祖先链；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysVenueController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/VenueSaveCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysVenueServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysVenueMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysVenueMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 复用 VenueSaveCommand；Service 补子树重写（参考 SysDeptServiceImpl.updateDeptChildren 模式）+防环检测，@Transactional。 |
| 最小验证方式 | 用例：移父后全部后代 ancestors 正确、环拒绝、并发 VERSION_CONFLICT；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位015；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-016　GET /system/smp/venue/tree

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG04(定位016) |
| 当前 Controller | com.futurefab.system.controller.SysVenueController#tree |
| 当前实际路由 | GET /system/smp/venue/tree |
| 当前权限 | system:venue:list（一致） |
| 冻结权限 | system:venue:list |
| 当前请求类型 | SysVenue query 绑定；excludeId 契约参数不存在 |
| 冻结 Request | VenueTreeQuery |
| 当前响应类型 | AjaxResult.data=List<SysVenue>（children 内存组装，含全部实体字段） |
| 冻结 Response | List<OptionView> |
| 当前 Service 调用 | ISysVenueService#selectSysVenueTree |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysVenueMapper#selectSysVenueList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysVenueController.tree→selectSysVenueList→内存构树 |
| 已确认兼容调用方 | api/smp/venue.js:treeVenue:12（父级选择器） |
| 主要差距 | 缺 excludeId 排除自身子树（编辑父级选择必需）；响应应 List<OptionView>（id/label/disabled/disabledReason/children）；仅可使用场地（status/删除过滤）未确认 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysVenueController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/VenueTreeQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/OptionView.java（已存在，接线）<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysVenueServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysVenueMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysVenueMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 VenueTreeQuery；OptionView 已存在于 vo/m01，只做映射层。 |
| 最小验证方式 | 用例：excludeId 排除子树、disabled 原因字段、软删/停用项不入树；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位016；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-018　DELETE /system/smp/venue/{venueIds}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG06(定位018) |
| 当前 Controller | com.futurefab.system.controller.SysVenueController#remove |
| 当前实际路由 | DELETE /system/smp/venue/{venueIds} |
| 当前权限 | system:venue:remove（一致） |
| 冻结权限 | system:venue:remove |
| 当前请求类型 | @PathVariable Long[]（逗号 ID；1–100 上限未校验） |
| 冻结 Request | VenueDeleteCommand |
| 当前响应类型 | toAjax(int) 无 DeleteResult |
| 冻结 Response | DeleteResult |
| 当前 Service 调用 | ISysVenueService#deleteSysVenueByVenueIds |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysVenueMapper#deleteSysVenueByVenueId, selectSysVenueList, countRelatedVenueUsage（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysVenueController.remove→全表载入+collectVenueCascade 递归收集子孙→逐条 checkVenueDeleteAllowed(countRelatedVenueUsage 引用 union 统计 lab_lab/lab_culture_container/lab_floor_scale/lab_detector/lab_integrated_reactor)→逐条 updateSysVenue(delFlag=2)；deleteSysVenueByVenueId(s) XML 存在但未被调用 |
| 已确认兼容调用方 | api/smp/venue.js:delVenue:47（单值路径已兼容 Long[]） |
| 主要差距 | 引用检查直读 M02 拥有表（union SQL 在 SysVenueMapper.xml:70-82）——跨模块表访问违反 Port 规则，见 BLK-02；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计；全表载入+逐条更新：无批量锁/稳定顺序、无整批原子声明（无 @Transactional）；ID 数量 1–100、正 ID 校验缺失 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysVenueController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/VenueDeleteCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysVenueServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysVenueMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysVenueMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 VenueDeleteCommand；删除走专用 statement+@Transactional；引用复核锁守卫后同事务执行。 |
| 最小验证方式 | 用例：REFERENCE_EXISTS 携数量、子树整棵原子软删、部分失败回滚；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位018；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-019　POST /system/dept

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG07(定位019) |
| 当前 Controller | com.futurefab.system.controller.SysDeptController#add |
| 当前实际路由 | POST /system/dept |
| 当前权限 | system:dept:add（一致） |
| 冻结权限 | system:dept:add |
| 当前请求类型 | @Validated SysDept 实体直收 |
| 冻结 Request | DeptCreateCommand |
| 当前响应类型 | toAjax(int)/error(字符串)（"新增部门…失败"自由文案） |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysDeptService#insertDept |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDeptMapper#insertDept, checkDeptNameUnique, checkDeptCodeUnique, selectDeptById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysDeptController.add→checkDeptNameUnique/checkDeptCodeUnique→insertDept(雪花/ancestors；父不存在时 info NPE 风险 SysDeptServiceImpl:231-245) |
| 已确认兼容调用方 | api/system/dept.js:addDept:29 |
| 主要差距 | orderNum 省略时未显式写 1（依赖实体/DB 默认）；父不存在→NPE 500 而非 NOT_FOUND；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计；无 @Transactional |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDeptController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DeptCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDeptServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDeptMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDeptMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DeptCreateCommand；错误文案改契约错误码。 |
| 最小验证方式 | 用例：顶级 parentId=0 不查父实体、orderNum 默认 1、父不存在 NOT_FOUND；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位019；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-020　PUT /system/dept

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG08(定位020) |
| 当前 Controller | com.futurefab.system.controller.SysDeptController#edit |
| 当前实际路由 | PUT /system/dept |
| 当前权限 | system:dept:edit（一致） |
| 冻结权限 | system:dept:edit |
| 当前请求类型 | @Validated SysDept 实体直收 |
| 冻结 Request | DeptUpdateCommand |
| 当前响应类型 | toAjax(int)/error(字符串) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysDeptService#updateDept |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDeptMapper#updateDept, updateDeptChildren, selectDeptById, selectChildrenDeptById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysDeptController.edit→checkDeptDataScope→updateDept(子树重挂 updateDeptChildren replaceFirst+updateParentDeptStatusNormal) |
| 已确认兼容调用方 | api/system/dept.js:updateDept:38 |
| 主要差距 | 整棵子树引用校验（用户/实验组/实验室项目配置→REFERENCE_EXISTS+数量）缺失；updateDeptChildren 用 replaceFirst：同前缀多子树理论竞态；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计；无 @Transactional（多 statement 写） |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDeptController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DeptUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDeptServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDeptMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDeptMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DeptUpdateCommand；引用校验涉及 M02/M03 数据（BLK-02）。 |
| 最小验证方式 | 用例：移父防环、祖先链 2000 字符上限 ANCESTOR_PATH_TOO_LONG、整批拒绝含数量；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位020；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-024　GET /system/smp/labgroup/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG12(定位024) |
| 当前 Controller | com.futurefab.system.controller.SysGroupController#list |
| 当前实际路由 | GET /system/smp/labgroup/list |
| 当前权限 | system:labgroup:list（一致） |
| 冻结权限 | system:labgroup:list |
| 当前请求类型 | SysGroup query 绑定 |
| 冻结 Request | GroupListQuery |
| 当前响应类型 | TableDataInfo{total,rows=List<SysGroup> 实体} |
| 冻结 Response | List<GroupRow> |
| 当前 Service 调用 | ISysGroupService#selectSysGroupList |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysGroupMapper#selectSysGroupList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysGroupController.list→startPage→selectSysGroupList(SysGroupMapper.xml)——无 leaders/memberCount 装配 |
| 已确认兼容调用方 | api/smp/labgroup.js:listLabgroup:4 |
| 主要差距 | 契约响应 List<GroupRow>（不分页外壳；含 leaders:Person[]、memberCount 有效成员去重）——实体行缺装配；keyword 匹配组名/编码/负责人规则未确认；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysGroupController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/GroupListQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/GroupRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysGroupServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysGroupMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysGroupMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 GroupListQuery/GroupRow；批量装配 leader/member（避免 N+1）。 |
| 最小验证方式 | 用例：leaders/memberCount 与两表一致、空组返回空数组；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位024；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-025　POST /system/smp/labgroup

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG13(定位025) |
| 当前 Controller | com.futurefab.system.controller.SysGroupController#add |
| 当前实际路由 | POST /system/smp/labgroup |
| 当前权限 | system:labgroup:add（一致） |
| 冻结权限 | system:labgroup:add |
| 当前请求类型 | SysGroup 实体直收（含 leaderUserIds/memberUserIds 数组字段） |
| 冻结 Request | GroupCreateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysGroupService#insertSysGroup |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysGroupMapper#insertSysGroup, batchInsertSysGroupLeader(SysGroupLeaderMapper), batchInsertSysGroupMember(SysGroupMemberMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysGroupController.add→insertSysGroup @Transactional→checkGroupUnique→syncGroupUsers(原子写 leader+member 两表) |
| 已确认兼容调用方 | api/smp/labgroup.js:addLabgroup:46 |
| 主要差距 | 实体直收+未知字段（groupId/delFlag 等可注入）；groupName≤20、groupCode 可选自动生成（新增时随名称）规则不完整；成员 ID 存在性与可管理范围校验缺失；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysGroupController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/GroupCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysGroupServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysGroupMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysGroupMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 GroupCreateCommand；成员/负责人分别多选不互带。 |
| 最小验证方式 | 用例：不存在用户 ID NOT_FOUND、编码自动生成、两表原子写；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位025；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-026　PUT /system/smp/labgroup

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG14(定位026) |
| 当前 Controller | com.futurefab.system.controller.SysGroupController#edit |
| 当前实际路由 | PUT /system/smp/labgroup |
| 当前权限 | system:labgroup:edit（一致） |
| 冻结权限 | system:labgroup:edit |
| 当前请求类型 | SysGroup 实体直收；null 数组=不清空（syncGroupUsers normalizeUserIds，null 跳过） |
| 冻结 Request | GroupUpdateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysGroupService#updateSysGroup |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysGroupMapper#updateSysGroup, deleteSysGroupLeaderByGroupId(SysGroupLeaderMapper), batchInsertSysGroupLeader(SysGroupLeaderMapper), deleteSysGroupMemberByGroupId(SysGroupMemberMapper), batchInsertSysGroupMember(SysGroupMemberMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysGroupController.edit→updateSysGroup @Transactional→checkGroupUnique→syncGroupUsers(先删后建) |
| 已确认兼容调用方 | api/smp/labgroup.js:updateLabgroup:55 |
| 主要差距 | 契约要求提交两个完整数组、空数组=清空：与现有 null 跳过语义不同，误删/漏删风险（旧成员未显示也不得误删）；用户手改编码后名称联动覆盖规则；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计；先删后建无集合差异校验：并发窗口内成员引用 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysGroupController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/GroupUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysGroupServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysGroupMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysGroupMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 GroupUpdateCommand（数组必携带完整集合）。前端详情必须先取完整 members（M01-033）。 |
| 最小验证方式 | 用例：空数组清空、缺字段 INPUT_INVALID、并发 VERSION_CONFLICT；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位026；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-028　DELETE /system/smp/labgroup/{groupIds}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG16(定位028) |
| 当前 Controller | com.futurefab.system.controller.SysGroupController#remove |
| 当前实际路由 | DELETE /system/smp/labgroup/{groupIds} |
| 当前权限 | system:labgroup:remove（一致） |
| 冻结权限 | system:labgroup:remove |
| 当前请求类型 | @PathVariable Long[]（1–100 未校验） |
| 冻结 Request | GroupDeleteCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | DeleteResult |
| 当前 Service 调用 | ISysGroupService#deleteSysGroupByGroupIds |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysGroupMapper#deleteSysGroupByGroupIds, deleteSysGroupLeaderByGroupId(SysGroupLeaderMapper), deleteSysGroupMemberByGroupId(SysGroupMemberMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysGroupController.remove→@Transactional 逐组 updateSysGroup(delFlag=2)+物理 delete leader/member 关系 |
| 已确认兼容调用方 | api/smp/labgroup.js:delLabgroup:64 |
| 主要差距 | 主表软删+清当前关系已满足语义 ✓；剩 W 回执/守卫/幂等（WM,GS,SH,AU）与批量数量校验；deleteSysGroupByGroupIds XML statement 存在但 Service 未用（循环更新） |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysGroupController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/GroupDeleteCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysGroupServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysGroupMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysGroupMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 GroupDeleteCommand；M03 项目成员快照不回溯撤销（实现时不得动 M03 数据）。 |
| 最小验证方式 | 用例：1–100 上限、关系清理与主表软删同事务；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位028；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-030　DELETE /system/dept/{deptId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG18(定位030) |
| 当前 Controller | com.futurefab.system.controller.SysDeptController#remove |
| 当前实际路由 | DELETE /system/dept/{deptId} |
| 当前权限 | system:dept:remove（一致） |
| 冻结权限 | system:dept:remove |
| 当前请求类型 | @PathVariable Long deptId |
| 冻结 Request | DeptDeleteCommand |
| 当前响应类型 | warn("存在下级部门…")/warn("部门存在用户…")字符串 AjaxResult 或 toAjax——契约应 REFERENCE_EXISTS/NOT_FOUND 错误码+DeleteResult |
| 冻结 Response | DeleteResult |
| 当前 Service 调用 | ISysDeptService#deleteDeptById |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDeptMapper#deleteDeptById, hasChildByDeptId, checkDeptExistUser, selectChildrenDeptById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysDeptController.remove→hasChildByDeptId+checkDeptExistUser(仅直属)→deleteDeptById(update del_flag=2) |
| 已确认兼容调用方 | api/system/dept.js:delDept:56 |
| 主要差距 | 全子树引用检查缺失（checkDeptExistUser 只查直属部门用户；契约要求任一后代有关联用户/实验组/实验室项目配置整批拒绝并返回数量）；引用检查在 Controller 编排（Controller 不得直连/多 Mapper 编排）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDeptController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DeptDeleteCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDeptServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDeptMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDeptMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DeptDeleteCommand；删除编排移入应用服务；实验组/项目配置引用涉 M02/M03（BLK-02）。 |
| 最小验证方式 | 用例：孙子层有用户也拒绝、返回数量、warn 字符串废弃；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位030；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-031　GET /system/smp/venue/{venueId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG19(定位031) |
| 当前 Controller | com.futurefab.system.controller.SysVenueController#getInfo |
| 当前实际路由 | GET /system/smp/venue/{venueId} |
| 当前权限 | system:venue:query（一致） |
| 冻结权限 | system:venue:query |
| 当前请求类型 | @PathVariable Long（PKG-01 的 delete-check 用 String venueId，类型不一致观察项） |
| 冻结 Request | VenueDetailQuery |
| 当前响应类型 | AjaxResult.data=SysVenue 实体（selectSysVenueByVenueId XML 不过滤 del_flag→已删可查） |
| 冻结 Response | VenueDetailView |
| 当前 Service 调用 | ISysVenueService#selectSysVenueByVenueId |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysVenueMapper#selectSysVenueByVenueId（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→selectSysVenueByVenueId |
| 已确认兼容调用方 | api/smp/venue.js:getVenue:21 |
| 主要差距 | 响应应 VenueDetailView（含 audit/allowedActions，children 空数组）；软删记录未过滤（NOT_FOUND 语义） |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysVenueController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/VenueDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/VenueDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysVenueServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysVenueMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysVenueMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 VenueDetailQuery/VenueDetailView；VenueRow 已在 vo/m01。 |
| 最小验证方式 | 用例：已删除 404、audit/allowedActions 快照；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位031；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-032　GET /system/dept/{deptId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG20(定位032) |
| 当前 Controller | com.futurefab.system.controller.SysDeptController#getInfo |
| 当前实际路由 | GET /system/dept/{deptId} |
| 当前权限 | system:dept:query（一致） |
| 冻结权限 | system:dept:query |
| 当前请求类型 | @PathVariable Long |
| 冻结 Request | DeptDetailQuery |
| 当前响应类型 | AjaxResult.data=SysDept 实体 |
| 冻结 Response | DeptDetailView |
| 当前 Service 调用 | ISysDeptService#selectDeptById |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDeptMapper#selectDeptById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→selectDeptById(XML 无 del_flag 过滤)→checkDeptDataScope |
| 已确认兼容调用方 | api/system/dept.js:getDept:21 |
| 主要差距 | 响应应 DeptDetailView（DeptRow 已在 vo/m01，children 空数组+audit/allowedActions）；软删可查 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDeptController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DeptDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/DeptDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDeptServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDeptMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDeptMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DeptDetailQuery；映射层复用 DeptRow/AuditView。 |
| 最小验证方式 | 用例：已删除 404、越权部门 PERMISSION_DENIED；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位032；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-033　GET /system/smp/labgroup/{groupId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ORG21(定位033) |
| 当前 Controller | com.futurefab.system.controller.SysGroupController#getInfo |
| 当前实际路由 | GET /system/smp/labgroup/{groupId} |
| 当前权限 | system:labgroup:query（一致） |
| 冻结权限 | system:labgroup:query |
| 当前请求类型 | @PathVariable Long |
| 冻结 Request | GroupDetailQuery |
| 当前响应类型 | AjaxResult.data=SysGroup 实体（fillGroupMembers 仅回填 leaderUserIds/memberUserIds，无 Person 明细） |
| 冻结 Response | GroupDetailView |
| 当前 Service 调用 | ISysGroupService#selectSysGroupByGroupId |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysGroupMapper#selectSysGroupByGroupId, selectLeaderUserIdsByGroupId(SysGroupLeaderMapper), selectMemberUserIdsByGroupId(SysGroupMemberMapper), selectMemberDetailsByGroupId(SysGroupMemberMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→selectSysGroupByGroupId(XML 不过滤 del_flag)+fillGroupMembers |
| 已确认兼容调用方 | api/smp/labgroup.js:getLabgroup:13（编辑对话框完整集合来源） |
| 主要差距 | 契约 GroupDetail 需 members:Person[] 完整集合（与 memberCount 一致）——selectMemberDetailsByGroupId 已存在未接入；软删可查；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysGroupController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/GroupDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/GroupDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysGroupServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysGroupMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysGroupMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 GroupDetailQuery/GroupDetailView；接 selectMemberDetailsByGroupId。 |
| 最小验证方式 | 用例：members 与两表一致、停用/删除组成员口径确认；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位033；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#18-场地、部门、实验组接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-036　POST /system/menu

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL02(定位036) |
| 当前 Controller | com.futurefab.system.controller.SysMenuController#add |
| 当前实际路由 | POST /system/menu |
| 当前权限 | system:menu:add（Q11 保持现状，一致） |
| 冻结权限 | system:menu:add |
| 当前请求类型 | @Validated SysMenu 实体直收 |
| 冻结 Request | MenuCreateCommand |
| 当前响应类型 | toAjax(int)/error 字符串 |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysMenuService#insertMenu |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysMenuMapper#insertMenu, checkMenuNameUnique, selectMenusByPathOrRouteName（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysMenuController.add→checkMenuNameUnique+isFrame http 校验+checkRouteConfigUnique→insertMenu(雪花，无 @Transactional) |
| 已确认兼容调用方 | api/system/menu.js:addMenu:37 |
| 主要差距 | F 不能做父、F 的 path/component/routeName/query/icon 应为 null、routeName 仅 C 必填等 MenuSave 规则不完整（perms 重复未校验）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysMenuController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/MenuCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysMenuServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysMenuMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysMenuMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 MenuCreateCommand；校验规则集中到应用服务。 |
| 最小验证方式 | 用例：F 挂子级拒绝、外链非 http/https 拒绝、routeName 唯一；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位036；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-037　PUT /system/menu

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL03(定位037) |
| 当前 Controller | com.futurefab.system.controller.SysMenuController#edit |
| 当前实际路由 | PUT /system/menu |
| 当前权限 | system:menu:edit（一致） |
| 冻结权限 | system:menu:edit |
| 当前请求类型 | @Validated SysMenu 实体直收 |
| 冻结 Request | MenuUpdateCommand |
| 当前响应类型 | toAjax(int)/error 字符串 |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysMenuService#updateMenu |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysMenuMapper#updateMenu, checkMenuNameUnique, selectMenusByPathOrRouteName（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | SysMenuController.edit→同 add 校验+menuId==parentId 自环检查→updateMenu(仅主键 WHERE，无 @Transactional、无子树路径级联) |
| 已确认兼容调用方 | api/system/menu.js:updateMenu:46 |
| 主要差距 | 深层移父环检测缺失（只防直接自环，契约 TREE_CYCLE）；有子节点不能改 F 规则缺失；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysMenuController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/MenuUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysMenuServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysMenuMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysMenuMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 MenuUpdateCommand；祖先链环检测。 |
| 最小验证方式 | 用例：A→B→A 环拒绝、有子改 F 拒绝；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位037；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-039　GET /system/role/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL05(定位039) |
| 当前 Controller | com.futurefab.system.controller.SysRoleController#list |
| 当前实际路由 | GET /system/role/list |
| 当前权限 | system:role:list（一致） |
| 冻结权限 | system:role:list |
| 当前请求类型 | SysRole query 绑定（beginTime/endTime via params Map）；operatorKeyword/status 缺 |
| 冻结 Request | RoleListQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysRole> 实体}，无 dataScopes[]/deptIds[]/menuIds[]/assignedUserCount/audit/allowedActions |
| 冻结 Response | List<RoleRow> |
| 当前 Service 调用 | ISysRoleService#selectRoleList（@DataScope(deptAlias="d")） |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysRoleMapper#selectRoleList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | list→startPage→selectRoleList(del_flag=0, order by role_sort) |
| 已确认兼容调用方 | api/system/role.js:listRole:4、views/system/role/index.vue |
| 主要差距 | 契约响应 List<RoleRow>（行含关系集合与 assignedUserCount）——需批量装配；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；operatorKeyword≤50/status 过滤缺失 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysRoleController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/RoleListQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/RoleRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysRoleServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysRoleMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysRoleMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 RoleListQuery/RoleRow；一次 join/批量装配防 N+1。 |
| 最小验证方式 | 用例：数据范围过滤（非超管仅可见范围行）、行字段快照；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位039；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-040　POST /system/role

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL06(定位040) |
| 当前 Controller | com.futurefab.system.controller.SysRoleController#add |
| 当前实际路由 | POST /system/role |
| 当前权限 | system:role:add（一致） |
| 冻结权限 | system:role:add |
| 当前请求类型 | @Validated SysRole 实体直收（menuIds 有、deptIds 实体字段） |
| 冻结 Request | RoleCreateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysRoleService#insertRole |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysRoleMapper#insertRole, batchRoleMenu(SysRoleMenuMapper), batchRoleDept(SysRoleDeptMapper), checkRoleNameUnique, checkRoleKeyUnique（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | add→checkRoleNameUnique/checkRoleKeyUnique→insertRole @Transactional→仅 insertRoleMenu（不写 sys_role_dept：deptIds 被静默丢弃） |
| 已确认兼容调用方 | api/system/role.js:addRole:21 |
| 主要差距 | roleKey 应服务端生成 role_+ID（当前客户端可传）、roleSort=1；dataScopes 非空 1–5 合法值、deptIds 选 2 非空校验缺失；菜单/范围可授予边界（ASSIGNMENT_DENIED）缺失；sys_role_data_scope 权威+data_scope 列投影：当前只写 sys_role.data_scope 列，role_dept 表完全不写——与冻结存储模型冲突；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysRoleController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/RoleCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysRoleServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysRoleMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysRoleMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 RoleCreateCommand；事务内写 role+role_menu+role_data_scope+role_dept 四表。 |
| 最小验证方式 | 用例：越权菜单授予拒绝、dataScope=2 无 deptIds 拒绝、roleKey 生成；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位040；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-041　PUT /system/role

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL07(定位041) |
| 当前 Controller | com.futurefab.system.controller.SysRoleController#edit |
| 当前实际路由 | PUT /system/role |
| 当前权限 | system:role:edit（一致） |
| 冻结权限 | system:role:edit |
| 当前请求类型 | @Validated SysRole 实体直收 |
| 冻结 Request | RoleUpdateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysRoleService#updateRole |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysRoleMapper#updateRole, batchRoleMenu(SysRoleMenuMapper), batchRoleDept(SysRoleDeptMapper), deleteRoleMenuByRoleId(SysRoleMenuMapper), deleteRoleDeptByRoleId(SysRoleDeptMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | edit→checkRoleAllowed(roleId=1)+checkRoleDataScope→updateRole @Transactional(role+role_menu 全删重建；不含 role_data_scope/role_dept——旧 PUT /role/dataScope 才写 role_dept) |
| 已确认兼容调用方 | api/system/role.js:updateRole:30；views/role/authUser/selectUser(授权用户路径为 authUser/*，另行收口) |
| 主要差距 | 契约要求主表/菜单/范围/部门一次提交同事务——现拆在 PUT /role 与 PUT /role/dataScope 两个入口（§22 要求旧入口调同一应用服务）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计；menuIds 可授予边界缺失 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysRoleController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/RoleUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysRoleServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysRoleMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysRoleMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 RoleUpdateCommand；/role/dataScope 旁路改为调用同一应用服务（旁路收口任务，与 041 同文件）。 |
| 最小验证方式 | 用例：一次提交四表一致、dataScope 修改撤权生效、版本冲突；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位041；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-042　PUT /system/role/changeStatus

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL08(定位042) |
| 当前 Controller | com.futurefab.system.controller.SysRoleController#changeStatus |
| 当前实际路由 | PUT /system/role/changeStatus |
| 当前权限 | system:role:edit（一致） |
| 冻结权限 | system:role:edit |
| 当前请求类型 | SysRole 实体直收（仅用 roleId/status） |
| 冻结 Request | RoleStatusChangeCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysRoleService#updateRoleStatus |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysRoleMapper#updateRole, countUserRoleByRoleId(SysUserRoleMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | changeStatus→checkRoleAllowed+checkRoleDataScope→updateRoleStatus(无 @Transactional、无 countUserRoleByRoleId)——停用仍关联用户的角色不被拒绝 |
| 已确认兼容调用方 | api/system/role.js:changeRoleStatus:48 |
| 主要差距 | 契约：关联未删除用户（含停用）→REFERENCE_EXISTS；绑定与停用同守卫防竞态——全部缺失；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysRoleController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/RoleStatusChangeCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysRoleServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysRoleMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysRoleMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 RoleStatusChangeCommand；禁用前事务内 count 关联用户。 |
| 最小验证方式 | 用例：有用户关联禁用被拒、并发绑定竞态；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位042；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#23-模块事务审计与状态联动；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-043　GET /system/role/roleUsers

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL09(定位043) |
| 当前 Controller | com.futurefab.system.controller.SysRoleController#roleUsers |
| 当前实际路由 | GET /system/role/roleUsers |
| 当前权限 | system:role:list；冻结"+角色可见"（角色数据范围未校验） |
| 冻结权限 | system:role:list且角色可见 |
| 当前请求类型 | @RequestParam roleId+pageNum/pageSize（绕过 startPage 直调 PageHelper） |
| 冻结 Request | RoleMemberQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysUser> 实体}+在线状态（Redis KEYS 全库扫描）+逐行 selectRolesByUserId（N+1） |
| 冻结 Response | PageResult<RoleMemberRow> |
| 当前 Service 调用 | ISysUserService#selectAllocatedList（@DataScope） |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#selectAllocatedList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | roleUsers→startPage(手工)→selectAllocatedList→redis keys(login_tokens:*)→N+1 roles |
| 已确认兼容调用方 | api/system/role.js:getRoleUsers:122 |
| 主要差距 | 契约 PageResult<RoleMemberRow>（Person 全字段+assignedAt，关联时间倒序、未知置末）——现按用户表排序，无 assignedAt；roleId 目标角色可见性校验缺失；Redis KEYS 全库扫描性能/安全 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysRoleController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/RoleMemberQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/RoleMemberRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 RoleMemberQuery/RoleMemberRow；assignedAt 需 sys_user_role.create_time（基线列是否存在需核对字段字典，实现前确认）。 |
| 最小验证方式 | 用例：越权角色 404/403、排序与 assignedAt null 置末；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位043；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-044　DELETE /system/role/{roleIds}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL10(定位044) |
| 当前 Controller | com.futurefab.system.controller.SysRoleController#remove |
| 当前实际路由 | DELETE /system/role/{roleIds} |
| 当前权限 | system:role:remove（一致） |
| 冻结权限 | system:role:remove |
| 当前请求类型 | @PathVariable Long[]（1–100 未校验） |
| 冻结 Request | RoleDeleteCommand |
| 当前响应类型 | toAjax(int)/异常字符串 |
| 冻结 Response | DeleteResult |
| 当前 Service 调用 | ISysRoleService#deleteRoleByIds |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysRoleMapper#deleteRoleByIds, deleteRoleMenu(SysRoleMenuMapper), deleteRoleDept(SysRoleDeptMapper), countUserRoleByRoleId(SysUserRoleMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | remove→@Transactional 逐项 checkRoleAllowed+checkRoleDataScope+countUserRoleByRoleId>0 抛错→role_menu/role_dept 物理删→sys_role 软删 |
| 已确认兼容调用方 | api/system/role.js:delRole:61 |
| 主要差距 | 关联用户整批拒绝已有 ✓（异常文案非 REFERENCE_EXISTS 契约码）；CTRL-BATCH 稳定顺序加锁/全量预验未显式（现逐项循环校验=等效全量，需锁顺序）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysRoleController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/RoleDeleteCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysRoleServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysRoleMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysRoleMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 RoleDeleteCommand；按 roleId 升序加锁。 |
| 最小验证方式 | 用例：任一角色有关系整批拒绝、菜单/范围清理与软删原子；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位044；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-045　GET /system/menu/{menuId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL11(定位045) |
| 当前 Controller | com.futurefab.system.controller.SysMenuController#getInfo |
| 当前实际路由 | GET /system/menu/{menuId} |
| 当前权限 | system:menu:query（一致） |
| 冻结权限 | system:menu:query |
| 当前请求类型 | @PathVariable Long |
| 冻结 Request | MenuDetailQuery |
| 当前响应类型 | AjaxResult.data=SysMenu 实体（无 del_flag 过滤、无 parent 信息） |
| 冻结 Response | MenuDetailView |
| 当前 Service 调用 | ISysMenuService#selectMenuById |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysMenuMapper#selectMenuById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→selectMenuById |
| 已确认兼容调用方 | api/system/menu.js:getMenu:13 |
| 主要差距 | 响应应 MenuDetailView(children 空数组+audit/allowedActions)；MenuRow 已在 vo/m01；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysMenuController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/MenuDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/MenuDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysMenuServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysMenuMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysMenuMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 MenuDetailQuery/MenuDetailView。 |
| 最小验证方式 | 用例：字段快照、软删/停用行语义确认；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位045；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-046　GET /system/role/{roleId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | ACL12(定位046) |
| 当前 Controller | com.futurefab.system.controller.SysRoleController#getInfo |
| 当前实际路由 | GET /system/role/{roleId} |
| 当前权限 | system:role:query（一致） |
| 冻结权限 | system:role:query |
| 当前请求类型 | @PathVariable Long |
| 冻结 Request | RoleDetailQuery |
| 当前响应类型 | AjaxResult.data=SysRole 实体（不回填 menuIds/deptIds；selectRoleById XML 缺 del_flag=0 可查已删角色） |
| 冻结 Response | RoleDetailView |
| 当前 Service 调用 | ISysRoleService#selectRoleById |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysRoleMapper#selectRoleById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→checkRoleDataScope→selectRoleById；前端另调 /menu/roleMenuTreeselect、/role/deptTree 拼图 |
| 已确认兼容调用方 | api/system/role.js:getRole:13、deptTreeSelect:114、api/menu.js:roleMenuTreeselect:29 |
| 主要差距 | 契约 data RoleRow 需合并 role_menu/role_data_scope/role_dept 为 menuIds[]/dataScopes[]/deptIds[]——现三入口分散；软删可查；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysRoleController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/RoleDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/RoleDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysRoleServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysRoleMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysRoleMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 RoleDetailQuery/RoleDetailView；一次装配。前端编辑页同批改单请求。 |
| 最小验证方式 | 用例：数组完整与关系表一致、已删角色 404；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位046；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#19-功能与角色接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-048　GET /system/user/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR01(定位048) |
| 当前 Controller | com.futurefab.system.controller.SysUserController#list |
| 当前实际路由 | GET /system/user/list |
| 当前权限 | system:user:list（一致）+@DataScope 已有 |
| 冻结权限 | system:user:list |
| 当前请求类型 | SysUser query 绑定（beginTime/endTime/deptId/phonenumber 等）；keyword/loginBegin~End/minLoginCount 等契约参数缺 |
| 冻结 Request | UserPageQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysUser>}（列清单不含 password，含 email/解密手机号；无 loginCount/sessionVersion/allowedActions/audit） |
| 冻结 Response | PageResult<UserRow> |
| 当前 Service 调用 | ISysUserService#selectUserList（@DataScope(deptAlias="d",userAlias="u")） |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#selectUserList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | list→startPage→preparePhoneQuery→selectUserList(XML:64+${params.dataScope}) |
| 已确认兼容调用方 | api/system/user.js:listUser:5、views/system/user/index.vue |
| 主要差距 | 契约 UserPageQuery 参数集（keyword≤50、登录时间左闭右开、min/maxLoginCount、includeDescendants）全部缺失；行应 UserRow（loginIp/loginCount/sessionVersion/audit/allowedActions）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/UserPageQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/UserRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 UserPageQuery/UserRow；数据权限保持 @DataScope 注入路径，不放开 params 自由 Map。 |
| 最小验证方式 | 用例：min>max 拒绝、时间左闭右开、includeDescendants、行字段快照；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位048；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-049　GET /system/user/{userId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR02(定位049) |
| 当前 Controller | com.futurefab.system.controller.SysUserController#getInfo |
| 当前实际路由 | GET /system/user/{userId}（同 handler 还映射 "/" 根路径变体） |
| 当前权限 | system:user:query+checkUserDataScope（目标数据权限已有，一致） |
| 冻结权限 | system:user:query及目标用户数据权限 |
| 当前请求类型 | @PathVariable(required=false) Long |
| 冻结 Request | UserDetailQuery |
| 当前响应类型 | AjaxResult.data=SysUser 实体——selectUserVo 含 u.password 哈希直接序列化（SysUser.password 无 @JsonIgnore）+postIds/roleIds/roles/posts |
| 冻结 Response | UserDetailView |
| 当前 Service 调用 | ISysUserService#selectUserById |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#selectUserById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→checkUserDataScope→selectUserById(XML:139)+回填 authorizedLabIds/labGroupIds（本地 sys_user_lab 读） |
| 已确认兼容调用方 | api/system/user.js:getUser:14（编辑对话框） |
| 主要差距 | P0：password 哈希泄漏到浏览器；authorizedLabIds 直读 M02 拥有表 sys_user_lab——违反"PKG-01 M01 不得写/直连 sys_user_lab"，契约要求经 M02 AUTH-I01 prepareUserEdit；缺 labAuthorizationVersion/credentialVersion/notify*/avatarPreset 等 UserDetail 字段；"/" 根路径变体须收敛（非数字 /user/xxx 400、/user/ 空命中 userId=null→isAdmin 拆箱 NPE） |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/UserDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/UserDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 UserDetailQuery/UserDetailView；授权实验室改调 LabAuthorizationPort。 |
| 最小验证方式 | 用例：响应无 password 字段（JSON 快照断言）、越权 403、phonenumber 仅编辑权限解密；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位049；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-050　POST /system/user

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR03(定位050) |
| 当前 Controller | com.futurefab.system.controller.SysUserController#add |
| 当前实际路由 | POST /system/user |
| 当前权限 | system:user:add（一致）+checkDeptDataScope/checkRoleDataScope 已有 |
| 冻结权限 | system:user:add |
| 当前请求类型 | @Validated SysUser 实体直收——password 由前端传入、postIds/roles 等自由绑定 |
| 冻结 Request | UserCreateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysUserService#insertUser |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#insertUser, batchUserRole(SysUserRoleMapper), batchUserPost(SysUserPostMapper), deleteSysGroupMemberByUserId(SysGroupMemberMapper), batchInsertSysGroupMembersByUserId(SysGroupMemberMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | add→唯一性×3→insertUser @Transactional(雪花/加密手机号/sys.user.initPassword 配置生成初始口令/roles/posts/labs/groups 多 Mapper 直写) |
| 已确认兼容调用方 | api/system/user.js:addUser:22；内部 registerUser/importUser 同调 userMapper.insertUser（旧注册/导入旁路 §22 收口） |
| 主要差距 | userName 2–20 正则、deptId 必填、roleIds 非空、notifyInsite 固定 1 等 UserSave 规则不完整；未知字段（password/status/delFlag）不拒绝；实验室授权应经 M02 replaceUserLabs 同事务（现直写 sys_user_lab）；初始口令 123456 同事务写密码历史/认证状态缺失；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/UserCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 UserCreateCommand；register/import 旁路必须改走同一应用服务或禁用。 |
| 最小验证方式 | 用例：password 字段提交即 READ_ONLY_FIELD/INPUT_INVALID、roleIds 空拒绝、原子回滚；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位050；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-051　PUT /system/user

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR04(定位051) |
| 当前 Controller | com.futurefab.system.controller.SysUserController#edit |
| 当前实际路由 | PUT /system/user |
| 当前权限 | system:user:edit+checkUserAllowed+checkUserDataScope（目标可管理已有，一致） |
| 冻结权限 | system:user:edit及可管理目标 |
| 当前请求类型 | @Validated SysUser 实体直收（userName 可提交、postIds/sex/avatar 自由绑定） |
| 冻结 Request | UserUpdateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysUserService#updateUser |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#updateUser, batchUserRole(SysUserRoleMapper), deleteUserPostByUserId(SysUserPostMapper), batchUserPost(SysUserPostMapper), deleteSysGroupMemberByUserId(SysGroupMemberMapper), batchInsertSysGroupMembersByUserId(SysGroupMemberMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | edit→checkUserAllowed/checkUserDataScope+唯一性→updateUser @Transactional(先删后插 role/post；不写岗位保留逻辑差异) |
| 已确认兼容调用方 | api/system/user.js:updateUser:31 |
| 主要差距 | P0 隐患：updateUser 不做 encryptPassword 且 SysUser.password 若随请求体回传，XML:212 条件成立会把客户端值原样写库（口令哈希旁路）；userName 只读（Q01）、未知字段拒绝缺失；岗位关系"保留未编辑"与先删后建冲突；authorizationChanges 仅显式修改（M02-Q09）缺失 |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/UserUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 UserUpdateCommand；先堵 password 直传（Command 无该字段即消除）。 |
| 最小验证方式 | 用例：提交 userName/password/postIds 拒绝、并发改密不覆盖；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位051；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-052　PUT /system/user/changeStatus

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR05(定位052) |
| 当前 Controller | com.futurefab.system.controller.SysUserController#changeStatus |
| 当前实际路由 | PUT /system/user/changeStatus |
| 当前权限 | system:user:edit（一致） |
| 冻结权限 | system:user:edit |
| 当前请求类型 | SysUser 实体直收（userId+status） |
| 冻结 Request | UserStatusChangeCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysUserService#updateUserStatus |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#updateUserStatus（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | changeStatus→updateUserStatus(仅 UPDATE status WHERE 主键)——无 checkUserAllowed、无自身检查、无会话撤销 |
| 已确认兼容调用方 | api/system/user.js:changeUserStatus:61 |
| 主要差距 | 自身/受保护账号拒绝缺失（现无 checkUserAllowed）；禁用撤会话+sessionVersion 递增缺失（I05）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/UserStatusChangeCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 UserStatusChangeCommand；禁用联动 revokeSession(LOGOUT/DISABLE)。 |
| 最小验证方式 | 用例：禁自身 403、禁超管 403、禁用后旧令牌 401；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位052；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#23-模块事务审计与状态联动；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-053　DELETE /system/user/{userIds}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR06(定位053) |
| 当前 Controller | com.futurefab.system.controller.SysUserController#remove |
| 当前实际路由 | DELETE /system/user/{userIds} |
| 当前权限 | system:user:remove（一致）+自身检查已有+checkUserAllowed/checkUserDataScope 循环内 |
| 冻结权限 | system:user:remove |
| 当前请求类型 | @PathVariable Long[]（1–100 未校验） |
| 冻结 Request | UserDeleteCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | DeleteResult |
| 当前 Service 调用 | ISysUserService#deleteUserByIds |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#deleteUserByIds, deleteUserRole(SysUserRoleMapper), deleteUserPost(SysUserPostMapper), deleteSysUserLabByUserIds(SysUserLabMapper), deleteSysGroupMemberByUserIds(SysGroupMemberMapper)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | remove→@Transactional 循环校验→级联删 role/post/lab(sys_user_lab 直写)/group member→del_flag=2 |
| 已确认兼容调用方 | api/system/user.js:delUser:40 |
| 主要差距 | 不清 sys_group_leader 负责人关系（数据完整性缺陷）；M02-Q10 实验室管理范围/M02-Q11 负责人关系校验缺失（应经 LabAuthorizationPort）；直写 M02 拥有表 sys_user_lab；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/UserDeleteCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 UserDeleteCommand；CTRL-BATCH 全量预验后整批执行。 |
| 最小验证方式 | 用例：负责人关系未清即拒绝、范围不足 ASSIGNMENT_DENIED、历史不删；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位053；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-055　GET /system/user/profile

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR08(定位055) |
| 当前 Controller | com.futurefab.system.controller.SysProfileController#profile |
| 当前实际路由 | GET /system/user/profile |
| 当前权限 | 无注解+本人会话（AUTHENTICATED_SELF 一致） |
| 冻结权限 | AUTHENTICATED_SELF |
| 当前请求类型 | 无参（取会话用户名） |
| 冻结 Request | ProfileQuery |
| 当前响应类型 | AjaxResult.data=完整 SysUser 实体（selectUserVo 含 password 哈希）+roleGroup/postGroup 字符串 |
| 冻结 Response | ProfileView |
| 当前 Service 调用 | ISysUserService#selectUserByUserName（无 @DataScope，本人读取合理） |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#selectUserByUserName（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | profile→selectUserByUserName→role/post group 拼接 |
| 已确认兼容调用方 | api/system/user.js:getUserProfile:74、views/system/user/profile |
| 主要差距 | P0：password 哈希泄漏；响应应 ProfileView 白名单（notify*/avatarPreset/avatarUrl/roles:RoleLabel[]/deptName）；roleGroup/postGroup 非契约；phonenumber 解密口径与脱敏规则需按契约 |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysProfileController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ProfileQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/ProfileView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ProfileQuery/ProfileView（RoleLabelView/AuditView 可复用）。 |
| 最小验证方式 | 用例：JSON 无 password/delFlag/params 字段、RoleLabel 数组结构；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位055；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-056　PUT /system/user/profile

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | USR09(定位056) |
| 当前 Controller | com.futurefab.system.controller.SysProfileController#updateProfile |
| 当前实际路由 | PUT /system/user/profile |
| 当前权限 | 本人会话 ✓（目标=自身，无需功能权限，一致） |
| 冻结权限 | AUTHENTICATED_SELF |
| 当前请求类型 | SysUser 实体直收——Service 仅取 nickName/email/phonenumber/sex 四字段，其余忽略但不拒绝 |
| 冻结 Request | ProfileUpdateCommand |
| 当前响应类型 | success() 无 data=W |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysUserService#updateUserProfile→userMapper.updateUser |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysUserMapper#updateUser（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | updateProfile→checkPhoneUnique/checkEmailUnique→updateUserProfile（updateUser XML 条件带 cached password 回写同哈希） |
| 已确认兼容调用方 | api/system/user.js:updateUserProfile:82 |
| 主要差距 | 契约白名单 email/phonenumber/notifyInsite=1/notifySms/notifyEmail/avatarPreset，且 nickName 等未知字段拒绝——现恰好相反（允许 nickName/sex，忽略通知偏好/头像预设）；notify*/avatarPreset 无存储与写路径确认（字段字典有列，实现时补）；手机号查重加密；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysProfileController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ProfileUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysUserServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysUserMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysUserMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ProfileUpdateCommand；avatarPreset 映射现有 avatar 不改 sex。 |
| 最小验证方式 | 用例：nickName 提交拒绝、notifyInsite≠1 拒绝、大陆 11 位手机号校验；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位056；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#20-用户与个人资料接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-058　GET /system/dict/type/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC01(定位058) |
| 当前 Controller | com.futurefab.system.controller.SysDictTypeController#list |
| 当前实际路由 | GET /system/dict/type/list |
| 当前权限 | system:dict:list（一致） |
| 冻结权限 | system:dict:list |
| 当前请求类型 | SysDictType query 绑定+params[beginTime/endTime]（自由 Map 参数） |
| 冻结 Request | DictTypePageQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysDictType>}——XML 无 ORDER BY、无 del_flag 过滤、无 update_by/update_time 列 |
| 冻结 Response | PageResult<DictTypeRow> |
| 当前 Service 调用 | ISysDictTypeService#selectDictTypeList |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictTypeMapper#selectDictTypeList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | list→startPage→selectDictTypeList |
| 已确认兼容调用方 | api/system/dict/type.js:listType:4 |
| 主要差距 | 排序规则缺失（updateTime 空则 createTime 倒序）；del_flag 列存在未过滤（uk_m01_dict_name 生成列已按 active 唯一）；行应 DictTypeRow（isEditable/audit/allowedActions）——实体缺 createTime 外的审计列；F 日期对（params Map 注入）不合规 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictTypeController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictTypePageQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/DictTypeRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictTypeServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictTypeMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictTypeMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictTypePageQuery/DictTypeRow。 |
| 最小验证方式 | 用例：排序断言、软删不可见、params 自由键拒绝；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位058；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-059　POST /system/dict/type

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC02(定位059) |
| 当前 Controller | com.futurefab.system.controller.SysDictTypeController#add |
| 当前实际路由 | POST /system/dict/type |
| 当前权限 | system:dict:add（一致） |
| 冻结权限 | system:dict:add |
| 当前请求类型 | @Validated SysDictType 实体直收 |
| 冻结 Request | DictTypeCreateCommand |
| 当前响应类型 | toAjax(int)/error 字符串 |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysDictTypeService#insertDictType |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictTypeMapper#insertDictType, checkDictTypeUnique, selectDictNameCount（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | add→checkDictTypeUnique+checkDictNameUnique→insertDictType（XML 硬插 is_editable=#{isEditable}→null 写 NULL） |
| 已确认兼容调用方 | api/system/dict/type.js:addType:22 |
| 主要差距 | isEditable 未服务端设 Y（客户端可控）；dictType 默认 custom_+dictId、值域校验缺失；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictTypeController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictTypeCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictTypeServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictTypeMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictTypeMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictTypeCreateCommand。 |
| 最小验证方式 | 用例：isEditable 客户端值被忽略恒 Y、名称/编码全局唯一；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位059；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-060　PUT /system/dict/type

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC03(定位060) |
| 当前 Controller | com.futurefab.system.controller.SysDictTypeController#edit |
| 当前实际路由 | PUT /system/dict/type |
| 当前权限 | system:dict:edit（一致） |
| 冻结权限 | system:dict:edit |
| 当前请求类型 | @Validated SysDictType 实体直收 |
| 冻结 Request | DictTypeUpdateCommand |
| 当前响应类型 | toAjax(int)/error 字符串 |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysDictTypeService#updateDictType |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictTypeMapper#updateDictType, updateDictDataType(SysDictDataMapper), checkDictTypeUnique（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | edit→双唯一校验→updateDictType @Transactional(updateDictDataType 级联 sys_dict_data+updateDictType+缓存重建) |
| 已确认兼容调用方 | api/system/dict/type.js:updateType:31 |
| 主要差距 | 内置只读保护缺失（不校验 isEditable=N 可改任意系统类型）；DICT_KEY_IN_USE 引用检查无已登记 M02/M04 Port（BLK-03）；updateDictDataType XML 不带 del_flag 条件；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictTypeController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictTypeUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictTypeServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictTypeMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictTypeMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictTypeUpdateCommand；显示名与存储编码区分（改名场景）。 |
| 最小验证方式 | 用例：isEditable=N 改键拒绝、级联更新同事务、固定字典键引用拒绝（BLK-03 决策后补）；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位060；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-061　GET /system/dict/type/{dictId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC04(定位061) |
| 当前 Controller | com.futurefab.system.controller.SysDictTypeController#getInfo |
| 当前实际路由 | GET /system/dict/type/{dictId} |
| 当前权限 | system:dict:query（一致） |
| 冻结权限 | system:dict:query |
| 当前请求类型 | @PathVariable Long |
| 冻结 Request | DictTypeDetailQuery |
| 当前响应类型 | AjaxResult.data=SysDictType 实体（无 del_flag 过滤） |
| 冻结 Response | DictTypeDetailView |
| 当前 Service 调用 | ISysDictTypeService#selectDictTypeById |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictTypeMapper#selectDictTypeById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→selectDictTypeById |
| 已确认兼容调用方 | api/system/dict/type.js:getType:13 |
| 主要差距 | 应 DictTypeDetailView 契约 DTO；软删可查 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictTypeController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictTypeDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/DictTypeDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictTypeServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictTypeMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictTypeMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictTypeDetailQuery/DictTypeDetailView。 |
| 最小验证方式 | 用例：404 语义、字段快照；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位061；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-062　GET /system/dict/data/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC05(定位062) |
| 当前 Controller | com.futurefab.system.controller.SysDictDataController#list |
| 当前实际路由 | GET /system/dict/data/list |
| 当前权限 | system:dict:list（一致） |
| 冻结权限 | system:dict:list |
| 当前请求类型 | SysDictData query 绑定（dictType 可选——契约必填）+searchKey/params |
| 冻结 Request | DictDataPageQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysDictData>}（含 delFlag/parentValue 连表列；ORDER BY parent_code,dict_sort——契约 createTime/ID 倒序） |
| 冻结 Response | PageResult<DictDataRow> |
| 当前 Service 调用 | ISysDictDataService#selectDictDataList |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictDataMapper#selectDictDataList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | list→startPage→selectDictDataList(XML:37-55, d.del_flag=0) |
| 已确认兼容调用方 | api/system/dict/data.js:listData:4 |
| 主要差距 | dictType 必填、keyword/parentCode/parentKeyword/status 参数集缺失；params/searchKey 自由 Map 不合规；排序不符；行应 DictDataRow（parentLabel/dictLevel/isEditable/isDefault） |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictDataController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictDataPageQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/DictDataRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictDataServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictDataMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictDataMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictDataPageQuery/DictDataRow。 |
| 最小验证方式 | 用例：dictType 缺失 INPUT_INVALID、层级列一致；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位062；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-063　POST /system/dict/data

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC06(定位063) |
| 当前 Controller | com.futurefab.system.controller.SysDictDataController#add |
| 当前实际路由 | POST /system/dict/data |
| 当前权限 | system:dict:add（一致） |
| 冻结权限 | system:dict:add |
| 当前请求类型 | SysDictData 实体直收（isDefault/dictLevel/parentCode 客户端可注入） |
| 冻结 Request | DictDataCreateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysDictDataServiceImpl#insertDictData |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictDataMapper#insertDictData, countDictValueUnique, countDictLabelUnique（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | add→补 dictCode/isEditable=Y/delFlag=0→prepareDictLevel(按 parentValue 回填)→checkDictLabelUnique+checkSameLevelDictValue→insert |
| 已确认兼容调用方 | api/system/dict/data.js:addData:76 |
| 主要差距 | isDefault/dictLevel 应服务端推导并拒绝提交（现实体可带）；类型内值唯一 vs 同级唯一口径（DB 生成列 uk_m01_dict_value 为类型内）需统一到契约；二级不允许子级为隐式（父级查找限定 parent_code=0）→错误码非契约语义；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictDataController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictDataCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictDataServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictDataMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictDataMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictDataCreateCommand。 |
| 最小验证方式 | 用例：提交 isDefault 拒绝、类型内重复值 CODE_CONFLICT；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位063；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-064　PUT /system/dict/data

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC07(定位064) |
| 当前 Controller | com.futurefab.system.controller.SysDictDataController#edit |
| 当前实际路由 | PUT /system/dict/data |
| 当前权限 | system:dict:edit（一致） |
| 冻结权限 | system:dict:edit |
| 当前请求类型 | SysDictData 实体直收 |
| 冻结 Request | DictDataUpdateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysDictDataServiceImpl#updateDictData |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictDataMapper#updateDictData, countDictValueUnique, selectRootDictDataByValue（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | edit→isEditable=N 只读保护✓→双校验→updateDictData+缓存刷新 |
| 已确认兼容调用方 | api/system/dict/data.js:updateData:85 |
| 主要差距 | 自定义值改动的消费引用检查（含 M04 型号字典）无 Port（BLK-03）；编辑保留 isDefault 原值（现实体直收可覆盖）；二级子级检查隐式；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictDataController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictDataUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictDataServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictDataMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictDataMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictDataUpdateCommand。 |
| 最小验证方式 | 用例：isEditable=N 拒绝、isDefault 只读；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位064；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-065　GET /system/dict/data/{dictCode}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC08(定位065) |
| 当前 Controller | com.futurefab.system.controller.SysDictDataController#getInfo |
| 当前实际路由 | GET /system/dict/data/{dictCode} |
| 当前权限 | system:dict:query（一致） |
| 冻结权限 | system:dict:query |
| 当前请求类型 | @PathVariable Long |
| 冻结 Request | DictDataDetailQuery |
| 当前响应类型 | AjaxResult.data=SysDictData 实体（XML 无 del_flag 过滤） |
| 冻结 Response | DictDataDetailView |
| 当前 Service 调用 | ISysDictDataServiceImpl#selectDictDataById |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictDataMapper#selectDictDataById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→selectDictDataById |
| 已确认兼容调用方 | api/system/dict/data.js:getData:13 |
| 主要差距 | 应 DictDataDetailView；软删可查 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictDataController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictDataDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/DictDataDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictDataServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictDataMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictDataMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictDataDetailQuery/DictDataDetailView。 |
| 最小验证方式 | 用例：404 语义；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位065；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-066　GET /system/dict/data/type/{dictType}/tree

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | DIC09(定位066) |
| 当前 Controller | com.futurefab.system.controller.SysDictDataController#dictTypeTree |
| 当前实际路由 | GET /system/dict/data/type/{dictType}/tree |
| 当前权限 | 无 @RequiresPermissions（仅网关登录态）——冻结"已认证且业务使用该字典或 system:dict:query"无代码化实现 |
| 冻结权限 | 已认证且业务使用该字典或system:dict:query |
| 当前请求类型 | @PathVariable String；includeDisabled 参数缺失 |
| 冻结 Request | DictDataTreeQuery |
| 当前响应类型 | AjaxResult.data=内部嵌套类 SysDictDataNode 树（缓存路径 selectDictDataByType 固定过滤 status=0——includeDisabled=true 无从取停用项） |
| 冻结 Response | List<DictOptionView> |
| 当前 Service 调用 | ISysDictTypeService#selectDictDataByType |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysDictDataMapper#selectDictDataByType（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | dictTypeTree→DictUtils 缓存→本地构树 |
| 已确认兼容调用方 | api/system/dict/data.js:getDictTree:30（业务下拉广泛使用） |
| 主要差距 | includeDisabled 语义与缓存恒过滤冲突需专用非缓存查询路径；响应应 List<DictOptionView>{id,value,label,parentCode,level,disabled,children}；"业务使用该字典"白名单校验规则无落点 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysDictDataController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/DictDataTreeQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/DictOptionView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysDictTypeServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysDictDataMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysDictDataMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 DictDataTreeQuery/DictOptionView；权限按契约补代码（编辑上下文 allow true）。 |
| 最小验证方式 | 用例：停用项 disabled=true 不入新选项、includeDisabled 仅编辑上下文；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位066；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-067　GET /system/config/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | CFG01(定位067) |
| 当前 Controller | com.futurefab.system.controller.SysConfigController#list |
| 当前实际路由 | GET /system/config/list |
| 当前权限 | system:config:list（Q12 保持现状，一致） |
| 冻结权限 | system:config:list |
| 当前请求类型 | SysConfig query 绑定+params；configType 可选过滤缺 |
| 冻结 Request | ConfigPageQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysConfig>}，configValue 原文全量返回 |
| 冻结 Response | PageResult<ConfigRow> |
| 当前 Service 调用 | ISysConfigService#selectConfigList |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysConfigMapper#selectConfigList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | list→startPage→selectConfigList(XML:41-60 无 ORDER BY) |
| 已确认兼容调用方 | api/system/config.js:listConfig:4 |
| 主要差距 | 敏感值脱敏缺失：契约 sensitive/configured 标记且敏感项 configValue=null——现原文（P1）；排序缺失；行应 ConfigRow |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysConfigController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ConfigPageQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/ConfigRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysConfigServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysConfigMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysConfigMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ConfigPageQuery/ConfigRow；一般敏感键判定依赖注册机制（BLK-04b 未冻结，先留脱敏接口位并 fail-closed）；四个密码政策受保护键按 BLK-04a 直接标注。 |
| 最小验证方式 | 用例：敏感键行 configValue=null+configured=true；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位067；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-068　POST /system/config

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | CFG02(定位068) |
| 当前 Controller | com.futurefab.system.controller.SysConfigController#add |
| 当前实际路由 | POST /system/config |
| 当前权限 | system:config:add（一致） |
| 冻结权限 | system:config:add |
| 当前请求类型 | @Validated SysConfig 实体直收（configType 客户端可带） |
| 冻结 Request | ConfigCreateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysConfigService#insertConfig |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysConfigMapper#insertConfig, checkConfigKeyUnique（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | add→checkConfigKeyUnique→insertConfig+Redis |
| 已确认兼容调用方 | api/system/config.js:addConfig:30 |
| 主要差距 | configType 应服务端决定 N；configKey 格式（字母数字点下划线）校验；业务键先注册规则、四个密码政策键不得走通用新增（现可插入同名键再改 API09 语义）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysConfigController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ConfigCreateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysConfigServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysConfigMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysConfigMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ConfigCreateCommand。 |
| 最小验证方式 | 用例：政策键走通用新增拒绝；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位068；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-069　PUT /system/config

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | CFG03(定位069) |
| 当前 Controller | com.futurefab.system.controller.SysConfigController#edit |
| 当前实际路由 | PUT /system/config |
| 当前权限 | system:config:edit（一致） |
| 冻结权限 | system:config:edit |
| 当前请求类型 | @Validated SysConfig 实体直收（configKey 可提交） |
| 冻结 Request | ConfigUpdateCommand |
| 当前响应类型 | toAjax(int) |
| 冻结 Response | MutationResult |
| 当前 Service 调用 | ISysConfigService#updateConfig |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysConfigMapper#updateConfig, checkConfigKeyUnique（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | edit→checkConfigKeyUnique→updateConfig(旧 key 清缓存) |
| 已确认兼容调用方 | api/system/config.js:updateConfig:39 |
| 主要差距 | PUT 不可改键未强制；内置 configType=Y 项禁改缺失（selectConfigById 读了旧值但不判）；政策键转专用 API09 路由缺失；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysConfigController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ConfigUpdateCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysConfigServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysConfigMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysConfigMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ConfigUpdateCommand；四个密码政策受保护键已冻结（BLK-04a，转专用策略服务或拒绝）；其余受保护/敏感键清单以注册机制为准（BLK-04b 未冻结）。 |
| 最小验证方式 | 用例：改键拒绝、内置项拒绝、政策键转 API09；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位069；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-070　GET /system/config/{configId}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | CFG04(定位070) |
| 当前 Controller | com.futurefab.system.controller.SysConfigController#getInfo |
| 当前实际路由 | GET /system/config/{configId} |
| 当前权限 | 完全没有权限注解（任意登录用户枚举 configId 读全部参数原文）——冻结要求 system:config:query |
| 冻结权限 | system:config:query |
| 当前请求类型 | @PathVariable Long |
| 冻结 Request | ConfigDetailQuery |
| 当前响应类型 | AjaxResult.data=SysConfig 实体全字段（configValue 原文，含 sys.user.initPassword 等） |
| 冻结 Response | ConfigDetailView |
| 当前 Service 调用 | ISysConfigService#selectConfigById（走 selectConfig 通用查询） |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysConfigMapper#selectConfigById（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→selectConfigById |
| 已确认兼容调用方 | api/system/config.js:getConfig:13 |
| 主要差距 | P0 权限差异+敏感原文：补 @RequiresPermissions("system:config:query")+受保护项校验+脱敏（敏感仅 configured/sensitive 标记）；应 ConfigDetailView |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysConfigController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ConfigDetailQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/ConfigDetailView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysConfigServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysConfigMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysConfigMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ConfigDetailQuery/ConfigDetailView。此端点权限补上前禁止开放新页面。 |
| 最小验证方式 | 用例：无权限 403、敏感值不返回原文；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位070；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-071　DELETE /system/config/{configIds}

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | CFG05(定位071) |
| 当前 Controller | com.futurefab.system.controller.SysConfigController#remove |
| 当前实际路由 | DELETE /system/config/{configIds} |
| 当前权限 | system:config:remove（一致） |
| 冻结权限 | system:config:remove |
| 当前请求类型 | @PathVariable Long[]（1–100 未校验） |
| 冻结 Request | ConfigDeleteCommand |
| 当前响应类型 | toAjax(int)/异常字符串 |
| 冻结 Response | DeleteResult |
| 当前 Service 调用 | ISysConfigService#deleteConfigByIds |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysConfigMapper#deleteConfigByIds（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | remove→逐项 configType=Y 内置拒绝→物理 delete+缓存清 |
| 已确认兼容调用方 | api/system/config.js:delConfig:48 |
| 主要差距 | "已引用/敏感保留键拒绝"缺失（仅内置标志）——四个密码政策受保护键已冻结可直接实现（BLK-04a），其余敏感/保留键判定依赖注册机制（BLK-04b/04c 未冻结）；sys_config 无 del_flag：物理删即永久（契约 REFERENCE_EXISTS 前置必须足够强）；不读取 X-Request-Id/X-Management-Revision，无 requestId 幂等回执（sys_management_request）、无 managementRevision/乐观锁 CAS；未接入 SYSTEM 管理守卫与 SEC-I03 ManagementRevisionPort（写事务未锁 sys_management_revision 固定行）；成功外壳为 AjaxResult/R/TableDataInfo 自由结构，缺 requestId、managementRevision、allowedActions 等契约必备外壳字段；审计仅 @Log 注解异步操作日志，无同事务 sys_oper_log+sys_data_change_log 白名单字段审计 |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysConfigController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/ConfigDeleteCommand.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysConfigServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysConfigMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysConfigMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 ConfigDeleteCommand。 |
| 最小验证方式 | 用例：被业务引用键拒绝、批量整批原子；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位071；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#21-数据字典与参数接口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-072　GET /system/logininfor/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | LOG01(定位072) |
| 当前 Controller | com.futurefab.system.controller.SysLogininforController#list |
| 当前实际路由 | GET /system/logininfor/list |
| 当前权限 | system:logininfor:list——冻结"+超级管理员"强制缺失 |
| 冻结权限 | system:logininfor:list且超级管理员 |
| 当前请求类型 | SysLogininfor query 绑定+params[beginTime/endTime]；契约 ipaddr/userKeyword/clientKeyword/macAddress/status 参数集缺 |
| 冻结 Request | LoginLogPageQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysLogininfor>}——XML 仅 9 旧列（无 eventType/pc_name/request_id/user_id/nick_name），时间字符串闭区间比较（右端漏当天） |
| 冻结 Response | PageResult<LoginLogRow> |
| 当前 Service 调用 | ISysLogininforService#selectLogininforList |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysLogininforMapper#selectLogininforList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | list→startPage→selectLogininforList(order by info_id desc) |
| 已确认兼容调用方 | api/system/logininfor.js:4（views/system/logininfor 页） |
| 主要差距 | 超级管理员硬校验缺失（持权限码即可看全局登录日志）；eventType 区分登录/凭据挑战事件缺失→status=0 全计成功风险；契约 Query 参数集与左闭右开时间语义；排序应事件时间 DESC+主键 DESC |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysLogininforController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/LoginLogPageQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/LoginLogRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysLogininforServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysLogininforMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysLogininforMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 LoginLogPageQuery/LoginLogRow；写侧 eventType 列由 I 契约/LogAspect 供数（列存在性以开发基线为准，实现前核对 01-完整建表.sql）。 |
| 最小验证方式 | 用例：非超管 403、时间边界、eventType 行快照；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位072；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#22-日志查询、权限上下文与兼容入口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-073　GET /system/operlog/list

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | LOG02(定位073) |
| 当前 Controller | com.futurefab.system.controller.SysOperlogController#list |
| 当前实际路由 | GET /system/operlog/list |
| 当前权限 | system:operlog:list——冻结"+超级管理员"强制缺失 |
| 冻结权限 | system:operlog:list且超级管理员 |
| 当前请求类型 | SysOperLog query 绑定+params 时间+businessTypes；契约 userKeyword/operationKeyword 缺 |
| 冻结 Request | OperLogPageQuery |
| 当前响应类型 | TableDataInfo{rows=List<SysOperLog>}——operParam/jsonResult 原文全量返回（写入侧仅屏蔽 4 个 password 变体），无 nickName/deptName/requestId 装配确认 |
| 冻结 Response | PageResult<OperLogRow> |
| 当前 Service 调用 | ISysOperLogService#selectOperLogList |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysOperLogMapper#selectOperLogList（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | list→startPage→selectOperLogList(order by oper_id desc) |
| 已确认兼容调用方 | api/system/operlog.js 文件缺失但 views/system/operlog/index.vue:158 import 断链（前端需补建，本身即缺陷） |
| 主要差距 | 超级管理员硬校验缺失；operParam/jsonResult 展示侧脱敏/截断缺失（token/手机号等入参原文可回显）；契约参数集、排序 oper_time DESC |
| 风险等级 | P1 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysOperlogController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/OperLogPageQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/OperLogRow.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysOperLogServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysOperLogMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysOperLogMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 OperLogPageQuery/OperLogRow；同事务审计列（user_id/nick_name/request_id）依赖业务写实现补齐。 |
| 最小验证方式 | 用例：非超管 403、大字段截断标识、前端 import 链修复；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位073；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#22-日志查询、权限上下文与兼容入口；docs/详细设计/01-系统管理/详细设计.md#17-管理接口公共数据契约；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-075　GET /system/user/getInfo

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | SEC01(定位075) |
| 当前 Controller | com.futurefab.system.controller.SysUserController#getInfo |
| 当前实际路由 | GET /system/user/getInfo（@GetMapping("getInfo") 无权限注解） |
| 当前权限 | 登录态（AUTHENTICATED 一致） |
| 冻结权限 | AUTHENTICATED |
| 当前请求类型 | 无参 |
| 冻结 Request | CurrentIdentityQuery |
| 当前响应类型 | AjaxResult 顶层 key{user(缓存 SysUser 含 password 哈希),roles,permissions,pwdChrtype,isDefaultModifyPwd,isPasswordExpired}——非 data 对象 |
| 冻结 Response | CurrentIdentityView |
| 当前 Service 调用 | ISysPermissionService#getRolePermission/getMenuPermission + selectConfigByKey×4 |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysMenuMapper#selectMenuPermsByUserId, selectMenuPermsByRoleId(SysRoleMapper.selectRolePermissionByUserId)（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getInfo→(缓存 loginUser)→roles/permissions→config 提示字段→权限变更时 refreshToken |
| 已确认兼容调用方 | api/login.js:25 getInfo、store/modules/user.js（登录后首调）、permission.js 路由守卫 |
| 主要差距 | P0：password 哈希泄漏（缓存 SysUser 直接序列化）；结构破坏性变更：顶层→data CurrentIdentityView{user:ProfileView,roles:角色key[],permissions,permissionRevision,password:D1,allowedModules}；permissionRevision 与"当前权限而非缓存"语义（现读 token 缓存 loginUser.roles? 需改实时+I03 版本比对）；pwdChrtype 等遗留字段仅显示兼容 |
| 风险等级 | P0 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysUserController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/CurrentIdentityQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/CurrentIdentityView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysPermissionServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysMenuMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysMenuMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 CurrentIdentityQuery/CurrentIdentityView；前端 store 同批升级。SEC-I01 ActorContextPort 提供 actor 上下文。 |
| 最小验证方式 | 用例：无 password 字段、permissionRevision 变更实时生效、撤权后 403；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位075；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#22-日志查询、权限上下文与兼容入口；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

### M01-076　GET /system/menu/getRouters

| 字段 | 内容 |
| --- | --- |
| 业务契约编号 | SEC02(定位076) |
| 当前 Controller | com.futurefab.system.controller.SysMenuController#getRouters |
| 当前实际路由 | GET /system/menu/getRouters（无权限注解） |
| 当前权限 | 登录态（AUTHENTICATED 一致） |
| 冻结权限 | AUTHENTICATED |
| 当前请求类型 | 无参 ✓ |
| 冻结 Request | CurrentRouteQuery |
| 当前响应类型 | AjaxResult.data=List<RouterVo>（common-core 现有 VO，字段与 RouteNode 结构一致；按钮 SQL 已排除） |
| 冻结 Response | List<RouteNodeView> |
| 当前 Service 调用 | ISysMenuService#selectMenuTreeByUserId→buildMenus |
| 当前 Mapper/XML | com.futurefab.system.mapper.SysMenuMapper#selectMenuTreeByUserId, selectMenuTreeAll（XML statement 均已在对应文件存在，除注明外） |
| 调用链摘要 | getRouters→admin: selectMenuTreeAll / 其它: selectMenuTreeByUserId(join 角色 status=0)→getChildPerms |
| 已确认兼容调用方 | api/menu.js:4 getRouters、store/modules/permission.js（路由注册） |
| 主要差距 | 冻结 Response 为 List<RouteNodeView>（vo/m01 归属），RouterVo 属 common-core 且无 meta.link/noCache 全字段核对——需类型化落位；与 SEC01 同一管理版本（permissionRevision 比对，否则前端重取）缺失；外壳 requestId/managementRevision；SQL 以 m.status = 0 数字比较（风格） |
| 风险等级 | P2 |
| 处置方式 | B（ADAPTER_REQUIRED） |
| 计划修改文件 | futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysMenuController.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m01/CurrentRouteQuery.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/RouteNodeView.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/SysMenuServiceImpl.java<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/mapper/SysMenuMapper.java<br>futurefab-modules/futurefab-system/src/main/resources/mapper/system/SysMenuMapper.xml |
| 文件所有者建议 | PKG-01 |
| 实现注意事项 | 新建 CurrentRouteQuery/RouteNodeView（vo/m01）；映射层输出。 |
| 最小验证方式 | 用例：按钮不生成路由、停用祖先被裁剪、与 getInfo 同 revision；`mvn -pl futurefab-modules/futurefab-system -am test` |
| 设计依据 | docs/详细设计/01-系统管理/接口目录与契约定位.md#定位076；docs/详细设计/01-系统管理/Controller请求调用时序设计.md#1-controller入口逐项映射；docs/详细设计/01-系统管理/详细设计.md#22-日志查询、权限上下文与兼容入口；docs/详细设计/01-系统管理/物理接口与骨架字段设计.md §2—§3；docs/详细设计/01-系统管理/详细设计.md §17（公共参数/响应/并发）；docs/开发任务/01-契约骨架/00-全接口契约骨架问题收口决策.md §3（旧路由处置） |

## 4. Entity/Map 泄漏清单

| 类别 | 接口 | 说明 |
| --- | --- | --- |
| 返回 SysUser 实体（含 password 哈希） | M01-049、M01-055、M01-075 | selectUserVo XML 列含 u.password，SysUser.password 无 @JsonIgnore，序列化直接泄漏口令哈希；075 还返回缓存 LoginUser.user |
| 返回 SysUser 实体（列不含 password 但非白名单） | M01-008、M01-043、M01-048 | email/解密手机号/delFlag/params 自由 Map 字段随行外泄 |
| 返回其他领域实体 | SysRole：M01-039、M01-046<br>SysMenu：M01-045<br>SysDept：M01-032<br>SysVenue：M01-016、M01-031<br>SysGroup：M01-024、M01-033<br>SysDictType：M01-058、M01-061<br>SysDictData：M01-062、M01-065、M01-066(SysDictDataNode)<br>SysConfig：M01-067、M01-070(原文 configValue)<br>SysOperLog：M01-073(operParam/jsonResult 原文)<br>SysLogininfor：M01-072 | — |
| Map 请求体 | M01-005(oldPassword/newPassword)、M01-009(validDays/remindDays) | — |
| 自由结构 AjaxResult/字符串文案 | M01-001(data=Map{access_token,expires_in})、M01-030(warn 字符串)、M01-019/M01-020/M01-036/M01-037/M01-058…(error 中文自由文案)、全部 toAjax 写端点(无 data=W 回执) | — |

全部写端点 `toAjax(int)`/`R.ok()`/`warn()/error(字符串)` 均不满足 data=W 回执契约（applied/id/affectedIds/managementRevision），按"自由结构 AjaxResult"整类计入上表末行。

## 5. 权限差异清单

| 接口 | 当前权限 | 冻结权限 | 差距 |
| --- | --- | --- | --- |
| M01-009 | system:user:edit | edit + 仅超级管理员（Q06） | 超管硬校验缺失 |
| M01-070 | 无权限注解（任意登录用户） | system:config:query | P0 补注解+受保护项校验与脱敏 |
| M01-072 | system:logininfor:list | list + 超级管理员 | 超管硬校验缺失 |
| M01-073 | system:operlog:list | list + 超级管理员 | 超管硬校验缺失 |
| M01-066 | 无权限注解 | 已认证且业务使用该字典或 system:dict:query | 业务使用白名单无代码化落点 |
| M01-007/M01-052 | 功能权限一致 | edit + 目标可管理/超管保护/自身拒绝 | resetPwd、changeStatus 未调 checkUserAllowed，且无自身操作拒绝 |
| M01-012 | 登录态 | AUTHENTICATED_LOCKED_SESSION | 锁屏会话上下文与 LOGIN 失败窗口计数合并（Q10）未实现 |
| M01-043 | system:role:list | list 且角色可见 | 目标角色可见性校验缺失 |

## 6. 路由冲突清单

- 整体结论：所有静态字面量路径（list/getInfo/profile/resetPwd/changeStatus/passwordValidity/tree/pageList/options/editor-options/member-options/resolve-members/getRouters/treeselect/export/clean/refreshCache/configKey/deptUsers/deptTree/authRole/roleUsers/dataScope 等）在 Spring AntPathMatcher 下优先于 /{id} 模板，当前无重复映射或歧义 handler。
- SysUserController @GetMapping({"/","/{userId}"})：GET /system/user/ 命中同 handler 且 userId=null → :325 SecurityUtils.isAdmin(userId) Long 拆箱 NPE 风险；非数字 /user/xxx 落入 /{userId} 返回 400 而非 404。契约要求收敛根路径变体（M01-049 实现注意事项）。
- SysUserController @GetMapping("getInfo") 缺前导斜杠（combine 后仍正确，风格不一致）。
- GET /user/profile（SysProfileController /user/profile 类级前缀）与 GET /user/{userId} 同 URL 空间，依赖字面量优先；新增 /user/editor-options、/user/{userId}/force-logout 后仍成立，但必须保持"静态段先声明/字面量优先"回归测试。
- SysVenueController：/tree、/list、/pageList 先于 /{venueId}(Long) 声明 ✓；PKG-01 新增 /{venueId}/delete-check 使用 String venueId 而 getInfo 使用 Long——同族 PathVariable 类型不一致（冻结物理名以清单为准，实现时统一 String）。
- SysDeptController：/options、/pageList、/list/exclude/{deptId} 与 /{deptId} 共存；delete-check/users 两段路径不与单段 /{deptId} 冲突。
- SysGroupController：/member-options、/resolve-members、/member-tree 均先于 /{groupId}；resolve-members 的 canonical 路径统一为 POST /system/smp/labgroup/resolve-members（M01-034，NEW，不在本批 58 条），当前 Controller 与清单一致，无差异。
- SysRoleController/SysMenuController：/editor-options、/pageList、/changeStatus 与 /{roleId}/{menuId} 字面量优先 ✓；DELETE /menu/{menuId} 旧删除入口与 GET 详情共存（§22 关闭公网写入口任务）。
- SysOperlogController：GET /{operId}（PKG-01 新增，当前必 500/501）与 /list、/export、DELETE /{operIds}、/clean 无冲突；DELETE /{operIds} 与 GET /{operId} 方法不同无歧义。
- /logininfor/clean、/config/refreshCache 等 DELETE 字面量与 DELETE /{ids} 模板共存：字面量优先，安全；若调整声明顺序须回归验证。

## 7. Service/Mapper 重载风险清单

- MyBatis statement id 冲突：Mapper 接口禁止同名重载指向不同 statement（同一 namespace 内方法名即 statement id，同名多参会触发 "ambiguous mapped statement"/映射失败）。本批新增 Request 入参的查询方法必须新命名 statement（如按清单登记名），不得对 insertUser/selectUserList 直接做同名 Java 重载。M01-074 先例是 Service 层重载（保留 selectOperLogById(Long)+新增 Request/View 重载），Mapper 层同名重载一律禁止。
- Java 泛型擦除：Service 接口同名方法 selectXxx(SysUser):List<SysUser> 与 selectXxx(DictTypePageQuery):PageResult<DictTypeRow> 因参数类型不同合法，但 List<SysUser>/List<Row> 返回擦除相同若参数也同形则会编译冲突——统一采用"新 DTO 配新方法名"策略消除歧义。
- Spring 注入歧义：新增 ApplicationService 与既有 ISys*Service 接口类型不同，无同类型双 Bean 风险；但若为适配而实现第二套同名接口须保持每契约唯一实现（时序文档 §1"不新增第二实现"）。
- 旧调用方误调用：SysUserServiceImpl.registerUser/importUser 直调 userMapper.insertUser(SysUser)，PasswordValidity 保存走 saveConfigValueByKey；新增 Command 版方法后旧路径仍在——必须显式标注旧方法为内部兼容路径或改走同一应用服务（§22），禁止两个写入口漂移出不同校验规则。
- default 方法骨架已存在于 SysVenueMapper/SysDeptMapper（抛异常 default），XML 同名空 statement 永不命中；实现阶段删除 default 并补真实 SQL，避免双定义漂移。

## 8. 跨模块依赖清单

| 依赖 | 涉及接口 | 现状 |
| --- | --- | --- |
| I01 verifyCredential / I02 activateSession / I03 validateSession / I05 revokeSession（RemoteAuthContractService，PKG-00 已冻结） | M01-001、M01-005、M01-007、M01-010、M01-011、M01-012、M01-052、M01-075 | 完全未接线；auth 直连 RemoteUserService+本地 Redis |
| m02.LabAuthorizationPort AUTH-I01 prepareUserEdit / AUTH-I02 replaceUserLabs / AUTH-I03 removeUserLabs | M01-049、M01-050、M01-051、M01-053 | Port 接口已建（PKG-00）；M02 适配器未实现；M01 现直读/直写 sys_user_lab（违例，需改造） |
| m01 SEC-I01 ActorContextPort / SEC-I02 FunctionPermissionPort / SEC-I03 ManagementRevisionPort（SYSTEM 守卫与版本） | 全部 31 个管理写接口 + M01-075/076 的 revision 语义 | 接口在，impl/port/m01 适配器不存在——本批适配实现的公共前置（TASK-0） |
| M02/M03 组织引用事实（场地删除的实验室/设备引用、部门子树的实验组/实验室项目配置引用） | M01-018、M01-020、M01-030 | 现状以 SysVenueMapper.xml union 直读 lab_* 表实现；未登记读取 Port，清单 cross_module_ports 为空——设计缺口 BLK-02 |
| M02/M04 字典键/值消费引用检查（DICT_KEY_IN_USE） | M01-060、M01-064 | 无已登记 Port——设计缺口 BLK-03 |
| Feign RemoteLogService POST /operlog、/logininfor（@InnerAuth） | M01-072、M01-073、M01-074(NEW 数据源) | 写入链路为跨服务内部 Feign，网关须拒绝公网 POST（@InnerAuth 已有；与 §22 关闭 POST 一致，联调门禁核对） |
| M07 参数值域注册（补糖轮询等业务参数） | M01-067、M01-068、M01-069 | 注册机制未定——BLK-04c（未冻结项）；四个密码政策受保护键已冻结（BLK-04a），一般敏感键注册未定（BLK-04b） |

## 9. 按文件拆分的后续实施任务包

| 任务包 | 内容 | 主要文件 | 依赖 |
| --- | --- | --- | --- |
| TASK-0 公共前置（PRE-01） | PRE-01 外壳适配实现：按 PKG-00 设计 §3，HTTP 成功外壳继续由现有 R/AjaxResult/TableDataInfo 适配，requestId/managementRevision 由统一适配层（ResponseBodyAdvice 或 ApplicationService 出口）装配，不触碰 PKG-00 只读文件；impl/port/m01 三个 SEC Port 适配器（ActorContext/FunctionPermission/ManagementRevision）+SYSTEM 守卫/幂等回执基础设施（sys_management_request 写路径、WriteMeta 头部合并切面） | futurefab-common-security 适配层（不改 PKG-00 公共文件）<br>futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/port/m01/** | 无——必须先于全部 B 适配合入 |
| TASK-A 认证边缘 4 入口 | M01-001/010/011/012 + auth 侧 LoginCommand/LogoutCommand/TokenRefreshCommand/ScreenUnlockCommand 与 Result 接线、I01—I05 调用、sessionKey 语义 | futurefab-auth/.../controller/TokenController.java<br>futurefab-auth/.../service/SysLoginService.java<br>futurefab-auth/.../service/TokenService.java<br>futurefab-auth/.../domain/dto/m01、vo/m01 新增 8 类<br>futurefab-auth/.../service/application/m01/AuthChallengeApplicationService(Impl) 扩展 | TASK-0；网关白名单与 X-Auth-Proof 不落日志 |
| TASK-B 凭据与身份（P0 泄漏优先） | M01-005/007/055/075/049 的 password 泄漏封堵 + ProfileView/CurrentIdentityView/UserDetailView + I05 撤销；随后 M01-008/009 政策对 | SysProfileController.java<br>SysUserController.java<br>SysUserServiceImpl.java<br>SysUserMapper.xml<br>domain/dto/m01：ProfilePasswordUpdateCommand/UserPasswordResetCommand/PasswordValidityQuery/PasswordValiditySaveCommand…<br>domain/vo/m01：ProfileView/CurrentIdentityView/UserDetailView/PasswordValidityRow…<br>service/application/m01/UserApplicationService(Impl)、PasswordStateApplicationService(Impl) 扩展 | TASK-0 |
| TASK-C 用户 CRUD 与状态 | M01-048/049/050/051/052/053；M02 LabAuthorizationPort 消费接线（授权部分标注依赖） | SysUserController.java<br>SysUserServiceImpl.java<br>SysUserMapper.xml<br>m01 User* Command/Query/Row DTO<br>UserApplicationService(Impl) | TASK-0；M02 适配器（联调层） |
| TASK-D 角色契约适配 | M01-039/040/041/042/043/044/046；role_data_scope 权威模型迁移；旧 /role/dataScope、/role/authUser/* 调同一应用服务 | SysRoleController.java<br>SysRoleServiceImpl.java<br>SysRoleMapper.xml<br>SysRoleDeptMapper.xml、sys_role_data_scope statement<br>m01 Role* DTO<br>RoleApplicationService(Impl) | TASK-0 |
| TASK-E 菜单契约适配 | M01-036/037/045/076；MenuSave 校验规则集中；RouteNodeView 落位 | SysMenuController.java<br>SysMenuServiceImpl.java<br>SysMenuMapper.xml<br>m01 Menu* DTO + RouteNodeView | TASK-0 |
| TASK-F 场地适配 | M01-014/015/016/018/031；子树重挂 ancestors；引用复核接口位（BLK-02） | SysVenueController.java<br>SysVenueServiceImpl.java<br>SysVenueMapper.xml<br>m01 Venue* DTO | TASK-0 |
| TASK-G 部门适配 | M01-019/020/030/032；全子树引用检查（BLK-02）；Controller 编排下沉 | SysDeptController.java<br>SysDeptServiceImpl.java<br>SysDeptMapper.xml<br>m01 Dept* DTO | TASK-0 |
| TASK-H 实验组适配 | M01-024/025/026/028/033；GroupRow/Detail 装配、完整集合语义 | SysGroupController.java<br>SysGroupServiceImpl.java<br>SysGroupMapper.xml/Leader/Member XML<br>m01 Group* DTO | TASK-0 |
| TASK-I 字典适配 | M01-058—066；排序/del_flag/isEditable 服务端语义、DictOptionView 树、引用检查接口位（BLK-03） | SysDictTypeController.java<br>SysDictDataController.java<br>SysDictTypeServiceImpl.java<br>SysDictDataServiceImpl.java<br>SysDictTypeMapper.xml/SysDictDataMapper.xml<br>m01 Dict* DTO | TASK-0 |
| TASK-J 参数配置适配（P0 先行） | M01-070 补权限（可独立热修先行）；067—071 脱敏/保护键/专用路由（四个密码政策受保护键按 BLK-04a 已冻结实现；敏感键注册与 M07 值域注册按 BLK-04b/04c 留接口位） | SysConfigController.java<br>SysConfigServiceImpl.java<br>SysConfigMapper.xml<br>m01 Config* DTO | TASK-0 |
| TASK-K 日志查询适配 | M01-072/073 超管校验、契约参数/排序/脱敏；前端 operlog api 断链修复；§22 关闭 clean/delete/unlock 公网入口（网关） | SysLogininforController.java<br>SysOperlogController.java<br>SysLogininforServiceImpl.java<br>SysOperLogServiceImpl.java<br>两个 Mapper XML<br>futurefab-ui api/views 对应文件 | TASK-0 |
| TASK-L 旧旁路与网关收口 | §22 全部 M01 旁路：unlock GET、logininfor/operlog clean/delete、dict DELETE、menu DELETE/updateSort、role dataScope/authUser、user authRole/register/import/avatar/export | futurefab-gateway 配置/nacos-config<br>各 Controller 标注与委托<br>网关白名单 | 与 TASK-A—K 并行，验收合并 |

所有权提示：以上文件均落在 PKG-01（M01）独占范围（含 auth 7 入口）；PRE-01 外壳适配实现于 futurefab-common-security 适配层，不修改 PKG-00 只读公共文件——如实现中确需触碰公共文件，必须走 01 文档 §8 公共文件变更流程，不得直接修改。

## 10. 推荐实施顺序

1. 0. 实现 TASK-0（PRE-01 外壳适配层 + SEC Port 适配器 + WriteMeta/幂等基础设施）——31 个管理写接口共同前置，无需跨包设计裁决
1. 1. 安全热修（可与 0 并行的小批）：M01-070 补权限、049/055/075 password 泄漏封堵（View 白名单先行）
1. 2. TASK-A 认证 4 入口（001/010/011/012）——登录语义是全部会话类契约的地基
1. 3. TASK-B 凭据（005/007 + 008/009）与身份（075/055 完整化）
1. 4. TASK-C 用户 CRUD（048—053），其中 049/050/051/053 的 M02 Port 分支实现到"接口位+依赖失败显式 503"
1. 5. TASK-D/E 角色、菜单（039—046、036/037/076）——角色 data_scope 权威迁移影响数据权限全局，须先全量回归
1. 6. TASK-F/G/H 组织三域（venue→dept→labgroup，dept 删除依赖 BLK-02 裁决）
1. 7. TASK-I/J/K 字典、配置、日志
1. 8. TASK-L 旁路收口 + 前端 api 全量切换，联调门禁（启动/HTTP/DB 层）

## 11. 开发前阻塞项与公共实现前置项

| ID | 性质 | 事项 | 影响 | 解决方式 |
| --- | --- | --- | --- | --- |
| PRE-01 | 公共实现前置项（非设计未决） | §17.1 成功外壳要求 code/msg/requestId/managementRevision；现有 AjaxResult/R/TableDataInfo 无 requestId/managementRevision 字段。依据 PKG-00 设计 §3：公共 HTTP 成功外壳继续由现有 R/AjaxResult/TableDataInfo 适配，Port 不返回 HTTP 类型——差异由适配层补齐，不涉及 PKG-00 只读文件变更。 | 全部 58 条响应外壳 | 实现 TASK-0 统一适配层（ResponseBodyAdvice 或 ApplicationService 出口装配 requestId/managementRevision），响应快照测试随之定稿；无需跨包设计裁决。 |
| BLK-02 | 设计缺口 | M01-018/020/030 删除/重挂引用复核需要 M02/M03 拥有的 lab_*/实验组引用事实；现状 SQL 直读跨模块表，且清单 cross_module_ports=[]、71 契约中无对应只读 Port。 | ORG06/ORG08/ORG18 完整实现 | 设计补登记（新增只读引用计数 Port 归 m02/m03，或豁免"只读计数聚合"允许直读并在总设计注记），二选一后回写清单 JSON 与本审计。适配骨架不受阻（引用检查留接口位）。 |
| BLK-03 | 设计缺口 | M01-060/064 的 DICT_KEY_IN_USE 跨模块（M02/M04）字典引用检查无 Port 签名。 | DIC03/DIC07 完整实现 | 同 BLK-02：登记 DictReferencePort 或以 M01 内注册表（sys_dict_reference）裁决；先补设计再实现引用分支。 |
| BLK-04a | 已冻结（依据备查，不阻塞） | 四个密码政策受保护键已冻结：sys.account.passwordValidateDays、sys.account.passwordRemindDays、sys.account.initPasswordModify、sys.account.passwordPolicyVersion（版本权威行，初始值 1，策略保存同事务递增）；通用配置写路径对这四个键转专用策略服务或拒绝。 | M01-008/009、CFG03 保护分支 | 直接实现：键清单与语义见《数据库表结构与字段字典》§sys.account 键表、开发基线 02-基础数据初始化.sql 固定种子、详细设计 §21（API09 专用路径）。 |
| BLK-04b | 未冻结 | 一般敏感配置键的注册机制（哪些键算敏感、注册载体）未定义；敏感值仅显示"已配置"不回原文的规则缺键清单来源。 | CFG01—CFG05 脱敏分支 | 由需求方确认敏感键注册表（sys_config 保护标记列或配置文档清单）后实现；先留脱敏接口位。 |
| BLK-04c | 未冻结 | 补糖轮询等业务参数的 M07 值域注册机制未定义，不能由 M01 猜测阈值。 | CFG01—CFG04 值校验分支 | 与 M07 设计对齐注册契约（值域随键登记）后实现；先按"注册规则允许才可空值/自定义值"的拒绝式默认（fail-closed）留位。 |

- 已裁决删除项：原 BLK-05（密码政策版本存储行语义）——权威已定：政策版本存于 sys_config 键 sys.account.passwordPolicyVersion（初始值 1，策略保存同事务递增），SYSTEM 管理写事务仍按 sys_management_revision 固定 SYSTEM 行加锁与校验；M01-008/009 实现注意事项已按此修正。
- 原 BLK-01 重定性为 PRE-01（见上表第一行）；原 BLK-04 拆分为 BLK-04a（已冻结）/04b/04c（未冻结）。

## 12. 观察项（超出本批处置但不容遗忘）

- OBS-1：views/system/operlog/index.vue 导入不存在的 @/api/system/operlog——前端断链缺陷，属 M01 前端适配批。
- OBS-2：SysGroupController 存在 /{groupId}/members GET+PUT、member-tree、member-details 关系旁路；§22 已定 COMPAT 方向（统一进实验组应用服务），列入旁路收口任务包 TASK-F2。
- OBS-3：logininfor/operlog 的 DELETE /{ids}、/clean 与 GET /logininfor/unlock/{userName} 属 §22"关闭公网入口"组，不在 58 条内，但 M01-012/072/073 验收必须联同网关规则完成。
- OBS-4：RemoteUserService 暴露的 /user/info、/user/email、/user/recordlogin（@InnerAuth）为收口决策 §3 DISABLE 组（I01—I05 替代），不在 58 条内。
- 已裁决删除项：原 OBS-1（M01-034 路径分歧）——canonical 路径统一为 POST /system/smp/labgroup/resolve-members，当前 Controller 与清单一致，分歧不存在。

## 13. 明确的验收门禁

- G1 每接口映射反射测试：HTTP 方法+完整外部路径（含网关前缀还原）与清单 JSON 逐字一致；58/58
- G2 类型门禁：全部 58 条 Controller 参数为命名 Query/Command、响应为命名 View/Result，Entity/Map 作为浏览器请求体或响应 data 命中 0（静态扫描断言）；31 个管理写接口另须通过 WriteMeta 合并断言（X-Request-Id/X-Management-Revision/Path 覆盖 Body/未知字段拒绝），查询接口不适用 WriteMeta/幂等/守卫断言
- G3 权限门禁：8 项权限差异（见权限差异清单）全部闭合；@RequiresPermissions/超管断言测试
- G4 写契约门禁：31 个管理写接口幂等回执（同键同载荷回放、同键异载荷 REQUEST_CONFLICT）、managementRevision CAS、SYSTEM 守卫锁顺序、审计同事务、禁用/删除会话撤销用例
- G5 批量门禁：044/053（CTRL-BATCH）全量预验+稳定顺序加锁+整批回滚测试
- G6 泄漏回归：password/口令哈希/敏感 configValue/operParam 原文在全部响应快照中命中 0
- G7 路由回归：静态字面量优先于 /{id} 的匹配断言（含 049 根路径收敛后 404 语义）
- G8 跨模块门禁：对 sys_user_lab/lab_* 的 M01 直读直写改 Port 后，M01 包扫描其他模块 Mapper/表引用为 0（BLK-02/03 裁决除外项须留痕）
- G9 编译+测试：mvn -pl futurefab-modules/futurefab-system -am test 与 mvn -pl futurefab-auth -am test 通过；未实现分支显式 NOT_IMPLEMENTED，不得伪成功
- G10 联调层（不得以静态结果宣称）：服务启动+网关路由+HTTP 冒烟+SQL 执行按 AGENTS.md 分层报告

## 14. 本任务边界声明

- 本审计仅新增 `docs/开发任务/05-PKG-01-ADJUST接口契约差异审计.md` 与同名 `.json` 两个文件；开始前工作树中 PKG-00/PKG-01 的未提交修改全部原样保留，未改动任何 Java/XML/Vue/SQL 与客户保护材料。
- 验证层级：文档存在/静态核对通过；未执行编译、测试、数据库或 HTTP 联调（本任务性质为审计）。
