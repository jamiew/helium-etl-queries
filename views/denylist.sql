DROP TABLE IF EXISTS denylist;
CREATE TABLE denylist (
  name VARCHAR(255),
  address VARCHAR(53) PRIMARY KEY
);

-- download the denylist CSV:
--
--    wget https://ipfs.io/ipfs/QmeaZFNRjAnTwqUJedWbSNMLPhKEiPoKTR59YPsKuS7qur/helium-denylist.csv
-- 
-- then load into our new table:
--
--    echo "copy denylist(address) from '$(pwd -P)/helium-denylist.csv' delimiter ',' csv header;" | psql etl2
--
-- lastly, remove the name column so folks don't get confused (right?)
--
--    alter table denylist drop column name;

--

