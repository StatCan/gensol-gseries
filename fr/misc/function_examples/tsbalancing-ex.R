###########
# Exemple 1 : Dans ce premier exemple, l'objectif est d'équilibrer un tableau comptable simple 
#             (`Profits = Revenus - Depenses`), pour 5 trimestres, sans modifier les `Profits` 
#             et où `Revenus >= 0` et `Depenses >= 0`.

# Spécifications du problème
mes_specs1 <- data.frame(type = c("EQ", rep(NA, 3), 
                                  "alter", NA, 
                                  "lowerBd", NA, NA),
                         col = c(NA, "Revenus", "Depenses", "Profits", 
                                 NA, "Profits", 
                                 NA, "Revenus", "Depenses"),
                         row = c(rep("Règle comptable", 4), 
                                 rep("Coefficient d'altérabilité", 2), 
                                 rep("Borne inférieure", 3)),
                         coef = c(NA, 1, -1, -1,
                                  NA, 0,
                                  NA, 0, 0))
mes_specs1

# Données du problème
mes_series1 <- ts(matrix(c( 15,  10,  10,
                             4,   8,  -1,
                           250, 250,   5,
                             8,  12,   0,
                             0,  45, -55),
                         ncol = 3,
                         byrow = TRUE,
                         dimnames = list(NULL, c("Revenus", "Depenses", "Profits"))),
                  start = c(2022, 1),
                  frequency = 4)

# Réconcilier les données
res_equi1 <- tsbalancing(in_ts = mes_series1,
                         problem_specs_df = mes_specs1,
                         display_level = 3)

# Données initiales
mes_series1

# Données réconciliées
res_equi1$out_ts

# Vérifier la présence de solutions invalides
any(res_equi1$proc_grp_df$sol_status_val < 0)

# Afficher les écarts maximaux des contraintes en sortie
res_equi1$proc_grp_df[, c("proc_grp_label", "max_discr")]


# La solution renvoyée par `tsbalancing()` correspond à des changements proportionnels 
# égaux (au prorata) et est associée aux coefficients d'altérabilité par défaut de 1. 
# Des changements absolus égaux peuvent être obtenus en spécifiant des coefficients 
# d'altérabilité égaux à l'inverse des valeurs initiales. 
# 
# Faisons cela pour le groupe de traitement 2022T2 (`timeVal = 2022.25`), avec le niveau 
# d'information affiché par défaut (`display_level = 1`).

mes_specs1b <- rbind(cbind(mes_specs1, 
                          data.frame(timeVal = rep(NA_real_, nrow(mes_specs1)))),
                    data.frame(type = rep(NA, 2),
                               col = c("Revenus", "Depenses"),
                               row = rep("Coefficient d'altérabilité", 2),
                               coef = c(0.25, 0.125),
                               timeVal = rep(2022.25, 2)))
mes_specs1b

res_equi1b <- tsbalancing(in_ts = mes_series1,
                          problem_specs_df = mes_specs1b)

# Afficher les valeurs initiales de 2022T2 et les deux solutions
cbind(data.frame(Statut = c("initial", "prorata", "changement égal")),
      rbind(as.data.frame(mes_series1[2, , drop = FALSE]), 
            as.data.frame(res_equi1$out_ts[2, , drop = FALSE]),
            as.data.frame(res_equi1b$out_ts[2, , drop = FALSE])),
      data.frame(Ecart_comptable = c(mes_series1[2, 1] - mes_series1[2, 2] - 
                                       mes_series1[2, 3],
                                     res_equi1$out_ts[2, 1] - 
                                       res_equi1$out_ts[2, 2] - 
                                       res_equi1$out_ts[2, 3],
                                     res_equi1b$out_ts[2, 1] - 
                                       res_equi1b$out_ts[2, 2] - 
                                       res_equi1b$out_ts[2, 3]),
                 ChgRel_Rev = c(NA, 
                                res_equi1$out_ts[2, 1] / mes_series1[2, 1] - 1,
                                res_equi1b$out_ts[2, 1] / mes_series1[2, 1] - 1),
                 ChgRel_Dep = c(NA, 
                                res_equi1$out_ts[2, 2] / mes_series1[2, 2] - 1,
                                res_equi1b$out_ts[2, 2] / mes_series1[2, 2] - 1),
                 ChgAbs_Rev = c(NA, 
                                res_equi1$out_ts[2, 1] - mes_series1[2, 1],
                                res_equi1b$out_ts[2, 1] - mes_series1[2, 1]),
                 ChgAbs_Dep = c(NA, 
                                res_equi1$out_ts[2, 2] - mes_series1[2, 2],
                                res_equi1b$out_ts[2, 2] - mes_series1[2, 2])))


###########
# Exemple 2 : Dans ce deuxième exemple, nous considérons les données simulées des  
#             ventes trimestrielles de véhicules par région (Ouest, Centre et Est), 
#             ainsi qu'un total national pour les trois régions, et par type de véhicules 
#             (voitures, camions et un total qui peut inclure d'autres types de véhicules). 
#             Les données correspondent à des données directement désaisonnalisées qui 
#             ont été étalonnées aux totaux annuels des séries originales (non 
#             désaisonnalisées) correspondantes dans le cadre du processus de 
#             désaisonnalisation (par exemple, avec le « spec » FORCE du logiciel 
#             X-13ARIMA-SEATS). 
#
#             L'objectif est de réconcilier les ventes régionales avec les ventes 
#             nationales sans modifier ces dernières, tout en veillant à ce que la somme 
#             des ventes de voitures et de camions ne dépasse pas 95% des ventes de tous 
#             les types de véhicules au cours d'un trimestre donné. À titre d'exemple, 
#             nous supposons que les ventes de camions dans la région Centre pour le 2e 
#             trimestre 2022 ne peuvent pas être modifiées.

