--
-- PostgreSQL database dump
--

-- Dumped from database version 10.15 (Ubuntu 10.15-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.15 (Ubuntu 10.15-0ubuntu0.18.04.1)

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: gateway_status_online; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.gateway_status_online AS ENUM (
    'online',
    'offline'
);


--
-- Name: pending_transaction_nonce_type; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.pending_transaction_nonce_type AS ENUM (
    'balance',
    'security',
    'none',
    'gateway'
);


--
-- Name: pending_transaction_status; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.pending_transaction_status AS ENUM (
    'received',
    'pending',
    'failed',
    'cleared'
);


--
-- Name: reward_entry; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.reward_entry AS (
	account text,
	gateway text,
	type text,
	amount bigint
);


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
    'oracle'
);


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
    'transfer_hotspot_v1'
);


--
-- Name: var_type; Type: TYPE; Schema: public; Owner: etl
--

CREATE TYPE public.var_type AS ENUM (
    'integer',
    'float',
    'atom',
    'binary'
);


--
-- Name: account_inventory_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.account_inventory_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$  BEGIN    insert into account_inventory           (address,           balance, nonce,           dc_balance, dc_nonce,           security_balance, security_nonce,           first_block, last_block)    VALUES          (NEW.address,          NEW.balance, NEW.nonce,          NEW.dc_balance, NEW.dc_nonce,          NEW.security_balance, NEW.security_nonce,          NEW.block, NEW.block          )    ON CONFLICT (address) DO UPDATE SET         balance = EXCLUDED.balance,         nonce = EXCLUDED.nonce,         dc_balance = EXCLUDED.dc_balance,         dc_nonce = EXCLUDED.dc_nonce,         security_balance = EXCLUDED.security_balance,         security_nonce = EXCLUDED.security_nonce,         last_block = EXCLUDED.last_block;   RETURN NEW;  END;  $$;


--
-- Name: gateway_inventory_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.gateway_inventory_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN   insert into gateway_inventory          (address, name, owner, location, alpha, beta, delta, score,           last_poc_challenge, last_poc_onion_key_hash, witnesses, nonce,           first_block, last_block, first_timestamp)   VALUES         (NEW.address, NEW.name, NEW.owner, NEW.location, NEW.alpha, NEW.beta, NEW.delta, NEW.score,         NEW.last_poc_challenge, NEW.last_poc_onion_key_hash, NEW.witnesses, NEW.nonce,         NEW.block, NEW.block, to_timestamp(NEW.time)         )   ON CONFLICT (address) DO UPDATE SET        owner = EXCLUDED.owner,        location = EXCLUDED.location,        alpha = EXCLUDED.alpha,        beta = EXCLUDED.beta,        delta = EXCLUDED.delta,        score = EXCLUDED.score,        last_poc_challenge = EXCLUDED.last_poc_challenge,        last_poc_onion_key_hash = EXCLUDED.last_poc_onion_key_hash,        witnesses = EXCLUDED.witnesses,        nonce = EXCLUDED.nonce,        last_block = EXCLUDED.last_block;   RETURN NEW; END; $$;


--
-- Name: insert_rewards(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.insert_rewards() RETURNS void
    LANGUAGE plpgsql
    AS $$ declare     txn RECORD; begin     for txn in         select *         from transactions where type = 'rewards_v1'         order by block asc     loop         insert into rewards (block, transaction_hash, time, account, gateway, amount)         select txn.block, txn.hash, txn.time, account, coalesce(gateway, '1Wh4bh') as gateway, sum(amount)::bigint as amount         from jsonb_populate_recordset(null::reward_entry, txn.fields->'rewards')         group by (account, gateway);     end loop; end; $$;


--
-- Name: last_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$         SELECT $2; $_$;


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
    city_id text
);


--
-- Name: location_city_id(public.locations); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_city_id(l public.locations) RETURNS text
    LANGUAGE plpgsql
    AS $$ begin     return lower(coalesce(l.long_city, '') || coalesce(l.long_state, '') || coalesce(l.long_country, '')); end; $$;


--
-- Name: location_city_id_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_city_id_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ begin     NEW.city_id := location_city_id(NEW);     return NEW; end; $$;


--
-- Name: location_city_words(public.locations); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_city_words(l public.locations) RETURNS text
    LANGUAGE plpgsql
    AS $$ begin     return (select string_agg(distinct word, ' ')             from regexp_split_to_table(                     lower(                         coalesce(l.long_city, '') || ' ' || coalesce(l.short_city, '') || ' ' ||                         coalesce(l.long_state, '') || ' ' || coalesce(l.short_state, '') || ' ' ||                         coalesce(l.long_country, '') || ' ' || coalesce(l.short_country, '') || ' '                     ) , '\s'                  ) as word where length(word) >= 3); end; $$;


