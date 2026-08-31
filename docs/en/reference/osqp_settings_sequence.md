# OSQP settings sequence data frame

Data frame containing a sequence of OSQP settings for
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
specified with argument `osqp_settings_df`. The package includes two
predefined OSQP settings sequence data frames:

- `default_osqp_sequence`: fast and effective (default
  `osqp_settings_df` argument value);

- `alternate_osqp_sequence`: geared towards precision at the expense of
  execution time.

See
[`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md)
for the actual contents of these data frames.

## Usage

``` r
# Default sequence:
# tsbalancing(..., osqp_settings_df = default_osqp_sequence)

# Alternative (slower) sequence:
# tsbalancing(..., osqp_settings_df = alternate_osqp_sequence)

# Custom-made sequence (use with caution!):
# tsbalancing(..., osqp_settings_df = <my-osqp-sequence-dataframe>)

# Single solving attempt with the default OSQP settings (not recommended!):
# tsbalancing(..., osqp_settings_df = NULL)
```

## Format

A data frame with at least one row and at least one column, the *most
common* columns being:

- max_iter:

  Maximum number of iterations (integer)

- sigma:

  Alternating direction method of multipliers (ADMM) sigma step (double)

- eps_abs:

  Absolute tolerance (double)

- eps_rel:

  Relative tolerance (double)

- eps_prim_inf:

  Primal infeasibility tolerance (double)

- eps_dual_inf:

  Dual infeasibility tolerance (double)

- polishing:

  Perform solution polishing (logical)

- scaling:

  Number of scaling iterations (integer)

- prior_scaling:

  Scale problem data prior to solving with OSQP (logical)

- require_polished:

  Require a polished solution to stop the sequence (logical)

- \[*any-other-OSQP-setting*\]:

  Value of the corresponding OSQP setting

## Details

With the exception of `prior_scaling` and `require_polished`, all
columns of the data frame must correspond to a OSQP setting. Default
OSQP values are used for any setting not specified in this data frame.
Visit <https://osqp.org/docs/interfaces/solver_settings.html> for all
available OSQP settings. Note that the OSQP `verbose` setting is
actually controlled through
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
arguments `quiet` and `display_level` (i.e., column `verbose` in a *OSQP
settings sequence data frame* would be ignored).

Each row of a *OSQP settings sequence data frame* represents one attempt
at solving a balancing problem with the corresponding OSQP settings. The
solving sequence stops as soon as a valid solution is obtained (a
solution for which all constraint discrepancies are smaller or equal to
the tolerance specified with
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
argument `validation_tol`) unless column `require_polished = TRUE`, in
which case a polished solution from OSQP (`status_polish = 1`) would
also be required to stop the sequence. Constraint discrepancies
correspond to \\\mathrm{max}(0, l - Ax, Ax - u)\\ with constraints
defined as \\l \le Ax \le u\\. In the event where a satisfactory
solution cannot be obtained after having gone through the entire
sequence,
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
returns the solution that generated the smallest total constraint
discrepancies among valid solutions, if any, or among all solutions,
otherwise. Note that running the entire solving sequence can be
*enforced* by specifying
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
argument `full_sequence = TRUE`. Rows with column `prior_scaling = TRUE`
have the problem data scaled prior to solving with OSQP, using the
average of the free (nonbinding) problem values as the scaling factor.

In addition to specifying a custom-made *OSQP settings sequence data
frame* with argument `osqp_settings_df`, one can also specify
`osqp_settings_df = NULL` which would result in a single solving attempt
with default OSQP values for all settings along with
`prior_scaling = FALSE` and `require_polished = FALSE`. Note that it is
recommended, however, to first try data frames `default_osqp_sequence`
and `alternate_osqp_sequence`, along with `full_sequence = TRUE` if
necessary, before considering other alternatives.

Vignette *OSQP Settings Sequence Data Frame*
([`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md))
contains additional information.
