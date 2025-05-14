#' Convertir un objet « ts » en _data frame_ de séries chronologiques
#'
#'
#' @description
#' Convertir un objet « ts  » (ou « mts ») en un _data frame_ de séries chronologiques pour les fonctions d'étalonnage avec 
#' trois variables (colonnes) ou plus :
#' - deux (2) pour l'identification du point de données (année et période)
#' - une (1) pour chaque série chronologique
#'
#' Pour des étalons discrets (points d'ancrage couvrant une seule période de la série indicatrice, par exemple, des stocks de 
#' fin d'année), spécifiez `discrete_flag = TRUE` et `alignment = "b"`, `"e"` ou `"m"`.
#'
#'
#' @usage
#' ts_to_tsDF(
#'   in_ts,
#'   yr_cName = "year",
#'   per_cName = "period",
#'   val_cName = "value"
#' )
#'
#'
#' @param in_ts (obligatoire)
#'
#' Objet de type série chronologique (« ts » ou « mts »), ou objet compatible, à convertir.
#'
#' @param yr_cName,per_cName (optionnel)
#'
#' Chaînes de caractères spécifiant le nom des variables (colonnes) numériques dans le *data frame* de sortie 
#' qui contiendront les identificateurs d'année et de période du point de données.
#'
#' **Les valeurs par défaut** sont `yr_cName = "year"` et `per_cName = "period"`.
#'
#' @param val_cName (optionnel)
#'
#' Chaîne de caractères spécifiant le nom de la variable (colonne) dans le *data frame* de sortie qui contiendra les 
#' valeurs des points de données. Cet argument n'a aucun effet pour les objets « mts » (les noms des variables de 
#' données des séries chronologiques sont automatiquement hérités de l'objet « mts »).
#'
#' **La valeur par défaut** est `val_cName = "value"`.
#'
#'
#' @returns
#' La fonction renvoie un *data frame* avec trois variables ou plus :
#' * Année du point de données, type numérique (voir argument `yr_cName`)
#' * Période du point de données, type numérique (voir argument `per_cName`)
#' * Valeur du point de données, type numérique (voir argument `val_cName`)
#' * Une (objet « ts ») ou plusieurs (objet « mts ») variable(s) de données de série(s) chronologique(s), type numérique 
#' (voir argument `val_cName`)
#'
#' Note : la fonction renvoie un objet « data.frame » qui peut être explicitement converti en un autre 
#' type d'objet avec la fonction `as*()` appropriée (ex., `tibble::as_tibble()` le convertirait en tibble).
#'
#'
#' @seealso [tsDF_to_ts()] [ts_to_bmkDF()] [stack_tsDF()] [benchmarking()] [stock_benchmarking()] [time_values_conv]
#'
#'
#' @example misc/function_examples/ts_to_tsDF-ex.R
#'
#'
#' @export
ts_to_tsDF <- function(in_ts,
                       yr_cName = "year",
                       per_cName = "period",
                       val_cName = "value") {
  
  
  # validate object
  if (!stats::is.ts(in_ts)) {
    stop("Argument 'in_ts' is not a 'ts' object.\n\n", call. = FALSE)
  }
  in_ts <- stats::as.ts(in_ts)
  
  if (stats::is.mts(in_ts)) {
    
    # Create the initial data frame with only the date columns (first 2 columns)
    out_df <- data.frame(
      col1 = gs.time2year(in_ts),
      col2 = gs.time2per(in_ts)
    )
    
    # Set date the column names
    names(out_df) <- cbind(yr_cName, per_cName)
    
    # Add the series data
    out_df <- cbind(out_df, in_ts)
    
  } else {
    
    # Create the initial data frame with generic column names
    out_df <- data.frame(
      col1 = gs.time2year(in_ts),
      col2 = gs.time2per(in_ts),
      col3 = as.numeric(in_ts)
    )
    
    # Set the column names
    names(out_df) <- c(yr_cName, per_cName, val_cName)
  }
  
  # Reset the now names (numbers)
  row.names(out_df) <- NULL
  
  out_df
}
