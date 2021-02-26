-- for converting this materialized view to an incrementally-populated table instead
-- by @wishplorer

ALTER MATERIALIZED VIEW challenge_receipts_parsed RENAME TO mv_challenge_receipts_parsed;

CREATE TABLE challenge_receipts_parsed AS
  SELECT * FROM mv_challenge_receipts_parsed;

-- blow away old indexes and make some fresh ones
DROP INDEX IF EXISTS challenge_receipts_parsed_transmitter_address_idx;
CREATE INDEX challenge_receipts_parsed_transmitter_address_idx ON public.challenge_receipts_parsed USING btree (transmitter_address);
DROP INDEX IF EXISTS challenge_receipts_parsed_transmitter_name_idx;
CREATE INDEX challenge_receipts_parsed_transmitter_name_idx ON public.challenge_receipts_parsed USING btree (transmitter_name);
DROP INDEX IF EXISTS challenge_receipts_parsed_witness_name_idx;
CREATE INDEX challenge_receipts_parsed_witness_name_idx ON public.challenge_receipts_parsed USING btree (witness_name);

DROP MATERIALIZED VIEW mv_challenge_receipts_parsed;
