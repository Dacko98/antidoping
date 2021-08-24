-- IDS PROJEKT VSECHNY FAZE
-- Authors: Daniel Jacko (xjacko04@stud.fit.vutbr.cz)
--          Petr Mičulek (xmicul08@stud.fit.vutbr.cz)

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

CREATE SEQUENCE sample_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE substance_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE person_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE address_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE tue_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE SEQUENCE control_seq
    START WITH 100000
    INCREMENT BY 1;

CREATE TABLE address
(
    id          int DEFAULT address_seq.nextval PRIMARY KEY,
    country     varchar(127),
    postal_code varchar(31), -- can contain alphanumeric
    city        varchar(127),
    street      varchar(127),
    house       varchar(31)  -- house "number" e.g. 3192B/9


);

CREATE TABLE person
(
    id           int DEFAULT person_seq.nextval PRIMARY KEY,
    sex          int, -- 0 == female, 1 == male;
    name_first   varchar(31) NOT NULL,
    name_last    varchar(31) NOT NULL,
    email        varchar(63),
    address      int,
    birth_date   date,

    phone_number int,

    CONSTRAINT phone_number_max_digits
        CHECK (phone_number <= 999999999999),

    CONSTRAINT phone_number_min_digits
        CHECK (phone_number >= 100000000),

    CONSTRAINT person#address_fk
        FOREIGN KEY (address) REFERENCES address (id)
);

CREATE TABLE athlete
(
    id              int PRIMARY KEY,
    address_current int,
    -- some athletes must give info about their current whereabouts

    CONSTRAINT athlete#person_fk
        FOREIGN KEY (id) REFERENCES person (id) ON DELETE CASCADE,

    CONSTRAINT athlete#address_current_fk
        FOREIGN KEY (address_current) REFERENCES address (id)

);

CREATE TABLE laboratory
(
    id                        int PRIMARY KEY,
    name                      varchar(127),
    accreditation_valid_until date,
    address                   int,

    CONSTRAINT laboratory#address_fk
        FOREIGN KEY (address) REFERENCES address (id)
);

CREATE TABLE laboratory_employee
(
    id            int PRIMARY KEY,
    position      varchar(127),
    laboratory_id int NOT NULL,

    CONSTRAINT laboratory_employee#laboratory_fk
        FOREIGN KEY (laboratory_id) REFERENCES laboratory (id),

    CONSTRAINT laboratory_employee#person_fk
        FOREIGN KEY (id) REFERENCES person (id) ON DELETE CASCADE

);

CREATE TABLE doping_control_officer
(
    id             int PRIMARY KEY,
    licence_number int UNIQUE,

    CONSTRAINT dco#person_fk
        FOREIGN KEY (id) REFERENCES person (id) ON DELETE CASCADE

);

CREATE TABLE sport
(
    name varchar(127) PRIMARY KEY

);

CREATE TABLE rel_athlete_sport
(
    athlete_id int,
    sport_name varchar(127),
    PRIMARY KEY (athlete_id, sport_name),


    CONSTRAINT athlete_sport#athlete_fk
        FOREIGN KEY (athlete_id) REFERENCES athlete (id) ON DELETE CASCADE,

    CONSTRAINT athlete_sport#sport_fk
        FOREIGN KEY (sport_name) REFERENCES sport (name) ON DELETE CASCADE

);

CREATE TABLE therapeutic_use_exemption
(
    id                       int DEFAULT tue_seq.nextval PRIMARY KEY,

    athlete_id               int NOT NULL,

    valid_in_competition     int, -- 0 == false, 1 == true
    valid_out_of_competition int, -- 0 == false, 1 == true

    commentary               clob,

    CONSTRAINT tue#athlete_fk
        FOREIGN KEY (athlete_id) REFERENCES athlete (id) ON DELETE CASCADE,


    CONSTRAINT tue_valid_in_competition_values
        CHECK (valid_in_competition = 0 OR valid_in_competition = 1),

    CONSTRAINT tue_valid_out_of_competition_values
        CHECK (valid_out_of_competition = 0 OR valid_out_of_competition = 1)

    -- referencing the substance must be done M:N -> separate table

);

