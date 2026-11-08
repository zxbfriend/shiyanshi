# 14-TASK-ORG 契约骨架执行报告

> 版本：TASK-ORG／2026-09-19／分支 cloud。基线：PKG-01（04 报告）+ PRE-01A/B/C（06/07/08/09 报告）+ SECURITY-P0（11 报告）+ TASK-COMMON（12 报告）+ TASK-USR（13 报告）。
> 任务书：TASK-ORG 组织（场地／部门／实验组）接口契约骨架接线（22 接口 = 14 ADJUST + 8 NEW 回归）。
> 边界：只建契约骨架，不实现任何真实业务逻辑；本文件仅记录本任务自有文件的改动与静态核验结论。

## 一、是否完成

**完成（骨架层级）**。14 条 ADJUST 已按冻结契约完成「Controller 入口 → 冻结 Command/Query → Venue/Dept/Group ApplicationService 骨架方法 → 显式 `SkeletonNotImplementedException → HTTP 501`」接线；8 条既有 NEW 骨架保持原样并纳入回归断言。未实现任何真实查询、写入、引用检查或数据库访问（本任务边界内不作为缺陷）。

- 静态检查通过；**编译与测试待统一时段**（并行四包收口后由协调者统一执行 Maven，见第十五、十六节）。

## 二、精确接口范围（14 ADJUST 逐条结果）

| 编号 | canonical 路由 | 权限（保持既有，不发明） | 新建/复用请求模型 | 冻结响应外壳 | 骨架出口 | 结果 |
| --- | --- | --- | --- | --- | --- | --- |
| M01-014 | POST /system/smp/venue | system:venue:add | `VenueSaveCommand`（新） | `MutationResult` | `VenueApplicationService#createVenue` | 501 已接线 |
| M01-015 | PUT /system/smp/venue | system:venue:edit | `VenueSaveCommand`（新，复用同类型） | `MutationResult` | `#updateVenue` | 501 已接线 |
| M01-016 | GET /system/smp/venue/tree | system:venue:list | `VenueTreeQuery`（新） | `List<OptionView>` | `#venueTree` | 501 已接线 |
| M01-018 | DELETE /system/smp/venue/{venueIds} | system:venue:remove | `VenueDeleteCommand`（新） | `DeleteResult` | `#deleteVenues` | 501 已接线 |
| M01-019 | POST /system/dept | system:dept:add | `DeptCreateCommand`（新） | `MutationResult` | `DeptApplicationService#createDept` | 501 已接线 |
| M01-020 | PUT /system/dept | system:dept:edit | `DeptUpdateCommand`（新） | `MutationResult` | `#updateDept` | 501 已接线 |
| M01-024 | GET /system/smp/labgroup/list | system:labgroup:list | `GroupListQuery`（新） | `List<GroupRow>` | `GroupApplicationService#listGroups` | 501 已接线 |
| M01-025 | POST /system/smp/labgroup | system:labgroup:add | `GroupCreateCommand`（新） | `MutationResult` | `#createGroup` | 501 已接线 |
| M01-026 | PUT /system/smp/labgroup | system:labgroup:edit | `GroupUpdateCommand`（新） | `MutationResult` | `#updateGroup` | 501 已接线 |
| M01-028 | DELETE /system/smp/labgroup/{groupIds} | system:labgroup:remove | `GroupDeleteCommand`（新） | `DeleteResult` | `#deleteGroups` | 501 已接线 |
| M01-030 | DELETE /system/dept/{deptId} | system:dept:remove | `DeptDeleteCommand`（新） | `DeleteResult` | `DeptApplicationService#deleteDept` | 501 已接线 |
| M01-031 | GET /system/smp/venue/{venueId} | system:venue:query | `VenueDetailQuery`（新） | `VenueDetailView`（新） | `#venueDetail` | 501 已接线 |
| M01-032 | GET /system/dept/{deptId} | system:dept:query | `DeptDetailQuery`（新） | `DeptDetailView`（新） | `#deptDetail` | 501 已接线 |
| M01-033 | GET /system/smp/labgroup/{groupId} | system:labgroup:query | `GroupDetailQuery`（新） | `GroupDetailView`（新） | `#groupDetail` | 501 已接线 |

