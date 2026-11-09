# 路由与 TypeScript 架构

## 路由目录

沿用 fabsyn-frontend 的 `RouteRecordRaw[]`、`useRoutes(routes)`、`RouterView` 模式。子应用负责声明与渲染页面，门户负责登录、锁屏、授权校验和离开保护。

```text
packages/portal/src/router/index.ts  # 门户页面、子应用入口、守卫和实例创建
packages/app-smp-data/src/router/index.ts
packages/app-smp-settings/src/router/index.ts
packages/app-smp-lab/src/router/index.ts
packages/sdk-smp-stores/src/route-paths.ts            # 索引访问与路由 meta 类型
packages/sdk-smp-stores/src/route-paths.generated.ts  # 自动生成的菜单路径索引
scripts/generate-route-paths.ts
```

| 子应用 | 已实现的业务页面入口 | 路径（相对子应用） |
| --- | --- | --- |
| app-smp-data | 19 个入口，包含检测工作台、记录、样品、结果、签名及审计 | 见数据应用 router/index.ts 中的检测、样品、结果、签名、审计注释分区 |
| app-smp-settings | 86 个入口，包含系统设置、实验室设备、资源、告警及监控 | 见设置应用 router/index.ts 中的业务分类注释分区 |
| app-smp-lab | 实验室概览、数据看板，共 2 个 | :labId/lab-overview、:labId/culture-dashboard |

四类仪器共用工作台视图，由各自路由的 `props.instrument` 区分。每个子应用保留未知菜单组件的兜底路由；当前菜单基线中69个页面均已覆盖，兜底不计入已实现页面数。系统监控目前复用 settings 应用容器，其授权菜单仍由 `/monitor` 独立管理。

页面采用懒加载。`app.vue` 注册路由并通过 `RouterView` 渲染，数据应用保留公共 `LeftMenu` 布局。路由切换按 `route.path` 重建页面，保证仪器状态和轮询按生命周期清理。

## 地址与权限

### 菜单层级与页面路由

后端菜单树决定导航层级，前端路由表只负责页面地址和组件，两者通过 `meta.menuComponent` 关联。

- 一级菜单作为工作空间入口，二级菜单显示在顶部导航。
- 三级功能页面或目录作为导航项；侧栏显示模式下，三级目录保留自身名称，例如“日志管理”。
- 三级目录下的四级页面显示为内容区顶部 Tab，例如“操作日志 / 登录日志”，不再提升到侧栏。

`buildEntries` 保留页面的三级目录信息 `section`；`navigationGroups` 从已授权且可见的页面生成三级 `items` 及其 Tab 页面。页面列表继续用于路由匹配，不将目录伪装成可访问页面。目录按菜单路径区分，避免同名目录合并；隐藏、权限和后端排序规则保持一致。自动显示模式下，包含四级页面的分组使用侧栏，显式下拉模式仍保留三级目录和内容区 Tab。

侧栏和 Tab 的选中状态都来自当前路由。切换 Tab 使用正常路由跳转，沿用未保存保护；刷新、浏览器前进后退及直达四级页面时，自动定位所属三级目录。只有一个可见四级页面时也保留目录和 Tab，避免权限变化导致层级跳动。

### 文件导入使用 `@/` 别名

路由目录和应用入口中对路由的引用统一使用 `@/`，例如：

```ts
import { routes } from "@/router";

// app-smp-data 中的 @ 指向 packages/app-smp-data/src。
component: () => import("@/views/detection-record/index.vue")
```

每个子项目的 `vite.config.mts` 和 `tsconfig.json` 均将 `@` 解析到该项目自己的 `src`。跨 SDK 导入继续使用 `@futurefab/…` 包名。此约定只改变源码文件导入，不改变路由 `path` 的 URL，也不改变懒加载行为。

### `meta` 字段的含义

`meta` 是路由携带的附加信息，字段由本项目定义，不会因名字相同而自动获得 Vue Router 内置行为。

```ts
{
  path: "detection-record",
  component: () => import("@/views/detection-record/index.vue"),
  meta: {
    menuComponent: "detect/record/index",
    detectionLayout: true,
  },
}
```

| 字段 | 意义 | 当前使用方式 |
| --- | --- | --- |
| `menuComponent` | 与后端菜单 `component` 对应的业务标识，例如 `detect/record/index`。不是磁盘文件路径。 | 数据应用 `src/app.vue` 将此标识与当前授权菜单匹配，筛选检测页面的左侧菜单。其他子应用也保留此关联标记。 |
| `pageLayout: "table"` | 页面使用公共表格容器。 | 门户提供固定高度工作区，并省去外置页面标题；页面用 `PageContainer layout="table"` 的 `filters`、`toolbar`、默认表格、`footer` 插槽组织查询、标题操作、表格和分页。 |
| `detectionLayout` | 此页面是否属于数据应用的检测布局。 | 数据应用先收集标记为 `true` 的路由，再依据当前页面的 `menuComponent` 决定是否使用 `LeftMenu` 布局。未设置或为 `false` 时不纳入该布局和侧栏集合。 |

