<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@ page import="user.*" %>
        <%@ page import="affichage.*" %>
            <%@ page import="categorieheure.HeureDePointeCpl" %>
                <%@ page import="support.Support" %>
                    <%@ page import="bean.CGenUtil" %>

                        <%-- Créé par: rachriss Date: 05/02/2026 Description: Modification d'une configuration d'heure
                            de pointe --%>

                            <% try { UserEJB u=(user.UserEJB)session.getValue("u"); String lien=(String)
                                session.getValue("lien"); String id=request.getParameter("id"); String
                                mapping="categorieheure.HeureDePointe" , nomtable="HEUREDEPOINTE" ,
                                apres="categorieheure/heuredepointe-fiche.jsp" , titre="Modifier l'heure de pointe" ;
                                HeureDePointeCpl hdp=new HeureDePointeCpl(); hdp.setId(id); HeureDePointeCpl[]
                                results=(HeureDePointeCpl[]) CGenUtil.rechercher(hdp, null, null, null, "" ); if
                                (results==null || results.length==0) { throw new Exception("Heure de pointe non
                                trouvée"); } hdp=results[0]; // Récupérer les supports Support[] supports=(Support[])
                                CGenUtil.rechercher(new Support(), null, null, null, "" ); String[]
                                jours={"LUNDI", "MARDI" , "MERCREDI" , "JEUDI" , "VENDREDI" , "SAMEDI" , "DIMANCHE" };
                                String[] joursLib={"Lundi", "Mardi" , "Mercredi" , "Jeudi" , "Vendredi" , "Samedi"
                                , "Dimanche" }; %>

                                <div class="content-wrapper">
                                    <section class="content-header">
                                        <h1><i class="fa fa-edit"></i>
                                            <%=titre%>
                                        </h1>
                                    </section>

                                    <section class="content">
                                        <div class="row">
                                            <div class="col-md-8 col-md-offset-2">
                                                <div class="box box-warning">
                                                    <div class="box-header with-border">
                                                        <h3 class="box-title">Modifier les informations</h3>
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
                                                                            <option value="">-- S&eacute;lectionnez un
                                                                                jour --</option>
                                                                            <% for (int i=0; i < jours.length; i++) {
                                                                                String
                                                                                selected=jours[i].equals(hdp.getJourSemaine())
                                                                                ? "selected" : "" ; %>
                                                                                <option value="<%=jours[i]%>"
                                                                                    <%=selected%>><%=joursLib[i]%>
                                                                                </option>
                                                                                <% } %>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Support (optionnel)</label>
                                                                        <select name="idSupport" class="form-control">
                                                                            <option value="">Tous les supports</option>
                                                                            <% for (Support s : supports) { String
                                                                                selected=s.getId().equals(hdp.getIdSupport())
                                                                                ? "selected" : "" ; %>
                                                                                <option value="<%=s.getId()%>"
                                                                                    <%=selected%>><%=s.getVal()%>
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
                                                                            class="form-control"
                                                                            value="<%=hdp.getHeureDebut() != null ? hdp.getHeureDebut().substring(0, 5) : ""%>"
                                                                            required>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-4">
                                                                    <div class="form-group">
                                                                        <label>Heure de fin <span
                                                                                class="text-danger">*</span></label>
                                                                        <input type="time" name="heureFin"
                                                                            class="form-control"
                                                                            value="<%=hdp.getHeureFin() != null ? hdp.getHeureFin().substring(0, 5) : ""%>"
                                                                            required>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-4">
                                                                    <div class="form-group">
                                                                        <label>Pourcentage de majoration (%) <span
                                                                                class="text-danger">*</span></label>
                                                                        <input type="number"
                                                                            name="pourcentageMajoration"
                                                                            class="form-control" step="0.01" min="0"
                                                                            max="100"
                                                                            value="<%=hdp.getPourcentageMajoration()%>"
                                                                            required>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>&Eacute;tat</label>
                                                                        <select name="etat" class="form-control">
                                                                            <option value="1" <%=hdp.getEtat()==1
                                                                                ? "selected" : "" %>>Actif</option>
                                                                            <option value="0" <%=hdp.getEtat()==0
                                                                                ? "selected" : "" %>>Inactif</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="box-footer">
                                                            <a href="<%=lien%>?but=categorieheure/heuredepointe-fiche.jsp&id=<%=id%>"
                                                                class="btn btn-default">
                                                                <i class="fa fa-arrow-left"></i> Annuler
                                                            </a>
                                                            <button type="submit" class="btn btn-warning pull-right">
                                                                <i class="fa fa-save"></i> Enregistrer les modifications
                                                            </button>

                                                            <input name="id" type="hidden" value="<%=id%>">
                                                            <input name="acte" type="hidden" value="modif">
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
                                        alert('Erreur: <%=e.getMessage()%>');
                                        history.back();
                                    </script>
                                    <% } %>