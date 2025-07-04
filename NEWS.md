# gseries (development version)

<!-- Display a link to the French `NEWS.md' file (only when rendering an HTML document)
     
     => the `pkgdown-devel` "fenced_div" below is used to avoid having the link generated in the 
        pkgdown website Changelog page
     => the link would only show in the "development" version of the pkgdown website
        (`development: mode: devel` in `_pkdown.yml` or `development: mode: auto` with a 4-level 
        version number in the DESCRIPTION file), which we do not use for gseries (we set 
        `development: mode: release` in `_pkdown.yml`, resulting in a single "release" website 
        regardless of the version number -->
<div class="pkgdown-devel">

(*version française : <https://StatCan.github.io/gensol-gseries/fr/news/index.html>*)

</div>

* Minor corrections to the documentation (e.g., fixing typos).
* *Awesome Official Statistics* badge (`README.md`, `index.md` and `fr/index.md`).


# gseries 3.0.2

(*G-Series 3.0 in R*)

* Minor changes to comply with the CRAN requirements following the second submission process:
  * New package title (`DESCRIPTION`).
  * Return values added for function aliases (`aliases.R`).
  * Operator `<<-` replaced with environment specific assignments (for more predictive behaviour).


# gseries 3.0.1

(*G-Series 3.0 in R*)

* Bug fix in `tsbalancing()` to avoid altering the R session's error option (`getOption("error")`) after execution.

* Validation of class "data.frame" input objects in (relevant) utility functions for coherence with the core functions.

* Updated description of the function arguments regarding the expected class of input objects.

* Minor changes to comply with the CRAN requirements following the initial submission process.


# gseries 3.0.0

(*G-Series 3.0 in R*)

* Initial release of G-Series in R (package gseries).

* New functionality (`stock_benchmarking()`) designed for benchmarking stocks using a cubic spline interpolation approach.

* Improvements to the already existing functionalities:
  * **Benchmarking** (`benchmarking()`): 
    * new options allowing proportional benchmarking (`lambda != 0`) in presence of negative values in the input data;
    * a flat indicator series of *all zeros* is now allowed with additive benchmarking (`lambda = 0`).
  * **Raking** (`tsrasking()`):
    * optional alternative handling of negative values in the input data (same handling as `tsbalancing()`);
    * helper function (`tsraking_driver()`) to simplify the reconciliation of several periods in a single function call.
  * **Balancing** (`tsbalancing()`): 
    * customizable solving sequence (multiple attempts at solving the problem as opposed to a single attempt);
    * improved solution validation process with more information (output data frames) available to help troubleshooting invalid solutions;
    * optional input data *validation only* process (without attempting to solve the problem, i.e., resolve the discrepancies, if any).

* New utility functions to help using the core functions, e.g.;
  * for producing benchmarking plots;
  * for converting reconciliation problem metadata (`tsrasking()` to `tsbalancing()`);
  * for manipulating time series data (prepare or convert the input and output data objects).


# Version 2.0.0

(*G-Series 2.0 in SAS<sup>®</sup>*, contact [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* New ***GSeriesTSBalancing*** macro.


# Version 1.4.0

(*G-Series 1.04 in SAS<sup>®</sup>*, contact [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Name change: *Forillon* becomes *G-Series*.

* Introduction of alterability coefficients for PROC BENCHMARKING (when `rho <  1`).

* New `WITH` statement for PROC BENCHMARKING.

* New options `WARNNEGRESULT|NOWARNNEGRESULT` and `TOLNEGRESULT=` for PROC BENCHMARKING and PROC TSRAKING.


# Version 1.3.0

(*Forillon 1.03 in SAS<sup>®</sup>*, contact [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* New `VAR` and `BY` statements for PROC BENCHMARKING.


# Version 1.2.0

(*Forillon 1.02 in SAS<sup>®</sup>*, contact [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Addition of PROC TSRAKING.


# Version 1.1.0

(*Forillon 1.01 in SAS<sup>®</sup>*, contact [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Initial release with PROC BENCHMARKING.
