# 审阅意见：work1 本轮 M01 交付（work4，2026-09-29）

审阅人：work4（总协调 2026-09-29 裁决 5 指定）。审阅性质：**只读评审，未改动任何源码/基线**。

送审范围（8 份文件＋2 篇文档，全部未提交，基线 `bf4475c2`）：

| # | 文件 | 状态 | 规模 |
| --- | --- | --- | --- |
| 1 | `service/impl/port/m01/M01FunctionPermissionAdapter.java` | 新增 | 216 行 |
| 2 | `test/.../m01/M01FunctionPermissionAdapterContractTest.java` | 新增 | 323 行／14 用例 |
| 3 | `service/guard/ManagementOperation.java` | 修改 | 122 → 148（+26） |
| 4 | `service/audit/AuditObjectType.java` | 修改 | +5 对象族 |
| 5 | `service/audit/AuditPolicyRegistry.java` | 修改 | +5 白名单常量、+26 行 put |
| 6 | `test/.../AuditPolicyRegistryTest.java` | 修改 | 期望表 +26、122→148、87/33→103/43 |
| 7 | `test/.../ManagementOperationTest.java` | 修改 | 码集 +26、122→148 |
| 8 | `docs/详细设计/05-检测与数据签批/history/review/M05权限码菜单种子建议清单-20260929.md` | 新增 | 纯静态文档 |
| 9 | `docs/详细设计/00-跨模块审阅收尾/history/review/review包-work1-SEC-I02与M05动作登记-20260929.md` | 新增 | 送审说明 |

---

## 1. 结论

**状态建议：ACCEPT_WITH_P1**（P0：无）。

三条 P1 都不是实现缺陷，而是**口径登记缺口**：代码与测试本身干净（1372 全绿），但有三处"未来接线者会踩空"的地方必须在本轮落成注释或裁决记录。

---

## 2. 实测命令与结果（必测项）

Git Bash 下 `mvn` 脚本不可用，按项目既有绕法用 classworlds 启动器：

```bash
cd /d/Code/zhixianweilai/yaoming-cloud
MH=D:/Programs/Maven; MPD=D:/Code/zhixianweilai/yaoming-cloud
java -cp $MH/boot/plexus-classworlds-2.9.0.jar \
  -Dmaven.home=$MH -Dclassworlds.conf=$MH/bin/m2.conf \
  -Dmaven.multiModuleProjectDirectory=$MPD \
  org.codehaus.classworlds.Launcher -pl futurefab-modules/futurefab-system -am test
```

结果（2026-09-29 12:10:48）：

```
Tests run: 1372, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.futurefab.system.service.impl.port.m01.M01FunctionPermissionAdapterContractTest
[INFO] Tests run: 14, Failures: 0, Errors: 0, Skipped: 0
Reactor: futurefab-modules-system SUCCESS [40.576 s]
BUILD SUCCESS   Total time: 56.843 s
```

层级：**CONTRACT_TESTED**。未做 HTTP、未做浏览器、未连库，不得标 `HTTP_VERIFIED` / `BROWSER_VERIFIED`。

补充实测（本轮自行复核，非引用送审文档）：

| 检查 | 命令/位置 | 结果 |
| --- | --- | --- |
| 041/042 无注解 | `DetSignConsoleController.java:92-93`、`:100-101` | 确无 `@RequiresPermissions`（`:75-76`/`:83-84`/`:107-108`/`:115-116` 有） |
| 038 预览口 | `DetSignConsoleController.java:156-157` | 无注解，未登记 ✓ |
| 基线 02 未被改 | `git status --short docs/开发基线/` | 空；`grep -c "INSERT INTO \`sys_menu\`" 02-…` = 0；`grep -c "detect:" 02-…` = 0 |
| 白名单列名命中 DDL | 逐列对 `01-完整建表.sql` | 5 组 94 列全部命中真实列（含 PK：`result_item_id`/`correction_id`/`sample_id`） |
| 未知动作码口径 | `ManagementGuardExecutor.java:150-152` | `ManagementOperation.fromCode(...)==null` → `INPUT_INVALID` |
| 错误码 HTTP | `FutureFabErrorCode.java` | INPUT_INVALID 400 / PERMISSION_DENIED 403 / SESSION_INVALID·SESSION_REPLACED 401 / ACCOUNT_UNAVAILABLE 403 / AUTH_DEPENDENCY_UNAVAILABLE 503 |
| 骨架全量比对 | `skeleton-m05.json` 63 项 | 26 项登记＝全为非预览写；预览 5、读口 17、legacy CRUD 9（052~060）未登记 |

