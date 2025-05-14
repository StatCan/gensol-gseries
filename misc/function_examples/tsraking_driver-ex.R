# 1-dimensional raking problem where the quarterly sales of cars in the 3 prairie
# provinces (Alb., Sask. and Man.) for 8 quarters, from 2019 Q2 to 2021 Q1, must
# sum up to the total (`cars_tot`).

# Problem metadata
my_metadata <- data.frame(series = c("cars_alb", "cars_sask", "cars_man"),
                          total1 = rep("cars_tot", 3))
my_metadata

# Problem data
my_series <- ts(matrix(c(14, 18, 14, 58,
                         17, 14, 16, 44,
                         14, 19, 18, 58,
                         20, 18, 12, 53,
                         16, 16, 19, 44,
                         14, 15, 16, 50,
                         19, 20, 14, 52,
                         16, 15, 19, 51),
                       ncol = 4,
                       byrow = TRUE,
                       dimnames = list(NULL, c("cars_alb", "cars_sask",
                                               "cars_man", "cars_tot"))),
                start = c(2019, 2),
                frequency = 4)


###########
# Example 1: Period-by-period processing without temporal total preservation.

# Reconcile the data
out_raked1 <- tsraking_driver(my_series, my_metadata)

# Initial data
my_series

# Reconciled data
out_raked1

# Check the output cross-sectional constraint
all.equal(rowSums(out_raked1[, my_metadata$series]), as.vector(out_raked1[, "cars_tot"]))

# Check the control total (fixed)
all.equal(my_series[, "cars_tot"], out_raked1[, "cars_tot"])


###########
# Example 2: Annual total preservation for year 2020 (period-by-period processing
#            for incomplete years 2019 and 2021), with `quiet = TRUE` to avoid
#            displaying the function header for all processing groups.

# First, check that the 2020 annual total for the total series (`cars_tot`) and the
# sum of the component series (`cars_alb`, `cars_sask` and `cars_man`) matches.
# Otherwise, this "grand total" discrepancy would first have to be resolved before
# calling `tsraking_driver()`.
tot2020 <- aggregate.ts(window(my_series, start = c(2020, 1), end = c(2020, 4)))
all.equal(as.numeric(tot2020[, "cars_tot"]), sum(tot2020[, my_metadata$series]))

# Reconcile the data
out_raked2 <- tsraking_driver(in_ts = my_series,
                              metadata_df = my_metadata,
                              quiet = TRUE,
                              temporal_grp_periodicity = frequency(my_series))

# Initial data
my_series

# Reconciled data
out_raked2

# Check the output cross-sectional constraint
all.equal(rowSums(out_raked2[, my_metadata$series]), as.vector(out_raked2[, "cars_tot"]))

# Check the output temporal constraints (2020 annual totals for each series)
all.equal(tot2020,
          aggregate.ts(window(out_raked2, start = c(2020, 1), end = c(2020, 4))))

# Check the control total (fixed)
all.equal(my_series[, "cars_tot"], out_raked2[, "cars_tot"])


###########
# Example 3: Annual total preservation for fiscal years defined from April to March
#            (2019Q2-2020Q1 and 2020Q2-2021Q1).

# Calculate the fiscal year totals (as an annual "ts" object)
fiscalYr_tot <- ts(rbind(aggregate.ts(window(my_series,
                                             start = c(2019, 2),
                                             end = c(2020, 1))),
                         aggregate.ts(window(my_series,
                                             start = c(2020, 2),
                                             end = c(2021, 1)))),
                   start = 2019,
                   frequency = 1)

# Discrepancies in both fiscal year totals (total series vs. sum of the component series)
as.numeric(fiscalYr_tot[, "cars_tot"]) - rowSums(fiscalYr_tot[, my_metadata$series])


# 3a) Reconcile the fiscal year totals (rake the fiscal year totals of the component series
#     to those of the total series).
new_fiscalYr_tot <- tsraking_driver(in_ts = fiscalYr_tot,
                                    metadata_df = my_metadata,
                                    quiet = TRUE)

# Confirm that the previous discrepancies are now "gone" (are both zero)
as.numeric(new_fiscalYr_tot[, "cars_tot"]) - rowSums(new_fiscalYr_tot[, my_metadata$series])

# 3b) Benchmark the quarterly component series to these new (coherent) fiscal year totals.
out_bench <- benchmarking(series_df = ts_to_tsDF(my_series[, my_metadata$series]),
                          benchmarks_df = ts_to_bmkDF(
                            new_fiscalYr_tot[, my_metadata$series],
                            ind_frequency = frequency(my_series),
                            
                            # Fiscal years starting on Q2 (April)
                            bmk_interval_start = 2),
                          
                          rho = 0.729,
                          lambda = 1,
                          biasOption = 2,
                          allCols = TRUE,
                          quiet = TRUE)
my_new_ser <- tsDF_to_ts(cbind(out_bench$series, cars_tot = my_series[, "cars_tot"]),
                         frequency = frequency(my_series))

# 3c) Reconcile the quarterly data with preservation of fiscal year totals.
out_raked3 <- tsraking_driver(in_ts = my_new_ser,
                              metadata_df = my_metadata,
                              temporal_grp_periodicity = frequency(my_series),
                              
                              # Fiscal years starting on Q2 (April)
                              temporal_grp_start = 2,
                              
                              quiet = TRUE)

# Initial data
my_series

# With coherent fiscal year totals
my_new_ser

# Reconciled data
out_raked3

# Check the output cross-sectional constraint
all.equal(rowSums(out_raked3[, my_metadata$series]), as.vector(out_raked3[, "cars_tot"]))

# Check the output temporal constraints (both fiscal year totals for all series)
all.equal(rbind(aggregate.ts(window(my_new_ser, start = c(2019, 2), end = c(2020, 1))),
                aggregate.ts(window(my_new_ser, start = c(2020, 2), end = c(2021, 1)))),
          rbind(aggregate.ts(window(out_raked3, start = c(2019, 2), end = c(2020, 1))),
                aggregate.ts(window(out_raked3, start = c(2020, 2), end = c(2021, 1)))))

# Check the control total (fixed)
all.equal(my_series[, "cars_tot"], out_raked3[, "cars_tot"])
