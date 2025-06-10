######
# Objects and functions in this "common utility script" are prefixed with "gs."
# to make them easy to spot in other (regular) scripts.



######
# Constants

# Package info (DESCRIPTION file fields)
gs.pkg_info <- utils::packageDescription("gseries")
attr(gs.pkg_info, "file") <- NULL  # drop the DESCRIPTION file name and path 

# Core function header string
gs.header <- paste0("--- Package gseries ", gs.pkg_info$Version)
if (length(gs.pkg_info$Title) > 0) {
  gs.header <- paste0(gs.header, " - ", gs.pkg_info$Title, " ---")
} else {
  gs.header <- paste0(gs.header, " ---")
}
if (length(gs.pkg_info$Created) > 0) {
  gs.header <- paste0(gs.header, "\nCreated on ", gs.pkg_info$Created)
}
if (length(gs.pkg_info$URL) > 0) {
  # Multiple URLs on separate lines
  gs.header <- paste0(gs.header, "\nURL: ", 
                      gsub("[[:blank:]]*,[[:blank:]]*[\n]?[[:blank:]]*", "\n     ", gs.pkg_info$URL))
} 
if (length(gs.pkg_info$Email) > 0) {
  # Multiple Emails on separate lines
  gs.header <- paste0(gs.header, "\nEmail: ", 
                      gsub("[[:blank:]]*,[[:blank:]]*[\n]?[[:blank:]]*", "\n       ", gs.pkg_info$Email))
} 

# Tolerances for numerical comparisons and number of significant digits for rounding
gs.min_tolerance <- .Machine$double.eps  # smallest positive floating-point number x such that `1 + x != 1`
gs.tolerance <- sqrt(gs.min_tolerance)  # default tolerance used in function `all.equal()`
gs.max_signif_digits <- ceiling(log10(1 / gs.min_tolerance))
gs.signif_digits <- ceiling(log10(1 / gs.tolerance))



######
# Functions

# Generic functions that do no processing
gs.FALSE_func <- function(...) {
  FALSE
}
gs.NULL_func <- function(...) {
  invisible(NULL)
}
gs.passThrough_func <- function(x) {
  x
}


# Generic calculation functions (e.g., for columns of output data frames)
gs.calc_ratio <- function(x, y, tol = gs.tolerance) {
  y[abs(y) <= tol] <- NA
  x / y
}
gs.calc_diff <- function(x, y, ...) {
  x - y
}
gs.calc_relDiff <- function(x, y, tol = gs.tolerance) {
  y[abs(y) <= tol] <- NA
  (x - y) / y
}
gs.calc_firstDiff <- function(x, ...) {
  x - c(NA, x[seq_len(length(x) - 1)])
}
gs.calc_relFirstDiff <- function(x, tol = gs.tolerance) {
  y <- c(NA, x[seq_len(length(x) - 1)])
  y[abs(y) <= tol] <- NA
  (x - y) / abs(y)
}


# Data validation functions
gs.check_alter <- function(x) {
  any(!is.finite(x)) || any(x < 0)
}
gs.check_neg <- function(x, tol = gs.tolerance) {
  any(x < -tol)
}


# Returns a character vector of trimmed strings (leading and trailing blanks removed) where missing (NA) 
# and empty ("") strings have been removed (i.e., not included in the returned vector).
#
# Note: lists corresponding to non atomic vectors (i.e., created with `list()` instead of `c()`) are 
#       transformed into atomic vectors (with `unlist()`), resulting in the same character vector 
#       being returned whether argument `str_vec` was created with `list()` or `c()`.
gs.cleanup_col_list <- function(str_vec) {
  x <- unlist(str_vec)
  logi_vec <- is.character(x) & !is.na(x)
  y <- trimws(x[logi_vec])
  y[y != ""]
}