CREATE TABLE substance_category
(
    name varchar(127) PRIMARY KEY
);

CREATE TABLE substance
(
    id       int PRIMARY KEY,
    category varchar(127) NOT NULL,
    name     varchar(127),

    CONSTRAINT substance#category_fk
        FOREIGN KEY (category) REFERENCES substance_category (name)

);


CREATE TABLE substance_ban
(
    id                       int PRIMARY KEY,
    substance_id             int, -- @discuss: add a substance category
    valid_from               date,
    valid_in_competition     int, -- 0 == false, 1 == true
    valid_out_of_competition int, -- 0 == false, 1 == true

    commentary               clob,

    CONSTRAINT substance_ban#substance_fk
        FOREIGN KEY (substance_id) REFERENCES substance (id) ON DELETE CASCADE,


    CONSTRAINT ban_valid_in_competition_values
        CHECK (valid_in_competition = 0 OR valid_in_competition = 1),

    CONSTRAINT ban_valid_out_of_competition_values
        CHECK (valid_out_of_competition = 0 OR valid_out_of_competition = 1)


);

CREATE TABLE rel_tue_substance
(
    tue_id       int,
    substance_id int,
    PRIMARY KEY (tue_id, substance_id),


    CONSTRAINT tue_substance#tue_fk
        FOREIGN KEY (tue_id) REFERENCES therapeutic_use_exemption (id) ON DELETE CASCADE,

    CONSTRAINT tue_substance#substance_fk
        FOREIGN KEY (substance_id) REFERENCES substance (id) ON DELETE CASCADE

);

CREATE TABLE doping_control
(
    id               int DEFAULT control_seq.nextval PRIMARY KEY,
    athlete_presence int, -- 0 == was not present, 1 == was present
    start_time       date,
    end_time         date,
    in_competition   int, -- 0 == out of competition, 1 == in competition
    samples_required varchar(127),
    delay            int, --number of days
    reason_of_delay  varchar(255),
    dco_id           int NOT NULL,
    athlete_id       int NOT NULL,

    CONSTRAINT dop_control#dco_fk
        FOREIGN KEY (dco_id) REFERENCES doping_control_officer (id) ON DELETE CASCADE,

    CONSTRAINT dop_control#athlete_fk
        FOREIGN KEY (athlete_id) REFERENCES athlete (id) ON DELETE CASCADE,

    CONSTRAINT control_athlete_presence_values
        CHECK (athlete_presence = 0 OR athlete_presence = 1),

    CONSTRAINT control_in_competition_values
        CHECK (in_competition = 0 OR in_competition = 1)

);

CREATE TABLE sample
(
    id            int DEFAULT sample_seq.nextval PRIMARY KEY,
    use           int, -- 0 == main sample, 1 == control sample
    evaluation    int, -- 0 == negative, 1 == positive
    type          int, -- 0 == urine sample, 1 == blood sample
    volume        int, -- [milliliters]
    control_id    int NOT NULL,
    laboratory_id int,

    CONSTRAINT sample#laboratory_fk
        FOREIGN KEY (laboratory_id) REFERENCES laboratory (id),

    CONSTRAINT sample#control_fk
        FOREIGN KEY (control_id) REFERENCES doping_control (id) ON DELETE CASCADE,

    CONSTRAINT sample_use_values
        CHECK (use = 0 OR use = 1),

    CONSTRAINT sample_evaluation_values
        CHECK (evaluation = 0 OR evaluation = 1),

    CONSTRAINT sample_type_values
        CHECK (type = 0 OR type = 1),

    CONSTRAINT sample_volume_positive
        CHECK (volume > 0)

);


CREATE TABLE rel_ban_sport
(
    sport_name       varchar(127),
    substance_ban_id int,

    PRIMARY KEY (sport_name, substance_ban_id),


    CONSTRAINT ban_sport#substance_fk
        FOREIGN KEY (substance_ban_id) REFERENCES substance_ban (id) ON DELETE CASCADE,

    CONSTRAINT ban_sport#sport_fk
        FOREIGN KEY (sport_name) REFERENCES sport (name) ON DELETE CASCADE
);

