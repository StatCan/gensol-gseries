# Convert reconciliation metadata

Convert a
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
metadata data frame to a
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
problem specs data frame.

## Usage

``` r
rkMeta_to_blSpecs(
  metadata_df,
  alterability_df = NULL,
  alterSeries = 1, 
  alterTotal1 = 0,
  alterTotal2 = 0,
  alterability_df_only = FALSE
)
```

## Arguments

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

- alterability_df_only:

  (optional)

  Logical argument specifying whether or not only the set of
  alterability ceofficients found in the alterability file (argument
  `alterability_df`) should be included in the returned
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  problem specs data frame. When `alterability_df_only = FALSE` (the
  default), the alterability coefficients specified with arguments
  `alterSeries`, `alterTotal1` and `alterTotal2` are combined with those
  found in `alterability_df` (the latter coefficients overwriting the
  former) and the returned data frame therefore contains alterability
  coefficients for all component and cross-sectional control total
  series. This argument does not affect the set of temporal total
  alterability coefficients (associated to
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  argument `alterAnnual`) that are included in the returned
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  problem specs data frame. The latter always strictly contains those
  specified in `metadata_df` with a non-missing (non-`NA`) value for
  column `alterAnnual`.

  **Default value** is `alterability_df_only = FALSE`.

## Value

A
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
problem specs data frame (argument `problem_specs_df`).

## Details

The preceding description of argument `alterability_df` comes from
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md).
This function (`rkMeta_to_blSpecs()`) slightly changes the specification
of alterability coefficients with argument `alterability_df` by allowing
either

- a single observation, specifying the set of alterability coefficients
  to use for all periods,

