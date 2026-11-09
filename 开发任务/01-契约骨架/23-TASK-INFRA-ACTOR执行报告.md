# 23 - TASK-INFRA-ACTOR 执行报告（R2）

> **R2 修订记录（2026-09-19）**：认证依赖日志最终脱敏收口。初版→R1 已消除消息参数面泄漏（`e.toString()` 拼接），但 R1 仍将异常对象作为 throwable 传给日志框架——logback 默认在 pattern 后追加完整堆栈，依赖组件（Redis/MySQL 驱动）异常原文常自带连接串、键名、SQL 参数与 Token，堆栈段仍可能进入认证链路业务日志。R2 修正：四处依赖异常 `log.error` **不再传异常对象、不记堆栈**，参数只允许 requestId＋异常类型名；原始 cause 仅随 `ManagementGuardRejectException` 在调用栈内保留（HTTP 响应与业务日志均禁入）。`ManagementGuardExceptionHandler` 本就不记录、不返回 cause（源码复核：无日志语句，响应体仅 code/msg/errorCode/retryable/currentManagementRevision）。**R1 遗留项"日志堆栈面脱敏待裁决"随本修订关闭。** 未修改全局 logback.xml，未使用 `%nopex`（不影响其他模块异常输出）。
>
> **R1 修订记录（2026-09-19）**：初版经外部审阅判"暂不通过"，发现 2 P0 + 1 P1，本版为修正后基线。
> 初版废止内容（不得再引用）：
> ① "session_version==0 且键激活 → 409 SESSION_VERSION_CONFLICT"（P0：无设计依据，DDL 规定 `NOT NULL DEFAULT 0`，0 是合法初始态；且 `LoginUser` 无 sessionVersion，不存在可信第二比较值，409 属伪造冲突判定）——已删除对应代码、测试与本文口径；
> ② "SYSTEM 行缺失/负值抛裸 `IllegalStateException`（与守卫同口径）"（P0：`ManagementGuardExceptionHandler` 只处理 `ManagementGuardRejectException`，IllegalStateException 落 HTTP 500，与初版宣称的 503 不符）——已改为 `ManagementGuardRejectException(AUTH_DEPENDENCY_UNAVAILABLE)`；
> ③ 日志参数拼接 `e.toString()`（P1：依赖异常原文可能含 Redis 键/SQL 参数）——已改为只记 requestId+异常类型名（throwable 通道由上方 R2 记录进一步收口）。
> 详见文末"附：R1 修订对照"。

任务：实现唯一生产 ActorContextPort 适配器 `M01ActorContextAdapter`，使 PRE-01B `ManagementGuardExecutor` 具备真实 ActorContextPort Bean。
范围：仅可信身份 / 会话有效性 / authzVersion 解析；不含业务 CRUD、不接入 76 Controller、不含审计 Hook、不含 M02 实验室授权。

---

## 1. 是否完成

**ActorContext 生产适配器已实现（R1 修正 + R2 日志收口后）**（静态层面：编译通过、310+14 单元/契约/HTTP 映射测试通过、架构门禁通过）。
- 真实业务 CRUD 仍未实现（骨架 501 语义不变）。
- Redis / MySQL / JWT / HTTP 真实环境尚未验证。
- 实验室授权仍由后续 M02-LAB-AUTH-PORT 实现。
- 跨代次会话版本校验未实现（见 §7/§18 PRE-AUTH-STATE），当前仅完成 current_session_key 一致性 + session_version 结构合法性。

## 2. 链路取证（编码前 10 项真实链路追踪结果）

