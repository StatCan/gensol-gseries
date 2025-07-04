% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ts_to_tsDF.R
\name{ts_to_tsDF}
\alias{ts_to_tsDF}
\title{Convert a "ts" object to a time series data frame}
\usage{
ts_to_tsDF(
  in_ts,
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value"
)
}
\arguments{
\item{in_ts}{(mandatory)

Time series (object of class "ts" or "mts") to be converted.}

\item{yr_cName, per_cName}{(optional)

Strings specifying the name of the numeric variables (columns) in the output data frame that will contain
the data point year and period identifiers.

\strong{Default values} are \code{yr_cName = "year"} and \code{per_cName   = "period"}.}

\item{val_cName}{(optional)

String specifying the name of the numeric variable (column) in the output data frame that will contain the
data point value. This argument has no effect for "mts" objects (time series data variable names are
automatically inherited from the "mts" object).

\strong{Default value} is \code{val_cName = "value"}.}
}
\value{
The function returns a data frame with three or more variables:
\itemize{
\item Data point year, type numeric (see argument \code{startYr_cName})
\item Data point period, type numeric (see argument \code{startPer_cName})
\item One ("ts" object) or many ("mts" object) time series data variable(s), type numeric (see argument \code{val_cName})
}

Note: the function returns a "data.frame" object than can be explicitly coerced to another type of object
with the appropriate \verb{as*()} function (e.g., \code{tibble::as_tibble()} would coerce it to a tibble).
}
\description{
\if{html,text}{(\emph{version française: 
\url{https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.html}})}

Convert a "ts" (or "mts") object into a time series data frame for the benchmarking functions with three or more
variables (columns):
\itemize{
\item two (2) for the data point identification (year and period)
\item one (1) for each time series
}
}
\examples{
# Quarterly time series
my_ts <- ts(1:10 * 100, start = 2019, frequency = 4)
my_ts


# With the default variable (column) names
ts_to_tsDF(my_ts)

# Using a custom name for the time series data variable (column)
ts_to_tsDF(my_ts, val_cName = "ser_val")


# Multiple time series: argument `val_cName` ignored
# (the "mts" object column names are always used)
ts_to_tsDF(ts.union(ser1 = my_ts,
                    ser2 = my_ts / 10),
            val_cName = "useless_column_name")
}
\seealso{
\code{\link[=tsDF_to_ts]{tsDF_to_ts()}} \code{\link[=ts_to_bmkDF]{ts_to_bmkDF()}} \code{\link[=stack_tsDF]{stack_tsDF()}} \code{\link[=benchmarking]{benchmarking()}} \code{\link[=stock_benchmarking]{stock_benchmarking()}} \link{time_values_conv}
}
