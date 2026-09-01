# Convert a "ts" object to a benchmarks data frame

Convert a "ts" (or "mts") object into a benchmarks data frame for the
benchmarking functions with five or more variables (columns):

- four (4) for the benchmark coverage

- one (1) for each benchmark time series

For discrete benchmarks (anchor points covering a single period of the
indicator series, e.g., end of year stocks), specify
`discrete_flag = TRUE` and `alignment = "b"`, `"e"` or `"m"`.

## Usage

``` r
ts_to_bmkDF(
  in_ts,
  ind_frequency,
  discrete_flag = FALSE,
  alignment = "b",
  bmk_interval_start = 1,
  startYr_cName = "startYear",
  startPer_cName = "startPeriod",
  endYr_cName = "endYear",
  endPer_cName = "endPeriod",
  val_cName = "value"
)
```

## Arguments

- in_ts:

  (mandatory)

  Time series (object of class "ts" or "mts") to be converted.

- ind_frequency:

  (mandatory)

  Integer specifying the frequency of the indicator (high frequency)
  series for which the benchmarks (low frequency series) are related to.
  The frequency of a time series corresponds to the maximum number of
  periods in a year (e.g., 12 for a monthly data, 4 for a quarterly
  data, 1 for annual data).

- discrete_flag:

  (optional)

  Logical argument specifying whether the benchmarks correspond to
  discrete values (anchor points covering a single period of the
  indicator series, e.g., end of year stocks) or not.
  `discrete_flag = FALSE` defines non-discrete benchmarks, i.e.,
  benchmarks that cover several periods of the indicator series (e.g.
  annual benchmarks cover 4 quarters or 12 months, quarterly benchmarks
  cover 3 months, etc.).

  **Default value** is `discrete_flag = FALSE`.

- alignment:

  (optional)

  Character identifying the alignment of discrete benchmarks (argument
  `discrete_flag = TRUE`) in the benchmark (low frequency series)
  interval coverage window:

  - `alignment = "b"`: beginning of the benchmark interval window (first
    period)

  - `alignment = "e"`: end of the benchmark interval window (last
    period)

  - `alignment = "m"`: middle of the benchmark interval window (middle
    period)

  This argument has no effect for non-discrete benchmarks
  (`discrete_flag = FALSE`).

  **Default value** is `alignment = "b"`.

- bmk_interval_start:

  (optional)

  Integer in the \[1 .. `ind_frequency`\] interval specifying the period
  (cycle) of the indicator (high frequency) series at which the
  benchmark (low frequency series) interval window starts. E.g., annual
  benchmarks corresponding to fiscal years defined from April to March
  of the following year would be specified with `bmk_interval_start = 4`
  for a monthly indicator series (`ind_frequency = 12`) and
  `bmk_interval_start = 2` for a quarterly indicator series
  (`ind_frequency = 4`).

  **Default value** is `bmk_interval_start = 1`.

- startYr_cName, startPer_cName, endYr_cName, endPer_cName:

  (optional)

  Strings specifying the name of the numeric variables (columns) in the
  output data frame that will define the benchmarks coverage, i.e., the
  starting and ending year and period (cycle) identifiers.

  **Default values** are `startYr_cName = "startYear"`,
  `startPer_cName = "startPeriod"` `endYr_cName = "endYear"` and
  `endPer_cName = "endPeriod"`.

- val_cName:

  (optional)

  String specifying the name of the numeric variable (column) in the
  output data frame that will contain the benchmark values. This
  argument has no effect for "mts" objects (benchmark variable names are
  automatically inherited from the "mts" object).

  **Default value** is `val_cName = "value"`.

## Value

The function returns a data frame with five or more variables:

- Benchmark coverage starting year, type numeric (see argument
  `startYr_cName`)

- Benchmark coverage starting period (cycle), type numeric (see argument
  `startPer_cName`)

- Benchmark coverage ending year, type numeric (see argument
  `endtYr_cName`)

- Benchmark coverage ending period (cycle), type numeric (see argument
  `endPer_cName`)

- One ("ts" object) or many ("mts" object) benchmark data variable(s),
  type numeric (see argument `val_cName`)

Note: the function returns a "data.frame" object than can be explicitly
coerced to another type of object with the appropriate `as*()` function
(e.g.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
would coerce it to a tibble).

## See also

