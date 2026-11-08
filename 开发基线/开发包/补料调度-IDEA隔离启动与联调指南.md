# 补料调度：IDEA隔离启动与联调指南

适用工作树：`D:/project/yaoming/SMP/wt-feeding-scheduler`，分支 `codex/feeding-scheduler`。本指南依据当前Main、JUnit、Mapper及测试复验记录编写。所有参数示例仅用于TEST环境，不是现场默认值。

**本次已验证：live42暂停恢复、live43普通正常、live44超量异常安全收尾的完整隔离执行及终态HTTP/浏览器均通过。**最终分层复验为clean编译及扩大回归3044/3044、独立四模块310/310、18类隔离SQL110/110、前端5文件61/61；不重复累加重叠批次。具体快照和历史失败见第8节及联调记录。三场景通过不等于全部四阶段、完整登录部署或客户设备/现场验收。

2026-10-23本轮验证结束后，执行Main/Monitor、5839测试Vite及33087隔离MySQL均已停止，测试库与证据保留。以下是重新启动步骤，旧`execution-http.json`不表示服务仍在线；不要直接使用旧manifest访问已结束的运行。

## 1. 当前能启动到哪一层

组件验证使用JUnit；同一任务的实际TEST执行使用第10节的`M07IsolatedFixedExecutionMain`及其HTTP入口。两者均不启动整个system开发服务。

| 组件 | 入口与运行方式 | 当前隔离联调用途 |
| --- | --- | --- |
| M07业务、M02客户端、M09交接 | `futurefab-modules/futurefab-system`中的JUnit测试 | 直接创建实际Worker/Service/Mapper，隔离Controller或真实本机HTTP；SQL测试使用专用MySQL。M09按独立测试验证，不等于下面Main已接真实通知 |
| 同一任务执行与HTTP | `com.futurefab.system.service.support.m07.M07IsolatedFixedExecutionMain`，system测试classpath | 已装配生产准备Authority、claim、命令、正式采样、控制和收尾组件；可启用本次任务的查询、暂停与恢复HTTP。当前相同源码下live42暂停恢复、live43正常、live44超量异常安全收尾均已完成完整隔离执行及终态HTTP/浏览器核对 |
| Gateway | `com.futurefab.feeding.gateway.FeedingGatewayMain` | 独立Java进程；保护监听与普通命令监听可分开 |
| Monitor | `com.futurefab.feeding.monitor.FeedingMonitorMain` | 独立Java进程；读数、保护STOP和持久日志 |
| 测试设备 | 各测试的`GatewayDriver`、`TestGatewayInstallation`或Main内部`TestDevice` | 由测试入口管理；执行Main的TEST设备按命令流量和有效时间改变原始重量，不通过写任务状态/量账制造执行结果；没有必须另外启动的通用“设备模拟器服务” |
| 客户适配 | `futurefab-feeding-customer-adapter` | Gateway加载的适配库。`CustomerOpcConfigurationCheckMain`是离线配置预检，不是长期运行服务；本轮测试不安装真实客户适配配置 |
| 共享API | `futurefab-api/futurefab-api-feeding-safety` | 协议/签名/判据依赖库，无需启动 |
| 前端 | `futurefab-frontend`中的Vitest及`tests/feeding-browser/` | 窄入口复用真实任务页面/SDK，可选择首轮只读夹具或本轮LIVE_EXECUTION；仍不是完整门户登录/后端部署包 |

`M07ApprovedFixedTaskPreparation`现已实现`M07FixedTaskPreparationProvider/Authority`，由`M07ApprovedFixedPreparationConfiguration`装配；`M07ApprovedMonitorSampleQualificationProvider`也已有生产实现及配置装配。实际TEST Main已使用这些实现，缺项应按同一执行的停止覆盖、恢复及最终收尾证据跟踪，不能再写成“只有接口”。核准来源、profile、供料政策和采样角色仍须显式提供；配置schema3不代表采样身份v3。只给system替换数据库URL不能证明Nacos、其他后台任务和通知已隔离，本指南仍不启用dev主类。

## 2. IDEA与JDK准备

1. File → Open，打开工作树根`pom.xml`，作为Maven项目导入；确认分支为`codex/feeding-scheduler`。
2. Project SDK、Maven Importer及Runner均使用JDK17。本机已验证：`C:/Users/Evan Hou/AppData/Local/Programs/Java/jdk-17.0.20.1+1`。
3. Maven安装：`D:/tools/apache-maven-3.9.16-bin`。先执行下列编译，再刷新Maven依赖。
4. 创建目录`D:/project/yaoming/SMP/tmp/j17`，作为本机TEST socket目录。
5. Maven配置使用工作树根目录；JUnit使用测试所在模块目录，system测试及第10节Main使用`D:/project/yaoming/SMP/wt-feeding-scheduler/futurefab-modules/futurefab-system`。源码型契约测试按模块解析`src/...`，不要误指向另一工作树。

```powershell
Set-Location 'D:/project/yaoming/SMP/wt-feeding-scheduler'
New-Item -ItemType Directory -Force 'D:/project/yaoming/SMP/tmp/j17' | Out-Null
& 'D:/tools/apache-maven-3.9.16-bin/bin/mvn.cmd' -o -B -ntp `
  -pl futurefab-modules/futurefab-system -am test-compile
