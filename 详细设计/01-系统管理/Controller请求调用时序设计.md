# M01 Controller 请求调用时序设计

## 2026-11-01 认证安全增强时序

现行本地时序以[认证安全增强设计](认证安全增强设计.md)为准，下文API07/API09旧时序须先执行本增补；对应源码已接线，不代表目标环境已部署。AAD专用重新认证仍依赖客户核准，不复用本地密码放行。

- SEC01/02：Controller绑定参数→当前可信会话→身份来源与权限/范围→auth编排本地口令或AAD重新认证→受控system端口保存操作凭证绑定；Controller不直接调用Mapper。远程认证和BCrypt在数据库锁事务外，锁内复核版本。
- API07/API09：当前身份/权限→system应用命令服务→操作记录行锁→原会话/动作/原载荷匹配→APPLIED回放或READY凭证检查→既有业务锁序及版本/权限复核→业务、审计、操作结果同事务提交。先操作记录后业务行；不扩大管理守卫动作白名单。
- SEC03：当前身份与原会话→按操作者和businessRequestId只读结果；无权和不存在统一404。SEC04：当前会话→读取本次登录持久化快照，不接受userId、不更新登录时间。
- SEC05：原会话→锁原操作记录→仅PENDING/READY取消、APPLIED回放原成功→清理短时挑战；与业务执行同锁裁决。SEC06：原会话与限流→当前操作状态→仅READY从受控短时存储取回凭证；无缓存、无URL凭证，不新增业务效果。
- 登录：限流/验证码权威单次消费→内部真实认证→匿名边界统一失败映射；成功激活事务按用户串行固定前次登录快照并记录本次事件→缓存完成→返回JWT。解锁/续期/二次认证不刷新快照。

版本：DD-20260917-CALL-01。覆盖《接口目录与契约定位》的 Controller 入口；字段、权限、错误和DTO以来源契约为准，调用顺序以本文和[总设计](../00-总纲与约定/00-Controller与模块接口调用总设计.md)为准。本文不表示接口已实现。

## 1. Controller入口逐项映射