14/14 完成，无遗漏、无 200 伪成功出口。

## 三、8 条 NEW 骨架回归（静态结论）

| 编号 | 路由 | 既有骨架方法 | 回归结论 |
| --- | --- | --- | --- |
| M01-013 | GET /system/smp/venue/pageList | `pageVenueList → PageResult<VenueRow>` | 未重建、未改签名，仍显式 501 |
| M01-017 | GET /system/smp/venue/{venueId}/delete-check | `deleteCheck → DeletePrecheckResult` | 同上 |
| M01-021 | GET /system/dept/options | `options → List<OptionView>` | 同上（7 权限 OR 集合未改） |
| M01-022 | GET /system/dept/{deptId}/delete-check | `deleteCheck → DeletePrecheckResult` | 同上 |
| M01-023 | GET /system/dept/{deptId}/users | `listDeptUsers → List<PersonOptionView>` | 同上 |
| M01-029 | GET /system/dept/pageList | `pageDeptList → PageResult<DeptRow>` | 同上 |
| M01-027 | GET /system/smp/labgroup/member-options | `memberOptions → List<PersonOptionView>` | 同上 |
| M01-034 | POST /system/smp/labgroup/resolve-members | `resolveMembers → GroupMemberResolveResult` | 同上（canonical 路径与 05 审计 R2 结论一致，无路径分歧） |

回归以「不重复建第二套接口／不新增嵌套结果类／每个契约编号在实现中恰好出现一次」三重断言固定，见第十七节。

## 四、新增/复用 DTO/View 与关键裁定

- **新增请求模型 13 个**（`domain/dto/m01`）：VenueSaveCommand、VenueTreeQuery、VenueDeleteCommand、VenueDetailQuery、DeptCreateCommand、DeptUpdateCommand、DeptDeleteCommand、DeptDetailQuery、GroupListQuery、GroupCreateCommand、GroupUpdateCommand、GroupDeleteCommand、GroupDetailQuery。
- **新增响应视图 4 个**（`domain/vo/m01`）：GroupRow、VenueDetailView、DeptDetailView、GroupDetailView。
- **复用既有视图/外壳**：VenueRow、DeptRow、OptionView、PersonOptionView、AuditView（`vo/m01`）+ PageResult、MutationResult、DeleteResult、DeletePrecheckResult（PKG-00 `vo/common`）；复用 DTO：VenuePageQuery、VenueDeleteCheckQuery、DeptOptionQuery、DeptPageQuery、DeptDeleteCheckQuery、DeptUserQuery、GroupMemberOptionQuery、GroupMemberResolveCommand。
- 关键裁定：
  1. `VenueSaveCommand` 同时承载 014/015（§18 ORG02/ORG03 字段同集，PUT 侧 venueId 必填属业务校验阶段），避免同形状双模型。
  2. 详情视图按 §17.2「DTO 继承指包含对应行全部展开字段」直接 `extends` 行模型（VenueDetailView→VenueRow、DeptDetailView→DeptRow、GroupDetailView→GroupRow 再补 leaderUserIds/memberUserIds/members），不复制字段、不返回实体。
  3. `GroupListQuery` 保持 §18 Q+F 形状（pageNum/pageSize/keyword/beginDate/endDate，日期为 `LocalDate` 日期串），不引入 WriteMeta。
  4. ID 全 String、视图时间全 `OffsetDateTime`（§17.1）；集合 getter 空值归一为 `Collections.emptyList()`，写 Command 的 List setter 对 null 归一为空数组（026「空数组即清空」语义的前置形状保证）。
  5. 冻结请求体不接受 `ancestors`、`delFlag`、`createBy/updateBy`、`params`、`searchValue`、`status`（Dept）、`orderNum`（Venue）等只读或派生字段；`parentId` 默认 `"0"`、`orderNum` 默认 `1` 按 §18 显式落默认值。

