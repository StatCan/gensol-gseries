# R package gseries

## Description

R version of Statistics Canada’s (StatCan) generalized system
**G‑Series** initially developed in SAS^(®). This website is devoted to
G‑Series in R (package gseries). Email us at <g-series@statcan.gc.ca>
for information about the SAS^(®) versions.

> ***Note - StatCan intranet***  
> StatCan employees can also visit the G‑Series Confluence page on the
> agency’s intranet (search for “G-Series \| G-Séries” in Confluence) as
> well as the G‑Series GitLab development project also hosted on the
> agency’s intranet (search for “G-Series in R - G-Séries en R” in
> GitLab). The latter includes a version of the information and
> instructions contained on this page that are specific to the StatCan
> IT infrastructure (e.g., Artifactory and GitLab); see file
> `index_StatCan.md` in the GitLab project root folder.

G‑Series 3.0 (package gseries 3.0.3) is the initial open-source version
of the software. It includes the rewriting in R of all SAS^(®) G‑Series
2.0 functionalities, that is PROC BENCHMARKING, PROC TSRAKING and macro
***GSeriesTSBalancing*** along with a function for benchmarking *stocks*
using a spline interpolation approach where the spline knots correspond
to the benchmark-to-indicator ratios or differences. It includes the
following *core functions*:

- [`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
- [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
- [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md),
  [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)  

Other *utility functions* are also included with the package. Visit the
[Reference](https://StatCan.github.io/gensol-gseries/en/reference/index.md)
page (top bar) for the complete list of available functions.

## Installation

Release version from CRAN:

``` r
install.packages("gseries")
```

Development version from GitHub:

``` r
install.packages("remotes")
remotes::install_github("StatCan/gensol-gseries")
```

A specific release version from GitHub:

``` r
install.packages("remotes")
remotes::install_github("StatCan/gensol-gseries@<release-tag>")
```

where *\<release-tag\>* refers to values listed under the GitHub project
[Tags](https://github.com/StatCan/gensol-gseries/tags) (\geq *v3.0.0*).

#### *Alternative*

The package can also be installed from the downloaded source files. This
approach requires the prior installation of the packages on which
gseries depends (because of `repos = NULL` in the
[`install.packages()`](https://rdrr.io/r/utils/install.packages.html)
call).

1.  Access the relevant GitHub
    [repository](https://github.com/StatCan/gensol-gseries) (*main*
    branch or tag \geq *v3.0.0*)
2.  Download the repository files (*Code* \> *Download ZIP*)
3.  Decompress the downloaded repository files
4.  Install the gseries package (and its dependent packages):

``` r
install.packages(
  c("ggplot2", "ggtext", "gridExtra", "lifecycle", "osqp", "rlang", "xmpdf")
)
install.packages(
  "<name & path of the decompressed downloaded repository files>",
  repos = NULL, type = "source"
)
```

#### *Vignettes*

Installing gseries from CRAN (`install.packages("gseries")`)
automatically builds and installs the package vignettes. However, this
is not the case by default when installing a package from GitHub (with
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html))
or from its downloaded source files (with
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

When installing **from GitHub**, specify arguments
`build_vignettes = TRUE` and `dependencies = TRUE` to also install the
*suggested* G-Series dependencies (packages necessary to build the
vignettes that are not installed by default by
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)):

``` r
install.packages("remotes")
remotes::install_github(
  "StatCan/gensol-gseries", 
  build_vignettes = TRUE, dependencies = TRUE
)
```

When installing **from the downloaded source files**, build the *bundle
package* first with
[`devtools::build()`](https://devtools.r-lib.org/reference/build.html):

``` r
install.packages(
  c("devtools", "ggplot2", "ggtext", "gridExtra", "osqp", "xmpdf")
)
devtools::build(
  "<name & path of the decompressed downloaded repository files>"
) |> 
  install.packages(repos = NULL, type = "source")
```

Note: packages knitr, lifecycle, rlang and rmarkdown are automatically
installed with devtools.

## Documentation

The bilingual (French-English) gseries package documentation available
in this website is also accessible from within R. Although R only
displays the English version of the gseries documentation, links to the
equivalent French pages on this website are provided at the beginning of
relevant gseries help pages in R.
[`help("gseries")`](https://StatCan.github.io/gensol-gseries/en/reference/gseries-package.md)
in R displays general package information including a link (the URL) to
this website. Clicking the **Index** link at the bottom of the gseries
package help page in RStudio (or with
[`help(package = "gseries")`](https://StatCan.github.io/gensol-gseries/en/reference))
displays a list of all the documentation elements available for the
package, including:

- topic/function help pages (top bar’s
  [Reference](https://StatCan.github.io/gensol-gseries/en/reference/index.md)
  page);
- vignettes, when installed (top bar’s ***Articles*** drop-down menu);
- package news
  ([Changelog](https://StatCan.github.io/gensol-gseries/en/news/index.md)
  page under the top bar’s ***News*** drop-down menu).

The individual function help pages found in the
[Reference](https://StatCan.github.io/gensol-gseries/en/reference/index.md)
page (top bar) can be accessed directly in R with
`help("<function-name>")`. They contain comprehensive information about
each function including useful examples and will be you primary source
of information. The vignettes found under the ***Articles*** drop-down
menu (top bar) are a complementary source of information that, when
installed with the package, can also be accessed from within R with
`browseVignettes("gseries")` or `vignette("<vignette-name>")`. They
include:

- a *Benchmarking Cookbook*
  ([`vignette("benchmarking-cookbook")`](https://StatCan.github.io/gensol-gseries/en/articles/benchmarking-cookbook.md))
  going through the steps of a typical benchmarking project;
- *A Beginner’s Benchmarking Demo Script*
  ([`vignette("benchmarking-demo-script")`](https://StatCan.github.io/gensol-gseries/en/articles/benchmarking-demo-script.md))
  illustrating the usage of the benchmarking functions in a practical
  context;
- a *OSQP Settings Sequence Data Frame* page
  ([`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/en/articles/osqp-settings-sequence-dataframe.md))
  describing the *solving sequence* implemented in
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  and explaining how it can be customized.

Finally, the [Get
started](https://StatCan.github.io/gensol-gseries/en/articles/gseries.md)
page (top bar) provides general information about G‑Series and is
available as a vignette in R
([`vignette("gseries")`](https://StatCan.github.io/gensol-gseries/en/articles/gseries.md)).

#### *Local copy of the package website*

The `docs/` folder of the GitHub
[repository](https://github.com/StatCan/gensol-gseries) (*main* branch
or tag \geq *v3.0.0*) contains the package website files and can
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
    branch or tag \geq *v3.0.0*).
2.  Copy the folder URL (address bar) in the [Download GitHub
    directory](https://download-directory.github.io/) tool’s text field
    and press Enter.
3.  Decompress the downloaded directory.
4.  Open file `en/index.html` in a web browser.

Note: the *Search for* box (top bar) is not functional in local copies
of the package website.

#### *PDF format*

Bilingual (French-English) G‑Series documentation in PDF format, also
useful for offline consultation or for a specific version of G‑Series,
is available in the `pdf/` folder of the GitHub
[repository](https://github.com/StatCan/gensol-gseries) (*main* branch
or tag \geq *v3.0.0* for the R versions and tag \leq *v2.0* for the
SAS^(®) versions). Again, GitHub tool [Download GitHub
directory](https://download-directory.github.io/) can be used to
download the contents of the `pdf/` folder instead of the entire
repository. Decompressing the downloaded directory will then unveil the
individual PDF files.
