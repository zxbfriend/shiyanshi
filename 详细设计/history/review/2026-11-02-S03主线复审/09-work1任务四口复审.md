# S03 M07 任务取消、修改、暂停、恢复四口复审

日期：2026-11-03。复审HEAD：77fae89ab9de4e5de8822d3f44f0cdd938f74b3b。

## 结论

接受本批限定范围的静态取证，保留所列F项，不重做四口。S03尚未通过，不能据“11口”宣称11个接口完整实现或验收通过。交付摘要中一处响应版本概括需纠正，正式字段表已经给出正确区分。

本次对象是《06-M07任务取消修改暂停恢复四口核验记录.md》及本批状态回填，与旧R01—R24销项账纠偏独立。

## 关键源码核对

1. 取消：M07TaskCancelService存在DIRECT/DIRECT_REASON与APPROVAL分流。直接取消的READY分支调用applyDirectCancel，PAUSED分支调用pausedFinalizer；审批分支落候选并holdForCandidate。详细PAUSED收尾及审批内部未验完，按报告F保留。
2. 修改：M07TaskChangeService#write调用RuntimeChangeApprovalRequirement.requireApproval。该方法只接受APPROVAL，否则POLICY_UNVERIFIED；不是通过添加一个直接修改规则补齐设计。当前新提交的成功路径是候选与审批，不是任务修改已经生效。
3. 暂停：Controller声明@ResponseStatus(ACCEPTED)。TaskPauseIntentService在guard.execute返回后调用dispatcher.dispatchPrepared，响应为PAUSE_REQUESTED/PENDING；设备执行成功不能由该返回推断。
4. 恢复：事务外预取读数，再进入guard回调；已定位任务/执行状态推进和新段/命令写入。恢复响应的意图状态与实际泵速生效应分开。
5. 暂停/恢复实际权限分支包括allAccess，普通范围使用operableLabIds及manageCultureIds。错误消息中的MEMBER字样不替代这些实际集合谓词；不根据消息另造权限规则。

以上为源码定向核对，不是对821行报告或全部Port/SQL重新做一次无遗漏验收。

## 响应版本的准确口径

用户转交摘要称“四口响应都没有任务新版本”，此句不准确。源码与正式记录§4.8/§6.8/§7.8应按以下解释：

- 取消：objectId是任务ID；直接分支objectVersion为expectedVersion+1，审批分支为expectedVersion。
- 修改申请：objectId是任务ID，新提交返回原expectedVersion；候选已提交不等于参数已改。
- 暂停/恢复：objectId是命令ID，objectVersion固定为意图创建版本1，不是任务当前版本。

因此应仅对暂停/恢复说“没有返回任务当前版本”，不能推广到四口。正式报告的逐口字段表已区分，后续摘要和回填同步采用即可，不需要重开整轮返修。

## 保留的解释边界

- “守卫提交后派发”已定位为当前请求调用链中的直接dispatcher调用，不由此推断HTTP返回后才异步调用设备；后续Worker及真实回执仍未核实。
- “任务仍EXECUTING”描述的是暂停准备事务未将业务状态改为PAUSED，不保证设备回执并发推进后，HTTP返回瞬间仍是该状态。恢复同理，数据库准备态与设备最终态分别描述。
- 公共守卫四元组等行为本批主要引用公共定义及调用，报告已保留内部未逐行展开；不能据此宣称四口重放和并发运行通过。
- 设计API06“审批或直接生效”与实际修改入口及专题冲突可作为设计纠偏建议，但当前源码不天然高于需求。后续现行设计落笔前继续引用已确认的审批业务依据；本轮不据此新增必须审批的客户规则。
- 11口/49口仅为本轮定义的静态维度覆盖数量，响应字段完整性、行级范围、外部实现及运行验证继续按F保留。包含必要下游未核并不等于其他接口已验收。

## 验证及改动纪律

实际以PowerShell枚举交付目录七份md后调用check-doc.mjs：FILES=7 BAD_LINKS=0 BAD_TABLE_ROWS=0，进程退出0。暂存区路径检查无输出。格式结果不能替代源码判断。

14a8b2fd0至复审HEAD的提交差异涉及M02服务与Port等文件；M07本次主要入口/支撑服务未在该列表。共享工作区的其他未提交修改不在此结论内，未声称整个仓库无变化。

仅新增本复审记录，未改业务代码、测试、前端、SQL、配置、客户原件、记忆或work1文件，未暂存、提交、推送。未编译、单测、连库、SQL、HTTP、浏览器或设备验证；运行层均NOT_VERIFIED。

## 下一步

本批可收口。下一小批优先核任务详情、执行记录、日志三个查询入口，复用本批状态与响应事实，重点核查询范围、分页/排序、字段来源和实际页面消费者；不扩展整个设备执行器或审批模块。旧R01—R24纠偏保持独立推进。
