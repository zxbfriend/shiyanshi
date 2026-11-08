# 一页式设计介绍图生成说明

最终修订：保留四个章节、全部包名及版式，将首版顶部、边缘和页脚的透明噪点修正为完全不透明的白色/浅蓝色背景；页脚用深色文字重排当前进度与待迁移说明，移除角落难辨认装饰文字。图片必须适合直接分享和打印，不带透明区域。

标题校对修订：只修正顶部四行，依次为 `SMART MATRIX PLATFORM`、`futurefab-frontend`、`SMP 新前端 · 设计与迁移概览`、`参考 fabsyn 架构，统一公司组件与 SMP 业务体验`；其余版式、章节、包名及页脚保持不变。

工具：内置 imagegen。内容依据当前迁移方案和实施进度；图片为设计介绍，不代表所有业务已完成迁移。

## 最终提示词

Use case: infographic-diagram. Create ONE polished Chinese one-page architecture and product design introduction image for the existing project "futurefab-frontend", SMP SMART MATRIX PLATFORM. This is a professional internal project overview poster, not a new product UI concept. Portrait 3:4 high resolution, all text clean readable Simplified Chinese, precise English code identifiers. Strong information hierarchy, generous margins, white and very pale icy blue background, restrained cyan #007fac accents, dark navy headings, thin connector lines, modest rounded panels. Subtle transparent glass ribbon decoration at upper right only. No invented logos. Editorial technology design, high clarity and accurate content rather than excessive decorations. Use small line icons, a visual top flow and a main architecture stack.
Exact text and structure:
Top small eyebrow: "SMART MATRIX PLATFORM"
Main title large: "futurefab-frontend"
Subtitle: "SMP 新前端 · 设计与迁移一页概览"
Short positioning line: "参照 fabsyn 架构与公司组件，承接现有 SMP 业务"
SECTION 01 "统一体验"
A horizontal clear arrow flow: "登录" → "门户选择" → "主入口切换" → "业务页面"
Below flow show exactly THREE current entry chips: "系统设置" "数据管理" "系统监控"
Caption: "菜单来自后端授权；实验室入口仅在具备对应菜单时显示"
Small concise feature row: "中英文切换  /  浅色与深色  /  个人中心与锁屏"
SECTION 02 "10 个工作区包，共用一套能力"
Architecture large stack (counts exact):
First top wide layer heading "1 个门户基座" code "portal" subtitle "登录 · 门户 · 导航 · 权限 · 子应用管理"
Second layer heading "3 个业务子应用", three equal adjacent boxes code "app-smp-lab" caption "实验室业务（预留入口）"; code "app-smp-data" caption "数据管理"; code "app-smp-settings" caption "系统设置与监控"
Third layer heading "5 个共享 SDK", five tidy cells in readable two or three rows:
"sdk-smp-api" / "接口与类型"
"sdk-smp-stores" / "会话与权限"
"sdk-smp-common" / "公共组件与页面容器"
"sdk-language" / "公共词条＋子应用词条"
"sdk-smp-static-files" / "品牌资源＋主题颜色变量"
Bottom layer "1 个依赖预构建库" code "lib-smp-base" caption "统一预构建公司组件依赖"
Connecting lines communicate apps use shared SDK and component library, no complex dependencies.
SECTION 03 "统一开发规范"
Four short parallel rows with simple line icons:
"公司 Ant Design Vue" caption "表单、菜单与基础控件"
"公司 vxe-grid 与图表" caption "统一表格和图表能力"
"Less ＋ 主题变量" caption "浅深色与品牌资源集中管理"
"kebab-case / index.vue" caption "页面目录与入口文件规范"
SECTION 04 "一个后端，两个前端"
Simple diagram with two frontends converging to one backend:
"futurefab-ui" label "旧前端" and "futurefab-frontend" label "新前端" both arrows into "现有 SMP 后端"
Caption: "保留接口与权限契约，逐页迁移、逐页验收"
Footer highlighted progress strip:
"当前进度：基础工程、门户与公共能力已落地；场地管理、检测记录为首批样板页。"
Second footnote:
"其余业务页面继续迁移；实验室入口保留类型，Azure AD 待接入。"
Ensure no claim entire migration complete, no fabrication of lab menu entries, no piecharts or fake numerical metrics. No Element Plus. Carefully proofread package names; no duplicate or missing SDK packages. Compact but readable all on one page.
