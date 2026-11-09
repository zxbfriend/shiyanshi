# M05 Controller 请求调用时序设计

> INTEGRATION-20261010：三类检测链先固定样品/派发/位置及配置身份，再调用检测适配器；可信接收先保存证据、唯一关联和版本校验，再发布有效结果。派发UNKNOWN保持占用，部分结果不代表整任务终结，结果接收不直接开泵。见[检测接入契约](三类实验室检测接入契约.md)，沿用既有Controller和内部接收契约。

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-总纲与约定/00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

## 1. Controller入口逐项映射

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位001 | POST /detect/result-corrections/preview | 受控更正与审计保留设计.md | M05.定位001 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位002 | POST /detect/result-corrections/{id}/decision-preview | 受控更正与审计保留设计.md | M05.定位002 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位003 | POST /detect/result-corrections/{id}/decisions | 受控更正与审计保留设计.md | M05.定位003 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位004 | POST /detect/result-corrections/{id}/withdraw | 受控更正与审计保留设计.md | M05.定位004 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位005 | GET /detect/result-corrections/{id} | 受控更正与审计保留设计.md | M05.定位005 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位006 | GET /detect/workbench/queue | 可配置发送暂存与删除规则设计.md | M05.定位006 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位007 | POST /detect/workbench/rules/evaluate | 可配置发送暂存与删除规则设计.md | M05.定位007 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位008 | POST /detect/workbench/sample/save-draft | 可配置发送暂存与删除规则设计.md | M05.定位008 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位009 | POST /detect/workbench/sample/save-draft/batch | 可配置发送暂存与删除规则设计.md | M05.定位009 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位010 | POST /detect/workbench/sample/send | 可配置发送暂存与删除规则设计.md | M05.定位010 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位011 | POST /detect/workbench/sample/send/batch | 可配置发送暂存与删除规则设计.md | M05.定位011 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位012 | DELETE /detect/workbench/sample/{sampleId} | 可配置发送暂存与删除规则设计.md | M05.定位012 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位013 | POST /detect/workbench/sample/delete/batch | 可配置发送暂存与删除规则设计.md | M05.定位013 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位014 | POST /detect/workbench/sample/send | 型号入参样例.md | M05.定位014 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位015 | GET /detect/workbench/operations/{requestId} | 型号入参样例.md | M05.定位015 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位016 | POST /detect/workbench/sample/send/batch | 型号入参样例.md | M05.定位011 | CTRL-APR | 样例引用定位011同一canonical端口；候选/hash固定，锁内全量重验 |
| 定位017 | GET /detect/workbench/operations/{requestId} | 型号入参样例.md | M05.定位017 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位018 | POST /detect/workbench/sample/send | 型号入参样例.md | M05.定位018 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位019 | GET /detect/workbench/operations/{requestId} | 型号入参样例.md | M05.定位019 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位020 | POST /detect/workbench/sample/send/batch | 型号入参样例.md | M05.定位011 | CTRL-APR | 样例引用定位011同一canonical端口；候选/hash固定，锁内全量重验 |
| 定位021 | GET /detect/workbench/operations/{requestId} | 型号入参样例.md | M05.定位021 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位022 | POST /detect/workbench/sample/send/batch | 型号入参样例.md | M05.定位011 | CTRL-APR | 样例引用定位011同一canonical端口；候选/hash固定，锁内全量重验 |
| 定位023 | GET /detect/workbench/operations/{requestId} | 型号入参样例.md | M05.定位023 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位024 | POST /detect/workbench/sample/send | 型号入参样例.md | M05.定位024 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位025 | GET /detect/workbench/operations/{requestId} | 型号入参样例.md | M05.定位025 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位026 | POST /detect/workbench/sample/send/batch | 型号入参样例.md | M05.定位011 | CTRL-APR | 样例引用定位011同一canonical端口；候选/hash固定，锁内全量重验 |
| 定位027 | GET /detect/workbench/operations/{requestId} | 型号入参样例.md | M05.定位027 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位028 | POST /rules/evaluate | 检测工作台接口与位置生命周期.md | M05.定位028 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位029 | POST /sample/save-draft | 检测工作台接口与位置生命周期.md | M05.定位029 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位030 | POST /sample/save-draft/batch | 检测工作台接口与位置生命周期.md | M05.定位030 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位031 | POST /sample/send | 检测工作台接口与位置生命周期.md | M05.定位031 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位032 | POST /sample/send/batch | 检测工作台接口与位置生命周期.md | M05.定位032 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位033 | DELETE /sample/{sampleId} | 检测工作台接口与位置生命周期.md | M05.定位033 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位034 | POST /sample/delete/batch | 检测工作台接口与位置生命周期.md | M05.定位034 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位035 | GET /operations/{requestId} | 检测工作台接口与位置生命周期.md | M05.定位035 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位036 | GET /queue | 检测工作台接口与位置生命周期.md | M05.定位036 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位037 | GET /detect/record/page | 检测记录与结果操作设计.md | M05.定位037 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位038.1 | GET /detect/record/projects | 检测记录与结果操作设计.md | M05.定位038.1 | CTRL-QRY | 只读；当前项目授权范围过滤后返回选项 |
| 定位038.2 | GET /detect/record/batches | 检测记录与结果操作设计.md | M05.定位038.2 | CTRL-QRY | 只读；校验projectId后按批次授权范围返回选项 |
| 定位038.3 | GET /detect/record/detectors | 检测记录与结果操作设计.md | M05.定位038.3 | CTRL-QRY | 只读；校验labId后按设备授权范围返回选项 |
| 定位039 | GET /detect/record/{resultId}/detail | 检测记录与结果操作设计.md | M05.定位039 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位040 | GET /detect/workbench/result/{resultId}/sample-no-history | 检测记录与结果操作设计.md | M05.定位040 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位041 | PUT /detect/workbench/result/{resultId}/sample-no | 检测记录与结果操作设计.md | M05.定位041 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位042 | PUT /detect/workbench/result/{resultId}/upload | 检测记录与结果操作设计.md | M05.定位042 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位043 | PUT /detect/workbench/result/{resultId}/exception | 检测记录与结果操作设计.md | M05.定位043 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位044 | PUT /detect/detresult/item/{resultItemId}/void | 检测记录与结果操作设计.md | M05.定位044 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位045 | DELETE /detect/detresult/{resultId} | 检测记录与结果操作设计.md | M05.定位045 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位046 | POST /detect/workbench/results/preview-delete | 检测记录与结果操作设计.md | M05.定位046 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位047 | PUT /detect/workbench/sample/{sampleId}/clear | 检测记录与结果操作设计.md | M05.定位047 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位048 | PUT /detect/workbench/sample/clear/batch | 检测记录与结果操作设计.md | M05.定位048 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位049.1 | POST /detect/report-jobs/preview | 签批记录与报告导出设计.md | M05.定位049.1 | CTRL-JOB | 作业先提交；事务外生成/上传；下载时重新鉴权 |
| 定位049.2 | POST /detect/report-jobs | 签批记录与报告导出设计.md | M05.定位049.2 | CTRL-JOB | 作业先提交；事务外生成/上传；下载时重新鉴权 |
| 定位049.3 | GET /detect/report-jobs/{jobId} | 签批记录与报告导出设计.md | M05.定位049.3 | CTRL-JOB | 作业先提交；事务外生成/上传；下载时重新鉴权 |
| 定位049.4 | GET /detect/report-jobs/{jobId}/file | 签批记录与报告导出设计.md | M05.定位049.4 | CTRL-JOB | 作业先提交；事务外生成/上传；下载时重新鉴权 |
| 定位050 | POST /detect/sign-console/preview-action | 详细设计.md | M05.定位050 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位051 | GET /detect/sign-console/projects | 详细设计.md | M05.定位051 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位052 | GET /detect/sign-console/batches | 详细设计.md | M05.定位052 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位053 | POST /detect/sign-console/query | 详细设计.md | M05.定位053 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位054 | POST /detect/sign-console/sign | 详细设计.md §11.2—11.4 | M05-SIGN-API02 | CTRL-CMD | 六动作共享固定验证器；本接口仅SIGN；整批原子提交 |
| 定位055 | POST /detect/sign-console/audit | 详细设计.md §11.2—11.4 | M05-SIGN-API03 | CTRL-CMD | 六动作共享固定验证器；本接口仅REVIEW；签审分离 |
| 定位056 | POST /detect/sign-console/revoke-sign | 详细设计.md §11.2—11.4 | M05-SIGN-API04 | CTRL-CMD | 六动作共享固定验证器；仅当前有效签名人撤销 |
| 定位057 | POST /detect/sign-console/revoke-audit | 详细设计.md §11.2—11.4 | M05-SIGN-API05 | CTRL-CMD | 六动作共享固定验证器；仅当前有效审核人撤销 |
| 定位058 | POST /detect/sign-console/void | 详细设计.md §11.2—11.4 | M05-SIGN-API06 | CTRL-CMD | 六动作共享固定验证器；仅结果级VOID，不级联其他检测类型 |
| 定位059 | POST /detect/sign-console/revoke-void | 详细设计.md §11.2—11.4 | M05-SIGN-API07 | CTRL-CMD | 六动作共享固定验证器；恢复准确beforeStatus |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

