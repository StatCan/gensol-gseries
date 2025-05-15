# OSQP settings sequence data frames builder


# 1- Default Sequence
#    ================

# Optimal sequence in terms of solution precision and execution time, based on an experimental study 
# involving 12 raking or balancing projects corresponding to ~8,000 balancing problems in total.
#   1) prior scaling,  eps_abs =              1e-06,  max_iter =  4,000,  polished solution required
#   2) prior scaling,  eps_abs =              1e-12,  max_iter = 10,000,  polished solution required
#   3)    no scaling,  eps_abs =              1e-12,  max_iter = 10,000,  polished solution NOT required
#   4) prior scaling,  eps_abs = `gs.min_tolerance`,  max_iter = 10,000,  polished solution NOT required
#
# Rationale:
#   - Prior data scaling, using the average of the free (nonbinding) problem values as the scaling factor, 
#     is sometimes necessary for OSQP to converge at a decent pace (i.e., to get reasonable improvements in the 
#     solution precision with each new iteration). Unfortunately, internal OSQP scaling (e.g., `scaling = 10L`) 
#     is not enough (not helping much) in these cases (i.e., cannot substitute "prior data scaling").
#   - Solving problems on prior-scaled data requires very precise solutions in order to ensure precise 
#     enough solutions once the data is brought back to the original scale.
#   - Polished OSQP solutions always correspond to precise enough solutions, even with prior-scaled data and
#     large convergence criteria.
#   - A much better rate of polished solutions is achieved on prior-scaled data.
#   - Faster convergence is achieved with larger convergence criteria, with `eps_abs = 1e-6` representing 
#     a good starting point (not much gain in speed starting with larger `eps_abs` values)
#   - `eps_abs = 1e-12` often generates precise enough solutions when a polished solution on prior-scaled data
#     with `eps_abs = 1e-6` could not be obtained.
#   - Machine epsilon (`gs.min_tolerance`) for all 4 convergence criteria (`eps_abs`, `eps_rel`, `eps_prim_inf` 
#     and `eps_dual_inf`) on prior-scaled data, although being slow, generates the best "last resort" solution.
#
default_osqp_sequence <- data.frame(max_iter = c(4000L, 10000L, 10000L, 10000L),
                                    sigma = rep.int(NA_real_, 4),
                                    eps_abs = c(1e-6, 1e-12, 1e-12, gs.min_tolerance),
                                    eps_rel = rep.int(NA_real_, 4),
                                    eps_prim_inf = rep.int(NA_real_, 4),
                                    eps_dual_inf = rep.int(NA_real_, 4),
                                    polish = rep.int(TRUE, 4),
                                    scaling = rep.int(0L, 4),
                                    prior_scaling = c(TRUE, TRUE, FALSE, TRUE),
                                    require_polished = c(TRUE, TRUE, FALSE, FALSE))
default_osqp_sequence$sigma <- pmin(1e-6, pmax(default_osqp_sequence$eps_abs / 1000, gs.min_tolerance))
default_osqp_sequence$eps_rel <- default_osqp_sequence$eps_abs
default_osqp_sequence$eps_prim_inf <- pmax(default_osqp_sequence$eps_abs / 10, gs.min_tolerance)
default_osqp_sequence$eps_dual_inf <- default_osqp_sequence$eps_prim_inf


# 2- Alternate Sequence
#    ==================

# Alternate version aiming at achieving very precise solutions at the expense of execution time.
#
# One may want to try this sequence if the default sequence does not generate precise enough solutions
# for some balancing problems.
#
# Rationale:
#   - From very small to larger convergence criteria, with machine epsilon criteria as a last attempt.
#   - Enforce polished solutions for all steps
#   - Start with non-prior-scaled data (the most precise polished solutions), then try with prior-scaled data
#   - 10,000 max iterations for all sequences
#
# Note: one can also try forcing all steps of either sequence (default or alternate) to be run with argument 
#       `full_sequence = TRUE` in order to get the best possible solution (smallest total constraint discrepancies),
#       at the expense of a longer execution time here, obviously.
#
alternate_osqp_sequence <- data.frame(max_iter = rep(10000L, 15),
                                      sigma = rep(NA_real_, 15),
                                      eps_abs = c(rep(c(1e-12, 1e-9, 1e-6, 1e-3, gs.min_tolerance), each = 2), 
                                                  c(1e-12, 1e-9, 1e-6, 1e-3, gs.min_tolerance)),
                                      eps_rel = rep(NA_real_, 15),
                                      eps_prim_inf = rep(NA_real_, 15),
                                      eps_dual_inf = rep(NA_real_, 15),
                                      polish = rep(TRUE, 15),
                                      scaling = c(rep(c(0L, 10L), 5), rep(0L, 5)),
                                      prior_scaling = c(rep(FALSE, 10), rep(TRUE, 5)),
                                      require_polished = rep(TRUE, 15))
alternate_osqp_sequence$sigma <- pmin(1e-6, pmax(alternate_osqp_sequence$eps_abs / 1000, gs.min_tolerance))
alternate_osqp_sequence$eps_rel <- alternate_osqp_sequence$eps_abs
alternate_osqp_sequence$eps_prim_inf <- pmax(alternate_osqp_sequence$eps_abs / 10, gs.min_tolerance)
alternate_osqp_sequence$eps_dual_inf <- alternate_osqp_sequence$eps_prim_inf



# 3- Save both data frames as package datasets
#    =========================================

# External version (exported for package users): individual .rda files in ./R/data/
# => avoids the user from prefixing them with the `<pkg-name>::` prefix
usethis::use_data(default_osqp_sequence, alternate_osqp_sequence, 
                  internal = FALSE, overwrite = TRUE)

# Internal version (for usage inside the package): single file ./R/sysdata.rda
# => necessary for proper execution of the package (including the examples)
usethis::use_data(default_osqp_sequence, alternate_osqp_sequence, 
                  internal = TRUE, overwrite = TRUE)


# NOTE: those are very small data frames (< 1KB each) and it is therefore not an issue to store both 
#       "external" and "internal" versions with the package.
