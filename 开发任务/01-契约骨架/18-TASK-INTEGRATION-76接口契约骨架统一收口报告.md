# 18-TASK-INTEGRATION-76接口契约骨架统一收口报告

> 日期：2026-09-19／分支 cloud／基线：PRE-01B-R1（07 报告）；08/PRE-01C 为已撤回历史材料不作依据。
> 任务定位：骨架集成审计与公共文档收口（TASK-INTEGRATION），非业务实现。逐条取证不允许抽样；不顺手修改生产代码。

## 1. TASK-INTEGRATION 是否通过

**审计与收口任务本体：完成。** 76 条接口全部按 24 项门禁逐条程序化取证＋人工判定，公共审计（10）已从 38/38 更新为真实数量并逐字段同步。
**但“76 条全部 COMPLETE_SKELETON”的收口预期未成立**：按源码证据与权威文档裁决，真实结果为 **COMPLETE_SKELETON=74 / PARTIAL_SKELETON=2**。按任务书 §七，不硬改 76/76，输出真实数量。本阶段结论只能表述为：74 条接口契约骨架完成并取证闭合；其余 2 条分别因设计未闭合（M01-024）与骨架接线缺陷（M01-074）保持 PARTIAL。

## 2. 实际审计接口数

76 条（M01-001～M01-076），逐条核验 24 项门禁，无抽样；interfaceId 唯一、编号 001～076 无空洞（程序化校验 0 异常）。

## 3. ADJUST / NEW 数量

ADJUST=58、NEW=18（合计 76，与 00 机读清单 M01 子集完全一致；路由/动词双向核对 76/76 EXACT）。

## 4. 收口前后状态统计

| 状态 | 收口前 | 收口后 |
| --- | --- | --- |
| COMPLETE_SKELETON | 38 | **74** |
| PARTIAL_SKELETON | 38 | **2**（M01-024、M01-074） |
| MISSING_SKELETON / CONTRACT_DRIFT / OVER_IMPLEMENTED / BLOCKED_DESIGN | 0 | 0 |

统计全部由 JSON 逐条实算生成，MD §一/§四/§六与 JSON 同源（程序化字段级比对 0 差异）。

## 5. 38 条原 PARTIAL 逐条处置结果

- **37 条 → COMPLETE_SKELETON**：TASK-ORG 13 条（014/015/016/018/019/020/025/026/028/030/031/032/033）、TASK-ACL 10 条（036/037/039～046）、TASK-DIC 9 条（058～066）、TASK-CFG 5 条（067～071，其中 070 的「无注解」过时证据随源码一并更正）。每条均以“冻结 DTO 直收→m01 ApplicationService→零字段骨架显式 501”新源码证据翻绿，18 字段全量重写（conclusion/requestDto/responseView/applicationServiceInterface/applicationServiceSkeleton/currentCallChain/notImplementedStatus/mayWriteDatabase/returnsFakeSuccess/reusesLegacyEntityAsRequest/directlyReturnsEntity/sensitiveFieldLeakRisk/writeMetaReservedInSource/evidencePathsAndLines/gapDescription/suggestedFixTaskPackage/blockerRefs/actionCode）。
- **M01-024 → 保持 PARTIAL_SKELETON**：接线本身已完成并显式 501，但响应外壳权威口径未闭合（§7）。
- **另：M01-074（原 18 NEW COMPLETE）→ 降级 PARTIAL_SKELETON**：收口取证发现真实接线缺陷（§25 前置说明＋第 22 节缺陷登记）。
- 附带刷新：TASK-COMMON/TASK-USR/NEW 已 COMPLETE 记录中 28 处过时字段（reusesLegacyEntityAsRequest「是：DTO 不存在」类）按源码更正为「否（冻结Command/Query直收）」；responseShell 口径行全局更新；M01-070 permissionAnnotation 证据按源码更正（详见 §10/§16）。

## 6. 76 条是否全部唯一编号化 501

是。程序化全仓扫描：`SkeletonNotImplementedException("M01-nnn")` 抛出点 76 个编号一一对应、无重复、无多余；其中 75 条位于 m01 零字段 ApplicationService 实现（含 auth 模块），M01-074 位于旧 Service 实现内（缺陷已登记，接口保持 PARTIAL）。无 null/空 List/0/true/success 伪成功出口。

