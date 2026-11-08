# 32-BLOCKED 设计裁决清单

> 生成时间 2026-09-20 ｜ 由 `_tmp_skelgen/gen/gen32.js（编号/路由/原因同源派生并与 31 报告交叉验证；裁决问题/动作为人工登记内容；改源后重跑本脚本）` 同源派生（编号/路由/权限/原因不可手改；裁决问题与补骨架动作为登记内容，改源后重跑脚本）。

## 1. 口径

- 共 **17 条** BLOCKED_REGISTERED：M02×2、M04×7、M05×6、M07×2。
- **全部且仅分配至「设计裁决阻塞包」**（`dev_package_eligible=false`）：不进入第9步任何业务开发任务包；裁决前不得落码、不得发明字段/枚举/路由、不得伪成功。
- 编号集合与 31 号合并定稿审计报告 `blockedCheck.expected` 完全一致（生成脚本交叉断言，不一致即拒绝产出）。
- 全局唯一键=`interface_id`；`contract_id` 仅模块内唯一，禁止作为全局标识（M01↔M09 API01–API12 重名 12 组为 00 冻结清单既有事实）。
- 锚点：456（非M01冻结）= 439（骨架条目）+ 17（本清单）；与 `26-...json` blockers[]、`port-closure-anchor.json` blockedIds 三方一致。

## 2. 逐条裁决登记

### M02-003（M02 / NEW）

- **路由**：`GET /lab/observations/{observationId}`
- **Controller**：`LabObservationController#getObservation`　**权限**：lab:observation:query＋设备/发生时实验室范围
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_FIELD
- **blocked 原因（登记原文）**：BLOCKED_FIELD: OBS-Q03响应另含『有权处理/关联版本索引』（在线业务观测存储与查询契约.md §4 OBS-Q03行），该索引的字段名与结构未逐项冻结，本条仅收口ObservationView主体
- **当前为什么不能分给业务开发**：请求/响应叶子字段未逐项冻结：26 清单中该契约 skeleton_impl=null、gate_resource=null，无任何门禁条目可承接开发验收；若强行分配开发包，开发者只能猜测契约形状，产出的将不是冻结契约的实现而是新发明，且无法通过 501→真实契约测试的逐个替换门禁。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：OBS-Q03 响应中『有权处理/关联版本索引』的字段名与结构需逐项冻结（在线业务观测存储与查询契约.md §4）。
- **裁决后补骨架动作**：设计冻结索引形状 → 更新 spec/m02_obs.json 移除 blocked → node _tmp_skelgen/gen/testgen.js M02 → 重跑 node _tmp_skelgen/gen/genAnchor.js → node _tmp_skelgen/gen/gen26.js → M02 wrapper 全绿 + 全量套件。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M02-004（M02 / NEW）

- **路由**：`GET /lab/observation-receipts`
- **Controller**：`LabObservationController#queryReceipts`　**权限**：lab:observation:maintain＋设备管理范围
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_FIELD
- **blocked 原因（登记原文）**：BLOCKED_FIELD: OBS-Q04行结构（隔离/冲突脱敏摘要）在《在线业务观测存储与查询契约.md》§4仅给语义与禁输出约束，未冻结字段清单；OBS-02增量DDL的receipt/conflict列为内部事实，按约定第9条不得直接外发
- **当前为什么不能分给业务开发**：请求/响应叶子字段未逐项冻结：26 清单中该契约 skeleton_impl=null、gate_resource=null，无任何门禁条目可承接开发验收；若强行分配开发包，开发者只能猜测契约形状，产出的将不是冻结契约的实现而是新发明，且无法通过 501→真实契约测试的逐个替换门禁。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：OBS-Q04 行结构（隔离/冲突脱敏摘要）需冻结字段清单；receipt/conflict 内部列按约定第9条不外发，需给出对外投影形状。
- **裁决后补骨架动作**：同 M02-003（源文件 spec/m02_obs.json，M02 再生链）。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M04-017（M04 / ADJUST）

