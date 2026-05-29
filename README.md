# Rozproszone Bazy Danych — Oracle SQL Developer

## Opis projektu

Projekt laboratoryjny z przedmiotu **Rozproszone Bazy Danych**, wykonany w Oracle SQL Developer z lokalną instancją Oracle Database 19c (ORCL).

---

## Środowisko

| Element | Opis |
|---|---|
| Baza danych | Oracle Database 19c, instancja `ORCL` |
| Klient | Oracle SQL Developer |
| Usługi Windows | `OracleServiceORCL`, `OracleOraDB19Home1TNSListener` |
| Symulacja rozproszenia | Dwa schematy w jednej instancji: `SIEDZIBA` i `FILIA` |

> **Uwaga:** Ze względu na środowisko lokalne (jedna instancja Oracle), fizyczne rozbicie na dwie bazy (`baza11a` i `baza11b`) zostało zasymulowane poprzez dwa odrębne schematy użytkowników (`SIEDZIBA` i `FILIA`) połączone database linkiem. Logicznie zachowanie jest identyczne jak przy dwóch oddzielnych bazach.

---

## Schemat danych

### SIEDZIBA (baza11a) — kursy językowe w Bydgoszczy

| Tabela | Opis |
|---|---|
| `WYKLADOWCY` | 19 wykładowców ze stawkami |
| `KURSANCI` | 85 kursantów |
| `RODZAJE` | 8 rodzajów kursów (angielski, włoski, francuski...) |
| `KURSY` | 8 kursów |
| `UMOWY` | 166 umów (siedziby + filii) |

### FILIA (baza11b) — kursy IT w Szczecinie

| Tabela | Opis |
|---|---|
| `WYKLADOWCY` | 14 wykładowców |
| `KURSANCI` | 81 kursantów |
| `RODZAJE` | 7 rodzajów kursów (Oracle, Python, Java, Cisco...) |
| `KURSY` | 7 kursów |

---

## Krok 1 — Przygotowanie użytkowników (SYS/SYSDBA)

Wykonano jako `SYS` z rolą `SYSDBA`:

```sql
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

CREATE USER siedziba IDENTIFIED BY start123;
CREATE USER filia    IDENTIFIED BY start123;

GRANT CONNECT, RESOURCE TO siedziba;
GRANT CONNECT, RESOURCE TO filia;

GRANT CREATE DATABASE LINK     TO siedziba;
GRANT CREATE SYNONYM           TO siedziba;
GRANT CREATE VIEW              TO siedziba;
GRANT CREATE MATERIALIZED VIEW TO siedziba;

ALTER USER siedziba QUOTA UNLIMITED ON USERS;
ALTER USER filia    QUOTA UNLIMITED ON USERS;
```

Połączenia w SQL Developer:
- `SYS_ORCL` — użytkownik `sys`, rola `SYSDBA`, service name `ORCL`
- `SIEDZIBA` — użytkownik `siedziba`, rola `default`, service name `ORCL`
- `FILIA` — użytkownik `filia`, rola `default`, service name `ORCL`

---

## Krok 2 — Załadowanie danych

- Do schematu `SIEDZIBA` → skrypt `sql/kursySiedziba.sql`
- Do schematu `FILIA` → skrypt `sql/kursyFilia.sql`

---

## Krok 3 — Database Link (Łącznik bazodanowy)

Będąc zalogowanym jako `SIEDZIBA`, utworzono prywatny database link do schematu `FILIA`:

```sql
CREATE DATABASE LINK dblinkFilia
  CONNECT TO filia
  IDENTIFIED BY start123
  USING 'ORCL';
```

Test łącznika:
```sql
SELECT COUNT(*) FROM kursanci@dblinkFilia;
-- Wynik: 81
```

> **Uwaga:** Początkowo zapytanie przez link zwracało 0. Problem wynikał z niezatwierdzonej transakcji w schemacie FILIA. Po wykonaniu `COMMIT` w sesji FILIA, link zaczął poprawnie zwracać 81 rekordów.

---

## Krok 4 — Synonimy

W schemacie `SIEDZIBA` utworzono synonimy prywatne dla tabel lokalnych i zdalnych:

