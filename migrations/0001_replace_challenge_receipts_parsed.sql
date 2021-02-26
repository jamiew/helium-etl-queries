-- for converting this materialized view to an incrementally-populated table instead
-- by @wishplorer

ALTER MATERIALIZED VIEW challenge_receipts_parsed RENAME TO mv_challenge_receipts_parsed;

CREATE TABLE challenge_receipts_parsed AS
  SELECT * FROM mv_challenge_receipts_parsed;

DROP MATERIALIZED VIEW mv_challenge_receipts_parsed;