`detectionLayout: true` 不会自动创建菜单；实际显示项仍来自当前用户已授权、未隐藏的后端菜单。页面访问权限由门户 `router/index.ts` 与 session 菜单校验决定，不由 `meta` 授予。

注意：门户 `components/layout.vue` 中也有名为 `detectionLayout` 的计算属性，它目前依据入口类型和页面标识决定壳层展示，不是直接读取这里的 `meta.detectionLayout`。

`props: { instrument: "cedex" }` 与 `meta` 不同：它会作为组件参数传入共用工作台，选择 Cedex 的业务逻辑。真正加载哪个 Vue 文件由 `component: () => import(...)` 决定。

### 页面地址和权限校验

各应用的 `router` 目录只保留 `index.ts`，直接声明路径、懒加载组件、props 和 meta，并用注释分组。它是路由信息的维护入口。共享 `pageRoutePaths` 由脚本静态读取这些配置生成，用于菜单跳转和权限判断；SDK 不会反向加载子应用。例如 `detect/bga/index` 对应 `/data/detection-bga`。后端菜单的排序、分组、隐藏标识和权限筛选保留。

配置路由本身不会授予页面访问权限。门户守卫在初始化当前用户菜单后确认地址属于已授权入口和页面；无权限、未知页面或未授权实验室返回门户。未登录跳转登录，锁屏跳转锁屏页。

旧格式 `/data/page/%2F...` 等地址仍按原菜单 key 查找，已实现页面跳转新地址并保留 query 和 hash；尚未配置对应组件的授权菜单继续使用原编码地址及未配置页面提示。实验室路径中的 labId 仍参与授权隔离。

新增页面时：

表格页面将标题传入公共容器的 `title`，可用 `usePageTitle` 获取当前菜单名称。主表设置 `height: "100%"`，由容器的剩余空间决定高度；查询区和分页不要与主表共用测量父节点。多表/卡片页可使用 `body-scroll` 在内容区滚动，其内部表格使用自然高度或明确的最大高度。弹窗通过 `overlays` 插槽放置，避免参与主表高度计算。

1. 在 `views/<kebab-case>/index.vue` 实现页面。
2. 在该应用 `src/router/index.ts` 对应分类下注释分区添加路由，直接填写字符串 `path`、懒加载组件和 `meta.menuComponent`；必要时配置 props。
3. 运行 `pnpm run routes:generate` 同步共享索引并提交生成文件，不手动编辑索引。根目录构建、门户启动、类型检查，以及 stores 的 Vite 构建会自动同步；门户和 stores 的开发服务会监听路由修改。`pnpm run routes:check` 和单元测试可检查索引是否过期。
4. 在路由测试中验证路径和授权边界，更新对应应用模块文档与业务菜单清单。

## TypeScript 范围

- 工作台原有 12 个 JS 文件全部迁为 TS：四类控制器、四类队列规则、队列工具、状态映射、轮询及 Cedex 提交参数。
- 接口 SDK 的 `workbench-types.ts` 定义记录、样品检测项、设备、实验室、打印机和响应类型；数据应用 `workbench/types.ts` 定义查询、弹窗及队列权限上下文。
- 页面直接使用控制器推导类型，按能力收窄 Vicell 和 Cedex 分支，移除原 `Record<string, any>`。
- 数据应用关闭 `allowJs`，继续使用严格类型检查；请求适配器和字典加载器保留具体参数及返回值类型。
- prepare、UI 检查、图标生成脚本均使用 `.ts` 和 `tsx`，纳入 Node 类型检查。
- `check:ui` 检查自有源码/脚本是否为 TS、Vue 脚本是否声明 TS、应用是否提供 router 目录，以及是否存在整文件关闭类型检查。

公司原始图标目录中的 `iconfont.js`、`iconfont.full.js` 是完整供应商资源，保留原文件以保证资源一致性；生成器只提取 SVG 数据。`dist` 中的 JS 属于编译产物，不应手工迁为 TS。

## 验证命令

```sh
pnpm run type-check
pnpm run test:unit
pnpm run check:ui
pnpm run build
```

路由测试覆盖页面注册、仪器 props、旧链接 query/hash 保留、跨入口和无权限访问、未配置页面兜底、未保存与提交保护、登录及锁屏。

### 2026-09-15 验证结果

54 项测试通过；10 个项目生产构建、声明生成和类型检查通过；Node 类型与 UI/TS 规范检查通过。测试实际调用公司 useRoutes 验证首次深链接注册、RouterView 渲染、切换及后退。浏览器验证登录页及未登录直链保护正常、无启动错误；本次没有执行已登录设备操作或业务写入。