# Utility function to implement argument `verbose = TRUE`, i.e. display of the
# processing steps with elapsed time
gs.display_difftime <- function(time1, time2, label) {
  time_d <- time2 - time1
  message("--- ", label, ": ", paste(format(time_d[[1]]), attr(time_d, "units")), "\n")
  invisible(NULL)
}


# Display/messaging functions

# Utility function to display an object in the console (development mode debugging)
gs.display_obj <- function(x, title = NA, head = FALSE, str = TRUE) {

  if (is.na(title))
    cat("\n", deparse1(substitute(x), collapse = "\n  "), "\n")
  else
    cat("\n", title, "\n")

  if (str)
    str(x)
  
  if (head)
    print(head(x))
  else
    print(x)

  invisible(NULL)
}

# Muted error message (`try(stop())` message)
gs.try_stop <- function(msg) {
  try(stop(msg, call. = FALSE))
}


# Returns a list of string vectors (same length as the input string vector) corresponding to the
# substrings (stripped of leading/trailing blanks) of the input string vector split according to the
# specified pattern (regular expression). The length of the returned list is 1 plus the maximum
# number of occurrences of the pattern in the input string vector. If the pattern is not found in
# the input string vector, then the returned list contains a single element corresponding to the
# input string vector.
#
# Example 1: single-string vector, 1 match
#
#   > gs.split_str("\\/", "abc / def")
#
#   returns a list of 2 strings (2 single-string vectors):
#     [[1]]  character [1]  "abc"
#     [[2]]  character [1]  "def"
#
# Example 2: 4-string vector, maximum of 2 matches
#
#   > gs.split_str("\\/", c("abc / def", "gh ijk", "lmno / p / qr", ""))
#
#   returns a list of 3 (three) 4-string vectors:
#     [[1]]  character [4]  "abc" "gh ijk" "lmno" ""
#     [[2]]  character [4]  "def" ""       "p"    ""
#     [[3]]  character [4]  ""    ""       "qr"   ""
#
# Example 3: 2-string vector, no match
#
#   > gs.split_str("\\/", c("abc def", "g"))
#
#   returns the input vector in a (single-element) list:
#     [[1]]  character [2]  "abc def" "g"
#
#
# Note: similar to base function `strsplit` but where the returned object is "transposed"
#       and the returned strings are stripped of leading and trailing blanks
gs.split_str <- function(pattern, str) {
  out_list <- list()
  while (length(grep(pattern, str)) > 0) {
    pos <- regexpr(pattern, str)
    pos <- pmax(pos, -pos * (nchar(str) + 1))
    out_list <- append(out_list, list(trimws(substr(str, rep(1, length(str)), pos - 1))))
    str <- trimws(substr(str, pos + 1, nchar(str)))
  }
  out_list <- append(out_list, list(str))
  out_list
}


# Validate a logical argument. The function Generates an error message if the argument is invalid 
# and invisibly returns the logical value of the argument otherwise.
gs.validate_arg_logi <- function(arg) {
  out_arg <- as.logical(unlist(arg))
  if (!identical(out_arg, TRUE) && !identical(out_arg, FALSE)) {
    stop("Argument '", deparse1(substitute(arg)), "' must either be TRUE or FALSE.\n\n", call. = FALSE)
  }
  invisible(out_arg)
}


# Validate string vector `cols` against string vector `against`: report (with an error message) 
# strings in `cols` that are not in `against`
gs.validate_cols <- function(cols, against, df_name, source_str = NA) {
  missing_cols <- setdiff(unique(cols), against)
  if (length(missing_cols) > 0) {
    if (is.na(source_str)) {
      stop("The following columns are missing from data frame \"", df_name, "\": ",
           paste0("\n  ", missing_cols, collapse = ""), "\n\n", call. = FALSE)
    } else {
      stop("The following columns listed with ", source_str, " are missing from data frame \"",
           df_name, "\": ", paste0("\n  ", missing_cols, collapse = ""), "\n\n", call. = FALSE)
    }
  } else {
    invisible(NULL)
  }
}