[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md)
[`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_bmkDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
[time_values_conv](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)

## Examples

``` r
# Annual and quarterly time series
my_ann_ts <- ts(1:5 * 100, start = 2019, frequency = 1)
my_ann_ts
#> Time Series:
#> Start = 2019 
#> End = 2023 
#> Frequency = 1 
#> [1] 100 200 300 400 500
my_qtr_ts <- ts(my_ann_ts, frequency = 4)
my_qtr_ts
#>   Qtr1 Qtr2 Qtr3 Qtr4
#> 1  100  200  300  400
#> 2  500               


# Annual benchmarks for a monthly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 12)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           1    2019        12   100
#> 2      2020           1    2020        12   200
#> 3      2021           1    2021        12   300
#> 4      2022           1    2022        12   400
#> 5      2023           1    2023        12   500

# Annual benchmarks for a quarterly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 4)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           1    2019         4   100
#> 2      2020           1    2020         4   200
#> 3      2021           1    2021         4   300
#> 4      2022           1    2022         4   400
#> 5      2023           1    2023         4   500

# Quarterly benchmarks for a monthly indicator series
ts_to_bmkDF(my_qtr_ts, ind_frequency = 12)
#>   startYear startPeriod endYear endPeriod value
#> 1         1           1       1         3   100
#> 2         1           4       1         6   200
#> 3         1           7       1         9   300
#> 4         1          10       1        12   400
#> 5         2           1       2         3   500

# Start of year stocks for a quarterly indicator series
ts_to_bmkDF(
  my_ann_ts, ind_frequency = 4, 
  discrete_flag = TRUE
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           1    2019         1   100
#> 2      2020           1    2020         1   200
#> 3      2021           1    2021         1   300
#> 4      2022           1    2022         1   400
#> 5      2023           1    2023         1   500

# End of quarter stocks for a monthly indicator series
ts_to_bmkDF(
  my_qtr_ts, ind_frequency = 12, 
  discrete_flag = TRUE, alignment = "e"
)
#>   startYear startPeriod endYear endPeriod value
#> 1         1           3       1         3   100
#> 2         1           6       1         6   200
#> 3         1           9       1         9   300
#> 4         1          12       1        12   400
#> 5         2           3       2         3   500

# April to March annual benchmarks for a ...
# ... monthly indicator series
ts_to_bmkDF(
  my_ann_ts, ind_frequency = 12, 
  bmk_interval_start = 4
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           4    2020         3   100
#> 2      2020           4    2021         3   200
#> 3      2021           4    2022         3   300
#> 4      2022           4    2023         3   400
#> 5      2023           4    2024         3   500
# ... quarterly indicator series
ts_to_bmkDF(
  my_ann_ts, ind_frequency = 4, 
  bmk_interval_start = 2
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           2    2020         1   100
#> 2      2020           2    2021         1   200
#> 3      2021           2    2022         1   300
#> 4      2022           2    2023         1   400
#> 5      2023           2    2024         1   500

# End-of-year (April to March) stocks for a ...
# ... monthly indicator series
ts_to_bmkDF(
  my_ann_ts, ind_frequency = 12, 
  discrete_flag = TRUE, alignment = "e", bmk_interval_start = 4
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2020           3    2020         3   100
#> 2      2021           3    2021         3   200
#> 3      2022           3    2022         3   300
#> 4      2023           3    2023         3   400
#> 5      2024           3    2024         3   500
# ... quarterly indicator series
ts_to_bmkDF(
  my_ann_ts, ind_frequency = 4,
  discrete_flag = TRUE, alignment = "e", bmk_interval_start = 2
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2020           1    2020         1   100
#> 2      2021           1    2021         1   200
#> 3      2022           1    2022         1   300
#> 4      2023           1    2023         1   400
#> 5      2024           1    2024         1   500

# Custom name for the benchmark data variable (column)
ts_to_bmkDF(
  my_ann_ts, ind_frequency = 12,
  val_cName = "bmk_val"
)
#>   startYear startPeriod endYear endPeriod bmk_val
#> 1      2019           1    2019        12     100
#> 2      2020           1    2020        12     200
#> 3      2021           1    2021        12     300
#> 4      2022           1    2022        12     400
#> 5      2023           1    2023        12     500

# Multiple time series: argument `val_cName` ignored
# (the "mts" object column names are always used)
ts_to_bmkDF(
  ts.union(ser1 = my_ann_ts, ser2 = my_ann_ts / 10), ind_frequency = 12,
  val_cName = "useless_column_name"
)
#>   startYear startPeriod endYear endPeriod ser1 ser2
#> 1      2019           1    2019        12  100   10
#> 2      2020           1    2020        12  200   20
#> 3      2021           1    2021        12  300   30
#> 4      2022           1    2022        12  400   40
#> 5      2023           1    2023        12  500   50
```
