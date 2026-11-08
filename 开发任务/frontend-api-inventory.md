# futurefab-frontend 前端接口调用清单（审计）

> 生成方式：静态解析 `futurefab-frontend/packages/**/src` 中 `request({url})`、`service({url})`、`request("path")`、`apiUrl(...)`、`download(...)` 全部调用点；只读审计，未修改任何业务代码。
> 基准前缀：所有路径均拼接网关 `baseUrl`（生产 `/prod-api`，开发 `/dev-api`，由 `configureApi` 注入），下表记录的是网关后路径。
> 扫描时间：2026-09-25；调用点总数：708

## 按模块统计

| 分类 | 数量 |
|---|---|
| 1 登录认证类 | 6 |
| 2 系统设置类 M01 | 164 |
| 3 实验室设置类 M02（实验室/分组） | 196 |
| 4 资源/设备类 M02（设备主数据） | 82 |
| 5 项目/批次/培养类 M03 | 82 |
| 6 工艺流程类 M04/M06 | 0 |
| 7 检测与签批类 M05（含 SDMS 集成） | 114 |
| 8 告警通知类 M09 | 28 |
| 9 其他/无法归类 | 36 |
| **合计** | **708** |


## 分类 1：登录认证类

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | sdk-smp-api | 验证码开关/图形验证码 | `index.ts`:62 | authApi.captcha | GET | `/code` | 无参 |  |  |  |  | — |
| 2 | sdk-smp-api | — | `index.ts`:71 | authApi.login | POST | `/auth/login` | 无参 |  |  | 是 |  | — |
| 3 | sdk-smp-api | — | `index.ts`:88 | authApi.logout | DELETE | `/auth/logout` | 无参 |  |  | 是 |  | — |
| 4 | sdk-smp-api | — | `index.ts`:93 | authApi.unlock | POST | `/auth/unlockscreen` | Body |  |  | 是 |  | — |
| 5 | sdk-smp-api | — | `index.ts`:103 | authApi.aadStatus | GET | `/auth/aad/status` | 无参 |  |  |  |  | — |
| 6 | sdk-smp-api | — | `index.ts`:105 | authApi.aadToken | POST | `/auth/aad/token` | Body |  |  | 是 |  | — |

