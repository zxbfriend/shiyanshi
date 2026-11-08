-- 系统管理目标结构参考稿，未执行。仅展示DD01+DD02后的完整CREATE TABLE。
-- 不是现有库升级脚本，禁止用于覆盖/重建生产表；迁移应使用01和04。

CREATE TABLE `sys_venue` (
  `venue_id` bigint NOT NULL COMMENT '场地主键',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '上级主键，逻辑关联本表主键；根为0，无外键',
  `ancestors` varchar(2000) NULL DEFAULT '' COMMENT '祖先ID链，0开头逗号分隔；应用防环且不得截断',
  `venue_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '场地名称',
  `venue_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '场地编码',
  `order_num` int NULL DEFAULT 1 COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `active_venue_name` varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN venue_name ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  `active_venue_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN venue_code ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  PRIMARY KEY (`venue_id`) USING BTREE,
  INDEX `idx_sys_venue_parent`(`parent_id` ASC) USING BTREE,
  INDEX `idx_sys_venue_name`(`parent_id` ASC, `venue_name` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_sys_venue_code`(`parent_id` ASC, `venue_code` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX uk_m01_venue_name(parent_id,active_venue_name),
  UNIQUE INDEX uk_m01_venue_code(active_venue_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_dept` (
  `dept_id` bigint NOT NULL COMMENT '部门主键',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '上级主键，逻辑关联本表主键；根为0，无外键',
  `ancestors` varchar(2000) NULL DEFAULT '' COMMENT '祖先ID链，0开头逗号分隔；应用防环且不得截断',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `dept_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门编码',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `active_dept_name` varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dept_name ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  `active_dept_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dept_code ELSE NULL END) STORED COMMENT '未删除记录唯一校验生成键，删除后NULL',
  PRIMARY KEY (`dept_id`) USING BTREE,
  UNIQUE INDEX uk_m01_dept_name(parent_id,active_dept_name),
  UNIQUE INDEX uk_m01_dept_code(active_dept_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_group` (
  `group_id` bigint NOT NULL COMMENT '实验组主键',
  `group_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实验组名称',
  `group_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实验组编码',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '归属部门主键',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `active_group_name` varchar(20) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN group_name ELSE NULL END) STORED COMMENT '有效实验组唯一键；删除及空编码不占唯一性',
  `active_group_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN NULLIF(group_code,'') ELSE NULL END) STORED COMMENT '有效实验组唯一键；删除及空编码不占唯一性',
  PRIMARY KEY (`group_id`) USING BTREE,
  INDEX `idx_sys_group_dept`(`dept_id` ASC) USING BTREE,
  UNIQUE INDEX uk_m01_group_name(active_group_name),
  UNIQUE INDEX uk_m01_group_code(active_group_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_group_leader` (
  `group_id` bigint NOT NULL COMMENT '实验组主键',
  `user_id` bigint NOT NULL COMMENT '负责人用户主键',
  PRIMARY KEY (`group_id`, `user_id`) USING BTREE,
  INDEX `idx_sys_group_leader_user`(`user_id` ASC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_group_member` (
  `group_id` bigint NOT NULL COMMENT '实验组主键',
  `user_id` bigint NOT NULL COMMENT '成员用户主键',
  PRIMARY KEY (`group_id`, `user_id`) USING BTREE,
  INDEX `idx_sys_group_member_user`(`user_id` ASC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_menu` (
  `menu_id` bigint NOT NULL COMMENT '菜单主键',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `menu_i18n_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '国际化key',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单主键',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏），字典：菜单状态',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用），字典：系统开关',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `api_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '后端接口路径',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_role` (
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(1000) NULL DEFAULT NULL COMMENT '角色描述，最多1000字符',
  `active_role_name` varchar(30) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN role_name ELSE NULL END) STORED COMMENT '有效角色唯一生成键',
  `active_role_key` varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN role_key ELSE NULL END) STORED COMMENT '有效角色唯一生成键',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX uk_m01_role_name(active_role_name),
  UNIQUE INDEX uk_m01_role_key(active_role_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_role_data_scope` (
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `scope_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '数据范围（1全部 2自定 3本部门 4本部门及以下 5本人）',
  PRIMARY KEY (`role_id`, `scope_type`) USING BTREE,
  INDEX `idx_sys_role_data_scope_role`(`role_id` ASC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_role_dept` (
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `dept_id` bigint NOT NULL COMMENT '部门主键',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `menu_id` bigint NOT NULL COMMENT '菜单主键',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_user` (
  `user_id` bigint NOT NULL COMMENT '用户主键',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门主键',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '显示姓名',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知），字典：用户性别',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `password_valid_days` int NULL DEFAULT NULL COMMENT '密码有效期天数',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `notify_email` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否接收邮件通知（0否 1是）',
  `notify_sms` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否接收短信通知（0否 1是）',
  `notify_insite` char(1) NOT NULL DEFAULT '1' COMMENT '站内通知固定1必选；0是历史关闭值不再允许',
  `login_count` int NULL DEFAULT 0 COMMENT '登录次数',
  `is_initial_password` char(1) NOT NULL DEFAULT '1' COMMENT '初始密码标记，sys_auth_initial：0普通、1初始',
  `credential_version` bigint NOT NULL DEFAULT 0 COMMENT '密码版本；每次实际改密递增',
  `active_user_name` varchar(30) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN user_name ELSE NULL END) STORED COMMENT '有效账号唯一生成键；删除行NULL',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX uk_sys_user_active_name(active_user_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL COMMENT '用户主键',
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `assigned_at` datetime(3) NULL DEFAULT NULL COMMENT '角色关联时间，旧记录无依据保留NULL，新增必须写入',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_dict_type` (
  `dict_id` bigint NOT NULL COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `is_editable` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'Y' COMMENT '是否可编辑（Y可编辑 N不可编辑）',
  `active_dict_name` varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dict_name ELSE NULL END) STORED COMMENT '有效字典名称唯一键',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_dict_type_dict_type`(`dict_type` ASC) USING BTREE,
  UNIQUE INDEX uk_m01_dict_name(active_dict_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_dict_data` (
  `dict_code` bigint NOT NULL COMMENT '字典编码',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典键值',
  `parent_code` bigint NULL DEFAULT 0 COMMENT '父字典数据主键，顶级为0',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_level` int NULL DEFAULT 1 COMMENT '字典层级，一级为1，二级为2',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `is_editable` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'Y' COMMENT '是否可编辑（Y可编辑 N不可编辑）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `active_dict_value` varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dict_value ELSE NULL END) STORED COMMENT '当前类型内有效字典项唯一键',
  `active_dict_label` varchar(100) GENERATED ALWAYS AS (CASE WHEN del_flag='0' THEN dict_label ELSE NULL END) STORED COMMENT '有效标签键；唯一范围由dict_label_scope限定',
  `dict_label_scope` bigint GENERATED ALWAYS AS (CASE WHEN dict_type='smp_detect_class' THEN COALESCE(parent_code,0) ELSE 0 END) STORED COMMENT '标签唯一范围：检测字典按父节点，其他字典固定0',
  PRIMARY KEY (`dict_code`) USING BTREE,
  INDEX `idx_sys_dict_data_parent`(`dict_type` ASC, `parent_code` ASC, `dict_sort` ASC) USING BTREE,
  INDEX `idx_sys_dict_data_ancestors`(`dict_type` ASC) USING BTREE,
  UNIQUE INDEX uk_m01_dict_value(dict_type,active_dict_value),
  UNIQUE INDEX uk_m01_dict_label(dict_type,dict_label_scope,active_dict_label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_config` (
  `config_id` bigint NOT NULL COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否），字典：系统是否',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX uk_sys_config_key(config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_logininfor` (
  `info_id` bigint NOT NULL COMMENT '访问主键',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败），字典：系统状态',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime(3) NULL DEFAULT NULL COMMENT '访问时间',
  `user_id` bigint NULL DEFAULT NULL COMMENT '逻辑关联sys_user.user_id；未知账号及旧记录可空',
  `nick_name` varchar(50) NULL DEFAULT NULL COMMENT '当时显示名快照',
  `pc_name` varchar(64) NULL DEFAULT NULL COMMENT 'PC名称，浏览器不能采集时为空',
  `mac_address` varchar(64) NULL DEFAULT NULL COMMENT 'MAC预留，不能采集时为空',
  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '请求ID',
  `session_key` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '会话随机ID，非JWT',
  `event_type` varchar(24) NOT NULL DEFAULT 'LEGACY' COMMENT '固定LEGACY/LOGIN/LOGIN_CHALLENGE/LOGOUT/LOCK/SESSION_REPLACED/PASSWORD_CHANGE/ADMIN_RESET',
  auth_event_sequence BIGINT NULL COMMENT '认证事件锁内序号，历史不回填',
  login_request_dedup VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin GENERATED ALWAYS AS (CASE WHEN event_type='LOGIN' AND user_id IS NOT NULL THEN request_id ELSE NULL END) STORED,
  UNIQUE KEY uk_login_user_sequence (user_id,auth_event_sequence),
  UNIQUE KEY uk_login_user_request (user_id,login_request_dedup),
  KEY idx_login_previous_event (user_id,event_type,status,auth_event_sequence),
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE,
  INDEX idx_login_user_time(user_id,login_time),
  INDEX idx_login_request(request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_oper_log` (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除），字典：操作类型',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0成功 1失败），字典：系统状态',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  `user_id` bigint NULL DEFAULT NULL COMMENT '操作者ID，逻辑关联sys_user.user_id，旧记录未知NULL',
  `nick_name` varchar(50) NULL DEFAULT NULL COMMENT '操作者当时显示名快照',
  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '操作请求ID，关联管理回执及链路',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE,
  INDEX idx_m01_oper_request(request_id),
  INDEX idx_m01_oper_user_time(user_id,oper_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_data_change_log` (
  `id` bigint NOT NULL COMMENT '主键',
  `table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务表名，如 t_order',
  `record_id` bigint NULL COMMENT '数字业务记录主键；与record_key二选一',
  `record_key` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '显式登记的字符串业务主键；与record_id二选一',
  `oper_id` bigint NULL DEFAULT NULL COMMENT '关联 sys_oper_log.oper_id',
  `operation` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型：INSERT/UPDATE/DELETE',
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作描述',
  `old_data` json NULL COMMENT '变更前数据快照',
  `new_data` json NULL COMMENT '变更后数据快照',
  `changed_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人用户名',
  `changed_nick_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人昵称',
  `changed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人 IP',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_table_record`(`table_name` ASC, `record_id` ASC) USING BTREE,
  INDEX `idx_table_record_key`(`table_name` ASC, `record_key` ASC) USING BTREE,
  INDEX `idx_changed_at`(`changed_at` ASC) USING BTREE,
  INDEX `idx_changed_by`(`changed_by` ASC) USING BTREE,
  INDEX idx_m01_change_oper(oper_id),
  CONSTRAINT `ck_m01_change_record_identity` CHECK ((record_id IS NOT NULL AND record_key IS NULL) OR (record_id IS NULL AND record_key IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_user_password_history` (
  `id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户主键，逻辑关联sys_user.user_id，无外键',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加密后的密码',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `credential_version` bigint NULL DEFAULT NULL COMMENT '对应sys_user.credential_version，旧历史未知NULL',
  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '同用户改密幂等请求',
  `change_type` varchar(20) NOT NULL DEFAULT 'LEGACY' COMMENT 'sys_auth_pwd_change：LEGACY旧记录、BASELINE迁移基线、SELF本人、ADMIN_RESET重置、INITIAL_CREATE初始化',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '逻辑关联sys_user.user_id，历史未知允许NULL',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX idx_pwd_history_recent(user_id,create_time,id),
  UNIQUE INDEX uk_pwd_history_version(user_id,credential_version),
  UNIQUE INDEX uk_pwd_history_request(user_id,request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_user_auth_state` (
  `user_id` bigint NOT NULL COMMENT '用户主键，逻辑关联sys_user.user_id，无外键',
  `locked_until` datetime(3) NULL DEFAULT NULL COMMENT '账号锁定截止时刻，NULL未锁',
  `login_failures` json NOT NULL COMMENT '最近15分钟登录失败数组，每项requestId和at毫秒；第7次锁定',
  `change_failures` json NOT NULL COMMENT '最近15分钟旧密码失败数组，每项requestId和at毫秒；第6次锁定',
  `current_session_key` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '当前会话随机ID，非JWT',
  `session_version` bigint NOT NULL DEFAULT 0 COMMENT '当前会话代次',
  `last_login_request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '当前会话登录请求，防止重复计数',
  `version` bigint NOT NULL DEFAULT 0 COMMENT '认证状态并发版本',
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '最近更新时间',
  PRIMARY KEY(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_management_revision` (
  `scope_key` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定SYSTEM；系统管理事务守卫键',
  `revision` bigint NOT NULL DEFAULT 0 COMMENT '管理数据版本，每次成功管理变更递增',
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '最近管理变更时间',
  PRIMARY KEY(scope_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_management_request` (
  `actor_user_id` bigint NOT NULL COMMENT '操作者，逻辑关联sys_user.user_id，无外键',
  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求UUID，同操作者唯一',
  `operation_code` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '本设计接口动作编码ORG/ACL/USR/DIC/CFG及序号',
  `payload_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '规范化请求的HMAC-SHA256十六进制摘要，不记录敏感原文',
  `result_json` json NOT NULL COMMENT '完整W成功结果，不含敏感信息，和业务同事务提交',
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '提交时间',
  `expires_at` datetime(3) NOT NULL COMMENT '回执到期，创建后24小时',
  PRIMARY KEY(actor_user_id,request_id),
  INDEX idx_m01_request_expiry(expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
