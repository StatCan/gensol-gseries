#' Rétablir les contraintes temporelles
#'
#'
#' @description
#' _Réplication de la procédure BENCHMARKING de G-Séries 2.0 en SAS\eqn{^\circledR}{®} (PROC BENCHMARKING).
#' Voir la documentation de G-Séries 2.0 pour plus de détails (Statistique Canada 2016)._
#'
#' Cette fonction assure la cohérence entre les données de séries chronologiques d'une même variable cible mesurée à des
#' fréquences différentes (ex., infra-annuellement et annuellement). L'étalonnage consiste à imposer le niveau de la série 
#' d'étalons (ex., données annuelles) tout en minimisant, autant que possible, les révisions au mouvement observé dans 
#' la série indicatrice (ex., données infra-annuelles). La fonction permet également l'étalonnage non contraignant où 
#' la série d'étalons peut également être révisée.
#'
#' La fonction peut également être utilisée pour des sujets liés à l'étalonnage tels que la *distribution temporelle*
#' (action réciproque de l'étalonnage : désagrégation de la série d'étalons en observations plus fréquentes), la 
#' *calendarisation* (cas spécial de distribution temporelle) et le *raccordement* (« *linking* » : connexion de différents 
#' segments de séries chronologiques en une série chronologique unique et cohérente).
#'
#' Plusieurs séries peuvent être étalonnées en un seul appel de fonction.
#' 
#'
#' @usage
#' benchmarking(
#'   series_df,
#'   benchmarks_df,
#'   rho,
#'   lambda,
#'   biasOption,
#'   bias = NA,
#'   tolV = 0.001,
#'   tolP = NA,
#'   warnNegResult = TRUE,
#'   tolN = -0.001,
#'   var = "value",
#'   with = NULL,
#'   by = NULL,
#'   verbose = FALSE,
#'
#'   # Nouveau dans G-Séries 3.0
#'   constant = 0,
#'   negInput_option = 0,
#'   allCols = FALSE,
#'   quiet = FALSE
#' )
#'
#'
#' @param series_df (obligatoire)
#'
#' *Data frame*, ou objet compatible, qui contient les données de la (des) série(s) indicatrice(s) à étalonner. En plus de 
#' la (des) variable(s) contenant les données, spécifiée(s) avec l'argument `var`, le *data frame* doit aussi contenir deux 
#' variables numériques, `year` et `period`, identifiant les périodes des séries indicatrices.
#'
#' @param benchmarks_df (obligatoire)
#'
#' *Data frame*, ou objet compatible, qui contient les étalons. En plus de la (des) variable(s) contenant les données, 
#' spécifiée(s) avec l'argument `with`, le *data frame* doit aussi contenir quatre variables numériques, `startYear`, 
#' `startPeriod`, `endYear` et `endPeriod`, identifiant les périodes des séries indicatrices couvertes par chaque étalon.
#'
#' @param rho (obligatoire)
#'
#' Nombre réel compris dans l'intervalle \eqn{[0,1]} qui spécifie la valeur du paramètre autorégressif \eqn{\rho}. 
#' Voir la section **Détails** pour plus d'informations sur l'effet du paramètre \eqn{\rho}.
#'
#' @param lambda (obligatoire)
#'
#' Nombre réel, avec des valeurs suggérées dans l'intervalle \eqn{[-3,3]}, qui spécifie la valeur du paramètre du modèle 
#' d'ajustement \eqn{\lambda}. Les valeurs typiques sont `lambda = 0.0` pour un modèle additif et `lambda = 1.0` pour un 
#' modèle proportionnel.
#'
#' @param biasOption (obligatoire)
#'
#' Spécification de l'option d'estimation du biais :
#' 
#' * `1` : Ne pas estimer le biais. Le biais utilisé pour corriger la série indicatrice sera la valeur 
#' spécifiée avec l'argument `bias`.
#' * `2` : Estimer le biais, afficher le résultat, mais ne pas l'utiliser. Le biais utilisé pour corriger 
#' la série indicatrice sera la valeur spécifiée avec l'argument `bias`.
#' * `3` : Estimer le biais, afficher le résultat et utiliser le biais estimé pour corriger la série indicatrice. 
#' Toute valeur spécifiée avec l'argument `bias` sera ignorée.
#'
#' L'argument `biasOption` n'est pas utilisé quand `rho = 1.0`. Voir la section **Détails** pour plus d'informations sur 
#' le biais.
#'
#' @param bias (optionnel)
#'
#' Nombre réel, ou `NA`, spécifiant la valeur du biais défini par l'utilisateur à utiliser pour la correction de la série 
#' indicatrice avant de procéder à l'étalonnage. Le biais est ajouté à la série indicatrice avec un modèle additif
#' (argument `lambda = 0.0`) alors qu'il est multiplié dans le cas contraire (argument `lambda != 0.0`). Aucune correction 
#' de biais n'est appliquée lorsque `bias = NA`, ce qui équivaut à spécifier `bias = 0.0` lorsque `lambda = 0.0` et 
#' `bias = 1.0` dans le cas contraire. L'argument `bias` n'est pas utilisé lorsque `biasOption = 3` ou `rho = 1.0`. Voir la 
#' section **Détails** pour plus d'informations sur le biais.
#'
#' **La valeur par défaut** est `bias = NA` (pas de biais défini par l'utilisateur).
#'
#' @param tolV,tolP (optionnel)
#'
#' Nombre réel non négatif, ou `NA`, spécifiant la tolérance, en valeur absolue ou en pourcentage, à utiliser pour 
#' la validation des étalons contraignants (coefficient d'altérabilité de \eqn{0.0}) en sortie. Cette validation consiste à 
#' comparer la valeur des étalons contraignants en entrée à la valeur équivalente calculée à partir des données de la série 
#' étalonnée (sortie). Les arguments `tolV` et `tolP` ne peuvent pas être spécifiés tous les deux à la fois (l'un doit être 
#' spécifié tandis que l'autre doit être `NA`).
#'
#' **Exemple :** pour une tolérance de 10 *unités*, spécifiez `tolV = 10, tolP = NA`; pour une tolérance de 1%, 
#' spécifiez `tolV = NA, tolP = 0.01`.
#'
#' **Les valeurs par défaut** sont `tolV = 0.001` et `tolP = NA`.
#'
#' @param warnNegResult (optionnel)
#'
#' Argument logique (*logical*) spécifiant si un message d'avertissement doit être affiché lorsqu'une valeur négative 
#' créée par la fonction dans la série étalonnée (en sortie) est inférieure au seuil spécifié avec l'argument `tolN`.
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
#' @param var (optionnel)
#'
#' Vecteur (longueur minimale de 1) de chaînes de caractères spécifiant le(s) nom(s) de variable(s) du *data frame* des séries 
#' indicatrices (argument `series_df`) contenant les valeurs et (optionnellement) les coefficients d'altérabilité définis par 
#' l'utilisateur de la (des) série(s) à étalonner. Ces variables doivent être numériques.
#' 
#' La syntaxe est `var = c("serie1 </ alt_ser1>", "serie2 </ alt_ser2>", ...)`. Des coefficients d'altérabilité par défaut 
#' de \eqn{1.0} sont utilisés lorsqu'une variable de coefficients d'altérabilité définie par l'utilisateur n'est pas spécifiée
#' à côté d'une variable de série indicatrice. Voir la section **Détails** pour plus d'informations sur les coefficients 
#' d'altérabilité.
#'
#' **Exemple :** `var = "value / alter"` étalonnerait la variable `value` du *data frame* des séries indicatrices avec les 
#' coefficients d'altérabilité contenus dans la variable `alter` tandis que `var = c("value / alter", "value2")` étalonnerait 
#' en plus la variable `value2` avec des coefficients d'altérabilité par défaut de \eqn{1.0}.
#'
#' **La valeur par défaut** est `var = "value"` (étalonner la variable `value` avec des coefficients d'altérabilité par défaut 
#' de \eqn{1.0}).
#'
#' @param with (optionnel)
#'
#' Vecteur (même longueur que l'argument `var`) de chaînes de caractères, ou `NULL`, spécifiant le(s) nom(s) de variable(s) 
#' du *data frame* des étalons (argument `benchmarks_df`) contenant les valeurs et (optionnellement) les coefficients 
#' d'altérabilité définis par l'utilisateur des étalons. Ces variables doivent être numériques. La spécification de `with = NULL` 
#' entraîne l'utilisation de variable(s) d'étalons correspondant à la (aux) variable(s) spécifiée(s) avec l'argument `var` sans 
#' coefficients d'altérabilité d'étalons définis par l'utilisateur (c'est  à dire des coefficients d'altérabilité par défaut de 
#' \eqn{0.0} correspondant à des étalons contraignants).
#'
#' La syntaxe est `with = NULL` ou `with = c("bmk1 </ alt_bmk1>", "bmk2 </ alt_bmk2>", ...)`. Des coefficients d'altérabilité 
#' par défaut de \eqn{0.0} (étalons contraignants) sont utilisés lorsqu'une variable de coefficients d'altérabilité définie 
#' par l'utilisateur n'est pas spécifiée à côté d'une variable d'étalon. Voir la section **Détails** pour plus d'informations 
#' sur les coefficients d'altérabilité.
#'
#' **Exemple :** `with = "val_bmk"` utiliserait la variable `val_bmk` du *data frame* des étalons avec les coefficients 
#' d'altérabilité par défaut de \eqn{0.0} pour étalonner la série indicatrice tandis que 
#' `with = c("val_bmk", "val_bmk2 / alt_bmk2")` étalonnerait en plus une deuxième série indicatrice en utilisant la variable 
#' d'étalons `val_bmk2` avec les coefficients d'altérabilité d'étalons contenus dans la variable `alt_bmk2`.
#'
#' **La valeur par défaut** est `with = NULL` (même(s) variable(s) d'étalons que l'argument `var` avec des coefficients 
#' d'altérabilité d'étalons par défaut de \eqn{0.0}).
#'
#' @param by (optionnel)
#'
#' Vecteur (longueur minimale de 1) de chaînes de caractères, ou `NULL`, spécifiant le(s) nom(s) de variable(s) dans les 
#' *data frames* d'entrée (arguments `series_df` et `benchmarks_df`) à utiliser pour former des groupes (pour le traitement 
#' « groupes-BY ») et permettre l'étalonnage de plusieurs séries en un seul appel de fonction. Les variables groupes-BY 
#' peuvent être numériques ou caractères (facteurs ou non), doivent être présentes dans les deux *data frames* d'entrée 
#' et apparaîtront dans les trois *data frames* de sortie (voir la section **Valeur de retour**). Le traitement groupes-BY 
#' n'est pas implémenté lorsque `by = NULL`. Voir « Étalonnage de plusieurs séries » dans la section **Détails** pour plus 
#' d'informations.
#'
#' **La valeur par défaut** est `by = NULL` (pas de traitement groupes-BY).
#'
#' @param verbose (optionnel)
#'
#' Argument logique (*logical*) spécifiant si les informations sur les étapes intermédiaires avec le temps d'exécution 
#' (temps réel et non le temps CPU) doivent être affichées. Notez que spécifier l'argument `quiet = TRUE` annulerait 
#' l'argument `verbose`.
#'
#' **La valeur par défaut** est `verbose = FALSE`.
#'
#' @param constant (optionnel)
#'
#' Nombre réel qui spécifie une valeur à ajouter temporairement à la fois à la (aux) série(s) indicatrice(s) et aux étalons 
#' avant de résoudre les problèmes d'étalonnage proportionnels (`lambda != 0.0`). La constante temporaire est enlevée de la 
#' série étalonnée finale en sortie. Par exemple, la spécification d'une (petite) constante permettrait l'étalonnage 
#' proportionnel avec `rho = 1` (étalonnage de  Denton proportionnel) sur avec des séries indicatrices qui comprennent des 
#' valeurs de 0. Sinon, l'étalonnage proportionnel avec des valeurs de 0 pour la série indicatrice n'est possible que 
#' lorsque `rho < 1`. Spécifier une constante avec l'étalonnage additif (`lambda = 0.0`) n'a pas d'impact sur les données 
#' étalonnées résultantes. Les variables de données dans le *data frame* de sortie **graphTable** incluent la constante, 
#' correspondant au problème d'étalonnage effectivement résolu par la fonction.
#'
#' **La valeur par défaut** est `constant = 0` (pas de constante additive temporaire).
#'
#' @param negInput_option (optionnel)
#'
#' Traitement des valeurs négatives dans les données d'entrée pour l'étalonnage proportionnel (`lambda != 0.0`) :
#' 
#' * `0` : Ne pas autoriser les valeurs négatives pour l'étalonnage proportionnel. Un message d'erreur est affiché en 
#' présence de valeurs négatives dans les séries indicatrices ou les étalons d'entrée et des valeurs manquantes (`NA`) 
#' sont renvoyées pour les séries étalonnées. Ceci correspond au comportement de G-Séries 2.0.
#' * `1` : Autoriser les valeurs négatives pour l'étalonnage proportionnel mais avec l'affichage d'un message d'avertissement.
#' * `2` : Autoriser les valeurs négatives pour l'étalonnage proportionnel sans afficher de message.
#' 
#' **La valeur par défaut** est `negInput_option = 0` (ne pas autoriser les valeurs négatives pour l'étalonnage proportionnel).
#'
#' @param allCols (optionnel)
#'
#' Argument logique (*logical*) spécifiant si toutes les variables du *data frame* des séries indicatrices (argument `series_df`),
#' autres que `year` et `period`, déterminent l'ensemble des séries à étalonner. Les valeurs spécifiées avec les arguments `var` 
#' et `with` sont ignorées lorsque `allCols = TRUE`, ce qui implique automatiquement des coefficients d'altérabilité par défaut, 
#' et des variables avec les mêmes noms que les séries indicatrices doivent exister dans le *data frame* des étalons (argument 
#' `benchmarks_df`).
#'
#' **La valeur par défaut** est `allCols = FALSE`.
#'
#' @param quiet (optionnel)
#'
#' Argument logique (*logical*) spécifiant s'il faut ou non afficher uniquement les informations essentielles telles que les 
#' messages d'avertissements, les messages d'erreurs et les informations sur les variables (séries) ou les groupes-BY lorsque 
#' plusieurs séries sont étalonnées en un seul appel à la fonction. Nous vous déconseillons d'*envelopper* votre appel à 
#' [benchmarking()] avec [suppressMessages()] afin de supprimer l'affichage des informations sur les variables (séries) ou les 
#' groupes-BY lors du traitement de plusieurs séries, car cela compliquerait le dépannage en cas de problèmes avec des séries 
#' individuelles. Notez que la spécification de `quiet = TRUE` annulera également l'argument `verbose`.
#'
#' **La valeur par défaut** est `quiet = FALSE`.
#'
#'
#' @details
#' Lorsque \eqn{\rho < 1}, cette fonction renvoie la solution des moindres carrés généralisés d'un cas particulier du modèle 
#' général d'étalonnage basé sur la régression proposé par Dagum et Cholette (2006). Le modèle, sous forme matricielle, est le 
#' suivant :
#' \deqn{\displaystyle
#' \begin{bmatrix} s^\dagger \\ a \end{bmatrix} = 
#' \begin{bmatrix} I \\ J \end{bmatrix} \theta + 
#' \begin{bmatrix} e \\ \varepsilon \end{bmatrix}
#' }{[s^dag; a] = [I; J] theta + [e; epsilion]}
#' où
#' * \eqn{a} est le vecteur de longueur \eqn{M} des étalons.
#' * \eqn{s^\dagger = \left\{
#'     \begin{array}{cl}
#'       s + b & \text{si } \lambda = 0 \\
#'       s \cdot b  & \text{sinon}
#'     \end{array} \right.
#'   }{s^dag = s + b si lambda = 0, s^dag = s * b sinon} est le vecteur de longueur \eqn{T} des valeurs de la série 
#'   indicatrice corrigée pour le biais, \eqn{s} désignant la série indicatrice initiale (d'entrée).
#' * \eqn{b} est le bias, qui est spécifié avec l'argument `bias` lorsque `bias_option != 3` ou, lorsque 
#' `bias_option = 3`, est estimé par \eqn{\hat{b} = \left\{
#'     \begin{array}{cl}
#'       \frac{{1_M}^\mathrm{T} (a - Js)}{{1_M}^\mathrm{T} J 1_T} & \text{si } \lambda = 0 \\
#'       \frac{{1_M}^\mathrm{T} a}{{1_M}^\mathrm{T} Js} & \text{sinon}
#'     \end{array} \right.
#'   }{b^hat = ({1_M}'(a - J s)) / ({1_M}' J 1_T) si \lambda = 0, b^hat = ({1_M}' a) / ({1_M}' J s) sinon}, où 
#'   \eqn{1_X = (1, ..., 1)^\mathrm{T}}{1_X = (1, ..., 1)'} est un vecteur de \eqn{1} de longueur \eqn{X}.
#' * \eqn{J} est la matrice \eqn{M \times T}{M x T} des contraintes d'agrégation temporelles avec les éléments \if{latex}{\cr} 
#'   \eqn{j_{m, t} = \left\{
#'     \begin{array}{cl}
#'       1 & \text{si l'étalon } m \text{ couvre la période } t \\
#'       0 & \text{sinon}
#'     \end{array} \right.
#'   }{j_{m,t} = 1 si l'étalon m couvre la période t, j_{m,t} = 0 sinon}.
#'   
######
# The previous blank roxygen2 line is necessary for proper rendering (itemization) of the following `\eqn{\theta}` line 
# in the French Rd file (?). The English Rd file is properly rendered without that blank roxygen2 line (!).
######
#' * \eqn{\theta} est le vecteur des valeurs de la série finale (étalonnée).
#' * \eqn{e \sim \left( 0, V_e \right)}{e ~ (0, V_e)} est le vecteur des erreurs de mesure de \eqn{s^\dagger}{s^dag} avec 
#' matrice de covariance \eqn{V_e = C \Omega_e C}.
#' * \eqn{C = \mathrm{diag} \left( \sqrt{c_{s^\dagger}} \left| s^\dagger \right|^\lambda \right)}{C = diag(\sqrt{c_{s^dag}} 
#' |s^dag|^lambda)} où \eqn{c_{s^\dagger}}{c_{s^dag}} est le vecteur des coefficients d'altérabilité de \eqn{s^\dagger}{s^dag}, 
#' en définissant \eqn{0^0 = 1}.
#' * \eqn{\Omega_e} est une matrice \eqn{T \times T}{T x T} avec les éléments \eqn{\omega_{e_{i,j}} = \rho^{|i-j|}} représentant 
#' l'autocorrelation d'un processus AR(1), en définissant encore \eqn{0^0 = 1}.
#' * \eqn{\varepsilon \sim (0, V_\varepsilon)}{epsilon ~ (0, V_epsilon)} est le vecteur des erreurs de mesure des étalons 
#' \eqn{a} avec matrice de covariance \eqn{V_\varepsilon = \mathrm{diag} \left( c_a a \right)}{V_epsilion = diag(c_a a)} où 
#' \eqn{c_a} est le vecteur des coefficients d'altérabilité des étalons \eqn{a}.
#' 
#' La solution des moindres carrés généralisés est la suivante :
#' \deqn{\displaystyle 
#' \hat{\theta} = s^\dagger + V_e J^{\mathrm{T}} \left( J V_e J^{\mathrm{T}} + V_\varepsilon \right)^+ \left( a - J s^\dagger \right)
#' }{theta^hat = s^dag + V_e J' (J V_e J' + V_epsilion)^{+} (a - J s^dag)}
#' où \eqn{A^{+}} désigne l'inverse de Moore-Penrose de la matrice \eqn{A}.
#' 
#' Lorsque \eqn{\rho = 1}, la fonction renvoie la solution de la méthode de Denton (modifiée) :
#' \deqn{\displaystyle 
#' \hat{\theta} = s + W \left( a - J s \right)
#' }{theta^hat = s + W (a - J s)}
#' où
#' * \eqn{W} est la matrice du coin supérieur droit du produit matriciel suivant
#'   \deqn{
#'     \left[\begin{array}{cc}
#'       D^{+} \Delta^{\mathrm{T}} \Delta D^{+} & J^{\mathrm{T}} \\
#'       J & 0
#'     \end{array} \right]^{+}
#'     \left[\begin{array}{cc}
#'       D^{+} \Delta^{\mathrm{T}} \Delta D^{+} & 0 \\
#'       J & I_M
#'     \end{array} \right] = 
#'     \left[\begin{array}{cc}
#'       I_T & W \\
#'       0 & W_\nu
#'     \end{array} \right]
#'   }{[D^{+} Delta' Delta D^{+}, J'; J, 0]^{+} [D^{+} Delta' Delta D^{+}, 0; J, I_M] = [I_T, W; 0, W_nu]}
#' * \eqn{D = \mathrm{diag} \left( \left| s \right|^\lambda \right)}{D = diag(|s|^\lambda)}, en définissant \eqn{0^0 = 1}. Notez
#' que \eqn{D} correspond à \eqn{C} avec \eqn{c_{s^\dagger} = 1.0}{c_{s^dag} = 1.0} et sans correction de biais (arguments 
#' `bias_option = 1` et `bias = NA`).
#' * \eqn{\Delta}{Delta} est une matrice \eqn{T-1 \times T}{T-1 x T} avec les éléments \eqn{\delta_{i,j} = \left\{
#'     \begin{array}{cl}
#'       -1 & \text{si } i=j \\
#'       1 & \text{si } j=i+1 \\
#'       0 & \text{sinon}
#'     \end{array} \right.
#'   }{delta_{i,j} = 1 si i = j, delta_{i,j} = 1 si j = i + 1, delta_{i,j} = 0 sinon}.
#' * \eqn{W_\nu} est une matrice \eqn{M \times M}{M x M} associée aux multiplicateurs de Lagrange du problème de minimisation 
#' correspondant exprimé comme suit :
#' \deqn{\displaystyle 
#' \begin{aligned}
#' & \underset{\theta}{\text{minimiser}} 
#' & & \sum_{t \ge 2} \left[ \frac{\left( s_t - \theta_t \right)}{\left| s_t\right|^\lambda}
#'       - \frac{\left( s_{t-1} - \theta_{t-1} \right)}{\left| s_{t-1}\right|^\lambda} \right]^2 \\
#' & \text{sous contrainte(s)} 
#' & & a = J \theta
#' \end{aligned}
#' }{min(theta) sum_{t>1}{[(s_t - theta_t) / |s_t|^lambda - (s_{t-1} - theta_{t-1}) / |s_{t-1}|^lambda]^2}, sous contrainte(s) 
#' a = J theta}
#' 
#' Voir Quenneville et al. (2006) et Dagum and Cholette (2006) pour les détails.
#' 
#' ## Paramètre autorégressif \eqn{\rho} et le *biais*
#' Le paramètre \eqn{\rho} (argument `rho`) est associé au changement entre la série indicatrice (d'entrée) et la série étalonnée 
#' (de sortie) pour deux périodes consécutives et est souvent appelé *paramètre de préservation du mouvement*. Plus la valeur de
#' \eqn{\rho} est grande, plus les mouvements d'une période à l'autre de la série indicatrice sont préservés dans la série étalonnée. 
#' Avec \eqn{\rho = 0}, la préservation des mouvements d'une période à l'autre n'est pas appliquée et les ajustements d'étalonnage 
#' qui en résultent ne sont pas lisses, comme dans le cas du prorata (\eqn{\rho = 0} et \eqn{\lambda = 0.5}) où les ajustements 
#' prennent la forme d'une *fonction en escalier*. À l'autre extrémité du spectre on trouve \eqn{\rho = 1}, appelé 
#' *étalonnage de Denton*, où la préservation du mouvement d'une période à l'autre est maximisée, ce qui se traduit par l'ensemble 
#' le plus lisse possible d'ajustements d'étalonnage disponibles avec la fonction.
#' 
#' Le *biais* représente l'écart attendu entre les étalons et la série indicatrice. Il peut être utilisé pour pré-ajuster 
#' la série indicatrice afin de réduire, en moyenne, les écarts entre les deux sources de données. La correction du biais, qui est 
#' spécifiée avec les arguments `biasOption` et `bias`, peut être particulièrement utile pour les périodes non couvertes par les 
#' étalons lorsque \eqn{\rho < 1}. Dans ce contexte, le paramètre \eqn{\rho} dicte la vitesse à laquelle les ajustements 
#' d'étalonnage projetés convergent vers le biais (ou convergent vers *aucun ajustement* sans correction du biais) pour les périodes 
#' non couvertes par un étalon. Plus la valeur de \eqn{\rho} est petite, plus la convergence vers le biais est rapide, avec 
#' convergence immédiate lorsque \eqn{\rho = 0} et aucune convergence (l'ajustement de la dernière période couverte par un étalon 
#' est répété indéfiniment) lorsque \eqn{\rho = 1} (étalonnage de Denton). En fait, les arguments `biasOption` et `bias` ne sont 
#' pas utilisés lorsque \eqn{\rho = 1} puisque la correction du biais n'a pas d'impact sur les résultats de l'étalonnage de Denton. 
#' La valeur suggérée pour \eqn{\rho} est \eqn{0.9} pour les indicateurs mensuels et \eqn{0.9^3 = 0.729} pour les indicateurs 
#' trimestriels, ce qui représente un compromis raisonnable entre maximiser la préservation du mouvement et réduire les révisions 
#' à mesure que de nouveaux étalons deviendront disponibles à l'avenir (*problème d'actualité* de l'étalonnage). En pratique, il 
#' convient de noter que l'étalonnage de Denton pourrait être *approximé* avec le modèle basé sur la régression en utilisant une 
#' valeur de \eqn{\rho} inférieure à, mais très proche de \eqn{1.0} (par exemple, \eqn{\rho = 0.999}). Voir Dagum et Cholette (2006) 
#' pour une discussion complète sur ce sujet.
#' 
#' ## Coefficients d'altérabilité
#' Les coefficients d'altérabilité \eqn{c_{s^\dagger}}{c_{s^dag}} et \eqn{c_a} représentent conceptuellement les erreurs de mesure 
#' associées aux valeurs de la série indicatrice (corrigée pour le biais) \eqn{s^\dagger}{s^dag} et des étalons \eqn{a} 
#' respectivement. Il s'agit de nombres réels non négatifs qui, en pratique, spécifient l'ampleur de la modification permise d'une 
#' valeur initiale par rapport aux autres valeurs. Un coefficient d'altérabilité de \eqn{0.0} définit une valeur fixe 
#' (contraignante), tandis qu'un coefficient d'altérabilité supérieur à \eqn{0.0} définit une valeur libre (non contraignante). 
#' L'augmentation du coefficient d'altérabilité d'une valeur initiale entraîne davantage de changements pour cette valeur dans la 
#' solution d'étalonnage et, inversement, moins de changements lorsque l'on diminue le coefficient d'altérabilité. Les coefficients 
#' d'altérabilité par défaut sont \eqn{0.0} pour les étalons (contraignants) et \eqn{1.0} pour les valeurs de la série indicatrice 
#' (non contraignantes). Remarques importantes :
#' * Avec une valeur de \eqn{\rho = 1} (argument `rho = 1`, associé à l'étalonnage de Denton), seuls les coefficients 
#' d'altérabilité par défaut (\eqn{0.0} pour un étalon et \eqn{1.0} pour une valeur de série indicatrice) sont valides. La 
#' spécification de variables de coefficients d'altérabilité définies par l'utilisateur n'est donc pas autorisée. Si de telles 
#' variables sont spécifiées (voir les arguments `var` et `with`), la fonction les ignore et affiche un message d'avertissement 
#' dans la console.
#' * Les coefficients d'altérabilité \eqn{c_{s^\dagger}}{c_{s^dag}} entrent en jeu après que la série indicatrice ait été corrigée 
#' pour le biais, lorsqu'applicable (\eqn{c_{s^\dagger}}{c_{s^dag}} est associé à \eqn{s^\dagger}{s^dag} et non à \eqn{s}). Cela 
#' signifie que la spécification d'un coefficient d'altérabilité de \eqn{0.0} pour une valeur de série indicatrice donnée 
#' **ne se traduira pas** par une valeur inchangée après étalonnage **avec correction du biais** (voir les arguments `biasOption` 
#' et `bias`).
#' 
#' Les étalons non contraignants, le cas échéant, peuvent être récupérés (calculés) à partir de la série étalonnée (voir le 
#' *data frame* de sortie **series** dans la section **Valeur de retour**). Le *data frame* de sortie **benchmarks** contient 
#' toujours les étalons fournis dans le *data frame* d'entrée des étalons (argument `benchmarks_df`).
#' 
#' ## Étalonnage de plusieurs séries
#' Plusieurs séries peuvent être étalonnées en un seul appel à [benchmarking()], en spécifiant `allCols = TRUE`, en spécifiant 
#' (manuellement) plusieurs variables avec l'argument `var` (et l'argument `with`) ou avec le traitement groupes-BY (argument 
#' `by != NULL`). Une distinction importante est que toutes les séries indicatrices spécifiées avec `allCols = TRUE`  ou avec 
#' l'argument `var` (et les étalons avec l'argument `with`) doivent avoir la même longueur, c'est-à-dire le même ensemble de 
#' périodes et et le même ensemble (nombre) d'étalons. L'étalonnage de séries de longueurs différentes (différents ensembles 
#' de périodes) ou avec différents ensembles (nombres) d'étalons doit être effectué avec un traitement groupes-BY sur des données 
#' empilées pour les *data frames* d'entrée de séries indicatrices et d'étalons (voir les fonctions utilitaires [stack_tsDF()] 
#' et [stack_bmkDF()]). Les arguments `by` et `var` peuvent être combinés afin d'implémenter le traitement groupes-BY pour des 
#' séries multiples comme illustré par l'*Exemple 2* dans la section **Exemples**. Alors que l'utilisation de variables multiples 
#' avec 'argument `var` (ou `allCols = TRUE`) sans traitement groupes-BY (argument `by = NULL`) est légèrement plus efficace 
#' (plus rapide), une approche groupes-BY avec une seule variable de série est généralement recommandée car elle est plus générale 
#' (fonctionne dans tous les contextes). Cette dernière est illustrée par l'*Exemple 3* dans la section **Exemples**. Les 
#' variables BY spécifiées avec l'argument `by` apparaissent dans les trois *data frames* de sortie.
#' 
#' ## Arguments `constant` et `negInput_option`
#' Ces arguments permettent d'étendre l'utilisation de l'étalonnage proportionnel à un plus grand nombre de problèmes. Leurs 
#' valeurs par défaut correspondent au comportement de G-Séries 2.0 (SAS\eqn{^\circledR}{®} PROC BENCHMARKING) pour lequel des 
#' options équivalentes ne sont pas définies. Bien que l'étalonnage proportionnel ne soit pas nécessairement l'approche la plus 
#' appropriée (l'étalonnage additif pourrait être plus indiqué) lorsque les valeurs de la série indicatrice approchent de 0 (ratios 
#' d'une période à l'autre instables) ou « traversent la ligne de 0 » et peuvent donc passer de positives à négatives et vice-versa 
#' (ratios d'une période à l'autre difficiles à interpréter), ces cas ne sont pas invalides d'un point de vue mathématique (le 
#' problème d'étalonnage proportionnel associé peut être résolu). Il est toutefois fortement recommandé d'analyser et de valider 
#' soigneusement les données étalonnées obtenues dans ces situations pour s'assurer qu'elles correspondent à des solutions 
#' raisonnables et interprétables. 
#' 
#' ## Traitement des valeurs manquantes (`NA`)
#' * Si une valeur manquante apparaît dans l'une des variables du *data frame* d'entrée des étalons (autre que les variables
#' BY), les enregistrements avec les valeurs manquantes sont laissés de côté, un message d'avertissement est affiché et la 
#' fonction s'exécute.
#' * Si une valeur manquante apparaît dans les variables `year` ou `period` du *data frame* d'entrée des séries indicatrices 
#' et que des variables BY sont spécifiées, le groupe-BY correspondant est ignoré, un message d'avertissement s'affiche et la 
#' fonction passe au groupe-BY suivant. Si aucune variable BY n'est spécifiée, un message d'avertissement s'affiche
#' et aucun traitement n'est effectué.
#' * Si une valeur manquante apparaît dans l'une des variables des données de série du *data frame* d'entrée des séries 
#' indicatrices et que des variables BY sont spécifiées, le groupe-BY correspondant est ignoré, un message d'avertissement est 
#' affiché et la fonction passe au groupe-BY suivant. Si aucune variable BY n'est spécifiée, la série indicatrice concernée 
#' n'est pas traitée, un message d'avertissement est affiché et la fonction passe à la série indicatrice suivante (le cas échéant).

