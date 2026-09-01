# Restore cross-sectional (contemporaneous) aggregation constraints

*Replication of the G-Series 2.0 SAS\\^\circledR\\ TSRAKING procedure
(PROC TSRAKING). See the G-Series 2.0 documentation for details
(Statistics Canada 2016).*

This function will restore cross-sectional aggregation constraints in a
system of time series. The aggregation constraints may come from a 1 or
2-dimensional table. Optionally, temporal constraints can also be
preserved.

`tsraking()` is usually called in practice through
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
in order to reconcile all periods of the time series system in a single
function call.

## Usage

``` r
tsraking(
  data_df,
  metadata_df,
  alterability_df = NULL,
  alterSeries = 1,
  alterTotal1 = 0,
  alterTotal2 = 0,
  alterAnnual = 0,
  tolV = 0.001,
  tolP = NA,
  warnNegResult = TRUE,
  tolN = -0.001,
  id = NULL,
  verbose = FALSE,

  # New in G-Series 3.0
  Vmat_option = 1,
  warnNegInput = TRUE,
  quiet = FALSE
)
```

## Arguments

- data_df:

  (mandatory)

  Data frame (object of class "data.frame") that contains the time
  series data to be reconciled. It must minimally contain variables
  corresponding to the component series and cross-sectional control
  totals specified in the metadata data frame (argument `metadata_df`).
  If more than one observation (period) is provided, the sum of the
  provided component series values will also be preserved as part of
  implicit temporal constraints.

- metadata_df:

  (mandatory)

  Data frame (object of class "data.frame") that describes the
  cross-sectional aggregation constraints (additivity rules) for the
  raking problem. Two character variables must be included in the
  metadata data frame: `series` and `total1`. Two variables are
  optional: `total2` (character) and `alterAnnual` (numeric). The values
  of variable `series` represent the variable names of the component
  series in the input time series data frame (argument `data_df`).
  Similarly, the values of variables `total1` and `total2` represent the
  variable names of the 1^(st) and 2^(nd) dimension cross-sectional
  control totals in the input time series data frame. Variable
  `alterAnnual` contains the alterability coefficient for the temporal
  constraint associated to each component series. When specified, the
  latter will override the default alterability coefficient specified
  with argument `alterAnnual`.

- alterability_df:

  (optional)

  Data frame (object of class "data.frame"), or `NULL`, that contains
  the alterability coefficients variables. They must correspond to a
  component series or a cross-sectional control total, that is, a
  variable with the same name must exist in the input time series data
  frame (argument `data_df`). The values of these alterability
  coefficients will override the default alterability coefficients
  specified with arguments `alterSeries`, `alterTotal1` and
  `alterTotal2`. When the input time series data frame contains several
  observations and the alterability coefficients data frame contains
  only one, the alterability coefficients are used (repeated) for all
  observations of the input time series data frame. Alternatively, the
  alterability coefficients data frame may contain as many observations
  as the input time series data frame.

  **Default value** is `alterability_df = NULL` (default alterability
  coefficients).

- alterSeries:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient for the component series values. It will apply to
  component series for which alterability coefficients have not already
  been specified in the alterability coefficients data frame (argument
  `alterability_df`).

  **Default value** is `alterSeries = 1.0` (nonbinding component series
  values).

- alterTotal1:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient for the 1^(st) dimension cross-sectional control totals.
  It will apply to cross-sectional control totals for which alterability
  coefficients have not already been specified in the alterability
  coefficients data frame (argument `alterability_df`).

  **Default value** is `alterTotal1 = 0.0` (binding 1^(st) dimension
  cross-sectional control totals)

- alterTotal2:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient for the 2^(nd) dimension cross-sectional control totals.
  It will apply to cross-sectional control totals for which alterability
  coefficients have not already been specified in the alterability
  coefficients data frame (argument `alterability_df`).

  **Default value** is `alterTotal2 = 0.0` (binding 2^(nd) dimension
  cross-sectional control totals).

- alterAnnual:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient for the component series temporal constraints (e.g.,
  annual totals). It will apply to component series for which
  alterability coefficients have not already been specified in the
  metadata data frame (argument `metadata_df`).

  **Default value** is `alterAnnual = 0.0` (binding temporal control
  totals).

