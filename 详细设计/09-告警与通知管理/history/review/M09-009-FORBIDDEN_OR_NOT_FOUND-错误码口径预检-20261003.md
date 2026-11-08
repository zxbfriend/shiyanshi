# M09-009 FORBIDDEN_OR_NOT_FOUND 剩余项开发前预检

日期：2026-10-03。任务性质：只读预检文档，不编码、不改 Java/XML/SQL/skeleton/菜单/前端/Nacos/网关，未执行 SQL，未发送 HTTP。最高声明层级：STATIC_VERIFIED。

目标：判断 M09-009 `PUT /alarm/v2/status-config` 写口内剩余的 `FORBIDDEN_OR_NOT_FOUND` 使用点能否与 002/008/012 已完成的窄修（`FORBIDDEN_OR_NOT_FOUND → NOT_FOUND`）同口径处理，还是存在写口行为差异、SQL 范围差异或权限差异，需要先裁决。

## 0. 归档时点勘误（2026-10-03 追记）

- 本文档为 M09-009 **实施前预检记录**，仅作为预检证据归档。
- 后续远端提交 `645e2517 fix(m09): 对齐 M09-009 不可见写口错误码为契约登记的 NOT_FOUND` 已按本文 §5 白名单完成该窄修（服务层 :268 枚举替换 + 契约测试断言改 NOT_FOUND 并钉住 HTTP 404 + 陈旧注释修正），并复跑契约测试 32/32 通过。
- 当前树中 M09-009 写口**不再残留** `FORBIDDEN_OR_NOT_FOUND`；本文其余章节（尤其 §1 基线、§3 行号取证）描述的是预检时点的 ec0bb25e 状态，不代表当前仍待实现。
- 验证层级以实施提交 `645e2517` 的报告为准：M09-009 写口 = PUSHED + IMPLEMENTED + CONTRACT_TESTED；HTTP / BROWSER / DB 仍为 NOT_VERIFIED，BLOCKED_MENU 保留。本文档本身不提升任何验证层级。

## 1. 基线与 git 状态

- 仓库根目录：`C:\Users\THINK\Documents\GitHub\yaoming_shengwu`（`git rev-parse --show-toplevel` 实测）。
- `git fetch origin cloud` 成功；`origin/cloud = ec0bb25e`（`fix(m09): 对齐 M09-021 形态校验错误码为契约登记的 VALIDATION_FAILED`；该提交同时在目标服务类读口 :136 完成 008 的 `FORBIDDEN_OR_NOT_FOUND → NOT_FOUND` 窄修，提交说明明确"M09-003/009/019 使用点留待后续批次，未做全局替换"）。
- 本地 `HEAD = 4b5c00e7`（docs(m09): 菜单/权限种子预检），与 `origin/cloud` 分叉：`git rev-list --left-right --count HEAD...origin/cloud = 1 1`（共同祖先 `0e5d704f`，本地领先 1 个纯文档提交，落后 1 个远端提交）。
- 处置：本轮不 rebase、不 merge、不 push（未获授权），分叉仅如实报告。本地领先的 1 个提交为 work8 已核对过的历史/review 文档，与本轮证据基线无冲突。
- 工作区状态：`git status --short` 输出为空（干净）。
- 证据基线：本文全部源码行号以 `git show ec0bb25e:<path>` blob 为准，并以 `grep -n` 在 blob 上复核。ec0bb25e 对目标服务类仅改动读口 1 行（:136），未改变行数，故 :268 等写口行号在工作区与远端 blob 一致。

## 2. 权威登记表（现行契约对 M09-009 错误码的口径）

按 AGENTS.md §3/§6 顺序核对，全部为现行权威面：

