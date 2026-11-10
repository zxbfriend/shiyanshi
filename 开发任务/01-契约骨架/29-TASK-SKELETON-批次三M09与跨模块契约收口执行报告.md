# 29-TASK-SKELETON-批次三 M09 与跨模块契约收口执行报告

- 任务：全系统接口契约骨架补齐（TASK-SYS-SKELETON）批次三 = S4（M09 骨架 + 跨模块 Port 收口 + 交叉门禁）
- 依据：`docs/开发任务/00-全接口契约骨架清单.json`（冻结 532 条，非 M01=456）、`docs/开发任务/01-契约骨架/02-PKG-00公共契约与Port物理签名设计.md` §6/§9、AGENTS.md
- 执行时间：2026-09-20
- 状态：批次三完成；M09 21/21 落码，blocked 0；跨模块 Port 与交叉门禁收口全绿；全模块套件 463/463 通过（编译+单元/MockMvc 层，未连接真实 MySQL/Redis/网关/外部系统）

## 1. 结果总览

| 口径 | 数值 |
| --- | --- |
| M09 冻结条目 / 落码 / blocked | 21 / 21 / 0 |
| M09 生成类（DTO/VO/枚举） | 96（dto/m09=18、vo/m09=78 文件） |
| M09 应用服务端口 + Impl | 10 + 10（`service/application/m09`、`service/impl/application/m09`） |
| M09 新建 Controller | 10 个 `Alarm*V2Controller`（与存量旧 Alarm*Controller 并存，canonical 路由各自独立） |
| 旧 Service 落点重定向（冻结链 → m09 应用端口） | 21/21（同批次二口径，登记于生成报告 redirected） |
| 门禁条目（skeleton-m09.json） | 21 = expectedCount 21（反空转锚：brief 21 − blocked 0） |
| M09 包装测试 | `M09SkeletonContractTest` 5 项全绿（路由权限/接线签名/编号501/形状/HTTP 501 信封） |

## 2. 跨模块 Port 收口

### 2.1 冻结 Port 本体（PKG-00 已交付，本批次复核）

- `service/port/m0{1..9}` 共 43 个 `*Port.java`，git 跟踪且工作区干净；`service/port/m0x/model/**` 模型齐备。
- 71 个内部契约的物理签名由存量 `PortSignatureSnapshotTest` 逐行冻结校验（接口存在、方法集精确、单 Request/单 Response、模型落 `service.port.m0x.model`、禁 Object/Map 退化、无 m08 Port 包），本批次纳入全量套件回归通过。

### 2.2 provider 适配口径（本批次决策：登记未接线）

- 任务书允许"provider 适配显式 501 或登记未接线"。因骨架 Impl 为零注入、不得伪接线，选择**登记未接线**：
  - `service/impl/port` 下仅存在 INFRA-ACTOR 已验收的 m01 适配器（`M01ActorContextAdapter`、`M01ManagementRevisionSourceAdapter`），其余模块 Port 无 provider 实现类；
  - 新增源级门禁 `FullSystemSkeletonGateTest.portAdaptersStayUnwiredExceptM01Actor`：骨架阶段一旦出现 m01 之外的 Port 适配实现即失败（防"伪接线成功"）。

### 2.3 同源收口锚点

- 新增测试资源 `src/test/resources/contract/port-closure-anchor.json`（脚本从 00 冻结清单 + `_tmp_skelgen/spec/*.json` 的 in-record `blocked` 登记同源生成）：
  - 冻结非 M01 总数 456；blocked 合计 17（M02=2、M04=7、M05=6、M07=2，编号逐项登记，与报告 27/28 一致）；门禁条目期望 439。
- 新门禁 `contractIdsAndRoutesGloballyUnique`：跨 7 个 skeleton-mXX.json 汇总校验条目总数=439 锚点、contractId 全局唯一、同 (verb, 模板归一路径) 无重复（跨模块路由互撞口径，单模块 checkHttp501 之外的全局补位）。
- 新门禁 `blockedContractsHaveNoGeneratedEntries`：17 个 blocked 契约编号不得出现在任何生成条目资源中（blocked 与落码互斥）。

## 3. 交叉门禁扩展（FullSystemSkeletonGateTest 7 项）

