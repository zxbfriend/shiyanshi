# work1：UNKNOWN 原证据受控恢复独立复测

## 本次续测先决条件：预览序列化阻塞修复

上一轮在预览200响应缺字段处中止，业务表零改动；原报告《2026-10-26-work1-UNKNOWN受控恢复独立复测-阻塞缺陷交回.md》保留，不改写原结论。本轮先构建部署最新修复：预览改为固定字段 Preview DTO，HTTP 不再返回 Jackson 2 ObjectNode；内部哈希、冻结快照及持久化使用的 Jackson 2 均不改。新增 M05UnknownRecoveryBootMvcTest 使用实际 Boot MVC/Jackson3 自动配置与 WebApplicationContext，不是 standalone，旧代码已实测因 $.data.dispatchId 缺失而失败。

先在**可见内置浏览器**对 BGA 1310973225890615296 点击“核对恢复证据”，逐一确认 data.dispatchId/sampleNo/kind/evidenceHash/sampleVersion/resultVersion/generation/approvalReference/originalEventId 及顶层 managementRevision 的真实响应。BGA 必须显示“源任务已完成”，不能显示“设备明确拒绝”；不得出现 array/object/nodeType 等树对象属性。先取消确认，证明零写，再进入下文恢复次序。

前端现在先整体校验预览和精确派发身份，只有 SOURCE_COMPLETED_BGA / DEFINITE_REJECTION 两种类型能进入展示/确认和构造写请求；缺 kind、未知 kind、空样品、缺版本/摘要、错派发均报错并继续保护，不能默认解释为拒绝。异常响应分支已有前端用例，不要为复测去包装页面 fetch 或篡改 DOM。原核准文件、十九条清单、十条保护快照和 5586 合规取证代理可复用，但先核对当前端口归属与路径过滤。

必须重建 system（方法签名已变化），记录新 jar SHA 与实际PID；遵守进程归属规则，不复用旧 b19b72f6… 包冒充新修复。重新运行 M05UnknownRecovery*Test（包含新 Boot MVC 测试）及四份前端测试。若新预览仍不合规，停止所有恢复写入并交回；禁止跳过预览从脚本直接POST。原 report 中尚未验证的写保护、重放、并发与回滚继续如实列出，不能继承为已通过。

## 任务与禁止事项

请验证本轮未提交的 UNKNOWN 恢复代码。用户已确认：先恢复一条已有完整源结果的 BGA，再处理十八条明确错误回包，其他十条继续保护；保留原文、审计、历史结果，不自动重发、不直接清空。暂不提交、推送或建 PR；发现缺陷请记录精确证据交回主任务，不混改其他任务。

本轮是实现后的首次运行验收，不能把此前只读排查、MockMvc 或单测写成已经恢复。先读 AGENTS.md、docs/README.md、01/02 入口，再读 M05《设备发送结果接收与位置释放契约》的“UNKNOWN 原证据受控恢复”、接口目录和 Controller 时序增补。核对当前 HEAD、dirty diff，尤其共享动作/审计注册表，不能只按旧 HEAD 构建。当前主任务最后核对的 HEAD 为 c9dbe0bb2，后续若变化必须重新定位受影响范围。

**严禁**：业务表 UPDATE/DELETE、清空/取消按钮代替恢复、修改派发冻结 JSON、伪造 ACK、补造历史时间核准、修改检测项/共享超时参数、重发任何原样品；不可重建模拟源任务。现有 UNKNOWN 要先完整快照。源库无任务不等于未发送，重复提示不等于确定拒绝。

## 构建与服务

主仓库：`D:\Code\zhixianweilai\yaoming-cloud`；模拟模块：`D:\Code\zhixianweilai\yaoming_shengwu\futurefab-mock-server`。使用已批准本机配置读出实际连接目标，不在文档/日志打印密码、令牌或完整凭据。不执行初始化/历史 SQL。

1. 核对 9201 system、9200 auth、9090 gateway、9080 mock、5581 门户和可选 5584 取证代理的实际 PID、命令归属与健康状态。旧报告的 PID 28644/21320 仅是历史线索。保留 auth/gateway/mock 和测试数据，**本轮不需重启模拟服务**。
2. system 若占用 jar，按 AGENTS.md 第14节先核对归属；只停止本任务有权处理的准确进程，否则取得明确授权。禁止全局结束 Java/Node。
3. Java/Maven 工具路径先核实。本机此前使用 JAVA_HOME `D:/Programs/dragonwell-21.0.10.0.10+7-GA`、Maven `D:/Programs/Maven/bin/mvn.cmd`。构建：

```powershell
& D:/Programs/Maven/bin/mvn.cmd -pl futurefab-modules/futurefab-system -am package '-DskipTests'
```

