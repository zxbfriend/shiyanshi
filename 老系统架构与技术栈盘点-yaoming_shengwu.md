# 老系统（yaoming_shengwu）架构、技术栈、模块与模块关系盘点

整理时间：2026-10-01。对象：`D:\Code\zhixianweilai\yaoming_shengwu`（老系统，只读）。

> **性质与层级**：本文是**只读盘点（SUPPORTING）**，用于解释新系统某些口径的来历，**不作为新系统的设计依据、契约来源或表结构来源**。与 `docs/README.md` 指定的 CURRENT 入口或模块现行契约冲突时，一律以新系统现行文档为准。
> **证据口径**：结论均可复算，出处见文末「证据索引」。文中**不含任何真实密钥、口令、连接串、设备序列号或私钥**（老 `application-dev.yml` 内确有这些，一律只描述键名结构、不抄值）。
> **范围口径**：老系统的业务规则哪些可继承、哪些必须重判，仍按各模块契约与 `需求澄清决策记录.md` 现行轮次办。本文只回答「老系统是怎么搭的」，不回答「新系统应该怎么做」。

---

## 一、一句话结论

老系统是一个 **RuoYi 风格的 Java 17 + Spring Boot 4 单体多模块应用**：一个后端进程（`futurefab-admin`，8080）承载全部业务，**没有 Spring Cloud、没有 Nacos、没有网关、没有 Seata**；前端处于**双轨迁移中**（旧 `futurefab-ui` Element Plus → 新 `futurefab-frontend` pnpm/lerna/nx + ant-design-vue）；设备侧集成靠**两个方向干净的客户端模块**（SDMS HTTP、Windows 命名管道）加**5 个 Spring `@Scheduled` 轮询任务**；数据分两个 schema——应用库 `ymsw` 与设备中间库 `iv_cdp_16_2_uat`，**应用对中间库只读**。

新系统是微服务化的另一起点（Spring Cloud + auth/gateway/monitor/api 拆分），**不要把老系统的模块边界当成新系统的服务边界**。

---

## 二、总体形态：单体多模块，不是微服务

| 维度 | 老系统 `yaoming_shengwu` | 新系统 `yaoming-cloud` |
|---|---|---|
| 坐标与版本 | `com.futurefab:futurefab:3.9.2` | 同名体系，`3.6.8` |
| Spring Boot | 4.0.7 | 4.0.6 |
| Spring Cloud | **无（全仓 pom 零命中）** | 有（2025.1.1 + Alibaba） |
| 注册/配置中心 | 无 | Nacos |
| 网关 | 无 | `futurefab-gateway` |
| 分布式事务 | 无（本地事务） | Seata |
| 独立认证服务 | 无（认证在 `futurefab-framework` 内） | `futurefab-auth` |
| 可运行进程 | `futurefab-admin`(8080) 单进程 + `futurefab-mock-server`(9080) 可选 | 多服务 |
| 监控 | `futurefab-quartz` 调度台 + `/monitor` 控制器 | `futurefab-monitor` |

**含义**：老系统的全部「模块」都是 **Maven 编译期模块**，运行期在同一个 JVM、同一个数据源里。它的模块划分反映的是**代码分层**，不是**部署单元**。

---

## 三、技术栈版本表

| 类别 | 组件 | 版本 | 备注 |
|---|---|---|---|
| 语言/运行时 | Java | 17 | |
| 框架 | Spring Boot | 4.0.7 | 用 `spring-boot-starter-webmvc` 新命名 |
| 持久层 | MyBatis Spring Boot Starter | 4.0.1 | **纯 XML**，domain 无 `@TableName`/JPA 注解，表名只能从 mapper XML 取证 |
| 分页 | PageHelper Spring Boot Starter | 4.1.0 | |
| 连接池 | Druid | 1.2.28 | `druid-spring-boot-4-starter` |
| JSON | fastjson2 | 2.0.62 | |
| 令牌 | jjwt | 0.12.7 | JWT 只作载体，会话实体在 Redis（见第九节） |
| 接口文档 | springdoc-openapi | 3.0.3 | |
| 本地调用 | JNA | 5.19.1 | 命名管道客户端依赖（`kernel32` CreateFile/ReadFile/WriteFile） |
| 服务器指标 | oshi-core | — | `/monitor/server` |
| 调度 | Spring `@Scheduled`（业务）＋ Quartz（通用调度台） | — | 见第八节 |
| 缓存/会话 | Redis | — | |
| SSO | `spring-security-saml2-service-provider` | — | Azure AD 登录，条件装配 |
| 其它 | kaptcha、velocity、poi、commons-io、jaxb-api、yauaa | — | RuoYi 遗产 |

