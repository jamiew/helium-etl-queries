drop view if exists validator_cg_members;
create view validator_cg_members as
    select address as address,
    count(penalty_type) as cg_count
    from validator_penalty_parsed
    where penalty_type = 'tenure'
    group by address;

