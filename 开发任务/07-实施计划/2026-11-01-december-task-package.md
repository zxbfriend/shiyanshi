# 十二月上线：K01—K03开发任务包

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将D01—D08落实到可领取、可检查的实施任务，先完成不依赖现场协议的部分。

**Architecture:** 沿现有Controller → ApplicationService → Mapper/Port链实施；方案、培养、审批、任务和检测分别保留原有数据责任。外部协议缺口只限制对应设备分支。

**Tech Stack:** Java 17、Spring Boot、MyBatis、Vue 3、TypeScript、pnpm 8.6.2、JUnit、Vitest。

**Spec:** [现行范围](../../详细设计/00-范围与待核/00-十二月上线范围与澄清规则.md)、[现行对接入口](../../详细设计/00-范围与待核/00-十二月上线开发对接待核事项.md)、[D01—D08](../../详细设计/history/review/2026-11-01-V4-V51差异分析/26-K01-K03独立开发事项清单.md)、[I01—I05](../../详细设计/history/review/2026-11-01-V4-V51差异分析/25-K01-K03最小技术对接资料清单.md)。业务依据继续以需求原文、原型和最新有效澄清为准，本计划不成为平行需求基线。

## 2026-11-02 R01—R03专项进展

R01再次触发的后续原文/培训/附件核查见[专项证据](../../详细设计/history/review/2026-11-01-V4-V51差异分析/R01-再次触发依据核查-20261102.md)。通气链只作来源关联，不能自行作为每链独立次数预算；生成/执行计数时点及独立检测归属尚无完整依据。原文的重新计时不自动授予执行后的再次生成，培训“一天可能一次”也不冻结每日次数。实现时不得根据本包旧概括重置预算或补新默认规则。

R01逐类发生键、通气链及连续性证据已明确于M07 JSON/事务契约R01节；R02固定用途、SYSTEM共同锁、M03锁读及方案竞争结果已明确于同文R02节；R03四个可写输入/只读资源、数值来源及启停attempt已明确于开始培养详细设计R03节。P04不再笼统挂“共同守卫未设计”，P05不再沿补料输入假设实施。

尚保留R01的窄项：搅拌/微泡已经生成后的再次触发资格及独立检测另起通气链，需继续核原执行来源，不能将防重键或新样本当作次数授权。R02/R03为目标设计细化，不等于真实Port/OPC已接线；I01—I05仍各自限制物理调用及返回。不更改业务代码、SQL或客户原件，不提交推送。

## 2026-11-01技术契约收口补充

本包最初列出的技术设计准备项已有后续现行契约：M04存储契约第8.3节确定Config内容schema 2，第12.4节确定AUTO_CONTROL内容schema 2；M07新增规则第8—10节明确DTO/类型/运行接口，JSON事务契约明确ControlTaskSpec 5、控制评估3及并发事务，任务页面契约逐类登记状态和执行交付。以下步骤中的“建议版本/先收口”须以这些现行契约为准，不重新讨论已定技术编码。人工pH调整必须带死区正负，人工通气只列Air且空流量行不生成，DO参数包含slope/大气压/温度及来源，不能照本包旧概括漏项。

本包实施复选框仍待执行；设计已明确不等于代码已支持。task_type列长度不足的目标差异已登记字段字典，DDL/开发基线未同步且本轮不修改SQL，实施时须独立处理，不宣称可直接落库。I01—I05仍只限制对应物理调用和真实回传。

## Global Constraints

- 本次只编制任务包，未获开始编码指令；所有复选框均待实施。本包不是整个十二月项目排期。
- 源码核对基点：`556bee73952833c89e5111e5809f196d0c27d8df`及当时工作区。执行前重查HEAD、索引及相关文件差异，避开他人在途修改。
- 不改客户原件，不执行SQL，不恢复中试下游，不增加作废与依赖任务暂停/恢复规则，不重提选机裁决。
- 本文“拟修改”是技术实施位置，不表示当前已支持。字段、枚举、版本和路由先进入所属模块现行契约，再写代码；没有实际生产调用方的辅助类不算接线完成。
- 管理写沿既有权限、幂等及版本制式；不新增权限、审批、设备默认值或无依据的失败联动。

