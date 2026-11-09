# 最终 API 基线（仅 FROZEN / READY）

> 由 `genApiBaseline.js` 同源生成（2026-09-21），与《最终设计闭环矩阵》同一判定链。收录 FROZEN 76 条＋READY 327 条 = 403 条；排除 DESIGN_BLOCKED/MISSING/CONFLICT 129 条（不得进入开发，见矩阵与收口报告）。

**口径**：FROZEN=契约冻结且存量实现已过门禁链（仅 M01）；READY=契约冻结＋骨架落码过门禁，DTO 叶子字段逐项冻结（`*`=必填），可按登记直接业务实现。嵌套 DTO 全集见 `_tmp_skelgen/spec/<模块>.json` 与来源文档；本基线不重复发明任何字段。验证层级=静态检查＋契约测试门禁，不含真实环境/设备联调。

## 目录

- M01：76 条（FROZEN 76／READY 0）
- M02：216 条（FROZEN 0／READY 216）
- M03：23 条（FROZEN 0／READY 23）
- M04：21 条（FROZEN 0／READY 21）
- M05：38 条（FROZEN 0／READY 38）
- M06：15 条（FROZEN 0／READY 15）
- M09：14 条（FROZEN 0／READY 14）

# M01（76 条）

## M01-001｜POST /auth/login｜登录、密码和会话〔FROZEN〕
- 权限：PUBLIC
- Controller→Service：`com.futurefab.auth.controller.TokenController#login` → `com.futurefab.auth.service.SysLoginService#login`
- Request：`LoginCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`LoginResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, CREDENTIALS_INVALID, ACCOUNT_LOCKED, ACCOUNT_UNAVAILABLE, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-002｜POST /auth/login/continue｜登录、密码和会话〔FROZEN〕
- 权限：PUBLIC_WITH_VALID_CHALLENGE
- Controller→Service：`com.futurefab.auth.controller.TokenController#loginContinue` → `com.futurefab.auth.service.application.m01.AuthChallengeApplicationService#continueAfterWarning`
- Request：`LoginContinueCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`LoginResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PASSWORD_CHANGE_REQUIRED, CHALLENGE_EXPIRED, SESSION_INVALID, SESSION_REPLACED, ACCOUNT_LOCKED, ACCOUNT_UNAVAILABLE, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-003｜POST /auth/password/complete｜登录、密码和会话〔FROZEN〕
- 权限：PUBLIC_WITH_VALID_CHALLENGE
- Controller→Service：`com.futurefab.auth.controller.TokenController#completePasswordChange` → `com.futurefab.auth.service.application.m01.AuthChallengeApplicationService#completePasswordChange`
- Request：`PasswordChallengeCompleteCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PasswordChallengeCompleteResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PASSWORD_POLICY_VIOLATION, PASSWORD_REUSED, CHALLENGE_EXPIRED, REQUEST_CONFLICT, ACCOUNT_LOCKED, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-004｜DELETE /auth/login/challenge｜登录、密码和会话〔FROZEN〕
- 权限：PUBLIC_WITH_VALID_CHALLENGE
- Controller→Service：`com.futurefab.auth.controller.TokenController#cancelLoginChallenge` → `com.futurefab.auth.service.application.m01.AuthChallengeApplicationService#cancelChallenge`
- Request：`LoginChallengeCancelCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`LoginChallengeCancelResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=—
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-005｜PUT /system/user/profile/updatePwd｜登录、密码和会话〔FROZEN〕
- 权限：AUTHENTICATED_SELF
- Controller→Service：`com.futurefab.system.controller.SysProfileController#updatePwd` → `com.futurefab.system.service.ISysUserService#resetUserPwd`
- Request：`ProfilePasswordUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PASSWORD_POLICY_VIOLATION, PASSWORD_REUSED, OLD_PASSWORD_INVALID, ACCOUNT_LOCKED, SESSION_INVALID, VERSION_CONFLICT, REQUEST_CONFLICT, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-006｜GET /system/user/profile/passwordState｜登录、密码和会话〔FROZEN〕
- 权限：AUTHENTICATED_SELF
- Controller→Service：`com.futurefab.system.controller.SysProfileController#passwordState` → `com.futurefab.system.service.application.m01.PasswordStateApplicationService#getPasswordState`
- Request：`PasswordStateQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PasswordStateView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, SESSION_INVALID, ACCOUNT_LOCKED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-007｜PUT /system/user/resetPwd｜登录、密码和会话〔FROZEN〕
- 权限：system:user:edit
- Controller→Service：`com.futurefab.system.controller.SysUserController#resetPwd` → `com.futurefab.system.service.ISysUserService#resetPwd`
- Request：`UserPasswordResetCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-008｜GET /system/user/passwordValidity｜登录、密码和会话〔FROZEN〕
- 权限：system:user:query
- Controller→Service：`com.futurefab.system.controller.SysUserController#getPasswordValidity` → `com.futurefab.system.service.ISysUserService#selectUserList`
- Request：`PasswordValidityQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<PasswordValidityRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-009｜PUT /system/user/passwordValidity｜登录、密码和会话〔FROZEN〕
- 权限：system:user:edit
- Controller→Service：`com.futurefab.system.controller.SysUserController#savePasswordValidity` → `com.futurefab.system.service.ISysConfigService#saveConfigValueByKey`
- Request：`PasswordValiditySaveCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, VERSION_CONFLICT, REQUEST_CONFLICT, ACCOUNT_UNAVAILABLE, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=sys_config
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-010｜DELETE /auth/logout｜登录、密码和会话〔FROZEN〕
- 权限：AUTHENTICATED
- Controller→Service：`com.futurefab.auth.controller.TokenController#logout` → `com.futurefab.auth.service.SysLoginService#logout`
- Request：`LogoutCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`LogoutResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, SESSION_INVALID
- 幂等：幂等口径见备注/来源契约｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-011｜POST /auth/refresh｜登录、密码和会话〔FROZEN〕
- 权限：AUTHENTICATED_REFRESH_TOKEN
- Controller→Service：`com.futurefab.auth.controller.TokenController#refresh` → `com.futurefab.auth.service.TokenService#refreshToken`
- Request：`TokenRefreshCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`TokenRefreshResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, SESSION_INVALID, SESSION_REPLACED, ACCOUNT_LOCKED, ACCOUNT_UNAVAILABLE, PASSWORD_CHANGE_REQUIRED, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=—
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-012｜POST /auth/unlockscreen｜登录、密码和会话〔FROZEN〕
- 权限：AUTHENTICATED_LOCKED_SESSION
- Controller→Service：`com.futurefab.auth.controller.TokenController#unlockScreen` → `com.futurefab.auth.service.SysLoginService#unlock`
- Request：`ScreenUnlockCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`ScreenUnlockResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, CREDENTIALS_INVALID, ACCOUNT_LOCKED, SESSION_INVALID, SESSION_REPLACED, ACCOUNT_UNAVAILABLE, AUTH_DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=sys_user_auth_state
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-02

## M01-013｜GET /system/smp/venue/pageList｜场地、部门、实验组〔FROZEN〕
- 权限：system:venue:list
- Controller→Service：`com.futurefab.system.controller.SysVenueController#pageList` → `com.futurefab.system.service.application.m01.VenueApplicationService#pageVenueList`
- Request：`VenuePageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<VenueRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-014｜POST /system/smp/venue｜场地、部门、实验组〔FROZEN〕
- 权限：system:venue:add
- Controller→Service：`com.futurefab.system.controller.SysVenueController#add` → `com.futurefab.system.service.ISysVenueService#insertSysVenue`
- Request：`VenueSaveCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, TREE_CYCLE, ANCESTOR_PATH_TOO_LONG, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：幂等口径见备注/来源契约｜事务：应用服务层事务；owner 表=sys_venue
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-015｜PUT /system/smp/venue｜场地、部门、实验组〔FROZEN〕
- 权限：system:venue:edit
- Controller→Service：`com.futurefab.system.controller.SysVenueController#edit` → `com.futurefab.system.service.ISysVenueService#updateSysVenue`
- Request：`VenueSaveCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, TREE_CYCLE, ANCESTOR_PATH_TOO_LONG, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：幂等口径见备注/来源契约｜事务：应用服务层事务；owner 表=sys_venue
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-016｜GET /system/smp/venue/tree｜场地、部门、实验组〔FROZEN〕
- 权限：system:venue:list
- Controller→Service：`com.futurefab.system.controller.SysVenueController#tree` → `com.futurefab.system.service.ISysVenueService#selectSysVenueTree`
- Request：`VenueTreeQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<OptionView>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-017｜GET /system/smp/venue/{venueId}/delete-check｜场地、部门、实验组〔FROZEN〕
- 权限：system:venue:remove
- Controller→Service：`com.futurefab.system.controller.SysVenueController#deleteCheck` → `com.futurefab.system.service.application.m01.VenueApplicationService#deleteCheck`
- Request：`VenueDeleteCheckQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeletePrecheckResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-018｜DELETE /system/smp/venue/{venueIds}｜场地、部门、实验组〔FROZEN〕
- 权限：system:venue:remove
- Controller→Service：`com.futurefab.system.controller.SysVenueController#remove` → `com.futurefab.system.service.ISysVenueService#deleteSysVenueByVenueIds`
- Request：`VenueDeleteCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeleteResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, REFERENCE_EXISTS, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_venue
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-019｜POST /system/dept｜场地、部门、实验组〔FROZEN〕
- 权限：system:dept:add
- Controller→Service：`com.futurefab.system.controller.SysDeptController#add` → `com.futurefab.system.service.ISysDeptService#insertDept`
- Request：`DeptCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, TREE_CYCLE, ANCESTOR_PATH_TOO_LONG, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_dept
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-020｜PUT /system/dept｜场地、部门、实验组〔FROZEN〕
- 权限：system:dept:edit
- Controller→Service：`com.futurefab.system.controller.SysDeptController#edit` → `com.futurefab.system.service.ISysDeptService#updateDept`
- Request：`DeptUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, TREE_CYCLE, ANCESTOR_PATH_TOO_LONG, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_dept
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-021｜GET /system/dept/options｜场地、部门、实验组〔FROZEN〕
- 权限：system:dept:list或经验证的用户/组/角色编辑场景
- Controller→Service：`com.futurefab.system.controller.SysDeptController#options` → `com.futurefab.system.service.application.m01.DeptApplicationService#options`
- Request：`DeptOptionQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<OptionView>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-022｜GET /system/dept/{deptId}/delete-check｜场地、部门、实验组〔FROZEN〕
- 权限：system:dept:remove
- Controller→Service：`com.futurefab.system.controller.SysDeptController#deleteCheck` → `com.futurefab.system.service.application.m01.DeptApplicationService#deleteCheck`
- Request：`DeptDeleteCheckQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeletePrecheckResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-023｜GET /system/dept/{deptId}/users｜场地、部门、实验组〔FROZEN〕
- 权限：system:user:list及部门可见
- Controller→Service：`com.futurefab.system.controller.SysDeptController#listUsers` → `com.futurefab.system.service.application.m01.DeptApplicationService#listDeptUsers`
- Request：`DeptUserQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<PersonOptionView>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-024｜GET /system/smp/labgroup/list｜场地、部门、实验组〔FROZEN〕
- 权限：system:labgroup:list
- Controller→Service：`com.futurefab.system.controller.SysGroupController#list` → `com.futurefab.system.service.ISysGroupService#selectSysGroupList`
- Request：`GroupListQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<GroupRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-025｜POST /system/smp/labgroup｜场地、部门、实验组〔FROZEN〕
- 权限：system:labgroup:add
- Controller→Service：`com.futurefab.system.controller.SysGroupController#add` → `com.futurefab.system.service.ISysGroupService#insertSysGroup`
- Request：`GroupCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_group
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-026｜PUT /system/smp/labgroup｜场地、部门、实验组〔FROZEN〕
- 权限：system:labgroup:edit
- Controller→Service：`com.futurefab.system.controller.SysGroupController#edit` → `com.futurefab.system.service.ISysGroupService#updateSysGroup`
- Request：`GroupUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_group
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-027｜GET /system/smp/labgroup/member-options｜场地、部门、实验组〔FROZEN〕
- 权限：system:labgroup:add/edit或用户编辑场景
- Controller→Service：`com.futurefab.system.controller.SysGroupController#memberOptions` → `com.futurefab.system.service.application.m01.GroupApplicationService#memberOptions`
- Request：`GroupMemberOptionQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<PersonOptionView>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-028｜DELETE /system/smp/labgroup/{groupIds}｜场地、部门、实验组〔FROZEN〕
- 权限：system:labgroup:remove
- Controller→Service：`com.futurefab.system.controller.SysGroupController#remove` → `com.futurefab.system.service.ISysGroupService#deleteSysGroupByGroupIds`
- Request：`GroupDeleteCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeleteResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_group
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-029｜GET /system/dept/pageList｜场地、部门、实验组〔FROZEN〕
- 权限：system:dept:list
- Controller→Service：`com.futurefab.system.controller.SysDeptController#pageList` → `com.futurefab.system.service.application.m01.DeptApplicationService#pageDeptList`
- Request：`DeptPageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<DeptRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-030｜DELETE /system/dept/{deptId}｜场地、部门、实验组〔FROZEN〕
- 权限：system:dept:remove
- Controller→Service：`com.futurefab.system.controller.SysDeptController#remove` → `com.futurefab.system.service.ISysDeptService#deleteDeptById`
- Request：`DeptDeleteCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeleteResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, REFERENCE_EXISTS, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_dept
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-031｜GET /system/smp/venue/{venueId}｜场地、部门、实验组〔FROZEN〕
- 权限：system:venue:query
- Controller→Service：`com.futurefab.system.controller.SysVenueController#getInfo` → `com.futurefab.system.service.ISysVenueService#selectSysVenueByVenueId`
- Request：`VenueDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`VenueDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-032｜GET /system/dept/{deptId}｜场地、部门、实验组〔FROZEN〕
- 权限：system:dept:query
- Controller→Service：`com.futurefab.system.controller.SysDeptController#getInfo` → `com.futurefab.system.service.ISysDeptService#selectDeptById`
- Request：`DeptDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeptDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-033｜GET /system/smp/labgroup/{groupId}｜场地、部门、实验组〔FROZEN〕
- 权限：system:labgroup:query
- Controller→Service：`com.futurefab.system.controller.SysGroupController#getInfo` → `com.futurefab.system.service.ISysGroupService#selectSysGroupByGroupId`
- Request：`GroupDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`GroupDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-034｜POST /system/smp/labgroup/resolve-members｜场地、部门、实验组〔FROZEN〕
- 权限：system:labgroup:add/edit或用户编辑场景
- Controller→Service：`com.futurefab.system.controller.SysGroupController#resolveMembers` → `com.futurefab.system.service.application.m01.GroupApplicationService#resolveMembers`
- Request：`GroupMemberResolveCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`GroupMemberResolveResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-01

## M01-035｜GET /system/menu/pageList｜功能与角色〔FROZEN〕
- 权限：system:menu:list
- Controller→Service：`com.futurefab.system.controller.SysMenuController#pageList` → `com.futurefab.system.service.application.m01.MenuApplicationService#pageMenuList`
- Request：`MenuPageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<MenuRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-036｜POST /system/menu｜功能与角色〔FROZEN〕
- 权限：system:menu:add
- Controller→Service：`com.futurefab.system.controller.SysMenuController#add` → `com.futurefab.system.service.ISysMenuService#insertMenu`
- Request：`MenuCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, TREE_CYCLE, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_menu
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-037｜PUT /system/menu｜功能与角色〔FROZEN〕
- 权限：system:menu:edit
- Controller→Service：`com.futurefab.system.controller.SysMenuController#edit` → `com.futurefab.system.service.ISysMenuService#updateMenu`
- Request：`MenuUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, TREE_CYCLE, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_menu
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-038｜PUT /system/menu/changeStatus｜功能与角色〔FROZEN〕
- 权限：system:menu:edit
- Controller→Service：`com.futurefab.system.controller.SysMenuController#changeStatus` → `com.futurefab.system.service.application.m01.MenuApplicationService#changeStatus`
- Request：`MenuStatusChangeCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_menu
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-039｜GET /system/role/list｜功能与角色〔FROZEN〕
- 权限：system:role:list
- Controller→Service：`com.futurefab.system.controller.SysRoleController#list` → `com.futurefab.system.service.ISysRoleService#selectRoleList`
- Request：`RoleListQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<RoleRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-040｜POST /system/role｜功能与角色〔FROZEN〕
- 权限：system:role:add
- Controller→Service：`com.futurefab.system.controller.SysRoleController#add` → `com.futurefab.system.service.ISysRoleService#insertRole`
- Request：`RoleCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, ASSIGNMENT_DENIED, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_role
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-041｜PUT /system/role｜功能与角色〔FROZEN〕
- 权限：system:role:edit
- Controller→Service：`com.futurefab.system.controller.SysRoleController#edit` → `com.futurefab.system.service.ISysRoleService#updateRole`
- Request：`RoleUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, NAME_CONFLICT, ASSIGNMENT_DENIED, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_role
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-042｜PUT /system/role/changeStatus｜功能与角色〔FROZEN〕
- 权限：system:role:edit
- Controller→Service：`com.futurefab.system.controller.SysRoleController#changeStatus` → `com.futurefab.system.service.ISysRoleService#updateRoleStatus`
- Request：`RoleStatusChangeCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, REFERENCE_EXISTS, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_role
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-043｜GET /system/role/roleUsers｜功能与角色〔FROZEN〕
- 权限：system:role:list且角色可见
- Controller→Service：`com.futurefab.system.controller.SysRoleController#roleUsers` → `com.futurefab.system.service.ISysUserService#selectAllocatedList`
- Request：`RoleMemberQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<RoleMemberRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-044｜DELETE /system/role/{roleIds}｜功能与角色〔FROZEN〕
- 权限：system:role:remove
- Controller→Service：`com.futurefab.system.controller.SysRoleController#remove` → `com.futurefab.system.service.ISysRoleService#deleteRoleByIds`
- Request：`RoleDeleteCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeleteResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, REFERENCE_EXISTS, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_role
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-045｜GET /system/menu/{menuId}｜功能与角色〔FROZEN〕
- 权限：system:menu:query
- Controller→Service：`com.futurefab.system.controller.SysMenuController#getInfo` → `com.futurefab.system.service.ISysMenuService#selectMenuById`
- Request：`MenuDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MenuDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-046｜GET /system/role/{roleId}｜功能与角色〔FROZEN〕
- 权限：system:role:query
- Controller→Service：`com.futurefab.system.controller.SysRoleController#getInfo` → `com.futurefab.system.service.ISysRoleService#selectRoleById`
- Request：`RoleDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`RoleDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-047｜GET /system/role/editor-options｜功能与角色〔FROZEN〕
- 权限：system:role:add/edit
- Controller→Service：`com.futurefab.system.controller.SysRoleController#editorOptions` → `com.futurefab.system.service.application.m01.RoleApplicationService#editorOptions`
- Request：`RoleEditorOptionQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`RoleEditorOptionsView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, ASSIGNMENT_DENIED
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-03

## M01-048｜GET /system/user/list｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:list
- Controller→Service：`com.futurefab.system.controller.SysUserController#list` → `com.futurefab.system.service.ISysUserService#selectUserList`
- Request：`UserPageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<UserRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-049｜GET /system/user/{userId}｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:query及目标用户数据权限
- Controller→Service：`com.futurefab.system.controller.SysUserController#getInfo` → `com.futurefab.system.service.ISysUserService#selectUserById`
- Request：`UserDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`UserDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-050｜POST /system/user｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:add
- Controller→Service：`com.futurefab.system.controller.SysUserController#add` → `com.futurefab.system.service.ISysUserService#insertUser`
- Request：`UserCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, CODE_CONFLICT, ASSIGNMENT_DENIED, LAB_AUTHORIZATION_UNAVAILABLE, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_user
- 跨模块 Port：M02:LabAuthorization.replaceUserLabs
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-051｜PUT /system/user｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:edit及可管理目标
- Controller→Service：`com.futurefab.system.controller.SysUserController#edit` → `com.futurefab.system.service.ISysUserService#updateUser`
- Request：`UserUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, CODE_CONFLICT, ASSIGNMENT_DENIED, LAB_AUTHORIZATION_UNAVAILABLE, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_user
- 跨模块 Port：M02:LabAuthorization.replaceUserLabs
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-052｜PUT /system/user/changeStatus｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:edit
- Controller→Service：`com.futurefab.system.controller.SysUserController#changeStatus` → `com.futurefab.system.service.ISysUserService#updateUserStatus`
- Request：`UserStatusChangeCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-053｜DELETE /system/user/{userIds}｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:remove
- Controller→Service：`com.futurefab.system.controller.SysUserController#remove` → `com.futurefab.system.service.ISysUserService#deleteUserByIds`
- Request：`UserDeleteCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeleteResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, REFERENCE_EXISTS, ASSIGNMENT_DENIED, LAB_AUTHORIZATION_UNAVAILABLE, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_user
- 跨模块 Port：M02:LabAuthorization.removeUserLabs
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-054｜GET /system/user/editor-options｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:add/edit
- Controller→Service：`com.futurefab.system.controller.SysUserController#editorOptions` → `com.futurefab.system.service.application.m01.UserApplicationService#editorOptions`
- Request：`UserEditorOptionQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`UserEditorOptionsView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, LAB_AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M02:LabAuthorization.prepareUserEdit
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-055｜GET /system/user/profile｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：AUTHENTICATED_SELF
- Controller→Service：`com.futurefab.system.controller.SysProfileController#profile` → `com.futurefab.system.service.ISysUserService#selectUserByUserName`
- Request：`ProfileQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`ProfileView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, SESSION_INVALID, ACCOUNT_LOCKED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-056｜PUT /system/user/profile｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：AUTHENTICATED_SELF
- Controller→Service：`com.futurefab.system.controller.SysProfileController#updateProfile` → `com.futurefab.system.service.ISysUserService#updateUserProfile`
- Request：`ProfileUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, CODE_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-057｜POST /system/user/{userId}/force-logout｜用户、个人资料及跨模块授权〔FROZEN〕
- 权限：system:user:edit并具有目标管理权
- Controller→Service：`com.futurefab.system.controller.SysUserController#forceLogout` → `com.futurefab.system.service.application.m01.UserApplicationService#forceLogout`
- Request：`UserForceLogoutCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`UserForceLogoutResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, SESSION_VERSION_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_user
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-06

## M01-058｜GET /system/dict/type/list｜数据字典与参数〔FROZEN〕
- 权限：system:dict:list
- Controller→Service：`com.futurefab.system.controller.SysDictTypeController#list` → `com.futurefab.system.service.ISysDictTypeService#selectDictTypeList`
- Request：`DictTypePageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<DictTypeRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-059｜POST /system/dict/type｜数据字典与参数〔FROZEN〕
- 权限：system:dict:add
- Controller→Service：`com.futurefab.system.controller.SysDictTypeController#add` → `com.futurefab.system.service.ISysDictTypeService#insertDictType`
- Request：`DictTypeCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NAME_CONFLICT, CODE_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_dict_type
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-060｜PUT /system/dict/type｜数据字典与参数〔FROZEN〕
- 权限：system:dict:edit
- Controller→Service：`com.futurefab.system.controller.SysDictTypeController#edit` → `com.futurefab.system.service.ISysDictTypeService#updateDictType`
- Request：`DictTypeUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NAME_CONFLICT, CODE_CONFLICT, DICT_KEY_IN_USE, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_dict_type
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-061｜GET /system/dict/type/{dictId}｜数据字典与参数〔FROZEN〕
- 权限：system:dict:query
- Controller→Service：`com.futurefab.system.controller.SysDictTypeController#getInfo` → `com.futurefab.system.service.ISysDictTypeService#selectDictTypeById`
- Request：`DictTypeDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DictTypeDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-062｜GET /system/dict/data/list｜数据字典与参数〔FROZEN〕
- 权限：system:dict:list
- Controller→Service：`com.futurefab.system.controller.SysDictDataController#list` → `com.futurefab.system.service.ISysDictDataService#selectDictDataList`
- Request：`DictDataPageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<DictDataRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-063｜POST /system/dict/data｜数据字典与参数〔FROZEN〕
- 权限：system:dict:add
- Controller→Service：`com.futurefab.system.controller.SysDictDataController#add` → `com.futurefab.system.service.ISysDictDataService#insertDictData`
- Request：`DictDataCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, CODE_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_dict_data
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-064｜PUT /system/dict/data｜数据字典与参数〔FROZEN〕
- 权限：system:dict:edit
- Controller→Service：`com.futurefab.system.controller.SysDictDataController#edit` → `com.futurefab.system.service.ISysDictDataService#updateDictData`
- Request：`DictDataUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, CODE_CONFLICT, DICT_KEY_IN_USE, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_dict_data
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-065｜GET /system/dict/data/{dictCode}｜数据字典与参数〔FROZEN〕
- 权限：system:dict:query
- Controller→Service：`com.futurefab.system.controller.SysDictDataController#getInfo` → `com.futurefab.system.service.ISysDictDataService#selectDictDataById`
- Request：`DictDataDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DictDataDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-066｜GET /system/dict/data/type/{dictType}/tree｜数据字典与参数〔FROZEN〕
- 权限：已认证且业务使用该字典或system:dict:query
- Controller→Service：`com.futurefab.system.controller.SysDictDataController#dictTypeTree` → `com.futurefab.system.service.ISysDictTypeService#selectDictDataByType`
- Request：`DictDataTreeQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<DictOptionView>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-067｜GET /system/config/list｜数据字典与参数〔FROZEN〕
- 权限：system:config:list
- Controller→Service：`com.futurefab.system.controller.SysConfigController#list` → `com.futurefab.system.service.ISysConfigService#selectConfigList`
- Request：`ConfigPageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<ConfigRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-068｜POST /system/config｜数据字典与参数〔FROZEN〕
- 权限：system:config:add
- Controller→Service：`com.futurefab.system.controller.SysConfigController#add` → `com.futurefab.system.service.ISysConfigService#insertConfig`
- Request：`ConfigCreateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, CODE_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_config
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-069｜PUT /system/config｜数据字典与参数〔FROZEN〕
- 权限：system:config:edit
- Controller→Service：`com.futurefab.system.controller.SysConfigController#edit` → `com.futurefab.system.service.ISysConfigService#updateConfig`
- Request：`ConfigUpdateCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`MutationResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, CODE_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_config
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-070｜GET /system/config/{configId}｜数据字典与参数〔FROZEN〕
- 权限：system:config:query
- Controller→Service：`com.futurefab.system.controller.SysConfigController#getInfo` → `com.futurefab.system.service.ISysConfigService#selectConfigById`
- Request：`ConfigDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`ConfigDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-071｜DELETE /system/config/{configIds}｜数据字典与参数〔FROZEN〕
- 权限：system:config:remove
- Controller→Service：`com.futurefab.system.controller.SysConfigController#remove` → `com.futurefab.system.service.ISysConfigService#deleteConfigByIds`
- Request：`ConfigDeleteCommand`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`DeleteResult`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND, REFERENCE_EXISTS, VERSION_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY
- 幂等：待登记—MISSING｜事务：应用服务层事务；owner 表=sys_config
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-05

## M01-072｜GET /system/logininfor/list｜日志查询、权限上下文与兼容入口〔FROZEN〕
- 权限：system:logininfor:list且超级管理员
- Controller→Service：`com.futurefab.system.controller.SysLogininforController#list` → `com.futurefab.system.service.ISysLogininforService#selectLogininforList`
- Request：`LoginLogPageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<LoginLogRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-04

## M01-073｜GET /system/operlog/list｜日志查询、权限上下文与兼容入口〔FROZEN〕
- 权限：system:operlog:list且超级管理员
- Controller→Service：`com.futurefab.system.controller.SysOperlogController#list` → `com.futurefab.system.service.ISysOperLogService#selectOperLogList`
- Request：`OperLogPageQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`PageResult<OperLogRow>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-04

## M01-074｜GET /system/operlog/{operId}｜日志查询、权限上下文与兼容入口〔FROZEN〕
- 权限：system:operlog:query且超级管理员
- Controller→Service：`com.futurefab.system.controller.SysOperlogController#getInfo` → `com.futurefab.system.service.ISysOperLogService#selectOperLogById`
- Request：`OperLogDetailQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`OperLogDetailView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, ACCOUNT_UNAVAILABLE, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-04

## M01-075｜GET /system/user/getInfo｜日志查询、权限上下文与兼容入口〔FROZEN〕
- 权限：AUTHENTICATED
- Controller→Service：`com.futurefab.system.controller.SysUserController#getInfo` → `com.futurefab.system.service.ISysPermissionService#getMenuPermission`
- Request：`CurrentIdentityQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`CurrentIdentityView`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, SESSION_INVALID, SESSION_REPLACED, ACCOUNT_LOCKED, ACCOUNT_UNAVAILABLE, PASSWORD_CHANGE_REQUIRED
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-04

## M01-076｜GET /system/menu/getRouters｜日志查询、权限上下文与兼容入口〔FROZEN〕
- 权限：AUTHENTICATED
- Controller→Service：`com.futurefab.system.controller.SysMenuController#getRouters` → `com.futurefab.system.service.ISysMenuService#selectMenuTreeByUserId`
- Request：`CurrentRouteQuery`（M01 存量链字段见 00 清单物理接口冻结表）
- Response：`List<RouteNodeView>`（M01 存量链，见 00 清单/契约测试）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, SESSION_INVALID, SESSION_REPLACED, ACCOUNT_LOCKED, ACCOUNT_UNAVAILABLE, PASSWORD_CHANGE_REQUIRED
- 幂等：N/A（只读）｜事务：只读（查询）
- 来源：docs/详细设计/01-系统管理/接口目录与契约定位.md ; docs/详细设计/01-系统管理/Controller请求调用时序设计.md ; docs/详细设计/01-系统管理/详细设计.md｜任务包 TP-M01-04

# M02（216 条）

## M02-001｜GET /lab/observations/current｜在线业务观测
- 权限：lab:observation:query＋设备/发生时实验室范围＋关联培养读取资格
- Controller→Service：`com.futurefab.system.controller.LabObservationController#queryCurrent` → `com.futurefab.system.service.application.m02.ObservationApplicationService#queryCurrent`
- Request `CurrentObservationQuery`：deviceKind:String*, deviceId:String*, channelCode:String*, itemIds:List<String>
- Response：`CurrentObservationView` + `DeviceRef` + `ObservationView` + `ObservationAssociationView`（主视图字段：deviceRef:DeviceRef, channelCode:String, itemId:String, current:ObservationView, lastGood:ObservationView, state:ObservationCurrentState, effectiveQuality:Quality, asOf:OffsetDateTime, staleReason:String）
- 枚举冻结：ObservationCurrentState=NORMAL/CONFLICT/UNAVAILABLE；Quality=GOOD/BAD/UNKNOWN；ValidationState=VALID/QUARANTINED；AssociationState=UNASSOCIATED/UNKNOWN/AMBIGUOUS
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, QUERY_EXPIRED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：在线业务观测存储与查询契约.md §4（CurrentView/ObservationView结构定义）；错误码全集.md｜任务包 TP-M02-14

## M02-002｜GET /lab/observations｜在线业务观测
- 权限：lab:observation:query＋设备/发生时实验室范围（culture模式叠加M03当前/历史授权）
- Controller→Service：`com.futurefab.system.controller.LabObservationController#queryObservations` → `com.futurefab.system.service.application.m02.ObservationApplicationService#queryObservations`
- Request `ObservationPageQuery`：deviceKind:String, deviceId:String, channelCode:String, cultureId:String, from:OffsetDateTime*, to:OffsetDateTime*, itemIds:List<String>, cursor:String, limit:Integer
- Response：`ObservationCursorPage`（主视图字段：rows:List<ObservationView>, nextCursor:String, asOf:OffsetDateTime, sourceWatermark:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, QUERY_EXPIRED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：在线业务观测存储与查询契约.md §4｜任务包 TP-M02-14

## M02-006｜GET /lab/observation-mappings｜在线业务观测
- 权限：lab:observation:maintain＋设备管理范围
- Controller→Service：`com.futurefab.system.controller.LabObservationController#queryMappings` → `com.futurefab.system.service.application.m02.ObservationApplicationService#queryMappings`
- Request `ObservationMappingQuery`：deviceKind:String*, deviceId:String*, channelCode:String*, rawMetricCode:String*
- Response：`ObservationMappingListView` + `ObservationMappingRow` + `MappingProfileView` + `MappingConversionView`（主视图字段：rows:List<ObservationMappingRow>）
- 枚举冻结：MeasurementScope=DEVICE/CHANNEL；ConversionKind=IDENTITY/AFFINE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：在线业务观测存储与查询契约.md §2/§4；OBS-02-业务观测增量建表.sql lab_observation_mapping列注释佐证｜任务包 TP-M02-14

## M02-007｜POST /lab/observation-mappings｜在线业务观测
- 权限：lab:observation:maintain＋设备管理范围
- Controller→Service：`com.futurefab.system.controller.LabObservationController#approveMapping` → `com.futurefab.system.service.application.m02.ObservationApplicationService#approveMapping`
- Request `ObservationMappingApproveCommand`：requestId:String*, expectedMappingVersion:Long*, deviceKind:String*, deviceId:String*, channelCode:String*, rawMetricCode:String*, itemId:String*, rawUnit:String*, unit:String*, profile:MappingProfileView*, effectiveFrom:OffsetDateTime*, effectiveTo:OffsetDateTime
- Response：`ObservationMappingMutationResult` + `MappingProfileView` + `MappingConversionView`（主视图字段：mappingId:String, mappingVersion:String）
- 枚举冻结：MeasurementScope=DEVICE/CHANNEL；ConversionKind=IDENTITY/AFFINE
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, REQUEST_ID_CONFLICT, VERSION_CONFLICT, MAPPING_OVERLAP, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_observation_mapping
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：在线业务观测存储与查询契约.md §2/§4（OBS-W02行）；requestId在Body为模块声明的WriteMeta载体，未声明X-Management-Revision故不加managementRevision｜任务包 TP-M02-14

## M02-008｜GET /lab/labbenchreactor/list｜设备实例管理
- 权限：lab:labbenchreactor:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorController#list` → `com.futurefab.system.service.ILabBenchReactorService#selectLabBenchReactorList`
- Request `LabBenchReactorPageQuery`：labId:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabBenchReactorRow`（主视图字段：reactorId:String*, labId:String*, assetNo:String, vesselNo:String, controllerNo:String, modelId:String, maxCapacity:Long, remark:String, labName:String, brand:String, brandLabel:String, category:String, categoryLabel:String, capacityUnit:String, description:String, iconPaths:List<String>, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:Str…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-01-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-03

## M02-009｜GET /lab/labbenchreactor/{reactorId}｜设备实例管理
- 权限：lab:labbenchreactor:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorController#getInfo` → `com.futurefab.system.service.ILabBenchReactorService#selectLabBenchReactorByReactorId`
- Request `LabBenchReactorDetailQuery`：reactorId:String*
- Response：`LabBenchReactorDetailView`（主视图字段：reactorId:String*, labId:String*, assetNo:String, vesselNo:String, controllerNo:String, modelId:String, maxCapacity:Long, remark:String, labName:String, brand:String, brandLabel:String, category:String, categoryLabel:String, capacityUnit:String, description:String, iconPaths:List<String>, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:Str…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-01-02; 设备实例详细设计.md §3｜任务包 TP-M02-03

