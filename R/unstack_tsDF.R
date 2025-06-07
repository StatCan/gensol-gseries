#' Reciprocal function of [stack_tsDF()]
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française:
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/unstack_tsDF.html}})}
#'
#' Convert a stacked (tall) multivariate time series data frame ([benchmarking()] and [stock_benchmarking()]
#' data format) into a non-stacked (wide) multivariate time series data frame.
#'
#' This function, combined with [tsDF_to_ts()], is useful to convert the benchmarked data frame returned by a call to
#' [benchmarking()] or [stock_benchmarking()] back into a "mts" object, where multiple series were benchmarked in
#' *BY-group* processing mode.
#'
#'
#' @param ts_df (mandatory)
#'
#' Data frame, or object to be coerced to one, that contains the multivariate time series data to be *unstacked*.
#'
#' @param ser_cName (optional)
#'
#' String specifying the name of the character variable (column) in the input time series data frame that
#' contains the series identifier (the time series variable names in the output data frame).
#'
#' **Default value** is `ser_cName = "series"`.
#'
#' @param yr_cName,per_cName (optional)
#'
#' Strings specifying the name of the numeric variables (columns) in the input time series data frame that
#' contain the data point year and period identifiers. These variables are *transferred* to the output data
#' frame with the same names.
#'
#' **Default values** are `yr_cName = "year"` and `per_cName   = "period"`.
#'
#' @param val_cName (optional)
#'
#' String specifying the name of the numeric variable (column) in the input time series data frame that
#' contains the data point values.
#'
#' **Default value** is `val_cName = "value"`.
#'
#'
#' @returns
#' The function returns a data frame with three or more variables:
#' * Data point year, type numeric (see argument `yr_cName`)
#' * Data point period, type numeric (see argument `per_cName`)
#' * One time series data variable for each distinct value of the input data frame variable specified with
#' argument `ser_cName`, type numeric (see arguments `ser_cName` and `val_cName`)
#'
#' Note: the function returns a "data.frame" object than can be explicitly coerced to another type of object
#' with the appropriate `as*()` function (e.g., `tibble::as_tibble()` would coerce it to a tibble).
#'
#'
#' @seealso [stack_tsDF()] [tsDF_to_ts()] [benchmarking()] [stock_benchmarking()]
#'
#'
#' @example misc/function_examples/unstack_tsDF-ex.R
#'
#'
#' @export
unstack_tsDF <- function(ts_df,
                         ser_cName = "series",
                         yr_cName = "year",
                         per_cName = "period",
                         val_cName = "value") {
  # Validate object
  ts_df <- as.data.frame(ts_df)
  df_cols <- names(ts_df)
  cols <- c(ser_cName, yr_cName, per_cName, val_cName)
  args <- c("ser_cName", "yr_cName", "per_cName", "val_cName")
  for (ii in seq_along(cols)) {
    if (!(cols[ii] %in% df_cols)) {
      stop("The input data frame does not contain column \"", cols[ii], "\" (argument '", args[ii],
        "').\n\n",
        call. = FALSE
      )
    }
  }

  # Unstack the data frame
  ser_list <- unique(ts_df[[ser_cName]])
  date_cols <- c(yr_cName, per_cName)
  out_df <- unique(ts_df[date_cols])
  for (ser in ser_list) {
    tmp_df <- ts_df[ts_df[ser_cName] == ser, c(date_cols, val_cName)]
    names(tmp_df)[3] <- ser
    out_df <- merge(out_df, tmp_df, by = date_cols, all = TRUE)
  }

  # Sort the data frame by date and reset the row names (numbers)
  out_df <- out_df[order(out_df[[yr_cName]], out_df[[per_cName]]), ]
  row.names(out_df) <- NULL

  out_df
}