| 权威入口 | 位置 | 对 M09-009 错误码的登记 | FORBIDDEN_OR_NOT_FOUND 出现？ |
| --- | --- | --- | --- |
| M09 错误码全集 | `docs/详细设计/09-告警与通知管理/错误码全集.md` :18 | `NOT_FOUND / 404 / 不存在或无对象读取范围；不泄露真实对象` | 全文零命中 |
| 最终API基线 | `docs/00-开发基线/最终API基线.md` | 仅有 `## M09-008｜GET /alarm/v2/status-config`（:4398），无 M09-009 独立段（20261002 结论 D 维持） | 无 009 段可泄露 |
| 最终设计闭环矩阵 | `docs/00-开发基线/最终设计闭环矩阵.csv` 第 521 行 | M09-009 登记集合：`UNAUTHENTICATED, FORBIDDEN, NOT_FOUND, VALIDATION_FAILED, ROW_SCOPE_MISMATCH, VERSION_CONFLICT`；权限 `lab:statusalarm:edit`；守卫链 Executor+@ManagementGuardedWrite+AuditIntent；`expectedVersion` CAS `COALESCE(row_version,0)` | 登记集合不含该码 |
| 骨架清单 | `docs/开发任务/00-全接口契约骨架清单.md` `### M09-009` | 同一六码集合；备注"OPERATE（所属实验室操作资格）；稳定顺序加锁、全量预验、整批提交或回滚" | 登记集合不含该码 |
| 页面与接口契约 | `docs/详细设计/09-告警与通知管理/页面与接口契约.md` §3 API09 行 | 409 组为 VERSION_CONFLICT/IDEMPOTENCY_CONFLICT；404 走统一存在性隐藏 | 不含该码 |
| 物理接口与骨架字段设计 | 同目录 :44-54 Controller 签名表 API09 行 | `lab:statusalarm:edit`、`AlarmStatusConfigBatchSaveCommand → MutationResult` | 不涉及 |

结论：`FORBIDDEN_OR_NOT_FOUND` 是 M05 自身口径的跨模块借用码，在 M09 全部现行权威面零登记；M09-009 登记的两码口径为 `NOT_FOUND(404)` 与 `VERSION_CONFLICT(409)`。注册码与使用码不一致，方向与 002/008/012 窄修前完全相同。

## 3. 当前源码分支证据（ec0bb25e blob，行号已复核）

### 3.1 Controller（协议层，本轮不动）

`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/controller/AlarmStatusConfigV2Controller.java`：
- 类级 `@RequestMapping("/alarm/v2/status-config")` :28。
- M09-008 GET :35-42：`@RequiresPermissions("lab:statusalarm:list")` + `@CurrentManagementRevision`。
- M09-009 PUT :44-54：`@RequiresPermissions("lab:statusalarm:edit")` :45、`@ManagementGuardedWrite` :46、WriteMeta 头部回填 :51-52。功能权限在进入应用服务前判定，与本轮错误码分支无关。

### 3.2 应用服务写口分支

`.../service/impl/application/m09/AlarmStatusConfigApplicationApplicationServiceImpl.java`：
- `saveStatusConfig` :188-256 顺序：requestId/labId/tab/rows 非空形态校验（INPUT_INVALID，守卫外）:195-213 → 从 SecurityUtils 取 authAdmin/authUserId :215-225 → payload 规范化 :227-235 → scopeKey `"STATUS:"+labId+":"+tab` :236 → `guardExecutor.execute(OPERATION_SAVE_STATUS, writeMeta, payload, actor -> writeStatusConfig(...))` :244-246。
- 回调 `writeStatusConfig` :262-295，**目标分支 :266-270**：

```java
if (labStatusAlarmConfigMapper.countLabVisibleV2(labId, authAdmin, authUserId) == 0)
{
    throw new ManagementGuardRejectException(FutureFabErrorCode.FORBIDDEN_OR_NOT_FOUND,   // :268
            "实验室不存在或无权访问");                                                      // :269
}
```

- 触库顺序（窄修前后均不变）：可见性验证 :266 先于台账 `alarmConfigRevisionService.recordApplied(KIND_STATUS,...)` :274-277、先于逐行 CAS `updateStatusAlarmQuantityWithVersionV2` :282-283（`hit != 1 → VERSION_CONFLICT` 整组回滚 :284-288）、先于审计 before/after :290-294；回执插入在守卫执行器内、回调成功之后（见 3.4）。即"不可见/无权"拒绝路径在任何写副作用之前抛出，改为 NOT_FOUND 不改变写触碰集合。

### 3.3 数据范围 SQL（"无权访问"文案确有范围支撑）

`futurefab-modules/futurefab-system/src/main/resources/mapper/lab/LabStatusAlarmConfigMapper.xml`（注意实际路径在 `mapper/lab/`，非 `mapper/system/`）：
- `statusLabScope` :254-258：`<if test="authAdmin == null or !authAdmin"> AND ${alias}.lab_id IN (SELECT ul.lab_id FROM sys_user_lab ul WHERE ul.user_id = #{authUserId})</if>` — admin 旁路与普通用户实验室授权共用同一片段。
- `countLabVisibleV2` :261-267：`WHERE ll.lab_id=#{labId} AND ll.del_flag='0'` + `<include refid="statusLabScope">`（alias=ll，:266 附近）。
- 读口（008，已在 ec0bb25e 窄修为 NOT_FOUND，:134-136）与写口 :266 调用**同一个** `countLabVisibleV2`、同一 `statusLabScope` 口径。文案"实验室不存在或无权访问"与 SQL 语义一致：不存在（del_flag 或无行）与不在授权集合都返回 0 → 统一 404，不泄露真实存在性。
- 行级 CAS `updateStatusAlarmQuantityWithVersionV2` :331-342：`WHERE config_id AND lab_id AND COALESCE(row_version,0)=#{expectedRowVersion}`，与本轮无关。

