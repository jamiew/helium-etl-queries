DROP TABLE IF EXISTS denylist;
CREATE TABLE denylist (
  name VARCHAR(255), -- duplicate of what's in gateway_inventory, but it's in the CSV
  address VARCHAR(53) PRIMARY KEY
);

-- download the denylist CSV:
--
--    wget https://ipfs.io/ipfs/QmeaZFNRjAnTwqUJedWbSNMLPhKEiPoKTR59YPsKuS7qur/helium-denylist.csv
-- 
-- then load into our new table:
--
--    echo "copy denylist(name,address) from '$(pwd -P)/helium-denylist.csv' delimiter ',' csv header;" | psql etl2
--
-- lastly, remove the name column so folks don't get confused (right?)
--
--    echo "alter table denylist drop column name;" | psql etl2

--