```

若本机首次缺依赖，移除`-o`并使用项目核准的依赖源。不要更改JDK版本或跳过编译错误来运行。

### JUnit运行配置的公共设置

通过测试类旁绿色按钮创建配置，再进入Run → Edit Configurations：

| 项目 | 填写内容 |
| --- | --- |
| 类型 | JUnit |
| Test kind | Class；需要调试某一个分支时使用Method |
| Classpath | 选择该测试所在Maven模块的**测试classpath**。system测试选`futurefab-modules/futurefab-system`对应IDEA模块，Monitor测试选`futurefab-feeding-monitor`；IDEA实际模块名以导入结果为准 |
| JRE | JDK17 |
| Working directory | 测试所在模块的绝对路径；system为本worktree下`futurefab-modules/futurefab-system` |
| VM options | `-Dfile.encoding=UTF-8 -Djdk.net.unixdomain.tmpdir=D:/project/yaoming/SMP/tmp/j17` |
| Environment variables | `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=D:/project/yaoming/SMP/tmp/j17` |
| Before launch | Build或Maven test-compile；不启动system dev服务 |

VM options影响父测试JVM，`JAVA_TOOL_OPTIONS`让测试创建的子JVM也继承socket目录。二者在此同值可以并存。此前HTTP回环故障来自JDK内部Unix socket临时路径，普通`java.io.tmpdir`不能替代这个专用参数。

## 3. 启动与验证顺序

按层逐个运行，不要将JUnit配置放进Compound后同时启动：进程测试会自行分配端口、创建登记和密钥，SQL测试的固定ID也不适合在同一库并行执行。

| 顺序 | IDEA配置建议名 | 测试类/模块 | 实际启动与断言 |
| --- | --- | --- | --- |
| 1 | TEST-01-首次开始与停止政策 | `M07FirstStartAdmissionPolicyTest`、`M07StopEvidenceAssemblerTest`，system | 纯/组件级政策；首次日期、停止观察资格，无外部设备 |
| 2 | TEST-02-M02签名命令 | `M02HttpDeviceCommandAdapterTest`，system | 本机HTTP夹具，M02实际客户端提交/查原命令；大ID、签名、错误响应、UNKNOWN和禁止事务内网络 |
| 3 | TEST-03-网关停止优先 | `FeedingGatewayProcessTest`，gateway | 真实GatewayMain子进程、TEST设备驱动、普通监听被阻塞时保护通路仍可响应；强杀后UNKNOWN原命令不重发 |
| 4 | TEST-04-独立监控双进程 | `FeedingMonitorProcessTest`，monitor | 自动先启动GatewayMain→登记Gateway→启动MonitorMain→登记Monitor→停止业务进度→等待保护STOP→强杀/重启Monitor→核原首期限与证据 |
| 5 | TEST-05-M07与保护通路 | `M07IndependentMonitorHttpTest`，system | 实际M07签名客户端、Gateway回环服务、MonitorMain；上下文先持久确认，再登记、进度和证据拉取 |
| 6 | TEST-06-失库与重启 | `M07PersistedContextRestartHttpTest`，system | 原context revision1→2签名ACK后注入业务Store不可用，强杀Monitor，复用原目录重启，不重送context仍读停/留证。DB失效是注入异常，不是真实MySQL停机 |
| 7 | TEST-07-续段三方交接 | `FeedingMonitorContinuationProcessTest`，monitor；`M02IndependentGatewayHttpIT`，system | 续段原身份、双ACK、激活、原M02客户端至真实回环Gateway；不借用旧段ACK |
| 8 | TEST-08-真实SQL | 第4节14类PersistenceIT，system | 新建隔离库、安装基线、真实Mapper/事务/CAS/并发；与上述HTTP/进程测试是不同验证层 |
| 9 | TEST-09-页面模型与SDK | 第6节Vitest | 状态、原因、允许动作与API请求；不接真实业务服务 |
| 10 | TEST-10-同任务实际执行 | 第10节Main，system测试classpath | 在新库中从已核准TEST任务开始，生产准备/命令/采样/控制链驱动TEST设备；自动管理回环Gateway和独立Monitor子进程 |
| 11 | TEST-11-实际任务页面 | 第10节LIVE_EXECUTION前端 | Main生成本轮manifest后再启Vite；同任务查询、暂停/恢复经真实Controller、管理守卫和SQL。不能复用首轮只读状态作为执行结果 |

已有同一任务的实际TEST执行入口，同一生产源码快照下live42暂停恢复、live43普通正常及live44超量异常安全收尾均已通过实际执行与终态HTTP/浏览器核对。最新clean编译及扩大回归3044/3044、18类SQL110/110、独立四模块310/310及前端61/61通过；live32/live33仍保留各自历史快照，不重复累计。入口使用实际固定任务与明确TEST M01身份、初始审批、设备输入，不覆盖页面创建/审批全流程、完整网关登录部署、客户适配或真实设备。各层结果按其运行及快照认定。

## 4. 隔离MySQL准备与SQL测试

### 4.1 实例边界

- 使用独立MySQL8.4数据目录和进程，绑定`127.0.0.1:33087`。现有测试会强制检查端口，不能直接改成dev库或生产库。
- 测试库名必须匹配`feeding_validation_[0-9]+`，每轮整批使用新库。
- 使用专用本地测试账号/密码。凭据文件放工作树外的私有目录，或已确认被Git忽略的私有目录；不要截图或提交。
- 按新空库依次运行当前`docs/开发基线/01-完整建表.sql`、`02-基础数据初始化.sql`、`03-初始化结果核验.sql`。不执行history脚本，不在已有业务库重跑。
- 14类整批基线要求188张表；这是整个当前SMP基线，不是调度新增188张表。

在IDEA Database窗口新建MySQL数据源，Host为`127.0.0.1`、Port为`33087`、Database为新测试库。执行以下只读查询保存结果：

```sql
SELECT @@port, @@datadir, @@version, @@transaction_isolation;
SELECT DATABASE(), COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE();
```

必须核对实际datadir为专用测试目录，表数量为188。上下文并发测试基线要求`REPEATABLE-READ`；生产服务局部使用READ_COMMITTED的规则仍由测试独立验证，不能为消除失败将整个测试实例改为READ-COMMITTED。

实例启动示意（填写本机**已初始化**的专用路径）：

```powershell
$mysqlExecutable = '<本机MySQL8.4目录>/bin/mysqld.exe'
$testDataDirectory = '<本机专用测试数据目录>'
# 启动前确认33087未被其他进程占用；本行不执行初始化或修改账号。
& $mysqlExecutable --no-defaults "--datadir=$testDataDirectory" `
  --port=33087 --bind-address=127.0.0.1 --mysqlx=0 --console
```

