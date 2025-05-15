# Créer un « data frame » de 2 séries indicatrices trimestrielles
# (avec des valeurs manquantes pour les 2 dernières trimestres)
mes_indicateurs <- ts_to_tsDF(ts(data.frame(ser1 = c(1:5 *  10, NA, NA),
                                            ser2 = c(1:5 * 100, NA, NA)), 
                                 start = c(2019, 1), frequency = 4))
mes_indicateurs


# Empiler les séries indicatrices ...

# en rejetant les `NA` dans les données empilées (comportement par défaut)
stack_tsDF(mes_indicateurs)

# en conserver les `NA` dans les données empilées
stack_tsDF(mes_indicateurs, keep_NA = TRUE)

# en utilisant des noms de variables (colonnes) personnalisés
stack_tsDF(mes_indicateurs, ser_cName = "nom_ind", val_cName = "val_ind")
