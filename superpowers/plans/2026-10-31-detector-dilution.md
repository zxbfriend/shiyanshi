# 检测型号稀释范围实施记录

用户明确将稀释范围放到型号配置，并要求前后端修改和浏览器验证；随后明确去掉默认值配置。本轮只维护上下限，不新增 defaultValue 字段、实例覆盖或数据库列。不提交、不推送。

- [x] 型号页面：ViCell/Cedex 的最小值和最大值；类型允许范围内校验精度与顺序。不支持稀释的 Cedex 固定为 1～1。
- [x] 后端：型号保存校验范围/精度；M05 队列返回设备已应用的范围；送检继续执行既有范围复核。
- [x] 检测分析：使用已应用范围；缺项提示先配置/应用，不伪装为 1～1。范围不包含 1 时新选项目留空，已有记录原值保留。
- [x] 验证：后端 84 项、前端 18 项定向测试通过（进程退出码0）；SDK及两个应用构建退出码0，两个应用类型检查退出码0；system 重启后 readiness UP。
- [x] 浏览器：测试型号 UI-M05-20261019-CedexBio 保存范围2～50、版本4；隔离设备 UI-DIL-CED-1031 应用版本4，预览只有范围无默认值。分析输入框 aria-valuemin=2、aria-valuemax=50、可编辑，初始为空；空值保存被阻断，3可保存本地选择。
- [x] ViCell 浏览器：UI-M05-VICELL-1031 已应用范围1～20，空闲行可输入10.0，已有QA1031VIC1保持2.0。

本轮测试未发送设备命令，真实设备与现场验收 NOT_VERIFIED。测试型号、隔离设备与检测项开关保留供复核；本地测试输入已丢弃，未创建新检测样品，不修改旧检测记录。

数据库只读核验确认型号JSON只含 min/max/scale/required/itemSelection，不含defaultValue，实例应用版本4。证据截图在 .local-start-tools/dilution-range-only.jpg、dilution-analysis-range.jpg、dilution-vicell-range.jpg。后端日志未发现本轮RequestMetaInvalidException、GlobalExceptionHandler或ERROR。浏览器工具未提供网络报文捕获，本轮未保存逐请求原始Header/响应体，不把源码双头实现视为原始报文证据。
