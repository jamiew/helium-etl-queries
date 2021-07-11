create or replace view validator_penalty_parsed as 
	with data1 as (
		select 	address, name,
			b.value as cpen
		from 	public.validator_inventory a, json_array_elements(a.penalties::json) as b
	), data2 as (
		select  address, name,
				cpen::json->>'type' as penalty_type,
				(cpen::json->>'amount')::double precision as penalty_amount,
				(cpen::json->>'height')::bigint as penalty_height
		from	data1
	)
	select 	* 
	from 	data2
