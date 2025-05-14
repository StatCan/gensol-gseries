# Set the working directory (for the PDF files)
iniwd <- getwd() 
setwd(tempdir())


###########
# Example 1: Simple case with a single quarterly series to benchmark to annual values

# Quarterly indicator series
my_series1 <- ts_to_tsDF(ts(c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
                            start = c(2015, 1),
                            frequency = 4))
my_series1

# Annual benchmarks for quarterly data
my_benchmarks1 <- ts_to_bmkDF(ts(c(10.3, 10.2),
                                 start = 2015,
                                 frequency = 1),
                              ind_frequency = 4)
my_benchmarks1

# Benchmarking using...
#   - recommended `rho` value for quarterly series (`rho = 0.729`)
#   - proportional model (`lambda = 1`)
#   - bias-corrected indicator series with the estimated bias (`biasOption = 3`)
out_bench1 <- benchmarking(my_series1,
                           my_benchmarks1,
                           rho = 0.729,
                           lambda = 0,
                           biasOption = 3)

# Generate the benchmarking graphs
plot_graphTable(out_bench1$graphTable, "Ex1_graphs.pdf")


###########
# Example 2: Two quarterly series to benchmark to annual values,
#            with BY-groups and user-defined alterability coefficients

# Sales data (same sales for groups A and B; only alter coefs for van sales differ)
qtr_sales <- ts(matrix(c(# Car sales
                         1851, 2436, 3115, 2205, 1987, 2635, 3435, 2361, 2183, 2822,
                         3664, 2550, 2342, 3001, 3779, 2538, 2363, 3090, 3807, 2631,
                         2601, 3063, 3961, 2774, 2476, 3083, 3864, 2773, 2489, 3082,
                         # Van sales
                         1900, 2200, 3000, 2000, 1900, 2500, 3800, 2500, 2100, 3100,
                         3650, 2950, 3300, 4000, 3290, 2600, 2010, 3600, 3500, 2100,
                         2050, 3500, 4290, 2800, 2770, 3080, 3100, 2800, 3100, 2860),
                       ncol = 2),
                start = c(2011, 1),
                frequency = 4,
                names = c("car_sales", "van_sales"))

ann_sales <- ts(matrix(c(# Car sales
                         10324, 10200, 10582, 11097, 11582, 11092,
                         # Van sales
                         12000, 10400, 11550, 11400, 14500, 16000),
                       ncol = 2),
                start = 2011,
                frequency = 1,
                names = c("car_sales", "van_sales"))

# Quarterly indicator series (with default alter coefs for now)
my_series2 <- rbind(cbind(data.frame(group = rep("A", nrow(qtr_sales)),
                                     alt_van = rep(1, nrow(qtr_sales))),
                          ts_to_tsDF(qtr_sales)),
                    cbind(data.frame(group = rep("B", nrow(qtr_sales)),
                                     alt_van = rep(1, nrow(qtr_sales))),
                          ts_to_tsDF(qtr_sales)))

# Set binding van sales (alter coef = 0) for 2012 Q1 and Q2 in group A (rows 5 and 6)
my_series2$alt_van[c(5,6)] <- 0
head(my_series2, n = 10)
tail(my_series2)


# Annual benchmarks for quarterly data (without alter coefs)
my_benchmarks2 <- rbind(cbind(data.frame(group = rep("A", nrow(ann_sales))),
                              ts_to_bmkDF(ann_sales, ind_frequency = 4)),
                        cbind(data.frame(group = rep("B", nrow(ann_sales))),
                              ts_to_bmkDF(ann_sales, ind_frequency = 4)))
my_benchmarks2

# Benchmarking using...
#   - recommended `rho` value for quarterly series (`rho = 0.729`)
#   - proportional model (`lambda = 1`)
#   - without bias correction (`biasOption = 1` and `bias` not specified)
#   - `quiet = TRUE` to avoid generating the function header
out_bench2 <- benchmarking(my_series2,
                           my_benchmarks2,
                           rho = 0.729,
                           lambda = 1,
                           biasOption = 1,
                           var = c("car_sales", "van_sales / alt_van"),
                           with = c("car_sales", "van_sales"),
                           by = "group",
                           quiet = TRUE)

# Generate the benchmarking graphs
plot_graphTable(out_bench2$graphTable, "Ex2_graphs.pdf")

# Check the value of van sales for 2012 Q1 and Q2 in group A (fixed values)
all.equal(my_series2$van_sales[c(5,6)], out_bench2$series$van_sales[c(5,6)])


###########
# Example 3: same as example 2, but benchmarking all 4 series as BY-groups
#            (4 BY-groups of 1 series instead of 2 BY-groups of 2 series)

qtr_sales2 <- ts.union(A = qtr_sales, B = qtr_sales)
my_series3 <- stack_tsDF(ts_to_tsDF(qtr_sales2))
my_series3$alter <- 1
my_series3$alter[my_series3$series == "A.van_sales"
                & my_series3$year == 2012 & my_series3$period <= 2] <- 0
head(my_series3)
tail(my_series3)


ann_sales2 <- ts.union(A = ann_sales, B = ann_sales)
my_benchmarks3 <- stack_bmkDF(ts_to_bmkDF(ann_sales2, ind_frequency = 4))
head(my_benchmarks3)
tail(my_benchmarks3)

out_bench3 <- benchmarking(my_series3,
                           my_benchmarks3,
                           rho = 0.729,
                           lambda = 1,
                           biasOption = 1,
                           var = "value / alter",
                           with = "value",
                           by = "series",
                           quiet = TRUE)

# Generate the benchmarking graphs
plot_graphTable(out_bench3$graphTable, "Ex3_graphs.pdf")

# Convert data frame `out_bench3$series` to a "mts" object
qtr_sales2_bmked <- tsDF_to_ts(unstack_tsDF(out_bench3$series), frequency = 4)

# Print the first 10 observations
ts(qtr_sales2_bmked[1:10, ], start = start(qtr_sales2), deltat = deltat(qtr_sales2))

# Check the value of van sales for 2012 Q1 and Q2 in group A (fixed values)
all.equal(window(qtr_sales2[, "A.van_sales"], start = c(2012, 1), end = c(2012, 2)),
          window(qtr_sales2_bmked[, "A.van_sales"], start = c(2012, 1), end = c(2012, 2)))


# Reset the working directory to its initial location
setwd(iniwd)
