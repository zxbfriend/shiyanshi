# 后台编译、Port装配与培养运行约束核查

2026-11-07；HEAD 024f404de。用户要求优先保障后台启动、核实际注入Port，并确认work1已暂停后端修改/构建。保留其M09在途代码，本任务没有修改或回退这些文件；未提交/推送、未改运行配置、未启动/停止他人服务。

## 1. 编译与测试实际结果

D:/Programs/Maven/bin/mvn.cmd -pl futurefab-modules/futurefab-system -am compile：原退出0，BUILD SUCCESS，19模块依赖链及system编译通过。

D:/Programs/Maven/bin/mvn.cmd -pl futurefab-modules/futurefab-system -am test -Dtest=M01ManagementRevisionPortWiringTest,M01ManagementRevisionSourceAdapterTest,M05DeviceUsageApplicationServiceTest,M05DeviceUsageControllerTest -Dsurefire.failIfNoSpecifiedTests=false：原退出0，25执行/25通过/0失败/0错误/0跳过。包括7个Port/真实Spring装配、4个原版本源、9个M05应用、5个Controller测试。修正此前B17全Maven被在途M09编译阻断的当前结论，历史失败日志仍保留，不把该轮25视为全量测试。

work1保存的M09字段/应用配套已解决之前setUnitId编译不一致，本任务未覆盖或重复修复。ManagementRevisionPort生产实现沿B17在原M01适配器复用真实SYSTEM源，无空Bean或固定版本。

## 2. 实际注入Port逐项扫描

JavaParser 3.28.2以Java17语法读取system生产源码，按全限定名/显式及通配导入、继承实现关系核对；覆盖构造器、Autowired/Resource/Inject字段与方法、Lombok构造以及@Bean工厂入参，识别ObjectProvider/Optional和集合，归一全限定注解名。3794个class/interface声明，841个组件类型，160种实际注入Port，515个注入位置；明细见[正式清单](B18-实际Port注入与注册核查.csv)。初步正则扫描只用于定位，不作为最终计数。

- 除B17已补的ManagementRevisionPort外，未发现其他必需Port无@Component/@Service或@Bean注册提供方。
- 唯一无生产提供方的是M05DetectionHandoffService的ObjectProvider<DetectionOrderHandoffPort>，属于原可选业务依赖，不能用空实现补齐；业务调用缺事实仍有原阻断行为，不作为缺Bean启动缺陷。
- CommunicationConfigurationPort由M02InternalCommunicationConfiguration的两个具名@Bean提供，8处注入均使用正确Qualifier；不误判为缺@Component或多Bean冲突。
- ApprovalOwnerPrecheckPort等拥有方集合按原用途聚合，M03/M07/M09同名接口按全限定名区分，不误判多个实现。
- DeviceCommandPort提供方由网关enabled条件控制，消费者ObjectProvider或Autowired(required=false)；ExecutionSamplePort提供方和必需消费者M07IndependentMonitorEvidenceIngestion均由同一ResourceTransactionConfiguration.PROP_ENABLED条件启用。没有移除条件或伪造设备Bean。
- 未发现组件多构造器既无零参构造、又无Autowired/Inject选择的候选。

此为生产源码注册/条件与必要Spring装配的静态及隔离验证，不等于实际运行profile下所有Bean均已实例化，更不能证明外部依赖可达。

## 3. ck_m03_culture_runtime错误根因和授权变更

现行M03运行事件/延期收尾契约明确：FIRST是首次操作事实，不是完整完成；没有完整选定工作流完成时，到期转EXPIRED释放本培养主预约，即使已有部分操作也适用，并保留操作记录。旧CHECK同时要求NOT_STARTED/EXPIRED的FIRST为空，与该规则冲突，不能清空FIRST或改为DELAYED规避。

