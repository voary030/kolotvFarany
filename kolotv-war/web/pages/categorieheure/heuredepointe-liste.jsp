<%@page import="affichage.PageRecherche" %>
    <%@ page import="categorieheure.HeureDePointeCpl" %>
        <%@ page import="utilitaire.Utilitaire" %>

            <%-- Créé par: rachriss Date: 05/02/2026 Description: Liste des configurations d'heures de pointe --%>

                <% try{ HeureDePointeCpl t=new HeureDePointeCpl(); String listeCrt[]={"id", "jourSemaine" , "heureDebut"
                    , "heureFin" , "pourcentageMajoration" , "idSupportLib" , "etatLib" }; String
                    listeInt[]={"heureDebut", "heureFin" , "pourcentageMajoration" }; String
                    libEntete[]={"id", "jourSemaine" , "heureDebut" , "heureFin" , "pourcentageMajoration"
                    , "idSupportLib" , "etatLib" }; PageRecherche pr=new PageRecherche(t, request, listeCrt, listeInt,
                    3, libEntete, libEntete.length); pr.setTitre("Configuration des Heures de Pointe");
                    pr.setUtilisateur((user.UserEJB) session.getValue("u")); pr.setLien((String)
                    session.getValue("lien")); pr.setApres("categorieheure/heuredepointe-liste.jsp");
                    pr.getFormu().getChamp("id").setLibelle("Id");
                    pr.getFormu().getChamp("jourSemaine").setLibelle("Jour de la semaine");
                    pr.getFormu().getChamp("heureDebut1").setLibelle("Heure d&eacute;but min");
                    pr.getFormu().getChamp("heureDebut1").setType("time");
                    pr.getFormu().getChamp("heureDebut2").setLibelle("Heure d&eacute;but max");
                    pr.getFormu().getChamp("heureDebut2").setType("time");
                    pr.getFormu().getChamp("heureFin1").setLibelle("Heure fin min");
                    pr.getFormu().getChamp("heureFin1").setType("time");
                    pr.getFormu().getChamp("heureFin2").setLibelle("Heure fin max");
                    pr.getFormu().getChamp("heureFin2").setType("time");
                    pr.getFormu().getChamp("pourcentageMajoration1").setLibelle("Majoration min (%)");
                    pr.getFormu().getChamp("pourcentageMajoration2").setLibelle("Majoration max (%)");
                    pr.getFormu().getChamp("idSupportLib").setLibelle("Support");
                    pr.getFormu().getChamp("etatLib").setLibelle("&Eacute;tat"); String[] colSomme=null;
                    pr.creerObjetPage(libEntete, colSomme); String lienTableau[]={pr.getLien()
                    + "?but=categorieheure/heuredepointe-fiche.jsp" }; String colonneLien[]={"id"};
                    pr.getTableau().setLien(lienTableau); pr.getTableau().setColonneLien(colonneLien); String
                    libEnteteAffiche[]={"ID", "Jour" , "Heure de d&eacute;but" , "Heure de fin" , "Majoration (%)"
                    , "Support" , "&Eacute;tat" }; pr.getTableau().setLibelleAffiche(libEnteteAffiche); %>

                    <div class="content-wrapper">
                        <section class="content-header">
                            <h1><i class="fa fa-clock-o"></i>
                                <%= pr.getTitre() %>
                            </h1>
                            <div style="margin-top: 10px;">
                                <a href="<%=pr.getLien()%>?but=categorieheure/heuredepointe-saisie.jsp"
                                    class="btn btn-success">
                                    <i class="fa fa-plus"></i> Nouvelle heure de pointe
                                </a>
                            </div>
                        </section>

                        <section class="content">
                            <div class="box box-primary">
                                <div class="box-header with-border">
                                    <h3 class="box-title">Rechercher</h3>
                                    <div class="box-tools pull-right">
                                        <button type="button" class="btn btn-box-tool" data-widget="collapse">
                                            <i class="fa fa-minus"></i>
                                        </button>
                                    </div>
                                </div>
                                <div class="box-body">
                                    <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
                                        <% out.println(pr.getFormu().getHtmlEnsemble()); %>
                                    </form>
                                </div>
                            </div>

                            <div class="box box-info">
                                <div class="box-header with-border">
                                    <h3 class="box-title">Liste des heures de pointe</h3>
                                </div>
                                <div class="box-body">
                                    <% out.println(pr.getTableauRecap().getHtml()); %>
                                        <br>
                                        <% out.println(pr.getTableau().getHtml()); out.println(pr.getBasPage()); %>
                                </div>
                            </div>

                            <div class="callout callout-info">
                                <h4><i class="fa fa-info-circle"></i> Information</h4>
                                <p>Les heures de pointe permettent d'appliquer automatiquement une majoration sur les
                                    r&eacute;servations
                                    qui tombent dans les plages horaires configur&eacute;es. Si une r&eacute;servation
                                    chevauche partiellement
                                    une heure de pointe, seule la partie incluse dans la plage sera major&eacute;e.</p>
                            </div>
                        </section>
                    </div>
                    <% }catch(Exception e){ e.printStackTrace(); } %>