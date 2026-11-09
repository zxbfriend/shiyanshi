# 19-TASK-INTEGRATION-R1：M01-074 骨架修正报告

> 日期：2026-09-19／分支 cloud／基线：PRE-01B-R1（有效骨架基线，07 报告口径）
> 任务书：TASK-INTEGRATION-R1（修正 18 报告 §22 登记的唯一生产骨架缺陷 M01-074）
> 口径红线：**75 条接口契约骨架完成，M01-024 等待 G4 外壳裁决。**（不宣称 76/76，不宣称业务已实现）

## 一、R1 是否完成

**完成。** M01-074（GET /system/operlog/{operId}）已从错误链路调整为标准骨架链路并显式 501；
仅改动任务书 §三 允许清单内文件；未实现任何真实操作日志查询；未提交 Git。

## 二、原缺陷（TASK-INTEGRATION 登记回显）

18 报告 §22 / 10 审计原 M01-074 记录：Controller 组装冻结 `OperLogDetailQuery` 后，
调用的是**旧业务接口** `ISysOperLogService#selectOperLogById(OperLogDetailQuery)`，501 抛点位于
`SysOperLogServiceImpl`（旧 Service 实现）内，并在 `SysOperLogMapper` 上以 default 方法挂出
`"M01-074-MAPPER"` 伪编号——违反骨架门禁 8/14（入口必须经 `service/application/m01` 零字段
ApplicationService），且旧接口/旧实现被新契约方法污染（TASK-INTEGRATION 判定为生产代码缺陷，
按任务书不顺手修改，转本 R1 任务）。

## 三、最终链路（与骨架标准形态一致）

```
SysOperlogController#getInfo(@PathVariable("operId") String operId)   [SysOperlogController.java:43-54]
  → @RequiresPermissions("system:operlog:query")
  → SecurityUtils.isAdmin 服务端硬校验（非超管 NotPermissionException）
  → 组装 OperLogDetailQuery（冻结 DTO）
  → SystemLogQueryApplicationService#getOperLogDetail(query)          [接口 :20]
  → SystemLogQueryApplicationServiceImpl#getOperLogDetail             [实现 :31-35，零字段]
      throw new SkeletonNotImplementedException("M01-074")             ← 全仓唯一抛点
  → GlobalExceptionHandler → HTTP 501
      { code:501, errorCode:"NOT_IMPLEMENTED", contractId:"M01-074", requestId:… }，无 data 伪成功
```

## 四、新增方法与方法名裁决依据

- 接口：`OperLogDetailView getOperLogDetail(OperLogDetailQuery query);`（SystemLogQueryApplicationService）
- 实现：同名 `@Override`，单语句显式抛 `SkeletonNotImplementedException("M01-074")`；
  实现保持**零字段、零注入、无 null 返回、无 DB 触达、无脱敏逻辑**。
- **命名依据**：权威设计（接口目录 LOG03／物理接口与骨架字段设计／Controller 时序 定位074）只冻结
  路由、入参 `OperLogDetailQuery`、出参 `OperLogDetailView` 与权限口径，**未冻结应用端口方法名**；
  按任务书"如权威设计已有明确名称以权威设计为准，否则与现有命名风格一致"采用
  `getXxxDetail(XxxDetailQuery)` 仓库既成冻结风格（`getConfigDetail`/`getRoleDetail`/`getMenuDetail`/
  `getUserDetail`/`getDictTypeDetail`/`getDictDataDetail` 同构），与同端口 `listOperLogs` 前缀规则一致。

## 五、删除的"新契约重载"清单（错误接线回收）

