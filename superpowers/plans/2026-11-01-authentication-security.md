# 认证安全增强实施计划

> For agentic workers: 使用 subagent-driven-development，按文件归属实施及复审。用户已明确授权直接开发，不重复请求计划批准；不提交、不推送、不操作共享数据库。

**Goal:** 实现验证码防破解、密码重置/现有密码策略修改二次认证、本人登录历史反馈和匿名认证失败统一提示。
**Architecture:** 沿auth/system与Redis/MySQL边界，沿用现有Body版本密码写。操作凭证与业务回执同事务，登录快照与激活同事务。
**Tech Stack:** Java17/Spring Boot4/MyBatis/MySQL/Redis；Vue3/TypeScript/pnpm8.6.2。
**Spec:** [认证安全增强设计](../../详细设计/01-系统管理/认证安全增强设计.md)。

## Global Constraints

- 已确认前端system-user/password-validity.vue及SDK和后端savePasswordValidity存在，故API09纳入范围。
- 角色权限不加二次认证。保留工作区无关修改；本次在当前cloud工作区按文件划分，避免复制丢失未提交设计，不创建或切换工作树。
- AAD真实能力缺失失败关闭并记录BLOCKED_EXTERNAL；无客户参数不伪造联调。
- 无共享数据库写授权；提供并校验目标DDL/基线同步及独立升级脚本，运行需另行授权。

## Review Focus

同凭证并发只产生一次效果；取消/提交竞争不能覆盖成功；失去Redis不能伪造已完成；换会话不能复用验证；同毫秒与登录重试不能改写快照。均在各任务增加行为测试。

## Task 1 验证码及匿名失败边界

- [x] 在auth/gateway相关测试先覆盖原子消费、归属不符、限流、Redis故障、匿名失败一致与不影响解锁；运行观察失败。
- [x] 公共Redis验证码/限流能力只被auth和gateway消费；验证码绑定服务端Cookie，可信来源默认remoteAddr，信任代理显式配置；保留现有开关及独立限流。
- [x] 修改auth匿名login/AAD失败边界，真实内部失败保留，禁止全局吞异常。
- [x] 定向auth/gateway -am测试，记录用例数和退出码。

## Task 2 登录历史反馈

- [x] 新增LoginSecuritySnapshotMapper及服务、InternalAuth激活与失败审计行为测试，验证首次NULL/重试/跨会话隔离。
- [x] 新建快照承载、原激活事务固定前次时刻；提供GET /system/user/profile/loginSecurity，只取可信当前会话。
- [x] 输出所需DDL片段供主代理统一基线同步；不单独修改基线生成物。
- [x] 定向测试并检查Mapper映射。

## Task 3 敏感操作二次认证

- [x] 增加SensitiveOperationService/Mapper/Controller/DTO及行为测试，覆盖绑定/过期/重复/撤销与原结果恢复。
- [x] 在PasswordManagementApplicationServiceImpl内包装resetUserPassword/savePasswordValidity，保留原资格校验，新增operationProof仅从Header注入，不采信Body。
- [x] 实现prepare/verify/result/cancel/status对应契约，本地重新校验操作者密码；AAD未核准分支明确失败关闭。
- [x] 新增操作记录DDL，统一同步M01目标SQL、安装/核验及来源哈希；不执行实库。
- [x] 正向旧密码写测试补真实有效二次凭证依赖，不能放宽缺凭证检查。

## Task 4 前端

- [x] SDK增加prepare/verify/cancel/status/result及本人反馈查询，reset/策略写携X-Operation-Proof。
- [x] 复用二次认证弹窗与内存意图状态；角色权限不动；响应未知查原requestId，取消/关闭清敏感数据。
- [x] 门户登录后显示本人前次成功/失败时间与重试；匿名错误/429提示按后端契约。
- [x] Vitest行为测试先失败再实现；pnpm8.6.2定向与必要全量/类型构建验证。

## Task 5 集成及复审

- [x] 汇总后端目标测试及前端测试，记录原进程退出码；需要时运行更广范围，真实失败不得隐藏。
- [x] 独立审查权限、版本、回执事务、失效与敏感日志；修复发现的问题。
- [x] 检查工作树差异、静态文档及SQL一致性。浏览器仅在已授权本机环境可用且无需改共享库时验收，否则标NOT_VERIFIED/BLOCKED_DEPLOY。

## 执行记录

- 2026-11-01：计划建立，已确认密码策略编辑功能存在。各任务并行不得修改同一文件；公共错误码、DDL及主设计由主代理维护。
- 2026-11-01：本地账号任务1—4源码已接线，二次认证仅API07/API09；新增两表及日志DDL/安装基线/哈希同步，未操作目标库。任务5独立复审三项已修正，最终定向后端1064例、前端93例通过（原退出码均0），离线基线3例通过；相关3包类型及生产构建通过。
- 更大范围未通过：前端全量4238例有39失败；后端全测试在feeding-gateway临时文件清理错误处中止，原退出码1。HTTP/浏览器NOT_VERIFIED，运行BLOCKED_DEPLOY；AAD重新认证BLOCKED_EXTERNAL，普通AAD旧成功入口快照尚未统一接线。详见[开发验收记录](../../详细设计/01-系统管理/history/review/2026-11-01-认证安全增强开发验收.md)。
- 方法限制：已实际观察核心旧行为的RED并翻绿，但验证码新增用例未全部在实现前单独跑RED，不宣称全程严格TDD；真实Redis并发和H2事务证据单独记录，不冒充目标数据库或浏览器。
