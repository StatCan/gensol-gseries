######
# Objects and functions in this "benchmarking utility script" are prefixed with "bk."
# to make them easy to spot in the (regular) benchmarking scripts.


# The functions defined in this script are internal functions shared by `benchmarking()`
# and `stock_benchmarking()` that would otherwise need to be defined inside (duplicated in)
# both function scripts. Environment `bk.e` created below contains objects that are not (cannot be)
# passed as arguments to the shared internal benchmarking functions. Notes:
#   - Environment `bk.e` must be compiled before the benchmarking function scripts, hence 'aaa_'
#     in the current script name.
#   - Although environment `bk.e` is primarily used for the shared internal benchmarking functions,
#     it can be used, if needed, by any package function to store objects.
#   - Large objects created in environment `bk.e` that are not needed after the function execution
#     should be removed at the end of the function execution with `rlang::env_unbind()`.
bk.e <- new.env(parent = emptyenv())


# Bias adjustment functions according to (main function) arguments 'lambda' and 'biasOption':
#   - add/mult bias estimation functions
#   - add/mult bias application (correction) functions
#   - bias option implementation functions
bk.calc_add_bias <- function(s_lowFreq, a, denom, ...) {
  sum(a - s_lowFreq) / denom
}
bk.calc_mult_bias <- function(s_lowFreq, a, tol = gs.tolerance, ...) {
  numer <- sum(a)
  denom <- sum(s_lowFreq)
  if (abs(denom) <= tol) {
    if (abs(numer) > tol) {
      warning("Bias calculation involves division by zero. Assuming no bias (1.0).\n",
              call. = FALSE, immediate. = TRUE)
      bk.e$warning_flag <- TRUE
    }
    1
  } else {
    numer / denom
  }
}
bk.apply_add_bias <- function(s, b) {
  s + b
}
bk.apply_mult_bias <- function(s, b) {
  s * b
}
bk.apply_biasOption1 <- function(msg_f, calc_f, s_lowFreq, a, denom, tol, apply_f, s, bias, str) {
  msg_f("BIAS = ", format(bias), " (", str, ")\n")
  bk.e$actual_bias <- bias  # package `bk.e` environment assignment
  apply_f(s, bias)  # `apply_f` is either `bk.apply_add_bias` or `bk.apply_mult_bias`
}
bk.apply_biasOption2 <- function(msg_f, calc_f, s_lowFreq, a, denom, tol, apply_f, s, bias, str) {
  b <- calc_f(s_lowFreq, a, denom = denom, tol = tol)  # `calc_f` is either `bk.calc_add_bias` or `bk.calc_mult_bias`
  # `denom` is `sum(J)` for PB and `length(a)` for SB
  msg_f("BIAS = ", format(bias), " (", str, ")")
  msg_f("BIAS = ", format(b), " (calculated, but NOT used)\n")
  bk.e$actual_bias <- bias  # package `bk.e` environment assignment
  apply_f(s, bias)  # `apply_f` is either `bk.apply_add_bias` or `bk.apply_mult_bias`
}
bk.apply_biasOption3 <- function(msg_f, calc_f, s_lowFreq, a, denom, tol, apply_f, s, ...) {
  b <- calc_f(s_lowFreq, a, denom = denom, tol = tol)  # `calc_f` is either `bk.calc_add_bias` or `bk.calc_mult_bias`
  # `denom` is `sum(J)` for PB and `length(a)` for SB
  msg_f("BIAS = ", format(b), " (calculated)\n")
  bk.e$actual_bias <- b  # package `bk.e` environment assignment
  apply_f(s, b)  # `apply_f` is either `bk.apply_add_bias` or `bk.apply_mult_bias`
}


