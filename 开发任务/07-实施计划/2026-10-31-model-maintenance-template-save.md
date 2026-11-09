# 型号维护信息直接用于方案保存

依据：用户2026-10-31明确要求按客户需求取消工程资料核准前置校验；V4.0/V4.2资源管理的反应器维护、工艺设置的补液方案章节。

设计：M04使用M02现有型号只读Port读取统一型号库及通道事实，在同一SYSTEM管理修订内校验并固定参数；不再读取EngineeringProfile的草稿、核准、撤销状态。新快照明确记录MODEL_MAINTENANCE来源，保留旧快照读取和摘要校验，不生成核准证据。型号不存在、能力不完整、型号不适配、版本冲突和权限不足仍拒绝。

本批不修改真实设备通信、安全停止、物理执行和计量规则，不以型号保存代表设备验收。独立工程资料旧接口暂保留，不作为方案保存前置。

- [x] 修改补液保存回归用例，证明无工程资料也可保存且快照来自型号信息；先运行确认旧代码失败。
- [x] 将M04型号读取及新版本快照改为型号维护来源，保留历史读取；补充来源、能力缺项、修订漂移测试。
- [x] 同步需求澄清、文档导航与M02/M04现行设计，清楚覆盖旧核准前置规则。
- [x] 执行后端定向测试并记录真实用例数、原进程退出码。
- [x] 核对运行目标并从真实补液方案页面验证保存；记录请求、响应、日志、数据保留或清理情况，运行未更新时标BLOCKED_DEPLOY。

交付不提交、不推送、不执行安装或历史SQL，不改客户原始材料。

## 已执行的验证

- RED：原实现执行1例新增补液用例，原Maven进程退出1，抛出与页面一致的`profile=PROFILE_NOT_VERIFIED`。日志`.local/model-maintenance-red.log`。
- 首轮回归157例，其中2例仍断言旧核准规则，退出1；按新需求将其改为从维护信息获取能力、无核准记录允许复制的真实行为断言，不删除权限、事务、冲突或回滚校验。
- 最终后端定向回归：`mvn -pl futurefab-modules/futurefab-system -am -Dtest=M04TemplateWriteGuardedContractTest,M02TemplateModelResourceAdapterTest,M04TemplatePackagePortContractTest,M04PermissionEnforcementContractTest,M04ConfigContentNormalizerTest,M04PerfusionContentNormalizerTest,M04EngineeringBundleContractTest,M04MaintainedModelFactsTest -Dsurefire.failIfNoSpecifiedTests=false test`，8类162例，Failures=0、Errors=0、Skipped=0，原进程退出0，BUILD SUCCESS。日志`.local/model-maintenance-regression.log`。
- 前端使用pnpm 8.6.2：`pnpm --filter @futurefab/ui-app-smp-settings run type-check`原进程退出0。仅修改灌注相关说明文字，未改变页面布局及交互。
- 静态只读复审完成；已修正残留“核准体积/核准量程”的前后端提示。历史schema1保留，新增测试验证维护schema2的导出、解码及期望摘要冲突。
- 真实数据库仅只读核对：统一型号表`dev_reactor_model`存在有效`rwerwer`，capacity_g=2.000、spec=1；旧`dev_integrated_reactor`无此型号不能作为当前事实依据。未执行安装、迁移、历史SQL或直接写库。
- 重启前层级：IMPLEMENTED + CONTRACT_TESTED；HTTP/浏览器 NOT_VERIFIED，运行暂为BLOCKED_DEPLOY。2026-10-31用户选择自行重启IDEA中的system服务，完成后通知继续浏览器保存验收。未停止用户调试进程。
- 本次未提交、未推送；客户原始Word及只读附件未修改。

- 前端设置包构建：`pnpm --filter @futurefab/ui-app-smp-settings run build`原进程退出0，产物构建通过；日志`.local/model-maintenance-frontend-build.log`。本地dist为构建产物，不纳入提交。

## 重启后的浏览器验收

用户重启system后，本轮使用rwerwer新增禁用方案`验收-rwerwer-20261031`成功，页面提示保存成功，列表及再次打开表单回显正确。数据库只读核对已保存MODEL_MAINTENANCE来源的schema2快照，核准工程资料记录保存前后均为0，error.log无新增异常。最终M04-006本次场景达到IMPLEMENTED + CONTRACT_TESTED + HTTP_VERIFIED + BROWSER_VERIFIED；运行BLOCKED_DEPLOY已解除。测试方案保留禁用，不用于真实执行。证据及网络记录边界见[浏览器验收记录](../../详细设计/04-工艺与方案管理/history/review/2026-10-31-rwerwer补液方案浏览器验收.md)。设备和现场验收NOT_VERIFIED，不能由本次保存推出。
