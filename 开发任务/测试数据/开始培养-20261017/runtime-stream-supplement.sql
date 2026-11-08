-- Existing test DB only. Exact missing fields and constraint from current installation baseline.
ALTER TABLE run_culture_runtime
  ADD COLUMN runtime_stream_id VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M07生产侧稳定运行事实流；服务重启或执行器换主不改变',
  ADD COLUMN runtime_stream_sequence BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'M07已生产的培养级运行事实最大序号；0表示尚未生产',
  ADD COLUMN runtime_last_event_key CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL COMMENT 'M07最后已生产事实的sourceEventKey；用于下一事实previousEventKey',
  ADD CONSTRAINT ck_m07_runtime_stream CHECK ((runtime_stream_sequence=0 AND runtime_stream_id IS NULL AND runtime_last_event_key IS NULL) OR (runtime_stream_sequence>0 AND runtime_stream_id IS NOT NULL AND runtime_last_event_key IS NOT NULL));
