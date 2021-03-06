PGDMP         	                w            test-weather-station "   10.11 (Ubuntu 10.11-1.pgdg18.04+1) "   10.11 (Ubuntu 10.11-1.pgdg18.04+1) a    3           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            4           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            5           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            6           1262    33850    test-weather-station    DATABASE     �   CREATE DATABASE "test-weather-station" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'es_AR.UTF-8' LC_CTYPE = 'es_AR.UTF-8';
 &   DROP DATABASE "test-weather-station";
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            7           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    4            8           0    0    SCHEMA public    ACL     *   GRANT ALL ON SCHEMA public TO developper;
                  postgres    false    4                        3079    13081    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            9           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                        3079    41468    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                  false    4            :           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                       false    2            �            1255    40256    apikeytoupper()    FUNCTION     �   CREATE FUNCTION public.apikeytoupper() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	new.name_apikey := upper(new.name_apikey);
	RETURN NEW;
END; $$;
 &   DROP FUNCTION public.apikeytoupper();
       public       client    false    1    4            �            1255    40891    availableconsultscontrol()    FUNCTION       CREATE FUNCTION public.availableconsultscontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	amountcurrentplanqueries plan.amount_consults%TYPE;
	amountqueriesmade queryhistory.amount_consults%TYPE;
	availableconsults client.available_consults%TYPE;
BEGIN
	amountcurrentplanqueries := (SELECT plan.amount_consults FROM plan, client 
								 	WHERE client.id_client=new.id_client AND client.suscribed_to_plan=plan.description);
	-- raise notice 'amountcurrentplanqueries: %', amountcurrentplanqueries;
	amountqueriesmade := new.amount_consults;
	-- raise notice 'amountqueriesmade: %', amountqueriesmade;
	
	availableconsults := (SELECT client.available_consults FROM client WHERE client.id_client=new.id_client);
	-- raise notice 'availableconsults: %', availableconsults;
	
	if (availableconsults = 0) then
		raise exception 'Ha llegado a su limite de consultas.';
	else
		UPDATE client SET available_consults = amountcurrentplanqueries-amountqueriesmade
			WHERE client.id_client=new.id_client;
	end if;
	RETURN NEW;
END; $$;
 1   DROP FUNCTION public.availableconsultscontrol();
       public    
   developper    false    4    1            �            1255    39327    finalusertoupper()    FUNCTION     �   CREATE FUNCTION public.finalusertoupper() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	new.email := lower(new.email);
	new.first_name := upper(new.first_name);
	new.last_name := upper(new.last_name);
	RETURN NEW;
END; $$;
 )   DROP FUNCTION public.finalusertoupper();
       public    
   developper    false    4    1            �            1255    40253    generatedefaultapikey()    FUNCTION     �   CREATE FUNCTION public.generatedefaultapikey() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN	
	INSERT INTO apikey(id_client) VALUES(NEW.id_client);
	RETURN NEW;
END; $$;
 .   DROP FUNCTION public.generatedefaultapikey();
       public       postgres    false    1    4            �            1255    40259    generatequeryhistory()    FUNCTION     �   CREATE FUNCTION public.generatequeryhistory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN	
	INSERT INTO queryhistory(id_client) VALUES(NEW.id_client);
	RETURN NEW;
END; $$;
 -   DROP FUNCTION public.generatequeryhistory();
       public       postgres    false    1    4                       1255    41657 I   getstationdatabetweendates(character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.getstationdatabetweendates(startdate character varying, enddate character varying, amount integer DEFAULT 10) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND station.created_at 
						BETWEEN TO_TIMESTAMP(startdate, 'YYYY-MM-DD HH24:MI:SS') 
							AND  TO_TIMESTAMP(enddate, 'YYYY-MM-DD HH24:MI:SS') 
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones creadas en el intervalo de fechas [%; %].', startdate, enddate;
	end if;
	
	RETURN;
END; $$;
 y   DROP FUNCTION public.getstationdatabetweendates(startdate character varying, enddate character varying, amount integer);
       public    
   developper    false    4    1                       1255    41659 0   getstationdatabycity(character varying, integer)    FUNCTION       CREATE FUNCTION public.getstationdatabycity(cityname character varying, amount integer DEFAULT 10) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.city=cityname
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas en la ciudad "%".', cityname;
	end if;
	
	RETURN;
END; $$;
 W   DROP FUNCTION public.getstationdatabycity(cityname character varying, amount integer);
       public    
   developper    false    4    1                       1255    41662 ?   getstationdatabygeolocation(double precision, double precision)    FUNCTION       CREATE FUNCTION public.getstationdatabygeolocation(lat double precision, lon double precision) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.latitude=lat
					AND location.longitude=lon)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos ninguna estacion ubicada en las coordenadas latitude: "%" ; longitude:"%".', lat, lon;
	end if;
	
	RETURN;
END; $$;
 ^   DROP FUNCTION public.getstationdatabygeolocation(lat double precision, lon double precision);
       public    
   developper    false    4    1                       1255    41658 %   getstationdatabyid(character varying)    FUNCTION     �  CREATE FUNCTION public.getstationdatabyid(idstation character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_station=idstation 
					AND station.id_location=location.id_location)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones con el id: % especificado.', idstation;
	end if;
	
	RETURN;
END; $$;
 F   DROP FUNCTION public.getstationdatabyid(idstation character varying);
       public    
   developper    false    4    1                       1255    41661 D   getstationdatabyplace(character varying, character varying, integer)    FUNCTION     g  CREATE FUNCTION public.getstationdatabyplace(regionname character varying, cityname character varying, amount integer DEFAULT 10) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.region=regionname
					AND location.city=cityname
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas en la region "%" y ciudad "%".', regionname, cityname;
	end if;
	
	RETURN;
