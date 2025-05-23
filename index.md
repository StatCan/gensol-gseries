
<!-- index.md is generated from index.Rmd. Please edit that file -->

# R package gseries

<!-- badges: start -->
<!-- [![CRAN status](https://www.r-pkg.org/badges/version/gseries)](https://cran.r-project.org/package=gseries) -->

[![Lifecycle:
stable](man/figures/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R-CMD-check
status](https://github.com/StatCan/gensol-gseries/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/StatCan/gensol-gseries/actions/workflows/R-CMD-check.yaml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/StatCan/gensol-gseries/graph/badge.svg?token=ZUL7LPM7EV)](https://codecov.io/gh/StatCan/gensol-gseries?branch=main)

<!-- badges: end -->
<!-- Display a link to the French `index.md' file (only when rendering an HTML document)
     &#10;     => the Pandoc "fenced_div" below (::: {.pkgdown-devel} <...> :::) is used to avoid 
        having the link generated in the pkgdown website home page
     => the link would only show in the "development" version of the pkgdown website
        (`development: mode: devel` in `_pkdown.yml` or `development: mode: auto` with a 4-level 
        version number in the DESCRIPTION file), which we do not use for gseries (we set 
        `development: mode: release` in `_pkdown.yml`, resulting in a single "release" website 
        regardless of the version number -->

<div class="pkgdown-devel">

[(Français : fichier `fr/index.md`)](fr/index.md)

</div>

## Description

R version of Statistics Canada’s (StatCan) generalized system
**G-Series** initially developed in SAS<sup>®</sup>. This website is
devoted to G-Series in R (package gseries). Email us at
<g-series@statcan.gc.ca> for information about the SAS<sup>®</sup>
versions.

> ***Note - StatCan intranet***  
> StatCan employees can also visit the G-Series Confluence page on the
> agency’s intranet (search for “G-Series \| G-Séries” in Confluence) as
> well as the G-Series GitLab development project also hosted on the
> agency’s intranet (search for “G-Series in R - G-Séries en R” in
> GitLab). The latter includes a version of the information and
> instructions contained on this page that are specific to the StatCan
> IT infrastructure (e.g., Artifactory and GitLab); see file
> `index_StatCan.md` in the GitLab project root folder.

G-Series 3.0 (package gseries 3.0.0) is the initial open-source version
of the software. It includes the rewriting in R of all SAS<sup>®</sup>
G‑Series 2.0 functionalities, that is PROC BENCHMARKING, PROC TSRAKING
and macro ***GSeriesTSBalancing*** along with a function for
benchmarking *stocks* using a spline interpolation approach where the
spline knots correspond to the benchmark-to-indicator ratios or
differences. It includes the following *core functions*:

- `benchmarking()`
- `stock_benchmarking()`
- `tsraking()`, `tsraking_driver()`
- `tsbalancing()` <br>

Other *utility functions* are also included with the package. Visit the
[Reference](./reference/index.html) page (top bar) for the complete list
of available functions.

## Installation

``` r
# Release version from CRAN 
# (coming soon...)
#install.packages("gseries")

# Development version from GitHub
install.packages("remotes")
remotes::install_github("StatCan/gensol-gseries")

# A specific release version from GitHub
remotes::install_github("StatCan/gensol-gseries@<release-tag>")
```

where *\<release-tag\>* refers to values listed under the GitHub project
[Tags](https://github.com/StatCan/gensol-gseries/tags) ($\geq$
*v3.0.0*).

#### *Alternative*

The package can also be installed from the downloaded source files. This
approach requires the prior installation of the packages on which
gseries depends (because of `repos = NULL` in the `install.packages()`
call).

1.  Access the relevant GitHub
    [repository](https://github.com/StatCan/gensol-gseries) (*main*
    branch or tag $\geq$ *v3.0.0*)
2.  Download the repository files (*Code* \> *Download ZIP*)
3.  Decompress the downloaded repository files
4.  Install the gseries package (and its dependent packages):

``` r
install.packages(c("ggplot2", "ggtext", "gridExtra", "lifecycle", "osqp", "rlang", "xmpdf"))
install.packages("<name & path of the decompressed downloaded repository files>",
                 repos = NULL, type = "source")
```

#### *Vignettes*

Installing gseries from CRAN (`install.packages("gseries")`)
automatically builds and installs the package vignettes. However, this
is not the case by default when installing a package from GitHub (with
`remotes::install_github()`) or from its downloaded source files (with
`install.packages(..., repos = NULL, type = "source")`). Although
vignettes are not necessary for a package to be functional, they contain
useful complementary documentation. The gseries package vignettes are
available under the ***Articles*** drop-down menu (top bar) of this
website and in the `pdf/` folder of the GitHub
[repository](https://github.com/StatCan/gensol-gseries). Installing
vignettes with the package makes them accessible from within R as well
(e.g., with `browseVignettes("gseries")` or
`vignette("<vignette-name>")`).

Building the gseries package vignettes requires the (free)
[Pandoc](https://pandoc.org/) software, which is included in
[RStudio](https://posit.co/downloads/), and a LaTeX distribution (e.g.,
[TinyTex](https://github.com/rstudio/tinytex-releases)). You should
therefore avoid trying to build the gseries package vignettes with the
basic R GUI (unless you have a standalone installation of Pandoc) or
without a working LaTeX distribution. Building vignettes also requires R
packages knitr and rmarkdown.

When installing **from GitHub**, use argument `build_vignettes = TRUE`:

``` r
install.packages(c("knitr", "remotes", "rmarkdown"))
remotes::install_github("StatCan/gensol-gseries", build_vignettes = TRUE)
```

When installing **from the downloaded source files**, build the *bundle
package* first with `devtools::build()`:

``` r
install.packages(c("devtools", "ggplot2", "ggtext", "gridExtra", "osqp", "xmpdf"))
bndl_pkg_path <- devtools::build("<name & path of the decompressed downloaded repository files>")
install.packages(bndl_pkg_path, repos = NULL, type = "source")
```

Note: packages knitr, lifecycle, rlang and rmarkdown are automatically
installed with devtools.

## Documentation

The bilingual (French-English) gseries package documentation available
in this website is also accessible from within R. Although R only
displays the English version of the gseries documentation, links to the
equivalent French pages on this website are provided at the beginning of
relevant gseries help pages in R. `help("gseries")` in R displays
general package information including a link (the URL) to this website.
Clicking the **Index** link at the bottom of the gseries package help
page in RStudio (or with `help(package = "gseries")`) displays a list of
all the documentation elements available for the package, including:

- topic/function help pages (top bar’s
  [Reference](./reference/index.html) page);
- vignettes, when installed (top bar’s ***Articles*** drop-down menu);
- package news ([Changelog](./news/index.html) page under the top bar’s
  ***News*** drop-down menu).

The individual function help pages found in the
[Reference](./reference/index.html) page (top bar) can be accessed
directly in R with `help("<function-name>")`. They contain comprehensive
information about each function including useful examples and will be
you primary source of information. The vignettes found under the
***Articles*** drop-down menu (top bar) are a complementary source of
information that, when installed with the package, can also be accessed
from within R with `browseVignettes("gseries")` or
`vignette("<vignette-name>")`. They include:

- a *Benchmarking CookBook* (`vignette("benchmarking-cookbook")`) going
  through the steps of a typical benchmarking project;
- *A Beginner’s Benchmarking Demo Script*
  (`vignette("benchmarking-demo-script")`) illustrating the usage of the
  benchmarking functions in a practical context;
- a *OSQP Settings Sequence Data Frame* page
  (`vignette("osqp-settings-sequence-dataframe")`) describing the
  *solving sequence* implemented in `tsbalancing()` and explaining how
  it can be customized.

Finally, the [Get started](./articles/gseries.html) page (top bar)
provides general information about G-Series and is available as a
vignette in R (`vignette("gseries")`).

#### *Local copy of the package website*

The `docs/` folder of the GitHub
[repository](https://github.com/StatCan/gensol-gseries) (*main* branch
or tag $\geq$ *v3.0.0*) contains the package website files and can
therefore be downloaded to obtain a local copy of this website. This can
be useful for offline consultation or for accessing the documentation of
a specific version of the package (e.g., the development version or an
earlier release). After having downloaded (*Code* \> *Download ZIP*) and
decompressed the repository files, open file `docs/en/index.html` in a
web browser to access the local copy of the (current) home page.
Alternatively, one can use GitHub tool [Download GitHub
directory](https://download-directory.github.io/) and download only the
contents of the `docs/` folder instead of the entire repository:

1.  Open the `docs/` folder of the relevant GitHub
    [repository](https://github.com/StatCan/gensol-gseries) (*main*
    branch or tag $\geq$ *v3.0.0*).
2.  Copy the folder URL (address bar) in the [Download GitHub
    directory](https://download-directory.github.io/) tool’s text field
    and press <kbd>Enter</kbd>.
3.  Decompress the downloaded directory.
4.  Open file `en/index.html` in a web browser.

Note: the *Search for* box (top bar) is not functional in local copies
of the package website.

#### *PDF format*

Bilingual (French-English) G-Series documentation in PDF format, also
useful for offline consultation or for a specific version of G-Series,
is available in the `pdf/` folder of the GitHub
[repository](https://github.com/StatCan/gensol-gseries) (*main* branch
or tag $\geq$ *v3.0.0* for the R versions and tag $\leq$ *v2.0* for the
SAS<sup>®</sup> versions). Again, GitHub tool [Download GitHub
directory](https://download-directory.github.io/) can be used to
download the contents of the `pdf/` folder instead of the entire
repository. Decompressing the downloaded directory will then unveil the
individual PDF files.
