# IMPORTANT: These functions require package readr (they assume that readr is installed)

# "Core" function used inside all the following `update_*()` functions
#
# Apply `gsub()` to the specified file. Notes:
# - The file will be rewritten => MAKE SURE YOU MAKE A BACKUP FIRST
# - The `...` args are passed on to `gsub()`
# - An end-of-line character should be ...
#     - matched with"\\r?\\n" in argument `pattern`
#     - generated with "\n" in argument `replacement`.
#   This should work on both Windows and Linux/Unix
my_gsub_file <- function(pattern, replacement, file, ...) {
  readr::write_file(gsub(pattern, replacement, readr::read_file(file), ...), file)
}


# Updates to Rd files
update_Rd_files <- function() {

  # 1- French and English "osqp_settings_sequence.Rd" file:
  #      Remove the irrelevant "An object of class `data.frame` ..." lines
  pattern <- paste0("\\}\\r?\\n",
                    "\\r?\\n",
                    "An object of class \\\\code\\{data.frame\\} with [[:digit:]]+ rows and [[:digit:]]+ columns\\.\\r?\\n",
                    "\\r?\\n",
                    "An object of class \\\\code\\{data.frame\\} with [[:digit:]]+ rows and [[:digit:]]+ columns\\.\\r?\\n",
                    "\\}\\r?\\n")
  replacement <- paste0("\\}\n",
                        "\\}\n")
  my_gsub_file(pattern, replacement, "man/osqp_settings_sequence.Rd")
  my_gsub_file(pattern, replacement, "fr/man/osqp_settings_sequence.Rd")
  
  
  # 2- French "tsraking_driver.Rd" file:
  #      Replace 
  #        "Arguments passed on to"
  #      with
  #        "Arguments transmis à"
  my_gsub_file("Arguments passed on to", 
               "Arguments transmis à", 
               "fr/man/tsraking_driver.Rd")
}


# Updates to html files
update_html_files <- function() {

  # 1- French reference page title ("docs/fr/reference/index.html"):
  #      Replace 
  #        "du paquetage"
  #      with
  #        "de la librairie"
  my_gsub_file("du paquetage", 
               "de la librairie", 
               "docs/fr/reference/index.html")
  
  
  # 2- French and English reference pages that use a temporary location for the PDf file 
  #    generated with `plot_graphTable()`:
  #      Replace 
  #        the content of environment variable "TEMP" (path to the directory where temporary files should be stored)
  #      with
  #        "%TEMP%"
  #      using `gsub()` argument
  #        `fixed = TRUE`
  #
  #    => On Windows only: Unix-like environments use "/tmp" as the default temporary files directory, 
  #                        which is not "sensitive" as opposed to Windows (env. var "TEMP" defaults to 
  #                        "C:\Users\<username>\AppData\Local\Temp" on Windows)
  if (.Platform$OS.type == "windows") {
    pattern <- normalizePath(Sys.getenv("TEMP"))
    replacement <- "%TEMP%"
    my_gsub_file(pattern, replacement, "docs/en/reference/benchmarking.html", fixed = TRUE)
    my_gsub_file(pattern, replacement, "docs/fr/reference/benchmarking.html", fixed = TRUE)
    my_gsub_file(pattern, replacement, "docs/en/reference/plot_graphTable.html", fixed = TRUE)
    my_gsub_file(pattern, replacement, "docs/fr/reference/plot_graphTable.html", fixed = TRUE)
    my_gsub_file(pattern, replacement, "docs/en/reference/stock_benchmarking.html", fixed = TRUE)
    my_gsub_file(pattern, replacement, "docs/fr/reference/stock_benchmarking.html", fixed = TRUE)
  }
}


# Updates to the pkgdown website URL
update_pkgdown_url <- function(pattern, replacement, list_files = FALSE) {
  
  file_list <- c(

    # `DESCRIPTION` files
    "DESCRIPTION", "fr/DESCRIPTION", 

    # `_pkgdown.yml` files
    "_pkgdown.yml", "fr/_pkgdown.yml", 
    
    # `README` files
    "README.Rmd", "README.md",

    # English `NEWS.md` file, R scripts and vignettes (Rmd files): link to the French HTML page
    "NEWS.md",
    list.files("R", pattern = ".R$", full.names = TRUE),
    list.files("vignettes", pattern = ".Rmd$", full.names = TRUE)
  )
  
  for (ii in seq_along(file_list)) {

    if (list_files) {
      message(normalizePath(utils::fileSnapshot(file_list[ii])$path))
    }
    my_gsub_file(pattern, replacement, file_list[ii])
  }
}
