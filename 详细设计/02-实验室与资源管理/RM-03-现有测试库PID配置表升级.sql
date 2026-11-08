-- 仅供已存在统一型号表的测试库，经备份/停写/显式批准后单独执行。
-- 不加入新系统空库安装链；新库直接使用开发基线。
-- 执行前由操作人设置：SET @rm_pid_upgrade_database = DATABASE();
-- 必须先确认 DATABASE() 为预期测试库，不能将本语句盲目自动化。
-- 本脚本只新增型号级PID配置表，不迁移工艺模板PID，也不生成默认配置行。
DELIMITER $$
CREATE PROCEDURE rm_upgrade_pid_config_20261021()
BEGIN
  IF DATABASE() IS NULL OR @rm_pid_upgrade_database IS NULL
     OR BINARY @rm_pid_upgrade_database <> BINARY DATABASE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Confirm target test database before RM PID upgrade';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables
      WHERE table_schema=DATABASE() AND table_name='dev_reactor_model') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'dev_reactor_model is missing';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables
      WHERE table_schema=DATABASE() AND table_name='dev_reactor_model_pid') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'dev_reactor_model_pid already exists: inspect schema; do not rerun';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM sys_management_revision WHERE scope_key='SYSTEM') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SYSTEM management revision is missing';
  END IF;

  CREATE TABLE dev_reactor_model_pid (
    pid_id bigint NOT NULL,
    model_id bigint NOT NULL,
    loop_code varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    gain_value decimal(10,1) NOT NULL,
    reset_seconds int NOT NULL,
    rate_value decimal(10,1) NULL,
    del_flag char(1) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '0',
    create_by varchar(64) NOT NULL DEFAULT '',
    create_time datetime NULL,
    update_by varchar(64) NOT NULL DEFAULT '',
    update_time datetime NULL,
    m02_active tinyint GENERATED ALWAYS AS
      (CASE WHEN del_flag = '0' THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (pid_id),
    UNIQUE KEY uk_rm_pid_loop (model_id, loop_code, m02_active),
    KEY idx_rm_pid_model (model_id, del_flag),
    CONSTRAINT fk_rm_pid_model FOREIGN KEY (model_id)
      REFERENCES dev_reactor_model (model_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_rmp_id CHECK (pid_id > 0 AND model_id > 0),
    CONSTRAINT ck_rmp_loop CHECK
      (loop_code IN ('DO','PH','VESSEL_TEMP','JACKET_TEMP','VESSEL_PRESSURE')),
    CONSTRAINT ck_rmp_values CHECK
      (gain_value > 0 AND reset_seconds > 0 AND (rate_value IS NULL OR rate_value >= 0)),
    CONSTRAINT ck_rmp_deleted CHECK (del_flag IN ('0','2'))
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资源管理-反应器型号PID默认参数';

  UPDATE sys_management_revision SET revision=revision+1, update_time=CURRENT_TIMESTAMP
    WHERE scope_key='SYSTEM';
END$$
DELIMITER ;
CALL rm_upgrade_pid_config_20261021();
DROP PROCEDURE rm_upgrade_pid_config_20261021;

-- 核验应返回1行表定义、0行数据；具体业务范围由应用服务校验。
SELECT table_name FROM information_schema.tables
  WHERE table_schema=DATABASE() AND table_name='dev_reactor_model_pid';
SELECT COUNT(*) AS pid_row_count FROM dev_reactor_model_pid;
