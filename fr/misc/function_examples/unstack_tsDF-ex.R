# Étalonnage proportionnel pour plusieurs (3) séries trimestrielles traitées avec 
# l'argument `by` (en mode groupes-BY)

vec_ind <- c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3)
df_ind <- ts_to_tsDF(ts(data.frame(ser1 = vec_ind,
                                   ser2 = vec_ind * 100,
                                   ser3 = vec_ind * 10),
                        start = c(2015, 1), frequency = 4))

vec_eta <- c(10.3, 10.2)
df_eta <- ts_to_bmkDF(ts(data.frame(ser1 = vec_eta,
                                    ser2 = vec_eta * 100,
                                    ser3 = vec_eta * 10), 
                         start = 2015, frequency = 1),
                      ind_frequency = 4)

res_eta <- benchmarking(stack_tsDF(df_ind),
                        stack_bmkDF(df_eta),
                        rho = 0.729, lambda = 1, biasOption = 3,
                        by = "series",
                        quiet = TRUE)

# « Data frame » des séries chronologiques initiales et finales (étalonnés)
df_ind
unstack_tsDF(res_eta$series)
