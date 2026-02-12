-- Active: 1770279145043@@127.0.0.1@1521@EE.oracle.docker@KOLO0107
-- Script de création de la table HEUREDEPOINTE
-- Permet de configurer les heures de pointe avec majoration de prix
-- Date: 05/02/2026

-- Création de la séquence
CREATE SEQUENCE SEQ_HEUREDEPOINTE START
WITH
    1 INCREMENT BY 1 NOCACHE;

-- Fonction pour générer l'ID
CREATE OR REPLACE FUNCTION GETSEQ_HEUREDEPOINTE RETURN VARCHAR2 IS 
BEGIN
    RETURN SEQ_HEUREDEPOINTE.NEXTVAL;
END;
/

-- Création de la table HEUREDEPOINTE
CREATE TABLE HEUREDEPOINTE (
    ID VARCHAR2 (50) PRIMARY KEY,
    HEUREDEBUT VARCHAR2 (20) NOT NULL,
    HEUREFIN VARCHAR2 (20) NOT NULL,
    JOURSEMAINE VARCHAR2 (20) NOT NULL, -- LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE
    POURCENTAGEMAJORATION NUMBER (10, 2) DEFAULT 0,
    IDSUPPORT VARCHAR2 (50),
    ETAT NUMBER (10) DEFAULT 1,
    DATY DATE DEFAULT SYSDATE,
    CONSTRAINT FK_HEUREDEPOINTE_SUPPORT FOREIGN KEY (IDSUPPORT) REFERENCES SUPPORT (ID)
);

-- Commentaires sur les colonnes
COMMENT ON COLUMN HEUREDEPOINTE.ID IS 'Identifiant unique de la configuration d''heure de pointe';

COMMENT ON COLUMN HEUREDEPOINTE.HEUREDEBUT IS 'Heure de début de la plage horaire (format HH:MI:SS)';

COMMENT ON COLUMN HEUREDEPOINTE.HEUREFIN IS 'Heure de fin de la plage horaire (format HH:MI:SS)';

COMMENT ON COLUMN HEUREDEPOINTE.JOURSEMAINE IS 'Jour de la semaine (LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE)';

COMMENT ON COLUMN HEUREDEPOINTE.POURCENTAGEMAJORATION IS 'Pourcentage de majoration à appliquer (ex: 10 pour 10%)';

COMMENT ON COLUMN HEUREDEPOINTE.IDSUPPORT IS 'Support concerné (optionnel, NULL = tous les supports)';

COMMENT ON COLUMN HEUREDEPOINTE.ETAT IS 'État de la configuration (1=actif, 0=inactif)';

-- Création de la vue HEUREDEPOINTECPL pour l'affichage
CREATE OR REPLACE VIEW HEUREDEPOINTECPL AS
SELECT
    h.ID,
    h.HEUREDEBUT,
    h.HEUREFIN,
    h.JOURSEMAINE,
    h.POURCENTAGEMAJORATION,
    h.IDSUPPORT,
    s.VAL AS IDSUPPORTLIB,
    h.ETAT,
    h.DATY,
    CASE
        WHEN h.ETAT = 0 THEN 'Inactif'
        WHEN h.ETAT = 1 THEN 'Actif'
    END AS ETATLIB
FROM HEUREDEPOINTE h
    LEFT JOIN SUPPORT s ON s.ID = h.IDSUPPORT;

-- Insertion de quelques exemples de configuration
-- Exemple: Lundi de 8h à 9h avec 10% de majoration
INSERT INTO
    HEUREDEPOINTE (
        ID,
        HEUREDEBUT,
        HEUREFIN,
        JOURSEMAINE,
        POURCENTAGEMAJORATION,
        IDSUPPORT,
        ETAT
    )
VALUES (
        'HDP' || GETSEQ_HEUREDEPOINTE (),
        '08:00:00',
        '09:00:00',
        'LUNDI',
        10,
        NULL,
        1
    );

-- Exemple: Vendredi de 18h à 20h avec 15% de majoration
INSERT INTO
    HEUREDEPOINTE (
        ID,
        HEUREDEBUT,
        HEUREFIN,
        JOURSEMAINE,
        POURCENTAGEMAJORATION,
        IDSUPPORT,
        ETAT
    )
VALUES (
        'HDP' || GETSEQ_HEUREDEPOINTE (),
        '18:00:00',
        '20:00:00',
        'VENDREDI',
        15,
        NULL,
        1
    );

-- Exemple: Samedi de 20h à 22h avec 20% de majoration
INSERT INTO
    HEUREDEPOINTE (
        ID,
        HEUREDEBUT,
        HEUREFIN,
        JOURSEMAINE,
        POURCENTAGEMAJORATION,
        IDSUPPORT,
        ETAT
    )
VALUES (
        'HDP' || GETSEQ_HEUREDEPOINTE (),
        '20:00:00',
        '22:00:00',
        'SAMEDI',
        20,
        NULL,
        1
    );

COMMIT;