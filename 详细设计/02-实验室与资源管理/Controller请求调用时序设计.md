# M02 Controller 请求调用时序设计

## S04库存258—264后续参考（Q-6-02退出本期）

258/259：页面→库存查询SDK目标→M02库存Controller目标→本模块查询应用服务→M02现有配置读取及原库存/任务/检测拥有方Port；先当前功能/实验室/对象范围，再读取卡片/孔位，最后分页或返回原布局。尚未定位真实运行页、Controller及原库存维护Port，不能把逻辑链命名当已接线。

260/261：双头及形态校验→应用服务全量核所选原对象、版本、线下完成确认及原动作资格→行锁或对象版本重验→原模板/孔位变更与审计同事务；若实际维护方在外部，事务外调用原维护接口，按原次身份读取结果，不承诺本地回滚外部副作用。

262—264：校验双头/对象/原动作→原控制方Port（本地事务外设备I/O）→按真实结果记录本次原操作及审计→页面成功/失败/结果未确认。模式切自动先全量耗材核算；任何设备调用前不显示成功。输入、逐资源规则及局部缺口以[库存契约](库存耗材工作台与原执行方交付契约.md)为准，不新增数据库/队列/租约。

2026-11-04 默认连接占用接线：GET 完成控制器身份/实验室 VIEW 校验后，通过 M03 ControllerOccupancyPort 读取有效占用；PUT 在既有 SYSTEM 守卫回调内重读，存在有效占用则拒绝修改实验室默认配置。列表按授权后的当前页分实验室批量读，不逐控制器查询。完整字段和来源分支见[默认连接契约 OC-20261104](默认连接与打印排版接口契约.md#oc-20261104控制器有效占用与默认连接来源)。

## CB-20261024：独立台式控制器与罐体绑定（最新确认）

台式控制器为独立实验室实例，主键沿用 `lab_bench_reactor_controller.connection_id`，对外命名 `controllerId`。允许控制器尚未绑定罐体；一个控制器可绑定多个罐体，一个罐体最多绑定一个控制器。规范关联改为 `lab_bench_reactor.controller_id → lab_bench_reactor_controller.connection_id`，可空且索引不唯一，不新增表。关联必须同实验室、目标有效；变更仍须实验室操作权限、SYSTEM管理守卫、真实设备使用/引用检查及审计，不以型号、编号或名称猜测关系。

控制器 `reactor_id` 仅保留迁移兼容事实，允许NULL，停止新增业务依赖或双写；旧字段不得限制新控制器的独立生命周期或一控多罐关系。反应器旧 `controller_no` 亦为兼容列，真实编号只读自控制器 `controller_no`。型号采用统一 `dev_reactor_model` 的有效 `BENCH_CONTROLLER`，型号无实验室归属；`model_name` 为型号名称，`spec` 为规格，均不代替实例编号或资产号。小试上游按 `lab_lab.lab_type='1'` 与授权实验室集合过滤实例 `lab_id`，不按型号归属筛选。

默认连接新主接口为 `GET /lab/pumpconnection/controller/{controllerId}`、`PUT /lab/pumpconnection/controller/{controllerId}`。沿原查询/编辑功能权限和实验室准入，PUT沿Header/WriteMeta双头，读响应顶层返回SYSTEM `managementRevision`；`controllerId` 解析为 `connection_id`，响应同时保留 `connectionId`。`controllerNo` 取该控制器真实编号，通道按稳定 `channelId` 读写，不要求先绑定罐体。响应 `reactorId` 为旧兼容字段，可空且不得解释为完整罐体集合。

旧 `GET/PUT /lab/pumpconnection/reactor/{reactorId}` 保留兼容：由该罐体的 `controller_id` 解析控制器并复用同一配置链，禁止按控制器旧 `reactor_id`、编号或“最后一条”解析；未绑定返回配置未就绪，不创建控制器或自动绑定。旧调用不能通过控制器配置修改罐体绑定。一个控制器的默认连接及通道由多个罐体共用，配置前必须检查该控制器及全部已绑定罐体的使用状态，任一阻断或事实未知即整次拒绝，不以当前入口罐体空闲代替全量检查。

空库仍只执行开发基线01/02/03；既有库单独使用 [RM-04升级来源](RM-04-现有开发库控制器罐体绑定升级.sql)，明确确认目标、停写和备份后执行。仅依据唯一、同实验室且无冲突的旧 `reactor_id` 回填；已有不同绑定、失效目标或多连接歧义拒绝，不猜测、不覆盖。脚本支持修正冲突后重跑；MySQL DDL隐式提交，不能承诺整个DDL与回填原子回滚。没有执行SQL或运行验收的证据时仅标静态设计同步，不能宣称数据库/HTTP/浏览器通过。

2026-10-21 RM-Q06/RM-C04：GET经查询权限、正ID校验和只读事务读取有效型号及PID行，返回能力开关、五个固定组和顶层SYSTEM修订；PUT经编辑权限/WriteMeta→形态与逐回路范围校验→SYSTEM回执/CAS→锁有效型号并重验温度/压力能力→软删旧有效PID→按新ID插入整组→聚合审计、修订与回执同事务提交。关闭能力的型号基本编辑同事务退役对应JACKET_TEMP/VESSEL_PRESSURE行；型号删除退役全部PID行。PID不调用实验室、设备或M04模板写链。

2026-10-20 RM-C01/C02泵类型：请求白名单/类型与引用配对校验→SYSTEM版本/幂等守卫→有效外置资源蠕动泵型号校验→原有引用/量程/通道身份守卫→主从差异持久化→包含泵类型和引用的审计→版本与回执同事务提交。M02-153在同一SYSTEM守卫内检查有效统一型号通道引用，存在则拒绝整批软删除。候选权限不变，外置量程不从L/min换算g/min；具体字段见统一型号专题。

2026-10-20 M02-227：双头/Path与Body核对→SYSTEM守卫回执/版本→实验室锁与MANAGE权限→连接锁→M07未决命令→expectedModelId核对→锁有效BENCH_CONTROLLER→M03 changedFields=["model_id"]使用检查→model_id CAS与证据→型号变化时初始化空控制器普通泵→model_id/证据/initialized_channels审计→版本与回执。已有通道不自动重建，失败整组回滚；同型号证据更新跳过初始化。后续工程解析/工艺消费尚未整体切换，不能宣称端到端验收。

2026-10-20 RM-C03正式DELETE源码接线：功能鉴权/WriteMeta→ID全量校验、去重和升序规范化→SYSTEM守卫原回执/CAS→按升序锁型号→整批引用重验与主从快照→逐型号软删通道/主表并核对行数→审计/版本/回执同提交。异常不跳过对象，预检不替代写内校验；HTTP/SQL事务实际运行尚未验证。PUT编辑仍未接线。

2026-10-20 RM-Q04/Q05：Controller功能鉴权→ReactorModelPrecheckService只读可重复读事务。删除预检读取有效型号→M02实例/工程资料计数及M04 RM-REF01当前模板引用→组装瞬时允许结果；唯一预检验证目标类型/名称/可选有效排除对象→按类型名称计数。无数据库写入，不授予后续操作资格。正式PUT/DELETE尚未接线，不能用预检代替守卫事务内重验。

2026-10-20 RM-C02：PUT /device/reactormodel/{modelId} → 权限/WriteMeta → ReactorModelEditService规范化载荷 → SYSTEM守卫回执及版本 → 锁型号、读取明细和引用 → 差异计划及全量前置核验 → 明细软删/原ID更新/插入 → 主型号更新 → 聚合before/after审计和回执同提交。已引用型号降低量程当前明确CONFIGURATION_INCOMPLETE，不用尚未闭合的使用事实放行。重放不再次写入，无设备副作用；[正式契约](逐接口完整契约清单.md#rm-c02-统一型号编辑2026-10-20登记)为准。

2026-10-20 RM-Q01/Q02/Q03：列表/详情/候选由DevReactorModelController鉴权后调用ReactorModelQueryService，校验筛选/ID，进入只读可重复读事务，再经DevReactorModelMapper读取。列表分页对象为型号主表，详情过滤有效父子行；列表/详情挂CurrentManagementRevision，候选不作为写版本来源。没有实验室范围或隐藏参数完整性门槛。源码已接线，HTTP及数据库未验收。

2026-10-20 RM-C01：POST /device/reactormodel → 新增权限鉴权/WriteMeta双头解析 → ReactorModelApplicationService.create形态校验与规范化 → ManagementGuardExecutor(M02-RM-CREATE)识别原回执及SYSTEM版本 → ReactorModelCreateWriter在已有事务内判重、校验压力字典、生成主从ID并插入 → 聚合审计 → 守卫版本/回执同提交。重放不执行Writer，无设备或网络副作用。公开契约见[RM-C01](逐接口完整契约清单.md#rm-c01-统一型号新增2026-10-20登记)，其他新路由尚未接线，旧链暂留。

2026-10-18：[固定执行器HTTP适配与关联发布](固定执行器HTTP适配与关联发布契约.md)补齐既有CMD-I01/I02客户端时序及既有设备内口发布客户端；网络提交/查单只能在事务外，登记仍经M02-INGRESS-V1验签和拥有域核对，不扩充Controller控制设备入口。

> INTEGRATION-20261010：三类设备的运行链为M07持久化命令并提交本地事务 → M02 CMD-I01核对执行身份/资源fence/配置能力 → 协议适配 → 返回事实 → M07持久化状态；CMD-I02只查询原命令，不暗中重发。配置Controller的保存/加载不得隐式开泵。详细前置与失败处理见[设备适配契约](三类实验室设备适配契约.md)，不增加当前Controller入口。

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-总纲与约定/00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

## 1. Controller入口逐项映射

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位001.1 | GET /system/lab/engineering/profiles?scopeKind&modelKind&modelId&deviceKind&deviceId | 控制器型号与工程参数收尾契约.md | M02.定位001.1 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位001.2 | POST /system/lab/engineering/profiles | 控制器型号与工程参数收尾契约.md | M02.定位001.2 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位002 | POST /system/lab/controllers/{connectionId}/model-verification | 控制器型号与工程参数收尾契约.md | M02.定位002 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位003 | GET /lab/detectorconfig/{detectorId}/available-items | 检测与资源配置详细设计.md | M02.定位003 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位004 | POST /lab/detectorconfig/{detectorId}/batch-save | 检测与资源配置详细设计.md | M02.定位004 | CTRL-APR | 候选/hash固定；审批交付幂等；UNKNOWN按原键查询 |
| 定位005.1 | GET /detect/detection-rule/labs | 检测与资源配置详细设计.md | M02.定位005.1 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位005.2 | GET /detect/detection-rule/config/{labId} | 检测与资源配置详细设计.md | M02.定位005.2 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位005.3 | PUT /detect/detection-rule/{labId}/{ruleItem} | 检测与资源配置详细设计.md | M02.定位005.3 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位007.1 | GET /lab/consumptionRule/bootstrap | 检测与资源配置详细设计.md | M02.定位007.1 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位008 | GET /lab/bottle-config/consumables | 检测与资源配置详细设计.md | M02.定位008 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位009 | GET /lab/bottle-config/layout | 检测与资源配置详细设计.md | M02.定位009 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位010 | PUT /lab/bottle-config/sampling-units/{labId}/{unitCode} | 检测与资源配置详细设计.md | M02.定位010 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位011 | PUT /lab/bottle-config/feeding-slots/{bottleId} | 检测与资源配置详细设计.md | M02.定位011 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位012 | GET /device/benchreactor/list | 设备型号库设计.md | M02.定位012 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位013 | GET /device/benchreactor/{modelId} | 设备型号库设计.md | M02.定位013 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位014 | POST /device/benchreactor | 设备型号库设计.md | M02.定位014 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位015 | PUT /device/benchreactor | 设备型号库设计.md | M02.定位015 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位016 | GET /device/benchreactor/{modelId}/check-delete | 设备型号库设计.md | M02.定位016 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位017 | DELETE /device/benchreactor/{modelIds} | 设备型号库设计.md | M02.定位017 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位018 | GET /device/benchreactor/check-unique | 设备型号库设计.md | M02.定位018 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位019.1 | GET /device/devdetector/{modelId}/runtime-profile | 设备型号库设计.md | M02.定位019.1 | CTRL-QRY | 只读；返回完整运行配置和profileRevision，不写设备或配置 |
| 定位019.2 | PUT /device/devdetector/{modelId}/runtime-profile | 设备型号库设计.md | M02.定位019.2 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位020 | GET /lab/lab/list | 详细设计.md | M02.定位020 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位021 | GET /lab/lab/{labId} | 详细设计.md | M02.定位021 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位022 | POST /lab/lab | 详细设计.md | M02.定位022 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位023 | PUT /lab/lab | 详细设计.md | M02.定位023 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位024 | GET /lab/lab/{labId}/check-disable | 详细设计.md | M02.定位024 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位025 | PUT /lab/lab/{labId}/status | 详细设计.md | M02.定位025 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位026 | GET /lab/lab/{labId}/authorized-users | 详细设计.md | M02.定位026 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位027 | GET /lab/communication/getByDevice | 通讯与设备公共契约.md | M02.定位027 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位028 | GET /lab/communication/{commId} | 通讯与设备公共契约.md | M02.定位028 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位029 | POST /lab/communication | 通讯与设备公共契约.md | M02.定位029 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位030 | PUT /lab/communication | 通讯与设备公共契约.md | M02.定位030 | CTRL-CMD | M02-209守卫内SYSTEM/配置锁→身份权限→M05/M07同代完整使用事实→旧desired_revision CAS；在用或事实不完整均拒绝；审计/回执同提交，探活在提交后 |
| 定位031 | DELETE /lab/communication/{commIds} | 通讯与设备公共契约.md | M02.定位031 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位032 | GET /lab/labintegratedreactor/{integratedId} | 集成反应器型号与实例参数契约.md | M02.定位032 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位033 | POST /lab/labintegratedreactor | 集成反应器型号与实例参数契约.md | M02.定位033 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位034 | PUT /lab/labintegratedreactor/{integratedId} | 集成反应器型号与实例参数契约.md | M02.定位034 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

## 2. 规范全路径入口

本表从M02权威逐接口契约汇总完整路径，替代 `R/P/K/basePath`、`GET /list` 等生成模板。每个入口必须独立映射Controller和应用端口；旧别名只有在来源契约明确兼容时才共用实现。

| 全路径ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| HTTP-001 | GET /lab/observations/current | 接口目录与契约定位.md | M02.HTTP-001 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-002 | GET /lab/observations | 接口目录与契约定位.md | M02.HTTP-002 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-003 | GET /lab/observations/{observationId} | 接口目录与契约定位.md | M02.HTTP-003 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-004 | GET /lab/observation-receipts | 接口目录与契约定位.md | M02.HTTP-004 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-005 | POST /lab/observation-receipts/{id}/reprocess | 接口目录与契约定位.md | M02.HTTP-005 | CTRL-EXT | 重处理意图先提交；租约执行；结果可恢复 |
| HTTP-006 | GET /lab/observation-mappings | 接口目录与契约定位.md | M02.HTTP-006 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-007 | POST /lab/observation-mappings | 接口目录与契约定位.md | M02.HTTP-007 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-008 | GET /lab/labbenchreactor/list | 逐接口完整契约清单.md | M02.HTTP-008 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-009 | GET /lab/labbenchreactor/{reactorId} | 逐接口完整契约清单.md | M02.HTTP-009 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-010 | POST /lab/labbenchreactor | 逐接口完整契约清单.md | M02.HTTP-010 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-011 | PUT /lab/labbenchreactor | 逐接口完整契约清单.md | M02.HTTP-011 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-012 | GET /lab/labbenchreactor/{reactorId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-012 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-013 | DELETE /lab/labbenchreactor/{reactorIds} | 逐接口完整契约清单.md | M02.HTTP-013 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-014 | GET /lab/labbenchreactor/edit-options | 逐接口完整契约清单.md | M02.HTTP-014 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-015 | POST /lab/labbenchreactor/export | 逐接口完整契约清单.md | M02.HTTP-015 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-016 | GET /lab/balance/list | 逐接口完整契约清单.md | M02.HTTP-016 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-017 | GET /lab/balance/{balanceId} | 逐接口完整契约清单.md | M02.HTTP-017 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-018 | POST /lab/balance | 逐接口完整契约清单.md | M02.HTTP-018 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-019 | PUT /lab/balance | 逐接口完整契约清单.md | M02.HTTP-019 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-020 | GET /lab/balance/{balanceId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-020 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-021 | DELETE /lab/balance/{balanceIds} | 逐接口完整契约清单.md | M02.HTTP-021 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-022 | GET /lab/balance/edit-options | 逐接口完整契约清单.md | M02.HTTP-022 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-023 | POST /lab/balance/export | 逐接口完整契约清单.md | M02.HTTP-023 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-024 | GET /lab/labperistalticpump/list | 逐接口完整契约清单.md | M02.HTTP-024 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-025 | GET /lab/labperistalticpump/{pumpId} | 逐接口完整契约清单.md | M02.HTTP-025 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-026 | POST /lab/labperistalticpump | 逐接口完整契约清单.md | M02.HTTP-026 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-027 | PUT /lab/labperistalticpump | 逐接口完整契约清单.md | M02.HTTP-027 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-028 | GET /lab/labperistalticpump/{pumpId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-028 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-029 | DELETE /lab/labperistalticpump/{pumpIds} | 逐接口完整契约清单.md | M02.HTTP-029 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-030 | GET /lab/labperistalticpump/edit-options | 逐接口完整契约清单.md | M02.HTTP-030 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-031 | POST /lab/labperistalticpump/export | 逐接口完整契约清单.md | M02.HTTP-031 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-032 | GET /lab/labairpump/list | 逐接口完整契约清单.md | M02.HTTP-032 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-033 | GET /lab/labairpump/{airPumpId} | 逐接口完整契约清单.md | M02.HTTP-033 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-034 | POST /lab/labairpump | 逐接口完整契约清单.md | M02.HTTP-034 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-035 | PUT /lab/labairpump | 逐接口完整契约清单.md | M02.HTTP-035 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-036 | GET /lab/labairpump/{airPumpId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-036 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-037 | DELETE /lab/labairpump/{airPumpIds} | 逐接口完整契约清单.md | M02.HTTP-037 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-038 | GET /lab/labairpump/edit-options | 逐接口完整契约清单.md | M02.HTTP-038 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-039 | POST /lab/labairpump/export | 逐接口完整契约清单.md | M02.HTTP-039 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-040 | GET /lab/labdetector/list | 逐接口完整契约清单.md | M02.HTTP-040 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-041 | GET /lab/labdetector/{detectorId} | 逐接口完整契约清单.md | M02.HTTP-041 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-042 | POST /lab/labdetector | 逐接口完整契约清单.md | M02.HTTP-042 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-043 | PUT /lab/labdetector | 逐接口完整契约清单.md | M02.HTTP-043 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-044 | GET /lab/labdetector/{detectorId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-044 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-045 | DELETE /lab/labdetector/{detectorIds} | 逐接口完整契约清单.md | M02.HTTP-045 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-046 | GET /lab/labdetector/edit-options | 逐接口完整契约清单.md | M02.HTTP-046 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-047 | POST /lab/labdetector/export | 逐接口完整契约清单.md | M02.HTTP-047 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-048 | GET /lab/labintegratedreactor/list | 逐接口完整契约清单.md | M02.HTTP-048 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-049 | GET /lab/labintegratedreactor/{integratedId} | 逐接口完整契约清单.md | M02.HTTP-049 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-050 | POST /lab/labintegratedreactor | 逐接口完整契约清单.md | M02.HTTP-050 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-051 | PUT /lab/labintegratedreactor/{integratedId} | 逐接口完整契约清单.md | M02.HTTP-051 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-052 | GET /lab/labintegratedreactor/{integratedId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-052 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-053 | DELETE /lab/labintegratedreactor/{integratedIds} | 逐接口完整契约清单.md | M02.HTTP-053 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-054 | GET /lab/labintegratedreactor/edit-options | 逐接口完整契约清单.md | M02.HTTP-054 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-055 | POST /lab/labintegratedreactor/export | 逐接口完整契约清单.md | M02.HTTP-055 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-056 | GET /lab/culturecontainer/list | 逐接口完整契约清单.md | M02.HTTP-056 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-057 | GET /lab/culturecontainer/{containerId} | 逐接口完整契约清单.md | M02.HTTP-057 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-058 | POST /lab/culturecontainer | 逐接口完整契约清单.md | M02.HTTP-058 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-059 | PUT /lab/culturecontainer | 逐接口完整契约清单.md | M02.HTTP-059 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-060 | GET /lab/culturecontainer/{containerId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-060 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-061 | DELETE /lab/culturecontainer/{containerIds} | 逐接口完整契约清单.md | M02.HTTP-061 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-062 | GET /lab/culturecontainer/edit-options | 逐接口完整契约清单.md | M02.HTTP-062 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-063 | POST /lab/culturecontainer/export | 逐接口完整契约清单.md | M02.HTTP-063 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-064 | GET /lab/labfloorscale/list | 逐接口完整契约清单.md | M02.HTTP-064 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-065 | GET /lab/labfloorscale/{scaleId} | 逐接口完整契约清单.md | M02.HTTP-065 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-066 | POST /lab/labfloorscale | 逐接口完整契约清单.md | M02.HTTP-066 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-067 | PUT /lab/labfloorscale | 逐接口完整契约清单.md | M02.HTTP-067 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-068 | GET /lab/labfloorscale/{scaleId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-068 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-069 | DELETE /lab/labfloorscale/{scaleIds} | 逐接口完整契约清单.md | M02.HTTP-069 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-070 | GET /lab/labfloorscale/edit-options | 逐接口完整契约清单.md | M02.HTTP-070 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-071 | POST /lab/labfloorscale/export | 逐接口完整契约清单.md | M02.HTTP-071 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-072 | GET /lab/downstreamdevice/list | 逐接口完整契约清单.md | M02.HTTP-072 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-073 | GET /lab/downstreamdevice/{deviceId} | 逐接口完整契约清单.md | M02.HTTP-073 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-074 | POST /lab/downstreamdevice | 逐接口完整契约清单.md | M02.HTTP-074 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-075 | PUT /lab/downstreamdevice | 逐接口完整契约清单.md | M02.HTTP-075 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-076 | GET /lab/downstreamdevice/{deviceId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-076 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-077 | DELETE /lab/downstreamdevice/{deviceIds} | 逐接口完整契约清单.md | M02.HTTP-077 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-078 | GET /lab/downstreamdevice/edit-options | 逐接口完整契约清单.md | M02.HTTP-078 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-079 | POST /lab/downstreamdevice/export | 逐接口完整契约清单.md | M02.HTTP-079 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-080 | GET /lab/soundalarm/list | 逐接口完整契约清单.md | M02.HTTP-080 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-081 | GET /lab/soundalarm/{alarmId} | 逐接口完整契约清单.md | M02.HTTP-081 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-082 | POST /lab/soundalarm | 逐接口完整契约清单.md | M02.HTTP-082 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-083 | PUT /lab/soundalarm | 逐接口完整契约清单.md | M02.HTTP-083 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-084 | GET /lab/soundalarm/{alarmId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-084 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-085 | DELETE /lab/soundalarm/{alarmIds} | 逐接口完整契约清单.md | M02.HTTP-085 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-086 | GET /lab/soundalarm/edit-options | 逐接口完整契约清单.md | M02.HTTP-086 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-087 | POST /lab/soundalarm/export | 逐接口完整契约清单.md | M02.HTTP-087 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-088 | GET /lab/printer/list | 逐接口完整契约清单.md | M02.HTTP-088 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-089 | GET /lab/printer/{printerId} | 逐接口完整契约清单.md | M02.HTTP-089 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-090 | POST /lab/printer | 逐接口完整契约清单.md | M02.HTTP-090 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-091 | PUT /lab/printer | 逐接口完整契约清单.md | M02.HTTP-091 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-092 | GET /lab/printer/{printerId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-092 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-093 | DELETE /lab/printer/{printerIds} | 逐接口完整契约清单.md | M02.HTTP-093 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-094 | GET /lab/printer/edit-options | 逐接口完整契约清单.md | M02.HTTP-094 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-095 | POST /lab/printer/export | 逐接口完整契约清单.md | M02.HTTP-095 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-096 | GET /lab/relay/list | 逐接口完整契约清单.md | M02.HTTP-096 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-097 | GET /lab/relay/{relayId} | 逐接口完整契约清单.md | M02.HTTP-097 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-098 | POST /lab/relay | 逐接口完整契约清单.md | M02.HTTP-098 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-099 | PUT /lab/relay | 逐接口完整契约清单.md | M02.HTTP-099 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-100 | GET /lab/relay/{relayId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-100 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-101 | DELETE /lab/relay/{relayIds} | 逐接口完整契约清单.md | M02.HTTP-101 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-102 | GET /lab/relay/edit-options | 逐接口完整契约清单.md | M02.HTTP-102 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-103 | POST /lab/relay/export | 逐接口完整契约清单.md | M02.HTTP-103 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-104 | PUT /lab/balance/changeMaintainStatus | 逐接口完整契约清单.md | M02.HTTP-104 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-105 | PUT /lab/labairpump/changeMaintainStatus | 逐接口完整契约清单.md | M02.HTTP-105 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-106 | PUT /lab/labfloorscale/changeMaintainStatus | 逐接口完整契约清单.md | M02.HTTP-106 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-107 | PUT /lab/labintegratedreactor/changeMaintainStatus | 逐接口完整契约清单.md | M02.HTTP-107 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-108 | PUT /lab/labperistalticpump/changeMaintainStatus | 逐接口完整契约清单.md | M02.HTTP-108 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-109 | GET /lab/pumpconnection/reactor/{reactorId} | 逐接口完整契约清单.md | M02.HTTP-109 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-110 | PUT /lab/pumpconnection/reactor/{reactorId} | 逐接口完整契约清单.md | M02.HTTP-110 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-111 | GET /lab/printer/{printerId}/layout | 逐接口完整契约清单.md | M02.HTTP-111 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-112 | POST /lab/printer/{printerId}/layout | 逐接口完整契约清单.md | M02.HTTP-112 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-113 | GET /device/benchreactor/list | 逐接口完整契约清单.md | M02.HTTP-113 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-114 | GET /device/benchreactor/{modelId} | 逐接口完整契约清单.md | M02.HTTP-114 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-115 | POST /device/benchreactor | 逐接口完整契约清单.md | M02.HTTP-115 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-116 | PUT /device/benchreactor | 逐接口完整契约清单.md | M02.HTTP-116 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-117 | GET /device/benchreactor/{modelId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-117 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-118 | DELETE /device/benchreactor/{modelIds} | 逐接口完整契约清单.md | M02.HTTP-118 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-119 | GET /device/benchreactor/check-unique | 逐接口完整契约清单.md | M02.HTTP-119 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-120 | GET /device/integratedreactor/list | 逐接口完整契约清单.md | M02.HTTP-120 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-121 | GET /device/integratedreactor/{modelId} | 逐接口完整契约清单.md | M02.HTTP-121 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-122 | POST /device/integratedreactor | 逐接口完整契约清单.md | M02.HTTP-122 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-123 | PUT /device/integratedreactor | 逐接口完整契约清单.md | M02.HTTP-123 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-124 | GET /device/integratedreactor/{modelId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-124 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-125 | DELETE /device/integratedreactor/{keys} | 逐接口完整契约清单.md | M02.HTTP-125 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-126 | GET /device/integratedreactor/check-unique | 逐接口完整契约清单.md | M02.HTTP-126 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-127 | GET /device/containerspec/list | 逐接口完整契约清单.md | M02.HTTP-127 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-128 | GET /device/containerspec/{specId} | 逐接口完整契约清单.md | M02.HTTP-128 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-129 | POST /device/containerspec | 逐接口完整契约清单.md | M02.HTTP-129 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-130 | PUT /device/containerspec | 逐接口完整契约清单.md | M02.HTTP-130 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-131 | GET /device/containerspec/{specId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-131 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-132 | DELETE /device/containerspec/{keys} | 逐接口完整契约清单.md | M02.HTTP-132 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-133 | GET /device/containerspec/check-unique | 逐接口完整契约清单.md | M02.HTTP-133 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-134 | GET /device/devfloorscale/list | 逐接口完整契约清单.md | M02.HTTP-134 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-135 | GET /device/devfloorscale/{modelId} | 逐接口完整契约清单.md | M02.HTTP-135 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-136 | POST /device/devfloorscale | 逐接口完整契约清单.md | M02.HTTP-136 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-137 | PUT /device/devfloorscale | 逐接口完整契约清单.md | M02.HTTP-137 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-138 | GET /device/devfloorscale/{modelId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-138 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-139 | DELETE /device/devfloorscale/{keys} | 逐接口完整契约清单.md | M02.HTTP-139 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-140 | GET /device/devfloorscale/check-unique | 逐接口完整契约清单.md | M02.HTTP-140 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-141 | GET /device/devdetector/list | 逐接口完整契约清单.md | M02.HTTP-141 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-142 | GET /device/devdetector/{modelId} | 逐接口完整契约清单.md | M02.HTTP-142 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-143 | POST /device/devdetector | 逐接口完整契约清单.md | M02.HTTP-143 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-144 | PUT /device/devdetector | 逐接口完整契约清单.md | M02.HTTP-144 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-145 | GET /device/devdetector/{modelId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-145 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-146 | DELETE /device/devdetector/{keys} | 逐接口完整契约清单.md | M02.HTTP-146 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-147 | GET /device/devdetector/check-unique | 逐接口完整契约清单.md | M02.HTTP-147 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-148 | GET /device/devperistalticpump/list | 逐接口完整契约清单.md | M02.HTTP-148 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-149 | GET /device/devperistalticpump/{modelId} | 逐接口完整契约清单.md | M02.HTTP-149 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-150 | POST /device/devperistalticpump | 逐接口完整契约清单.md | M02.HTTP-150 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-151 | PUT /device/devperistalticpump | 逐接口完整契约清单.md | M02.HTTP-151 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-152 | GET /device/devperistalticpump/{modelId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-152 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-153 | DELETE /device/devperistalticpump/{keys} | 逐接口完整契约清单.md | M02.HTTP-153 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-154 | GET /device/devperistalticpump/check-unique | 逐接口完整契约清单.md | M02.HTTP-154 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-155 | GET /device/devairpum/list | 逐接口完整契约清单.md | M02.HTTP-155 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-156 | GET /device/devairpum/{modelId} | 逐接口完整契约清单.md | M02.HTTP-156 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-157 | POST /device/devairpum | 逐接口完整契约清单.md | M02.HTTP-157 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-158 | PUT /device/devairpum | 逐接口完整契约清单.md | M02.HTTP-158 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-159 | GET /device/devairpum/{modelId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-159 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-160 | DELETE /device/devairpum/{keys} | 逐接口完整契约清单.md | M02.HTTP-160 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-161 | GET /device/devairpum/check-unique | 逐接口完整契约清单.md | M02.HTTP-161 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-162 | GET /device/devAnalyzerModel/list | 逐接口完整契约清单.md | M02.HTTP-162 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-163 | GET /device/devAnalyzerModel/{analyzerId} | 逐接口完整契约清单.md | M02.HTTP-163 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-164 | POST /device/devAnalyzerModel | 逐接口完整契约清单.md | M02.HTTP-164 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-165 | PUT /device/devAnalyzerModel | 逐接口完整契约清单.md | M02.HTTP-165 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-166 | GET /device/devAnalyzerModel/{analyzerId}/check-delete | 逐接口完整契约清单.md | M02.HTTP-166 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-167 | DELETE /device/devAnalyzerModel/{keys} | 逐接口完整契约清单.md | M02.HTTP-167 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-168 | GET /device/devAnalyzerModel/check-unique | 逐接口完整契约清单.md | M02.HTTP-168 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-169 | GET /lab/calibrationObject/list | 四类资源逐接口契约.md | M02.HTTP-169 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-170 | GET /lab/calibrationObject/{objectId} | 四类资源逐接口契约.md | M02.HTTP-170 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-171 | POST /lab/calibrationObject | 四类资源逐接口契约.md | M02.HTTP-171 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-172 | PUT /lab/calibrationObject | 四类资源逐接口契约.md | M02.HTTP-172 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-173 | DELETE /lab/calibrationObject/{objectIds} | 四类资源逐接口契约.md | M02.HTTP-173 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-174 | GET /lab/liquidBag/list | 四类资源逐接口契约.md | M02.HTTP-174 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-175 | GET /lab/liquidBag/{bagId} | 四类资源逐接口契约.md | M02.HTTP-175 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-176 | POST /lab/liquidBag | 四类资源逐接口契约.md | M02.HTTP-176 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-177 | PUT /lab/liquidBag | 四类资源逐接口契约.md | M02.HTTP-177 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-178 | DELETE /lab/liquidBag/{bagIds} | 四类资源逐接口契约.md | M02.HTTP-178 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-179 | GET /lab/feedMedium/list | 四类资源逐接口契约.md | M02.HTTP-179 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-180 | GET /lab/feedMedium/{mediumId} | 四类资源逐接口契约.md | M02.HTTP-180 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-181 | POST /lab/feedMedium | 四类资源逐接口契约.md | M02.HTTP-181 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-182 | PUT /lab/feedMedium | 四类资源逐接口契约.md | M02.HTTP-182 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-183 | DELETE /lab/feedMedium/{mediumIds} | 四类资源逐接口契约.md | M02.HTTP-183 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-184 | GET /resource/consumableMaster/list | 四类资源逐接口契约.md | M02.HTTP-184 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-185 | GET /resource/consumableMaster/{consumableId} | 四类资源逐接口契约.md | M02.HTTP-185 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-186 | POST /resource/consumableMaster | 四类资源逐接口契约.md | M02.HTTP-186 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-187 | PUT /resource/consumableMaster | 四类资源逐接口契约.md | M02.HTTP-187 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-188 | DELETE /resource/consumableMaster/{consumableIds} | 四类资源逐接口契约.md | M02.HTTP-188 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-189 | POST /lab/communication/export | 既有导出接口与文件响应契约.md | M02.HTTP-189 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-190 | POST /device/benchreactor/export | 既有导出接口与文件响应契约.md | M02.HTTP-190 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-191 | POST /device/integratedreactor/export | 既有导出接口与文件响应契约.md | M02.HTTP-191 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-192 | POST /device/containerspec/export | 既有导出接口与文件响应契约.md | M02.HTTP-192 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-193 | POST /device/devfloorscale/export | 既有导出接口与文件响应契约.md | M02.HTTP-193 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-194 | POST /device/devdetector/export | 既有导出接口与文件响应契约.md | M02.HTTP-194 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-195 | POST /device/devperistalticpump/export | 既有导出接口与文件响应契约.md | M02.HTTP-195 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-196 | POST /device/devairpum/export | 既有导出接口与文件响应契约.md | M02.HTTP-196 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-197 | POST /device/devAnalyzerModel/export | 既有导出接口与文件响应契约.md | M02.HTTP-197 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-198 | POST /lab/calibrationObject/export | 既有导出接口与文件响应契约.md | M02.HTTP-198 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-199 | POST /lab/liquidBag/export | 既有导出接口与文件响应契约.md | M02.HTTP-199 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-200 | POST /lab/feedMedium/export | 既有导出接口与文件响应契约.md | M02.HTTP-200 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-201 | POST /resource/consumableMaster/export | 既有导出接口与文件响应契约.md | M02.HTTP-201 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-202 | GET /lab/communication/getByDevice | 通讯逐接口字段与加载回执.md | M02.HTTP-202 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-203 | GET /lab/communication/{commId} | 通讯逐接口字段与加载回执.md | M02.HTTP-203 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-204 | POST /lab/communication | 通讯逐接口字段与加载回执.md | M02.HTTP-204 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-205 | PUT /lab/communication | 通讯逐接口字段与加载回执.md | M02.HTTP-205 | CTRL-CMD | 同M02-209：锁当前配置并核身份权限→双owner同代完整空闲事实→旧通讯版本CAS；SYSTEM管理版本、审计、回执同提交，失败整组回滚 |
| HTTP-206 | DELETE /lab/communication/{commIds} | 通讯逐接口字段与加载回执.md | M02.HTTP-206 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-207 | GET /lab/communication/list | 通讯逐接口字段与加载回执.md | M02.HTTP-207 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-208 | GET /lab/detectorconfig/{detectorId}/available-items | 检测项目开关与规则接口契约.md | M02.HTTP-208 | CTRL-QRY | 只读候选查询；不锁定未来资格 |
| HTTP-209 | POST /lab/detectorconfig/{detectorId}/batch-save | 检测项目开关与规则接口契约.md | M02.HTTP-209 | CTRL-APR | 候选/hash固定；锁内全量重验；稳定锁序；整批提交或回滚 |
| HTTP-210 | GET /detect/detection-rule/labs | 检测项目开关与规则接口契约.md | M02.HTTP-210 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-211 | GET /detect/detection-rule/config/{labId} | 检测项目开关与规则接口契约.md | M02.HTTP-211 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-212 | PUT /detect/detection-rule/{labId}/{ruleItem} | 检测项目开关与规则接口契约.md | M02.HTTP-212 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-213 | PUT /detect/detection-rule/1004/density-difference | 检测项目开关与规则接口契约.md | M02.HTTP-213 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-214 | PUT /detect/detection-rule/1004/photometer-time | 检测项目开关与规则接口契约.md | M02.HTTP-214 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-215 | PUT /detect/detection-rule/1004/photometer-rds | 检测项目开关与规则接口契约.md | M02.HTTP-215 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-216 | PUT /detect/detection-rule/1004/photometer-blank-concentration | 检测项目开关与规则接口契约.md | M02.HTTP-216 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-217 | PUT /detect/detection-rule/1004/solovpe-rds | 检测项目开关与规则接口契约.md | M02.HTTP-217 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-218 | PUT /detect/detection-rule/1004/solovpe-r2 | 检测项目开关与规则接口契约.md | M02.HTTP-218 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-219 | GET /device/detectoritem/list | 检测项目主数据逐接口契约.md | M02.HTTP-219 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-220 | GET /device/detectoritem/{itemId} | 检测项目主数据逐接口契约.md | M02.HTTP-220 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-221 | GET /device/detectoritem/check-unique | 检测项目主数据逐接口契约.md | M02.HTTP-221 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-222 | GET /device/detectoritem/{itemId}/check-delete | 检测项目主数据逐接口契约.md | M02.HTTP-222 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-223 | POST /device/detectoritem | 检测项目主数据逐接口契约.md | M02.HTTP-223 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-224 | PUT /device/detectoritem | 检测项目主数据逐接口契约.md | M02.HTTP-224 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-225 | DELETE /device/detectoritem/{itemIds} | 检测项目主数据逐接口契约.md | M02.HTTP-225 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-226 | POST /device/detectoritem/export | 检测项目主数据逐接口契约.md | M02.HTTP-226 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-227 | GET /system/lab/engineering/profiles | 工程资料维护与解析逐接口契约.md | M02.HTTP-227 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-228 | POST /system/lab/engineering/profiles | 工程资料维护与解析逐接口契约.md | M02.HTTP-228 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-229 | POST /system/lab/controllers/{connectionId}/model-verification | 工程资料维护与解析逐接口契约.md | M02.HTTP-229 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-230 | GET /lab/lab/list | 实验室主数据逐接口契约.md | M02.HTTP-230 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-231 | GET /lab/lab/options | 实验室主数据逐接口契约.md | M02.HTTP-231 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-232 | POST /lab/lab/export | 实验室主数据逐接口契约.md | M02.HTTP-232 | CTRL-JOB | 固定查询条件；事务外生成文件；下载重验权限 |
| HTTP-233 | GET /lab/lab/{labId} | 实验室主数据逐接口契约.md | M02.HTTP-233 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-234 | GET /lab/lab/{labId}/leaders | 实验室主数据逐接口契约.md | M02.HTTP-234 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-235 | GET /lab/lab/{labId}/authorized-users | 实验室主数据逐接口契约.md | M02.HTTP-235 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-236 | GET /lab/lab/{labId}/check-disable | 实验室主数据逐接口契约.md | M02.HTTP-236 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-237 | POST /lab/lab | 实验室主数据逐接口契约.md | M02.HTTP-237 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-238 | PUT /lab/lab | 实验室主数据逐接口契约.md | M02.HTTP-238 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-239 | PUT /lab/lab/{labId}/leaders | 实验室主数据逐接口契约.md | M02.HTTP-239 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-240 | PUT /lab/lab/{labId}/status | 实验室主数据逐接口契约.md | M02.HTTP-240 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-241 | DELETE /lab/lab/{labIds} | 实验室主数据逐接口契约.md | M02.HTTP-241 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-242 | GET /lab/consumptionRule/bootstrap | 消耗配置聚合与解析契约.md | M02.HTTP-242 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-243 | GET /lab/consumptionRule/config | 消耗配置聚合与解析契约.md | M02.HTTP-243 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-244 | GET /lab/consumptionRule/consumable-options | 消耗配置聚合与解析契约.md | M02.HTTP-244 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-245 | PUT /lab/consumptionRule/config | 消耗配置聚合与解析契约.md | M02.HTTP-245 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-246 | GET /lab/bottle-config/consumables | 液瓶配置逐接口与观测边界.md | M02.HTTP-246 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-247 | GET /lab/bottle-config/layout | 液瓶配置逐接口与观测边界.md | M02.HTTP-247 | CTRL-QRY | 只读；范围过滤后稳定分页/投影 |
| HTTP-248 | PUT /lab/bottle-config/sampling-units/{labId}/{unitCode} | 液瓶配置逐接口与观测边界.md | M02.HTTP-248 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-249 | PUT /lab/bottle-config/feeding-slots/{bottleId} | 液瓶配置逐接口与观测边界.md | M02.HTTP-249 | CTRL-CMD | M02本地事务；SYSTEM/对象版本、审计、回执、outbox同提交 |
| HTTP-250 | GET /lab/pumpconnection/{connectionId}/capabilities | 控制器能力接口契约.md | M02.HTTP-250 | CTRL-PRE | 只读预检；不锁定未来资格 |
| HTTP-251 | PUT /lab/pumpconnection/{connectionId}/capabilities | 控制器能力接口契约.md | M02.HTTP-251 | CTRL-PRE | 只读预检；不锁定未来资格 |

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| AUTH-I01 | prepareUserEdit | 用户实验室授权内部服务逐方法契约.md | CTRL-INTERNAL | M01可信调用；只读候选与授权版本，不暴露无权实验室 |
| AUTH-I02 | replaceUserLabs | 用户实验室授权内部服务逐方法契约.md | CTRL-INTERNAL | 与M01用户保存同受控事务；范围外旧授权保留 |
| AUTH-I03 | removeUserLabs | 用户实验室授权内部服务逐方法契约.md | CTRL-INTERNAL | 删除前重验负责人/全部相关实验室管理权；仅清直接授权 |
| ENG-I01 | resolveEngineering | 工程资料维护与解析逐接口契约.md | CTRL-INTERNAL | COMPLETE/INCOMPLETE/REVOKED/UNAVAILABLE分开，不伪造默认资料 |
| CAP-I01 | resolveDeviceConfiguration | 型号专属筛选与内部能力读取契约.md | CTRL-INTERNAL | 精确实例/型号/应用版本快照 |
| CAP-I02 | resolveIntegratedCapabilities | 型号专属筛选与内部能力读取契约.md | CTRL-INTERNAL | 返回核准能力及版本；缺项显式失败 |
| CAP-I03 | resolvePumpConfiguration | 型号专属筛选与内部能力读取契约.md | CTRL-INTERNAL | 固定泵配置、单位和曲线身份 |
| OBS-I01 | receiveObservation | 在线业务观测存储与查询契约.md | CTRL-INTERNAL | 可信适配器；持久化后ACK；同源同hash幂等，异hash隔离 |

## 4. 模块内调用约束

- HTTP字段必须先映射为 M02 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

2026-10-18补充M02-256/257，详见[专题契约](检测实例规则应用与命名管道接线契约.md)。256：Controller校验query权限→应用服务实验室VIEW→实例版本与型号投影→顶层managementRevision。257：Controller校验edit并解析WriteMeta→管理守卫SYSTEM锁及幂等→应用服务重验edit与MANAGE→实验室锁、实例锁→型号/实例/队列版本及协议校验→M05 DetectorRuleUsagePort占用核验→完整快照→实例CAS、队列递增及摘要审计→原回执。事务不执行设备命令，规则应用不生成物理ACK。

本文件登记37条目录来源映射、251条规范全路径映射和8个非Controller内部端口；目录定位可能覆盖多条规范路径，同一路径也可能在来源定位与规范表重复出现，因此不再人工相加推导接口总数。canonical HTTP去重数由`docs/开发任务/00-全接口契约骨架清单.json`生成校验；逐接口仍须以来源契约完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。
