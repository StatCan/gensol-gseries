# Restore cross-sectional (contemporaneous) linear constraints

*Replication of the G-Series 2.0 SAS\\^\circledR\\
**GSeriesTSBalancing** macro. See the G-Series 2.0 documentation for
details (Statistics Canada 2016).*

This function balances (reconciles) a system of time series according to
a set of linear constraints. The balancing solution is obtained by
solving one or several quadratic minimization problems (see section
**Details**) with the OSQP solver (Stellato et al. 2020). Given the
feasibility of the balancing problem(s), the resulting time series data
respect the specified constraints for every time period. Linear equality
and inequality constraints are allowed. Optionally, the preservation of
temporal totals may also be specified.

## Usage

``` r
tsbalancing(
  in_ts,
  problem_specs_df,
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1,
  osqp_settings_df = default_osqp_sequence,
  display_level = 1,
  alter_pos = 1,
  alter_neg = 1,
  alter_mix = 1,
  alter_temporal = 0,
  lower_bound = -Inf,
  upper_bound = Inf,
  tolV = 0,
  tolV_temporal = 0,
  tolP_temporal = NA,

  # New in G-Series 3.0
  validation_tol = 0.001,
  trunc_to_zero_tol = validation_tol,
  full_sequence = FALSE,
  validation_only = FALSE,
  quiet = FALSE
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

- osqp_settings_df:

  (optional)

  Data frame (object of class "data.frame") containing a sequence of
  OSQP settings for solving the balancing problems. The package includes
  two predefined OSQP settings sequence data frames:

  - [default_osqp_sequence](https://StatCan.github.io/gensol-gseries/en/reference/osqp_settings_sequence.md):
    fast and effective (default);

  - [alternate_osqp_sequence](https://StatCan.github.io/gensol-gseries/en/reference/osqp_settings_sequence.md):
    geared towards precision at the expense of execution time.

  See
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md)
  for more details on this topic and to see the actual contents of these
  two data frames. Note that the concept of a *solving sequence* with
  different sets of solver settings is new in G-Series 3.0 (a single
  solving attempt was made in G-Series 2.0).

  **Default value** is `osqp_settings_df = default_osqp_sequence`.

- display_level:

  (optional)

  Integer in the \[0 .. 3\] interval specifying the level of information
  to display in the console
  ([`stdout()`](https://rdrr.io/r/base/showConnections.html)). Note that
  specifying argument `quiet = TRUE` would *nullify* argument
  `display_level` (none of the following information would be
  displayed).

  |  |  |  |  |  |
  |----|----|----|----|----|
  | **Displayed information** | **`0`** | **`1`** | **`2`** | **`3`** |
  | Function header | \\\checkmark\\ | \\\checkmark\\ | \\\checkmark\\ | \\\checkmark\\ |
  | Balancing problem elements |  | \\\checkmark\\ | \\\checkmark\\ | \\\checkmark\\ |
  | Individual problem solving details |  |  | \\\checkmark\\ | \\\checkmark\\ |
  | Individual problem results (values and constraints) |  |  |  | \\\checkmark\\ |

  **Default value** is `display_level = 1`.

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

- alter_temporal:

  (optional)

  Nonnegative real number specifying the default alterability
  coefficient associated to the time series temporal totals.
  Alterability coefficients provided in the problem specification data
  frame (argument `problem_specs_df`) override this value.

  **Default value** is `alter_temporal = 0.0` (binding values).

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

- tolV:

  (optional)

  Nonnegative real number specifying the tolerance, in absolute value,
  for the balancing constraints right-hand side (RHS) values:

  - `EQ` constraints: \\\quad A\mathbf{x} = \mathbf{b} \quad\\ become
    \\\quad \mathbf{b} - \epsilon \le A\mathbf{x} \le \mathbf{b} +
    \epsilon\\

  - `LE` constraints: \\\quad A\mathbf{x} \le \mathbf{b} \quad\\ become
    \\\quad A\mathbf{x} \le \mathbf{b} + \epsilon\\

  - `GE` constraints: \\\quad A\mathbf{x} \ge \mathbf{b} \quad\\ become
    \\\quad A\mathbf{x} \ge \mathbf{b} - \epsilon\\

  where \\\epsilon\\ is the tolerance specified with `tolV`. This
  argument does not apply to the *period value (lower and upper) bounds*
  specified with arguments `lower_bound` and `upper_bound` or in the
  problem specs data frame (argument `prob_specs_df`). I.e., `tolV` does
  not affect the time series values lower and upper bounds, unless they
  are specified as *balancing constraints* instead (with `GE` and `LE`
  constraints in the problem specs data frame).

  **Default value** is `tolV = 0.0` (no tolerance).

- tolV_temporal, tolP_temporal:

  (optional)

  Nonnegative real number, or `NA`, specifying the tolerance, in
  percentage (`tolP_temporal`) or absolute value (`tolV_temporal`), for
  the implicit temporal aggregation constraints associated to **binding
  temporal totals** \\\left( \sum_t{x\_{i,t}} = \sum_t{y\_{i,t}}
  \right)\\, which become: \$\$\sum_t{y\_{i,t}} - \epsilon\_\text{abs}
  \le \sum_t{x\_{i,t}} \le \sum_t{y\_{i,t}} + \epsilon\_\text{abs}\$\$
  or \$\$\sum_t{y\_{i,t}} \left( 1 - \epsilon\_\text{rel} \right) \le
  \sum_t{x\_{i,t}} \le \sum_t{y\_{i,t}} \left( 1 + \epsilon\_\text{rel}
  \right)\$\$

  where \\\epsilon\_\text{abs}\\ and \\\epsilon\_\text{rel}\\ are the
  absolute and percentage tolerances specified respectively with
  `tolV_temporal` and `tolP_temporal`. Both arguments cannot be
  specified together (one must be specified while the other must be
  `NA`).

  **Example:** to set a tolerance of 10 *units*, specify
  `tolV_temporal = 10, tolP_temporal = NA`; to set a tolerance of 1%,
  specify`tolV_temporal = NA, tolP_temporal = 0.01`.

  **Default values** are `tolV_temporal = 0.0` and `tolP_temporal = NA`
  (no tolerance).

- validation_tol:

  (optional)

  Nonnegative real number specifying the tolerance for the validation of
  the balancing results. The function verifies if the final (reconciled)
  time series values meet the constraints, allowing for discrepancies up
  to the value specified with this argument. A warning is issued as soon
  as one constraint is not met (discrepancy greater than
  `validation_tol`).

  With constraints defined as \\\mathbf{l} \le A\mathbf{x} \le
  \mathbf{u}\\, where \\\mathbf{l = u}\\ for `EQ` constraints,
  \\\mathbf{l} = -\infty\\ for `LE` constraints and \\\mathbf{u} =
  \infty\\ for `GE` constraints, **constraint discrepancies** correspond
  to \\\max \left( 0, \mathbf{l} - A\mathbf{x}, A\mathbf{x} - \mathbf{u}
  \right)\\, where constraint bounds \\\mathbf{l}\\ and \\\mathbf{u}\\
  include the tolerances, when applicable, specified with arguments
  `tolV`, `tolV_temporal` and `tolP_temporal`.

  **Default value** is `validation_tol = 0.001`.

- trunc_to_zero_tol:

  (optional)

  Nonnegative real number specifying the tolerance, in absolute value,
  for replacing by zero (small) values in the output (reconciled) time
  series data (output object `out_ts`). Specify `trunc_to_zero_tol = 0`
  to disable this *truncation to zero* process on the reconciled data.
  Otherwise, specify `trunc_to_zero_tol > 0` to replace with \\0.0\\ any
  value in the \\\left\[ -\epsilon, \epsilon \right\]\\ interval, where
  \\\epsilon\\ is the tolerance specified with `trunc_to_zero_tol`.

  Note that the final constraint discrepancies (see argument
  `validation_tol`) are calculated on the *zero truncated* reconciled
  time series values, therefore ensuring accurate validation of the
  actual reconciled data returned by the function.

  **Default value** is `trunc_to_zero_tol = validation_tol`.

- full_sequence:

  (optional)

  Logical argument specifying whether all the steps of the *OSQP
  settings sequence data frame* should be performed or not. See argument
  `osqp_settings_df` and
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md)
  for more details on this topic.

  **Default value** is `full_sequence = FALSE`.

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

- quiet:

  (optional)

  Logical argument specifying whether or not to display only essential
  information such as warnings, errors and the period (or set of
  periods) being reconciled. You could further suppress, if desired, the
  display of the *balancing period(s)* information by *wrapping* your
  `tsbalancing()` call with
  [`suppressMessages()`](https://rdrr.io/r/base/message.html). In that
  case, the `proc_grp_df` output data frame can be used to identify
  (unsuccessful) balancing problems associated with warning messages (if
  any). Note that specifying `quiet = TRUE` would also *nullify*
  argument `display_level`.

  **Default value** is `quiet = FALSE`.

## Value

The function returns is a list of seven objects:

- `out_ts`: modified version of the input time series object (class "ts"
  or "mts"; see argument `in_ts`) with the resulting reconciled time
  series values (primary function output). It can be explicitly coerced
  to another type of object with the appropriate `as*()` function (e.g.,
  `tsibble::as_tsibble()` would coerce it to a tsibble).

- `proc_grp_df`: processing group summary data frame, useful to identify
  problems that have succeeded or failed. It contains one observation
  (row) for each balancing problem with the following columns:

  - `proc_grp` (num): processing group id.

  - `proc_grp_type` (chr): processing group type. Possible values are:

    - `"period"`;

    - `"temporal group"`.

  - `proc_grp_label` (chr): string describing the processing group in
    the following format:

    - `"<year>-<period>"` (single periods)

    - `"<start year>-<start period> - <end year>-<end period>"`
      (temporal groups)

  - `sol_status_val`, `sol_status` (num, chr): solution status numerical
    (integer) value and description string:

    - ` 1`: `"valid initial solution"`;

    - `-1`: `"invalid initial solution"`;

    - ` 2`: `"valid polished osqp solution"`;

    - `-2`: `"invalid polished osqp solution"`;

    - ` 3`: `"valid unpolished osqp solution"`;

    - `-3`: `"invalid unpolished osqp solution"`;

    - `-4`: `"unsolvable fixed problem"` (invalid initial solution).

  - `n_unmet_con` (num): number of unmet constraints
    (`sum(prob_conf_df$unmet_flag)`).

  - `max_discr` (num): maximum constraint discrepancy
    (`max(prob_conf_df$discr_out)`).

  - `validation_tol` (num): specified tolerance for validation purposes
    (argument `validation_tol`).

  - `sol_type` (chr): returned solution type. Possible values are:

    - `"initial"` (initial solution, i.e., input data values);

    - `"osqp"` (OSQP solution).

  - `osqp_attempts` (num): number of attempts made with OSQP (depth
    achieved in the solving sequence).

  - `osqp_seqno` (num): step \# of the solving sequence corresponding to
    the returned solution. `NA` when `sol_type = "initial"`.

  - `osqp_status` (chr): OSQP status description string
    (`osqp_sol_info_df$status`). `NA` when `sol_type = "initial"`.

  - `osqp_polished` (logi): `TRUE` if the returned OSQP solution is
    polished (`osqp_sol_info_df$status_polish = 1`), `FALSE` otherwise.
    `NA` when `sol_type = "initial"`.

  - `total_solve_time` (num): total time, in seconds, of the solving
    sequence.

  Column `proc_grp` constitutes a *unique key* (distinct rows) for the
  data frame. Successful balancing problems (problems with a valid
  solution) correspond to rows with `sol_status_val > 0` or,
  equivalently, to `n_unmet_con = 0` or to
  `max_discr <= validation_tol`. The *initial solution*
  (`sol_type = "initial"`) is returned only if **a)** there are no
  initial constraint discrepancies, **b)** the problem is fixed (all
  values are binding) or **c)** it beats the OSQP solution (smaller
  total constraint discrepancies). The OSQP solving sequence is
  described in
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md).

- `periods_df`: time periods data frame, useful to match periods to
  processing groups. It contains one observation (row) for each period
  of the input time series object (argument `in_ts`) with the following
  columns:

  - `proc_grp` (num): processing group id.

  - `t` (num): time id (`1:nrow(in_ts)`).

  - `time_val` (num): time value (`stats::time(in_ts)`). It conceptually
    corresponds to \\year + (period - 1) / frequency\\.

  Columns `t` and `time_val` both constitute a *unique key* (distinct
  rows) for the data frame.

- `prob_val_df`: problem values data frame, useful to analyze change
  diagnostics, i.e., initial vs final (reconciled) values. It contains
  one observation (row) for each value involved in each balancing
  problem, with the following columns:

  - `proc_grp` (num): processing group id.

  - `val_type` (chr): problem value type. Possible values are:

    - `"period value"`;

    - `"temporal total"`.

  - `name` (chr): time series (variable) name.

  - `t` (num): time id (`1:nrow(in_ts)`); id of the first period of the
    temporal group for a *temporal total*.

  - `time_val` (num): time value (`stats::time(in_ts)`); value of the
    first period of the temporal group for a *temporal total*. It
    conceptually corresponds to \\year + (period - 1) / frequency\\.

  - `lower_bd`, `upper_bd` (num): period value bounds; always `-Inf` and
    `Inf` for a *temporal total*.

  - `alter` (num): alterability coefficient.

  - `value_in`, `value_out` (num): initial and final (reconciled)
    values.

  - `dif` (num): `value_out - value_in`.

  - `rdif` (num): `dif / value_in`; `NA` if `value_in = 0`.

  Columns `val_type + name + t` and `val_type + name + time_val` both
  constitute a *unique key* (distinct rows) for the data frame. Binding
  (fixed) problem values correspond to rows with `alter = 0` or
  `value_in = 0`. Conversely, nonbinding (free) problem values
  correspond to rows with `alter != 0` and `value_in != 0`.

- `prob_con_df`: problem constraints data frame, useful for
  troubleshooting problems that failed (identify unmet constraints). It
  contains one observation (row) for each constraint involved in each
  balancing problem, with the following columns:

  - `proc_grp` (num): processing group id.

  - `con_type` (chr): problem constraint type. Possible values are:

    - `"balancing constraint"`;

    - `"temporal aggregation constraint"`;

    - `"period value bounds"`.

    While *balancing constraints* are specicied by the user, the other
    two types of constraints (*temporal aggregation constraints* and
    *period value bounds*) are automatically added to the problem by the
    function (when applicable).

  - `name` (chr): constraint label or time series (variable) name.

  - `t` (num): time id (`1:nrow(in_ts)`); id of the first period of the
    temporal group for a *temporal aggregation constraint*.

  - `time_val` (num): time value (`stats::time(in_ts)`); value of the
    first period of the temporal group for a *temporal aggregation
    constraint*. It conceptually corresponds to \\year + (period - 1) /
    frequency\\.

  - `l`, `u`, `Ax_in`, `Ax_out` (num): initial and final constraint
    elements \\\left( \mathbf{l} \le A \mathbf{x} \le \mathbf{u}
    \right)\\.

  - `discr_in`, `discr_out` (num): initial and final constraint
    discrepancies \\\left( \max \left( 0, \mathbf{l} - A \mathbf{x}, A
    \mathbf{x} - \mathbf{u} \right) \right)\\.

  - `validation_tol` (num): specified tolerance for validation purposes
    (argument `validation_tol`).

  - `unmet_flag` (logi): `TRUE` if the constraint is not met
    (`discr_out > validation_tol`), `FALSE` otherwise.

  Columns `con_type + name + t` and `con_type + name + time_val` both
  constitute a *unique key* (distinct rows) for the data frame.
  Constraint bounds \\\mathbf{l = u}\\ for `EQ` constraints,
  \\\mathbf{l} = -\infty\\ for `LE` constraints, \\\mathbf{u} = \infty\\
  for `GE` constraints, and include the tolerances, when applicable,
  specified with arguments `tolV`, `tolV_temporal` and `tolP_temporal`.

- `osqp_settings_df`: OSQP settings data frame. It contains one
  observation (row) for each problem (processing group) solved with OSQP
  (`proc_grp_df$sol_type = "osqp"`), with the following columns:

  - `proc_grp` (num): processing group id.

  - one column corresponding to each element of the list returned by the
    `osqp::GetParams()` method applied to a *OSQP solver object* (class
    "OSQP_Model" object as returned by
    [`osqp::osqp()`](https://rdrr.io/pkg/osqp/man/osqp.html)), e.g.:

    - Maximum iterations (`max_iter`);

    - Primal and dual infeasibility tolerances (`eps_prim_inf` and
      `eps_dual_inf`);

    - Solution polishing flag (`polishing`);

    - Number of scaling iterations (`scaling`);

    - etc.

  - extra settings specific to `tsbalancing()`:

    - `prior_scaling` (logi): `TRUE` if the problem data were scaled
      (using the average of the free (nonbinding) problem values as the
      scaling factor) prior to solving with OSQP, `FALSE` otherwise.

    - `require_polished` (logi): `TRUE` if a polished solution from OSQP
      (`osqp_sol_info_df$status_polish = 1`) was required for this step
      in order to end the solving sequence, `FALSE` otherwise. See
      [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md)
      for more details on the solving sequence used by `tsbalancing()`.

  Column `proc_grp` constitutes a *unique key* (distinct rows) for the
  data frame. Visit
  <https://osqp.org/docs/interfaces/solver_settings.html> for all
  available OSQP settings. Problems (processing groups) for which the
  initial solution was returned (`proc_grp_df$sol_type = "initial"`) are
  not included in this data frame.

- `osqp_sol_info_df`: OSQP solution information data frame. It contains
  one observation (row) for each problem (processing group) solved with
  OSQP (`proc_grp_df$sol_type = "osqp"`), with the following columns:

  - `proc_grp` (num): processing group id.

  - one column corresponding to each element of the `info` list of a
    *OSQP solver object* (class "OSQP_Model" object as returned by
    [`osqp::osqp()`](https://rdrr.io/pkg/osqp/man/osqp.html)) after
    having been solved with the `osqp::Solve()` method, e.g.:

    - Solution status (`status` and `status_val`);

    - Polishing status (`status_polish`);

    - Number of iterations (`iter`);

    - Objective function value (`obj_val`);

    - Primal and dual residuals (`pri_res` and `dua_res`);

    - Solve time (`solve_time`);

    - etc.

  - extra information specific to `tsbalancing()`:

    - `prior_scaling_factor` (num): value of the scaling factor when
      `osqp_settings_df$prior_scaling = TRUE`
      (`prior_scaling_factor = 1.0` otherwise).

    - `obj_val_ori_prob` (num): original balancing problem's objective
      function value, which is the OSQP objective function value
      (`obj_val`) on the original scale (when
      `osqp_settings_df$prior_scaling = TRUE`) plus the constant term of
      the original balancing problem's objective function, i.e.,
      `obj_val_ori_prob = obj_val * prior_scaling_factor + <constant term>`,
      where `<constant term>` corresponds to \\\mathbf{y}^{\mathrm{T}} W
      \mathbf{y}\\. See section **Details** for the definition of vector
      \\\mathbf{y}\\, matrix \\W\\ and, more generally speaking, the
      complete expression of the balancing problem's objective function.

  Column `proc_grp` constitutes a *unique key* (distinct rows) for the
  data frame. Visit <https://osqp.org> for more information on OSQP.
  Problems (processing groups) for which the initial solution was
  returned (`proc_grp_df$sol_type = "initial"`) are not included in this
  data frame.

Note that the "data.frame" objects returned by the function can be
explicitly coerced to other types of objects with the appropriate
`as*()` function (e.g.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
would coerce any of them to a tibble).

## Details

This function solves one balancing problem per processing group (see
section **Processing groups** for details). Each of these balancing
problems is a quadratic minimization problem of the following form:
\$\$\displaystyle \begin{aligned} &
\underset{\mathbf{x}}{\text{minimize}} & & \mathbf{\left( y - x
\right)}^{\mathrm{T}} W \mathbf{\left( y - x \right)} \\ & \text{subject
to} & & \mathbf{l} \le A \mathbf{x} \le \mathbf{u} \end{aligned} \$\$
where

- \\\mathbf{y}\\ is the vector of the initial problem values, i.e., the
  initial time series period values and, when applicable, temporal
  totals;

- \\\mathbf{x}\\ is the final (reconciled) version of vector
  \\\mathbf{y}\\;

- matrix \\W = \mathrm{diag} \left( \mathbf{w} \right)\\ with vector
  \\\mathbf{w}\\ elements \\w_i = \left\\ \begin{array}{cl} 0 & \text{if
  } \|c_i y_i\| = 0 \\ \frac{1}{\|c_i y_i\|} & \text{otherwise}
  \end{array} \right. \\, where \\c_i\\ is the alterability coefficient
  of problem value \\y_i\\ and cases corresponding to \\\|c_i y_i\| =
  0\\ are fixed problem values (binding period values or temporal
  totals);

- matrix \\A\\ and vectors \\\mathbf{l}\\ and \\\mathbf{u}\\ specify the
  *balancing constraints*, the *implicit temporal total aggregation
  constraints* (when applicable), the *period value (upper and lower)
  bounds* as well as *\\x_i = y_i\\ constraints for fixed \\y_i\\
  values* \\\left( \left\| c_i y_i \right\| = 0 \right)\\.

In practice, the objective function of the problem solved by OSQP
excludes constant term \\\mathbf{y}^{\mathrm{T}} W \mathbf{y}\\,
therefore corresponding to \\\mathbf{x}^{\mathrm{T}} W \mathbf{x} - 2
\left( \mathbf{w} \mathbf{y} \right)^{\mathrm{T}} \mathbf{x}\\, and the
fixed \\y_i\\ values \\\left( \left\| c_i y_i \right\| = 0 \right)\\ are
removed from the problem, adjusting the constraints accordingly, i.e.:

- rows corresponding to the *\\x_i = y_i\\ constraints for fixed \\y_i\\
  values* are removed from \\A\\, \\ \mathbf{l}\\ and \\\mathbf{u}\\;

- columns corresponding to fixed \\y_i\\ values are removed from \\A\\
  while appropriately adjusting \\ \mathbf{l}\\ and \\\mathbf{u}\\.

### Alterability Coefficients

Alterability coefficients are nonnegative numbers that change the
relative cost of modifying an initial problem value. By changing the
actual objective function to minimize, they allow the generation of a
wide range of solutions. Since they appear in the denominator of the
objective function (matrix \\W\\), the larger the alterability
coefficient the less costly it is to modify a problem value (period
value or temporal total) and, conversely, the smaller the alterability
coefficient the more costly it becomes. This results in problem values
with larger alterability coefficients proportionally changing more than
the ones with smaller alterability coefficients. Alterability
coefficients of \\0.0\\ define fixed (binding) problem values while
alterability coefficients greater than \\0.0\\ define free (nonbinding)
values. The default alterability coefficients are \\0.0\\ for temporal
totals (argument `alter_temporal`) and \\1.0\\ for period values
(arguments `alter_pos`, `alter_neg`, `alter_mix`). In the common case of
aggregation table raking problems, the period values of the marginal
totals (time series with a coefficient of \\-1\\ in the balancing
constraints) are usually binding (specified with `alter_neg = 0`) while
the period values of the component series (time series with a
coefficient of \\1\\ in the balancing constraints) are usually
nonbinding (specified with `alter_pos > 0`, e.g., `alter_pos = 1`).
*Almost binding* problem values (e.g., marginal totals or temporal
totals) can be obtained in practice by specifying very small (almost
\\0.0\\) alterability coefficients relative to those of the other
(nonbinding) problem values.

**Temporal total preservation** refers to the fact that temporal totals,
when applicable, are usually kept “as close as possible” to their
initial value. *Pure preservation* is achieved by default with binding
temporal totals while the change is minimized with nonbinding temporal
totals (in accordance with the set of alterability coefficients).

### Validation and troubleshooting

Successful balancing problems (problems with a valid solution) have
`sol_status_val > 0` or, equivalently, `n_unmet_con = 0` or
`max_discr <= validation_tol` in the output `proc_grp_df` data frame.
Troubleshooting unsuccessful balancing problems is not necessarily
straightforward. Following are some suggestions:

- Investigate the failed constraints (`unmet_flag = TRUE` or,
  equivalently, `discr_out > validation_tol` in the output `prob_con_df`
  data frame) to make sure that they do not cause an empty solution
  space (infeasible problem).

- Change the OSQP solving sequence. E.g., try:

  1.  argument `full_sequence = TRUE`

  2.  argument `osqp_settings_df = alternate_osqp_sequence`

  3.  arguments `osqp_settings_df = alternate_osqp_sequence` and
      `full_sequence = TRUE`

  See
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md)
  for more details on this topic.

- Increase (review) the `validation_tol` value. Although this may sound
  like *cheating*, the default `validation_tol` value (\\1 \times
  10^{-3}\\) may actually be too small for balancing problems that
  involve very large values (e.g., in billions) or, conversely, too
  large with very small problem values (e.g, \\\< 1.0\\). Multiplying
  the average scale of the problem data by the *machine tolerance*
  (`.Machine$double.eps`) gives an approximation of the average size of
  the discrepancies that `tsbalancing()` should be able to handle
  (distinguish from \\0\\) and should probably constitute an **absolute
  lower bound** for argument `validation_tol`. In practice, a reasonable
  `validation_tol` value would likely be \\1 \times 10^3\\ to \\1 \times
  10^6\\ times larger than this *lower bound*.

- Address constraints redundancy. Multi-dimensional aggregation table
  raking problems are over-specified (involve redundant constraints)
  when all totals of all dimensions of the *data cube* are binding
  (fixed) and a constraint is defined for all of them. Redundancy also
  occurs for the implicit temporal aggregation constraints in single- or
  multi-dimensional aggregation table raking problems with binding
  (fixed) temporal totals. Over-specification is generally not an issue
  for `tsbalancing()` if the input data are not contradictory with
  regards to the redundant constraints, i.e., if there are no
  inconsistencies (discrepancies) associated to the redundant
  constraints in the input data or if they are *negligible* (reasonably
  small relative to the scale of the problem data). Otherwise, this may
  lead to unsuccessful balancing problems with `tsbalancing()`. Possible
  solutions would then include:

  1.  Resolve (or reduce) the discrepancies associated to the redundant
      constraints in the input data.

  2.  Select one marginal total in every dimension, but one, of the data
      cube and remove the corresponding balancing constraints from the
      problem. *This cannot be done for the implicit temporal
      aggregation constraints*.

  3.  Select one marginal total in every dimension, but one, of the data
      cube and make them nonbinding (alterability coefficient of, say,
      \\1.0\\).

  4.  Do the same as (3) for the temporal totals of one of the
      inner-cube component series (make them nonbinding).

  5.  Make all marginal totals of every dimension, but one, of the data
      cube *amlost binding*, i.e., specify very small alterability
      coefficients (say \\1 \times 10^{-6}\\) compared to those of the
      inner-cube component series.

  6.  Do the same as (5) for the temporal totals of all inner-cube
      component series (very small alterability coefficients, e.g., with
      argument `alter_temporal`).

  7.  Use
      [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
      (if applicable), which handles these inconsistencies by using the
      Moore-Penrose inverse (uniform distribution among all binding
      totals).

  Solutions (2) to (7) above should only be considered if the
  discrepancies associated to the redundant constraints in the input
  data are *reasonably small* as they would be distributed among the
  omitted or nonbinding totals with `tsbalancing()` and all binding
  totals with
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md).
  Otherwise, one should first investigate solution (1) above.

- Relax the bounds of the problem constraints, e.g.:

  - argument `tolV` for the balancing constraints;

  - arguments `tolV_temporal` and `tolP_temporal` for the implicit
    temporal aggregation constraints;

  - arguments `lower_bound` and `upper_bound`.

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

## Comparing [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md) and `tsbalancing()`

- [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  is limited to one- and two-dimensional aggregation table raking
  problems (with temporal total preservation if required) while
  `tsbalancing()` handles more general balancing problems (e.g., higher
  dimensional raking problems, nonnegative solutions, general linear
  equality and inequality constraints as opposed to aggregation rules
  only, etc.).

- [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  returns the generalized least squared solution of the Dagum and
  Cholette regression-based raking model (Dagum and Cholette 2006) while
  `tsbalancing()` solves the corresponding quadratic minimization
  problem using a numerical solver. In most cases, *convergence to the
  minimum* is achieved and the `tsbalancing()` solution matches the
  (exact)
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  least square solution. It may not be the case, however, if convergence
  could not be achieved after a reasonable number of iterations. Having
  said that, only in very rare occasions will the `tsbalancing()`
  solution *significantly* differ from the
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  solution.

- `tsbalancing()` is usually faster than
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md),
  especially for large raking problems, but is generally more sensitive
  to the presence of (small) inconsistencies in the input data
  associated to the redundant constraints of fully specified
  (over-specified) raking problems.
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  handles these inconsistencies by using the Moore-Penrose inverse
  (uniform distribution among all binding totals).

- `tsbalancing()` accommodates the specification of sparse problems in
  their reduced form. This is not true in the case of
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  where aggregation rules must always be fully specified since a
  *complete data cube* without missing data is expected as input (every
  single *inner-cube* component series must contribute to all dimensions
  of the cube, i.e., to every single *outer-cube* marginal total
  series).

- Both tools handle negative values in the input data differently by
  default. While the solutions of raking problems obtained from
  `tsbalancing()` and
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  are identical when all input data points are positive, they will
  differ if some data points are negative (unless argument
  `Vmat_option = 2` is specified with
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)).

- While both `tsbalancing()` and
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  allow the preservation of temporal totals, time management is not
  incorporated in
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md).
  For example, the construction of the processing groups (sets of
  periods of each raking problem) is left to the user with
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  and separate calls must be submitted for each processing group (each
  raking problem). That's where helper function
  [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
  comes in handy with
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md).

- The marginal totals (*outer-cube* marginal total series) returned by
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  are always recalculated as the sum of the relevant component series
  (*inner-cube* component series). The output values of **binding**
  marginal totals may therefore slightly differ from the input values.
  The magnitude of the differences depends on the initial
  inconsistencies (that end up being uniformly distributed by the
  Moore-Penrose inverse). This is not the case for `tsbalancing()` where
  the values of **binding** marginal totals always remain perfectly
  unchanged, potentially resulting in (small) discrepancies between the
  sum of the returned component series and the corresponding marginal
  totals.

- `tsbalancing()` returns the same set of series as the input time
  series object while
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  returns the set of series involved in the raking problem plus those
  specified with argument `id` (which could correspond to a subset of
  the input series).

## References

Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal
Distribution and Reconciliation Methods of Time Series**.
Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
[doi:10.1007/0-387-35439-5](https://doi.org/10.1007/0-387-35439-5)

Ferland, M., S. Fortier and J. Bérubé (2016). "A Mathematical
Optimization Approach to Balancing Time Series: Statistics Canada’s
GSeriesTSBalancing". In **JSM Proceedings, Business and Economic
Statistics Section**. Alexandria, VA: American Statistical Association.
2292-2306.

Ferland, M. (2018). "Time Series Balancing Quadratic Problem — Hessian
matrix and vector of linear objective function coefficients". **Internal
document**. Statistics Canada, Ottawa, Canada.

Quenneville, B. and S. Fortier (2012). "Restoring Accounting Constraints
in Time Series – Methods and Software for a Statistical Agency".
**Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New
York.

SAS Institute Inc. (2015). "The LP Procedure Sparse Data Input Format".
**SAS/OR\\^\circledR\\ 14.1 User's Guide: Mathematical Programming
Legacy Procedures**.
<https://support.sas.com/documentation/cdl/en/ormplpug/68158/HTML/default/viewer.htm#ormplpug_lp_details03.htm>

Statistics Canada (2016). "The ***GSeriesTSBalancing*** Macro".
**G-Series 2.0 User Guide**. Statistics Canada, Ottawa, Canada.

Statistics Canada (2018). **Theory and Application of Reconciliation
(Course code 0437)**. Statistics Canada, Ottawa, Canada.

Stellato, B., G. Banjac, P. Goulart et al. (2020). "OSQP: an operator
splitting solver for quadratic programs". **Math. Prog. Comp. 12**,
637–672 (2020).
[doi:10.1007/s12532-020-00179-2](https://doi.org/10.1007/s12532-020-00179-2)

## See also

[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
[`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/en/reference/rkMeta_to_blSpecs.md)
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.build_proc_grps.md)
[`build_balancing_problem()`](https://StatCan.github.io/gensol-gseries/en/reference/build_balancing_problem.md)
[aliases](https://StatCan.github.io/gensol-gseries/en/reference/aliases.md)

## Examples

``` r
###########
# Example 1: In this first example, the objective is to balance a following simple 
#            accounting table (`Profits = Revenues – Expenses`) for 5 quarters 
#            without modifying `Profits` where `Revenues >= 0` and `Expenses >= 0`.

# Problem specifications
my_specs1 <- data.frame(
  type = c(
    "EQ", rep(NA, 3), 
    "alter", NA, 
    "lowerBd", NA, NA
  ),
  col = c(
    NA, "Revenues", "Expenses", "Profits", 
    NA, "Profits", 
    NA, "Revenues", "Expenses"
  ),
  row = c(
    rep("Accounting Rule", 4), 
    rep("Alterability Coefficient", 2), 
    rep("Lower Bound", 3)
  ),
  coef = c(
    NA, 1, -1, -1,
    NA, 0,
    NA, 0, 0
  )
)
my_specs1
#>      type      col                      row coef
#> 1      EQ     <NA>          Accounting Rule   NA
#> 2    <NA> Revenues          Accounting Rule    1
#> 3    <NA> Expenses          Accounting Rule   -1
#> 4    <NA>  Profits          Accounting Rule   -1
#> 5   alter     <NA> Alterability Coefficient   NA
#> 6    <NA>  Profits Alterability Coefficient    0
#> 7 lowerBd     <NA>              Lower Bound   NA
#> 8    <NA> Revenues              Lower Bound    0
#> 9    <NA> Expenses              Lower Bound    0

# Problem data
my_series1 <- ts(
  matrix(
    c( 15,  10,  10,
        4,   8,  -1,
      250, 250,   5,
        8,  12,   0,
        0,  45, -55
    ),
    ncol = 3,
    byrow = TRUE
  ),
  start = c(2022, 1),
  frequency = 4,
  names = c("Revenues", "Expenses", "Profits")
)

# Reconcile the data
out_balanced1 <- tsbalancing(
  in_ts = my_series1,
  problem_specs_df = my_specs1,
  display_level = 3
)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsbalancing() function:
#>     in_ts                    = my_series1
#>     problem_specs_df         = my_specs1
#>     temporal_grp_periodicity = 1 (default)
#>     temporal_grp_start       (ignored)
#>     osqp_settings_df         = default_osqp_sequence (default)
#>     display_level            = 3
#>     alter_pos                = 1 (default)
#>     alter_neg                = 1 (default)
#>     alter_mix                = 1 (default)
#>     alter_temporal           (ignored)
#>     lower_bound              = -Inf (default)
#>     upper_bound              = Inf (default)
#>     tolV                     = 0 (default)
#>     tolV_temporal            (ignored)
#>     (*)validation_tol        = 0.001 (default)
#>     (*)trunc_to_zero_tol     = validation_tol (default)
#>     (*)validation_only       = FALSE (default)
#>     (*)quiet                 = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Balancing Problem Elements
#> ==========================
#> 
#> 
#>   Balancing Constraints (1)
#>   -------------------------
#> 
#>   Accounting Rule:
#>     Revenues - Expenses - Profits == 0
#> 
#> 
#>   Time Series Info
#>   ----------------
#> 
#>         name lowerBd                 upperBd           alter                
#>   1 Revenues       0 (problem specs)     Inf (default)     1 (default)      
#>   2 Expenses       0 (problem specs)     Inf (default)     1 (default)      
#>   3  Profits    -Inf (default)           Inf (default)     0 (problem specs)
#> 
#> 
#> 
#> Balancing period [2022-1]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 5
#>     - Total discrepancy   = 5
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.3898e+00   7.94e-01   8.11e+01  -6.04e+01   8.11e+01   1.00e-01    8.74e-05s
#>     50  -1.9200e+00   9.38e-11   5.19e-10  -4.56e-10   5.19e-10   1.00e-01    1.84e-04s
#>   plsh  -1.9200e+00   1.11e-16   2.22e-16   1.67e-16   2.22e-16  ---------    2.85e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -1.9200
#>   dual objective:       -1.9200
#>   duality gap:          1.6653e-16
#>   primal-dual integral: 6.0431e+01
#>   run time:             2.85e-04s
#>   optimal rho estimate: 5.49e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 0
#>     - Total discrepancy   = 0
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out dif rdif
#>    Revenues 1     2022        0      Inf     1       15        18   3  0.2
#>    Expenses 1     2022        0      Inf     1       10         8  -2 -0.2
#>     Profits 1     2022     -Inf      Inf     0       10        10   0  0.0
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val  l  u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Accounting Rule 1     2022 10 10     5     10        5         0          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Revenues 1     2022 0 Inf    15     18        0         0          0.001      FALSE
#>    Expenses 1     2022 0 Inf    10      8        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2022-2]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 3
#>     - Total discrepancy   = 3
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.2816e+00   1.57e-01   1.77e+01   2.81e-01   1.77e+01   1.00e-01    7.97e-05s
#>     50  -1.8750e+00   1.33e-11   1.11e-10  -4.76e-11   1.11e-10   1.00e-01    1.93e-04s
#>   plsh  -1.8750e+00   2.78e-17   1.11e-16  -1.39e-16   1.11e-16  ---------    2.87e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -1.8750
#>   dual objective:       -1.8750
#>   duality gap:          -1.3878e-16
#>   primal-dual integral: 2.8069e-01
#>   run time:             2.87e-04s
#>   optimal rho estimate: 5.47e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 8.881784e-16
#>     - Total discrepancy   = 8.881784e-16
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out dif  rdif
#>    Revenues 2  2022.25        0      Inf     1        4         5   1  0.25
#>    Expenses 2  2022.25        0      Inf     1        8         6  -2 -0.25
#>     Profits 2  2022.25     -Inf      Inf     0       -1        -1   0  0.00
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val  l  u Ax_in Ax_out discr_in    discr_out validation_tol unmet_flag
#>    Accounting Rule 2  2022.25 -1 -1    -4     -1        3 8.881784e-16          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Revenues 2  2022.25 0 Inf     4      5        0         0          0.001      FALSE
#>    Expenses 2  2022.25 0 Inf     8      6        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2022-3]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 5
#>     - Total discrepancy   = 5
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.4512e+00   2.00e-02   3.05e+00   3.15e+00   3.15e+00   1.00e-01    8.05e-05s
#>     50  -1.9998e+00   1.70e-12   1.29e-11  -2.60e-13   1.29e-11   1.00e-01    1.86e-04s
#>   plsh  -1.9998e+00   1.73e-17   1.73e-17  -4.41e-17   1.73e-17  ---------    2.88e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -1.9998
#>   dual objective:       -1.9998
#>   duality gap:          -4.4073e-17
#>   primal-dual integral: 3.1527e+00
#>   run time:             2.88e-04s
#>   optimal rho estimate: 5.13e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 0
#>     - Total discrepancy   = 0
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out  dif  rdif
#>    Revenues 3   2022.5        0      Inf     1      250     252.5  2.5  0.01
#>    Expenses 3   2022.5        0      Inf     1      250     247.5 -2.5 -0.01
#>     Profits 3   2022.5     -Inf      Inf     0        5       5.0  0.0  0.00
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val l u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Accounting Rule 3   2022.5 5 5     0      5        5         0          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Revenues 3   2022.5 0 Inf   250  252.5        0         0          0.001      FALSE
#>    Expenses 3   2022.5 0 Inf   250  247.5        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2022-4]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 4
#>     - Total discrepancy   = 4
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.3898e+00   6.04e-03   1.05e+00   3.09e+00   3.09e+00   1.00e-01    5.85e-05s
#>     25  -1.9200e+00   5.09e-08   5.35e-07   3.64e-07   5.35e-07   1.00e-01    1.13e-04s
#>   plsh  -1.9200e+00   0.00e+00   1.11e-16   0.00e+00   1.11e-16  ---------    1.69e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 25
#>   optimal objective:    -1.9200
#>   dual objective:       -1.9200
#>   duality gap:          0.0000e+00
#>   primal-dual integral: 3.0853e+00
#>   run time:             1.69e-04s
#>   optimal rho estimate: 4.88e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 0
#>     - Total discrepancy   = 0
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out  dif rdif
#>    Revenues 4  2022.75        0      Inf     1        8       9.6  1.6  0.2
#>    Expenses 4  2022.75        0      Inf     1       12       9.6 -2.4 -0.2
#>     Profits 4  2022.75     -Inf      Inf     0        0       0.0  0.0   NA
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val l u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Accounting Rule 4  2022.75 0 0    -4      0        4         0          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Revenues 4  2022.75 0 Inf     8    9.6        0         0          0.001      FALSE
#>    Expenses 4  2022.75 0 Inf    12    9.6        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2023-1]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 10
#>     - Total discrepancy   = 10
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 1, constraints m = 2
#>             nnz(P) + nnz(A) = 3
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -6.1701e-02   1.19e+00   1.21e+02  -1.46e+02   1.21e+02   1.00e-01    4.65e-05s
#>     50  -9.5062e-01   1.37e-10   1.41e-10  -1.43e-10   1.41e-10   1.00e-01    1.04e-04s
#>   plsh  -9.5062e-01   0.00e+00   0.00e+00  -1.11e-16   0.00e+00  ---------    1.62e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -0.9506
#>   dual objective:       -0.9506
#>   duality gap:          -1.1102e-16
#>   primal-dual integral: 1.4561e+02
#>   run time:             1.62e-04s
#>   optimal rho estimate: 1.39e-01
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 7.105427e-15
#>     - Total discrepancy   = 7.105427e-15
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out dif      rdif
#>    Revenues 5     2023        0      Inf     1        0         0   0        NA
#>    Expenses 5     2023        0      Inf     1       45        55  10 0.2222222
#>     Profits 5     2023     -Inf      Inf     0      -55       -55   0 0.0000000
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val   l   u Ax_in Ax_out discr_in    discr_out validation_tol unmet_flag
#>    Accounting Rule 5     2023 -55 -55   -45    -55       10 7.105427e-15          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Expenses 5     2023 0 Inf    45     55        0         0          0.001      FALSE
#> 

# Initial data
my_series1
#>         Revenues Expenses Profits
#> 2022 Q1       15       10      10
#> 2022 Q2        4        8      -1
#> 2022 Q3      250      250       5
#> 2022 Q4        8       12       0
#> 2023 Q1        0       45     -55

# Reconciled data
out_balanced1$out_ts
#>         Revenues Expenses Profits
#> 2022 Q1     18.0      8.0      10
#> 2022 Q2      5.0      6.0      -1
#> 2022 Q3    252.5    247.5       5
#> 2022 Q4      9.6      9.6       0
#> 2023 Q1      0.0     55.0     -55

# Check for invalid solutions
any(out_balanced1$proc_grp_df$sol_status_val < 0)
#> [1] FALSE

# Display the maximum output constraint discrepancies
out_balanced1$proc_grp_df[, c("proc_grp_label", "max_discr")]
#>   proc_grp_label    max_discr
#> 1         2022-1 0.000000e+00
#> 2         2022-2 8.881784e-16
#> 3         2022-3 0.000000e+00
#> 4         2022-4 0.000000e+00
#> 5         2023-1 7.105427e-15


# The solution returned by `tsbalancing()` corresponds to equal proportional changes 
# (pro-rating) and is related to the default alterability coefficients of 1. Equal 
# absolute changes could be obtained instead by specifying alterability coefficients 
# equal to the inverse of the initial values. 
#
# Let’s do this for the processing group 2022Q2 (`timeVal = 2022.25`), with the default 
# displayed level of information (`display_level = 1`). 

my_specs1b <- rbind(
  cbind(my_specs1,  data.frame(timeVal = rep(NA_real_, nrow(my_specs1)))),
  data.frame(
    type = rep(NA, 2),
    col = c("Revenues", "Expenses"),
    row = rep("Alterability Coefficient", 2),
    coef = c(0.25, 0.125),
    timeVal = rep(2022.25, 2)
  )
)
my_specs1b
#>       type      col                      row   coef timeVal
#> 1       EQ     <NA>          Accounting Rule     NA      NA
#> 2     <NA> Revenues          Accounting Rule  1.000      NA
#> 3     <NA> Expenses          Accounting Rule -1.000      NA
#> 4     <NA>  Profits          Accounting Rule -1.000      NA
#> 5    alter     <NA> Alterability Coefficient     NA      NA
#> 6     <NA>  Profits Alterability Coefficient  0.000      NA
#> 7  lowerBd     <NA>              Lower Bound     NA      NA
#> 8     <NA> Revenues              Lower Bound  0.000      NA
#> 9     <NA> Expenses              Lower Bound  0.000      NA
#> 10    <NA> Revenues Alterability Coefficient  0.250 2022.25
#> 11    <NA> Expenses Alterability Coefficient  0.125 2022.25

out_balanced1b <- tsbalancing(
  in_ts = my_series1,
  problem_specs_df = my_specs1b
)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsbalancing() function:
#>     in_ts                    = my_series1
#>     problem_specs_df         = my_specs1b
#>     temporal_grp_periodicity = 1 (default)
#>     temporal_grp_start       (ignored)
#>     osqp_settings_df         = default_osqp_sequence (default)
#>     display_level            = 1 (default)
#>     alter_pos                = 1 (default)
#>     alter_neg                = 1 (default)
#>     alter_mix                = 1 (default)
#>     alter_temporal           (ignored)
#>     lower_bound              = -Inf (default)
#>     upper_bound              = Inf (default)
#>     tolV                     = 0 (default)
#>     tolV_temporal            (ignored)
#>     (*)validation_tol        = 0.001 (default)
#>     (*)trunc_to_zero_tol     = validation_tol (default)
#>     (*)validation_only       = FALSE (default)
#>     (*)quiet                 = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Balancing Problem Elements
#> ==========================
#> 
#> 
#>   Balancing Constraints (1)
#>   -------------------------
#> 
#>   Accounting Rule:
#>     Revenues - Expenses - Profits == 0
#> 
#> 
#>   Time Series Info
#>   ----------------
#> 
#>         name lowerBd                 upperBd           alter                  
#>   1 Revenues       0 (problem specs)     Inf (default)     1 * (default)      
#>   2 Expenses       0 (problem specs)     Inf (default)     1 * (default)      
#>   3  Profits    -Inf (default)           Inf (default)     0   (problem specs)
#> 
#>   * indicates cases where period-specific values (`timeVal` is not `NA`) are specified in the problem specs data frame.
#> 
#> 
#> 
#> Balancing period [2022-1]
#> =========================
#> 
#> 
#> Balancing period [2022-2]
#> =========================
#> 
#> 
#> Balancing period [2022-3]
#> =========================
#> 
#> 
#> Balancing period [2022-4]
#> =========================
#> 
#> 
#> Balancing period [2023-1]
#> =========================

# Display the initial 2022Q2 values and both solutions
cbind(
  data.frame(Status = c("initial", "pro-rating", "equal change")),
  rbind(
    as.data.frame(my_series1[2, , drop = FALSE]), 
    as.data.frame(out_balanced1$out_ts[2, , drop = FALSE]),
    as.data.frame(out_balanced1b$out_ts[2, , drop = FALSE])
  ),
  data.frame(
    Accounting_discr = c(
      my_series1[2, 1] - my_series1[2, 2] - my_series1[2, 3],
      out_balanced1$out_ts[2, 1] - out_balanced1$out_ts[2, 2] - 
        out_balanced1$out_ts[2, 3],
      out_balanced1b$out_ts[2, 1] - out_balanced1b$out_ts[2, 2] - 
        out_balanced1b$out_ts[2, 3]
    ),
    RelChg_Rev = c(
      NA, 
      out_balanced1$out_ts[2, 1] / my_series1[2, 1] - 1,
      out_balanced1b$out_ts[2, 1] / my_series1[2, 1] - 1
    ),
    RelChg_Exp = c(
      NA, 
      out_balanced1$out_ts[2, 2] / my_series1[2, 2] - 1,
      out_balanced1b$out_ts[2, 2] / my_series1[2, 2] - 1
    ),
    AbsChg_Rev = c(
      NA, 
      out_balanced1$out_ts[2, 1] - my_series1[2, 1],
      out_balanced1b$out_ts[2, 1] - my_series1[2, 1]
    ),
    AbsChg_Exp = c(
      NA, 
      out_balanced1$out_ts[2, 2] - my_series1[2, 2],
      out_balanced1b$out_ts[2, 2] - my_series1[2, 2]
    )
  )
)
#>         Status Revenues Expenses Profits Accounting_discr RelChg_Rev RelChg_Exp
#> 1      initial      4.0      8.0      -1    -3.000000e+00         NA         NA
#> 2   pro-rating      5.0      6.0      -1     8.881784e-16      0.250    -0.2500
#> 3 equal change      5.5      6.5      -1     0.000000e+00      0.375    -0.1875
#>   AbsChg_Rev AbsChg_Exp
#> 1         NA         NA
#> 2        1.0       -2.0
#> 3        1.5       -1.5


###########
# Example 2: In this second example, consider the simulated data on quarterly 
#            vehicle sales by region (West, Centre and East), along with a national 
#            total for the three regions, and by type of vehicles (cars, trucks and 
#            a total that may include other types of vehicles). The input data correspond 
#            to directly seasonally adjusted data that have been benchmarked to the 
#            annual totals of the corresponding unadjusted time series data as part 
#            of the seasonal adjustment process (e.g., with the FORCE spec in the 
#            X-13ARIMA-SEATS software). 
#
#            The objective is to reconcile the regional sales to the national sales 
#            without modifying the latter while ensuring that the sum of the sales of 
#            cars and trucks do not exceed 95% of the sales for all types of vehicles 
#            in any quarter. For illustrative purposes, we assume that the sales of 
#            trucks in the Centre region for the 2nd quarter of 2022 cannot be modified.

# Problem specifications
my_specs2 <- data.frame(
  
  type = c(
    "EQ", rep(NA, 4),
    "EQ", rep(NA, 4),
    "EQ", rep(NA, 4),
    "LE", rep(NA, 3),
    "LE", rep(NA, 3),
    "LE", rep(NA, 3),
    "alter", rep(NA, 4)
  ),
  
  col = c(
    NA, "West_AllTypes", "Centre_AllTypes", "East_AllTypes", "National_AllTypes", 
    NA, "West_Cars", "Centre_Cars", "East_Cars", "National_Cars", 
    NA, "West_Trucks", "Centre_Trucks", "East_Trucks", "National_Trucks", 
    NA, "West_Cars", "West_Trucks", "West_AllTypes", 
    NA, "Centre_Cars", "Centre_Trucks", "Centre_AllTypes", 
    NA, "East_Cars", "East_Trucks", "East_AllTypes",
    NA, "National_AllTypes", "National_Cars", "National_Trucks", "Centre_Trucks"
  ),
  
  row = c(
    rep("National Total - All Types", 5),
    rep("National Total - Cars", 5),
    rep("National Total - Trucks", 5),
    rep("West Region Sum", 4),
    rep("Center Region Sum", 4),
    rep("East Region Sum", 4),
    rep("Alterability Coefficient", 5)
  ),
  
  coef = c(
    NA, 1, 1, 1, -1,
    NA, 1, 1, 1, -1,
    NA, 1, 1, 1, -1,
    NA, 1, 1, -.95,
    NA, 1, 1, -.95,
    NA, 1, 1, -.95,
    NA, 0, 0, 0, 0
  ),
  
  time_val = c(rep(NA, 31), 2022.25)
)

# Beginning and end of the specifications data frame
head(my_specs2, n = 10)
#>    type               col                        row coef time_val
#> 1    EQ              <NA> National Total - All Types   NA       NA
#> 2  <NA>     West_AllTypes National Total - All Types    1       NA
#> 3  <NA>   Centre_AllTypes National Total - All Types    1       NA
#> 4  <NA>     East_AllTypes National Total - All Types    1       NA
#> 5  <NA> National_AllTypes National Total - All Types   -1       NA
#> 6    EQ              <NA>      National Total - Cars   NA       NA
#> 7  <NA>         West_Cars      National Total - Cars    1       NA
#> 8  <NA>       Centre_Cars      National Total - Cars    1       NA
#> 9  <NA>         East_Cars      National Total - Cars    1       NA
#> 10 <NA>     National_Cars      National Total - Cars   -1       NA
tail(my_specs2)
#>     type               col                      row  coef time_val
#> 27  <NA>     East_AllTypes          East Region Sum -0.95       NA
#> 28 alter              <NA> Alterability Coefficient    NA       NA
#> 29  <NA> National_AllTypes Alterability Coefficient  0.00       NA
#> 30  <NA>     National_Cars Alterability Coefficient  0.00       NA
#> 31  <NA>   National_Trucks Alterability Coefficient  0.00       NA
#> 32  <NA>     Centre_Trucks Alterability Coefficient  0.00  2022.25

# Problem data
my_series2 <- ts(
  matrix(
    c(
      43, 49, 47, 136, 20, 18, 12, 53, 20, 22, 26, 61,
      40, 45, 42, 114, 16, 16, 19, 44, 21, 26, 21, 59,
      35, 47, 40, 133, 14, 15, 16, 50, 19, 25, 19, 71,
      44, 44, 45, 138, 19, 20, 14, 52, 21, 18, 27, 74,
      46, 48, 55, 135, 16, 15, 19, 51, 27, 25, 28, 54
    ),
    ncol = 12,
    byrow = TRUE
  ),
  start = c(2022, 1),
  frequency = 4,
  names = c(
    "West_AllTypes", "Centre_AllTypes", "East_AllTypes", "National_AllTypes", 
    "West_Cars", "Centre_Cars", "East_Cars", "National_Cars", 
    "West_Trucks", "Centre_Trucks", "East_Trucks", "National_Trucks"
  )
)

# Reconcile without displaying the function header and enforce nonnegative data
out_balanced2 <- tsbalancing(
  in_ts                    = my_series2,
  problem_specs_df         = my_specs2,
  temporal_grp_periodicity = frequency(my_series2),
  lower_bound              = 0,
  quiet                    = TRUE
)
#> 
#> 
#> Balancing periods [2022-1 - 2022-4]
#> ===================================
#> 
#> 
#> Balancing period [2023-1]
#> =========================

# Initial data
my_series2
#>         West_AllTypes Centre_AllTypes East_AllTypes National_AllTypes West_Cars
#> 2022 Q1            43              49            47               136        20
#> 2022 Q2            40              45            42               114        16
#> 2022 Q3            35              47            40               133        14
#> 2022 Q4            44              44            45               138        19
#> 2023 Q1            46              48            55               135        16
#>         Centre_Cars East_Cars National_Cars West_Trucks Centre_Trucks
#> 2022 Q1          18        12            53          20            22
#> 2022 Q2          16        19            44          21            26
#> 2022 Q3          15        16            50          19            25
#> 2022 Q4          20        14            52          21            18
#> 2023 Q1          15        19            51          27            25
#>         East_Trucks National_Trucks
#> 2022 Q1          26              61
#> 2022 Q2          21              59
#> 2022 Q3          19              71
#> 2022 Q4          27              74
#> 2023 Q1          28              54

# Reconciled data
out_balanced2$out_ts
#>         West_AllTypes Centre_AllTypes East_AllTypes National_AllTypes West_Cars
#> 2022 Q1      42.10895        47.63734      46.25371               136  21.15646
#> 2022 Q2      35.31121        41.40859      37.28019               114  14.00517
#> 2022 Q3      38.89464        50.58071      43.52465               133  15.24054
#> 2022 Q4      45.68520        45.37335      46.94145               138  18.59783
#> 2023 Q1      41.67785        43.48993      49.83221               135  16.32000
#>         Centre_Cars East_Cars National_Cars West_Trucks Centre_Trucks
#> 2022 Q1    19.13355  12.70999            53    18.56134      18.59359
#> 2022 Q2    13.33816  16.65666            44    16.61497      26.00000
#> 2022 Q3    16.84858  17.91088            50    21.70936      27.22926
#> 2022 Q4    19.67970  13.72247            52    24.11433      19.17715
#> 2023 Q1    15.30000  19.38000            51    18.22500      16.87500
#>         East_Trucks National_Trucks
#> 2022 Q1    23.84507              61
#> 2022 Q2    16.38503              59
#> 2022 Q3    22.06138              71
#> 2022 Q4    30.70852              74
#> 2023 Q1    18.90000              54

# Check for invalid solutions
any(out_balanced2$proc_grp_df$sol_status_val < 0)
#> [1] FALSE

# Display the maximum output constraint discrepancies
out_balanced2$proc_grp_df[, c("proc_grp_label", "max_discr")]
#>    proc_grp_label    max_discr
#> 1 2022-1 - 2022-4 2.842171e-14
#> 2          2023-1 0.000000e+00


###########
# Example 3: Reproduce the `tsraking_driver()` 2nd example with `tsbalancing()` 
#            (1-dimensional raking problem with annual total preservation).

# `tsraking()` metadata
my_metadata3 <- data.frame(
  series = c("cars_alb", "cars_sask", "cars_man"),
  total1 = rep("cars_tot", 3)
)
my_metadata3
#>      series   total1
#> 1  cars_alb cars_tot
#> 2 cars_sask cars_tot
#> 3  cars_man cars_tot

# `tsbalancing()` problem specifications
my_specs3 <- rkMeta_to_blSpecs(my_metadata3)
my_specs3
#>     type       col                         row coef timeVal
#> 1     EQ      <NA> Marginal Total 1 (cars_tot)   NA      NA
#> 2   <NA>  cars_alb Marginal Total 1 (cars_tot)    1      NA
#> 3   <NA> cars_sask Marginal Total 1 (cars_tot)    1      NA
#> 4   <NA>  cars_man Marginal Total 1 (cars_tot)    1      NA
#> 5   <NA>  cars_tot Marginal Total 1 (cars_tot)   -1      NA
#> 6  alter      <NA>   Period Value Alterability   NA      NA
#> 7   <NA>  cars_alb   Period Value Alterability    1      NA
#> 8   <NA> cars_sask   Period Value Alterability    1      NA
#> 9   <NA>  cars_man   Period Value Alterability    1      NA
#> 10  <NA>  cars_tot   Period Value Alterability    0      NA

# Problem data
my_series3 <- ts(
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

# Reconcile the data with `tsraking()` (through `tsraking_driver()`)
out_raked3 <- tsraking_driver(
  in_ts = my_series3,
  metadata_df = my_metadata3,
  temporal_grp_periodicity = frequency(my_series3),
  quiet = TRUE
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

# Reconcile the data with `tsbalancing()`
out_balanced3 <- tsbalancing(
  in_ts = my_series3,
  problem_specs_df = my_specs3,
  temporal_grp_periodicity = frequency(my_series3),
  quiet = TRUE
)
#> 
#> 
#> Balancing period [2019-2]
#> =========================
#> 
#> 
#> Balancing period [2019-3]
#> =========================
#> 
#> 
#> Balancing period [2019-4]
#> =========================
#> 
#> 
#> Balancing periods [2020-1 - 2020-4]
#> ===================================
#> 
#> 
#> Balancing period [2021-1]
#> =========================

# Initial data
my_series3
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2       14        18       14       58
#> 2019 Q3       17        14       16       44
#> 2019 Q4       14        19       18       58
#> 2020 Q1       20        18       12       53
#> 2020 Q2       16        16       19       44
#> 2020 Q3       14        15       16       50
#> 2020 Q4       19        20       14       52
#> 2021 Q1       16        15       19       51

# Both sets of reconciled data
out_raked3
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2 17.65217  22.69565 17.65217       58
#> 2019 Q3 15.91489  13.10638 14.97872       44
#> 2019 Q4 15.92157  21.60784 20.47059       58
#> 2020 Q1 21.15283  19.04513 12.80204       53
#> 2020 Q2 13.74700  13.75373 16.49927       44
#> 2020 Q3 15.50782  16.62184 17.87034       50
#> 2020 Q4 18.59234  19.57931 13.82835       52
#> 2021 Q1 16.32000  15.30000 19.38000       51
out_balanced3$out_ts
#>         cars_alb cars_sask cars_man cars_tot
#> 2019 Q2 17.65217  22.69565 17.65217       58
#> 2019 Q3 15.91489  13.10638 14.97872       44
#> 2019 Q4 15.92157  21.60784 20.47059       58
#> 2020 Q1 21.15283  19.04513 12.80204       53
#> 2020 Q2 13.74700  13.75373 16.49927       44
#> 2020 Q3 15.50782  16.62184 17.87034       50
#> 2020 Q4 18.59234  19.57931 13.82835       52
#> 2021 Q1 16.32000  15.30000 19.38000       51

# Check for invalid `tsbalancing()` solutions
any(out_balanced3$proc_grp_df$sol_status_val < 0)
#> [1] FALSE

# Display the maximum output constraint discrepancies from the `tsbalancing()` solutions
out_balanced3$proc_grp_df[, c("proc_grp_label", "max_discr")]
#>    proc_grp_label    max_discr
#> 1          2019-2 0.000000e+00
#> 2          2019-3 0.000000e+00
#> 3          2019-4 0.000000e+00
#> 4 2020-1 - 2020-4 1.421085e-14
#> 5          2021-1 0.000000e+00

# Confirm that both solutions (`tsraking() and `tsbalancing()`) are the same
all.equal(out_raked3, out_balanced3$out_ts)
#> [1] TRUE
```
