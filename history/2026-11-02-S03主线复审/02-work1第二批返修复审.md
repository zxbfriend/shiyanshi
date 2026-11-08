# work1第二批返修主线复审

日期2026-11-02，复审HEAD：e5602792982828303d6c3e89d719c083cf85fe00。被复审报告结束快照59666f4fb；之后生产目录提交变化为BottleConfigController、DetApprovalAssigneeController、DetApprovalRecordController及ResBatchLeaderController，不将旧行号当作当前行号。本文只新增复审记录，不改work1文件、覆盖表、代码、SQL、配置或客户原件，不提交推送。

结论：**部分返修可接收，RV01/RV03/RV04尚未完全闭合，新增链级核验仍需定点补证；S03继续，不能回填全部RV已解决。**

## 1. 可以接收的返修

- 报告结束状态改为部分完成，并明确链级与字段级的区别、剩余未核范围，不再宣布S03完成。
- 删除取消审批政策启停导致M06-Q03失效的推导，保留自动核对及双人人工对账；不批准Q8替换现流程。不再断言行锁/对象版本足够替代租约。
- D-10改正新应用服务与裸写旧Service的混用，D-11更正为queryProfiles，M04工作流配置两口从M02差异统计剔除。具体各路由“在用”证据仍见下列余项。
- 公共约定E与验证层级已按现行AGENTS调整，不再仅因设计有要求就派必须开发；G1/G3措辞收窄、“改一行”承诺已撤。
- M08 StatisticsApplicationService为具体类且存在Source Port适配器、M04模板存在动态功能权限判定等正面源码事实可接收；这些事实不自动证明全部端点参数/分支/权限均核完。

## 2. 第二批仍需返修事项

### B2-01（P1）：M06-Q03与M09通知查单不能串证，政策拒绝口不能算业务真实实现

报告§3.2把AlarmDeliveryReconciliationService:248的TODO用于证明M06-Q03。实际该类在service/support/m09，处理通知delivery、提供商查单及DeliveryQueryCapability；不是M06审批决定的交付和双人对账。相同UNKNOWN名称不能建立业务等价关系。

M06已有ApprovalReconciliationCommandApplicationServiceImpl/Query及AprReconciliationMapper可用于追溯，不能拿M09 TODO作为M06自动核对/双人/证据规则一致的证明。补M06真实入口→命令/查询服务→审批交付/拥有方事实链，分别给提交人与复核人不同、原delivery/version、无证据不释放、重复处理等分支证据，未核的明确保留。

另外报告§0说M06十五口为真实链，但其中activatePolicy在ApprovalPolicyCommandApplicationServiceImpl校验后固定抛SOURCE_STATE_CONFLICT（政策启停已取消）。它是有鉴权的停用拒绝链，不是启停业务已实现。沿前批已确认事实登记，不能在族级新汇总中重新抹平。十五个映射可存在，不能因此写十五个业务实现。

### B2-02（P1）：G5仍把集合返回错误描述为单对象，RV03不能写全部解决

报告RV03与G5表称getUserlab(row.userId)“取单对象”，进而推定成功的单条编辑请求。实际SysUserLabController#getInfo返回selectSysUserLabsByUserId，即List；页面handleUpdate直接form.value=response.data，submitForm再按form.value.userId是否非null选择update或add。没有把所选lab行转换成单对象的代码。

可以接收两个静态问题：详情集合与页面对象消费不符；若PUT收到带userId/labId的单关系载荷，其SQL却按user_id更新多行。但不能把它们拼成已经证实的“当前页面取到单对象后执行PUT、该实验室修改影响该用户全部实验室”完整路径，更不能宣称运行数据损坏。

返修：如实登记集合回包、实际分支及可证明的载荷；单行意图须贴需求/确认或明确页面证据，不用按钮名称替代。保留SQL作用域风险和页面数据形态偏差；未核真实PUT触发条件与载荷时，不把此业务链标闭合。

### B2-03（P1）：机械归属只可做候选清单，不能用作当前模块完成分母

实际读取temp/work1/s03/modules.mjs及routes_mod.json，确认以下已知误归属：

| 控制器 | 机械清单 | 现行源码/契约事实 |
| --- | --- | --- |
| LabObservationController（5口）、ObservationIngressController（1口） | M05 | M02源观测与接入，前十二批已逐口定位 |
| WorkflowBatchQueryController（1口） | M04 | 明确依赖service.application.m07.WorkflowBatchQueryService，权限run:workflow:query；无需按类名猜owner |
| PilotReplacementBatchController（2口） | M03 | service.application.m07.PilotReplacementBatchService及M07 DTO/W02工作流 |
| WasteClearBatchController（2口） | M03 | service.application.m07.WasteClearBatchService及M07 DTO/W08工作流 |
| LabSoundAlarmController（11口） | M09 | 设备实例维护与M09告警发送须按实际职责分开，不能因SoundAlarm字样整族改owner |

