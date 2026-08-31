# Build the elements of raking problems.

This function is used internally by
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
to build the elements of the raking problem. It can also be useful to
derive the cross-sectional (marginal) totals of the raking problem
manually (outside of the
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
context).

## Usage

``` r
build_raking_problem(
  data_df,
  metadata_df,
  data_df_name = deparse1(substitute(data_df)),
  metadata_df_name = deparse1(substitute(metadata_df)),
  alterability_df = NULL,
  alterSeries = 1,
  alterTotal1 = 0,
  alterTotal2 = 0
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

- data_df_name:

  (optional)

  String containing the value of argument `data_df`.

  **Default value** is `data_df_name = deparse1(substitute(data_df))`.

- metadata_df_name:

  (optional)

  String containing the value of argument `metadata_df`.

  **Default value** is
  `metadata_df_name = deparse1(substitute(metadata_df))`.

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

## Value

A list with the elements of the raking problem (excluding the implicit
temporal totals):

- `x` : vector of component series initial values

- `c_x` : vector of component series alterability coefficients

- `comp_cols`: vector of component series (column) names

- `g` : vector of cross-sectional total initial values

- `c_g` : vector of cross-sectional total alterability coefficients

- `tot_cols` : vector of cross-sectional total (column) names

- `G` : cross-sectional total aggregation matrix (`g = G %*% x`)

## Details

See
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
for a detailed description of *time series raking* problems.

The returned raking problem elements do not include the implicit
component series temporal totals when applicable (i.e., elements `g` and
`G` only contain the cross-sectional totals info).

When the input data contains multiple periods (temporal total
preservation scenario), raking problem elements `x`, `c_x`, `g`, `c_g`
and `G` are constructed *column by column* (in "column-major order"),
corresponding to the default behaviour of R for converting objects of
class "matrix" into vectors.

Note: argument validation is not performed here; it is (bluntly) assumed
that the function is called by
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
where a thorough validation of the arguments is done.

## See also

[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
[`build_balancing_problem()`](https://StatCan.github.io/gensol-gseries/en/reference/build_balancing_problem.md)

## Examples

``` r
# Derive the 5 marginal totals of a 2 x 3 two-dimensional data cube using `tsraking()` 
# metadata.

my_metadata <- data.frame(
  series = c(
    "A1", "A2", "A3",
    "B1", "B2", "B3"
  ),
  total1 = c(
    rep("totA", 3),
    rep("totB", 3)
  ),
  total2 = rep(c("tot1", "tot2", "tot3"), 2)
)
my_metadata
#>   series total1 total2
#> 1     A1   totA   tot1
#> 2     A2   totA   tot2
#> 3     A3   totA   tot3
#> 4     B1   totB   tot1
#> 5     B2   totB   tot2
#> 6     B3   totB   tot3

# 6 periods of data with marginal totals set to `NA` (they MUST exist in the input data 
# but can be `NA`).
my_data <- data.frame(
  A1 = c(12, 10, 12,  9, 15,  7),
  B1 = c(20, 21, 15, 17, 19, 18),
  A2 = c(14,  9,  8,  9, 11, 10),
  B2 = c(20, 29, 20, 24, 21, 17),
  A3 = c(13, 15, 17, 14, 16, 12),
  B3 = c(24, 20, 30, 23, 21, 19),
  tot1 = rep(NA, 6),
  tot2 = rep(NA, 6),
  tot3 = rep(NA, 6),
  totA = rep(NA, 6),
  totB = rep(NA, 6)
)

# Get the raking problem elements.
p <- build_raking_problem(my_data, my_metadata)
str(p)
#> List of 7
#>  $ x        : num [1:36] 12 10 12 9 15 7 14 9 8 9 ...
#>  $ c_x      : num [1:36] 1 1 1 1 1 1 1 1 1 1 ...
#>  $ comp_cols: chr [1:6] "A1" "A2" "A3" "B1" ...
#>  $ g        : logi [1:30] NA NA NA NA NA NA ...
#>  $ c_g      : num [1:30] 0 0 0 0 0 0 0 0 0 0 ...
#>  $ tot_cols : chr [1:5] "totA" "totB" "tot1" "tot2" ...
#>  $ G        : num [1:30, 1:36] 1 0 0 0 0 0 0 0 0 0 ...

# Calculate the 5 marginal totals for all 6 periods.
my_data[p$tot_cols] <- p$G %*% p$x
my_data
#>   A1 B1 A2 B2 A3 B3 tot1 tot2 tot3 totA totB
#> 1 12 20 14 20 13 24   32   34   37   39   64
#> 2 10 21  9 29 15 20   31   38   35   34   70
#> 3 12 15  8 20 17 30   27   28   47   37   65
#> 4  9 17  9 24 14 23   26   33   37   32   64
#> 5 15 19 11 21 16 21   34   32   37   42   61
#> 6  7 18 10 17 12 19   25   27   31   29   54
```
