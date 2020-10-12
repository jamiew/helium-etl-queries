helium-etl-queries
==================

A collection of SQL queries used to enrich data produced by a Helium [blockchain-etl](https://github.com/helium/blockchain-etl)

This repo is specifically trying to create and manage views that better surface the embedded JSON fields in a
more managable form, e.g. turning `transactions[type='state_channel_close']` => `data_credits` table, with properly typed columns

A live instance with these views is avaialble on the beta DeWi ETL instance, which runs Metabase:

https://etl.dewi.org

If you're interested in using it, please contact @jamiedubs on Discord


TODO get fancy and use [dbt](https://github.com/fishtown-analytics/dbt)

Contributing
------------

* Pull requests welcome
* Fork and send a pull request
* Ask questions in #hips or #blockchain-dev on Discord

Contributors
------------

* @\~zav\~
* @jamiedubs

License
-------

MIT