---

## 3. P0 问题（无）

---

## 4. P1 问题清单

| # | 问题 | 证据 | 风险 | Owner |
| --- | --- | --- | --- | --- |
| P1-1 | **050/051 登记 vs 052~060 不登记，口径不自洽；且 050/051 当前是 501 骨架桩** | `skeleton-m05.json`：050/051/052 的 `svcFq` 同为 `LegacyDetectionEndpointGuard`、`respTypeFq` 同为 `DisabledEndpointResult`；`LegacyDetectionEndpointGuardImpl:33/39` 抛 `SkeletonNotImplementedException("M05-050/051")`；`DetResultController:100/108` 两者都有 `@RequiresPermissions` | 三类端点性质完全相同（legacy CRUD＋骨架 501＋有冻结 perm），却一个登记一个不登记；且登记了"INSERT/UPDATE＋det_result 全字段快照"的审计策略，实际端点恒 501。未来 M05 若真要实现，需回改枚举＋注册表＋两处冻结期望表（4 文件） | 总协调（裁决 4 复核）＋M05 设计 |
| P1-2 | **注解路径（会话快照）与 SEC-I02 Port（实时直读）结果可能不一致，未登记口径** | `SysPermissionServiceImpl:92` 登录时把 `selectMenuPermsByUserId` 结果装进会话；`M01FunctionPermissionAdapter:125` 每次实时直读同一 SQL | 撤权后：注解路径滞后放行、Port 即时拒绝；新授权后：Port 放行、注解拒绝。当前两条路径不叠加故无即时冲突，但一旦某接口既带注解又走 Port，判定基准不明 | M01 负责人 |
| P1-3 | **"动作编码已登记但权限串缺失"的中间态未在代码层标记** | `ManagementOperation` 中 M05-004/023/032/041/042 的 javadoc 只写业务语义；清单 §四虽标 P0，代码侧无提示 | 接线者易误以为加 `@ManagementGuardedWrite` 即完成，实际这 5 个口契约无 perm（041/042 连注解都没有） | work1 补注释；M05 负责人定串 |

**P1-1 建议落地**：
1. `M05_050/M05_051` 常量 javadoc 补：`端点当前为骨架 501（LegacyDetectionEndpointGuard 显式拒绝），本登记为正式化预留；接线前不得宣称为已守卫写`。
2. `M05-052~060` 排除理由细化写进块注释：`052/053/054 可复用已有 DET_RESULT_ITEM 族，无技术障碍；真正卡点是 055~060 需新增 signrecord/assignee 对象族且表名未定`——否则日后返工时无法判断是"技术不可行"还是"等待裁决"。

**P1-2 建议落地**：在 `M01FunctionPermissionAdapter` javadoc 或 M01 契约处登记一句：`注解路径＝登录时会话快照，Port 路径＝每次实时直读；同一接口两者并存时以更严格判定为准`。

**P1-3 建议落地**：5 个常量 javadoc 统一补 `契约权限串待裁决（BLOCKED_DESIGN，P0）；接线前禁止开放入口`。

---

## 5. P2 问题清单

