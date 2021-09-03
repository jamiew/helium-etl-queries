drop view if exists validator_cg_members;
create view validator_cg_members as
    select actor as address,
    count(actor_role) as cg_count
    from transaction_actors
    where actor_role = 'consensus_member'
    group by actor;