## 分类 2：系统设置类 M01

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 7 | sdk-smp-api | — | `dictData.ts`:98 | dictDataApi.checkValueUnique | GET | `/system/dict/data/checkValueUnique` | Query |  |  |  |  | — |
| 8 | sdk-smp-api | — | `dictData.ts`:107 | dictDataApi.checkLabelUnique | GET | `/system/dict/data/checkLabelUnique` | Query+Body |  |  |  |  | — |
| 9 | sdk-smp-api | — | `dictData.ts`:112 | dictDataApi.save | POST/PUT | `/system/dict/data` | Body |  |  | 是 |  | — |
| 10 | sdk-smp-api | — | `dictType.ts`:71 | dictTypeApi.list | GET | `/system/dict/type/list` | Query | 是 |  |  |  | — |
| 11 | sdk-smp-api | — | `dictType.ts`:82 | dictTypeApi.optionSelect | GET | `/system/dict/type/optionselect` | Query |  |  |  | 是 | — |
| 12 | sdk-smp-api | — | `dictType.ts`:85 | dictTypeApi.checkNameUnique | GET | `/system/dict/type/checkDictNameUnique` | Query+Body |  |  |  |  | — |
| 13 | sdk-smp-api | — | `dictType.ts`:90 | dictTypeApi.save | POST/PUT | `/system/dict/type` | Body |  |  | 是 |  | — |
| 14 | sdk-smp-api | — | `dictType.ts`:103 | dictTypeApi.refreshCache | DELETE | `/system/dict/type/refreshCache` | 无参 |  |  | 是 |  | — |
| 15 | sdk-smp-api | — | `index.ts`:76 | authApi.info | GET | `/system/user/getInfo` | 无参 |  |  |  |  | — |
| 16 | sdk-smp-api | — | `index.ts`:82 | authApi.updateProfile | PUT | `/system/user/profile` | Body |  |  | 是 |  | — |
| 17 | sdk-smp-api | — | `index.ts`:84 | authApi.menus | GET | `/system/menu/getRouters` | 无参 |  |  |  |  | — |
| 18 | sdk-smp-api | — | `index.ts`:98 | authApi.password | PUT | `/system/user/profile/updatePwd` | Body |  |  | 是 |  | — |
| 19 | sdk-smp-api | — | `index.ts`:113 | venueApi.list | GET | `/smp/venue/list` | Query+Body | 是 |  |  |  | — |
| 20 | sdk-smp-api | 后端已按正常状态过滤并支持 excludeId 排除自身子树，节点只有 id/label/children | `index.ts`:122 | venueApi.tree | GET | `/smp/venue/tree` | 无参 |  |  |  | 是 | — |
| 21 | sdk-smp-api | — | `index.ts`:126 | venueApi.detail | GET | `/smp/venue/` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 22 | sdk-smp-api | — | `index.ts`:128 | venueApi.save | POST/PUT | `/smp/venue` | Body |  |  | 是 |  | — |
| 23 | sdk-smp-api | — | `index.ts`:133 | venueApi.remove | DELETE | `/smp/venue/` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 24 | sdk-smp-api | — | `index.ts`:138 | venueApi.sort | PUT | `/smp/venue` | Query |  |  | 是 |  | — |
| 25 | sdk-smp-api | — | `index.ts`:179 | menuApi.list | GET | `/system/menu/list` | 无参 | 是 |  |  |  | — |
| 26 | sdk-smp-api | — | `index.ts`:181 | menuApi.detail | GET | `/system/menu/` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 27 | sdk-smp-api | — | `index.ts`:185 | menuApi.save | POST/PUT | `/system/menu` | Body |  |  | 是 |  | — |
| 28 | sdk-smp-api | — | `index.ts`:190 | menuApi.remove | DELETE | `/system/menu/` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 29 | sdk-smp-api | — | `index.ts`:192 | menuApi.sort | PUT | `/system/menu/updateSort` | Body |  |  | 是 |  | — |
| 30 | sdk-smp-api | 查询缓存详细 | `modules/monitor/cache.ts`:6 | getCache | GET | `/monitor/cache` | 无参 |  |  |  |  | — |
| 31 | sdk-smp-api | 查询缓存名称列表 | `modules/monitor/cache.ts`:14 | listCacheName | GET | `/monitor/cache/getNames` | 无参 | 是 |  |  |  | — |
| 32 | sdk-smp-api | 查询缓存键名列表 | `modules/monitor/cache.ts`:22 | listCacheKey | GET | `/monitor/cache/getKeys/${cacheName}` | 路径含ID/动态 | 是 | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 33 | sdk-smp-api | 查询缓存内容 | `modules/monitor/cache.ts`:30 | getCacheValue | GET | `/monitor/cache/getValue/${cacheName}/${cacheKey}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 34 | sdk-smp-api | 清理指定名称缓存 | `modules/monitor/cache.ts`:38 | clearCacheName | DELETE | `/monitor/cache/clearCacheName/${cacheName}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 35 | sdk-smp-api | 清理指定键名缓存 | `modules/monitor/cache.ts`:46 | clearCacheKey | DELETE | `/monitor/cache/clearCacheKey/${cacheKey}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 36 | sdk-smp-api | 清理全部缓存 | `modules/monitor/cache.ts`:54 | clearCacheAll | DELETE | `/monitor/cache/clearCacheAll` | 无参 |  |  | 是 |  | — |
| 37 | sdk-smp-api | 分页查询变更日志列表 | `modules/monitor/datalog.ts`:6 | listDataChangeLog | GET | `/monitor/datalog/list` | Query | 是 |  |  |  | — |
| 38 | sdk-smp-api | 查询某条记录的完整变更历史 | `modules/monitor/datalog.ts`:15 | getChangeHistory | GET | `/monitor/datalog/history/${tableName}/${recordId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 39 | sdk-smp-api | 根据日志 ID 查询变更详情（含字段级 diff） | `modules/monitor/datalog.ts`:23 | getDataChangeLogDetail | GET | `/monitor/datalog/${id}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 40 | sdk-smp-api | 查询定时任务调度列表 | `modules/monitor/job.ts`:6 | listJob | GET | `/monitor/job/list` | Query | 是 |  |  |  | — |
| 41 | sdk-smp-api | 查询定时任务调度详细 | `modules/monitor/job.ts`:15 | getJob | GET | `/monitor/job/${jobId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 42 | sdk-smp-api | 新增定时任务调度 | `modules/monitor/job.ts`:23 | addJob | POST | `/monitor/job` | 无参 |  |  | 是 |  | — |
| 43 | sdk-smp-api | 修改定时任务调度 | `modules/monitor/job.ts`:32 | updateJob | PUT | `/monitor/job` | 无参 |  |  | 是 |  | — |
| 44 | sdk-smp-api | 删除定时任务调度 | `modules/monitor/job.ts`:41 | delJob | DELETE | `/monitor/job/${jobId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 45 | sdk-smp-api | 任务状态修改 | `modules/monitor/job.ts`:53 | changeJobStatus | PUT | `/monitor/job/changeStatus` | 无参 |  |  | 是 |  | — |
| 46 | sdk-smp-api | 定时任务立即执行一次 | `modules/monitor/job.ts`:66 | runJob | PUT | `/monitor/job/run` | 无参 |  |  | 是 |  | — |
| 47 | sdk-smp-api | 查询调度日志列表 | `modules/monitor/jobLog.ts`:6 | listJobLog | GET | `/monitor/jobLog/list` | Query | 是 |  |  |  | — |
| 48 | sdk-smp-api | 删除调度日志 | `modules/monitor/jobLog.ts`:15 | delJobLog | DELETE | `/monitor/jobLog/${jobLogId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 49 | sdk-smp-api | 清空调度日志 | `modules/monitor/jobLog.ts`:23 | cleanJobLog | DELETE | `/monitor/jobLog/clean` | 无参 |  |  | 是 |  | — |
| 50 | sdk-smp-api | 查询登录日志列表 | `modules/monitor/logininfor.ts`:6 | list | GET | `/system/logininfor/list` | Query | 是 |  |  |  | — |
| 51 | sdk-smp-api | 删除登录日志 | `modules/monitor/logininfor.ts`:15 | delLogininfor | DELETE | `/system/logininfor/${infoId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 52 | sdk-smp-api | 解锁用户登录状态 | `modules/monitor/logininfor.ts`:23 | unlockLogininfor | GET | `/system/logininfor/unlock/${userName}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 53 | sdk-smp-api | 清空登录日志 | `modules/monitor/logininfor.ts`:31 | cleanLogininfor | DELETE | `/system/logininfor/clean` | 无参 |  |  | 是 |  | — |
| 54 | sdk-smp-api | 查询在线用户列表 | `modules/monitor/online.ts`:6 | list | GET | `/system/online/list` | Query | 是 |  |  |  | — |
| 55 | sdk-smp-api | 强退用户 | `modules/monitor/online.ts`:15 | forceLogout | DELETE | `/system/online/${tokenId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 56 | sdk-smp-api | 查询操作日志列表 | `modules/monitor/operlog.ts`:6 | list | GET | `/system/operlog/list` | Query | 是 |  |  |  | — |
| 57 | sdk-smp-api | 删除操作日志 | `modules/monitor/operlog.ts`:15 | delOperlog | DELETE | `/system/operlog/${operId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 58 | sdk-smp-api | 清空操作日志 | `modules/monitor/operlog.ts`:23 | cleanOperlog | DELETE | `/system/operlog/clean` | 无参 |  |  | 是 |  | — |
| 59 | sdk-smp-api | 获取服务信息 | `modules/monitor/server.ts`:6 | getServer | GET | `/monitor/server` | 无参 |  |  |  |  | — |
| 60 | sdk-smp-api | 查询场地管理列表 | `modules/smp/venue.ts`:6 | listVenue | GET | `/smp/venue/list` | Query | 是 |  |  |  | — |
| 61 | sdk-smp-api | — | `modules/smp/venue.ts`:14 | treeVenue | GET | `/smp/venue/tree` | Query |  |  |  | 是 | — |
| 62 | sdk-smp-api | 查询场地管理详细 | `modules/smp/venue.ts`:23 | getVenue | GET | `/smp/venue/${venueId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 63 | sdk-smp-api | 新增场地管理 | `modules/smp/venue.ts`:31 | addVenue | POST | `/smp/venue` | 无参 |  |  | 是 |  | — |
| 64 | sdk-smp-api | 修改场地管理 | `modules/smp/venue.ts`:40 | updateVenue | PUT | `/smp/venue` | 无参 |  |  | 是 |  | — |
| 65 | sdk-smp-api | 删除场地管理 | `modules/smp/venue.ts`:49 | delVenue | DELETE | `/smp/venue/${venueId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 66 | sdk-smp-api | 查询参数列表 | `modules/system/config.ts`:6 | listConfig | GET | `/system/config/list` | Query | 是 |  |  |  | — |
| 67 | sdk-smp-api | 查询参数详细 | `modules/system/config.ts`:15 | getConfig | GET | `/system/config/${configId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 68 | sdk-smp-api | 根据参数键名查询参数值 | `modules/system/config.ts`:23 | getConfigKey | GET | `/system/config/configKey/${configKey}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 69 | sdk-smp-api | 新增参数配置 | `modules/system/config.ts`:31 | addConfig | POST | `/system/config` | 无参 |  |  | 是 |  | — |
| 70 | sdk-smp-api | 修改参数配置 | `modules/system/config.ts`:40 | updateConfig | PUT | `/system/config` | 无参 |  |  | 是 |  | — |
| 71 | sdk-smp-api | 删除参数配置 | `modules/system/config.ts`:49 | delConfig | DELETE | `/system/config/${configId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 72 | sdk-smp-api | 刷新参数缓存 | `modules/system/config.ts`:57 | refreshCache | DELETE | `/system/config/refreshCache` | 无参 |  |  | 是 |  | — |
| 73 | sdk-smp-api | 查询部门列表 | `modules/system/dept.ts`:6 | listDept | GET | `/system/dept/list` | Query | 是 |  |  |  | — |
| 74 | sdk-smp-api | 查询部门列表（排除节点） | `modules/system/dept.ts`:15 | listDeptExcludeChild | GET | `/system/dept/list/exclude/${deptId}` | 路径含ID/动态 | 是 | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 75 | sdk-smp-api | 查询部门详细 | `modules/system/dept.ts`:23 | getDept | GET | `/system/dept/${deptId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 76 | sdk-smp-api | 新增部门 | `modules/system/dept.ts`:31 | addDept | POST | `/system/dept` | 无参 |  |  | 是 |  | — |
| 77 | sdk-smp-api | 修改部门 | `modules/system/dept.ts`:40 | updateDept | PUT | `/system/dept` | 无参 |  |  | 是 |  | — |
| 78 | sdk-smp-api | 保存部门排序 | `modules/system/dept.ts`:49 | updateDeptSort | PUT | `/system/dept/updateSort` | 无参 |  |  | 是 |  | — |
| 79 | sdk-smp-api | 删除部门 | `modules/system/dept.ts`:58 | delDept | DELETE | `/system/dept/${deptId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 80 | sdk-smp-api | 查询部门员工列表（含在线状态） | `modules/system/dept.ts`:66 | getDeptUsers | GET | `/system/user/deptUsers` | Query |  |  |  |  | — |
| 81 | sdk-smp-api | 查询字典数据列表 | `modules/system/dict/data.ts`:6 | listData | GET | `/system/dict/data/list` | Query | 是 |  |  |  | — |
| 82 | sdk-smp-api | 查询字典数据详细 | `modules/system/dict/data.ts`:14 | getData | GET | `/system/dict/data/${dictCode}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 83 | sdk-smp-api | 根据字典类型查询一级字典数据（parentValue 为空） | `modules/system/dict/data.ts`:19 | getDicts | GET | `/system/dict/data/type/${dictType}` | 路径含ID/动态 |  | 是 |  | 是 | 路径含动态ID/变量，需运行时确认 |
| 84 | sdk-smp-api | 查询字典树（含 children）数据 | `modules/system/dict/data.ts`:25 | getDictTree | GET | `/system/dict/data/type/${dictType}/tree` | 路径含ID/动态 |  | 是 |  | 是 | 路径含动态ID/变量，需运行时确认 |
| 85 | sdk-smp-api | @param {string} parentValue 父级 dictValue | `modules/system/dict/data.ts`:37 | getDictChildren | GET | `/system/dict/data/type/${dictType}/children/${parentValue}` | 路径含ID/动态 |  | 是 |  | 是 | 路径含动态ID/变量，需运行时确认 |
| 86 | sdk-smp-api | @param {{ dictType, dictValue, excludeCode }} params | `modules/system/dict/data.ts`:48 | checkValueUnique | GET | `/system/dict/data/checkValueUnique` | 无参 |  |  |  |  | — |
| 87 | sdk-smp-api | @param {{ dictType, dictLabel, excludeCode }} params | `modules/system/dict/data.ts`:60 | checkDictLabelUnique | GET | `/system/dict/data/checkLabelUnique` | 无参 |  |  |  |  | — |
| 88 | sdk-smp-api | 新增字典数据 | `modules/system/dict/data.ts`:68 | addData | POST | `/system/dict/data` | Body |  |  | 是 |  | — |
| 89 | sdk-smp-api | 修改字典数据 | `modules/system/dict/data.ts`:73 | updateData | PUT | `/system/dict/data` | Body |  |  | 是 |  | — |
| 90 | sdk-smp-api | @param {string} childAction        一级项的子级处理策略：cascade（默认）| orphan | `modules/system/dict/data.ts`:84 | delData | DELETE | `/system/dict/data/${codes}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 91 | sdk-smp-api | 查询菜单列表 | `modules/system/menu.ts`:6 | listMenu | GET | `/system/menu/list` | Query | 是 |  |  |  | — |
| 92 | sdk-smp-api | 查询菜单详细 | `modules/system/menu.ts`:15 | getMenu | GET | `/system/menu/${menuId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 93 | sdk-smp-api | 查询菜单下拉树结构 | `modules/system/menu.ts`:23 | treeselect | GET | `/system/menu/treeselect` | 无参 |  |  |  | 是 | — |
| 94 | sdk-smp-api | 根据角色ID查询菜单下拉树结构 | `modules/system/menu.ts`:31 | roleMenuTreeselect | GET | `/system/menu/roleMenuTreeselect/${roleId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 95 | sdk-smp-api | 新增菜单 | `modules/system/menu.ts`:39 | addMenu | POST | `/system/menu` | 无参 |  |  | 是 |  | — |
| 96 | sdk-smp-api | 修改菜单 | `modules/system/menu.ts`:48 | updateMenu | PUT | `/system/menu` | 无参 |  |  | 是 |  | — |
| 97 | sdk-smp-api | 保存菜单排序 | `modules/system/menu.ts`:57 | updateMenuSort | PUT | `/system/menu/updateSort` | 无参 |  |  | 是 |  | — |
| 98 | sdk-smp-api | 删除菜单 | `modules/system/menu.ts`:66 | delMenu | DELETE | `/system/menu/${menuId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 99 | sdk-smp-api | 查询公告列表 | `modules/system/notice.ts`:6 | listNotice | GET | `/system/notice/list` | Query | 是 |  |  |  | — |
| 100 | sdk-smp-api | 查询公告详细 | `modules/system/notice.ts`:15 | getNotice | GET | `/system/notice/${noticeId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 101 | sdk-smp-api | 新增公告 | `modules/system/notice.ts`:23 | addNotice | POST | `/system/notice` | 无参 |  |  | 是 |  | — |
| 102 | sdk-smp-api | 修改公告 | `modules/system/notice.ts`:32 | updateNotice | PUT | `/system/notice` | 无参 |  |  | 是 |  | — |
| 103 | sdk-smp-api | 删除公告 | `modules/system/notice.ts`:41 | delNotice | DELETE | `/system/notice/${noticeId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 104 | sdk-smp-api | 首页顶部公告列表（带已读状态） | `modules/system/notice.ts`:49 | listNoticeTop | GET | `/system/notice/listTop` | 无参 | 是 |  |  |  | — |
| 105 | sdk-smp-api | 标记公告已读 | `modules/system/notice.ts`:57 | markNoticeRead | POST | `/system/notice/markRead` | Query |  |  | 是 |  | — |
| 106 | sdk-smp-api | 批量标记已读 | `modules/system/notice.ts`:66 | markNoticeReadAll | POST | `/system/notice/markReadAll` | Query |  |  | 是 |  | — |
| 107 | sdk-smp-api | 查询公告已读用户列表 | `modules/system/notice.ts`:75 | listNoticeReadUsers | GET | `/system/notice/readUsers/list` | Query | 是 |  |  |  | — |
| 108 | sdk-smp-api | 查询用户密码历史记录列表 | `modules/system/pwdhistory.ts`:6 | listPwdhistory | GET | `/system/pwdhistory/list` | Query | 是 |  |  |  | — |
| 109 | sdk-smp-api | 查询用户密码历史记录详细 | `modules/system/pwdhistory.ts`:15 | getPwdhistory | GET | `/system/pwdhistory/${id}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 110 | sdk-smp-api | 新增用户密码历史记录 | `modules/system/pwdhistory.ts`:23 | addPwdhistory | POST | `/system/pwdhistory` | 无参 |  |  | 是 |  | — |
| 111 | sdk-smp-api | 修改用户密码历史记录 | `modules/system/pwdhistory.ts`:32 | updatePwdhistory | PUT | `/system/pwdhistory` | 无参 |  |  | 是 |  | — |
| 112 | sdk-smp-api | 删除用户密码历史记录 | `modules/system/pwdhistory.ts`:41 | delPwdhistory | DELETE | `/system/pwdhistory/${id}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 113 | sdk-smp-api | 查询角色列表 | `modules/system/role.ts`:6 | listRole | GET | `/system/role/list` | Query | 是 |  |  |  | — |
| 114 | sdk-smp-api | 查询角色详细 | `modules/system/role.ts`:15 | getRole | GET | `/system/role/${roleId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 115 | sdk-smp-api | 新增角色 | `modules/system/role.ts`:23 | addRole | POST | `/system/role` | 无参 |  |  | 是 |  | — |
| 116 | sdk-smp-api | 修改角色 | `modules/system/role.ts`:32 | updateRole | PUT | `/system/role` | 无参 |  |  | 是 |  | — |
| 117 | sdk-smp-api | 角色数据权限 | `modules/system/role.ts`:41 | dataScope | PUT | `/system/role/dataScope` | 无参 |  |  | 是 |  | — |
| 118 | sdk-smp-api | 角色状态修改 | `modules/system/role.ts`:54 | changeRoleStatus | PUT | `/system/role/changeStatus` | 无参 |  |  | 是 |  | — |
| 119 | sdk-smp-api | 删除角色 | `modules/system/role.ts`:63 | delRole | DELETE | `/system/role/${roleId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 120 | sdk-smp-api | 查询角色已授权用户列表 | `modules/system/role.ts`:71 | allocatedUserList | GET | `/system/role/authUser/allocatedList` | Query |  |  |  |  | — |
| 121 | sdk-smp-api | 查询角色未授权用户列表 | `modules/system/role.ts`:80 | unallocatedUserList | GET | `/system/role/authUser/unallocatedList` | Query |  |  |  |  | — |
| 122 | sdk-smp-api | 取消用户授权角色 | `modules/system/role.ts`:89 | authUserCancel | PUT | `/system/role/authUser/cancel` | 无参 |  |  | 是 |  | — |
| 123 | sdk-smp-api | 批量取消用户授权角色 | `modules/system/role.ts`:98 | authUserCancelAll | PUT | `/system/role/authUser/cancelAll` | Query |  |  | 是 |  | — |
| 124 | sdk-smp-api | 授权用户选择 | `modules/system/role.ts`:107 | authUserSelectAll | PUT | `/system/role/authUser/selectAll` | Query |  |  | 是 |  | — |
| 125 | sdk-smp-api | 根据角色ID查询部门树结构 | `modules/system/role.ts`:116 | deptTreeSelect | GET | `/system/role/deptTree/${roleId}` | Query+动态路径 |  | 是 |  | 是 | 路径含动态ID/变量，需运行时确认 |
| 126 | sdk-smp-api | 查询角色下的用户列表（含部门、角色、在线状态） | `modules/system/role.ts`:124 | getRoleUsers | GET | `/system/role/roleUsers` | Query |  |  |  |  | — |
| 127 | sdk-smp-api | — | `modules/system/user.ts`:20 | listUser | GET | `/system/user/list` | Query | 是 |  |  |  | — |
| 128 | sdk-smp-api | 查询用户详细 | `modules/system/user.ts`:33 | getUser | GET | `/system/user/${parseStrEmpty(userId)}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 129 | sdk-smp-api | 新增用户 | `modules/system/user.ts`:41 | addUser | POST | `/system/user` | 无参 |  |  | 是 |  | — |
| 130 | sdk-smp-api | 修改用户 | `modules/system/user.ts`:50 | updateUser | PUT | `/system/user` | 无参 |  |  | 是 |  | — |
| 131 | sdk-smp-api | 删除用户 | `modules/system/user.ts`:59 | delUser | DELETE | `/system/user/${userId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 132 | sdk-smp-api | 用户密码重置 | `modules/system/user.ts`:71 | resetUserPwd | PUT | `/system/user/resetPwd` | 无参 |  |  | 是 |  | — |
| 133 | sdk-smp-api | 用户状态修改 | `modules/system/user.ts`:84 | changeUserStatus | PUT | `/system/user/changeStatus` | 无参 |  |  | 是 |  | — |
| 134 | sdk-smp-api | 查询用户个人信息 | `modules/system/user.ts`:93 | getUserProfile | GET | `/system/user/profile` | Body |  |  |  |  | — |
| 135 | sdk-smp-api | 修改用户个人信息 | `modules/system/user.ts`:101 | updateUserProfile | PUT | `/system/user/profile` | 无参 |  |  | 是 |  | — |
| 136 | sdk-smp-api | 用户密码重置 | `modules/system/user.ts`:114 | updateUserPwd | PUT | `/system/user/profile/updatePwd` | 无参 |  |  | 是 |  | — |
| 137 | sdk-smp-api | 用户头像上传 | `modules/system/user.ts`:123 | uploadAvatar | POST | `/system/user/profile/avatar` | 无参 |  |  | 是 |  | — |
| 138 | sdk-smp-api | 查询授权角色 | `modules/system/user.ts`:133 | getAuthRole | GET | `/system/user/authRole/${userId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 139 | sdk-smp-api | 保存授权角色 | `modules/system/user.ts`:141 | updateAuthRole | PUT | `/system/user/authRole` | Query |  |  | 是 |  | — |
| 140 | sdk-smp-api | 查询部门下拉树结构 | `modules/system/user.ts`:150 | deptTreeSelect | GET | `/system/user/deptTree` | Query |  |  |  | 是 | — |
| 141 | sdk-smp-api | 查询用户已分配的角色列表 | `modules/system/user.ts`:158 | allocatedRoleList | GET | `/system/user/authRole/allocatedList` | Query |  |  |  |  | — |
| 142 | sdk-smp-api | 查询用户未分配的角色列表 | `modules/system/user.ts`:167 | unallocatedRoleList | GET | `/system/user/authRole/unallocatedList` | Query |  |  |  |  | — |
| 143 | sdk-smp-api | 取消用户角色授权 | `modules/system/user.ts`:176 | authRoleCancel | PUT | `/system/user/authRole/cancel` | 无参 |  |  | 是 |  | — |
| 144 | sdk-smp-api | 批量取消用户角色授权 | `modules/system/user.ts`:185 | authRoleCancelAll | PUT | `/system/user/authRole/cancelAll` | Query |  |  | 是 |  | — |
| 145 | sdk-smp-api | 批量选择角色授权给用户 | `modules/system/user.ts`:194 | authRoleSelectAll | PUT | `/system/user/authRole/selectAll` | Query |  |  | 是 |  | — |
| 146 | sdk-smp-api | 查询密码有效期设置（含用户列表） | `modules/system/user.ts`:203 | getPasswordValidity | GET | `/system/user/passwordValidity` | Query |  |  |  |  | — |
| 147 | sdk-smp-api | 保存密码有效期设置 | `modules/system/user.ts`:213 | savePasswordValidity | PUT | `/system/user/passwordValidity` | 无参 |  |  | 是 |  | — |
| 148 | sdk-smp-api | — | `monitor.ts`:98 | operlogApi.list | GET | `/system/operlog/list` | Query | 是 |  |  |  | — |
| 149 | sdk-smp-api | — | `monitor.ts`:113 | logininforApi.list | GET | `/system/logininfor/list` | Query | 是 |  |  |  | — |
| 150 | sdk-smp-api | — | `post.ts`:32 | postApi.detail | GET | `/system/post/` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 151 | sdk-smp-api | — | `post.ts`:36 | postApi.save | POST/PUT | `/system/post` | Body |  |  | 是 |  | — |
| 152 | sdk-smp-api | — | `sysConfig.ts`:69 | sysConfigApi.list | GET | `/system/config/list` | Query | 是 |  |  |  | — |
| 153 | sdk-smp-api | — | `sysConfig.ts`:85 | sysConfigApi.save | POST/PUT | `/system/config` | Body |  |  | 是 |  | — |
| 154 | sdk-smp-api | — | `sysConfig.ts`:98 | sysConfigApi.refreshCache | DELETE | `/system/config/refreshCache` | 无参 |  |  | 是 |  | — |
| 155 | sdk-smp-api | — | `system.ts`:131 | deptApi.list | GET | `/system/dept/list` | 无参 | 是 |  |  |  | — |
| 156 | sdk-smp-api | — | `system.ts`:138 | deptApi.detail | GET | `/system/dept/` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 157 | sdk-smp-api | — | `system.ts`:142 | deptApi.save | POST/PUT | `/system/dept` | Body |  |  | 是 |  | — |
| 158 | sdk-smp-api | — | `system.ts`:148 | deptApi.updateSort | PUT | `/system/dept/updateSort` | Body |  |  | 是 |  | — |
| 159 | sdk-smp-api | — | `system.ts`:156 | deptApi.remove | DELETE | `/system/dept/` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 160 | sdk-smp-api | — | `system.ts`:227 | roleApi.list | GET | `/system/role/list` | Query | 是 |  |  |  | — |
| 161 | sdk-smp-api | — | `system.ts`:232 | roleApi.detail | GET | `/system/role/` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 162 | sdk-smp-api | — | `system.ts`:236 | roleApi.save | POST/PUT | `/system/role` | Body |  |  | 是 |  | — |
| 163 | sdk-smp-api | — | `system.ts`:249 | roleApi.changeStatus | PUT | `/system/role/changeStatus` | Body |  |  | 是 |  | — |
| 164 | sdk-smp-api | — | `system.ts`:258 | roleApi.dataScope | PUT | `/system/role/dataScope` | 无参 |  |  | 是 |  | — |
| 165 | sdk-smp-api | — | `system.ts`:318 | roleApi.selectAll | PUT | `/system/role/authUser/selectAll` | Query |  |  | 是 |  | — |
| 166 | sdk-smp-api | — | `system.ts`:324 | roleApi.cancelAll | PUT | `/system/role/authUser/cancelAll` | Query |  |  | 是 |  | — |
| 167 | sdk-smp-api | — | `system.ts`:330 | roleApi.cancelUser | PUT | `/system/role/authUser/cancel` | Body |  |  | 是 |  | — |
| 168 | sdk-smp-api | — | `system.ts`:339 | menuTreeApi.all | GET | `/system/menu/treeselect` | 无参 |  |  |  | 是 | — |
| 169 | sdk-smp-api | — | `system.ts`:351 | deptTreeApi.list | GET | `/system/user/deptTree` | Query |  |  |  | 是 | — |
| 170 | sdk-smp-api | — | `system.ts`:357 | userApi.list | GET | `/system/user/list` | Query | 是 |  |  |  | — |

## 分类 3：实验室设置类 M02（实验室/分组）

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 171 | app-smp-settings | — | `app-smp-settings/src/views/lab-downstreamdevice/index.vue`:443 | handleExport | POST | `/lab/downstreamdevice/export` | download表单 |  |  | 是 |  | ⚠ 调用点未带前导斜杠，而 `apiUrl()` 强制要求以 / 开头，疑似运行时必然报“接口路径无效”，需联调确认 |
| 172 | sdk-smp-api | — | `calibrationObject.ts`:44 | calibrationObjectApi.save | POST/PUT | `/lab/calibrationObject` | Body |  |  | 是 |  | — |
| 173 | sdk-smp-api | — | `feedMedium.ts`:51 | feedMediumApi.checkUnique | GET | `/lab/feedMedium/check-unique` | Query+Body |  |  |  |  | — |
| 174 | sdk-smp-api | — | `feedMedium.ts`:56 | feedMediumApi.save | POST/PUT | `/lab/feedMedium` | Body |  |  | 是 |  | — |
| 175 | sdk-smp-api | — | `index.ts`:86 | authApi.labs | GET | `/lab/lab/options` | Query |  |  |  | 是 | — |
| 176 | sdk-smp-api | — | `lab.ts`:73 | labApi.detail | GET | `/lab/lab/` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 177 | sdk-smp-api | — | `lab.ts`:77 | labApi.save | POST/PUT | `/lab/lab` | Body |  |  | 是 |  | — |
| 178 | sdk-smp-api | — | `lab.ts`:96 | labApi.saveLeaders | PUT | `/lab/lab/` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 179 | sdk-smp-api | — | `lab.ts`:114 | labApi.checkDisable | GET | `/lab/lab/` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 180 | sdk-smp-api | — | `lab.ts`:116 | labApi.updateStatus | PUT | `/lab/lab/` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 181 | sdk-smp-api | — | `lab.ts`:127 | labApi.saveWorkflows | PUT | `/lab/lab/` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 182 | sdk-smp-api | — | `labgroup.ts`:98 | labgroupApi.list | GET | `/smp/labgroup/list` | Query | 是 |  |  |  | — |
| 183 | sdk-smp-api | — | `labgroup.ts`:103 | labgroupApi.detail | GET | `/smp/labgroup/` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 184 | sdk-smp-api | — | `labgroup.ts`:108 | labgroupApi.memberTree | GET | `/smp/labgroup/member-tree` | Query |  |  |  |  | — |
| 185 | sdk-smp-api | — | `labgroup.ts`:118 | labgroupApi.save | POST/PUT | `/smp/labgroup` | Body |  |  | 是 |  | — |
| 186 | sdk-smp-api | — | `labgroup.ts`:123 | labgroupApi.remove | DELETE | `/smp/labgroup/` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 187 | sdk-smp-api | — | `liquidBag.ts`:61 | liquidBagApi.checkUnique | GET | `/lab/liquidBag/check-unique` | Query+Body |  |  |  |  | — |
| 188 | sdk-smp-api | — | `liquidBag.ts`:66 | liquidBagApi.save | POST/PUT | `/lab/liquidBag` | Body |  |  | 是 |  | — |
| 189 | sdk-smp-api | 查询实验室空气泵列表 | `modules/lab/airpump.ts`:6 | listAirpump | GET | `/lab/airpump/list` | Query | 是 |  |  |  | — |
| 190 | sdk-smp-api | 查询实验室空气泵详细 | `modules/lab/airpump.ts`:15 | getAirpump | GET | `/lab/airpump/${airPumpId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 191 | sdk-smp-api | 新增实验室空气泵 | `modules/lab/airpump.ts`:23 | addAirpump | POST | `/lab/airpump` | 无参 |  |  | 是 |  | — |
| 192 | sdk-smp-api | 修改实验室空气泵 | `modules/lab/airpump.ts`:32 | updateAirpump | PUT | `/lab/airpump` | 无参 |  |  | 是 |  | — |
| 193 | sdk-smp-api | 删除实验室空气泵 | `modules/lab/airpump.ts`:41 | delAirpump | DELETE | `/lab/airpump/${airPumpId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 194 | sdk-smp-api | 查询实验室天平列表 | `modules/lab/balance.ts`:6 | listBalance | GET | `/lab/balance/list` | Query | 是 |  |  |  | — |
| 195 | sdk-smp-api | 查询实验室天平详细 | `modules/lab/balance.ts`:15 | getBalance | GET | `/lab/balance/${balanceId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 196 | sdk-smp-api | 新增实验室天平 | `modules/lab/balance.ts`:23 | addBalance | POST | `/lab/balance` | 无参 |  |  | 是 |  | — |
| 197 | sdk-smp-api | 修改实验室天平 | `modules/lab/balance.ts`:32 | updateBalance | PUT | `/lab/balance` | 无参 |  |  | 是 |  | — |
| 198 | sdk-smp-api | 删除实验室天平 | `modules/lab/balance.ts`:41 | delBalance | DELETE | `/lab/balance/${balanceId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 199 | sdk-smp-api | — | `modules/lab/balance.ts`:48 | checkUnique | GET | `/lab/balance/check-unique` | 无参 |  |  |  |  | — |
| 200 | sdk-smp-api | — | `modules/lab/balance.ts`:56 | checkCanDelete | GET | `/lab/balance/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 201 | sdk-smp-api | 变更维护状态 | `modules/lab/balance.ts`:65 | changeMaintainStatus | PUT | `/lab/balance/changeMaintainStatus` | 无参 |  |  | 是 |  | — |
| 202 | sdk-smp-api | 查询泵默认连接主列表 | `modules/lab/benchreactorcontroller.ts`:6 | listPumpconnection | GET | `/lab/pumpconnection/list` | Query | 是 |  |  |  | — |
| 203 | sdk-smp-api | 查询泵默认连接主详细 | `modules/lab/benchreactorcontroller.ts`:15 | getPumpconnection | GET | `/lab/pumpconnection/${connectionId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 204 | sdk-smp-api | — | `modules/lab/benchreactorcontroller.ts`:21 | getPumpconnectionByReactor | GET | `/lab/pumpconnection/reactor/${reactorId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 205 | sdk-smp-api | — | `modules/lab/benchreactorcontroller.ts`:27 | savePumpconnectionByReactor | PUT | `/lab/pumpconnection/reactor/${reactorId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 206 | sdk-smp-api | — | `modules/lab/benchreactorcontroller.ts`:35 | checkCanDelete | GET | `/lab/pumpconnection/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 207 | sdk-smp-api | 查询泵连接通道列表 | `modules/lab/benchreactorcontrollerchannel.ts`:6 | listPumpchannel | GET | `/lab/pumpchannel/list` | Query | 是 |  |  |  | — |
| 208 | sdk-smp-api | 查询泵连接通道详细 | `modules/lab/benchreactorcontrollerchannel.ts`:15 | getPumpchannel | GET | `/lab/pumpchannel/${channelId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 209 | sdk-smp-api | 新增泵连接通道 | `modules/lab/benchreactorcontrollerchannel.ts`:23 | addPumpchannel | POST | `/lab/pumpchannel` | 无参 |  |  | 是 |  | — |
| 210 | sdk-smp-api | 修改泵连接通道 | `modules/lab/benchreactorcontrollerchannel.ts`:32 | updatePumpchannel | PUT | `/lab/pumpchannel` | 无参 |  |  | 是 |  | — |
| 211 | sdk-smp-api | 删除泵连接通道 | `modules/lab/benchreactorcontrollerchannel.ts`:41 | delPumpchannel | DELETE | `/lab/pumpchannel/${channelId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 212 | sdk-smp-api | 查询桶类耗材下拉 | `modules/lab/bottle-config.ts`:8 | listBottleConfigConsumables | GET | `/lab/bottle-config/consumables` | 无参 | 是 |  |  |  | — |
| 213 | sdk-smp-api | 查询液瓶配置布局 | `modules/lab/bottle-config.ts`:18 | getBottleConfigLayout | GET | `/lab/bottle-config/layout` | Query |  |  |  |  | — |
| 214 | sdk-smp-api | 保存取样单元（3槽位） | `modules/lab/bottle-config.ts`:34 | saveBottleConfigSamplingUnit | PUT | `/lab/bottle-config/sampling-units/${labId}/${unitCode}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 215 | sdk-smp-api | 保存补料泵位 | `modules/lab/bottle-config.ts`:45 | saveBottleConfigFeedingSlot | PUT | `/lab/bottle-config/feeding-slots/${bottleId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 216 | sdk-smp-api | 根据主键查询通讯配置详情 | `modules/lab/communication.ts`:6 | getCommunication | GET | `/lab/communication/${commId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 217 | sdk-smp-api | 根据设备ID查询通讯配置 | `modules/lab/communication.ts`:14 | getCommunicationByDevice | GET | `/lab/communication/getByDevice` | Query |  |  |  |  | — |
| 218 | sdk-smp-api | 新增通讯配置 | `modules/lab/communication.ts`:23 | addCommunication | POST | `/lab/communication` | 无参 |  |  | 是 |  | — |
| 219 | sdk-smp-api | 修改通讯配置 | `modules/lab/communication.ts`:32 | updateCommunication | PUT | `/lab/communication` | 无参 |  |  | 是 |  | — |
| 220 | sdk-smp-api | 查询配置页面初始化数据 | `modules/lab/consumptionRule.ts`:6 | getConsumptionRuleBootstrap | GET | `/lab/consumptionRule/bootstrap` | 无参 |  |  |  |  | — |
| 221 | sdk-smp-api | 查询实验室+页签配置 | `modules/lab/consumptionRule.ts`:15 | getConsumptionRuleConfig | GET | `/lab/consumptionRule/config` | 无参 |  |  |  |  | — |
| 222 | sdk-smp-api | 查询耗材选项 | `modules/lab/consumptionRule.ts`:25 | getConsumableOptions | GET | `/lab/consumptionRule/consumable-options` | 无参 |  |  |  |  | — |
| 223 | sdk-smp-api | 保存实验室+页签配置 | `modules/lab/consumptionRule.ts`:34 | saveConsumptionRuleConfig | PUT | `/lab/consumptionRule/config` | 无参 |  |  | 是 |  | — |
| 224 | sdk-smp-api | 查询培养容器列表 | `modules/lab/culturecontainer.ts`:6 | listCulturecontainer | GET | `/lab/culturecontainer/list` | Query | 是 |  |  |  | — |
| 225 | sdk-smp-api | 查询培养容器详细 | `modules/lab/culturecontainer.ts`:15 | getCulturecontainer | GET | `/lab/culturecontainer/${containerId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 226 | sdk-smp-api | 新增培养容器 | `modules/lab/culturecontainer.ts`:23 | addCulturecontainer | POST | `/lab/culturecontainer` | 无参 |  |  | 是 |  | — |
| 227 | sdk-smp-api | 修改培养容器 | `modules/lab/culturecontainer.ts`:32 | updateCulturecontainer | PUT | `/lab/culturecontainer` | 无参 |  |  | 是 |  | — |
| 228 | sdk-smp-api | 删除培养容器 | `modules/lab/culturecontainer.ts`:41 | delCulturecontainer | DELETE | `/lab/culturecontainer/${containerId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 229 | sdk-smp-api | 校验容器名称在同一实验室内唯一 | `modules/lab/culturecontainer.ts`:49 | checkContainerName | GET | `/lab/culturecontainer/check-container-name` | 无参 |  |  |  |  | — |
| 230 | sdk-smp-api | — | `modules/lab/culturecontainer.ts`:57 | checkCanDelete | GET | `/lab/culturecontainer/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 231 | sdk-smp-api | 查询检测设备检测项启用配置详细 | `modules/lab/detectorconfig.ts`:6 | getDetectorconfig | GET | `/lab/detectorconfig/${detectorId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 232 | sdk-smp-api | 新增检测设备检测项启用配置 | `modules/lab/detectorconfig.ts`:14 | addDetectorconfig | POST | `/lab/detectorconfig` | 无参 |  |  | 是 |  | — |
| 233 | sdk-smp-api | 修改检测设备检测项启用配置 | `modules/lab/detectorconfig.ts`:23 | updateDetectorconfig | PUT | `/lab/detectorconfig` | 无参 |  |  | 是 |  | — |
| 234 | sdk-smp-api | — | `modules/lab/detectorconfig.ts`:31 | batchSave | POST | `/lab/detectorconfig/${detectorId}/batch-save` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 235 | sdk-smp-api | — | `modules/lab/detectorconfig.ts`:39 | getAvailableItems | GET | `/lab/detectorconfig/${detectorId}/available-items` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 236 | sdk-smp-api | 查询实验室下游设备列表 | `modules/lab/downstreamdevice.ts`:6 | listLabdownstreamdevice | GET | `/lab/downstreamdevice/list` | Query | 是 |  |  |  | — |
| 237 | sdk-smp-api | 查询实验室下游设备详细 | `modules/lab/downstreamdevice.ts`:15 | getLabdownstreamdevice | GET | `/lab/downstreamdevice/${deviceId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 238 | sdk-smp-api | 新增实验室下游设备 | `modules/lab/downstreamdevice.ts`:23 | addLabdownstreamdevice | POST | `/lab/downstreamdevice` | 无参 |  |  | 是 |  | — |
| 239 | sdk-smp-api | 修改实验室下游设备 | `modules/lab/downstreamdevice.ts`:32 | updateLabdownstreamdevice | PUT | `/lab/downstreamdevice` | 无参 |  |  | 是 |  | — |
| 240 | sdk-smp-api | 删除实验室下游设备 | `modules/lab/downstreamdevice.ts`:41 | delLabdownstreamdevice | DELETE | `/lab/downstreamdevice/${deviceId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 241 | sdk-smp-api | — | `modules/lab/downstreamdevice.ts`:49 | checkUnique | GET | `/lab/downstreamdevice/check-unique` | 无参 |  |  |  |  | — |
| 242 | sdk-smp-api | — | `modules/lab/downstreamdevice.ts`:58 | checkDeviceNo | GET | `/lab/downstreamdevice/check-device-no` | 无参 |  |  |  |  | — |
| 243 | sdk-smp-api | — | `modules/lab/downstreamdevice.ts`:66 | checkCanDelete | GET | `/lab/downstreamdevice/${id}/check-delete` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 244 | sdk-smp-api | 变更启用/禁用状态 | `modules/lab/downstreamdevice.ts`:74 | changeStatus | PUT | `/lab/downstreamdevice/changeStatus` | 无参 |  |  | 是 |  | — |
| 245 | sdk-smp-api | — | `modules/lab/lab.ts`:5 | listLab | GET | `/lab/lab/list` | Query | 是 |  |  |  | — |
| 246 | sdk-smp-api | 查询实验室下拉选项（精简字段，不分页） | `modules/lab/lab.ts`:14 | listLabOptions | GET | `/lab/lab/options` | Query | 是 |  |  | 是 | — |
| 247 | sdk-smp-api | — | `modules/lab/lab.ts`:22 | getLab | GET | `/lab/lab/${labId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 248 | sdk-smp-api | — | `modules/lab/lab.ts`:29 | addLab | POST | `/lab/lab` | Body |  |  | 是 |  | — |
| 249 | sdk-smp-api | — | `modules/lab/lab.ts`:37 | updateLab | PUT | `/lab/lab` | 无参 |  |  | 是 |  | — |
| 250 | sdk-smp-api | — | `modules/lab/lab.ts`:45 | delLab | DELETE | `/lab/lab/${labId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 251 | sdk-smp-api | — | `modules/lab/lab.ts`:52 | getLeaders | GET | `/lab/lab/${labId}/leaders` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 252 | sdk-smp-api | — | `modules/lab/lab.ts`:59 | saveLeaders | PUT | `/lab/lab/${labId}/leaders` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 253 | sdk-smp-api | 分页查询实验室授权用户列表 | `modules/lab/lab.ts`:68 | getAuthorizedUsers | GET | `/lab/lab/${labId}/authorized-users` | Query+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 254 | sdk-smp-api | — | `modules/lab/lab.ts`:76 | checkDisable | GET | `/lab/lab/${labId}/check-disable` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 255 | sdk-smp-api | — | `modules/lab/lab.ts`:83 | updateStatus | PUT | `/lab/lab/${labId}/status` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 256 | sdk-smp-api | — | `modules/lab/lab.ts`:91 | getLabWorkflows | GET | `/lab/lab/${labId}/workflows` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 257 | sdk-smp-api | — | `modules/lab/lab.ts`:98 | saveLabWorkflows | PUT | `/lab/lab/${labId}/workflows` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 258 | sdk-smp-api | 查询实验室空气泵列表 | `modules/lab/labairpump.ts`:6 | listLabairpump | GET | `/lab/labairpump/list` | Query | 是 |  |  |  | — |
| 259 | sdk-smp-api | 查询实验室空气泵详细 | `modules/lab/labairpump.ts`:16 | getLabairpump | GET | `/lab/labairpump/${airPumpId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 260 | sdk-smp-api | 新增实验室空气泵 | `modules/lab/labairpump.ts`:24 | addLabairpump | POST | `/lab/labairpump` | 无参 |  |  | 是 |  | — |
| 261 | sdk-smp-api | 修改实验室空气泵 | `modules/lab/labairpump.ts`:33 | updateLabairpump | PUT | `/lab/labairpump` | 无参 |  |  | 是 |  | — |
| 262 | sdk-smp-api | 删除实验室空气泵 | `modules/lab/labairpump.ts`:42 | delLabairpump | DELETE | `/lab/labairpump/${airPumpId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 263 | sdk-smp-api | — | `modules/lab/labairpump.ts`:49 | checkUnique | GET | `/lab/labairpump/check-unique` | 无参 |  |  |  |  | — |
| 264 | sdk-smp-api | — | `modules/lab/labairpump.ts`:58 | checkDeviceNo | GET | `/lab/labairpump/check-device-no` | 无参 |  |  |  |  | — |
| 265 | sdk-smp-api | — | `modules/lab/labairpump.ts`:66 | checkCanDelete | GET | `/lab/labairpump/${id}/check-delete` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 266 | sdk-smp-api | 变更维护状态 | `modules/lab/labairpump.ts`:74 | changeMaintainStatus | PUT | `/lab/labairpump/changeMaintainStatus` | 无参 |  |  | 是 |  | — |
| 267 | sdk-smp-api | 查询实验室台式反应器列表 | `modules/lab/labbenchreactor.ts`:6 | listLabbenchreactor | GET | `/lab/labbenchreactor/list` | Query | 是 |  |  |  | — |
| 268 | sdk-smp-api | 查询实验室台式反应器详细 | `modules/lab/labbenchreactor.ts`:15 | getLabbenchreactor | GET | `/lab/labbenchreactor/${reactorId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 269 | sdk-smp-api | 新增实验室台式反应器 | `modules/lab/labbenchreactor.ts`:23 | addLabbenchreactor | POST | `/lab/labbenchreactor` | 无参 |  |  | 是 |  | — |
| 270 | sdk-smp-api | 修改实验室台式反应器 | `modules/lab/labbenchreactor.ts`:32 | updateLabbenchreactor | PUT | `/lab/labbenchreactor` | 无参 |  |  | 是 |  | — |
| 271 | sdk-smp-api | 删除实验室台式反应器 | `modules/lab/labbenchreactor.ts`:41 | delLabbenchreactor | DELETE | `/lab/labbenchreactor/${reactorId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 272 | sdk-smp-api | — | `modules/lab/labbenchreactor.ts`:49 | checkUnique | GET | `/lab/labbenchreactor/check-unique` | 无参 |  |  |  |  | — |
| 273 | sdk-smp-api | — | `modules/lab/labbenchreactor.ts`:58 | checkVesselNo | GET | `/lab/labbenchreactor/check-vessel-no` | 无参 |  |  |  |  | — |
| 274 | sdk-smp-api | — | `modules/lab/labbenchreactor.ts`:67 | checkControllerNo | GET | `/lab/labbenchreactor/check-controller-no` | 无参 |  |  |  |  | — |
| 275 | sdk-smp-api | — | `modules/lab/labbenchreactor.ts`:75 | checkCanDelete | GET | `/lab/labbenchreactor/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 276 | sdk-smp-api | 查询实验室检测设备列表 | `modules/lab/labdetector.ts`:6 | listLabdetector | GET | `/lab/labdetector/list` | Query | 是 |  |  |  | — |
| 277 | sdk-smp-api | 查询实验室检测设备详细 | `modules/lab/labdetector.ts`:15 | getLabdetector | GET | `/lab/labdetector/${detectorId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 278 | sdk-smp-api | 新增实验室检测设备 | `modules/lab/labdetector.ts`:24 | addLabdetector | POST | `/lab/labdetector` | 无参 |  |  | 是 |  | — |
| 279 | sdk-smp-api | 修改实验室检测设备 | `modules/lab/labdetector.ts`:33 | updateLabdetector | PUT | `/lab/labdetector` | 无参 |  |  | 是 |  | — |
| 280 | sdk-smp-api | 删除实验室检测设备 | `modules/lab/labdetector.ts`:42 | delLabdetector | DELETE | `/lab/labdetector/${detectorId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 281 | sdk-smp-api | — | `modules/lab/labdetector.ts`:50 | checkUnique | GET | `/lab/labdetector/check-unique` | 无参 |  |  |  |  | — |
| 282 | sdk-smp-api | — | `modules/lab/labdetector.ts`:59 | checkDeviceNo | GET | `/lab/labdetector/check-device-no` | 无参 |  |  |  |  | — |
| 283 | sdk-smp-api | — | `modules/lab/labdetector.ts`:67 | checkCanDelete | GET | `/lab/labdetector/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 284 | sdk-smp-api | 查询实验室称重设备列表 | `modules/lab/labfloorscale.ts`:6 | listLabfloorscale | GET | `/lab/labfloorscale/list` | Query | 是 |  |  |  | — |
| 285 | sdk-smp-api | 查询实验室称重设备详细 | `modules/lab/labfloorscale.ts`:16 | getLabfloorscale | GET | `/lab/labfloorscale/${scaleId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 286 | sdk-smp-api | 新增实验室称重设备 | `modules/lab/labfloorscale.ts`:24 | addLabfloorscale | POST | `/lab/labfloorscale` | 无参 |  |  | 是 |  | — |
| 287 | sdk-smp-api | 修改实验室称重设备 | `modules/lab/labfloorscale.ts`:33 | updateLabfloorscale | PUT | `/lab/labfloorscale` | 无参 |  |  | 是 |  | — |
| 288 | sdk-smp-api | 删除实验室称重设备 | `modules/lab/labfloorscale.ts`:42 | delLabfloorscale | DELETE | `/lab/labfloorscale/${scaleId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 289 | sdk-smp-api | — | `modules/lab/labfloorscale.ts`:49 | checkUnique | GET | `/lab/labfloorscale/check-unique` | 无参 |  |  |  |  | — |
| 290 | sdk-smp-api | 校验设备编号实验室内唯一 | `modules/lab/labfloorscale.ts`:58 | checkDeviceNo | GET | `/lab/labfloorscale/check-device-no` | 无参 |  |  |  |  | — |
| 291 | sdk-smp-api | — | `modules/lab/labfloorscale.ts`:66 | checkCanDelete | GET | `/lab/labfloorscale/${id}/check-delete` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 292 | sdk-smp-api | 变更维护状态 | `modules/lab/labfloorscale.ts`:74 | changeMaintainStatus | PUT | `/lab/labfloorscale/changeMaintainStatus` | 无参 |  |  | 是 |  | — |
| 293 | sdk-smp-api | 查询实验室集成反应器列表 | `modules/lab/labintegratedreactor.ts`:6 | listLabintegratedreactor | GET | `/lab/labintegratedreactor/list` | Query | 是 |  |  |  | — |
| 294 | sdk-smp-api | 查询实验室集成反应器详细 | `modules/lab/labintegratedreactor.ts`:15 | getLabintegratedreactor | GET | `/lab/labintegratedreactor/${integratedId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 295 | sdk-smp-api | 新增实验室集成反应器 | `modules/lab/labintegratedreactor.ts`:24 | addLabintegratedreactor | POST | `/lab/labintegratedreactor` | 无参 |  |  | 是 |  | — |
| 296 | sdk-smp-api | 修改实验室集成反应器 | `modules/lab/labintegratedreactor.ts`:33 | updateLabintegratedreactor | PUT | `/lab/labintegratedreactor/${data.integratedId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 297 | sdk-smp-api | 删除实验室集成反应器 | `modules/lab/labintegratedreactor.ts`:42 | delLabintegratedreactor | DELETE | `/lab/labintegratedreactor/${integratedId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 298 | sdk-smp-api | — | `modules/lab/labintegratedreactor.ts`:49 | checkUnique | GET | `/lab/labintegratedreactor/check-unique` | 无参 |  |  |  |  | — |
| 299 | sdk-smp-api | — | `modules/lab/labintegratedreactor.ts`:57 | checkCanDelete | GET | `/lab/labintegratedreactor/${id}/check-delete` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 300 | sdk-smp-api | 变更维护状态 | `modules/lab/labintegratedreactor.ts`:65 | changeMaintainStatus | PUT | `/lab/labintegratedreactor/changeMaintainStatus` | 无参 |  |  | 是 |  | — |
| 301 | sdk-smp-api | 查询实验室蠕动泵列表 | `modules/lab/labperistalticpump.ts`:6 | listLabperistalticpump | GET | `/lab/labperistalticpump/list` | Query | 是 |  |  |  | — |
| 302 | sdk-smp-api | 查询实验室蠕动泵详细 | `modules/lab/labperistalticpump.ts`:16 | getLabperistalticpump | GET | `/lab/labperistalticpump/${pumpId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 303 | sdk-smp-api | 新增实验室蠕动泵 | `modules/lab/labperistalticpump.ts`:24 | addLabperistalticpump | POST | `/lab/labperistalticpump` | 无参 |  |  | 是 |  | — |
| 304 | sdk-smp-api | 修改实验室蠕动泵 | `modules/lab/labperistalticpump.ts`:33 | updateLabperistalticpump | PUT | `/lab/labperistalticpump` | 无参 |  |  | 是 |  | — |
| 305 | sdk-smp-api | 删除实验室蠕动泵 | `modules/lab/labperistalticpump.ts`:42 | delLabperistalticpump | DELETE | `/lab/labperistalticpump/${pumpId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 306 | sdk-smp-api | — | `modules/lab/labperistalticpump.ts`:49 | checkUnique | GET | `/lab/labperistalticpump/check-unique` | 无参 |  |  |  |  | — |
| 307 | sdk-smp-api | — | `modules/lab/labperistalticpump.ts`:58 | checkDeviceNo | GET | `/lab/labperistalticpump/check-device-no` | 无参 |  |  |  |  | — |
| 308 | sdk-smp-api | — | `modules/lab/labperistalticpump.ts`:66 | checkCanDelete | GET | `/lab/labperistalticpump/${id}/check-delete` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 309 | sdk-smp-api | 变更维护状态 | `modules/lab/labperistalticpump.ts`:74 | changeMaintainStatus | PUT | `/lab/labperistalticpump/changeMaintainStatus` | 无参 |  |  | 是 |  | — |
| 310 | sdk-smp-api | 查询离线告警阈值配置列表 | `modules/lab/offlinealarm.ts`:9 | listOfflinealarm | GET | `/lab/offlinealarm/list` | Query | 是 |  |  |  | — |
| 311 | sdk-smp-api | 删除离线告警阈值配置 | `modules/lab/offlinealarm.ts`:18 | delOfflinealarm | DELETE | `/lab/offlinealarm/${configId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 312 | sdk-smp-api | — | `modules/lab/offlinealarm.ts`:25 | checkCanDelete | GET | `/lab/offlinealarm/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 313 | sdk-smp-api | — | `modules/lab/offlinealarm.ts`:32 | batchSave | POST | `/lab/offlinealarm/${labId}/batch-save` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 314 | sdk-smp-api | 查询打印机列表 | `modules/lab/printer.ts`:6 | listPrinter | GET | `/lab/printer/list` | Query | 是 |  |  |  | — |
| 315 | sdk-smp-api | 查询打印机详细 | `modules/lab/printer.ts`:15 | getPrinter | GET | `/lab/printer/${printerId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 316 | sdk-smp-api | 新增打印机 | `modules/lab/printer.ts`:23 | addPrinter | POST | `/lab/printer` | 无参 |  |  | 是 |  | — |
| 317 | sdk-smp-api | 修改打印机 | `modules/lab/printer.ts`:32 | updatePrinter | PUT | `/lab/printer` | 无参 |  |  | 是 |  | — |
| 318 | sdk-smp-api | 查询打印机排版设置 | `modules/lab/printer.ts`:41 | getPrinterLayout | GET | `/lab/printer/${printerId}/layout` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 319 | sdk-smp-api | 保存打印机排版设置 | `modules/lab/printer.ts`:49 | savePrinterLayout | POST | `/lab/printer/${printerId}/layout` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 320 | sdk-smp-api | 删除打印机 | `modules/lab/printer.ts`:58 | delPrinter | DELETE | `/lab/printer/${printerId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 321 | sdk-smp-api | — | `modules/lab/printer.ts`:66 | checkUnique | GET | `/lab/printer/check-unique` | 无参 |  |  |  |  | — |
| 322 | sdk-smp-api | — | `modules/lab/printer.ts`:75 | checkDeviceNo | GET | `/lab/printer/check-device-no` | 无参 |  |  |  |  | — |
| 323 | sdk-smp-api | — | `modules/lab/printer.ts`:83 | checkCanDelete | GET | `/lab/printer/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 324 | sdk-smp-api | 查询继电器列表 | `modules/lab/relay.ts`:6 | listRelay | GET | `/lab/relay/list` | Query | 是 |  |  |  | — |
| 325 | sdk-smp-api | 查询继电器详细 | `modules/lab/relay.ts`:16 | getRelay | GET | `/lab/relay/${relayId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 326 | sdk-smp-api | 新增继电器 | `modules/lab/relay.ts`:24 | addRelay | POST | `/lab/relay` | 无参 |  |  | 是 |  | — |
| 327 | sdk-smp-api | 修改继电器 | `modules/lab/relay.ts`:33 | updateRelay | PUT | `/lab/relay` | 无参 |  |  | 是 |  | — |
| 328 | sdk-smp-api | 删除继电器 | `modules/lab/relay.ts`:42 | delRelay | DELETE | `/lab/relay/${relayId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 329 | sdk-smp-api | — | `modules/lab/relay.ts`:50 | checkUnique | GET | `/lab/relay/check-unique` | 无参 |  |  |  |  | — |
| 330 | sdk-smp-api | — | `modules/lab/relay.ts`:59 | checkDeviceNo | GET | `/lab/relay/check-device-no` | 无参 |  |  |  |  | — |
| 331 | sdk-smp-api | — | `modules/lab/relay.ts`:67 | checkCanDelete | GET | `/lab/relay/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 332 | sdk-smp-api | 查询声光报警器列表 | `modules/lab/soundalarm.ts`:6 | listSoundalarm | GET | `/lab/soundalarm/list` | Query | 是 |  |  |  | — |
| 333 | sdk-smp-api | 查询声光报警器详细 | `modules/lab/soundalarm.ts`:16 | getSoundalarm | GET | `/lab/soundalarm/${alarmId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 334 | sdk-smp-api | 新增声光报警器 | `modules/lab/soundalarm.ts`:24 | addSoundalarm | POST | `/lab/soundalarm` | 无参 |  |  | 是 |  | — |
| 335 | sdk-smp-api | 修改声光报警器 | `modules/lab/soundalarm.ts`:33 | updateSoundalarm | PUT | `/lab/soundalarm` | 无参 |  |  | 是 |  | — |
| 336 | sdk-smp-api | 删除声光报警器 | `modules/lab/soundalarm.ts`:42 | delSoundalarm | DELETE | `/lab/soundalarm/${alarmId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 337 | sdk-smp-api | — | `modules/lab/soundalarm.ts`:49 | checkUnique | GET | `/lab/soundalarm/check-unique` | 无参 |  |  |  |  | — |
| 338 | sdk-smp-api | — | `modules/lab/soundalarm.ts`:58 | checkDeviceNo | GET | `/lab/soundalarm/check-device-no` | 无参 |  |  |  |  | — |
| 339 | sdk-smp-api | — | `modules/lab/soundalarm.ts`:66 | checkCanDelete | GET | `/lab/soundalarm/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 340 | sdk-smp-api | @param {Object} query - { labId, alarmType } | `modules/lab/statusAlarm.ts`:9 | listStatusAlarm | GET | `/lab/statusalarm/list` | Query | 是 |  |  |  | — |
| 341 | sdk-smp-api | @param {Array} list     配置列表（含configId和alarmQuantity） | `modules/lab/statusAlarm.ts`:23 | batchSaveAlarm | POST | `/lab/statusalarm/batch-save` | Query+Body |  |  | 是 |  | — |
| 342 | sdk-smp-api | @param {String} alarmType 告警类型 | `modules/lab/statusAlarm.ts`:37 | clearAlarm | POST | `/lab/statusalarm/clear` | Query |  |  | 是 |  | — |
| 343 | sdk-smp-api | 查询实验组列表 | `modules/smp/labgroup.ts`:6 | listLabgroup | GET | `/smp/labgroup/list` | Query | 是 |  |  |  | — |
| 344 | sdk-smp-api | 查询实验组详细 | `modules/smp/labgroup.ts`:15 | getLabgroup | GET | `/smp/labgroup/${groupId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 345 | sdk-smp-api | 查询实验组成员（含负责人和成员用户ID列表） | `modules/smp/labgroup.ts`:23 | getLabgroupMembers | GET | `/smp/labgroup/${groupId}/members` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 346 | sdk-smp-api | 查询已选成员的详细信息（含昵称和部门名称） | `modules/smp/labgroup.ts`:31 | getLabgroupMemberDetails | GET | `/smp/labgroup/${groupId}/member-details` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 347 | sdk-smp-api | 查询部门+用户树（用于成员选择对话框） | `modules/smp/labgroup.ts`:39 | getLabgroupMemberTree | GET | `/smp/labgroup/member-tree` | Query |  |  |  |  | — |
| 348 | sdk-smp-api | 新增实验组 | `modules/smp/labgroup.ts`:48 | addLabgroup | POST | `/smp/labgroup` | 无参 |  |  | 是 |  | — |
| 349 | sdk-smp-api | 修改实验组 | `modules/smp/labgroup.ts`:57 | updateLabgroup | PUT | `/smp/labgroup` | 无参 |  |  | 是 |  | — |
| 350 | sdk-smp-api | 删除实验组 | `modules/smp/labgroup.ts`:66 | delLabgroup | DELETE | `/smp/labgroup/${groupId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 351 | sdk-smp-api | 查询实验组负责人关联列表 | `modules/smp/labgroupleader.ts`:6 | listLabgroupleader | GET | `/smp/labgroupleader/list` | Query | 是 |  |  |  | — |
| 352 | sdk-smp-api | 查询实验组负责人关联详细 | `modules/smp/labgroupleader.ts`:15 | getLabgroupleader | GET | `/smp/labgroupleader/${groupId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 353 | sdk-smp-api | 新增实验组负责人关联 | `modules/smp/labgroupleader.ts`:23 | addLabgroupleader | POST | `/smp/labgroupleader` | 无参 |  |  | 是 |  | — |
| 354 | sdk-smp-api | 修改实验组负责人关联 | `modules/smp/labgroupleader.ts`:32 | updateLabgroupleader | PUT | `/smp/labgroupleader` | 无参 |  |  | 是 |  | — |
| 355 | sdk-smp-api | 删除实验组负责人关联 | `modules/smp/labgroupleader.ts`:41 | delLabgroupleader | DELETE | `/smp/labgroupleader/${groupId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 356 | sdk-smp-api | 查询实验组成员关联列表 | `modules/smp/labgroupmember.ts`:6 | listLabgroupmember | GET | `/smp/labgroupmember/list` | Query | 是 |  |  |  | — |
| 357 | sdk-smp-api | 查询实验组成员关联详细 | `modules/smp/labgroupmember.ts`:15 | getLabgroupmember | GET | `/smp/labgroupmember/${groupId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 358 | sdk-smp-api | 新增实验组成员关联 | `modules/smp/labgroupmember.ts`:23 | addLabgroupmember | POST | `/smp/labgroupmember` | 无参 |  |  | 是 |  | — |
| 359 | sdk-smp-api | 修改实验组成员关联 | `modules/smp/labgroupmember.ts`:32 | updateLabgroupmember | PUT | `/smp/labgroupmember` | 无参 |  |  | 是 |  | — |
| 360 | sdk-smp-api | 删除实验组成员关联 | `modules/smp/labgroupmember.ts`:41 | delLabgroupmember | DELETE | `/smp/labgroupmember/${groupId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 361 | sdk-smp-api | 查询用户实验室授权列表 | `modules/smp/userlab.ts`:6 | listUserlab | GET | `/smp/userlab/list` | Query | 是 |  |  |  | — |
| 362 | sdk-smp-api | 查询用户实验室授权详细 | `modules/smp/userlab.ts`:15 | getUserlab | GET | `/smp/userlab/${userId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 363 | sdk-smp-api | 新增用户实验室授权 | `modules/smp/userlab.ts`:23 | addUserlab | POST | `/smp/userlab` | 无参 |  |  | 是 |  | — |
| 364 | sdk-smp-api | 修改用户实验室授权 | `modules/smp/userlab.ts`:32 | updateUserlab | PUT | `/smp/userlab` | 无参 |  |  | 是 |  | — |
| 365 | sdk-smp-api | 删除用户实验室授权 | `modules/smp/userlab.ts`:41 | delUserlab | DELETE | `/smp/userlab/${userId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 366 | sdk-smp-api | — | `workbench.ts`:302 | listPrinter | GET | `/lab/printer/list` | Query | 是 |  |  |  | — |

## 分类 4：资源/设备类 M02（设备主数据）

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 367 | sdk-smp-api | — | `benchreactor.ts`:56 | benchreactorApi.checkUnique | GET | `/device/benchreactor/check-unique` | Query+Body |  |  |  |  | — |
| 368 | sdk-smp-api | — | `benchreactor.ts`:61 | benchreactorApi.save | POST/PUT | `/device/benchreactor` | Body |  |  | 是 |  | — |
| 369 | sdk-smp-api | — | `containerspec.ts`:56 | containerspecApi.checkUnique | GET | `/device/containerspec/check-unique` | Query+Body |  |  |  |  | — |
| 370 | sdk-smp-api | — | `containerspec.ts`:61 | containerspecApi.save | POST/PUT | `/device/containerspec` | Body |  |  | 是 |  | — |
| 371 | sdk-smp-api | — | `detectoritem.ts`:65 | detectoritemApi.checkUnique | GET | `/device/detectoritem/check-unique` | Query |  |  |  |  | — |
| 372 | sdk-smp-api | 三者含义不同，不可混用 | `detectoritem.ts`:76 | detectoritemApi.save | POST/PUT | `/device/detectoritem` | Body |  |  | 是 |  | — |
| 373 | sdk-smp-api | — | `devairpum.ts`:58 | devairpumApi.checkUnique | GET | `/device/devairpum/check-unique` | Query+Body |  |  |  |  | — |
| 374 | sdk-smp-api | — | `devairpum.ts`:63 | devairpumApi.save | POST/PUT | `/device/devairpum` | Body |  |  | 是 |  | — |
| 375 | sdk-smp-api | — | `devAnalyzerModel.ts`:62 | devAnalyzerModelApi.checkUnique | GET | `/device/devAnalyzerModel/check-unique` | Query+Body |  |  |  |  | — |
| 376 | sdk-smp-api | — | `devAnalyzerModel.ts`:67 | devAnalyzerModelApi.save | POST/PUT | `/device/devAnalyzerModel` | Body |  |  | 是 |  | — |
| 377 | sdk-smp-api | — | `devdetector.ts`:130 | devdetectorApi.checkUnique | GET | `/device/devdetector/check-unique` | Query+Body |  |  |  |  | — |
| 378 | sdk-smp-api | — | `devdetector.ts`:135 | devdetectorApi.save | POST/PUT | `/device/devdetector` | Body |  |  | 是 |  | — |
| 379 | sdk-smp-api | — | `devdetector.ts`:149 | devdetectorApi.checkDelete | GET | `/device/devdetector/` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 380 | sdk-smp-api | — | `devfloorscale.ts`:63 | devfloorscaleApi.checkUnique | GET | `/device/devfloorscale/check-unique` | Query+Body |  |  |  |  | — |
| 381 | sdk-smp-api | — | `devfloorscale.ts`:68 | devfloorscaleApi.save | POST/PUT | `/device/devfloorscale` | Body |  |  | 是 |  | — |
| 382 | sdk-smp-api | — | `devperistalticpump.ts`:58 | devperistalticpumpApi.checkUnique | GET | `/device/devperistalticpump/check-unique` | Query+Body |  |  |  |  | — |
| 383 | sdk-smp-api | — | `devperistalticpump.ts`:63 | devperistalticpumpApi.save | POST/PUT | `/device/devperistalticpump` | Body |  |  | 是 |  | — |
| 384 | sdk-smp-api | — | `integratedreactor.ts`:58 | integratedreactorApi.checkUnique | GET | `/device/integratedreactor/check-unique` | Query+Body |  |  |  |  | — |
| 385 | sdk-smp-api | — | `integratedreactor.ts`:63 | integratedreactorApi.save | POST/PUT | `/device/integratedreactor` | Body |  |  | 是 |  | — |
| 386 | sdk-smp-api | 查询台式反应器型号列表 | `modules/device/benchreactor.ts`:6 | listBenchreactor | GET | `/device/benchreactor/list` | Query | 是 |  |  |  | — |
| 387 | sdk-smp-api | 查询台式反应器型号详细 | `modules/device/benchreactor.ts`:15 | getBenchreactor | GET | `/device/benchreactor/${modelId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 388 | sdk-smp-api | 新增台式反应器型号 | `modules/device/benchreactor.ts`:23 | addBenchreactor | POST | `/device/benchreactor` | 无参 |  |  | 是 |  | — |
| 389 | sdk-smp-api | 修改台式反应器型号 | `modules/device/benchreactor.ts`:32 | updateBenchreactor | PUT | `/device/benchreactor` | 无参 |  |  | 是 |  | — |
| 390 | sdk-smp-api | 删除台式反应器型号 | `modules/device/benchreactor.ts`:41 | delBenchreactor | DELETE | `/device/benchreactor/${modelId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 391 | sdk-smp-api | — | `modules/device/benchreactor.ts`:48 | checkUnique | GET | `/device/benchreactor/check-unique` | 无参 |  |  |  |  | — |
| 392 | sdk-smp-api | — | `modules/device/benchreactor.ts`:56 | checkCanDelete | GET | `/device/benchreactor/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 393 | sdk-smp-api | 查询培养容器规格列表 | `modules/device/containerspec.ts`:6 | listContainerspec | GET | `/device/containerspec/list` | Query | 是 |  |  |  | — |
| 394 | sdk-smp-api | 查询培养容器规格详细 | `modules/device/containerspec.ts`:15 | getContainerspec | GET | `/device/containerspec/${specId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 395 | sdk-smp-api | 新增培养容器规格 | `modules/device/containerspec.ts`:23 | addContainerspec | POST | `/device/containerspec` | 无参 |  |  | 是 |  | — |
| 396 | sdk-smp-api | 修改培养容器规格 | `modules/device/containerspec.ts`:32 | updateContainerspec | PUT | `/device/containerspec` | 无参 |  |  | 是 |  | — |
| 397 | sdk-smp-api | 删除培养容器规格 | `modules/device/containerspec.ts`:41 | delContainerspec | DELETE | `/device/containerspec/${specId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 398 | sdk-smp-api | — | `modules/device/containerspec.ts`:48 | checkUnique | GET | `/device/containerspec/check-unique` | 无参 |  |  |  |  | — |
| 399 | sdk-smp-api | — | `modules/device/containerspec.ts`:56 | checkCanDelete | GET | `/device/containerspec/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 400 | sdk-smp-api | 查询检测项库列表 | `modules/device/detectoritem.ts`:6 | listDetectoritem | GET | `/device/detectoritem/list` | Query | 是 |  |  |  | — |
| 401 | sdk-smp-api | 查询检测项库详细 | `modules/device/detectoritem.ts`:15 | getDetectoritem | GET | `/device/detectoritem/${itemId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 402 | sdk-smp-api | 新增检测项库 | `modules/device/detectoritem.ts`:23 | addDetectoritem | POST | `/device/detectoritem` | 无参 |  |  | 是 |  | — |
| 403 | sdk-smp-api | 修改检测项库 | `modules/device/detectoritem.ts`:32 | updateDetectoritem | PUT | `/device/detectoritem` | 无参 |  |  | 是 |  | — |
| 404 | sdk-smp-api | 删除检测项库 | `modules/device/detectoritem.ts`:41 | delDetectoritem | DELETE | `/device/detectoritem/${itemId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 405 | sdk-smp-api | — | `modules/device/detectoritem.ts`:48 | checkUnique | GET | `/device/detectoritem/check-unique` | 无参 |  |  |  |  | — |
| 406 | sdk-smp-api | — | `modules/device/detectoritem.ts`:56 | checkCanDelete | GET | `/device/detectoritem/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 407 | sdk-smp-api | 查询空气泵型号列表 | `modules/device/devairpum.ts`:6 | listDevairpum | GET | `/device/devairpum/list` | Query | 是 |  |  |  | — |
| 408 | sdk-smp-api | 查询空气泵型号详细 | `modules/device/devairpum.ts`:15 | getDevairpum | GET | `/device/devairpum/${modelId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 409 | sdk-smp-api | 新增空气泵型号 | `modules/device/devairpum.ts`:23 | addDevairpum | POST | `/device/devairpum` | 无参 |  |  | 是 |  | — |
| 410 | sdk-smp-api | 修改空气泵型号 | `modules/device/devairpum.ts`:32 | updateDevairpum | PUT | `/device/devairpum` | 无参 |  |  | 是 |  | — |
| 411 | sdk-smp-api | 删除空气泵型号 | `modules/device/devairpum.ts`:41 | delDevairpum | DELETE | `/device/devairpum/${modelId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 412 | sdk-smp-api | — | `modules/device/devairpum.ts`:48 | checkUnique | GET | `/device/devairpum/check-unique` | 无参 |  |  |  |  | — |
| 413 | sdk-smp-api | — | `modules/device/devairpum.ts`:56 | checkCanDelete | GET | `/device/devairpum/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 414 | sdk-smp-api | 查询分析检测仪型号列表 | `modules/device/devAnalyzerModel.ts`:6 | listDevAnalyzerModel | GET | `/device/devAnalyzerModel/list` | Query | 是 |  |  |  | — |
| 415 | sdk-smp-api | 查询分析检测仪型号详细 | `modules/device/devAnalyzerModel.ts`:15 | getDevAnalyzerModel | GET | `/device/devAnalyzerModel/${analyzerId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 416 | sdk-smp-api | 新增分析检测仪型号 | `modules/device/devAnalyzerModel.ts`:23 | addDevAnalyzerModel | POST | `/device/devAnalyzerModel` | 无参 |  |  | 是 |  | — |
| 417 | sdk-smp-api | 修改分析检测仪型号 | `modules/device/devAnalyzerModel.ts`:32 | updateDevAnalyzerModel | PUT | `/device/devAnalyzerModel` | 无参 |  |  | 是 |  | — |
| 418 | sdk-smp-api | 删除分析检测仪型号 | `modules/device/devAnalyzerModel.ts`:41 | delDevAnalyzerModel | DELETE | `/device/devAnalyzerModel/${analyzerId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 419 | sdk-smp-api | 校验品牌+型号唯一性 | `modules/device/devAnalyzerModel.ts`:49 | checkUnique | GET | `/device/devAnalyzerModel/check-unique` | 无参 |  |  |  |  | — |
| 420 | sdk-smp-api | 校验是否可以删除 | `modules/device/devAnalyzerModel.ts`:58 | checkCanDelete | GET | `/device/devAnalyzerModel/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 421 | sdk-smp-api | 查询检测设备型号列表 | `modules/device/devdetector.ts`:6 | listDevdetector | GET | `/device/devdetector/list` | Query | 是 |  |  |  | — |
| 422 | sdk-smp-api | 查询检测设备型号详细 | `modules/device/devdetector.ts`:15 | getDevdetector | GET | `/device/devdetector/${modelId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 423 | sdk-smp-api | 新增检测设备型号 | `modules/device/devdetector.ts`:23 | addDevdetector | POST | `/device/devdetector` | 无参 |  |  | 是 |  | — |
| 424 | sdk-smp-api | 修改检测设备型号 | `modules/device/devdetector.ts`:32 | updateDevdetector | PUT | `/device/devdetector` | 无参 |  |  | 是 |  | — |
| 425 | sdk-smp-api | 删除检测设备型号 | `modules/device/devdetector.ts`:41 | delDevdetector | DELETE | `/device/devdetector/${modelId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 426 | sdk-smp-api | — | `modules/device/devdetector.ts`:48 | checkUnique | GET | `/device/devdetector/check-unique` | 无参 |  |  |  |  | — |
| 427 | sdk-smp-api | — | `modules/device/devdetector.ts`:56 | checkCanDelete | GET | `/device/devdetector/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 428 | sdk-smp-api | 查询称重设备型号列表 | `modules/device/devfloorscale.ts`:6 | listDevfloorscale | GET | `/device/devfloorscale/list` | Query | 是 |  |  |  | — |
| 429 | sdk-smp-api | 查询称重设备型号详细 | `modules/device/devfloorscale.ts`:15 | getDevfloorscale | GET | `/device/devfloorscale/${modelId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 430 | sdk-smp-api | 新增称重设备型号 | `modules/device/devfloorscale.ts`:23 | addDevfloorscale | POST | `/device/devfloorscale` | 无参 |  |  | 是 |  | — |
| 431 | sdk-smp-api | 修改称重设备型号 | `modules/device/devfloorscale.ts`:32 | updateDevfloorscale | PUT | `/device/devfloorscale` | 无参 |  |  | 是 |  | — |
| 432 | sdk-smp-api | 删除称重设备型号 | `modules/device/devfloorscale.ts`:41 | delDevfloorscale | DELETE | `/device/devfloorscale/${modelId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 433 | sdk-smp-api | — | `modules/device/devfloorscale.ts`:48 | checkUnique | GET | `/device/devfloorscale/check-unique` | 无参 |  |  |  |  | — |
| 434 | sdk-smp-api | — | `modules/device/devfloorscale.ts`:56 | checkCanDelete | GET | `/device/devfloorscale/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 435 | sdk-smp-api | 查询蠕动泵型号列表 | `modules/device/devperistalticpump.ts`:6 | listDevperistalticpump | GET | `/device/devperistalticpump/list` | Query | 是 |  |  |  | — |
| 436 | sdk-smp-api | 查询蠕动泵型号详细 | `modules/device/devperistalticpump.ts`:15 | getDevperistalticpump | GET | `/device/devperistalticpump/${modelId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 437 | sdk-smp-api | 新增蠕动泵型号 | `modules/device/devperistalticpump.ts`:23 | addDevperistalticpump | POST | `/device/devperistalticpump` | 无参 |  |  | 是 |  | — |
| 438 | sdk-smp-api | 修改蠕动泵型号 | `modules/device/devperistalticpump.ts`:32 | updateDevperistalticpump | PUT | `/device/devperistalticpump` | 无参 |  |  | 是 |  | — |
| 439 | sdk-smp-api | 删除蠕动泵型号 | `modules/device/devperistalticpump.ts`:41 | delDevperistalticpump | DELETE | `/device/devperistalticpump/${modelId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 440 | sdk-smp-api | — | `modules/device/devperistalticpump.ts`:48 | checkUnique | GET | `/device/devperistalticpump/check-unique` | 无参 |  |  |  |  | — |
| 441 | sdk-smp-api | — | `modules/device/devperistalticpump.ts`:56 | checkCanDelete | GET | `/device/devperistalticpump/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 442 | sdk-smp-api | 查询集成反应器型号列表 | `modules/device/integratedreactor.ts`:6 | listIntegratedreactor | GET | `/device/integratedreactor/list` | Query | 是 |  |  |  | — |
| 443 | sdk-smp-api | 查询集成反应器型号详细 | `modules/device/integratedreactor.ts`:15 | getIntegratedreactor | GET | `/device/integratedreactor/${modelId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 444 | sdk-smp-api | 新增集成反应器型号 | `modules/device/integratedreactor.ts`:23 | addIntegratedreactor | POST | `/device/integratedreactor` | 无参 |  |  | 是 |  | — |
| 445 | sdk-smp-api | 修改集成反应器型号 | `modules/device/integratedreactor.ts`:32 | updateIntegratedreactor | PUT | `/device/integratedreactor` | 无参 |  |  | 是 |  | — |
| 446 | sdk-smp-api | 删除集成反应器型号 | `modules/device/integratedreactor.ts`:41 | delIntegratedreactor | DELETE | `/device/integratedreactor/${modelId}` | Query+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 447 | sdk-smp-api | — | `modules/device/integratedreactor.ts`:48 | checkUnique | GET | `/device/integratedreactor/check-unique` | 无参 |  |  |  |  | — |
| 448 | sdk-smp-api | — | `modules/device/integratedreactor.ts`:56 | checkCanDelete | GET | `/device/integratedreactor/${id}/check-delete` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |

## 分类 5：项目/批次/培养类 M03

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 449 | sdk-smp-api | — | `batch.ts`:81 | batchApi.detail | GET | `/resource/batch/` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 450 | sdk-smp-api | — | `batch.ts`:96 | batchApi.saveMembers | PUT | `/resource/batch/` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 451 | sdk-smp-api | — | `batch.ts`:107 | batchApi.save | POST/PUT | `/resource/batch` | Body |  |  | 是 |  | — |
| 452 | sdk-smp-api | — | `batch.ts`:121 | batchApi.exit | PUT | `/resource/batch/exit` | Body |  |  | 是 |  | — |
| 453 | sdk-smp-api | 不能用 `save`，它要求整份 BatchFields | `batch.ts`:127 | batchApi.end | PUT | `/resource/batch` | Body |  |  | 是 |  | — |
| 454 | sdk-smp-api | — | `consumableMaster.ts`:56 | consumableMasterApi.save | POST/PUT | `/resource/consumableMaster` | Body |  |  | 是 |  | — |
| 455 | sdk-smp-api | — | `culture.ts`:61 | cultureApi.detail | GET | `/resource/culture/` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 456 | sdk-smp-api | — | `culture.ts`:80 | cultureApi.save | POST/PUT | `/resource/culture` | Body |  |  | 是 |  | — |
| 457 | sdk-smp-api | 因此只需主键与目标值，不会覆盖其他字段 | `culture.ts`:89 | cultureApi.updateMode | PUT | `/resource/culture` | Body |  |  | 是 |  | — |
| 458 | sdk-smp-api | — | `culture.ts`:103 | cultureApi.exit | PUT | `/resource/culture/exit` | Body |  |  | 是 |  | — |
| 459 | sdk-smp-api | 查询批次列表 | `modules/resource/batch.ts`:6 | listBatch | GET | `/resource/batch/list` | Query | 是 |  |  |  | — |
| 460 | sdk-smp-api | 查询批次详细 | `modules/resource/batch.ts`:15 | getBatch | GET | `/resource/batch/${batchId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 461 | sdk-smp-api | 新增批次 | `modules/resource/batch.ts`:23 | addBatch | POST | `/resource/batch` | 无参 |  |  | 是 |  | — |
| 462 | sdk-smp-api | 修改批次 | `modules/resource/batch.ts`:32 | updateBatch | PUT | `/resource/batch` | 无参 |  |  | 是 |  | — |
| 463 | sdk-smp-api | 查询部门+用户树（用于批次成员选择对话框） | `modules/resource/batch.ts`:41 | getBatchMemberTree | GET | `/resource/batch/${batchId}/member-tree` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 464 | sdk-smp-api | 查询已选批次成员的详细信息（含昵称、部门名称和角色名称） | `modules/resource/batch.ts`:49 | getBatchMemberDetails | GET | `/resource/batch/${batchId}/member-details` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 465 | sdk-smp-api | 保存批次成员 | `modules/resource/batch.ts`:57 | updateBatchMembers | PUT | `/resource/batch/${batchId}/members` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 466 | sdk-smp-api | 校验培养编号是否重复（前端预校验） | `modules/resource/batch.ts`:66 | checkCultureCode | GET | `/resource/batch/check-culture-code` | Query |  |  |  |  | — |
| 467 | sdk-smp-api | 删除批次 | `modules/resource/batch.ts`:75 | delBatch | DELETE | `/resource/batch/${batchId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 468 | sdk-smp-api | 退出批次 | `modules/resource/batch.ts`:83 | exitBatch | PUT | `/resource/batch/exit` | Body |  |  | 是 |  | — |
| 469 | sdk-smp-api | 查询批次负责人关联列表 | `modules/resource/batchleader.ts`:6 | listBatchleader | GET | `/resource/batchleader/list` | Query | 是 |  |  |  | — |
| 470 | sdk-smp-api | 查询批次负责人关联详细 | `modules/resource/batchleader.ts`:15 | getBatchleader | GET | `/resource/batchleader/${batchId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 471 | sdk-smp-api | 新增批次负责人关联 | `modules/resource/batchleader.ts`:23 | addBatchleader | POST | `/resource/batchleader` | 无参 |  |  | 是 |  | — |
| 472 | sdk-smp-api | 修改批次负责人关联 | `modules/resource/batchleader.ts`:32 | updateBatchleader | PUT | `/resource/batchleader` | 无参 |  |  | 是 |  | — |
| 473 | sdk-smp-api | 删除批次负责人关联 | `modules/resource/batchleader.ts`:41 | delBatchleader | DELETE | `/resource/batchleader/${batchId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 474 | sdk-smp-api | 查询批次成员权限列表 | `modules/resource/batchmember.ts`:6 | listBatchmember | GET | `/resource/batchmember/list` | Query | 是 |  |  |  | — |
| 475 | sdk-smp-api | 查询批次成员权限详细 | `modules/resource/batchmember.ts`:15 | getBatchmember | GET | `/resource/batchmember/${batchId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 476 | sdk-smp-api | 新增批次成员权限 | `modules/resource/batchmember.ts`:23 | addBatchmember | POST | `/resource/batchmember` | 无参 |  |  | 是 |  | — |
| 477 | sdk-smp-api | 修改批次成员权限 | `modules/resource/batchmember.ts`:32 | updateBatchmember | PUT | `/resource/batchmember` | 无参 |  |  | 是 |  | — |
| 478 | sdk-smp-api | 删除批次成员权限 | `modules/resource/batchmember.ts`:41 | delBatchmember | DELETE | `/resource/batchmember/${batchId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 479 | sdk-smp-api | 查询培养列表 | `modules/resource/culture.ts`:6 | listCulture | GET | `/resource/culture/list` | Query | 是 |  |  |  | — |
| 480 | sdk-smp-api | 根据批次ID查询培养列表（绕过权限过滤，用于批次编辑时加载） | `modules/resource/culture.ts`:15 | listCultureByBatchId | GET | `/resource/culture/list-by-batch/${batchId}` | 路径含ID/动态 | 是 | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 481 | sdk-smp-api | 查询培养详细 | `modules/resource/culture.ts`:23 | getCulture | GET | `/resource/culture/${cultureId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 482 | sdk-smp-api | 新增培养 | `modules/resource/culture.ts`:31 | addCulture | POST | `/resource/culture` | 无参 |  |  | 是 |  | — |
| 483 | sdk-smp-api | 修改培养 | `modules/resource/culture.ts`:40 | updateCulture | PUT | `/resource/culture` | 无参 |  |  | 是 |  | — |
| 484 | sdk-smp-api | 保存培养成员 | `modules/resource/culture.ts`:49 | updateCultureMembers | PUT | `/resource/culture/${cultureId}/members` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 485 | sdk-smp-api | 查询部门+用户树（用于培养成员选择对话框） | `modules/resource/culture.ts`:58 | getCultureMemberTree | GET | `/resource/culture/${cultureId}/member-tree` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 486 | sdk-smp-api | 查询已选培养成员的详细信息（含昵称、部门名称和角色名称） | `modules/resource/culture.ts`:66 | getCultureMemberDetails | GET | `/resource/culture/${cultureId}/member-details` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 487 | sdk-smp-api | 删除培养 | `modules/resource/culture.ts`:74 | delCulture | DELETE | `/resource/culture/${cultureId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 488 | sdk-smp-api | 培养成员退出培养 | `modules/resource/culture.ts`:82 | exitCulture | PUT | `/resource/culture/exit` | Body |  |  | 是 |  | — |
| 489 | sdk-smp-api | 查询培养负责人关联列表 | `modules/resource/cultureleader.ts`:6 | listCultureleader | GET | `/resource/cultureleader/list` | Query | 是 |  |  |  | — |
| 490 | sdk-smp-api | 查询培养负责人关联详细 | `modules/resource/cultureleader.ts`:15 | getCultureleader | GET | `/resource/cultureleader/${cultureId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 491 | sdk-smp-api | 新增培养负责人关联 | `modules/resource/cultureleader.ts`:23 | addCultureleader | POST | `/resource/cultureleader` | 无参 |  |  | 是 |  | — |
| 492 | sdk-smp-api | 修改培养负责人关联 | `modules/resource/cultureleader.ts`:32 | updateCultureleader | PUT | `/resource/cultureleader` | 无参 |  |  | 是 |  | — |
| 493 | sdk-smp-api | 删除培养负责人关联 | `modules/resource/cultureleader.ts`:41 | delCultureleader | DELETE | `/resource/cultureleader/${cultureId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 494 | sdk-smp-api | 查询培养成员权限列表 | `modules/resource/culturemember.ts`:6 | listCulturemember | GET | `/resource/culturemember/list` | Query | 是 |  |  |  | — |
| 495 | sdk-smp-api | 查询培养成员权限详细 | `modules/resource/culturemember.ts`:15 | getCulturemember | GET | `/resource/culturemember/${cultureId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 496 | sdk-smp-api | 新增培养成员权限 | `modules/resource/culturemember.ts`:23 | addCulturemember | POST | `/resource/culturemember` | 无参 |  |  | 是 |  | — |
| 497 | sdk-smp-api | 修改培养成员权限 | `modules/resource/culturemember.ts`:32 | updateCulturemember | PUT | `/resource/culturemember` | 无参 |  |  | 是 |  | — |
| 498 | sdk-smp-api | 删除培养成员权限 | `modules/resource/culturemember.ts`:41 | delCulturemember | DELETE | `/resource/culturemember/${cultureId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 499 | sdk-smp-api | 查询项目列表 | `modules/resource/project.ts`:6 | listProject | GET | `/resource/project/list` | Query | 是 |  |  |  | — |
| 500 | sdk-smp-api | 查询项目详细 | `modules/resource/project.ts`:15 | getProject | GET | `/resource/project/${projectId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 501 | sdk-smp-api | 新增项目 | `modules/resource/project.ts`:23 | addProject | POST | `/resource/project` | 无参 |  |  | 是 |  | — |
| 502 | sdk-smp-api | 修改项目 | `modules/resource/project.ts`:32 | updateProject | PUT | `/resource/project` | 无参 |  |  | 是 |  | — |
| 503 | sdk-smp-api | 查询部门+用户树（用于项目成员选择对话框） | `modules/resource/project.ts`:41 | getProjectMemberTree | GET | `/resource/project/${projectId}/member-tree` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 504 | sdk-smp-api | 查询已选项目成员的详细信息（含昵称、部门名称和角色名称） | `modules/resource/project.ts`:49 | getProjectMemberDetails | GET | `/resource/project/${projectId}/member-details` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 505 | sdk-smp-api | 保存项目成员 | `modules/resource/project.ts`:57 | updateProjectMembers | PUT | `/resource/project/${projectId}/members` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 506 | sdk-smp-api | 删除项目 | `modules/resource/project.ts`:66 | delProject | DELETE | `/resource/project/${projectId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 507 | sdk-smp-api | 用户退出项目 | `modules/resource/project.ts`:74 | exitProject | POST | `/resource/project/${projectId}/exit` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 508 | sdk-smp-api | 查询项目参与实验室关联列表 | `modules/resource/projectlab.ts`:6 | listProjectlab | GET | `/resource/projectlab/list` | Query | 是 |  |  |  | — |
| 509 | sdk-smp-api | 查询项目参与实验室关联详细 | `modules/resource/projectlab.ts`:15 | getProjectlab | GET | `/resource/projectlab/${projectId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 510 | sdk-smp-api | 新增项目参与实验室关联 | `modules/resource/projectlab.ts`:23 | addProjectlab | POST | `/resource/projectlab` | 无参 |  |  | 是 |  | — |
| 511 | sdk-smp-api | 修改项目参与实验室关联 | `modules/resource/projectlab.ts`:32 | updateProjectlab | PUT | `/resource/projectlab` | 无参 |  |  | 是 |  | — |
| 512 | sdk-smp-api | 删除项目参与实验室关联 | `modules/resource/projectlab.ts`:41 | delProjectlab | DELETE | `/resource/projectlab/${projectId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 513 | sdk-smp-api | 查询项目负责人关联列表 | `modules/resource/projectleader.ts`:6 | listProjectleader | GET | `/resource/projectleader/list` | Query | 是 |  |  |  | — |
| 514 | sdk-smp-api | 查询项目负责人关联详细 | `modules/resource/projectleader.ts`:15 | getProjectleader | GET | `/resource/projectleader/${projectId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 515 | sdk-smp-api | 新增项目负责人关联 | `modules/resource/projectleader.ts`:23 | addProjectleader | POST | `/resource/projectleader` | 无参 |  |  | 是 |  | — |
| 516 | sdk-smp-api | 修改项目负责人关联 | `modules/resource/projectleader.ts`:32 | updateProjectleader | PUT | `/resource/projectleader` | 无参 |  |  | 是 |  | — |
| 517 | sdk-smp-api | 删除项目负责人关联 | `modules/resource/projectleader.ts`:41 | delProjectleader | DELETE | `/resource/projectleader/${projectId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 518 | sdk-smp-api | 查询项目成员权限列表 | `modules/resource/projectmember.ts`:6 | listProjectmember | GET | `/resource/projectmember/list` | Query | 是 |  |  |  | — |
| 519 | sdk-smp-api | 查询项目成员权限详细 | `modules/resource/projectmember.ts`:15 | getProjectmember | GET | `/resource/projectmember/${projectId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 520 | sdk-smp-api | 新增项目成员权限 | `modules/resource/projectmember.ts`:23 | addProjectmember | POST | `/resource/projectmember` | 无参 |  |  | 是 |  | — |
| 521 | sdk-smp-api | 修改项目成员权限 | `modules/resource/projectmember.ts`:32 | updateProjectmember | PUT | `/resource/projectmember` | 无参 |  |  | 是 |  | — |
| 522 | sdk-smp-api | 删除项目成员权限 | `modules/resource/projectmember.ts`:41 | delProjectmember | DELETE | `/resource/projectmember/${projectId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 523 | sdk-smp-api | 查询项目标签关联列表 | `modules/resource/projecttag.ts`:6 | listProjecttag | GET | `/resource/projecttag/list` | Query | 是 |  |  |  | — |
| 524 | sdk-smp-api | 查询项目标签关联详细 | `modules/resource/projecttag.ts`:15 | getProjecttag | GET | `/resource/projecttag/${projectId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 525 | sdk-smp-api | 新增项目标签关联 | `modules/resource/projecttag.ts`:23 | addProjecttag | POST | `/resource/projecttag` | 无参 |  |  | 是 |  | — |
| 526 | sdk-smp-api | 修改项目标签关联 | `modules/resource/projecttag.ts`:32 | updateProjecttag | PUT | `/resource/projecttag` | 无参 |  |  | 是 |  | — |
| 527 | sdk-smp-api | 删除项目标签关联 | `modules/resource/projecttag.ts`:41 | delProjecttag | DELETE | `/resource/projecttag/${projectId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 528 | sdk-smp-api | — | `project.ts`:84 | projectApi.detail | GET | `/resource/project/` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 529 | sdk-smp-api | — | `project.ts`:105 | projectApi.save | POST/PUT | `/resource/project` | Body |  |  | 是 |  | — |
| 530 | sdk-smp-api | — | `project.ts`:120 | projectApi.exit | POST | `/resource/project/` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |

## 分类 7：检测与签批类 M05（含 SDMS 集成）

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 531 | sdk-smp-api | — | `index.ts`:144 | recordApi.list | GET | `/detect/record/page` | Query | 是 |  |  |  | — |
| 532 | sdk-smp-api | — | `index.ts`:150 | recordApi.projects | GET | `/detect/record/projects` | 无参 |  |  |  |  | — |
| 533 | sdk-smp-api | — | `index.ts`:152 | recordApi.batches | GET | `/detect/record/batches` | Query |  |  |  |  | — |
| 534 | sdk-smp-api | — | `index.ts`:156 | recordApi.detectors | GET | `/detect/record/detectors` | Query |  |  |  |  | — |
| 535 | sdk-smp-api | 查询签批记录分页 | `modules/detect/approvalrecord.ts`:6 | listApprovalRecord | GET | `/detect/approval-record/page` | Query | 是 |  |  |  | — |
| 536 | sdk-smp-api | 查询签批记录详情 | `modules/detect/approvalrecord.ts`:15 | getApprovalRecordDetail | GET | `/detect/approval-record/${resultId}/detail` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 537 | sdk-smp-api | 查询签批记录日志 | `modules/detect/approvalrecord.ts`:23 | listApprovalRecordLogs | GET | `/detect/approval-record/${resultId}/logs` | 路径含ID/动态 | 是 | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 538 | sdk-smp-api | 查询检测审批人配置列表 | `modules/detect/assignee.ts`:9 | listAssignee | GET | `/detect/assignee/list` | Query | 是 |  |  |  | — |
| 539 | sdk-smp-api | 查询检测审批人配置详细 | `modules/detect/assignee.ts`:18 | getAssignee | GET | `/detect/assignee/${assigneeId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 540 | sdk-smp-api | 邀请检测审批人 | `modules/detect/assignee.ts`:26 | inviteAssignee | POST | `/detect/assignee/invite` | 无参 |  |  | 是 |  | — |
| 541 | sdk-smp-api | 删除检测审批人配置 | `modules/detect/assignee.ts`:35 | delAssignee | DELETE | `/detect/assignee/${assigneeId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 542 | sdk-smp-api | 查询审核日志聚合分页 | `modules/detect/auditlog.ts`:6 | listAuditLogPage | GET | `/detect/audit-log/page` | Query | 是 |  |  |  | — |
| 543 | sdk-smp-api | 查询CCPD上传日志列表 | `modules/detect/ccpdlog.ts`:6 | listCcpdlog | GET | `/detect/ccpdlog/list` | Query | 是 |  |  |  | — |
| 544 | sdk-smp-api | 查询CCPD上传日志详细 | `modules/detect/ccpdlog.ts`:15 | getCcpdlog | GET | `/detect/ccpdlog/${uploadId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 545 | sdk-smp-api | 新增CCPD上传日志 | `modules/detect/ccpdlog.ts`:23 | addCcpdlog | POST | `/detect/ccpdlog` | 无参 |  |  | 是 |  | — |
| 546 | sdk-smp-api | 修改CCPD上传日志 | `modules/detect/ccpdlog.ts`:32 | updateCcpdlog | PUT | `/detect/ccpdlog` | 无参 |  |  | 是 |  | — |
| 547 | sdk-smp-api | 删除CCPD上传日志 | `modules/detect/ccpdlog.ts`:41 | delCcpdlog | DELETE | `/detect/ccpdlog/${uploadId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 548 | sdk-smp-api | 查询检测结果主列表 | `modules/detect/detresult.ts`:6 | listDetresult | GET | `/detect/detresult/list` | Query | 是 |  |  |  | — |
| 549 | sdk-smp-api | 查询检测结果主详细 | `modules/detect/detresult.ts`:15 | getDetresult | GET | `/detect/detresult/${resultId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 550 | sdk-smp-api | 新增检测结果主 | `modules/detect/detresult.ts`:23 | addDetresult | POST | `/detect/detresult` | 无参 |  |  | 是 |  | — |
| 551 | sdk-smp-api | 修改检测结果主 | `modules/detect/detresult.ts`:32 | updateDetresult | PUT | `/detect/detresult` | 无参 |  |  | 是 |  | — |
| 552 | sdk-smp-api | 检测结果签名 | `modules/detect/detresult.ts`:41 | signDetresult | PUT | `/detect/detresult/${resultId}/sign` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 553 | sdk-smp-api | 检测结果作废 | `modules/detect/detresult.ts`:50 | voidDetresult | PUT | `/detect/detresult/${resultId}/void` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 554 | sdk-smp-api | 检测结果撤销作废 | `modules/detect/detresult.ts`:59 | revokeVoidDetresult | PUT | `/detect/detresult/${resultId}/revoke` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 555 | sdk-smp-api | 删除检测结果主 | `modules/detect/detresult.ts`:68 | delDetresult | DELETE | `/detect/detresult/${resultId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 556 | sdk-smp-api | 查询检测结果明细列表 | `modules/detect/detresultitem.ts`:6 | listDetresultitem | GET | `/detect/detresultitem/list` | Query | 是 |  |  |  | — |
| 557 | sdk-smp-api | 查询检测结果明细详细 | `modules/detect/detresultitem.ts`:15 | getDetresultitem | GET | `/detect/detresultitem/${resultItemId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 558 | sdk-smp-api | 新增检测结果明细 | `modules/detect/detresultitem.ts`:23 | addDetresultitem | POST | `/detect/detresultitem` | 无参 |  |  | 是 |  | — |
| 559 | sdk-smp-api | 修改检测结果明细 | `modules/detect/detresultitem.ts`:32 | updateDetresultitem | PUT | `/detect/detresultitem` | 无参 |  |  | 是 |  | — |
| 560 | sdk-smp-api | 删除检测结果明细 | `modules/detect/detresultitem.ts`:41 | delDetresultitem | DELETE | `/detect/detresultitem/${resultItemId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 561 | sdk-smp-api | 查询检测异常备注列表 | `modules/detect/exceptionnote.ts`:6 | listExceptionnote | GET | `/detect/exceptionnote/list` | Query | 是 |  |  |  | — |
| 562 | sdk-smp-api | 查询检测异常备注详细 | `modules/detect/exceptionnote.ts`:15 | getExceptionnote | GET | `/detect/exceptionnote/${noteId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 563 | sdk-smp-api | 新增检测异常备注 | `modules/detect/exceptionnote.ts`:23 | addExceptionnote | POST | `/detect/exceptionnote` | 无参 |  |  | 是 |  | — |
| 564 | sdk-smp-api | 修改检测异常备注 | `modules/detect/exceptionnote.ts`:32 | updateExceptionnote | PUT | `/detect/exceptionnote` | 无参 |  |  | 是 |  | — |
| 565 | sdk-smp-api | 删除检测异常备注 | `modules/detect/exceptionnote.ts`:41 | delExceptionnote | DELETE | `/detect/exceptionnote/${noteId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 566 | sdk-smp-api | 查询打印导出日志列表 | `modules/detect/printlog.ts`:6 | listPrintlog | GET | `/detect/printlog/list` | Query | 是 |  |  |  | — |
| 567 | sdk-smp-api | 查询打印导出日志详细 | `modules/detect/printlog.ts`:15 | getPrintlog | GET | `/detect/printlog/${logId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 568 | sdk-smp-api | 新增打印导出日志 | `modules/detect/printlog.ts`:23 | addPrintlog | POST | `/detect/printlog` | 无参 |  |  | 是 |  | — |
| 569 | sdk-smp-api | 修改打印导出日志 | `modules/detect/printlog.ts`:32 | updatePrintlog | PUT | `/detect/printlog` | 无参 |  |  | 是 |  | — |
| 570 | sdk-smp-api | 删除打印导出日志 | `modules/detect/printlog.ts`:41 | delPrintlog | DELETE | `/detect/printlog/${logId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 571 | sdk-smp-api | 查询检测需求与样品队列列表 | `modules/detect/sample.ts`:6 | listSample | GET | `/detect/sample/list` | Query | 是 |  |  |  | — |
| 572 | sdk-smp-api | 查询检测需求与样品队列详细 | `modules/detect/sample.ts`:15 | getSample | GET | `/detect/sample/${sampleId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 573 | sdk-smp-api | 新增检测需求与样品队列 | `modules/detect/sample.ts`:23 | addSample | POST | `/detect/sample` | 无参 |  |  | 是 |  | — |
| 574 | sdk-smp-api | 修改检测需求与样品队列 | `modules/detect/sample.ts`:32 | updateSample | PUT | `/detect/sample` | 无参 |  |  | 是 |  | — |
| 575 | sdk-smp-api | 删除检测需求与样品队列 | `modules/detect/sample.ts`:41 | delSample | DELETE | `/detect/sample/${sampleId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 576 | sdk-smp-api | 查询样品ID编辑历史列表 | `modules/detect/samplehistory.ts`:6 | listSamplehistory | GET | `/detect/samplehistory/list` | Query | 是 |  |  |  | — |
| 577 | sdk-smp-api | 查询样品ID编辑历史详细 | `modules/detect/samplehistory.ts`:15 | getSamplehistory | GET | `/detect/samplehistory/${historyId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 578 | sdk-smp-api | 新增样品ID编辑历史 | `modules/detect/samplehistory.ts`:23 | addSamplehistory | POST | `/detect/samplehistory` | 无参 |  |  | 是 |  | — |
| 579 | sdk-smp-api | 编辑样品ID编辑历史 | `modules/detect/samplehistory.ts`:32 | updateSamplehistory | PUT | `/detect/samplehistory` | 无参 |  |  | 是 |  | — |
| 580 | sdk-smp-api | 删除样品ID编辑历史 | `modules/detect/samplehistory.ts`:41 | delSamplehistory | DELETE | `/detect/samplehistory/${historyId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 581 | sdk-smp-api | 查询检测请求选择项列表 | `modules/detect/sampleitem.ts`:6 | listSampleitem | GET | `/detect/sampleitem/list` | Query | 是 |  |  |  | — |
| 582 | sdk-smp-api | 查询检测请求选择项详细 | `modules/detect/sampleitem.ts`:15 | getSampleitem | GET | `/detect/sampleitem/${sampleId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 583 | sdk-smp-api | 新增检测请求选择项 | `modules/detect/sampleitem.ts`:23 | addSampleitem | POST | `/detect/sampleitem` | 无参 |  |  | 是 |  | — |
| 584 | sdk-smp-api | 修改检测请求选择项 | `modules/detect/sampleitem.ts`:32 | updateSampleitem | PUT | `/detect/sampleitem` | 无参 |  |  | 是 |  | — |
| 585 | sdk-smp-api | 删除检测请求选择项 | `modules/detect/sampleitem.ts`:41 | delSampleitem | DELETE | `/detect/sampleitem/${sampleId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 586 | sdk-smp-api | 查询检测签名与操作记录列表 | `modules/detect/signrecord.ts`:6 | listSignrecord | GET | `/detect/signrecord/list` | Query | 是 |  |  |  | — |
| 587 | sdk-smp-api | 查询检测操作台下拉选项 | `modules/detect/workbench.ts`:6 | getWorkbenchOptions | GET | `/detect/workbench/options` | 无参 |  |  |  | 是 | — |
| 588 | sdk-smp-api | 查询检测操作台授权实验室选项 | `modules/detect/workbench.ts`:15 | getWorkbenchLabs | GET | `/detect/workbench/labs` | 无参 |  |  |  |  | — |
| 589 | sdk-smp-api | 查询检测操作台授权检测设备选项 | `modules/detect/workbench.ts`:24 | getWorkbenchDetectors | GET | `/detect/workbench/detectors` | 无参 |  |  |  |  | — |
| 590 | sdk-smp-api | 查询检测设备已启用的检测项 | `modules/detect/workbench.ts`:33 | getWorkbenchDetectorItems | GET | `/detect/workbench/detector/${detectorId}/available-items` | Query+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 591 | sdk-smp-api | 查询检测需求队列 | `modules/detect/workbench.ts`:41 | listWorkbenchQueue | GET | `/detect/workbench/queue` | Query | 是 |  |  |  | — |
| 592 | sdk-smp-api | 查询检测结果列表 | `modules/detect/workbench.ts`:50 | listWorkbenchResults | GET | `/detect/workbench/results` | Query | 是 |  |  |  | — |
| 593 | sdk-smp-api | 立即向对应设备通道刷新一条检测中结果 | `modules/detect/workbench.ts`:59 | refreshWorkbenchResult | POST | `/detect/workbench/result/${resultId}/refresh` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 594 | sdk-smp-api | 暂存检测需求 | `modules/detect/workbench.ts`:67 | saveWorkbenchDraft | POST | `/detect/workbench/sample/save-draft` | 无参 |  |  | 是 |  | — |
| 595 | sdk-smp-api | 发送检测需求 | `modules/detect/workbench.ts`:76 | sendWorkbenchSample | POST | `/detect/workbench/sample/send` | 无参 |  |  | 是 |  | — |
| 596 | sdk-smp-api | 批量发送检测需求 | `modules/detect/workbench.ts`:86 | sendWorkbenchSamples | POST | `/detect/workbench/sample/send/batch` | 无参 |  |  | 是 |  | — |
| 597 | sdk-smp-api | 清空检测操作台需求队列中的记录 | `modules/detect/workbench.ts`:96 | clearWorkbenchSample | PUT | `/detect/workbench/sample/${sampleId}/clear` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 598 | sdk-smp-api | 批量清空检测操作台需求队列中的记录 | `modules/detect/workbench.ts`:105 | clearWorkbenchSamples | PUT | `/detect/workbench/sample/clear/batch` | Body |  |  | 是 |  | — |
| 599 | sdk-smp-api | 修改检测列表样品 ID | `modules/detect/workbench.ts`:118 | updateWorkbenchSampleNo | PUT | `/detect/workbench/result/${resultId}/sample-no` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 600 | sdk-smp-api | 查询样品ID修改历史 | `modules/detect/workbench.ts`:128 | getSampleNoHistory | GET | `/detect/workbench/result/${resultId}/sample-no-history` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 601 | sdk-smp-api | 撤回检测结果 | `modules/detect/workbench.ts`:136 | withdrawWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/withdraw` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 602 | sdk-smp-api | 上传检测结果 | `modules/detect/workbench.ts`:145 | uploadWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/upload` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 603 | sdk-smp-api | 标记检测结果异常 | `modules/detect/workbench.ts`:154 | markWorkbenchException | PUT | `/detect/workbench/result/${resultId}/exception` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 604 | sdk-smp-api | 记录检测结果打印 | `modules/detect/workbench.ts`:163 | printWorkbenchResult | POST | `/detect/workbench/result/${resultId}/print` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 605 | sdk-smp-api | 作废检测结果（操作台入口） | `modules/detect/workbench.ts`:172 | voidWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/void` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 606 | sdk-smp-api | 撤销作废检测结果 | `modules/detect/workbench.ts`:181 | revokeVoidWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/revoke-void` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 607 | sdk-smp-api | 签名检测结果（仅已上传结果可签名） | `modules/detect/workbench.ts`:190 | signWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/sign` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 608 | sdk-smp-api | 撤销签名检测结果（恢复为已上传） | `modules/detect/workbench.ts`:199 | revokeSignWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/revoke-sign` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 609 | sdk-smp-api | 查询检测结果明细项列表 | `modules/detect/workbench.ts`:208 | getWorkbenchResultItems | GET | `/detect/workbench/result/${resultId}/items` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 610 | sdk-smp-api | 发送 BGA 检测订单 | `modules/sdms/order.ts`:6 | sendBgaOrder | POST | `/sdms/order/send` | 无参 |  |  | 是 |  | — |
| 611 | sdk-smp-api | 校验设备序列号 + 私钥是否有效 | `modules/sdms/order.ts`:15 | validEqu | POST | `/sdms/order/validEqu` | 无参 |  |  | 是 |  | — |
| 612 | sdk-smp-api | 按时间范围查询检测结果 | `modules/sdms/order.ts`:24 | getOrderResult | POST | `/sdms/order/result` | 无参 |  |  | 是 |  | — |
| 613 | sdk-smp-api | — | `sign-console.ts`:98 | signConsoleApi.projects | GET | `/detect/sign-console/projects` | 无参 |  |  |  |  | — |
| 614 | sdk-smp-api | — | `sign-console.ts`:100 | signConsoleApi.batches | GET | `/detect/sign-console/batches` | Query |  |  |  |  | — |
| 615 | sdk-smp-api | — | `sign-console.ts`:108 | signConsoleApi.query | POST | `/detect/sign-console/query` | Query+Body |  |  | 是 |  | — |
| 616 | sdk-smp-api | — | `sign-console.ts`:126 | signConsoleApi.print | POST | `/detect/sign-console/print` | Query |  |  | 是 |  | — |
| 617 | sdk-smp-api | — | `sign-console.ts`:133 | signConsoleApi.export | POST | `/detect/sign-console/export` | Query |  |  | 是 |  | — |
| 618 | sdk-smp-api | 查询检测操作台下拉选项 | `workbench.ts`:35 | getWorkbenchOptions | GET | `/detect/workbench/options` | 无参 |  |  |  | 是 | — |
| 619 | sdk-smp-api | 查询检测操作台授权实验室选项 | `workbench.ts`:44 | getWorkbenchLabs | GET | `/detect/workbench/labs` | 无参 |  |  |  |  | — |
| 620 | sdk-smp-api | 查询检测操作台授权检测设备选项 | `workbench.ts`:53 | getWorkbenchDetectors | GET | `/detect/workbench/detectors` | 无参 |  |  |  |  | — |
| 621 | sdk-smp-api | 查询检测设备已启用的检测项 | `workbench.ts`:62 | getWorkbenchDetectorItems | GET | `/detect/workbench/detector/${detectorId}/available-items` | Query+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 622 | sdk-smp-api | 查询检测需求队列 | `workbench.ts`:70 | listWorkbenchQueue | GET | `/detect/workbench/queue` | Query | 是 |  |  |  | — |
| 623 | sdk-smp-api | 查询检测结果列表 | `workbench.ts`:80 | listWorkbenchResults | GET | `/detect/workbench/results` | Query | 是 |  |  |  | — |
| 624 | sdk-smp-api | 立即向对应设备通道刷新一条检测中结果 | `workbench.ts`:90 | refreshWorkbenchResult | POST | `/detect/workbench/result/${resultId}/refresh` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 625 | sdk-smp-api | 暂存检测需求 | `workbench.ts`:98 | saveWorkbenchDraft | POST | `/detect/workbench/sample/save-draft` | 无参 |  |  | 是 |  | — |
| 626 | sdk-smp-api | 发送检测需求 | `workbench.ts`:110 | sendWorkbenchSample | POST | `/detect/workbench/sample/send` | 无参 |  |  | 是 |  | — |
| 627 | sdk-smp-api | 批量发送检测需求 | `workbench.ts`:123 | sendWorkbenchSamples | POST | `/detect/workbench/sample/send/batch` | 无参 |  |  | 是 |  | — |
| 628 | sdk-smp-api | 清空检测操作台需求队列中的记录 | `workbench.ts`:136 | clearWorkbenchSample | PUT | `/detect/workbench/sample/${sampleId}/clear` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 629 | sdk-smp-api | 批量清空检测操作台需求队列中的记录 | `workbench.ts`:145 | clearWorkbenchSamples | PUT | `/detect/workbench/sample/clear/batch` | Body |  |  | 是 |  | — |
| 630 | sdk-smp-api | 修改检测列表样品 ID | `workbench.ts`:158 | updateWorkbenchSampleNo | PUT | `/detect/workbench/result/${resultId}/sample-no` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 631 | sdk-smp-api | 查询样品ID修改历史 | `workbench.ts`:168 | getSampleNoHistory | GET | `/detect/workbench/result/${resultId}/sample-no-history` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 632 | sdk-smp-api | 撤回检测结果 | `workbench.ts`:179 | withdrawWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/withdraw` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 633 | sdk-smp-api | 上传检测结果 | `workbench.ts`:191 | uploadWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/upload` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 634 | sdk-smp-api | 标记检测结果异常 | `workbench.ts`:203 | markWorkbenchException | PUT | `/detect/workbench/result/${resultId}/exception` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 635 | sdk-smp-api | 记录检测结果打印 | `workbench.ts`:212 | printWorkbenchResult | POST | `/detect/workbench/result/${resultId}/print` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 636 | sdk-smp-api | 作废检测结果（操作台入口） | `workbench.ts`:221 | voidWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/void` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 637 | sdk-smp-api | 撤销作废检测结果 | `workbench.ts`:233 | revokeVoidWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/revoke-void` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 638 | sdk-smp-api | 签名检测结果（仅已上传结果可签名） | `workbench.ts`:242 | signWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/sign` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 639 | sdk-smp-api | 撤销签名检测结果（恢复为已上传） | `workbench.ts`:254 | revokeSignWorkbenchResult | PUT | `/detect/workbench/result/${resultId}/revoke-sign` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 640 | sdk-smp-api | 查询检测结果明细项列表 | `workbench.ts`:263 | getWorkbenchResultItems | GET | `/detect/workbench/result/${resultId}/items` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 641 | sdk-smp-api | — | `workbench.ts`:271 | logInCheckBga | GET | `/detect/workbench/${detectorId}/logInCheck` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 642 | sdk-smp-api | — | `workbench.ts`:279 | logInCheckVicell | GET | `/detect/workbench/${detectorId}/logInCheck` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 643 | sdk-smp-api | — | `workbench.ts`:287 | logInCheckOsmo | GET | `/detect/workbench/${detectorId}/logInCheck` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 644 | sdk-smp-api | — | `workbench.ts`:295 | logInCheckCedex | GET | `/detect/workbench/${detectorId}/logInCheck` | Query+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |

## 分类 8：告警通知类 M09

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 645 | sdk-smp-api | 查询系统发件配置列表 | `modules/alarm/alarmMailConfig.ts`:6 | listAlarmMailConfig | GET | `/alarm/alarmMailConfig/list` | Query | 是 |  |  |  | — |
| 646 | sdk-smp-api | 查询系统发件配置详细 | `modules/alarm/alarmMailConfig.ts`:15 | getAlarmMailConfig | GET | `/alarm/alarmMailConfig/${configId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 647 | sdk-smp-api | 查询发件设置聚合 | `modules/alarm/alarmMailConfig.ts`:23 | getAlarmMailConfigConfig | GET | `/alarm/alarmMailConfig/config` | Body |  |  |  |  | — |
| 648 | sdk-smp-api | 新增系统发件配置 | `modules/alarm/alarmMailConfig.ts`:31 | addAlarmMailConfig | POST | `/alarm/alarmMailConfig` | 无参 |  |  | 是 |  | — |
| 649 | sdk-smp-api | 新增或更新系统发件配置 | `modules/alarm/alarmMailConfig.ts`:40 | saveAlarmMailConfig | PUT | `/alarm/alarmMailConfig/config` | 无参 |  |  | 是 |  | — |
| 650 | sdk-smp-api | 修改系统发件配置 | `modules/alarm/alarmMailConfig.ts`:49 | updateAlarmMailConfig | PUT | `/alarm/alarmMailConfig` | 无参 |  |  | 是 |  | — |
| 651 | sdk-smp-api | 删除系统发件配置 | `modules/alarm/alarmMailConfig.ts`:58 | delAlarmMailConfig | DELETE | `/alarm/alarmMailConfig/${configId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 652 | sdk-smp-api | 查询告警通知接收人关联列表 | `modules/alarm/alarmNotifyReceiver.ts`:6 | listAlarmNotifyReceiver | GET | `/alarm/alarmNotifyReceiver/list` | Query | 是 |  |  |  | — |
| 653 | sdk-smp-api | 查询告警通知接收人关联详细 | `modules/alarm/alarmNotifyReceiver.ts`:15 | getAlarmNotifyReceiver | GET | `/alarm/alarmNotifyReceiver/${receiverId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 654 | sdk-smp-api | 新增告警通知接收人关联 | `modules/alarm/alarmNotifyReceiver.ts`:23 | addAlarmNotifyReceiver | POST | `/alarm/alarmNotifyReceiver` | 无参 |  |  | 是 |  | — |
| 655 | sdk-smp-api | 修改告警通知接收人关联 | `modules/alarm/alarmNotifyReceiver.ts`:32 | updateAlarmNotifyReceiver | PUT | `/alarm/alarmNotifyReceiver` | 无参 |  |  | 是 |  | — |
| 656 | sdk-smp-api | 删除告警通知接收人关联 | `modules/alarm/alarmNotifyReceiver.ts`:41 | delAlarmNotifyReceiver | DELETE | `/alarm/alarmNotifyReceiver/${receiverId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 657 | sdk-smp-api | 查询告警通知规则详细 | `modules/alarm/alarmNotifyRule.ts`:6 | getAlarmNotifyRule | GET | `/alarm/alarmNotifyRule/${ruleId}` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 658 | sdk-smp-api | 查询告警设置配置聚合 | `modules/alarm/alarmNotifyRule.ts`:14 | getAlarmNotifyRuleConfig | GET | `/alarm/alarmNotifyRule/config` | 无参 |  |  |  |  | — |
| 659 | sdk-smp-api | 统一保存告警通知配置 | `modules/alarm/alarmNotifyRule.ts`:23 | saveAlarmNotifyRuleConfig | PUT | `/alarm/alarmNotifyRule/config` | 无参 |  |  | 是 |  | — |
| 660 | sdk-smp-api | 查询告警通知规则详情（含接收人） | `modules/alarm/alarmNotifyRule.ts`:32 | getAlarmNotifyRuleWithReceivers | GET | `/alarm/alarmNotifyRule/${ruleId}/with-receivers` | 路径含ID/动态 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 661 | sdk-smp-api | 查询告警记录列表 | `modules/alarm/alarmRecord.ts`:6 | listAlarmRecord | GET | `/alarm/alarmRecord/list` | Query | 是 |  |  |  | — |
| 662 | sdk-smp-api | 查询告警记录详细 | `modules/alarm/alarmRecord.ts`:15 | getAlarmRecord | GET | `/alarm/alarmRecord/${alarmId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 663 | sdk-smp-api | 处理/忽略告警 | `modules/alarm/alarmRecord.ts`:23 | handleAlarm | POST | `/alarm/alarmRecord/handle` | 无参 |  |  | 是 |  | — |
| 664 | sdk-smp-api | 查询系统通知列表 | `modules/smp/notification.ts`:6 | listNotification | GET | `/smp/notification/list` | Query | 是 |  |  |  | — |
| 665 | sdk-smp-api | 查询系统通知详细 | `modules/smp/notification.ts`:15 | getNotification | GET | `/smp/notification/${notifyId}` | Body+动态路径 |  | 是 |  |  | 路径含动态ID/变量，需运行时确认 |
| 666 | sdk-smp-api | 新增系统通知 | `modules/smp/notification.ts`:23 | addNotification | POST | `/smp/notification` | 无参 |  |  | 是 |  | — |
| 667 | sdk-smp-api | 修改系统通知 | `modules/smp/notification.ts`:32 | updateNotification | PUT | `/smp/notification` | 无参 |  |  | 是 |  | — |
| 668 | sdk-smp-api | — | `modules/smp/notification.ts`:40 | markReadNotification | PUT | `/smp/notification/read/${notifyId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 669 | sdk-smp-api | — | `modules/smp/notification.ts`:47 | markReadNotifications | PUT | `/smp/notification/read/batch/${notifyIds}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 670 | sdk-smp-api | 删除系统通知 | `modules/smp/notification.ts`:55 | delNotification | DELETE | `/smp/notification/${notifyId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 671 | sdk-smp-api | — | `modules/smp/notification.ts`:62 | checkAlarm | POST | `/smp/notification/check-alarm/${resultId}` | 路径含ID/动态 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |
| 672 | sdk-smp-api | Keep the original SMP notification contract (not system/notice or EES messages). | `notification.ts`:18 | notificationApi.unread | GET | `/smp/notification/list` | Query | 是 |  |  |  | — |

## 分类 9：其他/无法归类

| 序号 | 前端模块 | 页面/功能 | 源文件 | 方法名 | HTTP方法 | 前端请求路径 | 参数来源 | 是否列表 | 是否详情 | 是否新增编辑删除 | 是否下拉/options | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 673 | sdk-smp-api | — | `modules/subsystem/bga.ts`:7 | logInCheck | POST | `/namedpipe/bga/logInCheck` | Query+Body |  |  | 是 |  | — |
| 674 | sdk-smp-api | — | `modules/subsystem/bga.ts`:15 | logIn | POST | `/namedpipe/bga/logIn` | Query |  |  | 是 |  | — |
| 675 | sdk-smp-api | — | `modules/subsystem/bga.ts`:24 | sendOrder | POST | `/namedpipe/bga/sendOrder` | Query |  |  | 是 |  | — |
| 676 | sdk-smp-api | — | `modules/subsystem/bga.ts`:33 | cancel | POST | `/namedpipe/bga/cancel` | Query |  |  | 是 |  | — |
| 677 | sdk-smp-api | — | `modules/subsystem/bga.ts`:41 | cancelSample | POST | `/namedpipe/bga/cancelSample` | Query+Body |  |  | 是 |  | — |
| 678 | sdk-smp-api | — | `modules/subsystem/bga.ts`:50 | queryResult | POST | `/namedpipe/bga/result` | Query |  |  | 是 |  | — |
| 679 | sdk-smp-api | — | `modules/subsystem/bga.ts`:58 | refreshResult | POST | `/namedpipe/bga/refreshResult` | Query+Body |  |  | 是 |  | — |
| 680 | sdk-smp-api | — | `modules/subsystem/bga.ts`:67 | queryPortName | POST | `/namedpipe/bga/queryPortName` | Query+Body |  |  | 是 |  | — |
| 681 | sdk-smp-api | — | `modules/subsystem/bga.ts`:75 | saveDevice | POST | `/namedpipe/bga/saveDevice` | Query |  |  | 是 |  | — |
| 682 | sdk-smp-api | — | `modules/subsystem/cedex.ts`:7 | getPortNames | POST | `/namedpipe/cedex/getPortNames` | Query+Body |  |  | 是 |  | — |
| 683 | sdk-smp-api | — | `modules/subsystem/cedex.ts`:15 | saveDevice | POST | `/namedpipe/cedex/saveSubsystemDevice` | Query |  |  | 是 |  | — |
| 684 | sdk-smp-api | — | `modules/subsystem/cedexOrder.ts`:7 | logInCheck | POST | `/namedpipe/cedexOrder/logInCheck` | Query+Body |  |  | 是 |  | — |
| 685 | sdk-smp-api | — | `modules/subsystem/cedexOrder.ts`:15 | logIn | POST | `/namedpipe/cedexOrder/logIn` | Query |  |  | 是 |  | — |
| 686 | sdk-smp-api | — | `modules/subsystem/cedexOrder.ts`:24 | sendOrders | POST | `/namedpipe/cedexOrder/sendOrders` | Query |  |  | 是 |  | — |
| 687 | sdk-smp-api | — | `modules/subsystem/cedexOrder.ts`:33 | queryResult | POST | `/namedpipe/cedexOrder/queryResult` | Query+Body |  |  | 是 |  | — |
| 688 | sdk-smp-api | — | `modules/subsystem/cedexOrder.ts`:42 | emptyRacks | POST | `/namedpipe/cedexOrder/emptyRacks` | Query |  |  | 是 |  | — |
| 689 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:7 | logInCheck | POST | `/namedpipe/osmo/logInCheck` | Query+Body |  |  | 是 |  | — |
| 690 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:15 | logIn | POST | `/namedpipe/osmo/logIn` | Query |  |  | 是 |  | — |
| 691 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:24 | order | POST | `/namedpipe/osmo/order` | Query |  |  | 是 |  | — |
| 692 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:33 | cancel | POST | `/namedpipe/osmo/cancel` | Query |  |  | 是 |  | — |
| 693 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:41 | start | POST | `/namedpipe/osmo/start` | Query |  |  | 是 |  | — |
| 694 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:49 | queryResult | POST | `/namedpipe/osmo/result` | Query |  |  | 是 |  | — |
| 695 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:57 | delOrder | POST | `/namedpipe/osmo/delOrder` | Query+Body |  |  | 是 |  | — |
| 696 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:66 | queryPortName | POST | `/namedpipe/osmo/queryPortName` | Query+Body |  |  | 是 |  | — |
| 697 | sdk-smp-api | — | `modules/subsystem/osmo.ts`:74 | saveDevice | POST | `/namedpipe/osmo/saveDevice` | Query |  |  | 是 |  | — |
| 698 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:7 | saveSetting | POST | `/namedpipe/vicell/saveSubsystemSetting` | Query |  |  | 是 |  | — |
| 699 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:16 | logInCheck | POST | `/namedpipe/vicell/logInCheck` | Query+Body |  |  | 是 |  | — |
| 700 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:24 | logIn | POST | `/namedpipe/vicell/logIn` | Query |  |  | 是 |  | — |
| 701 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:33 | logInManual | POST | `/namedpipe/vicell/logInManual` | Query |  |  | 是 |  | — |
| 702 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:42 | clear | POST | `/namedpipe/vicell/clear` | Query+Body |  |  | 是 |  | — |
| 703 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:51 | cancel | POST | `/namedpipe/vicell/cancel` | Query |  |  | 是 |  | — |
| 704 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:59 | queryResult | POST | `/namedpipe/vicell/result` | Query+Body |  |  | 是 |  | — |
| 705 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:67 | refresh | POST | `/namedpipe/vicell/refresh` | Query |  |  | 是 |  | — |
| 706 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:76 | delOrder | POST | `/namedpipe/vicell/delOrder` | Query+Body |  |  | 是 |  | — |
| 707 | sdk-smp-api | — | `modules/subsystem/vicell.ts`:85 | reset | POST | `/namedpipe/vicell/reset` | Query |  |  | 是 |  | — |
| 708 | sdk-smp-api | — | `workflow.ts`:89 | workflowApi.update | PUT | `/process/workflow/` | Body+动态路径 |  | 是 | 是 |  | 路径含动态ID/变量，需运行时确认 |

## 旧路径风险清单（/login、/getInfo、/getRouters、/captchaImage 单体分离式路径）

未发现旧前后端分离裸路径。登录认证已全部走微服务路径：

- `/code`（GET）— sdk-smp-api/src/index.ts:62 `(authApi.captcha)`
- `/auth/login`（POST）— sdk-smp-api/src/index.ts:71 `(authApi.login)`
- `/auth/logout`（DELETE）— sdk-smp-api/src/index.ts:88 `(authApi.logout)`
- `/auth/unlockscreen`（POST）— sdk-smp-api/src/index.ts:93 `(authApi.unlock)`
- `/auth/aad/status`（GET）— sdk-smp-api/src/index.ts:103 `(authApi.aadStatus)`
- `/auth/aad/token`（POST）— sdk-smp-api/src/index.ts:105 `(authApi.aadToken)`
- 用户信息/菜单走 `/system/user/getInfo` 与 `/system/menu/getRouters`（微服务前缀，非旧裸路径），验证码为 `/code`（新版 RuoYi 路径，非 `/captchaImage`）。

## pageSize 超白名单风险清单（后端分页白名单 10/20/50/100）

| 源文件 | 行 | pageSize | 涉及接口方法 | 说明 |
|---|---|---|---|---|
| `app-smp-data/src/views/detect-assignee/index.vue` | 420 | 1000 | loadProjectOptions / listProject / loadUserOptions | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-data/src/views/detect-assignee/index.vue` | 427 | 2000 | loadUserOptions / listUser / loadBatchOptions | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-data/src/views/detect-assignee/index.vue` | 434 | 1000 | loadBatchOptions / listBatch | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-data/src/views/detect-assignee/index.vue` | 448 | 1000 | loadCultureOptions / listCulture | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-data/src/workbench/bga/use-workbench.ts` | 1333 | 1000 | listPrinter | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-data/src/workbench/cedex/use-workbench.ts` | 1404 | 1000 | listPrinter | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-data/src/workbench/osmo/use-workbench.ts` | 1322 | 1000 | listPrinter | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-data/src/workbench/vicell/use-workbench.ts` | 1319 | 1000 | listPrinter | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/alarm-alarm-record/index.vue` | 388 | 9999 | getLabOptions / loadLabSelectOptions | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/batch-management/batch-editor.vue` | 207 | 1000 | labIntegratedReactorApi.list / cultureContainerApi.list | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/batch-management/batch-editor.vue` | 211 | 1000 | labIntegratedReactorApi.list / cultureContainerApi.list / labBenchReactorApi.list | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/batch-management/batch-editor.vue` | 220 | 1000 | labBenchReactorApi.list | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/batch-management/index.vue` | 235 | 1000 | projectApi.list / authApi.labs | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/culture-management/index.vue` | 242 | 1000 | projectApi.list / authApi.labs | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-balance/balance-editor.vue` | 120 | 2000 | loadUserOptions / listUser / loadFloorScaleOptions | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-balance/balance-editor.vue` | 127 | 1000 | loadFloorScaleOptions / listDevfloorscale | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-balance/index.vue` | 256 | 2000 | loadUserOptions / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-benchreactorcontroller/benchreactorcontroller-editor.vue` | 74 | 1000 | loadBalanceOptions / listLabfloorscale | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-culturecontainer/index.vue` | 556 | 1000 | loadSpecOptions / listContainerspec | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-detectorconfig/index.vue` | 182 | 1000 | loadDetectorOptions / listLabdetector / getList | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-downstreamdevice/device-editor.vue` | 448 | 2000 | loadUserOptions / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-downstreamdevice/device-editor.vue` | 462 | 1000 | loadDeviceOptions / listDevfloorscale / listDevAnalyzerModel | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-downstreamdevice/device-editor.vue` | 465 | 1000 | loadDeviceOptions / listDevfloorscale / listDevAnalyzerModel | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-downstreamdevice/index.vue` | 340 | 1000 | loadAnalyzerOptions / listDevAnalyzerModel | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labairpump/index.vue` | 242 | 1000 | loadDeviceOptions / listDevairpum / loadUserOptions | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labairpump/index.vue` | 248 | 2000 | loadUserOptions / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-labbenchreactor/labbenchreactor-editor.vue` | 243 | 1000 | loadDeviceOptions / listBenchreactor | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labdetector/index.vue` | 378 | 1000 | loadVenueOptions / loadDeviceOptions / listDevdetector | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labdetector/index.vue` | 384 | 2000 | loadUserOptions / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-labfloorscale/index.vue` | 388 | 1000 | loadModelOptions / listDevfloorscale / loadUserOptions | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labfloorscale/index.vue` | 394 | 2000 | loadUserOptions / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-labintegratedreactor/index.vue` | 370 | 2000 | loadUserOptions / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-labintegratedreactor/reactor-detail.vue` | 248 | 2000 | loadUserMap / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-labintegratedreactor/reactor-editor.vue` | 269 | 1000 | loadLabSelectOptions / listIntegratedreactor / listUser | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labintegratedreactor/reactor-editor.vue` | 270 | 2000 | loadLabSelectOptions / listIntegratedreactor / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-labintegratedreactor/use-reactor-options.ts` | 35 | 1000 | fetchRows | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labperistalticpump/index.vue` | 244 | 1000 | loadDeviceOptions / listDevperistalticpump / loadUserOptions | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-labperistalticpump/index.vue` | 252 | 2000 | loadUserOptions / listUser | listUser 已在 SDK 内剥离 pageSize 并逐页取满（安全） |
| `app-smp-settings/src/views/lab-offlinealarm/index.vue` | 349 | 1000 | listDetectoritem / listOfflinealarm | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/lab-offlinealarm/index.vue` | 354 | 1000 | listOfflinealarm | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/system-user/index.vue` | 518 | 1000 | getOnlineUsers / listOnlineUser | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/system-user/user-editor.vue` | 166 | 1000 | getLabOptions / loadLabSelectOptions / getLabGroupOptions | 直传后端，越界将被 M01-048 分页白名单拒绝 |
| `app-smp-settings/src/views/system-user/user-editor.vue` | 174 | 1000 | getLabGroupOptions / listLabgroup | 直传后端，越界将被 M01-048 分页白名单拒绝 |

## options / 下拉缺口候选

SDK 已有的 options/tree/字典类入口：

- `/system/dict/type/optionselect`
- `/smp/venue/tree`
- `/system/dict/data/type/{id}`
- `/system/dict/data/type/{id}/tree`
- `/system/dict/data/type/{id}/children/{id}`
- `/system/menu/treeselect`
- `/system/role/deptTree/{id}`
- `/system/user/deptTree`
- `/lab/lab/options`
- `/detect/workbench/options`

候选缺口（页面无 options 接口、用超大 pageSize 列表代替下拉的调用点）：

| 页面 | 代替下拉的调用 | 建议核对的后端 options 接口 |
|---|---|---|
| app-smp-data/src/views/detect-assignee/index.vue | `listProject` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-data/src/views/detect-assignee/index.vue<br>app-smp-settings/src/views/lab-balance/balance-editor.vue<br>app-smp-settings/src/views/lab-balance/index.vue<br>app-smp-settings/src/views/lab-downstreamdevice/device-editor.vue<br>app-smp-settings/src/views/lab-labairpump/index.vue<br>app-smp-settings/src/views/lab-labdetector/index.vue | `listUser` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-data/src/views/detect-assignee/index.vue | `listBatch` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-data/src/views/detect-assignee/index.vue | `listCulture` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-data/src/workbench/bga/use-workbench.ts<br>app-smp-data/src/workbench/cedex/use-workbench.ts<br>app-smp-data/src/workbench/osmo/use-workbench.ts<br>app-smp-data/src/workbench/vicell/use-workbench.ts | `listPrinter` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/alarm-alarm-record/index.vue ⇒ /lab/lab/list<br>app-smp-settings/src/views/lab-labintegratedreactor/reactor-editor.vue ⇒ /lab/lab/list<br>app-smp-settings/src/views/system-user/user-editor.vue ⇒ /lab/lab/list | `lab list` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/batch-management/batch-editor.vue ⇒ 对应模块 /list 接口 | `labIntegratedReactorApi.list` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/batch-management/batch-editor.vue ⇒ 对应模块 /list 接口 | `cultureContainerApi.list` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/batch-management/batch-editor.vue ⇒ 对应模块 /list 接口 | `labBenchReactorApi.list` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/batch-management/index.vue ⇒ 对应模块 /list 接口<br>app-smp-settings/src/views/culture-management/index.vue ⇒ 对应模块 /list 接口 | `projectApi.list` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-balance/balance-editor.vue<br>app-smp-settings/src/views/lab-downstreamdevice/device-editor.vue<br>app-smp-settings/src/views/lab-labfloorscale/index.vue | `listDevfloorscale` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-benchreactorcontroller/benchreactorcontroller-editor.vue | `listLabfloorscale` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-culturecontainer/index.vue | `listContainerspec` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-detectorconfig/index.vue | `listLabdetector` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-downstreamdevice/device-editor.vue<br>app-smp-settings/src/views/lab-downstreamdevice/index.vue | `listDevAnalyzerModel` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-labairpump/index.vue | `listDevairpum` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-labbenchreactor/labbenchreactor-editor.vue | `listBenchreactor` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-labdetector/index.vue | `listDevdetector` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-labintegratedreactor/reactor-editor.vue | `listIntegratedreactor` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-labperistalticpump/index.vue | `listDevperistalticpump` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-offlinealarm/index.vue | `listDetectoritem` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/lab-offlinealarm/index.vue | `listOfflinealarm` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/system-user/index.vue | `listOnlineUser` | 需确认是否存在 /options 或 listAll 契约 |
| app-smp-settings/src/views/system-user/user-editor.vue | `listLabgroup` | 需确认是否存在 /options 或 listAll 契约 |

## 运行时确认清单（路径拼接不明确项汇总）

### 下载调用缺少前导斜杠（疑似运行时缺陷）

- `/lab/downstreamdevice/export` — app-smp-settings/src/views/lab-downstreamdevice/index.vue:443 `(handleExport)`

- 动态 ID 拼接：如 `/system/user/${userId}`、`/resource/project/${projectId}/members`、`/detect/workbench/result/${resultId}/sign` 等，见上表“备注=路径含动态ID”。
- 子系统直连代理：`/namedpipe/{bga|cedex|cedexOrder|osmo|vicell}/...`，最终目标由运行参数 `host`、`pipeName` 决定，需联调确认。
- 通用文件组件：`sdk-smp-common/components/excel-import-dialog` 上传地址为 `${base}${props.action}`（当前唯一调用方传入 `/system/user/importData`、模板 `/system/user/importTemplate`），`user-import-dialog.vue` 的 `templateAction` 默认空串，需运行时确认传入值。
- 内嵌页面直链：`${base}/druid/login.html`、`${base}/swagger-ui/index.html`（非 JSON 接口，走网关静态路由）。
- `download(zip)` 工具透传任意 url：`save(url, {}, name)`，实际路径由各调用点传入。

总接口调用点：**708**