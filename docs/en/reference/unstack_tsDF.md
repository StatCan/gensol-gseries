# Reciprocal function of [`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_tsDF.md)

Convert a stacked (tall) multivariate time series data frame
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
and
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
data format) into a non-stacked (wide) multivariate time series data
frame.

This function, combined with
[`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/en/reference/tsDF_to_ts.md),
is useful to convert the benchmarked data frame returned by a call to
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
or
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
back into a "mts" object, where multiple series were benchmarked in
*BY-group* processing mode.

## Usage

``` r
unstack_tsDF(
  ts_df,
  ser_cName = "series",
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value"
)
```

## Arguments

- ts_df:

  (mandatory)

  Data frame (object of class "data.frame") that contains the
  multivariate time series data to be *unstacked*.

- ser_cName:

  (optional)

  String specifying the name of the character variable (column) in the
  input time series data frame that contains the series identifier (the
  time series variable names in the output data frame).

  **Default value** is `ser_cName = "series"`.

- yr_cName, per_cName:

  (optional)

  Strings specifying the name of the numeric variables (columns) in the
  input time series data frame that contain the data point year and
  period identifiers. These variables are *transferred* to the output
  data frame with the same names.

  **Default values** are `yr_cName = "year"` and `per_cName = "period"`.

- val_cName:

  (optional)

  String specifying the name of the numeric variable (column) in the
  input time series data frame that contains the data point values.

  **Default value** is `val_cName = "value"`.

## Value

The function returns a data frame with three or more variables:

- Data point year, type numeric (see argument `yr_cName`)

- Data point period, type numeric (see argument `per_cName`)

- One time series data variable for each distinct value of the input
  data frame variable specified with argument `ser_cName`, type numeric
  (see arguments `ser_cName` and `val_cName`)

Note: the function returns a "data.frame" object than can be explicitly
coerced to another type of object with the appropriate `as*()` function
(e.g.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
would coerce it to a tibble).

## See also

[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_tsDF.md)
[`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/en/reference/tsDF_to_ts.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)

## Examples

``` r
# Proportional benchmarking for multiple (3) quarterly series processed with 
# argument `by` (in BY-group mode)

ind_vec <- c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3)
ind_df <- ts_to_tsDF(
  ts(
    data.frame(
      ser1 = ind_vec,
      ser2 = ind_vec * 100,
      ser3 = ind_vec * 10
    ),
    start = c(2015, 1), frequency = 4
  )
)

bmk_vec <- c(10.3, 10.2)
bmk_df <- ts_to_bmkDF(
  ts(
    data.frame(
      ser1 = bmk_vec,
      ser2 = bmk_vec * 100,
      ser3 = bmk_vec * 10
    ), 
    start = 2015, frequency = 1
  ),
  ind_frequency = 4
)

out_bench <- benchmarking(
  stack_tsDF(ind_df),
  stack_bmkDF(bmk_df),
  rho = 0.729, lambda = 1, biasOption = 3,
  by = "series",
  quiet = TRUE
)
#> 
#> Benchmarking by-group 1 (series=ser1)
#> =====================================
#> 
#> Benchmarking by-group 2 (series=ser2)
#> =====================================
#> 
#> Benchmarking by-group 3 (series=ser3)
#> =====================================

# Initial and final (benchmarked) quarterly time series data frames
ind_df
#>   year period ser1 ser2 ser3
#> 1 2015      1  1.9  190   19
#> 2 2015      2  2.4  240   24
#> 3 2015      3  3.1  310   31
#> 4 2015      4  2.2  220   22
#> 5 2016      1  2.0  200   20
#> 6 2016      2  2.6  260   26
#> 7 2016      3  3.4  340   34
#> 8 2016      4  2.4  240   24
#> 9 2017      1  2.3  230   23
unstack_tsDF(out_bench$series)
#>   year period     ser1     ser2     ser3
#> 1 2015      1 2.049326 204.9326 20.49326
#> 2 2015      2 2.601344 260.1344 26.01344
#> 3 2015      3 3.337638 333.7638 33.37638
#> 4 2015      4 2.311691 231.1691 23.11691
#> 5 2016      1 2.021090 202.1090 20.21090
#> 6 2016      2 2.554801 255.4801 25.54801
#> 7 2016      3 3.292193 329.2193 32.92193
#> 8 2016      4 2.331915 233.1915 23.31915
#> 9 2017      1 2.268017 226.8017 22.68017
```
