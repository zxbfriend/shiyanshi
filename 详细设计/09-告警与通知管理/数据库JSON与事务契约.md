# M09 JSON字段、逻辑键与事务契约

2026-09-10。配套15表284列；JSON默认schemaVersion=1，明确登记的补料声光 result_ref v2 例外见下文；未知键/枚举拒绝，输入采用结构化DTO并限长，不接受任意脚本/SQL/URL。可空字段显式null，数组显式[]。内部数字ID/版本均字符串，时间统一UTC毫秒Z参与hash，显示Asia/Shanghai；十进制规范字符串、对象键字典序、业务有序数组不重排、集合按稳定ID排序，UTF-8 SHA256小写64hex，保留schema及canonicalVersion=1。

## 1. 公共值对象叶子

| 对象 | 完整叶子 |
| --- | --- |
| SourceRef | module:M01/M02/M03/M04/M05/M06/M07/M08/M09/ADAPTER,kind:string≤40,id:string≤100,version:string≤100,hash:64hex\|null |
| Actor | kind:USER/SYSTEM,userId:string\|null,displayName:string≤100\|null,sourceModule:string≤20 |
| Scope | kind:DEVICE/CULTURE/LAB/SYSTEM,labId:string\|null,deviceKind:string≤40\|null,deviceId:string\|null,cultureId:string\|null；身份关联从服务器验证，不信任前端labId |
| AuthorizationRef | evaluatedAt:ISO,userId:string,labGrantRevision:string\|null,projectGrantRevision:string\|null,memberRevision:string\|null,permissionRevision:string,decision:ALLOW/DENY/UNKNOWN |
| QuantityRef | source:SourceRef,value:decimal字符串\|null,unit:string≤30,observedAt:ISO\|null,quality:GOOD/BAD/UNKNOWN,normalizationProfile:SourceRef\|null |
| CommandEvidence | commandId:string,state:ACCEPTED/EXECUTED/FAILED/UNKNOWN,occurredAt:ISO,source:SourceRef,measuredValue:decimal\|null,unit:string\|null |
| Link | routeName:ALARM_DETAIL/CULTURE_DETAIL/DETECT_RECORD/SIGN_WORKBENCH/TASK_DETAIL/DEVICE_DETAIL,params:{alarmId?,cultureId?,deviceKind?,deviceId?,sampleId?,taskId?},label:string≤100；未知路由拒绝，内部路由白名单无外部URL |

Event完整字段：sourceModule、sourceEventId、sourceObject:SourceRef、sourceVersion、ruleKey:string|null、eventKind:TRIGGER/RECOVER/BUSINESS/EXTERNAL_PUSH、conditionKey:64hex|null、sourceSequence:string|null、labId:string|null、cultureId:string|null、occurredAt、schemaVersion:1、canonicalVersion:1、fact:Fact、payloadHash:64hex。sourceEventKey由服务端计算，不由外部填入绕过去重。同一持续condition必须有单一权威序列生产者；跨进程重启接续持久化序列，不能重置到1，不具备时只接收BLOCKED待接入。

P2-04 / INT01内部Port投影补记（2026-10-21）：现有EventEnvelope以sourceModule/eventId/eventType/occurredAt/payloadHash/payload承载，payload沿既有六字段白名单 `{schemaVersion,canonicalVersion,fact,ruleKey,conditionKey,sourceSequence}`，M07新安全生产者完整输出六字段。这里重申已有事件级叶子的物理承载，不增加HTTP DTO或未知JSON键。内部EventReceipt保留四种状态ACCEPTED/DUPLICATE/CONFLICT/REJECTED，增加持久sourceModule/sourceEventId/payloadHash；BLOCKED同hash重放仍REJECTED，原因取原result_ref。身份缺失或不匹配的回执不能确认M07安全发件箱，详见[接口目录INT01](接口目录与契约定位.md)及[M07专用子包](../07-补液运行与任务执行/数据库JSON与事务契约.md)。