前端技术栈见第六节。

---

## 四、后端 8 个 Maven 模块与依赖方向

```
                    futurefab-common  ←─┬─ futurefab-sdms-client
                                        ├─ futurefab-namedpipe-client
                                        ├─ futurefab-quartz
                                        └─ futurefab-system ─┐
                                                             ├─ futurefab-framework ─── futurefab-admin
                      futurefab-quartz ──────────────────────┘                              │
  futurefab-mock-server（独立可执行 jar，零内部依赖）
```

| 模块 | 内部依赖 | 职责 |
|---|---|---|
| `futurefab-common` | 无 | 注解（`@DataScope`/`@Log`/`@Anonymous`）、工具、基础 domain、异常、响应外壳 |
| `futurefab-system` | common、**sdms-client**、**namedpipe-client** | 全部业务：Controller／Service／Mapper／XML |
| `futurefab-framework` | **system** ＋ SAML2 provider | Spring Security 配置、JWT 过滤器、AOP 切面、Token/登录服务 |
| `futurefab-admin` | framework、quartz | **唯一 Web 启动入口**（8080），系统管理/监控 Controller 在此 |
| `futurefab-quartz` | common ＋ starter-quartz | 数据库驱动的通用调度台（`sys_job` CRUD ＋ 反射调用） |
| `futurefab-sdms-client` | common | SDMS HTTP 客户端（下单、结果查询、设备校验、健康检查） |
| `futurefab-namedpipe-client` | common（**不依赖 system**） | Windows 命名管道客户端，按设备分 5 族服务 |
| `futurefab-mock-server` | 无 | 独立桩服务（9080），本地联调用 |

**老系统唯一值得原样继承的结构性约束**：两个客户端模块只依赖 `common`、**不碰数据库**，设备凭证（`serialNumber`／`privateKey`）由调用方从 `lab_communication`／`lab_detector` 读出后作参数传入。依赖单向 `system → client`，无反向、无环。

**明显的类型不安全点**：`NamedPipeRouter.resolveService(String detectType)` 返回 **`Object`**，调用方必须强转到 5 族接口各自的方法签名（`DetDeviceDispatchServiceImpl` 内有十余处强转）；而 `NamedPipeResultFetchTask` 又**绕过 Router 直接注入 `IBgaNamedPipeService`**。Router 抽象不完整、两套取数路径并存。

---

## 五、业务域划分（`futurefab-system` 内部）

体量：Controller ≈107 个 `@RestController`、service 接口 97、service 实现 104、Mapper 接口 98、mapper XML 98、domain 190（entity 94／dto 40／vo 51）。

mapper XML 按域分 8 个子目录：`lab/30、system/23、detect/15、resource/12、device/9、alarm/4、process/3、smp/2`。

| 业务域 | 路由前缀 | 主要表 |
|---|---|---|
| 实验室与台位资产 | `/lab`（27 个 Controller，最大域） | `lab_lab`、`lab_detector`、`lab_detector_item_config`、`lab_communication`、`lab_workflow_node`、`lab_printer`、`lab_relay`、`lab_sound_alarm`、`lab_status_alarm_config`、`lab_offline_alarm_config` |
| 消耗品／培养基／容器 | 并入 `/lab`、`/resource` | `bottle_config`、`feed_medium`、`liquid_bag`、`calibration_object`、`consumable_master`、`consumption_rule` |
| 设备型号库 | `/device`（9） | `dev_detector_model`、`dev_detector_item`、`dev_analyzer_model`、`dev_bench_reactor`、`dev_integrated_reactor`、`dev_air_pump_model`、`dev_floor_scale_model`、`dev_peristaltic_pump_model`、`dev_culture_container_spec` |
| 样品／检测／结果／签批 | `/detect`（12＋3） | `det_sample`、`det_sample_item`、`det_sample_id_history`、`det_result`、`det_result_item`、`det_result_sign_record`、`det_approval_assignee`、`det_approval_record`、`det_exception_note`、`det_ccpd_upload_log`、`det_print_export_log`、`det_dispatch_log`、`lab_detection_rule` |
| 资源：项目／批次／培养 | `/resource`（12） | `res_project(_lab/_leader/_member/_tag)`、`res_batch*`、`res_culture*` |
| 告警 | `/alarm`（4） | `alarm_record`、`alarm_notify_rule`、`alarm_notify_receiver`、`alarm_mail_config` |
| 工艺／工作流 | `/process`（1） | `workflow_node`、`workflow_step`、`workflow_subflow` |
| 权限／组织／场地 | `/smp`（6） | `sys_group(_leader/_member)`、`sys_user_lab`、`sys_venue`、`sys_notification` |
| 系统／字典／日志 | `/system`（11，在 admin） | `sys_user/role/menu/dept/post/dict_type/dict_data/config/notice/oper_log/logininfor/data_change_log/user_password_history` |
| 监控 | `/monitor`（8，admin＋quartz） | `sys_job`、`sys_job_log` |

