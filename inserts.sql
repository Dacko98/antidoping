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