不要使用共享MySQL服务的安装目录/数据目录。等待日志出现`ready for connections`，不能仅依据进程已创建判断可用。结束时仅关闭本轮单独启动且已无其他隔离测试使用的实例；共用专用测试实例时先结束自己的测试，不中断其他活动场景。

### 4.2 私有连接文件

创建UTF-8 JSON（以下是结构模板，尖括号须替换）：

```json
{
  "host": "127.0.0.1",
  "port": 33087,
  "database": "feeding_validation_<本轮数字编号>",
  "username": "<本地测试账号>",
  "password": "<本地测试密码>",
  "dataDirectory": "D:/<实际专用MySQL数据目录>"
}
```

SQL JUnit配置额外增加VM option：

```text
-Dfeeding.isolated.connectionFile=D:/<私有目录>/feeding-mysql.json
```

`dataDirectory`必须与`@@datadir`解析后的真实路径一致。不得从Nacos/dev配置自动读取凭据。

### 4.3 SQL用例顺序

下列14类曾在同一Maven测试进程完成84项批次，这是当时快照的证据；用例后续已有增加，重跑以实际报告为准，不沿用旧总数。`M07TaskHandoffReadPersistenceIT`现为4项，已单独在新库复验。单个SQL测试不保证可在同库反复运行：多类使用固定ID并保留测试原件，再跑请新建库，不清空其他人数据。

```powershell
Set-Location 'D:/project/yaoming/SMP/wt-feeding-scheduler'
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=D:/project/yaoming/SMP/tmp/j17'
$sqlTests = @(
  'M07CalibrationAdoptionPersistenceIT', 'M07FeedingSafetyHandoffPersistenceIT',
  'M07FeedingSafetyPersistenceIT', 'M07GenerationScopeRulesPersistenceIT',
  'M07JitterRecoveryPersistenceIT', 'M07MonitorActivityPersistenceIT',
  'M07MonitorAnomalyPersistenceIT', 'M07MonitorContextPersistenceIT',
  'M07MonitorReleasePersistenceIT', 'M07NormalStopPersistenceIT',
  'M07ReleaseHandoffAdmissionPersistenceIT', 'M07TaskHandoffReadPersistenceIT',
  'M07UnifiedQueuePersistenceIT', 'M07ContinuationSystemLockPersistenceIT'
) -join ','
& 'D:/tools/apache-maven-3.9.16-bin/bin/mvn.cmd' -o -B -ntp `
  -pl futurefab-modules/futurefab-system -am test `
  "-Dtest=$sqlTests" `
  '-Dfeeding.isolated.connectionFile=D:/<私有目录>/feeding-mysql.json' `
  '-Dsurefire.failIfNoSpecifiedTests=false'
```

IDEA也可建立Maven Run Configuration：Working directory选工作树，Run字段填写上述`-pl ... -am test`及参数，不包括PowerShell变量和`&`部分。检查system实际执行非零用例；上游模块无匹配用例不代表system可以零用例通过。

## 5. Gateway/Monitor配置与断点

初次使用第3节JUnit，它们自动生成有效期匹配的配置和动态端口。不要复制已过期的登记JSON后只修改时间/hash，也不要手填现场批准。配置、登记、profile、密钥、源身份和摘要必须同一套。

### 5.1 保护Gateway配置

`FeedingGatewayMain`只接受一个绝对配置路径，或再加第二个绝对普通监听配置路径。保护properties要求以下键**全部且仅这些键**：

| 键 | TEST来源/约束 |
| --- | --- |
| `gateway.instance-id` | TEST网关实例身份；与登记/回执匹配 |
| `gateway.bind-host` | `127.0.0.1`或`::1` |
| `gateway.safety-port` | 空闲回环端口，由测试生成 |
| `gateway.journal-file` | 本轮绝对路径；重启使用原文件；不能两个进程共用 |
| `gateway.http-workers` | 显式2—64；TEST用值由夹具生成 |
| `transport.maximum-clock-skew` | ISO-8601 Duration，TEST值，不当现场批准 |
| `m07.client-id`、`m07.key-file` | M07至保护Gateway通道身份和至少32字节私有key文件 |
| `monitor.client-id`、`monitor.key-file` | Monitor独立读停通道，与M07身份/key不同 |
| `installation.class` | 当前测试的`GatewayInstallation`类；不填真实`CustomerOpcInstallation` |
| `installation.config-file` | TEST设备映射配置绝对路径 |

