# Stack time series data

Convert a multivariate time series data frame (see
[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md))
for the benchmarking functions
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
and
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md))
into a stacked (tall) data frame with four variables (columns):

- one (1) for the series name

- two (2) for the data point identification (year and period)

- one (1) for the data point value

Missing (`NA`) series values are not included in the output stacked data
frame by default. Specify argument `keep_NA = TRUE` in order to keep
them.

This function is useful when intending to use the `by` argument
(*BY-group* processing mode) of the benchmarking functions in order to
benchmark multiple series in a single function call.

## Usage

``` r
stack_tsDF(
  ts_df,
  ser_cName = "series",
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value",
  keep_NA = FALSE
)
```

## Arguments

- ts_df:

  (mandatory)

  Data frame (object of class "data.frame") that contains the
  multivariate time series data to be stacked.

- ser_cName:

  (optional)

  String specifying the name of the character variable (column) in the
  output stacked data frame that will contain the series names (name of
  the time series variables in the input multivariate time series data
  frame). This variable can then be used as the BY-group variable
  (argument `by`) with the benchmarking functions.

  **Default value** is `ser_cName = "series"`.

- yr_cName, per_cName:

  (optional)

  Strings specifying the name of the numeric variables (columns) in the
  input multivariate time series data frame that contain the data point
  year and period (cycle) identifiers. These variables are *transferred*
  to the output stacked data frame with the same variable names.

  **Default values** are `yr_cName = "year"` and `per_cName = "period"`.

- val_cName:

  (optional)

  String specifying the name of the numeric variable (column) in the
  output stacked data frame that will contain the data point values.

  **Default value** is `val_cName = "value"`.

- keep_NA:

  (optional)

  Logical argument specifying whether `NA` time series values in the
  input multivariate time series data frame should be kept in the output
  stacked data frame.

  **Default value** is `keep_NA = FALSE`.

## Value

The function returns a data frame with four variables:

- Series name, type character (see argument `ser_cName`)

- Data point year, type numeric (see argument `yr_cName`)

- Data point period, type numeric (see argument `per_cName`)

- Data point value, type numeric (see argument `val_cName`)

Note: the function returns a "data.frame" object than can be explicitly
coerced to another type of object with the appropriate `as*()` function
(e.g.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
would coerce it to a tibble).

## See also

[`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/unstack_tsDF.md)
[`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_bmkDF.md)
[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)

## Examples

``` r
# Create a data frame with 2 quarterly indicators series
# (with missing values for the last 2 quarters)
my_indicators <- ts_to_tsDF(
  ts(
    data.frame(
      ser1 = c(1:5 *  10, NA, NA),
      ser2 = c(1:5 * 100, NA, NA)
    ), 
    start = c(2019, 1), frequency = 4
  )
)
my_indicators
#>   year period ser1 ser2
#> 1 2019      1   10  100
#> 2 2019      2   20  200
#> 3 2019      3   30  300
#> 4 2019      4   40  400
#> 5 2020      1   50  500
#> 6 2020      2   NA   NA
#> 7 2020      3   NA   NA


# Stack the indicator series ...

# discarding `NA` values in the output stacked data frame (default behavior)
stack_tsDF(my_indicators)
#>    series year period value
#> 1    ser1 2019      1    10
#> 2    ser1 2019      2    20
#> 3    ser1 2019      3    30
#> 4    ser1 2019      4    40
#> 5    ser1 2020      1    50
#> 6    ser2 2019      1   100
#> 7    ser2 2019      2   200
#> 8    ser2 2019      3   300
#> 9    ser2 2019      4   400
#> 10   ser2 2020      1   500

# keeping `NA` values in the output stacked data frame
stack_tsDF(my_indicators, keep_NA = TRUE)
#>    series year period value
#> 1    ser1 2019      1    10
#> 2    ser1 2019      2    20
#> 3    ser1 2019      3    30
#> 4    ser1 2019      4    40
#> 5    ser1 2020      1    50
#> 6    ser1 2020      2    NA
#> 7    ser1 2020      3    NA
#> 8    ser2 2019      1   100
#> 9    ser2 2019      2   200
#> 10   ser2 2019      3   300
#> 11   ser2 2019      4   400
#> 12   ser2 2020      1   500
#> 13   ser2 2020      2    NA
#> 14   ser2 2020      3    NA

# using custom variable (column) names
stack_tsDF(my_indicators, ser_cName = "ser_name", val_cName = "ser_val")
#>    ser_name year period ser_val
#> 1      ser1 2019      1      10
#> 2      ser1 2019      2      20
#> 3      ser1 2019      3      30
#> 4      ser1 2019      4      40
#> 5      ser1 2020      1      50
#> 6      ser2 2019      1     100
#> 7      ser2 2019      2     200
#> 8      ser2 2019      3     300
#> 9      ser2 2019      4     400
#> 10     ser2 2020      1     500
```