| # | 取证项 | 结论（源码实证） |
|---|--------|------------------|
| 1 | JWT 签发与 user_key 来源 | `TokenService.createToken`（common-security）：`IdUtils.fastUUID()` 生成 token uuid，写入 JWT claim `user_key` |
| 2 | sessionKey → Redis 键 | `CacheConstants.LOGIN_TOKEN_KEY = "login_tokens:"`，键 = 前缀 + user_key；`getLoginUser` 按此读取 `LoginUser` |
| 3 | 网关侧校验 | `AuthFilter`：验 JWT 签名 + `redisTemplate.hasKey(login_tokens:{uuid})`，通过后注入 `user_id/user_key/username` 内部头 |
| 4 | 服务侧上下文 | `HeaderInterceptor` → `SecurityContextHolder`（ThreadLocal）。注意：`getUserKey()` 未设置时返回**空串**；`RequestMetadataContext.getRequestId()` 未初始化返回 **null**，两者判空语义不同 |
| 5 | LoginUser 字段集 | token/userid(Long)/username/loginTime/expireTime/ipaddr/permissions/roles/sysUser —— **无 sessionVersion**；会话代次只能来自 `sys_user_auth_state` 表 |
| 6 | auth_state 真实列 | 开发基线 DDL：`current_session_key varchar(64)` 可空、`session_version bigint NOT NULL DEFAULT 0`（R1 复核字段字典 §3.20 与 01-完整建表.sql L381：0 是合法初始态，不是异常证据）；生产源码此前对该表**零引用**（写路径未实现，见 21 报告 §2.4-8） |
| 7 | sys_user 状态查询 | `SysUserMapper.selectUserById` **无 del_flag 过滤**，须显式校验 `del_flag=="0" && status=="0"` |
| 8 | SYSTEM 行读取 | `SysManagementRevisionMapper.selectCurrentRevision()` 无锁读，与 `M01ManagementRevisionSourceAdapter`、守卫同源 |
| 9 | 守卫调用方式 | `ManagementGuardExecutor` L124-128：port 为 null 显式拒绝；L139 `resolveTrustedActor` 发生在 payload 哈希、写事务开启与 SYSTEM 锁**之前**；L162-191 对五字段做正十进制等校验 |
| 10 | 异常体系与同名实现查重 | 真 HTTP 状态码唯一现成通道 = `ManagementGuardRejectException` + `ManagementGuardExceptionHandler`（@Order HIGHEST，`ResponseEntity.status`）；`ServiceException` 是 body-code/HTTP200 旧风格不可用。`implements ActorContextPort` 全仓生产实现查重为 0（本任务前） |

源码与冻结文档差异：未发现推翻性差异；登记项两条——① retryable 位差异（文档"不重试" vs 枚举 `retryable=true`），冻结文档未授权改枚举，仅登记待裁决；② R1 审阅确认初版 409 规则与 IllegalStateException→500 两处为**实现自创、非设计依据**，本版已删除（见文首修订记录）。

## 3. 文件清单

新增（生产）：
- `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/port/m01/M01ActorContextAdapter.java`
- `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/vo/m01/AuthSessionStateView.java`（仅 currentSessionKey/sessionVersion 两字段，内部只读视图，不入对外契约）

增量修改（均为前任务未跟踪骨架文件上的最小增量，未动任何已跟踪文件）：
- `mapper/SysUserAuthStateMapper.java`：新增抽象方法 `selectAuthSessionStateByUserId(@Param("userId") Long)`；两个 default-throw 骨架方法原样保留
- `resources/mapper/system/SysUserAuthStateMapper.xml`：新增对应**只读** select（current_session_key、session_version 两列）
- `service/guard/ManagementGuardRejectException.java`：仅追加一段 Javadoc，登记其为 SEC-I01 fail-closed 复用通道（§十一"异常映射最小增量"）

新增（测试）：
- `src/test/.../service/impl/port/m01/M01ActorContextAdapterTest.java`（R1 后 27 项：version 0/正数成功口径、revision 503 映射、日志脱敏 ListAppender 断言）
- `src/test/.../service/impl/port/m01/M01ActorContextHttpMappingMockTest.java`（R1 新增 5 项：MockMvc HTTP 级 503/401 映射 + requestId + 响应防泄漏）
- `src/test/.../contract/ActorContextAdapterArchitectureTest.java`（4 项）
- `src/test/.../service/guard/M01ActorContextGuardWiringTest.java`（3 项）

## 4. 最终依赖清单（生产）

单构造注入，恰四类（§六白名单内）：
1. `RedisService`（会话读取，唯一惯用法 `getCacheObject(LOGIN_TOKEN_KEY + sessionKey)`）
2. `SysUserAuthStateMapper`（只读）
3. `SysUserMapper`（只读，selectUserById）
4. `SysManagementRevisionMapper`（只读，selectCurrentRevision）

另使用（非注入）：`RequestMetadataContext`/`WriteMeta`、`ManagementGuardRejectException`、`FutureFabErrorCode`。
零依赖：LabAuthorizationPort、M02-M09 任何领域包/模型、sys_user_lab/lab_lab、业务 ApplicationService、ManagementAuditHook、Controller、外部 HTTP、平行会话模型。

## 5. ActorContext 五字段来源

严格五 String 字段，未恢复/新增任何集合或状态字段：

