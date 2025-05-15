# Problème de ratissage à 1 dimension où les ventes trimestrielles de voitures 
# dans les 3 provinces des Prairies (Alb., Sask. et Man.) pour 8 trimestres, 
# de 2019 T2 à 2021 T1, doivent être égales au total (`cars_tot`).

# Métadonnées du problème
mes_meta <- data.frame(series = c("autos_alb", "autos_sask", "autos_man"),
                       total1 = rep("autos_tot", 3))
mes_meta

# Données du problème
mes_series <- ts(matrix(c(14, 18, 14, 58,
                          17, 14, 16, 44,
                          14, 19, 18, 58,
                          20, 18, 12, 53,
                          16, 16, 19, 44,
                          14, 15, 16, 50,
                          19, 20, 14, 52,
                          16, 15, 19, 51),
                        ncol = 4,
                        byrow = TRUE,
                        dimnames = list(NULL, c("autos_alb", "autos_sask",
                                                "autos_man", "autos_tot"))),
                 start = c(2019, 2),
                 frequency = 4)


###########
# Exemple 1 : Traitement période-par-période sans préservation des totaux annuels.

# Réconcilier les données
res_ratis1 <- tsraking_driver(mes_series, mes_meta)

# Données initiales
mes_series

# Données réconciliées
res_ratis1

# Vérifier les contraintes transversales en sortie
all.equal(rowSums(res_ratis1[, mes_meta$series]), as.vector(res_ratis1[, "autos_tot"]))

# Vérifier le total de contrôle (fixe)
all.equal(mes_series[, "autos_tot"], res_ratis1[, "autos_tot"])


###########
# Exemple 2 : Préservation des totaux annuels de 2020 (traitement période-par-période 
#             pour les années incomplètes 2019 et 2021), avec `quiet = TRUE` pour 
#             éviter d'afficher l'en-tête de la fonction pour chaque groupe de traitement.

# Vérifions tout d'abord que le total annuel de 2020 de la série totale (`autos_tot`) 
# et de la somme des séries composantes (`autos_alb`, `autos_sask` et `autos_man`) 
# concordent. Dans le cas contraire, il faudrait d'abord résoudre cet écart avant 
# d'exécuter `tsraking_driver()`.
tot2020 <- aggregate.ts(window(mes_series, start = c(2020, 1), end = c(2020, 4)))
all.equal(as.numeric(tot2020[, "autos_tot"]), sum(tot2020[, mes_meta$series]))

# Réconcilier les données
res_ratis2 <- tsraking_driver(in_ts = mes_series,
                              metadata_df = mes_meta,
                              quiet = TRUE,
                              temporal_grp_periodicity = frequency(mes_series))

# Données initiales
mes_series

# Données réconciliées
res_ratis2

# Vérifier les contraintes transversales en sortie
all.equal(rowSums(res_ratis2[, mes_meta$series]), as.vector(res_ratis2[, "autos_tot"]))

# Vérifier les contraintes temporelles en sortie (total annuel de 2020 pour chaque série)
all.equal(tot2020,
          aggregate.ts(window(res_ratis2, start = c(2020, 1), end = c(2020, 4))))

# Vérifier le total de contrôle (fixe)
all.equal(mes_series[, "autos_tot"], res_ratis2[, "autos_tot"])


###########
# Exemple 3 : Préservation des totaux annuels pour les années financières allant  
#             d'avril à mars (2019T2-2020T1 et 2020T2-2021T1).

# Calculer les deux totaux d'années financières (objet « ts » annuel)
tot_annFisc <- ts(rbind(aggregate.ts(window(mes_series,
                                            start = c(2019, 2),
                                            end = c(2020, 1))),
                        aggregate.ts(window(mes_series,
                                            start = c(2020, 2),
                                            end = c(2021, 1)))),
                  start = 2019,
                  frequency = 1)

# Écarts dans les totaux d'années financières (série totale contre la somme des 
# séries composantes)
as.numeric(tot_annFisc[, "autos_tot"]) - rowSums(tot_annFisc[, mes_meta$series])


# 3a) Réconcilier les totaux d'années financières (ratisser les totaux d'années 
#     financières des séries composantes à ceux de la série totale).
tot_annFisc_ratis <- tsraking_driver(in_ts = tot_annFisc,
                                     metadata_df = mes_meta,
                                     quiet = TRUE)

# Confirmer que les écarts précédents ont disparu (ils sont tous les deux nuls).
as.numeric(tot_annFisc_ratis[, "autos_tot"]) - rowSums(tot_annFisc_ratis[, mes_meta$series])

# 3b) Étalonner les séries composantes trimestrielles à ces nouveaux totaux (cohérents) 
#     d'années financières.
res_eta <- benchmarking(series_df = ts_to_tsDF(mes_series[, mes_meta$series]),
                        benchmarks_df = ts_to_bmkDF(
                          tot_annFisc_ratis[, mes_meta$series],
                          ind_frequency = frequency(mes_series),
                          
                          # Années financières d'avril à mars (T2 à T1)
                          bmk_interval_start = 2),
                        
                        rho = 0.729,
                        lambda = 1,
                        biasOption = 2,
                        allCols = TRUE,
                        quiet = TRUE)
mes_series_eta <- tsDF_to_ts(cbind(res_eta$series, autos_tot = mes_series[, "autos_tot"]),
                             frequency = frequency(mes_series))

# 3c) Réconcilier les données trimestrielles en préservant les totaux d'années finiacières.
res_ratis3 <- tsraking_driver(in_ts = mes_series_eta,
                              metadata_df = mes_meta,
                              temporal_grp_periodicity = frequency(mes_series),
                              
                              # Années financières d'avril à mars (T2 à T1)
                              temporal_grp_start = 2,
                              
                              quiet = TRUE)

# Données initiales
mes_series

# Avec totaux d'années finiacières cohérents
mes_series_eta

# Données réconciliées
res_ratis3

# Vérifier les contraintes transversales en sortie
all.equal(rowSums(res_ratis3[, mes_meta$series]), as.vector(res_ratis3[, "autos_tot"]))

# Vérifier les contraintes temporelles en sortie (totaux des deux années financières pour 
# chaque série)
all.equal(rbind(aggregate.ts(window(mes_series_eta, start = c(2019, 2), end = c(2020, 1))),
                aggregate.ts(window(mes_series_eta, start = c(2020, 2), end = c(2021, 1)))),
          rbind(aggregate.ts(window(res_ratis3, start = c(2019, 2), end = c(2020, 1))),
                aggregate.ts(window(res_ratis3, start = c(2020, 2), end = c(2021, 1)))))

# Vérifier le total de contrôle (fixe)
all.equal(mes_series[, "autos_tot"], res_ratis3[, "autos_tot"])
