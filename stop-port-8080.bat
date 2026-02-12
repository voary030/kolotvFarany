@echo off
REM ========================================
REM ARRETER LE PROCESSUS SUR LE PORT 8080
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo RECHERCHE DU PROCESSUS SUR LE PORT 8080
echo ========================================
echo.

REM Rechercher le processus qui utilise le port 8080
REM netstat : affiche les connexions reseau actives
REM -ano : affiche adresse, port, numero de processus
REM findstr :8080 : filtre pour ne voir que le port 8080
echo Recherche en cours...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
    set "PID=%%a"
)

if not defined PID (
    echo.
    echo AUCUN PROCESSUS n'utilise le port 8080
    echo.
    pause
    exit /b 0
)

echo.
echo Processus trouve avec le PID : !PID!
echo.

REM Afficher les infos du processus
echo ========================================
echo INFORMATIONS DU PROCESSUS
echo ========================================
echo.

tasklist /FI "PID eq !PID!"

echo.
echo ========================================
echo CONFIRMATION
echo ========================================
echo.

set /p confirm="Voulez-vous arreter ce processus ? (O/N) : "

if /i "%confirm%"=="O" (
    echo.
    echo Arrêt du processus en cours...
    taskkill /PID !PID! /F
    
    if errorlevel 1 (
        echo.
        echo ERREUR : Impossible d'arreter le processus
        echo Vous devez peut-etre executer ce script en tant qu'administrateur
        pause
        exit /b 1
    )
    
    echo.
    echo Processus PID !PID! arrête avec succes !
    echo Le port 8080 est maintenant libre.
    echo.
) else (
    echo.
    echo Annule par l'utilisateur.
    echo.
)

pause
