# S03 M07 任务查询三口复审

日期：2026-11-03。取证HEAD：3abfb74a3c394aa1540439790459538b2d542722。

## 结论

接受本批任务详情、执行记录、日志三口的限定范围静态取证，可以收口；不要求重做三口。S03尚未通过，14口静态维度已有证据不等于14个接口完整设计对齐或业务验收通过。

复审对象：《07-M07任务详情执行记录日志三口核验记录.md》及《03-M07逐口核验状态与样例证据.md》对应回填。没有重新复核旧R01—R24销项账。

## 主要源码核对

- RunTaskApplicationApplicationServiceImpl#getTask先解析范围，再selectTaskDetail；返回版本通过任务投影装配，不将暂停/恢复的命令意图版本当作任务版本。
- listTaskLogs/listTaskExecutions先requireTaskInRange再PageHelper.startPage。前置检查复用任务详情范围查询，不能只看子记录SQL无lab条件就认定无鉴权。
- 两个列表在PageInfo取total后，将请求pageNum/pageSize写入响应；执行分段取数发生在主分页查询之后。
- M07TaskQueryMapper.xml的日志排序为occurred_at DESC/event_id DESC，执行排序为attempt_no ASC/execution_id ASC，分段为execution_id ASC/segment_no ASC。
- 日志视图逐行只装配eventId/eventType/objectKind/objectId/objectVersion/actorUserId/occurredAt，未直接把payload及前后快照暴露为该接口字段。
- getTask展开安全交接、启动撤回及计算摘要投影。已读链路未发现业务写入；不把同Mapper其他未调用的update归入GET副作用。

上述为关键链路和语句抽查，不是对报告全部字段、投影和历史数据逐项重新验收。

## 保留的解释边界

1. 已认证且范围为空、无权或任务不存在的路径统一拒绝；会话身份缺失、非法参数等仍可能有各自错误。不能把所有失败都概括为404。
2. 无子记录返回空页的事实与PageHelper越界页行为分开。reasonable=true来自仓库application-dev配置，当前运行配置及库上效果未核，应写“若该配置实际生效，则存在夹页与响应页号不一致的可能”，不能把仓库文件当作实际部署证明。
3. 同一方法没有@Transactional只能说明该处未显式声明事务，不能仅凭它断言运行时绝不可能处于外层事务或一致快照。准确表述为“本批未证实两次查询的同一快照保证”。不为此要求新增事务机制。
4. 执行升序第1页与前端在该页内取最大attemptNo的组合风险可以保留，但需有超过一页执行记录才会触发，未做运行复现，不升级为已发生业务事故。
5. 排序中分段的executionId+segmentNo是实际排序键，不应未经DDL核对统称“均以主键为次级键”。不需要为这类摘要精度重开整轮返修。
6. 固定null、有限日志字段、LIMIT 9及时间往返均按已有依据分成设计差异或待核，不自动新增客户需求或实现任务。设计中的纯读约束已经由当前链路支持，无需把它另立为待批准的额外机制。
7. 字段逐项对齐、行级范围在真实数据下的结果、投影完整性和运行验证继续列F；A—F维度不是阶段验收结论。

以上限定供后续摘要和回填沿用，不要求一次性修完所有观察项或扩大调查范围。

## 实际检查与修改边界

以PowerShell枚举交付目录八份md后运行check-doc.mjs：FILES=8 BAD_LINKS=0 BAD_TABLE_ROWS=0，进程退出0。实际查看了计数，未把格式检查当作业务审核。暂存区路径检查无输出。

交付HEAD为7d96bdc53，复审时已有后续M01/M07文件提交。已直接重新读取当前RunTaskApplicationApplicationServiceImpl与M07TaskQueryMapper相关段落；本次三口主要取证方法不在后续提交路径列表，不沿用旧行号宣称全库快照未变。

仅新增本复审记录，未改业务代码、测试、前端、SQL、配置、客户原件、记忆或work1文件，未暂存、提交、推送。未编译、单测、连库、执行SQL、HTTP、浏览器、设备验证，运行层均NOT_VERIFIED。

## 下一步

继续小批核验任务异常处置入口，以及与其页面直接关联的执行详情、命令查询；先定位真实接口再固定3口范围。复用本批任务查询与前批暂停/恢复事实，不重新展开整个设备执行器或审批模块。旧R01—R24纠偏继续独立处理。