- **路由**：`GET /system/process/workflow/list`
- **Controller**：`WorkflowController#list`　**权限**：process:workflow:list
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：ROUTE_AND_FIELD
- **blocked 原因（登记原文）**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）不一致，且 WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状未逐项冻结（批次二报告登记）
- **当前为什么不能分给业务开发**：canonical 路由前缀口径与响应形状双双未定：入口路径无法冻结意味着 Controller 映射、MockMvc 501 信封、前端 api 路径三端都无锚可依；分配开发包将直接产生路由漂移与伪接线风险。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）的口径需裁决（网关 StripPrefix 与否）；WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状需逐项冻结。
- **裁决后补骨架动作**：设计冻结路由前缀与三个 VO 形状 → 更新 spec/m04_all.json 与 brief 路由 → node _tmp_skelgen/gen/testgen.js M04（或 regen-batch-b.sh 全量再生）→ node _tmp_skelgen/gen/genAnchor.js → gen26.js → 门禁回归。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M04-018（M04 / ADJUST）

- **路由**：`GET /system/process/workflow/{nodeId}`
- **Controller**：`WorkflowController#getInfo`　**权限**：process:workflow:query
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：ROUTE_AND_FIELD
- **blocked 原因（登记原文）**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）不一致，且 WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状未逐项冻结（批次二报告登记）
- **当前为什么不能分给业务开发**：canonical 路由前缀口径与响应形状双双未定：入口路径无法冻结意味着 Controller 映射、MockMvc 501 信封、前端 api 路径三端都无锚可依；分配开发包将直接产生路由漂移与伪接线风险。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：同 M04-017（路由前缀口径 + WorkflowNodeDetailVo 形状）。
- **裁决后补骨架动作**：同 M04-017。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M04-019（M04 / ADJUST）

- **路由**：`PUT /system/process/workflow/{nodeId}`
- **Controller**：`WorkflowController#update`　**权限**：process:workflow:edit
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：ROUTE_AND_FIELD
- **blocked 原因（登记原文）**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）不一致，且 WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状未逐项冻结（批次二报告登记）
- **当前为什么不能分给业务开发**：canonical 路由前缀口径与响应形状双双未定：入口路径无法冻结意味着 Controller 映射、MockMvc 501 信封、前端 api 路径三端都无锚可依；分配开发包将直接产生路由漂移与伪接线风险。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：同 M04-017（路由前缀口径 + 更新命令形状）。
- **裁决后补骨架动作**：同 M04-017。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M04-020（M04 / ADJUST）

- **路由**：`PUT /system/process/workflow/{nodeId}/status`
- **Controller**：`WorkflowController#updateStatus`　**权限**：process:workflow:edit（不套用模板changeStatus功能码）
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：ROUTE_AND_FIELD
- **blocked 原因（登记原文）**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）不一致，且 WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状未逐项冻结（批次二报告登记）
- **当前为什么不能分给业务开发**：canonical 路由前缀口径与响应形状双双未定：入口路径无法冻结意味着 Controller 映射、MockMvc 501 信封、前端 api 路径三端都无锚可依；分配开发包将直接产生路由漂移与伪接线风险。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：同 M04-017（路由前缀口径；状态变更命令与错误码 REGISTERED 差异见 00 清单 issues）。
- **裁决后补骨架动作**：同 M04-017。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M04-021（M04 / ADJUST）

- **路由**：`GET /system/lab/lab/{labId}/workflows`
- **Controller**：`LabWorkflowController#getWorkflows`　**权限**：lab:lab:query（且实验室可见）
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：ROUTE_AND_FIELD
- **blocked 原因（登记原文）**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）不一致，且 WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状未逐项冻结（批次二报告登记）
- **当前为什么不能分给业务开发**：canonical 路由前缀口径与响应形状双双未定：入口路径无法冻结意味着 Controller 映射、MockMvc 501 信封、前端 api 路径三端都无锚可依；分配开发包将直接产生路由漂移与伪接线风险。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：同 M04-017（/system/lab/lab 前缀口径 + LabWorkflowConfigVo 形状）。
- **裁决后补骨架动作**：同 M04-017。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M04-022（M04 / ADJUST）