| 文件 | 删除内容 | 保留内容（旧语义不动） |
| --- | --- | --- |
| ISysOperLogService.java | `OperLogDetailView selectOperLogById(OperLogDetailQuery)` 声明＋2 个 m01 import | `SysOperLog selectOperLogById(Long operId)`（legacy，旧链路仍在用） |
| SysOperLogServiceImpl.java | 上述重载实现（旧 Service 内抛 M01-074）＋3 个 import（含 SkeletonNotImplementedException） | `selectOperLogById(Long)`→Mapper 原实现 |
| SysOperLogMapper.java | `default OperLogDetailView selectOperLogById(OperLogDetailQuery)`（抛 `"M01-074-MAPPER"` 伪编号）＋3 个 import | `selectOperLogById(Long)` 声明；XML `selectOperLogById` 语句未动 |

全仓检索：`"M01-074-MAPPER"` 于 src/main 出现 **0** 次（仅契约测试负断言字面量 3 处）；
`SkeletonNotImplementedException("M01-074")` 全仓恰 **1** 处（m01 零字段实现）。
export/remove/clean/add 旧路由与 46 条未登记旧路由处置（TASK-ROUTE）未受影响。

## 六、权限边界（不放宽、不新造）

- 冻结注解 `@RequiresPermissions("system:operlog:query")` 原样保留（LOG03 契约），未新造任何权限字符串。
- 服务端超管硬校验保留：非超管在 Controller 边界抛 `NotPermissionException`，**不进入 AppService**；
   `"system:operlog:query:super-admin"` 仅是 NotPermissionException 的**消息载荷**（与 072/073
  `…:list:super-admin` 同构），不是注册的权限键。
- 契约测试未通过放宽该校验取绿：`operLogDetailRejectsNonSuperAdminBeforeSkeleton` 以 userId=2 断言
  NotPermissionException（异常类型即证明未抵达 501 端口）。

## 七、新增契约测试（M01SystemSkeletonContractTest，19→23 项）

任务书 §五 14 项要求的落位：

1. 路由存在＋动词/路径绑定：`systemRoutesAndHttpMethodsMatchFrozenContract` 追加 GET `/{operId}`；
2. `@PathVariable("operId") String`：同上新增注解断言；
3. 权限注解冻结复用：`permissionAnnotationsReuseFrozenDesign` 追加 `system:operlog:query`；
4. Controller 调用 SystemLogQueryApplicationService＋5. 不调用已删重载：
   `wiredMethodsOnlyCallApplicationServices` 追加 getInfo 方法体取证（必含
   `systemLogQueryApplicationService.getOperLogDetail`，禁含 `operLogService`/`selectOperLogById`/`SysOperLog `）；
6. 端口方法签名（OperLogDetailQuery→OperLogDetailView）＋11. Impl 零字段＋方法数恰 3：
   新测试 `operLogDetailSignatureMatchesFrozenContract`（原 `systemLogQueryServiceExposesOnlyTwoMethods`
   的"074 由旧 Service 承接"口径作废并改写）；
7. 编号 501：`operLogDetailAdminPathReachesExplicitSkeleton`；8. null 入参仍 501：
   `appServicesThrowForNullCommandWithoutTouchingCollaborators` 追加 `getOperLogDetail(null)`；
9. MockMvc 501 外壳：`operLogDetailRouteReturns501ForSuperAdmin`
   （status 501＋code＋errorCode=NOT_IMPLEMENTED＋contractId=M01-074＋requestId 为字符串＋`data` 不存在）；
10. 非管理员权限边界：`operLogDetailRejectsNonSuperAdminBeforeSkeleton`；
12. 旧 Service/Mapper 不再携带 OperLogDetailQuery 重载＋legacy Long 入口保留＋无 M01-074-MAPPER 残留：
    `legacyOperLogContractsCarryNoNewContractOverload`;
13. 072/073 无回归、14. 六包契约测试无回归：见 §八 全量结果。

## 八、测试结果（串行执行，2026-09-19）

