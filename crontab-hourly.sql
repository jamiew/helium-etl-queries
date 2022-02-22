-- meant to be run frequently. could be more often than an hour, but hourly is fine
set statement_timeout to 0;
\i ./views/challenge_receipts_parsed.sql;
