# Helper function for [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)

Helper function for the
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
function that conveniently determines the required set of raking
problems to be solved and internally generates the individual calls to
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md).
It is especially useful in the context of temporal total (e.g., annual
total) preservation where each individual raking problem either involves
a single period for incomplete temporal groups (e.g., incomplete years)
or several periods for complete temporal groups (e.g., the set of
periods of a complete year).

## Usage

``` r
tsraking_driver(
  in_ts,
  ...,  # `tsraking()` arguments excluding `data_df`
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1
)
```

## Arguments

- in_ts:

  (mandatory)

  Time series (object of class "ts" or "mts") that contains the time
  series data to be reconciled. They are the raking problems' input data
  (initial solutions).

- ...:

  Arguments passed on to
  [`tsraking`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)

  `metadata_df`

  :   (mandatory)

      Data frame (object of class "data.frame") that describes the
      cross-sectional aggregation constraints (additivity rules) for the
      raking problem. Two character variables must be included in the
      metadata data frame: `series` and `total1`. Two variables are
      optional: `total2` (character) and `alterAnnual` (numeric). The
      values of variable `series` represent the variable names of the
      component series in the input time series data frame (argument
      `data_df`). Similarly, the values of variables `total1` and
      `total2` represent the variable names of the 1^(st) and 2^(nd)
      dimension cross-sectional control totals in the input time series
      data frame. Variable `alterAnnual` contains the alterability
      coefficient for the temporal constraint associated to each
      component series. When specified, the latter will override the
      default alterability coefficient specified with argument
      `alterAnnual`.

  `alterability_df`

  :   (optional)

      Data frame (object of class "data.frame"), or `NULL`, that
      contains the alterability coefficients variables. They must
      correspond to a component series or a cross-sectional control
      total, that is, a variable with the same name must exist in the
      input time series data frame (argument `data_df`). The values of
      these alterability coefficients will override the default
      alterability coefficients specified with arguments `alterSeries`,
      `alterTotal1` and `alterTotal2`. When the input time series data
      frame contains several observations and the alterability
      coefficients data frame contains only one, the alterability
      coefficients are used (repeated) for all observations of the input
      time series data frame. Alternatively, the alterability
      coefficients data frame may contain as many observations as the
      input time series data frame.

      **Default value** is `alterability_df = NULL` (default
      alterability coefficients).

  `alterSeries`

  :   (optional)

      Nonnegative real number specifying the default alterability
      coefficient for the component series values. It will apply to
      component series for which alterability coefficients have not
      already been specified in the alterability coefficients data frame
      (argument `alterability_df`).

      **Default value** is `alterSeries = 1.0` (nonbinding component
      series values).

  `alterTotal1`

  :   (optional)

      Nonnegative real number specifying the default alterability
      coefficient for the 1^(st) dimension cross-sectional control
      totals. It will apply to cross-sectional control totals for which
      alterability coefficients have not already been specified in the
      alterability coefficients data frame (argument `alterability_df`).

      **Default value** is `alterTotal1 = 0.0` (binding 1^(st) dimension
      cross-sectional control totals)

  `alterTotal2`

  :   (optional)

      Nonnegative real number specifying the default alterability
      coefficient for the 2^(nd) dimension cross-sectional control
      totals. It will apply to cross-sectional control totals for which
      alterability coefficients have not already been specified in the
      alterability coefficients data frame (argument `alterability_df`).

      **Default value** is `alterTotal2 = 0.0` (binding 2^(nd) dimension
      cross-sectional control totals).

  `alterAnnual`

  :   (optional)

      Nonnegative real number specifying the default alterability
      coefficient for the component series temporal constraints (e.g.,
      annual totals). It will apply to component series for which
      alterability coefficients have not already been specified in the
      metadata data frame (argument `metadata_df`).

      **Default value** is `alterAnnual = 0.0` (binding temporal control
      totals).

  `tolV,tolP`

  :   (optional)

      Nonnegative real number, or `NA`, specifying the tolerance, in
      absolute value or percentage, to be used when performing the
      ultimate test in the case of binding totals (alterability
      coefficient of \\0.0\\ for temporal or cross-sectional control
      totals). The test compares the input binding control totals with
      the ones calculated from the reconciled (output) component series.
      Arguments `tolV` and `tolP` cannot be both specified together (one
      must be specified while the other must be `NA`).

      **Example:** to set a tolerance of 10 *units*, specify
      `tolV = 10, tolP = NA`; to set a tolerance of 1%, specify
      `tolV = NA, tolP = 0.01`.

      **Default values** are `tolV = 0.001` and `tolP = NA`.

  `warnNegResult`

  :   (optional)

      Logical argument specifying whether a warning message is generated
      when a negative value created by the function in the reconciled
      (output) series is smaller than the threshold specified by
      argument `tolN`.

      **Default value** is `warnNegResult = TRUE`.

  `tolN`

  :   (optional)

      Negative real number specifying the threshold for the
      identification of negative values. A value is considered negative
      when it is smaller than this threshold.

      **Default value** is `tolN = -0.001`.

  `id`

  :   (optional)

      String vector (minimum length of 1), or `NULL`, specifying the
      name of additional variables to be transferred from the input time
      series data frame (argument `data_df`) to the output time series
      data frame, the object returned by the function (see section
      **Value**). By default, the output series data frame only contains
      the variables listed in the metadata data frame (argument
      `metadata_df`).

      **Default value** is `id = NULL`.

  `verbose`

  :   (optional)

      Logical argument specifying whether information on intermediate
      steps with execution time (real time, not CPU time) should be
      displayed. Note that specifying argument `quiet = TRUE` would
      *nullify* argument `verbose`.

      **Default value** is `verbose = FALSE`.

  `Vmat_option`

  :   (optional)

      Specification of the option for the variance matrices (\\V_e\\ and
      \\V\_\epsilon\\; see section **Details**):

      |           |                                                               |
      |-----------|---------------------------------------------------------------|
      | **Value** | **Description**                                               |
      | `1`       | Use vectors \\x\\ and \\g\\ in the variance matrices.         |
      | `2`       | Use vectors \\\|x\|\\ and \\\|g\|\\ in the variance matrices. |

      See Ferland (2016) and subsection **Arguments `Vmat_option` and
      `warnNegInput`** in section **Details** for more information.

      **Default value** is `Vmat_option = 1`.

  `warnNegInput`

  :   (optional)

      Logical argument specifying whether a warning message is generated
      when a negative value smaller than the threshold specified by
      argument `tolN` is found in the input time series data frame
      (argument `data_df`).

      **Default value** is `warnNegInput = TRUE`.

  `quiet`

  :   (optional)

      Logical argument specifying whether or not to display only
      essential information such as warnings and errors. Specifying
      `quiet = TRUE` would also *nullify* argument `verbose` and is
      equivalent to *wrapping* your
      [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
      call with
      [`suppressMessages()`](https://rdrr.io/r/base/message.html).

      **Default value** is `quiet = FALSE`.

- temporal_grp_periodicity:

  (optional)

  Positive integer defining the number of periods in temporal groups for
  which the totals should be preserved. E.g., specify
  `temporal_grp_periodicity = 3` with a monthly time series for
  quarterly total preservation and `temporal_grp_periodicity = 12` (or
  `temporal_grp_periodicity = frequency(in_ts)`) for annual total
  preservation. Specifying `temporal_grp_periodicity = 1` (*default*)
  corresponds to period-by-period processing without temporal total
  preservation.

  **Default value** is `temporal_grp_periodicity = 1` (period-by-period
  processing without temporal total preservation).

- temporal_grp_start:

  (optional)

  Integer in the \[1 .. `temporal_grp_periodicity`\] interval specifying
  the starting period (cycle) for temporal total preservation. E.g.,
  annual totals corresponding to fiscal years defined from April to
  March of the following year would be specified with
  `temporal_grp_start = 4` for a monthly time series
  (`frequency(in_ts) = 12`) and `temporal_grp_start = 2` for a quarterly
  time series (`frequency(in_ts) = 4`). This argument has no effect for
  period-by-period processing without temporal total preservation
  (`temporal_grp_periodicity = 1`).

  **Default value** is `temporal_grp_start = 1`.

## Value

The function returns a time series object (class "ts" or "mts")
containing the reconciled component series, reconciled cross-sectional
control totals and other series specified with
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
argument `id`. It can be explicitly coerced to another type of object
with the appropriate `as*()` function (e.g., `tsibble::as_tsibble()`
would coerce it to a tsibble).

Note that a `NULL` object is returned if an error occurs before data
processing could start. Otherwise, if execution gets far enough so that
data processing could start, then an incomplete object (with `NA`
values) would be returned in case of errors.

## Details

This function solves one raking problem with
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
per processing group (see section **Processing groups** for details).
The mathematical expression of these raking problem can be found in the
**Details** section of the
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
documentation.

The alterability coefficients data frame (argument `alterability_df`)
specified with `tsraking_driver()` can either contain:

- A single observation: the specified coefficients will be used for all
  periods of input time series object (argument `in_ts`).

- A number of observations equal to `frequency(in_ts)`: the specified
  coefficients will be used for the corresponding *cycle* of the input
  time series object (argument `in_ts`) periods. Monthly data example:
  1^(st) observation for January, 2^(nd) observation for February,
  etc.).

- A number of observations equal to `nrow(in_ts)`: the specified
  coefficients will be used for the corresponding periods of the input
  time series object (argument `in_ts`), i.e., 1^(st) observation for
  the 1^(st) period, 2^(nd) observation for the 2^(nd) period, etc.).

