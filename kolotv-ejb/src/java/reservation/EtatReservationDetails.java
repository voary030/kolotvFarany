package reservation;

import bean.AdminGen;
import bean.CGenUtil;
import categorieheure.HeureDePointe;
import duree.DisponibiliteHeure;
import utilitaire.ConstanteEtat;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;
import utils.CalendarUtil;
import utils.ConstanteStation;

import java.sql.Connection;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class EtatReservationDetails {
    String[] listeDate;
    HashMap<String, Vector> reservations;
    List<LocalTime[]> horaire;
    HashMap<String, Double[]> total = new HashMap<>();
    HashMap<String, Double> majorationsHeurePointe = new HashMap<>();
    int dureeDiffuser;
    String idSupport;

    public EtatReservationDetails(String idSupport, String idTypeService, String dtMin, String dtMax) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            this.idSupport = idSupport;
            this.setListeDate(dtMin, dtMax);
            horaire = CalendarUtil.trierParReference(CalendarUtil.generateTimeIntervalsOfDay(60), LocalTime.now());
            this.setReservations(idSupport, idTypeService, dtMin, dtMax, c);
            this.setTotal();
            // Calcul des majorations heure de pointe (optionnel, ne bloque pas si table
            // n'existe pas)
            try {
                this.calculerMajorations(c);
            } catch (Exception eMaj) {
                // Table HEUREDEPOINTE n'existe peut-être pas encore
                System.out.println(
                        "Avertissement: Impossible de calculer les majorations heure de pointe: " + eMaj.getMessage());
            }
        } catch (Exception e) {
            throw e;
        } finally {
            if (c != null)
                c.close();
        }
    }

    public String[] getListeDate() {
        return listeDate;
    }

    public void setListeDate(String dtMin, String dtMax) {
        // if(Utilitaire.diffJourDaty(dtMax,dtMin)<0)throw new Exception("Date sup
        // inferieur a date Inf");
        int day = Utilitaire.diffJourDaty(dtMax, dtMin);
        String liste[] = new String[day];
        for (int i = 0; i < day; i++) {
            liste[i] = Utilitaire.formatterDaty(Utilitaire.ajoutJourDate(dtMin, i));
            // System.out.println(liste[i]);
        }
        this.listeDate = liste;
    }

    public HashMap<String, Vector> getReservations() {
        return reservations;
    }

    public void setReservations(String idSupport, String idTypeService, String dMin, String dMax, Connection c)
            throws Exception {
        ReservationDetailsAvecDiffusion res = new ReservationDetailsAvecDiffusion();
        if (idSupport != null && !idSupport.isEmpty()) {
            res.setIdSupport(idSupport);
        }
        if (idTypeService != null && !idTypeService.isEmpty()) {
            res.setCategorieproduit(idTypeService);
        }
        if (dMin == null || dMin.compareToIgnoreCase("") == 0)
            dMin = Utilitaire.formatterDaty(Utilitaire.getDebutSemaine(Utilitaire.dateDuJourSql()));
        String[] colInt = { "daty" };
        String[] valInt = { dMin, dMax };
        this.reservations = CGenUtil.rechercher2D(res, colInt, valInt, "daty", c, "");
    }

    public List<LocalTime[]> getHoraire() {
        return horaire;
    }

    public void setHoraire(List<LocalTime[]> horaire) {
        this.horaire = horaire;
    }

    public HashMap<String, Double[]> getTotal() {
        return total;
    }

    public void setTotal() {
        // total[0] - Montant Total
        // total[1] - Duree de diffusion Total
        this.total = new HashMap<>();
        for (String dt : listeDate) {
            double montantTotal = 0;
            double dureeTotal = 0;
            Vector v = this.reservations.get(dt);
            if (v != null) {
                for (Object o : v) {
                    ReservationDetailsAvecDiffusion res = (ReservationDetailsAvecDiffusion) o;
                    montantTotal += res.getMontantTtc();
                    if (res.getDuree() != null) {
                        dureeTotal += Double.valueOf(res.getDuree());
                    }
                }
            }
            total.put(dt, new Double[] { montantTotal, dureeTotal });
        }

    }

    public boolean checkTime(LocalTime time, LocalTime time_min, LocalTime time_max) {
        if (((time.isAfter(time_min) || time.equals(time_min)) && (time.isBefore(time_max)))) {
            return true;
        }
        return false;
    }

    // kasaina added code

    /**
     * Retourne les réservations qui touchent cette plage horaire (début, milieu ou
     * fin)
     * avec une indication de leur position dans la plage
     * 
     * @return Map<ReservationDetailsAvecDiffusion, String> où String est "debut",
     *         "suite", "fin" ou "complet"
     */
    public Map<ReservationDetailsAvecDiffusion, String> getReservationByTimeWithPosition(LocalTime[] times, String date)
            throws Exception {
        Map<ReservationDetailsAvecDiffusion, String> res = new LinkedHashMap<>();
        Vector liste = this.getReservations().get(date);
        this.dureeDiffuser = 0;
        if (liste != null) {
            for (Object d : liste) {
                ReservationDetailsAvecDiffusion rd = (ReservationDetailsAvecDiffusion) d;
                LocalTime heureDebut = LocalTime.parse(rd.getHeure());
                int dureeTotaleSecondes = (rd.getDuree() != null && !rd.getDuree().isEmpty())
                        ? Integer.parseInt(rd.getDuree())
                        : 0;
                LocalTime heureFin = heureDebut.plusSeconds(dureeTotaleSecondes);

                // Vérifier si la diffusion touche cette plage
                boolean debutDansPlage = checkTime(heureDebut, times[0], times[1]);
                boolean finDansPlage = (heureFin.isAfter(times[0])
                        && (heureFin.isBefore(times[1]) || heureFin.equals(times[1])));
                boolean chevaucheCompletement = (heureDebut.isBefore(times[0]) || heureDebut.equals(times[0]))
                        && (heureFin.isAfter(times[1]) || heureFin.equals(times[1]));

                String position = null;
                if (debutDansPlage && (heureFin.isBefore(times[1]) || heureFin.equals(times[1]))) {
                    position = "complet"; // La diffusion commence et se termine dans cette plage
                } else if (debutDansPlage && heureFin.isAfter(times[1])) {
                    position = "debut"; // La diffusion commence ici mais continue après
                } else if (finDansPlage && heureDebut.isBefore(times[0])) {
                    position = "fin"; // La diffusion a commencé avant et se termine ici
                } else if (chevaucheCompletement) {
                    position = "suite"; // La diffusion traverse complètement cette plage
                }

                if (position != null) {
                    if (rd.getEtatMere() >= ConstanteEtat.getEtatValider()) {
                        if (rd.getDuree() != null) {
                            // Calculer la durée dans cette plage
                            LocalTime debutIntersection = heureDebut.isAfter(times[0]) ? heureDebut : times[0];
                            LocalTime finIntersection = heureFin.isBefore(times[1]) ? heureFin : times[1];
                            if (debutIntersection.isBefore(finIntersection)) {
                                this.dureeDiffuser += java.time.Duration.between(debutIntersection, finIntersection)
                                        .getSeconds();
                            }
                        }
                    }
                    res.put(rd, position);
                }
            }
        }
        return res;
    }

    public ReservationDetailsAvecDiffusion[] getReservationByTime(LocalTime[] times, String date) throws Exception {
        List<ReservationDetailsAvecDiffusion> res = new ArrayList<>();
        Vector liste = this.getReservations().get(date);
        this.dureeDiffuser = 0;
        if (liste != null) {
            for (Object d : liste) {
                ReservationDetailsAvecDiffusion rd = (ReservationDetailsAvecDiffusion) d;
                LocalTime heure = LocalTime.parse(rd.getHeure());
                if (checkTime(heure, times[0], times[1])) {

                    if (rd.getEtatMere() >= ConstanteEtat.getEtatValider()) {
                        if (rd.getDuree() != null) {
                            this.dureeDiffuser += Integer.valueOf(rd.getDuree());
                        }
                    }
                    res.add(rd);
                }
            }
        }
        return res.toArray(new ReservationDetailsAvecDiffusion[] {});
    }

    // public ReservationDetailsAvecDiffusion checkReste
    // (ReservationDetailsAvecDiffusion rd,LocalTime [] times) throws Exception {
    // ReservationDetailsAvecDiffusion result = null;
    // LocalTime heure = LocalTime.parse(rd.getHeure());
    // LocalTime heure_fin = heure.plusSeconds(Long.parseLong(rd.getDuree()));
    // int restDuree = (int) (CalendarUtil.getDuration(heure,heure_fin) -
    // CalendarUtil.getDuration(times[0],times[1]));
    // if (restDuree>0){
    // result = new ReservationDetailsAvecDiffusion();
    // result.setDuree(String.valueOf(restDuree));
    // result.setHeure(times[1].format(DateTimeFormatter.ofPattern("HH:mm:ss")));
    // result.setDureeDiffusion(rd.getDureeDiffusion());
    // result.setHeureDiffusion(rd.getHeureDiffusion());
    // result.setIdSupport(rd.getIdSupport());
    // result.setMontantTtc(rd.getMontantTtc());
    // result.setEtatLib(rd.getEtatLib());
    // result.setEtatMere(rd.getEtatMere());
    // result.setIdMediaLib(rd.getIdMediaLib());
    // result.setLibelleproduit(rd.getLibelleproduit());
    // result.setEtat(rd.getEtat());
    // }
    // return result;
    // }

    public int getDureeDiffuser() {
        return dureeDiffuser;
    }

    public void setDureeDiffuser(int dureeDiffuser) {
        this.dureeDiffuser = dureeDiffuser;
    }

    public int getResteADiffuser(LocalTime[] times) {
        int result = (int) (CalendarUtil.getDuration(times[0], times[1]) - this.dureeDiffuser);
        if (result < 0) {
            result = 0;
        }
        return result;
    }

    /**
     * Calcule les majorations heures de pointe pour chaque réservation
     */
    private void calculerMajorations(Connection c) throws Exception {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        for (String dateStr : listeDate) {
            double majorationJour = 0;
            Vector liste = this.reservations.get(dateStr);
            if (liste != null) {
                LocalDate date = LocalDate.parse(dateStr, formatter);
                for (Object d : liste) {
                    ReservationDetailsAvecDiffusion rd = (ReservationDetailsAvecDiffusion) d;
                    if (rd.getHeure() != null && rd.getDuree() != null && !rd.getDuree().isEmpty()) {
                        int dureeSecondes = Integer.parseInt(rd.getDuree());
                        double majoration = HeureDePointe.calculerMajoration(
                                rd.getHeure(),
                                dureeSecondes,
                                rd.getMontantTtc(),
                                date,
                                this.idSupport,
                                c);
                        majorationJour += majoration;
                    }
                }
            }
            majorationsHeurePointe.put(dateStr, majorationJour);
        }
    }

    /**
     * Récupère la majoration heure de pointe pour une date donnée
     */
    public double getMajorationHeurePointe(String date) {
        Double maj = majorationsHeurePointe.get(date);
        return maj != null ? maj : 0;
    }

    /**
     * Calcule la majoration heure de pointe pour une réservation spécifique
     */
    public static double calculerMajorationReservation(ReservationDetailsAvecDiffusion rd, String dateStr,
            String idSupport, Connection c) throws Exception {
        if (rd.getHeure() == null || rd.getDuree() == null || rd.getDuree().isEmpty()) {
            return 0;
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        LocalDate date = LocalDate.parse(dateStr, formatter);
        int dureeSecondes = Integer.parseInt(rd.getDuree());
        return HeureDePointe.calculerMajoration(rd.getHeure(), dureeSecondes, rd.getMontantTtc(), date, idSupport, c);
    }

    /**
     * Vérifie si une date/heure est en heure de pointe
     */
    public static boolean estEnHeureDePointe(String heureDebut, String heureFin, String dateStr, String idSupport,
            Connection c) throws Exception {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        LocalDate date = LocalDate.parse(dateStr, formatter);
        return HeureDePointe.estEnHeureDePointe(heureDebut, heureFin, date, idSupport, c);
    }

    /**
     * Récupère les heures de pointe pour une date donnée
     */
    public static HeureDePointe[] getHeuresDePointe(String dateStr, String idSupport, Connection c) throws Exception {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        LocalDate date = LocalDate.parse(dateStr, formatter);
        return HeureDePointe.getHeuresDePointePourDate(date, idSupport, c);
    }
}
