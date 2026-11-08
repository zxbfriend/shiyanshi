# review 包 · work1 本轮交付（SEC-I02 生产实现 ＋ M05 动作编码/审计策略登记 ＋ detect 权限码清单）

送审日期：2026-09-29；审阅人：**work4**（总协调 2026-09-29 裁决 5 指定）。
代码基线：`cloud` 分支 `bf4475c2 锁定用户实验室授权删除语义`；本轮改动**全部未提交**（裁决 6：先不 `git add`、不 commit、不 push，等 work2 补完后由总协调统一排 review/提交顺序，避免多代理并发改共享注册表）。

本文是**送审说明（过程性材料）**，依 `AGENTS.md` §12 存放于 `history/review/`；不是契约、不是权威设计、不构成基线变更。

---

## 一、审阅范围（只含 work1 本轮文件，越界项不在包内）

| # | 文件 | 状态 | 规模 |
| --- | --- | --- | --- |
| 1 | `futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/port/m01/M01FunctionPermissionAdapter.java` | 新增 | 216 行 |
| 2 | `futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/service/impl/port/m01/M01FunctionPermissionAdapterContractTest.java` | 新增 | 323 行／14 用例 |
| 3 | `.../service/guard/ManagementOperation.java` | 修改 | 122 → 148（+26 常量，末行 `;`→`,`） |
| 4 | `.../service/audit/AuditObjectType.java` | 修改 | 净 +5 对象族 |
| 5 | `.../service/audit/AuditPolicyRegistry.java` | 修改 | +5 字段白名单常量、+26 行 `put(...)` |
| 6 | `.../src/test/java/com/futurefab/system/service/audit/AuditPolicyRegistryTest.java` | 修改 | 期望表 +26 行、计数 122→148、绑定分布 87/33→103/43 |
| 7 | `.../src/test/java/com/futurefab/system/service/guard/ManagementOperationTest.java` | 修改 | 码集 +26、`assertEquals(122→148)` |
| 8 | `docs/详细设计/05-检测与数据签批/history/review/M05权限码菜单种子建议清单-20260929.md` | 新增 | 纯静态文档，未改任何 SQL |

`git status --short` 另有的 6 个未跟踪文件（`.local-db-list.py`、`.local-dept-probe.py/.txt`、`.local-role-scope-probe.py/.txt`、`M05-M06-acceptance-report.md`）**不属本轮产物，未触碰、不入库**。

获取差异：

```bash
git rev-parse HEAD            # 期望 bf4475c2（工作区在其之上，改动未提交）
git status --short
git diff --stat
git diff -- futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/guard/ManagementOperation.java \
              futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/audit/AuditObjectType.java \
              futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/audit/AuditPolicyRegistry.java \
              futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/service/audit/AuditPolicyRegistryTest.java \
              futurefab-modules/futurefab-system/src/test/java/com/futurefab/system/service/guard/ManagementOperationTest.java
# 新增 Java/文档未跟踪，直接读文件（git diff 看不到）
```

---

## 二、本轮依据（裁决逐条对应）

| 裁决 | 内容 | 落地位置 |
| --- | --- | --- |
| 1 | SEC-I02 只补 M01 提供方，不进 M05 Controller/Service | 文件 1/2；未改任何 `controller/` 或 M05 service |
| 2 | 接收为 `CONTRACT_TESTED` | 仅契约测试证据，无 HTTP/浏览器声明 |
| 3 | 签批伴随写不另立对象族的处理"可进入 work4 review" | 本包 §四-Q5、§五-取舍 2 |
| 4 | 26 个 `M05_0NN` 登记；`M05-052~060` 继续 `NEED_M05_DECISION` | 文件 3/5/7 |
| 5 | 审计同步注册、白名单逐字对 DDL、不得借 M02 码、不得随意字符串 | 文件 4/5/6 |
| 6 | 不提交 | 本包 §一 说明 |
| 3（种子） | 先审清单与 5 个无串写口，不改 `02-基础数据初始化.sql` | 文件 8；§五-取舍 4 |

权威文档依据：`docs/开发任务/02-PKG-00公共契约与Port物理签名设计.md` §6.1（SEC-I01/I02/I03 签名冻结）；`docs/详细设计/21-TASK-GATES-G1-G3阶段门裁决报告.md` §1.4（29 项动作→审计策略口径）；`docs/详细设计/05-检测与数据签批/` 的 `接口目录与契约定位.md`、`检测工作台接口与位置生命周期.md`、`检测记录与结果操作设计.md`、`受控更正逐接口契约`、`签批记录与报告导出设计`；`docs/开发基线/01-完整建表.sql`（det_ 表列名）；`futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m05.json`（逐接口冻结台账）。

