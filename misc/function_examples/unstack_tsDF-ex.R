# Proportional benchmarking for multiple (3) quarterly series processed with 
# argument `by` (in BY-group mode)

ind_vec <- c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3)
ind_df <- ts_to_tsDF(ts(data.frame(ser1 = ind_vec,
                                   ser2 = ind_vec * 100,
                                   ser3 = ind_vec * 10),
                        start = c(2015, 1), frequency = 4))

bmk_vec <- c(10.3, 10.2)
bmk_df <- ts_to_bmkDF(ts(data.frame(ser1 = bmk_vec,
                                    ser2 = bmk_vec * 100,
                                    ser3 = bmk_vec * 10), 
                         start = 2015, frequency = 1),
                      ind_frequency = 4)

out_bench <- benchmarking(stack_tsDF(ind_df),
                          stack_bmkDF(bmk_df),
                          rho = 0.729, lambda = 1, biasOption = 3,
                          by = "series",
                          quiet = TRUE)

# Initial and final (benchmarked) quarterly time series data frames
ind_df
unstack_tsDF(out_bench$series)
