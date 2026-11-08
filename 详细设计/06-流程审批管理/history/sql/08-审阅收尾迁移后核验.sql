-- M06 后置只读设计；预期7表127列。旧列逐主键与备份逐值核对，不只看计数。
SHOW CREATE TABLE `apr_scene`;
SHOW CREATE TABLE `apr_lab_policy`;
SHOW CREATE TABLE `apr_policy_revision`;
SHOW CREATE TABLE `apr_request`;
SHOW CREATE TABLE `apr_action`;
SHOW CREATE TABLE `apr_delivery`;
SHOW CREATE TABLE `apr_reconciliation`;
SELECT table_name,constraint_name,enforced FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_type='CHECK' AND table_name IN ('apr_scene','apr_lab_policy','apr_policy_revision','apr_request','apr_action','apr_delivery','apr_reconciliation');
SELECT 'ck_apr_close_ack_kind' AS check_name,COUNT(*) AS invalid_rows FROM `apr_delivery` WHERE (state<>'ACKNOWLEDGED' OR (owner_receipt IS NOT NULL AND COALESCE(JSON_UNQUOTE(JSON_EXTRACT(owner_receipt,'$.status')),'')=CASE WHEN decision_kind='APPLY' THEN 'APPLIED' ELSE 'DISCARDED' END)) IS FALSE;
SELECT 'ck_apr_close_activation' AS check_name,COUNT(*) AS invalid_rows FROM `apr_lab_policy` WHERE (activation_state IN ('DISABLED','ENABLED','PAUSED') AND (activation_state<>'ENABLED' OR (readiness='READY' AND current_revision_id IS NOT NULL AND activation_evidence IS NOT NULL))) IS FALSE;
SELECT COUNT(*) AS expected_zero_before_enable FROM `apr_reconciliation`;