权限分支核对：009 无 SELF/ADMIN 双上下文参数（区别于 API17/19/20/21）；唯一分支是 authAdmin 旁路，且与 008 读口共享同一 SQL 片段——读口窄修已按此口径通过，写口不存在额外"权限差异需先裁决"的事实。

### 3.4 错误码枚举、异常映射与守卫事务

- `futurefab-api/futurefab-api-system/.../FutureFabErrorCode.java`：`FORBIDDEN_OR_NOT_FOUND(...,404,...)` :209、`NOT_FOUND(...,404,...)` :237。**两码 HTTP 状态同为 404**，窄修是 HTTP 中性的，仅改变响应 `errorCode` 字符串。
- `.../service/guard/ManagementGuardExceptionHandler.java` :30-45：`new AjaxResult(e.getHttpStatus(), e.getMessage()).put("errorCode", e.getErrorCodeValue())`；`ResponseEntity.status(e.getHttpStatus())` — 文案 `"实验室不存在或无权访问"` 原样透传，窄修后 msg 不变。
- `.../service/guard/ManagementGuardExecutor.java`：单一 TransactionTemplate :42/:80/:163，锁 SYSTEM 行→回执检查→版本 CAS→回调→审计→`insertReceipt` :290-291（回执在回调成功后写入）。守卫链自身的 REQUEST_CONFLICT/MANAGEMENT_CONFLICT/IDEMPOTENCY 类拒绝码不在闭环矩阵登记的六码集合内，属守卫通用行为，与本轮枚举更名无关，不动。

### 3.5 前端引用面（重试语义）

`futurefab-frontend/` monorepo 静态检索：对 `PUT /alarm/v2/status-config` 零引用；UI05 当前仍走旧 COMPAT 入口 `/lab/statusalarm/batch-save`。因此窄修不触及任何在途前端重试/分支逻辑（404 与 404，HTTP 状态本就不变）。

## 4. 是否具备窄修条件：具备，无需先裁决

对照本批次各接口：

| 接口 | 分支 | 与 009 的同类性 |
| --- | --- | --- |
| 002/008/012 | 读口"不存在或无权"→ NOT_FOUND，已完成 | 009 写口 :268 与已窄修的 008 读口 :136 调用同一 `countLabVisibleV2`/`statusLabScope`，同一文案口径，完全同类 |
| 003 | `AlarmRecord...Impl:271/294/305` 仍留该码 | 不同类：003 与 finding②（记录行级可见性缺 SQL 范围支撑）纠缠，需先裁决"不可见"措辞依据；009 不存在该问题（3.3 已证文案有 SQL 范围支撑） |
| 019 | `AlarmNotification...Impl:285` | 另案，本轮不评估 |

判定依据汇总：
1. 两码同为 404 → HTTP、前端重试、响应外壳均不变（3.4/3.5）。
2. 文案可原样保留（handler :30-45 透传 msg）。
3. 权威登记集合含 NOT_FOUND 且从不有 FORBIDDEN_OR_NOT_FOUND（第 2 节）→ 窄修是向契约收敛，非契约变更。
4. 无写口行为差异：拒绝发生在守卫事务内、任何台账/CAS/回执写之前（3.2），窄修改名不改时序。
5. 无 SQL 范围差异、无额外权限分支：与已窄修读口共用同一可见性查询与 admin 旁路片段（3.3）。

登记不一致（不在本轮修复，只登记）：目标类注释 :57 仍写"批量保存 M09-009 未放行，保持显式 501"，与 :188-295 的真实实现不符——属陈旧注释，窄修实施批次可顺带只改该注释行，勿扩大。

## 5. 最小改动白名单（未来窄修批次，需届时另行开工授权）

