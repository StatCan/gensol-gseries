#' Function aliases
#' @name aliases
#' 
#' @description
#' \if{html,text}{(\emph{version française: 
#' \url{https://StatCan.github.io/gensol-gseries/fr/reference/aliases.html}})}
#' 
#' [proc_benchmarking()] is an alias for [benchmarking()]
#' 
#' [proc_tsraking()] is an alias for [tsraking()]
#' 
#' [macro_gseriestsbalancing()] is an alias for [tsbalancing()]
#' 
#' @param ... Corresponding function arguments.
#' 
#' @details 
#' The name of these aliases is reminiscent of the corresponding function's SAS\eqn{^\circledR}{®} origin 
#' (PROC BENCHMARKING, PROC TSRAKING and macro ***GSeriesTSBalancing*** in G-Series 2.0). These aliases also 
#' ensure backward compatibility with early development versions of the R package.
#'
#' See the corresponding function for more details, including complete examples, detailed description of the 
#' arguments and the returned value.
#'
#' @returns
#' See the corresponding function:
#' - [benchmarking()] for alias [proc_benchmarking()]
#' - [tsraking()] for alias [proc_tsraking()]
#' - [tsbalancing()] for alias [macro_gseriestsbalancing()]

#' @rdname aliases
#' @export
#' @keywords internal
proc_benchmarking <- function(...) benchmarking(...)

#' @rdname aliases
#' @export
#' @keywords internal
proc_tsraking <- function(...) tsraking(...)

#' @rdname aliases
#' @export
#' @keywords internal
macro_gseriestsbalancing <- function(...) tsbalancing(...)
