# work1 · UNKNOWN 原证据受控恢复独立复测（2026-10-26，因阻塞缺陷中止）

本轮为 UNKNOWN 受控恢复的首次运行期验收。执行到 BGA 预览步骤时命中一个阻塞缺陷，
按分工约定不自行修改实现代码，记录精确证据交回主任务。业务表零改动。

## 一、范围与运行身份

- 主任务 HEAD：`fe2b6ff1435c35b3ea1a7fec64dd49c655f966c6`（报告时仍为该值）。
- 后端产物：`futurefab-modules/futurefab-system/target/futurefab-modules-system.jar`
  - SHA-256 `b19b72f6afacabc2902a2eace6318eafe60b41d454b874a1077bd891179654e9`，大小 134232802，mtime 2026-10-26 15:56:35
  - 报告时重新计算，SHA 与端口拥有者一致（见下）。
- 运行进程：PID 26812，`java -jar …futurefab-modules-system.jar --spring.profiles.active=dev …`，启动 15:57:21，9201 唯一监听者。
  命令行与 `restart-second-id-system.ps1:137` 完全一致，即本轮部署由该脚本 `-SkipStop` 启动。
- 恢复核准：`.local-start-tools/unknown-recovery-approvals.json`，恰 19 条派发，值均为
  `QA-MOCK-USER-20261026-UNKNOWN-RECOVERY`；未发布 Nacos，未扩大授权范围。
- 旧进程处置：首次打包 `BUILD FAILURE`（`Unable to rename …jar to …jar.original`，运行中的 system 持有 jar）。
  先用 `stop-owned-system.ps1` 核对该 PID 命令行确属本任务族的 QA 启动器且为 9201 唯一拥有者，只停止该 PID（旧 PID 28644），
  未批量结束 Java/Node。第二次打包 `BUILD SUCCESS`。
- 取证通道：新建只读代理 5586→5581（`unknown-recovery-evidence-proxy.cjs`），仅记录
  `X-Request-Id`/`X-Management-Revision`/`X-M05-Contract-Version`/`content-type` 与目标路径的请求响应，不落 Authorization/Cookie。
  原 5584 代理只匹配 `/detect/workbench/*/sample/`，抓不到本轮路径；5585 已被另一会话占用，未触碰他人工具。
- 浏览器：内置可见浏览器，用户保持面板前置；截图见 `screenshots/`。

## 二、阻塞缺陷（交回主任务）

### 现象

`GET /detect/workbench/dispatches/{id}/recovery-preview` 返回 HTTP 200、`code:200`，但 `data` 不是证据摘要，
而是 Jackson 2 `JsonNode` 的 bean 属性清单：

```json
{"msg":"操作成功","code":200,
 "data":{"array":false,"bigDecimal":false,"bigInteger":false,"binary":false,"boolean":false,
         "containerNode":true,"double":false,"empty":false,"float":false,"floatingPointNumber":false,
         "int":false,"integralNumber":false,"long":false,"missingNode":false,"nodeType":"OBJECT",
         "null":false,"number":false,"object":true,"pojo":false,"short":false,"textual":false,"valueNode":false},
 "requestId":"daa687a6-43f0-43f6-952c-3e8244bddeb9","managementRevision":"3007"}
```

契约要求（《设备发送结果接收与位置释放契约.md》§UNKNOWN 受控恢复）预览须返回证据摘要、样品/结果版本、原代次与可恢复类型；
实际一个字段都没到客户端。原始报文见 `browser-wire-unknown-recovery.jsonl` 第 1 行。

### 根因（已定位到文件）

- `M05UnknownRecoveryService.preview()` 返回 `com.fasterxml.jackson.databind.node.ObjectNode`
  （`futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/support/m05/M05UnknownRecoveryService.java:51`，
  导入见同文件 `:3-4`），Controller 直接 `AjaxResult.success(service.preview(id))`
  （`controller/M05UnknownRecoveryController.java:20`）。
- 本服务 HTTP 响应由 Jackson 3 序列化：全局配置 `futurefab-common/futurefab-common-core/src/main/java/com/futurefab/common/core/config/JacksonConfig.java:15-26`
  全部导入 `tools.jackson.databind.*`；产物 classpath 同时存在 `jackson-databind-2.21.2.jar` 与 `jackson-databind-3.1.2.jar`
  （`jar --list` 实测）。Jackson 3 不认识 Jackson 2 的 `JsonNode`，按普通 POJO 输出其 `isXxx()` 布尔属性。
- 全模块只用 Jackson 2 建树（`grep tools.jackson` 在 service/controller 命中 0），但 `M05UnknownRecoveryController.java:20`
  是唯一把裸 `JsonNode` 放进响应体的 Controller（`grep AjaxResult.success(.*preview` 仅命中该处），
  所以此前所有接口的响应都正常，本口是第一个踩中的。

### 影响

