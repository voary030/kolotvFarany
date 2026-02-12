package categorieheure;

import bean.CGenUtil;
import bean.ClassMAPTable;
import utils.CalendarUtil;

import java.sql.Connection;
import java.sql.Date;
import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Classe pour gérer les configurations des heures de pointe
 * Une heure de pointe permet d'appliquer une majoration en pourcentage
 * sur les réservations qui tombent dans cette plage horaire
 * 
 * @author rachriss
 * @date 05/02/2026
 */
public class HeureDePointe extends ClassMAPTable {

    private String id;
    private String heureDebut;
    private String heureFin;
    private String jourSemaine; // LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE
    private double pourcentageMajoration;
    private String idSupport;
    private int etat;
    private Date daty;

    // Jours de la semaine en français
    public static final String LUNDI = "LUNDI";
    public static final String MARDI = "MARDI";
    public static final String MERCREDI = "MERCREDI";
    public static final String JEUDI = "JEUDI";
    public static final String VENDREDI = "VENDREDI";
    public static final String SAMEDI = "SAMEDI";
    public static final String DIMANCHE = "DIMANCHE";

    public static final String[] JOURS_SEMAINE = {
            LUNDI, MARDI, MERCREDI, JEUDI, VENDREDI, SAMEDI, DIMANCHE
    };

    public HeureDePointe() {
        this.setNomTable("HEUREDEPOINTE");
    }

    public void construirePK(Connection c) throws Exception {
        this.preparePk("HDP", "GETSEQ_HEUREDEPOINTE");
        this.setId(makePK(c));
    }

    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    // ===================== GETTERS ET SETTERS =====================

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getHeureDebut() {
        return heureDebut;
    }

    public void setHeureDebut(String heureDebut) throws Exception {
        if (!CalendarUtil.isValidTime(heureDebut)) {
            throw new Exception("L'heure de début doit être au format HH:MM:SS");
        }
        this.heureDebut = heureDebut;
    }

    public String getHeureFin() {
        return heureFin;
    }

    public void setHeureFin(String heureFin) throws Exception {
        if (!CalendarUtil.isValidTime(heureFin)) {
            throw new Exception("L'heure de fin doit être au format HH:MM:SS");
        }
        this.heureFin = heureFin;
    }

    public String getJourSemaine() {
        return jourSemaine;
    }

    public void setJourSemaine(String jourSemaine) {
        this.jourSemaine = jourSemaine;
    }

    public double getPourcentageMajoration() {
        return pourcentageMajoration;
    }

    public void setPourcentageMajoration(double pourcentageMajoration) {
        this.pourcentageMajoration = pourcentageMajoration;
    }

    public String getIdSupport() {
        return idSupport;
    }