其余前缀：`/namedpipe`（6，管道侧自暴露接口）、`/sdms-app`、`/sdms`、`/auth`、`/common`、`/test`、`/`（首页）。

> 注意：`/lab` 一个前缀装了 27 个 Controller，把实验室、台位、通讯、打印机、继电器、声光告警、离线告警配置**全塞在同一域**；而 `DetWorkbenchController`、`DetRecordController`、`DetApprovalRecordController` 三个类**没有类级 `@RequestMapping`**，路由写在方法上。老系统的域边界不等于新系统的模块边界（新系统按 M01—M09 划分）。

---

## 六、检测数据主线与双通道取数

老系统的核心链路（12 张表，与 `docs/实验室检测设备配置与样品检测流程.md` 一致）：

- **配置侧 5 张**：`dev_detector_model`（型号）＋ `dev_detector_item`（检项库，靠 `detect_type` 字典值对齐、**无物理外键**）→ `lab_detector`（实例化到某实验室）→ `lab_detector_item_config`（按台启用的检项，`enabled='0'` 才是开通）＋ `lab_communication`（按台的通讯方式）。
- **检测侧 7 张**：`res_project → res_batch → res_culture → det_sample → det_sample_item`，结果 `det_result → det_result_item`。
- **状态机**：`det_sample.queue_status` 与 `det_result.result_status` 共用一套字典（idle → stored → pending → testing → tested → uploaded → signed → reviewed，另有 voided/timeout/exception/cancelled）。

**取数口由「这台设备配的是哪条通讯方式」决定，不由型号决定**（`lab_communication.communication_type` 是**按设备实例**的属性）：

| 通道 | 实现 | 触发 | 一级路由 | 二级路由 |
|---|---|---|---|---|
| SDMS HTTP | `SDMSResultFetchTask` → `ISDMSClientService.getOrderResult()` | cron 每 1 分钟 | 只处理 `communication_type = "HTTP"` 的记录（不匹配直接 return） | `detect_type` ∈ BGA／OSMO1／OSMO2／OSMO3／CedexBio／CedexBioHT（**Vicell 在 HTTP 分支显式抛异常**） |
| Windows 命名管道 | `NamedPipeResultFetchTask` → 读中间表／`refreshResult()` | cron 每 3 分钟 | 非 HTTP 记录 | 按 `detect_type` 选 5 族管道服务 |

两条链路**互斥、各写各的 SQL**，都绕过 `IDetResultService` 直接操作 `det_result`／`det_result_item` 等 Mapper。这与第二十六轮登记口径一致：**「管道查库、HTTP 调接口」，逐台看配置，同一个型号换通道就换一套匹配值**。

---

## 七、外部系统集成点

| 集成 | 模块 | 接口 | 调用方 |
|---|---|---|---|
| SDMS 平台 | `futurefab-sdms-client` | `ISDMSClientService` 5 个方法：`sendBgaOrder`、`sendOsmoOrder`、`sendCedexBioOrder`、`validEqu`、`getOrderResult` | `DetDeviceDispatchServiceImpl`（三种下单）、`SDMSResultFetchTask`（取结果）、`SdmsHttpHealthCheckAdapter`、自暴露的 `SDMSClientController` |
| 命名管道 | `futurefab-namedpipe-client` | 5 族：`IBgaNamedPipeService`、`IOsmoNamedPipeService`、`IOsmo2NamedPipeService`、`ICedexOrderNamedPipeService`、`IVicellNamedPipeService`（另有遗留 `ICedexNamedPipeService`） | 唯一正常消费者是 `DetDeviceDispatchServiceImpl`（经 `NamedPipeRouter`）；`NamedPipeResultFetchTask` 绕过 Router 直连 BGA |
| 健康检查 | 两侧各一 Adapter | 共同实现 `DeviceCommunicationHealthAdapter` SPI，由 `IDeviceCommunicationHealthService` 聚合 | — |
| CCPD 上传／打印导出 | `futurefab-system` | 落 `det_ccpd_upload_log`、`det_print_export_log` | — |
| 邮件／短信告警 | `futurefab-system` | `alarm_mail_config`、`alarm_notify_rule/receiver` | — |