| 目录ID | HTTP入口 | 字段权威 | 唯一应用端口ID | 时序 | 事务与恢复 |
| --- | --- | --- | --- | --- | --- |
| 定位001 | POST /auth/login | 详细设计.md | M01.定位001 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位002 | POST /auth/login/continue | 详细设计.md | M01.定位002 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位003 | POST /auth/password/complete | 详细设计.md | M01.定位003 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位004 | DELETE /auth/login/challenge | 详细设计.md | M01.定位004 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位005 | PUT /system/user/profile/updatePwd | 详细设计.md | M01.定位005 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位006 | GET /system/user/profile/passwordState | 详细设计.md | M01.定位006 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位007 | PUT /system/user/resetPwd | 详细设计.md | M01.定位007 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位008 | GET /system/user/passwordValidity | 详细设计.md | M01.定位008 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位009 | PUT /system/user/passwordValidity | 详细设计.md | M01.定位009 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位010 | DELETE /auth/logout | 详细设计.md | M01.定位010 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位011 | POST /auth/refresh | 详细设计.md | M01.定位011 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位012 | POST /auth/unlockscreen | 详细设计.md | M01.定位012 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位013 | GET /system/smp/venue/pageList | 详细设计.md | M01.定位013 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位014 | POST /system/smp/venue | 详细设计.md | M01.定位014 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位015 | PUT /system/smp/venue | 详细设计.md | M01.定位015 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位016 | GET /system/smp/venue/tree | 详细设计.md | M01.定位016 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位017 | GET /system/smp/venue/{venueId}/delete-check | 详细设计.md | M01.定位017 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位018 | DELETE /system/smp/venue/{venueIds} | 详细设计.md | M01.定位018 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位019 | POST /system/dept | 详细设计.md | M01.定位019 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位020 | PUT /system/dept | 详细设计.md | M01.定位020 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位021 | GET /system/dept/options | 详细设计.md | M01.定位021 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位022 | GET /system/dept/{deptId}/delete-check | 详细设计.md | M01.定位022 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位023 | GET /system/dept/{deptId}/users | 详细设计.md | M01.定位023 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位024 | GET /system/smp/labgroup/list | 详细设计.md | M01.定位024 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位025 | POST /system/smp/labgroup | 详细设计.md | M01.定位025 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位026 | PUT /system/smp/labgroup | 详细设计.md | M01.定位026 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位027 | GET /system/smp/labgroup/member-options | 详细设计.md | M01.定位027 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位028 | DELETE /system/smp/labgroup/{groupIds} | 详细设计.md | M01.定位028 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位029 | GET /system/dept/pageList | 详细设计.md | M01.定位029 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位030 | DELETE /system/dept/{deptId} | 详细设计.md | M01.定位030 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位031 | GET /system/smp/venue/{venueId} | 详细设计.md | M01.定位031 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位032 | GET /system/dept/{deptId} | 详细设计.md | M01.定位032 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位033 | GET /system/smp/labgroup/{groupId} | 详细设计.md | M01.定位033 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位034 | POST /system/smp/labgroup/resolve-members | 详细设计.md | M01.定位034 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位035 | GET /system/menu/pageList | 详细设计.md | M01.定位035 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位036 | POST /system/menu | 详细设计.md | M01.定位036 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位037 | PUT /system/menu | 详细设计.md | M01.定位037 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位038 | PUT /system/menu/changeStatus | 详细设计.md | M01.定位038 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位039 | GET /system/role/list | 详细设计.md | M01.定位039 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位040 | POST /system/role | 详细设计.md | M01.定位040 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位041 | PUT /system/role | 详细设计.md | M01.定位041 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位042 | PUT /system/role/changeStatus | 详细设计.md | M01.定位042 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位043 | GET /system/role/roleUsers | 详细设计.md | M01.定位043 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位044 | DELETE /system/role/{roleIds} | 详细设计.md | M01.定位044 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位045 | GET /system/menu/{menuId} | 详细设计.md | M01.定位045 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位046 | GET /system/role/{roleId} | 详细设计.md | M01.定位046 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位047 | GET /system/role/editor-options | 详细设计.md | M01.定位047 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位048 | GET /system/user/list | 详细设计.md | M01.定位048 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位049 | GET /system/user/{userId} | 详细设计.md | M01.定位049 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位050 | POST /system/user | 详细设计.md | M01.定位050 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位051 | PUT /system/user | 详细设计.md | M01.定位051 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位052 | PUT /system/user/changeStatus | 详细设计.md | M01.定位052 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位053 | DELETE /system/user/{userIds} | 详细设计.md | M01.定位053 | CTRL-BATCH | 稳定顺序加锁；全量预验；整批提交或回滚 |
| 定位054 | GET /system/user/editor-options | 详细设计.md | M01.定位054 | CTRL-PRE | 只读；不锁定未来资格；依赖失败显式返回 |
| 定位055 | GET /system/user/profile | 详细设计.md | M01.定位055 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位056 | PUT /system/user/profile | 详细设计.md | M01.定位056 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位057 | POST /system/user/{userId}/force-logout | 详细设计.md | M01.定位057 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位058 | GET /system/dict/type/list | 详细设计.md | M01.定位058 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位059 | POST /system/dict/type | 详细设计.md | M01.定位059 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位060 | PUT /system/dict/type | 详细设计.md | M01.定位060 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位061 | GET /system/dict/type/{dictId} | 详细设计.md | M01.定位061 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位062 | GET /system/dict/data/list | 详细设计.md | M01.定位062 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位063 | POST /system/dict/data | 详细设计.md | M01.定位063 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位064 | PUT /system/dict/data | 详细设计.md | M01.定位064 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位065 | GET /system/dict/data/{dictCode} | 详细设计.md | M01.定位065 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位066 | GET /system/dict/data/type/{dictType}/tree | 详细设计.md | M01.定位066 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位067 | GET /system/config/list | 详细设计.md | M01.定位067 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位068 | POST /system/config | 详细设计.md | M01.定位068 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位069 | PUT /system/config | 详细设计.md | M01.定位069 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位070 | GET /system/config/{configId} | 详细设计.md | M01.定位070 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位071 | DELETE /system/config/{configIds} | 详细设计.md | M01.定位071 | CTRL-CMD | 本地单事务；幂等/CAS/审计/outbox同提交 |
| 定位072 | GET /system/logininfor/list | 详细设计.md | M01.定位072 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位073 | GET /system/operlog/list | 详细设计.md | M01.定位073 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位074 | GET /system/operlog/{operId} | 详细设计.md | M01.定位074 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位075 | GET /system/user/getInfo | 详细设计.md | M01.定位075 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |
| 定位076 | GET /system/menu/getRouters | 详细设计.md | M01.定位076 | CTRL-QRY | 只读；无业务写事务；先范围过滤再分页 |