普通命令第二份properties严格要求：`normal.bind-host`、`normal.port`、`normal.path-prefix`、`normal.executor-id`、`normal.key-file`、`normal.maximum-clock-skew`、`normal.http-workers`。端口和key须与保护监听分离。未提供第二文件不会打开普通命令监听。

`TestGatewayInstallation`位于Monitor的`src/test/java`，是保护测试驱动：只允许读和STOP，明确拒绝正常启动/调速及释放。验证正常命令请选择Gateway或M02专门的测试驱动，不能为使它接受START而移除拒绝逻辑。测试类不能打包成生产失败兜底。

### 5.2 Monitor配置

`FeedingMonitorMain`只接受一份绝对properties路径，必要键如下：

| 类别 | 键 |
| --- | --- |
| 实例与存储 | `monitor.instance-id`、`monitor.bind-host`、`monitor.port`、`monitor.state-directory` |
| 扫描与容量 | `monitor.scan-interval`、`monitor.maximum-active-bindings`；当前Main只接受单活动绑定`1`，不等于多设备投用能力 |
| 到Gateway | `transport.gateway-uri`、`transport.client-id`、`transport.gateway-key-file`、`transport.request-timeout`、`transport.maximum-clock-skew` |
| M07进入Monitor | `m07.client-id`、`m07.key-file`，与Monitor到Gateway通道分离 |
| 精确资格摘要 | `approval.profile-hash`、`approval.authorization-hash`、`approval.clock-proof-hash` |
| 反馈资格 | `feedback.config-file`、`feedback.config-sha256`成对提供；文件明确设备/指标/单位/时间等，缺失不能接收新合格绑定 |
| 异常来源二选一 | `anomaly.installation.class`和`anomaly.installation.config-file`成对；或`anomaly.context.mode=PERSISTED_M07_V1`消费M07持久上下文，不同时配置两种模式 |

进程存活或`FEEDING_MONITOR_READY`只说明监听/主循环已启动；还必须确认精确登记和ACK、反馈资格、存储和上下文有效。`FEEDBACK_APPROVAL_UNAVAILABLE`表示新登记被阻断，不能当作就绪成功。

### 5.3 M07连接配置的对应关系

`M07IndependentMonitorConfiguration`的开关是 `futurefab.m07.independent-monitor.enabled`，两个通道分别是：

```text
futurefab.m07.independent-monitor.gateway.endpoint
futurefab.m07.independent-monitor.gateway.client-id
futurefab.m07.independent-monitor.gateway.instance-id
futurefab.m07.independent-monitor.gateway.key-file
futurefab.m07.independent-monitor.gateway.request-timeout
futurefab.m07.independent-monitor.gateway.maximum-clock-skew

futurefab.m07.independent-monitor.monitor.endpoint
futurefab.m07.independent-monitor.monitor.client-id
futurefab.m07.independent-monitor.monitor.instance-id
futurefab.m07.independent-monitor.monitor.key-file
futurefab.m07.independent-monitor.monitor.request-timeout
futurefab.m07.independent-monitor.monitor.maximum-clock-skew
```

gateway端指向保护监听，monitor端指向Monitor监听；两端endpoint/key不能相同。普通M02命令客户端采用另一组`futurefab.m02.command-gateway.*`参数，不能将普通监听地址填到保护通道。当前JUnit使用MockEnvironment明确组装这些值，不启动Nacos。

### 5.4 在IDEA调试

先调JUnit父进程：在`M07ExecutionControlWorker.evaluate`、`M07MonitorContextOutbox.ensureProgress`、`M07StopEvidenceAssembler`、`M07JitterRecoveryCoordinator`、`M07ResourceReleaseWorker`等处打断点。要确认测试是否经过某类，以实际调用栈为准，不因类存在就声称已执行。

JUnit的Debug只附加父测试JVM，不能自动进入`ProcessBuilder`创建的Gateway/Monitor子JVM。需要调子JVM时，先在测试写完properties、创建进程前暂停，查看`@TempDir`和生成配置；再为目标子进程单独配置JDWP/Remote Debug。不要把`suspend=y`放进公共`JAVA_TOOL_OPTIONS`，否则所有测试子JVM会等待调试器并使定时断言失败。暂停断点也会影响真实超时，断点运行不作为时限验收。

手工Application配置的Main、参数及classpath应沿用对应测试生成的完整集合。Monitor测试的`TestGatewayInstallation`需要Monitor测试classpath，单用Gateway生产classpath会报ClassNotFound。每次重启保留原状态目录；每个新测试场景使用新目录，不删除活动日志来解除保护。

## 6. 前端隔离验证

先不启动连接既有后端的门户。当前工作树已有本机依赖链接；不同机器应按锁文件安装，不能把这里的依赖链接目录复制过去。

```powershell
Set-Location 'D:/project/yaoming/SMP/wt-feeding-scheduler/futurefab-frontend'
pnpm exec node node_modules/vitest/vitest.mjs run --config vitest.config.ts `
  tests/reactor-task-detail.test.ts tests/feeding-browser/vite-config.test.ts `
  tests/reactor-task-queue-remote.test.ts tests/feeding-runtime-readings.test.ts tests/run-task.test.ts
```