- tolV, tolP:

  (optional)

  Nonnegative real number, or `NA`, specifying the tolerance, in
  absolute value or percentage, to be used when performing the ultimate
  test in the case of binding totals (alterability coefficient of
  \\0.0\\ for temporal or cross-sectional control totals). The test
  compares the input binding control totals with the ones calculated
  from the reconciled (output) component series. Arguments `tolV` and
  `tolP` cannot be both specified together (one must be specified while
  the other must be `NA`).

  **Example:** to set a tolerance of 10 *units*, specify
  `tolV = 10, tolP = NA`; to set a tolerance of 1%, specify
  `tolV = NA, tolP = 0.01`.

  **Default values** are `tolV = 0.001` and `tolP = NA`.

- warnNegResult:

  (optional)

  Logical argument specifying whether a warning message is generated
  when a negative value created by the function in the reconciled
  (output) series is smaller than the threshold specified by argument
  `tolN`.

  **Default value** is `warnNegResult = TRUE`.

- tolN:

  (optional)

  Negative real number specifying the threshold for the identification
  of negative values. A value is considered negative when it is smaller
  than this threshold.

  **Default value** is `tolN = -0.001`.

- id:

  (optional)

  String vector (minimum length of 1), or `NULL`, specifying the name of
  additional variables to be transferred from the input time series data
  frame (argument `data_df`) to the output time series data frame, the
  object returned by the function (see section **Value**). By default,
  the output series data frame only contains the variables listed in the
  metadata data frame (argument `metadata_df`).

  **Default value** is `id = NULL`.

- verbose:

  (optional)

  Logical argument specifying whether information on intermediate steps
  with execution time (real time, not CPU time) should be displayed.
  Note that specifying argument `quiet = TRUE` would *nullify* argument
  `verbose`.

  **Default value** is `verbose = FALSE`.

- Vmat_option:

  (optional)

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

- warnNegInput:

  (optional)

  Logical argument specifying whether a warning message is generated
  when a negative value smaller than the threshold specified by argument
  `tolN` is found in the input time series data frame (argument
  `data_df`).

  **Default value** is `warnNegInput = TRUE`.

