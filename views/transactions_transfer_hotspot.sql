DROP VIEW transactions_transfer_hotspot;
CREATE VIEW transactions_transfer_hotspot AS
SELECT
    public.transactions.block AS block,
    public.transactions.hash AS hash,
    public.transactions.type AS type,

    -- fields specific to this txn
    public.transactions.fields->>'buyer' as buyer,
    public.transactions.fields->>'seller' as seller,
    public.transactions.fields->>'gateway' as gateway,
    CAST(public.transactions.fields->>'buyer_nonce' AS INT) as buyer_nonce,
    CAST(public.transactions.fields->>'amount_to_seller' AS BIGINT) as amount_to_seller,

    to_timestamp(public.transactions.time) AS time
FROM
  public.transactions
WHERE
  public.transactions.type = CAST('transfer_hotspot_v1' AS transaction_type)
;