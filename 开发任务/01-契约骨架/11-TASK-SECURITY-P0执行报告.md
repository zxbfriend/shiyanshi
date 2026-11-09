# 11 - TASK-SECURITY-P0-R1 执行报告：系统管理旧链路高危暴露封堵 + 响应契约类型与敏感配置口径修正

- 任务编号：TASK-SECURITY-P0-R1（修订自 TASK-SECURITY-P0 初版报告）
- 执行日期：2026-09-19
- 依据：`docs/开发任务/10-全接口契约骨架覆盖审计.md`（SEC-R1/SEC-R2）、`05-PKG-01-ADJUST接口契约差异审计`、M01 详细设计 §17.1/§17.2 DTO 冻结契约（外部 ID 一律十进制字符串避免 JS 大整数损失；时间为 ISO/null）、CFG04/Q06/Q12、审阅结论（R1 任务书）
- 阶段定位：仍为契约骨架阶段，只封堵 P0 泄漏风险并修正契约类型，不实现冻结业务规则
- Git 状态：未提交（按任务书要求）

## 一、任务是否完成

**完成（按 R1 修正后口径）。** SEC-R1 CLOSED。SEC-R2 拆分结论：越权访问部分 CLOSED；Entity 直出部分 CLOSED；敏感配置分类能力 BLK-04b 未冻结——初版"空注册表不影响完成"的表述**作废**，R1 采用方案 A（fail-closed 保守隐藏）后**当前原文泄漏已封堵，分类能力待 BLK-04b**。§九 完成门禁 12 条全部满足（见 §十一）。

## 二、四个接口的原泄漏链路（初版取证，R1 保持）

| 接口 | 入口 | 泄漏链路 |
| --- | --- | --- |
| M01-049 `GET /system/user/{userId}` | `SysUserController.getInfo(Long)` | `selectUserById` → `SysUserMapper.selectUserVo`（含 `u.password`）→ `SysUser` Entity 直出 → bcrypt 哈希随响应返回 |
| M01-055 `GET /system/user/profile` | `SysProfileController.profile()` | `selectUserByUserName`（同一 `selectUserVo`）→ Entity 直出 |
| M01-075 `GET /system/user/getInfo` | `SysUserController.getInfo()` | Redis 会话缓存 `LoginUser.sysUser`（含哈希）→ `ajax.put("user", user)` 直出 |
| M01-070 `GET /system/config/{configId}` | `SysConfigController.getInfo(Long)` | 无权限注解 + `SysConfig` Entity 直出，`configValue` 原文无差别返回 |

password 的合法消费方（登录比较、锁定解锁、updatePwd 旧密码比对经 Redis/Feign）不可切断，取证见 §五。

## 三、修改后的响应模型（R1 类型修正后）

| 接口 | 最终响应类型 | R1 类型修正 |
| --- | --- | --- |
| M01-049 | `UserDetailView` | userId/deptId `Long→String`（`String.valueOf`，null 保持 null）；loginDate `java.util.Date→OffsetDateTime`（Asia/Shanghai 固定业务时区，输出 ISO-8601 带 +08:00 偏移，null 保持 null） |
| M01-055 | `ProfileView` | userId `Long→String` |
| M01-075 | `user` 载荷 `ProfileView`，顶层兼容键不动 | 同上（CurrentIdentityView 整体重构留待 TASK-COMMON） |
| M01-070 | `ConfigDetailView` + `@RequiresPermissions("system:config:query")` | configId `Long→String`；敏感口径改 fail-closed（§七） |

外部 ID 全量核查结果（R1 §二.5）：UserDetailView.userId/deptId/roleIds/labGroupIds/authorizedLabIds、RoleLabelView.roleId、ProfileView.userId、ConfigDetailView.configId、AuditView.createBy/updateBy 全部为 String；无任何字段用 Jackson 自定义序列化把 Long 伪装成字符串——Java 契约字段本身即 String。时间契约：AuditView.createTime/updateTime 与 UserDetailView.loginDate 均为 `OffsetDateTime`，与既有冻结骨架 View（PersonOptionView.loginDate、OperLogDetailView.operTime）同型；转换固定 `ZoneId.of("Asia/Shanghai")`，不依赖 JVM 默认时区（有专项测试）。本次未新增任何数据库查询。

## 四、password 封堵主措施

