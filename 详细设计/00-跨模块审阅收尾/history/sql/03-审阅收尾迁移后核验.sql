-- COMMON 后置只读设计；预期3表31列。旧列逐主键与备份逐值核对，不只看计数。
SHOW CREATE TABLE `audit_archive_manifest`;
SHOW CREATE TABLE `audit_archive_record`;
SHOW CREATE TABLE `audit_archive_key`;
SELECT table_name,constraint_name,enforced FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND constraint_type='CHECK' AND table_name IN ('audit_archive_manifest','audit_archive_record','audit_archive_key');
SELECT COUNT(*) AS expected_zero_before_enable FROM `audit_archive_manifest`;
SELECT COUNT(*) AS expected_zero_before_enable FROM `audit_archive_record`;
SELECT COUNT(*) AS expected_zero_before_enable FROM `audit_archive_key`;
