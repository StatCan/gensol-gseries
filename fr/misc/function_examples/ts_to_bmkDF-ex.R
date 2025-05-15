# Séries chronologiques annuelle et trimestrielle
ma_sc_ann <- ts(1:5 * 100, start = 2019, frequency = 1)
ma_sc_ann
ma_sc_tri <- ts(1:5 * 10, start = c(2019, 1), frequency = 4)
ma_sc_tri


# Étalons annuels pour des séries indicatrices mensuelles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 12)

# Étalons annuels pour des série indicatrices trimestrielles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 4)

# Étalons trimestriels pour des séries indicatrices mensuelles
ts_to_bmkDF(ma_sc_tri, ind_frequency = 12)

# Stocks de début d'année pour des séries indicatrices trimestrielles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 4,
            discrete_flag = TRUE)

# Stocks de fin de trimestre pour des séries indicatrices mensuelles
ts_to_bmkDF(ma_sc_tri, ind_frequency = 12,
            discrete_flag = TRUE, alignment = "e")

# Étalons annuels (avril à mars) pour des séries indicatrices ...
# ... mensuelles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 12,
            bmk_interval_start = 4)
# ... trimestrielles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 4,
            bmk_interval_start = 2)

# Stocks de fin d'année (avril à mars) pour des séries indicatrices ...
# ... mensuelles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 12,
            discrete_flag = TRUE, alignment = "e", bmk_interval_start = 4)
# ... trimestrielles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 4,
            discrete_flag = TRUE, alignment = "e", bmk_interval_start = 2)

# Nom personnalisé pour la variable (colonne) des étalons
ts_to_bmkDF(ma_sc_ann, ind_frequency = 12,
            val_cName = "eta_val")

# Séries chronologiques multiples: argument `val_cName` ignoré
# (les noms des colonnes de l'object « mts » sont toujours utilisés)
ts_to_bmkDF(ts.union(ser1 = ma_sc_ann, ser2 = ma_sc_ann / 10), ind_frequency = 12,
            val_cName = "nom_de_colonne_inutile")