- or one or several observations with an additional column named
  `timeVal` allowing the specification of both period-specific
  alterability coefficients (`timeVal` is not `NA`) and generic
  coefficients to use for all other periods (`timeVal` is `NA`). Values
  for column `timeVal` correspond to the *time values* of a "ts" object
  as returned by [`stats::time()`](https://rdrr.io/r/stats/time.html),
  conceptually corresponding to \\year + (period - 1) / frequency\\.

Another difference with
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
is that missing (`NA`) values are allowed in the alterability
coefficients data frame (argument `alterability_df`) and result in using
the generic coefficients (observations for which `timeVal` is `NA`) or
the default coefficients (arguments `alterSeries`, `alterTotal1` and
`alterTotal2`).

Note that apart from discarding alterability coefficients for series not
listed in the
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
metadata data frame (argument `metadata_df`), this function does not
validate the values specified in the alterability coefficients data
frame (argument `alterability_df`) nor the ones specified with column
`alterAnnual` in the
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
metadata data frame (argument `metadata_df`). The function transfers
them *as is* in the returned
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
problem specs data frame.

## See also

[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)

## Examples

``` r
# `tsraking()` metadata for a 2-dimensional raking problem (2 x 2 table)
my_metadata <- data.frame(
  series = c("A1", "A2", "B1", "B2"),
  total1 = c("totA", "totA", "totB", "totB"),
  total2 = c("tot1", "tot2", "tot1", "tot2")
)
my_metadata
#>   series total1 total2
#> 1     A1   totA   tot1
#> 2     A2   totA   tot2
#> 3     B1   totB   tot1
#> 4     B2   totB   tot2


# Convert to `tsbalancing()` specifications

# Include the default `tsraking()` alterability coefficients
rkMeta_to_blSpecs(my_metadata)
#>     type  col                       row coef timeVal
#> 1     EQ <NA>   Marginal Total 1 (totA)   NA      NA
#> 2   <NA>   A1   Marginal Total 1 (totA)    1      NA
#> 3   <NA>   A2   Marginal Total 1 (totA)    1      NA
#> 4   <NA> totA   Marginal Total 1 (totA)   -1      NA
#> 5     EQ <NA>   Marginal Total 2 (totB)   NA      NA
#> 6   <NA>   B1   Marginal Total 2 (totB)    1      NA
#> 7   <NA>   B2   Marginal Total 2 (totB)    1      NA
#> 8   <NA> totB   Marginal Total 2 (totB)   -1      NA
#> 9     EQ <NA>   Marginal Total 3 (tot1)   NA      NA
#> 10  <NA>   A1   Marginal Total 3 (tot1)    1      NA
#> 11  <NA>   B1   Marginal Total 3 (tot1)    1      NA
#> 12  <NA> tot1   Marginal Total 3 (tot1)   -1      NA
#> 13    EQ <NA>   Marginal Total 4 (tot2)   NA      NA
#> 14  <NA>   A2   Marginal Total 4 (tot2)    1      NA
#> 15  <NA>   B2   Marginal Total 4 (tot2)    1      NA
#> 16  <NA> tot2   Marginal Total 4 (tot2)   -1      NA
#> 17 alter <NA> Period Value Alterability   NA      NA
#> 18  <NA>   A1 Period Value Alterability    1      NA
#> 19  <NA>   A2 Period Value Alterability    1      NA
#> 20  <NA>   B1 Period Value Alterability    1      NA
#> 21  <NA>   B2 Period Value Alterability    1      NA
#> 22  <NA> totA Period Value Alterability    0      NA
#> 23  <NA> totB Period Value Alterability    0      NA
#> 24  <NA> tot1 Period Value Alterability    0      NA
#> 25  <NA> tot2 Period Value Alterability    0      NA

# Almost binding 1st marginal totals (small alter. coef for columns `totA` and `totB`)
tail(rkMeta_to_blSpecs(my_metadata, alterTotal1 = 1e-6))
#>    type  col                       row  coef timeVal
#> 20 <NA>   B1 Period Value Alterability 1e+00      NA
#> 21 <NA>   B2 Period Value Alterability 1e+00      NA
#> 22 <NA> totA Period Value Alterability 1e-06      NA
#> 23 <NA> totB Period Value Alterability 1e-06      NA
#> 24 <NA> tot1 Period Value Alterability 0e+00      NA
#> 25 <NA> tot2 Period Value Alterability 0e+00      NA

# Do not include alterability coefficients (aggregation constraints only)
rkMeta_to_blSpecs(my_metadata, alterability_df_only = TRUE)
#>    type  col                     row coef timeVal
#> 1    EQ <NA> Marginal Total 1 (totA)   NA      NA
#> 2  <NA>   A1 Marginal Total 1 (totA)    1      NA
#> 3  <NA>   A2 Marginal Total 1 (totA)    1      NA
#> 4  <NA> totA Marginal Total 1 (totA)   -1      NA
#> 5    EQ <NA> Marginal Total 2 (totB)   NA      NA
#> 6  <NA>   B1 Marginal Total 2 (totB)    1      NA
#> 7  <NA>   B2 Marginal Total 2 (totB)    1      NA
#> 8  <NA> totB Marginal Total 2 (totB)   -1      NA
#> 9    EQ <NA> Marginal Total 3 (tot1)   NA      NA
#> 10 <NA>   A1 Marginal Total 3 (tot1)    1      NA
#> 11 <NA>   B1 Marginal Total 3 (tot1)    1      NA
#> 12 <NA> tot1 Marginal Total 3 (tot1)   -1      NA
#> 13   EQ <NA> Marginal Total 4 (tot2)   NA      NA
#> 14 <NA>   A2 Marginal Total 4 (tot2)    1      NA
#> 15 <NA>   B2 Marginal Total 4 (tot2)    1      NA
#> 16 <NA> tot2 Marginal Total 4 (tot2)   -1      NA

# With an alterability coefficients file (argument `alterability_df`)
my_alter = data.frame(B2 = 0.5)
tail(rkMeta_to_blSpecs(my_metadata, alterability_df = my_alter))
#>    type  col                       row coef timeVal
#> 20 <NA>   B1 Period Value Alterability  1.0      NA
#> 21 <NA>   B2 Period Value Alterability  0.5      NA
#> 22 <NA> totA Period Value Alterability  0.0      NA
#> 23 <NA> totB Period Value Alterability  0.0      NA
#> 24 <NA> tot1 Period Value Alterability  0.0      NA
#> 25 <NA> tot2 Period Value Alterability  0.0      NA

# Only include the alterability coefficients from `alterability_df` 
# (i.e., for column `B2` only)
tail(
  rkMeta_to_blSpecs(
    my_metadata, alterability_df = my_alter, 
    alterability_df_only = TRUE
  )
)
#>     type  col                       row coef timeVal
#> 13    EQ <NA>   Marginal Total 4 (tot2)   NA      NA
#> 14  <NA>   A2   Marginal Total 4 (tot2)  1.0      NA
#> 15  <NA>   B2   Marginal Total 4 (tot2)  1.0      NA
#> 16  <NA> tot2   Marginal Total 4 (tot2) -1.0      NA
#> 17 alter <NA> Period Value Alterability   NA      NA
#> 18  <NA>   B2 Period Value Alterability  0.5      NA
```
