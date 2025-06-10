#' Reciprocal function of [ts_to_tsDF()]
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/tsDF_to_ts.html}})}
#' 
#' Convert a (non-stacked) time series data frame ([benchmarking()] and [stock_benchmarking()] data format)
#' into a "ts" (or "mts") object.
#'
#' This function is useful to convert the benchmarked data frame returned by a call to [benchmarking()] or 
#' [stock_benchmarking()] into a "ts" object, where one or several series were benchmarked in *non BY-group*
#' processing mode. Stacked time series data frames associated to executions in *BY-group* mode must first be
#' *unstacked* with [unstack_tsDF()].
#'
#'
#' @usage
#' tsDF_to_ts(
#'   ts_df,
#'   frequency,
#'   yr_cName = "year",
#'   per_cName = "period"
#' )
#'
#'
#' @param ts_df (mandatory)
#'
#' Data frame (object of class "data.frame") to be converted.
#'
#' @param frequency (mandatory)
#' 
#' Integer specifying the frequency of the time series to be converted. The frequency of a time series corresponds
#' to the maximum number of periods in a year (12 for a monthly data, 4 for a quarterly data, 1 for annual data).
#'
#' @param yr_cName,per_cName (optional)
#'
#' Strings specifying the name of the numeric variables (columns) in the input data frame that contain the data
#' point year and period identifiers.
#'
#' **Default values** are `yr_cName = "year"` and `per_cName   = "period"`.
#'
#'
#' @returns
#' The function returns a time series object (class "ts" or "mts"), which can be explicitly coerced to another type 
#' of object with the appropriate `as*()` function (e.g., `tsibble::as_tsibble()` would coerce it to a tsibble).
#'
#'
#' @seealso [ts_to_tsDF()] [unstack_tsDF()] [benchmarking()] [stock_benchmarking()]
#'
#'
#' @example misc/function_examples/tsDF_to_ts-ex.R
#'
#'
#' @export
tsDF_to_ts <- function(ts_df,
                       frequency,
                       yr_cName = "year",
                       per_cName = "period") {

  # validate object
  if (!is.data.frame(ts_df)) {
    stop("Argument 'ts_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  if (nrow(ts_df) == 0) {
    stop("The input data frame must contain at leat one observation (row).\n\n", call. = FALSE)
  }  
  df_cols <- names(ts_df)
  date_cols <- c(yr_cName, per_cName)
  date_args <- c("yr_cName", "per_cName")
  for (ii in seq_along(date_cols)) {
    if (!(date_cols[ii] %in% df_cols)) {
      stop("The input data frame does not contain column \"", date_cols[ii], "\" (argument '",
           date_args[ii], "').\n\n", call. = FALSE)
    }
  }

  # Sort the data frame by date (safety measure)
  sorted_df <- ts_df[order(ts_df[[yr_cName]], ts_df[[per_cName]]), ]

  # Extract the numeric columns (excluding the year and period id columns)
  if (length(df_cols) > 2) {
    tmp_df <- sorted_df[setdiff(df_cols, date_cols)]
    # `sapply()` is safe: it always returns a logical vector of length minimum 1
    series_obj <- tmp_df[sapply(tmp_df, is.numeric)]
    nTS <- ncol(series_obj)
  } else {
    nTS <- 0
  }
  if (nTS == 0) {
    stop("The input data frame must contain at leat one (numeric) time series.\n\n", call. = FALSE)
  } else if (nTS == 1) {
    # Univariate ts object: transform the data frame into a vector
    series_obj <- series_obj[[1]]
  }

  # Create the ts object
  stats::ts(series_obj,
            start = as.integer(c(sorted_df[1, yr_cName], sorted_df[1, per_cName])),
            frequency = as.integer(frequency))
}
