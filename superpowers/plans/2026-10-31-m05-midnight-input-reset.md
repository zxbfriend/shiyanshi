# 检测工作台零点录入区清理实施

依据用户2026-10-31明确要求：所有检测设备左侧需求录入区每天上海零点全部清空，前端代码和界面不改，右侧检测记录及发送校验不变。

方案：只调整M05WorkbenchQueueReader的录入行投影。以同一个服务端时刻计算上海业务日边界和serverTime，过滤前日及时间未知的输入行；已发送、检测中、超时、完成、未知等旧状态不再通过occupantRows返回给左侧。未知态也读取同设备的输入时间以正确区分今天与昨天，但不对外返回其敏感内容。物理占位snapshot、positions动作守卫、WorkbenchQueueRules、发送锁读、检测结果查询、原派发和后台安全回收全部保持原规则。日期筛选不能重新取回前日输入。

这是录入区按业务日的逻辑清空，不删除检测任务、结果或物理占用证据；所有设备共用该入口，无当前页面设备或设备类型白名单。现有前端已根据serverTime在跨日轮询时清理本地未提交草稿，无须修改前端。

- [x] 新回归用例在旧实现中复现左侧残留。
- [x] 修改后端投影，增加可控Clock和同一时刻边界计算。
- [x] 测试零点前后、各种任务状态、新日输入、历史查询条件、未知状态隐私和发送守卫不变。
- [x] 定向运行相关发送/回收/右侧查询测试，记录原始退出码和实际用例数。
- [x] 用户重启system后验收四类设备页面，旧行隐藏、当日行保留、右侧历史记录保留；真实跨零点效果仍为NOT_VERIFIED。

不提交、不推送，不操作测试数据或系统时钟，不改前端及无关M04复核文件。

## 实施与验证过程

- RED：旧实现执行1个定向用例，原Maven退出1，明确复现零点后occupantRows仍有旧行。日志`.local/m05-midnight-red.log`。
- 后端实现只改M05WorkbenchQueueReader；Clock同时生成上海业务日与serverTime，避免跨零点两次取时不一致。occupantRows和displayRows按当前业务日过滤；positions及原snapshot继续完整参与既有动作判定。没有改Mapper SQL、发送服务、右侧查询或回收任务。
- 新增测试遍历全部State枚举及4个设备ID，断言上海23:59:59仍有录入、00:00:00旧行消失、当日边界之后的新输入保留、UNKNOWN仍匿名，并比较零点前后原positions动作一致。其他定向测试覆盖回收、发送、样品变更、结果字段和权限范围。
- 首轮相关回归117例有1例动作一致性失败；该轮编译期间调整了visible与currentDayInput分离，不作为最终源码的通过证据。最终稳定源码正在完整重跑，结论以后续原始进程结果为准。
- 静态只读复审未发现阻断问题。前端未改；既有页面每10秒轮询，隐藏时暂停，编辑期间仅刷新右侧，因此浏览器清空发生在零点后的下一次有效队列刷新，不宣称精确00:00立即更新画面。
- 右侧记录不删除，旧任务状态不重写，实际物理占用不伪装空闲。发送准入不因左侧行消失而放宽。

- 用户同轮补充确认按需求列表记录创建时间判断当天录入。实现使用WorkbenchInputRow.createTime（det_sample.create_time），按既有UTC时间存储约定转换上海业务日；测试明确覆盖createTime恰等于上海零点时保留。

## 最终稳定源码验证

- `mvn -pl futurefab-modules/futurefab-system -am -Dtest=M05QueueProjectionBehaviorTest,M05QueueRulesTest,M05WorkbenchSnapshotReaderTest,M05DayRolloverProcessorTest,M05SampleMutationBehaviorTest,M05DispatchExecutorTest,M05WorkbenchTimeProjectionTest,M05WorkbenchUnboundResultScopeTest,M05WorkbenchNumericProjectionMapperTest,M05WorkbenchManagementRevisionShellTest -Dsurefire.failIfNoSpecifiedTests=false test`：10类117例，Failures=0、Errors=0、Skipped=0，原始Maven进程退出0、BUILD SUCCESS。日志`.local/m05-midnight-final.log`。
- 测试覆盖创建时间早于当天零点的旧录入行消失、恰好达到零点的新录入保留、当前UNKNOWN匿名显示、显式历史日期无法取回旧输入、所有State和4个设备ID、发送动作判定保持不变。右侧查询、数字/时间映射及范围权限定向回归通过。
- `git diff --check`通过；前端目录无差异；只改后端reader及行为测试，无Mapper SQL、发送服务、右侧查询改动。HEAD为6be001c06，本轮不提交、不推送，保留已有M04复核记录。
- 用户已自行重启system，9201端口新进程28924。重启后四类设备读取页面通过，见M05 history/review/2026-10-31-需求录入区清理浏览器验收.md。当前旧行过滤及当日行保留为BROWSER_VERIFIED；真实跨零点刷新、发送HTTP及外部设备发送仍为NOT_VERIFIED。未停止用户进程、未调整系统时钟、未修改共享数据库。

## 2026-10-31 补充类内状态清空开关

用户要求增加clearOldLeftStatuses：true保持当前旧输入与状态均清空；false清输入但保留活动任务的状态及受保护占位。默认true；不修改前端、右侧记录或发送事实。新增行为测试遍历全部State及pending/testing/timeout，比较两模式positions一致，检查旧输入不泄露、身份版本代次保留、UNKNOWN匿名、行操作均禁用。实际运行和浏览器尚未验证，不停止用户IDEA进程。

定向验证：M05QueueProjectionBehaviorTest、M05QueueRulesTest、M05WorkbenchSnapshotReaderTest共42例，0失败/0错误/0跳过，原始Maven退出0、BUILD SUCCESS，日志.local/m05-status-switch-test.log。源码IMPLEMENTED + CONTRACT_TESTED；服务未重启，新开关HTTP/浏览器NOT_VERIFIED、运行BLOCKED_DEPLOY。默认true未改，不提交、不推送。

提交前核对：用户测试期间已将clearOldLeftStatuses设为false，本次保留该设置提交，即当前启用跨日保留活动任务状态及受保护占位。上述42例通过记录对应此前默认true的源码快照；默认值被修改后未重新运行测试，不能作为当前false设置的通过证据。页面测试交由用户，本轮未新增页面验收结论。
