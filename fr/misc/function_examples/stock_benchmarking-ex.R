# Série de stocks trimestriels (même patron répété chaque année)
mes_ind <- ts_to_tsDF(ts(rep(c(85, 95, 125, 95), 7),
                         start = c(2013, 1),
                         frequency = 4))
head(mes_ind)

# Étalons annuels (stocks de fin d'année)
mes_eta <- ts_to_bmkDF(ts(c(135, 125, 155, 145, 165),
                          start = 2013,
                          frequency = 1),
                       discrete_flag = TRUE,
                       alignment = "e",
                       ind_frequency = 4)
mes_eta

# Étalonnage avec...
#   - valeur de `rho` recommandée pour des séries trimestrielles (`rho = 0.729`)
#   - modèle proportionnel (`lambda = 1`)
#   - correction de la série indicatrice pour le biais avec estimation du biais 
#     (`biasOption = 3`)

# ... avec `benchmarking()` (approche « Proc Benchmarking »)
res_PB <- benchmarking(mes_ind,
                       mes_eta,
                       rho = 0.729,
                       lambda = 1,
                       biasOption = 3)

# ... avec `stock_benchmarking()` (approche « Stock Benchmarking »)
res_SB <- stock_benchmarking(mes_ind,
                             mes_eta,
                             rho = 0.729,
                             lambda = 1,
                             biasOption = 3)

# Comparer les ajustements d'étalonnage des deux approches
plot_benchAdj(PB_graphTable = res_PB$graphTable,
              SB_graphTable = res_SB$graphTable)

# Avez-vous remarqué que les ajustements de `stock_benchmarking()` sont plus lisses 
# que ceux de `benchmarking()` ?

# L'amélioration de la qualité des données étalonnées qui en résulte n'est pas 
# nécessairement évidente dans cet exemple.
plot(res_SB$graphTable$t, res_SB$graphTable$benchmarked,
     type = "b", col = "red", xlab = "t", ylab = "Stocks étalonnés")
lines(res_PB$graphTable$t, res_PB$graphTable$benchmarked,
      type = "b", col = "blue")
legend(x = "topleft", bty = "n", inset = 0.05, lty = 1, pch = 1,
       col = c("red", "blue"), legend = c("res_SB", "res_PB"))
title("Stocks étalonnés")

# Qu'en est-il des cas où un indicateur plat (rectiligne) est utilisé, ce qui se produit 
# souvent en pratique en l'absence d'un bon indicateur des mouvements infra-annuels ?
mes_inds2 <- mes_ind
mes_inds2$value <- 1  # indicateur plat
res_PB2 <- benchmarking(mes_inds2,
                        mes_eta,
                        rho = 0.729,
                        lambda = 1,
                        biasOption = 3,
                        quiet = TRUE)  # ne pas afficher l'en-tête

res_SB2 <- stock_benchmarking(mes_inds2,
                              mes_eta,
                              rho = 0.729,
                              lambda = 1,
                              biasOption = 3,
                              quiet = TRUE)  # ne pas afficher l'en-tête

plot(res_SB2$graphTable$t, res_SB2$graphTable$benchmarked,
     type = "b", col = "red", xlab = "t", ylab = "Stocks étalonnés")
lines(res_PB2$graphTable$t, res_PB2$graphTable$benchmarked,
      type = "b", col = "blue")
legend(x = "topleft", bty = "n", inset = 0.05, lty = 1, pch = 1,
       col = c("red", "blue"), legend = c("res_SB2", "res_PB2"))
title("Stocks étalonnés - Indicateur plat")

# L'apparence plutôt étrange des valeurs étalonnées produites par `benchmarking()` devient 
# soudainement plus évidente. En effet, la série étalonnée correspond aux ajustements 
# d'étalonnage lorsqu'on utilise un indicateur plat (par exemple, une série de 1 avec 
# un étalonnage proportionnel) :
plot_benchAdj(PB_graphTable = res_PB2$graphTable,
              SB_graphTable = res_SB2$graphTable)

# Les lacunes de l'approche « Proc Benchmarking » (fonction `benchmarking()`) avec 
# des stocks sont également très visibles lorsque l'on regarde les taux de croissance 
# trimestriels résultants, qui sont commodément produits par `plot_graphTable()`. 
# Portez une attention particulière à la transition des taux de croissance de T4 à T1 
# à chaque année dans les graphiques PDF générés.
plot_graphTable(res_PB2$graphTable, file.path(tempdir(), "Stock_ind_plat_PB.pdf"))
plot_graphTable(res_SB2$graphTable, file.path(tempdir(), "Stock_ind_plat_SB.pdf"))


# Illustrer l'approximation d'une spline cubique naturelle aux nœuds d'extrémité originaux 
# (premier et dernier étalons) en spécifiant une grande valeur pour `low_freq_periodicity`.
res_SB3 <- stock_benchmarking(mes_ind,
                              mes_eta,
                              rho = 0.729,
                              lambda = 1,
                              biasOption = 3,
                              
                              # Grande valeur pour approximer une spline cubique naturelle
                              low_freq_periodicity = 100,
                              
                              quiet = TRUE)

