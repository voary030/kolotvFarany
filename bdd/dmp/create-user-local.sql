-- Script pour créer l'utilisateur kolotv dans Oracle local avec TOUS les privilèges
-- Exécuter avec: sqlplus system/[votre_mot_de_passe]@ORCL @create-user-local.sql

-- Supprimer l'utilisateur s'il existe déjà
DROP USER kolotv CASCADE;

-- Créer l'utilisateur
CREATE USER kolotv IDENTIFIED BY kolotv 
  DEFAULT TABLESPACE users 
  TEMPORARY TABLESPACE temp 
  QUOTA UNLIMITED ON users;

-- Accorder TOUS les privilèges système
GRANT ALL PRIVILEGES TO kolotv;

-- Accorder le rôle DBA (inclut presque tous les privilèges)
GRANT DBA TO kolotv WITH ADMIN OPTION;

-- Accorder les rôles standards
GRANT CONNECT, RESOURCE TO kolotv WITH ADMIN OPTION;

-- Privilèges spécifiques pour les objets
GRANT CREATE SESSION TO kolotv;
GRANT CREATE TABLE TO kolotv;
GRANT CREATE VIEW TO kolotv;
GRANT CREATE SEQUENCE TO kolotv;
GRANT CREATE PROCEDURE TO kolotv;
GRANT CREATE TRIGGER TO kolotv;
GRANT CREATE TYPE TO kolotv;
GRANT CREATE SYNONYM TO kolotv;
GRANT CREATE DATABASE LINK TO kolotv;
GRANT CREATE MATERIALIZED VIEW TO kolotv;
GRANT CREATE JOB TO kolotv;
GRANT CREATE ANY TABLE TO kolotv;
GRANT CREATE ANY VIEW TO kolotv;
GRANT CREATE ANY SEQUENCE TO kolotv;
GRANT CREATE ANY PROCEDURE TO kolotv;
GRANT CREATE ANY TRIGGER TO kolotv;
GRANT CREATE ANY TYPE TO kolotv;
GRANT CREATE ANY SYNONYM TO kolotv;

-- Privilèges de modification
GRANT ALTER ANY TABLE TO kolotv;
GRANT ALTER ANY VIEW TO kolotv;
GRANT ALTER ANY SEQUENCE TO kolotv;
GRANT ALTER ANY PROCEDURE TO kolotv;
GRANT ALTER ANY TRIGGER TO kolotv;

-- Privilèges de suppression
GRANT DROP ANY TABLE TO kolotv;
GRANT DROP ANY VIEW TO kolotv;
GRANT DROP ANY SEQUENCE TO kolotv;
GRANT DROP ANY PROCEDURE TO kolotv;
GRANT DROP ANY TRIGGER TO kolotv;

-- Privilèges de sélection/insertion/mise à jour/suppression
GRANT SELECT ANY TABLE TO kolotv;
GRANT INSERT ANY TABLE TO kolotv;
GRANT UPDATE ANY TABLE TO kolotv;
GRANT DELETE ANY TABLE TO kolotv;

-- Privilèges d'exécution
GRANT EXECUTE ANY PROCEDURE TO kolotv;
GRANT EXECUTE ANY TYPE TO kolotv;

-- Privilèges de gestion
GRANT ALTER SYSTEM TO kolotv;
GRANT ALTER SESSION TO kolotv;
GRANT ANALYZE ANY TO kolotv;
GRANT AUDIT ANY TO kolotv;
GRANT COMMENT ANY TABLE TO kolotv;
GRANT GRANT ANY PRIVILEGE TO kolotv;
GRANT GRANT ANY ROLE TO kolotv;

-- Privilèges sur les tablespaces
GRANT UNLIMITED TABLESPACE TO kolotv;

-- Vérifier
SELECT username, account_status FROM dba_users WHERE username = 'kolotv';
SELECT * FROM dba_sys_privs WHERE grantee = 'kolotv' ORDER BY privilege;

