# 22-TASK-GATES-R1：ActorContext 去领域范围化与 G2 职责边界修正报告

版本：TASK-GATES-R1-DD-20260919-R1。任务性质：设计矛盾修正（契约模型＋测试＋活跃设计文档）。本任务不实现任何生产适配器与真实业务；不改 Mapper/XML/SQL/Vue/Controller/76 条骨架；不触碰 ManagementGuardExecutor 幂等/CAS 核心逻辑。

## 一、结论

TASK-GATES-R1 **完成**。TASK-GATES（21 报告）G2 裁决存在设计矛盾：一面规定 ActorContext 只负责身份/会话/权限版本，一面让 M01ActorContextAdapter 调用 M02 服务聚合 labScopes——这会使全部 29 个管理写都依赖 M02，并把锁前范围快照传播为潜在授权依据。本任务已消除该矛盾：**ActorContext 恢复为五字段纯身份/会话/版本上下文（labScopes 已从模型删除）；SEC-I01 及其生产适配器不依赖 M02；实验室范围唯一权威=M02 拥有的 LabAuthorizationPort，按具体业务动作在 SYSTEM 锁后同一事务内计算与重验；M02 不可用只阻塞依赖实验室授权的业务**。G2 逻辑状态 REOPENED_FOR_R1→验证通过后重新 **CLOSED**；G1/G3/G4 全程保持 CLOSED 未动。

> **最终表述：ActorContext已去除领域范围，G2职责边界闭合；G1/G2/G3/G4均已关闭，可以启动INFRA-ACTOR、INFRA-AUDIT和M02-LAB-AUTH-PORT实现。生产适配器和真实业务仍未实现。**

## 二、原设计缺陷（21 报告 G2 口径，已由本报告 §五与 21 报告 §〇-A 废止）

1. §2.2 输出表将 labScopes 列为 ActorContext 契约字段，权威来源="适配器调用 M02 拥有的 LabAuthorizationService 聚合推导"。
2. §2.7 SEC-I01 时序图含"经 M02 查询服务聚合 labScopes"一步，即身份解析依赖 M02。
3. §2.8 INFRA-ACTOR 文件归属允许"M02 LabAuthorizationService 注入"。
4. 后果推演（缺陷本质）：菜单/角色/字典/配置/部门/实验组等 26 个与实验室无关的守卫写接口也被绑定到 M02 可用性；且锁前解析的范围快照若被下游信任，等价于把"事务内重验"降级为"请求入口一次快照"，违背 G3 的锁后重验冻结。
5. 澄清：全仓取证确认**不存在任何 A 类（生产代码真实调用 actorContext.labScopes 做授权判断）**——缺陷停留在契约模型字段与文档口径层，无既有运行时行为需要迁移。

## 三、ActorContext 最终字段（冻结，五字段）

| 字段 | 类型 | 权威来源 |
|---|---|---|
| actorUserId | String（正十进制） | 可信 Redis 会话 login_tokens:{sessionKey}→LoginUser，＋sys_user 停用/删除复核 |
| actorName | String | 可信会话（LoginUser.username），仅审计展示不作身份键 |
| sessionKey | String | 服务端 JWT/网关认证链路（user_key claim=Redis 键）；不接受普通业务 Header/Body 自报 |
| authzVersion | String | sys_management_revision 固定 SYSTEM 行当前值（裁决不变，≠session_version≠objectVersion≠M02 authorizationVersion） |
| requestId | String | RequestMetadataContext/WriteMeta 合并结果 |

ActorContextQuery 保持 {requestId, sessionKey} 不变；`resolveActorContext(ActorContextQuery) -> ActorContext` 物理方法签名不变（PKG-00 §6.1 的方法冻结未被破坏，仅结果字段集修订）。

## 四、删除的字段及原因

