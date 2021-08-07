#!/bin/bash
# 
# assumes you have postgres credentials in the ENV already, e.g. PGUSER, PGPASSWORD et al
#
# to update `etl-schema.sql`, run this on an up-to-date ETL instance:
#
#   pg_dump -s etl > etl-schema.sql
# 

set -e

database="etl_queries_test"
dropdb "$database"
createdb "$database"

psql "$database" < etl-schema.sql
echo

for file in views/*.sql; do 
  echo "----- $file -----"
  psql "$database" < "$file"
  sleep 1
  echo
done

echo "All done"
