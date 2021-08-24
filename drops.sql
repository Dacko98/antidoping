DROP TABLE address CASCADE CONSTRAINTS; -- adresa
DROP TABLE person CASCADE CONSTRAINTS; -- osoba
DROP TABLE athlete CASCADE CONSTRAINTS; -- sportovec
DROP TABLE laboratory_employee CASCADE CONSTRAINTS; -- laboratorni pracovnik
DROP TABLE doping_control_officer CASCADE CONSTRAINTS; -- (DCO) komisar
DROP TABLE doping_control CASCADE CONSTRAINTS; -- kontrola
DROP TABLE sport CASCADE CONSTRAINTS; -- sport
DROP TABLE therapeutic_use_exemption CASCADE CONSTRAINTS; -- (TUE) terapeuticka vyjimka
DROP TABLE substance CASCADE CONSTRAINTS; -- latka
DROP TABLE substance_ban CASCADE CONSTRAINTS; -- zakaz latky
DROP TABLE sample CASCADE CONSTRAINTS; -- vzorek
DROP TABLE substance_category CASCADE CONSTRAINTS; -- vzorek
DROP TABLE laboratory CASCADE CONSTRAINTS; -- laborator
DROP TABLE rel_athlete_sport CASCADE CONSTRAINTS; -- vztah sportovec sport
DROP TABLE rel_tue_substance CASCADE CONSTRAINTS; -- laborator
DROP TABLE rel_ban_sport CASCADE CONSTRAINTS; -- vztah zakaz latky sport
DROP TABLE rel_substance_sample CASCADE CONSTRAINTS; -- vztah latka vzorek
DROP TABLE rel_tue_sport CASCADE CONSTRAINTS; -- vztah vyjimka sport

DROP SEQUENCE sample_seq;
DROP SEQUENCE substance_seq;
DROP SEQUENCE person_seq;
DROP SEQUENCE tue_seq;
DROP SEQUENCE address_seq;
DROP SEQUENCE control_seq;

DROP VIEW athlete_names_ids;
DROP VIEW dco_names_ids;

DROP TRIGGER address_pk_fill_empty;
DROP TRIGGER person_contact_validate;
DROP TRIGGER person_email_validate;
DROP PROCEDURE currently_in_country_percentage;
DROP PROCEDURE not_at_home_list;

DROP MATERIALIZED VIEW lab_sample;

DROP INDEX index_athlete_sport;