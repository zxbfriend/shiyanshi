# K03 Vi-CELL前缀类型与原样回传核查

日期：2026-11-01；核查HEAD：`9aabe22594919a968d5ebc6fa95cdc245747c790`，另读当前工作区。仅核查附件、原型和代码，记录具体输入及实施缺口；不修改业务代码、客户原件、SQL或运行配置，不调用设备或外部系统。

## 1. 结论

**业务含义已定，完整前缀链尚未接通。**中试前缀可选，类型部分取字典键值，显示名只展示；原型要求后续Vi-CELL取测自动填写，返回类型不一致时标红及告警。不能再以SC-Q07旧提示重问类型取值。

现有Named Pipe资料提供CellType字段及任务关联，但没有中试带前缀的真实请求/结果样例，也没有证明该字段就是仪器原样返回的类型名称。当前代码有三处拒绝非空前缀，保存语句未落前缀，正式CDP采集未读取CellType，更未完成前缀结果比对。

因此K03应分为**我方已知接线缺口**和**实际设备传参/返回对应待核**，不是要求客户重新提供字典或作新业务裁决。中试真实来源不能仅按实验室名称猜成Named Pipe或SDMS；本轮不恢复额外Vi-CELL HTTP订单接口。

## 2. 依据及可用程度

| 来源 | 已明确内容 | 未提供/不能推定的内容 |
| --- | --- | --- |
| [V5.1原件](../../../../需求说明书V5.1-1030.docx)，B6355—6357 | 中试开始培养步骤2细胞类型：前缀选填、类型从数据字典单选必填；B8047培养记录中试含前缀展示 | 未规定分隔符、字符归一化、设备字段长度或返回载体 |
| [原型“⑤中试-开始培养”](../../../../需求原型V5.1-1030/⑤中试-开始培养.html) | 原页静态文字明确“中试的细胞前面可以自定义一个前缀（选填）”“后续…Vicell取测…自动…填写细胞类型”“检测结果返回的细胞类型…不一致标红以及告警”，返回名字与前缀＋类型比对 | 这是业务交互说明，不是某个Pipe/HTTP/文件的协议定义；没有完整字符串或实际设备输出样例 |
| [第117项有效澄清](../../../../需求说明书V4.0-0904_md/需求澄清决策记录.md) | 中试前缀场景类型部分为dict_value，dict_label只展示；不改变无前缀场景；不新设字典键值修改能力 | 本条明确未同时裁定分隔符、大小写/空格处理、完整长度或设备参数能力 |
| 10/30培训01:32附近 | `D:/Downloads/文字记录：SMP后续需求串讲 2026年10月30日.md`第1327行提及前缀与离线检测关联，应核前缀使用逻辑 | 未补足真实拼接格式、协议字段或回传示例 |
| [Named Pipe说明](../../../../接口文档/离线检测接口文档/SubSystem-NamedPipe接口文档.md) §7.2.3/7.2.4、7.3.1、示例§9 | log_in/log_in_manual可携SampleInfo；CellType是string；SampleID、任务头/明细、设备ID等字段存在；示例CellType为CHO | string不能证明任意完整名称都可直接送仪器；未定义CellType长度、前缀格式或独立返回类型字段。SubsystemSuccess只是该指令成功，不是类型原样回传 |
| [六子系统字段说明](../../../../接口文档/六子系统数据表字段说明.html) ViCell部分§2—5 | CellType/DilutionFactor在任务明细中为送检写入；结果扫描/DBUpdateResult主要回写VCD、Viability、AvgDiam、文件路径、状态和完成时间；类型可从旧字典或CellTypeSetting读取 | 不能把先写入明细的CellType读出来当作仪器返回值。该说明没有给出带前缀结果文件内容或真实设备类型列 |
| [SDMS说明](../../../../接口文档/离线检测接口文档/发送订单到SDMS-接口文档.md) | 有订单/结果通用路径及BGA等说明 | 本轮未找到Vi-CELL带前缀订单/结果的字段约定；已有VicellJob名称不能证明该协议已具备，不从BGA/OSMO/Cedex样例外推 |

原型仅静态读取文字，未执行其脚本。客户参数附件含有连接信息，本报告不复制连接、凭据或令牌；核查结论只涉及业务字段及代码。

## 3. 必须区分的四种内容

| 内容 | 本次核查结论 |
| --- | --- |
| 字典记录ID与字典键值 | 开始培养用稳定字典记录选择，类型业务内容用dict_value。它们不等于dict_label，也不等于任意设备编号 |
| 可选前缀及完整业务类型 | 前缀独立于样品编号前缀；与类型部分按真实设备格式对应，不自动插下划线/横杠，不trim或改变大小写，不用显示标签替换键值 |
| 设备实际下发字段 | 当前Named Pipe适配会把非数字业务键值按每设备配置映射成正整数字符串，再填CellType。它是已有设备侧编码层，不能直接塞完整前缀名称；也不能把此规则强加给所有中试来源 |
| 检测实际返回类型 | 必须定位到真实设备/结果载体中的原值及其来源。请求中填写的CellType、业务期望值和仪器实际返回值分别保留意义，不能循环用期望值证明“相同” |

不改变普通无前缀规则。格式及长度未核实前，不将本地数据库VARCHAR长度当作仪器限制，不截断字符串，不在本轮自行增加设备ID映射、格式管理页面或新审批。

## 4. 当前代码链及具体缺口

