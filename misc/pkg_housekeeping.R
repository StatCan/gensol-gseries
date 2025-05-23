# Called all the time during development:
devtools::load_all(".")
devtools::load_all("fr")
devtools::document(".")  # loads the package (like `devtools::load_all(".")`)
devtools::document("fr")  # loads the French package (like `devtools::load_all("fr")`)
lintr::lint_package()
devtools::test(".")

devtools::test_coverage(".")  # displays the HTML coverage report (same as `covr::report()`; see below)
                              # !!! restart R before running !!! 
covr::report()  # runs `covr::package_coverage()` first and then displays the HTML report
                # !!! restart R before running !!!
cov <- covr::package_coverage(".")  # creates a 'covr' object
                                    # !!! restart R before running !!!
covr::percent_coverage(cov)  # returns the (overall) package coverage
cov_report_file <- covr::report(cov)  # displays the HTML report

devtools::check(".")
devtools::build_rmd("misc/README.Rmd")
devtools::build_rmd("misc/Release_Checklist.Rmd")
devtools::build_rmd("G-Series_in_R_roadmap.Rmd")

# Wait for the GitHub repo to be public
urlchecker::url_check(".")
urlchecker::url_check("fr")
urlchecker::url_update(".")
urlchecker::url_update("fr")

usethis::use_cran_comments()

