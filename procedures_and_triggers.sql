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





