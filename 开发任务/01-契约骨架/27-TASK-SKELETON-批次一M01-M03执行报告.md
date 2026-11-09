# 27-TASK-SKELETON-批次一（M01—M03）契约骨架执行报告

- 任务：全系统接口契约骨架补齐（TASK-SYS-SKELETON）批次一
- 日期：2026-09-20
- 范围：M01 防回归 + M02、M03 契约骨架生成 + 门禁测试 + 共享引擎/门禁修正
- 冻结来源：`docs/开发任务/00-全接口契约骨架清单.json`（canonical，`TARGET:` 前缀剥离后使用）

## 一、结果总览

| 模块 | brief 条目 | blocked | 生成条目 | 门禁预期(expectedCount) | 结果 |
|---|---|---|---|---|---|
| M02 | 255 | 2（M02-003、M02-004） | 253 | 253 | 5 项门禁全绿 |
| M03 | 43 | 0 | 43 | 43 | 5 项门禁全绿 |
| M01 | 76（存量） | — | 不重生成 | — | 23 项契约测试全绿（防回归通过） |

- M02：DTO/VO/枚举类 446、ApplicationService 35、骨架 Impl 35、Controller 35（既有文件入口改写，
  新增 3 个 Controller 文件：`LabObservationController`、`LabEngineeringProfileController`、
  `LabControllerModelVerificationController`）。
- M03：类 123、ApplicationService 10、Impl 10、Controller 4（`ResProjectController`、
  `ResCultureController`、`ResBatchController`、`ResGrantController`）。
- conflicts=0，problems=0；条目数锚点 = brief 条目数 − blocked，由包装测试
  `EXPECTED_ENTRIES` 独立断言（反空转）。

## 二、BLOCKED 登记（不阻塞其余接口）

1. `M02-003`（OBS-Q03）：响应另含“有权处理/关联版本索引”，索引字段名与结构未逐项冻结
   （《在线业务观测存储与查询契约.md》§4）。
2. `M02-004`（OBS-Q04）：隔离/冲突脱敏摘要行结构仅有语义与禁输出约束，未冻结字段清单；
   receipt/conflict 内部列不得直接外发。

## 三、骨架边界事实（与既有 GUARD 交付的关系）

- 全部管理写入口仅接线应用服务；未调用 `ManagementGuardExecutor.execute`、未触达
  AuditIntent/回执/`@ManagementGuardedWrite`；骨架 Impl 零声明字段、每方法唯一
  `throw new SkeletonNotImplementedException(contractId)`。
- 旧 Service 端口重定向：255 条冻结链指向存量 `I*Service`/`impl` 的条目统一改落
  `service.application.m0x.*ApplicationService`（原名保留在 `service_interface_original`），
  生成器写入门禁拒绝任何非 `application` 包 Service 落盘。本批次据此恢复且未再触碰
  `IResBatchService`/`ResBatchServiceImpl`/`IResCultureService`/`ResCultureServiceImpl`
  （上一轮曾被误覆盖，已按 HEAD 内容恢复，现无净变更）。
- 非标识符取值表枚举（7 个：RelayStatusValue、DetectorCarrierType、DetectionRuleItem、
  LabType、LabStatus、ConsumptionDetectClass、ConsumptionItemType）按冻结取值以 String
  承载并在字段 note 登记取值表，未虚构常量名。

## 四、本批次发现并修正的生成器/门禁缺陷（对批次二/三直接生效）

1. `renderClass` 缺失跨包类型 import（DTO 引用 VO 包枚举/行类型编译失败）。
2. `@RequestMapping({"a","b"})` 数组形式类前缀不可解析 → `classRequestMappings()` 多前缀尝试。
3. PATCH 未计入 body 动词（`patchBasic` 引用未声明变量）→ 控制器绑定 + 引擎 MockMvc/mappingOf 补 PATCH。
4. DELETE 可选 `@RequestBody(required = false)` 无空体守卫 → 绑定 null 时 `new X()`；28 个存量
   生成方法已同步补守卫（无请求体的 DELETE 曾因 NPE 落入通用异常处理返回 200）。
5. `SkeletonEngine` 同名遮蔽/重载按方法名盲选 → `selectMethod` 以契约 Request 类型唯一定位
   （list/export 同名重载、legacy 同名 `edit` 两类真实形态）。
6. `checkHttp501` fail-fast 不带编号 → AssertionError 纳入聚合违例并携带契约编号。
7. 生成 Impl 注释含 “Mapper/ManagementGuardExecutor” 字样触发文本门禁误报 → 注释改写（45 文件）。
8. View 敏感字段判定从子串收紧为 String 声明正则：契约冻结的脱敏布尔
   （`hasInterfacePassword`/`passwordConfigured`）不再误伤，String 凭据检出能力保留。
9. 生成过程在“已生成态”上重跑会因 legacy 同名方法遮蔽产生重复追加 → 固化规程：
   HEAD 恢复受治文件 → 清理生成器自有未跟踪文件 → 单次生成。

## 五、门禁检出能力反例（fixture 证据）

- `SkeletonEngineShadowFixtureTest`（6 项）：正确条目在遮蔽/重载下放行；映射漂移、权限漂移、
  返回类型漂移、非 501 重载、错误契约编号 5 类违例全部被拦截。
- `FullSystemSkeletonGateTest#detectorsThemselvesWork`：新增“脱敏布尔 View 不误报”“非 View
  凭据输入不误报”反例，String 凭据/实体导入/注入 Impl 正例检出保持不变。
- `SkeletonEngine.selectMethod` 残余歧义不做循环放行：仍由映射/权限/返回断言暴露。

## 六、分层验证结论

| 层级 | 命令/对象 | 结果 |
|---|---|---|
| 静态（源码门禁） | FullSystemSkeletonGateTest 4 项（零注入/唯一501/敏感字段/M08排除+反空转） | 通过 |
| 编译 | `mvn -pl futurefab-modules/futurefab-system -am test-compile -o` | 通过 |
| 单元/契约（反射） | M02/M03 各 5 项（路由/接线/501/形状/HTTP）| 253+43 条目全绿 |
| MockMvc（standalone） | `http501EnvelopeForEveryEntry`（501+NOT_IMPLEMENTED+contractId） | 全绿 |
| M01 防回归 | M01SystemSkeletonContractTest 等 6 个 M01 契约测试 | 全绿 |
| 模块全量 | `mvn -pl futurefab-modules/futurefab-system -am test -o` | Tests run: 434, Failures: 0, Errors: 0 |
| 真实环境 | 未连接 MySQL/Redis/网关/外部系统；无 HTTP 联调、无现场验收 | 未执行（不作宣称） |

## 七、遗留与移交

- 批次二（M04—M07）、批次三（M09 + 跨模块 Port 收口）、26/30 汇总清单仍待执行。
- 工作区纪律：未执行任何 git commit/push/reset/checkout；GUARD 系列 7 个跟踪文件与
  并行会话 `_tmp_*` 文件未触碰；`git status` 中除本任务生成面外无其他净变更。
