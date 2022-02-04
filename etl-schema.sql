--
-- PostgreSQL database dump
--

-- Dumped from database version 10.17 (Ubuntu 10.17-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.17 (Ubuntu 10.17-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: etl
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO etl;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: etl
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: burn_type; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.burn_type AS ENUM (
    'fee',
    'state_channel',
    'assert_location',
    'add_gateway',
    'oui',
    'routing'
);


ALTER TYPE public.burn_type OWNER TO etl;

--
-- Name: gateway_mode; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.gateway_mode AS ENUM (
    'full',
    'light',
    'dataonly'
);


ALTER TYPE public.gateway_mode OWNER TO etl;

--
-- Name: gateway_status_online; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.gateway_status_online AS ENUM (
    'online',
    'offline'
);


ALTER TYPE public.gateway_status_online OWNER TO etl;

--
-- Name: packet_entry; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.packet_entry AS (
	client text,
	type text,
	num_packets bigint,
	num_dcs bigint
);


ALTER TYPE public.packet_entry OWNER TO etl;

--
-- Name: pending_transaction_nonce_type; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.pending_transaction_nonce_type AS ENUM (
    'balance',
    'security',
    'none',
    'gateway'
);


ALTER TYPE public.pending_transaction_nonce_type OWNER TO etl;

--
-- Name: pending_transaction_status; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.pending_transaction_status AS ENUM (
    'received',
    'pending',
    'failed',
    'cleared'
);


ALTER TYPE public.pending_transaction_status OWNER TO etl;

--
-- Name: reward_entry; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.reward_entry AS (
	account text,
	gateway text,
	type text,
	amount bigint
);


ALTER TYPE public.reward_entry OWNER TO etl;

--
-- Name: transaction_actor_role; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.transaction_actor_role AS ENUM (
    'payee',
    'payer',
    'owner',
    'gateway',
    'reward_gateway',
    'challenger',
    'challengee',
    'witness',
    'consensus_member',
    'escrow',
    'sc_opener',
    'sc_closer',
    'packet_receiver',
    'oracle',
    'router',
    'validator',
    'consensus_failure_member',
    'consensus_failure_failed_member'
);


ALTER TYPE public.transaction_actor_role OWNER TO etl;

--
-- Name: transaction_type; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.transaction_type AS ENUM (
    'coinbase_v1',
    'security_coinbase_v1',
    'oui_v1',
    'gen_gateway_v1',
    'routing_v1',
    'payment_v1',
    'security_exchange_v1',
    'consensus_group_v1',
    'add_gateway_v1',
    'assert_location_v1',
    'create_htlc_v1',
    'redeem_htlc_v1',
    'poc_request_v1',
    'poc_receipts_v1',
    'vars_v1',
    'rewards_v1',
    'token_burn_v1',
    'dc_coinbase_v1',
    'token_burn_exchange_rate_v1',
    'payment_v2',
    'state_channel_open_v1',
    'state_channel_close_v1',
    'price_oracle_v1',
    'transfer_hotspot_v1',
    'rewards_v2',
    'assert_location_v2',
    'gen_validator_v1',
    'stake_validator_v1',
    'unstake_validator_v1',
    'validator_heartbeat_v1',
    'transfer_validator_stake_v1',
    'gen_price_oracle_v1',
    'consensus_group_failure_v1'
);


ALTER TYPE public.transaction_type OWNER TO etl;

--
-- Name: validator_status_online; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.validator_status_online AS ENUM (
    'online',
    'offline'
);


ALTER TYPE public.validator_status_online OWNER TO etl;

--
-- Name: validator_status_type; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.validator_status_type AS ENUM (
    'staked',
    'cooldown',
    'unstaked'
);


ALTER TYPE public.validator_status_type OWNER TO etl;

--
-- Name: var_type; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.var_type AS ENUM (
    'integer',
    'float',
    'atom',
    'binary'
);


ALTER TYPE public.var_type OWNER TO etl;

--
-- Name: account_inventory_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.account_inventory_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$  BEGIN    insert into account_inventory           (address,           balance, nonce,           dc_balance, dc_nonce,           security_balance, security_nonce,           staked_balance,           first_block, last_block)    VALUES          (NEW.address,          NEW.balance, NEW.nonce,          NEW.dc_balance, NEW.dc_nonce,          NEW.security_balance, NEW.security_nonce,          NEW.staked_balance,          NEW.block, NEW.block          )    ON CONFLICT (address) DO UPDATE SET         balance = EXCLUDED.balance,         nonce = EXCLUDED.nonce,         dc_balance = EXCLUDED.dc_balance,         dc_nonce = EXCLUDED.dc_nonce,         security_balance = EXCLUDED.security_balance,         security_nonce = EXCLUDED.security_nonce,         staked_balance = EXCLUDED.staked_balance,         last_block = EXCLUDED.last_block;   RETURN NEW;  END;  $$;


ALTER FUNCTION public.account_inventory_update() OWNER TO etl;

--
-- Name: gateway_inventory_on_insert(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.gateway_inventory_on_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN     UPDATE gateway_inventory SET payer = (         select fields->>'payer'          from transaction_actors a inner join transactions t          on a.transaction_hash = t.hash             and a.actor = NEW.address             and a.actor_role = 'gateway'             and a.block = NEW.first_block         limit 1     )     where address = NEW.address;     RETURN NEW; END; $$;


ALTER FUNCTION public.gateway_inventory_on_insert() OWNER TO etl;

--
-- Name: gateway_inventory_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.gateway_inventory_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN   insert into gateway_inventory as g          (address, name, owner, location,           last_poc_challenge, last_poc_onion_key_hash, witnesses, nonce,           first_block, last_block, first_timestamp, reward_scale,           elevation, gain, location_hex, mode)   VALUES         (NEW.address, NEW.name, NEW.owner, NEW.location,         NEW.last_poc_challenge, NEW.last_poc_onion_key_hash, NEW.witnesses, NEW.nonce,         NEW.block, NEW.block, to_timestamp(NEW.time), NEW.reward_scale,         NEW.elevation, NEW.gain,         NEW.location_hex, NEW.mode         )   ON CONFLICT (address) DO UPDATE SET        owner = EXCLUDED.owner,        location = EXCLUDED.location,        last_poc_challenge = EXCLUDED.last_poc_challenge,        last_poc_onion_key_hash = EXCLUDED.last_poc_onion_key_hash,        witnesses = EXCLUDED.witnesses,        nonce = EXCLUDED.nonce,        last_block = EXCLUDED.last_block,        reward_scale = COALESCE(EXCLUDED.reward_scale, g.reward_scale),        elevation = EXCLUDED.elevation,        gain = EXCLUDED.gain,        location_hex = EXCLUDED.location_hex;   RETURN NEW; END; $$;


ALTER FUNCTION public.gateway_inventory_update() OWNER TO etl;

--
-- Name: get_avg_version_penalties(integer, integer, text); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.get_avg_version_penalties(integer, integer, text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
 total integer;
begin
    select 1 into total;
    return total;
end;
$$;


ALTER FUNCTION public.get_avg_version_penalties(integer, integer, text) OWNER TO etl;

--
-- Name: insert_packets(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.insert_packets() RETURNS void
    LANGUAGE plpgsql
    AS $$ declare     txn RECORD; begin     for txn in         select *         from transactions where type = 'state_channel_close_v1'         order by block asc     loop         insert into packets (block, transaction_hash, time, gateway, num_packets, num_dcs)         select              txn.block, txn.hash, txn.time, client as gateway,              sum(num_packets)::bigint as num_packets,              sum(num_dcs)::bigint as num_dcs         from jsonb_populate_recordset(null::packet_entry, txn.fields#>'{state_channel, summaries}')         group by client;     end loop; end; $$;


ALTER FUNCTION public.insert_packets() OWNER TO etl;

--
-- Name: insert_rewards(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.insert_rewards() RETURNS void
    LANGUAGE plpgsql
    AS $$ declare     txn RECORD; begin     for txn in         select *         from transactions where type = 'rewards_v1'         order by block asc     loop         insert into rewards (block, transaction_hash, time, account, gateway, amount)         select txn.block, txn.hash, txn.time, account, coalesce(gateway, '1Wh4bh') as gateway, sum(amount)::bigint as amount         from jsonb_populate_recordset(null::reward_entry, txn.fields->'rewards')         group by (account, gateway);     end loop; end; $$;


ALTER FUNCTION public.insert_rewards() OWNER TO etl;

--
-- Name: last_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$         SELECT $2; $_$;


ALTER FUNCTION public.last_agg(anyelement, anyelement) OWNER TO etl;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.locations (
    location text NOT NULL,
    long_street text,
    short_street text,
    long_city text,
    short_city text,
    long_state text,
    short_state text,
    long_country text,
    short_country text,
    search_city text,
    city_id text,
    geometry public.geometry(Point,4326)
);


ALTER TABLE public.locations OWNER TO etl;

--
-- Name: location_city_id(public.locations); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_city_id(l public.locations) RETURNS text
    LANGUAGE plpgsql
    AS $$ begin     return lower(coalesce(l.long_city, '') || coalesce(l.long_state, '') || coalesce(l.long_country, '')); end; $$;


ALTER FUNCTION public.location_city_id(l public.locations) OWNER TO etl;

--
-- Name: location_city_id_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_city_id_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ begin     NEW.city_id := location_city_id(NEW);     return NEW; end; $$;


ALTER FUNCTION public.location_city_id_update() OWNER TO etl;

--
-- Name: location_city_words(public.locations); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_city_words(l public.locations) RETURNS text
    LANGUAGE plpgsql
    AS $$ begin     return (select string_agg(word, ' ' order by rn)         from (select word, min(rn) as rn             from regexp_split_to_table(                         lower(                             coalesce(l.long_city, '') || ' ' || coalesce(l.short_city, '') || ' ' ||                              coalesce(l.long_state, '') || ' ' || coalesce(l.short_state, '') || ' ' ||                             coalesce(l.long_country, '') || ' ' || coalesce(l.short_country, '') || ' '                                                     ) , '\s'                      ) with ordinality x(word, rn) where length(word) >= 3             group by word) x); end; $$;


ALTER FUNCTION public.location_city_words(l public.locations) OWNER TO etl;

--
-- Name: location_search_city_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_search_city_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ begin     NEW.search_city := location_city_words(NEW);     return NEW; end; $$;


ALTER FUNCTION public.location_search_city_update() OWNER TO etl;

--
-- Name: oui_inventory_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.oui_inventory_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$  BEGIN    insert into oui_inventory         (oui, owner,         nonce, addresses, subnets,         first_block, last_block)    VALUES         (NEW.oui, NEW.owner,         NEW.nonce, NEW.addresses, NEW.subnets,         NEW.block, NEW.block)    ON CONFLICT (oui) DO UPDATE SET         owner = EXCLUDED.owner,         nonce = EXCLUDED.nonce,         addresses = EXCLUDED.addresses,         subnets = EXCLUDED.subnets,         last_block = EXCLUDED.last_block;   RETURN NEW;  END;  $$;


ALTER FUNCTION public.oui_inventory_update() OWNER TO etl;

--
-- Name: state_channel_counts(public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.state_channel_counts(type public.transaction_type, fields jsonb, OUT num_packets numeric, OUT num_dcs numeric) RETURNS record
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'state_channel_close_v1' then             select into num_packets, num_dcs sum(x.num_packets), sum(x.num_dcs)             from jsonb_to_recordset(fields#>'{state_channel, summaries}') as x(owner TEXT, client TEXT, num_dcs BIGINT, location TEXT, num_packets BIGINT);         else             num_packets := 0;             num_dcs := 0;     end case; end;  $$;


ALTER FUNCTION public.state_channel_counts(type public.transaction_type, fields jsonb, OUT num_packets numeric, OUT num_dcs numeric) OWNER TO etl;

--
-- Name: trigger_set_updated_at(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.trigger_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN   NEW.updated_at = NOW();   RETURN NEW; END; $$;


ALTER FUNCTION public.trigger_set_updated_at() OWNER TO etl;

--
-- Name: txn_filter_account_activity(text, public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.txn_filter_account_activity(acc text, type public.transaction_type, fields jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'rewards_v1' then             return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where account = acc));         when type = 'payment_v2' then             if fields#>'{payer}' = acc then                 return fields;             else                 return jsonb_set(fields, '{payees}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{payees}') as x(payee text, amount bigint) where payee = acc));             end if;         else             return fields;     end case; end; $$;


ALTER FUNCTION public.txn_filter_account_activity(acc text, type public.transaction_type, fields jsonb) OWNER TO etl;

--
-- Name: txn_filter_actor_activity(text, public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.txn_filter_actor_activity(actor text, type public.transaction_type, fields jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'rewards_v1' then             return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where account = actor or gateway = actor));         when type = 'rewards_v2' then             return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where account = actor or gateway = actor));         when type = 'state_channel_close_v1' then             return jsonb_set(fields, '{state_channel,summaries}', coalesce((select jsonb_agg(x) from jsonb_to_recordset(fields#>'{state_channel,summaries}') as x(owner text, num_packets bigint, num_dcs bigint, location text, client text) where owner = actor or client = actor), '[]'));         when type = 'payment_v2' then             if fields->>'payer' = actor then                 return fields;             else                 return jsonb_set(fields, '{payments}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{payments}') as x(payee text, amount bigint) where payee = actor));             end if;         when type = 'consensus_group_v1' then            return fields - 'proof';         else             return fields;     end case; end; $$;


ALTER FUNCTION public.txn_filter_actor_activity(actor text, type public.transaction_type, fields jsonb) OWNER TO etl;

--
-- Name: txn_filter_gateway_activity(text, public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.txn_filter_gateway_activity(gw text, type public.transaction_type, fields jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'rewards_v1' then             return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where gateway = gw));         when type = 'consensus_group_v1' then            return fields - 'proof';         else             return fields;     end case; end; $$;


ALTER FUNCTION public.txn_filter_gateway_activity(gw text, type public.transaction_type, fields jsonb) OWNER TO etl;

--
-- Name: validator_inventory_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.validator_inventory_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$  BEGIN    insert into validator_inventory           (address, name, owner,           stake, status, nonce,           last_heartbeat, version_heartbeat,           penalty, penalties,           first_block, last_block)    VALUES          (NEW.address, NEW.name, NEW.owner,          NEW.stake, NEW.status, NEW.nonce,          NEW.last_heartbeat, NEW.version_heartbeat,          NEW.penalty, NEW.penalties,          NEW.block, NEW.block          )    ON CONFLICT (address) DO UPDATE SET         stake = EXCLUDED.stake,         status = EXCLUDED.status,         owner = EXCLUDED.owner,         nonce = EXCLUDED.nonce,         last_heartbeat = EXCLUDED.last_heartbeat,         version_heartbeat = EXCLUDED.version_heartbeat,         penalty = EXCLUDED.penalty,         penalties = EXCLUDED.penalties,         last_block = EXCLUDED.last_block;   RETURN NEW;  END;  $$;


ALTER FUNCTION public.validator_inventory_update() OWNER TO etl;

--
-- Name: jsonb_merge_agg(jsonb); Type: AGGREGATE; Schema: public; Owner: etl
--

CREATE AGGREGATE public.jsonb_merge_agg(jsonb) (
    SFUNC = jsonb_concat,
    STYPE = jsonb,
    INITCOND = '{}'
);


ALTER AGGREGATE public.jsonb_merge_agg(jsonb) OWNER TO etl;

--
-- Name: last(anyelement); Type: AGGREGATE; Schema: public; Owner: etl
--

CREATE AGGREGATE public.last(anyelement) (
    SFUNC = public.last_agg,
    STYPE = anyelement
);


ALTER AGGREGATE public.last(anyelement) OWNER TO etl;

--
-- Name: __migrations; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.__migrations (
    id character varying(255) NOT NULL,
    datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.__migrations OWNER TO etl;

--
-- Name: account_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.account_inventory (
    address text NOT NULL,
    balance bigint NOT NULL,
    nonce bigint NOT NULL,
    dc_balance bigint NOT NULL,
    dc_nonce bigint NOT NULL,
    security_balance bigint NOT NULL,
    security_nonce bigint NOT NULL,
    first_block bigint,
    last_block bigint,
    staked_balance bigint
);


ALTER TABLE public.account_inventory OWNER TO etl;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.accounts (
    block bigint NOT NULL,
    address text NOT NULL,
    dc_balance bigint DEFAULT 0 NOT NULL,
    dc_nonce bigint DEFAULT 0 NOT NULL,
    security_balance bigint DEFAULT 0 NOT NULL,
    security_nonce bigint DEFAULT 0 NOT NULL,
    balance bigint DEFAULT 0 NOT NULL,
    nonce bigint DEFAULT 0 NOT NULL,
    staked_balance bigint
);


ALTER TABLE public.accounts OWNER TO etl;

--
-- Name: block_signatures; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.block_signatures (
    block bigint NOT NULL,
    signer text NOT NULL,
    signature text NOT NULL
);


ALTER TABLE public.block_signatures OWNER TO etl;

--
-- Name: blocks; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.blocks (
    height bigint NOT NULL,
    "time" bigint NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    prev_hash text,
    block_hash text NOT NULL,
    transaction_count integer NOT NULL,
    hbbft_round bigint NOT NULL,
    election_epoch bigint NOT NULL,
    epoch_start bigint NOT NULL,
    rescue_signature text NOT NULL,
    snapshot_hash text,
    created_at timestamp with time zone
);


ALTER TABLE public.blocks OWNER TO etl;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.transactions (
    block bigint NOT NULL,
    hash text NOT NULL,
    type public.transaction_type NOT NULL,
    fields jsonb NOT NULL,
    "time" bigint NOT NULL
);


ALTER TABLE public.transactions OWNER TO etl;

--
-- Name: challenge_receipts; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.challenge_receipts AS
 SELECT transactions.block,
    transactions.hash,
    transactions.type,
    (transactions.fields ->> 'challenger'::text) AS challenger,
    (transactions.fields ->> 'challenger_location'::text) AS challenger_location,
    (transactions.fields ->> 'challenger_owner'::text) AS challenger_owner,
    (transactions.fields ->> 'fee'::text) AS fee,
    (transactions.fields ->> 'onion_key_hash'::text) AS onion_key_hash,
    (transactions.fields ->> 'path'::text) AS path,
    (transactions.fields ->> 'secret'::text) AS secret,
    to_timestamp((transactions."time")::double precision) AS "time"
   FROM public.transactions
  WHERE (transactions.type = 'poc_receipts_v1'::public.transaction_type);


ALTER TABLE public.challenge_receipts OWNER TO etl;

--
-- Name: challenge_receipts_parsed; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.challenge_receipts_parsed (
    block bigint,
    hash text,
    "time" timestamp with time zone,
    transmitter_name text,
    transmitter_address text,
    origin text,
    witness_owner text,
    witness_name text,
    witness_gateway text,
    witness_is_valid text,
    witness_invalid_reason text,
    witness_signal text,
    witness_snr text,
    witness_channel text,
    witness_datarate text,
    witness_frequency text,
    witness_location text,
    witness_timestamp text
);


ALTER TABLE public.challenge_receipts_parsed OWNER TO etl;

--
-- Name: challenge_receipts_parsed_old; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.challenge_receipts_parsed_old (
    block bigint,
    hash text,
    "time" timestamp with time zone,
    transmitter_name text,
    transmitter_address text,
    origin text,
    witness_owner text,
    witness_name text,
    witness_gateway text,
    witness_is_valid text,
    witness_invalid_reason text,
    witness_signal text,
    witness_snr text,
    witness_channel text,
    witness_datarate text,
    witness_frequency text,
    witness_location text,
    witness_timestamp text
);


ALTER TABLE public.challenge_receipts_parsed_old OWNER TO etl;

--
-- Name: challenge_requests; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.challenge_requests AS
 SELECT transactions.block,
    transactions.hash,
    transactions.type,
    (transactions.fields ->> 'block_hash'::text) AS block_hash,
    (transactions.fields ->> 'challenger'::text) AS challenger,
    (transactions.fields ->> 'challenger_location'::text) AS challenger_location,
    (transactions.fields ->> 'challenger_owner'::text) AS challenger_owner,
    (transactions.fields ->> 'fee'::text) AS fee,
    (transactions.fields ->> 'onion_key_hash'::text) AS onion_key_hash,
    (transactions.fields ->> 'secret_hash'::text) AS secret_hash,
    (transactions.fields ->> 'version'::text) AS version,
    to_timestamp((transactions."time")::double precision) AS "time"
   FROM public.transactions
  WHERE (transactions.type = 'poc_request_v1'::public.transaction_type);


ALTER TABLE public.challenge_requests OWNER TO etl;

--
-- Name: rewards; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.rewards (
    block bigint NOT NULL,
    transaction_hash text NOT NULL,
    "time" bigint NOT NULL,
    account text NOT NULL,
    gateway text NOT NULL,
    amount bigint NOT NULL
)
WITH (autovacuum_enabled='true');


ALTER TABLE public.rewards OWNER TO etl;

--
-- Name: data_credits; Type: MATERIALIZED VIEW; Schema: public; Owner: etl
--

CREATE MATERIALIZED VIEW public.data_credits AS
 WITH second AS (
         WITH first AS (
                 SELECT transactions.type,
                    ((transactions.fields -> 'state_channel'::text) -> 'summaries'::text) AS sums,
                    to_timestamp((transactions."time")::double precision) AS "time"
                   FROM public.transactions
                  WHERE (transactions.type = 'state_channel_close_v1'::public.transaction_type)
                 LIMIT 1048576
                )
         SELECT first.sums AS summaries,
            date_trunc('day'::text, first."time") AS "time"
           FROM first
        )
 SELECT second."time",
    (json_array_elements(to_json(second.summaries)) ->> 'owner'::text) AS owner,
    (json_array_elements(to_json(second.summaries)) ->> 'client'::text) AS client,
    (json_array_elements(to_json(second.summaries)) ->> 'location'::text) AS location,
    ((json_array_elements(to_json(second.summaries)) ->> 'num_dcs'::text))::integer AS dcs,
    ((json_array_elements(to_json(second.summaries)) ->> 'num_packets'::text))::integer AS packets
   FROM second
  WITH NO DATA;


ALTER TABLE public.data_credits OWNER TO etl;

--
-- Name: data_credits_with_locations; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.data_credits_with_locations AS
 SELECT data_credits."time",
    data_credits.owner,
    data_credits.client,
    data_credits.location,
    data_credits.dcs,
    data_credits.packets,
    locations.long_street,
    locations.short_street,
    locations.long_city,
    locations.short_city,
    locations.long_state,
    locations.short_state,
    locations.long_country,
    locations.short_country,
    locations.search_city,
    locations.city_id,
    locations.geometry,
    public.st_y(locations.geometry) AS lat,
    public.st_x(locations.geometry) AS long
   FROM (public.data_credits
     LEFT JOIN public.locations locations ON ((data_credits.location = locations.location)))
  WHERE (locations.geometry IS NOT NULL);


ALTER TABLE public.data_credits_with_locations OWNER TO etl;

--
-- Name: dc_burns; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.dc_burns (
    block bigint,
    transaction_hash text NOT NULL,
    actor text NOT NULL,
    type public.burn_type NOT NULL,
    amount bigint NOT NULL,
    oracle_price bigint,
    "time" bigint
);


ALTER TABLE public.dc_burns OWNER TO etl;

--
-- Name: gateway_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.gateway_inventory (
    address text NOT NULL,
    owner text NOT NULL,
    location text,
    last_poc_challenge bigint,
    last_poc_onion_key_hash text,
    witnesses jsonb NOT NULL,
    first_block bigint,
    last_block bigint,
    nonce bigint,
    name text,
    first_timestamp timestamp with time zone,
    reward_scale double precision,
    elevation integer,
    gain integer,
    location_hex text,
    mode public.gateway_mode,
    payer text
);


ALTER TABLE public.gateway_inventory OWNER TO etl;

--
-- Name: gateway_status; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.gateway_status (
    address text NOT NULL,
    online public.gateway_status_online,
    block bigint,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    poc_interval bigint,
    last_challenge bigint,
    peer_timestamp timestamp with time zone,
    listen_addrs jsonb
);


ALTER TABLE public.gateway_status OWNER TO etl;

--
-- Name: gateways; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.gateways (
    block bigint NOT NULL,
    address text NOT NULL,
    owner text NOT NULL,
    location text,
    last_poc_challenge bigint,
    last_poc_onion_key_hash text,
    witnesses jsonb NOT NULL,
    nonce bigint,
    name text,
    "time" bigint,
    reward_scale double precision,
    elevation integer,
    gain integer,
    location_hex text,
    mode public.gateway_mode
);


ALTER TABLE public.gateways OWNER TO etl;

--
-- Name: maker_address; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.maker_address AS
 SELECT 'Helium Inc'::text AS maker,
    '13daGGWvDQyTyHFDCPz8zDSVTWgPNNfJ4oh31Teec4TRWfjMx53'::text AS address
UNION
 SELECT 'Cal-Chip Connected Devices'::text AS maker,
    '13ENbEQPAvytjLnqavnbSAzurhGoCSNkGECMx7eHHDAfEaDirdY'::text AS address
UNION
 SELECT 'Maker Integration Tests'::text AS maker,
    '138LbePH4r7hWPuTnK6HXVJ8ATM2QU71iVHzLTup1UbnPDvbxmr'::text AS address
UNION
 SELECT 'Nebra Ltd'::text AS maker,
    '13Zni1he7KY9pUmkXMhEhTwfUpL9AcEV1m2UbbvFsrU9QPTMgE3'::text AS address
UNION
 SELECT 'SyncroB.it'::text AS maker,
    '14rb2UcfS9U89QmKswpZpjRCUVCVu1haSyqyGY486EvsYtvdJmR'::text AS address
UNION
 SELECT 'Bobcat'::text AS maker,
    '14sKWeeYWQWrBSnLGq79uRQqZyw3Ldi7oBdxbF6a54QboTNBXDL'::text AS address
UNION
 SELECT 'LongAP'::text AS maker,
    '12zX4jgDGMbJgRwmCfRNGXBuphkQRqkUTcLzYHTQvd4Qgu8kiL4'::text AS address
UNION
 SELECT 'Smart Mimic'::text AS maker,
    '13MS2kZHU4h6wp3tExgoHdDFjBsb9HB9JBvcbK9XmfNyJ7jqzVv'::text AS address
UNION
 SELECT 'RAKwireless'::text AS maker,
    '14h2zf1gEr9NmvDb2U53qucLN2jLrKU1ECBoxGnSnQ6tiT6V2kM'::text AS address
UNION
 SELECT 'Kerlink'::text AS maker,
    '13Mpg5hCNjSxHJvWjaanwJPBuTXu1d4g5pGvGBkqQe3F8mAwXhK'::text AS address
UNION
 SELECT 'DeWi Foundation'::text AS maker,
    '13LVwCqZEKLTVnf3sjGPY1NMkTE7fWtUVjmDfeuscMFgeK3f9pn'::text AS address
UNION
 SELECT 'SenseCAP'::text AS maker,
    '14NBXJE5kAAZTMigY4dcjXSMG4CSqjYwvteQWwQsYhsu2TKN6AF'::text AS address
UNION
 SELECT 'Helium Inc (old)'::text AS maker,
    '14fzfjFcHpDR1rTH8BNPvSi5dKBbgxaDnmsVPbCjuq9ENjpZbxh'::text AS address;


ALTER TABLE public.maker_address OWNER TO etl;

--
-- Name: oracle_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.oracle_inventory (
    address text NOT NULL
);


ALTER TABLE public.oracle_inventory OWNER TO etl;

--
-- Name: oracle_price_predictions; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.oracle_price_predictions (
    "time" bigint NOT NULL,
    price bigint NOT NULL
);


ALTER TABLE public.oracle_price_predictions OWNER TO etl;

--
-- Name: oracle_price_transactions; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.oracle_price_transactions AS
 SELECT transactions.block,
    transactions.hash,
    transactions.type,
    ((transactions.fields ->> 'fee'::text))::bigint AS fee,
    ((transactions.fields ->> 'price'::text))::bigint AS price,
    (transactions.fields ->> 'public_key'::text) AS public_key,
    (transactions.fields ->> 'block_height'::text) AS block_height,
    to_timestamp((transactions."time")::double precision) AS "time"
   FROM public.transactions
  WHERE (transactions.type = 'price_oracle_v1'::public.transaction_type);


ALTER TABLE public.oracle_price_transactions OWNER TO etl;

--
-- Name: oracle_prices; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.oracle_prices (
    block bigint NOT NULL,
    price bigint NOT NULL
);


ALTER TABLE public.oracle_prices OWNER TO etl;

--
-- Name: oui_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.oui_inventory (
    oui bigint NOT NULL,
    owner text NOT NULL,
    nonce bigint NOT NULL,
    addresses text[] NOT NULL,
    subnets integer[] NOT NULL,
    first_block bigint,
    last_block bigint
);


ALTER TABLE public.oui_inventory OWNER TO etl;

--
-- Name: ouis; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.ouis (
    block bigint NOT NULL,
    oui bigint NOT NULL,
    owner text NOT NULL,
    nonce bigint NOT NULL,
    addresses text[] NOT NULL,
    subnets integer[] NOT NULL
);


ALTER TABLE public.ouis OWNER TO etl;

--
-- Name: packets; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.packets (
    block bigint NOT NULL,
    transaction_hash text NOT NULL,
    "time" bigint NOT NULL,
    gateway text NOT NULL,
    num_packets bigint NOT NULL,
    num_dcs bigint NOT NULL
);


ALTER TABLE public.packets OWNER TO etl;

--
-- Name: pending_transaction_actors; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.pending_transaction_actors (
    actor text NOT NULL,
    actor_role public.transaction_actor_role NOT NULL,
    transaction_hash text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.pending_transaction_actors OWNER TO etl;

--
-- Name: pending_transactions; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.pending_transactions (
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    hash text NOT NULL,
    type public.transaction_type NOT NULL,
    address text,
    nonce bigint NOT NULL,
    nonce_type public.pending_transaction_nonce_type NOT NULL,
    status public.pending_transaction_status NOT NULL,
    failed_reason text,
    data bytea NOT NULL,
    fields jsonb
);


ALTER TABLE public.pending_transactions OWNER TO etl;

--
-- Name: stats_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.stats_inventory (
    name text NOT NULL,
    value bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.stats_inventory OWNER TO etl;

--
-- Name: transaction_actors; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.transaction_actors (
    actor text NOT NULL,
    actor_role public.transaction_actor_role NOT NULL,
    transaction_hash text NOT NULL,
    block bigint NOT NULL
);


ALTER TABLE public.transaction_actors OWNER TO etl;

--
-- Name: transactions_assert_location; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.transactions_assert_location AS
 SELECT transactions.block,
    transactions.hash,
    transactions.type,
    (transactions.fields ->> 'fee'::text) AS fee,
    ((transactions.fields ->> 'nonce'::text))::integer AS nonce,
    (transactions.fields ->> 'owner'::text) AS owner,
    (transactions.fields ->> 'payer'::text) AS payer,
    (transactions.fields ->> 'gateway'::text) AS gateway,
    (transactions.fields ->> 'location'::text) AS location,
    (transactions.fields ->> 'staking_fee'::text) AS staking_fee,
    to_timestamp((transactions."time")::double precision) AS "time"
   FROM public.transactions
  WHERE (transactions.type = 'assert_location_v1'::public.transaction_type);


ALTER TABLE public.transactions_assert_location OWNER TO etl;

--
-- Name: transactions_exploded; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.transactions_exploded AS
 SELECT transactions.block,
    transactions.hash,
    transactions.type,
    ((transactions.fields ->> 'fee'::text))::bigint AS fee,
    ((transactions.fields ->> 'price'::text))::bigint AS price,
    (transactions.fields ->> 'public_key'::text) AS public_key,
    (transactions.fields ->> 'block_height'::text) AS block_height,
    ((transactions.fields ->> 'nonce'::text))::integer AS nonce,
    (transactions.fields ->> 'owner'::text) AS owner,
    (transactions.fields ->> 'payer'::text) AS payer,
    (transactions.fields ->> 'gateway'::text) AS gateway,
    (transactions.fields ->> 'location'::text) AS location,
    (transactions.fields ->> 'staking_fee'::text) AS staking_fee,
    (transactions.fields ->> 'block_hash'::text) AS block_hash,
    (transactions.fields ->> 'challenger'::text) AS challenger,
    (transactions.fields ->> 'challenger_location'::text) AS challenger_location,
    (transactions.fields ->> 'challenger_owner'::text) AS challenger_owner,
    (transactions.fields ->> 'onion_key_hash'::text) AS onion_key_hash,
    (transactions.fields ->> 'secret_hash'::text) AS secret_hash,
    ((transactions.fields ->> 'version'::text))::integer AS version,
    (transactions.fields ->> 'path'::text) AS path,
    (transactions.fields ->> 'secret'::text) AS secret,
    to_timestamp((transactions."time")::double precision) AS "time"
   FROM public.transactions;


ALTER TABLE public.transactions_exploded OWNER TO etl;

--
-- Name: transactions_transfer_hotspot; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.transactions_transfer_hotspot AS
 SELECT transactions.block,
    transactions.hash,
    transactions.type,
    (transactions.fields ->> 'buyer'::text) AS buyer,
    (transactions.fields ->> 'seller'::text) AS seller,
    (transactions.fields ->> 'gateway'::text) AS gateway,
    ((transactions.fields ->> 'buyer_nonce'::text))::integer AS buyer_nonce,
    ((transactions.fields ->> 'amount_to_seller'::text))::bigint AS amount_to_seller,
    to_timestamp((transactions."time")::double precision) AS "time"
   FROM public.transactions
  WHERE (transactions.type = 'transfer_hotspot_v1'::public.transaction_type);


ALTER TABLE public.transactions_transfer_hotspot OWNER TO etl;

--
-- Name: validator_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.validator_inventory (
    address text NOT NULL,
    name text NOT NULL,
    owner text NOT NULL,
    status public.validator_status_type NOT NULL,
    stake bigint DEFAULT 0 NOT NULL,
    nonce bigint NOT NULL,
    last_heartbeat bigint,
    version_heartbeat bigint NOT NULL,
    penalty double precision DEFAULT 0 NOT NULL,
    penalties jsonb,
    first_block bigint,
    last_block bigint
);


ALTER TABLE public.validator_inventory OWNER TO etl;

--
-- Name: validator_penalty_parsed; Type: VIEW; Schema: public; Owner: etl
--

CREATE VIEW public.validator_penalty_parsed AS
 WITH data1 AS (
         SELECT a.address,
            a.name,
            a.owner,
            b.value AS cpen
           FROM public.validator_inventory a,
            LATERAL json_array_elements((a.penalties)::json) b(value)
        ), data2 AS (
         SELECT data1.address,
            data1.name,
            data1.owner,
            (data1.cpen ->> 'type'::text) AS penalty_type,
            ((data1.cpen ->> 'amount'::text))::double precision AS penalty_amount,
            ((data1.cpen ->> 'height'::text))::bigint AS penalty_height
           FROM data1
        )
 SELECT data2.address,
    data2.name,
    data2.owner,
    data2.penalty_type,
    data2.penalty_amount,
    data2.penalty_height
   FROM data2;


ALTER TABLE public.validator_penalty_parsed OWNER TO etl;

--
-- Name: validator_status; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.validator_status (
    address text NOT NULL,
    online public.validator_status_online,
    block bigint,
    peer_timestamp timestamp with time zone,
    listen_addrs jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.validator_status OWNER TO etl;

--
-- Name: validators; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.validators (
    block bigint NOT NULL,
    address text NOT NULL,
    name text NOT NULL,
    owner text NOT NULL,
    status public.validator_status_type NOT NULL,
    stake bigint DEFAULT 0 NOT NULL,
    nonce bigint NOT NULL,
    last_heartbeat bigint,
    version_heartbeat bigint NOT NULL,
    penalty double precision DEFAULT 0 NOT NULL,
    penalties jsonb
);


ALTER TABLE public.validators OWNER TO etl;

--
-- Name: vars_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.vars_inventory (
    name text NOT NULL,
    type public.var_type NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.vars_inventory OWNER TO etl;

--
-- Name: __migrations __migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.__migrations
    ADD CONSTRAINT __migrations_pkey PRIMARY KEY (id);


--
-- Name: account_inventory account_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.account_inventory
    ADD CONSTRAINT account_inventory_pkey PRIMARY KEY (address);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (block, address);


--
-- Name: block_signatures block_signatures_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.block_signatures
    ADD CONSTRAINT block_signatures_pkey PRIMARY KEY (block, signer);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (height);


--
-- Name: dc_burns dc_burns_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.dc_burns
    ADD CONSTRAINT dc_burns_pkey PRIMARY KEY (actor, transaction_hash, type);


--
-- Name: gateway_inventory gateway_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateway_inventory
    ADD CONSTRAINT gateway_inventory_pkey PRIMARY KEY (address);


--
-- Name: gateway_status gateway_status_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateway_status
    ADD CONSTRAINT gateway_status_pkey PRIMARY KEY (address);


--
-- Name: gateways gateways_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateways
    ADD CONSTRAINT gateways_pkey PRIMARY KEY (block, address);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (location);


--
-- Name: oracle_inventory oracle_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.oracle_inventory
    ADD CONSTRAINT oracle_inventory_pkey PRIMARY KEY (address);


--
-- Name: oracle_price_predictions oracle_price_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.oracle_price_predictions
    ADD CONSTRAINT oracle_price_predictions_pkey PRIMARY KEY ("time");


--
-- Name: oui_inventory oui_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.oui_inventory
    ADD CONSTRAINT oui_inventory_pkey PRIMARY KEY (oui);


--
-- Name: ouis ouis_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.ouis
    ADD CONSTRAINT ouis_pkey PRIMARY KEY (block, oui);


--
-- Name: packets packets_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.packets
    ADD CONSTRAINT packets_pkey PRIMARY KEY (block, transaction_hash, gateway);


--
-- Name: pending_transaction_actors pending_transaction_actors_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.pending_transaction_actors
    ADD CONSTRAINT pending_transaction_actors_pkey PRIMARY KEY (actor, actor_role, created_at);


--
-- Name: pending_transactions pending_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.pending_transactions
    ADD CONSTRAINT pending_transactions_pkey PRIMARY KEY (created_at);


--
-- Name: rewards rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (block, account, gateway);


--
-- Name: stats_inventory stats_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.stats_inventory
    ADD CONSTRAINT stats_inventory_pkey PRIMARY KEY (name);


--
-- Name: transaction_actors transaction_actors_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.transaction_actors
    ADD CONSTRAINT transaction_actors_pkey PRIMARY KEY (actor, actor_role, transaction_hash);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (hash);


--
-- Name: validator_inventory validator_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validator_inventory
    ADD CONSTRAINT validator_inventory_pkey PRIMARY KEY (address);


--
-- Name: validator_status validator_status_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validator_status
    ADD CONSTRAINT validator_status_pkey PRIMARY KEY (address);


--
-- Name: validators validators_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validators
    ADD CONSTRAINT validators_pkey PRIMARY KEY (block, address);


--
-- Name: vars_inventory vars_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.vars_inventory
    ADD CONSTRAINT vars_inventory_pkey PRIMARY KEY (name);


--
-- Name: account_address_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX account_address_idx ON public.accounts USING btree (address);


--
-- Name: account_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX account_block_idx ON public.accounts USING btree (block);


--
-- Name: account_inventory_first_block; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX account_inventory_first_block ON public.account_inventory USING btree (first_block);


--
-- Name: blocks_snapshot_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX blocks_snapshot_idx ON public.blocks USING btree (snapshot_hash);


--
-- Name: challenge_receipts_parsed2_transmitter_address_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX challenge_receipts_parsed2_transmitter_address_idx ON public.challenge_receipts_parsed USING btree (transmitter_address);


--
-- Name: challenge_receipts_parsed2_transmitter_name_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX challenge_receipts_parsed2_transmitter_name_idx ON public.challenge_receipts_parsed USING btree (transmitter_name);


--
-- Name: challenge_receipts_parsed2_witness_name_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX challenge_receipts_parsed2_witness_name_idx ON public.challenge_receipts_parsed USING btree (witness_name);


--
-- Name: challenge_receipts_parsed_transmitter_address_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX challenge_receipts_parsed_transmitter_address_idx ON public.challenge_receipts_parsed_old USING btree (transmitter_address);


--
-- Name: challenge_receipts_parsed_transmitter_name_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX challenge_receipts_parsed_transmitter_name_idx ON public.challenge_receipts_parsed_old USING btree (transmitter_name);


--
-- Name: challenge_receipts_parsed_witness_name_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX challenge_receipts_parsed_witness_name_idx ON public.challenge_receipts_parsed_old USING btree (witness_name);


--
-- Name: data_credits_client_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX data_credits_client_idx ON public.data_credits USING btree (client);


--
-- Name: dc_burns_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX dc_burns_block_idx ON public.dc_burns USING brin ("time");


--
-- Name: gateway_address_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_address_idx ON public.gateways USING btree (address);


--
-- Name: gateway_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_block_idx ON public.gateways USING btree (block);


--
-- Name: gateway_inventory_first_block; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_inventory_first_block ON public.gateway_inventory USING btree (first_block);


--
-- Name: gateway_inventory_first_timestamp; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_inventory_first_timestamp ON public.gateway_inventory USING btree (first_timestamp);


--
-- Name: gateway_inventory_location_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_inventory_location_idx ON public.gateway_inventory USING btree (location);


--
-- Name: gateway_inventory_name; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_inventory_name ON public.gateway_inventory USING btree (name);


--
-- Name: gateway_inventory_owner; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_inventory_owner ON public.gateway_inventory USING btree (owner);


--
-- Name: gateway_owner_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_owner_idx ON public.gateways USING btree (owner);


--
-- Name: gateway_search_name_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_search_name_idx ON public.gateway_inventory USING gin (name public.gin_trgm_ops);


--
-- Name: gateway_status_updated_at_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX gateway_status_updated_at_idx ON public.gateway_status USING btree (updated_at);


--
-- Name: location_city_id_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX location_city_id_idx ON public.locations USING btree (city_id);


--
-- Name: location_search_city_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX location_search_city_idx ON public.locations USING gin (search_city public.gin_trgm_ops);


--
-- Name: oracle_prices_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX oracle_prices_block_idx ON public.oracle_prices USING btree (block);


--
-- Name: oui_inventory_first_block; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX oui_inventory_first_block ON public.oui_inventory USING btree (first_block);


--
-- Name: oui_owner_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX oui_owner_idx ON public.oui_inventory USING btree (owner);


--
-- Name: packets_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX packets_block_idx ON public.packets USING btree (block);


--
-- Name: packets_gateway_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX packets_gateway_idx ON public.packets USING btree (gateway);


--
-- Name: pending_transaction_hash_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX pending_transaction_hash_idx ON public.pending_transactions USING btree (hash);


--
-- Name: pending_transaction_nonce_type_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX pending_transaction_nonce_type_idx ON public.pending_transactions USING btree (nonce_type);


--
-- Name: rewards_account_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX rewards_account_idx ON public.rewards USING btree (account);


--
-- Name: rewards_gateway_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX rewards_gateway_idx ON public.rewards USING btree (gateway);


--
-- Name: rewards_time_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX rewards_time_idx ON public.rewards USING brin ("time");


--
-- Name: transaction_actor_actor_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX transaction_actor_actor_idx ON public.transaction_actors USING btree (actor);


--
-- Name: transaction_actor_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX transaction_actor_block_idx ON public.transaction_actors USING btree (block);


--
-- Name: transaction_actor_role_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX transaction_actor_role_idx ON public.transaction_actors USING btree (actor_role);


--
-- Name: transaction_actor_transaction_hash_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX transaction_actor_transaction_hash_idx ON public.transaction_actors USING btree (transaction_hash);


--
-- Name: transaction_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX transaction_block_idx ON public.transactions USING btree (block);


--
-- Name: transaction_time_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX transaction_time_idx ON public.transactions USING btree ("time");


--
-- Name: transaction_type_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX transaction_type_idx ON public.transactions USING btree (type);


--
-- Name: validator_inventory_first_block; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX validator_inventory_first_block ON public.validator_inventory USING btree (first_block);


--
-- Name: validator_name_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX validator_name_idx ON public.validator_inventory USING btree (name);


--
-- Name: validator_owner_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX validator_owner_idx ON public.validator_inventory USING btree (owner);


--
-- Name: validator_search_name_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX validator_search_name_idx ON public.validator_inventory USING gin (name public.gin_trgm_ops);


--
-- Name: validator_status_updated_at_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX validator_status_updated_at_idx ON public.validator_status USING btree (updated_at);


--
-- Name: accounts account_insert; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER account_insert AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE PROCEDURE public.account_inventory_update();


--
-- Name: gateways gateway_insert; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER gateway_insert AFTER INSERT ON public.gateways FOR EACH ROW EXECUTE PROCEDURE public.gateway_inventory_update();


--
-- Name: gateway_inventory gateway_inventory_insert; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER gateway_inventory_insert AFTER INSERT ON public.gateway_inventory FOR EACH ROW EXECUTE PROCEDURE public.gateway_inventory_on_insert();


--
-- Name: gateway_status gateway_status_set_updated_at; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER gateway_status_set_updated_at BEFORE UPDATE ON public.gateway_status FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_updated_at();


--
-- Name: locations location_update_city_id; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER location_update_city_id BEFORE INSERT ON public.locations FOR EACH ROW EXECUTE PROCEDURE public.location_city_id_update();


--
-- Name: locations location_update_search_city; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER location_update_search_city BEFORE INSERT ON public.locations FOR EACH ROW EXECUTE PROCEDURE public.location_search_city_update();


--
-- Name: ouis oui_insert; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER oui_insert AFTER INSERT ON public.ouis FOR EACH ROW EXECUTE PROCEDURE public.oui_inventory_update();


--
-- Name: pending_transactions pending_transaction_set_updated_at; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER pending_transaction_set_updated_at BEFORE UPDATE ON public.pending_transactions FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_updated_at();


--
-- Name: validators validator_insert; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER validator_insert AFTER INSERT ON public.validators FOR EACH ROW EXECUTE PROCEDURE public.validator_inventory_update();


--
-- Name: validator_status validator_status_set_updated_at; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER validator_status_set_updated_at BEFORE UPDATE ON public.validator_status FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_updated_at();


--
-- Name: account_inventory account_inventory_first_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.account_inventory
    ADD CONSTRAINT account_inventory_first_block_fkey FOREIGN KEY (first_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: account_inventory account_inventory_last_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.account_inventory
    ADD CONSTRAINT account_inventory_last_block_fkey FOREIGN KEY (last_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: accounts accounts_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: block_signatures block_signatures_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.block_signatures
    ADD CONSTRAINT block_signatures_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: dc_burns dc_burns_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.dc_burns
    ADD CONSTRAINT dc_burns_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height);


--
-- Name: dc_burns dc_burns_transaction_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.dc_burns
    ADD CONSTRAINT dc_burns_transaction_hash_fkey FOREIGN KEY (transaction_hash) REFERENCES public.transactions(hash) ON DELETE CASCADE;


--
-- Name: gateway_inventory gateway_inventory_first_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateway_inventory
    ADD CONSTRAINT gateway_inventory_first_block_fkey FOREIGN KEY (first_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: gateway_inventory gateway_inventory_last_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateway_inventory
    ADD CONSTRAINT gateway_inventory_last_block_fkey FOREIGN KEY (last_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: gateway_inventory gateway_inventory_last_poc_challenge_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateway_inventory
    ADD CONSTRAINT gateway_inventory_last_poc_challenge_fkey FOREIGN KEY (last_poc_challenge) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: gateway_status gateway_status_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateway_status
    ADD CONSTRAINT gateway_status_address_fkey FOREIGN KEY (address) REFERENCES public.gateway_inventory(address) ON DELETE CASCADE;


--
-- Name: gateways gateways_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateways
    ADD CONSTRAINT gateways_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: gateways gateways_last_poc_challenge_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.gateways
    ADD CONSTRAINT gateways_last_poc_challenge_fkey FOREIGN KEY (last_poc_challenge) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: oracle_prices oracle_prices_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.oracle_prices
    ADD CONSTRAINT oracle_prices_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: oui_inventory oui_inventory_first_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.oui_inventory
    ADD CONSTRAINT oui_inventory_first_block_fkey FOREIGN KEY (first_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: oui_inventory oui_inventory_last_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.oui_inventory
    ADD CONSTRAINT oui_inventory_last_block_fkey FOREIGN KEY (last_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: ouis ouis_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.ouis
    ADD CONSTRAINT ouis_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: packets packets_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.packets
    ADD CONSTRAINT packets_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: packets packets_transaction_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.packets
    ADD CONSTRAINT packets_transaction_hash_fkey FOREIGN KEY (transaction_hash) REFERENCES public.transactions(hash);


--
-- Name: pending_transaction_actors pending_transaction_actors_created_at_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.pending_transaction_actors
    ADD CONSTRAINT pending_transaction_actors_created_at_fkey FOREIGN KEY (created_at) REFERENCES public.pending_transactions(created_at);


--
-- Name: rewards rewards_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT rewards_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: rewards rewards_transaction_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT rewards_transaction_hash_fkey FOREIGN KEY (transaction_hash) REFERENCES public.transactions(hash);


--
-- Name: transaction_actors transaction_actors_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.transaction_actors
    ADD CONSTRAINT transaction_actors_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height);


--
-- Name: transaction_actors transaction_actors_transaction_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.transaction_actors
    ADD CONSTRAINT transaction_actors_transaction_hash_fkey FOREIGN KEY (transaction_hash) REFERENCES public.transactions(hash) ON DELETE CASCADE;


--
-- Name: transactions transactions_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: validator_inventory validator_inventory_first_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validator_inventory
    ADD CONSTRAINT validator_inventory_first_block_fkey FOREIGN KEY (first_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: validator_inventory validator_inventory_last_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validator_inventory
    ADD CONSTRAINT validator_inventory_last_block_fkey FOREIGN KEY (last_block) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: validator_inventory validator_inventory_last_heartbeat_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validator_inventory
    ADD CONSTRAINT validator_inventory_last_heartbeat_fkey FOREIGN KEY (last_heartbeat) REFERENCES public.blocks(height) ON DELETE SET NULL;


--
-- Name: validator_status validator_status_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validator_status
    ADD CONSTRAINT validator_status_address_fkey FOREIGN KEY (address) REFERENCES public.validator_inventory(address) ON DELETE CASCADE;


--
-- Name: validators validators_block_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validators
    ADD CONSTRAINT validators_block_fkey FOREIGN KEY (block) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: validators validators_last_heartbeat_fkey; Type: FK CONSTRAINT; Schema: public; Owner: etl
--

ALTER TABLE ONLY public.validators
    ADD CONSTRAINT validators_last_heartbeat_fkey FOREIGN KEY (last_heartbeat) REFERENCES public.blocks(height) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA public TO readaccess;


--
-- Name: TABLE locations; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.locations TO readaccess;


--
-- Name: TABLE __migrations; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.__migrations TO readaccess;


--
-- Name: TABLE account_inventory; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.account_inventory TO readaccess;


--
-- Name: TABLE accounts; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.accounts TO readaccess;


--
-- Name: TABLE block_signatures; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.block_signatures TO readaccess;


--
-- Name: TABLE blocks; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.blocks TO readaccess;


--
-- Name: TABLE transactions; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.transactions TO readaccess;


--
-- Name: TABLE challenge_receipts; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.challenge_receipts TO readaccess;


--
-- Name: TABLE challenge_receipts_parsed; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.challenge_receipts_parsed TO readaccess;


--
-- Name: TABLE challenge_receipts_parsed_old; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.challenge_receipts_parsed_old TO readaccess;


--
-- Name: TABLE challenge_requests; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.challenge_requests TO readaccess;


--
-- Name: TABLE rewards; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.rewards TO readaccess;


--
-- Name: TABLE data_credits; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.data_credits TO readaccess;


--
-- Name: TABLE data_credits_with_locations; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.data_credits_with_locations TO readaccess;


--
-- Name: TABLE dc_burns; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.dc_burns TO readaccess;


--
-- Name: TABLE gateway_inventory; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.gateway_inventory TO readaccess;


--
-- Name: TABLE gateway_status; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.gateway_status TO readaccess;


--
-- Name: TABLE gateways; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.gateways TO readaccess;


--
-- Name: TABLE oracle_inventory; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.oracle_inventory TO readaccess;


--
-- Name: TABLE oracle_price_predictions; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.oracle_price_predictions TO readaccess;


--
-- Name: TABLE oracle_price_transactions; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.oracle_price_transactions TO readaccess;


--
-- Name: TABLE oracle_prices; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.oracle_prices TO readaccess;


--
-- Name: TABLE oui_inventory; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.oui_inventory TO readaccess;


--
-- Name: TABLE ouis; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.ouis TO readaccess;


--
-- Name: TABLE packets; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.packets TO readaccess;


--
-- Name: TABLE pending_transaction_actors; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.pending_transaction_actors TO readaccess;


--
-- Name: TABLE pending_transactions; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.pending_transactions TO readaccess;


--
-- Name: TABLE stats_inventory; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.stats_inventory TO readaccess;


--
-- Name: TABLE transaction_actors; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.transaction_actors TO readaccess;


--
-- Name: TABLE transactions_assert_location; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.transactions_assert_location TO readaccess;


--
-- Name: TABLE transactions_exploded; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.transactions_exploded TO readaccess;


--
-- Name: TABLE transactions_transfer_hotspot; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.transactions_transfer_hotspot TO readaccess;


--
-- Name: TABLE validator_inventory; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.validator_inventory TO readaccess;


--
-- Name: TABLE validator_status; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.validator_status TO readaccess;


--
-- Name: TABLE validators; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.validators TO readaccess;


--
-- Name: TABLE vars_inventory; Type: ACL; Schema: public; Owner: etl
--

GRANT SELECT ON TABLE public.vars_inventory TO readaccess;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: etl
--

ALTER DEFAULT PRIVILEGES FOR ROLE etl IN SCHEMA public REVOKE ALL ON TABLES  FROM etl;
ALTER DEFAULT PRIVILEGES FOR ROLE etl IN SCHEMA public GRANT SELECT ON TABLES  TO readaccess;


--
-- PostgreSQL database dump complete
--

