######################################################################################
#        Indirect series derivation framework with `tsbalancing()` metadata
######################################################################################
#
# Is is assumed (agreed) that...
#
# a) All balancing constraints are equality constraints (`type = EQ`).
# b) All constraints have only one nonbinding (free) series: the series to be derived
#    (i.e., all series have an alter. coef of 0 except the series to be derived).
# c) Each constraint derives a different (new) series.
# d) Constraints are the same for all periods (i.e., no "dated" alter. coefs 
#    specified with column `timeVal`).
######################################################################################


# Derive the 5 marginal totals of a 2 x 3 two-dimensional data cube using `tsbalancing()` 
# metadata (data cube aggregation constraints respect the above assumptions).


# Build the balancing problem specs through the (simpler) raking metadata.
my_specs <- rkMeta_to_blSpecs(
  data.frame(series = c("A1", "A2", "A3",
                        "B1", "B2", "B3"),
             total1 = c(rep("totA", 3),
                        rep("totB", 3)),
             total2 = rep(c("tot1", "tot2", "tot3"), 2)),
  alterSeries = 0,  # binding (fixed) component series
  alterTotal1 = 1,  # nonbinding (free) marginal totals (to be derived)
  alterTotal2 = 1)  # nonbinding (free) marginal totals (to be derived)
my_specs

# 6 periods (quarters) of data with marginal totals set to zero (0): they MUST exist
# in the input data AND contain valid (non missing) data.
my_ts <- ts(data.frame(A1 = c(12, 10, 12,  9, 15,  7),
                       B1 = c(20, 21, 15, 17, 19, 18),
                       A2 = c(14,  9,  8,  9, 11, 10),
                       B2 = c(20, 29, 20, 24, 21, 17),
                       A3 = c(13, 15, 17, 14, 16, 12),
                       B3 = c(24, 20, 30, 23, 21, 19),
                       tot1 = rep(0, 6),
                       tot2 = rep(0, 6),
                       tot3 = rep(0, 6),
                       totA = rep(0, 6),
                       totB = rep(0, 6)),
            start = 2019, frequency = 4)

# Get the balancing problem elements.
n_per <- nrow(my_ts)
p <- build_balancing_problem(my_ts, my_specs, 
                             temporal_grp_periodicity = n_per)

# `A2`, `op2` and `b2` define 30 constraints (5 marginal totals X 6 periods) 
# involving a total of 66 time series data points (11 series X 6 periods) of which 
# 36 belong to the 6 component series and 30 belong to the 5 marginal totals.
dim(p$A2)

# Get the names of the marginal totals (series with a nonzero alter. coef), in the order 
# in which the corresponding constraints appear in the specs (constraints specification 
# order).
tmp <- p$coefs_df$col[p$coefs_df$con.flag]
tot_names <- tmp[tmp %in% p$ser_names[p$alter$nondated_id_vec[p$alter$nondated_coefs != 0]]]

# Define logical flags identifying the marginal total columns:
# - `tot_col_logi1`: for single-period elements (of length 11 = number of series)
# - `tot_col_logi2`: for multi-period elements (of length 66 = number of data points), 
#                    in "column-major order" (the `A2` matrix element construction order)
tot_col_logi1 <- p$ser_names %in% tot_names
tot_col_logi2 <- rep(tot_col_logi1, each = n_per)

# Order of the marginal totals to be derived based on
# ... the input data columns ("mts" object `my_ts`)
p$ser_names[tot_col_logi1]
# ... the constraints specification (data frame `my_specs`)
tot_names


# Calculate the 5 marginal totals for all 6 periods
# Note: the following calculation allows for general linear equality constraints, i.e.,
#       a) nonzero right-hand side (RHS) constraint values (`b2`) and 
#       b) nonzero constraint coefs other than 1 for the component series and -1 for 
#          the derived series.
my_ts[, tot_names] <- {
  (
    # Constraints RHS.
    p$b2 - 

    # Sums of the components ("weighted" by the constraint coefficients).
    p$A2[, !tot_col_logi2, drop = FALSE] %*% as.vector(p$values_ts[, !tot_col_logi1])
  ) /

  # Derived series constraint coefficients: `t()` allows for a "row-major order" search 
  # in matrix `A2` (i.e., according to the constraints specification order).
  # Note: `diag(p$A2[, tot_col_logi2])` would work if `p$ser_names[tot_col_logi1]` and 
  #       `tot_names` were identical (same totals order); however, the following search 
  #       in "row-major order" will always work (and is necessary in the current case).
  t(p$A2[, tot_col_logi2])[t(p$A2[, tot_col_logi2]) != 0]
}
my_ts
