-- 只读后置核验：初装计数均为0；结构对照25，不只比列数。
SHOW CREATE TABLE det_result;
SHOW CREATE TABLE det_result_correction;
SHOW CREATE TABLE det_result_revision;
SELECT COUNT(*) AS unexpected_active FROM det_result WHERE current_correction_id IS NOT NULL;
SELECT COUNT(*) AS unexpected_requests FROM det_result_correction;
SELECT COUNT(*) AS unexpected_events FROM det_result_revision WHERE source_kind='CORRECTION';
SELECT COUNT(*) AS broken_projection FROM det_result r LEFT JOIN det_result_correction c ON c.correction_id=r.current_correction_id LEFT JOIN det_result_revision v ON v.revision_id=c.result_revision_id WHERE r.current_correction_id IS NOT NULL AND (c.correction_id IS NULL OR c.result_id<>r.result_id OR c.state<>'APPROVED' OR v.revision_id IS NULL OR v.result_id<>r.result_id OR v.object_version<>r.object_version);
-- 另按备份逐主键、逐原列比较14表：零丢失/零旧值修改；新pointer全NULL，不伪造历史。
SELECT table_name,constraint_name,enforced FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name IN ('det_result_correction','det_result_revision') AND constraint_type='CHECK';