| 门禁 | 命令 | 结果 |
| --- | --- | --- |
| system 全量 | `mvn -pl futurefab-modules/futurefab-system -am test` | **Tests run: 269, Failures: 0, Errors: 0, Skipped: 0，BUILD SUCCESS**（≥265 达成；M01SystemSkeletonContractTest 23 项含 5 项新断言组实际执行） |
| auth 回归 | `mvn -pl futurefab-auth -am test` | **14/14 绿，BUILD SUCCESS**（TokenControllerSkeletonContractTest 无回归） |
| 空白检查 | `git diff --check` | 退出码 0 |
| JSON 可解析 | node JSON.parse | OK；interfaceId 去重 76/76 |
| 编号唯一 | 全仓 grep | `SkeletonNotImplementedException("M01-074")` 恰 1 处；`M01-074-MAPPER` src/main 0 处 |
| MD↔JSON 同源 | 程序化字段级比对 | 76 个明细块逐字段一致；汇总 75/1 实算一致（临时脚本已删除） |

## 九、审计文档更新（10-audit JSON＋MD）

- 仅 M01-074 记录按新源码证据逐字段重写：conclusion→`COMPLETE_SKELETON`；
  applicationServiceInterface/Skeleton、currentCallChain、notImplementedStatus、responseShell、
  mayWriteDatabase、evidencePathsAndLines（改指 m01 链路 :43-54/:20/:31-35＋契约测试＋本报告）、
  gapDescription（转业务阶段脱敏投影缺口）、suggestedFixTaskPackage、actionCode/blockerRefs 原样。
  旧"经 ISysOperLogService 承接"证据全部清除。
- 汇总程序化重算：**COMPLETE_SKELETON 74→75、PARTIAL_SKELETON 2→1、total 76**；
  联动更正：contract_drifts 074 条目收口注记、task_packages（TASK-COMMON 描述＋TASK-INTEGRATION-R1
  已完成口径）、recommended_order 0/5、acceptance_gates（G2/G5/G6/G11/G12＋新增"R1 M01-074 修正收口"行）、
  meta.method R1 层级声明；MD §一/§四/§五/§六/§十一/§十三/§十五/§十六/§十七 同源同步。
- **M01-024 与 G4 内容保持原样**（判定分布中仅作为唯一 PARTIAL 出现，未顺手改判）。

## 十、范围与红线自查

- 是否修改 XML／SQL／Vue／客户只读材料／开发基线：**否**（0 个此类文件被触碰）。
- 是否实现真实操作日志查询、接入 ManagementGuardExecutor/ActorContextPort/ManagementAuditHook、
  触碰 BLK-02/03/04b/04c、46 条旧路由或 PRE-01A/B 交付物：**否**。
- 是否改动其余 75 条接口源码：**否**（R1 生产/测试改动文件共 7 个，全部在任务书 §三 清单内：
  SysOperlogController、SystemLogQueryApplicationService(+Impl)、ISysOperLogService、
  SysOperLogServiceImpl、SysOperLogMapper、M01SystemSkeletonContractTest）。
- Git 状态：**未提交、未推送**；未执行 reset/checkout/restore/clean；用户既有未提交变更未回退。

## 十一、验证层级与未执行事项

已达成层级：静态源码取证＋编译＋单元/MockMvc 契约测试（本地串行）。
未执行（不得引用为本任务通过）：真实 HTTP 联调、MySQL/Redis 实库、JWT/网关链路、浏览器验收、
外部系统联调。X-Request-Id 走 MockMvc 过滤器链为组件级验证，非网关运行验证。

## 十二、遗留与下一步

1. **M01-024**：唯一 PARTIAL，等待 **G4 响应外壳裁决**（00清单 List\<GroupRow\> vs §17.1 rows/total）；
   裁决后回归本审计即可翻绿。
2. G1/G2/G3 阶段门、BLK-02/03/04b/04c：阻塞真实实现，不阻塞骨架。
3. TASK-ROUTE：46 条未登记旧路由处置＋M01-049 根路径收敛（需用户裁决）。
4. 业务实现阶段：074 脱敏投影（operParam/jsonResult/errorMsg 截断、changes 白名单快照）按 05 §9 接线。

当前口径：**75 条接口契约骨架完成，M01-024 等待 G4 外壳裁决。**
