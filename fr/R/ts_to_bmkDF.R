#' Convertir un objet « ts » en _data frame_ d'étalons
#'
#'
#' @description
#' Convertir un objet « ts  » (ou « mts ») en un _data frame_ d'étalons pour les fonctions d'étalonnage avec cinq variables
#' (colonnes) ou plus :
#' * quatre (4) pour la converture de l'étalon
#' * une (1) pour chaque série chronologique d'étalons
#'
#' Pour des étalons discrets (points d'ancrage couvrant une seule période de la série indicatrice, par exemple, des stocks de 
#' fin d'année), spécifiez `discrete_flag = TRUE` et `alignment = "b"`, `"e"` ou `"m"`.
#'
#'
#' @param in_ts (obligatoire)
#'
#' Objet de type série chronologique (« ts » ou « mts »), ou objet compatible, à convertir.
#'
#' @param ind_frequency (obligatoire)
#'
#' Entier spécifiant la fréquence de la série indicatrice (haute fréquence) à laquelle les étalons (séries de basse fréquence) 
#' sont liés. La fréquence d'une série chronologique correspond au nombre maximum de périodes dans une année (par exemple, 12 
#' pour des données mensuelles, 4 pour des données trimestrielles, 1 pour des données annuelles).
#'
#' @param discrete_flag (optionnel)
#'
#' Argument logique (*logical*) précisant si les étalons correspondent à des valeurs discrètes (points d'ancrage couvrant une 
#' seule période de la série indicatrice, par exemple des stocks de fin d'année) ou non. `discrete_flag = FALSE` définit des 
#' étalons non discrets, c'est-à-dire des étalons qui couvrent plusieurs périodes de la série indicatrice (par exemple, des 
#' étalons annuels couvrent 4 trimestres ou 12 mois, des étalons trimestriels couvrent 3 mois, etc.).
#'
#' **La valeur par défaut** est `discrete_flag = FALSE`.
#'
#' @param alignment (optionnel)
#'
#' Caractère identifiant l'alignement des étalons discrets (argument `discrete_flag = TRUE`) dans la fenêtre de couverture 
#' de l'intervalle de l'étalon (série de basse fréquence) :
#' * `alignment = "b"` : début de la fenêtre de l'intervalle de l'étalon (première période)
#' * `alignment = "e"` : fin de la fenêtre de l'intervalle de l'étalon (dernière période)
#' * `alignment = "m"` : milieu de la fenêtre de l'intervalle de l'étalon (période du milieu)
#'
#' Cet argument n'a pas d'effet pour les étalons non discrets (`discrete_flag = FALSE`).
#'
#' **La valeur par défaut** est `alignment = "b"`.
#'
#' @param bmk_interval_start (optionnel)
#'
#' Entier dans l'intervalle \[1 .. `ind_frequency`\] spécifiant la période (cycle) de la série indicatrice (haute fréquence) 
#' à laquelle commence la fenêtre de l'intervalle de l'étalon (série de basse fréquence). Par exemple, des étalons annuels 
#' correspondant à des années financières définies d'avril à mars de l'année suivante seraient spécifiés avec 
#' `bmk_interval_start = 4` pour une série indicatrice mensuelle (`ind_frequency = 12`) et `bmk_interval_start = 2` pour 
#' une série indicatrice trimestrielle (`ind_frequency = 4`).
#'
#' **La valeur par défaut** est `bmk_interval_start = 1`.
#'
#' @param startYr_cName,startPer_cName,endYr_cName,endPer_cName (optionnel)
#'
#' Chaînes de caractères spécifiant le nom des variables (colonnes) numériques dans le *data frame* de sortie qui 
#' définiront la couverture des étalons, c'est-à-dire les identificateurs de l'année et de la période de début et de 
#' fin des étalons.
#'
#' **Les valeurs par défaut** sont `startYr_cName = "startYear"`, `startPer_cName = "startPeriod"`
#' `endYr_cName = "endYear"` et `endPer_Name = "endPeriod"`.
#'
#' @param val_cName (optionnel)
#'
#' Chaîne de caractères spécifiant le nom de la variable (colonne) dans le *data frame* de sortie qui contiendra les 
#' valeurs des étalons. Cet argument n'a aucun effet pour les objets « mts » (les noms des variables d'étalons sont 
#' automatiquement hérités de l'objet « mts »).
#'
#' **La valeur par défaut** est `val_cName = "value"`.
#'
#'
#' @returns
#' La fonction renvoie un *data frame* avec cinq variables ou plus :
#' * Année de début de la couverture de l'étalon, type numérique (voir argument `startYr_cName`)
#' * Période de début de la couverture de l'étalon, type numérique (voir argument `startPer_cName`)
#' * Année de fin de la couverture de l'étalon, type numérique (voir argument `endYr_cName`)
#' * Période de fin de la couverture de l'étalon, type numérique (voir argument `endPer_cName`)
#' * Une (objet « ts ») ou plusieurs (objet « mts ») variable(s) de données d'étalons, type numérique 
#' (voir argument `val_cName`)
#'
#' Note : la fonction renvoie un objet « data.frame » qui peut être explicitement converti en un autre 
#' type d'objet avec la fonction `as*()` appropriée (ex., `tibble::as_tibble()` le convertirait en tibble).
#'
#'
#' @seealso [ts_to_tsDF()] [stack_bmkDF()] [benchmarking()] [stock_benchmarking()] [time_values_conv] 
#'
#'
#' @example misc/function_examples/ts_to_bmkDF-ex.R
#'
#'
#' @export
ts_to_bmkDF <- function(in_ts,
                        ind_frequency,
                        discrete_flag = FALSE,
                        alignment = "b",
                        bmk_interval_start = 1,
                        startYr_cName = "startYear",
                        startPer_cName = "startPeriod",
                        endYr_cName = "endYear",
                        endPer_cName = "endPeriod",
                        val_cName = "value") {
  
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt))
  options(error = NULL)
  
  
  # validate object
  if (!stats::is.ts(in_ts)) {
    stop("Argument 'in_ts' is not a 'ts' object.\n\n", call. = FALSE)
  }
  in_ts <- stats::as.ts(in_ts)
  
  
  # (Re)align the `in_ts` time values at the start of the benchmark interval (to ensure proper year and indicator period 
  # determination) and then shift them to reflect `bmk_interval_start`
  #
  # => Note that since the `in-ts` frequency corresponds to the benchmark series (and not the indicator series), function 
  #    `gs.time2per()` (`stats::cycle()`) cannot be used to determine the periods of the indicator series.
  #    Function 'gs.time2year()` could be used to determine the years of the indicator series, but it's not necessary since
  #    the time values are (re)aligned at the start of the intervals (simply "truncating" the time values works fine)
  #
  bmk_freq <- stats::frequency(in_ts)
  beg_time <- stats::time(stats::ts(in_ts,
                                    start = c(gs.time2year(in_ts)[1], gs.time2per(in_ts)[1]),
                                    frequency = stats::frequency(in_ts))) +
    ((bmk_interval_start - 1) %% (ind_frequency / bmk_freq)) / ind_frequency
  
  
  # Create the initial data frame with generic names for the benchmark window columns
  # (first 4 columns)
  
  # Non-discrete benchmarks (e.g. flow series benchmarking)
  if (!gs.validate_arg_logi(discrete_flag)) {
    
    end_time <- beg_time + (ind_frequency / bmk_freq - 1) / ind_frequency
    out_df <- data.frame(
      col1 = as.integer(signif(beg_time, gs.signif_digits)),
      col2 = as.integer(round((beg_time - as.integer(beg_time)) * ind_frequency)) + 1L,
      col3 = as.integer(signif(end_time, gs.signif_digits)),
      col4 = as.integer(round((end_time - as.integer(end_time)) * ind_frequency)) + 1L
    )
    
    # Discrete benchmarks (e.g. stock series benchmarking)
  } else {
    
    tmp <- toupper(substr(alignment, 1, 1))
    if (tmp == "E") {
      shift <- (ind_frequency / bmk_freq - 1) / ind_frequency
    } else if (tmp == "M") {
      # An obvious formula (based on the above one) would probably be `round((ind_frequency / bmk_freq - 1) / 2) / ind_frequency`.
      # However, `base::round()` implements 'go to the even digit' for rounding off a 5 (0.5 -> 0, 1.5 = 2.5 -> 2, etc.) while we
      # want them (half intervals) always rounded up (half years are closer to July 1st than June 1st, i.e., a shift of 6 months).
      # For example, we want...
      #   - monthly indicators with annual benchmarks     : shift = round((12 / 1 - 1) / 2) / 12 = round(5.5) / 12 = 6 / 12 = 0.5)
      #                                                     (base::round(5.5) = 6 -> all good)
      #   - monthly indicators with semi-annual benchmarks: shift = round((12 / 2 - 1) / 2) / 12 = round(2.5) / 12 = 3 / 12 = 0.25)
      #                                                     (base::round(2.5) = 2 -> not what we want!)
      # The following formula corresponds to always rounding up value `(ind_frequency / bmk_freq - 1) / 2`
      shift <- as.integer(ind_frequency / bmk_freq / 2) / ind_frequency
    } else {
      shift <- 0
    }
    time <- beg_time + shift
    yr <- as.integer(signif(time, gs.signif_digits))
    per <- as.integer(round((time - as.integer(time)) * ind_frequency)) + 1L
    out_df <- data.frame(
      col1 = yr,
      col2 = per,
      col3 = yr,
      col4 = per
    )
  }
  
  # Set the date column names
  names(out_df) <- c(startYr_cName, startPer_cName, endYr_cName, endPer_cName)
  
  
  # Multivariate series data columns for a mts object
  if (stats::is.mts(in_ts)) {
    out_df <- cbind(out_df, in_ts)
    
    # Single series data column for a ts object
  } else {
    temp_df <- data.frame(col1 = as.numeric(in_ts))
    names(temp_df) <- val_cName[1]
    out_df <- cbind(out_df, temp_df)
  }
  
  # Reset the now names (numbers)
  row.names(out_df) <- NULL
  
  out_df
}
