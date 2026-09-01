# Convert a "ts" object to a time series data frame

Convert a "ts" (or "mts") object into a time series data frame for the
benchmarking functions with three or more variables (columns):

- two (2) for the data point identification (year and period)

- one (1) for each time series

## Usage

``` r
ts_to_tsDF(
  in_ts,
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value"
)
```

## Arguments

- in_ts:

  (mandatory)

  Time series (object of class "ts" or "mts") to be converted.

- yr_cName, per_cName:

  (optional)

  Strings specifying the name of the numeric variables (columns) in the
  output data frame that will contain the data point year and period
  identifiers.

  **Default values** are `yr_cName = "year"` and `per_cName = "period"`.

- val_cName:

  (optional)

  String specifying the name of the numeric variable (column) in the
  output data frame that will contain the data point value. This
  argument has no effect for "mts" objects (time series data variable
  names are automatically inherited from the "mts" object).

  **Default value** is `val_cName = "value"`.

## Value

The function returns a data frame with three or more variables:

- Data point year, type numeric (see argument `startYr_cName`)

- Data point period, type numeric (see argument `startPer_cName`)

- One ("ts" object) or many ("mts" object) time series data variable(s),
  type numeric (see argument `val_cName`)

Note: the function returns a "data.frame" object than can be explicitly
coerced to another type of object with the appropriate `as*()` function
(e.g.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
would coerce it to a tibble).

## See also

[`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/en/reference/tsDF_to_ts.md)
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_bmkDF.md)
[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_tsDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
[time_values_conv](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)

## Examples

``` r
# Quarterly time series
my_ts <- ts(1:10 * 100, start = 2019, frequency = 4)
my_ts
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2019  100  200  300  400
#> 2020  500  600  700  800
#> 2021  900 1000          


# With the default variable (column) names
ts_to_tsDF(my_ts)
#>    year period value
#> 1  2019      1   100
#> 2  2019      2   200
#> 3  2019      3   300
#> 4  2019      4   400
#> 5  2020      1   500
#> 6  2020      2   600
#> 7  2020      3   700
#> 8  2020      4   800
#> 9  2021      1   900
#> 10 2021      2  1000

# Using a custom name for the time series data variable (column)
ts_to_tsDF(my_ts, val_cName = "ser_val")
#>    year period ser_val
#> 1  2019      1     100
#> 2  2019      2     200
#> 3  2019      3     300
#> 4  2019      4     400
#> 5  2020      1     500
#> 6  2020      2     600
#> 7  2020      3     700
#> 8  2020      4     800
#> 9  2021      1     900
#> 10 2021      2    1000


# Multiple time series: argument `val_cName` ignored
# (the "mts" object column names are always used)
ts_to_tsDF(
  ts.union(ser1 = my_ts, ser2 = my_ts / 10),
  val_cName = "useless_column_name"
)
#>    year period ser1 ser2
#> 1  2019      1  100   10
#> 2  2019      2  200   20
#> 3  2019      3  300   30
#> 4  2019      4  400   40
#> 5  2020      1  500   50
#> 6  2020      2  600   60
#> 7  2020      3  700   70
#> 8  2020      4  800   80
#> 9  2021      1  900   90
#> 10 2021      2 1000  100
```
