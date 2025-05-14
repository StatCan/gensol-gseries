#' Alias de fonction
#' @name aliases
#' 
#' @description 
#' [proc_benchmarking()] est un alias de [benchmarking()]
#' 
#' [proc_tsraking()] est un alias de [tsraking()]
#' 
#' [macro_gseriestsbalancing()] est un alias de [tsbalancing()]
#' 
#' @param ... Arguments de la fonction correspondante.
#' 
#' @details 
#' Le nom de ces alias rappelle l'origine SAS\eqn{^\circledR}{®} de la fonction correspondante 
#' (PROC BENCHMARKING, PROC TSRAKING et macro ***GSeriesTSBalancing*** dans G-Séries 2.0). Ces alias  
#' assurent également la compatibilité avec les premières versions de développement de la librairie R.
#' 
#' Voir la fonction correspondante pour des exemples ou la description des arguments et de la valeur 
#' de retour :
#' - [benchmarking()] pour l'alias [proc_benchmarking()]
#' - [tsraking()] pour l'alias [proc_tsraking()]
#' - [tsbalancing()] pour l'alias [macro_gseriestsbalancing()]

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
