@echo off
REM ========================================
REM SETUP BASE DE DONNEES ORACLE - KOLOTV
REM ========================================

echo.
echo ========================================
echo CREATION D'UTILISATEUR ORACLE
echo ========================================
echo.

REM Executer les commandes SQL pour creer l'utilisateur kolo0107
REM Utiliser le compte administrateur Oracle : system/oracle (depuis docker-compose.yml)
docker exec -i kolotv-db sqlplus -S system/oracle@localhost:1521/EE.oracle.docker << EOF

-- Creer un nouvel utilisateur Oracle avec mot de passe "kolo0107"
CREATE USER kolo0107 IDENTIFIED BY kolo0107;

-- Configurer l'espace disque par defaut (tablespace) et l'espace temporaire
-- users : tablespace par defaut pour les donnees
-- temp : tablespace temporaire pour les operations de tri
-- QUOTA UNLIMITED : pas de limite de stockage
ALTER USER kolo0107 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp QUOTA UNLIMITED ON users;

-- Accorder les privileges CONNECT (connexion) et RESOURCE (creation d'objets)
GRANT CONNECT, RESOURCE TO kolo0107;

-- Accorder les privileges DBA (administrateur de base de donnees)
GRANT DBA TO kolo0107;

EXIT;
EOF

echo.
echo ========================================
echo CONFIGURATION DU REPERTOIRE DE DUMP
echo ========================================
echo.

REM Creer le repertoire pour les dumps via Docker
docker exec -i kolotv-db sqlplus -S system/oracle@localhost:1521/EE.oracle.docker << EOF

-- Creer un repertoire logique pour stocker les fichiers d'export/import
CREATE DIRECTORY dump_dir AS '/opt/oracle/dump';

-- Autoriser l'utilisateur kolo0107 a lire et ecrire dans le repertoire
GRANT READ, WRITE ON DIRECTORY dump_dir TO kolo0107;

EXIT;
EOF

echo.
echo ========================================
echo GESTION DES PERMISSIONS SYSTEME
echo ========================================
echo.

REM Creer le repertoire dump s'il n'existe pas
echo Creation du repertoire dump s'il n'existe pas...
docker exec -i kolotv-db mkdir -p /opt/oracle/dump

REM Change proprietaire du repertoire dump vers oracle:oinstall
docker exec -it kolotv-db chown -R oracle:oinstall /opt/oracle/dump

REM Change les permissions du repertoire (755)
docker exec -it kolotv-db chmod -R 775 /opt/oracle/dump

echo.
echo ========================================
echo IMPORT DES DONNEES
echo ========================================
echo.

REM Copier le fichier dump depuis le local vers le conteneur Docker
echo Copie du fichier dump en cours...
docker cp bdd\dmp\export_20260122.dmp kolotv-db:/opt/oracle/dump/export.dmp

if errorlevel 1 (
    echo ERREUR : Impossible de copier le fichier dump
    pause
    exit /b 1
)

echo Copie reussie. Import des donnees en cours...

REM Importer les donnees depuis le fichier dump
REM FILE : chemin du fichier dump a importer
REM LOG : fichier journal pour tracer les erreurs/succes
REM FULL=Y : importer la base de donnees complete
docker exec -i kolotv-db imp kolo0107/kolo0107 ^
FILE=/opt/oracle/dump/export.dmp ^
LOG=/opt/oracle/dump/import5.log ^
FULL=Y

if errorlevel 1 (
    echo ERREUR : Echec de l'import des donnees
    pause
    exit /b 1
)

echo.
echo ========================================
echo VERIFICATION
echo ========================================
echo.

REM Verifier que l'utilisateur kolo0107 a bien ete cree
docker exec -i kolotv-db sqlplus -S system/oracle@localhost:1521/EE.oracle.docker << EOF

SELECT username, account_status FROM dba_users WHERE username = 'KOLO0107';

EXIT;
EOF

echo.
echo Setup de la base de donnees termine avec succes !
echo.
pause
