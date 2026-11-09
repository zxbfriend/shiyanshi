# VXE 表格基础配置

`sdk-smp-common/src/table.ts` 迁入了 fabsyn-frontend 的 `sdk-ees-basic/src/utils/table.ts` 中的 `tableDefaultConfig`，并使用当前公司版 VXE 的类型约束。新项目从 SMP 公共 SDK 导入，避免引入整个 EES 业务 SDK 的依赖。

```ts
import { computed } from "vue";
import {
  tableDefaultConfig,
  tableFormEditingConfig,
} from "@futurefab/ui-sdk-smp-common";

const options = computed(() => tableDefaultConfig({
  ...tableFormEditingConfig,
  id: "smp-example-results",
  columns: [{ field: "sampleNo", title: "Sample ID" }],
  rowConfig: { keyField: "resultId" },
}));
```

```vue
<vxe-grid v-bind="options" height="100%" :data="rows" />
```

## 基础行为

- `scroll-hover-table`：直接启用 `@futurefab/vxe-table/lib/style.css` 内置的悬浮滚动条。移出时滑块透明，悬浮时显示；无需另写 VXE 滚动条样式。
- `size: null` 使用公司 VXE 的默认大号尺寸，表头为 46px；`rowConfig.height: 46` 统一数据行高度。本系统默认使用大号表格。保留 `border: false`、外围边框、行悬浮、单元格高亮、溢出提示。
- 列宽调整、序号列、复选框列对齐、分组表头、冻结菜单、自定义列存储、多列排序、筛选、导出、虚拟滚动和编辑配置。
- 页面传入的嵌套选项覆盖对应默认值；列定义不会被原地修改。额外 CSS 类与悬浮滚动条类合并。

## SMP 适配

- 默认自动补充序号列；已有 `type: seq` 时不重复添加。设备队列使用真实通道编号，传第二个参数 `false`，保留 `__tableRowIndex`。不需要序号的详情表也传 `false`。
- 开启列存储需要唯一、稳定的 `id`，弹窗内的表格也必须提供。
- 现有页面使用自己的操作栏，因此 VXE 工具栏默认 `enabled: false`。需要时显式开启并配置权限；工具栏图标使用公司 VXE 自带图标，避免依赖 EES 专用字体类。
- 当前业务输入由表单及控制器处理，传入 `tableFormEditingConfig` 禁用 VXE 的删除键编辑、覆盖式编辑和粘贴，保留原有权限与脏数据追踪。
- 页面固定高度要写在 `v-bind` **后面**，覆盖基础配置的 `height: auto`，使滚动发生在表格内部。
- 队列内的 Ant 输入框、选择器和图标按钮尺寸独立于表格尺寸；表头和数据行默认由基础配置统一为 46px。
- Portal 保留亮暗主题变量映射，移除了 `.smp-page .vxe-*` 对字号和表头颜色的额外覆盖。

工作台 4 处、检测记录 3 处、场所管理 1 处均已接入。`tests/table-config.test.ts` 覆盖配置合并、序号、列定义不变性、菜单、筛选和编辑保护。
