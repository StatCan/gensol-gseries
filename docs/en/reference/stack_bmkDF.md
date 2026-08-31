# Stack benchmarks data

Convert a multivariate benchmarks data frame (see
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_bmkDF.md))
for the benchmarking functions
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
and
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md))
into a stacked (tall) data frame with six variables (columns):

- one (1) for the benchmark name (e.g., series name)

- four (4) for the benchmark coverage

- one (1) for the benchmark value

Missing (`NA`) benchmark values are not included in the output stacked
data frame by default. Specify argument `keep_NA = TRUE` in order to
keep them.

This function is useful when intending to use the `by` argument
(*BY-group* processing mode) of the benchmarking functions in order to
benchmark multiple series in a single function call.

## Usage

``` r
stack_bmkDF(
  bmk_df,
  ser_cName = "series",
  startYr_cName = "startYear",
  startPer_cName = "startPeriod",
  endYr_cName = "endYear",
  endPer_cName = "endPeriod",
  val_cName = "value",
  keep_NA = FALSE
)
```

## Arguments

- bmk_df:

  (mandatory)

  Data frame (object of class "data.frame") that contains the
  multivariate benchmarks to be stacked.

- ser_cName:

  (optional)

  String specifying the name of the character variable (column) in the
  output stacked data frame that will contain the benchmark names (name
  of the benchmark variables in the input multivariate benchmarks data
  frame). This variable can then be used as the BY-group variable
  (argument `by`) with the benchmarking functions.

  **Default value** is `ser_cName = "series"`.

- startYr_cName, startPer_cName, endYr_cName, endPer_cName:

  (optional)

  Strings specifying the name of the numeric variables (columns) in the
  input multivariate benchmarks data frame that define the benchmark
  coverage, i.e., the starting and ending year and period (cycle)
  identifiers. These variables are *transferred* to the output stacked
  data frame with the same variable names.

  **Default values** are `startYr_cName = "startYear"`,
  `startPer_cName = "startPeriod"` `endYr_cName = "endYear"` and
  `endPer_cName = "endPeriod"`.

- val_cName:

  (optional)

  String specifying the name of the numeric variable (column) in the
  output stacked data frame that will contain the benchmark values.

  **Default value** is `val_cName = "value"`.

- keep_NA:

  (optional)

  Logical argument specifying whether missing (`NA`) benchmark values in
  the input multivariate benchmarks data frame should be kept in the
  output stacked data frame.

  **Default value** is `keep_NA = FALSE`.

## Value

The function returns a data frame with six variables:

- Benchmark (series) name, type character (see argument `ser_cName`)

- Benchmark coverage starting year, type numeric (see argument
  `startYr_cName`)

- Benchmark coverage starting period, type numeric (see argument
  `startPer_cName`)

- Benchmark coverage ending year, type numeric (see argument
  `endtYr_cName`)

- Benchmark coverage ending period, type numeric (see argument
  `endPer_cName`)

- Benchmark value, type numeric (see argument `val_cName`)

Note: the function returns a "data.frame" object than can be explicitly
coerced to another type of object with the appropriate `as*()` function
(e.g.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
would coerce it to a tibble).

## See also

[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_tsDF.md)
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_bmkDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)

## Examples

``` r
# Create an annual benchmarks data frame for 2 quarterly indicator series 
# (with missing benchmark values for the last 2 years)
my_benchmarks <- ts_to_bmkDF(
  ts(
    data.frame(
      ser1 = c(1:3 *  10, NA, NA), 
      ser2 = c(1:3 * 100, NA, NA)
    ), 
    start = c(2019, 1), frequency = 1
  ),
  ind_frequency = 4
)
my_benchmarks
#>   startYear startPeriod endYear endPeriod ser1 ser2
#> 1      2019           1    2019         4   10  100
#> 2      2020           1    2020         4   20  200
#> 3      2021           1    2021         4   30  300
#> 4      2022           1    2022         4   NA   NA
#> 5      2023           1    2023         4   NA   NA


# Stack the benchmarks ...

# discarding `NA` values in the output stacked data frame (default behavior)
stack_bmkDF(my_benchmarks)
#>   series startYear startPeriod endYear endPeriod value
#> 1   ser1      2019           1    2019         4    10
#> 2   ser1      2020           1    2020         4    20
#> 3   ser1      2021           1    2021         4    30
#> 4   ser2      2019           1    2019         4   100
#> 5   ser2      2020           1    2020         4   200
#> 6   ser2      2021           1    2021         4   300

# keep `NA` values in the output stacked data frame
stack_bmkDF(my_benchmarks, keep_NA = TRUE)
#>    series startYear startPeriod endYear endPeriod value
#> 1    ser1      2019           1    2019         4    10
#> 2    ser1      2020           1    2020         4    20
#> 3    ser1      2021           1    2021         4    30
#> 4    ser1      2022           1    2022         4    NA
#> 5    ser1      2023           1    2023         4    NA
#> 6    ser2      2019           1    2019         4   100
#> 7    ser2      2020           1    2020         4   200
#> 8    ser2      2021           1    2021         4   300
#> 9    ser2      2022           1    2022         4    NA
#> 10   ser2      2023           1    2023         4    NA

# using custom variable (column) names
stack_bmkDF(my_benchmarks, ser_cName = "bmk_name", val_cName = "bmk_val")
#>   bmk_name startYear startPeriod endYear endPeriod bmk_val
#> 1     ser1      2019           1    2019         4      10
#> 2     ser1      2020           1    2020         4      20
#> 3     ser1      2021           1    2021         4      30
#> 4     ser2      2019           1    2019         4     100
#> 5     ser2      2020           1    2020         4     200
#> 6     ser2      2021           1    2021         4     300
```