## Review Focus

逐项检查：是否有原文或已确认规则；是否复用现有页面/调用链；是否混淆业务期望值和设备事实；是否把内部实现缺口误列为客户欠资料；是否用低层验证冒充设备验收。

## 1. 领取顺序与退出条件

本包A/B/C/D是最初的设计准备顺序；后续实际领取按[复核后的P01—P06批次](../../详细设计/history/review/2026-11-01-V4-V51差异分析/27-设计收口复核与开发批次.md)第3节执行，D01—D08追踪身份不变。优先P01 Config存取/解释及P02前缀保存；P04自动生成须先细化R01/R02，P05填充输入须先细化R03，不将该三项内部设计工作推给客户。实施范围、真实文件和退出证据均在该表，旧步骤与现行字段契约有差异时以现行契约为准。

| 批次 | 对应编号 | 可执行工作 | 本批退出条件 | 外部依赖 |
| --- | --- | --- | --- | --- |
| A | D01、D08 | 收口新增任务及方案消费契约，建立逐项实施台账 | 每类入口、参数、事实生产者、消费者、状态及适用审批均可定位 | 不等待I01—I05；未知设备参数留在对应Port边界 |
| B1 | D02 | Config内容版本、三DO槽及Nothing的前后端一致实施 | 新写、重读、旧版本读取和有效槽校验有证据 | 点位展开/设备写入仍受I01/I02限制 |
| B2 | D06 | 中试前缀最终保存、来源读取及无前缀兼容 | 保存值、读取值、字典键值及重试一致性可核验 | 不要求先猜I05设备字符串格式 |
| B3 | D05 | 复用填充页面，收口typed输入与跳过契约 | 字段含义、校验来源、单元身份及步骤作用域一致 | 真实启停/反馈等待I04 |
| C | D03、D04 | 按A的生产/消费契约实现pH判断与监控生成任务 | 真实调用链及关键业务测试成立，不能只扩枚举 | 实际写入分别受I01—I03限制 |
| D | D07、D08 | 期望类型与实际返回来源分离，登记实施证据 | 关联设计可核验；获得I05后才实现真实提取和比对 | 实际返回字段/格式依I05 |

B1、B2的局部存取可独立推进；C必须先有A的任务消费契约。当前不是“8项都能直接编码”，其中A及D的一部分首先是可直接执行的契约工作。

## 2. A：任务与消费契约（D01、D08）

现有M07 `domain/vo/m07/TaskType.java`仍主要承载FEEDING/SUGAR；不能用补量字段或新增枚举代替新控制任务完整模型。以下Java路径均相对`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/`。

- [ ] 在`docs/详细设计/07-补液运行与任务执行/十二月新增工作流与任务规则.md`中逐类对应已确认入口：pH校准、pH/搅拌/温度/气体调整、DO校准、取样测样；保留各自自动/人工及立即/定时适用差别，不能统一加入口。
- [ ] 同步M03/M04/M06/M07的接口目录、时序和错误码：列清方案合法生效来源、适用审批、监控启动、条件事实来源、任务创建与执行责任。沿现有编号登记真实新增/调整接口，不在本计划预造路由。
- [ ] 每类任务列出具体字段及单位、源方案版本、事实引用、幂等边界、合法状态；对照真实Controller、应用服务、Mapper/Port及前端SDK。未落实的格子明确记为“我方契约待收口”，不是业务待客户裁决。
- [ ] 检查M07任务类型和运行入口的白名单、列表/详情/审批/执行消费者；形成精确文件清单后才扩类型，禁止添加无人消费的任务。
- [ ] 建立同一台账：需求依据、接口/内部Port、实现链、测试、HTTP、浏览器、设备、阻塞输入与责任方。D08在每批更新，不另造功能状态机。

