# Restore temporal constraints

*Replication of the G-Series 2.0 SAS\\^\circledR\\ BENCHMARKING
procedure (PROC BENCHMARKING). See the G-Series 2.0 documentation for
details (Statistics Canada 2016).*

This function ensures coherence between time series data of the same
target variable measured at different frequencies (e.g., sub-annually
and annually). Benchmarking consists of imposing the level of the
benchmark series (e.g., annual data) while minimizing the revisions of
the observed movement in the indicator series (e.g., sub-annual data) as
much as possible. The function also allows nonbinding benchmarking where
the benchmark series can also be revised.

The function may also be used for benchmarking-related topics such as
*temporal distribution* (the reciprocal action of benchmarking:
disaggregation of the benchmark series into more frequent observations),
*calendarization* (a special case of temporal distribution) and
*linking* (the connection of different time series segments into a
single consistent time series).

Several series can be benchmarked in a single function call.

## Usage

``` r
benchmarking(
  series_df,
  benchmarks_df,
  rho,
  lambda,
  biasOption,
  bias = NA,
  tolV = 0.001,
  tolP = NA,
  warnNegResult = TRUE,
  tolN = -0.001,
  var = "value",
  with = NULL,
  by = NULL,
  verbose = FALSE,

  # New in G-Series 3.0
  constant = 0,
  negInput_option = 0,
  allCols = FALSE,
  quiet = FALSE
)
```

## Arguments

- series_df:

  (mandatory)

  Data frame (object of class "data.frame") that contains the indicator
  time series data to be benchmarked. In addition to the series data
  variable(s), specified with argument `var`, the data frame must also
  contain two numeric variables, `year` and `period`, identifying the
  periods of the indicator time series.

- benchmarks_df:

  (mandatory)

  Data frame (object of class "data.frame") that contains the
  benchmarks. In addition to the benchmarks data variable(s), specified
  with argument `with`, the data frame must also contain four numeric
  variables, `startYear`, `startPeriod`, `endYear` and `endPeriod`,
  identifying the indicator time series periods covered by each
  benchmark.

- rho:

  (mandatory)

  Real number in the \\\[0,1\]\\ interval that specifies the value of
  the autoregressive parameter \\\rho\\. See section **Details** for
  more information on the effect of parameter \\\rho\\.

- lambda:

  (mandatory)

  Real number, with suggested values in the \\\[-3,3\]\\ interval, that
  specifies the value of the adjustment model parameter \\\lambda\\.
  Typical values are `lambda = 0.0` for an additive model and
  `lambda = 1.0` for a proportional model.

- biasOption:

  (mandatory)

  Specification of the bias estimation option:

  - `1`: Do not estimate the bias. The bias used to correct the
    indicator series will be the value specified with argument `bias`.

  - `2`: Estimate the bias, display the result, but do not use it. The
    bias used to correct the indicator series will be the value
    specified with argument `bias`.

  - `3`: Estimate the bias, display the result and use the estimated
    bias to correct the indicator series. Any value specified with
    argument `bias` will be ignored.

  Argument `biasOption` is ignored when `rho = 1.0`. See section
  **Details** for more information on the bias.

- bias:

  (optional)

  Real number, or `NA`, specifying the value of the user-defined bias to
  be used for the correction of the indicator series prior to
  benchmarking. The bias is added to the indicator series with an
  additive model (argument `lambda = 0.0`) while it is multiplied
  otherwise (argument `lambda != 0.0`). No bias correction is applied
  when `bias = NA`, which is equivalent to specifying `bias = 0.0` when
  `lambda = 0.0` and `bias = 1.0` otherwise. Argument `bias` is ignored
  when `biasOption = 3` or `rho = 1.0`. See section **Details** for more
  information on the bias.

  **Default value** is `bias = NA` (no user-defined bias).

- tolV, tolP:

  (optional)

  Nonnegative real number, or `NA`, specifying the tolerance, in
  absolute value or percentage, to be used for the validation of the
  output binding benchmarks (alterability coefficient of \\0.0\\). This
  validation compares the input binding benchmark values with the
  equivalent values calculated from the benchmarked series (output)
  data. Arguments `tolV` and `tolP` cannot be both specified (one must
  be specified while the other must be `NA`).

  **Example:** to set a tolerance of 10 *units*, specify
  `tolV = 10, tolP = NA`; to set a tolerance of 1%, specify
  `tolV = NA, tolP = 0.01`.

  **Default values** are `tolV = 0.001` and `tolP = NA`.

- warnNegResult:

  (optional)

  Logical argument specifying whether a warning message is generated
  when a negative value created by the function in the benchmarked
  (output) series is smaller than the threshold specified by argument
  `tolN`.

  **Default value** is `warnNegResult = TRUE`.

- tolN:

  (optional)

  Negative real number specifying the threshold for the identification
  of negative values. A value is considered negative when it is smaller
  than this threshold.

  **Default value** is `tolN = -0.001`.

