-- ============================================================
-- 06_tests.sql
-- Wykonać jako użytkownik SIEDZIBA
-- Zestaw zapytań weryfikujących poprawność konfiguracji
-- ============================================================

-- 1. Weryfikacja database linka
SELECT COUNT(*) AS kursanci_filia FROM kursanci@dblinkFilia; -- 81

-- 2. Weryfikacja synonimów
SELECT COUNT(*) AS kursanci_siedziba FROM kursanciSiedziba;   -- 85
SELECT COUNT(*) AS kursanci_filia    FROM kursanciFilia;      -- 81
SELECT COUNT(*) AS wyklad_siedziba   FROM wykladowcySiedziba; -- 19
SELECT COUNT(*) AS wyklad_filia      FROM wykladowcyFilia;    -- 14

-- 3. Weryfikacja widoków
SELECT COUNT(*) AS wszyscy_kursanci   FROM kursanciAll;   -- 166
SELECT COUNT(*) AS wszyscy_wykladowcy FROM wykladowcyAll; -- 33
SELECT COUNT(*) AS wszystkie_kursy    FROM kursyAll;      -- 15

SELECT view_name FROM user_views ORDER BY view_name;

-- 4. Weryfikacja migawek
SELECT COUNT(*) AS mv_wykladowcy FROM mv_wykladowcy_all; -- 33
SELECT COUNT(*) AS mv_kursy      FROM mv_kursy_all;      -- 15
SELECT COUNT(*) AS mv_kursanci   FROM mv_kursanci_all;   -- 166

SELECT name, refresh_method, last_refresh, next
FROM user_snapshots ORDER BY name;

-- 5. Przychód ze wszystkich kursów (siedziba + filia)
SELECT r.nazwa, r.cena, COUNT(u.umowa_id) AS uczestnicy,
       r.cena * COUNT(u.umowa_id) AS przychod
FROM kursySiedziba k
JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
JOIN umowy u ON k.kurs_id = u.kurs_id
WHERE u.miasto = 'BYDGOSZCZ'
GROUP BY r.nazwa, r.cena
UNION ALL
SELECT r.nazwa, r.cena, COUNT(u.umowa_id),
       r.cena * COUNT(u.umowa_id)
FROM kursyFilia k
JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
JOIN umowy u ON k.kurs_id = u.kurs_id
WHERE u.miasto = 'SZCZECIN'
GROUP BY r.nazwa, r.cena
ORDER BY przychod DESC;