END; $$;
 v   DROP FUNCTION public.getstationdatabyplace(regionname character varying, cityname character varying, amount integer);
       public    
   developper    false    4    1                       1255    41660 2   getstationdatabyregion(character varying, integer)    FUNCTION       CREATE FUNCTION public.getstationdatabyregion(regionname character varying, amount integer DEFAULT 10) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.region=reg
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas en la region "%".', reg;
	end if;
	
	RETURN;
END; $$;
 [   DROP FUNCTION public.getstationdatabyregion(regionname character varying, amount integer);
       public    
   developper    false    4    1                       1255    41663 3   getstationdatabyzipcode(character varying, integer)    FUNCTION       CREATE FUNCTION public.getstationdatabyzipcode(zipcode character varying, amount integer DEFAULT 10) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE
	stationdata record%TYPE;
BEGIN
	for stationdata in (SELECT station.id_station, station.name_station, 
						station.fail, station.created_at, location.latitude, 
						location.longitude, location.country, location.region, 
						location.city, location.zip_code
 			FROM station, location
				WHERE station.id_location=location.id_location 
					AND location.zip_code=zipcode
						ORDER BY station.created_at ASC
						LIMIT amount)
	loop
		return next stationdata;
	end loop;
	
	if (stationdata is null) then
		raise exception 'No poseemos estaciones ubicadas la region con el zipcode "%".', zipcode;
	end if;
	
	RETURN;
END; $$;
 Y   DROP FUNCTION public.getstationdatabyzipcode(zipcode character varying, amount integer);
       public    
   developper    false    4    1            �            1259    41536    measurement    TABLE     #  CREATE TABLE public.measurement (
    id_measurement character varying DEFAULT replace("substring"((public.gen_random_uuid())::text, 0, 15), '-'::text, ''::text) NOT NULL,
    date_measurement timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP,
    temperature double precision,
    humidity double precision,
    pressure double precision,
    uv_radiation double precision,
    wind_vel double precision,
    wind_dir double precision,
    rain_mm double precision,
    rain_intensity integer,
    id_station character varying NOT NULL
);
    DROP TABLE public.measurement;
       public      
   developper    false    2    4    4            ;           0    0    TABLE measurement    ACL        GRANT SELECT ON TABLE public.measurement TO finaluser;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.measurement TO admin;
            public    
   developper    false    199            �            1255    41652 d   getweatherdatabetweendates(double precision, double precision, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.getweatherdatabetweendates(lat double precision, lon double precision, startdate character varying, enddate character varying) RETURNS SETOF public.measurement
    LANGUAGE plpgsql
    AS $$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location WHERE location.latitude=lat AND location.longitude=lon);
	-- raise notice 'idlocationreq: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la latitude: % y longitude: %', lat, lon;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					  	WHERE measurement.id_station=stationlocated 
					  	AND measurement.date_measurement 
					  	BETWEEN TO_TIMESTAMP(startdate, 'YYYY-MM-DD HH24:MI:SS') 
					  	AND  TO_TIMESTAMP(enddate, 'YYYY-MM-DD HH24:MI:SS'))
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $$;
 �   DROP FUNCTION public.getweatherdatabetweendates(lat double precision, lon double precision, startdate character varying, enddate character varying);
       public    
   developper    false    4    1    199                       1255    41655 ?   getweatherdatabygeolocation(double precision, double precision)    FUNCTION     �  CREATE FUNCTION public.getweatherdatabygeolocation(lat double precision, lon double precision) RETURNS SETOF public.measurement
    LANGUAGE plpgsql
    AS $$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location 
					  	WHERE location.latitude=lat AND location.longitude=lon);
	-- raise notice 'idlocationreq: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la latitude: % y longitude: %', lat, lon;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					WHERE measurement.id_station=stationlocated 
					ORDER BY measurement.date_measurement 
					DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $$;
 ^   DROP FUNCTION public.getweatherdatabygeolocation(lat double precision, lon double precision);
       public    
   developper    false    1    199    4                       1255    41654 ;   getweatherdatabyplace(character varying, character varying)    FUNCTION     2  CREATE FUNCTION public.getweatherdatabyplace(regionname character varying, cityname character varying) RETURNS SETOF public.measurement
    LANGUAGE plpgsql
    AS $$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location 
					  	WHERE location.region=regionname AND location.city=cityname
					  	ORDER BY location.id_location ASC LIMIT 1);
	-- raise notice 'idlocation: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la region "%" y ciudad "%".', regionname, cityname;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					WHERE measurement.id_station=stationlocated 
					ORDER BY measurement.date_measurement 
					DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $$;
 f   DROP FUNCTION public.getweatherdatabyplace(regionname character varying, cityname character varying);
       public    
   developper    false    199    1    4            �            1255    41653 ,   getweatherdatabystationid(character varying)    FUNCTION     �  CREATE FUNCTION public.getweatherdatabystationid(idstation character varying) RETURNS SETOF public.measurement
    LANGUAGE plpgsql
    AS $$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
