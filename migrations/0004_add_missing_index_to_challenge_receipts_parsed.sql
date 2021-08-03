-- this table has indexes on name + address for transmitter, but only on name for witness
-- this adds the missing `witness_gateway` index
-- arguably should only be indexing on address, since names are not garaunteed to be unique

ALTER TABLE challenge_receipts_parsed RENAME COLUMN "witness_gateway" TO "witness_address";

DROP INDEX IF EXISTS challenge_receipts_parsed_witness_address_idx;
CREATE INDEX challenge_receipts_parsed_witness_address_idx ON public.challenge_receipts_parsed USING btree (witness_address);
