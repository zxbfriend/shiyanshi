-- 2026-09-10 M06设计稿，未执行。目标MySQL8.0.16+的8.x，无外键。
-- 禁止--force；DDL隐式提交，部分失败停止保留现场。
SET NAMES utf8mb4;
-- 只读：目标库及版本、同名表、依赖必须核对；原生一致性备份/恢复演练由运维完成。
SELECT DATABASE() AS target_database,VERSION() AS server_version;
SELECT table_name,engine FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('apr_scene','apr_lab_policy','apr_policy_revision','apr_request','apr_action','apr_delivery','lab_lab','res_project','res_batch','res_culture','sys_management_revision','sys_management_request');
-- 与已核准M01/M02/M03完整目标逐字段核对，不以表存在代替目标列/授权契约已就绪。