---

## 三、实现要点与代码定位

**M01FunctionPermissionAdapter（SEC-I02）** — 判定顺序即失败关闭顺序：

1. `:97-100` `query`/`actorContext` 缺失 → `INPUT_INVALID`，不返回 null、不构造匿名身份。
2. `:104` `validateActorShape`（`:152-172`）：actorUserId 必须十进制串；sessionKey/requestId/authzVersion 缺一即拒；`:169-172` 权限串语法 `^[a-z0-9][a-z0-9:*.-]{0,99}$` 非法 → `INPUT_INVALID`。
3. `:107-110` **实时撤权重验**：以 `sessionKey/requestId` 原样再走一次 `ActorContextPort.resolveActorContext`（会话/顶号/停用/SYSTEM 版本全链），因此权限判定永远基于服务端可信会话，而不是调用方自带的上下文。
4. `:111-117` **声明身份与可信身份不一致 → `INPUT_INVALID` fail-closed**（伪造/串号上下文在判权前就被拒）。
5. `:119` → `verifyCodeRegistered`（`:177-199`）：权限串必须落在 `menuMapper.selectMenuPerms()` 登记的字典全集内；未登记 → `INPUT_INVALID`（配置错误，与"合法码但未授予"语义分开）；`Constants.ALL_PERMISSION`（`*:*:*`）豁免登记检查。
6. `:121-134` `selectMenuPermsByUserId` 抛 `DataAccessException` → `AUTH_DEPENDENCY_UNAVAILABLE`(503)，**不伪装为拒绝**；异常消息不含 sessionKey。
7. `:135-138` 授权查询返回 `null` → 503（依赖不可用），不是"无权限"。
8. `:139-148` 命中 `*:*:*` 或精确码 → `allowed=true, reason=GRANTED`；否则 `allowed=false`＋`PERMISSION_DENIED`＋携带 `authzVersion`；拒绝日志只打 `requestId/permissionCode/objectHint`。
9. `:53` `objectHint` 只透传定位，**不参与授权计算**（有对应用例锁定）。
10. 依赖白名单只有 `ActorContextPort` ＋ `SysMenuMapper`；测试用反射类路径扫描锁定"`FunctionPermissionPort` 生产实现恰为该类一个"（`:200-260`）。

**M05 动作编码与审计策略**

- `ManagementOperation:321-381` 新增 26 个 `M05_0NN`，每个常量 javadoc 标注逐接口契约出处；块注释登记裁决 4 与 `M05-052~060` 未登记理由。
- `AuditObjectType:98-106` 新增 `DET_RESULT`/`DET_RESULT_ITEM`/`DET_SAMPLE`/`DET_RESULT_CORRECTION`/`DET_REPORT_JOB`。
- `AuditPolicyRegistry:253-294` 五个字段白名单（列名逐字来自 `01-完整建表.sql`）；`:928-1050` 26 行策略；`:1052-1064` 装配期全等闭合门禁（数量不等/缺项/重复登记均 `IllegalStateException`）。
- 冻结期望表两处以"字面量逐行"方式扩，不用循环生成（沿既有口径）。

---

## 四、请重点判定（总协调指定的六条）

**Q1 SEC-I02 是否与 `@RequiresPermissions` 同源？**
注解链消费的是 `SysPermissionServiceImpl:92` 在登录时装配进会话的权限集合；本适配器直读 `SysMenuMapper.selectMenuPermsByUserId`（`SysMenuMapper.xml` 内联 `m.status='0' and r.status='0'`）。请判定：直读是否等价于同源，以及**注解路径存在会话缓存快照**这一事实会不会造成"Port 判权"与"注解判权"在同一用户上的结果差异；如果会，属不属 M01 侧需要登记的反差。

**Q2 未登记权限串该 `INPUT_INVALID` 还是 `PERMISSION_DENIED`？**
现口径：未登记＝配置错误＝`INPUT_INVALID` 失败关闭（`:177-199`），与"合法码未授予"（403）区分。请对照 `ManagementGuardExecutor` 里"未知 `operationCode` → `INPUT_INVALID`"的既有约定判定一致性；若认为应统一为 403，请给出对幂等/审计取证的影响。

