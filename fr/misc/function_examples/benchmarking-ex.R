# Définir le répertoire de travail (pour les fichiers graphiques PDF)
rep_ini <- getwd() 
setwd(tempdir())


###########
# Exemple 1 : Cas simple d'étalonnage d'une série trimestrielle à des valeurs annuelles

# Série indicatrice trimestrielle
mes_ind1 <- ts_to_tsDF(ts(c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
                          start = c(2015, 1),
                          frequency = 4))
mes_ind1

# Étalons annuels pour données trimestrielles
mes_eta1 <- ts_to_bmkDF(ts(c(10.3, 10.2),
                           start = 2015,
                           frequency = 1),
                        ind_frequency = 4)
mes_eta1

# Étalonnage avec...
#   - valeur de `rho` recommandée pour des séries trimestrielles (`rho = 0.729`)
#   - modèle proportionnel (`lambda = 1`)
#   - correction de la série indicatrice pour le biais avec estimation du biais 
#     (`biasOption = 3`)
res_eta1 <- benchmarking(mes_ind1,
                         mes_eta1,
                         rho = 0.729,
                         lambda = 1,
                         biasOption = 3)

# Générerer les graphiques d'étalonnage
plot_graphTable(res_eta1$graphTable, "Graphs_ex1.pdf")


###########
# Exemple 2 : Étalonnage de deux séries trimestrielles à des valeurs annuelles,
#             avec groupes-BY et coef. d'altérabilité définis par l'utilisateur.

# Données sur les ventes (mêmes ventes pour les groupes A et B; seuls les coef. 
# d'alté. pour les ventes de camionnettes diffèrent)
ventes_tri <- ts(matrix(c(# Voitures
                          1851, 2436, 3115, 2205, 1987, 2635, 3435, 2361, 2183, 2822,
                          3664, 2550, 2342, 3001, 3779, 2538, 2363, 3090, 3807, 2631,
                          2601, 3063, 3961, 2774, 2476, 3083, 3864, 2773, 2489, 3082,
                          # Camionnettes
                          1900, 2200, 3000, 2000, 1900, 2500, 3800, 2500, 2100, 3100,
                          3650, 2950, 3300, 4000, 3290, 2600, 2010, 3600, 3500, 2100,
                          2050, 3500, 4290, 2800, 2770, 3080, 3100, 2800, 3100, 2860),
                        ncol = 2),
                 start = c(2011, 1),
                 frequency = 4,
                 names = c("voitures", "camionnettes"))

ventes_ann <- ts(matrix(c(# Voitures
                          10324, 10200, 10582, 11097, 11582, 11092,
                          # Camionnettes
                          12000, 10400, 11550, 11400, 14500, 16000),
                        ncol = 2),
                 start = 2011,
                 frequency = 1,
                 names = c("voitures", "camionnettes"))

# Séries indicatrices trimestrielles (avec les coef. d'alté. par défaut pour l'instant)
mes_ind2 <- rbind(cbind(data.frame(groupe = rep("A", nrow(ventes_tri)),
                                   alt_cam = rep(1, nrow(ventes_tri))),
                        ts_to_tsDF(ventes_tri)),
                  cbind(data.frame(groupe = rep("B", nrow(ventes_tri)),
                                   alt_cam = rep(1, nrow(ventes_tri))),
                        ts_to_tsDF(ventes_tri)))

# Ventes contraignantes de camionnettes (coef. d'alté. = 0) pour 2012 T1 et T2 
# dans le groupe A (lignes 5 et 6)
mes_ind2$alt_cam[c(5,6)] <- 0
head(mes_ind2, n = 10)
tail(mes_ind2)

# Étalons annuels pour données trimestrielles (sans coef. d'alté.)
mes_eta2 <- rbind(cbind(data.frame(groupe = rep("A", nrow(ventes_ann))),
                        ts_to_bmkDF(ventes_ann, ind_frequency = 4)),
                  cbind(data.frame(groupe = rep("B", nrow(ventes_ann))),
                        ts_to_bmkDF(ventes_ann, ind_frequency = 4)))
mes_eta2

# Étalonnage avec...
#   - valeur de `rho` recommandée pour des séries trimestrielles (`rho = 0.729`)
#   - modèle proportionnel (`lambda = 1`)
#   - sans correction du biais (`biasOption = 1` et `bias` non spécifié)
#   - `quiet = TRUE` afin d'éviter l'affichage de l'en-tête de la fonction
res_eta2 <- benchmarking(mes_ind2,
                         mes_eta2,
                         rho = 0.729,
                         lambda = 1,
                         biasOption = 1,
                         var = c("voitures", "camionnettes / alt_cam"),
                         with = c("voitures", "camionnettes"),
                         by = "groupe",
                         quiet = TRUE)

# Générerer les graphiques d'étalonnage
plot_graphTable(res_eta2$graphTable, "Graphs_ex2.pdf")

# Vérifier la valeur des ventes de camionnettes pour 2012 T1 et T2 
# dans le groupe A (valeurs fixes)
all.equal(mes_ind2$camionnettes[c(5,6)], res_eta2$series$camionnettes[c(5,6)])


###########
# Exemple 3 : identique à l'exemple 2, mais en étalonnant les 4 séries 
#             en tant que groupes-BY (4 groupes-BY au lieu de 2)

ventes_tri2 <- ts.union(A = ventes_tri, B = ventes_tri)
mes_ind3 <- stack_tsDF(ts_to_tsDF(ventes_tri2))
mes_ind3$alter <- 1
mes_ind3$alter[mes_ind3$series == "A.camionnettes"
                & mes_ind3$year == 2012 & mes_ind3$period <= 2] <- 0
head(mes_ind3)
tail(mes_ind3)

ventes_ann2 <- ts.union(A = ventes_ann, B = ventes_ann)
mes_eta3 <- stack_bmkDF(ts_to_bmkDF(ventes_ann2, ind_frequency = 4))
head(mes_eta3)
tail(mes_eta3)

res_eta3 <- benchmarking(mes_ind3,
                         mes_eta3,
                         rho = 0.729,
                         lambda = 1,
                         biasOption = 1,
                         var = "value / alter",
                         with = "value",
                         by = "series",
                         quiet = TRUE)

# Générerer les graphiques d'étalonnage
plot_graphTable(res_eta3$graphTable, "Graphs_ex3.pdf")

# Convertir le « data frame » `res_eta3$series` en un objet « mts »
ventes_tri2_eta <- tsDF_to_ts(unstack_tsDF(res_eta3$series), frequency = 4)

# Afficher les 10 premières observations
ts(ventes_tri2_eta[1:10, ], start = start(ventes_tri2), deltat = deltat(ventes_tri2))

# Vérifier la valeur des ventes de camionnettes pour 2012 T1 et T2 
# dans le groupe A (valeurs fixes)
all.equal(window(ventes_tri2[, "A.camionnettes"], start = c(2012, 1), end = c(2012, 2)),
          window(ventes_tri2_eta[, "A.camionnettes"], start = c(2012, 1), end = c(2012, 2)))


# Réinitialiser le répertoire de travail à son emplacement initial
setwd(rep_ini)
