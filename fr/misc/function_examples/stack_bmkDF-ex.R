# Créer un « data frame » d'étalons annuels pour 2 séries indicatrices trimestrielles 
# (avec des valeurs manquantes pour les étalons des 2 dernières années)
mes_etalons <- ts_to_bmkDF(ts(data.frame(ser1 = c(1:3 *  10, NA, NA), 
                                         ser2 = c(1:3 * 100, NA, NA)),
                              start = c(2019, 1), frequency = 1),
                           ind_frequency = 4)
mes_etalons


# Empiler les étalons ...

# en rejetant les `NA` dans les données empilées (comportement par défaut)
stack_bmkDF(mes_etalons)

# en conservant les `NA` dans les données empilées
stack_bmkDF(mes_etalons, keep_NA = TRUE)

# en utilisant des noms de variables (colonnes) personnalisés
stack_bmkDF(mes_etalons, ser_cName = "nom_eta", val_cName = "val_eta")
