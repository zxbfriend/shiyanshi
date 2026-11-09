# DOM 检查卡顿排查

## 已确认并修复的问题

`sdk-smp-static-files` 使用 Vite library 构建。原先普通图片 import 被内联成
Data URL，`sdk-smp-common/src/display.ts` 又将背景 URL 写入 `<html>` 的
`--smp-brand-background` CSS 变量。该变量会被子元素继承。

本地登录页实测只有 94 个 DOM 元素，但根节点的 style 属性达到 1,036,827
字符，其中背景变量占 1,036,781 字符。检查元素时，Elements/Styles 面板需要
处理这段超长属性和继承样式，因此这是一个明确应消除的调试负担。

修复：五张品牌 PNG 的 import 增加 `?no-inline`，SDK 的 Vite 配置增加
`base: "./"`。构建后使用相对模块的图片 URL，兼容门户版本化 `/unpkg/`
路径。仅设置 `assetsInlineLimit: 0` 不足以处理 library 模式，详见
[Vite 构建选项](https://vite.dev/config/build-options#build-assetsinlinelimit)
及[静态资源处理](https://vite.dev/guide/assets#explicit-inline-handling)。

修复后，同一本地页面的根节点 style 降到 150 字符；静态 SDK 的 index.js
从 5,993,059 字节降到约 4.62 MB。五张输出 PNG 与源文件逐字节一致。
小型 SVG Logo 保留内联，因为当前公司脚手架的资源复制白名单不包含 SVG；
直接将其外置会导致生产包缺失 Logo。
这是属性/产物体积的对照，不能替代 DevTools 实际耗时的性能录制。

## data 与 portal 同时启动

这是正常的联调结构：`portal` 是入口，`app-smp-data` 为检测页面提供开发模块。
公司脚手架通过 `ui-dev-url.local` 和健康检查发现子应用开发地址；没有运行的
子应用使用构建产物。调试 data 页面时保留两个服务；仅调试门户时，在依赖已经
构建的前提下可以只运行根目录 `pnpm dev`。

根目录 `pnpm start` 会先执行全量 build-only，再启动门户。启动构建、首次
模块编译可能与浏览器争用资源，但本次没有白天卡顿时的 CPU/内存和 Performance
记录，不能认定双服务就是卡顿原因。卡顿现在已消失，也不能宣称已复现并彻底修复。

## 截图中的消息通道错误

`A listener indicated an asynchronous response by returning true, but the message
channel closed before a response was received` 对应浏览器扩展的异步消息机制，
参见 [Chrome 消息传递文档](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)。

本次业务源码及 ui-platform/ui-framework 的检索没有发现对应 runtime 消息调用，
本地登录页浏览器检查也没有出现该错误。目前高度怀疑浏览器扩展，但截图不足以
确定具体扩展；未验证用户截图中的已登录业务页面。

在报错浏览器中，用未启用扩展的访客窗口对照相同页面；如果错误消失，再逐个
停用普通窗口中的扩展并刷新，定位后更新或停用对应扩展。不要通过覆盖 console
或吞掉全局 unhandledrejection 来隐藏业务错误。`[resource-loader]` 的彩色输出
是加载日志，与红色消息通道错误不同。

共享 SDK 使用预构建文件，修改源码后要重新构建该包并刷新页面；生产发布时要
重新构建门户并完整发布 dist，包括 SDK 同目录下新增的图片文件。