--
-- Name: location_search_city_update(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.location_search_city_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ begin     NEW.search_city := location_city_words(NEW);     return NEW; end; $$;


--
-- Name: state_channel_counts(public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.state_channel_counts(type public.transaction_type, fields jsonb, OUT num_packets numeric, OUT num_dcs numeric) RETURNS record
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'state_channel_close_v1' then             select into num_packets, num_dcs sum(x.num_packets), sum(x.num_dcs)             from jsonb_to_recordset(fields#>'{state_channel, summaries}') as x(owner TEXT, client TEXT, num_dcs BIGINT, location TEXT, num_packets BIGINT);         else             num_packets := 0;             num_dcs := 0;     end case; end;  $$;


--
-- Name: trigger_set_updated_at(); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.trigger_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN   NEW.updated_at = NOW();   RETURN NEW; END; $$;


--
-- Name: txn_filter_account_activity(text, public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.txn_filter_account_activity(acc text, type public.transaction_type, fields jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'rewards_v1' then             return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where account = acc));         when type = 'payment_v2' then             if fields#>'{payer}' = acc then                 return fields;             else                 return jsonb_set(fields, '{payees}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{payees}') as x(payee text, amount bigint) where payee = acc));             end if;         else             return fields;     end case; end; $$;


--
-- Name: txn_filter_actor_activity(text, public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.txn_filter_actor_activity(actor text, type public.transaction_type, fields jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'rewards_v1' then             return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where account = actor or gateway = actor));         when type = 'payment_v2' then             if fields->>'payer' = actor then                 return fields;             else                 return jsonb_set(fields, '{payments}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{payments}') as x(payee text, amount bigint) where payee = actor));             end if;         when type = 'consensus_group_v1' then            return fields - 'proof';         else             return fields;     end case; end; $$;


--
-- Name: txn_filter_gateway_activity(text, public.transaction_type, jsonb); Type: FUNCTION; Schema: public; Owner: etl
--

CREATE FUNCTION public.txn_filter_gateway_activity(gw text, type public.transaction_type, fields jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$ begin     case         when type = 'rewards_v1' then             return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where gateway = gw));         when type = 'consensus_group_v1' then            return fields - 'proof';         else             return fields;     end case; end; $$;


--
-- Name: last(anyelement); Type: AGGREGATE; Schema: public; Owner: etl
--

CREATE AGGREGATE public.last(anyelement) (
    SFUNC = public.last_agg,
    STYPE = anyelement
);


--
-- Name: __migrations; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.__migrations (
    id character varying(255) NOT NULL,
    datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


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
    last_block bigint
);


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
    nonce bigint DEFAULT 0 NOT NULL
);


--
-- Name: block_signatures; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.block_signatures (
    block bigint NOT NULL,
    signer text NOT NULL,
    signature text NOT NULL
);


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


--
-- Name: gateway_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.gateway_inventory (
    address text NOT NULL,
    owner text NOT NULL,
    location text,
    alpha double precision NOT NULL,
    beta double precision NOT NULL,
    delta integer NOT NULL,
    score double precision NOT NULL,
    last_poc_challenge bigint,
    last_poc_onion_key_hash text,
    witnesses jsonb NOT NULL,
    first_block bigint,
    last_block bigint,
    nonce bigint,
    name text,
    first_timestamp timestamp with time zone
);


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
    peer_timestamp timestamp with time zone
);


--
-- Name: gateways; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.gateways (
    block bigint NOT NULL,
    address text NOT NULL,
    owner text NOT NULL,
    location text,
    alpha double precision NOT NULL,
    beta double precision NOT NULL,
    delta integer NOT NULL,
    score double precision NOT NULL,
    last_poc_challenge bigint,
    last_poc_onion_key_hash text,
    witnesses jsonb NOT NULL,
    nonce bigint,
    name text,
    "time" bigint
);


--
-- Name: oracle_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.oracle_inventory (
    address text NOT NULL
);


--
-- Name: oracle_price_predictions; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.oracle_price_predictions (
    "time" bigint NOT NULL,
    price bigint NOT NULL
);


--
-- Name: oracle_prices; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.oracle_prices (
    block bigint NOT NULL,
    price bigint NOT NULL
);


--
-- Name: pending_transaction_actors; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.pending_transaction_actors (
    actor text NOT NULL,
    actor_role public.transaction_actor_role NOT NULL,
    transaction_hash text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


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


--
-- Name: stats_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.stats_inventory (
    name text NOT NULL,
    value bigint DEFAULT 0 NOT NULL
);


--
-- Name: transaction_actors; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.transaction_actors (
    actor text NOT NULL,
    actor_role public.transaction_actor_role NOT NULL,
    transaction_hash text NOT NULL,
    block bigint NOT NULL
);


--
-- Name: vars_inventory; Type: TABLE; Schema: public; Owner: etl
--

CREATE TABLE public.vars_inventory (
    name text NOT NULL,
    type public.var_type NOT NULL,
    value text NOT NULL
);


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
-- Name: rewards_block_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX rewards_block_idx ON public.rewards USING btree (block);


--
-- Name: rewards_gateway_idx; Type: INDEX; Schema: public; Owner: etl
--

CREATE INDEX rewards_gateway_idx ON public.rewards USING btree (gateway);


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
-- Name: accounts account_insert; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER account_insert AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE PROCEDURE public.account_inventory_update();


--
-- Name: gateways gateway_insert; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER gateway_insert AFTER INSERT ON public.gateways FOR EACH ROW EXECUTE PROCEDURE public.gateway_inventory_update();


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
-- Name: pending_transactions pending_transaction_set_updated_at; Type: TRIGGER; Schema: public; Owner: etl
--

CREATE TRIGGER pending_transaction_set_updated_at BEFORE UPDATE ON public.pending_transactions FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_updated_at();


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
-- PostgreSQL database dump complete
--

