# Désactiver la création du périphérique de graphiques pour la page de référence HTML 
# du site web (non petinent dans ce contexte)
creer_grDev <- !(identical(Sys.getenv("IN_PKGDOWN"), "true"))


# Série chronologique trimestrielle initiale (série indicatrice à étalonner)
sc_tri <- ts(c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
             start = c(2015, 1), frequency = 4)

# Série chronologique annuelle (étalons)
sc_ann <- ts(c(10.3, 10.2), start = 2015, frequency = 1)


# Étalonnage proportionnel
res_eta <- benchmarking(ts_to_tsDF(sc_tri),
                        ts_to_bmkDF(sc_ann, ind_frequency = 4),
                        rho = 0.729, lambda = 1, biasOption = 3,
                        quiet = TRUE)


# Ouvrir un nouveau périphérique de graphiques de 11po de large et 8.5po de haut
# (format de papier Lettre US en orientation paysage)
if (creer_grDev) {
  dev.new(width = 11, height = 8.5, unit = "in", noRStudioGD = TRUE)
}

# Générer les graphiques d'étalonnage
ori_plot(res_eta$graphTable)
adj_plot(res_eta$graphTable)
GR_plot(res_eta$graphTable)
GR_table(res_eta$graphTable)


# Simuler l'étalonnage de plusieurs séries (3 séries de stocks)

sc_tri2 <- ts.union(ser1 = sc_tri, ser2 = sc_tri * 100, ser3 = sc_tri * 10)
sc_ann2 <- ts.union(ser1 = sc_ann, ser2 = sc_ann * 100, ser3 = sc_ann * 10)

# Avec l'argument `allCols = TRUE` (séries identifiées avec la colonne `varSeries`)
res_eta2 <- benchmarking(ts_to_tsDF(sc_tri2),
                         ts_to_bmkDF(sc_ann2, ind_frequency = 4),
                         rho = 0.729, lambda = 1, biasOption = 3,
                         allCols = TRUE,
                         quiet = TRUE)

# Graphiques « Échelle originale » et « Échelle d'ajustement » pour la 2ième série (ser2)
res_ser2 <- res_eta2$graphTable[res_eta2$graphTable$varSeries == "ser2", ]
ori_plot(res_ser2)
adj_plot(res_ser2)

# Avec l'argument `by = "series"` (séries identifiées avec la colonne `series`)
res_eta3 <- benchmarking(stack_tsDF(ts_to_tsDF(sc_tri2)),
                         stack_bmkDF(ts_to_bmkDF(sc_ann2, ind_frequency = 4)),
                         rho = 0.729, lambda = 1, biasOption = 3,
                         by = "series",
                         quiet = TRUE)

# Graphique des taux de croissance pour le 3ième séries (ser3)
res_ser3 <- res_eta3$graphTable[res_eta3$graphTable$series == "ser3", ]
GR_plot(res_ser3)


# Fermer le périphérique de graphiques
if (creer_grDev) {
  dev.off()
}
