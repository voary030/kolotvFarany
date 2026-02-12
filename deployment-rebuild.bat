@echo off
REM ========================================
REM DEPLOIEMENT KOLOTV - RECONSTRUCTION
REM ========================================

echo.
echo ========================================
echo VERIFICATION DU FICHIER WAR
echo ========================================
echo.

if not exist "deployments\kolotv.war" (
    echo ERREUR : Fichier deployments\kolotv.war non trouve !
    pause
    exit /b 1
)

echo Fichier WAR trouve : deployments\kolotv.war

echo.
echo ========================================
echo ARRET ET SUPPRESSION DU CONTENEUR
echo ========================================
echo.

echo Arret et suppression des conteneurs existants...
docker-compose down

if errorlevel 1 (
    echo AVERTISSEMENT : Erreur lors de l'arret des conteneurs
)

echo.
echo ========================================
echo RECONSTRUCTION ET DEMARRAGE
echo ========================================
echo.

echo Reconstruction de l'image et demarrage des conteneurs...
docker-compose up -d --build

if errorlevel 1 (
    echo ERREUR : Impossible de reconstruire et demarrer les conteneurs
    pause
    exit /b 1
)

echo.
echo Conteneurs demarres. Attente du demarrage complet de WildFly...
timeout /t 45 /nobreak

echo.
echo ========================================
echo VERIFICATION DU DEPLOIEMENT
echo ========================================
echo.

REM Verifier que le conteneur est en cours d'execution
docker inspect -f "{{.State.Running}}" kolotv-wildfly 2>nul | findstr "true" >nul
if errorlevel 1 (
    echo [ERREUR] Le conteneur kolotv-wildfly n'est pas demarre !
    echo Consultez les logs : docker logs kolotv-wildfly
    pause
    exit /b 1
)

echo [OK] Conteneur kolotv-wildfly en cours d'execution

REM Verifier le deploiement via les markers
docker exec kolotv-wildfly sh -c "test -f /opt/wildfly/standalone/deployments/kolotv.war.deployed" >nul 2>&1
if not errorlevel 1 (
    echo [OK] Application kolotv.war deployee avec succes !
    echo.
    echo L'application est accessible sur : http://localhost:8080/kolotv
    goto :end
)

docker exec kolotv-wildfly sh -c "test -f /opt/wildfly/standalone/deployments/kolotv.war.failed" >nul 2>&1
if not errorlevel 1 (
    echo [ERREUR] Le deploiement a echoue !
    echo.
    echo Consultez les logs pour plus de details :
    echo docker logs kolotv-wildfly --tail 100
    echo.
    set /p viewlogs="Voulez-vous voir les logs maintenant ? (O/N) : "
    if /i "%viewlogs%"=="O" (
        docker logs kolotv-wildfly --tail 100
    )
    goto :end
)

echo [INFO] Deploiement en cours ou etat inconnu
echo.
echo Verification des markers :
docker exec kolotv-wildfly ls -la /opt/wildfly/standalone/deployments/kolotv.war* 2>nul
echo.
echo Logs recents :
docker logs kolotv-wildfly --tail 30

:end
echo.
echo ========================================
echo DEPLOIEMENT TERMINE
echo ========================================
echo.
pause
