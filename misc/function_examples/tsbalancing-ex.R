###########
# Example 1: In this first example, the objective is to balance a following simple 
#            accounting table (`Profits = Revenues – Expenses`) for 5 quarters 
#            without modifying `Profits` where `Revenues >= 0` and `Expenses >= 0`.

# Problem specifications
my_specs1 <- data.frame(type = c("EQ", rep(NA, 3), 
                                 "alter", NA, 
                                 "lowerBd", NA, NA),
                        col = c(NA, "Revenues", "Expenses", "Profits", 
                                NA, "Profits", 
                                NA, "Revenues", "Expenses"),
                        row = c(rep("Accounting Rule", 4), 
                                rep("Alterability Coefficient", 2), 
                                rep("Lower Bound", 3)),
                        coef = c(NA, 1, -1, -1,
                                 NA, 0,
                                 NA, 0, 0))
my_specs1

# Problem data
my_series1 <- ts(matrix(c( 15,  10,  10,
                            4,   8,  -1,
                          250, 250,   5,
                            8,  12,   0,
                            0,  45, -55),
                        ncol = 3,
                        byrow = TRUE,
                        dimnames = list(NULL, c("Revenues", "Expenses", "Profits"))),
                 start = c(2022, 1),
                 frequency = 4)

# Reconcile the data
out_balanced1 <- tsbalancing(in_ts = my_series1,
                             problem_specs_df = my_specs1,
                             display_level = 3)

# Initial data
my_series1

# Reconciled data
out_balanced1$out_ts

# Check for invalid solutions
any(out_balanced1$proc_grp_df$sol_status_val < 0)

# Display the maximum output constraint discrepancies
out_balanced1$proc_grp_df[, c("proc_grp_label", "max_discr")]


# The solution returned by `tsbalancing()` corresponds to equal proportional changes 
# (pro-rating) and is related to the default alterability coefficients of 1. Equal 
# absolute changes could be obtained instead by specifying alterability coefficients 
# equal to the inverse of the initial values. 
#
# Let’s do this for the processing group 2022Q2 (`timeVal = 2022.25`), with the default 
# displayed level of information (`display_level = 1`). 

my_specs1b <- rbind(cbind(my_specs1, 
                          data.frame(timeVal = rep(NA_real_, nrow(my_specs1)))),
                    data.frame(type = rep(NA, 2),
                               col = c("Revenues", "Expenses"),
                               row = rep("Alterability Coefficient", 2),
                               coef = c(0.25, 0.125),
                               timeVal = rep(2022.25, 2)))
my_specs1b

out_balanced1b <- tsbalancing(in_ts = my_series1,
                              problem_specs_df = my_specs1b)

# Display the initial 2022Q2 values and both solutions
cbind(data.frame(Status = c("initial", "pro-rating", "equal change")),
      rbind(as.data.frame(my_series1[2, , drop = FALSE]), 
            as.data.frame(out_balanced1$out_ts[2, , drop = FALSE]),
            as.data.frame(out_balanced1b$out_ts[2, , drop = FALSE])),
      data.frame(Accounting_discr = c(my_series1[2, 1] - my_series1[2, 2] - 
                                        my_series1[2, 3],
                                      out_balanced1$out_ts[2, 1] - 
                                        out_balanced1$out_ts[2, 2] - 
                                        out_balanced1$out_ts[2, 3],
                                      out_balanced1b$out_ts[2, 1] - 
                                        out_balanced1b$out_ts[2, 2] - 
                                        out_balanced1b$out_ts[2, 3]),
                 RelChg_Rev = c(NA, 
                                out_balanced1$out_ts[2, 1] / my_series1[2, 1] - 1,
                                out_balanced1b$out_ts[2, 1] / my_series1[2, 1] - 1),
                 RelChg_Exp = c(NA, 
                                out_balanced1$out_ts[2, 2] / my_series1[2, 2] - 1,
                                out_balanced1b$out_ts[2, 2] / my_series1[2, 2] - 1),
                 AbsChg_Rev = c(NA, 
                                out_balanced1$out_ts[2, 1] - my_series1[2, 1],
                                out_balanced1b$out_ts[2, 1] - my_series1[2, 1]),
                 AbsChg_Exp = c(NA, 
                                out_balanced1$out_ts[2, 2] - my_series1[2, 2],
                                out_balanced1b$out_ts[2, 2] - my_series1[2, 2])))


###########
# Example 2: In this second example, consider the simulated data on quarterly 
#            vehicle sales by region (West, Centre and East), along with a national 
#            total for the three regions, and by type of vehicles (cars, trucks and 
#            a total that may include other types of vehicles). The input data correspond 
#            to directly seasonally adjusted data that have been benchmarked to the 
#            annual totals of the corresponding unadjusted time series data as part 
#            of the seasonal adjustment process (e.g., with the FORCE spec in the 
#            X-13ARIMA-SEATS software). 
#
#            The objective is to reconcile the regional sales to the national sales 
#            without modifying the latter while ensuring that the sum of the sales of 
#            cars and trucks do not exceed 95% of the sales for all types of vehicles 
#            in any quarter. For illustrative purposes, we assume that the sales of 
#            trucks in the Centre region for the 2nd quarter of 2022 cannot be modified.

