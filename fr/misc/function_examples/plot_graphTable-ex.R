# Définir le répertoire de travail (pour les fichiers graphiques PDF)
rep_ini <- getwd() 
setwd(tempdir())


# Ventes trimestrielles de voitures et camionnettes (séries indicatrices)
ind_tri <- ts_to_tsDF(
  ts(matrix(c(# Voitures
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
     names = c("voitures", "camionnettes")))

# Ventes annuelles de voitures et camionnettes (étalons)
eta_tri <- ts_to_bmkDF(
  ts(matrix(c(# Voitures
              10324, 10200, 10582, 11097, 11582, 11092,
              # Camionnettes
              12000, 10400, 11550, 11400, 14500, 16000),
            ncol = 2),
     start = 2011,
     frequency = 1,
     names = c("voitures", "camionnettes")), 
  ind_frequency = 4)
  

# Étalonnage proportionnel sans correction pour le biais
res_eta <- benchmarking(ind_tri, eta_tri,
                        rho = 0.729, lambda = 1, biasOption = 1,
                        allCols = TRUE,
                        quiet = TRUE)


# Ensemble de graphiques par défaut (les 3 premiers types de graphiques)
plot_graphTable(res_eta$graphTable, "graphes_etalonnage.pdf")

# Utiliser temporairement `theme_bw()` de ggplot2 pour les graphiques
library(ggplot2)
theme_ini <- theme_get()
theme_set(theme_bw())
plot_graphTable(res_eta$graphTable, "graphes_etalonnage_bw.pdf")
theme_set(theme_ini)

# Generer les 4 types de graphiques (incluant le tableau des taux de croissance)
plot_graphTable(res_eta$graphTable, "graphes_etalonnage_avec_tableauTC.pdf",
                GR_table_flag = TRUE)

# Réduire le temps d'exécution en désactivant les deux types de graphiques 
# des taux de croissance
plot_graphTable(res_eta$graphTable, "graphes_etalonnage_sans_TC.pdf",
                GR_plot_flag = FALSE)


# Réinitialiser le répertoire de travail à son emplacement initial
setwd(rep_ini)
