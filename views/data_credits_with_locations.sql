-- adds locations + extracted lat/lng to data credit transactions
-- useful for using Metabase's "off the shelf" Grid Map visualization, which is hard with raw SQL
-- arguably could just create "locations_with_latlng" instead and join with that

create view data_credits_with_locations as (
	SELECT data_credits.time AS time, 
		data_credits.owner, data_credits.client, data_credits.location, 
		data_credits.dcs, data_credits.packets, 
		Locations.long_street, Locations.short_street, Locations.long_city, Locations.short_city, Locations.long_state, Locations.short_state, Locations.long_country, Locations.short_country, Locations.search_city, Locations.city_id, Locations.geometry,
	--   ST_AsGeoJSON(geometry)::json->'coordinates'->>1 as lat, ST_AsGeoJSON(geometry)::json->'coordinates'->>0 as long
		ST_Y(geometry)::double precision as lat, ST_X(geometry)::double precision as long
	FROM data_credits
	LEFT JOIN locations Locations ON data_credits.location = Locations.location
	WHERE locations.geometry IS NOT NULL
);