## 五、ApplicationService 与方法数量

复用并扩展 PKG-01 既有三个组织应用端口，**未新建第二套接口、未新增接口文件**：

| 端口 | 方法数 | 其中本任务新增 | 覆盖契约 |
| --- | --- | --- | --- |
| `VenueApplicationService` | 7 | 5（createVenue/updateVenue/venueTree/deleteVenues/venueDetail） | 013—018、031 |
| `DeptApplicationService` | 8 | 4（createDept/updateDept/deleteDept/deptDetail） | 019—023、029、030、032 |
| `GroupApplicationService` | 7 | 5（listGroups/createGroup/updateGroup/deleteGroups/groupDetail） | 024—028、033、034 |
| 合计 | **22** | **14** | 14 ADJUST + 8 NEW |

对应三个骨架实现类（`service/impl/application/m01`）方法数 7/8/7＝22，与接口一一对应；每个方法体只有一行 `throw new SkeletonNotImplementedException("M01-nnn")`。

## 六、Controller → ApplicationService 映射

- `SysVenueController`：013/014/015/016/017/018/031 → `venueApplicationService`（7 入口）。
- `SysDeptController`：019/020/021/022/023/029/030/032 → `deptApplicationService`（8 入口）。
- `SysGroupController`：024/025/026/027/028/033/034 → `groupApplicationService`（7 入口）。

22 个入口方法签名参数均为冻结 Command/Query 或 String Path 变量，返回统一 `AjaxResult`（`success(视图)` 外壳，`requestId/managementRevision` 由 PRE-01A 的 `RequestMetadataFilter` + `RequestMetadataResponseAdvice` 注入）。

## 七、权限口径（§九）

14 条 ADJUST 权限全部逐字沿用既有注解与 00 清单登记值（见第二节表格），未新增、未改名、未放宽；021/027/034 三条 NEW 的多权限 OR 集合原样保留。测试对 22 个入口的权限做了单值与集合两级断言，任何越界改动都会失败。

## 八、WriteMeta 预留（§十）

- 预留的写接口（014/015/018/019/020/025/026/028/030）：Command 仅预留 `requestId` + `managementRevision` 两个 String 字段位，形状与 TASK-COMMON／TASK-USR 一致；**未接入** `ManagementGuardExecutor`、幂等表写入、`X-Management-Revision` 解析或任何回执逻辑。
- 查询接口（016/024/031/032/033）及既有 NEW Query（013/017/021/022/023/027/029）不携带 WriteMeta：测试对 12 个读模型逐类证明无 `requestId/managementRevision` 字段。
- DELETE 类 Path 入参（018/028/030）只做逗号字符串基本拆分绑定与 Command 装配，不做数量、正 ID、存在性、引用或数据范围校验。

## 九、骨架纪律逐条自查（任务书 §四 12 项）

