#' Restore temporal constraints
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.html}})}
#' 
#' _Replication of the G-Series 2.0 SAS\eqn{^\circledR}{®} BENCHMARKING procedure (PROC BENCHMARKING).
#' See the G-Series 2.0 documentation for details (Statistics Canada 2016)._
#'
#' This function ensures coherence between time series data of the same target variable measured at different 
#' frequencies (e.g., sub-annually and annually). Benchmarking consists of imposing the level of the benchmark 
#' series (e.g., annual data) while minimizing the revisions of the observed movement in the indicator series 
#' (e.g.,  sub-annual data) as much as possible. The function also allows nonbinding benchmarking where the 
#' benchmark series can also be revised.
#'
#' The function may also be used for benchmarking-related topics such as *temporal distribution*
#' (the reciprocal action of benchmarking: disaggregation of the benchmark series into more frequent observations), 
#' *calendarization* (a special case of temporal distribution) and *linking* (the connection of different time series 
#' segments into a single consistent time series).
#'
#' Several series can be benchmarked in a single function call.
#'
#'
#' @usage
#' benchmarking(
#'   series_df,
#'   benchmarks_df,
#'   rho,
#'   lambda,
#'   biasOption,
#'   bias = NA,
#'   tolV = 0.001,
#'   tolP = NA,
#'   warnNegResult = TRUE,
#'   tolN = -0.001,
#'   var = "value",
#'   with = NULL,
#'   by = NULL,
#'   verbose = FALSE,
#'
#'   # New in G-Series 3.0
#'   constant = 0,
#'   negInput_option = 0,
#'   allCols = FALSE,
#'   quiet = FALSE
#' )
#'
#'
#' @param series_df (mandatory)
#'
#' Data frame (object of class "data.frame") that contains the indicator time series data to be 
#' benchmarked. In addition to the series data variable(s), specified with argument `var`, the data 
#' frame must also contain two numeric variables, `year` and `period`, identifying the periods of 
#' the indicator time series.
#'
#' @param benchmarks_df (mandatory)
#'
#' Data frame (object of class "data.frame") that contains the benchmarks. In addition to the benchmarks 
#' data variable(s), specified with argument `with`, the data frame must also contain four numeric 
#' variables, `startYear`, `startPeriod`, `endYear` and `endPeriod`, identifying the indicator time 
#' series periods covered by each benchmark.
#'
#' @param rho (mandatory)
#'
#' Real number in the \eqn{[0,1]} interval that specifies the value of the autoregressive parameter
#' \eqn{\rho}. See section **Details** for more information on the effect of parameter \eqn{\rho}.
#'
#' @param lambda (mandatory)
#'
#' Real number, with suggested values in the \eqn{[-3,3]} interval, that specifies the value of the
#' adjustment model parameter \eqn{\lambda}. Typical values are `lambda = 0.0` for an additive model
#' and `lambda = 1.0` for a proportional model.
#'
#' @param biasOption (mandatory)
#'
#' Specification of the bias estimation option:
#' 
#' * `1`: Do not estimate the bias. The bias used to correct the indicator series will be the value 
#' specified with argument `bias`.
#' * `2`: Estimate the bias, display the result, but do not use it. The bias used to correct the indicator 
#' series will be the value specified with argument `bias`.
#' * `3`: Estimate the bias, display the result and use the estimated bias to correct the indicator series. 
#' Any value specified with argument `bias` will be ignored.
#'
#' Argument `biasOption` is ignored when `rho = 1.0`. See section **Details** for more information on the bias.
#'
#' @param bias (optional)
#'
#' Real number, or `NA`, specifying the value of the user-defined bias to be used for the correction of the
#' indicator series prior to benchmarking. The bias is added to the indicator series with an additive model
#' (argument  `lambda = 0.0`) while it is multiplied otherwise (argument `lambda != 0.0`). No bias
#' correction is applied when `bias = NA`, which is equivalent to specifying `bias = 0.0` when `lambda = 0.0`
#' and `bias = 1.0` otherwise. Argument `bias` is ignored when `biasOption = 3` or `rho = 1.0`. See section 
#' **Details** for more information on the bias.
#'
#' **Default value** is `bias = NA` (no user-defined bias).
#'
#' @param tolV,tolP (optional)
#'
#' Nonnegative real number, or `NA`, specifying the tolerance, in absolute value or percentage, to be used
#' for the validation of the output binding benchmarks (alterability coefficient of \eqn{0.0}). This validation 
#' compares the input binding benchmark values with the equivalent values calculated from the benchmarked series 
#' (output) data. Arguments `tolV` and `tolP` cannot be both specified (one must be specified while the other 
#' must be `NA`).
#'
#' **Example:** to set a tolerance of 10 *units*, specify `tolV = 10, tolP = NA`; to set a tolerance of 1%, 
#' specify `tolV = NA, tolP = 0.01`.
#'
#' **Default values** are `tolV = 0.001` and `tolP = NA`.
#'
#' @param warnNegResult (optional)
#'
#' Logical argument specifying whether a warning message is generated when a negative value created by the
#' function in the benchmarked (output) series is smaller than the threshold specified by argument `tolN`.
#'
#' **Default value** is `warnNegResult = TRUE`.
#'
#' @param tolN (optional)
#'
#' Negative real number specifying the threshold for the identification of negative values. A value is
#' considered negative when it is smaller than this threshold.
#'
#' **Default value** is `tolN = -0.001`.
#'
#' @param var (optional)
#'
#' String vector (minimum length of 1) specifying the variable name(s) in the indicator series data frame 
#' (argument `series_df`) containing the values and (optionally) the user-defined alterability coefficients 
#' of the series to be benchmarked. These variables must be numeric.
#'
#' The syntax is `var = c("series1 </ alt_ser1>", "series2 </ alt_ser2>", ...)`. Default alterability
#' coefficients of \eqn{1.0} are used when a user-defined alterability coefficients variable is not specified
#' alongside an indicator series variable. See section **Details** for more information on alterability coefficients.
#'
#' **Example:** `var = "value / alter"` would benchmark indicator series data frame variable `value` with the
#' alterability coefficients contained in variable `alter` while `var = c("value / alter", "value2")` would
#' additionally benchmark variable `value2` with default alterability coefficients of \eqn{1.0}.
#'
#' **Default value** is `var = "value"` (benchmark variable `value` using default alterability coefficients of
#' \eqn{1.0}).
#'
#' @param with (optional)
#'
#' String vector (same length as argument `var`), or `NULL`, specifying the variable name(s) in the benchmarks data 
#' frame (argument `benchmarks_df`) containing the values and (optionally) the user-defined alterability coefficients 
#' of the benchmarks. These variables must be numeric. Specifying `with = NULL` results in using benchmark variable(s) 
#' with the same names(s) as those specified with argument `var` without user-defined benchmark alterability coefficients 
#' (i.e., default alterability coefficients of \eqn{0.0} corresponding to binding benchmarks).
#'
#' The syntax is `with = NULL` or `with = c("bmk1 </ alt_bmk1>", "bmk2 </ alt_bmk2>", ...)`. Default alterability
#' coefficients of \eqn{0.0} (binding benchmarks) are used when a user-defined alterability coefficients variable
#' is not specified alongside a benchmark variable. See section **Details** for more information on alterability
#' coefficients.
#'
#' **Example:** `with = "val_bmk"` would use benchmarks data frame variable `val_bmk` with default benchmark
#' alterability coefficients of \eqn{0.0} to benchmark the indicator series while
#' `with = c("val_bmk", "val_bmk2 / alt_bmk2")` would additionally benchmark a second indicator series using
#' benchmark variable `val_bmk2` with the benchmark alterability coefficients contained in variable `alt_bmk2`.
#'
#' **Default value** is `with = NULL` (same benchmark variable(s) as argument `var` using default benchmark
#' alterability coefficients of \eqn{0.0}).
#'
#' @param by (optional)
#'
#' String vector (minimum length of 1), or `NULL`, specifying the variable name(s) in the input data frames 
#' (arguments `series_df` and `benchmarks_df`) to be used to form groups (for _BY-group_ processing) and allow 
#' the benchmarking of multiple series in a single function call. BY-group variables can be numeric or 
#' character (factors or not), must be present in both input data frames and will appear in all three output 
#' data frames (see section **Value**). BY-group processing is not  implemented when `by = NULL`. See 
#' "Benchmarking Multiple Series" in section **Details** for more information.
#'
#' **Default value** is `by = NULL` (no BY-group processing).
#'
#' @param verbose (optional)
#'
#' Logical argument specifying whether information on intermediate steps with execution time (real time,
#' not CPU time) should be displayed. Note that specifying argument `quiet = TRUE` would *nullify* argument 
#' `verbose`.
#'
#' **Default value** is `verbose = FALSE`.
#'
#' @param constant (optional)
#'
#' Real number that specifies a value to be temporarily added to both the indicator series and the
#' benchmarks before solving proportional benchmarking problems (`lambda != 0.0`). The temporary
#' constant is removed from the final output benchmarked series. E.g., specifying a (small) constant
#' would allow proportional benchmarking with `rho = 1` (e.g., proportional Denton benchmarking) on
#' indicator series that include values of 0. Otherwise, proportional benchmarking with values of 0 in
#' the indicator series is only possible when `rho < 1`. Specifying a constant with additive benchmarking
#' (`lambda = 0.0`) has no impact on the resulting benchmarked data. The data variables in the `graphTable`
#' output data frame include the constant, corresponding to the benchmarking problem that was actually solved.
#'
#' **Default value** is `constant = 0` (no temporary additive constant).
#'
#' @param negInput_option (optional)
#'
#' Handling of negative values in the input data for proportional benchmarking (`lambda != 0.0`):
#' 
#' * `0`: Do not allow negative values with proportional benchmarking. An error message is displayed in the 
#' presence of negative values in the input indicator series or benchmarks and missing (`NA`) values are 
#' returned for the benchmarked series. This corresponds to the G-Series 2.0 behaviour.
#' * `1`: Allow negative values with proportional benchmarking but display a warning message.
#' * `2`: Allow negative values with proportional benchmarking without displaying any message.
#' 
#' **Default value** is `negInput_option = 0` (do not allow negative values with proportional benchmarking).
#'
#' @param allCols (optional)
#'
#' Logical argument specifying whether all variables in the indicator series data frame (argument `series_df`), 
#' other than `year` and `period`, determine the set of series to benchmark. Values specified with arguments `var` 
#' and `with` are ignored when `allCols = TRUE`, which automatically implies default alterability coefficients, 
#' and variables with the same names as the indicator series must exist in the benchmarks data frame (argument 
#' `benchmarks_df`).
#'
#' **Default value** is `allCols = FALSE`.
#'
#' @param quiet (optional)
#'
#' Logical argument specifying whether or not to display only essential information such as warning messages,
#' error messages and variable (series) or BY-group information when multiple series are benchmarked in a single call 
#' to the function. We advise against *wrapping* your [benchmarking()] call with [suppressMessages()] to further suppress 
#' the display of variable (series) or BY-group information when processing multiple series as this would make 
#' troubleshooting difficult in case of issues with individual series. Note that specifying `quiet = TRUE` would 
#' also *nullify* argument `verbose`.
#'
#' **Default value** is `quiet = FALSE`.
#'
#'
#' @details
#' When \eqn{\rho < 1}, this function returns the generalized least squared solution of a special case of the general 
#' regression-based benchmarking model proposed by Dagum and Cholette (2006). The model, in matrix form, is:
#' \deqn{\displaystyle
#' \begin{bmatrix} s^\dagger \\ a \end{bmatrix} = 
#' \begin{bmatrix} I \\ J \end{bmatrix} \theta + 
#' \begin{bmatrix} e \\ \varepsilon \end{bmatrix}
#' }{[s^dag; a] = [I; J] theta + [e; epsilion]}
#' where
#' * \eqn{a} is the vector of length \eqn{M} of the benchmarks.
#' * \eqn{s^\dagger = \left\{
#'     \begin{array}{cl}
#'       s + b & \text{if } \lambda = 0 \\
#'       s \cdot b  & \text{otherwise}
#'     \end{array} \right.
#'   }{s^dag = s + b if lambda = 0, s^dag = s * b otherwise} is the vector of length \eqn{T} of the bias corrected 
#'   indicator series values, with \eqn{s} denoting the initial (input) indicator series.
#' * \eqn{b} is the bias, which is specified with argument `bias` when argument `bias_option != 3` or, when `bias_option = 3`, 
#' is estimated as \eqn{\hat{b} = \left\{
#'     \begin{array}{cl}
#'       \frac{{1_M}^\mathrm{T} (a - Js)}{{1_M}^\mathrm{T} J 1_T} & \text{if } \lambda = 0 \\
#'       \frac{{1_M}^\mathrm{T} a}{{1_M}^\mathrm{T} Js} & \text{otherwise}
#'     \end{array} \right.
#'   }{b^hat = ({1_M}'(a - J s)) / ({1_M}' J 1_T) if \lambda = 0, b^hat = ({1_M}' a) / ({1_M}' J s) otherwise}, where 
#'   \eqn{1_X = (1, ..., 1)^\mathrm{T}}{1_X = (1, ..., 1)'} is a vector of \eqn{1} of length \eqn{X}.
#' * \eqn{J} is the \eqn{M \times T}{M x T} matrix of temporal aggregation constraints with elements \if{latex}{\cr} 
#'   \eqn{j_{m, t} = \left\{
#'     \begin{array}{cl}
#'       1 & \text{if benchmark } m \text{ covers period } t \\
#'       0 & \text{otherwise}
#'     \end{array} \right.
#'   }{j_{m,t} = 1 if benchmark m covers period t, j_{m,t} = 0 otherwise}.
#' * \eqn{\theta} is the vector of the final (benchmarked) series values.
#' * \eqn{e \sim \left( 0, V_e \right)}{e ~ (0, V_e)} is the vector of the measurement errors of \eqn{s^\dagger}{s^dag} 
#' with covariance matrix \eqn{V_e = C \Omega_e C}.
#' * \eqn{C = \mathrm{diag} \left( \sqrt{c_{s^\dagger}} \left| s^\dagger \right|^\lambda \right)}{C = diag(\sqrt{c_{s^dag}} 
#' |s^dag|^lambda)} where \eqn{c_{s^\dagger}}{c_{s^dag}} is the vector of the alterability coefficients of \eqn{s^\dagger}{s^dag}, 
#' assuming \eqn{0^0 = 1}.
#' * \eqn{\Omega_e} is a \eqn{T \times T}{T x T} matrix with elements \eqn{\omega_{e_{i,j}} = \rho^{|i-j|}} representing the 
#' autocorrelation of an AR(1) process, again assuming \eqn{0^0 = 1}.
#' * \eqn{\varepsilon \sim (0, V_\varepsilon)}{epsilon ~ (0, V_epsilon)} is the vector of the measurement errors of the benchmarks 
#' \eqn{a} with covariance matrix \eqn{V_\varepsilon = \mathrm{diag} \left( c_a a \right)}{V_epsilion = diag(c_a a)} where \eqn{c_a} 
#' is the vector of the alterability coefficients of the benchmarks \eqn{a}.
#' 
#' The generalized least squared solution is:
#' \deqn{\displaystyle 
#' \hat{\theta} = s^\dagger + V_e J^{\mathrm{T}} \left( J V_e J^{\mathrm{T}} + V_\varepsilon \right)^+ \left( a - J s^\dagger \right)
#' }{theta^hat = s^dag + V_e J' (J V_e J' + V_epsilion)^{+} (a - J s^dag)}
#' where \eqn{A^{+}} designates the Moore-Penrose inverse of matrix \eqn{A}.
#' 
#' When \eqn{\rho = 1}, the function returns the solution of the (modified) Denton method:
#' \deqn{\displaystyle 
#' \hat{\theta} = s + W \left( a - J s \right)
#' }{theta^hat = s + W (a - J s)}
#' where
#' * \eqn{W} is the upper-right corner matrix from the following matrix product
#'   \deqn{
#'     \left[\begin{array}{cc}
#'       D^{+} \Delta^{\mathrm{T}} \Delta D^{+} & J^{\mathrm{T}} \\
#'       J & 0
#'     \end{array} \right]^{+}
#'     \left[\begin{array}{cc}
#'       D^{+} \Delta^{\mathrm{T}} \Delta D^{+} & 0 \\
#'       J & I_M
#'     \end{array} \right] = 
#'     \left[\begin{array}{cc}
#'       I_T & W \\
#'       0 & W_\nu
#'     \end{array} \right]
#'   }{[D^{+} Delta' Delta D^{+}, J'; J, 0]^{+} [D^{+} Delta' Delta D^{+}, 0; J, I_M] = [I_T, W; 0, W_nu]}
#' * \eqn{D = \mathrm{diag} \left( \left| s \right|^\lambda \right)}{D = diag(|s|^\lambda)}, assuming \eqn{0^0 = 1}. Note that 
#' \eqn{D} corresponds to \eqn{C} with \eqn{c_{s^\dagger} = 1.0}{c_{s^dag} = 1.0} and without bias correction (arguments 
#' `bias_option = 1` and `bias = NA`).
#' * \eqn{\Delta}{Delta} is a \eqn{T-1 \times T}{T-1 x T} matrix with elements \eqn{\delta_{i,j} = \left\{
#'     \begin{array}{cl}
#'       -1 & \text{if } i=j \\
#'       1 & \text{if } j=i+1 \\
#'       0 & \text{otherwise}
#'     \end{array} \right.
#'   }{delta_{i,j} = 1 if i = j, delta_{i,j} = 1 if j = i + 1, delta_{i,j} = 0 otherwise}.
#' * \eqn{W_\nu} is a \eqn{M \times M}{M x M} matrix associated with the Lagrange multipliers of the corresponding 
#' minimization problem, expressed as:
#' \deqn{\displaystyle 
#' \begin{aligned}
#' & \underset{\theta}{\text{minimize}} 
#' & & \sum_{t \ge 2} \left[ \frac{\left( s_t - \theta_t \right)}{\left| s_t\right|^\lambda}
#'       - \frac{\left( s_{t-1} - \theta_{t-1} \right)}{\left| s_{t-1}\right|^\lambda} \right]^2 \\
#' & \text{subject to} 
#' & & a = J \theta
#' \end{aligned}
#' }{min(theta) sum_{t>1}{[(s_t - theta_t) / |s_t|^lambda - (s_{t-1} - theta_{t-1}) / |s_{t-1}|^lambda]^2}, subject to a = J theta}
#' 
#' See Quenneville et al. (2006) and Dagum and Cholette (2006) for details.
#' 
#' ## Autoregressive Parameter \eqn{\rho} and *bias*
#' Parameter \eqn{\rho} (argument `rho`) is associated to the change between the (input) indicator and the (output)
#' benchmarked series for two consecutive periods and is often called the *movement preservation parameter*. The larger
#' the value of \eqn{\rho}, the more the indicator series period to period movements are preserved in the
#' benchmarked series. With \eqn{\rho = 0}, period to period movement preservation is not enforced and the
#' resulting benchmarking adjustments are not smooth, as in the case of prorating (\eqn{\rho = 0} and
#' \eqn{\lambda = 0.5}) where the adjustments take the shape of a *step function*. At the other end of the
#' spectrum is \eqn{\rho = 1}, referred to as *Denton benchmarking*, where period to period movement preservation
#' is maximized, which results in the smoothest possible set of benchmarking adjustments available with the function.
#'
#' The *bias* represents the expected discrepancies between the benchmarks and the indicator series. It can be
#' used to pre-adjust the indicator series in order to reduce, on average, the discrepancies between the two
#' sources of data. Bias correction, which is specified with arguments `biasOption` and `bias`, can be particularly 
#' useful for periods not covered by benchmarks when \eqn{\rho < 1}. In this context, parameter \eqn{\rho} dictates the 
#' speed at which the projected benchmarking adjustments converge to the bias (or converge to *no adjustment* without bias 
#' correction) for periods not covered by a benchmark. The smaller the value of \eqn{\rho}, the faster the convergence to 
#' the bias, with immediate convergence when \eqn{\rho = 0} and no convergence at all (the adjustment of the last period 
#' covered by a benchmark is repeated) when \eqn{\rho = 1} (Denton benchmarking). Arguments `biasOption` and `bias` are 
#' actually ignored when \eqn{\rho = 1} since correcting for the bias has no impact on Denton benchmarking solutions.
#' The suggested value for \eqn{\rho} is \eqn{0.9} for monthly indicators and \eqn{0.9^3 = 0.729} for quarterly indicators, 
#' representing a reasonable compromise between maximizing movement preservation and reducing revisions as new benchmarks 
#' become available in the future (benchmarking *timeliness issue*). In practice, note that Denton benchmarking could be 
#' *approximated* with the regression-based model by using a \eqn{\rho} value that is smaller than, but very close to, 
#' \eqn{1.0} (e.g., \eqn{\rho = 0.999}). See Dagum and Cholette (2006) for a complete discussion on this topic.
#'
#' ## Alterability Coefficients
#' Alterability coefficients \eqn{c_{s^\dagger}}{c_{s^dag}} and \eqn{c_a} conceptually represent the measurement errors 
#' associated with the (bias corrected) indicator time series values \eqn{s^\dagger}{s^dag} and benchmarks \eqn{a} 
#' respectively. They are nonnegative real numbers which, in practice, specify the extent to which an initial value can be 
#' modified in relation to other values. Alterability coefficients of \eqn{0.0} define fixed (binding) values while 
#' alterability coefficients greater than \eqn{0.0} define free (nonbinding) values. Increasing the alterability coefficient 
#' of an intial value results in more changes for that value in the benchmarking solution and, conversely, less changes when 
#' decreasing the alterability coefficient. The default alterability coefficients are \eqn{0.0} for the benchmarks (binding 
#' benchmarks) and \eqn{1.0} for the indicator series values (nonbinding indicator series). Important notes:
#' * With a value of \eqn{\rho = 1} (argument `rho = 1`, associated to Denton Benchmarking), only the default 
#' alterability coefficients (\eqn{0.0} for a benchmark and \eqn{1.0} for a an indicator series value) are valid. The 
#' specification of user-defined alterability coefficients variables is therefore not allowed. If such variables are 
#' specified (see arguments `var` and `with`), the function ignores them and displays a warning message in the console.
#' * Alterability coefficients \eqn{c_{s^\dagger}}{c_{s^dag}} come into play after the indicator series has been corrected for 
#' the bias, when applicable (\eqn{c_{s^\dagger}}{c_{s^dag}} is associated to \eqn{s^\dagger}{s^dag}, not \eqn{s}). This means 
#' that specifying an alterability coefficient of \eqn{0.0} for a given indicator series value **will not** result in an unchanged 
#' value after benchmarking **with bias correction** (see arguments `biasOption` and `bias`).
#'
#' Nonbinding benchmarks, when applicable, can be recovered (calculated) from the benchmarked series (see output data frame
#' `series` in section **Value**). The output `benchmarks` data frame always contains the original benchmarks provided 
#' in the input benchmarks data frame (argument `benchmarks_df`).
#'
#' ## Benchmarking Multiple Series
#' Multiple series can be benchmarked in a single [benchmarking()] call, by specifying `allCols = TRUE`, by 
#' (manually) specifying multiple variables with argument `var` (and argument `with`) or with BY-group processing 
#' (argument `by != NULL`). An important distinction is that all indicator series specified with `allCols = TRUE` 
#' or with argument `var` (and benchmarks with argument `with`) are expected to be of the same length, i.e., same 
#' set of periods and same set (number) of benchmarks. Benchmarking series of different lengths (different sets of 
#' periods) or with different sets (number) of benchmarks must be done with BY-group processing on stacked indicator 
#' series and benchmarks input data frames (see utility functions [stack_tsDF()] and [stack_bmkDF()]). Arguments 
#' `by` and `var` can be combined in order to implement BY-group processing for multiple series as illustrated by 
#' *Example 2* in the **Examples** section. While multiple variables with argument `var` (or `allCols = TRUE`) 
#' without BY-group processing (argument `by = NULL`) is slightly more efficient (faster), a BY-group approach with 
#' a single series variable is usually recommended as it is more general (works in all contexts). The latter is 
#' illustrated by *Example 3* in the **Examples** section. The BY variables specified with argument `by` appear in 
#' all three output data frames.
#'
#' ## Arguments `constant` and `negInput_option`
#' These arguments extend the usage of proportional benchmarking to a larger set of problems. Their default 
#' values correspond to the G-Series 2.0 behaviour (SAS\eqn{^\circledR}{®} PROC BENCHMARKING) for which equivalent 
#' options are not defined. Although proportional benchmarking may not necessarily be the most appropriate approach 
#' (additive benchmarking may be more appropriate) when the values of the indicator series approach 0 (unstable 
#' period-to-period ratios) or "cross the 0 line" and can therefore go from positive to negative and vice versa 
#' (confusing, difficult to interpret period-to-period ratios), these cases are not invalid mathematically 
#' speaking (i.e., the associated proportional benchmarking problem can be solved). It is strongly recommended, 
#' however, to carefully analyze and validate the resulting benchmarked data in these situations and make sure they 
#' correspond to reasonable, interpretable solutions.
#'
#' ## Treatment of Missing (`NA`) Values
#' * If a missing value appears in one of the variables of the benchmarks input data frame (other than the
#' BY variables), the observations with the missing values are dropped, a warning message is displayed and the
#' function executes.
#' * If a missing value appears in the `year` and/or `period` variables of the indicator series input data frame
#' and BY variables are specified, the corresponding BY-group is skipped, a warning message is displayed and
#' the function moves on to the next BY-group. If no BY variables are specified, a warning message is displayed
#' and no processing is done.
#' * If a missing value appears in one of the indicator series variables in the indicator series input data
#' frame and BY variables are specified, the corresponding BY-group is skipped, a warning message is displayed
#' and the function moves on to the next BY-group. If no BY variables are specified, the affected indicator
#' series is not processed, a warning message is displayed and the function moves on to the next indicator
#' series (when applicable).
#'
#'
#' @returns
#' The function returns is a list of three data frames:
#' 
#' * `series`: data frame containing the benchmarked data (primary function output). BY variables specified 
#' with argument `by` would be included in the data frame but not alterability coefficient variables 
#' specified with argument `var`.
#' 
#' * `benchmarks`: copy of the input benchmarks data frame (excluding invalid benchmarks when applicable).
#' BY variables specified with argument `by` would be included in the data frame but not alterability
#' coefficient variables specified with argument `with`.
#' 
#' * `graphTable`: data frame containing supplementary data useful for producing analytical tables and graphs
#' (see function [plot_graphTable()]). It contains the following variables in addition to the BY variables
#' specified with argument `by`:
#'   * `varSeries`: Name of the indicator series variable
#'   * `varBenchmarks`: Name of the benchmark variable
#'   * `altSeries`: Name of the user-defined indicator series alterability coefficients variable
#'   * `altSeriesValue`: Indicator series alterability coefficients
#'   * `altbenchmarks`: Name of the user-defined benchmark alterability coefficients variable
#'   * `altBenchmarksValue`: Benchmark alterability coefficients
#'   * `t`: Indicator series period identifier (1 to \eqn{T})
#'   * `m`: Benchmark coverage periods identifier (1 to \eqn{M})
#'   * `year`: Data point calendar year
#'   * `period`: Data point period (cycle) value (1 to `periodicity`)
#'   * `constant`: Temporary additive constant (argument `constant`)
#'   * `rho`: Autoregressive parameter \eqn{\rho} (argument `rho`)
#'   * `lambda`: Adjustment model parameter \eqn{\lambda} (argument `lambda`)
#'   * `bias`: Bias adjustment (default, user-defined or estimated bias according to arguments `biasOption` and `bias`)
#'   * `periodicity`: The maximum number of periods in a year (e.g. 4 for a quarterly indicator series)
#'   * `date`: Character string combining the values of variables `year` and `period`
#'   * `subAnnual`: Indicator series values
#'   * `benchmarked`: Benchmarked series values
#'   * `avgBenchmark`: Benchmark values divided by the number of coverage periods
#'   * `avgSubAnnual`: Indicator series values (variable `subAnnual`) averaged over the benchmark coverage period
#'   * `subAnnualCorrected`: Bias corrected indicator series values
#'   * `benchmarkedSubAnnualRatio`: Difference (\eqn{\lambda = 0}) or ratio (\eqn{\lambda \ne 0}{lambda != 0}) of the values 
#'   of variables `benchmarked` and `subAnnual`
#'   * `avgBenchmarkSubAnnualRatio`: Difference (\eqn{\lambda = 0}) or ratio (\eqn{\lambda \ne 0}{lambda != 0}) of the values 
#'   of variables `avgBenchmark` and `avgSubAnnual`
#'   * `growthRateSubAnnual`: Period to period difference (\eqn{\lambda = 0}) or relative difference (\eqn{\lambda \ne 0}{
#'   lambda != 0}) of the indicator series values (variable `subAnnual`)
#'   * `growthRateBenchmarked`: Period to period difference (\eqn{\lambda = 0}) or relative difference (\eqn{\lambda \ne 0}{
#'   lambda != 0}) of the benchmarked series values (variable `benchmarked`)
#'
#' Notes:
#' * The output `benchmarks` data frame always contains the original benchmarks provided in the input
#' benchmarks data frame. Modified nonbinding benchmarks, when applicable, can be recovered (calculated)
#' from the output `series` data frame.
#' * The function returns a `NULL` object if an error occurs before data processing could start. Otherwise,
#' if execution gets far enough so that data processing could start, then an incomplete object would be
#' returned in case of errors (e.g., output `series` data frame with `NA` values for the benchmarked data).
#' * The function returns "data.frame" objects that can be explicitly coerced to other types of objects with 
#' the appropriate `as*()` function (e.g., `tibble::as_tibble()` would coerce any of them to a tibble).
#'
#'
#' @references Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal Distribution and Reconciliation
#' Methods of Time Series**. Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186
#'
#' @references Fortier, S. and B. Quenneville (2007). "Theory and Application of Benchmarking in Business Surveys".
#' **Proceedings of the Third International Conference on Establishment Surveys (ICES-III)**. Montréal, June 2007.
#'
#' @references Latendresse, E., M. Djona and S. Fortier (2007). "Benchmarking Sub-Annual Series to Annual Totals –
#' From Concepts to SAS\eqn{^\circledR}{®} Procedure and Enterprise Guide\eqn{^\circledR}{®} Custom Task". **Proceedings 
#' of the SAS\eqn{^\circledR}{®} Global Forum 2007 Conference**. Cary, NC: SAS Institute Inc.
#'
#' @references Quenneville, B., S. Fortier, Z.-G. Chen and E. Latendresse (2006). "Recent Developments in Benchmarking to 
#' Annual Totals in X-12-ARIMA and at Statistics Canada". **Proceedings of the Eurostat Conference on Seasonality, 
#' Seasonal Adjustment and Their Implications for Short-Term Analysis and Forecasting**. Luxembourg, May 2006.
#'
#' @references Quenneville, B., P. Cholette, S. Fortier and J. Bérubé (2010). "Benchmarking Sub-Annual Indicator
#' Series to Annual Control Totals (Forillon v1.04.001)". **Internal document**. Statistics Canada, Ottawa, Canada.
#'
#' @references Quenneville, B. and S. Fortier (2012). "Restoring Accounting Constraints in Time Series – Methods and
#' Software for a Statistical Agency". **Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New York.
#'
#' @references Statistics Canada (2012). **Theory and Application of Benchmarking (Course code 0436)**.
#' Statistics Canada, Ottawa, Canada.
#'
#' @references Statistics Canada (2016). "The BENCHMARKING Procedure". **G-Series 2.0 User Guide**.
#' Statistics Canada, Ottawa, Canada.
#'
#'
#' @seealso [stock_benchmarking()] [plot_graphTable()] [bench_graphs] [plot_benchAdj()] [gs.gInv_MP()] [aliases]
#'
#'
#' @example misc/function_examples/benchmarking-ex.R
#'
#'
#' @export
benchmarking <- function(series_df,
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
                         quiet = FALSE) {




  ### Internal functions ###


  # NOTE: some internal functions shared with `stock_benchmarking()` are defined in script `aaa_bench_utils.R`
  #       where environment `the` is defined and contains objects that are not (cannot be) passed as arguments
  #       to the shared internal benchmarking functions.


  # Zero values input data validation functions (proportional benchmarking)
  # => return `TRUE` if the situation corresponds to an "error" and return `FALSE` otherwise
  check_any_zero_ind <- function(s, tol = gs.tolerance, ...) {
    if (any(abs(s) <= tol)) {
      
      # Zero values are NOT allowed and some were found (this is an "error")
      TRUE
      
    } else {
      
      # Zero values not found (this is NOT an "error")
      FALSE
    }
  }
  check_nonZero_bindingBmk <- function(s, J, a, c_a, tol = gs.tolerance) {
    abs_s_lowFreq <- as.vector(J %*% abs(s))

    # Elementwise comparisons are necessary here (cannot use &&)
    if (any(abs_s_lowFreq <= tol & (abs(a) * (c_a == 0)) > tol)) {
      warning("The indicator series is zero for all periods of a nonzero binding benchmark. ",
              "This benchmark cannot be met with proportional benchmarking.\n", call. = FALSE, immediate. = TRUE)
      bk.e$warning_flag <- TRUE
    }
    
    # Zero values are allowed (whether zero values are found or not, this is NOT an "error")
    FALSE
  }


  # Benchmarking functions according to (main function) argument 'rho':
  #   - Denton benchmarking    : rho = 1
  #   - Non-Denton benchmarking: otherwise (rho < 1)
  # => No arguments: they refer to objects that exist in the parent (main function) calling environment and 
  #                  use environment pointer `main.e` (when necessary) to update objects in that environment 
  #                  (instead of using operator `<<-`)
  Denton_bench <- function() {

    # Data rescaling (standardization) of matrix C
    tmp_C <- abs(s_b)^lambda
    mean_C <- mean(tmp_C)
    if (mean_C != 0) {
      # `mean_C` should never be 0 in theory, but it could become zero in practice with 
      # "extreme negative" values for `lambda` (e.g., `lambda = -9999` )
      tmp_C <- tmp_C / mean_C
    }
    verbose_func(start_time, Sys.time(), "Data rescaling for matrix C")
    main.e$start_time <- Sys.time()

    # Build the matrices and solve
    C <- diag(tmp_C, nrow = nT)
    delta <- stats::toeplitz(c(-1, 1, rep.int(0, nT - 2)))
    delta[lower.tri(delta)] <- 0
    delta <- delta[1:(nT - 1), , drop = FALSE]
    verbose_func(start_time, Sys.time(), "C and Delta matrices construction")
    main.e$start_time <- Sys.time()

    C_inv <- gs.gInv_MP(C)
    verbose_func(start_time, Sys.time(), "Inverse C calculation")
    main.e$start_time <- Sys.time()

    M0 <- C_inv %*% t(delta) %*% delta %*% C_inv
    verbose_func(start_time, Sys.time(), "Inv(C) x Delta' x Delta x Inv(C)")
    main.e$start_time <- Sys.time()

    M1_inv <- gs.gInv_MP(rbind(cbind(M0, t(J)), cbind(J, matrix(0, nrow = M, ncol = M))))
    verbose_func(start_time, Sys.time(), "Inverse BigMat1 calculation")
    main.e$start_time <- Sys.time()

    bigMat <- M1_inv %*% rbind(cbind(M0, matrix(0, nrow = nT, ncol = M)), cbind(J, diag(1, nrow = M)))
    verbose_func(start_time, Sys.time(), "BigMat3 = Inv(BigMat1) x BigMat2")
    main.e$start_time <- Sys.time()

    theta <- as.vector(s_b + bigMat[1:nT, (nT + 1):(nT + M), drop = FALSE] %*% (a - J %*% s_b))
    verbose_func(start_time, Sys.time(), "Theta = s* + W x (a - J x s*)")
    main.e$start_time <- Sys.time()

    theta
  }
  nonDenton_bench <- function() {

    # Data rescaling (standardization) of matrices C and V_eps
    tmp_C <- sqrt(c_s) * abs(s_b)^lambda
    tmp_V <- c_a * a
    mean_C <- mean(tmp_C)
    if (mean_C != 0) {
      tmp_C <- tmp_C / mean_C
      tmp_V <- tmp_V / mean_C^2
    }
    verbose_func(start_time, Sys.time(), "Data rescaling for matrices C and V_eps")
    main.e$start_time <- Sys.time()

    # Build the matrices and solve
    C <- diag(tmp_C, nrow = nT)
    V_eps <- diag(tmp_V, nrow = M)
    # `sapply()` is safe: Omega_e will always be a "matrix" object, even when `nT = 1`
    Omega_e <- stats::toeplitz(sapply(1:nT, function(x) rho^(x - 1)))
    verbose_func(start_time, Sys.time(), "C, V_eps and Omega matrices construction")
    main.e$start_time <- Sys.time()

    V_e <- C %*% Omega_e %*% C
    verbose_func(start_time, Sys.time(), "V_e = C x Omega x C")
    main.e$start_time <- Sys.time()

    V_d <- J %*% V_e %*% t(J) + V_eps
    verbose_func(start_time, Sys.time(), "V_d = J x V_e x J' + V_eps")
    main.e$start_time <- Sys.time()

    V_d_inv <- gs.gInv_MP(V_d)
    verbose_func(start_time, Sys.time(), "Inverse V_d calculation")
    main.e$start_time <- Sys.time()

    theta <- as.vector(s_b + V_e %*% t(J) %*% V_d_inv %*% (a - J %*% s_b))
    verbose_func(start_time, Sys.time(), "Theta = s* + V_e x J' x Inv(V_d) x (a - J x s*)")
    main.e$start_time <- Sys.time()

    theta
  }




  ### Main function ###
  
  # Define a pointer to the main function environment and create a NULL object
  main.e <- environment()
  main.e$dummy <- NULL
  
  # Time stamps (when argument `verbose = TRUE`)
  start_time <- Sys.time()
  start_time0 <- start_time

  # Initialize the object to be returned by the function via `on.exit()`
  out_list <- NULL
  on.exit(return(out_list))
  try_error <- FALSE
  try_error_msg <- ""
  bk.e$warning_flag <- FALSE
  
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
  } else {
    quiet_msg_func <- message
    quiet_lab <- "    (*)quiet           = FALSE (default)"
  }

  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\nbenchmarking() function:\n")


  # Initial argument validation

  # Mandatory arguments (without default values)
  ser_df_name <- deparse1(substitute(series_df))
  tmp <- nchar(ser_df_name)
  if (tmp == 0) {
    stop("Argument 'series_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    ser_df_name <- paste0(substr(ser_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", ser_df_name, fixed = TRUE)) {
    ser_df_name <- "<argument 'series_df'>"
  }
  series_df <- series_df
  if (!is.data.frame(series_df)) {
    stop("Argument 'series_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  series_df <- as.data.frame(series_df)
  row.names(series_df) <- NULL
  bmk_df_name <- deparse1(substitute(benchmarks_df))
  tmp <- nchar(bmk_df_name)
  if (tmp == 0) {
    stop("Argument 'benchmarks_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    bmk_df_name <- paste0(substr(bmk_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", bmk_df_name, fixed = TRUE)) {
    bmk_df_name <- "<argument 'benchmarks_df'>"
  }
  benchmarks_df <- benchmarks_df
  if (!is.data.frame(benchmarks_df)) {
    stop("Argument 'benchmarks_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  benchmarks_df <- as.data.frame(benchmarks_df)
  row.names(benchmarks_df) <- NULL
  if (nchar(deparse1(substitute(lambda))) == 0) {
    stop("Argument 'lambda' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  tmp <- (unlist(lambda))[1]
  if (!identical(lambda, tmp) || is.null(tmp) || !is.finite(tmp)) {
    stop("Argument 'lambda' must be a real number.\n\n", call. = FALSE)
  }
  if (nchar(deparse1(substitute(rho))) == 0) {
    stop("Argument 'rho' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  tmp <- (unlist(rho))[1]
  if (!identical(rho, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0 || tmp > 1) {
    stop("Argument 'rho' must be a real number in the [0, 1] interval.\n\n", call. = FALSE)
  }
  if (nchar(deparse1(substitute(biasOption))) == 0) {
    if (rho == 1) {
      # bias is irrelevant for Denton benchmarking (`rho = 1`)
      biasOption <- 1L
    } else {
      stop("Argument 'biasOption' is mandatory (it must be specified).\n\n", call. = FALSE)
    }
  }
  tmp <- (unlist(biasOption))[1]
  if (!identical(biasOption, tmp) || is.null(tmp) || !(tmp %in% 1:3)) {
    stop("Argument 'biasOption' must take value 1, 2 or 3.\n\n", call. = FALSE)
  }
  biasOption <- as.integer(biasOption)

  # Optional arguments (with default values)
  tmp <- (unlist(bias))[1]
  if (is.null(tmp)) {
    bias <- NA_real_
  } else if (!identical(bias, tmp) || !is.finite(tmp) && !is.na(tmp)) {
    stop("Argument 'bias' must either be a real number or NA.\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolV))[1]
  if (is.null(tmp)) {
    tolV <- NA_real_
  } else if (!identical(tolV, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolV' must be a nonnegative real number or NA.\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolP))[1]
  if (is.null(tmp)) {
    tolP <- NA_real_
  } else if (!identical(tolP, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolP' must be a nonnegative real number or NA.\n\n", call. = FALSE)
  }
  warnNegResult <- gs.validate_arg_logi(warnNegResult)
  tmp <- (unlist(tolN))[1]
  if (!identical(tolN, tmp) || is.null(tmp) || !is.finite(tmp) || tmp >= 0) {
    stop("Argument 'tolN' must be a negative real number.\n\n", call. = FALSE)
  }
  verbose <- gs.validate_arg_logi(verbose)
  tmp <- (unlist(constant))[1]
  if (!identical(constant, tmp) || is.null(tmp) || !is.finite(tmp)) {
    stop("Argument 'constant' must be a real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(negInput_option))[1]
  if (!identical(negInput_option, tmp) || is.null(tmp) || !(tmp %in% 0:2)) {
    stop("Argument 'negInput_option' must take value 0, 1 or 2.\n\n", call. = FALSE)
  }
  negInput_option <- as.integer(negInput_option)
  allCols <- gs.validate_arg_logi(allCols)
  # Argument `quiet` was already validated

  # Implement the verbose setting
  if (verbose && !quiet) {
    verbose_func <- gs.display_difftime
    verbose_lab <- "    verbose            = TRUE"
  } else {
    verbose_func <- gs.NULL_func
    verbose_lab <- "    verbose            = FALSE (default)"
  }
  
  # Initialize the final warning/error message flag for multiple series processing
  final_msg_flag <- FALSE
  try_stop_func <- gs.NULL_func
  

  # Initialize the list of "non-data columns" (date and by-group columns)
  info_cols_serDF <- c("year", "period")
  info_cols_bmkDF <- c("startYear", "startPeriod", "endYear", "endPeriod")

  all_cols_serDF <- names(series_df)
  gs.validate_cols(info_cols_serDF, all_cols_serDF, ser_df_name)
  if (any(!is.finite(as.matrix(series_df[info_cols_serDF])))) {
    stop("Indicator series date columns (\"year\" and \"period\") contain invalid or NA values.\n\n", call. = FALSE)
  }

  all_cols_bmkDF <- names(benchmarks_df)
  gs.validate_cols(info_cols_bmkDF, all_cols_bmkDF, bmk_df_name)
  if (any(!is.finite(as.matrix(benchmarks_df[info_cols_bmkDF])))) {
    stop("Benchmarks date columns (\"startYear\", \"startPeriod\", \"endYear\" and \"endPeriod\") contain invalid or NA values.\n\n",
         call. = FALSE)
  }

  # Initialize the list of "series data columns" from both input files
  data_cols_serDF <- setdiff(all_cols_serDF, info_cols_serDF)
  data_cols_bmkDF <- setdiff(all_cols_bmkDF, info_cols_bmkDF)

  # Validation of argument 'by' ("non-data columns" as well)
  by <- unique(gs.cleanup_col_list(by))
  n_byVars <- length(by)
  if (n_byVars > 0) {
    by_lab <- paste0("    by                 = ", paste(by, collapse = " "))
    gs.validate_cols(by, data_cols_serDF, ser_df_name, source_str = "argument 'by'")
    gs.validate_cols(by, data_cols_bmkDF, bmk_df_name, source_str = "argument 'by'")
    by_grps <- unique(series_df[by])
    n_byGrps <- nrow(by_grps)

    # Build the by-group expression (for message display)
    if (n_byGrps > 0) {
      by_grps$PB._expr_ <- paste0(by[1], "=", by_grps[, by[1]])
      for (ii in seq_along(by)[-1]) {
        by_grps$PB._expr_ <- paste(by_grps$PB._expr_, paste0(by[ii], "=", by_grps[, by[ii]]), sep = " & ")
      }
    }
    
    # Add the by variables to the list of "non-data columns"
    info_cols_serDF <- c(by, info_cols_serDF)
    info_cols_bmkDF <- c(by, info_cols_bmkDF)
    
    # Remove by variables from the list of "series data columns"
    data_cols_serDF <- setdiff(data_cols_serDF, by)
    data_cols_bmkDF <- setdiff(data_cols_bmkDF, by)
    
    # Set message display info
    if (n_byGrps > 1) {
      byGrp_ini_func <- bk.byGrp_ini
      byGrp_msg_func <- message
      final_msg_flag <- TRUE
      try_stop_func <- gs.try_stop
    } else {
      byGrp_ini_func <- bk.noByGrp_ini
      byGrp_msg_func <- gs.NULL_func
    }

  # No by-groups
  } else {
    by <- NULL
    by_lab <- "    by                 = NULL (default)"
    by_grps <- data.frame(PB._expr_ = "")
    n_byGrps <- 1
    byGrp_ini_func <- bk.noByGrp_ini
    byGrp_msg_func <- gs.NULL_func
  }

  # Ignore arguments 'var' and 'with' and process all data columns of the input indicator series
  # data frame, expecting corresponding columns (same names) in the input benchmarks data frame
  if (allCols) {
    var_lab <- "    var                (ignored)"
    with_lab <- "    with               (ignored)"
    allCols_lab <- "    (*)allCols         = TRUE"
    var <- data_cols_serDF
    with <- var
    n_vars <- length(var)
    alter_ser <- rep.int("", n_vars)
    default_alter_ser_id <- 1:n_vars
    user_alter_ser_id <- integer(0)  # value returned by which() on an "all FALSE" logical vector
    alter_bmk <- alter_ser
    default_alter_bmk_id <- 1:n_vars
    user_alter_bmk_id <- integer(0)
    gs.validate_cols(with, data_cols_bmkDF, bmk_df_name)

    # Process arguments 'var' and 'with'
  } else {
    allCols_lab <- "    (*)allCols         = FALSE (default)"

    # Validation of argument 'var'
    var <- gs.cleanup_col_list(var)
    var_lab <- paste0("    var                = ", paste(var, collapse = " "))
    if (var_lab == "    var                = value") {
      var_lab <- "    var                = value (default)"
    }
    tmp <- gs.split_str("\\/", var)
    var <- tmp[[1]]
    n_vars <- length(var)
    len <- length(tmp)
    if (len == 2) {
      alter_ser <- tmp[[2]]
      default_alter_ser_id <- which(alter_ser == "")
      user_alter_ser_id <- setdiff(1:n_vars, default_alter_ser_id)
    } else {
      if (len > 2) {
        stop("Invalid specification of alterability coefficients in argument 'var'.\n\n", call. = FALSE)
      }
      alter_ser <- rep.int("", n_vars)
      default_alter_ser_id <- 1:n_vars
      user_alter_ser_id <- integer(0)
    }
    prob_cols <- intersect(var, by)
    if (length(prob_cols) > 0) {
      stop("The following columns are listed with arguments 'var' and 'by' (these arguments are mutually exclusive):",
           paste0("\n  ", prob_cols, collapse = ""), "\n\n", call. = FALSE)
    }
    gs.validate_cols(c(var, alter_ser[user_alter_ser_id]), data_cols_serDF, ser_df_name, source_str = "argument 'var'")

    # Validation of argument 'with'
    with <- gs.cleanup_col_list(with)
    if (length(with) == 0) {
      with_lab <- "    with               = NULL (default)"
      with <- var
      alter_bmk <- rep.int("", n_vars)
      default_alter_bmk_id <- 1:n_vars
      user_alter_bmk_id <- integer(0)
    } else {
      with_lab <- paste0("    with               = ", paste(with, collapse = " "))
      tmp <- gs.split_str("\\/", with)
      with <- tmp[[1]]
      len <- length(tmp)
      if (len == 2) {
        alter_bmk <- tmp[[2]]
        default_alter_bmk_id <- which(alter_bmk == "")
        user_alter_bmk_id <- setdiff(1:n_vars, default_alter_bmk_id)
      } else {
        if (len > 2) {
          stop("Invalid specification of alterability coefficients in argument 'with'.\n\n", call. = FALSE)
        }
        alter_bmk <- rep.int("", n_vars)
        default_alter_bmk_id <- 1:n_vars
        user_alter_bmk_id <- integer(0)
      }
    }
    prob_cols <- intersect(with, by)
    if (length(prob_cols) > 0) {
      stop("The following columns are listed with arguments 'with' and 'by' (these arguments are mutually exclusive):",
           paste0("\n  ", prob_cols, collapse = ""), "\n\n", call. = FALSE)
    }
    gs.validate_cols(c(with, alter_bmk[user_alter_bmk_id]), data_cols_bmkDF, bmk_df_name, source_str = "argument 'with'")
    if (n_vars != length(with)) {
      stop("Arguments 'var' and 'with' do not contain the same number of elements.\n\n", call. = FALSE)
    }
  }
  if (n_vars == 0) {
    stop("Argument 'var' results in 0 series to be benchmarked.\n\n", call. = FALSE)
  } else if (n_vars == 1) {
    var_msg_func <- gs.NULL_func
  } else {
    var_msg_func <- message
    final_msg_flag <- TRUE
    try_stop_func <- gs.try_stop
  }
  
  # Shrink the input data frames with only the necessary columns
  series_df <- series_df[unique(c(info_cols_serDF, var, alter_ser[user_alter_ser_id]))]
  benchmarks_df <- benchmarks_df[unique(c(info_cols_bmkDF, with, alter_bmk[user_alter_bmk_id]))]

  # Add the default alter coefs to the input data frames and specify them when relevant
  series_df$PB._default_alter_ <- rep.int(1, nrow(series_df))
  benchmarks_df$PB._default_alter_ <- rep.int(0, nrow(benchmarks_df))
  actual_alter_ser <- alter_ser
  actual_alter_bmk <- alter_bmk
  alter_ser[default_alter_ser_id] <- "PB._default_alter_"
  alter_bmk[default_alter_bmk_id] <- "PB._default_alter_"
  alter_ser_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_bmk_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_ser_check_func_str[user_alter_ser_id] <- "gs.check_alter"
  alter_bmk_check_func_str[user_alter_bmk_id] <- "gs.check_alter"

  # Initialize the output data frames (as NULL objects for now)
  out_series_df <- NULL
  out_benchmarks_df <- NULL
  out_graphTable_df <- NULL

  # Set parameters and function names according to the benchmarking model (additive benchmarking
  # when 'lambda == 0' and proportional benchmarking otherwise):
  #   - negative values verification functions
  #   - bias calculation
  #   - ratio and growth rate calculation functions
  if (lambda == 0) {
    zeros_verif_func <- gs.FALSE_func
    neg_verif_func <- gs.FALSE_func
    default_bias <- 0
    bias_calc_func <- bk.calc_add_bias
    bias_apply_func <- bk.apply_add_bias
    ratio_func <- gs.calc_diff
    growthRate_func <- gs.calc_firstDiff
  } else {
    if (rho == 1 || lambda < 0) {
      zeros_verif_func <- check_any_zero_ind
    } else {
      zeros_verif_func <- check_nonZero_bindingBmk
    }
    if (negInput_option == 0) {
      neg_verif_func <- bk.check_neg_err
    } else if (negInput_option == 1) {
      neg_verif_func <- bk.check_neg_warn
    } else {
      neg_verif_func <- gs.FALSE_func
    }
    default_bias <- 1
    bias_calc_func <- bk.calc_mult_bias
    bias_apply_func <- bk.apply_mult_bias
    ratio_func <- gs.calc_ratio
    growthRate_func <- gs.calc_relFirstDiff
    if (!is.na(bias) && bias < 0) {
      stop("Argument 'bias' must be positive with proportional benchmarking.\n\n", call. = FALSE)
    }
  }

  # Set the bias option function according to argument 'biasOption'
  if (biasOption == 3) {
    biasOption_func <- bk.apply_biasOption3
    biasOption_lab <- "    biasOption         = 3 (Calculate bias, use calculated bias)"
    bias_parm <- NA_real_
    bias_str <- NA_character_
    bias_lab <- "    bias               (ignored)"
  } else {
    if (biasOption == 1) {
      biasOption_func <- bk.apply_biasOption1
      biasOption_lab <- "    biasOption         = 1 (Use user-defined or default bias)"
    } else if (biasOption == 2) {
      biasOption_func <- bk.apply_biasOption2
      biasOption_lab <- "    biasOption         = 2 (Calculate bias, but use user-defined or default bias)"
    }
    if (is.na(bias)) {
      bias_parm <- default_bias
      bias_str <- "default"
      bias_lab <- "    bias               = NA (default)"
    } else {
      bias_parm <- bias
      bias_str <- "user-defined"
      bias_lab <- paste0("    bias               = ", format(bias))
    }
  }
  bk.e$actual_bias <- NULL

  # Set parameters and functions according to argument 'rho' (Denton or Non-Denton benchmarking):
  #   - minimum required number of periods in the indicator series
  #   - benchmarking function
  if (rho == 1) {
    min_nT <- 2
    bench_func <- Denton_bench
    
    # Impose no bias correction (same as `biasOption = 1` and `bias = NA`)
    biasOption_func <- bk.apply_biasOption1
    biasOption_lab <- "    biasOption         (ignored)"
    bias_parm <- default_bias
    bias_str <- "default"
    bias_lab <- "    bias               (ignored)"
    
    # Check for user (non-default) alter coefs (not allowed when rho=1)
    if (length(user_alter_ser_id) > 0 || length(user_alter_bmk_id) > 0) {
      warning("Alterability coefficients are not available when rho=1.0. ",
              "The default values will be used.\n", call. = FALSE, immediate. = TRUE)
      bk.e$warning_flag <- TRUE
      if (length(user_alter_ser_id) > 0) {
        var_lab <- paste0("    var                = ", paste(var, collapse = " "))
        if (var_lab == "    var                = value") {
          var_lab <- "    var                = value (default)"
        }
      }
      if (length(user_alter_bmk_id) > 0) {
        with_lab <- paste0("    with               = ", paste(with, collapse = " "))
      }
      alter_ser[user_alter_ser_id] <- "PB._default_alter_"
      alter_bmk[user_alter_bmk_id] <- "PB._default_alter_"
      actual_alter_ser[user_alter_ser_id] <- ""
      actual_alter_bmk[user_alter_bmk_id] <- ""
      alter_ser_check_func_str[user_alter_ser_id] <- "gs.FALSE_func"
      alter_bmk_check_func_str[user_alter_bmk_id] <- "gs.FALSE_func"
      user_alter_ser_id <- integer(0)
      user_alter_bmk_id <- integer(0)
      default_alter_ser_id <- 1:n_vars
      default_alter_bmk_id <- 1:n_vars
    }
  } else {
    min_nT <- 1
    bench_func <- nonDenton_bench
  }

  # Results validation function and binding benchmarks tolerance
  if (warnNegResult) {
    neg_res_func <- gs.check_neg
    warnNegResult_lab <- "    warnNegResult      = TRUE (default)"
  } else {
    neg_res_func <- gs.FALSE_func
    warnNegResult_lab <- "    warnNegResult      = FALSE"
  }
  if (!is.na(tolV)) {
    if (!is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both specified (one must be NA).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_diff_valid
    tol_parm <- tolV
    tol_lab <- paste0("    tolV               = ", format(tolV))
    if (abs(tolV - 0.001) < gs.tolerance) {
      tol_lab <- paste0(tol_lab, " (default)")
    }
  } else {
    if (is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both NA (one must be specified).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_relDiff_valid
    tol_parm <- tolP
    tol_lab <- paste0("    tolP               = ", format(tolP))
  }


  # Display the function call (argument values)
  quiet_msg_func("    series_df          = ", ser_df_name)
  quiet_msg_func("    benchmarks_df      = ", bmk_df_name)
  quiet_msg_func("    rho                = ", format(rho))
  quiet_msg_func("    lambda             = ", format(lambda))
  quiet_msg_func(biasOption_lab)
  quiet_msg_func(bias_lab)
  quiet_msg_func(tol_lab)
  quiet_msg_func(warnNegResult_lab)
  lab <- paste0("    tolN               = ", format(tolN))
  if (abs(tolN - (-0.001)) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(var_lab)
  quiet_msg_func(with_lab)
  quiet_msg_func(by_lab)
  quiet_msg_func(verbose_lab, "\n")
  lab <- paste0("    (*)constant        = ", format(constant))
  if (constant == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    (*)negInput_option = ", format(negInput_option))
  if (negInput_option == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(allCols_lab)
  quiet_msg_func(quiet_lab, "\n")
  quiet_msg_func("    (*) indicates new arguments in G-Series 3.0\n")

  verbose_func(start_time, Sys.time(), "Set up phase")
  start_time <- Sys.time()

  
  # Return the input series data frames
  if (nrow(series_df) == 0 || nrow(benchmarks_df) == 0) {
    out_series_df <- series_df[intersect(all_cols_serDF, names(series_df))]
    out_benchmarks_df <- benchmarks_df[intersect(all_cols_bmkDF, names(benchmarks_df))]

  # Attempt to benchmark the data
  } else {
    
    # Enforce integer period id values
    cols_vec <- setdiff(info_cols_serDF, by)
    series_df[cols_vec] <- as.integer(as.matrix(series_df[cols_vec]))
    cols_vec <- setdiff(info_cols_bmkDF, by)
    benchmarks_df[cols_vec] <- as.integer(as.matrix(benchmarks_df[cols_vec]))
    
    
    # Process each by-group
    
    on.exit(rlang::env_unbind(bk.e, c("ser_df_byGrp", "bmk_df_byGrp")), add = TRUE)
    for (ii in 1:n_byGrps) {
      
      # By-group initialization/setup
      bk.e$ser_df_byGrp <- NULL
      bk.e$bmk_df_byGrp <- NULL
      byGrp_ini_func(series_df, benchmarks_df, by_grps, ii, by)
      
      msg_str <- paste0("\nBenchmarking by-group ", ii, " (", by_grps$PB._expr_[ii], ")")
      byGrp_msg_func(msg_str)
      byGrp_msg_func(strrep("=", nchar(msg_str) - 1), "\n")
      
      # Reject rows with invalid benchmark data (for any of the benchmarks)
      M_ini <- nrow(bk.e$bmk_df_byGrp)
      if (nrow(bk.e$bmk_df_byGrp) > 1) {
        prob_id <- which(apply(!apply(bk.e$bmk_df_byGrp[with], 2, is.finite), 1, any))
      } else {
        prob_id <- which(any(!apply(bk.e$bmk_df_byGrp[with], 2, is.finite)))
      }
      if (length(prob_id) > 0) {
        warning("Rows from the benchmarks data frame were dropped because of invalid or NA values.\n",
                call. = FALSE, immediate. = TRUE)
        bk.e$warning_flag <- TRUE
        bk.e$bmk_df_byGrp <- bk.e$bmk_df_byGrp[-prob_id, , drop = FALSE]
        M <- nrow(bk.e$bmk_df_byGrp)
      } else {
        M <- M_ini
      }
      
      # Initialize the by-group output data frames
      out_bmk_df_byGrp <- bk.e$bmk_df_byGrp[c(info_cols_bmkDF, with)]
      out_ser_df_byGrp <- bk.e$ser_df_byGrp[c(info_cols_serDF, var)]
      out_ser_df_byGrp[var] <- NA_real_
      
      nT <- nrow(bk.e$ser_df_byGrp)
      if (nT < min_nT) {
        try_error_msg <- paste0("The minimum number of periods (", min_nT, ") for the indicator series ", 
                                "is not met.\n\n")
        try_stop_func(try_error_msg)
        try_error <- TRUE
        
      } else if (M == 0) {
        try_error_msg <- "A minimum of 1 benchmark is required.\n\n"
        try_stop_func(try_error_msg)
        try_error <- TRUE
        
      } else {
        
        # Vectors for periods and benchmarks coverage validation
        periodicity <- max(bk.e$ser_df_byGrp$period)
        periods <- paste(bk.e$ser_df_byGrp$year, bk.e$ser_df_byGrp$period, sep = "-")
        bmk_start <- paste(bk.e$bmk_df_byGrp$startYear, bk.e$bmk_df_byGrp$startPeriod, sep = "-")
        bmk_end <- paste(bk.e$bmk_df_byGrp$endYear, bk.e$bmk_df_byGrp$endPeriod, sep = "-")
        
        # Validate indicator series periods (period-to-period gap != 1 / periodicity)
        time_val <- bk.e$ser_df_byGrp$year + (bk.e$ser_df_byGrp$period - 1) / periodicity
        if (nT > 1) {
          # `sapply()` is safe: `which()` always returns a "vector" object, even when `nT = 2`
          prob_id <- which(c(FALSE,
                             sapply(2:nT,
                                    function(x) {
                                      abs(time_val[x] - time_val[x - 1] - 1 / periodicity) > gs.tolerance
                                    })))
        } else {
          prob_id <- integer(0)
        }
        if (length(prob_id) > 0) {
          try_error_msg <- paste0("Non-contiguous periods found in the indicator series: ", 
                                  paste0("\n  ", periods[prob_id - 1], " - ", periods[prob_id], 
                                         collapse = ""), 
                                  "\n\n")
          try_stop_func(try_error_msg)
          try_error <- TRUE
          
        } else {
          
          # Build benchmarks to periods mapping matrix of dimension 2 X M:
          #   - Row 1: benchmark starting period ids (positions in vector `periods`)
          #   - Row 2: benchmark ending period ids (positions in vector `periods`)
          mapping <- rbind(match(bmk_start, periods),
                           match(bmk_end, periods))
          
          # Validate the benchmark coverage (i.e. not inside the set of indicator periods)
          prob_id <- which(apply(is.na(mapping), 2, any))
          if (length(prob_id) > 0) {
            try_error_msg <- paste0("Benchmark coverage not fully inside the indicator series span: ",
                                    paste0("\n  [", bmk_start[prob_id], ", ", bmk_end[prob_id], "]", 
                                           collapse = ""), 
                                    "\n\n")
            try_stop_func(try_error_msg)
            try_error <- TRUE
            
          } else {
            
            # Display a message about the number of observations in the benchmarks and series data frames
            # Note: all indicator series observations are valid at this point, making the SERIES
            #       message not quite relevant... but that's what SAS G-Series PROC BENCHMARKING displays
            #       (there might be cases where the 2 numbers differ, but I don't see it...)
            
            # Widths without commas
            width_nT <- floor(log10(nT)) + 1
            width_M_ini <- floor(log10(M_ini)) + 1
            width_M <- floor(log10(M)) + 1
            
            # Adjust the widths of the benchmarks info considering the commas (for `format(..., big.mark = ",")`)
            # => add the difference in the number of commas between the series obs. number (`nT`) and each of the 
            #    two (initial and final) benchmarks obs. numbers (`M_ini` and `M`)
            # => it's (reasonably) assumed here that there will always be more observations in the series data 
            #    frame than in the benchmarks data frame (i.e., `nT` >= `M_ini` >= `M`)
            if (width_M_ini < width_nT) {
              width_M_ini <- width_nT + floor((width_nT - 1) / 3) - floor((width_M_ini - 1) / 3)
            }
            if (width_M < width_nT) {
              width_M <- width_nT + floor((width_nT - 1) / 3) - floor((width_M - 1) / 3)
            }
            quiet_msg_func("Number of observations in the BENCHMARKS data frame .............: ",
                           format(M_ini, scientific = FALSE, big.mark = ",", width = width_M_ini, justify = "right"))
            quiet_msg_func("Number of valid observations in the BENCHMARKS data frame .......: ",
                           format(M, scientific = FALSE, big.mark = ",", width = width_M, justify = "right"), "\n")
            quiet_msg_func("Number of observations in the SERIES data frame .................: ",
                           format(nT, scientific = FALSE, big.mark = ",", width = width_nT, justify = "right"))
            quiet_msg_func("Number of valid observations in the SERIES data frame ...........: ",
                           format(nT, scientific = FALSE, big.mark = ",", width = width_nT, justify = "right"), "\n")
            
            verbose_func(start_time, Sys.time(), "Data validation 1")
            start_time <- Sys.time()
            start_time1 <- start_time
            
            # Process each series
            for (jj in 1:n_vars) {
              
              msg_str <- paste0("\nBenchmarking indicator series [", var[jj], "] with benchmarks [", with[jj], "]")
              var_msg_func(msg_str)
              var_msg_func(strrep("-", nchar(msg_str) - 1), "\n")
              
              # Series/benchmarks data and alterablity coefficients validation
              if (any(!is.finite(bk.e$ser_df_byGrp[[var[jj]]]))) {
                warning("The indicator series contains invalid or NA values. It will not be processed.\n", call. = FALSE,
                        immediate. = TRUE)
                bk.e$warning_flag <- TRUE
                
              } else if (do.call(alter_ser_check_func_str[jj], list(bk.e$ser_df_byGrp[[alter_ser[jj]]]))) {
                try_error_msg <- "Invalid indicator series alterability coefficients (must be nonnegative numbers).\n\n"
                try_stop_func(try_error_msg)
                try_error <- TRUE
                
              } else if (do.call(alter_bmk_check_func_str[jj], list(bk.e$bmk_df_byGrp[[alter_bmk[jj]]]))) {
                try_error_msg <- "Invalid benchmarks alterability coefficients (must be nonnegative numbers).\n\n"
                try_stop_func(try_error_msg)
                try_error <- TRUE
                
                # Process (benchmark) the series
              } else {
                
                verbose_func(start_time, Sys.time(), "Data validation 2")
                start_time <- Sys.time()
                
                # Build the J matrix (temporal sum operator)
                J <- matrix(0, nrow = M, ncol = nT)
                for (kk in 1:M) {
                  J[kk, mapping[1, kk]:mapping[2, kk]] <- 1
                }
                
                # Build the elementary vectors and matrices
                #   => the temporary constant is added here
                s <- bk.e$ser_df_byGrp[[var[jj]]] + constant
                c_s <- bk.e$ser_df_byGrp[[alter_ser[jj]]]
                s_lowFreq <- as.vector(J %*% s)
                nT_lowFreq <- as.vector(J %*% rep.int(1, nT))
                nT_bmk <- sum(nT_lowFreq)
                a <- bk.e$bmk_df_byGrp[[with[jj]]] + constant * nT_lowFreq
                c_a <- bk.e$bmk_df_byGrp[[alter_bmk[jj]]]
                
                verbose_func(start_time, Sys.time(), "J matrix construction")
                start_time <- Sys.time()
                
                # Additional series/benchmarks data validation for proportional benchmarking (lambda != 0)
                #   - `rho = 1` or `lambda < 0`: zero indicator series values (infeasible proportional benchmarking problem)
                #     `rho < 1`: nonzero binding benchmarks associated to "all zero" indicator series values
                #                (infeasible proportional benchmarking problem)
                #   - negative benchmarks or indicator series values (according to argument `negInput_option`)
                if (zeros_verif_func(s, J, a, c_a, tol = gs.tolerance)) {
                  try_error_msg <- paste0("The indicator series has zero values. This is not permitted for proportional ",
                                          "benchmarking when `rho = 1` or `lambda < 0`.\n\n")
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
                  
                } else if (neg_verif_func(a, tol = 0, data_str = "benchmarks")) {
                  try_error_msg <- paste0("Negative values found in the benchmarks. This is not permitted for ", 
                                          "proportional benchmarking.\n\n")
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
                  
                } else if (neg_verif_func(s, tol = 0, data_str = "indicator series")) {
                  try_error_msg <- paste0("Negative values found in the indicator series. This is not permitted for ", 
                                          "proportional benchmarking.\n\n")
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
                  
                } else {
                  
                  # Bias correction
                  s_b <- biasOption_func(quiet_msg_func,                                      # message function
                                         bias_calc_func, s_lowFreq, a, nT_bmk, gs.tolerance,  # bias calculation arguments
                                         bias_apply_func, s, bias_parm,                       # bias application arguments
                                         bias_str)
                  
                  verbose_func(start_time, Sys.time(), "Bias adjustment (s*)")
                  start_time <- Sys.time()
                  
                  # Solve the benchmarking problem (unless there's no discrepancies)
                  if (any(abs(as.vector(J %*% s_b) - a) > gs.min_tolerance)) {
                    theta <- bench_func()
                  } else {
                    theta <- s_b
                  }
                  
                  # Just for safety: solution could contain `NaN` values in very extreme cases (matrix inversion problems)
                  if (any(!is.finite(theta))) {
                    warning("Unable to solve the benchmarking problem.\n", call. = FALSE, immediate. = TRUE)
                    bk.e$warning_flag <- TRUE
                    out_ser_df_byGrp[[var[jj]]] <- NA_real_
                    
                  } else {
                    
                    
                    # Cumulate the graphTable output data frame info
                    #   => the graphTable includes more periods than the indicator series (`n_obs_GT > nT`)
                    #      in the case of overlapping benchmarks

                    # Map benchmark level info (vectors of length `M`) to period level info (vectors of length
                    # `n >= nT`, with `n = nT` for non-overlapping benchmarks and `n > nT` for overlapping benchmarks)
                    # according to matrix `mapping` of dimension 2 X `M`:
                    #   - Row 1: benchmark starting period ids
                    #   - Row 2: benchmark ending period ids
                    #
                    # The resulting `bmk_info` data frame has `n >= nT` observations and 5 variables:
                    #   - `t`: period id
                    #   - `m`: benchmark id (`NA` for periods not associated to any benchmark)
                    #   - `avg_s`: average indicator series value  (`NA` for periods not associated to any benchmark)
                    #   - `avg_a`: average benchmark value (`NA` for periods not associated to any benchmark)
                    #   - `c_a`: benchmark alter coef (`NA` for periods not associated to any benchmark)
                    temp_df <- data.frame(t = rep.int(NA_integer_, nT_bmk),
                                          m = rep.int(NA_integer_, nT_bmk))
                    last_row <- 0
                    for (ii in 1:M) {
                      per_vec <- mapping[1, ii]:mapping[2, ii]
                      n_per <- length(per_vec)
                      temp_df[(last_row + 1):(last_row + n_per), ] <- c(per_vec,             # period ids (`t`)
                                                                        rep.int(ii, n_per))  # benchmark ids (`m`)
                      last_row <- last_row + n_per
                    }
                    bmk_info <- merge(data.frame(t = 1:nT), # period ids
                                      merge(temp_df,
                                            # Benchmark level info
                                            data.frame(m = 1:M,
                                                       avg_s = s_lowFreq / nT_lowFreq,
                                                       avg_a = a / nT_lowFreq,
                                                       c_a = c_a),
                                            by = "m"), 
                                      by = "t", 
                                      all.x = TRUE)
                    bmk_info <- bmk_info[order(bmk_info$t, bmk_info$m), ]

                    # Generate the graphTable data frame info
                    n_obs_GT <- length(bmk_info$t)
                    out_GT_df_var <- data.frame(varSeries = rep.int(var[jj], n_obs_GT),
                                                varBenchmarks = rep.int(with[jj], n_obs_GT),
                                                altSeries = rep.int(actual_alter_ser[jj], n_obs_GT),
                                                altSeriesValue = c_s[bmk_info$t],
                                                altbenchmarks = rep.int(actual_alter_bmk[jj], n_obs_GT),
                                                altBenchmarksValue = bmk_info$c_a,
                                                t = bmk_info$t,
                                                m = bmk_info$m,
                                                year = bk.e$ser_df_byGrp$year[bmk_info$t],
                                                period = bk.e$ser_df_byGrp$period[bmk_info$t],
                                                constant = rep.int(constant, n_obs_GT),
                                                rho = rep.int(rho, n_obs_GT),
                                                lambda = rep.int(lambda, n_obs_GT),
                                                bias = rep.int(bk.e$actual_bias, n_obs_GT),
                                                periodicity = rep.int(periodicity, n_obs_GT),
                                                date = paste(bk.e$ser_df_byGrp$year[bmk_info$t], 
                                                             sprintf("%06d", bk.e$ser_df_byGrp$period[bmk_info$t]), sep = "-"),
                                                subAnnual = s[bmk_info$t],
                                                benchmarked = theta[bmk_info$t],
                                                avgBenchmark = bmk_info$avg_a,
                                                avgSubAnnual = bmk_info$avg_s,
                                                subAnnualCorrected = s_b[bmk_info$t],
                                                benchmarkedSubAnnualRatio = ratio_func(theta[bmk_info$t], s[bmk_info$t]),
                                                avgBenchmarkSubAnnualRatio = ratio_func(bmk_info$avg_a, bmk_info$avg_s),
                                                growthRateSubAnnual = growthRate_func(s)[bmk_info$t],
                                                growthRateBenchmarked = growthRate_func(theta)[bmk_info$t],
                                                stringsAsFactors = FALSE)
                    
                    # Cumulate the graphTable data frame info
                    out_graphTable_df <- rbind(out_graphTable_df, cbind(bk.e$ser_df_byGrp[bmk_info$t, by, drop = FALSE],
                                                                        out_GT_df_var))
                    
                    verbose_func(start_time, Sys.time(), "Output grahTable creation")
                    start_time <- Sys.time()
                    
                    # Remove the temporary constant
                    out_ser_df_byGrp[[var[jj]]] <- theta - constant
                    
                    # Results validation
                    if (neg_res_func(out_ser_df_byGrp[[var[jj]]], tol = -tolN)) {
                      warning("The benchmarked series contains negative values (threshold = ", format(tolN), ").\n",
                              call. = FALSE, immediate. = TRUE)
                      bk.e$warning_flag <- TRUE
                    }
                    binding_bmk_valid_func(bk.e$bmk_df_byGrp[[with[jj]]], as.vector(J %*% out_ser_df_byGrp[[var[jj]]]), c_a,
                                           bmk_start, bmk_end, tol_parm, zero_tol = 0)
                    
                    verbose_func(start_time, Sys.time(), "Results validation")
                    start_time <- Sys.time()
                  }
                  
                  verbose_func(start_time1, Sys.time(), "Benchmarking step total execution time")
                  start_time1 <- Sys.time()
                }
              }
            }
          }
        }
      }
      
      # Cumulate the output series and benchmarks data frame info
      out_series_df <- rbind(out_series_df, out_ser_df_byGrp)
      out_benchmarks_df <- rbind(out_benchmarks_df, out_bmk_df_byGrp)
    }
  }

  
  # Create the output list
  row.names(out_series_df) <- NULL
  row.names(out_benchmarks_df) <- NULL
  row.names(out_graphTable_df) <- NULL
  out_list <- list(series = out_series_df, 
                   benchmarks = out_benchmarks_df, 
                   graphTable = out_graphTable_df)
  
  verbose_func(start_time, Sys.time(), "Wrap up phase")
  verbose_func(start_time0, Sys.time(), "Total execution time")


  # Display a final warning/error message for multiple series processing
  if (final_msg_flag) {
    if (bk.e$warning_flag) {
      warning("Warnings were generated during processing. See preceeding warning message(s) for details.\n",
              call. = FALSE, immediate. = TRUE)
    }
    # Non-muted error message (for proper condition catching by users of the function)
    if (try_error) {
      stop("Problems were encontered during processing. See preceeding error message(s) for details.\n\n",
           call. = FALSE)
    }
    
  # Display the error message for single-series processing
  } else if (try_error) {
    stop(try_error_msg, call. = FALSE)
  }

  # Output object returned via function `on.exit()`
}