| 字段 | 来源 |
|------|------|
| actorUserId | 可信 Redis `LoginUser.userid`；null 时回退 `sysUser.getUserId`；仍 null/≤0 → SESSION_INVALID |
| actorName | `LoginUser.username`；blank → SESSION_INVALID |
| sessionKey | 入参 Query.sessionKey（经 §6 可信链验证后原值回填） |
| authzVersion | 解析时刻 `sys_management_revision` SYSTEM 行当前值 `Long.toString` |
| requestId | 入参 Query.requestId（与 RequestMetadataContext 一致性校验通过后回填） |

## 6. sessionKey 可信来源与一致性

- 取证确认 sessionKey = JWT `user_key` = `IdUtils.fastUUID` uuid = Redis 键后缀 = `sys_user_auth_state.current_session_key` 列值，同一标识贯穿全链。
- 输入侧校验（零依赖触达前）：非空、≤64（列宽）、`^[0-9a-fA-F-]+$`（防任意自报串拼接 Redis 键），违规 → SESSION_INVALID。
- 内容侧一致性：Redis 反序列化 `LoginUser.token` 必须等于 sessionKey，不等 → SESSION_INVALID（结构异常）。
- 与 auth_state `current_session_key` 一致性见 §7。

## 7. session_version 校验规则（R1 最终保守口径）

必须承认的当前事实：`LoginUser` 没有 sessionVersion；JWT/Redis 会话中不存在可与数据库 `session_version` 比较的可信版本；开发基线 DDL 规定 `session_version NOT NULL DEFAULT 0`；当前只有 `current_session_key` 可完成可信一致性比较。因此：

| 情形 | 结果 |
|------|------|
| auth_state 行缺失 | 401 SESSION_INVALID |
| current_session_key 为 null（登出/强制下线已清除） | 401 SESSION_INVALID |
| current_session_key ≠ sessionKey（被顶下线） | 401 SESSION_REPLACED |
| session_version 为 null 或负数 | 503 AUTH_DEPENDENCY_UNAVAILABLE（数据不可信，禁止降级） |
| session_version 为 **0 或正数** | **仅判定结构合法，解析成功**；不返回 SESSION_VERSION_CONFLICT |

**当前不存在 SESSION_VERSION_CONFLICT 的两个可信比较值（会话载体内版本 vs 数据库当前版本），因此不得伪造冲突判定**——初版"version==0→409"规则已整体删除。`SESSION_VERSION_CONFLICT` 错误码继续保留，但本适配器当前不使用。

**PRE-AUTH-STATE：认证状态写入与可信会话版本闭环（阻塞项登记）**——后续登录激活/强制下线写路径必须完成：① 原子递增 `session_version`；② 将本次可信 sessionVersion 写入 Redis `LoginUser` 或等价服务端会话载体；③ 之后才能升级为"Redis 会话版本 vs 数据库当前版本"的真实跨代次比较。该项是进入**真实环境联调**前的阻塞项，但**不阻塞 ActorContext 只读适配器的静态完成**。本修正未给 ActorContext 增加 sessionVersion 字段、未改 JWT 对外载荷（均须另行设计裁决）。
retryable 位差异登记：设计文档 §2.5 规定 SESSION_INVALID/SESSION_REPLACED 不重试，`FutureFabErrorCode` L305/L307 实际 `retryable=true`——冻结文档未授权改枚举，**仅登记待裁决，未修改**。

## 8. authzVersion 读取与校验

- `selectCurrentRevision()` 无锁只读，发生在守卫进入写事务与 SYSTEM 锁之前（与守卫自身时序一致）。
- R1 修正：null / 负数 / 其他可信数据异常 → 一律 `ManagementGuardRejectException(AUTH_DEPENDENCY_UNAVAILABLE, 安全消息)`，**HTTP 503**（消息不含表名、SQL、revision 值等内部信息）；不再抛裸 `IllegalStateException`（初版会落入通用 500，与宣称的 503 不符）。MockMvc 级测试锁定 status=503 + errorCode + requestId + 无内部细节。
- 不伪造默认版本（0 或任意缺省值）的约束不变。
- 语义区分：authzVersion = 解析时刻 SYSTEM 当前值 ≠ session_version ≠ objectVersion ≠ M02 authorizationVersion。

## 9. 停用 / 删除复核

