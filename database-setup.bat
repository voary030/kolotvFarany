@echo off
REM ========================================
REM SETUP BASE DE DONNEES ORACLE - KOLOTV
REM ========================================

echo.
echo ========================================
echo VERIFICATION DU CONTENEUR ORACLE
echo ========================================
echo.

REM Verifier que le conteneur existe
docker inspect kolotv-db >nul 2>&1
if errorlevel 1 (
    echo ERREUR : Le conteneur kolotv-db n'existe pas.
    echo Lancez d'abord : docker-compose up -d
    pause
    exit /b 1
)

REM Verifier que le conteneur est en cours d'execution
docker inspect -f "{{.State.Running}}" kolotv-db 2>nul | findstr "true" >nul
if errorlevel 1 (
    echo ERREUR : Le conteneur kolotv-db n'est pas demarre.
    echo Lancez : docker-compose up -d
    pause
    exit /b 1
)

echo Conteneur kolotv-db en cours d'execution.
echo.
echo Attente du demarrage complet d'Oracle (healthcheck)...
echo Cela peut prendre jusqu'a 2 minutes...

REM Attendre que le healthcheck soit "healthy"
set /a timeout=120
:wait_healthy
docker inspect --format="{{.State.Health.Status}}" kolotv-db 2>nul | findstr "healthy" >nul
if not errorlevel 1 goto :healthy

timeout /t 5 /nobreak >nul
set /a timeout-=5
if %timeout% gtr 0 (
    echo Attente... (%timeout% secondes restantes^)
    goto :wait_healthy
)

echo AVERTISSEMENT : Le healthcheck n'est pas "healthy" apres 2 minutes.
echo Tentative de connexion quand meme...

:healthy
echo Oracle est pret !

echo.
echo ========================================
echo CREATION D'UTILISATEUR ORACLE
echo ========================================
echo.

REM Creer un fichier SQL temporaire pour la creation d'utilisateur
echo CREATE USER kolo0107 IDENTIFIED BY kolo0107; > %TEMP%\create_user.sql
echo ALTER USER kolo0107 DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp QUOTA UNLIMITED ON users; >> %TEMP%\create_user.sql
echo GRANT CONNECT, RESOURCE TO kolo0107; >> %TEMP%\create_user.sql
echo GRANT DBA TO kolo0107; >> %TEMP%\create_user.sql
echo EXIT; >> %TEMP%\create_user.sql

REM Copier le fichier SQL dans le conteneur
docker cp %TEMP%\create_user.sql kolotv-db:/tmp/create_user.sql

REM Executer les commandes SQL - connexion locale depuis le conteneur
echo Creation de l'utilisateur kolo0107...
docker exec -i kolotv-db bash -c "export ORACLE_SID=EE && sqlplus -S system/oracle < /tmp/create_user.sql"

if errorlevel 1 (
    echo ERREUR : Echec de la creation de l'utilisateur
    del %TEMP%\create_user.sql >nul 2>&1
    pause
    exit /b 1
)

REM Nettoyer les fichiers temporaires
del %TEMP%\create_user.sql >nul 2>&1
docker exec -i kolotv-db rm -f /tmp/create_user.sql >nul 2>&1

echo Utilisateur cree avec succes.

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
echo CONFIGURATION DU REPERTOIRE DE DUMP
echo ========================================
echo.

REM Creer un fichier SQL temporaire pour la configuration du repertoire dump
echo CREATE OR REPLACE DIRECTORY dump_dir AS '/opt/oracle/dump'; > %TEMP%\create_dump_dir.sql
echo GRANT READ, WRITE ON DIRECTORY dump_dir TO kolo0107; >> %TEMP%\create_dump_dir.sql
echo EXIT; >> %TEMP%\create_dump_dir.sql

REM Copier et executer le fichier SQL
docker cp %TEMP%\create_dump_dir.sql kolotv-db:/tmp/create_dump_dir.sql
echo Configuration du repertoire dump...
docker exec -i kolotv-db bash -c "export ORACLE_SID=EE && sqlplus -S system/oracle < /tmp/create_dump_dir.sql"

if errorlevel 1 (
    echo ERREUR : Echec de la configuration du repertoire dump
    del %TEMP%\create_dump_dir.sql >nul 2>&1
    pause
    exit /b 1
)

REM Nettoyer
del %TEMP%\create_dump_dir.sql >nul 2>&1
docker exec -i kolotv-db rm -f /tmp/create_dump_dir.sql >nul 2>&1

echo Repertoire dump configure avec succes.


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

REM Creer un fichier SQL temporaire pour la verification
echo SELECT username, account_status FROM dba_users WHERE username = 'KOLO0107'; > %TEMP%\verify_user.sql
echo EXIT; >> %TEMP%\verify_user.sql

REM Verifier que l'utilisateur kolo0107 a bien ete cree
docker cp %TEMP%\verify_user.sql kolotv-db:/tmp/verify_user.sql
echo Verification de l'utilisateur...
docker exec -i kolotv-db bash -c "export ORACLE_SID=EE && sqlplus -S system/oracle < /tmp/verify_user.sql"

REM Nettoyer
del %TEMP%\verify_user.sql >nul 2>&1
docker exec -i kolotv-db rm -f /tmp/verify_user.sql >nul 2>&1

echo.
echo Setup de la base de donnees termine avec succes !
echo.
pause
