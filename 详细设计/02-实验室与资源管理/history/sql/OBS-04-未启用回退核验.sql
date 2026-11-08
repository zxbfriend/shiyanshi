-- DD-20260917-OBS：只读回退资格核验，未执行；不包含可自动运行的DROP。
-- DDL不可事务回滚。必须停新写、确认无发布/消费者、逐表COUNT=0、验证备份和回退版本后单独审批。
SELECT 'lab_observation_mapping' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation_mapping`;
SELECT 'lab_observation_receipt' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation_receipt`;
SELECT 'lab_observation_conflict' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation_conflict`;
SELECT 'lab_observation' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation`;
SELECT 'lab_observation_association' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation_association`;
SELECT 'lab_observation_current' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation_current`;
SELECT 'lab_observation_outbox' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation_outbox`;
SELECT 'lab_observation_monitor' AS target_table,COUNT(*) AS must_be_zero_for_empty_install_rollback FROM `lab_observation_monitor`;
-- 若任何表已有业务/证据行：禁止删表；停用新增入口、保留数据与兼容读取，采用前向修复。
-- 仅空表且从未启用时，人工核准下列反向删除清单；本文件不执行：
-- DROP TABLE `lab_observation_monitor`;
-- DROP TABLE `lab_observation_outbox`;
-- DROP TABLE `lab_observation_current`;
-- DROP TABLE `lab_observation_association`;
-- DROP TABLE `lab_observation`;
-- DROP TABLE `lab_observation_conflict`;
-- DROP TABLE `lab_observation_receipt`;
-- DROP TABLE `lab_observation_mapping`;
-- 不修改原有样本、占用、业务源表；M07存在v2样本或未决执行时禁止回退不兼容程序。