```sql
-- Synonimy lokalne (siedziba)
CREATE SYNONYM kursanciSiedziba   FOR kursanci;
CREATE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE SYNONYM rodzajeSiedziba    FOR rodzaje;
CREATE SYNONYM kursySiedziba      FOR kursy;

-- Synonimy zdalne (filia przez database link)
CREATE SYNONYM kursanciFilia   FOR kursanci@dblinkFilia;
CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE SYNONYM rodzajeFilia    FOR rodzaje@dblinkFilia;
CREATE SYNONYM kursyFilia      FOR kursy@dblinkFilia;
```

Testy:
```sql
SELECT COUNT(*) FROM kursanciSiedziba;  -- 85
SELECT COUNT(*) FROM kursanciFilia;     -- 81
```

---

## Krok 5 — Widoki (Views)

```sql
-- Wszyscy kursanci z obu baz
CREATE VIEW kursanciAll AS
  SELECT imie, nazwisko FROM kursanciSiedziba
  UNION
  SELECT imie, nazwisko FROM kursanciFilia;

-- Wszyscy wykładowcy z obu baz
CREATE VIEW wykladowcyAll AS
  SELECT imie, nazwisko FROM wykladowcySiedziba
  UNION
  SELECT imie, nazwisko FROM wykladowcyFilia;

-- Wszystkie kursy z obu baz
CREATE VIEW kursyAll AS
  SELECT kurs_id, rodzaj_id, wykladowca_id FROM kursySiedziba
  UNION
  SELECT kurs_id, rodzaj_id, wykladowca_id FROM kursyFilia;
```

Wyniki testów:
```sql
SELECT COUNT(*) FROM kursanciAll;   -- 166
SELECT COUNT(*) FROM wykladowcyAll; -- 33
SELECT COUNT(*) FROM kursyAll;      -- 15
```

---

## Krok 6 — Perspektywy zmaterializowane (Migawki)

### MV_WYKLADOWCY_ALL — odświeżanie ręczne (ON DEMAND)

```sql
CREATE MATERIALIZED VIEW mv_wykladowcy_all
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
AS
  SELECT * FROM wykladowcyAll;

-- Ręczne odświeżenie:
EXECUTE DBMS_MVIEW.REFRESH('MV_WYKLADOWCY_ALL', 'C');
```

### MV_KURSY_ALL — odświeżanie co godzinę

```sql
CREATE MATERIALIZED VIEW mv_kursy_all
  BUILD IMMEDIATE
  REFRESH COMPLETE
  START WITH SYSDATE
  NEXT SYSDATE + 1/24
AS
  SELECT * FROM kursyAll;
```

### MV_KURSANCI_ALL — odświeżanie co 7 dni

```sql
CREATE MATERIALIZED VIEW mv_kursanci_all
  BUILD IMMEDIATE
  REFRESH COMPLETE
  START WITH SYSDATE
  NEXT SYSDATE + 7
AS
  SELECT * FROM kursanciAll;
```

Wyniki testów:
```sql
SELECT COUNT(*) FROM mv_wykladowcy_all; -- 33
SELECT COUNT(*) FROM mv_kursy_all;      -- 15
SELECT COUNT(*) FROM mv_kursanci_all;   -- 166
```

Sprawdzenie harmonogramu odświeżania:
```sql
SELECT name, last_refresh, refresh_method, next
FROM user_snapshots;
```

| Migawka | Metoda | Harmonogram |
|---|---|---|
| MV_WYKLADOWCY_ALL | COMPLETE | ON DEMAND (ręczne) |
| MV_KURSY_ALL | COMPLETE | co godzinę (SYSDATE + 1/24) |
| MV_KURSANCI_ALL | COMPLETE | co 7 dni (SYSDATE + 7) |

---

## Struktura repozytorium

```
├── README.md
├── sql/
│   ├── 01_create_users.sql        -- Tworzenie użytkowników (SYS)
│   ├── 02_database_link.sql       -- Database link dblinkFilia
│   ├── 03_synonyms.sql            -- Synonimy prywatne
│   ├── 04_views.sql               -- Widoki kursanciAll, wykladowcyAll, kursyAll
│   ├── 05_materialized_views.sql  -- Perspektywy zmaterializowane (migawki)
│   ├── 06_tests.sql               -- Zapytania testowe
│   ├── kursySiedziba.sql          -- Skrypt źródłowy - dane siedziby
│   └── kursyFilia.sql             -- Skrypt źródłowy - dane filii
└── screenshots/                   -- Screenshoty z Oracle SQL Developer
```