上述最新定向批次使用pnpm8.6.2，5文件61/61通过，日志`outputs/feeding-http-browser-20261023/236-frontend-focused-final.log`。首调`pnpm exec vitest`因本机node_modules/.bin缺失未执行，保留`236-frontend-cli-missing-bin.log`；上面的命令直接使用已安装Vitest入口，后续实际执行通过，未修改依赖或测试断言。141旧61项和首轮116项保留为历史证据，不重复累加。IDEA可创建Vitest配置，选择当前目录、`vitest.config.ts`和上述文件。

类型检查在`futurefab-frontend/packages/app-smp-lab`：

```powershell
node ../../node_modules/vue-tsc/bin/vue-tsc.js --noEmit --composite false
```

构建需要本机固定pnpm8.6.2、可解析的vue-tsc，并先构建本worktree的API、静态资源、语言、stores和common。可参考本机 `outputs/feeding-test-20261022/bin/` 工具包装及测试复验记录；这些是本地工具，不是生产配置。第10节已提供限定本次任务的TEST身份/后端和代理，支持暂停、恢复；完整门户认证与其他页面写接口不在其范围。不能沿用dev代理。Vitest、类型检查和构建通过不代替浏览器业务验收。

## 7. 联调检查表

| 场景 | 期望 | 证据 |
| --- | --- | --- |
| 错误客户端身份/签名/旧fence | 拒绝，无设备动作 | 原请求/回执、TEST动作调用计数 |
| START结果UNKNOWN | 查原命令，不新建启动 | 原command/request identity及调用次数 |
| 普通监听阻塞 | 独立保护读停仍响应 | 两个真实子进程及STOP审计；不代表真实泵停止 |
| 监控重启 | 恢复原登记/context/首次停止期限 | 重启前后journal/hash及首期限对比 |
| 持久上下文缺失 | 进度不发出、RETRY，无成功ACK | 活动SQL9项中的反例 |
| 终点与超量 | 原目标量；终点≥，超量严格>，可同时保留原因 | 控制/判据测试和原事件 |
| 抖动恢复 | 原起点/原J、实际停料、合格观察及恢复门禁齐备 | 恢复协调、窗口资格、SQL；示例参数非默认 |
| ERROR安全释放 | 安全事实齐备可释放，异常待办/设备锁/培养约束保留 | 正常停止/异常处理/释放SQL及HTTP投影 |
| 坏质量/旧采样/无覆盖 | 保持未知/保护，不能伪造稳定或认可量 | 原采样身份、拒绝原因、账本不重复 |

结束时记录HEAD、工作区快照、用例数及失败/错误/跳过，确认自己的TEST子进程已退出。专用MySQL的关闭按第4.1节区分是否仍有其他场景使用。不要提交密钥、密码、测试日志、数据库数据目录或`.idea`本地凭据。

## 8. 已知结果与限制

最终`233-m07-regression-final.log`完成clean Maven编译与扩大回归3044/3044，0失败/错误/跳过，BUILD SUCCESS。`234-independent-modules-final.log` clean test通过API95、Gateway70、Monitor122、客户适配23，共310/310，0失败/错误/跳过；236前端5文件61/61通过；`237-sql-fixture-test-compile.log`测试重编译退出0；`238-all-persistence-sql-green.log`在新库`feeding_validation_1792766347539`完成18类110/110，0失败/中止/跳过，退出0。各层结果不合并为重复累加的总数。

联合SQL首轮108/110、2失败保留在`235-all-persistence-sql-red.log`，原`current-all-persistence-sql-green.log`的green文件名不代表成功。根因为`M07JitterRecoveryPersistenceIT`遗留PREPARED命令995000704，影响另一IT的候选集合和限额扫描。仅这两个IT在写入后登记自有command_id/execution_id/request_id，并在AfterEach精确清理，生产SQL、扫描资格和断言均未改；237重编译及238全批SQL复验通过。233之后仅两个IT代码变化，三条live及3044项对应的生产源码快照仍有效，不据此扩展为后续任意修改也已验证。

此前快照结果：独立API95、Gateway70、Monitor93、客户适配23项分别通过；隔离SQL84项通过；前端116项及实验室应用类型检查/完整构建通过。详见[测试复验记录](补料调度-测试复验记录-20261022.md)。后续修改不能直接沿用这些结果作为当前全量通过证明。

2026-10-23已修复原六项门禁，扩大调度及公共守卫回归2696/2696通过，隔离SQL84/84通过，独立API/网关/监控/适配281/281通过；详见[六项门禁修复与复验](补料调度-六项门禁修复与复验-20261023.md)。这些结果不证明完整生产自动补料链。

已完成的整体回归见`180-m07-regression-current.log`：Maven clean编译及2986项测试通过，0失败/错误/跳过；四个安全模块在`176-safety-process-regression.log`中复验281/281。综合隔离SQL见`181-all-persistence-sql-green.log`：17类101/101、0失败/跳过。其首轮曾因固定任务claim测试类双构造器而只执行100项并有1个容器失败；改为单默认构造器和`live()`测试工厂、同步Main/BindingTest后全批复验通过。旧2696/84及各组件定向批次保留为历史证据，与新回归不重复累计；180之后的修改按各自新证据认定，不能沿用2986项作为当前全部修改已复验的证明，也不能代替恢复完整链。