- var:

  (optional)

  String vector (minimum length of 1) specifying the variable name(s) in
  the indicator series data frame (argument `series_df`) containing the
  values and (optionally) the user-defined alterability coefficients of
  the series to be benchmarked. These variables must be numeric.

  The syntax is
  `var = c("series1 </ alt_ser1>", "series2 </ alt_ser2>", ...)`.
  Default alterability coefficients of \\1.0\\ are used when a
  user-defined alterability coefficients variable is not specified
  alongside an indicator series variable. See section **Details** for
  more information on alterability coefficients.

  **Example:** `var = "value / alter"` would benchmark indicator series
  data frame variable `value` with the alterability coefficients
  contained in variable `alter` while
  `var = c("value / alter", "value2")` would additionally benchmark
  variable `value2` with default alterability coefficients of \\1.0\\.

  **Default value** is `var = "value"` (benchmark variable `value` using
  default alterability coefficients of \\1.0\\).

- with:

  (optional)

  String vector (same length as argument `var`), or `NULL`, specifying
  the variable name(s) in the benchmarks data frame (argument
  `benchmarks_df`) containing the values and (optionally) the
  user-defined alterability coefficients of the benchmarks. These
  variables must be numeric. Specifying `with = NULL` results in using
  benchmark variable(s) with the same names(s) as those specified with
  argument `var` without user-defined benchmark alterability
  coefficients (i.e., default alterability coefficients of \\0.0\\
  corresponding to binding benchmarks).

  The syntax is `with = NULL` or
  `with = c("bmk1 </ alt_bmk1>", "bmk2 </ alt_bmk2>", ...)`. Default
  alterability coefficients of \\0.0\\ (binding benchmarks) are used
  when a user-defined alterability coefficients variable is not
  specified alongside a benchmark variable. See section **Details** for
  more information on alterability coefficients.

  **Example:** `with = "val_bmk"` would use benchmarks data frame
  variable `val_bmk` with default benchmark alterability coefficients of
  \\0.0\\ to benchmark the indicator series while
  `with = c("val_bmk", "val_bmk2 / alt_bmk2")` would additionally
  benchmark a second indicator series using benchmark variable
  `val_bmk2` with the benchmark alterability coefficients contained in
  variable `alt_bmk2`.

  **Default value** is `with = NULL` (same benchmark variable(s) as
  argument `var` using default benchmark alterability coefficients of
  \\0.0\\).

- by:

  (optional)

  String vector (minimum length of 1), or `NULL`, specifying the
  variable name(s) in the input data frames (arguments `series_df` and
  `benchmarks_df`) to be used to form groups (for *BY-group* processing)
  and allow the benchmarking of multiple series in a single function
  call. BY-group variables can be numeric or character (factors or not),
  must be present in both input data frames and will appear in all three
  output data frames (see section **Value**). BY-group processing is not
  implemented when `by = NULL`. See "Benchmarking Multiple Series" in
  section **Details** for more information.

  **Default value** is `by = NULL` (no BY-group processing).

- verbose:

  (optional)

  Logical argument specifying whether information on intermediate steps
  with execution time (real time, not CPU time) should be displayed.
  Note that specifying argument `quiet = TRUE` would *nullify* argument
  `verbose`.

  **Default value** is `verbose = FALSE`.

- constant:

  (optional)

  Real number that specifies a value to be temporarily added to both the
  indicator series and the benchmarks before solving proportional
  benchmarking problems (`lambda != 0.0`). The temporary constant is
  removed from the final output benchmarked series. E.g., specifying a
  (small) constant would allow proportional benchmarking with `rho = 1`
  (e.g., proportional Denton benchmarking) on indicator series that
  include values of 0. Otherwise, proportional benchmarking with values
  of 0 in the indicator series is only possible when `rho < 1`.
  Specifying a constant with additive benchmarking (`lambda = 0.0`) has
  no impact on the resulting benchmarked data. The data variables in the
  `graphTable` output data frame include the constant, corresponding to
  the benchmarking problem that was actually solved.

  **Default value** is `constant = 0` (no temporary additive constant).

- negInput_option:

  (optional)

  Handling of negative values in the input data for proportional
  benchmarking (`lambda != 0.0`):

  - `0`: Do not allow negative values with proportional benchmarking. An
    error message is displayed in the presence of negative values in the
    input indicator series or benchmarks and missing (`NA`) values are
    returned for the benchmarked series. This corresponds to the
    G-Series 2.0 behaviour.

  - `1`: Allow negative values with proportional benchmarking but
    display a warning message.

  - `2`: Allow negative values with proportional benchmarking without
    displaying any message.

  **Default value** is `negInput_option = 0` (do not allow negative
  values with proportional benchmarking).

- allCols:

  (optional)

  Logical argument specifying whether all variables in the indicator
  series data frame (argument `series_df`), other than `year` and
  `period`, determine the set of series to benchmark. Values specified
  with arguments `var` and `with` are ignored when `allCols = TRUE`,
  which automatically implies default alterability coefficients, and
  variables with the same names as the indicator series must exist in
  the benchmarks data frame (argument `benchmarks_df`).

  **Default value** is `allCols = FALSE`.

