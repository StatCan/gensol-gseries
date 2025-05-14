#' Fonction réciproque de [stack_tsDF()]
#'
#'
#' @description
#' Convertir un *data frame* empilé (long) de séries chronologiques multivariées (format de données de [benchmarking()] et 
#' [stock_benchmarking()]) en un *data frame* non empilé (large) de séries chronologiques multivariées.
#'
#' Cette fonction, combinée avec [tsDF_to_ts()], est utile pour convertir le *data frame* renvoyé par un appel à 
#' [benchmarking()] ou [stock_benchmarking()] en un objet « mts », où plusieurs séries ont été étalonnées en mode de 
#' traitement *groupes-BY*.
#'
#'
#' @param ts_df (obligatoire)
#'
#' *Data frame*, ou objet compatible, contenant les données de séries chronologiques multivariées à *désempiler*.
#'
#' @param ser_cName (optionnel)
#'
#' Chaîne de caractères spécifiant le nom de la variable (colonne) dans le *data frame* d'entrée qui contient le nom des 
#' séries chronologiques (nom des variables des séries chronologiques dans le *data frame* de sortie). 
#'
#' **La valeur par défaut** est `ser_cName = "series"`.
#'
#' @param yr_cName,per_cName (optionnel)
#'
#' Chaînes de caractères spécifiant le nom des variables (colonnes) numériques dans le *data frame* d'entrée qui identifient 
#' l'année et la période des points de données. Ces variables sont *transférées* dans le *data frame* de sortie avec les mêmes 
#' noms de variable.
#'
#' **Les valeurs par défaut** sont `yr_cName = "year"` et `per_cName = "period"`.
#'
#' @param val_cName (optionnel)
#'
#' Chaîne de caractères spécifiant le nom de la variable (colonne) numérique dans le *data frame* d'entrée qui contient  
#' la valeur des points de données.
#'
#' **La valeur par défaut** est `val_cName = "value"`.
#'
#'
#' @returns
#' La fonction renvoie un *data frame* avec trois variables ou plus :
#' * Année du point de données, type numérique (voir argument `yr_cName`)
#' * Période du point de données, type numérique (voir argument `per_cName`)
#' * Une variable de données de série chronologique pour chaque valeur distincte de la variable du _data frame_ d'entrée 
#' spécifiée avec l'argument `ser_cName`, type numérique (voir arguments `ser_cName` et `val_cName`)
#' 
#' Note : la fonction renvoie un objet « data.frame » qui peut être explicitement converti en un autre 
#' type d'objet avec la fonction `as*()` appropriée (ex., `tibble::as_tibble()` le convertirait en tibble).
#'
#'
#' @seealso [stack_tsDF()] [tsDF_to_ts()] [benchmarking()] [stock_benchmarking()]
#'
#'
#' @example misc/function_examples/unstack_tsDF-ex.R
#'
#'
#' @export
unstack_tsDF <- function(ts_df,
                         ser_cName = "series",
                         yr_cName = "year",
                         per_cName = "period",
                         val_cName = "value") {
  
  # Validate object
  if (!is.data.frame(ts_df)) {
    stop("Argument 'ts_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  ts_df <- as.data.frame(ts_df)
  df_cols <- names(ts_df)
  cols <- c(ser_cName, yr_cName, per_cName, val_cName)
  args <- c("ser_cName", "yr_cName", "per_cName", "val_cName")
  for (ii in seq_along(cols)) {
    if (!(cols[ii] %in% df_cols)) {
      stop("The input data frame does not contain column \"", cols[ii], "\" (argument '", args[ii],
           "').\n\n", call. = FALSE)
    }
  }
  
  # Unstack the data frame
  ser_list <- unique(ts_df[[ser_cName]])
  date_cols <- c(yr_cName, per_cName)
  out_df <- unique(ts_df[date_cols])
  for (ser in ser_list) {
    tmp_df <- ts_df[ts_df[ser_cName] == ser, c(date_cols, val_cName)]
    names(tmp_df)[3] <- ser
    out_df <- merge(out_df, tmp_df, by = date_cols, all = TRUE)
  }
  
  # Sort the data frame by date and reset the row names (numbers)
  out_df <- out_df[order(out_df[[yr_cName]], out_df[[per_cName]]), ]
  row.names(out_df) <- NULL
  
  out_df
}
