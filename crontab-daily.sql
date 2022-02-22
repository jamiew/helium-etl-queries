-- meant to be run nightly; quite slow
set statement_timeout to 0;
REFRESH MATERIALIZED VIEW data_credits;
