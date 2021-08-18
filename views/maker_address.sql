drop view if exists maker_address;
create view maker_address as (
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
    '14fzfjFcHpDR1rTH8BNPvSi5dKBbgxaDnmsVPbCjuq9ENjpZbxh'::text AS address
);
