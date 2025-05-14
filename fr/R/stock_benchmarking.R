#' Rétablir les contraintes temporelles pour des séries de stocks
#'
#'
#' @description
#' Fonction spécifiquement destinée à l'étalonnage des séries de stocks où les étalons sont des points d'ancrage couvrant 
#' une seule période de la série indicatrice. Les étalons couvrant plus d'une période de la série indicatrice ne peuvent pas 
#' être utilisés avec cette fonction. La fonction [benchmarking()] doit être utilisée à la place pour étalonner des séries de 
#' flux (« non-stock »).
#'
#' Plusieurs séries de stocks peuvent être étalonnées en un seul appel de fonction.
#'
#' Notez que les fonctions [stock_benchmarking()] et [benchmarking()] partagent principalement les mêmes arguments et renvoient 
#' le même type d'objet. Les différences sont énumérées ci-dessous :
#' * L'argument `verbose` n'est pas défini pour [stock_benchmarking()].
#' * Des arguments supplémentaires sont définis pour [stock_benchmarking()] :
#'   * `low_freq_periodicity`
#'   * `n_low_freq_proj`
#'   * `proj_knots_rho_bd`
#' * La liste renvoyée par [stock_benchmarking()] contient un _data frame_ supplémentaire :
#'   * `splineKnots`
#'
#' Voir la section **Détails** pour plus d'informations sur les similitudes et les différences entre les fonctions
#' [stock_benchmarking()] et [benchmarking()].
#'
#' *Un équivalent direct de [stock_benchmarking()] n'existe pas dans G-Séries 2.0 en SAS\eqn{^\circledR}{®}.*
#'
#'
#' @inheritParams benchmarking
#'
#' @param low_freq_periodicity (optionnel)
#'
#' Nombre entier positif représentant le nombre de périodes définissant la *basse fréquence* (e.g., celle des étalons) pour 
#' l'ajout de nœuds supplémentaires à la spline cubique (avant le premier étalon et après le dernier étalon). Par exemple, 
#' \ifelse{latex}{\code{low_freq _periodicity = 3}}{\code{low_freq_periodicity = 3}} avec des indicateurs mensuels 
#' définira des nœuds trimestriels. Des nœuds annuels sont ajoutés lorsque `low_freq_periodicity = NA`.
#'
#' **La valeur par défaut** est `low_freq_periodicity = NA` (nœuds annuels).
#'
#' @param n_low_freq_proj (optionnel)
#'
#' Entier non négatif représentant le nombre de nœuds de basse fréquence (tel que défini avec l'argument 
#' `low_freq_periodicity`) à ajouter aux deux extrémités (avant le premier étalon et après le dernier étalon) 
#' avant de commencer à ajouter des nœuds de *haute fréquence* (celle de la série indicatrice).
#'
#' **La valeur par défaut** est `n_low_freq_proj = 1`.
#'
#' @param proj_knots_rho_bd (optionnel)
#'
#' Limite qui s'applique à la valeur spécifiée avec l'argument `rho` et qui determine le type noœuds supplémentaires à 
#' ajouter aux deux extrémités (avant le premier étalon et après le dernier étalon). Lorsque `rho > proj_knots_rho_bd`, des 
#' nœuds de *haute fréquence* (celle de la série indicatrice) sont utilisés immédiatement aux deux extrémité. Autrement, 
#' lorsque `rho <= proj_knots_rho_bd`, des nœuds de *basse fréquence* (voir les arguments `low_freq_periodicity` et 
#' `n_low_freq_proj`) sont d'abord projetés de part et d'autre. Notez que pour des stocks trimestriels, le cube de 
#' `proj_knots_rho_bd` est utilisé. Par conséquent, la valeur de l'argument `proj_knots_rho_bd` doit correspondre à des 
#' indicateurs de stocks mensuels; elle est ajustée à l'interne pour des stocks trimestriels. Cet argument vise à atteindre 
#' un compromis pour les périodes à l'extérieur (avant ou après) les étalons (points d'ancrage) fournis en entrée, 
#' c'est-à-dire des ajustements de type Denton (en ligne droite) lorsque `rho` s'approche de 1 (lorsque 
#' `rho > proj_knots_rho_bd`) et une spline cubique d'apparence normale (sans contorsions excessives) dans le cas contraire 
#' (lorsque `rho <= proj_knots_rho_bd`). La section **Détails** contient plus d'informations sur ce sujet et certains 
#' cas illustratifs sont fournis dans la section **Exemples**.
#'
#' **La valeur par défaut** est `proj_knots_rho_bd = 0.995` (\eqn{0.995^3} pour des indicateurs de stocks trimestriels).
#'
#'
#' @details
#' ## Comparaison avec [benchmarking()]
#' Avec des séries de stocks, [benchmarking()] est connu pour produire des bris dans les ajustements d'étalonnage aux périodes 
#' correspondant aux étalons (points d'ancrage). [stock_benchmarking()] résout ce problème en travaillant directement sur les 
#' ajustements d'étalonnage. Des ajustements lisses pour les stocks sont garantis en estimant une spline cubique de *pente=0* 
#' (une spline qui est *plate* aux deux extrémités) passant par les nœuds correspondant à la différence (lorsque l'argument 
#' `lambda = 0.0`) ou au ratio (sinon) entre les étalons (points d'ancrage) et les valeurs correspondantes de la série indicatrice. 
#' Ces nœuds sont parfois appelés *différences BI* ou *ratios BI* (_**B**enchmark-to-**I**ndicator_ en anglais). Les 
#' interpolations à partir de la spline cubique estimée fournissent alors les ajustements d'étalonnage pour les périodes entre 
#' les étalons.
#' 
#' Les arguments `rho`, `lambda`, `biasOption` et `bias` jouent un rôle similaire à ceux de [benchmarking()]. Cependant, notez que 
#' pour [stock_benchmarking()], l'argument `rho` n'affecte les résultats que pour les périodes à l'extérieur, ou autour, du premier 
#' et du dernier étalon et `lambda` ne prend que deux valeurs en pratique : `lambda = 0.0` pour des ajustements additifs 
#' (interpolations par spline cubique où les nœuds sont des *différences BI*) ou `lambda = 1.0` pour des ajustements multiplicatifs 
#' (interpolations par spline cubique où les nœuds sont des *ratios BI*). Toute valeur non nulle pour `lambda` donnerait le même 
#' résultat que `lambda = 1.0`. Les coefficients d'altérabilité jouent également un rôle similaire à ceux de [benchmarking()] et ont 
#' les mêmes valeurs par défaut, c'est-à-dire \eqn{1.0} pour la série indicatrice (valeurs non contraignantes) et \eqn{0.0} pour 
#' les étalons (étalons contraignants). Cependant, comme pour l'argument `lambda`, les coefficients d'altérabilité de cette 
#' fonction ne prennent que deux valeurs en pratique : \eqn{0.0} pour des valeurs contraignantes ou \eqn{1.0} pour des valeurs 
#' non contraignantes. Tout coefficient d'altérabilité non nul renverrait le même résultat qu'un coefficient de \eqn{1.0}. Une 
#' autre différence avec [benchmarking()] est que les coefficients d'altérabilité définis par l'utilisateur sont autorisés même 
#' si `rho = 1` avec [stock_benchmarking()]. Enfin, le fait de spécifier un étalon non contraignant avec [stock_benchmarking()] 
#' équivaut à l'ignorer complètement, comme si l'étalon en question n'était pas inclus dans le fichier d'entrée des étalons. Par 
#' rapport à [benchmarking()], cette approche se traduit généralement par un impact plus important des étalons non contraignants 
#' sur les résultats de l'étalonnage (sur les stocks étalonnés résultants).
#' 
#' ## Solution autour des premier et dernier étalons (*problème d'actualité* de l'étalonnage)
#' Une spline de *pente=0* est choisie parce qu'elle correspond conceptuellement à l'approche (populaire) d'*étalonnage de 
#' Denton* (`rho = 1`). Afin de fournir une solution avant le premier étalon et après le dernier étalon qui soit semblable à 
#' celle de [benchmarking()] lorsque `rho < 1`, c'est-à-dire des ajustements convergeant vers le biais à une vitesse dictée par 
#' l'argument `rho`, des nœuds supplémentaires sont ajoutés aux deux extrémités avant d'estimer la spline. Par défaut, un nœud 
#' supplémentaire de basse fréquence (défini par l'argument `low_freq_periodicity`) est ajouté de chaque côté (au début et à la fin), 
#' c'est-à-dire qu'un nœud supplémentaire est ajouté avant le premier étalon et après le dernier étalon. Ensuite, des nœuds de 
#' haute fréquence (celle de la série indicatrice) sont ajoutés pour couvrir l'étendue de la série indicatrice, à laquelle est 
#' ajoutée une année supplémentaire de nœuds de haute fréquence. La valeur de tous ces nœuds supplémentaires est basée sur les 
#' arguments `rho`, `biasOption` et `bias`. Cela produit des ajustements lisses et naturels pour les périodes à l'extérieur, ou 
#' autour, des premier et dernier étalons qui convergent progressivement vers le biais, de manière similaire à [benchmarking()]. 
#' Le nombre de nœuds supplémentaires de basse fréquence à ajouter peut être modifié avec l'argument `n_low_freq_proj`. 
#' L'utilisation immédiate de nœuds de haute fréquence (`n_low_freq_proj = 0`) produirait les mêmes ajustements projetés que 
#' [benchmarking()]. Cependant, notez que cela tend à produire une spline d'apparence peu naturelle (exagérément contortionnée) 
#' autour des premier et dernier étalons qui pourrait être révisée de manière substantielle une fois que le prochain étalon sera 
#' disponible. L'utilisation de la valeur par défaut `n_low_freq_proj = 1` fonctionne généralement mieux. Cependant, lorsque 
#' `rho` est *proche de 1* (voir l'argument `proj_knots_rho_bd`), des noeuds de haute fréquence sont immédiatement ajoutés de 
#' chaque côté afin d'assurer des ajustements projetés de type Denton (en ligne droite) pour les périodes à l'extérieur des 
#' premier et dernier étalons. Enfin, une spline cubique de *pente=0* passant à travers les nœuds (originaux et supplémentaires) 
#' est estimée. Notez qu'en pratique, la spline de *pente=0* est en fait approximée en reproduisant la valeur des nœuds aux 
#' extrémités 100 fois au cours de la période suivante (à une fréquence correspondant à 100 fois la fréquence de la série 
#' indicatrice).
#' 
#' Une *spline naturelle* aux nœuds d'extrémité originaux (premier et dernier étalons) peut être approximée en spécifiant
#' une grande valeur pour l'argument `low_freq_periodicity`. Plus la valeur de `low_freq_periodicity` est grande, plus la spline 
#' cubique se comportera comme une *spline naturelle* (dérivée seconde égale à 0 aux extrémités, c'est-à-dire une spline qui 
#' garde une pente constante aux extrémités au lieu d'être plate comme une spline de *pente=0*).
#' 
#' En résumé, les ajustements projetés sont contrôlés avec les arguments `rho`, `bias` (et `biasOption`), `n_low_freq_proj`, 
#' `proj_knots_rho_bd` et `low_freq_periodicity` :
#' * Les valeurs par défaut de ces arguments produisent des ajustements projetés du type fonction `benchmarking` (convergence 
#' raisonnablement lente vers le biais).
#' * Des valeurs plus petites de `rho` généreraient une convergence plus rapide vers le biais.
#' * Spécifier un biais défini par l'utilisateur avec l'argument `bias` lorsque `rho < 1` est une autre façon d'influencer la 
#' forme des ajustements projetés.
#' * Spécifier `rho = 1` produit des ajustements projetés de type Denton (premiers/derniers ajustements répétés sans convergence 
#' vers le biais).
#' * Spécifier une grande valeur pour `low_freq_periodicity` génère des ajustements projetés qui se comportent plus comme une 
#' spline naturelle, c'est-à-dire des ajustements qui continuent dans la même direction au premier/dernier étalon. Plus la valeur 
#' de `low_freq_periodicity` est grande, plus les ajustements projetés continuent à aller dans la même direction avant de *tourner*.
#' 
#' La spline cubique associée aux ajustements de [stock_benchmarking()] peut être commodément tracée avec [plot_benchAdj()].
#' 
#' ## Note sur les révisions des ajustements d'étalonnage
#' Les ajustements de [benchmarking()] ne seraient pas révisés si tous les futurs étalons tombaient exactement sur ceux qui sont 
#' projetés (sur la base du biais et de la valeur de `rho`) et si le biais était fixé. La même chose pourrait être obtenue avec 
#' [stock_benchmarking()] si *suffisamment* de nœuds de basse fréquence (celle des étalons) étaient projetés. Le problème avec 
#' cette approche, cependant, est que les ajustements projetés peuvent ne pas sembler naturels car la spline peut osciller plus 
#' que souhaité autour des nœuds projetés. Ceci est clairement perceptible lorsque `rho` s'approche de 1 et que la spline oscille 
#' autour des nœuds projetés alignés horizontalement au lieu d'être alignée sur une ligne parfaitement droite. L'implémentation 
#' par défaut de la spline autour des premier et dernier étalons décrite précédemment vise à atteindre une *solution de meilleur 
#' compromis* :
#' * une spline d'apparence naturelle aux extrémités évitant les oscillations et les contorsions excessives;
#' * de petites révisions de la spline si l'étalon suivant est proche de celui projeté lorsque `rho` est _assez éloigné_
#' de 1 (`rho <= proj_knots_rho_bd`);
#' * ajustements projetés qui sont en ligne droite (sans oscillations) lorsque `rho` s'approche de 1 (`rho > proj_knots_rho_bd`).
#' 
#' Les sous-sections *Étalonnage de plusieurs séries*, *Arguments `constant` et `negInput_option`* et *Traitement des valeurs 
#' manquantes (`NA`)* à la fin de la section **Détails** de [benchmarking()] sont également pertinentes pour 
#' [stock_benchmarking()]. Consultez-les au besoin.
#' 
#' Enfin, notez que la spline cubique associée aux ajustements de [stock_benchmarking()] peut être commodément tracée avec 
#' [plot_benchAdj()]. Cette dernière est utilisée dans les **Exemples** pour illustrer certains des sujets abordés ci-dessus.
#'
#'
#' @returns
#' La fonction renvoie une liste de quatre *data frames* :
#' 
#' * **series** : *data frame* contenant les données étalonnées (sortie principale de la fonction). Les variables BY spécifiées 
#' avec l'argument `by` sont incluses dans le *data frame* mais pas les variables de coefficient d'altérabilité spécifiées 
#' avec l'argument `var`.
#' 
#' * **benchmarks** : copie du *data frame* d'entrée des étalons (à l'exclusion des étalons non valides, le cas échéant). 
#' Les variables BY spécifiées avec l'argument `by` sont incluses dans le *data frame* mais pas les variables de coefficient 
#' d'altérabilité spécifiées avec l'argument `with`.
#' 
#' * **graphTable** : *data frame* contenant des données supplémentaires utiles pour produire des tableaux et des graphiques 
#' analytiques (voir la fonction [plot_graphTable()]). Il contient les variables suivantes en plus des variables BY spécifiées 
#' avec l'argument `by` :
#'   * `varSeries` : Nom de la variable de la série indicatrice
#'   * `varBenchmarks` : Nom de la variable des étalons
#'   * `altSeries` : Nom de la variable des coefficients d'altérabilité définis par l'utilisateur pour la série indicatrice
#'   * `altSeriesValue` : Coefficients d'altérabilité de la série indicatrice
#'   * `altbenchmarks` : Nom de la variable des coefficients d'altérabilité définis par l'utilisateur pour les étalons
#'   * `altBenchmarksValue` : Coefficients d'altérabilité des étalons
#'   * `t` : Identificateur de la période de la série indicatrice (1 à \eqn{T})
#'   * `m` : Identificateur des périodes de couverture de l'étalon (1 à \eqn{M})
#'   * `year` : Année civile du point de données
#'   * `period` : Valeur de la période (du cycle) du point de données (1 à `periodicity`)
#'   * `rho` : Paramètre autorégressif \eqn{\rho} (argument `rho`)
#'   * `lambda` : Paramètre du modèle d'ajustement \eqn{\lambda} (argument `lambda`)
#'   * `bias` : Ajustement du biais (par défaut, défini par l'utilisateur ou biais estimé selon les arguments `biasOption` 
#'   et `bias`)
#'   * `periodicity` : Le nombre maximum de périodes dans une année (par exemple 4 pour une série indicatrice trimestrielle)
#'   * `date` : Chaîne de caractères combinant les valeurs des variables `year` et `period`
#'   * `subAnnual` : Valeurs de la série indicatrice
#'   * `benchmarked` : Valeurs de la série étalonnée
#'   * `avgBenchmark` : Valeurs des étalons divisées par le nombre de périodes de couverture
#'   * `avgSubAnnual` : Valeurs moyennes de la série indicatrice (variable `subAnnual`) pour les périodes couvertes par les 
#'   étalons
#'   * `subAnnualCorrected` : Valeurs de la série indicatrice corrigée pour le biais
#'   * `benchmarkedSubAnnualRatio` : Différence (\eqn{\lambda = 0}) ou ratio (\eqn{\lambda \ne 0}{lambda != 0}) des valeurs 
#'   des variables `benchmarked` et `subAnnual`
#'   * `avgBenchmarkSubAnnualRatio` : Différence (\eqn{\lambda = 0}) ou ratio (\eqn{\lambda \ne 0}{lambda != 0}) des valeurs 
#'   des variables `avgBenchmark` et `avgSubAnnual`
#'   * `growthRateSubAnnual` : Différence (\eqn{\lambda = 0}) ou différence relative (\eqn{\lambda \ne 0}{lambda != 0}) d'une 
#'   période à l'autre des valeurs de la série indicatrice (variable `subAnnual`)
#'   * `growthRateBenchmarked` : Différence (\eqn{\lambda = 0}) ou différence relative (\eqn{\lambda \ne 0}{lambda != 0}) d'une 
#'   période à l'autre des valeurs de la série étalonnée (variable `benchmarked`)
#'   
#' * **splineKnots** : ensemble de coordonnées `x` et `y` (nœuds) utilisées pour estimer la spline cubique naturelle avec la 
#' fonction `stats::spline()`. En plus de l'ensemble original de nœuds correspondant aux étalons (points d'ancrage) contraignants, 
#' des nœuds supplémentaires sont également ajoutés au début et à la fin afin de traiter le *problème d'actualité* de 
#' l'étalonnage et d'approximer une spline de *pente=0* aux deux extrémités (voir section **Détails**). Il contient les variables 
#' suivantes en plus des variables BY spécifiées avec l'argument `by` :
#'   * `varSeries` : Nom de la variable de la série indicatrice
#'   * `varBenchmarks` : Nom de la variable des étalons
#'   * `x` : Coordonnée `x` de la spline cubique
#'   * `y` : Coordonnée `y` de la spline cubique
#'   * `extraKnot` : Valeur logique (*logical*) identifiant les nœuds supplémentaires ajoutés au début et à la fin.
#' 
#'   Les enregistrements pour lesquels `extraKnot == FALSE` correspondent aux enregistrements du *data frame* de sortie 
#'   **graphTable** pour lesquels `m` n'est pas manquant (pas `NA`), avec `x = t` et `y = benchmarkedSubAnnualRatio`.
#'   
#' Notes :
#' * Le *data frame* de sortie **benchmarks** contient toujours les étalons originaux fournis dans le *data frame* d'entrée 
#' des étalons. Les étalons modifiés non contraignants, le cas échéant, peuvent être récupérés (calculés) à partir du *data frame* 
#' de sortie **series**.
#' * La fonction renvoie un objet `NULL` si une erreur se produit avant que le traitement des données ne puisse commencer. 
#' Dans le cas contraire, si l'exécution est suffisamment avancée pour que le traitement des données puisse commencer, alors 
#' un objet incomplet sera renvoyé en cas d'erreur (par exemple, un *data frame* de sortie **series** avec des valeurs `NA` 
#' pour les données étalonnées).
#' * La fonction renvoie des objets « data.frame » qui peuvent être explicitement convertis en d'autres types d'objets avec la 
#' fonction `as*()` appropriée (ex., `tibble::as_tibble()` convertirait n'importe lequel d'entre eux en tibble).
#'
#'
#' @references Statistique Canada (2012). « Chapitre 5 : Étalonnage de stocks ». **Théorie et application de l’étalonnage 
#' (Code du cours 0436)**. Statistique Canada, Ottawa, Canada.
#'
#'
#' @seealso [benchmarking()] [plot_graphTable()] [bench_graphs] [plot_benchAdj()]
#'
#'
#' @example misc/function_examples/stock_benchmarking-ex.R
#'
#'
#' @export
stock_benchmarking <- function(series_df,
                               benchmarks_df,
                               rho,
                               lambda,
                               biasOption,
                               bias = NA,
                               low_freq_periodicity = NA,
                               n_low_freq_proj = 1,
                               proj_knots_rho_bd = 0.995,
                               tolV = 0.001,
                               tolP = NA,
                               warnNegResult = TRUE,
                               tolN = -0.001,
                               var = "value",
                               with = NULL,
                               by = NULL,
                               constant = 0,
                               negInput_option = 0,
                               allCols = FALSE,
                               quiet = FALSE) {
  
  
  
  
  ### Internal functions ###
  
  
  # NOTE: some internal functions shared with `benchmarking()` are defined in script `aaa_bench_utils.R`
  #       where environment `the` is defined and contains objects that are not (cannot be) passed as arguments
  #       to the shared internal benchmarking functions.
  
  
  # Binding benchmarks validation function (proportional benchmarking0)
  check_nonZero_bindingBmk <- function(s_lowFreq, a, c_a, tol = gs.tolerance) {
    
    # Elementwise comparisons are necessary here (cannot use &&)
    if (any(abs(s_lowFreq) <= tol & (abs(a) * (c_a == 0)) > tol)) {
      warning("The indicator series is zero for a nonzero binding benchmark (anchor point). ",
              "This benchmark cannot be met with proportional benchmarking.\n", call. = FALSE, immediate. = TRUE)
      bk.e$warning_flag <- TRUE
    }
    
    invisible(NULL)
  }
  
  
  
  
  ### Main function ###
  
  # Initialize the object to be returned by the function via `on.exit()`
  out_list <- NULL
  on.exit(return(out_list))
  try_error <- FALSE
  try_error_msg <- ""
  bk.e$warning_flag <- FALSE
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  # Validate argument `quiet` and implement the quiet setting
  quiet <- gs.validate_arg_logi(quiet)
  if (quiet) {
    quiet_msg_func <- gs.NULL_func
    quiet_lab <- ""  # won't be displayed anyway
  } else {
    quiet_msg_func <- message
    quiet_lab <- "    quiet                = FALSE (default)"
  }
  
  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\nstock_benchmarking() function:\n")
  
  
  # Initial argument validation
  
  # Mandatory arguments (without default values)
  ser_df_name <- deparse1(substitute(series_df))
  tmp <- nchar(ser_df_name)
  if (tmp == 0) {
    stop("Argument 'series_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    ser_df_name <- paste0(substr(ser_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", ser_df_name, fixed = TRUE)) {
    ser_df_name <- "<argument 'series_df'>"
  }
  series_df <- series_df
  if (!is.data.frame(series_df)) {
    stop("Argument 'series_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  series_df <- as.data.frame(series_df)
  row.names(series_df) <- NULL
  bmk_df_name <- deparse1(substitute(benchmarks_df))
  tmp <- nchar(bmk_df_name)
  if (tmp == 0) {
    stop("Argument 'benchmarks_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    bmk_df_name <- paste0(substr(bmk_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", bmk_df_name, fixed = TRUE)) {
    bmk_df_name <- "<argument 'benchmarks_df'>"
  }
  benchmarks_df <- benchmarks_df
  if (!is.data.frame(benchmarks_df)) {
    stop("Argument 'benchmarks_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  benchmarks_df <- as.data.frame(benchmarks_df)
  row.names(benchmarks_df) <- NULL
  if (nchar(deparse1(substitute(lambda))) == 0) {
    stop("Argument 'lambda' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  tmp <- (unlist(lambda))[1]
  if (!identical(lambda, tmp) || is.null(tmp) || !is.finite(tmp)) {
    stop("Argument 'lambda' must be a real number.\n\n", call. = FALSE)
  }
  if (nchar(deparse1(substitute(rho))) == 0) {
    stop("Argument 'rho' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  tmp <- (unlist(rho))[1]
  if (!identical(rho, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0 || tmp > 1) {
    stop("Argument 'rho' must be a real number in the [0, 1] interval.\n\n", call. = FALSE)
  }
  if (nchar(deparse1(substitute(biasOption))) == 0) {
    if (rho == 1) {
      # bias is irrelevant for Denton benchmarking (`rho = 1`)
      biasOption <- 1L
    } else {
      stop("Argument 'biasOption' is mandatory (it must be specified).\n\n", call. = FALSE)
    }
  }
  tmp <- (unlist(biasOption))[1]
  if (!identical(biasOption, tmp) || is.null(tmp) || !(tmp %in% 1:3)) {
    stop("Argument 'biasOption' must take value 1, 2 or 3.\n\n", call. = FALSE)
  }
  biasOption <- as.integer(biasOption)
  
  # Optional arguments (with default values)
  tmp <- (unlist(bias))[1]
  if (is.null(tmp)) {
    bias <- NA_real_
  } else if (!identical(bias, tmp) || !is.finite(tmp) && !is.na(tmp)) {
    stop("Argument 'bias' must either be a real number or NA.\n\n", call. = FALSE)
  }
  tmp <- (unlist(low_freq_periodicity))[1]
  if (is.null(tmp)) {
    low_freq_periodicity <- NA_integer_
  } else {
    if (!identical(low_freq_periodicity, tmp) || !is.finite(tmp) && !is.na(tmp) ||
        is.finite(tmp) && (tmp <= 0 || tmp != as.integer(tmp))) {
      stop("Argument 'n_low_freq_proj' must be a positive integer or NA.\n\n", call. = FALSE)
    }
    low_freq_periodicity <- as.integer(low_freq_periodicity)    
  } 
  tmp <- (unlist(n_low_freq_proj))[1]
  if (!identical(n_low_freq_proj, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0 || tmp != as.integer(tmp)) {
    stop("Argument 'n_low_freq_proj' must be a nonnegative integer.\n\n", call. = FALSE)
  }
  n_low_freq_proj <- as.integer(n_low_freq_proj)
  tmp <- (unlist(proj_knots_rho_bd))[1]
  if (!identical(proj_knots_rho_bd, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0 || tmp > 1) {
    stop("Argument 'proj_knots_rho_bd' must be a real number in the [0, 1] interval.\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolV))[1]
  if (is.null(tmp)) {
    tolV <- NA_real_
  } else if (!identical(tolV, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolV' must be a nonnegative real number or NA.\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolP))[1]
  if (is.null(tmp)) {
    tolP <- NA_real_
  } else if (!identical(tolP, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolP' must be a nonnegative real number or NA.\n\n", call. = FALSE)
  }
  warnNegResult <- gs.validate_arg_logi(warnNegResult)
  tmp <- (unlist(tolN))[1]
  if (!identical(tolN, tmp) || is.null(tmp) || !is.finite(tmp) || tmp >= 0) {
    stop("Argument 'tolN' must be a negative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(constant))[1]
  if (!identical(constant, tmp) || is.null(tmp) || !is.finite(tmp)) {
    stop("Argument 'constant' must be a real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(negInput_option))[1]
  if (!identical(negInput_option, tmp) || is.null(tmp) || !(tmp %in% 0:2)) {
    stop("Argument 'negInput_option' must take value 0, 1 or 2.\n\n", call. = FALSE)
  }
  negInput_option <- as.integer(negInput_option)
  allCols <- gs.validate_arg_logi(allCols)
  # Argument `quiet` was already validated
  
  # Initialize the final warning/error message flag for multiple series processing
  final_msg_flag <- FALSE
  try_stop_func <- gs.NULL_func
  
  # Initialize the list of "non-data columns" (date and by-group columns)
  info_cols_serDF <- c("year", "period")
  info_cols_bmkDF <- c("startYear", "startPeriod", "endYear", "endPeriod")
  
  all_cols_serDF <- names(series_df)
  gs.validate_cols(info_cols_serDF, all_cols_serDF, ser_df_name)
  if (any(!is.finite(as.matrix(series_df[info_cols_serDF])))) {
    stop("Indicator series date columns (\"year\" and \"period\") contain invalid or NA values.\n\n", call. = FALSE)
  }
  
  all_cols_bmkDF <- names(benchmarks_df)
  gs.validate_cols(info_cols_bmkDF, all_cols_bmkDF, bmk_df_name)
  if (any(!is.finite(as.matrix(benchmarks_df[info_cols_bmkDF])))) {
    stop("Benchmarks date columns (\"startYear\", \"startPeriod\", \"endYear\" and \"endPeriod\") contain invalid or NA values.\n\n",
         call. = FALSE)
  }
  
  # Initialize the list of "series data columns" from both input files
  data_cols_serDF <- setdiff(all_cols_serDF, info_cols_serDF)
  data_cols_bmkDF <- setdiff(all_cols_bmkDF, info_cols_bmkDF)
  
  # Validation of argument 'by' ("non-data columns" as well)
  by <- unique(gs.cleanup_col_list(by))
  n_byVars <- length(by)
  if (n_byVars > 0) {
    by_lab <- paste0("    by                   = ", paste(by, collapse = " "))
    gs.validate_cols(by, data_cols_serDF, ser_df_name, source_str = "argument 'by'")
    gs.validate_cols(by, data_cols_bmkDF, bmk_df_name, source_str = "argument 'by'")
    by_grps <- unique(series_df[by])
    n_byGrps <- nrow(by_grps)
    
    # Build the by-group expression (for message display)
    if (n_byGrps > 0) {
      by_grps$SB._expr_ <- paste0(by[1], "=", by_grps[, by[1]])
      for (ii in seq_along(by)[-1]) {
        by_grps$SB._expr_ <- paste(by_grps$SB._expr_, paste0(by[ii], "=", by_grps[, by[ii]]), sep = " & ")
      }
    }
    
    # Add the by variables to the list of "non-data columns"
    info_cols_serDF <- c(by, info_cols_serDF)
    info_cols_bmkDF <- c(by, info_cols_bmkDF)
    
    # Remove by variables from the list of "series data columns"
    data_cols_serDF <- setdiff(data_cols_serDF, by)
    data_cols_bmkDF <- setdiff(data_cols_bmkDF, by)
    
    # Set message display info
    if (n_byGrps > 1) {
      byGrp_ini_func <- bk.byGrp_ini
      byGrp_msg_func <- message
      final_msg_flag <- TRUE
      try_stop_func <- gs.try_stop
    } else {
      byGrp_ini_func <- bk.noByGrp_ini
      byGrp_msg_func <- gs.NULL_func
    }
    
    # No by-groups
  } else {
    by <- NULL
    by_lab <- "    by                   = NULL (default)"
    by_grps <- data.frame(SB._expr_ = "")
    n_byGrps <- 1
    byGrp_ini_func <- bk.noByGrp_ini
    byGrp_msg_func <- gs.NULL_func
  }
  
  # Ignore arguments 'var' and 'with' and process all data columns of the input indicator series
  # data frame, expecting corresponding columns (same names) in the input benchmarks data frame
  if (allCols) {
    var_lab <- "    var                  (ignored)"
    with_lab <- "    with                 (ignored)"
    allCols_lab <- "    allCols              = TRUE"
    var <- data_cols_serDF
    with <- var
    n_vars <- length(var)
    alter_ser <- rep.int("", n_vars)
    default_alter_ser_id <- 1:n_vars
    user_alter_ser_id <- integer(0)  # value returned by which() on an "all FALSE" logical vector
    alter_bmk <- alter_ser
    default_alter_bmk_id <- 1:n_vars
    user_alter_bmk_id <- integer(0)
    gs.validate_cols(with, data_cols_bmkDF, bmk_df_name)
    
    # Process arguments 'var' and 'with'
  } else {
    allCols_lab <- "    allCols              = FALSE (default)"
    
    # Validation of argument 'var'
    var <- gs.cleanup_col_list(var)
    var_lab <- paste0("    var                  = ", paste(var, collapse = " "))
    if (var_lab == "    var                  = value") {
      var_lab <- "    var                  = value (default)"
    }
    tmp <- gs.split_str("\\/", var)
    var <- tmp[[1]]
    n_vars <- length(var)
    len <- length(tmp)
    if (len == 2) {
      alter_ser <- tmp[[2]]
      default_alter_ser_id <- which(alter_ser == "")
      user_alter_ser_id <- setdiff(1:n_vars, default_alter_ser_id)
    } else {
      if (len > 2) {
        stop("Invalid specification of alterability coefficients in argument 'var'.\n\n", call. = FALSE)
      }
      alter_ser <- rep.int("", n_vars)
      default_alter_ser_id <- 1:n_vars
      user_alter_ser_id <- integer(0)
    }
    prob_cols <- intersect(var, by)
    if (length(prob_cols) > 0) {
      stop("The following columns are listed with arguments 'var' and 'by' (these arguments are mutually exclusive):",
           paste0("\n  ", prob_cols, collapse = ""), "\n\n", call. = FALSE)
    }
    gs.validate_cols(c(var, alter_ser[user_alter_ser_id]), data_cols_serDF, ser_df_name, source_str = "argument 'var'")
    
    # Validation of argument 'with'
    with <- gs.cleanup_col_list(with)
    if (length(with) == 0) {
      with_lab <- "    with                 = NULL (default)"
      with <- var
      alter_bmk <- rep.int("", n_vars)
      default_alter_bmk_id <- 1:n_vars
      user_alter_bmk_id <- integer(0)
    } else {
      with_lab <- paste0("    with                 = ", paste(with, collapse = " "))
      tmp <- gs.split_str("\\/", with)
      with <- tmp[[1]]
      len <- length(tmp)
      if (len == 2) {
        alter_bmk <- tmp[[2]]
        default_alter_bmk_id <- which(alter_bmk == "")
        user_alter_bmk_id <- setdiff(1:n_vars, default_alter_bmk_id)
      } else {
        if (len > 2) {
          stop("Invalid specification of alterability coefficients in argument 'with'.", call. = FALSE)
        }
        alter_bmk <- rep.int("", n_vars)
        default_alter_bmk_id <- 1:n_vars
        user_alter_bmk_id <- integer(0)
      }
    }
    prob_cols <- intersect(with, by)
    if (length(prob_cols) > 0) {
      stop("The following columns are listed with arguments 'with' and 'by' (these arguments are mutually exclusive):",
           paste0("\n  ", prob_cols, collapse = ""), "\n\n", call. = FALSE)
    }
    gs.validate_cols(c(with, alter_bmk[user_alter_bmk_id]), data_cols_bmkDF, bmk_df_name, source_str = "argument 'with'")
    if (n_vars != length(with)) {
      stop("Arguments 'var' and 'with' do not contain the same number of elements.\n\n", call. = FALSE)
    }
  }
  if (n_vars == 0) {
    stop("Argument 'var' results in 0 series to be benchmarked.\n\n", call. = FALSE)
  } else if (n_vars == 1) {
    var_msg_func <- gs.NULL_func
  } else {
    var_msg_func <- message
    final_msg_flag <- TRUE
    try_stop_func <- gs.try_stop
  }
  
  
  # Shrink the input data frames with only the necessary columns
  series_df <- series_df[unique(c(info_cols_serDF, var, alter_ser[user_alter_ser_id]))]
  benchmarks_df <- benchmarks_df[unique(c(info_cols_bmkDF, with, alter_bmk[user_alter_bmk_id]))]
  
  # Add the default alter coefs to the input data frames and specify them when relevant
  series_df$SB._default_alter_ <- rep.int(1, nrow(series_df))
  benchmarks_df$SB._default_alter_ <- rep.int(0, nrow(benchmarks_df))
  actual_alter_ser <- alter_ser
  actual_alter_bmk <- alter_bmk
  alter_ser[default_alter_ser_id] <- "SB._default_alter_"
  alter_bmk[default_alter_bmk_id] <- "SB._default_alter_"
  alter_ser_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_bmk_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_ser_check_func_str[user_alter_ser_id] <- "gs.check_alter"
  alter_bmk_check_func_str[user_alter_bmk_id] <- "gs.check_alter"
  
  # Initialize the output data frames (as NULL objects for now)
  out_series_df <- NULL
  out_benchmarks_df <- NULL
  out_graphTable_df <- NULL
  out_splineKnots_df <- NULL
  
  # Set parameters and function names according to the benchmarking model (additive benchmarking
  # when 'lambda == 0' and proportional benchmarking otherwise):
  #   - negative values verification functions
  #   - bias calculation and BI (ratios or differences) application
  #   - ratio and growth rate calculation functions
  if (lambda == 0) {
    zeros_verif_func <- gs.NULL_func
    neg_verif_func <- gs.FALSE_func
    default_bias <- 0
    bias_calc_func <- bk.calc_add_bias
    bias_apply_func <- bk.apply_add_bias
    BI_apply_func <- bk.apply_add_bias
    ratio_func <- gs.calc_diff
    growthRate_func <- gs.calc_firstDiff
  } else {
    zeros_verif_func <- check_nonZero_bindingBmk
    if (negInput_option == 0) {
      neg_verif_func <- bk.check_neg_err
    } else if (negInput_option == 1) {
      neg_verif_func <- bk.check_neg_warn
    } else {
      neg_verif_func <- gs.FALSE_func
    }
    default_bias <- 1
    bias_calc_func <- bk.calc_mult_bias
    bias_apply_func <- bk.apply_mult_bias
    BI_apply_func <- bk.apply_mult_bias
    ratio_func <- gs.calc_ratio
    growthRate_func <- gs.calc_relFirstDiff
    if (!is.na(bias) && bias < 0) {
      stop("Argument 'bias' must be positive with proportional benchmarking.\n\n", call. = FALSE)
    }
  }
  
  # Set the bias option function according to argument 'biasOption'
  if (rho == 1) {
    # The bias has no effect and can be ignored (impose `biasOption = 1` and `bias = NA`)
    biasOption_func <- bk.apply_biasOption1
    biasOption_lab <- "    biasOption           (ignored)"
    bias_parm <- default_bias
    bias_str <- "default"
    bias_lab <- "    bias                 (ignored)"
  } else {
    if (biasOption == 3) {
      biasOption_func <- bk.apply_biasOption3
      biasOption_lab <- "    biasOption           = 3 (Calculate bias, use calculated bias)"
      bias_parm <- NA_real_
      bias_str <- NA_character_
      bias_lab <- "    bias                 (ignored)"
    } else {
      if (biasOption == 1) {
        biasOption_func <- bk.apply_biasOption1
        biasOption_lab <- "    biasOption           = 1 (Use user-defined or default bias)"
      } else if (biasOption == 2) {
        biasOption_func <- bk.apply_biasOption2
        biasOption_lab <- "    biasOption           = 2 (Calculate bias, but use user-defined or default bias)"
      }
      if (is.na(bias)) {
        bias_parm <- default_bias
        bias_str <- "default"
        bias_lab <- "    bias                 = NA (default)"
      } else {
        bias_parm <- bias
        bias_str <- "user-defined"
        bias_lab <- paste0("    bias                 = ", format(bias))
      }
    }
  }
  bk.e$actual_bias <- NULL
  
  # Minimum required number of periods in the indicator series
  min_nT <- 1
  
  # Results validation function and binding benchmarks tolerance
  if (warnNegResult) {
    neg_res_func <- gs.check_neg
    warnNegResult_lab <- "    warnNegResult        = TRUE (default)"
  } else {
    neg_res_func <- gs.FALSE_func
    warnNegResult_lab <- "    warnNegResult        = FALSE"
  }
  if (!is.na(tolV)) {
    if (!is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both specified (one must be NA).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_diff_valid
    tol_parm <- tolV
    tol_lab <- paste0("    tolV                 = ", format(tolV))
    if (abs(tolV - 0.001) < gs.tolerance) {
      tol_lab <- paste0(tol_lab, " (default)")
    }
  } else {
    if (is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both NA (one must be specified).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_relDiff_valid
    tol_parm <- tolP
    tol_lab <- paste0("    tolP                 = ", format(tolP))
  }
  
  
  # Display the function call (argument values)
  quiet_msg_func("    series_df            = ", ser_df_name)
  quiet_msg_func("    benchmarks_df        = ", bmk_df_name)
  quiet_msg_func("    rho                  = ", format(rho))
  quiet_msg_func("    lambda               = ", format(lambda))
  quiet_msg_func(biasOption_lab)
  quiet_msg_func(bias_lab)
  lab <- paste0("    low_freq_periodicity = ", low_freq_periodicity)
  if (is.na(low_freq_periodicity)) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    n_low_freq_proj      = ", n_low_freq_proj)
  if (n_low_freq_proj == 1) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    proj_knots_rho_bd    = ", format(proj_knots_rho_bd))
  if (abs(proj_knots_rho_bd - 0.995) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(tol_lab)
  quiet_msg_func(warnNegResult_lab)
  lab <- paste0("    tolN                 = ", format(tolN))
  if (abs(tolN - (-0.001)) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(var_lab)
  quiet_msg_func(with_lab)
  quiet_msg_func(by_lab)
  lab <- paste0("    constant             = ", format(constant))
  if (constant == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    negInput_option      = ", format(negInput_option))
  if (negInput_option == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(allCols_lab)
  quiet_msg_func(quiet_lab, "\n")
  
  
  # Return the input series data frames
  if (nrow(series_df) == 0 || nrow(benchmarks_df) == 0) {
    out_series_df <- series_df[intersect(all_cols_serDF, names(series_df))]
    out_benchmarks_df <- benchmarks_df[intersect(all_cols_bmkDF, names(benchmarks_df))]
    
    # Attempt to benchmark the data
  } else {
    
    # Enforce integer period id values
    cols_vec <- setdiff(info_cols_serDF, by)
    series_df[cols_vec] <- as.integer(as.matrix(series_df[cols_vec]))
    cols_vec <- setdiff(info_cols_bmkDF, by)
    benchmarks_df[cols_vec] <- as.integer(as.matrix(benchmarks_df[cols_vec]))
    
    
    # Process each by-group
    
    on.exit(rlang::env_unbind(bk.e, c("ser_df_byGrp", "bmk_df_byGrp")), add = TRUE)
    for (ii in 1:n_byGrps) {
      
      # By-group initialization/setup
      bk.e$ser_df_byGrp <- NULL
      bk.e$bmk_df_byGrp <- NULL
      byGrp_ini_func(series_df, benchmarks_df, by_grps, ii, by)
      
      msg_str <- paste0("\nBenchmarking by-group ", ii, " (", by_grps$SB._expr_[ii], ")")
      byGrp_msg_func(msg_str)
      byGrp_msg_func(strrep("=", nchar(msg_str) - 1), "\n")
      
      # Reject rows with invalid benchmark data (for any of the benchmarks)
      M_ini <- nrow(bk.e$bmk_df_byGrp)
      if (nrow(bk.e$bmk_df_byGrp) > 1) {
        prob_id <- which(apply(!apply(bk.e$bmk_df_byGrp[with], 2, is.finite), 1, any))
      } else {
        prob_id <- which(any(!apply(bk.e$bmk_df_byGrp[with], 2, is.finite)))
      }
      if (length(prob_id) > 0) {
        warning("Rows from the benchmarks data frame were dropped because of invalid or NA values.\n",
                call. = FALSE, immediate. = TRUE)
        bk.e$warning_flag <- TRUE
        bk.e$bmk_df_byGrp <- bk.e$bmk_df_byGrp[-prob_id, , drop = FALSE]
        M <- nrow(bk.e$bmk_df_byGrp)
      } else {
        M <- M_ini
      }
      
      # Initialize the by-group output data frames
      out_bmk_df_byGrp <- bk.e$bmk_df_byGrp[c(info_cols_bmkDF, with)]
      out_ser_df_byGrp <- bk.e$ser_df_byGrp[c(info_cols_serDF, var)]
      out_ser_df_byGrp[var] <- NA_real_
      
      nT <- nrow(bk.e$ser_df_byGrp)
      if (nT < min_nT) {
        try_error_msg <- paste0("The minimum number of periods (", min_nT, ") for the indicator series ", 
                                "is not met.\n\n")
        try_stop_func(try_error_msg)
        try_error <- TRUE
        
      } else if (M == 0) {
        try_error_msg <- "A minimum of 1 benchmark is required.\n\n"
        try_stop_func(try_error_msg)
        try_error <- TRUE
        
      } else {
        
        # Vectors for periods and benchmarks coverage validation
        periodicity <- max(bk.e$ser_df_byGrp$period)
        if (is.na(low_freq_periodicity)) {
          low_freq_periodicity <- periodicity
        }
        periods <- paste(bk.e$ser_df_byGrp$year, bk.e$ser_df_byGrp$period, sep = "-")
        bmk_start <- paste(bk.e$bmk_df_byGrp$startYear, bk.e$bmk_df_byGrp$startPeriod, sep = "-")
        bmk_end <- paste(bk.e$bmk_df_byGrp$endYear, bk.e$bmk_df_byGrp$endPeriod, sep = "-")
        
        # Validate indicator series periods (period-to-period gap != 1 / periodicity)
        time_val <- bk.e$ser_df_byGrp$year + (bk.e$ser_df_byGrp$period - 1) / periodicity
        if (nT > 1) {
          # `sapply()` is safe: `which()` always returns a "vector" object, even when `nT = 2`
          prob_id <- which(c(FALSE,
                             sapply(2:nT,
                                    function(x) {
                                      abs(time_val[x] - time_val[x - 1] - 1 / periodicity) > gs.tolerance
                                    })))
        } else {
          prob_id <- integer(0)
        }
        if (length(prob_id) > 0) {
          try_error_msg <- paste0("Non-contiguous periods found in the indicator series: ",
                                  paste0("\n  ", periods[prob_id - 1], " - ", periods[prob_id], collapse = ""), 
                                  "\n\n")
          try_stop_func(try_error_msg)
          try_error <- TRUE
          
        } else {
          
          # Validate the benchmark coverage: anchor points (single-period coverage)
          prob_id <- which(bk.e$bmk_df_byGrp$startYear != bk.e$bmk_df_byGrp$endYear |
                             bk.e$bmk_df_byGrp$startPeriod != bk.e$bmk_df_byGrp$endPeriod)
          if (length(prob_id) > 0) {
            try_error_msg <- paste0("Benchmark coverage not compatible with stock benchmarking (not an anchor point): ",
                                    paste0("\n  [", bmk_start[prob_id], ", ", bmk_end[prob_id], "]", 
                                           collapse = ""), 
                                    "\n\n")
            try_stop_func(try_error_msg)
            try_error <- TRUE
            
          } else {
            
            # Build benchmarks to periods mapping vector of dimension M
            # (period id of each "anchor point" benchmark)
            bmk_per_id <- match(bmk_start, periods)
            
            # Validate the benchmark coverage: not inside the set of indicator periods
            prob_id <- which(is.na(bmk_per_id))
            if (length(prob_id) > 0) {
              try_error_msg <- paste0("Benchmark coverage not fully inside the indicator series span: ",
                                      paste0("\n  [", bmk_start[prob_id], ", ", bmk_end[prob_id], "]", 
                                             collapse = ""), 
                                      "\n\n")
              try_stop_func(try_error_msg)
              try_error <- TRUE
              
            } else {
              
              # Display a message about the number of observations in the benchmarks and series data frames
              # Note: all indicator series observations are valid at this point, making the SERIES
              #       message not quite relevant... but that's what SAS G-Series PROC BENCHMARKING displays
              #       (there might be cases where the 2 numbers differ, but I don't see it...)
              
              # Widths without commas
              width_nT <- floor(log10(nT)) + 1
              width_M_ini <- floor(log10(M_ini)) + 1
              width_M <- floor(log10(M)) + 1
              
              # Adjust the widths of the benchmarks info considering the commas (for `format(..., big.mark = ",")`)
              # => add the difference in the number of commas between the series obs. number (`nT`) and each of the 
              #    two (initial and final) benchmarks obs. numbers (`M_ini` and `M`)
              # => it's (reasonably) assumed here that there will always be more observations in the series data 
              #    frame than in the benchmarks data frame (i.e., `nT` >= `M_ini` >= `M`)
              if (width_M_ini < width_nT) {
                width_M_ini <- width_nT + floor((width_nT - 1) / 3) - floor((width_M_ini - 1) / 3)
              }
              if (width_M < width_nT) {
                width_M <- width_nT + floor((width_nT - 1) / 3) - floor((width_M - 1) / 3)
              }
              quiet_msg_func("Number of observations in the BENCHMARKS data frame .............: ",
                             format(M_ini, scientific = FALSE, big.mark = ",", width = width_M_ini, justify = "right"))
              quiet_msg_func("Number of valid observations in the BENCHMARKS data frame .......: ",
                             format(M, scientific = FALSE, big.mark = ",", width = width_M, justify = "right"), "\n")
              quiet_msg_func("Number of observations in the SERIES data frame .................: ",
                             format(nT, scientific = FALSE, big.mark = ",", width = width_nT, justify = "right"))
              quiet_msg_func("Number of valid observations in the SERIES data frame ...........: ",
                             format(nT, scientific = FALSE, big.mark = ",", width = width_nT, justify = "right"), "\n")
              
              # Set K1 for the BY-group...
              #   K1 = the number of low (benchmark) frequency extra knots at the start and end
              if (rho > proj_knots_rho_bd^(12 / periodicity)) {
                K1 <- 0
              } else {
                K1 <- n_low_freq_proj
              }
              
              
              # Process each series
              for (jj in 1:n_vars) {
                
                msg_str <- paste0("\nBenchmarking indicator series [", var[jj], "] with benchmarks [", with[jj], "]")
                var_msg_func(msg_str)
                var_msg_func(strrep("-", nchar(msg_str) - 1), "\n")
                
                # Series/benchmarks data and alterablity coefficients validation
                if (any(!is.finite(bk.e$ser_df_byGrp[[var[jj]]]))) {
                  warning("The indicator series contains invalid or NA values. It will not be processed.\n", call. = FALSE,
                          immediate. = TRUE)
                  bk.e$warning_flag <- TRUE
                  
                } else if (do.call(alter_ser_check_func_str[jj], list(bk.e$ser_df_byGrp[[alter_ser[jj]]]))) {
                  try_error_msg <- "Invalid indicator series alterability coefficients (must be nonnegative numbers).\n\n"
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
                  
                } else if (do.call(alter_bmk_check_func_str[jj], list(bk.e$bmk_df_byGrp[[alter_bmk[jj]]]))) {
                  try_error_msg <- "Invalid benchmarks alterability coefficients (must be nonnegative numbers).\n\n"
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
                  
                  # Process (benchmark) the series
                } else {
                  
                  # Build the elementary vectors and matrices
                  #   => the temporary constant is added here
                  s <- bk.e$ser_df_byGrp[[var[jj]]] + constant
                  c_s <- bk.e$ser_df_byGrp[[alter_ser[jj]]]
                  a <- bk.e$bmk_df_byGrp[[with[jj]]] + constant
                  c_a <- bk.e$bmk_df_byGrp[[alter_bmk[jj]]]
                  
                  # Get the indicator series values associated to the benchmarks (anchor points)
                  s_lowFreq <- s[bmk_per_id]
                  
                  # Additional series/benchmarks data validation for proportional benchmarking (lambda != 0)
                  #   - nonzero binding benchmarks associated to zero indicator series values (undefined BI value)
                  #   - negative benchmark or indicator series values (according to argument `negInput_option`)
                  zeros_verif_func(s_lowFreq, a, c_a, tol = gs.tolerance)
                  if (neg_verif_func(a, tol = 0, data_str = "benchmarks")) {
                    try_error_msg <- paste0("Negative values found in the benchmarks. This is not permitted for ", 
                                            "proportional benchmarking.\n\n")
                    try_stop_func(try_error_msg)
                    try_error <- TRUE
                    
                  } else if (neg_verif_func(s, tol = 0, data_str = "indicator series")) {
                    try_error_msg <- paste0("Negative values found in the indicator series. This is not permitted for ", 
                                            "proportional benchmarking.\n\n")
                    try_stop_func(try_error_msg)
                    try_error <- TRUE
                    
                  } else {
                    
                    # Bias correction
                    s_b <- biasOption_func(quiet_msg_func,                                 # message function
                                           bias_calc_func, s_lowFreq, a, M, gs.tolerance,  # bias calculation arguments
                                           bias_apply_func, s, bias_parm,                  # bias application arguments
                                           bias_str)
                    
                    
                    # Calculate the initial set of knots corresponding to binding benchmarks, taking the average value
                    # for duplicated binding benchmarks (spline knot x = t, spline knot y = BI differences or ratios)
                    binding_m <- which(c_a == 0)
                    t_vec <- bmk_per_id[binding_m]
                    if (anyDuplicated(t_vec)) {
                      t_vec <- unique(t_vec)
                      knots_ini <- data.frame(t = t_vec,
                                              BI = ratio_func(as.vector(tapply(a[binding_m], bmk_start[binding_m], mean)),
                                                              s[t_vec]),
                                              extra_knot = FALSE)
                    } else {
                      knots_ini <- data.frame(t  = t_vec,
                                              BI = ratio_func(a[binding_m], s[t_vec]),
                                              extra_knot = FALSE)
                    }
                    
                    # Remove missing (`NA`) BI's, i.e. irrelevant spline knots (BI values) corresponding to indicator
                    # values of 0 with proportional benchmarking (0's remain 0's with proportional benchmarking)
                    knots_ini <- knots_ini[!is.na(knots_ini$BI), , drop = FALSE]
                    n_knots_ini <- nrow(knots_ini)
                    
                    # Validate the initial set of knots
                    if (n_knots_ini == 0) {
                      quiet_msg_func("Benchmarking is not required for this series (no relevant benchmark remains). ",
                                     "New observations will not be added to the output spline knots data frame.\n")
                      theta <- s
                      
                    } else {
                      
                      
                      # Add extra knots at the start and end (benchmarking timeliness issue)
                      
                      # Set K2...
                      #   K2 = the number of high (indicator series) frequency extra knots to add after the
                      #        low (benchmarks) frequency extra knots (K1)
                      #      = the number of periods required to cover the first/last plus 1 year worth of
                      #        high frequency knots
                      K2.beg <- periodicity + max(0, knots_ini$t[1] - K1 * low_freq_periodicity - 1)
                      K2.end <- periodicity + max(0, nT - knots_ini$t[n_knots_ini] - K1 * low_freq_periodicity)
                      
                      # Initialize the spline knots with NA for columns "t" and "BI" for the extra knots (for now)
                      # (the 100 extra knots will be used to approximate a "slope=0" spline at both ends)
                      n_extra.beg <- K1 + K2.beg + 100
                      n_extra.end <- K1 + K2.end + 100
                      knots <- rbind(data.frame(t = rep.int(NA_real_, n_extra.beg),
                                                BI = rep.int(NA_real_, n_extra.beg),
                                                extra_knot = rep.int(TRUE, n_extra.beg)),
                                     knots_ini,
                                     data.frame(t = rep.int(NA_real_, n_extra.end),
                                                BI = rep.int(NA_real_, n_extra.end),
                                                extra_knot = rep.int(TRUE, n_extra.end)))
                      
                      # K1 low frequency knots
                      kk.beg <- n_extra.beg + 1
                      kk.end <- n_extra.beg + n_knots_ini
                      for (kk in seq_len(K1)) {
                        # ... at the start
                        knots$t[kk.beg - kk] <- knots$t[kk.beg] - kk * low_freq_periodicity
                        knots$BI[kk.beg - kk] <- bk.e$actual_bias + rho^(kk * low_freq_periodicity) *
                          (knots$BI[kk.beg] - bk.e$actual_bias)
                        # ... at the end
                        knots$t[kk.end + kk] <- knots$t[kk.end] + kk * low_freq_periodicity
                        knots$BI[kk.end + kk] <- bk.e$actual_bias + rho^(kk * low_freq_periodicity) *
                          (knots$BI[kk.end] - bk.e$actual_bias)
                      }
                      
                      # K2 high frequency knots
                      #... at the start
                      kk.beg <- kk.beg - K1
                      for (kk in seq_len(K2.beg)) {
                        knots$t[kk.beg - kk] <- knots$t[kk.beg - kk + 1] - 1
                        knots$BI[kk.beg - kk] <- bk.e$actual_bias + rho * (knots$BI[kk.beg - kk + 1] - bk.e$actual_bias)
                      }
                      #... at the end
                      kk.end <- kk.end + K1
                      for (kk in seq_len(K2.end)) {
                        knots$t[kk.end + kk] <- knots$t[kk.end + kk - 1] + 1
                        knots$BI[kk.end + kk] <- bk.e$actual_bias + rho * (knots$BI[kk.end + kk - 1] - bk.e$actual_bias)
                      }
                      
                      # 100 extra knots for "slope=0" spline approximation
                      kk.beg <- kk.beg - K2.beg
                      kk.end <- kk.end + K2.end
                      for (kk in 1:100) {
                        # ... at the start
                        knots$t[kk.beg - kk] <- knots$t[kk.beg] - kk / 100
                        knots$BI[kk.beg - kk] <- knots$BI[kk.beg]
                        # ... at the end
                        knots$t[kk.end + kk] <- knots$t[kk.end] + kk / 100
                        knots$BI[kk.end + kk] <- knots$BI[kk.end]
                      }
                      
                      # Implement the spline interpolations
                      interpol <- stats::spline(knots$t, knots$BI, xout = 1:nT, method = "natural")
                      BI <- interpol$y
                      
                      # Benchmark the indicator series by applying the interpolated BI ratios or differences
                      # to the indicator series, taking into account binding indicator values (BI = bias)
                      BI[which(c_s == 0)] <- bk.e$actual_bias
                      theta <- BI_apply_func(s, BI)
                      
                      
                      # Cumulate the splineKnots output data frame info
                      n_knots <- nrow(knots)
                      out_splineKnots_df <- rbind(out_splineKnots_df,
                                                  cbind((bk.e$ser_df_byGrp[by])[rep.int(1, n_knots), , drop = FALSE],
                                                        data.frame(varSeries = rep.int(var[jj], n_knots),
                                                                   varBenchmarks = rep.int(with[jj], n_knots),
                                                                   x = knots$t,
                                                                   y = knots$BI,
                                                                   extraKnot = knots$extra_knot)))
                    }
                    
                    
                    # Cumulate the graphTable output data frame info
                    #   => the graphTable includes more periods than the indicator series (`n_obs_GT > nT`)
                    #      in the case of duplicate benchmarks (anchor points)
                    
                    # Map benchmark level info (vectors of length `M`) to period level info (vectors of length
                    # `n >= nT`, with `n = nT` for distinct benchmarks and `n > nT` for duplicate benchmarks)
                    #
                    # The resulting `bmk_info` data frame has `n >= nT` observations and 5 variables:
                    #   - `t`: period id
                    #   - `m`: benchmark id (`NA` for periods not associated to any benchmark)
                    #   - `avg_s`: indicator series value  (`NA` for periods not associated to any benchmark)
                    #   - `avg_a`: benchmark value (`NA` for periods not associated to any benchmark)
                    #   - `c_a`: benchmark alter coef (`NA` for periods not associated to any benchmark)
                    bmk_info <- merge(data.frame(t = 1:nT), # period ids
                                      # Benchmark level info
                                      data.frame(t = bmk_per_id, # benchmark (anchor point) period ids
                                                 m = 1:M,
                                                 avg_s = s_lowFreq,
                                                 avg_a = a,
                                                 c_a = c_a),
                                      by = "t", 
                                      all.x = TRUE)
                    
                    # Generate the graphTable data frame info
                    n_obs_GT <- length(bmk_info$t)
                    out_GT_df_var <- data.frame(varSeries = rep.int(var[jj], n_obs_GT),
                                                varBenchmarks = rep.int(with[jj], n_obs_GT),
                                                altSeries = rep.int(actual_alter_ser[jj], n_obs_GT),
                                                altSeriesValue = c_s[bmk_info$t],
                                                altbenchmarks = rep.int(actual_alter_bmk[jj], n_obs_GT),
                                                altBenchmarksValue = bmk_info$c_a,
                                                t = bmk_info$t,
                                                m = bmk_info$m,
                                                year = bk.e$ser_df_byGrp$year[bmk_info$t],
                                                period = bk.e$ser_df_byGrp$period[bmk_info$t],
                                                constant = rep.int(constant, n_obs_GT),
                                                rho = rep.int(rho, n_obs_GT),
                                                lambda = rep.int(lambda, n_obs_GT),
                                                bias = rep.int(bk.e$actual_bias, n_obs_GT),
                                                periodicity = rep.int(periodicity, n_obs_GT),
                                                date = paste(bk.e$ser_df_byGrp$year[bmk_info$t], 
                                                             sprintf("%06d", bk.e$ser_df_byGrp$period[bmk_info$t]), sep = "-"),
                                                subAnnual = s[bmk_info$t],
                                                benchmarked = theta[bmk_info$t],
                                                avgBenchmark = bmk_info$avg_a,
                                                avgSubAnnual = bmk_info$avg_s,
                                                subAnnualCorrected = s_b[bmk_info$t],
                                                benchmarkedSubAnnualRatio = ratio_func(theta[bmk_info$t], s[bmk_info$t]),
                                                avgBenchmarkSubAnnualRatio = ratio_func(bmk_info$avg_a, bmk_info$avg_s),
                                                growthRateSubAnnual = growthRate_func(s)[bmk_info$t],
                                                growthRateBenchmarked = growthRate_func(theta)[bmk_info$t],
                                                stringsAsFactors = FALSE)
                    
                    out_graphTable_df <- rbind(out_graphTable_df, cbind(bk.e$ser_df_byGrp[bmk_info$t, by, drop = FALSE],
                                                                        out_GT_df_var))
                    
                    # Remove the temporary constant
                    out_ser_df_byGrp[[var[jj]]] <- theta - constant
                    
                    # Results validation
                    if (neg_res_func(out_ser_df_byGrp[[var[jj]]], tol = -tolN)) {
                      warning("The benchmarked series contains negative values (threshold = ", format(tolN), ").\n",
                              call. = FALSE, immediate. = TRUE)
                      bk.e$warning_flag <- TRUE
                    }
                    binding_bmk_valid_func(bk.e$bmk_df_byGrp[[with[jj]]], out_ser_df_byGrp[bmk_per_id, var[jj], drop = TRUE], c_a,
                                           bmk_start, bmk_end, tol_parm, zero_tol = 0)
                  }
                }
              }
            }
          }
        }
      }
      
      # Cumulate the output series and benchmarks data frame info
      out_series_df <- rbind(out_series_df, out_ser_df_byGrp)
      out_benchmarks_df <- rbind(out_benchmarks_df, out_bmk_df_byGrp)
    }
  }
  
  
  # Create the output list
  row.names(out_series_df) <- NULL
  row.names(out_benchmarks_df) <- NULL
  row.names(out_graphTable_df) <- NULL
  row.names(out_splineKnots_df) <- NULL
  out_list <- list(series = out_series_df, 
                   benchmarks = out_benchmarks_df, 
                   graphTable = out_graphTable_df, 
                   splineKnots = out_splineKnots_df)
  
  
  # Display a final warning/error message for multiple series processing
  if (final_msg_flag) {
    if (bk.e$warning_flag) {
      warning("Warnings were generated during processing. See preceeding warning message(s) for details.\n",
              call. = FALSE, immediate. = TRUE)
    }
    # Non-muted error message (for proper condition catching by users of the function)
    if (try_error) {
      stop("Problems were encontered during processing. See preceeding error message(s) for details.\n\n",
           call. = FALSE)
    }
    
    # Display the error message for single-series processing
  } else if (try_error) {
    stop(try_error_msg, call. = FALSE)
  }
  
  # Output object returned via function `on.exit()`
}