**Q3 503 / 403 / 401 语义是否每路都正确？**
逐路核：`query`/上下文形态非法(400)、可信重解析失败(由 ActorContextPort 抛 401 `SESSION_INVALID`/`SESSION_REPLACED` 或 403 `ACCOUNT_UNAVAILABLE`)、声明≠可信(400)、未登记码(400)、DB 异常(503)、`null` 结果(503)、真未授予(403)。请特别判定 `:111-117` 的不一致用 400 是否恰当（另一种口径是 403）。

**Q4 26 个动作是否只覆盖正式受控写？**
登记集＝`003/004/048/008/009/010/011/012/013/021/022/023/025/026/027/029/030/032/039/040/041/042/043/044/050/051`。请核对：(a) 是否混入预览/读口（候选疑点：`028 preview-delete`、`031/038` 预览、`033/034` 报告读取、`005/049` 更正读、`014` 幂等回执读，本轮**均未登记**）；(b) 是否有真实受控写漏登记；(c) `050/051` 属 legacy `detresult` 增改，登记而不登记 `052~060` 是否自洽。

**Q5 审计白名单是否泄露大字段或凭据？**
排除项：`raw_data`、`time_evidence`、`collection_basis`、`source_progress`、`candidate_snapshot`、`content_snapshot`、`selection_snapshot`、`file_path`、签名原文/口令类列。请逐列对 `01-完整建表.sql` 复核，并判定 `changed_paths`/`evidence_refs`/`content_manifest` 这类"引用/清单"列入快照是否可接受。
另请判定两项口径选择：**(a) 签批六动作（039~044）主策略挂 `DET_RESULT`＋`OUTCOME_AFFECTED_IDS`，`det_result_sign_record` 作伴随写不另立对象族**（裁决 3 明确交此 review）；**(b) `del_flag` 不进基础白名单，只由删除/聚合行的 after 通过 `plus(...)` 追加**——请检查是否存在基础列与追加列重复、以及 INSERT 行 before 为空的口径是否统一。
批量"部分跳过"（`013/030` 与 `039~044`）沿 **M02-243 先例**＝`changeOperation=UPDATE`＋`OUTCOME_AFFECTED_IDS`＋`AuditDeleteKind.NONE`，与 M02-248 的"真软删＝DELETE＋LOGICAL"并存，请判定这一双口径是否要在登记说明里写得更硬。

**Q6 M05-041/042 缺权限注解是否已列为 M05 P0？**
现状：`DetSignConsoleController:93/:101` 两个撤销口**既无契约权限串也无 `@RequiresPermissions`**；同型缺口还有 `004/023/032`。本轮只登记动作编码与审计策略，未替 M05 接线。请判定清单 §四/§5.2 的分级是否够清楚，以及"动作编码已登记但权限串缺失"这一中间态是否要在注册表注释里再标一句。

---

## 五、已知取舍与开放点（请审阅人确认或推翻）

1. **未改 M05 任何文件**（裁决 1/4）：`@ManagementGuardedWrite`/`@CurrentManagementRevision`/WriteMeta 接线全部留给 M05 批次。
2. **`DET_RESULT_SIGN_RECORD` 曾建后删**：为避免"枚举值无注册行"触发装配期闭合门禁，改为伴随写口径并从 `AuditObjectType` 移除。若 review 认为应保留该对象族，需要为 039~044 增设第二行策略——这会打破"一个动作一行策略"的既有不变量，请一并评估。
3. **`M05_048` 语义**：骨架里 048 是"受控更正申请提交"（`det_result_correction` INSERT），不是"报告生成"；已按骨架登记，早期口头台账曾把它当报告号，请勿据旧台账判定。
4. **种子文档不产出 SQL**：`docs/开发基线/03-初始化结果核验.sql:86` 把任意 `sys_menu` 行判为异常、`来源清单.json.seedTables` 不含 `sys_menu`、`02-基础数据初始化.sql` 对 `detect:` 与 `sys_menu` 均 0 命中；因此只出登记表建议＋裁决问题清单（P1~P8）。请审 §六四条阻断与 §四差异表的计数（24 骨架码／13 无串／9 已导出／76 控制器在用／52 反向差）。
5. **验证层级**：只到 `CONTRACT_TESTED`。无 HTTP、无浏览器、无库执行；不得被读成"权限可授予"或"M05 写接口已守卫"。

---

## 六、复现与验证命令

