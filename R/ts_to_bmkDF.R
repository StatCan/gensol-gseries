#' Convert a "ts" object to a benchmarks data frame
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_bmkDF.html}})}
#' 
#' Convert a "ts" (or "mts") object into a benchmarks data frame for the benchmarking functions with five or more variables
#' (columns):
#' * four (4) for the benchmark coverage
#' * one (1) for each benchmark time series
#'
#' For discrete benchmarks (anchor points covering a single period of the indicator series, e.g., end of year
#' stocks), specify `discrete_flag = TRUE` and `alignment = "b"`, `"e"` or `"m"`.
#'
#'
#' @param in_ts (mandatory)
#'
#' Time series ("ts" or "mts"), or object to be coerced to one, to be converted.
#'
#' @param ind_frequency (mandatory)
#'
#' Integer specifying the frequency of the indicator (high frequency) series for which the benchmarks (low
#' frequency series) are related to. The frequency of a time series corresponds to the maximum number of periods
#' in a year (e.g., 12 for a monthly data, 4 for a quarterly data, 1 for annual data).
#'
#' @param discrete_flag (optional)
#'
#' Logical argument specifying whether the benchmarks correspond to discrete values (anchor points covering a single
#' period of the indicator series, e.g., end of year stocks) or not. `discrete_flag = FALSE` defines non-discrete
#' benchmarks, i.e., benchmarks that cover several periods of the indicator series (e.g. annual benchmarks cover
#' 4 quarters or 12 months, quarterly benchmarks cover 3 months, etc.).
#'
#' **Default value** is `discrete_flag = FALSE`.
#'
#' @param alignment (optional)
#'
#' Character identifying the alignment of discrete benchmarks (argument `discrete_flag = TRUE`) in the benchmark
#' (low frequency series) interval coverage window:
#' * `alignment = "b"`: beginning of the benchmark interval window (first period)
#' * `alignment = "e"`: end of the benchmark interval window (last period)
#' * `alignment = "m"`: middle of the benchmark interval window (middle period)
#'
#' This argument has no effect for non-discrete benchmarks (`discrete_flag = FALSE`).
#'
#' **Default value** is `alignment = "b"`.
#'
#' @param bmk_interval_start (optional)
#'
#' Integer in the \[1 .. `ind_frequency`\] interval specifying the period (cycle) of the indicator (high frequency) 
#' series at which the benchmark (low frequency series) interval window starts. E.g., annual benchmarks corresponding to 
#' fiscal years defined from April to March of the following year would be specified with `bmk_interval_start = 4` 
#' for a monthly indicator series (`ind_frequency = 12`) and `bmk_interval_start = 2` for a quarterly indicator 
#' series (`ind_frequency = 4`).
#'
#' **Default value** is `bmk_interval_start = 1`.
#'
#' @param startYr_cName,startPer_cName,endYr_cName,endPer_cName (optional)
#'
#' Strings specifying the name of the numeric variables (columns) in the output data frame that will define the
#' benchmarks coverage, i.e., the starting and ending year and period (cycle) identifiers.
#'
#' **Default values** are `startYr_cName = "startYear"`, `startPer_cName = "startPeriod"`
#' `endYr_cName = "endYear"` and `endPer_cName   = "endPeriod"`.
#'
#' @param val_cName (optional)
#'
#' String specifying the name of the numeric variable (column) in the output data frame that will contain the
#' benchmark values. This argument has no effect for "mts" objects (benchmark variable names are automatically
#' inherited from the "mts" object).
#'
#' **Default value** is `val_cName = "value"`.
#'
#'
#' @returns
#' The function returns a data frame with five or more variables:
#' * Benchmark coverage starting year, type numeric (see argument `startYr_cName`)
#' * Benchmark coverage starting period (cycle), type numeric (see argument `startPer_cName`)
#' * Benchmark coverage ending year, type numeric (see argument `endtYr_cName`)
#' * Benchmark coverage ending period (cycle), type numeric (see argument `endPer_cName`)
#' * One ("ts" object) or many ("mts" object) benchmark data variable(s), type numeric (see argument `val_cName`)
#'
#' Note: the function returns a "data.frame" object than can be explicitly coerced to another type of object 
#' with the appropriate `as*()` function (e.g., `tibble::as_tibble()` would coerce it to a tibble).
#'
#'
#' @seealso [ts_to_tsDF()] [stack_bmkDF()] [benchmarking()] [stock_benchmarking()] [time_values_conv]
#'
#'
#' @example misc/function_examples/ts_to_bmkDF-ex.R
#'
#'
#' @export
ts_to_bmkDF <- function(in_ts,
                        ind_frequency,
                        discrete_flag = FALSE,
                        alignment = "b",
                        bmk_interval_start = 1,
                        startYr_cName = "startYear",
                        startPer_cName = "startPeriod",
                        endYr_cName = "endYear",
                        endPer_cName = "endPeriod",
                        val_cName = "value") {

  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt))
  options(error = NULL)
  
  
  # validate object
  if (!stats::is.ts(in_ts)) {
    stop("Argument 'in_ts' is not a 'ts' object.\n\n", call. = FALSE)
  }
  in_ts <- stats::as.ts(in_ts)


  # (Re)align the `in_ts` time values at the start of the benchmark interval (to ensure proper year and indicator period 
  # determination) and then shift them to reflect `bmk_interval_start`
  #
  # => Note that since the `in-ts` frequency corresponds to the benchmark series (and not the indicator series), function 
  #    `gs.time2per()` (`stats::cycle()`) cannot be used to determine the periods of the indicator series.
  #    Function 'gs.time2year()` could be used to determine the years of the indicator series, but it's not necessary since
  #    the time values are (re)aligned at the start of the intervals (simply "truncating" the time values works fine)
  #
  bmk_freq <- stats::frequency(in_ts)
  beg_time <- stats::time(stats::ts(in_ts,
                                    start = c(gs.time2year(in_ts)[1], gs.time2per(in_ts)[1]),
                                    frequency = stats::frequency(in_ts))) +
    ((bmk_interval_start - 1) %% (ind_frequency / bmk_freq)) / ind_frequency


  # Create the initial data frame with generic names for the benchmark window columns
  # (first 4 columns)

  # Non-discrete benchmarks (e.g. flow series benchmarking)
  if (!gs.validate_arg_logi(discrete_flag)) {

    end_time <- beg_time + (ind_frequency / bmk_freq - 1) / ind_frequency
    out_df <- data.frame(
      col1 = as.integer(signif(beg_time, gs.signif_digits)),
      col2 = as.integer(round((beg_time - as.integer(beg_time)) * ind_frequency)) + 1L,
      col3 = as.integer(signif(end_time, gs.signif_digits)),
      col4 = as.integer(round((end_time - as.integer(end_time)) * ind_frequency)) + 1L
    )

  # Discrete benchmarks (e.g. stock series benchmarking)
  } else {

    tmp <- toupper(substr(alignment, 1, 1))
    if (tmp == "E") {
      shift <- (ind_frequency / bmk_freq - 1) / ind_frequency
    } else if (tmp == "M") {
      # An obvious formula (based on the above one) would probably be `round((ind_frequency / bmk_freq - 1) / 2) / ind_frequency`.
      # However, `base::round()` implements 'go to the even digit' for rounding off a 5 (0.5 -> 0, 1.5 = 2.5 -> 2, etc.) while we
      # want them (half intervals) always rounded up (half years are closer to July 1st than June 1st, i.e., a shift of 6 months).
      # For example, we want...
      #   - monthly indicators with annual benchmarks     : shift = round((12 / 1 - 1) / 2) / 12 = round(5.5) / 12 = 6 / 12 = 0.5)
      #                                                     (base::round(5.5) = 6 -> all good)
      #   - monthly indicators with semi-annual benchmarks: shift = round((12 / 2 - 1) / 2) / 12 = round(2.5) / 12 = 3 / 12 = 0.25)
      #                                                     (base::round(2.5) = 2 -> not what we want!)
      # The following formula corresponds to always rounding up value `(ind_frequency / bmk_freq - 1) / 2`
      shift <- as.integer(ind_frequency / bmk_freq / 2) / ind_frequency
    } else {
      shift <- 0
    }
    time <- beg_time + shift
    yr <- as.integer(signif(time, gs.signif_digits))
    per <- as.integer(round((time - as.integer(time)) * ind_frequency)) + 1L
    out_df <- data.frame(
      col1 = yr,
      col2 = per,
      col3 = yr,
      col4 = per
    )
  }

  # Set the date column names
  names(out_df) <- c(startYr_cName, startPer_cName, endYr_cName, endPer_cName)


  # Multivariate series data columns for a mts object
  if (stats::is.mts(in_ts)) {
    out_df <- cbind(out_df, in_ts)

  # Single series data column for a ts object
  } else {
    temp_df <- data.frame(col1 = as.numeric(in_ts))
    names(temp_df) <- val_cName[1]
    out_df <- cbind(out_df, temp_df)
  }

  # Reset the now names (numbers)
  row.names(out_df) <- NULL

  out_df
}
