# M02 台式反应器 F2/F3 修复与 check-delete 口径对齐记录（2026-10-05）

## 背景

终验（见《台式反应器新旧系统盘点与验收准备-20261005.md》§9）登记的三个后续修复项 F1/F2/F3 处置收口记录。F1（前端筛选参数）已于同日以前端 commit `6bc6cb76` 修复并浏览器验收，不在本记录范围。

## 总控裁决（2026-10-05，用户当轮确认）

- **F2**：授权 work9 直接修复 M02 `DevBenchReactorMapper.xml` 单边日期条件，并补契约测试。
- **F3**：契约向 PKG-00 冻结壳对齐——`canDelete` 改为 `allowed`，`reasonCodes` 登记为契约字段；后端不改。
- **D6（删除预检 UI 接入）**：维持现状，页面删除继续走守卫 DELETE + 后端拒绝提示，预检 UI 待产品另行裁决。
- **push**：本轮本地提交不 push，等总控统一安排。

## F2 修复内容

- 文件：`futurefab-modules/futurefab-system/src/main/resources/mapper/device/DevBenchReactorMapper.xml`（`selectDevBenchReactorList`）。
- 变更：原 `<if>` 要求 `params.beginTime` 与 `params.endTime` 双端非空才拼 `update_time` 窗口（单边静默丢弃），拆为两个独立 `<if>`，逐边生效；缺边不拼该侧条件。与《型号专属筛选与内部能力读取契约》§1（beginDate/endDate 各自可单边）一致。
- 不改 `M02DeviceModelQueryReader`（缺边写 `""` 的既有行为与新 XML 兼容）、不动 `LabBenchReactorMapper.xml`（lab 侧实例列表，非本轮授权范围）。
- 测试：`M02WiredDeviceModelContractTest` 新增
  - `listDateWindowAppliesPerSideAndBoth`：单边 begin / 单边 end / 双边 / 倒置拒绝（INPUT_INVALID）四段断言，内存替身按修复后 XML 同口径逐边过滤；
  - `mapperXmlKeepsPerSideDateWindowConditions`：XML 结构守卫——单边条件必须独立存在、双端耦合条件禁止回归（项目无 DB 级测试基建，结构守卫为最低成本回归钉）。
- 验证：
  - `mvn -o -pl futurefab-modules/futurefab-system test -Dtest=M02Wired*` → 492/492 通过；
  - 9299 临时实例（`mvn -o package` 出的 jar，`--spring.cloud.nacos.discovery.enabled=false` + dev hmac 密钥，验毕即杀）HTTP 实测：无筛选 total=3；`beginDate=2026-09-20` 单边 total=2（旧码同参返回 3，被静默忽略）；`endDate=2026-09-20` 单边 total=1；双边 `2026-09-20..2026-09-30` total=1；倒置 400 `INPUT_INVALID 开始日期不能晚于结束日期`。
  - 共享 9201 为 IDE 调试进程（跑主树 target/classes），未重启；浏览器经网关 9090→9201 的单边筛选在 IDE 重载前仍走旧码，属 `BLOCKED_DEPLOY`（运行环境未重载），非代码问题。

## F3 契约对齐内容

后端 `checkDevBenchReactorDeleteAllowed` 返回 PKG-00 冻结壳 `DeletePrecheckResult{allowed, reasonCodes, referenceCount, managementRevision}`（《02-PKG-00公共契约与Port物理签名设计.md》§DeletePrecheckResult 定义，且 M02 全部型号类应用服务同壳复用），契约文档原写 `data:{canDelete,...}`。按裁决以 PKG-00 壳为准，修改以下文档（均为 M02 设备型号库 check-delete 口径，未触碰 M03 实验室子树删除预检与检测设备条目预检等其他 API 族的 `canDelete`）：

- `docs/详细设计/02-实验室与资源管理/逐接口完整契约清单.md`：MDL-B05 输出字段与预检业务体样例（样例补 `reasonCodes`）；同文件 MDL-I05/C05/W05/D05/P05/A05/N05 七个同壳姊妹类行按同一口径同步对齐（避免同文档平行口径）。
- `docs/详细设计/02-实验室与资源管理/接口目录与契约定位.md`：定位016 MDL-B05 行。
- `docs/详细设计/02-实验室与资源管理/设备型号库设计.md`：§4 矩阵 MDL-B05 行、§16 通用矩阵 05 行（标注 PKG-00 通用壳、跨模块同壳）。
- `docs/开发任务/00-全接口契约骨架清单.md`：M02-117 及 M02-118 段中 8 个型号类删除预检备注（`{allowed,reasonCodes,referenceCount,managementRevision}`）。

不改：`docs/00-开发基线/最终API基线.md`（开发基线快照，其 MDL-B05 行已注明来源为逐接口完整契约清单且括注"公共外壳DeletePrecheckResult"，基线变更走另行流程）；后端 `DeletePrecheckResult` 类与 `DevBenchReactorApplicationServiceImpl` 零改动。

## 页面消费现状（不随本轮改变）

`/settings/benchreactor-management` 删除流程不消费 check-delete（D6 维持现状裁决）；SDK `benchreactorApi` 无 check-delete 调用点。待 D6 产品裁决接入预检 UI 时，前端按对齐后口径读取 `data.allowed` / `data.reasonCodes`。

## 验证层级声明

- F2：CONTRACT_TESTED（492/492）+ HTTP_VERIFIED（9299 临时实例实测）；共享环境浏览器层为 `BLOCKED_DEPLOY`（待 IDE 重载 9201 后可浏览器复验，页面代码无需再改）。
- F3：文档存在/链接检查通过（静态）；后端行为为既有已验证事实，本轮零后端改动。
- 未 push、未执行数据库脚本、未触碰客户材料与 history 既有文件。
