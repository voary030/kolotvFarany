<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="affichage.*" %>
<%@ page import="categorieheure.HeureDePointeCpl" %>
<%@ page import="bean.CGenUtil" %>

<%--
    Créé par : rachriss
    Date     : 05/02/2026
    Description :
    Fiche de consultation d'une configuration d'heure de pointe
--%>

<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String id = request.getParameter("id");

        HeureDePointeCpl hdp = new HeureDePointeCpl();
        hdp.setId(id);

        HeureDePointeCpl[] results = (HeureDePointeCpl[])
                CGenUtil.rechercher(hdp, null, null, null, "");

        if (results == null || results.length == 0) {
            throw new Exception("Heure de pointe non trouvée");
        }

        hdp = results[0];

        String pageModif = "categorieheure/heuredepointe-modif.jsp";
        String pageListe = "categorieheure/heuredepointe-liste.jsp";
        String classe = "categorieheure.HeureDePointe";
%>

<div class="content-wrapper">

    <section class="content-header">
        <h1>
            <a href="<%= lien %>?but=<%= pageListe %>" class="btn btn-default">
                <i class="fa fa-arrow-left"></i>
            </a>
            <i class="fa fa-clock-o"></i> Fiche Heure de Pointe
        </h1>
    </section>

    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">

                <div class="box box-primary">

                    <div class="box-header with-border">
                        <h3 class="box-title">Détails de la configuration</h3>
                        <div class="box-tools pull-right">
                            <span class="label label-<%= hdp.getEtat() == 1 ? "success" : "danger" %>">
                                <%= hdp.getEtatLib() %>
                            </span>
                        </div>
                    </div>

                    <div class="box-body">
                        <table class="table table-bordered">
                            <tr>
                                <th style="width: 30%">ID</th>
                                <td><%= hdp.getId() %></td>
                            </tr>
                            <tr>
                                <th>Jour de la semaine</th>
                                <td><strong><%= hdp.getJourSemaineFormate() %></strong></td>
                            </tr>
                            <tr>
                                <th>Plage horaire</th>
                                <td>
                                    <i class="fa fa-clock-o"></i>
                                    <%= hdp.getHeureDebut() %> - <%= hdp.getHeureFin() %>
                                </td>
                            </tr>
                            <tr>
                                <th>Pourcentage de majoration</th>
                                <td>
                                    <span class="label label-warning" style="font-size:14px;">
                                        +<%= hdp.getPourcentageFormate() %>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Support concerné</th>
                                <td><%= hdp.getSupportLibelle() %></td>
                            </tr>
                            <tr>
                                <th>État</th>
                                <td>
                                    <span class="label label-<%= hdp.getEtat() == 1 ? "success" : "danger" %>">
                                        <%= hdp.getEtatLib() %>
                                    </span>
                                </td>
                            </tr>
                        </table>

                        <div class="callout callout-info">
                            <h4>
                                <i class="fa fa-info-circle"></i> Fonctionnement
                            </h4>
                            <p>
                                Cette configuration applique une majoration de
                                <strong><%= hdp.getPourcentageFormate() %></strong>
                                sur toutes les réservations comprises dans la plage
                                <strong><%= hdp.getPlageHoraire() %></strong>
                                chaque <strong><%= hdp.getJourSemaineFormate() %></strong>.
                            </p>
                            <p>
                                Si une réservation chevauche partiellement cette plage,
                                seule la portion incluse dans l'heure de pointe sera
                                majorée proportionnellement.
                            </p>
                        </div>
                    </div>

                    <div class="box-footer">
                        <a href="<%= lien %>?but=apresTarif.jsp&id=<%= id %>&acte=delete&bute=<%= pageListe %>&classe=<%= classe %>"
                           class="btn btn-danger"
                           onclick="return confirm('Êtes-vous sûr de vouloir supprimer cette configuration ?');">
                            <i class="fa fa-trash"></i> Supprimer
                        </a>

                        <a href="<%= lien %>?but=<%= pageModif %>&id=<%= id %>"
                           class="btn btn-warning pull-right">
                            <i class="fa fa-edit"></i> Modifier
                        </a>
                    </div>

                </div>
            </div>
        </div>
    </section>
</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<script type="text/javascript">
    alert("Erreur : <%= e.getMessage() %>");
    history.back();
</script>
<%
    }
%>
