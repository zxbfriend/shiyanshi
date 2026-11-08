# B16 Git同步、误回退纠正与前端编译修复

日期：2026-11-07。用户明确授权同步远端、保护本地功能、分功能中文提交；随后要求先修复前端编译。仅本地提交，未推送。

## 同步及保护

起始cloud/9a37ef0ba7c133a65a13be834f43408196a41b1d。fetch后origin/cloud为12f149cf3，领先9提交。ed3edd764为误回退9a37ef0ba，用户明确要求保留原成果。变更前按实际未跟踪文件展开，保存551个文件记录/恢复副本及tracked binary patch到本任务temp；临时副本不提交、不作为正式唯一证据。只按显式文件路径暂存，没有git add .或-A，没有reset/clean或批量覆盖。

本地功能按M01、M02、M04、M03生命周期/D0、M03参数、M05、M06、M07、M08、M09、共享契约、设计交接分组提交。用户要求暂停后，已终止后续提交，修复并取得完整前端构建退出0后再继续。本次中断产生零字节index.lock；确认无git/python活动进程、锁时间与本次中断一致后，仅移除该锁，没有终止GitHub Desktop。

38f45c8c1合入远端；9份冲突文档全部属于误回退影响文件，核对后保留本地更新内容。91046ac83纠正误回退，恢复SDK、真实型号来源和相关测试；不重写远端历史。ApprovalPolicyPortProvider同时保留本地CONFIG保存事务资格和远端审批流未配置提示。culture.ts同时保留原参数方法与远端成员显示方法。

同步核验：origin/cloud是当前HEAD祖先（原退出0）；远端独立更新逐文件Git对象比对差异0。合并前已有本地修改与副本按统一LF比对，功能差异仅为本轮3个settings类型兼容修复及已核对的ApprovalPolicy提示合并。本机nacos-config/application-dev.yml仍未提交，期间内容有变化，不回退或覆盖。Config预览与新增测试原本不是开工修改，单独以35cfe252f提交。

## 前端编译问题与最小修复

初次pnpm 8.6.2 build:prod退出1，9处TS报错：pilot-state 6处（source可null）、通知规则模板回调1处隐式any、邮件/短信replaceAll各1处（当前目标lib不支持）。仅4个源码文件修改：NonNullable用于构造辅助类型，预览读取先判断真实source，模板回调明确revisionId结构类型，字符串替换改全局正则；未调整tsconfig/目标lib或跳过检查。增加Nothing输出不读取空来源的行为回归。

## 实际验证

- lab/settings定向build-dts分别原退出0。
- 修复后、同步前完整build:prod原退出0：10项目build/build-dts/check-without-dts及生产产物检查通过；日志明示25任务中6项使用Nx缓存，未宣称全部重新编译。
- 合并后3文件定向Vitest：16例通过、0失败，原退出0（Config预览8、配置SDK5、远端成员显示SDK3）。这是隔离测试，不是HTTP或浏览器。
- 合并后完整build:prod原退出0，10项目及生产产物检查通过；25任务中2项使用Nx缓存。
- 静态git diff --check原退出0；合并冲突已解决。未运行新的后端编译/测试、数据库、真实HTTP/浏览器或设备联调，不能以本次前端构建宣称V5.1全部通过。

## 当前提交

- 470e3dc2a feat(m09): 补齐规则快照提醒策略及回归配套
- 91046ac83 fix: 撤销误回退并恢复配置参数SDK与真实型号来源
- 38f45c8c1 merge: 同步远端最新功能并保留本地设计成果
- 35cfe252f fix(m07): 兼容Config空输出来源并补充预览回归
- fc1eb8b02 docs: 设计契约与测试交接
- 6db1c604c feat: 共享契约与回归登记
- 41ec67d42 feat(m09): 接通告警配置通知并修复前端类型兼容
- 61df00e97 feat: M08统计对比与工作台
- a583fca7f feat: M07任务工作流与执行边界
- 7c98d5a34 feat: M06审批策略与决定交付
- 1ca79eb77 feat: M05检测签批报告与使用记录
- de0811ade feat: M03培养参数与跨模块事实
- 0e5a78bf9 feat: M03培养生命周期与D0联动
- f3ade2ce1 feat: M04模板与固定包
- 15799c087 feat: M02资源查询与型号来源
- 3da7e414a feat: M01管理查询与个人设置

## 正式验证证据

- [初次失败日志](B16-evidence/frontend-build.log.txt)
- [修复后构建日志](B16-evidence/frontend-build-fixed.log.txt)
- [合并后构建日志](B16-evidence/frontend-build-merged.log.txt)
- [合并后16例回归](B16-evidence/frontend-merged-regression.log.txt)

上述日志仅去除终端颜色控制符和行尾空白，未改动报错、用例结果或构建结论。最终工作区只保留本机Nacos配置未提交；未推送。