验收：每个新任务可从入口沿事实生产者走到消费者；缺设备输入时仅设备Port受限，不将整个任务登记为IMPLEMENTED。

## 3. B1：Config存储及校验（D02）

拟修改文件：

| 文件（Java相对上述根目录） | 当前事实与修改责任 |
| --- | --- |
| `service/support/m04/content/ConfigContentNormalizer.java` | 当前DO输出限定2槽，source仅MFC/PUMP；实施3槽、Nothing及有效槽完整校验 |
| `domain/vo/m04/ConfigContent.java`及其实际引用的输出/source模型 | 保持模型、序列化及可空字段一致 |
| `service/impl/application/m04/ProcessTemplateApplicationApplicationServiceImpl.java` | 新写版本与读/复制/应用的版本识别一致，不能仅改normalizer |
| `service/port/m04/TemplatePackagePortImpl.java` | 区分包版本与内容版本，核对导入导出及历史读取 |
| `futurefab-frontend/packages/sdk-smp-api/src/configTemplate.ts` | source类型和Nothing字段语义与后端一致 |
| `futurefab-frontend/packages/app-smp-settings/src/views/config-template-management/config-template-editor.vue` | 当前初始化2个DO槽；改为3槽并复用现有编辑器 |

- [ ] 先更新`docs/详细设计/04-工艺与方案管理/模板内容存储契约.md`：明确新Config内容版本与旧版读取规则。CONFIG内容按第8.3节写2，AUTO_CONTROL按第12.4节独立写2，其余类型不整体升版；包schema与内容schema分开。
- [ ] 按已定第8.3节实现Nothing枚举及固定键/null分支，前后端共同遵守，不再自行选择另一种表示。Nothing不要求通道/映射/端点，也不展开MFC动作；有效槽按完整规则校验。pH两槽不变，不把豁免套到灌注。
- [ ] 覆盖所有内容版本硬编码检查；旧快照、摘要与历史包保持原值。旧方案进入新写格式时明确补齐第三槽的交互，不偷偷推断物理绑定或覆盖历史数据。
- [ ] 实施模型、normalizer、应用服务、包读写、SDK及页面；复用既有精充/粗充、型号能力和泵冲突校验，不增加工程资料核准环节。各重量字段沿已确认单位/精度，不全局套用一套精度。
- [ ] 补充新格式测试，并保留`M04ConfigContentNormalizerTest`、`M04TemplatePackagePortContractTest`的旧格式覆盖。新测试至少包括三槽、全部Nothing、混合有效槽、缺必填、非法通道/重复映射，以及旧包读取与新写再读。
- [ ] 浏览器验证新建、编辑、保存重读、Nothing切换和错误提示；记录实际请求、版本及响应。没有设备调用证据不声明Config设备工作流完成。

## 4. B2：前缀保存及培养来源（D06）

已存在`InitialInput.cellTypePrefix`、数据库`cell_type_prefix`及行模型字段，当前主要缺口是拒绝非空前缀、最终保存未落值及读取未带回。此批不需要为了存前缀新增数据库列。

