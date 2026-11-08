-- NEW SYSTEM ONLY. MySQL 8.0.16+. Select an EMPTY dedicated application database. Stop on first error.
-- Do not use mysql --force. DDL is not transactional. No historical migration is required.
SET NAMES utf8mb4;
SET time_zone = '+00:00';
DELIMITER //
CREATE PROCEDURE baseline_assert_empty()
BEGIN
 IF DATABASE() IS NULL OR EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE()) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Select an empty dedicated application database';
 END IF;
END//
DELIMITER ;
CALL baseline_assert_empty();
DROP PROCEDURE baseline_assert_empty;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
CREATE TABLE `sys_group_leader` (
  `group_id` bigint NOT NULL COMMENT '实验组主键',
  `user_id` bigint NOT NULL COMMENT '负责人用户主键',
  PRIMARY KEY (`group_id`, `user_id`) USING BTREE,
  INDEX `idx_sys_group_leader_user`(`user_id` ASC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
CREATE TABLE `sys_group_member` (
  `group_id` bigint NOT NULL COMMENT '实验组主键',
  `user_id` bigint NOT NULL COMMENT '成员用户主键',
  PRIMARY KEY (`group_id`, `user_id`) USING BTREE,
  INDEX `idx_sys_group_member_user`(`user_id` ASC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
CREATE TABLE `sys_role_data_scope` (
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `scope_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '数据范围（1全部 2自定 3本部门 4本部门及以下 5本人）',
  PRIMARY KEY (`role_id`, `scope_type`) USING BTREE,
  INDEX `idx_sys_role_data_scope_role`(`role_id` ASC) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
CREATE TABLE `sys_role_dept` (
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `dept_id` bigint NOT NULL COMMENT '部门主键',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `menu_id` bigint NOT NULL COMMENT '菜单主键',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL COMMENT '用户主键',
  `role_id` bigint NOT NULL COMMENT '角色主键',
  `assigned_at` datetime(3) NULL DEFAULT NULL COMMENT '角色关联时间，旧记录无依据保留NULL，新增必须写入',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
CREATE TABLE `sys_management_revision` (
  `scope_key` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定SYSTEM；系统管理事务守卫键',
  `revision` bigint NOT NULL DEFAULT 0 COMMENT '管理数据版本，每次成功管理变更递增',
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '最近管理变更时间',
  PRIMARY KEY(scope_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Source: docs/详细设计/01-系统管理/07-系统管理目标表结构.sql
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

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `bottle_config` (
`bottle_id` bigint NOT NULL COMMENT '液瓶站位主键',
  `lab_id` bigint NOT NULL COMMENT '实验室ID',
  `row_no` int NOT NULL COMMENT '动态Row编号',
  `unit_sort` int NOT NULL DEFAULT 0 COMMENT 'Row内单元排序',
  `slot_no` int NOT NULL COMMENT '单元内槽位序号',
  `reactor_id` bigint NULL DEFAULT NULL COMMENT '历史罐体或补料单元台式反应器ID',
  `controller_id` bigint NULL DEFAULT NULL COMMENT '取样单元所属控制器连接ID',
  `unit_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'S取样，F补料',
  `unit_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单元编号',
  `pump_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '已知的真实泵通道编号；取样单元可为空',
  `consumable_id` bigint NULL DEFAULT NULL COMMENT 'Bucket耗材ID',
  `liquid_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '液体/补料(字典smp_bottle_liquid_type)',
  `current_capacity` decimal(12, 3) NULL DEFAULT NULL COMMENT '当前实际重量(g)',
  `standard_capacity` decimal(12, 3) NULL DEFAULT NULL COMMENT '最大重量(g)',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '历史状态：0空闲，1使用中；NULL未知',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '0存在，2删除',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `configuration_revision` bigint UNSIGNED NOT NULL DEFAULT 0 COMMENT '液瓶配置版本',
  `observed_revision` bigint UNSIGNED NULL COMMENT '读数对应配置版本',
  `observed_at` datetime(3) NULL COMMENT '设备观测时间UTC',
  `reading_quality` varchar(20) NOT NULL DEFAULT 'UNKNOWN' COMMENT 'GOOD/STALE/BAD/UNKNOWN',
  `standard_source` varchar(64) NULL COMMENT 'PLC标准重量来源标识',
  PRIMARY KEY (`bottle_id`) USING BTREE,
  UNIQUE INDEX `uk_bottle_lab_unit_slot`(`lab_id` ASC, `unit_type` ASC, `unit_code` ASC, `slot_no` ASC) USING BTREE,
  UNIQUE INDEX `uk_bottle_lab_pump`(`lab_id` ASC, `pump_code` ASC) USING BTREE,
  INDEX `idx_bottle_layout`(`lab_id` ASC, `unit_type` ASC, `row_no` ASC, `unit_sort` ASC, `slot_no` ASC) USING BTREE,
  INDEX `idx_bottle_reactor`(`reactor_id` ASC) USING BTREE,
  INDEX `idx_bottle_controller`(`lab_id` ASC, `controller_id` ASC) USING BTREE,
  INDEX `idx_bottle_consumable`(`consumable_id` ASC) USING BTREE,
  INDEX `idx_bottle_status`(`unit_type` ASC, `status` ASC, `del_flag` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '液瓶配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `calibration_object` (
`object_id` bigint NOT NULL COMMENT '主键ID',
  `weight_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '砝码名称（唯一）',
  `net_weight` decimal(10, 2) NOT NULL COMMENT '净重(g)，正数',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`object_id`) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`weight_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '校准对象设置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `consumable_master` (
`consumable_id` bigint NOT NULL COMMENT '主键ID',
  `item_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '耗材编码（唯一）',
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '描述',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类别（来自数据字典）',
  `measure_unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '计量单位',
  `capacity` int NULL DEFAULT NULL COMMENT '容量（0或正整数）',
  `capacity_unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '容量单位',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品牌（来自数据字典）',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`consumable_id`) USING BTREE,
  INDEX `idx_consumable_desc_category`(`description` ASC, `category` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`item_code`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '耗材管理表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `consumption_rule` (
`rule_id` bigint NOT NULL COMMENT '主键ID',
  `lab_id` bigint NULL DEFAULT NULL COMMENT '实验室ID',
  `tab_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '页签类型：feeding_batch-补料批次, column_after-柱后, sample-样本',
  `detect_class` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：SMP检测类型',
  `row_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称（仅展示，不可修改）',
  `dilution_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '稀释类型：diluted-稀释, undiluted-未稀释（仅ViCell）',
  `seq_number` int NOT NULL COMMENT '序号',
  `item_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型：1-耗材, 2-共享',
  `consumable_id` bigint NULL DEFAULT NULL COMMENT '关联耗材ID（item_type=1时）',
  `shared_rule_id` bigint NULL DEFAULT NULL COMMENT '共享耗材规则ID（item_type=2时）',
  `shared_source` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '共享来源标识（item_type=2时）',
  `quantity` int NULL DEFAULT NULL COMMENT '数量（正整数，NULL表示NA）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`rule_id`) USING BTREE,
  INDEX `idx_consumption_lab_tab`(`lab_id` ASC, `tab_type` ASC) USING BTREE,
  INDEX `idx_consumption_lab_seq`(`lab_id` ASC, `tab_type` ASC, `seq_number` ASC) USING BTREE,
  INDEX `idx_consumption_shared_rule`(`shared_rule_id` ASC) USING BTREE,
  INDEX `idx_consumption_tab_detect`(`tab_type` ASC, `detect_class` ASC) USING BTREE,
  INDEX `idx_consumption_lab_tab_detect`(`lab_id` ASC, `tab_type` ASC, `detect_class` ASC, `dilution_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消耗设置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_air_pump_model` (
`model_id` bigint NOT NULL COMMENT '型号主键',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品牌，字典值快照',
  `model_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备型号',
  `max_flow` decimal(12, 4) NULL DEFAULT NULL COMMENT '最大流量',
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_dev_air_pump_model_del`(`brand` ASC, `model_name` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '空气泵型号表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_analyzer_model` (
`analyzer_id` bigint NOT NULL COMMENT '分析仪ID（雪花算法）',
  `device_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备类型，字典值快照，字典：dev_analyzer_type',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '品牌，字典值快照，字典：SMP品牌名称',
  `model_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备型号（品牌+型号唯一，应用层校验）',
  `communication_types` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '通讯方式，支持多选保存为逗号分隔字符串，字典：SMP通讯方式',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `image_paths` json NULL COMMENT '有序图片URL数组；首项兼容icon_path',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`analyzer_id`) USING BTREE,
  INDEX `idx_dev_analyzer_model_type`(`device_type` ASC) USING BTREE,
  INDEX `idx_dev_analyzer_brand_model_del`(`brand` ASC, `model_name` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分析检测仪型号表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_bench_reactor` (
`model_id` bigint NOT NULL COMMENT '型号主键',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品牌，字典：SMP品牌名称',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '类别，字典：SMP容量类别',
  `capacity` decimal(12, 3) NULL DEFAULT NULL COMMENT '容量',
  `capacity_unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '容量单位，字典：SMP容量单位',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_dev_bench_reactor_brand_category_del`(`brand` ASC, `category` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`brand`,`category`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '台式反应器型号表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_culture_container_spec` (
`spec_id` bigint NOT NULL COMMENT '规格主键',
  `container_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '容器类型，字典：SMP容器类型',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规格',
  `volume_ml` decimal(12, 3) NULL DEFAULT NULL COMMENT '容量ml',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`spec_id`) USING BTREE,
  INDEX `idx_dev_container_type_spec_del`(`container_type` ASC, `spec` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`container_type`,`spec`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养容器规格表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_detector_item` (
`item_id` bigint NOT NULL COMMENT '检测项主键',
  `detect_class` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：SMP检测类型',
  `item_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测项ID',
  `item_cn_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测项中文名称',
  `item_en_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项英文名称',
  `short_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项简称',
  `offline_stat_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '离线统计名',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '单位',
  `group_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '分组名',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_dev_detector_item_type`(`detect_class` ASC) USING BTREE,
  INDEX `idx_dev_detector_item_type_code_del`(`detect_class` ASC, `item_code` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`detect_class`,`item_code`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备库-检测项库表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_detector_model` (
`model_id` bigint NOT NULL COMMENT '型号主键',
  `detect_class` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：smp_detect_class',
  `detect_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '检测设备型号（BGA/Vicell/OSMO1/OSMO2/CedexBio/CedexBioHT），字典：smp_detect_class二级字典数据',
  `communication_types` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '通讯方式，支持多选保存为逗号分隔字符串，字典：SMP通讯方式',
  `support_stored` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否支持暂存（0=否,1=是），NULL=未配置',
  `send_mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发送方式（single=单发,column=列发），NULL=未配置',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '品牌，字典值快照，字典：SMP品牌名称',
  `work_send_limit` int NOT NULL COMMENT '工作状态下发送上限，0表示不限制',
  `channel_count` int NOT NULL COMMENT '通道数',
  `column_count` int NOT NULL COMMENT '列数',
  `timeout` int NOT NULL DEFAULT 0 COMMENT '超时时间（秒），必填，正整数',
  `carrier_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '载具形态（1=单管,2=圆盘,3=矩阵/多层），字典：SMP载具形态',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `model_name` varchar(50) NULL COMMENT '展示型号；不得用其替换驱动detect_type',
  `single_send_limit` tinyint UNSIGNED NULL COMMENT '单次发送上限1至99；NULL未知',
  `support_dilution` char(1) NULL COMMENT '0否1是NULL未知；新建由应用默认0',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  `rule_profile` JSON NULL COMMENT '扩展规则schemaVersion、layout补充、scheduling、workCapacity.unit、protection、occlusion、inputProfile；不重复旧标量',
  `rule_revision` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0未核准；发布成功递增，模型当前配置版本',
  CONSTRAINT `ck_m02_rule_object` CHECK (rule_profile IS NULL OR JSON_TYPE(rule_profile)='OBJECT'),
  CONSTRAINT `ck_m02_rule_published` CHECK (rule_revision=0 OR rule_profile IS NOT NULL),
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_dev_detector_model_type`(`detect_class` ASC) USING BTREE,
  INDEX `idx_dev_detector_brand_model_del`(`brand` ASC, `detect_type` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`detect_class`,`model_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备库-检测设备型号表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_floor_scale_model` (
`model_id` bigint NOT NULL COMMENT '型号主键',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '品牌，字典值快照，字典：SMP品牌名称',
  `model_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备型号名称',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '量程',
  `precision_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '精度',
  `calibration_modes` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '校准方式，字典值快照，字典：SMP校准方式',
  `icon_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `image_paths` json NULL COMMENT '有序图片URL数组；首项兼容icon_path',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_dev_floor_scale_name_spec_del`(`model_name` ASC, `spec` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备资源-地秤设备型号' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_integrated_reactor` (
`model_id` bigint NOT NULL COMMENT '型号主键',
  `model_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备型号',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '规格',
  `capacity` decimal(12, 3) NULL DEFAULT NULL COMMENT '容量',
  `pressure_unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '压力单位，字典：SMP压力单位',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `mfc_count` int UNSIGNED NULL COMMENT 'MFC数量；NULL未知',
  `threshold_weight_g` decimal(12,3) NULL COMMENT '达阈重量g；NULL未知',
  `temperature_control` char(1) NULL COMMENT '0否1是NULL未知',
  `weight_control` char(1) NULL COMMENT '0否1是NULL未知',
  `pressure_control` char(1) NULL COMMENT '0否1是NULL未知',
  `pump_count` smallint UNSIGNED NULL COMMENT '固定泵数量；NULL未知',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_dev_integrated_reactor_name_del`(`model_name` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`model_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '集成反应器型号表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `dev_peristaltic_pump_model` (
`model_id` bigint NOT NULL COMMENT '型号主键',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品牌，字典：SMP品牌名称',
  `model_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备型号',
  `max_flow` decimal(12, 4) NULL DEFAULT NULL COMMENT '最大流量',
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_dev_peristaltic_pump_model_del`(`brand` ASC, `model_name` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`brand`,`model_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '蠕动泵型号表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `feed_medium` (
`medium_id` bigint NOT NULL COMMENT '主键ID',
  `medium_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '补料培养基名称（唯一）',
  `sugar_concentration` decimal(10, 2) NOT NULL COMMENT '含糖浓度，允许为0',
  `is_sugar_feed` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否糖补料：0否 1是',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`medium_id`) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`medium_name`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '补料培养基管理表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_air_pump` (
`air_pump_id` bigint NOT NULL COMMENT '空气泵主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `model_id` bigint NULL DEFAULT NULL COMMENT '设备库型号主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备型号',
  `work_speed` decimal(12, 4) NULL DEFAULT NULL COMMENT '工作泵速',
  `duration_s` int NULL DEFAULT NULL COMMENT '时长(s)',
  `speed_factor` decimal(12, 4) NULL DEFAULT NULL COMMENT '泵速系数',
  `ip_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `port` int NULL DEFAULT NULL COMMENT '端口',
  `owner_user_id` bigint NULL DEFAULT NULL COMMENT '负责人用户主键',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1维护/停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`air_pump_id`) USING BTREE,
  INDEX `idx_lab_air_pump_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_air_pump_model`(`model_id` ASC) USING BTREE,
  INDEX `idx_lab_air_pump_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_air_pump_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-空气泵表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_balance` (
`balance_id` bigint NOT NULL COMMENT '天平主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '品牌，字典：SMP品牌名称',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '型号',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '规格',
  `precision_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '精度',
  `range_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '量程',
  `ip_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `port` int NULL DEFAULT NULL COMMENT '端口',
  `owner_user_id` bigint NULL DEFAULT NULL COMMENT '负责人用户主键',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1维护/停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `model_id` bigint NULL COMMENT '称重型号dev_floor_scale_model.model_id',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`balance_id`) USING BTREE,
  INDEX `idx_lab_balance_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_balance_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_balance_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-天平表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_bench_reactor` (
`reactor_id` bigint NOT NULL COMMENT '台式反应器主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `venue_id` bigint NULL DEFAULT NULL COMMENT '场地主键',
  `controller_id` bigint NULL COMMENT '独立控制器connection_id；一个控制器可关联多个罐体',
  `model_id` bigint NULL DEFAULT NULL COMMENT '设备库型号主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '资产编号',
  `reactor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '反应器名称',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '品牌，字典：SMP品牌名称',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '型号',
  `vessel_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '罐体编号',
  `controller_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '历史兼容控制器编号；现由独立控制器表维护',
  `volume_ml` decimal(12, 3) NULL DEFAULT NULL COMMENT '工作体积ml',
  `ip_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `port` int NULL DEFAULT NULL COMMENT '端口',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `capacity_unit` varchar(20) NULL COMMENT 'volume_ml实际最大容量单位；NULL待核验',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`reactor_id`) USING BTREE,
  INDEX `idx_bench_reactor_controller` (`controller_id`),
  INDEX `idx_lab_bench_reactor_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_bench_reactor_venue`(`venue_id` ASC) USING BTREE,
  INDEX `idx_lab_bench_reactor_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_bench_reactor_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_vessel_no` (`lab_id`,`vessel_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-台式反应器表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/RM-01-统一反应器型号表结构.sql
CREATE TABLE `lab_bench_reactor_controller` (
`connection_id` bigint NOT NULL COMMENT '泵连接主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `reactor_id` bigint NULL DEFAULT NULL COMMENT '历史迁移关联；新关系使用lab_bench_reactor.controller_id',
  `controller_no` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '控制器编号',
  `feed_unit_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前实验室控制器对应的补料单元编码；NULL未配置',
  `sampling_unit_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前实验室控制器对应的取样单元编码；内置唯一取样泵；NULL未配置',
  `balance_id` bigint NULL DEFAULT NULL COMMENT '称重设备主键',
  `connection_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '连接名称',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `mfc_count` int UNSIGNED NULL COMMENT 'MFC数量；NULL未知',
  `threshold_weight_g` decimal(12,3) NULL COMMENT '达阈重量g；NULL未知',
  `temperature_control` char(1) NULL COMMENT '0否1是NULL未知',
  `weight_control` char(1) NULL COMMENT '0否1是NULL未知',
  `pressure_control` char(1) NULL COMMENT '0否1是NULL未知',
  `balance_kind` varchar(32) NULL COMMENT 'FLOOR_SCALE或BALANCE；历史需核验',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  `model_id` bigint NULL COMMENT '统一型号ID；仅允许有效BENCH_CONTROLLER，由应用校验',
  KEY idx_bench_controller_model (model_id),
  `model_dict_code` bigint NULL DEFAULT NULL COMMENT '核准控制器型号dict_code；NULL旧未知，无默认型号',
  `model_verification_evidence` json NULL COMMENT '型号核准来源文档、摘要、章节、可信核准人及时刻；只由M02-227写入',
  PRIMARY KEY (`connection_id`) USING BTREE,
  INDEX `idx_lab_pump_connection_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_pump_connection_reactor`(`reactor_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_controller` (`lab_id`,`controller_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_feed_unit` (`lab_id`,`feed_unit_code`,`m02_active`),
  UNIQUE INDEX `uk_m02_sampling_unit` (`lab_id`,`sampling_unit_code`,`m02_active`),
  CONSTRAINT `ck_m02_feed_unit_nonblank` CHECK (`feed_unit_code` IS NULL OR CHAR_LENGTH(TRIM(`feed_unit_code`)) > 0),
  CONSTRAINT `ck_m02_sampling_unit_nonblank` CHECK (`sampling_unit_code` IS NULL OR CHAR_LENGTH(TRIM(`sampling_unit_code`)) > 0)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-台式反应器-控制器通道配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/RM-01-统一反应器型号表结构.sql
CREATE TABLE `lab_bench_reactor_controller_channel` (
`channel_id` bigint NOT NULL COMMENT '通道主键',
  `connection_id` bigint NOT NULL COMMENT '泵连接主键',
  `model_channel_id` bigint NULL COMMENT '对应统一型号普通泵通道ID；NULL未转换或非型号普通泵',
  UNIQUE KEY uk_bench_model_channel (connection_id, model_channel_id),
  CONSTRAINT ck_bench_model_channel_positive CHECK (model_channel_id IS NULL OR model_channel_id > 0),
  `channel_no` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通道号',
  `pump_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '泵类型',
  `pump_id` bigint NULL DEFAULT NULL COMMENT '关联泵主键',
  `pump_usage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用途',
  `material_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '补料液体或物料名称，字典：SMP补料液体种类',
  `feed_container` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '补料容器，字典：SMP补料容器类型',
  `default_speed` decimal(12, 4) NULL DEFAULT NULL COMMENT '默认速度',
  `max_speed` decimal(12, 4) NULL DEFAULT NULL COMMENT '最高速度',
  `speed_strategy` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '泵速策略',
  PRIMARY KEY (`channel_id`) USING BTREE,
  UNIQUE INDEX `uk_lab_pump_channel_no`(`connection_id` ASC, `channel_no` ASC) USING BTREE,
  INDEX `idx_lab_pump_channel_connection`(`connection_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-台式反应器-控制器表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_communication` (
`comm_id` bigint NOT NULL COMMENT '通讯配置主键',
  `route` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模块路由（如 /labs/balance）',
  `device_id` bigint NOT NULL COMMENT '设备主键（对应各模块表的主键）',
  `communication_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通讯方式（HTTP/命名管道/网口/文件/串口），字典：smp_communication_type',
  `interface_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '接口地址（HTTP模式必填）',
  `interface_account` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '接口账号',
  `interface_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '接口密码（加密存储）',
  `device_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备编码',
  `device_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备密钥（加密存储）',
  `subsystem_device_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子系统设备编号（网口/文件模式必填）',
  `subsystem_mac` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子系统MAC（自动获取，暂无数据源，置灰）',
  `subsystem_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子系统IP（网口/文件模式必填）',
  `device_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备IP（网口模式必填）',
  `port_no` int NULL DEFAULT NULL COMMENT '端口号（网口模式必填）',
  `excel_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'EXCEL路径（文件模式必填）',
  `device_model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备型号',
  `serial_port` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '串口号，字典：smp_serial_port',
  `baud_rate` int NULL DEFAULT NULL COMMENT '波特率，字典：smp_baud_rate',
  `parity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '校验位，字典：smp_parity',
  `data_bits` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '数据位，字典：smp_data_bits',
  `stop_bits` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '停止位，字典：smp_stop_bits',
  `flow_control` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流控类型，字典：smp_flow_control',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `pipe_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '命名管道名称（命名管道模式必填，如 BGAService/OsmoSixPipe/CedexOrderPipe/VicellPipe）',
  `device_kind` varchar(32) NULL COMMENT '服务端设备种类白名单',
  `desired_revision` bigint UNSIGNED NOT NULL DEFAULT 0 COMMENT '期望配置版本；0未纳管',
  `applied_revision` bigint UNSIGNED NULL COMMENT '适配器确认的配置版本',
  `apply_state` varchar(20) NOT NULL DEFAULT 'NOT_CONFIGURED' COMMENT 'NOT_CONFIGURED/PENDING/APPLIED/FAILED/UNKNOWN',
  `apply_error_code` varchar(64) NULL COMMENT '去敏错误码',
  `applied_at` datetime(3) NULL COMMENT '配置加载回报时间UTC',
  `verification_revision` bigint UNSIGNED NULL COMMENT '通讯探活所用配置版本，不等于desired_revision时视为未核验',
  `verification_status` varchar(16) NULL COMMENT 'ONLINE/OFFLINE/UNKNOWN；不替代配置加载状态',
  `verification_reason` varchar(64) NULL COMMENT '固定脱敏原因码；不保存外部异常文本',
  `verification_checked_at` datetime(3) NULL COMMENT '通讯探活结束时间UTC',
  CONSTRAINT `ck_m02_comm_verification` CHECK ((verification_revision IS NULL AND verification_status IS NULL AND verification_reason IS NULL AND verification_checked_at IS NULL) OR (verification_revision IS NOT NULL AND verification_revision>0 AND verification_revision<=desired_revision AND verification_status IS NOT NULL AND BINARY verification_status IN ('ONLINE','OFFLINE','UNKNOWN') AND verification_reason IS NOT NULL AND verification_checked_at IS NOT NULL)),
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`comm_id`) USING BTREE,
  INDEX `idx_route`(`route` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`device_kind`,`device_id`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备通讯方式配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_culture_container` (
`container_id` bigint NOT NULL COMMENT '培养容器主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `spec_id` bigint NULL DEFAULT NULL COMMENT '设备库规格主键',
  `venue_id` bigint NULL DEFAULT NULL COMMENT '场地主键',
  `container_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '容器编号',
  `container_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '容器类型，字典：SMP容器类型',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '规格',
  `container_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '容器名称，按类型和规格拼接',
  `volume_ml` decimal(12, 3) NULL DEFAULT NULL COMMENT '容量ml',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`container_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`container_id`) USING BTREE,
  INDEX `idx_lab_culture_container_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_culture_container_name_del`(`lab_id` ASC, `container_name` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_culture_container_container_no_del`(`container_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_container` (`lab_id`,`container_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_name` (`lab_id`,`container_name`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养容器表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_detection_rule` (
`rule_id` bigint NOT NULL COMMENT '主键ID',
  `lab_id` bigint NOT NULL COMMENT '关联实验室ID（中试/小试下游）',
  `density_operator` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密度分析仪-差值运算符',
  `density_value` decimal(10, 2) NULL DEFAULT NULL COMMENT '密度分析仪-差值阈值',
  `photometer_time_operator` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '光度计-时间运算符',
  `photometer_time_value` int NULL DEFAULT NULL COMMENT '光度计-时间阈值',
  `photometer_rds_operator` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '光度计-RDS运算符',
  `photometer_rds_value` int NULL DEFAULT NULL COMMENT '光度计-RDS阈值',
  `photometer_blank_op` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '光度计-空白浓度运算符',
  `photometer_blank_val` decimal(10, 2) NULL DEFAULT NULL COMMENT '光度计-空白浓度阈值',
  `solovp_rds_operator` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SoloVP-RDS运算符',
  `solovp_rds_value` int NULL DEFAULT NULL COMMENT 'SoloVP-RDS阈值',
  `solovp_r2_operator` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SoloVP-R²运算符',
  `solovp_r2_value` decimal(10, 3) NULL DEFAULT NULL COMMENT 'SoloVP-R²阈值',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`rule_id`) USING BTREE,
  INDEX `idx_detection_rule_lab`(`lab_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`lab_id`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测规则表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_detector` (
`detector_id` bigint NOT NULL COMMENT '检测设备主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `venue_id` bigint NULL DEFAULT NULL COMMENT '场地主键',
  `model_id` bigint NULL DEFAULT NULL COMMENT '设备库型号主键',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号',
  `device_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备名称',
  `detect_class` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：smp_detect_class',
  `detect_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备型号（BGA/Vicell/OSMO1/OSMO2/CedexBio/CedexBioHT），字典：smp_detect_class二级字典数据',
  `owner_user_id` bigint NULL DEFAULT NULL COMMENT '负责人用户主键',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  `queue_revision` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '设备队列/位置事实版本，改变可操作性时同事务递增',
  `applied_rule_revision` BIGINT UNSIGNED NULL COMMENT '当前实例实际接入运行的型号规则修订；与所属model_id组成身份',
  `applied_rule_snapshot` JSON NULL COMMENT '已核准且已接入的完整规则快照，包含modelId/修订及旧标量固定值',
  `position_evidence` JSON NULL COMMENT '初始/当前位置证据、采集时间、事件身份与源；NULL不是初始态',
  CONSTRAINT `ck_m02_rule_applied_pair` CHECK ((applied_rule_revision IS NULL AND applied_rule_snapshot IS NULL) OR (applied_rule_revision IS NOT NULL AND applied_rule_revision>0 AND applied_rule_snapshot IS NOT NULL)),
  CONSTRAINT `ck_m02_rule_applied_object` CHECK (applied_rule_snapshot IS NULL OR JSON_TYPE(applied_rule_snapshot)='OBJECT'),
  CONSTRAINT `ck_m02_position_object` CHECK (position_evidence IS NULL OR JSON_TYPE(position_evidence)='OBJECT'),
  PRIMARY KEY (`detector_id`) USING BTREE,
  INDEX `idx_lab_detector_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_detector_venue`(`venue_id` ASC) USING BTREE,
  INDEX `idx_lab_detector_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_detector_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_detector_type`(`detect_class` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-检测设备表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_detector_item_config` (
`detector_id` bigint NOT NULL COMMENT '检测设备主键',
  `item_id` bigint NOT NULL COMMENT '检测项主键',
  `enabled` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否启用（0启用 1停用）',
  PRIMARY KEY (`detector_id`, `item_id`) USING BTREE,
  INDEX `idx_lab_detector_item_item`(`item_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-检测设备-检测项启用配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_downstream_device` (
`device_id` bigint NOT NULL COMMENT '下游设备ID（雪花算法）',
  `lab_id` bigint NOT NULL COMMENT '实验室ID',
  `venue_id` bigint NULL DEFAULT NULL COMMENT '场地ID（选填）',
  `device_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备类型（非字典）：floor_scale=称重设备；其余为 dev_analyzer_model.device_type（dev_analyzer_type 字典值，如 density_analyzer）',
  `model_id` bigint NULL DEFAULT NULL COMMENT '设备库型号ID（型号快照来源）',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资产编号（全局唯一）',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号（实验室内唯一）',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '品牌（型号快照）',
  `device_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '型号（型号快照）',
  `owner_user_id` bigint NULL DEFAULT NULL COMMENT '负责人用户ID',
  `is_tablet_direct` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1' COMMENT '是否平板直采（0否 1是）',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '量程（称重设备型号快照）',
  `precision_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '精度（称重设备型号快照）',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述（其余设备型号快照）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '是否启用（0启用 1禁用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`device_id`) USING BTREE,
  INDEX `idx_lab_downstream_device_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_downstream_device_venue`(`venue_id` ASC) USING BTREE,
  INDEX `idx_lab_downstream_device_type`(`device_type` ASC) USING BTREE,
  INDEX `idx_lab_downstream_device_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_downstream_device_asset_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-下游设备表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_floor_scale` (
`scale_id` bigint NOT NULL COMMENT '称重设备主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `venue_id` bigint NULL DEFAULT NULL COMMENT '场地主键',
  `model_id` bigint NULL DEFAULT NULL COMMENT '称重设备型号主键',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌，字典：SMP品牌名称',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '型号',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '规格',
  `precision_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '精度',
  `alarm_low_limit` decimal(18, 4) NULL DEFAULT NULL COMMENT '报警下限值',
  `alarm_high_limit` decimal(18, 4) NULL DEFAULT NULL COMMENT '报警上限值',
  `is_feed_scale` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否补料（0否 1是）',
  `ip_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `port` int NULL DEFAULT NULL COMMENT '端口',
  `owner_user_id` bigint NULL DEFAULT NULL COMMENT '负责人用户主键',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1维护/停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`scale_id`) USING BTREE,
  INDEX `idx_lab_floor_scale_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_floor_scale_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_floor_scale_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-地秤表管理' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_integrated_reactor` (
`integrated_id` bigint NOT NULL COMMENT '集成反应器主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `venue_id` bigint NULL DEFAULT NULL COMMENT '场地主键',
  `model_id` bigint NOT NULL COMMENT '设备库型号主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资产编号',
  `reactor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反应器名称',
  `volume_ml` decimal(12, 3) NULL DEFAULT NULL COMMENT '工作体积ml',
  `floor_scale_id` bigint NOT NULL COMMENT '反应器地秤主键',
  `floor_scale_low_limit` decimal(18, 4) NOT NULL COMMENT '反应器地秤报警下限',
  `floor_scale_high_limit` decimal(18, 4) NOT NULL COMMENT '反应器地秤报警上限',
  `feed_scale_id` bigint NOT NULL COMMENT '补料地秤主键',
  `feed_range` decimal(18, 4) NULL DEFAULT NULL COMMENT '补料量程',
  `feed_strategy` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '补料策略',
  `relay_id` bigint NULL DEFAULT NULL COMMENT '继电器主键',
  `alarm_id` bigint NULL DEFAULT NULL COMMENT '声光报警器主键',
  `need_external_pump` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '是否需要外置泵（0否 1是）',
  `opc_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'OPC IP',
  `opc_port` int NULL DEFAULT NULL COMMENT 'OPC端口',
  `owner_user_id` bigint NOT NULL COMMENT '负责人用户主键',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1维护/停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `active_device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci GENERATED ALWAYS AS ((case when (`del_flag` = _utf8mb4'0') then `device_no` else NULL end)) STORED NULL COMMENT '有效设备编号唯一键；删除后NULL',
  `active_reactor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci GENERATED ALWAYS AS ((case when (`del_flag` = _utf8mb4'0') then `reactor_name` else NULL end)) STORED NULL COMMENT '有效反应器名称唯一键；删除后NULL',
  `air_pump_id` bigint NULL COMMENT '空气泵lab_air_pump.air_pump_id',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`integrated_id`) USING BTREE,
  UNIQUE INDEX `uk_lab_integrated_reactor_active_device_no`(`active_device_no` ASC) USING BTREE,
  UNIQUE INDEX `uk_lab_integrated_reactor_active_name`(`lab_id` ASC, `active_reactor_name` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_model`(`model_id` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_venue`(`venue_id` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_floor_scale`(`floor_scale_id` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_feed_scale`(`feed_scale_id` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_relay`(`relay_id` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_alarm`(`alarm_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-集成反应器表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_integrated_reactor_pump` (
`integrated_id` bigint NOT NULL COMMENT '集成反应器主键',
  `pump_id` bigint NOT NULL COMMENT '蠕动泵主键',
  `pump_no` smallint UNSIGNED NULL DEFAULT NULL COMMENT '反应器型号泵通道号；NULL表示历史关联未确认',
  `pump_usage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '泵用途',
  `range_value` decimal(18, 4) NULL DEFAULT NULL COMMENT '量程',
  `strategy` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '策略',
  PRIMARY KEY (`integrated_id`, `pump_id`) USING BTREE,
  UNIQUE INDEX `uk_lab_integrated_reactor_pump_no` (`integrated_id` ASC, `pump_no` ASC) USING BTREE,
  INDEX `idx_lab_integrated_reactor_pump_pump`(`pump_id` ASC) USING BTREE,
  CONSTRAINT `ck_lab_integrated_reactor_pump_no` CHECK (`pump_no` IS NULL OR `pump_no` > 0)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-集成反应器-外置泵关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_integrated_reactor_pump_config` (
`integrated_id` bigint NOT NULL COMMENT '集成反应器主键',
  `pump_no` smallint UNSIGNED NOT NULL COMMENT '泵通道号，从1连续编号',
  `range_value` decimal(18, 2) NOT NULL COMMENT '量程',
  `strategy` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '策略',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`integrated_id`, `pump_no`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-集成反应器-内置泵通道配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_lab` (
`lab_id` bigint NOT NULL COMMENT '实验室主键',
  `venue_id` bigint NULL DEFAULT NULL COMMENT '所属场地主键',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '所属部门主键',
  `lab_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实验室名称',
  `lab_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实验室编码',
  `lab_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实验室类型（字典smp_lab_type）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '中转服务IP',
  `port` int NULL DEFAULT NULL COMMENT '中转服务端口',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '详细位置',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`lab_code`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`lab_id`) USING BTREE,
  INDEX `idx_lab_lab_venue`(`venue_id` ASC) USING BTREE,
  INDEX `idx_lab_lab_dept`(`dept_id` ASC) USING BTREE,
  INDEX `idx_lab_lab_code_del`(`lab_code` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_lab_lab_code_del`(`lab_code` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`lab_name`,`m02_active`),
  UNIQUE INDEX `uk_m02_code` (`lab_code`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_lab_leader` (
`lab_id` bigint NOT NULL COMMENT '实验室主键',
  `user_id` bigint NOT NULL COMMENT '负责人用户主键',
  PRIMARY KEY (`lab_id`, `user_id`) USING BTREE,
  INDEX `idx_lab_lab_leader_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-负责人关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_peristaltic_pump` (
`pump_id` bigint NOT NULL COMMENT '蠕动泵主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `model_id` bigint NULL DEFAULT NULL COMMENT '设备库型号主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备型号',
  `spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '规格',
  `pump_speed` decimal(12, 4) NULL DEFAULT NULL COMMENT '泵速',
  `timeout_s` int NULL DEFAULT NULL COMMENT '超时时间(s)',
  `speed_factor` decimal(12, 4) NULL DEFAULT NULL COMMENT '泵速系数',
  `speed_strategy` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '泵速策略',
  `ip_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `port` int NULL DEFAULT NULL COMMENT '端口',
  `owner_user_id` bigint NULL DEFAULT NULL COMMENT '负责人用户主键',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1维护/停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`pump_id`) USING BTREE,
  INDEX `idx_lab_peristaltic_pump_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_peristaltic_pump_model`(`model_id` ASC) USING BTREE,
  INDEX `idx_lab_peristaltic_pump_no_del`(`lab_id` ASC, `device_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_lab_peristaltic_pump_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-蠕动泵表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_printer` (
`printer_id` bigint NOT NULL COMMENT '打印机主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `subsystem_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '子系统IP',
  `subsystem_port` int NULL DEFAULT NULL COMMENT '子系统端口',
  `print_limit` int NULL DEFAULT NULL COMMENT '打印数量限制',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`printer_id`) USING BTREE,
  INDEX `idx_lab_printer_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_printer_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-打印机表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_printer_layout_setting` (
`layout_id` bigint NOT NULL COMMENT '排版设置主键',
  `printer_id` bigint NOT NULL COMMENT '打印机主键',
  `row_no` int NOT NULL COMMENT '行号（1-4）',
  `width` decimal(10, 2) NOT NULL COMMENT '宽',
  `height` decimal(10, 2) NOT NULL COMMENT '高',
  `font_size` decimal(10, 2) NOT NULL COMMENT '字体大小',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`layout_id`) USING BTREE,
  UNIQUE INDEX `uk_lab_printer_layout_row`(`printer_id` ASC, `row_no` ASC) USING BTREE,
  INDEX `idx_lab_printer_layout_printer`(`printer_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-打印机-排版设置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_relay` (
`relay_id` bigint NOT NULL COMMENT '继电器主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `ip_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `port` int NULL DEFAULT NULL COMMENT '端口',
  `relay_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '开启/关闭状态（0关闭 1开启）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`relay_id`) USING BTREE,
  INDEX `idx_lab_relay_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_relay_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-继电器表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_sound_alarm` (
`alarm_id` bigint NOT NULL COMMENT '声光报警器主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `device_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备编号',
  `asset_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '资产编号',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '描述',
  `ip_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `port` int NULL DEFAULT NULL COMMENT '端口',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用），字典：系统开关',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_asset_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (NULLIF(LOWER(TRIM(`asset_no`)), '')) STORED COMMENT '资产号归一化；跨表仍须SYSTEM守卫',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`alarm_id`) USING BTREE,
  INDEX `idx_lab_sound_alarm_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_lab_sound_alarm_asset_no_del`(`asset_no` ASC, `del_flag` ASC) USING BTREE,
  UNIQUE INDEX `uk_m02_device` (`lab_id`,`device_no`,`m02_active`),
  UNIQUE INDEX `uk_m02_asset` (`m02_asset_key`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-声光报警器表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `liquid_bag` (
`bag_id` bigint NOT NULL COMMENT '主键ID',
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '描述（唯一）',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '型号（来自数据字典）',
  `capacity` int NOT NULL COMMENT '容量(g)，正整数',
  `tare_weight` int NOT NULL COMMENT '皮重(g)，0或正整数',
  `residual_amount` int NOT NULL COMMENT '残余量(g)，0或正整数',
  `lower_limit_vol` int NOT NULL COMMENT '下限体积(g)，0或正整数',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标路径（<1M）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `m02_active` tinyint GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN 1 ELSE NULL END) STORED COMMENT '仅有效行参与唯一约束',
  PRIMARY KEY (`bag_id`) USING BTREE,
  UNIQUE INDEX `uk_m02_business` (`description`,`m02_active`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '液袋管理表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `sys_user_lab` (
`user_id` bigint NOT NULL COMMENT '用户主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `auth_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '授权类型（0可见 1可操作 2管理）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`user_id`, `lab_id`) USING BTREE,
  INDEX `idx_sys_user_lab_lab`(`lab_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户实验室授权表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_engineering_profile` (
  `profile_id` bigint NOT NULL COMMENT '主键，应用生成',
  `scope_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MODEL或INSTANCE及稳定身份规范摘要',
  `scope_kind` varchar(16) NOT NULL COMMENT 'MODEL或INSTANCE',
  `model_kind` varchar(40) NULL COMMENT 'M04 ModelRef类别，MODEL必填',
  `model_id` bigint NULL COMMENT '真实型号ID或控制器字典dict_code',
  `device_kind` varchar(40) NULL COMMENT 'M02 DeviceRef类型，INSTANCE必填',
  `device_id` bigint NULL COMMENT '实例稳定ID',
  `current_version_id` bigint NULL COMMENT '现行工程版本，未核准可空',
  `status` varchar(16) NOT NULL COMMENT 'DRAFT或VERIFIED或REVOKED',
  `object_version` bigint NOT NULL COMMENT '并发版本，从1开始',
  `updated_by_user_id` bigint NOT NULL COMMENT '实际技术维护人',
  `updated_at` datetime(3) NOT NULL COMMENT 'UTC修改时间',
  PRIMARY KEY (`profile_id`),
  UNIQUE KEY `uk_close_engineering_scope` (`scope_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='工程能力配置身份';

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql
CREATE TABLE `lab_engineering_profile_version` (
  `version_id` bigint NOT NULL COMMENT '主键，应用生成',
  `profile_id` bigint NOT NULL COMMENT '所属工程身份',
  `version_no` bigint NOT NULL COMMENT '同身份版本从1递增',
  `previous_version_id` bigint NULL COMMENT '前版，首版空',
  `schema_version` int NOT NULL COMMENT '工程模式1',
  `profile_json` json NOT NULL COMMENT '闭合EngineeringProfile完整对象',
  `canonical_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '规范化内容SHA256',
  `evidence_json` json NOT NULL COMMENT '供应商资料、核准范围及文件摘要',
  `recorded_by_user_id` bigint NOT NULL COMMENT '记录人',
  `recorded_at` datetime(3) NOT NULL COMMENT '记录UTC时间',
  `verified_by_user_id` bigint NULL COMMENT '核准执行人；未核准空',
  `verified_at` datetime(3) NULL COMMENT '核准UTC时间',
  `request_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作者、动作、requestId摘要',
  `request_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求摘要',
  PRIMARY KEY (`version_id`),
  UNIQUE KEY `uk_close_engineering_version` (`profile_id`,`version_no`),
  UNIQUE KEY `uk_close_engineering_request` (`request_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变工程参数与核准版本';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_project` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `project_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',

  `project_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目编号',

  `dept_id` bigint NULL DEFAULT NULL COMMENT '所属部门主键',

  `project_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0进行中 1已完成 2已暂停），字典：SMP项目状态',

  `start_date` date NULL DEFAULT NULL COMMENT '开始日期',

  `end_date` date NULL DEFAULT NULL COMMENT '结束日期',

  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',

  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',

  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',

  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',

  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',

  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',

  `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',

  `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',

  `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',

  `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',

  `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',

  `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY',

  `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN TRIM(`project_code`) ELSE NULL END) STORED COMMENT '逻辑删除释放编号，历史记录按内部主键保留',

  PRIMARY KEY (`project_id`) USING BTREE,

  INDEX `idx_res_project_dept`(`dept_id` ASC) USING BTREE,

  INDEX `idx_res_project_status`(`project_status` ASC) USING BTREE,

  CONSTRAINT `ck_m03_project_version` CHECK (`object_version` >= 1),

  CONSTRAINT `ck_m03_project_facts` CHECK (`facts_status` IN ('READY','REVIEW')),

  CONSTRAINT `ck_m03_project_identity` CHECK (`project_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`project_code`)) > 0),

  INDEX `idx_m03_project_created` (`del_flag`,`create_time`,`project_id`),

  UNIQUE INDEX `uk_m03_project_code` (`m03_live_code`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_project_leader` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `user_id` bigint NOT NULL COMMENT '负责人用户主键',

  PRIMARY KEY (`project_id`, `user_id`) USING BTREE,

  INDEX `idx_res_project_leader_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目负责人关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_project_lab` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `lab_id` bigint NOT NULL COMMENT '实验室主键',

  PRIMARY KEY (`project_id`, `lab_id`) USING BTREE,

  INDEX `idx_res_project_lab_lab`(`lab_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目参与实验室关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_project_tag` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `dict_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型（如smp_project_tag）',

  `tag_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典值，字典：SMP项目标签',

  `tag_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签快照',

  PRIMARY KEY (`project_id`, `dict_code`, `tag_value`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目标签关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_project_member` (
`project_id` bigint NOT NULL COMMENT '项目主键',

  `user_id` bigint NOT NULL COMMENT '用户主键',

  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'member' COMMENT '权限类型（admin/member/view/share）',

  `expire_date` date NULL DEFAULT NULL COMMENT '权限截止日期，空为永久',

  `source_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'direct' COMMENT '来源（direct/group/share）',

  `joined_time` datetime NULL DEFAULT NULL COMMENT '加入时间',

  `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',

  `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',

  `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',

  `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',

  `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',

  `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',

  `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',

  PRIMARY KEY (`project_id`, `user_id`, `grant_type`) USING BTREE,

  INDEX `idx_res_project_member_user`(`user_id` ASC) USING BTREE,

  INDEX `idx_res_project_member_expire`(`expire_date` ASC) USING BTREE,

  CONSTRAINT `ck_m03_project_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),

  CONSTRAINT `ck_m03_project_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),

  INDEX `idx_m03_project_grant_user` (`user_id`,`grant_type`,`expire_date`,`project_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目成员权限表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_batch` (
`batch_id` bigint NOT NULL COMMENT '批次主键',

  `project_id` bigint NOT NULL COMMENT '项目主键',

  `lab_id` bigint NOT NULL COMMENT '实验室主键',

  `batch_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '批次名称',

  `batch_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '批次编号',

  `alias` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '别名',

  `batch_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0进行中 1已完成 2已暂停），字典：SMP批次状态',

  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',

  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',

  `titer` decimal(10, 4) NULL DEFAULT NULL COMMENT '结束时填写的Titer',

  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',

  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',

  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',

  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',

  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',

  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',

  `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',

  `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',

  `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',

  `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',

  `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',

  `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY',

  `feeding_interval_hours` tinyint NULL COMMENT '补料间隔要求小时：8表示±8h，12表示±12h；未知不补默认值',
  `sampling_interval_hours` tinyint NULL COMMENT '取测间隔要求小时：8或12；仅配置，不启动告警计时',
  `upstream_batch_id` bigint NULL COMMENT '中试下游引用同项目中试上游批次ID；稳定关联不以编号代替',
  `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN TRIM(`batch_code`) ELSE NULL END) STORED COMMENT '未删除批次编号在项目内唯一',
  CONSTRAINT `ck_m03_batch_intervals` CHECK ((feeding_interval_hours IS NULL OR feeding_interval_hours IN (8,12)) AND (sampling_interval_hours IS NULL OR sampling_interval_hours IN (8,12))),
  CONSTRAINT `ck_m03_batch_upstream` CHECK (upstream_batch_id IS NULL OR (upstream_batch_id > 0 AND upstream_batch_id <> batch_id)),
  INDEX `idx_m03_batch_upstream` (`upstream_batch_id`),

  PRIMARY KEY (`batch_id`) USING BTREE,

  INDEX `idx_res_batch_project`(`project_id` ASC) USING BTREE,

  INDEX `idx_res_batch_lab`(`lab_id` ASC) USING BTREE,

  INDEX `idx_res_batch_status`(`batch_status` ASC) USING BTREE,

  CONSTRAINT `ck_m03_batch_version` CHECK (`object_version` >= 1),

  CONSTRAINT `ck_m03_batch_facts` CHECK (`facts_status` IN ('READY','REVIEW')),

  CONSTRAINT `ck_m03_batch_identity` CHECK (`batch_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`batch_code`)) > 0),

  INDEX `idx_m03_batch_list` (`project_id`,`del_flag`,`update_time`,`batch_id`),

  UNIQUE INDEX `uk_m03_batch_code` (`project_id`,`m03_live_code`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '批次表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_batch_leader` (
`batch_id` bigint NOT NULL COMMENT '批次主键',

  `user_id` bigint NOT NULL COMMENT '负责人用户主键',

  PRIMARY KEY (`batch_id`, `user_id`) USING BTREE,

  INDEX `idx_res_batch_leader_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '批次负责人关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_batch_member` (
`batch_id` bigint NOT NULL COMMENT '批次主键',

  `user_id` bigint NOT NULL COMMENT '用户主键',

  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'member' COMMENT '权限类型（admin/member/view/share）',

  `expire_date` date NULL DEFAULT NULL COMMENT '权限截止日期',

  `source_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'direct' COMMENT '来源（direct/project_share/group）',

  `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',

  `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',

  `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',

  `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',

  `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',

  `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',

  `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',

  PRIMARY KEY (`batch_id`, `user_id`, `grant_type`) USING BTREE,

  INDEX `idx_res_batch_member_user`(`user_id` ASC) USING BTREE,

  INDEX `idx_res_batch_member_expire`(`expire_date` ASC) USING BTREE,

  CONSTRAINT `ck_m03_batch_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),

  CONSTRAINT `ck_m03_batch_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),

  INDEX `idx_m03_batch_grant_user` (`user_id`,`grant_type`,`expire_date`,`batch_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '批次成员权限表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture` (
  `initial_weight_g` DECIMAL(20,6) NULL COMMENT 'M03合并初始重量g，未知NULL',
  `initial_weight_revision` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `initial_weight_effective_at` DATETIME(3) NULL,
  `initial_weight_candidate_id` BIGINT NULL,
  `initial_weight_source_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'CHANGE_CANDIDATE/WORKFLOW_START；无有效重量NULL',
  `initial_weight_workflow_id` BIGINT NULL COMMENT '首次登记可信开始培养工作流；不伪造candidate',
  `cell_type_id` BIGINT NULL COMMENT '首次类型合法字典身份',
  `cell_type_name` VARCHAR(100) NULL COMMENT '首次类型名称快照',
  `cell_type_value` VARCHAR(100) NULL COMMENT '首次类型合法字典值快照，与显示名称分离',
  `cell_type_prefix` VARCHAR(100) NULL COMMENT '独立类型前缀；SC-Q07核准前拒绝非空输入',
  `cell_type_workflow_id` BIGINT NULL COMMENT '首次类型来源工作流',
  `cell_type_effective_at` DATETIME(3) NULL COMMENT '首次类型生效UTC时刻',
  `start_completed_workflow_id` BIGINT NULL COMMENT '已应用开始培养完成工作流；只写一次',
  UNIQUE KEY `uk_m03_start_completed_workflow` (`start_completed_workflow_id`),
  CONSTRAINT `ck_m03_initial_weight` CHECK (
    (initial_weight_g IS NULL AND initial_weight_revision=0 AND initial_weight_effective_at IS NULL AND initial_weight_candidate_id IS NULL AND initial_weight_source_kind IS NULL AND initial_weight_workflow_id IS NULL)
    OR (initial_weight_g IS NOT NULL AND initial_weight_g>0 AND initial_weight_g=FLOOR(initial_weight_g)
    AND initial_weight_revision>=1 AND initial_weight_effective_at IS NOT NULL AND initial_weight_source_kind IS NOT NULL
    AND ((initial_weight_source_kind='CHANGE_CANDIDATE' AND initial_weight_candidate_id IS NOT NULL AND initial_weight_workflow_id IS NULL)
    OR (initial_weight_source_kind='WORKFLOW_START' AND initial_weight_candidate_id IS NULL AND initial_weight_workflow_id IS NOT NULL)))),
  CONSTRAINT `ck_m03_start_cell_type` CHECK ((cell_type_id IS NULL AND cell_type_name IS NULL AND cell_type_value IS NULL AND cell_type_prefix IS NULL AND cell_type_workflow_id IS NULL AND cell_type_effective_at IS NULL) OR (cell_type_id IS NOT NULL AND cell_type_name IS NOT NULL AND CHAR_LENGTH(TRIM(cell_type_name))>0 AND cell_type_value IS NOT NULL AND CHAR_LENGTH(TRIM(cell_type_value))>0 AND cell_type_workflow_id IS NOT NULL AND cell_type_effective_at IS NOT NULL)),
`culture_id` bigint NOT NULL COMMENT '培养主键',

  `project_id` bigint NOT NULL COMMENT '项目主键',

  `batch_id` bigint NOT NULL COMMENT '批次主键',

  `lab_id` bigint NOT NULL COMMENT '实验室主键',

  `culture_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '培养编号',

  `culture_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '培养名称或别名',

  `culture_mode` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '培养模式（batch/perfusion/normal），字典：SMP培养模式',

  `is_special` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否特殊培养（0否 1是）',

  `reactor_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '反应器类型',

  `reactor_id` bigint NULL DEFAULT NULL COMMENT '反应器主键',

  `container_id` bigint NULL DEFAULT NULL COMMENT '培养容器主键',

  `reactor_capacity_value` decimal(12,3) NULL COMMENT '新增培养选择的反应器容量快照；培养容器为NULL',
  `reactor_category` varchar(100) NULL COMMENT '小试培养选择的台式反应器类别字典值快照；历史记录和中试为NULL',

  `reactor_capacity_unit` varchar(20) NULL COMMENT '反应器容量单位快照；与容量值同时为空或同时非空',

  `cell_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '细胞类型，字典：ViCell细胞类型',

  `culture_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0进行中 1已完成 2已终止），字典：SMP培养状态',

  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',

  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',

  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',

  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',

  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',

  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',

  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',

  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',

  `object_version` bigint NOT NULL DEFAULT 1 COMMENT '对象并发版本；迁移基线1，每次领域变更递增',

  `creator_user_id` bigint NULL COMMENT '真实创建用户ID，逻辑关联sys_user；旧身份未知NULL，不按当前用户名猜测',

  `modifier_user_id` bigint NULL COMMENT '最近修改用户ID，旧身份未知NULL',

  `deleted_at` datetime(3) NULL COMMENT '逻辑删除确认时刻UTC；旧未知NULL',

  `deleted_by_user_id` bigint NULL COMMENT '逻辑删除操作者ID，旧未知NULL',

  `facts_status` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'REVIEW' COMMENT 'READY已核准，REVIEW待核验；新业务必须显式READY',

  `lifecycle_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'DRAFT草稿/NOT_STARTED未开始/RUNNING进行中/EXPIRED已过期/DELAYED已延期/CANCELLED已取消/FINISHED已结束；旧未知NULL',

  `mode_code` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'NORMAL普通/REACTOR反应器；旧culture_mode仅保留原值',

  `device_kind` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER；选中主设备种类',

  `device_id` bigint NULL COMMENT '主设备稳定ID，按device_kind映射M02表，不按名称重绑',

  `planned_start_date` date NULL COMMENT '计划开始业务日Asia/Shanghai；不是实际流程开始时刻',

  `planned_end_date` date NULL COMMENT '计划结束业务日Asia/Shanghai；当天允许结束',

  `planned_duration_days` int NULL COMMENT '包含首尾的自然日数；两日期完整时DATEDIFF+1',

  `workflow_selection_json` json NULL COMMENT '已保存一级流程ID数组；新建未配置为configurationState=UNCONFIGURED对象；历史NULL/[]不自动补齐',

  `plan_version` bigint NOT NULL DEFAULT 0 COMMENT '计划并发版本；无计划基线0，有计划新建1；合法计划变更递增',

  `runtime_version` bigint NOT NULL DEFAULT 0 COMMENT '可信运行事实并发版本；迁移基线0，不重演历史事件',

  `n_marked` tinyint NULL COMMENT 'N阶段外部标识：0否/1是；新建显式0，旧未知NULL，不参与计算',

  `mode_changed_at` datetime(3) NULL COMMENT '普通转反应器的确认时刻UTC；未知NULL',

  `member_setup_state` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'UNKNOWN' COMMENT 'NEVER从未设置/CONFIGURED曾成功设置/UNKNOWN历史待核验；清空不重置',

  `first_workflow_started_at` datetime(3) NULL COMMENT '任意工作流首次可信开启时刻UTC；不是收到事件时刻',

  `start_completed_at` datetime(3) NULL COMMENT '开始培养可信完成时刻UTC；M07提供',

  `end_completed_at` datetime(3) NULL COMMENT '结束培养可信完成时刻UTC；本期仅隔离模拟',

  `cancel_confirmed_at` datetime(3) NULL COMMENT '取消业务可信确认时刻UTC，不等于设备释放',

  `start_delay_at` datetime(3) NULL COMMENT '开始阶段首次延期事实时刻UTC；历史保留，不作为当前原因开关',

  `end_delay_at` datetime(3) NULL COMMENT '结束阶段首次延期事实时刻UTC；历史保留',

  `start_delay_active` tinyint NOT NULL DEFAULT 0 COMMENT '当前开始阶段延期原因0无/1有；Q10消解按合法流程',

  `end_delay_active` tinyint NOT NULL DEFAULT 0 COMMENT '当前结束阶段延期原因0无/1有',

  `runtime_evidence_ref` varchar(128) NULL COMMENT '可信运行核准/事件证据引用；不存设备命令或未经校验payload',

  `m03_live_code` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' AND (`lifecycle_state` IS NULL OR `lifecycle_state` <> 'CANCELLED') THEN TRIM(`culture_code`) ELSE NULL END) STORED COMMENT '有效占号键；取消或删除释放，未知状态保守占号',

  `runtime_stream_id` varchar(128) NULL DEFAULT NULL COMMENT '当前M07稳定事实流，重启不换ID',
  `runtime_stream_sequence` bigint NULL DEFAULT NULL COMMENT '已生效源序列；未建立为NULL',
  `delay_resolution_json` json NULL DEFAULT NULL COMMENT '开始及结束延期当前消解证据，不覆盖历史首次时间',
  PRIMARY KEY (`culture_id`) USING BTREE,

  INDEX `idx_res_culture_project`(`project_id` ASC) USING BTREE,

  INDEX `idx_res_culture_batch`(`batch_id` ASC) USING BTREE,

  INDEX `idx_res_culture_lab`(`lab_id` ASC) USING BTREE,

  INDEX `idx_res_culture_status`(`culture_status` ASC) USING BTREE,

  INDEX `idx_res_culture_reactor_status`(`reactor_type` ASC, `reactor_id` ASC, `culture_status` ASC, `del_flag` ASC) USING BTREE,

  CONSTRAINT `ck_m03_culture_version` CHECK (`object_version` >= 1),

  CONSTRAINT `ck_m03_culture_facts` CHECK (`facts_status` IN ('READY','REVIEW')),

  CONSTRAINT `ck_m03_culture_identity` CHECK (`culture_id` > 0 AND `del_flag` IS NOT NULL AND `del_flag` IN ('0','2') AND CHAR_LENGTH(TRIM(`culture_code`)) > 0),

  CONSTRAINT `ck_m03_culture_state` CHECK (`lifecycle_state` IS NULL OR `lifecycle_state` IN ('DRAFT','NOT_STARTED','RUNNING','EXPIRED','DELAYED','CANCELLED','FINISHED')),

  CONSTRAINT `ck_m03_culture_mode` CHECK (`mode_code` IS NULL OR `mode_code` IN ('NORMAL','REACTOR')),

  CONSTRAINT `ck_m03_culture_device` CHECK ((`device_kind` IS NULL AND `device_id` IS NULL) OR (`device_kind` IS NOT NULL AND `device_kind` IN ('INTEGRATED_REACTOR','CULTURE_CONTAINER','BENCH_CONTROLLER') AND `device_id` IS NOT NULL AND `device_id` > 0)),

  CONSTRAINT `ck_m03_culture_reactor_capacity` CHECK ((`reactor_capacity_value` IS NULL AND `reactor_capacity_unit` IS NULL) OR (`reactor_capacity_value` > 0 AND `reactor_capacity_unit` IS NOT NULL AND CHAR_LENGTH(TRIM(`reactor_capacity_unit`)) > 0)),

  CONSTRAINT `ck_m03_culture_duration` CHECK ((`planned_duration_days` IS NULL OR `planned_duration_days` >= 1) AND (`planned_start_date` IS NULL OR `planned_end_date` IS NULL OR (`planned_end_date` >= `planned_start_date` AND `planned_duration_days` IS NOT NULL AND `planned_duration_days` = DATEDIFF(`planned_end_date`,`planned_start_date`) + 1))),

  CONSTRAINT `ck_m03_culture_plan_pair` CHECK (NOT ((`planned_start_date` IS NULL) <> (`planned_end_date` IS NULL)) OR `planned_duration_days` IS NULL),

  CONSTRAINT `ck_m03_culture_versions` CHECK (`plan_version` >= 0 AND `runtime_version` >= 0),

  CONSTRAINT `ck_m03_culture_flags` CHECK ((`n_marked` IS NULL OR `n_marked` IN (0,1)) AND `start_delay_active` IN (0,1) AND `end_delay_active` IN (0,1)),

  CONSTRAINT `ck_m03_culture_members` CHECK (`member_setup_state` IN ('NEVER','CONFIGURED','UNKNOWN')),

  CONSTRAINT `ck_m03_culture_ready` CHECK (`facts_status` <> 'READY' OR (`lifecycle_state` IS NOT NULL AND `mode_code` IS NOT NULL AND `device_kind` IS NOT NULL AND `device_id` IS NOT NULL AND `n_marked` IS NOT NULL AND `member_setup_state` <> 'UNKNOWN')),

  CONSTRAINT `ck_m03_culture_scheduled` CHECK (`facts_status` <> 'READY' OR `lifecycle_state` NOT IN ('NOT_STARTED','RUNNING','EXPIRED','DELAYED') OR (`planned_start_date` IS NOT NULL AND `planned_end_date` IS NOT NULL)),

  CONSTRAINT `ck_m03_culture_draft` CHECK (`facts_status` <> 'READY' OR `lifecycle_state` <> 'DRAFT' OR `planned_start_date` IS NULL OR `planned_end_date` IS NULL),

  CONSTRAINT `ck_m03_culture_runtime` CHECK (`facts_status` <> 'READY' OR ((`lifecycle_state` <> 'RUNNING' OR `first_workflow_started_at` IS NOT NULL) AND (`lifecycle_state` <> 'FINISHED' OR `end_completed_at` IS NOT NULL) AND (`lifecycle_state` <> 'CANCELLED' OR `cancel_confirmed_at` IS NOT NULL) AND (`lifecycle_state` <> 'DELAYED' OR (`first_workflow_started_at` IS NOT NULL AND (`start_delay_active` = 1 OR `end_delay_active` = 1))) AND (`lifecycle_state` <> 'DRAFT' OR `first_workflow_started_at` IS NULL))),

  UNIQUE INDEX `uk_m03_culture_live_code` (`m03_live_code`),

  INDEX `idx_m03_culture_lab_state` (`lab_id`,`del_flag`,`lifecycle_state`,`batch_id`,`project_id`),

  INDEX `idx_m03_culture_batch_list` (`batch_id`,`del_flag`,`update_time`,`culture_id`),

  INDEX `idx_m03_culture_device` (`device_kind`,`device_id`,`del_flag`),

  INDEX `idx_m03_culture_start_due` (`facts_status`,`del_flag`,`lifecycle_state`,`planned_start_date`),

  INDEX `idx_m03_culture_end_due` (`facts_status`,`del_flag`,`lifecycle_state`,`planned_end_date`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_feeding_config` (
  `culture_id` bigint NOT NULL COMMENT '培养主键；每个培养一行当前规则，逻辑关联res_culture',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '1补液规则当前生效/0因取消补液流程而保留停用历史',
  `calculation_basis` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'INITIAL_WEIGHT/CURRENT_WEIGHT',
  `residual_sugar_confirmation_mode` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NOT_REQUIRED/MANUAL_REQUIRED/COMPREHENSIVE',
  `calculate_sugar_concentration_change` tinyint NOT NULL DEFAULT 1 COMMENT '补糖时是否计算补料引起的糖浓度变化',
  `require_residual_sugar_confirmation_before_sugar` tinyint NOT NULL DEFAULT 1 COMMENT '补糖前是否要求确认残糖',
  `sugar_calculation_mode` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'RESIDUAL_SUGAR/RESIDUAL_SUGAR_AND_LACTATE',
  `config_version` bigint NOT NULL DEFAULT 1 COMMENT '规则独立版本；M07 创建任务时冻结此版本及字段快照',
  `creator_user_id` bigint NULL COMMENT '首次配置操作者',
  `modifier_user_id` bigint NULL COMMENT '最近修改或停用操作者',
  `create_time` datetime(3) NOT NULL COMMENT '首次配置UTC时刻',
  `update_time` datetime(3) NOT NULL COMMENT '最近修改或停用UTC时刻',
  PRIMARY KEY (`culture_id`) USING BTREE,
  CONSTRAINT `ck_m03_feeding_config_enabled` CHECK (`enabled` IN (0,1)),
  CONSTRAINT `ck_m03_feeding_config_basis` CHECK (`calculation_basis` IN ('INITIAL_WEIGHT','CURRENT_WEIGHT')),
  CONSTRAINT `ck_m03_feeding_config_confirmation` CHECK (`residual_sugar_confirmation_mode` IN ('NOT_REQUIRED','MANUAL_REQUIRED','COMPREHENSIVE')),
  CONSTRAINT `ck_m03_feeding_config_change` CHECK (`calculate_sugar_concentration_change` IN (0,1)),
  CONSTRAINT `ck_m03_feeding_config_before_sugar` CHECK (`require_residual_sugar_confirmation_before_sugar` IN (0,1)),
  CONSTRAINT `ck_m03_feeding_config_mode` CHECK (`sugar_calculation_mode` IN ('RESIDUAL_SUGAR','RESIDUAL_SUGAR_AND_LACTATE')),
  CONSTRAINT `ck_m03_feeding_config_version` CHECK (`config_version` >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养补液计算规则当前版本；运行任务必须冻结快照，不得运行时回读覆盖';

CREATE TABLE `res_culture_leader` (
`culture_id` bigint NOT NULL COMMENT '培养主键',

  `user_id` bigint NOT NULL COMMENT '负责人用户主键',

  PRIMARY KEY (`culture_id`, `user_id`) USING BTREE,

  INDEX `idx_res_culture_leader_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养负责人关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_member` (
`culture_id` bigint NOT NULL COMMENT '培养主键',

  `user_id` bigint NOT NULL COMMENT '用户主键',

  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'member' COMMENT '权限类型（admin/member/view/share）',

  `expire_date` date NULL DEFAULT NULL COMMENT '权限截止日期',

  `source_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'direct' COMMENT '来源（direct/project_share/batch_share/group）',

  `grant_type` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'LEGACY' COMMENT 'MEMBER直接成员/SHARE直接分享/LEGACY旧语义待核准；新接口拒绝LEGACY',

  `granted_at` datetime(3) NULL COMMENT '本次直接授权开始时刻UTC；旧记录未知NULL',

  `granted_by_user_id` bigint NULL COMMENT '本次授权操作者ID，旧未知NULL',

  `modified_at` datetime(3) NULL COMMENT '最近改期时刻UTC，旧未知NULL',

  `modified_by_user_id` bigint NULL COMMENT '最近改期操作者ID，旧未知NULL',

  `selection_origin` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'USER手选/DEPARTMENT部门快照/GROUP组快照；旧未知NULL，不形成动态继承',

  `selection_ref` varchar(128) NULL COMMENT '选择来源证据引用，非授权关系主键；可空',

  PRIMARY KEY (`culture_id`, `user_id`, `grant_type`) USING BTREE,

  INDEX `idx_res_culture_member_user`(`user_id` ASC) USING BTREE,

  INDEX `idx_res_culture_member_expire`(`expire_date` ASC) USING BTREE,

  CONSTRAINT `ck_m03_culture_grant_type` CHECK (`grant_type` IN ('MEMBER','SHARE','LEGACY')),

  CONSTRAINT `ck_m03_culture_origin` CHECK (`selection_origin` IS NULL OR `selection_origin` IN ('USER','DEPARTMENT','GROUP')),

  INDEX `idx_m03_culture_grant_user` (`user_id`,`grant_type`,`expire_date`,`culture_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '培养成员权限表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_occupancy` (
`occupancy_id` bigint NOT NULL COMMENT '一次取得主设备占用的不可复用主键，应用生成',

  `culture_id` bigint NOT NULL COMMENT '所属培养ID，逻辑关联res_culture',

  `device_kind` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'INTEGRATED_REACTOR/CULTURE_CONTAINER/BENCH_CONTROLLER',

  `device_id` bigint NOT NULL COMMENT 'M02对应表主键；身份与kind共同组成',

  `lab_id` bigint NOT NULL COMMENT '取得占用时实验室ID，须与培养及设备一致',

  `occupancy_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'RESERVED预约/RUNNING运行/RELEASE_PENDING待核验释放/RELEASED已确认释放',

  `acquired_at` datetime(3) NOT NULL COMMENT '取得占用的确认时刻UTC，不是计划开始日',

  `released_at` datetime(3) NULL COMMENT '已确认释放时刻UTC，其他状态NULL',

  `release_reason` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'EXPIRED/WITHDRAW/DELETE/REBOOK_REPLACED/FINISHED/CANCELLED；未释放NULL',

  `release_evidence_ref` varchar(128) NULL COMMENT '领域事务/可信运行释放凭据引用，释放必填',

  `created_request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '取得占用的管理请求ID或迁移核准批号',

  `object_version` bigint NOT NULL COMMENT '占用事实版本，初始1；条件释放防止误放新预约',

  `active_slot` tinyint GENERATED ALWAYS AS (CASE WHEN `occupancy_state` <> 'RELEASED' THEN 1 ELSE NULL END) STORED COMMENT '非释放状态均占用唯一槽位；允许多条已释放历史',

  `resource_release_snapshot` json NULL DEFAULT NULL COMMENT 'M07全部附属资源释放证据快照',
  `release_source_event_id` bigint NULL DEFAULT NULL COMMENT '已应用M03运行收件事件ID',
  PRIMARY KEY (`occupancy_id`),

  UNIQUE INDEX `uk_m03_occupancy_device` (`device_kind`,`device_id`,`active_slot`),

  UNIQUE INDEX `uk_m03_occupancy_culture` (`culture_id`,`active_slot`),

  INDEX `idx_m03_occupancy_lab` (`lab_id`,`occupancy_state`,`culture_id`),

  CONSTRAINT `ck_m03_occupancy_kind` CHECK (`device_kind` IN ('INTEGRATED_REACTOR','CULTURE_CONTAINER','BENCH_CONTROLLER')),

  CONSTRAINT `ck_m03_occupancy_state` CHECK (`occupancy_state` IN ('RESERVED','RUNNING','RELEASE_PENDING','RELEASED')),

  CONSTRAINT `ck_m03_occupancy_identity` CHECK (`occupancy_id` > 0 AND `culture_id` > 0 AND `device_id` > 0 AND `lab_id` > 0 AND `object_version` >= 1),

  CONSTRAINT `ck_m03_occupancy_release` CHECK ((`occupancy_state` = 'RELEASED' AND `released_at` IS NOT NULL AND `released_at` >= `acquired_at` AND `release_reason` IS NOT NULL AND `release_reason` IN ('EXPIRED','WITHDRAW','DELETE','REBOOK_REPLACED','FINISHED','CANCELLED') AND `release_evidence_ref` IS NOT NULL AND CHAR_LENGTH(`release_evidence_ref`) > 0) OR (`occupancy_state` <> 'RELEASED' AND `released_at` IS NULL AND `release_reason` IS NULL AND `release_evidence_ref` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03主设备占用及释放历史；不是按日期排程';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_notice_outbox` (
`event_id` bigint NOT NULL COMMENT '不可复用事件ID，应用生成，M09按此去重',

  `culture_id` bigint NOT NULL COMMENT '培养ID，逻辑关联res_culture，删除后保留',

  `event_type` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'N_MARK_CHANGED/DELAY_CHANGED；本表不接收设备控制事件',

  `culture_version` bigint NOT NULL COMMENT '产生事件后的培养object_version',

  `occurred_at` datetime(3) NOT NULL COMMENT '业务事实时刻UTC',

  `actor_user_id` bigint NULL COMMENT '用户操作者ID，系统判断NULL并由事件类型辨识',

  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '管理请求或可信系统事件去重标识',

  `old_value` json NOT NULL COMMENT '变化前：N标记{marked:boolean}；延期{state:string,startActive:boolean,endActive:boolean}',

  `new_value` json NOT NULL COMMENT '变化后，同old_value闭合结构；无用户列表或秘密',

  `delivery_state` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PENDING待交付/LEASED投递中/DELIVERED已被M09幂等接收',

  `attempt_count` int NOT NULL COMMENT '投递尝试次数，初始0',

  `next_attempt_at` datetime(3) NOT NULL COMMENT '下次可尝试时间UTC，初始业务提交时间',

  `lease_token` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '投递租用令牌，防止旧工作者覆盖新结果',

  `lease_until` datetime(3) NULL COMMENT '投递租约到期UTC，过期允许恢复',

  `delivered_at` datetime(3) NULL COMMENT 'M09确认接收时刻UTC；不等于用户阅读',

  `last_error_code` varchar(64) NULL COMMENT '最近脱敏错误码，不保存异常栈或远端敏感响应',

  PRIMARY KEY (`event_id`),

  UNIQUE INDEX `uk_m03_notice_fact` (`culture_id`,`event_type`,`culture_version`),

  INDEX `idx_m03_notice_dispatch` (`delivery_state`,`next_attempt_at`,`event_id`),

  CONSTRAINT `ck_m03_notice_type` CHECK (`event_type` IN ('N_MARK_CHANGED','DELAY_CHANGED')),

  CONSTRAINT `ck_m03_notice_state` CHECK (`delivery_state` IN ('PENDING','LEASED','DELIVERED') AND `attempt_count` >= 0 AND `culture_version` >= 1),

  CONSTRAINT `ck_m03_notice_lease` CHECK ((`delivery_state` = 'LEASED' AND `lease_token` IS NOT NULL AND `lease_until` IS NOT NULL AND `delivered_at` IS NULL) OR (`delivery_state` = 'PENDING' AND `lease_token` IS NULL AND `lease_until` IS NULL AND `delivered_at` IS NULL) OR (`delivery_state` = 'DELIVERED' AND `lease_token` IS NULL AND `lease_until` IS NULL AND `delivered_at` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03领域通知提交箱；M09拥有接收人与实际投递';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_parameter_application` (
`application_id` bigint NOT NULL COMMENT '主键',
  `snapshot_id` bigint NOT NULL COMMENT '不可变候选快照',
  `culture_id` bigint NOT NULL COMMENT '培养ID',
  `decision_key` varchar(128) NOT NULL COMMENT '唯一M06决定键或DIRECT请求键',
  `decision_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '完整决定摘要',
  `approval_id` bigint NULL COMMENT 'M06单据；DIRECT为空',
  `policy_evidence` json NOT NULL COMMENT '精确审批或免审批政策证据',
  `outcome` varchar(20) NOT NULL COMMENT 'APPLIED/DISCARDED/CONFLICT',
  `previous_snapshot_id` bigint NULL COMMENT '实际旧现行指针',
  `effective_snapshot_id` bigint NULL COMMENT '实际新现行指针，未应用仍为旧值',
  `parameter_generation` bigint NOT NULL COMMENT '处理后的参数代次',
  `result_json` json NOT NULL COMMENT '不可覆盖的回执与依赖结果',
  `handled_at` datetime(3) NOT NULL COMMENT '处理UTC时间',
  `actor_user_id` bigint NULL COMMENT '真实人工或系统空',
  PRIMARY KEY (`application_id`),
  UNIQUE KEY `uk_close_parameter_decision` (`decision_key`),
  KEY `ix_close_parameter_application` (`snapshot_id`,`handled_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养参数决定应用历史';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_parameter_snapshot` (
`snapshot_id` bigint NOT NULL COMMENT '主键，应用生成',
  `culture_id` bigint NOT NULL COMMENT 'M03培养稳定ID',
  `workflow_node_id` bigint NOT NULL COMMENT '一级流程稳定ID',
  `template_kind` varchar(16) NOT NULL COMMENT 'CONFIG/PERFUSION/SAMPLING/AUTO_CONTROL/FEEDING/PUMP_SPEED',
  `package_schema_version` int NOT NULL COMMENT 'TemplatePackage模式1历史或2新包',
  `template_package` json NOT NULL COMMENT '完整固定参数包，含工程快照',
  `package_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定包SHA256',
  `candidate_identity` json NULL COMMENT 'M03 v1不可变候选信封，历史候选可空',
  `candidate_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M03候选信封SHA256，与包摘要独立',
  `preparation_input` json NULL COMMENT '补液预核准准备原输入及拟生效代次，不代表已批准',
  `previous_snapshot_id` bigint NULL COMMENT '上一次同培养槽位快照',
  `base_effective_snapshot_id` bigint NULL COMMENT '捕获时现行快照',
  `base_config_snapshot_id` bigint NULL COMMENT '灌注生效所依赖Config快照',
  `culture_object_version` bigint NOT NULL COMMENT '捕获时培养对象版本',
  `schedule_plan_version` bigint NOT NULL COMMENT '捕获时日期计划版本，非参数代次',
  `device_kind` varchar(40) NOT NULL COMMENT '捕获时M02设备类型',
  `device_id` bigint NOT NULL COMMENT '捕获时设备稳定ID',
  `saved_by_user_id` bigint NOT NULL COMMENT '真实提交人',
  `saved_at` datetime(3) NOT NULL COMMENT '捕获UTC时间',
  `request_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户、源动作与请求ID摘要',
  `request_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求规范摘要',
  `request_id` varchar(64) NOT NULL COMMENT '源请求标识',
  `reason` varchar(500) NULL COMMENT '业务提交原因',
  PRIMARY KEY (`snapshot_id`),
  UNIQUE KEY `uk_close_snapshot_request` (`request_key`),
  KEY `ix_close_snapshot_culture` (`culture_id`,`workflow_node_id`,`saved_at`),
  CONSTRAINT `ck_m03_parameter_candidate_identity_pair` CHECK (
    (`candidate_identity` IS NULL AND `candidate_hash` IS NULL)
    OR (`candidate_identity` IS NOT NULL AND `candidate_hash` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养不可变方案参数包';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_parameter_state` (
`state_id` bigint NOT NULL COMMENT '主键',
  `culture_id` bigint NOT NULL COMMENT '培养ID',
  `workflow_node_id` bigint NOT NULL COMMENT '一级流程稳定ID',
  `template_kind` varchar(16) NOT NULL COMMENT '参数种类',
  `effective_snapshot_id` bigint NULL COMMENT '已合法生效快照',
  `candidate_snapshot_id` bigint NULL COMMENT '活动候选快照',
  `parameter_generation` bigint NOT NULL COMMENT '独立参数代次，从0开始',
  `approval_id` bigint NULL COMMENT 'M06审批单，明确DIRECT可空',
  `apply_state` varchar(20) NOT NULL COMMENT 'NONE/PREPARED/PENDING/APPLIED/DISCARDED/CONFLICT',
  `decision_key` varchar(128) NULL COMMENT 'M06 approvalId及decisionVersion或DIRECT回执键',
  `application_receipt` json NULL COMMENT '精确候选、决定与结果证据',
  `object_version` bigint NOT NULL COMMENT '指针/状态并发版本，从1开始',
  `updated_at` datetime(3) NOT NULL COMMENT '更新时间UTC',
  PRIMARY KEY (`state_id`),
  UNIQUE KEY `uk_close_parameter_slot` (`culture_id`,`workflow_node_id`,`template_kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养参数现行候选指针';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_workflow_reference` (
`reference_id` bigint NOT NULL COMMENT '主键',
  `culture_id` bigint NOT NULL COMMENT '培养ID，逻辑删除仍保留',
  `lab_id` bigint NOT NULL COMMENT '发生时实验室',
  `workflow_node_id` bigint NOT NULL COMMENT '一级流程稳定身份',
  `snapshot_id` bigint NULL COMMENT '参数快照；仅流程选择引用可空',
  `source_kind` varchar(20) NOT NULL COMMENT 'SNAPSHOT/WORKFLOW_SELECTION/LEGACY_VERIFIED',
  `source_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源稳定键摘要',
  `created_at` datetime(3) NOT NULL COMMENT '真实建立时间',
  `evidence_ref` json NOT NULL COMMENT '来源版本及核准证据',
  PRIMARY KEY (`reference_id`),
  UNIQUE KEY `uk_close_workflow_ref_source` (`source_key`),
  KEY `ix_close_workflow_ref_node` (`lab_id`,`workflow_node_id`,`culture_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养流程全历史引用';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_runtime_event` (
`event_id` bigint NOT NULL COMMENT '主键',
  `culture_id` bigint NOT NULL COMMENT '培养ID',
  `source_module` varchar(16) NOT NULL COMMENT 'M07或M03_SCHEDULER或SIMULATOR',
  `source_event_id` varchar(128) NOT NULL COMMENT '来源不可变事件身份',
  `source_event_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源模块及事件ID摘要',
  `stream_id` varchar(128) NOT NULL COMMENT '稳定运行事实流身份，重启不改变',
  `stream_sequence` bigint NOT NULL COMMENT '同流单调序列',
  `previous_event_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '前序源键；首事件空',
  `event_type` varchar(40) NOT NULL COMMENT 'FIRST_WORKFLOW_STARTED/START_COMPLETED/TERMINAL_CONFIRMED/RESOURCES_RELEASED/DEADLINE_EVALUATED/DELAY_RESOLVED',
  `source_object_version` bigint NOT NULL COMMENT '来源事实版本',
  `expected_culture_version` bigint NOT NULL COMMENT '预期培养版本',
  `expected_plan_version` bigint NOT NULL COMMENT '预期日期计划版本',
  `occupancy_id` bigint NULL COMMENT '目标主设备占用实例',
  `occurred_at` datetime(3) NOT NULL COMMENT '发生UTC时间',
  `received_at` datetime(3) NOT NULL COMMENT '接收UTC时间',
  `payload_json` json NOT NULL COMMENT '完整RuntimeFact模式1',
  `payload_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '源事实SHA256',
  `apply_state` varchar(20) NOT NULL COMMENT 'RECEIVED/APPLIED/IGNORED/BLOCKED',
  `result_json` json NULL COMMENT '前后版本、状态、占用和原因',
  `applied_at` datetime(3) NULL COMMENT '应用UTC时间',
  `object_version` bigint NOT NULL COMMENT '收件投影版本',
  `lease_token` varchar(64) NULL COMMENT '收件工作器栅栏token',
  `lease_until` datetime(3) NULL COMMENT '租约截止UTC',
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uk_close_runtime_source` (`source_event_key`),
  UNIQUE KEY `uk_close_runtime_sequence` (`culture_id`,`stream_id`,`stream_sequence`),
  KEY `ix_close_runtime_work` (`apply_state`,`lease_until`,`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养运行事实收件与生效回执';

-- Source: docs/详细设计/03-项目与培养管理/23-重量补齐完整目标表结构.sql
CREATE TABLE `res_culture_change_candidate` (
  `candidate_id` BIGINT NOT NULL COMMENT '培养基础变更候选',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `scene_code` VARCHAR(32) NOT NULL COMMENT '场景编码',
  `schema_version` SMALLINT UNSIGNED NOT NULL COMMENT '候选协议版本；1=既有协议，2=模式/初始重量完整证据',
  `operation_code` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CODE/DATES/MODE/INITIAL_WEIGHT/DEVICE',
  `change_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '变更键',
  `management_revision` BIGINT UNSIGNED NOT NULL COMMENT '提交时SYSTEM管理版本',
  `expected_target_version` BIGINT UNSIGNED NOT NULL COMMENT '期望目标版本',
  `expected_weight_revision` BIGINT UNSIGNED NULL COMMENT 'INITIAL_WEIGHT必填；其他操作为空',
  `before_snapshot` JSON NOT NULL COMMENT '固定原身份日期模式及设备版本',
  `after_snapshot` JSON NOT NULL COMMENT '受控基础字段候选',
  `impact_snapshot` JSON NOT NULL COMMENT '拥有方影响预览；纳入candidate_hash',
  `candidate_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '候选摘要',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PREPARED' COMMENT 'PREPARED/PENDING/APPLIED/DISCARDED/CONFLICT/UNKNOWN',
  `approval_id` BIGINT NULL COMMENT 'M06审批；DIRECT空',
  `policy_evidence` JSON NOT NULL COMMENT '固定政策与免审批依据',
  `reason` VARCHAR(500) NULL COMMENT '变更原因',
  `source_request_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户及原UUID',
  `source_request_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求内容',
  `decision_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '固定最终决定键',
  `decision_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '决定正文',
  `application_receipt` JSON NULL COMMENT '持久生效或封禁回执',
  `created_by` BIGINT NOT NULL COMMENT '原申请人',
  `created_at` DATETIME(3) NOT NULL COMMENT '候选提交；UTC',
  `applied_at` DATETIME(3) NULL COMMENT '实际应用；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `active_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state IN ('PREPARED','PENDING','UNKNOWN') THEN culture_id ELSE NULL END) STORED COMMENT '有效培养ID唯一键；仅待处理状态生成，应用或废弃后NULL',
  PRIMARY KEY (`candidate_id`),
  UNIQUE KEY `uk_m03_close_active_change` (`active_culture_id`),
  UNIQUE KEY `uk_m03_close_source` (`source_request_key`),
  UNIQUE KEY `uk_m03_close_decision` (`decision_key`),
  UNIQUE KEY `uk_m03_close_approval` (`approval_id`),
  CONSTRAINT `ck_m03_close_change_state` CHECK (state IN ('PREPARED','PENDING','APPLIED','DISCARDED','CONFLICT','UNKNOWN')),
  CONSTRAINT `ck_m03_close_change_scene` CHECK (scene_code IN ('M06_SC027','M06_SC028','M06_SC029','M06_SC030','M03_DEVICE_CHANGE')),
  CONSTRAINT `ck_m03_close_change_operation` CHECK (operation_code IN ('CODE','DATES','MODE','INITIAL_WEIGHT','DEVICE')),
  CONSTRAINT `ck_m03_close_change_scene_operation` CHECK (
    (scene_code='M06_SC027' AND operation_code='CODE') OR
    (scene_code='M06_SC028' AND operation_code='DATES') OR
    (scene_code='M06_SC029' AND operation_code='MODE') OR
    (scene_code='M06_SC030' AND operation_code='INITIAL_WEIGHT') OR
    (scene_code='M03_DEVICE_CHANGE' AND operation_code='DEVICE')
  ),
  CONSTRAINT `ck_m03_close_change_schema` CHECK (
    (schema_version=1 AND operation_code IN ('CODE','DATES','MODE','DEVICE')) OR
    (schema_version=2 AND operation_code IN ('MODE','INITIAL_WEIGHT'))
  ),
  CONSTRAINT `ck_m03_close_change_weight_revision` CHECK (
    (operation_code='INITIAL_WEIGHT' AND expected_weight_revision IS NOT NULL) OR
    (operation_code<>'INITIAL_WEIGHT' AND expected_weight_revision IS NULL)
  ),
  CONSTRAINT `ck_m03_close_change_reason` CHECK (operation_code<>'INITIAL_WEIGHT' OR (reason IS NOT NULL AND CHAR_LENGTH(TRIM(reason)) BETWEEN 1 AND 500)),
  CONSTRAINT `ck_m03_close_change_json` CHECK (JSON_TYPE(before_snapshot)='OBJECT' AND JSON_TYPE(after_snapshot)='OBJECT' AND JSON_TYPE(impact_snapshot)='OBJECT' AND JSON_TYPE(policy_evidence)='OBJECT'),
  CONSTRAINT `ck_m03_close_change_applied` CHECK (state<>'APPLIED' OR (application_receipt IS NOT NULL AND applied_at IS NOT NULL AND decision_key IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='res_culture_change_candidate 当前设计目标';

-- Source: docs/详细设计/04-工艺与方案管理/10-最终目标表结构.sql
CREATE TABLE `prc_template` (
  `template_id` bigint NOT NULL COMMENT '稳定模板身份，应用生成',
  `template_kind` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CONFIG/PERFUSION/SAMPLING/AUTO_CONTROL/FEEDING/PUMP_SPEED',
  `template_name` varchar(50) NOT NULL COMMENT '当前名称，去首尾空白，同类型未删除唯一',
  `current_version_id` bigint NULL DEFAULT NULL COMMENT '同身份当前完整版本，仅创建事务内部允许NULL',
  `object_version` bigint NOT NULL DEFAULT 1 COMMENT '名称内容或管理状态变更递增',
  `status` char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0' COMMENT '0启用，1禁用',
  `del_flag` char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0' COMMENT '0未删除，2已删除',
  `created_by_user_id` bigint NULL DEFAULT NULL COMMENT 'sys_user真实创建者，旧未知NULL',
  `created_at` datetime(3) NULL DEFAULT NULL COMMENT '创建UTC时刻，旧未知NULL',
  `updated_by_user_id` bigint NULL DEFAULT NULL COMMENT '最近管理修改者sys_user',
  `updated_at` datetime(3) NULL DEFAULT NULL COMMENT '最近管理修改UTC时刻',
  `deleted_by_user_id` bigint NULL DEFAULT NULL COMMENT '删除操作者，未删除NULL',
  `deleted_at` datetime(3) NULL DEFAULT NULL COMMENT '删除UTC时刻，未删除NULL',
  `created_request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '创建请求标识，不替代公共回执',
  `origin_kind` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NEW/COPY/IMPORT',
  `copied_from_version_id` bigint NULL DEFAULT NULL COMMENT 'COPY来源版本，其他NULL',
  `live_name` varchar(50) GENERATED ALWAYS AS (CASE WHEN `del_flag` = '0' THEN TRIM(`template_name`) ELSE NULL END) STORED COMMENT 'Q10占名键，禁用占用，删除释放',
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `uk_prc_template_live_name` (`template_kind`,`live_name`),
  KEY `idx_prc_template_current` (`current_version_id`),
  KEY `idx_prc_template_list_created` (`template_kind`,`del_flag`,`created_at`,`template_id`),
  KEY `idx_prc_template_list_updated` (`template_kind`,`del_flag`,`updated_at`,`template_id`),
  CONSTRAINT `ck_prc_template_kind` CHECK (`template_kind` IN ('CONFIG','PERFUSION','SAMPLING','AUTO_CONTROL','FEEDING','PUMP_SPEED')),
  CONSTRAINT `ck_prc_template_state` CHECK (`status` IN ('0','1') AND `del_flag` IN ('0','2') AND `object_version` >= 1),
  CONSTRAINT `ck_prc_template_name` CHECK (CHAR_LENGTH(TRIM(`template_name`)) >= 1),
  CONSTRAINT `ck_prc_template_origin` CHECK (`origin_kind` IN ('NEW','COPY','IMPORT')),
  CONSTRAINT `ck_prc_template_copy` CHECK ((`origin_kind` = 'COPY' AND `copied_from_version_id` IS NOT NULL) OR (`origin_kind` <> 'COPY' AND `copied_from_version_id` IS NULL)),
  CONSTRAINT `ck_prc_template_not_deleted` CHECK (`del_flag` = '2' OR (`deleted_by_user_id` IS NULL AND `deleted_at` IS NULL)),
  CONSTRAINT `ck_close_template_name` CHECK ((template_kind IN ('CONFIG','PERFUSION','SAMPLING','AUTO_CONTROL','FEEDING') AND CHAR_LENGTH(TRIM(template_name)) BETWEEN 2 AND 50) OR (template_kind='PUMP_SPEED' AND CHAR_LENGTH(TRIM(template_name)) BETWEEN 1 AND 19))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M04模板身份，逻辑删除保留历史';

-- Source: docs/详细设计/04-工艺与方案管理/10-最终目标表结构.sql
CREATE TABLE `prc_template_version` (
  `version_id` bigint NOT NULL COMMENT '不可变内容版本身份，应用生成',
  `template_id` bigint NOT NULL COMMENT '所属prc_template',
  `version_no` bigint NOT NULL COMMENT '同模板从1递增',
  `previous_version_id` bigint NULL DEFAULT NULL COMMENT '同身份前一版本，首版NULL',
  `name_snapshot` varchar(50) NOT NULL COMMENT '保存当时模板名称',
  `content_schema_version` int NOT NULL COMMENT '内容模式版本，当前1',
  `calculation_profile` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NONE/M04_CALC_V1，固定公式解释版本',
  `content_json` json NOT NULL COMMENT '类型化本体完整参数，服务端白名单构造',
  `applicability_json` json NOT NULL COMMENT 'labTypes/labIds/modelRefs适配交集，非用户权限',
  `canonical_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '规范化完整内容及绑定的SHA256，不是权限凭证',
  `reactor_type` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT 'INTEGRATED_REACTOR/BENCH_REACTOR查询投影',
  `control_platform` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT 'Config为DELTAV，其他NULL',
  `lab_type` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '泵速PILOT/SMALL/COMMON，其他NULL',
  `applicable_lab_id` bigint NULL DEFAULT NULL COMMENT '唯一限定实验室投影，未限定NULL',
  `culture_days` int NULL DEFAULT NULL COMMENT '自动控制/补液培养周期，单位天',
  `strategy_type` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT 'TWO_STAGE/THREE_STAGE泵速投影',
  `duration_display_min` decimal(20,2) NULL DEFAULT NULL COMMENT '泵速理论分钟HALF_UP两位显示，非执行精度',
  `saved_by_user_id` bigint NULL DEFAULT NULL COMMENT '真实版本保存者，旧未知NULL',
  `saved_at` datetime(3) NULL DEFAULT NULL COMMENT '版本保存UTC时刻，旧未知NULL',
  `saved_request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '正常保存请求标识，迁移可NULL',
  `change_kind` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CREATE/EDIT/COPY/IMPORT',
  `recorded_at` datetime(3) NOT NULL COMMENT '实际写入新系统UTC时刻，不冒充历史保存时间',
  `engineering_schema_version` int NULL DEFAULT NULL COMMENT '新工程快照模式1；旧历史未知NULL',
  `engineering_snapshot_json` json NULL DEFAULT NULL COMMENT '固定EngineeringBundle；非工程类型显式空集合',
  `engineering_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '工程快照规范SHA256；历史未知NULL',
  PRIMARY KEY (`version_id`),
  UNIQUE KEY `uk_prc_version_number` (`template_id`,`version_no`),
  KEY `idx_prc_version_owner` (`template_id`,`version_id`),
  KEY `idx_prc_version_lab` (`applicable_lab_id`,`version_id`),
  KEY `idx_prc_version_strategy` (`strategy_type`,`duration_display_min`,`version_id`),
  KEY `idx_prc_version_reactor` (`reactor_type`,`control_platform`,`version_id`),
  CONSTRAINT `ck_prc_version_sequence` CHECK (`version_no` >= 1 AND `content_schema_version` >= 1),
  CONSTRAINT `ck_prc_version_previous` CHECK ((`version_no` = 1 AND `previous_version_id` IS NULL) OR (`version_no` > 1 AND `previous_version_id` IS NOT NULL)),
  CONSTRAINT `ck_prc_version_profile` CHECK (`calculation_profile` IN ('NONE','M04_CALC_V1')),
  CONSTRAINT `ck_prc_version_json` CHECK (JSON_TYPE(`content_json`) = 'OBJECT' AND JSON_TYPE(`applicability_json`) = 'OBJECT'),
  CONSTRAINT `ck_prc_version_change` CHECK (`change_kind` IN ('CREATE','EDIT','COPY','IMPORT')),
  CONSTRAINT `ck_prc_version_reactor` CHECK (`reactor_type` IS NULL OR `reactor_type` IN ('INTEGRATED_REACTOR','BENCH_REACTOR')),
  CONSTRAINT `ck_prc_version_platform` CHECK (`control_platform` IS NULL OR `control_platform` = 'DELTAV'),
  CONSTRAINT `ck_prc_version_lab_type` CHECK (`lab_type` IS NULL OR `lab_type` IN ('PILOT','SMALL','COMMON')),
  CONSTRAINT `ck_prc_version_strategy` CHECK (`strategy_type` IS NULL OR `strategy_type` IN ('TWO_STAGE','THREE_STAGE')),
  CONSTRAINT `ck_prc_version_days` CHECK (`culture_days` IS NULL OR `culture_days` >= 1),
  CONSTRAINT `ck_prc_version_duration` CHECK (`duration_display_min` IS NULL OR `duration_display_min` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M04不可变完整版本，保存后无业务UPDATE/DELETE';

-- Source: docs/详细设计/04-工艺与方案管理/10-最终目标表结构.sql
CREATE TABLE `prc_template_binding` (
  `binding_id` bigint NOT NULL COMMENT '本版本新建绑定行身份',
  `parent_version_id` bigint NOT NULL COMMENT '所属父版本',
  `slot_key` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定规则或模板槽位，不使用数组下标',
  `parent_rule_id` varchar(36) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL COMMENT '父内容规则UUID，模板级槽位NULL',
  `source_template_id` bigint NOT NULL COMMENT '固定来源模板身份',
  `source_version_id` bigint NOT NULL COMMENT '固定来源版本，不追当前指针',
  `source_kind` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源模板种类，与来源身份相同',
  `effective_schema_version` int NOT NULL COMMENT '实际有效参数的内容模式版本',
  `effective_parameters_json` json NOT NULL COMMENT '带入及允许局部修改后的完整参数',
  `effective_applicability_json` json NOT NULL COMMENT '有效参数固定适配限制，不授予权限',
  `effective_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '完整有效内容规范化SHA256',
  `derived_from_binding_id` bigint NULL DEFAULT NULL COMMENT '服务端核实的前父版或复制源绑定，不接受客户端指定',
  PRIMARY KEY (`binding_id`),
  UNIQUE KEY `uk_prc_binding_slot` (`parent_version_id`,`slot_key`),
  KEY `idx_prc_binding_source` (`source_template_id`,`source_version_id`,`parent_version_id`),
  KEY `idx_prc_binding_derived` (`derived_from_binding_id`),
  CONSTRAINT `ck_prc_binding_kind` CHECK (`source_kind` IN ('CONFIG','PERFUSION','SAMPLING','AUTO_CONTROL','FEEDING','PUMP_SPEED')),
  CONSTRAINT `ck_prc_binding_schema` CHECK (`effective_schema_version` >= 1),
  CONSTRAINT `ck_prc_binding_json` CHECK (JSON_TYPE(`effective_parameters_json`) = 'OBJECT' AND JSON_TYPE(`effective_applicability_json`) = 'OBJECT'),
  CONSTRAINT `ck_prc_binding_slot` CHECK (CHAR_LENGTH(`slot_key`) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M04父版本固定来源和有效参数，逻辑关联';

-- Source: docs/详细设计/04-工艺与方案管理/10-最终目标表结构.sql
CREATE TABLE `prc_template_version_model` (
  `version_id` bigint NOT NULL COMMENT '所属模板版本',
  `model_kind` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'INTEGRATED_MODEL/BENCH_CONTROLLER_MODEL，后者映射待核准',
  `model_id` bigint NOT NULL COMMENT '对应M02共享型号ID，不是实例连接ID',
  `display_order` int NOT NULL COMMENT '从0起的用户选择顺序',
  PRIMARY KEY (`version_id`,`model_kind`,`model_id`),
  UNIQUE KEY `uk_prc_model_order` (`version_id`,`display_order`),
  KEY `idx_prc_model_reverse` (`model_kind`,`model_id`,`version_id`),
  CONSTRAINT `ck_prc_model_kind` CHECK (`model_kind` IN ('INTEGRATED_MODEL','BENCH_CONTROLLER_MODEL')),
  CONSTRAINT `ck_prc_model_order` CHECK (`display_order` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M04版本型号查询投影，不是型号主数据';

-- Source: docs/详细设计/04-工艺与方案管理/10-最终目标表结构.sql
CREATE TABLE `prc_template_import_map` (
  `import_map_id` bigint NOT NULL COMMENT '核准导入映射身份',
  `import_batch_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '受控核准导入批次',
  `source_system` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CDP/NPP独立来源',
  `source_table` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '已核准白名单旧表名，禁止据此拼任意SQL',
  `source_key` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '旧主键规范化字符串',
  `source_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准时旧主子数据规范化SHA256',
  `target_template_id` bigint NOT NULL COMMENT '核准导入的新模板身份',
  `target_version_id` bigint NOT NULL COMMENT '核准导入的新模板首版本',
  `reviewed_by_user_id` bigint NOT NULL COMMENT '真实核准者sys_user，不冒充旧创建者',
  `reviewed_at` datetime(3) NOT NULL COMMENT '核准UTC时刻',
  `evidence_ref` varchar(255) NOT NULL COMMENT '受控核准记录引用，不存证据正文',
  `imported_at` datetime(3) NOT NULL COMMENT '实际导入UTC时刻',
  PRIMARY KEY (`import_map_id`),
  UNIQUE KEY `uk_prc_import_source` (`source_system`,`source_table`,`source_key`),
  KEY `idx_prc_import_target` (`target_template_id`,`target_version_id`),
  KEY `idx_prc_import_batch` (`import_batch_id`,`import_map_id`),
  CONSTRAINT `ck_prc_import_source` CHECK (`source_system` IN ('CDP','NPP'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M04核准旧来源映射，非应用可编辑数据';

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_approval_assignee` (
`assignee_id` bigint NOT NULL COMMENT '配置主键',
  `scope_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '范围类型（project/batch/culture/lab）',
  `scope_id` bigint NOT NULL COMMENT '范围主键',
  `user_id` bigint NOT NULL COMMENT '审批人用户表主键',
  `assigner_user_id` bigint NULL DEFAULT NULL COMMENT '授权人用户主键',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `enabled` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否启用（0启用 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`assignee_id`) USING BTREE,
  INDEX `idx_det_approval_assignee_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测审批人配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_ccpd_upload_log` (
`upload_id` bigint NOT NULL COMMENT '上传记录主键',
  `result_id` bigint NOT NULL COMMENT '检测结果主键',
  `sample_id` bigint NOT NULL COMMENT '检测需求主键',
  `upload_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '上传类型（upload/revoke）',
  `upload_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '上传状态（0成功 1失败）',
  `request_payload` json NULL COMMENT '请求报文',
  `response_payload` json NULL COMMENT '响应报文',
  `error_message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误信息',
  `upload_time` datetime NULL DEFAULT NULL COMMENT '上传时间',
  PRIMARY KEY (`upload_id`) USING BTREE,
  INDEX `idx_det_ccpd_upload_log_result`(`result_id` ASC) USING BTREE,
  INDEX `idx_det_ccpd_upload_log_sample`(`sample_id` ASC) USING BTREE,
  INDEX `idx_det_ccpd_upload_log_time`(`upload_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'CCPD上传日志表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_dispatch_log` (
`log_id` bigint NOT NULL COMMENT '主键',
  `request_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备调用ID',
  `send_batch_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '页面批量提交编号',
  `detector_id` bigint NOT NULL COMMENT '检测设备ID',
  `detect_class` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：SMP检测类型',
  `detect_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备型号（BGA/Vicell/OSMO1/OSMO2/CedexBio/CedexBioHT），字典：SMP检测类型 二级字典值',
  `communication_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'HTTP/NAMED_PIPE',
  `invocation_mode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'BATCH/SINGLE',
  `sample_nos` json NULL COMMENT '样品编号列表',
  `device_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'accepted/rejected/unknown',
  `local_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'committed/rolled_back/unknown',
  `request_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '脱敏请求摘要',
  `response_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '脱敏响应摘要',
  `error_message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '脱敏错误',
  `start_time` datetime NULL COMMENT '实际调用开始时间；PREPARED为NULL',
  `end_time` datetime NULL DEFAULT NULL COMMENT '调用结束时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `dispatch_lifecycle` VARCHAR(16) NULL COMMENT 'PREPARED/INVOKING/RESOLVED/UNKNOWN，描述调用过程而非样品检测状态',
  `item_bindings` JSON NULL COMMENT '调用所含sampleId/resultId/列/位置/代次/期望指标及每项接受事实',
  `rule_snapshot` JSON NULL COMMENT '本次调用固定的完整规则及适配契约版本，不引用可变最新配置',
  `client_request_id` VARCHAR(64) NULL COMMENT '关联M01 HTTP幂等请求；现request_id仍为真实设备调用ID',
  CONSTRAINT `ck_m05_dispatch_lifecycle` CHECK (dispatch_lifecycle IS NULL OR BINARY dispatch_lifecycle IN ('PREPARED','INVOKING','RESOLVED','UNKNOWN')),
  CONSTRAINT `ck_m05_bindings_array` CHECK (item_bindings IS NULL OR JSON_TYPE(item_bindings)='ARRAY'),
  CONSTRAINT `ck_m05_dispatch_rule_object` CHECK (rule_snapshot IS NULL OR JSON_TYPE(rule_snapshot)='OBJECT'),
  INDEX `idx_m05_client_request` (`client_request_id`),
  INDEX `idx_m05_dispatch_recovery` (`detector_id`,`dispatch_lifecycle`,`create_time`),
  PRIMARY KEY (`log_id`) USING BTREE,
  UNIQUE INDEX `uk_det_dispatch_request`(`request_id` ASC) USING BTREE,
  INDEX `idx_det_dispatch_batch`(`send_batch_no` ASC) USING BTREE,
  INDEX `idx_det_dispatch_detector_time`(`detector_id` ASC, `start_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '离线检测样品下发调用日志' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_exception_note` (
`note_id` bigint NOT NULL COMMENT '备注主键',
  `result_id` bigint NOT NULL COMMENT '检测结果主键',
  `result_item_id` bigint NULL DEFAULT NULL COMMENT '检测结果明细主键',
  `exception_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常类型',
  `note_content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常备注内容',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`note_id`) USING BTREE,
  INDEX `idx_det_exception_note_result`(`result_id` ASC) USING BTREE,
  INDEX `idx_det_exception_note_item`(`result_item_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测异常备注表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_print_export_log` (
`log_id` bigint NOT NULL COMMENT '日志主键',
  `result_id` bigint NOT NULL COMMENT '检测结果主键',
  `sample_id` bigint NOT NULL COMMENT '检测需求主键',
  `action_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型（print/export）',
  `printer_id` bigint NULL DEFAULT NULL COMMENT '打印机主键',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '文件名',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '文件路径',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_det_print_export_log_result`(`result_id` ASC) USING BTREE,
  INDEX `idx_det_print_export_log_sample`(`sample_id` ASC) USING BTREE,
  INDEX `idx_det_print_export_log_time`(`create_time` ASC) USING BTREE,
  `job_root_id` BIGINT NULL COMMENT '每冻结结果一行；root指向自身log_id，子行指向root',
  `actor_user_id` BIGINT NULL COMMENT '稳定操作用户；历史NULL',
  `request_id` VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M01请求UUID；与用户及结果组合去重',
  `request_payload_hash` BINARY(32) NULL COMMENT 'root规范化请求摘要',
  `job_state` VARCHAR(16) NULL COMMENT 'root PREPARING/RENDERING/READY/SUBMITTED/UNKNOWN/FAILED',
  `job_version` BIGINT UNSIGNED NULL COMMENT 'root乐观版本，从1递增；子行NULL',
  `content_manifest` JSON NULL COMMENT 'root不可变完整结果版本和动作集合及模板映射快照',
  `file_sha256` BINARY(32) NULL COMMENT 'root服务端生成文件摘要',
  `template_profile` VARCHAR(32) NULL COMMENT 'root核准模板配置及版本键',
  `template_hash` BINARY(32) NULL COMMENT 'root原模板SHA256',
  `selection_snapshot` JSON NULL COMMENT 'root不可变选中与扩展范围及用途',
  `job_evidence` JSON NULL COMMENT 'root租约token及生成打印尝试证据；允许追加',
  `state_updated_at` DATETIME(3) NULL COMMENT 'root最近状态变更时间',
  CONSTRAINT `ck_m05_report_state` CHECK (job_state IS NULL OR job_state IN ('PREPARING','RENDERING','READY','SUBMITTED','UNKNOWN','FAILED')),
  CONSTRAINT `ck_m05_report_identity` CHECK (job_root_id IS NULL OR (job_root_id>0 AND actor_user_id IS NOT NULL AND actor_user_id>0 AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36)),
  CONSTRAINT `ck_m05_report_root` CHECK (job_root_id IS NULL OR (job_root_id<>log_id AND job_state IS NULL AND job_version IS NULL AND content_manifest IS NULL) OR (job_root_id=log_id AND job_state IS NOT NULL AND job_version IS NOT NULL AND job_version>=1 AND request_payload_hash IS NOT NULL AND content_manifest IS NOT NULL AND template_profile IS NOT NULL AND template_hash IS NOT NULL AND selection_snapshot IS NOT NULL AND state_updated_at IS NOT NULL)),
  CONSTRAINT `ck_m05_report_json` CHECK ((content_manifest IS NULL OR JSON_TYPE(content_manifest)='OBJECT') AND (selection_snapshot IS NULL OR JSON_TYPE(selection_snapshot)='OBJECT') AND (job_evidence IS NULL OR JSON_TYPE(job_evidence)='OBJECT')),
  CONSTRAINT `ck_m05_report_ready` CHECK (job_state IS NULL OR job_state NOT IN ('READY','SUBMITTED','UNKNOWN') OR (file_sha256 IS NOT NULL AND file_path IS NOT NULL AND CHAR_LENGTH(TRIM(file_path))>0)),
  UNIQUE INDEX `uk_m05_report_request_result` (actor_user_id,request_id,result_id),
  INDEX `idx_m05_report_root` (job_root_id,log_id),
  INDEX `idx_m05_report_jobs` (job_state,state_updated_at,log_id)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '打印导出日志表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_result` (
`current_correction_id` BIGINT NULL COMMENT '当前批准更正；NULL沿原投影',
  `result_id` bigint NOT NULL COMMENT '检测结果主键',
  `sample_id` bigint NOT NULL COMMENT '样品检测需求主键',
  `detector_id` bigint NOT NULL COMMENT '检测设备主键',
  `detect_class` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：SMP检测类型',
  `detect_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备型号（BGA/Vicell/OSMO1/OSMO2/CedexBio/CedexBioHT），字典：SMP检测类型 二级字典值',
  `result_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'testing' COMMENT '结果状态（idle/stored/pending/testing/tested/uploaded/signed/reviewed/voided/timeout/exception/cancelled），字典：SMP检测队列状态',
  `testing_end_time` datetime NULL DEFAULT NULL COMMENT '检测完成时间',
  `testing_start_time` datetime NULL DEFAULT NULL COMMENT '上样时间',
  `raw_data` json NULL COMMENT '设备原始结果JSON',
  `review_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人用户名',
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `sign_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '签名人用户名',
  `sign_time` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `void_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '作废原因，字典：SMP作废原因',
  `void_from_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '作废前状态（tested/uploaded），用于撤销作废恢复',
  `exception_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '异常原因，字典：SMP异常原因',
  `is_alarm` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否告警（0否 1是）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`result_id`) USING BTREE,
  INDEX `idx_det_result_sample`(`sample_id` ASC) USING BTREE,
  INDEX `idx_det_result_detector`(`detector_id` ASC) USING BTREE,
  INDEX `idx_det_result_status`(`result_status` ASC) USING BTREE,
  INDEX `idx_result_sample`(`sample_id` ASC) USING BTREE,
  INDEX `idx_det_result_poll`(`result_status` ASC, `detector_id` ASC) USING BTREE,
  INDEX `idx_det_result_timeout`(`result_status` ASC, `testing_start_time` ASC) USING BTREE,
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '结果内容状态签批共同版本；复用主设计版本不另设result_version',
  `result_completeness` VARCHAR(16) NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'NONE/PARTIAL/COMPLETE/UNVERIFIED',
  `device_completion` VARCHAR(16) NOT NULL DEFAULT 'UNKNOWN' COMMENT 'NOT_FINISHED/FINISHED/UNKNOWN；失败取消终态另见source_progress',
  `collection_state` VARCHAR(24) NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'UNVERIFIED/OPEN/RECONCILING/CLOSED/CLOSED_EXCEPTION',
  `actual_started_at` DATETIME(3) NULL COMMENT '可信实际检测开始；不是上样时间',
  `completion_observed_at` DATETIME(3) NULL COMMENT '本系统首次观测可信设备结束的时点',
  `time_evidence` JSON NULL COMMENT '每个时刻的来源时区精度及事件引用；NULL为历史未核验',
  `collection_basis` JSON NULL COMMENT '本次dispatch/sample/代次及非空expectedItems不可变快照',
  `source_progress` JSON NULL COMMENT '各类事实源版本终态依据和待更正事件；不是按收到先后覆盖',
  `last_event_id` BIGINT NULL COMMENT '最近实际改变本结果的接收事件；不是全部历史',
  `next_collect_at` DATETIME(3) NULL COMMENT '下一次只读采集核对调度时间；不触发发送',
  CONSTRAINT `ck_m05_rx_version` CHECK (object_version>=1),
  CONSTRAINT `ck_m05_rx_complete` CHECK (result_completeness IN ('NONE','PARTIAL','COMPLETE','UNVERIFIED')),
  CONSTRAINT `ck_m05_rx_device` CHECK (device_completion IN ('NOT_FINISHED','FINISHED','UNKNOWN')),
  CONSTRAINT `ck_m05_rx_collect` CHECK (collection_state IN ('UNVERIFIED','OPEN','RECONCILING','CLOSED','CLOSED_EXCEPTION')),
  CONSTRAINT `ck_m05_rx_r_time` CHECK (time_evidence IS NULL OR JSON_TYPE(time_evidence)='OBJECT'),
  CONSTRAINT `ck_m05_rx_basis` CHECK (collection_basis IS NULL OR JSON_TYPE(collection_basis)='OBJECT'),
  CONSTRAINT `ck_m05_rx_progress` CHECK (source_progress IS NULL OR JSON_TYPE(source_progress)='OBJECT'),
  CONSTRAINT `ck_m05_rx_closed` CHECK (collection_state<>'CLOSED' OR (result_completeness='COMPLETE' AND device_completion='FINISHED')),
  CONSTRAINT `ck_m05_rx_expected` CHECK (result_completeness='UNVERIFIED' OR (collection_basis IS NOT NULL AND COALESCE(JSON_TYPE(JSON_EXTRACT(collection_basis,'$.expectedItems')),'')='ARRAY' AND COALESCE(JSON_LENGTH(JSON_EXTRACT(collection_basis,'$.expectedItems')),0)>0)),
  INDEX `idx_m05_rx_collect` (collection_state,next_collect_at,result_id),
  INDEX `idx_m05_rx_result_event` (last_event_id),
  `active_sign_id` BIGINT NULL COMMENT '当前有效SIGN动作主键；不从最新记录推算',
  `active_review_id` BIGINT NULL COMMENT '当前有效REVIEW动作主键；关联有效签名',
  `active_void_id` BIGINT NULL COMMENT '当前有效整结果VOID动作主键；精确恢复原状态',
  `sign_chain_state` VARCHAR(16) NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'VERIFIED/UNVERIFIED/CONFLICT；历史默认未核验',
  CONSTRAINT `ck_m05_sign_chain` CHECK (sign_chain_state IN ('VERIFIED','UNVERIFIED','CONFLICT')),
  CONSTRAINT `ck_m05_sign_ptr_positive` CHECK ((active_sign_id IS NULL OR active_sign_id>0) AND (active_review_id IS NULL OR active_review_id>0) AND (active_void_id IS NULL OR active_void_id>0)),
  CONSTRAINT `ck_m05_sign_ptr_state` CHECK ((sign_chain_state<>'VERIFIED' AND active_sign_id IS NULL AND active_review_id IS NULL AND active_void_id IS NULL) OR (sign_chain_state='VERIFIED' AND ((result_status='signed' AND active_sign_id IS NOT NULL AND active_review_id IS NULL AND active_void_id IS NULL) OR (result_status='reviewed' AND active_sign_id IS NOT NULL AND active_review_id IS NOT NULL AND active_void_id IS NULL) OR (result_status='voided' AND active_sign_id IS NULL AND active_review_id IS NULL AND active_void_id IS NOT NULL) OR (result_status NOT IN ('signed','reviewed','voided') AND active_sign_id IS NULL AND active_review_id IS NULL AND active_void_id IS NULL)))),
  INDEX `idx_m05_active_sign` (active_sign_id),
  INDEX `idx_m05_active_review` (active_review_id),
  INDEX `idx_m05_active_void` (active_void_id),
  `active_upload_id` BIGINT NULL COMMENT '当前有效人工或系统上传动作；历史NULL不推断',
  CONSTRAINT `ck_m05_upload_ptr` CHECK (active_upload_id IS NULL OR active_upload_id>0),
  INDEX `idx_m05_active_upload` (active_upload_id)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测结果主表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_result_item` (
`result_item_id` bigint NOT NULL COMMENT '检测结果明细主键',
  `result_id` bigint NOT NULL COMMENT '检测结果主键',
  `item_id` bigint NULL DEFAULT NULL COMMENT '检测项库主键',
  `item_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项编码',
  `item_cn_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项中文名称',
  `item_en_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项英文名称',
  `item_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测值',
  `numeric_value` decimal(18, 6) NULL DEFAULT NULL COMMENT '数值结果',
  `original_value` decimal(18, 6) NULL DEFAULT NULL COMMENT '原始值',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '单位',
  `lower_limit` decimal(18, 6) NULL DEFAULT NULL COMMENT '告警下限',
  `upper_limit` decimal(18, 6) NULL DEFAULT NULL COMMENT '告警上限',
  `is_alarm` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否告警（0否 1是）',
  `is_voided` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否单条作废（0否 1是）',
  `void_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '单条作废原因，字典：SMP作废原因',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '最近结果更新时间',
  PRIMARY KEY (`result_item_id`) USING BTREE,
  UNIQUE INDEX `uk_det_result_item_result_code`(`result_id` ASC, `item_code` ASC) USING BTREE,
  INDEX `idx_det_result_item_result`(`result_id` ASC) USING BTREE,
  INDEX `idx_det_result_item_item`(`item_id` ASC) USING BTREE,
  `item_outcome` VARCHAR(16) NOT NULL DEFAULT 'UNKNOWN' COMMENT 'VALUE/ERROR/NO_MEASUREMENT/UNKNOWN；历史值不自动核准',
  `source_evidence` JSON NULL COMMENT '源项目子样品修订单位与映射版本及事件ID集合',
  `last_event_id` BIGINT NULL COMMENT '最近实际改变本明细的事件；逻辑关联',
  CONSTRAINT `ck_m05_rx_outcome` CHECK (item_outcome IN ('VALUE','ERROR','NO_MEASUREMENT','UNKNOWN')),
  CONSTRAINT `ck_m05_rx_item_evidence` CHECK (source_evidence IS NULL OR JSON_TYPE(source_evidence)='OBJECT'),
  INDEX `idx_m05_rx_item_event` (last_event_id),
  `active_void_action_id` BIGINT NULL COMMENT '当前有效单项作废动作；不是整结果作废',
  CONSTRAINT `ck_m05_item_void_ptr` CHECK (active_void_action_id IS NULL OR (active_void_action_id>0 AND is_voided IS NOT NULL AND is_voided='1')),
  INDEX `idx_m05_item_void_action` (active_void_action_id)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测结果明细表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_result_sign_record` (
`sign_id` bigint NOT NULL COMMENT '记录主键',
  `result_id` bigint NULL DEFAULT NULL COMMENT '检测结果主键，暂存阶段为空',
  `sample_id` bigint NOT NULL COMMENT '检测需求主键',
  `action_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型（submit/approve/reject/sign/void/revoke/print/export/upload）',
  `action_result` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '操作结果（0失败 1成功）',
  `action_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '原因或意见',
  `signer_user_id` bigint NULL DEFAULT NULL COMMENT '操作人用户主键',
  `before_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作前状态快照',
  `after_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作后状态快照',
  `old_sample_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '修改前样品ID',
  `new_sample_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '修改后样品ID',
  `revoked_by_sign_id` bigint NULL DEFAULT NULL COMMENT '对应撤销操作记录主键',
  `voided_time` datetime NULL DEFAULT NULL COMMENT '被撤销时间',
  `is_voided` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '是否已被撤销（0否 1是）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`sign_id`) USING BTREE,
  INDEX `idx_det_sign_record_result`(`result_id` ASC) USING BTREE,
  INDEX `idx_det_sign_record_sample`(`sample_id` ASC) USING BTREE,
  INDEX `idx_det_sign_record_action`(`action_type` ASC, `create_time` ASC) USING BTREE,
  INDEX `idx_det_sign_record_active_action`(`result_id` ASC, `action_type` ASC, `is_voided` ASC, `create_time` ASC) USING BTREE,
  `action_contract_version` SMALLINT UNSIGNED NULL COMMENT '本批成功动作固定1；旧记录NULL不伪造升级',
  `operation_code` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'SIGN/REVIEW/REVOKE_SIGN/REVOKE_REVIEW/VOID/RESTORE_VOID；精确新契约类型',
  `result_version_before` BIGINT UNSIGNED NULL COMMENT '操作锁定的结果版本',
  `result_version_after` BIGINT UNSIGNED NULL COMMENT '成功后结果版本，等于before加1',
  `content_snapshot` JSON NULL COMMENT '不可变对象：schema/content/actor/authorization/action；完整明细与来源依据',
  `content_hash` BINARY(32) NULL COMMENT '规范化snapshot.content的SHA256；非电子证书签名',
  `request_id` VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '同操作者M01请求UUID；领域证据不随HTTP回执过期删除',
  `related_action_id` BIGINT NULL COMMENT 'REVIEW指向被审核SIGN；撤销/恢复指向原动作',
  CONSTRAINT `ck_m05_sign_contract` CHECK (action_contract_version IS NULL OR action_contract_version IN (1,2)),
  CONSTRAINT `ck_m05_sign_new_required` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR (operation_code IS NOT NULL AND operation_code IN ('SIGN','REVIEW','REVOKE_SIGN','REVOKE_REVIEW','VOID','RESTORE_VOID') AND result_id IS NOT NULL AND signer_user_id IS NOT NULL AND signer_user_id>0 AND action_result IS NOT NULL AND action_result='1' AND before_status IS NOT NULL AND after_status IS NOT NULL AND create_time IS NOT NULL AND result_version_before IS NOT NULL AND result_version_before>=1 AND result_version_after IS NOT NULL AND result_version_after=result_version_before+1 AND content_snapshot IS NOT NULL AND content_hash IS NOT NULL AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36)),
  CONSTRAINT `ck_m05_sign_snapshot` CHECK (content_snapshot IS NULL OR JSON_TYPE(content_snapshot)='OBJECT'),
  CONSTRAINT `ck_m05_sign_relation` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR ((operation_code IN ('SIGN','VOID') AND related_action_id IS NULL) OR (operation_code IN ('REVIEW','REVOKE_SIGN','REVOKE_REVIEW','RESTORE_VOID') AND related_action_id IS NOT NULL AND related_action_id>0))),
  CONSTRAINT `ck_m05_sign_reason` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR operation_code IN ('SIGN','REVIEW') OR (action_reason IS NOT NULL AND CHAR_LENGTH(TRIM(action_reason)) BETWEEN 1 AND 500)),
  CONSTRAINT `ck_m05_sign_transition` CHECK (action_contract_version=2 OR action_contract_version IS NULL OR (operation_code='SIGN' AND before_status='uploaded' AND after_status='signed') OR (operation_code='REVIEW' AND before_status='signed' AND after_status='reviewed') OR (operation_code='REVOKE_SIGN' AND before_status='signed' AND after_status='uploaded') OR (operation_code='REVOKE_REVIEW' AND before_status='reviewed' AND after_status='signed') OR (operation_code='VOID' AND before_status IN ('tested','uploaded') AND after_status='voided') OR (operation_code='RESTORE_VOID' AND before_status='voided' AND after_status IN ('tested','uploaded'))),
  INDEX `idx_m05_sign_related` (related_action_id),
  UNIQUE INDEX `uk_m05_sign_request_result` (signer_user_id,request_id,result_id),
  `target_result_item_id` BIGINT NULL COMMENT 'v2单项动作目标；其他动作NULL',
  CONSTRAINT `ck_m05_action_v2_required` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR (operation_code IS NOT NULL AND operation_code IN ('UPLOAD','AUTO_UPLOAD','REVOKE_UPLOAD','RENAME_SAMPLE','MARK_EXCEPTION','DELETE_RESULT','VOID_ITEM','RESTORE_ITEM') AND result_id IS NOT NULL AND action_result IS NOT NULL AND action_result='1' AND before_status IS NOT NULL AND after_status IS NOT NULL AND create_time IS NOT NULL AND result_version_before IS NOT NULL AND result_version_before>=1 AND result_version_after IS NOT NULL AND result_version_after=result_version_before+1 AND content_snapshot IS NOT NULL AND content_hash IS NOT NULL AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36 AND ((operation_code='AUTO_UPLOAD' AND signer_user_id IS NULL) OR (operation_code<>'AUTO_UPLOAD' AND signer_user_id IS NOT NULL AND signer_user_id>0)))),
  CONSTRAINT `ck_m05_action_v2_target` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR ((operation_code IN ('VOID_ITEM','RESTORE_ITEM') AND target_result_item_id IS NOT NULL AND target_result_item_id>0) OR (operation_code NOT IN ('VOID_ITEM','RESTORE_ITEM') AND target_result_item_id IS NULL))),
  CONSTRAINT `ck_m05_action_v2_relation` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR ((operation_code IN ('REVOKE_UPLOAD','RESTORE_ITEM') AND related_action_id IS NOT NULL AND related_action_id>0) OR (operation_code NOT IN ('REVOKE_UPLOAD','RESTORE_ITEM') AND related_action_id IS NULL))),
  CONSTRAINT `ck_m05_action_v2_reason` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR operation_code IN ('UPLOAD','AUTO_UPLOAD','DELETE_RESULT') OR (action_reason IS NOT NULL AND CHAR_LENGTH(TRIM(action_reason)) BETWEEN 1 AND 500)),
  CONSTRAINT `ck_m05_action_v2_transition` CHECK (action_contract_version IS NULL OR action_contract_version<>2 OR (operation_code IN ('UPLOAD','AUTO_UPLOAD') AND before_status='tested' AND after_status='uploaded') OR (operation_code='REVOKE_UPLOAD' AND before_status='uploaded' AND after_status='tested') OR (operation_code IN ('RENAME_SAMPLE','VOID_ITEM','RESTORE_ITEM') AND before_status IN ('tested','uploaded') AND after_status=before_status) OR (operation_code='MARK_EXCEPTION' AND before_status IN ('pending','testing') AND after_status='exception') OR (operation_code='DELETE_RESULT' AND before_status IN ('pending','testing') AND after_status=before_status)),
  INDEX `idx_m05_action_item` (target_result_item_id,sign_id)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测结果-操作审计表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_review_audit_log` (
`audit_id` bigint NOT NULL COMMENT '审核日志主键',
  `result_id` bigint NOT NULL COMMENT '检测结果主键',
  `audit_step` int NULL DEFAULT 1 COMMENT '审核步骤',
  `audit_user_id` bigint NULL DEFAULT NULL COMMENT '审核人用户主键',
  `audit_user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '审核人名称快照',
  `audit_action` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作类型（upload/revoke_upload/void/void_item/sign/audit/exception/cancel_void/cancel_item_void/revoke_sign/revoke_audit/edit）',
  `audit_opinion` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '审核意见',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (`audit_id`) USING BTREE,
  INDEX `idx_det_review_audit_log_result`(`result_id` ASC) USING BTREE,
  INDEX `idx_det_review_audit_log_time`(`audit_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审核日志表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_sample` (
  `current_result_id` BIGINT NULL COMMENT '核准当前运行主结果；多结果歧义保留NULL',
`sample_id` bigint NOT NULL COMMENT '样品检测需求主键',
  `sample_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '当前样品编号',
  `second_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'Second主键',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目主键',
  `batch_id` bigint NULL DEFAULT NULL COMMENT '批次主键',
  `culture_id` bigint NULL DEFAULT NULL COMMENT '培养主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `detector_id` bigint NOT NULL COMMENT '检测设备主键',
  `detect_class` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：SMP检测类型',
  `detect_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备型号（BGA/Vicell/OSMO1/OSMO2/CedexBio/CedexBioHT），字典：SMP检测类型 二级字典值',
  `detect_mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '检测模式（manual/auto）',
  `queue_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'idle' COMMENT '队列状态（idle/stored/pending/testing/tested/uploaded/signed/reviewed/voided/timeout/exception/cancelled），字典：SMP检测队列状态',
  `send_batch_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发送批次号，同一批次发送的记录共享该值',
  `column_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '列号编号',
  `channel_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通道编号',
  `sample_position` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '样品位置',
  `day_number` int NULL DEFAULT NULL COMMENT '培养天数',
  `detect_count` int NULL DEFAULT 1 COMMENT '当日检测次数',
  `temperature` decimal(4, 1) NULL DEFAULT NULL COMMENT '温度，BGA使用',
  `cell_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '细胞类型，Vicell使用，字典：ViCell细胞类型',
  `dilution_factor` decimal(12, 4) NULL DEFAULT NULL COMMENT '稀释倍数，Vicell使用',
  `testing_start_time` datetime NULL DEFAULT NULL COMMENT '上样时间',
  `testing_end_time` datetime NULL DEFAULT NULL COMMENT '检测完成时间',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `clear_flag` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '清空标志（0否 1是）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '样品修改、关联、状态、占位、清空/删除共同版本',
  `created_user_id` BIGINT NULL COMMENT '稳定暂存/创建用户身份；create_by继续用于原审计显示',
  `sent_user_id` BIGINT NULL COMMENT '本次真实送检操作者，确定派发时固定；不由回调登录人代填',
  `occupancy_generation` BIGINT UNSIGNED NULL COMMENT '新装入时以设备新queue_revision分配；同位置新样品必须新代次',
  `occupancy_state` VARCHAR(16) NULL COMMENT 'DRAFT/RESERVED/RUNNING/UNKNOWN/COMPLETED/RELEASED；与业务queue_status独立',
  `draft_source` VARCHAR(24) NULL COMMENT 'MANUAL/OFFLINE_UNSENT/CAPACITY_UNSENT，非未发送草稿可为NULL；不含已接受/未知请求',
  `current_dispatch_id` BIGINT NULL COMMENT '逻辑关联det_dispatch_log.log_id，最近相关调用；历史映射仍保存于每次调用',
  `send_requested_at` DATETIME(3) NULL COMMENT '发起发送动作时间，不能替代设备上样testing_start_time',
  CONSTRAINT `ck_m05_sample_version` CHECK (object_version>=1),
  CONSTRAINT `ck_m05_occupancy_generation` CHECK (occupancy_generation IS NULL OR occupancy_generation>0),
  CONSTRAINT `ck_m05_occupancy_state` CHECK (occupancy_state IS NULL OR BINARY occupancy_state IN ('DRAFT','RESERVED','RUNNING','UNKNOWN','COMPLETED','RELEASED')),
  CONSTRAINT `ck_m05_draft_source` CHECK (draft_source IS NULL OR BINARY draft_source IN ('MANUAL','OFFLINE_UNSENT','CAPACITY_UNSENT')),
  INDEX `idx_m05_occupancy` (`detector_id`,`occupancy_state`,`column_no`,`channel_no`),
  INDEX `idx_m05_dispatch` (`current_dispatch_id`),
  INDEX `idx_m05_draft_owner` (`created_user_id`,`queue_status`,`create_time`),
  PRIMARY KEY (`sample_id`) USING BTREE,
  INDEX `idx_det_sample_biz`(`project_id` ASC, `batch_id` ASC, `culture_id` ASC) USING BTREE,
  INDEX `idx_det_sample_lab_type`(`lab_id` ASC, `detect_class` ASC) USING BTREE,
  INDEX `idx_det_sample_status_time`(`queue_status` ASC, `create_time` ASC) USING BTREE,
  INDEX `idx_det_sample_no_del`(`lab_id` ASC, `detect_class` ASC, `sample_no` ASC, `del_flag` ASC) USING BTREE,
  INDEX `idx_sample_pending`(`detector_id` ASC, `detect_class` ASC, `testing_start_time` ASC) USING BTREE,
  INDEX `idx_sample_testing`(`detector_id` ASC, `detect_class` ASC) USING BTREE,
  INDEX `idx_sample_table_status`(`detector_id` ASC, `detect_class` ASC, `column_no` ASC) USING BTREE,
  INDEX `idx_det_sample_detect_type`(`detector_id` ASC, `queue_status` ASC) USING BTREE,
  `actual_started_at` DATETIME(3) NULL COMMENT '可信实际检测开始；不是上样时间',
  `completion_observed_at` DATETIME(3) NULL COMMENT '本系统首次观测可信设备结束的时点',
  `time_evidence` JSON NULL COMMENT '每个时刻的来源时区精度及事件引用；NULL为历史未核验',
  CONSTRAINT `ck_m05_rx_s_time` CHECK (time_evidence IS NULL OR JSON_TYPE(time_evidence)='OBJECT'),
  CONSTRAINT `ck_m05_close_current_result` CHECK (current_result_id IS NULL OR current_result_id>0)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测需求与样品队列表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_sample_id_history` (
`history_id` bigint NOT NULL COMMENT '历史记录主键',
  `sample_id` bigint NOT NULL COMMENT '检测需求主键',
  `old_sample_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '修改前样品编号',
  `new_sample_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '修改后样品编号',
  `change_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '修改原因，字典：SMP样品ID修改原因',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '修改人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`history_id`) USING BTREE,
  INDEX `idx_det_sample_id_history_sample`(`sample_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '样品ID编辑历史表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_sample_item` (
`sample_id` bigint NOT NULL COMMENT '检测需求主键',
  `item_id` bigint NOT NULL COMMENT '检测项主键',
  `item_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项ID快照',
  `item_cn_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项中文名称快照',
  `item_en_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '检测项英文名称快照',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `dilution_numerator` SMALLINT UNSIGNED NULL COMMENT '项目稀释左值，新请求固定1；旧NULL不擅自当1',
  `dilution_denominator` SMALLINT UNSIGNED NULL COMMENT '项目稀释右值，新请求1—100整数，不能复用样品dilution_factor',
  CONSTRAINT `ck_m05_item_dilution` CHECK ((dilution_numerator IS NULL AND dilution_denominator IS NULL) OR (dilution_numerator IS NOT NULL AND dilution_denominator IS NOT NULL AND dilution_numerator=1 AND dilution_denominator BETWEEN 1 AND 100)),
  PRIMARY KEY (`sample_id`, `item_id`) USING BTREE,
  INDEX `idx_det_sample_item_item`(`item_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '检测请求选择项表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_device_event` (
`event_id` BIGINT NOT NULL COMMENT '系统生成主键；每份观测独立保存',
  `observation_id` VARCHAR(128) NOT NULL COMMENT '适配器观测标识；非唯一避免同标识异载荷丢失',
  `detector_id` BIGINT NOT NULL COMMENT '认证映射设备实例；非前端自报',
  `adapter_key` VARCHAR(128) NOT NULL COMMENT '可信适配器身份',
  `contract_version` VARCHAR(64) NOT NULL COMMENT '解析及映射契约固定版本',
  `source_scope` VARCHAR(512) NOT NULL COMMENT '稳定源事件命名空间；不随应用重启改变',
  `native_event_id` VARCHAR(512) NULL COMMENT '原生事件键；未知为NULL',
  `native_revision` VARCHAR(128) NULL COMMENT '原生修订字符串；不默认可按字符串比较',
  `dedup_key` TEXT NULL COMMENT '经核准的完整规范去重键；证据不足为NULL',
  `dedup_hash` BINARY(32) NULL COMMENT '完整去重键SHA256查询索引；命中后仍比较完整键',
  `semantic_hash` BINARY(32) NOT NULL COMMENT '标准化语义摘要；冲突判断仍核对规范载荷',
  `raw_hash` BINARY(32) NOT NULL COMMENT '原始字节SHA256',
  `raw_payload` LONGBLOB NOT NULL COMMENT '实际收到的原始字节；不可被JSON规范化替代',
  `payload_meta` JSON NOT NULL COMMENT '编码媒体类型传输来源及源时间原文；不存认证密钥',
  `normalized_payload` JSON NOT NULL COMMENT '解析冻结的完整观测对象含items及事实类型',
  `event_kinds` JSON NOT NULL COMMENT '非空事实类型数组；同包兼容事实一并应用',
  `received_at` DATETIME(3) NOT NULL COMMENT '本系统耐久接收时间UTC',
  `source_observed_at` DATETIME(3) NULL COMMENT '可信源发生时间归一UTC；未知时区不得填',
  `resolved_bindings` JSON NULL COMMENT '逐成员dispatch/sample/result/代次绑定及关联证据',
  `correlation_status` VARCHAR(16) NOT NULL DEFAULT 'UNMATCHED' COMMENT 'UNMATCHED/MATCHED/AMBIGUOUS',
  `receipt_status` VARCHAR(24) NOT NULL DEFAULT 'RECEIVED' COMMENT 'RECEIVED/APPLIED/DUPLICATE/UNMATCHED/CONFLICT/RETRYABLE_ERROR',
  `receipt_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '处理回执CAS版本；重试不改原文',
  `related_event_id` BIGINT NULL COMMENT '重复指向原事件或冲突对照事件；全部同键证据可查询',
  `applied_versions` JSON NULL COMMENT '每个受影响resultId及before/afterObjectVersion；多样品包使用数组',
  `applied_at` DATETIME(3) NULL COMMENT '领域事实与APPLIED回执原子提交时间',
  `retry_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '应用重试次数；不表示设备重发次数',
  `next_retry_at` DATETIME(3) NULL COMMENT '瞬时失败退避时间',
  `error_code` VARCHAR(64) NULL COMMENT '脱敏处理问题码',
  `error_detail` VARCHAR(1000) NULL COMMENT '脱敏说明；原文证据保存在raw_payload',
  `processing_history` JSON NULL COMMENT '追加处理尝试版本与问题；不得用重试覆盖冲突历史',
  PRIMARY KEY (`event_id`),
  INDEX `idx_m05_rx_e_dedup` (detector_id,dedup_hash,event_id),
  INDEX `idx_m05_rx_e_retry` (receipt_status,next_retry_at,event_id),
  INDEX `idx_m05_rx_e_source` (detector_id,received_at,event_id),
  INDEX `idx_m05_rx_e_related` (related_event_id),
  CONSTRAINT `ck_m05_rx_e_version` CHECK (receipt_version>=1),
  CONSTRAINT `ck_m05_rx_e_dedup` CHECK ((dedup_key IS NULL AND dedup_hash IS NULL) OR (dedup_key IS NOT NULL AND dedup_hash IS NOT NULL)),
  CONSTRAINT `ck_m05_rx_e_corr` CHECK (correlation_status IN ('UNMATCHED','MATCHED','AMBIGUOUS')),
  CONSTRAINT `ck_m05_rx_e_receipt` CHECK (receipt_status IN ('RECEIVED','APPLIED','DUPLICATE','UNMATCHED','CONFLICT','RETRYABLE_ERROR')),
  CONSTRAINT `ck_m05_rx_e_applied` CHECK (receipt_status<>'APPLIED' OR (correlation_status='MATCHED' AND applied_at IS NOT NULL AND applied_versions IS NOT NULL)),
  CONSTRAINT `ck_m05_rx_e_duplicate` CHECK (receipt_status<>'DUPLICATE' OR related_event_id IS NOT NULL),
  CONSTRAINT `ck_m05_rx_e_payload_meta` CHECK (JSON_TYPE(payload_meta)='OBJECT'),
  CONSTRAINT `ck_m05_rx_e_normalized_payload` CHECK (JSON_TYPE(normalized_payload)='OBJECT'),
  CONSTRAINT `ck_m05_rx_e_kinds` CHECK (JSON_TYPE(event_kinds)='ARRAY' AND JSON_LENGTH(event_kinds)>0),
  CONSTRAINT `ck_m05_rx_e_resolved_bindings` CHECK (resolved_bindings IS NULL OR JSON_TYPE(resolved_bindings)='ARRAY'),
  CONSTRAINT `ck_m05_rx_e_applied_versions` CHECK (applied_versions IS NULL OR JSON_TYPE(applied_versions)='ARRAY'),
  CONSTRAINT `ck_m05_rx_e_processing_history` CHECK (processing_history IS NULL OR JSON_TYPE(processing_history)='ARRAY')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_bin ROW_FORMAT=DYNAMIC COMMENT='设备观测耐久收件与应用回执';

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_result_revision` (
`revision_id` BIGINT NOT NULL COMMENT '不可变版本兼发件箱事件主键',
  `result_id` BIGINT NOT NULL COMMENT '结果主键；逻辑关联',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '精确结果版本',
  `event_kind` VARCHAR(32) NOT NULL COMMENT 'INITIAL/BASELINE/RECEIVE或精确领域动作',
  `source_kind` VARCHAR(16) NOT NULL COMMENT 'RESULT/ACTION/RECEIVE/CORRECTION',
  `source_id` BIGINT NOT NULL COMMENT '对应结果或动作或接收事件或更正申请主键',
  `actor_user_id` BIGINT NULL COMMENT '用户主体；系统事件NULL',
  `content_snapshot` JSON NOT NULL COMMENT '完整ResultSnapshot，内容不可变',
  `created_at` DATETIME(3) NOT NULL COMMENT '版本提交前服务器时刻',
  `publish_state` VARCHAR(16) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/RETRY/PUBLISHED',
  `publish_attempts` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '尝试次数，不等同下游消费次数',
  `next_publish_at` DATETIME(3) NULL COMMENT '退避重试时刻',
  `last_error` VARCHAR(1000) NULL COMMENT '无凭据的投递错误摘要',
  `published_at` DATETIME(3) NULL COMMENT '消息系统确认交接时刻',
  PRIMARY KEY (`revision_id`),
  UNIQUE INDEX `uk_m05_revision_result_version` (result_id,object_version),
  INDEX `idx_m05_revision_publish` (publish_state,next_publish_at,revision_id),
  CONSTRAINT `ck_m05_revision_version` CHECK (result_id>0 AND object_version>=1),
  CONSTRAINT `ck_m05_revision_snapshot` CHECK (JSON_TYPE(content_snapshot)='OBJECT'),
  CONSTRAINT `ck_m05_revision_source` CHECK (source_kind IN ('RESULT','ACTION','RECEIVE','CORRECTION') AND source_id IS NOT NULL AND source_id>0),
  CONSTRAINT `ck_m05_revision_publish` CHECK ((publish_state IN ('PENDING','RETRY') AND published_at IS NULL) OR (publish_state='PUBLISHED' AND published_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='检测结果不可变版本与事务发件箱';

-- Source: docs/详细设计/05-检测与数据签批/30-审阅收尾完整目标表结构.sql
CREATE TABLE `det_result_correction` (
`correction_id` BIGINT NOT NULL COMMENT '更正申请主键',
  `result_id` BIGINT NOT NULL COMMENT '原结果稳定主键',
  `base_object_version` BIGINT UNSIGNED NOT NULL COMMENT '提交时结果基线',
  `base_correction_id` BIGINT NULL COMMENT '前一已生效更正',
  `base_content_hash` CHAR(64) NOT NULL COMMENT '完整原版摘要',
  `candidate_snapshot` JSON NOT NULL COMMENT '冻结完整候选',
  `candidate_hash` CHAR(64) NOT NULL COMMENT '候选规范摘要',
  `changed_paths` JSON NOT NULL COMMENT '稳定指标字段差异',
  `evidence_refs` JSON NOT NULL COMMENT '不可变证据及身份依据',
  `reason` VARCHAR(500) NOT NULL COMMENT '更正理由',
  `state` VARCHAR(16) NOT NULL DEFAULT 'SUBMITTED' COMMENT '申请状态',
  `submitted_by` BIGINT NOT NULL COMMENT '新版本签名人稳定ID',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '当前签名时刻UTC',
  `submission_signature` JSON NOT NULL COMMENT '签名声明及摘要与当时身份',
  `submit_request_id` CHAR(36) NOT NULL COMMENT '提交持久幂等键',
  `submit_payload_hash` CHAR(64) NOT NULL COMMENT '规范请求摘要',
  `terminal_actor_id` BIGINT NULL COMMENT '决定或撤回操作者',
  `terminal_at` DATETIME(3) NULL COMMENT '终结时刻UTC',
  `terminal_request_id` CHAR(36) NULL COMMENT '终结持久幂等键',
  `terminal_payload_hash` CHAR(64) NULL COMMENT '终结规范请求摘要',
  `terminal_reason` VARCHAR(500) NULL COMMENT '审核撤回或过期原因',
  `review_signature` JSON NULL COMMENT '批准的新审核签名及候选摘要',
  `result_revision_id` BIGINT NULL COMMENT '批准生成不可变版本',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '申请乐观版本',
  `pending_result_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state='SUBMITTED' THEN result_id ELSE NULL END) STORED COMMENT '每结果至多一个未决申请',
  PRIMARY KEY (`correction_id`),
  UNIQUE INDEX `uk_m05_corr_pending` (`pending_result_id`),
  UNIQUE INDEX `uk_m05_corr_submit` (`submitted_by`,`submit_request_id`),
  UNIQUE INDEX `uk_m05_corr_terminal` (`terminal_actor_id`,`terminal_request_id`),
  INDEX `idx_m05_corr_result` (`result_id`,`correction_id`),
  CONSTRAINT `ck_m05_corr_ids` CHECK (correction_id>0 AND result_id>0 AND submitted_by>0 AND object_version>=1 AND (base_correction_id IS NULL OR base_correction_id>0)),
  CONSTRAINT `ck_m05_corr_json` CHECK (JSON_TYPE(candidate_snapshot)='OBJECT' AND JSON_TYPE(changed_paths)='ARRAY' AND JSON_TYPE(evidence_refs)='ARRAY' AND JSON_LENGTH(evidence_refs) BETWEEN 1 AND 20 AND JSON_TYPE(submission_signature)='OBJECT'),
  CONSTRAINT `ck_m05_corr_reason` CHECK (CHAR_LENGTH(TRIM(reason)) BETWEEN 1 AND 500),
  CONSTRAINT `ck_m05_corr_state` CHECK (state IN ('SUBMITTED','APPROVED','REJECTED','WITHDRAWN','STALE')),
  CONSTRAINT `ck_m05_corr_terminal` CHECK ((state='SUBMITTED' AND terminal_actor_id IS NULL AND terminal_at IS NULL AND terminal_request_id IS NULL AND terminal_payload_hash IS NULL AND terminal_reason IS NULL AND review_signature IS NULL AND result_revision_id IS NULL) OR (state<>'SUBMITTED' AND terminal_actor_id IS NOT NULL AND terminal_actor_id>0 AND terminal_at IS NOT NULL AND terminal_request_id IS NOT NULL AND terminal_payload_hash IS NOT NULL AND terminal_reason IS NOT NULL AND CHAR_LENGTH(TRIM(terminal_reason)) BETWEEN 1 AND 500)),
  CONSTRAINT `ck_m05_corr_approval` CHECK ((state='APPROVED' AND terminal_actor_id<>submitted_by AND result_revision_id IS NOT NULL AND result_revision_id>0 AND review_signature IS NOT NULL AND JSON_TYPE(review_signature)='OBJECT') OR (state<>'APPROVED' AND result_revision_id IS NULL AND review_signature IS NULL)),
  CONSTRAINT `ck_m05_corr_actor` CHECK ((state='WITHDRAWN' AND terminal_actor_id=submitted_by) OR state<>'WITHDRAWN')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='受控更正申请与不可变候选证据';

-- Source: docs/详细设计/06-流程审批管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `apr_scene` (
`scene_code` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '受控场景码主键；不是可编辑业务名称',
  `source_kind` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'TASK/CULTURE_OPERATION/PLAN_INITIALIZATION/DATA_MANAGEMENT',
  `module_level1` VARCHAR(64) NOT NULL COMMENT '源一级模块名称',
  `module_level2` VARCHAR(100) NOT NULL COMMENT '源二级模块名称',
  `operation_code` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MODIFY/MANUAL_CREATE/SYSTEM_CREATE/CREATE/INIT/CANCEL/ALARM_BLOCK/CANCEL_COPY/VOID',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M03/M05/M07/M09；真实变更拥有方',
  `scope_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SUPPORTED/OWNER_GATED/EXCLUDED',
  `source_reference` VARCHAR(255) NOT NULL COMMENT '冻结源文件工作表行号',
  `source_hash` BINARY(32) NOT NULL COMMENT '源附件SHA256',
  `schema_version` SMALLINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '受控目录版本',
  `sort_order` INT UNSIGNED NOT NULL COMMENT '展示顺序',
  `scope_reason` VARCHAR(500) NOT NULL COMMENT '本期范围或排除依据',
  PRIMARY KEY (`scene_code`),
  CONSTRAINT `ck_apr_scene_source` CHECK (source_kind IN ('TASK','CULTURE_OPERATION','PLAN_INITIALIZATION','DATA_MANAGEMENT')),
  CONSTRAINT `ck_apr_scene_scope` CHECK (scope_state IN ('SUPPORTED','OWNER_GATED','EXCLUDED')),
  CONSTRAINT `ck_apr_scene_owner` CHECK (owner_module IN ('M03','M05','M07','M09'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

-- Source: docs/详细设计/06-流程审批管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `apr_lab_policy` (
  `activation_evidence` JSON NULL COMMENT '分批启用或暂停的操作者、批次、核准及原因；完整历史见policy_revision',
  `activation_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'DISABLED' COMMENT 'DISABLED/ENABLED/PAUSED；旧政策不自动启用',
`policy_id` BIGINT NOT NULL COMMENT '平台分配主键',
  `lab_id` BIGINT NOT NULL COMMENT '真实lab_lab实验室；逻辑唯一',
  `current_revision_id` BIGINT NULL COMMENT '当前不可变配置版本；初始NULL',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '整份配置共同版本',
  `readiness` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'UNVERIFIED' COMMENT 'UNVERIFIED/READY；不默认免审批',
  `created_at` DATETIME(3) NOT NULL COMMENT '创建时刻',
  `updated_at` DATETIME(3) NOT NULL COMMENT '最近更新时刻',
  `updated_by` BIGINT NOT NULL COMMENT '稳定配置操作者',
  PRIMARY KEY (`policy_id`),
  UNIQUE INDEX `uk_apr_policy_lab` (`lab_id`),
  CONSTRAINT `ck_apr_policy_version` CHECK (object_version>=1),
  CONSTRAINT `ck_apr_policy_ready` CHECK (readiness IN ('UNVERIFIED','READY') AND (readiness<>'READY' OR current_revision_id IS NOT NULL)),
  CONSTRAINT `ck_apr_close_activation` CHECK (activation_state IN ('DISABLED','ENABLED','PAUSED') AND (activation_state<>'ENABLED' OR (readiness='READY' AND current_revision_id IS NOT NULL AND activation_evidence IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

-- Source: docs/详细设计/06-流程审批管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `apr_policy_revision` (
  `request_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '配置或启停规范请求摘要',
  `request_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '真实操作人及UUID持久幂等；历史NULL',
`revision_id` BIGINT NOT NULL COMMENT '不可变配置版本主键',
  `policy_id` BIGINT NOT NULL COMMENT '配置根逻辑关联',
  `revision_no` BIGINT UNSIGNED NOT NULL COMMENT '同配置从1递增',
  `policy_snapshot` JSON NOT NULL COMMENT 'schema/entries/resolutionRules完整快照',
  `content_hash` BINARY(32) NOT NULL COMMENT '规范化配置SHA256',
  `source_evidence` JSON NOT NULL COMMENT '初始化资料或人工维护事实及核准人时间',
  `created_by` BIGINT NOT NULL COMMENT '真实配置操作者',
  `created_at` DATETIME(3) NOT NULL COMMENT '版本形成时刻',
  `change_reason` VARCHAR(500) NULL COMMENT '管理变更说明，可空；非审批原因',
  PRIMARY KEY (`revision_id`),
  UNIQUE INDEX `uk_apr_policy_revision` (`policy_id`,`revision_no`),
  CONSTRAINT `ck_apr_policy_revision_no` CHECK (revision_no>=1),
  CONSTRAINT `ck_apr_policy_json` CHECK (JSON_TYPE(policy_snapshot)='OBJECT' AND JSON_TYPE(source_evidence)='OBJECT'),
  UNIQUE KEY `uk_apr_close_policy_request` (`request_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

-- Source: docs/详细设计/06-流程审批管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `apr_request` (
`approval_id` BIGINT NOT NULL COMMENT '审批单主键',
  `scene_code` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'apr_scene场景逻辑关联',
  `lab_id` BIGINT NOT NULL COMMENT '固定真实实验室',
  `project_id` BIGINT NOT NULL COMMENT '固定真实项目',
  `batch_id` BIGINT NOT NULL COMMENT '固定真实批次',
  `culture_id` BIGINT NOT NULL COMMENT '固定真实培养',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M03/M07/M09',
  `source_request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '拥有方持久幂等请求键',
  `change_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '受控业务操作唯一槽；不由客户端任意选择',
  `target_type` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CULTURE/TASK/PLAN/ALARM_CONFIG',
  `target_id` BIGINT NOT NULL COMMENT '业务对象或预分配候选任务ID',
  `expected_target_version` BIGINT UNSIGNED NOT NULL COMMENT '审阅所依赖源版本；新增候选0',
  `candidate_id` BIGINT NOT NULL COMMENT '来源不可变候选ID',
  `candidate_version` BIGINT UNSIGNED NOT NULL COMMENT '来源候选版本',
  `candidate_hash` BINARY(32) NOT NULL COMMENT '精确内容SHA256',
  `policy_revision_id` BIGINT NOT NULL COMMENT '申请固定政策版本',
  `policy_snapshot` JSON NOT NULL COMMENT '仅本场景策略与分离/回退规则快照',
  `change_snapshot` JSON NOT NULL COMMENT '全部前后差异与关联对象和影响规则',
  `initiator_kind` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'USER/SYSTEM',
  `initiator_user_id` BIGINT NULL COMMENT '人工申请人；系统NULL',
  `initiator_snapshot` JSON NOT NULL COMMENT '提交身份和合法来源证据',
  `submission_reason` VARCHAR(500) NULL COMMENT '提交补充说明',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PENDING_REVIEW' COMMENT 'PENDING_REVIEW/PENDING_APPROVAL/APPROVED/CANCELLED',
  `apply_state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'NONE' COMMENT 'NONE/NOT_APPLICABLE/PENDING/APPLIED/CONFLICT/FAILED/UNKNOWN',
  `cancel_kind` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'REJECTED/WITHDRAWN/SOURCE_INVALIDATED',
  `decision_version` BIGINT UNSIGNED NULL COMMENT '最终决定版本；后续ack不改变',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '审批及生效投影共同版本',
  `reviewer_user_id` BIGINT NULL COMMENT '首级真实审核人',
  `reviewed_at` DATETIME(3) NULL COMMENT '首级通过时刻',
  `approver_user_id` BIGINT NULL COMMENT '第二级真实批准人',
  `approved_at` DATETIME(3) NULL COMMENT '第二级通过时刻；单级NULL',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '首次提交，用于列表排序',
  `operation_at` DATETIME(3) NOT NULL COMMENT '最近提交/撤回时刻，不被审批/投递覆盖',
  `operator_user_id` BIGINT NULL COMMENT '最近提交/撤回用户，系统NULL',
  `supersedes_approval_id` BIGINT NULL COMMENT '重新申请关联旧单，不复活旧单',
  `active_change_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin GENERATED ALWAYS AS (CASE WHEN state IN ('PENDING_REVIEW','PENDING_APPROVAL') OR (state='APPROVED' AND apply_state IN ('PENDING','UNKNOWN')) THEN change_key ELSE NULL END) STORED COMMENT '待审及通过待生效/未知占用同业务变更槽',
  PRIMARY KEY (`approval_id`),
  UNIQUE INDEX `uk_apr_request_source` (`owner_module`,`source_request_id`),
  UNIQUE INDEX `uk_apr_active_change` (`owner_module`,`active_change_key`),
  INDEX `idx_apr_lab_submit` (`lab_id`,`submitted_at`,`approval_id`),
  INDEX `idx_apr_lab_state` (`lab_id`,`state`,`submitted_at`,`approval_id`),
  INDEX `idx_apr_culture` (`culture_id`,`approval_id`),
  CONSTRAINT `ck_apr_request_versions` CHECK (object_version>=1 AND candidate_version>=1 AND (decision_version IS NULL OR decision_version<=object_version)),
  CONSTRAINT `ck_apr_request_actor` CHECK ((initiator_kind='USER' AND initiator_user_id IS NOT NULL AND initiator_user_id>0) OR (initiator_kind='SYSTEM' AND initiator_user_id IS NULL)),
  CONSTRAINT `ck_apr_request_json` CHECK (JSON_TYPE(policy_snapshot)='OBJECT' AND JSON_TYPE(change_snapshot)='OBJECT' AND JSON_TYPE(initiator_snapshot)='OBJECT'),
  CONSTRAINT `ck_apr_request_stage_actors` CHECK ((reviewer_user_id IS NULL OR initiator_user_id IS NULL OR reviewer_user_id<>initiator_user_id) AND (approver_user_id IS NULL OR initiator_user_id IS NULL OR approver_user_id<>initiator_user_id) AND (reviewer_user_id IS NULL OR approver_user_id IS NULL OR reviewer_user_id<>approver_user_id)),
  CONSTRAINT `ck_apr_request_actor_time` CHECK ((reviewer_user_id IS NULL AND reviewed_at IS NULL OR reviewer_user_id IS NOT NULL AND reviewed_at IS NOT NULL) AND (approver_user_id IS NULL AND approved_at IS NULL OR approver_user_id IS NOT NULL AND approved_at IS NOT NULL)),
  CONSTRAINT `ck_apr_request_state` CHECK ((state IN ('PENDING_REVIEW','PENDING_APPROVAL') AND apply_state='NONE' AND cancel_kind IS NULL AND decision_version IS NULL) OR (state='APPROVED' AND apply_state IN ('PENDING','APPLIED','CONFLICT','FAILED','UNKNOWN') AND cancel_kind IS NULL AND decision_version IS NOT NULL) OR (state='CANCELLED' AND apply_state='NOT_APPLICABLE' AND cancel_kind IS NOT NULL AND cancel_kind IN ('REJECTED','WITHDRAWN','SOURCE_INVALIDATED') AND decision_version IS NOT NULL)),
  CONSTRAINT `ck_apr_request_review_stage` CHECK (state NOT IN ('PENDING_APPROVAL','APPROVED') OR reviewer_user_id IS NOT NULL),
  CONSTRAINT `ck_apr_request_policy` CHECK (COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.reviewMode')),'') IN ('BATCH','PROJECT') AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'') IN ('NONE','BATCH','PROJECT') AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.resolutionRules.differentStageActors')),'')='true'),
  CONSTRAINT `ck_apr_request_stage` CHECK ((state='PENDING_REVIEW' AND reviewer_user_id IS NULL AND approver_user_id IS NULL) OR (state='PENDING_APPROVAL' AND reviewer_user_id IS NOT NULL AND approver_user_id IS NULL AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'') IN ('BATCH','PROJECT')) OR (state='APPROVED' AND reviewer_user_id IS NOT NULL AND ((COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'')='NONE' AND approver_user_id IS NULL) OR (COALESCE(JSON_UNQUOTE(JSON_EXTRACT(policy_snapshot,'$.entry.approveMode')),'') IN ('BATCH','PROJECT') AND approver_user_id IS NOT NULL))) OR (state='CANCELLED' AND approver_user_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

-- Source: docs/详细设计/06-流程审批管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `apr_action` (
`action_id` BIGINT NOT NULL COMMENT '动作主键',
  `approval_id` BIGINT NOT NULL COMMENT '审批单逻辑关联',
  `action_code` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SUBMIT/REVIEW_PASS/APPROVE_PASS/REJECT/WITHDRAW/SOURCE_INVALIDATE/APPLY_RESULT',
  `actor_kind` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'USER/SYSTEM',
  `actor_user_id` BIGINT NULL COMMENT '系统动作NULL',
  `event_key` BINARY(32) NOT NULL COMMENT '规范化用户请求或来源回执身份摘要',
  `request_id` VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '人工UUID；系统来源身份在action_snapshot',
  `before_version` BIGINT UNSIGNED NOT NULL COMMENT 'SUBMIT前为0',
  `after_version` BIGINT UNSIGNED NOT NULL COMMENT '成功后=before+1',
  `before_state` VARCHAR(24) NULL COMMENT 'SUBMIT前NULL',
  `after_state` VARCHAR(24) NOT NULL COMMENT '动作后审批状态',
  `reason` VARCHAR(500) NULL COMMENT '拒绝/撤回必填，其他可空',
  `action_snapshot` JSON NOT NULL COMMENT '身份、权限、前后状态/应用态、源证据及请求摘要',
  `occurred_at` DATETIME(3) NOT NULL COMMENT '稳定服务端操作时刻',
  PRIMARY KEY (`action_id`),
  UNIQUE INDEX `uk_apr_action_event` (`approval_id`,`event_key`),
  INDEX `idx_apr_action_order` (`approval_id`,`occurred_at`,`action_id`),
  CONSTRAINT `ck_apr_action_version` CHECK (after_version=before_version+1),
  CONSTRAINT `ck_apr_action_json` CHECK (JSON_TYPE(action_snapshot)='OBJECT'),
  CONSTRAINT `ck_apr_action_actor` CHECK ((actor_kind='USER' AND actor_user_id IS NOT NULL AND actor_user_id>0 AND request_id IS NOT NULL AND CHAR_LENGTH(request_id)=36) OR (actor_kind='SYSTEM' AND actor_user_id IS NULL)),
  CONSTRAINT `ck_apr_action_reason` CHECK (action_code NOT IN ('REJECT','WITHDRAW','SOURCE_INVALIDATE') OR (reason IS NOT NULL AND CHAR_LENGTH(TRIM(reason)) BETWEEN 1 AND 500)),
  CONSTRAINT `ck_apr_action_code` CHECK (action_code IN ('SUBMIT','REVIEW_PASS','APPROVE_PASS','REJECT','WITHDRAW','SOURCE_INVALIDATE','APPLY_RESULT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

-- Source: docs/详细设计/06-流程审批管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `apr_delivery` (
  `retry_policy_snapshot` JSON NULL COMMENT '首次交付固定退避与预算；旧NULL须受控初始化',
  `escalation_level` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0正常1关注2人工3长期未决',
  `unknown_since` DATETIME(3) NULL COMMENT '首次未知时刻；重试不重置',
  `query_attempts` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '只读对账查询次数',
`delivery_id` BIGINT NOT NULL COMMENT '固定决定交付主键',
  `approval_id` BIGINT NOT NULL COMMENT '审批单逻辑关联',
  `decision_version` BIGINT UNSIGNED NOT NULL COMMENT '冻结最终决定版本',
  `decision_kind` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'APPLY/DISCARD',
  `candidate_hash` BINARY(32) NOT NULL COMMENT '冻结候选SHA256',
  `payload_json` JSON NOT NULL COMMENT 'API11完整不可变决定',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/RETRY/ACKNOWLEDGED/UNKNOWN/CONFLICT/FAILED',
  `attempts` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '技术交付次数',
  `next_attempt_at` DATETIME(3) NULL COMMENT '下一次重试或查询时间',
  `lease_token` VARCHAR(36) NULL COMMENT 'worker租约随机UUID',
  `lease_until` DATETIME(3) NULL COMMENT '租约过期时刻',
  `owner_receipt` JSON NULL COMMENT '最后可核验来源回执，完整历史见操作记录',
  `last_error` VARCHAR(1000) NULL COMMENT '无凭据错误摘要',
  `created_at` DATETIME(3) NOT NULL COMMENT '交付形成时刻',
  `updated_at` DATETIME(3) NOT NULL COMMENT '交付状态更新时刻',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '投递worker CAS版本',
  PRIMARY KEY (`delivery_id`),
  UNIQUE INDEX `uk_apr_delivery_decision` (`approval_id`,`decision_version`),
  INDEX `idx_apr_delivery_due` (`state`,`next_attempt_at`,`delivery_id`),
  CONSTRAINT `ck_apr_delivery_kind` CHECK (decision_kind IN ('APPLY','DISCARD')),
  CONSTRAINT `ck_apr_delivery_state` CHECK (state IN ('PENDING','RETRY','ACKNOWLEDGED','UNKNOWN','CONFLICT','FAILED')),
  CONSTRAINT `ck_apr_delivery_json` CHECK (JSON_TYPE(payload_json)='OBJECT' AND (owner_receipt IS NULL OR JSON_TYPE(owner_receipt)='OBJECT')),
  CONSTRAINT `ck_apr_delivery_ack` CHECK (state<>'ACKNOWLEDGED' OR owner_receipt IS NOT NULL),
  CONSTRAINT `ck_apr_delivery_lease` CHECK ((lease_token IS NULL AND lease_until IS NULL) OR (lease_token IS NOT NULL AND lease_until IS NOT NULL)),
  CONSTRAINT `ck_apr_delivery_version` CHECK (object_version>=1 AND decision_version>=1),
  CONSTRAINT `ck_apr_close_ack_kind` CHECK (state<>'ACKNOWLEDGED' OR (owner_receipt IS NOT NULL AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(owner_receipt,'$.status')),'')=CASE WHEN decision_kind='APPLY' THEN 'APPLIED' ELSE 'DISCARDED' END))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M06流程审批目标表';

-- Source: docs/详细设计/06-流程审批管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `apr_reconciliation` (
  `reconciliation_id` BIGINT NOT NULL COMMENT '对账申请',
  `delivery_id` BIGINT NOT NULL COMMENT '固定原交付',
  `approval_id` BIGINT NOT NULL COMMENT '固定审批',
  `decision_version` BIGINT UNSIGNED NOT NULL COMMENT '决策版本',
  `candidate_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原候选',
  `resolution` VARCHAR(24) NOT NULL COMMENT 'VERIFY_APPLIED/SEAL_NOT_APPLIED',
  `base_delivery_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `evidence_json` JSON NOT NULL COMMENT '原始证据引用及拥有方核对结果',
  `evidence_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '签审绑定摘要',
  `reason` VARCHAR(500) NOT NULL COMMENT '对账原因',
  `submitted_by` BIGINT NOT NULL COMMENT '提交者稳定ID',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '提交时刻；UTC',
  `submit_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户及请求持久键',
  `submit_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '提交正文',
  `reviewed_by` BIGINT NULL COMMENT '复核者稳定ID',
  `reviewed_at` DATETIME(3) NULL COMMENT '复核时刻；UTC',
  `review_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '复核请求持久键',
  `review_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '复核正文',
  `withdraw_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '撤回请求持久键',
  `withdraw_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '撤回原始语义载荷摘要',
  `withdraw_evidence` JSON NULL COMMENT '服务端撤回V1身份、原因及原时刻',
  `withdrawn_at` DATETIME(3) NULL COMMENT '原撤回时刻；UTC',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'SUBMITTED' COMMENT 'SUBMITTED/REJECTED/WITHDRAWN/RESOLVING/RESOLVED/STALE',
  `owner_receipt` JSON NULL COMMENT '最终拥有模块证明',
  `review_evidence` JSON NULL COMMENT '复核身份和原因',
  `resolved_at` DATETIME(3) NULL COMMENT '闭合时刻；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `active_delivery_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state IN ('SUBMITTED','RESOLVING') THEN delivery_id ELSE NULL END) STORED COMMENT '有效交付ID唯一键；仅待处理状态生成，闭合后NULL',
  PRIMARY KEY (`reconciliation_id`),
  UNIQUE KEY `uk_apr_rec_active` (`active_delivery_id`),
  UNIQUE KEY `uk_apr_rec_submit` (`submit_key`),
  UNIQUE KEY `uk_apr_rec_review` (`review_key`),
  UNIQUE KEY `uk_apr_rec_withdraw` (`withdraw_key`),
  KEY `ix_apr_rec_delivery` (`delivery_id`,`reconciliation_id`),
  CONSTRAINT `ck_apr_rec_state` CHECK (state IN ('SUBMITTED','REJECTED','WITHDRAWN','RESOLVING','RESOLVED','STALE')),
  CONSTRAINT `ck_apr_rec_resolution` CHECK (resolution IN ('VERIFY_APPLIED','SEAL_NOT_APPLIED')),
  CONSTRAINT `ck_apr_rec_actor` CHECK (submitted_by>0 AND (reviewed_by IS NULL OR (reviewed_by>0 AND reviewed_by<>submitted_by))),
  CONSTRAINT `ck_apr_rec_ready` CHECK (state NOT IN ('RESOLVING','RESOLVED') OR (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND review_evidence IS NOT NULL)),
  CONSTRAINT `ck_apr_rec_closed` CHECK (state<>'RESOLVED' OR (owner_receipt IS NOT NULL AND resolved_at IS NOT NULL)),
  CONSTRAINT `ck_apr_rec_withdraw` CHECK (
    (state='WITHDRAWN' AND withdraw_key IS NOT NULL AND withdraw_hash IS NOT NULL AND withdraw_evidence IS NOT NULL AND withdrawn_at IS NOT NULL
      AND withdraw_key REGEXP '^[0-9A-Fa-f]{64}$' AND withdraw_hash REGEXP '^[0-9A-Fa-f]{64}$'
      AND JSON_TYPE(withdraw_evidence)='OBJECT'
      AND COALESCE(JSON_TYPE(JSON_EXTRACT(withdraw_evidence,'$.schemaVersion'))='INTEGER' AND JSON_UNQUOTE(JSON_EXTRACT(withdraw_evidence,'$.schemaVersion'))='1',FALSE))
    OR (state<>'WITHDRAWN' AND withdraw_key IS NULL AND withdraw_hash IS NULL AND withdraw_evidence IS NULL AND withdrawn_at IS NULL)),
  CONSTRAINT `ck_apr_rec_json` CHECK (JSON_TYPE(evidence_json)='OBJECT' AND CHAR_LENGTH(TRIM(reason)) BETWEEN 1 AND 500 AND object_version>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='apr_reconciliation 当前设计目标';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_culture_runtime` (
  `handover_id` BIGINT NULL COMMENT '一次核准接续基线；NULL沿原初始量',
`culture_id` BIGINT NOT NULL COMMENT 'M03培养身份',
  `lab_id` BIGINT NOT NULL COMMENT '真实实验室',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `connection_generation` BIGINT UNSIGNED NOT NULL COMMENT '连接成功代次，未连接为0',
  `connection_workflow_id` BIGINT NULL COMMENT '成功连接实例',
  `writer_mode` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SMP/PLC/UNKNOWN',
  `readiness` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'READY/BLOCKED/UNKNOWN',
  `readiness_evidence` JSON NOT NULL COMMENT '设备及计量依赖核准依据；结构见JSON契约',
  `total_feed_grams` DECIMAL(20,6) NOT NULL COMMENT '认可累计培养补入，g',
  `total_withdrawal_grams` DECIMAL(20,6) NOT NULL COMMENT '认可累计取测减少，g',
  `last_ledger_id` BIGINT NULL COMMENT '最后投影账事件',
  `last_calculation_id` BIGINT NULL COMMENT '最近有效理论计算',
  `last_glucose_confirmation_id` BIGINT NULL COMMENT '最近GLC确认',
  `last_lactate_confirmation_id` BIGINT NULL COMMENT '最近LAC确认',
  `plan_barrier_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'OPEN/REPLACING/BLOCKED',
  `plan_barrier_evidence` JSON NULL COMMENT 'M03方案生效屏障来源；结构见JSON契约',
  `runtime_stream_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M07生产侧稳定运行事实流；服务重启或执行器换主不改变',
  `runtime_stream_sequence` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'M07已生产的培养级运行事实最大序号；0表示尚未生产',
  `runtime_last_event_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M07最后已生产事实的sourceEventKey；用于下一事实previousEventKey',
  `created_at` DATETIME(3) NOT NULL COMMENT '建立时间，UTC',
  `updated_at` DATETIME(3) NOT NULL COMMENT '更新时间，UTC',
  PRIMARY KEY (`culture_id`),
  CONSTRAINT `ck_m07_runtime_version` CHECK (object_version>0),
  CONSTRAINT `ck_m07_runtime_writer` CHECK (`writer_mode` IN ('SMP','PLC','UNKNOWN')),
  CONSTRAINT `ck_m07_runtime_totals` CHECK (total_feed_grams>=0 AND total_withdrawal_grams>=0),
  CONSTRAINT `ck_m07_runtime_ready` CHECK (`readiness` IN ('READY','BLOCKED','UNKNOWN')),
  CONSTRAINT `ck_m07_runtime_barrier` CHECK (`plan_barrier_state` IN ('OPEN','REPLACING','BLOCKED')),
  CONSTRAINT `ck_m07_runtime_stream` CHECK ((runtime_stream_sequence=0 AND runtime_stream_id IS NULL AND runtime_last_event_key IS NULL) OR (runtime_stream_sequence>0 AND runtime_stream_id IS NOT NULL AND runtime_last_event_key IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养运行守卫与账本投影';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_workflow_instance` (
`workflow_id` BIGINT NOT NULL COMMENT '实例身份',
  `culture_id` BIGINT NULL COMMENT '培养；实验室级工作流（W06 取样单元液体补充）为空',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `subflow_id` BIGINT NOT NULL COMMENT 'M04二级流程',
  `subflow_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'W01至W08对应稳定流程编码',
  `definition_hash` BINARY(32) NOT NULL COMMENT '固定流程定义，SHA256',
  `definition_snapshot` JSON NOT NULL COMMENT 'M04定义/步骤/图片版本；结构见JSON契约',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'OPEN/IN_PROGRESS/COMPLETED/CANCELLED/NEEDS_RECONCILIATION',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M01请求ID',
  `actor_user_id` BIGINT NOT NULL COMMENT '发起人稳定ID',
  `actor_snapshot` JSON NOT NULL COMMENT '发起身份；结构见JSON契约',
  `selection_snapshot` JSON NOT NULL COMMENT '本实例培养及泵选择、权限证据；结构见JSON契约',
  `started_at` DATETIME(3) NOT NULL COMMENT '开始，UTC',
  `ended_at` DATETIME(3) NULL COMMENT '结束，UTC',
  `application_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NONE/PENDING/APPLIED/CONFLICT/UNKNOWN',
  `created_at` DATETIME(3) NOT NULL COMMENT '建立，UTC',
  `workflow_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '开始培养专用类型；旧工作流NULL',
  `page_session_id` BIGINT NULL COMMENT '开始培养页面会话',
  `batch_id` BIGINT NULL COMMENT '小试整组身份，等于页面会话ID；中试NULL',
  `business_date` DATE NULL COMMENT '冻结上海业务日',
  `deadline_at` DATETIME(3) NULL COMMENT '冻结次日零点UTC时刻',
  `active_start_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND state IN ('OPEN','IN_PROGRESS','NEEDS_RECONCILIATION') THEN culture_id ELSE NULL END) STORED COMMENT '未安全闭合尝试独占培养',
  `completed_start_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND state='COMPLETED' THEN culture_id ELSE NULL END) STORED COMMENT '每培养唯一完成槽',
  PRIMARY KEY (`workflow_id`),
  UNIQUE KEY `uk_m07_start_active` (`active_start_culture_id`),
  UNIQUE KEY `uk_m07_start_completed` (`completed_start_culture_id`),
  KEY `idx_m07_start_session` (`page_session_id`,`workflow_id`),
  KEY `idx_m07_start_batch` (`batch_id`,`workflow_id`),
  CONSTRAINT `ck_m07_start_kind` CHECK (workflow_kind IS NULL OR (workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT') AND culture_id IS NOT NULL AND page_session_id IS NOT NULL AND business_date IS NOT NULL AND deadline_at IS NOT NULL AND ((workflow_kind='START_CULTURE_SMALL' AND batch_id IS NOT NULL AND batch_id=page_session_id) OR (workflow_kind='START_CULTURE_PILOT' AND batch_id IS NULL)))),
  CONSTRAINT `ck_m07_start_applied` CHECK (workflow_kind IS NULL OR state<>'COMPLETED' OR application_state='APPLIED'),
  UNIQUE KEY `uk_m07_flow_request` (`request_id`,`culture_id`,`subflow_code`),
  KEY `idx_m07_flow_culture` (`culture_id`,`started_at`),
  KEY `idx_m07_flow_lab_state` (`lab_id`,`state`,`workflow_id`),
  CONSTRAINT `ck_m07_flow_state` CHECK (`state` IN ('OPEN','IN_PROGRESS','COMPLETED','CANCELLED','NEEDS_RECONCILIATION')),
  CONSTRAINT `ck_m07_flow_version` CHECK (object_version>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='补液工作流实例';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_workflow_step` (
`step_instance_id` BIGINT NOT NULL COMMENT '运行步骤',
  `workflow_id` BIGINT NOT NULL COMMENT '父实例',
  `definition_step_id` BIGINT NOT NULL COMMENT 'M04步骤ID',
  `step_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定步骤码',
  `step_order` INT UNSIGNED NOT NULL COMMENT '固定顺序',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PENDING/IN_PROGRESS/COMPLETED/SKIPPED/CANCELLED/UNKNOWN',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `form_snapshot` JSON NOT NULL COMMENT '该步骤类型化表单及前后对照；结构见JSON契约',
  `completion_evidence` JSON NULL COMMENT '完成/跳过/设备证据；结构见JSON契约',
  `actor_user_id` BIGINT NULL COMMENT '步骤操作者',
  `started_at` DATETIME(3) NULL COMMENT '开始，UTC',
  `ended_at` DATETIME(3) NULL COMMENT '结束，UTC',
  PRIMARY KEY (`step_instance_id`),
  UNIQUE KEY `uk_m07_step_order` (`workflow_id`,`step_order`),
  CONSTRAINT `ck_m07_step_state` CHECK (`state` IN ('PENDING','IN_PROGRESS','COMPLETED','SKIPPED','CANCELLED','UNKNOWN')),
  CONSTRAINT `ck_m07_step_order` CHECK (step_order>0 AND object_version>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='工作流步骤事实';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_material_session` (
`session_id` BIGINT NOT NULL COMMENT '本次装载身份',
  `culture_id` BIGINT NULL COMMENT '服务培养；W06实验室级采样液瓶为空',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '具体通道键',
  `physical_item_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '物理袋瓶标识，不是型号ID',
  `material_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'FEED_BAG/FEED_BOTTLE/SAMPLE_BOTTLE/WASTE_BOTTLE',
  `medium_id` BIGINT NULL COMMENT '培养基',
  `resource_snapshot` JSON NOT NULL COMMENT '模型/容量/皮重/单位及来源版本；结构见JSON契约',
  `initial_grams` DECIMAL(20,6) NOT NULL COMMENT '本次实际初始装载量，g',
  `consumed_grams` DECIMAL(20,6) NOT NULL COMMENT '认可物料消耗投影，g',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/CLOSED/UNKNOWN',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `active_slot` TINYINT GENERATED ALWAYS AS (CASE WHEN state IN ('ACTIVE','UNKNOWN') THEN 1 ELSE NULL END) STORED COMMENT '未闭合通道唯一槽',
  `opened_by` BIGINT NOT NULL COMMENT '装载操作者',
  `workflow_id` BIGINT NOT NULL COMMENT '来源工作流',
  `opened_at` DATETIME(3) NOT NULL COMMENT '装载时间，UTC',
  `closed_at` DATETIME(3) NULL COMMENT '闭合时间，UTC',
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `uk_m07_material_channel` (`resource_key`,`active_slot`),
  UNIQUE KEY `uk_m07_material_physical` (`physical_item_key`,`active_slot`),
  CONSTRAINT `ck_m07_material_state` CHECK (`state` IN ('ACTIVE','CLOSED','UNKNOWN')),
  CONSTRAINT `ck_m07_material_amount` CHECK (initial_grams>=0 AND consumed_grams>=0 AND object_version>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='物理袋瓶装载会话';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_manual_result` (
`manual_result_id` BIGINT NOT NULL COMMENT '手工候选ID',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `sample_no` VARCHAR(100) NOT NULL COMMENT '原文样品号',
  `sample_reservation_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '跨M05全局样品号占号证据',
  `position_text` VARCHAR(100) NOT NULL COMMENT '位置',
  `completed_at` DATETIME(3) NOT NULL COMMENT '填写的检测完成时刻，UTC',
  `items_snapshot` JSON NOT NULL COMMENT '项目ID/简称/单位/结果/稀释1；结构见JSON契约',
  `content_hash` BINARY(32) NOT NULL COMMENT '候选内容，SHA256',
  `created_by` BIGINT NOT NULL COMMENT '登记人',
  `created_at` DATETIME(3) NOT NULL COMMENT '登记时间，UTC',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求ID',
  PRIMARY KEY (`manual_result_id`),
  UNIQUE KEY `uk_m07_manual_sample` (`sample_no`),
  UNIQUE KEY `uk_m07_manual_request` (`request_id`),
  CONSTRAINT `ck_m07_manual_version` CHECK (object_version>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='残糖确认专属手工检测候选';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_confirmation` (
`confirmation_id` BIGINT NOT NULL COMMENT '确认ID',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `business_date` DATE NOT NULL COMMENT '上海检测/确认业务日',
  `analyte_kind` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'GLUCOSE/LACTATE',
  `source_kind` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M05/MANUAL',
  `source_id` BIGINT NOT NULL COMMENT '结果或手工候选ID',
  `source_version` BIGINT UNSIGNED NOT NULL COMMENT '精确源版本',
  `item_id` BIGINT NOT NULL COMMENT '精确项目项身份',
  `source_snapshot` JSON NOT NULL COMMENT '值/项目/单位/状态及可信来源证据；结构见JSON契约',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'COUNTDOWN/CONFIRMED/CANCELLED/INVALIDATED',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `actor_user_id` BIGINT NOT NULL COMMENT '发起确认人',
  `selected_at` DATETIME(3) NOT NULL COMMENT '点击确认，UTC',
  `deadline_at` DATETIME(3) NOT NULL COMMENT '60秒服务器截止，UTC',
  `confirmed_at` DATETIME(3) NULL COMMENT '生效时刻，UTC',
  `invalid_reason` VARCHAR(500) NULL COMMENT '失效/取消原因',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求ID',
  `active_slot` TINYINT GENERATED ALWAYS AS (CASE WHEN state IN ('COUNTDOWN','CONFIRMED') THEN 1 ELSE NULL END) STORED COMMENT '本日每类最多一个倒计时或已确认',
  PRIMARY KEY (`confirmation_id`),
  UNIQUE KEY `uk_m07_confirmation_daily` (`culture_id`,`business_date`,`analyte_kind`,`active_slot`),
  UNIQUE KEY `uk_m07_confirmation_request` (`request_id`),
  CONSTRAINT `ck_m07_confirmation_state` CHECK (`state` IN ('COUNTDOWN','CONFIRMED','CANCELLED','INVALIDATED')),
  CONSTRAINT `ck_m07_confirmation_kind` CHECK (`analyte_kind` IN ('GLUCOSE','LACTATE')),
  CONSTRAINT `ck_m07_confirmation_deadline` CHECK (deadline_at=TIMESTAMPADD(SECOND,60,selected_at)),
  CONSTRAINT `ck_m07_confirmation_time` CHECK ((state='CONFIRMED' AND confirmed_at IS NOT NULL) OR (state IN ('COUNTDOWN','CANCELLED') AND confirmed_at IS NULL) OR state='INVALIDATED')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='按培养日和指标类确认';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_calculation` (
`calculation_id` BIGINT NOT NULL COMMENT '计算ID',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `task_id` BIGINT NULL COMMENT '关联任务',
  `execution_id` BIGINT NULL COMMENT '执行',
  `purpose` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PREVIEW/GENERATE/EXECUTE/SETTLE/DAY_START',
  `algorithm_version` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '算法版本',
  `input_snapshot` JSON NOT NULL COMMENT '完整CalculationInput；结构见JSON契约',
  `input_hash` BINARY(32) NOT NULL COMMENT '输入规范内容，SHA256',
  `output_snapshot` JSON NOT NULL COMMENT '完整CalculationOutput及量纲推导；结构见JSON契约',
  `outcome` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'VALID/NOT_NEEDED/BLOCKED/INVALID',
  `business_date` DATE NOT NULL COMMENT '上海业务日',
  `calculated_at` DATETIME(3) NOT NULL COMMENT '计算时间，UTC',
  `source_event_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '不可重复来源身份',
  PRIMARY KEY (`calculation_id`),
  UNIQUE KEY `uk_m07_calculation_source` (`source_event_key`,`purpose`),
  KEY `idx_m07_calculation_culture` (`culture_id`,`calculated_at`),
  CONSTRAINT `ck_m07_calc_purpose` CHECK (`purpose` IN ('PREVIEW','GENERATE','EXECUTE','SETTLE','DAY_START')),
  CONSTRAINT `ck_m07_calc_outcome` CHECK (`outcome` IN ('VALID','NOT_NEEDED','BLOCKED','INVALID'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变计算快照';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_task` (
`task_id` BIGINT NOT NULL COMMENT '任务身份，待审新单也预分配',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `project_id` BIGINT NOT NULL COMMENT '真实项目',
  `batch_id` BIGINT NOT NULL COMMENT '真实批次',
  `task_type` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'FEEDING/SUGAR',
  `source_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PLAN_FIXED/PLAN_RULE/USER/COPY/ERROR_SUPPLEMENT',
  `parent_task_id` BIGINT NULL COMMENT '异常补充或复制来源',
  `business_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PENDING_REVIEW/PENDING_APPROVAL/READY/REPAIR_PENDING_REVIEW/EXECUTING/ERROR/ERROR_HANDLED/EXECUTED/CANCELLED/DAY_CANCELLED/PAUSED',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `admitted` TINYINT NOT NULL COMMENT '已生效准入0/1',
  `scheduler_held` TINYINT NOT NULL COMMENT '候选/来源阻断0/1',
  `planned_at` DATETIME(3) NOT NULL COMMENT '计划时间，UTC',
  `planned_date` DATE NOT NULL COMMENT '计划上海业务日',
  `started_at` DATETIME(3) NULL COMMENT '首次物理开始，UTC',
  `ended_at` DATETIME(3) NULL COMMENT '结束，UTC',
  `plan_snapshot_id` BIGINT NOT NULL COMMENT 'M03固定方案',
  `plan_snapshot_version` BIGINT UNSIGNED NOT NULL COMMENT '方案版本',
  `plan_hash` BINARY(32) NOT NULL COMMENT '精确方案内容，SHA256',
  `rule_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '固定规则ID',
  `task_spec` JSON NOT NULL COMMENT 'TaskSpec完整参数与来源；结构见JSON契约',
  `material_session_id` BIGINT NULL COMMENT '实际开始时绑定装载会话',
  `current_candidate_id` BIGINT NULL COMMENT '未闭合变更',
  `current_execution_id` BIGINT NULL COMMENT '当前执行尝试',
  `calculation_id` BIGINT NULL COMMENT '实际目标计算',
  `target_grams` DECIMAL(20,6) NULL COMMENT '执行固定目标，g',
  `actual_grams` DECIMAL(20,6) NULL COMMENT '已认可实际量投影，g',
  `settlement_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NONE/PROVISIONAL/CONFIRMED/NEEDS_RECONCILIATION',
  `creation_key` BINARY(32) NOT NULL COMMENT '稳定任务创建身份，SHA256',
  `created_by` BIGINT NULL COMMENT '人工来源操作者，系统为空',
  `modified_by` BIGINT NULL COMMENT '最近人工修改人',
  `created_at` DATETIME(3) NOT NULL COMMENT '创建，UTC',
  `modified_at` DATETIME(3) NOT NULL COMMENT '更新，UTC',
  `reason` VARCHAR(1000) NULL COMMENT '创建/最近修改原因',
  PRIMARY KEY (`task_id`),
  UNIQUE KEY `uk_m07_task_creation` (`creation_key`),
  KEY `idx_m07_task_queue` (`culture_id`,`planned_date`,`planned_at`,`task_id`),
  KEY `idx_m07_task_lab_state` (`lab_id`,`business_state`,`planned_at`),
  CONSTRAINT `ck_m07_task_type` CHECK (`task_type` IN ('FEEDING','SUGAR')),
  CONSTRAINT `ck_m07_task_state` CHECK (`business_state` IN ('PENDING_REVIEW','PENDING_APPROVAL','READY','REPAIR_PENDING_REVIEW','EXECUTING','ERROR','ERROR_HANDLED','EXECUTED','CANCELLED','DAY_CANCELLED','PAUSED')),
  CONSTRAINT `ck_m07_task_flags` CHECK (admitted IN (0,1) AND scheduler_held IN (0,1) AND object_version>0),
  CONSTRAINT `ck_m07_task_amount` CHECK ((target_grams IS NULL OR target_grams>0) AND (actual_grams IS NULL OR actual_grams>=0)),
  CONSTRAINT `ck_m07_task_settlement` CHECK (`settlement_state` IN ('NONE','PROVISIONAL','CONFIRMED','NEEDS_RECONCILIATION'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='补料补糖业务任务';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_task_candidate` (
`candidate_id` BIGINT NOT NULL COMMENT '候选ID',
  `task_id` BIGINT NOT NULL COMMENT '目标预分配或已有任务',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `action_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CREATE/UPDATE/CANCEL/ERROR_SUPPLEMENT/RECOVER_SOURCE',
  `candidate_version` BIGINT UNSIGNED NOT NULL COMMENT '候选版本，从1',
  `expected_target_version` BIGINT UNSIGNED NOT NULL COMMENT '新增0，已有精确版本',
  `before_snapshot` JSON NULL COMMENT '变更前或新增null；结构见JSON契约',
  `after_snapshot` JSON NOT NULL COMMENT '精确候选内容；结构见JSON契约',
  `candidate_hash` BINARY(32) NOT NULL COMMENT '候选内容，SHA256',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PREPARED/PENDING/APPLIED/REJECTED/WITHDRAWN/INVALIDATED/CONFLICT/UNKNOWN',
  `approval_id` BIGINT NULL COMMENT 'M06审批，无需审批为空',
  `decision_version` BIGINT UNSIGNED NULL COMMENT '固定最终决定版本',
  `decision_snapshot` JSON NULL COMMENT 'M06决定或直接政策证据；结构见JSON契约',
  `application_receipt` JSON NULL COMMENT '目标版本/结果/生效证据；结构见JSON契约',
  `source_request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源稳定请求',
  `created_at` DATETIME(3) NOT NULL COMMENT '提交，UTC',
  `applied_at` DATETIME(3) NULL COMMENT '实际生效，UTC',
  `active_slot` TINYINT GENERATED ALWAYS AS (CASE WHEN state IN ('PREPARED','PENDING','UNKNOWN') THEN 1 ELSE NULL END) STORED COMMENT '一个任务至多一个活动候选',
  PRIMARY KEY (`candidate_id`),
  UNIQUE KEY `uk_m07_candidate_task` (`task_id`,`active_slot`),
  UNIQUE KEY `uk_m07_candidate_request` (`source_request_id`),
  UNIQUE KEY `uk_m07_candidate_approval` (`approval_id`),
  CONSTRAINT `ck_m07_candidate_action` CHECK (`action_kind` IN ('CREATE','UPDATE','CANCEL','ERROR_SUPPLEMENT','RECOVER_SOURCE')),
  CONSTRAINT `ck_m07_candidate_state` CHECK (`state` IN ('PREPARED','PENDING','APPLIED','REJECTED','WITHDRAWN','INVALIDATED','CONFLICT','UNKNOWN')),
  CONSTRAINT `ck_m07_candidate_version` CHECK (candidate_version>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='审批候选与决定应用证据';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_generation` (
`generation_id` BIGINT NOT NULL COMMENT '生成身份',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `plan_snapshot_id` BIGINT NOT NULL COMMENT '固定方案',
  `rule_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定规则',
  `business_date` DATE NOT NULL COMMENT '上海业务日',
  `generation_key` BINARY(32) NOT NULL COMMENT '生成业务身份，SHA256',
  `evaluation_hash` BINARY(32) NOT NULL COMMENT '本次输入及前置集合，SHA256',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'BLOCKED/NOT_NEEDED/CREATED/INVALIDATED',
  `evaluation_snapshot` JSON NOT NULL COMMENT '确认组/前置任务/阈值及原因；结构见JSON契约',
  `task_id` BIGINT NULL COMMENT '已创建任务',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `evaluated_at` DATETIME(3) NOT NULL COMMENT '本次评估，UTC',
  `next_check_at` DATETIME(3) NULL COMMENT '下次允许评估，UTC',
  PRIMARY KEY (`generation_id`),
  UNIQUE KEY `uk_m07_generation` (`generation_key`),
  KEY `idx_m07_generation_due` (`state`,`next_check_at`),
  CONSTRAINT `ck_m07_generation_state` CHECK (`state` IN ('BLOCKED','NOT_NEEDED','CREATED','INVALIDATED')),
  CONSTRAINT `ck_m07_generation_created` CHECK (state<>'CREATED' OR task_id IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='规则评估及防重记录';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_execution` (
`execution_id` BIGINT NOT NULL COMMENT '执行身份',
  `task_id` BIGINT NULL COMMENT '任务，预填充为空',
  `step_instance_id` BIGINT NULL COMMENT '工作流步骤，任务为空',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `attempt_no` INT UNSIGNED NOT NULL COMMENT '同一业务对象尝试序号',
  `physical_phase` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NOT_STARTED/STARTING/CALIBRATING/HIGH/LOW/PAUSE_REQUESTED/PAUSED/STOPPING/STOPPED/UNKNOWN',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `execution_spec` JSON NOT NULL COMMENT '固定ExecutionSpec及设备能力；结构见JSON契约',
  `spec_hash` BINARY(32) NOT NULL COMMENT '执行规格，SHA256',
  `target_grams` DECIMAL(20,6) NOT NULL COMMENT '固定目标，g',
  `confirmed_grams` DECIMAL(20,6) NOT NULL COMMENT '认可累计实际量，g',
  `active_milliseconds` BIGINT UNSIGNED NOT NULL COMMENT '累计有效运行时长',
  `timeout_milliseconds` BIGINT UNSIGNED NOT NULL COMMENT '计算后的本次期限',
  `worker_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '执行器实例',
  `fence` BIGINT UNSIGNED NOT NULL COMMENT '执行域仲裁epoch',
  `current_segment_id` BIGINT NULL COMMENT '当前计量段',
  `stop_reason` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'NORMAL/USER_PAUSE/ERROR/CANCEL/RECOVERY',
  `stop_evidence` JSON NULL COMMENT '实际停止与稳定证据；结构见JSON契约',
  `settlement_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NONE/PROVISIONAL/CONFIRMED/NEEDS_RECONCILIATION',
  `first_start_evidence` JSON NULL COMMENT '真实首次开始及权威源时间证据；独立v1结构见JSON契约，不以调用时刻填充',
  `started_at` DATETIME(3) NULL COMMENT '首次开始，UTC',
  `stopped_at` DATETIME(3) NULL COMMENT '确认停止，UTC',
  `created_at` DATETIME(3) NOT NULL COMMENT '创建，UTC',
  `updated_at` DATETIME(3) NOT NULL COMMENT '更新，UTC',
  PRIMARY KEY (`execution_id`),
  UNIQUE KEY `uk_m07_execution_task` (`task_id`,`attempt_no`),
  UNIQUE KEY `uk_m07_execution_step` (`step_instance_id`,`attempt_no`),
  CONSTRAINT `ck_m07_execution_owner` CHECK ((task_id IS NOT NULL AND step_instance_id IS NULL) OR (task_id IS NULL AND step_instance_id IS NOT NULL)),
  CONSTRAINT `ck_m07_execution_phase` CHECK (`physical_phase` IN ('NOT_STARTED','STARTING','CALIBRATING','HIGH','LOW','PAUSE_REQUESTED','PAUSED','STOPPING','STOPPED','UNKNOWN')),
  CONSTRAINT `ck_m07_execution_amount` CHECK (target_grams>0 AND confirmed_grams>=0 AND attempt_no>0 AND object_version>0),
  CONSTRAINT `ck_m07_execution_timeout` CHECK (timeout_milliseconds>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='物理执行尝试';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_execution_segment` (
`segment_id` BIGINT NOT NULL COMMENT '分段ID',
  `execution_id` BIGINT NOT NULL COMMENT '父执行',
  `segment_no` INT UNSIGNED NOT NULL COMMENT '从1连续递增',
  `material_session_id` BIGINT NOT NULL COMMENT '本段袋瓶',
  `start_readings` JSON NOT NULL COMMENT '供液及反应器初始读数；结构见JSON契约',
  `end_readings` JSON NULL COMMENT '本段末读数；结构见JSON契约',
  `stop_intent` JSON NULL COMMENT '原分段首次停止意图、期限及多原因；独立v1结构见JSON契约',
  `observation_coverage` JSON NULL COMMENT '全原始STOP与采样绑定的观察覆盖；独立v1结构见JSON契约',
  `direction` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CONSUMED_INCREASES/SUPPLY_DECREASES/UNKNOWN',
  `raw_difference_grams` DECIMAL(20,6) NULL COMMENT '保留正负原始差，g',
  `normalized_grams` DECIMAL(20,6) NULL COMMENT '方向核准后的实际量，g',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'OPEN/CLOSED/UNKNOWN',
  `started_at` DATETIME(3) NOT NULL COMMENT '开始，UTC',
  `stopped_at` DATETIME(3) NULL COMMENT '停止，UTC',
  `active_milliseconds` BIGINT UNSIGNED NOT NULL COMMENT '本段运行毫秒',
  `resume_reason` VARCHAR(1000) NULL COMMENT '恢复时必有的上次暂停原因',
  `active_slot` TINYINT GENERATED ALWAYS AS (CASE WHEN state IN ('OPEN','UNKNOWN') THEN 1 ELSE NULL END) STORED COMMENT '每执行至多一个未闭合段',
  PRIMARY KEY (`segment_id`),
  UNIQUE KEY `uk_m07_segment_no` (`execution_id`,`segment_no`),
  UNIQUE KEY `uk_m07_segment_open` (`execution_id`,`active_slot`),
  CONSTRAINT `ck_m07_segment_state` CHECK (`state` IN ('OPEN','CLOSED','UNKNOWN')),
  CONSTRAINT `ck_m07_segment_direction` CHECK (`direction` IN ('CONSUMED_INCREASES','SUPPLY_DECREASES','UNKNOWN')),
  CONSTRAINT `ck_m07_segment_no` CHECK (segment_no>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='暂停恢复计量分段';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_command` (
`command_id` BIGINT NOT NULL COMMENT '稳定命令ID',
  `execution_id` BIGINT NULL COMMENT '任务或预填充执行',
  `step_instance_id` BIGINT NULL COMMENT '模式/服务等工作流来源',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '执行域资源',
  `operation` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SET_AUTO/START/SET_SPEED/STOP/RESTART',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定物理意图请求ID',
  `payload_hash` BINARY(32) NOT NULL COMMENT '命令完整内容，SHA256',
  `parameters` JSON NOT NULL COMMENT '参数和单位，不含凭据；结构见JSON契约',
  `controller_resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin GENERATED ALWAYS AS
    (CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(`parameters`, '$.resourceClaims[0].resourceKey')) REGEXP '^BENCH_CONTROLLER:[1-9][0-9]{0,18}$'
      AND JSON_LENGTH(JSON_EXTRACT(`parameters`, '$.resourceClaims')) = 2
      AND JSON_UNQUOTE(JSON_EXTRACT(`parameters`, '$.resourceClaims[1].resourceKey')) = `resource_key`
      AND `resource_key` LIKE 'PUMP:%'
      THEN JSON_UNQUOTE(JSON_EXTRACT(`parameters`, '$.resourceClaims[0].resourceKey')) ELSE NULL END) STORED
    COMMENT '冻结完整资源声明的首个控制器身份；缺失不推断空闲，型号核准查询索引投影',
  `configuration_revision` BIGINT UNSIGNED NOT NULL COMMENT '固定通讯版本',
  `fence` BIGINT UNSIGNED NOT NULL COMMENT '仲裁代次',
  `adapter_instance_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '适配器实例',
  `device_command_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '底层命令关联',
  `state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PREPARED/INVOKING/ACCEPTED/EXECUTED/FAILED/UNKNOWN',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `attempt_count` INT UNSIGNED NOT NULL COMMENT '传输尝试次数',
  `result_evidence` JSON NULL COMMENT '操作回执/真实回读证据；结构见JSON契约',
  `last_error` VARCHAR(1000) NULL COMMENT '去敏错误',
  `created_at` DATETIME(3) NOT NULL COMMENT '创建，UTC',
  `invoked_at` DATETIME(3) NULL COMMENT '调用开始，UTC',
  `resolved_at` DATETIME(3) NULL COMMENT '结果确认，UTC',
  `next_query_at` DATETIME(3) NULL COMMENT '下次核对，UTC',
  PRIMARY KEY (`command_id`),
  UNIQUE KEY `uk_m07_command_request` (`request_id`),
  KEY `idx_m07_command_recovery` (`state`,`next_query_at`),
  KEY `idx_m07_command_controller` (`controller_resource_key`,`state`),
  KEY `idx_m07_command_identity_coverage` (`state`,`controller_resource_key`),
  CONSTRAINT `ck_m07_command_owner` CHECK (execution_id IS NOT NULL OR step_instance_id IS NOT NULL),
  CONSTRAINT `ck_m07_command_state` CHECK (`state` IN ('PREPARED','INVOKING','ACCEPTED','EXECUTED','FAILED','UNKNOWN')),
  CONSTRAINT `ck_m07_command_operation` CHECK (`operation` IN ('SET_AUTO','START','SET_SPEED','STOP','RESTART')),
  CONSTRAINT `ck_m07_command_evidence` CHECK (state<>'EXECUTED' OR result_evidence IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备物理命令及核对状态';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_resource_guard` (
`resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '类型/身份/通道规范键',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `owner_kind` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'EXECUTION/WORKFLOW',
  `owner_id` BIGINT NULL COMMENT '持有人',
  `fence` BIGINT UNSIGNED NOT NULL COMMENT '永久单调递增，释放不重置',
  `worker_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '当前协调者',
  `lease_until` DATETIME(3) NULL COMMENT '协调租约截止，UTC',
  `physical_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'FREE/HELD/STOPPING/UNKNOWN',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '乐观版本，从1开始',
  `release_evidence` JSON NULL COMMENT '核准停泵/无物理调用证据；结构见JSON契约',
  `updated_at` DATETIME(3) NOT NULL COMMENT '变更，UTC',
  PRIMARY KEY (`resource_key`),
  KEY `idx_m07_guard_lease` (`physical_state`,`lease_until`),
  KEY `idx_m07_guard_owner` (`owner_kind`,`owner_id`,`resource_key`),
  CONSTRAINT `ck_m07_guard_state` CHECK (`physical_state` IN ('FREE','HELD','STOPPING','UNKNOWN')),
  CONSTRAINT `ck_m07_guard_owner` CHECK ((physical_state='FREE' AND owner_id IS NULL AND owner_kind IS NULL) OR (physical_state<>'FREE' AND owner_id IS NOT NULL AND owner_kind IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='跨任务物理资源仲裁';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_execution_sample` (
`sample_id` BIGINT NOT NULL COMMENT '样本ID',
  `execution_id` BIGINT NOT NULL COMMENT '执行',
  `segment_id` BIGINT NOT NULL COMMENT '分段',
  `source_sequence` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '适配器固定序列',
  `sample_hash` BINARY(32) NOT NULL COMMENT '原始样本内容，SHA256',
  `observed_at` DATETIME(3) NOT NULL COMMENT '设备观测，UTC',
  `received_at` DATETIME(3) NOT NULL COMMENT '服务接收，UTC',
  `stage` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '执行阶段',
  `raw_readings` JSON NOT NULL COMMENT '原单位/时间/设备/质量/配置版本；结构见JSON契约',
  `cumulative_grams` DECIMAL(20,6) NULL COMMENT '运行累计量，g',
  `feeding_scale_grams` DECIMAL(20,6) NULL COMMENT '供液秤归一化值，g',
  `reactor_grams` DECIMAL(20,6) NULL COMMENT '反应器净量，g',
  `actual_speed` DECIMAL(20,6) NULL COMMENT '实际速度',
  `requested_speed` DECIMAL(20,6) NULL COMMENT '下发速度',
  `speed_unit` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '核准速度单位或CODE',
  `quality` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'GOOD/STALE/BAD/UNKNOWN',
  PRIMARY KEY (`sample_id`),
  UNIQUE KEY `uk_m07_sample_sequence` (`execution_id`,`source_sequence`),
  KEY `idx_m07_sample_time` (`execution_id`,`observed_at`),
  CONSTRAINT `ck_m07_sample_quality` CHECK (`quality` IN ('GOOD','STALE','BAD','UNKNOWN'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='环控样本与阶段曲线';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_exception_handling` (
`handling_id` BIGINT NOT NULL COMMENT '处理ID',
  `task_id` BIGINT NOT NULL COMMENT '原任务',
  `execution_id` BIGINT NOT NULL COMMENT '原执行',
  `exception_snapshot` JSON NOT NULL COMMENT '原错误/停泵/读数；结构见JSON契约',
  `measured_grams` DECIMAL(20,6) NULL COMMENT '原实测量，g',
  `confirmed_actual_grams` DECIMAL(20,6) NOT NULL COMMENT '人工认可量，g',
  `deficit_pct` DECIMAL(20,6) NOT NULL COMMENT '有符号缺量百分比',
  `cause` VARCHAR(1000) NOT NULL COMMENT '必填异常原因',
  `extra_mode` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NONE/MANUAL/AUTO',
  `extra_grams` DECIMAL(20,6) NULL COMMENT '额外量，g',
  `speed_snapshot` JSON NULL COMMENT '自动子任务泵速；结构见JSON契约',
  `child_task_id` BIGINT NULL COMMENT '自动补充子任务',
  `actor_user_id` BIGINT NOT NULL COMMENT '处理人',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '请求ID',
  `handled_at` DATETIME(3) NOT NULL COMMENT '登记时间，UTC',
  `content_hash` BINARY(32) NOT NULL COMMENT '处理内容，SHA256',
  PRIMARY KEY (`handling_id`),
  UNIQUE KEY `uk_m07_handling_execution` (`execution_id`),
  UNIQUE KEY `uk_m07_handling_request` (`request_id`),
  CONSTRAINT `ck_m07_handling_amount` CHECK (confirmed_actual_grams>=0),
  CONSTRAINT `ck_m07_handling_mode` CHECK ((extra_mode='NONE' AND extra_grams IS NULL AND child_task_id IS NULL) OR (extra_mode='MANUAL' AND extra_grams>0 AND child_task_id IS NULL) OR (extra_mode='AUTO' AND extra_grams>0 AND child_task_id IS NOT NULL AND speed_snapshot IS NOT NULL)),
  CONSTRAINT `ck_m07_handling_threshold` CHECK (extra_mode='NONE' OR deficit_pct>5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变异常处理登记';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_ledger` (
`ledger_id` BIGINT NOT NULL COMMENT '账事件ID',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `entry_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'FEED/WITHDRAWAL/PRIME/MANUAL_FEED/MANUAL_SUPPLEMENT/ADJUSTMENT',
  `source_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'EXECUTION/WORKFLOW/HANDLING/MANUAL/EXTERNAL',
  `source_id` BIGINT NOT NULL COMMENT '来源身份',
  `source_event_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定来源事件键',
  `execution_id` BIGINT NULL COMMENT '执行',
  `material_session_id` BIGINT NULL COMMENT '物料会话',
  `adjusts_ledger_id` BIGINT NULL COMMENT '被更正账',
  `culture_delta_grams` DECIMAL(20,6) NOT NULL COMMENT '培养量带符号变化，g',
  `material_delta_grams` DECIMAL(20,6) NOT NULL COMMENT '物料消耗带符号变化，g',
  `measurement_evidence` JSON NOT NULL COMMENT '实测/人工/来源版本依据；结构见JSON契约',
  `calculation_id` BIGINT NULL COMMENT '结算公式',
  `actor_user_id` BIGINT NULL COMMENT '人工者，系统空',
  `business_date` DATE NOT NULL COMMENT '发生上海业务日',
  `occurred_at` DATETIME(3) NOT NULL COMMENT '业务发生，UTC',
  `recorded_at` DATETIME(3) NOT NULL COMMENT '认可入账，UTC',
  `content_hash` BINARY(32) NOT NULL COMMENT '不可变账内容，SHA256',
  PRIMARY KEY (`ledger_id`),
  UNIQUE KEY `uk_m07_ledger_source` (`source_event_key`),
  KEY `idx_m07_ledger_culture_date` (`culture_id`,`business_date`,`ledger_id`),
  CONSTRAINT `ck_m07_ledger_kind` CHECK (`entry_kind` IN ('FEED','WITHDRAWAL','PRIME','MANUAL_FEED','MANUAL_SUPPLEMENT','ADJUSTMENT')),
  CONSTRAINT `ck_m07_ledger_adjustment` CHECK ((entry_kind='ADJUSTMENT' AND adjusts_ledger_id IS NOT NULL) OR (entry_kind<>'ADJUSTMENT' AND adjusts_ledger_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='认可计量事实及追加更正账';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_event` (
`event_id` BIGINT NOT NULL COMMENT '事件ID',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `culture_id` BIGINT NOT NULL COMMENT '培养',
  `event_type` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定领域事件码',
  `object_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'TASK/WORKFLOW/COMMAND/LEDGER/CONFIRMATION/GENERATION',
  `object_id` BIGINT NOT NULL COMMENT '业务对象',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '发生时对象版本',
  `source_event_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '生产或消费唯一事件键',
  `payload` JSON NOT NULL COMMENT '不可变领域事实/回执/来源；结构见JSON契约',
  `payload_hash` BINARY(32) NOT NULL COMMENT '事件完整内容，SHA256',
  `actor_user_id` BIGINT NULL COMMENT '人工用户或系统空',
  `occurred_at` DATETIME(3) NOT NULL COMMENT '事实发生，UTC',
  `publish_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'LOCAL/PENDING/RETRY/PUBLISHED',
  `publish_attempts` INT UNSIGNED NOT NULL COMMENT '投递次数',
  `next_publish_at` DATETIME(3) NULL COMMENT '下次发布，UTC',
  `published_at` DATETIME(3) NULL COMMENT '代理确认，UTC',
  `last_error` VARCHAR(1000) NULL COMMENT '去敏投递错误',
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uk_m07_event_source` (`source_event_key`),
  KEY `idx_m07_event_outbox` (`publish_state`,`next_publish_at`),
  KEY `idx_m07_event_object` (`object_kind`,`object_id`,`occurred_at`),
  KEY `idx_m07_event_type_scope` (`event_type`,`publish_state`,`object_kind`,`object_id`),
  CONSTRAINT `ck_m07_event_publish` CHECK (`publish_state` IN ('LOCAL','PENDING','RETRY','PUBLISHED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='领域审计及可靠交接事件';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_executor_assignment` (
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '执行器资源键',
  `lab_id` BIGINT NOT NULL COMMENT '所属实验室',
  `executor_id` VARCHAR(128) NOT NULL COMMENT '执行器ID',
  `assignment_epoch` BIGINT UNSIGNED NOT NULL COMMENT '分配纪元；用于并发接管判定',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'DISABLED' COMMENT 'DISABLED/ENABLED/ISOLATED/TRANSFERRING',
  `control_proof` JSON NOT NULL COMMENT '控制入口限制及网关核准证据',
  `transfer_evidence` JSON NULL COMMENT '旧执行器隔离、未决命令及接管核对',
  `updated_by` BIGINT NOT NULL COMMENT '真实维护人',
  `updated_at` DATETIME(3) NOT NULL COMMENT '变更时刻；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`resource_key`),
  CONSTRAINT `ck_m07_assign_state` CHECK (state IN ('DISABLED','ENABLED','ISOLATED','TRANSFERRING')),
  CONSTRAINT `ck_m07_assign_epoch` CHECK (assignment_epoch>0 AND object_version>0 AND JSON_TYPE(control_proof)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='run_executor_assignment 当前设计目标';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_executor_transfer` (
  `transfer_id` BIGINT NOT NULL COMMENT '执行器整组移交批次ID',
  `source_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SHA256(M07_EXECUTOR_TRANSFER+actor+requestId)幂等键',
  `request_hash` BINARY(32) NOT NULL COMMENT '规范请求摘要SHA256',
  `anchor_resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'HTTP路径锚点资源键',
  `lab_id` BIGINT NOT NULL COMMENT '资源组所属实验室',
  `old_executor_id` VARCHAR(128) NOT NULL COMMENT '移交前固定执行器',
  `new_executor_id` VARCHAR(128) NOT NULL COMMENT '移交后固定执行器',
  `group_snapshot` JSON NOT NULL COMMENT 'M02完整资源组成员冻结快照',
  `group_hash` BINARY(32) NOT NULL COMMENT '规范资源组快照SHA256',
  `eligibility_evidence` JSON NOT NULL COMMENT 'M02逐设备授权、隔离及命令对账证据',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'SUBMITTED/REJECTED/APPLIED/UNKNOWN',
  `submitted_by` BIGINT NOT NULL COMMENT '可信提交操作者',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '提交时刻UTC',
  `completed_at` DATETIME(3) NULL COMMENT '终态时刻UTC',
  `rejection_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '受控拒绝码',
  `rejection_reason` VARCHAR(1000) NULL COMMENT '去敏拒绝原因',
  `result_receipt` JSON NULL COMMENT '长期精确移交回执',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '批次版本',
  PRIMARY KEY (`transfer_id`),
  UNIQUE KEY `uk_m07_executor_transfer_source` (`source_key`),
  KEY `idx_m07_executor_transfer_lab_state` (`lab_id`,`state`,`submitted_at`),
  CONSTRAINT `ck_m07_executor_transfer_state` CHECK (`state` IN ('SUBMITTED','REJECTED','APPLIED','UNKNOWN')),
  CONSTRAINT `ck_m07_executor_transfer_json` CHECK (JSON_TYPE(`group_snapshot`)='OBJECT' AND JSON_TYPE(`eligibility_evidence`)='OBJECT'),
  CONSTRAINT `ck_m07_executor_transfer_terminal` CHECK ((`state`='APPLIED' AND `completed_at` IS NOT NULL AND `result_receipt` IS NOT NULL) OR (`state`='REJECTED' AND `completed_at` IS NOT NULL AND `rejection_code` IS NOT NULL) OR (`state` IN ('SUBMITTED','UNKNOWN'))),
  CONSTRAINT `ck_m07_executor_transfer_version` CHECK (`object_version`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='执行器整组移交不可变批次及长期回执';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_executor_transfer_member` (
  `transfer_id` BIGINT NOT NULL COMMENT '所属移交批次',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '资源组成员键',
  `device_ref` JSON NOT NULL COMMENT 'M02冻结设备身份',
  `assignment_epoch_before` BIGINT UNSIGNED NOT NULL COMMENT '移交前归属纪元',
  `object_version_before` BIGINT UNSIGNED NOT NULL COMMENT '移交前归属版本',
  `assignment_epoch_after` BIGINT UNSIGNED NULL COMMENT '移交后归属纪元；仅APPLIED',
  `object_version_after` BIGINT UNSIGNED NULL COMMENT '移交后归属版本；仅APPLIED',
  `executor_id_before` VARCHAR(128) NOT NULL COMMENT '移交前执行器',
  `executor_id_after` VARCHAR(128) NOT NULL COMMENT '目标执行器',
  `state_before` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '移交前归属状态',
  `state_after` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '移交后归属状态；仅APPLIED',
  PRIMARY KEY (`transfer_id`,`resource_key`),
  KEY `idx_m07_executor_transfer_member_resource` (`resource_key`,`transfer_id`),
  CONSTRAINT `ck_m07_executor_transfer_member_versions` CHECK (`assignment_epoch_before`>0 AND `object_version_before`>0 AND ((`assignment_epoch_after` IS NULL AND `object_version_after` IS NULL AND `state_after` IS NULL) OR (`assignment_epoch_after`=`assignment_epoch_before`+1 AND `object_version_after`=`object_version_before`+1 AND `state_after`='ENABLED'))),
  CONSTRAINT `ck_m07_executor_transfer_member_state` CHECK (`state_before`='ISOLATED')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='执行器整组移交成员冻结快照及前后版本';

-- Source: docs/详细设计/07-补液运行与任务执行/10-审阅收尾完整目标表结构.sql
CREATE TABLE `run_legacy_handover` (
  `handover_id` BIGINT NOT NULL COMMENT '交接申请',
  `culture_id` BIGINT NOT NULL COMMENT '核准培养',
  `lab_id` BIGINT NOT NULL COMMENT '实验室',
  `source_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '旧系统与培养及截止点唯一键',
  `cutover_at` DATETIME(3) NOT NULL COMMENT '交接截止；UTC',
  `mapping_snapshot` JSON NOT NULL COMMENT '旧BatchID实际含义及新身份映射',
  `baseline_snapshot` JSON NOT NULL COMMENT '净量累计量物料余额及源水位',
  `baseline_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '冻结基线',
  `evidence_json` JSON NOT NULL COMMENT '现场观测与数据凭据',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'SUBMITTED' COMMENT 'SUBMITTED/APPROVED/REJECTED/STALE',
  `submitted_by` BIGINT NOT NULL COMMENT '提交复核人',
  `submitted_at` DATETIME(3) NOT NULL COMMENT '提交；UTC',
  `reviewed_by` BIGINT NULL COMMENT '第二复核人',
  `reviewed_at` DATETIME(3) NULL COMMENT '批准；UTC',
  `request_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '申请幂等',
  `review_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '决定幂等',
  `application_receipt` JSON NULL COMMENT '一次安装基线回执',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `pending_culture_id` BIGINT GENERATED ALWAYS AS (CASE WHEN state='SUBMITTED' THEN culture_id ELSE NULL END) STORED COMMENT '待交接培养ID唯一键；复核通过后NULL',
  PRIMARY KEY (`handover_id`),
  UNIQUE KEY `uk_m07_handover_source` (`source_key`),
  UNIQUE KEY `uk_m07_handover_pending` (`pending_culture_id`),
  UNIQUE KEY `uk_m07_handover_request` (`request_key`),
  UNIQUE KEY `uk_m07_handover_review` (`review_key`),
  CONSTRAINT `ck_m07_handover_actor` CHECK (reviewed_by IS NULL OR reviewed_by<>submitted_by),
  CONSTRAINT `ck_m07_handover_state` CHECK (state IN ('SUBMITTED','APPROVED','REJECTED','STALE')),
  CONSTRAINT `ck_m07_handover_ready` CHECK (state<>'APPROVED' OR (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND application_receipt IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='run_legacy_handover 当前设计目标';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_mail_config` (
`config_id` bigint NOT NULL COMMENT '配置ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'alarm_mail_default' COMMENT '配置键（系统级单例）',
  `sender_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发件人邮箱',
  `sender_account` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发件人账号',
  `sender_password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发件人密码（加密存储）',
  `platform_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发件平台名称',
  `server_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发件服务器名称',
  `server_port` int NOT NULL COMMENT '发件服务器端口',
  `sms_gateway_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '短信网关地址',
  `sms_secret_key` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '短信密钥',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '启用状态：0启用 1禁用',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `secret_key_version` varchar(64) NULL DEFAULT NULL COMMENT '密文密钥版本；未知禁止投递',
  `active_revision_id` bigint NULL DEFAULT NULL COMMENT '当前配置修订ID',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_alarm_mail_config_key`(`config_key` ASC) USING BTREE,
  CONSTRAINT `ck_m09_close_port` CHECK (server_port BETWEEN 1 AND 65535)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统发件配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_notify_receiver` (
`receiver_id` bigint NOT NULL COMMENT '接收人ID',
  `rule_id` bigint NOT NULL COMMENT '关联通知规则ID',
  `receiver_source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '接收人来源：1-培养相关用户, 2-设备负责人, 3-指定角色',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源ID（source=3时为角色ID）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `stable_source_key` varchar(100) NULL DEFAULT NULL COMMENT '来源稳定键；CULTURE_MEMBER或DEVICE_OWNER或ROLE角色ID',
  PRIMARY KEY (`receiver_id`) USING BTREE,
  INDEX `idx_receiver_rule`(`rule_id` ASC) USING BTREE,
  CONSTRAINT `ck_m09_close_receiver_source` CHECK (receiver_source IN ('1','2','3') AND (receiver_source<>'3' OR (source_id IS NOT NULL AND source_id>0)))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警通知-接收人关联表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_notify_rule` (
`rule_id` bigint NOT NULL COMMENT '规则ID',
  `rule_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知规则编码',
  `alarm_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警类型（smp_alarm_type）',
  `alarm_module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警模块',
  `notify_mode` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知模式：0-不通知, 1-24h全天候, 2-指定时间段',
  `notify_time_start` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开始时间（HH:mm，仅notify_mode=2时）',
  `notify_time_end` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结束时间（HH:mm，仅notify_mode=2时）',
  `notify_methods` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通知方式，逗号分隔 site/email/sms/sound',
  `notify_limit_count` int NULL DEFAULT NULL COMMENT '通知上限次数（1—98）',
  `notify_interval_min` int NULL DEFAULT NULL COMMENT '每次间隔分钟数（1—1439）',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '启用状态：0启用 1禁用',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `active_revision_id` bigint NULL DEFAULT NULL COMMENT '当前核准规则修订ID',
  `rule_key` varchar(64) NULL DEFAULT NULL COMMENT '稳定规则键；附件M09-R001至R042及扩展规则',
  `window_policy` varchar(30) NULL DEFAULT NULL COMMENT 'NO_CATCH_UP；Q02已确认：时段外触发仅记录，开窗不补发',
  PRIMARY KEY (`rule_id`) USING BTREE,
  INDEX `idx_notify_rule_type`(`alarm_type` ASC) USING BTREE,
  UNIQUE KEY `uk_m09_rule_key` (`rule_key`),
  CONSTRAINT `ck_m09_close_mode` CHECK (notify_mode IN ('0','1','2')),
  CONSTRAINT `ck_m09_close_rule_ready` CHECK (active_revision_id IS NULL OR (window_policy IS NOT NULL AND window_policy='NO_CATCH_UP' AND rule_key IS NOT NULL AND (notify_mode='0' OR (notify_limit_count IS NOT NULL AND notify_limit_count BETWEEN 1 AND 98 AND notify_interval_min IS NOT NULL AND notify_interval_min BETWEEN 1 AND 1439))))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警通知-规则表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_record` (
`alarm_id` bigint NOT NULL COMMENT '告警ID',
  `alarm_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警类型（smp_alarm_type）',
  `alarm_module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警模块（用于通知规则关联）',
  `lab_id` bigint NULL DEFAULT NULL COMMENT '实验室ID',
  `device_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备类型',
  `device_id` bigint NULL DEFAULT NULL COMMENT '设备实例ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `batch_id` bigint NULL DEFAULT NULL COMMENT '批次ID',
  `culture_id` bigint NULL DEFAULT NULL COMMENT '培养ID',
  `sample_id` bigint NULL DEFAULT NULL COMMENT '样品ID',
  `biz_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '业务幂等键',
  `alarm_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警标题',
  `alarm_content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '告警详细描述',
  `trigger_time` datetime NOT NULL COMMENT '告警触发时间',
  `notify_users` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通知用户JSON列表',
  `related_system` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联系统信息',
  `jump_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转链接',
  `handle_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '处理状态：0-未处理, 1-已处理',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `handle_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理人',
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理备注',
  `handle_action` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理动作：1-处理, 2-忽略',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `event_id` bigint NULL DEFAULT NULL COMMENT '首次触发事件ID',
  `condition_key` varchar(64) NULL DEFAULT NULL COMMENT '语义条件SHA256；旧数据未知为NULL',
  `episode_no` bigint NULL DEFAULT NULL COMMENT '同条件告警轮次，从1开始',
  `condition_state` varchar(20) NULL DEFAULT NULL COMMENT 'ACTIVE或RESOLVED；与人工处理独立',
  `resolved_at` datetime(3) NULL DEFAULT NULL COMMENT '可信恢复时间',
  `rule_revision_id` bigint NULL DEFAULT NULL COMMENT '触发时通知规则修订ID',
  `recipient_state` varchar(20) NULL DEFAULT NULL COMMENT 'RESOLVED或KNOWN_EMPTY或UNKNOWN',
  `handled_user_id` bigint NULL DEFAULT NULL COMMENT '人工处理稳定用户ID',
  `row_version` bigint NULL DEFAULT NULL COMMENT 'V2并发版本，从1递增',
  `handle_request_id` varchar(64) NULL DEFAULT NULL COMMENT '最终成功处理请求ID',
  `handle_request_hash` varchar(64) NULL DEFAULT NULL COMMENT '处理请求规范摘要',
  `fact_snapshot` json NULL DEFAULT NULL COMMENT '首次事实白名单快照',
  PRIMARY KEY (`alarm_id`) USING BTREE,
  UNIQUE INDEX `uk_alarm_record_biz_key`(`biz_key` ASC) USING BTREE,
  INDEX `idx_alarm_record_module`(`alarm_type` ASC, `alarm_module` ASC) USING BTREE,
  INDEX `idx_alarm_record_status`(`handle_status` ASC) USING BTREE,
  INDEX `idx_alarm_record_lab`(`lab_id` ASC) USING BTREE,
  INDEX `idx_alarm_record_device`(`device_type` ASC, `device_id` ASC) USING BTREE,
  INDEX `idx_alarm_record_time`(`trigger_time` DESC) USING BTREE,
  UNIQUE KEY `uk_m09_alarm_episode` (`condition_key`,`episode_no`),
  KEY `ix_m09_alarm_scope_time` (`lab_id`,`trigger_time`,`alarm_id`),
  CONSTRAINT `ck_m09_close_handle` CHECK (handle_status IN ('0','1')),
  CONSTRAINT `ck_m09_close_alarm_states` CHECK (row_version IS NULL OR (row_version>=1 AND event_id IS NOT NULL AND episode_no IS NOT NULL AND episode_no>=1 AND condition_state IS NOT NULL AND condition_state IN ('ACTIVE','RESOLVED') AND recipient_state IS NOT NULL AND recipient_state IN ('RESOLVED','KNOWN_EMPTY','UNKNOWN'))),
  CONSTRAINT `ck_m09_close_resolved` CHECK (row_version IS NULL OR condition_state<>'RESOLVED' OR resolved_at IS NOT NULL)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警记录表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `lab_offline_alarm_config` (
`config_id` bigint NOT NULL COMMENT '配置主键',
  `lab_id` bigint NOT NULL COMMENT '实验室主键',
  `culture_mode` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '培养模式（fed_batch/perfusion），字典：SMP培养模式',
  `detect_class` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '检测设备分类（BGA/Vicell/OSMO/Cedex），字典：smp_detect_class',
  `item_id` bigint NOT NULL COMMENT '检测项主键',
  `lower_limit` decimal(18, 4) NULL DEFAULT NULL COMMENT '报警下限',
  `upper_limit` decimal(18, 4) NULL DEFAULT NULL COMMENT '报警上限',
  `enabled` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否启用（0启用 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `culture_id` bigint NULL DEFAULT NULL COMMENT '当前培养ID；旧实验室全局配置不自动扩散',
  `active_key` varchar(64) NULL DEFAULT NULL COMMENT '培养检测类型指标有效键SHA256',
  `revision_id` bigint NULL DEFAULT NULL COMMENT '生效修订ID',
  `row_version` bigint NULL DEFAULT NULL COMMENT 'V2版本，从1递增',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE KEY `uk_m09_offline_scope` (`active_key`),
  CONSTRAINT `ck_m09_close_ver_lab_offline_alarm_config` CHECK (row_version IS NULL OR row_version>=1),
  CONSTRAINT `ck_m09_close_offline_ready` CHECK (row_version IS NULL OR (culture_id IS NOT NULL AND culture_id>0 AND revision_id IS NOT NULL AND active_key IS NOT NULL AND enabled IS NOT NULL AND enabled IN ('0','1') AND (lower_limit IS NULL OR upper_limit IS NULL OR lower_limit<upper_limit)))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-离线告警阈值配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `lab_status_alarm_config` (
`config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `lab_id` bigint NOT NULL COMMENT '实验室ID',
  `alarm_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警类型：consumable-耗材, liquid-液体, sampling_unit-取样单元, feed_unit-补料单元',
  `bottle_id` bigint NULL DEFAULT NULL COMMENT '关联液瓶配置ID（取样/补料单元用）',
  `item_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称（耗材/液体用）',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `default_quantity` decimal(12, 3) NULL DEFAULT NULL COMMENT '默认数量',
  `default_alarm_quantity` decimal(12, 3) NULL DEFAULT NULL COMMENT '默认报警数量',
  `current_quantity` decimal(12, 3) NULL DEFAULT NULL COMMENT '当前数量（耗材/液体存储，取样/补料从bottle_config实时取）',
  `alarm_quantity` decimal(12, 3) NULL DEFAULT NULL COMMENT '报警数量（NULL=不报警）',
  `alarm_operator` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '<' COMMENT '告警操作符：< 当前值<报警值触发, > 当前值>报警值触发',
  `liquid_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '液体类型（取样/补料单元用）',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision_id` bigint NULL DEFAULT NULL COMMENT '当前整组配置修订ID',
  `row_version` bigint NULL DEFAULT NULL COMMENT 'V2版本，从1递增',
  `quantity_source_ref` json NULL DEFAULT NULL COMMENT '可信当前数量来源；未知不得触发',
  `quantity_observed_at` datetime(3) NULL DEFAULT NULL COMMENT '可信当前数量观测时间',
  PRIMARY KEY (`config_id`) USING BTREE,
  INDEX `idx_lab_type`(`lab_id` ASC, `alarm_type` ASC) USING BTREE,
  CONSTRAINT `ck_m09_close_ver_lab_status_alarm_config` CHECK (row_version IS NULL OR row_version>=1),
  CONSTRAINT `ck_m09_close_status_ready` CHECK (row_version IS NULL OR (revision_id IS NOT NULL AND (alarm_quantity IS NULL OR alarm_quantity>=0) AND alarm_operator IS NOT NULL AND alarm_operator='<'))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '状态告警配置表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `sys_notification` (
`notify_id` bigint NOT NULL COMMENT '通知主键',
  `notify_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知类型（offline_alarm/unsigned_warn/timeout_warn/detect_overdue/force_logout/other），字典：SMP通知方式',
  `target_user_id` bigint NULL DEFAULT NULL COMMENT '目标用户主键',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '通知内容',
  `lab_id` bigint NULL DEFAULT NULL COMMENT '关联实验室主键',
  `sample_id` bigint NULL DEFAULT NULL COMMENT '关联检测需求主键',
  `result_id` bigint NULL DEFAULT NULL COMMENT '关联检测结果主键',
  `is_read` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否已读（0未读 1已读）',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `delivery_id` bigint NULL DEFAULT NULL COMMENT '唯一站内信投递ID',
  `event_id` bigint NULL DEFAULT NULL COMMENT '来源事件ID',
  `alarm_id` bigint NULL DEFAULT NULL COMMENT '关联告警ID；普通消息可空',
  `read_actor_id` bigint NULL DEFAULT NULL COMMENT '实际标记已读人稳定ID；管理员与目标人区分',
  `row_version` bigint NULL DEFAULT NULL COMMENT 'V2版本，从1递增',
  PRIMARY KEY (`notify_id`) USING BTREE,
  INDEX `idx_sys_notification_target`(`target_user_id` ASC, `is_read` ASC, `create_time` ASC) USING BTREE,
  INDEX `idx_sys_notification_type`(`notify_type` ASC, `create_time` ASC) USING BTREE,
  INDEX `idx_sys_notification_lab`(`lab_id` ASC, `create_time` ASC) USING BTREE,
  UNIQUE KEY `uk_m09_notification_delivery` (`delivery_id`),
  CONSTRAINT `ck_m09_close_ver_sys_notification` CHECK (row_version IS NULL OR row_version>=1),
  CONSTRAINT `ck_m09_close_notification_read` CHECK (is_read IS NULL OR is_read IN ('0','1')),
  CONSTRAINT `ck_m09_close_notification_ready` CHECK (row_version IS NULL OR (target_user_id IS NOT NULL AND target_user_id>0 AND is_read IS NOT NULL))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统通知表' ROW_FORMAT = DYNAMIC;

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_online_config` (
`config_id` bigint NOT NULL COMMENT '主键',
  `scope_key` varchar(64) NOT NULL COMMENT '设备或培养加设备及指标的SHA256有效键',
  `scope_kind` varchar(20) NOT NULL COMMENT 'DEVICE或CULTURE',
  `lab_id` bigint NOT NULL COMMENT '所属实验室',
  `device_kind` varchar(40) NOT NULL COMMENT 'M02 DeviceKind',
  `device_id` bigint NOT NULL COMMENT '设备稳定ID',
  `culture_id` bigint NULL COMMENT '培养ID；DEVICE时空',
  `item_id` bigint NOT NULL COMMENT 'M02检测项目ID',
  `unit` varchar(30) NOT NULL COMMENT '项目单位快照',
  `set_value` decimal(20,6) NULL COMMENT '设定值',
  `limit_percent` int NULL COMMENT '正整数上下限百分比',
  `lower_limit` decimal(20,6) NULL COMMENT '最终报警下限',
  `upper_limit` decimal(20,6) NULL COMMENT '最终报警上限',
  `stagnant_limit` decimal(20,6) NULL COMMENT '呆滞限值，仅保存待外部逻辑核准',
  `stagnant_seconds` decimal(14,3) NULL COMMENT '呆滞时长秒，仅保存',
  `upper_delay_seconds` decimal(14,3) NULL COMMENT '上限延迟秒，仅保存',
  `lower_delay_seconds` decimal(14,3) NULL COMMENT '下限延迟秒，仅保存',
  `cycle_seconds` decimal(14,3) NULL COMMENT '循环间隔秒，仅保存',
  `cycle_enabled` char(1) NOT NULL COMMENT '0关闭或1开启',
  `methods_json` json NOT NULL COMMENT '保存原页面sms、phone、email、sound选项',
  `enabled` char(1) NOT NULL COMMENT '0关闭或1开启；与旧离线enabled编码不同',
  `evaluation_state` varchar(20) NOT NULL COMMENT 'SAVE_ONLY或VERIFIED',
  `logic_profile_ref` json NULL COMMENT '核准外部告警逻辑及版本；无则不得执行高级字段',
  `revision_id` bigint NOT NULL COMMENT '生效配置修订',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  `updated_by` bigint NOT NULL COMMENT '修改人',
  `updated_at` datetime(3) NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_m09_online_scope` (`scope_key`),
  KEY `ix_m09_online_culture` (`culture_id`,`device_id`),
  CONSTRAINT `ck_m09_close_online_scope` CHECK ((scope_kind='DEVICE' AND culture_id IS NULL) OR (scope_kind='CULTURE' AND culture_id IS NOT NULL AND culture_id>0)),
  CONSTRAINT `ck_m09_close_online_limits` CHECK ((lower_limit IS NULL OR upper_limit IS NULL OR lower_limit<upper_limit) AND (limit_percent IS NULL OR limit_percent>0)),
  CONSTRAINT `ck_m09_close_online_mode` CHECK (enabled IN ('0','1') AND cycle_enabled IN ('0','1') AND evaluation_state IN ('SAVE_ONLY','VERIFIED') AND (evaluation_state<>'VERIFIED' OR logic_profile_ref IS NOT NULL)),
  CONSTRAINT `ck_m09_close_online_time` CHECK ((stagnant_seconds IS NULL OR stagnant_seconds>=0) AND (upper_delay_seconds IS NULL OR upper_delay_seconds>=0) AND (lower_delay_seconds IS NULL OR lower_delay_seconds>=0) AND (cycle_seconds IS NULL OR cycle_seconds>=0) AND (cycle_enabled<>'1' OR (cycle_seconds IS NOT NULL AND cycle_seconds>0))),
  CONSTRAINT `ck_m09_close_ver_online_config` CHECK (row_version>=1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='在线告警现行配置';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_monitor_policy` (
`policy_id` bigint NOT NULL COMMENT '主键',
  `scope_key` varchar(64) NOT NULL COMMENT '设备和培养稳定键',
  `lab_id` bigint NOT NULL COMMENT '实验室',
  `device_kind` varchar(40) NOT NULL COMMENT 'M02设备类型',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `culture_id` bigint NULL COMMENT '培养ID',
  `monitor_mode` varchar(20) NOT NULL COMMENT 'ON或TEMP_OFF或LONG_OFF',
  `remark` varchar(500) NULL COMMENT '备注',
  `revision_id` bigint NOT NULL COMMENT '生效修订ID',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  `updated_by` bigint NOT NULL COMMENT '修改人',
  `updated_at` datetime(3) NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`policy_id`),
  UNIQUE KEY `uk_m09_monitor_scope` (`scope_key`),
  CONSTRAINT `ck_m09_close_monitor` CHECK (monitor_mode IN ('ON','TEMP_OFF','LONG_OFF') AND row_version>=1),
  CONSTRAINT `ck_m09_close_ver_monitor_policy` CHECK (row_version>=1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='泵速异动和台秤移动监控开关';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_config_revision` (
  `application_receipt` JSON NULL COMMENT '当前候选的不可变生效或永久封禁回执',
  `decision_snapshot` JSON NULL COMMENT 'M06最终决定或DIRECT政策证据',
`revision_id` bigint NOT NULL COMMENT '主键',
  `config_kind` varchar(20) NOT NULL COMMENT 'RULE或MAIL或ONLINE或OFFLINE或STATUS或MONITOR',
  `scope_key` varchar(64) NOT NULL COMMENT '配置集合语义键',
  `base_revision_id` bigint NULL COMMENT '修改前修订；首次为NULL',
  `request_key` varchar(64) NOT NULL COMMENT '用户、接口、requestId的SHA256',
  `request_hash` varchar(64) NOT NULL COMMENT '请求规范摘要',
  `content_json` json NOT NULL COMMENT '固定候选内容，不含明文密码',
  `content_hash` varchar(64) NOT NULL COMMENT '固定内容SHA256',
  `revision_state` varchar(20) NOT NULL COMMENT 'PENDING或APPLIED或DISCARDED或CONFLICT',
  `approval_id` bigint NULL COMMENT 'M06审批单ID',
  `created_by` bigint NOT NULL COMMENT '申请人',
  `created_at` datetime(3) NOT NULL COMMENT '创建时间',
  `applied_at` datetime(3) NULL COMMENT '实际生效时间',
  `reason` varchar(500) NULL COMMENT '原因',
  `row_version` bigint NOT NULL COMMENT '状态转换版本',
  PRIMARY KEY (`revision_id`),
  UNIQUE KEY `uk_m09_config_request` (`request_key`),
  KEY `ix_m09_config_scope` (`scope_key`,`created_at`),
  CONSTRAINT `ck_m09_close_revision` CHECK (config_kind IN ('RULE','MAIL','ONLINE','OFFLINE','STATUS','MONITOR') AND revision_state IN ('PENDING','APPLIED','DISCARDED','CONFLICT') AND row_version>=1 AND JSON_TYPE(content_json)='OBJECT' AND (revision_state<>'APPLIED' OR applied_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变配置候选与生效证据';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_event` (
`event_id` bigint NOT NULL COMMENT '主键',
  `source_module` varchar(20) NOT NULL COMMENT 'M01至M09或核准适配器',
  `source_event_key` varchar(64) NOT NULL COMMENT '源事件ID规范SHA256',
  `source_event_id` varchar(200) NOT NULL COMMENT '源事件原ID',
  `source_object_kind` varchar(40) NOT NULL COMMENT '来源对象类型',
  `source_object_id` varchar(100) NOT NULL COMMENT '来源对象稳定ID',
  `source_version` varchar(100) NOT NULL COMMENT '来源事实版本',
  `rule_key` varchar(64) NULL COMMENT '规则键，外部推送可空',
  `event_kind` varchar(30) NOT NULL COMMENT 'TRIGGER或RECOVER或BUSINESS或EXTERNAL_PUSH',
  `condition_key` varchar(64) NULL COMMENT '持续条件语义键',
  `source_sequence` bigint NULL COMMENT '同条件单调序列；持续条件必填',
  `lab_id` bigint NULL COMMENT '实验室',
  `culture_id` bigint NULL COMMENT '培养ID',
  `occurred_at` datetime(3) NOT NULL COMMENT '事实发生时间',
  `received_at` datetime(3) NOT NULL COMMENT '收件时间',
  `payload_json` json NOT NULL COMMENT '版本1白名单事实',
  `payload_hash` varchar(64) NOT NULL COMMENT '相同源ID重复内容校验',
  `process_state` varchar(20) NOT NULL COMMENT 'RECEIVED或APPLIED或IGNORED或BLOCKED',
  `result_ref` json NULL COMMENT '生成告警和投递ID及原因',
  `lease_token` varchar(64) NULL COMMENT '处理租约栅栏token',
  `lease_until` datetime(3) NULL COMMENT '租约截止',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uk_m09_event_source` (`source_module`,`source_event_key`),
  KEY `ix_m09_event_work` (`process_state`,`lease_until`,`event_id`),
  CONSTRAINT `ck_m09_close_event_state` CHECK (process_state IN ('RECEIVED','APPLIED','IGNORED','BLOCKED') AND event_kind IN ('TRIGGER','RECOVER','BUSINESS','EXTERNAL_PUSH')),
  CONSTRAINT `ck_m09_close_condition` CHECK (event_kind NOT IN ('TRIGGER','RECOVER') OR (condition_key IS NOT NULL AND source_sequence IS NOT NULL AND source_sequence>=0)),
  CONSTRAINT `ck_m09_close_event_json` CHECK (JSON_TYPE(payload_json)='OBJECT' AND (result_ref IS NULL OR JSON_TYPE(result_ref)='OBJECT')),
  CONSTRAINT `ck_m09_close_ver_event` CHECK (row_version>=1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='可靠事件收件与处理证据';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_recipient` (
`recipient_id` bigint NOT NULL COMMENT '主键',
  `alarm_id` bigint NOT NULL COMMENT '告警ID',
  `user_id` bigint NOT NULL COMMENT '用户稳定ID',
  `source_json` json NOT NULL COMMENT 'CULTURE_MEMBER、DEVICE_OWNER、ROLE来源并集',
  `display_name` varchar(100) NOT NULL COMMENT '触发时姓名快照',
  `authorization_ref` json NOT NULL COMMENT '当时资格版本，不替代当前鉴权',
  `created_at` datetime(3) NOT NULL COMMENT '解析时间',
  PRIMARY KEY (`recipient_id`),
  UNIQUE KEY `uk_m09_recipient` (`alarm_id`,`user_id`),
  CONSTRAINT `ck_m09_close_recipient` CHECK (user_id>0 AND JSON_TYPE(source_json)='OBJECT' AND COALESCE(JSON_TYPE(JSON_EXTRACT(source_json,'$.sources')),'MISSING')='ARRAY' AND JSON_TYPE(authorization_ref)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='告警稳定接收人与资格快照';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_delivery` (
`delivery_id` bigint NOT NULL COMMENT '主键',
  `delivery_key` varchar(64) NOT NULL COMMENT '事件或告警、轮次、目标、通道SHA256',
  `event_id` bigint NOT NULL COMMENT '来源事件ID',
  `alarm_id` bigint NULL COMMENT '告警ID；外部推送和普通消息可空',
  `round_no` int NOT NULL COMMENT '告警通知轮次，从1开始',
  `target_kind` varchar(20) NOT NULL COMMENT 'USER或SOUND或EXTERNAL',
  `target_key` varchar(100) NOT NULL COMMENT '用户ID或设备身份或外部目的端配置ID',
  `channel` varchar(20) NOT NULL COMMENT 'site或email或sms或sound或external',
  `rule_revision_id` bigint NULL COMMENT '规则修订',
  `config_revision_id` bigint NULL COMMENT '投递配置修订',
  `template_revision` varchar(64) NOT NULL COMMENT '核准模板版本',
  `address_cipher` text NULL COMMENT '邮箱手机号等目标密文；站内无需',
  `address_key_version` varchar(64) NULL COMMENT '目标加密密钥版本',
  `title` varchar(200) NOT NULL COMMENT '脱敏受控标题',
  `content_cipher` mediumtext NULL COMMENT '发送内容密文；无秘密时仍按受控内容存储',
  `content_key_version` varchar(64) NULL COMMENT '内容密钥版本',
  `content_hash` varchar(64) NOT NULL COMMENT '固定发送内容摘要',
  `delivery_state` varchar(20) NOT NULL COMMENT 'PENDING或SENDING或SUCCEEDED或FAILED或UNKNOWN或SKIPPED或CANCELLED',
  `reason_code` varchar(64) NULL COMMENT '失败、跳过或取消原因',
  `scheduled_at` datetime(3) NOT NULL COMMENT '最早发送时间',
  `attempt_count` int NOT NULL COMMENT '实际尝试次数，从0开始',
  `provider_ref` varchar(200) NULL COMMENT '提供商回执ID；接收不等于送达',
  `lease_token` varchar(64) NULL COMMENT '发送租约栅栏token',
  `lease_until` datetime(3) NULL COMMENT '发送租约截止',
  `created_at` datetime(3) NOT NULL COMMENT '建任务时间',
  `updated_at` datetime(3) NOT NULL COMMENT '投影更新时间',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  PRIMARY KEY (`delivery_id`),
  UNIQUE KEY `uk_m09_delivery` (`delivery_key`),
  KEY `ix_m09_delivery_work` (`delivery_state`,`scheduled_at`,`delivery_id`),
  KEY `ix_m09_delivery_target` (`target_kind`,`target_key`,`created_at`),
  CONSTRAINT `ck_m09_close_delivery_state` CHECK (delivery_state IN ('PENDING','SENDING','SUCCEEDED','FAILED','UNKNOWN','SKIPPED','CANCELLED') AND round_no>=1 AND attempt_count>=0 AND row_version>=1),
  CONSTRAINT `ck_m09_close_channel` CHECK ((target_kind='USER' AND channel IN ('site','email','sms')) OR (target_kind='SOUND' AND channel='sound') OR (target_kind='EXTERNAL' AND channel='external')),
  CONSTRAINT `ck_m09_close_delivery_lease` CHECK (((lease_token IS NULL AND lease_until IS NULL) OR (lease_token IS NOT NULL AND lease_until IS NOT NULL)) AND (delivery_state<>'SENDING' OR lease_token IS NOT NULL)),
  CONSTRAINT `ck_m09_close_cipher` CHECK (((address_cipher IS NULL AND address_key_version IS NULL) OR (address_cipher IS NOT NULL AND address_key_version IS NOT NULL)) AND ((content_cipher IS NULL AND content_key_version IS NULL) OR (content_cipher IS NOT NULL AND content_key_version IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='每轮每目标每通道的投递任务';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_delivery_attempt` (
`attempt_id` bigint NOT NULL COMMENT '主键',
  `delivery_id` bigint NOT NULL COMMENT '投递ID',
  `attempt_no` int NOT NULL COMMENT '该投递尝试序号',
  `request_key` varchar(64) NOT NULL COMMENT '自动租约或人工requestId规范键',
  `request_hash` varchar(64) NOT NULL COMMENT '重发请求摘要',
  `actor_user_id` bigint NULL COMMENT '人工操作人；自动为空',
  `provider_idempotency_key` varchar(100) NOT NULL COMMENT '同一投递固定提供商幂等键',
  `started_at` datetime(3) NOT NULL COMMENT '尝试开始',
  `finished_at` datetime(3) NULL COMMENT '结果落库时间',
  `attempt_state` varchar(20) NOT NULL COMMENT 'PENDING或INVOKING或SUCCEEDED或FAILED或UNKNOWN',
  `provider_ref` varchar(200) NULL COMMENT '外部回执',
  `response_code` varchar(64) NULL COMMENT '脱敏错误码',
  `response_summary` varchar(500) NULL COMMENT '白名单摘要，禁止回显秘密',
  `evidence_ref` json NULL COMMENT '查单或回调证明',
  `lease_token` varchar(64) NOT NULL COMMENT '尝试与任务租约一致',
  PRIMARY KEY (`attempt_id`),
  UNIQUE KEY `uk_m09_attempt_no` (`delivery_id`,`attempt_no`),
  UNIQUE KEY `uk_m09_attempt_request` (`request_key`),
  CONSTRAINT `ck_m09_close_attempt` CHECK (attempt_state IN ('PENDING','INVOKING','SUCCEEDED','FAILED','UNKNOWN') AND attempt_no>=1 AND (finished_at IS NULL OR finished_at>=started_at)),
  CONSTRAINT `ck_m09_close_attempt_terminal` CHECK (attempt_state NOT IN ('SUCCEEDED','FAILED') OR finished_at IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知尝试及人工重发证据';

-- Source: docs/详细设计/09-告警与通知管理/10-审阅收尾完整目标表结构.sql
CREATE TABLE `alarm_runtime` (
`runtime_id` bigint NOT NULL COMMENT '主键',
  `condition_key` varchar(64) NOT NULL COMMENT '规则、实体、指标、方向、任务或结果版本语义摘要',
  `latest_source_sequence` bigint NOT NULL COMMENT '已应用最大源序列',
  `episode_no` bigint NOT NULL COMMENT '累计异常周期数；恢复先到可为0',
  `active_alarm_id` bigint NULL COMMENT '本周期告警ID；恢复先到可空',
  `condition_state` varchar(20) NOT NULL COMMENT 'NORMAL或ACTIVE或RESOLVED',
  `first_trigger_at` datetime(3) NULL COMMENT '本周期开始',
  `last_observed_at` datetime(3) NOT NULL COMMENT '最后可信观测时间',
  `resolved_at` datetime(3) NULL COMMENT '恢复时间',
  `rounds_created` int NOT NULL COMMENT '本周期已生成通知轮次',
  `next_round_at` datetime(3) NULL COMMENT '下一轮到期',
  `notify_eligibility` varchar(30) NOT NULL COMMENT 'ELIGIBLE或RECORD_ONLY或STOPPED',
  `rule_revision_id` bigint NULL COMMENT '本周期固定规则修订',
  `row_version` bigint NOT NULL COMMENT '并发版本',
  `updated_at` datetime(3) NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`runtime_id`),
  UNIQUE KEY `uk_m09_runtime_condition` (`condition_key`),
  KEY `ix_m09_runtime_due` (`notify_eligibility`,`next_round_at`),
  CONSTRAINT `ck_m09_close_runtime` CHECK (condition_state IN ('NORMAL','ACTIVE','RESOLVED') AND notify_eligibility IN ('ELIGIBLE','RECORD_ONLY','STOPPED') AND latest_source_sequence>=0 AND episode_no>=0 AND rounds_created>=0 AND row_version>=1),
  CONSTRAINT `ck_m09_close_active` CHECK (condition_state<>'ACTIVE' OR (active_alarm_id IS NOT NULL AND episode_no>=1 AND first_trigger_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='持续条件与重复通知游标';

-- Source: docs/详细设计/00-跨模块审阅收尾/05-审阅收尾完整目标表结构.sql
CREATE TABLE `audit_archive_manifest` (
  `manifest_id` BIGINT NOT NULL COMMENT '归档批次',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '归属模块标识',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'COPYING' COMMENT 'COPYING/VERIFIED/ACTIVE/FAILED',
  `schema_version` INT NOT NULL COMMENT '归档包Schema版本',
  `object_uri` VARCHAR(500) NOT NULL COMMENT '归档对象URI',
  `object_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '加密归档包摘要',
  `key_version` VARCHAR(64) NOT NULL COMMENT '加密密钥版本',
  `row_count` BIGINT UNSIGNED NOT NULL COMMENT '归档行数',
  `byte_count` BIGINT UNSIGNED NOT NULL COMMENT '归档字节数',
  `scope_snapshot` JSON NOT NULL COMMENT '归档范围及在线门禁证据',
  `restore_proof` JSON NULL COMMENT '恢复验证',
  `created_by` BIGINT NOT NULL COMMENT '受控归档维护身份',
  `created_at` DATETIME(3) NOT NULL COMMENT '归档；UTC',
  `activated_at` DATETIME(3) NULL COMMENT '切换；UTC',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`manifest_id`),
  CONSTRAINT `ck_archive_manifest` CHECK (state IN ('COPYING','VERIFIED','ACTIVE','FAILED') AND row_count>0 AND schema_version>0 AND (state<>'ACTIVE' OR (restore_proof IS NOT NULL AND activated_at IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='audit_archive_manifest 当前设计目标';

-- Source: docs/详细设计/00-跨模块审阅收尾/05-审阅收尾完整目标表结构.sql
CREATE TABLE `audit_archive_record` (
  `record_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '模块表与原主键摘要',
  `manifest_id` BIGINT NOT NULL COMMENT '归档批次',
  `owner_module` VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '归属模块标识',
  `table_name` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '源表名',
  `original_key` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '原记录主键值',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '原对象并发版本',
  `object_offset` VARCHAR(128) NOT NULL COMMENT '归档对象偏移量',
  `content_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原行规范摘要',
  `authorization_scope` JSON NOT NULL COMMENT '真实归属与用途定位',
  `occurred_at` DATETIME(3) NOT NULL COMMENT '业务时间；UTC',
  `archived_at` DATETIME(3) NOT NULL COMMENT '归档时间；UTC',
  PRIMARY KEY (`record_key`),
  UNIQUE KEY `uk_archive_original` (`owner_module`,`table_name`,`original_key`),
  KEY `ix_archive_query` (`owner_module`,`table_name`,`occurred_at`,`record_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='audit_archive_record 当前设计目标';

-- Source: docs/详细设计/00-跨模块审阅收尾/05-审阅收尾完整目标表结构.sql
CREATE TABLE `audit_archive_key` (
  `key_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '唯一键命名空间与规范值摘要',
  `key_namespace` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '键命名空间',
  `record_key` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '定位归档原记录',
  `canonical_key` VARBINARY(768) NOT NULL COMMENT '规范键值',
  `created_at` DATETIME(3) NOT NULL COMMENT '形成时间；UTC',
  PRIMARY KEY (`key_hash`),
  KEY `ix_archive_key_record` (`record_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='audit_archive_key 当前设计目标';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation_mapping` (
  `mapping_id` BIGINT NOT NULL COMMENT '映射版本ID',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '设备种类',
  `device_id` BIGINT NOT NULL COMMENT '设备ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准通道；设备级用固定DEVICE',
  `raw_metric_code` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原指标码',
  `mapping_version` BIGINT NOT NULL COMMENT '同设备通道指标递增版本',
  `item_id` BIGINT NOT NULL COMMENT 'dev_detector_item稳定ID',
  `raw_unit` VARCHAR(30) NOT NULL COMMENT '原单位，不得默认g',
  `unit` VARCHAR(30) NOT NULL COMMENT '核准目标单位',
  `profile` JSON NOT NULL COMMENT '固定MappingProfile v1',
  `effective_from` DATETIME(6) NOT NULL COMMENT '生效起点UTC',
  `effective_to` DATETIME(6) NULL COMMENT '半开区间终点；仅受控关闭',
  `approved_by` BIGINT NOT NULL COMMENT '核准操作者',
  `approved_at` DATETIME(6) NOT NULL COMMENT '核准时刻',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '幂等管理请求',
  `request_hash` BINARY(32) NOT NULL COMMENT '规范请求SHA256',
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_obs_mapping_version` (`device_kind`,`device_id`,`channel_code`,`raw_metric_code`,`mapping_version`),
  UNIQUE KEY `uk_obs_mapping_request` (`request_id`),
  CHECK (`mapping_version` > 0 AND (`effective_to` IS NULL OR `effective_to` > `effective_from`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='核准在线指标映射版本，不复制指标主数据';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation_receipt` (
  `receipt_id` BIGINT NOT NULL COMMENT '收件ID',
  `event_key` BINARY(32) NOT NULL COMMENT '规范稳定身份SHA256',
  `identity_json` JSON NOT NULL COMMENT 'Identity v1，碰撞时逐字段比对',
  `packet_hash` BINARY(32) NOT NULL COMMENT '原始内容哈希',
  `raw_payload_ref` VARCHAR(500) NOT NULL COMMENT '受保护持久证据引用，不是任意URL',
  `envelope` JSON NOT NULL COMMENT 'Envelope v1固定叶子，不存凭据',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '经凭据核实的设备种类',
  `device_id` BIGINT NOT NULL COMMENT '经核实设备ID',
  `lab_id` BIGINT NOT NULL COMMENT '接收身份所属实验室快照',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '接入通道',
  `received_at` DATETIME(6) NOT NULL COMMENT '首接收服务端时刻',
  `state` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'QUARANTINED或ARCHIVED；不是告警ACK',
  `reason_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '隔离原因',
  `process_version` BIGINT NOT NULL COMMENT '处理投影CAS版本',
  `next_retry_at` DATETIME(6) NULL COMMENT '补偿计划',
  `lease_token` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '工作进程租约token',
  `lease_until` DATETIME(6) NULL COMMENT '租约UTC',
  `created_at` DATETIME(6) NOT NULL COMMENT '创建时刻',
  PRIMARY KEY (`receipt_id`),
  UNIQUE KEY `uk_obs_receipt_event` (`event_key`),
  KEY `ix_obs_receipt_retry` (`state`,`next_retry_at`,`receipt_id`),
  CHECK (`state` IN ('QUARANTINED','ARCHIVED') AND `process_version` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='原始业务收件证据及处理进度';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation_conflict` (
  `conflict_id` BIGINT NOT NULL COMMENT '冲突ID',
  `receipt_id` BIGINT NOT NULL COMMENT '原始收件',
  `packet_hash` BINARY(32) NOT NULL COMMENT '冲突内容hash',
  `raw_payload_ref` VARCHAR(500) NOT NULL COMMENT '冲突原包受保护引用',
  `identity_json` JSON NOT NULL COMMENT '用于排除hash碰撞',
  `received_at` DATETIME(6) NOT NULL COMMENT '冲突接收时刻',
  `reason_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'EVENT_CONTENT_CONFLICT或IDENTITY_HASH_COLLISION',
  PRIMARY KEY (`conflict_id`),
  UNIQUE KEY `uk_obs_conflict` (`receipt_id`,`packet_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='同身份不同内容证据，不能覆盖首次事实';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation` (
  `observation_id` BIGINT NOT NULL COMMENT '观测版本ID',
  `receipt_id` BIGINT NOT NULL COMMENT '原包收件',
  `process_version` BIGINT NOT NULL COMMENT '与重处理版本对应',
  `mapping_id` BIGINT NULL COMMENT '隔离时可空',
  `item_id` BIGINT NULL COMMENT '未核准指标可空',
  `raw_value` VARCHAR(256) NULL COMMENT '原十进制字符串原精度',
  `raw_unit` VARCHAR(30) NULL COMMENT '原单位',
  `value` DECIMAL(38,12) NULL COMMENT '规范值；超范围不截断',
  `unit` VARCHAR(30) NULL COMMENT '规范单位',
  `observed_at` DATETIME(6) NULL COMMENT '可信UTC；不可信保持空',
  `quality` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源质量',
  `validation_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'VALID或QUARANTINED',
  `reason_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '处理原因',
  `evidence` JSON NOT NULL COMMENT 'ProcessingEvidence v1',
  `processed_at` DATETIME(6) NOT NULL COMMENT '处理时刻',
  `processed_by` BIGINT NULL COMMENT '自动空，人工重处理用户ID',
  PRIMARY KEY (`observation_id`),
  UNIQUE KEY `uk_obs_process` (`receipt_id`,`process_version`),
  KEY `ix_obs_item_time` (`item_id`,`observed_at`,`observation_id`),
  CHECK (`quality` IN ('GOOD','STALE','BAD','UNKNOWN')),
  CHECK (`validation_state` IN ('VALID','QUARANTINED')),
  CHECK (`validation_state` <> 'VALID' OR (`mapping_id` IS NOT NULL AND `item_id` IS NOT NULL AND `observed_at` IS NOT NULL AND `unit` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变规范业务观测及重处理版本';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation_association` (
  `association_id` BIGINT NOT NULL COMMENT '关联证据ID',
  `observation_id` BIGINT NOT NULL COMMENT '观测版本',
  `association_version` BIGINT NOT NULL COMMENT '同观测递增',
  `state` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MATCHED/UNASSOCIATED/AMBIGUOUS/UNKNOWN',
  `binding_revision_id` BIGINT NULL COMMENT 'M03完整关系修订',
  `binding_interval_id` BIGINT NULL COMMENT 'M03匹配区间',
  `culture_id` BIGINT NULL COMMENT '可信培养',
  `project_id` BIGINT NULL COMMENT '可信项目',
  `batch_id` BIGINT NULL COMMENT '可信批次',
  `lab_id` BIGINT NULL COMMENT '发生时实验室',
  `evidence` JSON NOT NULL COMMENT 'AssociationEvidence v1',
  `resolved_at` DATETIME(6) NOT NULL COMMENT '解析时刻',
  PRIMARY KEY (`association_id`),
  UNIQUE KEY `uk_obs_association` (`observation_id`,`association_version`),
  KEY `ix_obs_culture` (`culture_id`,`observation_id`,`association_version`),
  CHECK (`state` IN ('MATCHED','UNASSOCIATED','AMBIGUOUS','UNKNOWN')),
  CHECK (`state` <> 'MATCHED' OR (`binding_revision_id` IS NOT NULL AND `binding_interval_id` IS NOT NULL AND `culture_id` IS NOT NULL AND `project_id` IS NOT NULL AND `batch_id` IS NOT NULL AND `lab_id` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03历史解析结果的版本证据，不是关系权威';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation_current` (
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '设备种类',
  `device_id` BIGINT NOT NULL COMMENT '设备ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '通道',
  `item_id` BIGINT NOT NULL COMMENT '指标',
  `current_observation_id` BIGINT NOT NULL COMMENT '最新合法时刻观测，允许BAD',
  `last_good_observation_id` BIGINT NULL COMMENT '最后GOOD，仅供明确标旧值',
  `observed_at` DATETIME(6) NOT NULL COMMENT '当前值排序时刻',
  `event_key` BINARY(32) NOT NULL COMMENT '同刻确定排序',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'NORMAL或CONFLICT',
  `row_version` BIGINT NOT NULL COMMENT '并发CAS',
  `updated_at` DATETIME(6) NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`device_kind`,`device_id`,`channel_code`,`item_id`),
  CHECK (`state` IN ('NORMAL','CONFLICT') AND `row_version` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='可重建业务当前值指针，绝非唯一历史';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation_outbox` (
  `event_id` BIGINT NOT NULL COMMENT '事件ID',
  `source_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定来源事件幂等键',
  `event_type` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'OBSERVATION_ARCHIVED/ASSOCIATION_REVISED/REPROCESS等',
  `receipt_id` BIGINT NULL COMMENT '收件来源',
  `observation_id` BIGINT NULL COMMENT '观测来源',
  `payload` JSON NOT NULL COMMENT '按事件类型闭合模式',
  `payload_hash` BINARY(32) NOT NULL COMMENT '完整不可变payload哈希',
  `created_at` DATETIME(6) NOT NULL COMMENT '事件时刻',
  `publish_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'LOCAL/PENDING/RETRY/PUBLISHED',
  `attempts` INT UNSIGNED NOT NULL COMMENT '投递次数初始0',
  `next_publish_at` DATETIME(6) NULL COMMENT '下次重试',
  `published_at` DATETIME(6) NULL COMMENT '代理持久确认时间',
  `lease_token` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '领取token',
  `lease_until` DATETIME(6) NULL COMMENT '租约到期',
  `last_error` VARCHAR(1000) NULL COMMENT '脱敏错误',
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uk_obs_outbox_source` (`source_key`),
  KEY `ix_obs_outbox_retry` (`publish_state`,`next_publish_at`,`event_id`),
  CHECK (`publish_state` IN ('LOCAL','PENDING','RETRY','PUBLISHED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='业务可靠事实及补偿审计，独立于M08消费者';

-- Source: docs/详细设计/02-实验室与资源管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `lab_observation_monitor` (
  `condition_key` BINARY(32) NOT NULL COMMENT '稳定告警condition SHA256',
  `identity_json` JSON NOT NULL COMMENT 'MonitorIdentity v1核对碰撞',
  `sequence` BIGINT NOT NULL COMMENT '持久单调事件序列，初始0',
  `evaluation_version` BIGINT NOT NULL COMMENT '每轮评价CAS版本',
  `last_input_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '已处理样本或缺测时间槽身份',
  `last_evaluated_at` DATETIME(6) NULL COMMENT '评价水位，旧样本不得倒退',
  `condition_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'UNKNOWN/NORMAL/ACTIVE',
  `evidence` JSON NOT NULL COMMENT 'MonitorEvidence v1含连续次数及profile',
  `row_version` BIGINT NOT NULL COMMENT '并发CAS',
  `updated_at` DATETIME(6) NOT NULL COMMENT '更新时刻',
  PRIMARY KEY (`condition_key`),
  CHECK (`sequence` >= 0 AND `evaluation_version` >= 0 AND `row_version` > 0),
  CHECK (`condition_state` IN ('UNKNOWN','NORMAL','ACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='非运行在线判定状态；与告警outbox原子提交';

-- Source: docs/详细设计/03-项目与培养管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `res_observation_binding_revision` (
  `revision_id` BIGINT NOT NULL COMMENT '修订ID',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '测量设备种类',
  `device_id` BIGINT NOT NULL COMMENT '测量设备ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准物理通道或DEVICE',
  `revision_no` BIGINT NOT NULL COMMENT '同流递增版本',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '幂等请求，首次版本也受唯一键保护',
  `request_hash` BINARY(32) NOT NULL COMMENT '完整请求hash',
  `evidence_ref` VARCHAR(500) NOT NULL COMMENT '绑定/占用/迁移核准依据',
  `approved_by` BIGINT NULL COMMENT '自动领域事务为空，人工核准必填',
  `created_at` DATETIME(6) NOT NULL COMMENT '提交时刻',
  `reason` VARCHAR(500) NOT NULL COMMENT '绑定变更或纠正理由',
  PRIMARY KEY (`revision_id`),
  UNIQUE KEY `uk_binding_version` (`device_kind`,`device_id`,`channel_code`,`revision_no`),
  UNIQUE KEY `uk_binding_request` (`request_id`),
  CHECK (`revision_no` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备测量通道的完整历史关系修订';

-- Source: docs/详细设计/03-项目与培养管理/OBS-02-业务观测增量建表.sql
CREATE TABLE `res_observation_binding_interval` (
  `interval_id` BIGINT NOT NULL COMMENT '区间ID',
  `revision_id` BIGINT NOT NULL COMMENT '完整修订头',
  `valid_from` DATETIME(6) NOT NULL COMMENT '包含起点',
  `valid_to` DATETIME(6) NULL COMMENT '不含终点，开放末段可空',
  `state` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'MATCHED或UNASSOCIATED',
  `culture_id` BIGINT NULL COMMENT '空闲时空',
  `project_id` BIGINT NULL COMMENT '发生时项目',
  `batch_id` BIGINT NULL COMMENT '发生时批次',
  `lab_id` BIGINT NOT NULL COMMENT '发生时实验室',
  `occupancy_id` BIGINT NULL COMMENT '主占用证据，不代替测点映射',
  `configuration_revision` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准通道/绑定配置版本',
  `evidence_ref` VARCHAR(500) NOT NULL COMMENT '具体绑定或空闲证明',
  PRIMARY KEY (`interval_id`),
  UNIQUE KEY `uk_binding_start` (`revision_id`,`valid_from`),
  KEY `ix_binding_culture` (`culture_id`,`valid_from`,`valid_to`),
  CHECK (`valid_to` IS NULL OR `valid_to` > `valid_from`),
  CHECK ((`state` = 'MATCHED' AND `culture_id` IS NOT NULL AND `project_id` IS NOT NULL AND `batch_id` IS NOT NULL AND `occupancy_id` IS NOT NULL) OR (`state` = 'UNASSOCIATED' AND `culture_id` IS NULL AND `project_id` IS NULL AND `batch_id` IS NULL AND `occupancy_id` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='修订内不可变半开历史区间，显式空闲亦有证据';

-- Source: docs/详细设计/07-补液运行与任务执行/OBS-02-业务观测增量建表.sql
CREATE TABLE `run_observation_monitor` (
  `condition_key` BINARY(32) NOT NULL COMMENT '稳定告警condition SHA256',
  `identity_json` JSON NOT NULL COMMENT 'MonitorIdentity v1核对碰撞',
  `sequence` BIGINT NOT NULL COMMENT '持久单调事件序列，初始0',
  `evaluation_version` BIGINT NOT NULL COMMENT '每轮评价CAS版本',
  `last_input_key` VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '已处理样本或缺测时间槽身份',
  `last_evaluated_at` DATETIME(6) NULL COMMENT '评价水位，旧样本不得倒退',
  `condition_state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'UNKNOWN/NORMAL/ACTIVE',
  `evidence` JSON NOT NULL COMMENT 'MonitorEvidence v1含连续次数及profile',
  `row_version` BIGINT NOT NULL COMMENT '并发CAS',
  `updated_at` DATETIME(6) NOT NULL COMMENT '更新时刻',
  PRIMARY KEY (`condition_key`),
  CHECK (`sequence` >= 0 AND `evaluation_version` >= 0 AND `row_version` > 0),
  CHECK (`condition_state` IN ('UNKNOWN','NORMAL','ACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='运行/连接会话判定状态，不复制M02观测库';

-- Source: sql/ymsw.sql
CREATE TABLE `lab_workflow_node`  (
  `lab_id` bigint NOT NULL COMMENT '实验室ID',
  `node_id` bigint NOT NULL COMMENT '一级工作流节点ID',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`lab_id`, `node_id`) USING BTREE,
  INDEX `idx_lab_workflow_node_node`(`node_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实验室-工作流节点关联表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `sys_downstream_device`  (
  `device_id` bigint NOT NULL COMMENT '下游设备ID',
  `device_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备/平台名称',
  `device_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备类型：sdms / ccmpd / http / other',
  `device_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址或域名',
  `device_port` int NULL DEFAULT NULL COMMENT '端口号',
  `api_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API路径',
  `auth_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '认证方式：none / basic / bearer / oauth',
  `auth_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '认证密钥（加密存储）',
  `timeout` int NULL DEFAULT 30 COMMENT '连接超时时间（秒）',
  `retry_count` int NULL DEFAULT 3 COMMENT '重试次数',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '启用状态：0启用 1禁用',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`device_id`) USING BTREE,
  INDEX `idx_downstream_device_type`(`device_type` ASC) USING BTREE,
  INDEX `idx_downstream_device_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '下游设备管理表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL COMMENT '任务主键',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名，字典：任务分组',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停），字典：任务状态',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL COMMENT '任务日志主键',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名，字典：任务分组',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败），字典：系统状态',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常信息',
  `start_time` datetime NULL DEFAULT NULL COMMENT '执行开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '执行结束时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `sys_notice`  (
  `notice_id` bigint NOT NULL COMMENT '公告主键',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告类型（1通知 2公告），字典：通知类型',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭），字典：通知状态',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知公告表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `sys_notice_read`  (
  `read_id` bigint NOT NULL COMMENT '已读主键',
  `notice_id` bigint NOT NULL COMMENT '公告主键',
  `user_id` bigint NOT NULL COMMENT '用户主键',
  `read_time` datetime NOT NULL COMMENT '阅读时间',
  PRIMARY KEY (`read_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_notice_read_user_notice`(`user_id` ASC, `notice_id` ASC) USING BTREE COMMENT '同一用户同一公告只记录一次'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告已读记录表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL COMMENT '岗位主键',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（0正常 1停用），字典：系统开关',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '岗位信息表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户主键',
  `post_id` bigint NOT NULL COMMENT '岗位主键',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `workflow_node`  (
  `node_id` bigint NOT NULL COMMENT '节点ID',
  `node_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程名称',
  `node_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点编码（系统内部标识，不可修改）',
  `icon_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图标路径',
  `lab_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '实验室类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态：0启用 1禁用',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流程说明',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '显示排序',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`node_id`) USING BTREE,
  UNIQUE INDEX `uk_workflow_node_code`(`node_code` ASC) USING BTREE,
  INDEX `idx_node_lab_type`(`lab_type` ASC) USING BTREE,
  INDEX `idx_node_status`(`status` ASC) USING BTREE,
  INDEX `idx_workflow_node_query`(`del_flag` ASC, `lab_type` ASC, `status` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流一级节点表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `workflow_step`  (
  `step_id` bigint NOT NULL COMMENT '步骤ID',
  `node_id` bigint NOT NULL COMMENT '关联一级节点ID',
  `subflow_id` bigint NULL DEFAULT NULL COMMENT '关联二级流程ID',
  `step_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '二级流程内稳定步骤编码',
  `step_order` int NOT NULL COMMENT '步骤序号（固定，不可调整）',
  `step_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '二级名称',
  `step_description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '说明文字',
  `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '示意图路径',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0未删除 2已删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`step_id`) USING BTREE,
  UNIQUE INDEX `uk_workflow_step_code`(`subflow_id` ASC, `step_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_workflow_step_order`(`subflow_id` ASC, `step_order` ASC) USING BTREE,
  INDEX `idx_step_node_id`(`node_id` ASC) USING BTREE,
  INDEX `idx_step_order`(`node_id` ASC, `step_order` ASC) USING BTREE,
  INDEX `idx_workflow_step_node_subflow`(`node_id` ASC, `subflow_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流二级子步骤表' ROW_FORMAT = DYNAMIC;

-- Source: sql/ymsw.sql
CREATE TABLE `workflow_subflow`  (
  `subflow_id` bigint NOT NULL COMMENT '二级流程ID',
  `node_id` bigint NOT NULL COMMENT '一级节点ID',
  `subflow_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点内稳定编码',
  `subflow_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '二级流程名称',
  `lab_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '适用实验室类型（smp_lab_type字典值）',
  `repeatable` tinyint NOT NULL DEFAULT '0' COMMENT '是否可重复（0不可重复 1可重复）',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '固定排序',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '删除标志（0存在 2删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`subflow_id`) USING BTREE,
  UNIQUE INDEX `uk_workflow_subflow_code`(`node_id` ASC, `subflow_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_workflow_subflow_order`(`node_id` ASC, `sort_order` ASC) USING BTREE,
  INDEX `idx_workflow_subflow_node_del`(`node_id` ASC, `del_flag` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流二级流程表' ROW_FORMAT = DYNAMIC;

-- M05 B2: durable mutation receipts, committed with sample and audit changes.
CREATE TABLE `det_sample_mutation_receipt` (
  `receipt_id` BIGINT NOT NULL COMMENT '持久回执主键',
  `actor_id` BIGINT NOT NULL COMMENT '服务端真实操作者',
  `request_id` CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '可信请求头幂等键',
  `operation_code` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M05-008/009/012/013/029/030',
  `payload_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '公共规范化请求HMAC摘要',
  `detector_id` BIGINT NOT NULL COMMENT '冻结设备读取范围',
  `lab_id` BIGINT NOT NULL COMMENT '冻结实验室读取范围',
  `management_revision` BIGINT UNSIGNED NOT NULL COMMENT '成功提交后的管理版本',
  `result_json` JSON NOT NULL COMMENT '不可变完整回执，包括逐项成功与跳过',
  `scope_json` JSON NOT NULL COMMENT '已授权对象及培养范围，重放时重新鉴权',
  `create_time` DATETIME(3) NOT NULL COMMENT '服务端提交时间UTC',
  PRIMARY KEY (`receipt_id`),
  UNIQUE KEY `uk_m05_sample_receipt_request` (`actor_id`,`request_id`),
  CONSTRAINT `ck_m05_sample_receipt_ids` CHECK (receipt_id>0 AND actor_id>0 AND detector_id>0 AND lab_id>0 AND management_revision>0),
  CONSTRAINT `ck_m05_sample_receipt_action` CHECK (operation_code IN ('M05-008','M05-009','M05-010','M05-011','M05-012','M05-013','M05-029','M05-030')),
  CONSTRAINT `ck_m05_sample_receipt_json` CHECK (JSON_TYPE(result_json)='OBJECT' AND JSON_TYPE(scope_json)='ARRAY')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M05工作台变更持久回执，不自动清理';

-- M02 COM-05：一域一份完整关联锚点；无行不是空闲证明。
CREATE TABLE `lab_communication_usage` (
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '冻结通讯设备种类',
  `device_id` BIGINT NOT NULL COMMENT '真实设备实例ID',
  `lab_id` BIGINT NOT NULL COMMENT '真实实验室ID',
  `configuration_version` BIGINT NOT NULL COMMENT '核验时通讯配置版本',
  `owner_module` VARCHAR(3) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M05或M07事实拥有方',
  `links_json` JSON NOT NULL COMMENT '拥有方核验的完整关联身份集合，不存自报结束状态',
  `adapter_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '独立授权设备适配器',
  `object_version` BIGINT NOT NULL COMMENT '关联登记CAS版本，从1递增',
  `verified_at` DATETIME(6) NOT NULL COMMENT '服务器核验时间UTC',
  PRIMARY KEY (`device_kind`,`device_id`,`lab_id`,`configuration_version`,`owner_module`),
  CONSTRAINT `ck_m02_comm_usage_kind` CHECK (device_kind IN ('DETECTOR','FLOOR_SCALE','DOWNSTREAM_DEVICE')),
  CONSTRAINT `ck_m02_comm_usage_owner` CHECK (owner_module IN ('M05','M07')),
  CONSTRAINT `ck_m02_comm_usage_ids` CHECK (device_id>0 AND lab_id>0 AND configuration_version>0 AND object_version>0),
  CONSTRAINT `ck_m02_comm_usage_links` CHECK (JSON_TYPE(links_json)='ARRAY' AND JSON_LENGTH(links_json)<=1000)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='按配置代次核验的通讯关联登记';

-- 原始签名观测包的受控密文存储；普通接口不暴露密文或密钥。
CREATE TABLE lab_observation_raw_evidence (
  evidence_id BIGINT NOT NULL COMMENT '应用生成的正数证据ID',
  adapter_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '已验签接入适配器身份',
  lab_id BIGINT NOT NULL COMMENT '核准实验室ID',
  device_kind VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '测量设备种类',
  device_id BIGINT NOT NULL COMMENT '核准设备实例ID',
  key_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '部署受控密钥版本，不存密钥',
  nonce BINARY(12) NOT NULL COMMENT 'AES-GCM随机nonce',
  ciphertext MEDIUMBLOB NOT NULL COMMENT '带身份附加认证数据的AES-256-GCM签名包密文',
  packet_hash BINARY(32) NOT NULL COMMENT '解码原始设备报文字节SHA-256',
  created_at DATETIME(6) NOT NULL COMMENT '服务端首次保存时刻UTC',
  PRIMARY KEY (evidence_id),
  CONSTRAINT ck_obs_raw_ids CHECK (evidence_id > 0 AND lab_id > 0 AND device_id > 0),
  CONSTRAINT ck_obs_raw_device_kind CHECK (device_kind IN ('DETECTOR','FLOOR_SCALE','DOWNSTREAM_DEVICE')),
  CONSTRAINT ck_obs_raw_cipher CHECK (OCTET_LENGTH(ciphertext) >= 16)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02受控原始观测证据';

-- Source: docs/详细设计/02-实验室与资源管理/13-最终目标表结构.sql

-- COM-07 immutable load evidence; never a device acceptance or health record.
CREATE TABLE `lab_communication_apply_receipt` (
  `evidence_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '设备修订适配器及规范化回报SHA256',
  `comm_id` BIGINT NOT NULL COMMENT '原通讯配置ID',
  `configuration_revision` BIGINT UNSIGNED NOT NULL COMMENT '回报对应修订',
  `adapter_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '服务端登记实例身份',
  `evidence_json` JSON NOT NULL COMMENT '无秘密加载证据，含原观测UTC时刻',
  `receipt_json` JSON NOT NULL COMMENT '不可变原受理结果',
  `received_at` DATETIME(3) NOT NULL COMMENT '服务端接收时间UTC',
  PRIMARY KEY (`evidence_hash`),
  INDEX `idx_m02_apply_configuration` (`comm_id`,`configuration_revision`),
  CONSTRAINT `ck_m02_apply_receipt_revision` CHECK (`comm_id`>0 AND `configuration_revision`>0),
  CONSTRAINT `ck_m02_apply_receipt_json` CHECK (JSON_TYPE(`evidence_json`)='OBJECT' AND JSON_TYPE(`receipt_json`)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通讯配置加载回报不可变回执';

-- 2026-10-16 已确认：M05私有普通证据原件；不设TTL/删除/覆盖。
CREATE TABLE `det_correction_evidence` (
  `attachment_id` bigint NOT NULL COMMENT 'M05应用生成不可变证据ID',
  `version_no` bigint NOT NULL COMMENT '精确不可变版本；首次为1，不覆盖',
  `result_id` bigint NOT NULL COMMENT '固定所属结果；不可跨结果借用',
  `uploaded_result_version` bigint NOT NULL COMMENT '上传时当前结果版本',
  `display_name` varchar(100) NOT NULL COMMENT '展示名，不含路径或控制字符',
  `content_type` varchar(128) NOT NULL COMMENT '服务端确定的下载媒体类型',
  `size_bytes` bigint NOT NULL COMMENT '原件真实字节数',
  `content_sha256` binary(32) NOT NULL COMMENT '服务端原始字节SHA256',
  `original_bytes` LONGBLOB NOT NULL COMMENT '普通更正证据原件；禁止更新删除和自动到期',
  `uploaded_by` bigint NOT NULL COMMENT '稳定上传人身份',
  `uploaded_at` datetime(6) NOT NULL COMMENT '服务端首次上传时刻UTC',
  `upload_request_id` char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '长期领域上传幂等键',
  `upload_payload_hash` binary(32) NOT NULL COMMENT '规范上传意图摘要，不存原件到审计',
  `committed_management_revision` bigint NOT NULL COMMENT '首次上传成功管理版本，用于长期回放',
  PRIMARY KEY (`attachment_id`,`version_no`),
  UNIQUE KEY `uk_m05_evidence_upload` (`uploaded_by`,`upload_request_id`),
  KEY `ix_m05_evidence_result` (`result_id`,`uploaded_at`,`attachment_id`),
  CONSTRAINT `ck_m05_evidence_identity` CHECK (attachment_id>0 AND version_no>0 AND result_id>0 AND uploaded_result_version>0 AND uploaded_by>0 AND committed_management_revision>0),
  CONSTRAINT `ck_m05_evidence_bytes` CHECK (size_bytes>0 AND OCTET_LENGTH(original_bytes)=size_bytes),
  CONSTRAINT `ck_m05_evidence_name` CHECK (CHAR_LENGTH(TRIM(display_name)) BETWEEN 1 AND 100 AND CHAR_LENGTH(TRIM(content_type))>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M05普通更正不可变原件及长期上传回执';

-- M02 M07-033：共享物理资源组、逐设备运维范围及受信适配器核验事实。
-- 这些表不保存设备凭据；浏览器不得直接写入核验记录。
CREATE TABLE `lab_executor_resource_group` (
  `group_id` BIGINT NOT NULL COMMENT '资源组主键，应用生成',
  `group_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定资源组规范键',
  `lab_id` BIGINT NOT NULL COMMENT '所属实验室',
  `group_revision` BIGINT UNSIGNED NOT NULL COMMENT '成员或控制配置变更递增',
  `group_hash` BINARY(32) NOT NULL COMMENT '规范成员及控制配置摘要SHA256',
  `control_profile` JSON NOT NULL COMMENT '控制方、协议和能力核准引用；不含凭据',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/DISABLED',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  `updated_by_user_id` BIGINT NOT NULL COMMENT '实际维护人',
  `updated_at` DATETIME(3) NOT NULL COMMENT 'UTC修改时间',
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `uk_m02_executor_group_key` (`group_key`),
  KEY `idx_m02_executor_group_lab_state` (`lab_id`,`state`),
  CONSTRAINT `ck_m02_executor_group_state` CHECK (`state` IN ('ACTIVE','DISABLED')),
  CONSTRAINT `ck_m02_executor_group_values` CHECK (`group_revision`>0 AND `object_version`>0 AND JSON_TYPE(`control_profile`)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02共享物理资源组身份及控制配置';

CREATE TABLE `lab_executor_resource_group_member` (
  `group_id` BIGINT NOT NULL COMMENT '所属资源组',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M07稳定资源声明键',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'M02设备实例种类',
  `device_id` BIGINT NOT NULL COMMENT 'M02设备实例ID',
  `channel_key` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '泵位/管路/通道；无则空',
  `member_role` VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'PUMP/SCALE/PIPELINE/CONTROLLER',
  `member_revision` BIGINT UNSIGNED NOT NULL COMMENT '成员映射版本',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/DISABLED',
  PRIMARY KEY (`group_id`,`resource_key`),
  UNIQUE KEY `uk_m02_executor_member_resource` (`resource_key`),
  KEY `idx_m02_executor_member_device` (`device_kind`,`device_id`),
  CONSTRAINT `ck_m02_executor_member_state` CHECK (`state` IN ('ACTIVE','DISABLED')),
  CONSTRAINT `ck_m02_executor_member_values` CHECK (`device_id`>0 AND `member_revision`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02共享物理资源组成员映射';

CREATE TABLE `lab_device_operation_grant` (
  `grant_id` BIGINT NOT NULL COMMENT '逐设备运维授权主键，应用生成',
  `user_id` BIGINT NOT NULL COMMENT '被授权用户',
  `lab_id` BIGINT NOT NULL COMMENT '授权实验室',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '授权设备资源键',
  `permission_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定DEVICE_OPERATE',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/REVOKED',
  `granted_by_user_id` BIGINT NOT NULL COMMENT '实际授权维护人',
  `granted_at` DATETIME(3) NOT NULL COMMENT 'UTC授权时间',
  `expires_at` DATETIME(3) NULL COMMENT 'UTC失效时间；空为未设失效',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`grant_id`),
  UNIQUE KEY `uk_m02_device_operation_grant` (`user_id`,`lab_id`,`resource_key`,`permission_code`),
  KEY `idx_m02_device_operation_grant_lookup` (`lab_id`,`resource_key`,`state`,`expires_at`),
  CONSTRAINT `ck_m02_device_operation_grant_state` CHECK (`state` IN ('ACTIVE','REVOKED')),
  CONSTRAINT `ck_m02_device_operation_grant_code` CHECK (`permission_code`='DEVICE_OPERATE'),
  CONSTRAINT `ck_m02_device_operation_grant_values` CHECK (`user_id`>0 AND `lab_id`>0 AND `object_version`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02逐设备运维授权事实';

CREATE TABLE `lab_device_read_grant` (
  `grant_id` BIGINT NOT NULL COMMENT '逐设备读取授权主键，应用生成',
  `user_id` BIGINT NOT NULL COMMENT '被授权用户',
  `lab_id` BIGINT NOT NULL COMMENT '授权实验室',
  `resource_key` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '授权设备资源键',
  `permission_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定DEVICE_READ',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/REVOKED',
  `granted_by_user_id` BIGINT NOT NULL COMMENT '实际授权维护人',
  `granted_at` DATETIME(3) NOT NULL COMMENT 'UTC授权时间',
  `expires_at` DATETIME(3) NULL COMMENT 'UTC失效时间；空为未设失效',
  `object_version` BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'CAS版本',
  PRIMARY KEY (`grant_id`),
  UNIQUE KEY `uk_m02_device_read_grant` (`user_id`,`lab_id`,`resource_key`,`permission_code`),
  KEY `idx_m02_device_read_grant_lookup` (`lab_id`,`resource_key`,`state`,`expires_at`),
  CONSTRAINT `ck_m02_device_read_grant_state` CHECK (`state` IN ('ACTIVE','REVOKED')),
  CONSTRAINT `ck_m02_device_read_grant_code` CHECK (`permission_code`='DEVICE_READ'),
  CONSTRAINT `ck_m02_device_read_grant_values` CHECK (`user_id`>0 AND `lab_id`>0 AND `object_version`>0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02逐设备读取授权事实；只用于原批次回执恢复读取';

CREATE TABLE `lab_executor_control_verification` (
  `verification_id` BIGINT NOT NULL COMMENT '受信适配器核验主键，应用生成',
  `group_id` BIGINT NOT NULL COMMENT '核验资源组',
  `group_revision` BIGINT UNSIGNED NOT NULL COMMENT '核验对应资源组版本',
  `old_executor_id` VARCHAR(128) NOT NULL COMMENT '待隔离旧执行器',
  `new_executor_id` VARCHAR(128) NOT NULL COMMENT '待绑定新执行器',
  `adapter_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '受信设备适配器身份',
  `evidence_reference` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '外部核验证据稳定引用摘要',
  `evidence_payload` JSON NOT NULL COMMENT '无凭据隔离、停泵、对账、绑定核验证据',
  `old_executor_physically_isolated` TINYINT NOT NULL COMMENT '1仅当旧物理控制入口已失效',
  `commands_reconciled_and_stopped` TINYINT NOT NULL COMMENT '1仅当未决命令核对且设备已停',
  `new_executor_binding_verified` TINYINT NOT NULL COMMENT '1仅当新执行器绑定及旧epoch拒绝已核验',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'VERIFIED/REJECTED/UNKNOWN',
  `verified_at` DATETIME(3) NOT NULL COMMENT '适配器观测UTC时间',
  `expires_at` DATETIME(3) NOT NULL COMMENT '核验有效截止UTC',
  `received_at` DATETIME(3) NOT NULL COMMENT '服务端接收UTC时间',
  `payload_hash` BINARY(32) NOT NULL COMMENT '规范证据摘要SHA256',
  PRIMARY KEY (`verification_id`),
  UNIQUE KEY `uk_m02_executor_verification_evidence` (`evidence_reference`),
  KEY `idx_m02_executor_verification_lookup` (`group_id`,`group_revision`,`old_executor_id`,`new_executor_id`,`state`,`expires_at`),
  CONSTRAINT `ck_m02_executor_verification_state` CHECK (`state` IN ('VERIFIED','REJECTED','UNKNOWN')),
  CONSTRAINT `ck_m02_executor_verification_flags` CHECK ((`old_executor_physically_isolated` IN (0,1)) AND (`commands_reconciled_and_stopped` IN (0,1)) AND (`new_executor_binding_verified` IN (0,1))),
  CONSTRAINT `ck_m02_executor_verification_values` CHECK (`group_revision`>0 AND `expires_at`>=`verified_at` AND JSON_TYPE(`evidence_payload`)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02受信执行器隔离及绑定核验事实';


-- Source: docs/详细设计/07-补液运行与任务执行/SC-01-开始培养表结构.sql
CREATE TABLE `run_start_culture_session` (
  `session_id` BIGINT NOT NULL COMMENT '页面会话；小试同时作为整组身份',
  `lab_id` BIGINT NOT NULL COMMENT '真实实验室',
  `workflow_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'START_CULTURE_SMALL/START_CULTURE_PILOT',
  `actor_user_id` BIGINT NOT NULL COMMENT '会话所属服务端用户',
  `entry_business_date` DATE NOT NULL COMMENT '页面进入上海业务日',
  `deadline_at` DATETIME(3) NOT NULL COMMENT '当日次日零点的UTC时刻，禁止滚动延期',
  `interaction_state` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'ACTIVE/CANCEL_REQUESTED/CLOSED',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '会话与小试组共用CAS版本',
  `current_step` INT UNSIGNED NOT NULL COMMENT '当前步骤1至4',
  `state_json` JSON NOT NULL COMMENT '类型化身份、访问、校验摘要和跳过意图；禁止业务草稿',
  `batch_id` BIGINT NULL COMMENT '小试绑定后=session_id；中试NULL',
  `created_at` DATETIME(3) NOT NULL COMMENT 'UTC',
  `closed_at` DATETIME(3) NULL COMMENT '安全关闭或完成，UTC；未闭合NULL',
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `uk_m07_sc_batch` (`batch_id`),
  KEY `idx_m07_sc_actor` (`actor_user_id`,`lab_id`,`created_at`),
  KEY `idx_m07_sc_deadline` (`interaction_state`,`deadline_at`),
  CONSTRAINT `ck_m07_sc_kind` CHECK (workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT')),
  CONSTRAINT `ck_m07_sc_state` CHECK (interaction_state IN ('ACTIVE','CANCEL_REQUESTED','CLOSED') AND object_version>0 AND current_step BETWEEN 1 AND 4),
  CONSTRAINT `ck_m07_sc_batch` CHECK (batch_id IS NULL OR (workflow_kind='START_CULTURE_SMALL' AND batch_id=session_id)),
  CONSTRAINT `ck_m07_sc_closed` CHECK ((interaction_state='CLOSED' AND closed_at IS NOT NULL AND closed_at>=created_at) OR (interaction_state<>'CLOSED' AND closed_at IS NULL)),
  CONSTRAINT `ck_m07_sc_deadline` CHECK (deadline_at>created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='开始培养页面会话与整组聚合';


-- Source: docs/详细设计/07-补液运行与任务执行/SC-01-开始培养表结构.sql
CREATE TABLE `run_start_culture_receipt` (
  `actor_user_id` BIGINT NOT NULL COMMENT '原请求操作者，隔离查询及幂等命名空间',
  `request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原写请求ID',
  `lab_id` BIGINT NOT NULL COMMENT '原实验室',
  `workflow_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原开始培养类型',
  `session_id` BIGINT NOT NULL COMMENT '原页面会话',
  `operation` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '成功提交的固定操作',
  `payload_hash` BINARY(32) NOT NULL COMMENT '规范化原请求SHA256；不保存正文',
  `workflow_ids_json` JSON NOT NULL COMMENT '已提交实例ID字符串数组；OPEN为空',
  `batch_id` BIGINT NULL COMMENT '小试组引用',
  `created_at` DATETIME(3) NOT NULL COMMENT '原事务提交时间，UTC',
  PRIMARY KEY (`actor_user_id`,`request_id`),
  KEY `idx_m07_sc_receipt_session` (`session_id`,`created_at`),
  CONSTRAINT `ck_m07_sc_receipt_kind` CHECK (workflow_kind IN ('START_CULTURE_SMALL','START_CULTURE_PILOT')),
  CONSTRAINT `ck_m07_sc_receipt_refs` CHECK (JSON_TYPE(workflow_ids_json)='ARRAY')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='不可变成功请求引用；不按24小时清理；缺记录不能推断未执行';


-- Source: docs/详细设计/07-补液运行与任务执行/SC-01-开始培养表结构.sql
CREATE TABLE `run_workflow_step_visit` (
  `visit_id` BIGINT NOT NULL COMMENT '访问身份',
  `page_session_id` BIGINT NOT NULL COMMENT '会话；第1步可先于运行实例存在',
  `step_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '稳定固定步骤编码',
  `visit_no` INT UNSIGNED NOT NULL COMMENT '同会话同一步锁内递增访问序号',
  `started_at` DATETIME(3) NOT NULL COMMENT '服务端进入UTC时刻',
  `ended_at` DATETIME(3) NULL COMMENT '已确认结束UTC时刻；未知保持NULL',
  `started_by` BIGINT NOT NULL COMMENT '进入操作者',
  `ended_by` BIGINT NULL COMMENT '结束操作者；自动中断可NULL',
  `end_reason` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'NEXT/COMPLETED/SKIPPED/BACK/CANCELLED/PAGE_REFRESH/DEADLINE_EXPIRED',
  `end_time_basis` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'SERVER_TRANSITION/DETECTED_INTERRUPTION；未知NULL',
  `start_request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '开始请求引用',
  `end_request_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '独立结束请求引用',
  PRIMARY KEY (`visit_id`),
  UNIQUE KEY `uk_m07_sc_visit` (`page_session_id`,`step_code`,`visit_no`),
  CONSTRAINT `ck_m07_sc_visit_no` CHECK (visit_no>0),
  CONSTRAINT `ck_m07_sc_visit_end` CHECK ((ended_at IS NULL AND end_reason IS NULL AND end_time_basis IS NULL AND end_request_id IS NULL AND ended_by IS NULL) OR (ended_at IS NOT NULL AND ended_at>=started_at AND end_reason IS NOT NULL AND end_time_basis IS NOT NULL AND end_request_id IS NOT NULL)),
  CONSTRAINT `ck_m07_sc_visit_reason` CHECK (end_reason IS NULL OR end_reason IN ('NEXT','COMPLETED','SKIPPED','BACK','CANCELLED','PAGE_REFRESH','DEADLINE_EXPIRED')),
  CONSTRAINT `ck_m07_sc_visit_basis` CHECK (end_time_basis IS NULL OR end_time_basis IN ('SERVER_TRANSITION','DETECTED_INTERRUPTION'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='共享步骤访问时间审计；不可用结束时间证明物理停止';


-- Source: docs/详细设计/07-补液运行与任务执行/SC-01-开始培养表结构.sql
CREATE TABLE `run_workflow_step_visit_member` (
  `visit_id` BIGINT NOT NULL COMMENT '共享会话访问',
  `step_instance_id` BIGINT NOT NULL COMMENT '成员运行步骤',
  `workflow_id` BIGINT NOT NULL COMMENT '成员运行实例',
  `member_outcome` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '该访问成员结果，非整组结论',
  `evidence_refs` JSON NULL COMMENT '物理命令及确认引用；不含表单正文',
  PRIMARY KEY (`visit_id`,`step_instance_id`),
  KEY `idx_m07_sc_member_workflow` (`workflow_id`,`visit_id`),
  CONSTRAINT `ck_m07_sc_member_outcome` CHECK (member_outcome IN ('IN_PROGRESS','COMPLETED','SKIPPED','CANCELLED','UNKNOWN','PENDING'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='共享访问与各实例步骤关联及逐成员结果';


-- Source: docs/详细设计/09-告警与通知管理/SC-01-开始培养配置集合.sql
CREATE TABLE `alarm_start_culture_collection` (
  `culture_id` BIGINT NOT NULL COMMENT '培养配置集合标记；零项也保留',
  `device_kind` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '真实设备类别',
  `device_id` BIGINT NOT NULL COMMENT '真实设备稳定身份',
  `lab_id` BIGINT NOT NULL COMMENT '真实实验室',
  `workflow_id` BIGINT NOT NULL COMMENT '首次提交开始培养工作流',
  `source_scope` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CULTURE/DEVICE/NONE',
  `source_revision` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '继承源版本',
  `source_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '继承源SHA256',
  `content_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '最终配置SHA256',
  `created_at` DATETIME(3) NOT NULL COMMENT 'UTC生效时间',
  `actor_user_id` BIGINT NOT NULL COMMENT '操作者',
  PRIMARY KEY (`culture_id`),
  UNIQUE KEY `uk_m09_sc_workflow` (`workflow_id`),
  CONSTRAINT `ck_m09_sc_source` CHECK (source_scope IN ('CULTURE','DEVICE','NONE')),
  CONSTRAINT `ck_m09_sc_hash` CHECK (source_hash REGEXP '^[0-9a-f]{64}$' AND content_hash REGEXP '^[0-9a-f]{64}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='首次培养在线配置集合；区分已有空集合与不存在';

-- Source: docs/详细设计/02-实验室与资源管理/RM-01-统一反应器型号表结构.sql
CREATE TABLE dev_reactor_model (
  model_id bigint NOT NULL,
  reactor_type varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  model_name varchar(50) NOT NULL,
  capacity_g decimal(12,3) NULL,
  spec varchar(50) NOT NULL DEFAULT '',
  pressure_unit varchar(20) NULL,
  threshold_weight_g decimal(12,3) NULL,
  temperature_control tinyint NOT NULL DEFAULT 1,
  weight_control tinyint NOT NULL DEFAULT 1,
  pressure_control tinyint NOT NULL DEFAULT 1,
  description varchar(100) NOT NULL DEFAULT '',
  icon_path varchar(255) NULL,
  del_flag char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0',
  create_by varchar(64) NOT NULL DEFAULT '',
  create_time datetime NULL,
  update_by varchar(64) NOT NULL DEFAULT '',
  update_time datetime NULL,
  remark varchar(500) NULL,
  m02_active tinyint GENERATED ALWAYS AS
    (CASE WHEN del_flag = '0' THEN 1 ELSE NULL END) STORED,
  PRIMARY KEY (model_id),
  UNIQUE KEY uk_reactor_model_name (reactor_type, model_name, m02_active),
  KEY idx_reactor_model_list (del_flag, reactor_type, update_time, model_id),
  CONSTRAINT ck_rm_id CHECK (model_id > 0),
  CONSTRAINT ck_rm_type CHECK
    (reactor_type IN ('INTEGRATED_REACTOR', 'BENCH_CONTROLLER')),
  CONSTRAINT ck_rm_name CHECK (CHAR_LENGTH(TRIM(model_name)) > 0),
  CONSTRAINT ck_rm_capacity CHECK
    (capacity_g IS NULL OR (capacity_g > 0 AND capacity_g = FLOOR(capacity_g))),
  CONSTRAINT ck_rm_threshold CHECK
    (threshold_weight_g IS NULL OR
      (threshold_weight_g > 0 AND threshold_weight_g = FLOOR(threshold_weight_g))),
  CONSTRAINT ck_rm_pressure CHECK
    (pressure_unit IS NULL OR CHAR_LENGTH(TRIM(pressure_unit)) > 0),
  CONSTRAINT ck_rm_required CHECK
    (reactor_type = 'BENCH_CONTROLLER' OR
      (capacity_g IS NOT NULL AND pressure_unit IS NOT NULL
       AND threshold_weight_g IS NOT NULL)),
  CONSTRAINT ck_rm_controls CHECK
    (temperature_control IN (0,1) AND weight_control IN (0,1)
     AND pressure_control IN (0,1)),
  CONSTRAINT ck_rm_deleted CHECK (del_flag IN ('0','2'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资源管理-反应器与台式控制器统一型号';

-- Source: docs/详细设计/02-实验室与资源管理/RM-01-统一反应器型号表结构.sql
CREATE TABLE dev_reactor_model_channel (
  channel_id bigint NOT NULL,
  model_id bigint NOT NULL,
  channel_kind varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  channel_no int NOT NULL,
  channel_code varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  max_range decimal(18,2) NULL,
  range_unit varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL,
  strategy_id bigint NULL,
  pump_type varchar(16) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'PUMP: INTERNAL内置/EXTERNAL外置；其他通道NULL',
  external_pump_model_id bigint NULL COMMENT '外置泵资源型号ID，不是实验室实物ID',
  del_flag char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0',
  create_by varchar(64) NOT NULL DEFAULT '',
  create_time datetime NULL,
  update_by varchar(64) NOT NULL DEFAULT '',
  update_time datetime NULL,
  m02_active tinyint GENERATED ALWAYS AS
    (CASE WHEN del_flag = '0' THEN 1 ELSE NULL END) STORED,
  PRIMARY KEY (channel_id),
  UNIQUE KEY uk_rm_channel_no (model_id, channel_kind, channel_no, m02_active),
  UNIQUE KEY uk_rm_channel_code (model_id, channel_code, m02_active),
  KEY idx_rmc_external_pump_model (external_pump_model_id, del_flag),
  CONSTRAINT fk_rmc_external_pump_model FOREIGN KEY (external_pump_model_id)
    REFERENCES dev_peristaltic_pump_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_rm_channel_model FOREIGN KEY (model_id)
    REFERENCES dev_reactor_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_rmc_id CHECK (channel_id > 0 AND model_id > 0),
  CONSTRAINT ck_rmc_kind CHECK
    (channel_kind IN ('PUMP','MFC','SAMPLING_PUMP','VALVE')),
  CONSTRAINT ck_rmc_no CHECK
    (channel_no > 0 AND (channel_kind <> 'PUMP' OR channel_no <= 65535)
     AND (channel_kind <> 'SAMPLING_PUMP' OR channel_no = 1)),
  CONSTRAINT ck_rmc_code CHECK
    (channel_code = CONCAT(channel_kind, CAST(channel_no AS CHAR))),
  CONSTRAINT ck_rmc_range CHECK (max_range IS NULL OR max_range >= 0),
  CONSTRAINT ck_rmc_pump_source CHECK (
    (channel_kind = 'PUMP' AND pump_type IS NOT NULL AND
      ((pump_type = 'INTERNAL' AND external_pump_model_id IS NULL)
       OR (pump_type = 'EXTERNAL' AND external_pump_model_id IS NOT NULL AND external_pump_model_id > 0)))
    OR (channel_kind <> 'PUMP' AND pump_type IS NULL AND external_pump_model_id IS NULL)
  ),
  CONSTRAINT ck_rmc_payload CHECK (
    (channel_kind = 'PUMP' AND max_range IS NOT NULL
      AND range_unit IS NOT NULL AND range_unit = 'g/min' AND strategy_id IS NULL)
    OR (channel_kind = 'MFC' AND max_range IS NOT NULL
      AND range_unit IS NOT NULL AND range_unit = 'L/min' AND strategy_id IS NULL)
    OR (channel_kind = 'SAMPLING_PUMP' AND max_range IS NULL
      AND range_unit IS NOT NULL AND range_unit = 'g/min' AND strategy_id IS NULL)
    OR (channel_kind = 'VALVE' AND max_range IS NULL
      AND range_unit IS NULL AND strategy_id IS NULL)
  ),
  CONSTRAINT ck_rmc_deleted CHECK (del_flag IN ('0','2'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资源管理-型号通道与隐藏组件预留';

-- Source: docs/详细设计/02-实验室与资源管理/RM-01-统一反应器型号表结构.sql
CREATE TABLE dev_reactor_model_pid (
  pid_id bigint NOT NULL,
  model_id bigint NOT NULL,
  loop_code varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  gain_value decimal(10,1) NOT NULL,
  reset_seconds int NOT NULL,
  rate_value decimal(10,1) NULL,
  del_flag char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0',
  create_by varchar(64) NOT NULL DEFAULT '',
  create_time datetime NULL,
  update_by varchar(64) NOT NULL DEFAULT '',
  update_time datetime NULL,
  m02_active tinyint GENERATED ALWAYS AS
    (CASE WHEN del_flag = '0' THEN 1 ELSE NULL END) STORED,
  PRIMARY KEY (pid_id),
  UNIQUE KEY uk_rm_pid_loop (model_id, loop_code, m02_active),
  KEY idx_rm_pid_model (model_id, del_flag),
  CONSTRAINT fk_rm_pid_model FOREIGN KEY (model_id)
    REFERENCES dev_reactor_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_rmp_id CHECK (pid_id > 0 AND model_id > 0),
  CONSTRAINT ck_rmp_loop CHECK
    (loop_code IN ('DO','PH','VESSEL_TEMP','JACKET_TEMP','VESSEL_PRESSURE')),
  CONSTRAINT ck_rmp_values CHECK
    (gain_value > 0 AND reset_seconds > 0 AND (rate_value IS NULL OR rate_value >= 0)),
  CONSTRAINT ck_rmp_deleted CHECK (del_flag IN ('0','2'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资源管理-反应器型号PID默认参数';

-- Source: docs/详细设计/03-项目与培养管理/PD-01-项目检测规则表结构.sql
-- M03 project-owned downstream detection configuration. New table only; no historical data or lab defaults are copied.
CREATE TABLE `res_project_detection_rule` (
  `project_id` bigint NOT NULL COMMENT '所属项目，逻辑关联res_project',
  `lab_id` bigint NOT NULL COMMENT '项目参与的中试下游实验室，逻辑关联lab_lab',
  `items_json` json NOT NULL COMMENT '按M02六项规则编码保存的完整项目覆盖数组，小数为字符串，无配置项为null对',
  `updated_project_version` bigint NOT NULL COMMENT '本行最近保存后的项目object_version，非独立并发版本',
  `creator_user_id` bigint NOT NULL COMMENT '首次配置的可信创建用户ID',
  `modifier_user_id` bigint NOT NULL COMMENT '最近配置的可信修改用户ID',
  `create_by` varchar(64) NOT NULL COMMENT '首次配置的账号',
  `update_by` varchar(64) NOT NULL COMMENT '最近配置的账号',
  `create_time` datetime(3) NOT NULL COMMENT '创建时间UTC',
  `update_time` datetime(3) NOT NULL COMMENT '修改时间UTC',
  PRIMARY KEY (`project_id`, `lab_id`),
  KEY `idx_m03_project_detection_lab` (`lab_id`),
  CONSTRAINT `ck_m03_project_detection_ids` CHECK (`project_id` > 0 AND `lab_id` > 0 AND `creator_user_id` > 0 AND `modifier_user_id` > 0),
  CONSTRAINT `ck_m03_project_detection_version` CHECK (`updated_project_version` > 0),
  CONSTRAINT `ck_m03_project_detection_items` CHECK (JSON_TYPE(`items_json`) = 'ARRAY' AND JSON_LENGTH(`items_json`) = 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03项目按中试下游实验室的检测规则覆盖';

-- M02 工作流执行配置事实：由受信适配器/核准流程写入，M07 只读消费。
CREATE TABLE `m02_workflow_execution_configuration` (
  `configuration_id` BIGINT NOT NULL COMMENT '配置事实ID',
  `lab_id` BIGINT NOT NULL COMMENT '实验室ID',
  `controller_connection_id` BIGINT NOT NULL COMMENT '台式控制器连接ID',
  `pump_id` BIGINT NOT NULL COMMENT '固定泵实例ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '泵通道编码',
  `scale_id` BIGINT NULL COMMENT '核准计量秤ID',
  `meter_device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准计量设备类型',
  `meter_channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准计量通道',
  `meter_metric_code` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '核准计量指标',
  `configuration_revision` BIGINT UNSIGNED NOT NULL COMMENT '实际已应用配置版本',
  `capability_revision` BIGINT UNSIGNED NOT NULL COMMENT '核准能力版本',
  `adapter_instance_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '可信适配器实例',
  `execution_profile_json` JSON NOT NULL COMMENT '完整核准executionProfile',
  `profile_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'profile规范SHA256',
  `state` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'READY/REVOKED',
  `evidence_ref` VARCHAR(500) CHARACTER SET utf8mb4 NOT NULL COMMENT '核准证据引用',
  `object_version` BIGINT UNSIGNED NOT NULL COMMENT '并发版本',
  `valid_from` DATETIME(6) NOT NULL COMMENT '生效时刻UTC',
  `valid_to` DATETIME(6) NULL COMMENT '失效时刻UTC',
  `active_slot` TINYINT GENERATED ALWAYS AS (CASE WHEN state='READY' AND valid_to IS NULL THEN 1 ELSE NULL END) STORED,
  `created_at` DATETIME(6) NOT NULL COMMENT '形成时刻UTC',
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `uk_m02_workflow_config_active` (`controller_connection_id`,`pump_id`,`channel_code`,`active_slot`),
  KEY `ix_m02_workflow_config_hash` (`profile_hash`),
  KEY `ix_m02_workflow_config_lookup` (`lab_id`,`controller_connection_id`,`pump_id`,`channel_code`,`state`),
  CONSTRAINT `ck_m02_workflow_config_ids` CHECK (`configuration_id`>0 AND `lab_id`>0 AND `controller_connection_id`>0 AND `pump_id`>0 AND `scale_id`>0 AND `configuration_revision`>0 AND `capability_revision`>0 AND `object_version`>0),
  CONSTRAINT `ck_m02_workflow_config_meter_kind` CHECK (`meter_device_kind` IN ('FLOOR_SCALE','BALANCE')),
  CONSTRAINT `ck_m02_workflow_config_state` CHECK (`state` IN ('READY','REVOKED')),
  CONSTRAINT `ck_m02_workflow_config_json` CHECK (JSON_TYPE(`execution_profile_json`)='OBJECT'),
  CONSTRAINT `ck_m02_workflow_config_validity` CHECK (`valid_to` IS NULL OR `valid_to`>`valid_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02工作流执行配置权威事实';

-- M02 工作流首次计量不可变事实：M07 读取后写入自己的执行分段。
CREATE TABLE `m02_workflow_metering_fact` (
  `fact_id` BIGINT NOT NULL COMMENT '计量事实ID',
  `lab_id` BIGINT NOT NULL COMMENT '实验室ID',
  `device_kind` VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'FLOOR_SCALE/BALANCE/BENCH_CONTROLLER',
  `device_id` BIGINT NOT NULL COMMENT '计量设备ID',
  `channel_code` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '计量通道',
  `metric_code` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '指标编码',
  `configuration_revision` BIGINT UNSIGNED NOT NULL COMMENT '读数对应配置版本',
  `raw_value` VARCHAR(256) NOT NULL COMMENT '原始十进制值',
  `raw_unit` VARCHAR(30) NOT NULL COMMENT '原始单位',
  `value` DECIMAL(38,12) NOT NULL COMMENT '规范值',
  `unit` VARCHAR(30) NOT NULL COMMENT '规范单位',
  `observed_at` DATETIME(6) NOT NULL COMMENT '设备观测时间UTC',
  `received_at` DATETIME(6) NOT NULL COMMENT '服务接收时间UTC',
  `quality` VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'GOOD/STALE/BAD/UNKNOWN',
  `source_revision` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源版本',
  `source_instance_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源适配器实例',
  `source_boot_id` VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源启动代次',
  `source_event_id` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源事件ID',
  `source_sequence` VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '来源序列',
  `direction` VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'CONSUMED_INCREASES/SUPPLY_DECREASES',
  `fact_hash` CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '规范事实SHA256',
  `evidence_json` JSON NOT NULL COMMENT '不可变来源证据',
  `created_at` DATETIME(6) NOT NULL COMMENT '形成时刻UTC',
  PRIMARY KEY (`fact_id`),
  UNIQUE KEY `uk_m02_workflow_metering_source` (`source_instance_id`,`source_boot_id`,`source_event_id`),
  KEY `ix_m02_workflow_metering_lookup` (`lab_id`,`device_kind`,`device_id`,`channel_code`,`metric_code`,`configuration_revision`,`observed_at`),
  CONSTRAINT `ck_m02_workflow_metering_ids` CHECK (`fact_id`>0 AND `lab_id`>0 AND `device_id`>0 AND `configuration_revision`>0),
  CONSTRAINT `ck_m02_workflow_metering_kind` CHECK (`device_kind` IN ('FLOOR_SCALE','BALANCE','BENCH_CONTROLLER')),
  CONSTRAINT `ck_m02_workflow_metering_quality` CHECK (`quality` IN ('GOOD','STALE','BAD','UNKNOWN')),
  CONSTRAINT `ck_m02_workflow_metering_direction` CHECK (`direction` IN ('CONSUMED_INCREASES','SUPPLY_DECREASES')),
  CONSTRAINT `ck_m02_workflow_metering_time` CHECK (`observed_at`<=`received_at`),
  CONSTRAINT `ck_m02_workflow_metering_json` CHECK (JSON_TYPE(`evidence_json`)='OBJECT')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M02工作流首次计量不可变事实';

-- Source: docs/详细设计/07-补液运行与任务执行/RC-01-培养运行设置变更表结构.sql
CREATE TABLE `run_culture_change_candidate` (
  candidate_id bigint NOT NULL,
  culture_id bigint NOT NULL,
  lab_id bigint NOT NULL,
  operation_code varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  candidate_version bigint NOT NULL,
  expected_culture_version bigint NOT NULL,
  expected_config_version bigint NULL,
  before_snapshot json NOT NULL,
  after_snapshot json NOT NULL,
  impact_snapshot json NOT NULL,
  candidate_hash binary(32) NOT NULL,
  policy_snapshot json NULL,
  state varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  approval_id bigint NULL,
  decision_version bigint NULL,
  decision_snapshot json NULL,
  submission_receipt json NULL,
  application_receipt json NULL,
  source_request_id char(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  request_hash binary(32) NOT NULL,
  created_by bigint NOT NULL,
  created_at datetime(3) NOT NULL,
  applied_at datetime(3) NULL,
  closed_at datetime(3) NULL,
  active_culture_id bigint GENERATED ALWAYS AS (CASE WHEN state IN ('PREPARED','PENDING') THEN culture_id ELSE NULL END) STORED,
  PRIMARY KEY (candidate_id),
  UNIQUE KEY uk_run_culture_change_active (active_culture_id),
  UNIQUE KEY uk_run_culture_change_request (created_by, source_request_id),
  UNIQUE KEY uk_run_culture_change_approval (approval_id),
  KEY idx_run_culture_change_history (culture_id, created_at, candidate_id),
  CONSTRAINT ck_run_culture_change_ids CHECK (candidate_id > 0 AND culture_id > 0 AND lab_id > 0 AND created_by > 0),
  CONSTRAINT ck_run_culture_change_versions CHECK (candidate_version > 0 AND expected_culture_version > 0 AND (decision_version IS NULL OR decision_version >= 0)),
  CONSTRAINT ck_run_culture_change_operation CHECK ((operation_code = 'CALCULATION' AND expected_config_version IS NOT NULL AND expected_config_version > 0) OR (operation_code = 'DEVICE' AND expected_config_version IS NULL)),
  CONSTRAINT ck_run_culture_change_state CHECK (state IN ('PREPARED','PENDING','APPLIED','DISCARDED','CONFLICT')),
  CONSTRAINT ck_run_culture_change_policy CHECK (state = 'PREPARED' OR (policy_snapshot IS NOT NULL AND submission_receipt IS NOT NULL)),
  CONSTRAINT ck_run_culture_change_approval CHECK (approval_id IS NULL OR approval_id > 0),
  CONSTRAINT ck_run_culture_change_pending CHECK (state <> 'PENDING' OR approval_id IS NOT NULL),
  CONSTRAINT ck_run_culture_change_decision CHECK ((decision_version IS NULL AND decision_snapshot IS NULL AND application_receipt IS NULL) OR (decision_version IS NOT NULL AND decision_snapshot IS NOT NULL AND application_receipt IS NOT NULL AND approval_id IS NOT NULL AND state IN ('APPLIED','DISCARDED','CONFLICT'))),
  CONSTRAINT ck_run_culture_change_applied CHECK ((state = 'APPLIED' AND applied_at IS NOT NULL) OR (state <> 'APPLIED' AND applied_at IS NULL)),
  CONSTRAINT ck_run_culture_change_closed CHECK ((state IN ('PREPARED','PENDING') AND closed_at IS NULL) OR (state IN ('APPLIED','DISCARDED','CONFLICT') AND closed_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sys_sensitive_operation_receipt` (
  `actor_user_id` bigint NOT NULL COMMENT '操作者用户编号',
  `business_request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '业务请求唯一编号',
  `operation` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作类型：密码重置或密码策略修改',
  `session_binding` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '当前会话绑定摘要',
  `actor_credential_version` bigint NOT NULL COMMENT '操作者凭证版本',
  `payload_hmac` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作参数完整性校验摘要',
  `key_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '摘要密钥版本标识',
  `proof_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '操作凭证哈希值',
  `state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '操作状态：待验证、就绪、已执行、已拒绝或已取消',
  `active_challenge_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '当前认证挑战哈希值',
  `challenge_expires_at` datetime(3) NOT NULL COMMENT '认证挑战到期时间（UTC）',
  `authentication_method` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '身份认证方式',
  `verified_at` datetime(3) NULL COMMENT '二次认证通过时间（UTC）',
  `proof_expires_at` datetime(3) NULL COMMENT '操作凭证到期时间（UTC）',
  `result_json` json NULL COMMENT '成功执行结果回执',
  `reject_code` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '操作拒绝错误码',
  `created_at` datetime(3) NOT NULL COMMENT '记录创建时间（UTC）',
  `retain_until` datetime(3) NOT NULL COMMENT '记录至少保留至此时间（UTC）',
  PRIMARY KEY (`actor_user_id`,`business_request_id`),
  UNIQUE KEY `uk_sensitive_proof` (`proof_hash`),
  KEY `idx_sensitive_retention` (`retain_until`),
  CONSTRAINT `ck_sensitive_operation` CHECK (`operation` IN ('PASSWORD_RESET','PASSWORD_POLICY_UPDATE')),
  CONSTRAINT `ck_sensitive_state` CHECK (`state` IN ('PENDING','READY','APPLIED','REJECTED','CANCELLED')),
  CONSTRAINT `ck_sensitive_verified` CHECK (`state` NOT IN ('READY','APPLIED') OR (`proof_hash` IS NOT NULL AND `verified_at` IS NOT NULL AND `proof_expires_at` IS NOT NULL)),
  CONSTRAINT `ck_sensitive_result` CHECK ((`state`='APPLIED' AND `result_json` IS NOT NULL) OR (`state`<>'APPLIED' AND `result_json` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='敏感操作二次认证及执行回执';

CREATE TABLE sys_login_security_snapshot (
  user_id BIGINT NOT NULL COMMENT '用户编号',
  session_version BIGINT NOT NULL COMMENT '登录会话版本',
  login_request_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '登录请求唯一编号',
  previous_success_at DATETIME(3) NULL COMMENT '本次登录前最近成功登录时间（UTC）',
  previous_failure_at DATETIME(3) NULL COMMENT '本次登录前最近失败登录时间（UTC）',
  current_login_at DATETIME(3) NOT NULL COMMENT '本次成功登录时间（UTC）',
  created_at DATETIME(3) NOT NULL COMMENT '快照创建时间（UTC）',
  success_event_id BIGINT NULL COMMENT '上次成功登录日志编号',
  failure_event_id BIGINT NULL COMMENT '上次失败登录日志编号',
  PRIMARY KEY (user_id, session_version),
  UNIQUE KEY uk_login_snapshot_request (user_id, login_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户登录安全反馈快照';

-- Source: docs/详细设计/03-项目与培养管理/培养固定泵连接事实目标表结构.sql
CREATE TABLE `res_culture_pump_connection_revision` (
  `revision_id` bigint NOT NULL COMMENT '不可变版本ID，应用生成',
  `culture_id` bigint NOT NULL COMMENT '所属培养ID',
  `lab_id` bigint NOT NULL COMMENT '冻结时实验室ID',
  `controller_id` bigint NOT NULL COMMENT '台式控制器连接ID，对应M02 connection_id',
  `base_effective_revision_id` bigint NULL COMMENT '提交时当前生效版本；首次保存为空',
  `occupancy_id` bigint NULL COMMENT '冻结时有效占用ID；无占用草稿为空',
  `occupancy_version` bigint NULL COMMENT '冻结时有效占用版本，与占用ID成对',
  `culture_version` bigint NOT NULL COMMENT '冻结时培养对象版本',
  `plan_version` bigint NOT NULL COMMENT '冻结时日期计划版本；无完整日期计划的新建草稿为0，合法计划变更递增',
  `channels_json` json NOT NULL COMMENT '服务端校验的完整通道及配置、真实引用和资源快照',
  `content_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '不可变内容规范摘要',
  `candidate_schema_version` bigint NOT NULL DEFAULT 1 COMMENT '候选信封格式：1保持草稿既有格式，2为SC026前值绑定格式',
  `before_original` json NULL COMMENT 'v2不可变前值原件；原件自身schemaVersion为1，v1候选为空',
  `before_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'v2前值原件规范摘要，小写SHA-256；v1为空',
  `review_original` json NULL COMMENT 'v2同事务冻结的M07可信ChangeSnapshot审阅正文，免审同样保留；v1为空',
  `review_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT '完整审阅正文规范摘要，小写SHA-256；v1为空',
  `reason` varchar(500) NULL COMMENT '变更原因；按SC026政策和入口规则核验',
  `request_key` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '来源、操作人和请求ID的幂等键摘要',
  `request_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '不可变请求载荷与版本摘要',
  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '源请求ID',
  `created_by` bigint NOT NULL COMMENT '可信操作者ID',
  `created_at` datetime(3) NOT NULL COMMENT '创建时刻UTC',
  PRIMARY KEY (`revision_id`),
  UNIQUE KEY `uk_m03_pump_connection_request` (`request_key`),
  KEY `ix_m03_pump_connection_history` (`culture_id`,`created_at`,`revision_id`),
  CONSTRAINT `ck_m03_pump_conn_revision_ids` CHECK (`revision_id` > 0 AND `culture_id` > 0 AND `lab_id` > 0 AND `controller_id` > 0 AND `created_by` > 0),
  CONSTRAINT `ck_m03_pump_conn_revision_versions` CHECK (`culture_version` > 0 AND `plan_version` >= 0 AND (`base_effective_revision_id` IS NULL OR `base_effective_revision_id` > 0)),
  CONSTRAINT `ck_m03_pump_conn_occupancy_pair` CHECK ((`occupancy_id` IS NULL AND `occupancy_version` IS NULL) OR (`occupancy_id` IS NOT NULL AND `occupancy_version` IS NOT NULL AND `occupancy_id` > 0 AND `occupancy_version` > 0)),
  CONSTRAINT `ck_m03_pump_conn_candidate_schema` CHECK (`candidate_schema_version` IN (1,2)),
  CONSTRAINT `ck_m03_pump_conn_candidate_evidence` CHECK ((`candidate_schema_version` = 1 AND `before_original` IS NULL AND `before_hash` IS NULL AND `review_original` IS NULL AND `review_hash` IS NULL) OR (`candidate_schema_version` = 2 AND `before_original` IS NOT NULL AND `before_hash` IS NOT NULL AND `review_original` IS NOT NULL AND `review_hash` IS NOT NULL AND JSON_TYPE(`before_original`) = 'OBJECT' AND JSON_TYPE(`review_original`) = 'OBJECT' AND CHAR_LENGTH(`before_hash`) = 64 AND CHAR_LENGTH(`review_hash`) = 64 AND `before_hash` = LOWER(`before_hash`) AND `review_hash` = LOWER(`review_hash`))),
  CONSTRAINT `ck_m03_pump_conn_v2_context` CHECK (`candidate_schema_version` = 1 OR (`occupancy_id` IS NOT NULL AND `occupancy_version` IS NOT NULL AND `reason` IS NOT NULL AND CHAR_LENGTH(TRIM(`reason`)) BETWEEN 1 AND 500))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03培养固定泵连接不可变版本';

-- Source: docs/详细设计/03-项目与培养管理/培养固定泵连接事实目标表结构.sql
CREATE TABLE `res_culture_pump_connection_state` (
  `state_id` bigint NOT NULL COMMENT '主键，应用生成',
  `culture_id` bigint NOT NULL COMMENT '培养ID；每培养一条状态',
  `lab_id` bigint NOT NULL COMMENT '当前事实所属实验室',
  `controller_id` bigint NOT NULL COMMENT '当前事实对应台式控制器连接ID',
  `effective_revision_id` bigint NULL COMMENT '已合法生效的固定泵版本',
  `candidate_revision_id` bigint NULL COMMENT '独立的活动候选版本',
  `approval_id` bigint NULL COMMENT '当前待审候选对应的真实审批单ID',
  `apply_state` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'EMPTY/PREPARED/PENDING/APPLIED',
  `feeding_snapshot_id` bigint NULL COMMENT '生效时同步产生的真实FEEDING方案快照；无则为空',
  `application_receipt` json NULL COMMENT '最近一次合法生效的决定及版本关联证据',
  `object_version` bigint NOT NULL COMMENT '状态并发版本，初始1',
  `updated_at` datetime(3) NOT NULL COMMENT '最近变更时刻UTC',
  PRIMARY KEY (`state_id`),
  UNIQUE KEY `uk_m03_pump_connection_culture` (`culture_id`),
  UNIQUE KEY `uk_m03_pump_connection_approval` (`approval_id`),
  KEY `ix_m03_pump_connection_controller` (`lab_id`,`controller_id`),
  CONSTRAINT `ck_m03_pump_conn_state_ids` CHECK (`state_id` > 0 AND `culture_id` > 0 AND `lab_id` > 0 AND `controller_id` > 0 AND `object_version` > 0),
  CONSTRAINT `ck_m03_pump_conn_state_refs` CHECK ((`effective_revision_id` IS NULL OR `effective_revision_id` > 0) AND (`candidate_revision_id` IS NULL OR `candidate_revision_id` > 0) AND (`approval_id` IS NULL OR `approval_id` > 0) AND (`feeding_snapshot_id` IS NULL OR `feeding_snapshot_id` > 0)),
  CONSTRAINT `ck_m03_pump_conn_state_shape` CHECK ((`apply_state` = 'EMPTY' AND `effective_revision_id` IS NULL AND `candidate_revision_id` IS NULL AND `approval_id` IS NULL) OR (`apply_state` = 'APPLIED' AND `effective_revision_id` IS NOT NULL AND `candidate_revision_id` IS NULL AND `approval_id` IS NULL) OR (`apply_state` = 'PREPARED' AND `candidate_revision_id` IS NOT NULL AND `approval_id` IS NULL) OR (`apply_state` = 'PENDING' AND `candidate_revision_id` IS NOT NULL AND `approval_id` IS NOT NULL)),
  CONSTRAINT `ck_m03_pump_conn_effective_evidence` CHECK ((`effective_revision_id` IS NULL AND `feeding_snapshot_id` IS NULL AND `application_receipt` IS NULL) OR (`effective_revision_id` IS NOT NULL AND `application_receipt` IS NOT NULL)),
  CONSTRAINT `ck_m03_pump_conn_distinct_revisions` CHECK (`effective_revision_id` IS NULL OR `candidate_revision_id` IS NULL OR `effective_revision_id` <> `candidate_revision_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03培养固定泵连接生效与活动候选指针';

-- Source: docs/详细设计/03-项目与培养管理/培养固定泵连接事实目标表结构.sql
CREATE TABLE `res_culture_pump_connection_application` (
  `application_id` bigint NOT NULL COMMENT '不可变决定应用原件ID，应用生成',
  `culture_id` bigint NOT NULL COMMENT '所属培养ID',
  `lab_id` bigint NOT NULL COMMENT '保存时实验室ID',
  `controller_id` bigint NOT NULL COMMENT '保存时台式控制器连接ID',
  `revision_id` bigint NOT NULL COMMENT '本次决定针对的固定泵版本',
  `actor_user_id` bigint NOT NULL COMMENT '提交请求的可信操作者ID',
  `request_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原始请求UUID',
  `request_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '原请求规范摘要，小写SHA-256',
  `candidate_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '固定泵候选信封规范摘要，大写SHA-256',
  `previous_state_version` bigint NOT NULL COMMENT '决定前固定泵状态版本，初始空状态亦须先建立',
  `previous_revision_id` bigint NULL COMMENT '决定前实际生效版本，无则为空',
  `decision_mode` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT 'DRAFT_DIRECT/POLICY_DIRECT/APPROVAL',
  `decision_key` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '真实决定原件唯一身份',
  `decision_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '完整决定原件规范摘要，小写SHA-256',
  `decision_original` json NOT NULL COMMENT '真实决定原件，草稿直存不包含虚构审批与政策',
  `outcome` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '真实决定结果：APPLIED生效或DISCARDED撤回',
  `feeding_snapshot_id` bigint NULL COMMENT '同事务产生的真实补液快照，无则为空',
  `checked_at` datetime(3) NOT NULL COMMENT '服务端实际完成校验的UTC时间',
  `applied_at` datetime(3) NULL COMMENT '实际应用时刻UTC；撤回时为空',
  PRIMARY KEY (`application_id`),
  UNIQUE KEY `uk_m03_pump_application_decision` (`decision_key`),
  UNIQUE KEY `uk_m03_pump_application_revision` (`revision_id`),
  KEY `ix_m03_pump_application_culture` (`culture_id`,`applied_at`,`application_id`),
  CONSTRAINT `ck_m03_pump_application_ids` CHECK (`application_id` > 0 AND `culture_id` > 0 AND `lab_id` > 0 AND `controller_id` > 0 AND `revision_id` > 0 AND `actor_user_id` > 0 AND `previous_state_version` > 0 AND (`previous_revision_id` IS NULL OR `previous_revision_id` > 0) AND (`feeding_snapshot_id` IS NULL OR `feeding_snapshot_id` > 0)),
  CONSTRAINT `ck_m03_pump_application_mode` CHECK (`decision_mode` IN ('DRAFT_DIRECT','POLICY_DIRECT','APPROVAL')),
  CONSTRAINT `ck_m03_pump_application_outcome` CHECK ((`outcome` = 'APPLIED' AND `applied_at` IS NOT NULL) OR (`outcome` = 'DISCARDED' AND `applied_at` IS NULL AND `feeding_snapshot_id` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='M03培养固定泵真实决定及应用不可变原件';
