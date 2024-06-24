CREATE TABLE atlas_driver_offer_bpp.merchant ();

ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN city text NOT NULL default 'Kochi';
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN country text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN created_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN description text ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN enabled boolean NOT NULL default true;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN from_time timestamp with time zone ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN geo_hash_precision_value integer NOT NULL default 9;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN destination_restriction text[] NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN origin_restriction text[] NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN gstin character varying (255) ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN head_count bigint ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN id character varying(36) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN info text ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN internal_api_key character varying (128) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN minimum_driver_rates_count integer NOT NULL default 5;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN mobile_country_code character varying (255) ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN mobile_number text ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN name character varying (255) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN registry_url character varying (255) NOT NULL default 'http://localhost:8020';
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN short_id character varying (255) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN state text NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN status character varying (255) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN subscriber_id character varying (255) NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN to_time timestamp with time zone ;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN unique_key_id character varying (255) NOT NULL default 'FIXME';
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN updated_at timestamp with time zone NOT NULL default CURRENT_TIMESTAMP;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN verified boolean NOT NULL;
ALTER TABLE atlas_driver_offer_bpp.merchant ADD PRIMARY KEY ( id);


------- SQL updates -------

ALTER TABLE atlas_driver_offer_bpp.merchant ADD COLUMN online_payment boolean NOT NULL default false;