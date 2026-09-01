# Reciprocal function of [`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md)

Convert a (non-stacked) time series data frame
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
and
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
data format) into a "ts" (or "mts") object.

This function is useful to convert the benchmarked data frame returned
by a call to
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
or
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
into a "ts" object, where one or several series were benchmarked in *non
BY-group* processing mode. Stacked time series data frames associated to
executions in *BY-group* mode must first be *unstacked* with
[`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/unstack_tsDF.md).

## Usage

``` r
tsDF_to_ts(
  ts_df,
  frequency,
  yr_cName = "year",
  per_cName = "period"
)
```

## Arguments

- ts_df:

  (mandatory)

  Data frame (object of class "data.frame") to be converted.

- frequency:

  (mandatory)

  Integer specifying the frequency of the time series to be converted.
  The frequency of a time series corresponds to the maximum number of
  periods in a year (12 for a monthly data, 4 for a quarterly data, 1
  for annual data).

- yr_cName, per_cName:

  (optional)

  Strings specifying the name of the numeric variables (columns) in the
  input data frame that contain the data point year and period
  identifiers.

  **Default values** are `yr_cName = "year"` and `per_cName = "period"`.

## Value

The function returns a time series object (class "ts" or "mts"), which
can be explicitly coerced to another type of object with the appropriate
`as*()` function (e.g., `tsibble::as_tsibble()` would coerce it to a
tsibble).

## See also

[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md)
[`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/unstack_tsDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)

## Examples

``` r
# Initial quarterly time series (indicator series to be benchmarked)
qtr_ts <- ts(
  c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
  start = c(2015, 1), frequency = 4
)

# Annual time series (benchmarks)
ann_ts <- ts(c(10.3, 10.2), start = 2015, frequency = 1)


# Proportional benchmarking
out_bench <- benchmarking(
  ts_to_tsDF(qtr_ts),
  ts_to_bmkDF(ann_ts, ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE
)

# Initial and final (benchmarked) quarterly time series ("ts" objects)
qtr_ts
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2015  1.9  2.4  3.1  2.2
#> 2016  2.0  2.6  3.4  2.4
#> 2017  2.3               
tsDF_to_ts(out_bench$series, frequency = 4)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2015 2.049326 2.601344 3.337638 2.311691
#> 2016 2.021090 2.554801 3.292193 2.331915
#> 2017 2.268017                           


# Proportional end-of-year stock benchmarking - multiple (3) series processed 
# with argument `by` (in BY-group mode)
qtr_mts <- ts.union(ser1 = qtr_ts,     ser2 = qtr_ts * 100, ser3 = qtr_ts * 10)
ann_mts <- ts.union(ser1 = ann_ts / 4, ser2 = ann_ts * 25,  ser3 = ann_ts * 2.5)
out_bench2 <- stock_benchmarking(
  stack_tsDF(ts_to_tsDF(qtr_mts)),
  stack_bmkDF(ts_to_bmkDF(
    ann_mts, ind_frequency = 4,
    discrete_flag = TRUE, alignment = "e")
  ),
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

# Initial and final (benchmarked) quarterly time series ("mts" objects)
qtr_mts
#>         ser1 ser2 ser3
#> 2015 Q1  1.9  190   19
#> 2015 Q2  2.4  240   24
#> 2015 Q3  3.1  310   31
#> 2015 Q4  2.2  220   22
#> 2016 Q1  2.0  200   20
#> 2016 Q2  2.6  260   26
#> 2016 Q3  3.4  340   34
#> 2016 Q4  2.4  240   24
#> 2017 Q1  2.3  230   23
tsDF_to_ts(unstack_tsDF(out_bench2$series), frequency = 4)
#>             ser1     ser2     ser3
#> 2015 Q1 2.172021 217.2021 21.72021
#> 2015 Q2 2.784446 278.4446 27.84446
#> 2015 Q3 3.633922 363.3922 36.33922
#> 2015 Q4 2.575000 257.5000 25.75000
#> 2016 Q1 2.298694 229.8694 22.98694
#> 2016 Q2 2.903718 290.3718 29.03718
#> 2016 Q3 3.685986 368.5986 36.85986
#> 2016 Q4 2.550000 255.0000 25.50000
#> 2017 Q1 2.437793 243.7793 24.37793
```