> 本文只登记**接口的存在与调用方向**。老系统 `application-dev.yml` 与 `docs/接口测试入参出参(2).txt` 中的真实凭据（设备 `serialNumber`／`privateKey`、`app-key`／`app-secret`、内网平台 IP）**一律不抄入新系统任何文档**；新系统对应参数缺失时按 AGENTS 规则记 `BLOCKED_INPUT`。

---

## 八、定时任务：Quartz 是空壳，业务全在 `@Scheduled`

- `futurefab-quartz` 里**只有一个演示类** `RyTask`（`@Component("ryTask")`，三个 println 方法，无 cron）。Quartz 本身是**数据库驱动**的通用调度台：cron 与 `invokeTarget` 存 `sys_job`，由 `/monitor/job` CRUD，`ScheduleUtils`／`JobInvokeUtil` 反射调用。仓库内 `sql/*.sql` **没有 seed 任何业务 job**。
- **全部 5 个业务定时任务都在 `futurefab-system` 的 `service/impl` 包里**，由 `config/SchedulerConfig` 的 `@EnableScheduling` 驱动，专用线程池 `detectionTaskScheduler` 固定 4 线程：

| 类 | 触发 | 配置键（默认值） | 职责 |
|---|---|---|---|
| `SDMSResultFetchTask` | cron | `sdms.result.fetch.cron`（`0 */1 * * * ?`） | 轮询 SDMS 取结果回写 |
| `NamedPipeResultFetchTask` | cron | `namedpipe.result.fetch.cron`（`0 */3 * * * ?`） | 轮询管道结果回写 |
| `OfflineDispatchRetryTask` | cron，且 `@ConditionalOnProperty` 开关 | `offline.dispatch.retry.cron`（`0 */5 * * * ?`）、`detection.offline.retry.enabled` | 离线待下发订单重试 |
| `DetectionTimeoutTask` | fixedDelay 60s／首延 5s | `detection.timeout.scan.*` | 检测超时扫描 → 告警 |
| `QueuedDetectionPromotionTask` | fixedDelay 5s／首延 5s | `detection.queue.promotion.*` | 排队检测晋升到在线设备 |

> 两个问题值得在新系统规避：**（1）** 核心编排类物理放在 `service/impl`，包名与职责不符；**（2）** 超时扫描与排队晋升都是**轮询推算**，不是事件驱动——这与第二十三、二十四轮「超时只数检测中时长、排队不设上限只展示时长」的裁决直接相关：老系统靠的就是这两条轮询，新系统若沿用轮询实现，起点仍是**我方置位的业务时刻**，不是设备回报。

---

## 九、认证、会话与数据权限

**双登录链路，最终签发同一种令牌：**

- 账号密码：`SecurityConfig`（无状态；`/login`、`/captchaImage`、`/openapi/**` 放行；`JwtAuthenticationTokenFilter` 前置）＋ `POST /login`。
- Azure AD／SAML2：`AadSecurityConfig` 以 `@ConditionalOnProperty(prefix="smp.aad", name="enabled")` **条件装配**，手工装配 `RelyingPartyRegistration`；入口 `/auth/aad` 的 `/status`、`/login`、`/token`；SAML 断言成功后用**一次性 code ＋ Redis 换 JWT**（`AadLoginService.createCode`／`exchangeToken`）。

**令牌实质**：`TokenService` 用 jjwt 作**载体**，payload 只放一个 UUID，真实 `LoginUser` 存在 **Redis**。是「JWT ＋ Redis 会话」混合，**不是自包含 JWT**——改会话有效期靠 Redis TTL 与 `token.expireTime`，`token.singleDeviceLogin` 控制单设备登录。