SysUserLab归属也不能只因Sys前缀就统计为M01业务拥有方；HTTP入口位置、数据owner与调用模块分别记。报告已注明机械推断，这使其可以作初步清点，却不能同时拿M04 26/26、M05未核133、M07剩52等作为已确认模块进度。先落实已能从源码/当前专题解决的归属，再重算，不把已清楚的M07批次归属推成客户或owner题。

扫描ROOT仅futurefab-modules，排除futurefab-auth等；因此1025/1034只能描述该范围及解析策略下的临时结果，不能称全系统唯一接口集合。AAD是当前明确交付范围，需在整体剩余清单登记认证模块覆盖边界。

### B2-04（P2）：新核验的证据深度与“核完”表述仍不一致

M04仅列ProcessTemplate19口的动态权限位置及几个Controller族，未逐口转录每口应用方法/实际下游与关键分支；M06/M08表多处只到应用服务方法名，没有逐口落实Mapper/Port消费者/关键失败分支。报告自己写字段级0、M08需求逐章未核，这些应保留为“路由及部分链定位”，不能在转交摘要写“26/26核完”“15/15核完”。

返回每个接口唯一身份、需求依据状态、真实链（包括拒绝/部分链）、前端或后台调用证据、关键分支和具体未验项。内部通用判权方法存在不等于19个模板入口都已证实调用；Source Port类存在也不等于10口的所有数据、查询状态/用户隔离和图表分支均已验收。没有需求规定新增写功能码时，不制造是否另加功能码的客户题。

M04-023等仅有设计而缺需求/批准方案的目标，继续列设计缺口待溯源，不自动恢复必须开发。正常业务链、已有声明性拒绝及不存在的路由要分别计数。

### B2-05（P2）：R36四个活动映射不等于四个页面在用，影响字段也须分开

新链GET/PUT反应器入口的旧键回退、控制器主入口的兼容reactorId投影是不同影响。此前已定位页面使用controller两口，reactor两口有SDK封装但未定位当前页面直调；本轮报告称“四个在用口”却未补四口消费行。改记活动实现/已定位消费者分别列示，不能用路由存在或共享方法证明页面在用；控制器直接按ID寻址也不能和反应器旧键回退寻址的后果混写。

### B2-06（P2）：身份清点脚本只是临时扫描，不是完整映射/权限证明

inventory.mjs递归futurefab-modules，按行正则读取，不剥注释；方法扫描只看后续八行，多前缀仅提取第一个，RequestMapping统一记ANY，权限在Mapping之前累积。WorkflowBatchQueryController在GetMapping之后才写RequiresPermissions，这种写法会被该扫描行漏记，不能把空权限列作为端点无注解证据。别名另手工加9时要枚举来源，不能把常量修正当实际展开。

本轮静态复算存量routes.json确为1025条、无空方法名、无重复verb/path键，这些有限检查可接受；但这不证明映射覆盖完整或模块归属正确。报告后的并发ResBatchLeaderController注释改变已导致至少一条旧行号不再落在当前注解上，不能据此指责旧快照数据虚假，也不能沿用旧行号宣称当前复验。限定生产源目录、处理注释和数组/方法属性、按当前快照核已发现的异常，再给计数。临时扫描不转为源码门禁测试。

## 3. 下一批最小返修顺序

1. 先修B2-01及B2-02，撤回跨模块串证和单对象错误前提。
2. 修正已知模块归属/扫描范围及当前分母，明确路由、handler、别名、数据owner与业务归属。
3. 将M04/M06/M08进度降到实际证据层级；补逐口下游与关键分支，不扩需求、不批量造缺陷。M09已有6口深核、其余待核继续如实保留。
4. 保留前版已正确修复的规则/Q03有效性，不反复撤回；重新给RV01/RV03/RV04的部分解决状态和剩余项，不笼统七项全解决。
5. 主线覆盖表暂不回填新增模块核完数字；继续不改代码、SQL、客户原件、配置，不提交推送。

## 4. 本轮复审与验证边界

读取第二批三份文档、临时inventory/modules/check-doc脚本及其清单；按当前源码抽核M06政策拒绝、M09查单与M06实际对账类、用户授权集合回包/表单分支、M07批次调用以及模块归属。没有复验全1025个临时记录，也不重复实施S03全部剩余核验。

编译、单元测试、真实数据库集成、真实环境或浏览器四层均未验证。只新增本主线复审记录，未改work1文档或覆盖表。检查结果以本轮实际命令输出为准，不把静态源码读取当运行验收。