- **路由**：`PUT /system/lab/lab/{labId}/workflows`
- **Controller**：`LabWorkflowController#saveWorkflows`　**权限**：lab:lab:edit（且管理等级2；Q12模板等级1不适用此处）
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：ROUTE_AND_FIELD
- **blocked 原因（登记原文）**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）不一致，且 WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状未逐项冻结（批次二报告登记）
- **当前为什么不能分给业务开发**：canonical 路由前缀口径与响应形状双双未定：入口路径无法冻结意味着 Controller 映射、MockMvc 501 信封、前端 api 路径三端都无锚可依；分配开发包将直接产生路由漂移与伪接线风险。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：同 M04-021（保存实验室工作流配置形状）。
- **裁决后补骨架动作**：同 M04-017。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M04-023（M04 / NEW）

- **路由**：`POST /system/lab/lab/{labId}/workflows/clear`
- **Controller**：`LabWorkflowController#clearWorkflows`　**权限**：lab:lab:edit（且管理等级2）
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：ROUTE_AND_FIELD
- **blocked 原因（登记原文）**：canonical 路由带 /system 服务前缀与冻结 Controller 前缀（/process/workflow、/lab/lab）不一致，且 WorkflowNodeListVo/WorkflowNodeDetailVo/LabWorkflowConfigVo 形状未逐项冻结（批次二报告登记）
- **当前为什么不能分给业务开发**：canonical 路由前缀口径与响应形状双双未定：入口路径无法冻结意味着 Controller 映射、MockMvc 501 信封、前端 api 路径三端都无锚可依；分配开发包将直接产生路由漂移与伪接线风险。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：同 M04-021（clear 命令响应形状）。
- **裁决后补骨架动作**：同 M04-017。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M05-006（M05 / ADJUST）

- **路由**：`GET /detect/workbench/queue`
- **Controller**：`DetWorkbenchController#queue`　**权限**：detect:workbench:query
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_FIELD
- **blocked 原因（登记原文）**：BLOCKED_FIELD: columns与displayRows的叶子字段未在设计文档冻结（检测工作台接口与位置生命周期.md§4只给出键名与占用可见性规则），实现前需补充列/行结构定义
- **当前为什么不能分给业务开发**：请求/响应叶子字段未逐项冻结：26 清单中该契约 skeleton_impl=null、gate_resource=null，无任何门禁条目可承接开发验收；若强行分配开发包，开发者只能猜测契约形状，产出的将不是冻结契约的实现而是新发明，且无法通过 501→真实契约测试的逐个替换门禁。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：工作台队列 columns 与 displayRows 的叶子字段需冻结（检测工作台接口与位置生命周期.md §4 仅有键名与占用可见性规则）。
- **裁决后补骨架动作**：设计冻结列/行结构 → spec/m05_all.json 去 blocked → testgen M05 → node _tmp_skelgen/gen/genAnchor.js → gen26.js → 回归。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M05-024（M05 / ADJUST）

- **路由**：`PUT /detect/workbench/result/{resultId}/exception`
- **Controller**：`DetWorkbenchController#markException`　**权限**：detect:workbench:edit（送检本人）
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_FIELD
- **blocked 原因（登记原文）**：BLOCKED_FIELD: exceptionType取值域未在设计文档枚举（检测记录与结果操作设计§2仅事实'保存异常类型及说明'），骨架按String保留，实现前需字典核准
- **当前为什么不能分给业务开发**：请求/响应叶子字段未逐项冻结：26 清单中该契约 skeleton_impl=null、gate_resource=null，无任何门禁条目可承接开发验收；若强行分配开发包，开发者只能猜测契约形状，产出的将不是冻结契约的实现而是新发明，且无法通过 501→真实契约测试的逐个替换门禁。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：exceptionType 取值域需字典核准（当前骨架以 String 承载，不得发明枚举）。
- **裁决后补骨架动作**：取值域冻结后按 enum/String 决定落码形状 → 同 M05-006 链。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M05-035（M05 / COMPAT）