## 7. M01-024 最终裁决及依据

**裁决：保持 PARTIAL_SKELETON（设计未闭合，新增阶段门 G4）。** 证据层级=接口目录→模块内部接口设计→Controller 时序设计→公共契约：
- 接口目录与契约定位.md:5 将字段级权威委托 00 机读清单：`List<GroupRow>`（data 直出）；
- 详细设计 §17.1（详细设计.md:820-824）：列表外壳=rows+total、不返回 data（分页口径）；GroupListQuery 仍含 pageNum/pageSize；
- 00 物理接口表自身两处口径并存，机读链内部不完全自洽。
权威文档互相冲突且无法按层级唯一裁决 → 按任务书 §五.1 不得为 76/76 强行通过。骨架五层接线（Controller→GroupQueryApplicationService→501）已完成并如实登记；裁决落地若需改 Controller/View/DTO 属生产代码，须随 R1/业务任务执行。

> **TASK-G4 补记（2026-09-19）**：本节为当时裁决记录，保持原样。G4 阶段门已由 TASK-G4 闭合：裁决响应外壳=公共分页外壳 `PageResult<GroupRow>`（顶层 rows/total/pageNum/pageSize，先权限/数据范围过滤再计数分页）；复核确认主设计 §17.1、接口目录与 024 时序口径彼此同义，00 清单 response_vo 与《物理接口与骨架字段设计》字段表的 `List<GroupRow>` 属转录错误、已勘误（非需求新增）。M01-024 判 COMPLETE_SKELETON，详见 docs/开发任务/20-TASK-G4-M01-024分页外壳裁决与最终收口报告.md。

## 8. M01-044 / M01-071 最终裁决及依据

**裁决：DeleteResult 为 PKG-00 冻结的独立语义类型，允许并要求使用；两接口判 COMPLETE_SKELETON。** 依据：DeleteResult={requestId,managementRevision,removedIds} 与 W（applied/id/affectedIds/managementRevision）字段集与语义均不等价（无 applied/无 objectVersion），亦≠MutationResult；00 机读清单 response 字段为解析权威（接口目录 §5 授权）。§17.1「data=W」为早期代际措辞，与机读链冲突处已登记 contract_drifts，转设计侧文本勘误（不在本任务改写详细设计）。附带登记：M01-053 的 13 报告裁决（复用 MutationResult）与 00 清单 response_vo=DeleteResult 属同类冲突，本收口不改动既有 COMPLETE 结论，留待设计侧统一裁决。

## 9. M01-066 最终权限裁决及依据

