drop view if exists transactions_payment;
create view transactions_payment as
	select 
			block
			-- , hash
			-- , type
			, fields::json->>'fee' as fee
			, fields::json->>'hash' as hash
			, fields::json->>'type' as type
			, fields::json->>'nonce' as nonce
			, fields::json->>'payee' as payee
			, fields::json->>'payer' as payer
			, fields::json->>'amount' as amount::bigint
	from transactions 
	where type IN ('payment_v1', 'payment_v2');

