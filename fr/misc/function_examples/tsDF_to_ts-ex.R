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

# Séries chronologiques initiale et finale (étalonnée) - objects « ts » 
sc_tri
tsDF_to_ts(res_eta$series, frequency = 4)


# Étalonnage proportionnel de stocks de fin d'année - plusieurs (3) séries 
# traitées avec l'argument `by` (en mode groupes-BY)
sc_tri2 <- ts.union(ser1 = sc_tri,     ser2 = sc_tri * 100, ser3 = sc_tri * 10)
sc_ann2 <- ts.union(ser1 = sc_ann / 4, ser2 = sc_ann * 25,  ser3 = sc_ann * 2.5)
res_eta2 <- stock_benchmarking(stack_tsDF(ts_to_tsDF(sc_tri2)),
                                 stack_bmkDF(ts_to_bmkDF(
                                   sc_ann2, ind_frequency = 4,
                                   discrete_flag = TRUE, alignment = "e")),
                                 rho = 0.729, lambda = 1, biasOption = 3,
                                 by = "series",
                                 quiet = TRUE)

# Séries chronologiques initiales et finales (étalonnées) - objects « mts » 
sc_tri2
tsDF_to_ts(unstack_tsDF(res_eta2$series), frequency = 4)
