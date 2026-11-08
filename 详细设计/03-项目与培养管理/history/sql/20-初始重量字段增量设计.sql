-- 设计稿，未执行。先执行19只读核验并备份res_culture及候选；仅在既有18基线且无同名列时使用。
-- MySQL DDL隐式提交，不承诺事务ROLLBACK；历史初始重量不自动回填。
ALTER TABLE res_culture
 ADD COLUMN initial_weight_g DECIMAL(20,6) NULL COMMENT '合并初始培养重量g，未知NULL，M03唯一写',
 ADD COLUMN initial_weight_revision BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '初始重量版本，未知0',
 ADD COLUMN initial_weight_effective_at DATETIME(3) NULL COMMENT '实际生效UTC',
 ADD COLUMN initial_weight_candidate_id BIGINT NULL COMMENT 'M03候选来源，逻辑关联',
 ADD CONSTRAINT ck_m03_initial_weight CHECK (
  (initial_weight_g IS NULL AND initial_weight_revision=0 AND initial_weight_effective_at IS NULL AND initial_weight_candidate_id IS NULL)
  OR
  (initial_weight_g IS NOT NULL AND initial_weight_g>0 AND initial_weight_g=FLOOR(initial_weight_g)
   AND initial_weight_revision>=1 AND initial_weight_effective_at IS NOT NULL AND initial_weight_candidate_id IS NOT NULL)
 );