Fact完整白名单叶子：source:SourceRef、actor:Actor、scope:Scope、projectId:string|null、batchId:string|null、sampleId:string|null、taskId:string|null、resultId:string|null、itemId:string|null、direction:LOW/HIGH/ERROR/INFO/NONE、observed:QuantityRef|null、lower:decimal|null、upper:decimal|null、thresholdUnit:string|null、policyRef:SourceRef|null、phase:string≤40|null、title:string≤200、summary:string≤1000、entityLabels:{cultureCode:string≤100|null,deviceNo:string≤100|null,itemName:string≤100|null,mediumName:string≤100|null}、aliasRuleKeys:[string≤64]、commandEvidence:[CommandEvidence]、links:[Link]、change:Change|null、deadline:{jobKey:string,businessDate:date,from:ISO,to:ISO,sourceWatermark:string}|null。Change为闭合联合：N_MARK={kind:N_MARK,old:{marked:boolean},new:{marked:boolean}}；DELAY={kind:DELAY,old:{state:State,startActive:boolean,endActive:boolean},new:{state:State,startActive:boolean,endActive:boolean}}，完整保留M03第5.4节outbox原字段。State沿M03 DRAFT/NOT_STARTED/RUNNING/CANCELLED/FINISHED/EXPIRED/DELAYED的实际导出编码核对，未知编码阻断，不自创映射。非该事件所需字段为空，不把全培养对象塞进snapshot；实际事件需要额外变量时先发布新schema，不能动态塞任意键。

## 2. 每列模式与可变性

| 表.列 | 结构 | 生命周期 |
| --- | --- | --- |
| alarm_record.fact_snapshot | {schemaVersion,canonicalVersion,fact:Fact,eventHash:64hex} | 首次触发后不可变；恢复时间在独立列 |
| alarm_notify_rule.notify_methods | 既有CSV，site,email,sms,phone,sound规范顺序去重；phone为旧123已确认原渠道 | 当前配置投影；revision保留旧值 |
| alarm_record.notify_users | 旧varchar兼容显示JSON数组，不再作为授权源；V2仅写稳定ID字符串数组，超1000长度不截断身份列表而写空兼容值并以recipient表为准 | 授权只用recipient与recipient_state；空兼容值不等于KNOWN_EMPTY |
| alarm_online_config.methods_json | [sms/phone/email/sound]去重 | 当前投影，电话已确认本期；真实协议/参数未齐则只阻电话实际调用，不以SAVE_ONLY排除该渠道 |
| alarm_online_config.logic_profile_ref | SourceRef | 当前核准逻辑，不从客户端写入 |
| lab_status_alarm_config.quantity_source_ref | {schemaVersion,quantity:QuantityRef} | 可信数据同步投影；未知为NULL |
| alarm_config_revision.content_json | {schemaVersion,canonicalVersion,scope:Scope,kind:RULE/MAIL/ONLINE/OFFLINE/STATUS/MONITOR,body:对应下面固定对象,actor:Actor} | 内容/hash不可变；状态列独立更新 |
| alarm_event.payload_json | {schemaVersion,canonicalVersion,fact:Fact}；M09内部命令另用CommandReceipt模式 | 收件后不可变 |
| alarm_event.result_ref | {schemaVersion,alarmIds:[string],deliveryIds:[string],reasonCode:string\|null,monitorAck:{policyId,revisionId,state:APPLIED/FAILED/UNKNOWN,occurredAt,evidence:SourceRef}\|null,commandResult:CommandResult\|null} | 处理状态/ACK投影；更改用版本CAS |

补料异常声光规划新增 `alarm_event.result_ref` schemaVersion 2：沿用 v1 各叶，并增加 `soundPlanning:{state:ALLOW/CANCELLED/BLOCKED/UNKNOWN,deliveryId:string|null}`；其中 ALLOW 仅表示已生成投递计划，不表示设备已动作。未走该规划的事件继续使用 v1。声光规划阻断/未知可按原事件和告警身份重查已核准规则与事件时设备绑定，事务中以版本 CAS 更新规划结果，保留原 `reasonCode` 和其他字段；新增投递 ID 同步追加至 `deliveryIds`。已有 v1 记录不得补造设备身份或事后用当前绑定代替历史事实。
| alarm_recipient.source_json | {schemaVersion,sources:[{kind:CULTURE_MEMBER/DEVICE_OWNER/ROLE,sourceId:string,level:CULTURE/BATCH/PROJECT/DEVICE/ROLE,sourceRevision:string}]} | 触发解析后不可变 |
| alarm_recipient.authorization_ref | AuthorizationRef | 当时证据不可变；当前发送另外鉴权 |
| alarm_delivery_attempt.evidence_ref | {schemaVersion,method:RESPONSE/CALLBACK/QUERY,provider:string≤100,reference:string≤200,receivedAt:ISO,signatureVerified:boolean,responseHash:64hex,source:SourceRef} | 同次尝试结果单向终结；UNKNOWN后核实保留证明，不覆盖历史错误摘要 |

