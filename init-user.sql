-- ========================================
-- SCRIPT D'INITIALISATION UTILISATEUR KOLOTV
-- ========================================

-- Créer l'utilisateur kolo0107 pour l'application KoloTV
-- IDENTIFIED BY : définit le mot de passe (kolo0107)
-- DEFAULT TABLESPACE : lieu de stockage des données par défaut
-- TEMPORARY TABLESPACE : lieu de stockage pour les opérations temporaires (tri, tri...)
-- QUOTA UNLIMITED ON users : pas de limite de stockage sur le tablespace "users"
CREATE USER kolo0107 IDENTIFIED BY kolo0107 
  DEFAULT TABLESPACE users 
  TEMPORARY TABLESPACE temp 
  QUOTA UNLIMITED ON users;

-- Accorder les privilèges de connexion et de création d'objets
-- CONNECT : permet à l'utilisateur de se connecter à la base de données
-- RESOURCE : permet de créer et gérer des objets (tables, index, etc.)
GRANT CONNECT, RESOURCE TO kolo0107;

-- Accorder tous les privilèges d'administrateur
-- DBA : accès complet à la base de données
GRANT DBA TO kolo0107;

-- Accorder explicitement le droit de création de session
-- (généralement déjà inclus dans CONNECT, mais explicite pour être sûr)
GRANT CREATE SESSION TO kolo0107;

-- Accorder l'espace disque illimité (sur tous les tablespaces)
-- Permet à l'utilisateur de créer et stocker autant de données que nécessaire
GRANT UNLIMITED TABLESPACE TO kolo0107;

-- ========================================
-- CRÉATION DU RÉPERTOIRE POUR LES EXPORTS/IMPORTS
-- ========================================

-- Créer un répertoire logique Oracle appelé "dump_dir"
-- Pointe vers le chemin système '/opt/oracle/dump'
-- Utilisé pour les opérations d'import/export de données
CREATE DIRECTORY dump_dir AS '/opt/oracle/dump';

-- Accorder à l'utilisateur kolo0107 les droits de lecture et écriture sur ce répertoire
-- READ : peut lire les fichiers dans le répertoire
-- WRITE : peut créer/modifier les fichiers dans le répertoire
GRANT READ, WRITE ON DIRECTORY dump_dir TO kolo0107;

-- ========================================
-- VÉRIFICATION
-- ========================================

-- Vérifier que l'utilisateur kolo0107 a bien été créé
-- Affiche le nom d'utilisateur et son statut (devrait être "OPEN")
SELECT username, account_status FROM dba_users WHERE username = 'KOLO0107';

-- Quitter le script SQL
EXIT;