1. 每个接口都有 Controller → 冻结模型 → ApplicationService → 显式 501 的完整链路：满足（第二、五、六节）。
2. 实现类不注入任何依赖：三个 Impl `getDeclaredFields().length == 0`。
3. 每个方法只抛自身 501，不返回 null/空/0/true/成功：源码取证要求所有 `public ... { ... }` 代码行含 `throw new SkeletonNotImplementedException("M01-`，且全文件无 `return`。
4. 复用扩展既有三个端口，无第二套接口：方法数 7/8/7、无嵌套结果类。
5. 14 个 Controller 方法已移除旧编排与旧 Service 调用：方法体源码取证禁止 `sysVenueService/deptService/sysGroupService`、`insertSysVenue/updateSysVenue/selectSysVenueByVenueId/countRelatedVenueUsage`、`checkDeptNameUnique/checkDeptCodeUnique/checkDeptDataScope/hasChildByDeptId/checkDeptExistUser/deleteDeptById`、`selectSysGroupList/insertSysGroup/updateSysGroup/selectSysGroupByGroupId/syncGroupUsers/fillGroupMembers`、`startPage/getDataTable/TableDataInfo/toAjax/error(/warn(/ArrayUtils/SecurityUtils/UserConstants` 及 `SysVenue/SysDept/SysGroup/Long` 实体签名。
6. 其他旧路由保持原样：`/smp/venue/list`、`/smp/venue/export`、`/dept/list`、`/dept/list/exclude/{deptId}`、`/dept/updateSort`、`/smp/labgroup/export`、`/smp/labgroup/{groupId}/members`（GET）、`/smp/labgroup/member-tree`、`/smp/labgroup/{groupId}/member-details`、`PUT /smp/labgroup/{groupId}/members` 全部保留（测试反射验证签名仍在，且旧 Service 字段仍在），处置权归 TASK-ROUTE。
7. 查询不带 WriteMeta：见第八节。
8. 写接口只预留 requestId + managementRevision，无守卫执行器：见第八节。
9. DELETE Path 只做基本绑定：见第八节。
10. BLK-02（场地/部门删除与重挂的跨模块引用检查）未实现，只保留接口位与显式 501：见第十八节。
11. ID 全 String、时间全 OffsetDateTime、绝不返回 Entity/Map：见第四节与第十七节类型断言。
12. 权限字符串零发明：见第七节。

补充决策（与 TASK-COMMON/TASK-USR 同口径）：已接线的 8 个写入口（014/015/018/019/020/025/026/028/030 对应方法）**移除 `@Log` 注解**。理由：`LogAspect` 在响应为 501 时仍会写 `sys_oper_log`，与「骨架不产生副作用」冲突；`@Log` 应随业务实现阶段一并接回。未登记旧路由（如 `/dept/updateSort`、`/smp/labgroup/export`、`PUT /{groupId}/members`）的 `@Log` 原样保留。

## 十、是否仍调用旧 Service

14 条 ADJUST 与 8 条 NEW 的 22 个入口方法体内**均不**调用 `ISysVenueService`／`ISysDeptService`／`ISysGroupService`。旧 Service 字段与被显式登记的未路由消费者（TASK-ROUTE 管辖的旧路由）仍需它，故字段保留；这是第 6 项纪律的要求，不是遗留调用。

## 十一、是否访问 Mapper/Redis/M02/M03

无。三个骨架实现类源码（剔除注释后的代码行）禁止并验证了 `Mapper`、`Redis/redis`、`ISys`、`service.port`、`Port`、`M02`、`M03`、`@Autowired`、`@Transactional`、`return`、`Entity`、实体类型名等 token；Controller 侧由第九节第 5 项取证覆盖。未新增或修改任何 Mapper 接口、Mapper XML、SQL、Flyway/建表脚本（本任务自有文件内 0 处）。

## 十二、是否接入 ManagementGuardExecutor

**未接入**。无守卫调用、无幂等回执、无 revision 预解析装配；仅保留 §八 的两个字段位。守卫接线属实现阶段（PRE-01B/C 已提供运行前置，不在骨架接线范围）。

## 十三、修改文件清单（共 28 个，全部在本任务所有权内）

修改（9）：

1. `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/SysVenueController.java`
2. `.../controller/SysDeptController.java`
3. `.../controller/SysGroupController.java`
4. `.../service/application/m01/VenueApplicationService.java`
5. `.../service/application/m01/DeptApplicationService.java`
6. `.../service/application/m01/GroupApplicationService.java`
7. `.../service/impl/application/m01/VenueApplicationServiceImpl.java`
8. `.../service/impl/application/m01/DeptApplicationServiceImpl.java`
9. `.../service/impl/application/m01/GroupApplicationServiceImpl.java`

