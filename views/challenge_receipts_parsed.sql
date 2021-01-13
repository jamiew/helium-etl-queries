-- enriched version of challenge_receipts by @wishplorer
drop materialized view challenge_receipts_parsed;
create materialized view challenge_receipts_parsed as 
with data1 as 
(
SELECT  a.block, a.hash, a.time, b.value as cpath
FROM
  public.challenge_receipts a, json_array_elements(a.path::json) b
  -- where a.block > 635109
  -- where a.block > 600000
  where a.block > 620000
),
data2 as (
select  a.block, a.hash, a.time,
        cpath::json->>'challengee' as challengee,
        cpath::json->>'receipt' as receipt,
        cpath::json->>'witnesses' as witnesses
FROM    data1 a
),
data_r1 as (
select  block, hash, time, challengee, 
        receipt::json->>'gateway' as challengee_gateway,
        receipt::json->>'origin' as origin
FROM    data2 
),
data_w1 as (
select  a.block, a.hash, a.challengee, 
        b.value::json->>'owner' as witness_owner,
        b.value::json->>'gateway' as witness_gateway,
        b.value::json->>'is_valid' as witness_is_valid,
        b.value::json->>'signal' as witness_signal,
        b.value::json->>'snr' as witness_snr
from    data2 a, json_array_elements(a.witnesses::json) b
),
hotspot1 as (
select  address, name
from    gateway_inventory
)
select  a.block, a.hash, a.time, h.name as transmitter_name, a.challengee_gateway as transmitter_address, a.origin,
        b.witness_owner, wt.name as witness_name, b.witness_gateway, COALESCE(b.witness_is_valid, 'No Witness') as witness_is_valid, 
        b.witness_signal, b.witness_snr
from    data_r1 a
join    hotspot1 h
    on  a.challengee_gateway = h.address
left join    data_w1 b
    on  a.block = b.block
    and a.hash = b.hash
    and a.challengee = b.challengee
left join   gateway_inventory wt 
    on  b.witness_gateway = wt.address;

-- FIXME should just be indexing on either name or address, not both
create index challenge_receipts_parsed_transmitter_address_idx ON public.challenge_receipts_parsed USING btree (transmitter_address);
create index challenge_receipts_parsed_transmitter_name_idx ON public.challenge_receipts_parsed USING btree (transmitter_name);
create index challenge_receipts_parsed_witness_name_idx ON public.challenge_receipts_parsed USING btree (witness_name);
