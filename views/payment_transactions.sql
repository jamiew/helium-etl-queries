drop view if exists payment_transactions;
create view payment_transactions as
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
			, fields::json->>'amount' as amount    
	from transactions 
	where type IN ('payment_v1', 'payment_v2');