`selectUserById` 结果显式检查：null（不存在）、`del_flag != "0"`（已删除）、`status != "0"`（已停用）三种情形**统一**返回 403 ACCOUNT_UNAVAILABLE 同一文案，不区分细节（防账号枚举）。查询异常 → 503。

## 10. 错误码映射（严格复用，无第二套码；R1 修正后）

| 场景 | HTTP | 码 |
|------|------|-----|
| Query null / 会话不存在或过期 / 结构异常 / sessionKey 非法 / auth_state 行缺失或键已清除 | 401 | SESSION_INVALID |
| current_session_key 不一致（顶下线） | 401 | SESSION_REPLACED |
| 账号不存在/删除/停用 | 403 | ACCOUNT_UNAVAILABLE |
| Redis/MySQL 依赖故障、session_version 数据非法（null/负）、**SYSTEM 行缺失/负值/查询异常（R1）** | 503 | AUTH_DEPENDENCY_UNAVAILABLE（携带 cause，绝不降级为 SESSION_INVALID，绝不落裸 500） |
| requestId 非法或与元数据上下文不一致 | 400 | INPUT_INVALID；上下文未初始化 → 503 fail-closed |

`SESSION_VERSION_CONFLICT(409)`：错误码保留，本适配器当前**不使用**（无可信比较对象，禁止伪造冲突，见 §7）。
映射通道唯一复用 `ManagementGuardRejectException` + 现有 `ManagementGuardExceptionHandler`；无统一 catch-all 500；requestId 由 `RequestMetadataResponseAdvice` 统一保留补齐（MockMvc HTTP 级断言验证）。泄漏防护：全部失败消息禁含 sessionKey/JWT/Token/Redis 键/**表名/SQL 片段**；HTTP 响应禁含 cause 消息、异常类名原文、SQL、Redis 键、sessionKey、Token 或连接信息（`ManagementGuardExceptionHandler` 不记录、不返回 cause，源码复核＋MockMvc poisoned-message 断言）。
**日志面 R2 最终收口**：`log.error` 消息参数只记 requestId 与异常类型名，**不传异常对象、不记堆栈**——不把原始依赖异常交给认证链路业务日志的原因：Redis/MySQL 驱动异常原文常自带连接串、键名、SQL 参数与 Token，logback pattern（`%msg%n`）未显式声明 throwable 转换器时默认追加完整堆栈，任何一条认证依赖故障日志都可能成为凭据面泄漏点；诊断粒度上异常类型名（如 `QueryTimeoutException`/`RedisConnectionException`）已足以定位依赖故障类别。测试以 ListAppender 锁定完整 `ILoggingEvent`：formattedMessage、argumentArray 不含敏感值且不含 Throwable，`throwableProxy` 恰为 null。未修改全局 logback.xml、未用 `%nopex`（不掩盖其他模块异常）。

## 11. 是否引入 M02 依赖

否。构造注入恰四类白名单类型；架构测试以反射扫描强制：适配器字段/构造参数/方法签名正则禁 `service.port.m02..09|LabAuthorization|sys_user_lab|lab_lab`，匹配数 0。M02 授权端口缺席或不可用不影响解析（测试项覆盖）。

## 12. 是否改数据库或 SQL（逐条）

- 未新增/修改任何表、列、索引；未改 `docs/开发基线/` 任何脚本；未执行任何 DDL/DML。
- 唯一 SQL 相关改动：`SysUserAuthStateMapper.xml` 新增 1 条**只读** select（§十一允许清单："现有只读 Mapper 增加设计已存在的最小查询"——auth_state 表与两列均存在于开发基线 DDL）。
- 两列均只读，不写 session_version、不写 current_session_key。

## 13. 是否改 Controller 或 76 骨架

未改任何 Controller；未将任何 501 骨架改为真实业务；`SysUserAuthStateMapper` 原有两个 default-throw 骨架方法原样保留。PRE-01B 守卫"Port 缺失显式拒绝"分支（L124-128）转为防御性代码（现在生产上下文存在恰一 Bean），语义未改。

## 14. 新增测试数与覆盖（R2 后）

INFRA-ACTOR 累计 **39 项**（27 适配器 + 5 HTTP 映射 + 4 架构反射门禁 + 3 守卫接线），覆盖任务书 §九 至少 24 项 + R1 §七 15 项 + R2 §7/§8 要求：五字段快照与单次解析（四个数据源各恰 1 次读取）、唯一生产 Bean、无 M02 依赖、requestId 一致/不一致/未初始化、各错误码逐一映射（Java 级 + **MockMvc HTTP 级**：status/code/errorCode/requestId）、**session_version=0 且键匹配→成功、正数→成功、null/负→503、任何路径不产出 409**、**SYSTEM 行缺失/负值/查询异常→HTTP 503 且响应不含表名/SQL/sessionKey/Redis 键/依赖异常原文**、**R2 完整 ILoggingEvent 断言（`dependencyFailureLogsCarryNoThrowableAndNoSensitiveValues`）：poisoned 异常（含 sessionKey/完整 Redis 键/SQL 参数/Token/jdbc 连接串）分别注入 Redis、auth_state、sys_user、revision 四类依赖，逐条断言 formattedMessage 与 argumentArray 不含敏感值、参数恰两个且不含 Throwable、`throwableProxy` 必为 null、cause 仍在 `ManagementGuardRejectException` 对象内保留**、HTTP 响应防泄漏断言扩充（token=/jdbc:/user_id=/异常类名原文）、守卫 ActorContext 来自该生产 Port 且解析先于 txBegin/SYSTEM 锁、拒绝时零 DB 调用、既有测试无回归。
测试替身：JDK `Proxy`（mapper 接口，白名单外方法抛 AssertionError）+ RedisService 匿名子类 + standalone MockMvc（Filter+Advice 真实生产类）+ logback ListAppender，**零真实 Redis/MySQL 连接，未引入 Mockito**。

## 15. system 与 auth 实际测试结果（R2 重跑）

- `mvn -pl futurefab-modules/futurefab-system -am test`：**Tests run: 310, Failures: 0, Errors: 0, Skipped: 0，BUILD SUCCESS**（R2 为既有测试强化与生产日志收口，方法数不变：271 + INFRA-ACTOR 39 = 310；其中适配器类 27 项含 R2 日志断言测试、HTTP 映射类 5 项含扩充防泄漏断言）
- `mvn -pl futurefab-auth -am test`：**Tests run: 14, Failures: 0, Errors: 0, Skipped: 0，BUILD SUCCESS**

## 16. git diff --check

exit=0（仅既有 CRLF→LF 转换 warning，均为任务前已存在的 docs 文件，与本任务无关，无空白错误）。

## 17. 未执行的验证层级（不得宣称）

仅达成：编译通过、单元/契约测试通过、静态检查（grep/反射门禁）通过。
**未执行**：真实 Redis 会话读写、真实 MySQL auth_state/sys_user/sys_management_revision 查询、真实 JWT 签发/网关转发、HTTP 端到端联调、Nacos 配置环境下 Spring 上下文启动装配验证。以上均需环境后验收，不得以本报告结果宣称。

## 18. 遗留与阻塞（R2 后）

1. **PRE-AUTH-STATE：认证状态写入与可信会话版本闭环**（§7 定义：auth_state 写路径原子递增 session_version + 可信版本写入会话载体）——真实环境联调前阻塞项；其未实现前，真实环境解析还将因 auth_state 行缺失而 fail-closed（SESSION_INVALID），这是守门行为非缺陷；**不阻塞 ActorContext 只读适配器静态完成，也不阻塞 INFRA-AUDIT / M02-LAB-AUTH-PORT**。
2. retryable 位文档/枚举差异待裁决（§2.5 vs FutureFabErrorCode L305/L307）。
3. ~~日志堆栈面脱敏待裁决~~ **已由 R2 关闭**（§10：依赖异常日志不传 throwable、不记堆栈，ListAppender 锁定 `throwableProxy=null`）。
4. BLOCKED_INPUT：无新增（未涉及外部系统参数）。

## 19. 能否进入 INFRA-GUARD-R2 / INFRA-AUDIT / M02-LAB-AUTH-PORT

- **INFRA-AUDIT、M02-LAB-AUTH-PORT：可以启动**（与 R1/R2 修正面无交叠；本适配器零 M02/审计依赖）。
- **INFRA-GUARD-R2：建议待本次 R2 审阅通过后启动**（R1 审阅指示的延续；R1 三项问题已全部修正并经 R2 日志面收口）。通过后的启动条件已满足：守卫依赖的 ActorContextPort 有唯一生产 Bean，解析时序、fail-closed 语义、错误映射与日志脱敏由 Java 级 + HTTP 级 + 日志事件级 + 接线测试锁定；PRE-AUTH-STATE 不构成其静态阻塞。真实环境装配验证仍受 §17/§18 约束。

## 20. Git 未提交确认

本任务（含 R1、R2）全程**未执行任何 git commit/push**，未执行 reset/checkout/restore/clean。所有交付物位于工作区（本任务文件均为未跟踪新增或骨架文件上的增量）；用户既有工作区修改（session 起始快照中的大量 M 文件）未被触碰；非本任务的 `_tmp` 文件未清理。

---

## 附：R1 修订对照

| 审阅问题 | 初版行为 | R1 行为 | 锁定测试 |
|----------|----------|---------|----------|
| P0-1 无依据 409 | key 激活 + version==0 → 409 SESSION_VERSION_CONFLICT | 规则整体删除；0/正数一律结构合法成功解析；409 仅错误码保留不使用；跨代次比较登记 PRE-AUTH-STATE | `zeroVersionWithMatchingKeyResolvesSuccessfullyNotAsConflict`、`positiveVersionWithMatchingKeyResolvesSuccessfully`、HTTP 级 `zeroVersionHappyPathResolvesOverHttpWithoutConflict` |
| P0-2 revision 落 500 | null/负值抛裸 `IllegalStateException`（无 handler 认领 → HTTP 500） | `ManagementGuardRejectException(AUTH_DEPENDENCY_UNAVAILABLE)` → HTTP 503，消息无表名/SQL/值 | `missingSystemRowMapsToDependency503WithoutFabrication`、`negativeSystemRowMapsToDependency503` + MockMvc `missingSystemRowReturnsHttp503WithErrorCodeAndRequestId` 等 3 项 |
| P1 日志泄漏面 | `log.error(..., cause=e.toString())` 把依赖异常原文拼进消息参数 | 参数只记 requestId+`e.getClass().getName()`，`e` 作 throwable 传框架；堆栈面如实披露并登记遗留项 3 | `dependencyFailureLogsNeverInterpolateRawCauseMessage`（poisoned message 注入四类依赖）、MockMvc 响应体防泄漏断言 |
| 附带收口 | auth_state 行缺失消息含表名 `sys_user_auth_state` | 消息去表名（全部失败消息禁表名断言） | `failureMessagesNeverLeakSessionKeyOrRedisKey` |
| R2 堆栈面泄漏 | throwable 传日志框架→logback 默认追加堆栈，依赖异常原文仍可入 error 日志 | 四处 `log.error` 不传异常对象、不记堆栈；参数恰 requestId+异常类型名；cause 仅随拒绝异常在栈内保留 | `dependencyFailureLogsCarryNoThrowableAndNoSensitiveValues`（throwableProxy=null＋argumentArray＋四类 poisoned 依赖）、MockMvc 防泄漏断言扩充（token/jdbc/SQL 参数/类名） |

R1 边界确认：未实现登录写路径、未改 JWT 契约、未给 ActorContext 加字段（仍恰五）、未改业务 Controller、未动 501 骨架、未改数据库结构或开发基线 SQL、未实现 INFRA-GUARD-R2/INFRA-AUDIT/M02 业务、未提交 Git、未清理他人文件。
R2 边界确认：在 R1 边界基础上另确认——未修改错误码、session_version 口径、ActorContext 字段或任何数据库查询；未修改全局 `logback.xml`、未使用 `%nopex` 掩盖其他模块异常；未修改 Controller、业务骨架、SQL 结构、Vue、客户材料；R2 改动面仅为适配器 4 处 `log.error` 参数与 Javadoc、两个测试类的断言强化、本报告。

---

## 最终结论（四层严格区分，R2）

1. **ActorContext 生产适配器已实现，认证依赖日志面已彻底收口**：`M01ActorContextAdapter` 为唯一生产 ActorContextPort Bean；310+14 测试、HTTP 级映射断言、日志事件级断言（`throwableProxy=null`）与架构门禁全绿（静态层）。session_version 校验当前口径＝"current_session_key 一致性 + 结构合法性"，**不含跨代次比较**（PRE-AUTH-STATE 落地后升级）。
2. **真实业务仍未实现**：auth_state 写路径、76 Controller 接线、全部业务 CRUD 维持骨架语义。
3. **Redis/MySQL/JWT/HTTP 环境尚未验证**：本报告仅覆盖编译/单元/契约/MockMvc-standalone/静态检查层级。
4. **实验室授权仍由后续 M02-LAB-AUTH-PORT 实现**：本适配器与 M02 零依赖，已由反射门禁强制。