- **labScopes（List<String>）＋getLabScopes/setLabScopes＋java.util.List/ArrayList import：已从 `service/port/m01/model/ActorContext.java` 删除。**
- 原因：①领域范围不属于 SEC-I01 职责（身份/会话/版本），保留即持续制造"锁前范围可作授权依据"的歧义载体；②使 29 个管理写全部依赖 M02 可用性，与 G3"M02 依赖仅约束实验室授权业务"矛盾；③全仓无 A 类真实调用，删除零行为影响；④任务书 §二 冻结边界明确 SEC-I01 不得负责实验室/部门/项目/培养范围、角色/权限集合快照、任何领域对象授权、调用 M02/M03/M04 等领域服务。
- 任务书 G2 原建议字段（sessionKeyFingerprint/sessionVersion/roles/permissions/resolvedAt/authenticationSource/enabled/deleted/sessionValid）维持 21 报告 §2.2 的"不入契约"裁决，本次不恢复、不新增。

## 五、ActorContextPort 最终职责（Javadoc 已同步）

负责：当前操作者是谁（actorUserId/actorName）、会话是否仍有效（sessionKey 与 Redis 当前会话/auth_state.current_session_key/session_version 匹配）、用户是否停用/删除、当前 authzVersion、requestId 关联；同一请求只解析一次、锁与写入前解析、全链复用同一快照；失败 fail-closed（401 SESSION_INVALID/SESSION_REPLACED、409 SESSION_VERSION_CONFLICT、403 ACCOUNT_UNAVAILABLE、503 AUTH_DEPENDENCY_UNAVAILABLE），不降级匿名。

不负责（禁止清单）：实验室/部门/项目/培养范围、角色/权限集合快照、任何领域对象授权、调用 M02/M03/M04 等领域服务、读取领域私有表、产生业务写。ActorContext 不是长期权限票据。

## 六、INFRA-ACTOR 允许依赖

M01ActorContextAdapter（`service/impl/port/m01`，尚未实现）允许依赖仅限会话/认证链路：Redis login_tokens 模板（LoginUser 反序列化）、sys_user_auth_state 读取、sys_user 状态读取（停用/删除）、sys_management_revision(SYSTEM) 无锁读取、RequestMetadataContext/WriteMeta。

## 七、INFRA-ACTOR 禁止依赖

禁止注入或调用：LabAuthorizationPort/LabAuthorizationService 及任何 M02 组件、M03/M04 等领域 Port、领域私有表 Mapper、以及任何"为 ActorContext 计算范围"的适配器逻辑（契约快照测试 `actorContextCarriesNoDomainScopeAfterGatesR1` 以反射固定 ActorContext 与 ManagementGuardExecutor 均无 m02 类型依赖）。

## 八、实验室范围最终权威

- 唯一边界=M02 拥有的 `LabAuthorizationPort`（prepareUserEdit/replaceUserLabs/removeUserLabs，三方法与物理签名不变，G3 15 维冻结不变）。
- 调用方式：M01 ApplicationService 把可信 ActorContext（身份对象，非范围载体）传给 M02 Port；M02 依据 actorUserId、当前功能权限映射与 M02 当前数据计算范围；**不接受 ActorContext 预置 labScopes、不接受浏览器提交 labScopes、不接受 M01 预计算实验室 ID 范围作为授权权威**；一切写操作范围判定在 SYSTEM 锁后同一事务内重验；查询候选范围（可授予实验室集合）同样由 M02 Port（prepareUserEdit 输出 laboratories/defaultLabIds）返回。
- M01 侧 `SmpPermissionQueryMapper.selectLabIdsByAuthLevel` 直查违例仍为实现阶段必改项（改造方向=经 M02 查询服务，但**不再引用"labScopes 同口径"**）。
- authzVersion 不是 M02 authorizationVersion；两者载体、递增时机、比较对象均不同（21 报告 §2.3/§2.3 显式区分继续有效）。

## 九、M02 不可用的影响边界

