# 检测后端统一生产执行链

依据用户2026-10-31最终要求：删除后端模拟专用执行分支，开发及验收按生产流程执行；外部futurefab-mock-server只替代设备提供生产协议数据，不在业务后端区分模拟任务并放宽规则。不直接修改数据库、不提交、不推送。

## 改动范围

- 删除M05MockObservationProcessor、M05MockObservationVerifier、M05MockNamedPipeDispatchAdapter、M05MockObservationMapper及XML和专属旧链测试；删除模拟适配器Bean注册。
- 发送准备、M02通信事实读取、派发SQL和CDP候选SQL不再识别MOCK_NAMED_PIPE_V1；不将旧协议自动转换为NAMED_PIPE_V1，不给旧任务伪造生产身份。
- 删除allow-qa-dispatch字段、构造参数及Verifier放行分支；接收、自动上传、位置完成、结果展示及开始培养指标消费者统一调用生产协议核验。新增负向断言：即使旧mock开关开启、引用为QA-MOCK，也不允许旧协议发送或采集。
- UNKNOWN受控恢复取消QA-MOCK前缀限制，改为通用非空协议依据及逐派发审批引用，继续保留默认无登记拒绝、权限、来源、任务/代次、双对象版本、管理修订和审计；恢复服务回归改用生产审批引用。
- 仅保留旧模拟结果的历史只读展示解析与SQL协议识别，防止历史检测记录失去已有原文展示；该兼容不发送、不采集、不写状态、不释放位置。数据库原文不删除、不改写。
- 模拟器已有CDP生产表结构输出能力，无须新增后端替代协议。未修改外部模拟器源码及用户已有application.yml改动。

## 验证与运行边界

首轮编译发现Verifier删除布尔参数后还有3个消费者使用旧签名，已同步修正并扩大回归范围；首轮失败不记为通过。最终结果以后续日志和原Maven退出码为准。

已对确认为删除源码对应的target内旧class/XML做定向清理，避免增量构建残留已删除Bean，不清理其他临时数据。HTTP、浏览器、真实设备和现场验收未执行；当前服务与配置未更新，不能认为运行时已经不再走旧链。运行前须将原模拟专用设备配置重新核实为生产NAMED_PIPE、精确通信修订/CDP来源/单位及正式采集准入，并重启system；不回填旧任务快照，不强制释放旧RUNNING记录。

## 最终源码验证

Maven定向14类263例，Failures=0、Errors=0、Skipped=0，原始进程退出0、BUILD SUCCESS（日志.local/m05-production-only-final.log）。覆盖生产发送与旧模拟协议拒绝、正式准入、CDP接收与SQL、完整结果与不完整/冲突保护、位置完成、自动上传、跨日清理、受控UNKNOWN恢复及历史只读展示。git diff --check通过。未运行全量测试、未执行SQL、未重启服务、未浏览器或外部设备验收。当前状态IMPLEMENTED + CONTRACT_TESTED；运行BLOCKED_DEPLOY，HTTP/浏览器NOT_VERIFIED。用户安排work1执行完整运行验证，本轮不再操作页面或触发设备任务。未提交、未推送。