配置body叶子：RULE={ruleId,ruleKey,alarmType,alarmModule,notifyMode,timeStart,timeEnd,methods,limitCount,intervalMin,receiverSources,roleIds,status,windowPolicy}；ONLINE={rows:[OnlineInput],evaluationState,logicProfileRef}；OFFLINE={cultureId,detectClass,rows:[{itemId,lowerLimit,upperLimit}]}；STATUS={labId,tab,rows:[{configId,expectedVersion,alarmQuantity}]}；MONITOR={mode,remark}。字段类型/长度/枚举见页面DTO；schema不得省略页面字段。MAIL={senderEmail,senderAccount,platformName,serverName,serverPort,smsGatewayUrl,status,passwordCipherRef:{ciphertext,keyVersion}|null,smsSecretCipherRef:{ciphertext,keyVersion}|null}，不保存输入明文密码或KEEP星号。所有content_json属于受控数据，日志不能序列化输出整个对象。

### 2026-11-07 RULE/LAB实施约束

实验室规则使用既有Scope.kind=LAB、真实labId；固定scope_key为`LAB:<labId>:RULE:<ruleId>`。每条修订body严格为本节单条RULE对象，不使用全局rules数组；同一批次仍由原M09-005守卫全量校验、同事务保存，任一行失败整批回滚。规则目录的全局unique rule_key保持身份，不复制成各实验室物理规则，也不以全局active_revision_id供实验室事件兜底。

仅新RULE/LAB逐条修订采用`request_key=SHA256(actorUserId+"\n"+operationCode+"\n"+原requestId+"\n"+canonical scopeKey)`；`request_hash=SHA256(operationCode+"\n"+原requestId+"\n"+canonical scopeKey+"\n"+content_json)`。scopeKey必须由服务器验证lab和规则身份后生成，不接受客户端任意字符串。原管理守卫收据仍使用原requestId与含labId的整批规范载荷，相同请求重放不追加修订，同键改lab/载荷拒绝；其他kind和历史台账的键算法保持。仅新RULE/LAB写入前沿既有canonicalVersion=1规范化规则排序对象键并保留数组顺序，content_hash=SHA256(规范内容JSON)；读取按同一规范校验，JSON存储重排键/格式化不改变内容身份。上式request_hash中的content_json同样是本次写入的规范JSON。其他kind及历史记录原摘要口径不变。

### MAIL共享配置的原修订闭环（2026-11-07设计补齐）

MAIL沿既有SYSTEM Scope，lab/device/culture叶子均null；唯一配置继续使用原`alarm_mail_default` configKey，MAIL修订的scope_key复用该同一语义键，不新增第二个单例键或枚举。既有alarm_config_revision的MAIL kind、content_json/base_revision_id/request_key/hash/APPLIED/row_version及单例active_revision_id已能承载；不得为本闭环扩表或另造回执。

API06同一读快照返回当前单例version、真实active_revision_id及该MAIL集合最近APPLIED修订；身份不一致/原件损坏按原错误失败，不填SYSTEM修订、行版本或任意别的配置组ID。API07在原M09-007守卫事务中核真实baseRevisionId和expectedVersion，按原KEEP/REPLACE/CLEAR取得实际密文引用、记录本次完整MAIL APPLIED修订，再CAS单例字段/active_revision_id/version、原审计、原守卫回执及SYSTEM版本；任一步失败全组回滚。同UUID重放沿原守卫返回，不重复加密写或追加修订。

空baseRevisionId仅在确无该MAIL集合已应用基线时合法；若已有单例但尚无台账，也必须校该单例真实expectedVersion，仅本次合法写建立首份MAIL修订，不在GET补造历史。首次无单例时expectedVersion亦空；有旧APPLIED即必须匹配真实base，不以解析字段但忽略基线当校验。content_json继续本节既有MAIL body，passwordCipherRef/smsSecretCipherRef只保存实际密文/可回读版本或null，不存明文/星号；读取页面与日志不输出这些密文。加密版本必须指实际可解析实现，未知不能靠默认版本或截断密文放行。

此修订表示配置持久化，不等于SMTP/TLS/SMS协议已核准、地址合法可达或消息已送达；通道能力和真实外部动作继续沿通知投递契约。共享发件配置不伪造cultureId走SC045/046审批，也不将实验室规则凭据复制为各LAB单例。

