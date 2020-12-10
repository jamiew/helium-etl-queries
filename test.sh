#!/bin/bash
# 
# assumes you have postgres credentials in the ENV already
# PGUSER, PGPASSWORD et al
# 

database="etl_queries_test"
dropdb "$database"
createdb "$database"

psql "$database" < etl-schema.sql
echo

for file in views/*.sql; do 
  echo "----- $file -----"
  psql "$database" < "$file"
  echo
done

echo "All done"
