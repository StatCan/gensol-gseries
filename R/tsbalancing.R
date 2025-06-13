#' Restore cross-sectional (contemporaneous) linear constraints
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.html}})}
#' 
#' \emph{Replication of the G-Series 2.0 SAS\eqn{^\circledR}{®} \strong{GSeriesTSBalancing} macro. See the
#' G-Series 2.0 documentation for details (Statistics Canada 2016).}
#'
#' This function balances (reconciles) a system of time series according to a set of linear constraints. The balancing 
#' solution is obtained by solving one or several quadratic minimization problems (see section **Details**) with the OSQP 
#' solver (Stellato et al. 2020). Given the feasibility of the balancing problem(s), the resulting time series data respect 
#' the specified constraints for every time period. Linear equality and inequality constraints are allowed. Optionally, the 
#' preservation of temporal totals may also be specified.
#' 
#' 
#' @usage
#' tsbalancing(
#'   in_ts,
#'   problem_specs_df,
#'   temporal_grp_periodicity = 1,
#'   temporal_grp_start = 1,
#'   osqp_settings_df = default_osqp_sequence,
#'   display_level = 1,
#'   alter_pos = 1,
#'   alter_neg = 1,
#'   alter_mix = 1,
#'   alter_temporal = 0,
#'   lower_bound = -Inf,
#'   upper_bound = Inf,
#'   tolV = 0,
#'   tolV_temporal = 0,
#'   tolP_temporal = NA,
#'
#'   # New in G-Series 3.0
#'   validation_tol = 0.001,
#'   trunc_to_zero_tol = validation_tol,
#'   full_sequence = FALSE,
#'   validation_only = FALSE,
#'   quiet = FALSE
#' )
#' 
#'
#' @param in_ts (mandatory) 
#' 
#' Time series (object of class "ts" or "mts") that contains the time series data to be reconciled. 
#' They are the balancing problems' input data (initial solutions).
#' 
#' @param problem_specs_df (mandatory) 
#' 
#' Balancing problem specifications data frame (object of class "data.frame"). Using a sparse format inspired from the 
#' SAS/OR\eqn{^\circledR}{®} LP procedure’s *sparse data input format* (SAS Institute 2015), it contains only the relevant 
#' information such as the nonzero coefficients of the balancing constraints as well as the non-default alterability 
#' coefficients and lower/upper bounds (i.e., values that would take precedence over those defined with arguments `alter_pos`, 
#' `alter_neg`, `alter_mix`, `alter_temporal`, `lower_bound` and `upper_bound`).
#' 
#' The information is provided using four mandatory variables (`type`, `col`, `row` and `coef`) and one optional variable 
#' (`timeVal`). An observation (a row) in the problem specs data frame either defines a label for one of the seven types of the 
#' balancing problem elements with columns `type` and `row` (see *Label definition records* below) or specifies coefficients 
#' (numerical values) for those balancing problem elements with variables `col`, `row`, `coef` and `timeVal` (see *Information 
#' specification records* below).
#' 
#' * **Label definition records** (`type` is not missing (is not `NA`))
#' 
#'   * `type` (chr): reserved keyword identifying the type of problem element being defined: 
#'     * `EQ`: equality (\eqn{=}) balancing constraint
#'     * `LE`: lower or equal (\eqn{\le}{<=}) balancing constraint
#'     * `GE`: greater or equal (\eqn{\ge}{>=}) balancing constraint 
#'     * `lowerBd`: period value lower bound
#'     * `upperBd`: period value upper bound
#'     * `alter`: period values alterability coefficient
#'     * `alterTmp`: temporal total alterability coefficient
#'   * `row` (chr): label to be associated to the problem element (_`type` keyword_)
#'   * _all other variables are irrelevant and should contain missing data (`NA` values)_ \cr \cr
#' 
#' * **Information specification records** (`type` is missing (is `NA`))
#' 
#'   * `type` (chr): not applicable (`NA`)
#'   * `col` (chr): series name or reserved word `_rhs_` to specify a balancing constraint right-hand side (RHS) value.
#'   * `row` (chr): problem element label.
#'   * `coef` (num): problem element value:
#'     * balancing constraint series coefficient or RHS value
#'     * series period value lower or upper bound
#'     * series period value or temporal total alterability coefficient
#'   * `timeVal` (num): optional time value to restrict the application of series bounds or alterability coefficients 
#'   to a specific time period (or temporal group). It corresponds to the time value, as returned by `stats::time()`, of a given 
#'   input time series (argument `in_ts`) period (observation) and is conceptually equivalent to \eqn{year + (period - 1) / 
#'   frequency}.
#'
#' Note that empty strings (`""` or `''`) for character variables are interpreted as missing (`NA`) by the function. Variable 
#' `row` identifies the elements of the balancing problem and is the key variable that makes the link between both types of 
#' records. The same label (`row`) cannot be associated with more than one type of problem element (`type`) and multiple labels 
#' (`row`) cannot be defined for the same given type of problem element (`type`), except for balancing constraints (values 
#' `"EQ"`, `"LE"` and `"GE"` of column `type`). User-friendly features of the problem specs data frame include:
#' * The order of the observations (rows) is not important.
#' * Character values (variables `type`, `row` and `col`) are not case sensitive (e.g., strings `"Constraint 1"` and 
#' `"CONSTRAINT 1"` for `row` would be considered as the same problem element label), except when `col` is used to specify a 
#' series name (a column of the input time series object) where **case sensitivity is enforced**.
#' * The variable names of the problem specs data frame are also not case sensitive (e.g., `type`, `Type` or `TYPE` are all 
#' valid) and `time_val` is an accepted variable name (instead of `timeVal`).
#' 
#' Finally, the following table lists valid aliases for the *`type` keywords* (type of problem element):
#' | **Keyword** | **Aliases** |
#' |:-----------:|:------------|
#' | `EQ`        | `==`, `=` |
#' | `LE`        | `<=`, `<` |
#' | `GE`        | `>=`, `>` |
#' | `lowerBd`   | `lowerBound`, `lowerBnd`, + *same terms with '_', '.' or ' ' between words*|
#' | `upperBd`   | `upperBound`, `upperBnd`, + *same terms with '_', '.' or ' ' between words*|
#' | `alterTmp`  | `alterTemporal`, `alterTemp`, + *same terms with '_', '.' or ' ' between words*|
#' 
#' Reviewing the **Examples** should help conceptualize the balancing problem specifications data frame.
#' 
#' @param temporal_grp_periodicity (optional)
#'
#' Positive integer defining the number of periods in temporal groups for which the totals should be preserved.
#' E.g., specify `temporal_grp_periodicity = 3` with a monthly time series for quarterly total preservation and
#' `temporal_grp_periodicity = 12` (or `temporal_grp_periodicity = frequency(in_ts)`) for annual total preservation.
#' Specifying `temporal_grp_periodicity = 1` (*default*) corresponds to period-by-period processing without
#' temporal total preservation.
#'
#' **Default value** is `temporal_grp_periodicity = 1` (period-by-period processing without temporal total preservation).
#'
#' @param temporal_grp_start (optional)
#'
#' Integer in the \[1 .. `temporal_grp_periodicity`\] interval specifying the starting period (cycle) for temporal
#' total preservation. E.g., annual totals corresponding to fiscal years defined from April to March of the
#' following year would be specified with `temporal_grp_start = 4` for a monthly time series (`frequency(in_ts) = 12`)
#' and `temporal_grp_start = 2` for a quarterly time series (`frequency(in_ts) = 4`). This argument has no effect
#' for period-by-period processing without temporal total preservation (`temporal_grp_periodicity = 1`).
#'
#' **Default value** is `temporal_grp_start = 1`.
#' 
#' @param osqp_settings_df (optional)
#' 
#' Data frame (object of class "data.frame") containing a sequence of OSQP settings for solving the balancing problems. 
#' The package includes two predefined OSQP settings sequence data frames:
#' * [default_osqp_sequence]: fast and effective (default);
#' * [alternate_osqp_sequence]: geared towards precision at the expense of execution time.
#' 
#' See `vignette("osqp-settings-sequence-dataframe")` for more details on this topic and to see the actual contents 
#' of these two data frames. Note that the concept of a *solving sequence* with different sets of solver settings is 
#' new in G-Series 3.0 (a single solving attempt was made in G-Series 2.0).
#'
#' **Default value** is `osqp_settings_df = default_osqp_sequence`.
#' 
#' @param display_level (optional)
#' 
#' Integer in the \[0 .. 3\] interval specifying the level of information to display in the console (`stdout()`). 
#' Note that specifying argument `quiet = TRUE` would *nullify* argument `display_level` (none of the following information
#' would be displayed).
#' 
#' | **Displayed information**                           |       **`0`**       |       **`1`**       |       **`2`**       |       **`3`**       |
#' |:----------------------------------------------------|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
#' | Function header                                     | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} |
#' | Balancing problem elements                          |                     | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} |
#' | Individual problem solving details                  |                     |                     | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} |
#' | Individual problem results (values and constraints) |                     |                     |                     | \eqn{\checkmark}{Y} |
#'
#' **Default value** is `display_level = 1`.
#'  
#' @param alter_pos (optional)
#' 
#' Nonnegative real number specifying the default alterability coefficient associated to the values of time series with **positive** 
#' coefficients in all balancing constraints in which they are involved (e.g., component series in aggregation table raking problems). 
#' Alterability coefficients provided in the problem specification data frame (argument `problem_specs_df`) override this value.
#'
#' **Default value** is `alter_pos = 1.0` (nonbinding values).
#' 
#' @param alter_neg (optional)
#' 
#' Nonnegative real number specifying the default alterability coefficient associated to the values of time series with **negative** 
#' coefficients in all balancing constraints in which they are involved (e.g., marginal totals in aggregation table raking problems). 
#' Alterability coefficients provided in the problem specification data frame (argument `problem_specs_df`) override this value.
#'
#' **Default value** is `alter_neg = 1.0` (nonbinding values).
#' 
#' @param alter_mix (optional)
#' 
#' Nonnegative real number specifying the default alterability coefficient associated to the values of time series with a mix of 
#' **positive and negative** coefficients in the balancing constraints in which they are involved. Alterability coefficients provided 
#' in the problem specification data frame (argument `problem_specs_df`) override this value.
#'
#' **Default value** is `alter_mix = 1.0` (nonbinding values).
#' 
#' @param alter_temporal (optional)
#' 
#' Nonnegative real number specifying the default alterability coefficient associated to the time series temporal totals. 
#' Alterability coefficients provided in the problem specification data frame (argument `problem_specs_df`) override this value.
#'
#' **Default value** is `alter_temporal = 0.0` (binding values).
#' 
#' @param lower_bound (optional)
#' 
#' Real number specifying the default lower bound for the time series values. Lower bounds provided in the problem specification 
#' data frame (argument \ifelse{latex}{\code{problem _specs_df}}{\code{problem_specs_df}}) override this value.
#'
#' **Default value** is `lower_bound = -Inf` (unbounded).
#' 
#' @param upper_bound (optional)
#' 
#' Real number specifying the default upper bound for the time series values. Upper bounds provided in the problem specification 
#' data frame (argument \ifelse{latex}{\code{problem _specs_df}}{\code{problem_specs_df}}) override this value.
#'
#' **Default value** is `upper_bound = Inf` (unbounded).
#' 
#' @param tolV (optional)
#' 
#' Nonnegative real number specifying the tolerance, in absolute value, for the balancing constraints right-hand side (RHS) 
#' values:
#' * `EQ` constraints: \eqn{\quad A\mathbf{x} = \mathbf{b} \quad}{Ax = b} become \eqn{\quad \mathbf{b} - \epsilon \le A\mathbf{x} 
#' \le \mathbf{b} + \epsilon}{b - eps <= Ax <= b + eps}
#' * `LE` constraints: \eqn{\quad A\mathbf{x} \le \mathbf{b} \quad}{Ax <= b} become \eqn{\quad A\mathbf{x} \le \mathbf{b} + 
#' \epsilon}{Ax <= b + eps}
#' * `GE` constraints: \eqn{\quad A\mathbf{x} \ge \mathbf{b} \quad}{Ax >= b} become \eqn{\quad A\mathbf{x} \ge \mathbf{b} - 
#' \epsilon}{Ax >= b - eps}
#' 
#' where \eqn{\epsilon}{eps} is the tolerance specified with `tolV`. This argument does not apply to the *period value (lower 
#' and upper) bounds* specified with arguments `lower_bound` and `upper_bound` or in the problem specs data frame (argument 
#' `prob_specs_df`). I.e., `tolV` does not affect the time series values lower and upper bounds, unless they are specified as 
#' *balancing constraints* instead (with `GE` and `LE` constraints in the problem specs data frame).
#' 
#' **Default value** is `tolV = 0.0` (no tolerance).
#' 
#' @param tolV_temporal,tolP_temporal (optional)
#' 
#' Nonnegative real number, or `NA`, specifying the tolerance, in percentage (`tolP_temporal`) or absolute value 
#' (`tolV_temporal`), for the implicit temporal aggregation constraints associated to **binding temporal totals** 
#' \eqn{\left( \sum_t{x_{i,t}} = \sum_t{y_{i,t}} \right)}{(sum_t{x_{i,t}} = sum_t{y_{i,t}})}, which become:
#' \deqn{\sum_t{y_{i,t}} - \epsilon_\text{abs} \le \sum_t{x_{i,t}} \le \sum_t{y_{i,t}} + \epsilon_\text{abs}}{sum_t{y_{i,t}} - 
#' eps_abs <= sum_t{x_{i,t}} <= sum_t{y_{i,t}} + eps_abs}
#' or 
#' \deqn{\sum_t{y_{i,t}} \left( 1 - \epsilon_\text{rel} \right) \le \sum_t{x_{i,t}} \le \sum_t{y_{i,t}} \left( 1 + 
#' \epsilon_\text{rel} \right)}{sum_t{y_{i,t}} (1 - eps_rel) <= sum_t{x_{i,t}} <= sum_t{y_{i,t}} (1 + eps_rel)}
#' 
#' where \eqn{\epsilon_\text{abs}}{eps_abs} and \eqn{\epsilon_\text{rel}}{eps_rel} are the absolute and percentage tolerances 
#' specified respectively with `tolV_temporal` and  `tolP_temporal`. Both arguments cannot be specified together (one must be 
#' specified while the other must be `NA`).
#'
#' **Example:** to set a tolerance of 10 *units*, specify \ifelse{latex}{\code{tolV_temporal = 10, tolP_temporal} \code{= NA}}{
#' \code{tolV_temporal = 10, tolP_temporal = NA}}; to set a tolerance of 1%, specify`tolV_temporal = NA, tolP_temporal = 0.01`. 
#' 
#' **Default values** are `tolV_temporal = 0.0` and `tolP_temporal = NA` (no tolerance).
#' 
#' @param validation_tol (optional)
#' 
#' Nonnegative real number specifying the tolerance for the validation of the balancing results. The function verifies if 
#' the final (reconciled) time series values meet the constraints, allowing for discrepancies up to the value specified with 
#' this argument. A warning is issued as soon as one constraint is not met (discrepancy greater than `validation_tol`).
#' 
#' With constraints defined as \eqn{\mathbf{l} \le A\mathbf{x} \le \mathbf{u}}{l <= Ax <= u}, where \eqn{\mathbf{l = u}}{l = u} 
#' for `EQ` constraints, \eqn{\mathbf{l} = -\infty}{l = -Inf} for `LE` constraints and \eqn{\mathbf{u} = \infty}{u = Inf} for 
#' `GE` constraints, **constraint discrepancies** correspond to \eqn{\max \left( 0, \mathbf{l} - A\mathbf{x}, A\mathbf{x} - 
#' \mathbf{u} \right)}{max(0, l - Ax, Ax - u)}, where constraint bounds \eqn{\mathbf{l}}{l} and \eqn{\mathbf{u}}{u} include 
#' the tolerances, when applicable, specified with arguments `tolV`, `tolV_temporal` and `tolP_temporal`.  
#' 
#' **Default value** is `validation_tol = 0.001`.
#' 
#' @param trunc_to_zero_tol (optional)
#' 
#' Nonnegative real number specifying the tolerance, in absolute value, for replacing by zero (small) values in the output 
#' (reconciled) time series data (output object `out_ts`). Specify `trunc_to_zero_tol = 0` to disable this *truncation to zero* 
#' process on the reconciled data. Otherwise, specify `trunc_to_zero_tol > 0` to replace with \eqn{0.0} any value in the 
#' \eqn{\left[ -\epsilon, \epsilon \right]}{[-eps, eps]} interval, where \eqn{\epsilon}{eps} is the tolerance specified with 
#' `trunc_to_zero_tol`. 
#' 
#' Note that the final constraint discrepancies (see argument `validation_tol`) are calculated on the *zero truncated* 
#' reconciled time series values, therefore ensuring accurate validation of the actual reconciled data returned by the 
#' function.
#' 
#' **Default value** is `trunc_to_zero_tol = validation_tol`.
#' 
#' @param full_sequence (optional)
#' 
#' Logical argument specifying whether all the steps of the *OSQP settings sequence data frame* should be performed or not. 
#' See argument `osqp_settings_df` and `vignette("osqp-settings-sequence-dataframe")` for more details on this topic.
#' 
#' **Default value** is `full_sequence = FALSE`.
#' 
#' @param validation_only (optional)
#' 
#' Logical argument specifying whether the function should only perform input data validation or not. When 
#' `validation_only = TRUE`, the specified *balancing constraints* and *period value (lower and upper) bounds* constraints 
#' are validated against the input time series data, allowing for discrepancies up to the value specified with argument 
#' `validation_tol`. Otherwise, when `validation_only = FALSE` (default), the input data are first reconciled and the 
#' resulting (output) data are then validated.
#' 
#' **Default value** is `validation_only = FALSE`.
#' 
#' @param quiet (optional)
#' 
#' Logical argument specifying whether or not to display only essential information such as warnings, errors and the period 
#' (or set of periods) being reconciled. You could further suppress, if desired, the display of the _balancing period(s)_ 
#' information by _wrapping_ your [tsbalancing()] call with [suppressMessages()]. In that case, the `proc_grp_df` output 
#' data frame can be used to identify (unsuccessful) balancing problems associated with warning messages (if any). Note that 
#' specifying `quiet = TRUE` would also *nullify* argument `display_level`.
#'
#' **Default value** is `quiet = FALSE`.
#'   
#'
#' @details 
#' This function solves one balancing problem per processing group (see section **Processing groups** for details). Each of these balancing 
#' problems is a quadratic minimization problem of the following form:
#' \deqn{\displaystyle 
#' \begin{aligned}
#' & \underset{\mathbf{x}}{\text{minimize}} 
#' & & \mathbf{\left( y - x \right)}^{\mathrm{T}} W \mathbf{\left( y - x \right)} \\
#' & \text{subject to} 
#' & & \mathbf{l} \le A \mathbf{x} \le \mathbf{u}
#' \end{aligned}
#' }{min(x) (y - x)' W (y - x), subject to l <= Ax <= u}
#' where
#' - \eqn{\mathbf{y}}{y} is the vector of the initial problem values, i.e., the initial time series period values and, when applicable, 
#' temporal totals;
#' - \eqn{\mathbf{x}}{x} is the final (reconciled) version of vector \eqn{\mathbf{y}}{y};
#' - matrix \eqn{W = \mathrm{diag} \left( \mathbf{w} \right)}{W = diag(w)} with vector \eqn{\mathbf{w}}{w} elements \eqn{w_i = \left\{
#'     \begin{array}{cl}
#'       0 & \text{if } |c_i y_i| = 0 \\
#'       \frac{1}{|c_i y_i|} & \text{otherwise}
#'     \end{array} \right.
#'     }{w_i = 0 if |c_i y_i| = 0, w_i = 1/|c_i y_i| otherwise}, 
#'     where \eqn{c_i} is the alterability coefficient of problem value \eqn{y_i} and cases corresponding to \eqn{|c_i y_i| 
#'     = 0} are fixed problem values (binding period values or temporal totals);
#' - matrix \eqn{A} and vectors \eqn{\mathbf{l}}{l} and \eqn{\mathbf{u}}{u} specify the _balancing constraints_, the _implicit 
#' temporal total aggregation constraints_ (when applicable), the _period value (upper and lower) bounds_ as well as _\eqn{x_i 
#' = y_i} constraints for fixed \eqn{y_i} values_ \eqn{\left( \left| c_i y_i \right| = 0 \right)}{(|c_i y_i| = 0)}.
#'
#' In practice, the objective function of the problem solved by OSQP excludes constant term \eqn{\mathbf{y}^{\mathrm{T}} W 
#' \mathbf{y}}{y' W y}, therefore corresponding to \eqn{\mathbf{x}^{\mathrm{T}} W \mathbf{x} - 2 \left( \mathbf{w} \mathbf{y} 
#' \right)^{\mathrm{T}} \mathbf{x}}{x' W x - 2 (w y)' x}, and the fixed \eqn{y_i} values \eqn{\left( \left| c_i y_i \right| = 0 
#' \right)}{(|c_i y_i| = 0)} are removed from the problem, adjusting the constraints accordingly, i.e.:
#' - rows corresponding to the *\eqn{x_i = y_i} constraints for fixed \eqn{y_i} values* are removed from \eqn{A}, \eqn{
#' \mathbf{l}}{l} and \eqn{\mathbf{u}}{u};
#' - columns corresponding to fixed \eqn{y_i} values are removed from \eqn{A} while appropriately adjusting \eqn{
#' \mathbf{l}}{l} and \eqn{\mathbf{u}}{u}.
#'     
#'     
######
# This subsection differs slightly between `tsraking()` and `tsbalancing` and is therefore maintained for both functions 
# (in both sets of roxygen2 comments) as opposed to being shared with `roxygen2 tag `@inheritSection`.
# => the "Temporal total preservation* paragraph is the SAME, however: keep them "in sync"!.
######
#' ## Alterability Coefficients
#' Alterability coefficients are nonnegative numbers that change the relative cost of modifying an initial problem value. 
#' By changing the actual objective function to minimize, they allow the generation of a wide range of solutions. Since they 
#' appear in the denominator of the objective function (matrix \eqn{W}), the larger the alterability coefficient the less costly 
#' it is to modify a problem value (period value or temporal total) and, conversely, the smaller the alterability coefficient 
#' the more costly it becomes. This results in problem values with larger alterability coefficients proportionally changing more 
#' than the ones with smaller alterability coefficients. Alterability coefficients of \eqn{0.0} define fixed (binding) problem 
#' values while alterability coefficients greater than \eqn{0.0} define free (nonbinding) values. The default alterability 
#' coefficients are \eqn{0.0} for temporal totals (argument `alter_temporal`) and \eqn{1.0} for period values (arguments 
#' `alter_pos`, `alter_neg`, `alter_mix`). In the common case of aggregation table raking problems, the period values of the 
#' marginal totals (time series with a coefficient of \eqn{-1} in the balancing constraints) are usually binding (specified 
#' with `alter_neg = 0`) while the period values of the component series (time series with a coefficient of \eqn{1} in the 
#' balancing constraints) are usually nonbinding (specified with `alter_pos > 0`, e.g., `alter_pos = 1`). *Almost binding* 
#' problem values (e.g., marginal totals or temporal totals) can be obtained in practice by specifying very small (almost 
#' \eqn{0.0}) alterability coefficients relative to those of the other (nonbinding) problem values.
#' 
#' **Temporal total preservation** refers to the fact that temporal totals, when applicable, are usually kept “as close as 
#' possible” to their initial value. *Pure preservation* is achieved by default with binding temporal totals while the change 
#' is minimized with nonbinding temporal totals (in accordance with the set of alterability coefficients).
#' 
#' 
#' ## Validation and troubleshooting
#' Successful balancing problems (problems with a valid solution) have `sol_status_val > 0` or, equivalently, 
#' `n_unmet_con = 0` or `max_discr <= validation_tol` in the output `proc_grp_df` data frame. Troubleshooting 
#' unsuccessful balancing problems is not necessarily straightforward. Following are some suggestions:
#' 
#' - Investigate the failed constraints (`unmet_flag = TRUE` or, equivalently, `discr_out > validation_tol` in the 
#' output `prob_con_df` data frame) to make sure that they do not cause an empty solution space (infeasible problem).
#' 
#' - Change the OSQP solving sequence. E.g., try:
#'   1. argument `full_sequence = TRUE`
#'   2. argument `osqp_settings_df = alternate_osqp_sequence`
#'   3. arguments `osqp_settings_df = alternate_osqp_sequence` and `full_sequence = TRUE`
#'   
#'   See `vignette("osqp-settings-sequence-dataframe")` for more details on this topic.
#'   
#' - Increase (review) the `validation_tol` value. Although this may sound like *cheating*, the default `validation_tol` 
#' value (\eqn{1 \times 10^{-3}}) may actually be too small for balancing problems that involve very large values (e.g., 
#' in billions) or, conversely, too large with very small problem values (e.g, \eqn{< 1.0}). Multiplying the average scale 
#' of the problem data by the *machine tolerance* (`.Machine$double.eps`) gives an approximation of the average size of the 
#' discrepancies that [tsbalancing()] should be able to handle (distinguish from \eqn{0}) and should probably constitute an 
#' **absolute lower bound** for argument `validation_tol`. In practice, a reasonable `validation_tol` value would likely be 
#' \eqn{1 \times 10^3} to \eqn{1 \times 10^6} times larger than this *lower bound*.
#'   
#' - Address constraints redundancy. Multi-dimensional aggregation table raking problems are over-specified (involve 
#' redundant constraints) when all totals of all dimensions of the *data cube* are binding (fixed) and a constraint is 
#' defined for all of them. Redundancy also occurs for the implicit temporal aggregation constraints in single- or 
#' multi-dimensional aggregation table raking problems with binding (fixed) temporal totals. Over-specification is generally 
#' not an issue for [tsbalancing()] if the input data are not contradictory with regards to the redundant constraints, i.e., 
#' if there are no inconsistencies (discrepancies) associated to the redundant constraints in the input data or if they are 
#' *negligible* (reasonably small relative to the scale of the problem data). Otherwise, this may lead to unsuccessful 
#' balancing problems with [tsbalancing()]. Possible solutions would then include:
#'   1. Resolve (or reduce) the discrepancies associated to the redundant constraints in the input data.
#'   2. Select one marginal total in every dimension, but one, of the data cube and remove the corresponding balancing 
#'   constraints from the problem. *This cannot be done for the implicit temporal aggregation constraints*.
#'   3. Select one marginal total in every dimension, but one, of the data cube and make them nonbinding (alterability 
#'   coefficient of, say, \eqn{1.0}). 
#'   4. Do the same as (3) for the temporal totals of one of the inner-cube component series (make them nonbinding).
#'   5. Make all marginal totals of every dimension, but one, of the data cube *amlost binding*, i.e., specify very small 
#'   alterability coefficients (say \eqn{1 \times 10^{-6}}) compared to those of the inner-cube component series. 
#'   6. Do the same as (5) for the temporal totals of all inner-cube component series (very small alterability 
#'   coefficients, e.g., with argument `alter_temporal`).
#'   7. Use [tsraking()] (if applicable), which handles these inconsistencies by using the Moore-Penrose inverse  
#'   (uniform distribution among all binding totals).
#'        
#'   Solutions (2) to (7) above should only be considered if the discrepancies associated to the redundant constraints 
#'   in the input data are *reasonably small* as they would be distributed among the omitted or nonbinding totals with 
#'   [tsbalancing()] and all binding totals with [tsraking()]. Otherwise, one should first investigate solution (1) above.
#' 
#' - Relax the bounds of the problem constraints, e.g.:
#'   - argument `tolV` for the balancing constraints;
#'   - arguments `tolV_temporal` and `tolP_temporal` for the implicit temporal aggregation constraints;
#'   - arguments `lower_bound` and `upper_bound`.
#' 
#' 
#' # Processing groups
#' The set of periods of a given reconciliation (raking or balancing) problem is called a *processing group* 
#' and either corresponds to:
#' - a **single period** with period-by-period processing or, when preserving temporal totals, for the individual 
#' periods of an incomplete temporal group (e.g., an incomplete year)
#' - or the **set of periods of a complete temporal group** (e.g., a complete year) when preserving temporal 
#' totals. 
#' 
#' The total number of processing groups (total number of reconciliation problems) depends on the set of 
#' periods in the input time series object (argument `in_ts`) and on the value of arguments 
#' `temporal_grp_periodicity` and `temporal_grp_start`. 
#' 
#' Common scenarios include `temporal_grp_periodicity = 1` (default) for period-by period processing without 
#' temporal total preservation and `temporal_grp_periodicity = frequency(in_ts)` for the preservation of annual 
#' totals (calendar years by default). Argument `temporal_grp_start` allows the specification of other types of 
#' (_non-calendar_) years. E.g., fiscal years starting on April correspond to `temporal_grp_start = 4` with monthly 
#' data and `temporal_grp_start = 2` with quarterly data. Preserving quarterly totals with monthly data would 
#' correspond to \ifelse{latex}{\code{temporal_grp _periodicity = 3}}{\code{temporal_grp_periodicity = 3}}. 
#' 
#' By default, temporal groups covering more than a year (i.e., corresponding to \ifelse{latex}{\code{
#' temporal_grp _periodicity > frequency(in_ts)}}{\code{temporal_grp_periodicity > frequency(in_ts)}} start on a 
#' year that is a multiple of \ifelse{latex}{\code{ceiling(temporal_grp _periodicity / frequency(in_ts))}}{\code{
#' ceiling(temporal_grp_periodicity / frequency(in_ts))}}. E.g., biennial groups corresponding to \ifelse{latex}{
#' \code{temporal_grp_per iodicity = 2 * frequency(in_ts)}}{\code{temporal_grp_periodicity = 2 * frequency(in_ts)}}
#' start on an _even year_ by default. This behaviour can be changed with argument `temporal_grp_start`. E.g., the 
#' preservation of biennial totals starting on an _odd year_ instead of an _even year_ (default) corresponds to 
#' `temporal_grp_start = frequency(in_ts) + 1` (along with `temporal_grp_periodicity = 2 * frequency(in_ts)`).
#' 
#' See the [gs.build_proc_grps()] **Examples** for common processing group scenarios.
#' 
#' 
#' # Comparing [tsraking()] and [tsbalancing()]
#' - [tsraking()] is limited to one- and two-dimensional aggregation table raking problems (with temporal total 
#' preservation if required) while [tsbalancing()] handles more general balancing problems (e.g., higher dimensional 
#' raking problems, nonnegative solutions, general linear equality and inequality constraints as opposed to aggregation 
#' rules only, etc.).
#' - [tsraking()] returns the generalized least squared solution of the Dagum and Cholette regression-based raking 
#' model (Dagum and Cholette 2006) while [tsbalancing()] solves the corresponding quadratic minimization problem using 
#' a numerical solver. In most cases, *convergence to the minimum* is achieved and the [tsbalancing()] solution matches 
#' the (exact) [tsraking()] least square solution. It may not be the case, however, if convergence could not be achieved 
#' after a reasonable number of iterations. Having said that, only in very rare occasions will the [tsbalancing()] 
#' solution *significantly* differ from the [tsraking()] solution.
#' - [tsbalancing()] is usually faster than [tsraking()], especially for large raking problems, but is generally more 
#' sensitive to the presence of (small) inconsistencies in the input data associated to the redundant constraints of 
#' fully specified (over-specified) raking problems. [tsraking()] handles these inconsistencies by using the 
#' Moore-Penrose inverse (uniform distribution among all binding totals). 
#' - [tsbalancing()] accommodates the specification of sparse problems in their reduced form. This is not true in the 
#' case of [tsraking()] where aggregation rules must always be fully specified since a *complete data cube* without 
#' missing data is expected as input (every single *inner-cube* component series must contribute to all dimensions of 
#' the cube, i.e., to every single *outer-cube* marginal total series).
#' - Both tools handle negative values in the input data differently by default. While the solutions of raking problems 
#' obtained from [tsbalancing()] and [tsraking()] are identical when all input data points are positive, they will 
#' differ if some data points are negative (unless argument `Vmat_option = 2` is specified with [tsraking()]).
#' - While both [tsbalancing()] and [tsraking()] allow the preservation of temporal totals, time management is not 
#' incorporated in [tsraking()]. For example, the construction of the processing groups (sets of periods of each raking 
#' problem) is left to the user with [tsraking()] and separate calls must be submitted for each processing group (each 
#' raking problem). That's where helper function [tsraking_driver()] comes in handy with [tsraking()].
#' - [tsbalancing()] returns the same set of series as the input time series object while [tsraking()] returns the set 
#' of series involved in the raking problem plus those specified with argument `id` (which could correspond to a subset 
#' of the input series).
#'
#'
#' @returns
#' The function returns is a list of seven objects:
#' 
#' - `out_ts`: modified version of the input time series object (class "ts" or "mts"; see argument `in_ts`) with the resulting 
#' reconciled time series values (primary function output). It can be explicitly coerced to another type of object with the 
#' appropriate `as*()` function (e.g., `tsibble::as_tsibble()` would coerce it to a tsibble).
#' 
#' - `proc_grp_df`: processing group summary data frame, useful to identify problems that have succeeded or failed. 
#' It contains one observation (row) for each balancing problem with the following columns:
#'   - `proc_grp` (num): processing group id.
#'   - `proc_grp_type` (chr): processing group type. Possible values are:
#'     - `"period"`;
#'     - `"temporal group"`.
#'   - `proc_grp_label` (chr): string describing the processing group in the following format:
#'     - `"<year>-<period>"` (single periods)
#'     - `"<start year>-<start period> - <end year>-<end period>"` (temporal groups)
#'   - `sol_status_val`, `sol_status` (num, chr): solution status numerical (integer) value and description string:
#'     - ` 1`: `"valid initial solution"`;
#'     - `-1`: `"invalid initial solution"`;
#'     - ` 2`: `"valid polished osqp solution"`;
#'     - `-2`: `"invalid polished osqp solution"`;
#'     - ` 3`: `"valid unpolished osqp solution"`;
#'     - `-3`: `"invalid unpolished osqp solution"`;
#'     - `-4`: `"unsolvable fixed problem"` (invalid initial solution).
#'   - `n_unmet_con` (num): number of unmet constraints (`sum(prob_conf_df$unmet_flag)`).
#'   - `max_discr` (num): maximum constraint discrepancy (`max(prob_conf_df$discr_out)`).
#'   - `validation_tol` (num): specified tolerance for validation purposes (argument `validation_tol`).
#'   - `sol_type` (chr): returned solution type. Possible values are:
#'     - `"initial"` (initial solution, i.e., input data values);
#'     - `"osqp"` (OSQP solution).
#'   - `osqp_attempts` (num): number of attempts made with OSQP (depth achieved in the solving sequence).
#'   - `osqp_seqno` (num): step # of the solving sequence corresponding to the returned solution. `NA` when 
#'   `sol_type = "initial"`.
#'   - `osqp_status` (chr): OSQP status description string (`osqp_sol_info_df$status`). `NA` when `sol_type = "initial"`.
#'   - `osqp_polished` (logi): `TRUE` if the returned OSQP solution is polished (\ifelse{latex}{\code{osqp_sol_info_df 
#'   $status_polish = 1}}{\code{osqp_sol_info_df$status_polish = 1}}), `FALSE` otherwise. `NA` when `sol_type = "initial"`.
#'   - `total_solve_time` (num): total time, in seconds, of the solving sequence.
#'   
#'   Column `proc_grp` constitutes a *unique key* (distinct rows) for the data frame. Successful balancing problems 
#'   (problems with a valid solution) correspond to rows with `sol_status_val > 0` or, equivalently, to `n_unmet_con = 0` 
#'   or to `max_discr <= validation_tol`. The *initial solution* (`sol_type = "initial"`) is returned only if **a)** 
#'   there are no initial constraint discrepancies, **b)** the problem is fixed (all values are binding) or **c)** it beats 
#'   the OSQP solution (smaller total constraint discrepancies). The OSQP solving sequence is described in \ifelse{latex}{
#'   \code{vignette("osqp-settings -sequence-dataframe")}}{\code{vignette("osqp-settings-sequence-dataframe")}}.
#'     
#' - `periods_df`: time periods data frame, useful to match periods to processing groups. It contains one observation 
#' (row) for each period of the input time series object (argument `in_ts`) with the following columns:
#'   - `proc_grp` (num): processing group id.
#'   - `t` (num): time id (`1:nrow(in_ts)`).
#'   - `time_val` (num): time value (`stats::time(in_ts)`). It conceptually corresponds to \eqn{year + (period - 1) / frequency}.
#'   
#'   Columns `t` and `time_val` both constitute a *unique key* (distinct rows) for the data frame.
#' 
#' - `prob_val_df`: problem values data frame, useful to analyze change diagnostics, i.e., initial vs final (reconciled) 
#' values. It contains one observation (row) for each value involved in each balancing problem, with the following columns:
#'   - `proc_grp` (num): processing group id.
#'   - `val_type` (chr): problem value type. Possible values are:
#'     - `"period value"`;
#'     - `"temporal total"`.
#'   - `name` (chr): time series (variable) name.
#'   - `t` (num): time id (`1:nrow(in_ts)`); id of the first period of the temporal group for a *temporal total*.
#'   - `time_val` (num): time value (`stats::time(in_ts)`); value of the first period of the temporal group for a 
#'   *temporal total*. It conceptually corresponds to \eqn{year + (period - 1) / frequency}.
#'   - `lower_bd`, `upper_bd` (num): period value bounds; always `-Inf` and `Inf` for a *temporal total*.
#'   - `alter` (num): alterability coefficient.
#'   - `value_in`, `value_out` (num): initial and final (reconciled) values.
#'   - `dif` (num): `value_out - value_in`.
#'   - `rdif` (num): `dif / value_in`; `NA` if `value_in = 0`.
#'   
#'   Columns `val_type + name + t` and `val_type + name + time_val` both constitute a *unique key* (distinct rows) for the 
#'   data frame. Binding (fixed) problem values correspond to rows with `alter = 0` or `value_in = 0`. Conversely, nonbinding 
#'   (free) problem values correspond to rows with `alter != 0` and `value_in != 0`.
#'   
#' - `prob_con_df`: problem constraints data frame, useful for troubleshooting problems that failed (identify unmet 
#' constraints). It contains one observation (row) for each constraint involved in each balancing problem, with the following 
#' columns:
#'   - `proc_grp` (num): processing group id.
#'   - `con_type` (chr): problem constraint type. Possible values are:
#'     - `"balancing constraint"`;
#'     - `"temporal aggregation constraint"`;
#'     - `"period value bounds"`.
#'     
#'     While *balancing constraints* are specicied by the user, the other two types of constraints (*temporal aggregation 
#'     constraints* and *period value bounds*) are automatically added to the problem by the function (when applicable).
#'   - `name` (chr): constraint label or time series (variable) name.
#'   - `t` (num): time id (`1:nrow(in_ts)`); id of the first period of the temporal group for a *temporal aggregation constraint*.
#'   - `time_val` (num): time value (`stats::time(in_ts)`); value of the first period of the temporal group for a *temporal 
#'   aggregation constraint*. It conceptually corresponds to \eqn{year + (period - 1) / frequency}.
#'   - `l`, `u`, `Ax_in`, `Ax_out` (num): initial and final constraint elements \eqn{\left( \mathbf{l} \le A \mathbf{x} \le 
#'   \mathbf{u} \right)}{(l <= Ax <= u)}.
#'   - `discr_in`, `discr_out` (num): initial and final constraint discrepancies \eqn{\left( \max \left( 0, \mathbf{l} - A 
#'   \mathbf{x}, A \mathbf{x} - \mathbf{u} \right) \right)}{(max(0, l - Ax, Ax - u))}.
#'   - `validation_tol` (num): specified tolerance for validation purposes (argument `validation_tol`).
#'   - `unmet_flag` (logi): `TRUE` if the constraint is not met (`discr_out > validation_tol`), `FALSE` otherwise.
#'   
#'   Columns `con_type + name + t` and `con_type + name + time_val` both constitute a *unique key* (distinct rows) for the 
#'   data frame. Constraint bounds \eqn{\mathbf{l = u}}{l = u} for `EQ` constraints, \eqn{\mathbf{l} = -\infty}{l = -Inf} for 
#'   `LE` constraints, \eqn{\mathbf{u} = \infty}{u = Inf} for `GE` constraints, and include the tolerances, when applicable, 
#'   specified with arguments `tolV`, `tolV_temporal` and `tolP_temporal`.
#' 
#' - `osqp_settings_df`: OSQP settings data frame. It contains one observation (row) for each problem (processing group) 
#' solved with OSQP (`proc_grp_df$sol_type = "osqp"`), with the following columns:
#'   - `proc_grp` (num): processing group id.
#'   - one column corresponding to each element of the list returned by the `osqp::GetParams()` method applied to a 
#'   *OSQP solver object* (class "osqp_model" object as returned by [osqp::osqp()]), e.g.:
#'     - Maximum iterations (`max_iter`);
#'     - Primal and dual infeasibility tolerances (`eps_prim_inf` and `eps_dual_inf`);
#'     - Solution polishing flag (`polish`);
#'     - Number of scaling iterations (`scaling`);
#'     - etc.
#'   - extra settings specific to [tsbalancing()]:
#'     - `prior_scaling` (logi): `TRUE` if the problem data were scaled (using the average of the free (nonbinding) problem 
#'     values as the scaling factor) prior to solving with OSQP, `FALSE` otherwise.
#'     - `require_polished` (logi): `TRUE` if a polished solution from OSQP (\ifelse{latex}{\code{osqp_sol_info_df 
#'     $status_polish = 1}}{\code{osqp_sol_info_df$status_polish = 1}}) was required for this step in order to end the solving 
#'     sequence, `FALSE` otherwise. See `vignette("osqp-settings-sequence-dataframe")` for more details on the solving sequence 
#'     used by [tsbalancing()].
#'     
#'   Column `proc_grp` constitutes a *unique key* (distinct rows) for the data frame. Visit 
#'   <https://osqp.org/docs/interfaces/solver_settings.html> for all available OSQP settings. Problems (processing groups) for 
#'   which the initial solution was returned (`proc_grp_df$sol_type = "initial"`) are not included in this data frame.
#' 
#' - `osqp_sol_info_df`: OSQP solution information data frame. It contains one observation (row) for each problem 
#' (processing group) solved with OSQP (`proc_grp_df$sol_type = "osqp"`), with the following columns:
#'   - `proc_grp` (num): processing group id.
#'   - one column corresponding to each element of the `info` list of a *OSQP solver object* (class "osqp_model" object 
#'   as returned by [osqp::osqp()]) after having been solved with the `osqp::Solve()` method, e.g.:
#'     - Solution status (`status` and `status_val`);
#'     - Polishing status (`status_polish`);
#'     - Number of iterations (`iter`);
#'     - Objective function value (`obj_val`);
#'     - Primal and dual residuals (`pri_res` and `dua_res`);
#'     - Solve time (`solve_time`);
#'     - etc.
#'   - extra information specific to [tsbalancing()]:
#'     - `prior_scaling_factor` (num): value of the scaling factor when \ifelse{latex}{\code{osqp_settings_df $prior_scaling 
#'     = TRUE}}{\code{osqp_settings_df$prior_scaling = TRUE}} (`prior_scaling_factor = 1.0` otherwise).
#'     - `obj_val_ori_prob` (num): original balancing problem's objective function value, which is the OSQP objective function 
#'     value (`obj_val`) on the original scale (when \code{osqp_settings_df$prior_scaling = TRUE}) plus the constant term of 
#'     the original balancing problem's objective function, i.e., \ifelse{latex}{\code{obj_val_ori_prob = obj_val * 
#'     prior _scaling_factor + <constant term>}}{\code{obj_val_ori_prob = obj_val * prior_scaling_factor + <constant term>}}, 
#'     where `<constant term>` corresponds to 
#'     \eqn{\mathbf{y}^{\mathrm{T}} W \mathbf{y}}{y' W y}. See section **Details** for the definition of vector 
#'     \eqn{\mathbf{y}}{y}, matrix \eqn{W} and, more generally speaking, the complete expression of the balancing problem's 
#'     objective function.
#' 
#'   Column `proc_grp` constitutes a *unique key* (distinct rows) for the data frame. Visit <https://osqp.org> for more information on 
#'   OSQP. Problems (processing groups) for which the initial solution was returned (`proc_grp_df$sol_type = "initial"`) are not 
#'   included in this data frame.
#'
#' Note that the "data.frame" objects returned by the function can be explicitly coerced to other types of objects with 
#' the appropriate `as*()` function (e.g., `tibble::as_tibble()` would coerce any of them to a tibble).
#'
#'
#' @references Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal Distribution and Reconciliation Methods
#' of Time Series**. Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
#'
#' @references Ferland, M., S. Fortier and J. Bérubé (2016). "A Mathematical Optimization Approach to Balancing Time Series: 
#' Statistics Canada’s GSeriesTSBalancing". In **JSM Proceedings, Business and Economic Statistics Section**. Alexandria, 
#' VA: American Statistical Association. 2292-2306.
#' 
#' @references Ferland, M. (2018). "Time Series Balancing Quadratic Problem — Hessian matrix and vector of linear objective 
#' function coefficients". **Internal document**. Statistics Canada, Ottawa, Canada.
#'
#' @references Quenneville, B. and S. Fortier (2012). "Restoring Accounting Constraints in Time Series – Methods and
#' Software for a Statistical Agency". **Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New York.
#' 
#' @references SAS Institute Inc. (2015). "The LP Procedure Sparse Data Input Format". **SAS/OR\eqn{^\circledR}{®} 14.1 
#' User's Guide: Mathematical Programming Legacy Procedures**. 
#' <https://support.sas.com/documentation/cdl/en/ormplpug/68158/HTML/default/viewer.htm#ormplpug_lp_details03.htm>
#' 
#' @references Statistics Canada (2016). "The ***GSeriesTSBalancing*** Macro". **G-Series 2.0 User Guide**.
#' Statistics Canada, Ottawa, Canada.
#'
#' @references Statistics Canada (2018). **Theory and Application of Reconciliation (Course code 0437)**.
#' Statistics Canada, Ottawa, Canada.
#'
#' @references Stellato, B., G. Banjac, P. Goulart et al. (2020). "OSQP: an operator splitting solver for quadratic programs". 
#' **Math. Prog. Comp. 12**, 637–672 (2020). \doi{10.1007/s12532-020-00179-2}
#'
#'
#' @seealso [tsraking()] [tsraking_driver()] [rkMeta_to_blSpecs()] [gs.build_proc_grps()] [build_balancing_problem()] [aliases]
#'
#'
#' @example misc/function_examples/tsbalancing-ex.R
#'
#'
#' @export
tsbalancing <- function(in_ts,
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
                        quiet = FALSE) {




  ### Internal functions ###

  # Display the Problem Specs data frame info
  #
  # Main (parent) function objects used in this function:
  #   - pb         : balancing problem core elements (building blocks), namely (elements of the list):
  #     - labels_df: problem specs labels
  #     - coefs_df : problem specs coefficients 
  #     - ser_names: vector of all series names involved in the balancing problem
  #     - lb       : lower bounds info (list object)
  #     - ub       : upper bounds info (list object)
  #     - alter    : period value alterability coefficients (list object)
  #     - altertmp : temporal total alterability coefficients (list object)
  #     - pos_ser  : vector of series names with only positive constraint coefficients (across all constraints)
  #     - neg_ser  : vector of series names with only negative constraint coefficients (across all constraints)
  #     - mix_ser  : vector of series names with both positive and negative constraint coefficients (across all constraints)
  #   - n_ser      : `length(pb$ser_names)`
  #   - n_con      : `length(pb$labels_df$row.lc[pb$labels_df$con.flag])`
  #   - arguments `alter_pos`, `alter_neg`, `alter_mix`, `alter_temporal`, `lower_bound`, `upper_bound`, 
  #     `validation_only` and `temporal_grp_periodicity`
  print_specs <- function() {

    # Function to build the balancing constraint string for display
    build_con_str <- function(type_val, row_val, col_vec, coef_vec) {
      rhs_logic <- (col_vec == "_rhs_")
      if (any(rhs_logic)) {
        rhs_str <- format(coef_vec[rhs_logic], big.mark = ",")
      } else {
        rhs_str <- "0"
      }
      series <- col_vec[!rhs_logic]
      coefs <- coef_vec[!rhs_logic]

      # A loop is used as opposed to a single `paste0(, collapse = "")` essentially for optimized display
      # of each single series constraint coefficient (e.g., avoid having "200x - 10.5y + 300z >= 1,000"
      # being displayed as "200.0x - 10.5y + 300.0z >= 1,000", i.e., with a decimal everywhere)
      #   => the loop is not that costly (compared to `paste0(, collapse = "")`)
      tmp <- format(abs(coefs[1]), big.mark = ",")
      con_str <- paste0(ifelse(coefs[1] < 0, "-", ""), ifelse(tmp == "1", "", tmp), series[1])
      for (ii in seq.int(from = 2, length.out = length(coefs) - 1)) {
        tmp <- format(abs(coefs[ii]), big.mark = ",")
        con_str <- paste0(con_str, ifelse(coefs[ii] < 0, " - ", " + "), ifelse(tmp == "1", "", tmp), series[ii])
      }

      if (type_val == "eq") {
        op <- " == "
      } else if (type_val == "le") {
        op <- " <= "
      } else {
        op <- " >= "
      }

      paste0("  ", row_val, ":\n    ", con_str, op, rhs_str)
    }

    header <- "Balancing Problem Elements"
    message("\n\n\n", header, "\n", paste0(rep.int("=", nchar(header)), collapse = ""))

    # Display constraints
    con_labels_df <- pb$labels_df[pb$labels_df$con.flag, , drop = FALSE]
    header <- paste0("Balancing Constraints (", n_con, ")")
    message("\n\n  ", header, "\n  ", paste0(rep.int("-", nchar(header)), collapse = ""))
    for (ii in seq.int(n_con)) {
      logi_vec <- pb$coefs_df$row.lc == con_labels_df$row.lc[ii]
      message("\n", build_con_str(type_val = con_labels_df$type.lc[ii],
                                  row_val = con_labels_df$row[ii],
                                  col_vec = pb$coefs_df$col[logi_vec],
                                  coef_vec = pb$coefs_df$coef[logi_vec]))
    }

    
    # Function to pad the values of a character data frame column (character vector) to the right 
    # so that it is displayed as a left-aligned character column
    pad_right <- function(x) {
      len <- max(nchar(x))
      # `sapply()` is safe: it always returns a character vector (`x` is of length minimum 1)
      paste0(x, sapply(len - nchar(x), 
                       function(x) paste0(rep(" ", x), collapse = "")))
      
    }
    
    # Initialize the series info data frame (lower/upper bounds and alter/alterTmp coef values and source)
    series_info_df <- data.frame(
      name = pb$ser_names,
      lb_val = rep.int(lower_bound, n_ser),
      lb_per = rep.int("", n_ser),
      lb_src = rep.int(lower_bound_label, n_ser),
      ub_val = rep.int(upper_bound, n_ser),
      ub_per = rep.int("", n_ser),
      ub_src = rep.int(upper_bound_label, n_ser),
      alter_val = rep.int(NA_real_, n_ser),
      alter_per = rep.int("", n_ser),
      alter_src = rep.int(NA_character_, n_ser),
      altertmp_val = rep.int(alter_temporal, n_ser),
      altertmp_per = rep.int("", n_ser),
      altertmp_src = rep.int(alter_temporal_label, n_ser)
    )

    # Assign the lower/upper bounds and alter coefs
    dated_info <- FALSE
    col_id_vec <- 1
    series_info_df$lb_val[pb$lb$nondated_id_vec] <- pb$lb$nondated_coefs
    series_info_df$lb_src[pb$lb$nondated_id_vec] <- "(problem specs)"
    series_info_df$lb_src <- pad_right(series_info_df$lb_src)
    # Treat period-specific values
    if (length(pb$lb$dated_id_vec) > 0) {
      dated_info <- TRUE
      series_info_df$lb_per[pb$lb$dated_id_vec] <- "*"
      col_id_vec <- c(col_id_vec, 2, 3, 4)
    } else {
      col_id_vec <- c(col_id_vec, 2, 4)
    }
    series_info_df$ub_val[pb$ub$nondated_id_vec] <- pb$ub$nondated_coefs
    series_info_df$ub_src[pb$ub$nondated_id_vec] <- "(problem specs)"
    series_info_df$ub_src <- pad_right(series_info_df$ub_src)
    if (length(pb$ub$dated_id_vec) > 0) {
      dated_info <- TRUE
      series_info_df$ub_per[pb$ub$dated_id_vec] <- "*"
      col_id_vec <- c(col_id_vec, 5, 6, 7)
    } else {
      col_id_vec <- c(col_id_vec, 5, 7)
    }
    if (!validation_only) {
      id_vec <- match(pb$pos_ser, pb$ser_names)
      series_info_df$alter_val[id_vec] <- alter_pos
      series_info_df$alter_src[id_vec] <- alter_pos_label
      id_vec <- match(pb$neg_ser, pb$ser_names)
      series_info_df$alter_val[id_vec] <- alter_neg
      series_info_df$alter_src[id_vec] <- alter_neg_label
      id_vec <- match(pb$mix_ser, pb$ser_names)
      series_info_df$alter_val[id_vec] <- alter_mix
      series_info_df$alter_src[id_vec] <- alter_mix_label
      series_info_df$alter_val[pb$alter$nondated_id_vec] <- pb$alter$nondated_coefs
      series_info_df$alter_src[pb$alter$nondated_id_vec] <- "(problem specs)"
      series_info_df$alter_src <- pad_right(series_info_df$alter_src)
      if (length(pb$alter$dated_id_vec) > 0) {
        dated_info <- TRUE
        series_info_df$alter_per[pb$alter$dated_id_vec] <- "*"
        col_id_vec <- c(col_id_vec, 8, 9, 10)
      } else {
        col_id_vec <- c(col_id_vec, 8, 10)
      }
      if (temporal_grp_periodicity != 1) {
        series_info_df$altertmp_val[pb$altertmp$nondated_id_vec] <- pb$altertmp$nondated_coefs
        series_info_df$altertmp_src[pb$altertmp$nondated_id_vec] <- "(problem specs)"
        series_info_df$altertmp_src <- pad_right(series_info_df$altertmp_src)
        if (length(pb$altertmp$dated_id_vec) > 0) {
          dated_info <- TRUE
          series_info_df$altertmp_per[pb$altertmp$dated_id_vec] <- "*"
          col_id_vec <- c(col_id_vec, 11, 12, 13)
        } else {
          col_id_vec <- c(col_id_vec, 11, 13)
        }
      }
    }
    
    # Keep relevant columns and assign the (duplicate/empty) column names for display
    series_info_df <- data.frame(series_info_df[col_id_vec])
    cols_names <- c("name",
                    "lowerBd", "", "",
                    "upperBd", "", "",
                    "alter", "", "", 
                    "alterTmp", "", "")
    names(series_info_df) <- cols_names[col_id_vec]

    # Display the time series info
    header <- "Time Series Info"
    message("\n\n  ", header, "\n  ", paste0(rep.int("-", nchar(header)), collapse = ""))
    message("\n", paste0("  ", utils::capture.output(print.data.frame(series_info_df)), collapse = "\n"))
    if (dated_info) {
      message("\n  * indicates cases where period-specific values (`timeVal` is not `NA`) are specified in the problem specs data frame.")
    }
    message("\n")
  }


  # Functions to set up `sink()` in order to store "output" type display (sent to `stdout()`) in a text file,
  # wrap up (close) `sink()` and display the text file contents as a "message" (sent to `stderr()`)
  #
  # Argument:
  #   - txtfile: name and path of the (temporary) text file that will store the output
  #
  # Other main (parent) function objects used in this function:
  #   - osqp_output_file: name and path of the (temporary) text file to be deleted as the function exits
  sink_setup <- function(txtfile) {
    sink(file = txtfile, type = c("output", "message"))
    invisible(NULL)
  }
  sink_wrapup <- function(txtfile) {
    sink()
    osqp_output_file <<- txtfile
    msg <- paste0("  ", readLines(txtfile), collapse = "\n")
    message("\n", msg)
    invisible(NULL)
  }


  # Display the balancing results (problem values and constraints data frames)
  #
  # Main (parent) function objects used in this function:
  #   - prob_val_df: balancing problem values data frame
  #   - prob_con_df: balancing problem constraints data frame
  print_results <- function() {

    
    # Problem values data frame
    
    header <- "Problem Values"
    lines <- paste0(rep.int("-", nchar(header)), collapse = "")
    message("\n  ", lines, "\n  ", header, "\n  ", lines, "\n")
    logi_vec <- (prob_val_df$val_type == "temporal total")
    if (sum(logi_vec) == 0) {
      df <- prob_val_df[, -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE, big_mark = ",")),
                     collapse = "\n"), "\n")
    } else {
      header <- "Period Values"
      lines <- paste0(rep.int("-", nchar(header)), collapse = "")
      message("  ", header, "\n  ", lines)
      df <- prob_val_df[!logi_vec, -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)), collapse = "\n"), "\n")
      header <- "Temporal Totals"
      lines <- paste0(rep.int("-", nchar(header)), collapse = "")
      message("  ", header, "\n  ", lines)
      df <- prob_val_df[logi_vec, -c(1, 2, 4, 5, 6, 7)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)), collapse = "\n"), "\n")
    }

    
    # Problem constraints data frame
    
    header <- "Problem Constraints (l <= Ax <= u)"
    lines <- paste0(rep.int("-", nchar(header)), collapse = "")
    message("\n  ", lines, "\n  ", header, "\n  ", lines, "\n")

    if (length(unique(prob_con_df$con_type)) == 1) {
      df <- prob_con_df[, -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)),
                     collapse = "\n"), "\n")
    } else {
      header <- "Balancing Constraints"
      lines <- paste0(rep.int("-", nchar(header)), collapse = "")
      message("  ", header, "\n  ", lines)
      df <- prob_con_df[prob_con_df$con_type == "balancing constraint", -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)), collapse = "\n"), "\n")
      logi_vec <- (prob_con_df$con_type == "period value bounds")
      if (sum(logi_vec) > 0) {
        header <- "Period Value Bounds"
        lines <- paste0(rep.int("-", nchar(header)), collapse = "")
        message("  ", header, "\n  ", lines)
        df <- prob_con_df[logi_vec, -c(1, 2)]
        message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)),
                       collapse = "\n"), "\n")
      }
      logi_vec <- (prob_con_df$con_type == "temporal aggregation constraint")
      if (sum(logi_vec) > 0) {
        header <- "Temporal Aggregation Constraints"
        lines <- paste0(rep.int("-", nchar(header)), collapse = "")
        message("  ", header, "\n  ", lines)
        df <- prob_con_df[logi_vec, -c(1, 2, 4, 5)]
        message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)),
                       collapse = "\n"), "\n")
      }
    }
    message("")
  }




  ### Main function ###
  
  # Initialize the object to be returned by the function via `on.exit()`
  out_list <- NULL
  on.exit(return(out_list))
  warning_flag <- FALSE
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)

  # Validate argument `quiet` and implement the quiet setting
  quiet <- gs.validate_arg_logi(quiet)
  if (quiet) {
    quiet_msg_func <- gs.NULL_func
    quiet_lab <- ""  # won't be displayed anyway
    displayLevel_lab <- ""  # won't be displayed anyway
    specs_display_func <- gs.NULL_func
    solve_msg_func <- gs.NULL_func
    osqp_verbose <- FALSE
    osqpBeg_display_func <- gs.NULL_func
    osqpEnd_display_func <- gs.NULL_func
    osqp_output_file <- NULL
    results_display_func <- gs.NULL_func
  } else {
    quiet_msg_func <- message
    quiet_lab <- "    (*)quiet                 = FALSE (default)"
    
    tmp <- (unlist(display_level))[1]
    if (!identical(display_level, tmp) || is.null(tmp) || !(tmp %in% 0:3)) {
      stop("Argument 'display_level' must take value 0, 1, 2, or 3.\n\n", call. = FALSE)
    }
    display_level <- as.integer(display_level)
    displayLevel_lab <- paste0("    display_level            = ", format(display_level))
    width_opt <- getOption("width")
    if (width_opt < 128) {
      on.exit(options(width = width_opt), add = TRUE)
      options(width = 128)
    }
    if (display_level == 1) {
      displayLevel_lab <- paste0(displayLevel_lab, " (default)")
      specs_display_func <- print_specs
      solve_msg_func <- gs.NULL_func
      osqp_verbose <- FALSE
      osqpBeg_display_func <- gs.NULL_func
      osqpEnd_display_func <- gs.NULL_func
      osqp_output_file <- NULL
      results_display_func <- gs.NULL_func
    } else if (display_level == 0) {
      specs_display_func <- gs.NULL_func
      solve_msg_func <- gs.NULL_func
      osqp_verbose <- FALSE
      osqpBeg_display_func <- gs.NULL_func
      osqpEnd_display_func <- gs.NULL_func
      osqp_output_file <- NULL
      results_display_func <- gs.NULL_func
    } else {
      specs_display_func <- print_specs
      solve_msg_func <- message
      osqp_verbose <- TRUE
      osqpBeg_display_func <- sink_setup
      osqpEnd_display_func <- sink_wrapup
      osqp_output_file <- ".gseries_osqp_output.txt"
      on.exit(invisible(suppressWarnings(file.remove(osqp_output_file))), add = TRUE)
      if (display_level == 3) {
        results_display_func <- print_results
      } else {
        results_display_func <- gs.NULL_func
      }
    }
  }

  
  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\ntsbalancing() function:\n")


  # Initial argument validation

  # Mandatory arguments (without default values)
  in_ts_name <- deparse1(substitute(in_ts))
  tmp <- nchar(in_ts_name)
  if (tmp == 0) {
    stop("Argument 'in_ts' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    in_ts_name <- paste0(substr(in_ts_name, 1, 55), "<...>")
  }
  if (grepl("structure(", in_ts_name, fixed = TRUE)) {
    in_ts_name <- "<argument 'in_ts'>"
  }
  in_ts <- in_ts
  if (!stats::is.ts(in_ts)) {
    stop("Argument 'in_ts' is not a 'ts' object.\n\n", call. = FALSE)
  }
  in_ts <- stats::as.ts(in_ts)
  ts_freq <- stats::frequency(in_ts)
  time_values <- as.numeric(stats::time(in_ts))
  periods <- gs.time2str(in_ts)
  n_per <- length(periods)
  
  specs_df_name <- deparse1(substitute(problem_specs_df))
  tmp <- nchar(specs_df_name)
  if (tmp == 0) {
    stop("Argument 'problem_specs_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    specs_df_name <- paste0(substr(specs_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", specs_df_name, fixed = TRUE)) {
    specs_df_name <- "<argument 'problem_specs_df'>"
  }
  problem_specs_df <- problem_specs_df
  if (!is.data.frame(problem_specs_df)) {
    stop("Argument 'problem_specs_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  problem_specs_df <- as.data.frame(problem_specs_df)
  row.names(problem_specs_df) <- NULL

  # Optional arguments (with default values).
  # => Note that the following optional arguments, only relevant when `validation_only == FALSE`,
  #    will be validated later:
  #      - `temporal_grp_periodicity`
  #      - `temporal_grp_start`
  #      - `osqp_settings_df`
  #      - `alter_pos`
  #      - `alter_neg`
  #      - `alter_mix`
  #      - `alter_temporal`
  #      - `tolV_temporal` and `tolP_temporal`
  #      - `trunc_to_zero_tol`
  tmp <- (unlist(lower_bound))[1]
  if (!identical(lower_bound, tmp) || is.null(tmp) || is.na(tmp) || !is.finite(tmp) && tmp != -Inf) {
    stop("Argument 'lower_bound' must be a finite real number or -Inf.\n\n", call. = FALSE)
  }
  tmp <- (unlist(upper_bound))[1]
  if (!identical(upper_bound, tmp) || is.null(tmp) || is.na(tmp) || !is.finite(tmp) && tmp != Inf) {
    stop("Argument 'upper_bound' must be a finite real number or Inf.\n\n", call. = FALSE)
  }
  if (lower_bound > upper_bound) {
    stop("Arguments `lower_bound` and 'upper_bound' are not compatible (`lower_bound = ",
         format(lower_bound, big.mark = ","), " > ", format(upper_bound, big.mark = ","),
         " = upper_bound`).\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolV))[1]
  if (!identical(tolV, tmp) || is.null(tmp) || !is.finite(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolV' must be a nonnegative finite real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(validation_tol))[1]
  if (!identical(validation_tol, tmp) || is.null(tmp) || !is.finite(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'validation_tol' must be a nonnegative finite real number.\n\n", call. = FALSE)
  }
  validation_only <- gs.validate_arg_logi(validation_only)

  if (validation_only) {
    valid_only_lab <- "    (*)validation_only       = TRUE"
    solve_func <- return_initial_sol
    solve_str <- "Input Values Validation"
    solve_word <- "Validating"

    # Force period-by-period processing
    temporal_grp_periodicity <- 1
    temp_grp_per_lab <- "    temporal_grp_periodicity (ignored)"
    temporal_grp_start <- NA_integer_
    temp_grp_start_lab <- "    temporal_grp_start       (ignored)"

    # Set other ignored arguments
    settings_df <- osqp_settings_df
    settingsDF_lab <- "    osqp_settings_df         (ignored)"
    alter_pos <- NA_real_
    alterPos_lab <- "    alter_pos                (ignored)"
    alter_pos_label <- NA_character_
    alter_neg <- NA_real_
    alterNeg_lab <- "    alter_neg                (ignored)"
    alter_neg_label <- NA_character_
    alter_mix <- NA_real_
    alterMix_lab <- "    alter_mix                (ignored)"
    alter_mix_label <- NA_character_
    alter_temporal <- NA_real_
    alterTmp_lab <- "    alter_temporal           (ignored)"
    alter_temporal_label <- NA_character_
    tolV_temporal <- NA_real_
    tolP_temporal <- NA_real_
    tol_temporal_lab <- "    tolV_temporal            (ignored)"
    trunc_to_zero_tol <- NA_real_
    zero_trunc_lab <- "    (*)trunc_to_zero_tol     (ignored)"

  } else {
    valid_only_lab <- paste0("    (*)validation_only       = FALSE (default)")
    solve_func <- solve_one_osqp
    solve_str <- "Problem Solving"
    solve_word <- "Balancing"

    # Validate optional argument `temporal_grp_periodicity` (and set the header label)
    tmp <- (unlist(temporal_grp_periodicity))[1]
    if (!identical(temporal_grp_periodicity, tmp) || is.null(tmp) || !is.finite(tmp) ||
        is.finite(tmp) && (tmp <= 0 || tmp != as.integer(tmp))) {
      stop("Argument 'temporal_grp_periodicity' must be a positive integer.\n\n", call. = FALSE)
    }
    temporal_grp_periodicity <- as.integer(temporal_grp_periodicity)
    temp_grp_per_lab <- paste0("    temporal_grp_periodicity = ", format(temporal_grp_periodicity))
    if (temporal_grp_periodicity == 1) {
      temp_grp_per_lab <- paste0(temp_grp_per_lab, " (default)")
      temporal_grp_start <- NA_integer_
      temp_grp_start_lab <- paste0("    temporal_grp_start       (ignored)")
      alter_temporal <- NA_real_
      alterTmp_lab <- "    alter_temporal           (ignored)"
      alter_temporal_label <- NA_character_
      tolV_temporal <- NA_real_
      tolP_temporal <- NA_real_
      tol_temporal_lab <- "    tolV_temporal            (ignored)"
    } else {

      # Validate optional argument `temporal_grp_start` (and set the header label)
      tmp <- (unlist(temporal_grp_start))[1]
      if (!identical(temporal_grp_start, tmp) || is.null(tmp) || !is.finite(tmp) ||
          is.finite(tmp) && (tmp <= 0 || tmp > temporal_grp_periodicity || tmp != as.integer(tmp))) {
        stop("Argument 'temporal_grp_start' must be an integer in the [1..", temporal_grp_periodicity, "] interval.\n\n",
             call. = FALSE)
      }
      temporal_grp_start <- as.integer(temporal_grp_start)
      temp_grp_start_lab <- paste0("    temporal_grp_start       = ", format(temporal_grp_start))
      if (temporal_grp_start == 1) {
        temp_grp_start_lab <- paste0(temp_grp_start_lab, " (default)")
      }
      
      # Validate optional argument `alter_temporal`
      tmp <- (unlist(alter_temporal))[1]
      if (!identical(alter_temporal, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
        stop("Argument 'alter_temporal' must be a nonnegative finite real number.\n\n", call. = FALSE)
      }
      alterTmp_lab <- paste0("    alter_temporal           = ", format(alter_temporal, big.mark = ","))
      if (alter_temporal == 0) {
        alterTmp_lab <- paste0(alterTmp_lab, " (default)")
        alter_temporal_label <- "(default)"
      } else {
        alter_temporal_label <- "(arg `alter_temporal`)"
      }
      
      # Validate the binding temporal total tolerances (and set the header label)
      tmp <- (unlist(tolV_temporal))[1]
      if (is.null(tmp)) {
        tolV_temporal <- NA_real_
      } else if (!identical(tolV_temporal, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
        stop("Argument 'tolV_temporal' must be a nonnegative finite real number or NA.\n\n", call. = FALSE)
      }
      tmp <- (unlist(tolP_temporal))[1]
      if (is.null(tmp)) {
        tolP_temporal <- NA_real_
      } else if (!identical(tolP_temporal, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
        stop("Argument 'tolP_temporal' must be a nonnegative finite real number or NA.\n\n", call. = FALSE)
      }
      if (!is.na(tolV_temporal)) {
        if (!is.na(tolP_temporal)) {
          stop("Arguments 'tolV_temporal' and 'tolP_temporal' cannot be both specified (one must be NA).\n\n", call. = FALSE)
        }
        tol_temporal_lab <- paste0("    tolV_temporal            = ", format(tolV_temporal))
        if (abs(tolV_temporal) < gs.tolerance) {
          tol_temporal_lab <- paste0(tol_temporal_lab, " (default)")
        }
        tolP_temporal <- 0
      } else {
        if (is.na(tolP_temporal)) {
          stop("Arguments 'tolV_temporal' and 'tolP_temporal' cannot be both NA (one must be specified).\n\n", call. = FALSE)
        }
        tol_temporal_lab <- paste0("    tolP_temporal            = ", format(tolP_temporal))
        tolV_temporal <- 0
      }
    }
    
    # Validate optional argument `osqp_settings_df` (and set the header label)
    settingsDF_lab <- "    osqp_settings_df         = "
    if (is.null(osqp_settings_df)) {
      settingsDF_lab <- paste0(settingsDF_lab, "NULL (default OSQP settings)")
      # Set OSQP setting `verbose` (based on arguments `quiet` and `display_level`), 
      # `require_polished = FALSE` and  `prior_scaling = FALSE`
      settings_df <- data.frame(verbose = osqp_verbose, require_polished = FALSE, prior_scaling = FALSE)
    } else {
      settings_df_name <- deparse1(substitute(osqp_settings_df))
      if (nchar(settings_df_name) >= 60) {
        settings_df_name <- paste0(substr(settings_df_name, 1, 55), "<...>")
      }
      if (grepl("structure(", settings_df_name, fixed = TRUE)) {
        settings_df_name <- "<argument 'osqp_settings_df'>"
      }
      settings_df <- osqp_settings_df
      if (!is.data.frame(settings_df)) {
        warning("Argument 'settings_df_name' is not a 'data.frame' object. It will be ignored and the default OSQP ",
                "settings sequence data frame (package data frame `default_osqp_sequence`) will be  used instead.\n",
                call. = FALSE, immediate. = TRUE)
        settings_df <- default_osqp_sequence
        settings_df_name <- "default_osqp_sequence"
      }
      # Set (add/overwrite) OSQP setting `verbose` (based on arguments `quiet` and `display_level`)
      settings_df$verbose <- osqp_verbose
      if (settings_df_name %in% c("default_osqp_sequence", "gseries::default_osqp_sequence")) {
        settingsDF_lab <- paste0(settingsDF_lab, settings_df_name, " (default)")
      } else {
        settingsDF_lab <- paste0(settingsDF_lab, settings_df_name)
        # Remove duplicate rows and row names (just in case)
        settings_df <- unique(settings_df)
        row.names(settings_df) <- NULL
      }
      # Set `require_polished`
      settings_cols <- names(settings_df)
      if ("require_polished" %in% settings_cols) {
        # Impose polishing when `require_polished == TRUE`
        if ("polish" %in% settings_cols) {
          settings_df$polish <- (settings_df$polish | settings_df$require_polished)
        } else {
          settings_df$polish <- settings_df$require_polished
        }
      } else {
        settings_df$require_polished <- FALSE
      }
      # Set `prior_scaling` 
      if (!("prior_scaling" %in% settings_cols)) {
        settings_df$prior_scaling <- FALSE
      }
    }
    
    # Validate the alterability coefficient optional arguments
    tmp <- (unlist(alter_pos))[1]
    if (!identical(alter_pos, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
      stop("Argument 'alter_pos' must be a nonnegative finite real number.\n\n", call. = FALSE)
    }
    alterPos_lab <- paste0("    alter_pos                = ", format(alter_pos, big.mark = ","))
    if (alter_pos == 1) {
      alterPos_lab <- paste0(alterPos_lab, " (default)")
      alter_pos_label <- "(default)"
    } else {
      alter_pos_label <- "(arg `alter_pos`)"
    }
    tmp <- (unlist(alter_neg))[1]
    if (!identical(alter_neg, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
      stop("Argument 'alter_neg' must be a nonnegative finite real number.\n\n", call. = FALSE)
    }
    alterNeg_lab <- paste0("    alter_neg                = ", format(alter_neg, big.mark = ","))
    if (alter_neg == 1) {
      alterNeg_lab <- paste0(alterNeg_lab, " (default)")
      alter_neg_label <- "(default)"
    } else {
      alter_neg_label <- "(arg `alter_neg`)"
    }
    tmp <- (unlist(alter_mix))[1]
    if (!identical(alter_mix, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
      stop("Argument 'alter_mix' must be a nonnegative finite real number.\n\n", call. = FALSE)
    }
    alterMix_lab <- paste0("    alter_mix                = ", format(alter_mix, big.mark = ","))
    if (alter_mix == 1) {
      alterMix_lab <- paste0(alterMix_lab, " (default)")
      alter_mix_label <- "(default)"
    } else {
      alter_mix_label <- "(arg `alter_mix`)"
    }

    # Validate optional argument `trunc_to_zero_tol` (and set the header label)
    tmp <- (unlist(trunc_to_zero_tol))[1]
    if (!identical(trunc_to_zero_tol, tmp) || is.null(tmp) || !is.finite(tmp) || is.finite(tmp) && tmp < 0) {
      stop("Argument 'trunc_to_zero_tol' must be a nonnegative finite real number.\n\n",
           call. = FALSE)
    }
    if (abs(trunc_to_zero_tol - validation_tol) < gs.tolerance) {
      zero_trunc_lab <- "    (*)trunc_to_zero_tol     = validation_tol (default)"
    } else {
      zero_trunc_lab <- paste0("    (*)trunc_to_zero_tol     = ", format(trunc_to_zero_tol))
    }

    # Validate optional argument `full_sequence`
    full_sequence <- gs.validate_arg_logi(full_sequence)
  }

  # Display the function call (argument values)
  quiet_msg_func("    in_ts                    = ", in_ts_name)
  quiet_msg_func("    problem_specs_df         = ", specs_df_name)
  quiet_msg_func(temp_grp_per_lab)
  quiet_msg_func(temp_grp_start_lab)
  quiet_msg_func(settingsDF_lab)
  quiet_msg_func(displayLevel_lab)
  quiet_msg_func(alterPos_lab)
  quiet_msg_func(alterNeg_lab)
  quiet_msg_func(alterMix_lab)
  quiet_msg_func(alterTmp_lab)
  lab <- paste0("    lower_bound              = ", format(lower_bound, big.mark = ","))
  if (lower_bound == -Inf) {
    lab <- paste0(lab, " (default)")
    lower_bound_label <- "(default)"
  } else {
    lower_bound_label <- "(arg `lower_bound`)"
  }
  quiet_msg_func(lab)
  lab <- paste0("    upper_bound              = ", format(upper_bound, big.mark = ","))
  if (upper_bound == Inf) {
    lab <- paste0(lab, " (default)")
    upper_bound_label <- "(default)"
  } else {
    upper_bound_label <- "(arg `upper_bound`)"
  }
  quiet_msg_func(lab)
  lab <- paste0("    tolV                     = ", format(tolV))
  if (tolV < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(tol_temporal_lab, "\n")
  lab <- paste0("    (*)validation_tol        = ", format(validation_tol))
  if (abs(validation_tol - 0.001) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(zero_trunc_lab)
  quiet_msg_func(valid_only_lab)
  quiet_msg_func(quiet_lab, "\n")
  quiet_msg_func("    (*) indicates new arguments in G-Series 3.0\n")
  
  
  # Build the core elements (building blocks) for the balancing problems (while validating the specified 
  # info), excluding the temporal totals info (will be added later, inside the processing groups loop):
  #   - labels_df: cleaned-up version of the label definition records from `problem_specs_df` 
  #                (rows where `type` is non-missing); extra columns:
  #                  - type.lc : `tolower(type)`
  #                  - row.lc  : `tolower(row)` 
  #                  - con.flag: `type.lc %in% c("eq", "le", "ge")`
  #   - coefs_df : cleaned-up version of the information specification records from `problem_specs_df` 
  #                (rows where `type` is missing); extra columns:
  #                  - row.lc  : `tolower(row)` 
  #                  - con.flag: `labels_df$con.flag` allocated through `row.lc`
  #   - values_ts: reduced version of 'in_ts' with only the relevant series (see vector `ser_names`)
  #   - lb       : lower bound info (`type.lc = "lowerbd"`) for the relevant series; list object with the 
  #                following elements:
  #                  - coefs_ts       : lower bound values for series and period
  #                  - nondated_coefs : vector of nondated lower bounds from `problem_specs_df` (`timeVal` is `NA`)
  #                  - nondated_id_vec: vector of `ser_names` id's associated to vector `nondated_coefs`
  #                  - dated_id_vec   : vector of `ser_names` id's associated to dated lower bounds from 
  #                                     `problem_specs_df` (`timeVal` is not `NA`)
  #   - ub       : same as `lb` but for upper bounds (`type.lc = "upperbd"`)
  #   - alter    : same as `lb` but for period value alterability coefficients (`type.lc = "alter"`)
  #   - altertmp : same as `lb` but for temporal total alterability coefficients (`type.lc = "altertmp"`)
  #   - ser_names: vector of the relevant series names (set of series involved in the balancing constraints)
  #   - pos_ser  : vector of series names that have only positive coefficients across all balancing constraints
  #   - neg_ser  : vector of series names that have only negative coefficients across all balancing constraints
  #   - mix_ser  : vector of series names that have both positive and negative coefficients across all balancing 
  #                constraints
  #   - A1,op1,b1: period level (single-period) balancing constraint elements (`A1 %*% x op1 b1` for 
  #                coherent/reconciled data)
  #   - A2,op2,b2: temporal group level (multi-period) balancing constraint elements (`A2 %*% x op2 b2` for 
  #                coherent/reconciled data)
  #
  # Notes:
  #
  #   - The returned balancing problem elements do not include the implicit temporal totals for multi-period 
  #     processing (i.e., elements `A2`, `op2` and `b2` only contain the balancing constraints info).
  #       
  #   - Multi-period balancing problem elements `A2`, `op2` and `b2` are constructed in "column-major order",
  #     corresponding to the default behaviour of R for converting matrices into vectors. E.g.:
  #       - single-period processing (period `t`):
  #           `A1 %*% as.vector(values_ts[t, ]) op1 b1` for coherent/reconciled data
  #       - multi-period processing (periods `t1:t2` of length `temporal_grp_periodicity`):
  #           `A2 %*% as.vector(values_ts[t1:t2, ]) op2 b2` for coherent/reconciled data
  # 
  #   - Default temporal total alterability coefficients (`altertmp$coefs_ts`) for cases not specified in the 
  #     problem specs data frame (`problem_specs_df`) remain `NA` at this stage (i.e., argument `alter_temporal` 
  #     has not been used yet at this point). When time comes, this will allow for easy identification of the
  #     first specified (non `NA`) temporal total alter coef in the specs inside a complete temporal group.
  # 
  #   - A "wide range" of reserved keywords for column `type` in the specs (for label definition records) 
  #     are accepted in practice (i.e., the list of accepted keywords, in lowercase, include):
  #   - A "wide range" of reserved keywords for column `type` in the specs (for label definition records) 
  #     are accepted in practice. The list of accepted keywords, in lowercase, include:
  #       - "==" and "=" for "eq"
  #       - "<=" and "<" for "le"
  #       - ">=" and ">" for "ge"
  #       - "lower" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "lowerbd"
  #       - "upper" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "upperbd"
  #       - "alter" + ("" or "_" or "-" or "." or " ") + ("tmp" or "temp" or "temporal) for "altertmp"
  #
  pb <- build_balancing_problem(in_ts                    = in_ts,
                                problem_specs_df         = problem_specs_df,
                                in_ts_name               = in_ts_name,
                                ts_freq                  = ts_freq,
                                periods                  = periods,
                                n_per                    = n_per,
                                specs_df_name            = specs_df_name,
                                temporal_grp_periodicity = temporal_grp_periodicity,
                                alter_pos                = alter_pos,
                                alter_neg                = alter_neg,
                                alter_mix                = alter_mix,
                                lower_bound              = lower_bound, 
                                upper_bound              = upper_bound,
                                validation_only          = validation_only)
  
  # Number of series and balancing constraints
  n_ser <- length(pb$ser_names)
  n_con <- length(pb$labels_df$row.lc[pb$labels_df$con.flag])
  
  # Display the problem specs info
  specs_display_func()

    
  # Initial temporal aggregation matrix (for all series)
  #   => will be reduced later to the set of non fully binding series only
  #      (temporal totals of fully binding represent redundant constraints)
  dim_A2 <- dim(pb$A2)  # `dim_A2[1]` = number of rows
  # `dim_A2[2]` = number of columns
  A_a <- matrix(0, nrow = n_ser, ncol = dim_A2[2] + n_ser)
  for (ii in 1:n_ser) {
    A_a[ii, ((ii - 1) * temporal_grp_periodicity + 1):(ii * temporal_grp_periodicity)] <- 1
    A_a[ii, dim_A2[2] + ii] <- -1
  }
  

  # Define the processing groups (set of balancing problems).
  # Columns of the returned data frame:
  #   - grp         : processing group id (1:<number-of-groups>)
  #   - beg_per     : first period id
  #   - end_per     : last period id
  #   - complete_grp: complete group flag (logical, TRUE if end_per != beg_per)
  grp_df <- gs.build_proc_grps(gs.time2year(pb$values_ts),
                               gs.time2per(pb$values_ts),
                               n_per,
                               ts_freq,
                               temporal_grp_periodicity,
                               temporal_grp_start)

  # Activate message display
  n_grps <- nrow(grp_df)
  if (n_grps > 1) {
    solve_header_msg_func <- gs.NULL_func
    grp_msg_func <- message
    final_msg_flag <- TRUE
  } else {
    solve_header_msg_func <- solve_msg_func
    grp_msg_func <- gs.NULL_func
    final_msg_flag <- FALSE
  }

  solve_header_msg_func("\n\n", solve_str)
  solve_header_msg_func(strrep("=", nchar(solve_str)), "\n")


  # Initialize the output objects
  out_mat <- matrix(NA_real_, nrow = n_per, ncol = n_ser,
                    dimnames = list(NULL, pb$ser_names))
  tmp1 <- rep.int(NA_character_, n_grps)
  tmp2 <- rep.int(NA_real_, n_grps)
  tmp3 <- rep.int(NA_integer_, n_grps)
  out_proc_grp_df <- data.frame(
    proc_grp = grp_df$grp,
    proc_grp_type = tmp1,
    proc_grp_label = tmp1,
    sol_status = tmp1,
    sol_status_val = tmp3,
    n_unmet_con = tmp2,
    max_discr = tmp2,
    validation_tol = rep.int(validation_tol, n_grps),
    sol_type = tmp1,
    osqp_attempts = rep.int(0L, n_grps),
    osqp_seqno = tmp3,
    osqp_status = tmp1,
    osqp_polished = rep.int(as.logical(NA), n_grps),
    total_solve_time = tmp3)
  out_prob_val_df <- NULL
  out_prob_con_df <- NULL
  out_osqp_settings_df <- NULL
  out_osqp_sol_info_df <- NULL


  # Balance each processing group (generate the `balancing_process()` calls)
  for (grp in 1:n_grps) {

    # Build the processing group header and balancing problem elements list
    per_id_vec <- grp_df$beg_per[grp]:grp_df$end_per[grp]
    n_per_grp <- length(per_id_vec)
    n_values_grp <- n_ser * n_per_grp

    # Initialize the (non-constraint) balancing problem elements
    bl <- list(
      x = as.vector(pb$values_ts[per_id_vec, , drop = FALSE]),
      c = as.vector(pb$alter$coefs_ts[per_id_vec, , drop = FALSE]),
      lb = as.vector(pb$lb$coefs_ts[per_id_vec, , drop = FALSE]),
      ub = as.vector(pb$ub$coefs_ts[per_id_vec, , drop = FALSE]),
      bd_tol = rep.int(0, n_values_grp)
    )


    # Temporal group processing (multiple periods)
    #   => balancing problem elements must be "augmented" with temporal total info
    #   => initial constraint elements are the "v2" objects
    if (grp_df$complete_grp[grp]) {

      out_proc_grp_df$proc_grp_type[grp] <- "temporal group"
      out_proc_grp_df$proc_grp_label[grp] <- paste0(periods[grp_df$beg_per[grp]], " - ", periods[grp_df$end_per[grp]])

      # Build the processing group header
      msg_str <- paste0(solve_word, " periods [", out_proc_grp_df$proc_grp_label[grp], "]")

      # Reduce matrix `A_a` for non fully binding series only
      # (temporal totals of fully binding series are irrelevant)
      non_fully_binding <- (A_a[, 1:dim_A2[2], drop = FALSE] %*% bl$c) != 0
      n_a <- sum(non_fully_binding)
      A_a2 <- A_a[non_fully_binding, c(rep.int(TRUE, dim_A2[2]), non_fully_binding), drop = FALSE]

      # Add the temporal totals info
      a <- A_a2[, 1:dim_A2[2], drop = FALSE] %*% bl$x
      bl$x <- c(bl$x, a)
      c_a <- apply(pb$altertmp$coefs_ts[per_id_vec, pb$ser_names[non_fully_binding], drop = FALSE], 2,
                   function(x) {
                     # Return the first non missing (non `NA`) temporal total alter. coef. of the temporal group.
                     # Otherwise (all `NA`), return the default alter. coef. (argument `alter_temporal`)
                     y <- x[!is.na(x)][1]
                     if (is.na(y)) {
                       alter_temporal
                     } else {
                       y
                     }
                   })
      bl$c <- c(bl$c, c_a)
      names(bl$c) <- NULL
      bl$lb <- c(bl$lb, rep.int(-Inf, n_a))
      bl$ub <- c(bl$ub, rep.int(Inf, n_a))
      bl$bd_tol <- c(bl$bd_tol, rep.int(0, n_a))
      bl$A <- rbind(cbind(pb$A2, matrix(0, nrow = dim_A2[1], ncol = n_a)),
                    A_a2)
      bl$op <- c(pb$op2, rep.int("==", n_a))
      bl$b <- c(pb$b2, rep.int(0, n_a))

      # Temporal aggregation constraint tolerances are for binding temporal totals only!
      # (no need for "additional slack" in nonbinding temporal total aggregation constraints:
      # "slack" for nonbinding temporal totals is already accounted for in the optimization
      # function where changes to the initial temporal totals are minimized)
      bl$b_tol <- c(rep.int(tolV, dim_A2[1]), (a * tolP_temporal + tolV_temporal) * (c_a == 0))


    # Single-period processing
    #   => constraint elements are the "v1" objects
    } else {

      out_proc_grp_df$proc_grp_type[grp] <- "period"
      out_proc_grp_df$proc_grp_label[grp] <- periods[grp_df$beg_per[grp]]

      # Build the processing group header
      msg_str <- paste0(solve_word, " period [", out_proc_grp_df$proc_grp_label[grp], "]")

      # Define the constraint elements
      bl$A <- pb$A1
      bl$op <- pb$op1
      bl$b <- pb$b1
      bl$b_tol <- rep.int(tolV, n_con)

      non_fully_binding <- integer(0L)
      n_a <- 0
    }


    # Display the processing group header
    grp_msg_func("\n\n", msg_str)
    grp_msg_func(strrep("=", nchar(msg_str)), "\n")


    # Convert the balancing problem into a (reduced) QP problem (for OSQP):
    #   - construct the QP problem's Hessian matrix (`P`) and vector of linear coefficients (`q`)
    #   - rewrite the balancing constraints as `l <= Ax <= u` linear constraints. transferring binding values 
    #     (`c * x = 0`) into the constraints bounds (`l` and `u`)
    #   - add `l <= Ax <= u` linear constraints for and upper/lower bounds
    qp <- build_reduced_qp(bl$x, bl$c, bl$lb, bl$ub, bl$bd_tol,  # problem variables info
                           bl$A, bl$op, bl$b, bl$b_tol)          # problem constraints info
    n_con_qp <- length(qp$l)

    
    # Calculate the initial discrepancies
    Ax_ini <- qp$A %*% qp$x
    discr_ini <- calc_discr(Ax_ini, qp$l, qp$u)
    

    # Solve the balancing problem
    sol <- solve_func(x = qp$x,                                          # initial problem values (initial solution)
                      Ax = Ax_ini,                                       # evaluated constraint body values with the initial solution
                      discr = discr_ini,                                 # initial constraint discrepancies list
                      validation_tol = validation_tol,                   # solution validation tolerance (max. allowed constraint discr.)
                      P = qp$P, q = qp$q, A = qp$A, l = qp$l, u = qp$u,  # OSQP problem elements
                      settings_df = settings_df,                         # OSQP settings sequence data frame
                      full_sequence = full_sequence,                     # (logical) perform all steps (rows) of `settings_df`
                      solve_msg_func = solve_msg_func,                   # (function) message display function
                      osqpBeg_display_func = osqpBeg_display_func,       # (function) OSQP model and iterations display set up function
                      osqpEnd_display_func = osqpEnd_display_func,       # (function) OSQP model and iterations display wrap up function
                      osqp_output_file = osqp_output_file,               # temporary file (name and path) for the OSQP model and iterations contents
                      trunc_to_zero_tol = trunc_to_zero_tol)             # tolerance for changing nonzero solution data points to 0

    # Set the balancing solution:
    #  - initial solution (`bl$x`) for binding values
    #  - returned solution (`sol$x`) for nonbinding values
    x_out <- bl$x
    x_out[qp$id_x] <- sol$x

    # Cumulate the solutions
    out_mat[per_id_vec, ] <- matrix(x_out[1:n_values_grp], ncol = n_ser)


    # Create the problem values data frame
    prob_val_df <- data.frame(
      proc_grp = rep.int(grp, length(bl$x)),
      val_type = rep.int(c("period value", "temporal total"), c(n_values_grp, n_a)),
      name = c(rep(pb$ser_names, each = n_per_grp), pb$ser_names[non_fully_binding]),
      t = c(rep.int(per_id_vec, n_ser), rep.int(per_id_vec[1], n_a)),
      time_val = c(rep.int(time_values[per_id_vec], n_ser), rep.int(time_values[per_id_vec[1]], n_a)),
      lower_bd = bl$lb,
      upper_bd = bl$ub,
      alter = bl$c,
      value_in = bl$x,
      value_out = x_out,
      dif = x_out - bl$x,
      rdif = gs.calc_relDiff(x_out, bl$x)
    )


    # Create the problem constraints info data frame
    prob_con_df <- data.frame(
      proc_grp = rep.int(grp, n_con_qp),
      con_type = rep.int(c("balancing constraint",
                           "temporal aggregation constraint",
                           "period value bounds"),
                         c(n_con * n_per_grp,
                           n_a,
                           length(qp$id_bd_con))),
      name = c(rep(pb$labels_df$row[pb$labels_df$con.flag], each = n_per_grp),
               pb$ser_names[non_fully_binding],
               prob_val_df$name[qp$id_bd_con]),
      t = c(rep.int(per_id_vec, n_con),
            rep.int(per_id_vec[1], n_a),
            prob_val_df$t[qp$id_bd_con]),
      time_val = c(rep.int(time_values[per_id_vec], n_con),
                   rep.int(time_values[per_id_vec[1]], n_a),
                   prob_val_df$time_val[qp$id_bd_con]),
      l = qp$l,
      u = qp$u,
      Ax_in = as.vector(Ax_ini),
      Ax_out = as.vector(sol$Ax),
      discr_in = discr_ini$discr_vec,
      discr_out = sol$discr$discr_vec,
      validation_tol = rep.int(validation_tol, n_con_qp),
      unmet_flag = (sol$discr$discr_vec > validation_tol)
    )


    # Fill in the processing groups data frame and both OSQP info data frames
    out_proc_grp_df$sol_status[grp] <- sol$status
    out_proc_grp_df$sol_status_val[grp] <- sol$status_val
    n_unmet <- sum(prob_con_df$unmet_flag)
    out_proc_grp_df$n_unmet_con[grp] <- n_unmet
    out_proc_grp_df$max_discr[grp] <- sol$discr$max_discr
    out_proc_grp_df$sol_type[grp] <- sol$type
    out_proc_grp_df$total_solve_time[grp] <- sol$seq_time
    if (!is.null(sol$osqp_info)) {
      out_proc_grp_df$osqp_attempts[grp] <- sol$osqp_attempts
      out_proc_grp_df$osqp_seqno[grp] <- sol$osqp_seqno
      out_proc_grp_df$osqp_status[grp] <- sol$osqp_info$status
      out_proc_grp_df$osqp_polished[grp] <- sol$osqp_info$status_polish == 1
      out_osqp_settings_df <- rbind(out_osqp_settings_df, as.data.frame(c(list(proc_grp = grp), sol$osqp_settings)))
      out_osqp_sol_info_df <- rbind(out_osqp_sol_info_df,
                                    as.data.frame(c(
                                      list(proc_grp = grp),
                                      sol$osqp_info,
                                      # Calculate the original balancing problem's objective value
                                      list(obj_val_ori_prob = 
                                             sol$osqp_info$obj_val * sol$osqp_info$prior_scaling_factor  # original scale
                                             + sum(-0.5 * qp$q * qp$x)))))                               # constant terms
    }


    # Sort, display and cumulate the problem values and constraints info data frames
    prob_val_df <- prob_val_df[order(rep.int(1:2, c(n_values_grp, n_a)),
                                     prob_val_df$t,
                                     c(rep(1:n_ser, each = n_per_grp), seq_len(n_a)))
                               , ]
    out_prob_val_df <- rbind(out_prob_val_df, prob_val_df)
    prob_con_df <- prob_con_df[order(
      # 1- constraint type (periods, then temporal totals)
      rep.int(c(1, 2, 1), c(n_con * n_per_grp,
                                  n_a,
                                  length(qp$id_bd_con))),
      # 2- period
      prob_con_df$t,
      # 3- constraint sub-type
      rep.int(c(1, 3, 2), c(n_con * n_per_grp,
                            n_a,
                            length(qp$id_bd_con))),
      # 4- constraint/series name (keeping this initial order)
      c(rep(1:n_con, each = n_per_grp),
        seq_len(n_a),
        seq_along(qp$id_bd_con)))
      , ]
    out_prob_con_df <- rbind(out_prob_con_df, prob_con_df)
    results_display_func()
    
    # Validate the solution
    if (n_unmet > 0) {
      warning("Constraints were not met in ", n_unmet, " occasion(s). Maximum discrepancy: ",
              format(sol$discr$max_discr, big.mark = ","), ". See constraints with `unmet_flag = TRUE` ",
              "for details.\n", call. = FALSE, immediate. = TRUE)
      warning_flag <- TRUE
    }
  }


  # Create the output list
  out_ts <- in_ts
  out_ts[, pb$ser_names] <- out_mat
  out_list$out_ts <- out_ts
  row.names(out_proc_grp_df) <- NULL
  out_list$proc_grp_df <- out_proc_grp_df
  out_list$periods_df <- data.frame(
    # `sapply()` is safe: it always returns a numeric vector (`grp_df$grp` is of length minimum 1)
    proc_grp = rep.int(grp_df$grp, sapply(grp_df$grp, function(ii) length(grp_df$beg_per[ii]:grp_df$end_per[ii]))),
    t = 1:n_per,
    time_val = time_values)
  row.names(out_prob_val_df) <- NULL
  out_list$prob_val_df <- out_prob_val_df
  row.names(out_prob_con_df) <- NULL
  out_list$prob_con_df <- out_prob_con_df
  row.names(out_osqp_settings_df) <- NULL
  out_list$osqp_settings_df <- out_osqp_settings_df
  row.names(out_osqp_sol_info_df) <- NULL
  out_list$osqp_sol_info_df <- out_osqp_sol_info_df


  if (final_msg_flag && warning_flag) {
    warning("Warnings were generated during processing. See relevant message(s) for details.\n",
            call. = FALSE, immediate. = TRUE)
  }

  # Output object returned via function `on.exit()`
}


#' Build the elements of balancing problems.
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/build_balancing_problem.html}})}
#' 
#' This function is used internally by [tsbalancing()] to build the elements of the balancing problems. 
#' It can also be useful to derive the indirect series associated to equality balancing constraints manually 
#' (outside of the [tsbalancing()] context). 
#' 
#' 
#' @inheritParams tsbalancing
#' 
#' @param in_ts_name (optional) 
#' 
#' String containing the value of argument `in_ts`.
#'
#' **Default value** is `in_ts_name = deparse1(substitute(in_ts))`.
#' 
#' @param ts_freq (optional)
#' 
#' Frequency of the time series object (argument `in_ts`).
#' 
#' **Default value** is `ts_freq = stats::frequency(in_ts)`.
#' 
#' @param periods (optional) 
#' 
#' Character vector describing the time series object (argument `in_ts`) periods.
#' 
#' **Default value** is `periods = gs.time2str(in_ts)`.
#' 
#' @param n_per (optional) 
#' 
#' Number of periods of the time series object (argument `in_ts`).
#' 
#' **Default value** is `n_per = nrow(as.matrix(in_ts))`.
#' 
#' @param specs_df_name (optional)
#' 
#' String containing the value of argument `problem_specs_df`.
#' 
#' **Default value** is `specs_df_name = deparse1(substitute(problem_specs_df))`.
#' 
#'
#' @returns
#' A list with the elements of the balancing problems (excluding the temporal totals info):
#' - `labels_df`: cleaned-up version of the _label definition records_ from `problem_specs_df` 
#'                (`type` is not missing (is not `NA`)); extra columns:
#'   - `type.lc` : `tolower(type)`
#'   - `row.lc`  : `tolower(row)` 
#'   - `con.flag`: `type.lc %in% c("eq", "le", "ge")`
#' - `coefs_df` : cleaned-up version of the information specification records from `problem_specs_df` 
#'                (`type` is missing (is `NA`); extra columns:
#'   - `row.lc`  : `tolower(row)` 
#'   - `con.flag`: `labels_df$con.flag` allocated through `row.lc`
#' - `values_ts`: reduced version of `in_ts` with only the relevant series (see vector `ser_names`)
#' - `lb`       : lower bound info (`type.lc  = "lowerbd"`) for the relevant series; list object with the 
#'                following elements:
#'   - `coefs_ts`       : lower bound values for series and period
#'   - `nondated_coefs` : vector of nondated lower bounds from `problem_specs_df` (`timeVal` is `NA`)
#'   - `nondated_id_vec`: vector of `ser_names` id's associated to vector `nondated_coefs`
#'   - `dated_id_vec`   : vector of `ser_names` id's associated to dated lower bounds from 
#'                        `problem_specs_df` (`timeVal` is not `NA`)
#' - `ub`       : `lb` equivalent for upper bounds (`type.lc = "upperbd"`)
#' - `alter`    : `lb` equivalent for period value alterability coefficients (`type.lc = "alter"`)
#' - `altertmp` : `lb` equivalent for temporal total alterability coefficients (`type.lc = "altertmp"`)
#' - `ser_names`: vector of the relevant series names (set of series involved in the balancing constraints)
#' - `pos_ser`  : vector of series names that have only positive nonzero coefficients across all balancing constraints
#' - `neg_ser`  : vector of series names that have only negative nonzero coefficients across all balancing constraints
#' - `mix_ser`  : vector of series names that have both positive and negative nonzero coefficients across all balancing 
#'                constraints
#' - `A1`,`op1`,`b1`: balancing constraint elements for problems involving a single period (e.g., each period of an 
#'                    incomplete temporal group)
#' - `A2`,`op2`,`b2`: balancing constraint elements for problems involving `temporal_grp_periodicity` periods (e.g., the set 
#'                    of periods of a complete temporal group)
#' 
#' 
#' @details
#' See [tsbalancing()] for a detailed description of _time series balancing_ problems.
#' 
#' Any missing (`NA`) value found in the input time series object (argument `in_ts`) would be replaced with 0 in `values_ts` 
#' and trigger a warning message.
#' 
#' The returned elements of the balancing problems do not include the implicit temporal totals (i.e., elements `A2`, `op2` 
#' and `b2` only contain the balancing constraints).
#'       
#' Multi-period balancing problem elements `A2`, `op2` and `b2` (when `temporal_grp_periodicity > 1`) are constructed 
#' _column by column_ (in "column-major order"), corresponding to the default behaviour of R for converting objects of class 
#' "matrix" into vectors. I.e., the balancing constraints conceptually correspond to:
#' - `A1 %*% values_ts[t, ] op1 b1` for problems involving a single period (`t`)
#' - `A2 %*% as.vector(values_ts[t1:t2, ]) op2 b2` for problems involving `temporal_grp_periodicity` periods (`t1:t2`).
#' 
#' Notes:
#' - Argument `alter_temporal` has not been applied yet at this point and `altertmp$coefs_ts` only contains the 
#' coefficients specified in the problem specs data frame (argument `problem_specs_df`). I.e., `altertmp$coefs_ts` contains 
#' missing (`NA`) values except for the temporal total alterability coefficients included in (specified with) `problem_specs_df`. 
#' This is done in order to simplify the identification of the first non missing (non `NA`) temporal total alterability 
#' coefficient of each complete temporal group (to occur later, when applicable, inside [tsbalancing()]).
#' - Argument validation is not performed here; it is (bluntly) assumed that the function is called by [tsbalancing()] 
#' where a thorough validation of the arguments is done.

#'
#'
#' @seealso [tsbalancing()] [build_raking_problem()]
#' 
#' @example misc/function_examples/build_balancing_problem-ex.R
#' 
#' @export
build_balancing_problem <- function(in_ts,
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
                                    validation_only = FALSE) {
  
  
  # Assign non-constraint coefficients from the problem specs data frame.
  # Note: coefs with time values (`timeval`) outside the time series span are ignored
  #
  # Arguments:
  #   - coefs_ts      : 'ts' object to be updated
  #   - label         : string (`coef_df$type.lc` value) identifying the type of coefs to assign
  #
  # Other main (parent) function objects used in this function:
  #   - coefs_df : problem specs coefficients data frame (rows for which `type` is `NA`)
  #   - ser_names: vector of the series names involved in the balancing problem
  #   - n_per    : `nrow(coefs_ts)` = number of periods in the input 'ts' object
  #   - ts_freq  : `frequency(coefs_ts)` = frequency of the input 'ts' object
  #   - periods  : `gs.time2str(coefs_ts)` = vector of period string labels ("<year>-<per>")
  # 
  # Value:
  #   Returns a list of 4 objects:
  #     - coefs_ts       : updated 'ts' object
  #     - nondated_coefs : vector of nondated coefficients (`timeval` is `NA`)
  #     - nondated_id_vec: vector of `ser_names` id's associated to vector `nondated_coefs`
  #     - dated_id_vec   : vector of `ser_names` id's associated to dated coefficient (`timeval` is not `NA`)
  assign_coefs <- function(coefs_ts, label) {
    
    # All periods (`timeval` is `NA`)
    logi_vec <- coefs_df$type.lc == label & is.na(coefs_df$timeval)
    coefs_ts[, coefs_df$col[logi_vec]] <- rep(coefs_df$coef[logi_vec], each = n_per)
    
    # Specific periods (`timeval` is not `NA`)
    id_vec <- which(coefs_df$type.lc == label & !is.na(coefs_df$timeval))
    for (ii in seq_along(id_vec)) {
      coefs_ts[match(gs.time2str(stats::ts(NA, start = coefs_df$timeval[id_vec[ii]], frequency = ts_freq)),
                     periods, nomatch = 0),
               coefs_df$col[id_vec[ii]]] <- coefs_df$coef[id_vec[ii]]
    }
    
    list(coefs_ts = coefs_ts,
         nondated_coefs = coefs_df$coef[logi_vec],
         nondated_id_vec = match(coefs_df$col[logi_vec], ser_names),
         dated_id_vec = match(unique(coefs_df$col[id_vec]), ser_names))
  }
  
  
  ### Main function ###

  
  # Initial clean-up/standardization of the problem specs df:
  #   - convert column names to lowercase
  #   - replace empty strings ("") with `NA` for character columns (`type`, `col`, `row`)
  #   - standardize constraint RHS specification (`col = "_rhs_"`)
  #   - add column `timeval` if not present 
  #     => if column `time_val` is present (without column `timeval`), it is recoded to `timeval`
  in_ts_cols <- colnames(in_ts)
  specsDF_cols <- tolower(names(problem_specs_df))
  names(problem_specs_df) <- specsDF_cols
  core_cols <- c("type", "col", "row", "coef")
  gs.validate_cols(tolower(setdiff(core_cols, specsDF_cols)), NULL, specs_df_name)
  # `sapply()` is safe: it always returns a logical vector of length 3
  logi_vec <- sapply(core_cols[1:3], function(col) !is.character(problem_specs_df[[col]]))
  if (any(logi_vec)) {
    stop("The following problem specs data frame column(s) must be character:",
         paste0("\n  ", core_cols[c(logi_vec, FALSE)], collapse = ""), call. = FALSE)
  }
  if (!is.numeric(problem_specs_df$coef)) {
    stop("Problem specs data frame column `coef` must be numeric.", call. = FALSE)
  }
  problem_specs_df$type <- trimws(problem_specs_df$type)
  problem_specs_df$type[problem_specs_df$type == ""] <- NA
  problem_specs_df$col <- trimws(problem_specs_df$col)
  problem_specs_df$col[problem_specs_df$col == ""] <- NA
  problem_specs_df$col[tolower(problem_specs_df$col) == "_rhs_"] <- "_rhs_"
  problem_specs_df$row <- trimws(problem_specs_df$row)
  problem_specs_df$row[problem_specs_df$row == ""] <- NA
  logi_vec <- c("timeval", "time_val") %in% specsDF_cols
  if (!any(logi_vec)) {
    problem_specs_df$timeval <- NA_real_
  } else {
    if (all(logi_vec == c(FALSE, TRUE))) {
      problem_specs_df$timeval <- problem_specs_df$time_val
    }
    logi_vec <- !is.na(problem_specs_df$timeval)
    if (any(logi_vec)) {
      if (!is.numeric(problem_specs_df$timeval[logi_vec])) {
        stop("Problem specs data frame column `timeVal` must be numeric.", call. = FALSE)
      }
      if (any(!is.finite(problem_specs_df$timeval[logi_vec]))) {
        stop("Invalid time values (column `timeVal`) found in the problem specs data frame (time values must be ",
             "finite real numbers or `NA`).", call. = FALSE)
      }
    } else {
      problem_specs_df$timeval <- NA_real_
    }
  }
  
  
  # Split specs data frame into labels and coefs data frames
  labels_df <- problem_specs_df[!is.na(problem_specs_df$type), c("type", "row"), drop = FALSE]
  coefs_df <- problem_specs_df[is.na(problem_specs_df$type), c("col", "row", "coef", "timeval"), drop = FALSE]
  
  # Initial (basic) problems specs validation
  if (any(is.na(labels_df$row))) {
    stop("Invalid label definition record found in the problem specs data frame (missing `row` value).", call. = FALSE)
  }
  if (any(is.na(coefs_df$col) | is.na(coefs_df$row))) {
    stop("Invalid information specification record found in the problem specs data frame ",
         "(missing `col` or `row` value).", call. = FALSE)
  }
  # Reject (ignore) missing (`NA`) coefs
  coefs_df <- coefs_df[!is.na(coefs_df$coef), , drop = FALSE]
  
  # Cleanup the labels (lowercase version of columns `type` and `row`)
  # => Allow the following lowercase `type` values (convert them to the expected lowercase value):
  #    - "==" and "=" for "eq"
  #    - "<=" and "<" for "le"
  #    - ">=" and ">" for "ge"
  #    - "lower" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "lowerbd"
  #    - "upper" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "upperbd"
  #    - "alter" + ("" or "_" or "-" or "." or " ") + ("tmp" or "temp" or "temporal) for "altertmp"
  labels_df$type.lc <- sub(sub(sub(sub(sub(tolower(labels_df$type), 
                                           pattern = "^(==|=)$", 
                                           replacement = "eq", 
                                           perl = TRUE),
                                       pattern = "^(<=|<)$", 
                                       replacement = "le", 
                                       perl = TRUE),
                                   pattern = "^(>=|>)$", 
                                   replacement = "ge", 
                                   perl = TRUE),
                               pattern = "^(lower|upper)[\\.[:blank:]_-]?(bd|bnd|bound)$", 
                               replacement = "\\1bd", 
                               perl = TRUE),
                           pattern = "^alter[\\.[:blank:]_-]?(tmp|temp|temporal)$", 
                           replacement = "altertmp", 
                           perl = TRUE)
  labels_df$row.lc <- tolower(labels_df$row)
  coefs_df$row.lc <- tolower(coefs_df$row)
  labels_df$con.flag <- labels_df$type.lc %in% c("eq", "le", "ge")
  coefs_df$con.flag <- coefs_df$row.lc %in% unique(labels_df$row.lc[labels_df$con.flag])
  
  # Get the list of series involved in balancing constraints
  ser_names <- unique(coefs_df$col[coefs_df$con.flag & coefs_df$col != "_rhs_" & coefs_df$coef != 0])
  n_ser <- length(ser_names)
  if (n_ser == 0) {
    stop("The problem specs data frame must include at least one valid (non-empty) balancing constraint.", call. = FALSE)
  }
  missing_cols <- setdiff(ser_names, in_ts_cols)
  if (length(missing_cols) > 0) {
    stop("The following series, listed in balancing constraints in the problem specs data frame, are missing from ",
         "input 'ts' object \"", in_ts_name, "\": ", paste0("\n  ", missing_cols, collapse = ""), call. = FALSE)
  }
  # Order `ser_names` according to the input time series columns
  ser_names <- intersect(in_ts_cols, ser_names)
  
  # Keep only the relevant info from the problem specification data frame: info related to the
  # "balancing problem series", i.e., the set of series involved in the balancing constraint.
  coefs_df <- coefs_df[
    # coefs of relevant series (involved in balancing constraints)
    coefs_df$col %in% ser_names & (!coefs_df$con.flag | coefs_df$con.flag & coefs_df$coef != 0)
    # RHS values for relevant constraints (involving at least one series)
    | coefs_df$col == "_rhs_" & coefs_df$row.lc %in% unique(coefs_df$row.lc[coefs_df$con.flag & coefs_df$col %in% ser_names])
    , , drop = FALSE]
  row.names(coefs_df) <- NULL
  labels_df <- labels_df[labels_df$row.lc %in% unique(coefs_df$row.lc), , drop = FALSE]
  row.names(labels_df) <- NULL
  
  # Bring the type labels in the coefs data frame
  coefs_df <- merge(labels_df[c("type.lc", "row.lc")], coefs_df, by = "row.lc", all = TRUE, sort = FALSE)
  
  
  # Extra problems specs validation (more in-depth validation for the remaining relevant info)
  
  # Invalid problem elements
  invalid_types <- setdiff(unique(labels_df$type.lc), c("eq", "le", "ge", "lowerbd", "upperbd", "alter", "altertmp"))
  if (length(invalid_types) > 0) {
    stop("The following invalid problem elements ('type' column values in lowercase) were found in the problem specs data frame: ",
         paste0("\n  ", invalid_types, collapse = ""), call. = FALSE)
  }
  
  # Invalid labels
  invalid_labels <- unique(coefs_df$row.lc[is.na(coefs_df$type.lc)])
  if (length(invalid_labels) > 0) {
    stop("The following labels ('row' column values in lowercase) in the problem specs data frame have not been properly ",
         "defined (no coresponding \"label definition record\"): ", paste0("\n  ", invalid_labels, collapse = ""),
         call. = FALSE)
  }
  
  # Duplicate labels
  if (any(table(labels_df$row.lc) > 1)) {
    stop("The problem specs data frame contains duplicate labels, i.e., same 'row' value used for several ",
         "problem elements (`type` values).", call. = FALSE)
  }
  
  # Duplicate label definition records for non-constraint elements
  if (any(table(labels_df$type.lc[!labels_df$con.flag]) > 1)) {
    stop("The problem specs data frame contains duplicate label definition records for non-constraint elements ",
         "(i.e., a given non-constraint `type` value is assigned a `row` value more than once).", call. = FALSE)
  }
  
  # Specified time values (`timeval`) for constraints
  if (any(coefs_df$con.flag & !is.na(coefs_df$timeval))) {
    stop("Time values (column `timeVal` in the problem specs data frame) cannot be specified for constraint ",
         "coefficients or RHS values.", call. = FALSE)
  }
  
  # Invalid numeric `coef` values:
  #   - constraint coefficients  : infinite
  #   - alterability coefficients: negative or infinite
  #   - lower bound              : Inf
  #   - upper bound              : -Inf
  if (any(!is.finite(coefs_df$coef[coefs_df$con.flag]))) {
    stop("Invalid constraint coefficients (column `coef`) found in the problem specs data frame (constraint ",
         "coefficients must be finite real numbers).", call. = FALSE)
  }
  logi_vec <- (coefs_df$type.lc %in% c("alter", "altertmp"))
  if (any(!is.finite(coefs_df$coef[logi_vec]) | coefs_df$coef[logi_vec] < 0)) {
    stop("Invalid alterability coefficients (column `coef`) found in the problem specs data frame (alterability ",
         "coefficients must be nonnegative finite real numbers).", call. = FALSE)
  }
  if (any(coefs_df$coef[coefs_df$type.lc == "lowerbd"] == Inf)) {
    stop("Invalid period value lower bounds (column `coef`) found in the problem specs data frame (lower bounds ",
         "must be a finite real number or -Inf).", call. = FALSE)
  }
  if (any(coefs_df$coef[coefs_df$type.lc == "upperbd"] == -Inf)) {
    stop("Invalid period value upper bounds (column `coef`) found in the problem specs data frame (upper bounds ",
         "must be a finite real number or Inf).", call. = FALSE)
  }
  
  # Duplicate coefficient specification
  if (any(table(coefs_df[c("col", "row.lc", "timeval")], useNA = "always") > 1)) {
    stop("The problem specs data frame contains duplicate information specification records, i.e., multiple 'coef' values ",
         "for a given set of `col` (time series or constraint RHS), `row` (problem element) and 'timeVal' values.",
         call. = FALSE)
  }
  
  # 'Reduce the input 'ts' 'in_ts' version with only the relevant series
  values_ts <- in_ts[, ser_names, drop = FALSE]
  logi_vec <- is.na(values_ts)
  if (sum(logi_vec) > 0) {
    warning("Missing data were found in the input 'ts' object. They were replaced with 0.",
            call. = FALSE, immediate. = TRUE)
    values_ts[logi_vec] <- 0
  }
  
  
  # Assign the lower/upper bounds
  lb <- list(coefs_ts = values_ts)
  lb$coefs_ts[, ] <- lower_bound
  lb <- assign_coefs(lb$coefs_ts, "lowerbd")
  ub <- list(coefs_ts = values_ts)
  ub$coefs_ts[, ] <- upper_bound
  ub <- assign_coefs(ub$coefs_ts, "upperbd")
  if (any(lb$coefs_ts > ub$coefs_ts)) {
    stop("Incompatible period value bounds (column `coef`) specified in the problem specs data frame (lower bounds ",
         "cannot be greater than upper bounds).", call. = FALSE)
  }
  
  # Assign the alterability coefficients
  alter <- list(coefs_ts = values_ts)
  alter$coefs_ts[, ] <- NA_real_
  altertmp <- alter
  if (!validation_only) {
    
    # Default (function arguments `alter_pos`, `alter_neg` and `alter_mix`)
    pos_ser <- unique(coefs_df$col[coefs_df$con.flag & coefs_df$col != "_rhs_" & coefs_df$coef > 0])
    neg_ser <- unique(coefs_df$col[coefs_df$con.flag & coefs_df$col != "_rhs_" & coefs_df$coef < 0])
    mix_ser <- intersect(pos_ser, neg_ser)
    pos_ser <- setdiff(pos_ser, mix_ser)
    neg_ser <- setdiff(neg_ser, mix_ser)
    alter$coefs_ts[, pos_ser] <- alter_pos
    alter$coefs_ts[, neg_ser] <- alter_neg
    alter$coefs_ts[, mix_ser] <- alter_mix
    
    # From the problem specs data frame
    alter <- assign_coefs(alter$coefs_ts, "alter")
    altertmp <- assign_coefs(altertmp$coefs_ts, "altertmp")
    # Note: as opposed to the period value alter coefs (`alter$coefs_ts`), the default temporal total 
    #       alterability coefficients (`altertmp$coefs_ts`) for cases not specified in the problem specs 
    #       data frame remain `NA` for now (i.e., argument `alter_temporal` is not used right away).
    #       This will allow for easy identification of the first specified temporal total alter coef in the specs 
    #       (when applicable) inside a complete temporal group.
    
  } else {
    pos_ser <- character(0L)
    neg_ser <- character(0L)
    mix_ser <- character(0L)
    alter <- c(alter, list(nondated_coefs = numeric(0L),
                           nondated_id_vec = integer(0L),
                           dated_id_vec = integer(0L)))
    altertmp <- c(altertmp, list(nondated_coefs = numeric(0L),
                                 nondated_id_vec = integer(0L),
                                 dated_id_vec = integer(0L)))
  }
  
  
  # Build the initial version of problem constraints elements:
  #   - matrix `A` : balancing constraint coefficients matrix
  #   - vector `op`: balancing constraint operator strings ("==", "<=" or ">=")
  #   - vector `b` : balancing constraint RHS
  #
  # Two versions of these elements are built:
  #   - <obj>1: for single period processing (incomplete temporal groups or period-by-period processing)
  #   - <obj>2: for multiple periods processing (complete temporal groups)
  #
  # Note: these constraint elements will eventually be "augmented" for OSQP to implement:
  #         - (implicit) temporal aggregation constraints (for complete temporal groups)
  #         - period value (lower/upper) bounds
  #
  con_labels <- labels_df$row.lc[labels_df$con.flag]
  n_con <- length(con_labels)
  A1 <- matrix(0, nrow = n_con, ncol = n_ser)
  A2 <- matrix(0, nrow = n_con * temporal_grp_periodicity, ncol = n_ser * temporal_grp_periodicity)
  for (ii in 1:n_con) {
    logi_vec <- coefs_df$row.lc == con_labels[ii] & coefs_df$col != "_rhs_"
    id_vec <- match(coefs_df$col[logi_vec], ser_names)
    A1[ii, id_vec] <- coefs_df$coef[logi_vec]
    for (jj in 1:temporal_grp_periodicity) {
      A2[(ii - 1) * temporal_grp_periodicity + jj, (id_vec - 1) * temporal_grp_periodicity + jj] <- coefs_df$coef[logi_vec]
    }
  }
  b1 <- rep.int(0, n_con)
  b1[match(coefs_df$row.lc[coefs_df$col == "_rhs_"], con_labels)] <- coefs_df$coef[coefs_df$col == "_rhs_"]
  b2 <- b1[rep(1:n_con, each = temporal_grp_periodicity)]
  op1 <- labels_df$type.lc[labels_df$con.flag]
  op1[op1 == "eq"] <- "=="
  op1[op1 == "le"] <- "<="
  op1[op1 == "ge"] <- ">="
  op2 <- op1[rep(1:n_con, each = temporal_grp_periodicity)]
  
  
  # Return the balancing problem core elements (building blocks)
  list(labels_df = labels_df,
       coefs_df = coefs_df,
       values_ts = values_ts,
       lb = lb,
       ub = ub,
       alter = alter,
       altertmp = altertmp,
       ser_names = ser_names,
       pos_ser = pos_ser,
       neg_ser = neg_ser,
       mix_ser = mix_ser,
       A1 = A1,
       op1 = op1,
       b1 = b1,
       A2 = A2,
       op2 = op2,
       b2 = b2)
}


#' Convert a time series balancing problem into a QP problem for OSQP.
#'
#' Balancing problem values arguments (numeric vectors of size `n`) including time series
#' temporal totals (when applicable)
#' @param x vector of initial values
#' @param c vector of alterability coefficients
#' @param lb,ub vectors of lower/upper bounds (`-Inf` or `Inf` correspond to no bounds)
#' @param bd_tol vector of tolerances for lower/upper bounds (0 corresponds to no tolerance)
#'
#' Balancing problem constraints arguments (matrices and vectors of size `m X n` and `m`)
#' including the implicit temporal aggregation constraints (when applicable)
#' @param A left-hand-side matrix (numeric)
#' @param op vector of operators (character: "==", "<=" or ">=")
#' @param b vector of right-hand side values (numeric)
#' @param b_tol vector of right-hand side value tolerances (0 corresponds to no tolerance)
#'
#' @returns
#' Elements of the (reduced) QP problem for OSQP:
#'   - P    : Hessian (quadratic coefficients) matrix
#'   - q    : vector of linear coefficients
#'   - A,l,u: constraints matrix and bounds (`l <= Ax <= u`)
#' Additional information:
#'   - x        : reduced problem initial values (input vector `x` stripped of the binding values)
#'   - id_x     : id's of input vector `x` corresponding to the reduced problem values
#'   - id_bd_con: id's of input vector `x` corresponding to the lower/upper bound constraints
#'
#' @details
#' The returned QP problem corresponds the balancing problem in its "reduced form" where binding values 
#' (`c * x = 0`) are removed from the problem and transferred into the constraints bounds (`l` and `u`) 
#' instead. 
#' 
#' Construct the reduced QP problem's Hessian matrix (`P`) and vector of linear coefficients (`q`), 
#' rewrite the balancing constraints as `l <= Ax <= u` linear constraints, i.e.,
#'   - `l = b - b_tol` and `u = b + b_tol` for "==" constraints,
#'   - `l = -Inf` and `u = b + b_tol` for "<=" constraints,
#'   - `l = b - b_tol` and `u = Inf` for ">=" constraints,
#' and define additional `l <= Ax <= u` linear constraints for lower/upper bounds, i.e.,
#'   - `l = lb - bd_tol` and `u = Inf` for lower bounds (w/o upper bounds),
#'   - `l = -Inf` and `u = ub + bd_tol` for upper bounds (w/o lower bounds),
#'   - `l = lb - bd_tol` and `u = ub + bd_tol` for both lower AND upper bounds.
#'   
#' Fixed QP problems (`validation_only = TRUE` or all values of `x` are binding) have missing (`NA`) values 
#' for `P` and `q` and should not be sent to OSQP (the initial solution should be returned).
#'
#' @noRd
build_reduced_qp <- function(x, c, lb, ub, bd_tol,  # problem variables info
                             A, op, b, b_tol) {     # problem constraints info
  
  # Initial number of constraints (`dim_A[1]`) and variables (`dim_A[2]`)
  dim_A <- dim(A)

  # Identify the set of free (nonbinding) problem values (when in "solving mode", i.e., `validation_only = FALSE`)
  # => alterability coefficients are all `NA` when in "validation mode" (`validation_only = TRUE`)
  logi_vec <- !is.na(c) & (x * c) != 0

  # Reduce the problem for fixed (binding) values
  if (any(logi_vec)) {
    id_x <- which(logi_vec)

    # Update the constraints given the fixed (binding) values:
    #   - adjust the constraint RHS (`b`) values
    #   - remove the corresponding column from constrain coefficients matrix (`A`)
    b <- b - A[, !logi_vec, drop = FALSE] %*% x[!logi_vec]
    A <- A[, id_x, drop = FALSE]
    dim_A[2] <- length(id_x)
    
    # QP problem quadratic coefficients (Hessian) matrix and vector of linear coefficients
    w <- 1 / abs(c[id_x] * x[id_x])
    P <- diag(2 * w, nrow = dim_A[2])
    q <- -2 * w * x[id_x]

  # Fixed problem (`validation_only = TRUE` or all values are binding) => do not reduce the problem
  } else {
    id_x <- seq_along(x)

    # (dummy) QP problem quadratic coefficients (Hessian) matrix and vector of linear coefficients
    # (won't be sent to OSQP for solving anyway)
    P <- as.matrix(NA_real_)
    q <- NA_real_
  }

  # Transform constraint RHS values (`b`) into `l` and `u` vectors (constraints lower/upper bounds)
  l <- rep.int(-Inf, dim_A[1])
  u <- rep.int(Inf, dim_A[1])
  logi_vec <- op != "<="
  l[logi_vec] <- b[logi_vec] - b_tol[logi_vec]
  logi_vec <- op != ">="
  u[logi_vec] <- b[logi_vec] + b_tol[logi_vec]
  
  # Add constraints for period value lower/upper bounds.
  logi_vec <- lb[id_x] != -Inf | ub[id_x] != Inf
  if (any(logi_vec)) {
    # Note regarding both vectors of id's defined here:
    #   - `id_bd`    : id's of the output 'x' vector (reduced problem)
    #   - `id_bd_con`: id's of the input 'x' vector (full scale problem)
    id_bd <- which(logi_vec)
    id_bd_con <- id_x[id_bd]
    n_bd <- length(id_bd)
    
    # Initial transposed matrix (0 values) for the new rows (new columns in this transposed matrix)
    tmp_mat <- matrix(0, nrow = dim_A[2], ncol = n_bd)
    
    # Set the proper matrix elements to 1 (column-major order)
    tmp_mat[id_bd + seq.int(from = 0, by = dim_A[2], length.out = n_bd)] <- 1
    
    # Add the new constraints
    A <- rbind(A, t(tmp_mat))
    l <- c(l, lb[id_bd_con] - bd_tol[id_bd_con])  # `-Inf` minus any value remains `-Inf`
    u <- c(u, ub[id_bd_con] + bd_tol[id_bd_con])  #  `Inf`  plus any value remains  `Inf`
  } else {
    id_bd_con <- integer(0L)
  }

  # Return the reduced QP problem info
  list(P = P,
       q = q,
       A = A,
       l = l,
       u = u,
       x = x[id_x],
       id_x = id_x,
       id_bd_con = id_bd_con)
}


#' Calculate the balancing problem discrepancies
#'
#' @description
#' Calculate the discrepancies of a solution given a set of linear constraints
#' (`l <= Ax <= u`)
#'
#' @param Ax (vector) evaluated constraint body values.
#' @param l,u (vector) constraint lower and upper bounds.
#'
#' @return a list of three elements:
#'   - `discr_vec`: vector of constraint discrepancies (length `n`)
#'   - `max_discr`: maximum constraint discrepancy (`max(discr_vec)`)
#'   - `tot_discr`: sum of all constraint discrepancies (`sum(discr_vec)`)
#'
#' @details
#' Compare the evaluated constraints body (`Ax`) against the constraints bounds
#' (`l` and `u`). Discrepancies are positive values representing constraint bounds 
#' *violations*. A discrepancy of 0 means that the corresponding constraint bounds 
#' are fully respected.
#'   - Equality (`==`) constraints have `l = u`
#'   - Inequality (`<=` or `>=`) constraints either have `l = -Inf` or `u = Inf`
#' A given constraint discrepancy corresponds to `max(l - Ax, Ax - u, 0)`
#'
#' @noRd
calc_discr <- function(Ax, l, u) {
  
  discr_vec <- pmax.int(l - Ax, Ax - u, 0)
  list(discr_vec = discr_vec,
       max_discr = max(discr_vec),
       tot_discr = sum(discr_vec))
}


#' Return the Initial Solution
#' 
#' @description
#' Do not solve the balancing problem. Simply return the initial solution info.
#'
#' @param x (double vector) initial problem values (initial solution).
#' @param Ax (double vector) initial evaluated constraint body values.
#' @param discr (list) initial constraint discrepancies list.
#' @param validation_tol (double) solution validation tolerance (max. allowed constraint discr.).
#' @param ... receptacle for other (ignored) `solve_one_osqp()` arguments.
#'
#' @return a list with the following elements elements:
#'   - `x`: (double vector) initial solution.
#'   - `status`: (string) solution status description.
#'   - `status_val`: (integer) solution status value.
#'   - `Ax`: (double vector) evaluated constraint body values with the initial solution.
#'   - `discr`: (list) initial constraint discrepancies.
#'   - `type`: (string) solution type (`"initial"`).
#'   - `osqp_attempts`: (integer) number of OSQP attempts (`0`).
#'   - `osqp_seqno`: (integer) sequence (iteration) number of the OSQP solution (`NA`).
#'   - `osqp_settings`: (list) OSQP solution settings (`NULL`).
#'   - `osqp_info`: (list) OSQP solution info (`NULL`).
#'   - `seq_time`: solving sequence execution time in seconds.
#'
#' @details
#' This function is used when main argument `validation_only = TRUE`
#'
#' @noRd
return_initial_sol <- function(x,
                               Ax,
                               discr,
                               validation_tol,
                               ...) {

  start_time <- Sys.time()
  
  if (discr$max_discr <= validation_tol) {
    status <- "valid initial solution"
    status_val <- 1
  } else {
    status <- "invalid initial solution"
    status_val <- -1
  }
  
  list(x = x,
       status = status,
       status_val = status_val,
       Ax = Ax,
       discr = discr,
       type = "initial",
       osqp_attempts = 0,
       osqp_seqno = NA_integer_,
       osqp_settings = NULL,
       osqp_info = NULL,
       seq_time = Sys.time() - start_time)
}


#' Solve the balancing problem
#' 
#' @description
#' Solve a single balancing problem with OSQP.
#'
#' @param x (double vector) initial problem values (initial solution).
#' @param Ax (double vector) evaluated constraint body values with the initial solution.
#' @param discr (list) initial constraint discrepancies list.
#' @param validation_tol (double) solution validation tolerance (max. allowed constraint discr.).
#' @param P,q,A,l,u (double matrix, vector, matrix, vector and vector) OSQP problem elements.
#' @param settings_df (data.frame) OSQP settings sequence data frame.
#' @param full_sequence (logical) perform all steps (rows) of `settings_df`.
#' @param solve_msg_func (function) message display function.
#' @param osqpBeg_display_func (function) OSQP model and iterations display set up function.
#' @param osqpEnd_display_func (function) OSQP model and iterations display wrap up function.
#' @param osqp_output_file (string) temporary file (name and path) for the OSQP model and iterations contents.
#' @param trunc_to_zero_tol (double) tolerance for changing nonzero solution data points to 0.
#' 
#' @return a list with the following elements elements:
#'   - `x`: (double vector) final solution.
#'   - `status`: (string) solution status description.
#'   - `status_val`: (integer) solution status value.
#'   - `Ax`: (double vector) evaluated constraint body values with the final solution.
#'   - `discr`: (list) final constraint discrepancies list.
#'   - `type`: (string) solution type (`"initial"` or `"osqp"`).
#'   - `osqp_attempts`: (integer) number of OSQP attempts.
#'   - `osqp_seqno`: (integer) sequence (iteration) number of the OSQP solution (`NA` if `type = "initial"`).
#'   - `osqp_settings`: (list) OSQP solution settings (`NULL` if `type = "initial"`).
#'   - `osqp_info`: (list) OSQP solution info (`NULL` if `type = "initial"`).
#'   - `seq_time`: solving sequence execution time in seconds.
#'
#' @details
#' This function is used when main argument `validation_only = FALSE`
#'
#' The settings data frame (argument `settings_df`) dictates the total number of attempts made
#' at solving the problem. Each attempt is made with the list of OSQP settings for the corresponding
#' `settings_df` observation (row). Unless a full sequence is specified (argument `full_sequence = TRUE`), 
#' the solving sequence stops as soon as a valid solution is obtained (a solution for which all constraint 
#' discrepancies are smaller or equal to the tolerance specified with argument `validation_tol`) unless setting 
#' `require_polished = TRUE` is specified in the settings data frame for that step, in which case a polished 
#' solution from OSQP (`status_polish = 1`) would also be required to stop the sequence. 
#' 
#' Note that the constraint discrepancies are calculated on the *zero truncated* solution values, when applicable 
#' (i.e., when argument `trunc_to_zero_tol > 0`), therefore ensuring accurate validation of the final solution.
#'
#' @noRd
solve_one_osqp <- function(x,
                           Ax,
                           discr,
                           validation_tol,
                           P, q, A, l, u,
                           settings_df,
                           full_sequence,
                           solve_msg_func,
                           osqpBeg_display_func,
                           osqpEnd_display_func,
                           osqp_output_file,
                           trunc_to_zero_tol) {


  start_time <- Sys.time()
  
  # Print the initial solution discrepancies
  solve_msg_func("  Initial solution:\n    - Maximum discrepancy = ", format(discr$max_discr, big.mark = ","),
                 "\n    - Total discrepancy   = ", format(discr$tot_discr, big.mark = ","), "\n")

  
  # No initial discrepancies: return the initial solution
  if (discr$tot_discr <= gs.min_tolerance) {
    
    solve_msg_func("  No discrepancies. Returning the intial values.\n")
    
    status <- "valid initial solution"
    status_val <- 1
    type <- "initial"
    osqp_attempts <- 0
    osqp_seqno <- NA_integer_
    osqp_settings <- NULL
    osqp_info <- NULL

    
  # Fixed problem (all values are either 0 or binding): return the initial solution
  } else if (any(is.na(q))) {
    
    if (discr$max_discr <= validation_tol) {
      solve_msg_func("  Fixed balancing problem (all values are either 0 or binding) with a valid initial solution (maximum discrepancy <= ", 
                     format(validation_tol), " = `validation_tol`).\n")
      status <- "valid initial solution"
      status_val <- 1
    } else {
      warning("Unsolvable fixed balancing problem (all values are either 0 or binding) with an invalid initial solution (maximum discrepancy > ", 
              format(validation_tol), " = `validation_tol`).", call. = FALSE, immediate. = TRUE)
      message("\n")
      status <- "unsolvable fixed problem"
      status_val <- -4
    }
    type <- "initial"
    osqp_attempts <- 0
    osqp_seqno <- NA_integer_
    osqp_settings <- NULL
    osqp_info <- NULL


  # At least one free (nonbinding) value: try to solve with OSQP
  } else {
    
    # Note regarding flags `valid` and `satisfactory` used for the OSQP solving loop:
    #  - `valid`       : is TRUE if a valid solution (`max_discr <= validation_tol`) hasbeen found (initial or OSQP).
    #  - `satisfactory`: is TRUE if a satisfactory OSQP solution (`valid & polished` when required, `valid` otherwise) 
    #                    has been found.
    #
    # `satisfactory == TRUE` stops the solving loop (unless 'full_sequence == TRUE`); it is therefore initialized to 
    # `FALSE` here (as we hope to improve the initial solution with OSQP).
    satisfactory <- FALSE
    if (discr$max_discr <= validation_tol) {
      valid <- TRUE
      solve_msg_func("  Valid solution (maximum discrepancy <= ", format(validation_tol), " = `validation_tol`).\n")
      status <- "valid initial solution"
      status_val <- 1
    } else {
      valid <- FALSE
      status <- "invalid initial solution"
      status_val <- -1
    }
    solve_msg_func("  Try to find a better solution with OSQP.\n")

    # Calculate the scaling factor
    mean_abs_x <- mean(abs(x))

    
    # Solving loop
    best_osqp <- NA_integer_
    for (ii in seq_along(settings_df$verbose)) {

      # Set the scaling factor
      if (settings_df$prior_scaling[ii]) {
        factor_ii <- mean_abs_x
      } else {
        factor_ii <- 1
      }
      
      osqpBeg_display_func(osqp_output_file)

      # Build the model (ii-th row of `settings_df`)
      model_ii <- osqp::osqp(P * factor_ii, q, A, l / factor_ii, u / factor_ii, as.list(settings_df[ii, , drop = FALSE]))

      # Solve
      sol_ii <- model_ii$Solve() 
      sol_ii$x <- sol_ii$x * factor_ii  # original scale

      osqpEnd_display_func(osqp_output_file)

      # Trunc to zero
      sol_ii$x[abs(sol_ii$x) <= trunc_to_zero_tol] <- 0

      
      # Evaluate:
      #  a) update the "current solution" when relevant (smallest `tot_discr` among valid/invalid solutions so far)
      #  b) stop the solving loop if a satisfactory OSQP solution was found and not doing a full OSQP sequence
      Ax_ii <- A %*% sol_ii$x
      discr_ii <- calc_discr(Ax_ii, l, u)
      polished_ii <- sol_ii$info$status_polish == 1
      solve_msg_func("  OSQP iteration ", ii, ":\n    - Maximum discrepancy = ", format(discr_ii$max_discr, big.mark = ","),
                     "\n    - Total discrepancy   = ", format(discr_ii$tot_discr, big.mark = ","), "\n")
      
      # Valid solution (`max_discr <= validation_tol`)
      if (discr_ii$max_discr <= validation_tol) {
        solve_msg_func("  Valid solution (maximum discrepancy <= ", format(validation_tol), " = `validation_tol`).\n")

        # Polished solution required
        if (settings_df$require_polished[ii]) {
          if (polished_ii) {
            satisfactory <- TRUE
            solve_msg_func("  Required polished solution achieved.\n")
            status_ii <- "valid polished osqp solution"
            status_val_ii <- 2
          } else {
            solve_msg_func("  Required polished solution NOT achieved.\n")
            status_ii <- "valid unpolished osqp solution"
            status_val_ii <- 3
          }
          
        # Polished solution NOT required
        } else {
          satisfactory <- TRUE
          if (polished_ii) {
            status_ii <- "valid polished osqp solution"
            status_val_ii <- 2
          } else {
            status_ii <- "valid unpolished osqp solution"
            status_val_ii <- 3
          }
        }
        
        # Update the "current (valid) solution"
        if (!valid || discr_ii$tot_discr < discr$tot_discr) {
          valid <- TRUE
          status <- status_ii
          status_val <- status_val_ii
          Ax <- Ax_ii
          discr <- discr_ii
          best_osqp <- ii
          model <- model_ii
          sol <- sol_ii
          scaling_factor <- factor_ii
        }
        
        # Stop the solving loop
        if (satisfactory && !full_sequence) {
          break
        }
        
      # Invalid solution (`max_discr > validation_tol`)
      } else {
        solve_msg_func("  Invalid solution (maximum discrepancy > ", format(validation_tol), " = `validation_tol`).\n")
        
        # Update the "current (invalid) solution"
        if (!valid && discr_ii$tot_discr < discr$tot_discr) {
          if (polished_ii) {
            status <- "invalid polished osqp solution"
            status_val <- -2
          } else {
            status <- "invalid unpolished osqp solution"
            status_val <- -3
          }
          Ax <- Ax_ii
          discr <- discr_ii
          best_osqp <- ii
          model <- model_ii
          sol <- sol_ii
          scaling_factor <- factor_ii
        }
      }
    }

    
    # Wrap up the final solution    
    osqp_attempts <- ii
    
    # Initial solution
    if (is.na(best_osqp)) {
      solve_msg_func("  The initial solution could not be improved with OSQP. Returning the initial solution.\n")
      type <- "initial"
      osqp_seqno <- NA_integer_
      osqp_settings <- NULL
      osqp_info <- NULL
      
    # OSQP solution
    } else {
      if (!satisfactory) {
        if (valid) {
          word <-  "valid"
        } else {
          word <-  "all"
        }
        solve_msg_func("  A satisfactory OSQP solution could not be obtained. Returning the solution with the smallest ",
                       "total discrepancy among ", word, " solutions (OSQP iteration ", best_osqp, ").\n")
      }
      x <- sol$x
      type <- "osqp"
      osqp_seqno <- best_osqp
      osqp_settings <- c(model$GetParams(), list(prior_scaling = settings_df$prior_scaling[best_osqp]))
      osqp_info <- c(sol$info, list(prior_scaling_factor = scaling_factor))
    }
  }

    
  # Return the final solution
  list(x = x,
       status = status,
       status_val = status_val,
       Ax = Ax,
       discr = discr,
       type = type,
       osqp_attempts = osqp_attempts,
       osqp_seqno = osqp_seqno,
       osqp_settings = osqp_settings,
       osqp_info = osqp_info,
       seq_time = Sys.time() - start_time)
}