相关定向结果包括前端61/61、续段最终释放/投影/准入门禁69/69、最终段读取SQL4/4，各批范围不同且部分与旧批重叠，不汇总为整链通过数。后续live32正常执行10.000000g完成EXECUTED/STOPPED/CONFIRMED、唯一FEED/SETTLE及资源FREE双ACK；live33超量12.300000g完成ERROR/STOPPED/CONFIRMED，人工处理=0仍安全释放。两次均已核对实际HTTP及浏览器详情RELEASED/ACKNOWLEDGED，设备/现场锁UNKNOWN未被改写为已解锁。live30虽到达PAUSED，恢复503、SET_SPEED未派发的历史失败保留；后续恢复成功另见live42。运行日志与页面证据见[联调记录](补料调度-隔离HTTP与浏览器联调记录-20261023.md)。

后续续段来源修复已通过75项定向单元和4项隔离SQL：正式采样Provider、执行Authority以及生产配置/TEST Main均接通原核准来源追溯，保留续段自身资格证明并逐段核原登记和双ACK。证据见`continuation-approval-source-snapshot.json`及同前缀green日志；SQL命令和锁定上下文是明确TEST替身。该批只证明组件修复，实际恢复后的首样、控制、最终收尾与浏览器完整链证据另见live42。

后续live34暴露TEST设备记录的START时刻晚于运行读数，现已改为先记录物理转换再读取反馈，STOP仍在停止反馈后确认；185红/186绿共6项通过，生产时间门禁未改。live35完成实际开始归并后，因Ingestion混淆命令摘要与结果自身摘要，调用前原件持续阻塞并触发保护STOP；该运行已终止并保留数据。摘要修复已有57项单元和4项run_event隔离SQL通过，见`monitor-invocation-hash-*`日志/快照；live35仍是失败记录，后续live42单独记录恢复成功。

live36和live37均已通过真实HTTP暂停到PAUSED，恢复仍返回503。live36先因TEST网关缺续段登记/激活Authority被拒，随后才发生progress保护；`M07IsolatedContinuationAuthority`已补原REQUEST/ELIGIBLE、唯一FEED、真实STOP及覆盖的只读锁事务核验，25/25通过。live37是前段rev144在续段事务中仍为PENDING、真实ACK紧随后提交的交接竞态，Store.continuation为360ms；不能归为性能超限。Store/Outbox已按合法末版原件在事务外补交接，取得真实ACK后重进原事务校验一次，`context-tail-*-green.log`记录75项单元、25项独立SQL通过。这些修复不改写两次失败结果。

CLOSED重投影已在调用前返回，保留原件/游标且停止覆盖继续读取原件，`monitor-closed-reprojection-green.log`及同前缀SQL日志对应66项单元及5项SQL通过。生产已有PREPARED SET_SPEED原命令恢复scanner，本次补齐隔离Main接线，`prepared-resume-recovery-green.log`及同前缀SQL日志对应60项单元、2项SQL；`197-current-test-composition-green.log`另有19项装配验证通过。后续真实CONTINUATION收取及交接前旧身份严格排除已取得70项单元、6项SQL证据（`monitor-continuation-*`）；首反馈不代替采样覆盖的修复另有57项单元和1项独立进程通过（`first-feedback-coverage-*`）。各批不重复累计，也不扩展180/181的旧快照结论。

live38/live39均已完成pause 202、PAUSED、resume 202及续段SET_SPEED实际执行。live38随后因旧MISMATCH历史影响独立固定量资格而触发`ANOMALY_QUALIFICATION_UNAVAILABLE`/`FIXED_AMOUNT_FACTS_UNQUALIFIED`保护；已有32项定向修复证据（`fixed-current-observation-green.log`），原件及本次失败保留。live39已形成`FIXED_AMOUNT_PROTECTION_DECISION`，但登记至首进度耗时越过TEST 3秒而触发`EXECUTION_PROGRESS_STALLED`，最终安全ERROR收尾。`210-live39-readonly-closure.txt`确认ERROR/STOPPED/CONFIRMED、2.100000g、FEED=2、SETTLE=1、两个资源FREE及释放/HANDOFF/ACK各1；206/207/208只保留暂停恢复网络和PAUSED页面，没有释放终态截图，不能记为释放页面验收通过。

Context批量化已通过99项单元、26项SQL，见`context-continuation-batch-final-unit.log`及`context-continuation-batch-sql-green.log`；185版上下文由371次原件查询降为3次。`context-continuation-batch-final-profile.log`中热状态ACK重验104.353ms，但冷启动历史校验3832.802ms，不能据局部热路径性能认定TEST 3秒部署期限达标。后续策略窗口原件回归49/49见`strategy-window-original-green.log`；它与固定量32项、首反馈57项/独立进程1项属于不同快照和范围，不重复累加。

live40（211）在HIGH约150秒、尚未暂停时，M07证据收取3548ms越过3秒进度期限；独立监控仍约220ms一轮、762条OBS/762次固定量判定，没有资格异常，最终安全ERROR/FREE，并非恢复场景通过。live41（213/215/216）由真实浏览器pause 202到13:51:13.973Z PAUSED，resume 202且原SET_SPEED实际执行；新登记13:51:53.532Z、首反馈13:51:56.45994Z，13:51:56.67858Z仍触发进度超时。`217-live41-sql.txt`已只读确认ERROR/STOPPED/CONFIRMED、2.700000g、FEED=2总2.7g、EXECUTE=1、SETTLE=1，控制器和地秤均FREE，释放/HANDOFF/ACK各1；这是本次异常安全收尾证据，没有正常恢复及释放终态浏览器验证。

