# 15-TASK-ACL 契约骨架执行报告

> 版本：TASK-ACL／2026-09-19／分支 cloud。基线：PKG-00（03 报告）+ PKG-01（04 报告）+ TASK-COMMON（12 报告）+ TASK-USR（13 报告）。
> 任务书：TASK-ACL 功能与角色接口契约骨架接线（10 接口 = 10 ADJUST，3 NEW 回归）。
> 范围：仅接口契约骨架接线，**不实现真实菜单树、角色数据范围、角色成员、SYSTEM 保护、引用检查或任何授权业务**。

## 一、是否完成

**完成（骨架层级）**。10 条 ADJUST 接口已按冻结契约建立 Command/Query → ApplicationService 骨架 → Controller 接线，统一显式 `SkeletonNotImplementedException → HTTP 501`；扩展既有 `MenuApplicationService`/`RoleApplicationService`，未新建重复服务；035/038/047 三条 NEW 回归通过、未重复建结构。未实现任何真实菜单/角色查询或写入（本任务边界内不作为缺陷）。编译与测试由协调者在四包收口统一时段执行，本包未运行 Maven。

## 二、精确接口范围（10 条 ADJUST）

| 编号 | 契约 | 路由 | 冻结出口 | 权限 | 骨架出口 |
| --- | --- | --- | --- | --- | --- |
| M01-036 | ACL02 | POST /system/menu | MenuCreateCommand → MutationResult | system:menu:add | `menuApplicationService.createMenu`，501 |
| M01-037 | ACL03 | PUT /system/menu | MenuUpdateCommand → MutationResult | system:menu:edit | `menuApplicationService.updateMenu`，501 |
| M01-039 | ACL05 | GET /system/role/list | RoleListQuery → List\<RoleRow\> | system:role:list | `roleApplicationService.listRoles`，501 |
| M01-040 | ACL06 | POST /system/role | RoleCreateCommand → MutationResult | system:role:add | `roleApplicationService.createRole`，501 |
| M01-041 | ACL07 | PUT /system/role | RoleUpdateCommand → MutationResult | system:role:edit | `roleApplicationService.updateRole`，501 |
| M01-042 | ACL08 | PUT /system/role/changeStatus | RoleStatusChangeCommand → MutationResult | system:role:edit | `roleApplicationService.changeStatus`，501 |
| M01-043 | ACL09 | GET /system/role/roleUsers | RoleMemberQuery → PageResult\<RoleMemberRow\> | system:role:list | `roleApplicationService.listRoleMembers`，501 |
| M01-044 | ACL10 | DELETE /system/role/{roleIds} | RoleDeleteCommand → DeleteResult | system:role:remove | `roleApplicationService.deleteRoles`，501 |
| M01-045 | ACL11 | GET /system/menu/{menuId} | MenuDetailQuery → MenuDetailView | system:menu:query | `menuApplicationService.getMenuDetail`，501 |
| M01-046 | ACL12 | GET /system/role/{roleId} | RoleDetailQuery → RoleDetailView | system:role:query | `roleApplicationService.getRoleDetail`，501 |

权限按 00 清单冻结完整前缀（`system:menu:*`/`system:role:*`），未创造新权限字符串；043 冻结权限登记为「system:role:list 且角色可见」，骨架保留 `system:role:list` 单值注解，「角色可见」判定属业务实现阶段。

## 三、3 条 NEW 回归（不重复创建）

| 编号 | 契约 | 路由 | 归属服务 | 结果 |
| --- | --- | --- | --- | --- |
| M01-035 | ACL01 | GET /system/menu/pageList | `MenuApplicationService.pageMenuList` | 显式 501，编号不变，未重复建 |
| M01-038 | ACL04 | PUT /system/menu/changeStatus | `MenuApplicationService.changeStatus` | 显式 501，编号不变，未重复建（PKG-01 请求头装配未改） |
| M01-047 | ACL13 | GET /system/role/editor-options | `RoleApplicationService.editorOptions` | 显式 501，编号不变，未重复建 |

方法计数锁定：`MenuApplicationService` 恰 5 方法（2 NEW + 3 本包）、`RoleApplicationService` 恰 8 方法（1 NEW + 7 本包），无新增嵌套结果结构。

## 四、冻结契约与外壳出入说明

- 任务书 §四冻结表与 00 清单、PKG-00 公共契约逐条一致，无返回外壳出入。
- **M01-039 输出 `List<RoleRow>`**（旧数组根不静默改分页，00 清单 notes 明确）；`success(List)` 走 data 数组外壳，非 PageResult，与冻结一致。
- **M01-044 输出 `DeleteResult`**（00 清单与冻结表均为 DeleteResult）。注：模块详细设计 §17.1 将删除 data 记为 W，与 00 清单 DeleteResult 存在文档级措辞差异；本任务遵冻结清单取 DeleteResult，并在类 javadoc 与本报告标注，交接口目录侧后续统一确认。
- MutationResult / PageResult / DeleteResult 均为 PKG-00 `vo/common` 冻结公共外壳，本包只读、未复制。

