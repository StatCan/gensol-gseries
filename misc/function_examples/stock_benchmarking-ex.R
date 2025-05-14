# Quarterly stock series (same pattern repeated every year)
my_series <- ts_to_tsDF(ts(rep(c(85, 95, 125, 95), 7),
                           start = c(2013, 1),
                           frequency = 4))
head(my_series)

# Annual benchmarks (end-of-year stocks)
my_benchmarks <- ts_to_bmkDF(ts(c(135, 125, 155, 145, 165),
                                start = 2013,
                                frequency = 1),
                             discrete_flag = TRUE,
                             alignment = "e",
                             ind_frequency = 4)
my_benchmarks

# Benchmark using...
#   - recommended `rho` value for quarterly series (`rho = 0.729`)
#   - proportional model (`lambda = 1`)
#   - bias-corrected indicator series with the estimated bias (`biasOption = 3`)

# ... with `benchmarking()` ("Proc Benchmarking" approach)
out_PB <- benchmarking(my_series,
                       my_benchmarks,
                       rho = 0.729,
                       lambda = 1,
                       biasOption = 3)

# ... with `stock_benchmarking()` ("Stock Benchmarking" approach)
out_SB <- stock_benchmarking(my_series,
                             my_benchmarks,
                             rho = 0.729,
                             lambda = 1,
                             biasOption = 3)

# Compare the benchmarking adjustments of both approaches
plot_benchAdj(PB_graphTable = out_PB$graphTable,
              SB_graphTable = out_SB$graphTable)


# Have you noticed how smoother the `stock_benchmarking()` adjustments are compared 
# to the `benchmarking()` ones?

# The gain in the quality of the resulting benchmarked stocks might not necessarily
# be obvious in this example
plot(out_SB$graphTable$t, out_SB$graphTable$benchmarked,
     type = "b", col = "red", xlab = "t", ylab = "Benchmarked Stock")
lines(out_PB$graphTable$t, out_PB$graphTable$benchmarked,
      type = "b", col = "blue")
legend(x = "topleft", bty = "n", inset = 0.05, lty = 1, pch = 1,
       col = c("red", "blue"), legend = c("out_SB", "out_PB"))
title("Benchmarked Stock")


# What about cases where a flat indicator is used, which may happen in practice
# in absence of a good indicator of the quarterly (sub-annual) movement?
my_series2 <- my_series
my_series2$value <- 1  # flat indicator
head(my_series2)
out_PB2 <- benchmarking(my_series2,
                        my_benchmarks,
                        rho = 0.729,
                        lambda = 1,
                        biasOption = 3,
                        quiet = TRUE)  # don't show the function header

out_SB2 <- stock_benchmarking(my_series2,
                              my_benchmarks,
                              rho = 0.729,
                              lambda = 1,
                              biasOption = 3,
                              quiet = TRUE)  # don't show the function header

plot(out_SB2$graphTable$t, out_SB2$graphTable$benchmarked,
     type = "b", col = "red", xlab = "t", ylab = "Benchmarked Stock")
lines(out_PB2$graphTable$t, out_PB2$graphTable$benchmarked,
      type = "b", col = "blue")
legend(x = "bottomright", bty = "n", inset = 0.05, lty = 1, pch = 1,
       col = c("red", "blue"), legend = c("out_SB2", "out_PB2"))
title("Benchmarked Stock - Flat Indicator")


# The awkwardness of the benchmarked stocks produced by `benchmarking()` suddenly
# becomes obvious. That's because the benchmarked series corresponds to the
# benchmarking adjustments when using a flat indicator (e.g., a series on 1's
# with proportional benchmarking):
plot_benchAdj(PB_graphTable = out_PB2$graphTable,
              SB_graphTable = out_SB2$graphTable)


# The shortcomings of the "Proc Benchmarking" approach (function `benchmarking()`)
# with stocks is also quite noticeable in this case when looking at the resulting
# quarterly growth rates, which are conveniently produced by `plot_graphTable()`.
# Pay particular attention to the transition in the growth rates from Q4 to Q1
# every year in the generated PDF graphs.
plot_graphTable(out_PB2$graphTable, file.path(tempdir(), "PB_stock_flat_ind.pdf"))
plot_graphTable(out_SB2$graphTable, file.path(tempdir(), "SB_stock_flat_ind.pdf"))