# Binding benchmarks validation functions according to (main function) arguments 'tolV' and 'tolP':
#   - bk.binding_bmk_diff_valid   : tolV is specified (check differences against tolV)
#   - bk.binding_bmk_relDiff_valid: tolP is specified (check relative differences against tolP)
bk.binding_bmk_diff_valid <- function(a, theta_lowFreq, c_a, bmk_start, bmk_end, tol, ...) {
  discr <- abs(theta_lowFreq - a) * (c_a == 0)
  prob_id <- which(discr > tol)
  if (length(prob_id) > 0) {
    warning("The following binding benchmarks were not met (tolerance = ", format(tol), "):",
            paste0("\n  [", bmk_start[prob_id], ", ", bmk_end[prob_id], "]: difference = ",
                   format(discr[prob_id]), collapse = ""),
            "\n", call. = FALSE, immediate. = TRUE)
    bk.e$warning_flag <- TRUE
  }
  invisible(NULL)
}
bk.binding_bmk_relDiff_valid <- function(a, theta_lowFreq, c_a, bmk_start, bmk_end, tol, zero_tol = gs.tolerance) {
  a[abs(a) <= zero_tol] <- NA
  discr <- abs(theta_lowFreq / a - 1) * 100 * (c_a == 0)
  tol <- tol * 100
  prob_id <- which(discr > tol)
  if (length(prob_id) > 0) {
    warning("The following binding benchmarks were not met (tolerance = ", format(tol), "%):",
            paste0("\n  [", bmk_start[prob_id], ", ", bmk_end[prob_id], "]: relative difference = ",
                   format(discr[prob_id]), "%", collapse = ""),
            "\n", call. = FALSE, immediate. = TRUE)
    bk.e$warning_flag <- TRUE
  }
  invisible(NULL)
}


# By-group initialization functions:
#   - bk.noByGrp_ini: argument 'by' (main function) is empty
#   - bk.byGrp_ini  : otherwise
# => They return nothing
bk.noByGrp_ini <- function(series_df, benchmarks_df, ...) {
  bk.e$ser_df_byGrp <- series_df[order(series_df$year, series_df$period), ]
  bk.e$bmk_df_byGrp <- benchmarks_df[order(benchmarks_df$startYear, benchmarks_df$startPeriod,
                                           benchmarks_df$endYear, benchmarks_df$endPeriod), ]
  invisible(NULL)
}
bk.byGrp_ini <- function(series_df, benchmarks_df, by_grps, ii, by) {
  subset <- by_grps[ii, by, drop = FALSE]
  bk.e$ser_df_byGrp <- merge(subset, series_df, by = by)
  bk.e$ser_df_byGrp <- bk.e$ser_df_byGrp[order(bk.e$ser_df_byGrp$year, bk.e$ser_df_byGrp$period), ]
  bk.e$bmk_df_byGrp <- merge(subset, benchmarks_df, by = by)
  bk.e$bmk_df_byGrp <- bk.e$bmk_df_byGrp[order(bk.e$bmk_df_byGrp$startYear, bk.e$bmk_df_byGrp$startPeriod,
                                               bk.e$bmk_df_byGrp$endYear, bk.e$bmk_df_byGrp$endPeriod), ]
  invisible(NULL)
}


# Negative input data validation functions
# => return `TRUE` if the situation corresponds to an "error" and return `FALSE` otherwise
bk.check_neg_err <- function(x, tol = gs.tolerance, data_str = "input data") {
  if (gs.check_neg(x, tol = tol)) {

    # Negative values are NOT allowed and some were found (this is an "error")
    TRUE

  } else {

    # Negative values not found (this is NOT an "error")
    FALSE
  }
}
bk.check_neg_warn <- function(x, tol = gs.tolerance, data_str = "input data") {
  if (gs.check_neg(x, tol = tol)) {
    warning("Negative values found in the ", data_str, ". Suspicious use of proportional benchmarking.\n",
            call. = FALSE, immediate. = TRUE)
    bk.e$warning_flag <- TRUE
  }

  # Negative values are allowed (whether negative values are found or not, this is NOT an "error")
  FALSE
}
