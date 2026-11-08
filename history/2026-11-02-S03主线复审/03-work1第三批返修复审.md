# S03 work1 第三批返修复审

性质：过程性静态复审，不是现行需求或新增验收机制。日期：2026-11-02。

复审起始 HEAD 为 d8021e7b304c807fa3672c1e21ea4f3abe7f609a，结束取证时为 24ec93efd3fb8de89e078346be916588d5309b5f。期间他人提交为 M02 检测设备型号控制器注释；本次具体问题取证涉及的脚本、SDK 和 M06 服务不在该提交内。未重新扫描整个仓库，不宣称全量快照已刷新。

## 1. 结论

部分返修可以接受，S03 尚未通过。本轮仅新增本复审记录，不改 work1 文件、覆盖表、业务代码、SQL、配置或客户原件，不暂存、提交或推送。

可保留：M06 改用自身对账服务取证、activatePolicy 固定拒绝的定位；SysUserLab 集合返回/空表单/写口作用域分开描述，不再断言页面已造成数据损坏；D-10 四个活动实现口与两个页面在用口分开；M08 共用功能码不再列为需求问题；M07 三个控制器归属修正。接受的是上述具体纠偏，不代表模块字段与业务覆盖已经验完。

## 2. 仍需定向返修

### B3-01：同名重载被误当成别名，两个分母没有统一

inventory_v3.mjs 以 controller#method 聚合 handler；modules_v4.mjs 则增加 file:methodLine。对同一份 routes_mod_v4.json，独立计算前者为 1032、后者为 1035。真实重载包括：

- ResBatchController#edit：214 行与 271 行，两个不同方法声明。
- ResProjectController#edit：184 行与 237 行，两个不同方法声明。
- SysUserController#getInfo：472 行与 495 行；495 行自身才具有两个路径。

因此不能把这些重载合并为别名。按该快照的文件+方法声明行区分，得到 1035 个声明、10 个多路由声明对应 20 行；1045 路由行与此相差 10 行。以上是对扫描产物的独立复算，仍不是 AST 或运行时映射完整性证明。修正应统一声明身份，最好保留签名；不要只改一个总数。

报告自身承认 884+110=994 与 1045 差 51，且 M01 剩余 234 大于该模块声明总数 233。未逐行关联前，应撤下“精确剩余”措辞。已核集合、未核集合和别名展开必须使用同一身份轴再求差集，不能相减估算。

### B3-02：消费者扫描仍存在 SDK 方法误配，汇总不能直接验收

m07_consumers_v4.json 把 GET /run/tasks 的 SDK 记为 runTaskApi.recoverDetectionSources，并引用 DetectionSourceRecoveryModal.vue:163。实际 sdk-smp-api/src/run-task.ts:271 起的 recoverDetectionSources 是 POST /run/tasks/{taskId}/detection-source-recoveries；GET /run/tasks 属于随后声明的 page 方法。

consumer_v4.mjs 的对象成员识别要求形参后直接出现 =>，未覆盖 page 的返回类型注解，随后用“最近前置声明”兜底，将该请求归给前一个成员。类似语法需检查，无法可靠绑定时记待人工，而不是延用前一个声明。未显式指定 method 的 request 还不能不分 HTTP 方法地匹配任意后端路由。页面文本命中也需核实导入及调用，不能仅凭同名文本断言在用。

41/7/12 可以复算为当前工具输出，但目前不能当作人工核验后的事实。修正工具后仅对受影响项重核，并明确工具候选与人工确认的区别。

### B3-03：M07 分族表与本轮产物矛盾

报告 §5.2 写 RunCultureChangeController 六口均无封装，但新 JSON 六口均有 SDK 和页面引用，例如 calculationRuleContext → operations/runtime-calculation.ts:29、submitCalculationChange → 同文件:139、deviceChangeContext → operations/replacement-dialog.vue:50。

同表写 RunTask 的 exception-handling/executions/logs 无封装，而新 JSON 均有封装和调用候选；RunMeasurement 写两口无封装，新 JSON 四口均有封装和调用候选。SDK 源文件中 logs:316、executions:343 的定义确实存在。

需逐口核实并从同一份已核证据生成分族表与汇总，不能正文保留旧结论、汇总采用新数字。此问题与 B3-02 分开：修正文稿矛盾不等于扫描误配已消除。

### B3-04：M04-023 的 E 分类与本轮规则仍冲突

公共约定 §9.1 定义 E 为“本期需求或已批准必要方案要求的目标，实现链缺失”。报告 §4.3 却写“维持 E（设计侧目标、无需求条款），不进必须开发清单”。

若没有需求或已批准方案依据，按本轮规则登记设计—源码差异或额外机制待评估；若确有批准依据则列明。不得保留 E 再用括号排除其定义，也不据此增加开发任务。

### B3-05：过期 501 说明的结论要匹配实际证据深度

RunExecution 已展开范围、判权、Mapper 查询等链路，其证据强于单纯文本计数；ProcessTemplate 的 resolveSamplingResourceFacts 实现也能定位到 M02 samplingResourcePort.resolve（实现文件 1514—1528 行）。这些可按具体链路登记。

但 DetectionRule、DetResult、DetWorkbench 表中仍主要以应用服务直接 throw 计数为 0 判“过期、非未实现”，不足以排除下游 Mapper/Port 的未实现或其他拒绝方式。未使用 import 可登记静态残留，不能由此证明业务已实现。需补受影响端点的下游证据，或收窄为“直接抛出说法未在该服务发现，实际链路待核”。不要求为本轮改源码注释。

## 3. M06 补证边界

已核对 M06 Command 服务的 baseDeliveryVersion 校验与比较（116、208 行）、replayCreate/replayReview、requireReviewableReconciliation（542 行起），以及 Query 服务 EVIDENCE_REQUIREMENTS。可以撤销此前 M09 串证问题。

这些是源码机制事实；需求依据仍以有效 Q03 等确认原文为准，不把每个 CAS、摘要或活动槽字段都提升为客户需求。静态分支存在不代表真实事务、重放及设备执行行为已经运行通过。

## 4. 后续与验证

先处理 B3-01—B3-03，建立同一身份轴、同一批证据的逐口状态清单，再继续未核接口；B3-04—B3-05仅需纠正分类及证据强度。已接受的 B2 具体纠偏不必重做，不新增客户问题，不增加统一门槛。

本轮进行了源文件定向阅读及 JSON 独立复算。没有运行 work1 全量扫描器，没有编译、测试、数据库、HTTP、浏览器或设备验证；以上运行层均为 NOT_VERIFIED。只新增本记录，其他在途修改保持原样。
