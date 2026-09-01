# Build reconciliation processing groups

This function builds the processing groups data frame for reconciliation
problems. It is used internally by
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
and
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md).

## Usage

``` r
gs.build_proc_grps(
  ts_yr_vec,
  ts_per_vec,
  n_per,
  ts_freq,
  temporal_grp_periodicity,
  temporal_grp_start
)
```

## Arguments

- ts_yr_vec:

  (mandatory)

  Vector of the time series year (time unit) values (see
  [`gs.time2year()`](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)).

- ts_per_vec:

  (mandatory)

  Vector of the time series period (cycle) values (see
  [`gs.time2per()`](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)).

- n_per:

  (mandatory)

  Time series length (number of periods).

- ts_freq:

  (mandatory)

  Time series frequency (see
  [`stats::frequency()`](https://rdrr.io/r/stats/time.html)).

- temporal_grp_periodicity:

  (mandatory)

  Number of periods in temporal groups.

- temporal_grp_start:

  (mandatory)

  First period of temporal groups.

## Value

A data frame with the following variables (columns):

- `grp` : integer vector identifying the processing group
  (`1:<number-of-groups>`).

- `beg_per` : integer vector identifying the first period of the
  processing group.

- `end_per` : integer vector identifying the last period of the
  processing group.

- `complete_grp`: logical vector indicating if the processing group
  corresponds to a complete temporal group.

## Processing groups

The set of periods of a given reconciliation (raking or balancing)
problem is called a *processing group* and either corresponds to:

- a **single period** with period-by-period processing or, when
  preserving temporal totals, for the individual periods of an
  incomplete temporal group (e.g., an incomplete year)

- or the **set of periods of a complete temporal group** (e.g., a
  complete year) when preserving temporal totals.

The total number of processing groups (total number of reconciliation
problems) depends on the set of periods in the input time series object
(argument `in_ts`) and on the value of arguments
`temporal_grp_periodicity` and `temporal_grp_start`.

Common scenarios include `temporal_grp_periodicity = 1` (default) for
period-by period processing without temporal total preservation and
`temporal_grp_periodicity = frequency(in_ts)` for the preservation of
annual totals (calendar years by default). Argument `temporal_grp_start`
allows the specification of other types of (*non-calendar*) years. E.g.,
fiscal years starting on April correspond to `temporal_grp_start = 4`
with monthly data and `temporal_grp_start = 2` with quarterly data.
Preserving quarterly totals with monthly data would correspond to
`temporal_grp_periodicity = 3`.

By default, temporal groups covering more than a year (i.e.,
corresponding to `temporal_grp_periodicity > frequency(in_ts)` start on
a year that is a multiple of
` ceiling(temporal_grp_periodicity / frequency(in_ts))`. E.g., biennial
groups corresponding to
`temporal_grp_periodicity = 2 * frequency(in_ts)` start on an *even
year* by default. This behaviour can be changed with argument
`temporal_grp_start`. E.g., the preservation of biennial totals starting
on an *odd year* instead of an *even year* (default) corresponds to
`temporal_grp_start = frequency(in_ts) + 1` (along with
`temporal_grp_periodicity = 2 * frequency(in_ts)`).

See the `gs.build_proc_grps()` **Examples** for common processing group
scenarios.

## See also

[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
[time_values_conv](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)

## Examples

``` r
#######
# Preliminary setup

# Dummy monthly and quarterly time series (2.5 years long)
mth_ts <- ts(rep(NA, 30), start = c(2019, 1), frequency = 12)
mth_ts
#>      Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#> 2019  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#> 2020  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#> 2021  NA  NA  NA  NA  NA  NA                        
qtr_ts <- ts(rep(NA, 10), start = c(2019, 1), frequency = 4)
qtr_ts
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2019   NA   NA   NA   NA
#> 2020   NA   NA   NA   NA
#> 2021   NA   NA          

# Summarized time series info
ts_info <- function(ts, sep = "-") {
  list(
    y = gs.time2year(ts),     # years
    p = gs.time2per(ts),      # periods
    n = length(ts),           # length
    f = frequency(ts),        # frequency
    l = gs.time2str(ts, sep)  # labels
  )
}
mth_info <- ts_info(mth_ts)
qtr_info <- ts_info(qtr_ts, sep = "q")

# Function to add a description label for the processing group
add_desc <- function(grp_df, lab_vec, word) {
  grp_df$description <- ifelse(
    grp_df$complete_grp,
    paste0(
      "--- ", grp_df$end_per - grp_df$beg_per + 1, " ", word, "s: ",
      lab_vec[grp_df$beg_per], " to ", lab_vec[grp_df$end_per], " --- "
    ),
    paste0("--- 1 ", word, ": ", lab_vec[grp_df$beg_per], " ---")
  )
  
  grp_df
}




#######
# Common processing group scenarios for monthly data


# 0- Month-by-month processing (every single month is a processing group)
mth_grps0 <- gs.build_proc_grps(
  mth_info$y, mth_info$p, mth_info$n, mth_info$f,
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1
)
tmp <- add_desc(mth_grps0, mth_info$l, "month")
head(tmp)
#>   grp beg_per end_per complete_grp             description
#> 1   1       1       1        FALSE --- 1 month: 2019-1 ---
#> 2   2       2       2        FALSE --- 1 month: 2019-2 ---
#> 3   3       3       3        FALSE --- 1 month: 2019-3 ---
#> 4   4       4       4        FALSE --- 1 month: 2019-4 ---
#> 5   5       5       5        FALSE --- 1 month: 2019-5 ---
#> 6   6       6       6        FALSE --- 1 month: 2019-6 ---
tail(tmp)
#>    grp beg_per end_per complete_grp             description
#> 25  25      25      25        FALSE --- 1 month: 2021-1 ---
#> 26  26      26      26        FALSE --- 1 month: 2021-2 ---
#> 27  27      27      27        FALSE --- 1 month: 2021-3 ---
#> 28  28      28      28        FALSE --- 1 month: 2021-4 ---
#> 29  29      29      29        FALSE --- 1 month: 2021-5 ---
#> 30  30      30      30        FALSE --- 1 month: 2021-6 ---


# Temporal groups corresponding to ...

# 1- calendar years
mth_grps1 <- gs.build_proc_grps(
  mth_info$y, mth_info$p, mth_info$n, mth_info$f,
  temporal_grp_periodicity = 12,
  temporal_grp_start = 1
)
add_desc(mth_grps1, mth_info$l, "month")
#>   grp beg_per end_per complete_grp                           description
#> 1   1       1      12         TRUE --- 12 months: 2019-1 to 2019-12 --- 
#> 2   2      13      24         TRUE --- 12 months: 2020-1 to 2020-12 --- 
#> 3   3      25      25        FALSE               --- 1 month: 2021-1 ---
#> 4   4      26      26        FALSE               --- 1 month: 2021-2 ---
#> 5   5      27      27        FALSE               --- 1 month: 2021-3 ---
#> 6   6      28      28        FALSE               --- 1 month: 2021-4 ---
#> 7   7      29      29        FALSE               --- 1 month: 2021-5 ---
#> 8   8      30      30        FALSE               --- 1 month: 2021-6 ---

# 2- fiscal years starting on April
mth_grps2 <- gs.build_proc_grps(
  mth_info$y, mth_info$p, mth_info$n, mth_info$f,
  temporal_grp_periodicity = 12,
  temporal_grp_start = 4
)
add_desc(mth_grps2, mth_info$l, "month")
#>   grp beg_per end_per complete_grp                          description
#> 1   1       1       1        FALSE              --- 1 month: 2019-1 ---
#> 2   2       2       2        FALSE              --- 1 month: 2019-2 ---
#> 3   3       3       3        FALSE              --- 1 month: 2019-3 ---
#> 4   4       4      15         TRUE --- 12 months: 2019-4 to 2020-3 --- 
#> 5   5      16      27         TRUE --- 12 months: 2020-4 to 2021-3 --- 
#> 6   6      28      28        FALSE              --- 1 month: 2021-4 ---
#> 7   7      29      29        FALSE              --- 1 month: 2021-5 ---
#> 8   8      30      30        FALSE              --- 1 month: 2021-6 ---

# 3- regular quarters (starting on Jan, Apr, Jul and Oct)
mth_grps3 <- gs.build_proc_grps(
  mth_info$y, mth_info$p, mth_info$n, mth_info$f,
  temporal_grp_periodicity = 3,
  temporal_grp_start = 1
)
add_desc(mth_grps3, mth_info$l, "month")
#>    grp beg_per end_per complete_grp                           description
#> 1    1       1       3         TRUE   --- 3 months: 2019-1 to 2019-3 --- 
#> 2    2       4       6         TRUE   --- 3 months: 2019-4 to 2019-6 --- 
#> 3    3       7       9         TRUE   --- 3 months: 2019-7 to 2019-9 --- 
#> 4    4      10      12         TRUE --- 3 months: 2019-10 to 2019-12 --- 
#> 5    5      13      15         TRUE   --- 3 months: 2020-1 to 2020-3 --- 
#> 6    6      16      18         TRUE   --- 3 months: 2020-4 to 2020-6 --- 
#> 7    7      19      21         TRUE   --- 3 months: 2020-7 to 2020-9 --- 
#> 8    8      22      24         TRUE --- 3 months: 2020-10 to 2020-12 --- 
#> 9    9      25      27         TRUE   --- 3 months: 2021-1 to 2021-3 --- 
#> 10  10      28      30         TRUE   --- 3 months: 2021-4 to 2021-6 --- 

# 4- quarters shifted by one month (starting on Feb, May, Aug and Nov)
mth_grps4 <- gs.build_proc_grps(
  mth_info$y, mth_info$p, mth_info$n, mth_info$f,
  temporal_grp_periodicity = 3,
  temporal_grp_start = 2
)
add_desc(mth_grps4, mth_info$l, "month")
#>    grp beg_per end_per complete_grp                          description
#> 1    1       1       1        FALSE              --- 1 month: 2019-1 ---
#> 2    2       2       4         TRUE  --- 3 months: 2019-2 to 2019-4 --- 
#> 3    3       5       7         TRUE  --- 3 months: 2019-5 to 2019-7 --- 
#> 4    4       8      10         TRUE --- 3 months: 2019-8 to 2019-10 --- 
#> 5    5      11      13         TRUE --- 3 months: 2019-11 to 2020-1 --- 
#> 6    6      14      16         TRUE  --- 3 months: 2020-2 to 2020-4 --- 
#> 7    7      17      19         TRUE  --- 3 months: 2020-5 to 2020-7 --- 
#> 8    8      20      22         TRUE --- 3 months: 2020-8 to 2020-10 --- 
#> 9    9      23      25         TRUE --- 3 months: 2020-11 to 2021-1 --- 
#> 10  10      26      28         TRUE  --- 3 months: 2021-2 to 2021-4 --- 
#> 11  11      29      29        FALSE              --- 1 month: 2021-5 ---
#> 12  12      30      30        FALSE              --- 1 month: 2021-6 ---




#######
# Common processing group scenarios for quarterly data


# 0- Quarter-by-quarter processing (every single quarter is a processing group)
qtr_grps0 <- gs.build_proc_grps(
  qtr_info$y, qtr_info$p, qtr_info$n, qtr_info$f,
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1
)
add_desc(qtr_grps0, qtr_info$l, "quarter")
#>    grp beg_per end_per complete_grp               description
#> 1    1       1       1        FALSE --- 1 quarter: 2019q1 ---
#> 2    2       2       2        FALSE --- 1 quarter: 2019q2 ---
#> 3    3       3       3        FALSE --- 1 quarter: 2019q3 ---
#> 4    4       4       4        FALSE --- 1 quarter: 2019q4 ---
#> 5    5       5       5        FALSE --- 1 quarter: 2020q1 ---
#> 6    6       6       6        FALSE --- 1 quarter: 2020q2 ---
#> 7    7       7       7        FALSE --- 1 quarter: 2020q3 ---
#> 8    8       8       8        FALSE --- 1 quarter: 2020q4 ---
#> 9    9       9       9        FALSE --- 1 quarter: 2021q1 ---
#> 10  10      10      10        FALSE --- 1 quarter: 2021q2 ---


# Temporal groups corresponding to ...

# 1- calendar years
qtr_grps1 <- gs.build_proc_grps(
  qtr_info$y, qtr_info$p, qtr_info$n, qtr_info$f,
  temporal_grp_periodicity = 4,
  temporal_grp_start = 1
)
add_desc(qtr_grps1, qtr_info$l, "quarter")
#>   grp beg_per end_per complete_grp                           description
#> 1   1       1       4         TRUE --- 4 quarters: 2019q1 to 2019q4 --- 
#> 2   2       5       8         TRUE --- 4 quarters: 2020q1 to 2020q4 --- 
#> 3   3       9       9        FALSE             --- 1 quarter: 2021q1 ---
#> 4   4      10      10        FALSE             --- 1 quarter: 2021q2 ---

# 2- fiscal years starting on April (2nd quarter)
qtr_grps2 <- gs.build_proc_grps(
  qtr_info$y, qtr_info$p, qtr_info$n, qtr_info$f,
  temporal_grp_periodicity = 4,
  temporal_grp_start = 2
)
add_desc(qtr_grps2, qtr_info$l, "quarter")
#>   grp beg_per end_per complete_grp                           description
#> 1   1       1       1        FALSE             --- 1 quarter: 2019q1 ---
#> 2   2       2       5         TRUE --- 4 quarters: 2019q2 to 2020q1 --- 
#> 3   3       6       9         TRUE --- 4 quarters: 2020q2 to 2021q1 --- 
#> 4   4      10      10        FALSE             --- 1 quarter: 2021q2 ---
```