## M02-010｜POST /lab/labbenchreactor｜设备实例管理
- 权限：lab:labbenchreactor:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorController#add` → `com.futurefab.system.service.ILabBenchReactorService#insertLabBenchReactor`
- Request `LabBenchReactorCreateCommand`：labId:String*, assetNo:String*, vesselNo:String*, controllerNo:String*, modelId:String*, maxCapacity:Long*, remark:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_bench_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-01-03｜任务包 TP-M02-03

## M02-011｜PUT /lab/labbenchreactor｜设备实例管理
- 权限：lab:labbenchreactor:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorController#edit` → `com.futurefab.system.service.ILabBenchReactorService#updateLabBenchReactor`
- Request `LabBenchReactorUpdateCommand`：reactorId:String*, labId:String, assetNo:String, vesselNo:String, controllerNo:String, modelId:String, maxCapacity:Long, remark:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_bench_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-01-04｜任务包 TP-M02-03

## M02-012｜GET /lab/labbenchreactor/{reactorId}/check-delete｜设备实例管理
- 权限：lab:labbenchreactor:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorController#checkDelete` → `com.futurefab.system.service.ILabBenchReactorService#checkLabBenchReactorDeleteAllowed`
- Request `LabBenchReactorDeleteCheckQuery`：reactorId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-01-05｜任务包 TP-M02-03

## M02-013｜DELETE /lab/labbenchreactor/{reactorIds}｜设备实例管理
- 权限：lab:labbenchreactor:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorController#remove` → `com.futurefab.system.service.ILabBenchReactorService#deleteLabBenchReactorByReactorIds`
- Request `LabBenchReactorDeleteCommand`：reactorIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_bench_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-01-06｜任务包 TP-M02-03

## M02-014｜GET /lab/labbenchreactor/edit-options｜设备实例管理
- 权限：lab:labbenchreactor:add或lab:labbenchreactor:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorController#editOptions` → `com.futurefab.system.service.ILabBenchReactorService#editOptions`
- Request `LabBenchReactorEditOptionQuery`：labId:String*, reactorId:String, modelId:String
- Response：`LabBenchReactorEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-01-07｜任务包 TP-M02-03

## M02-016｜GET /lab/balance/list｜设备实例管理
- 权限：lab:balance:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBalanceController#list` → `com.futurefab.system.service.ILabBalanceService#selectLabBalanceList`
- Request `LabBalancePageQuery`：labId:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabBalanceRow`（主视图字段：balanceId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, maintenance:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, spec:String, precisionValue:BigDecimal, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, enabled:Boolean, occupancy:St…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-02-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-04

## M02-017｜GET /lab/balance/{balanceId}｜设备实例管理
- 权限：lab:balance:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBalanceController#getInfo` → `com.futurefab.system.service.ILabBalanceService#selectLabBalanceByBalanceId`
- Request `LabBalanceDetailQuery`：balanceId:String*
- Response：`LabBalanceDetailView`（主视图字段：balanceId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, maintenance:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, spec:String, precisionValue:BigDecimal, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, enabled:Boolean, occupancy:St…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-02-02; 设备实例详细设计.md §3｜任务包 TP-M02-04

## M02-018｜POST /lab/balance｜设备实例管理
- 权限：lab:balance:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabBalanceController#add` → `com.futurefab.system.service.ILabBalanceService#insertLabBalance`
- Request `LabBalanceCreateCommand`：labId:String*, deviceNo:String*, assetNo:String*, modelId:String*, ownerUserId:String*, maintenance:Boolean*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_balance
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-02-03｜任务包 TP-M02-04

## M02-019｜PUT /lab/balance｜设备实例管理
- 权限：lab:balance:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabBalanceController#edit` → `com.futurefab.system.service.ILabBalanceService#updateLabBalance`
- Request `LabBalanceUpdateCommand`：balanceId:String*, labId:String, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, maintenance:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_balance
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-02-04｜任务包 TP-M02-04

## M02-020｜GET /lab/balance/{balanceId}/check-delete｜设备实例管理
- 权限：lab:balance:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBalanceController#checkDelete` → `com.futurefab.system.service.ILabBalanceService#checkLabBalanceDeleteAllowed`
- Request `LabBalanceDeleteCheckQuery`：balanceId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-02-05｜任务包 TP-M02-04

## M02-021｜DELETE /lab/balance/{balanceIds}｜设备实例管理
- 权限：lab:balance:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabBalanceController#remove` → `com.futurefab.system.service.ILabBalanceService#deleteLabBalanceByBalanceIds`
- Request `LabBalanceDeleteCommand`：balanceIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_balance
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-02-06｜任务包 TP-M02-04

## M02-022｜GET /lab/balance/edit-options｜设备实例管理
- 权限：lab:balance:add或lab:balance:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBalanceController#editOptions` → `com.futurefab.system.service.ILabBalanceService#editOptions`
- Request `LabBalanceEditOptionQuery`：labId:String*, balanceId:String, modelId:String
- Response：`LabBalanceEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-02-07｜任务包 TP-M02-04

## M02-024｜GET /lab/labperistalticpump/list｜设备实例管理
- 权限：lab:labperistalticpump:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPeristalticPumpController#list` → `com.futurefab.system.service.ILabPeristalticPumpService#selectLabPeristalticPumpList`
- Request `LabPeristalticPumpPageQuery`：labId:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabPeristalticPumpRow`（主视图字段：pumpId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, spec:String, pumpSpeed:BigDecimal, timeoutS:Long, speedFactor:BigDecimal, maintenance:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, manag…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-03-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-04

## M02-025｜GET /lab/labperistalticpump/{pumpId}｜设备实例管理
- 权限：lab:labperistalticpump:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPeristalticPumpController#getInfo` → `com.futurefab.system.service.ILabPeristalticPumpService#selectLabPeristalticPumpByPumpId`
- Request `LabPeristalticPumpDetailQuery`：pumpId:String*
- Response：`LabPeristalticPumpDetailView`（主视图字段：pumpId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, spec:String, pumpSpeed:BigDecimal, timeoutS:Long, speedFactor:BigDecimal, maintenance:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, manag…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-03-02; 设备实例详细设计.md §3｜任务包 TP-M02-04

## M02-026｜POST /lab/labperistalticpump｜设备实例管理
- 权限：lab:labperistalticpump:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabPeristalticPumpController#add` → `com.futurefab.system.service.ILabPeristalticPumpService#insertLabPeristalticPump`
- Request `LabPeristalticPumpCreateCommand`：labId:String*, deviceNo:String*, assetNo:String*, modelId:String*, ownerUserId:String*, spec:String, pumpSpeed:BigDecimal*, timeoutS:Long*, speedFactor:BigDecimal*, maintenance:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_peristaltic_pump
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-03-03｜任务包 TP-M02-04

## M02-027｜PUT /lab/labperistalticpump｜设备实例管理
- 权限：lab:labperistalticpump:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabPeristalticPumpController#edit` → `com.futurefab.system.service.ILabPeristalticPumpService#updateLabPeristalticPump`
- Request `LabPeristalticPumpUpdateCommand`：pumpId:String*, labId:String, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, spec:String, pumpSpeed:BigDecimal, timeoutS:Long, speedFactor:BigDecimal, maintenance:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_peristaltic_pump
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-03-04｜任务包 TP-M02-04

## M02-028｜GET /lab/labperistalticpump/{pumpId}/check-delete｜设备实例管理
- 权限：lab:labperistalticpump:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPeristalticPumpController#checkDelete` → `com.futurefab.system.service.ILabPeristalticPumpService#checkLabPeristalticPumpDeleteAllowed`
- Request `LabPeristalticPumpDeleteCheckQuery`：pumpId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-03-05｜任务包 TP-M02-04

## M02-029｜DELETE /lab/labperistalticpump/{pumpIds}｜设备实例管理
- 权限：lab:labperistalticpump:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabPeristalticPumpController#remove` → `com.futurefab.system.service.ILabPeristalticPumpService#deleteLabPeristalticPumpByPumpIds`
- Request `LabPeristalticPumpDeleteCommand`：pumpIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_peristaltic_pump
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-03-06｜任务包 TP-M02-04

## M02-030｜GET /lab/labperistalticpump/edit-options｜设备实例管理
- 权限：lab:labperistalticpump:add或lab:labperistalticpump:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPeristalticPumpController#editOptions` → `com.futurefab.system.service.ILabPeristalticPumpService#editOptions`
- Request `LabPeristalticPumpEditOptionQuery`：labId:String*, pumpId:String, modelId:String
- Response：`LabPeristalticPumpEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-03-07｜任务包 TP-M02-04

## M02-032｜GET /lab/labairpump/list｜设备实例管理
- 权限：lab:labairpump:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabAirPumpController#list` → `com.futurefab.system.service.ILabAirPumpService#selectLabAirPumpList`
- Request `LabAirPumpPageQuery`：labId:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabAirPumpRow`（主视图字段：airPumpId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, workSpeed:BigDecimal, durationS:Long, speedFactor:BigDecimal, maintenance:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevi…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-04-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-04

## M02-033｜GET /lab/labairpump/{airPumpId}｜设备实例管理
- 权限：lab:labairpump:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabAirPumpController#getInfo` → `com.futurefab.system.service.ILabAirPumpService#selectLabAirPumpByAirPumpId`
- Request `LabAirPumpDetailQuery`：airPumpId:String*
- Response：`LabAirPumpDetailView`（主视图字段：airPumpId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, workSpeed:BigDecimal, durationS:Long, speedFactor:BigDecimal, maintenance:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevi…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-04-02; 设备实例详细设计.md §3｜任务包 TP-M02-04

## M02-034｜POST /lab/labairpump｜设备实例管理
- 权限：lab:labairpump:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabAirPumpController#add` → `com.futurefab.system.service.ILabAirPumpService#insertLabAirPump`
- Request `LabAirPumpCreateCommand`：labId:String*, deviceNo:String*, assetNo:String*, modelId:String*, ownerUserId:String*, workSpeed:BigDecimal*, durationS:Long*, speedFactor:BigDecimal*, maintenance:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_air_pump
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-04-03｜任务包 TP-M02-04

## M02-035｜PUT /lab/labairpump｜设备实例管理
- 权限：lab:labairpump:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabAirPumpController#edit` → `com.futurefab.system.service.ILabAirPumpService#updateLabAirPump`
- Request `LabAirPumpUpdateCommand`：airPumpId:String*, labId:String, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, workSpeed:BigDecimal, durationS:Long, speedFactor:BigDecimal, maintenance:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_air_pump
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-04-04｜任务包 TP-M02-04

## M02-036｜GET /lab/labairpump/{airPumpId}/check-delete｜设备实例管理
- 权限：lab:labairpump:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabAirPumpController#checkDelete` → `com.futurefab.system.service.ILabAirPumpService#checkLabAirPumpDeleteAllowed`
- Request `LabAirPumpDeleteCheckQuery`：airPumpId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-04-05｜任务包 TP-M02-04

## M02-037｜DELETE /lab/labairpump/{airPumpIds}｜设备实例管理
- 权限：lab:labairpump:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabAirPumpController#remove` → `com.futurefab.system.service.ILabAirPumpService#deleteLabAirPumpByAirPumpIds`
- Request `LabAirPumpDeleteCommand`：airPumpIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_air_pump
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-04-06｜任务包 TP-M02-04

## M02-038｜GET /lab/labairpump/edit-options｜设备实例管理
- 权限：lab:labairpump:add或lab:labairpump:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabAirPumpController#editOptions` → `com.futurefab.system.service.ILabAirPumpService#editOptions`
- Request `LabAirPumpEditOptionQuery`：labId:String*, airPumpId:String, modelId:String
- Response：`LabAirPumpEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-04-07｜任务包 TP-M02-04

## M02-040｜GET /lab/labdetector/list｜设备实例管理
- 权限：lab:labdetector:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDetectorController#list` → `com.futurefab.system.service.ILabDetectorService#selectLabDetectorList`
- Request `LabDetectorPageQuery`：labId:String, venueId:String, detectClass:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabDetectorRow`（主视图字段：detectorId:String*, labId:String*, detectClass:String, modelId:String, assetNo:String, deviceNo:String, ownerUserId:String, venueId:String, labName:String, modelName:String, detectType:String, description:String, detectionCount:String, venueName:String, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, mainte…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-05-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-05

## M02-041｜GET /lab/labdetector/{detectorId}｜设备实例管理
- 权限：lab:labdetector:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDetectorController#getInfo` → `com.futurefab.system.service.ILabDetectorService#selectLabDetectorByDetectorId`
- Request `LabDetectorDetailQuery`：detectorId:String*
- Response：`LabDetectorDetailView`（主视图字段：detectorId:String*, labId:String*, detectClass:String, modelId:String, assetNo:String, deviceNo:String, ownerUserId:String, venueId:String, labName:String, modelName:String, detectType:String, description:String, detectionCount:String, venueName:String, ownerDisplayName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, mainte…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-05-02; 设备实例详细设计.md §3｜任务包 TP-M02-05

## M02-042｜POST /lab/labdetector｜设备实例管理
- 权限：lab:labdetector:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabDetectorController#add` → `com.futurefab.system.service.ILabDetectorService#insertLabDetector`
- Request `LabDetectorCreateCommand`：labId:String*, detectClass:String*, modelId:String*, assetNo:String*, deviceNo:String*, ownerUserId:String*, venueId:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_detector
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-05-03｜任务包 TP-M02-05

## M02-043｜PUT /lab/labdetector｜设备实例管理
- 权限：lab:labdetector:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabDetectorController#edit` → `com.futurefab.system.service.ILabDetectorService#updateLabDetector`
- Request `LabDetectorUpdateCommand`：detectorId:String*, labId:String, detectClass:String, modelId:String, assetNo:String, deviceNo:String, ownerUserId:String, venueId:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_detector
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-05-04｜任务包 TP-M02-05

## M02-044｜GET /lab/labdetector/{detectorId}/check-delete｜设备实例管理
- 权限：lab:labdetector:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDetectorController#checkDelete` → `com.futurefab.system.service.ILabDetectorService#checkLabDetectorDeleteAllowed`
- Request `LabDetectorDeleteCheckQuery`：detectorId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-05-05｜任务包 TP-M02-05

## M02-045｜DELETE /lab/labdetector/{detectorIds}｜设备实例管理
- 权限：lab:labdetector:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabDetectorController#remove` → `com.futurefab.system.service.ILabDetectorService#deleteLabDetectorByDetectorIds`
- Request `LabDetectorDeleteCommand`：detectorIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_detector
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-05-06｜任务包 TP-M02-05

## M02-046｜GET /lab/labdetector/edit-options｜设备实例管理
- 权限：lab:labdetector:add或lab:labdetector:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDetectorController#editOptions` → `com.futurefab.system.service.ILabDetectorService#editOptions`
- Request `LabDetectorEditOptionQuery`：labId:String*, detectorId:String, modelId:String
- Response：`LabDetectorEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-05-07｜任务包 TP-M02-05

## M02-048｜GET /lab/labintegratedreactor/list｜设备实例管理
- 权限：lab:labintegratedreactor:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabIntegratedReactorController#list` → `com.futurefab.system.service.ILabIntegratedReactorService#selectLabIntegratedReactorList`
- Request `LabIntegratedReactorPageQuery`：labId:String, venueId:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabIntegratedReactorRow`（主视图字段：integratedId:String*, labId:String*, modelId:String, deviceNo:String, assetNo:String, reactorName:String, ownerUserId:String, floorScaleId:String, feedScaleId:String, venueId:String, floorScaleLowLimit:BigDecimal, floorScaleHighLimit:BigDecimal, maintenance:Boolean, airPumpId:String, relayId:String, alarmId:String, needExternalPump:String, labName:String, modelName:String, capacity:BigDecimal, spe…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-06-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-03

## M02-049｜GET /lab/labintegratedreactor/{integratedId}｜设备实例管理
- 权限：lab:labintegratedreactor:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabIntegratedReactorController#getInfo` → `com.futurefab.system.service.ILabIntegratedReactorService#selectDetail`
- Request `LabIntegratedReactorDetailQuery`：integratedId:String*
- Response：`LabIntegratedReactorDetailView` + `PumpConfigView` + `ExternalPumpView` + `CapabilityView`（主视图字段：integratedId:String*, labId:String*, modelId:String, deviceNo:String, assetNo:String, reactorName:String, ownerUserId:String, floorScaleId:String, feedScaleId:String, venueId:String, floorScaleLowLimit:BigDecimal, floorScaleHighLimit:BigDecimal, maintenance:Boolean, pumpConfigs:List<PumpConfigView>, airPumpId:String, relayId:String, alarmId:String, needExternalPump:String, externalPumps:List<Exter…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-06-02; 设备实例详细设计.md §3｜任务包 TP-M02-03

## M02-050｜POST /lab/labintegratedreactor｜设备实例管理
- 权限：lab:labintegratedreactor:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabIntegratedReactorController#add` → `com.futurefab.system.service.ILabIntegratedReactorService#create`
- Request `LabIntegratedReactorCreateCommand`：labId:String*, modelId:String*, deviceNo:String*, assetNo:String*, reactorName:String*, ownerUserId:String*, floorScaleId:String*, feedScaleId:String*, venueId:String, floorScaleLowLimit:BigDecimal*, floorScaleHighLimit:BigDecimal*, maintenance:Boolean, pumpConfigs:List<PumpConfigInput>*, airPumpId:String, relayId:String, alarmId:String, needExternalPump:String*, externalPumps:List<ExternalPumpInput>*, requestId:String*, managementRevision:String*
- Response：`PumpConfigInput` + `ExternalPumpInput`（主视图字段：pumpNo:Long*, rangeValue:BigDecimal*, strategy:String）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_integrated_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-06-03｜任务包 TP-M02-03

## M02-051｜PUT /lab/labintegratedreactor/integratedId｜设备实例管理
- 权限：lab:labintegratedreactor:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabIntegratedReactorController#edit` → `com.futurefab.system.service.ILabIntegratedReactorService#update`
- Request `LabIntegratedReactorUpdateCommand`：integratedId:String*, labId:String, modelId:String, deviceNo:String, assetNo:String, reactorName:String, ownerUserId:String, floorScaleId:String, feedScaleId:String, venueId:String, floorScaleLowLimit:BigDecimal, floorScaleHighLimit:BigDecimal, maintenance:Boolean, pumpConfigs:List<PumpConfigInput>, airPumpId:String, relayId:String, alarmId:String, needExternalPump:String, externalPumps:List<ExternalPumpInput>, requestId:String*, managementRevision:String*
- Response：`PumpConfigInput` + `ExternalPumpInput`（主视图字段：pumpNo:Long*, rangeValue:BigDecimal*, strategy:String）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_integrated_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-06-04｜任务包 TP-M02-03

## M02-052｜GET /lab/labintegratedreactor/{integratedId}/check-delete｜设备实例管理
- 权限：lab:labintegratedreactor:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabIntegratedReactorController#checkDelete` → `com.futurefab.system.service.ILabIntegratedReactorService#checkLabIntegratedReactorDeleteAllowed`
- Request `LabIntegratedReactorDeleteCheckQuery`：integratedId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-06-05｜任务包 TP-M02-03

## M02-053｜DELETE /lab/labintegratedreactor/{integratedIds}｜设备实例管理
- 权限：lab:labintegratedreactor:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabIntegratedReactorController#remove` → `com.futurefab.system.service.ILabIntegratedReactorService#deleteLabIntegratedReactorByIntegratedIds`
- Request `LabIntegratedReactorDeleteCommand`：integratedIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_integrated_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-06-06｜任务包 TP-M02-03

## M02-054｜GET /lab/labintegratedreactor/edit-options｜设备实例管理
- 权限：lab:labintegratedreactor:add或lab:labintegratedreactor:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabIntegratedReactorController#editOptions` → `com.futurefab.system.service.ILabIntegratedReactorService#editOptions`
- Request `LabIntegratedReactorEditOptionQuery`：labId:String*, integratedId:String, modelId:String
- Response：`LabIntegratedReactorEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-06-07｜任务包 TP-M02-03

## M02-056｜GET /lab/culturecontainer/list｜设备实例管理
- 权限：lab:culturecontainer:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabCultureContainerController#list` → `com.futurefab.system.service.ILabCultureContainerService#selectLabCultureContainerList`
- Request `LabCultureContainerPageQuery`：labId:String, venueId:String, containerType:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabCultureContainerRow`（主视图字段：containerId:String*, labId:String*, containerType:String, specId:String, containerName:String, venueId:String, remark:String, labName:String, containerNo:String, containerTypeLabel:String, spec:String, volumeMl:BigDecimal, venueName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupa…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-07-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-05

## M02-057｜GET /lab/culturecontainer/{containerId}｜设备实例管理
- 权限：lab:culturecontainer:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabCultureContainerController#getInfo` → `com.futurefab.system.service.ILabCultureContainerService#selectLabCultureContainerByContainerId`
- Request `LabCultureContainerDetailQuery`：containerId:String*
- Response：`LabCultureContainerDetailView`（主视图字段：containerId:String*, labId:String*, containerType:String, specId:String, containerName:String, venueId:String, remark:String, labName:String, containerNo:String, containerTypeLabel:String, spec:String, volumeMl:BigDecimal, venueName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupa…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-07-02; 设备实例详细设计.md §3｜任务包 TP-M02-05

## M02-058｜POST /lab/culturecontainer｜设备实例管理
- 权限：lab:culturecontainer:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabCultureContainerController#add` → `com.futurefab.system.service.ILabCultureContainerService#insertLabCultureContainer`
- Request `LabCultureContainerCreateCommand`：labId:String*, containerType:String*, specId:String*, containerName:String*, venueId:String, remark:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_culture_container
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-07-03｜任务包 TP-M02-05

## M02-059｜PUT /lab/culturecontainer｜设备实例管理
- 权限：lab:culturecontainer:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabCultureContainerController#edit` → `com.futurefab.system.service.ILabCultureContainerService#updateLabCultureContainer`
- Request `LabCultureContainerUpdateCommand`：containerId:String*, labId:String, containerType:String, specId:String, containerName:String, venueId:String, remark:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_culture_container
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-07-04｜任务包 TP-M02-05

## M02-060｜GET /lab/culturecontainer/{containerId}/check-delete｜设备实例管理
- 权限：lab:culturecontainer:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabCultureContainerController#checkDelete` → `com.futurefab.system.service.ILabCultureContainerService#checkLabCultureContainerDeleteAllowed`
- Request `LabCultureContainerDeleteCheckQuery`：containerId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-07-05｜任务包 TP-M02-05

## M02-061｜DELETE /lab/culturecontainer/{containerIds}｜设备实例管理
- 权限：lab:culturecontainer:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabCultureContainerController#remove` → `com.futurefab.system.service.ILabCultureContainerService#deleteLabCultureContainerByContainerIds`
- Request `LabCultureContainerDeleteCommand`：containerIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_culture_container
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-07-06｜任务包 TP-M02-05

## M02-062｜GET /lab/culturecontainer/edit-options｜设备实例管理
- 权限：lab:culturecontainer:add或lab:culturecontainer:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabCultureContainerController#editOptions` → `com.futurefab.system.service.ILabCultureContainerService#editOptions`
- Request `LabCultureContainerEditOptionQuery`：labId:String*, containerId:String, modelId:String
- Response：`LabCultureContainerEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-07-07｜任务包 TP-M02-05

## M02-064｜GET /lab/labfloorscale/list｜设备实例管理
- 权限：lab:labfloorscale:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabFloorScaleController#list` → `com.futurefab.system.service.ILabFloorScaleService#selectLabFloorScaleList`
- Request `LabFloorScalePageQuery`：labId:String, venueId:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabFloorScaleRow`（主视图字段：scaleId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, venueId:String, alarmLowLimit:BigDecimal, maintenance:Boolean, isFeedScale:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, spec:String, precisionValue:BigDecimal, alarmHighLimit:BigDecimal, venueName:String, ownerDisplayName:String, createBy:String, updateBy:String, crea…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-08-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-03

## M02-065｜GET /lab/labfloorscale/{scaleId}｜设备实例管理
- 权限：lab:labfloorscale:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabFloorScaleController#getInfo` → `com.futurefab.system.service.ILabFloorScaleService#selectLabFloorScaleByScaleId`
- Request `LabFloorScaleDetailQuery`：scaleId:String*
- Response：`LabFloorScaleDetailView`（主视图字段：scaleId:String*, labId:String*, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, venueId:String, alarmLowLimit:BigDecimal, maintenance:Boolean, isFeedScale:Boolean, labName:String, brand:String, brandLabel:String, modelName:String, spec:String, precisionValue:BigDecimal, alarmHighLimit:BigDecimal, venueName:String, ownerDisplayName:String, createBy:String, updateBy:String, crea…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-08-02; 设备实例详细设计.md §3｜任务包 TP-M02-03

## M02-066｜POST /lab/labfloorscale｜设备实例管理
- 权限：lab:labfloorscale:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabFloorScaleController#add` → `com.futurefab.system.service.ILabFloorScaleService#insertLabFloorScale`
- Request `LabFloorScaleCreateCommand`：labId:String*, deviceNo:String*, assetNo:String*, modelId:String*, ownerUserId:String*, venueId:String, alarmLowLimit:BigDecimal*, maintenance:Boolean, isFeedScale:Boolean*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_floor_scale
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-08-03｜任务包 TP-M02-03

## M02-067｜PUT /lab/labfloorscale｜设备实例管理
- 权限：lab:labfloorscale:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabFloorScaleController#edit` → `com.futurefab.system.service.ILabFloorScaleService#updateLabFloorScale`
- Request `LabFloorScaleUpdateCommand`：scaleId:String*, labId:String, deviceNo:String, assetNo:String, modelId:String, ownerUserId:String, venueId:String, alarmLowLimit:BigDecimal, maintenance:Boolean, isFeedScale:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_floor_scale
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-08-04｜任务包 TP-M02-03

## M02-068｜GET /lab/labfloorscale/{scaleId}/check-delete｜设备实例管理
- 权限：lab:labfloorscale:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabFloorScaleController#checkDelete` → `com.futurefab.system.service.ILabFloorScaleService#checkLabFloorScaleDeleteAllowed`
- Request `LabFloorScaleDeleteCheckQuery`：scaleId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-08-05｜任务包 TP-M02-03

## M02-069｜DELETE /lab/labfloorscale/{scaleIds}｜设备实例管理
- 权限：lab:labfloorscale:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabFloorScaleController#remove` → `com.futurefab.system.service.ILabFloorScaleService#deleteLabFloorScaleByScaleIds`
- Request `LabFloorScaleDeleteCommand`：scaleIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_floor_scale
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-08-06｜任务包 TP-M02-03

## M02-070｜GET /lab/labfloorscale/edit-options｜设备实例管理
- 权限：lab:labfloorscale:add或lab:labfloorscale:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabFloorScaleController#editOptions` → `com.futurefab.system.service.ILabFloorScaleService#editOptions`
- Request `LabFloorScaleEditOptionQuery`：labId:String*, scaleId:String, modelId:String
- Response：`LabFloorScaleEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-08-07｜任务包 TP-M02-03

## M02-072｜GET /lab/downstreamdevice/list｜设备实例管理
- 权限：lab:downstreamDevice:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDownstreamDeviceController#list` → `com.futurefab.system.service.ILabDownstreamDeviceService#selectLabDownstreamDeviceList`
- Request `LabDownstreamDevicePageQuery`：labId:String, venueId:String, deviceType:String, modelId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabDownstreamDeviceRow`（主视图字段：deviceId:String*, labId:String*, deviceType:String, modelId:String, assetNo:String, deviceNo:String, ownerUserId:String, venueId:String, isTabletDirect:Boolean, enabled:Boolean, communicationType:String, labName:String, brand:String, brandLabel:String, modelName:String, spec:String, precisionValue:BigDecimal, description:String, venueName:String, ownerDisplayName:String, createBy:String, updateBy:…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-09-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-05

## M02-073｜GET /lab/downstreamdevice/{deviceId}｜设备实例管理
- 权限：lab:downstreamDevice:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDownstreamDeviceController#getInfo` → `com.futurefab.system.service.ILabDownstreamDeviceService#selectLabDownstreamDeviceByDeviceId`
- Request `LabDownstreamDeviceDetailQuery`：deviceId:String*
- Response：`LabDownstreamDeviceDetailView`（主视图字段：deviceId:String*, labId:String*, deviceType:String, modelId:String, assetNo:String, deviceNo:String, ownerUserId:String, venueId:String, isTabletDirect:Boolean, enabled:Boolean, communicationType:String, labName:String, brand:String, brandLabel:String, modelName:String, spec:String, precisionValue:BigDecimal, description:String, venueName:String, ownerDisplayName:String, createBy:String, updateBy:…全集见 spec 文件）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-09-02; 设备实例详细设计.md §3｜任务包 TP-M02-05

## M02-074｜POST /lab/downstreamdevice｜设备实例管理
- 权限：lab:downstreamDevice:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabDownstreamDeviceController#add` → `com.futurefab.system.service.ILabDownstreamDeviceService#insertLabDownstreamDevice`
- Request `LabDownstreamDeviceCreateCommand`：labId:String*, deviceType:String*, modelId:String*, assetNo:String*, deviceNo:String*, ownerUserId:String*, venueId:String, isTabletDirect:Boolean, enabled:Boolean, communicationType:String*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_downstream_device
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-09-03｜任务包 TP-M02-05

## M02-075｜PUT /lab/downstreamdevice｜设备实例管理
- 权限：lab:downstreamDevice:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabDownstreamDeviceController#edit` → `com.futurefab.system.service.ILabDownstreamDeviceService#updateLabDownstreamDevice`
- Request `LabDownstreamDeviceUpdateCommand`：deviceId:String*, labId:String, deviceType:String, modelId:String, assetNo:String, deviceNo:String, ownerUserId:String, venueId:String, isTabletDirect:Boolean, enabled:Boolean, communicationType:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_downstream_device
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-09-04｜任务包 TP-M02-05

## M02-076｜GET /lab/downstreamdevice/{deviceId}/check-delete｜设备实例管理
- 权限：lab:downstreamDevice:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDownstreamDeviceController#checkDelete` → `com.futurefab.system.service.ILabDownstreamDeviceService#checkLabDownstreamDeviceDeleteAllowed`
- Request `LabDownstreamDeviceDeleteCheckQuery`：deviceId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-09-05｜任务包 TP-M02-05

## M02-077｜DELETE /lab/downstreamdevice/{deviceIds}｜设备实例管理
- 权限：lab:downstreamDevice:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabDownstreamDeviceController#remove` → `com.futurefab.system.service.ILabDownstreamDeviceService#deleteLabDownstreamDeviceByDeviceIds`
- Request `LabDownstreamDeviceDeleteCommand`：deviceIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_downstream_device
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-09-06｜任务包 TP-M02-05

## M02-078｜GET /lab/downstreamdevice/edit-options｜设备实例管理
- 权限：lab:downstreamDevice:add或lab:downstreamDevice:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDownstreamDeviceController#editOptions` → `com.futurefab.system.service.ILabDownstreamDeviceService#editOptions`
- Request `LabDownstreamDeviceEditOptionQuery`：labId:String*, deviceId:String, modelId:String
- Response：`LabDownstreamDeviceEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-09-07｜任务包 TP-M02-05

## M02-080｜GET /lab/soundalarm/list｜设备实例管理
- 权限：lab:soundalarm:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabSoundAlarmController#list` → `com.futurefab.system.service.ILabSoundAlarmService#selectLabSoundAlarmList`
- Request `LabSoundAlarmPageQuery`：labId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabSoundAlarmRow`（主视图字段：alarmId:String*, labId:String*, deviceNo:String, assetNo:String, description:String, labName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupancy:String, connectivity:String, configurationReady:Boolean, configurationIssues:List<String>）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-10-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-06

## M02-081｜GET /lab/soundalarm/{alarmId}｜设备实例管理
- 权限：lab:soundalarm:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabSoundAlarmController#getInfo` → `com.futurefab.system.service.ILabSoundAlarmService#selectLabSoundAlarmByAlarmId`
- Request `LabSoundAlarmDetailQuery`：alarmId:String*
- Response：`LabSoundAlarmDetailView`（主视图字段：alarmId:String*, labId:String*, deviceNo:String, assetNo:String, description:String, labName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupancy:String, connectivity:String, configurationReady:Boolean, configurationIssues:List<String>）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-10-02; 设备实例详细设计.md §3｜任务包 TP-M02-06

## M02-082｜POST /lab/soundalarm｜设备实例管理
- 权限：lab:soundalarm:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabSoundAlarmController#add` → `com.futurefab.system.service.ILabSoundAlarmService#insertLabSoundAlarm`
- Request `LabSoundAlarmCreateCommand`：labId:String*, deviceNo:String*, assetNo:String*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_sound_alarm
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-10-03｜任务包 TP-M02-06

## M02-083｜PUT /lab/soundalarm｜设备实例管理
- 权限：lab:soundalarm:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabSoundAlarmController#edit` → `com.futurefab.system.service.ILabSoundAlarmService#updateLabSoundAlarm`
- Request `LabSoundAlarmUpdateCommand`：alarmId:String*, labId:String, deviceNo:String, assetNo:String, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_sound_alarm
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-10-04｜任务包 TP-M02-06

## M02-084｜GET /lab/soundalarm/{alarmId}/check-delete｜设备实例管理
- 权限：lab:soundalarm:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabSoundAlarmController#checkDelete` → `com.futurefab.system.service.ILabSoundAlarmService#checkLabSoundAlarmDeleteAllowed`
- Request `LabSoundAlarmDeleteCheckQuery`：alarmId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-10-05｜任务包 TP-M02-06

## M02-085｜DELETE /lab/soundalarm/{alarmIds}｜设备实例管理
- 权限：lab:soundalarm:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabSoundAlarmController#remove` → `com.futurefab.system.service.ILabSoundAlarmService#deleteLabSoundAlarmByAlarmIds`
- Request `LabSoundAlarmDeleteCommand`：alarmIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_sound_alarm
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-10-06｜任务包 TP-M02-06

