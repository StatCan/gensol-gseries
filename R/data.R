#' OSQP settings sequence data frame
#'
#' @description
#'
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/osqp_settings_sequence.html}})}
#' 
#' Data frame containing a sequence of OSQP settings for [tsbalancing()] specified with argument 
#' `osqp_settings_df`. The package includes two predefined OSQP settings sequence data frames:
#' * [`default_osqp_sequence`][osqp_settings_sequence]: fast and effective (default `osqp_settings_df` argument value);
#' * [`alternate_osqp_sequence`][osqp_settings_sequence]: geared towards precision at the expense of execution time.
#' 
#' See `vignette("osqp-settings-sequence-dataframe")` for the actual contents of these data frames.
#'
#' @format A data frame with at least one row and at least one column, the *most common* columns being:
#' \describe{
#'   \item{max_iter}{Maximum number of iterations (integer)}
#'   \item{sigma}{Alternating direction method of multipliers (ADMM) sigma step (double)}
#'   \item{eps_abs}{Absolute tolerance (double)}
#'   \item{eps_rel}{Relative tolerance (double)}
#'   \item{eps_prim_inf}{Primal infeasibility tolerance (double)}
#'   \item{eps_dual_inf}{Dual infeasibility tolerance (double)}
#'   \item{polish}{Perform solution polishing (logical)}
#'   \item{scaling}{ Number of scaling iterations (integer)}
#'   \item{prior_scaling}{Scale problem data prior to solving with OSQP (logical)}
#'   \item{require_polished}{Require a polished solution to stop the sequence (logical)}
#'   \item{\[*any-other-OSQP-setting*\]}{Value of the corresponding OSQP setting}
#' }
#'
#' @details
#' With the exception of `prior_scaling` and `require_polished`, all columns of the data frame must 
#' correspond to a OSQP setting. Default OSQP values are used for any setting not specified in this 
#' data frame. Visit <https://osqp.org/docs/interfaces/solver_settings.html> for all available OSQP 
#' settings. Note that the OSQP `verbose` setting is actually controlled through [tsbalancing()] arguments 
#' `quiet` and `display_level` (i.e., column `verbose` in a *OSQP settings sequence data frame* would be ignored).
#' 
#' Each row of a *OSQP settings sequence data frame* represents one attempt at solving a balancing problem 
#' with the corresponding OSQP settings. The solving sequence stops as soon as a valid solution is obtained 
#' (a solution for which all constraint discrepancies are smaller or equal to the tolerance 
#' specified with [tsbalancing()] argument `validation_tol`) unless column `require_polished = TRUE`, 
#' in which case a polished solution from OSQP (`status_polish = 1`) would also be required 
#' to stop the sequence. Constraint discrepancies correspond to \eqn{\mathrm{max}(0, l - Ax, Ax - u)} 
#' with constraints defined as \eqn{l \le Ax \le u}{l <= Ax <= u}. In the event where a satisfactory solution 
#' cannot be obtained after having gone through the entire sequence, [tsbalancing()] returns the solution that 
#' generated the smallest total constraint discrepancies among valid solutions, if any, or among all solutions, 
#' otherwise. Note that running the entire solving sequence can be *enforced* by specifying [tsbalancing()] argument 
#' `full_sequence = TRUE`. Rows with column `prior_scaling = TRUE` have the problem data scaled prior to 
#' solving with OSQP, using the average of the free (nonbinding) problem values as the scaling factor.
#' 
#' In addition to specifying a custom-made *OSQP settings sequence data frame* with argument `osqp_settings_df`, 
#' one can also specify `osqp_settings_df = NULL` which would result in a single solving attempt with default OSQP 
#' values for all settings along with `prior_scaling = FALSE` and `require_polished = FALSE`. Note that it is 
#' recommended, however, to first try data frames `default_osqp_sequence` and `alternate_osqp_sequence`, along with 
#' `full_sequence = TRUE` if necessary, before considering other alternatives.
#' 
#' Vignette *OSQP Settings Sequence Data Frame* (`vignette("osqp-settings-sequence-dataframe")`) contains additional 
#' information.
#' 
#' @name osqp_settings_sequence
NULL

# NOTES (usage examples): 
#   a) bringing them all under subject `osqp_settings_sequence` above would generate 2 residual/extra lines 
#      ("default_osqp_sequence" and "alternate_osqp_sequence") in the Rd file (!)
#   b) the `tsbalancing()` call examples MUST be commented out, otherwise:
#      - the reference page is indexed under subject `tsbalancing()` instead of subjects 
#        `osqp_settings_sequence`, `default_osqp_sequence` and `alternate_osqp_sequence`.
#      - `R CMD check` fails: it complains about the `...` argument not being defined with `tsbalancing()` 
#        (removing the dot arguments from the calls would work but not solve the preceding issue).

#' @rdname osqp_settings_sequence
#' @usage 
#' # Default sequence:
#' # tsbalancing(..., osqp_settings_df = default_osqp_sequence)
"default_osqp_sequence"

#' @rdname osqp_settings_sequence
#' @usage 
#' 
#' # Alternative (slower) sequence:
#' # tsbalancing(..., osqp_settings_df = alternate_osqp_sequence)
#' 
#' # Custom-made sequence (use with caution!):
#' # tsbalancing(..., osqp_settings_df = <my-osqp-sequence-dataframe>)
#' 
#' # Single solving attempt with the default OSQP settings (not recommended!):
#' # tsbalancing(..., osqp_settings_df = NULL)
"alternate_osqp_sequence"
