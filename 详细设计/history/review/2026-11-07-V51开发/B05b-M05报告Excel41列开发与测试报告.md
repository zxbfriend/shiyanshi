# B05b：F30 M05报告Excel41列开发与测试

日期：2026-11-07。本批由主代理在F31之后正式授权，范围为真实报告作业Renderer、Writer用途版本门禁及独立针对测试。无提交、推送、PR、数据库/HTTP/浏览器/设备操作，无客户附件、运行release、签名密钥或配置修改。

## 1. 依据与真实链

现行《签批记录与报告导出设计》第3节及实施段约L147—170明确新Excel A:AO共41列：BGA D:J/K:N、Cedex O:W/X:AA、OSMO AB:AC/AD:AG、Vi-Cell AH:AK/AL:AO分别为设备指标/自身四项签审。回读原生134约L399—411（每类检测各有签审）、105约L949—959（按上样日期），133原场景约L415—425已撤销，不额外创造跨日配对或停止规则。

真实链为 `DetReportJobController` → `DetReportJobApplicationServiceImpl` → `M05ReportJobWriter` → `M05ReportRenderer`。旧 `DetSignConsoleExportWorkbookBuilder` 没有该生产消费者，本批没有以修改孤立Builder替代真实接线。

## 2. 修改文件与行为

| 文件 | 实际行为 |
| --- | --- |
| M05ReportRenderer.java | 新增冻结版本 `M05-POI-4.1.2-V2` 及独立41列渲染；旧V1 excel方法保留。V2三行表头/逻辑41列宽、四组Code与签审位置校验，指标只许自身组指标列，不能覆盖设备/签审；来源不符拒绝而非猜列 |
| 同Renderer V2 | 每条结果独立一行，不合并重测/未配对数据；设备Code取本结果快照，签审只写本结果检测组；标识、指标、Code、签审批注含自身来源，指标另带实际resultItemId及固定profileHash，unitMappingVersion仅取真实unitPolicy.version（原单位字符串映射留空，不补常量）。不用actionId充当人名 |
| 同Renderer V2 | 复用可信loadedAt→上海日期，缺证据独立“日期待核验”；保留全部培养/日期sheet及长名冲突稳定后缀、完整标题、操作记录与更正附录；未知完成时间不倒填上样日期 |
| 同Renderer V2 | 复用精度与单位规则：超过15位有效数字写文本，负数正常数值，公式形态编号/文本写字符串；不计算Excel公式或推断单位 |
| M05ReportJobWriter.java | XLSX用途同时允许冻结V1/V2，PDF沿既有PDF版本；用途版本不匹配仍拒绝，不增加Profile发布或升级机制 |
| M05V51ExcelReportTest.java | 独立合成三行41列fixture验证真实Renderer与Writer；不是客户原件或核准发布证据。既有M05ReportArtifactPipelineTest旧V1未改造成V2 |
| 现行签批记录与报告导出设计.md | 仅补版本接线与证据边界实施说明，不更改业务原规则或客户原件 |

## 3. TDD与实际结果

Java只由主代理统一Maven执行，本代理未启动Maven。RED9原进程exit 1，统一324测9失败11错误（含其他批次）。本类6例实际1失败4错误：四个V2正向渲染均被旧Renderer真实拒绝，Writer拒绝V2；负向模板拒绝例通过。取得该结果后才修改两个生产文件。

6例覆盖四类各自Code/指标/签审与批注；同类型重测分行、>15位精度、负数、公式形态编号；可信上样/完成跨上海午夜及缺日期；全部sheet/长名冲突/日志；缺第三表头、旧29列模板、签审带错映射拒绝；真实Writer的V1/V2同用途与错用途门禁。

生产改动后 `git diff --check` 原进程exit 0。最终定向编译/契约GREEN待主代理统一执行：`M05V51ExcelReportTest,M05ReportArtifactPipelineTest`，旧V1冻结回归不得省略。未以预期GREEN冒充实际结果。

主代理启动RED10后，本代理补齐V2逐格来源字段和同一正向例断言，双方已确认该轮只能作为中间快照；必须以最终冻结源码再次统一执行，不能借中间编译产物宣称最终GREEN。当前后端已按协调冻结。

RED10实际统一243例6失败1错误、原进程exit 1。旧V1 `M05ReportArtifactPipelineTest`9例全绿；V2本类6例1失败0错误，失败精确为新增L42 resultItemId批注断言。只读`javap -p`检查该轮target class（原进程exit 0）确认编译的Renderer没有当前源码已存在的v2MetricSource方法，属于旧生产class/新测试的中间快照；未据此继续堆修补或放宽断言。当前源码/测试已静止，最终6例与旧V1仍需统一重编译回归。

RED11已在最终静止源码重新编译：`M05V51ExcelReportTest`6例、旧V1 `M05ReportArtifactPipelineTest`9例均0失败0错误。统一该轮323例11失败10错误、原进程exit 1，其他范围未通过，不能写整轮通过。准确命令由主代理记录在同目录《02-验证命令与逐轮结果》。V2来源补充已取得最终源码证据，不沿用中间快照结果。

## 4. 分层状态

F30为IMPLEMENTED + CONTRACT_TESTED：V2已接真实报告作业链，新V2 6例及旧V1 9例通过。SQL执行、真实HTTP、浏览器、正式模板视觉核准/签名发布、文件发布原子性现场验收、打印设备及生产验收均NOT_VERIFIED。

V2正式核准模板/许可/公钥/受控release及worker部署需沿现有发布机制由拥有方提供，运行可标BLOCKED_EXTERNAL/BLOCKED_DEPLOY；这些不阻本批已可实现的真实渲染源码。未伪造核准包、输入参数、签名或成功文件事实。