## M02-086｜GET /lab/soundalarm/edit-options｜设备实例管理
- 权限：lab:soundalarm:add或lab:soundalarm:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabSoundAlarmController#editOptions` → `com.futurefab.system.service.ILabSoundAlarmService#editOptions`
- Request `LabSoundAlarmEditOptionQuery`：labId:String*, alarmId:String
- Response：`LabSoundAlarmEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-10-07｜任务包 TP-M02-06

## M02-088｜GET /lab/printer/list｜设备实例管理
- 权限：lab:printer:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPrinterController#list` → `com.futurefab.system.service.ILabPrinterService#selectLabPrinterList`
- Request `LabPrinterPageQuery`：labId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabPrinterRow`（主视图字段：printerId:String*, labId:String*, deviceNo:String, assetNo:String, printLimit:Long, labName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupancy:String, connectivity:String, configurationReady:Boolean, configurationIssues:List<String>）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-11-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-06

## M02-089｜GET /lab/printer/{printerId}｜设备实例管理
- 权限：lab:printer:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPrinterController#getInfo` → `com.futurefab.system.service.ILabPrinterService#selectLabPrinterByPrinterId`
- Request `LabPrinterDetailQuery`：printerId:String*
- Response：`LabPrinterDetailView`（主视图字段：printerId:String*, labId:String*, deviceNo:String, assetNo:String, printLimit:Long, labName:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupancy:String, connectivity:String, configurationReady:Boolean, configurationIssues:List<String>）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-11-02; 设备实例详细设计.md §3｜任务包 TP-M02-06

## M02-092｜GET /lab/printer/{printerId}/check-delete｜设备实例管理
- 权限：lab:printer:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPrinterController#checkDelete` → `com.futurefab.system.service.ILabPrinterService#checkLabPrinterDeleteAllowed`
- Request `LabPrinterDeleteCheckQuery`：printerId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-11-05｜任务包 TP-M02-06

## M02-094｜GET /lab/printer/edit-options｜设备实例管理
- 权限：lab:printer:add或lab:printer:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabPrinterController#editOptions` → `com.futurefab.system.service.ILabPrinterService#editOptions`
- Request `LabPrinterEditOptionQuery`：labId:String*, printerId:String
- Response：`LabPrinterEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-11-07｜任务包 TP-M02-06

## M02-096｜GET /lab/relay/list｜设备实例管理
- 权限：lab:relay:list＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabRelayController#list` → `com.futurefab.system.service.ILabRelayService#selectLabRelayList`
- Request `LabRelayPageQuery`：labId:String, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`LabRelayRow`（主视图字段：relayId:String*, labId:String*, deviceNo:String, assetNo:String, labName:String, relayStatus:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupancy:String, connectivity:String, configurationReady:Boolean, configurationIssues:List<String>）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN；RelayStatusValue=0/1
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-12-01; 实例列表与详情读取投影.md §2–3｜任务包 TP-M02-06

## M02-097｜GET /lab/relay/{relayId}｜设备实例管理
- 权限：lab:relay:query＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabRelayController#getInfo` → `com.futurefab.system.service.ILabRelayService#selectLabRelayByRelayId`
- Request `LabRelayDetailQuery`：relayId:String*
- Response：`LabRelayDetailView`（主视图字段：relayId:String*, labId:String*, deviceNo:String, assetNo:String, labName:String, relayStatus:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:OffsetDateTime, managementRevision:String, maintenance:Boolean, enabled:Boolean, occupancy:String, connectivity:String, configurationReady:Boolean, configurationIssues:List<String>）
- 枚举冻结：OccupancyState=IDLE/RESERVED/IN_USE/UNKNOWN；ConnectivityState=ONLINE/OFFLINE/UNKNOWN；RelayStatusValue=0/1
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实例列表与详情读取投影.md §3 INS-12-02; 设备实例详细设计.md §3｜任务包 TP-M02-06

## M02-098｜POST /lab/relay｜设备实例管理
- 权限：lab:relay:add＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabRelayController#add` → `com.futurefab.system.service.ILabRelayService#insertLabRelay`
- Request `LabRelayCreateCommand`：labId:String*, deviceNo:String*, assetNo:String*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_relay
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-12-03｜任务包 TP-M02-06

## M02-099｜PUT /lab/relay｜设备实例管理
- 权限：lab:relay:edit＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabRelayController#edit` → `com.futurefab.system.service.ILabRelayService#updateLabRelay`
- Request `LabRelayUpdateCommand`：relayId:String*, labId:String, deviceNo:String, assetNo:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_relay
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：设备实例详细设计.md §4; 逐接口完整契约清单.md §INS-12-04｜任务包 TP-M02-06

## M02-100｜GET /lab/relay/{relayId}/check-delete｜设备实例管理
- 权限：lab:relay:remove＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabRelayController#checkDelete` → `com.futurefab.system.service.ILabRelayService#checkLabRelayDeleteAllowed`
- Request `LabRelayDeleteCheckQuery`：relayId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-12-05｜任务包 TP-M02-06

## M02-101｜DELETE /lab/relay/{relayIds}｜设备实例管理
- 权限：lab:relay:remove＋实验室操作等级
- Controller→Service：`com.futurefab.system.controller.LabRelayController#remove` → `com.futurefab.system.service.ILabRelayService#deleteLabRelayByRelayIds`
- Request `LabRelayDeleteCommand`：relayIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_relay
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-12-06｜任务包 TP-M02-06

## M02-102｜GET /lab/relay/edit-options｜设备实例管理
- 权限：lab:relay:add或lab:relay:edit＋实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabRelayController#editOptions` → `com.futurefab.system.service.ILabRelayService#editOptions`
- Request `LabRelayEditOptionQuery`：labId:String*, relayId:String
- Response：`LabRelayEditOptionsView` + `Option` + `ReferenceOption`（主视图字段：models:List<Option>*, owners:List<Option>*, venues:List<Option>*, references:List<ReferenceOption>*, managementRevision:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：逐接口完整契约清单.md §INS-12-07｜任务包 TP-M02-06

## M02-109｜GET /lab/pumpconnection/reactor/{reactorId}｜台式默认连接与打印排版
- 权限：lab:pumpconnection:query＋实验室可见
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorControllerController#getByReactor` → `com.futurefab.system.service.ILabBenchReactorControllerService#selectLabBenchReactorControllerByReactorId`
- Request `PumpConnectionByReactorQuery`：reactorId:String*
- Response：`PumpConnectionDetailView` + `PumpConnectionChannel`（主视图字段：connectionId:String*, labId:String*, reactorId:String*, controllerNo:String, balanceId:String, balanceKind:String, remark:String, channels:List<PumpConnectionChannel>*, managementRevision:String*）
- 枚举冻结：BalanceKind=FLOOR_SCALE/BALANCE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, CONFIGURATION_INCOMPLETE, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：默认连接与打印排版接口契约.md §2｜任务包 TP-M02-12

## M02-110｜PUT /lab/pumpconnection/reactor/{reactorId}｜台式默认连接与打印排版
- 权限：lab:pumpconnection:edit＋原实例实验室操作等级1
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorControllerController#saveByReactor` → `com.futurefab.system.service.ILabBenchReactorControllerService#saveLabBenchReactorControllerByReactorId`
- Request `PumpConnectionByReactorSaveCommand`：reactorId:String*, balanceId:String, balanceKind:String, remark:String, channels:List<PumpConnectionChannelInput>*, requestId:String*, managementRevision:String*
- Response：`PumpConnectionChannelInput`（主视图字段：channelId:String*, pumpType:String, pumpId:String, defaultSpeed:Long, maxSpeed:Long, materialName:String, feedContainer:String, speedStrategy:String）
- 枚举冻结：BalanceKind=FLOOR_SCALE/BALANCE
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, CONFIGURATION_INCOMPLETE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_bench_reactor_controller
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：默认连接与打印排版接口契约.md §3（brief response_vo=MutationResult；文档注：成功实际返回提交后聚合视图）｜任务包 TP-M02-12

## M02-111｜GET /lab/printer/{printerId}/layout｜台式默认连接与打印排版
- 权限：lab:printer:query＋对象可见
- Controller→Service：`com.futurefab.system.controller.LabPrinterController#getLayout` → `com.futurefab.system.service.ILabPrinterLayoutSettingService#selectLabPrinterLayoutSettingByPrinterId`
- Request `PrinterLayoutQuery`：printerId:String*
- Response：`PrinterLayoutView` + `PrinterLayoutRow`（主视图字段：printerId:String*, rows:List<PrinterLayoutRow>*, managementRevision:String*, configurationReady:Boolean*, configurationIssues:List<String>*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, CONFIGURATION_INCOMPLETE, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：默认连接与打印排版接口契约.md §4｜任务包 TP-M02-12

## M02-112｜POST /lab/printer/{printerId}/layout｜台式默认连接与打印排版
- 权限：lab:printer:edit＋真实实验室操作资格
- Controller→Service：`com.futurefab.system.controller.LabPrinterController#saveLayout` → `com.futurefab.system.service.ILabPrinterLayoutSettingService#insertLabPrinterLayoutSettings`
- Request `PrinterLayoutSaveCommand`：printerId:String*, rows:List<PrinterLayoutRowInput>*, requestId:String*, managementRevision:String*
- Response：`PrinterLayoutRowInput`（主视图字段：rowNo:Long*, fontSize:Long*）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, CONFIGURATION_INCOMPLETE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_printer_layout_setting
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：默认连接与打印排版接口契约.md §5｜任务包 TP-M02-12

## M02-113｜GET /device/benchreactor/list｜设备型号库
- 权限：device:benchreactor:list
- Controller→Service：`com.futurefab.system.controller.DevBenchReactorController#list` → `com.futurefab.system.service.IDevBenchReactorService#selectDevBenchReactorList`
- Request `DevBenchReactorPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:String, endDate:String, brandList:List<String>
- Response：`DevBenchReactorRow`（主视图字段：modelId:String, brand:String, brandLabel:String, category:String, categoryLabel:String, capacityUnit:String, capacityUnitLabel:String, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:Lis…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §3；设备型号库设计.md §16｜任务包 TP-M02-08

## M02-114｜GET /device/benchreactor/{modelId}｜设备型号库
- 权限：device:benchreactor:query
- Controller→Service：`com.futurefab.system.controller.DevBenchReactorController#getInfo` → `com.futurefab.system.service.IDevBenchReactorService#selectDevBenchReactorByModelId`
- Request `DevBenchReactorDetailQuery`：modelId:String*
- Response：`DevBenchReactorDetailView`（主视图字段：modelId:String, brand:String, brandLabel:String, category:String, categoryLabel:String, capacityUnit:String, capacityUnitLabel:String, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:Lis…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§3；设备型号库设计.md §16｜任务包 TP-M02-08

## M02-115｜POST /device/benchreactor｜设备型号库
- 权限：device:benchreactor:add
- Controller→Service：`com.futurefab.system.controller.DevBenchReactorController#add` → `com.futurefab.system.service.IDevBenchReactorService#insertDevBenchReactor`
- Request `DevBenchReactorCreateCommand`：brand:String*, category:String*, capacityUnit:String*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_bench_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §3/§4/§16；逐接口完整契约清单.md#型号B（白名单brand/category/capacityUnit/description；不接受capacity/icon_path/del_flag/审计列）｜任务包 TP-M02-08

## M02-116｜PUT /device/benchreactor｜设备型号库
- 权限：device:benchreactor:edit
- Controller→Service：`com.futurefab.system.controller.DevBenchReactorController#edit` → `com.futurefab.system.service.IDevBenchReactorService#updateDevBenchReactor`
- Request `DevBenchReactorUpdateCommand`：modelId:String*, brand:String*, category:String*, capacityUnit:String*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_bench_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §4/§8/§16；逐接口完整契约清单.md#型号B｜任务包 TP-M02-08

## M02-117｜GET /device/benchreactor/{modelId}/check-delete｜设备型号库
- 权限：device:benchreactor:query
- Controller→Service：`com.futurefab.system.controller.DevBenchReactorController#checkDelete` → `com.futurefab.system.service.IDevBenchReactorService#checkDevBenchReactorDeleteAllowed`
- Request `DevBenchReactorDeleteCheckQuery`：modelId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-B05（data:{canDelete,referenceCount,managementRevision}为公共外壳DeletePrecheckResult）｜任务包 TP-M02-08

## M02-118｜DELETE /device/benchreactor/{modelIds}｜设备型号库
- 权限：device:benchreactor:remove
- Controller→Service：`com.futurefab.system.controller.DevBenchReactorController#remove` → `com.futurefab.system.service.IDevBenchReactorService#deleteDevBenchReactorByModelIds`
- Request `DevBenchReactorDeleteCommand`：modelIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_bench_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-B06；设备型号库设计.md §4/§16｜任务包 TP-M02-08

## M02-119｜GET /device/benchreactor/check-unique｜设备型号库
- 权限：device:benchreactor:query
- Controller→Service：`com.futurefab.system.controller.DevBenchReactorController#checkUnique` → `com.futurefab.system.service.IDevBenchReactorService#checkDevBenchReactorUnique`
- Request `DevBenchReactorUniquenessCheckQuery`：brand:String*, category:String*, modelId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-B07（data:{unique:boolean}为公共外壳；联合键见设备型号库设计§2/§4）｜任务包 TP-M02-08

## M02-120｜GET /device/integratedreactor/list｜设备型号库
- 权限：device:integratedreactor:list
- Controller→Service：`com.futurefab.system.controller.DevIntegratedReactorController#list` → `com.futurefab.system.service.IDevIntegratedReactorService#selectDevIntegratedReactorList`
- Request `DevIntegratedReactorPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:String, endDate:String, pressureUnit:String
- Response：`DevIntegratedReactorRow`（主视图字段：modelId:String, modelName:String, capacity:BigDecimal, spec:String, pumpCount:Long, mfcCount:Long, pressureUnit:String, thresholdWeightG:BigDecimal, temperatureControl:Boolean, weightControl:Boolean, pressureControl:Boolean, pressureUnitLabel:String, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetD…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §4；设备型号库设计.md §16｜任务包 TP-M02-08

## M02-121｜GET /device/integratedreactor/{modelId}｜设备型号库
- 权限：device:integratedreactor:query
- Controller→Service：`com.futurefab.system.controller.DevIntegratedReactorController#getInfo` → `com.futurefab.system.service.IDevIntegratedReactorService#selectDevIntegratedReactorByModelId`
- Request `DevIntegratedReactorDetailQuery`：modelId:String*
- Response：`DevIntegratedReactorDetailView`（主视图字段：modelId:String, modelName:String, capacity:BigDecimal, spec:String, pumpCount:Long, mfcCount:Long, pressureUnit:String, thresholdWeightG:BigDecimal, temperatureControl:Boolean, weightControl:Boolean, pressureControl:Boolean, pressureUnitLabel:String, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetD…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§4；设备型号库设计.md §16｜任务包 TP-M02-08

## M02-122｜POST /device/integratedreactor｜设备型号库
- 权限：device:integratedreactor:add
- Controller→Service：`com.futurefab.system.controller.DevIntegratedReactorController#add` → `com.futurefab.system.service.IDevIntegratedReactorService#insertDevIntegratedReactor`
- Request `DevIntegratedReactorCreateCommand`：modelName:String*, capacity:BigDecimal*, spec:String, pumpCount:Long*, mfcCount:Long*, pressureUnit:String*, thresholdWeightG:BigDecimal*, temperatureControl:Boolean*, weightControl:Boolean*, pressureControl:Boolean*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_integrated_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §10.1/§11/§16；逐接口完整契约清单.md#型号I｜任务包 TP-M02-08

## M02-123｜PUT /device/integratedreactor｜设备型号库
- 权限：device:integratedreactor:edit
- Controller→Service：`com.futurefab.system.controller.DevIntegratedReactorController#edit` → `com.futurefab.system.service.IDevIntegratedReactorService#updateDevIntegratedReactor`
- Request `DevIntegratedReactorUpdateCommand`：modelId:String*, modelName:String*, capacity:BigDecimal*, spec:String, pumpCount:Long*, mfcCount:Long*, pressureUnit:String*, thresholdWeightG:BigDecimal*, temperatureControl:Boolean*, weightControl:Boolean*, pressureControl:Boolean*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_integrated_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §8/§10.1/§15/§16；逐接口完整契约清单.md#型号I｜任务包 TP-M02-08

## M02-124｜GET /device/integratedreactor/{modelId}/check-delete｜设备型号库
- 权限：device:integratedreactor:query
- Controller→Service：`com.futurefab.system.controller.DevIntegratedReactorController#checkDelete` → `com.futurefab.system.service.IDevIntegratedReactorService#checkDevIntegratedReactorDeleteAllowed`
- Request `DevIntegratedReactorDeleteCheckQuery`：modelId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-I05（DeletePrecheckResult公共外壳）｜任务包 TP-M02-08

## M02-125｜DELETE /device/integratedreactor/{modelIds}｜设备型号库
- 权限：device:integratedreactor:remove
- Controller→Service：`com.futurefab.system.controller.DevIntegratedReactorController#remove` → `com.futurefab.system.service.IDevIntegratedReactorService#deleteDevIntegratedReactorByModelIds`
- Request `DevIntegratedReactorDeleteCommand`：modelIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_integrated_reactor
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-I06｜任务包 TP-M02-08

## M02-126｜GET /device/integratedreactor/check-unique｜设备型号库
- 权限：device:integratedreactor:query
- Controller→Service：`com.futurefab.system.controller.DevIntegratedReactorController#checkUnique` → `com.futurefab.system.service.IDevIntegratedReactorService#checkDevIntegratedReactorUnique`
- Request `DevIntegratedReactorUniquenessCheckQuery`：modelName:String*, modelId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-I07；设备型号库设计.md §10.1｜任务包 TP-M02-08

## M02-127｜GET /device/containerspec/list｜设备型号库
- 权限：device:containerspec:list
- Controller→Service：`com.futurefab.system.controller.DevCultureContainerSpecController#list` → `com.futurefab.system.service.IDevCultureContainerSpecService#selectDevCultureContainerSpecList`
- Request `DevCultureContainerSpecPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:String, endDate:String, containerTypeList:List<String>
- Response：`DevCultureContainerSpecRow`（主视图字段：specId:String, containerType:String, containerTypeLabel:String, spec:String, volumeMl:BigDecimal, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:List<String>）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §5；设备型号库设计.md §16｜任务包 TP-M02-09

## M02-128｜GET /device/containerspec/{specId}｜设备型号库
- 权限：device:containerspec:query
- Controller→Service：`com.futurefab.system.controller.DevCultureContainerSpecController#getInfo` → `com.futurefab.system.service.IDevCultureContainerSpecService#selectDevCultureContainerSpecBySpecId`
- Request `DevCultureContainerSpecDetailQuery`：specId:String*
- Response：`DevCultureContainerSpecDetailView`（主视图字段：specId:String, containerType:String, containerTypeLabel:String, spec:String, volumeMl:BigDecimal, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:List<String>）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§5；设备型号库设计.md §16｜任务包 TP-M02-09

## M02-129｜POST /device/containerspec｜设备型号库
- 权限：device:containerspec:add
- Controller→Service：`com.futurefab.system.controller.DevCultureContainerSpecController#add` → `com.futurefab.system.service.IDevCultureContainerSpecService#insertDevCultureContainerSpec`
- Request `DevCultureContainerSpecCreateCommand`：containerType:String*, spec:String*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_culture_container_spec
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §10.2/§11/§16.2；逐接口完整契约清单.md#型号C｜任务包 TP-M02-09

## M02-130｜PUT /device/containerspec｜设备型号库
- 权限：device:containerspec:edit
- Controller→Service：`com.futurefab.system.controller.DevCultureContainerSpecController#edit` → `com.futurefab.system.service.IDevCultureContainerSpecService#updateDevCultureContainerSpec`
- Request `DevCultureContainerSpecUpdateCommand`：specId:String*, containerType:String*, spec:String*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_culture_container_spec
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §8/§10.2/§16；逐接口完整契约清单.md#型号C｜任务包 TP-M02-09

## M02-131｜GET /device/containerspec/{specId}/check-delete｜设备型号库
- 权限：device:containerspec:query
- Controller→Service：`com.futurefab.system.controller.DevCultureContainerSpecController#checkDelete` → `com.futurefab.system.service.IDevCultureContainerSpecService#checkDevCultureContainerSpecDeleteAllowed`
- Request `DevCultureContainerSpecDeleteCheckQuery`：specId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-C05（DeletePrecheckResult公共外壳）｜任务包 TP-M02-09

## M02-132｜DELETE /device/containerspec/{specIds}｜设备型号库
- 权限：device:containerspec:remove
- Controller→Service：`com.futurefab.system.controller.DevCultureContainerSpecController#remove` → `com.futurefab.system.service.IDevCultureContainerSpecService#deleteDevCultureContainerSpecBySpecIds`
- Request `DevCultureContainerSpecDeleteCommand`：specIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_culture_container_spec
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-C06｜任务包 TP-M02-09

## M02-133｜GET /device/containerspec/check-unique｜设备型号库
- 权限：device:containerspec:query
- Controller→Service：`com.futurefab.system.controller.DevCultureContainerSpecController#checkUnique` → `com.futurefab.system.service.IDevCultureContainerSpecService#checkDevCultureContainerSpecUnique`
- Request `DevCultureContainerSpecUniquenessCheckQuery`：containerType:String*, spec:String*, specId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-C07；设备型号库设计.md §10.2｜任务包 TP-M02-09

## M02-134｜GET /device/devfloorscale/list｜设备型号库
- 权限：device:devfloorscale:list
- Controller→Service：`com.futurefab.system.controller.DevFloorScaleController#list` → `com.futurefab.system.service.IDevFloorScaleService#selectDevFloorScaleList`
- Request `DevFloorScalePageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:String, endDate:String, brandList:List<String>, spec:String
- Response：`DevFloorScaleRow`（主视图字段：modelId:String, brand:String, brandLabel:String, modelName:String, modelNameLabel:String, spec:String, precisionValue:BigDecimal, communicationTypes:List<String>, imagePaths:List<String>, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §6；设备型号库设计.md §16｜任务包 TP-M02-09

## M02-135｜GET /device/devfloorscale/{modelId}｜设备型号库
- 权限：device:devfloorscale:query
- Controller→Service：`com.futurefab.system.controller.DevFloorScaleController#getInfo` → `com.futurefab.system.service.IDevFloorScaleService#selectDevFloorScaleByModelId`
- Request `DevFloorScaleDetailQuery`：modelId:String*
- Response：`DevFloorScaleDetailView`（主视图字段：modelId:String, brand:String, brandLabel:String, modelName:String, modelNameLabel:String, spec:String, precisionValue:BigDecimal, communicationTypes:List<String>, imagePaths:List<String>, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§6；设备型号库设计.md §16｜任务包 TP-M02-09

## M02-136｜POST /device/devfloorscale｜设备型号库
- 权限：device:devfloorscale:add
- Controller→Service：`com.futurefab.system.controller.DevFloorScaleController#add` → `com.futurefab.system.service.IDevFloorScaleService#insertDevFloorScale`
- Request `DevFloorScaleCreateCommand`：brand:String*, modelName:String*, spec:String*, precisionValue:BigDecimal, communicationTypes:List<String>*, imagePaths:List<String>, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_floor_scale_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §10.3/§11/§16.3；逐接口完整契约清单.md#型号W｜任务包 TP-M02-09

## M02-137｜PUT /device/devfloorscale｜设备型号库
- 权限：device:devfloorscale:edit
- Controller→Service：`com.futurefab.system.controller.DevFloorScaleController#edit` → `com.futurefab.system.service.IDevFloorScaleService#updateDevFloorScale`
- Request `DevFloorScaleUpdateCommand`：modelId:String*, brand:String*, modelName:String*, spec:String*, precisionValue:BigDecimal, communicationTypes:List<String>*, imagePaths:List<String>, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_floor_scale_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §8/§10.3/§16；逐接口完整契约清单.md#型号W｜任务包 TP-M02-09

## M02-138｜GET /device/devfloorscale/{modelId}/check-delete｜设备型号库
- 权限：device:devfloorscale:query
- Controller→Service：`com.futurefab.system.controller.DevFloorScaleController#checkDelete` → `com.futurefab.system.service.IDevFloorScaleService#checkDevFloorScaleDeleteAllowed`
- Request `DevFloorScaleDeleteCheckQuery`：modelId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-W05（DeletePrecheckResult公共外壳）｜任务包 TP-M02-09

## M02-139｜DELETE /device/devfloorscale/{modelIds}｜设备型号库
- 权限：device:devfloorscale:remove
- Controller→Service：`com.futurefab.system.controller.DevFloorScaleController#remove` → `com.futurefab.system.service.IDevFloorScaleService#deleteDevFloorScaleByModelIds`
- Request `DevFloorScaleDeleteCommand`：modelIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_floor_scale_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-W06｜任务包 TP-M02-09

## M02-140｜GET /device/devfloorscale/check-unique｜设备型号库
- 权限：device:devfloorscale:query
- Controller→Service：`com.futurefab.system.controller.DevFloorScaleController#checkUnique` → `com.futurefab.system.service.IDevFloorScaleService#checkDevFloorScaleUnique`
- Request `DevFloorScaleUniquenessCheckQuery`：brand:String*, modelName:String*, modelId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-W07；设备型号库设计.md §10.3｜任务包 TP-M02-09

## M02-141｜GET /device/devdetector/list｜设备型号库
- 权限：device:devdetector:list
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#list` → `com.futurefab.system.service.IDevDetectorService#selectDevDetectorList`
- Request `DevDetectorPageQuery`：pageNum:Integer, pageSize:Integer, beginDate:String, endDate:String, detectClassList:List<String>, detectType:String
- Response：`DevDetectorRow`（主视图字段：modelId:String, detectClass:String, detectClassLabel:String, modelName:String, detectType:String, singleSendLimit:Long, channelCount:Long, columnCount:Long, carrierType:String, workSendLimit:Long, timeout:Long, supportDilution:Boolean, communicationTypes:List<String>, supportStored:Boolean, sendMode:String, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, upd…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §7；设备型号库设计.md §16｜任务包 TP-M02-08

## M02-142｜GET /device/devdetector/{modelId}｜设备型号库
- 权限：device:devdetector:query
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#getInfo` → `com.futurefab.system.service.IDevDetectorService#selectDevDetectorByModelId`
- Request `DevDetectorDetailQuery`：modelId:String*
- Response：`DevDetectorDetailView`（主视图字段：modelId:String, detectClass:String, detectClassLabel:String, modelName:String, detectType:String, singleSendLimit:Long, channelCount:Long, columnCount:Long, carrierType:String, workSendLimit:Long, timeout:Long, supportDilution:Boolean, communicationTypes:List<String>, supportStored:Boolean, sendMode:String, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, upd…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§7；设备型号库设计.md §16｜任务包 TP-M02-08

## M02-143｜POST /device/devdetector｜设备型号库
- 权限：device:devdetector:add
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#add` → `com.futurefab.system.service.IDevDetectorService#insertDevDetector`
- Request `DevDetectorCreateCommand`：detectClass:String*, modelName:String*, singleSendLimit:Long*, channelCount:Long*, columnCount:Long*, carrierType:String*, workSendLimit:Long*, timeout:Long*, supportDilution:Boolean*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 枚举冻结：DetectorCarrierType=1/2/3
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_detector_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §10.4/§11/§16.1；逐接口完整契约清单.md#型号D｜任务包 TP-M02-08

## M02-144｜PUT /device/devdetector｜设备型号库
- 权限：device:devdetector:edit
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#edit` → `com.futurefab.system.service.IDevDetectorService#updateDevDetector`
- Request `DevDetectorUpdateCommand`：modelId:String*, detectClass:String*, modelName:String*, singleSendLimit:Long*, channelCount:Long*, columnCount:Long*, carrierType:String*, workSendLimit:Long*, timeout:Long*, supportDilution:Boolean*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_detector_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §8/§10.4/§16；逐接口完整契约清单.md#型号D｜任务包 TP-M02-08

## M02-145｜GET /device/devdetector/{modelId}/check-delete｜设备型号库
- 权限：device:devdetector:query
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#checkDelete` → `com.futurefab.system.service.IDevDetectorService#checkDevDetectorDeleteAllowed`
- Request `DevDetectorDeleteCheckQuery`：modelId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-D05（DeletePrecheckResult公共外壳）｜任务包 TP-M02-08

## M02-146｜DELETE /device/devdetector/{modelIds}｜设备型号库
- 权限：device:devdetector:remove
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#remove` → `com.futurefab.system.service.IDevDetectorService#deleteDevDetectorByModelIds`
- Request `DevDetectorDeleteCommand`：modelIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_detector_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-D06｜任务包 TP-M02-08

## M02-147｜GET /device/devdetector/check-unique｜设备型号库
- 权限：device:devdetector:query
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#checkUnique` → `com.futurefab.system.service.IDevDetectorService#checkDevDetectorUnique`
- Request `DevDetectorUniquenessCheckQuery`：detectClass:String*, modelName:String*, modelId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-D07；设备型号库设计.md §10.4/§16.1｜任务包 TP-M02-08

## M02-148｜GET /device/devperistalticpump/list｜设备型号库
- 权限：device:devperistalticpump:list
- Controller→Service：`com.futurefab.system.controller.DevPeristalticPumpController#list` → `com.futurefab.system.service.IDevPeristalticPumpService#selectDevPeristalticPumpList`
- Request `DevPeristalticPumpPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:String, endDate:String, brandList:List<String>
- Response：`DevPeristalticPumpRow`（主视图字段：modelId:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:List<String>）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §8；设备型号库设计.md §16｜任务包 TP-M02-09

## M02-149｜GET /device/devperistalticpump/{modelId}｜设备型号库
- 权限：device:devperistalticpump:query
- Controller→Service：`com.futurefab.system.controller.DevPeristalticPumpController#getInfo` → `com.futurefab.system.service.IDevPeristalticPumpService#selectDevPeristalticPumpByModelId`
- Request `DevPeristalticPumpDetailQuery`：modelId:String*
- Response：`DevPeristalticPumpDetailView`（主视图字段：modelId:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:List<String>）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§8；设备型号库设计.md §16｜任务包 TP-M02-09

## M02-150｜POST /device/devperistalticpump｜设备型号库
- 权限：device:devperistalticpump:add
- Controller→Service：`com.futurefab.system.controller.DevPeristalticPumpController#add` → `com.futurefab.system.service.IDevPeristalticPumpService#insertDevPeristalticPump`
- Request `DevPeristalticPumpCreateCommand`：brand:String*, modelName:String*, maxFlow:BigDecimal, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_peristaltic_pump_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §10.5/§11；逐接口完整契约清单.md#型号P｜任务包 TP-M02-09

## M02-151｜PUT /device/devperistalticpump｜设备型号库
- 权限：device:devperistalticpump:edit
- Controller→Service：`com.futurefab.system.controller.DevPeristalticPumpController#edit` → `com.futurefab.system.service.IDevPeristalticPumpService#updateDevPeristalticPump`
- Request `DevPeristalticPumpUpdateCommand`：modelId:String*, brand:String*, modelName:String*, maxFlow:BigDecimal, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_peristaltic_pump_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §8/§10.5/§16；逐接口完整契约清单.md#型号P｜任务包 TP-M02-09

## M02-152｜GET /device/devperistalticpump/{modelId}/check-delete｜设备型号库
- 权限：device:devperistalticpump:query
- Controller→Service：`com.futurefab.system.controller.DevPeristalticPumpController#checkDelete` → `com.futurefab.system.service.IDevPeristalticPumpService#checkDevPeristalticPumpDeleteAllowed`
- Request `DevPeristalticPumpDeleteCheckQuery`：modelId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-P05（DeletePrecheckResult公共外壳）｜任务包 TP-M02-09

## M02-153｜DELETE /device/devperistalticpump/{modelIds}｜设备型号库
- 权限：device:devperistalticpump:remove
- Controller→Service：`com.futurefab.system.controller.DevPeristalticPumpController#remove` → `com.futurefab.system.service.IDevPeristalticPumpService#deleteDevPeristalticPumpByModelIds`
- Request `DevPeristalticPumpDeleteCommand`：modelIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_peristaltic_pump_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-P06｜任务包 TP-M02-09

## M02-154｜GET /device/devperistalticpump/check-unique｜设备型号库
- 权限：device:devperistalticpump:query
- Controller→Service：`com.futurefab.system.controller.DevPeristalticPumpController#checkUnique` → `com.futurefab.system.service.IDevPeristalticPumpService#checkDevPeristalticPumpUnique`
- Request `DevPeristalticPumpUniquenessCheckQuery`：brand:String*, modelName:String*, modelId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-P07；设备型号库设计.md §10.5｜任务包 TP-M02-09

## M02-155｜GET /device/devairpum/list｜设备型号库
- 权限：device:devairpum:list
- Controller→Service：`com.futurefab.system.controller.DevAirPumpController#list` → `com.futurefab.system.service.IDevAirPumpService#selectDevAirPumpList`
- Request `DevAirPumpPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:String, endDate:String, brandList:List<String>
- Response：`DevAirPumpRow`（主视图字段：modelId:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:List<String>）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §9；设备型号库设计.md §16｜任务包 TP-M02-10

## M02-156｜GET /device/devairpum/{modelId}｜设备型号库
- 权限：device:devairpum:query
- Controller→Service：`com.futurefab.system.controller.DevAirPumpController#getInfo` → `com.futurefab.system.service.IDevAirPumpService#selectDevAirPumpByModelId`
- Request `DevAirPumpDetailQuery`：modelId:String*
- Response：`DevAirPumpDetailView`（主视图字段：modelId:String, brand:String, brandLabel:String, modelName:String, maxFlow:BigDecimal, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationReady:Boolean, configurationIssues:List<String>）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§9；设备型号库设计.md §16｜任务包 TP-M02-10

## M02-157｜POST /device/devairpum｜设备型号库
- 权限：device:devairpum:add
- Controller→Service：`com.futurefab.system.controller.DevAirPumpController#add` → `com.futurefab.system.service.IDevAirPumpService#insertDevAirPump`
- Request `DevAirPumpCreateCommand`：brand:String*, modelName:String*, maxFlow:BigDecimal, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_air_pump_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §10.5/§11；逐接口完整契约清单.md#型号A｜任务包 TP-M02-10

## M02-158｜PUT /device/devairpum｜设备型号库
- 权限：device:devairpum:edit
- Controller→Service：`com.futurefab.system.controller.DevAirPumpController#edit` → `com.futurefab.system.service.IDevAirPumpService#updateDevAirPump`
- Request `DevAirPumpUpdateCommand`：modelId:String*, brand:String*, modelName:String*, maxFlow:BigDecimal, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_air_pump_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §8/§10.5/§16；逐接口完整契约清单.md#型号A｜任务包 TP-M02-10

## M02-159｜GET /device/devairpum/{modelId}/check-delete｜设备型号库
- 权限：device:devairpum:query
- Controller→Service：`com.futurefab.system.controller.DevAirPumpController#checkDelete` → `com.futurefab.system.service.IDevAirPumpService#checkDevAirPumpDeleteAllowed`
- Request `DevAirPumpDeleteCheckQuery`：modelId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-A05（DeletePrecheckResult公共外壳）｜任务包 TP-M02-10

## M02-160｜DELETE /device/devairpum/{modelIds}｜设备型号库
- 权限：device:devairpum:remove
- Controller→Service：`com.futurefab.system.controller.DevAirPumpController#remove` → `com.futurefab.system.service.IDevAirPumpService#deleteDevAirPumpByModelIds`
- Request `DevAirPumpDeleteCommand`：modelIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_air_pump_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-A06｜任务包 TP-M02-10

