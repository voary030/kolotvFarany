<%@ page import="affichage.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="reservation.ReservationLib" %>
<%@ page import="reservation.ReservationDetailsLib" %>
<%@ page import="utils.ConstanteAsync" %>
<%@ page import="utils.CalendarUtil" %>
<%@ page import="utils.UrlUtils" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%@ page import="utilitaire.Utilitaire" %>
<%@ page import="reservation.EtatReservationDetails" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.util.List" %>
<%@ page import="reservation.ReservationDetailsAvecDiffusion" %>
<%@ page import="java.util.Vector" %>
<%@ page import="produits.Acte" %>
<%@ page import="support.Support" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="produits.CategorieIngredient" %>
<%@ page import="categorieheure.HeureDePointe" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<style>
.form-input { margin-bottom: 0px; }
table td { max-width: 30%; }
.calendar-grid { width: 100%; background-color: white; overflow: hidden; border-radius: 2px; }
.calendar-cell { border-style: solid; border-width: 0.5px; border-color: #c8c8c8; padding: 10px 5px; text-align: center; }
.event { display: flex; justify-content: space-between; gap: 2px; align-items: flex-start; font-size: 14px; line-height: 1.2; }
.day-btn { cursor: pointer; color: white; background-color: #003695db; padding: 10px 2px; text-align: center; font-size: 16px; border: 0.5px solid #c8c8c8; font-weight: bold; }
.day-btn:hover { background-color: #0b3881; }
.event-title { width: 80%; background: #f4f4f4; border-left: 3px solid #0e66ff; padding: 2px 6px; margin: 2px 0; border-radius: 3px; overflow: hidden; cursor: pointer; }
.event-title:hover { box-shadow: 0 0 5px #616161; }
.event-title p { margin: 0; padding: 0; }
.event-hours { padding: 2px; color: #333; font-size: 12px; }
.calendar-cell-title { padding: 10px 2px; text-align: center; font-size: 16px; background-color: rgba(231, 231, 231, 0.334); border: 0.5px solid #c8c8c8; font-weight: bold; }
.calendar-footer { border: 0.5px solid #c8c8c8; padding: 5px; }
.heure-pointe-indicator { background: linear-gradient(135deg, #ff6b6b, #ffa500); color: white; padding: 2px 6px; border-radius: 3px; font-size: 10px; font-weight: bold; display: inline-block; margin-bottom: 5px; }
.majoration-badge { background-color: #ff9800; color: white; padding: 2px 5px; border-radius: 3px; font-size: 10px; margin-top: 2px; display: inline-block; }
.total-avec-maj { background: #4caf50; color: white; padding: 3px 6px; border-radius: 3px; font-size: 11px; margin-top: 3px; font-weight: bold; display: inline-block; }
.calendar-cell.heure-pointe { background: linear-gradient(135deg, rgba(255, 152, 0, 0.15), rgba(255, 107, 107, 0.15)); }
.heure-pointe-legend { display: inline-flex; align-items: center; gap: 5px; padding: 5px 10px; background: linear-gradient(135deg, rgba(255, 152, 0, 0.2), rgba(255, 107, 107, 0.2)); border-radius: 5px; font-size: 12px; }
.total-box { background: #f5f5f5; padding: 8px; border-radius: 5px; margin-top: 5px; }
.majoration-total { background: linear-gradient(135deg, #fff3e0, #ffe0b2); padding: 5px 8px; border-radius: 4px; margin-top: 3px; }
.montant-base { font-size: 12px; color: #666; }
.montant-final { font-size: 13px; font-weight: bold; color: #2e7d32; }
</style>
<%
  Connection connGlobal = null;
  try {
    connGlobal = new UtilDB().GetConn();
    String lien = (String) session.getValue("lien");
    user.UserEJB u = (user.UserEJB) session.getValue("u");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    String dateEncours = request.getParameter("d");
    if (dateEncours != null) {
      dateEncours = CalendarUtil.castDateToFormat(dateEncours, DateTimeFormatter.ofPattern("yyyy-MM-dd"), formatter);
    }
    if (dateEncours == null || dateEncours.trim().isEmpty()) {
      dateEncours = LocalDate.now().format(formatter);
    }
    String[] debutEtFinDeSemaine = CalendarUtil.getDebutEtFinDeSemaine(dateEncours);
    String idSupport = request.getParameter("idSupport");
    if (idSupport == null || idSupport.isEmpty()) idSupport = "SUPP002";
    String idTypeService = request.getParameter("idCategorieIngredient");
    EtatReservationDetails eta = new EtatReservationDetails(idSupport, idTypeService, debutEtFinDeSemaine[0], debutEtFinDeSemaine[1]);
    String[] listeDate = eta.getListeDate();
    List<LocalTime[]> listeHoraire = eta.getHoraire();
    HashMap<String, Double[]> total = eta.getTotal();
    String urlComplete = request.getRequestURL().toString();
    String queryString = request.getQueryString();
    if (queryString != null) urlComplete += "?" + queryString;
    String lienPrecedent = UrlUtils.modifierParametreDansUrl(urlComplete, "d", CalendarUtil.castDateToFormat(debutEtFinDeSemaine[2], formatter, DateTimeFormatter.ofPattern("yyyy-MM-dd")));
    String lienSuivant = UrlUtils.modifierParametreDansUrl(urlComplete, "d", CalendarUtil.castDateToFormat(debutEtFinDeSemaine[3], formatter, DateTimeFormatter.ofPattern("yyyy-MM-dd")));
    Support[] supports = (Support[]) CGenUtil.rechercher(new Support(), null, null, null, "");
    CategorieIngredient[] categorieIngredients = (CategorieIngredient[]) CGenUtil.rechercher(new CategorieIngredient(), null, null, null, "");
    
    HashMap<String, HeureDePointe[]> heuresDePointeParJour = new HashMap<>();
    for (String dateStr : listeDate) {
      try {
        LocalDate dateLocal = LocalDate.parse(dateStr, formatter);
        HeureDePointe[] hdps = HeureDePointe.getHeuresDePointePourDate(dateLocal, idSupport, connGlobal);
        heuresDePointeParJour.put(dateStr, hdps);
      } catch (Exception e) { }
    }
    
    String temp = "<div class=\"modal fade\" id=\"linkModal\" tabindex=\"-1\" role=\"dialog\"><div style='width:60%;background:transparent;' class=\"modal-dialog modal-dialog-centered\" role=\"dialog\"><div style=\"border-radius:16px;padding:15px;overflow-y:auto;height:80vh\" class=\"modal-content\"><div class=\"modal-body\"><div id=\"modalContent\"></div></div></div></div></div>";
    String bute = "reservation/reservation-details-calendrier.jsp";
%>
<div class="content-wrapper">
  <section class="content-header"><h1><i class="fa fa-calendar"></i> Grille de diffusion</h1></section>
  <div class="week-nav">
    <a href="<%=lienPrecedent%>" class="btn btn-default"><i class="fa fa-chevron-left"></i></a>
    <span class="week-range">Semaine du <%=debutEtFinDeSemaine[0]%> au <%=debutEtFinDeSemaine[1]%></span>
    <a href="<%=lienSuivant%>" class="btn btn-default"><i class="fa fa-chevron-right"></i></a>
  </div>
  <div style="width:100%;display:flex;justify-content:center">
    <form class="col-md-6 col-xs-12" action="<%=lien%>" method="Get" style="padding:10px;margin:5px;display:flex;align-items:end;">
      <div class='form-input col-md-3 col-xs-12'>
        <label class="nopadding fontinter labelinput">Support</label>
        <select class="form-control" name="idSupport">
          <option value="">Tous</option>
          <% for (Support s : supports) { %>
          <option <%=(idSupport != null && idSupport.equals(s.getId())) ? "selected" : ""%> value="<%=s.getId()%>"><%=s.getVal()%></option>
          <% } %>
        </select>
      </div>
      <div class='form-input col-md-3 col-xs-12'>
        <label class="nopadding fontinter labelinput">Type Service</label>
        <select class="form-control" name="idCategorieIngredient">
          <option value="">Tous</option>
          <% for (CategorieIngredient c : categorieIngredients) { %>
          <option <%=(idTypeService != null && idTypeService.equals(c.getId())) ? "selected" : ""%> value="<%=c.getId()%>"><%=c.getVal()%></option>
          <% } %>
        </select>
      </div>
      <div class="form-input col-md-3 col-xs-12">
        <label class="nopadding fontinter labelinput">Date</label>
        <input class='form-control' type='date' value='<%=CalendarUtil.castDateToFormat(dateEncours, formatter, DateTimeFormatter.ofPattern("yyyy-MM-dd"))%>' name='d'>
      </div>
      <input type='hidden' value='<%=bute%>' name='but'>
      <div class="form-input col-md-3 col-xs-12">
        <button class="btn btn-success" style="width:100%;height:32px" type="submit">Afficher</button>
      </div>
    </form>
  </div>
  <div style="display:flex;justify-content:center;gap:20px;padding:10px;margin-bottom:10px;">
    <span class="heure-pointe-legend"><i class="fa fa-fire" style="color:#ff5722;"></i> Heure de pointe (majoration appliquee)</span>
    <a href="<%=lien%>?but=categorieheure/heuredepointe-liste.jsp" class="btn btn-sm btn-warning"><i class="fa fa-cog"></i> Configurer</a>
  </div>
  <section class="content">
    <div class="row">
      <div class="col-xs-12 calendar-scroll">
        <table class="calendar-grid">
          <thead>
          <tr>
            <th class="calendar-cell-title">Horaire</th>
            <% for (int i = 0; i < listeDate.length; i++) { %>
            <th class="day-btn" onclick="ouvrirModal(event,'moduleLeger.jsp?but=reservation/inc/reservation-popup.jsp&daty=<%=listeDate[i]%>&idSupport=<%=idSupport%>&idCategorieIngredient=<%=idTypeService%>','modalContent')"><%=listeDate[i]%></th>
            <% } %>
            <th class="calendar-cell-title">Total Plage</th>
          </tr>
          </thead>
          <tbody>
          <%
            double[] montantParJour = new double[listeDate.length];
            double[] majorationParJour = new double[listeDate.length];
            for (int i = 0; i < listeDate.length; i++) { montantParJour[i] = 0; majorationParJour[i] = 0; }
            
            for (int i = 0; i < listeHoraire.size(); i++) {
              LocalTime[] intervales = listeHoraire.get(i);
              double montantTotalLigne = 0;
              double majorationTotalLigne = 0;
          %>
          <tr>
            <td class="calendar-cell-title"><%=intervales[0]%></td>
            <% for (int j = 0; j < listeDate.length; j++) {
              Map<ReservationDetailsAvecDiffusion, String> reservationsMap = eta.getReservationByTimeWithPosition(intervales, listeDate[j]);
              ReservationDetailsAvecDiffusion[] reservations = reservationsMap.keySet().toArray(new ReservationDetailsAvecDiffusion[]{});
              
              boolean estHeureDePointe = false;
              HeureDePointe[] hdpsJour = heuresDePointeParJour.get(listeDate[j]);
              if (hdpsJour != null && hdpsJour.length > 0) {
                LocalTime debutPlage = intervales[0];
                LocalTime finPlage = intervales[1];
                for (HeureDePointe hdp : hdpsJour) {
                  try {
                    String hdpDebut = hdp.getHeureDebut();
                    String hdpFin = hdp.getHeureFin();
                    if (hdpDebut != null && hdpFin != null) {
                      if (hdpDebut.length() == 5) hdpDebut += ":00";
                      if (hdpFin.length() == 5) hdpFin += ":00";
                      LocalTime debutPointe = LocalTime.parse(hdpDebut);
                      LocalTime finPointe = LocalTime.parse(hdpFin);
                      if (!(finPlage.isBefore(debutPointe) || finPlage.equals(debutPointe) || debutPlage.isAfter(finPointe) || debutPlage.equals(finPointe))) {
                        estHeureDePointe = true;
                        break;
                      }
                    }
                  } catch (Exception e) { }
                }
              }
              
              double montantPlage = 0;
              double majorationPlage = 0;
              
              if (reservations != null && reservations.length > 0) {
                for (ReservationDetailsAvecDiffusion r : reservations) {
                  if (r == null) continue;
                  try {
                    LocalTime heureDebutDiffusion = LocalTime.parse(r.getHeure());
                    int dureeTotaleSecondes = (r.getDuree() != null && !r.getDuree().isEmpty()) ? Integer.parseInt(r.getDuree()) : 0;
                    LocalTime heureFinDiffusion = heureDebutDiffusion.plusSeconds(dureeTotaleSecondes);
                    LocalTime debutIntersection = heureDebutDiffusion.isAfter(intervales[0]) ? heureDebutDiffusion : intervales[0];
                    LocalTime finIntersection = heureFinDiffusion.isBefore(intervales[1]) ? heureFinDiffusion : intervales[1];
                    long dureeIntersection = 0;
                    if (debutIntersection.isBefore(finIntersection) || debutIntersection.equals(finIntersection)) {
                      dureeIntersection = java.time.Duration.between(debutIntersection, finIntersection).getSeconds();
                    }
                    double proportion = (dureeTotaleSecondes > 0) ? (double) dureeIntersection / dureeTotaleSecondes : 1.0;
                    montantPlage += r.getMontantTtc() * proportion;
                    
                    if (estHeureDePointe && hdpsJour != null && dureeIntersection > 0) {
                      double montantReservationDansPlage = r.getMontantTtc() * proportion;
                      for (HeureDePointe hdp : hdpsJour) {
                        try {
                          String hdpDebut = hdp.getHeureDebut();
                          String hdpFin = hdp.getHeureFin();
                          if (hdpDebut != null && hdpFin != null) {
                            if (hdpDebut.length() == 5) hdpDebut += ":00";
                            if (hdpFin.length() == 5) hdpFin += ":00";
                            LocalTime debutPointe = LocalTime.parse(hdpDebut);
                            LocalTime finPointe = LocalTime.parse(hdpFin);
                            LocalTime debutIntersHdp = debutIntersection.isAfter(debutPointe) ? debutIntersection : debutPointe;
                            LocalTime finIntersHdp = finIntersection.isBefore(finPointe) ? finIntersection : finPointe;
                            if (debutIntersHdp.isBefore(finIntersHdp)) {
                              long dureeIntersHdp = java.time.Duration.between(debutIntersHdp, finIntersHdp).getSeconds();
                              if (dureeIntersHdp > 0 && dureeIntersection > 0) {
                                double proportionHdp = (double) dureeIntersHdp / dureeIntersection;
                                majorationPlage += montantReservationDansPlage * proportionHdp * (hdp.getPourcentageMajoration() / 100.0);
                              }
                            }
                          }
                        } catch (Exception e) { }
                      }
                    }
                  } catch (Exception e) { }
                }
              }
              
              montantTotalLigne += montantPlage;
              majorationTotalLigne += majorationPlage;
              montantParJour[j] += montantPlage;
              majorationParJour[j] += majorationPlage;
              
              String classeHeurePointe = estHeureDePointe ? "heure-pointe" : "";
              
              if (reservations != null && reservations.length > 0) {
            %>
            <td class="calendar-cell <%=classeHeurePointe%>">
              <% if (estHeureDePointe) { %><span class="heure-pointe-indicator"><i class="fa fa-fire"></i> HP</span><% } %>
              <% for (int k = 0; k < reservations.length && k < 2; k++) {
                if (reservations[k] != null) {
                  String position = reservationsMap.get(reservations[k]);
                  String styleBorder = "border-left: 3px solid " + reservations[k].getCodeCouleur();
                  String notePosition = "";
                  if ("debut".equals(position)) { notePosition = "(debut -)"; styleBorder += "; border-right: 2px dashed #ff9800"; }
                  else if ("fin".equals(position)) { notePosition = "(- fin)"; styleBorder = "border-left: 2px dashed #4caf50; border-right: 3px solid " + reservations[k].getCodeCouleur(); }
                  else if ("suite".equals(position)) { notePosition = "(- suite -)"; styleBorder = "border-left: 2px dashed #2196f3; border-right: 2px dashed #2196f3"; }
              %>
              <div class="event" onclick="ouvrirModal(event,'moduleLeger.jsp?but=reservation/reservation-details-fiche.jsp&id=<%=reservations[k].getId()%>','modalContent')">
                <div class="event-title" style="<%=styleBorder%>"><p><%=reservations[k].getRemarque()%> <span style="font-size:9px;color:#888;"><%=notePosition%></span></p></div>
                <div class="event-hours"><%=reservations[k].getHeure()%></div>
              </div>
              <% } } %>
              <% if (reservations.length > 2) { %>
              <a class="btn btn-primary btn-xs" style="width:100%;margin-top:4px" onclick="ouvrirModal(event,'moduleLeger.jsp?but=reservation/inc/reservation-popup.jsp&bute=<%=bute%>&daty=<%=listeDate[j]%>&heureDebut=<%=intervales[0]%>&heureFin=<%=intervales[1]%>&idSupport=<%=idSupport%>&idCategorieIngredient=<%=idTypeService%>','modalContent')"><i class="fa fa-search-plus"></i> Voir plus (<%=reservations.length - 2%>)</a>
              <% } %>
              <% if (eta.getResteADiffuser(intervales) > 0) { %>
              <a class="btn btn-success btn-xs" style="width:100%;margin-top:4px" href="<%=lien%>?but=reservation/reservation-groupe-saisie.jsp&date=<%=CalendarUtil.castDateToFormat(listeDate[j], formatter, DateTimeFormatter.ofPattern("yyyy-MM-dd"))%>&heure=<%=intervales[0].format(DateTimeFormatter.ofPattern("HH:mm:ss"))%>&idSupport=<%=idSupport%>"><i class="fa fa-plus"></i> <%=CalendarUtil.secondToHMS(eta.getResteADiffuser(intervales))%></a>
              <% } %>
              <% if (montantPlage > 0) { %>
              <div class="montant-base"><i class="fa fa-money"></i> <%=Utilitaire.formaterAr(montantPlage)%> Ar</div>
              <% } %>
              <% if (majorationPlage > 0) { %>
              <div class="majoration-badge"><i class="fa fa-plus-circle"></i> +<%=Utilitaire.formaterAr(majorationPlage)%> Ar</div>
              <div class="total-avec-maj"><i class="fa fa-calculator"></i> <%=Utilitaire.formaterAr(montantPlage + majorationPlage)%> Ar</div>
              <% } %>
            </td>
            <% } else { %>
            <td class="calendar-cell <%=classeHeurePointe%>">
              <% if (estHeureDePointe) { %><span class="heure-pointe-indicator"><i class="fa fa-fire"></i> HP</span><% } %>
              <a href="<%=lien%>?but=reservation/reservation-groupe-saisie.jsp&date=<%=CalendarUtil.castDateToFormat(listeDate[j], formatter, DateTimeFormatter.ofPattern("yyyy-MM-dd"))%>&idSupport=<%=idSupport%>&heure=<%=intervales[0].format(DateTimeFormatter.ofPattern("HH:mm:ss"))%>"><i class="fa fa-plus"></i></a>
            </td>
            <% } } %>
            <td class="calendar-cell">
              <% if (montantTotalLigne > 0) { %>
              <div><%=Utilitaire.formaterAr(montantTotalLigne)%> Ar</div>
              <% if (majorationTotalLigne > 0) { %>
              <div class="majoration-badge">+<%=Utilitaire.formaterAr(majorationTotalLigne)%></div>
              <div class="total-avec-maj"><%=Utilitaire.formaterAr(montantTotalLigne + majorationTotalLigne)%> Ar</div>
              <% } %>
              <% } else { %><span style="color:#999;">-</span><% } %>
            </td>
          </tr>
          <% } %>
          </tbody>
          <tfoot>
          <tr>
            <th class="calendar-cell-title">TOTAL</th>
            <%
              double grandTotal = 0;
              double grandTotalMaj = 0;
              for (int k = 0; k < listeDate.length; k++) {
                Double[] tab = total.get(listeDate[k]);
                double montantJour = (tab != null) ? tab[0] : 0;
                double dureeJour = (tab != null) ? tab[1] : 0;
                grandTotal += montantJour;
                grandTotalMaj += majorationParJour[k];
            %>
            <th class="calendar-footer">
              <div class="total-box">
                <p class="montant-base">Base: <strong><%=Utilitaire.formaterAr(montantJour)%> Ar</strong></p>
                <% if (majorationParJour[k] > 0) { %>
                <div class="majoration-total">
                  <i class="fa fa-fire" style="color:#ff5722;"></i> +<%=Utilitaire.formaterAr(majorationParJour[k])%> Ar
                </div>
                <p class="montant-final"><i class="fa fa-calculator"></i> Total: <%=Utilitaire.formaterAr(montantJour + majorationParJour[k])%> Ar</p>
                <% } %>
                <p style="font-size:10px;color:#888;"><%=CalendarUtil.secondToHMS(Math.round(dureeJour))%></p>
              </div>
            </th>
            <% } %>
            <th class="calendar-footer">
              <div class="total-box" style="background:#e3f2fd;">
                <p style="font-size:14px;font-weight:bold;">TOTAL SEMAINE</p>
                <p class="montant-base">Base: <%=Utilitaire.formaterAr(grandTotal)%> Ar</p>
                <% if (grandTotalMaj > 0) { %>
                <div class="majoration-total" style="background:linear-gradient(135deg,#ffccbc,#ffab91);">
                  <i class="fa fa-fire" style="color:#ff5722;"></i> +<%=Utilitaire.formaterAr(grandTotalMaj)%> Ar
                </div>
                <p class="montant-final" style="font-size:16px;"><i class="fa fa-calculator"></i> TOTAL: <%=Utilitaire.formaterAr(grandTotal + grandTotalMaj)%> Ar</p>
                <% } else { %>
                <p class="montant-final" style="font-size:16px;"><%=Utilitaire.formaterAr(grandTotal)%> Ar</p>
                <% } %>
              </div>
            </th>
          </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </section>
</div>
<% out.println(temp); %>
<script>
function affModal(idResa) {
  var checkboxes = document.querySelectorAll('input[name="id"]:checked');
  if (checkboxes.length == 0) { alert("vous devez cocher"); return; }
  $('#linkModal2').modal('show').css({'opacity':'1','padding':'25rem 0px 0px 0px'});
}
</script>
<% } catch (Exception e) { e.printStackTrace(); } finally { if (connGlobal != null) try { connGlobal.close(); } catch (Exception ex) { } } %>
