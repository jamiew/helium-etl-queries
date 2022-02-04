DROP MATERIALIZED VIEW data_credits;
CREATE MATERIALIZED VIEW data_credits AS
WITH second AS (
    WITH first AS (
        SELECT
			"public"."transactions"."type" AS "type",
        	"public"."transactions"."fields"->'state_channel'->'summaries' AS "sums",
        	to_timestamp("public"."transactions"."time") AS "time"
        FROM "public"."transactions"
        WHERE ("public"."transactions"."type" = CAST('state_channel_close_v1' AS "transaction_type"))
        LIMIT 1048576
    )
    SELECT
        "first"."sums" AS "summaries", date_trunc('day',"time") as "time"
    FROM "first"
)
SELECT
	second.time as "time",
  ((json_array_elements(to_json(second.summaries))->>'owner')) as "owner",
  ((json_array_elements(to_json(second.summaries))->>'client')) as "client",
  ((json_array_elements(to_json(second.summaries))->>'location')) as "location",
  ((json_array_elements(to_json(second.summaries))->>'num_dcs')::int) as "dcs",
  ((json_array_elements(to_json(second.summaries))->>'num_packets')::int) as "packets"
FROM second;

create index data_credits_client_idx on public.data_credits using btree (client);