## M02-161｜GET /device/devairpum/check-unique｜设备型号库
- 权限：device:devairpum:query
- Controller→Service：`com.futurefab.system.controller.DevAirPumpController#checkUnique` → `com.futurefab.system.service.IDevAirPumpService#checkDevAirPumpUnique`
- Request `DevAirPumpUniquenessCheckQuery`：brand:String*, modelName:String*, modelId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-A07；设备型号库设计.md §10.5｜任务包 TP-M02-10

## M02-162｜GET /device/devAnalyzerModel/list｜设备型号库
- 权限：device:devAnalyzerModel:list
- Controller→Service：`com.futurefab.system.controller.DevAnalyzerModelController#list` → `com.futurefab.system.service.IDevAnalyzerModelService#selectDevAnalyzerModelList`
- Request `DevAnalyzerModelPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:String, endDate:String, deviceTypeList:List<String>, brandList:List<String>
- Response：`DevAnalyzerModelRow`（主视图字段：analyzerId:String, deviceType:String, deviceTypeLabel:String, brand:String, brandLabel:String, modelName:String, communicationTypes:List<String>, imagePaths:List<String>, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationRe…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号专属筛选与内部能力读取契约.md §1—2；型号查询响应与契约样例.md §10；设备型号库设计.md §16｜任务包 TP-M02-10

## M02-163｜GET /device/devAnalyzerModel/{analyzerId}｜设备型号库
- 权限：device:devAnalyzerModel:query
- Controller→Service：`com.futurefab.system.controller.DevAnalyzerModelController#getInfo` → `com.futurefab.system.service.IDevAnalyzerModelService#selectDevAnalyzerModelByAnalyzerId`
- Request `DevAnalyzerModelDetailQuery`：analyzerId:String*
- Response：`DevAnalyzerModelDetailView`（主视图字段：analyzerId:String, deviceType:String, deviceTypeLabel:String, brand:String, brandLabel:String, modelName:String, communicationTypes:List<String>, imagePaths:List<String>, description:String, iconPaths:List<String>, createBy:String, createTime:OffsetDateTime, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>, managementRevision:String, configurationRe…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/型号查询响应与契约样例.md §1/§10；设备型号库设计.md §16｜任务包 TP-M02-10

## M02-164｜POST /device/devAnalyzerModel｜设备型号库
- 权限：device:devAnalyzerModel:add
- Controller→Service：`com.futurefab.system.controller.DevAnalyzerModelController#add` → `com.futurefab.system.service.IDevAnalyzerModelService#insertDevAnalyzerModel`
- Request `DevAnalyzerModelCreateCommand`：deviceType:String*, brand:String*, modelName:String*, communicationTypes:List<String>*, imagePaths:List<String>*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_analyzer_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §10.6/§11/§16.3；逐接口完整契约清单.md#型号N｜任务包 TP-M02-10

## M02-165｜PUT /device/devAnalyzerModel｜设备型号库
- 权限：device:devAnalyzerModel:edit
- Controller→Service：`com.futurefab.system.controller.DevAnalyzerModelController#edit` → `com.futurefab.system.service.IDevAnalyzerModelService#updateDevAnalyzerModel`
- Request `DevAnalyzerModelUpdateCommand`：analyzerId:String*, deviceType:String*, brand:String*, modelName:String*, communicationTypes:List<String>*, imagePaths:List<String>*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_analyzer_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §8/§10.6/§16；逐接口完整契约清单.md#型号N｜任务包 TP-M02-10

## M02-166｜GET /device/devAnalyzerModel/{analyzerId}/check-delete｜设备型号库
- 权限：device:devAnalyzerModel:query
- Controller→Service：`com.futurefab.system.controller.DevAnalyzerModelController#checkDelete` → `com.futurefab.system.service.IDevAnalyzerModelService#checkDevAnalyzerModelDeleteAllowed`
- Request `DevAnalyzerModelDeleteCheckQuery`：analyzerId:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeletePrecheckResult`）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-N05（DeletePrecheckResult公共外壳）｜任务包 TP-M02-10

## M02-167｜DELETE /device/devAnalyzerModel/{analyzerIds}｜设备型号库
- 权限：device:devAnalyzerModel:remove
- Controller→Service：`com.futurefab.system.controller.DevAnalyzerModelController#remove` → `com.futurefab.system.service.IDevAnalyzerModelService#deleteDevAnalyzerModelByAnalyzerIds`
- Request `DevAnalyzerModelDeleteCommand`：analyzerIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_analyzer_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-N06｜任务包 TP-M02-10

## M02-168｜GET /device/devAnalyzerModel/check-unique｜设备型号库
- 权限：device:devAnalyzerModel:query
- Controller→Service：`com.futurefab.system.controller.DevAnalyzerModelController#checkUnique` → `com.futurefab.system.service.IDevAnalyzerModelService#checkDevAnalyzerModelUnique`
- Request `DevAnalyzerModelUniquenessCheckQuery`：brand:String*, modelName:String*, analyzerId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md#MDL-N07；设备型号库设计.md §10.6｜任务包 TP-M02-10

## M02-169｜PUT /device/devdetector/{modelId}/runtime-profile｜设备型号库
- 权限：device:devdetector:edit
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#saveRuntimeProfile` → `com.futurefab.system.service.IDevDetectorService#saveRuntimeProfile`
- Request `DetectorRuntimeProfileSaveCommand`：modelId:String*, schemaVersion:Long*, detectType:String*, communicationTypes:List<String>*, supportStored:Boolean*, sendMode:String*, singleSendLimit:Long*, workSendLimit:Long*, layout:DetectorRuntimeProfileLayout, scheduling:DetectorRuntimeProfileScheduling, workCapacity:DetectorRuntimeProfileWorkCapacity, protection:DetectorRuntimeProfileProtection, occlusion:DetectorRuntimeProfileOcclusion, expectedProfileRevision:String, requestId:String*, managementRevision:String*
- Response：`DetectorRuntimeProfile` + `DetectorRuntimeProfileLayout` + `DetectorRuntimeProfileScheduling` + `DetectorRuntimeProfileWorkCapacity` + `DetectorRuntimeProfileProtection` + `DetectorRuntimeProfileOcclusion` + `DetectorRuntimeProfileIssue`（主视图字段：schemaVersion:Long, modelId:String, detectType:String, communicationTypes:List<String>, supportStored:Boolean, sendMode:String, singleSendLimit:Long, workSendLimit:Long, layout:DetectorRuntimeProfileLayout, scheduling:DetectorRuntimeProfileScheduling, workCapacity:DetectorRuntimeProfileWorkCapacity, protection:DetectorRuntimeProfileProtection, occlusion:DetectorRuntimeProfileOcclusion, profileRevi…全集见 spec 文件）
- 枚举冻结：DetectorSendMode=single/column；RuntimeLayoutTopology=LIST/MATRIX/RING；RuntimeSelectionOrder=NONE/PHYSICAL_CYCLE/ADAPTER_REPORTED；RuntimeWorkCapacityUnit=SAMPLE/COLUMN；RuntimeLockScope=POSITION/COLUMN
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_detector_model
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §16.1（runtime-profile本期冻结字段清单）｜任务包 TP-M02-08

## M02-170｜GET /device/devdetector/{modelId}/runtime-profile｜设备型号库
- 权限：device:devdetector:query
- Controller→Service：`com.futurefab.system.controller.DevDetectorController#getRuntimeProfile` → `com.futurefab.system.service.IDevDetectorService#getRuntimeProfile`
- Request `DetectorRuntimeProfileQuery`：modelId:String*
- Response：`DetectorRuntimeProfile` + `DetectorRuntimeProfileLayout` + `DetectorRuntimeProfileScheduling` + `DetectorRuntimeProfileWorkCapacity` + `DetectorRuntimeProfileProtection` + `DetectorRuntimeProfileOcclusion` + `DetectorRuntimeProfileIssue`（主视图字段：schemaVersion:Long, modelId:String, detectType:String, communicationTypes:List<String>, supportStored:Boolean, sendMode:String, singleSendLimit:Long, workSendLimit:Long, layout:DetectorRuntimeProfileLayout, scheduling:DetectorRuntimeProfileScheduling, workCapacity:DetectorRuntimeProfileWorkCapacity, protection:DetectorRuntimeProfileProtection, occlusion:DetectorRuntimeProfileOcclusion, profileRevi…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/设备型号库设计.md §16.1；接口目录与契约定位.md#定位019｜任务包 TP-M02-08

## M02-171｜GET /lab/calibrationObject/list｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：lab:calibrationObject:list
- Controller→Service：`com.futurefab.system.controller.CalibrationObjectController#list` → `com.futurefab.system.service.ICalibrationObjectService#selectCalibrationObjectList`
- Request `CalibrationObjectPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate
- Response：`CalibrationObjectRow`（主视图字段：objectId:String, weightName:String, netWeight:BigDecimal, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §公共ListQuery/校准对象｜任务包 TP-M02-15

## M02-172｜GET /lab/calibrationObject/{objectId}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：lab:calibrationObject:query
- Controller→Service：`com.futurefab.system.controller.CalibrationObjectController#getInfo` → `com.futurefab.system.service.ICalibrationObjectService#selectCalibrationObjectByObjectId`
- Request `CalibrationObjectDetailQuery`：objectId:String*
- Response：`CalibrationObjectDetailView`（主视图字段：objectId:String, weightName:String, netWeight:BigDecimal, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §GET /lab/calibrationObject/{objectId}｜任务包 TP-M02-15

## M02-173｜POST /lab/calibrationObject｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：lab:calibrationObject:add
- Controller→Service：`com.futurefab.system.controller.CalibrationObjectController#add` → `com.futurefab.system.service.ICalibrationObjectService#insertCalibrationObject`
- Request `CalibrationObjectCreateCommand`：weightName:String*, netWeight:BigDecimal*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=calibration_object
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §校准对象字段白名单/POST｜任务包 TP-M02-15

## M02-174｜PUT /lab/calibrationObject｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：lab:calibrationObject:edit
- Controller→Service：`com.futurefab.system.controller.CalibrationObjectController#edit` → `com.futurefab.system.service.ICalibrationObjectService#updateCalibrationObject`
- Request `CalibrationObjectUpdateCommand`：objectId:String*, weightName:String*, netWeight:BigDecimal*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=calibration_object
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §PUT /lab/calibrationObject｜任务包 TP-M02-15

## M02-175｜DELETE /lab/calibrationObject/{objectIds}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：lab:calibrationObject:remove
- Controller→Service：`com.futurefab.system.controller.CalibrationObjectController#remove` → `com.futurefab.system.service.ICalibrationObjectService#deleteCalibrationObjectByObjectIds`
- Request `CalibrationObjectDeleteCommand`：objectIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=calibration_object
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §DELETE /lab/calibrationObject/{objectIds}｜任务包 TP-M02-15

## M02-176｜GET /lab/liquidBag/list｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:liquidBag:list
- Controller→Service：`com.futurefab.system.controller.LiquidBagController#list` → `com.futurefab.system.service.ILiquidBagService#selectLiquidBagList`
- Request `LiquidBagPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate
- Response：`LiquidBagRow`（主视图字段：bagId:String, description:String, model:String, capacity:Long, tareWeight:Long, residualAmount:Long, lowerLimitVol:Long, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String, iconUrl:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §液袋｜任务包 TP-M02-15

## M02-177｜GET /lab/liquidBag/{bagId}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:liquidBag:query
- Controller→Service：`com.futurefab.system.controller.LiquidBagController#getInfo` → `com.futurefab.system.service.ILiquidBagService#selectLiquidBagByBagId`
- Request `LiquidBagDetailQuery`：bagId:String*
- Response：`LiquidBagDetailView`（主视图字段：bagId:String, description:String, model:String, capacity:Long, tareWeight:Long, residualAmount:Long, lowerLimitVol:Long, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String, iconUrl:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §GET /lab/liquidBag/{bagId}｜任务包 TP-M02-15

## M02-178｜POST /lab/liquidBag｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:liquidBag:add
- Controller→Service：`com.futurefab.system.controller.LiquidBagController#add` → `com.futurefab.system.service.ILiquidBagService#insertLiquidBag`
- Request `LiquidBagCreateCommand`：description:String*, model:String*, capacity:Long*, tareWeight:Long*, residualAmount:Long*, lowerLimitVol:Long*, iconPath:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=liquid_bag
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §液袋字段白名单/POST｜任务包 TP-M02-15

## M02-179｜PUT /lab/liquidBag｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:liquidBag:edit
- Controller→Service：`com.futurefab.system.controller.LiquidBagController#edit` → `com.futurefab.system.service.ILiquidBagService#updateLiquidBag`
- Request `LiquidBagUpdateCommand`：bagId:String*, description:String*, model:String*, capacity:Long*, tareWeight:Long*, residualAmount:Long*, lowerLimitVol:Long*, iconPath:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=liquid_bag
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §PUT /lab/liquidBag｜任务包 TP-M02-15

## M02-180｜DELETE /lab/liquidBag/{bagIds}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:liquidBag:remove
- Controller→Service：`com.futurefab.system.controller.LiquidBagController#remove` → `com.futurefab.system.service.ILiquidBagService#deleteLiquidBagByBagIds`
- Request `LiquidBagDeleteCommand`：bagIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=liquid_bag
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §DELETE /lab/liquidBag/{bagIds}｜任务包 TP-M02-15

## M02-181｜GET /lab/feedMedium/list｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:feedMedium:list
- Controller→Service：`com.futurefab.system.controller.FeedMediumController#list` → `com.futurefab.system.service.IFeedMediumService#selectFeedMediumList`
- Request `FeedMediumPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String
- Response：`FeedMediumRow`（主视图字段：mediumId:String, mediumName:String, sugarConcentration:BigDecimal, isSugarFeed:Boolean, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §培养基｜任务包 TP-M02-15

## M02-182｜GET /lab/feedMedium/{mediumId}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:feedMedium:query
- Controller→Service：`com.futurefab.system.controller.FeedMediumController#getInfo` → `com.futurefab.system.service.IFeedMediumService#selectFeedMediumByMediumId`
- Request `FeedMediumDetailQuery`：mediumId:String*
- Response：`FeedMediumDetailView`（主视图字段：mediumId:String, mediumName:String, sugarConcentration:BigDecimal, isSugarFeed:Boolean, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §GET /lab/feedMedium/{mediumId}｜任务包 TP-M02-15

## M02-183｜POST /lab/feedMedium｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:feedMedium:add
- Controller→Service：`com.futurefab.system.controller.FeedMediumController#add` → `com.futurefab.system.service.IFeedMediumService#insertFeedMedium`
- Request `FeedMediumCreateCommand`：mediumName:String*, sugarConcentration:BigDecimal*, isSugarFeed:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=feed_medium
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §培养基字段白名单/POST｜任务包 TP-M02-15

## M02-184｜PUT /lab/feedMedium｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:feedMedium:edit
- Controller→Service：`com.futurefab.system.controller.FeedMediumController#edit` → `com.futurefab.system.service.IFeedMediumService#updateFeedMedium`
- Request `FeedMediumUpdateCommand`：mediumId:String*, mediumName:String*, sugarConcentration:BigDecimal*, isSugarFeed:Boolean, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=feed_medium
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §PUT /lab/feedMedium｜任务包 TP-M02-15

## M02-185｜DELETE /lab/feedMedium/{mediumIds}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:feedMedium:remove
- Controller→Service：`com.futurefab.system.controller.FeedMediumController#remove` → `com.futurefab.system.service.IFeedMediumService#deleteFeedMediumByMediumIds`
- Request `FeedMediumDeleteCommand`：mediumIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=feed_medium
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §DELETE /lab/feedMedium/{mediumIds}｜任务包 TP-M02-15

## M02-186｜GET /resource/consumableMaster/list｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:consumableMaster:list
- Controller→Service：`com.futurefab.system.controller.ConsumableMasterController#list` → `com.futurefab.system.service.IConsumableMasterService#selectConsumableMasterList`
- Request `ConsumableMasterPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, timeField:String, startDate:LocalDate, endDate:LocalDate
- Response：`ConsumableMasterRow`（主视图字段：consumableId:String, itemCode:String, description:String, category:String, measureUnit:String, capacity:Long, capacityUnit:String, brand:String, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String, iconUrl:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §耗材｜任务包 TP-M02-15

## M02-187｜GET /resource/consumableMaster/{consumableId}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:consumableMaster:query
- Controller→Service：`com.futurefab.system.controller.ConsumableMasterController#getInfo` → `com.futurefab.system.service.IConsumableMasterService#selectConsumableMasterByConsumableId`
- Request `ConsumableMasterDetailQuery`：consumableId:String*
- Response：`ConsumableMasterDetailView`（主视图字段：consumableId:String, itemCode:String, description:String, category:String, measureUnit:String, capacity:Long, capacityUnit:String, brand:String, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String, iconUrl:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §GET /resource/consumableMaster/{consumableId}｜任务包 TP-M02-15

## M02-188｜POST /resource/consumableMaster｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:consumableMaster:add
- Controller→Service：`com.futurefab.system.controller.ConsumableMasterController#add` → `com.futurefab.system.service.IConsumableMasterService#insertConsumableMaster`
- Request `ConsumableMasterCreateCommand`：itemCode:String*, description:String*, category:String*, measureUnit:String*, capacity:Long, capacityUnit:String*, brand:String*, iconPath:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=consumable_master
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §耗材字段白名单/POST｜任务包 TP-M02-15

## M02-189｜PUT /resource/consumableMaster｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:consumableMaster:edit
- Controller→Service：`com.futurefab.system.controller.ConsumableMasterController#edit` → `com.futurefab.system.service.IConsumableMasterService#updateConsumableMaster`
- Request `ConsumableMasterUpdateCommand`：consumableId:String*, itemCode:String*, description:String*, category:String*, measureUnit:String*, capacity:Long, capacityUnit:String*, brand:String*, iconPath:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=consumable_master
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §PUT /resource/consumableMaster｜任务包 TP-M02-15

## M02-190｜DELETE /resource/consumableMaster/{consumableIds}｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:consumableMaster:remove
- Controller→Service：`com.futurefab.system.controller.ConsumableMasterController#remove` → `com.futurefab.system.service.IConsumableMasterService#deleteConsumableMasterByConsumableIds`
- Request `ConsumableMasterDeleteCommand`：consumableIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=consumable_master
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/四类资源逐接口契约.md §DELETE /resource/consumableMaster/{consumableIds}｜任务包 TP-M02-15

## M02-191｜GET /lab/liquidBag/check-unique｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:liquidBag:query
- Controller→Service：`com.futurefab.system.controller.LiquidBagController#checkUnique` → `com.futurefab.system.service.ILiquidBagService#checkLiquidBagUnique`
- Request `LiquidBagUniquenessCheckQuery`：description:String*, bagId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/唯一性预检查与消耗旧入口兼容契约.md §2（外壳UniquenessCheckResult公共，不定义；重复目标409 NAME_CONFLICT）｜任务包 TP-M02-15

## M02-192｜GET /lab/feedMedium/check-unique｜资源主数据（校准对象/液袋/培养基/耗材）
- 权限：device:feedMedium:query
- Controller→Service：`com.futurefab.system.controller.FeedMediumController#checkUnique` → `com.futurefab.system.service.IFeedMediumService#checkFeedMediumUnique`
- Request `FeedMediumUniquenessCheckQuery`：mediumName:String*, mediumId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/唯一性预检查与消耗旧入口兼容契约.md §3（重复目标409 NAME_CONFLICT）｜任务包 TP-M02-15

## M02-206｜GET /lab/communication/getByDevice｜设备通讯配置
- 权限：lab:communication:query＋目标实例可见
- Controller→Service：`com.futurefab.system.controller.LabCommunicationController#getByDevice` → `com.futurefab.system.service.ILabCommunicationService#selectMaskedCommunicationByDeviceId`
- Request `LabCommunicationByDeviceQuery`：deviceKind:String*, deviceId:String*
- Response：`LabCommunicationView`（主视图字段：commId:String, deviceKind:String, deviceId:String, labId:String, communicationType:String, interfaceUrl:String, interfaceAccount:String, deviceCode:String, subsystemDeviceNo:String, subsystemMac:String, subsystemIp:String, deviceIp:String, portNo:Long, excelPath:String, deviceModel:String, serialPort:String, baudRate:Long, parity:String, dataBits:String, stopBits:String, flowControl:String, pipeNa…全集见 spec 文件）
- 枚举冻结：ApplyState=NOT_CONFIGURED/PENDING/APPLIED/FAILED/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/通讯逐接口字段与加载回执.md §3 GET getByDevice(COM-01)｜任务包 TP-M02-07

## M02-207｜GET /lab/communication/{commId}｜设备通讯配置
- 权限：lab:communication:query＋目标实例可见
- Controller→Service：`com.futurefab.system.controller.LabCommunicationController#getInfo` → `com.futurefab.system.service.ILabCommunicationService#selectLabCommunicationByCommId`
- Request `LabCommunicationDetailQuery`：commId:String*
- Response：`LabCommunicationView`（主视图字段：commId:String, deviceKind:String, deviceId:String, labId:String, communicationType:String, interfaceUrl:String, interfaceAccount:String, deviceCode:String, subsystemDeviceNo:String, subsystemMac:String, subsystemIp:String, deviceIp:String, portNo:Long, excelPath:String, deviceModel:String, serialPort:String, baudRate:Long, parity:String, dataBits:String, stopBits:String, flowControl:String, pipeNa…全集见 spec 文件）
- 枚举冻结：ApplyState=NOT_CONFIGURED/PENDING/APPLIED/FAILED/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/通讯逐接口字段与加载回执.md §3 GET /lab/communication/{commId}(COM-02)｜任务包 TP-M02-07

## M02-208｜POST /lab/communication｜设备通讯配置
- 权限：lab:communication:add＋目标实例操作
- Controller→Service：`com.futurefab.system.controller.LabCommunicationController#add` → `com.futurefab.system.service.ILabCommunicationService#insertLabCommunication`
- Request `LabCommunicationCreateCommand`：deviceKind:String*, deviceId:String*, communicationType:CommunicationType*, interfaceUrl:String, interfaceAccount:String, deviceCode:String, subsystemDeviceNo:String, deviceModel:String, subsystemIp:String, deviceIp:String, portNo:Long, excelPath:String, pipeName:String, serialPort:String, baudRate:Long, parity:String, dataBits:String, stopBits:String, flowControl:String, interfacePasswordChange:SecretChange*, deviceSecretChange:SecretChange*, requestId:String*, managementRevision:String*
- Response：`SecretChange`（主视图字段：action:SecretChangeAction, value:String）
- 枚举冻结：CommunicationType=HTTP/NAMED_PIPE/NETWORK/FILE/SERIAL；SecretChangeAction=KEEP/REPLACE/CLEAR
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：VALIDATION_ERROR, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, RESOURCE_IN_USE, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, CONFIGURATION_INCOMPLETE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_communication
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/通讯逐接口字段与加载回执.md §1—§3 POST(COM-03)｜任务包 TP-M02-07

## M02-209｜PUT /lab/communication｜设备通讯配置
- 权限：lab:communication:edit＋原实例操作
- Controller→Service：`com.futurefab.system.controller.LabCommunicationController#edit` → `com.futurefab.system.service.ILabCommunicationService#updateLabCommunication`
- Request `LabCommunicationUpdateCommand`：commId:String*, deviceKind:String*, deviceId:String*, communicationType:CommunicationType*, interfaceUrl:String, interfaceAccount:String, deviceCode:String, subsystemDeviceNo:String, deviceModel:String, subsystemIp:String, deviceIp:String, portNo:Long, excelPath:String, pipeName:String, serialPort:String, baudRate:Long, parity:String, dataBits:String, stopBits:String, flowControl:String, interfacePasswordChange:SecretChange*, deviceSecretChange:SecretChange*, requestId:String*, managementRevision:String*
- Response：`SecretChange`（主视图字段：action:SecretChangeAction, value:String）
- 枚举冻结：CommunicationType=HTTP/NAMED_PIPE/NETWORK/FILE/SERIAL；SecretChangeAction=KEEP/REPLACE/CLEAR
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：VALIDATION_ERROR, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, RESOURCE_IN_USE, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, CONFIGURATION_INCOMPLETE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_communication
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/通讯逐接口字段与加载回执.md §1—§3 PUT(COM-04)｜任务包 TP-M02-07

## M02-210｜DELETE /lab/communication/{commIds}｜设备通讯配置
- 权限：lab:communication:remove＋每台实例操作
- Controller→Service：`com.futurefab.system.controller.LabCommunicationController#remove` → `com.futurefab.system.service.ILabCommunicationService#deleteLabCommunicationByCommIds`
- Request `LabCommunicationDeleteCommand`：commIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：VALIDATION_ERROR, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, RESOURCE_IN_USE, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_communication
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/通讯逐接口字段与加载回执.md §3 DELETE(COM-05)｜任务包 TP-M02-07

## M02-211｜GET /lab/communication/list｜设备通讯配置
- 权限：lab:communication:list＋逐设备可见
- Controller→Service：`com.futurefab.system.controller.LabCommunicationController#list` → `com.futurefab.system.service.ILabCommunicationService#selectLabCommunicationList`
- Request `LabCommunicationPageQuery`：labId:String, deviceKind:String, deviceId:String, communicationType:String, pageNum:Integer, pageSize:Integer
- Response：`LabCommunicationRow`（主视图字段：commId:String, deviceKind:String, deviceId:String, labId:String, communicationType:String, interfaceUrl:String, interfaceAccount:String, deviceCode:String, subsystemDeviceNo:String, subsystemMac:String, subsystemIp:String, deviceIp:String, portNo:Long, excelPath:String, deviceModel:String, serialPort:String, baudRate:Long, parity:String, dataBits:String, stopBits:String, flowControl:String, pipeNa…全集见 spec 文件）
- 枚举冻结：ApplyState=NOT_CONFIGURED/PENDING/APPLIED/FAILED/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/通讯逐接口字段与加载回执.md §3 GET /lab/communication/list｜任务包 TP-M02-07

## M02-212｜GET /lab/detectorconfig/{detectorId}/available-items｜实例检测项目开关
- 权限：lab:labdetector:config或lab:detectorconfig:edit＋真实设备实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabDetectorItemConfigController#availableItems` → `com.futurefab.system.service.ILabDetectorItemConfigService#getAvailableItems`
- Request `DetectorAvailableItemQuery`：detectorId:String*
- Response：`DetectorItemOptionView`（主视图字段：itemId:String, itemCode:String, shortName:String, itemCnName:String, unit:String, description:String, enabled:Boolean）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目开关与规则接口契约.md §2｜任务包 TP-M02-02

## M02-213｜POST /lab/detectorconfig/{detectorId}/batch-save｜实例检测项目开关
- 权限：lab:labdetector:config或lab:detectorconfig:edit＋真实实验室操作等级1
- Controller→Service：`com.futurefab.system.controller.LabDetectorItemConfigController#batchSave` → `com.futurefab.system.service.ILabDetectorItemConfigService#batchSaveForDetector`
- Request `DetectorItemConfigBatchSaveCommand`：detectorId:String*, items:List<DetectorItemConfigBatchItem>*, requestId:String*, managementRevision:String*
- Response：`DetectorItemConfigBatchItem`（主视图字段：itemId:String, enabled:Boolean）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, RESOURCE_IN_USE, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_detector_item_config
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目开关与规则接口契约.md §3（成功回显完整候选视图，brief冻结回执外壳为MutationResult）｜任务包 TP-M02-02

## M02-214｜GET /detect/detection-rule/labs｜检测规则
- 权限：lab:detectionRule:list
- Controller→Service：`com.futurefab.system.controller.DetectionRuleController#listAuthorizedLabs` → `com.futurefab.system.service.IDetectionRuleService#listAuthorizedLabOptions`
- Request `DetectionRuleAuthorizedLabQuery`：（无字段/NoBody）
- Response：`LabOptionView`（主视图字段：labId:String, labName:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目开关与规则接口契约.md §4｜任务包 TP-M02-02

## M02-215｜GET /detect/detection-rule/config/{labId}｜检测规则
- 权限：lab:detectionRule:list＋当前实验室可见
- Controller→Service：`com.futurefab.system.controller.DetectionRuleController#getConfig` → `com.futurefab.system.service.IDetectionRuleService#getConfig`
- Request `DetectionRuleConfigQuery`：labId:String*
- Response：`DetectionRuleConfigView` + `DetectionRuleConfigItem`（主视图字段：labId:String, items:List<DetectionRuleConfigItem>, managementRevision:String）
- 枚举冻结：DetectionRuleItem=density-difference/photometer-time/photometer-rds/photometer-blank-concentration/solovpe-rds/solovpe-r2
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目开关与规则接口契约.md §5｜任务包 TP-M02-02

## M02-216｜PUT /detect/detection-rule/{labId}/{ruleItem}｜检测规则
- 权限：lab:detectionRule:edit＋真实实验室操作等级1/2
- Controller→Service：`com.futurefab.system.controller.DetectionRuleController#saveItem` → `com.futurefab.system.service.IDetectionRuleService#saveItem`
- Request `DetectionRuleItemSaveCommand`：labId:String*, ruleItem:DetectionRuleItem*, operator:String*, value:BigDecimal*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 枚举冻结：DetectionRuleItem=density-difference/photometer-time/photometer-rds/photometer-blank-concentration/solovpe-rds/solovpe-r2
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_detection_rule
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目开关与规则接口契约.md §6｜任务包 TP-M02-02

## M02-217｜GET /device/detectoritem/list｜检测项目主数据
- 权限：device:detectoritem:list
- Controller→Service：`com.futurefab.system.controller.DevDetectorItemController#list` → `com.futurefab.system.service.IDevDetectorItemService#selectDevDetectorItemList`
- Request `DevDetectorItemPageQuery`：detectClass:String*, itemName:String, pageNum:Integer, pageSize:Integer
- Response：`DevDetectorItemRow`（主视图字段：itemId:String, detectClass:String, itemCode:String, itemCnName:String, itemEnName:String, shortName:String, unit:String, groupName:String, offlineStatName:String, description:String, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目主数据逐接口契约.md §1—§2｜任务包 TP-M02-02

## M02-218｜GET /device/detectoritem/{itemId}｜检测项目主数据
- 权限：device:detectoritem:query
- Controller→Service：`com.futurefab.system.controller.DevDetectorItemController#getInfo` → `com.futurefab.system.service.IDevDetectorItemService#selectDevDetectorItemByItemId`
- Request `DevDetectorItemDetailQuery`：itemId:String*
- Response：`DevDetectorItemDetailView`（主视图字段：itemId:String, detectClass:String, itemCode:String, itemCnName:String, itemEnName:String, shortName:String, unit:String, groupName:String, offlineStatName:String, description:String, createBy:String, createTime:OffsetDateTime, updateBy:String, updateTime:OffsetDateTime, managementRevision:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目主数据逐接口契约.md §3｜任务包 TP-M02-02

## M02-219｜GET /device/detectoritem/check-unique｜检测项目主数据
- 权限：device:detectoritem:query
- Controller→Service：`com.futurefab.system.controller.DevDetectorItemController#checkUnique` → `com.futurefab.system.service.IDevDetectorItemService#checkDevDetectorItemUnique`
- Request `DevDetectorItemUniquenessCheckQuery`：detectClass:String*, itemCode:String*, itemId:String
- Response：`UniquenessCheckResult`（主视图字段：unique:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, CODE_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目主数据逐接口契约.md §4（外壳UniquenessCheckResult公共）｜任务包 TP-M02-02

## M02-220｜GET /device/detectoritem/{itemId}/check-delete｜检测项目主数据
- 权限：device:detectoritem:query
- Controller→Service：`com.futurefab.system.controller.DevDetectorItemController#checkDelete` → `com.futurefab.system.service.IDevDetectorItemService#checkDevDetectorItemDeleteAllowed`
- Request `DevDetectorItemDeleteCheckQuery`：itemId:String*
- Response：`DeletePrecheckResult`（主视图字段：）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, NOT_FOUND, RESOURCE_FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目主数据逐接口契约.md §5｜任务包 TP-M02-02

## M02-221｜POST /device/detectoritem｜检测项目主数据
- 权限：device:detectoritem:add
- Controller→Service：`com.futurefab.system.controller.DevDetectorItemController#add` → `com.futurefab.system.service.IDevDetectorItemService#insertDevDetectorItem`
- Request `DevDetectorItemCreateCommand`：detectClass:String*, itemCode:String*, itemName:String*, englishName:String*, shortName:String*, unit:String, groupName:String, offlineStatName:String*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_detector_item
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目主数据逐接口契约.md §1/§6｜任务包 TP-M02-02

## M02-222｜PUT /device/detectoritem｜检测项目主数据
- 权限：device:detectoritem:edit
- Controller→Service：`com.futurefab.system.controller.DevDetectorItemController#edit` → `com.futurefab.system.service.IDevDetectorItemService#updateDevDetectorItem`
- Request `DevDetectorItemUpdateCommand`：itemId:String*, detectClass:String*, itemCode:String*, itemName:String*, englishName:String*, shortName:String*, unit:String, groupName:String, offlineStatName:String*, description:String, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_detector_item
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目主数据逐接口契约.md §7｜任务包 TP-M02-02

## M02-223｜DELETE /device/detectoritem/{itemIds}｜检测项目主数据
- 权限：device:detectoritem:remove
- Controller→Service：`com.futurefab.system.controller.DevDetectorItemController#remove` → `com.futurefab.system.service.IDevDetectorItemService#deleteDevDetectorItemByItemIds`
- Request `DevDetectorItemDeleteCommand`：itemIds:List<String>*, requestId:String*, managementRevision:String*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`DeleteResult`）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, REFERENCE_EXISTS, RESOURCE_IN_USE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=dev_detector_item
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：docs/详细设计/02-实验室与资源管理/检测项目主数据逐接口契约.md §8（DeleteResult外壳含removedIds/managementRevision）｜任务包 TP-M02-02

