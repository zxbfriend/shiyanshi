# M06 Controller 请求调用时序设计

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

## 1. Controller入口逐项映射

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位001 | GET /process/approval/deliveries/{id}/reconciliation-preview | 审阅收尾对账与启用契约.md | M06.定位001 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位002 | POST /process/approval/deliveries/{id}/reconciliations | 审阅收尾对账与启用契约.md | M06.定位002 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位003 | POST /process/approval/reconciliations/{id}/review | 审阅收尾对账与启用契约.md | M06.定位003 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位004 | POST /process/approval/reconciliations/{id}/withdraw | 审阅收尾对账与启用契约.md | M06.定位004 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位005 | GET /process/approval/reconciliations/{id} | 审阅收尾对账与启用契约.md | M06.定位005 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位006（已停用） | POST /process/approval/policies/{labId}/activation | 接口与审批生效契约.md | M06.定位006 | 停用入口 | 明确拒绝；不再启用或暂停实验室政策，历史记录保留 |
| 定位007 | GET /process/approval/scenes | 接口与审批生效契约.md | M06.定位007 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位008 | GET /lab/lab/{labId}/approval-policy | 接口与审批生效契约.md | M06.定位008 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位009 | PUT /lab/lab/{labId}/approval-policy | 接口与审批生效契约.md | M06.定位009 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位010 | GET /process/approval/requests | 接口与审批生效契约.md | M06.定位010 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位011 | GET /process/approval/requests/{approvalId} | 接口与审批生效契约.md | M06.定位011 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位012 | GET /process/approval/requests/{approvalId}/actions | 接口与审批生效契约.md | M06.定位012 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位013 | POST /process/approval/requests/{approvalId}/precheck | 接口与审批生效契约.md | M06.定位013 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位014 | POST /process/approval/requests/{approvalId}/actions | 接口与审批生效契约.md | M06.定位014 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位019 | GET /process/approval/audit | 审阅收尾对账与启用契约.md | M06.定位019 | CTRL-QRY | 只读聚合；经M03/M07/M09审计QueryPort读取；任一依赖未知显式503 |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| 定位015 | API09 evaluateApprovalPolicy | 接口与审批生效契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位016 | API10 submitApproval | 接口与审批生效契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位017 | API11 deliverDecision | 接口与审批生效契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |
| 定位018 | API12 queryDecisionApplication | 接口与审批生效契约.md | CTRL-INTERNAL | 仅可信模块调用；输入输出以来源契约为准 |

## 4. 模块内调用约束

- HTTP字段必须先映射为 M06 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

2026-11-07 S04：API10保存不可执行候选副本，API11沿原APPLY/DISCARD交拥有方；DISCARD按NEW/修改/取消原操作语义处理，不按审批CANCELLED一概取消任务。新增被驳回的任务由M07在消费原决定的本地事务内取消、不再次申请取消审批；已有修改/取消申请不覆盖原有效内容。DATES只消费M03当前分类，详细影响不足列S05字段映射差异，不新增本地字段或借旧impact直接清方案。见[副本及日期影响配套](接口与审批生效契约.md#s04副本及日期影响配套2026-11-07)。

本文件自动登记 15 个目录内HTTP入口、4 个内部定位项、0 个尾部补登记入口。数量校验只防漏项；逐接口仍须以来源契约完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。
