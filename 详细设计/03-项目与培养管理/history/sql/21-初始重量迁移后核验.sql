-- 只读。DDL后检查列、CHECK；下方异常查询预期0行。
SHOW CREATE TABLE res_culture;
SELECT culture_id FROM res_culture WHERE
 (initial_weight_g IS NULL AND (initial_weight_revision<>0 OR initial_weight_effective_at IS NOT NULL OR initial_weight_candidate_id IS NOT NULL))
 OR (initial_weight_g IS NOT NULL AND (initial_weight_g<=0 OR initial_weight_g<>FLOOR(initial_weight_g)
 OR initial_weight_revision<1 OR initial_weight_effective_at IS NULL OR initial_weight_candidate_id IS NULL));
SELECT c.culture_id FROM res_culture c LEFT JOIN res_culture_change_candidate k
 ON k.candidate_id=c.initial_weight_candidate_id AND k.culture_id=c.culture_id
 WHERE c.initial_weight_candidate_id IS NOT NULL AND (k.candidate_id IS NULL OR k.state<>'APPLIED' OR k.scene_code<>'M06_SC030');