plot_benchAdj(SB_graphTable = res_SB3$graphTable,
              SB_splineKnots = res_SB3$splineKnots,
              legendPos = "topleft")


# Illustrer les « oscillations » pour les ajustements projetés au-delà des nœuds 
# d'extrémité originaux avec l'étalonnage de type Denton (`rho ~ 1`) causées par 
# l'utilisation de nœuds supplémentaires de basse fréquence (annuelle).
res_SB4 <- stock_benchmarking(mes_ind,
                              mes_eta,
                              rho = 0.999,
                              lambda = 1,
                              biasOption = 3,
                              
                              # Utiliser d'abord 3 noœuds supplémentaires annuels
                              n_low_freq_proj = 3,
                              proj_knots_rho_bd = 1,
                              
                              quiet = TRUE)

plot_benchAdj(SB_graphTable = res_SB4$graphTable,
              SB_splineKnots = res_SB4$splineKnots)

# Pas d'« oscillations » avec la valeur par défaut de `proj_knots_rho_bd` parce que 
# des nœuds supplémentaires de haute fréquence (trimestrielle) sont utilisés immédiatement 
# (`n_low_freq_proj` est ignoré) puisque `rho = 0.999` excède la valeur par défaut de 
# `proj_knots_rho_bd` (0.995^3 pour des données trimestrielles). Ces ajustements projetés 
# correspondent davantage à des ajustements de type Denton (en ligne droite).
res_SB4b <- stock_benchmarking(mes_ind,
                               mes_eta,
                               rho = 0.999,
                               lambda = 1,
                               biasOption = 3,
                               quiet = TRUE)

plot_benchAdj(SB_graphTable = res_SB4b$graphTable,
              SB_splineKnots = res_SB4b$splineKnots)


# Illustrer les « contorsions » de la spline cubique autour des nœuds d'extrémité originaux 
# causées par l'utilisation immédiate de nœuds supplémentaires de haute fréquence 
# (`n_low_freq_proj = 0`), c.à-d., en utilisant les mêmes ajustements projetés que ceux qui 
# seraient obtenus avec `benchmarking()`.
#
# Pour exacerber le phénomène, nous utiliserons des données mensuelles (11 périodes entre 
# chaque étalon annuel contre seulement 3 pour des données trimestrielles, c.-à-d., une 
# spline moins contrainte) et une valeur plutôt faible de `rho` (0.5 < 0.9 = valeur 
# recommandée pour des données mensuelles) pour une convergence plus rapide vers le biais 
# des ajustements projetés.
vec_ans <- unique(mes_ind$year)
mes_ind3 <- data.frame(year = rep(vec_ans, each = 12),
                       period = rep(1:12, length(vec_ans)),
                       value = rep(1, 12 * length(vec_ans)))  # indicateur plat
mes_eta2 <- mes_eta
mes_eta2[c("startPeriod", "endPeriod")] <- 12

res_SB5 <- stock_benchmarking(mes_ind3,
                              mes_eta2,
                              rho = 0.5,
                              lambda = 1,
                              biasOption = 3,
                              
                              # Utilisation immédiate de noœuds supplémentaires mensuels
                              n_low_freq_proj = 0,
                              
                              quiet = TRUE)

plot_benchAdj(SB_graphTable = res_SB5$graphTable,
              SB_splineKnots = res_SB5$splineKnots)

# Pas de « contorsions » excessives autour des nœuds d'extrémité originaux avec la valeur 
# par défaut `n_low_freq_proj = 1`, c.-à-d., utiliser d'abord 1 nœud supplémentaire de 
# basse fréquence (annuelle).
res_SB5b <- stock_benchmarking(mes_ind3,
                               mes_eta2,
                               rho = 0.5,
                               lambda = 1,
                               biasOption = 3,
                               quiet = TRUE)

plot_benchAdj(SB_graphTable = res_SB5b$graphTable,
              SB_splineKnots = res_SB5b$splineKnots)

# Afin de mettre encore mieux en évidence les « contorsions » excessives potentielles de 
# la spline cubique lorsqu'on impose les ajustements projetés de `benchmarking()` (c.-à-d., 
# des nœuds supplémentaires de basse fréquence immédiats avec `n_low_freq_proj = 0`), 
# traçons les deux précédents ensembles d'ajustements sur le même graphique (la ligne 
# bleue correspond ici au cas `n_low_freq_proj = 0`, soit les ajustements projetés de 
# `benchmarking()` alors que la ligne rouge correspond aux ajustements par défaut de 
# `stock_benchmarking()`, soit `n_low_freq_proj = 1`).
plot_benchAdj(PB_graphTable = res_SB5$graphTable,
              SB_graphTable = res_SB5b$graphTable,
              legend = NULL)
