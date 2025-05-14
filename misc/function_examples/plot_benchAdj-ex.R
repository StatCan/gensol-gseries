#######
# Preliminary setup

# Quarterly stocks (same annual pattern repeated for 7 years)
qtr_ts <- ts(rep(c(85, 95, 125, 95), 7), start = c(2013, 1), frequency = 4)

# End-of-year stocks
ann_ts <- ts(c(135, 125, 155, 145, 165), start = 2013, frequency = 1)

# Proportional benchmarking
# ... with `benchmarking()` ("Proc Benchmarking" approach)
out_PB <- benchmarking(
  ts_to_tsDF(qtr_ts), 
  ts_to_bmkDF(ann_ts, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE)
# ... with `stock_benchmarking()`
out_SB <- stock_benchmarking(
  ts_to_tsDF(qtr_ts), 
  ts_to_bmkDF(ann_ts, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE)


#######
# Plot the benchmarking adjustments

# `benchmarking()` adjustments (`out_PB`), without a legend
plot_benchAdj(PB_graphTable = out_PB$graphTable,
              legendPos = NULL)

# Add the `stock_benchmarking()` (`out_SB`) adjustments, with a legend this time
plot_benchAdj(PB_graphTable = out_PB$graphTable,
              SB_graphTable = out_SB$graphTable)

# Add the `stock_benchmarking()` cubic spline actually used to generate the adjustments
# (incl. the extra knots at both ends), with the legend located in the top-left corner
plot_benchAdj(PB_graphTable = out_PB$graphTable,
              SB_graphTable = out_SB$graphTable,
              SB_splineKnots = out_SB$splineKnots,
              legendPos = "topleft")


#######
# Simulate multiple series benchmarking (3 stock series)

qtr_mts <- ts.union(ser1 = qtr_ts, ser2 = qtr_ts * 100, ser3 = qtr_ts * 10)
ann_mts <- ts.union(ser1 = ann_ts, ser2 = ann_ts * 100, ser3 = ann_ts * 10)

# Using argument `allCols = TRUE` (identify stocks with column `varSeries`)
out_SB2 <- stock_benchmarking(
  ts_to_tsDF(qtr_mts),
  ts_to_bmkDF(ann_mts, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  allCols = TRUE,
  quiet = TRUE)

# Adjustments for 2nd stock (ser2)
plot_benchAdj(
  SB_graphTable = out_SB2$graphTable[out_SB2$graphTable$varSeries == "ser2", ])

# Using argument `by = "series"` (identify stocks with column `series`)
out_SB3 <- stock_benchmarking(
  stack_tsDF(ts_to_tsDF(qtr_mts)),
  stack_bmkDF(ts_to_bmkDF(
    ann_mts, discrete_flag = TRUE, alignment = "e", ind_frequency = 4)),
  rho = 0.729, lambda = 1, biasOption = 3,
  by = "series",
  quiet = TRUE)

# Cubic spline for 3nd stock (ser3)
plot_benchAdj(
  SB_splineKnots = out_SB3$splineKnots[out_SB3$splineKnots$series == "ser3", ])
