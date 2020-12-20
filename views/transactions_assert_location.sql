DROP VIEW transactions_assert_location;
CREATE VIEW transactions_assert_location AS
SELECT
    public.transactions.block AS block,
    public.transactions.hash AS hash,
    public.transactions.type AS type,

    -- fields specific to this txn
    public.transactions.fields->>'fee' as fee,
    CAST(public.transactions.fields->>'nonce' AS INT) as nonce,
    public.transactions.fields->>'owner' as owner,
    public.transactions.fields->>'payer' as payer,
    public.transactions.fields->>'gateway' as gateway,
    public.transactions.fields->>'location' as location,
    public.transactions.fields->>'staking_fee' as staking_fee,

    to_timestamp(public.transactions.time) AS time
FROM
  public.transactions
WHERE
  public.transactions.type = CAST('assert_location_v1' AS transaction_type)
;