CREATE TABLE rel_substance_sample
(
    sample_id    int,
    substance_id int,
    PRIMARY KEY (sample_id, substance_id),

    CONSTRAINT substance_sample#sample_fk
        FOREIGN KEY (sample_id) REFERENCES sample (id) ON DELETE CASCADE,

    CONSTRAINT substance_sample#substance_fk
        FOREIGN KEY (substance_id) REFERENCES substance (id) ON DELETE CASCADE
);

CREATE TABLE rel_tue_sport
(
    tue_id     int,
    sport_name varchar(127),
    PRIMARY KEY (tue_id, sport_name),


    CONSTRAINT tue_sport#tue_fk
        FOREIGN KEY (tue_id) REFERENCES therapeutic_use_exemption (id) ON DELETE CASCADE,

    CONSTRAINT tue_sport#sport_fk
        FOREIGN KEY (sport_name) REFERENCES sport (name) ON DELETE CASCADE
);


INSERT INTO address
VALUES (1, 'Slovakia', 01021, 'Osrblie', 'Horna', '123/41');

INSERT INTO address
VALUES (2, 'Slovakia', 05001, 'Revuca', 'Sladkovicova', '1/65');

INSERT INTO address
VALUES (3, 'Slovakia', 09101, 'Bratislava', 'Dolna', '1111/633');