**数据权限两套并行（重要）**：

1. **若依式 `@DataScope`（部门维度）**：切面用 `@Before` 拼 SQL 片段。**全仓只有 5 处使用，且全在 `SysDeptServiceImpl`(1)、`SysRoleServiceImpl`(1)、`SysUserServiceImpl`(3)** —— 只覆盖用户／角色／部门，**业务表完全没接入**。
2. **自建 SMP 域权限（实验室／项目／批次／培养维度）**：`SmpPermissionService`（`resolveScope`、`canView/Manage{Project,Batch,Culture}`、`checkApprovalAssigneeScope`）、`LabPermissionScopeApplier`（`applyViewLabScope`、`checkView/Operate/ManageLab`）、`LabAuthorizationService`，配合跨表查询 `mapper/smp/SmpPermissionQueryMapper.xml`。**这才是业务数据权限的真正实现**。

另有 `@Anonymous`（配合 `PermitAllUrlProperties` 动态放行）、`@Log`、`@DataLog`。

> **避坑**：只看 `@DataScope` 会得出「老系统数据权限形同虚设」的错误结论；老系统的业务可见范围靠第 2 套自建体系。新系统的 `data_purview`／字典表数据权限口径**不得从 `@DataScope` 反推**。

---

## 十、耦合实况：跨模块干净，跨业务域严重

| 层次 | 结论 | 证据 |
|---|---|---|
| **跨 Maven 模块** | **干净**：`import com.futurefab.system.mapper` 在 admin／framework／quartz／common／两个 client 中**零命中**；framework 只调 system 的 **service 接口**（方向合法） | grep 复算 |
| **system 内部跨域** | **严重穿透**：`DetSampleServiceImpl` 一个类注入 `DevDetectorMapper`＋`LabDetectorMapper`＋`LabDetectorItemConfigMapper`＋`ResCultureMapper`（detect→device/lab/resource 三域）；`NamedPipeResultFetchTask`／`SDMSResultFetchTask` 各直连 4—5 个 Mapper；`DetWorkbenchServiceImpl` 注入 8 个 Mapper；`LabIntegratedReactorServiceImpl` 跨 lab/device/告警直引 4 个 Mapper；`ResCultureController` **全仓唯一**跳过 service 直接用 Mapper |
| **SQL 层** | `mapper/detect/DetResultMapper.xml` 直接 JOIN `alarm_record` 与 4 张 `cdp_testing_*task*` 外部表；`mapper/alarm/AlarmRecordMapper.xml` JOIN `res_project_member`、`sys_user_lab` |

> **含义**：老系统的「表所有权」在 SQL 层就被打穿，**无法按前缀机械拆分成服务**。新系统拆 M01—M09 边界时，不能以老系统的 JOIN 关系为参照；跨模块必须走接口或 Port，不得复用老系统的「Service 直引他域 Mapper」写法。

---

## 十一、数据库形态：两个 schema，中间库只读

| schema | 内容 | 应用侧权限 |
|---|---|---|
| `ymsw` | 应用主库，约 98 张表；前缀分布 `sys_`28／`lab_`24／`det_`12／`res_`11／`dev_`9／`alarm_`4／`workflow_`3／无前缀 7 | 读写 |
| `iv_cdp_16_2_uat` | 设备中间库，22 张 `cdp_` 表（`cdp_testing_*order`／`*task*`／`*taskresult`），由工业机上的**本地子系统**写入 | **只读**——全仓 `cdp_` 表**零 INSERT／UPDATE** |

`sql/` 目录是**日期化快照＋增量**的形态（如 `20260616.sql`、`20260720/20260720_lab_communication.sql`），并明确 v3 起「不得合并回历史基线 SQL」。

> **对新系统的硬约束**：这些 SQL 属历史/迁移材料，**不得进入新系统安装链**（新库只按 `docs/开发基线/README.md` 的 01/02/03 三步）。老系统「应用只读中间库」这一条**方向可继承**：新系统同样不得写设备中间表。

---

## 十二、前端双轨与迁移关系

