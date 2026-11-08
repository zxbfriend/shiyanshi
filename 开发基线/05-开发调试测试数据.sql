-- FutureFab 开发调试测试数据（非正式初始化数据）
-- 适用：执行 docs/开发基线/01-完整建表.sql、02-基础数据初始化.sql、03-初始化结果核验.sql 之后的本地/联调调试库。
-- 禁止用于生产、验收或客户正式数据；不要加入开发基线 README 的三段正式执行链。
-- 生成原则：每张目标表至少 1 条样例，尽量串起 M01/M02/M03/M04/M05/M06/M07/M09 的调试链路。
SET NAMES utf8mb4;
SET time_zone = '+00:00';
START TRANSACTION;

-- sys_venue
INSERT INTO `sys_venue` (`venue_id`, `venue_name`, `venue_code`)
VALUES (9100, 'sys_venue调试样例', 'SYS_VENUE_DEBUG')
ON DUPLICATE KEY UPDATE `venue_name` = VALUES(`venue_name`);

-- sys_dept
INSERT INTO `sys_dept` (`dept_id`)
VALUES (9101)
ON DUPLICATE KEY UPDATE `dept_id` = VALUES(`dept_id`);

-- sys_group
INSERT INTO `sys_group` (`group_id`, `group_name`)
VALUES (9102, 'sys_group调试样例')
ON DUPLICATE KEY UPDATE `group_name` = VALUES(`group_name`);

-- sys_group_leader
INSERT INTO `sys_group_leader` (`group_id`, `user_id`)
VALUES (9102, 9001)
ON DUPLICATE KEY UPDATE `group_id` = VALUES(`group_id`);

-- sys_group_member
INSERT INTO `sys_group_member` (`group_id`, `user_id`)
VALUES (9102, 9001)
ON DUPLICATE KEY UPDATE `group_id` = VALUES(`group_id`);

-- sys_menu
INSERT INTO `sys_menu` (`menu_id`, `menu_name`)
VALUES (9202, 'sys_menu调试样例')
ON DUPLICATE KEY UPDATE `menu_name` = VALUES(`menu_name`);

-- sys_role
INSERT INTO `sys_role` (`role_id`, `role_name`, `role_key`, `role_sort`, `status`)
VALUES (9201, 'sys_role调试样例', 'sys_role:debug:key', 700006, '0')
ON DUPLICATE KEY UPDATE `role_name` = VALUES(`role_name`);

-- sys_role_data_scope
INSERT INTO `sys_role_data_scope` (`role_id`, `scope_type`)
VALUES (9201, '1')
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);

-- sys_role_dept
INSERT INTO `sys_role_dept` (`role_id`, `dept_id`)
VALUES (9201, 9101)
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);

-- sys_role_menu
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
VALUES (9201, 9202)
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);

-- sys_user
INSERT INTO `sys_user` (`user_id`, `user_name`, `nick_name`)
VALUES (9001, 'sys_user调试样例', 'sys_user调试样例')
ON DUPLICATE KEY UPDATE `user_name` = VALUES(`user_name`);

-- sys_user_role
INSERT INTO `sys_user_role` (`user_id`, `role_id`)
VALUES (9001, 9201)
ON DUPLICATE KEY UPDATE `user_id` = VALUES(`user_id`);

-- sys_dict_type
INSERT INTO `sys_dict_type` (`dict_id`)
VALUES (700012)
ON DUPLICATE KEY UPDATE `dict_id` = VALUES(`dict_id`);

-- sys_dict_data
INSERT INTO `sys_dict_data` (`dict_code`)
VALUES (700013)
ON DUPLICATE KEY UPDATE `dict_code` = VALUES(`dict_code`);

-- sys_config
INSERT INTO `sys_config` (`config_id`)
VALUES (9902)
ON DUPLICATE KEY UPDATE `config_id` = VALUES(`config_id`);

-- sys_logininfor
INSERT INTO `sys_logininfor` (`info_id`)
VALUES (700015)
ON DUPLICATE KEY UPDATE `info_id` = VALUES(`info_id`);

-- sys_oper_log
INSERT INTO `sys_oper_log` (`oper_id`)
VALUES (700016)
ON DUPLICATE KEY UPDATE `oper_id` = VALUES(`oper_id`);

-- sys_data_change_log
INSERT INTO `sys_data_change_log` (`id`, `table_name`, `record_id`, `operation`)
VALUES (700017, 'sys_data_change_log调试样例', 700017, 'START')
ON DUPLICATE KEY UPDATE `table_name` = VALUES(`table_name`);

-- sys_user_password_history
INSERT INTO `sys_user_password_history` (`id`, `user_id`, `password`)
VALUES ('sys_user_password_history_id_debug', 9001, 'sys_user_password_history_password_debug')
ON DUPLICATE KEY UPDATE `user_id` = VALUES(`user_id`);

-- sys_user_auth_state
INSERT INTO `sys_user_auth_state` (`user_id`, `login_failures`, `change_failures`)
VALUES (9001, CAST('{"debug":true,"table":"sys_user_auth_state"}' AS JSON), CAST('{"debug":true,"table":"sys_user_auth_state"}' AS JSON))
ON DUPLICATE KEY UPDATE `user_id` = VALUES(`user_id`);

-- sys_management_revision
INSERT INTO `sys_management_revision` (`scope_key`)
VALUES ('SYSTEM')
ON DUPLICATE KEY UPDATE `scope_key` = VALUES(`scope_key`);

