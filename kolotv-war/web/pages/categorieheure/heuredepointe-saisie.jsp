<%@page import="affichage.PageInsert" %>
    <%@page import="user.UserEJB" %>
        <%@ page import="categorieheure.HeureDePointe" %>
            <%@ page import="support.Support" %>
                <%@ page import="bean.CGenUtil" %>

                    <%-- Créé par: rachriss Date: 05/02/2026 Description: Saisie d'une nouvelle configuration d'heure de
                        pointe --%>

                        <% try{ UserEJB u=(user.UserEJB) session.getValue("u"); String
                            mapping="categorieheure.HeureDePointe" , nomtable="HEUREDEPOINTE" ,
                            apres="categorieheure/heuredepointe-fiche.jsp" ,
                            titre="Nouvelle configuration d'heure de pointe" ; HeureDePointe hdp=new HeureDePointe();
                            String lien=(String) session.getValue("lien"); // Récupérer les supports pour le select
                            Support[] supports=(Support[]) CGenUtil.rechercher(new Support(), null, null, null, "" ); %>
                            <div class="content-wrapper">
                                <section class="content-header">
                                    <h1><i class="fa fa-clock-o"></i>
                                        <%=titre%>
                                    </h1>
                                </section>

                                <section class="content">
                                    <div class="row">
                                        <div class="col-md-8 col-md-offset-2">
                                            <div class="box box-primary">
                                                <div class="box-header with-border">
                                                    <h3 class="box-title">Informations de l'heure de pointe</h3>
                                                </div>

                                                <form action="<%=lien%>?but=apresTarif.jsp" method="post"
                                                    name="<%=nomtable%>" id="<%=nomtable%>">
                                                    <div class="box-body">
                                                        <div class="row">
                                                            <div class="col-md-6">
                                                                <div class="form-group">
                                                                    <label>Jour de la semaine <span
                                                                            class="text-danger">*</span></label>
                                                                    <select name="jourSemaine" class="form-control"
                                                                        required>
                                                                        <option value="">-- S&eacute;lectionnez un jour
                                                                            --</option>
                                                                        <option value="LUNDI">Lundi</option>
                                                                        <option value="MARDI">Mardi</option>
                                                                        <option value="MERCREDI">Mercredi</option>
                                                                        <option value="JEUDI">Jeudi</option>
                                                                        <option value="VENDREDI">Vendredi</option>
                                                                        <option value="SAMEDI">Samedi</option>
                                                                        <option value="DIMANCHE">Dimanche</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <div class="form-group">
                                                                    <label>Support (optionnel)</label>
                                                                    <select name="idSupport" class="form-control">
                                                                        <option value="">Tous les supports</option>
                                                                        <% for (Support s : supports) { %>
                                                                            <option value="<%=s.getId()%>">
                                                                                <%=s.getVal()%>
                                                                            </option>
                                                                            <% } %>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-md-4">
                                                                <div class="form-group">
                                                                    <label>Heure de d&eacute;but <span
                                                                            class="text-danger">*</span></label>
                                                                    <input type="time" name="heureDebut"
                                                                        class="form-control" required>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <div class="form-group">
                                                                    <label>Heure de fin <span
                                                                            class="text-danger">*</span></label>
                                                                    <input type="time" name="heureFin"
                                                                        class="form-control" required>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <div class="form-group">
                                                                    <label>Pourcentage de majoration (%) <span
                                                                            class="text-danger">*</span></label>
                                                                    <input type="number" name="pourcentageMajoration"
                                                                        class="form-control" step="0.01" min="0"
                                                                        max="100" placeholder="Ex: 10" required>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-md-6">
                                                                <div class="form-group">
                                                                    <label>&Eacute;tat</label>
                                                                    <select name="etat" class="form-control">
                                                                        <option value="1" selected>Actif</option>
                                                                        <option value="0">Inactif</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="callout callout-warning">
                                                            <h4><i class="fa fa-warning"></i> Note</h4>
                                                            <p>La majoration sera appliqu&eacute;e automatiquement aux
                                                                r&eacute;servations qui tombent
                                                                dans cette plage horaire pour le jour
                                                                s&eacute;lectionn&eacute;.</p>
                                                        </div>
                                                    </div>

                                                    <div class="box-footer">
                                                        <a href="<%=lien%>?but=categorieheure/heuredepointe-liste.jsp"
                                                            class="btn btn-default">
                                                            <i class="fa fa-arrow-left"></i> Retour
                                                        </a>
                                                        <button type="submit" class="btn btn-success pull-right">
                                                            <i class="fa fa-save"></i> Enregistrer
                                                        </button>

                                                        <input name="acte" type="hidden" value="insert">
                                                        <input name="bute" type="hidden" value="<%=apres%>">
                                                        <input name="classe" type="hidden" value="<%=mapping%>">
                                                        <input name="nomtable" type="hidden" value="<%=nomtable%>">
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </section>
                            </div>

                            <% } catch (Exception e) { e.printStackTrace(); %>
                                <script language="JavaScript">
                                    alert('<%=e.getMessage()%>');
                                    history.back();
                                </script>
                                <% }%>