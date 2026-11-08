# 管理版本Port装配缺失修复

2026-11-07。开工HEAD 024f404de，已有08交接提示词未跟踪；过程中其他任务修改M09状态阈值文件，本任务未覆盖。没有提交、配置变更、数据库或外部调用。

## 根因与修改

DeviceUsageApplicationServiceImpl构造器第5项依赖ManagementRevisionPort，但生产源码无实现。已有@Component的M01ManagementRevisionSourceAdapter仅实现ManagementRevisionSource。原M05测试Mock该接口，未覆盖真实装配。

本次仅让原适配器同时实现ManagementRevisionPort并补verifyManagementRevision：合法请求无锁读取原SYSTEM版本源，返回matched/currentManagementRevision；真实零版本合法，冲突返回真实当前值；非法参数拒绝，源缺失/负数/查询异常转原DEPENDENCY_UNAVAILABLE，不伪冲突或补0。不新增平行Bean、配置或存储。原CurrentManagementRevision源行为保留。符合PKG-00 §6.1 SEC-I03及原Port合同，未改变签名。

新增M01ManagementRevisionPortWiringTest，纯AnnotationConfigApplicationContext装配真实设备使用应用与生产版本适配器，仅Mapper及其他依赖隔离；不加载Boot配置、不执行SQL。

## 验证与实际限制

初次定向Maven因新增测试ObjectMapper构造方法引用与registerBean重载歧义而编译失败，0用例；已改为明确零参lambda。这不是业务RED测试结果。

修复后Maven命令：D:/Programs/Maven/bin/mvn.cmd -pl futurefab-modules/futurefab-system -am test -Dtest=M01ManagementRevisionPortWiringTest,M01ManagementRevisionSourceAdapterTest,M05DeviceUsageApplicationServiceTest,M05DeviceUsageControllerTest -Dsurefire.failIfNoSpecifiedTests=false。原退出1、0用例，生产编译被并行M09的setUnitId缺失阻断，完整Maven未通过。没有回退或修补他人在途文件。

随后使用已解析依赖classpath，在temp独立classes输出，通过javac --release 17编译本次适配器、上述4测试类、实际DeviceUsage Controller及必要源依赖；不写共享target。JUnit Platform 6.0.3 Launcher执行上述4类，25发现/25执行/25通过/0失败/0跳过，javac原退出0、Java原退出0。首次隔离运行20通过5失败是反射Controller未包含编译集，补入真实Controller后上述25通过；没有修改或放宽测试断言。

[正式测试输出](B18-编译装配与约束静态测试证据.txt)。可复跑输入为本次temp内javac.args/java.args及RevisionPortRunner.java（过程产物），长期复跑优先用上文Maven命令，须待并行代码稳定。独立验证包含真实Spring构造装配、版本一致/冲突/零值/源失败/非法输入及M05服务和MockMvc契约，不等于全应用启动、真实HTTP或数据库联调。完整启动待M09配套完成后重构建并由安全环境验证。

## 后续当前验证（B18）

work1暂停后，以其最新已保存配套重新执行，完整Maven compile及定向test均原退出0，4类25例通过；详B18。此前受并行M09编译阻断是历史轮次结果，不再代表当前源码无法编译。全应用启动与运行数据库仍未验证。
