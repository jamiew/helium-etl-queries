#!/bin/bash
# 
# this assumes you have postgres credentials in the ENV already, e.g. PGUSER, PGPASSWORD et alo
# 
# to update `etl-schema.sql`, run this on an up-to-date ETL instance:
#
#   pg_dump -s etl > etl-schema.sql
# 
# to dump users & roles, run:
#
#   pg_dumpall --globals-only --file=etl-roles.sql
# 

set -e

database="etl_queries_test"
dropdb "$database"
createdb "$database"

[ -f etl-roles.sql ] && psql --quiet "$database" < etl-roles.sql || echo "warning: roles are missing, there will be errors"
psql --quiet "$database" < etl-schema.sql
echo

for file in views/*.sql; do 
  echo "----- $file -----"
  psql "$database" < "$file"
  sleep 1
  echo
done

echo "All done"
echo "select count(*) from gateway_inventory" | psql "$database" 