# Illustrate approximating a natural cubic spline at the original end knots (first and 
# last benchmarks) by specifying a large `low_freq_periodicity` value.
out_SB3 <- stock_benchmarking(my_series,
                              my_benchmarks,
                              rho = 0.729,
                              lambda = 1,
                              biasOption = 3,
                              
                              # Large value to approximate a natural cubic spline
                              low_freq_periodicity = 100,
                              
                              quiet = TRUE)

plot_benchAdj(SB_graphTable = out_SB3$graphTable,
              SB_splineKnots = out_SB3$splineKnots,
              legendPos = "topleft")


# Illustrate "oscillations" of the cubic spline beyond the original end knots with
# Denton-type benchmarking (`rho ~ 1`) caused by using low frequency (annual) extra knots.
out_SB4 <- stock_benchmarking(my_series,
                              my_benchmarks,
                              rho = 0.999,
                              lambda = 1,
                              biasOption = 3,
                              
                              # Use 3 annual extra knots first
                              n_low_freq_proj = 3,
                              proj_knots_rho_bd = 1,
                              
                              quiet = TRUE)

plot_benchAdj(SB_graphTable = out_SB4$graphTable,
              SB_splineKnots = out_SB4$splineKnots)

# No "oscillations" with the default `proj_knots_rho_bd` value because high frequency 
# (quarterly) extra knots are used right away (`n_low_freq_proj` is ignored) since 
# `rho = 0.999` exceeds the default `proj_knots_rho_bd` value (0.995^3 for quarterly data). 
# These projected adjustments are more in line with Denton-type adjustments (straight line).
out_SB4b <- stock_benchmarking(my_series,
                               my_benchmarks,
                               rho = 0.999,
                               lambda = 1,
                               biasOption = 3,
                               quiet = TRUE)

plot_benchAdj(SB_graphTable = out_SB4b$graphTable,
              SB_splineKnots = out_SB4b$splineKnots)


# Illustrate "contortions" of the cubic spline around the original end knots caused
# by using high frequency extra knots right away (`n_low_freq_proj = 0`), i.e., using 
# the same projected adjustments as those that would be obtained with `benchmarking()`.
#
# To exacerbate the phenomenon, we'll use monthly data (11 periods between each annual 
# benchmark compared to only 3 for quarterly data, i.e., a less constrained spline) 
# and a rather small value for `rho` (0.5 < 0.9 = recommended value for monthly data) 
# for a faster convergence to the bias of the projected adjustments.

yr_vec <- unique(my_series$year)
my_series3 <- data.frame(year = rep(yr_vec, each = 12),
                         period = rep(1:12, length(yr_vec)),
                         value = rep(1, 12 * length(yr_vec)))  # flat indicator
my_benchmarks2 <- my_benchmarks
my_benchmarks2[c("startPeriod", "endPeriod")] <- 12

out_SB5 <- stock_benchmarking(my_series3,
                              my_benchmarks2,
                              rho = 0.5,
                              lambda = 1,
                              biasOption = 3,
                              
                              # Use monthly extra knots right away
                              n_low_freq_proj = 0,
                              
                              quiet = TRUE)

plot_benchAdj(SB_graphTable = out_SB5$graphTable,
              SB_splineKnots = out_SB5$splineKnots)

# No excessive "contortions" around the original end knots with the default  
# `n_low_freq_proj = 1`, i.e., use 1 low frequency (annual) extra knot first.
out_SB5b <- stock_benchmarking(my_series3,
                               my_benchmarks2,
                               rho = 0.5,
                               lambda = 1,
                               biasOption = 3,
                               quiet = TRUE)

plot_benchAdj(SB_graphTable = out_SB5b$graphTable,
              SB_splineKnots = out_SB5b$splineKnots)

# To even better highlight the potential excessive "contortions" of the cubic spline 
# when enforcing the `benchmarking()` projected adjustment (i.e., low frequency extra 
# knots right away with `n_low_freq_proj = 0`), let's plot the previous two sets of 
# adjustments on the same plot (the blue line corresponds to the `n_low_freq_proj = 0` 
# case, i.e., the `benchmarking()` projected adjustments while the red line corresponds 
# to the default `stock_benchmarking()` adjustments, i.e., `n_low_freq_proj = 1`).
plot_benchAdj(PB_graphTable = out_SB5$graphTable,
              SB_graphTable = out_SB5b$graphTable,
              legend = NULL)
