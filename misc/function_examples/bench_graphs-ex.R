# Deactivate the graphics device creation for the pkgdown website HTML reference page
# (irrelevant in that context)
new_grDev <- !(identical(Sys.getenv("IN_PKGDOWN"), "true"))


# Initial quarterly time series (indicator series to be benchmarked)
qtr_ts <- ts(c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
             start = c(2015, 1), frequency = 4)

# Annual time series (benchmarks)
ann_ts <- ts(c(10.3, 10.2), start = 2015, frequency = 1)

# Proportional benchmarking
out_bench <- benchmarking(ts_to_tsDF(qtr_ts),
                          ts_to_bmkDF(ann_ts, ind_frequency = 4),
                          rho = 0.729, lambda = 1, biasOption = 3,
                          quiet = TRUE)


# Open a new graphics device that is 11in wide and 8.5in tall 
# (US Letter paper size format in landscape view)
if (new_grDev) {
  dev.new(width = 11, height = 8.5, unit = "in", noRStudioGD = TRUE)
}

# Generate the benchmarking graphics
ori_plot(out_bench$graphTable)
adj_plot(out_bench$graphTable)
GR_plot(out_bench$graphTable)
GR_table(out_bench$graphTable)


# Simulate multiple series benchmarking (3 series)

qtr_mts <- ts.union(ser1 = qtr_ts, ser2 = qtr_ts * 100, ser3 = qtr_ts * 10)
ann_mts <- ts.union(ser1 = ann_ts, ser2 = ann_ts * 100, ser3 = ann_ts * 10)

# Using argument `allCols = TRUE` (identify series with column `varSeries`)
out_bench2 <- benchmarking(ts_to_tsDF(qtr_mts),
                           ts_to_bmkDF(ann_mts, ind_frequency = 4),
                           rho = 0.729, lambda = 1, biasOption = 3,
                           allCols = TRUE,
                           quiet = TRUE)

# Original and adjustment scale plots for the 2nd series (ser2)
ser2_res <- out_bench2$graphTable[out_bench2$graphTable$varSeries == "ser2", ]
ori_plot(ser2_res)
adj_plot(ser2_res)

# Using argument `by = "series"` (identify series with column `series`)
out_bench3 <- benchmarking(stack_tsDF(ts_to_tsDF(qtr_mts)),
                           stack_bmkDF(ts_to_bmkDF(ann_mts, ind_frequency = 4)),
                           rho = 0.729, lambda = 1, biasOption = 3,
                           by = "series",
                           quiet = TRUE)
						   
# Growth rates plot for the 3rd series (ser3)
ser3_res <- out_bench3$graphTable[out_bench3$graphTable$series == "ser3", ]
GR_plot(ser3_res)


# Close the graphics device 
if (new_grDev) {
  dev.off()
}
