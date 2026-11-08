-- M03 SQL设计稿；2026-09-09；未在数据库执行。MySQL 8.0.16+，须在实际小版本隔离演练。
-- 先读主设计第5/6节。逐阶段执行，错误立即停止；DDL隐式提交，不能整包盲跑。
-- 旧datetime与M01审计保持上海业务时区；明确标UTC的新列仅写UTC值。
SET NAMES utf8mb4;
SET SESSION time_zone = '+08:00';

-- 先按03导入真实核准记录。此脚本无猜测回填，无示例业务数据。
-- 所有相关写/消费者必须仍停止；DML事务失败整体回滚。重复运行BACKFILLED会明确拒绝。
DELIMITER $$
CREATE PROCEDURE m03_apply_review_20260909()
BEGIN
  DECLARE v_revision bigint;
  DECLARE v_phase varchar(16);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT revision INTO v_revision FROM sys_management_revision WHERE scope_key='SYSTEM' FOR UPDATE;
  SELECT phase INTO v_phase FROM m03_migration_run WHERE run_key='M03_20260909' FOR UPDATE;
  IF v_revision IS NULL OR v_phase IS NULL OR v_phase <> 'EXPANDED' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='M03 migration stage or SYSTEM guard missing';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_run WHERE run_key='M03_20260909' AND system_revision_before<>v_revision) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='SYSTEM changed during migration review';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project` t LEFT JOIN `m03_bak_20260909_res_project` b ON b.`project_id`=t.`project_id` WHERE b.`project_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`project_id`,b.`project_name`,b.`project_code`,b.`dept_id`,b.`project_status`,b.`start_date`,b.`end_date`,b.`del_flag`,b.`create_by`,b.`create_time`,b.`update_by`,b.`update_time`,b.`remark`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`project_name`,t.`project_code`,t.`dept_id`,t.`project_status`,t.`start_date`,t.`end_date`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_project';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_project` b LEFT JOIN `res_project` t ON b.`project_id`=t.`project_id` WHERE t.`project_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_project';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project_leader` t LEFT JOIN `m03_bak_20260909_res_project_leader` b ON b.`project_id`=t.`project_id` AND b.`user_id`=t.`user_id` WHERE b.`project_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`project_id`,b.`user_id`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`user_id`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_project_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_project_leader` b LEFT JOIN `res_project_leader` t ON b.`project_id`=t.`project_id` AND b.`user_id`=t.`user_id` WHERE t.`project_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_project_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project_lab` t LEFT JOIN `m03_bak_20260909_res_project_lab` b ON b.`project_id`=t.`project_id` AND b.`lab_id`=t.`lab_id` WHERE b.`project_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`project_id`,b.`lab_id`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`lab_id`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_project_lab';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_project_lab` b LEFT JOIN `res_project_lab` t ON b.`project_id`=t.`project_id` AND b.`lab_id`=t.`lab_id` WHERE t.`project_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_project_lab';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project_tag` t LEFT JOIN `m03_bak_20260909_res_project_tag` b ON b.`project_id`=t.`project_id` AND b.`dict_code`=t.`dict_code` AND b.`tag_value`=t.`tag_value` WHERE b.`project_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`project_id`,b.`dict_code`,b.`tag_value`,b.`tag_label`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`dict_code`,t.`tag_value`,t.`tag_label`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_project_tag';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_project_tag` b LEFT JOIN `res_project_tag` t ON b.`project_id`=t.`project_id` AND b.`dict_code`=t.`dict_code` AND b.`tag_value`=t.`tag_value` WHERE t.`project_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_project_tag';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project_member` t LEFT JOIN `m03_bak_20260909_res_project_member` b ON b.`project_id`=t.`project_id` AND b.`user_id`=t.`user_id` WHERE b.`project_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`project_id`,b.`user_id`,b.`permission_type`,b.`expire_date`,b.`source_type`,b.`joined_time`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`,t.`joined_time`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_project_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_project_member` b LEFT JOIN `res_project_member` t ON b.`project_id`=t.`project_id` AND b.`user_id`=t.`user_id` WHERE t.`project_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_project_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_batch` t LEFT JOIN `m03_bak_20260909_res_batch` b ON b.`batch_id`=t.`batch_id` WHERE b.`batch_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`batch_id`,b.`project_id`,b.`lab_id`,b.`batch_name`,b.`batch_code`,b.`alias`,b.`batch_status`,b.`start_time`,b.`end_time`,b.`titer`,b.`del_flag`,b.`create_by`,b.`create_time`,b.`update_by`,b.`update_time`,b.`remark`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`project_id`,t.`lab_id`,t.`batch_name`,t.`batch_code`,t.`alias`,t.`batch_status`,t.`start_time`,t.`end_time`,t.`titer`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_batch';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_batch` b LEFT JOIN `res_batch` t ON b.`batch_id`=t.`batch_id` WHERE t.`batch_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_batch';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_batch_leader` t LEFT JOIN `m03_bak_20260909_res_batch_leader` b ON b.`batch_id`=t.`batch_id` AND b.`user_id`=t.`user_id` WHERE b.`batch_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`batch_id`,b.`user_id`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`user_id`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_batch_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_batch_leader` b LEFT JOIN `res_batch_leader` t ON b.`batch_id`=t.`batch_id` AND b.`user_id`=t.`user_id` WHERE t.`batch_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_batch_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_batch_member` t LEFT JOIN `m03_bak_20260909_res_batch_member` b ON b.`batch_id`=t.`batch_id` AND b.`user_id`=t.`user_id` WHERE b.`batch_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`batch_id`,b.`user_id`,b.`permission_type`,b.`expire_date`,b.`source_type`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_batch_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_batch_member` b LEFT JOIN `res_batch_member` t ON b.`batch_id`=t.`batch_id` AND b.`user_id`=t.`user_id` WHERE t.`batch_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_batch_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_culture` t LEFT JOIN `m03_bak_20260909_res_culture` b ON b.`culture_id`=t.`culture_id` WHERE b.`culture_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`culture_id`,b.`project_id`,b.`batch_id`,b.`lab_id`,b.`culture_code`,b.`culture_name`,b.`culture_mode`,b.`is_special`,b.`reactor_type`,b.`reactor_id`,b.`container_id`,b.`cell_type`,b.`culture_status`,b.`start_time`,b.`end_time`,b.`del_flag`,b.`create_by`,b.`create_time`,b.`update_by`,b.`update_time`,b.`remark`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`project_id`,t.`batch_id`,t.`lab_id`,t.`culture_code`,t.`culture_name`,t.`culture_mode`,t.`is_special`,t.`reactor_type`,t.`reactor_id`,t.`container_id`,t.`cell_type`,t.`culture_status`,t.`start_time`,t.`end_time`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_culture';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_culture` b LEFT JOIN `res_culture` t ON b.`culture_id`=t.`culture_id` WHERE t.`culture_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_culture';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_culture_leader` t LEFT JOIN `m03_bak_20260909_res_culture_leader` b ON b.`culture_id`=t.`culture_id` AND b.`user_id`=t.`user_id` WHERE b.`culture_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`culture_id`,b.`user_id`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`user_id`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_culture_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_culture_leader` b LEFT JOIN `res_culture_leader` t ON b.`culture_id`=t.`culture_id` AND b.`user_id`=t.`user_id` WHERE t.`culture_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_culture_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_culture_member` t LEFT JOIN `m03_bak_20260909_res_culture_member` b ON b.`culture_id`=t.`culture_id` AND b.`user_id`=t.`user_id` WHERE b.`culture_id` IS NULL OR SHA2(CAST(JSON_ARRAY(b.`culture_id`,b.`user_id`,b.`permission_type`,b.`expire_date`,b.`source_type`) AS CHAR CHARACTER SET utf8mb4),256)<>SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`) AS CHAR CHARACTER SET utf8mb4),256)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source changed since backup: res_culture_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `m03_bak_20260909_res_culture_member` b LEFT JOIN `res_culture_member` t ON b.`culture_id`=t.`culture_id` AND b.`user_id`=t.`user_id` WHERE t.`culture_id` IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source deleted since backup: res_culture_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project` t WHERE t.project_id<=0 OR t.del_flag IS NULL OR t.del_flag NOT IN ('0','2') OR CHAR_LENGTH(TRIM(t.project_code))=0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid baseline flag/code: res_project';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project` t LEFT JOIN m03_migration_object_review r ON r.target_type='PROJECT' AND r.target_id=t.project_id LEFT JOIN sys_user u ON u.user_id=r.creator_user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id WHERE t.del_flag='0' AND (r.target_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`project_name`,t.`project_code`,t.`dept_id`,t.`project_status`,t.`start_date`,t.`end_date`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing/stale creator review: res_project';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_object_review r LEFT JOIN `res_project` t ON t.project_id=r.target_id WHERE r.target_type='PROJECT' AND t.project_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unexpected object review: res_project';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_object_review r JOIN `res_project` t ON t.project_id=r.target_id LEFT JOIN sys_user u ON u.user_id=r.creator_user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id WHERE r.target_type='PROJECT' AND (r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`project_name`,t.`project_code`,t.`dept_id`,t.`project_status`,t.`start_date`,t.`end_date`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid optional historical review: res_project';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_batch` t WHERE t.batch_id<=0 OR t.del_flag IS NULL OR t.del_flag NOT IN ('0','2') OR CHAR_LENGTH(TRIM(t.batch_code))=0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid baseline flag/code: res_batch';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_batch` t LEFT JOIN m03_migration_object_review r ON r.target_type='BATCH' AND r.target_id=t.batch_id LEFT JOIN sys_user u ON u.user_id=r.creator_user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id WHERE t.del_flag='0' AND (r.target_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`project_id`,t.`lab_id`,t.`batch_name`,t.`batch_code`,t.`alias`,t.`batch_status`,t.`start_time`,t.`end_time`,t.`titer`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing/stale creator review: res_batch';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_object_review r LEFT JOIN `res_batch` t ON t.batch_id=r.target_id WHERE r.target_type='BATCH' AND t.batch_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unexpected object review: res_batch';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_object_review r JOIN `res_batch` t ON t.batch_id=r.target_id LEFT JOIN sys_user u ON u.user_id=r.creator_user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id WHERE r.target_type='BATCH' AND (r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`project_id`,t.`lab_id`,t.`batch_name`,t.`batch_code`,t.`alias`,t.`batch_status`,t.`start_time`,t.`end_time`,t.`titer`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid optional historical review: res_batch';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_culture` t WHERE t.culture_id<=0 OR t.del_flag IS NULL OR t.del_flag NOT IN ('0','2') OR CHAR_LENGTH(TRIM(t.culture_code))=0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid baseline flag/code: res_culture';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_culture` t LEFT JOIN m03_migration_object_review r ON r.target_type='CULTURE' AND r.target_id=t.culture_id LEFT JOIN sys_user u ON u.user_id=r.creator_user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id WHERE t.del_flag='0' AND (r.target_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`project_id`,t.`batch_id`,t.`lab_id`,t.`culture_code`,t.`culture_name`,t.`culture_mode`,t.`is_special`,t.`reactor_type`,t.`reactor_id`,t.`container_id`,t.`cell_type`,t.`culture_status`,t.`start_time`,t.`end_time`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing/stale creator review: res_culture';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_object_review r LEFT JOIN `res_culture` t ON t.culture_id=r.target_id WHERE r.target_type='CULTURE' AND t.culture_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unexpected object review: res_culture';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_object_review r JOIN `res_culture` t ON t.culture_id=r.target_id LEFT JOIN sys_user u ON u.user_id=r.creator_user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id WHERE r.target_type='CULTURE' AND (r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`project_id`,t.`batch_id`,t.`lab_id`,t.`culture_code`,t.`culture_name`,t.`culture_mode`,t.`is_special`,t.`reactor_type`,t.`reactor_id`,t.`container_id`,t.`cell_type`,t.`culture_status`,t.`start_time`,t.`end_time`,t.`del_flag`,t.`create_by`,t.`create_time`,t.`update_by`,t.`update_time`,t.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid optional historical review: res_culture';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_object_review WHERE target_type NOT IN ('PROJECT','BATCH','CULTURE')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unknown object review type';
  END IF;
  IF EXISTS (SELECT 1 FROM res_batch b LEFT JOIN res_project p ON p.project_id=b.project_id LEFT JOIN lab_lab l ON l.lab_id=b.lab_id LEFT JOIN res_project_lab r ON r.project_id=b.project_id AND r.lab_id=b.lab_id WHERE b.del_flag='0' AND (p.project_id IS NULL OR p.del_flag<>'0' OR l.lab_id IS NULL OR r.project_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid active batch parent/lab';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture c LEFT JOIN res_batch b ON b.batch_id=c.batch_id WHERE c.del_flag='0' AND (b.batch_id IS NULL OR b.del_flag<>'0' OR b.project_id<>c.project_id OR b.lab_id<>c.lab_id)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid active culture parent';
  END IF;
  IF EXISTS (SELECT 1 FROM res_project p LEFT JOIN sys_dept d ON d.dept_id=p.dept_id WHERE p.del_flag='0' AND (d.dept_id IS NULL OR NOT EXISTS(SELECT 1 FROM res_project_leader r WHERE r.project_id=p.project_id) OR NOT EXISTS(SELECT 1 FROM res_project_lab r WHERE r.project_id=p.project_id))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing active project dept/leader/lab';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project_leader` r LEFT JOIN res_project t ON t.project_id=r.project_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE t.project_id IS NULL OR (t.del_flag='0' AND u.user_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid leader reference: res_project_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_batch_leader` r LEFT JOIN res_batch t ON t.batch_id=r.batch_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE t.batch_id IS NULL OR (t.del_flag='0' AND u.user_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid leader reference: res_batch_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_culture_leader` r LEFT JOIN res_culture t ON t.culture_id=r.culture_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE t.culture_id IS NULL OR (t.del_flag='0' AND u.user_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid leader reference: res_culture_leader';
  END IF;
  IF EXISTS (SELECT 1 FROM res_project_lab r LEFT JOIN res_project p ON p.project_id=r.project_id LEFT JOIN lab_lab l ON l.lab_id=r.lab_id WHERE p.project_id IS NULL OR (p.del_flag='0' AND l.lab_id IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid project lab relation';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture c LEFT JOIN m03_migration_culture_review r ON r.culture_id=c.culture_id LEFT JOIN sys_user u ON u.user_id=r.reviewer_user_id WHERE c.del_flag='0' AND (r.culture_id IS NULL OR u.user_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(c.`culture_id`,c.`project_id`,c.`batch_id`,c.`lab_id`,c.`culture_code`,c.`culture_name`,c.`culture_mode`,c.`is_special`,c.`reactor_type`,c.`reactor_id`,c.`container_id`,c.`cell_type`,c.`culture_status`,c.`start_time`,c.`end_time`,c.`del_flag`,c.`create_by`,c.`create_time`,c.`update_by`,c.`update_time`,c.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing/stale culture facts review';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r LEFT JOIN res_culture c ON c.culture_id=r.culture_id WHERE c.culture_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unexpected culture review';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r JOIN res_culture c ON c.culture_id=r.culture_id LEFT JOIN sys_user u ON u.user_id=r.reviewer_user_id WHERE u.user_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(c.`culture_id`,c.`project_id`,c.`batch_id`,c.`lab_id`,c.`culture_code`,c.`culture_name`,c.`culture_mode`,c.`is_special`,c.`reactor_type`,c.`reactor_id`,c.`container_id`,c.`cell_type`,c.`culture_status`,c.`start_time`,c.`end_time`,c.`del_flag`,c.`create_by`,c.`create_time`,c.`update_by`,c.`update_time`,c.`remark`) AS CHAR CHARACTER SET utf8mb4),256) OR CHAR_LENGTH(TRIM(r.evidence_ref))=0 OR NOT EXISTS (SELECT 1 FROM m03_migration_object_review o WHERE o.target_type='CULTURE' AND o.target_id=c.culture_id)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid optional culture review';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r WHERE r.lifecycle_state NOT IN ('DRAFT','NOT_STARTED','RUNNING','EXPIRED','DELAYED','CANCELLED','FINISHED') OR r.mode_code NOT IN ('NORMAL','REACTOR') OR r.member_setup_state NOT IN ('NEVER','CONFIGURED') OR r.n_marked NOT IN (0,1) OR r.start_delay_active NOT IN (0,1) OR r.end_delay_active NOT IN (0,1)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid reviewed culture enum';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r WHERE (r.planned_duration_days IS NOT NULL AND r.planned_duration_days<1) OR (r.planned_start_date IS NOT NULL AND r.planned_end_date IS NOT NULL AND (r.planned_end_date<r.planned_start_date OR r.planned_duration_days IS NULL OR r.planned_duration_days<>DATEDIFF(r.planned_end_date,r.planned_start_date)+1)) OR (((r.planned_start_date IS NULL)<>(r.planned_end_date IS NULL)) AND r.planned_duration_days IS NOT NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed dates/duration inconsistent';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r WHERE (r.lifecycle_state IN ('NOT_STARTED','RUNNING','EXPIRED','DELAYED') AND (r.planned_start_date IS NULL OR r.planned_end_date IS NULL)) OR (r.lifecycle_state='DRAFT' AND r.planned_start_date IS NOT NULL AND r.planned_end_date IS NOT NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed state/plan inconsistent';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r WHERE (r.lifecycle_state='RUNNING' AND r.first_workflow_started_at IS NULL) OR (r.lifecycle_state='FINISHED' AND r.end_completed_at IS NULL) OR (r.lifecycle_state='CANCELLED' AND r.cancel_confirmed_at IS NULL) OR (r.lifecycle_state='DELAYED' AND (r.first_workflow_started_at IS NULL OR (r.start_delay_active=0 AND r.end_delay_active=0))) OR (r.lifecycle_state IN ('DRAFT','NOT_STARTED','EXPIRED') AND r.first_workflow_started_at IS NOT NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed runtime evidence missing';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r WHERE r.occupancy_state NOT IN ('NONE','RESERVED','RUNNING','RELEASE_PENDING') OR (r.occupancy_state='NONE' AND (r.occupancy_id IS NOT NULL OR r.occupancy_acquired_at IS NOT NULL)) OR (r.occupancy_state<>'NONE' AND (r.occupancy_id IS NULL OR r.occupancy_id<=0 OR r.occupancy_acquired_at IS NULL)) OR (r.lifecycle_state IN ('DRAFT','EXPIRED') AND r.occupancy_state<>'NONE') OR (r.lifecycle_state='NOT_STARTED' AND r.occupancy_state<>'RESERVED') OR (r.lifecycle_state IN ('RUNNING','DELAYED') AND r.occupancy_state<>'RUNNING') OR (r.lifecycle_state IN ('FINISHED','CANCELLED') AND r.occupancy_state NOT IN ('NONE','RELEASE_PENDING'))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed occupancy/state inconsistent';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r JOIN res_culture c ON c.culture_id=r.culture_id LEFT JOIN lab_integrated_reactor i ON r.device_kind='INTEGRATED_REACTOR' AND i.integrated_id=r.device_id LEFT JOIN lab_culture_container v ON r.device_kind='CULTURE_CONTAINER' AND v.container_id=r.device_id LEFT JOIN lab_bench_reactor b ON r.device_kind='BENCH_CONTROLLER' AND b.reactor_id=r.device_id WHERE r.device_id<=0 OR r.device_kind NOT IN ('INTEGRATED_REACTOR','CULTURE_CONTAINER','BENCH_CONTROLLER') OR (r.device_kind='INTEGRATED_REACTOR' AND (i.integrated_id IS NULL OR i.lab_id<>c.lab_id)) OR (r.device_kind='CULTURE_CONTAINER' AND (v.container_id IS NULL OR v.lab_id<>c.lab_id)) OR (r.device_kind='BENCH_CONTROLLER' AND (b.reactor_id IS NULL OR b.lab_id<>c.lab_id OR r.mode_code<>'NORMAL')) OR (r.occupancy_state<>'NONE' AND COALESCE(i.del_flag,v.del_flag,b.del_flag,'2')<>'0')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed device identity/lab invalid';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review WHERE occupancy_state<>'NONE' GROUP BY device_kind,device_id HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Multiple cultures claim same device';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review WHERE occupancy_state<>'NONE' GROUP BY occupancy_id HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate occupancy id';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r JOIN res_culture c ON c.culture_id=r.culture_id WHERE c.del_flag='2' AND r.occupancy_state<>'NONE') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Deleted culture cannot own current occupancy';
  END IF;
  IF EXISTS (SELECT 1 FROM res_project WHERE del_flag='0' GROUP BY TRIM(project_code) HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed live code conflict: project';
  END IF;
  IF EXISTS (SELECT 1 FROM res_batch WHERE del_flag='0' GROUP BY project_id,TRIM(batch_code) HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed live code conflict: batch';
  END IF;
  IF EXISTS (SELECT 1 FROM res_culture c LEFT JOIN m03_migration_culture_review r ON r.culture_id=c.culture_id WHERE c.del_flag='0' AND COALESCE(r.lifecycle_state,'UNKNOWN')<>'CANCELLED' GROUP BY TRIM(c.culture_code) HAVING COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Reviewed global culture code conflict';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_project_member` t JOIN res_project p ON p.project_id=t.project_id WHERE p.del_flag='0' AND NOT EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE r.target_type='PROJECT' AND r.target_id=t.project_id AND r.user_id=t.user_id)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing active grant review: res_project_member';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r LEFT JOIN `m03_bak_20260909_res_project_member` t ON t.project_id=r.target_id AND t.user_id=r.user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE r.target_type='PROJECT' AND (t.project_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`project_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`,t.`joined_time`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Stale/unproven grant review: res_project_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_batch_member` t JOIN res_batch p ON p.batch_id=t.batch_id WHERE p.del_flag='0' AND NOT EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE r.target_type='BATCH' AND r.target_id=t.batch_id AND r.user_id=t.user_id)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing active grant review: res_batch_member';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r LEFT JOIN `m03_bak_20260909_res_batch_member` t ON t.batch_id=r.target_id AND t.user_id=r.user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE r.target_type='BATCH' AND (t.batch_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`batch_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Stale/unproven grant review: res_batch_member';
  END IF;
  IF EXISTS (SELECT 1 FROM `res_culture_member` t JOIN res_culture p ON p.culture_id=t.culture_id WHERE p.del_flag='0' AND NOT EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE r.target_type='CULTURE' AND r.target_id=t.culture_id AND r.user_id=t.user_id)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Missing active grant review: res_culture_member';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r LEFT JOIN `m03_bak_20260909_res_culture_member` t ON t.culture_id=r.target_id AND t.user_id=r.user_id LEFT JOIN sys_user v ON v.user_id=r.reviewer_user_id LEFT JOIN sys_user u ON u.user_id=r.user_id WHERE r.target_type='CULTURE' AND (t.culture_id IS NULL OR r.source_hash<>SHA2(CAST(JSON_ARRAY(t.`culture_id`,t.`user_id`,t.`permission_type`,t.`expire_date`,t.`source_type`) AS CHAR CHARACTER SET utf8mb4),256) OR u.user_id IS NULL OR v.user_id IS NULL OR CHAR_LENGTH(TRIM(r.evidence_ref))=0)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Stale/unproven grant review: res_culture_member';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review WHERE target_type NOT IN ('PROJECT','BATCH','CULTURE') OR decision NOT IN ('MEMBER','SHARE','INHERITED','RETIRED')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unknown grant review decision';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review GROUP BY target_type,target_id,user_id HAVING SUM(decision IN ('INHERITED','RETIRED'))>0 AND COUNT(*)>1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Conflicting grant review decisions';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE (r.decision='INHERITED' AND (r.target_type='PROJECT' OR r.source_target_type IS NULL OR r.source_target_type NOT IN ('PROJECT','BATCH') OR r.source_target_id IS NULL OR r.source_grant_type IS NULL OR r.source_grant_type NOT IN ('MEMBER','SHARE','CREATOR','LEADER'))) OR (r.decision<>'INHERITED' AND (r.source_target_type IS NOT NULL OR r.source_target_id IS NOT NULL OR r.source_grant_type IS NOT NULL))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid inherited source metadata';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r LEFT JOIN res_batch b ON r.target_type='BATCH' AND b.batch_id=r.target_id LEFT JOIN res_culture c ON r.target_type='CULTURE' AND c.culture_id=r.target_id WHERE r.decision='INHERITED' AND NOT ((r.target_type='BATCH' AND r.source_target_type='PROJECT' AND r.source_target_id=b.project_id) OR (r.target_type='CULTURE' AND ((r.source_target_type='PROJECT' AND r.source_target_id=c.project_id) OR (r.source_target_type='BATCH' AND r.source_target_id=c.batch_id))))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Inherited source is not actual ancestor';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_grant_review r WHERE r.decision='INHERITED' AND ((r.source_grant_type IN ('MEMBER','SHARE') AND NOT EXISTS (SELECT 1 FROM m03_migration_grant_review p WHERE p.target_type=r.source_target_type AND p.target_id=r.source_target_id AND p.user_id=r.user_id AND p.decision=r.source_grant_type)) OR (r.source_grant_type='CREATOR' AND NOT EXISTS (SELECT 1 FROM m03_migration_object_review p WHERE p.target_type=r.source_target_type AND p.target_id=r.source_target_id AND p.creator_user_id=r.user_id)) OR (r.source_grant_type='LEADER' AND NOT ((r.source_target_type='PROJECT' AND EXISTS (SELECT 1 FROM res_project_leader p WHERE p.project_id=r.source_target_id AND p.user_id=r.user_id)) OR (r.source_target_type='BATCH' AND EXISTS (SELECT 1 FROM res_batch_leader p WHERE p.batch_id=r.source_target_id AND p.user_id=r.user_id)))))) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Inherited source has no reviewed evidence';
  END IF;
  IF EXISTS (SELECT 1 FROM m03_migration_culture_review r JOIN m03_migration_grant_review g ON g.target_type='CULTURE' AND g.target_id=r.culture_id AND g.decision='MEMBER' WHERE r.member_setup_state<>'CONFIGURED') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Direct members require setup history';
  END IF;
  UPDATE res_project t JOIN m03_migration_object_review r ON r.target_type='PROJECT' AND r.target_id=t.project_id SET t.creator_user_id=r.creator_user_id,t.facts_status='READY';
  UPDATE res_batch t JOIN m03_migration_object_review r ON r.target_type='BATCH' AND r.target_id=t.batch_id SET t.creator_user_id=r.creator_user_id,t.facts_status='READY';
  UPDATE res_culture t JOIN m03_migration_object_review r ON r.target_type='CULTURE' AND r.target_id=t.culture_id SET t.creator_user_id=r.creator_user_id;
  UPDATE res_culture c JOIN m03_migration_culture_review r ON r.culture_id=c.culture_id JOIN m03_migration_object_review o ON o.target_type='CULTURE' AND o.target_id=c.culture_id SET c.lifecycle_state=r.lifecycle_state,c.mode_code=r.mode_code,c.device_kind=r.device_kind,c.device_id=r.device_id,c.planned_start_date=r.planned_start_date,c.planned_end_date=r.planned_end_date,c.planned_duration_days=r.planned_duration_days,c.n_marked=r.n_marked,c.member_setup_state=r.member_setup_state,c.first_workflow_started_at=r.first_workflow_started_at,c.start_completed_at=r.start_completed_at,c.end_completed_at=r.end_completed_at,c.cancel_confirmed_at=r.cancel_confirmed_at,c.start_delay_at=r.start_delay_at,c.end_delay_at=r.end_delay_at,c.start_delay_active=r.start_delay_active,c.end_delay_active=r.end_delay_active,c.facts_status='READY',c.runtime_evidence_ref=r.evidence_ref,c.plan_version=CASE WHEN r.planned_start_date IS NOT NULL OR r.planned_end_date IS NOT NULL OR r.planned_duration_days IS NOT NULL THEN 1 ELSE 0 END;
  INSERT INTO res_culture_occupancy (occupancy_id,culture_id,device_kind,device_id,lab_id,occupancy_state,acquired_at,released_at,release_reason,release_evidence_ref,created_request_id,object_version) SELECT r.occupancy_id,r.culture_id,r.device_kind,r.device_id,c.lab_id,r.occupancy_state,r.occupancy_acquired_at,NULL,NULL,NULL,'M03_20260909',1 FROM m03_migration_culture_review r JOIN res_culture c ON c.culture_id=r.culture_id WHERE r.occupancy_state<>'NONE';
  INSERT INTO `res_project_member` (`project_id`,user_id,permission_type,expire_date,source_type,grant_type,granted_at,granted_by_user_id,modified_at,modified_by_user_id,selection_origin,selection_ref,joined_time) SELECT r.target_id,r.user_id,b.permission_type,r.expire_date,b.source_type,r.decision,r.granted_at,NULL,NULL,NULL,NULL,r.evidence_ref,b.joined_time FROM m03_migration_grant_review r JOIN `m03_bak_20260909_res_project_member` b ON b.project_id=r.target_id AND b.user_id=r.user_id WHERE r.target_type='PROJECT' AND r.decision IN ('MEMBER','SHARE');
  DELETE t FROM `res_project_member` t JOIN m03_migration_grant_review r ON r.target_type='PROJECT' AND r.target_id=t.project_id AND r.user_id=t.user_id WHERE t.grant_type='LEGACY';
  INSERT INTO `res_batch_member` (`batch_id`,user_id,permission_type,expire_date,source_type,grant_type,granted_at,granted_by_user_id,modified_at,modified_by_user_id,selection_origin,selection_ref) SELECT r.target_id,r.user_id,b.permission_type,r.expire_date,b.source_type,r.decision,r.granted_at,NULL,NULL,NULL,NULL,r.evidence_ref FROM m03_migration_grant_review r JOIN `m03_bak_20260909_res_batch_member` b ON b.batch_id=r.target_id AND b.user_id=r.user_id WHERE r.target_type='BATCH' AND r.decision IN ('MEMBER','SHARE');
  DELETE t FROM `res_batch_member` t JOIN m03_migration_grant_review r ON r.target_type='BATCH' AND r.target_id=t.batch_id AND r.user_id=t.user_id WHERE t.grant_type='LEGACY';
  INSERT INTO `res_culture_member` (`culture_id`,user_id,permission_type,expire_date,source_type,grant_type,granted_at,granted_by_user_id,modified_at,modified_by_user_id,selection_origin,selection_ref) SELECT r.target_id,r.user_id,b.permission_type,r.expire_date,b.source_type,r.decision,r.granted_at,NULL,NULL,NULL,NULL,r.evidence_ref FROM m03_migration_grant_review r JOIN `m03_bak_20260909_res_culture_member` b ON b.culture_id=r.target_id AND b.user_id=r.user_id WHERE r.target_type='CULTURE' AND r.decision IN ('MEMBER','SHARE');
  DELETE t FROM `res_culture_member` t JOIN m03_migration_grant_review r ON r.target_type='CULTURE' AND r.target_id=t.culture_id AND r.user_id=t.user_id WHERE t.grant_type='LEGACY';
  UPDATE sys_management_revision SET revision=revision+1,update_time=CURRENT_TIMESTAMP(3) WHERE scope_key='SYSTEM';
  UPDATE m03_migration_run SET phase='BACKFILLED',system_revision_after=v_revision+1 WHERE run_key='M03_20260909';
  COMMIT;
END$$
DELIMITER ;
CALL m03_apply_review_20260909();
DROP PROCEDURE m03_apply_review_20260909;