后续来源校验性能修复通过137项单元及26项SQL，见`context-source-validation-*`日志/快照，同一保留原件的首次续段校验896.218ms降至691.002ms；独立监控原件增量导出通过44项单元及2项独立进程，见`monitor-evidence-index-*`，保持原字节、摘要、身份及损坏/并发停止边界。各批与此前用例重叠，不重复累计，局部性能测量不能代替整体期限验证。

live42现已完整通过：`218-live-chain.log`在14:13:41.801544Z持久核验EXECUTED、10.000000g、FEED=2、SETTLE=1、manualHandlings=0，输出`PAUSE_RESUME_EXECUTION_AND_RESOURCE_RELEASED`。220记录PAUSED、221为pause/resume两次202、222为恢复后HIGH、223为resume响应；224最终页面显示“已完成/已停料/已认可”、详情RELEASED/ACKNOWLEDGED，console为0 error，现场/故障锁仍UNKNOWN。`225-live42-sql.txt`确认STOPPED/CONFIRMED、两个资源FREE、释放/HANDOFF/ACK各1；成功检查期由stop-http结束，Main退出0。该同一固定任务的恢复、正常终点、计量及释放已经生产调用链产生并核对，不依靠状态夹具。

live43普通正常也已通过：226日志14:18:52.9928826Z输出`NORMAL_EXECUTION_AND_RESOURCE_RELEASED`，EXECUTED、10.000000g、FEED=1、SETTLE=1、manualHandlings=0、整组FREE及释放交接ACK；229完成页面/网络/控制台已核对，0 error，Main退出0。live44超量异常在230日志14:20:43.2748896Z输出`OVER_AMOUNT_EXECUTION_AND_RESOURCE_RELEASED`，ERROR、12.300000g、FEED=1、SETTLE=1、manualHandlings=0、整组FREE及释放交接ACK；232完成页面/网络/控制台0 error，Main退出0，异常状态及现场/故障锁UNKNOWN仍保留。三场景之间源码未改，均完成本次真实TEST执行，不能用正常终态替代异常收尾。

入口使用TEST M01身份、初始审批和设备输入，不能扩大为完整网关登录部署、真实客户设备或全部四阶段验收。原3秒期限与全部安全门禁未改。本轮233/234/236/237/238分层复验均完成，联合SQL首轮失败经精确测试清理后全批通过；180/181旧快照和失败历史仍保留。四阶段剩余业务、客户接口及现场验收按原开发计划逐项跟踪，不因三条固定量隔离链通过就标记全部完成。

## 9. 首轮只读页面与隔离SQL查询联调（保留历史入口）

完整记录见[隔离HTTP与浏览器联调记录](补料调度-隔离HTTP与浏览器联调记录-20261023.md)。本轮实际页面/SDK源码通过唯一回环代理连接真实Controller/Application/查询Mapper及全新隔离库，22项浏览器断言通过。状态由TEST SQL夹具预置；所有管理写403拒绝。它用于安全投影与前端交互验证，不是正常补料、成功恢复或H06真实释放的完整业务链。

IDEA新建Application，Main为`com.futurefab.system.service.support.m07.M07IsolatedReadBrowserMain`，使用system测试classpath，Working directory为本worktree下`futurefab-modules/futurefab-system`。参数依次为已核验新库的私有连接JSON和本轮绝对输出目录。首次按第4节在新库安装01/02/03；不得复用已预置测试ID的库。沿用第2节JDK/socket配置，不能启动system开发主类。

前端兼容默认读取`outputs/feeding-http-browser-20261023/read-server.json`；新目录使用`FEEDING_BROWSER_STATE_FILE`显式选择本轮Main生成的`read-server.json`，无需修改Vite源码。文件必须位于本worktree的outputs内；后端地址仅127.0.0.1。新一轮使用新目录，不覆盖活动证据或删除原停止标记冒充新场景。

在前端根运行：

```powershell
node node_modules/vite/bin/vite.js --config tests/feeding-browser/vite.config.mts
```

访问`http://127.0.0.1:5839/`。页面顶部必须显示只读/SQL夹具标识。可通过现有Playwright浏览器工具执行`tests/feeding-browser/checks.playwright.js`，或按联调记录逐项操作。所有断言操作均通过实际页面和HTTP，不用fetch mock。不能将恢复请求得到的TEST只读403当作成功恢复。

结束时在本轮输出目录创建`stop-read-server`文件，使只读Java主进程正常退出；停止本轮Vite，按第4.1节处理专用MySQL。删除不再使用的临时私密连接副本，保留测试数据与审计。这个停止标记仅适用于只读Main，不用于第10节实际执行。

## 10. 当前实际执行、暂停恢复与浏览器入口

### 10.1 IDEA Application配置

先按第4节安装新的`feeding_validation_数字`库，并核验端口、真实数据目录和私有连接文件。不要复用其他运行场景的库或正在使用的输出目录。

| 项目 | 配置 |
| --- | --- |
| Main class | `com.futurefab.system.service.support.m07.M07IsolatedFixedExecutionMain` |
| Classpath / JRE | system测试classpath，JDK17；包含Gateway、Monitor及feeding-safety依赖，不能改为system生产classpath |
| Working directory | `D:/project/yaoming/SMP/wt-feeding-scheduler/futurefab-modules/futurefab-system` |
| Program arguments | `D:/project/yaoming/SMP/wt-feeding-scheduler/outputs/<本轮唯一目录> PAUSE_RESUME`；也可显式选择`NORMAL`或`OVER_AMOUNT` |
| VM options | `-Dfile.encoding=UTF-8 -Djdk.net.unixdomain.tmpdir=D:/project/yaoming/SMP/tmp/j17 -Dfeeding.isolated.connectionFile=D:/<私有目录>/<本轮连接>.json -Dfeeding.isolated.http=true -Dfeeding.isolated.httpHoldSeconds=600` |
| Environment / Before launch | 沿用第2节socket环境；先编译当前源码，不启动system/dev、Nacos、真实客户适配或通知服务 |