#'
#' @returns
#' La fonction renvoie une liste de trois *data frames* :
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
#'   * `constant` : Constante additive temporaire (argument `constant`)
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
#' @references Dagum, E. B. et P. Cholette (2006). **Benchmarking, Temporal Distribution and Reconciliation
#' Methods of Time Series**. Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186
#'
#' @references Fortier, S. et B. Quenneville (2007). « Theory and Application of Benchmarking in Business Surveys ».
#' **Proceedings of the Third International Conference on Establishment Surveys (ICES-III)**. Montréal, juin 2007.
#'
#' @references Latendresse, E., M. Djona et S. Fortier (2007). « Benchmarking Sub-Annual Series to Annual Totals –
#' From Concepts to SAS\eqn{^\circledR}{®} Procedure and Enterprise Guide\eqn{^\circledR}{®} Custom Task ». **Proceedings 
#' of the SAS\eqn{^\circledR}{®} Global Forum 2007 Conference**. Cary, NC: SAS Institute Inc.
#'
#' @references Quenneville, B., S. Fortier, Z.-G. Chen et E. Latendresse (2006). « Recent Developments in Benchmarking to 
#' Annual Totals in X-12-ARIMA and at Statistics Canada ». **Proceedings of the Eurostat Conference on Seasonality, 
#' Seasonal Adjustment and Their Implications for Short-Term Analysis and Forecasting**. Luxembourg, mai 2006.
#'
#' @references Quenneville, B., P. Cholette, S. Fortier et J. Bérubé (2010). « Benchmarking Sub-Annual Indicator
#' Series to Annual Control Totals (Forillon v1.04.001) ». **Document interne**. Statistique Canada, Ottawa, Canada.
#'
#' @references Quenneville, B. et S. Fortier (2012). « Restoring Accounting Constraints in Time Series – Methods and
#' Software for a Statistical Agency ». **Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New York.
#'
#' @references Statistique Canada (2012). **Théorie et application de l’étalonnage (Code du cours 0436)**.
#' Statistique Canada, Ottawa, Canada.
#'
#' @references Statistique Canada (2016). « La procédure BENCHMARKING ». **Guide de l'utilisateur de G-Séries 2.0**.
#' Statistique Canada, Ottawa, Canada.
#'
#'
#' @seealso [stock_benchmarking()] [plot_graphTable()] [bench_graphs] [plot_benchAdj()] [gs.gInv_MP()] [aliases]
#'
#'
#' @example misc/function_examples/benchmarking-ex.R
#'
#'
#' @export
benchmarking <- function(series_df,
                         benchmarks_df,
                         rho,
                         lambda,
                         biasOption,
                         bias = NA,
                         tolV = 0.001,
                         tolP = NA,
                         warnNegResult = TRUE,
                         tolN = -0.001,
                         var = "value",
                         with = NULL,
                         by = NULL,
                         verbose = FALSE,
                         
                         # New in G-Series 3.0
                         constant = 0,
                         negInput_option = 0,
                         allCols = FALSE,
                         quiet = FALSE) {
  
  
  
  
  ### Internal functions ###
  
  
  # NOTE: some internal functions shared with `stock_benchmarking()` are defined in script `aaa_bench_utils.R`
  #       where environment `the` is defined and contains objects that are not (cannot be) passed as arguments
  #       to the shared internal benchmarking functions.
  
  
  # Zero values input data validation functions (proportional benchmarking)
  # => return `TRUE` if the situation corresponds to an "error" and return `FALSE` otherwise
  check_any_zero_ind <- function(s, tol = gs.tolerance, ...) {
    if (any(abs(s) <= tol)) {
      
      # Zero values are NOT allowed and some were found (this is an "error")
      TRUE
      
    } else {
      
      # Zero values not found (this is NOT an "error")
      FALSE
    }
  }
  check_nonZero_bindingBmk <- function(s, J, a, c_a, tol = gs.tolerance) {
    abs_s_lowFreq <- as.vector(J %*% abs(s))
    
    # Elementwise comparisons are necessary here (cannot use &&)
    if (any(abs_s_lowFreq <= tol & (abs(a) * (c_a == 0)) > tol)) {
      warning("The indicator series is zero for all periods of a nonzero binding benchmark. ",
              "This benchmark cannot be met with proportional benchmarking.\n", call. = FALSE, immediate. = TRUE)
      bk.e$warning_flag <- TRUE
    }
    
    # Zero values are allowed (whether zero values are found or not, this is NOT an "error")
    FALSE
  }
  
  
  # Benchmarking functions according to (main function) argument 'rho':
  #   - Denton benchmarking    : rho = 1
  #   - Non-Denton benchmarking: otherwise (rho < 1)
  # => No arguments: they refer to objects that exist in the parent (calling function) environment
  Denton_bench <- function() {
    
    # Data rescaling (standardization) of matrix C
    tmp_C <- abs(s_b)^lambda
    mean_C <- mean(tmp_C)
    if (mean_C != 0) {
      # `mean_C` should never be 0 in theory, but it could become zero in practice with 
      # "extreme negative" values for `lambda` (e.g., `lambda = -9999` )
      tmp_C <- tmp_C / mean_C
    }
    verbose_func(start_time, Sys.time(), "Data rescaling for matrix C")
    start_time <<- Sys.time()
    
    # Build the matrices and solve
    C <- diag(tmp_C, nrow = nT)
    delta <- stats::toeplitz(c(-1, 1, rep.int(0, nT - 2)))
    delta[lower.tri(delta)] <- 0
    delta <- delta[1:(nT - 1), , drop = FALSE]
    verbose_func(start_time, Sys.time(), "C and Delta matrices construction")
    start_time <<- Sys.time()
    
    C_inv <- gs.gInv_MP(C)
    verbose_func(start_time, Sys.time(), "Inverse C calculation")
    start_time <<- Sys.time()
    
    M0 <- C_inv %*% t(delta) %*% delta %*% C_inv
    verbose_func(start_time, Sys.time(), "Inv(C) x Delta' x Delta x Inv(C)")
    start_time <<- Sys.time()
    
    M1_inv <- gs.gInv_MP(rbind(cbind(M0, t(J)), cbind(J, matrix(0, nrow = M, ncol = M))))
    verbose_func(start_time, Sys.time(), "Inverse BigMat1 calculation")
    start_time <<- Sys.time()
    
    bigMat <- M1_inv %*% rbind(cbind(M0, matrix(0, nrow = nT, ncol = M)), cbind(J, diag(1, nrow = M)))
    verbose_func(start_time, Sys.time(), "BigMat3 = Inv(BigMat1) x BigMat2")
    start_time <<- Sys.time()
    
    theta <- as.vector(s_b + bigMat[1:nT, (nT + 1):(nT + M), drop = FALSE] %*% (a - J %*% s_b))
    verbose_func(start_time, Sys.time(), "Theta = s* + W x (a - J x s*)")
    start_time <<- Sys.time()
    
    theta
  }
  nonDenton_bench <- function() {
    
    # Data rescaling (standardization) of matrices C and V_eps
    tmp_C <- sqrt(c_s) * abs(s_b)^lambda
    tmp_V <- c_a * a
    mean_C <- mean(tmp_C)
    if (mean_C != 0) {
      tmp_C <- tmp_C / mean_C
      tmp_V <- tmp_V / mean_C^2
    }
    verbose_func(start_time, Sys.time(), "Data rescaling for matrices C and V_eps")
    start_time <<- Sys.time()
    
    # Build the matrices and solve
    C <- diag(tmp_C, nrow = nT)
    V_eps <- diag(tmp_V, nrow = M)
    # `sapply()` is safe: Omega_e will always be a "matrix" object, even when `nT = 1`
    Omega_e <- stats::toeplitz(sapply(1:nT, function(x) rho^(x - 1)))
    verbose_func(start_time, Sys.time(), "C, V_eps and Omega matrices construction")
    start_time <<- Sys.time()
    
    V_e <- C %*% Omega_e %*% C
    verbose_func(start_time, Sys.time(), "V_e = C x Omega x C")
    start_time <<- Sys.time()
    
    V_d <- J %*% V_e %*% t(J) + V_eps
    verbose_func(start_time, Sys.time(), "V_d = J x V_e x J' + V_eps")
    start_time <<- Sys.time()
    
    V_d_inv <- gs.gInv_MP(V_d)
    verbose_func(start_time, Sys.time(), "Inverse V_d calculation")
    start_time <<- Sys.time()
    
    theta <- as.vector(s_b + V_e %*% t(J) %*% V_d_inv %*% (a - J %*% s_b))
    verbose_func(start_time, Sys.time(), "Theta = s* + V_e x J' x Inv(V_d) x (a - J x s*)")
    start_time <<- Sys.time()
    
    theta
  }
  
  
  
  
  ### Main function ###
  
  start_time <- Sys.time()
  start_time0 <- start_time
  
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
    quiet_lab <- "    (*)quiet           = FALSE (default)"
  }
  
  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\nbenchmarking() function:\n")
  
  
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
  verbose <- gs.validate_arg_logi(verbose)
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
  
  # Implement the verbose setting
  if (verbose && !quiet) {
    verbose_func <- gs.display_difftime
    verbose_lab <- "    verbose            = TRUE"
  } else {
    verbose_func <- gs.NULL_func
    verbose_lab <- "    verbose            = FALSE (default)"
  }
  
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
    by_lab <- paste0("    by                 = ", paste(by, collapse = " "))
    gs.validate_cols(by, data_cols_serDF, ser_df_name, source_str = "argument 'by'")
    gs.validate_cols(by, data_cols_bmkDF, bmk_df_name, source_str = "argument 'by'")
    by_grps <- unique(series_df[by])
    n_byGrps <- nrow(by_grps)
    
    # Build the by-group expression (for message display)
    if (n_byGrps > 0) {
      by_grps$PB._expr_ <- paste0(by[1], "=", by_grps[, by[1]])
      for (ii in seq_along(by)[-1]) {
        by_grps$PB._expr_ <- paste(by_grps$PB._expr_, paste0(by[ii], "=", by_grps[, by[ii]]), sep = " & ")
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
    by_lab <- "    by                 = NULL (default)"
    by_grps <- data.frame(PB._expr_ = "")
    n_byGrps <- 1
    byGrp_ini_func <- bk.noByGrp_ini
    byGrp_msg_func <- gs.NULL_func
  }
  
  # Ignore arguments 'var' and 'with' and process all data columns of the input indicator series
  # data frame, expecting corresponding columns (same names) in the input benchmarks data frame
  if (allCols) {
    var_lab <- "    var                (ignored)"
    with_lab <- "    with               (ignored)"
    allCols_lab <- "    (*)allCols         = TRUE"
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
    allCols_lab <- "    (*)allCols         = FALSE (default)"
    
    # Validation of argument 'var'
    var <- gs.cleanup_col_list(var)
    var_lab <- paste0("    var                = ", paste(var, collapse = " "))
    if (var_lab == "    var                = value") {
      var_lab <- "    var                = value (default)"
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
      with_lab <- "    with               = NULL (default)"
      with <- var
      alter_bmk <- rep.int("", n_vars)
      default_alter_bmk_id <- 1:n_vars
      user_alter_bmk_id <- integer(0)
    } else {
      with_lab <- paste0("    with               = ", paste(with, collapse = " "))
      tmp <- gs.split_str("\\/", with)
      with <- tmp[[1]]
      len <- length(tmp)
      if (len == 2) {
        alter_bmk <- tmp[[2]]
        default_alter_bmk_id <- which(alter_bmk == "")
        user_alter_bmk_id <- setdiff(1:n_vars, default_alter_bmk_id)
      } else {
        if (len > 2) {
          stop("Invalid specification of alterability coefficients in argument 'with'.\n\n", call. = FALSE)
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
  series_df$PB._default_alter_ <- rep.int(1, nrow(series_df))
  benchmarks_df$PB._default_alter_ <- rep.int(0, nrow(benchmarks_df))
  actual_alter_ser <- alter_ser
  actual_alter_bmk <- alter_bmk
  alter_ser[default_alter_ser_id] <- "PB._default_alter_"
  alter_bmk[default_alter_bmk_id] <- "PB._default_alter_"
  alter_ser_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_bmk_check_func_str <- rep.int("gs.FALSE_func", n_vars)
  alter_ser_check_func_str[user_alter_ser_id] <- "gs.check_alter"
  alter_bmk_check_func_str[user_alter_bmk_id] <- "gs.check_alter"
  
  # Initialize the output data frames (as NULL objects for now)
  out_series_df <- NULL
  out_benchmarks_df <- NULL
  out_graphTable_df <- NULL
  
  # Set parameters and function names according to the benchmarking model (additive benchmarking
  # when 'lambda == 0' and proportional benchmarking otherwise):
  #   - negative values verification functions
  #   - bias calculation
  #   - ratio and growth rate calculation functions
  if (lambda == 0) {
    zeros_verif_func <- gs.FALSE_func
    neg_verif_func <- gs.FALSE_func
    default_bias <- 0
    bias_calc_func <- bk.calc_add_bias
    bias_apply_func <- bk.apply_add_bias
    ratio_func <- gs.calc_diff
    growthRate_func <- gs.calc_firstDiff
  } else {
    if (rho == 1 || lambda < 0) {
      zeros_verif_func <- check_any_zero_ind
    } else {
      zeros_verif_func <- check_nonZero_bindingBmk
    }
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
    ratio_func <- gs.calc_ratio
    growthRate_func <- gs.calc_relFirstDiff
    if (!is.na(bias) && bias < 0) {
      stop("Argument 'bias' must be positive with proportional benchmarking.\n\n", call. = FALSE)
    }
  }
  
  # Set the bias option function according to argument 'biasOption'
  if (biasOption == 3) {
    biasOption_func <- bk.apply_biasOption3
    biasOption_lab <- "    biasOption         = 3 (Calculate bias, use calculated bias)"
    bias_parm <- NA_real_
    bias_str <- NA_character_
    bias_lab <- "    bias               (ignored)"
  } else {
    if (biasOption == 1) {
      biasOption_func <- bk.apply_biasOption1
      biasOption_lab <- "    biasOption         = 1 (Use user-defined or default bias)"
    } else if (biasOption == 2) {
      biasOption_func <- bk.apply_biasOption2
      biasOption_lab <- "    biasOption         = 2 (Calculate bias, but use user-defined or default bias)"
    }
    if (is.na(bias)) {
      bias_parm <- default_bias
      bias_str <- "default"
      bias_lab <- "    bias               = NA (default)"
    } else {
      bias_parm <- bias
      bias_str <- "user-defined"
      bias_lab <- paste0("    bias               = ", format(bias))
    }
  }
  bk.e$actual_bias <- NULL
  
  # Set parameters and functions according to argument 'rho' (Denton or Non-Denton benchmarking):
  #   - minimum required number of periods in the indicator series
  #   - benchmarking function
  if (rho == 1) {
    min_nT <- 2
    bench_func <- Denton_bench
    
    # Impose no bias correction (same as `biasOption = 1` and `bias = NA`)
    biasOption_func <- bk.apply_biasOption1
    biasOption_lab <- "    biasOption         (ignored)"
    bias_parm <- default_bias
    bias_str <- "default"
    bias_lab <- "    bias               (ignored)"
    
    # Check for user (non-default) alter coefs (not allowed when rho=1)
    if (length(user_alter_ser_id) > 0 || length(user_alter_bmk_id) > 0) {
      warning("Alterability coefficients are not available when rho=1.0. ",
              "The default values will be used.\n", call. = FALSE, immediate. = TRUE)
      bk.e$warning_flag <- TRUE
      if (length(user_alter_ser_id) > 0) {
        var_lab <- paste0("    var                = ", paste(var, collapse = " "))
        if (var_lab == "    var                = value") {
          var_lab <- "    var                = value (default)"
        }
      }
      if (length(user_alter_bmk_id) > 0) {
        with_lab <- paste0("    with               = ", paste(with, collapse = " "))
      }
      alter_ser[user_alter_ser_id] <- "PB._default_alter_"
      alter_bmk[user_alter_bmk_id] <- "PB._default_alter_"
      actual_alter_ser[user_alter_ser_id] <- ""
      actual_alter_bmk[user_alter_bmk_id] <- ""
      alter_ser_check_func_str[user_alter_ser_id] <- "gs.FALSE_func"
      alter_bmk_check_func_str[user_alter_bmk_id] <- "gs.FALSE_func"
      user_alter_ser_id <- integer(0)
      user_alter_bmk_id <- integer(0)
      default_alter_ser_id <- 1:n_vars
      default_alter_bmk_id <- 1:n_vars
    }
  } else {
    min_nT <- 1
    bench_func <- nonDenton_bench
  }
  
  # Results validation function and binding benchmarks tolerance
  if (warnNegResult) {
    neg_res_func <- gs.check_neg
    warnNegResult_lab <- "    warnNegResult      = TRUE (default)"
  } else {
    neg_res_func <- gs.FALSE_func
    warnNegResult_lab <- "    warnNegResult      = FALSE"
  }
  if (!is.na(tolV)) {
    if (!is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both specified (one must be NA).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_diff_valid
    tol_parm <- tolV
    tol_lab <- paste0("    tolV               = ", format(tolV))
    if (abs(tolV - 0.001) < gs.tolerance) {
      tol_lab <- paste0(tol_lab, " (default)")
    }
  } else {
    if (is.na(tolP)) {
      stop("Arguments 'tolV' and 'tolP' cannot be both NA (one must be specified).\n\n", call. = FALSE)
    }
    binding_bmk_valid_func <- bk.binding_bmk_relDiff_valid
    tol_parm <- tolP
    tol_lab <- paste0("    tolP               = ", format(tolP))
  }
  
  
  # Display the function call (argument values)
  quiet_msg_func("    series_df          = ", ser_df_name)
  quiet_msg_func("    benchmarks_df      = ", bmk_df_name)
  quiet_msg_func("    rho                = ", format(rho))
  quiet_msg_func("    lambda             = ", format(lambda))
  quiet_msg_func(biasOption_lab)
  quiet_msg_func(bias_lab)
  quiet_msg_func(tol_lab)
  quiet_msg_func(warnNegResult_lab)
  lab <- paste0("    tolN               = ", format(tolN))
  if (abs(tolN - (-0.001)) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(var_lab)
  quiet_msg_func(with_lab)
  quiet_msg_func(by_lab)
  quiet_msg_func(verbose_lab, "\n")
  lab <- paste0("    (*)constant        = ", format(constant))
  if (constant == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  lab <- paste0("    (*)negInput_option = ", format(negInput_option))
  if (negInput_option == 0) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(allCols_lab)
  quiet_msg_func(quiet_lab, "\n")
  quiet_msg_func("    (*) indicates new arguments in G-Series 3.0\n")
  
  verbose_func(start_time, Sys.time(), "Set up phase")
  start_time <- Sys.time()
  
  
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
      
      msg_str <- paste0("\nBenchmarking by-group ", ii, " (", by_grps$PB._expr_[ii], ")")
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
                                  paste0("\n  ", periods[prob_id - 1], " - ", periods[prob_id], 
                                         collapse = ""), 
                                  "\n\n")
          try_stop_func(try_error_msg)
          try_error <- TRUE
          
        } else {
          
          # Build benchmarks to periods mapping matrix of dimension 2 X M:
          #   - Row 1: benchmark starting period ids (positions in vector `periods`)
          #   - Row 2: benchmark ending period ids (positions in vector `periods`)
          mapping <- rbind(match(bmk_start, periods),
                           match(bmk_end, periods))
          
          # Validate the benchmark coverage (i.e. not inside the set of indicator periods)
          prob_id <- which(apply(is.na(mapping), 2, any))
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
            
            verbose_func(start_time, Sys.time(), "Data validation 1")
            start_time <- Sys.time()
            start_time1 <- start_time
            
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
                
                verbose_func(start_time, Sys.time(), "Data validation 2")
                start_time <- Sys.time()
                
                # Build the J matrix (temporal sum operator)
                J <- matrix(0, nrow = M, ncol = nT)
                for (kk in 1:M) {
                  J[kk, mapping[1, kk]:mapping[2, kk]] <- 1
                }
                
                # Build the elementary vectors and matrices
                #   => the temporary constant is added here
                s <- bk.e$ser_df_byGrp[[var[jj]]] + constant
                c_s <- bk.e$ser_df_byGrp[[alter_ser[jj]]]
                s_lowFreq <- as.vector(J %*% s)
                nT_lowFreq <- as.vector(J %*% rep.int(1, nT))
                nT_bmk <- sum(nT_lowFreq)
                a <- bk.e$bmk_df_byGrp[[with[jj]]] + constant * nT_lowFreq
                c_a <- bk.e$bmk_df_byGrp[[alter_bmk[jj]]]
                
                verbose_func(start_time, Sys.time(), "J matrix construction")
                start_time <- Sys.time()
                
                # Additional series/benchmarks data validation for proportional benchmarking (lambda != 0)
                #   - `rho = 1` or `lambda < 0`: zero indicator series values (infeasible proportional benchmarking problem)
                #     `rho < 1`: nonzero binding benchmarks associated to "all zero" indicator series values
                #                (infeasible proportional benchmarking problem)
                #   - negative benchmarks or indicator series values (according to argument `negInput_option`)
                if (zeros_verif_func(s, J, a, c_a, tol = gs.tolerance)) {
                  try_error_msg <<- paste0("The indicator series has zero values. This is not permitted for proportional ",
                                           "benchmarking when `rho = 1` or `lambda < 0`.\n\n")
                  try_stop_func(try_error_msg)
                  try_error <- TRUE
                  
                } else if (neg_verif_func(a, tol = 0, data_str = "benchmarks")) {
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
                  s_b <- biasOption_func(quiet_msg_func,                                      # message function
                                         bias_calc_func, s_lowFreq, a, nT_bmk, gs.tolerance,  # bias calculation arguments
                                         bias_apply_func, s, bias_parm,                       # bias application arguments
                                         bias_str)
                  
                  verbose_func(start_time, Sys.time(), "Bias adjustment (s*)")
                  start_time <- Sys.time()
                  
                  # Solve the benchmarking problem (unless there's no discrepancies)
                  if (any(abs(as.vector(J %*% s_b) - a) > gs.min_tolerance)) {
                    theta <- bench_func()
                  } else {
                    theta <- s_b
                  }
                  
                  # Just for safety: solution could contain `NaN` values in very extreme cases (matrix inversion problems)
                  if (any(!is.finite(theta))) {
                    warning("Unable to solve the benchmarking problem.\n", call. = FALSE, immediate. = TRUE)
                    bk.e$warning_flag <- TRUE
                    out_ser_df_byGrp[[var[jj]]] <- NA_real_
                    
                  } else {
                    
                    
                    # Cumulate the graphTable output data frame info
                    #   => the graphTable includes more periods than the indicator series (`n_obs_GT > nT`)
                    #      in the case of overlapping benchmarks
                    
                    # Map benchmark level info (vectors of length `M`) to period level info (vectors of length
                    # `n >= nT`, with `n = nT` for non-overlapping benchmarks and `n > nT` for overlapping benchmarks)
                    # according to matrix `mapping` of dimension 2 X `M`:
                    #   - Row 1: benchmark starting period ids
                    #   - Row 2: benchmark ending period ids
                    #
                    # The resulting `bmk_info` data frame has `n >= nT` observations and 5 variables:
                    #   - `t`: period id
                    #   - `m`: benchmark id (`NA` for periods not associated to any benchmark)
                    #   - `avg_s`: average indicator series value  (`NA` for periods not associated to any benchmark)
                    #   - `avg_a`: average benchmark value (`NA` for periods not associated to any benchmark)
                    #   - `c_a`: benchmark alter coef (`NA` for periods not associated to any benchmark)
                    temp_df <- data.frame(t = rep.int(NA_integer_, nT_bmk),
                                          m = rep.int(NA_integer_, nT_bmk))
                    last_row <- 0
                    for (ii in 1:M) {
                      per_vec <- mapping[1, ii]:mapping[2, ii]
                      n_per <- length(per_vec)
                      temp_df[(last_row + 1):(last_row + n_per), ] <- c(per_vec,             # period ids (`t`)
                                                                        rep.int(ii, n_per))  # benchmark ids (`m`)
                      last_row <- last_row + n_per
                    }
                    bmk_info <- merge(data.frame(t = 1:nT), # period ids
                                      merge(temp_df,
                                            # Benchmark level info
                                            data.frame(m = 1:M,
                                                       avg_s = s_lowFreq / nT_lowFreq,
                                                       avg_a = a / nT_lowFreq,
                                                       c_a = c_a),
                                            by = "m"), 
                                      by = "t", 
                                      all.x = TRUE)
                    bmk_info <- bmk_info[order(bmk_info$t, bmk_info$m), ]
                    
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
                    
                    # Cumulate the graphTable data frame info
                    out_graphTable_df <- rbind(out_graphTable_df, cbind(bk.e$ser_df_byGrp[bmk_info$t, by, drop = FALSE],
                                                                        out_GT_df_var))
                    
                    verbose_func(start_time, Sys.time(), "Output grahTable creation")
                    start_time <- Sys.time()
                    
                    # Remove the temporary constant
                    out_ser_df_byGrp[[var[jj]]] <- theta - constant
                    
                    # Results validation
                    if (neg_res_func(out_ser_df_byGrp[[var[jj]]], tol = -tolN)) {
                      warning("The benchmarked series contains negative values (threshold = ", format(tolN), ").\n",
                              call. = FALSE, immediate. = TRUE)
                      bk.e$warning_flag <- TRUE
                    }
                    binding_bmk_valid_func(bk.e$bmk_df_byGrp[[with[jj]]], as.vector(J %*% out_ser_df_byGrp[[var[jj]]]), c_a,
                                           bmk_start, bmk_end, tol_parm, zero_tol = 0)
                    
                    verbose_func(start_time, Sys.time(), "Results validation")
                    start_time <- Sys.time()
                  }
                  
                  verbose_func(start_time1, Sys.time(), "Benchmarking step total execution time")
                  start_time1 <- Sys.time()
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
  out_list <- list(series = out_series_df, 
                   benchmarks = out_benchmarks_df, 
                   graphTable = out_graphTable_df)
  
  verbose_func(start_time, Sys.time(), "Wrap up phase")
  verbose_func(start_time0, Sys.time(), "Total execution time")
  
  
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
