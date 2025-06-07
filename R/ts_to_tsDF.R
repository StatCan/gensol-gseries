#' Convert a "ts" object to a time series data frame
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française:
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.html}})}
#'
#' Convert a "ts" (or "mts") object into a time series data frame for the benchmarking functions with three or more
#' variables (columns):
#' * two (2) for the data point identification (year and period)
#' * one (1) for each time series
#'
#'
#' @usage
#' ts_to_tsDF(
#'   in_ts,
#'   yr_cName = "year",
#'   per_cName = "period",
#'   val_cName = "value"
#' )
#'
#'
#' @param in_ts (mandatory)
#'
#' Time series ("ts" or "mts"), or object to be coerced to one, to be converted.
#'
#' @param yr_cName,per_cName (optional)
#'
#' Strings specifying the name of the numeric variables (columns) in the output data frame that will contain
#' the data point year and period identifiers.
#'
#' **Default values** are `yr_cName = "year"` and `per_cName   = "period"`.
#'
#' @param val_cName (optional)
#'
#' String specifying the name of the numeric variable (column) in the output data frame that will contain the
#' data point value. This argument has no effect for "mts" objects (time series data variable names are
#' automatically inherited from the "mts" object).
#'
#' **Default value** is `val_cName = "value"`.
#'
#'
#' @returns
#' The function returns a data frame with three or more variables:
#' * Data point year, type numeric (see argument `startYr_cName`)
#' * Data point period, type numeric (see argument `startPer_cName`)
#' * One ("ts" object) or many ("mts" object) time series data variable(s), type numeric (see argument `val_cName`)
#'
#' Note: the function returns a "data.frame" object than can be explicitly coerced to another type of object
#' with the appropriate `as*()` function (e.g., `tibble::as_tibble()` would coerce it to a tibble).
#'
#'
#' @seealso [tsDF_to_ts()] [ts_to_bmkDF()] [stack_tsDF()] [benchmarking()] [stock_benchmarking()] [time_values_conv]
#'
#'
#' @example misc/function_examples/ts_to_tsDF-ex.R
#'
#'
#' @export
ts_to_tsDF <- function(in_ts,
                       yr_cName = "year",
                       per_cName = "period",
                       val_cName = "value") {
  # validate object
  in_ts <- stats::as.ts(in_ts)

  if (stats::is.mts(in_ts)) {
    # Create the initial data frame with only the date columns (first 2 columns)
    out_df <- data.frame(
      col1 = gs.time2year(in_ts),
      col2 = gs.time2per(in_ts)
    )

    # Set date the column names
    names(out_df) <- cbind(yr_cName, per_cName)

    # Add the series data
    out_df <- cbind(out_df, in_ts)
  } else {
    # Create the initial data frame with generic column names
    out_df <- data.frame(
      col1 = gs.time2year(in_ts),
      col2 = gs.time2per(in_ts),
      col3 = as.numeric(in_ts)
    )

    # Set the column names
    names(out_df) <- c(yr_cName, per_cName, val_cName)
  }

  # Reset the now names (numbers)
  row.names(out_df) <- NULL

  out_df
}
