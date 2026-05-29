-- ============================================================
-- 05_materialized_views.sql
-- Wykonać jako użytkownik SIEDZIBA
-- Tworzy perspektywy zmaterializowane (migawki)
-- ============================================================

-- --------------------------------------------------------
-- MIGAWKA 1: MV_WYKLADOWCY_ALL
-- Odświeżanie ręczne (ON DEMAND), tryb COMPLETE
-- --------------------------------------------------------
CREATE MATERIALIZED VIEW mv_wykladowcy_all
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
AS
  SELECT * FROM wykladowcyAll;

-- Ręczne odświeżenie migawki
EXECUTE DBMS_MVIEW.REFRESH('MV_WYKLADOWCY_ALL', 'C');

-- Sprawdzenie daty i trybu ostatniego odświeżenia
SELECT mview_name, last_refresh_type, last_refresh_date
FROM user_mviews
WHERE mview_name = 'MV_WYKLADOWCY_ALL';

-- --------------------------------------------------------
-- MIGAWKA 2: MV_KURSY_ALL
-- Odświeżanie automatyczne co godzinę, tryb COMPLETE
-- --------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kursy_all
  BUILD IMMEDIATE
  REFRESH COMPLETE
  START WITH SYSDATE
  NEXT SYSDATE + 1/24
AS
  SELECT * FROM kursyAll;

-- --------------------------------------------------------
-- MIGAWKA 3: MV_KURSANCI_ALL
-- Odświeżanie automatyczne co 7 dni, tryb COMPLETE
-- --------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kursanci_all
  BUILD IMMEDIATE
  REFRESH COMPLETE
  START WITH SYSDATE
  NEXT SYSDATE + 7
AS
  SELECT * FROM kursanciAll;

-- --------------------------------------------------------
-- TESTY MIGAWEK
-- --------------------------------------------------------
SELECT COUNT(*) FROM mv_wykladowcy_all; -- oczekiwany wynik: 33
SELECT COUNT(*) FROM mv_kursy_all;      -- oczekiwany wynik: 15
SELECT COUNT(*) FROM mv_kursanci_all;   -- oczekiwany wynik: 166

-- Przegląd wszystkich migawek i harmonogramów odświeżania
SELECT name, last_refresh, refresh_method, next
FROM user_snapshots;

-- Alternatywnie (nowsza składnia):
SELECT mview_name, refresh_method, last_refresh_type, last_refresh_date
FROM user_mviews;
