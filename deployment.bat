@echo off
REM ========================================
REM DEPLOIEMENT KOLOTV - WILDFLY
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo VERIFICATION DU CONTENEUR
echo ========================================
echo.

REM Verifier que le fichier WAR existe
if not exist "deployments\kolotv.war" (
    echo ERREUR : Fichier deployments\kolotv.war non trouve !
    pause
    exit /b 1
)

REM Verifier si le conteneur existe
docker inspect kolotv-wildfly >nul 2>&1
if errorlevel 1 (
    echo ERREUR : Le conteneur kolotv-wildfly n'existe pas.
    echo Lancez d'abord : docker-compose up -d
    pause
    exit /b 1
)

REM Verifier si le conteneur est en cours d'execution
docker inspect -f "{{.State.Running}}" kolotv-wildfly 2>nul | findstr "true" >nul
if errorlevel 1 (
    echo Le conteneur kolotv-wildfly est arrete. Demarrage en cours...
    docker start kolotv-wildfly
    if errorlevel 1 (
        echo ERREUR : Impossible de demarrer le conteneur.
        pause
        exit /b 1
    )
    echo Conteneur demarre. Attente du demarrage de WildFly...
    timeout /t 15 /nobreak
) else (
    echo Conteneur kolotv-wildfly en cours d'execution.
)

echo.
echo ========================================
echo NETTOYAGE ANCIEN DEPLOIEMENT
echo ========================================
echo.

REM Arreter WildFly proprement pour eviter les conflits de deploiement
echo Arret de WildFly pour nettoyage...
docker exec -i kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="shutdown" >nul 2>&1
timeout /t 5 /nobreak

REM Supprimer les anciens fichiers de deploiement et markers pour eviter "Duplicate resource"
echo Nettoyage des anciens fichiers de deploiement...
docker exec kolotv-wildfly rm -f /opt/wildfly/standalone/deployments/kolotv.war >nul 2>&1
docker exec kolotv-wildfly rm -f /opt/wildfly/standalone/deployments/kolotv.war.deployed >nul 2>&1
docker exec kolotv-wildfly rm -f /opt/wildfly/standalone/deployments/kolotv.war.failed >nul 2>&1
docker exec kolotv-wildfly rm -f /opt/wildfly/standalone/deployments/kolotv.war.dodeploy >nul 2>&1
docker exec kolotv-wildfly rm -f /opt/wildfly/standalone/deployments/kolotv.war.undeployed >nul 2>&1
docker exec kolotv-wildfly rm -f /opt/wildfly/standalone/deployments/kolotv.war.isdeploying >nul 2>&1

REM Nettoyer aussi le cache de donnees standalone pour eviter les references orphelines
docker exec kolotv-wildfly rm -rf /opt/wildfly/standalone/data/content >nul 2>&1
docker exec kolotv-wildfly mkdir -p /opt/wildfly/standalone/data/content >nul 2>&1

REM Nettoyer le fichier standalone.xml pour supprimer la reference au deploiement
echo Nettoyage du fichier de configuration standalone.xml...
docker exec kolotv-wildfly sed -i '/<deployment name="kolotv.war"/,/<\/deployment>/d' /opt/wildfly/standalone/configuration/standalone.xml >nul 2>&1

echo Nettoyage termine.

echo.
echo ========================================
echo COPIE DU NOUVEAU WAR
echo ========================================
echo.

REM Copier le nouveau fichier WAR
echo Copie du fichier WAR vers le conteneur...
docker cp deployments\kolotv.war kolotv-wildfly:/opt/wildfly/standalone/deployments/

if errorlevel 1 (
    echo ERREUR : Impossible de copier le fichier WAR
    pause
    exit /b 1
)

echo Copie reussie !

REM Creer le marker .dodeploy pour que le deployment scanner prenne en charge le deploiement
docker exec kolotv-wildfly sh -c "touch /opt/wildfly/standalone/deployments/kolotv.war.dodeploy"
echo Marker de deploiement cree.

echo.
echo ========================================
echo REDEMARRAGE DE WILDFLY
echo ========================================
echo.

REM Redemarrer le conteneur pour demarrer WildFly proprement
echo Redemarrage du conteneur...
docker restart kolotv-wildfly

if errorlevel 1 (
    echo ERREUR : Impossible de redemarrer le conteneur
    pause
    exit /b 1
)

REM Attendre que WildFly demarre completement
echo Attente du demarrage de WildFly (30 secondes)...
timeout /t 30 /nobreak

echo.
echo ========================================
echo VERIFICATION DU DEPLOIEMENT
echo ========================================
echo.

REM Verifier si le deploiement a reussi via les markers
docker exec kolotv-wildfly sh -c "test -f /opt/wildfly/standalone/deployments/kolotv.war.deployed" >nul 2>&1
if not errorlevel 1 (
    echo [OK] Application kolotv.war deployee avec succes !
    goto :menu
)

docker exec kolotv-wildfly sh -c "test -f /opt/wildfly/standalone/deployments/kolotv.war.failed" >nul 2>&1
if not errorlevel 1 (
    echo [ERREUR] Le deploiement a echoue. Consultez les logs :
    echo docker logs kolotv-wildfly --tail 50
    goto :menu
)

echo [INFO] Deploiement en cours ou etat inconnu. Verifiez les logs :
echo docker logs kolotv-wildfly --tail 50

:menu
echo.
echo ========================================
echo OPTIONS
echo ========================================
echo.
echo 1. Voir les logs WildFly
echo 2. Verifier l'etat de deploiement
echo 3. Quitter
echo.
set /p choice="Entrez votre choix (1/2/3) : "

if "%choice%"=="1" (
    echo.
    docker logs kolotv-wildfly --tail 80
    pause
    goto :menu
)

if "%choice%"=="2" (
    echo.
    echo Verification des markers de deploiement...
    docker exec kolotv-wildfly ls -la /opt/wildfly/standalone/deployments/kolotv.war*
    echo.
    echo Verification via CLI...
    docker exec -i kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="ls deployment" 2>nul
    pause
    goto :menu
)

echo.
echo Deploiement termine !
echo.
pause
