-- ============================================================
-- 04_views.sql
-- Wykonać jako użytkownik SIEDZIBA
-- Tworzy widoki łączące dane z obu schematów (UNION)
-- ============================================================

-- Widok: wszyscy kursanci z siedziby i filii
CREATE VIEW kursanciAll AS
  SELECT imie, nazwisko FROM kursanciSiedziba
  UNION
  SELECT imie, nazwisko FROM kursanciFilia;

-- Widok: wszyscy wykładowcy z siedziby i filii
CREATE VIEW wykladowcyAll AS
  SELECT imie, nazwisko FROM wykladowcySiedziba
  UNION
  SELECT imie, nazwisko FROM wykladowcyFilia;

-- Widok: wszystkie kursy z siedziby i filii
-- Tabela KURSY zawiera kolumny: KURS_ID, RODZAJ_ID, WYKLADOWCA_ID
CREATE VIEW kursyAll AS
  SELECT kurs_id, rodzaj_id, wykladowca_id FROM kursySiedziba
  UNION
  SELECT kurs_id, rodzaj_id, wykladowca_id FROM kursyFilia;

-- Testy widoków
SELECT COUNT(*) FROM kursanciAll;   -- oczekiwany wynik: 166
SELECT COUNT(*) FROM wykladowcyAll; -- oczekiwany wynik: 33
SELECT COUNT(*) FROM kursyAll;      -- oczekiwany wynik: 15

-- Sprawdzenie listy widoków w schemacie
SELECT view_name FROM user_views;
-- Oczekiwane: KURSANCIALL, WYKLADOWCYALL, KURSYALL
