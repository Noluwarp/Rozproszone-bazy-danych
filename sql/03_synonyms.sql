-- ============================================================
-- 03_synonyms.sql
-- Wykonać jako użytkownik SIEDZIBA
-- Tworzy synonimy prywatne dla tabel lokalnych i zdalnych
-- ============================================================

-- Synonimy dla tabel lokalnych (SIEDZIBA)
CREATE SYNONYM kursanciSiedziba   FOR kursanci;
CREATE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE SYNONYM rodzajeSiedziba    FOR rodzaje;
CREATE SYNONYM kursySiedziba      FOR kursy;

-- Synonimy dla tabel zdalnych (FILIA przez database link)
CREATE SYNONYM kursanciFilia   FOR kursanci@dblinkFilia;
CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE SYNONYM rodzajeFilia    FOR rodzaje@dblinkFilia;
CREATE SYNONYM kursyFilia      FOR kursy@dblinkFilia;

-- Testy synonimów
SELECT COUNT(*) FROM kursanciSiedziba;   -- oczekiwany wynik: 85
SELECT COUNT(*) FROM kursanciFilia;      -- oczekiwany wynik: 81

SELECT COUNT(*) FROM wykladowcySiedziba; -- oczekiwany wynik: 19
SELECT COUNT(*) FROM wykladowcyFilia;    -- oczekiwany wynik: 14