- **路由**：`POST /detect/sign-console/print`
- **Controller**：`DetSignConsoleController#print`　**权限**：detect:sign:export
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_COMPAT
- **blocked 原因（登记原文）**：BLOCKED_COMPAT: COMPAT入口设计仅规定转DetReportJobApplicationService#submitReportJob，旧/sign-console/print请求体到新命令（purpose/scope/confirmationToken）的逐字段映射未冻结
- **当前为什么不能分给业务开发**：COMPAT 旧入口到新命令的逐字段映射未冻结：请求体契约无法落码，旧请求形态到新契约的转换规则属设计裁决而非开发决策；不得由开发侧默认透传或发明白名单。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：COMPAT 旧 /sign-console/print 请求体到新命令（purpose/scope/confirmationToken）的逐字段映射需冻结。
- **裁决后补骨架动作**：设计冻结映射表 → spec/m05_all.json 去 blocked 并补 RequestCommand 形状 → 同 M05-006 链。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M05-036（M05 / COMPAT）

- **路由**：`POST /detect/sign-console/export`
- **Controller**：`DetSignConsoleController#export`　**权限**：detect:sign:export
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_COMPAT
- **blocked 原因（登记原文）**：BLOCKED_COMPAT: 现状export按cultureId空值选模式、读当前字典建列，需改为显式CULTURE/DATE与固定附件映射；旧请求体到新命令的逐字段映射未冻结
- **当前为什么不能分给业务开发**：COMPAT 旧入口到新命令的逐字段映射未冻结：请求体契约无法落码，旧请求形态到新契约的转换规则属设计裁决而非开发决策；不得由开发侧默认透传或发明白名单。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：旧 export 隐式模式（cultureId 空值选模式、读当前字典建列）到新显式 CULTURE/DATE + 固定附件映射的请求体字段需冻结。
- **裁决后补骨架动作**：同 M05-035。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M05-037（M05 / COMPAT）

- **路由**：`POST /detect/workbench/result/{resultId}/print`
- **Controller**：`DetWorkbenchController#print`　**权限**：detect:workbench:edit（工作台明确选择打印机才用PRINT）
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_COMPAT
- **blocked 原因（登记原文）**：BLOCKED_COMPAT: 现状recordWorkbenchPrint仅登记客户端提供文件信息属整改项；旧请求体（不得含fileName/filePath）到新命令字段的映射白名单未逐项冻结
- **当前为什么不能分给业务开发**：COMPAT 旧入口到新命令的逐字段映射未冻结：请求体契约无法落码，旧请求形态到新契约的转换规则属设计裁决而非开发决策；不得由开发侧默认透传或发明白名单。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：工作台打印旧请求体（不得含 fileName/filePath）到新命令字段的映射白名单需逐项冻结。
- **裁决后补骨架动作**：同 M05-035。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M05-064（M05 / ADJUST）

- **路由**：`GET /detect/audit-log/page`
- **Controller**：`DetApprovalRecordController#auditLogPage`　**权限**：detect:auditLog:query
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_FIELD
- **blocked 原因（登记原文）**：BLOCKED_FIELD: 全局审计日志查询的过滤叶子未逐项冻结（详细设计§12仅给出记录页过滤，全局日志页仅冻结必须有对象范围与分页），待文档补充
- **当前为什么不能分给业务开发**：请求/响应叶子字段未逐项冻结：26 清单中该契约 skeleton_impl=null、gate_resource=null，无任何门禁条目可承接开发验收；若强行分配开发包，开发者只能猜测契约形状，产出的将不是冻结契约的实现而是新发明，且无法通过 501→真实契约测试的逐个替换门禁。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：全局审计日志分页查询的过滤叶子未逐项冻结（详细设计 §12 仅冻结"必须有对象范围与分页"）。
- **裁决后补骨架动作**：设计补充过滤字段清单 → 同 M05-006 链。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M07-003（M07 / NEW）