# Problem specifications
my_specs2 <- data.frame(
  
  type = c("EQ", rep(NA, 4),
           "EQ", rep(NA, 4),
           "EQ", rep(NA, 4),
           "LE", rep(NA, 3),
           "LE", rep(NA, 3),
           "LE", rep(NA, 3),
           "alter", rep(NA, 4)),
  
  col = c(NA, "West_AllTypes", "Centre_AllTypes", "East_AllTypes", "National_AllTypes", 
          NA, "West_Cars", "Centre_Cars", "East_Cars", "National_Cars", 
          NA, "West_Trucks", "Centre_Trucks", "East_Trucks", "National_Trucks", 
          NA, "West_Cars", "West_Trucks", "West_AllTypes", 
          NA, "Centre_Cars", "Centre_Trucks", "Centre_AllTypes", 
          NA, "East_Cars", "East_Trucks", "East_AllTypes",
          NA, "National_AllTypes", "National_Cars", "National_Trucks", "Centre_Trucks"),
  
  row = c(rep("National Total - All Types", 5),
          rep("National Total - Cars", 5),
          rep("National Total - Trucks", 5),
          rep("West Region Sum", 4),
          rep("Center Region Sum", 4),
          rep("East Region Sum", 4),
          rep("Alterability Coefficient", 5)),
  
  coef = c(NA, 1, 1, 1, -1,
           NA, 1, 1, 1, -1,
           NA, 1, 1, 1, -1,
           NA, 1, 1, -.95,
           NA, 1, 1, -.95,
           NA, 1, 1, -.95,
           NA, 0, 0, 0, 0),
  
  time_val = c(rep(NA, 31), 2022.25))

# Beginning and end of the specifications data frame
head(my_specs2, n = 10)
tail(my_specs2)

# Problem data
my_series2 <- ts(
  matrix(c(43, 49, 47, 136, 20, 18, 12, 53, 20, 22, 26, 61,
           40, 45, 42, 114, 16, 16, 19, 44, 21, 26, 21, 59,
           35, 47, 40, 133, 14, 15, 16, 50, 19, 25, 19, 71,
           44, 44, 45, 138, 19, 20, 14, 52, 21, 18, 27, 74,
           46, 48, 55, 135, 16, 15, 19, 51, 27, 25, 28, 54),
         ncol = 12,
         byrow = TRUE,
         dimnames = list(NULL, 
                         c("West_AllTypes", "Centre_AllTypes", "East_AllTypes", 
                           "National_AllTypes", "West_Cars", "Centre_Cars", 
                           "East_Cars", "National_Cars", "West_Trucks", 
                           "Centre_Trucks", "East_Trucks", "National_Trucks"))),
  start = c(2022, 1),
  frequency = 4)

# Reconcile without displaying the function header and enforce nonnegative data
out_balanced2 <- tsbalancing(
  in_ts                    = my_series2,
  problem_specs_df         = my_specs2,
  temporal_grp_periodicity = frequency(my_series2),
  lower_bound              = 0,
  quiet                    = TRUE)

# Initial data
my_series2

# Reconciled data
out_balanced2$out_ts

# Check for invalid solutions
any(out_balanced2$proc_grp_df$sol_status_val < 0)

# Display the maximum output constraint discrepancies
out_balanced2$proc_grp_df[, c("proc_grp_label", "max_discr")]


###########
# Example 3: Reproduce the `tsraking_driver()` 2nd example with `tsbalancing()` 
#            (1-dimensional raking problem with annual total preservation).

# `tsraking()` metadata
my_metadata3 <- data.frame(series = c("cars_alb", "cars_sask", "cars_man"),
                           total1 = rep("cars_tot", 3))
my_metadata3

# `tsbalancing()` problem specifications
my_specs3 <- rkMeta_to_blSpecs(my_metadata3)
my_specs3

# Problem data
my_series3 <- ts(matrix(c(14, 18, 14, 58,
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

# Reconcile the data with `tsraking()` (through `tsraking_driver()`)
out_raked3 <- tsraking_driver(in_ts = my_series3,
                              metadata_df = my_metadata3,
                              temporal_grp_periodicity = frequency(my_series3),
                              quiet = TRUE)

# Reconcile the data with `tsbalancing()`
out_balanced3 <- tsbalancing(in_ts = my_series3,
                             problem_specs_df = my_specs3,
                             temporal_grp_periodicity = frequency(my_series3),
                             quiet = TRUE)

# Initial data
my_series3

# Both sets of reconciled data
out_raked3
out_balanced3$out_ts

# Check for invalid `tsbalancing()` solutions
any(out_balanced3$proc_grp_df$sol_status_val < 0)

# Display the maximum output constraint discrepancies from the `tsbalancing()` solutions
out_balanced3$proc_grp_df[, c("proc_grp_label", "max_discr")]

# Confirm that both solutions (`tsraking() and `tsbalancing()`) are the same
all.equal(out_raked3, out_balanced3$out_ts)
