# 固定执行器HTTP适配与关联发布契约

2026-10-18技术适配增补。落实《三类实验室设备适配契约》§3和M07《设备命令契约》，不改变CMD-I01/I02签名，不新增浏览器控制设备入口。客户厂商协议仍由现场网关转换；本协议不是厂商已支持的声明。

## 命令网关 M02-CMD-HTTP-V1

M02客户端只访问部署固定的网关URI，不接受页面地址。非本机网关必须HTTPS；仅字面127.0.0.1或[::1]可用HTTP。禁止userinfo、query、fragment、重定向。配置前缀`futurefab.m02.command-gateway`：enabled显式true才装配；base-url、executor-id、adapter-id、hmac-key（至少32字节）、approval-ref、device-refs（kind:id:channel，空通道用-）、operations、timeout-millis、max-clock-skew-seconds全部必配。超时1..120000ms，时钟预算1..300s。凭据由部署秘密注入，无仓库默认值。approval-ref是现场核准文档引用，不由客户端生成核准事实。

POST `{base}/commands`提交，JSON为既有DeviceCommand字段，parametersPayload转为parameters对象；POST `{base}/commands/{commandId}/query`只查原命令（commandId、deviceCommandId、deviceRef、fence、configRevision），不得执行或补发。所有ID/版本十进制字符串。

请求头X-Executor-Id取固定部署身份、X-Command-Timestamp为UTC秒级或毫秒ISO时间、X-Command-Signature为小写HMAC-SHA256。签名原文`M02-CMD-HTTP-V1\n{executorId}\n{POST}\n{absolute-path}\n{timestamp}\n{sha256(body)}`，UTF-8，无尾换行。受信网关须在物理入口核验执行器绑定、完整资源组归属与fence、配置/能力版本及核准单位；按稳定commandId/requestId持久去重，同键异载荷拒绝，进程重启不丢原命令查单。未满足这些条件不得启用配置。

响应HTTP200的原文为M07 `{commandId,state,evidence}`，不使用管理Ajax外壳；头X-Command-Timestamp、X-Command-Signature，签名原文`M02-CMD-HTTP-V1-RECEIPT\n{executorId}\n{commandId}\n{timestamp}\n{sha256(body)}`。必须校验响应签名/时效、原命令身份、adapter-id、configurationRevision、fence、完整evidence规范摘要及时间/状态一致性。回执摘要沿现行JSON规则（对象键排序、数组保序），剔除payloadHash后SHA256。EXECUTED必须有真实readings和executedAt；ACCEPTED不能包含executedAt。查单必须给queryResult，NOT_FOUND只能UNKNOWN。无凭证、空/过大/未知字段/异身份/摘要错误或超时不返回假回执，抛依赖异常，由M07按已持久化调用阶段处理UNKNOWN。提交/查询均不自动重试，不跟随重定向，不把异常正文/地址/凭据写入日志。

客户端网络调用禁止位于管理或资源事务内。M02不从M07 Mapper读取控制权，也不创建第二套业务账；网关持久去重、物理fence及真实证据是部署验收前置。此客户端可用隔离HTTP服务器做契约测试；不表示真实网关或厂商驱动交付。

## 通讯关联发布客户端

新增受信恢复读口 POST `/internal/m02/device-ingress/communication-usage/current`，沿用同一适配器验签，正文仅 labId、deviceKind、deviceId、ownerModule、configurationVersion。核对授权范围和当前配置后返回 registrationVersion 与完整 links；不存在登记时为版本字符串 "0" 和空数组，这不表示设备空闲或就绪。接口不写验证时间或业务事实。写入结果未知后先读取并核对原载荷，不得自动换版本重发或仅凭版本变动判断原写已应用。

复用`/internal/m02/device-ingress/communication-usage`及M02-INGRESS-V1 HMAC，不新增公开管理口。设备适配器须从实际已加载的同代配置收集完整映射，分别发布M05/M07两个owner，明确expectedRegistrationVersion；部分发布失败保留原配置/owner/载荷，重读版本后核对，不自动换代/删关联。客户端只签名调用，不生成RESOURCE_MAPPING、adapter验证时间或设备读数；登记事务仍由服务端核对静态设备归属及业务拥有方完整性。

客户端本身不提供现场拓扑、密钥或设备应用回执。部署还缺：可信适配器身份与授权范围、真实映射生产者和完整快照、配置实际加载证明、同代登记版本、真实网关地址/认证与上述协议支持证据、固定执行器与物理写入隔离、逐泵单位/速度/停止读数核准。缺项保留BLOCKED_INPUT/BLOCKED_EXTERNAL，不手插verified行。

W08保持暂停。M07工作流的PREPARED持久意图、实际派发、设备回执、安全停止与结算分别验收；仅实现此客户端不能宣称W03/W07物理闭环通过。

同日M07续批已实现完整v1冻结与专用派发协调/扫描，边界见[M07执行规格增补](../07-补液运行与任务执行/ExecutionSpec版本与观测兼容契约.md#2026-10-18工作流冻结接线边界)。M02原规格提供方将管理修订号当配置/能力版本、拼controllerNo当adapter身份的投影已移除。实际metadata、核准executionProfile的权威生产链仍缺失；该事实束的静态/计量字段不得通过网页提交，也不得将测试profile发布到运行配置。新消费者存在不表示可启用真实设备START，初始计量段、运行监控和安全收尾也须独立验收。


## 同代配置加载回报入口（2026-10-18）

新增内部 `POST /internal/m02/device-ingress/configuration-apply`，复用部署固定的适配器授权与 HMAC，purpose 固定 `CONFIGURATION_APPLY`，不能重放 OBSERVATION/COMMUNICATION_USAGE 签名。Body 严格为 labId/deviceKind/deviceId/desiredRevision/result/errorCode/observedAt；身份及修订为字符串，observedAt 带 offset。result=APPLIED 时 errorCode=null；FAILED/UNKNOWN 分别使用 CONFIGURATION_LOAD_FAILED/CONFIGURATION_LOAD_UNKNOWN。接口不接受 adapterInstanceId、online、verified 等自报字段，adapter 身份只来自验签结果。

SYSTEM 首锁、原生事务及有界锁等待；从 M02 实例表重验实验室和配置身份，再锁配置，同事务更新 appliedRevision/applyState 并追加不可变证据回执。旧修订及 APPLIED 后迟到失败保留原状态且 accepted=false；同证据返回原回执并 duplicate=true。回执插入失败整体回滚。不生成用户守卫身份、不推进管理配置修订、不调用现场设备。

适配器侧 `CommunicationUsagePublisher.reportApplied(ConfigurationApplication)` 仅发送调用者已经实际尝试加载的结果；无自动成功、无自动重试，未知结果保留原 observedAt/修订/载荷以便同证据重放。HTTP 传输仍限 HTTPS 或字面回环地址，无重定向且限制响应和总时限。生产加载器尚需在真实加载结束后调用本方法；具备客户端代码不等于设备已加载。

通用通讯身份白名单以[通讯公共契约](通讯与设备公共契约.md)第1节为准；泵/台式控制器不得冒充秤登记。配置加载回报、观测值、工程核准、命令执行是不同事实，不能由其中一种推导其他事实。命令网关 adapter/configurationRevision 的生产关联仍需专用受信映射及实际加载凭证；不能从 controllerNo 或 SYSTEM revision 生成。