Controller必须只调用表中的唯一应用端口。应用端口先做当前会话和对象范围校验，再按时序编号执行；Controller不得直连Mapper、跨模块Repository、设备适配器或外部通道。相同接口ID的补充文档合并为同一端口，不新增第二实现。

## 3. 非Controller内部端口

| 目录ID | 内部声明 | 字段权威 | 时序 | 调用限制 |
| --- | --- | --- | --- | --- |
| SEC-I01 | resolveActorContext | 详细设计.md、总体设计与公共契约 | CTRL-INTERNAL | 当前会话、authzVersion、requestId；浏览器actor字段无效 |
| SEC-I02 | checkFunctionPermission | 详细设计.md | CTRL-INTERNAL | 实时撤权；功能权限不替代对象范围 |
| SEC-I03 | verifyManagementRevision | 详细设计.md | CTRL-INTERNAL | 只验证SYSTEM配置并发；不替代领域objectVersion |

## 4. 模块内调用约束

- HTTP字段必须先映射为 M01 自有Command/Query DTO；不得把Entity或Mapper参数暴露给Controller。
- 查询端口无副作用；preview/precheck只返回当时快照，不替代最终锁内重验。
- 命令端口必须保存requestId/requestHash或等价唯一回执；相同键异载荷返回REQUEST_CONFLICT。
- 跨模块只调用总设计登记的Port；依赖失败不得降级成空集合、成功或“无需审批”。
- 具体主表、唯一键、CHECK、JSON和索引以完整建表基线及模块最终目标DDL为准。

## 5. 验收

本文件自动登记 76 个目录内HTTP入口、0 个内部定位项、0 个尾部补登记入口。数量校验只防漏项；逐接口仍须以来源契约完成成功、拒绝、冲突、重复、超时/UNKNOWN和失权用例。

## 6. TASK-GATES 补充：管理写快照时序与 SEC-I01 口径（2026-09-19，裁决明细见 docs/开发任务/01-契约骨架/21-TASK-GATES-G1-G3阶段门裁决报告.md）

- §1 各写口的真实实现时序统一收敛为 21 报告 §1.3 十六步（Controller 只绑定→AppService 合并可信 WriteMeta→守卫先解析 ActorContext→同事务锁 SYSTEM 行→幂等→版本校验→写前 beforeSnapshot→业务写→写后审计前 afterSnapshot→白名单审计明细→Hook 同事务写审计→revision CAS→回执→提交→提交后仅回填 committedManagementRevision）；29 个 operationCode 的 auditTitle/businessType/主ID与affectedIds来源/快照白名单/脱敏禁列以 21 报告 §1.4 映射表为唯一来源。
- §3 SEC-I01 行冻结：输入仅 requestId+sessionKey（operationCode 走守卫服务端枚举）；输出 ActorContext **五字段**（actorUserId/actorName/sessionKey/authzVersion/requestId；原"六字段+labScopes 经 M02 聚合"口径已由 TASK-GATES-R1 废止，见 22 报告——SEC-I01 不依赖 M02、不承载领域范围，实验室范围唯一权威=M02 LabAuthorizationPort 事务内实时判定）；单请求一次解析、全链复用同一快照；authzVersion=resolve 时刻 sys_management_revision SYSTEM 当前值（非 session_version/非 objectVersion）；失败复用 401 SESSION_INVALID/SESSION_REPLACED、409 SESSION_VERSION_CONFLICT、403 ACCOUNT_UNAVAILABLE、503 AUTH_DEPENDENCY_UNAVAILABLE，fail-closed 不降级匿名；对象范围与受保护校验仍由事务内 AppService/领域 Port 重验（G3）。
- USR03/04/06 的实验室授权阶段按 21 报告 §3.3/§3.6 在守卫事务内调用 LabAuthorizationPort（同 DataSource 同事务，锁序 SYSTEM→targetUser→labId 升序，任一步失败整次回滚；M02 依赖失败 503 LAB_AUTHORIZATION_UNAVAILABLE 不保存部分数据）。