## M02-225｜GET /system/lab/engineering/profiles｜工程资料与控制器型号核准
- 权限：lab:engineering:query
- Controller→Service：`com.futurefab.system.controller.LabEngineeringProfileController#queryProfiles` → `com.futurefab.system.service.application.m02.EngineeringApplicationService#queryProfiles`
- Request `EngineeringProfilePageQuery`：scopeKind:String*, modelKind:String, modelId:String, deviceKind:String, deviceId:String
- Response：`EngineeringProfileRow` + `EngineeringScope` + `EngineeringProfileIssue` + `Evidence` + `EngineeringProfile` + `EngineeringVendor` + `EngineeringCapabilities` + `EngineeringSpecification` + `PidRule` + `PidParameter` + `PidConversion` + `PidReadback` + `ChannelRule` + `ChannelCodeSpeed` + `MediumMapping` + `FeedingPolicy`（主视图字段：scope:EngineeringScope*, profileId:String, versionId:String, versionNo:Long, objectVersion:String, status:String, profile:EngineeringProfile, evidence:List<Evidence>*, state:String*, issues:List<EngineeringProfileIssue>*, allowedActions:List<String>*, managementRevision:String*）
- 枚举冻结：ProfileScopeKind=MODEL/INSTANCE；ProfileStatus=DRAFT/VERIFIED/REVOKED；ProfileState=COMPLETE/INCOMPLETE/REVOKED；ProfileAllowedAction=EDIT/VERIFY/REVOKE；EvidenceSourceKind=VENDOR_MANUAL/SITE_VERIFIED/APPROVED_MAPPING；SpecificationUnit=L/ML；ConversionRule=ML_DIV_1000/L_IDENTITY；PidAction=FORWARD/REVERSE/CONFIGURABLE；PidParameterName=GAIN/RESET/RATE；ConversionExpressionKind=IDENTITY/LINEAR；ChannelKind=PUMP/MFC/CONTROL_LOOP；ChannelCodeSpeedCode=SPEED1/SPEED2/SPEED3/SPEED4/SPEED5/SPEED6/SPEED7/SPEED8/SPEED9/SPEED10；MaterialKind=FEED_MEDIUM/LIQUID_BAG/CONSUMABLE；FeedingPolicyUnit=G/ML
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, RESOURCE_FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：工程资料维护与解析逐接口契约.md §1-§2；控制器型号与工程参数收尾契约.md §3(EngineeringProfile模式1)｜任务包 TP-M02-01

## M02-226｜POST /system/lab/engineering/profiles｜工程资料与控制器型号核准
- 权限：lab:engineering:edit(SAVE_DRAFT)/lab:engineering:verify(VERIFY)/lab:engineering:revoke(REVOKE)
- Controller→Service：`com.futurefab.system.controller.LabEngineeringProfileController#saveProfile` → `com.futurefab.system.service.application.m02.EngineeringApplicationService#saveProfile`
- Request `EngineeringProfileSaveCommand`：requestId:String*, expectedManagementRevision:String*, expectedProfileVersion:String, scope:EngineeringScope*, action:String*, reason:String, profile:EngineeringProfile, evidence:List<Evidence>
- Response：`MutationResult`（主视图字段：）
- 枚举冻结：ProfileSaveAction=SAVE_DRAFT/VERIFY/REVOKE
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, VALIDATION_ERROR, PERMISSION_DENIED, NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, RESOURCE_IN_USE, RESOURCE_FACTS_UNAVAILABLE, MANAGEMENT_BUSY
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_engineering_profile
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：工程资料维护与解析逐接口契约.md §1,§3｜任务包 TP-M02-01

## M02-227｜POST /system/lab/controllers/{connectionId}/model-verification｜工程资料与控制器型号核准
- 权限：lab:controller:model-verification＋连接所属实验室管理等级2
- Controller→Service：`com.futurefab.system.controller.LabControllerModelVerificationController#verifyModelMapping` → `com.futurefab.system.service.application.m02.EngineeringApplicationService#verifyModelMapping`
- Request `ControllerModelVerificationCommand`：connectionId:String*, expectedManagementRevision:String*, expectedModelDictCode:String, newModelDictCode:String*, evidence:ModelVerificationEvidence*, requestId:String*
- Response：`ControllerModelVerificationResult` + `ModelVerificationEvidence`（主视图字段：connectionId:String*, modelDictCode:String*, managementRevision:String*, requestId:String*）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, RESOURCE_IN_USE, RESOURCE_FACTS_UNAVAILABLE, MANAGEMENT_BUSY
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_bench_reactor_controller
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：工程资料维护与解析逐接口契约.md §4；控制器型号与工程参数收尾契约.md §1(只保存映射与审计不发物理命令)｜任务包 TP-M02-01

## M02-228｜GET /lab/lab/list｜实验室管理
- 权限：lab:lab:list＋有效可见实验室范围
- Controller→Service：`com.futurefab.system.controller.LabLabController#list` → `com.futurefab.system.service.ILabLabService#selectLabLabList`
- Request `LabPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, beginDate:LocalDate, endDate:LocalDate
- Response：`LabRow` + `LabPersonRef`（主视图字段：labId:String*, labName:String*, labCode:String*, labType:String*, labTypeLabel:String*, status:String*, leaders:List<LabPersonRef>*, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>*）
- 枚举冻结：LabType=1/2/3/4；LabStatus=0/1；LabAllowedAction=EDIT/DISABLE/VIEW_USERS/WORKFLOW/APPROVAL
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §1-§2(排序createTime DESC、labId DESC)｜任务包 TP-M02-11

## M02-229｜GET /lab/lab/options｜实验室管理
- 权限：已认证＋服务端VIEW范围(无功能码要求)
- Controller→Service：`com.futurefab.system.controller.LabLabController#options` → `com.futurefab.system.service.ILabLabService#selectLabSelectOptions`
- Request `LabOptionQuery`：status:String, labType:String
- Response：`LabOptionView`（主视图字段：labId:String*, labName:String*, labType:String*, isDefaultLab:Boolean*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §3(排序labName ASC、labId ASC)｜任务包 TP-M02-11

## M02-231｜GET /lab/lab/{labId}｜实验室管理
- 权限：lab:lab:query＋目标实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabLabController#getInfo` → `com.futurefab.system.service.ILabLabService#selectLabLabByLabId`
- Request `LabDetailQuery`：labId:String*
- Response：`LabDetailView` + `LabPersonRef`（主视图字段：labId:String*, labName:String*, labCode:String*, labType:String*, labTypeLabel:String*, status:String*, leaders:List<LabPersonRef>*, updateBy:String, updateDisplayName:String, updateTime:OffsetDateTime, allowedActions:List<String>*, venueId:String*, deptId:String*, ipAddress:String*, port:Long, leaderUserIds:List<String>*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §5｜任务包 TP-M02-11

## M02-232｜GET /lab/lab/{labId}/leaders｜实验室管理
- 权限：lab:lab:query＋VIEW
- Controller→Service：`com.futurefab.system.controller.LabLabController#getLeaders` → `com.futurefab.system.service.ILabLabService#listLeaderUserIds`
- Request `LabLeaderQuery`：labId:String*
- Response：`UserOptionView`（主视图字段：）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §6｜任务包 TP-M02-11

## M02-233｜GET /lab/lab/{labId}/authorized-users｜实验室管理
- 权限：lab:lab:query＋VIEW
- Controller→Service：`com.futurefab.system.controller.LabLabController#getAuthorizedUsers` → `com.futurefab.system.service.ILabLabService#listAuthorizedUsers`
- Request `LabAuthorizedUserQuery`：labId:String*, pageNum:Integer, pageSize:Integer
- Response：`AuthorizedUserRow`（主视图字段：userId:String*, displayName:String*, userName:String*, deptName:String, roleNames:List<String>*, authorizationSources:List<String>*, directAuthType:String, effectiveAuthType:String*, lastLoginTime:OffsetDateTime, online:Boolean*, associatedAt:OffsetDateTime）
- 枚举冻结：LabAuthorizationSource=DIRECT/LAB_LEADER
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission ; M01:有效会话服务(online按userId批量读取)
- 来源：实验室主数据逐接口契约.md §7｜任务包 TP-M02-11

## M02-234｜GET /lab/lab/{labId}/check-disable｜实验室管理
- 权限：lab:lab:query＋该实验室MANAGE
- Controller→Service：`com.futurefab.system.controller.LabLabController#checkDisable` → `com.futurefab.system.service.ILabLabService#checkDisableAllowed`
- Request `LabDisableCheckQuery`：labId:String*
- Response：`DisablePrecheckResult`（主视图字段：）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, RESOURCE_FACTS_UNAVAILABLE, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §8｜任务包 TP-M02-11

## M02-235｜POST /lab/lab｜实验室管理
- 权限：lab:lab:add
- Controller→Service：`com.futurefab.system.controller.LabLabController#add` → `com.futurefab.system.service.ILabLabService#insertLabLab`
- Request `LabCreateCommand`：labName:String*, labCode:String*, labType:String*, leaderUserIds:List<String>*, venueId:String*, deptId:String*, ipAddress:String*, port:Long, status:String*, requestId:String, managementRevision:String
- Response：`MutationResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_lab
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §1,§9(创建者不因创建自动获授权M02-Q21)｜任务包 TP-M02-11

## M02-236｜PUT /lab/lab｜实验室管理
- 权限：lab:lab:edit＋目标管理权限
- Controller→Service：`com.futurefab.system.controller.LabLabController#edit` → `com.futurefab.system.service.ILabLabService#updateLabLab`
- Request `LabUpdateCommand`：labId:String*, labName:String*, labCode:String*, labType:String*, leaderUserIds:List<String>*, venueId:String*, deptId:String*, ipAddress:String*, port:Long, status:String*, requestId:String, managementRevision:String
- Response：`MutationResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, NAME_CONFLICT, CODE_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_lab
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §10｜任务包 TP-M02-11

## M02-237｜PUT /lab/lab/{labId}/leaders｜实验室管理
- 权限：lab:lab:edit＋MANAGE
- Controller→Service：`com.futurefab.system.controller.LabLabController#batchSaveLeaders` → `com.futurefab.system.service.ILabLabService#batchSaveLeaders`
- Request `LabLeaderBatchSaveCommand`：leaderUserIds:List<String>*, labId:String*, requestId:String, managementRevision:String
- Response：`MutationResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_lab_leader
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §11｜任务包 TP-M02-11

## M02-238｜PUT /lab/lab/{labId}/status｜实验室管理
- 权限：lab:lab:edit＋MANAGE
- Controller→Service：`com.futurefab.system.controller.LabLabController#updateStatus` → `com.futurefab.system.service.ILabLabService#updateLabStatus`
- Request `LabStatusUpdateCommand`：labId:String*, status:String*, requestId:String, managementRevision:String
- Response：`MutationResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, REFERENCE_EXISTS, RESOURCE_IN_USE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_lab
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §12｜任务包 TP-M02-11

## M02-239｜DELETE /lab/lab/{labIds}｜实验室管理
- 权限：lab:lab:remove＋每个实验室MANAGE
- Controller→Service：`com.futurefab.system.controller.LabLabController#remove` → `com.futurefab.system.service.ILabLabService#deleteLabLabByLabIds`
- Request `LabDeleteCommand`：labIds:List<String>*, requestId:String, managementRevision:String
- Response：`DeleteResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, REFERENCE_EXISTS, RESOURCE_IN_USE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_lab
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：实验室主数据逐接口契约.md §13｜任务包 TP-M02-11

## M02-240｜GET /lab/consumptionRule/bootstrap｜消耗配置
- 权限：lab:consumptionRule:list
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#bootstrap` → `com.futurefab.system.service.IConsumptionRuleService#getBootstrapData`
- Request `ConsumptionBootstrapQuery`：（无字段/NoBody）
- Response：`ConsumptionRuleBootstrapView` + `ConsumptionLabOption` + `ConsumptionBootstrapTab` + `ConsumptionBootstrapCard` + `ConsumptionOptionItem`（主视图字段：labOptions:List<ConsumptionLabOption>*, defaultLabId:String, tabs:List<ConsumptionBootstrapTab>*, itemTypeOptions:List<ConsumptionOptionItem>*, dilutionTypeOptions:List<ConsumptionOptionItem>*）
- 枚举冻结：ConsumptionTabType=feeding_batch/column_after/sample；ConsumptionDetectClass=BGA/ViCell/OSMO/Cedex/留样；ConsumptionDilutionType=diluted/undiluted
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗配置聚合与解析契约.md §GET /lab/consumptionRule/bootstrap；卡片键buildCardKey=detectClass|dilutionType｜任务包 TP-M02-13

## M02-241｜GET /lab/consumptionRule/config｜消耗配置
- 权限：lab:consumptionRule:query＋实验室可见等级0
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#config` → `com.futurefab.system.service.IConsumptionRuleService#getConsumptionConfigByLabAndTab`
- Request `ConsumptionConfigQuery`：labId:String*, tabType:String*
- Response：`ConsumptionConfigView` + `ConsumptionConfigCardView` + `ConsumptionRowView`（主视图字段：labId:String*, tabType:String*, cards:List<ConsumptionConfigCardView>*, managementRevision:String*）
- 枚举冻结：ConsumptionItemType=1/2；ConsumptionConfigurationIssue=SOURCE_UNAVAILABLE/CONSUMABLE_UNAVAILABLE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗配置聚合与解析契约.md §字段与身份, §GET /lab/consumptionRule/config｜任务包 TP-M02-13

## M02-242｜GET /lab/consumptionRule/consumable-options｜消耗配置
- 权限：lab:consumptionRule:list
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#consumableOptions` → `com.futurefab.system.service.IConsumptionRuleService#getConsumableOptions`
- Request `ConsumptionConsumableOptionQuery`：（无字段/NoBody）
- Response：`ConsumableOptionView`（主视图字段：consumableId:String*, itemCode:String, description:String, label:String*, measureUnit:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗配置聚合与解析契约.md §GET /lab/consumptionRule/consumable-options(排序description、consumableId升序)｜任务包 TP-M02-13

## M02-243｜PUT /lab/consumptionRule/config｜消耗配置
- 权限：lab:consumptionRule:edit＋实际实验室管理等级2
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#saveConfig` → `com.futurefab.system.service.IConsumptionRuleService#saveConsumptionConfig`
- Request `ConsumptionConfigSaveCommand`：labId:String*, tabType:String*, cards:List<ConsumptionCardInput>*, requestId:String, managementRevision:String
- Response：`ConsumptionConfigView` + `ConsumptionCardInput` + `ConsumptionRowInput` + `ConsumptionConfigCardView` + `ConsumptionRowView`（主视图字段：labId:String*, tabType:String*, cards:List<ConsumptionConfigCardView>*, managementRevision:String*）
- 枚举冻结：ConsumptionItemType=1/2
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=consumption_rule
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗配置聚合与解析契约.md §PUT /lab/consumptionRule/config, §字段与身份｜任务包 TP-M02-13

## M02-244｜GET /lab/consumptionRule/list｜消耗配置
- 权限：lab:consumptionRule:list
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#list` → `com.futurefab.system.service.IConsumptionRuleService#selectConsumptionRuleList`
- Request `ConsumptionRulePageQuery`：pageNum:Integer, pageSize:Integer, labId:String, tabType:String, detectClass:String, rowName:String, dilutionType:String, seqNumber:Long, itemType:String, consumableId:String, quantity:Long
- Response：`ConsumptionRuleRow`（主视图字段：ruleId:String*, labId:String*, tabType:String*, detectClass:String*, dilutionType:String, rowName:String*, seqNumber:Long*, itemType:String*, consumableId:String, sharedRuleId:String, sharedSource:String, quantity:Long, consumableCode:String, consumableDescription:String, resolvedQuantity:Long, configurationIssue:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:Offse…全集见 spec 文件）
- 枚举冻结：ConsumptionTabType=feeding_batch/column_after/sample；ConsumptionDetectClass=BGA/ViCell/OSMO/Cedex/留样；ConsumptionDilutionType=diluted/undiluted；ConsumptionItemType=1/2
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗旧接口逐字段契约.md §1-§2(排序labId/tabType/detectClass/dilutionType/seqNumber/ruleId ASC；不输出delFlag/params)｜任务包 TP-M02-13

## M02-245｜GET /lab/consumptionRule/{ruleId}｜消耗配置
- 权限：lab:consumptionRule:query
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#getInfo` → `com.futurefab.system.service.IConsumptionRuleService#selectConsumptionRuleByRuleId`
- Request `ConsumptionRuleDetailQuery`：ruleId:String*
- Response：`ConsumptionRuleDetailView`（主视图字段：ruleId:String*, labId:String*, tabType:String*, detectClass:String*, dilutionType:String, rowName:String*, seqNumber:Long*, itemType:String*, consumableId:String, sharedRuleId:String, sharedSource:String, quantity:Long, consumableCode:String, consumableDescription:String, resolvedQuantity:Long, configurationIssue:String, createBy:String, updateBy:String, createTime:OffsetDateTime, updateTime:Offse…全集见 spec 文件）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗旧接口逐字段契约.md §3(同RowView平铺)｜任务包 TP-M02-13

## M02-246｜POST /lab/consumptionRule｜消耗配置
- 权限：lab:consumptionRule:add＋实验室管理等级2
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#add` → `com.futurefab.system.service.IConsumptionRuleService#insertConsumptionRule`
- Request `ConsumptionRuleCreateCommand`：labId:String*, tabType:String*, detectClass:String*, dilutionType:String, itemType:String*, consumableId:String, sharedRuleId:String, quantity:Long, requestId:String, managementRevision:String
- Response：`MutationResult`（主视图字段：）
- 枚举冻结：ConsumptionItemType=1/2
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, CLIENT_UPGRADE_REQUIRED, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, REFERENCE_EXISTS, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=consumption_rule
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗旧接口逐字段契约.md §4｜任务包 TP-M02-13

## M02-247｜PUT /lab/consumptionRule｜消耗配置
- 权限：lab:consumptionRule:edit＋真实实验室管理等级2
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#edit` → `com.futurefab.system.service.IConsumptionRuleService#updateConsumptionRule`
- Request `ConsumptionRuleUpdateCommand`：ruleId:String*, labId:String*, tabType:String*, detectClass:String*, dilutionType:String, itemType:String*, consumableId:String, sharedRuleId:String, quantity:Long, requestId:String, managementRevision:String
- Response：`MutationResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, CLIENT_UPGRADE_REQUIRED, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, REFERENCE_EXISTS, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=consumption_rule
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗旧接口逐字段契约.md §5｜任务包 TP-M02-13

## M02-248｜DELETE /lab/consumptionRule/{ruleIds}｜消耗配置
- 权限：lab:consumptionRule:remove＋全部真实实验室管理等级2
- Controller→Service：`com.futurefab.system.controller.ConsumptionRuleController#remove` → `com.futurefab.system.service.IConsumptionRuleService#deleteConsumptionRuleByRuleIds`
- Request `ConsumptionRuleDeleteCommand`：ruleIds:List<String>*, requestId:String, managementRevision:String
- Response：`DeleteResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, CLIENT_UPGRADE_REQUIRED, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, REFERENCE_EXISTS, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=consumption_rule
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：消耗旧接口逐字段契约.md §6｜任务包 TP-M02-13

## M02-250｜GET /lab/bottle-config/consumables｜液瓶配置
- 权限：lab:bottle-config:list＋实验室可见等级0
- Controller→Service：`com.futurefab.system.controller.BottleConfigController#listConsumables` → `com.futurefab.system.service.IBottleConfigService#listBottleConsumableOptions`
- Request `BottleConsumableOptionQuery`：labId:String*
- Response：`BottleConsumableOptionView`（主视图字段：consumableId:String*, description:String*, capacityMl:BigDecimal*, iconUrl:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：液瓶配置逐接口与观测边界.md §GET /lab/bottle-config/consumables(排序description、consumableId升序)｜任务包 TP-M02-12

## M02-251｜GET /lab/bottle-config/layout｜液瓶配置
- 权限：lab:bottle-config:list＋可见等级0
- Controller→Service：`com.futurefab.system.controller.BottleConfigController#getLayout` → `com.futurefab.system.service.IBottleConfigService#getLayout`
- Request `BottleLayoutQuery`：labId:String*, unitType:String*
- Response：`BottleLayoutView` + `BottleLayoutRowView` + `BottleUnitView` + `BottleSlotView`（主视图字段：labId:String*, unitType:String*, rows:List<BottleLayoutRowView>*, managementRevision:String*）
- 枚举冻结：BottleUnitType=S/F；BottleReadingQuality=GOOD/STALE/BAD/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：液瓶配置逐接口与观测边界.md §读取叶子及观测规则, §GET /lab/bottle-config/layout｜任务包 TP-M02-12

## M02-252｜PUT /lab/bottle-config/sampling-units/{labId}/{unitCode}｜液瓶配置
- 权限：lab:bottle-config:edit＋实际实验室管理等级2
- Controller→Service：`com.futurefab.system.controller.BottleConfigController#saveSamplingUnit` → `com.futurefab.system.service.IBottleConfigService#saveSamplingUnit`
- Request `SamplingUnitBottleSaveCommand`：labId:String*, unitCode:String*, slots:List<SamplingSlotInput>*, requestId:String, managementRevision:String
- Response：`MutationResult` + `SamplingSlotInput`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, RESOURCE_IN_USE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=bottle_config
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：液瓶配置逐接口与观测边界.md §PUT /lab/bottle-config/sampling-units/{labId}/{unitCode}｜任务包 TP-M02-12

## M02-253｜PUT /lab/bottle-config/feeding-slots/{bottleId}｜液瓶配置
- 权限：lab:bottle-config:edit＋该槽真实实验室管理等级2
- Controller→Service：`com.futurefab.system.controller.BottleConfigController#saveFeedingSlot` → `com.futurefab.system.service.IBottleConfigService#saveFeedingSlot`
- Request `FeedingSlotBottleSaveCommand`：bottleId:String*, consumableId:String, liquidType:String, requestId:String, managementRevision:String
- Response：`MutationResult`（主视图字段：）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, RESOURCE_IN_USE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=bottle_config
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：液瓶配置逐接口与观测边界.md §PUT /lab/bottle-config/feeding-slots/{bottleId}｜任务包 TP-M02-12

## M02-254｜GET /lab/pumpconnection/{connectionId}/capabilities｜小试控制器能力
- 权限：lab:pumpconnection:query＋原实例实验室可见范围
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorControllerController#getCapabilities` → `com.futurefab.system.service.ILabBenchReactorControllerService#getCapabilities`
- Request `ControllerCapabilityQuery`：connectionId:String*
- Response：`ControllerCapabilityView`（主视图字段：connectionId:String*, mfcCount:Long, thresholdWeightG:String, temperatureControl:Boolean, weightControl:Boolean, pressureControl:Boolean, managementRevision:String*, configurationReady:Boolean*, configurationIssues:List<String>*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, PERMISSION_DENIED, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：控制器能力接口契约.md §1-§2｜任务包 TP-M02-01

## M02-255｜PUT /lab/pumpconnection/{connectionId}/capabilities｜小试控制器能力
- 权限：lab:pumpconnection:edit＋原实验室操作等级1/管理等级2
- Controller→Service：`com.futurefab.system.controller.LabBenchReactorControllerController#saveCapabilities` → `com.futurefab.system.service.ILabBenchReactorControllerService#saveCapabilities`
- Request `ControllerCapabilitySaveCommand`：connectionId:String*, mfcCount:Long, thresholdWeightG:String, temperatureControl:Boolean, weightControl:Boolean, pressureControl:Boolean, requestId:String, managementRevision:String
- Response：`ControllerCapabilityView`（主视图字段：connectionId:String*, mfcCount:Long, thresholdWeightG:String, temperatureControl:Boolean, weightControl:Boolean, pressureControl:Boolean, managementRevision:String*, configurationReady:Boolean*, configurationIssues:List<String>*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PERMISSION_DENIED, NOT_FOUND, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, REFERENCE_EXISTS, RESOURCE_IN_USE, MANAGEMENT_BUSY, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M01:ActorContext ; M01:Permission
- 来源：控制器能力接口契约.md §1,§3(仅空闲且无当前模板/运行配置依赖才允许能力结构变更)｜任务包 TP-M02-01

# M03（23 条）

## M03-001｜GET /resource/project/list｜UI01-项目管理
- 权限：resource:project:list（Q30本人参与范围过滤）
- Controller→Service：`com.futurefab.system.controller.ResProjectController#list` → `com.futurefab.system.service.IResProjectService#selectResProjectList`
- Request `ProjectPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, timeType:TimeType, fromDate:LocalDate, toDate:LocalDate
- Response：`ProjectRow` + `NamedRef` + `DictionaryRef` + `AuditView`（主视图字段：projectId:String*, version:String*, projectCode:String*, dept:NamedRef*, leaders:List<NamedRef>*, labs:List<NamedRef>*, tags:List<DictionaryRef>*, remark:String, batchCount:Long, countsComplete:Boolean*, audit:AuditView*, allowedActions:List<String>*）
- 枚举冻结：TimeType=CREATE/UPDATE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.3/7.4(定位006)｜任务包 TP-M03-04

## M03-002｜GET /resource/project/{projectId}｜UI01-项目管理
- 权限：resource:project:query
- Controller→Service：`com.futurefab.system.controller.ResProjectController#getInfo` → `com.futurefab.system.service.IResProjectService#selectResProjectByProjectId`
- Request `ProjectDetailQuery`：projectId:String*
- Response：`ProjectDetailView` + `NamedRef` + `DictionaryRef` + `AuditView`（主视图字段：projectId:String*, version:String*, projectCode:String*, dept:NamedRef*, leaders:List<NamedRef>*, labs:List<NamedRef>*, tags:List<DictionaryRef>*, remark:String, batchCount:Long, countsComplete:Boolean*, audit:AuditView*, allowedActions:List<String>*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.3/7.4(定位007)｜任务包 TP-M03-04

## M03-003｜GET /resource/project/options｜UI01-项目管理
- 权限：按purpose判权：PROJECT_CREATE→项目新增资格(resource:project:add语义)、PROJECT_EDIT→编辑资格(resource:project:edit语义)，Q30只读权不授予完整编辑候选
- Controller→Service：`com.futurefab.system.controller.ResProjectController#listOptions` → `com.futurefab.system.service.application.m03.ProjectApplicationService#listOptions`
- Request `ProjectOptionQuery`：purpose:ProjectOptionPurpose*, field:ProjectOptionField*, deptId:String, projectId:String, keyword:String, pageNum:Integer, pageSize:Integer
- Response：`ProjectOptionPage` + `Option` + `NamedRef`（主视图字段：items:List<Option>*, total:Long*, defaultLabIds:List<String>*）
- 枚举冻结：ProjectOptionPurpose=PROJECT_CREATE/PROJECT_EDIT；ProjectOptionField=DEPT/LEADER/LAB/TAG
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.3/7.4(定位008)｜任务包 TP-M03-04

## M03-004｜POST /resource/project｜UI01-项目管理
- 权限：resource:project:add
- Controller→Service：`com.futurefab.system.controller.ResProjectController#add` → `com.futurefab.system.service.IResProjectService#insertResProject`
- Request `ProjectCreateCommand`：requestId:String*, managementRevision:String*, projectCode:String*, deptId:String*, leaderUserIds:List<String>*, labIds:List<String>*, tagIds:List<String>*, remark:String
- Response：`W` + `WriteItem`（主视图字段：applied:Boolean*, managementRevision:String*, results:List<WriteItem>*）
- 枚举冻结：State=DRAFT/NOT_STARTED/RUNNING/EXPIRED/DELAYED/CANCELLED/FINISHED
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PROTOCOL_UPGRADE_REQUIRED, UNAUTHENTICATED, PERMISSION_DENIED, CODE_CONFLICT, MANAGEMENT_CONFLICT, REQUEST_CONFLICT, LAB_AUTHORIZATION_UNAVAILABLE, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_project
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.3/7.4(定位009)｜任务包 TP-M03-04

## M03-005｜PUT /resource/project/{projectId}｜UI01-项目管理
- 权限：resource:project:edit（Q05核验）
- Controller→Service：`com.futurefab.system.controller.ResProjectController#edit` → `com.futurefab.system.service.IResProjectService#updateResProject`
- Request `ProjectUpdateCommand`：projectId:String*, requestId:String*, managementRevision:String*, expectedVersion:String*, projectCode:String*, deptId:String*, leaderUserIds:List<String>*, labIds:List<String>*, tagIds:List<String>*, remark:String
- Response：`W` + `WriteItem`（主视图字段：applied:Boolean*, managementRevision:String*, results:List<WriteItem>*）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PROTOCOL_UPGRADE_REQUIRED, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, CODE_CONFLICT, REFERENCE_EXISTS, MANAGEMENT_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, LAB_AUTHORIZATION_UNAVAILABLE, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_project
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.3/7.4(定位010)｜任务包 TP-M03-04

## M03-006｜POST /resource/project/{projectId}/delete-preview｜UI01-项目管理
- 权限：resource:project:remove（Q20项目删除权及完整可展示范围）
- Controller→Service：`com.futurefab.system.controller.ResProjectController#deletePreview` → `com.futurefab.system.service.application.m03.ProjectApplicationService#deletePreview`
- Request `ProjectDeletePreviewQuery`：projectId:String*
- Response：`DeletePreview` + `TargetRef` + `DeletePreviewBlocker`（主视图字段：target:TargetRef*, canDelete:Boolean*, blockers:List<DeletePreviewBlocker>*, cascadeBatches:List<TargetRef>*, cascadeBatchCount:Long*, snapshotToken:String, expiresAt:OffsetDateTime）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, REFERENCE_EXISTS, FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.4(定位011)｜任务包 TP-M03-04

## M03-007｜POST /resource/project/{projectId}/delete｜UI01-项目管理
- 权限：resource:project:remove（锁后复核Q20当前身份及删除功能权限）
- Controller→Service：`com.futurefab.system.controller.ResProjectController#delete` → `com.futurefab.system.service.application.m03.ProjectApplicationService#delete`
- Request `ProjectDeleteCommand`：projectId:String*, requestId:String*, managementRevision:String*, expectedVersion:String*, snapshotToken:String*
- Response：`W` + `WriteItem`（主视图字段：applied:Boolean*, managementRevision:String*, results:List<WriteItem>*）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, MANAGEMENT_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, DELETE_SCOPE_CHANGED, PREVIEW_EXPIRED, REFERENCE_EXISTS, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_project
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.4(定位012)｜任务包 TP-M03-04

## M03-008｜GET /resource/batch/list｜UI02-批次与培养聚合
- 权限：resource:batch:list（Q31叠加所属实验室可见范围）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#list` → `com.futurefab.system.service.IResBatchService#selectResBatchList`
- Request `BatchPageQuery`：pageNum:Integer, pageSize:Integer, keyword:String, timeType:TimeType, fromDate:LocalDate, toDate:LocalDate, projectId:String, labId:String
- Response：`BatchRow` + `NamedRef` + `DictionaryRef` + `AuditView`（主视图字段：batchId:String*, version:String*, batchCode:String*, alias:String, project:NamedRef*, projectDept:NamedRef*, projectLeaders:List<NamedRef>*, projectTags:List<DictionaryRef>*, lab:NamedRef*, leaders:List<NamedRef>*, cultureCount:Long, countsComplete:Boolean*, audit:AuditView*, allowedActions:List<String>*）
- 枚举冻结：TimeType=CREATE/UPDATE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, LAB_AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision ; M03→M02: 资源、能力、工程和设备配置读取端口
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.3/7.5(定位013)｜任务包 TP-M03-05

## M03-009｜GET /resource/batch/{batchId}｜UI02-批次与培养聚合
- 权限：resource:batch:query（Q31复核所属实验室可见权限）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#getInfo` → `com.futurefab.system.service.IResBatchService#selectResBatchByBatchId`
- Request `BatchDetailQuery`：batchId:String*
- Response：`BatchDetailView` + `NamedRef` + `DictionaryRef` + `AuditView`（主视图字段：batchId:String*, version:String*, batchCode:String*, alias:String, project:NamedRef*, projectDept:NamedRef*, projectLeaders:List<NamedRef>*, projectTags:List<DictionaryRef>*, lab:NamedRef*, leaders:List<NamedRef>*, cultureCount:Long, countsComplete:Boolean*, audit:AuditView*, allowedActions:List<String>*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, LAB_AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision ; M03→M02: 资源、能力、工程和设备配置读取端口
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.3/7.5(定位014)｜任务包 TP-M03-05

## M03-010｜GET /resource/batch/options｜UI02-批次与培养聚合
- 权限：按purpose实际动作判权（BATCH_CREATE→Q23、BATCH_EDIT→Q22、CULTURE_CREATE→Q24/Q29、CULTURE_EDIT→Q25/Q29、CULTURE_REBOOK→Q27/Q29、FILTER→list查看功能）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#listOptions` → `com.futurefab.system.service.application.m03.BatchApplicationService#listOptions`
- Request `BatchOptionQuery`：purpose:BatchOptionPurpose*, field:BatchOptionField*, keyword:String, pageNum:Integer, pageSize:Integer, projectId:String, batchId:String, labId:String, cultureId:String
- Response：`BatchOptionPage` + `Option` + `NamedRef` + `DeviceView` + `DeviceRef` + `CandidateContext`（主视图字段：items:List<Option>*, total:Long*, context:CandidateContext）
- 枚举冻结：BatchOptionPurpose=BATCH_CREATE/BATCH_EDIT/CULTURE_CREATE/CULTURE_EDIT/CULTURE_REBOOK/BATCH_FILTER/CULTURE_FILTER；BatchOptionField=PROJECT/BATCH/LAB/LEADER/DEVICE；DeviceRefKind=INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER；DeviceAvailability=AVAILABLE/OWN_RESERVED/OTHER_OCCUPIED/INVALID/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, PARENT_MISMATCH, FACTS_UNAVAILABLE, LAB_AUTHORIZATION_UNAVAILABLE, RETRY_LATER
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision ; M03→M02: 资源、能力、工程和设备配置读取端口
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.3/7.5(定位015)｜任务包 TP-M03-05

## M03-011｜POST /resource/batch｜UI02-批次与培养聚合
- 权限：resource:batch:add（Q23批次新增权；新增培养逐条Q24/Q29）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#add` → `com.futurefab.system.service.IResBatchService#insertResBatch`
- Request `BatchCreateCommand`：requestId:String*, managementRevision:String*, projectId:String*, batchCode:String*, labId:String*, alias:String, batchLeaderUserIds:List<String>*, cultureCreates:List<CultureCreateItem>*, cultureUpdates:List<CultureUpdateItem>*, cultureDeletes:List<CultureDeleteItem>*
- Response：`W` + `WriteItem` + `CultureCreateItem` + `CInput` + `DeviceRef` + `CultureUpdateItem` + `CPatch` + `CultureDeleteItem`（主视图字段：applied:Boolean*, managementRevision:String*, results:List<WriteItem>*）
- 枚举冻结：CultureMode=NORMAL/REACTOR；DeviceRefKind=INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PROTOCOL_UPGRADE_REQUIRED, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, PLAN_INCONSISTENT, BATCH_LIMIT_EXCEEDED, CODE_CONFLICT, PARENT_MISMATCH, COMPOSITE_CHANGE_CONFLICT, DEVICE_OCCUPIED, DEVICE_INVALID, STATE_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, LAB_AUTHORIZATION_UNAVAILABLE, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_batch
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision ; M03→M02: 资源、能力、工程和设备配置读取端口 ; M03→M02: 占用/释放守卫
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.3/7.5(定位016)｜任务包 TP-M03-05

