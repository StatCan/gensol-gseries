# Create an annual benchmarks data frame for 2 quarterly indicator series 
# (with missing benchmark values for the last 2 years)
my_benchmarks <- ts_to_bmkDF(ts(data.frame(ser1 = c(1:3 *  10, NA, NA), 
                                           ser2 = c(1:3 * 100, NA, NA)), 
                                start = c(2019, 1), frequency = 1),
                             ind_frequency = 4)
my_benchmarks


# Stack the benchmarks ...

# discarding `NA` values in the output stacked data frame (default behavior)
stack_bmkDF(my_benchmarks)

# keep `NA` values in the output stacked data frame
stack_bmkDF(my_benchmarks, keep_NA = TRUE)

# using custom variable (column) names
stack_bmkDF(my_benchmarks, ser_cName = "bmk_name", val_cName = "bmk_val")