1. 19 条核准派发全部无法经页面确认：`recoveryWrite()` 校验 `dispatchId/sampleVersion/resultVersion/generation`
   （`futurefab-frontend/packages/app-smp-data/src/workbench/unknown-recovery.ts:13-14`）短路，报
   「未取得有效预览版本，请重新核对证据」，写请求根本不发。BGA 有结果恢复、18 条确定拒绝、
   写路径保护负向、重放/并发/回滚四类均因此无法推进；本轮只跑通了不依赖预览成功的那道闸（§三读路径核准范围）。
2. 页面判定文案会误导操作员：`WorkbenchUnknownRecovery.vue:50` 用 `preview.kind === 'SOURCE_COMPLETED_BGA'` 三元判断，
   `kind` 缺失时一律落到「设备明确拒绝，释放本次预占并保留失败历史」。截图 `03-bga-preview.png`、`04-client-failsafe-no-post.png`
   显示：对实际已完成源任务的 BGA 派发 1310973225890615296，页面写着「设备明确拒绝」，同时「样品：」为空，
   却仍可填原因并进入二次确认「确认执行恢复」。所幸客户端版本校验兜住了，未发出请求。

### 测试为什么没抓到

`M05UnknownRecoveryControllerTest`（1 用例通过）只测 POST 的双头解析，完全没覆盖 GET 预览响应体；
且它用 `MockMvcBuilders.standaloneSetup`（`:16`），消息转换器集合与 Boot 4 运行期（Jackson 3）不同，
即便补断言也证明不了真实序列化。属真实缺口，不是偶发。

### 建议的最小修法（供主任务裁决，本轮未改）

- 首选：`preview()` 改返回 `Map<String,Object>`（或一个字段固定的 DTO），Jackson 3 原生可序列化，
  字段与顺序不变，不动任何哈希与持久化路径。
- 不建议把该服务整体换成 `tools.jackson` 的 `ObjectMapper`：同文件 `:69` 的
  `payload=(ObjectNode)json.valueToTree(command)` 要进幂等回执，`NormalizedPayloadHasher` 自带 Jackson 2 树与
  规范化写法（`service/guard/NormalizedPayloadHasher.java:11-13,95-136`）；换 mapper 有改变 payload 字节进而影响
  `payload_hash` 与重放比对的风险，需单独评估。
- 修后须补一条走真实 Boot MVC（非 standalone）的预览响应体断言，防止再退。

## 三、已完成的验证

- 后端构建：`mvn -pl futurefab-modules/futurefab-system -am package -DskipTests` 第一次 `BUILD FAILURE`（jar 被持有），
  停 own PID 后第二次 `BUILD SUCCESS`（`build-backend.log`、`build-backend-2.log`）。
- 前端构建：`build:shared`、`check:shared` 通过（`build-fe-shared.log`，`BUILD_EXIT=0`）；
  `pnpm --filter @futurefab/ui-app-smp-data run type-check` `TYPECHECK_EXIT=0`（`fe-type-check.log`）、
  `run build` `BUILD_EXIT=0`（`fe-build.log`，`dist/` 重建于 16:29）。
  页面已加载 `WorkbenchUnknownRecovery` 组件（浏览器实际渲染，非静态推断）。
- 后端定向测试：`Tests run: 428, Failures: 0, Errors: 0, Skipped: 0`，`BUILD SUCCESS`（`test-backend-targeted.log`），
  含 `M05UnknownRecoveryControllerTest` 1、`M05UnknownRecoveryEvidenceTest` 2、`M05UnknownRecoveryServiceTest` 8、
  `M05UnknownRecoverySqlMappingTest` 3 全绿。
- 前端定向测试：4 文件 39 用例全通过，`PNPM_EXIT=0`（`test-frontend.log`），含 `workbench-unknown-recovery.test.ts` 2 用例。
- `ManagementOperationTest`：3 用例 1 失败 `whitelistMatchesFrozenFieldDictionaryList`（`MVN_EXIT=1`）。
  集合差集实测：枚举比冻结清单多 `M07_CULTURE_CALCULATION_CHANGE`/`M07_CULTURE_CALCULATION_DECISION` 两码
  （已登记的现行基线既有失败），`in_frozen_list_not_in_enum=[]`，`M05-DISPATCH-RECOVER` 两侧都在
  （`test-mgmt-operation-diff.txt`）。本轮未新增失败。
- 部署后基线复核：UNKNOWN 派发 29 条与改动前逐字段一致（`rows-after-restart.txt` 对 `base-unknown-rows.txt`）。
- 页面结构复核：「查询发送回执」弹窗同时呈现只读「查询原回执」区与新增「依据原证据恢复 UNKNOWN」区，
  说明文案「仅处理服务端逐条核准的派发。重复样品提示、无回包及证据不足继续保护，不会清空或重新发送。」
  与契约一致（`02-recovery-modal-top.png`）。