INSERT INTO address
VALUES (4, 'Czechia', '10700', 'Praha', 'Za Cisarskym mlynem', '1063');
INSERT INTO address
VALUES (5, 'Czechia', '70800', 'Ostrava', 'Marie Majerove', '1691');
INSERT INTO address
VALUES (6, 'Czechia', '70100', 'Ostrava', 'Hornopolni', '541A');
INSERT INTO address
VALUES (7, 'Czechia', '60200', 'Brno', 'Lerchova', '7');
INSERT INTO address
VALUES (8, 'Czechia', '61200', 'Brno', 'Bozetechova', '1/2');
INSERT INTO address
VALUES (9, 'Czechia', '16000', 'Praha', 'Thakurova', '2700/9');
INSERT INTO address
VALUES (10, 'Czechia', '11800', 'Praha', 'Uavoz', '169/6');
INSERT INTO person
VALUES (1, 1, 'Anastasiya', 'Kuzmina ', 'nasta@gmail.com', 1, TO_DATE('1984-08-28 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        421939288009);
INSERT INTO person
VALUES (2, 1, 'Jaro', 'Krupina ', 'jaro.krupina@gmail.com', 2, TO_DATE('1956-12-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        421939288009);
INSERT INTO person
VALUES (3, 1, 'Gavriel', 'Guatiche', 'mr.pg@hotmail.co.uk', 3, TO_DATE('1975-04-11 19:19:18', 'YYYY-MM-DD HH24:MI:SS'),
        420771250888);
INSERT INTO person
VALUES (4, 1, 'Cairne', 'Bloodhoof', 'hearmeroar@blizzard.com', 4,
        TO_DATE('1999-09-24 00:20:48', 'YYYY-MM-DD HH24:MI:SS'), 420712365487);
INSERT INTO person
VALUES (5, 0, 'Janna', 'Solari', 'forecast@chmi.cz', 5, TO_DATE('2000-04-11 19:22:00', 'YYYY-MM-DD HH24:MI:SS'),
        420655494124);
INSERT INTO person
VALUES (6, 1, 'Lentz', 'Strongarm', 'imcleanman@doubt.yes', 6, TO_DATE('1969-07-11 19:23:18', 'YYYY-MM-DD HH24:MI:SS'),
        433679979953);
INSERT INTO person
VALUES (7, 0, 'Johanna', 'Arch', 'idontuse@arch.btw', 7, TO_DATE('1994-03-17 19:25:26', 'YYYY-MM-DD HH24:MI:SS'),
        420646544654);
INSERT INTO person
VALUES (8, 0, 'Tess', 'Twicey', 'foolmetwice@shameon.me', 8, TO_DATE('1998-05-15 19:27:35', 'YYYY-MM-DD HH24:MI:SS'),
        420949465423);
INSERT INTO person
VALUES (9, 1, 'Jan', 'Chlumsky', 'reditel@antidoping.cz', 9, TO_DATE('1950-03-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        420233382701);

INSERT INTO doping_control_officer
VALUES (3, 1975);
INSERT INTO doping_control_officer
VALUES (9, 555);

INSERT INTO athlete
VALUES (1, 1);

INSERT INTO athlete (id, address_current)
VALUES (4, 4);
INSERT INTO athlete (id, address_current)
VALUES (5, 5);
INSERT INTO athlete (id, address_current)
VALUES (6, 10);
INSERT INTO athlete (id, address_current)
VALUES (7, 10);
INSERT INTO athlete (id, address_current)
VALUES (8, 10);

INSERT INTO laboratory
VALUES (1002, 'Antidoping centre', '29-August-2021', 3);

INSERT INTO laboratory_employee
VALUES (2, 'student', 1002);

INSERT INTO sport
VALUES ('biathlon');

INSERT INTO sport
VALUES ('cycling');

INSERT INTO sport
VALUES ('rowing');

INSERT INTO sport
VALUES ('columning');

INSERT INTO rel_athlete_sport
VALUES (1, 'biathlon');


INSERT INTO therapeutic_use_exemption
VALUES (100000, 1, 1, 1, 'OK');
INSERT INTO therapeutic_use_exemption
VALUES (100001, 4, 1, 0, 'OK-too');
INSERT INTO therapeutic_use_exemption
VALUES (100002, 4, 1, 1, 'OK-three');

INSERT INTO substance_category
VALUES ('vitamins');

INSERT INTO substance_category
VALUES ('WABP');

INSERT INTO substance_category
VALUES ('metabolic modulator');

INSERT INTO substance
VALUES (100000, 'vitamins', 'B12');

INSERT INTO substance
VALUES (100001, 'WABP', 'suplement411');

INSERT INTO substance
VALUES (100002, 'metabolic modulator', 'Letrozole');

INSERT INTO substance_ban
VALUES (100002, 100001, '20-November-1999', 1, 1, 'No commentary');

INSERT INTO rel_tue_substance
VALUES (100000, 100001);

INSERT INTO doping_control
VALUES (100000, -- id
        1, -- athlete presence
        TO_DATE('2020-November-20 17:30', 'YYYY-MON-DD HH24:MI'), -- start
        TO_DATE('2020-November-20 18:30', 'YYYY-MON-DD HH24:MI'), -- end
        1, -- in competition
        '15ml blood, if not possible, 90ml urine instead', -- notes on samples
        0, -- no delay
        '', -- no reason of delay
        9, -- dco id
        1); -- athlete id

INSERT INTO doping_control
VALUES (100001, -- id
        1, -- athlete presence
        TO_DATE('2020-November-21 17:30', 'YYYY-MON-DD HH24:MI'), -- start
        TO_DATE('2020-November-21 18:30', 'YYYY-MON-DD HH24:MI'), -- end
        0, -- in competition
        '20ml blood', -- notes on samples
        0, -- no delay
        '', -- no reason of delay
        3, -- dco id
        6); -- athlete id


INSERT INTO doping_control
VALUES (100002, -- id
        1, -- athlete presence
        TO_DATE('2020-November-22 17:30', 'YYYY-MON-DD HH24:MI'), -- start
        TO_DATE('2020-November-22 18:30', 'YYYY-MON-DD HH24:MI'), -- end
        1, -- in competition
        '20ml blood', -- notes on samples
        0, -- no delay
        '', -- no reason of delay
        9, -- dco id
        1); -- athlete id


INSERT INTO doping_control
VALUES (100003, -- id
        1, -- athlete presence
        TO_DATE('2020-November-23 17:30', 'YYYY-MON-DD HH24:MI'), -- start
        TO_DATE('2020-November-23 18:30', 'YYYY-MON-DD HH24:MI'), -- end
        0, -- in competition
       '15ml blood, if not possible, 90ml urine instead', -- notes on samples
        0, -- no delay
        '', -- no reason of delay
        3, -- dco id
        5); -- athlete id

-- NULL -> sample evaluation may not be known at given time
INSERT INTO sample
VALUES (100000, 0, NULL, 0, 95, 100000, 1002);

INSERT INTO sample
VALUES (100001, 1, NULL, 1, 20, 100000, 1002);

INSERT INTO sample
VALUES (100002, 0, NULL, 1, 20, 100001, 1002);

INSERT INTO sample
VALUES (100003, 1, NULL, 1, 20, 100001, 1002);

INSERT INTO sample
VALUES (100004, 0, NULL, 1, 20, 100002, 1002);

INSERT INTO sample
VALUES (100005, 0, NULL, 1, 15, 100003, 1002);

INSERT INTO sample
VALUES (100006, 1, NULL, 1, 15, 100003, 1002);

-- later on, sample is evaluated as positive(1) / negative(0)
UPDATE sample
SET evaluation = 1
WHERE id = 100000;

UPDATE sample
SET evaluation = 1
WHERE id = 100001;

UPDATE sample
SET evaluation = 0
WHERE id = 100002;

UPDATE sample
SET evaluation = 0
WHERE id = 100003;

UPDATE sample
SET evaluation = 0
WHERE id = 100004;

UPDATE sample
SET evaluation = 1
WHERE id = 100005;

UPDATE sample
SET evaluation = 1
WHERE id = 100006;

INSERT INTO rel_ban_sport
VALUES ('biathlon', 100002);

INSERT INTO rel_substance_sample
VALUES (100000, 100001);

INSERT INTO rel_substance_sample
VALUES (100001, 100001);

INSERT INTO rel_substance_sample
VALUES (100002, 100000);

INSERT INTO rel_substance_sample
VALUES (100002, 100001);

INSERT INTO rel_substance_sample
VALUES (100003, 100000);

INSERT INTO rel_substance_sample
VALUES (100002, 100002);

INSERT INTO rel_substance_sample
VALUES (100003, 100002);

INSERT INTO rel_substance_sample
VALUES (100004, 100000);

INSERT INTO rel_substance_sample
VALUES (100005, 100002);

INSERT INTO rel_substance_sample
VALUES (100006, 100002);


INSERT INTO rel_tue_sport
VALUES (100000, 'biathlon');

INSERT INTO REL_ATHLETE_SPORT
VALUES(4, 'biathlon');

INSERT INTO REL_ATHLETE_SPORT
VALUES(1, 'cycling');

INSERT INTO REL_ATHLETE_SPORT
VALUES(5, 'cycling');

INSERT INTO REL_ATHLETE_SPORT
VALUES(7, 'rowing');

INSERT INTO REL_ATHLETE_SPORT
VALUES(8, 'biathlon');

INSERT INTO REL_ATHLETE_SPORT
VALUES(4, 'cycling');

INSERT INTO REL_ATHLETE_SPORT
VALUES(6, 'cycling');

INSERT INTO REL_ATHLETE_SPORT
VALUES(6, 'columning');

INSERT INTO REL_ATHLETE_SPORT
VALUES(6, 'rowing');

-- podpurne views
--      typicky nas zajimaji jmena urcitych osob,
--      vzhledem k vazbam skrz .id ale potrebujeme i tento atribut
CREATE VIEW athlete_names_ids AS
SELECT p.name_first, p.name_last, p.id
FROM athlete a
         JOIN person p ON a.id = p.id;

CREATE VIEW dco_names_ids AS
SELECT p.name_first, p.name_last, p.id
FROM doping_control_officer d
         JOIN person p ON d.id = p.id;


-- Kteří sportovci ještě neměli žádnou kontrolu?

SELECT DISTINCT *
FROM athlete_names_ids a
WHERE NOT EXISTS(SELECT * FROM doping_control dc WHERE dc.athlete_id = a.id)
ORDER BY a.id;


-- Zjisti všechny sportovce, kteří byli na kontrole u komisaře X.
-- vstupem do tohoto dotazu je jmeno a prijmeni komisare (zde 'Jan', 'Chlumsky')

SELECT DISTINCT *
FROM athlete_names_ids a
WHERE EXISTS(SELECT *
             FROM doping_control dc
                      JOIN dco_names_ids dco
                           ON dc.dco_id = dco.id
             WHERE dc.athlete_id = a.id
               AND dco.name_first = 'Jan'
               AND dco.name_last = 'Chlumsky')
ORDER BY a.id;


-- Seznam sportovců, kteří měli libovolný vzorek vyhodnocený jako pozitivní
-- (nemusí nutně obsahovat zakázanou látku - např. se zjistil podvod při manipulaci se vzorkem)
-- pomocí NOT EXISTS se dá naopak vypsat seznam těch, co nikdy neměli pozitivní vzorek
SELECT DISTINCT p.name_first, p.name_last
FROM athlete a
         JOIN person p ON a.id = p.id
WHERE EXISTS
          (SELECT *
           FROM doping_control dc
                    JOIN sample s
                         ON dc.id = s.control_id
           WHERE s.evaluation = 1
             AND dc.athlete_id = a.id);


-- Sportovci s největším počtem Terapeutických výjimek
-- (počet nemusí být maximální, cílem bylo sestupné seřazení)

SELECT a.name_first, a.name_last, a.id, COUNT(*) AS c
FROM therapeutic_use_exemption tue
         JOIN athlete_names_ids a
              ON tue.athlete_id = a.id
GROUP BY a.id, a.name_first, a.name_last
ORDER BY c DESC;


-- Najviac zastúpené kategórie látok v odobratých vzorkoch

SELECT s.category, COUNT(*) AS c
FROM rel_substance_sample ss
         JOIN substance s
              ON ss.substance_id = s.id
GROUP BY s.category
ORDER BY c DESC;

--Najviac testovaní športovci

SELECT a.name_first, a.name_last, a.id, COUNT(*) AS c
FROM DOPING_CONTROL dp
         JOIN athlete_names_ids a
              ON dp.athlete_id = a.id
GROUP BY a.id, a.name_first, a.name_last
ORDER BY c DESC;

--Športovci testovaní v určitom časovom rozmedzí

SELECT *
FROM athlete_names_ids
WHERE id IN
      (SELECT athlete_id
       FROM doping_control
       WHERE start_time BETWEEN TO_DATE('2020-November-22 17:30', 'YYYY-MON-DD HH24:MI') and
                 TO_DATE('2020-November-24 18:30', 'YYYY-MON-DD HH24:MI'));


--generuje primarny kluc, pokial nebol zadany tj. NULL
CREATE OR REPLACE TRIGGER address_pk_fill_empty
    BEFORE INSERT OR UPDATE
    ON address
    FOR EACH ROW
    WHEN (new.id IS NULL)
BEGIN
    SELECT address_seq.nextval INTO : new.id FROM dual;
END;
/



--Aspon jeden kontaktny udaj z dvojice email, cislo musi byt zadany
CREATE OR REPLACE TRIGGER person_contact_validate
    BEFORE INSERT OR UPDATE
    ON person
    FOR EACH ROW
BEGIN
    IF ((:new.email IS NULL) AND (:new.phone_number IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20005, 'At least one from email and phone number should not be null');
    END IF;
END;
/


--nespravny format emailu
CREATE OR REPLACE TRIGGER person_email_validate
    BEFORE INSERT OR UPDATE
    ON person
    FOR EACH ROW
BEGIN
    IF (:new.email NOT LIKE '%@%._%') THEN
        RAISE_APPLICATION_ERROR(-20005, 'Wrong email address format');
    END IF;
END;
/



--Vypise kolko percent zo vsetkych sportovcov aktualne pobyva v dane krajine
CREATE OR REPLACE PROCEDURE currently_in_country_percentage(country IN varchar2)
    IS
    CURSOR athlete_cursor IS SELECT *
                             FROM athlete;
    athlete_var      athlete%rowtype;
    total_var        number := 0;
    from_country_var number := 0;
    address_var      address%rowtype;

BEGIN
    OPEN athlete_cursor;
    LOOP
        FETCH athlete_cursor INTO athlete_var;
        EXIT WHEN athlete_cursor%NOTFOUND;
        FOR one_person IN (SELECT * FROM person)
            LOOP
                IF one_person.id = athlete_var.id THEN
                    SELECT * INTO address_var FROM address WHERE address.id = one_person.address;
                    IF address_var.country = country THEN
                        from_country_var := from_country_var + 1;
                    END IF;
                    total_var := total_var + 1;
                END IF;
            END LOOP;
    END LOOP;
    dbms_output.put_line(ROUND(from_country_var / total_var * 100, 2) || '% of all athletes currently stay in ' || country);
    CLOSE athlete_cursor;

EXCEPTION
    WHEN zero_divide THEN
        dbms_output.put_line('No athletes registered (ZERO_DIVIDE: ' || sqlerrm || ')');
END;
/



--vypise sportovcov, ktori sa aktualne nenachadzaju v mieste trvaleho bydliska
CREATE OR REPLACE PROCEDURE not_at_home_list
    IS
    CURSOR athlete_cursor IS SELECT *
                             FROM athlete;
    athlete_var athlete%rowtype;

BEGIN
    OPEN athlete_cursor;
    LOOP
        FETCH athlete_cursor INTO athlete_var;
        EXIT WHEN athlete_cursor%NOTFOUND;
        FOR person IN (SELECT * FROM person)
            LOOP
                IF ((person.id = athlete_var.id) AND (athlete_var.address_current <> person.address)) THEN
                    dbms_output.put_line(person.name_first || ' ' || person.name_last);
                END IF;
            END LOOP;
    END LOOP;
    CLOSE athlete_cursor;
END;
/

--EXPLAIN PLAN a INDEX

EXPLAIN PLAN FOR
SELECT s.name, COUNT(*) AS c
FROM rel_athlete_sport aths
         JOIN sport s
              ON aths.sport_name = s.name
GROUP BY s.name;

SELECT *
FROM TABLE (dbms_xplan.display());


CREATE INDEX index_athlete_sport ON rel_athlete_sport (sport_name);

EXPLAIN PLAN FOR
SELECT /*+ INDEX(rel_athlete_sport index_athlete_sport) */ s.name, COUNT(*) AS c
FROM rel_athlete_sport aths
         JOIN sport s
              ON aths.sport_name = s.name
GROUP BY s.name;

SELECT *
FROM TABLE (dbms_xplan.display());


-- Materializovany pohled
CREATE MATERIALIZED VIEW lab_sample
            CACHE
            BUILD IMMEDIATE
            REFRESH ON COMMIT
            ENABLE QUERY REWRITE
AS
SELECT lab.name, sam.id
FROM laboratory lab,
     sample sam
WHERE lab.id = sam.laboratory_id;

-- SELECT * FROM lab_sample;


-- Prideleni pristupovych prav (konkretnimu uzivateli)
GRANT ALL ON address TO xmicul08;
GRANT ALL ON athlete TO xmicul08;
GRANT ALL ON doping_control TO xmicul08;
GRANT ALL ON doping_control_officer TO xmicul08;
GRANT ALL ON laboratory TO xmicul08;
GRANT ALL ON laboratory_employee TO xmicul08;
GRANT ALL ON person TO xmicul08;
GRANT ALL ON rel_athlete_sport TO xmicul08;
GRANT ALL ON rel_ban_sport TO xmicul08;
GRANT ALL ON rel_substance_sample TO xmicul08;
GRANT ALL ON rel_tue_sport TO xmicul08;
GRANT ALL ON sample TO xmicul08;
GRANT ALL ON sport TO xmicul08;
GRANT ALL ON substance TO xmicul08;
GRANT ALL ON substance_ban TO xmicul08;
GRANT ALL ON substance_category TO xmicul08;
GRANT ALL ON therapeutic_use_exemption TO xmicul08;
GRANT ALL ON lab_sample TO xmicul08;

COMMIT;

-- INSERT INTO sample VALUES (100010, 0, NULL, 0, 95, 100000, 1002);


-- sample usage of procedures
-- DECLARE BEGIN
-- currently_in_country_percentage('Czechia');
-- not_at_home_list();
-- END;
-- /





