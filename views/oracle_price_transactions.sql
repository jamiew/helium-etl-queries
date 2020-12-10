CREATE VIEW oracle_price_transactions AS
SELECT
    public.transactions.block AS block,
    public.transactions.hash AS hash,
    public.transactions.type AS type,

    -- fields specific to this txn
    public.transactions.fields->>'fee' as fee,
    public.transactions.fields->>'price' as price, -- do we want to cast this?
    public.transactions.fields->>'public_key' as public_key,
    public.transactions.fields->>'block_height' as block_height, -- is this

    to_timestamp(public.transactions.time) AS time
FROM
  public.transactions
WHERE
  public.transactions.type = CAST('price_oracle_v1' AS transaction_type)
;