######
# Documented functions


#' Moore-Penrose inverse
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/gs.gInv_MP.html}})}
#' 
#' This function calculates the Moore-Penrose (pseudo) inverse of a square or rectangular matrix 
#' using Singular Value Decomposition (SVD). It is used internally by [tsraking()] and [benchmarking()].
#' 
#' @param X (mandatory) 
#' 
#' Matrix to invert.
#' 
#' @param tol (optional) 
#' 
#' Real number that specifies the tolerance for identifying zero singular values. When `tol = NA` (default), 
#' the tolerance is calculated as the product of the size (dimension) of the matrix, the norm of the matrix 
#' (largest singular value) and the _machine epsilon_ (`.Machine$double.eps`). 
#' 
#' **Default value** is `tol = NA`.
#' 
#' @returns
#' The Moore-Penrose (pseudo) inverse of matrix `X`.
#' 
#' @details
#' The default tolerance (argument `tol = NA`) is coherent with the tolerance used by the MATLAB and GNU Octave 
#' software in their general inverse functions. In our testing, this default tolerance also produced solutions 
#' (results) comparable to G-Series 2.0 in SAS\eqn{^\circledR}{®}.
#' 
#' @seealso [tsraking()] [benchmarking()]
#' 
#' @examples
#' # Invertible matrix
#' X1 <- matrix(c(3, 2, 8, 
#'                6, 3, 2,
#'                5, 2, 4), nrow = 3, byrow = TRUE)
#' Y1 <- gs.gInv_MP(X1)
#' all.equal(Y1, solve(X1))
#' X1 %*% Y1
#' 
#' # Rectangular matrix
#' X2 <- X1[-1, ]
#' try(solve(X2))
#' X2 %*% gs.gInv_MP(X2)
#' 
#' # Non-invertible square matrix
#' X3 <- matrix(c(3, 0, 0, 
#'                0, 0, 0, 
#'                0, 0, 4), nrow = 3, byrow = TRUE)
#' try(solve(X3))
#' X3 %*% gs.gInv_MP(X3)
#' 
#' @export
gs.gInv_MP <- function(X, tol = NA) {
  
  # Related contents on Wikipedia:
  # - "Moore-Penrose inverse" (<https://en.wikipedia.org/wiki/Moore%E2%80%93Penrose_inverse>)
  # - "Singular Value Decomposition" (<https://en.wikipedia.org/wiki/Singular_value_decomposition>)
  
  # Notes on function `svd(X)` where X is a matrix of dimension M x N:
  #   - Returned vector `d` is of dimension MIN(M, N) and contains the (nonnegative) singular
  #     values of `X` sorted decreasingly:
  #       - no need to take the absolute value of `d` in the inversion process;
  #       - the largest singular value is the 1st element of `d`.
  #   - Returned matrix `u` is of dimension M x N if M > N and M x M otherwise.
  #   - Returned matrix `v` is of dimension M x N if M < N and N x N otherwise.
  
  m <- nrow(X)
  n <- ncol(X)
  s <- svd(X)
  if (is.na(tol)) {
    tol <- max(m, n) * s$d[1] * .Machine$double.eps
  }
  d_inv <- ifelse(s$d <= tol, 0, 1 / s$d)
  s$v %*% diag(d_inv, min(m, n)) %*% t(s$u)
}


