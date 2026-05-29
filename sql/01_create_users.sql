-- ============================================================
-- 01_create_users.sql
-- Wykonać jako SYS z rolą SYSDBA
-- Tworzy użytkowników SIEDZIBA i FILIA symulujących dwie bazy
-- ============================================================

ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

-- Tworzenie użytkowników
CREATE USER siedziba IDENTIFIED BY start123;
CREATE USER filia    IDENTIFIED BY start123;

-- Uprawnienia podstawowe
GRANT CONNECT, RESOURCE TO siedziba;
GRANT CONNECT, RESOURCE TO filia;

-- Uprawnienia dla SIEDZIBA do pracy z rozproszonymi obiektami
GRANT CREATE DATABASE LINK     TO siedziba;
GRANT CREATE SYNONYM           TO siedziba;
GRANT CREATE VIEW              TO siedziba;
GRANT CREATE MATERIALIZED VIEW TO siedziba;

-- Quota na przestrzeń tabel
ALTER USER siedziba QUOTA UNLIMITED ON USERS;
ALTER USER filia    QUOTA UNLIMITED ON USERS;
