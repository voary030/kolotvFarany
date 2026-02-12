<%--
  Created by IntelliJ IDEA.
  User: tokiniaina_judicael
  Date: 11/04/2025
  Time: 10:45
  To change this template use File | Settings | File Templates.
--%>
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
.form-input {
  margin-bottom: 0px;
}
table td{
  max-width: 30%;
}
.planning-content p{
  font-weight: bold;
  margin: 0px;
  font-size: 10px;
}
.calendar-grid {
  width: 100%;
  background-color: white;
  overflow: hidden;
  border-radius: 2px;
}
.calendar-cell {
  border-style: solid;
  border-width: 0.5px;
  border-color: #c8c8c8;
  padding: 20px 10px;
  text-align: center;
}
.event{
  display: flex;
  justify-content: space-between;
  gap: 2px;
  align-items: flex-start;
  font-size: 16px;
  line-height: 1.2;
  text-overflow: ellipsis;
}
.day-btn {
  cursor: pointer;
  color: white;
  background-color: #003695db;
  padding: 10px 2px;
  text-align: center;
  font-size: 18px;
  border-style: solid;
  border-width: 0.5px;
  border-color: #c8c8c8;
  font-weight: bold;
  transition: 0.3s ease;
}
.day-btn:hover{
  color: rgba(255, 255, 255, 0.87);
  background-color: #0b3881;
}
.event-title {
  width: 80%;
  background: #f4f4f4;
  border-left: 3px solid #0e66ff;
  padding: 2px 6px;
  margin: 2px 0;
  border-radius: 3px;
  overflow: hidden;
  cursor: pointer;
  transition: 0.3s ease;
}
.event-title:hover{
  box-shadow: 0 0 5px #616161;
}
.event-title p{
  margin: 0;
  padding: 0;
}
.event-hours{
  width: fit-content;
  padding: 2px 2px;
  color: #333;
}
.calendar-cell-title{
  padding: 10px 2px;
  text-align: center;
  font-size: 18px;
  background-color: rgba(231, 231, 231, 0.334);
  border-style: solid;
  border-width: 0.5px;
  border-color: #c8c8c8;
  font-weight: bold;
}
.calendar-footer{
  border-style: solid;
  border-width: 0.5px;
  border-color: #c8c8c8;
  padding: 5px;
}
.heure-pointe-indicator {
  background: linear-gradient(135deg, #ff6b6b, #ffa500);
  color: white;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 10px;
  font-weight: bold;
  margin-left: 4px;
}
.majoration-badge {
  background-color: #ff9800;
  color: white;
  padding: 2px 5px;
  border-radius: 3px;
  font-size: 10px;
  margin-top: 2px;
  display: inline-block;
}
.calendar-cell.heure-pointe {
  background: linear-gradient(135deg, rgba(255, 152, 0, 0.1), rgba(255, 107, 107, 0.1));
}
.heure-pointe-legend {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 5px 10px;
  background: linear-gradient(135deg, rgba(255, 152, 0, 0.2), rgba(255, 107, 107, 0.2));
  border-radius: 5px;
  font-size: 12px;
  margin-right: 10px;
}
.total-majoration {
  color: #ff5722;
  font-weight: bold;
}
</style>
<% try{
    String lien = (String) session.getValue("lien");
    user.UserEJB u= (user.UserEJB) session.getValue("u");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    String dateEncours = request.getParameter("d");
    if (dateEncours!=null){
      dateEncours = CalendarUtil.castDateToFormat(dateEncours,DateTimeFormatter.ofPattern("yyyy-MM-dd"),formatter);
    }
    if (dateEncours == null || dateEncours.trim().isEmpty()) {
      LocalDate aujourdHui = LocalDate.now();
      dateEncours = aujourdHui.format(formatter);
    }
    String debutEtFinDeSemaine[]=CalendarUtil.getDebutEtFinDeSemaine(dateEncours);
    String idSupport = request.getParameter("idSupport");
    if (idSupport==null){
      idSupport = "SUPP002";
    }
    String idTypeService = request.getParameter("idCategorieIngredient");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
    EtatReservationDetails eta=new EtatReservationDetails(idSupport,idTypeService,debutEtFinDeSemaine[0],debutEtFinDeSemaine[1]);
    String[] listeDate=eta.getListeDate();
    List<LocalTime[]> listeHoraire=eta.getHoraire();
    HashMap<String,Double[]> total = eta.getTotal();
    String urlComplete = request.getRequestURL().toString();
    String queryString = request.getQueryString();
    if (queryString != null) {
      urlComplete += "?" + queryString;
    }
    String lienPrecedent = UrlUtils.modifierParametreDansUrl(urlComplete,"d" ,CalendarUtil.castDateToFormat(debutEtFinDeSemaine[2],formatter,DateTimeFormatter.ofPattern("yyyy-MM-dd")));
    String lienSuivant = UrlUtils.modifierParametreDansUrl(urlComplete,"d" ,CalendarUtil.castDateToFormat(debutEtFinDeSemaine[3],formatter,DateTimeFormatter.ofPattern("yyyy-MM-dd")));
    Support [] supports = (Support[]) CGenUtil.rechercher(new Support(),null,null,null,"");
    CategorieIngredient [] categorieIngredients = (CategorieIngredient[]) CGenUtil.rechercher(new CategorieIngredient(),null,null,null,"");
  String temp="";
  temp=temp+ "<div class=\"modal fade\" id=\"linkModal\" tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"linkModalLabel\" aria-hidden=\"true\">\r\n" +
          "  <div style='width:60%;background:transparent;' class=\"modal-dialog modal-dialog-centered\" role=\"dialog\">\r\n" +
          "    <div style=\"border-radius: 16px;padding:15px;overflow-y:auto;height:80vh\" class=\"modal-content\">\r\n" +
          "      <div class=\"modal-body\">\r\n"+
          "       <div id=\"modalContent\">\r\n>";
  temp +=                "</div>\r\n" +
          "    </div>\r\n" +
          "   </div>\r\n" +
          "  </div>\r\n" +
          "</div>";
  String bute = "reservation/reservation-details-calendrier.jsp";
%>
<div class="content-wrapper">
  <section class="content-header">
    <h1> <i class="fa fa-calendar"></i>&nbsp;&nbsp;&nbsp; Grille de diffusion</h1>
  </section>
  <div class="week-nav">
    <a href="<%=lienPrecedent%>" id="prev-week" class="btn btn-default">
      <i class="fa fa-chevron-left"></i>
    </a>
    <span class="week-range" id="week-range">Semaine du <%=debutEtFinDeSemaine[0]%> au <%=debutEtFinDeSemaine[1]%></span>
    <a href="<%=lienSuivant%>" id="next-week" class="btn btn-default">
      <i class="fa fa-chevron-right"></i>
    </a>
  </div>
  <div style="width: 100%;display: flex;justify-content: center">
    <form class="col-md-6 col-xs-12" action="<%=lien%>" method="Get" style="padding: 10px;margin: 5px;border-radius: 5px;display: flex;align-items: end;">
      <div class='form-input col-md-4 col-xs-12'>
        <label class="nopadding fontinter labelinput">Support</label>
        <select class="form-control" name="idSupport">
          <option value="">Tous</option>
          <% for (Support s:supports) {
            String isSelected = "";
            if(idSupport!=null && idSupport.equals(s.getId())){
                isSelected="selected";
              }
          %>
             <option <%=isSelected%> value="<%=s.getId()%>"><%=s.getVal()%></option>
          <% } %>
        </select>
      </div>
      <div class='form-input col-md-4 col-xs-12'>
        <label class="nopadding fontinter labelinput">Type Service</label>
        <select class="form-control" name="idCategorieIngredient">
          <option value="">Tous</option>
          <% for (CategorieIngredient c:categorieIngredients) {
            String isSelected = "";
            if(idTypeService!=null && idTypeService.equals(c.getId())){
              isSelected="selected";
            }
          %>
          <option <%=isSelected%> value="<%=c.getId()%>"><%=c.getVal()%></option>
          <% } %>
        </select>
      </div>
      <div class="form-input col-md-4 col-xs-12">
        <label class="nopadding fontinter labelinput">Date</label>
        <input class='form-control' type='date' value='<%=CalendarUtil.castDateToFormat(dateEncours,formatter,DateTimeFormatter.ofPattern("yyyy-MM-dd"))%>' name='d'>
      </div>
      <input type='hidden' value='<%=bute%>' name='but'>
      <div class="form-input col-md-4 col-xs-12">
        <button class="btn btn-success" style="width: 100%;height: 32px;text-align: center" type="submit">Afficher</button>
      </div>
    </form>
  </div>
  <div class="legend" style="display: flex; justify-content: center; gap: 20px; padding: 10px; margin-bottom: 10px;">
    <span class="heure-pointe-legend">
      <i class="fa fa-fire" style="color: #ff5722;"></i> Heure de pointe (majoration appliquee)
    </span>
    <a href="<%=lien%>?but=categorieheure/heuredepointe-liste.jsp" class="btn btn-sm btn-warning">
      <i class="fa fa-cog"></i> Configurer les heures de pointe
    </a>
  </div>
  <section class="content">
    <div class="row">
      <div class="col-xs-12 calendar-scroll">
        <table class="calendar-grid">
          <thead>
          <tr>
            <th class="calendar-cell-title">Horaire</th>
            <% for(int i=0;i<listeDate.length;i++) { %>
            <th class="day-btn" onclick="ouvrirModal(event,'moduleLeger.jsp?but=reservation/inc/reservation-popup.jsp&daty=<%=listeDate[i]%>&idSupport=<%=idSupport%>&idCategorieIngredient=<%=idTypeService%>','modalContent')">
              <%=listeDate[i]%>
            </th>
            <% } %>
            <th class="calendar-cell-title">Total Plage</th>
          </tr>
          </thead>
          <tbody>
          <tr>
              <% for(int i=0;i<listeHoraire.size();i++) {
                LocalTime [] intervales = listeHoraire.get(i);
                double montantTotalLigne = 0;
              %>
          <tr>
            <td class="calendar-cell-title"><%=intervales[0]%></td>
            <% for(int j=0;j<listeDate.length;j++) { %>
            <%
              Map<ReservationDetailsAvecDiffusion, String> reservationsMap = eta.getReservationByTimeWithPosition(intervales,listeDate[j]);
              ReservationDetailsAvecDiffusion [] reservations = reservationsMap.keySet().toArray(new ReservationDetailsAvecDiffusion[]{});
              boolean estHeureDePointe = false;
              double majorationPlage = 0;
              try {
                Connection connHdp = new UtilDB().GetConn();
                try {
                  estHeureDePointe = EtatReservationDetails.estEnHeureDePointe(
                    intervales[0].format(DateTimeFormatter.ofPattern("HH:mm:ss")),
                    intervales[1].format(DateTimeFormatter.ofPattern("HH:mm:ss")),
                    listeDate[j], idSupport, connHdp);
                } finally {
                  if(connHdp != null) connHdp.close();
                }
              } catch(Exception eHdp) { eHdp.printStackTrace(); }
              double montantPlage = 0;
              double montantPlageFinal = 0;
              if(reservations != null) {
                for(ReservationDetailsAvecDiffusion r : reservations) {
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
                  montantPlageFinal += r.getMontantFinal() * proportion;
                  if (estHeureDePointe && dureeTotaleSecondes > 0) {
                    try {
                      Connection connMaj = new UtilDB().GetConn();
                      try {
                        double montantReservationDansPlage = r.getMontantTtc() * proportion;
                        double maj = HeureDePointe.calculerMajoration(
                          debutIntersection.format(DateTimeFormatter.ofPattern("HH:mm:ss")),
                          (int) dureeIntersection,
                          montantReservationDansPlage,
                          LocalDate.parse(listeDate[j], formatter),
                          idSupport, connMaj);
                        majorationPlage += maj;
                      } finally {
                        if(connMaj != null) connMaj.close();
                      }
                    } catch(Exception eMaj) { eMaj.printStackTrace(); }
                  }
                }
              }
              montantTotalLigne += montantPlage;
              String classeHeurePointe = estHeureDePointe ? "heure-pointe" : "";
              if(reservations != null && reservations.length>0) { %>
            <td class="calendar-cell <%=classeHeurePointe%>">
              <% if(estHeureDePointe) { %>
                <span class="heure-pointe-indicator" title="Heure de pointe - Majoration appliquee">
                  <i class="fa fa-fire"></i> HP
                </span>
              <% } %>
              <% for (int k=0;k<reservations.length && k<2;k++) {
                if (reservations[k] != null) { 
                  String position = reservationsMap.get(reservations[k]);
                  String notePosition = "";
                  String styleBorder = "border-left: 3px solid " + reservations[k].getCodeCouleur();
                  if ("debut".equals(position)) {
                    notePosition = "<span style='font-size:9px;color:#ff9800;font-weight:bold;'>(debut -)</span>";
                    styleBorder = "border-left: 3px solid " + reservations[k].getCodeCouleur() + "; border-right: 2px dashed #ff9800";
                  } else if ("fin".equals(position)) {
                    notePosition = "<span style='font-size:9px;color:#4caf50;font-weight:bold;'>(- fin)</span>";
                    styleBorder = "border-left: 2px dashed #4caf50; border-right: 3px solid " + reservations[k].getCodeCouleur();
                  } else if ("suite".equals(position)) {
                    notePosition = "<span style='font-size:9px;color:#2196f3;font-weight:bold;'>(- suite -)</span>";
                    styleBorder = "border-left: 2px dashed #2196f3; border-right: 2px dashed #2196f3";
                  }
              %>
              <div class="event" onclick="ouvrirModal(event,'moduleLeger.jsp?but=reservation/reservation-details-fiche.jsp&id=<%=reservations[k].getId()%>','modalContent')">
                <div class="event-title" style="<%=styleBorder%>">
                  <p><%=reservations[k].getRemarque()%> <%=notePosition%></p>
                </div>
                <div class="event-hours"><%=reservations[k].getHeure()%></div>
              </div>
              <% } }%>
              <% if (reservations.length > 2) { %>
                  <a class="btn btn-primary" style="width: 100%;margin-top: 4px" onclick="ouvrirModal(event,'moduleLeger.jsp?but=reservation/inc/reservation-popup.jsp&bute=<%=bute%>&daty=<%=listeDate[j]%>&heureDebut=<%=intervales[0]%>&heureFin=<%=intervales[1]%>&idSupport=<%=idSupport%>&idCategorieIngredient=<%=idTypeService%>','modalContent')">
                      <i class="fa fa-search-plus"></i> Voir plus (<%=reservations.length-2%>)
                  </a>
                  <p>Montant TTC:<%=Utilitaire.formaterAr(montantPlage)%>Ar</p>
                  <p>Montant Final:<%=Utilitaire.formaterAr(montantPlageFinal)%>Ar</p>
              <% } %>
              <% if(eta.getResteADiffuser(intervales)>0) { %>
                <a class="btn btn-success" style="width: 100%;margin-top: 4px" href="<%=lien%>?but=reservation/reservation-groupe-saisie.jsp&date=<%=CalendarUtil.castDateToFormat(listeDate[j],formatter,DateTimeFormatter.ofPattern("yyyy-MM-dd"))%>&heure=<%=intervales[0].format(DateTimeFormatter.ofPattern("HH:mm:ss"))%>&idSupport=<%=idSupport%>">
                  <i class="fa fa-plus"></i> <%=CalendarUtil.secondToHMS(eta.getResteADiffuser(intervales))%>
                </a>
              <% } %>
              <% if(montantPlage > 0) { %>
              <div><i class="fa fa-money"></i> <%=Utilitaire.formaterAr(montantPlage)%> Ar</div>
              <% } %>
              <% if(majorationPlage > 0) { %>
              <div class="majoration-badge" title="Majoration heure de pointe">
                <i class="fa fa-plus-circle"></i> +<%=Utilitaire.formaterAr(majorationPlage)%> Ar
              </div>
              <% } %>
            </td>
            <%  } else { %>
            <td class="calendar-cell">
              <a href="<%=lien%>?but=reservation/reservation-groupe-saisie.jsp&date=<%=CalendarUtil.castDateToFormat(listeDate[j],formatter,DateTimeFormatter.ofPattern("yyyy-MM-dd"))%>&idSupport=<%=idSupport%>&heure=<%=intervales[0].format(DateTimeFormatter.ofPattern("HH:mm:ss"))%>">
                <i class="fa fa-plus"></i>
              </a>
            </td>
            <% } %>
            <%  } %>
            <td class="calendar-cell">
              <% if(montantTotalLigne > 0) { %>
              <div><%=Utilitaire.formaterAr(montantTotalLigne)%> Ar</div>
              <% } else { %>
              <span style="color: #999;">-</span>
              <% } %>
            </td>
          </tr>
          <%  } %>
          </tbody>
          <tfoot>
          <tr>
            <th class="calendar-cell-title">TOTAL</th>
            <% 
              double grandTotal = 0;
              double grandTotalMajoration = 0;
              for(int k=0;k<listeDate.length;k++) {
              Double [] tab = total.get(listeDate[k]);
              double majorationJour = eta.getMajorationHeurePointe(listeDate[k]);
              grandTotal += tab[0];
              grandTotalMajoration += majorationJour;
            %>
              <th class="calendar-footer">
                <p>Montant : <strong><%=Utilitaire.formaterAr(tab[0])%></strong></p>
                <% if(majorationJour > 0) { %>
                <p class="total-majoration" title="Majoration heure de pointe">
                  <i class="fa fa-fire"></i> +<%=Utilitaire.formaterAr(majorationJour)%>
                </p>
                <% } %>
                <p>Duree de diffusion : <strong><%=CalendarUtil.secondToHMS(Math.round(tab[1]))%></strong></p>
              </th>
            <%  } %>
            <th class="calendar-footer">
              <p>TOTAL SEMAINE</p>
              <p><%=Utilitaire.formaterAr(grandTotal)%> Ar</p>
              <% if(grandTotalMajoration > 0) { %>
              <p class="total-majoration" title="Total des majorations heures de pointe">
                <i class="fa fa-fire"></i> Majorations: +<%=Utilitaire.formaterAr(grandTotalMajoration)%> Ar
              </p>
              <p><strong>Total avec majorations: <%=Utilitaire.formaterAr(grandTotal + grandTotalMajoration)%> Ar</strong></p>
              <% } %>
            </th>
          </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </section>
</div>
<% out.println(temp);%>
<script>
  function affModal(idResa) {
    var checkboxes = document.querySelectorAll('input[name="id"]:checked');
    if (checkboxes.length==0){
      alert("vous devez cocher");
      return;
    }
    var modalElement = $('#linkModal2');
    if (modalElement.length) {
      modalElement.modal('show');
      modalElement.css({
        'opacity': '1',
        'padding': '25rem 0px 0px 0px'
      });
    }
  }
  function sendSingnalement(){
    var checkboxes = document.querySelectorAll('input[name="id"]:checked');
    var description = document.getElementById("description").value;
    if (description===""){
      alert("Veuillez ajouter une description");
      return;
    }
    const formData = new URLSearchParams();
    Array.from(checkboxes).forEach(cb=>{
      formData.append('ids',cb.value);
    })
    formData.append('description',description);
    fetch('<%=request.getContextPath()%>/NotificationServlet?action=send_notif', {
      method: 'POST',
      headers:{
        'Content-Type':'application/x-www-form-urlencoded'
      },
      body: formData
    })
    .then(response => response.text())
    .then(data => {
        console.log("Reponse du serveur :", data);
        alert("Message envoye");
    })
    .catch(error => {
        console.error('Erreur:', error);
        alert("Une erreur est survenue.");
    });
  }
</script>
<% } catch (Exception e) {
    e.printStackTrace();
  } %>
