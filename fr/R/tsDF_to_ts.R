#' Fonction réciproque de [ts_to_tsDF()]
#'
#'
#' @description
#' Convertir un *data frame* (non empilé) de séries chronologiques (format de données de [benchmarking()] et [stock_benchmarking()])
#' en un objet « ts » (ou « mts »).
#'
#' Cette fonction est utile pour convertir le *data frame* renvoyé par un appel à [benchmarking()] ou [stock_benchmarking()] 
#' en un objet « ts », où une ou plusieurs séries ont été étalonnées en mode de traitement *non groupes-BY*. Les 
#'  *data frame* empilés de séries chronologiques associées à des exécutions en mode *groupes-BY* doivent d'abord être 
#'  *désempilés* avec [unstack_tsDF()].
#'
#'
#' @usage
#' tsDF_to_ts(
#'   ts_df,
#'   frequency,
#'   yr_cName = "year",
#'   per_cName = "period"
#' )
#'
#'
#' @param ts_df (obligatoire)
#'
#' *Data frame*, ou objet compatible, à convertir.
#'
#' @param frequency (obligatoire)
#' 
#' Entier spécifiant la fréquence de la (des) série(s) à convertir. La fréquence d'une série chronologique correspond 
#' au nombre maximum de périodes dans une année (par exemple, 12 pour des données mensuelles, 4 pour des données trimestrielles, 
#' 1 pour des données annuelles).
#'
#' @param yr_cName,per_cName (optionnel)
#'
#' Chaînes de caractères spécifiant le nom des variables (colonnes) numériques dans le *data frame* d'entrée 
#' qui contiennent les identificateurs d'année et de période du point de données.
#'
#' **Les valeurs par défaut** sont `yr_cName = "year"` et `per_cName = "period"`.
#'
#'
#' @returns
#' La fonction renvoie un objet de type série chronologique (« ts » ou « mts »), qui peut être explicitement converti 
#' en un autre type d'objet avec la fonction `as*()` appropriée (ex., `tsibble::as_tsibble()` le convertirait en tsibble).
#'
#'
#' @seealso [ts_to_tsDF()] [unstack_tsDF()] [benchmarking()] [stock_benchmarking()]
#'
#'
#' @example misc/function_examples/tsDF_to_ts-ex.R
#' 
#' 
#' @export
tsDF_to_ts <- function(ts_df,
                       frequency,
                       yr_cName = "year",
                       per_cName = "period") {
  
  # validate object
  if (!is.data.frame(ts_df)) {
    stop("Argument 'ts_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  if (nrow(ts_df) == 0) {
    stop("The input data frame must contain at leat one observation (row).\n\n", call. = FALSE)
  }  
  df_cols <- names(ts_df)
  date_cols <- c(yr_cName, per_cName)
  date_args <- c("yr_cName", "per_cName")
  for (ii in seq_along(date_cols)) {
    if (!(date_cols[ii] %in% df_cols)) {
      stop("The input data frame does not contain column \"", date_cols[ii], "\" (argument '",
           date_args[ii], "').\n\n", call. = FALSE)
    }
  }
  
  # Sort the data frame by date (safety measure)
  sorted_df <- ts_df[order(ts_df[[yr_cName]], ts_df[[per_cName]]), ]
  
  # Extract the numeric columns (excluding the year and period id columns)
  if (length(df_cols) > 2) {
    tmp_df <- sorted_df[setdiff(df_cols, date_cols)]
    # `sapply()` is safe: it always returns a logical vector of length minimum 1
    series_obj <- tmp_df[sapply(tmp_df, is.numeric)]
    nTS <- ncol(series_obj)
  } else {
    nTS <- 0
  }
  if (nTS == 0) {
    stop("The input data frame must contain at leat one (numeric) time series.\n\n", call. = FALSE)
  } else if (nTS == 1) {
    # Univariate ts object: transform the data frame into a vector
    series_obj <- series_obj[[1]]
  }
  
  # Create the ts object
  stats::ts(series_obj,
            start = as.integer(c(sorted_df[1, yr_cName], sorted_df[1, per_cName])),
            frequency = as.integer(frequency))
}
