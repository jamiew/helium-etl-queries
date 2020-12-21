-- TODO rename this to transactions_price_oracle
DROP VIEW oracle_price_transactions;
CREATE VIEW oracle_price_transactions AS
SELECT
    public.transactions.block AS block,
    public.transactions.hash AS hash,
    public.transactions.type AS type,

    -- fields specific to this txn
    CAST(public.transactions.fields->>'fee' AS BIGINT) as fee,
    CAST(public.transactions.fields->>'price' AS BIGINT) as price,
    public.transactions.fields->>'public_key' as public_key,
    public.transactions.fields->>'block_height' as block_height, -- is this different from "block" above?

    to_timestamp(public.transactions.time) AS time
FROM
  public.transactions
WHERE
  public.transactions.type = CAST('price_oracle_v1' AS transaction_type)
;
