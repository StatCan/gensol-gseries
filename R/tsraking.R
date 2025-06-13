#' Restore cross-sectional (contemporaneous) aggregation constraints
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.html}})}
#' 
#' _Replication of the G-Series 2.0 SAS\eqn{^\circledR}{®} TSRAKING procedure (PROC TSRAKING). See the
#' G-Series 2.0 documentation for details (Statistics Canada 2016)._
#'
#' This function will restore cross-sectional aggregation constraints in a system of time series. The
#' aggregation constraints may come from a 1 or 2-dimensional table. Optionally, temporal constraints
#' can also be preserved.
#'
#' [tsraking()] is usually called in practice through [tsraking_driver()] in order to reconcile
#' all periods of the time series system in a single function call.
#'
#'
#' @usage
#' tsraking(
#'   data_df,
#'   metadata_df,
#'   alterability_df = NULL,
#'   alterSeries = 1,
#'   alterTotal1 = 0,
#'   alterTotal2 = 0,
#'   alterAnnual = 0,
#'   tolV = 0.001,
#'   tolP = NA,
#'   warnNegResult = TRUE,
#'   tolN = -0.001,
#'   id = NULL,
#'   verbose = FALSE,
#'
#'   # New in G-Series 3.0
#'   Vmat_option = 1,
#'   warnNegInput = TRUE,
#'   quiet = FALSE
#' )
#'
#'
#' @param data_df (mandatory)
#'
#' Data frame (object of class "data.frame") that contains the time series data to be reconciled. It must minimally 
#' contain variables corresponding to the component series and cross-sectional control totals specified in the 
#' metadata data frame (argument `metadata_df`). If more than one observation (period) is provided, the sum of 
#' the provided component series values will also be preserved as part of implicit temporal constraints.
#'
#' @param metadata_df (mandatory)
#'
#' Data frame (object of class "data.frame") that describes the cross-sectional aggregation constraints 
#' (additivity rules) for the raking problem. Two character variables must be included in the metadata data frame: 
#' `series` and `total1`. Two variables are optional: `total2` (character) and `alterAnnual` (numeric). The values 
#' of variable `series` represent the variable names of the component series in the input time series data frame 
#' (argument `data_df`). Similarly, the values of variables `total1` and `total2` represent the variable names of 
#' the 1<sup>st</sup> and 2<sup>nd</sup> dimension cross-sectional control totals in the input time series data 
#' frame. Variable `alterAnnual` contains the alterability coefficient for the temporal constraint associated to 
#' each component series. When specified, the latter will override the default alterability coefficient specified 
#' with argument `alterAnnual`.
#'
#' @param alterability_df (optional)
#'
#' Data frame (object of class "data.frame"), or `NULL`, that contains the alterability coefficients variables. 
#' They must correspond to a component series or a cross-sectional control total, that is, a variable with the same 
#' name must exist in the input time series data frame (argument `data_df`). The values of these alterability 
#' coefficients will override the default alterability coefficients specified with arguments `alterSeries`, 
#' `alterTotal1` and `alterTotal2`. When the input time series data frame contains several observations and the 
#' alterability coefficients data frame contains only one, the alterability coefficients are used (repeated) for 
#' all observations of the input time series data frame. Alternatively, the alterability coefficients data frame 
#' may contain as many observations as the input time series data frame.
#'
#' **Default value** is `alterability_df = NULL` (default alterability coefficients).
#'
#' @param alterSeries (optional)
#'
#' Nonnegative real number specifying the default alterability coefficient for the component series values. It 
#' will apply to component series for which alterability coefficients have not already been specified in the 
#' alterability coefficients data frame (argument `alterability_df`).
#'
#' **Default value** is `alterSeries = 1.0` (nonbinding component series values).
#'
#' @param alterTotal1 (optional)
#'
#' Nonnegative real number specifying the default alterability coefficient for the 1<sup>st</sup> dimension
#' cross-sectional control totals. It will apply to cross-sectional control totals for which alterability 
#' coefficients have not already been specified in the alterability coefficients data frame (argument 
#' `alterability_df`).
#'
#' **Default value** is `alterTotal1 = 0.0` (binding 1<sup>st</sup> dimension cross-sectional control totals)
#'
#' @param alterTotal2 (optional)
#'
#' Nonnegative real number specifying the default alterability coefficient for the 2<sup>nd</sup> dimension
#' cross-sectional control totals. It will apply to cross-sectional control totals for which alterability 
#' coefficients have not already been specified in the alterability coefficients data frame (argument 
#' `alterability_df`).
#'
#' **Default value** is `alterTotal2 = 0.0` (binding 2<sup>nd</sup> dimension cross-sectional control totals).
#'
#' @param alterAnnual (optional)
#'
#' Nonnegative real number specifying the default alterability coefficient for the component series temporal
#' constraints (e.g., annual totals). It will apply to component series for which alterability coefficients
#' have not already been specified in the metadata data frame (argument `metadata_df`).
#'
#' **Default value** is `alterAnnual = 0.0` (binding temporal control totals).
#'
#' @param tolV,tolP (optional)
#'
#' Nonnegative real number, or `NA`, specifying the tolerance, in absolute value or percentage, to be used 
#' when performing the ultimate test in the case of binding totals (alterability coefficient of \eqn{0.0} 
#' for temporal or cross-sectional control totals). The test compares the input binding control totals with 
#' the ones calculated from the reconciled (output) component series. Arguments `tolV` and `tolP` cannot be both 
#' specified together (one must be specified while the other must be `NA`).
#'
#' **Example:** to set a tolerance of 10 *units*, specify `tolV = 10, tolP = NA`; to set a tolerance of 1%, 
#' specify `tolV = NA, tolP = 0.01`.
#'
#' **Default values** are `tolV = 0.001` and `tolP = NA`.
#'
#' @param warnNegResult (optional)
#'
#' Logical argument specifying whether a warning message is generated when a negative value created by the
#' function in the reconciled (output) series is smaller than the threshold specified by argument `tolN`.
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
#' @param id (optional)
#'
#' String vector (minimum length of 1), or `NULL`, specifying the name of additional variables to be transferred
#' from the input time series data frame (argument `data_df`) to the output time series data frame, the
#' object returned by the function (see section **Value**). By default, the output series data frame only contains
#' the variables listed in the metadata data frame (argument `metadata_df`).
#'
#' **Default value** is `id = NULL`.
#'
#' @param verbose (optional)
#'
#' Logical argument specifying whether information on intermediate steps with execution time (real time,
#' not CPU time) should be displayed. Note that specifying argument `quiet = TRUE` would *nullify* argument 
#' `verbose`.
#'
#' **Default value** is `verbose = FALSE`.
#'
#' @param Vmat_option (optional)
#'
#' Specification of the option for the variance matrices (\eqn{V_e} and \eqn{V_\epsilon}; see section **Details**):
#' | **Value** | **Description** |
#' | :-------: | :-------------- |
#' | `1` | Use vectors \eqn{x} and \eqn{g} in the variance matrices. |
#' | `2` | Use vectors \eqn{|x|} and \eqn{|g|} in the variance matrices. |
#'
#' See Ferland (2016) and subsection **Arguments `Vmat_option` and `warnNegInput`** in section **Details** for 
#' more information.
#'
#' **Default value** is `Vmat_option = 1`.
#'
#' @param warnNegInput (optional)
#'
#' Logical argument specifying whether a warning message is generated when a negative value smaller than
#' the threshold specified by argument `tolN` is found in the input time series data frame (argument `data_df`).
#'
#' **Default value** is `warnNegInput = TRUE`.
#'
#' @param quiet (optional)
#'
#' Logical argument specifying whether or not to display only essential information such as warnings and errors.
#' Specifying `quiet = TRUE` would also *nullify* argument `verbose` and is equivalent to _wrapping_ your 
#' [tsraking()] call with [suppressMessages()].
#'
#' **Default value** is `quiet = FALSE`.
#'
#'
#' @details
#' This function returns the generalized least squared solution of a specific, simple variant of the general 
#' regression-based raking model proposed by Dagum and Cholette (Dagum and Cholette 2006). The model, in matrix form, is:
#' \deqn{\displaystyle
#' \begin{bmatrix} x \\ g \end{bmatrix} = 
#' \begin{bmatrix} I \\ G \end{bmatrix} \theta + 
#' \begin{bmatrix} e \\ \varepsilon \end{bmatrix}
#' }{[x; g] = [I; G] theta + [e; epsilion]}
#' where
#' * \eqn{x} is the vector of the initial component series values.
#' * \eqn{\theta} is the vector of the final (reconciled) component series values.
#' * \eqn{e \sim \left( 0, V_e \right)}{e ~ (0, V_e)} is the vector of the measurement errors of \eqn{x} with covariance
#' matrix \eqn{V_e = \mathrm{diag} \left( c_x x \right)}{V_e = diag(c_x x)}, or \eqn{V_e = \mathrm{diag} \left( \left| 
#' c_x x \right| \right)}{V_e = diag(|c_x x|)} when argument `Vmat_option = 2`, where \eqn{c_x} is the vector of the 
#' alterability coefficients of \eqn{x}.
#' * \eqn{g} is the vector of the initial control totals, including the component series temporal totals (when 
#' applicable).
#' * \eqn{\varepsilon \sim (0, V_\varepsilon)}{epsilon ~ (0, V_epsilon)} is the vector of the measurement errors of 
#' \eqn{g} with covariance matrix \eqn{V_\varepsilon = \mathrm{diag} \left( c_g g \right)}{V_epsilion = diag(c_g g)}, or 
#' \eqn{V_\varepsilon = \mathrm{diag} \left( \left| c_g g \right| \right)}{V_epsilon = diag(|c_g g|)} when argument 
#' `Vmat_option = 2`, where \eqn{c_g} is the vector of the alterability coefficients of \eqn{g}.
#' * \eqn{G} is the matrix of aggregation constraints, including the implicit temporal constraints (when applicable). 
#' 
#' The generalized least squared solution is:
#' \deqn{\displaystyle 
#' \hat{\theta} = x + V_e G^{\mathrm{T}} \left( G V_e G^{\mathrm{T}} + V_\varepsilon \right)^+ \left( g - G x \right)
#' }{theta^hat = x + V_e G' (G V_e G' + V_epsilion)^{+} (g - G x)}
#' where \eqn{A^{+}} designates the Moore-Penrose inverse of matrix \eqn{A}.
#' 
#' [tsraking()] solves a single raking problem, i.e., either a single period of the time series system, or a single 
#' temporal group (e.g., all periods of a given year) when temporal total preservation is required. Several call to 
#' [tsraking()] are therefore necessary in order to reconcile all the periods of the time series system. 
#' [tsraking_driver()] can achieve this in a single call: it conveniently determines the required set of raking 
#' problems to be solved and internally generates the individual calls to [tsraking()].
#'
######
# This subsection differs slightly between `tsraking()` and `tsbalancing` and is therefore maintained for both functions 
# (in both sets of roxygen2 comments) as opposed to being shared with `roxygen2 tag `@inheritSection`.
# => the "Temporal total preservation* paragraph is the SAME, however: keep them "in sync"!.
######
#' ## Alterability Coefficients
#' Alterability coefficients \eqn{c_x} and \eqn{c_g} conceptually represent the measurement errors associated with the 
#' input component series values \eqn{x} and control totals \eqn{g} respectively. They are nonnegative real numbers which,  
#' in practice, specify the extent to which an initial value can be modified in relation to other values. Alterability 
#' coefficients of \eqn{0.0} define fixed (binding) values while alterability coefficients greater than \eqn{0.0} define 
#' free (nonbinding) values. Increasing the alterability coefficient of an intial value results in more changes for that 
#' value in the reconciled (output) data and, conversely, less changes when decreasing the alterability coefficient. The 
#' default alterability coefficients are \eqn{1.0} for the component series values and \eqn{0.0} for the cross-sectional 
#' control totals and, when applicable, the component series temporal totals. These default alterability coefficients 
#' result in a proportional allocation of the discrepancies to the component series. Setting the component series 
#' alterability coefficients to the inverse of the component series initial values would result in a uniform allocation 
#' of the discrepancies instead. *Almost binding* totals can be obtained in practice by specifying very small 
#' (almost \eqn{0.0}) alterability coefficients relative to those of the (nonbinding) component series.
#' 
#' **Temporal total preservation** refers to the fact that temporal totals, when applicable, are usually kept 
#' “as close as possible” to their initial value. *Pure preservation* is achieved by default with binding temporal 
#' totals while the change is minimized with nonbinding temporal totals (in accordance with the set of alterability 
#' coefficients).
#'
#' ## Arguments `Vmat_option` and `warnNegInput`
#' These arguments allow for an alternative handling of negative values in the input data, similar to that of [tsbalancing()]. 
#' Their default values correspond to the G-Series 2.0 behaviour (SAS\eqn{^\circledR}{®} PROC TSRAKING) for which equivalent 
#' options are not defined. The latter was developed with "nonnegative input data only" in mind, similar to SAS\eqn{^\circledR}{®}
#' PROC BENCHMARKING in G-Series 2.0 that did not allow negative values either with proportional benchmarking, which explains
#' the "suspicious use of proportional raking" warning in presence of negative values with PROC TSRAKING in G-Series 2.0 and 
#' when `warnNegInput = TRUE` (default). However, (proportional) raking in the presence of negative values generally works well 
#' with `Vmat_option = 2` and produces reasonable, intuitive solutions. E.g., while the default `Vmat_option = 1` fails at 
#' solving constraint `A + B = C` with input data `A = 2`, `B = -2`, `C = 1` and the default alterability coefficients, 
#' `Vmat_option = 2` returns the (intuitive) solution `A = 2.5`, `B = -1.5`, `C = 1` (25% increase for `A` and `B`). See 
#' Ferland (2016) for more details.
#'
#' ## Treatment of Missing (`NA`) Values
#' Missing values in the input time series data frame (argument `data_df`) or alterability coefficients data frame
#' (argument `alterability_df`) for any of the raking problem data (variables listed in the metadata data frame
#' with argument `metadata_df`) will generate an error message and stop the function execution.
#' 
#' 
#' @inheritSection tsbalancing Comparing [tsraking()] and [tsbalancing()]
#' 
#' 
#' @returns
#' The function returns a data frame containing the reconciled component series, reconciled cross-sectional control 
#' totals and variables specified with  argument `id`. Note that the "data.frame" object can be explicitly coerced to
#' another type of object with the appropriate `as*()` function (e.g., `tibble::as_tibble()` would coerce it to a tibble).
#'
#'
#' @references Bérubé, J. and S. Fortier (2009). "PROC TSRAKING: An in-house SAS\eqn{^\circledR}{®} procedure for balancing 
#' time series". In **JSM Proceedings, Business and Economic Statistics Section**. Alexandria, VA: American Statistical 
#' Association.
#'
#' @references Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal Distribution and Reconciliation Methods
#' of Time Series**. Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
#' 
#' @references Ferland, M. (2016). "Negative Values with PROC TSRAKING". **Internal document**. Statistics Canada, Ottawa, 
#' Canada.
#' 
#' @references Fortier, S. and B. Quenneville (2009). "Reconciliation and Balancing of Accounts and Time Series". 
#' In **JSM Proceedings, Business and Economic Statistics Section**. Alexandria, VA: American Statistical Association.
#'
#' @references Quenneville, B. and S. Fortier (2012). "Restoring Accounting Constraints in Time Series – Methods and
#' Software for a Statistical Agency". **Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New York.
#'
#' @references Statistics Canada (2016). "The TSRAKING Procedure". **G-Series 2.0 User Guide**. Statistics Canada,
#' Ottawa, Canada.
#'
#' @references Statistics Canada (2018). **Theory and Application of Reconciliation (Course code 0437)**.
#' Statistics Canada, Ottawa, Canada.
#'
#'
#' @seealso [tsraking_driver()] [tsbalancing()] [rkMeta_to_blSpecs()] [gs.gInv_MP()] [build_raking_problem()] [aliases]
#'
#'
#' @example misc/function_examples/tsraking-ex.R
#'
#'
#' @export
tsraking <- function(data_df,
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
                     quiet = FALSE) {




  ### Internal functions ###


  # Binding totals validation functions according to (main function) arguments 'tolV' and 'tolP':
  #   - binding_tot_diff_valid   : tolV is specified (check differences against tolV)
  #   - binding_tot_relDiff_valid: tolP is specified (check relative differences against tolP)
  binding_tot_diff_valid <- function(g_in, g_out, c_g, tol, ...) {
    max_discr <- max(abs(g_out - g_in) * (c_g == 0))
    if (max_discr > tol) {
      warning("Binding totals are not met (maximum difference: ", format(max_discr), "). Inconsistencies ",
              "in the data are suspected.\n", call. = FALSE, immediate. = TRUE)
    }
    invisible(NULL)
  }
  binding_tot_relDiff_valid <- function(g_in, g_out, c_g, tol, zero_tol = gs.tolerance) {
    g_in[abs(g_in) <= zero_tol] <- NA
    max_discr <- max(abs(g_out / g_in - 1) * 100 * (c_g == 0))
    tol <- tol * 100
    if (max_discr > tol) {
      warning("Binding totals are not met (maximum relative difference: ", format(max_discr), "%). Inconsistencies ",
              "in the data are suspected.\n", call. = FALSE, immediate. = TRUE)
    }
    invisible(NULL)
  }




  ### Main function ###

  start_time <- Sys.time()
  start_time0 <- start_time

  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt))
  options(error = NULL)
  
  # Validate argument `quiet` and implement the quiet setting
  quiet <- gs.validate_arg_logi(quiet)
  if (quiet) {
    quiet_msg_func <- gs.NULL_func
    quiet_lab <- ""  # won't be displayed anyway
  } else {
    quiet_msg_func <- message
    quiet_lab <- "    (*)quiet        = FALSE (default)"
  }

  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\ntsraking() function:\n")


  # Initial argument validation

  # Mandatory arguments (without default values)
  data_df_name <- deparse1(substitute(data_df))
  tmp <- nchar(data_df_name)
  if (tmp == 0) {
    stop("Argument 'data_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    data_df_name <- paste0(substr(data_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", data_df_name, fixed = TRUE)) {
    data_df_name <- "<argument 'data_df'>"
  }
  data_df <- data_df
  if (!is.data.frame(data_df)) {
    stop("Argument 'data_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  data_df <- as.data.frame(data_df)
  row.names(data_df) <- NULL
  metadata_df_name <- deparse1(substitute(metadata_df))
  tmp <- nchar(metadata_df_name)
  if (tmp == 0) {
    stop("Argument 'metadata_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    metadata_df_name <- paste0(substr(metadata_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", metadata_df_name, fixed = TRUE)) {
    metadata_df_name <- "<argument 'metadata_df'>"
  }
  metadata_df <- metadata_df
  if (!is.data.frame(metadata_df)) {
    stop("Argument 'metadata_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  metadata_df <- as.data.frame(metadata_df)
  row.names(metadata_df) <- NULL

  # Column names in 'data_df' are case sensitive (e.g. 'metadata_df' values must reflect the correct "casing")
  # Column names in 'metadata_df' are NOT case sensitive (e.g. "Series", "series" and "SERIES" are all valid)
  dataDF_cols <- names(data_df)
  metaDF_cols <- toupper(names(metadata_df))
  names(metadata_df) <- metaDF_cols
  P <- nrow(data_df)  # number of periods
    
  # Alterability coefficients data frame (optional argument `alterability_df`)
  alterDF_lab <- "    alterability_df ="
  dup_alter_msg <- ""
  if (!is.null(alterability_df) && P > 0) {
    alter_df_name <- deparse1(substitute(alterability_df))
    if (alter_df_name >= 60) {
      alter_df_name <- paste0(substr(alter_df_name, 1, 55), "<...>")
    }
    if (grepl("structure(", alter_df_name, fixed = TRUE)) {
      alter_df_name <- "<argument 'alterability_df'>"
    }
    alterability_df <- alterability_df
    if (!is.data.frame(alterability_df)) {
      # Accept `alterability_df = NA` as `alterability_df = NULL`
      tmp <- (unlist(alterability_df))[1]
      if (!identical(alterability_df, tmp) || !is.na(tmp)) {
        warning("Argument 'alterability_df' is not a 'data.frame' object. It will be ignored.\n",
                call. = FALSE, immediate. = TRUE)
      }
      alterability_df <- NULL
      alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
      
    } else {
      alterability_df <- as.data.frame(alterability_df)
      n_perAlter <- nrow(alterability_df)
      if (n_perAlter == 0) {
        alterability_df <- NULL
        alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
        
      } else if (n_perAlter != 1 && n_perAlter != P) {
        warning("The alterability data frame (argument 'alterability_df') must contain either a single row ",
                "or as many rows as the input series data frame. It will be ignored.\n",
                call. = FALSE, immediate. = TRUE)
        alterability_df <- NULL
        alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
        
      } else {
        
        # Duplicate the alterability coefficients
        if (n_perAlter == 1 && P > 1) {
          alterability_df <- alterability_df[rep(1, P), , drop = FALSE]
          dup_alter_msg <- paste0("\nThe alterability data frame contains only one observation (row). The ",
                                  "coefficients will be reused for every row of the input series data frame.\n")
        } else {
          
        }
        row.names(alterability_df) <- NULL
        alterDF_lab <- paste(alterDF_lab, alter_df_name)
      }
    }
  } else {
    alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
  }

  # Other optional arguments
  tmp <- (unlist(alterSeries))[1]
  if (!identical(alterSeries, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterSeries' must be a nonnegative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(alterTotal1))[1]
  if (!identical(alterTotal1, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterTotal1' must be a nonnegative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(alterTotal2))[1]
  if (!identical(alterTotal2, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterTotal2' must be a nonnegative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(alterAnnual))[1]
  if (!identical(alterAnnual, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterAnnual' must be a nonnegative real number.\n\n", call. = FALSE)
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
  id <- gs.cleanup_col_list(id)
  if (length(id) == 0) {
    id_lab <- "    id              = NULL (default)"
    id <- NULL
  } else {
    gs.validate_cols(id, dataDF_cols, data_df_name, source_str = "argument 'id'")
    id_lab <- paste0("    id              = ", paste(id, collapse = " "))
  }
  verbose <- gs.validate_arg_logi(verbose)
  tmp <- (unlist(Vmat_option))[1]
  if (!identical(Vmat_option, tmp) || is.null(tmp) || !(tmp %in% 1:2)) {
    stop("Argument 'Vmat_option' must take value 1 or 2.\n\n", call. = FALSE)
  }
  Vmat_option <- as.integer(Vmat_option)
  warnNegInput <- gs.validate_arg_logi(warnNegInput)
  # Argument `quiet` was already validated
  
  # Implement the verbose setting
  if (verbose && !quiet) {
    verbose_func <- gs.display_difftime
    verbose_lab <- "    verbose         = TRUE"
  } else {
    verbose_func <- gs.NULL_func
    verbose_lab <- "    verbose         = FALSE (default)"
  }
  
  # Negative results validation function and validate the binding total tolerances
  if (warnNegResult) {
    neg_res_func <- gs.check_neg
    warnNegResult_lab <- "    warnNegResult   = TRUE (default)"
  } else {
    neg_res_func <- gs.FALSE_func
    warnNegResult_lab <- "    warnNegResult   = FALSE"
  }
  if (!is.na(tolV)) {
    if (!is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both specified (one must be NA).\n\n", call. = FALSE)
    }
    binding_tot_valid_func <- binding_tot_diff_valid
    tol_parm <- tolV
    tol_lab <- paste0("    tolV            = ", format(tolV))
    if (abs(tolV - 0.001) < gs.tolerance) {
      tol_lab <- paste0(tol_lab, " (default)")
    }
  } else {
    if (is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both NA (one must be specified).\n\n", call. = FALSE)
    }
    binding_tot_valid_func <- binding_tot_relDiff_valid
    tol_parm <- tolP
    tol_lab <- paste0("    tolP            = ", format(tolP))
  }
  
  
  # Display the function call (argument values)
  quiet_msg_func("    data_df         = ", data_df_name)
  quiet_msg_func("    metadata_df     = ", metadata_df_name)
  quiet_msg_func(alterDF_lab)
  lab <- paste0("    alterSeries     = ", format(alterSeries))
  if (alterSeries == 1) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    alterTotal1     = ", format(alterTotal1))
  if (alterTotal1 == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    alterTotal2     = ", format(alterTotal2))
  if (alterTotal2 == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    alterAnnual     = ", format(alterAnnual))
  if (alterAnnual == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(tol_lab)
  quiet_msg_func(warnNegResult_lab)
  lab <- paste0("    tolN            = ", format(tolN))
  if (tolN == -0.001) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(id_lab)
  quiet_msg_func(verbose_lab, "\n")
  lab <- paste0("    (*)Vmat_option  = ", format(Vmat_option))
  if (Vmat_option == 1) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    (*)warnNegInput = ", format(warnNegInput))
  if (warnNegInput) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(quiet_lab, "\n")
  quiet_msg_func("    (*) indicates new arguments in G-Series 3.0\n")
  quiet_msg_func(dup_alter_msg)
  
  verbose_func(start_time, Sys.time(), "Set up phase")
  start_time <- Sys.time()
  
  # Return the (empty) input series data frame
  if (P == 0) {
    out_df <- data_df 
    
  # Attempt to reconcile the input series data frame
  } else {

    # Build the elements of the raking problem (while validating the specified info), 
    # excluding the component series temporal totals info (will be added later):
    #   - x        : vector of component series initial values
    #   - c_x      : vector of component series alterability coefficients
    #   - comp_cols: vector of component series (column) names 
    #   - g        : vector of marginal total series initial values
    #   - c_g      : vector of marginal total series alterability coefficients
    #   - tot_cols : vector of marginal total series (column) names 
    #   - G        : marginal total series aggregation matrix (`g = G %*% x` for coherent/reconciled data)
    #
    # Notes: 
    #
    #   - The returned raking problem elements do not include the implicit component series temporal totals 
    #     when applicable (i.e., elements `g` and `G` only contain the marginal totals info).
    #
    #   - When the input data contains multiple periods (temporal total preservation scenario), raking problem 
    #     elements `x`, `c_x`, `g`, `c_g` and `G` are constructed in "column-major order", corresponding to the 
    #     default behaviour of R for converting matrices into vectors.
    #
    rk <- build_raking_problem(data_df          = data_df,
                               metadata_df      = metadata_df,
                               data_df_name     = data_df_name,
                               metadata_df_name = metadata_df_name,
                               alterability_df  = alterability_df,
                               alterSeries      = alterSeries, 
                               alterTotal1      = alterTotal1,
                               alterTotal2      = alterTotal2)
    
    n_comp <- length(rk$comp_cols)  # number of component series
    K <- length(rk$x)               # number of component series data points
    n_tot <- length(rk$tot_cols)    # number of marginal total series
    L <- length(rk$g)               # number of marginal total series data points
    
    
    # Validate the problem data
    if (any(!is.finite(rk$x)) || any(!is.finite(rk$g))) {
      stop("The input series data frame (argument 'data_df') contains invalid or NA values.\n\n",
           call. = FALSE)
    }
    if (gs.check_alter(rk$c_x) || gs.check_alter(rk$c_g)) {
      stop("The alterability data frame (argument 'alterability_df') contains invalid or NA values.\n\n",
           call. = FALSE)
    }
    if (warnNegInput) {
      if (gs.check_neg(rk$x, tol = 0) || gs.check_neg(rk$g, tol = 0)) {
        warning("The input series data frame (argument 'data_df') contains negative values. ",
                "Suspicious use of proportional raking.\n", call. = FALSE, immediate. = TRUE)
      }
    }
    
    
    # Process component series temporal totals info
    # (update aggregation matrix `G`, total data vector `g` and total alter coefs vector `c_g`
    # to include temporal totals)
    #
    # Note: count `L` is not updated here; it remains `n_tot * P`, i.e. the number of elements
    #       in vectors `g` and `c_g` associated to marginal (contemporaneous) totals only (excluding
    #       temporal totals). In other words, `L < length(g)` when `P > 1`
    if (P > 1) {
      Y <- matrix(0, nrow = n_comp, ncol = K)
      for (ii in 1:n_comp) {
        Y[ii, ((ii - 1) * P + 1):(ii * P)] <- 1
      }
      rk$G <- rbind(rk$G, Y)
      rk$g <- c(rk$g, Y %*% rk$x)
      
      if ("ALTERANNUAL" %in% metaDF_cols) {
        # Note: missing (NA) values are allowed for user-defined temporal total alter coefs (in the metadata file),
        #       but not for the component series and marginal (contemporaneous) totals (in the alterability file)
        #       in SAS G-Series PROC TSRAKING. I don't have a good  explanation for this (!)
        tmp <- metadata_df$ALTERANNUAL
        if (gs.check_alter(tmp[!is.na(tmp)])) {
          stop("Column 'alterAnnual' in the input metadata data frame (argument 'metadata_df') contains invalid values.\n\n",
               call. = FALSE)
        }
        tmp[is.na(tmp)] <- alterAnnual
        rk$c_g <- c(rk$c_g, tmp)
      } else {
        rk$c_g <- c(rk$c_g, rep(alterAnnual, n_comp))
      }
    }
    
    verbose_func(start_time, Sys.time(), "Metadata processing")
    start_time <- Sys.time()
    start_time1 <- start_time
    
    
    # Solve the raking problem (unless there's no discrepancies)
    discr_ini <- rk$g - rk$G %*% rk$x
    if (any(abs(discr_ini) > gs.min_tolerance)) {
      
      # Diagonal elements of the variance matrices (V_e and V_eps)
      if (Vmat_option == 1) {
        V_e <- rk$c_x * rk$x
        V_eps <- rk$c_g * rk$g
        mean_Ve <- mean(V_e)
        V_factor <- mean(abs(V_e))
      } else {
        V_e <- rk$c_x * abs(rk$x)
        V_eps <- rk$c_g * abs(rk$g)
        mean_Ve <- mean(V_e)
        V_factor <- mean_Ve
      }
      
      
      # Solve the raking problem
      if (mean_Ve != 0) {
        
        # Rescaled variance matrices (rescaling helps with the inverse calculation)
        # Note: `V_factor != 0` if `mean_Ve != 0`, regardless of argument `Vmat_option`
        V_e <- diag(V_e / V_factor, nrow = K)
        V_eps <- diag(V_eps / V_factor, nrow = length(rk$g))
        
        verbose_func(start_time, Sys.time(), "Variance matrices construction (V_e and V_eps)")
        start_time <- Sys.time()
        
        V_c <- V_e %*% t(rk$G)
        verbose_func(start_time, Sys.time(), "V_c = V_e * t(G)")
        start_time <- Sys.time()
        
        # Report totals for which all component series are binding (i.e. deterministic totals)
        # => may help users identify the cause of binding totals that can't be met (when applicable)
        all_binding_id <- which(colSums(V_c[, 1:L, drop = FALSE] == 0) == K)
        if (length(all_binding_id) > 0) {
          if (P == 1) {
            quiet_msg_func("All component series are binding (non alterable) for the following totals:",
                           paste0("\n  ", rk$tot_cols[all_binding_id], collapse = ""), "\n")
          } else {
            tot_id <- (all_binding_id - 1) %/% P + 1
            per_id <- (all_binding_id - 1) %% P + 1
            # `sapply()` is safe: it will always returns a character vector of length minimum 1
            quiet_msg_func("All component series are binding (non alterable) for the following totals (applicable periods in brackets):",
                           paste0("\n  ", 
                                  sapply(unique(tot_id),
                                         function(x) {
                                           paste0(rk$tot_cols[x],
                                                  "[",
                                                  paste0(per_id[which(tot_id == x)], collapse = ", "),
                                                  "]")  
                                         }), 
                                  collapse = ""),
                           "\n")
          }
        }
        verbose_func(start_time, Sys.time(), "Deterministic totals check")
        start_time <- Sys.time()
        
        V_d <- rk$G %*% V_c + V_eps
        verbose_func(start_time, Sys.time(), "V_d = G * V_c + V_eps")
        start_time <- Sys.time()
        
        V_d_inv <- gs.gInv_MP(V_d)
        verbose_func(start_time, Sys.time(), "Inverse V_d")
        start_time <- Sys.time()
        
        x_out <- rk$x + V_c %*% V_d_inv %*% discr_ini
        verbose_func(start_time, Sys.time(), "Solution = x + V_c * Inv(V_d) * (g - G * x)")
        verbose_func(start_time1, Sys.time(), "Total problem solving")
        start_time <- Sys.time()
        
        # Just for safety: `x_out` could contain `NaN` values in very extreme cases (matrix inversion problems)...
        if (any(!is.finite(x_out))) {
          warning("Unable to solve the raking problem. Returning the input component series data (and resulting totals).\n",
                  call. = FALSE, immediate. = TRUE)
          x_out <- rk$x
        }
        
        
      # Unsolvable (fixed) raking problem (sum of the elements of the component series variance matrix `V_e` is zero)
      } else {
        
        if (V_factor == 0) {
          if (P == 1) {
            quiet_msg_func("All component series are binding (non alterable). Nothing to solve. ",
                           "Returning the input component series data (and resulting totals).\n")
          } else {
            quiet_msg_func("All component series are binding (non alterable) for all periods. Nothing to solve. ",
                           "Returning the input component series data (and resulting totals).\n")
          }
          
          # May happen in presence of negative values in the input data with `Vmat_option = 1`
          # (impossible with `Vmat_option = 2`)
        } else {
          warning("Unsolvable raking problem. Returning the input component series data (and resulting totals).\n", call. = FALSE,
                  immediate. = TRUE)
        }
        x_out <- rk$x
        
        verbose_func(start_time, Sys.time(), "Problem feasibility checking")
        start_time <- Sys.time()
      }
      
      
      # (Re)calculate the totals
      g_out <- rk$G %*% x_out
      
      
    # Return the initial values (no initial discrepancies)
    } else {
      x_out <- rk$x
      g_out <- rk$g
      verbose_func(start_time, Sys.time(), "Solution = initial values (no discrepancy)")
      start_time <- Sys.time()
    }
    
    
    # Results validation
    if (neg_res_func(c(x_out, g_out), tol = -tolN)) {
      warning("The reconciled data contains negative values (threshold = ", format(tolN), ").\n", call. = FALSE,
              immediate. = TRUE)
    }
    binding_tot_valid_func(rk$g, g_out, rk$c_g, tol_parm, zero_tol = 0)
    
    verbose_func(start_time, Sys.time(), "Results validation")
    start_time <- Sys.time()
    
    
    # Create the output (series) data frame
    
    # Initialize with the input series data
    out_cols <- intersect(dataDF_cols, c(rk$comp_cols, rk$tot_cols, id))
    out_df <- data_df[out_cols]
    
    # Update the component series
    out_df[rk$comp_cols] <- as.data.frame(matrix(x_out, ncol = n_comp))
    
    # Update the marginal total(s)
    #   => exclude the temporal totals at the end of `g_out` (when applicable)
    out_df[rk$tot_cols] <- as.data.frame(matrix(g_out[1:L], ncol = n_tot))
    
    verbose_func(start_time, Sys.time(), "Wrap up phase")
  }
  
  verbose_func(start_time0, Sys.time(), "Total execution time")
  out_df
}


#' Build the elements of raking problems.
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/build_raking_problem.html}})}
#' 
#' This function is used internally by [tsraking()] to build the elements of the raking problem. It can also 
#' be useful to derive the cross-sectional (marginal) totals of the raking problem manually (outside of the [tsraking()] 
#' context). 
#' 
#' 
#' @inheritParams tsraking
#'
#' @param data_df_name (optional) 
#' 
#' String containing the value of argument `data_df`.
#'
#' **Default value** is `data_df_name = deparse1(substitute(data_df))`.
#' 
#' @param metadata_df_name (optional)
#' 
#' String containing the value of argument `metadata_df`.
#' 
#' **Default value** is `metadata_df_name = deparse1(substitute(metadata_df))`.
#'
#'
#' @returns
#' A list with the elements of the raking problem (excluding the implicit temporal totals):
#' - `x`        : vector of component series initial values
#' - `c_x`      : vector of component series alterability coefficients
#' - `comp_cols`: vector of component series (column) names 
#' - `g`        : vector of cross-sectional total initial values
#' - `c_g`      : vector of cross-sectional total alterability coefficients
#' - `tot_cols` : vector of cross-sectional total (column) names 
#' - `G`        : cross-sectional total aggregation matrix (`g = G %*% x`)
#'
#'
#' @details
#' See [tsraking()] for a detailed description of _time series raking_ problems.
#' 
#' The returned raking problem elements do not include the implicit component series temporal totals 
#' when applicable (i.e., elements `g` and `G` only contain the cross-sectional totals info).
#'       
#' When the input data contains multiple periods (temporal total preservation scenario), raking problem 
#' elements `x`, `c_x`, `g`, `c_g` and `G` are constructed _column by column_ (in "column-major order"), 
#' corresponding to the default behaviour of R for converting objects of class "matrix" into vectors.
#' 
#' Note: argument validation is not performed here; it is (bluntly) assumed that the function is called 
#' by [tsraking()] where a thorough validation of the arguments is done.
#'
#'
#' @seealso [tsraking()] [build_balancing_problem()]
#' 
#' @example misc/function_examples/build_raking_problem-ex.R
#' 
#' @export
build_raking_problem <- function(data_df,
                                 metadata_df,
                                 data_df_name = deparse1(substitute(data_df)),
                                 metadata_df_name = deparse1(substitute(metadata_df)),
                                 alterability_df = NULL,
                                 alterSeries = 1, 
                                 alterTotal1 = 0,
                                 alterTotal2 = 0) {
  
  
  # Alterability data frame creation function, taking into account both the specified
  # default (arguments `alter...`) and user-defined coefs (argument `alterability_df`)
  #
  # Main (parent) function objects used by the function (expected to exist):
  #  - P              : number of periods in the raking problem
  #  - alterability_df: user-defined alterability copefficients data frame
  #  - alterDF_cols   : list of column names of data frame `alterability_df` 
  #                     (`alterDF_cols == NULL` when `alterability_df == NULL`)
  create_alterDF <- function(cols, default_coef) {
    
    # Start with the default alter coefs
    default_cols <- setdiff(cols, alterDF_cols)
    alter_df <- as.data.frame(matrix(rep(default_coef, length(default_cols) * P),
                                     nrow = P,
                                     dimnames = list(NULL, default_cols)))
    
    # Add the user-defined alter coefs
    user_cols <- intersect(cols, alterDF_cols)
    if (length(user_cols) > 0) {
      alter_df <- cbind(alter_df, alterability_df[user_cols])
    }
    
    alter_df[cols]
  }
  
  
  ### Main function ###

  # Create the vectors of column names and other elementary objects
  dataDF_cols <- names(data_df)
  metaDF_cols <- toupper(names(metadata_df))
  names(metadata_df) <- metaDF_cols
  alterDF_cols <- names(alterability_df)
  P <- nrow(data_df)           # number of periods
  n_comp <- nrow(metadata_df)  # number of component series
  

  # Validate the metadata and build the raking problem matrices and vectors
  
  if (n_comp == 0) {
    stop("The input metadata data frame (argument 'metadata_df') must contain at least one observation (row).\n\n", 
         call. = FALSE)
  }
  gs.validate_cols(tolower(setdiff(c("SERIES", "TOTAL1"), metaDF_cols)), NULL, metadata_df_name)
  
  
  # Process component series info
  
  comp_cols <- gs.cleanup_col_list(metadata_df$SERIES)
  if (n_comp != length(comp_cols)) {
    stop("Column 'series' in the input metadata data frame (argument 'metadata_df') contains missing (NA) or blank (\"\") values.\n\n",
         call. = FALSE)
  }
  if (n_comp > length(unique(comp_cols))) {
    stop("Column 'series' in the input metadata data frame (argument 'metadata_df') contains duplicate values.\n\n",
         call. = FALSE)
  }
  gs.validate_cols(comp_cols, dataDF_cols, data_df_name, source_str = "metadata column 'series'")
  
  # Component series data vector `x` (column-major version of the input series data frame)
  x <- unlist(data_df[comp_cols], use.names = FALSE)
  K <- length(x)  # number of component series data points
  
  # Component series alter coef vector c_x (column-major version of the alter coef data frame data)
  c_x <- unlist(create_alterDF(comp_cols, alterSeries), use.names = FALSE)
  
  
  # Process marginal (contemporaneous) totals info
  
  temp <- gs.cleanup_col_list(metadata_df$TOTAL1)
  if (n_comp != length(temp)) {
    stop("Column 'total1' in the input metadata data frame (argument 'metadata_df') contains missing (NA) ", 
         "or blank (\"\") values.\n\n", call. = FALSE)
  }
  tot1_cols <- unique(temp)
  gs.validate_cols(tot1_cols, dataDF_cols, data_df_name, source_str = "metadata column 'total1'")
  N <- length(tot1_cols)
  tot_cols <- tot1_cols

  if ("TOTAL2" %in% metaDF_cols) {
    temp <- gs.cleanup_col_list(metadata_df$TOTAL2)
    if (length(temp) > 0) {
      if (n_comp != length(temp)) {
        stop("Column 'total2' in the input metadata data frame (argument 'metadata_df') contans missing (NA) ", 
             "or blank (\"\") values.\n\n", call. = FALSE)
      }
      tot2_cols <- unique(temp)
      M <- length(tot2_cols)
      if (M == 1) {
        stop("Column 'total2' in the input metadata data frame (argument 'metadata_df') defines a single dim. 2 total. ",
             "It should either be removed from the data frame for a 1-dimensional raking problem or be used to define ",
             "multiple dim. 2 totals for a 2-dimensional problem.\n\n", call. = FALSE)
      }
      gs.validate_cols(tot2_cols, dataDF_cols, data_df_name, source_str = "metadata column 'total2'")
      tot_cols <- c(tot_cols, tot2_cols)
    } else {
      tot2_cols <- NULL
      M <- 1
    }
  } else {
    tot2_cols <- NULL
    M <- 1
  }
  
  
  # Initialize aggregation matrix `G` and data vector `g` for the marginal totals
  
  # 1-dim raking (single marginal total): order of the component series doesn't matter
  if (M == 1) {
    if (length(tot_cols) != 1) {
      stop("Column 'total1' in the input metadata data frame (argument 'metadata_df') defines multiple totals ",
           "while a single total is expected in a 1-dimensional raking problem.\n\n", call. = FALSE)
    }
    n_tot <- 1
    L <- P
    
    # For each component series corresponds P rows and columns in matrix `G`
    G <- matrix(rep(diag(1, nrow = P), n_comp), nrow = P)
    
    # Totals alter coef vector c_g (column-major version of the alter coef data frame data)
    c_g <- unlist(create_alterDF(tot_cols, alterTotal1), use.names = FALSE)
    
  # 2-dim raking (multiple marginal totals): order of the component series is important (!)
  } else {
    if (n_comp < M * N) {
      stop("Incomplete specification of a 2-dimensional raking problem in the input metadata data frame ",
           "(argument 'metadata_df'). Some dim. 1 and dim. 2 total combinations (columns 'total1' and 'total2') ",
           "are missing from the data frame (have not been assigned a component series).\n\n", call. = FALSE)
    }
    if (any(duplicated(metadata_df[c("TOTAL1", "TOTAL2")], MARGIN = 1))) {
      stop("Invalid specification of a 2-dimensional raking problem in the input metadata data frame ",
           "(argument 'metadata_df'). Some dim. 1 and dim. 2 total combinations (columns 'total1' and 'total2') ",
           "appear more than once in the data frame (have been assigned more than one component series).\n\n",
           call. = FALSE)
    }
    n_tot <- M + N
    L <- n_tot * P
    
    # For each component series corresponds P rows and columns in matrix `G`
    # Initialize `G` with 0's
    G <- matrix(0, nrow = L, ncol = K)
    
    # 1st dim. totals aggregation vectors (update `G` with 1's in the right place)
    for (ii in 1:N) {
      # kk, the row number in the metadata data frame, represents column number(s) in matrix `G`.
      kk <- which(metadata_df$TOTAL1 == tot_cols[ii])
      for (jj in 1:P) {
        G[(ii - 1) * P + jj, (kk - 1) * P + jj] <- 1
      }
    }
    
    # 2nd dim. totals aggregation vectors (update `G` with 1's in the right place)
    for (ii in 1:M + N) {
      # same as for TOTAL1
      kk <- which(metadata_df$TOTAL2 == tot_cols[ii])
      for (jj in 1:P) {
        G[(ii - 1) * P + jj, (kk - 1) * P + jj] <- 1
      }
    }
    
    # Totals alter coef vector c_g (column-major version of the alter coef data frame data)
    c_g <- c(unlist(create_alterDF(tot1_cols, alterTotal1), use.names = FALSE),
             unlist(create_alterDF(tot2_cols, alterTotal2), use.names = FALSE))
  }
  
  # Totals data vector `g` (column-major version of the input series data frame data)
  g <- unlist(data_df[tot_cols], use.names = FALSE)
  
  
  # Return the raking problem elements
  list(x = x,
       c_x = c_x,
       comp_cols = comp_cols,
       g = g,
       c_g = c_g,
       tot_cols = tot_cols,
       G = G)
}