- quiet:

  (optional)

  Logical argument specifying whether or not to display only essential
  information such as warnings and errors. Specifying `quiet = TRUE`
  would also *nullify* argument `verbose` and is equivalent to
  *wrapping* your `tsraking()` call with
  [`suppressMessages()`](https://rdrr.io/r/base/message.html).

  **Default value** is `quiet = FALSE`.

## Value

The function returns a data frame containing the reconciled component
series, reconciled cross-sectional control totals and variables
specified with argument `id`. Note that the "data.frame" object can be
explicitly coerced to another type of object with the appropriate
`as*()` function (e.g.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
would coerce it to a tibble).

## Details

This function returns the generalized least squared solution of a
specific, simple variant of the general regression-based raking model
proposed by Dagum and Cholette (Dagum and Cholette 2006). The model, in
matrix form, is: \$\$\displaystyle \begin{bmatrix} x \\ g \end{bmatrix}
= \begin{bmatrix} I \\ G \end{bmatrix} \theta + \begin{bmatrix} e \\
\varepsilon \end{bmatrix} \$\$ where

- \\x\\ is the vector of the initial component series values.

- \\\theta\\ is the vector of the final (reconciled) component series
  values.

- \\e \sim \left( 0, V_e \right)\\ is the vector of the measurement
  errors of \\x\\ with covariance matrix \\V_e = \mathrm{diag} \left(
  c_x x \right)\\, or \\V_e = \mathrm{diag} \left( \left\| c_x x
  \right\| \right)\\ when argument `Vmat_option = 2`, where \\c_x\\ is
  the vector of the alterability coefficients of \\x\\.

- \\g\\ is the vector of the initial control totals, including the
  component series temporal totals (when applicable).

- \\\varepsilon \sim (0, V\_\varepsilon)\\ is the vector of the
  measurement errors of \\g\\ with covariance matrix \\V\_\varepsilon =
  \mathrm{diag} \left( c_g g \right)\\, or \\V\_\varepsilon =
  \mathrm{diag} \left( \left\| c_g g \right\| \right)\\ when argument
  `Vmat_option = 2`, where \\c_g\\ is the vector of the alterability
  coefficients of \\g\\.

- \\G\\ is the matrix of aggregation constraints, including the implicit
  temporal constraints (when applicable).

The generalized least squared solution is: \$\$\displaystyle
\hat{\theta} = x + V_e G^{\mathrm{T}} \left( G V_e G^{\mathrm{T}} +
V\_\varepsilon \right)^+ \left( g - G x \right) \$\$ where \\A^{+}\\
designates the Moore-Penrose inverse of matrix \\A\\.

`tsraking()` solves a single raking problem, i.e., either a single
period of the time series system, or a single temporal group (e.g., all
periods of a given year) when temporal total preservation is required.
Several call to `tsraking()` are therefore necessary in order to
reconcile all the periods of the time series system.
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
can achieve this in a single call: it conveniently determines the
required set of raking problems to be solved and internally generates
the individual calls to `tsraking()`.

### Alterability Coefficients

Alterability coefficients \\c_x\\ and \\c_g\\ conceptually represent the
measurement errors associated with the input component series values
\\x\\ and control totals \\g\\ respectively. They are nonnegative real
numbers which, in practice, specify the extent to which an initial value
can be modified in relation to other values. Alterability coefficients
of \\0.0\\ define fixed (binding) values while alterability coefficients
greater than \\0.0\\ define free (nonbinding) values. Increasing the
alterability coefficient of an intial value results in more changes for
that value in the reconciled (output) data and, conversely, less changes
when decreasing the alterability coefficient. The default alterability
coefficients are \\1.0\\ for the component series values and \\0.0\\ for
the cross-sectional control totals and, when applicable, the component
series temporal totals. These default alterability coefficients result
in a proportional allocation of the discrepancies to the component
series. Setting the component series alterability coefficients to the
inverse of the component series initial values would result in a uniform
allocation of the discrepancies instead. *Almost binding* totals can be
obtained in practice by specifying very small (almost \\0.0\\)
alterability coefficients relative to those of the (nonbinding)
component series.

**Temporal total preservation** refers to the fact that temporal totals,
when applicable, are usually kept “as close as possible” to their
initial value. *Pure preservation* is achieved by default with binding
temporal totals while the change is minimized with nonbinding temporal
totals (in accordance with the set of alterability coefficients).

### Arguments `Vmat_option` and `warnNegInput`

These arguments allow for an alternative handling of negative values in
the input data, similar to that of
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md).
Their default values correspond to the G-Series 2.0 behaviour
(SAS\\^\circledR\\ PROC TSRAKING) for which equivalent options are not
defined. The latter was developed with "nonnegative input data only" in
mind, similar to SAS\\^\circledR\\ PROC BENCHMARKING in G-Series 2.0
that did not allow negative values either with proportional
benchmarking, which explains the "suspicious use of proportional raking"
warning in presence of negative values with PROC TSRAKING in G-Series
2.0 and when `warnNegInput = TRUE` (default). However, (proportional)
raking in the presence of negative values generally works well with
`Vmat_option = 2` and produces reasonable, intuitive solutions. E.g.,
while the default `Vmat_option = 1` fails at solving constraint
`A + B = C` with input data `A = 2`, `B = -2`, `C = 1` and the default
alterability coefficients, `Vmat_option = 2` returns the (intuitive)
solution `A = 2.5`, `B = -1.5`, `C = 1` (25% increase for `A` and `B`).
See Ferland (2016) for more details.

### Treatment of Missing (`NA`) Values

Missing values in the input time series data frame (argument `data_df`)
or alterability coefficients data frame (argument `alterability_df`) for
any of the raking problem data (variables listed in the metadata data
frame with argument `metadata_df`) will generate an error message and
stop the function execution.

## Comparing `tsraking()` and [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)

- `tsraking()` is limited to one- and two-dimensional aggregation table
  raking problems (with temporal total preservation if required) while
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  handles more general balancing problems (e.g., higher dimensional
  raking problems, nonnegative solutions, general linear equality and
  inequality constraints as opposed to aggregation rules only, etc.).

