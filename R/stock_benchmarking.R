#' Restore temporal constraints for stock series
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.html}})}
#' 
#' Function specifically aimed at benchmarking stock series where the benchmarks are anchor points covering a
#' single period of the indicator series. Benchmarks covering more than one period of the indicator series
#' cannot be used with this function. Function [benchmarking()] should be used instead to benchmark
#' non-stock series (flows).
#'
#' Several stock series can be benchmarked in a single function call.
#'
#' Note that functions [stock_benchmarking()] and [benchmarking()] mainly share the same arguments and
#' return the same type of object. Differences are listed below:
#' * Argument `verbose` is not defined for [stock_benchmarking()].
#' * Extra arguments defined for [stock_benchmarking()]:
#'   * `low_freq_periodicity`
#'   * `n_low_freq_proj`
#'   * `proj_knots_rho_bd`
#' * The list returned by [stock_benchmarking()] contains an extra (fourth) data frame:
#'   * `splineKnots`
#'
#'  See section **Details** for more information on the similarities and differences of functions
#'  [stock_benchmarking()] and [benchmarking()].
#'
#'  *A direct equivalent of [stock_benchmarking()] does not exist in SAS\eqn{^\circledR}{®} G-Series 2.0.*
#'
#'
#' @inheritParams benchmarking
#'
#' @param low_freq_periodicity (optional)
#'
#' Positive integer representing the number of periods defining the *low* (e.g., benchmarks) frequency for adding
#' the extra spline knots (before the first benchmark and after the last benchmark). For example, `low_freq_periodicity = 3`
#' with monthly indicators would define quarterly knots. Annual knots are added when `low_freq_periodicity = NA`.
#'
#' **Default value** is `low_freq_periodicity = NA` (annual knots).
#'
#' @param n_low_freq_proj (optional)
#'
#' Nonnegative integer representing the number of low frequency knots (as defined with argument
#' `low_freq_periodicity`) to add at both ends (before the first benchmark and after the last benchmark)
#' before starting to add *high* (indicator series) frequency knots.
#'
#' **Default value** is `n_low_freq_proj = 1`.
#'
#' @param proj_knots_rho_bd (optional)
#'
#' Bound that applies to the value specified with argument `rho` and determines the type of extra knots to be added at 
#' both ends (before the first benchmark and after the last benchmark). When `rho > proj_knots_rho_bd`, *high* (indicator 
#' series) frequency knots are used right away. Otherwise, when `rho <= proj_knots_rho_bd`, *low* frequency knots (see 
#' arguments `low_freq_periodicity` and `n_low_freq_proj`) are first projected on either side. Note that for quarterly 
#' stocks, the cube of the specified `proj_knots_rho_bd` value is actually used. Therefore, the value for argument 
#' `proj_knots_rho_bd` should correspond to monthly stock indicators; it is internally adjusted for quarterly stocks. 
#' This argument aims at reaching a compromise for the set periods outside (before or after) the provided benchmarks 
#' (anchor points), i.e., Denton-type (straight line) adjustments as `rho` approaches 1 (when `rho > proj_knots_rho_bd`) 
#' and a natural looking (not overly contorted) spline otherwise (when `rho <= proj_knots_rho_bd`). Section **Details** 
#' contains more information on this subject and some illustrative cases are provided in section **Examples**.
#'
#' **Default value** is `proj_knots_rho_bd = 0.995` (\eqn{0.995^3} for quarterly stock indicators).
#'
#'
#' @details
#' ## Comparison with [benchmarking()]
#' With stock series, [benchmarking()] is known to produce breaks in the benchmarking adjustments at
#' periods corresponding to the benchmark stocks (anchor points). [stock_benchmarking()] addresses this issue
#' by working directly on the benchmarking adjustments. Smooth adjustments for stocks are ensured by
#' estimating a *slope=0* cubic spline (a spline that is flat at the end knots) going through knots
#' corresponding to the difference (when argument `lambda = 0.0`) or ratio (otherwise) between the benchmarks
#' (anchor points) and the corresponding indicator series values. These knots are sometimes referred to as
#' *BI* (***B***enchmark-to-***I***ndicator) *differences* or *BI ratios*. Interpolations from the estimated
#' cubic spline then provide the adjustments for the periods between benchmarks.
#'
#' Arguments `rho`, `lambda`, `biasOption`and `bias` play a similar role as in [benchmarking()]. However,
#' note that for [stock_benchmarking()], argument `rho` only affects the results for periods outside of, or
#' around the, first and last benchmarks and `lambda` only takes two values in practice: `lambda = 0.0` for
#' additive adjustments (spline interpolations where the knots are *BI differences*) or `lambda = 1.0` for
#' multiplicative adjustments (spline interpolations where the knots are *BI ratios*). Any nonzero value for
#' `lambda` would return the same result as `lambda = 1.0`. Alterability coefficients also play a similar role
#' as in [benchmarking()] and have the same default values, i.e., \eqn{1.0} for the indicator series
#' (nonbinding values) and \eqn{0.0} for the benchmarks (binding benchmarks). However, similar to argument
#' `lambda`, alterability coefficients in this function only take two values in practice: \eqn{0.0} for binding
#' values or \eqn{1.0} for nonbinding values. Any nonzero alterability coefficient would return the same result
#' as a coefficient of \eqn{1.0}. Another difference with [benchmarking()] is that user-defined
#' alterability coefficients are allowed even when `rho = 1` with [stock_benchmarking()]. Finally, specifying a
#' nonbinding benchmark with [stock_benchmarking()]  is equivalent to ignoring the benchmark entirely, as if the
#' benchmark was not included in the input benchmarks file. Compared to [benchmarking()], this generally
#' translates into nonbinding benchmarks having a larger impact on the resulting benchmarked stocks.
#'
#' ## Solution around the first and last benchmarks (benchmarking *timeliness issue*)
#' A *slope=0* spline is chosen because it conceptually corresponds to the (popular) *Denton benchmarking*
#' approach (`rho = 1`). In order to provide a solution before the first benchmark and after the last benchmark
#' that is similar to [benchmarking()] when `rho < 1`, i.e., adjustments converging to the bias at a speed
#' dictated by argument `rho`, extra knots are added at both ends before estimating the spline. By default, one
#' extra low frequency (as defined with argument `low_freq_periodicity`) knot is added on each side (beginning
#' and end), i.e. one extra knot is added before the first benchmark and after the last benchmark. Then, high
#' (indicator series) frequency knots are added to cover the indicator series span to which is added an extra
#' year worth of high frequency knots. The value of all those extra knots is based on arguments `rho`, `biasOption` 
#' and `bias`. This produces natural looking, smooth adjustments for periods outside of or around the first and last
#' benchmarks that gradually converge to the bias, similarly to [benchmarking()]. The number of extra low
#' frequency knots to be added can be modified with argument `n_low_freq_proj`. Using high frequency knots right
#' away (`n_low_freq_proj = 0`) would produce the same projected adjustments as [benchmarking()]. However,
#' note that this tends to produce an unnatural looking (overly contorted) spline around the first and last 
#' benchmarks that could be substantially revised once the next benchmark is available. Using the default 
#' `n_low_freq_proj = 1` generally works better. However, when `rho` is *close to 1* (see argument `proj_knots_rho_bd`), 
#' high frequency knots are immediately added on each side in order to ensure Denton-type (straight line) projected 
#' adjustments for periods outside of the first and last benchmarks. Finally, a *slope=0* cubic spline is fitted through 
#' the (original and extra) knots. Note that in practice, the *slope=0* spline is actually approximated by 
#' replicating the value of the end knots 100 times within the following period (at a frequency corresponding 
#' to 100 times the indicator series frequency).
#'
#' A *natural spline* at the original end knots (first and last benchmarks) can be approximated by specifying
#' a large value for argument `low_freq_periodicity`. The larger the value of `low_freq_periodicity`, the more
#' the cubic spline at the end knots will behave like a *natural spline* (2<sup>nd</sup> derivative equal to 0
#' at the end knots, i.e., a spline that keeps a constant slope at the end knots as opposed to being flat like
#' a *slope=0* spline).
#'
#' In summary, the projected adjustments are controlled with arguments `rho`, `bias` (and `biasOption`),
#' `n_low_freq_proj`, `proj_knots_rho_bd` and `low_freq_periodicity`:
#' * Default values for these arguments produce [benchmarking()] function-like projected adjustments
#' (reasonably slow convergence to the bias).
#' * Smaller values of `rho` would generate faster convergence to the bias.
#' * Specifying a user-defined bias with argument `bias` when `rho < 1` is another way to influence the shape
#' of the projected adjustments.
#' * Specifying `rho = 1` produce Denton-like projected adjustments (repeated first/last adjustments without
#' convergence to the bias).
#' * Specifying a large value for `low_freq_periodicity` generates projected adjustments that behave more
#' like a natural spline, i.e., adjustments that continue in the same direction at the first/last benchmark.
#' The larger the value of `low_freq_periodicity`, the more the projected adjustments keep on going in the
#' same direction before *turning around*.
#'
#' ## Note on revisions to the benchmarking adjustments
#' [benchmarking()] adjustments would not be revised if all future benchmarks were to fall exactly on the
#' projected ones (based on the bias and value of `rho`) and the bias was fixed. The same could be achieved
#' with [stock_benchmarking()] if *enough* low (e.g., benchmarks) frequency knots were projected. The problem
#' with this approach, however, is that the projected adjustments may not look natural as the spline may
#' oscillate more than desired around the projected knots. This is clearly noticeable as `rho` approaches 1
#' and the spline oscillates around the horizontally aligned projected knots instead of being aligned in a
#' perfectly straight line. The default implementation of the spline around the first and last benchmarks
#' described previously aims at reaching a *best compromise* solution:
#' * a natural looking spline around the end knots avoiding oscillations and excessive contortions;
#' * small revisions to the spline if the next benchmark is close to the projected one when `rho` is *far enough*
#' from 1 (`rho <= proj_knots_rho_bd`);
#' * projected adjustments that are in a straight line (free of oscillations) as `rho` approaches 1 (`rho >
#' proj_knots_rho_bd`).
#' 
#' Subsections *Benchmarking Multiple Series*, *Arguments `constant` and `negInput_option`* and *Treatment 
#' of Missing (`NA`) Values* at the end of the [benchmarking()] **Details** section are also relevant for 
#' [stock_benchmarking()]. Consult them as necessary.
#' 
#' Finally, note that the cubic spline associated to the [stock_benchmarking()] adjustments can be conveniently 
#' plotted with [plot_benchAdj()]. The latter is used in the **Examples** to illustrate some of the topics discussed 
#' above.
#' 
#'
#' @returns
#' The function returns is a list of four data frames:
#' 
#' * `series`: data frame containing the benchmarked data (primary function output). BY-group variables
#' specified with argument `by` would be included in the data frame but not alterability coefficient variables
#' specified with argument `var`.
#' 
#' * `benchmarks`: copy of the input benchmarks data frame (excluding invalid benchmarks when applicable).
#' BY-group variables specified with argument `by` would be included in the data frame but not alterability
#' coefficient variables specified with argument `with`.
#' 
#' * `graphTable`: data frame containing supplementary data useful to produce analytical tables and graphs
#' (see function [plot_graphTable()]). It contains the following variables in addition to the BY-group variables
#' specified with argument `by`:
#'   * `varSeries`: Name of the indicator series variable
#'   * `varBenchmarks`: Name of the benchmark variable
#'   * `altSeries`: Name of the user-defined indicator series alterability coefficients variable
#'   * `altSeriesValue`: Indicator series alterability coefficients
#'   * `altbenchmarks`: Name of the user-defined benchmark alterability coefficients variable
#'   * `altBenchmarksValue`: Benchmark alterability coefficients
#'   * `t`: Indicator series period identifier (1 to \eqn{T})
#'   * `m`: Benchmark coverage periods identifier (1 to \eqn{M})
#'   * `year`: Data point calendar year
#'   * `period`: Data point period (cycle) value (1 to `periodicity`)
#'   * `rho`: Autoregressive parameter \eqn{\rho} (argument `rho`)
#'   * `lambda`: Adjustment model parameter \eqn{\lambda} (argument `lambda`)
#'   * `bias`: Bias adjustment (default, user-defined or estimated bias according to arguments `biasOption` and `bias`)
#'   * `periodicity`: The maximum number of periods in a year (e.g. 4 for a quarterly indicator series)
#'   * `date`: Character string combining the values of variables `year` and `period`
#'   * `subAnnual`: Indicator series values
#'   * `benchmarked`: Benchmarked series values
#'   * `avgBenchmark`: Benchmark values divided by the number of coverage periods
#'   * `avgSubAnnual`: Indicator series values (variable `subAnnual`) averaged over the benchmark coverage period
#'   * `subAnnualCorrected`: Bias corrected indicator series values
#'   * `benchmarkedSubAnnualRatio`: Difference (\eqn{\lambda = 0}) or ratio (\eqn{\lambda \ne 0}{lambda != 0}) of the values 
#'   of variables `benchmarked` and `subAnnual`
#'   * `avgBenchmarkSubAnnualRatio`: Difference (\eqn{\lambda = 0}) or ratio (\eqn{\lambda \ne 0}{lambda != 0}) of the values 
#'   of variables `avgBenchmark` and `avgSubAnnual`
#'   * `growthRateSubAnnual`: Period to period difference (\eqn{\lambda = 0}) or relative difference (\eqn{\lambda \ne 0}{
#'   lambda != 0}) of the indicator series values (variable `subAnnual`)
#'   * `growthRateBenchmarked`: Period to period difference (\eqn{\lambda = 0}) or relative difference (\eqn{\lambda \ne 0}{
#'   lambda != 0}) of the benchmarked series values (variable `benchmarked`)
#'   
#' * `splineKnots`: set of `x` and `y` coordinates (knots) used to estimate the natural cubic spline with
#' function `stats::spline()`. In addition to the original set of knots corresponding to binding benchmarks
#' (anchor points), extra knots are also added at the beginning and end in order to deal with the *benchmarking
#' timeliness issue* and approximate a *slope=0* spline at both ends (see section **Details**). It contains the following 
#' variables in addition to the BY-group variables specified with argument `by`:
#'   * `varSeries`: Name of the indicator series variable
#'   * `varBenchmarks`: Name of the benchmark variable
#'   * `x`: Cubic spline `x` coordinate
#'   * `y`: Cubic spline `y` coordinate
#'   * `extraKnot`: Logical value identifying the extra knots added at the beginning and end
#'   
#'   Rows for which `extraKnot == FALSE` correspond to rows in the `graphTable` output data frame for which 
#'   `m` is not missing (not `NA`), with `x = t` and `y = benchmarkedSubAnnualRatio`.
#'
#' Notes:
#' * The output `benchmarks` data frame always contains the original benchmarks provided in the input
#' benchmarks data frame. Modified nonbinding benchmarks, when applicable, can be recovered (calculated)
#' from the output `series` data frame.
#' * The function returns a `NULL` object if an error occurs before data processing could start. Otherwise,
#' if execution gets far enough so that data processing could start, then an incomplete object would be
#' returned in case of errors (e.g., output `series` data frame with `NA` values for the benchmarked data).
#' * The function returns "data.frame" objects that can be explicitly coerced to other types of objects with 
#' the appropriate `as*()` function (e.g., `tibble::as_tibble()` would coerce any of them to a tibble).
#'
#'
#' @references Statistics Canada (2012). "Chapter 5: Benchmarking Stock". **Theory and Application of Benchmarking
#' (Course code 0436)**. Statistics Canada, Ottawa, Canada.
#'
#'
#' @seealso [benchmarking()] [plot_graphTable()] [bench_graphs] [plot_benchAdj()]
#'
#'
#' @example misc/function_examples/stock_benchmarking-ex.R
#'
#'
#' @export
stock_benchmarking <- function(series_df,
                               benchmarks_df,
                               rho,
                               lambda,
                               biasOption,
                               bias = NA,
                               low_freq_periodicity = NA,
                               n_low_freq_proj = 1,
                               proj_knots_rho_bd = 0.995,
                               tolV = 0.001,
                               tolP = NA,
                               warnNegResult = TRUE,
                               tolN = -0.001,
                               var = "value",
                               with = NULL,
                               by = NULL,
                               constant = 0,
                               negInput_option = 0,
                               allCols = FALSE,
                               quiet = FALSE) {




  ### Internal functions ###


  # NOTE: some internal functions shared with `benchmarking()` are defined in script `aaa_bench_utils.R`
  #       where environment `the` is defined and contains objects that are not (cannot be) passed as arguments
  #       to the shared internal benchmarking functions.


  # Binding benchmarks validation function (proportional benchmarking0)
  check_nonZero_bindingBmk <- function(s_lowFreq, a, c_a, tol = gs.tolerance) {

    # Elementwise comparisons are necessary here (cannot use &&)
    if (any(abs(s_lowFreq) <= tol & (abs(a) * (c_a == 0)) > tol)) {
      warning("The indicator series is zero for a nonzero binding benchmark (anchor point). ",
              "This benchmark cannot be met with proportional benchmarking.\n", call. = FALSE, immediate. = TRUE)
      bk.e$warning_flag <- TRUE
    }
    
    invisible(NULL)
  }




  ### Main function ###

  # Initialize the object to be returned by the function via `on.exit()`
  out_list <- NULL
  on.exit(return(out_list))
  try_error <- FALSE
  try_error_msg <- ""
  bk.e$warning_flag <- FALSE
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  # Validate argument `quiet` and implement the quiet setting
  quiet <- gs.validate_arg_logi(quiet)
  if (quiet) {
    quiet_msg_func <- gs.NULL_func
    quiet_lab <- ""  # won't be displayed anyway
  } else {
    quiet_msg_func <- message
    quiet_lab <- "    quiet                = FALSE (default)"
  }

  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\nstock_benchmarking() function:\n")


  # Initial argument validation

  # Mandatory arguments (without default values)
  ser_df_name <- deparse1(substitute(series_df))
  tmp <- nchar(ser_df_name)
  if (tmp == 0) {
    stop("Argument 'series_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    ser_df_name <- paste0(substr(ser_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", ser_df_name, fixed = TRUE)) {
    ser_df_name <- "<argument 'series_df'>"
  }
  series_df <- series_df
  if (!is.data.frame(series_df)) {
    stop("Argument 'series_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  series_df <- as.data.frame(series_df)
  row.names(series_df) <- NULL
  bmk_df_name <- deparse1(substitute(benchmarks_df))
  tmp <- nchar(bmk_df_name)
  if (tmp == 0) {
    stop("Argument 'benchmarks_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    bmk_df_name <- paste0(substr(bmk_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", bmk_df_name, fixed = TRUE)) {
    bmk_df_name <- "<argument 'benchmarks_df'>"
  }
  benchmarks_df <- benchmarks_df
  if (!is.data.frame(benchmarks_df)) {
    stop("Argument 'benchmarks_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  benchmarks_df <- as.data.frame(benchmarks_df)
  row.names(benchmarks_df) <- NULL
  if (nchar(deparse1(substitute(lambda))) == 0) {
    stop("Argument 'lambda' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  tmp <- (unlist(lambda))[1]
  if (!identical(lambda, tmp) || is.null(tmp) || !is.finite(tmp)) {
    stop("Argument 'lambda' must be a real number.\n\n", call. = FALSE)
  }
  if (nchar(deparse1(substitute(rho))) == 0) {
    stop("Argument 'rho' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  tmp <- (unlist(rho))[1]
  if (!identical(rho, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0 || tmp > 1) {
    stop("Argument 'rho' must be a real number in the [0, 1] interval.\n\n", call. = FALSE)
  }
  if (nchar(deparse1(substitute(biasOption))) == 0) {
    if (rho == 1) {
      # bias is irrelevant for Denton benchmarking (`rho = 1`)
      biasOption <- 1L
    } else {
      stop("Argument 'biasOption' is mandatory (it must be specified).\n\n", call. = FALSE)
    }
  }
  tmp <- (unlist(biasOption))[1]
  if (!identical(biasOption, tmp) || is.null(tmp) || !(tmp %in% 1:3)) {
    stop("Argument 'biasOption' must take value 1, 2 or 3.\n\n", call. = FALSE)
  }
  biasOption <- as.integer(biasOption)

  # Optional arguments (with default values)
  tmp <- (unlist(bias))[1]
  if (is.null(tmp)) {
    bias <- NA_real_
  } else if (!identical(bias, tmp) || !is.finite(tmp) && !is.na(tmp)) {
    stop("Argument 'bias' must either be a real number or NA.\n\n", call. = FALSE)
  }
  tmp <- (unlist(low_freq_periodicity))[1]
  if (is.null(tmp)) {
    low_freq_periodicity <- NA_integer_
  } else {
    if (!identical(low_freq_periodicity, tmp) || !is.finite(tmp) && !is.na(tmp) ||
        is.finite(tmp) && (tmp <= 0 || tmp != as.integer(tmp))) {
      stop("Argument 'n_low_freq_proj' must be a positive integer or NA.\n\n", call. = FALSE)
    }
    low_freq_periodicity <- as.integer(low_freq_periodicity)    
  } 
  tmp <- (unlist(n_low_freq_proj))[1]
  if (!identical(n_low_freq_proj, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0 || tmp != as.integer(tmp)) {
    stop("Argument 'n_low_freq_proj' must be a nonnegative integer.\n\n", call. = FALSE)
  }
  n_low_freq_proj <- as.integer(n_low_freq_proj)
  tmp <- (unlist(proj_knots_rho_bd))[1]
  if (!identical(proj_knots_rho_bd, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0 || tmp > 1) {
    stop("Argument 'proj_knots_rho_bd' must be a real number in the [0, 1] interval.\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolV))[1]
  if (is.null(tmp)) {
    tolV <- NA_real_
  } else if (!identical(tolV, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolV' must be a nonnegative real number or NA.\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolP))[1]
  if (is.null(tmp)) {
    tolP <- NA_real_
  } else if (!identical(tolP, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolP' must be a nonnegative real number or NA.\n\n", call. = FALSE)
  }
  warnNegResult <- gs.validate_arg_logi(warnNegResult)
  tmp <- (unlist(tolN))[1]
  if (!identical(tolN, tmp) || is.null(tmp) || !is.finite(tmp) || tmp >= 0) {
    stop("Argument 'tolN' must be a negative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(constant))[1]
  if (!identical(constant, tmp) || is.null(tmp) || !is.finite(tmp)) {
    stop("Argument 'constant' must be a real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(negInput_option))[1]
  if (!identical(negInput_option, tmp) || is.null(tmp) || !(tmp %in% 0:2)) {
    stop("Argument 'negInput_option' must take value 0, 1 or 2.\n\n", call. = FALSE)
  }
  negInput_option <- as.integer(negInput_option)
  allCols <- gs.validate_arg_logi(allCols)
  # Argument `quiet` was already validated

  # Initialize the final warning/error message flag for multiple series processing
  final_msg_flag <- FALSE
  try_stop_func <- gs.NULL_func

  # Initialize the list of "non-data columns" (date and by-group columns)
  info_cols_serDF <- c("year", "period")
  info_cols_bmkDF <- c("startYear", "startPeriod", "endYear", "endPeriod")

  all_cols_serDF <- names(series_df)
  gs.validate_cols(info_cols_serDF, all_cols_serDF, ser_df_name)
  if (any(!is.finite(as.matrix(series_df[info_cols_serDF])))) {
    stop("Indicator series date columns (\"year\" and \"period\") contain invalid or NA values.\n\n", call. = FALSE)
  }

  all_cols_bmkDF <- names(benchmarks_df)
  gs.validate_cols(info_cols_bmkDF, all_cols_bmkDF, bmk_df_name)
  if (any(!is.finite(as.matrix(benchmarks_df[info_cols_bmkDF])))) {
    stop("Benchmarks date columns (\"startYear\", \"startPeriod\", \"endYear\" and \"endPeriod\") contain invalid or NA values.\n\n",
         call. = FALSE)
  }

  # Initialize the list of "series data columns" from both input files
  data_cols_serDF <- setdiff(all_cols_serDF, info_cols_serDF)
  data_cols_bmkDF <- setdiff(all_cols_bmkDF, info_cols_bmkDF)

  # Validation of argument 'by' ("non-data columns" as well)
  by <- unique(gs.cleanup_col_list(by))
  n_byVars <- length(by)
  if (n_byVars > 0) {
    by_lab <- paste0("    by                   = ", paste(by, collapse = " "))
    gs.validate_cols(by, data_cols_serDF, ser_df_name, source_str = "argument 'by'")
    gs.validate_cols(by, data_cols_bmkDF, bmk_df_name, source_str = "argument 'by'")
    by_grps <- unique(series_df[by])
    n_byGrps <- nrow(by_grps)

    # Build the by-group expression (for message display)
    if (n_byGrps > 0) {
      by_grps$SB._expr_ <- paste0(by[1], "=", by_grps[, by[1]])
      for (ii in seq_along(by)[-1]) {
        by_grps$SB._expr_ <- paste(by_grps$SB._expr_, paste0(by[ii], "=", by_grps[, by[ii]]), sep = " & ")
      }
    }

    # Add the by variables to the list of "non-data columns"
    info_cols_serDF <- c(by, info_cols_serDF)
    info_cols_bmkDF <- c(by, info_cols_bmkDF)

    # Remove by variables from the list of "series data columns"
    data_cols_serDF <- setdiff(data_cols_serDF, by)
    data_cols_bmkDF <- setdiff(data_cols_bmkDF, by)

    # Set message display info
    if (n_byGrps > 1) {
      byGrp_ini_func <- bk.byGrp_ini
      byGrp_msg_func <- message
      final_msg_flag <- TRUE
      try_stop_func <- gs.try_stop
    } else {
      byGrp_ini_func <- bk.noByGrp_ini
      byGrp_msg_func <- gs.NULL_func
    }

  # No by-groups
  } else {
    by <- NULL
    by_lab <- "    by                   = NULL (default)"
    by_grps <- data.frame(SB._expr_ = "")
    n_byGrps <- 1
    byGrp_ini_func <- bk.noByGrp_ini
    byGrp_msg_func <- gs.NULL_func
  }

  # Ignore arguments 'var' and 'with' and process all data columns of the input indicator series
  # data frame, expecting corresponding columns (same names) in the input benchmarks data frame
  if (allCols) {
    var_lab <- "    var                  (ignored)"
    with_lab <- "    with                 (ignored)"
    allCols_lab <- "    allCols              = TRUE"
    var <- data_cols_serDF
    with <- var
    n_vars <- length(var)
    alter_ser <- rep.int("", n_vars)
    default_alter_ser_id <- 1:n_vars
    user_alter_ser_id <- integer(0)  # value returned by which() on an "all FALSE" logical vector
    alter_bmk <- alter_ser
    default_alter_bmk_id <- 1:n_vars
    user_alter_bmk_id <- integer(0)
    gs.validate_cols(with, data_cols_bmkDF, bmk_df_name)

    # Process arguments 'var' and 'with'
  } else {
    allCols_lab <- "    allCols              = FALSE (default)"

    # Validation of argument 'var'
    var <- gs.cleanup_col_list(var)
    var_lab <- paste0("    var                  = ", paste(var, collapse = " "))
    if (var_lab == "    var                  = value") {
      var_lab <- "    var                  = value (default)"
    }
    tmp <- gs.split_str("\\/", var)
    var <- tmp[[1]]
    n_vars <- length(var)
    len <- length(tmp)
    if (len == 2) {
      alter_ser <- tmp[[2]]
      default_alter_ser_id <- which(alter_ser == "")
      user_alter_ser_id <- setdiff(1:n_vars, default_alter_ser_id)
    } else {
      if (len > 2) {
        stop("Invalid specification of alterability coefficients in argument 'var'.\n\n", call. = FALSE)
      }
      alter_ser <- rep.int("", n_vars)
      default_alter_ser_id <- 1:n_vars
      user_alter_ser_id <- integer(0)
    }
    prob_cols <- intersect(var, by)
    if (length(prob_cols) > 0) {
      stop("The following columns are listed with arguments 'var' and 'by' (these arguments are mutually exclusive):",
           paste0("\n  ", prob_cols, collapse = ""), "\n\n", call. = FALSE)
    }
    gs.validate_cols(c(var, alter_ser[user_alter_ser_id]), data_cols_serDF, ser_df_name, source_str = "argument 'var'")

    # Validation of argument 'with'
    with <- gs.cleanup_col_list(with)
    if (length(with) == 0) {
      with_lab <- "    with                 = NULL (default)"
      with <- var
      alter_bmk <- rep.int("", n_vars)
      default_alter_bmk_id <- 1:n_vars
      user_alter_bmk_id <- integer(0)
    } else {
      with_lab <- paste0("    with                 = ", paste(with, collapse = " "))
      tmp <- gs.split_str("\\/", with)
      with <- tmp[[1]]
      len <- length(tmp)
      if (len == 2) {
        alter_bmk <- tmp[[2]]
        default_alter_bmk_id <- which(alter_bmk == "")
        user_alter_bmk_id <- setdiff(1:n_vars, default_alter_bmk_id)
      } else {
        if (len > 2) {
          stop("Invalid specification of alterability coefficients in argument 'with'.", call. = FALSE)
        }
        alter_bmk <- rep.int("", n_vars)
        default_alter_bmk_id <- 1:n_vars
        user_alter_bmk_id <- integer(0)
      }
    }
    prob_cols <- intersect(with, by)
    if (length(prob_cols) > 0) {
      stop("The following columns are listed with arguments 'with' and 'by' (these arguments are mutually exclusive):",
           paste0("\n  ", prob_cols, collapse = ""), "\n\n", call. = FALSE)
    }
    gs.validate_cols(c(with, alter_bmk[user_alter_bmk_id]), data_cols_bmkDF, bmk_df_name, source_str = "argument 'with'")
    if (n_vars != length(with)) {
      stop("Arguments 'var' and 'with' do not contain the same number of elements.\n\n", call. = FALSE)
    }
  }
  if (n_vars == 0) {
    stop("Argument 'var' results in 0 series to be benchmarked.\n\n", call. = FALSE)
  } else if (n_vars == 1) {
    var_msg_func <- gs.NULL_func
  } else {
    var_msg_func <- message
    final_msg_flag <- TRUE
    try_stop_func <- gs.try_stop
  }


  # Shrink the input data frames with only the necessary columns
  series_df <- series_df[unique(c(info_cols_serDF, var, alter_ser[user_alter_ser_id]))]
  benchmarks_df <- benchmarks_df[unique(c(info_cols_bmkDF, with, alter_bmk[user_alter_bmk_id]))]

  # Add the default alter coefs to the input data frames and specify them when relevant
  series_df$SB._default_alter_ <- rep.int(1, nrow(series_df))
  benchmarks_df$SB._default_alter_ <- rep.int(0, nrow(benchmarks_df))
  actual_alter_ser <- alter_ser
  actual_alter_bmk <- alter_bmk
  alter_ser[default_alter_ser_id] <- "SB._default_alter_"
  alter_bmk[default_alter_bmk_id] <- "SB._default_alter_"
  alter_ser_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_bmk_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_ser_check_func_str[user_alter_ser_id] <- "gs.check_alter"
  alter_bmk_check_func_str[user_alter_bmk_id] <- "gs.check_alter"

  # Initialize the output data frames (as NULL objects for now)
  out_series_df <- NULL
  out_benchmarks_df <- NULL
  out_graphTable_df <- NULL
  out_splineKnots_df <- NULL

  # Set parameters and function names according to the benchmarking model (additive benchmarking
  # when 'lambda == 0' and proportional benchmarking otherwise):
  #   - negative values verification functions
  #   - bias calculation and BI (ratios or differences) application
  #   - ratio and growth rate calculation functions
  if (lambda == 0) {
    zeros_verif_func <- gs.NULL_func
    neg_verif_func <- gs.FALSE_func
    default_bias <- 0
    bias_calc_func <- bk.calc_add_bias
    bias_apply_func <- bk.apply_add_bias
    BI_apply_func <- bk.apply_add_bias
    ratio_func <- gs.calc_diff
    growthRate_func <- gs.calc_firstDiff
  } else {
    zeros_verif_func <- check_nonZero_bindingBmk
    if (negInput_option == 0) {
      neg_verif_func <- bk.check_neg_err
    } else if (negInput_option == 1) {
      neg_verif_func <- bk.check_neg_warn
    } else {
      neg_verif_func <- gs.FALSE_func
    }
    default_bias <- 1
    bias_calc_func <- bk.calc_mult_bias
    bias_apply_func <- bk.apply_mult_bias
    BI_apply_func <- bk.apply_mult_bias
    ratio_func <- gs.calc_ratio
    growthRate_func <- gs.calc_relFirstDiff
    if (!is.na(bias) && bias < 0) {
      stop("Argument 'bias' must be positive with proportional benchmarking.\n\n", call. = FALSE)
    }
  }

  # Set the bias option function according to argument 'biasOption'
  if (rho == 1) {
    # The bias has no effect and can be ignored (impose `biasOption = 1` and `bias = NA`)
    biasOption_func <- bk.apply_biasOption1
    biasOption_lab <- "    biasOption           (ignored)"
    bias_parm <- default_bias
    bias_str <- "default"
    bias_lab <- "    bias                 (ignored)"
  } else {
    if (biasOption == 3) {
      biasOption_func <- bk.apply_biasOption3
      biasOption_lab <- "    biasOption           = 3 (Calculate bias, use calculated bias)"
      bias_parm <- NA_real_
      bias_str <- NA_character_
      bias_lab <- "    bias                 (ignored)"
    } else {
      if (biasOption == 1) {
        biasOption_func <- bk.apply_biasOption1
        biasOption_lab <- "    biasOption           = 1 (Use user-defined or default bias)"
      } else if (biasOption == 2) {
        biasOption_func <- bk.apply_biasOption2
        biasOption_lab <- "    biasOption           = 2 (Calculate bias, but use user-defined or default bias)"
      }
      if (is.na(bias)) {
        bias_parm <- default_bias
        bias_str <- "default"
        bias_lab <- "    bias                 = NA (default)"
      } else {
        bias_parm <- bias
        bias_str <- "user-defined"
        bias_lab <- paste0("    bias                 = ", format(bias))
      }
    }
  }
  bk.e$actual_bias <- NULL

  # Minimum required number of periods in the indicator series
  min_nT <- 1

  # Results validation function and binding benchmarks tolerance
  if (warnNegResult) {
    neg_res_func <- gs.check_neg
    warnNegResult_lab <- "    warnNegResult        = TRUE (default)"
  } else {
    neg_res_func <- gs.FALSE_func
    warnNegResult_lab <- "    warnNegResult        = FALSE"
  }
  if (!is.na(tolV)) {
    if (!is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both specified (one must be NA).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_diff_valid
    tol_parm <- tolV
    tol_lab <- paste0("    tolV                 = ", format(tolV))
    if (abs(tolV - 0.001) < gs.tolerance) {
      tol_lab <- paste0(tol_lab, " (default)")
    }
  } else {
    if (is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both NA (one must be specified).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_relDiff_valid
    tol_parm <- tolP
    tol_lab <- paste0("    tolP                 = ", format(tolP))
  }


  # Display the function call (argument values)
  quiet_msg_func("    series_df            = ", ser_df_name)
  quiet_msg_func("    benchmarks_df        = ", bmk_df_name)
  quiet_msg_func("    rho                  = ", format(rho))
  quiet_msg_func("    lambda               = ", format(lambda))
  quiet_msg_func(biasOption_lab)
  quiet_msg_func(bias_lab)
  lab <- paste0("    low_freq_periodicity = ", low_freq_periodicity)
  if (is.na(low_freq_periodicity)) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    n_low_freq_proj      = ", n_low_freq_proj)
  if (n_low_freq_proj == 1) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    proj_knots_rho_bd    = ", format(proj_knots_rho_bd))
  if (abs(proj_knots_rho_bd - 0.995) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(tol_lab)
  quiet_msg_func(warnNegResult_lab)
  lab <- paste0("    tolN                 = ", format(tolN))
  if (abs(tolN - (-0.001)) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(var_lab)
  quiet_msg_func(with_lab)
  quiet_msg_func(by_lab)
  lab <- paste0("    constant             = ", format(constant))
  if (constant == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    negInput_option      = ", format(negInput_option))
  if (negInput_option == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(allCols_lab)
  quiet_msg_func(quiet_lab, "\n")
  
  
  # Return the input series data frames
  if (nrow(series_df) == 0 || nrow(benchmarks_df) == 0) {
    out_series_df <- series_df[intersect(all_cols_serDF, names(series_df))]
    out_benchmarks_df <- benchmarks_df[intersect(all_cols_bmkDF, names(benchmarks_df))]
    
    # Attempt to benchmark the data
  } else {
    
    # Enforce integer period id values
    cols_vec <- setdiff(info_cols_serDF, by)
    series_df[cols_vec] <- as.integer(as.matrix(series_df[cols_vec]))
    cols_vec <- setdiff(info_cols_bmkDF, by)
    benchmarks_df[cols_vec] <- as.integer(as.matrix(benchmarks_df[cols_vec]))
    
    
    # Process each by-group

    on.exit(rlang::env_unbind(bk.e, c("ser_df_byGrp", "bmk_df_byGrp")), add = TRUE)
    for (ii in 1:n_byGrps) {
  
      # By-group initialization/setup
      bk.e$ser_df_byGrp <- NULL
      bk.e$bmk_df_byGrp <- NULL
      byGrp_ini_func(series_df, benchmarks_df, by_grps, ii, by)
  
      msg_str <- paste0("\nBenchmarking by-group ", ii, " (", by_grps$SB._expr_[ii], ")")
      byGrp_msg_func(msg_str)
      byGrp_msg_func(strrep("=", nchar(msg_str) - 1), "\n")
  
      # Reject rows with invalid benchmark data (for any of the benchmarks)
      M_ini <- nrow(bk.e$bmk_df_byGrp)
      if (nrow(bk.e$bmk_df_byGrp) > 1) {
        prob_id <- which(apply(!apply(bk.e$bmk_df_byGrp[with], 2, is.finite), 1, any))
      } else {
        prob_id <- which(any(!apply(bk.e$bmk_df_byGrp[with], 2, is.finite)))
      }
      if (length(prob_id) > 0) {
        warning("Rows from the benchmarks data frame were dropped because of invalid or NA values.\n",
                call. = FALSE, immediate. = TRUE)
        bk.e$warning_flag <- TRUE
        bk.e$bmk_df_byGrp <- bk.e$bmk_df_byGrp[-prob_id, , drop = FALSE]
        M <- nrow(bk.e$bmk_df_byGrp)
      } else {
        M <- M_ini
      }
  
      # Initialize the by-group output data frames
      out_bmk_df_byGrp <- bk.e$bmk_df_byGrp[c(info_cols_bmkDF, with)]
      out_ser_df_byGrp <- bk.e$ser_df_byGrp[c(info_cols_serDF, var)]
      out_ser_df_byGrp[var] <- NA_real_
  
      nT <- nrow(bk.e$ser_df_byGrp)
      if (nT < min_nT) {
        try_error_msg <- paste0("The minimum number of periods (", min_nT, ") for the indicator series ", 
                                "is not met.\n\n")
        try_stop_func(try_error_msg)
        try_error <- TRUE
  
      } else if (M == 0) {
        try_error_msg <- "A minimum of 1 benchmark is required.\n\n"
        try_stop_func(try_error_msg)
        try_error <- TRUE
  
      } else {
  
        # Vectors for periods and benchmarks coverage validation
        periodicity <- max(bk.e$ser_df_byGrp$period)
        if (is.na(low_freq_periodicity)) {
          low_freq_periodicity <- periodicity
        }
        periods <- paste(bk.e$ser_df_byGrp$year, bk.e$ser_df_byGrp$period, sep = "-")
        bmk_start <- paste(bk.e$bmk_df_byGrp$startYear, bk.e$bmk_df_byGrp$startPeriod, sep = "-")
        bmk_end <- paste(bk.e$bmk_df_byGrp$endYear, bk.e$bmk_df_byGrp$endPeriod, sep = "-")
  
        # Validate indicator series periods (period-to-period gap != 1 / periodicity)
        time_val <- bk.e$ser_df_byGrp$year + (bk.e$ser_df_byGrp$period - 1) / periodicity
        if (nT > 1) {
          # `sapply()` is safe: `which()` always returns a "vector" object, even when `nT = 2`
          prob_id <- which(c(FALSE,
                             sapply(2:nT,
                                    function(x) {
                                      abs(time_val[x] - time_val[x - 1] - 1 / periodicity) > gs.tolerance
                                    })))
        } else {
          prob_id <- integer(0)
        }
        if (length(prob_id) > 0) {
          try_error_msg <- paste0("Non-contiguous periods found in the indicator series: ",
                                  paste0("\n  ", periods[prob_id - 1], " - ", periods[prob_id], collapse = ""), 
                                  "\n\n")
          try_stop_func(try_error_msg)
          try_error <- TRUE
  
        } else {
  
          # Validate the benchmark coverage: anchor points (single-period coverage)
          prob_id <- which(bk.e$bmk_df_byGrp$startYear != bk.e$bmk_df_byGrp$endYear |
                           bk.e$bmk_df_byGrp$startPeriod != bk.e$bmk_df_byGrp$endPeriod)
          if (length(prob_id) > 0) {
            try_error_msg <- paste0("Benchmark coverage not compatible with stock benchmarking (not an anchor point): ",
                                    paste0("\n  [", bmk_start[prob_id], ", ", bmk_end[prob_id], "]", 
                                           collapse = ""), 
                                    "\n\n")
            try_stop_func(try_error_msg)
            try_error <- TRUE
  
          } else {
  
            # Build benchmarks to periods mapping vector of dimension M
            # (period id of each "anchor point" benchmark)
            bmk_per_id <- match(bmk_start, periods)
  
            # Validate the benchmark coverage: not inside the set of indicator periods
            prob_id <- which(is.na(bmk_per_id))
            if (length(prob_id) > 0) {
              try_error_msg <- paste0("Benchmark coverage not fully inside the indicator series span: ",
                                      paste0("\n  [", bmk_start[prob_id], ", ", bmk_end[prob_id], "]", 
                                             collapse = ""), 
                                      "\n\n")
              try_stop_func(try_error_msg)
              try_error <- TRUE
  
            } else {
  
              # Display a message about the number of observations in the benchmarks and series data frames
              # Note: all indicator series observations are valid at this point, making the SERIES
              #       message not quite relevant... but that's what SAS G-Series PROC BENCHMARKING displays
              #       (there might be cases where the 2 numbers differ, but I don't see it...)
  
              # Widths without commas
              width_nT <- floor(log10(nT)) + 1
              width_M_ini <- floor(log10(M_ini)) + 1
              width_M <- floor(log10(M)) + 1
  
              # Adjust the widths of the benchmarks info considering the commas (for `format(..., big.mark = ",")`)
              # => add the difference in the number of commas between the series obs. number (`nT`) and each of the 
              #    two (initial and final) benchmarks obs. numbers (`M_ini` and `M`)
              # => it's (reasonably) assumed here that there will always be more observations in the series data 
              #    frame than in the benchmarks data frame (i.e., `nT` >= `M_ini` >= `M`)
              if (width_M_ini < width_nT) {
                width_M_ini <- width_nT + floor((width_nT - 1) / 3) - floor((width_M_ini - 1) / 3)
              }
              if (width_M < width_nT) {
                width_M <- width_nT + floor((width_nT - 1) / 3) - floor((width_M - 1) / 3)
              }
              quiet_msg_func("Number of observations in the BENCHMARKS data frame .............: ",
                             format(M_ini, scientific = FALSE, big.mark = ",", width = width_M_ini, justify = "right"))
              quiet_msg_func("Number of valid observations in the BENCHMARKS data frame .......: ",
                             format(M, scientific = FALSE, big.mark = ",", width = width_M, justify = "right"), "\n")
              quiet_msg_func("Number of observations in the SERIES data frame .................: ",
                             format(nT, scientific = FALSE, big.mark = ",", width = width_nT, justify = "right"))
              quiet_msg_func("Number of valid observations in the SERIES data frame ...........: ",
                             format(nT, scientific = FALSE, big.mark = ",", width = width_nT, justify = "right"), "\n")
  
              # Set K1 for the BY-group...
              #   K1 = the number of low (benchmark) frequency extra knots at the start and end
              if (rho > proj_knots_rho_bd^(12 / periodicity)) {
                K1 <- 0
              } else {
                K1 <- n_low_freq_proj
              }

  
              # Process each series
              for (jj in 1:n_vars) {
  
                msg_str <- paste0("\nBenchmarking indicator series [", var[jj], "] with benchmarks [", with[jj], "]")
                var_msg_func(msg_str)
                var_msg_func(strrep("-", nchar(msg_str) - 1), "\n")
  
                # Series/benchmarks data and alterablity coefficients validation
                if (any(!is.finite(bk.e$ser_df_byGrp[[var[jj]]]))) {
                  warning("The indicator series contains invalid or NA values. It will not be processed.\n", call. = FALSE,
                          immediate. = TRUE)
                  bk.e$warning_flag <- TRUE
  
                } else if (do.call(alter_ser_check_func_str[jj], list(bk.e$ser_df_byGrp[[alter_ser[jj]]]))) {
                  try_error_msg <- "Invalid indicator series alterability coefficients (must be nonnegative numbers).\n\n"
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
  
                } else if (do.call(alter_bmk_check_func_str[jj], list(bk.e$bmk_df_byGrp[[alter_bmk[jj]]]))) {
                  try_error_msg <- "Invalid benchmarks alterability coefficients (must be nonnegative numbers).\n\n"
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
  
                  # Process (benchmark) the series
                } else {
  
                  # Build the elementary vectors and matrices
                  #   => the temporary constant is added here
                  s <- bk.e$ser_df_byGrp[[var[jj]]] + constant
                  c_s <- bk.e$ser_df_byGrp[[alter_ser[jj]]]
                  a <- bk.e$bmk_df_byGrp[[with[jj]]] + constant
                  c_a <- bk.e$bmk_df_byGrp[[alter_bmk[jj]]]
  
                  # Get the indicator series values associated to the benchmarks (anchor points)
                  s_lowFreq <- s[bmk_per_id]
  
                  # Additional series/benchmarks data validation for proportional benchmarking (lambda != 0)
                  #   - nonzero binding benchmarks associated to zero indicator series values (undefined BI value)
                  #   - negative benchmark or indicator series values (according to argument `negInput_option`)
                  zeros_verif_func(s_lowFreq, a, c_a, tol = gs.tolerance)
                  if (neg_verif_func(a, tol = 0, data_str = "benchmarks")) {
                    try_error_msg <- paste0("Negative values found in the benchmarks. This is not permitted for ", 
                                            "proportional benchmarking.\n\n")
                    try_stop_func(try_error_msg)
                    try_error <- TRUE
  
                  } else if (neg_verif_func(s, tol = 0, data_str = "indicator series")) {
                    try_error_msg <- paste0("Negative values found in the indicator series. This is not permitted for ", 
                                            "proportional benchmarking.\n\n")
                    try_stop_func(try_error_msg)
                    try_error <- TRUE
  
                  } else {
  
                    # Bias correction
                    s_b <- biasOption_func(quiet_msg_func,                                 # message function
                                           bias_calc_func, s_lowFreq, a, M, gs.tolerance,  # bias calculation arguments
                                           bias_apply_func, s, bias_parm,                  # bias application arguments
                                           bias_str)
  
  
                    # Calculate the initial set of knots corresponding to binding benchmarks, taking the average value
                    # for duplicated binding benchmarks (spline knot x = t, spline knot y = BI differences or ratios)
                    binding_m <- which(c_a == 0)
                    t_vec <- bmk_per_id[binding_m]
                    if (anyDuplicated(t_vec)) {
                      t_vec <- unique(t_vec)
                      knots_ini <- data.frame(t = t_vec,
                                              BI = ratio_func(as.vector(tapply(a[binding_m], bmk_start[binding_m], mean)),
                                                              s[t_vec]),
                                              extra_knot = FALSE)
                    } else {
                      knots_ini <- data.frame(t  = t_vec,
                                              BI = ratio_func(a[binding_m], s[t_vec]),
                                              extra_knot = FALSE)
                    }
  
                    # Remove missing (`NA`) BI's, i.e. irrelevant spline knots (BI values) corresponding to indicator
                    # values of 0 with proportional benchmarking (0's remain 0's with proportional benchmarking)
                    knots_ini <- knots_ini[!is.na(knots_ini$BI), , drop = FALSE]
                    n_knots_ini <- nrow(knots_ini)
  
                    # Validate the initial set of knots
                    if (n_knots_ini == 0) {
                      quiet_msg_func("Benchmarking is not required for this series (no relevant benchmark remains). ",
                                     "New observations will not be added to the output spline knots data frame.\n")
                      theta <- s
  
                    } else {
  
  
                      # Add extra knots at the start and end (benchmarking timeliness issue)
  
                      # Set K2...
                      #   K2 = the number of high (indicator series) frequency extra knots to add after the
                      #        low (benchmarks) frequency extra knots (K1)
                      #      = the number of periods required to cover the first/last plus 1 year worth of
                      #        high frequency knots
                      K2.beg <- periodicity + max(0, knots_ini$t[1] - K1 * low_freq_periodicity - 1)
                      K2.end <- periodicity + max(0, nT - knots_ini$t[n_knots_ini] - K1 * low_freq_periodicity)
  
                      # Initialize the spline knots with NA for columns "t" and "BI" for the extra knots (for now)
                      # (the 100 extra knots will be used to approximate a "slope=0" spline at both ends)
                      n_extra.beg <- K1 + K2.beg + 100
                      n_extra.end <- K1 + K2.end + 100
                      knots <- rbind(data.frame(t = rep.int(NA_real_, n_extra.beg),
                                                BI = rep.int(NA_real_, n_extra.beg),
                                                extra_knot = rep.int(TRUE, n_extra.beg)),
                                     knots_ini,
                                     data.frame(t = rep.int(NA_real_, n_extra.end),
                                                BI = rep.int(NA_real_, n_extra.end),
                                                extra_knot = rep.int(TRUE, n_extra.end)))
  
                      # K1 low frequency knots
                      kk.beg <- n_extra.beg + 1
                      kk.end <- n_extra.beg + n_knots_ini
                      for (kk in seq_len(K1)) {
                        # ... at the start
                        knots$t[kk.beg - kk] <- knots$t[kk.beg] - kk * low_freq_periodicity
                        knots$BI[kk.beg - kk] <- bk.e$actual_bias + rho^(kk * low_freq_periodicity) *
                          (knots$BI[kk.beg] - bk.e$actual_bias)
                        # ... at the end
                        knots$t[kk.end + kk] <- knots$t[kk.end] + kk * low_freq_periodicity
                        knots$BI[kk.end + kk] <- bk.e$actual_bias + rho^(kk * low_freq_periodicity) *
                          (knots$BI[kk.end] - bk.e$actual_bias)
                      }
  
                      # K2 high frequency knots
                      #... at the start
                      kk.beg <- kk.beg - K1
                      for (kk in seq_len(K2.beg)) {
                        knots$t[kk.beg - kk] <- knots$t[kk.beg - kk + 1] - 1
                        knots$BI[kk.beg - kk] <- bk.e$actual_bias + rho * (knots$BI[kk.beg - kk + 1] - bk.e$actual_bias)
                      }
                      #... at the end
                      kk.end <- kk.end + K1
                      for (kk in seq_len(K2.end)) {
                        knots$t[kk.end + kk] <- knots$t[kk.end + kk - 1] + 1
                        knots$BI[kk.end + kk] <- bk.e$actual_bias + rho * (knots$BI[kk.end + kk - 1] - bk.e$actual_bias)
                      }
  
                      # 100 extra knots for "slope=0" spline approximation
                      kk.beg <- kk.beg - K2.beg
                      kk.end <- kk.end + K2.end
                      for (kk in 1:100) {
                        # ... at the start
                        knots$t[kk.beg - kk] <- knots$t[kk.beg] - kk / 100
                        knots$BI[kk.beg - kk] <- knots$BI[kk.beg]
                        # ... at the end
                        knots$t[kk.end + kk] <- knots$t[kk.end] + kk / 100
                        knots$BI[kk.end + kk] <- knots$BI[kk.end]
                      }
  
                      # Implement the spline interpolations
                      interpol <- stats::spline(knots$t, knots$BI, xout = 1:nT, method = "natural")
                      BI <- interpol$y
  
                      # Benchmark the indicator series by applying the interpolated BI ratios or differences
                      # to the indicator series, taking into account binding indicator values (BI = bias)
                      BI[which(c_s == 0)] <- bk.e$actual_bias
                      theta <- BI_apply_func(s, BI)
  
  
                      # Cumulate the splineKnots output data frame info
                      n_knots <- nrow(knots)
                      out_splineKnots_df <- rbind(out_splineKnots_df,
                                                  cbind((bk.e$ser_df_byGrp[by])[rep.int(1, n_knots), , drop = FALSE],
                                                        data.frame(varSeries = rep.int(var[jj], n_knots),
                                                                   varBenchmarks = rep.int(with[jj], n_knots),
                                                                   x = knots$t,
                                                                   y = knots$BI,
                                                                   extraKnot = knots$extra_knot)))
                    }
                    
                    
                    # Cumulate the graphTable output data frame info
                    #   => the graphTable includes more periods than the indicator series (`n_obs_GT > nT`)
                    #      in the case of duplicate benchmarks (anchor points)
                    
                    # Map benchmark level info (vectors of length `M`) to period level info (vectors of length
                    # `n >= nT`, with `n = nT` for distinct benchmarks and `n > nT` for duplicate benchmarks)
                    #
                    # The resulting `bmk_info` data frame has `n >= nT` observations and 5 variables:
                    #   - `t`: period id
                    #   - `m`: benchmark id (`NA` for periods not associated to any benchmark)
                    #   - `avg_s`: indicator series value  (`NA` for periods not associated to any benchmark)
                    #   - `avg_a`: benchmark value (`NA` for periods not associated to any benchmark)
                    #   - `c_a`: benchmark alter coef (`NA` for periods not associated to any benchmark)
                    bmk_info <- merge(data.frame(t = 1:nT), # period ids
                                      # Benchmark level info
                                      data.frame(t = bmk_per_id, # benchmark (anchor point) period ids
                                                 m = 1:M,
                                                 avg_s = s_lowFreq,
                                                 avg_a = a,
                                                 c_a = c_a),
                                      by = "t", 
                                      all.x = TRUE)

                    # Generate the graphTable data frame info
                    n_obs_GT <- length(bmk_info$t)
                    out_GT_df_var <- data.frame(varSeries = rep.int(var[jj], n_obs_GT),
                                                varBenchmarks = rep.int(with[jj], n_obs_GT),
                                                altSeries = rep.int(actual_alter_ser[jj], n_obs_GT),
                                                altSeriesValue = c_s[bmk_info$t],
                                                altbenchmarks = rep.int(actual_alter_bmk[jj], n_obs_GT),
                                                altBenchmarksValue = bmk_info$c_a,
                                                t = bmk_info$t,
                                                m = bmk_info$m,
                                                year = bk.e$ser_df_byGrp$year[bmk_info$t],
                                                period = bk.e$ser_df_byGrp$period[bmk_info$t],
                                                constant = rep.int(constant, n_obs_GT),
                                                rho = rep.int(rho, n_obs_GT),
                                                lambda = rep.int(lambda, n_obs_GT),
                                                bias = rep.int(bk.e$actual_bias, n_obs_GT),
                                                periodicity = rep.int(periodicity, n_obs_GT),
                                                date = paste(bk.e$ser_df_byGrp$year[bmk_info$t], 
                                                             sprintf("%06d", bk.e$ser_df_byGrp$period[bmk_info$t]), sep = "-"),
                                                subAnnual = s[bmk_info$t],
                                                benchmarked = theta[bmk_info$t],
                                                avgBenchmark = bmk_info$avg_a,
                                                avgSubAnnual = bmk_info$avg_s,
                                                subAnnualCorrected = s_b[bmk_info$t],
                                                benchmarkedSubAnnualRatio = ratio_func(theta[bmk_info$t], s[bmk_info$t]),
                                                avgBenchmarkSubAnnualRatio = ratio_func(bmk_info$avg_a, bmk_info$avg_s),
                                                growthRateSubAnnual = growthRate_func(s)[bmk_info$t],
                                                growthRateBenchmarked = growthRate_func(theta)[bmk_info$t],
                                                stringsAsFactors = FALSE)
  
                    out_graphTable_df <- rbind(out_graphTable_df, cbind(bk.e$ser_df_byGrp[bmk_info$t, by, drop = FALSE],
                                                                        out_GT_df_var))
  
                    # Remove the temporary constant
                    out_ser_df_byGrp[[var[jj]]] <- theta - constant
  
                    # Results validation
                    if (neg_res_func(out_ser_df_byGrp[[var[jj]]], tol = -tolN)) {
                      warning("The benchmarked series contains negative values (threshold = ", format(tolN), ").\n",
                              call. = FALSE, immediate. = TRUE)
                      bk.e$warning_flag <- TRUE
                    }
                    binding_bmk_valid_func(bk.e$bmk_df_byGrp[[with[jj]]], out_ser_df_byGrp[bmk_per_id, var[jj], drop = TRUE], c_a,
                                           bmk_start, bmk_end, tol_parm, zero_tol = 0)
                  }
                }
              }
            }
          }
        }
      }
  
      # Cumulate the output series and benchmarks data frame info
      out_series_df <- rbind(out_series_df, out_ser_df_byGrp)
      out_benchmarks_df <- rbind(out_benchmarks_df, out_bmk_df_byGrp)
    }
  }


  # Create the output list
  row.names(out_series_df) <- NULL
  row.names(out_benchmarks_df) <- NULL
  row.names(out_graphTable_df) <- NULL
  row.names(out_splineKnots_df) <- NULL
  out_list <- list(series = out_series_df, 
                   benchmarks = out_benchmarks_df, 
                   graphTable = out_graphTable_df, 
                   splineKnots = out_splineKnots_df)


  # Display a final warning/error message for multiple series processing
  if (final_msg_flag) {
    if (bk.e$warning_flag) {
      warning("Warnings were generated during processing. See preceeding warning message(s) for details.\n",
              call. = FALSE, immediate. = TRUE)
    }
    # Non-muted error message (for proper condition catching by users of the function)
    if (try_error) {
      stop("Problems were encontered during processing. See preceeding error message(s) for details.\n\n",
           call. = FALSE)
    }

  # Display the error message for single-series processing
  } else if (try_error) {
    stop(try_error_msg, call. = FALSE)
  }

  # Output object returned via function `on.exit()`
}