    public void setIdSupport(String idSupport) {
        this.idSupport = idSupport;
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    // ===================== MÉTHODES MÉTIER =====================

    /**
     * Normalise une heure au format HH:mm:ss
     * Accepte les formats HH:mm et HH:mm:ss
     */
    public static String normaliserHeure(String heure) {
        if (heure == null || heure.isEmpty()) {
            return "00:00:00";
        }
        heure = heure.trim();
        // Si format HH:mm, ajouter :00
        if (heure.matches("^\\d{2}:\\d{2}$")) {
            return heure + ":00";
        }
        // Si format HH:mm:ss, retourner tel quel
        if (heure.matches("^\\d{2}:\\d{2}:\\d{2}$")) {
            return heure;
        }
        // Sinon, essayer de parser et reformater
        try {
            LocalTime lt = LocalTime.parse(heure);
            return lt.format(DateTimeFormatter.ofPattern("HH:mm:ss"));
        } catch (Exception e) {
            return heure + ":00";
        }
    }

    /**
     * Convertit un DayOfWeek en nom de jour en français
     */
    public static String dayOfWeekToFrench(DayOfWeek day) {
        switch (day) {
            case MONDAY:
                return LUNDI;
            case TUESDAY:
                return MARDI;
            case WEDNESDAY:
                return MERCREDI;
            case THURSDAY:
                return JEUDI;
            case FRIDAY:
                return VENDREDI;
            case SATURDAY:
                return SAMEDI;
            case SUNDAY:
                return DIMANCHE;
            default:
                return null;
        }
    }

    /**
     * Récupère toutes les heures de pointe actives pour un jour et un support donné
     * 
     * @param jourSemaine Le jour de la semaine (LUNDI, MARDI, etc.)
     * @param idSupport   L'ID du support (peut être null pour tous les supports)
     * @param c           La connexion à la base de données
     * @return Liste des heures de pointe correspondantes
     */
    public static HeureDePointe[] getHeuresDePointe(String jourSemaine, String idSupport, Connection c)
            throws Exception {
        HeureDePointe search = new HeureDePointe();
        search.setJourSemaine(jourSemaine);
        search.setEtat(1); // Uniquement les configurations actives

        String condition = "";
        if (idSupport != null && !idSupport.isEmpty()) {
            condition = " AND (IDSUPPORT = '" + idSupport + "' OR IDSUPPORT IS NULL)";
        }

        return (HeureDePointe[]) CGenUtil.rechercher(search, null, null, c, condition);
    }

    /**
     * Récupère les heures de pointe pour une date donnée
     * 
     * @param date      La date pour laquelle chercher les heures de pointe
     * @param idSupport L'ID du support (peut être null)
     * @param c         La connexion
     * @return Liste des heures de pointe pour cette date
     */
    public static HeureDePointe[] getHeuresDePointePourDate(LocalDate date, String idSupport, Connection c)
            throws Exception {
        String jourSemaine = dayOfWeekToFrench(date.getDayOfWeek());
        return getHeuresDePointe(jourSemaine, idSupport, c);
    }

    /**
     * Calcule la majoration pour une réservation donnée
     * Prend en compte le chevauchement partiel entre la réservation et l'heure de
     * pointe
     * 
     * @param heureDebutResa           Heure de début de la réservation (format
     *                                 HH:MM:SS)
     * @param dureeReservationSecondes Durée de la réservation en secondes
     * @param montantBase              Montant de base de la réservation
     * @param dateResa                 Date de la réservation
     * @param idSupport                ID du support
     * @param c                        Connexion à la base de données
     * @return Montant de la majoration à appliquer
     */
    public static double calculerMajoration(String heureDebutResa, int dureeReservationSecondes,
            double montantBase, LocalDate dateResa, String idSupport, Connection c) throws Exception {

        HeureDePointe[] heuresDePointe = getHeuresDePointePourDate(dateResa, idSupport, c);

        if (heuresDePointe == null || heuresDePointe.length == 0) {
            return 0;
        }

        LocalTime debutResa = LocalTime.parse(normaliserHeure(heureDebutResa), DateTimeFormatter.ofPattern("HH:mm:ss"));
        LocalTime finResa = debutResa.plusSeconds(dureeReservationSecondes);

        double majorationTotale = 0;

        for (HeureDePointe hdp : heuresDePointe) {
            LocalTime debutPointe = LocalTime.parse(normaliserHeure(hdp.getHeureDebut()),
                    DateTimeFormatter.ofPattern("HH:mm:ss"));
            LocalTime finPointe = LocalTime.parse(normaliserHeure(hdp.getHeureFin()),
                    DateTimeFormatter.ofPattern("HH:mm:ss"));

            // Calcul de l'intersection entre la réservation et l'heure de pointe
            LocalTime debutIntersection = debutResa.isAfter(debutPointe) ? debutResa : debutPointe;
            LocalTime finIntersection = finResa.isBefore(finPointe) ? finResa : finPointe;

            // Vérifier s'il y a une intersection
            if (debutIntersection.isBefore(finIntersection) || debutIntersection.equals(finIntersection)) {
                // Durée de l'intersection en secondes
                long dureeIntersection = Duration.between(debutIntersection, finIntersection).getSeconds();

                if (dureeIntersection > 0 && dureeReservationSecondes > 0) {
                    // Proportion de la réservation dans l'heure de pointe
                    double proportion = (double) dureeIntersection / dureeReservationSecondes;

                    // Calcul de la majoration proportionnelle
                    double majorationPourCetteHeureDePointe = (montantBase * proportion)
                            * (hdp.getPourcentageMajoration() / 100.0);
                    majorationTotale += majorationPourCetteHeureDePointe;
                }
            }
        }

        return majorationTotale;
    }

    /**
     * Calcule le montant total avec majoration pour une réservation
     * 
     * @param heureDebutResa           Heure de début de la réservation
     * @param dureeReservationSecondes Durée en secondes
     * @param montantBase              Montant de base
     * @param dateResa                 Date de la réservation
     * @param idSupport                ID du support
     * @param c                        Connexion
     * @return Montant total (base + majoration)
     */
    public static double calculerMontantAvecMajoration(String heureDebutResa, int dureeReservationSecondes,
            double montantBase, LocalDate dateResa, String idSupport, Connection c) throws Exception {
        double majoration = calculerMajoration(heureDebutResa, dureeReservationSecondes, montantBase, dateResa,
                idSupport, c);
        return montantBase + majoration;
    }

    /**
     * Vérifie si une plage horaire est en heure de pointe
     * 
     * @param heureDebut Heure de début à vérifier
     * @param heureFin   Heure de fin à vérifier
     * @param dateResa   Date à vérifier
     * @param idSupport  ID du support
     * @param c          Connexion
     * @return true si la plage est en heure de pointe
     */
    public static boolean estEnHeureDePointe(String heureDebut, String heureFin,
            LocalDate dateResa, String idSupport, Connection c) throws Exception {

        HeureDePointe[] heuresDePointe = getHeuresDePointePourDate(dateResa, idSupport, c);

        if (heuresDePointe == null || heuresDePointe.length == 0) {
            return false;
        }

        LocalTime debut = LocalTime.parse(normaliserHeure(heureDebut), DateTimeFormatter.ofPattern("HH:mm:ss"));
        LocalTime fin = LocalTime.parse(normaliserHeure(heureFin), DateTimeFormatter.ofPattern("HH:mm:ss"));

        for (HeureDePointe hdp : heuresDePointe) {
            LocalTime debutPointe = LocalTime.parse(normaliserHeure(hdp.getHeureDebut()),
                    DateTimeFormatter.ofPattern("HH:mm:ss"));
            LocalTime finPointe = LocalTime.parse(normaliserHeure(hdp.getHeureFin()),
                    DateTimeFormatter.ofPattern("HH:mm:ss"));

            // Vérifie s'il y a une intersection
            if (!(fin.isBefore(debutPointe) || fin.equals(debutPointe) ||
                    debut.isAfter(finPointe) || debut.equals(finPointe))) {
                return true;
            }
        }

        return false;
    }

    /**
     * Récupère le détail de la majoration pour affichage
     * 
     * @param heureDebutResa           Heure de début de la réservation
     * @param dureeReservationSecondes Durée en secondes
     * @param montantBase              Montant de base
     * @param dateResa                 Date de la réservation
     * @param idSupport                ID du support
     * @param c                        Connexion
     * @return Détails de la majoration sous forme de liste
     */
    public static List<MajorationDetail> getDetailMajoration(String heureDebutResa, int dureeReservationSecondes,
            double montantBase, LocalDate dateResa, String idSupport, Connection c) throws Exception {

        List<MajorationDetail> details = new ArrayList<>();
        HeureDePointe[] heuresDePointe = getHeuresDePointePourDate(dateResa, idSupport, c);

        if (heuresDePointe == null || heuresDePointe.length == 0) {
            return details;
        }

        LocalTime debutResa = LocalTime.parse(normaliserHeure(heureDebutResa), DateTimeFormatter.ofPattern("HH:mm:ss"));
        LocalTime finResa = debutResa.plusSeconds(dureeReservationSecondes);

        for (HeureDePointe hdp : heuresDePointe) {
            LocalTime debutPointe = LocalTime.parse(normaliserHeure(hdp.getHeureDebut()),
                    DateTimeFormatter.ofPattern("HH:mm:ss"));
            LocalTime finPointe = LocalTime.parse(normaliserHeure(hdp.getHeureFin()),
                    DateTimeFormatter.ofPattern("HH:mm:ss"));

            LocalTime debutIntersection = debutResa.isAfter(debutPointe) ? debutResa : debutPointe;
            LocalTime finIntersection = finResa.isBefore(finPointe) ? finResa : finPointe;

            if (debutIntersection.isBefore(finIntersection) || debutIntersection.equals(finIntersection)) {
                long dureeIntersection = Duration.between(debutIntersection, finIntersection).getSeconds();

                if (dureeIntersection > 0 && dureeReservationSecondes > 0) {
                    double proportion = (double) dureeIntersection / dureeReservationSecondes;
                    double majorationMontant = (montantBase * proportion) * (hdp.getPourcentageMajoration() / 100.0);

                    MajorationDetail detail = new MajorationDetail();
                    detail.setHeureDePointe(hdp);
                    detail.setDureeIntersection(dureeIntersection);
                    detail.setProportion(proportion);
                    detail.setMontantMajoration(majorationMontant);
                    details.add(detail);
                }
            }
        }

        return details;
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        CalendarUtil.controlerHeureDebutEtFin(this.getHeureDebut(), this.getHeureFin(), null);
        return super.createObject(u, c);
    }

    /**
     * Classe interne pour stocker les détails d'une majoration
     */
    public static class MajorationDetail {
        private HeureDePointe heureDePointe;
        private long dureeIntersection;
        private double proportion;
        private double montantMajoration;

        public HeureDePointe getHeureDePointe() {
            return heureDePointe;
        }

        public void setHeureDePointe(HeureDePointe heureDePointe) {
            this.heureDePointe = heureDePointe;
        }

        public long getDureeIntersection() {
            return dureeIntersection;
        }

        public void setDureeIntersection(long dureeIntersection) {
            this.dureeIntersection = dureeIntersection;
        }

        public double getProportion() {
            return proportion;
        }

        public void setProportion(double proportion) {
            this.proportion = proportion;
        }

        public double getMontantMajoration() {
            return montantMajoration;
        }

        public void setMontantMajoration(double montantMajoration) {
            this.montantMajoration = montantMajoration;
        }
    }
}