| | 旧 `futurefab-ui` | 新 `futurefab-frontend` |
|---|---|---|
| 形态 | 单包 | pnpm workspace ＋ lerna ＋ nx，**10 个 package** |
| 组件库 | Element Plus 2.14.4 | ant-design-vue 4.27.11 ＋ vxe-table 2.86.4（走公司 `@futurefab/*` 镜像源） |
| 构建 | Vite 6.4.2，dev 端口 **82** | rolldown-vite 7.1.9，Node `^20.19.0 \|\| >=22.12.0`、pnpm 8.6.2 |
| 其它 | Vue 3.5.35、Pinia 3.0.4、axios | Vue 3.5.13、biome、vitest |
| 状态 | 被迁移方 | 迁移目标 |

新前端的包结构：`portal`（装配入口）＋ 三个业务 app（`app-smp-settings` 系统设置与监控、`app-smp-data` 数据管理、`app-smp-lab` 实验室工作空间）＋ `lib-smp-base` ＋ 四个 sdk（`sdk-smp-api`／`sdk-smp-common`／`sdk-smp-static-files`／`sdk-smp-stores`）＋ `sdk-language`。

**装配方式**：`@futurefab/ui-platform` 的 `AppManager` 做**同 SPA 路由挂载**，**不是 qiankun、不是 iframe**。README 原文声明「参照 fabsyn-frontend 的公司 UI Framework 架构，迁移旧 futurefab-ui 的菜单和接口，业务代码仅在本项目实施，旧前端与新前端共用后端、独立启动」，当前注册 107 个业务及辅助入口，覆盖菜单清单中 69 个菜单标识。

> 老系统前端仍在迁移途中，**两套前端并存**。新系统的 `futurefab-frontend/` 是独立起点，不要从老 `futurefab-ui` 搬页面。另注：本仓库 `AGENTS.md` 写「前端位于 `futurefab-ui/`」，而新仓库实际目录是 **`futurefab-frontend/`**，属文档陈旧，已登记为待修条目。

---

## 十三、对新系统的启示

**可以继承（结构与方向）**

1. `client 模块只依赖 common、不碰 DB、凭证由调用方传参` —— 老系统唯一干净的依赖约束，新系统 `futurefab-sdms-client`／`futurefab-namedpipe-client` 应保持。
2. `cdp_` 设备中间表**只读**的方向性。
3. 取数通道**按设备实例配置**路由（一级 `communication_type`、二级 `detect_type`），与第二十六轮登记一致。
4. 管道服务的**按型号分包**思路（BGA／Osmo／Osmo2／CedexOrder／Vicell 五族）。

**不得继承（老系统缺陷）**

1. `NamedPipeRouter.resolveService` 返回 `Object` ＋ 调用方强转，以及取数任务绕过 Router 直连具体服务 —— 抽象不完整，新系统应收敛为带类型的派发接口。
2. 两条结果回写链路各写各的 SQL、绕过 `IDetResultService`；`DetResultMapper.xml` 跨域 JOIN `alarm_record` 与外部 `cdp_` 表。
3. 业务定时任务物理塞在 `service/impl`；Quartz 只做通用调度台却无 seed，容易误以为业务调度在 Quartz 里。
4. 数据权限两套并行（`@DataScope` 只覆盖用户/角色/部门）。
5. `det_*` 结果侧把设备编号直接当中文名写库（Cedex 把 `938` 显示成 "938"），根因是**没有 join 订单表**——链路上编号↔项目名的配对本来就存在（订单侧下发时自己写下去的），属老系统实现缺陷，**不是数据缺口**，已在第二十六轮更正。
6. 把检项编码配成人类易读名（`pH`／`Glucose`）而非设备原文，导致回传失配；失配后又用「条数凑满即完成」掩盖 —— 第十八轮已明确不得继承。

**需要重判（不能照搬）**

- 老系统的域划分（`/lab` 装 27 个 Controller）≠ 新系统 M01—M09 边界。
- 老系统的超时扫描／排队晋升算法是轮询推算，新系统的超时窗口口径按第二十三轮（只数「检测中」时长）、排队按第二十四轮（不设上限、只展示排队时长）执行，**不得以老系统实现为准反推需求**。
- 老系统检项清单/单位/精度等口径来自配置与实测，新系统一律以模块契约与字典种子为准。

---

## 十四、证据索引（全部只读取证，未修改老系统任何文件）