## 2. 目录尾部补登记入口

下列入口出现在目录的后续补登记区。本文给出稳定调用映射ID；原业务接口ID（如CU-R01、OBS-Q01）仍以对应来源契约为准，二者必须在实现清单中同时登记。

| 调用映射ID | HTTP入口 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- |
| SUP-001 | POST /detect/result-corrections | M05.SUP-001 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| SUP-002 | GET /detect/result-corrections | M05.SUP-002 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| DET-I01 | validateDetectionCandidate | 自动检测与跨模块结果契约.md | CTRL-INTERNAL | 只读预检，不预占、不派发 |
| DET-I02 | reserveDetectionOrder | 自动检测与跨模块结果契约.md | CTRL-INTERNAL | M07拥有reservation；同培养冲突守卫与防重 |
| DET-I03 | prepareDetection | 自动检测与跨模块结果契约.md | CTRL-INTERNAL | M05固定样品/能力/派发快照，结果PREPARED |
| DET-I04 | executePreparedDetection | 自动检测与跨模块结果契约.md | CTRL-EXT | 先持久化INVOKING，事务外物理调用 |
| DET-I05 | getDetectionProgress | 自动检测与跨模块结果契约.md | CTRL-INTERNAL | 只查原order/dispatch，不触发新检测 |
| DET-I06 | getResultRevision | 自动检测与跨模块结果契约.md | CTRL-INTERNAL | 精确不可变版本，不回退最新 |
| DET-I07 | queryEligibleResults/resolveEffectiveResult | 自动检测与跨模块结果契约.md、受控更正与审计保留设计.md | CTRL-INTERNAL | 当前有效版本/hash一致；旧消费者不截断schema2 |