- quiet:

  (optional)

  Logical argument specifying whether or not to display only essential
  information such as warning messages, error messages and variable
  (series) or BY-group information when multiple series are benchmarked
  in a single call to the function. We advise against *wrapping* your
  `benchmarking()` call with
  [`suppressMessages()`](https://rdrr.io/r/base/message.html) to further
  suppress the display of variable (series) or BY-group information when
  processing multiple series as this would make troubleshooting
  difficult in case of issues with individual series. Note that
  specifying `quiet = TRUE` would also *nullify* argument `verbose`.

  **Default value** is `quiet = FALSE`.

## Value

The function returns is a list of three data frames:

- `series`: data frame containing the benchmarked data (primary function
  output). BY variables specified with argument `by` would be included
  in the data frame but not alterability coefficient variables specified
  with argument `var`.

- `benchmarks`: copy of the input benchmarks data frame (excluding
  invalid benchmarks when applicable). BY variables specified with
  argument `by` would be included in the data frame but not alterability
  coefficient variables specified with argument `with`.

- `graphTable`: data frame containing supplementary data useful for
  producing analytical tables and graphs (see function
  [`plot_graphTable()`](https://StatCan.github.io/gensol-gseries/en/reference/plot_graphTable.md)).
  It contains the following variables in addition to the BY variables
  specified with argument `by`:

  - `varSeries`: Name of the indicator series variable

  - `varBenchmarks`: Name of the benchmark variable

  - `altSeries`: Name of the user-defined indicator series alterability
    coefficients variable

  - `altSeriesValue`: Indicator series alterability coefficients

  - `altbenchmarks`: Name of the user-defined benchmark alterability
    coefficients variable

  - `altBenchmarksValue`: Benchmark alterability coefficients

  - `t`: Indicator series period identifier (1 to \\T\\)

  - `m`: Benchmark coverage periods identifier (1 to \\M\\)

  - `year`: Data point calendar year

  - `period`: Data point period (cycle) value (1 to `periodicity`)

  - `constant`: Temporary additive constant (argument `constant`)

  - `rho`: Autoregressive parameter \\\rho\\ (argument `rho`)

  - `lambda`: Adjustment model parameter \\\lambda\\ (argument `lambda`)

  - `bias`: Bias adjustment (default, user-defined or estimated bias
    according to arguments `biasOption` and `bias`)

  - `periodicity`: The maximum number of periods in a year (e.g. 4 for a
    quarterly indicator series)

  - `date`: Character string combining the values of variables `year`
    and `period`

  - `subAnnual`: Indicator series values

  - `benchmarked`: Benchmarked series values

  - `avgBenchmark`: Benchmark values divided by the number of coverage
    periods

  - `avgSubAnnual`: Indicator series values (variable `subAnnual`)
    averaged over the benchmark coverage period

  - `subAnnualCorrected`: Bias corrected indicator series values

  - `benchmarkedSubAnnualRatio`: Difference (\\\lambda = 0\\) or ratio
    (\\\lambda \ne 0\\) of the values of variables `benchmarked` and
    `subAnnual`

  - `avgBenchmarkSubAnnualRatio`: Difference (\\\lambda = 0\\) or ratio
    (\\\lambda \ne 0\\) of the values of variables `avgBenchmark` and
    `avgSubAnnual`

  - `growthRateSubAnnual`: Period to period difference (\\\lambda = 0\\)
    or relative difference (\\\lambda \ne 0\\) of the indicator series
    values (variable `subAnnual`)

  - `growthRateBenchmarked`: Period to period difference (\\\lambda =
    0\\) or relative difference (\\\lambda \ne 0\\) of the benchmarked
    series values (variable `benchmarked`)

Notes:

- The output `benchmarks` data frame always contains the original
  benchmarks provided in the input benchmarks data frame. Modified
  nonbinding benchmarks, when applicable, can be recovered (calculated)
  from the output `series` data frame.

- The function returns a `NULL` object if an error occurs before data
  processing could start. Otherwise, if execution gets far enough so
  that data processing could start, then an incomplete object would be
  returned in case of errors (e.g., output `series` data frame with `NA`
  values for the benchmarked data).

- The function returns "data.frame" objects that can be explicitly
  coerced to other types of objects with the appropriate `as*()`
  function (e.g.,
  [`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
  would coerce any of them to a tibble).

## Details

When \\\rho \< 1\\, this function returns the generalized least squared
solution of a special case of the general regression-based benchmarking
model proposed by Dagum and Cholette (2006). The model, in matrix form,
is: \$\$\displaystyle \begin{bmatrix} s^\dagger \\ a \end{bmatrix} =
\begin{bmatrix} I \\ J \end{bmatrix} \theta + \begin{bmatrix} e \\
\varepsilon \end{bmatrix} \$\$ where

- \\a\\ is the vector of length \\M\\ of the benchmarks.

- \\s^\dagger = \left\\ \begin{array}{cl} s + b & \text{if } \lambda = 0
  \\ s \cdot b & \text{otherwise} \end{array} \right. \\ is the vector
  of length \\T\\ of the bias corrected indicator series values, with
  \\s\\ denoting the initial (input) indicator series.

- \\b\\ is the bias, which is specified with argument `bias` when
  argument `bias_option != 3` or, when `bias_option = 3`, is estimated
  as \\\hat{b} = \left\\ \begin{array}{cl} \frac{{1_M}^\mathrm{T} (a -
  Js)}{{1_M}^\mathrm{T} J 1_T} & \text{if } \lambda = 0 \\
  \frac{{1_M}^\mathrm{T} a}{{1_M}^\mathrm{T} Js} & \text{otherwise}
  \end{array} \right. \\, where \\1_X = (1, ..., 1)^\mathrm{T}\\ is a
  vector of \\1\\ of length \\X\\.

- \\J\\ is the \\M \times T\\ matrix of temporal aggregation constraints
  with elements \\j\_{m, t} = \left\\ \begin{array}{cl} 1 & \text{if
  benchmark } m \text{ covers period } t \\ 0 & \text{otherwise}
  \end{array} \right. \\.

- \\\theta\\ is the vector of the final (benchmarked) series values.

- \\e \sim \left( 0, V_e \right)\\ is the vector of the measurement
  errors of \\s^\dagger\\ with covariance matrix \\V_e = C \Omega_e C\\.

- \\C = \mathrm{diag} \left( \sqrt{c\_{s^\dagger}} \left\| s^\dagger
  \right\|^\lambda \right)\\ where \\c\_{s^\dagger}\\ is the vector of
  the alterability coefficients of \\s^\dagger\\, assuming \\0^0 = 1\\.

- \\\Omega_e\\ is a \\T \times T\\ matrix with elements
  \\\omega\_{e\_{i,j}} = \rho^{\|i-j\|}\\ representing the
  autocorrelation of an AR(1) process, again assuming \\0^0 = 1\\.

- \\\varepsilon \sim (0, V\_\varepsilon)\\ is the vector of the
  measurement errors of the benchmarks \\a\\ with covariance matrix
  \\V\_\varepsilon = \mathrm{diag} \left( c_a a \right)\\ where \\c_a\\
  is the vector of the alterability coefficients of the benchmarks
  \\a\\.

The generalized least squared solution is: \$\$\displaystyle
\hat{\theta} = s^\dagger + V_e J^{\mathrm{T}} \left( J V_e
J^{\mathrm{T}} + V\_\varepsilon \right)^+ \left( a - J s^\dagger \right)
\$\$ where \\A^{+}\\ designates the Moore-Penrose inverse of matrix
\\A\\.

When \\\rho = 1\\, the function returns the solution of the (modified)
Denton method: \$\$\displaystyle \hat{\theta} = s + W \left( a - J s
\right) \$\$ where

- \\W\\ is the upper-right corner matrix from the following matrix
  product \$\$ \left\[\begin{array}{cc} D^{+} \Delta^{\mathrm{T}} \Delta
  D^{+} & J^{\mathrm{T}} \\ J & 0 \end{array} \right\]^{+}
  \left\[\begin{array}{cc} D^{+} \Delta^{\mathrm{T}} \Delta D^{+} & 0 \\
  J & I_M \end{array} \right\] = \left\[\begin{array}{cc} I_T & W \\ 0 &
  W\_\nu \end{array} \right\] \$\$

- \\D = \mathrm{diag} \left( \left\| s \right\|^\lambda \right)\\,
  assuming \\0^0 = 1\\. Note that \\D\\ corresponds to \\C\\ with
  \\c\_{s^\dagger} = 1.0\\ and without bias correction (arguments
  `bias_option = 1` and `bias = NA`).

- \\\Delta\\ is a \\T-1 \times T\\ matrix with elements \\\delta\_{i,j}
  = \left\\ \begin{array}{cl} -1 & \text{if } i=j \\ 1 & \text{if }
  j=i+1 \\ 0 & \text{otherwise} \end{array} \right. \\.

- \\W\_\nu\\ is a \\M \times M\\ matrix associated with the Lagrange
  multipliers of the corresponding minimization problem, expressed as:
  \$\$\displaystyle \begin{aligned} & \underset{\theta}{\text{minimize}}
  & & \sum\_{t \ge 2} \left\[ \frac{\left( s_t - \theta_t
  \right)}{\left\| s_t\right\|^\lambda} - \frac{\left( s\_{t-1} -
  \theta\_{t-1} \right)}{\left\| s\_{t-1}\right\|^\lambda} \right\]^2 \\
  & \text{subject to} & & a = J \theta \end{aligned} \$\$

See Quenneville et al. (2006) and Dagum and Cholette (2006) for details.

### Autoregressive Parameter \\\rho\\ and *bias*

Parameter \\\rho\\ (argument `rho`) is associated to the change between
the (input) indicator and the (output) benchmarked series for two
consecutive periods and is often called the *movement preservation
parameter*. The larger the value of \\\rho\\, the more the indicator
series period to period movements are preserved in the benchmarked
series. With \\\rho = 0\\, period to period movement preservation is not
enforced and the resulting benchmarking adjustments are not smooth, as
in the case of prorating (\\\rho = 0\\ and \\\lambda = 0.5\\) where the
adjustments take the shape of a *step function*. At the other end of the
spectrum is \\\rho = 1\\, referred to as *Denton benchmarking*, where
period to period movement preservation is maximized, which results in
the smoothest possible set of benchmarking adjustments available with
the function.

The *bias* represents the expected discrepancies between the benchmarks
and the indicator series. It can be used to pre-adjust the indicator
series in order to reduce, on average, the discrepancies between the two
sources of data. Bias correction, which is specified with arguments
`biasOption` and `bias`, can be particularly useful for periods not
covered by benchmarks when \\\rho \< 1\\. In this context, parameter
\\\rho\\ dictates the speed at which the projected benchmarking
adjustments converge to the bias (or converge to *no adjustment* without
bias correction) for periods not covered by a benchmark. The smaller the
value of \\\rho\\, the faster the convergence to the bias, with
immediate convergence when \\\rho = 0\\ and no convergence at all (the
adjustment of the last period covered by a benchmark is repeated) when
\\\rho = 1\\ (Denton benchmarking). Arguments `biasOption` and `bias`
are actually ignored when \\\rho = 1\\ since correcting for the bias has
no impact on Denton benchmarking solutions. The suggested value for
\\\rho\\ is \\0.9\\ for monthly indicators and \\0.9^3 = 0.729\\ for
quarterly indicators, representing a reasonable compromise between
maximizing movement preservation and reducing revisions as new
benchmarks become available in the future (benchmarking *timeliness
issue*). In practice, note that Denton benchmarking could be
*approximated* with the regression-based model by using a \\\rho\\ value
that is smaller than, but very close to, \\1.0\\ (e.g., \\\rho =
0.999\\). See Dagum and Cholette (2006) for a complete discussion on
this topic.

### Alterability Coefficients

Alterability coefficients \\c\_{s^\dagger}\\ and \\c_a\\ conceptually
represent the measurement errors associated with the (bias corrected)
indicator time series values \\s^\dagger\\ and benchmarks \\a\\
respectively. They are nonnegative real numbers which, in practice,
specify the extent to which an initial value can be modified in relation
to other values. Alterability coefficients of \\0.0\\ define fixed
(binding) values while alterability coefficients greater than \\0.0\\
define free (nonbinding) values. Increasing the alterability coefficient
of an intial value results in more changes for that value in the
benchmarking solution and, conversely, less changes when decreasing the
alterability coefficient. The default alterability coefficients are
\\0.0\\ for the benchmarks (binding benchmarks) and \\1.0\\ for the
indicator series values (nonbinding indicator series). Important notes:

- With a value of \\\rho = 1\\ (argument `rho = 1`, associated to Denton
  Benchmarking), only the default alterability coefficients (\\0.0\\ for
  a benchmark and \\1.0\\ for a an indicator series value) are valid.
  The specification of user-defined alterability coefficients variables
  is therefore not allowed. If such variables are specified (see
  arguments `var` and `with`), the function ignores them and displays a
  warning message in the console.

- Alterability coefficients \\c\_{s^\dagger}\\ come into play after the
  indicator series has been corrected for the bias, when applicable
  (\\c\_{s^\dagger}\\ is associated to \\s^\dagger\\, not \\s\\). This
  means that specifying an alterability coefficient of \\0.0\\ for a
  given indicator series value **will not** result in an unchanged value
  after benchmarking **with bias correction** (see arguments
  `biasOption` and `bias`).

Nonbinding benchmarks, when applicable, can be recovered (calculated)
from the benchmarked series (see output data frame `series` in section
**Value**). The output `benchmarks` data frame always contains the
original benchmarks provided in the input benchmarks data frame
(argument `benchmarks_df`).

### Benchmarking Multiple Series

Multiple series can be benchmarked in a single `benchmarking()` call, by
specifying `allCols = TRUE`, by (manually) specifying multiple variables
with argument `var` (and argument `with`) or with BY-group processing
(argument `by != NULL`). An important distinction is that all indicator
series specified with `allCols = TRUE` or with argument `var` (and
benchmarks with argument `with`) are expected to be of the same length,
i.e., same set of periods and same set (number) of benchmarks.
Benchmarking series of different lengths (different sets of periods) or
with different sets (number) of benchmarks must be done with BY-group
processing on stacked indicator series and benchmarks input data frames
(see utility functions
[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_tsDF.md)
and
[`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_bmkDF.md)).
Arguments `by` and `var` can be combined in order to implement BY-group
processing for multiple series as illustrated by *Example 2* in the
**Examples** section. While multiple variables with argument `var` (or
`allCols = TRUE`) without BY-group processing (argument `by = NULL`) is
slightly more efficient (faster), a BY-group approach with a single
series variable is usually recommended as it is more general (works in
all contexts). The latter is illustrated by *Example 3* in the
**Examples** section. The BY variables specified with argument `by`
appear in all three output data frames.

### Arguments `constant` and `negInput_option`

These arguments extend the usage of proportional benchmarking to a
larger set of problems. Their default values correspond to the G-Series
2.0 behaviour (SAS\\^\circledR\\ PROC BENCHMARKING) for which equivalent
options are not defined. Although proportional benchmarking may not
necessarily be the most appropriate approach (additive benchmarking may
be more appropriate) when the values of the indicator series approach 0
(unstable period-to-period ratios) or "cross the 0 line" and can
therefore go from positive to negative and vice versa (confusing,
difficult to interpret period-to-period ratios), these cases are not
invalid mathematically speaking (i.e., the associated proportional
benchmarking problem can be solved). It is strongly recommended,
however, to carefully analyze and validate the resulting benchmarked
data in these situations and make sure they correspond to reasonable,
interpretable solutions.

### Treatment of Missing (`NA`) Values

- If a missing value appears in one of the variables of the benchmarks
  input data frame (other than the BY variables), the observations with
  the missing values are dropped, a warning message is displayed and the
  function executes.

- If a missing value appears in the `year` and/or `period` variables of
  the indicator series input data frame and BY variables are specified,
  the corresponding BY-group is skipped, a warning message is displayed
  and the function moves on to the next BY-group. If no BY variables are
  specified, a warning message is displayed and no processing is done.

- If a missing value appears in one of the indicator series variables in
  the indicator series input data frame and BY variables are specified,
  the corresponding BY-group is skipped, a warning message is displayed
  and the function moves on to the next BY-group. If no BY variables are
  specified, the affected indicator series is not processed, a warning
  message is displayed and the function moves on to the next indicator
  series (when applicable).

## References

Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal
Distribution and Reconciliation Methods of Time Series**.
Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
[doi:10.1007/0-387-35439-5](https://doi.org/10.1007/0-387-35439-5)

Fortier, S. and B. Quenneville (2007). "Theory and Application of
Benchmarking in Business Surveys". **Proceedings of the Third
International Conference on Establishment Surveys (ICES-III)**.
Montréal, June 2007.

Latendresse, E., M. Djona and S. Fortier (2007). "Benchmarking
Sub-Annual Series to Annual Totals – From Concepts to SAS\\^\circledR\\
Procedure and Enterprise Guide\\^\circledR\\ Custom Task". **Proceedings
of the SAS\\^\circledR\\ Global Forum 2007 Conference**. Cary, NC: SAS
Institute Inc.

Quenneville, B., S. Fortier, Z.-G. Chen and E. Latendresse (2006).
"Recent Developments in Benchmarking to Annual Totals in X-12-ARIMA and
at Statistics Canada". **Proceedings of the Eurostat Conference on
Seasonality, Seasonal Adjustment and Their Implications for Short-Term
Analysis and Forecasting**. Luxembourg, May 2006.

Quenneville, B., P. Cholette, S. Fortier and J. Bérubé (2010).
"Benchmarking Sub-Annual Indicator Series to Annual Control Totals
(Forillon v1.04.001)". **Internal document**. Statistics Canada, Ottawa,
Canada.

Quenneville, B. and S. Fortier (2012). "Restoring Accounting Constraints
in Time Series – Methods and Software for a Statistical Agency".
**Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New
York.

Statistics Canada (2012). **Theory and Application of Benchmarking
(Course code 0436)**. Statistics Canada, Ottawa, Canada.

Statistics Canada (2016). "The BENCHMARKING Procedure". **G-Series 2.0
User Guide**. Statistics Canada, Ottawa, Canada.

## See also

[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
[`plot_graphTable()`](https://StatCan.github.io/gensol-gseries/en/reference/plot_graphTable.md)
[bench_graphs](https://StatCan.github.io/gensol-gseries/en/reference/bench_graphs.md)
[`plot_benchAdj()`](https://StatCan.github.io/gensol-gseries/en/reference/plot_benchAdj.md)
[`gs.gInv_MP()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.gInv_MP.md)
[aliases](https://StatCan.github.io/gensol-gseries/en/reference/aliases.md)

## Examples

``` r
# Set the working directory (for the PDF files)
iniwd <- setwd(tempdir())


###########
# Example 1: Simple case with a single quarterly series to benchmark to annual values

# Quarterly indicator series
my_series1 <- ts_to_tsDF(
  ts(
    c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
    start = c(2015, 1),
    frequency = 4
  )
)
my_series1
#>   year period value
#> 1 2015      1   1.9
#> 2 2015      2   2.4
#> 3 2015      3   3.1
#> 4 2015      4   2.2
#> 5 2016      1   2.0
#> 6 2016      2   2.6
#> 7 2016      3   3.4
#> 8 2016      4   2.4
#> 9 2017      1   2.3

# Annual benchmarks for quarterly data
my_benchmarks1 <- ts_to_bmkDF(
  ts(
    c(10.3, 10.2),
    start = 2015,
    frequency = 1
  ),
  ind_frequency = 4
)
my_benchmarks1
#>   startYear startPeriod endYear endPeriod value
#> 1      2015           1    2015         4  10.3
#> 2      2016           1    2016         4  10.2

# Benchmarking using...
#   - recommended `rho` value for quarterly series (`rho = 0.729`)
#   - proportional model (`lambda = 1`)
#   - bias-corrected indicator series with the estimated bias (`biasOption = 3`)
out_bench1 <- benchmarking(
  my_series1,
  my_benchmarks1,
  rho = 0.729,
  lambda = 0,
  biasOption = 3
)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> benchmarking() function:
#>     series_df          = my_series1
#>     benchmarks_df      = my_benchmarks1
#>     rho                = 0.729
#>     lambda             = 0
#>     biasOption         = 3 (Calculate bias, use calculated bias)
#>     bias               (ignored)
#>     tolV               = 0.001 (default)
#>     warnNegResult      = TRUE (default)
#>     tolN               = -0.001 (default)
#>     var                = value (default)
#>     with               = NULL (default)
#>     by                 = NULL (default)
#>     verbose            = FALSE (default)
#>     (*)constant        = 0 (default)
#>     (*)negInput_option = 0 (default)
#>     (*)allCols         = FALSE (default)
#>     (*)quiet           = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> Number of observations in the BENCHMARKS data frame .............: 2
#> Number of valid observations in the BENCHMARKS data frame .......: 2
#> Number of observations in the SERIES data frame .................: 9
#> Number of valid observations in the SERIES data frame ...........: 9
#> BIAS = 0.0625 (calculated)

# Generate the benchmarking graphs
plot_graphTable(out_bench1$graphTable, "Ex1_graphs.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 1 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\Rtmp82Yc2t\Ex1_graphs.pdf


###########
# Example 2: Two quarterly series to benchmark to annual values,
#            with BY-groups and user-defined alterability coefficients

# Sales data (same sales for groups A and B; only alter coefs for van sales differ)
qtr_sales <- ts(
  matrix(
    c(
      # Car sales
      1851, 2436, 3115, 2205, 1987, 2635, 3435, 2361, 2183, 2822,
      3664, 2550, 2342, 3001, 3779, 2538, 2363, 3090, 3807, 2631,
      2601, 3063, 3961, 2774, 2476, 3083, 3864, 2773, 2489, 3082,
      # Van sales
      1900, 2200, 3000, 2000, 1900, 2500, 3800, 2500, 2100, 3100,
      3650, 2950, 3300, 4000, 3290, 2600, 2010, 3600, 3500, 2100,
      2050, 3500, 4290, 2800, 2770, 3080, 3100, 2800, 3100, 2860
    ),
    ncol = 2
  ),
  start = c(2011, 1),
  frequency = 4,
  names = c("car_sales", "van_sales")
)

ann_sales <- ts(
  matrix(
    c(
      # Car sales
       10324, 10200, 10582, 11097, 11582, 11092,
       # Van sales
       12000, 10400, 11550, 11400, 14500, 16000),
     ncol = 2
    ),
  start = 2011,
  frequency = 1,
  names = c("car_sales", "van_sales")
)

# Quarterly indicator series (with default alter coefs for now)
my_series2 <- rbind(
  cbind(
    data.frame(
      group = rep("A", nrow(qtr_sales)),
      alt_van = rep(1, nrow(qtr_sales))
    ),
    ts_to_tsDF(qtr_sales)
  ),
  cbind(
    data.frame(
      group = rep("B", nrow(qtr_sales)),
      alt_van = rep(1, nrow(qtr_sales))
    ),
    ts_to_tsDF(qtr_sales)
  )
)

# Set binding van sales (alter coef = 0) for 2012 Q1 and Q2 in group A (rows 5 and 6)
my_series2$alt_van[c(5,6)] <- 0
head(my_series2, n = 10)
#>    group alt_van year period car_sales van_sales
#> 1      A       1 2011      1      1851      1900
#> 2      A       1 2011      2      2436      2200
#> 3      A       1 2011      3      3115      3000
#> 4      A       1 2011      4      2205      2000
#> 5      A       0 2012      1      1987      1900
#> 6      A       0 2012      2      2635      2500
#> 7      A       1 2012      3      3435      3800
#> 8      A       1 2012      4      2361      2500
#> 9      A       1 2013      1      2183      2100
#> 10     A       1 2013      2      2822      3100
tail(my_series2)
#>    group alt_van year period car_sales van_sales
#> 55     B       1 2017      1      2476      2770
#> 56     B       1 2017      2      3083      3080
#> 57     B       1 2017      3      3864      3100
#> 58     B       1 2017      4      2773      2800
#> 59     B       1 2018      1      2489      3100
#> 60     B       1 2018      2      3082      2860


# Annual benchmarks for quarterly data (without alter coefs)
my_benchmarks2 <- rbind(
  cbind(
    data.frame(group = rep("A", nrow(ann_sales))),
    ts_to_bmkDF(ann_sales, ind_frequency = 4)
  ),
  cbind(
    data.frame(group = rep("B", nrow(ann_sales))),
    ts_to_bmkDF(ann_sales, ind_frequency = 4))
)
my_benchmarks2
#>    group startYear startPeriod endYear endPeriod car_sales van_sales
#> 1      A      2011           1    2011         4     10324     12000
#> 2      A      2012           1    2012         4     10200     10400
#> 3      A      2013           1    2013         4     10582     11550
#> 4      A      2014           1    2014         4     11097     11400
#> 5      A      2015           1    2015         4     11582     14500
#> 6      A      2016           1    2016         4     11092     16000
#> 7      B      2011           1    2011         4     10324     12000
#> 8      B      2012           1    2012         4     10200     10400
#> 9      B      2013           1    2013         4     10582     11550
#> 10     B      2014           1    2014         4     11097     11400
#> 11     B      2015           1    2015         4     11582     14500
#> 12     B      2016           1    2016         4     11092     16000

# Benchmarking using...
#   - recommended `rho` value for quarterly series (`rho = 0.729`)
#   - proportional model (`lambda = 1`)
#   - without bias correction (`biasOption = 1` and `bias` not specified)
#   - `quiet = TRUE` to avoid generating the function header
out_bench2 <- benchmarking(
  my_series2,
  my_benchmarks2,
  rho = 0.729,
  lambda = 1,
  biasOption = 1,
  var = c("car_sales", "van_sales / alt_van"),
  with = c("car_sales", "van_sales"),
  by = "group",
  quiet = TRUE
)
#> 
#> Benchmarking by-group 1 (group=A)
#> =================================
#> 
#> Benchmarking indicator series [car_sales] with benchmarks [car_sales]
#> ---------------------------------------------------------------------
#> 
#> Benchmarking indicator series [van_sales] with benchmarks [van_sales]
#> ---------------------------------------------------------------------
#> 
#> Benchmarking by-group 2 (group=B)
#> =================================
#> 
#> Benchmarking indicator series [car_sales] with benchmarks [car_sales]
#> ---------------------------------------------------------------------
#> 
#> Benchmarking indicator series [van_sales] with benchmarks [van_sales]
#> ---------------------------------------------------------------------

# Generate the benchmarking graphs
plot_graphTable(out_bench2$graphTable, "Ex2_graphs.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 4 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\Rtmp82Yc2t\Ex2_graphs.pdf

# Check the value of van sales for 2012 Q1 and Q2 in group A (fixed values)
all.equal(my_series2$van_sales[c(5,6)], out_bench2$series$van_sales[c(5,6)])
#> [1] TRUE


###########
# Example 3: same as example 2, but benchmarking all 4 series as BY-groups
#            (4 BY-groups of 1 series instead of 2 BY-groups of 2 series)

qtr_sales2 <- ts.union(A = qtr_sales, B = qtr_sales)
my_series3 <- stack_tsDF(ts_to_tsDF(qtr_sales2))
my_series3$alter <- 1
my_series3$alter[
  my_series3$series == "A.van_sales" & 
    my_series3$year == 2012 & 
    my_series3$period <= 2
] <- 0
head(my_series3)
#>        series year period value alter
#> 1 A.car_sales 2011      1  1851     1
#> 2 A.car_sales 2011      2  2436     1
#> 3 A.car_sales 2011      3  3115     1
#> 4 A.car_sales 2011      4  2205     1
#> 5 A.car_sales 2012      1  1987     1
#> 6 A.car_sales 2012      2  2635     1
tail(my_series3)
#>          series year period value alter
#> 115 B.van_sales 2017      1  2770     1
#> 116 B.van_sales 2017      2  3080     1
#> 117 B.van_sales 2017      3  3100     1
#> 118 B.van_sales 2017      4  2800     1
#> 119 B.van_sales 2018      1  3100     1
#> 120 B.van_sales 2018      2  2860     1


ann_sales2 <- ts.union(A = ann_sales, B = ann_sales)
my_benchmarks3 <- stack_bmkDF(ts_to_bmkDF(ann_sales2, ind_frequency = 4))
head(my_benchmarks3)
#>        series startYear startPeriod endYear endPeriod value
#> 1 A.car_sales      2011           1    2011         4 10324
#> 2 A.car_sales      2012           1    2012         4 10200
#> 3 A.car_sales      2013           1    2013         4 10582
#> 4 A.car_sales      2014           1    2014         4 11097
#> 5 A.car_sales      2015           1    2015         4 11582
#> 6 A.car_sales      2016           1    2016         4 11092
tail(my_benchmarks3)
#>         series startYear startPeriod endYear endPeriod value
#> 19 B.van_sales      2011           1    2011         4 12000
#> 20 B.van_sales      2012           1    2012         4 10400
#> 21 B.van_sales      2013           1    2013         4 11550
#> 22 B.van_sales      2014           1    2014         4 11400
#> 23 B.van_sales      2015           1    2015         4 14500
#> 24 B.van_sales      2016           1    2016         4 16000

out_bench3 <- benchmarking(
  my_series3,
  my_benchmarks3,
  rho = 0.729,
  lambda = 1,
  biasOption = 1,
  var = "value / alter",
  with = "value",
  by = "series",
  quiet = TRUE
)
#> 
#> Benchmarking by-group 1 (series=A.car_sales)
#> ============================================
#> 
#> Benchmarking by-group 2 (series=A.van_sales)
#> ============================================
#> 
#> Benchmarking by-group 3 (series=B.car_sales)
#> ============================================
#> 
#> Benchmarking by-group 4 (series=B.van_sales)
#> ============================================

# Generate the benchmarking graphs
plot_graphTable(out_bench3$graphTable, "Ex3_graphs.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 4 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\Rtmp82Yc2t\Ex3_graphs.pdf

# Convert data frame `out_bench3$series` to a "mts" object
qtr_sales2_bmked <- tsDF_to_ts(unstack_tsDF(out_bench3$series), frequency = 4)

# Print the first 10 observations
ts(qtr_sales2_bmked[1:10, ], start = start(qtr_sales2), deltat = deltat(qtr_sales2))
#>         A.car_sales A.van_sales B.car_sales B.van_sales
#> 2011 Q1    1987.762    2470.301    1987.762    2497.155
#> 2011 Q2    2641.222    2956.559    2641.222    2980.984
#> 2011 Q3    3366.003    4031.113    3366.003    4029.901
#> 2011 Q4    2329.013    2542.026    2329.013    2491.960
#> 2012 Q1    2021.161    1900.000    2021.161    2077.268
#> 2012 Q2    2602.064    2500.000    2602.064    2466.739
#> 2012 Q3    3320.486    3636.551    3320.486    3522.652
#> 2012 Q4    2256.289    2363.449    2256.289    2333.342
#> 2013 Q1    2072.168    2071.868    2072.168    2060.533
#> 2013 Q2    2663.309    3112.774    2663.309    3110.631

# Check the value of van sales for 2012 Q1 and Q2 in group A (fixed values)
all.equal(
  window(qtr_sales2[, "A.van_sales"], start = c(2012, 1), end = c(2012, 2)),
  window(qtr_sales2_bmked[, "A.van_sales"], start = c(2012, 1), end = c(2012, 2))
)
#> [1] TRUE


# Reset the working directory to its initial location
setwd(iniwd)
```
