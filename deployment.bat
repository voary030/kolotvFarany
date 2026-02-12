@echo off
REM ========================================
REM DEPLOIEMENT KOLOTV - WILDFLY
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo PREPARATION DU FICHIER WAR
echo ========================================
echo.

REM Verifier que le fichier WAR existe
if not exist "deployments\kolotv.war" (
    echo ERREUR : Fichier deployments\kolotv.war non trouve !
    pause
    exit /b 1
)

REM Copier le fichier WAR de l'application KoloTV depuis le repertoire local
REM vers le conteneur Docker dans le repertoire de deploiement de Wildfly
echo Copie du fichier WAR vers le conteneur...
docker cp deployments\kolotv.war kolotv-wildfly:/opt/wildfly/standalone/deployments/

if errorlevel 1 (
    echo ERREUR : Impossible de copier le fichier WAR
    pause
    exit /b 1
)

echo Copie reussie !

REM Attendre quelques secondes pour s'assurer que la copie est complete
echo Attente de completion de la copie...
timeout /t 3 /nobreak

echo.
echo ========================================
echo PRETRAITEMENT - RETRAIT ANCIENNE VERSION
echo ========================================
echo.

REM Verifier si une ancienne version est deployee et la retirer
echo Verification et retrait de l'ancienne version...
docker exec -i kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="undeploy kolotv.war" >nul 2>&1

REM Attendre un peu avant le nouveau deploiement
timeout /t 2 /nobreak

echo.
echo ========================================
echo DEPLOIEMENT DE L'APPLICATION
echo ========================================
echo.

REM Deployer l'application WAR via la CLI JBoss
REM -i : mode non-interactif pour eviter les problemes de timeout
REM --connect : se connecter au serveur Wildfly
REM deploy : commande de deploiement de l'application
REM --force : force le remplacement si le fichier existe deja
echo Deploiement de l'application en cours...
docker exec -i kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="deploy /opt/wildfly/standalone/deployments/kolotv.war --force"

if errorlevel 1 (
    echo ATTENTION : Verification de l'etat du deploiement requise
) else (
    echo Deploiement reussi !
)

echo.
echo ========================================
echo OPTIONS SUPPLEMENTAIRES
echo ========================================
echo.
echo Pour RETIRER l'application (si necessaire), executez :
echo docker exec kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="undeploy kolotv.war"
echo.

REM Menu d'options
echo.
echo Choisissez une action :
echo 1. Retirer/redéployer l'application
echo 2. Verifier l'etat de deploiement
echo 3. Quitter
echo.
set /p choice="Entrez votre choix (1/2/3) : "

if "%choice%"=="1" (
    echo.
    echo Retrait de l'ancienne version...
    docker exec -i kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="undeploy kolotv.war" 2>nul
    timeout /t 2 /nobreak
    echo Deploiement de la nouvelle version...
    docker exec -i kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="deploy /opt/wildfly/standalone/deployments/kolotv.war --force"
    echo Application redéployée avec succès !
    pause
)

if "%choice%"=="2" (
    echo.
    echo Verification de l'etat du conteneur Wildfly...
    docker exec kolotv-wildfly /opt/wildfly/bin/jboss-cli.sh --connect --command="ls deployment"
    pause
)

echo.
echo Deploiement termine !
echo.
pause
