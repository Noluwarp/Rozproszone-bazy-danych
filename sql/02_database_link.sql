-- ============================================================
-- 02_database_link.sql
-- Wykonać jako użytkownik SIEDZIBA
-- Tworzy prywatny database link do schematu FILIA
-- ============================================================

-- Tworzenie łącznika bazodanowego
-- W środowisku laboratoryjnym service name = nazwa bazy (baza11b)
-- W środowisku lokalnym (jedna instancja ORCL) używamy ORCL
CREATE DATABASE LINK dblinkFilia
  CONNECT TO filia
  IDENTIFIED BY start123
  USING 'ORCL';

-- Test łącznika - powinien zwrócić 81
SELECT COUNT(*) FROM kursanci@dblinkFilia;

-- Wyświetlenie zawartości tabeli przez link
SELECT * FROM kursanci@dblinkFilia;

-- UWAGA: Jeśli COUNT(*) zwraca 0, mimo że dane są w schemacie FILIA,
-- należy w sesji FILIA wykonać COMMIT, aby dane były widoczne przez link.
