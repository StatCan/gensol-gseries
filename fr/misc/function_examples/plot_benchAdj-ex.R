#######
# Étapes préliminaires

# Stocks trimestriels (même patron répété pour 7 années)
sc_tri <- ts(rep(c(85, 95, 125, 95), 7), start = c(2013, 1), frequency = 4)

# Stocks de fin d'année
sc_ann <- ts(c(135, 125, 155, 145, 165), start = 2013, frequency = 1)

# Étalonnage proportionnel
# ... avec `benchmarking()` (approche "Proc Benchmarking")
res_PB <- benchmarking(
  ts_to_tsDF(sc_tri), 
  ts_to_bmkDF(sc_ann, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE)
# ... avec `stock_benchmarking()`
res_SB <- stock_benchmarking(
  ts_to_tsDF(sc_tri), 
  ts_to_bmkDF(sc_ann, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE)


#######
# Tracer les ajustements d'étalonnage

# Ajustements de `benchmarking()` (`res_PB`), sans légende
plot_benchAdj(PB_graphTable = res_PB$graphTable,
              legendPos = NULL)

# Ajouter les de `stock_benchmarking()` (`res_SB`), avec une légende cette fois
plot_benchAdj(PB_graphTable = res_PB$graphTable,
              SB_graphTable = res_SB$graphTable)

# Ajouter la spline cubique de `stock_benchmarking()` utilisée pour générer les ajustements
# (incluant les nœuds supplémentaires aux deux extrémités), avec légende en haut à gauche
plot_benchAdj(PB_graphTable = res_PB$graphTable,
              SB_graphTable = res_SB$graphTable,
              SB_splineKnots = res_SB$splineKnots,
              legendPos = "topleft")


#######
# Simuler l'étalonnage de plusieurs séries (3 séries de stocks)

sc_tri2 <- ts.union(ser1 = sc_tri, ser2 = sc_tri * 100, ser3 = sc_tri * 10)
sc_ann2 <- ts.union(ser1 = sc_ann, ser2 = sc_ann * 100, ser3 = sc_ann * 10)

# Avec l'argument `allCols = TRUE` (stocks identifiés avec la colonne `varSeries`)
res_SB2 <- stock_benchmarking(
  ts_to_tsDF(sc_tri2),
  ts_to_bmkDF(sc_ann2, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  allCols = TRUE,
  quiet = TRUE)

# Ajustements d'étalonnage pour le 2ième stock (ser2)
plot_benchAdj(
  SB_graphTable = res_SB2$graphTable[res_SB2$graphTable$varSeries == "ser2", ])

# Avec l'argument `by = "series"` (stocks identifiés avec la colonne `series`)
res_SB3 <- stock_benchmarking(
  stack_tsDF(ts_to_tsDF(sc_tri2)),
  stack_bmkDF(ts_to_bmkDF(
    sc_ann2, discrete_flag = TRUE, alignment = "e", ind_frequency = 4)),
  rho = 0.729, lambda = 1, biasOption = 3,
  by = "series",
  quiet = TRUE)

# Spline cubique pour le 3ième stock (ser3)
plot_benchAdj(
  SB_splineKnots = res_SB3$splineKnots[res_SB3$splineKnots$series == "ser3", ])