- 只有调用 LabAuthorizationPort 的具体业务（USR03/USR04/USR06 实验室授权阶段）受 M02 依赖故障影响：503 **LAB_AUTHORIZATION_UNAVAILABLE**（错误码枚举已存在，retryable=true；不映射为 RESOURCE_FACTS_UNAVAILABLE，二者语义域不同），M01 不保存部分数据、整事务回滚。
- 菜单、角色、字典类型/数据、参数配置、部门、实验组、场地等不依赖实验室授权的管理写：ActorContext 解析链路（§六）不含 M02，M02 不可用时**仍可完整完成**——原设计"29 写全量依赖 M02"的阻塞面收窄为 3 个用户写接口。

## 十、跨模块迁移清单（全仓检索 8 组关键词，逐条分类）

检索词：`actorContext.labScopes`、`getLabScopes()`、`setLabScopes(`、`含actorUserId/requestId/labScopes`、`必须落在actorContext.labScopes内`、`可信六字段`、`输出ActorContext六字段`、`labScopes`（不区分大小写，含前端与全部模块）。命中处置：

| # | 位置 | 类别 | 处置 |
|---|---|---|---|
| 1 | `port/m01/model/ActorContext.java` 字段+getter/setter+import | B 契约模型字段 | **已删除**（本任务） |
| 2 | 同文件类头 Javadoc"六字段" | C Javadoc | **已改**五字段+R1 声明 |
| 3 | `port/m01/ActorContextPort.java` Javadoc"…requestId、实验室范围" | C | **已改**：不含范围＋禁调领域服务＋适配器依赖白名单 |
| 4 | `port/m03/model/ParameterApplicationQuery.java` L20 注释"含 actorUserId/requestId/labScopes" | C | **已改**五字段口径 |
| 5 | `port/m03/model/UnfinishedLabBusinessQuery.java` L20/L23"…labScopes""必须落在 actorContext.labScopes 内" | C | **已改**：范围由拥有模块事务内实时判定 |
| 6 | `port/m03/model/WorkflowRemovalQuery.java` L22"含…labScopes" | C | **已改**五字段口径 |
| 7 | `service/guard/ManagementGuardExecutor(.java/Test)` | A 检查 | **无 labScopes 引用**，无需改；测试 trustedPort 仅设 actorUserId/requestId/sessionKey，删除字段不破坏编译（全量测试佐证） |
| 8 | 其余全部 Java 生产/测试源码、futurefab-ui、XML/SQL | A/B 检查 | **0 命中**（含 getLabScopes/setLabScopes 全仓 0 调用） |
| 9 | `docs/开发任务/21-…报告.md` §2.2/§2.6/§2.7 图/§2.8/§3.1 违例行/§八 G2 closeNote | D 活跃设计 | **已修订**：新增 §〇-A R1 修订声明；各处醒目标注"已由 TASK-GATES-R1 废止"（原文以删除线/勘注保留历史） |
| 10 | `docs/详细设计/01-系统管理/详细设计.md` 2026-09-19 条款 2＋节标题 | D | **已修订**（五字段+禁依赖 M02+影响边界） |
| 11 | `docs/详细设计/01-系统管理/Controller请求调用时序设计.md` §6 SEC-I01 行 | D | **已修订** |
| 12 | `docs/详细设计/02-实验室与资源管理/用户实验室授权内部服务逐方法契约.md` 版本行＋actor 承载句（"可信六字段"） | D | **已修订**（五字段+范围由 M02 锁内计算重验） |
| 13 | `docs/历史归档/02总体设计与公共契约-V4.0.md` §8.1 指针段 | D | **已修订**（补 R1 口径） |
| 14 | `docs/开发任务/10-…审计.md/.json` blockers.G2 closeNote、§13/14/15/17 相关行、meta.lastUpdatedTask、acceptance_gates | D | **已修订**（MD/JSON 同源一致） |
| 15 | `docs/详细设计/00-总纲与约定/00-Controller与模块接口调用总设计.md` L263"对象范围仍由拥有方校验" | D 检查 | **与 R1 一致，无需改** |
| 16 | `docs/开发任务/01-契约骨架/02-PKG-00公共契约与Port物理签名设计.md` §6.1 L116（六字段冻结表） | E 历史/冻结基线 | **不修改**（PKG-00 冻结文档不在本任务允许清单）；在此登记：其 ActorContext 结果字段集描述已由 TASK-GATES-R1 修订，方法签名部分仍然有效，现行字段集以本报告 §三为准 |
| 17 | `docs/开发任务/01-契约骨架/08-PRE-01C管理守卫可运行前置执行报告.md` L44-45（六字段填充口径） | E 历史撤回记录 | **不修改**（任务书禁止）；该报告整体已是 09 撤回态历史 |
| 18 | `docs/详细设计/03-项目与培养管理/详细设计.md`"表单六字段" | E 检查 | 语义为项目表单字段，与 ActorContext 无关，**不改** |

