CREATE VIEW challenge_receipts AS
SELECT
    public.transactions.block AS block,
    public.transactions.hash AS hash,
    public.transactions.type AS type,

    -- fields specific to this txn
    -- public.transactions.fields AS fields,
    public.transactions.fields->>'challenger' as challenger,
    public.transactions.fields->>'challenger_location' as challenger_location,
    public.transactions.fields->>'challenger_owner' as challenger_owner,
    public.transactions.fields->>'fee' as fee,
    -- public.transactions.fields->>'hash' as hash,
    public.transactions.fields->>'onion_key_hash' as onion_key_hash,
    public.transactions.fields->>'path' as path,
    public.transactions.fields->>'secret' as secret,
    -- public.transactions.fields->>'type' as type,

    to_timestamp(public.transactions.time) AS time
FROM
  public.transactions
WHERE
  public.transactions.type = CAST('poc_receipts_v1' AS transaction_type)
;