## 4. 模块内调用约束

- HTTP字段必须先映射为 M05 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

2026-11-07 S04增量：M05-069按CTRL-QRY进入M05自有样品/派发绑定查询，再通过M02/M01既有读取合同补设备/人员投影，结果关联可空；M05-070复用同筛选与权限取全量一致性快照，事务外生成Excel。字段与失败分支见[设备使用记录专题](设备使用记录查询与导出契约.md)。069/070是目标设计而非已实现声明，不新增outbox、租约或设备调用。

六个签批入口仍先预检混选，再对确认的合格集合做锁内全量重验。需审批的VOID在本次事务仅提交候选/申请并保持原结果，审批决定到达后M05复核版本后才写作废与审计；免审卡片同次直接生效。不是全批先作废再等待审批。Load Sample模式/任务动作由M07编排，M05只接受固定检测交接及读取结果进度，不在Controller调用设备或原BatchJob。

本文件已显式登记三个检测记录候选查询和M05-SIGN-API02—07六个写接口。型号样例中的重复路径只引用对应canonical应用端口，不另计新接口；canonical HTTP与内部契约总数由接口骨架清单去重校验，不再用表格行数手工推导。逐接口仍须完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。
# UNKNOWN 恢复时序增补（2026-10-26）

预览/执行均先鉴权、核对逐派发核准及 M02 精确来源；外部源库只读定位在事务外。执行进入 SYSTEM 管理守卫→实验室/设备→样品/结果→派发/原证据锁→重验原代次和版本→追加恢复事件→推进派发受理或拒绝预占→审计与回执同事务。BGA 后续由既有接受投影和正式查表采集继续推进，不在恢复事务内做外部读取或发送。失败保持 UNKNOWN，不换键重发，不采用人工取消路径。

## SC052作废审批目标时序（2026-11-07，未编码）

原签名台VOID Controller鉴权/解析双头→同M05应用服务预览及确认集合→锁内原权限/结果版本/状态重验→逐卡真实SC052判策。免审沿原VOID写；需审只建M05不可变候选及M06审批关联/提交审计，不写成功VOID或实际结果revision。M06交付经M05薄适配→同M05应用重验→原VOID写/应用回执/审计同事务；DISCARD原结果不动，已知版本变化CONFLICT、依赖失败回滚。原未知请求通过M05-071目标只读核原本人原UUID，不换键。完整目标schema/响应及结构授权差异见[结果操作第7节](检测记录与结果操作设计.md#7-sc052最小目标交接仅设计未编码未安装)；当前尚未实现，不用旧DIRECT回归证明需审链。
