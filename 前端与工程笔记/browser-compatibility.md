# 浏览器构建兼容

所有 portal、app、SDK 和公共库的 Vite 配置都接入 `scripts/browser-compat.ts`。使用 `postcss-preset-env`（包含 Autoprefixer）转换通用 CSS，并配合项目专用回退和按能力加载的运行时补丁。继续使用现有命令 `pnpm run build:prod`；开发服务也使用同一组 CSS 转换。

根目录 `.browserslistrc` 使用固定发布日期范围，当前为自 2022 年 8 月起发布的浏览器。共享配置从该范围中选取桌面 Chrome，同时提供给 PostCSS 并推导 Vite 的 `build.target` / `build.cssTarget`，不在各包硬编码浏览器版本。固定起始日期不会像“最近两版”策略一样随时间排除旧浏览器。该范围是构建策略，不是所有版本、所有业务流程的完整认证，也不代表支持任意年代的浏览器或其他浏览器内核。

兼容处理包括：

- 通用 CSS：`postcss-preset-env` 按统一目标启用 Stage 2 及以上特性的转换与自动前缀；不自动启用所有需要客户端库的特性。
- `dvh` / `dvw`：构建时生成 `vh` / `vw` 基础值，原声明放入 `@supports`，避免含 `var()` 的声明在计算阶段失效。旧桌面浏览器使用窗口视口尺寸。
- `:has()`：关闭 preset-env 中的同名转换，由末尾的 `css-has-pseudo` 在通用选择器转换后生成替代选择器，旧浏览器按需加载其选择器 API 补丁。`packages/portal/src/has-compat.ts` 同步编码后的选择器和 DOM 属性，支持容器补丁替换样式表、异步 CSS、弹窗及按钮显隐。现代浏览器使用原生规则。
- `@container` / `cqw`：仅在不支持 `container-type` 时加载 `container-query-polyfill`。补丁随门户打包，不请求公共 CDN。
- `color-mix()`：关闭 preset-env 中的同名转换，构建时解析当前项目的主题变量和别名，使用 `@csstools/postcss-color-mix-function` 分别计算浅色、深色回退值，并在旧浏览器中按主题应用。现代浏览器保留原生混色。新增混色若使用无法解析的局部变量，构建会报错，需要补充明确的回退值。

注意事项：

- 发布时更新整个 `packages/portal/dist`，包含 `assets` 和版本化 `unpkg` 子包；单独替换门户 JS 不能兼容旧的子包 CSS。
- CSS 必须保持当前的同源部署约定；容器补丁处理 `<style>` 和同源 `<link>`，不处理 Shadow DOM、CSSOM 插入规则或行内样式里的容器查询。JS / Vue 属性中的 `dvh` 不经过 PostCSS，应自行提供兼容值。
- 当前运行时跟踪项目用到的 DOM 类名、内联样式和常见表单状态。若新增依赖其他 HTML 属性的 `:has()`，需同步扩展 `has-compat.ts` 的 `attributeFilter`；当前未使用的 `:hover` 条件需要额外事件跟踪。
- 这是现有样式和构建目标的兼容措施，不会自动补齐所有新的 JavaScript API 或未来的 CSS 特性。

兼容配置、主题源和别名文件已加入 Nx / 公共库构建指纹，修改后会使旧构建缓存失效。

自动化回归：`pnpm exec vitest run tests/browser-compat.test.ts tests/has-compat.test.ts`。

浏览器回归范围：实际发布包登录页、组件 scoped 样式的浅深色背景，以及独立构建页面的容器 4/2/1 列切换、异步样式加载和 `:has()` 随 DOM 变化更新。新旧浏览器分别验证，现代浏览器应不请求兼容补丁。登录页测试模拟未登录接口响应，不覆盖需要真实登录的完整业务流程。

本次迁移验证通过：`pnpm run type-check:node`、完整 `pnpm run build:prod`（含全部子包类型检查和生产产物检查）、相关 53 项自动化回归，以及上述新旧浏览器样式与生产登录页检查。现代浏览器未请求运行时兼容补丁。

参考：[postcss-preset-env](https://github.com/csstools/postcss-plugins/tree/main/plugin-packs/postcss-preset-env)、[Browserslist](https://github.com/browserslist/browserslist)、[css-has-pseudo](https://github.com/csstools/postcss-plugins/tree/main/plugins/css-has-pseudo)、[container-query-polyfill](https://github.com/GoogleChromeLabs/container-query-polyfill)。