| # | 问题 | 位置 | 建议 |
| --- | --- | --- | --- |
| P2-1 | 送审文档写死 `Tests run: 1357`，本次实测 1372（work3 提交并入后变化） | review 包 §六、种子清单 §九/§十 | 数字易漂移，改为"全绿"＋注明基线 commit |
| P2-2 | `declared.getAuthzVersion()` 只做形态校验，未与 `trusted` 比对；decision 取 trusted 版本 | `M01FunctionPermissionAdapter:159-160`、`:147` | 当前无安全影响（会话重解析已覆盖陈旧场景），建议注释写"以 trusted 为准" |
| P2-3 | `selectMenuPerms()`（`SysMenuMapper.xml:99-104`）**无 where**，返回菜单定义全集（含停用菜单） | 字典检查口径 | 与授权查询的 `status='0'` 不同口径，建议注释固化"登记＝配置中存在，停用即时生效体现在授权查询" |
| P2-4 | JSON 引用列入快照且无长度/条目约束：`changed_paths`、`evidence_refs`（det_result_correction，JSON NOT NULL）、`content_manifest`（det_print_export_log，JSON NULL） | `AuditPolicyRegistry:270-278`、`:284-288` | 非凭据，可接受；建议注明"引用/清单类列，实现期限制条目数或截断" |
| P2-5 | `sign_by`/`review_by` 为 username 列入 DET_RESULT 快照 | `AuditPolicyRegistry:256-257` | 与"身份只认稳定 userId"的演进方向不一致（表列事实如此）；建议注明"用户名仅作展示溯源，身份判定仍以 `active_*_id`／`det_result_sign_record.signer_user_id` 为准" |
| P2-6 | 签批伴随写不另立对象族的结论未写清边界 | `AuditPolicyRegistry` 签批六动作注释 | 补一句：`det_result_sign_record 由 M05 侧独立留存，其 content_snapshot 等大 JSON 不在本审计策略覆盖范围`，避免误以为已覆盖 |
| P2-7 | `AuditObjectType.DET_REPORT_JOB` 对应表名 `det_print_export_log`，枚举名与表名不一致 | `AuditObjectType:104-105` | javadoc 已标表名，可接受；建议枚举注释直接出现 log 字样 |
| P2-8 | actorUserId 不一致用 400 而非 401 | `M01FunctionPermissionAdapter:115-116` | 与 `ManagementGuardExecutor:150-152` 未知 operationCode→INPUT_INVALID 同口径 ✓，建议 javadoc 固化"为何非 401" |
| P2-9 | 工作区无关未跟踪文件仍存在 | `.local-db-list.py`、`.local-dept-probe.py/.txt`、`.local-role-scope-probe.py/.txt`、`M05-M06-acceptance-report.md`，以及本轮之外其他代理产物（如 M03 审阅记录） | review 包 §一已声明前 6 项不入库 ✓；提交时必须显式路径 `git add`，**禁止 `git add .`** |
| P2-10 | SEC-I02 适配器已 `@Component` 装配但**当前无任何生产调用方** | `grep checkFunctionPermission` 仅命中端口/测试/签名快照测试 | 状态写 `IMPLEMENTED + CONTRACT_TESTED`，不得表述为"M05 已接入 SEC-I02" |

---

## 6. 重点项逐条核验结论

