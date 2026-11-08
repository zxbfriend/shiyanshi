# work1第一批现行设计纠偏复审

日期：2026-11-03。HEAD：`0fdf8612796f3503a9f04d63d186e6b4b9deaad4`。

结论：部分返修。未接受“11项全部落地”的整体结论。本次回读处置记录与六份现行文件差异，对下列问题定向核对源码；不构成全部分支深度验收。

## 1. 必须修正

| 编号 | 问题与实际依据 | 返修范围 |
|---|---|---|
| W1-01 | 接口目录定位026及开始培养专题M07-026将SET_AUTO笼统写为固定拒绝。但RunWorkflowApplicationApplicationServiceImpl#operateWorkflow先分派逻辑W07、W03模拟及中试模拟，随后普通实机分支才有CONFIGURATION_INCOMPLETE拒绝；模拟SET_AUTO在现行任务专题也有明确说明。 | 区分开始培养Controller拒绝、模拟分支及普通实机分支；不把实机分支拒绝外推到整个路由，也不保证所有失败均返回该错误码。同步报告。 |
| W1-02 | 任务专题complete新增说明称“不写正式连接标志”，与逻辑成员当前行为不符。BenchConnectionBatchService#finalizeSimulation中applyConnection为非取消且逻辑成员时，调用saveBusinessConnection并completeLogicalConnection，applicationState为APPLIED；saveBusinessConnection写连接运行关联，现场能力仍UNVERIFIED，completionEvidence仍simulated=true。 | 区分逻辑成员业务连接保存与其他成员仅终态登记。业务连接不等于真实设备连接或动作成功。同步本页原有“模拟终态不写正式连接标志”泛化句，保留无设备命令等实际边界。不能只改新增句而留下矛盾。 |
| W1-03 | 报告自列DOC-02三项、DOC-03四项、DOC-04三项、DOC-05两项，合计12而非11。 | 修正标题、摘要和自检数量；若使用其他分组口径需解释对应，不改业务范围。 |

## 2. 轻量文字修正

报告DOC-02②依据称“四路ownsBatch分派”，实际最后W02为兜底，不执行第四个ownsBatch。其他正文已正确写兜底，统一该依据句即可。

## 3. 验证及边界

复跑原七份文件检查：`FILES=7 BAD_LINKS=0 BAD_TABLE_ROWS=0`，进程退出0。格式通过不替代上述语义返修。

未编辑work1现行文件或处置记录；仅新增本复审记录。未改业务代码、SQL、配置、客户原件，未运行编译、测试、SQL、HTTP、浏览器或设备验证，未暂存、提交或推送。工作区客户OPC接口xlsx的已有修改保持不动。

完成上述定向修正后复审；本记录不新增业务决策题、不要求扩展审核范围、不宣布S03通过。

## 4. 定向返修复核（2026-11-03）

HEAD仍为文首版本。W1-01、W1-02、W1-03及兜底文字修正已复核，接受本轮定向返修：

- SET_AUTO：Controller开始培养拒绝与服务分派分开；W07逻辑及W03/W02模拟仅启停，W01模拟处理SET_AUTO；普通实机路径先核参数、提供方与派发依赖，再拒绝SET_AUTO。依据为各操作方法本体，不采用旁边过期注释替代实际分支。
- W03：complete保留SIMULATION范围，逻辑成员保存业务连接且APPLIED；其他成员NONE。共同证据仍simulated=true，现场能力仍UNVERIFIED。confirm不保存最终业务连接，cancel不套用complete分支。同页旧泛化句已同步。
- 数量已统一为12个处置子项；分派依据已写前三路判断与W02兜底。

本批DOC-02—05文档纠偏可交接，不再向work1追加逐口审计。仅接受本轮授权文档范围，不表示接口运行、整个S03或其他待办通过。DOC-06仍独立待复审与合并。