#' Time values conversion functions
#' 
#' @name time_values_conv
#' 
#' @description
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.html}})}
#' 
#' Time values conversion functions used internally by other gseries functions.
#' 
#' @param ts (mandatory) 
#' 
#' Time series (object of class "ts" or "mts").
#' 
#' @param sep (optional) 
#' 
#' String (character constant) specifying the separator to use between the year 
#' and period values.
#' 
#' **Default value** is `sep = "-"`.
#' 
#' @returns 
#' [gs.time2year()] returns an integer vector of the "nearest" year (time unit) values. This function is the 
#' equivalent of [stats::cycle()] for time unit values. 
#' 
#' [gs.time2per()] returns an integer vector of the period (cycle) values (see [stats::cycle()]).
#' 
#' [gs.time2str()] returns a character vector corresponding to `gs.time2year(ts)` if `stats::frequency(ts) == 1` 
#' or `gs.time2year(ts)` and `gs.time2per(ts)` separated with `sep` otherwise. 
#' 
#' @seealso [ts_to_tsDF()] [ts_to_bmkDF()] [gs.build_proc_grps()] 
#'  
#' @examples
#' # Dummy monthly time series 
#' mth_ts <- ts(rep(NA, 15), start = c(2019, 1), frequency = 12)
#' mth_ts
#' gs.time2year(mth_ts)
#' gs.time2per(mth_ts)
#' gs.time2str(mth_ts)
#' gs.time2str(mth_ts, sep = "m")
#' 
#' # Dummy quarterly time series 
#' qtr_ts <- ts(rep(NA, 5), start = c(2019, 1), frequency = 4)
#' qtr_ts
#' gs.time2year(qtr_ts)
#' gs.time2per(qtr_ts)
#' gs.time2str(qtr_ts)
#' gs.time2str(qtr_ts, sep = "q")

#' @rdname time_values_conv
#' @export
gs.time2year <- function(ts) {
  # Truncated time values shifted forward by "half a cycle"
  as.integer(signif(stats::time(ts) + 0.5 * stats::deltat(ts), gs.signif_digits))
}

#' @rdname time_values_conv
#' @export
gs.time2per <- function(ts) {
  as.integer(stats::cycle(ts))
}

#' @rdname time_values_conv
#' @export
gs.time2str <- function(ts, sep = "-") {
  if (stats::frequency(ts) == 1) {
    as.character(gs.time2year(ts))
  } else {
    paste(gs.time2year(ts), gs.time2per(ts), sep = sep)
  }
}