图谱工具连接失败，本轮采用限定目录搜索及直接读取。以下为源码静态事实，未执行数据库或设备。

| 环节 | 当前代码 | 具体缺口/影响 |
| --- | --- | --- |
| 输入与合法类型选择 | [StartCultureCommands.Inoculation](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/dto/m07/StartCultureCommands.java)已有cellTypePrefix；[M03StartCultureAdmissionAdapter](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/port/m03/M03StartCultureAdmissionAdapter.java)先拒绝非空前缀，再从字典读取label/value | 类型取值基础已有；拒绝前缀是旧接线状态，不能解释为业务未确认。不得仅去掉校验就宣称完整支持 |
| 最终持久化 | [StartCultureOwnerMapper.complete](../../../../../futurefab-modules/futurefab-system/src/main/resources/mapper/resource/StartCultureOwnerMapper.xml)写type/name/value及来源，不写prefix；[OwnerRow](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/domain/row/StartCultureOwnerRow.java)已有prefix属性 | 有字段/属性不等于保存链已完成；须由M03按原第4步唯一保存点落前缀及来源，历史不回写。本轮不改表或代码 |
| 生效类型提供及检测填入 | [M03CultureStartProfileAdapter](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/impl/port/m03/M03CultureStartProfileAdapter.java)拒绝前缀；[M05CultureCellTypeSupport](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/support/m05/M05CultureCellTypeSupport.java)也拒绝前缀，并限制普通cellType长度50 | 缺中试带前缀消费；dict_value与label分开已存在，不重问。当前50、M03字段100等是存储/代码约束，不是已证实的设备完整名称长度 |
| Named Pipe序列化 | [SampleInfo](../../../../../futurefab-namedpipe-client/src/main/java/com/futurefab/namedpipeclient/vicell/model/SampleInfo.java)的CellType为String；[M05NamedPipePreparation](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/support/m05/M05NamedPipePreparation.java)要求正整数或显式cell-types映射，发送log_in_manual | 必须核具体中试设备实际接入是否走此链及业务类型到设备类型的对应。Java String、DTO存在和通道受理都不能当作支持任意前缀的证明 |
| SDMS分支 | [M05SdmsDispatchAdapter](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/support/m05/M05SdmsDispatchAdapter.java)只登记BGA/OSMO/CEDEX，未登记Vi-CELL订单 | 不为了补K03擅自增加Vi-CELL HTTP；先查实际已有设备来源，这不是需要用户重新选一种通信方式 |
| CDP正式结果取数 | [JdbcCdpResultReader](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/support/m02/cdp/JdbcCdpResultReader.java)的Vi-CELL SELECT读取任务身份、样品、状态/时间及三类测值，不读取CellType | 原样快照只包含实际SELECT取得的列，不能说原始结果已经保留类型。即使将来加读CellType，也须先证实其来自仪器结果，而非请求回填 |
| 关联及比对 | [M05CdpObservationVerifier](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/support/m05/M05CdpObservationVerifier.java)按原派发、设备、协议、SampleID及源任务/明细关联；[正式结果映射](../../../../../futurefab-modules/futurefab-system/src/main/java/com/futurefab/system/service/support/m05/M05CdpFormalResultMapping.java)处理检测项、数值/单位 | 原关联机制可沿用，不靠类型串重新绑定任务。所查正式链未实现带前缀实际类型与业务期望类型比较及对应标红/告警；原型已有该功能，不新增结果作废、拒收、任务暂停或自动重测联动 |

有状态和关联基础不等于带前缀路径已IMPLEMENTED。已有类型清单/键值选择是正常维护事项，不需要现场重新裁决；未读现场配置不等于现场没有映射。

## 5. K03收窄后的内部子项

| 子项 | 可由我方继续推进 | 确实还需核到的输入/证据 |
| --- | --- | --- |
| K03-A 业务字段与来源 | 按既有字典键值及第4步保存点落实前缀独立保存、生效来源、普通无前缀兼容和本次检测期望值关联 | 既有输入范围保持；不得从当前字段长度推定设备长度或新设必填前缀 |
| K03-B 实际传参对应 | 对照现有设备通信配置，确定真实链路和各层字段用途 | 一组该中试设备的“前缀原值、字典键值、设备接收字段/内容、设备侧类型配置”对应；若有转换，由现有接口方明确，不自造转换规则 |
| K03-C 原样返回与样品关联 | 沿既有派发/源任务/明细/SampleID关联，原型要求的类型比对、标红及告警按原有模块责任落实 | 同一样品的真实结果载体及类型字段/列原值，区分请求回填；实际格式、长度/编码限制。若来自文件需具体列/位置；若来自接口/表需明确字段及生产者 |

最小对接证据是一组保留真实格式的同样品“配置/送检/结果”对应及字段说明，无须整批历史数据、客户凭据或新业务选择。先查已有设备/接口方资料；只有必要信息确缺才对该分支登记BLOCKED_INPUT/BLOCKED_EXTERNAL，未联调则NOT_VERIFIED，不冻结无前缀独立功能。

## 6. 关联与验证

与[K01—K03开发与输入缺口汇总](24-K01-K03可推进事项与输入缺口汇总.md)及[现行待核清单](../../../00-十二月上线开发对接待核事项.md)共同读取；本报告为过程证据，不新增平行业务权威。没有发送消息给客户或接口方，没有修改接口实现/SQL/配置，没有运行构建、单元测试、HTTP、浏览器、设备或现场验收。
