package categorieheure;

/**
 * Classe CPL (Complète) pour l'affichage des heures de pointe
 * avec les informations jointes (libellé support, etc.)
 * 
 * @author rachriss
 * @date 05/02/2026
 */
public class HeureDePointeCpl extends HeureDePointe {

    private String idSupportLib;
    private String etatLib;

    public HeureDePointeCpl() {
        super();
        this.setNomTable("HEUREDEPOINTECPL");
    }

    public String getIdSupportLib() {
        return idSupportLib;
    }

    public void setIdSupportLib(String idSupportLib) {
        this.idSupportLib = idSupportLib;
    }

    public String getEtatLib() {
        return etatLib;
    }

    public void setEtatLib(String etatLib) {
        this.etatLib = etatLib;
    }

    /**
     * Retourne le libellé du support ou "Tous les supports" si null
     */
    public String getSupportLibelle() {
        if (this.idSupportLib != null && !this.idSupportLib.isEmpty()) {
            return this.idSupportLib;
        }
        return "Tous les supports";
    }

    /**
     * Retourne le jour de la semaine formaté
     */
    public String getJourSemaineFormate() {
        String jour = this.getJourSemaine();
        if (jour != null) {
            return jour.substring(0, 1).toUpperCase() + jour.substring(1).toLowerCase();
        }
        return "";
    }

    /**
     * Retourne une description de la plage horaire
     */
    public String getPlageHoraire() {
        return this.getHeureDebut() + " - " + this.getHeureFin();
    }

    /**
     * Retourne le pourcentage formaté
     */
    public String getPourcentageFormate() {
        return String.format("%.1f%%", this.getPourcentageMajoration());
    }
}
