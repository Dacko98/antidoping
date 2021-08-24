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
                 TO_DATE('2020-November-24 18:30', 'YYYY-MON-DD HH24:MI'))