### 十条未核准派发的逐派发核准范围（读路径，本轮唯一还能跑通的负向）

预览口本身就会走 `approval(id)`（`M05UnknownRecoveryService.java:157-160`：配置里没有该派发就 `invalid()`），
所以在写路径被 §二缺陷卡住的情况下，仍可验证「服务端逐条核准」这道闸在真实部署里生效。

10 条未核准派发全部经页面「核对恢复证据」入口发出，全部被拒：

| 派发日志编号 | HTTP | code | msg |
| --- | --- | --- | --- |
| 1310843429185523712 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311118185268908032 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311179225847435264 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311182587657588736 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311522996774637568 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311528590332006400 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311531200799707136 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311534291813011456 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311805973672890368 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |
| 1311806388292423680 | 409 | 409 | `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED` |

对照：已核准的 BGA 派发 1310973225890615296 同一路径返回 200（响应体缺陷见 §二）。
逐条原始报文见 `preview-probe-summary.txt` 与 `browser-wire-unknown-recovery.jsonl`；页面告警可见状态见 `06-protected-dispatch-409.png`。
拒绝外壳仍带顶层 `managementRevision=3007`，符合守卫写取 revision 的口径。

取证方式说明（不冒充可信点击）：这 10 次是在页面内用脚本向「恢复派发日志编号」输入框写值并调用按钮的 `click()`
（`isTrusted=false`），请求仍走应用自身的请求客户端与真实登录态，未自签令牌、未包装 fetch、未读 cookie/令牌。
可信用户点击的证据只有 §二那条 BGA 链路（截图 02—05）。因此本组按 HTTP_VERIFIED + 页面可见告警登记，不记 BROWSER_VERIFIED。


## 四、零副作用证明

- 证据代理全程录到 13 条请求，全部是 `GET …/recovery-preview`；`grep -c POST` = 0 —— 没有任何 `/recover` 写请求到达后端。
- 点击「确认执行恢复」后页面报「未取得有效预览版本，请重新核对证据」（`05-recovery-blocked-client-error.png`），未发请求。
- 客户端中止后重跑基线计数与 29 条 UNKNOWN 明细：`counts-after-attempt.txt` 与 `base-counts.txt` 逐字节 `diff` 为空；
  `rows-after-attempt.txt` 与 `base-unknown-rows.txt` 一致。含 `receipt_m05_recover`、`audit_all`、
  `event_recovery`、`dispatch_resolved`、`sample_released` 等全部未变。
- 10 条未核准派发的读路径探测（§三）之后，第三次重跑基线计数：`counts-after-probes.txt` 与 `base-counts.txt` 仍逐字节一致。
- 未执行任何业务表 UPDATE/DELETE，未改冻结 JSON，未重启模拟服务，未清理测试数据。

## 五、分层状态

| 项 | 状态 |
| --- | --- |
| 恢复链路源码（预览/确认/回执/审计/核准范围） | IMPLEMENTED |
| 定向单元与契约测试（后端 428 / 前端 39） | CONTRACT_TESTED |
| `ManagementOperationTest` 白名单冻结清单 | 既有失败 1，非本轮引入（已给差集证据） |
| 预览接口 HTTP | HTTP_VERIFIED 且结果不合规：200 但响应体缺全部契约字段（缺陷见 §二） |
| 确认写接口 HTTP | NOT_VERIFIED —— 客户端短路，无请求发出 |
| BGA 有结果恢复（1310973225890615296） | NOT_VERIFIED（阻塞于 §二实现缺陷，非部署缺项、非客户输入缺项） |
| 18 条确定拒绝逐条恢复 | NOT_VERIFIED（同上阻塞） |
| 10 条未核准派发 —— 读路径核准范围 | HTTP_VERIFIED（10/10 返回 409 `UNKNOWN_RECOVERY_EVIDENCE_UNVERIFIED`）+ 页面告警可见；脚本触发非可信点击，不记 BROWSER_VERIFIED |
| 10 条未核准派发 —— 写路径拒绝 | NOT_VERIFIED（§二缺陷使写请求无法从页面发出） |
| 同键重放、异载荷冲突、并发与事务回滚 | NOT_VERIFIED（同上阻塞） |
| 真实设备/现场 | BLOCKED_EXTERNAL |

## 六、交回主任务的最小待办

1. 修 §二预览序列化（建议 `Map` 返回），并补一条真实 Boot MVC 下的预览响应体断言。
2. 顺带确认 `WorkbenchUnknownRecovery.vue:50` 在 `kind` 缺失时不应默认渲染「设备明确拒绝」，
   避免误导操作员（可与修口同批，或单独登记）。
3. 修复合入并重新部署后，按本轮既定顺序重跑：BGA 1 条 → 18 条确定拒绝 → 10 条保护负向 → 重放/并发/回滚。
   本轮的基线快照、核准文件、取证代理与页面入口均可直接复用。