## 3. 不增平行业务表的请求证据

配置写入幂等使用alarm_config_revision；处理使用record.handle_request_id/hash且不可覆盖；外部重发使用attempt.request_key/hash。站内批量已读/监控应用编排等无独立动作表的请求复用alarm_event：source_module=M09、source_object_kind=COMMAND、source_object_id=当前用户ID、source_version=规范版本1、source_event_id=接口编码+用户ID+requestId、event_kind=BUSINESS、rule_key/condition_key=NULL；只允许内部命令处理器创建，不可经INT01外部伪造M09身份。

CommandReceipt={schemaVersion:1,canonicalVersion:1,commandKind:READ_NOTIFICATIONS/RECONCILE_REQUEST/MONITOR_APPLY,actor:Actor,requestId:string,requestHash:64hex,input:{context:SELF/ADMIN|null,items:[{notifyId,expectedVersion}],deliveryId:string|null,policyId:string|null,revisionId:string|null,reason:string|null}}。CommandResult={outcome:APPLIED/UNCHANGED/UNKNOWN,items:[{notifyId,outcome:READ/ALREADY_READ,readTime:ISO,version:string}],deliveryId:string|null,version:string|null}。这类事件不进入告警触发路由，不创建告警或发给自己。

同命令收件与批量已读在一事务完成，重复同键hash返回commandResult；异hash冲突。V1站内历史首次标读用COALESCE(row_version,0)做CAS，新版本=1；原已读历史保留read_time，未知原读时间不能补成当前“首次阅读”。V1告警处理身份不明不可用此方式越权升级，须身份核准后操作。

## 4. 核心事务与故障边界

| 事务 | 加锁/唯一键 | 提交内容 | 故障处理 |
| --- | --- | --- | --- |
| T01收件 | 源唯一键 | immutable event RECEIVED | 同源异内容409；上游只认已持久化ACK |
| T02告警应用 | event租约token＋condition_key runtime行锁 | 水位、alarm周期、接收人、首轮delivery、event APPLIED同事务 | 回滚不留孤立告警；重放依唯一键返回原周期 |
| T03到期轮次 | runtime CAS＋条件/处理/资格重验 | rounds_created+1、delivery唯一键、next_round_at | 单轮失败不得跳过轮数，不能高并发突破次数上限 |
| T04人工处理 | record＋runtime固定锁顺序 | 处理信息、STOPPED、尚未发送delivery取消 | 已调用外部的attempt保留，结束后如实记录 |
| T05站内投递 | delivery lease/CAS＋notification.delivery_id唯一 | 一封消息与delivery成功同事务 | 重试不新增消息；read与handle相互独立 |
| T06外部投递 | delivery lease/token＋attempt序号 | 先写INVOKING提交，事务外调用，再写结果 | 崩溃UNKNOWN查单；不持有数据库事务等待网络 |
| T07配置生效 | scope串行锁＋baseRevision CAS | 完整集合及revision、修改通知event同事务 | 若需跨M06只持久化候选再交付，不跨服务事务 |

固定锁顺序event→runtime→record→delivery，配置scope锁独立；发送完成只锁本delivery避免反向拿runtime死锁。先读取版本不能代替条件UPDATE/行锁。没有外键不等于忽略逻辑完整性，任一关联失效阻断本次写入而不是删来源修复。源当前版本迟到变化保留历史事实；设备命令回执引用原命令，不以最新成功命令覆盖旧UNKNOWN。


## 2026-09-11审阅收尾衔接

当前技术补充见[审阅收尾准入与恢复契约.md](审阅收尾准入与恢复契约.md)；完整物理结构以[审阅收尾字典](审阅收尾完整字段字典.md)及该字典链接的最新DDL为准。本文保留此前版本设计，冲突处按该补充执行。实施前必须完成领域实现、隔离迁移和对应CLOSE验收，不代表现已运行。

## T9-R2 M03状态消费

Change.state严格消费M03七态；M07流程/步骤IN_PROGRESS/COMPLETED不得进入该字段。RuntimeFact与审批交付身份见[T9交接核对](../00-跨模块审阅收尾/history/review/T9-身份状态模板审批交接核对.md)。

## T9-R3 告警事实与投递冻结

源事件、Fact/QuantityRef/CommandEvidence、投递状态和外部查单边界见[T9交接核对](../00-跨模块审阅收尾/history/review/T9-结果命令运行告警投递交接核对.md#4-源事件--m09告警与投递)。
