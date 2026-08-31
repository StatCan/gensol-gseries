# Time values conversion functions

Time values conversion functions used internally by other gseries
functions.

## Usage

``` r
gs.time2year(ts)

gs.time2per(ts)

gs.time2str(ts, sep = "-")
```

## Arguments

- ts:

  (mandatory)

  Time series (object of class "ts" or "mts").

- sep:

  (optional)

  String (character constant) specifying the separator to use between
  the year and period values.

  **Default value** is `sep = "-"`.

## Value

`gs.time2year()` returns an integer vector of the "nearest" year (time
unit) values. This function is the equivalent of
[`stats::cycle()`](https://rdrr.io/r/stats/time.html) for time unit
values.

`gs.time2per()` returns an integer vector of the period (cycle) values
(see [`stats::cycle()`](https://rdrr.io/r/stats/time.html)).

`gs.time2str()` returns a character vector corresponding to
`gs.time2year(ts)` if `stats::frequency(ts) == 1` or `gs.time2year(ts)`
and `gs.time2per(ts)` separated with `sep` otherwise.

## See also

[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md)
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_bmkDF.md)
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.build_proc_grps.md)

## Examples

``` r
# Dummy monthly time series 
mth_ts <- ts(rep(NA, 15), start = c(2019, 1), frequency = 12)
mth_ts
#>      Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#> 2019  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#> 2020  NA  NA  NA                                    
gs.time2year(mth_ts)
#>  [1] 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2020 2020 2020
gs.time2per(mth_ts)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12  1  2  3
gs.time2str(mth_ts)
#>  [1] "2019-1"  "2019-2"  "2019-3"  "2019-4"  "2019-5"  "2019-6"  "2019-7" 
#>  [8] "2019-8"  "2019-9"  "2019-10" "2019-11" "2019-12" "2020-1"  "2020-2" 
#> [15] "2020-3" 
gs.time2str(mth_ts, sep = "m")
#>  [1] "2019m1"  "2019m2"  "2019m3"  "2019m4"  "2019m5"  "2019m6"  "2019m7" 
#>  [8] "2019m8"  "2019m9"  "2019m10" "2019m11" "2019m12" "2020m1"  "2020m2" 
#> [15] "2020m3" 

# Dummy quarterly time series 
qtr_ts <- ts(rep(NA, 5), start = c(2019, 1), frequency = 4)
qtr_ts
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2019   NA   NA   NA   NA
#> 2020   NA               
gs.time2year(qtr_ts)
#> [1] 2019 2019 2019 2019 2020
gs.time2per(qtr_ts)
#> [1] 1 2 3 4 1
gs.time2str(qtr_ts)
#> [1] "2019-1" "2019-2" "2019-3" "2019-4" "2020-1"
gs.time2str(qtr_ts, sep = "q")
#> [1] "2019q1" "2019q2" "2019q3" "2019q4" "2020q1"
```