## M03-012｜PUT /resource/batch/{batchId}｜UI02-批次与培养聚合
- 权限：按动作拆分：提交BInput→resource:batch:edit(Q22)；培养新增Q24、基础修改Q25、删除Q26逐条判权
- Controller→Service：`com.futurefab.system.controller.ResBatchController#edit` → `com.futurefab.system.service.IResBatchService#updateResBatch`
- Request `BatchUpdateCommand`：batchId:String*, requestId:String*, managementRevision:String*, expectedVersion:String*, projectId:String, batchCode:String, labId:String, alias:String, batchLeaderUserIds:List<String>, cultureCreates:List<CultureCreateItem>*, cultureUpdates:List<CultureUpdateItem>*, cultureDeletes:List<CultureDeleteItem>*
- Response：`W` + `WriteItem` + `CultureCreateItem` + `CInput` + `DeviceRef` + `CultureUpdateItem` + `CPatch` + `CultureDeleteItem`（主视图字段：applied:Boolean*, managementRevision:String*, results:List<WriteItem>*）
- 枚举冻结：CultureMode=NORMAL/REACTOR；DeviceRefKind=INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PROTOCOL_UPGRADE_REQUIRED, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, PARENT_MISMATCH, PLAN_INCONSISTENT, BATCH_LIMIT_EXCEEDED, CODE_CONFLICT, COMPOSITE_CHANGE_CONFLICT, DEVICE_OCCUPIED, DEVICE_INVALID, STATE_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, LAB_AUTHORIZATION_UNAVAILABLE, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_batch
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision ; M03→M02: 资源、能力、工程和设备配置读取端口 ; M03→M02: 占用/释放守卫
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.3/7.5(定位017)｜任务包 TP-M03-05

## M03-015｜POST /resource/batch/{batchId}/delete-preview｜UI02-批次与培养聚合
- 权限：resource:batch:remove（Q21批次删除权）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#deletePreview` → `com.futurefab.system.service.application.m03.BatchApplicationService#deletePreview`
- Request `BatchDeletePreviewQuery`：batchId:String*
- Response：`DeletePreview` + `TargetRef` + `DeletePreviewBlocker`（主视图字段：target:TargetRef*, canDelete:Boolean*, blockers:List<DeletePreviewBlocker>*, cascadeBatches:List<TargetRef>*, cascadeBatchCount:Long*, snapshotToken:String, expiresAt:OffsetDateTime）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, REFERENCE_EXISTS, FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.4/7.5(定位020)｜任务包 TP-M03-05

## M03-016｜POST /resource/batch/{batchId}/delete｜UI02-批次与培养聚合
- 权限：resource:batch:remove（锁内复核Q21身份及功能权限、Q19空对象资格）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#delete` → `com.futurefab.system.service.application.m03.BatchApplicationService#delete`
- Request `BatchDeleteCommand`：batchId:String*, requestId:String*, managementRevision:String*, expectedVersion:String*, snapshotToken:String*
- Response：`W` + `WriteItem`（主视图字段：applied:Boolean*, managementRevision:String*, results:List<WriteItem>*）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, MANAGEMENT_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, DELETE_SCOPE_CHANGED, PREVIEW_EXPIRED, REFERENCE_EXISTS, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_batch
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.5(定位021)｜任务包 TP-M03-05

## M03-025｜POST /resource/grants/query｜UI04-成员分享与退出
- 权限：purpose=SELF→目标合法查看范围；purpose=MANAGE→逐目标相应members/share功能权限
- Controller→Service：`com.futurefab.system.controller.ResGrantController#queryGrants` → `com.futurefab.system.service.application.m03.GrantApplicationService#queryGrants`
- Request `GrantQuery`：targetType:GrantTargetType*, targetIds:List<String>*, grantType:GrantType*, purpose:GrantPurpose*
- Response：`GrantsView` + `TargetRef` + `GrantSource` + `Option` + `NamedRef` + `GrantMemberSetup`（主视图字段：targets:List<TargetRef>*, sources:List<GrantSource>*, memberSetup:List<GrantMemberSetup>*, canSubmit:Boolean*, reasonCodes:List<String>*）
- 枚举冻结：GrantTargetType=PROJECT/BATCH/CULTURE；GrantType=MEMBER/SHARE；GrantPurpose=SELF/MANAGE；GrantSourceGrantType=MEMBER/SHARE/CREATOR/LEADER；GrantSourceStatus=ACTIVE/EXPIRED/INVALID；MemberSetupState=NEVER/CONFIGURED/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, ASSIGNMENT_DENIED, NOT_FOUND, FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.7(定位030)｜任务包 TP-M03-07

## M03-026｜POST /resource/grants/candidates｜UI04-成员分享与退出
- 权限：相应授权动作管理权（members/share按GrantContext）
- Controller→Service：`com.futurefab.system.controller.ResGrantController#candidates` → `com.futurefab.system.service.application.m03.GrantApplicationService#candidates`
- Request `GrantCandidateQuery`：targetType:GrantTargetType*, targetIds:List<String>*, grantType:GrantType*, keyword:String, deptId:String, groupId:String, pageNum:Integer, pageSize:Integer
- Response：`GrantCandidateView` + `NamedRef`（主视图字段：id:String*, name:String*, selectable:Boolean*, reasonCode:String, parentId:String, userName:String, deptName:String, roles:List<NamedRef>*）
- 枚举冻结：GrantTargetType=PROJECT/BATCH/CULTURE；GrantType=MEMBER/SHARE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, ASSIGNMENT_DENIED, FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.7(定位031)｜任务包 TP-M03-07

## M03-027｜POST /resource/grants/save｜UI04-成员分享与退出
- 权限：相应members/share功能权限（逐目标独立判权；PROJECT/BATCH单目标、CULTURE可1–100个）
- Controller→Service：`com.futurefab.system.controller.ResGrantController#saveGrants` → `com.futurefab.system.service.application.m03.GrantApplicationService#saveGrants`
- Request `GrantSaveCommand`：requestId:String*, managementRevision:String*, targetType:GrantTargetType*, targetIds:List<String>*, grantType:GrantType*, targets:List<GrantTargetRef>*, changes:GrantChanges*, selectionToken:String
- Response：`W` + `WriteItem` + `GrantTargetRef` + `GrantChanges` + `GrantUserExpiry`（主视图字段：applied:Boolean*, managementRevision:String*, results:List<WriteItem>*）
- 枚举冻结：GrantTargetType=PROJECT/BATCH/CULTURE；GrantType=MEMBER/SHARE
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, READ_ONLY_FIELD, PROTOCOL_UPGRADE_REQUIRED, UNAUTHENTICATED, PERMISSION_DENIED, ASSIGNMENT_DENIED, NOT_FOUND, MEMBER_ALREADY_CONFIGURED, GRANT_CONFLICT, SELECTION_EXPIRED, MANAGEMENT_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_project_member|res_batch_member|res_culture_member（按GrantContext.targetType）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.7(定位032)｜任务包 TP-M03-07

## M03-028｜POST /resource/{type}/{id}/exit-preview｜UI04-成员分享与退出
- 权限：本人会话（type=project/batch/culture）
- Controller→Service：`com.futurefab.system.controller.ResGrantController#exitPreview` → `com.futurefab.system.service.application.m03.GrantApplicationService#exitPreview`
- Request `GrantExitPreviewQuery`：type:String*, id:String*
- Response：`GrantExitPreviewView` + `TargetRef` + `AccessSummary` + `GrantSource` + `Option` + `NamedRef`（主视图字段：target:TargetRef*, hasDirectMembership:Boolean*, remainingAccess:AccessSummary*）
- 枚举冻结：GrantSourceGrantType=MEMBER/SHARE/CREATOR/LEADER；GrantSourceStatus=ACTIVE/EXPIRED/INVALID
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.7(定位033)｜任务包 TP-M03-07

## M03-029｜POST /resource/{type}/{id}/exit｜UI04-成员分享与退出
- 权限：resource:{project|batch|culture}:exit（EXIT独立功能码）
- Controller→Service：`com.futurefab.system.controller.ResGrantController#exit` → `com.futurefab.system.service.application.m03.GrantApplicationService#exit`
- Request `GrantExitCommand`：type:String*, id:String*, requestId:String*, managementRevision:String*, expectedVersion:String*
- Response：`GrantExitResult` + `W` + `WriteItem` + `AccessSummary` + `GrantSource` + `Option` + `NamedRef` + `TargetRef`（主视图字段：write:W*, remainingAccess:AccessSummary*）
- 枚举冻结：GrantSourceGrantType=MEMBER/SHARE/CREATOR/LEADER；GrantSourceStatus=ACTIVE/EXPIRED/INVALID
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INPUT_INVALID, PROTOCOL_UPGRADE_REQUIRED, UNAUTHENTICATED, PERMISSION_DENIED, NOT_FOUND, STATE_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, REQUEST_CONFLICT, RETRY_LATER
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=res_project_member|res_batch_member|res_culture_member（按type）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.2/7.7(定位034)｜任务包 TP-M03-07

## M03-030｜POST /resource/grants/selection-snapshot｜UI04-成员分享与退出
- 权限：相应授权动作管理权（members/share按GrantContext）
- Controller→Service：`com.futurefab.system.controller.ResGrantController#selectionSnapshot` → `com.futurefab.system.service.application.m03.GrantApplicationService#selectionSnapshot`
- Request `GrantSelectionSnapshotCommand`：targetType:GrantTargetType*, targetIds:List<String>*, grantType:GrantType*, mode:GrantSelectionMode*, departmentId:String, groupId:String, userIds:List<String>
- Response：`GrantSelectionSnapshotView` + `Option` + `NamedRef`（主视图字段：selectionToken:String*, expiresAt:OffsetDateTime*, users:List<Option>*, count:Long*）
- 枚举冻结：GrantTargetType=PROJECT/BATCH/CULTURE；GrantType=MEMBER/SHARE；GrantSelectionMode=DEPARTMENT/GROUP/USERS
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INPUT_INVALID, UNAUTHENTICATED, PERMISSION_DENIED, ASSIGNMENT_DENIED, FACTS_UNAVAILABLE, RETRY_LATER
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M03→M01: ActorContext / Permission / managementRevision
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.7(定位035)｜任务包 TP-M03-07

## M03-039｜DELETE /resource/project/{projectIds}｜UI01-项目管理
- 权限：resource:project:remove（现有注解）
- Controller→Service：`com.futurefab.system.controller.ResProjectController#remove` → `com.futurefab.system.service.application.m03.LegacyResourceEndpointGuard#rejectProjectDelete`
- Request `LegacyProjectDeleteCommand`：projectIds:String*
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：PROTOCOL_UPGRADE_REQUIRED
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.1/7.8(M03-API-C11) + 物理接口与骨架字段设计.md§1｜任务包 TP-M03-04

## M03-040｜DELETE /resource/batch/{batchIds}｜UI02-批次与培养聚合
- 权限：resource:batch:remove（现有注解）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#remove` → `com.futurefab.system.service.application.m03.LegacyResourceEndpointGuard#rejectBatchDelete`
- Request `LegacyBatchDeleteCommand`：batchIds:String*
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：PROTOCOL_UPGRADE_REQUIRED
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.1/7.8(M03-API-C11) + 物理接口与骨架字段设计.md§1｜任务包 TP-M03-05

## M03-042｜PUT /resource/batch/exit｜UI04-成员分享与退出
- 权限：resource:batch:edit（现有注解）
- Controller→Service：`com.futurefab.system.controller.ResBatchController#exit` → `com.futurefab.system.service.application.m03.LegacyResourceEndpointGuard#rejectBatchExit`
- Request `LegacyBatchExitCommand`：id:Long*
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：PROTOCOL_UPGRADE_REQUIRED
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：docs/详细设计/03-项目与培养管理/详细设计.md#7.1｜任务包 TP-M03-07

# M04（21 条）

## M04-001｜GET /system/process/templates/context｜P02
- 权限：process:{kindCode}:add（kindCode=config/perfusion/sampling/autoControl/feeding/pumpSpeed 六类，详细设计§9.1）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#getCreateContext` → `com.futurefab.system.service.IProcessTemplateApplicationService#getCreateContext`
- Request `TemplateCreateContextQuery`：templateKind:TemplateKind*
- Response：`TemplateCreateContextView`（主视图字段：templateKind:TemplateKind, allowedActions:List<String>）
- 枚举冻结：TemplateKind=CONFIG/PERFUSION/SAMPLING/AUTO_CONTROL/FEEDING/PUMP_SPEED
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, INPUT_INVALID
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.1/§9.2/§9.4｜任务包 TP-M04-01

## M04-002｜GET /system/process/templates/{templateId}｜P02
- 权限：process:{kindCode}:query（query及对象可见）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#getTemplateDetail` → `com.futurefab.system.service.IProcessTemplateApplicationService#getTemplateDetail`
- Request `TemplateDetailQuery`：templateId:String*
- Response：`TemplateDetailView` + `Summary` + `VersionMeta` + `Applicability` + `ModelRef` + `BindingView` + `SamplingContent` + `BgaBranch` + `TemperatureSpec` + `StabilitySpec` + `VicellBranch` + `OsmoBranch` + `CedexBranch` + `CedexItem` + `CedexItemSnapshot` + `PumpSpeedContent` + `PumpCalibration` + `PumpStage` + `PumpMonitor` + `JitterSpec` + `BackflowSpec` + `ClogSpec` + `ConfigContent` + `ConfigMfcRow` + `ConfigMfcValues` + `ConfigPumpRow` + `ConfigPumpValues` + `ConfigLoops` + `Map2Loop` + `InitialOutLoop` + `JacketTempLoop` + `Map2Output` + `ChannelSource` + `PidSet` + `PidValues` + `ConfigProcess` + `CoarseAirRow` + `FineAirRow` + `PressureDrop` + `ExchangeConfig` + `PerfusionContent` + `PerfusionMedium` + `PerfusionTargets` + `PhDeadband` + `PerfusionDetection` + `FirstDetection` + `SecondDetection` + `PerfPhCalibration` + `PerfDoAdjustment` + `Po2Limits` + `Po2Bound` + `Pco2Limits` + `Pco2Bound` + `PerfusionParameters` + `PerfMfcRow` + `PerfMfcValues` + `PerfPumpRow` + `PerfPumpValues` + `PerfLoops` + `LoopOverride` + `LoopOverrideValues` + `PidOverride` + `AutoControlContent` + `AutoReactorSpec` + `AutoMfcRow` + `AutoMfcValues` + `AutoRules` + `DetectionSpec` + `SamplingRule` + `PhAdjRule` + `OperatorValueC` + `Window` + `WindowBound` + `AerationRule` + `AgitationRule` + `MicrobubbleRule` + `TempRule` + `VcdCondition` + `AutoEndNotice` + `ViabilityCondition` + `FeedingContent` + `FeedingPumpRow` + `ConsumableRef` + `SpeedSelection` + `FeedingResourceSnapshot` + `SnapshotMedium` + `SnapshotConsumable` + `FlowSourceFact` + `FeedingRules` + `FeedingRule` + `SugarRule` + `SugarFixedAmount` + `SugarConcentration`（主视图字段：template:Summary, version:VersionMeta, content:SamplingContent|PumpSpeedContent|ConfigContent|PerfusionContent|AutoControlContent|FeedingContent, applicability:Applicability, bindings:List<BindingView>, redactedPaths:List<String>）
- 枚举冻结：TemplateKind=CONFIG/PERFUSION/SAMPLING/AUTO_CONTROL/FEEDING/PUMP_SPEED；CalculationProfile=NONE/M04_CALC_V1；ChangeKind=CREATE/EDIT/COPY/IMPORT；BindingSourceState=ENABLED/DISABLED/DELETED/UNKNOWN；LabCategory=PILOT/SMALL；LabTypeScope=PILOT/SMALL/COMMON；ModelKind=INTEGRATED_MODEL/BENCH_CONTROLLER_MODEL；ReactorType=INTEGRATED_REACTOR/BENCH_REACTOR；SelectedType=BGA/VICELL/OSMO/CEDEX；DetectionMode=AUTO/MANUAL；TemperatureMode=DEFAULT/FIXED；StabilityMode=NONE/FIXED；StrategyType=TWO_STAGE/THREE_STAGE；GasType=AIR/O2/CO2；MfcRoute=HEAD_SPACE/SPARGER_1/SPARGER_2；RegulationMode=SPEED/FLOW；PumpDirection=CW/CCW；ChannelKind=MFC/PUMP；WeightUnit=G/KG；ComparatorGELE=GE/GT/LE/LT；NAC=LT/LE/NA；LTLE=LT/LE；AutoManualMode=AUTO/MANUAL；CasManAuto=CAS/MAN/AUTO；LogicalJoin=AND/OR；DetectionBaseType=RULE_TIME/TASK_COMPLETED_AT/PREDICTED_AT；ExecutionOrder=FEED_THEN_COOL/COOL_THEN_FEED；ConsumableKind=LIQUID_BAG/BUCKET；SpeedSelectionKind=UNUSED/CODE/TEMPLATE；FlowDeviceKind=INTEGRATED_REACTOR/BENCH_CONTROLLER；FeedingCalculationType=AMOUNT/PERCENT；SugarPlanMode=FIXED_AMOUNT/CONCENTRATION_RULE；SugarCalculationMode=GLUCOSE/GLUCOSE_LACTATE；TemplateAllowedAction=VIEW/EDIT/COPY/ENABLE/DISABLE/DELETE/HISTORY
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, SCHEMA_UNSUPPORTED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.2/§9.4；模板内容存储契约.md §2/§3/§7/§8/§9/§11/§12/§13（六类content字段树权威定义；API04/05/06/07/08的content/effectiveInput类均引用本接口嵌套集合，输入投影按§9.3移除服务端只读叶子）｜任务包 TP-M04-01

## M04-003｜GET /system/process/templates/{templateId}/versions｜P02
- 权限：process:{kindCode}:query（query及对象可见）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#pageTemplateVersions` → `com.futurefab.system.service.IProcessTemplateApplicationService#pageTemplateVersions`
- Request `TemplateVersionPageQuery`：templateId:String*, pageNum:Integer, pageSize:Integer
- Response：`TemplateVersionView`（主视图字段：versionId:String, versionNo:String, previousVersionId:String, nameSnapshot:String, contentSchemaVersion:Long, calculationProfile:CalculationProfile, canonicalHash:String, savedByUserId:String, savedAt:OffsetDateTime, changeKind:ChangeKind）
- 枚举冻结：CalculationProfile=NONE/M04_CALC_V1；ChangeKind=CREATE/EDIT/COPY/IMPORT
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.2/§9.4｜任务包 TP-M04-01

## M04-004｜GET /system/process/templates/{templateId}/versions/{versionId}｜P02
- 权限：process:{kindCode}:query（query及对象可见）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#getTemplateVersionDetail` → `com.futurefab.system.service.IProcessTemplateApplicationService#getTemplateVersionDetail`
- Request `TemplateVersionDetailQuery`：templateId:String*, versionId:String*
- Response：`TemplateDetailView`（主视图字段：template:Summary, version:VersionMeta, content:SamplingContent|PumpSpeedContent|ConfigContent|PerfusionContent|AutoControlContent|FeedingContent, applicability:Applicability, bindings:List<BindingView>, redactedPaths:List<String>）
- 枚举冻结：TemplateKind=CONFIG/PERFUSION/SAMPLING/AUTO_CONTROL/FEEDING/PUMP_SPEED
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, SCHEMA_UNSUPPORTED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.2/§9.4｜任务包 TP-M04-01

## M04-007｜PUT /system/process/templates/{templateId}｜P02
- 权限：process:{kindCode}:edit
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#updateTemplate` → `com.futurefab.system.service.IProcessTemplateApplicationService#updateTemplate`
- Request `TemplateUpdateCommand`：expectedObjectVersion:String*, expectedCurrentVersionId:String*, templateName:String*, content:InputContent*, bindings:List<BindingInput>*, requestId:String*, managementRevision:String*
- Response：`TemplateWriteResult`（主视图字段：applied:Boolean, templateId:String, currentVersionId:String, objectVersion:String, status:String, deleted:Boolean, managementRevision:String, warnings:List<Issue>）
- 枚举冻结：BindingAction=SELECT/RELOAD/RETAIN
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, READ_ONLY_FIELD, SCHEMA_UNSUPPORTED, NO_CHANGE, NAME_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, SOURCE_VERSION_CONFLICT, STATE_CONFLICT, SOURCE_UNAVAILABLE, CONFIGURATION_INCONSISTENT, BINDING_INVALID, APPLICABILITY_CONFLICT, CONTENT_INVALID, ENGINEERING_REVOKED, LAB_AUTHORIZATION_UNAVAILABLE, RESOURCE_FACTS_UNAVAILABLE, RESOURCE_MAPPING_UNRESOLVED
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=prc_template
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:resolveEngineering ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.3/§9.4｜任务包 TP-M04-01

## M04-008｜POST /system/process/templates/{templateId}/copies｜P02
- 权限：process:{sourceKind}:query + process:{kindCode}:add（来源query+目标同类型add）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#copyTemplate` → `com.futurefab.system.service.IProcessTemplateApplicationService#copyTemplate`
- Request `TemplateCopyCommand`：copySourceVersionId:String*, expectedSourceObjectVersion:String*, status:String*, templateName:String*, content:InputContent*, bindings:List<BindingInput>*, ruleCopies:List<RuleCopy>*, requestId:String*, managementRevision:String*
- Response：`TemplateWriteResult` + `RuleCopy`（主视图字段：applied:Boolean, templateId:String, currentVersionId:String, objectVersion:String, status:String, deleted:Boolean, managementRevision:String, warnings:List<Issue>）
- 枚举冻结：BindingAction=SELECT/RELOAD/RETAIN
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, READ_ONLY_FIELD, SCHEMA_UNSUPPORTED, ACTION_NOT_SUPPORTED, NO_CHANGE, NAME_CONFLICT, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, SOURCE_VERSION_CONFLICT, STATE_CONFLICT, SOURCE_UNAVAILABLE, CONFIGURATION_INCONSISTENT, BINDING_INVALID, APPLICABILITY_CONFLICT, CONTENT_INVALID, ENGINEERING_REVOKED, LAB_AUTHORIZATION_UNAVAILABLE, RESOURCE_FACTS_UNAVAILABLE, RESOURCE_MAPPING_UNRESOLVED
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=prc_template
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:resolveEngineering ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.3/§9.4｜任务包 TP-M04-01

## M04-009｜PUT /system/process/templates/{templateId}/status｜P02
- 权限：process:{kindCode}:changeStatus
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#changeTemplateStatus` → `com.futurefab.system.service.IProcessTemplateApplicationService#changeTemplateStatus`
- Request `TemplateStatusChangeCommand`：expectedObjectVersion:String*, status:String*, requestId:String*, managementRevision:String*
- Response：`TemplateWriteResult`（主视图字段：applied:Boolean, templateId:String, currentVersionId:String, objectVersion:String, status:String, deleted:Boolean, managementRevision:String, warnings:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, STATE_CONFLICT
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=prc_template
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.2/§9.4｜任务包 TP-M04-01

## M04-010｜POST /system/process/templates/{templateId}/delete｜P02
- 权限：process:{kindCode}:remove
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#deleteTemplate` → `com.futurefab.system.service.IProcessTemplateApplicationService#deleteTemplate`
- Request `TemplateDeleteCommand`：expectedObjectVersion:String*, requestId:String*, managementRevision:String*
- Response：`TemplateWriteResult`（主视图字段：applied:Boolean, templateId:String, currentVersionId:String, objectVersion:String, status:String, deleted:Boolean, managementRevision:String, warnings:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, VERSION_CONFLICT, STATE_CONFLICT
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=prc_template
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §9.2/§9.4｜任务包 TP-M04-01

## M04-011｜GET /system/process/templates/list｜P02
- 权限：process:{kindCode}:list
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#pageTemplates` → `com.futurefab.system.service.IProcessTemplateApplicationService#pageTemplates`
- Request `TemplatePageQuery`：templateKind:TemplateKind*, pageNum:Integer, pageSize:Integer, reactorType:ReactorType, controlPlatform:String, keyword:String, timeField:TimeField, beginDate:LocalDate, endDate:LocalDate, status:String, applicableLabId:String, cultureDays:Integer, modelKind:ModelKind, modelId:String, cultureDaysKeyword:String, labType:LabTypeScope, strategyType:StrategyType
- Response：`TemplateListRow` + `ConfigColumns` + `PerfusionColumns` + `SamplingColumns` + `AutoControlColumns` + `FeedingColumns` + `PumpSpeedColumns` + `PumpCalibrationRead` + `PumpRateRead` + `PumpRateRead2` + `ModelLabel` + `LabLabel` + `SpecLabel`（主视图字段：template:Summary, columns:ConfigColumns|PerfusionColumns|SamplingColumns|AutoControlColumns|FeedingColumns|PumpSpeedColumns）
- 枚举冻结：TemplateKind=CONFIG/PERFUSION/SAMPLING/AUTO_CONTROL/FEEDING/PUMP_SPEED；TimeField=CREATED/UPDATED；ReactorType=INTEGRATED_REACTOR/BENCH_REACTOR；ModelKind=INTEGRATED_MODEL/BENCH_CONTROLLER_MODEL；LabTypeScope=PILOT/SMALL/COMMON；StrategyType=TWO_STAGE/THREE_STAGE；ModelSourceState=AVAILABLE/DELETED/UNKNOWN；LabSourceState=AVAILABLE/DISABLED/DELETED/UNKNOWN；DetectionMode=AUTO/MANUAL
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, INPUT_INVALID
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §10.1/§10.2｜任务包 TP-M04-01

## M04-012｜POST /system/process/templates/candidates｜P02
- 权限：process:{parentKind}:add|edit + process:{SAMPLING|PUMP_SPEED}:query（候选查询不要求来源edit或来源全库list）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#pageBindingCandidates` → `com.futurefab.system.service.IProcessTemplateApplicationService#pageBindingCandidates`
- Request `TemplateCandidatePageQuery`：parentKind:ParentCandidateKind*, parentTemplateId:String, slotKey:String*, criteria:CandidateCriteria*, keyword:String, pageNum:Integer, pageSize:Integer
- Response：`TemplateCandidateView` + `CandidateCriteria`（主视图字段：templateId:String, versionId:String, objectVersion:String, templateKind:CandidateSourceKind, templateName:String, contentSchemaVersion:Long, applicability:Applicability, laboratory:LabLabel, strategyType:StrategyType）
- 枚举冻结：ParentCandidateKind=PERFUSION/AUTO_CONTROL/FEEDING；CandidateSourceKind=SAMPLING/PUMP_SPEED；ReactorType=INTEGRATED_REACTOR/BENCH_REACTOR；StrategyType=TWO_STAGE/THREE_STAGE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, BINDING_INVALID, APPLICABILITY_CONFLICT
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §10.2（只读POST无写Header，§9.2）｜任务包 TP-M04-01

## M04-013｜GET /system/process/templates/model-options｜P02
- 权限：process:{kindCode}:add|edit（E对应add/edit；templateKind限CONFIG/PERFUSION/AUTO_CONTROL/FEEDING）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#pageModelOptions` → `com.futurefab.system.service.IProcessTemplateApplicationService#pageModelOptions`
- Request `TemplateModelOptionQuery`：templateKind:ModelOptionKind*, templateId:String, reactorType:ReactorType*, keyword:String, pageNum:Integer, pageSize:Integer
- Response：`TemplateModelOptionView`（主视图字段：modelKind:ModelKind, modelId:String, displayName:String, specText:String, factStatus:FactStatus, issues:List<Issue>）
- 枚举冻结：ModelOptionKind=CONFIG/PERFUSION/AUTO_CONTROL/FEEDING；ReactorType=INTEGRATED_REACTOR/BENCH_REACTOR；ModelKind=INTEGRATED_MODEL/BENCH_CONTROLLER_MODEL；FactStatus=COMPLETE/INCOMPLETE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, RESOURCE_MAPPING_UNRESOLVED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:resolveEngineering ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §10.4｜任务包 TP-M04-01

## M04-014｜POST /system/process/templates/model-facts｜P02
- 权限：process:{kindCode}:add|edit（E对应）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#resolveModelFacts` → `com.futurefab.system.service.IProcessTemplateApplicationService#resolveModelFacts`
- Request `TemplateModelFactsQuery`：templateKind:ModelOptionKind*, templateId:String, modelRefs:List<ModelRef>*
- Response：`TemplateModelFactsView` + `ModelFact` + `Compatibility`（主视图字段：observedAt:OffsetDateTime, observedManagementRevision:String, models:List<ModelFact>, compatibility:Compatibility）
- 枚举冻结：ModelOptionKind=CONFIG/PERFUSION/AUTO_CONTROL/FEEDING；FactStatus=COMPLETE/INCOMPLETE；CompatibilityResult=COMPATIBLE/INCOMPATIBLE/UNKNOWN；ModelKind=INTEGRATED_MODEL/BENCH_CONTROLLER_MODEL
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, RESOURCE_FACTS_UNAVAILABLE, RESOURCE_MAPPING_UNRESOLVED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:resolveEngineering ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §10.3/§10.4｜任务包 TP-M04-01

## M04-015｜POST /system/process/templates/feeding-resource-facts｜P02
- 权限：process:{kindCode}:add|edit（kind必须FEEDING）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#resolveFeedingResourceFacts` → `com.futurefab.system.service.IProcessTemplateApplicationService#resolveFeedingResourceFacts`
- Request `FeedingResourceFactsQuery`：templateKind:String*, templateId:String, modelRefs:List<ModelRef>*, labIds:List<String>*, pumps:List<PumpResourceRequest>*
- Response：`FeedingResourceFactsView` + `PumpResourceRequest` + `PumpFacts`（主视图字段：observedAt:OffsetDateTime, observedManagementRevision:String, labScope:List<String>, pumps:List<PumpFacts>, issues:List<Issue>）
- 枚举冻结：FactStatus=COMPLETE/INCOMPLETE；ConsumableKind=LIQUID_BAG/BUCKET；ModelKind=INTEGRATED_MODEL/BENCH_CONTROLLER_MODEL
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, LAB_AUTHORIZATION_UNAVAILABLE, RESOURCE_FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §10.3/§10.4（资源接口只读、无写Header、无回执）｜任务包 TP-M04-01

## M04-016｜POST /system/process/templates/sampling-resource-facts｜P02
- 权限：process:{kindCode}:add|edit（kind为SAMPLING/PERFUSION/AUTO_CONTROL）
- Controller→Service：`com.futurefab.system.controller.ProcessTemplateController#resolveSamplingResourceFacts` → `com.futurefab.system.service.IProcessTemplateApplicationService#resolveSamplingResourceFacts`
- Request `SamplingResourceFactsQuery`：templateKind:SamplingFactsKind*, templateId:String, applicableLabId:String*
- Response：`SamplingResourceFactsView` + `DetectorFact` + `ItemFact`（主视图字段：observedAt:OffsetDateTime, observedManagementRevision:String, laboratory:LabLabel, labType:LabCategory, detectors:List<DetectorFact>, issues:List<Issue>）
- 枚举冻结：SamplingFactsKind=SAMPLING/PERFUSION/AUTO_CONTROL；LabCategory=PILOT/SMALL；DetectClass=BGA/VICELL/OSMO/CEDEX；DetectorStatus=AVAILABLE/DISABLED/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, LAB_AUTHORIZATION_UNAVAILABLE, RESOURCE_FACTS_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M02:资源字典读取端口
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §10.4｜任务包 TP-M04-01

## M04-017｜GET /system/process/workflow/list｜P02〔待再生：spec/32 仍带 blocked 标记；裁决核验认定现行权威已逐项冻结（证据见《17个BLOCKED接口裁决表》本条行），再生链执行后此标记消除〕
- 权限：process:workflow:list
- Controller→Service：`com.futurefab.system.controller.WorkflowController#list` → `IWorkflowService#selectWorkflowNodeList`
- Request `WorkflowNodeQuery`：nodeName:String, labTypeList:List<String>, pageNum:Integer, pageSize:Integer
- Response：`WfNodeRow`（主视图字段：nodeId:String, nodeName:String, nodeCode:String, iconPath:String, labType:String, status:String, description:String, sortOrder:Long, updateBy:String, updateTime:OffsetDateTime, allowedActions:List<WfNodeAction>）
- 枚举冻结：WfNodeAction=VIEW/EDIT/ENABLE/DISABLE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, INPUT_INVALID
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §11.2

## M04-018｜GET /system/process/workflow/{nodeId}｜P02〔待再生：spec/32 仍带 blocked 标记；裁决核验认定现行权威已逐项冻结（证据见《17个BLOCKED接口裁决表》本条行），再生链执行后此标记消除〕
- 权限：process:workflow:query
- Controller→Service：`com.futurefab.system.controller.WorkflowController#getInfo` → `IWorkflowService#getWorkflowNodeDetail`
- Request `WorkflowNodeDetailQuery`：nodeId:String*
- Response：`WfDetail` + `WfSubflow` + `WfStep`（主视图字段：subflows:List<WfSubflow>, imageOptions:List<String>）
- 枚举冻结：WfNodeAction=VIEW/EDIT/ENABLE/DISABLE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, CONFIGURATION_INCONSISTENT
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §11.2

## M04-019｜PUT /system/process/workflow/{nodeId}｜P02〔待再生：spec/32 仍带 blocked 标记；裁决核验认定现行权威已逐项冻结（证据见《17个BLOCKED接口裁决表》本条行），再生链执行后此标记消除〕
- 权限：process:workflow:edit
- Controller→Service：`com.futurefab.system.controller.WorkflowController#update` → `IWorkflowService#updateWorkflowNode`
- Request `WfInput`：nodeName:String*, description:String, iconPath:String*, subflows:List<WfSubflowInput>*, requestId:String*, managementRevision:String*
- Response：`WfSubflowInput` + `WfStepInput` + `WfWrite`（主视图字段：subflowId:String*, subflowName:String*, steps:List<WfStepInput>*）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, READ_ONLY_FIELD, NO_CHANGE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=workflow_node
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §11.2/§11.4

## M04-020｜PUT /system/process/workflow/{nodeId}/status｜P02〔待再生：spec/32 仍带 blocked 标记；裁决核验认定现行权威已逐项冻结（证据见《17个BLOCKED接口裁决表》本条行），再生链执行后此标记消除〕
- 权限：process:workflow:edit（不套用模板changeStatus功能码）
- Controller→Service：`com.futurefab.system.controller.WorkflowController#updateStatus` → `IWorkflowService#updateWorkflowStatus`
- Request `WorkflowStatusUpdateRequest`：status:String*, requestId:String*, managementRevision:String*
- Response：`WfWrite`（主视图字段：applied:Boolean, id:String, managementRevision:String）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, NO_CHANGE, REFERENCE_EXISTS, REQUEST_CONFLICT, MANAGEMENT_CONFLICT
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=workflow_node
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §11.2/§11.4