| # | 审查重点 | 结论 | 依据 |
| --- | --- | --- | --- |
| 1 | SEC-I02 是否用可信 ActorContextPort、不信任请求体 actor | **通过** | `:107-110` 以 declared 的 sessionKey/requestId 原样重走 `resolveActorContext`；判权键用 `trusted.getActorUserId()`；`:111-117` 声明≠可信即 INPUT_INVALID；形态校验（`:151-165`）先于一切，浏览器拼装产物在进判权前被拒 |
| 2 | 权限来源是否与 `@RequiresPermissions` 同源 | **通过** | `M01FunctionPermissionAdapter:125` → `SysMenuMapper.selectMenuPermsByUserId`（`SysMenuMapper.xml:106-112`，`sys_menu ⋈ sys_role_menu ⋈ sys_user_role ⋈ sys_role`，`m.status='0' and r.status='0'`）；注解链 `SysPermissionServiceImpl:92` → `SysMenuServiceImpl:105` → 同一 Mapper/同一 SQL |
| 3 | 401/403/503/INPUT_INVALID 分层 | **通过** | 形态非法 400；会话失效/顶号 401（透传 ActorContextPort 的 SESSION_INVALID/SESSION_REPLACED，不改写）；账号停用 403（ACCOUNT_UNAVAILABLE）；未登记码 400；DB 异常 503；null 结果 503；真未授予 403。与 `FutureFabErrorCode` 实测映射一致（详见 P2-8） |
| 4 | 未登记权限串是否 fail-closed | **通过** | `:178-201` → `INPUT_INVALID` 抛异常（非 `allowed=false`）；测试 `unregisteredPermissionCodeFailsClosedNotDenial` 用 `verify(menuMapper, never()).selectMenuPermsByUserId` 锁定不落到授权查询；与"合法码未授予"的 PERMISSION_DENIED 明确区分 |
| 5 | 26 个 M05_0NN 是否只覆盖正式 guarded write | **通过** | 实测 skeleton 63 项全量比对：预览 001/002/028/031/038 未登记；读口 005/007/014/015~020/033/034/045~047/049/061~063 未登记；登记的 26 项全为非预览写（HTTP POST/PUT/DELETE） |
| 6 | M05-052~060 暂不登记是否符合 NEED_M05_DECISION | **符合裁决**（但口径见 P1-1） | 与总协调裁决 4 一致；清单 §八 P5 已列为裁决项 |
| 7 | 白名单是否泄露大字段/凭据 | **通过**（两项见 P2-4/P2-5） | 94 列逐列命中 DDL 真实列；`raw_data`/`time_evidence`/`collection_basis`/`source_progress`/`source_evidence`/`candidate_snapshot`/`submission_signature`/`review_signature`/`selection_snapshot`/`job_evidence`/`file_path`/`file_sha256`/`request_payload_hash` 全部未入；无口令/密钥列 |
| 8 | 新增对象族是否必要且与表名一致 | **通过** | `det_result`/`det_result_item`/`det_sample`/`det_result_correction`/`det_print_export_log` 均在基线 DDL 存在；5 族互不重叠且被 26 行全覆盖（`EnumSet.allOf(AuditObjectType.class)` 门禁） |
| 9 | 签批伴随写不另立对象族是否合理 | **合理** | 装配期 `map.size()==ManagementOperation.values().length` 全等门禁要求每个枚举值必有注册行；增设 `DET_RESULT_SIGN_RECORD` 会为 039~044 增设第二行，打破"一动作一行策略"不变量；签批主写对象本就是 `det_result` 状态链 |
| 10 | M05-041/042 缺注解是否列为 M05 P0 | **已列**（代码层见 P1-3） | 清单 §四标注"契约缺口：先定串（P0）"×2，§八 P1 列为裁决项；实测控制器确无注解 |
| 11 | 菜单 seed 清单是否只是协作输入、未误改基线 02 | **通过** | `git status docs/开发基线/` 空；`02-基础数据初始化.sql` 的 `sys_menu` INSERT 与 `detect:` 均 0 命中；文档 §六四条硬阻断成立，未产出 SQL |
| 12 | 是否混入无关未跟踪文件 | **未混入**（提醒见 P2-9） | review 包 §一明确声明 6 个无关文件不入库；本轮改动严格限制在上表 9 项 |

---

## 7. 送审文档 Q1~Q6 答复索引

- **Q1（是否同源、快照反差）**：同源成立；反差客观存在 → 登记为 **P1-2**。
- **Q2（未登记码 400 还是 403）**：维持 400。与 `ManagementGuardExecutor:150-152` 未知 operationCode→INPUT_INVALID 同口径；若改 403 会把"配置错误"混同"无权"，削弱审计取证。**ACCEPT 现口径**。
- **Q3（401/403/503 分层）**：**全部正确**，见 §6-3。仅 actorUserId 不一致的 400 建议补理由（P2-8）。
- **Q4（26 个是否只覆盖正式写）**：(a) 未混入预览/读口 ✓；(b) 未发现真实受控写漏登记 ✓；(c) 050/051 vs 052~060 不自洽 → **P1-1**。
- **Q5（白名单泄露/两项口径）**：无泄露 ✓；(a) 伴随写不另立族合理 ✓（补注见 P2-6）；(b) `del_flag` 仅由 DELETE/聚合行 `plus(...)` 追加、INSERT 行 before 为空，统一 ✓；`changed_paths`/`evidence_refs`/`content_manifest` 可接受（P2-4）；M02-243 与 M02-248 双口径建议按送审意见在登记说明里写硬。
- **Q6（041/042 是否列 P0）**：清单已列 ✓；代码层补标 → **P1-3**。

---

## 8. 未验证项声明

- 未执行 HTTP 请求、未做浏览器验收、未连数据库、未外部系统联调：全部 `NOT_VERIFIED`。
- SEC-I02 适配器无生产调用方，能力尚未启用。
- M05 侧 `@ManagementGuardedWrite`/`@CurrentManagementRevision`/WriteMeta/前端双头接线未做，归 M05 批次。
- 全部 `detect:*` 权限串的授予链为 `BLOCKED_MENU` ＋ `BLOCKED_DATA`（缺 M01 菜单登记表）。