`connectionFile`是VM参数，不能放到Program arguments。输出目录必须在本worktree的outputs下。`httpHoldSeconds`仅在场景真正收尾成功后保留HTTP供检查，允许0—600秒；它不延长运行、停料、覆盖或独立监控的安全期限。`NORMAL`和`OVER_AMOUNT`当前TEST运行等待上限为260秒，`PAUSE_RESUME`为420秒；这些是测试进程等待预算，不是现场参数，也不能据超时改写任务成功。当前代码按每个新段独立等待首个合格采样，独立监控的首次期限不重置。

本机已有`outputs/feeding-http-browser-20261023/run-owned-live.ps1`可作运行记录参考：它读取该机私有客户端文件、安装`current-baseline-0..2.sql`并运行Main；路径和classpath均为本机产物，不是通用部署脚本。复用前核对基线与当前正式01/02/03一致，选择未占用Run/Log编号；不要照抄旧库、旧密钥或另一个活动场景的manifest。

### 10.2 启动顺序与实际边界

1. 独立MySQL就绪，新库安装与隔离身份核验完成后启动上述Main。Main预置明确的TEST主数据、核准来源和待执行任务，再调用生产准备Provider/Authority及claim，不预置运行完成、量账或释放结果。
2. Main启动同进程的实际Gateway保护/普通HTTP监听和内部TEST设备，再启动独立`FeedingMonitorMain`子进程；登记、上下文和双ACK经实际回环HTTP交接。无需另外启动Gateway或通用模拟器，以免重复绑定。
3. Main接通`M02HttpDeviceCommandAdapter`、原命令派发、PREPARED续段原命令恢复扫描、实际首反馈、正式采样资格/归并、控制和停止收尾；TEST网关续段授权由`M07IsolatedContinuationAuthority`只读核验原业务证据。启用HTTP后，`M07IsolatedExecutionHttp.collectObservation`将TEST设备原读数经正式M02签名收件与投影链送入当前读数。测试设备仅产生原始反馈，任务/段/量账变化由生产调用链写入。
4. HTTP监听成功后，Main在本轮输出目录生成`execution-http.json`，包含`mode=LIVE_EXECUTION`、本次taskId/executionId及随机回环端口。该文件存在只证明接口已启动，不证明补料成功。
5. 再按第10.3节启动Vite并操作本次任务。实际网络由JDK HttpServer转入真实Controller/Application、管理守卫、事务及Mapper；内层MVC组装使用测试容器，身份严格限定为TEST用户及本次实验室/培养，不能称为完整Spring Boot、登录/AOP或部署验收。M09真实通知未装配。

### 10.3 前端连接与操作

在前端根目录运行，替换本轮路径：

```powershell
Set-Location 'D:/project/yaoming/SMP/wt-feeding-scheduler/futurefab-frontend'
$env:FEEDING_BROWSER_STATE_FILE = 'D:/project/yaoming/SMP/wt-feeding-scheduler/outputs/<本轮唯一目录>/execution-http.json'
node node_modules/vite/bin/vite.js --config tests/feeding-browser/vite.config.mts
```

访问`http://127.0.0.1:5839/`，顶部必须显示“TEST隔离执行联调”和生产调用链说明。Vite只代理到manifest的127.0.0.1端口；换场景需重新选择manifest并重启自己的Vite。端口5839已有其他运行占用时先核对归属，不结束他人进程。此入口复用真实Tasks页面、SDK和管理头，不替换成功响应。

HTTP白名单仅含本次任务列表、详情、logs、executions的GET，以及本次任务的POST pause/resume；其他任务或写接口返回403。TEST token由manifest约定与入口使用，不是生产登录凭证。暂停须从当前allowedActions发起，body含最新`expectedVersion`及`confirm:true`；恢复须在服务端允许时传最新`expectedVersion`和明确`pauseReason`。`X-Management-Revision`取最新GET顶层，`X-Request-Id`由SDK生成；结果未知时保留原请求身份，不换键重复下发。

先观察HIGH/首启事实，再发暂停并跟踪PAUSE_REQUESTED、实际停料、合格观察和PAUSED；202只表示意图受理。恢复后仍须核对新段、原终点、登记双ACK、激活、实际反馈与最终量账，HTTP返回或页面跳转不能代替这些事实。收尾必须同时核对数据库各段唯一FEED、原执行唯一SETTLE、完整资源FREE及外部双ACK；异常场景须保留ERROR待处理与锁状态，不以正常结束冒充异常安全收尾。

本轮证据保存在输出目录的`execution-http-audit.ndjson`、`m02-observation-receipts.ndjson`、`TEST-gateway.journal`、Monitor日志及数据库原件。程序只有在对应业务状态、资源和双端交接均满足且持久核验通过后才输出`<SCENARIO>_EXECUTION_AND_RESOURCE_RELEASED`；缺标记、断言失败或提前退出均不得记为场景通过。成功后的HTTP检查期可用本轮`stop-http`文件结束；该文件不会中止运行中的补料循环。提前中止仅按TEST故障退出记录，并核对本次子进程清理，不当作正常停止确认或业务收尾。
