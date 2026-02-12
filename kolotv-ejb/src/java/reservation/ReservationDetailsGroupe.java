package reservation;

import bean.CGenUtil;
import bean.ClassFille;
import bean.ClassMAPTable;
import emission.Emission;
import emission.ParrainageEmission;
import media.Media;
import produits.Acte;
import produits.Ingredients;
import stock.MvtStock;
import stock.MvtStockFille;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;
import utils.CalendarUtil;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class ReservationDetailsGroupe extends ClassFille {
    String idmere, idproduit, idmedia, heure, remarque, source;
    String duree;
    double pu;
    Date datedebut;
    Date datefin;
    String dateDiffusion;
    int isEntete;
    int ordre;
    int nbspot;
    String dateInvalide;
    int nbDiffusion; // Nombre de diffusions à générer

    public int getNbDiffusion() {
        return nbDiffusion;
    }

    public void setNbDiffusion(int nbDiffusion) {
        this.nbDiffusion = nbDiffusion;
    }

    public String getDateInvalide() {
        return dateInvalide;
    }

    public void setDateInvalide(String dateInvalide) {
        this.dateInvalide = dateInvalide;
    }

    public int getNbspot() {
        return nbspot;
    }

    public void setNbspot(int nbspot) {
        this.nbspot = nbspot;
    }

    public int getIsEntete() {
        return isEntete;
    }

    public void setIsEntete(int isEntete) {
        this.isEntete = isEntete;
    }

    public int getOrdre() {
        return ordre;
    }

    public void setOrdre(int ordre) {
        this.ordre = ordre;
    }

    @Override
    public String getTuppleID() {
        return "";
    }

    @Override
    public String getAttributIDName() {
        return "";
    }

    public ReservationDetailsGroupe() {
        super();
        this.setNomTable("RESERVATIONDETAILSGROUPE");
    }

    public String getIdmedia() {
        return idmedia;
    }

    public void setIdmedia(String idmedia) {
        this.idmedia = idmedia;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getDuree() {
        return duree;
    }

    public String getIdmere() {
        return idmere;
    }

    public void setIdmere(String idmere) {
        this.idmere = idmere;
    }

    public String getIdproduit() {
        return idproduit;
    }

    public void setIdproduit(String idproduit) {
        this.idproduit = idproduit;
    }

    public Date getDatedebut() {
        return datedebut;
    }

    public void setDatedebut(Date datedebut) {
        this.datedebut = datedebut;
    }

    public Date getDatefin() {
        return datefin;
    }

    public void setDatefin(Date datefin) {
        this.datefin = datefin;
    }

    public String getHeure() {
        return heure;
    }

    public String getDateDiffusion() {
        return dateDiffusion;
    }

    public void setDateDiffusion(String dateDiffusion) {
        this.dateDiffusion = dateDiffusion;
    }

    public String getRemarque() {
        return remarque;
    }

    public void setRemarque(String remarque) {
        this.remarque = remarque;
        this.setLiaisonMere("idmere");
        setClassMere("reservation.Reservation");
    }

    public ReservationDetails[] genererReservationDetails() throws Exception {
        List<ReservationDetails> reservationDetails = new ArrayList<ReservationDetails>();
        String[] listDate = this.getDateDiffusion().split(";");

        // Récupérer la durée depuis le média si non fournie
        String dureeFinale = this.getDuree();
        if ((dureeFinale == null || dureeFinale.isEmpty() || "0".equals(dureeFinale)) && this.getIdmedia() != null
                && !this.getIdmedia().isEmpty()) {
            Media media = new Media();

            media.setId(this.getIdmedia());
            Media[] medias = (Media[]) CGenUtil.rechercher(media, null, null, null, "");
            if (medias != null && medias.length > 0) {
                dureeFinale = medias[0].getDuree();
            }
        }

        for (String d : listDate) {
            ReservationDetails res = new ReservationDetails();
            res.setIdproduit(this.getIdproduit());
            res.setIdMedia(this.getIdmedia());
            res.setHeure(this.getHeure());
            res.setDaty(Date.valueOf(LocalDate.parse(d, DateTimeFormatter.ofPattern("dd/MM/yyyy"))));
            res.setRemarque(this.getRemarque());
            res.setSource(this.getSource());
            res.setDuree(dureeFinale);
            res.setPu(this.getPu());
            res.setQte(1);
            res.setIsEntete(this.getIsEntete());
            res.setOrdre(this.getOrdre());
            reservationDetails.add(res);
        }
        return reservationDetails.toArray(new ReservationDetails[] {});
    }

    /**
     * Génère les détails de réservation en utilisant le nombre de diffusions.
     * Gère les conflits en décalant les dates si nécessaire.
     * 
     * @param idSupport L'ID du support pour la vérification des conflits
     * @param idClient  L'ID du client pour vérifier si c'est la même réservation
     * @param c         La connexion à la base de données
     * @return Les détails de réservation générés
     * @throws Exception En cas de conflit avec une autre réservation
     */
    public ReservationDetails[] genererReservationDetailsAvecNbDiffusion(String idSupport, String idClient,
            Connection c) throws Exception {
        List<ReservationDetails> reservationDetails = new ArrayList<ReservationDetails>();

        // Récupérer la durée depuis le média si non fournie
        String dureeFinale = this.getDuree();
        if ((dureeFinale == null || dureeFinale.isEmpty() || "0".equals(dureeFinale)) && this.getIdmedia() != null
                && !this.getIdmedia().isEmpty()) {
            Media media = new Media();
            media.setId(this.getIdmedia());
            Media[] medias = (Media[]) CGenUtil.rechercher(media, null, null, c, "");
            if (medias != null && medias.length > 0) {
                dureeFinale = medias[0].getDuree();
            }
        }

        // Générer les dates avec gestion des conflits (en prenant en compte la durée)
        List<Date> datesToUse = genererDatesAvecNbDiffusion(
                this.getDatedebut(),
                this.getDatefin(),
                this.getHeure(),
                dureeFinale,
                this.getNbDiffusion(),
                idClient,
                this.getIdproduit(),
                this.getIdmedia(),
                idSupport,
                c);

        for (Date date : datesToUse) {
            ReservationDetails res = new ReservationDetails();
            res.setIdproduit(this.getIdproduit());
            res.setIdMedia(this.getIdmedia());
            res.setHeure(this.getHeure());
            res.setDaty(date);
            res.setRemarque(this.getRemarque());
            res.setSource(this.getSource());
            res.setDuree(dureeFinale);
            res.setPu(this.getPu());
            res.setQte(1);
            res.setIsEntete(this.getIsEntete());
            res.setOrdre(this.getOrdre());
            reservationDetails.add(res);
        }

        return reservationDetails.toArray(new ReservationDetails[] {});
    }

    public ReservationDetails[] genererReservationDetailsPourModif(Connection c) throws Exception {
        // Récupérer la durée depuis le média si non fournie
        String dureeFinale = this.getDuree();
        if ((dureeFinale == null || dureeFinale.isEmpty() || "0".equals(dureeFinale)) && this.getIdmedia() != null
                && !this.getIdmedia().isEmpty()) {
            Media media = new Media();
            media.setId(this.getIdmedia());
            Media[] medias = (Media[]) CGenUtil.rechercher(media, null, null, c, "");
            if (medias != null && medias.length > 0) {
                dureeFinale = medias[0].getDuree();
            }
        }

        ReservationDetails search = new ReservationDetails();
        search.setIdmere(this.getIdmere());
        search.setOrdre(this.getOrdre());
        search.setIdproduit(this.getIdproduit());
        search.setHeure(this.getHeure());
        search.setPu(this.getPu());
        search.setDuree(dureeFinale != null && !dureeFinale.isEmpty() ? dureeFinale : "0");
        search.setRemarque(this.getRemarque());
        search.setSource(this.getSource());
        search.setIdMedia(this.getIdmedia());
        search.setIsEntete(this.getIsEntete());
        search.updateAllByOrdre(c);

        List<ReservationDetails> reservationDetails = new ArrayList<ReservationDetails>();
        String[] listDate = this.getDateDiffusion().split(";");
        String[] listDateInvalide = this.getDateInvalide().split(";");
        Map<String, Boolean> dtInvalide = new HashMap<>();
        for (String d : listDateInvalide) {
            dtInvalide.put(d, true);
        }
        for (String d : listDate) {
            if (dtInvalide.get(d) == null) {
                ReservationDetails res = new ReservationDetails();
                res.setIdmere(this.getIdmere());
                res.setIdproduit(this.getIdproduit());
                res.setIdMedia(this.getIdmedia());
                res.setHeure(this.getHeure());
                res.setDaty(Date.valueOf(LocalDate.parse(d, DateTimeFormatter.ofPattern("dd/MM/yyyy"))));
                res.setRemarque(this.getRemarque());
                res.setSource(this.getSource());
                res.setDuree(dureeFinale);
                res.setPu(this.getPu());
                res.setQte(1);
                res.setIsEntete(this.getIsEntete());
                res.setOrdre(this.getOrdre());
                reservationDetails.add(res);
            }
        }
        return reservationDetails.toArray(new ReservationDetails[] {});
    }

    public double getPu() {
        return pu;
    }

    public void setPu(double pu) {
        this.pu = pu;
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        boolean estOuvert = false;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                estOuvert = true;
            }

            ReservationDetails[] reservationDetails = genererReservationDetails();
            for (ReservationDetails reservationDetail : reservationDetails) {
                reservationDetail.createObject(u, c);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null && estOuvert == true) {
                c.close();
            }
        }
        return null;
    }

    public void setHeure(String heure) throws Exception {
        this.heure = heure;
    }

    public void setDuree(String duree) throws Exception {
        if (!CalendarUtil.isValidTime(duree)) {
            this.duree = duree;
        } else {
            this.duree = String.valueOf(CalendarUtil.HMSToSecond(duree));
        }
    }

    /**
     * Convertit une heure au format HH:mm ou HH:mm:ss en secondes depuis minuit.
     */
    private static int heureEnSecondes(String heure) {
        if (heure == null || heure.isEmpty())
            return 0;
        String[] parts = heure.split(":");
        int heures = Integer.parseInt(parts[0]);
        int minutes = parts.length > 1 ? Integer.parseInt(parts[1]) : 0;
        int secondes = parts.length > 2 ? Integer.parseInt(parts[2]) : 0;
        return heures * 3600 + minutes * 60 + secondes;
    }

    /**
     * Convertit une durée (en secondes ou format HH:mm:ss) en secondes.
     */
    private static int dureeEnSecondes(String duree) {
        if (duree == null || duree.isEmpty())
            return 0;
        // Si c'est déjà un nombre (en secondes)
        try {
            return Integer.parseInt(duree);
        } catch (NumberFormatException e) {
            // C'est au format HH:mm:ss ou mm:ss
            return heureEnSecondes(duree);
        }
    }

    /**
     * Vérifie si une réservation existe déjà à une date/heure donnée, en prenant
     * en compte la durée pour détecter les chevauchements.
     * 
     * @param daty          La date à vérifier
     * @param heure         L'heure de début de la nouvelle diffusion
     * @param dureeNouvelle La durée de la nouvelle diffusion (en secondes ou
     *                      HH:mm:ss)
     * @param idSupport     L'ID du support
     * @param c             La connexion à la base de données
     * @return null si pas de conflit, sinon retourne les infos de la réservation
     *         existante (idClient, idProduit, idMedia)
     */
    public static Map<String, String> verifierConflitReservation(Date daty, String heure, String dureeNouvelle,
            String idSupport, Connection c) throws Exception {
        boolean estOuvert = false;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                estOuvert = true;
            }

            int heureNouvelleSecondes = heureEnSecondes(heure);
            int dureeNouvelleSecondes = dureeEnSecondes(dureeNouvelle);
            if (dureeNouvelleSecondes <= 0)
                dureeNouvelleSecondes = 30; // Durée par défaut 30 secondes
            int finNouvelleSecondes = heureNouvelleSecondes + dureeNouvelleSecondes;

            // Récupérer toutes les réservations à cette date pour ce support
            String sql = "SELECT rd.ID, rd.IDPRODUIT, rd.IDMEDIA, rd.HEURE, rd.DUREE, r.IDCLIENT, " +
                    "c.NOM as CLIENT_NOM, p.LIBELLE as PRODUIT_NOM, m.DESCRIPTION as MEDIA_NOM " +
                    "FROM RESERVATIONDETAILS rd " +
                    "JOIN RESERVATION r ON r.ID = rd.IDMERE " +
                    "LEFT JOIN CLIENT c ON c.ID = r.IDCLIENT " +
                    "LEFT JOIN AS_INGREDIENTS p ON p.ID = rd.IDPRODUIT " +
                    "LEFT JOIN MEDIA m ON m.ID = rd.IDMEDIA " +
                    "WHERE rd.DATY = ? AND r.IDSUPPORT = ? AND r.ETAT >= 1";

            java.sql.PreparedStatement ps = c.prepareStatement(sql);
            ps.setDate(1, daty);
            ps.setString(2, idSupport);

            java.sql.ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String heureExistante = rs.getString("HEURE");
                String dureeExistante = rs.getString("DUREE");

                int heureExistanteSecondes = heureEnSecondes(heureExistante);
                int dureeExistanteSecondes = dureeEnSecondes(dureeExistante);
                if (dureeExistanteSecondes <= 0)
                    dureeExistanteSecondes = 30; // Durée par défaut
                int finExistanteSecondes = heureExistanteSecondes + dureeExistanteSecondes;

                // Vérifier chevauchement: nouvelle.debut < existante.fin ET nouvelle.fin >
                // existante.debut
                boolean chevauchement = (heureNouvelleSecondes < finExistanteSecondes) &&
                        (finNouvelleSecondes > heureExistanteSecondes);

                if (chevauchement) {
                    Map<String, String> conflit = new HashMap<>();
                    conflit.put("id", rs.getString("ID"));
                    conflit.put("idClient", rs.getString("IDCLIENT"));
                    conflit.put("idProduit", rs.getString("IDPRODUIT"));
                    conflit.put("idMedia", rs.getString("IDMEDIA"));
                    conflit.put("clientNom", rs.getString("CLIENT_NOM"));
                    conflit.put("produitNom", rs.getString("PRODUIT_NOM"));
                    conflit.put("mediaNom", rs.getString("MEDIA_NOM"));
                    rs.close();
                    ps.close();
                    return conflit;
                }
            }
            rs.close();
            ps.close();
            return null;

        } finally {
            if (c != null && estOuvert) {
                c.close();
            }
        }
    }

    /**
     * Vérifie si le conflit est avec la même réservation (même client, service,
     * media)
     */
    public static boolean estMemeReservation(Map<String, String> conflit, String idClient, String idProduit,
            String idMedia) {
        if (conflit == null)
            return false;

        boolean memeClient = conflit.get("idClient") != null && conflit.get("idClient").equals(idClient);
        boolean memeProduit = conflit.get("idProduit") != null && conflit.get("idProduit").equals(idProduit);
        boolean memeMedia = (conflit.get("idMedia") == null && idMedia == null) ||
                (conflit.get("idMedia") != null && conflit.get("idMedia").equals(idMedia));

        return memeClient && memeProduit && memeMedia;
    }

    /**
     * Génère les dates de diffusion avec gestion des conflits.
     * Si nbDiffusion est défini, génère exactement ce nombre de diffusions en
     * décalant si conflit avec sa propre réservation.
     * 
     * @param dateDebut   Date de début
     * @param dateFin     Date de fin maximum
     * @param heure       Heure de diffusion
     * @param duree       Durée de la diffusion (en secondes ou format HH:mm:ss)
     * @param nbDiffusion Nombre de diffusions à générer
     * @param idClient    ID du client
     * @param idProduit   ID du service/produit
     * @param idMedia     ID du média
     * @param idSupport   ID du support
     * @param c           Connexion DB
     * @return Liste des dates de diffusion générées
     */
    public static List<Date> genererDatesAvecNbDiffusion(Date dateDebut, Date dateFin, String heure, String duree,
            int nbDiffusion, String idClient, String idProduit, String idMedia, String idSupport,
            Connection c) throws Exception {

        List<Date> datesGenerees = new ArrayList<>();
        LocalDate currentDate = dateDebut.toLocalDate();
        LocalDate maxDate = dateFin.toLocalDate();
        int diffusionsGenerees = 0;
        int maxIterations = 365; // Sécurité pour éviter boucle infinie
        int iterations = 0;

        while (diffusionsGenerees < nbDiffusion && iterations < maxIterations) {
            Date dateCourante = Date.valueOf(currentDate);

            // Vérifier s'il y a un conflit à cette date/heure en prenant en compte la durée
            Map<String, String> conflit = verifierConflitReservation(dateCourante, heure, duree, idSupport, c);

            if (conflit == null) {
                // Pas de conflit, on ajoute cette date
                datesGenerees.add(dateCourante);
                diffusionsGenerees++;
            } else {
                // Il y a un conflit
                if (estMemeReservation(conflit, idClient, idProduit, idMedia)) {
                    // C'est notre propre réservation, on décale au jour suivant
                    // On ne compte pas cette date, on continue simplement
                } else {
                    // C'est une autre réservation, on lève une exception
                    String message = String.format(
                            "La case du %s à %s est déjà réservée par %s pour le service '%s' (média: %s)",
                            currentDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")),
                            heure,
                            conflit.get("clientNom") != null ? conflit.get("clientNom") : "un autre client",
                            conflit.get("produitNom") != null ? conflit.get("produitNom") : "inconnu",
                            conflit.get("mediaNom") != null ? conflit.get("mediaNom") : "N/A");
                    throw new Exception(message);
                }
            }

            currentDate = currentDate.plusDays(1);
            iterations++;
        }

        if (diffusionsGenerees < nbDiffusion) {
            throw new Exception(String.format(
                    "Impossible de générer %d diffusions. Seulement %d dates disponibles ont été trouvées.",
                    nbDiffusion, diffusionsGenerees));
        }

        return datesGenerees;
    }

    /**
     * Génère une réservation avec un nombre de diffusions spécifié.
     * Gère les conflits en décalant les dates si c'est la même réservation,
     * ou en levant une exception si c'est une réservation différente.
     */
    public Reservation genererReservationAvecNbDiffusion(HttpServletRequest request, Connection c) throws Exception {
        boolean estOuvert = false;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                estOuvert = true;
            }

            Reservation reservation = new Reservation();
            if (request.getParameter("idBc") != null && !request.getParameter("idBc").isEmpty()) {
                reservation.setIdBc(request.getParameter("idBc"));
            }
            String idSupport = request.getParameter("idSupport");
            String idClient = request.getParameter("idclient");
            reservation.setIdSupport(idSupport);
            reservation.setIdclient(idClient);
            reservation.setDaty(Date.valueOf(request.getParameter("daty")));
            reservation.setRemarque(request.getParameter("remarque"));

            String[] list = request.getParameterValues("ids");
            List<ReservationDetails> filles = new ArrayList<>();
            int ordre = 0;

            for (String id : list) {
                int isEntete = Integer.parseInt(request.getParameter("isEntete_" + id));
                String idproduit = request.getParameter("idproduit_" + id);
                String heure_debut = request.getParameter("heure_" + id);
                String remarque = request.getParameter("remarque_" + id);
                String source = request.getParameter("source_" + id);
                String idmedia = request.getParameter("idmedia_" + id);
                String duree = request.getParameter("duree_" + id);

                // Récupérer la durée depuis le média si non fournie
                if ((duree == null || duree.isEmpty() || "0".equals(duree)) && idmedia != null && !idmedia.isEmpty()) {
                    Media media = new Media();
                    media.setId(idmedia);
                    Media[] medias = (Media[]) CGenUtil.rechercher(media, null, null, c, "");
                    if (medias != null && medias.length > 0) {
                        duree = medias[0].getDuree();
                    }
                }

                double pu = 0;
                if (request.getParameter("pu_" + id) != null && !request.getParameter("pu_" + id).isEmpty()) {
                    pu = Double.parseDouble(request.getParameter("pu_" + id));
                }

                // Récupérer le nombre de diffusions
                int nbDiffusion = 0;
                if (request.getParameter("nbDiffusion_" + id) != null
                        && !request.getParameter("nbDiffusion_" + id).isEmpty()) {
                    nbDiffusion = Integer.parseInt(request.getParameter("nbDiffusion_" + id));
                }

                // Récupérer les dates de début et fin
                String dateDebutStr = request.getParameter("datedebut_" + id);
                String dateFinStr = request.getParameter("datefin_" + id);

                List<Date> datesToUse = new ArrayList<>();

                if (nbDiffusion > 0 && dateDebutStr != null && !dateDebutStr.isEmpty() &&
                        dateFinStr != null && !dateFinStr.isEmpty()) {
                    // Utiliser la nouvelle logique avec nbDiffusion
                    Date dateDebut = Date.valueOf(dateDebutStr);
                    Date dateFin = Date.valueOf(dateFinStr);

                    // Générer les dates avec gestion des conflits
                    datesToUse = genererDatesAvecNbDiffusion(dateDebut, dateFin, heure_debut, duree,
                            nbDiffusion, idClient, idproduit, idmedia, idSupport, c);
                } else {
                    // Logique existante: utiliser les dates sélectionnées manuellement
                    String champDate = request.getParameter("listDate_" + id);
                    if (champDate != null && !champDate.isEmpty()) {
                        String[] listDate = champDate.split(";");
                        for (String d : listDate) {
                            if (d != null && !d.isEmpty()) {
                                datesToUse.add(Utilitaire.stringDate(d));
                            }
                        }
                    }
                }

                // Créer les réservations details pour chaque date
                for (Date date : datesToUse) {
                    ReservationDetails reservationDetails = new ReservationDetails();
                    reservationDetails.setIdproduit(idproduit);
                    reservationDetails.setIdMedia(idmedia);
                    reservationDetails.setDaty(date);
                    reservationDetails.setHeure(heure_debut);
                    reservationDetails.setPu(pu);
                    reservationDetails.setRemarque(remarque);
                    reservationDetails.setSource(source);
                    reservationDetails.setQte(1);
                    reservationDetails.setDuree(duree);
                    reservationDetails.setIsEntete(isEntete);
                    reservationDetails.setOrdre(ordre);
                    filles.add(reservationDetails);
                }
                ordre++;
            }

            reservation.setFille(filles.toArray(new ReservationDetails[] {}));
            return reservation;

        } finally {
            if (c != null && estOuvert) {
                c.close();
            }
        }
    }

    public Reservation genererReservationApresSaisieMultiple(HttpServletRequest request) throws Exception {
        Reservation reservation = new Reservation();
        if (request.getParameter("idBc") != null && request.getParameter("idBc").isEmpty() == false) {
            reservation.setIdBc(request.getParameter("idBc"));
        }
        reservation.setIdSupport(request.getParameter("idSupport"));
        reservation.setIdclient(request.getParameter("idclient"));
        reservation.setDaty(Date.valueOf(request.getParameter("daty")));
        reservation.setRemarque(request.getParameter("remarque"));
        String[] list = request.getParameterValues("ids");
        List<ReservationDetails> filles = new ArrayList<>();
        int ordre = 0;
        for (String id : list) {
            int isEntete = Integer.parseInt(request.getParameter("isEntete_" + id));
            String idproduit = request.getParameter("idproduit_" + id);
            String heure_debut = request.getParameter("heure_" + id);
            String remarque = request.getParameter("remarque_" + id);
            String source = request.getParameter("source_" + id);
            String idmedia = request.getParameter("idmedia_" + id);
            String duree = request.getParameter("duree_" + id);

            // Récupérer la durée depuis le média si non fournie
            if ((duree == null || duree.isEmpty() || "0".equals(duree)) && idmedia != null && !idmedia.isEmpty()) {
                Media media = new Media();
                media.setId(idmedia);
                Media[] medias = (Media[]) CGenUtil.rechercher(media, null, null, null, "");
                if (medias != null && medias.length > 0) {
                    duree = medias[0].getDuree();
                }
            }

            double pu = 0;
            if (request.getParameter("pu_" + id) != null && request.getParameter("pu_" + id).isEmpty() == false) {
                pu = Double.parseDouble(request.getParameter("pu_" + id));
            }
            String champDate = request.getParameter("listDate_" + id);
            if (champDate != null && champDate.isEmpty() == false) {
                String[] listDate = champDate.split(";");
                for (String d : listDate) {
                    System.out.println(isEntete);
                    if (d != null && d.isEmpty() == false) {
                        Date date = Utilitaire.stringDate(d);
                        ReservationDetails reservationDetails = new ReservationDetails();
                        reservationDetails.setIdproduit(idproduit);
                        reservationDetails.setIdMedia(idmedia);
                        reservationDetails.setDaty(date);
                        reservationDetails.setHeure(heure_debut);
                        reservationDetails.setPu(pu);
                        reservationDetails.setRemarque(remarque);
                        reservationDetails.setSource(source);
                        reservationDetails.setQte(1);
                        reservationDetails.setDuree(duree);
                        reservationDetails.setIsEntete(isEntete);
                        reservationDetails.setOrdre(ordre);
                        filles.add(reservationDetails);
                    }
                }
            }
            ordre++;
        }
        reservation.setFille(filles.toArray(new ReservationDetails[] {}));
        return reservation;
    }

    public Reservation genererReservationApresSaisieMultipleAmeliorer(HttpServletRequest request) throws Exception {
        Reservation reservation = new Reservation();
        if (request.getParameter("idBc") != null && request.getParameter("idBc").isEmpty() == false) {
            reservation.setIdBc(request.getParameter("idBc"));
        }
        reservation.setIdSupport(request.getParameter("idSupport"));
        reservation.setIdclient(request.getParameter("idclient"));
        reservation.setDaty(Date.valueOf(request.getParameter("daty")));
        reservation.setRemarque(request.getParameter("remarque"));
        String[] list = request.getParameterValues("ids");
        List<ReservationDetails> filles = new ArrayList<>();
        int ordre = 0;
        for (String id : list) {
            int isEntete = Integer.parseInt(request.getParameter("isEntete_" + id));
            String idproduit = request.getParameter("idproduit_" + id);
            String heure_debut = request.getParameter("heure_" + id);
            String remarque = request.getParameter("remarque_" + id);
            String source = request.getParameter("source_" + id);
            String idmedia = request.getParameter("idmedia_" + id);
            String duree = request.getParameter("duree_" + id);

            // Récupérer la durée depuis le média si non fournie
            if ((duree == null || duree.isEmpty() || "0".equals(duree)) && idmedia != null && !idmedia.isEmpty()) {
                Media media = new Media();
                media.setId(idmedia);
                Media[] medias = (Media[]) CGenUtil.rechercher(media, null, null, null, "");
                if (medias != null && medias.length > 0) {
                    duree = medias[0].getDuree();
                }
            }

            double pu = 0;
            if (request.getParameter("pu_" + id) != null && request.getParameter("pu_" + id).isEmpty() == false) {
                pu = Double.parseDouble(request.getParameter("pu_" + id));
            }
            LocalDate dateDebut = null;
            LocalDate dateFin = null;
            if (request.getParameter("dateDebut_" + id) != null
                    && request.getParameter("dateDebut_" + id).isEmpty() == false &&
                    request.getParameter("dateFin_" + id) != null
                    && request.getParameter("dateFin_" + id).isEmpty() == false) {
                dateDebut = Date.valueOf(request.getParameter("dateDebut_" + id)).toLocalDate();
                dateFin = Date.valueOf(request.getParameter("dateFin_" + id)).toLocalDate();
            } else {
                throw new Exception("La date debut et fin sont requise pour la ligne " + id);
            }
            String[] jours = request.getParameterValues("jours_" + id);
            String[] dateInvalides = request.getParameter("dateInvalide_" + id).split(";");
            Map<String, Boolean> dtInterdite = new HashMap<>();
            for (String j : dateInvalides) {
                dtInterdite.put(j, false);
            }
            Map<String, Boolean> jourValide = new HashMap<>();
            for (String j : jours) {
                jourValide.put(j, true);
            }

            while (!dateDebut.isAfter(dateFin)) {
                if (dtInterdite.get(dateDebut.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))) == null) {
                    if (jourValide.get(CalendarUtil.getDayOfWeek(dateDebut)) != null) {
                        ReservationDetails reservationDetails = new ReservationDetails();
                        reservationDetails.setIdproduit(idproduit);
                        reservationDetails.setIdMedia(idmedia);
                        reservationDetails.setDaty(Date.valueOf(dateDebut));
                        reservationDetails.setHeure(heure_debut);
                        reservationDetails.setPu(pu);
                        reservationDetails.setRemarque(remarque);
                        reservationDetails.setSource(source);
                        reservationDetails.setQte(1);
                        reservationDetails.setDuree(duree);
                        reservationDetails.setIsEntete(isEntete);
                        reservationDetails.setOrdre(ordre);
                        filles.add(reservationDetails);
                    }
                }
                dateDebut = dateDebut.plusDays(1);
            }
            ordre++;
        }
        reservation.setFille(filles.toArray(new ReservationDetails[] {}));
        return reservation;
    }

    public Reservation genererReservationApresSaisieMultiplePourEmission(HttpServletRequest request, Connection c)
            throws Exception {
        boolean estOuvert = false;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                estOuvert = true;
            }
            Reservation reservation = new Reservation();
            reservation.setIdSupport(request.getParameter("idSupport"));
            reservation.setDaty(Date.valueOf(request.getParameter("daty")));
            reservation.setRemarque(request.getParameter("remarque"));
            String[] list = request.getParameterValues("ids");
            int nbJour = Integer.parseInt(request.getParameter("nbJours"));
            List<ReservationDetails> filles = new ArrayList<>();
            for (String id : list) {
                String serviceMedia = request.getParameter("idproduit_" + id);
                Emission emission = new Emission();
                emission.setId(serviceMedia);
                emission = (Emission) CGenUtil.rechercher(emission, null, null, c, "")[0];
                String heure_debut = request.getParameter("heure_" + id);
                String duree = request.getParameter("duree_" + id);
                double remise = 0;
                double pu = 0;
                for (int i = 0; i < nbJour; i++) {
                    String champDate = "date_" + id + "_" + i;
                    int quantite = Integer.parseInt(request.getParameter(champDate + "_quantite"));
                    Date date = Utilitaire.stringDate(request.getParameter(champDate + "_date"));
                    for (int j = 0; j < quantite; j++) {
                        ReservationDetails reservationDetails = new ReservationDetails();
                        reservationDetails.setIdproduit(serviceMedia);
                        reservationDetails.setDaty(date);
                        reservationDetails.setHeure(heure_debut);
                        reservationDetails.setPu(pu);
                        reservationDetails.setRemise(remise);
                        reservationDetails.setQte(1);
                        reservationDetails.setDuree(duree);
                        filles.add(reservationDetails);

                        ReservationDetails[] resaParainnage = emission.genererReservationPourSponsors(date, heure_debut,
                                c);
                        if (resaParainnage.length > 0) {
                            filles.addAll(Arrays.asList(resaParainnage));
                        }
                    }
                }
            }
            reservation.setFille(filles.toArray(new ReservationDetails[] {}));
            return reservation;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null && estOuvert == true) {
                c.close();
            }
        }
    }

    public Reservation genererReservationApresModif(HttpServletRequest request, Connection c) throws Exception {
        boolean estOuvert = false;
        try {
            if (c == null) {
                c = new UtilDB().GetConn();
                estOuvert = true;
            }
            Reservation reservation = new Reservation();
            reservation.setId(request.getParameter("idResa"));
            reservation = (Reservation) CGenUtil.rechercher(reservation, null, null, c, "")[0];
            if (request.getParameter("idBc") != null && request.getParameter("idBc").isEmpty() == false) {
                reservation.setIdBc(request.getParameter("idBc"));
            }
            reservation.setIdSupport(request.getParameter("idSupport"));
            reservation.setIdclient(request.getParameter("idclient"));
            reservation.setDaty(Date.valueOf(request.getParameter("daty")));
            reservation.setRemarque(request.getParameter("remarque"));
            String idParrainage = null;
            if (reservation.getSource() != null && reservation.getSource().startsWith("PRE")) {
                idParrainage = reservation.getSource();
            }
            String[] list = request.getParameterValues("ids");
            List<ReservationDetails> filles = new ArrayList<>();
            if (list != null) {
                for (String id : list) {
                    int isEntete = Integer.parseInt(request.getParameter("isEntete_" + id));
                    String idproduit = request.getParameter("idproduit_" + id);
                    String heure_debut = request.getParameter("heure_" + id);
                    String remarque = request.getParameter("remarque_" + id);
                    String source = request.getParameter("source_" + id);
                    String idmedia = request.getParameter("idmedia_" + id);
                    String duree = request.getParameter("duree_" + id);

                    // Récupérer la durée depuis le média si non fournie
                    if ((duree == null || duree.isEmpty() || "0".equals(duree)) && idmedia != null
                            && !idmedia.isEmpty()) {
                        Media media = new Media();
                        media.setId(idmedia);
                        Media[] medias = (Media[]) CGenUtil.rechercher(media, null, null, c, "");
                        if (medias != null && medias.length > 0) {
                            duree = medias[0].getDuree();
                        }
                    }

                    double pu = 0;
                    if (request.getParameter("pu_" + id) != null
                            && request.getParameter("pu_" + id).isEmpty() == false) {
                        pu = Double.parseDouble(request.getParameter("pu_" + id));
                    }
                    int ordre = Integer.parseInt(request.getParameter("ordre_" + id));
                    ReservationDetails search = new ReservationDetails();
                    search.setIdmere(reservation.getId());
                    search.setOrdre(ordre);
                    search.setIdproduit(idproduit);
                    search.setHeure(heure_debut);
                    search.setPu(pu);
                    search.setDuree(duree);
                    search.setRemarque(remarque);
                    search.setSource(source);
                    search.setIdMedia(idmedia);
                    search.setIsEntete(isEntete);
                    search.updateAllByOrdre(c);
                    String champDate = request.getParameter("listDate_" + id);
                    if (champDate != null && champDate.isEmpty() == false) {
                        String[] listDate = champDate.split(";");
                        for (String d : listDate) {
                            System.out.println(isEntete);
                            if (d != null && d.isEmpty() == false) {
                                Date date = Utilitaire.stringDate(d);
                                ReservationDetails reservationDetails = new ReservationDetails();
                                reservationDetails.setIdmere(reservation.getId());
                                reservationDetails.setIdproduit(idproduit);
                                reservationDetails.setIdMedia(idmedia);
                                reservationDetails.setDaty(date);
                                reservationDetails.setHeure(heure_debut);
                                reservationDetails.setPu(pu);
                                reservationDetails.setRemarque(remarque);
                                reservationDetails.setSource(source);
                                reservationDetails.setQte(1);
                                reservationDetails.setDuree(duree);
                                reservationDetails.setIsEntete(isEntete);
                                reservationDetails.setOrdre(ordre);
                                reservationDetails.setIdparrainage(idParrainage);
                                filles.add(reservationDetails);
                            }
                        }
                    }
                }
            }
            reservation.setFille(filles.toArray(new ReservationDetails[] {}));
            return reservation;
        } catch (Exception ex) {
            ex.printStackTrace();
            c.rollback();
            throw ex;
        } finally {
            if (c != null && estOuvert == true) {
                c.close();
            }
        }
    }

}