# Spécifications du problème
mes_specs2 <- data.frame(
  
  type = c("EQ", rep(NA, 4),
           "EQ", rep(NA, 4),
           "EQ", rep(NA, 4),
           "LE", rep(NA, 3),
           "LE", rep(NA, 3),
           "LE", rep(NA, 3),
           "alter", rep(NA, 4)),
  
  col = c(NA, "Ouest_Tous", "Centre_Tous", "Est_Tous", "National_Tous", 
          NA, "Ouest_Autos", "Centre_Autos", "Est_Autos", "National_Autos", 
          NA, "Ouest_Camions", "Centre_Camions", "Est_Camions", "National_Camions", 
          NA, "Ouest_Autos", "Ouest_Camions", "Ouest_Tous", 
          NA, "Centre_Autos", "Centre_Camions", "Centre_Tous", 
          NA, "Est_Autos", "Est_Camions", "Est_Tous",
          NA, "National_Tous", "National_Autos", "National_Camions", "Centre_Camions"),
  
  row = c(rep("Total national - Tous les véhicules", 5),
          rep("Total national - Autos", 5),
          rep("Total national - Camions", 5),
          rep("Somme région Ouest", 4),
          rep("Somme région Centre", 4),
          rep("Somme région Est", 4),
          rep("Coefficient d'altérabilité", 5)),
  
  coef = c(NA, 1, 1, 1, -1,
           NA, 1, 1, 1, -1,
           NA, 1, 1, 1, -1,
           NA, 1, 1, -.95,
           NA, 1, 1, -.95,
           NA, 1, 1, -.95,
           NA, 0, 0, 0, 0),
  
  time_val = c(rep(NA, 31), 2022.25))

# Début et fin du « data frame » des spécifications
head(mes_specs2, n = 10)
tail(mes_specs2)

# Données du problème
mes_series2 <- ts(
  matrix(c(43, 49, 47, 136, 20, 18, 12, 53, 20, 22, 26, 61,
           40, 45, 42, 114, 16, 16, 19, 44, 21, 26, 21, 59,
           35, 47, 40, 133, 14, 15, 16, 50, 19, 25, 19, 71,
           44, 44, 45, 138, 19, 20, 14, 52, 21, 18, 27, 74,
           46, 48, 55, 135, 16, 15, 19, 51, 27, 25, 28, 54),
         ncol = 12,
         byrow = TRUE,
         dimnames = list(NULL, 
                         c("Ouest_Tous", "Centre_Tous", "Est_Tous", 
                           "National_Tous", "Ouest_Autos", "Centre_Autos", 
                           "Est_Autos", "National_Autos", "Ouest_Camions", 
                           "Centre_Camions", "Est_Camions", "National_Camions"))),
  start = c(2022, 1),
  frequency = 4)

# Réconcilier sans afficher l'en-tête de la fonction et imposer des données non négatives
res_equi2 <- tsbalancing(
  in_ts                    = mes_series2,
  problem_specs_df         = mes_specs2,
  temporal_grp_periodicity = frequency(mes_series2),
  lower_bound              = 0,
  quiet                    = TRUE)

# Données initiales
mes_series2

# Données réconciliées
res_equi2$out_ts

# Vérifier la présence de solutions invalides
any(res_equi2$proc_grp_df$sol_status_val < 0)

# Afficher les écarts maximaux des contraintes en sortie
res_equi2$proc_grp_df[, c("proc_grp_label", "max_discr")]


###########
# Exemple 3 : Reproduire le 2ème exemple de `tsraking_driver()` avec `tsbalancing()` 
#             (ratissage à 1 dimension avec préservation des totaux annuels).

# Métadonnées de `tsraking()`
mes_meta3 <- data.frame(series = c("autos_alb", "autos_sask", "autos_man"),
                        total1 = rep("autos_tot", 3))
mes_meta3

# Spécifications du problème de `tsbalancing()`
mes_specs3 <- rkMeta_to_blSpecs(mes_meta3)
mes_specs3

# Données du problème
mes_series3 <- ts(matrix(c(14, 18, 14, 58,
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

# Réconcilier les données avec `tsraking()` (via `tsraking_driver()`)
res_ratis3 <- tsraking_driver(in_ts = mes_series3,
                              metadata_df = mes_meta3,
                              temporal_grp_periodicity = frequency(mes_series3),
                              quiet = TRUE)

# Réconcilier les données avec `tsbalancing()`
res_equi3 <- tsbalancing(in_ts = mes_series3,
                         problem_specs_df = mes_specs3,
                         temporal_grp_periodicity = frequency(mes_series3),
                         quiet = TRUE)

# Données initiales
mes_series3

# Les deux ensembles de données réconciliées
res_ratis3
res_equi3$out_ts

# Vérifier la présence de solutions de `tsbalancing()` invalides
any(res_equi3$proc_grp_df$sol_status_val < 0)

# Afficher les écarts maximaux des contraintes en sortie dans les solutions de `tsbalancing()`
res_equi3$proc_grp_df[, c("proc_grp_label", "max_discr")]

# Confirmer que les deux solutions (`tsraking() et `tsbalancing()`) sont les mêmes
all.equal(res_ratis3, res_equi3$out_ts)
