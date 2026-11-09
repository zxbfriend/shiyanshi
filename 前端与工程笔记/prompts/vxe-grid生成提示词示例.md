# VXE Grid 生成提示词（示例）

用途：在已有页面内迁移 / 生成公司表格配置和插槽。下面整段可直接交给代码生成工具；更换业务时修改“本次输入”，不要机械替换所有 post 字样。

## 可复制提示词

```text
你正在协助 futurefab-ui → futurefab-frontend 的迁移。请直接完成本次表格代码，并检查可用性。

【工作范围】
工作目录为 futurefab-frontend。仅修改新前端的目标页面与必要词条，不修改旧前端、后端、数据库、公共组件默认行为或依赖版本。保留当前工作区已有修改。
这次任务是表格配置及插槽，不重新实现登录、导航、接口客户端、页面查询区和 CRUD 弹窗。

【本次输入：岗位管理示例】
- 旧页面：../futurefab-ui/src/views/system/post/index.vue
- 旧接口：../futurefab-ui/src/api/system/post.js
- 新页面目录：packages/app-smp-settings/src/views/post-management
- 表格配置：grid.ts；装配与插槽：index.vue
- 稳定表格 ID：smp-settings-post
- 行主键：postId（string | number）
- 分页：后端 pageNum/pageSize，列表返回顶层 rows 和 total
- 列：序号、复选框、postCode 岗位编码、postName 岗位名称、postSort 显示顺序、status 状态、createTime 创建时间、操作
- 参考列宽：编码 / 名称 minWidth 180，排序 110，状态 120，创建时间 180，操作 100；优先让名称类列伸缩
- 编辑入口权限：同时具有 system:post:query 与 system:post:edit
- 删除及复选框权限：system:post:remove
- 状态：sys_normal_disable 字典；值保持字符串 "0" / "1"
- 编辑方式：弹窗表单，不在单元格直接改值
- 行操作：编辑、删除；旧页面没有导入、导出或列内筛选入口
- 已有页面提供 rows/loading、pageNum/pageSize、权限状态、statusLabel、编辑和删除处理函数

【先阅读，不猜组件 API】
1. README.md、docs/系统设置纯表格迁移交接.md。
2. docs/VXE表格基础配置.md、docs/公共按钮组件.md。
3. packages/sdk-smp-common/src/table.ts 和 src/index.ts。
4. packages/sdk-smp-common/src/components/icon-button/index.vue、button-tip/index.vue 及 interface.ts。
5. packages/app-smp-settings/src/views/post-management/grid.ts 和 index.vue。
6. 当前安装的 @futurefab/vxe-table 类型定义；仅在用到某项 API 时核对。
如果目标就是现有岗位样板，先核对再增量修改，不重复生成第二个页面。

【必须遵循的表格规范】
1. 使用公司 @futurefab/vxe-table 的 vxe-grid，不使用原版 vxe-table、a-table、el-table 或手写 table。
2. 从 @futurefab/ui-sdk-smp-common 导入 tableDefaultConfig 和 tableFormEditingConfig。
3. 页面专属列配置放 grid.ts，封装配置工厂；在页面 computed 内调用，保证切换语言后标题更新。
4. 为每张表配置唯一稳定 id 和 rowConfig.keyField，不使用数组索引作为业务主键；页面复制后必须改 id。
5. 展开 ...tableFormEditingConfig，防止键盘删除、覆盖编辑、粘贴绕过表单。不要启用 editRender。
6. 默认序号由 tableDefaultConfig 自动补充；样板显式提供一列 type='seq' 和 t('common.label.sequenceNumber')，避免默认键 vxe.no 原样显示。基础配置会识别已有序号，不会重复添加。服务端分页配置 seqConfig.startIndex=(pageNum-1)*pageSize。
7. 有实际理由不需要序号时才使用 tableDefaultConfig(config, false)。复选框 type='checkbox'，checkboxConfig.reserve=false，不跨页保留勾选。
8. 显式指定数值列 align='right'、状态 / 操作 align='center'；长文字使用 minWidth 和溢出提示；操作列固定右侧。
9. 状态、行操作通过具名插槽渲染；slot 名称与 columns[].slots.default 精确匹配。状态取真实字典，未知值保留原值，不伪装成正常。
10. 保留基础配置的默认大号尺寸、46px 行高、悬浮滚动条、列宽调整、列存储、主题。不要复制 tableDefaultConfig 实现或覆盖 .vxe-* 皮肤。
11. 当前页后端分页数据不可擅自开启本地 sortable/filter。业务需要排序 / 过滤时，先核实服务端字段，再完整接入远程请求；不能给用户只排序当前页的假象。
12. 默认 toolbarConfig.enabled=false。页面已有工具栏时不要再生成第二套。需要启用 VXE toolbar 时，逐项显式关闭未授权或没有实现的 import/export/refresh 等功能。
13. 表格高度属性放在 v-bind 后面：<vxe-grid v-bind="options" height="100%" ... />。父容器必须有明确高度和 min-width:0；参考样板响应式高度，不写无父高度的 100%。
14. 在 checkbox-change、checkbox-all 事件中用带类型的 VxeGridInstance.getCheckboxRecords() 获取选择；查询、分页、刷新后清空选择，避免批量删除旧页面数据。
15. row 操作使用公共 EqIconButton：icon、tooltip、disabled、@click。编辑图标 #icon-codesign-edit，删除 #icon-codesign-btn-delete；其他图标先查 packages/sdk-smp-static-files/src/index.ts 中显式导入的包，再查对应 src/iconfont/<包名>/iconfont.json 的名称；同名图标通过 icon-pack 指定包。
16. 工具栏图标可用 EesButtonTip：icon、text、loading、disabled、@onClick（事件与 EqIconButton 不同）。两个组件都不自动鉴权，页面显隐和事件内都需检查 session.has。
17. 模板 a-* 已由门户注册；vxe-grid 已由门户统一 vxePlugin 注册。业务页不能重复 app.use(VXETable)，不能创建自己的 Vue / Pinia / i18n 实例。
18. 文案使用 @futurefab/ui-sdk-language 的 t()，新增词条放 smp-settings/cn.ts 和 en.ts 的页面命名空间。岗位名称 / 编码等业务数据不翻译。
19. 只使用 TypeScript 和 Less，优先复用公共类与主题变量。不要迁入 Element Plus/SCSS 写法。

【输出与验收】
- 输出实际可运行的 grid.ts 和必要 index.vue 插槽 / 绑定代码；保留已有业务逻辑。
- 说明使用了哪些公共组件、插槽、事件和权限；列明所需行数据字段。
- 检查列与插槽对应、主键与 id 唯一、语言切换、loading/空数据、窄屏横向滚动、操作列与图标可见、选择清理。
- 运行 pnpm run check:ui，以及受影响包的类型检查；若 SDK 类型产物变更，先构建依赖。
- 需要看门户结果时重建受影响子应用及依赖后再刷新。区分实际执行的验证与待联调项。
- 不输出伪接口、TODO 按钮、alert('成功') 或硬编码业务行。不新增旧页面不存在的业务功能。
```

## 典型绑定方式

以下是已有标准页的接口关系，完整可运行代码以页面源文件为准：

```ts
const options = computed(() =>
  createPostGridOptions(query.pageNum, query.pageSize, canRemove.value, canEdit.value),
);
```

```vue
<vxe-grid ref="grid" v-bind="options" height="100%"
  :data="rows" :loading="loading"
  @checkbox-change="syncSelection" @checkbox-all="syncSelection">
  <template #status="{ row }">{{ statusLabel(row.status) }}</template>
  <template #actions="{ row }">
    <EqIconButton v-if="canEdit" icon="#icon-codesign-edit"
      :tooltip="t('common.btn.edit')" @click="editor?.show(row.postId)" />
  </template>
</vxe-grid>
```

迁移其他页面时，至少重新核对：业务主键、列字段、分页协议、选择范围、实际权限、字典、行操作、表格 ID。树表、主从联动、合并单元格和行内编辑需另做业务分析，不直接套本模板。
