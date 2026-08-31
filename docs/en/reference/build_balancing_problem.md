# Build the elements of balancing problems.

This function is used internally by
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
to build the elements of the balancing problems. It can also be useful
to derive the indirect series associated to equality balancing
constraints manually (outside of the
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
context).

## Usage

``` r
build_balancing_problem(
  in_ts,
  problem_specs_df,
  in_ts_name = deparse1(substitute(in_ts)),
  ts_freq = stats::frequency(in_ts),
  periods = gs.time2str(in_ts),
  n_per = nrow(as.matrix(in_ts)),
  specs_df_name = deparse1(substitute(problem_specs_df)),
  temporal_grp_periodicity = 1,
  alter_pos = 1,
  alter_neg = 1,
  alter_mix = 1,
  lower_bound = -Inf,
  upper_bound = Inf,
  validation_only = FALSE
)
```

## Arguments

- in_ts:

  (mandatory)

  Time series (object of class "ts" or "mts") that contains the time
  series data to be reconciled. They are the balancing problems' input
  data (initial solutions).

- problem_specs_df:

  (mandatory)

  Balancing problem specifications data frame (object of class
  "data.frame"). Using a sparse format inspired from the
  SAS/OR\\^\circledR\\ LP procedure’s *sparse data input format* (SAS
  Institute 2015), it contains only the relevant information such as the
  nonzero coefficients of the balancing constraints as well as the
  non-default alterability coefficients and lower/upper bounds (i.e.,
  values that would take precedence over those defined with arguments
  `alter_pos`, `alter_neg`, `alter_mix`, `alter_temporal`, `lower_bound`
  and `upper_bound`).

  The information is provided using four mandatory variables (`type`,
  `col`, `row` and `coef`) and one optional variable (`timeVal`). An
  observation (a row) in the problem specs data frame either defines a
  label for one of the seven types of the balancing problem elements
  with columns `type` and `row` (see *Label definition records* below)
  or specifies coefficients (numerical values) for those balancing
  problem elements with variables `col`, `row`, `coef` and `timeVal`
  (see *Information specification records* below).

  - **Label definition records** (`type` is not missing (is not `NA`))

    - `type` (chr): reserved keyword identifying the type of problem
      element being defined:

      - `EQ`: equality (\\=\\) balancing constraint

      - `LE`: lower or equal (\\\le\\) balancing constraint

      - `GE`: greater or equal (\\\ge\\) balancing constraint

      - `lowerBd`: period value lower bound

      - `upperBd`: period value upper bound

      - `alter`: period values alterability coefficient

      - `alterTmp`: temporal total alterability coefficient

    - `row` (chr): label to be associated to the problem element
      (*`type` keyword*)

    - *all other variables are irrelevant and should contain missing
      data (`NA` values)*  
        

  - **Information specification records** (`type` is missing (is `NA`))

    - `type` (chr): not applicable (`NA`)

    - `col` (chr): series name or reserved word `_rhs_` to specify a
      balancing constraint right-hand side (RHS) value.

    - `row` (chr): problem element label.

    - `coef` (num): problem element value:

      - balancing constraint series coefficient or RHS value

      - series period value lower or upper bound

      - series period value or temporal total alterability coefficient

    - `timeVal` (num): optional time value to restrict the application
      of series bounds or alterability coefficients to a specific time
      period (or temporal group). It corresponds to the time value, as
      returned by [`stats::time()`](https://rdrr.io/r/stats/time.html),
      of a given input time series (argument `in_ts`) period
      (observation) and is conceptually equivalent to \\year +
      (period - 1) / frequency\\.

  Note that empty strings (`""` or `''`) for character variables are
  interpreted as missing (`NA`) by the function. Variable `row`
  identifies the elements of the balancing problem and is the key
  variable that makes the link between both types of records. The same
  label (`row`) cannot be associated with more than one type of problem
  element (`type`) and multiple labels (`row`) cannot be defined for the
  same given type of problem element (`type`), except for balancing
  constraints (values `"EQ"`, `"LE"` and `"GE"` of column `type`).
  User-friendly features of the problem specs data frame include:

  - The order of the observations (rows) is not important.

  - Character values (variables `type`, `row` and `col`) are not case
    sensitive (e.g., strings `"Constraint 1"` and `"CONSTRAINT 1"` for
    `row` would be considered as the same problem element label), except
    when `col` is used to specify a series name (a column of the input
    time series object) where **case sensitivity is enforced**.

  - The variable names of the problem specs data frame are also not case
    sensitive (e.g., `type`, `Type` or `TYPE` are all valid) and
    `time_val` is an accepted variable name (instead of `timeVal`).

  Finally, the following table lists valid aliases for the *`type`
  keywords* (type of problem element):

  |  |  |
  |----|----|
  | **Keyword** | **Aliases** |
  | `EQ` | `==`, `=` |
  | `LE` | `<=`, `<` |
  | `GE` | `>=`, `>` |
  | `lowerBd` | `lowerBound`, `lowerBnd`, + *same terms with '\_', '.' or ' ' between words* |
  | `upperBd` | `upperBound`, `upperBnd`, + *same terms with '\_', '.' or ' ' between words* |
  | `alterTmp` | `alterTemporal`, `alterTemp`, + *same terms with '\_', '.' or ' ' between words* |

  Reviewing the **Examples** should help conceptualize the balancing
  problem specifications data frame.

- in_ts_name:

  (optional)

  String containing the value of argument `in_ts`.

  **Default value** is `in_ts_name = deparse1(substitute(in_ts))`.

- ts_freq:

  (optional)

  Frequency of the time series object (argument `in_ts`).

  **Default value** is `ts_freq = stats::frequency(in_ts)`.

- periods:

  (optional)

  Character vector describing the time series object (argument `in_ts`)
  periods.

  **Default value** is `periods = gs.time2str(in_ts)`.

- n_per:

  (optional)

  Number of periods of the time series object (argument `in_ts`).

  **Default value** is `n_per = nrow(as.matrix(in_ts))`.

- specs_df_name:

  (optional)

  String containing the value of argument `problem_specs_df`.

  **Default value** is
  `specs_df_name = deparse1(substitute(problem_specs_df))`.

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

- alter_pos:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient associated to the values of time series with **positive**
  coefficients in all balancing constraints in which they are involved
  (e.g., component series in aggregation table raking problems).
  Alterability coefficients provided in the problem specification data
  frame (argument `problem_specs_df`) override this value.

  **Default value** is `alter_pos = 1.0` (nonbinding values).

- alter_neg:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient associated to the values of time series with **negative**
  coefficients in all balancing constraints in which they are involved
  (e.g., marginal totals in aggregation table raking problems).
  Alterability coefficients provided in the problem specification data
  frame (argument `problem_specs_df`) override this value.

  **Default value** is `alter_neg = 1.0` (nonbinding values).

- alter_mix:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient associated to the values of time series with a mix of
  **positive and negative** coefficients in the balancing constraints in
  which they are involved. Alterability coefficients provided in the
  problem specification data frame (argument `problem_specs_df`)
  override this value.

  **Default value** is `alter_mix = 1.0` (nonbinding values).

- lower_bound:

  (optional)

  Real number specifying the default lower bound for the time series
  values. Lower bounds provided in the problem specification data frame
  (argument `problem_specs_df`) override this value.

  **Default value** is `lower_bound = -Inf` (unbounded).

- upper_bound:

  (optional)

  Real number specifying the default upper bound for the time series
  values. Upper bounds provided in the problem specification data frame
  (argument `problem_specs_df`) override this value.

  **Default value** is `upper_bound = Inf` (unbounded).

- validation_only:

  (optional)

  Logical argument specifying whether the function should only perform
  input data validation or not. When `validation_only = TRUE`, the
  specified *balancing constraints* and *period value (lower and upper)
  bounds* constraints are validated against the input time series data,
  allowing for discrepancies up to the value specified with argument
  `validation_tol`. Otherwise, when `validation_only = FALSE` (default),
  the input data are first reconciled and the resulting (output) data
  are then validated.

  **Default value** is `validation_only = FALSE`.

## Value

A list with the elements of the balancing problems (excluding the
temporal totals info):

- `labels_df`: cleaned-up version of the *label definition records* from
  `problem_specs_df` (`type` is not missing (is not `NA`)); extra
  columns:

  - `type.lc` : `tolower(type)`

  - `row.lc` : `tolower(row)`

  - `con.flag`: `type.lc %in% c("eq", "le", "ge")`

- `coefs_df` : cleaned-up version of the information specification
  records from `problem_specs_df` (`type` is missing (is `NA`); extra
  columns:

  - `row.lc` : `tolower(row)`

  - `con.flag`: `labels_df$con.flag` allocated through `row.lc`

- `values_ts`: reduced version of `in_ts` with only the relevant series
  (see vector `ser_names`)

- `lb` : lower bound info (`type.lc = "lowerbd"`) for the relevant
  series; list object with the following elements:

  - `coefs_ts` : lower bound values for series and period

  - `nondated_coefs` : vector of nondated lower bounds from
    `problem_specs_df` (`timeVal` is `NA`)

  - `nondated_id_vec`: vector of `ser_names` id's associated to vector
    `nondated_coefs`

  - `dated_id_vec` : vector of `ser_names` id's associated to dated
    lower bounds from `problem_specs_df` (`timeVal` is not `NA`)

- `ub` : `lb` equivalent for upper bounds (`type.lc = "upperbd"`)

- `alter` : `lb` equivalent for period value alterability coefficients
  (`type.lc = "alter"`)

- `altertmp` : `lb` equivalent for temporal total alterability
  coefficients (`type.lc = "altertmp"`)

- `ser_names`: vector of the relevant series names (set of series
  involved in the balancing constraints)

- `pos_ser` : vector of series names that have only positive nonzero
  coefficients across all balancing constraints

- `neg_ser` : vector of series names that have only negative nonzero
  coefficients across all balancing constraints

- `mix_ser` : vector of series names that have both positive and
  negative nonzero coefficients across all balancing constraints

- `A1`,`op1`,`b1`: balancing constraint elements for problems involving
  a single period (e.g., each period of an incomplete temporal group)

- `A2`,`op2`,`b2`: balancing constraint elements for problems involving
  `temporal_grp_periodicity` periods (e.g., the set of periods of a
  complete temporal group)

## Details

See
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
for a detailed description of *time series balancing* problems.

Any missing (`NA`) value found in the input time series object (argument
`in_ts`) would be replaced with 0 in `values_ts` and trigger a warning
message.

The returned elements of the balancing problems do not include the
implicit temporal totals (i.e., elements `A2`, `op2` and `b2` only
contain the balancing constraints).

Multi-period balancing problem elements `A2`, `op2` and `b2` (when
`temporal_grp_periodicity > 1`) are constructed *column by column* (in
"column-major order"), corresponding to the default behaviour of R for
converting objects of class "matrix" into vectors. I.e., the balancing
constraints conceptually correspond to:

- `A1 %*% values_ts[t, ] op1 b1` for problems involving a single period
  (`t`)

- `A2 %*% as.vector(values_ts[t1:t2, ]) op2 b2` for problems involving
  `temporal_grp_periodicity` periods (`t1:t2`).

Notes:

- Argument `alter_temporal` has not been applied yet at this point and
  `altertmp$coefs_ts` only contains the coefficients specified in the
  problem specs data frame (argument `problem_specs_df`). I.e.,
  `altertmp$coefs_ts` contains missing (`NA`) values except for the
  temporal total alterability coefficients included in (specified with)
  `problem_specs_df`. This is done in order to simplify the
  identification of the first non missing (non `NA`) temporal total
  alterability coefficient of each complete temporal group (to occur
  later, when applicable, inside
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)).

- Argument validation is not performed here; it is (bluntly) assumed
  that the function is called by
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  where a thorough validation of the arguments is done.

## See also

[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
[`build_raking_problem()`](https://StatCan.github.io/gensol-gseries/en/reference/build_raking_problem.md)

## Examples

``` r
######################################################################################
#        Indirect series derivation framework with `tsbalancing()` metadata
######################################################################################
#
# Is is assumed (agreed) that...
#
# a) All balancing constraints are equality constraints (`type = EQ`).
# b) All constraints have only one nonbinding (free) series: the series to be derived
#    (i.e., all series have an alter. coef of 0 except the series to be derived).
# c) Each constraint derives a different (new) series.
# d) Constraints are the same for all periods (i.e., no "dated" alter. coefs 
#    specified with column `timeVal`).
######################################################################################


# Derive the 5 marginal totals of a 2 x 3 two-dimensional data cube using `tsbalancing()` 
# metadata (data cube aggregation constraints respect the above assumptions).


# Build the balancing problem specs through the (simpler) raking metadata.
my_specs <- rkMeta_to_blSpecs(
  data.frame(
    series = c(
      "A1", "A2", "A3",
      "B1", "B2", "B3"
    ),
    total1 = c(
      rep("totA", 3),
      rep("totB", 3)
    ),
    total2 = rep(c("tot1", "tot2", "tot3"), 2)
  ),
  alterSeries = 0,  # binding (fixed) component series
  alterTotal1 = 1,  # nonbinding (free) marginal totals (to be derived)
  alterTotal2 = 1)  # nonbinding (free) marginal totals (to be derived)
my_specs
#>     type  col                       row coef timeVal
#> 1     EQ <NA>   Marginal Total 1 (totA)   NA      NA
#> 2   <NA>   A1   Marginal Total 1 (totA)    1      NA
#> 3   <NA>   A2   Marginal Total 1 (totA)    1      NA
#> 4   <NA>   A3   Marginal Total 1 (totA)    1      NA
#> 5   <NA> totA   Marginal Total 1 (totA)   -1      NA
#> 6     EQ <NA>   Marginal Total 2 (totB)   NA      NA
#> 7   <NA>   B1   Marginal Total 2 (totB)    1      NA
#> 8   <NA>   B2   Marginal Total 2 (totB)    1      NA
#> 9   <NA>   B3   Marginal Total 2 (totB)    1      NA
#> 10  <NA> totB   Marginal Total 2 (totB)   -1      NA
#> 11    EQ <NA>   Marginal Total 3 (tot1)   NA      NA
#> 12  <NA>   A1   Marginal Total 3 (tot1)    1      NA
#> 13  <NA>   B1   Marginal Total 3 (tot1)    1      NA
#> 14  <NA> tot1   Marginal Total 3 (tot1)   -1      NA
#> 15    EQ <NA>   Marginal Total 4 (tot2)   NA      NA
#> 16  <NA>   A2   Marginal Total 4 (tot2)    1      NA
#> 17  <NA>   B2   Marginal Total 4 (tot2)    1      NA
#> 18  <NA> tot2   Marginal Total 4 (tot2)   -1      NA
#> 19    EQ <NA>   Marginal Total 5 (tot3)   NA      NA
#> 20  <NA>   A3   Marginal Total 5 (tot3)    1      NA
#> 21  <NA>   B3   Marginal Total 5 (tot3)    1      NA
#> 22  <NA> tot3   Marginal Total 5 (tot3)   -1      NA
#> 23 alter <NA> Period Value Alterability   NA      NA
#> 24  <NA>   A1 Period Value Alterability    0      NA
#> 25  <NA>   A2 Period Value Alterability    0      NA
#> 26  <NA>   A3 Period Value Alterability    0      NA
#> 27  <NA>   B1 Period Value Alterability    0      NA
#> 28  <NA>   B2 Period Value Alterability    0      NA
#> 29  <NA>   B3 Period Value Alterability    0      NA
#> 30  <NA> totA Period Value Alterability    1      NA
#> 31  <NA> totB Period Value Alterability    1      NA
#> 32  <NA> tot1 Period Value Alterability    1      NA
#> 33  <NA> tot2 Period Value Alterability    1      NA
#> 34  <NA> tot3 Period Value Alterability    1      NA

# 6 periods (quarters) of data with marginal totals set to zero (0): they MUST exist
# in the input data AND contain valid (non missing) data.
my_ts <- ts(
  data.frame(
    A1 = c(12, 10, 12,  9, 15,  7),
    B1 = c(20, 21, 15, 17, 19, 18),
    A2 = c(14,  9,  8,  9, 11, 10),
    B2 = c(20, 29, 20, 24, 21, 17),
    A3 = c(13, 15, 17, 14, 16, 12),
    B3 = c(24, 20, 30, 23, 21, 19),
    tot1 = rep(0, 6),
    tot2 = rep(0, 6),
    tot3 = rep(0, 6),
    totA = rep(0, 6),
    totB = rep(0, 6)
  ),
  start = 2019, frequency = 4
)

# Get the balancing problem elements.
n_per <- nrow(my_ts)
p <- build_balancing_problem(
  my_ts, my_specs, 
  temporal_grp_periodicity = n_per
)

# `A2`, `op2` and `b2` define 30 constraints (5 marginal totals X 6 periods) 
# involving a total of 66 time series data points (11 series X 6 periods) of which 
# 36 belong to the 6 component series and 30 belong to the 5 marginal totals.
dim(p$A2)
#> [1] 30 66

# Get the names of the marginal totals (series with a nonzero alter. coef), in the order 
# in which the corresponding constraints appear in the specs (constraints specification 
# order).
tmp <- p$coefs_df$col[p$coefs_df$con.flag]
tot_names <- tmp[
  tmp %in% p$ser_names[p$alter$nondated_id_vec[p$alter$nondated_coefs != 0]]
]

# Define logical flags identifying the marginal total columns:
# - `tot_col_logi1`: for single-period elements (of length 11 = number of series)
# - `tot_col_logi2`: for multi-period elements (of length 66 = number of data points), 
#                    in "column-major order" (the `A2` matrix element construction order)
tot_col_logi1 <- p$ser_names %in% tot_names
tot_col_logi2 <- rep(tot_col_logi1, each = n_per)

# Order of the marginal totals to be derived based on
# ... the input data columns ("mts" object `my_ts`)
p$ser_names[tot_col_logi1]
#> [1] "tot1" "tot2" "tot3" "totA" "totB"
# ... the constraints specification (data frame `my_specs`)
tot_names
#> [1] "totA" "totB" "tot1" "tot2" "tot3"


# Calculate the 5 marginal totals for all 6 periods
# Note: the following calculation allows for general linear equality constraints, i.e.,
#       a) nonzero right-hand side (RHS) constraint values (`b2`) and 
#       b) nonzero constraint coefs other than 1 for the component series and -1 for 
#          the derived series.
my_ts[, tot_names] <- {
  (
    # Constraints RHS.
    p$b2 - 

    # Sums of the components ("weighted" by the constraint coefficients).
    p$A2[, !tot_col_logi2, drop = FALSE] %*% as.vector(p$values_ts[, !tot_col_logi1])
  ) /

  # Derived series constraint coefficients: `t()` allows for a "row-major order" search 
  # in matrix `A2` (i.e., according to the constraints specification order).
  # Note: `diag(p$A2[, tot_col_logi2])` would work if `p$ser_names[tot_col_logi1]` and 
  #       `tot_names` were identical (same totals order); however, the following search 
  #       in "row-major order" will always work (and is necessary in the current case).
  t(p$A2[, tot_col_logi2])[t(p$A2[, tot_col_logi2]) != 0]
}
my_ts
#>         A1 B1 A2 B2 A3 B3 tot1 tot2 tot3 totA totB
#> 2019 Q1 12 20 14 20 13 24   32   34   37   39   64
#> 2019 Q2 10 21  9 29 15 20   31   38   35   34   70
#> 2019 Q3 12 15  8 20 17 30   27   28   47   37   65
#> 2019 Q4  9 17  9 24 14 23   26   33   37   32   64
#> 2020 Q1 15 19 11 21 16 21   34   32   37   42   61
#> 2020 Q2  7 18 10 17 12 19   25   27   31   29   54
```
