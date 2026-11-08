-- 只读。确认目标库、MySQL版本及CHECK强制执行能力；输出不满足条件即停止，不自行覆盖已有字段。
SELECT DATABASE() AS target_database, VERSION() AS mysql_version;
SHOW CREATE TABLE res_culture;
SHOW CREATE TABLE res_culture_change_candidate;
SELECT COLUMN_NAME,COLUMN_TYPE,IS_NULLABLE,COLUMN_DEFAULT FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='res_culture' AND COLUMN_NAME LIKE 'initial_weight%';
-- 预期上条0行；已有同名字段必须人工比对来源，不能再次运行20。
SELECT scene_code,state,COUNT(*) AS count_rows FROM res_culture_change_candidate
 WHERE scene_code IN ('M06_SC029','M06_SC030') GROUP BY scene_code,state;
-- M06已有SC030审批/交付及原owner候选必须按真实表核对并结案；本脚本不猜测并改写M06表。
