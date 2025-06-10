#' Helper function for [tsraking()]
#'
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.html}})}
#' 
#' Helper function for the [tsraking()] function that conveniently determines the required set of raking
#' problems to be solved and internally generates the individual calls to [tsraking()]. It is especially
#' useful in the context of temporal total (e.g., annual total) preservation where each individual raking
#' problem either involves a single period for incomplete temporal groups (e.g., incomplete years) or several
#' periods for complete temporal groups (e.g., the set of periods of a complete year).
#'
#'
#' @usage
#' tsraking_driver(
#'   in_ts,
#'   ...,  # `tsraking()` arguments excluding `data_df`
#'   temporal_grp_periodicity = 1,
#'   temporal_grp_start = 1
#' )
#'
#' 
#' @param in_ts (mandatory)
#'
#' Time series (object of class "ts" or "mts") that contains the time series data to be reconciled. 
#' They are the raking problems' input data (initial solutions).
#'
#' @inheritDotParams tsraking -data_df
#' 
#' @inheritParams tsbalancing
#' 
#' 
#' @details
#' This function solves one raking problem with [tsraking()] per processing group (see section **Processing groups** for 
#' details). The mathematical expression of these raking problem can be found in the **Details** section of the [tsraking()] 
#' documentation.
#' 
#' The alterability coefficients data frame (argument `alterability_df`) specified with [tsraking_driver()] can either 
#' contain:
#' * A single observation: the specified coefficients will be used for all periods of input time series object (argument 
#' `in_ts`).
#' * A number of observations equal to `frequency(in_ts)`: the specified coefficients will be used for the 
#' corresponding *cycle* of the input time series object (argument `in_ts`) periods. Monthly data example: 1<sup>st</sup> 
#' observation for January, 2<sup>nd</sup> observation for February, etc.).
#' * A number of observations equal to `nrow(in_ts)`: the specified coefficients will be used for the corresponding 
#' periods of the input time series object (argument `in_ts`), i.e., 1<sup>st</sup> observation for the 1<sup>st</sup> 
#' period, 2<sup>nd</sup> observation for the 2<sup>nd</sup> period, etc.).
#'
#' Specifying `quiet = TRUE` will suppress the [tsraking()] messages (e.g., function header) and only
#' display essential information such as warnings, errors and the period (or set of periods) being reconciled.
#' We advise against _wrapping_ your [tsraking_driver()] function call with [suppressMessages()] to further
#' suppress the display of the _raking period(s)_ information as this would make troubleshooting difficult
#' in case of issues with individual raking problems.
#'
#' Although [tsraking()] could be called with `*apply()` to successively reconcile all the periods of the input time 
#' series (`in_ts`), using [tsraking_driver()] has a few advantages, namely:
#' - temporal total preservation (only period-by-period processing, without temporal total preservation,
#' would be possible with `*apply()`);
#' - more flexibility in the specification of user-defined alterability coefficients (e.g., period-specific values);
#' - display of the period being processed (reconciled) in the console, which is useful for troubleshooting individual
#' raking problems;
#' - improved error handling, i.e., better management of warnings or errors if they were to occur only for some
#' raking problems (periods);
#' - readily returns a "ts" ("mts") object.
#'
#' 
#' @inheritSection tsbalancing Processing groups
#'
#'
#' @returns
#' The function returns a time series object (class "ts" or "mts") containing the reconciled component series, 
#' reconciled cross-sectional control totals and other series specified with [tsraking()] argument `id`. It can be 
#' explicitly coerced to another type of object with the appropriate `as*()` function (e.g., `tsibble::as_tsibble()` 
#' would coerce it to a tsibble). 
#' 
#' Note that a `NULL` object is returned if an error occurs before data processing could start. Otherwise, if execution 
#' gets far enough so that data processing could start, then an incomplete object (with `NA` values) would be returned 
#' in case of errors. 
#'
#'
#' @references Statistics Canada (2018). "Chapter 6: Advanced topics", **Theory and Application of Reconciliation
#' (Course code 0437)**, Statistics Canada, Ottawa, Canada.
#'
#'
#' @seealso [tsraking()] [tsbalancing()] [rkMeta_to_blSpecs()] [gs.build_proc_grps()] 
#'
#'
#' @example misc/function_examples/tsraking_driver-ex.R
#'
#'
#' @export
tsraking_driver <- function(in_ts,                         # input data as a "ts" ("mts") object
                            ...,                           # `tsraking()` arguments excluding `data_df`
                            temporal_grp_periodicity = 1,  # positive integer (number of periods for temporal group preservation)
                            temporal_grp_start = 1) {      # integer in the [1..`temporal_grp_periodicity`] interval




  ### Internal functions ###


  # Generate the `alterability_df` argument data frame
  gen_alter_arg <- function(per_vec) {
    alter_df[per_vec, , drop = FALSE]
  }




  ### Main function ###
  
  # Initialize the object to be returned by the function via `on.exit()`
  out_ts <- NULL
  on.exit(return(out_ts))
  try_error <- FALSE
  try_error_msg <- ""
  warning_flag <- FALSE
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)


  # Argument validation

  # Mandatory arguments (without default values)
  if (nchar(deparse1(substitute(in_ts))) == 0) {
    stop("Argument 'in_ts' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  in_ts <- in_ts
  if (!stats::is.ts(in_ts)) {
    stop("Argument 'in_ts' is not a 'ts' object.\n\n", call. = FALSE)
  }
  in_ts <- stats::as.ts(in_ts)
  ts_freq <- stats::frequency(in_ts)
  periods <- gs.time2str(in_ts)
  
  # Optional arguments (with default values)
  tmp <- (unlist(temporal_grp_periodicity))[1]
  if (!identical(temporal_grp_periodicity, tmp) || is.null(tmp) || !is.finite(tmp) ||
      is.finite(tmp) && (tmp <= 0 || tmp != as.integer(tmp))) {
    stop("Argument 'temporal_grp_periodicity' must be a positive integer.\n\n", call. = FALSE)
  }
  temporal_grp_periodicity <- as.integer(temporal_grp_periodicity)
  if (temporal_grp_periodicity > 1) {
    tmp <- (unlist(temporal_grp_start))[1]
    if (!identical(temporal_grp_start, tmp) || is.null(tmp) || !is.finite(tmp) ||
        is.finite(tmp) && (tmp <= 0 || tmp > temporal_grp_periodicity || tmp != as.integer(tmp))) {
      stop("Argument 'temporal_grp_start' must be an integer in the [1..", temporal_grp_periodicity, "] interval.\n\n",
           call. = FALSE)
    }
    temporal_grp_start <- as.integer(temporal_grp_start)
  }


  # Build the initial version of the input data frame
  n_per <- nrow(in_ts)
  in_df <- data.frame(RK._t_ = 1:n_per,
                      RK._year_ = gs.time2year(in_ts),
                      RK._per_ = gs.time2per(in_ts),
                      as.data.frame(in_ts))
  row.names(in_df) <- NULL


  # `tsraking()` arguments, i.e. the dot (...) arguments
  n_dot_args <- ...length()
  if (n_dot_args == 0) {
    stop("`tsraking()` argument 'metadata_df' must be specified.\n\n", call. = FALSE)
  }
  dot_args_list <- list(...)
  dot_args <- ...names()
  if (length(dot_args) == 0) {
    dot_args <- rep("", n_dot_args)
    names(dot_args_list) <- dot_args
  }
  tsraking_args <- names(formals("tsraking"))

  # "named" arguments
  named_args <- intersect(dot_args, tsraking_args)
  args_list <- dot_args_list[named_args]
  if ("data_df" %in% names(args_list)) {
    stop("`tsraking()` argument 'data_df' must NOT be specified with `tsraking_driver()`. ",
         "Use argument 'in_ts' instead.\n\n", call. = FALSE)
  }

  # "unnamed" arguments
  n_unnamed <- n_dot_args - length(args_list)
  if (n_unnamed > 0) {
    temp <- setdiff(dot_args, named_args)
    invalid_args <- temp[temp != ""]
    if (length(invalid_args) > 0) {
      stop("The following arguments are not defined for `tsraking()`:",
           paste0("\n  ", invalid_args, collapse = ""), "\n\n", call. = FALSE)
    }
    remaining_tsraking_args <- setdiff(tsraking_args, c("data_df", named_args))
    if (n_unnamed > length(remaining_tsraking_args)) {
      stop("Unable to match some of the specified dot (...) arguments with `tsraking()` arguments. ",
           "Remember not to specify argument 'data_df' with `tsraking_driver()`. Use argument 'in_ts' instead.\n\n",
           call. = FALSE)
    }

    # Assign names to the unnamed `tsraking()` arguments and add them to list `args_list`
    unnamed_args_list <- dot_args_list[which(dot_args == "")]
    names(unnamed_args_list) <- remaining_tsraking_args[1:n_unnamed]
    args_list <- c(args_list, unnamed_args_list)
  }
  specified_args <- names(args_list)


  # Quick validation of argument `metadata_df`
  if (!("metadata_df" %in% specified_args)) {
    stop("`tsraking()` argument 'metadata_df' must be specified.\n\n", call. = FALSE)
  }
  if (!is.data.frame(args_list$metadata_df)) {
    stop("`tsraking()` argument 'metadata_df' must be a 'data.frame' object.\n\n", call. = FALSE)
  }
  args_list$metadata_df <- as.data.frame(args_list$metadata_df)
  meta_cols <- toupper(names(args_list$metadata_df))
  if (length(intersect(c("SERIES", "TOTAL1"), meta_cols)) < 2) {
    stop("`tsraking()` argument 'metadata_df' contains invalid data. Suspecting argument ",
         "'data_df' to be inadvertently specified for argument 'metadata_df'.\n\n", call. = FALSE)
  }
  meta_df <- args_list$metadata_df
  names(meta_df) <- meta_cols


  # Process the alterability file (argument 'alterability_df')
  alter_arg_id <- which(specified_args == "alterability_df")
  if (length(alter_arg_id) == 1) {
    if (!is.null(args_list$alterability_df)) {

      if (!is.data.frame(args_list$alterability_df)) {
        stop("`tsraking()` argument 'alterability_df' must be a 'data.frame' object.\n\n", call. = FALSE)
      }
      args_list$alterability_df <- as.data.frame(args_list$alterability_df)


      # Assign the relevant alter coefs to each individual period
      n_alter_obs <- nrow(args_list$alterability_df)

      # Single obs: propagate (replicate) the alter coefs for all periods
      if (n_alter_obs == 1) {
        alter_df <- args_list$alterability_df[rep(1, n_per), , drop = FALSE]
        row.names(alter_df) <- NULL

      # Number of obs matches the 'ts' frequency: propagate the alter coefs to the corresponding
      # periods (matching cycles) in the 'ts'
      } else if (n_alter_obs == ts_freq) {
        alter_df <- args_list$alterability_df
        row.names(alter_df) <- NULL
        alter_df$RK._per_ <- as.integer(row.names(alter_df))
        temp <- c("RK._per_", "RK._t_")
        alter_df <- merge(alter_df, in_df[temp], by = "RK._per_")
        alter_df <- alter_df[order(alter_df$RK._t_), setdiff(names(alter_df), temp), drop = FALSE]
        row.names(alter_df) <- NULL

      # Number of obs matches the number of periods in the 'ts': nothing to do
      } else if (n_alter_obs == n_per)  {
        alter_df <- args_list$alterability_df
        row.names(alter_df) <- NULL

      # Incompatible number of obs in the `alterability_df` data frame
      } else {
        stop("`tsraking()` argument 'alterability_df' contains a number of observations ",
             "that is not compatible with the specified time series (argument 'in_ts').\n\n", call. = FALSE)
      }
      alter_arg_func <- gen_alter_arg

    # No alterability file
    } else {
      alter_arg_func <- gs.NULL_func
    }

    # Temporarily remove `alterability_df` from the list of arguments (will be (re)added for each
    # `tsraking()` call)
    args_list <- args_list[-alter_arg_id]

    # No `alterability_df` argument
  } else {
    alter_arg_func <- gs.NULL_func
  }


  # Set the output time series columns and problem variables (`NA` in case of errors)
  all_cols <- colnames(in_ts)
  prob_cols <- intersect(all_cols, unlist(apply(meta_df[intersect(meta_cols, c("SERIES", "TOTAL1", "TOTAL2"))],
                                                2, unique)))
  names(prob_cols) <- NULL
  if ("id" %in% specified_args) {
    xtra_cols <- intersect(all_cols, gs.cleanup_col_list(args_list$id))
  } else {
    xtra_cols <- character(0)
  }
  out_cols <- intersect(all_cols, unique(c(prob_cols, xtra_cols)))


  # Define the processing groups (set of raking problems)
  grp_df <- gs.build_proc_grps(in_df$RK._year_,
                               in_df$RK._per_,
                               n_per,
                               ts_freq,
                               temporal_grp_periodicity,
                               temporal_grp_start)

  # Activate message display
  n_grps <- nrow(grp_df)
  if (n_grps > 1) {
    msg_func <- message
    final_msg_flag <- TRUE
    try_stop_func <- gs.try_stop
  } else {
    msg_func <- gs.NULL_func
    final_msg_flag <- FALSE
    try_stop_func <- gs.NULL_func
  }


  # Rake each processing group (generate the `tsraking()` calls)
  out_df <- NULL
  for (grp in 1:n_grps) {

    # Print the processing group header
    if (grp_df$complete_grp[grp]) {
      msg_str <- paste0("Raking periods [", periods[grp_df$beg_per[grp]], " - ", periods[grp_df$end_per[grp]], "]")
    } else {
      msg_str <- paste0("Raking period [", periods[grp_df$beg_per[grp]], "]")
    }
    msg_func("\n\n", msg_str)
    msg_func(strrep("=", nchar(msg_str)), "\n")

    per_vec <- grp_df$beg_per[grp]:grp_df$end_per[grp]
    grp_data_df <- in_df[per_vec, out_cols, drop = FALSE]

    out_df <- rbind(out_df,
                    tryCatch(
                      withCallingHandlers(

                        do.call("tsraking",
                                c(list(data_df = grp_data_df,
                                       alterability_df = alter_arg_func(per_vec)),
                                  args_list)
                        ),

                        warning = function(wCnd) {
                          warning_flag <<- TRUE
                        }
                      ),

                      error = function(eCnd) {
                        try_error_msg <<- conditionMessage(eCnd)
                        try_stop_func(try_error_msg)
                        try_error <<- TRUE
                        df <- grp_data_df
                        df[prob_cols] <- NA
                        df
                      }
                    ))
  }


  # Create the output ts object
  out_ser <- intersect(all_cols, names(out_df))
  out_ts <- stats::ts(data = out_df[out_ser],
                      start = stats::start(in_ts),
                      frequency = ts_freq)


  # Display a final warning/error message for multiple processing groups
  if (final_msg_flag) {
    if (warning_flag) {
      warning("Warnings were generated during processing. See relevant message(s) for details.\n",
              call. = FALSE, immediate. = TRUE)
    }
    # Non-muted error message (for proper condition catching by users of the function)
    if (try_error) {
      stop("Problems were encontered during processing. See preceeding error message(s) for details.\n\n",
           call. = FALSE)
    }
    
  # Display the error message for single processing groups
  } else if (try_error) {
    stop(try_error_msg, call. = FALSE)
  }
  
  # Output object returned via function `on.exit()`
}