BEGIN
	stationlocated := (SELECT station.id_location FROM station WHERE station.id_station=idstation);
	-- raise notice 'stationlocated: %', stationlocated;
	if (stationlocated is null) then
		raise exception 'No poseemos datos de mediciones para este id: % de estacion', idstation;
	else
		for weatherdata in (SELECT * FROM measurement 
						WHERE measurement.id_station=idstation 
						ORDER BY measurement.date_measurement 
						DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
					
	RETURN;
END; $$;
 M   DROP FUNCTION public.getweatherdatabystationid(idstation character varying);
       public    
   developper    false    4    1    199                       1255    41656 *   getweatherdatabyzipcode(character varying)    FUNCTION     �  CREATE FUNCTION public.getweatherdatabyzipcode(zipcode character varying) RETURNS SETOF public.measurement
    LANGUAGE plpgsql
    AS $$
DECLARE
	weatherdata measurement%ROWTYPE;
	stationlocated station.id_station%TYPE;
	idlocationreq location.id_location%TYPE;
BEGIN
	idlocationreq := (SELECT location.id_location FROM location 
					  	WHERE location.zip_code=zipcode
					  	ORDER BY location.id_location ASC LIMIT 1);
	-- raise notice 'idlocationreq: %', idlocationreq;
	
	if (idlocationreq is null) then
		raise exception 'No poseemos datos de mediciones en la ciudad con el zipcode: %.', zipcode;
	else
		stationlocated := (SELECT station.id_station FROM station WHERE station.id_location=idlocationreq);
		-- raise notice 'stationlocated: %', stationlocated;
		
		for weatherdata in (SELECT * FROM measurement 
					WHERE measurement.id_station=stationlocated 
					ORDER BY measurement.date_measurement 
					DESC LIMIT 1)
		loop
			return next weatherdata;
		end loop;
	end if;
	
	RETURN;
END; $$;
 I   DROP FUNCTION public.getweatherdatabyzipcode(zipcode character varying);
       public    
   developper    false    199    4    1            �            1255    40554    locationtoupper()    FUNCTION     �   CREATE FUNCTION public.locationtoupper() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	new.country := upper(new.country);
	new.region := upper(new.region);
	new.city := upper(new.city);
	RETURN NEW;
END; $$;
 (   DROP FUNCTION public.locationtoupper();
       public    
   developper    false    1    4            �            1255    41166    plantoupper()    FUNCTION     �   CREATE FUNCTION public.plantoupper() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	new.description := upper(new.description);
	RETURN NEW;
END; $$;
 $   DROP FUNCTION public.plantoupper();
       public    
   developper    false    1    4            �            1255    41649 �   registerlocation(double precision, double precision, character varying, character varying, character varying, character varying)    FUNCTION     L  CREATE FUNCTION public.registerlocation(lat double precision, lon double precision, ctry character varying, reg character varying, citnm character varying, zipc character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	idlocation varchar;
BEGIN
	INSERT INTO location(latitude, longitude, country, region, city, zip_code) 
		VALUES(lat, lon, ctry, reg, citnm, zipc);
	idlocation := (SELECT location.id_location FROM location WHERE location.latitude=lat AND location.longitude=lon);
	
	-- RAISE NOTICE 'idlocation: %', idlocation;
		
	RETURN idlocation;
END; $$;
 �   DROP FUNCTION public.registerlocation(lat double precision, lon double precision, ctry character varying, reg character varying, citnm character varying, zipc character varying);
       public    
   developper    false    4    1            �            1255    41651 �   registermeasurement(double precision, double precision, double precision, double precision, double precision, double precision, double precision, integer, character varying)    FUNCTION     Q  CREATE FUNCTION public.registermeasurement(temp double precision, hum double precision, pres double precision, uvrad double precision, windvel double precision, winddir double precision, rainmm double precision, rainintensity integer, namestation character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	idstation station.id_station%TYPE;
BEGIN
	idstation := (SELECT station.id_station FROM station WHERE station.name_station=namestation);
	RAISE NOTICE 'idstation: %', idstation;
	
	if (idstation is not null) then
		INSERT INTO measurement(temperature, humidity, pressure, uv_radiation, wind_vel, wind_dir, rain_mm, rain_intensity, id_station)
			VALUES(temp, hum, pres, uvrad, windvel, winddir, rainmm, rainintensity, idstation);
	else
		raise exception 'Revise que la estacion "%" exista', namestaion;
	end if;

	RETURN;
END; $$;
 	  DROP FUNCTION public.registermeasurement(temp double precision, hum double precision, pres double precision, uvrad double precision, windvel double precision, winddir double precision, rainmm double precision, rainintensity integer, namestation character varying);
       public    
   developper    false    4    1            �            1255    41650 �   registerstation(character varying, double precision, double precision, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.registerstation(namestation character varying, latitude double precision, longitude double precision, country character varying, region character varying, cityname character varying, zipcode character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	idlocation varchar;
	idstation varchar;
BEGIN
	idlocation := (SELECT registerLocation(latitude, longitude, country, region, cityname, zipcode));
	
	INSERT INTO station(name_station, id_location)
		VALUES(namestation, idlocation);
 
	idstation := (SELECT station.id_station FROM station WHERE station.name_station=namestation);
	RAISE NOTICE 'idstation: %', idstation;
				   
	RETURN idstation;
END; $$;
 �   DROP FUNCTION public.registerstation(namestation character varying, latitude double precision, longitude double precision, country character varying, region character varying, cityname character varying, zipcode character varying);
       public    
   developper    false    1    4                       1255    41665 %   saveinqueryhistory(character varying)    FUNCTION       CREATE FUNCTION public.saveinqueryhistory(idcurrentclient character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	lastqueryhistory queryhistory%ROWTYPE;
	datelastquery date;
	currentdate date;
BEGIN
	lastqueryhistory := (SELECT queryhistory
		FROM queryhistory WHERE queryhistory.id_client=idcurrentclient);
	-- raise notice 'lastqueryhistory: %', lastqueryhistory; 
	
	if (lastqueryhistory is null) then
		raise exception 'Corrobore que el idcurrentclient: "%" sea el correcto.', idcurrentclient;
	end if;
	
	datelastquery := lastqueryhistory.date_query::date;
	-- raise notice 'datelastquery: %', datelastquery;
	
	currentdate := (SELECT current_timestamp::date);
	-- raise notice 'currentdate: %', currentdate;

	if (datelastquery = currentdate) then
		UPDATE queryhistory SET amount_consults=amount_consults+1
			WHERE queryhistory.id_qh=lastqueryhistory.id_qh;
	end if;
	
	if (datelastquery != currentdate) then
		INSERT INTO queryhistory(amount_consults, id_client) VALUES(1, idcurrentclient);
	end if;
	RETURN;
END; $$;
 L   DROP FUNCTION public.saveinqueryhistory(idcurrentclient character varying);
       public    
   developper    false    1    4            �            1255    40251    signupasadmin()    FUNCTION     -  CREATE FUNCTION public.signupasadmin() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	currentuser varchar;
BEGIN
	currentuser := (SELECT current_user);
	if (currentuser = 'developper') then
		INSERT INTO administrator(id_finaluser)
			VALUES(NEW.id_finaluser);
	end if;
	RETURN NEW;
END; $$;
 &   DROP FUNCTION public.signupasadmin();
       public       admin    false    1    4            �            1255    40114    signupasclient()    FUNCTION     �  CREATE FUNCTION public.signupasclient() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	planbasic plan% ROWTYPE;
	currentuser varchar;
BEGIN
	currentuser := (SELECT current_user);
	if (currentuser = 'client') then
		planbasic := (SELECT plan FROM plan WHERE plan.description='BASIC');

		INSERT INTO client(available_consults, suscribed_to_plan, id_finaluser)
			VALUES(planbasic.amount_consults, planbasic.description, NEW.id_finaluser);
	end if;
	RETURN NEW;
END; $$;
 '   DROP FUNCTION public.signupasclient();
       public    
   developper    false    4    1            �            1255    40396    stationstatuscontrol()    FUNCTION     y  CREATE FUNCTION public.stationstatuscontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	fail bool;
BEGIN
	fail := (SELECT station.fail FROM station WHERE station.id_station = NEW.id_station);
	
	if ((new.temperature is null) or (new.humidity is null) or (new.pressure is null)
			or (new.uv_radiation is null) or (new.wind_vel is null) or (new.wind_dir is null)
			or (new.rain_mm is null) or (new.rain_intensity is null)) then
		UPDATE station SET fail=true WHERE station.id_station = new.id_station;
	else
		UPDATE station SET fail=false WHERE station.id_station = NEW.id_station;
	end if;
    
	RETURN NEW;
END; $$;
 -   DROP FUNCTION public.stationstatuscontrol();
       public    
   developper    false    4    1            �            1255    40556    stationtoupper()    FUNCTION     �   CREATE FUNCTION public.stationtoupper() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	new.name_station := upper(new.name_station);
	RETURN NEW;
END; $$;
 '   DROP FUNCTION public.stationtoupper();
       public    
   developper    false    4    1                       1255    41664 1   upgradeplan(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.upgradeplan(emailadress character varying, plantosuscribe character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	planselected plan%ROWTYPE;
	iduser finaluser.id_finaluser%TYPE;
	currentplan varchar;
BEGIN	
	emailadress := lower(emailadress);
	plantosuscribe := upper(plantosuscribe);
	planselected := (SELECT plan FROM plan WHERE plan.description=plantosuscribe);
	if (planselected is null) then
		raise exception 'El plan "%" no esta disponible.', plantosuscribe;
	end if;
	
	iduser := (SELECT finaluser.id_finaluser FROM finaluser WHERE finaluser.email=emailadress);
	if (iduser is null) then
		raise exception 'Corrobore que el email "%" sea correcto.', emailadress;
	end if;
	
	currentplan := (SELECT client.suscribed_to_plan FROM client WHERE client.id_finaluser=iduser);
	if(currentplan=plantosuscribe) then
		raise exception 'Usted ya posee el plan "%".', plantosuscribe;
	end if;
	
	if (planselected is not null AND iduser is not null) then
		UPDATE client SET 
			suscribed_to_plan=planselected.description,
			available_consults=planselected.amount_consults
				WHERE client.id_finaluser=iduser;
	end if;

	RETURN;
END; $$;
 c   DROP FUNCTION public.upgradeplan(emailadress character varying, plantosuscribe character varying);
       public    
   developper    false    4    1            �            1259    41573    administrator    TABLE     �   CREATE TABLE public.administrator (
    id_administrator character varying DEFAULT replace("substring"((public.gen_random_uuid())::text, 0, 15), '-'::text, ''::text) NOT NULL,
    id_finaluser character varying NOT NULL
);
 !   DROP TABLE public.administrator;
       public      
   developper    false    2    4    4            <           0    0    TABLE administrator    ACL     5   GRANT SELECT ON TABLE public.administrator TO admin;
            public    
   developper    false    202            �            1259    41606    apikey    TABLE     �   CREATE TABLE public.apikey (
    id_apikey character varying DEFAULT public.gen_random_uuid() NOT NULL,
    name_apikey character varying DEFAULT 'DEFAULT'::character varying,
    id_client character varying NOT NULL
);
    DROP TABLE public.apikey;
       public      
   developper    false    2    4    4            =           0    0    TABLE apikey    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.apikey TO admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.apikey TO client;
            public    
   developper    false    204            �            1259    41587    client    TABLE     -  CREATE TABLE public.client (
    id_client character varying DEFAULT replace("substring"((public.gen_random_uuid())::text, 0, 15), '-'::text, ''::text) NOT NULL,
    available_consults smallint NOT NULL,
    suscribed_to_plan character varying NOT NULL,
    id_finaluser character varying NOT NULL
);
    DROP TABLE public.client;
       public      
   developper    false    2    4    4            >           0    0    TABLE client    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.client TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.client TO client;
            public    
   developper    false    203            �            1259    41560 	   finaluser    TABLE     �  CREATE TABLE public.finaluser (
    id_finaluser character varying DEFAULT replace("substring"((public.gen_random_uuid())::text, 0, 15), '-'::text, ''::text) NOT NULL,
    email character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    profile_picture character varying,
    birthdate date NOT NULL,
    CONSTRAINT finaluser_birthdate_check CHECK (((date_part('year'::text, age((birthdate)::timestamp with time zone)) >= (18)::double precision) AND (date_part('year'::text, age((birthdate)::timestamp with time zone)) <= (122)::double precision))),
    CONSTRAINT finaluser_email_check CHECK (((email)::text ~~ '%@%.%'::text))
);
    DROP TABLE public.finaluser;
       public      
   developper    false    2    4    4            ?           0    0    TABLE finaluser    ACL     �   GRANT SELECT,DELETE,UPDATE ON TABLE public.finaluser TO finaluser;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.finaluser TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.finaluser TO client;
            public    
   developper    false    201            �            1259    41505    location    TABLE     �  CREATE TABLE public.location (
    id_location character varying DEFAULT replace("substring"((public.gen_random_uuid())::text, 0, 15), '-'::text, ''::text) NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    country character varying NOT NULL,
    region character varying NOT NULL,
    city character varying NOT NULL,
    zip_code character varying(4) NOT NULL
);
    DROP TABLE public.location;
       public      
   developper    false    2    4    4            @           0    0    TABLE location    ACL     y   GRANT SELECT ON TABLE public.location TO finaluser;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.location TO admin;
            public    
   developper    false    197            �            1259    41551    plan    TABLE     �   CREATE TABLE public.plan (
    description character varying DEFAULT 'BASIC'::character varying NOT NULL,
    price double precision NOT NULL,
    amount_consults integer NOT NULL
);
    DROP TABLE public.plan;
       public      
   developper    false    4            A           0    0 
   TABLE plan    ACL     n   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.plan TO admin;
GRANT SELECT ON TABLE public.plan TO client;
            public    
   developper    false    200            �            1259    41621    queryhistory    TABLE     @  CREATE TABLE public.queryhistory (
    id_qh character varying DEFAULT replace("substring"((public.gen_random_uuid())::text, 0, 15), '-'::text, ''::text) NOT NULL,
    amount_consults integer DEFAULT 0,
    date_query timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP,
    id_client character varying NOT NULL
);
     DROP TABLE public.queryhistory;
       public      
   developper    false    2    4    4            B           0    0    TABLE queryhistory    ACL     �   GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.queryhistory TO admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.queryhistory TO client;
            public    
   developper    false    205            �            1259    41518    station    TABLE     h  CREATE TABLE public.station (
    id_station character varying DEFAULT replace("substring"((public.gen_random_uuid())::text, 0, 15), '-'::text, ''::text) NOT NULL,
    name_station character varying NOT NULL,
    fail boolean DEFAULT false,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP,
    id_location character varying NOT NULL
);
    DROP TABLE public.station;
       public      
   developper    false    2    4    4            C           0    0    TABLE station    ACL     w   GRANT SELECT ON TABLE public.station TO finaluser;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.station TO admin;
            public    
   developper    false    198            -          0    41573    administrator 
   TABLE DATA               G   COPY public.administrator (id_administrator, id_finaluser) FROM stdin;
    public    
   developper    false    202   I�       /          0    41606    apikey 
   TABLE DATA               C   COPY public.apikey (id_apikey, name_apikey, id_client) FROM stdin;
    public    
   developper    false    204   ��       .          0    41587    client 
   TABLE DATA               `   COPY public.client (id_client, available_consults, suscribed_to_plan, id_finaluser) FROM stdin;
    public    
   developper    false    203   �       ,          0    41560 	   finaluser 
   TABLE DATA               k   COPY public.finaluser (id_finaluser, email, first_name, last_name, profile_picture, birthdate) FROM stdin;
    public    
   developper    false    201   ׿       (          0    41505    location 
   TABLE DATA               e   COPY public.location (id_location, latitude, longitude, country, region, city, zip_code) FROM stdin;
    public    
   developper    false    197   ��       *          0    41536    measurement 
   TABLE DATA               �   COPY public.measurement (id_measurement, date_measurement, temperature, humidity, pressure, uv_radiation, wind_vel, wind_dir, rain_mm, rain_intensity, id_station) FROM stdin;
    public    
   developper    false    199   ��       +          0    41551    plan 
   TABLE DATA               C   COPY public.plan (description, price, amount_consults) FROM stdin;
    public    
   developper    false    200   ^�       0          0    41621    queryhistory 
   TABLE DATA               U   COPY public.queryhistory (id_qh, amount_consults, date_query, id_client) FROM stdin;
    public    
   developper    false    205   ��       )          0    41518    station 
   TABLE DATA               Z   COPY public.station (id_station, name_station, fail, created_at, id_location) FROM stdin;
    public    
   developper    false    198   ��       �           2606    41572    finaluser finaluser_email_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.finaluser
    ADD CONSTRAINT finaluser_email_key UNIQUE (email);
 G   ALTER TABLE ONLY public.finaluser DROP CONSTRAINT finaluser_email_key;
       public      
   developper    false    201            �           2606    41515    location location_latitude_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_latitude_key UNIQUE (latitude);
 H   ALTER TABLE ONLY public.location DROP CONSTRAINT location_latitude_key;
       public      
   developper    false    197            �           2606    41517    location location_longitude_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_longitude_key UNIQUE (longitude);
 I   ALTER TABLE ONLY public.location DROP CONSTRAINT location_longitude_key;
       public      
   developper    false    197            �           2606    41581    administrator pk_administrator 
   CONSTRAINT     j   ALTER TABLE ONLY public.administrator
    ADD CONSTRAINT pk_administrator PRIMARY KEY (id_administrator);
 H   ALTER TABLE ONLY public.administrator DROP CONSTRAINT pk_administrator;
       public      
   developper    false    202            �           2606    41615    apikey pk_apikey 
   CONSTRAINT     U   ALTER TABLE ONLY public.apikey
    ADD CONSTRAINT pk_apikey PRIMARY KEY (id_apikey);
 :   ALTER TABLE ONLY public.apikey DROP CONSTRAINT pk_apikey;
       public      
   developper    false    204            �           2606    41595    client pk_client 
   CONSTRAINT     U   ALTER TABLE ONLY public.client
    ADD CONSTRAINT pk_client PRIMARY KEY (id_client);
 :   ALTER TABLE ONLY public.client DROP CONSTRAINT pk_client;
       public      
   developper    false    203            �           2606    41513    location pk_location 
   CONSTRAINT     [   ALTER TABLE ONLY public.location
    ADD CONSTRAINT pk_location PRIMARY KEY (id_location);
 >   ALTER TABLE ONLY public.location DROP CONSTRAINT pk_location;
       public      
   developper    false    197            �           2606    41545    measurement pk_measurement 
   CONSTRAINT     d   ALTER TABLE ONLY public.measurement
    ADD CONSTRAINT pk_measurement PRIMARY KEY (id_measurement);
 D   ALTER TABLE ONLY public.measurement DROP CONSTRAINT pk_measurement;
       public      
   developper    false    199            �           2606    41559    plan pk_plan 
   CONSTRAINT     S   ALTER TABLE ONLY public.plan
    ADD CONSTRAINT pk_plan PRIMARY KEY (description);
 6   ALTER TABLE ONLY public.plan DROP CONSTRAINT pk_plan;
       public      
   developper    false    200            �           2606    41631    queryhistory pk_queryhistory 
   CONSTRAINT     ]   ALTER TABLE ONLY public.queryhistory
    ADD CONSTRAINT pk_queryhistory PRIMARY KEY (id_qh);
 F   ALTER TABLE ONLY public.queryhistory DROP CONSTRAINT pk_queryhistory;
       public      
   developper    false    205            �           2606    41528    station pk_station 
   CONSTRAINT     X   ALTER TABLE ONLY public.station
    ADD CONSTRAINT pk_station PRIMARY KEY (id_station);
 <   ALTER TABLE ONLY public.station DROP CONSTRAINT pk_station;
       public      
   developper    false    198            �           2606    41570    finaluser pk_user 
   CONSTRAINT     Y   ALTER TABLE ONLY public.finaluser
    ADD CONSTRAINT pk_user PRIMARY KEY (id_finaluser);
 ;   ALTER TABLE ONLY public.finaluser DROP CONSTRAINT pk_user;
       public      
   developper    false    201            �           2606    41530     station station_name_station_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.station
    ADD CONSTRAINT station_name_station_key UNIQUE (name_station);
 J   ALTER TABLE ONLY public.station DROP CONSTRAINT station_name_station_key;
       public      
   developper    false    198            �           2620    41646    apikey apikeytoupper    TRIGGER     }   CREATE TRIGGER apikeytoupper BEFORE INSERT OR UPDATE ON public.apikey FOR EACH ROW EXECUTE PROCEDURE public.apikeytoupper();
 -   DROP TRIGGER apikeytoupper ON public.apikey;
       public    
   developper    false    233    204            �           2620    41645 %   queryhistory availableconsultscontrol    TRIGGER     �   CREATE TRIGGER availableconsultscontrol AFTER UPDATE ON public.queryhistory FOR EACH ROW EXECUTE PROCEDURE public.availableconsultscontrol();
 >   DROP TRIGGER availableconsultscontrol ON public.queryhistory;
       public    
   developper    false    232    205            �           2620    41642    finaluser finalusertoupper    TRIGGER     �   CREATE TRIGGER finalusertoupper BEFORE INSERT OR UPDATE ON public.finaluser FOR EACH ROW EXECUTE PROCEDURE public.finalusertoupper();
 3   DROP TRIGGER finalusertoupper ON public.finaluser;
       public    
   developper    false    218    201            �           2620    41647    client generatedefaultapikey    TRIGGER     �   CREATE TRIGGER generatedefaultapikey AFTER INSERT ON public.client FOR EACH ROW EXECUTE PROCEDURE public.generatedefaultapikey();
 5   DROP TRIGGER generatedefaultapikey ON public.client;
       public    
   developper    false    222    203            �           2620    41648    client generatequeryhistory    TRIGGER     �   CREATE TRIGGER generatequeryhistory AFTER INSERT ON public.client FOR EACH ROW EXECUTE PROCEDURE public.generatequeryhistory();
 4   DROP TRIGGER generatequeryhistory ON public.client;
       public    
   developper    false    203    223            �           2620    41638    location locationtoupper    TRIGGER     �   CREATE TRIGGER locationtoupper BEFORE INSERT OR UPDATE ON public.location FOR EACH ROW EXECUTE PROCEDURE public.locationtoupper();
 1   DROP TRIGGER locationtoupper ON public.location;
       public    
   developper    false    197    229            �           2620    41641    plan plantoupper    TRIGGER     w   CREATE TRIGGER plantoupper BEFORE INSERT OR UPDATE ON public.plan FOR EACH ROW EXECUTE PROCEDURE public.plantoupper();
 )   DROP TRIGGER plantoupper ON public.plan;
       public    
   developper    false    200    231            �           2620    41643    finaluser signupasadmin    TRIGGER     u   CREATE TRIGGER signupasadmin AFTER INSERT ON public.finaluser FOR EACH ROW EXECUTE PROCEDURE public.signupasadmin();
 0   DROP TRIGGER signupasadmin ON public.finaluser;
       public    
   developper    false    219    201            �           2620    41644    finaluser signupasclient    TRIGGER     w   CREATE TRIGGER signupasclient AFTER INSERT ON public.finaluser FOR EACH ROW EXECUTE PROCEDURE public.signupasclient();
 1   DROP TRIGGER signupasclient ON public.finaluser;
       public    
   developper    false    201    230            �           2620    41640     measurement stationstatuscontrol    TRIGGER     �   CREATE TRIGGER stationstatuscontrol BEFORE INSERT OR UPDATE ON public.measurement FOR EACH ROW EXECUTE PROCEDURE public.stationstatuscontrol();
 9   DROP TRIGGER stationstatuscontrol ON public.measurement;
       public    
   developper    false    199    221            �           2620    41639    station stationtoupper    TRIGGER     �   CREATE TRIGGER stationtoupper BEFORE INSERT OR UPDATE ON public.station FOR EACH ROW EXECUTE PROCEDURE public.stationtoupper();
 /   DROP TRIGGER stationtoupper ON public.station;
       public    
   developper    false    220    198            �           2606    41616    apikey fk_client    FK CONSTRAINT     �   ALTER TABLE ONLY public.apikey
    ADD CONSTRAINT fk_client FOREIGN KEY (id_client) REFERENCES public.client(id_client) ON UPDATE CASCADE ON DELETE CASCADE;
 :   ALTER TABLE ONLY public.apikey DROP CONSTRAINT fk_client;
       public    
   developper    false    204    2968    203            �           2606    41632    queryhistory fk_client    FK CONSTRAINT     �   ALTER TABLE ONLY public.queryhistory
    ADD CONSTRAINT fk_client FOREIGN KEY (id_client) REFERENCES public.client(id_client) ON UPDATE CASCADE ON DELETE CASCADE;
 @   ALTER TABLE ONLY public.queryhistory DROP CONSTRAINT fk_client;
       public    
   developper    false    205    2968    203            �           2606    41601    client fk_finaluser    FK CONSTRAINT     �   ALTER TABLE ONLY public.client
    ADD CONSTRAINT fk_finaluser FOREIGN KEY (id_finaluser) REFERENCES public.finaluser(id_finaluser) ON UPDATE CASCADE ON DELETE CASCADE;
 =   ALTER TABLE ONLY public.client DROP CONSTRAINT fk_finaluser;
       public    
   developper    false    201    203    2964            �           2606    41531    station fk_location    FK CONSTRAINT     �   ALTER TABLE ONLY public.station
    ADD CONSTRAINT fk_location FOREIGN KEY (id_location) REFERENCES public.location(id_location) ON UPDATE CASCADE ON DELETE CASCADE;
 =   ALTER TABLE ONLY public.station DROP CONSTRAINT fk_location;
       public    
   developper    false    198    2952    197            �           2606    41596    client fk_plan    FK CONSTRAINT        ALTER TABLE ONLY public.client
    ADD CONSTRAINT fk_plan FOREIGN KEY (suscribed_to_plan) REFERENCES public.plan(description);
 8   ALTER TABLE ONLY public.client DROP CONSTRAINT fk_plan;
       public    
   developper    false    2960    200    203            �           2606    41546    measurement fk_station    FK CONSTRAINT     �   ALTER TABLE ONLY public.measurement
    ADD CONSTRAINT fk_station FOREIGN KEY (id_station) REFERENCES public.station(id_station) ON UPDATE CASCADE ON DELETE CASCADE;
 @   ALTER TABLE ONLY public.measurement DROP CONSTRAINT fk_station;
       public    
   developper    false    198    2954    199            �           2606    41582    administrator fk_user    FK CONSTRAINT     �   ALTER TABLE ONLY public.administrator
    ADD CONSTRAINT fk_user FOREIGN KEY (id_finaluser) REFERENCES public.finaluser(id_finaluser) ON UPDATE CASCADE ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.administrator DROP CONSTRAINT fk_user;
       public    
   developper    false    202    201    2964            -   K   x�ȱ�  �Z�Ɂ �.id��/���WǢ]����α�Bcp۪C�3�J�����T4$���> ��g#      /   N  x�E�;r^1Fkk/x�����]�L�4�`�K�����8�=��}t��� �8b����������ϟ7�騼��j�ך�r��rLQ����iC%_$�Ě����ڴ\��y- � �j�F���E2e�9��Tsá�D#��=�t
taUWŋt4rj&E�~8Q�}�a>�N����O��8=����k�H�]�U�(���QJ�i=	q�%���5��\���9q �0�������H�i�=���#t�me�9(�F���I�w	���+{��;m�%Ӡ춆�d��/��G�w�[��{n8�'����d�f#����~�PX}�ﭵ�����      .   �   x�M�1r1��1.$�оȱS' ��O�:��{�ff�0Q�֯���ϟ��k�A12&�C�)���F�O�c�C	�(�����\�(b��;��ύ�A�r,\%�"|#�$�L��-��k�j��ͬ���2˴�a��:8)�."�W�W�zX��2�y�WKѺ����:�"��-�X�(�|��� ���U�      ,     x�m�]��0���qH�G��:5mD�:v������hQ�e����2,�}����X͸��D�鮲��x�q��m����g�(ѳ��{�g��ԥ��,�$JQ����dgd��a�D�'e��e���;�3_E��I^Z3*s6Z��;�|��!��}��U�C�HC�'T)�G���i��L�F)O�flez3-��e���Eu���믑�7�^@��Rc;�ơ��^:X�iU�@e��YR�9Qp�����3ǡ�Z#���g3��tz�I�}��U�ۉr��,�s����%���sδ�2�ӷrj��R�x݈<�Q�f�!O\�9�E��d��5�^JZkF9/0�|���kQ���BÛQ���p�0�4X9t8�fce�@l��"Q�br�5ح&��uC�l8:~�	nr4���@\c+~=�0M���Ke$� �����`�	�m�. i�Vg1*EU�!����$r��C�e�QK���}2�W����"�<h+�Һ����O���_X��      (   �  x���M��0��p
.dW���N��Fb ㄑF�|�#tQ��$R�7����իWd�q��<^e;�R ����+��F�d>�W��n}�W��Pw���!t��*�(W�6#��b�1J�)�Y&�����9�е��x���x����{��dZ�8O���"���n��	UR�E�6Ղ>|����Rf0Jʁ�D��W��g/���[�Y���a�I0LIZ�M+�"&��T7�B���>��Ϳ�q� :ҦZ���ZS	_����}�v��ׁ�{k��9wő�	?�L��9�(����I�b���d��V�0��������_�Jl�e����Bkx�m`1�K���ޟ<���2�F��2sg��W�8;-�4�y�~���?�l�Rnu�yvli1��y&�����/(��mg�L��V�Hi���*ikof���U�`Q�qԷUZ\϶�J�{K�ܤ�e���:�      *   {  x��W˕$9<+�XZO��X梯�&,���*u�7���BA@ɬ��L�6!�G�� ���I�3$�Cԧ'�c��P�O�$����|����8����9^J.gE	��\�j�И�G�1�t��@}ڮ�щA��cv��2{zH]
�i��K|�ԑ�u�X�,���4+OFx�j�lH-W�[dt�^7R��t��L�	zظ�ĕ'�qhc*\=�1K1�3R򴑠��������VC6٧��G�eˈ�%�����JĢ3�\�^�]F�iG�$>m�2��^�؁VK��}�8��3�E+��j�z�lO���d��U�f��B�=T��X�VY�������v�"w��i�qk
J+�;R+��Z�i^z��"ZԊ|�T��zտ��2���lE4M��WQ�x�
B.EO�����P�A�1:�]�	Ոm�����z�5�f�U�y�t�iw
�1w�{I=m��8M�Tl�4Ϝ.�P*p�Ջ��}��lh���
&pY匛��e��ʆ��p�R�b��f�s"�yC�w��]��V�mﱋ��$g��L��ƛ�Σ5����ż�\mԀ�r�q|������/��\�rn��@��c��&Hh2�#@?#��1��n#<J��g���6{��ͤd��j,�Μ���Xf���1�&�͒���O�i�ȡ�D�,փy���+��9|+>���W�Wp��L�z���+��ְ���5p��� ܬዦﰆ���	��$:J�a�O�>�I"�^�G�ﳙ�R�E���}A}��d�TI�Zn��_H�f3�ܸ��e��m&v%7�*��^}��ľZ��%�|���l&)%�:B�y[�P�i3a)�9�Ag^�m3�yJ%��-���;m&��u]���ߩ      +   A   x�sr�t�4�45���q�uu�tq�4�460�
r����44�42417�0631����� m7�      0   �   x�u��q%0Ϗ(6�@ >��! ��	��5�=�^"m�c}�����?�?�ON
5\1�Y��͜/�i�f��uѵ���U/sE��+#F���O:���[.lɠL�8/�
���f���թ<�e��p`��o*��:����qY��G��Ed�l(�ڣE��p뱨H���9כ��|8��F�~�R�k
      )   {  x�}�Mn�0F��)|�"%��씉�p�S{\�@7�~��*p�.�J���H}�Dk���5�C?�e�nCW;� /�/{���;�%�\K��*N���Pc���η�p����~[�o[�}�r�8a������)�u��������_�o'Sr�j\��*��R���������#;���3Zv![3��2�ǰ��Pؚj�Cl��5s�>�k�r��0=���޲���ޡ5���Ze4L��b�!�5NSx��
-�hSv
��� ���cMю�� 	*�qo��ݙ��v�����׳� �Fa����=�FB��=,�v6O�����"4�3 �Qg�l�����l�rA��/�بU�DE�S��V=�$�&��!)���E)�Ѿ@     