#' Build reconciliation processing groups
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/gs.build_proc_grps.html}})}
#' 
#' This function builds the processing groups data frame for reconciliation problems. It is used internally by 
#' [tsraking_driver()] and [tsbalancing()].
#' 
#' @param ts_yr_vec (mandatory) 
#' 
#' Vector of the time series year (time unit) values (see [gs.time2year()]).
#' 
#' @param ts_per_vec (mandatory) 
#' 
#' Vector of the time series period (cycle) values (see [gs.time2per()]).
#' 
#' @param n_per (mandatory) 
#' 
#' Time series length (number of periods).
#' 
#' @param ts_freq (mandatory) 
#' 
#' Time series frequency (see [stats::frequency()]).
#' 
#' @param temporal_grp_periodicity (mandatory) 
#' 
#' Number of periods in temporal groups.
#' 
#' @param temporal_grp_start (mandatory) 
#' 
#' First period of temporal groups.
#' 
#' @inheritSection tsbalancing Processing groups
#' 
#' @returns
#' A data frame with the following variables (columns):
#' - `grp`         : integer vector identifying the processing group (`1:<number-of-groups>`).
#' - `beg_per`     : integer vector identifying the first period of the processing group.
#' - `end_per`     : integer vector identifying the last period of the processing group.
#' - `complete_grp`: logical vector indicating if the processing group corresponds to a complete temporal group.
#' 
#' @seealso [tsraking_driver()] [tsbalancing()] [time_values_conv] 
#' 
#' @example misc/function_examples/gs.build_proc_grps-ex.R
#' 
#' @export
gs.build_proc_grps <- function(ts_yr_vec,
                               ts_per_vec,
                               n_per,
                               ts_freq,
                               temporal_grp_periodicity,
                               temporal_grp_start) {


  # Define processing groups for period-by-period processing (no temporal total preservation)
  if (temporal_grp_periodicity == 1) {

    # Create the processing groups data frame (each period is a processing group)
    per_vec <- 1:n_per
    grp_df <- data.frame(grp = per_vec,
                         beg_per = per_vec,
                         end_per = per_vec,
                         complete_grp = rep(FALSE, n_per))


  # Define processing groups for temporal groups processing (temporal total preservation)
  #
  # => The idea is to create a "ts" object of the temporal group frequency (frequency = `temporal_grp_periodicity`) 
  #    where the "unit values" (integer portion of the "ts" object time values) represent the temporal group and the
  #    "cycle values" represent the periods within the temporal group.
  #
  # => Then...
  #      - the set of periods of each complete temporal group (# of periods = `temporal_grp_periodicity`) will 
  #        constitute individual processing groups (with temporal total preservation)
  #      - each period of each incomplete temporal group (# of periods < `temporal_grp_periodicity`) will 
  #        constitute individual processing groups (without temporal total preservation)
  #
  } else {

    # Define the temporal groups vector (`tmpGrp_vec = 1..[# of temporal groups]` or length `n_per`) identifying 
    # the temporal group associated to each period

    
    # Temporal groups = years (annual total preservation: keep the original start time (and frequency))
    if (temporal_grp_periodicity == ts_freq) {
      start_time <- c(ts_yr_vec[1], ts_per_vec[1])
      start_per <- temporal_grp_start

      
    # Other (non-year) temporal groups (temporal groups where the "time series unit" no longer represents a "year")
    } else {

      # Temporal groups shorter than a year
      if (temporal_grp_periodicity < ts_freq) {

        # Map the input "ts" start to a temporal group period
        start_time <- c(ts_yr_vec[1], (ts_per_vec[1] - 1) %% temporal_grp_periodicity + 1)
        start_per <- temporal_grp_start

      # Temporal groups longer than a year
      } else {

        # Map the temporal group start period to an input "ts" period
        start_per <- (temporal_grp_start - 1) %% ts_freq + 1
        start_id_vec <- which(ts_per_vec == start_per)

        # Calculate extra years for the temporal group start (as necessary)
        if (length(start_id_vec) > 0) {

          # Number of years in the temporal group (capped upwards, i.e., 1.5 -> 2)
          tmpGrp_yrs <- ceiling(temporal_grp_periodicity / ts_freq)

          # Keep `xtra_yrs` in the [0..(`tmpGrp_yrs` - 1)] interval
          xtra_yrs <- (
            # Groups should start on a "whole year" (a multiple of `tmpGrp_yrs`) by default (e.g., even years of biennial groups)
            tmpGrp_yrs - ts_yr_vec[start_id_vec[1]] %% tmpGrp_yrs
            # Shift for groups that shouldn't start on a "whole year" (e.g., odd year start for biennial groups)
            + (temporal_grp_start - 1) %/% ts_freq
          ) %% tmpGrp_yrs

        } else {
          xtra_yrs <- 0
        }

        # At least 1 occurrence of the temporal group start: start time corresponds to the start of a "ts" object
        # (with the new frequency) that ends with the start of the 1st temporal group
        if (length(start_id_vec) > xtra_yrs) {
          start_time <- stats::time(stats::ts(rep(NA, start_id_vec[1 + xtra_yrs]),
                                              end = c(ts_yr_vec[start_id_vec[1]] + xtra_yrs, start_per),
                                              frequency = temporal_grp_periodicity))[1]

        # No occurrence of the temporal group start (no complete temporal group): keep the "original" start time
        } else {
          start_time <- c(ts_yr_vec[1], ts_per_vec[1])
        }
      }
    }
    
    # Create the (new) "ts" object (with the new frequency and start)
    temp_ts <- stats::ts(data = rep.int(NA, n_per),
                         start = start_time,
                         frequency = temporal_grp_periodicity)
    
    # This is where it all happens: the temporal group ids are simply the (new) "ts" object time units 
    # (integer portion of the time values), shifted to take into account the temporal group start, 
    # and then finally "adjusted/realigned/translated" so that they start at 1.
    #
    # => Proper temporal groups determination (assignment) is ensured by the fact that the time values of `temp_ts` 
    #    are always aligned at the start of an interval ("pure ts object" time values), even for cases where the 
    #    original `in_ts` time values are not ("non-pure ts object" time values). I.e., no need to use `gs.time2year()` 
    #    to get the "unit values" (simply "truncating" the time values works fine)
    #
    temp_ts_unit <- as.integer(signif(stats::time(temp_ts) - (start_per - 1) * stats::deltat(temp_ts),
                                      gs.signif_digits))
    tmpGrp_vec <- temp_ts_unit - temp_ts_unit[1] + 1L


    # Create the processing groups data frame
    #  - Periods of a complete temporal group are processed together (in a single processing group)
    #  - Periods of an incomplete temporal group are processed separately (in individual processing groups of 1 period)
    #  - Only the 1st and last temporal groups can be incomplete (middle temporal groups are always complete)

    # 1st temporal group (can be "incomplete")
    grp_n_per <- sum(tmpGrp_vec == 1)

    # Complete
    if (grp_n_per == temporal_grp_periodicity) {
      grp_df <- data.frame(grp = 1,
                           beg_per = 1,
                           end_per = grp_n_per,
                           complete_grp = TRUE)
      grp_padding <- 0

    # Incomplete
    } else {
      per_vec <- 1:grp_n_per
      grp_df <- data.frame(grp = per_vec,
                           beg_per = per_vec,
                           end_per = per_vec,
                           complete_grp = rep(FALSE, grp_n_per))
      grp_padding <- grp_n_per - 1
    }

    # Middle temporal groups (always "complete")
    mid_tmpGrp_vec <- seq_len(max(0, tmpGrp_vec[n_per] - 2)) + 1
    n_mid_grp <- length(mid_tmpGrp_vec)
    beg_per_vec <- (mid_tmpGrp_vec - 2) * temporal_grp_periodicity + 1 + grp_n_per
    end_per_vec <- beg_per_vec + temporal_grp_periodicity - 1
    grp_df <- rbind(grp_df,
                    data.frame(grp = mid_tmpGrp_vec + grp_padding,
                               beg_per = beg_per_vec,
                               end_per = end_per_vec,
                               complete_grp = rep(TRUE, n_mid_grp)))

    # Last temporal group (can be "incomplete")
    if (grp_df$end_per[length(grp_df$end_per)] < n_per) {
      grp_n_per <- n_per - grp_df$end_per[length(grp_df$end_per)]

      # Complete
      if (grp_n_per == temporal_grp_periodicity) {
        beg_per <- grp_df$end_per[length(grp_df$end_per)] + 1
        end_per <- beg_per + temporal_grp_periodicity - 1
        grp_df <- rbind(grp_df,
                        data.frame(grp = tmpGrp_vec[n_per] + grp_padding,
                                   beg_per = beg_per,
                                   end_per = end_per,
                                   complete_grp = TRUE)
        )

      # Incomplete
      } else {
        per_vec <- (grp_df$end_per[length(grp_df$end_per)] + 1):n_per
        grp_df <- rbind(grp_df,
                        data.frame(grp = 1:grp_n_per + grp_df$grp[length(grp_df$grp)],
                                   beg_per = per_vec,
                                   end_per = per_vec,
                                   complete_grp = rep(FALSE, grp_n_per)))
      }
    }
  }

  # Return the processing groups data frame, converting the group and period id's to integers
  # `sapply()` is safe: it always returns a compatible object for the assignment operator 
  # (a vector of length 3 if `grp_df` has a single row or a matrix of matching dimension otherwise)
  grp_df[, 1:3] <- sapply(grp_df[, 1:3], as.integer)
  grp_df
}