## M04-021｜GET /system/lab/lab/{labId}/workflows｜P02〔待再生：spec/32 仍带 blocked 标记；裁决核验认定现行权威已逐项冻结（证据见《17个BLOCKED接口裁决表》本条行），再生链执行后此标记消除〕
- 权限：lab:lab:query（且实验室可见）
- Controller→Service：`com.futurefab.system.controller.LabWorkflowController#getWorkflows` → `ILabWorkflowService#getLabWorkflowConfig`
- Request `LabWorkflowConfigQuery`：labId:String*
- Response：`LabWfConfig` + `LabWfOption` + `LabWfSelected`（主视图字段：labId:String, labType:String, options:List<LabWfOption>, selectedNodeIds:List<String>, selectedNodes:List<LabWfSelected>, allowedActions:List<LabWfAction>, issues:List<Issue>）
- 枚举冻结：LabWfAction=VIEW/EDIT/CLEAR；LabWfSelectedState=ENABLED/DISABLED/DELETED/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, CONFIGURATION_INCONSISTENT
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §11.2

## M04-022｜PUT /system/lab/lab/{labId}/workflows｜P02〔待再生：spec/32 仍带 blocked 标记；裁决核验认定现行权威已逐项冻结（证据见《17个BLOCKED接口裁决表》本条行），再生链执行后此标记消除〕
- 权限：lab:lab:edit（且管理等级2；Q12模板等级1不适用此处）
- Controller→Service：`com.futurefab.system.controller.LabWorkflowController#saveWorkflows` → `com.futurefab.system.service.ILabWorkflowService#saveLabWorkflows`
- Request `LabWorkflowSaveCommand`：nodeIds:List<String>*, requestId:String*, managementRevision:String*
- Response：`WorkflowWriteResult`（主视图字段：applied:Boolean, id:String, managementRevision:String, selectedNodeIds:List<String>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, READ_ONLY_FIELD, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, STATE_CONFLICT, REFERENCE_EXISTS, WORKFLOW_REFERENCE_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_workflow_node
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M03:WorkflowReference.checkRemoval
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §11.2/§11.3/§11.4

## M04-023｜POST /system/lab/lab/{labId}/workflows/clear｜P02〔待再生：spec/32 仍带 blocked 标记；裁决核验认定现行权威已逐项冻结（证据见《17个BLOCKED接口裁决表》本条行），再生链执行后此标记消除〕
- 权限：lab:lab:edit（且管理等级2）
- Controller→Service：`com.futurefab.system.controller.LabWorkflowController#clearWorkflows` → `com.futurefab.system.service.ILabWorkflowService#clearLabWorkflows`
- Request `LabWorkflowClearCommand`：requestId:String*, managementRevision:String*
- Response：`WorkflowWriteResult`（主视图字段：applied:Boolean, id:String, managementRevision:String, selectedNodeIds:List<String>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHORIZED, FORBIDDEN, NOT_FOUND, INPUT_INVALID, NO_CHANGE, REQUEST_CONFLICT, MANAGEMENT_CONFLICT, REFERENCE_EXISTS, WORKFLOW_REFERENCE_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=lab_workflow_node
- 跨模块 Port：M04→M01:ActorContext ; M04→M01:Permission ; M04→M01:managementRevision ; M04→M03:WorkflowReference.checkRemoval
- 来源：docs/详细设计/04-工艺与方案管理/详细设计.md §11.2/§11.3/§11.4；物理接口与骨架字段设计.md §4

# M05（38 条）

## M05-001｜POST /detect/result-corrections/preview｜M05-Q09
- 权限：detect:correction:submit＋detect:sign:sign＋当前结果操作范围（排除仅历史分享）
- Controller→Service：`com.futurefab.system.controller.DetResultCorrectionController#previewCorrection` → `com.futurefab.system.service.application.m05.DetResultCorrectionApplicationService#previewCorrection`
- Request `ResultCorrectionPreviewCommand`：resultId:String*, expectedObjectVersion:String*, changes:List<CorrectionChange>*, evidenceRefs:List<EvidenceRef>*, reason:String*
- Response：`ResultCorrectionPreviewResult` + `CorrectionChange` + `EvidenceRef` + `CorrectionImpactSummary`（主视图字段：resultId:String, baseObjectVersion:String, baseCorrectionId:String, candidateHash:String, changedPaths:List<String>, impactSummary:CorrectionImpactSummary, confirmationToken:String, expiresAt:OffsetDateTime）
- 枚举冻结：CorrectionChangeField=VALUE/UNIT/ITEM_MAPPING/VALIDITY/NOTE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, CORRECTION_EVIDENCE_INSUFFICIENT, CORRECTION_ALREADY_PENDING, FORBIDDEN_OR_NOT_FOUND, RESULT_PROJECTION_UNAVAILABLE, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：受控更正逐接口契约.md §1—§2｜任务包 TP-M05-06

## M05-002｜POST /detect/result-corrections/{id}/decision-preview｜M05-Q09
- 权限：detect:correction:review＋detect:sign:audit＋当前审核资格且与提交者不同
- Controller→Service：`com.futurefab.system.controller.DetResultCorrectionController#decisionPreview` → `com.futurefab.system.service.application.m05.DetResultCorrectionApplicationService#decisionPreview`
- Request `ResultCorrectionDecisionPreviewCommand`：id:String*, expectedVersion:String*, candidateHash:String*, decision:CorrectionDecision*, reason:String*
- Response：`ResultCorrectionDecisionPreviewResult`（主视图字段：correctionId:String, decision:CorrectionDecision, candidateHash:String, changedPaths:List<String>, evidenceSummary:List<EvidenceRef>, confirmationToken:String, expiresAt:OffsetDateTime）
- 枚举冻结：CorrectionDecision=APPROVE/REJECT
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, RESULT_STATE_CONFLICT, RESULT_VERSION_CONFLICT, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：受控更正逐接口契约.md §4｜任务包 TP-M05-06

## M05-003｜POST /detect/result-corrections/{id}/decisions｜M05-Q09
- 权限：detect:correction:review＋detect:sign:audit＋当前审核资格且与提交者不同
- Controller→Service：`com.futurefab.system.controller.DetResultCorrectionController#decide` → `com.futurefab.system.service.application.m05.DetResultCorrectionApplicationService#decide`
- Request `ResultCorrectionDecisionCommand`：id:String*, confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`ResultCorrectionMutationResult`（主视图字段：correctionId:String, state:CorrectionState, version:String, resultId:String, resultObjectVersion:String, resultRevisionId:String）
- 枚举冻结：CorrectionState=SUBMITTED/APPROVED/REJECTED/WITHDRAWN/STALE
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：CONFIRMATION_EXPIRED_OR_CHANGED, CORRECTION_BASE_CHANGED, REQUEST_CONFLICT, RESULT_STATE_CONFLICT, RESULT_VERSION_CONFLICT, MANAGEMENT_REVISION_CONFLICT, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result_correction
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：受控更正逐接口契约.md §1、§5｜任务包 TP-M05-06

## M05-004｜POST /detect/result-corrections/{id}/withdraw｜M05-Q09
- 权限：仅SUBMITTED申请人＋当前结果操作范围（设计未列独立功能码）
- Controller→Service：`com.futurefab.system.controller.DetResultCorrectionController#withdraw` → `com.futurefab.system.service.application.m05.DetResultCorrectionApplicationService#withdraw`
- Request `ResultCorrectionWithdrawCommand`：id:String*, expectedVersion:String*, reason:String*, requestId:String*, managementRevision:String*
- Response：`ResultCorrectionMutationResult`（主视图字段：correctionId:String, state:CorrectionState, version:String）
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：INVALID_REQUEST, REQUEST_CONFLICT, RESULT_STATE_CONFLICT, MANAGEMENT_REVISION_CONFLICT, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result_correction
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：受控更正逐接口契约.md §6｜任务包 TP-M05-06

## M05-005｜GET /detect/result-corrections/{id}｜M05-Q09
- 权限：结果读取用途权限（详情沿结果详情/签批详情用途）
- Controller→Service：`com.futurefab.system.controller.DetResultCorrectionController#getCorrection` → `com.futurefab.system.service.application.m05.DetResultCorrectionApplicationService#getCorrection`
- Request `ResultCorrectionDetailQuery`：id:String*
- Response：`ResultCorrectionDetailView` + `CorrectionRow` + `CorrectionSnapshot` + `CorrectionDiff` + `CorrectionEvidenceDetail` + `CorrectionSignatures` + `CorrectionSignatureActor`（主视图字段：correction:CorrectionRow, baseSnapshot:CorrectionSnapshot, candidateSnapshot:CorrectionSnapshot, diffs:List<CorrectionDiff>, evidence:List<CorrectionEvidenceDetail>, signatures:CorrectionSignatures）
- 枚举冻结：CorrectionState=SUBMITTED/APPROVED/REJECTED/WITHDRAWN/STALE；CorrectionDecision=APPROVE/REJECT
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：FORBIDDEN_OR_NOT_FOUND, RESULT_PROJECTION_UNAVAILABLE, ARCHIVE_UNAVAILABLE, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：受控更正逐接口契约.md §1、§7｜任务包 TP-M05-06

## M05-015｜GET /detect/record/page｜M05-REQ04
- 权限：detect:record:query
- Controller→Service：`com.futurefab.system.controller.DetRecordController#recordPage` → `com.futurefab.system.service.IDetRecordService#selectRecordPage`
- Request `DetApprovalRecordQuery`：labId:String, sentUserKeyword:String, projectId:String, batchId:String, cultureId:String, sampleNo:String, projectTag:String, status:String, detectClass:String, detectorId:String, nonCultureOnly:Boolean, startDate:String, endDate:String, pageNum:Integer, pageSize:Integer
- Response：`DetApprovalRecordVo` + `SentUserSnapshot`（主视图字段：resultId:String, sampleId:String, objectVersion:String, sampleObjectVersion:String, sampleNo:String, labId:String, projectId:String, batchId:String, cultureId:String, projectCode:String, projectTags:List<String>, batchCode:String, cultureCode:String, detectClass:String, detectType:String, detectorId:String, deviceNo:String, sentUser:SentUserSnapshot, testingStartTime:OffsetDateTime, testingEndTime…全集见 spec 文件）
- 枚举冻结：ResultStatus=idle/stored/pending/testing/tested/uploaded/signed/reviewed/exception/timeout/cancelled/voided
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：检测记录与结果操作设计.md §1（UI02过滤与ResultRow定义）｜任务包 TP-M05-01

## M05-016｜GET /detect/record/projects｜M05-REQ04
- 权限：detect:record:query
- Controller→Service：`com.futurefab.system.controller.DetRecordController#projects` → `com.futurefab.system.service.IDetRecordService#selectProjectOptions`
- Request `RecordProjectOptionQuery`：labId:String, keyword:String
- Response：`DetSignConsoleOptionVo`（主视图字段：id:String, label:String, associatedAt:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位038；检测记录与结果操作设计.md §5｜任务包 TP-M05-01

## M05-019｜GET /detect/record/{resultId}/detail｜M05-REQ04
- 权限：detect:record:query（详情重新鉴权）
- Controller→Service：`com.futurefab.system.controller.DetRecordController#recordDetail` → `com.futurefab.system.service.IDetRecordService#selectRecordDetail`
- Request `RecordDetailQuery`：resultId:String*
- Response：`DetApprovalRecordDetailVo` + `ResultItemDetail`（主视图字段：result:ResultRowView, secondId:String, dayNumber:Long, expectedItems:List<String>, items:List<ResultItemDetail>, logs:List<DetApprovalLogVo>, allowedActions:List<String>）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：检测记录与结果操作设计.md §1（ResultDetail/items事实）｜任务包 TP-M05-01

## M05-020｜GET /detect/workbench/result/{resultId}/sample-no-history｜M05-REQ04
- 权限：detect:workbench:query
- Controller→Service：`com.futurefab.system.controller.DetWorkbenchController#sampleNoHistory` → `com.futurefab.system.service.IDetWorkbenchService#selectSampleIdHistory`
- Request `SampleNoHistoryQuery`：resultId:String*, pageNum:Integer, pageSize:Integer
- Response：`DetSampleIdHistory`（主视图字段：oldSampleNo:String, newSampleNo:String, reason:String, operatorUserId:String, operatorDisplayName:String, occurredAt:OffsetDateTime）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位040；检测记录与结果操作设计.md §5｜任务包 TP-M05-01

## M05-021｜PUT /detect/workbench/result/{resultId}/sample-no｜M05-REQ04
- 权限：detect:workbench:edit
- Controller→Service：`com.futurefab.system.controller.DetWorkbenchController#updateSampleNo` → `com.futurefab.system.service.IDetWorkbenchService#updateWorkbenchSampleNo`
- Request `DetWorkbenchActionRequest`：resultId:String*, sampleNo:String*, reason:String*, allowNonCulture:Boolean, expectedObjectVersion:String*, expectedSampleVersion:String*, requestId:String*, managementRevision:String*
- Response：`WorkbenchResultMutationResult`（主视图字段：requestId:String, resultId:String, beforeStatus:String, afterStatus:String, objectVersion:String, actionRecordId:String, issues:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INVALID_REQUEST, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, NON_CULTURE_CONFIRM_REQUIRED, FORBIDDEN_OR_NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_REVISION_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_sample
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位041；检测记录与结果操作设计.md §1、§3、§5｜任务包 TP-M05-01

## M05-022｜PUT /detect/workbench/result/{resultId}/upload｜M05-REQ04
- 权限：detect:workbench:edit
- Controller→Service：`com.futurefab.system.controller.DetWorkbenchController#upload` → `com.futurefab.system.service.IDetWorkbenchService#uploadWorkbenchResult`
- Request `DetWorkbenchActionRequest`：resultId:String*, expectedObjectVersion:String*, reason:String, requestId:String*, managementRevision:String*
- Response：`WorkbenchResultMutationResult`（主视图字段：requestId:String, resultId:String, beforeStatus:String, afterStatus:String, objectVersion:String, actionRecordId:String, issues:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INVALID_REQUEST, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, FORBIDDEN_OR_NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_REVISION_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位042；检测记录与结果操作设计.md §2、§5｜任务包 TP-M05-01

## M05-023｜PUT /detect/workbench/result/{resultId}/withdraw｜M05-REQ04
- 权限：detect:workbench:edit（送检本人）
- Controller→Service：`com.futurefab.system.controller.DetWorkbenchController#withdraw` → `com.futurefab.system.service.IDetWorkbenchService#withdrawWorkbenchResult`
- Request `DetWorkbenchActionRequest`：resultId:String*, expectedObjectVersion:String*, reason:String*, requestId:String*, managementRevision:String*
- Response：`WorkbenchResultMutationResult`（主视图字段：requestId:String, resultId:String, beforeStatus:String, afterStatus:String, objectVersion:String, actionRecordId:String, issues:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INVALID_REQUEST, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, ONLY_CURRENT_ACTOR_CAN_REVOKE, FORBIDDEN_OR_NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_REVISION_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位042；检测记录与结果操作设计.md §2—§3｜任务包 TP-M05-01

## M05-025｜PUT /detect/detresult/item/{resultItemId}/void｜M05-REQ04
- 权限：detect:detresult:void
- Controller→Service：`com.futurefab.system.controller.DetResultController#voidResultItem` → `com.futurefab.system.service.IDetResultWorkflowService#voidResultItem`
- Request `DetResultActionRequest`：resultItemId:String*, resultId:String*, expectedObjectVersion:String*, reason:String*, requestId:String*, managementRevision:String*
- Response：`ResultItemMutationResult`（主视图字段：requestId:String, resultId:String, resultItemId:String, objectVersion:String, actionRecordId:String, issues:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INVALID_REQUEST, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, FORBIDDEN_OR_NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_REVISION_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位044；检测记录与结果操作设计.md §2、§5；结果操作报告与版本发布数据库设计.md §2｜任务包 TP-M05-01

## M05-026｜PUT /detect/detresult/item/{resultItemId}/revoke｜M05-REQ04
- 权限：detect:detresult:revoke
- Controller→Service：`com.futurefab.system.controller.DetResultController#revokeVoidResultItem` → `com.futurefab.system.service.IDetResultWorkflowService#revokeVoidResultItem`
- Request `DetResultActionRequest`：resultItemId:String*, resultId:String*, expectedObjectVersion:String*, reason:String*, requestId:String*, managementRevision:String*
- Response：`ResultItemMutationResult`（主视图字段：requestId:String, resultId:String, resultItemId:String, objectVersion:String, actionRecordId:String, issues:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INVALID_REQUEST, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, FORBIDDEN_OR_NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_REVISION_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位044；检测记录与结果操作设计.md §2；结果操作报告与版本发布数据库设计.md §2｜任务包 TP-M05-01

## M05-027｜DELETE /detect/detresult/{resultId}｜M05-REQ04
- 权限：detect:detresult:remove
- Controller→Service：`com.futurefab.system.controller.DetResultController#remove` → `com.futurefab.system.service.IDetResultService#deleteDetResultByResultIds`
- Request `ResultDeleteCommand`：resultId:String*, expectedObjectVersion:String*, confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`ResultDeleteResult`（主视图字段：requestId:String, resultId:String, beforeStatus:String, afterStatus:String, objectVersion:String, actionRecordId:String, issues:List<Issue>）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：INVALID_REQUEST, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, CONFIRMATION_EXPIRED_OR_CHANGED, FORBIDDEN_OR_NOT_FOUND, REQUEST_CONFLICT, MANAGEMENT_REVISION_CONFLICT, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位045；检测记录与结果操作设计.md §3、§5｜任务包 TP-M05-01

## M05-028｜POST /detect/workbench/results/preview-delete｜M05-REQ04
- 权限：detect:detresult:remove（与正式删除相同，并叠加对象读取范围）
- Controller→Service：`com.futurefab.system.controller.DetWorkbenchController#previewResultDelete` → `com.futurefab.system.service.IDetWorkbenchService#previewResultDelete`
- Request `ResultDeletePreviewRequest`：items:List<ResultDeletePreviewItem>*, requestId:String
- Response：`ResultDeletePreviewResult` + `ResultDeletePreviewItem` + `ResultDeleteEligibleItem` + `ResultDeleteIneligibleItem`（主视图字段：managementRevision:String, expiresAt:OffsetDateTime, eligible:List<ResultDeleteEligibleItem>, ineligible:List<ResultDeleteIneligibleItem>, confirmationToken:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, RESULT_VERSION_CONFLICT, CONFIRMATION_EXPIRED_OR_CHANGED, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：接口目录与契约定位.md 定位046；检测记录与结果操作设计.md §5；详细设计.md §11.3（令牌规则）｜任务包 TP-M05-01

## M05-038｜POST /detect/sign-console/preview-action｜M05-REQ05
- 权限：按action映射目标写权限：SIGN/REVOKE_SIGN=detect:sign:sign；REVIEW/REVOKE_REVIEW=detect:sign:audit；VOID/RESTORE_VOID=detect:sign:edit
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#previewAction` → `com.futurefab.system.service.IDetSignConsoleService#previewAction`
- Request `SignActionPreviewRequest`：action:SignActionType*, items:List<SignActionItem>*, reason:String
- Response：`SignActionPreviewResult` + `SignActionItem` + `SignEligibleItem` + `SignIneligibleItem`（主视图字段：action:SignActionType, managementRevision:String, expiresAt:OffsetDateTime, eligible:List<SignEligibleItem>, ineligible:List<SignIneligibleItem>, confirmationToken:String）
- 枚举冻结：SignActionType=SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, RESULT_VERSION_CONFLICT, ACTOR_IDENTITY_UNVERIFIED, USE_CONTROLLED_CORRECTION, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §11.3（PreviewResult形状）；接口目录与契约定位.md 定位050｜任务包 TP-M05-04

## M05-039｜POST /detect/sign-console/sign｜M05-REQ05
- 权限：detect:sign:sign
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#sign` → `com.futurefab.system.service.IDetSignConsoleService#signResults`
- Request `DetSignConsoleActionRequest`：items:List<SignActionItem>*, reason:String, confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`DetSignConsoleActionResultVo` + `SignWriteItem`（主视图字段：requestId:String, action:SignActionType, managementRevision:String, completedAt:OffsetDateTime, items:List<SignWriteItem>）
- 枚举冻结：SignActionType=SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID
- 状态变化/守卫：状态变更校验＋权限（模块时序设计）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, MANAGEMENT_REVISION_CONFLICT, CONFIRMATION_EXPIRED_OR_CHANGED, ACTOR_IDENTITY_UNVERIFIED, USE_CONTROLLED_CORRECTION, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §11.2—§11.4；接口目录与契约定位.md 定位054｜任务包 TP-M05-04

## M05-040｜POST /detect/sign-console/audit｜M05-REQ05
- 权限：detect:sign:audit
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#audit` → `com.futurefab.system.service.IDetSignConsoleService#auditResults`
- Request `DetSignConsoleActionRequest`：items:List<SignActionItem>*, reason:String, confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`DetSignConsoleActionResultVo` + `SignWriteItem`（主视图字段：requestId:String, action:SignActionType, managementRevision:String, completedAt:OffsetDateTime, items:List<SignWriteItem>）
- 枚举冻结：SignActionType=SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID
- 状态变化/守卫：状态变更校验＋权限（模块时序设计）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, MANAGEMENT_REVISION_CONFLICT, CONFIRMATION_EXPIRED_OR_CHANGED, ACTOR_IDENTITY_UNVERIFIED, SIGNER_CANNOT_REVIEW, USE_CONTROLLED_CORRECTION, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §11.2—§11.4；接口目录与契约定位.md 定位055｜任务包 TP-M05-04

## M05-041｜POST /detect/sign-console/revoke-sign｜M05-REQ05
- 权限：detect:sign:sign（当前有效签名人本人）
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#revokeSign` → `com.futurefab.system.service.IDetSignConsoleService#revokeSignResults`
- Request `DetSignConsoleActionRequest`：items:List<SignActionItem>*, reason:String*, confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`DetSignConsoleActionResultVo` + `SignWriteItem`（主视图字段：requestId:String, action:SignActionType, managementRevision:String, completedAt:OffsetDateTime, items:List<SignWriteItem>）
- 枚举冻结：SignActionType=SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID
- 状态变化/守卫：状态变更校验＋权限（模块时序设计）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, MANAGEMENT_REVISION_CONFLICT, CONFIRMATION_EXPIRED_OR_CHANGED, ACTOR_IDENTITY_UNVERIFIED, ONLY_CURRENT_ACTOR_CAN_REVOKE, USE_CONTROLLED_CORRECTION, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §11.2—§11.4；接口目录与契约定位.md 定位056｜任务包 TP-M05-04

## M05-042｜POST /detect/sign-console/revoke-audit｜M05-REQ05
- 权限：detect:sign:audit（当前有效审核人本人）
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#revokeAudit` → `com.futurefab.system.service.IDetSignConsoleService#revokeAuditResults`
- Request `DetSignConsoleActionRequest`：items:List<SignActionItem>*, reason:String*, confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`DetSignConsoleActionResultVo` + `SignWriteItem`（主视图字段：requestId:String, action:SignActionType, managementRevision:String, completedAt:OffsetDateTime, items:List<SignWriteItem>）
- 枚举冻结：SignActionType=SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID
- 状态变化/守卫：状态变更校验＋权限（模块时序设计）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, MANAGEMENT_REVISION_CONFLICT, CONFIRMATION_EXPIRED_OR_CHANGED, ACTOR_IDENTITY_UNVERIFIED, ONLY_CURRENT_ACTOR_CAN_REVOKE, USE_CONTROLLED_CORRECTION, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §11.2—§11.4；接口目录与契约定位.md 定位057｜任务包 TP-M05-04

## M05-044｜POST /detect/sign-console/revoke-void｜M05-REQ05
- 权限：detect:sign:edit
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#revokeVoid` → `com.futurefab.system.service.IDetSignConsoleService#revokeVoidResults`
- Request `DetSignConsoleActionRequest`：items:List<SignActionItem>*, reason:String*, confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`DetSignConsoleActionResultVo` + `SignWriteItem`（主视图字段：requestId:String, action:SignActionType, managementRevision:String, completedAt:OffsetDateTime, items:List<SignWriteItem>）
- 枚举冻结：SignActionType=SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID
- 状态变化/守卫：状态变更校验＋权限（模块时序设计）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, MANAGEMENT_REVISION_CONFLICT, CONFIRMATION_EXPIRED_OR_CHANGED, ACTOR_IDENTITY_UNVERIFIED, USE_CONTROLLED_CORRECTION, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §11.2—§11.4；接口目录与契约定位.md 定位059｜任务包 TP-M05-04

## M05-045｜GET /detect/sign-console/projects｜M05-REQ05
- 权限：detect:sign:query
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#projects` → `com.futurefab.system.service.IDetSignConsoleService#selectProjectOptions`
- Request `SignConsoleProjectOptionQuery`：keyword:String, pageNum:Integer, pageSize:Integer
- Response：`DetSignConsoleOptionVo`（主视图字段：id:String, label:String, associatedAt:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §12.2（M05-SIGN-API08）；接口目录与契约定位.md 定位051｜任务包 TP-M05-04

## M05-046｜GET /detect/sign-console/batches｜M05-REQ05
- 权限：detect:sign:query
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#batches` → `com.futurefab.system.service.IDetSignConsoleService#selectBatchOptions`
- Request `SignConsoleBatchOptionQuery`：projectId:String*, keyword:String, pageNum:Integer, pageSize:Integer
- Response：`DetSignConsoleOptionVo`（主视图字段：id:String, label:String, associatedAt:String）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §12.2（M05-SIGN-API09）；接口目录与契约定位.md 定位052｜任务包 TP-M05-04

## M05-047｜POST /detect/sign-console/query｜M05-REQ05
- 权限：detect:sign:query
- Controller→Service：`com.futurefab.system.controller.DetSignConsoleController#query` → `com.futurefab.system.service.IDetSignConsoleService#querySamples`
- Request `DetSignConsoleQuery`：projectId:String*, batchId:String, startDate:String*, endDate:String*, sampleKeyword:String, projectTag:String, operatorFilter:OperatorFilter, status:SignQueryStatus, pageNum:Integer, pageSize:Integer
- Response：`DetSignConsoleSampleVo` + `ResultCard` + `DisplayRef` + `PersonSnapshot` + `ActionSnapshot` + `ConsoleResultItem` + `OperatorFilter`（主视图字段：groupKey:String, sampleNo:String, labId:String, projectId:String, batchId:String, cultureId:String, cultureCode:String, secondId:String, dayNumber:Long, firstLoadedAt:OffsetDateTime, results:List<ResultCard>）
- 枚举冻结：SignQueryStatus=ALL/UPLOADED/SIGNED/REVIEWED/VOIDED；OperatorFilterMode=SELF_UPLOADER/ANY_PERSON/ALL
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：详细设计.md §12.2—§12.4（API10与Group/ResultCard/ResultItem形状）｜任务包 TP-M05-04

## M05-048｜POST /detect/result-corrections｜M05-Q09
- 权限：detect:correction:submit＋detect:sign:sign＋当前结果操作范围（排除仅历史分享）
- Controller→Service：`com.futurefab.system.controller.DetResultCorrectionController#submitCorrection` → `com.futurefab.system.service.application.m05.DetResultCorrectionApplicationService#submitCorrection`
- Request `ResultCorrectionSubmitCommand`：confirmationToken:String*, requestId:String*, managementRevision:String*
- Response：`ResultCorrectionMutationResult`（主视图字段：correctionId:String, resultId:String, state:CorrectionState, version:String, candidateHash:String）
- 枚举冻结：CorrectionState=SUBMITTED/APPROVED/REJECTED/WITHDRAWN/STALE
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：CONFIRMATION_EXPIRED_OR_CHANGED, REQUEST_CONFLICT, CORRECTION_ALREADY_PENDING, CORRECTION_BASE_CHANGED, RESULT_VERSION_CONFLICT, RESULT_STATE_CONFLICT, MANAGEMENT_REVISION_CONFLICT, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=det_result_correction
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：受控更正逐接口契约.md §3；接口目录与契约定位.md T8补收｜任务包 TP-M05-06

## M05-049｜GET /detect/result-corrections｜M05-Q09
- 权限：结果读取用途权限（当前有权结果的更正历史）
- Controller→Service：`com.futurefab.system.controller.DetResultCorrectionController#listCorrections` → `com.futurefab.system.service.application.m05.DetResultCorrectionApplicationService#listCorrections`
- Request `ResultCorrectionPageQuery`：resultId:String*, state:CorrectionState, pageNum:Integer, pageSize:Integer
- Response：`ResultCorrectionRow`（主视图字段：correctionId:String, resultId:String, baseObjectVersion:String, baseCorrectionId:String, state:CorrectionState, candidateHash:String, reason:String, changedPaths:List<String>, submittedBy:String, submittedDisplayName:String, submittedAt:OffsetDateTime, reviewDecision:CorrectionDecision, reviewedBy:String, reviewedDisplayName:String, reviewedAt:OffsetDateTime, reviewReason:String, resultRevisionId:…全集见 spec 文件）
- 枚举冻结：CorrectionState=SUBMITTED/APPROVED/REJECTED/WITHDRAWN/STALE；CorrectionDecision=APPROVE/REJECT
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_REQUEST, FORBIDDEN_OR_NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M05→M01: ActorContext / Permission / managementRevision
- 来源：受控更正逐接口契约.md §1、§8｜任务包 TP-M05-06

## M05-050｜POST /detect/detresult｜M05-REQ04
- 权限：detect:detresult:add
- Controller→Service：`com.futurefab.system.controller.DetResultController#add` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyResultCreate`
- Request `LegacyResultCreateCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：检测记录与结果操作设计.md §5；物理接口与骨架字段设计.md §1（DISABLE守卫仅返回CLIENT_UPGRADE_REQUIRED，请求体不解析，旧客户端缺版本拒绝而非降级）｜任务包 TP-M05-01

## M05-051｜PUT /detect/detresult｜M05-REQ04
- 权限：detect:detresult:edit
- Controller→Service：`com.futurefab.system.controller.DetResultController#edit` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyResultUpdate`
- Request `LegacyResultUpdateCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：检测记录与结果操作设计.md §5；物理接口与骨架字段设计.md §1｜任务包 TP-M05-01

## M05-052｜POST /detect/detresultitem｜M05-REQ04
- 权限：detect:detresultitem:add
- Controller→Service：`com.futurefab.system.controller.DetResultItemController#add` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyResultItemCreate`
- Request `LegacyResultItemCreateCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：检测记录与结果操作设计.md §5；物理接口与骨架字段设计.md §1｜任务包 TP-M05-01

## M05-053｜PUT /detect/detresultitem｜M05-REQ04
- 权限：detect:detresultitem:edit
- Controller→Service：`com.futurefab.system.controller.DetResultItemController#edit` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyResultItemUpdate`
- Request `LegacyResultItemUpdateCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：检测记录与结果操作设计.md §5；物理接口与骨架字段设计.md §1｜任务包 TP-M05-01

## M05-054｜DELETE /detect/detresultitem/{resultItemIds}｜M05-REQ04
- 权限：detect:detresultitem:remove
- Controller→Service：`com.futurefab.system.controller.DetResultItemController#remove` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyResultItemDelete`
- Request `LegacyResultItemDeleteCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：检测记录与结果操作设计.md §5；物理接口与骨架字段设计.md §1（/{resultItemIds}数组入口停用）｜任务包 TP-M05-01

## M05-055｜PUT /detect/signrecord｜M05-REQ05
- 权限：detect:signrecord:edit
- Controller→Service：`com.futurefab.system.controller.DetResultSignRecordController#edit` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacySignRecordUpdate`
- Request `LegacySignRecordUpdateCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：详细设计.md §11.5；物理接口与骨架字段设计.md §1（签批日志不可覆写原动作内容/快照）｜任务包 TP-M05-04

## M05-056｜DELETE /detect/signrecord/{signIds}｜M05-REQ05
- 权限：detect:signrecord:remove
- Controller→Service：`com.futurefab.system.controller.DetResultSignRecordController#remove` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacySignRecordDelete`
- Request `LegacySignRecordDeleteCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：详细设计.md §11.5；物理接口与骨架字段设计.md §1｜任务包 TP-M05-04

## M05-057｜POST /detect/assignee｜M05-Q01
- 权限：detect:assignee:add
- Controller→Service：`com.futurefab.system.controller.DetApprovalAssigneeController#add` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyAssigneeCreate`
- Request `LegacyAssigneeCreateCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：详细设计.md §1（不恢复09章已删除添加审批人功能；det_approval_assignee遗留只读表）｜任务包 TP-M05-02

## M05-058｜POST /detect/assignee/invite｜M05-Q01
- 权限：detect:assignee:add
- Controller→Service：`com.futurefab.system.controller.DetApprovalAssigneeController#invite` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyAssigneeInvite`
- Request `LegacyAssigneeInviteCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：详细设计.md §1；物理接口与骨架字段设计.md §1｜任务包 TP-M05-02

## M05-059｜PUT /detect/assignee｜M05-Q01
- 权限：detect:assignee:edit
- Controller→Service：`com.futurefab.system.controller.DetApprovalAssigneeController#edit` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyAssigneeUpdate`
- Request `LegacyAssigneeUpdateCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：详细设计.md §1；物理接口与骨架字段设计.md §1｜任务包 TP-M05-02

## M05-060｜DELETE /detect/assignee/{assigneeIds}｜M05-Q01
- 权限：detect:assignee:remove
- Controller→Service：`com.futurefab.system.controller.DetApprovalAssigneeController#remove` → `com.futurefab.system.service.application.m05.LegacyDetectionEndpointGuard#rejectLegacyAssigneeDelete`
- Request `LegacyAssigneeDeleteCommand`：（无字段/NoBody）
- Response：`DisabledEndpointResult`（主视图字段：）
- 状态变化/守卫：N/A（DISABLE 规则直接返回停用错误）
- 错误码：—
- 幂等：N/A（停用入口，返回契约停用错误）｜事务：无事务（停用入口直接返回）
- 来源：详细设计.md §1；物理接口与骨架字段设计.md §1｜任务包 TP-M05-02

# M06（15 条）

## M06-001｜GET /process/approval/deliveries/{id}/reconciliation-preview｜com.futurefab.system.service.application.m06
- 权限：process:approval:reconcile:submit＋原审批对象查询范围
- Controller→Service：`com.futurefab.system.controller.ApprovalReconciliationController#reconciliationPreview` → `com.futurefab.system.service.application.m06.ApprovalReconciliationQueryApplicationService#previewReconciliation`
- Request `ReconciliationPreviewQuery`：deliveryId:String*
- Response：`ReconciliationPreviewView` + `IssueView`（主视图字段：deliveryId:String*, approvalId:String*, decisionVersion:String*, decision:Decision*, candidateId:String*, candidateHash:String*, deliveryState:String*, applyState:ApplyState*, unknownSince:OffsetDateTime, retryBudget:Object, baseDeliveryVersion:String*, evidenceRequirements:List<String>, maskedEvidence:Object, allowedResolutions:List<String>, issues:List<IssueView>）
- 枚举冻结：Decision=APPLY/DISCARD；ApplyState=NONE/NOT_APPLICABLE/PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：NOT_FOUND, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#对账接口权限与完整投影｜任务包 TP-M06-01