新增 DTO（13）：`.../domain/dto/m01/{VenueSaveCommand,VenueTreeQuery,VenueDeleteCommand,VenueDetailQuery,DeptCreateCommand,DeptUpdateCommand,DeptDeleteCommand,DeptDetailQuery,GroupListQuery,GroupCreateCommand,GroupUpdateCommand,GroupDeleteCommand,GroupDetailQuery}.java`

新增 View（4）：`.../domain/vo/m01/{GroupRow,VenueDetailView,DeptDetailView,GroupDetailView}.java`

新增测试（1）：`futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/contract/M01OrgSkeletonContractTest.java`

新增报告（1）：`docs/开发任务/14-TASK-ORG契约骨架执行报告.md`（本文件）

未触碰：其他并行任务（ACL/DIC/CFG/SECURITY/ROUTE）自有文件、`docs/开发任务/10-*` 审计双文件、`05-*` 差异审计与 06—13 报告、仓库根 `_tmp_*`、Mapper/XML/SQL、`futurefab-ui`、`docs/接口文档` 等只读资料。

## 十四、测试数量与结果

`M01OrgSkeletonContractTest` 共 **31 个 @Test**（1118 行），覆盖任务书 §十一要求的全部维度：

| 组 | 断言 |
| --- | --- |
| 路由/动词 | 22 个入口的 `@GetMapping/@PostMapping/@PutMapping/@DeleteMapping` 路径与参数类型（反射） |
| 权限 | 14 ADJUST 单值 + 8 NEW（含 021/027/034 OR 集合） |
| 调用链取证 | 14 个方法体只调对应 ApplicationService；22 个入口统一 `success(` 外壳，无 `toAjax/TableDataInfo/startPage/error(/warn(` |
| 逗号 Path 绑定 | 018/028 `split(",")` + 冻结 Command 装配证据 |
| 旧路由保留 | 10 条未登记旧路由签名与旧 Service 字段仍在 |
| 显式 501 | 14 个方法（含 null 入参）逐一 `getContractId()` 匹配；14 个 Controller 入口在进入任何协作者前抛出 |
| NEW 回归 | 8 个既有骨架方法仍抛自身编号 |
| 结构与计数 | 三端口方法数 7/8/7、无嵌套类、22 处 `SkeletonNotImplementedException(` 且每个契约编号恰好出现一次、返回类型全名与冻结外壳一致 |
| 零状态 | 三个 Impl `getDeclaredFields().length == 0`；实现类代码行协作者禁止清单 |
| HTTP 外壳 | 14 ADJUST + 8 NEW 经 MockMvc + 三 ControllerAdvice + `RequestMetadataFilter`：`status=501`、`errorCode=NOT_IMPLEMENTED`、`contractId`、`requestId` 为字符串、`$.data` 不存在 |
| 模型形状 | 13 个 DTO 字段全集、禁止字段、String/Integer/`LocalDate`/`OffsetDateTime` 类型、默认值与 null 安全集合、9 写 Command 预留 WriteMeta、12 读模型无 WriteMeta、详情视图继承行模型字段并集 |

**结果：静态检查通过、编译测试待统一时段。** 按当前四包并行协调约束未执行任何 Maven 命令，因此不得声称测试通过；已完成的核验见第十五节。

## 十五、已执行的核验（不含 Maven）

1. `git diff --check`：退出码 0，无空白/冲突标记。
2. 自有文件全部通过括号/花括号配平与字符串-注释感知的语法扫描（133 个相关 java 文件 0 异常）。
3. 逐项人工比对：22 个签名字符串、14+8 个权限值、22 个路由与动词、13 个 DTO 字段集、4 个 VO 字段集与继承关系、9 个写模型 WriteMeta、12 个读模型无 WriteMeta —— 均与主干源码逐字核对一致。
4. 交叉影响检查：`M01SystemSkeletonContractTest`（TASK-SYSTEM）、`M01UserSkeletonContractTest`（TASK-USR）、`M01ConfigSkeletonContractTest`、`M01AclSkeletonContractTest`、`M01DictSkeletonContractTest`、`M01ResponseLeakGuardTest` 均不引用 Venue/Dept/Group 类或本任务改动的文件，不存在因本任务改动而失败的既有断言。
5. 测试内源码取证辅助（`readSource`/`extractMethodBody`/`codeLinesOf`）已用真实源码字符串复核，包括签名唯一性与大括号配平。