# Copy relevant MD files to the French folder
file.copy(c("CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "SECURITY.md", "LICENSE.md"), "fr", overwrite = TRUE)

#devtools::build_readme()
devtools::build_rmd("README.Rmd")
devtools::build_rmd("index.Rmd")
devtools::build_rmd("fr/index.Rmd")
devtools::build_rmd("index_StatCan.Rmd")

# IMPORTANT: manual modifications of RD files before creating the pkgdown website and building/installing the package
#
# 1) osqp_settings_sequence.Rd: remove both sentences starting with "An object of class [...]"
#    => English (./man/<topic>.Rd)
#    => French (.fr//man/<topic>.Rd)
# 
# 2) tsraking_driver.Rd: manually replace sentence
#        "Arguments passed on to"
#      with
#         "Arguments transmis à"
#    => French (.fr//man/<topic>.Rd)
#
#
# *** Now automated in the following `update_Rd_files()` function ***

source("misc/update_files.R"); update_Rd_files()


# Field "Created" in the DESCRIPTION file (to be manually copied):
t <- Sys.time(); cat(paste0(format(t, "%B %d, %Y,"), " at ", format(t, "%X %Z")))
file.copy("DESCRIPTION", "fr", overwrite = TRUE)

devtools::build(".")
#devtools::install(".")
devtools::install(".", build_vignettes = TRUE)


# MD files to (temporarily) move to folder `misc` and prevent generating an HTML page by pkgdown
md_list <- c("G-Series_in_R_roadmap.md", "index_StatCan.md"); md_list2 <- paste0("misc/", md_list)
#pkgdown::fig_settings()  # display the figure settings (for the `override_list` below)
override_list <- list(figures = list(fig.width = 11, fig.height = 8.5))

pkgdown::clean_site(".", force = TRUE)  # delete the website files (to rebuild from a clean slate)
pkgdown::clean_cache(".")  # use in case of issues with `pkgdown::build_site(".")`
file.copy(md_list, "misc"); unlink(md_list); pkgdown::build_site("."); file.copy(md_list2, "."); unlink(md_list2); pkgdown::build_reference(".", topics = "bench_graphs", override = override_list)
#pkgdown::build_home_index("."); pkgdown::init_site("."); pkgdown::preview_site(".")  # quick preview

setwd("fr"); pkgdown::clean_site(".", force = TRUE); setwd("..")
setwd("fr"); pkgdown::clean_cache("."); setwd("..")
setwd("fr"); pkgdown::build_site("."); pkgdown::build_reference(".", topics = "bench_graphs", override = override_list); setwd("..")

# Load ggplot2 and recreate the `plot_graphTable()` HTML reference pages (to avoid a potential warning in the 
# HTML examples regarding the R version ggplot2 was built with)
library(ggplot2); pkgdown::build_reference(".", topics = "plot_graphTable")
library(ggplot2); setwd("fr"); pkgdown::build_reference(".", topics = "plot_graphTable"); setwd("..")

# Manual modifications of HTML files:
#
# 1) French reference page title (file ".\docs\fr\reference\index.html"):
#    - Replace "du paquetage" by "de la librairie"
#      (Search > Replace... in Notepad++)
#
# 2) French and English reference pages that use a temporary location for the PDf file 
#    generated with `plot_graphTable()` (on Windows ONLY!):
#    - Replace the env. var. "TEMP" path (e.g.. "C:\Users\ferlmic\AppData\Local\Temp") with "%TEMP%"
#      (Search > Replace... in Notepad++)
#    - Topics (/reference pages) where this must be done:
#      "docs/en/reference/benchmarking.html"
#      "docs/fr/reference/benchmarking.html"
#      "docs/en/reference/plot_graphTable.html"
#      "docs/fr/reference/plot_graphTable.html"
#      "docs/en/reference/stock_benchmarking.html"
#      "docs/fr/reference/stock_benchmarking.html"
#    => This is done on Windows only (`.Platform$OS.type == "windows"`). Unix-like environments use 
#       "/tmp" as the default temporary files directory, which is not "sensitive" as opposed to Windows 
#       (env. var "TEMP" defaults to "C:\Users\<username>\AppData\Local\Temp" on Windows)
#
# *** Now automated in the following `update_html_files()` function ***

source("misc/update_files.R"); update_html_files()


# Package PDF doc builder (both approaches generate identical PDF files)
#
# R command (in a RStudio Terminal):
#   => user-specified PDF file name and location
#   => doc: R CMD Rd2pdf --help
#   => env. var. R_PAPERSIZE must be first be changed in the Terminal (A4 paper size by default)
#   => use option --no-description to remove the package DERSCRIPTION file info form the generated PDF
#      (may not be allowed for documentation of CRAN packages)
#set R_PAPERSIZE=letter && R CMD Rd2pdf "." -o "pdf/en/gseries.pdf" --force
#set R_PAPERSIZE=letter && R CMD Rd2pdf "." -o "pdf/en/gseries.pdf" --force --no-description
#set R_PAPERSIZE=letter && R CMD Rd2pdf "fr" -o "pdf/fr/gseries-fr.pdf" --force
#set R_PAPERSIZE=letter && R CMD Rd2pdf "fr" -o "pdf/fr/gseries-fr.pdf" --force --no-description
#
# R function (in the RStudio console):
#   => user-specified PDF file location but fixed name: "gseries_[version].pdf")
#   => doc: help("build_manual")
#   => generates A4 paper size PDF documents (there might be a way to specify "letter" paper size instead)
#devtools::build_manual(path = "pdf")
#
# Use the R CMD Rd2pdf approach:
#  - more flexible (more available options)
#  - easy to generate letter paper size PDF documents (instead of A4)

# R CMD check from the command line (e.g., in the RStudio terminal)
#R CMD build "." && R CMD check --no-stop-on-test-error "gseries_3.0.0.tar.gz" && rm "gseries_3.0.0.tar.gz"


# Called once per package
install.packages("devtools")
install.packages("readr")  # for "misc/update_files.R"
install.packages("covr")
install.packages("lintr")
install.packages("lifecycle")
usethis::use_lifecycle()
setwd("fr"); usethis::use_lifecycle(); setwd("..")
#install.packages("mathjaxr")
usethis::use_mit_license()
usethis::use_lgpl_license()
usethis::use_gpl_license()
setwd("fr"); usethis::use_mit_license(); setwd("..")
setwd("fr"); usethis::use_lgpl_license(); setwd("..")
setwd("fr"); usethis::use_gpl_license(); setwd("..")
usethis::use_testthat(3)
usethis::use_readme_rmd()
usethis::use_news_md()
usethis::use_pkgdown()
usethis::use_roxygen_md()
# usethis::use_gitlab_ci()
# usethis::use_github_action()
usethis::use_data_raw("osqp_settings_sequence")
lintr::use_lintr()
usethis::use_build_ignore(".lintr")
# Git ignores
usethis::use_git_ignore(".pdf", directory = "tests/testthat/")
usethis::use_git_ignore("..Rcheck")
usethis::use_git_ignore("gseries.Rcheck")

# Vignettes (initial creation)
usethis::use_vignette("benchmarking-cookbook")
usethis::use_vignette("benchmarking-demo-script")
usethis::use_vignette("gseries")
usethis::use_vignette("osqp-settings-sequence-dataframe")

# Non-vignette Articles (pkgdown website only)
#usethis::use_article("benchmarking-demo-script")

# Exclusions from the built/installed package
usethis::use_build_ignore("..Rcheck")
usethis::use_build_ignore("gseries.Rcheck")
usethis::use_build_ignore("misc")
usethis::use_build_ignore("tests")
usethis::use_build_ignore(".gitlab-ci.yml")
usethis::use_build_ignore("inst/pkgdown.yml")
usethis::use_build_ignore("docs")
usethis::use_build_ignore("pdf")
usethis::use_build_ignore("index.Rmd")
usethis::use_build_ignore("index.md")
usethis::use_build_ignore("index_StatCan.Rmd")
usethis::use_build_ignore("index_StatCan.md")
usethis::use_build_ignore("fr")
usethis::use_build_ignore("G-Series_in_R_roadmap.md")
usethis::use_build_ignore("G-Series_in_R_roadmap.Rmd")
usethis::use_build_ignore("CODE_OF_CONDUCT.md")
usethis::use_build_ignore("CONTRIBUTING.md")
usethis::use_build_ignore("SECURITY.md")
usethis::use_build_ignore(".github")
usethis::use_build_ignore("github_cleaning.cmd")

# Dependencies:
usethis::use_package("stats")
usethis::use_package("utils")
usethis::use_package("graphics")
usethis::use_package("grDevices")
usethis::use_package("rlang", min_version = "1.1.0")
usethis::use_package("ggplot2")
usethis::use_package("ggtext")
usethis::use_package("gridExtra")
usethis::use_package("mathjaxr")
usethis::use_package("httr2")
usethis::use_package("osqp")
usethis::use_package("Matrix")
usethis::use_package("xmpdf")

# Functions:
usethis::use_r("aaa_utils-bench")
usethis::use_test("aaa_utils-bench")
usethis::use_r("benchmarking")
usethis::use_test("benchmarking")
usethis::use_r("data")
usethis::use_r("plot_benchAdj")
usethis::use_test("plot_benchAdj")
usethis::use_r("plot_graphTable")
usethis::use_test("plot_graphTable")
usethis::use_r("rkMeta_to_blSpecs")
usethis::use_test("rkMeta_to_blSpecs")
usethis::use_r("stack_bmkDF")
usethis::use_test("stack_bmkDF")
usethis::use_r("stack_tsDF")
usethis::use_test("stack_tsDF")
usethis::use_r("stock_benchmarking")
usethis::use_test("stock_benchmarking")
usethis::use_r("ts_to_bmkDF")
usethis::use_test("ts_to_bmkDF")
usethis::use_r("ts_to_tsDF")
usethis::use_test("ts_to_tsDF")
usethis::use_r("tsbalancing")
usethis::use_test("tsbalancing")
usethis::use_r("tsDF_to_ts")
usethis::use_test("tsDF_to_ts")
usethis::use_r("tsraking")
usethis::use_test("tsraking")
usethis::use_r("tsraking_driver")
usethis::use_test("tsraking_driver")
usethis::use_r("unstack_tsDF")
usethis::use_test("unstack_tsDF")
usethis::use_r("utils-common")
usethis::use_test("utils-common")
usethis::use_r("aliases")
#usethis::use_r("utils-onAttach")


topic <- "gseries-package"
topic <- "aliases"
topic <- "alternate_osqp_sequence"
topic <- "bench_graphs"
topic <- "benchmarking"
topic <- "build_balancing_problem"
topic <- "build_raking_problem"
topic <- "default_osqp_sequence"
topic <- "gs.gInv_MP"
topic <- "gs.build_proc_grps"
topic <- "osqp_settings_sequence"
topic <- "plot_benchAdj"
topic <- "plot_graphTable"
topic <- "rkMeta_to_blSpecs"
topic <- "stack_bmkDF"
topic <- "stack_tsDF"
topic <- "stock_benchmarking"
topic <- "time_values_conv"
topic <- "ts_to_bmkDF"
topic <- "ts_to_tsDF"
topic <- "tsbalancing"
topic <- "tsDF_to_ts"
topic <- "tsraking"
topic <- "tsraking_driver"
topic <- "unstack_tsDF"

# Run an example
pkgload::dev_example(topic)

# View the RD file in RStudio
# => note that mathjaxr equations (if applicable) may NOT render correctly this way
#pkgload::dev_topic_index(".")  # list available topics
pkgload::dev_help(topic)

# Update the pkgdown HTML reference page
pkgdown::build_reference(".", topics = topic)
setwd("fr"); pkgdown::build_reference(".", topics = topic); setwd("..")
#pkgdown::build_reference_index(".")
#setwd("fr"); pkgdown::build_reference_index("."); setwd("..")


# "bench_graphs" HTML reference page => override list for the figures
override_list <- list(figures = list(fig.width = 11, fig.height = 8.5))
pkgdown::build_reference(".", topics = "bench_graphs", override = override_list)
setwd("fr"); pkgdown::build_reference(".", topics = "bench_graphs", override = override_list); setwd("..")

# Update the pkgdown vignette (articles) page
vignette <- "benchmarking-cookbook"
vignette <- "benchmarking-demo-script"
vignette <- "gseries"
vignette <- "osqp-settings-sequence-dataframe"
pkgdown::build_article(vignette, pkg = ".")
setwd("fr"); pkgdown::build_article(vignette, pkg = "."); setwd("..")

# Update the pkgdown home page
# home page only
pkgdown::build_home_index(pkg = ".")
setwd("fr"); pkgdown::build_home_index(pkg = "."); setwd("..")
# home page + "all other" MD files
file.copy(md_list, "misc"); unlink(md_list); pkgdown::build_home("."); file.copy(md_list2, "."); unlink(md_list2)
setwd("fr"); pkgdown::build_home(pkg = "."); setwd("..")

# Update the pkgdown home page
pkgdown::build_news(pkg = ".")
setwd("fr"); pkgdown::build_news(pkg = "."); setwd("..")


# Update reference pages that use `plot_graphTable`
pkgdown::build_reference(".", topics = "benchmarking")
setwd("fr"); pkgdown::build_reference(".", topics = "benchmarking"); setwd("..")
library(ggplot2); pkgdown::build_reference(".", topics = "plot_graphTable")
library(ggplot2); setwd("fr"); pkgdown::build_reference(".", topics = "plot_graphTable"); setwd("..")
pkgdown::build_reference(".", topics = "stock_benchmarking")
setwd("fr"); pkgdown::build_reference(".", topics = "stock_benchmarking"); setwd("..")