A/B 类已在任务内清零；C/D 类全部改为"ActorContext 身份＋拥有模块 Port 实时范围判定"口径；E 类仅登记。G2 关闭条件不因残留受阻。

## 十一、修改源码清单（6 文件）

1. `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/port/m01/model/ActorContext.java`：删 labScopes 字段/getter/setter/List·ArrayList import；Javadoc 五字段＋R1 声明。
2. `.../service/port/m01/ActorContextPort.java`：Javadoc——职责白名单、领域范围与领域服务禁令、INFRA-ACTOR 依赖边界（接口方法未动）。
3. `.../service/port/m03/model/ParameterApplicationQuery.java`：actorContext 字段注释改五字段。
4. `.../service/port/m03/model/UnfinishedLabBusinessQuery.java`：两处注释去除 labScopes 授权口径。
5. `.../service/port/m03/model/WorkflowRemovalQuery.java`：注释改五字段。
6. `futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/contract/PortSignatureSnapshotTest.java`：
   - `highRiskDetailedContractModelFieldsStayFrozen` 增加 ActorContext 精确五字段快照＋ActorContextQuery 两字段快照断言；
   - 新增 `actorContextCarriesNoDomainScopeAfterGatesR1`：无 labScopes 字段、无 get/setLabScopes、无集合字段、ActorContext 字段类型不引用 m02、`resolveActorContext(ActorContextQuery)->ActorContext` 签名保持、ManagementGuardExecutor 实例字段无 m02 依赖、LAB_AUTHORIZATION_UNAVAILABLE 保持 503。
   - 未改动：ManagementGuardExecutorTest（取证确认无 labScopes 构造/断言，23 项幂等/CAS/回执/可信 actor 测试原样通过）、ManagementGuardExecutor、LabAuthorizationPort 及 m02 model（业务签名本就只承载 actorContext 对象，无需改）、任何 Controller/Mapper/XML/SQL/Vue。

## 十二、修改文档清单（7 文件＋本报告）

21 报告（§〇-A 新增＋6 处废止标注/就地更正）、01 详细设计（条款 2 重写＋节标题）、Controller 时序设计（§6 SEC-I01 行）、M02 逐方法契约（版本行＋actor 承载句）、docs/02 总体设计（§8.1 指针段）、10 审计 MD（§13 行 6、§14 G2 行、§15 两行、§17 补充）、10 审计 JSON（meta.lastUpdatedTask、blockers.G2 items/closeNote、acceptance_gates 两处）；新增本报告 22。未修改：02-PKG-00、08/09 历史报告、00 清单、05 审计、客户材料。

## 十三、测试结果（串行执行）