View 白名单 + 显式逐字段映射（禁 BeanUtils 复制后删）。三条用户响应链出口不再直出 `SysUser`；password/pwdUpdateDate/delFlag/params/searchValue 从结构上不可能进入响应；Mapper SQL 零改动（内部读哈希链路保留），成功/失败语义不变。

## 五、Entity 层纵深防御措施：评估后不采用（依据保持）

fastjson2 遵循 Jackson 访问注解（`ObjectWriterBaseModule.java:607`、`JSONFactory.java:223`，fastjson2 2.0.62），`TokenService` 以 fastjson2 序列化 Redis 内嵌 `LoginUser.sysUser`；给 `SysUser.password` 加 `@JsonProperty(WRITE_ONLY)` 或 `@JsonIgnore` 将破坏登录比较、解锁与 updatePwd 旧密码校验。故不加 Entity 注解，收口点唯一在 Controller 响应映射层；该决定由反射断言（password 字段无 Jackson 注解）与入向反序列化测试（`{"password":...}` 仍可读入）双向锁死。

## 六、M01-070 权限口径（R1 §五：保持）

`@RequiresPermissions("system:config:query")` 不变。依据：00 机器清单唯一冻结该字符串 + CFG04/§661 + 05/10 审计一致，无 §四.4 矛盾。匿名不可达由网关白名单（仅 `/auth/login`、`/auth/aad/**`）+ 认证过滤器保证；无权限请求由 `PreAuthorizeAspect` 拒绝；**未引入超级管理员专属限制**（注解为普通权限字符串，测试持续断言注解存在与取值）。

## 七、敏感配置值处理规则（R1 修正：方案 A fail-closed）

初版缺陷（审阅指出）：`SENSITIVE_KEYS = Collections.emptySet()` 使一切键判为非敏感并回显原值——"空集合"不等于"无敏感项"，运行时 fail-open。

R1 修正（不发明敏感键清单、不复用/新建第二套分类服务——现有源码无权威分类器，方案 B 无证据基础，故采用方案 A）：

- `ConfigDetailView.from(config)`（Controller 现用入口）：BLK-04b 未裁决前**一律保守处理**——`configValue` 恒 null、`sensitive=true`（契约语义"敏感或未分类"）、`configured` 返回真实配置状态。
- 双入口保留：`from(config, false)` 仅允许在 BLK-04b 裁决出权威分类器、且该分类器判定为普通配置后调用；`from(config, true)` 为敏感/未分类通道。
- 契约无 `classificationPending` 字段（§17.2 ConfigRow 完整字段中不存在），未擅自扩展字段，未分类信息复用 `sensitive=true` 保守值（R1 §四.5 允许口径）。
- 影响声明：四个 04a 密码策略键（Q06 属"受保护可回显"参数）在 BLK-04b 裁决前其值也暂不回显——这是方案 A"统一置 null"的必然保守代价，登记为 BLK-04b 裁决后的恢复项，而非本任务的隐藏缺陷。
- 配置新增、编辑、删除与缓存刷新逻辑零改动。

## 八、BLK-04b 状态（R1 修正口径）

BLK-04b 仍是**实际阻塞**：敏感键权威分类（注册表或 sys_config 敏感性列）未冻结，070 普通配置值回显能力被保守挂起。本任务关闭的是"未分类配置原文泄漏"面（fail-closed），不宣称也不实现 BLK-04b 的完整注册业务；`from(config,false)` 通道即其落地接线位。

## 九、修改文件清单

R1 增量修改（相对初版 TASK-SECURITY-P0）：
- `domain/vo/m01/UserDetailView.java` — ID/时间类型契约化
- `domain/vo/m01/ProfileView.java` — userId String
- `domain/vo/m01/ConfigDetailView.java` — configId String；方案 A fail-closed；删除空注册表
- `domain/vo/m01/AuditViews.java` — `toOffset` 提为包内共享（最小修改，行为不变）
- `src/test/java/com/futurefab/system/security/M01ResponseLeakGuardTest.java` — 9→12 用例（+大整数精度、ISO/时区无关、null 保持、既有断言补 ID 类型）
- `src/test/java/com/futurefab/system/domain/vo/m01/ConfigDetailViewMaskingTest.java` — 4→6 用例（改保守口径断言 + 分类通道断言 + configId 字符串断言）
- 本报告

初版累计（保持）：`controller/SysUserController.java`、`SysProfileController.java`、`SysConfigController.java` 三处出口映射与注解。

