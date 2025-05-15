###########
# Exemple 1 : Problème simple de ratissage à une dimension dans lequel les valeurs des 
#             `autos` et des `camions` doivent être égales à la valeur du `total`.

# Métadonnées du problème
mes_meta1 <- data.frame(series = c("autos", "camions"),
                        total1 = c("total", "total"))
mes_meta1

# Données du problème
mes_series1 <- data.frame(autos = 25, camions = 5, total = 40)

# Réconcilier les données
res_ratis1 <- tsraking(mes_series1, mes_meta1)

# Données initiales
mes_series1

# Données réconciliées
res_ratis1

# Vérifier les contraintes transversales en sortie
all.equal(rowSums(res_ratis1[c("autos", "camions")]), res_ratis1$total)

# Vérifier le total de contrôle (fixe)
all.equal(mes_series1$total, res_ratis1$total)


###########
# Exemple 2 : problème de ratissage à 2 dimensions similaire au 1er exemple mais 
#             en ajoutant les ventes régionales pour les 3 provinces des prairies 
#             (Alb., Sask. et Man.) et où les ventes de camions en Sask. ne sont 
#             pas modifiables (coefficient d'altérabilité = 0), avec `quiet = TRUE` 
#             pour éviter l'affichage de l'en-tête de la fonction.

# Métadonnées du problème
mes_meta2 <- data.frame(series = c("autos_alb", "autos_sask", "autos_man",
                                   "camions_alb", "camions_sask", "camions_man"),
                        total1 = c(rep("total_autos", 3),
                                   rep("total_camions", 3)),
                        total2 = rep(c("total_alb", "total_sask", "total_man"), 2))

# Données du problème
mes_series2 <- data.frame(autos_alb = 12, autos_sask = 14, autos_man = 13,
                          camions_alb = 20, camions_sask = 20, camions_man = 24,
                          total_alb = 30, total_sask = 31, total_man = 32,
                          total_autos = 40, total_camions = 53)

# Réconcilier les données
res_ratis2 <- tsraking(mes_series2, mes_meta2,
                       alterability_df = data.frame(camions_sask = 0),
                       quiet = TRUE)

# Données initiales
mes_series2

# Données réconciliées
res_ratis2

# Vérifier les contraintes transversales en sortie
all.equal(rowSums(res_ratis2[c("autos_alb", "autos_sask", "autos_man")]), res_ratis2$total_autos)
all.equal(rowSums(res_ratis2[c("camions_alb", "camions_sask", "camions_man")]), res_ratis2$total_camions)
all.equal(rowSums(res_ratis2[c("autos_alb", "camions_alb")]), res_ratis2$total_alb)
all.equal(rowSums(res_ratis2[c("autos_sask", "camions_sask")]), res_ratis2$total_sask)
all.equal(rowSums(res_ratis2[c("autos_man", "camions_man")]), res_ratis2$total_man)

# Vérifier le total de contrôle (fixe)
cols_tot <- union(unique(mes_meta2$total1), unique(mes_meta2$total2))
all.equal(mes_series2[cols_tot], res_ratis2[cols_tot])

# Vérifier la valeur des camions en Saskatchewan (fixée à 20)
all.equal(mes_series2$camions_sask, res_ratis2$camions_sask)
