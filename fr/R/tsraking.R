################################################################################
#
# CAREFUL: this script contains translated (French) roxygen2 comments 
#          for other topics/functions further down below
#
################################################################################


#' Rétablir les contraintes d'agrégation transversales (contemporaines)
#'
#'
#' @description
#' _Réplication de la procédure TSRAKING de G-Séries 2.0 en SAS\eqn{^\circledR}{®} (PROC TSRAKING).
#' Voir la documentation de G-Séries 2.0 pour plus de détails (Statistique Canada 2016)._
#'
#' Cette fonction rétablit les contraintes d'agrégation transversales dans un système de séries chronologiques. 
#' Les contraintes d'agrégation peuvent provenir d'une table à 1 ou 2 dimensions. Optionnellement, des contraintes 
#' temporelles peuvent également être préservées.
#'
#' En pratique, [tsraking()] est généralement appelée à travers [tsraking_driver()] afin de réconcilier toutes 
#' les périodes du système de séries chronologiques en un seul appel de fonction.
#'
#'
#' @usage
#' tsraking(
#'   data_df,
#'   metadata_df,
#'   alterability_df = NULL,
#'   alterSeries = 1,
#'   alterTotal1 = 0,
#'   alterTotal2 = 0,
#'   alterAnnual = 0,
#'   tolV = 0.001,
#'   tolP = NA,
#'   warnNegResult = TRUE,
#'   tolN = -0.001,
#'   id = NULL,
#'   verbose = FALSE,
#'
#'   # Nouveau dans G-Séries 3.0
#'   Vmat_option = 1,
#'   warnNegInput = TRUE,
#'   quiet = FALSE
#' )
#'
#'
#' @param data_df (obligatoire)
#'
#' *Data frame*, ou objet compatible, qui contient les données des séries chronologiques à réconcilier. Il doit au minimum 
#' contenir des variables correspondant aux séries composantes et aux totaux de contrôle transversaux spécifiés dans le 
#' *data frame* des métadonnées de ratissage (argument `metadata_df`). Si plus d'un enregistrement (plus d'une période) est 
#' fournie, la somme des valeurs des séries composantes fournies sera également préservée à travers des contraintes 
#' temporelles implicites.
#'
#' @param metadata_df (obligatoire)
#'
#' *Data frame*, ou objet compatible, qui décrit les contraintes d'agrégation transversales (règles d'additivité) pour le 
#' problème de ratissage (« *raking* »). Deux variables de type caractère doivent être incluses dans le *data frame* : 
#' `series` et `total1`. Deux variables sont optionnelles : `total2` (caractère) et `alterAnnual` (numérique). Les valeurs 
#' de la variable `series` représentent les noms des variables des séries composantes dans le *data frame* des données 
#' d'entrée (argument `data_df`). De même, les valeurs des variables `total1` et `total2` représentent les noms des variables 
#' des totaux de contrôle transversaux de 1<sup>ère</sup> et 2<sup>ème</sup> dimension dans le *data frame* des données 
#' d'entrée. La variable `alterAnnual` contient le coefficient d'altérabilité pour la contrainte temporelle associée à 
#' chaque série composante. Lorsqu'elle est spécifiée, cette dernière remplace le coefficient d'altérabilité par défaut 
#' spécifié avec l'argument `alterAnnual`.
#'
#' @param alterability_df (optionnel)
#'
#' *Data frame*, ou objet compatible, ou `NULL`, qui contient les variables de coefficients d'altérabilité. Elles 
#' doivent correspondre à une série composante ou à un total de contrôle transversal, c'est-à-dire qu'une variable 
#' portant le même nom doit exister dans le *data frame* des données d'entrée (argument `data_df`). Les valeurs de 
#' ces coefficients d'altérabilité remplaceront les coefficients d'altérabilité par défaut spécifiés avec les arguments 
#' `alterSeries`, `alterTotal1` et `alterTotal2`. Lorsque le *data frame* des données d'entrée contient plusieurs 
#' enregistrements et que le *data frame* des coefficients d'altérabilité n'en contient qu'un seul, les coefficients 
#' d'altérabilité sont utilisés (répétés) pour tous les enregistrements du *data frame* des données d'entrée. Le 
#' *data frame* des coefficients d'altérabilité peut également contenir autant d'enregistrements que le *data frame* 
#' des données d'entrée.
#'
#' **La valeur par défaut** est `alterability_df = NULL` (coefficients d'altérabilité par défaut).
#'
#' @param alterSeries (optionnel)
#'
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut pour les valeurs des séries composantes. 
#' Il s'appliquera aux séries composantes pour lesquelles des coefficients d'altérabilité n'ont pas déjà été spécifiés 
#' dans le *data frame* des coefficients d'altérabilité (argument `alterability_df`).
#'
#' **La valeur par défaut** est `alterSeries = 1.0` (valeurs des séries composantes non contraignantes).
#'
#' @param alterTotal1 (optionnel)
#'
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut pour les totaux de contrôle transversaux 
#' de la 1<sup>ère</sup> dimension. Il s'appliquera aux totaux de contrôle transversaux pour lesquels des coefficients 
#' d'altérabilité n'ont pas déjà été spécifiés dans le *data frame* des coefficients d'altérabilité (argument 
#' `alterability_df`).
#'
#' **La valeur par défaut** est `alterTotal1 = 0.0` (totaux de contrôle transversaux de 1<sup>ère</sup> dimension 
#' contraignants).
#'
#' @param alterTotal2 (optionnel)
#'
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut pour les totaux de contrôle transversaux 
#' de la 2<sup>ème</sup> dimension. Il s'appliquera aux totaux de contrôle transversaux pour lesquels des coefficients 
#' d'altérabilité n'ont pas déjà été spécifiés dans le *data frame* des coefficients d'altérabilité (argument 
#' `alterability_df`).
#'
#' **La valeur par défaut** est `alterTotal2 = 0.0` (totaux de contrôle transversaux de 2<sup>ème</sup> dimension 
#' contraignants).
#'
#' @param alterAnnual (optionnel)
#'
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut pour les contraintes temporelles 
#' (ex., totaux annuels) des séries composantes. Il s'appliquera aux séries composantes pour lesquelles des 
#' coefficients d'altérabilité n'ont pas déjà été spécifiés dans le *data frame* des métadonnées de ratissage 
#' (argument `metadata_df`).
#'
#' **La valeur par défaut** est `alterAnnual = 0.0` (totaux de contrôle temporels contraignants).
#'
#' @param tolV,tolP (optionnel)
#'
#' Nombre réel non négatif, ou `NA`, spécifiant la tolérance, en valeur absolue ou en pourcentage, à utiliser 
#' lors du test ultime pour les totaux de contrôle contraignants (coefficient d'altérabilité de \eqn{0.0} pour 
#' les totaux de contrôle temporels ou transversaux). Le test compare les totaux de contrôle contraignants d'entrée 
#' avec ceux calculés à partir des séries composantes réconciliées (en sortie). Les arguments `tolV` et `tolP` ne 
#' peuvent pas être spécifiés tous les deux à la fois (l'un doit être spécifié tandis que l'autre doit être `NA`).
#'
#' **Exemple :** pour une tolérance de 10 *unités*, spécifiez `tolV = 10, tolP = NA`; pour une tolérance de 1%, 
#' spécifiez `tolV = NA, tolP = 0.01`.
#'
#' **Les valeurs par défaut** sont `tolV = 0.001` et `tolP = NA`.
#'
#' @param warnNegResult (optionnel)
#'
#' Argument logique (*logical*) spécifiant si un message d'avertissement doit être affiché lorsqu'une valeur négative 
#' créée par la fonction dans une série réconciliée (en sortie) est inférieure au seuil spécifié avec l'argument `tolN`.
#'
#' **La valeur par défaut** est `warnNegResult = TRUE`.
#'
#' @param tolN (optionnel)
#'
#' Nombre réel négatif spécifiant le seuil pour l'identification des valeurs négatives. Une valeur est considérée 
#' négative lorsqu'elle est inférieure à ce seuil.
#'
#' **La valeur par défaut** est `tolN = -0.001`.
#'
#' @param id (optionnel)
#'
#' Vecteur de chaînes de caractère (longueur minimale de 1), ou `NULL`, spécifiant le nom des variables additionnelles 
#' à transférer du *data frame* d'entrée (argument `data_df`) au *data frame* de sortie, c.-à-d., l'objet renvoyé par 
#' la fonction (voir la section **Valeur de retour**). Par défaut, le *data frame* de sortie ne contient que les 
#' variables énumérées dans le *data frame* des métadonnées de ratissage (argument `metadata_df`).
#'
#' **La valeur par défaut** est `id = NULL`.
#'
#' @param verbose (optionnel)
#'
#' Argument logique (*logical*) spécifiant si les informations sur les étapes intermédiaires avec le temps d'exécution 
#' (temps réel et non le temps CPU) doivent être affichées. Notez que spécifier l'argument `quiet = TRUE` annulerait 
#' l'argument `verbose`.
#'
#' **La valeur par défaut** est `verbose = FALSE`.
#'
#' @param Vmat_option (optionnel)
#'
#' Spécification de l'option pour les matrices de variance (\eqn{V_e} et \eqn{V_\epsilon}; voir la section **Détails**) :
#' | **Valeur** | **Description** |
#' | :-------: | :-------------- |
#' | `1` | Utiliser les vecteurs \eqn{x} et \eqn{g} dans les matrices de variance. |
#' | `2` | Utiliser les vecteurs \eqn{|x|} et \eqn{|g|} dans les matrices de variance. |
#' 
#' Voir Ferland (2016) et la sous-section **Arguments `Vmat_option` et `warnNegInput`** dans la section **Détails** pour 
#' plus d'informations.
#'
#' **La valeur par défaut** est `Vmat_option = 1`.
#' 
#' @param warnNegInput (optionnel)
#'
#' Argument logique (*logical*) spécifiant si un message d'avertissement doit être affiché lorsqu'une valeur négative 
#' plus petite que le seuil spécifié par l'argument `tolN` est trouvée dans le *data frame* des données d'entrée 
#' (argument `data_df`).
#'
#' **La valeur par défaut** est `warnNegInput = TRUE`.
#'
#' @param quiet (optionnel)
#'
#' Argument logique (*logical*) spécifiant s'il faut ou non afficher uniquement les informations essentielles telles 
#' que les messages d'avertissements et d'erreurs. Spécifier `quiet = TRUE` annulera également l'argument `verbose` et 
#' est équivalent à _envelopper_ votre appel à [tsraking()] avec [suppressMessages()].
#'
#' **La valeur par défaut** est `quiet = FALSE`.
#'
#'
#' @details
#' Cette fonction renvoie la solution des moindres carrés généralisés d'une variante spécifique, simple du modèle général 
#' de ratissage (*raking*) basé sur la régression proposé par Dagum et Cholette (Dagum et Cholette 2006). Le modèle, 
#' sous forme matricielle, est le suivant :
#' \deqn{\displaystyle
#' \begin{bmatrix} x \\ g \end{bmatrix} = 
#' \begin{bmatrix} I \\ G \end{bmatrix} \theta + 
#' \begin{bmatrix} e \\ \varepsilon \end{bmatrix}
#' }{[x; g] = [I; G] theta + [e; epsilion]}
#' où
#' * \eqn{x} est le vecteur des valeurs initiales des séries composantes.
#' * \eqn{\theta} est le vecteur des valeurs finales (réconciliées) des séries composantes.
#' * \eqn{e \sim \left( 0, V_e \right)}{e ~ (0, V_e)} est le vecteur des erreurs de mesure de \eqn{x} avec la matrice de 
#' covariance \eqn{V_e = \mathrm{diag} \left( c_x x \right)}{V_e = diag(c_x x)}, ou \eqn{V_e = \mathrm{diag} \left( \left| 
#' c_x x \right| \right)}{V_e = diag(|c_x x|)} quand l'argument `Vmat_option = 2`, où \eqn{c_x} est le vecteur des 
#' coefficients d'alterabilité de \eqn{x}.
#' * \eqn{g} est le vecteur des totaux de contrôle initiaux, incluant les totaux temporels des séries composantes (le cas 
#' échéant).
#' * \eqn{\varepsilon \sim (0, V_\varepsilon)}{epsilon ~ (0, V_epsilon)} est le vecteur des erreurs de mesure de \eqn{g} 
#' avec la matrice de covariance \eqn{V_\varepsilon = \mathrm{diag} \left( c_g g \right)}{V_epsilion = diag(c_g g)}, ou 
#' \eqn{V_\varepsilon = \mathrm{diag} \left( \left| c_g g \right| \right)}{V_epsilon = diag(|c_g g|)} quand l'argument  
#' `Vmat_option = 2`, où \eqn{c_g} est le vecteur des coefficients d'alterabilité de \eqn{g}.
#' * \eqn{G} est la matrice des contraintes d'agrégation, y compris les contraintes temporelles implicites (le cas échéant). 
#' 
#' La solution généralisée des moindres carrés est :
#'\deqn{\displaystyle 
#' \hat{\theta} = x + V_e G^{\mathrm{T}} \left( G V_e G^{\mathrm{T}} + V_\varepsilon \right)^+ \left( g - G x \right)
#' }{theta^hat = x + V_e G' (G V_e G' + V_epsilion)^{+} (g - G x)}
#' où \eqn{A^{+}} désigne l'inverse de Moore-Penrose de la matrice \eqn{A}.
#' 
#' [tsraking()] résout un seul problème de ratissage à la fois, c'est-à-dire, soit une seule période du système de séries 
#' chronologiques, ou un seul groupe temporel (ex., toutes les périodes d'une année donnée) lorsque la préservation des 
#' totaux temporels est requise. Plusieurs appels à [tsraking()] sont donc nécessaires pour réconcilier toutes les 
#' périodes du système de séries chronologiques. [tsraking_driver()] peut réaliser cela en un seul appel : il détermine 
#' commodément l'ensemble des problèmes à résoudre et génère à l'interne les appels individuels à [tsraking()].
#' 
######
# This subsection differs slightly between `tsraking()` and `tsbalancing` and is therefore maintained for both functions 
# (in both sets of roxygen2 comments) as opposed to being shared with `roxygen2 tag `@inheritSection`.
# => the "Temporal total preservation* paragraph is the SAME, however: keep them "in sync"!.
######
#' ## Coefficients d'altérabilité
#' Les coefficients d'altérabilité \eqn{c_x} et \eqn{c_g} représentent conceptuellement les erreurs de mesure associées aux 
#' valeurs d'entrée des séries composantes \eqn{x} et des totaux de contrôle \eqn{g} respectivement. Il s'agit de nombres réels 
#' non négatifs qui, en pratique, spécifient l'ampleur de la modification permise d'une valeur initiale par rapport aux autres 
#' valeurs. Un coefficients d'altérabilité de \eqn{0.0} définit une valeur fixe (contraignante), tandis qu'un coefficient 
#' d'altérabilité supérieur à \eqn{0.0} définit une valeur libre (non contraignante). L'augmentation du coefficient 
#' d'altérabilité d'une valeur initiale entraîne davantage de changements pour cette valeur dans les données réconciliées (en 
#' sortie) et, inversement, moins de changements lorsque l'on diminue le coefficient d'altérabilité. Les coefficients 
#' d'altérabilité par défaut sont \eqn{1.0} pour les valeurs des séries composantes et \eqn{0.0} pour les totaux de contrôle 
#' transversaux et, le cas échéant, les totaux temporels des séries composantes. Ces coefficients d'altérabilité par défaut 
#' entraînent une répartition proportionnelle des écarts entre les séries composantes. En fixant les coefficients d'altérabilité 
#' des séries composantes à l'inverse des valeurs initiales des séries composantes, on obtiendrait une répartition uniforme des 
#' écarts à la place. Des totaux *presque contraignants* peuvent être obtenus en pratique en spécifiant des coefficients 
#' d'altérabilité très petits (presque \eqn{0.0}) par rapport à ceux des séries composantes (non contraignantes). 
#' 
#' **La préservation des totaux temporels** fait référence au fait que les totaux temporels, le cas échéant, sont 
#' généralement conservés « aussi près que possible » de leur valeur initiale. Une *préservation pure* est obtenue par 
#' défaut avec des totaux temporels contraignants, tandis que le changement est minimisé avec des totaux temporels non 
#' contraignants (conformément à l'ensemble de coefficients d'altérabilité utilisés).
#' 
#' ## Arguments `Vmat_option` et `warnNegInput`
#' Ces arguments permettent une gestion alternative des valeurs négatives dans les données d'entrée, similaire à celle de 
#' [tsbalancing()]. Leurs valeurs par défaut correspondent au comportement de G-Séries 2.0 (PROC TSRAKING en 
#' SAS\eqn{^\circledR}{®}) pour lequel des options équivalentes ne sont pas définies. Ce dernier a été développé en présumant 
#' des « données d'entrée non négatives uniquement », à l'instar de PROC BENCHMARKING dans G-Séries 2.0 en 
#' SAS\eqn{^\circledR}{®} qui n'autorisait pas non plus les valeurs négatives avec l'étalonnage proportionnel, ce qui explique
#' l'avertissement « suspicious use of proportional raking » (*utilisation suspecte du ratissage proportionnel*) en présence 
#' de valeurs négatives avec PROC TSRAKING dans G-Series 2.0 et lorsque `warnNegInput = TRUE` (par défault). Cependant, le 
#' ratissage (proportionnel) en présence de valeurs négatives fonctionne généralement bien avec `Vmat_option = 2` et produit 
#' des solutions raisonnables et intuitives. Par exemple, alors que l'option par défaut `Vmat_option = 1` échoue à résoudre 
#' la contrainte `A + B = C` avec les données d'entrée `A = 2`, `B = -2`, `C = 1` et les coefficients d'altérabilité par défaut, 
#' `Vmat_option = 2` renvoie la solution (intuitive) `A = 2.5`, `B = -1.5`, `C = 1` (augmentation de 25% pour `A` et `B`). Voir 
#' Ferland (2016) pour plus de détails.
#' 
#' ## Traitement des valeurs manquantes (`NA`)
#' Une valeur manquante dans le *data frame* des données d'entrée (argument `data_df`) ou dans le *data frame* des 
#' coefficients d'altérabilité (argument `alterability_df`) pour n'importe quelle donnée du problème de ratissage (variables 
#' énumérées dans le *data frame* des métadonnées avec l'argument `metadata_df`) générera un message d'erreur et arrêtera 
#' l'exécution de la fonction.
#' 
#' 
#' @inheritSection tsbalancing Comparaison de [tsraking()] et [tsbalancing()]
#' 
#' 
#' @returns
#' La fonction renvoie un *data frame* contenant les séries composantes réconciliées, les totaux de contrôle transversaux 
#' réconciliés et les variables spécifiées avec l'argument `id`. Notez que l'objet « data.frame » peut être explicitement 
#' converti en un autre type d'objet avec la fonction `as*()` appropriée (ex., `tibble::as_tibble()` le convertirait en 
#' tibble).
#'
#'
#' @references Bérubé, J. and S. Fortier (2009). « PROC TSRAKING: An in-house SAS\eqn{^\circledR}{®} procedure for balancing 
#' time series ». Dans **JSM Proceedings, Business and Economic Statistics Section**. Alexandria, VA: American Statistical 
#' Association.
#'
#' @references Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal Distribution and Reconciliation Methods
#' of Time Series**. Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
#' 
#' @references Ferland, M. (2016). « Negative Values with PROC TSRAKING ». **Document interne**. Statistique Canada, Ottawa, 
#' Canada.
#' 
#' @references Fortier, S. and B. Quenneville (2009). « Reconciliation and Balancing of Accounts and Time Series ». 
#' Dans **JSM Proceedings, Business and Economic Statistics Section**. Alexandria, VA: American Statistical Association.
#'
#' @references Quenneville, B. and S. Fortier (2012). « Restoring Accounting Constraints in Time Series – Methods and
#' Software for a Statistical Agency ». **Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New York.
#'
#' @references Statistique Canada (2016). « La procédure TSRAKING ». **Guide de l'utilisateur de G-Séries 2.0**.
#' Statistique Canada, Ottawa, Canada.
#'
#' @references Statistique Canada (2018). **Théorie et application de la réconciliation (Code du cours 0437)**.
#' Statistique Canada, Ottawa, Canada.
#'
#'
#' @seealso [tsraking_driver()] [tsbalancing()] [rkMeta_to_blSpecs()] [gs.gInv_MP()] [build_raking_problem()] [aliases]
#'
#'
#' @example misc/function_examples/tsraking-ex.R
#'
#'
#' @export
tsraking <- function(data_df,
                     metadata_df,
                     alterability_df = NULL,
                     alterSeries = 1,
                     alterTotal1 = 0,
                     alterTotal2 = 0,
                     alterAnnual = 0,
                     tolV = 0.001,
                     tolP = NA,
                     warnNegResult = TRUE,
                     tolN = -0.001,
                     id = NULL,
                     verbose = FALSE,
                     
                     # New in G-Series 3.0
                     Vmat_option = 1,
                     warnNegInput = TRUE,
                     quiet = FALSE) {
  
  
  
  
  ### Internal functions ###
  
  
  # Binding totals validation functions according to (main function) arguments 'tolV' and 'tolP':
  #   - binding_tot_diff_valid   : tolV is specified (check differences against tolV)
  #   - binding_tot_relDiff_valid: tolP is specified (check relative differences against tolP)
  binding_tot_diff_valid <- function(g_in, g_out, c_g, tol, ...) {
    max_discr <- max(abs(g_out - g_in) * (c_g == 0))
    if (max_discr > tol) {
      warning("Binding totals are not met (maximum difference: ", format(max_discr), "). Inconsistencies ",
              "in the data are suspected.\n", call. = FALSE, immediate. = TRUE)
    }
    invisible(NULL)
  }
  binding_tot_relDiff_valid <- function(g_in, g_out, c_g, tol, zero_tol = gs.tolerance) {
    g_in[abs(g_in) <= zero_tol] <- NA
    max_discr <- max(abs(g_out / g_in - 1) * 100 * (c_g == 0))
    tol <- tol * 100
    if (max_discr > tol) {
      warning("Binding totals are not met (maximum relative difference: ", format(max_discr), "%). Inconsistencies ",
              "in the data are suspected.\n", call. = FALSE, immediate. = TRUE)
    }
    invisible(NULL)
  }
  
  
  
  
  ### Main function ###
  
  start_time <- Sys.time()
  start_time0 <- start_time
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt))
  options(error = NULL)
  
  # Validate argument `quiet` and implement the quiet setting
  quiet <- gs.validate_arg_logi(quiet)
  if (quiet) {
    quiet_msg_func <- gs.NULL_func
    quiet_lab <- ""  # won't be displayed anyway
  } else {
    quiet_msg_func <- message
    quiet_lab <- "    (*)quiet        = FALSE (default)"
  }
  
  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\ntsraking() function:\n")
  
  
  # Initial argument validation
  
  # Mandatory arguments (without default values)
  data_df_name <- deparse1(substitute(data_df))
  tmp <- nchar(data_df_name)
  if (tmp == 0) {
    stop("Argument 'data_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    data_df_name <- paste0(substr(data_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", data_df_name, fixed = TRUE)) {
    data_df_name <- "<argument 'data_df'>"
  }
  data_df <- data_df
  if (!is.data.frame(data_df)) {
    stop("Argument 'data_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  data_df <- as.data.frame(data_df)
  row.names(data_df) <- NULL
  metadata_df_name <- deparse1(substitute(metadata_df))
  tmp <- nchar(metadata_df_name)
  if (tmp == 0) {
    stop("Argument 'metadata_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    metadata_df_name <- paste0(substr(metadata_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", metadata_df_name, fixed = TRUE)) {
    metadata_df_name <- "<argument 'metadata_df'>"
  }
  metadata_df <- metadata_df
  if (!is.data.frame(metadata_df)) {
    stop("Argument 'metadata_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  metadata_df <- as.data.frame(metadata_df)
  row.names(metadata_df) <- NULL
  
  # Column names in 'data_df' are case sensitive (e.g. 'metadata_df' values must reflect the correct "casing")
  # Column names in 'metadata_df' are NOT case sensitive (e.g. "Series", "series" and "SERIES" are all valid)
  dataDF_cols <- names(data_df)
  metaDF_cols <- toupper(names(metadata_df))
  names(metadata_df) <- metaDF_cols
  P <- nrow(data_df)  # number of periods
  
  # Alterability coefficients data frame (optional argument `alterability_df`)
  alterDF_lab <- "    alterability_df ="
  dup_alter_msg <- ""
  if (!is.null(alterability_df) && P > 0) {
    alter_df_name <- deparse1(substitute(alterability_df))
    if (alter_df_name >= 60) {
      alter_df_name <- paste0(substr(alter_df_name, 1, 55), "<...>")
    }
    if (grepl("structure(", alter_df_name, fixed = TRUE)) {
      alter_df_name <- "<argument 'alterability_df'>"
    }
    alterability_df <- alterability_df
    if (!is.data.frame(alterability_df)) {
      # Accept `alterability_df = NA` as `alterability_df = NULL`
      tmp <- (unlist(alterability_df))[1]
      if (!identical(alterability_df, tmp) || !is.na(tmp)) {
        warning("Argument 'alterability_df' is not a 'data.frame' object. It will be ignored.\n",
                call. = FALSE, immediate. = TRUE)
      }
      alterability_df <- NULL
      alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
      
    } else {
      alterability_df <- as.data.frame(alterability_df)
      n_perAlter <- nrow(alterability_df)
      if (n_perAlter == 0) {
        alterability_df <- NULL
        alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
        
      } else if (n_perAlter != 1 && n_perAlter != P) {
        warning("The alterability data frame (argument 'alterability_df') must contain either a single row ",
                "or as many rows as the input series data frame. It will be ignored.\n",
                call. = FALSE, immediate. = TRUE)
        alterability_df <- NULL
        alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
        
      } else {
        
        # Duplicate the alterability coefficients
        if (n_perAlter == 1 && P > 1) {
          alterability_df <- alterability_df[rep(1, P), , drop = FALSE]
          dup_alter_msg <- paste0("\nThe alterability data frame contains only one observation (row). The ",
                                  "coefficients will be reused for every row of the input series data frame.\n")
        } else {
          
        }
        row.names(alterability_df) <- NULL
        alterDF_lab <- paste(alterDF_lab, alter_df_name)
      }
    }
  } else {
    alterDF_lab <- paste0(alterDF_lab, " NULL (default)")
  }
  
  # Other optional arguments
  tmp <- (unlist(alterSeries))[1]
  if (!identical(alterSeries, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterSeries' must be a nonnegative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(alterTotal1))[1]
  if (!identical(alterTotal1, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterTotal1' must be a nonnegative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(alterTotal2))[1]
  if (!identical(alterTotal2, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterTotal2' must be a nonnegative real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(alterAnnual))[1]
  if (!identical(alterAnnual, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
    stop("Argument 'alterAnnual' must be a nonnegative real number.\n\n", call. = FALSE)
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
  id <- gs.cleanup_col_list(id)
  if (length(id) == 0) {
    id_lab <- "    id              = NULL (default)"
    id <- NULL
  } else {
    gs.validate_cols(id, dataDF_cols, data_df_name, source_str = "argument 'id'")
    id_lab <- paste0("    id              = ", paste(id, collapse = " "))
  }
  verbose <- gs.validate_arg_logi(verbose)
  tmp <- (unlist(Vmat_option))[1]
  if (!identical(Vmat_option, tmp) || is.null(tmp) || !(tmp %in% 1:2)) {
    stop("Argument 'Vmat_option' must take value 1 or 2.\n\n", call. = FALSE)
  }
  Vmat_option <- as.integer(Vmat_option)
  warnNegInput <- gs.validate_arg_logi(warnNegInput)
  # Argument `quiet` was already validated
  
  # Implement the verbose setting
  if (verbose && !quiet) {
    verbose_func <- gs.display_difftime
    verbose_lab <- "    verbose         = TRUE"
  } else {
    verbose_func <- gs.NULL_func
    verbose_lab <- "    verbose         = FALSE (default)"
  }
  
  # Negative results validation function and validate the binding total tolerances
  if (warnNegResult) {
    neg_res_func <- gs.check_neg
    warnNegResult_lab <- "    warnNegResult   = TRUE (default)"
  } else {
    neg_res_func <- gs.FALSE_func
    warnNegResult_lab <- "    warnNegResult   = FALSE"
  }
  if (!is.na(tolV)) {
    if (!is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both specified (one must be NA).\n\n", call. = FALSE)
    }
    binding_tot_valid_func <- binding_tot_diff_valid
    tol_parm <- tolV
    tol_lab <- paste0("    tolV            = ", format(tolV))
    if (abs(tolV - 0.001) < gs.tolerance) {
      tol_lab <- paste0(tol_lab, " (default)")
    }
  } else {
    if (is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both NA (one must be specified).\n\n", call. = FALSE)
    }
    binding_tot_valid_func <- binding_tot_relDiff_valid
    tol_parm <- tolP
    tol_lab <- paste0("    tolP            = ", format(tolP))
  }
  
  
  # Display the function call (argument values)
  quiet_msg_func("    data_df         = ", data_df_name)
  quiet_msg_func("    metadata_df     = ", metadata_df_name)
  quiet_msg_func(alterDF_lab)
  lab <- paste0("    alterSeries     = ", format(alterSeries))
  if (alterSeries == 1) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    alterTotal1     = ", format(alterTotal1))
  if (alterTotal1 == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    alterTotal2     = ", format(alterTotal2))
  if (alterTotal2 == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    alterAnnual     = ", format(alterAnnual))
  if (alterAnnual == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(tol_lab)
  quiet_msg_func(warnNegResult_lab)
  lab <- paste0("    tolN            = ", format(tolN))
  if (tolN == -0.001) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(id_lab)
  quiet_msg_func(verbose_lab, "\n")
  lab <- paste0("    (*)Vmat_option  = ", format(Vmat_option))
  if (Vmat_option == 1) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    (*)warnNegInput = ", format(warnNegInput))
  if (warnNegInput) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(quiet_lab, "\n")
  quiet_msg_func("    (*) indicates new arguments in G-Series 3.0\n")
  quiet_msg_func(dup_alter_msg)
  
  verbose_func(start_time, Sys.time(), "Set up phase")
  start_time <- Sys.time()
  
  # Return the (empty) input series data frame
  if (P == 0) {
    out_df <- data_df 
    
    # Attempt to reconcile the input series data frame
  } else {
    
    # Build the elements of the raking problem (while validating the specified info), 
    # excluding the component series temporal totals info (will be added later):
    #   - x        : vector of component series initial values
    #   - c_x      : vector of component series alterability coefficients
    #   - comp_cols: vector of component series (column) names 
    #   - g        : vector of marginal total series initial values
    #   - c_g      : vector of marginal total series alterability coefficients
    #   - tot_cols : vector of marginal total series (column) names 
    #   - G        : marginal total series aggregation matrix (`g = G %*% x` for coherent/reconciled data)
    #
    # Notes: 
    #
    #   - The returned raking problem elements do not include the implicit component series temporal totals 
    #     when applicable (i.e., elements `g` and `G` only contain the marginal totals info).
    #
    #   - When the input data contains multiple periods (temporal total preservation scenario), raking problem 
    #     elements `x`, `c_x`, `g`, `c_g` and `G` are constructed in "column-major order", corresponding to the 
    #     default behaviour of R for converting matrices into vectors.
    #
    rk <- build_raking_problem(data_df          = data_df,
                               metadata_df      = metadata_df,
                               data_df_name     = data_df_name,
                               metadata_df_name = metadata_df_name,
                               alterability_df  = alterability_df,
                               alterSeries      = alterSeries, 
                               alterTotal1      = alterTotal1,
                               alterTotal2      = alterTotal2)
    
    n_comp <- length(rk$comp_cols)  # number of component series
    K <- length(rk$x)               # number of component series data points
    n_tot <- length(rk$tot_cols)    # number of marginal total series
    L <- length(rk$g)               # number of marginal total series data points
    
    
    # Validate the problem data
    if (any(!is.finite(rk$x)) || any(!is.finite(rk$g))) {
      stop("The input series data frame (argument 'data_df') contains invalid or NA values.\n\n",
           call. = FALSE)
    }
    if (gs.check_alter(rk$c_x) || gs.check_alter(rk$c_g)) {
      stop("The alterability data frame (argument 'alterability_df') contains invalid or NA values.\n\n",
           call. = FALSE)
    }
    if (warnNegInput) {
      if (gs.check_neg(rk$x, tol = 0) || gs.check_neg(rk$g, tol = 0)) {
        warning("The input series data frame (argument 'data_df') contains negative values. ",
                "Suspicious use of proportional raking.\n", call. = FALSE, immediate. = TRUE)
      }
    }
    
    
    # Process component series temporal totals info
    # (update aggregation matrix `G`, total data vector `g` and total alter coefs vector `c_g`
    # to include temporal totals)
    #
    # Note: count `L` is not updated here; it remains `n_tot * P`, i.e. the number of elements
    #       in vectors `g` and `c_g` associated to marginal (contemporaneous) totals only (excluding
    #       temporal totals). In other words, `L < length(g)` when `P > 1`
    if (P > 1) {
      Y <- matrix(0, nrow = n_comp, ncol = K)
      for (ii in 1:n_comp) {
        Y[ii, ((ii - 1) * P + 1):(ii * P)] <- 1
      }
      rk$G <- rbind(rk$G, Y)
      rk$g <- c(rk$g, Y %*% rk$x)
      
      if ("ALTERANNUAL" %in% metaDF_cols) {
        # Note: missing (NA) values are allowed for user-defined temporal total alter coefs (in the metadata file),
        #       but not for the component series and marginal (contemporaneous) totals (in the alterability file)
        #       in SAS G-Series PROC TSRAKING. I don't have a good  explanation for this (!)
        tmp <- metadata_df$ALTERANNUAL
        if (gs.check_alter(tmp[!is.na(tmp)])) {
          stop("Column 'alterAnnual' in the input metadata data frame (argument 'metadata_df') contains invalid values.\n\n",
               call. = FALSE)
        }
        tmp[is.na(tmp)] <- alterAnnual
        rk$c_g <- c(rk$c_g, tmp)
      } else {
        rk$c_g <- c(rk$c_g, rep(alterAnnual, n_comp))
      }
    }
    
    verbose_func(start_time, Sys.time(), "Metadata processing")
    start_time <- Sys.time()
    start_time1 <- start_time
    
    
    # Solve the raking problem (unless there's no discrepancies)
    discr_ini <- rk$g - rk$G %*% rk$x
    if (any(abs(discr_ini) > gs.min_tolerance)) {
      
      # Diagonal elements of the variance matrices (V_e and V_eps)
      if (Vmat_option == 1) {
        V_e <- rk$c_x * rk$x
        V_eps <- rk$c_g * rk$g
        mean_Ve <- mean(V_e)
        V_factor <- mean(abs(V_e))
      } else {
        V_e <- rk$c_x * abs(rk$x)
        V_eps <- rk$c_g * abs(rk$g)
        mean_Ve <- mean(V_e)
        V_factor <- mean_Ve
      }
      
      
      # Solve the raking problem
      if (mean_Ve != 0) {
        
        # Rescaled variance matrices (rescaling helps with the inverse calculation)
        # Note: `V_factor != 0` if `mean_Ve != 0`, regardless of argument `Vmat_option`
        V_e <- diag(V_e / V_factor, nrow = K)
        V_eps <- diag(V_eps / V_factor, nrow = length(rk$g))
        
        verbose_func(start_time, Sys.time(), "Variance matrices construction (V_e and V_eps)")
        start_time <- Sys.time()
        
        V_c <- V_e %*% t(rk$G)
        verbose_func(start_time, Sys.time(), "V_c = V_e * t(G)")
        start_time <- Sys.time()
        
        # Report totals for which all component series are binding (i.e. deterministic totals)
        # => may help users identify the cause of binding totals that can't be met (when applicable)
        all_binding_id <- which(colSums(V_c[, 1:L, drop = FALSE] == 0) == K)
        if (length(all_binding_id) > 0) {
          if (P == 1) {
            quiet_msg_func("All component series are binding (non alterable) for the following totals:",
                           paste0("\n  ", rk$tot_cols[all_binding_id], collapse = ""), "\n")
          } else {
            tot_id <- (all_binding_id - 1) %/% P + 1
            per_id <- (all_binding_id - 1) %% P + 1
            # `sapply()` is safe: it will always returns a character vector of length minimum 1
            quiet_msg_func("All component series are binding (non alterable) for the following totals (applicable periods in brackets):",
                           paste0("\n  ", 
                                  sapply(unique(tot_id),
                                         function(x) {
                                           paste0(rk$tot_cols[x],
                                                  "[",
                                                  paste0(per_id[which(tot_id == x)], collapse = ", "),
                                                  "]")  
                                         }), 
                                  collapse = ""),
                           "\n")
          }
        }
        verbose_func(start_time, Sys.time(), "Deterministic totals check")
        start_time <- Sys.time()
        
        V_d <- rk$G %*% V_c + V_eps
        verbose_func(start_time, Sys.time(), "V_d = G * V_c + V_eps")
        start_time <- Sys.time()
        
        V_d_inv <- gs.gInv_MP(V_d)
        verbose_func(start_time, Sys.time(), "Inverse V_d")
        start_time <- Sys.time()
        
        x_out <- rk$x + V_c %*% V_d_inv %*% discr_ini
        verbose_func(start_time, Sys.time(), "Solution = x + V_c * Inv(V_d) * (g - G * x)")
        verbose_func(start_time1, Sys.time(), "Total problem solving")
        start_time <- Sys.time()
        
        # Just for safety: `x_out` could contain `NaN` values in very extreme cases (matrix inversion problems)...
        if (any(!is.finite(x_out))) {
          warning("Unable to solve the raking problem. Returning the input component series data (and resulting totals).\n",
                  call. = FALSE, immediate. = TRUE)
          x_out <- rk$x
        }
        
        
        # Unsolvable (fixed) raking problem (sum of the elements of the component series variance matrix `V_e` is zero)
      } else {
        
        if (V_factor == 0) {
          if (P == 1) {
            quiet_msg_func("All component series are binding (non alterable). Nothing to solve. ",
                           "Returning the input component series data (and resulting totals).\n")
          } else {
            quiet_msg_func("All component series are binding (non alterable) for all periods. Nothing to solve. ",
                           "Returning the input component series data (and resulting totals).\n")
          }
          
          # May happen in presence of negative values in the input data with `Vmat_option = 1`
          # (impossible with `Vmat_option = 2`)
        } else {
          warning("Unsolvable raking problem. Returning the input component series data (and resulting totals).\n", call. = FALSE,
                  immediate. = TRUE)
        }
        x_out <- rk$x
        
        verbose_func(start_time, Sys.time(), "Problem feasibility checking")
        start_time <- Sys.time()
      }
      
      
      # (Re)calculate the totals
      g_out <- rk$G %*% x_out
      
      
      # Return the initial values (no initial discrepancies)
    } else {
      x_out <- rk$x
      g_out <- rk$g
      verbose_func(start_time, Sys.time(), "Solution = initial values (no discrepancy)")
      start_time <- Sys.time()
    }
    
    
    # Results validation
    if (neg_res_func(c(x_out, g_out), tol = -tolN)) {
      warning("The reconciled data contains negative values (threshold = ", format(tolN), ").\n", call. = FALSE,
              immediate. = TRUE)
    }
    binding_tot_valid_func(rk$g, g_out, rk$c_g, tol_parm, zero_tol = 0)
    
    verbose_func(start_time, Sys.time(), "Results validation")
    start_time <- Sys.time()
    
    
    # Create the output (series) data frame
    
    # Initialize with the input series data
    out_cols <- intersect(dataDF_cols, c(rk$comp_cols, rk$tot_cols, id))
    out_df <- data_df[out_cols]
    
    # Update the component series
    out_df[rk$comp_cols] <- as.data.frame(matrix(x_out, ncol = n_comp))
    
    # Update the marginal total(s)
    #   => exclude the temporal totals at the end of `g_out` (when applicable)
    out_df[rk$tot_cols] <- as.data.frame(matrix(g_out[1:L], ncol = n_tot))
    
    verbose_func(start_time, Sys.time(), "Wrap up phase")
  }
  
  verbose_func(start_time0, Sys.time(), "Total execution time")
  out_df
}


#' Construire les éléments du problème de ratissage.
#'
#' @description
#' Cette fonction est utilisée à l'interne par [tsraking()] pour construire les éléments du problème de ratissage. Elle peut 
#' également être utile pour dériver manuellement les totaux transversaux (des marges) du problème de ratissage (en dehors du 
#' contexte de [tsraking()]).
#' 
#' 
#' @inheritParams tsraking
#'
#' @param data_df_name (optionnel) 
#' 
#' Chaîne de caractères contenant la valeur de l'argument `data_df`.
#'
#' **La valeur par défaut** est `data_df_name = deparse1(substitute(data_df))`.
#' 
#' @param metadata_df_name (optionnel)
#' 
#' Chaîne de caractères contenant la valeur de l'argument `metadata_df`.
#'
#' **La valeur par défaut** est `data_df_name = deparse1(substitute(metadata_df))`.
#'
#'
#' @returns
#' Une liste avec les éléments du problème de ratissage (excluant les totaux temporels implicites) :
#' - `x`         : vecteur des valeurs initiales des séries composantes
#' - `c_x`       : vecteur des coefficients d'altérabilité des séries composantes
#' - `comp_cols` : vecteur des noms des séries composantes (colonnes de `data_df`)
#' - `g`         : vecteur des valeurs initiales des totaux transversaux
#' - `c_g`       : vecteur des coefficients d'altérabilité des totaux transversaux
#' - `tot_cols`  : vecteur des noms des totaux transversaux (colonnes de `data_df`)
#' - `G`         : matrice d'agrégation des totaux transversaux (`g = G %*% x`)
#'
#'
#' @details
#' Voir [tsraking()] pour une description détaillée des problèmes de _ratissage de séries chronologiques_.
#' 
#' Les éléments du problème de ratissage renvoyés n'incluent pas les totaux temporels implicites des séries de 
#' composantes, le cas échéant (c.-à-d., les éléments `g` et `G` ne contiennent que l'information sur les totaux 
#' transversaux).
#' 
#' Lorsque les données d'entrée contiennent plusieurs périodes (scénario de préservation des totaux temporels), 
#' les éléments `x`, `c_x`, `g`, `c_g` et `G` du problème de ratissage sont construits _colonne par colonne_ 
#' (selon le principe « column-major order » en anglais), ce qui correspond au comportement par défaut de R lors 
#' de la conversion d'objets de la classe « matrix » en vecteurs.
#'
#'
#' @seealso [tsraking()] [build_balancing_problem()]
#' 
#' @example misc/function_examples/build_raking_problem-ex.R
#' 
#' @export
build_raking_problem <- function(data_df,
                                 metadata_df,
                                 data_df_name = deparse1(substitute(data_df)),
                                 metadata_df_name = deparse1(substitute(metadata_df)),
                                 alterability_df = NULL,
                                 alterSeries = 1, 
                                 alterTotal1 = 0,
                                 alterTotal2 = 0) {
  
  
  # Alterability data frame creation function, taking into account both the specified
  # default (arguments `alter...`) and user-defined coefs (argument `alterability_df`)
  #
  # Main (parent) function objects used by the function (expected to exist):
  #  - P              : number of periods in the raking problem
  #  - alterability_df: user-defined alterability copefficients data frame
  #  - alterDF_cols   : list of column names of data frame `alterability_df` 
  #                     (`alterDF_cols == NULL` when `alterability_df == NULL`)
  create_alterDF <- function(cols, default_coef) {
    
    # Start with the default alter coefs
    default_cols <- setdiff(cols, alterDF_cols)
    alter_df <- as.data.frame(matrix(rep(default_coef, length(default_cols) * P),
                                     nrow = P,
                                     dimnames = list(NULL, default_cols)))
    
    # Add the user-defined alter coefs
    user_cols <- intersect(cols, alterDF_cols)
    if (length(user_cols) > 0) {
      alter_df <- cbind(alter_df, alterability_df[user_cols])
    }
    
    alter_df[cols]
  }
  
  
  ### Main function ###
  
  # Create the vectors of column names and other elementary objects
  dataDF_cols <- names(data_df)
  metaDF_cols <- toupper(names(metadata_df))
  names(metadata_df) <- metaDF_cols
  alterDF_cols <- names(alterability_df)
  P <- nrow(data_df)           # number of periods
  n_comp <- nrow(metadata_df)  # number of component series
  
  
  # Validate the metadata and build the raking problem matrices and vectors
  
  if (n_comp == 0) {
    stop("The input metadata data frame (argument 'metadata_df') must contain at least one observation (row).\n\n", 
         call. = FALSE)
  }
  gs.validate_cols(tolower(setdiff(c("SERIES", "TOTAL1"), metaDF_cols)), NULL, metadata_df_name)
  
  
  # Process component series info
  
  comp_cols <- gs.cleanup_col_list(metadata_df$SERIES)
  if (n_comp != length(comp_cols)) {
    stop("Column 'series' in the input metadata data frame (argument 'metadata_df') contains missing (NA) or blank (\"\") values.\n\n",
         call. = FALSE)
  }
  if (n_comp > length(unique(comp_cols))) {
    stop("Column 'series' in the input metadata data frame (argument 'metadata_df') contains duplicate values.\n\n",
         call. = FALSE)
  }
  gs.validate_cols(comp_cols, dataDF_cols, data_df_name, source_str = "metadata column 'series'")
  
  # Component series data vector `x` (column-major version of the input series data frame)
  x <- unlist(data_df[comp_cols], use.names = FALSE)
  K <- length(x)  # number of component series data points
  
  # Component series alter coef vector c_x (column-major version of the alter coef data frame data)
  c_x <- unlist(create_alterDF(comp_cols, alterSeries), use.names = FALSE)
  
  
  # Process marginal (contemporaneous) totals info
  
  temp <- gs.cleanup_col_list(metadata_df$TOTAL1)
  if (n_comp != length(temp)) {
    stop("Column 'total1' in the input metadata data frame (argument 'metadata_df') contains missing (NA) ", 
         "or blank (\"\") values.\n\n", call. = FALSE)
  }
  tot1_cols <- unique(temp)
  gs.validate_cols(tot1_cols, dataDF_cols, data_df_name, source_str = "metadata column 'total1'")
  N <- length(tot1_cols)
  tot_cols <- tot1_cols
  
  if ("TOTAL2" %in% metaDF_cols) {
    temp <- gs.cleanup_col_list(metadata_df$TOTAL2)
    if (length(temp) > 0) {
      if (n_comp != length(temp)) {
        stop("Column 'total2' in the input metadata data frame (argument 'metadata_df') contans missing (NA) ", 
             "or blank (\"\") values.\n\n", call. = FALSE)
      }
      tot2_cols <- unique(temp)
      M <- length(tot2_cols)
      if (M == 1) {
        stop("Column 'total2' in the input metadata data frame (argument 'metadata_df') defines a single dim. 2 total. ",
             "It should either be removed from the data frame for a 1-dimensional raking problem or be used to define ",
             "multiple dim. 2 totals for a 2-dimensional problem.\n\n", call. = FALSE)
      }
      gs.validate_cols(tot2_cols, dataDF_cols, data_df_name, source_str = "metadata column 'total2'")
      tot_cols <- c(tot_cols, tot2_cols)
    } else {
      tot2_cols <- NULL
      M <- 1
    }
  } else {
    tot2_cols <- NULL
    M <- 1
  }
  
  
  # Initialize aggregation matrix `G` and data vector `g` for the marginal totals
  
  # 1-dim raking (single marginal total): order of the component series doesn't matter
  if (M == 1) {
    if (length(tot_cols) != 1) {
      stop("Column 'total1' in the input metadata data frame (argument 'metadata_df') defines multiple totals ",
           "while a single total is expected in a 1-dimensional raking problem.\n\n", call. = FALSE)
    }
    n_tot <- 1
    L <- P
    
    # For each component series corresponds P rows and columns in matrix `G`
    G <- matrix(rep(diag(1, nrow = P), n_comp), nrow = P)
    
    # Totals alter coef vector c_g (column-major version of the alter coef data frame data)
    c_g <- unlist(create_alterDF(tot_cols, alterTotal1), use.names = FALSE)
    
    # 2-dim raking (multiple marginal totals): order of the component series is important (!)
  } else {
    if (n_comp < M * N) {
      stop("Incomplete specification of a 2-dimensional raking problem in the input metadata data frame ",
           "(argument 'metadata_df'). Some dim. 1 and dim. 2 total combinations (columns 'total1' and 'total2') ",
           "are missing from the data frame (have not been assigned a component series).\n\n", call. = FALSE)
    }
    if (any(duplicated(metadata_df[c("TOTAL1", "TOTAL2")], MARGIN = 1))) {
      stop("Invalid specification of a 2-dimensional raking problem in the input metadata data frame ",
           "(argument 'metadata_df'). Some dim. 1 and dim. 2 total combinations (columns 'total1' and 'total2') ",
           "appear more than once in the data frame (have been assigned more than one component series).\n\n",
           call. = FALSE)
    }
    n_tot <- M + N
    L <- n_tot * P
    
    # For each component series corresponds P rows and columns in matrix `G`
    # Initialize `G` with 0's
    G <- matrix(0, nrow = L, ncol = K)
    
    # 1st dim. totals aggregation vectors (update `G` with 1's in the right place)
    for (ii in 1:N) {
      # kk, the row number in the metadata data frame, represents column number(s) in matrix `G`.
      kk <- which(metadata_df$TOTAL1 == tot_cols[ii])
      for (jj in 1:P) {
        G[(ii - 1) * P + jj, (kk - 1) * P + jj] <- 1
      }
    }
    
    # 2nd dim. totals aggregation vectors (update `G` with 1's in the right place)
    for (ii in 1:M + N) {
      # same as for TOTAL1
      kk <- which(metadata_df$TOTAL2 == tot_cols[ii])
      for (jj in 1:P) {
        G[(ii - 1) * P + jj, (kk - 1) * P + jj] <- 1
      }
    }
    
    # Totals alter coef vector c_g (column-major version of the alter coef data frame data)
    c_g <- c(unlist(create_alterDF(tot1_cols, alterTotal1), use.names = FALSE),
             unlist(create_alterDF(tot2_cols, alterTotal2), use.names = FALSE))
  }
  
  # Totals data vector `g` (column-major version of the input series data frame data)
  g <- unlist(data_df[tot_cols], use.names = FALSE)
  
  
  # Return the raking problem elements
  list(x = x,
       c_x = c_x,
       comp_cols = comp_cols,
       g = g,
       c_g = c_g,
       tot_cols = tot_cols,
       G = G)
}