| 门禁 | 判定 | 取证 |
| --- | --- | --- |
| generatedCodeImportsStayInOwnModule | domain/service 生成骨架目录 + `controller/run` 内，`domain.(dto|vo)/service(.impl).application` 的 m0x import 必须与文件自身模块一致（Port、common 豁免） | 实际扫描命中 0 违例；正反例 fixture 证明可检出（m02 引 m03 必炸、同模块/common/port 不误伤） |
| contractIdsAndRoutesGloballyUnique | 439 同源锚 + 全局 contractId 唯一 + 全局路由模板唯一 | 命中即列出重复项 |
| blockedContractsHaveNoGeneratedEntries | blocked 登记 ⇔ 生成条目互斥 | 17 编号逐项断言 |
| portAdaptersStayUnwiredExceptM01Actor | Port provider 未接线口径 | 见 §2.2 |
| m08IsFullyExcluded（口径修正） | 无 m08 骨架目录 + 源码不引用 M08；**冻结取值表枚举常量行豁免** | M09 `SourceModule={M01..M09,ADAPTER}` 为 `docs/详细设计/09-告警与通知管理/数据库JSON与事务契约.md#L9` 冻结取值，属契约值域而非 M08 实现引用；豁免仅针对"独立大写常量行"，代码行 M08 类型引用仍检出（正反例 fixture 成对） |
| dtoAndVoCarryNoEntityMapperOrSensitiveFields / applicationServicesAreZeroFieldNumbered501Only | （存量）骨架禁 Mapper/Entity/Redis/守卫/事务；Impl 零字段、唯一编号 501 | 存量自检测试保留 |

反空转纪律：所有新判定器均在 `detectorsThemselvesWork` 合成样本上证明检出能力，命中 0 不宣称"已验证真实链路"。

## 4. 生成器与门禁缺陷修正（每项均有真实失败反例）

1. **NoBody 单例语义**（两处）：
   - `ctrl-edit.js` 生成调用参数 `new NoBody()` → `NoBody.getInstance()`（NoBody 构造私有，PKG-00 冻结）；编译失败实证（3 个 V2 Controller "private 访问控制"）。
   - `SkeletonEngine.checkImplThrows501` 反射入参改走 `newArg()`：NoBody 取 `getInstance`，其余 `getDeclaredConstructor().newInstance()`；测试失败实证（M09-004/006/018 IllegalAccessException）。修正后 M09 5 项全绿。
2. **M08 门禁误伤冻结枚举**：`m08IsFullyExcluded` 纯子串判定命中 `vo/m09/SourceModule.java`（真实测试失败输出为证）→ 抽为 `detectM08Reference` 纯函数 + 常量行豁免 + 正反例 fixture。
3. Java 语法附带：`newArg throws Exception` 收窄为 `ReflectiveOperationException`（编译失败实证）。

## 5. M09 规范化登记（与批次二同口径）

- autoAdded 3 项（冻结路由路径变量绑定补齐）：M09-003 `alarmId`、M09-016 `deviceId`、M09-021 `deliveryId`（均 String，登记于生成报告 notes）。
- unionFields / mergedConflicts / enumUnions / renamedFields / collisionFqcn / legacyShadow：M09 均为 0（合并 0 problems）。

## 6. 验证分层

| 层级 | 结果 |
| --- | --- |
| 文档存在/链接 | 本报告引用的 00 清单、02-PKG-00、09 设计条款均实读核对 |
| 静态检查 | 生成脚本 0 problems；blocked↔条目互斥脚本核验（456−17=439=实扫条目和） |
| 编译 | `mvn -pl futurefab-modules/futurefab-system -am test -o` BUILD SUCCESS |
| 单元/契约（定向） | M09 5 + FullSystemSkeletonGate 7 + SkeletonEngineShadowFixture 6 = 18/18 |
| 全模块套件 | futurefab-system `Tests run: 463, Failures: 0, Errors: 0`（批次一 434 + 批次二 20 + 批次三新增 9） |
| MockMvc | 各模块 wrapper `http501EnvelopeForEveryEntry` 全绿（standalone，不起真实服务） |
| 真实环境 | **未执行**：未连接 MySQL/Redis/Nacos/网关/外部系统；未做 HTTP 联调与现场验收 |

## 7. 遗留与后续

- M08 仅登记后续任务（00 清单/本门禁保证无骨架、无 Port、无实现）。
- blocked 17 条的路由前缀与形状冻结差异，待设计侧裁决后补生成（编号与原因见报告 27/28 及锚点资源 blockedIds）。
- Port provider 全部未接线（除 m01 两适配器），业务实现阶段按模块逐个接线并以真实契约测试替换 501 门禁。
- 下一步：S5（26-全系统接口契约骨架清单 JSON/MD 同源产出 + 报告 30 汇总 + 最终分层汇报）。