## 五、新增/复用 DTO / View

**新增 DTO（`domain/dto/m01`，10 个）**：MenuCreateCommand、MenuUpdateCommand（=Create+menuId）、MenuDetailQuery、RoleListQuery、RoleCreateCommand、RoleUpdateCommand（=Create+roleId）、RoleStatusChangeCommand、RoleMemberQuery、RoleDeleteCommand、RoleDetailQuery。字段逐项取自《详细设计 §17.2 / §19》：ID 一律 String，`beginDate/endDate` 用 `LocalDate`（对齐 MenuPageQuery 既有惯例），写 Command 仅预留 `requestId/managementRevision` 字段位。

**新增 View（`domain/vo/m01`，4 个）**：RoleRow（roleId/roleName/roleKey/status/dataScopes[]/deptIds[]/menuIds[]/remark/assignedUserCount/audit:AuditView/allowedActions[]）、RoleDetailView（RoleRow 全字段，ACL12 data RoleRow）、MenuDetailView（§17.2 MenuRow 全展开，children 空数组，ACL11 data MenuRow）、RoleMemberRow（Person 全字段 + assignedAt:OffsetDateTime）。

**复用（只读）**：MenuRow、AuditView、RoleLabelView、OptionView/ScopeOptionView/RoleEditorOptionsView（047）、vo/common 三外壳。未返回 `SysMenu`/`SysRole`/`SysUser` 实体或 Map。集合 getter 一律 null 归一为空集合。

## 六、ApplicationService 方法（扩展既有，零字段）

- `MenuApplicationService`/`Impl`：新增 `createMenu(036)/updateMenu(037)/getMenuDetail(045)`，与既有 `pageMenuList(035)/changeStatus(038)` 同接口承接，共 5 方法。
- `RoleApplicationService`/`Impl`：新增 `listRoles(039)/createRole(040)/updateRole(041)/changeStatus(042)/listRoleMembers(043)/deleteRoles(044)/getRoleDetail(046)`，与既有 `editorOptions(047)` 同接口承接，共 8 方法。
- 两 Impl 类零字段（`getDeclaredFields().length==0` 断言锁定），每方法单行抛 `SkeletonNotImplementedException("M01-nnn")`，无 null/空分页/固定成功。

## 七、Controller → ApplicationService 映射与旧链路切断

| 入口 | 协作者 | 移除的旧编排 |
| --- | --- | --- |
| SysMenuController.add | menuApplicationService.createMenu | checkMenuNameUnique/checkRouteConfigUnique/insertMenu/SecurityUtils/toAjax |
| SysMenuController.edit | menuApplicationService.updateMenu | 同名唯一/移父防环/updateMenu |
| SysMenuController.getInfo(String) | menuApplicationService.getMenuDetail | menuService.selectMenuById（改 String Path） |
| SysRoleController.list | roleApplicationService.listRoles | startPage/selectRoleList/getDataTable/TableDataInfo |
| SysRoleController.add | roleApplicationService.createRole | checkRoleName/KeyUnique/insertRole/SecurityUtils |
| SysRoleController.edit | roleApplicationService.updateRole | checkRoleAllowed/checkRoleDataScope/updateRole |
| SysRoleController.changeStatus | roleApplicationService.changeStatus | checkRoleAllowed/updateRoleStatus |
| SysRoleController.roleUsers | roleApplicationService.listRoleMembers | Redis 在线查询/PageHelper/selectAllocatedList/getDataTable（删私有 helper getRoleOnlineUserNames） |
| SysRoleController.remove | roleApplicationService.deleteRoles | deleteRoleByIds/toAjax（Path 逗号仅基本拆分绑定） |
| SysRoleController.getInfo(String) | roleApplicationService.getRoleDetail | checkRoleDataScope/selectRoleById |

**保留原样（属 TASK-ROUTE，非本 10 条）**：SysMenuController 的 list/treeselect/roleMenuTreeselect/updateSort/remove/{menuId}/getRouters、changeStatus 头装配；SysRoleController 的 export/dataScope/optionselect/authUser 系列/deptTree 等。旧 `ISysMenuService`/`ISysRoleService`/`ISysUserService` 字段仍被这些未登记旧路由使用，本包不删。SysRoleController 移除的私有 helper 与 `redisService` 字段仅服务被本包接线的 043，非旧路由消费者。

## 八、WriteMeta 预留与守卫边界（§十）

写接口 036/037/040/041/042/044 的 Command 均含 `requestId/managementRevision` 字段位（对齐 TASK-USR 先例：ADJUST 入口不接请求头强制装配，仅字段预留）。**未接** ManagementGuardExecutor、幂等回执、CAS、审计、ActorContextPort、SysManagementRequest。读接口 039/043/045/046（及 035）Query **不含** WriteMeta 字段（测试双向断言）。

## 九、@Log 处置

骨架写入口 036/037/040/041/042/044 移除 `@Log`（LogAspect 会在 501 时仍写 sys_oper_log，违反「501 前无 DB/日志副作用」门禁），与 TASK-USR 先例一致；恢复实现时随业务一并接回。