- [ ] 在M03/M07现行契约写清：仅相应中试入口选填前缀；`cellTypeId`为字典身份、`cellTypeValue`取dict_value、显示名只展示；前缀与样品编号前缀分开。
- [ ] 修改`service/impl/port/m03/M03StartCultureAdmissionAdapter.java`的`validateInitial/applyInitial`：按适用设备范围支持前缀，保留原权限、版本及最终第4步保存边界。非空前缀须进入新提交一致性校验，历史无前缀摘要/回执不能批量重算。
- [ ] 修改`mapper/StartCultureOwnerMapper.java`的`complete`参数及`src/main/resources/mapper/resource/StartCultureOwnerMapper.xml`绑定，把实际前缀随最终业务保存落库；失败回滚和重复提交不得丢值或二次生效。
- [ ] 修改`service/impl/port/m03/M03CultureStartProfileAdapter.java`，从已生效培养读取真实前缀；不再用“前缀业务未核准”拒绝已确认的保存/读取。
- [ ] 对照`domain/dto/m07/StartCultureCommands.java`、`service/application/m07/StartCultureApplicationService.java`、SDK `start-culture.ts`及开始培养页面，确认字段贯通；只修实际断点，不重做已有页面。
- [ ] 保存/读取前缀不等于设备支持。`service/support/m05/M05CultureCellTypeSupport.java`及派发边界仍须防止把完整名称塞入正整数设备映射；不得未经I05核实就去掉最后一道协议限制。
- [ ] 在`M03StartCultureAdmissionAdapterTest`、`M03StartCultureOwnerMutationTest`、`M03CultureStartProfileAdapterTest`、`StartCultureOwnerSqlMappingTest`和M07开始培养测试中覆盖：键值与标签不同、非空前缀保存重读、空前缀兼容、最终提交失败/重试、越权与版本冲突。需要新增测试时以真实调用链为对象。

不自造分隔符、大小写转换、trim规则或设备长度。现有数据库容量不是已核实的设备协议上限。浏览器保存重读后才能标该页面BROWSER_VERIFIED；设备派发另行验收。

## 5. B3：复用取样填充交互（D05）

现有`futurefab-frontend/packages/app-smp-lab/src/views/start-culture/`已有`index.vue`、`small-sampling-prime.vue`、`sampling-prime-input.ts`，不能再建一套填充页面。当前组件主要使用SIMULATE_PRIME_START/STOP，输入校验借用了feeding模型的上限和整数约束；这不构成新需求依据。

- [ ] 在M07现行输入契约补齐取样单元身份、净重g、速度二选一（数值g/min或Speed1—10代码）及步骤归属。按原文核每个数值约束，不能沿用补料1—100g，也不自行新增精度/上限。
- [ ] 对照`ControllerSamplingUnitPort`/`ControllerSamplingUnitService`的单元编号，记录实际资源身份来源；编号不是已经具备真实指令寻址的证明。
- [ ] 复用上述组件与SDK `start-culture.ts`；仅在契约明确后移除不适用的feeding校验依赖，增加对应typed输入。同步`StartCultureCommands.java`和`StartCultureApplicationService.java`，保留原跳过与步骤作用域。
- [ ] 保持原第4步唯一业务保存点。物理动作日志不扩展为中间业务续做快照；停止填充不等于取消培养，不增加自动达量停止。
- [ ] 测试速度互斥、代码原样、不同单元不串参数、合法跳过及原最终保存链。I04未落实前保持真实物理入口不可用，模拟结果不得充当真实启停回执。
- [ ] I04到位后另补真实方法、地址、字段编码和结果对应，再接`RunWorkflowController.java`的合法入口；不直接放开当前拒绝分支。

## 6. C：pH判断与自动规则运行（D03、D04）

- [ ] A收口后，将规则配置、培养生效版本、M05有效结果和M02历史在线数据的真实来源逐一绑定到M07消费链。先核实际生产者/查询接口，再确定新增文件；当前没有可直接复用的独立`AutoControlContentNormalizer.java`，不要引用不存在的类。
- [ ] pH四档按实际选择动作，阈值最多2位小数及原范围保持；BGA窗口按已确认配置；按检测时刻取之前最近在线值，无最大间隔；缺BGA或配对数据等待，不补0、不计当天已处理。
- [ ] 分开覆盖人工超deadband二次确认、自动中位值超deadband记录且当日不再自动判断、其他自动分支原规则。不增加统一强制校准、不改用实时PV。
- [ ] 自动控制确认后先监控，条件达到才生成任务；搅拌连续条件中断归0；当前培养方案按原校验/适用审批生效后自动更新规则，不重跑工作流。不据此取消、重算旧任务或重置次数。
- [ ] 测试必须经真实应用服务消费规则，覆盖临界时刻、缺事实、合法方案切换和非法状态；不得仅测试无调用方的判断工具类后宣称链路已实现。
- [ ] I01/I02/I03分别补入实际设备调用契约后才接命令与回读。旧pH服务重读实时PV与历史配对不兼容的问题须保留，不能以测试造一条成功OFFSET。