- **路由**：`GET /run/task-candidates/resources`
- **Controller**：`RunTaskController#listTaskCandidateResources`　**权限**：run:task:add
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_FIELD
- **blocked 原因（登记原文）**：BLOCKED_FIELD: TaskCandidateResourceView『可新建培养及泵』候选结构在权威文档无字段级枚举（任务页面与接口契约§3仅散文一行；物理接口设计§3 Mapper=NOT_APPLICABLE，候选来自M02/M03 Port且输出叶子未定义），不得发明培养/泵候选行字段
- **当前为什么不能分给业务开发**：请求/响应叶子字段未逐项冻结：26 清单中该契约 skeleton_impl=null、gate_resource=null，无任何门禁条目可承接开发验收；若强行分配开发包，开发者只能猜测契约形状，产出的将不是冻结契约的实现而是新发明，且无法通过 501→真实契约测试的逐个替换门禁。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：TaskCandidateResourceView『可新建培养及泵』候选行字段需冻结（任务页面与接口契约 §3 仅散文；候选来自 M02/M03 Port，输出叶子未定义，不得发明）。
- **裁决后补骨架动作**：设计冻结候选行字段（与 M02/M03 Port 模型对齐）→ spec/m07_all.json 去 blocked → testgen M07 → node _tmp_skelgen/gen/genAnchor.js → gen26.js → 回归。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

### M07-016（M07 / NEW）

- **路由**：`POST /run/cultures/{id}/withdrawals`
- **Controller**：`RunCultureController#appendWithdrawal`　**权限**：run:balance:append
- **skeleton_status**：BLOCKED_REGISTERED　**类型**：BLOCKED_FIELD
- **blocked 原因（登记原文）**：BLOCKED_FIELD: CultureWithdrawalResult回执字段在契约中未逐字段枚举（任务页面与接口契约§3仅『→追加账』，计量契约§5只定义ledger派生），回执形状待收口
- **当前为什么不能分给业务开发**：请求/响应叶子字段未逐项冻结：26 清单中该契约 skeleton_impl=null、gate_resource=null，无任何门禁条目可承接开发验收；若强行分配开发包，开发者只能猜测契约形状，产出的将不是冻结契约的实现而是新发明，且无法通过 501→真实契约测试的逐个替换门禁。
- **进入业务开发包**：否（一律隔离到设计裁决阻塞包）
- **需要设计侧裁决的问题**：CultureWithdrawalResult 回执字段需逐字段冻结（任务页面与接口契约 §3 仅『→追加账』；计量契约 §5 只定义 ledger 派生）。
- **裁决后补骨架动作**：同 M07-003。
- **裁决后需同步重算的锚点**：
  - docs/开发任务/26-全系统接口契约骨架清单.json/.md：裁决去 blocked 后 `node _tmp_skelgen/gen/gen26.js` 重算（总数 532 不变，BLOCKED_REGISTERED 与 SKELETON_IN_SOURCE 计数及 blockers[] 联动变化）。
  - futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-m0X.json：该模块 `node _tmp_skelgen/gen/testgen.js M0X` 重算，门禁条目数（当前合计 439）随裁决增加。
  - futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json：`node _tmp_skelgen/gen/genAnchor.js` 重算，frozenNonM01Total=456 / blockedTotal=17 / gateEntriesExpected=439 三锚点随裁决数变化（456 恒等式=439+17 必须保持）。

## 3. 裁决流程约定

1. 设计侧对每条"需要裁决的问题"给出冻结结论（写入对应权威设计文档/契约，不以口头或本清单为准）。
2. 更新 `_tmp_skelgen/spec/<group>.json` 移除对应 `blocked`（必要时同步 brief 路由），重跑该模块 `testgen`、`node _tmp_skelgen/gen/genAnchor.js` 与 `node _tmp_skelgen/gen/gen26.js`——三处锚点（26 清单 / skeleton-m0X.json / port-closure-anchor.json）必须同源重算，439 随裁决数变化。
3. 门禁全绿（该模块 wrapper + FullSystemSkeletonGateTest + 全量套件）后，该条从本清单消失、在 26 清单转为 SKELETON_IN_SOURCE，方可进入开发任务包。
4. 未走完 1—3 的条目一律保持 BLOCKED_REGISTERED 隔离。