## 十、显式 501 / 旧 Service / Mapper / Redis / 守卫 / SQL 自查

1. 仅建 DTO/View/AppService/Controller 接线与显式 501；无真实菜单树、数据范围、成员、SYSTEM 保护、引用检查计算。
2. 未调用 `ISysMenuService`/`ISysRoleService`/`ISysUserService` 业务方法（接线方法体静态取证禁列 token）。
3. **无新增/修改 Mapper、Mapper XML、SQL**：本包改动清单内 0 个 mapper 文件、0 条 SQL statement（`git status` 中 `SysMenuMapper.java/.xml`、`SysRoleMapper.java/.xml` 为并行任务先前改动，非本包，未触碰）。
4. 未访问 Redis；043 旧 Redis 在线查询已从接线方法体移除。
5. 未接 ManagementGuardExecutor/ActorContextPort（全仓骨架入口 0 引用）。
6. 未修改 Vue（futurefab-ui）、客户只读材料、开发基线 SQL、domain 实体。
7. 未提交 Git、未执行 reset/checkout/restore/clean。

## 十一、修改文件清单

**新增（main，14）**：dto/m01 10 个（§五）+ vo/m01 4 个（RoleRow/RoleDetailView/MenuDetailView/RoleMemberRow）。
**修改（main，6）**：service/application/m01/{MenuApplicationService,RoleApplicationService}.java、service/impl/application/m01/{MenuApplicationServiceImpl,RoleApplicationServiceImpl}.java、controller/{SysMenuController,SysRoleController}.java。
**新增（test，1）**：contract/M01AclSkeletonContractTest.java。
**新增（文档，1）**：本报告。
未修改：公共 10 审计文件（`10-全接口契约骨架覆盖审计.md/.json`）、05~13 号报告（只读）、Mapper/XML/SQL、domain 实体、futurefab-ui、其他并行任务包（SYS-VENUE/SYS-DEPT/SYS-GROUP/SysDict*/SysConfig/SysUser* 等）文件、客户只读材料、仓库根 `_tmp_*`。

## 十二、测试结果（未运行 Maven 声明）

**本包静态检查通过**（编辑期 `git diff --check` 退出码 0；import/方法签名/注解/契约 ID 逐项人工核对）。**未运行 Maven：编译与单元/契约测试待协调者在四包收口后统一时段执行**，本报告不宣称编译或测试通过。

新增 `M01AclSkeletonContractTest`（待统一时段执行）覆盖：
- 10 条路由/HTTP 动词/冻结权限反射断言；
- 10 个接线方法体 Controller→ApplicationService 单调用取证 + 旧协作者禁列 token（menuService/roleService/userService/redis/PageHelper/toAjax/SysUser/SysRole 等）；
- Menu/Role AppService 逐方法编号 501（含 null 入参）与 Controller 委托抛 501；
- 实现类零字段、`MenuApplicationService==5`/`RoleApplicationService==8` 方法数、无重复服务/嵌套结构；
- 035/038/047 三条 NEW 方法编号回归；
- WriteMeta 写 Command 双向、读 Query 无（含 requestId/managementRevision 类型 String）；
- DTO 字段全集与 Update=Create+id、View/Row ID String、`LocalDate`/`OffsetDateTime` 冻结时间、集合非 null、无实体/凭据字段；
- 044 逗号拆分不进旧删除链；
- MockMvc 外壳：status 501 + `errorCode=NOT_IMPLEMENTED` + `contractId` + `requestId` 为 String + `data` 不存在（读接口不返回 data 伪成功）。

COMMON（M01SystemSkeletonContractTest）、USR（M01UserSkeletonContractTest）既有测试未触碰其类与被测接线；038 头装配与 047 既有注解未改动，预期无回归（待统一时段核验）。

## 十三、未执行验证事项

真实 MySQL/Redis/M02-AAD 联调、HTTP 端到端、浏览器验收、外部设备/系统联调、建库执行、现场验收均未进行。本报告仅声明至「静态检查」层级，编译与测试待统一时段。

## 十四、阻塞项 / 需确认

1. M01-044 输出类型 `DeleteResult`（冻结清单）与 §17.1「删除 data=W」措辞差异，需接口目录侧统一确认（不影响骨架可编译性）。
2. 守卫、幂等回执、SYSTEM 保护、引用检查、数据范围、菜单树、成员装配、审计映射均为业务实现阶段回填，本包不实现。
3. 非本 10 条旧路由的处置交 TASK-ROUTE。

## 十五、公共审计文件与 Git 未操作确认

未修改 `docs/开发任务/10-全接口契约骨架覆盖审计.md` 与 `.json`；05~13 号报告仅读。未 `git commit`/`git push`/建 PR；未 `git checkout`/`reset`/`stash`/`clean` 他人变更。

## 十六、边界声明

**本任务无真实授权、数据范围计算与菜单树逻辑**，仅为契约骨架接线与显式 501；不得据本报告宣称任何较高层级（编译/测试/联调/上线）完成。