## M06-002｜POST /process/approval/deliveries/{id}/reconciliations｜com.futurefab.system.service.application.m06
- 权限：process:approval:reconcile:submit
- Controller→Service：`com.futurefab.system.controller.ApprovalReconciliationController#createReconciliation` → `com.futurefab.system.service.application.m06.ApprovalReconciliationCommandApplicationService#createReconciliation`
- Request `ReconciliationCreateCommand`：requestId:String*, baseDeliveryVersion:String*, resolution:ReconciliationResolution*, reason:String*, evidenceJson:String*, evidenceHash:String*, managementRevision:String*
- Response：`ReconciliationMutationResult`（主视图字段：reconciliationId:String*, deliveryId:String*, state:String*, objectVersion:String*, requestId:String*, duplicate:Boolean*, submittedAt:OffsetDateTime*）
- 枚举冻结：ReconciliationResolution=VERIFY_APPLIED/SEAL_NOT_APPLIED
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：INVALID_ARGUMENT, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=apr_reconciliation
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission ; M06→M01: managementRevision
- 来源：docs/详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#对账接口权限与完整投影｜任务包 TP-M06-01

## M06-003｜POST /process/approval/reconciliations/{id}/review｜com.futurefab.system.service.application.m06
- 权限：process:approval:reconcile:review
- Controller→Service：`com.futurefab.system.controller.ApprovalReconciliationController#reviewReconciliation` → `com.futurefab.system.service.application.m06.ApprovalReconciliationCommandApplicationService#reviewReconciliation`
- Request `ReconciliationReviewCommand`：requestId:String*, expectedVersion:String*, action:ReconciliationReviewAction*, reason:String*, evidenceHash:String, managementRevision:String*
- Response：`ReconciliationMutationResult`（主视图字段：reconciliationId:String*, deliveryId:String*, state:String*, objectVersion:String*, requestId:String*, duplicate:Boolean*, reviewedAt:OffsetDateTime*）
- 枚举冻结：ReconciliationReviewAction=APPROVE/REJECT
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：INVALID_ARGUMENT, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, FORBIDDEN, SELF_APPROVAL, AUTHORIZATION_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=apr_reconciliation
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission ; M06→M01: managementRevision
- 来源：docs/详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#对账接口权限与完整投影｜任务包 TP-M06-01

## M06-004｜POST /process/approval/reconciliations/{id}/withdraw｜com.futurefab.system.service.application.m06
- 权限：process:approval:reconcile:submit＋仅原提交人
- Controller→Service：`com.futurefab.system.controller.ApprovalReconciliationController#withdrawReconciliation` → `com.futurefab.system.service.application.m06.ApprovalReconciliationCommandApplicationService#withdrawReconciliation`
- Request `ReconciliationWithdrawCommand`：requestId:String*, expectedVersion:String*, reason:String*, managementRevision:String*
- Response：`ReconciliationMutationResult`（主视图字段：reconciliationId:String*, deliveryId:String*, state:String*, objectVersion:String*, requestId:String*, duplicate:Boolean*, withdrawnAt:OffsetDateTime*）
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：INVALID_ARGUMENT, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, FORBIDDEN
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=apr_reconciliation
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission ; M06→M01: managementRevision
- 来源：docs/详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#对账接口权限与完整投影｜任务包 TP-M06-01

## M06-005｜GET /process/approval/reconciliations/{id}｜com.futurefab.system.service.application.m06
- 权限：process:approval:query＋原审批对象查询范围
- Controller→Service：`com.futurefab.system.controller.ApprovalReconciliationController#getReconciliation` → `com.futurefab.system.service.application.m06.ApprovalReconciliationQueryApplicationService#getReconciliation`
- Request `ReconciliationDetailQuery`：reconciliationId:String*
- Response：`ReconciliationDetailView` + `PersonView` + `IssueView`（主视图字段：reconciliationId:String*, deliveryId:String*, approvalId:String*, resolution:ReconciliationResolution*, state:String*, objectVersion:String*, submitter:PersonView*, reviewer:PersonView, reason:String, evidenceHash:String, ownerResult:Object, createdAt:OffsetDateTime*, reviewedAt:OffsetDateTime, resolvedAt:OffsetDateTime, allowedActions:List<String>, issues:List<IssueView>）
- 枚举冻结：ReconciliationResolution=VERIFY_APPLIED/SEAL_NOT_APPLIED；PersonKind=USER/SYSTEM
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：NOT_FOUND, FORBIDDEN
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#对账接口权限与完整投影｜任务包 TP-M06-01

## M06-006｜POST /process/approval/policies/{labId}/activation｜com.futurefab.system.service.application.m06
- 权限：lab:approval:edit
- Controller→Service：`com.futurefab.system.controller.ApprovalPolicyController#activatePolicy` → `com.futurefab.system.service.application.m06.ApprovalPolicyCommandApplicationService#activatePolicy`
- Request `PolicyActivationCommand`：labId:String*, requestId:String*, expectedVersion:String*, action:PolicyActivationAction*, reason:String*, evidence:String*, managementRevision:String*
- Response：`PolicyActivationResult`（主视图字段：labId:String*, policyId:String*, currentRevisionId:String*, state:ActivationState*, readiness:PolicyReadiness*, objectVersion:String*, managementRevision:String*, requestId:String*, duplicate:Boolean*）
- 枚举冻结：PolicyActivationAction=ENABLE/PAUSE；ActivationState=DISABLED/ENABLED/PAUSED；PolicyReadiness=UNVERIFIED/READY
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：INVALID_ARGUMENT, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=apr_lab_policy
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission ; M06→M01: managementRevision
- 来源：docs/详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#对账接口权限与完整投影｜任务包 TP-M06-03

## M06-007｜GET /process/approval/scenes｜com.futurefab.system.service.application.m06
- 权限：lab:approval:query 或 process:approval:list（按实际入口，设计原文）
- Controller→Service：`com.futurefab.system.controller.ApprovalPolicyController#listScenes` → `com.futurefab.system.service.application.m06.ApprovalPolicyQueryApplicationService#listScenes`
- Request `ApprovalSceneQuery`：labId:String*, purpose:ApprovalScenePurpose*
- Response：`ApprovalSceneView`（主视图字段：sceneCode:String*, sourceKind:String*, moduleLevel1:String*, moduleLevel2:String*, operation:String*, ownerModule:OwnerModule*, scopeState:ScopeState*, gateReason:String, sourceReference:String*, sortOrder:Integer*）
- 枚举冻结：ApprovalScenePurpose=POLICY/FILTER；ScopeState=SUPPORTED/OWNER_GATED/EXCLUDED；OwnerModule=M03/M07/M09
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_ARGUMENT, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§1-2｜任务包 TP-M06-03

## M06-008｜GET /lab/lab/{labId}/approval-policy｜com.futurefab.system.service.application.m06
- 权限：lab:approval:query
- Controller→Service：`com.futurefab.system.controller.LabApprovalPolicyController#getApprovalPolicy` → `com.futurefab.system.service.application.m06.ApprovalPolicyQueryApplicationService#getApprovalPolicy`
- Request `ApprovalPolicyDetailQuery`：labId:String*
- Response：`ApprovalPolicyView` + `PolicyEntry` + `ResolutionRules` + `SourceEvidence`（主视图字段：policyId:String, labId:String*, objectVersion:String*, currentRevisionId:String, readiness:PolicyReadiness*, entries:List<PolicyEntry>*, resolutionRules:ResolutionRules*, sourceEvidence:SourceEvidence, allowedActions:List<String>*）
- 枚举冻结：PolicyReadiness=UNVERIFIED/READY；ReviewMode=DIRECT/DIRECT_REASON/BATCH/PROJECT；ApproveMode=NONE/BATCH/PROJECT
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：NOT_FOUND, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§1-2｜任务包 TP-M06-03

## M06-009｜PUT /lab/lab/{labId}/approval-policy｜com.futurefab.system.service.application.m06
- 权限：lab:approval:edit（+实验室MANAGE）
- Controller→Service：`com.futurefab.system.controller.LabApprovalPolicyController#saveApprovalPolicy` → `com.futurefab.system.service.application.m06.ApprovalPolicyCommandApplicationService#saveApprovalPolicy`
- Request `ApprovalPolicySaveCommand`：labId:String*, expectedObjectVersion:String*, entries:List<PolicyEntry>*, requestId:String*, managementRevision:String*
- Response：`ApprovalPolicySaveResult` + `PolicyEntry`（主视图字段：policyId:String*, currentRevisionId:String*, objectVersion:String*, readiness:PolicyReadiness*）
- 枚举冻结：PolicyReadiness=UNVERIFIED/READY；ReviewMode=DIRECT/DIRECT_REASON/BATCH/PROJECT；ApproveMode=NONE/BATCH/PROJECT
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：INVALID_ARGUMENT, NOT_FOUND, VERSION_CONFLICT, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=apr_lab_policy
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission ; M06→M01: managementRevision
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§2(API03)｜任务包 TP-M06-03

## M06-010｜GET /process/approval/requests｜com.futurefab.system.service.application.m06
- 权限：process:approval:list
- Controller→Service：`com.futurefab.system.controller.ProcessApprovalController#pageApprovalRequests` → `com.futurefab.system.service.application.m06.ProcessApprovalQueryApplicationService#pageApprovalRequests`
- Request `ApprovalRequestQuery`：labId:String*, cultureKeyword:String, personKeyword:String, moduleLevel1:String, moduleLevel2:String, state:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`ApprovalRow` + `PersonView` + `IssueView`（主视图字段：approvalId:String*, objectVersion:String*, labId:String*, labName:String*, projectId:String, batchId:String, cultureId:String, cultureCode:String, sceneCode:String*, moduleLevel1:String*, moduleLevel2:String*, operation:String*, sourceKind:String*, state:ApprovalState*, applyState:ApplyState*, submittedAt:OffsetDateTime*, operationAt:OffsetDateTime*, operator:PersonView*, reviewedAt:OffsetDateTime…全集见 spec 文件）
- 枚举冻结：ApprovalState=PENDING_REVIEW/PENDING_APPROVAL/APPROVED/CANCELLED；ApplyState=NONE/NOT_APPLICABLE/PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN；PersonKind=USER/SYSTEM
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_ARGUMENT, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§1-2(API04)｜任务包 TP-M06-02

## M06-011｜GET /process/approval/requests/{approvalId}｜com.futurefab.system.service.application.m06
- 权限：process:approval:query
- Controller→Service：`com.futurefab.system.controller.ProcessApprovalController#getApprovalRequestDetail` → `com.futurefab.system.service.application.m06.ProcessApprovalQueryApplicationService#getApprovalRequestDetail`
- Request `ApprovalRequestDetailQuery`：approvalId:String*
- Response：`ApprovalDetailView` + `ApprovalRow` + `PolicySnapshot` + `PolicyEntry` + `ResolutionRules` + `SourceEvidence` + `ChangeSnapshot` + `DiffField` + `TypedValue` + `Section` + `SectionRow` + `SectionCell` + `RelatedCulture` + `CultureReactor` + `CultureEquipment` + `CultureWorkflowNode` + `CulturePlanRef` + `RelatedTask` + `SpeedStrategy` + `ChangeImpact` + `PrecheckSummary` + `PrecheckIssue` + `PersonView` + `IssueView`（主视图字段：row:ApprovalRow*, policySnapshot:PolicySnapshot*, changeSnapshot:ChangeSnapshot*, submissionReason:String, cancelKind:CancelKind, supersedesApprovalId:String, precheck:PrecheckSummary）
- 枚举冻结：ApprovalState=PENDING_REVIEW/PENDING_APPROVAL/APPROVED/CANCELLED；ApplyState=NONE/NOT_APPLICABLE/PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN；PersonKind=USER/SYSTEM；CancelKind=REJECTED/WITHDRAWN/SOURCE_INVALIDATED；PolicyReadiness=UNVERIFIED/READY；ReviewMode=DIRECT/DIRECT_REASON/BATCH/PROJECT；ApproveMode=NONE/BATCH/PROJECT；OwnerModule=M03/M07/M09；ChangeTargetType=CULTURE/TASK/PLAN/ALARM_CONFIG；TypedValueKind=NULL/TEXT/DECIMAL/DATE/DATETIME/BOOLEAN/ID；TaskType=FEEDING/SUGAR；ImpactKind=NONE/REPLACE_PLAN_CANCEL_UNSTARTED；PrecheckStatus=PASS/BLOCKED/UNAVAILABLE
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：NOT_FOUND, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§1(Detail类型族)｜任务包 TP-M06-02

## M06-012｜GET /process/approval/requests/{approvalId}/actions｜com.futurefab.system.service.application.m06
- 权限：process:approval:query
- Controller→Service：`com.futurefab.system.controller.ProcessApprovalController#listApprovalActions` → `com.futurefab.system.service.application.m06.ProcessApprovalQueryApplicationService#listApprovalActions`
- Request `ApprovalActionListQuery`：approvalId:String*
- Response：`ApprovalActionView` + `PersonView`（主视图字段：actionId:String*, actionCode:ApprovalActionCode*, occurredAt:OffsetDateTime*, actor:PersonView*, beforeState:String*, afterState:String*, beforeVersion:String*, afterVersion:String*, reason:String, resultCode:String*）
- 枚举冻结：ApprovalActionCode=SUBMIT/REVIEW_PASS/APPROVE_PASS/REJECT/WITHDRAW/SOURCE_INVALIDATE/APPLY_RESULT；PersonKind=USER/SYSTEM
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：NOT_FOUND, FORBIDDEN
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§1-2(API06)｜任务包 TP-M06-02

## M06-013｜POST /process/approval/requests/{approvalId}/precheck｜com.futurefab.system.service.application.m06
- 权限：process:approval:review/approve/withdraw（按Body.action对应具体预检动作的功能码）
- Controller→Service：`com.futurefab.system.controller.ProcessApprovalController#precheckApprovalAction` → `com.futurefab.system.service.application.m06.ProcessApprovalQueryApplicationService#precheckApprovalAction`
- Request `ApprovalPrecheckCommand`：approvalId:String*, action:ApprovalPrecheckAction*, expectedObjectVersion:String*
- Response：`ApprovalPrecheckResult` + `IssueView`（主视图字段：eligible:Boolean*, issues:List<IssueView>, approvalVersion:String*, candidateHash:String*, checkedAt:OffsetDateTime*）
- 枚举冻结：ApprovalPrecheckAction=REVIEW/APPROVE/REJECT/WITHDRAW
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_ARGUMENT, NOT_FOUND, FORBIDDEN, AUTHORIZATION_UNAVAILABLE, OWNER_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§2(API07)｜任务包 TP-M06-02

## M06-014｜POST /process/approval/requests/{approvalId}/actions｜com.futurefab.system.service.application.m06
- 权限：process:approval:review/approve/withdraw（action映射：REVIEW_PASS→review、APPROVE_PASS→approve、REJECT→当前阶段review或approve、WITHDRAW→withdraw）
- Controller→Service：`com.futurefab.system.controller.ProcessApprovalController#executeApprovalAction` → `com.futurefab.system.service.application.m06.ProcessApprovalCommandApplicationService#executeApprovalAction`
- Request `ApprovalActionCommand`：approvalId:String*, action:ApprovalExecuteAction*, expectedObjectVersion:String*, reason:String, requestId:String*, managementRevision:String*
- Response：`ApprovalActionResult` + `IssueView`（主视图字段：approvalId:String*, objectVersion:String*, state:String*, applyState:String*, actionId:String*, requestId:String*, issues:List<IssueView>*）
- 枚举冻结：ApprovalExecuteAction=REVIEW_PASS/APPROVE_PASS/REJECT/WITHDRAW
- 状态变化/守卫：审批守卫链（M06 接口与审批生效契约）
- 错误码：INVALID_ARGUMENT, REASON_REQUIRED, FORBIDDEN, SELF_APPROVAL, STAGE_ACTOR_CONFLICT, NOT_FOUND, VERSION_CONFLICT, REQUEST_CONFLICT, ACTIVE_CHANGE_EXISTS, CULTURE_CODE_CONFLICT, SOURCE_STATE_CONFLICT, OWNER_UNAVAILABLE, AUTHORIZATION_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=apr_request
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission ; M06→M01: managementRevision ; M06→M03/M07/M09: deliverDecision ; M06→M03/M07/M09: queryApplication
- 来源：docs/详细设计/06-流程审批管理/接口与审批生效契约.md§1-2,§5(API08/ActionResult样例)｜任务包 TP-M06-02

## M06-015｜GET /process/approval/audit｜com.futurefab.system.service.application.m06
- 权限：process:approval:query＋ownerModule对应业务对象读取范围
- Controller→Service：`com.futurefab.system.controller.ProcessApprovalController#listDirectAudit` → `com.futurefab.system.service.application.m06.ProcessApprovalQueryApplicationService#listDirectAudit`
- Request `ApprovalAuditQuery`：ownerModule:OwnerModule*, sourceRequestId:String*, mode:AuditMode
- Response：`ApprovalAuditView` + `PersonView` + `IssueView`（主视图字段：ownerModule:OwnerModule*, sourceRequestId:String*, mode:AuditMode*, sceneCode:String, targetType:String, targetId:String, candidateId:String, candidateHash:String, policyRevisionId:String, reason:String, actor:PersonView, occurredAt:OffsetDateTime, approvalId:String, approvalState:String, deliveryId:String, applyState:String, ownerEvidenceRef:String, issues:List<IssueView>）
- 枚举冻结：OwnerModule=M03/M07/M09；AuditMode=DIRECT/DIRECT_REASON/APPROVAL；PersonKind=USER/SYSTEM
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：INVALID_ARGUMENT, FORBIDDEN, AUTHORIZATION_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M06→M01: ActorContext ; M06→M01: Permission
- 来源：docs/详细设计/06-流程审批管理/审阅收尾对账与启用契约.md#场景直通审计与查询(M06-API13冻结)｜任务包 TP-M06-02

# M09（14 条）

## M09-001｜GET /alarm/v2/records｜com.futurefab.system
- 权限：alarm:alarmRecord:list
- Controller→Service：`com.futurefab.system.controller.AlarmRecordV2Controller#pageRecords` → `com.futurefab.system.service.IAlarmRecordApplicationService#pageRecords`
- Request `AlarmRecordPageQuery`：startDate:LocalDate, endDate:LocalDate, alarmType:String, handleStatus:Integer, labId:String, keyword:String, personKeyword:String, pageNum:Integer, pageSize:Integer
- Response：`AlarmRow` + `DeviceBrief` + `CultureBrief` + `UserDisplayRef` + `AlarmRecipient` + `RoleRef`（主视图字段：alarmId:String*, alarmCode:String*, alarmType:String*, alarmTypeLabel:String*, ruleKey:String, module:String*, title:String*, content:String*, labId:String, labName:String, device:DeviceBrief, culture:CultureBrief, projectId:String, batchId:String, sampleId:String, triggerTime:OffsetDateTime*, conditionState:ConditionState*, resolvedAt:OffsetDateTime, handleStatus:Integer*, handleAction:Integer, h…全集见 spec 文件）
- 枚举冻结：ConditionState=ACTIVE/RESOLVED/LEGACY_UNKNOWN；RecipientState=RESOLVED/KNOWN_EMPTY/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §2/§3；固定排序triggerTime DESC,alarmId DESC、先当前可见域过滤再分页见§1/notes；物理接口与骨架字段设计.md §2｜任务包 TP-M09-02

## M09-002｜GET /alarm/v2/records/{alarmId}｜com.futurefab.system
- 权限：alarm:alarmRecord:query
- Controller→Service：`com.futurefab.system.controller.AlarmRecordV2Controller#getRecordDetail` → `com.futurefab.system.service.IAlarmRecordApplicationService#getRecordDetail`
- Request `AlarmRecordDetailQuery`：alarmId:String*
- Response：`AlarmDetail` + `AlarmRow` + `DeviceBrief` + `CultureBrief` + `UserDisplayRef` + `AlarmRecipient` + `RoleRef` + `Fact` + `SourceRef` + `Actor` + `Scope` + `QuantityRef` + `CommandEvidence` + `FactLink` + `LinkParams` + `EntityLabels` + `FactChange` + `FactDeadline` + `AlarmDetailLink` + `DeliveryRow`（主视图字段：factSnapshot:Fact*, ruleRevisionId:String, deliveryRows:List<DeliveryRow>*, links:List<AlarmDetailLink>*）
- 枚举冻结：ConditionState=ACTIVE/RESOLVED/LEGACY_UNKNOWN；RecipientState=RESOLVED/KNOWN_EMPTY/UNKNOWN；SourceModule=M01/M02/M03/M04/M05/M06/M07/M08/M09/ADAPTER；ActorKind=USER/SYSTEM；ScopeKind=DEVICE/CULTURE/LAB/SYSTEM；FactDirection=LOW/HIGH/ERROR/INFO/NONE；QuantityQuality=GOOD/BAD/UNKNOWN；CommandState=ACCEPTED/EXECUTED/FAILED/UNKNOWN；LinkRoute=ALARM_DETAIL/CULTURE_DETAIL/DETECT_RECORD/SIGN_WORKBENCH/TASK_DETAIL/DEVICE_DETAIL；DeliveryChannel=site/email/sms/sound/external；DeliveryState=PENDING/SENDING/SUCCEEDED/FAILED/UNKNOWN/SKIPPED/CANCELLED
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §2/§3；Fact/SourceRef/Scope等叶子取数据库JSON与事务契约.md §1；AlarmDetail=AlarmRow全部字段＋扩展见物理接口与骨架字段设计.md §2｜任务包 TP-M09-02

## M09-003｜POST /alarm/v2/records/{alarmId}/handle｜com.futurefab.system
- 权限：alarm:alarmRecord:handle
- Controller→Service：`com.futurefab.system.controller.AlarmRecordV2Controller#handleRecord` → `com.futurefab.system.service.IAlarmRecordApplicationService#handleRecord`
- Request `AlarmHandleCommand`：requestId:String*, expectedVersion:String*, action:Integer*, remark:String
- Response：`AlarmHandleResult`（主视图字段：mutation:MutationResult*, current:AlarmRow*）
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, VERSION_CONFLICT, IDEMPOTENCY_CONFLICT, ALREADY_HANDLED
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=alarm_record
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §2/§3/§5；AlarmHandleResult组合见物理接口与骨架字段设计.md §3；T04事务见数据库JSON与事务契约.md §4｜任务包 TP-M09-02

## M09-004｜GET /alarm/v2/rules｜com.futurefab.system
- 权限：alarm:alarmNotifyRule:list
- Controller→Service：`com.futurefab.system.controller.AlarmRuleV2Controller#getRuleConfig` → `com.futurefab.system.service.IAlarmRuleApplicationService#getRuleConfig`
- Request `null`：（无字段/NoBody）
- Response：`AlarmRuleConfigView` + `RuleRow` + `RoleOption` + `TypeOption` + `UserDisplayRef`（主视图字段：rules:List<RuleRow>*, roleOptions:List<RoleOption>*, typeOptions:List<TypeOption>*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3/§3配置输入展开；聚合响应形状见notes与物理接口与骨架字段设计.md §2｜任务包 TP-M09-01

## M09-006｜GET /alarm/v2/sender-config｜com.futurefab.system
- 权限：alarm:alarmMailConfig:query
- Controller→Service：`com.futurefab.system.controller.AlarmSenderConfigV2Controller#getSenderConfig` → `com.futurefab.system.service.IAlarmSenderConfigApplicationService#getSenderConfig`
- Request `null`：（无字段/NoBody）
- Response：`SenderView` + `SenderReadiness`（主视图字段：configId:String, revisionId:String, version:String, senderEmail:String*, senderAccount:String*, platformName:String*, serverName:String*, serverPort:Integer*, smsGatewayUrl:String, status:Integer*, passwordConfigured:Boolean*, secretConfigured:Boolean*, readiness:SenderReadiness*）
- 枚举冻结：ChannelReadiness=READY/BLOCKED
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3 SenderView输出；通知投递与恢复契约.md §4｜任务包 TP-M09-03

## M09-007｜PUT /alarm/v2/sender-config｜com.futurefab.system
- 权限：alarm:alarmMailConfig:edit
- Controller→Service：`com.futurefab.system.controller.AlarmSenderConfigV2Controller#saveSenderConfig` → `com.futurefab.system.service.IAlarmSenderConfigApplicationService#saveSenderConfig`
- Request `AlarmSenderConfigSaveCommand`：requestId:String*, baseRevisionId:String, expectedVersion:String, senderEmail:String*, senderAccount:String*, password:String, platformName:String*, serverName:String*, serverPort:Integer*, smsGatewayUrl:String, smsSecret:String, status:Integer*, passwordAction:SecretAction*, secretAction:SecretAction*
- Response：spec 未登记响应类（核对 00 清单 response_vo=`MutationResult`）
- 枚举冻结：SecretAction=KEEP/REPLACE/CLEAR
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, VERSION_CONFLICT, IDEMPOTENCY_CONFLICT
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=alarm_mail_config
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3 SenderInput；必填/加密规则见通知投递与恢复契约.md §4；MAIL body见数据库JSON与事务契约.md §2；响应MutationResult为公共外壳｜任务包 TP-M09-03

## M09-008｜GET /alarm/v2/status-config｜com.futurefab.system
- 权限：lab:statusalarm:list
- Controller→Service：`com.futurefab.system.controller.AlarmStatusConfigV2Controller#getStatusConfig` → `com.futurefab.system.service.IAlarmStatusConfigApplicationService#getStatusConfig`
- Request `AlarmStatusConfigQuery`：labId:String*, tab:StatusConfigTab*, unitId:String, liquidType:String
- Response：`AlarmStatusConfigView` + `Scope` + `StatusRow` + `UserDisplayRef` + `StatusFilterOptions` + `UnitOption` + `LiquidTypeOption` + `Issue`（主视图字段：scope:Scope*, revisionId:String, version:String, approvalId:String, applyState:ConfigApplyState*, origin:ConfigOrigin*, rows:List<StatusRow>*, allowedActions:List<String>*, issues:List<Issue>*, filterOptions:StatusFilterOptions*）
- 枚举冻结：StatusConfigTab=consumable/liquid/sampling_unit/feed_unit；ScopeKind=DEVICE/CULTURE/LAB/SYSTEM；ConfigApplyState=NONE/PENDING/APPLIED/CONFLICT；ConfigOrigin=DEVICE_PREVIEW/OWN/EMPTY；QuantityState=KNOWN/UNKNOWN
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3/§3配置输入展开+ConfigSet；G07见告警配置与审批生效契约.md §2；View包装形状见物理接口与骨架字段设计.md §3｜任务包 TP-M09-03

## M09-010｜GET /alarm/v2/online-config｜com.futurefab.system
- 权限：alarm:onlineConfig:query
- Controller→Service：`com.futurefab.system.controller.AlarmOnlineConfigV2Controller#getOnlineConfig` → `com.futurefab.system.service.IAlarmOnlineConfigApplicationService#getOnlineConfig`
- Request `AlarmOnlineConfigQuery`：scopeKind:OnlineScopeKind*, deviceKind:String*, deviceId:String*, cultureId:String
- Response：`AlarmOnlineConfigView` + `Scope` + `OnlineRow` + `UserDisplayRef` + `Issue`（主视图字段：scope:Scope*, revisionId:String, version:String, approvalId:String, applyState:ConfigApplyState*, origin:ConfigOrigin*, rows:List<OnlineRow>*, allowedActions:List<String>*, issues:List<Issue>*）
- 枚举冻结：OnlineScopeKind=DEVICE/CULTURE；ScopeKind=DEVICE/CULTURE/LAB/SYSTEM；ConfigApplyState=NONE/PENDING/APPLIED/CONFLICT；ConfigOrigin=DEVICE_PREVIEW/OWN/EMPTY；EvaluationState=SAVE_ONLY/VERIFIED
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3 API10+OnlineRow；View包装ConfigSet见物理接口与骨架字段设计.md §3；作用域规则见告警配置与审批生效契约.md §1｜任务包 TP-M09-03

## M09-012｜GET /alarm/v2/offline-config｜com.futurefab.system
- 权限：lab:offlinealarm:list
- Controller→Service：`com.futurefab.system.controller.AlarmOfflineConfigV2Controller#getOfflineConfig` → `com.futurefab.system.service.IAlarmOfflineConfigApplicationService#getOfflineConfig`
- Request `AlarmOfflineConfigQuery`：cultureId:String*, detectClass:OfflineDetectClass*
- Response：`AlarmOfflineConfigView` + `Scope` + `OfflineRow` + `UserDisplayRef` + `Issue`（主视图字段：scope:Scope*, revisionId:String, version:String, approvalId:String, applyState:ConfigApplyState*, origin:ConfigOrigin*, rows:List<OfflineRow>*, allowedActions:List<String>*, issues:List<Issue>*）
- 枚举冻结：OfflineDetectClass=BGA/Vicell/OSMO/Cedex；ScopeKind=DEVICE/CULTURE/LAB/SYSTEM；ConfigApplyState=NONE/PENDING/APPLIED/CONFLICT；ConfigOrigin=DEVICE_PREVIEW/OWN/EMPTY
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3 API12+OfflineRow展开；M09-Q03见详细设计/告警配置与审批生效契约.md；View包装见物理接口与骨架字段设计.md §3｜任务包 TP-M09-03

## M09-014｜GET /alarm/v2/monitor-policy｜com.futurefab.system
- 权限：alarm:monitorPolicy:query
- Controller→Service：`com.futurefab.system.controller.AlarmMonitorPolicyV2Controller#getMonitorPolicy` → `com.futurefab.system.service.IAlarmMonitorPolicyApplicationService#getMonitorPolicy`
- Request `AlarmMonitorPolicyQuery`：deviceKind:String*, deviceId:String*, cultureId:String
- Response：`AlarmMonitorPolicyView` + `Scope`（主视图字段：scope:Scope*, mode:MonitorMode*, remark:String, revisionId:String, version:String, executionAck:MonitorExecutionAck*, allowedActions:List<String>*）
- 枚举冻结：MonitorMode=ON/TEMP_OFF/LONG_OFF/UNKNOWN；MonitorExecutionAck=APPLIED/PENDING/UNKNOWN；ScopeKind=DEVICE/CULTURE/LAB/SYSTEM
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3 API14（叶子已定义，VO名按brief冻结AlarmMonitorPolicyView）；监控语义见告警配置与审批生效契约.md §3｜任务包 TP-M09-01

## M09-017｜GET /alarm/v2/notifications｜com.futurefab.system
- 权限：SELF=AUTHENTICATED; ADMIN=smp:notification:list
- Controller→Service：`com.futurefab.system.controller.AlarmNotificationV2Controller#pageNotifications` → `com.futurefab.system.service.IAlarmNotificationApplicationService#pageNotifications`
- Request `NotificationPageQuery`：context:MsgContext, channel:MsgQueryChannel, isRead:Integer, state:DeliveryState, recipientKeyword:String, contentKeyword:String, keyword:String, startDate:LocalDate, endDate:LocalDate, pageNum:Integer, pageSize:Integer
- Response：`NotificationPageView` + `NotificationRow` + `TargetUserBrief` + `UserDisplayRef` + `DeliveryRow`（主视图字段：context:MsgContext*, channel:MsgQueryChannel*, pageNum:Integer*, pageSize:Integer*, total:Long*, notificationRows:List<NotificationRow>, deliveryRows:List<DeliveryRow>）
- 枚举冻结：MsgContext=SELF/ADMIN；MsgQueryChannel=site/email/sms；DeliveryState=PENDING/SENDING/SUCCEEDED/FAILED/UNKNOWN/SKIPPED/CANCELLED；DeliveryChannel=site/email/sms/sound/external
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, VALIDATION_FAILED, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3 API17/G05；View形状见物理接口与骨架字段设计.md §3；密文受控内存分批解密匹配见通知投递与恢复契约/加密边界节｜任务包 TP-M09-04

## M09-018｜GET /alarm/v2/notifications/unread-count｜com.futurefab.system
- 权限：AUTHENTICATED
- Controller→Service：`com.futurefab.system.controller.AlarmNotificationV2Controller#getUnreadCount` → `com.futurefab.system.service.IAlarmNotificationApplicationService#getUnreadCount`
- Request `null`：（无字段/NoBody）
- Response：`NotificationUnreadCountView`（主视图字段：count:Long*, display:String*）
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §3 API18；形状冻结于物理接口与骨架字段设计.md §3｜任务包 TP-M09-04

## M09-020｜GET /alarm/v2/deliveries/{deliveryId}｜com.futurefab.system
- 权限：SELF=AUTHENTICATED; ADMIN=smp:notification:query; external/sound=alarm:delivery:operate
- Controller→Service：`com.futurefab.system.controller.AlarmDeliveryV2Controller#getDeliveryDetail` → `com.futurefab.system.service.IAlarmDeliveryApplicationService#getDeliveryDetail`
- Request `AlarmDeliveryDetailQuery`：deliveryId:String*
- Response：`AlarmDeliveryDetailView` + `DeliveryRow` + `AttemptRow` + `UserDisplayRef`（主视图字段：delivery:DeliveryRow*, attempts:List<AttemptRow>*, content:String）
- 枚举冻结：DeliveryChannel=site/email/sms/sound/external；DeliveryState=PENDING/SENDING/SUCCEEDED/FAILED/UNKNOWN/SKIPPED/CANCELLED
- 状态变化/守卫：N/A（只读；权限/数据范围由守卫前置，33-⑧查询五要素）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, DEPENDENCY_UNAVAILABLE
- 幂等：N/A（只读）｜事务：只读（查询）
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §2/§3 API20；View形状见物理接口与骨架字段设计.md §3；投递状态机见通知投递与恢复契约.md §3｜任务包 TP-M09-04

## M09-021｜POST /alarm/v2/deliveries/{deliveryId}/resend｜com.futurefab.system
- 权限：alarm:delivery:resend
- Controller→Service：`com.futurefab.system.controller.AlarmDeliveryV2Controller#resendDelivery` → `com.futurefab.system.service.IAlarmDeliveryApplicationService#resendDelivery`
- Request `AlarmDeliveryResendCommand`：requestId:String*, expectedVersion:String*
- Response：`AlarmDeliveryResendResult` + `DeliveryRow`（主视图字段：mutation:MutationResult*, delivery:DeliveryRow*）
- 枚举冻结：DeliveryChannel=site/email/sms/sound/external；DeliveryState=PENDING/SENDING/SUCCEEDED/FAILED/UNKNOWN/SKIPPED/CANCELLED
- 状态变化/守卫：管理写守卫链 Executor+@ManagementGuardedWrite+AuditIntent（33-⑦）
- 错误码：UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, VERSION_CONFLICT, IDEMPOTENCY_CONFLICT, DELIVERY_NOT_FAILED, DEPENDENCY_UNAVAILABLE
- 幂等：requestId 幂等键（DTO 字段已逐项冻结）｜事务：应用服务层事务；owner 表=alarm_delivery
- 跨模块 Port：M09→M01:ActorContext/Permission/managementRevision
- 来源：页面与接口契约.md §2/§3 API21；Result形状见物理接口与骨架字段设计.md §3；重发约束见通知投递与恢复契约.md §1/§3、数据库JSON与事务契约.md §3｜任务包 TP-M09-04