未修改：Controller 路由/业务调用链、Service、Mapper 接口/XML、SQL、Entity、Vue、PRE-01A/PRE-01B、客户只读材料、其他接口与 46 条旧路由。

## 十、测试与实际结果

新增测试合计 **18 个**（`M01ResponseLeakGuardTest` 12 + `ConfigDetailViewMaskingTest` 6），全部断言**序列化后的最终 JSON 字段与类型**（非仅 Java getter、非仅状态码），覆盖 R1 §六 19 项：ID 字符串形态（userId/deptId/configId/roleId）、`labGroupIds/authorizedLabIds` 字符串数组、2^53+1 大整数无精度丢失、loginDate ISO-8601 输出、JVM 默认时区切至 America/New_York 后仍按 +08:00 转换、null ID/null 时间保持 JSON null、049/055/075 无 password 回归（键形态负向断言列表保持）、070 未分类不回显原文且 sensitive 不错误报 false、configured 真实、`system:config:query` 注解反射断言、不直出 SysConfig、入向 password 反序列化不受影响、Entity 无 Jackson 注解断言。

实际执行（2026-09-19 本机）：

```
mvn -pl futurefab-modules/futurefab-system -am test → BUILD SUCCESS；Tests run: 129, Failures: 0, Errors: 0, Skipped: 0（111 旧 + 18 新，§六.19 PRE-01A/PRE-01B-R1 无回归）
mvn -pl futurefab-auth -am test                     → BUILD SUCCESS（auth 无测试目录，编译级回归）
git diff --check                                    → 退出码 0
```

分层声明：以上仅为**编译 + 单元/契约测试**层；未执行真实 MySQL、真实 HTTP、浏览器验收、真实网关 JWT 联调（权限切面运行时拒绝路径与网关认证约束仍为静态+单元层证据）。

## 十一、完成门禁核验（R1 §九 12 条）

①外部 ID 全部 String（含 roleId/labGroupIds/authorizedLabIds/audit）✅；②时间字段 OffsetDateTime/ISO ✅；③大整数 ID 测试无精度丢失 ✅；④三条用户响应 JSON 无 password（回归）✅；⑤070 默认入口不回显未分类原值 ✅；⑥不再以空敏感集合伪装完成（javadoc 与测试均锁死 fail-closed 语义）✅；⑦未新增敏感键业务规则（未发明清单）✅；⑧`system:config:query` 注解保持 ✅；⑨SQL 零修改 ✅；⑩未实现其他业务（双入口保留、分类器接线留 TASK-CFG）✅；⑪129/129 测试通过 ✅；⑫`git diff --check` 通过 ✅。

## 十二、剩余风险

1. **R-A'（替代初版 fail-open 风险）**：BLK-04b 未冻结期间普通配置值（含 04a 政策键）不回显，070 前端表单编辑原值为空——功能保守侧缺失，属裁决后恢复项；未分类键 `sensitive=true` 语义为"敏感或未分类"，前端不得据此文案直译"该键敏感"。
2. **R-B（前端展示适配）**：049/055 白名单 View 不含 sex/remark/顶层 createTime 等 Entity 平铺字段；070 表单绑定字段名不变但 configValue 暂为 null。均待对应 TASK 前端适配。
3. **R-C（纵深防御单层）**：收口仅在 Controller 响应映射层；`@InnerAuth /user/info` 为登录链必需出口，依赖内部注解+网关剥离保护，建议后续加"新增 SysUser 直出出口"静态守卫扫描。
4. **R-D（验证层级）**：见 §十分层声明。
5. 075 CurrentIdentityView 整体结构留待 TASK-COMMON，属冻结范围非本任务缺口。

## 十三、下一步建议

1. 用户审阅 R1 后决定提交（当前未提交）。
2. 优先裁决 BLK-04b（敏感键清单或 sys_config 敏感性列 + 权威分类器归属），裁决后经 `from(config, false)` 接线恢复普通值回显，并补充"权威分类器→View"契约测试。
3. 进入 TASK-COMMON：58 个 ADJUST 接口共用 ApplicationService 分包、DTO/View 命名与统一 501 骨架规则；View 完整化（avatarPreset/credentialVersion/allowedActions、075 CurrentIdentityView）随各 TASK 落地。
4. 具备环境后补真实网关 JWT + HTTP 层验收，关闭 R-D。
