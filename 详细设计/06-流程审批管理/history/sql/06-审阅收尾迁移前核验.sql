-- M06 只读前置；必须逐列/索引/CHECK与原完整目标比对，不以数量相同代替一致。
SELECT DATABASE(),VERSION();
SELECT table_name,column_name,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('apr_scene','apr_lab_policy','apr_policy_revision','apr_request','apr_action','apr_delivery') ORDER BY table_name,ordinal_position;
SHOW CREATE TABLE `apr_scene`;
SHOW CREATE TABLE `apr_lab_policy`;
SHOW CREATE TABLE `apr_policy_revision`;
SHOW CREATE TABLE `apr_request`;
SHOW CREATE TABLE `apr_action`;
SHOW CREATE TABLE `apr_delivery`;
SELECT 'ck_apr_close_ack_kind' AS check_name,COUNT(*) AS invalid_rows FROM `apr_delivery` WHERE (state<>'ACKNOWLEDGED' OR (owner_receipt IS NOT NULL AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(owner_receipt,'$.status')),'')=CASE WHEN decision_kind='APPLY' THEN 'APPLIED' ELSE 'DISCARDED' END)) IS FALSE;
-- 任一invalid_rows非0则停止；保留原数据，不自动清洗。备份与维护核准完成才设置本包维护/基线/备份确认变量。
