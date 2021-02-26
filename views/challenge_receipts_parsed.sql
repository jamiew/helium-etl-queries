-- v3 of challenge_receipts by @wishplorer
-- see also new migrations/00001_* file, which sets up this table
-- and imports data from the old materialized view

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
        b.value::json->>'gateway' as witness_gateway,
        b.value::json->>'is_valid' as witness_is_valid,
        b.value::json->>'invalid_reason' as witness_invalid_reason,
        b.value::json->>'signal' as witness_signal,
        b.value::json->>'snr' as witness_snr
from    data2 a, json_array_elements(a.witnesses::json) b
),
hotspot1 as (
select  address, name
from    gateway_inventory
)
Insert into challenge_receipts_parsed
select  a.block, a.hash, a.time, h.name as transmitter_name, a.challengee_gateway as transmitter_address, a.origin,
        b.witness_owner, wt.name as witness_name, b.witness_gateway, COALESCE(b.witness_is_valid, 'No Witness') as witness_is_valid,
        b.witness_invalid_reason, b.witness_signal, b.witness_snr
from    data_r1 a
join    hotspot1 h
    on  a.challengee_gateway = h.address
left join    data_w1 b
    on  a.block = b.block
    and a.hash = b.hash
    and a.challengee = b.challengee
left join   gateway_inventory wt
    on  b.witness_gateway = wt.address;