```bash
# 全量模块测试（本轮已跑，需带 -am；Windows 控制台 GBK，判据看 exit code 与 surefire）
mvn -pl futurefab-modules/futurefab-system -am test
# 期望：Tests run: 1357, Failures: 0, Errors: 0, Skipped: 0；BUILD SUCCESS；exit 0

# 定向三件套
mvn -q -pl futurefab-modules/futurefab-system -am \
  -Dtest=AuditPolicyRegistryTest,ManagementOperationTest,M01FunctionPermissionAdapterContractTest \
  -Dsurefire.failIfNoSpecifiedTests=false test

# 动作编码数量与注册表闭合（失败会在类加载期抛 IllegalStateException）
grep -c "^    M05_[0-9]" futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/guard/ManagementOperation.java   # 期望 26
grep -c "put(map, ManagementOperation.M05_" futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/audit/AuditPolicyRegistry.java   # 期望 26

# 白名单列名逐字核对 DDL（示例：det_result）
awk '/CREATE TABLE `det_result`/,/ENGINE/' docs/开发基线/01-完整建表.sql | grep -oE '^\s+`[a-z0-9_]+`' | tr -d ' `'

# 种子文档事实复算
grep -c "INSERT INTO \`sys_menu\`" docs/开发基线/02-基础数据初始化.sql   # 期望 0
grep -c "detect:" docs/开发基线/02-基础数据初始化.sql                    # 期望 0
grep -c "detect:" sql/sys_menu.sql                                       # 期望 14 行 / 9 个去重码
```

---

## 七、状态口径（AGENTS.md §13.2）

| 事项 | 状态 |
| --- | --- |
| SEC-I02 生产实现＋契约测试 | `CONTRACT_TESTED`（14 用例，M01 侧） |
| 26 个 M05 动作编码＋审计策略登记 | `CONTRACT_TESTED`（注册表闭合门禁＋两处冻结期望表绿） |
| detect 权限码种子建议清单 | `STATIC_REVIEWED`，本身不改变任何接口状态 |
| M05 侧写口接线（注解/WriteMeta/前端头） | 未做，归 M05 批次（`NOT_VERIFIED`） |
| M05-041/042（及 004/023/032）权限串 | `BLOCKED_DESIGN`，需 M05 裁决 |
| 全部 `detect:*` 码的授予链 | `BLOCKED_MENU` ＋ `BLOCKED_DATA`（缺 M01 菜单登记表） |
| HTTP / 浏览器 / 数据库 / 外部系统 | `NOT_VERIFIED` |

**未提交**：本轮产物一律停留在工作区，等总协调安排 review/提交顺序。

---

## 八、work4 审阅结论与 P1 处理记录（2026-09-29 追加）

审阅结论：**ACCEPT_WITH_P1，无 P0**，实现保留、不回滚（总协调 2026-09-29 转发）。§一~§七 的送审原文不改写，本节记录落地后的实际改动与校正后的锚点；引用 §三 行号时以本节为准。

### P1-1 M05-050/051 与 052~060 口径不自洽 → 已修

- `ManagementOperation`：删除 `M05_050`/`M05_051` 两常量，M05 块注释改为"050~060 统一 `NEED_M05_DECISION`"，并写明理由（原 050/051 登记已于 P1-1 撤下）。枚举常量数 122→**146**，M05 段常量 26→**24**（`grep -c "^    M05_[0-9]"`＝24）。
- `AuditPolicyRegistry`：删除 `M05_050`/`M05_051` 两行 `put(...)`，原位留一行理由注释；M05 策略行数 **24**，注册表总行 **146**，装配期全等闭合门禁未放宽。
- 事实依据（实测，非引用）：`LegacyDetectionEndpointGuard.java:26`（M05-050）、`:29`（M05-051）、`:32/35/38`（052/053/054）同批登记为"骨架：显式 501／DISABLE"，与 052~060 同族；`DetResultController` 注入的正是该 guard（`:4,55`）。
- `AuditObjectType` 未回退：`DET_RESULT` 仍由 021/022/027/039~044 覆盖，对象族全覆盖断言仍绿。
- 两处冻结期望表同步：`AuditPolicyRegistryTest`（期望表删 2 行、146 行断言、分布 `OUTCOME_ID 101 / AFFECTED_IDS 43 / 副作用 1 / 计数回执 1`，并顺手修掉一条重复的 S-3  tally 注释行）；`ManagementOperationTest`（码集删 2 个、146 断言）。

### P1-2 `@RequiresPermissions` 会话快照 vs SEC-I02 实时直读分叉 → 只登记口径，不改实现

- 实现逻辑未动、公共 AOP 未动。`M01FunctionPermissionAdapter` 类注释新增"与 `@RequiresPermissions` 的关系"小节（新 `:44-58`），明确三点：同一份 `sys_menu/sys_role_menu` 授权事实（来源一致）；取数时机不同（注解＝登录/刷新时算定的会话快照，Port＝每次 `selectMenuPermsByUserId` 实时直读）；撤权后到下一次会话刷新或强制下线之间两者可能短时间分叉，登记为 **M01 安全口径差异**，如需统一另开独立任务评估开销与批量失效方案。
- 该结论即 §四 Q1 的落地答复：同源成立，同时机不同，属需登记的口径差异而非缺陷。

### P1-3 动作编码已登记但权限串缺失的中间态 → 已标注

- `M05-004/023/032/041/042` 五个常量 javadoc 增写裁决原话口径：`operation registered for guard/audit only; business permission string is BLOCKED_DESIGN/BLOCKED_MENU pending M05 permission-code decision（登记不等于可判权）`。
- `M05-041/042` 额外标注 **M05 P0**，并给出实测锚点：`DetSignConsoleController.java:92-93`（`/revoke-sign`）、`:100-101`（`/revoke-audit`）两个 `@PostMapping` 上方确无 `@RequiresPermissions`（同类 `:75/:83/:107/:115/:130/:146` 均有，可对照）。控制器本体未改，接线归 M05 批次。
- 种子建议清单 `M05权限码菜单种子建议清单-20260929.md` 同步：§四 标题与归纳改为 24 项登记、050/051 两行标注"已撤下（501 桩）"、§七 14/15 行与 P5 改为"050~060 统一 `NEED_M05_DECISION`"。

### §三 锚点位移校正（P1 注释追加导致行号整体下移）

| §三 原锚点 | 现锚点 | 内容 |
| --- | --- | --- |
| `:97-100` | `:109-113` | `query`/`actorContext` 缺失 → `INPUT_INVALID` |
| `:104`（`:152-172`） | `:115`（`:163-183`） | `validateActorShape` ＋ 权限串语法校验 |
| `:107-110` | `:118-122` | 实时撤权重验 `resolveActorContext` |
| `:111-117` | `:123-129` | 声明身份与可信身份不一致 → `INPUT_INVALID` |
| `:119`（`:177-199`） | `:132`（`:190-`） | `verifyCodeRegistered` 字典校验 |
| `:121-134` | `:134-145` | `DataAccessException` → `AUTH_DEPENDENCY_UNAVAILABLE`(503) |
| `:135-138` | `:146-150` | 授权结果为 `null` → 503 |
| `:139-148` | `:151-159` | `*:*:*` 或精确码命中；拒绝日志仅 `requestId/permissionCode/objectHint` |

### 复跑验证（P1 修完后）

```
mvn -pl futurefab-modules/futurefab-system -am test   → exit code 0
```

surefire 报表逐类汇总（本批 104 份报告，全部时间戳属本次运行）：`Tests run: 1374, Failures: 0, Errors: 0, Skipped: 0`。
关键门禁类单项：`AuditPolicyRegistryTest` 8/0、`ManagementOperationTest` 3/0、`M01FunctionPermissionAdapterContractTest` 14/0、`FullSystemSkeletonGateTest` 9/0、`ManagementGuardedWriteArchTest` 14/0、`M05SkeletonContractTest` 5/0、`PortSignatureSnapshotTest` 6/0。
总数较送审时的 1357 增加 17，来自 HEAD 已并入的 M03 提交（`b9216338`/`f429cea3`）新增用例，非本轮改动引入。

### 状态口径（AGENTS.md §13.2，P1 处理后）

最高仍为 `CONTRACT_TESTED`。`M05-050/051` 现为 `NEED_M05_DECISION`（未登记）；`M05-004/023/032/041/042` 为 `BLOCKED_DESIGN`；全部 `detect:*` 码授予链 `BLOCKED_MENU`＋`BLOCKED_DATA`；P1-2 分叉为已登记安全口径差异；HTTP／浏览器／数据库／外部系统一律 `NOT_VERIFIED`。仍未 `git add`、未 commit、未 push。

---

## 九、保护性 ff 合流与注册表并集（2026-09-29 14:20 追加）

P1 修完后，远端 `cloud` 新增一个 M02 提交 `7037fbdb feat(m02): wire detector runtime profile provider`（22 文件 / 2489 行插入），其中 **`M02_169`（检测设备运行配置发布写，M-1）** 与本轮一样改了 `ManagementOperation` / `AuditPolicyRegistry` / 两处冻结期望表。按总协调裁决执行保护性合流，不改别人的实现。

### 9.1 过程（逐步）

1. 先发现索引被并发代理整树 `git add`（含禁止纳入的 `.local-*`、`M05-M06-acceptance-report.md`）→ 未擅自处理，上报后按裁决 `git restore --staged .` 清空。
2. 只 stash 本轮 5 个已跟踪注册表文件（显式路径，不带 `-u`，未跟踪新文件与 `.local-*` 原地保留）→ `stash@{0}: On cloud: work1 M01 M05 registration before pulling cloud`。
3. `git fetch origin` + `git pull --ff-only origin cloud` → HEAD `bf4475c2` → **`7037fbdb`**，无合并提交。
4. `git stash pop`：`ManagementOperation.java` / `AuditObjectType.java` / `AuditPolicyRegistry.java` 干净并入；`AuditPolicyRegistryTest.java`、`ManagementOperationTest.java` 两处 `UU` 冲突（共 5 个冲突 hunk）。因为 pop 冲突，stash 条目被 Git 保留。
5. 冲突按**并集**原则解：保留远端 `M02_169` 与其策略行 + 保留本轮 24 个 M05 登记（050/051 仍按 P1-1 撤下）+ M05-050~060 统一 `NEED_M05_DECISION` 不进注册表。
6. `git add` 被权限分类器按"不 git add"的既有约束拦截 → 改用 `git reset -q -- <5 个显式路径>` 清除 unmerged 记录，不产生任何 staged 内容；`git status` 确认 unmerged=0、staged=0。

### 9.2 并集后的计数（取代 §八 的 146 口径）

| 项 | P1 后（§八） | 合流后（本节） |
| --- | --- | --- |
| `ManagementOperation` 常量数 | 146 | **147** = 122 + 1（M02-169）+ 24（M05） |
| `AuditPolicyRegistry` 策略行 | 146 | **147**（`grep -c "put("`） |
| `AuditPolicyRegistryTest` 期望表 | 146 行 | **147 行**（字面量逐行，未循环生成） |
| 绑定分布 | OUTCOME_ID 101 / AFFECTED_IDS 43 / 副作用 1 / 计数回执 1 | **OUTCOME_ID 102 / AFFECTED_IDS 43 / 副作用 1 / 计数回执 1**（M02-169 是单对象写，只进 OUTCOME_ID） |
| `ManagementOperationTest` | `assertEquals(146, …)` | `assertEquals(147, …)`，码集同时含 `M02-169` 与 24 个 `M05-*` |
| M05 段 | 24（050/051 已撤） | 24（不变） |

装配期全等闭合门禁（数量不等 / 缺项 / 重复登记 → `IllegalStateException`）**未放宽**。

### 9.3 复跑验证（合流后）

```
mvn -pl futurefab-modules/futurefab-system -am test   → exit code 0，BUILD SUCCESS
Tests run: 1394, Failures: 0, Errors: 0, Skipped: 0
```

总数由 §八 的 1374 增至 **1394**（+20），来自 `7037fbdb` 带入的 M02 M-1 用例，非本轮改动引入。关键门禁类单项：`AuditPolicyRegistryTest`、`ManagementOperationTest`、`M01FunctionPermissionAdapterContractTest` 14/0、`FullSystemSkeletonGateTest`、`PortSignatureSnapshotTest` 均 0 失败。

### 9.4 合流后 git 现场

- 5 个注册表文件为 ` M`（已改、**未 staged**）；`git diff --cached --stat` 为空。
- 未跟踪：本轮 2 个新 Java 文件（`M01FunctionPermissionAdapter.java` + 契约测试）、本轮 2 份 history 审阅记录，以及他人/本地在途项（`.local-*`、`M05-M06-acceptance-report.md`、M03 与 work4 的审阅文档）——均**未纳入任何操作**。
- `stash@{0}` 因 pop 冲突被保留，内容与工作区当前 5 个文件一致；**是否 drop 需总协调批准**，本轮未动。
- 未 `git add` / 未 commit / 未 push；HEAD 停在 `7037fbdb`。

### 9.5 状态口径（合流后）

最高仍为 `CONTRACT_TESTED`；未做 HTTP、浏览器、数据库与外部系统验收，`detect:*` 授予链仍 `BLOCKED_MENU`＋`BLOCKED_DATA`。