用户另行明确授权“修改这一项现行设计和DDL基线、准备旧库脚本，不连接/执行数据库”。据此只将该CHECK最后一项从lifecycle_state NOT IN ('DRAFT','NOT_STARTED','EXPIRED') OR FIRST IS NULL改为lifecycle_state <> 'DRAFT' OR FIRST IS NULL；其他RUNNING/FINISHED/CANCELLED/DELAYED条件原样保留。未改列/表/索引、初始化数据或其他约束。

同步M03原目标DDL、字段字典、完整建表基线、03约束存在/定义/启用状态只读核验及来源清单对应SHA256；开发基线README说明新库与旧库路径及未执行状态。旧库只准备两份开发包脚本：

- [执行前核查](../../../../开发基线/开发包/2026-11-07-M03-培养运行约束-执行前核查.sql)：选库/MySQL版本、SHOW CREATE TABLE、该CHECK定义和启用状态、目标CHECK冲突行计数，只有读取。必须人工审阅，不能与变更连跑。
- [定向变更](../../../../开发基线/开发包/2026-11-07-M03-培养运行约束-定向变更.sql)：经另行数据库执行授权及前置人工核准后，在同一ALTER内只替换本CHECK。不自动建库、不修改业务数据、不关闭检查、不清空FIRST、不重跑完整建表。

python scripts/test_culture_runtime_constraint.py：6个静态测试通过、原退出0，覆盖实际基线表达式的部分操作/过期、其他状态拒绝、源与基线只改单项、SHA256、两份脚本无业务写。测试仅将该已知表达式映射为Python布尔判定，并做制品检查，不连接数据库，不等同MySQL约束执行通过。调整测试表达式转换时一次运行有3个SyntaxError，已修转换器等号处理并实际重跑6通过，未修改生产目标约束来迁就测试。

## 4. 仍未验证与下一步

数据库未连接、脚本未执行，运行库仍可能保留旧约束；重启代码本身不能修复旧库3819错误。待数据库维护人员获得执行授权后，先审前置核查结果，再单独变更并复核实际到期扫描、状态与预约释放、事务回滚。

本服务有ApplicationReadyEvent及定时采集/派发/告警等后台处理。实际Nacos覆盖和外部隔离未被完整证实，因此本任务未自行启动整业务应用，避免连接未知库或触发业务/外部动作。完整应用启动、真实HTTP/数据库/设备仍NOT_VERIFIED；不能以compile或25单测宣称现场启动通过。用户当前提供的SQLException说明旧库约束问题，与Bean构造缺失分层记录。

[正式编译与测试输出](B18-编译装配与约束静态测试证据.txt)。临时AST工具和中间数据只在temp/root/port-bean-audit，不构成新业务框架。当前源码可继续本机构建，work1恢复前需知悉M01适配器和本次单项DDL/文档修改，勿将旧库脚本自动执行或恢复旧约束。

## 分批提交前追加核查

用户要求中文分批提交。M01修复、M03已授权单项约束基线/未执行脚本及核查证据分别提交；M09为work1在途代码，依据AGENTS §13.1保留不混入。定向M09WiredStatusOnlineConfigContractTest实际60例、1失败、0错误/跳过，Maven原退出1；失败statusUnitCodeSpanningMultipleRowsIsRejectedInsteadOfFirstPicked的具体断言为首条行号期望2、实际1（随后B19复核定位；不是行数断言）。settings包type-check原退出1，lab-statusalarm/index.vue(414,60)使用unitCode而当前SDK声明仅有unitId；这是当前类型检查结果，不据此排除SDK产物未重建的可能。未为提交放宽断言或修改work1源码。此前25例Port/M05回归与compile成功仅覆盖对应范围，不覆盖本轮M09失败。

scripts/test_culture_runtime_constraint.py静态测试6通过；提交前去除“HEAD必须还是旧DDL”的一次性假设，改为长期检查现行源/安装基线目标定义一致，避免提交自身使测试失效；未改变CHECK目标规则。