Specifying `quiet = TRUE` will suppress the
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
messages (e.g., function header) and only display essential information
such as warnings, errors and the period (or set of periods) being
reconciled. We advise against *wrapping* your `tsraking_driver()`
function call with
[`suppressMessages()`](https://rdrr.io/r/base/message.html) to further
suppress the display of the *raking period(s)* information as this would
make troubleshooting difficult in case of issues with individual raking
problems.

Although
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
could be called with `*apply()` to successively reconcile all the
periods of the input time series (`in_ts`), using `tsraking_driver()`
has a few advantages, namely:

- temporal total preservation (only period-by-period processing, without
  temporal total preservation, would be possible with `*apply()`);

- more flexibility in the specification of user-defined alterability
  coefficients (e.g., period-specific values);

- display of the period being processed (reconciled) in the console,
  which is useful for troubleshooting individual raking problems;

- improved error handling, i.e., better management of warnings or errors
  if they were to occur only for some raking problems (periods);

- readily returns a "ts" ("mts") object.

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

See the
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.build_proc_grps.md)
**Examples** for common processing group scenarios.

## References

Statistics Canada (2018). "Chapter 6: Advanced topics", **Theory and
Application of Reconciliation (Course code 0437)**, Statistics Canada,
Ottawa, Canada.