`-DskipTests` 只证明构建，不证明测试。记录原进程退出码、jar SHA-256/mtime、启动 PID 与 HEAD/diff 身份。

4. 已准备本机启动入口：`.local-start-tools/ht-isolated-qa/restart-second-id-system.ps1`，保留现有六型号数据源/采集/接受投影配置。新增参数仅把精确核准范围注入该 system 进程，不发布 Nacos：

```powershell
# 确认旧进程已按归属规则停止、9201空闲，并且本次新源码已构建成功后：
& .local-start-tools/ht-isolated-qa/restart-second-id-system.ps1 -SkipStop `
  -UnknownRecoveryApprovalFile .local-start-tools/unknown-recovery-approvals.json
```

核准文件是忽略目录内的本机文件，恰十九个派发 ID，值为 `QA-MOCK-USER-20261026-UNKNOWN-RECOVERY`。对应配置形态：`futurefab.m05.unknown-recovery.dispatches.<logId>.approval-reference`。没有该逐派发登记时入口失败关闭。该引用表示本轮用户对 QA 证据的授权，不代表真实设备厂商核准；不可扩大到其他派发。

若本机辅助文件不在，按现有已批准启动方式保留全部原配置，只增加上述十九项；不要编造数据源或将源库回退到 master。

5. 前端在 `futurefab-frontend/` 下使用 pnpm 8.6.2。已有依赖无需重装。先 `pnpm run build:shared`、`pnpm run check:shared`，再 `pnpm --filter @futurefab/ui-app-smp-data run type-check` 和 `run build`。保留当前门户 active backendUrl 指向本机网关，确认实际加载了包含 WorkbenchUnknownRecovery 的新 data 产物。需要启门户时按 `docs/开发基线/本机启动.md`，不要启动已删除的 futurefab-ui。

## 浏览器与请求证据要求

使用**可见的内置浏览器**，登录现有门户，打开检测分析页面。先确认面板可见并取得一张实际截图；若 hidden / NATIVE_BROWSER_VIEWPORT_UNAVAILABLE，停止依赖可见操作的步骤，明确记 NOT_VERIFIED，不以 DOM 或 HTTP 代替。不要读取 sessionStorage/cookie/令牌，不包装 fetch，不用脚本登录关闭验证码；验证码如需处理，遵守浏览器规则。

通过现有“查询发送回执”窗口，下方新区域“依据原证据恢复 UNKNOWN”操作：输入派发日志编号→“核对恢复证据”→查看样品/判定→填写恢复原因→“确认恢复”→再次“确认执行恢复”。原“查询原回执”按钮仍必须只读。

GET `/dev-api/detect/workbench/dispatches/{logId}/recovery-preview` 返回 data 及**顶层 managementRevision**，预览不能增加版本、审计、事件、源订单或派发。POST `/dev-api/detect/workbench/dispatches/{logId}/recover` 必须由页面实际发出：

- `X-Request-Id`：新恢复动作的 UUID，与原设备调用 ID 不同；结果未知只沿用此 UUID。
- `X-Management-Revision`：取本次恢复预览顶层版本，不硬编码、不借其他模块。
- `X-M05-Contract-Version: 2`。
- Body 只有 `evidenceHash/sampleVersion/resultVersion/generation/reason`；不携带成功结论、测量值、源地址或操作者。

用公开网络工具或合规被动代理保存 method、URL、这三个头、脱敏载荷、状态与响应。不要记录 Authorization/Cookie。旧 5584 代理可能只过滤 sample 写请求，必须先核对是否捕获新的 dispatches 读写路径；未捕获就用公开 DevTools，不能取令牌自行 fetch 冒充点击证据。

## 测试数据：先 BGA，后十八条拒绝

只读排查时十九条均为样品版本2、结果版本1；**操作时重新预览取值，不沿用本表硬编码版本**。

| 顺序/分组 | 样品 | 派发日志 ID |
| --- | --- | --- |
| BGA，必须先做 | QA-CDP-N-FORMAL1 | 1310973225890615296 |
| 旧HT ZA1/07 | QA-CDP-W-ZA1-9N2507 | 1311522957352374272 |
| 旧HT ZA1/08 | QA-CDP-W-ZA1-9N2508 | 1311522979351498752 |
| 旧HT ZA1/10 | QA-CDP-W-ZA1-9N2510 | 1311523017196703744 |
| 旧HT ZL1/07 | QA-CDP-W-ZL1-9N2507 | 1311528550167351296 |
| 旧HT ZL1/08 | QA-CDP-W-ZL1-9N2508 | 1311528569373069312 |
| 旧HT ZL1/10 | QA-CDP-W-ZL1-9N2510 | 1311528610343030784 |
| 旧HT ZM1/07 | QA-CDP-W-ZM1-9N2507 | 1311531156805652480 |
| 旧HT ZM1/08 | QA-CDP-W-ZM1-9N2508 | 1311531178003664896 |
| 旧HT ZM1/10 | QA-CDP-W-ZM1-9N2510 | 1311531226171052032 |
| 旧HT ZN1/07 | QA-CDP-W-ZN1-9N2507 | 1311534240193712128 |
| 旧HT ZN1/08 | QA-CDP-W-ZN1-9N2508 | 1311534267838369792 |
| 旧HT ZN1/10 | QA-CDP-W-ZN1-9N2510 | 1311534316139974656 |
| 隔离HT A/07 | QA-CDP-W1Q8A07X | 1311805972251021312 |
| 隔离HT A/08 | QA-CDP-W1Q8A08X | 1311805972896944128 |
| 隔离HT A/10 | QA-CDP-W1Q8A10X | 1311805974427865088 |
| 隔离HT B/07 | QA-CDP-W1Q8B07X | 1311806386581147648 |
| 隔离HT B/08 | QA-CDP-W1Q8B08X | 1311806387436785664 |
| 隔离HT B/10 | QA-CDP-W1Q8B10X | 1311806389047398400 |

### A. BGA 有结果恢复

设备 QA-BGA-FORMAL-N-20261023，detectorId `1310966934325563392`，子设备41105；样品 `1310973225752203264`，结果 `1310973225890615297`，位置1-1、代次2。源任务 `cdp_testing_bgatask.TestingBGATaskID=4`，设备41105、样品精确相同，Status=7、未删除，pH=7.38/单位“无”，另有未配置 DO=98.1/%。

1. 保存原派发 error、冻结快照、样品/结果/事件/版本、源订单/任务/测量及原始 hash 快照。
2. 页面预览应得到 SOURCE_COMPLETED_BGA；取消一次不写入；再确认恢复并抓完整请求。
3. 恢复事件必须是新追加，payload_meta.source=CONTROLLED_RECOVERY、evidenceKind=CDP_COMPLETED_SOURCE_SNAPSHOT，包含当前操作者、理由、核准引用和证据摘要。原通信异常不抹除，不能生成伪造旧 ACK。
4. 原 dispatch 转 RESOLVED/accepted；既有受理投影将原样品/结果从 RESERVED/pending 推进，正式采集将 pH 写入**原 resultId**；代次不变、不新增订单/派发/结果身份。DO 未配置，不得进入正式项或原生结果展示区。
5. 全项完整和可信源完成按现行 LIST/POSITION/无遮挡规则处理为 COMPLETED；位置行保留历史语义，不调用清空。若仍 pending/OPEN，检查接受事件和正式采集日志，不能手工改状态或直接宣称通过。
6. 原冻结无 timeContext：完成时间保持未核验，testing_end_time 不补造；不能用当前UTC配置或恢复时刻冒充源完成时间。loadedAt 只能表示本系统恢复核验时刻，不能表示设备实际开始。该旧样品未关联培养，不要求制造自动上传。
7. 同恢复 requestId+原载荷重放应返回原回执，零新增恢复事件/审计/管理版本/设备命令；不同载荷同键409。必须先保留原请求，不能在已恢复后用新键假装重放。

### B. 十八条确定拒绝

旧 HT detectorId `1311090742852194304`/子设备41126；隔离 HT `1311692613891526656`/子设备41127。

本轮核准三种原文：

```text
send_orders|0100000000000007|CedexMissingDevice
send_orders|0100000000000008|CedexSubSystemOrdersError
send_orders|0100000000000007|CedexNotRunning
```

逐条预览与确认，核对原事件 ID/raw_hash/raw_payload/normalized_payload 保持不变，新恢复事件 related_event_id 指向原事件，evidenceKind=ORIGINAL_NATIVE_RESPONSE。原回包收件时绑定 acceptance=NOT_ATTEMPTED、当前派发 UNKNOWN 是正常顺序差异，**其他冻结绑定/项目/代次必须完全一致**。

期待：dispatch RESOLVED/rejected、该样品原代次 RESERVED→RELEASED、样品版本恰+1；clear_flag/del_flag 不变，不删除样品/结果/正式历史项。结果追加未执行终态 source_progress.dispatchRejection、collection_state=CLOSED_EXCEPTION 和新版本，原 pending 业务值不伪装成检测完成、已上传或签批；原管理守卫审计标题“检测工作台/未知派发恢复”。既有 RECEIVED 错误包不得覆盖成 ACCEPTED。

每条确认前版本均须重新取；后台可能推进 SYSTEM，遇409重新读真实状态。整列仍有其他 UNKNOWN 时列保护保持，不得以释放其中三条为由清空该列。源订单/任务和派发数量均不能因恢复增加。

## 必须保持保护的十条

- QA-CDP-N-BGA1：logId 1310843429185523712，无回包无源任务。
- QA-CDP-R-BGAX9：1311118185268908032，BGASampleSended 重复提示。
- QA-CDP-L-H41-9N2305：1311179225847435264，无回包无源任务。
- QA-CDP-N-H502-9N2305：1311182587657588736，无回包无源任务。
- QA-CDP-W-ZA1-9N2509：1311522996774637568。
- QA-CDP-W-ZL1-9N2509：1311528590332006400。
- QA-CDP-W-ZM1-9N2509：1311531200799707136。
- QA-CDP-W-ZN1-9N2509：1311534291813011456。
- QA-CDP-W1Q8A09X：1311805973672890368。
- QA-CDP-W1Q8B09X：1311806388292423680。

最后六条是重复样品相关回包。这十条不在批准文件中，预览应拒绝；不要为测试临时加批准或修改配置。前后比较完整样品行、原结果、原事件hash、派发绑定与代次，必须一致。通过合法页面写路径验证该列仍受保护；若原页面禁用，记录 UI 拒绝，后端负向另用合规工具并明确 HTTP_VERIFIED，不篡改DOM启用按钮，不读取令牌。

若初始基线仍29条且无人并行操作，成功处理19条后应余10条 UNKNOWN；统计仅作辅助，必须按清单逐条核对。基线变化时停止扩大范围并报告真实差异。

## 失败、权限、并发和回滚

- 缺/非法管理版本、非法requestId的400；缺M05契约2的升级拒绝；Body不能覆盖Header。缺requestId由公共过滤器生成，不应误报缺任一头都400，页面仍必须主动携带双头。
- 过期样品/结果版本、代次、证据hash、配置修订或管理版本拒绝，不新增证据、版本、审计或源任务。
- 无编辑权限/无实验室范围/无培养读取范围拒绝；缺相应测试账号记BLOCKED_INPUT，不伪称已验证。
- 多任务、源身份冲突、源已删除、拒绝包但已有源任务、非精确错误包保持UNKNOWN。这些分支先用契约测试；没有正式夹具不得改业务表构造。
- 新恢复事件、派发变更、拒绝占位与结果版本、审计和回执在同一个守卫事务；失败不得半提交。已有BGA后续投影可以独立重试，不因此再发命令。
- 新功能不依赖 NamedPipeClient/派发执行器，观察 mock 无新的 sendOrder/send_orders。不要把后台只读轮询当成重发。
- 保留原键重放，两个不同恢复键并发最多一次成功，另一条状态/版本冲突；无双事件、双审计和双释放。不得以人工作废或取消替代该测试。

## 测试命令与已知基线

```powershell
mvn -pl futurefab-modules/futurefab-system -am test '-Dtest=M05UnknownRecovery*Test,M05*Dispatch*Test,M05Acceptance*Test,M05Cdp*Test,M05Bga*Test,Bga*Test,DetectionTimeout*Test,AuditPolicyRegistryTest' '-Dsurefire.failIfNoSpecifiedTests=false'
# 前端工作区内
pnpm run test:unit tests/workbench-unknown-recovery.test.ts tests/workbench-send-recovery.test.ts tests/detection-workbench-ui.test.ts tests/m05-workbench-guarded-write.test.ts
```

记录实际匹配类/例数和 Maven/pnpm 原始退出码。ManagementOperationTest 在当前远程基线有一项既有失败，精确差异为 M07_CULTURE_CALCULATION_CHANGE / M07_CULTURE_CALCULATION_DECISION 两码未进入其期望集合；本轮只增加 M05-DISPATCH-RECOVER 的期望，不改那两码。若 HEAD 已修复则按实际结论更新，不能继续引用旧失败，也不能借此忽略新增失败。

## 交付

原始截图、请求和SQL证据放忽略目录 `.local-start-tools/unknown-recovery-work1/`；验证报告放本目录 history/review，写明部署身份、19条逐条结果、剩余十条快照、原始hash与审计/版本对照、源任务与命令零新增、测试退出码、所有 NOT_VERIFIED/BLOCKED 项。截图必须能看到样品/设备/状态；完成时间未核验要如实呈现。

最终分层报告 IMPLEMENTED / CONTRACT_TESTED / HTTP_VERIFIED / BROWSER_VERIFIED，真实设备与现场仍 BLOCKED_EXTERNAL。未部署、未点击的状态变更必须 NOT_VERIFIED，不能只凭“接口200”或计数从29降到10宣称验收通过。未清理测试数据，保留历史与剩余保护。暂不提交、推送、建PR。
