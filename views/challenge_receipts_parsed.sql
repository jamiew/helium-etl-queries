-- v4 of challenge_receipts by @wishplorer & @jamiedubs
-- this is a full table now, and this query is meant to be run hourly-ish to insert new rows
-- view was too slow, materialized view was too slow

-- disable any query timeouts
SET statement_timeout TO 0;

-- first, create table + indexes if they don't exist yet
CREATE TABLE IF NOT EXISTS challenge_receipts_parsed (
    block bigint,
    hash text,
    "time" timestamp with time zone,
    transmitter_name text,
    transmitter_address text,
    origin text,
    witness_owner text,
    witness_name text,
    witness_address text,
    witness_is_valid text,
    witness_invalid_reason text,
    witness_signal text,
    witness_snr text,
    witness_channel text,
    witness_datarate text,
    witness_frequency text,
    witness_location text,
    witness_timestamp text
);

CREATE INDEX IF NOT EXISTS challenge_receipts_parsed_block_idx ON challenge_receipts_parsed USING btree (block);
CREATE INDEX IF NOT EXISTS challenge_receipts_parsed_hash_idx ON challenge_receipts_parsed USING btree (hash);
CREATE INDEX IF NOT EXISTS challenge_receipts_parsed_transmitter_time_idx ON challenge_receipts_parsed USING btree (time);
CREATE INDEX IF NOT EXISTS challenge_receipts_parsed_transmitter_address_idx ON challenge_receipts_parsed USING btree (transmitter_address);
CREATE INDEX IF NOT EXISTS challenge_receipts_parsed_transmitter_name_idx ON challenge_receipts_parsed USING btree (transmitter_name);
CREATE INDEX IF NOT EXISTS challenge_receipts_parsed_witness_address_idx ON challenge_receipts_parsed USING btree (witness_address);
CREATE INDEX IF NOT EXISTS challenge_receipts_parsed_witness_name_idx ON challenge_receipts_parsed USING btree (witness_name);

-- then build our query and insert data into that table
with data1 as
(
    SELECT      a.block, a.hash, a.time, b.value as cpath
    FROM        public.challenge_receipts a, json_array_elements(a.path::json) b
    WHERE     a.block > (select max(block) from challenge_receipts_parsed)
),
data2 as (
    select  a.block, a.hash, a.time,
        cpath::json->>'challengee' as challengee,
        cpath::json->>'receipt' as receipt,
        cpath::json->>'witnesses' as witnesses
    FROM    data1 a
),
data_r1 as (
    SELECT  block, hash, time, challengee,
            receipt::json->>'gateway' as challengee_gateway,
            receipt::json->>'origin' as origin
    FROM    data2
),
data_w1 as (
    SELECT  a.block, a.hash, a.challengee,
            b.value::json->>'owner' as witness_owner,
            b.value::json->>'gateway' as witness_address,
            b.value::json->>'is_valid' as witness_is_valid,
            b.value::json->>'invalid_reason' as witness_invalid_reason,
            b.value::json->>'signal' as witness_signal,
            b.value::json->>'snr' as witness_snr,
            b.value::json->>'channel' as witness_channel,
            b.value::json->>'datarate' as witness_sf,
            b.value::json->>'frequency' as witness_frequency,
            b.value::json->>'location' as witness_location,
            b.value::json->>'timestamp' as witness_timestamp
    from    data2 a, json_array_elements(a.witnesses::json) b
),
hotspot1 as (
    select  address, name
    from    gateway_inventory
)

insert into challenge_receipts_parsed
select  a.block, a.hash, a.time, h.name as transmitter_name, a.challengee_gateway as transmitter_address, a.origin,
        b.witness_owner, wt.name as witness_name, b.witness_address, COALESCE(b.witness_is_valid, 'No Witness') as witness_is_valid,
        b.witness_invalid_reason, b.witness_signal, b.witness_snr, b.witness_channel, b.witness_sf, b.witness_frequency,
        b.witness_location, b.witness_timestamp
from    data_r1 a
join    hotspot1 h
    on  a.challengee_gateway = h.address
left join    data_w1 b
    on  a.block = b.block
    and a.hash = b.hash
    and a.challengee = b.challengee
left join   gateway_inventory wt
    on  b.witness_address = wt.address;