## See also

[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
[`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/en/reference/rkMeta_to_blSpecs.md)
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.build_proc_grps.md)

## Examples

``` r
# 1-dimensional raking problem where the quarterly sales of cars in the 3 prairie
# provinces (Alb., Sask. and Man.) for 8 quarters, from 2019 Q2 to 2021 Q1, must
# sum up to the total (`cars_tot`).

# Problem metadata
my_metadata <- data.frame(
  series = c("cars_alb", "cars_sask", "cars_man"),
  total1 = rep("cars_tot", 3)
)
my_metadata
#>      series   total1
#> 1  cars_alb cars_tot
#> 2 cars_sask cars_tot
#> 3  cars_man cars_tot

# Problem data
my_series <- ts(
  matrix(
    c(
      14, 18, 14, 58,
      17, 14, 16, 44,
      14, 19, 18, 58,
      20, 18, 12, 53,
      16, 16, 19, 44,
      14, 15, 16, 50,
      19, 20, 14, 52,
      16, 15, 19, 51
    ),
    ncol = 4,
    byrow = TRUE
  ),
  start = c(2019, 2),
  frequency = 4,
  names = c("cars_alb", "cars_sask", "cars_man", "cars_tot")
)


###########
# Example 1: Period-by-period processing without temporal total preservation.

# Reconcile the data
out_raked1 <- tsraking_driver(my_series, my_metadata)
#> 
#> 
#> Raking period [2019-2]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2019-3]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2019-4]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-1]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-2]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-3]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-4]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2021-1]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 

# Initial data
my_series
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2       14        18       14       58
#> 2019 Q3       17        14       16       44
#> 2019 Q4       14        19       18       58
#> 2020 Q1       20        18       12       53
#> 2020 Q2       16        16       19       44
#> 2020 Q3       14        15       16       50
#> 2020 Q4       19        20       14       52
#> 2021 Q1       16        15       19       51

# Reconciled data
out_raked1
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2 17.65217  22.69565 17.65217       58
#> 2019 Q3 15.91489  13.10638 14.97872       44
#> 2019 Q4 15.92157  21.60784 20.47059       58
#> 2020 Q1 21.20000  19.08000 12.72000       53
#> 2020 Q2 13.80392  13.80392 16.39216       44
#> 2020 Q3 15.55556  16.66667 17.77778       50
#> 2020 Q4 18.64151  19.62264 13.73585       52
#> 2021 Q1 16.32000  15.30000 19.38000       51

# Check the output cross-sectional constraint
all.equal(
  rowSums(out_raked1[, my_metadata$series]), 
  as.vector(out_raked1[, "cars_tot"])
)
#> [1] TRUE

# Check the control total (fixed)
all.equal(my_series[, "cars_tot"], out_raked1[, "cars_tot"])
#> [1] TRUE


###########
# Example 2: Annual total preservation for year 2020 (period-by-period processing
#            for incomplete years 2019 and 2021), with `quiet = TRUE` to avoid
#            displaying the function header for all processing groups.

# First, check that the 2020 annual total for the total series (`cars_tot`) and the
# sum of the component series (`cars_alb`, `cars_sask` and `cars_man`) matches.
# Otherwise, this "grand total" discrepancy would first have to be resolved before
# calling `tsraking_driver()`.
tot2020 <- aggregate.ts(window(my_series, start = c(2020, 1), end = c(2020, 4)))
all.equal(
  as.numeric(tot2020[, "cars_tot"]), 
  sum(tot2020[, my_metadata$series])
)
#> [1] TRUE

# Reconcile the data
out_raked2 <- tsraking_driver(
  in_ts = my_series,
  metadata_df = my_metadata,
  quiet = TRUE,
  temporal_grp_periodicity = frequency(my_series)
)
#> 
#> 
#> Raking period [2019-2]
#> ======================
#> 
#> 
#> Raking period [2019-3]
#> ======================
#> 
#> 
#> Raking period [2019-4]
#> ======================
#> 
#> 
#> Raking periods [2020-1 - 2020-4]
#> ================================
#> 
#> 
#> Raking period [2021-1]
#> ======================

# Initial data
my_series
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2       14        18       14       58
#> 2019 Q3       17        14       16       44
#> 2019 Q4       14        19       18       58
#> 2020 Q1       20        18       12       53
#> 2020 Q2       16        16       19       44
#> 2020 Q3       14        15       16       50
#> 2020 Q4       19        20       14       52
#> 2021 Q1       16        15       19       51

# Reconciled data
out_raked2
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2 17.65217  22.69565 17.65217       58
#> 2019 Q3 15.91489  13.10638 14.97872       44
#> 2019 Q4 15.92157  21.60784 20.47059       58
#> 2020 Q1 21.15283  19.04513 12.80204       53
#> 2020 Q2 13.74700  13.75373 16.49927       44
#> 2020 Q3 15.50782  16.62184 17.87034       50
#> 2020 Q4 18.59234  19.57931 13.82835       52
#> 2021 Q1 16.32000  15.30000 19.38000       51

# Check the output cross-sectional constraint
all.equal(
  rowSums(out_raked2[, my_metadata$series]), 
  as.vector(out_raked2[, "cars_tot"])
)
#> [1] TRUE

# Check the output temporal constraints (2020 annual totals for each series)
all.equal(
  tot2020,
  aggregate.ts(window(out_raked2, start = c(2020, 1), end = c(2020, 4)))
)
#> [1] TRUE

# Check the control total (fixed)
all.equal(my_series[, "cars_tot"], out_raked2[, "cars_tot"])
#> [1] TRUE


###########
# Example 3: Annual total preservation for fiscal years defined from April to March
#            (2019Q2-2020Q1 and 2020Q2-2021Q1).

# Calculate the fiscal year totals (as an annual "ts" object)
fiscalYr_tot <- ts(
  rbind(
    aggregate.ts(window(my_series, start = c(2019, 2), end = c(2020, 1))),
    aggregate.ts(window(my_series, start = c(2020, 2), end = c(2021, 1)))
  ),
  start = 2019,
  frequency = 1
)

# Discrepancies in both fiscal year totals (total series vs. sum of the component series)
as.numeric(fiscalYr_tot[, "cars_tot"]) - rowSums(fiscalYr_tot[, my_metadata$series])
#> [1] 19 -2


# 3a) Reconcile the fiscal year totals (rake the fiscal year totals of the component series
#     to those of the total series).
new_fiscalYr_tot <- tsraking_driver(
  in_ts = fiscalYr_tot,
  metadata_df = my_metadata,
  quiet = TRUE
)
#> 
#> 
#> Raking period [2019]
#> ====================
#> 
#> 
#> Raking period [2020]
#> ====================

# Confirm that the previous discrepancies are now "gone" (are both zero)
as.numeric(new_fiscalYr_tot[, "cars_tot"]) - 
  rowSums(new_fiscalYr_tot[, my_metadata$series])
#> [1] 0 0

# 3b) Benchmark the quarterly component series to these new (coherent) fiscal year totals.
out_bench <- benchmarking(
  series_df = ts_to_tsDF(my_series[, my_metadata$series]),
  benchmarks_df = ts_to_bmkDF(
    new_fiscalYr_tot[, my_metadata$series],
    ind_frequency = frequency(my_series),
    
    # Fiscal years starting on Q2 (April)
    bmk_interval_start = 2
  ),
  rho = 0.729,
  lambda = 1,
  biasOption = 2,
  allCols = TRUE,
  quiet = TRUE
)
#> 
#> Benchmarking indicator series [cars_alb] with benchmarks [cars_alb]
#> -------------------------------------------------------------------
#> 
#> Benchmarking indicator series [cars_sask] with benchmarks [cars_sask]
#> ---------------------------------------------------------------------
#> 
#> Benchmarking indicator series [cars_man] with benchmarks [cars_man]
#> -------------------------------------------------------------------
my_new_ser <- tsDF_to_ts(
  cbind(out_bench$series, cars_tot = my_series[, "cars_tot"]),
  frequency = frequency(my_series)
)

# 3c) Reconcile the quarterly data with preservation of fiscal year totals.
out_raked3 <- tsraking_driver(
  in_ts = my_new_ser,
  metadata_df = my_metadata,
  temporal_grp_periodicity = frequency(my_series),
  
  # Fiscal years starting on Q2 (April)
  temporal_grp_start = 2,
  
  quiet = TRUE
)
#> 
#> 
#> Raking periods [2019-2 - 2020-1]
#> ================================
#> 
#> 
#> Raking periods [2020-2 - 2021-1]
#> ================================

# Initial data
my_series
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2       14        18       14       58
#> 2019 Q3       17        14       16       44
#> 2019 Q4       14        19       18       58
#> 2020 Q1       20        18       12       53
#> 2020 Q2       16        16       19       44
#> 2020 Q3       14        15       16       50
#> 2020 Q4       19        20       14       52
#> 2021 Q1       16        15       19       51

# With coherent fiscal year totals
my_new_ser
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2 15.40737  19.84939 15.41097       58
#> 2019 Q3 18.90614  15.54094 17.78267       44
#> 2019 Q4 15.45221  20.98489 19.84697       58
#> 2020 Q1 21.60026  19.38252 12.83568       53
#> 2020 Q2 16.44068  16.41619 19.39307       44
#> 2020 Q3 13.91243  14.89512 15.85700       50
#> 2020 Q4 18.49133  19.47043 13.65082       52
#> 2021 Q1 15.50230  14.55494 18.41569       51

# Reconciled data
out_raked3
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2 17.77916  22.53212 17.68872       58
#> 2019 Q3 16.07232  12.91959 15.00808       44
#> 2019 Q4 16.06497  21.42285 20.51217       58
#> 2020 Q1 21.44952  18.88317 12.66732       53
#> 2020 Q2 13.84015  13.79962 16.36024       44
#> 2020 Q3 15.57114  16.65292 17.77593       50
#> 2020 Q4 18.62985  19.59265 13.77750       52
#> 2021 Q1 16.30560  15.29149 19.40291       51

# Check the output cross-sectional constraint
all.equal(
  rowSums(out_raked3[, my_metadata$series]), 
  as.vector(out_raked3[, "cars_tot"])
)
#> [1] TRUE

# Check the output temporal constraints (both fiscal year totals for all series)
all.equal(
  rbind(
    aggregate.ts(window(my_new_ser, start = c(2019, 2), end = c(2020, 1))),
    aggregate.ts(window(my_new_ser, start = c(2020, 2), end = c(2021, 1)))
  ),
  rbind(
    aggregate.ts(window(out_raked3, start = c(2019, 2), end = c(2020, 1))),
    aggregate.ts(window(out_raked3, start = c(2020, 2), end = c(2021, 1)))
  )
)
#> [1] TRUE

# Check the control total (fixed)
all.equal(my_series[, "cars_tot"], out_raked3[, "cars_tot"])
#> [1] TRUE
```