## 7. D：检测返回类型来源（D07）

- [ ] 在M05现行契约分别登记业务期望类型、请求使用的设备类型参数、真实返回类型、来源记录/样品身份，沿既有派发与接收关联，不创造第二套匹配。
- [ ] 核`M05NamedPipePreparation.java`、`M05NamedPipeDispatchAdapter.java`、`M05SdmsDispatchAdapter.java`和`JdbcCdpResultReader.java`：当前CellType传参约束、SDMS支持类型、CDP真实SELECT字段分别记录，不能凭String类型推断支持完整前缀。
- [ ] I05取得同一样品的实际配置、传参和返回字段后，再实现提取、比较及原型已有标红告警。请求写入的CellType不能作为仪器回传；没有真实返回字段时该提取分支保持BLOCKED_INPUT。
- [ ] 覆盖身份关联成功/失败、期望与返回来源分离、实际不一致的展示及原告警链。不新增拒收、作废、自动重测或任务暂停。

## 8. 实施时的验证命令及证据

本次未运行以下构建/测试；这些是后续实施步骤。Java测试位于`futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/`。先确认所选测试类真实存在，新增测试完成后再加入命令。

```powershell
# 仓库根目录：Config定向回归；新增格式测试须追加到-Dtest
mvn -pl futurefab-modules/futurefab-system -am "-Dtest=M04ConfigContentNormalizerTest,M04TemplatePackagePortContractTest" "-Dsurefire.failIfNoSpecifiedTests=false" test

# 仓库根目录：前缀保存与读取的既有测试
mvn -pl futurefab-modules/futurefab-system -am "-Dtest=M03StartCultureAdmissionAdapterTest,M03StartCultureOwnerMutationTest,M03CultureStartProfileAdapterTest,StartCultureOwnerSqlMappingTest" "-Dsurefire.failIfNoSpecifiedTests=false" test

# 在futurefab-frontend目录；按实际改动包执行
pnpm --filter @futurefab/ui-app-smp-settings run type-check
pnpm --filter @futurefab/ui-app-smp-lab run type-check
pnpm --filter @futurefab/ui-sdk-smp-api run type-check
```

- [ ] Vue单元测试使用对应包`exec vitest run <实际测试文件>`，不得以零用例或passWithNoTests作为通过；Java记录实际用例数及Maven原始退出码。
- [ ] 写接口检查权限、版本冲突、幂等、回滚；涉及实际字段映射时补Mapper验证。未执行SQL只报告静态映射检查，不能宣称目标数据库通过。
- [ ] 对可见改动按项目要求做浏览器验收，记录请求/响应及服务日志；运行前按本机文档确认连接目标，不擅自启动用户服务。
- [ ] 每批按显式路径检查diff；提交/推送须有对应授权。本任务包本轮仅保留本地。
- [ ] 交付按IMPLEMENTED、CONTRACT_TESTED、HTTP_VERIFIED、BROWSER_VERIFIED及具体阻塞分别登记；设备及现场证据独立提供。

## 9. 本次交付状态

仅形成文档任务包。业务规则沿已有确认，技术契约待收口项不冒充新增客户问题。未改业务代码/SQL/客户原件，未执行构建、单元测试、HTTP、浏览器或设备联调；所有实施结果均为NOT_VERIFIED。

用户2026-11-02已明确撤下：2.1.2手动BGA与1.6.5.1自动控制额度共享/另起问题无需求依据，不再提问或作为开发前置；前述相关推导仅为已撤销过程记录。需求描述及确认问题须有原文或用户明确确认依据，技术推测不得升级为需求、实现要求或验收条件。