仅允许两处：
1. `AlarmStatusConfigApplicationApplicationServiceImpl.java` :268 — `FutureFabErrorCode.FORBIDDEN_OR_NOT_FOUND` → `FutureFabErrorCode.NOT_FOUND`（单枚举引用替换，:269 文案不动）。
2. `M09WiredStatusOnlineConfigContractTest.java` :757（方法 `statusInvisibleLabWritesNoLedgerWithinGuard` :750-761）— `assertEquals(FutureFabErrorCode.FORBIDDEN_OR_NOT_FOUND, e.getErrorCode())` → `NOT_FOUND`。该方法其余断言（`assertNull(capturedRevision.get())`、receipts/operLogs/changeLogs 为空、`assertEquals(1, txRollbacks)`）均与码名无关，不需要改。若方法或邻近注释提及旧码名，仅同步措辞。

git grep 证实 ec0bb25e 上 status 相关测试中 FORBIDDEN_OR_NOT_FOUND 仅此 1 处（:757）。

## 6. 禁止清单（窄修批次不得触碰）

- 不改 `countLabVisibleV2`、`statusLabScope`、`updateStatusAlarmQuantityWithVersionV2` 及任何 XML。
- 不改 VERSION_CONFLICT（:286）、INPUT_INVALID 形态校验（:195-213）、守卫链错误码（REQUEST_CONFLICT/MANAGEMENT_CONFLICT/IDEMPOTENCY）。
- 不改 Controller 权限注解、`@ManagementGuardedWrite`/`@CurrentManagementRevision`、WriteMeta 回填。
- 不动 M09-003、M09-019 使用点；不动 M05 自有口径与 M03 `MemberIdentityFactsPolicy`；不做任何全局/批量替换。
- 不执行 SQL、不发 HTTP、不动菜单/权限种子/前端/Nacos/网关。
- 不"顺手"重排 saveStatusConfig 校验顺序或补 003 的行可见性（各自另案）。

## 7. 推荐测试命令（实施批次使用）

环境事实（用户级记忆）：PATH 无 mvn，用 IDEA 捆绑 maven3 + dragonwell-17；管道 exit code 不可信，以输出文本 `BUILD SUCCESS` 为准。

```bash
# 定向契约测试（窄修两条断言所在类）
mvn -pl futurefab-modules/futurefab-system -am test \
  -Dtest=M09WiredStatusOnlineConfigContractTest

# 模块全量回归
mvn -pl futurefab-modules/futurefab-system -am test
```

通过标准：`statusInvisibleLabWritesNoLedgerWithinGuard` 断言 NOT_FOUND 且"零台账/零回执/零审计/1 次回滚"原断言全部保持通过——这同时证明窄修未改变写副作用边界。

## 8. 风险分级

- P0：无。窄修为枚举引用向已登记契约收敛，HTTP 状态同为 404，无行为面变化。
- P1：`statusInvisibleLabWritesNoLedgerWithinGuard` 若漏改 :757 则实施批次测试红；已定位精确行，风险可控。
- P2：陈旧注释 :57（"保持显式 501"）继续误导阅读者；建议实施批次顺带更正，不单独开工。
- P2：闭环矩阵/骨架清单未把守卫链码并入 009 登记集合（登记口径不完整），属登记文档问题，与本窄修正交，留待契约登记批次统一处理。

## 9. 分层口径

| 层级 | 状态 |
| --- | --- |
| 文档存在/链接与权威面核对 | STATIC_VERIFIED（本文） |
| 源码分支/SQL 片段/测试断言行号取证 | STATIC_VERIFIED（基于 ec0bb25e blob + grep -n 复核） |
| 编译 | NOT_VERIFIED（本轮未构建） |
| 契约测试 | NOT_VERIFIED（本轮未运行） |
| SQL 执行 | NOT_VERIFIED（本轮未执行，禁止执行） |
| HTTP 联调 | NOT_VERIFIED（本轮禁止发 HTTP） |
| 浏览器验收 | NOT_VERIFIED |
| 目标库/现场验收 | NOT_VERIFIED |

## 10. 结论与建议

M09-009 **具备与 002/008/012 同口径的窄修条件，无需先裁决**：目标 :268 的"实验室不存在或无权访问"确有 `countLabVisibleV2 + statusLabScope + del_flag` SQL 范围支撑，与已完成窄修的 008 读口共用同一查询；两码同为 404，文案经守卫异常处理器原样透传；改动面为服务层 1 行 + 契约测试 1 行。与 003 的"不可见但无 SQL 范围"纠缠情形不同，003 仍须先裁决。建议协调者按第 5 节白名单排入下一窄修批次，第 6 节禁止清单随单下发。
