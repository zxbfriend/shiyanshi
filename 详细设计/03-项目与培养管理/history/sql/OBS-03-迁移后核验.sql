-- DD-20260917-OBS，只读核验；未执行。必须先完成本模块OBS-02。
SELECT table_name,COUNT(*) AS column_count FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN ('res_observation_binding_revision','res_observation_binding_interval') GROUP BY table_name ORDER BY table_name;
SELECT table_name,index_name,non_unique,seq_in_index,column_name FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name IN ('res_observation_binding_revision','res_observation_binding_interval') ORDER BY table_name,index_name,seq_in_index;
SELECT table_name,constraint_name,constraint_type FROM information_schema.table_constraints WHERE table_schema=DATABASE() AND table_name IN ('res_observation_binding_revision','res_observation_binding_interval') ORDER BY table_name,constraint_name;
-- 同一修订内不得重叠，历史不同修订重叠是正常的完整快照。
SELECT a.interval_id,b.interval_id AS overlaps_with FROM res_observation_binding_interval a JOIN res_observation_binding_interval b ON a.revision_id=b.revision_id AND a.interval_id<b.interval_id AND (a.valid_to IS NULL OR b.valid_from<a.valid_to) AND (b.valid_to IS NULL OR a.valid_from<b.valid_to);
SELECT i.interval_id FROM res_observation_binding_interval i LEFT JOIN res_observation_binding_revision r ON r.revision_id=i.revision_id WHERE r.revision_id IS NULL;
SELECT i.interval_id FROM res_observation_binding_interval i LEFT JOIN res_culture_occupancy o ON o.occupancy_id=i.occupancy_id WHERE i.state='MATCHED' AND (o.occupancy_id IS NULL OR o.culture_id<>i.culture_id OR o.lab_id<>i.lab_id);

