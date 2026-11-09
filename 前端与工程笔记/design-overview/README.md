# futurefab-frontend 一页式设计介绍

图片：`futurefab-frontend-design-overview.png`，使用内置 imagegen 生成。

内容依据 `work5/futurefab-frontend迁移设计方案.md` 和 `docs/实施进度.md`，重点展示：

- 登录 → 门户选择 → 主入口切换 → 业务页面；当前授权主入口为系统设置、数据管理、系统监控。
- 10 个工作区包：1 个门户、3 个业务子应用、5 个共享 SDK、1 个公司依赖预构建库。
- 公司 Ant Design Vue、公司 VXE/图表、Less 和集中主题变量、kebab-case 页面目录及 index.vue 入口。
- 一个现有后端同时服务新旧两个前端，按页面逐步迁移和验收。
- 当前基础工程、门户与公共能力已落地，场地管理和检测记录是首批样板页；其余页面继续迁移，实验室入口保留类型，Azure AD 待接入。

生成提示词见 `prompt.md`。介绍图中的连接线表示总体分层，不是包依赖图；详细依赖与实施范围以迁移文档为准。

## 本次服务恢复

- 新前端：http://127.0.0.1:5581/
- 旧前端：http://127.0.0.1:5173/
- 主后端：http://127.0.0.1:8080/
- 设备 Mock：http://127.0.0.1:9080/swagger-ui.html

2026-09-14 已恢复 Redis、后端、设备 Mock 及两个前端，两个前端首页与 `/dev-api/captchaImage` 代理均返回 HTTP 200。服务以隐藏后台进程运行，日志沿用各项目 `.local` 目录。
