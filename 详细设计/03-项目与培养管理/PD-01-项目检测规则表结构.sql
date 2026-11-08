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