## 十六、未执行的环境验证

- `mvn -q -pl futurefab-modules/futurefab-system -am test`（或协调窗口的全量 `test`）——含 `M01OrgSkeletonContractTest` 31 项、TASK-COMMON/TASK-USR/PKG-01 回归。
- 编译期校验（注解处理器、Spring 上下文启动、`@Service` 唯一实现装配）。
- 网关前缀端到端验证（canonical `/system/...` → 内部 `/smp/venue`、`/dept`、`/smp/labgroup`）与 MockMvc 之外的真实 HTTP 外壳。
- 数据库/Redis/M02、M03 交互：本任务不涉及，无需验证。
- 生产门禁（不得存在可达 501）与前端联调：属实现阶段。

## 十七、公共审计文件与 git 状态确认

- `docs/开发任务/10-全接口契约骨架覆盖审计.md` 与 `.json`：**未修改**（本任务未打开写入；仍由审计会话独占）。
- `docs/开发任务/05-PKG-01-ADJUST接口契约差异审计.*`、06—13 报告、00 清单、`Controller请求调用时序设计.md`、`物理接口与骨架字段设计.md`、`详细设计.md`：**只读引用，未修改**。
- 仓库根 `_tmp_*` 文件：**未创建、未修改、未删除**。
- **未执行任何 `git commit`／`git push`**；未使用 `git checkout`／`reset`／`stash` 等可能影响他人变更的命令。暂存区未被本任务改动（`git status` 中本任务文件仍为工作区未跟踪/已修改状态）。

## 十八、遗留阻塞与后续建议

1. **BLK-02 仍为设计阻塞**：018/020/030 的场地/部门删除与重挂需 M02/M03 侧引用事实（课程、实验、库存等占用），当前无可注册的只读 Port；本任务只保留接口位与显式 501，实现阶段需先冻结 Port 契约。
2. **守卫与幂等回执未接线**：写接口仅预留字段位，实现阶段需按 PRE-01B/C 接 `ManagementGuardExecutor` 并回 `ChangeView` 回执。
3. **`@Log` 待回挂**：9 个写入口的 `@Log` 已按纪律移除，业务实现阶段接回。
4. **旧路由处置**：10 条未登记旧路由（含 `PUT /smp/labgroup/{groupId}/members`、`/dept/list`、`/smp/venue/list` 等）仍走旧 Service 且返回实体形状，属 TASK-ROUTE 范围；其 `TableDataInfo`/实体输出不在本任务修正之列。
5. **`GroupListQuery` 分页语义**：024 冻结外壳为 `List<GroupRow>`（§18 ORG12 Q+F），但携带 pageNum/pageSize 字段；实现阶段需确认是「列表 + 前端分页」还是改为 `PageResult<GroupRow>`，该分歧属设计侧，本任务不擅自改外壳。
6. **审计统计待刷新**：10 审计中这 14 条仍记为 `PARTIAL_SKELETON`（缺冻结 DTO/缺骨架方法/未预留 WriteMeta/旧外壳直出/旧链路），本任务已消除上述缺口，但统计文件按所有权约定不由本任务更新，请由审计会话在收口后重跑。
7. **统一时段验证**：请协调者在四包收口后执行 Maven 编译与本包 31 项测试及 TASK-COMMON/TASK-USR/PKG-01 回归；如出现失败，按报告第十五节的核验层级如实回写结论，不得以静态检查冒充通过。