- `tsraking()` returns the generalized least squared solution of the
  Dagum and Cholette regression-based raking model (Dagum and
  Cholette 2006) while
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  solves the corresponding quadratic minimization problem using a
  numerical solver. In most cases, *convergence to the minimum* is
  achieved and the
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  solution matches the (exact) `tsraking()` least square solution. It
  may not be the case, however, if convergence could not be achieved
  after a reasonable number of iterations. Having said that, only in
  very rare occasions will the
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  solution *significantly* differ from the `tsraking()` solution.

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  is usually faster than `tsraking()`, especially for large raking
  problems, but is generally more sensitive to the presence of (small)
  inconsistencies in the input data associated to the redundant
  constraints of fully specified (over-specified) raking problems.
  `tsraking()` handles these inconsistencies by using the Moore-Penrose
  inverse (uniform distribution among all binding totals).

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  accommodates the specification of sparse problems in their reduced
  form. This is not true in the case of `tsraking()` where aggregation
  rules must always be fully specified since a *complete data cube*
  without missing data is expected as input (every single *inner-cube*
  component series must contribute to all dimensions of the cube, i.e.,
  to every single *outer-cube* marginal total series).

- Both tools handle negative values in the input data differently by
  default. While the solutions of raking problems obtained from
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  and `tsraking()` are identical when all input data points are
  positive, they will differ if some data points are negative (unless
  argument `Vmat_option = 2` is specified with `tsraking()`).

