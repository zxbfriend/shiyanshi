# M04 Controller 请求调用时序设计

## 2026-10-31 型号信息直接用于工艺方案

用户确认取消工艺方案保存对“已核准工程资料”的前置要求，直接使用反应器型号维护信息。M04型号候选、事实读取与版本保存的旧ENG-I01核准门禁由[本次来源与版本规则](工程版本固定与评审收尾.md)覆盖；保留字段合法性、型号适配、权限、SYSTEM修订及不可变快照校验，不生成伪造核准记录。设备运行及安全规则不由此放宽。

每个入口的物理Controller、ApplicationService、DTO/VO和Mapper三元组以[物理接口与骨架字段设计](物理接口与骨架字段设计.md)为准；本文件的`M04.定位xxx`是逻辑端口ID。

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-总纲与约定/00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

## 1. Controller入口逐项映射

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位001 | GET /system/process/templates/context | 详细设计.md | M04.定位001 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位002 | GET /system/process/templates/{templateId} | 详细设计.md | M04.定位002 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位003 | GET /system/process/templates/{templateId}/versions | 详细设计.md | M04.定位003 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位004 | GET /system/process/templates/{templateId}/versions/{versionId} | 详细设计.md | M04.定位004 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位005 | POST /system/process/templates/binding-preview | 详细设计.md | M04.定位005 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位006 | POST /system/process/templates | 详细设计.md | M04.定位006 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位007 | PUT /system/process/templates/{templateId} | 详细设计.md | M04.定位007 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位008 | POST /system/process/templates/{templateId}/copies | 详细设计.md | M04.定位008 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位009 | PUT /system/process/templates/{templateId}/status | 详细设计.md | M04.定位009 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位010 | POST /system/process/templates/{templateId}/delete | 详细设计.md | M04.定位010 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位011 | GET /system/process/templates/list | 详细设计.md | M04.定位011 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位012 | POST /system/process/templates/candidates | 详细设计.md | M04.定位012 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位013 | GET /system/process/templates/model-options | 详细设计.md | M04.定位013 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位014 | POST /system/process/templates/model-facts | 详细设计.md | M04.定位014 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位015 | POST /system/process/templates/feeding-resource-facts | 详细设计.md | M04.定位015 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位016 | POST /system/process/templates/sampling-resource-facts | 详细设计.md | M04.定位016 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位017 | GET /system/process/workflow/list | 详细设计.md | M04.定位017 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位018 | GET /system/process/workflow/{nodeId} | 详细设计.md | M04.定位018 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位019 | PUT /system/process/workflow/{nodeId} | 详细设计.md | M04.定位019 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位020 | PUT /system/process/workflow/{nodeId}/status | 详细设计.md | M04.定位020 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位021 | GET /system/lab/lab/{labId}/workflows | 详细设计.md | M04.定位021 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位022 | PUT /system/lab/lab/{labId}/workflows | 详细设计.md | M04.定位022 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位023 | POST /system/lab/lab/{labId}/workflows/clear | 详细设计.md | M04.定位023 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| M04-SVC01 | exportForCandidate | 详细设计.md §12、工程版本固定与评审收尾.md | CTRL-INTERNAL | 仅M03可信调用；固定完整TemplatePackage/hash，不写培养、不下设备 |
| M04-SVC02 | validateForActivation | 详细设计.md §12 | CTRL-INTERNAL | 纯校验；hash/设备/审批/工程未知均阻断，不写双方主表 |
| M04-SVC03 | decodeFixedPackage | 详细设计.md §12 | CTRL-INTERNAL | 只解释调用方提供的固定包；不按templateId追当前版本 |

## 4. 模块内调用约束

- HTTP字段必须先映射为 M04 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

本文件登记23个目录内HTTP入口、3个非Controller内部端口、0个尾部补登记入口。数量校验只防漏项；逐接口仍须以来源契约完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。
