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

# Initial and final (benchmarked) quarterly time series ("ts" objects)
qtr_ts
tsDF_to_ts(out_bench$series, frequency = 4)


# Proportional end-of-year stock benchmarking - multiple (3) series processed 
# with argument `by` (in BY-group mode)
qtr_mts <- ts.union(ser1 = qtr_ts,     ser2 = qtr_ts * 100, ser3 = qtr_ts * 10)
ann_mts <- ts.union(ser1 = ann_ts / 4, ser2 = ann_ts * 25,  ser3 = ann_ts * 2.5)
out_bench2 <- stock_benchmarking(stack_tsDF(ts_to_tsDF(qtr_mts)),
                                 stack_bmkDF(ts_to_bmkDF(
                                   ann_mts, ind_frequency = 4,
                                   discrete_flag = TRUE, alignment = "e")),
                                 rho = 0.729, lambda = 1, biasOption = 3,
                                 by = "series",
                                 quiet = TRUE)

# Initial and final (benchmarked) quarterly time series ("mts" objects)
qtr_mts
tsDF_to_ts(unstack_tsDF(out_bench2$series), frequency = 4)