- While both
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  and `tsraking()` allow the preservation of temporal totals, time
  management is not incorporated in `tsraking()`. For example, the
  construction of the processing groups (sets of periods of each raking
  problem) is left to the user with `tsraking()` and separate calls must
  be submitted for each processing group (each raking problem). That's
  where helper function
  [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
  comes in handy with `tsraking()`.

- The marginal totals (*outer-cube* marginal total series) returned by
  `tsraking()` are always recalculated as the sum of the relevant
  component series (*inner-cube* component series). The output values of
  **binding** marginal totals may therefore slightly differ from the
  input values. The magnitude of the differences depends on the initial
  inconsistencies (that end up being uniformly distributed by the
  Moore-Penrose inverse). This is not the case for
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  where the values of **binding** marginal totals always remain
  perfectly unchanged, potentially resulting in (small) discrepancies
  between the sum of the returned component series and the corresponding
  marginal totals.

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  returns the same set of series as the input time series object while
  `tsraking()` returns the set of series involved in the raking problem
  plus those specified with argument `id` (which could correspond to a
  subset of the input series).

## References

Bérubé, J. and S. Fortier (2009). "PROC TSRAKING: An in-house
SAS\\^\circledR\\ procedure for balancing time series". In **JSM
Proceedings, Business and Economic Statistics Section**. Alexandria, VA:
American Statistical Association.

Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal
Distribution and Reconciliation Methods of Time Series**.
Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
[doi:10.1007/0-387-35439-5](https://doi.org/10.1007/0-387-35439-5)

Ferland, M. (2016). "Negative Values with PROC TSRAKING". **Internal
document**. Statistics Canada, Ottawa, Canada.

Fortier, S. and B. Quenneville (2009). "Reconciliation and Balancing of
Accounts and Time Series". In **JSM Proceedings, Business and Economic
Statistics Section**. Alexandria, VA: American Statistical Association.

Quenneville, B. and S. Fortier (2012). "Restoring Accounting Constraints
in Time Series – Methods and Software for a Statistical Agency".
**Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New
York.

Statistics Canada (2016). "The TSRAKING Procedure". **G-Series 2.0 User
Guide**. Statistics Canada, Ottawa, Canada.

Statistics Canada (2018). **Theory and Application of Reconciliation
(Course code 0437)**. Statistics Canada, Ottawa, Canada.

## See also

[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
[`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/en/reference/rkMeta_to_blSpecs.md)
[`gs.gInv_MP()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.gInv_MP.md)
[`build_raking_problem()`](https://StatCan.github.io/gensol-gseries/en/reference/build_raking_problem.md)
[aliases](https://StatCan.github.io/gensol-gseries/en/reference/aliases.md)

## Examples

``` r
###########
# Example 1: Simple 1-dimensional raking problem where the values of `cars` and `vans`
#            must sum up to the value of `total`.

# Problem metadata
my_metadata1 <- data.frame(
  series = c("cars", "vans"),
  total1 = c("total", "total")
)
my_metadata1
#>   series total1
#> 1   cars  total
#> 2   vans  total

# Problem data
my_series1 <- data.frame(cars = 25, vans = 5, total = 40)

# Reconcile the data
out_raked1 <- tsraking(my_series1, my_metadata1)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = my_series1
#>     metadata_df     = my_metadata1
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
my_series1
#>   cars vans total
#> 1   25    5    40

# Reconciled data
out_raked1
#>       cars     vans total
#> 1 33.33333 6.666667    40

# Check the output cross-sectional constraint
all.equal(rowSums(out_raked1[c("cars", "vans")]), out_raked1$total)
#> [1] TRUE

# Check the control total (fixed)
all.equal(my_series1$total, out_raked1$total)
#> [1] TRUE


###########
# Example 2: 2-dimensional raking problem similar to the 1st example but adding
#            regional sales for the 3 prairie provinces (Alb., Sask. and Man.)
#            and where the sales of vans in Sask. are non-alterable
#            (alterability coefficient = 0), with `quiet = TRUE` to avoid
#            displaying the function header.

# Problem metadata
my_metadata2 <- data.frame(
  series = c(
    "cars_alb", "cars_sask", "cars_man",
    "vans_alb", "vans_sask", "vans_man"
  ),
  total1 = c(
    rep("cars_total", 3),
    rep("vans_total", 3)
  ),
  total2 = rep(c("alb_total", "sask_total", "man_total"), 2)
)
my_metadata2
#>      series     total1     total2
#> 1  cars_alb cars_total  alb_total
#> 2 cars_sask cars_total sask_total
#> 3  cars_man cars_total  man_total
#> 4  vans_alb vans_total  alb_total
#> 5 vans_sask vans_total sask_total
#> 6  vans_man vans_total  man_total

# Problem data
my_series2 <- data.frame(
  cars_alb = 12, cars_sask = 14, cars_man = 13,
  vans_alb = 20, vans_sask = 20, vans_man = 24,
  alb_total = 30, sask_total = 31, man_total = 32,
  cars_total = 40, vans_total = 53
)

# Reconciled data
out_raked2 <- tsraking(
  my_series2, my_metadata2,
  alterability_df = data.frame(vans_sask = 0),
  quiet = TRUE
)

# Initial data
my_series2
#>   cars_alb cars_sask cars_man vans_alb vans_sask vans_man alb_total sask_total
#> 1       12        14       13       20        20       24        30         31
#>   man_total cars_total vans_total
#> 1        32         40         53

# Reconciled data
out_raked2
#>   cars_alb cars_sask cars_man vans_alb vans_sask vans_man alb_total sask_total
#> 1 14.31298        11 14.68702 15.68702        20 17.31298        30         31
#>   man_total cars_total vans_total
#> 1        32         40         53

# Check the output cross-sectional constraints
all.equal(
  rowSums(out_raked2[c("cars_alb", "cars_sask", "cars_man")]), 
  out_raked2$cars_total
)
#> [1] TRUE
all.equal(
  rowSums(out_raked2[c("vans_alb", "vans_sask", "vans_man")]), 
  out_raked2$vans_total
)
#> [1] TRUE
all.equal(
  rowSums(out_raked2[c("cars_alb", "vans_alb")]), 
  out_raked2$alb_total
)
#> [1] TRUE
all.equal(
  rowSums(out_raked2[c("cars_sask", "vans_sask")]), 
  out_raked2$sask_total
)
#> [1] TRUE
all.equal(
  rowSums(out_raked2[c("cars_man", "vans_man")]), 
  out_raked2$man_total
)
#> [1] TRUE

# Check the control totals (fixed)
tot_cols <- union(unique(my_metadata2$total1), unique(my_metadata2$total2))
all.equal(my_series2[tot_cols], out_raked2[tot_cols])
#> [1] TRUE

# Check the value of vans in Saskatchewan (fixed at 20)
all.equal(my_series2$vans_sask, out_raked2$vans_sask)
#> [1] TRUE
```