| 门禁 | 命令/方式 | 结果 |
|---|---|---|
| system 全量 | `mvn -pl futurefab-modules/futurefab-system -am test` | **Tests run: 271, Failures: 0, Errors: 0, Skipped: 0，BUILD SUCCESS**（≥270，含新增 1 项契约快照测试；PRE-01B 守卫测试 ManagementGuardExecutorTest 23 项、ManagementGuardConfigTest 2 项等全绿；76 条骨架契约测试无回归） |
| auth 全量 | `mvn -pl futurefab-auth -am test` | Tests run: 14, Failures: 0, Errors: 0, Skipped: 0，BUILD SUCCESS |
| 空白检查 | `git diff --check` | 通过（仅既有 CRLF 提示，无空白错误） |
| JSON 解析 | node JSON.parse 10 审计 JSON | OK |
| 阶段门一致性 | G1/G2/G3/G4 在 MD/JSON 均 CLOSED | OK |
| 76/0 | status_counts | COMPLETE_SKELETON=76 / PARTIAL_SKELETON=0 未动 |
| 全生产源码 actorContext.labScopes 授权判断 | 全仓检索 | 0 残留（A/B/C 类清零；E 类 2 处按规则保留并登记 §十 16/17） |
| 临时脚本 | 本任务未新增过程脚本 | 无遗留 |

任务书 §九 12 项测试门禁与本报告§十/§十三逐项对应：1-5、7、9、12 由新增/扩展契约测试断言；6、8 由 ManagementGuardExecutorTest 既有断言无回归证明；10 由全仓检索＋编译通过证明；11 由 PortSignatureSnapshotTest m02 冻结签名测试（三方法未动）证明。

## 十四、G1/G2/G3/G4 最终状态

- G1：CLOSED（不变，本任务未触碰其裁决内容）。
- G2：**CLOSED**（执行期逻辑状态 REOPENED_FOR_R1；§十~§十三修正与验证全部完成后重新闭合；10 审计 closeNote 已含 R1 七要素）。
- G3：CLOSED（不变；仅其"契约-物理差异"表述涉及的 actor 承载语义按五字段收敛，Port 三方法、所有权矩阵、事务规则零改动）。
- G4：CLOSED（不变）。
- BLK-02/03/04b/04c：OPEN 不变；76 条接口结论、路由数量不变。

## 十五、76/0 是否保持

保持。COMPLETE_SKELETON=76 / PARTIAL_SKELETON=0，未触碰任何接口记录与 501 骨架入口。

## 十六、是否实现真实业务

否。本任务仅修改契约模型字段、Javadoc、注释与契约测试断言＋设计文档；ActorContextPort/ManagementAuditHook/LabAuthorizationPort 生产适配器仍全部不存在；无任何查询、写入、审计、守卫行为被实现。

## 十七、是否修改 Mapper/XML/SQL/Vue

否。全部改动限于 §十一 6 个 Java（模型/接口 Javadoc＋测试）与 §十二 8 个 Markdown/JSON。

## 十八、未执行环境验证

数据库、Redis、JWT、网关、HTTP、浏览器、外部系统均未运行验证；ActorContext 五字段的会话解析行为在真实链路上的取证待 INFRA-ACTOR 实现后验证。本报告验证层级＝静态源码＋编译＋单元/契约测试＋文档一致性核对。

## 十九、下一步实现任务包（顺序不变，边界已修正）

1. **INFRA-ACTOR**（可立即启动）：M01ActorContextAdapter 按 §六/§七 依赖边界实现五字段解析；禁止 M02 注入。
2. **INFRA-AUDIT**（并行）：AuditIntent/AuditSnapshot/Hook R2（21 报告 §1.5 不变）。
3. **M02-LAB-AUTH-PORT**（并行）：范围计算/重验、候选集合、版本与负责人逻辑全部落 M02。
4. INFRA-GUARD-R2（依赖 INFRA-AUDIT 模型）。
5. M01-USR-BUSINESS（依赖 1+3；USR03/04/06 为当前设计中仅有的 M02 依赖业务写）。
TASK-ROUTE 仍待用户裁决；BLK-02/03/04b/04c 仍开放，均不阻塞上述三包启动。

## 二十、Git 状态

未提交、未推送、未执行 reset/checkout/restore/clean；全部改动以工作区未提交状态交付，供用户审阅。