**裁决：COMPLETE_SKELETON，权限口径登记为「已认证（网关强制）＋复合判定转业务阶段」。** 取证：futurefab-gateway AuthFilter（GlobalFilter order=-200）白名单仅 /auth/login、/auth/aad/**（nacos-config/futurefab-gateway-dev.yml），匿名请求在网关层即被拒；骨架入口不挂函数权限注解（与冻结契约一致，契约测试锁定不发明新权限字符串——11 报告 070 同型先例）。「已认证且业务使用该字典或 system:dict:query」的复合判定需字典使用登记表（未冻结），属业务阶段授权点，登记于 permissionVerdict 与 gapDescription，不构成骨架虚假完成。

## 10. Controller / DTO / View / ApplicationService 覆盖结果

- Controller 入口：76/76 存在且路由/动词与 00 清单一致；权限注解逐条与冻结契约比对一致（NE/ABSENT 均有登记口径）。
- 冻结 DTO/View：原登记缺失 83 个文件（57 DTO＋26 View）已**全部落地**（按文件名全仓核验 0 残留，JSON missing_files 清空并登记 missingFilesNote）。
- ApplicationService：75/76 经 service/application/m01 接口＋零字段骨架实现（Impl 零依赖字段核验通过）；M01-074 未经 m01 层（§22 缺陷）。
- ID 十进制 String、时间冻结类型/ISO-8601 口径、View 无 password/delFlag/params 禁字段（CurrentIdentityView.password 为 D1 冻结 PasswordStateView 状态对象，非口令，人工复核成立）。

## 11. 是否存在旧 Entity 直出

76 条骨架入口：0。骨架出口显式 501 不回显数据；响应类型均为冻结 View/Result（无 Sys* Entity、无自由 Map）。46 条未登记旧路由的旧语义不在本收口范围（TASK-ROUTE）。

## 12. 是否存在旧 Service / Mapper / Redis 调用

骨架入口：0（除已登记的 M01-074：Controller→ISysOperLogService 旧 Service 接口冻结方法内抛 501，未经 m01 ApplicationService，违反门禁 8/14）。76 Controller 对 Mapper/RedisService/RedisTemplate/DictUtils 直连引用 0；ManagementGuardExecutor/ActorContextPort/ManagementAuditHook 引用 0。

## 13. 是否存在伪成功

0。M01-010/011 旧 logout/refresh 的 R.ok() 遗留语义已随 TASK-COMMON 接线消除为显式 501；全量纯 501 方法体核验通过。

## 14. 是否存在提前实现业务

0。全部骨架实现零字段、单语句抛编号异常；未接入守卫/幂等/真实审计/快照时序（PRE-01B-R1 边界保持）；无真实 SQL 新增。

## 15. WriteMeta 边界核验结果

写口 Command 全量预留 requestId/managementRevision 字段位（不接守卫/幂等执行）；读 Query 无一混入 WriteMeta；非法 X-Request-Id / 非十进制 managementRevision 在 400 INPUT_INVALID fail-closed（PRE-01A）。程序化 76/76 通过。

## 16. 安全泄漏回归结果

M01ResponseLeakGuardTest 13、ConfigDetailViewMaskingTest 6、M01UserSkeletonContractTest/M01SystemSkeletonContractTest 泄漏断言全部通过；049/055/075 口令哈希不出现在响应 View；070 维持 @RequiresPermissions("system:config:query")＋ConfigDetailView fail-closed（configValue 恒 null、sensitive=true，BLK-04b 分类能力转业务阶段）；072/073/074 超管硬校验保留。文档证据更正：10 审计中 070 的 permissionAnnotation 原登记「无注解」已过时，按源码更正为冻结串 system:config:query（属纯文档证据错误修正，未动代码）。

## 17. 46 条旧路由边界声明

46 条未登记旧路由（源码→清单差集）全部原样保留，处置登记仍属 TASK-ROUTE（用户裁决 DISABLE/COMPAT/移除）；M01-049 根路径双映射保留等待 TASK-ROUTE 收敛，本任务未删除、未修改。

## 18. BLK-02 / 03 / 04b / 04c 状态

均 OPEN 且仅阻塞真实实现，不否定已完成 501 骨架（各接口 blockerRefs 保留）：BLK-02 场地/部门删除引用 Port 未登记；BLK-03 DICT_KEY_IN_USE 跨模块检查无 Port；BLK-04b 通用敏感键注册表未冻结；BLK-04c M07 值域登记未冻结。阶段门 G1（审计映射/快照时序）、G2（SEC-I01）、G3（实验室范围）维持 OPEN；**新增 G4：M01-024 响应外壳未闭合**。

## 19. 测试数量与结果（串行执行）

- `mvn -pl futurefab-modules/futurefab-system -am test`：**Tests run 265, Failures 0, Errors 0, Skipped 0，BUILD SUCCESS**（≥265 要求满足）。关键套件：M01Org 31／M01Acl 19／M01Dict 26／M01Config 20／M01User 20／M01System 19／泄漏 13＋6／PRE-01A 适配 34（ShellAdapter 28＋Filter 6）／PRE-01B 守卫 48（Executor 23＋Hasher 13＋HasherContext 3＋Operation 3＋Adapter 4＋Config 2）／WriteMeta 9＋PortSignature 5＋错误码 3＋Auth 反射 3＋CommonShell 6＋501 映射 3。
- `mvn -pl futurefab-auth -am test`：**Tests run 14, Failures 0, Errors 0，BUILD SUCCESS**（TokenControllerSkeletonContractTest 14，TASK-COMMON 会话骨架无回归）。
- `git diff --check`：退出码 0，无空白错误。
- 覆盖判定：TASK-COMMON/USR/ORG/ACL/DIC/CFG 契约测试全绿；SECURITY-P0 泄漏防护全绿；PRE-01A/PRE-01B 无回归。

## 20. 未执行环境验证

未执行：真实 HTTP 服务、MySQL、Redis、JWT 登录链路、浏览器、网关运行实例、外部系统/设备联调。本报告仅声明**编译、单元测试、MockMvc 契约测试**层级通过；不得引用为运行/联调/验收通过。

## 21. 修改文件清单（本任务）

1. `docs/开发任务/10-全接口契约骨架覆盖审计.json`（收口更新：76 条逐字段同步、状态汇总、missing_files 清零、contract_drifts＋5、task_packages/推荐序/门禁自检/阻塞项 G4）
2. `docs/开发任务/10-全接口契约骨架覆盖审计.md`（由更新后 JSON 程序化同源重渲染＋同步章节改写，新增 §十七收口说明）
3. `docs/开发任务/18-TASK-INTEGRATION-76接口契约骨架统一收口报告.md`（本文件，新增）
4. 临时只读取证/渲染/校验脚本 `integration_gate_scan.tmp.js`、`integration_gate_rows.tmp.json`、`integration_update.tmp.js`、`integration_md.tmp.js`、`integration_verify.tmp.js`——**验收后已全部删除，不属于交付物**；未新增集成测试类（24 门禁取证由既有各包契约测试＋本任务临时脚本完成，取证结论固化于审计 evidencePathsAndLines）。

## 22. 是否修改生产源码 / 发现的骨架缺陷

未修改任何 Java/XML/SQL/Vue。发现并登记生产骨架缺陷 **1 项**：

- **M01-074（GET /system/operlog/{operId}，缺陷登记 DEF-INT-01）**：SysOperlogController.getInfo 组装 OperLogDetailQuery 后经旧 Service 接口 `ISysOperLogService.selectOperLogById` 抛 501（SysOperLogServiceImpl.java:25），未经 m01 `SystemLogQueryApplicationService`（无对应方法位、无零字段骨架实现、无该入口 MockMvc 501 断言）。违反门禁 8/14。影响：调用链分层与新契约注册口径；运行表现仍为显式 501、无写库、无伪成功。处置：接口保持 PARTIAL_SKELETON，原登记链证据已按实更正，修正**必须另开 TASK-INTEGRATION-R1**（生产代码改动不在本任务范围）。

## 23. 是否修改 SQL / Vue / 客户材料

否。未触碰开发基线 SQL、mapper XML、前端 futurefab-ui、docs/接口文档等客户只读材料。

## 24. 是否提交 Git

否。全部改动保留在工作区（与本任务前既有未提交变更共存，未回退、未清理用户材料）。

## 25. 下一步建议

1. **TASK-INTEGRATION-R1**（小批）：修正 M01-074 接线（入口改经 SystemLogQueryApplicationService＋零字段骨架实现抛 "M01-074"＋补 MockMvc 501 断言），完成后 74→75。
2. **G-阶段门裁决**：G4（M01-024 响应外壳 List vs rows/total）、053/§17.1 与 P/DeletePrecheckResult 机读链-文本统一设计勘误、G1/G2/G3；024 裁决落地后回归收口（75→76）。
3. **TASK-ROUTE**：46 条未登记旧路由处置登记＋M01-049 根路径收敛（需用户裁决）。
4. 上述完成后，契约骨架即 76/76 闭合，可进入**业务实现任务拆分**（守卫/幂等/审计接线与真实查询写入按 05 §9 与各模块时序落地；BLK-02/03/04b/04c 须先行或同步裁决）。
5. 措辞边界：在 R1 与 G4 闭合前，不得表述“76 条接口契约骨架完成”；本收口仅支持“74 条完成、2 条按证据保持 PARTIAL”。任何情况下不得表述“系统开发完成/接口业务已实现/可以直接上线/数据库与外部系统已经验收”。