-- sys_management_request
INSERT INTO `sys_management_request` (`actor_user_id`, `request_id`, `operation_code`, `payload_hash`, `result_json`, `expires_at`)
VALUES (9001, '00000000-0000-4000-8000-000000000001', 'SYS_MANAGEMENT_REQUEST_DEBUG', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"sys_management_request"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `actor_user_id` = VALUES(`actor_user_id`);

-- bottle_config
INSERT INTO `bottle_config` (`bottle_id`, `lab_id`, `row_no`, `slot_no`, `reactor_id`, `unit_type`, `unit_code`, `pump_code`)
VALUES (700022, 9301, 1, 1, 9959, 'F', 'BOTTLE_CONFIG_DEBUG', 'BOTTLE_CONFIG_DEBUG')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- calibration_object
INSERT INTO `calibration_object` (`object_id`, `weight_name`, `net_weight`)
VALUES (9951, 'calibration_object调试样例', 1.00)
ON DUPLICATE KEY UPDATE `weight_name` = VALUES(`weight_name`);

-- consumable_master
INSERT INTO `consumable_master` (`consumable_id`, `item_code`, `description`, `category`, `measure_unit`, `capacity_unit`, `brand`)
VALUES (9952, 'CONSUMABLE_MASTER_DEBUG', '127.0.0.1', 'debug', 'g', 'g', 'DebugBrand')
ON DUPLICATE KEY UPDATE `item_code` = VALUES(`item_code`);

-- consumption_rule
INSERT INTO `consumption_rule` (`rule_id`, `tab_type`, `detect_class`, `row_name`, `seq_number`, `item_type`)
VALUES (9953, 'debug', 'BGA', 'consumption_rule调试样例', 700025, '1')
ON DUPLICATE KEY UPDATE `tab_type` = VALUES(`tab_type`);

-- dev_air_pump_model
INSERT INTO `dev_air_pump_model` (`model_id`, `brand`, `model_name`)
VALUES (700026, 'DebugBrand', 'dev_air_pump_model调试样例')
ON DUPLICATE KEY UPDATE `brand` = VALUES(`brand`);

-- dev_analyzer_model
INSERT INTO `dev_analyzer_model` (`analyzer_id`, `device_type`, `model_name`)
VALUES (9954, 'sdms', 'dev_analyzer_model调试样例')
ON DUPLICATE KEY UPDATE `device_type` = VALUES(`device_type`);

-- dev_bench_reactor
INSERT INTO `dev_bench_reactor` (`model_id`, `brand`)
VALUES (700028, 'DebugBrand')
ON DUPLICATE KEY UPDATE `brand` = VALUES(`brand`);

-- dev_culture_container_spec
INSERT INTO `dev_culture_container_spec` (`spec_id`, `container_type`, `spec`)
VALUES (9955, 'debug', 'dev_culture_container_spec_spec_debug')
ON DUPLICATE KEY UPDATE `container_type` = VALUES(`container_type`);

-- dev_detector_item
INSERT INTO `dev_detector_item` (`item_id`, `detect_class`, `item_code`, `item_cn_name`)
VALUES (9602, 'BGA', 'DEV_DETECTOR_ITEM_DEBUG', 'dev_detector_item调试样例')
ON DUPLICATE KEY UPDATE `detect_class` = VALUES(`detect_class`);

-- dev_detector_model
INSERT INTO `dev_detector_model` (`model_id`, `detect_class`, `support_stored`, `send_mode`, `work_send_limit`, `channel_count`, `column_count`)
VALUES (700031, 'BGA', '1', 'dev_detector_model_send_mode_debug', 700031, 1, 1)
ON DUPLICATE KEY UPDATE `detect_class` = VALUES(`detect_class`);

-- dev_floor_scale_model
INSERT INTO `dev_floor_scale_model` (`model_id`, `model_name`)
VALUES (700032, 'dev_floor_scale_model调试样例')
ON DUPLICATE KEY UPDATE `model_name` = VALUES(`model_name`);

-- dev_integrated_reactor
INSERT INTO `dev_integrated_reactor` (`model_id`, `model_name`)
VALUES (700033, 'dev_integrated_reactor调试样例')
ON DUPLICATE KEY UPDATE `model_name` = VALUES(`model_name`);

-- dev_peristaltic_pump_model
INSERT INTO `dev_peristaltic_pump_model` (`model_id`, `brand`, `model_name`)
VALUES (700034, 'DebugBrand', 'dev_peristaltic_pump_model调试样例')
ON DUPLICATE KEY UPDATE `brand` = VALUES(`brand`);

-- feed_medium
INSERT INTO `feed_medium` (`medium_id`, `medium_name`, `sugar_concentration`)
VALUES (9956, 'feed_medium调试样例', 1.00)
ON DUPLICATE KEY UPDATE `medium_name` = VALUES(`medium_name`);

-- lab_air_pump
INSERT INTO `lab_air_pump` (`air_pump_id`, `lab_id`, `device_no`)
VALUES (9957, 9301, 'lab_air_pump_device_no_debug')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_balance
INSERT INTO `lab_balance` (`balance_id`, `lab_id`, `device_no`)
VALUES (9958, 9301, 'lab_balance_device_no_debug')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_bench_reactor
INSERT INTO `lab_bench_reactor` (`reactor_id`, `lab_id`)
VALUES (9959, 9301)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_bench_reactor_controller
INSERT INTO `lab_bench_reactor_controller` (`connection_id`, `lab_id`, `connection_name`)
VALUES (9960, 9301, 'lab_bench_reactor_controller调试样例')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_bench_reactor_controller_channel
INSERT INTO `lab_bench_reactor_controller_channel` (`channel_id`, `connection_id`)
VALUES (9961, 9960)
ON DUPLICATE KEY UPDATE `connection_id` = VALUES(`connection_id`);

-- lab_communication
INSERT INTO `lab_communication` (`comm_id`, `route`, `device_id`)
VALUES (9962, 'lab_communication_route_debug', 9964)
ON DUPLICATE KEY UPDATE `route` = VALUES(`route`);

-- lab_culture_container
INSERT INTO `lab_culture_container` (`container_id`, `lab_id`)
VALUES (9963, 9301)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_detection_rule
INSERT INTO `lab_detection_rule` (`rule_id`, `lab_id`)
VALUES (9953, 9301)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_detector
INSERT INTO `lab_detector` (`detector_id`, `lab_id`, `device_no`, `detect_class`, `detect_type`)
VALUES (9601, 9301, 'lab_detector_device_no_debug', 'BGA', 'BGA')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_detector_item_config
INSERT INTO `lab_detector_item_config` (`detector_id`, `item_id`)
VALUES (9601, 9602)
ON DUPLICATE KEY UPDATE `detector_id` = VALUES(`detector_id`);

-- lab_downstream_device
INSERT INTO `lab_downstream_device` (`device_id`, `lab_id`, `device_type`, `asset_no`, `device_no`)
VALUES (9964, 9301, 'sdms', 'lab_downstream_device_asset_no_debug', 'lab_downstream_device_device_no_debug')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_floor_scale
INSERT INTO `lab_floor_scale` (`scale_id`, `lab_id`, `device_no`)
VALUES (9965, 9301, 'lab_floor_scale_device_no_debug')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_integrated_reactor
INSERT INTO `lab_integrated_reactor` (`integrated_id`, `lab_id`, `model_id`, `device_no`, `asset_no`, `reactor_name`, `floor_scale_id`, `floor_scale_low_limit`, `floor_scale_high_limit`, `feed_scale_id`, `owner_user_id`)
VALUES (9966, 9301, 700048, 'lab_integrated_reactor_device_no_debug', 'lab_integrated_reactor_asset_no_debug', 'lab_integrated_reactor调试样例', 700048, 10.00, 100.00, 700048, 9001)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_integrated_reactor_pump
INSERT INTO `lab_integrated_reactor_pump` (`integrated_id`, `pump_id`)
VALUES (9966, 9967)
ON DUPLICATE KEY UPDATE `integrated_id` = VALUES(`integrated_id`);

-- lab_integrated_reactor_pump_config
INSERT INTO `lab_integrated_reactor_pump_config` (`integrated_id`, `pump_no`, `range_value`)
VALUES (9966, 1, 1.00)
ON DUPLICATE KEY UPDATE `range_value` = VALUES(`range_value`);

-- lab_lab
INSERT INTO `lab_lab` (`lab_id`, `lab_name`, `lab_code`, `ip_address`)
VALUES (9301, 'lab_lab调试样例', 'LAB_LAB_DEBUG', '127.0.0.1')
ON DUPLICATE KEY UPDATE `lab_name` = VALUES(`lab_name`);

-- lab_lab_leader
INSERT INTO `lab_lab_leader` (`lab_id`, `user_id`)
VALUES (9301, 9001)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_peristaltic_pump
INSERT INTO `lab_peristaltic_pump` (`pump_id`, `lab_id`, `device_no`)
VALUES (9967, 9301, 'lab_peristaltic_pump_device_no_debug')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_printer
INSERT INTO `lab_printer` (`printer_id`, `lab_id`)
VALUES (9968, 9301)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_printer_layout_setting
INSERT INTO `lab_printer_layout_setting` (`layout_id`, `printer_id`, `row_no`, `width`, `height`, `font_size`)
VALUES (9969, 9968, 1, 1.00, 1.00, 1.00)
ON DUPLICATE KEY UPDATE `printer_id` = VALUES(`printer_id`);

-- lab_relay
INSERT INTO `lab_relay` (`relay_id`, `lab_id`)
VALUES (9970, 9301)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_sound_alarm
INSERT INTO `lab_sound_alarm` (`alarm_id`, `lab_id`)
VALUES (9904, 9301)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- liquid_bag
INSERT INTO `liquid_bag` (`bag_id`, `description`, `model`, `capacity`, `tare_weight`, `residual_amount`, `lower_limit_vol`)
VALUES (9971, '127.0.0.1', 'DebugModel', 700058, 700058, 700058, 10)
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

-- sys_user_lab
INSERT INTO `sys_user_lab` (`user_id`, `lab_id`)
VALUES (9001, 9301)
ON DUPLICATE KEY UPDATE `user_id` = VALUES(`user_id`);

-- lab_engineering_profile
INSERT INTO `lab_engineering_profile` (`profile_id`, `scope_key`, `scope_kind`, `status`, `object_version`, `updated_by_user_id`, `updated_at`)
VALUES (9950, 'lab_engineering_profile:debug', 'MODEL', '0', 1, 9001, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `scope_key` = VALUES(`scope_key`);

-- lab_engineering_profile_version
INSERT INTO `lab_engineering_profile_version` (`version_id`, `profile_id`, `version_no`, `schema_version`, `profile_json`, `canonical_hash`, `evidence_json`, `recorded_by_user_id`, `recorded_at`, `request_key`, `request_hash`)
VALUES (9502, 9950, 1, 1, CAST('{"debug":true,"table":"lab_engineering_profile_version"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"lab_engineering_profile_version"}' AS JSON), 9001, UTC_TIMESTAMP(3), 'lab_engineering_profile_version:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
ON DUPLICATE KEY UPDATE `profile_id` = VALUES(`profile_id`);

-- res_project
INSERT INTO `res_project` (`project_id`, `project_code`)
VALUES (9401, 'RES_PROJECT_DEBUG')
ON DUPLICATE KEY UPDATE `project_code` = VALUES(`project_code`);

-- res_project_leader
INSERT INTO `res_project_leader` (`project_id`, `user_id`)
VALUES (9401, 9001)
ON DUPLICATE KEY UPDATE `project_id` = VALUES(`project_id`);

-- res_project_lab
INSERT INTO `res_project_lab` (`project_id`, `lab_id`)
VALUES (9401, 9301)
ON DUPLICATE KEY UPDATE `project_id` = VALUES(`project_id`);

-- res_project_tag
INSERT INTO `res_project_tag` (`project_id`, `dict_code`, `tag_value`)
VALUES (9401, 'RES_PROJECT_TAG_DEBUG', 'res_project_tag_tag_value_debug')
ON DUPLICATE KEY UPDATE `project_id` = VALUES(`project_id`);

-- res_project_member
INSERT INTO `res_project_member` (`project_id`, `user_id`, `grant_type`)
VALUES (9401, 9001, 'MEMBER')
ON DUPLICATE KEY UPDATE `project_id` = VALUES(`project_id`);

-- res_batch
INSERT INTO `res_batch` (`batch_id`, `project_id`, `lab_id`, `batch_code`)
VALUES (9402, 9401, 9301, 'RES_BATCH_DEBUG')
ON DUPLICATE KEY UPDATE `project_id` = VALUES(`project_id`);

-- res_batch_leader
INSERT INTO `res_batch_leader` (`batch_id`, `user_id`)
VALUES (9402, 9001)
ON DUPLICATE KEY UPDATE `batch_id` = VALUES(`batch_id`);

-- res_batch_member
INSERT INTO `res_batch_member` (`batch_id`, `user_id`, `grant_type`)
VALUES (9402, 9001, 'MEMBER')
ON DUPLICATE KEY UPDATE `batch_id` = VALUES(`batch_id`);

-- res_culture
INSERT INTO `res_culture` (`culture_id`, `project_id`, `batch_id`, `lab_id`, `culture_code`)
VALUES (9403, 9401, 9402, 9301, 'RES_CULTURE_DEBUG')
ON DUPLICATE KEY UPDATE `project_id` = VALUES(`project_id`);

-- res_culture_leader
INSERT INTO `res_culture_leader` (`culture_id`, `user_id`)
VALUES (9403, 9001)
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_member
INSERT INTO `res_culture_member` (`culture_id`, `user_id`, `grant_type`)
VALUES (9403, 9001, 'MEMBER')
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_occupancy
INSERT INTO `res_culture_occupancy` (`occupancy_id`, `culture_id`, `device_kind`, `device_id`, `lab_id`, `occupancy_state`, `acquired_at`, `created_request_id`, `object_version`)
VALUES (9404, 9403, 700073, 9964, 9301, 'RUNNING', UTC_TIMESTAMP(3), 'res_culture_occupancy_created_request_id_debug', 1)
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_notice_outbox
INSERT INTO `res_culture_notice_outbox` (`event_id`, `culture_id`, `event_type`, `culture_version`, `occurred_at`, `request_id`, `old_value`, `new_value`, `delivery_state`, `attempt_count`, `next_attempt_at`)
VALUES (9901, 9403, 'N_MARK_CHANGED', 1, UTC_TIMESTAMP(3), '00000000-0000-4000-8000-000000000001', CAST('{"debug":true,"table":"res_culture_notice_outbox"}' AS JSON), CAST('{"debug":true,"table":"res_culture_notice_outbox"}' AS JSON), 'PENDING', 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_parameter_application
INSERT INTO `res_culture_parameter_application` (`application_id`, `snapshot_id`, `culture_id`, `decision_key`, `decision_hash`, `policy_evidence`, `outcome`, `parameter_generation`, `result_json`, `handled_at`)
VALUES (700075, 700075, 9403, 'res_culture_parameter_application:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"res_culture_parameter_application"}' AS JSON), 'VALID', 700075, CAST('{"debug":true,"table":"res_culture_parameter_application"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `snapshot_id` = VALUES(`snapshot_id`);

-- res_culture_parameter_snapshot
INSERT INTO `res_culture_parameter_snapshot` (`snapshot_id`, `culture_id`, `workflow_node_id`, `template_kind`, `package_schema_version`, `template_package`, `package_hash`, `culture_object_version`, `schedule_plan_version`, `device_kind`, `device_id`, `saved_by_user_id`, `saved_at`, `request_key`, `request_hash`, `request_id`)
VALUES (700076, 9403, 10, 'FEEDING', 1, CAST('{"debug":true,"table":"res_culture_parameter_snapshot"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 1, 1, 'INTEGRATED_REACTOR', 9964, 700076, UTC_TIMESTAMP(3), 'res_culture_parameter_snapshot:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_parameter_state
INSERT INTO `res_culture_parameter_state` (`state_id`, `culture_id`, `workflow_node_id`, `template_kind`, `parameter_generation`, `apply_state`, `object_version`, `updated_at`)
VALUES (700077, 9403, 10, 'FEEDING', 700077, 'NONE', 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_workflow_reference
INSERT INTO `res_culture_workflow_reference` (`reference_id`, `culture_id`, `lab_id`, `workflow_node_id`, `source_kind`, `source_key`, `created_at`, `evidence_ref`)
VALUES (700078, 9403, 9301, 10, 'FEEDING', 'res_culture_workflow_reference:debug:key', UTC_TIMESTAMP(3), CAST('{"debug":true,"table":"res_culture_workflow_reference"}' AS JSON))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_runtime_event
INSERT INTO `res_culture_runtime_event` (`event_id`, `culture_id`, `source_module`, `source_event_id`, `source_event_key`, `stream_id`, `stream_sequence`, `event_type`, `source_object_version`, `expected_culture_version`, `expected_plan_version`, `occurred_at`, `received_at`, `payload_json`, `payload_hash`, `apply_state`, `object_version`)
VALUES (9901, 9403, 'M07', 'res_culture_runtime_event_source_event_id_debug', 'res_culture_runtime_event:debug:key', 'res_culture_runtime_event_stream_id_debug', 1, 'debug', 1, 1, 1, UTC_TIMESTAMP(3), UTC_TIMESTAMP(3), CAST('{"debug":true,"table":"res_culture_runtime_event"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'NONE', 1)
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- res_culture_change_candidate
INSERT INTO `res_culture_change_candidate` (`candidate_id`, `culture_id`, `scene_code`, `schema_version`, `operation_code`, `change_key`, `management_revision`, `expected_target_version`, `before_snapshot`, `after_snapshot`, `impact_snapshot`, `candidate_hash`, `policy_evidence`, `source_request_key`, `source_request_hash`, `created_by`, `created_at`)
VALUES (9809, 9403, 'RES_CULTURE_CHANGE_CANDIDATE_DEBUG', 1, 'RES_CULTURE_CHANGE_CANDIDATE_DEBUG', 'res_culture_change_candidate:debug:key', 700080, 1, CAST('{"debug":true,"table":"res_culture_change_candidate"}' AS JSON), CAST('{"debug":true,"table":"res_culture_change_candidate"}' AS JSON), CAST('{"debug":true,"table":"res_culture_change_candidate"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"res_culture_change_candidate"}' AS JSON), 'res_culture_change_candidate:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 9001, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- prc_template
INSERT INTO `prc_template` (`template_id`, `template_kind`, `template_name`, `origin_kind`)
VALUES (9501, 'FEEDING', 'prc_template调试样例', 'NEW')
ON DUPLICATE KEY UPDATE `template_kind` = VALUES(`template_kind`);

-- prc_template_version
INSERT INTO `prc_template_version` (`version_id`, `template_id`, `version_no`, `name_snapshot`, `content_schema_version`, `calculation_profile`, `content_json`, `applicability_json`, `canonical_hash`, `change_kind`, `recorded_at`)
VALUES (9502, 9501, 1, 'prc_template_version调试样例', 1, 'NONE', CAST('{"debug":true,"table":"prc_template_version"}' AS JSON), CAST('{"debug":true,"table":"prc_template_version"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'CREATE', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `template_id` = VALUES(`template_id`);

-- prc_template_binding
INSERT INTO `prc_template_binding` (`binding_id`, `parent_version_id`, `slot_key`, `source_template_id`, `source_version_id`, `source_kind`, `effective_schema_version`, `effective_parameters_json`, `effective_applicability_json`, `effective_hash`)
VALUES (9503, 1, 'prc_template_binding:debug:key', 700083, 1, 'FEEDING', 1, CAST('{"debug":true,"table":"prc_template_binding"}' AS JSON), CAST('{"debug":true,"table":"prc_template_binding"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
ON DUPLICATE KEY UPDATE `parent_version_id` = VALUES(`parent_version_id`);

-- prc_template_version_model
INSERT INTO `prc_template_version_model` (`version_id`, `model_kind`, `model_id`, `display_order`)
VALUES (9502, 700084, 700084, 1)
ON DUPLICATE KEY UPDATE `display_order` = VALUES(`display_order`);

-- prc_template_import_map
INSERT INTO `prc_template_import_map` (`import_map_id`, `import_batch_id`, `source_system`, `source_table`, `source_key`, `source_hash`, `target_template_id`, `target_version_id`, `reviewed_by_user_id`, `reviewed_at`, `evidence_ref`, `imported_at`)
VALUES (25, 'prc_template_import_map_import_batch_id_debug', 'CDP', 'prc_template_import_map_source_table_debug', 'prc_template_import_map:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 700085, 1, 700085, UTC_TIMESTAMP(3), 'debug://prc_template_import_map/evidence_ref', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `import_batch_id` = VALUES(`import_batch_id`);

-- det_approval_assignee
INSERT INTO `det_approval_assignee` (`assignee_id`, `scope_type`, `scope_id`, `user_id`)
VALUES (700086, '1', 700086, 9001)
ON DUPLICATE KEY UPDATE `scope_type` = VALUES(`scope_type`);

-- det_ccpd_upload_log
INSERT INTO `det_ccpd_upload_log` (`upload_id`, `result_id`, `sample_id`, `upload_type`)
VALUES (700087, 9604, 9603, 'debug')
ON DUPLICATE KEY UPDATE `result_id` = VALUES(`result_id`);

-- det_dispatch_log
INSERT INTO `det_dispatch_log` (`log_id`, `request_id`, `detector_id`, `detect_class`, `detect_type`, `communication_type`, `invocation_mode`, `device_status`, `local_status`, `start_time`)
VALUES (9607, '00000000-0000-4000-8000-000000000001', 9601, 'BGA', 'BGA', 'HTTP', 'SINGLE', 'accepted', 'committed', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `request_id` = VALUES(`request_id`);

-- det_exception_note
INSERT INTO `det_exception_note` (`note_id`, `result_id`)
VALUES (700089, 9604)
ON DUPLICATE KEY UPDATE `result_id` = VALUES(`result_id`);

-- det_print_export_log
INSERT INTO `det_print_export_log` (`log_id`, `result_id`, `sample_id`, `action_type`)
VALUES (9607, 9604, 9603, 700090)
ON DUPLICATE KEY UPDATE `result_id` = VALUES(`result_id`);

-- det_result
INSERT INTO `det_result` (`result_id`, `sample_id`, `detector_id`, `detect_class`, `detect_type`)
VALUES (9604, 9603, 9601, 'BGA', 'BGA')
ON DUPLICATE KEY UPDATE `sample_id` = VALUES(`sample_id`);

-- det_result_item
INSERT INTO `det_result_item` (`result_item_id`, `result_id`)
VALUES (9605, 9604)
ON DUPLICATE KEY UPDATE `result_id` = VALUES(`result_id`);

-- det_result_sign_record
INSERT INTO `det_result_sign_record` (`sign_id`, `sample_id`, `action_type`)
VALUES (9608, 9603, 700093)
ON DUPLICATE KEY UPDATE `sample_id` = VALUES(`sample_id`);

-- det_review_audit_log
INSERT INTO `det_review_audit_log` (`audit_id`, `result_id`)
VALUES (700094, 9604)
ON DUPLICATE KEY UPDATE `result_id` = VALUES(`result_id`);

-- det_sample
INSERT INTO `det_sample` (`sample_id`, `lab_id`, `detector_id`, `detect_class`, `detect_type`, `channel_no`, `create_time`)
VALUES (9603, 9301, 9601, 'BGA', 'BGA', 'det_sample_channel_no_debug', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- det_sample_id_history
INSERT INTO `det_sample_id_history` (`history_id`, `sample_id`)
VALUES (700096, 9603)
ON DUPLICATE KEY UPDATE `sample_id` = VALUES(`sample_id`);

-- det_sample_item
INSERT INTO `det_sample_item` (`sample_id`, `item_id`)
VALUES (9603, 9602)
ON DUPLICATE KEY UPDATE `sample_id` = VALUES(`sample_id`);

-- det_device_event
INSERT INTO `det_device_event` (`event_id`, `observation_id`, `detector_id`, `adapter_key`, `contract_version`, `source_scope`, `semantic_hash`, `raw_hash`, `raw_payload`, `payload_meta`, `normalized_payload`, `event_kinds`, `received_at`)
VALUES (9901, 9923, 9601, 'det_device_event:debug:key', 'v1', 'det_device_event_source_scope_debug', UNHEX(SHA2('det_device_event.semantic_hash',256)), UNHEX(SHA2('det_device_event.raw_hash',256)), CAST('{"debug":true,"table":"det_device_event"}' AS JSON), CAST('{"debug":true,"table":"det_device_event"}' AS JSON), CAST('{"debug":true,"table":"det_device_event"}' AS JSON), CAST('{"debug":true,"table":"det_device_event"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `observation_id` = VALUES(`observation_id`);

-- det_result_revision
INSERT INTO `det_result_revision` (`revision_id`, `result_id`, `object_version`, `event_kind`, `source_kind`, `source_id`, `content_snapshot`, `created_at`)
VALUES (9701, 9604, 1, 'TRIGGER', 'FEEDING', 700099, CAST('{"debug":true,"table":"det_result_revision"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `result_id` = VALUES(`result_id`);

-- det_result_correction
INSERT INTO `det_result_correction` (`correction_id`, `result_id`, `base_object_version`, `base_content_hash`, `candidate_snapshot`, `candidate_hash`, `changed_paths`, `evidence_refs`, `reason`, `submitted_by`, `submitted_at`, `submission_signature`, `submit_request_id`, `submit_payload_hash`)
VALUES (9610, 9604, 1, '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"det_result_correction"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"det_result_correction"}' AS JSON), CAST('{"debug":true,"table":"det_result_correction"}' AS JSON), '开发调试样例数据', 9001, UTC_TIMESTAMP(3), CAST('{"debug":true,"table":"det_result_correction"}' AS JSON), 'det_result_correction_submit_request_id_debug', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
ON DUPLICATE KEY UPDATE `result_id` = VALUES(`result_id`);

-- apr_scene
INSERT INTO `apr_scene` (`scene_code`, `source_kind`, `module_level1`, `module_level2`, `operation_code`, `owner_module`, `scope_state`, `source_reference`, `source_hash`, `sort_order`, `scope_reason`)
VALUES ('APR_SCENE_DEBUG', 'TASK', '项目与培养', '培养变更', 'APR_SCENE_DEBUG', 'M03', 'SUPPORTED', 'debug://apr_scene/source_reference', UNHEX(SHA2('apr_scene.source_hash',256)), 1, '开发调试样例数据')
ON DUPLICATE KEY UPDATE `source_kind` = VALUES(`source_kind`);

-- apr_lab_policy
INSERT INTO `apr_lab_policy` (`policy_id`, `lab_id`, `created_at`, `updated_at`, `updated_by`)
VALUES (9903, 9301, UTC_TIMESTAMP(3), UTC_TIMESTAMP(3), 700102)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- apr_policy_revision
INSERT INTO `apr_policy_revision` (`revision_id`, `policy_id`, `revision_no`, `policy_snapshot`, `content_hash`, `source_evidence`, `created_by`, `created_at`)
VALUES (9701, 9903, 1, CAST('{"entry":{"reviewMode":"BATCH","approveMode":"NONE"},"resolutionRules":{"differentStageActors":true}}' AS JSON), UNHEX(SHA2('apr_policy_revision.content_hash',256)), CAST('{"debug":true,"table":"apr_policy_revision"}' AS JSON), 9001, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `policy_id` = VALUES(`policy_id`);

-- apr_request
INSERT INTO `apr_request` (`approval_id`, `scene_code`, `lab_id`, `project_id`, `batch_id`, `culture_id`, `owner_module`, `source_request_id`, `change_key`, `target_type`, `target_id`, `expected_target_version`, `candidate_id`, `candidate_version`, `candidate_hash`, `policy_revision_id`, `policy_snapshot`, `change_snapshot`, `initiator_kind`, `initiator_snapshot`, `submitted_at`, `operation_at`)
VALUES (700104, 'APR_SCENE_DEBUG', 9301, 9401, 9402, 9403, 'M03', 'apr_request_source_request_id_debug', 'apr_request:debug:key', 'CULTURE', 9403, 1, 9809, 1, UNHEX(SHA2('apr_request.candidate_hash',256)), 9701, CAST('{"entry":{"reviewMode":"BATCH","approveMode":"NONE"},"resolutionRules":{"differentStageActors":true}}' AS JSON), CAST('{"debug":true,"table":"apr_request"}' AS JSON), 'USER', CAST('{"debug":true,"table":"apr_request"}' AS JSON), UTC_TIMESTAMP(3), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `scene_code` = VALUES(`scene_code`);

-- apr_action
INSERT INTO `apr_action` (`action_id`, `approval_id`, `action_code`, `actor_kind`, `event_key`, `before_version`, `after_version`, `after_state`, `action_snapshot`, `occurred_at`)
VALUES (9703, 700104, 'SUBMIT', 'USER', UNHEX(SHA2('apr_action.event_key',256)), 1, 2, 'PENDING_REVIEW', CAST('{"debug":true,"table":"apr_action"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `approval_id` = VALUES(`approval_id`);

-- apr_delivery
INSERT INTO `apr_delivery` (`delivery_id`, `approval_id`, `decision_version`, `decision_kind`, `candidate_hash`, `payload_json`, `created_at`, `updated_at`)
VALUES (9704, 700106, 1, 'APPLY', UNHEX(SHA2('apr_delivery.candidate_hash',256)), CAST('{"debug":true,"table":"apr_delivery"}' AS JSON), UTC_TIMESTAMP(3), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `approval_id` = VALUES(`approval_id`);

-- apr_reconciliation
INSERT INTO `apr_reconciliation` (`reconciliation_id`, `delivery_id`, `approval_id`, `decision_version`, `candidate_hash`, `resolution`, `evidence_json`, `evidence_hash`, `reason`, `submitted_by`, `submitted_at`, `submit_key`, `submit_hash`)
VALUES (9705, 9704, 700107, 1, '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'VERIFY_APPLIED', CAST('{"debug":true,"table":"apr_reconciliation"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', '开发调试样例数据', 9001, UTC_TIMESTAMP(3), 'apr_reconciliation:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
ON DUPLICATE KEY UPDATE `delivery_id` = VALUES(`delivery_id`);

-- run_culture_runtime
INSERT INTO `run_culture_runtime` (`culture_id`, `lab_id`, `object_version`, `connection_generation`, `writer_mode`, `readiness`, `readiness_evidence`, `total_feed_grams`, `total_withdrawal_grams`, `plan_barrier_state`, `created_at`, `updated_at`)
VALUES (9403, 9301, 1, 700108, 'SMP', 'READY', CAST('{"debug":true,"table":"run_culture_runtime"}' AS JSON), 1.00, 1.00, 'OPEN', UTC_TIMESTAMP(3), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- run_workflow_instance
INSERT INTO `run_workflow_instance` (`workflow_id`, `culture_id`, `lab_id`, `subflow_id`, `subflow_code`, `definition_hash`, `definition_snapshot`, `state`, `object_version`, `request_id`, `actor_user_id`, `actor_snapshot`, `selection_snapshot`, `started_at`, `application_state`, `created_at`)
VALUES (10, 9403, 9301, 9932, 'RUN_WORKFLOW_INSTANCE_DEBUG', UNHEX(SHA2('run_workflow_instance.definition_hash',256)), CAST('{"debug":true,"table":"run_workflow_instance"}' AS JSON), 'OPEN', 1, '00000000-0000-4000-8000-000000000001', 9001, CAST('{"debug":true,"table":"run_workflow_instance"}' AS JSON), CAST('{"debug":true,"table":"run_workflow_instance"}' AS JSON), UTC_TIMESTAMP(3), 'OPEN', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_workflow_step
INSERT INTO `run_workflow_step` (`step_instance_id`, `workflow_id`, `definition_step_id`, `step_code`, `step_order`, `state`, `object_version`, `form_snapshot`)
VALUES (9803, 10, 700110, 'RUN_WORKFLOW_STEP_DEBUG', 1, 'PENDING', 1, CAST('{"debug":true,"table":"run_workflow_step"}' AS JSON))
ON DUPLICATE KEY UPDATE `workflow_id` = VALUES(`workflow_id`);

-- run_material_session
INSERT INTO `run_material_session` (`session_id`, `culture_id`, `lab_id`, `resource_key`, `physical_item_key`, `material_kind`, `resource_snapshot`, `initial_grams`, `consumed_grams`, `state`, `object_version`, `opened_by`, `workflow_id`, `opened_at`)
VALUES (700111, 9403, 9301, 'run_material_session:debug:key', 'run_material_session:debug:key', 'debug', CAST('{"debug":true,"table":"run_material_session"}' AS JSON), 1.00, 1.00, 'ACTIVE', 1, 700111, 10, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_manual_result
INSERT INTO `run_manual_result` (`manual_result_id`, `culture_id`, `lab_id`, `sample_no`, `sample_reservation_id`, `position_text`, `completed_at`, `items_snapshot`, `content_hash`, `created_by`, `created_at`, `object_version`, `request_id`)
VALUES (9805, 9403, 9301, 'run_manual_result_sample_no_debug', 'run_manual_result_sample_reservation_id_debug', 'run_manual_result_position_text_debug', UTC_TIMESTAMP(3), CAST('{"debug":true,"table":"run_manual_result"}' AS JSON), UNHEX(SHA2('run_manual_result.content_hash',256)), 9001, UTC_TIMESTAMP(3), 1, '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_confirmation
INSERT INTO `run_confirmation` (`confirmation_id`, `culture_id`, `lab_id`, `business_date`, `analyte_kind`, `source_kind`, `source_id`, `source_version`, `item_id`, `source_snapshot`, `state`, `object_version`, `actor_user_id`, `selected_at`, `deadline_at`, `request_id`)
VALUES (9806, 9403, 9301, CURRENT_DATE, 'GLUCOSE', 'FEEDING', 700113, 1, 9602, CAST('{"debug":true,"table":"run_confirmation"}' AS JSON), 'COUNTDOWN', 1, 9001, UTC_TIMESTAMP(3), TIMESTAMPADD(SECOND,60,UTC_TIMESTAMP(3)), '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_calculation
INSERT INTO `run_calculation` (`calculation_id`, `culture_id`, `lab_id`, `purpose`, `algorithm_version`, `input_snapshot`, `input_hash`, `output_snapshot`, `outcome`, `business_date`, `calculated_at`, `source_event_key`)
VALUES (9807, 9403, 9301, 'PREVIEW', 'v1', CAST('{"debug":true,"table":"run_calculation"}' AS JSON), UNHEX(SHA2('run_calculation.input_hash',256)), CAST('{"debug":true,"table":"run_calculation"}' AS JSON), 'VALID', CURRENT_DATE, UTC_TIMESTAMP(3), 'run_calculation:debug:key')
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_task
INSERT INTO `run_task` (`task_id`, `culture_id`, `lab_id`, `project_id`, `batch_id`, `task_type`, `source_kind`, `business_state`, `object_version`, `admitted`, `scheduler_held`, `planned_at`, `planned_date`, `plan_snapshot_id`, `plan_snapshot_version`, `plan_hash`, `task_spec`, `settlement_state`, `creation_key`, `created_at`, `modified_at`)
VALUES (9808, 9403, 9301, 9401, 9402, 'FEEDING', 'FEEDING', 'READY', 1, 700115, 700115, UTC_TIMESTAMP(3), CURRENT_DATE, 700115, 1, UNHEX(SHA2('run_task.plan_hash',256)), CAST('{"debug":true,"table":"run_task"}' AS JSON), 'NONE', UNHEX(SHA2('run_task.creation_key',256)), UTC_TIMESTAMP(3), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_task_candidate
INSERT INTO `run_task_candidate` (`candidate_id`, `task_id`, `culture_id`, `action_kind`, `candidate_version`, `expected_target_version`, `after_snapshot`, `candidate_hash`, `state`, `source_request_id`, `created_at`)
VALUES (9809, 9808, 9403, 'CREATE', 1, 1, CAST('{"debug":true,"table":"run_task_candidate"}' AS JSON), UNHEX(SHA2('run_task_candidate.candidate_hash',256)), 'PREPARED', 'run_task_candidate_source_request_id_debug', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `task_id` = VALUES(`task_id`);

-- run_generation
INSERT INTO `run_generation` (`generation_id`, `culture_id`, `plan_snapshot_id`, `rule_id`, `business_date`, `generation_key`, `evaluation_hash`, `state`, `evaluation_snapshot`, `object_version`, `evaluated_at`)
VALUES (9810, 9403, 700117, 9953, CURRENT_DATE, UNHEX(SHA2('run_generation.generation_key',256)), UNHEX(SHA2('run_generation.evaluation_hash',256)), 'CREATED', CAST('{"debug":true,"table":"run_generation"}' AS JSON), 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_execution
INSERT INTO `run_execution` (`execution_id`, `culture_id`, `attempt_no`, `physical_phase`, `object_version`, `execution_spec`, `spec_hash`, `target_grams`, `confirmed_grams`, `active_milliseconds`, `timeout_milliseconds`, `worker_id`, `fence`, `settlement_state`, `created_at`, `updated_at`)
VALUES (9811, 9403, 1, 'NOT_STARTED', 1, CAST('{"debug":true,"table":"run_execution"}' AS JSON), UNHEX(SHA2('run_execution.spec_hash',256)), 1.00, 1.00, 700118, 60000, 'run_execution_worker_id_debug', 700118, 'NONE', UTC_TIMESTAMP(3), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_execution_segment
INSERT INTO `run_execution_segment` (`segment_id`, `execution_id`, `segment_no`, `material_session_id`, `start_readings`, `direction`, `state`, `started_at`, `active_milliseconds`)
VALUES (9812, 9811, 1, 9804, CAST('{"debug":true,"table":"run_execution_segment"}' AS JSON), 'CONSUMED_INCREASES', 'OPEN', UTC_TIMESTAMP(3), 700119)
ON DUPLICATE KEY UPDATE `execution_id` = VALUES(`execution_id`);

-- run_command
INSERT INTO `run_command` (`command_id`, `culture_id`, `resource_key`, `operation`, `request_id`, `payload_hash`, `parameters`, `configuration_revision`, `fence`, `adapter_instance_id`, `state`, `object_version`, `attempt_count`, `created_at`)
VALUES (9813, 9403, 'run_command:debug:key', 'START', '00000000-0000-4000-8000-000000000001', UNHEX(SHA2('run_command.payload_hash',256)), CAST('{"debug":true,"table":"run_command"}' AS JSON), 700120, 700120, 'run_command_adapter_instance_id_debug', 'PREPARED', 1, 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_resource_guard
INSERT INTO `run_resource_guard` (`resource_key`, `lab_id`, `fence`, `physical_state`, `object_version`, `updated_at`)
VALUES ('run_resource_guard:debug:key', 9301, 700121, 'HELD', 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- run_execution_sample
INSERT INTO `run_execution_sample` (`sample_id`, `execution_id`, `segment_id`, `source_sequence`, `sample_hash`, `observed_at`, `received_at`, `stage`, `raw_readings`, `quality`)
VALUES (9603, 9811, 9812, 'run_execution_sample_source_sequence_debug', UNHEX(SHA2('run_execution_sample.sample_hash',256)), UTC_TIMESTAMP(3), UTC_TIMESTAMP(3), 'run_execution_sample_stage_debug', CAST('{"debug":true,"table":"run_execution_sample"}' AS JSON), 'GOOD')
ON DUPLICATE KEY UPDATE `execution_id` = VALUES(`execution_id`);

-- run_exception_handling
INSERT INTO `run_exception_handling` (`handling_id`, `task_id`, `execution_id`, `exception_snapshot`, `confirmed_actual_grams`, `deficit_pct`, `cause`, `extra_mode`, `actor_user_id`, `request_id`, `handled_at`, `content_hash`)
VALUES (9816, 9808, 9811, CAST('{"debug":true,"table":"run_exception_handling"}' AS JSON), 1.00, 1.00, 'run_exception_handling_cause_debug', 'NONE', 9001, '00000000-0000-4000-8000-000000000001', UTC_TIMESTAMP(3), UNHEX(SHA2('run_exception_handling.content_hash',256)))
ON DUPLICATE KEY UPDATE `task_id` = VALUES(`task_id`);

-- run_ledger
INSERT INTO `run_ledger` (`ledger_id`, `culture_id`, `lab_id`, `entry_kind`, `source_kind`, `source_id`, `source_event_key`, `culture_delta_grams`, `material_delta_grams`, `measurement_evidence`, `business_date`, `occurred_at`, `recorded_at`, `content_hash`)
VALUES (9817, 9403, 9301, 'FEED', 'FEEDING', 700124, 'run_ledger:debug:key', 1.00, 1.00, CAST('{"debug":true,"table":"run_ledger"}' AS JSON), CURRENT_DATE, UTC_TIMESTAMP(3), UTC_TIMESTAMP(3), UNHEX(SHA2('run_ledger.content_hash',256)))
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- run_event
INSERT INTO `run_event` (`event_id`, `lab_id`, `culture_id`, `event_type`, `object_kind`, `object_id`, `object_version`, `source_event_key`, `payload`, `payload_hash`, `occurred_at`, `publish_state`, `publish_attempts`)
VALUES (9901, 9301, 9403, 'debug', 'debug', 9951, 1, 'run_event:debug:key', CAST('{"debug":true,"table":"run_event"}' AS JSON), UNHEX(SHA2('run_event.payload_hash',256)), UTC_TIMESTAMP(3), 'PENDING', 700125)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- run_executor_assignment
INSERT INTO `run_executor_assignment` (`resource_key`, `lab_id`, `executor_id`, `assignment_epoch`, `control_proof`, `updated_by`, `updated_at`)
VALUES ('run_executor_assignment:debug:key', 9301, 'run_executor_assignment_executor_id_debug', 1, CAST('{"debug":true,"table":"run_executor_assignment"}' AS JSON), 700126, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- run_legacy_handover
INSERT INTO `run_legacy_handover` (`handover_id`, `culture_id`, `lab_id`, `source_key`, `cutover_at`, `mapping_snapshot`, `baseline_snapshot`, `baseline_hash`, `evidence_json`, `submitted_by`, `submitted_at`, `request_key`)
VALUES (700127, 9403, 9301, 'run_legacy_handover:debug:key', UTC_TIMESTAMP(3), CAST('{"debug":true,"table":"run_legacy_handover"}' AS JSON), CAST('{"debug":true,"table":"run_legacy_handover"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"run_legacy_handover"}' AS JSON), 9001, UTC_TIMESTAMP(3), 'run_legacy_handover:debug:key')
ON DUPLICATE KEY UPDATE `culture_id` = VALUES(`culture_id`);

-- alarm_mail_config
INSERT INTO `alarm_mail_config` (`config_id`, `sender_email`, `sender_account`, `sender_password`, `platform_name`, `server_name`, `server_port`)
VALUES (9902, 'debug@example.test', 'alarm_mail_config_sender_account_debug', 'alarm_mail_config_sender_password_debug', 'alarm_mail_config调试样例', 'alarm_mail_config调试样例', 25)
ON DUPLICATE KEY UPDATE `sender_email` = VALUES(`sender_email`);

-- alarm_notify_receiver
INSERT INTO `alarm_notify_receiver` (`receiver_id`, `rule_id`, `receiver_source`)
VALUES (700129, 9953, '1')
ON DUPLICATE KEY UPDATE `rule_id` = VALUES(`rule_id`);

-- alarm_notify_rule
INSERT INTO `alarm_notify_rule` (`rule_id`, `rule_code`, `alarm_type`, `alarm_module`, `notify_mode`)
VALUES (9953, 'ALARM_NOTIFY_RULE_DEBUG', 'debug', 'alarm_notify_rule_alarm_module_debug', '1')
ON DUPLICATE KEY UPDATE `rule_code` = VALUES(`rule_code`);

-- alarm_record
INSERT INTO `alarm_record` (`alarm_id`, `alarm_type`, `alarm_module`, `alarm_title`, `trigger_time`)
VALUES (9904, 'debug', 'alarm_record_alarm_module_debug', '开发调试通知', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `alarm_type` = VALUES(`alarm_type`);

-- lab_offline_alarm_config
INSERT INTO `lab_offline_alarm_config` (`config_id`, `lab_id`, `detect_class`, `item_id`)
VALUES (9902, 9301, 'BGA', 9602)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- lab_status_alarm_config
INSERT INTO `lab_status_alarm_config` (`config_id`, `lab_id`, `alarm_type`)
VALUES (9902, 9301, 'debug')
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- sys_notification
INSERT INTO `sys_notification` (`notify_id`, `notify_type`)
VALUES (700134, 'debug')
ON DUPLICATE KEY UPDATE `notify_type` = VALUES(`notify_type`);

-- alarm_online_config
INSERT INTO `alarm_online_config` (`config_id`, `scope_key`, `scope_kind`, `lab_id`, `device_kind`, `device_id`, `item_id`, `unit`, `cycle_enabled`, `methods_json`, `enabled`, `evaluation_state`, `revision_id`, `row_version`, `updated_by`, `updated_at`)
VALUES (9902, 'alarm_online_config:debug', 'DEVICE', 9301, 'INTEGRATED_REACTOR', 9964, 9602, 'g', '1', CAST('{"debug":true,"table":"alarm_online_config"}' AS JSON), '1', 'SAVE_ONLY', 9701, 1, 700135, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `scope_key` = VALUES(`scope_key`);

-- alarm_monitor_policy
INSERT INTO `alarm_monitor_policy` (`policy_id`, `scope_key`, `lab_id`, `device_kind`, `device_id`, `monitor_mode`, `revision_id`, `row_version`, `updated_by`, `updated_at`)
VALUES (9903, 'alarm_monitor_policy:debug', 9301, 'INTEGRATED_REACTOR', 9964, 'ON', 9701, 1, 700136, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `scope_key` = VALUES(`scope_key`);

-- alarm_config_revision
INSERT INTO `alarm_config_revision` (`revision_id`, `config_kind`, `scope_key`, `request_key`, `request_hash`, `content_json`, `content_hash`, `revision_state`, `created_by`, `created_at`, `row_version`)
VALUES (9701, 'ONLINE', 'alarm_config_revision:debug', 'alarm_config_revision:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"alarm_config_revision"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'PENDING', 9001, UTC_TIMESTAMP(3), 1)
ON DUPLICATE KEY UPDATE `config_kind` = VALUES(`config_kind`);

-- alarm_event
INSERT INTO `alarm_event` (`event_id`, `source_module`, `source_event_key`, `source_event_id`, `source_object_kind`, `source_object_id`, `source_version`, `event_kind`, `occurred_at`, `received_at`, `payload_json`, `payload_hash`, `process_state`, `row_version`)
VALUES (9901, 'M07', 'alarm_event:debug:key', 'alarm_event_source_event_id_debug', 'CULTURE', 'alarm_event_source_object_id_debug', 'v1', 'TRIGGER', UTC_TIMESTAMP(3), UTC_TIMESTAMP(3), CAST('{"debug":true,"table":"alarm_event"}' AS JSON), '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'RECEIVED', 1)
ON DUPLICATE KEY UPDATE `source_module` = VALUES(`source_module`);

-- alarm_recipient
INSERT INTO `alarm_recipient` (`recipient_id`, `alarm_id`, `user_id`, `source_json`, `display_name`, `authorization_ref`, `created_at`)
VALUES (9905, 9904, 9001, CAST('{"sources":["debug"]}' AS JSON), 'alarm_recipient调试样例', CAST('{"debug":true,"table":"alarm_recipient"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `alarm_id` = VALUES(`alarm_id`);

-- alarm_delivery
INSERT INTO `alarm_delivery` (`delivery_id`, `delivery_key`, `event_id`, `round_no`, `target_kind`, `target_key`, `channel`, `template_revision`, `title`, `content_hash`, `delivery_state`, `scheduled_at`, `attempt_count`, `created_at`, `updated_at`, `row_version`)
VALUES (9704, 'alarm_delivery:debug:key', 9901, 1, 'USER', 'alarm_delivery:debug:key', 'site', 'alarm_delivery_template_revision_debug', '开发调试通知', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'PENDING', UTC_TIMESTAMP(3), 1, UTC_TIMESTAMP(3), UTC_TIMESTAMP(3), 1)
ON DUPLICATE KEY UPDATE `delivery_key` = VALUES(`delivery_key`);

-- alarm_delivery_attempt
INSERT INTO `alarm_delivery_attempt` (`attempt_id`, `delivery_id`, `attempt_no`, `request_key`, `request_hash`, `provider_idempotency_key`, `started_at`, `attempt_state`, `lease_token`)
VALUES (9906, 9704, 1, 'alarm_delivery_attempt:debug:key', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'alarm_delivery_attempt:debug:key', UTC_TIMESTAMP(3), 'INVOKING', 'alarm_delivery_attempt_lease_token_debug')
ON DUPLICATE KEY UPDATE `delivery_id` = VALUES(`delivery_id`);

-- alarm_runtime
INSERT INTO `alarm_runtime` (`runtime_id`, `condition_key`, `latest_source_sequence`, `episode_no`, `condition_state`, `last_observed_at`, `rounds_created`, `notify_eligibility`, `row_version`, `updated_at`)
VALUES (9801, 'alarm_runtime:debug:key', 1, 1, 'NORMAL', UTC_TIMESTAMP(3), 700142, 'ELIGIBLE', 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `condition_key` = VALUES(`condition_key`);

-- audit_archive_manifest
INSERT INTO `audit_archive_manifest` (`manifest_id`, `owner_module`, `schema_version`, `object_uri`, `object_hash`, `key_version`, `row_count`, `byte_count`, `scope_snapshot`, `created_by`, `created_at`)
VALUES (9910, 'M05', 1, 'debug://audit_archive_manifest/object_uri', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'v1', 1, 1, CAST('{"debug":true,"table":"audit_archive_manifest"}' AS JSON), 9001, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `owner_module` = VALUES(`owner_module`);

-- audit_archive_record
INSERT INTO `audit_archive_record` (`record_key`, `manifest_id`, `owner_module`, `table_name`, `original_key`, `object_version`, `object_offset`, `content_hash`, `authorization_scope`, `occurred_at`, `archived_at`)
VALUES ('audit_archive_record:debug:key', 9910, 'M05', 'audit_archive_record调试样例', 'audit_archive_record:debug:key', 1, 'audit_archive_record_object_offset_debug', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', CAST('{"debug":true,"table":"audit_archive_record"}' AS JSON), UTC_TIMESTAMP(3), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `manifest_id` = VALUES(`manifest_id`);

-- audit_archive_key
INSERT INTO `audit_archive_key` (`key_hash`, `key_namespace`, `record_key`, `canonical_key`, `created_at`)
VALUES ('0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', 'audit_archive_key调试样例', 'audit_archive_key:debug:key', X'6465627567', UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `key_namespace` = VALUES(`key_namespace`);

-- lab_observation_mapping
INSERT INTO `lab_observation_mapping` (`mapping_id`, `device_kind`, `device_id`, `channel_code`, `raw_metric_code`, `mapping_version`, `item_id`, `raw_unit`, `unit`, `profile`, `effective_from`, `approved_by`, `approved_at`, `request_id`, `request_hash`)
VALUES (9920, 'INTEGRATED_REACTOR', 9964, 'LAB_OBSERVATION_MAPPING_DEBUG', 'LAB_OBSERVATION_MAPPING_DEBUG', 1, 9602, 'g', 'g', CAST('{"debug":true,"table":"lab_observation_mapping"}' AS JSON), UTC_TIMESTAMP(3), 9002, UTC_TIMESTAMP(3), '00000000-0000-4000-8000-000000000001', UNHEX(SHA2('lab_observation_mapping.request_hash',256)))
ON DUPLICATE KEY UPDATE `device_kind` = VALUES(`device_kind`);

-- lab_observation_receipt
INSERT INTO `lab_observation_receipt` (`receipt_id`, `event_key`, `identity_json`, `packet_hash`, `raw_payload_ref`, `envelope`, `device_kind`, `device_id`, `lab_id`, `channel_code`, `received_at`, `state`, `process_version`, `created_at`)
VALUES (9921, UNHEX(SHA2('lab_observation_receipt.event_key',256)), CAST('{"debug":true,"table":"lab_observation_receipt"}' AS JSON), UNHEX(SHA2('lab_observation_receipt.packet_hash',256)), 'debug://lab_observation_receipt/raw_payload_ref', CAST('{"debug":true,"table":"lab_observation_receipt"}' AS JSON), 'INTEGRATED_REACTOR', 9964, 9301, 'LAB_OBSERVATION_RECEIPT_DEBUG', UTC_TIMESTAMP(3), 'ARCHIVED', 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `event_key` = VALUES(`event_key`);

-- lab_observation_conflict
INSERT INTO `lab_observation_conflict` (`conflict_id`, `receipt_id`, `packet_hash`, `raw_payload_ref`, `identity_json`, `received_at`, `reason_code`)
VALUES (9922, 9921, UNHEX(SHA2('lab_observation_conflict.packet_hash',256)), 'debug://lab_observation_conflict/raw_payload_ref', CAST('{"debug":true,"table":"lab_observation_conflict"}' AS JSON), UTC_TIMESTAMP(3), 'EVENT_CONTENT_CONFLICT')
ON DUPLICATE KEY UPDATE `receipt_id` = VALUES(`receipt_id`);

-- lab_observation
INSERT INTO `lab_observation` (`observation_id`, `receipt_id`, `process_version`, `quality`, `validation_state`, `evidence`, `processed_at`)
VALUES (9923, 9921, 1, 'GOOD', 'QUARANTINED', CAST('{"debug":true,"table":"lab_observation"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `receipt_id` = VALUES(`receipt_id`);

-- lab_observation_association
INSERT INTO `lab_observation_association` (`association_id`, `observation_id`, `association_version`, `state`, `evidence`, `resolved_at`)
VALUES (9924, 9923, 1, 'UNASSOCIATED', CAST('{"debug":true,"table":"lab_observation_association"}' AS JSON), UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `observation_id` = VALUES(`observation_id`);

-- lab_observation_current
INSERT INTO `lab_observation_current` (`device_kind`, `device_id`, `channel_code`, `item_id`, `current_observation_id`, `observed_at`, `event_key`, `state`, `row_version`, `updated_at`)
VALUES ('INTEGRATED_REACTOR', 9964, 'LAB_OBSERVATION_CURRENT_DEBUG', 9602, 700151, UTC_TIMESTAMP(3), UNHEX(SHA2('lab_observation_current.event_key',256)), 'NORMAL', 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `current_observation_id` = VALUES(`current_observation_id`);

-- lab_observation_outbox
INSERT INTO `lab_observation_outbox` (`event_id`, `source_key`, `event_type`, `payload`, `payload_hash`, `created_at`, `publish_state`, `attempts`)
VALUES (9901, 'lab_observation_outbox:debug:key', 'debug', CAST('{"debug":true,"table":"lab_observation_outbox"}' AS JSON), UNHEX(SHA2('lab_observation_outbox.payload_hash',256)), UTC_TIMESTAMP(3), 'PENDING', 700152)
ON DUPLICATE KEY UPDATE `source_key` = VALUES(`source_key`);

-- lab_observation_monitor
INSERT INTO `lab_observation_monitor` (`condition_key`, `identity_json`, `sequence`, `evaluation_version`, `condition_state`, `evidence`, `row_version`, `updated_at`)
VALUES (UNHEX(SHA2('lab_observation_monitor.condition_key',256)), CAST('{"debug":true,"table":"lab_observation_monitor"}' AS JSON), 1, 1, 'NORMAL', CAST('{"debug":true,"table":"lab_observation_monitor"}' AS JSON), 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `identity_json` = VALUES(`identity_json`);

-- res_observation_binding_revision
INSERT INTO `res_observation_binding_revision` (`revision_id`, `device_kind`, `device_id`, `channel_code`, `revision_no`, `request_id`, `request_hash`, `evidence_ref`, `created_at`, `reason`)
VALUES (9701, 'INTEGRATED_REACTOR', 9964, 'RES_OBSERVATION_BINDING_REVISION_DEBUG', 1, '00000000-0000-4000-8000-000000000001', UNHEX(SHA2('res_observation_binding_revision.request_hash',256)), 'debug://res_observation_binding_revision/evidence_ref', UTC_TIMESTAMP(3), '开发调试样例数据')
ON DUPLICATE KEY UPDATE `device_kind` = VALUES(`device_kind`);

-- res_observation_binding_interval
INSERT INTO `res_observation_binding_interval` (`interval_id`, `revision_id`, `valid_from`, `state`, `lab_id`, `configuration_revision`, `evidence_ref`)
VALUES (9925, 9701, UTC_TIMESTAMP(3), 'UNASSOCIATED', 9301, 'res_observation_binding_interval_configuration_revision_debug', 'debug://res_observation_binding_interval/evidence_ref')
ON DUPLICATE KEY UPDATE `revision_id` = VALUES(`revision_id`);

-- run_observation_monitor
INSERT INTO `run_observation_monitor` (`condition_key`, `identity_json`, `sequence`, `evaluation_version`, `condition_state`, `evidence`, `row_version`, `updated_at`)
VALUES (UNHEX(SHA2('run_observation_monitor.condition_key',256)), CAST('{"debug":true,"table":"run_observation_monitor"}' AS JSON), 1, 1, 'NORMAL', CAST('{"debug":true,"table":"run_observation_monitor"}' AS JSON), 1, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `identity_json` = VALUES(`identity_json`);

-- lab_workflow_node
INSERT INTO `lab_workflow_node` (`lab_id`, `node_id`)
VALUES (9301, 9930)
ON DUPLICATE KEY UPDATE `lab_id` = VALUES(`lab_id`);

-- sys_downstream_device
INSERT INTO `sys_downstream_device` (`device_id`, `device_name`, `device_type`)
VALUES (9964, 'sys_downstream_device调试样例', 'sdms')
ON DUPLICATE KEY UPDATE `device_name` = VALUES(`device_name`);

-- sys_job
INSERT INTO `sys_job` (`job_id`, `job_name`, `job_group`, `invoke_target`)
VALUES (9940, 'sys_job调试样例', 'sys_job_job_group_debug', 'sys_job_invoke_target_debug')
ON DUPLICATE KEY UPDATE `invoke_target` = VALUES(`invoke_target`);

-- sys_job_log
INSERT INTO `sys_job_log` (`job_log_id`, `job_name`, `job_group`, `invoke_target`)
VALUES (9941, 'sys_job_log调试样例', 'sys_job_log_job_group_debug', 'sys_job_log_invoke_target_debug')
ON DUPLICATE KEY UPDATE `job_name` = VALUES(`job_name`);

-- sys_notice
INSERT INTO `sys_notice` (`notice_id`, `notice_title`, `notice_type`)
VALUES (9942, '开发调试通知', '1')
ON DUPLICATE KEY UPDATE `notice_title` = VALUES(`notice_title`);

-- sys_notice_read
INSERT INTO `sys_notice_read` (`read_id`, `notice_id`, `user_id`, `read_time`)
VALUES (9943, 9942, 9001, UTC_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE `notice_id` = VALUES(`notice_id`);

-- sys_post
INSERT INTO `sys_post` (`post_id`, `post_code`, `post_name`, `post_sort`, `status`)
VALUES (9203, 'SYS_POST_DEBUG', 'sys_post调试样例', 700163, '0')
ON DUPLICATE KEY UPDATE `post_code` = VALUES(`post_code`);

-- sys_user_post
INSERT INTO `sys_user_post` (`user_id`, `post_id`)
VALUES (9001, 9203)
ON DUPLICATE KEY UPDATE `user_id` = VALUES(`user_id`);

-- workflow_node
INSERT INTO `workflow_node` (`node_id`, `node_name`, `node_code`, `icon_path`)
VALUES (9930, 'workflow_node调试样例', 'WORKFLOW_NODE_DEBUG', 'debug://workflow_node/icon_path')
ON DUPLICATE KEY UPDATE `node_name` = VALUES(`node_name`);

-- workflow_step
INSERT INTO `workflow_step` (`step_id`, `node_id`, `step_order`, `step_name`)
VALUES (9931, 9930, 1, 'workflow_step调试样例')
ON DUPLICATE KEY UPDATE `node_id` = VALUES(`node_id`);

-- workflow_subflow
INSERT INTO `workflow_subflow` (`subflow_id`, `node_id`, `subflow_code`, `subflow_name`)
VALUES (9932, 9930, 'WORKFLOW_SUBFLOW_DEBUG', 'workflow_subflow调试样例')
ON DUPLICATE KEY UPDATE `node_id` = VALUES(`node_id`);

-- 执行前建议先在本地调试库 review 本脚本；确认后提交。
COMMIT;