| 主题 | 出处 |
|---|---|
| 模块清单与版本 | 老 `pom.xml`:8-9（`futurefab`/`3.9.2`）、:12（`futurefab.version`）、:15-30（java 17／boot 4.0.7／mybatis 4.0.1／druid 1.2.28／pagehelper 4.1.0／fastjson2 2.0.62／jjwt 0.12.7／springdoc 3.0.3／jna 5.19.1）、:187-194（8 个 `<module>`）；全仓 `pom.xml` 中 `spring-cloud\|nacos\|seata` grep 命中 **0** |
| 依赖方向 | 各模块 `pom.xml` 的 `<dependencies>`：`futurefab-system/pom.xml`:21-41（含两个 client）、`futurefab-framework/pom.xml`:32-36、:62-66、`futurefab-admin/pom.xml`:39-48、`futurefab-sdms-client/pom.xml`:21-24、`futurefab-namedpipe-client/pom.xml`:22-25、`futurefab-mock-server/pom.xml`:18-53 |
| 端口 | `futurefab-admin/src/main/resources/application-dev.yml`:23（8080）、`futurefab-mock-server/src/main/resources/application.yml`:4（9080）、`futurefab-ui/vite.config.js`:50（82） |
| Controller 前缀分布 | 全仓 `@RestController` 文件 grep 复算（≈107 个类，不含异常处理器） |
| 域内跨 Mapper 直连 | `service/impl/DetSampleServiceImpl.java`:25-28、`NamedPipeResultFetchTask.java`:14-18、`SDMSResultFetchTask.java`:15-18、`controller/ResCultureController.java`:12、`service/impl/LabIntegratedReactorServiceImpl.java`:23-29 |
| SQL 跨域 JOIN | `futurefab-system/src/main/resources/mapper/detect/DetResultMapper.xml`:370-470（含 `cdp_testing_*`）、`mapper/alarm/AlarmRecordMapper.xml` |
| 双通道取数 | `SDMSResultFetchTask.java`:194-206（`if (!"HTTP".equals(comm.getCommunicationType())) return;`）、:213（`getOrderResult`）、:270-273（按 `testingNo` 匹配、`name` 当中文名）；`DetDeviceDispatchServiceImpl.java`:164-185（路由）、:671-685（HTTP 分支，Vicell 抛异常）、:722-737（管道分支）；`NamedPipeResultFetchTask.java`:46-51、:85（直连 BGA）、:163-171 |
| Router 反模式 | `system/dispatch/NamedPipeRouter.java`:54（`buildEndpoint`）、:65（`public Object resolveService(String detectType)`，javadoc 自陈「调用方需 cast」） |
| 定时任务 | `config/SchedulerConfig.java`:18-19、:26-30；5 个 `@Scheduled` 命中行见第八节；`futurefab-quartz/.../task/RyTask.java`:11 |
| 认证与权限 | `framework/config/SecurityConfig.java`:86-118、`framework/web/service/TokenService.java`:36、:41-49、:129、`framework/config/AadSecurityConfig.java`:34、:51-135、`framework/web/service/AadLoginService.java`:61、:96、:171、`admin/.../SysLoginController.java`:57、`admin/.../SysAadLoginController.java`:25、:42、:55、:79；`@DataScope` 5 处使用（`SysDeptServiceImpl`:51、`SysRoleServiceImpl`:63、`SysUserServiceImpl`:100/123/146）、`system/service/SmpPermissionService.java`:11、`service/LabPermissionScopeApplier.java`:18、`mapper/smp/SmpPermissionQueryMapper.xml` |
| 业务主线表与状态机 | `docs/实验室检测设备配置与样品检测流程.md`（老仓根目录，146 行） |
| schema 与只读方向 | 老仓 `sql/` 目录、`docs/iv_cdp_16_2_uat(1).sql`；全仓 `cdp_` 表无 INSERT/UPDATE |
| 前端双轨 | `futurefab-ui/package.json`:23/26/33/34/53；`futurefab-frontend/package.json`:40/54/82/84/104/106、`README.md`:1-12、`packages/`（10 个包）、`pnpm-workspace.yaml`、`lerna.json`、`nx.json` |

---

## 十五、本文未覆盖事项

- 未运行老系统任何进程、未连库、未联调设备；本文全部结论为**源码/配置/DDL 级只读证据**。
- 未盘点 `docs/`、`plans/`、`redesign/` 下的老系统设计文档内容（只用了 `实验室检测设备配置与样品检测流程.md`）。
- 未核对老系统前端页面与新系统前端页面的对应关系；未统计各接口的请求/响应字段。
- 老系统的业务规则正确性一律未评判：本文只登记「它是怎么写的」，不登记「它是对的」。
