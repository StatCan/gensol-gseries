# Série chronologique Quarterly time series
ma_sc <- ts(1:10 * 100, start = 2019, frequency = 4)
ma_sc


# Noms de variables (colonnes) par défaut
ts_to_tsDF(ma_sc)

# Nom personnalisé pour la variable (colonne) des étalons
ts_to_tsDF(ma_sc, val_cName = "ser_val")


# Séries chronologiques multiples: argument `val_cName` ignoré
# (les noms de colonnes de l'object « mts » sont toujours utilisés)
ts_to_tsDF(ts.union(ser1 = ma_sc,
                    ser2 = ma_sc / 10),
            val_cName = "nom_de_colonne_inutile")
