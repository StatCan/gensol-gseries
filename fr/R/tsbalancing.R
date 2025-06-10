################################################################################
#
# CAREFUL: this script contains translated (French) roxygen2 comments 
#          for other topics/functions further down below
#
################################################################################


#' Rétablir les contraintes linéaires transversales (contemporaines)
#'
#'
#' @description
#' _Réplication de la macro ***GSeriesTSBalancing*** de G-Séries 2.0 en SAS\eqn{^\circledR}{®}. Voir la documentation 
#' de G-Séries 2.0 pour plus de détails (Statistique Canada 2016)._
#'
#' Cette fonction équilibre (réconcilie) un système de séries chronologiques selon un ensemble de contraintes linéaires. 
#' La solution d'équilibrage (« *balancing* ») est obtenue en résolvant un ou plusieurs problèmes de minimisation quadratique 
#' (voir la section **Détails**) avec le solveur OSQP (Stellato et al. 2020). Étant donné la faisabilité du (des) problème(s) 
#' d'équilibrage, les données des séries chronologiques résultantes respectent les contraintes spécifiées pour chaque période. 
#' Des contraintes linéaires d'égalité et d'inégalité sont permises. Optionnellement, la préservation des totaux temporels peut 
#' également être spécifiée.
#' 
#' 
#' @usage
#' tsbalancing(
#'   in_ts,
#'   problem_specs_df,
#'   temporal_grp_periodicity = 1,
#'   temporal_grp_start = 1,
#'   osqp_settings_df = default_osqp_sequence,
#'   display_level = 1,
#'   alter_pos = 1,
#'   alter_neg = 1,
#'   alter_mix = 1,
#'   alter_temporal = 0,
#'   lower_bound = -Inf,
#'   upper_bound = Inf,
#'   tolV = 0,
#'   tolV_temporal = 0,
#'   tolP_temporal = NA,
#'
#'   # Nouveau dans G-Séries 3.0
#'   validation_tol = 0.001,
#'   trunc_to_zero_tol = validation_tol,
#'   full_sequence = FALSE,
#'   validation_only = FALSE,
#'   quiet = FALSE
#' )
#' 
#'
#' @param in_ts (obligatoire) 
#' 
#' Objet de type série chronologique (classe « ts » ou « mts ») qui contient les données des séries 
#' chronologiques à réconcilier. Il s'agit des données d'entrée (solutions initiales) des problèmes d'équilibrage 
#' (« *balancing* »).
#' 
#' @param problem_specs_df (obligatoire) 
#' 
#' *Data frame* des spécifications du problème d'équilibrage. En utilisant un format clairsemé (épars) inspiré de la 
#' procédure LP de SAS/OR\eqn{^\circledR}{®} (SAS Institute 2015), il ne contient que les informations pertinentes 
#' telles que les coefficients non nuls des contraintes d'équilibrage ainsi que les coefficients d'altérabilité et les 
#' bornes inférieures/supérieures à utiliser au lieu des valeurs par défaut (c.-à-d., les valeurs qui auraient la priorité 
#' sur celles définies avec les arguments `alter_pos`, `alter_neg`, `alter_mix`, `alter_temporal`, `lower_bound` et 
#' `upper_bound`).
#' 
#' Les informations sont fournies à l'aide de quatre variables obligatoires (`type`, `col`, `row` et `coef`) et d'une 
#' variable facultative (`timeVal`). Un enregistrement (une rangée) dans le *data frame* des spécifications du problème 
#' définit soit une étiquette pour l'un des sept types d'éléments du problème d'équilibrage avec les colonnes `type` et `row` 
#' (voir *Enregistrements de définition d'étiquette* ci-dessous) ou bien spécifie des coefficients (valeurs numériques) pour 
#' ces éléments du problème d'équilibrage avec les variables `col`, `row`, `coef` et `timeVal` (voir *Enregistrements de 
#' spécification d'information* ci-dessous).
#' 
#' * **Enregistrements de définition d'étiquette** (`type` n'est pas manquant (n'est pas `NA`))
#' 
#'   * `type` (car) : mot-clé réservé identifiant le type d'élément du problème en cours de définition : 
#'     * `EQ` : contrainte d'équilibrage d'égalité (\eqn{=}) 
#'     * `LE` : contrainte d'équilibrage d'inégalité de type inférieure ou égale (\eqn{\le}{<=})
#'     * `GE` : contrainte d'équilibrage d'inégalité de type supérieure ou égale (\eqn{\ge}{>=})
#'     * `lowerBd` : borne inférieure des valeurs de période
#'     * `upperBd` : borne supérieure des valeurs de période
#'     * `alter` : coefficient d'altérabilité des valeurs de période
#'     * `alterTmp` : coefficient d'altérabilité des totaux temporels
#'   * `row` (car) : étiquette à associer à l'élément du problème (_mot-clé `type`_)
#'   * _toutes les autres variables ne sont pas pertinentes et devraient contenir des données manquantes (valeurs `NA`)_ \cr \cr
#' 
#' * **Enregistrements de spécification d'information** (`type` est manquant (est `NA`))
#' 
#'   * `type` (car) : non applicable (`NA`)
#'   * `col` (car) : nom de la série ou mot réservé `_rhs_` pour spécifier la valeur du côté droit (_RHS_ pour 
#'   _**R**ight-**H**and **S**ide_) 
#'   d'une contrainte d'équilibrage.
#'   * `row` (car) : étiquette de l'élément du problème.
#'   * `coef` (num) : valeur de l'élément du problème :
#'     * coefficient de la série dans la contrainte d'équilibrage ou valeur _RHS_
#'     * borne inférieure ou supérieure des valeurs de période de la série
#'     * coefficient d'altérabilité des valeurs de période ou des totaux temporels de la série
#'   * `timeVal` (num) : valeur de temps optionnelle pour restreindre l'application des bornes ou coefficients 
#'   d'altérabilité des séries à une période (ou groupe temporel) spécifique. Elle correspond à la valeur de temps, 
#'   telle que renvoyée par `stats::time()`, pour une période (observation) donnée des séries chronologiques d'entrée 
#'   (argument `in_ts`) et correspond conceptuellement à \eqn{ann\acute{e}e + (p\acute{e}riode - 1) / fr\acute{e}quence}.
#'    
#'    
######
# The previous extra blank roxygen2 line is necessary for proper rendering (non-itemization) of the following paragraph 
# in the French Rd file (?). The English Rd file is properly rendered without that extra blank roxygen2 line (!).
######
#' Notez que les chaînes de caractères vides (`""` ou `''`) pour les variables de type caractère sont interprétées comme 
#' manquantes (`NA`) par la fonction. La variable `row` identifie les éléments du problème d'équilibrage et est la variable 
#' clé qui fait le lien entre les deux types d'enregistrements. La même étiquette (`row`) ne peut être associée à plus d'un 
#' type d'éléments du problème (`type`) et plusieurs étiquettes (`row`) ne peuvent pas être définies pour un même type 
#' d'éléments du problème donné (`type`), à l'exception des contraintes d'équilibrage (valeurs `"EQ"`, `"LE"` et `"GE"` de 
#' la colonne `type`). Voici certaines caractéristiques conviviales du *data frame* des spécifications du problème : 
#' * L'ordre des enregistrements (rangées) n'est pas important.
#' * Les valeurs des variables de type caractère (`type`, `row` et `col`) ne sont pas sensibles à la casse (ex., les chaînes de 
#' caractères `"Constraint 1"` et `"CONSTRAINT 1"` pour la variable `row` seraient considérées comme une même étiquette d'élément 
#' du problème), sauf lorsque `col` est utilisé pour spécifier un nom de série (une colonne de l'objet d'entrée de type série 
#' chronologique) où **la sensibilité à la casse est appliquée**.
#' * Les noms des variables du *data frame* des spécifications du problème ne sont pas non plus sensibles à la casse (ex., 
#' `type`, `Type` ou `TYPE` sont tous des noms de variable valides) et `time_val` est un nom de variable accepté (au lieu de 
#' `timeVal`).
#' 
#' Enfin, le tableau suivant dresse la liste des alias valides (acceptés) pour les *mots-clés `type`* 
#' (type d'éléments du problème) :
#' | **Mot-clé** | **Alias** |
#' |:-----------:|:------------|
#' | `EQ`        | `==`, `=` |
#' | `LE`        | `<=`, `<` |
#' | `GE`        | `>=`, `>` |
#' | `lowerBd`   | `lowerBound`, `lowerBnd`, + *mêmes termes avec '_', '.' ou ' ' entre les mots*|
#' | `upperBd`   | `upperBound`, `upperBnd`, + *mêmes termes avec '_', '.' ou ' ' entre les mots*|
#' | `alterTmp`  | `alterTemporal`, `alterTemp`, + *mêmes termes avec '_', '.' ou ' ' entre les mots*|
#' 
#' L'examen des **Exemples** devrait aider à conceptualiser le *data frame* des spécifications du problème d'équilibrage.
#' 
#' @param temporal_grp_periodicity (optionnel)
#'
#' Nombre entier positif définissant le nombre de périodes dans les groupes temporels pour lesquels les totaux doivent 
#' être préservés. Par exemple, spécifiez `temporal_grp_periodicity = 3` avec des séries chronologiques mensuelles pour la 
#' préservation des totaux trimestriels et `temporal_grp_periodicity = 12` (ou `temporal_grp_periodicity = frequency(in_ts)`) 
#' pour la préservation des totaux annuels. Spécifier `temporal_grp_periodicity = 1` (*défaut*) correspond à un traitement 
#' période par période sans préservation des totaux temporels.
#'
#' **La valeur par défaut** est `temporal_grp_periodicity = 1` (traitement période par période sans préservation des 
#' totaux temporels).
#'
#' @param temporal_grp_start (optionnel)
#'
#' Entier dans l'intervalle \[1 .. `temporal_grp_periodicity`\] spécifiant la période (cycle) de départ pour la préservation 
#' des totaux temporels. Par exemple, des totaux annuels correspondant aux années financières définies d'avril à mars de l'année 
#' suivante seraient spécifiés avec `temporal_grp_start = 4` pour des séries chronologiques mensuelles (`frequency(in_ts) = 12`) 
#' et `temporal_grp_start = 2` pour des séries chronologiques trimestrielles (`frequency(in_ts) = 4`). Cet argument n'a pas 
#' d'effet pour un traitement période par période sans préservation des totaux temporels (`temporal_grp_periodicity = 1`).
#'
#' **La valeur par défaut** est `temporal_grp_start = 1`.
#' 
#' @param osqp_settings_df (optionnel)
#' 
#' *Data frame* contenant une séquence de paramètres d'OSQP pour la résolution des problèmes d'équilibrage. La librairie 
#' inclut deux *data frames* prédéfinis de séquences de paramètres d'OSQP :
#' * [default_osqp_sequence] : rapide et efficace (par défaut);
#' * [alternate_osqp_sequence] : orienté vers la précision au détriment du temps d'exécution.
#' 
#' Voir la `vignette("osqp-settings-sequence-dataframe")` pour plus de détails sur ce sujet et pour voir le contenu de ces 
#' deux *data frames*. Notez que le concept d'une *séquence de résolution* avec différents ensembles de paramètres pour 
#' le solveur est nouveau dans G-Séries 3.0 (une seule tentative de résolution était effectuée dans G-Séries 2.0).
#' 
#' **La valeur par défaut** est `osqp_settings_df = default_osqp_sequence`.
#' 
#' @param display_level (optionnel)
#' 
#' Entier dans l'intervalle \[0 .. 3\] spécifiant le niveau d'information à afficher dans la console (`stdout()`). 
#' Notez que spécifier l'argument `quiet = TRUE` annulerait l'argument `display_level` (aucune des informations suivantes 
#' ne serait affichée).
#' 
#' | **Information affichée**                              |       **`0`**       |       **`1`**       |       **`2`**       |       **`3`**       |
#' |:------------------------------------------------------|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
#' | En-tête de la fonction                                | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} |
#' | Éléments du problème d'équilibrage                    |                     | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} |
#' | Détails de résolution de chaque problème              |                     |                     | \eqn{\checkmark}{Y} | \eqn{\checkmark}{Y} |
#' | Résultats de chaque problème (valeurs et contraintes) |                     |                     |                     | \eqn{\checkmark}{Y} |
#' 
#' **La valeur par défaut** est `display_level = 1`.
#'  
#' @param alter_pos (optionnel)
#' 
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut associé aux valeurs des séries chronologiques 
#' avec des coefficients **positifs** dans toutes les contraintes d'équilibrage dans lesquelles elles sont impliquées (ex., 
#' les séries composantes dans les problèmes de ratissage (« *raking* ») de tables d'agrégation). Les coefficients 
#' d'altérabilité fournis dans le *data frame* des spécifications du problème (argument `problem_specs_df`) remplacent cette 
#' valeur.
#'
#' **La valeur par défaut** est `alter_pos = 1.0` (valeurs non contraignantes).
#' 
#' @param alter_neg (optionnel)
#' 
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut associé aux valeurs des séries chronologiques 
#' avec des coefficients **négatifs** dans toutes les contraintes d'équilibrage dans lesquelles elles sont impliquées (ex., 
#' les séries de total de marge dans les problèmes de ratissage (« *raking* ») de tables d'agrégation). Les coefficients 
#' d'altérabilité fournis dans le *data frame* des spécifications du problème (argument `problem_specs_df`) remplacent cette 
#' valeur.
#'
#' **La valeur par défaut** est `alter_neg = 1.0` (valeurs non contraignantes).
#' 
#' @param alter_mix (optionnel)
#' 
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut associé aux valeurs des séries chronologiques 
#' avec un mélange de coefficients **positifs et négatifs** dans les contraintes d'équilibrage dans lesquelles elles sont 
#' impliquées. Les coefficients d'altérabilité fournis dans le *data frame* des spécifications du problème (argument 
#' `problem_specs_df`) remplacent cette valeur.
#'
#' **La valeur par défaut** est `alter_mix = 1.0` (valeurs non contraignantes).
#' 
#' @param alter_temporal (optionnel)
#' 
#' Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut associé aux totaux temporels des séries 
#' chronologiques. Les coefficients d'altérabilité fournis dans le *data frame* des spécifications du problème (argument 
#' \ifelse{latex}{\code{problem _specs_df}}{\code{problem_specs_df}}) remplacent cette valeur.
#'
#' **La valeur par défaut** est `alter_temporal = 0.0` (valeurs contraignantes).
#' 
#' @param lower_bound (optionnel)
#' 
#' Nombre réel spécifiant la borne inférieure par défaut pour les valeurs des séries chronologiques. Les bornes inférieures 
#' fournies dans le *data frame* des spécifications du problème (argument `problem_specs_df`) remplacent cette valeur.
#'
#' **La valeur par défaut** est `lower_bound = -Inf` (non borné).
#' 
#' @param upper_bound (optionnel)
#' 
#' Nombre réel spécifiant la borne supérieure par défaut pour les valeurs des séries chronologiques. Les bornes supérieures 
#' fournies dans le *data frame* des spécifications du problème (argument `problem_specs_df`) remplacent cette valeur.
#'
#' **La valeur par défaut** est `upper_bound = Inf` (non borné).
#' 
#' @param tolV (optionnel)
#' 
#' Nombre réel non négatif spécifiant la tolérance, en valeur absolue, de la valeur du côté droit (*RHS*) des contraintes 
#' d'équilibrage :
#' * Contraintes `EQ` : \eqn{\quad A\mathbf{x} = \mathbf{b} \quad}{Ax = b} devient \eqn{\quad \mathbf{b} - \epsilon \le 
#' A\mathbf{x} \le \mathbf{b} + \epsilon}{b - eps <= Ax <= b + eps}
#' * Contraintes `LE` : \eqn{\quad A\mathbf{x} \le \mathbf{b} \quad}{Ax <= b} devient \eqn{\quad A\mathbf{x} \le 
#' \mathbf{b} + \epsilon}{Ax <= b + eps}
#' * Contraintes `GE` : \eqn{\quad A\mathbf{x} \ge \mathbf{b} \quad}{Ax >= b} devient \eqn{\quad A\mathbf{x} \ge 
#' \mathbf{b} - \epsilon}{Ax >= b - eps}
#' 
#' où \eqn{\epsilon}{eps} est la tolérance spécifiée avec `tolV`. Cet argument ne s'applique pas aux _bornes (inférieures et 
#' supérieures) des valeurs de période_ spécifiées avec les arguments `lower_bound` et `upper_bound` ou dans le *data frame* 
#' des spécifications du problème (argument `prob_specs_df`). Autrement dit, `tolV` n'affecte pas les bornes inférieure et 
#' supérieure des valeurs des séries chronologiques, à moins qu'elles ne soient spécifiées comme *contraintes d'équilibrage* 
#' à la place (avec des contraintes `GE` et `LE` dans le *data frame* des spécifications du problème).
#' 
#' **La valeur par défaut** est `tolV = 0.0` (pas de tolérance).
#' 
#' @param tolV_temporal,tolP_temporal (optionnel)
#' 
#' Nombre réel non négatif, ou `NA`, spécifiant la tolérance, en pourcentage (`tolP_temporal`) ou en valeur absolue 
#' (`tolV_temporal`), pour les contraintes implicites d'agrégation temporelle associées aux **totaux temporels contraignants** 
#' \eqn{\left( \sum_t{x_{i,t}} = \sum_t{y_{i,t}} \right)}{(sum_t{x_{i,t}} = sum_t{y_{i,t}})}, qui deviennent :
#' \deqn{\sum_t{y_{i,t}} - \epsilon_\text{abs} \le \sum_t{x_{i,t}} \le \sum_t{y_{i,t}} + \epsilon_\text{abs}}{sum_t{y_{i,t}} - 
#' eps_abs <= sum_t{x_{i,t}} <= sum_t{y_{i,t}} + eps_abs}
#' ou 
#' \deqn{\sum_t{y_{i,t}} \left( 1 - \epsilon_\text{rel} \right) \le \sum_t{x_{i,t}} \le \sum_t{y_{i,t}} \left( 1 + 
#' \epsilon_\text{rel} \right)}{sum_t{y_{i,t}} (1 - eps_rel) <= sum_t{x_{i,t}} <= sum_t{y_{i,t}} (1 + eps_rel)}
#' 
#' où \eqn{\epsilon_\text{abs}}{eps_abs} et \eqn{\epsilon_\text{rel}}{eps_rel} sont les tolérances absolues et en pourcentage 
#' spécifiées respectivement avec `tolV_temporal` et `tolP_temporal`. Les deux arguments ne peuvent pas être spécifiés tous 
#' les deux à la fois (l'un doit être spécifié tandis que l'autre doit être `NA`).
#'
#' **Exemple :** pour une tolérance de 10 *unités*, spécifiez \code{tolV_temporal = 10, tolP_temporal = NA}; pour une tolérance 
#' de 1%, spécifiez \code{tolV_temporal = NA, tolP_temporal = 0.01}.
#' 
#' **Les valeurs par défaut** sont `tolV_temporal = 0.0` et `tolP_temporal = NA` (pas de tolérance).
#' 
#' @param validation_tol (optionnel)
#' 
#' Nombre réel non négatif spécifiant la tolérance pour la validation des résultats d'équilibrage. La fonction vérifie si
#' les valeurs finales des séries chronologiques (réconciliées) satisfont les contraintes, en autorisant des écarts jusqu'à 
#' la valeur spécifiée avec cet argument. Un avertissement est émis dès qu'une contrainte n'est pas respectée (écart 
#' supérieur à `validation_tol`).
#' 
#' Avec des contraintes définies comme \eqn{\mathbf{l} \le A\mathbf{x} \le \mathbf{u}}{l <= Ax <= u}, où \eqn{\mathbf{l = 
#' u}}{l = u} pour les contraintes `EQ`, \eqn{\mathbf{l} = -\infty}{l = -Inf} pour les contraintes `LE` et \eqn{\mathbf{u} = 
#' \infty}{u = Inf} pour les contraintes `GE`, **les écarts de contraintes** correspondent à \eqn{\max \left( 0, \mathbf{l} - 
#' A\mathbf{x}, A\mathbf{x} - \mathbf{u} \right)}{max(0, l - Ax, Ax - u)}, où les bornes de contraintes \eqn{\mathbf{l}}{l} 
#' et \eqn{\mathbf{u}}{u} incluent les tolérances, le cas échéant, spécifiées avec les arguments `tolV`, `tolV_temporal` et 
#' `tolP_temporal`. 
#' 
#' **La valeur par défaut** est `validation_tol = 0.001`.
#' 
#' @param trunc_to_zero_tol (optionnel)
#' 
#' Nombre réel non négatif spécifiant la tolérance, en valeur absolue, pour le remplacement par zéro de (petites) valeurs 
#' dans les données (réconciliées) de séries chronologiques de sortie (objet de sortie `out_ts`). Spécifiez 
#' `trunc_to_zero_tol = 0` pour désactiver ce processus de *troncation à zéro* des données réconciliées. Sinon, spécifiez 
#' `trunc_to_zero_tol > 0` pour remplacer par \eqn{0.0} toute valeur dans l'intervalle \eqn{\left[ -\epsilon, \epsilon 
#' \right]}{[-eps, eps]}, où \eqn{\epsilon}{eps} est la tolérance spécifiée avec `trunc_to_zero_tol`. 
#' 
#' Notez que les écarts de contraintes finaux (voir l'argument `validation_tol`) sont calculées sur les séries 
#' chronologiques réconciliées *tronquées à zéro*, ce qui garantit une validation précise des données réconciliées 
#' réelles renvoyées par la fonction.
#' 
#' **La valeur par défaut** est `trunc_to_zero_tol = validation_tol`.
#' 
#' @param full_sequence (optionnel)
#' 
#' Argument logique (*logical*) spécifiant si toutes les étapes du *data frame pour la séquence de paramètres d'OSQP* 
#' doivent être exécutées ou non.  Voir l'argument `osqp_settings_df` et la `vignette("osqp-settings-sequence-dataframe")` 
#' pour plus de détails sur ce sujet.
#' 
#' **La valeur par défaut** est `full_sequence = FALSE`.
#' 
#' @param validation_only (optionnel)
#' 
#' Argument logique (*logical*) spécifiant si la fonction doit uniquement effectuer la validation des données d'entrée ou 
#' non. Lorsque `validation_only = TRUE`, les *contraintes d'équilibrage* et les *bornes (inférieures et supérieures) des 
#' valeurs de période* spécifiées sont validées par rapport aux données de séries chronologiques d'entrée, en permettant 
#' des écarts jusqu'à la valeur spécifiée avec l'argument `validation_tol`. Sinon, lorsque `validation_only = FALSE` 
#' (par défaut), les données d'entrée sont d'abord réconciliées et les données résultantes (en sortie) sont ensuite 
#' validées.
#' 
#' **La valeur par défaut** est `validation_only = FALSE`.
#' 
#' @param quiet (optionnel)
#' 
#' Argument logique (*logical*) spécifiant s'il faut ou non afficher uniquement les informations essentielles telles que 
#' les avertissements, les erreurs et la période (ou l'ensemble de périodes) en cours de traitement. Vous pouvez également 
#' supprimer, si vous le souhaitez, l'affichage des informations relatives à la (aux) période(s) en cours de traitement en 
#' *enveloppant* votre appel à [tsbalancing()] avec [suppressMessages()]. Dans ce cas, le *data frame* de sortie 
#' `proc_grp_df` peut être utilisé pour identifier les problèmes d'équilibrage (infructueux) associés aux messages 
#' d'avertissement (le cas échéant). Notez que la spécification de `quiet = TRUE` annulera également l'argument `display_level`.
#'
#' **La valeur par défaut** est `quiet = FALSE`.
#'   
#'
#' @details 
#' Cette fonction résout un problème d'équilibrage par groupe de traitement (voir la section **Groupes de traitement** pour 
#' plus de détails). Chacun de ces problèmes d'équilibrage est un problème de minimisation quadratique de la forme suivante :
#' \deqn{\displaystyle 
#' \begin{aligned}
#' & \underset{\mathbf{x}}{\text{minimiser}} 
#' & & \mathbf{\left( y - x \right)}^{\mathrm{T}} W \mathbf{\left( y - x \right)} \\
#' & \text{sous contrainte(s)} 
#' & & \mathbf{l} \le A \mathbf{x} \le \mathbf{u}
#' \end{aligned}
#' }{min(x) (y - x)' W (y - x), sous contrainte(s) l <= Ax <= u}
#' où
#' - \eqn{\mathbf{y}}{y} est le vecteur des valeurs initiales du problème, c.-à-d., les valeurs de période initiales et, le cas 
#' échéant, les totaux temporels initiaux des séries chronologiques;
#' - \eqn{\mathbf{x}}{x} est la version finale (réconciliée) du vecteur \eqn{\mathbf{y}}{y};
#' - la matrice \eqn{W = \mathrm{diag} \left( \mathbf{w} \right)}{W = diag(w)} avec les éléments du vecteur \eqn{\mathbf{w}}{w} 
#' définis comme \eqn{w_i = \left\{
#'     \begin{array}{cl}
#'       0 & \text{if } |c_i y_i| = 0 \\
#'       \frac{1}{|c_i y_i|} & \text{sinon}
#'     \end{array} \right.
#'     }{w_i = 0 if |c_i y_i| = 0, w_i = 1/|c_i y_i| sinon}, 
#'     où \eqn{c_i} est coefficient d'altérabilité de la valeur du problème \eqn{y_i} et où les cas correspondant à \eqn{|c_i 
#'     y_i| = 0} sont des valeurs fixes (valeurs de période ou totaux temporels contraignants);
#' - la matrice \eqn{A} et les vecteurs \eqn{\mathbf{l}}{l} et \eqn{\mathbf{u}}{u} définissent les _contraintes d'équilibrage_, 
#' les _contraintes implicites d'agrégation temporelle_ (le cas échéant), les _bornes (inférieures et supérieures) des 
#' valeurs de période_ et _les contraintes \eqn{x_i = y_i} pour les valeurs \eqn{y_i} fixes_ \eqn{\left( \left| c_i y_i \right| 
#' = 0 \right)}{(|c_i y_i| = 0)}.
#'
#' En pratique, la fonction objectif du problème résolu par OSQP exclut le terme constant \eqn{\mathbf{y}^{\mathrm{T}} W 
#' \mathbf{y}}{y' W y}, correspondant alors à \eqn{\mathbf{x}^{\mathrm{T}} W \mathbf{x} - 2 \left( \mathbf{w} \mathbf{y} 
#' \right)^{\mathrm{T}} \mathbf{x}}{x' W x - 2 (w y)' x}, et les valeurs \eqn{y_i} fixes \eqn{\left( \left| c_i y_i \right| 
#' = 0 \right)}{(|c_i y_i| = 0)} sont exclues du problème, en ajustant les contraintes en conséquence, c.-à-d. :
#' - les lignes correspondant aux _contraintes \eqn{x_i = y_i} pour les valeurs \eqn{y_i} fixes_ sont supprimées de \eqn{A}, 
#' \eqn{\mathbf{l}}{l} et \eqn{\mathbf{u}}{u};
#' - les colonnes correspondant aux valeurs \eqn{y_i} fixes sont supprimées de \eqn{A} tout en ajustant de manière appropriée 
#' \eqn{\mathbf{l}}{l} et \eqn{\mathbf{u}}{u}.
#' 
#' 
######
# This subsection differs slightly between `tsraking()` and `tsbalancing` and is therefore maintained for both functions 
# (in both sets of roxygen2 comments) as opposed to being shared with `roxygen2 tag `@inheritSection`.
# => the "Temporal total preservation* paragraph is the SAME, however: keep them "in sync"!.
######
#' ## Coefficients d'altérabilité
#' Les coefficients d'altérabilité sont des nombres non négatifs qui modifient le coût relatif de la modification d'une valeur 
#' initiale du problème. En modifiant la fonction objectif à minimiser, ils permettent de générer un large éventail de solutions. 
#' Puisqu'ils apparaissent dans le dénominateur de la fonction objectif (matrice \eqn{W}), plus le coefficient d'altérabilité 
#' est élevé, moins il est coûteux de modifier une valeur du problème (valeur de période ou total temporel) et, inversement, 
#' plus le coefficient d'altérabilité est petit, plus il devient coûteux de le faire. Il en résulte que les valeurs du problème 
#' ayant des coefficients d'altérabilité plus élevés changent proportionnellement plus que celles ayant des coefficients 
#' d'altérabilité plus petits. Un coefficient d'altérabilité de \eqn{0.0} définit une valeur de problème fixe (contraignante), 
#' tandis qu'un coefficient d'altérabilité supérieur à \eqn{0.0} définit une valeur libre (non contraignante). Les coefficients 
#' d'altérabilité par défaut sont \eqn{0.0} pour les totaux temporels (argument `alter_temporal`) et \eqn{1.0} pour les valeurs 
#' de période (arguments `alter_pos`, `alter_neg`, `alter_mix`). Dans le cas courant des problèmes de ratissage (« *raking* ») 
#' de tables d'agrégation, les valeurs de période des totaux de marge (séries chronologiques avec un coefficient de \eqn{-1} 
#' dans les contraintes d'équilibrage) sont généralement contraignantes (spécifié avec `alter_neg = 0`) tandis que les valeurs 
#' de période des séries composantes (séries chronologiques avec un coefficient \eqn{1} dans les contraintes d'équilibrage) sont 
#' généralement non contraignantes (spécifié avec `alter_pos > 0`, ex., `alter_pos = 1`). Des valeurs de problème *presque 
#' contraignantes* (ex., pour les totaux de marge ou les totaux temporels) peuvent être obtenues en pratique en spécifiant de 
#' très petits (presque \eqn{0.0}) coefficents d'altérabilité par rapport à ceux des autres valeurs (non contraignantes) du 
#' problème.
#' 
#' **La préservation des totaux temporels** fait référence au fait que les totaux temporels, le cas échéant, sont 
#' généralement conservés « aussi près que possible » de leur valeur initiale. Une *préservation pure* est obtenue par 
#' défaut avec des totaux temporels contraignants, tandis que le changement est minimisé avec des totaux temporels non 
#' contraignants (conformément à l'ensemble de coefficients d'altérabilité utilisés).
#' 
#' 
#' ## Validation et dépannage
#' Les problèmes d'équilibrage fructueux (problèmes avec une solution valide) ont `sol_status_val > 0` ou, de manière 
#' équivalente, `n_unmet_con = 0` ou `max_discr <= validation_tol` dans le *data frame* de sortie `proc_grp_df`. 
#' Le dépannage des problèmes d'équilibrage infructueux n'est pas nécessairement simple. Voici quelques suggestions :
#' 
#' - Examinez les contraintes qui ont échoué (`unmet_flag = TRUE` ou, de manière équivalente, `discr_out > validation_tol` 
#' dans le *data frame* de sortie `prob_con_df`) pour s'assurer qu'elles ne causent pas un espace de solution vide 
#' (problème infaisable).
#' 
#' - Modifier la séquence de résolution d'OSQP. Par exemple, essayez :
#'   1. l' argument `full_sequence = TRUE`
#'   2. l' argument `osqp_settings_df = alternate_osqp_sequence`
#'   3. les arguments `osqp_settings_df = alternate_osqp_sequence` et `full_sequence = TRUE`
#' 
#'   Voir la `vignette("osqp-settings-sequence-dataframe")` pour plus de détails sur ce sujet.
#'   
#' - Augmenter (revoir) la valeur de `validation_tol`. Bien que cela puisse ressembler à de la *tricherie*, la valeur par 
#' défaut de `validation_tol` (\eqn{1 \times 10^{-3}}) peut en fait être trop petite pour les problèmes d'équilibrage qui 
#' impliquent de très grandes valeurs (ex., en milliards) ou, inversement, trop grande avec des valeurs de problème très 
#' petites (ex., \eqn{< 1.0}). Multiplier l'échelle moyenne des données du problème par la *tolérance de la machine* 
#' (`.Machine$double.eps`) donne une approximation de la taille moyenne des écarts que [tsbalancing()] devrait être capable 
#' de détecter (distinguer de \eqn{0}) et devrait probablement constituer une **limite inférieure absolue** pour l'argument 
#' `validation_tol`. En pratique, une valeur raisonnable de `validation_tol` devrait probablement être de \eqn{1 
#' \times 10^3} à \eqn{1 \times 10^6} fois plus grande que cette *limite inférieure*.
#' 
#' - S'attaquer aux contraintes redondantes. Les problèmes de ratissage (« *raking* ») de tables d'agrégation 
#' multidimensionnelles sont surspécifiés (ils impliquent des contraintes redondantes) lorsque tous les totaux de toutes 
#' les dimensions du *cube de données* sont contraignants (fixes) et qu'une contrainte est définie pour chacun d'entre eux. 
#' La redondance se produit également pour les contraintes implicites d'agrégation temporelle dans les tables d'agrégation
#' unidimensionnelles ou multidimensionnelles avec des totaux temporels contraignants (fixes). La surspécification n'est 
#' généralement pas un problème pour [tsbalancing()] si les données d'entrée ne sont pas contradictoires en ce qui concerne 
#' les contraintes redondantes, c'est-à-dire, s'il n'y a pas d'incohérences (d'écarts) associées aux contraintes redondantes 
#' dans les données d'entrée ou si elles sont *négligeables* (raisonnablement faibles par rapport à l'échelle des données 
#' du problème). Dans le cas contraire, cela peut conduire à des problèmes d'équilibrage infructueux [tsbalancing()]. Les 
#' solutions possibles sont alors les suivantes :
#'   1. Résoudre (ou réduire) les écarts associés aux contraintes redondantes dans les données d'entrée.
#'   2. Sélectionner un total de marge dans chaque dimension, sauf une, du cube de données et supprimer du problème les 
#'   contraintes d'équilibrage correspondantes. *Cela ne peut pas être fait pour les contraintes implicites d'agrégation 
#'   temporelle.*
#'   3. Sélectionnez un total de marge dans chaque dimension, sauf une, du cube de données et rendez-les non contraignantes 
#'   (coefficient d'altérabilité de, disons, \eqn{1.0}).
#'   4. Faire la même chose que (3) pour les totaux temporels d'une des séries composantes de l'intérieur du cube (les 
#'   rendre non contraignants).
#'   5. Rendre tous les totaux de marge de chaque dimension, sauf une, du cube de données *presque contraignants*, c.-à-d., 
#'   spécifier de très petits coefficients d'altérabilité (disons \eqn{1 \times 10^{-6}}) par rapport à ceux des séries 
#'   composantes de l'intérieur du cube. 
#'   6. Faire la même chose que (5) pour les totaux temporels de toutes les séries composantes de l'intérieur du cube 
#'   (coefficients d'altérabilité très petits, par exemple, avec l'argument `alter_temporal`).
#'   7. Utilisez [tsraking()] (le cas échéant), qui gère ces incohérences en utilisant l'inverse de Moore-Penrose 
#'   (distribution uniforme à travers tous les totaux contraignants).
#' 
#'   Les solutions (2) à (7) ci-dessus ne doivent être envisagées que si les écarts associés aux contraintes redondantes 
#'   dans les données d'entrée sont *raisonnablement faibles* car ils seraient distribués parmi les totaux omis ou non 
#'   contraignants avec [tsbalancing()] et tous les totaux contraignants avec [tsraking()]. Sinon, il faut d'abord étudier 
#'   la solution (1) ci-dessus.
#'   
#' - Assouplir (relaxer) les bornes des contraintes du problème, par exemple :
#'   - avec l'argument `tolV` pour les contraintes d'équilibrage;
#'   - avec les arguments `tolV_temporal` et `tolP_temporal` pour les contraintes implicites d'agrégation temporelle;
#'   - avec les arguments `lower_bound` et `upper_bound`.
#'   
#'   
#' # Groupes de traitement
#' L'ensemble des périodes d'un problème de réconciliation (ratissage ou équilibrage) donné est appelé *groupe de 
#' traitement* et correspond soit :
#' - à une **période unique** lors d'un traitement période par période ou, lorsque les totaux temporels sont préservés, 
#' pour les périodes individuelles d'un groupe temporel incomplet (ex., une année incomplète)
#' - ou à l'**ensemble des périodes d'un groupe temporel complet** (ex., une année complète) lorsque les totaux temporels 
#' sont préservés. 
#' 
#' Le nombre total de groupes de traitement (nombre total de problèmes de réconciliation) dépend de l'ensemble de périodes 
#' des séries chronologiques d'entrée (objet de type série chronologique spécifié avec l'argument `in_ts`) et de la valeur 
#' des arguments `temporal_grp_periodicity` et `temporal_grp_start`.
#' 
#' Les scénarios courants incluent `temporal_grp_periodicity = 1` (par défaut) pour un traitement période par période sans 
#' préservation des totaux temporels et \ifelse{latex}{\code{temporal_grp_periodicity = freq uency(in_ts)}}{
#' \code{temporal_grp_periodicity = frequency(in_ts)}} pour la préservation des totaux annuels (années civiles par défaut). 
#' L'argument `temporal_grp_start` permet de spécifier d'autres types d'années (_non civile_). Par exemple, des années 
#' financières commençant en avril correspondent à `temporal_grp_start = 4` avec des données mensuelles et à 
#' `temporal_grp_start = 2` avec des données trimestrielles. La préservation des totaux trimestriels avec des données 
#' mensuelles correspondrait à `temporal_grp_periodicity = 3`. 
#' 
#' Par défaut, les groupes temporels convrant plus d'une année (c.-à-d., correspondant à \ifelse{latex}{\code{
#' temporal_grp _periodicity > frequency(in_ts)}}{\code{temporal_grp_periodicity > frequency(in_ts)}}) débutent avec une année 
#' qui est un multiple de \ifelse{latex}{\code{ceiling( temporal_grp_periodicity / frequency(in_ts))}}{\code{
#' ceiling(temporal_grp_periodicity / frequency(in_ts))}}. Par exemple, les groupes bisannuels correspondant à 
#' `temporal_grp_periodicity = 2 * frequency(in_ts)` débutent avec une _année paire_ par défaut. Ce comportement peut être 
#' modifié avec l'argument `temporal_grp_start`. Par exemple, la préservation des totaux bisannuels débutant avec une _année 
#' impaire_ au lieu d'une _année paire_ (par défaut) correspond à `temporal_grp_start = frequency(in_ts) + 1` (avec 
#' \ifelse{latex}{\code{temporal_grp _periodicity = 2 * frequency(in_ts)}}{\code{temporal_grp_periodicity = 2 * frequency(in_ts)}}).
#' 
#' Voir les **Exemples** de [gs.build_proc_grps()] pour des scénarios courants de groupes de traitements.
#' 
#' 
#' # Comparaison de [tsraking()] et [tsbalancing()]
#' - [tsraking()] est limitée aux problèmes de ratissage (« *raking* ») de tables d'agrégation unidimensionnelles et 
#' bidimensionnelles (avec préservation des totaux temporels si nécessaire) alors que [tsbalancing()] traite des problèmes 
#' d'équilibrage plus généraux (ex., des problèmes de ratissage de plus grande dimension, solutions non négatives, 
#' contraintes linéaires générales d'égalité et d'inégalité par opposition à des règles d'agrégation uniquement, etc.)
#' - [tsraking()] renvoie la solution des moindres carrés généralisés du modèle de ratissage basé sur la régression de 
#' Dagum et Cholette (Dagum et Cholette 2006) tandis que [tsbalancing()] résout le problème de minimisation quadratique 
#' correspondant à l'aide d'un solveur numérique. Dans la plupart des cas, la *convergence vers le minimum* est atteinte 
#' et la solution de [tsbalancing()] correspond à la solution (exacte) des moindres carrés de [tsraking()]. Cela peut ne 
#' pas être le cas, cependant, si la convergence n'a pas pu être atteinte après un nombre raisonnable d'itérations. Cela 
#' dit, ce n'est qu'en de très rares occasions que la solution de [tsbalancing()] différera *significativement* de celle 
#' de [tsraking()].
#' - [tsbalancing()] est généralement plus rapide que [tsraking()], en particulier pour les gros problèmes de ratissage, 
#' mais est généralement plus sensible à la présence de (petites) incohérences dans les données d'entrée associées aux 
#' contraintes redondantes des problèmes de ratissage *entièrement spécifiés* (ou surspécifiés). [tsraking()] gère ces 
#' incohérences en utilisant l'inverse de Moore-Penrose (distribution uniforme à travers tous les totaux contraignants).
#' - [tsbalancing()] permet de spécifier des problèmes épars (clairsemés) sous leur forme réduite. Ce n'est pas le cas de 
#' [tsraking()] où les règles d'agrégation doivent toujours être entièrement spécifiées étant donné qu'un _cube de données 
#' complet_, sans données manquantes, est attendu en entrée (chaque série composante de l'*intérieur du cube* doit 
#' contribuer à toutes les dimensions du cube, c.-à-d., à chaque série totale des *faces extérieures du cube*). 
#' - Les deux outils traitent différemment les valeurs négatives dans les données d'entrée par défaut. Alors que les 
#' solutions des problèmes de ratissage obtenues avec [tsbalancing()] et [tsraking()] sont identiques lorsque tous les 
#' points de données d'entrée sont positifs, elles seront différentes si certains points de données sont négatifs (à 
#' moins que l'argument `Vmat_option = 2` ne soit spécifié avec [tsraking()]).
#' - Alors que [tsbalancing()] et [tsraking()] permettent toutes les deux de préserver les totaux temporels, la gestion 
#' du temps n'est pas incorporée dans [tsraking()]. Par exemple, la construction des groupes de traitement (ensembles de 
#' périodes de chaque problème de ratissage) est laissée à l'utilisateur avec [tsraking()] et des appels séparés doivent 
#' être soumis pour chaque groupe de traitement (chaque problème de ratissage). De là l'utilité de la fonction 
#' d'assistance [tsraking_driver()] pour [tsraking()].
#' - [tsbalancing()] renvoie le même ensemble de séries que l'objet d'entrée de type série chronologique (argument 
#' `in_ts`) alors que [tsraking()] renvoie l'ensemble des séries impliquées dans le problème de ratissage plus celles 
#' spécifiées avec l'argument `id` (qui pourrait correspondre à un sous-ensemble des séries d'entrée).
#'
#'
#' @returns
#' La fonction renvoie une liste de sept objets :
#' 
#' - `out_ts` : version modifiée de l'objet d'entrée de type série chronologique (classe « ts » ou « mts » ; voir 
#' l'argument `in_ts`) contenant les valeurs réconciliées des séries chronologiques qui résultent de l'exécution de 
#' la fonction (sortie principale de la fonction). Il peut être explicitement converti en un autre type d'objet avec 
#' la fonction `as*()` appropriée (ex., `tsibble::as_tsibble()` le convertirait en tsibble).
#' 
#' - `proc_grp_df` : *data frame* récapitulatif des groupes de traitement, utile pour identifier les problèmes 
#' fructueux ou infructueux. Il contient un enregistrement (une rangée) pour chaque problème d'équilibrage avec les 
#' colonnes suivantes :
#'   - `proc_grp` (num) : identificateur du groupe de traitement.
#'   - `proc_grp_type` (car) : type de groupe de traitement. Les valeurs possibles sont :
#'     - `"period"` (périodes uniques);
#'     - `"temporal group"` (groupes temporels).
#'   - `proc_grp_label` (car) : chaîne de caractères décrivant le groupe de traitement dans le format suivant :
#'     - `"<year>-<period>"` (périodes uniques)
#'     - `"<start year>-<start period> - <end year>-<end period>"` (groupes temporels)
#'   - `sol_status_val`, `sol_status` (num, car) : valeur numérique (entière) et chaîne de caractères associés au 
#'   statut de la solution :
#'     - ` 1` : `"valid initial solution"` (solution initiale valide);
#'     - `-1` : `"invalid initial solution"` (solution initiale invalide);
#'     - ` 2` : `"valid polished osqp solution"` (solution OSQP *raffinée* valide);
#'     - `-2` : `"invalid polished osqp solution"` (solution OSQP *raffinée* invalide);
#'     - ` 3` : `"valid unpolished osqp solution"` (solution OSQP *non raffinée* valide);
#'     - `-3` : `"invalid unpolished osqp solution"` (solution OSQP *non raffinée* invalide);
#'     - `-4` : `"unsolvable fixed problem"` (problème fixe insoluble, avec solution initiale invalide).
#'   - `n_unmet_con` (num) : nombre de contraintes non satisfaites (`sum(prob_conf_df$unmet_flag)`).
#'   - `max_discr` (num) : écart de contrainte maximal (`max(prob_conf_df$discr_out)`).
#'   - `validation_tol` (num) : tolérance spécifiée à des fins de validation (argument `validation_tol`).
#'   - `sol_type` (car) : type de solution renvoyée. Les valeurs possibles sont :
#'     - `"initial"` (solution initiale, c.-à-d., les valeurs des données d'entrée);
#'     - `"osqp"` (solution OSQP).
#'   - `osqp_attempts` (num) : nombre de tentatives effectuées avec OSQP (profondeur atteinte dans la séquence 
#'   de résolution).
#'   - `osqp_seqno` (num) : numéro d'étape de la séquence de résolution correspondant à la solution renvoyée. 
#'   `NA` lorsque `sol_type = "initial"`.
#'   - `osqp_status` (car) : chaîne de caractères décrivant le statut OSQP (`osqp_sol_info_df$status`). `NA` lorsque 
#'   `sol_type = "initial"`.
#'   - `osqp_polished` (logi) : `TRUE` si la solution OSQP renvoyée est *raffinée* (\ifelse{latex}{
#'   \code{osqp_sol_info_df $status_polish = 1}}{\code{osqp_sol_info_df$status_polish = 1}}), `FALSE` sinon. 
#'   `NA` lorsque `sol_type = "initial"`.
#'   - `total_solve_time` (num) : temps total, en secondes, de la séquence de résolution.
#'   
#'   La colonne `proc_grp` constitue une *clé unique* (enregistrements distincts) pour le *data frame*. Les problèmes 
#'   d'équilibrage fructueux (problèmes avec une solution valide) correspondent aux enregistrements avec 
#'   `sol_status_val > 0` ou, de manière équivalente, à `n_unmet_con = 0` ou à `max_discr <= validation_tol`. La 
#'   *solution initiale* (`sol_type = "initial"`) n'est renvoyée que si **a)** il n'y a pas de d'écarts de contraintes 
#'   initiaux, **b)** le problème est fixé (toutes les valeurs sont contraignantes) ou **c)** elle est meilleure que la 
#'   solution OSQP (total des écarts de contraintes plus faible). La séquence de résolution est décrite dans la 
#'   \ifelse{latex}{\code{vignette("osqp-settings -sequence-dataframe")}}{\code{vignette("osqp-settings-sequence-dataframe")}}.
#'   
#' - `periods_df` : *data frame* sur les périodes de temps, utile pour faire correspondre les périodes aux groupes 
#' de traitement. Il contient un enregistrement (une rangée) pour chaque période de l'objet d'entrée de type série 
#' chronologique (argument `in_ts`) avec les colonnes suivantes :
#'   - `proc_grp` (num) : identificateur du groupe de traitement.
#'   - `t` (num) : identificateur de la période (`1:nrow(in_ts)`).
#'   - `time_val` (num) : valeur de temps (`stats::time(in_ts)`). Correspond conceptuellement à \eqn{ann\acute{e}e + 
#'   (p\acute{e}riode - 1) / fr\acute{e}quence}.
#'   
#'   
######
# The previous extra blank roxygen2 line is necessary for proper rendering (non-itemization) of the following paragraph 
# in the French Rd file (?). The English Rd file is properly rendered without that extra blank roxygen2 line (!).
######
#'   Les colonnes `t` et `time_val` constituent toutes deux une *clé unique* (enregistrements distincts) pour le 
#'   *data frame*.
#'   
#' - `prob_val_df` : *data frame* sur les valeurs du problème, utile pour analyser les changements entre les valeurs 
#' initiales et finales (réconciliées). Il contient un enregistrement (une rangée) pour chaque valeur impliquée dans 
#' chaque problème d'équilibrage, avec les colonnes suivantes :
#'   - `proc_grp` (num) : identificateur du groupe de traitement.
#'   - `val_type` (car) : type de valeur du problème. Les valeurs possibles sont :
#'     - `"period value"` (valeur de période);
#'     - `"temporal total"` (total temporel).
#'   - `name` (car) : nom de la série chronologique (variable).
#'   - `t` (num) : identificateur de la période (`1:nrow(in_ts)`); identificateur de la première période du groupe 
#'   temporel pour un *total temporel*.
#'   - `time_val` (num) : valeur de temps (`stats::time(in_ts)`); valeur de la première période du groupe temporel 
#'   pour un *total temporel*. Correspond conceptuellement à \eqn{ann\acute{e}e + (p\acute{e}riode - 1) / fr\acute{e}quence}.  
#'   - `lower_bd`, `upper_bd` (num) : bornes des valeurs de période; toujours `-Inf` et `Inf` pour un *total temporel*.
#'   - `alter` (num) : coefficient d'altérabilité.
#'   - `value_in`, `value_out` (num) : valeurs initiales et finales (réconciliées).
#'   - `dif` (num) : `value_out - value_in`.
#'   - `rdif` (num) : `dif / value_in`; `NA` si `value_in = 0`.
#'   
#'   Les colonnes `val_type + name + t` et `val_type + name + time_val` constituent toutes deux une *clé unique* 
#'   (enregistrements distincts) pour le *data frame*. Les valeurs contraignantes (fixes) des problèmes correspondent aux 
#'   enregistrements avec `alter = 0` ou `value_in = 0`. Inversement, les valeurs de problèmes non contraignantes (libres) 
#'   correspondent aux enregistrements avec `alter != 0` et `value_in != 0`.
#'   
#' - `prob_con_df` : *data frame* sur les contraintes du problème, utile pour dépanner les problèmes infructueux (identifier 
#' les contraintes non satisfaites). Il contient un enregistrement (une rangée) pour chaque contrainte impliquée dans chaque 
#' problème d'équilibrage, avec les colonnes suivantes :
#'   - `proc_grp` (num) : identificateur du groupe de traitement.
#'   - `con_type` (car) : type de contrainte. Les valeurs possibles sont :
#'     - `"balancing constraint"` (contrainte d'équilibrage);
#'     - `"temporal aggregation constraint"` (contrainte d'agrégation temporelle);
#'     - `"period value bounds"` (bornes de valeur de période).
#' 
#'     Alors que les *contraintes d'équilibrage* sont spécifiées par l'utilisateur, les deux autres types de contraintes 
#'     (*contraintes d'agrégation temporelle* et *bornes de valeur de période*) sont automatiquement ajoutées au problème 
#'     par la fonction (le cas échéant).
#'   - `name` (car) : étiquette de la contrainte ou nom de la série chronologique (variable).
#'   - `t` (num) : identificateur de la période (`1:nrow(in_ts)`); identificateur de la première période du groupe 
#'   temporel pour une *contrainte d'agrégation temporelle*.
#'   - `time_val` (num) : valeur de temps (`stats::time(in_ts)`); valeur de la première période du groupe temporel 
#'   pour une *contrainte d'agrégation temporelle*. Correspond conceptuellement à \eqn{ann\acute{e}e + (p\acute{e}riode - 1) 
#'   / fr\acute{e}quence}.  
#'   - `l`, `u`, `Ax_in`, `Ax_out` (num) : éléments de contrainte initiaux et finaux \eqn{\left( \mathbf{l} \le A \mathbf{x} 
#'   \le \mathbf{u} \right)}{(l <= Ax <= u)}.
#'   - `discr_in`, `discr_out` (num) : écarts de contrainte initiaux et finaux \eqn{\left( \max \left( 0, \mathbf{l} - A 
#'   \mathbf{x}, A \mathbf{x} - \mathbf{u} \right) \right)}{(max(0, l - Ax, Ax - u))}.
#'   - `validation_tol` (num) : tolérance spécifiée à des fins de validation (argument `validation_tol`).
#'   - `unmet_flag` (logi) : `TRUE` si la contrainte n'est pas satisfaite (`discr_out > validation_tol`), `FALSE` sinon.
#' 
#'   Les colonnes `con_type + name + t` et `con_type + name + time_val` constituent toutes deux une *clé unique* 
#'   (enregistrements distincts) pour le *data frame*. Les bornes de contrainte \eqn{\mathbf{l = u}}{l = u} pour des 
#'   contraintes `EQ`, \eqn{\mathbf{l} = -\infty}{l = -Inf} pour des contraintes `LE`, \eqn{\mathbf{u} = \infty}{u = Inf} 
#'   pour des contraintes `GE`, et incluent les tolérances, le cas échéant, spécifiées avec les arguments `tolV`, 
#'   `tolV_temporal` et `tolP_temporal`.
#'   
#' - `osqp_settings_df` : *data frame* des paramètres d'OSQP. Il contient un enregistrement (une rangée) pour chaque 
#' problème (groupe de traitement) résolu avec OSQP (`proc_grp_df$sol_type = "osqp"`), avec les colonnes suivantes :
#'   - `proc_grp` (num) : identificateur du groupe de traitement.
#'   - une colonne correspondant à chaque élément de la liste renvoyée par la méthode \ifelse{latex}{\code{osqp::Get Params()}
#'   }{\code{osqp::GetParams()}} appliquée à un *objet solveur d'OSQP* (objet de classe « osqp_model » tel que renvoyé par 
#'   [osqp::osqp()]), ex. :
#'     - Nombre maximal d'itérations (`max_iter`);
#'     - Tolérances d'infaisabilité primale et duale (`eps_prim_inf` et `eps_dual_inf`);
#'     - Drapeau d'exécution de l'étape de raffinement de la solution (`polish`);
#'     - Nombre d'itérations de mise à l'échelle (`scaling`);
#'     - etc.
#'   - paramètres supplémentaires spécifiques à [tsbalancing()] :
#'     - `prior_scaling` (logi) : `TRUE` si les données du problème ont été mises à l'échelle (en utilisant la moyenne des 
#'     valeurs libres (non contraignantes) du problème comme facteur d'échelle) avant la résolution avec OSQP, `FALSE` sinon. 
#'     - `require_polished` (logi) : `TRUE` si une solution *raffinée* d'OSQP (\ifelse{latex}{
#'     \code{osqp_sol_info_df $status_polish = 1}}{\code{osqp_sol_info_df$status_polish = 1}}) était nécessaire pour cette 
#'     étape afin de terminer la séquence de résolution, `FALSE` sinon. Voir la `vignette("osqp-settings-sequence-dataframe")` 
#'     pour plus de détails sur la séquence de résolution utilisée par [tsbalancing()].
#'     
#'   La colonne `proc_grp` constitue une *clé unique* (enregistrements distincts) pour le *data frame*. Visitez le site 
#'   <https://osqp.org/docs/interfaces/solver_settings.html> pour tous les paramètres d'OSQP disponibles. Les problèmes 
#'   (groupes de traitement) pour lesquels la solution initiale a été renvoyée (`proc_grp_df$sol_type = "initial"`) ne sont 
#'   pas inclus dans ce *data frame*.
#'   
#' - `osqp_sol_info_df` : *data frame* d'informations sur les solutions OSQP. Il contient un enregistrement (une rangée) 
#' pour chaque problème (groupe de traitement) résolu avec OSQP (`proc_grp_df$sol_type = "osqp"`), avec les colonnes suivantes :
#'   - `proc_grp` (num) : identificateur du groupe de traitement.
#'   - une colonne correspondant à chaque élément de la liste `info` d'un *objet solveur d'OSQP* (objet de classe 
#'   « osqp_model » tel que renvoyé par [osqp::osqp()]), ex. :
#'     - Statut de la solution (`status` et `status_val`) ;
#'     - Statut de raffinement de la solution (`status_polish`) ;
#'     - Nombre d'itérations (`iter`) ;
#'     - Valeur de la fonction objectif (`obj_val`) ;
#'     - Résidus primal et dual (`pri_res` et `dua_res`) ;
#'     - Temps de résolution (`solve_time`) ;
#'     - etc.
#'   - informations supplémentaires spécifiques à [tsbalancing()] :
#'     - `prior_scaling_factor` (num) : valeur du facteur d'échelle lorsque \ifelse{latex}{\code{osqp_settings_df 
#'     $prior_scaling = TRUE}}{\code{osqp_settings_df$prior_scaling = TRUE}} (`prior_scaling_factor = 1.0` sinon).
#'     - `obj_val_ori_prob` (num) : valeur de la fonction objectif du problème d'équilibrage original, qui est la valeur 
#'     de la fonction objectif d'OSQP (`obj_val`) sur l'échelle originale (lorsque \code{osqp_settings_df$prior_scaling = TRUE}) 
#'     plus le terme constant de la fonction objectif du problème d'équilibrage original, c.-à-d., \code{obj_val_ori_prob = obj_val 
#'     * prior_scaling_factor + <terme constant>}, où `<terme constant>` correspond à \eqn{\mathbf{y}^{\mathrm{T}} W \mathbf{y}}{
#'     y' W y}. Voir la section **Détails** pour la définition du vecteur \eqn{\mathbf{y}}{y}, de la matrice \eqn{W} et, plus 
#'     généralement, de l'expression complète de la fonction objectif du problème d'équilibrage.  
#'     
#'   La colonne `proc_grp` constitue une *clé unique* (enregistrements distincts) pour le *data frame*. Visitez 
#'   <https://osqp.org> pour plus d'informations sur OSQP. Les problèmes (groupes de traitement) pour lesquels la solution 
#'   initiale a été renvoyée (`proc_grp_df$sol_type = "initial"`) ne sont pas inclus dans ce *data frame*.
#'
#' Notez que les objets de type « data.frame » renvoyés par la fonction peuvent être explicitement convertis en d'autres types 
#' d'objets avec la fonction `as*()` appropriée (ex., `tibble::as_tibble()` convertirait n'importe lequel d'entre eux en tibble).
#'   
#'
#' @references Dagum, E. B. et P. Cholette (2006). **Benchmarking, Temporal Distribution and Reconciliation Methods
#' of Time Series**. Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
#'
#' @references Ferland, M., S. Fortier et J. Bérubé (2016). « A Mathematical Optimization Approach to Balancing Time Series: 
#' Statistics Canada’s GSeriesTSBalancing ». Dans **JSM Proceedings, Business and Economic Statistics Section**. Alexandria, 
#' VA: American Statistical Association. 2292-2306.
#' 
#' @references Ferland, M. (2018). « Time Series Balancing Quadratic Problem — Hessian matrix and vector of linear objective 
#' function coefficients ». **Document interne**. Statistique Canada, Ottawa, Canada.
#'
#' @references Quenneville, B. et S. Fortier (2012). « Restoring Accounting Constraints in Time Series – Methods and
#' Software for a Statistical Agency ». **Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New York.
#' 
#' @references SAS Institute Inc. (2015). « The LP Procedure Sparse Data Input Format ». **SAS/OR\eqn{^\circledR}{®} 14.1 User's 
#' Guide: Mathematical Programming Legacy Procedures**. 
#' <https://support.sas.com/documentation/cdl/en/ormplpug/68158/HTML/default/viewer.htm#ormplpug_lp_details03.htm>
#' 
#' @references Statistique Canada (2016). « La macro ***GSeriesTSBalancing*** ». **Guide de l'utilisateur de G-Séries 2.0**.
#' Statistique Canada, Ottawa, Canada.
#'
#' @references Statistique Canada (2018). **Théorie et application de la réconciliation (Code du cours 0437)**.
#' Statistique Canada, Ottawa, Canada.
#'
#' @references Stellato, B., G. Banjac, P. Goulart et al. (2020). « OSQP: an operator splitting solver for quadratic programs ». 
#' **Math. Prog. Comp. 12**, 637–672 (2020). <https://doi.org/10.1007/s12532-020-00179-2>
#'
#'
#' @seealso [tsraking()] [tsraking_driver()] [rkMeta_to_blSpecs()] [gs.build_proc_grps()] [build_balancing_problem()] [aliases]
#'
#'
#' @example misc/function_examples/tsbalancing-ex.R
#'
#'
#' @export
tsbalancing <- function(in_ts,
                        problem_specs_df,
                        temporal_grp_periodicity = 1,
                        temporal_grp_start = 1,
                        osqp_settings_df = default_osqp_sequence,
                        display_level = 1,
                        alter_pos = 1,
                        alter_neg = 1,
                        alter_mix = 1,
                        alter_temporal = 0,
                        lower_bound = -Inf,
                        upper_bound = Inf,
                        tolV = 0,
                        tolV_temporal = 0,
                        tolP_temporal = NA,
                        
                        # New in G-Series 3.0
                        validation_tol = 0.001,
                        trunc_to_zero_tol = validation_tol,
                        full_sequence = FALSE,
                        validation_only = FALSE,
                        quiet = FALSE) {
  
  
  
  
  ### Internal functions ###
  
  # Display the Problem Specs data frame info
  #
  # Main (parent) function objects used in this function:
  #   - pb         : balancing problem core elements (building blocks), namely (elements of the list):
  #     - labels_df: problem specs labels
  #     - coefs_df : problem specs coefficients 
  #     - ser_names: vector of all series names involved in the balancing problem
  #     - lb       : lower bounds info (list object)
  #     - ub       : upper bounds info (list object)
  #     - alter    : period value alterability coefficients (list object)
  #     - altertmp : temporal total alterability coefficients (list object)
  #     - pos_ser  : vector of series names with only positive constraint coefficients (across all constraints)
  #     - neg_ser  : vector of series names with only negative constraint coefficients (across all constraints)
  #     - mix_ser  : vector of series names with both positive and negative constraint coefficients (across all constraints)
  #   - n_ser      : `length(pb$ser_names)`
  #   - n_con      : `length(pb$labels_df$row.lc[pb$labels_df$con.flag])`
  #   - arguments `alter_pos`, `alter_neg`, `alter_mix`, `alter_temporal`, `lower_bound`, `upper_bound`, 
  #     `validation_only` and `temporal_grp_periodicity`
  print_specs <- function() {
    
    # Function to build the balancing constraint string for display
    build_con_str <- function(type_val, row_val, col_vec, coef_vec) {
      rhs_logic <- (col_vec == "_rhs_")
      if (any(rhs_logic)) {
        rhs_str <- format(coef_vec[rhs_logic], big.mark = ",")
      } else {
        rhs_str <- "0"
      }
      series <- col_vec[!rhs_logic]
      coefs <- coef_vec[!rhs_logic]
      
      # A loop is used as opposed to a single `paste0(, collapse = "")` essentially for optimized display
      # of each single series constraint coefficient (e.g., avoid having "200x - 10.5y + 300z >= 1,000"
      # being displayed as "200.0x - 10.5y + 300.0z >= 1,000", i.e., with a decimal everywhere)
      #   => the loop is not that costly (compared to `paste0(, collapse = "")`)
      tmp <- format(abs(coefs[1]), big.mark = ",")
      con_str <- paste0(ifelse(coefs[1] < 0, "-", ""), ifelse(tmp == "1", "", tmp), series[1])
      for (ii in seq.int(from = 2, length.out = length(coefs) - 1)) {
        tmp <- format(abs(coefs[ii]), big.mark = ",")
        con_str <- paste0(con_str, ifelse(coefs[ii] < 0, " - ", " + "), ifelse(tmp == "1", "", tmp), series[ii])
      }
      
      if (type_val == "eq") {
        op <- " == "
      } else if (type_val == "le") {
        op <- " <= "
      } else {
        op <- " >= "
      }
      
      paste0("  ", row_val, ":\n    ", con_str, op, rhs_str)
    }
    
    header <- "Balancing Problem Elements"
    message("\n\n\n", header, "\n", paste0(rep.int("=", nchar(header)), collapse = ""))
    
    # Display constraints
    con_labels_df <- pb$labels_df[pb$labels_df$con.flag, , drop = FALSE]
    header <- paste0("Balancing Constraints (", n_con, ")")
    message("\n\n  ", header, "\n  ", paste0(rep.int("-", nchar(header)), collapse = ""))
    for (ii in seq.int(n_con)) {
      logi_vec <- pb$coefs_df$row.lc == con_labels_df$row.lc[ii]
      message("\n", build_con_str(type_val = con_labels_df$type.lc[ii],
                                  row_val = con_labels_df$row[ii],
                                  col_vec = pb$coefs_df$col[logi_vec],
                                  coef_vec = pb$coefs_df$coef[logi_vec]))
    }
    
    
    # Function to pad the values of a character data frame column (character vector) to the right 
    # so that it is displayed as a left-aligned character column
    pad_right <- function(x) {
      len <- max(nchar(x))
      # `sapply()` is safe: it always returns a character vector (`x` is of length minimum 1)
      paste0(x, sapply(len - nchar(x), 
                       function(x) paste0(rep(" ", x), collapse = "")))
      
    }
    
    # Initialize the series info data frame (lower/upper bounds and alter/alterTmp coef values and source)
    series_info_df <- data.frame(
      name = pb$ser_names,
      lb_val = rep.int(lower_bound, n_ser),
      lb_per = rep.int("", n_ser),
      lb_src = rep.int(lower_bound_label, n_ser),
      ub_val = rep.int(upper_bound, n_ser),
      ub_per = rep.int("", n_ser),
      ub_src = rep.int(upper_bound_label, n_ser),
      alter_val = rep.int(NA_real_, n_ser),
      alter_per = rep.int("", n_ser),
      alter_src = rep.int(NA_character_, n_ser),
      altertmp_val = rep.int(alter_temporal, n_ser),
      altertmp_per = rep.int("", n_ser),
      altertmp_src = rep.int(alter_temporal_label, n_ser)
    )
    
    # Assign the lower/upper bounds and alter coefs
    dated_info <- FALSE
    col_id_vec <- 1
    series_info_df$lb_val[pb$lb$nondated_id_vec] <- pb$lb$nondated_coefs
    series_info_df$lb_src[pb$lb$nondated_id_vec] <- "(problem specs)"
    series_info_df$lb_src <- pad_right(series_info_df$lb_src)
    # Treat period-specific values
    if (length(pb$lb$dated_id_vec) > 0) {
      dated_info <- TRUE
      series_info_df$lb_per[pb$lb$dated_id_vec] <- "*"
      col_id_vec <- c(col_id_vec, 2, 3, 4)
    } else {
      col_id_vec <- c(col_id_vec, 2, 4)
    }
    series_info_df$ub_val[pb$ub$nondated_id_vec] <- pb$ub$nondated_coefs
    series_info_df$ub_src[pb$ub$nondated_id_vec] <- "(problem specs)"
    series_info_df$ub_src <- pad_right(series_info_df$ub_src)
    if (length(pb$ub$dated_id_vec) > 0) {
      dated_info <- TRUE
      series_info_df$ub_per[pb$ub$dated_id_vec] <- "*"
      col_id_vec <- c(col_id_vec, 5, 6, 7)
    } else {
      col_id_vec <- c(col_id_vec, 5, 7)
    }
    if (!validation_only) {
      id_vec <- match(pb$pos_ser, pb$ser_names)
      series_info_df$alter_val[id_vec] <- alter_pos
      series_info_df$alter_src[id_vec] <- alter_pos_label
      id_vec <- match(pb$neg_ser, pb$ser_names)
      series_info_df$alter_val[id_vec] <- alter_neg
      series_info_df$alter_src[id_vec] <- alter_neg_label
      id_vec <- match(pb$mix_ser, pb$ser_names)
      series_info_df$alter_val[id_vec] <- alter_mix
      series_info_df$alter_src[id_vec] <- alter_mix_label
      series_info_df$alter_val[pb$alter$nondated_id_vec] <- pb$alter$nondated_coefs
      series_info_df$alter_src[pb$alter$nondated_id_vec] <- "(problem specs)"
      series_info_df$alter_src <- pad_right(series_info_df$alter_src)
      if (length(pb$alter$dated_id_vec) > 0) {
        dated_info <- TRUE
        series_info_df$alter_per[pb$alter$dated_id_vec] <- "*"
        col_id_vec <- c(col_id_vec, 8, 9, 10)
      } else {
        col_id_vec <- c(col_id_vec, 8, 10)
      }
      if (temporal_grp_periodicity != 1) {
        series_info_df$altertmp_val[pb$altertmp$nondated_id_vec] <- pb$altertmp$nondated_coefs
        series_info_df$altertmp_src[pb$altertmp$nondated_id_vec] <- "(problem specs)"
        series_info_df$altertmp_src <- pad_right(series_info_df$altertmp_src)
        if (length(pb$altertmp$dated_id_vec) > 0) {
          dated_info <- TRUE
          series_info_df$altertmp_per[pb$altertmp$dated_id_vec] <- "*"
          col_id_vec <- c(col_id_vec, 11, 12, 13)
        } else {
          col_id_vec <- c(col_id_vec, 11, 13)
        }
      }
    }
    
    # Keep relevant columns and assign the (duplicate/empty) column names for display
    series_info_df <- data.frame(series_info_df[col_id_vec])
    cols_names <- c("name",
                    "lowerBd", "", "",
                    "upperBd", "", "",
                    "alter", "", "", 
                    "alterTmp", "", "")
    names(series_info_df) <- cols_names[col_id_vec]
    
    # Display the time series info
    header <- "Time Series Info"
    message("\n\n  ", header, "\n  ", paste0(rep.int("-", nchar(header)), collapse = ""))
    message("\n", paste0("  ", utils::capture.output(print.data.frame(series_info_df)), collapse = "\n"))
    if (dated_info) {
      message("\n  * indicates cases where period-specific values (`timeVal` is not `NA`) are specified in the problem specs data frame.")
    }
    message("\n")
  }
  
  
  # Functions to set up `sink()` in order to store "output" type display (sent to `stdout()`) in a text file,
  # wrap up (close) `sink()` and display the text file contents as a "message" (sent to `stderr()`)
  #
  # Argument:
  #   - txtfile: name and path of the (temporary) text file that will store the output
  #
  # Other main (parent) function objects used in this function:
  #   - osqp_output_file: name and path of the (temporary) text file to be deleted as the function exits
  sink_setup <- function(txtfile) {
    sink(file = txtfile, type = c("output", "message"))
    invisible(NULL)
  }
  sink_wrapup <- function(txtfile) {
    sink()
    osqp_output_file <<- txtfile
    msg <- paste0("  ", readLines(txtfile), collapse = "\n")
    message("\n", msg)
    invisible(NULL)
  }
  
  
  # Display the balancing results (problem values and constraints data frames)
  #
  # Main (parent) function objects used in this function:
  #   - prob_val_df: balancing problem values data frame
  #   - prob_con_df: balancing problem constraints data frame
  print_results <- function() {
    
    
    # Problem values data frame
    
    header <- "Problem Values"
    lines <- paste0(rep.int("-", nchar(header)), collapse = "")
    message("\n  ", lines, "\n  ", header, "\n  ", lines, "\n")
    logi_vec <- (prob_val_df$val_type == "temporal total")
    if (sum(logi_vec) == 0) {
      df <- prob_val_df[, -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE, big_mark = ",")),
                     collapse = "\n"), "\n")
    } else {
      header <- "Period Values"
      lines <- paste0(rep.int("-", nchar(header)), collapse = "")
      message("  ", header, "\n  ", lines)
      df <- prob_val_df[!logi_vec, -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)), collapse = "\n"), "\n")
      header <- "Temporal Totals"
      lines <- paste0(rep.int("-", nchar(header)), collapse = "")
      message("  ", header, "\n  ", lines)
      df <- prob_val_df[logi_vec, -c(1, 2, 4, 5, 6, 7)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)), collapse = "\n"), "\n")
    }
    
    
    # Problem constraints data frame
    
    header <- "Problem Constraints (l <= Ax <= u)"
    lines <- paste0(rep.int("-", nchar(header)), collapse = "")
    message("\n  ", lines, "\n  ", header, "\n  ", lines, "\n")
    
    if (length(unique(prob_con_df$con_type)) == 1) {
      df <- prob_con_df[, -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)),
                     collapse = "\n"), "\n")
    } else {
      header <- "Balancing Constraints"
      lines <- paste0(rep.int("-", nchar(header)), collapse = "")
      message("  ", header, "\n  ", lines)
      df <- prob_con_df[prob_con_df$con_type == "balancing constraint", -c(1, 2)]
      message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)), collapse = "\n"), "\n")
      logi_vec <- (prob_con_df$con_type == "period value bounds")
      if (sum(logi_vec) > 0) {
        header <- "Period Value Bounds"
        lines <- paste0(rep.int("-", nchar(header)), collapse = "")
        message("  ", header, "\n  ", lines)
        df <- prob_con_df[logi_vec, -c(1, 2)]
        message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)),
                       collapse = "\n"), "\n")
      }
      logi_vec <- (prob_con_df$con_type == "temporal aggregation constraint")
      if (sum(logi_vec) > 0) {
        header <- "Temporal Aggregation Constraints"
        lines <- paste0(rep.int("-", nchar(header)), collapse = "")
        message("  ", header, "\n  ", lines)
        df <- prob_con_df[logi_vec, -c(1, 2, 4, 5)]
        message(paste0("  ", utils::capture.output(print.data.frame(df, row.names = FALSE)),
                       collapse = "\n"), "\n")
      }
    }
    message("")
  }
  
  
  
  
  ### Main function ###
  
  # Initialize the object to be returned by the function via `on.exit()`
  out_list <- NULL
  on.exit(return(out_list))
  warning_flag <- FALSE
  
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
    displayLevel_lab <- ""  # won't be displayed anyway
    specs_display_func <- gs.NULL_func
    solve_msg_func <- gs.NULL_func
    osqp_verbose <- FALSE
    osqpBeg_display_func <- gs.NULL_func
    osqpEnd_display_func <- gs.NULL_func
    osqp_output_file <- NULL
    results_display_func <- gs.NULL_func
  } else {
    quiet_msg_func <- message
    quiet_lab <- "    (*)quiet                 = FALSE (default)"
    
    tmp <- (unlist(display_level))[1]
    if (!identical(display_level, tmp) || is.null(tmp) || !(tmp %in% 0:3)) {
      stop("Argument 'display_level' must take value 0, 1, 2, or 3.\n\n", call. = FALSE)
    }
    display_level <- as.integer(display_level)
    displayLevel_lab <- paste0("    display_level            = ", format(display_level))
    width_opt <- getOption("width")
    if (width_opt < 128) {
      on.exit(options(width = width_opt), add = TRUE)
      options(width = 128)
    }
    if (display_level == 1) {
      displayLevel_lab <- paste0(displayLevel_lab, " (default)")
      specs_display_func <- print_specs
      solve_msg_func <- gs.NULL_func
      osqp_verbose <- FALSE
      osqpBeg_display_func <- gs.NULL_func
      osqpEnd_display_func <- gs.NULL_func
      osqp_output_file <- NULL
      results_display_func <- gs.NULL_func
    } else if (display_level == 0) {
      specs_display_func <- gs.NULL_func
      solve_msg_func <- gs.NULL_func
      osqp_verbose <- FALSE
      osqpBeg_display_func <- gs.NULL_func
      osqpEnd_display_func <- gs.NULL_func
      osqp_output_file <- NULL
      results_display_func <- gs.NULL_func
    } else {
      specs_display_func <- print_specs
      solve_msg_func <- message
      osqp_verbose <- TRUE
      osqpBeg_display_func <- sink_setup
      osqpEnd_display_func <- sink_wrapup
      osqp_output_file <- ".gseries_osqp_output.txt"
      on.exit(invisible(suppressWarnings(file.remove(osqp_output_file))), add = TRUE)
      if (display_level == 3) {
        results_display_func <- print_results
      } else {
        results_display_func <- gs.NULL_func
      }
    }
  }
  
  
  # Display the function header
  quiet_msg_func("\n\n", gs.header, "\n\ntsbalancing() function:\n")
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  
  # Initial argument validation
  
  # Mandatory arguments (without default values)
  in_ts_name <- deparse1(substitute(in_ts))
  tmp <- nchar(in_ts_name)
  if (tmp == 0) {
    stop("Argument 'in_ts' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    in_ts_name <- paste0(substr(in_ts_name, 1, 55), "<...>")
  }
  if (grepl("structure(", in_ts_name, fixed = TRUE)) {
    in_ts_name <- "<argument 'in_ts'>"
  }
  in_ts <- in_ts
  if (!stats::is.ts(in_ts)) {
    stop("Argument 'in_ts' is not a 'ts' object.\n\n", call. = FALSE)
  }
  in_ts <- stats::as.ts(in_ts)
  ts_freq <- stats::frequency(in_ts)
  time_values <- as.numeric(stats::time(in_ts))
  periods <- gs.time2str(in_ts)
  n_per <- length(periods)
  
  specs_df_name <- deparse1(substitute(problem_specs_df))
  tmp <- nchar(specs_df_name)
  if (tmp == 0) {
    stop("Argument 'problem_specs_df' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    specs_df_name <- paste0(substr(specs_df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", specs_df_name, fixed = TRUE)) {
    specs_df_name <- "<argument 'problem_specs_df'>"
  }
  problem_specs_df <- problem_specs_df
  if (!is.data.frame(problem_specs_df)) {
    stop("Argument 'problem_specs_df' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  problem_specs_df <- as.data.frame(problem_specs_df)
  row.names(problem_specs_df) <- NULL
  
  # Optional arguments (with default values).
  # => Note that the following optional arguments, only relevant when `validation_only == FALSE`,
  #    will be validated later:
  #      - `temporal_grp_periodicity`
  #      - `temporal_grp_start`
  #      - `osqp_settings_df`
  #      - `alter_pos`
  #      - `alter_neg`
  #      - `alter_mix`
  #      - `alter_temporal`
  #      - `tolV_temporal` and `tolP_temporal`
  #      - `trunc_to_zero_tol`
  tmp <- (unlist(lower_bound))[1]
  if (!identical(lower_bound, tmp) || is.null(tmp) || is.na(tmp) || !is.finite(tmp) && tmp != -Inf) {
    stop("Argument 'lower_bound' must be a finite real number or -Inf.\n\n", call. = FALSE)
  }
  tmp <- (unlist(upper_bound))[1]
  if (!identical(upper_bound, tmp) || is.null(tmp) || is.na(tmp) || !is.finite(tmp) && tmp != Inf) {
    stop("Argument 'upper_bound' must be a finite real number or Inf.\n\n", call. = FALSE)
  }
  if (lower_bound > upper_bound) {
    stop("Arguments `lower_bound` and 'upper_bound' are not compatible (`lower_bound = ",
         format(lower_bound, big.mark = ","), " > ", format(upper_bound, big.mark = ","),
         " = upper_bound`).\n\n", call. = FALSE)
  }
  tmp <- (unlist(tolV))[1]
  if (!identical(tolV, tmp) || is.null(tmp) || !is.finite(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'tolV' must be a nonnegative finite real number.\n\n", call. = FALSE)
  }
  tmp <- (unlist(validation_tol))[1]
  if (!identical(validation_tol, tmp) || is.null(tmp) || !is.finite(tmp) || is.finite(tmp) && tmp < 0) {
    stop("Argument 'validation_tol' must be a nonnegative finite real number.\n\n", call. = FALSE)
  }
  validation_only <- gs.validate_arg_logi(validation_only)
  
  if (validation_only) {
    valid_only_lab <- "    (*)validation_only       = TRUE"
    solve_func <- return_initial_sol
    solve_str <- "Input Values Validation"
    solve_word <- "Validating"
    
    # Force period-by-period processing
    temporal_grp_periodicity <- 1
    temp_grp_per_lab <- "    temporal_grp_periodicity (ignored)"
    temporal_grp_start <- NA_integer_
    temp_grp_start_lab <- "    temporal_grp_start       (ignored)"
    
    # Set other ignored arguments
    settings_df <- osqp_settings_df
    settingsDF_lab <- "    osqp_settings_df         (ignored)"
    alter_pos <- NA_real_
    alterPos_lab <- "    alter_pos                (ignored)"
    alter_pos_label <- NA_character_
    alter_neg <- NA_real_
    alterNeg_lab <- "    alter_neg                (ignored)"
    alter_neg_label <- NA_character_
    alter_mix <- NA_real_
    alterMix_lab <- "    alter_mix                (ignored)"
    alter_mix_label <- NA_character_
    alter_temporal <- NA_real_
    alterTmp_lab <- "    alter_temporal           (ignored)"
    alter_temporal_label <- NA_character_
    tolV_temporal <- NA_real_
    tolP_temporal <- NA_real_
    tol_temporal_lab <- "    tolV_temporal            (ignored)"
    trunc_to_zero_tol <- NA_real_
    zero_trunc_lab <- "    (*)trunc_to_zero_tol     (ignored)"
    
  } else {
    valid_only_lab <- paste0("    (*)validation_only       = FALSE (default)")
    solve_func <- solve_one_osqp
    solve_str <- "Problem Solving"
    solve_word <- "Balancing"
    
    # Validate optional argument `temporal_grp_periodicity` (and set the header label)
    tmp <- (unlist(temporal_grp_periodicity))[1]
    if (!identical(temporal_grp_periodicity, tmp) || is.null(tmp) || !is.finite(tmp) ||
        is.finite(tmp) && (tmp <= 0 || tmp != as.integer(tmp))) {
      stop("Argument 'temporal_grp_periodicity' must be a positive integer.\n\n", call. = FALSE)
    }
    temporal_grp_periodicity <- as.integer(temporal_grp_periodicity)
    temp_grp_per_lab <- paste0("    temporal_grp_periodicity = ", format(temporal_grp_periodicity))
    if (temporal_grp_periodicity == 1) {
      temp_grp_per_lab <- paste0(temp_grp_per_lab, " (default)")
      temporal_grp_start <- NA_integer_
      temp_grp_start_lab <- paste0("    temporal_grp_start       (ignored)")
      alter_temporal <- NA_real_
      alterTmp_lab <- "    alter_temporal           (ignored)"
      alter_temporal_label <- NA_character_
      tolV_temporal <- NA_real_
      tolP_temporal <- NA_real_
      tol_temporal_lab <- "    tolV_temporal            (ignored)"
    } else {
      
      # Validate optional argument `temporal_grp_start` (and set the header label)
      tmp <- (unlist(temporal_grp_start))[1]
      if (!identical(temporal_grp_start, tmp) || is.null(tmp) || !is.finite(tmp) ||
          is.finite(tmp) && (tmp <= 0 || tmp > temporal_grp_periodicity || tmp != as.integer(tmp))) {
        stop("Argument 'temporal_grp_start' must be an integer in the [1..", temporal_grp_periodicity, "] interval.\n\n",
             call. = FALSE)
      }
      temporal_grp_start <- as.integer(temporal_grp_start)
      temp_grp_start_lab <- paste0("    temporal_grp_start       = ", format(temporal_grp_start))
      if (temporal_grp_start == 1) {
        temp_grp_start_lab <- paste0(temp_grp_start_lab, " (default)")
      }
      
      # Validate optional argument `alter_temporal`
      tmp <- (unlist(alter_temporal))[1]
      if (!identical(alter_temporal, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
        stop("Argument 'alter_temporal' must be a nonnegative finite real number.\n\n", call. = FALSE)
      }
      alterTmp_lab <- paste0("    alter_temporal           = ", format(alter_temporal, big.mark = ","))
      if (alter_temporal == 0) {
        alterTmp_lab <- paste0(alterTmp_lab, " (default)")
        alter_temporal_label <- "(default)"
      } else {
        alter_temporal_label <- "(arg `alter_temporal`)"
      }
      
      # Validate the binding temporal total tolerances (and set the header label)
      tmp <- (unlist(tolV_temporal))[1]
      if (is.null(tmp)) {
        tolV_temporal <- NA_real_
      } else if (!identical(tolV_temporal, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
        stop("Argument 'tolV_temporal' must be a nonnegative finite real number or NA.\n\n", call. = FALSE)
      }
      tmp <- (unlist(tolP_temporal))[1]
      if (is.null(tmp)) {
        tolP_temporal <- NA_real_
      } else if (!identical(tolP_temporal, tmp) || !is.finite(tmp) && !is.na(tmp) || is.finite(tmp) && tmp < 0) {
        stop("Argument 'tolP_temporal' must be a nonnegative finite real number or NA.\n\n", call. = FALSE)
      }
      if (!is.na(tolV_temporal)) {
        if (!is.na(tolP_temporal)) {
          stop("Arguments 'tolV_temporal' and 'tolP_temporal' cannot be both specified (one must be NA).\n\n", call. = FALSE)
        }
        tol_temporal_lab <- paste0("    tolV_temporal            = ", format(tolV_temporal))
        if (abs(tolV_temporal) < gs.tolerance) {
          tol_temporal_lab <- paste0(tol_temporal_lab, " (default)")
        }
        tolP_temporal <- 0
      } else {
        if (is.na(tolP_temporal)) {
          stop("Arguments 'tolV_temporal' and 'tolP_temporal' cannot be both NA (one must be specified).\n\n", call. = FALSE)
        }
        tol_temporal_lab <- paste0("    tolP_temporal            = ", format(tolP_temporal))
        tolV_temporal <- 0
      }
    }
    
    # Validate optional argument `osqp_settings_df` (and set the header label)
    settingsDF_lab <- "    osqp_settings_df         = "
    if (is.null(osqp_settings_df)) {
      settingsDF_lab <- paste0(settingsDF_lab, "NULL (default OSQP settings)")
      # Set OSQP setting `verbose` (based on arguments `quiet` and `display_level`), 
      # `require_polished = FALSE` and  `prior_scaling = FALSE`
      settings_df <- data.frame(verbose = osqp_verbose, require_polished = FALSE, prior_scaling = FALSE)
    } else {
      settings_df_name <- deparse1(substitute(osqp_settings_df))
      if (nchar(settings_df_name) >= 60) {
        settings_df_name <- paste0(substr(settings_df_name, 1, 55), "<...>")
      }
      if (grepl("structure(", settings_df_name, fixed = TRUE)) {
        settings_df_name <- "<argument 'osqp_settings_df'>"
      }
      settings_df <- osqp_settings_df
      if (!is.data.frame(settings_df)) {
        warning("Argument 'settings_df_name' is not a 'data.frame' object. It will be ignored and the default OSQP ",
                "settings sequence data frame (package data frame `default_osqp_sequence`) will be  used instead.\n",
                call. = FALSE, immediate. = TRUE)
        settings_df <- default_osqp_sequence
        settings_df_name <- "default_osqp_sequence"
      }
      # Set (add/overwrite) OSQP setting `verbose` (based on arguments `quiet` and `display_level`)
      settings_df$verbose <- osqp_verbose
      if (settings_df_name %in% c("default_osqp_sequence", "gseries::default_osqp_sequence")) {
        settingsDF_lab <- paste0(settingsDF_lab, settings_df_name, " (default)")
      } else {
        settingsDF_lab <- paste0(settingsDF_lab, settings_df_name)
        # Remove duplicate rows and row names (just in case)
        settings_df <- unique(settings_df)
        row.names(settings_df) <- NULL
      }
      # Set `require_polished`
      settings_cols <- names(settings_df)
      if ("require_polished" %in% settings_cols) {
        # Impose polishing when `require_polished == TRUE`
        if ("polish" %in% settings_cols) {
          settings_df$polish <- (settings_df$polish | settings_df$require_polished)
        } else {
          settings_df$polish <- settings_df$require_polished
        }
      } else {
        settings_df$require_polished <- FALSE
      }
      # Set `prior_scaling` 
      if (!("prior_scaling" %in% settings_cols)) {
        settings_df$prior_scaling <- FALSE
      }
    }
    
    # Validate the alterability coefficient optional arguments
    tmp <- (unlist(alter_pos))[1]
    if (!identical(alter_pos, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
      stop("Argument 'alter_pos' must be a nonnegative finite real number.\n\n", call. = FALSE)
    }
    alterPos_lab <- paste0("    alter_pos                = ", format(alter_pos, big.mark = ","))
    if (alter_pos == 1) {
      alterPos_lab <- paste0(alterPos_lab, " (default)")
      alter_pos_label <- "(default)"
    } else {
      alter_pos_label <- "(arg `alter_pos`)"
    }
    tmp <- (unlist(alter_neg))[1]
    if (!identical(alter_neg, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
      stop("Argument 'alter_neg' must be a nonnegative finite real number.\n\n", call. = FALSE)
    }
    alterNeg_lab <- paste0("    alter_neg                = ", format(alter_neg, big.mark = ","))
    if (alter_neg == 1) {
      alterNeg_lab <- paste0(alterNeg_lab, " (default)")
      alter_neg_label <- "(default)"
    } else {
      alter_neg_label <- "(arg `alter_neg`)"
    }
    tmp <- (unlist(alter_mix))[1]
    if (!identical(alter_mix, tmp) || is.null(tmp) || !is.finite(tmp) || tmp < 0) {
      stop("Argument 'alter_mix' must be a nonnegative finite real number.\n\n", call. = FALSE)
    }
    alterMix_lab <- paste0("    alter_mix                = ", format(alter_mix, big.mark = ","))
    if (alter_mix == 1) {
      alterMix_lab <- paste0(alterMix_lab, " (default)")
      alter_mix_label <- "(default)"
    } else {
      alter_mix_label <- "(arg `alter_mix`)"
    }
    
    # Validate optional argument `trunc_to_zero_tol` (and set the header label)
    tmp <- (unlist(trunc_to_zero_tol))[1]
    if (!identical(trunc_to_zero_tol, tmp) || is.null(tmp) || !is.finite(tmp) || is.finite(tmp) && tmp < 0) {
      stop("Argument 'trunc_to_zero_tol' must be a nonnegative finite real number.\n\n",
           call. = FALSE)
    }
    if (abs(trunc_to_zero_tol - validation_tol) < gs.tolerance) {
      zero_trunc_lab <- "    (*)trunc_to_zero_tol     = validation_tol (default)"
    } else {
      zero_trunc_lab <- paste0("    (*)trunc_to_zero_tol     = ", format(trunc_to_zero_tol))
    }
    
    # Validate optional argument `full_sequence`
    full_sequence <- gs.validate_arg_logi(full_sequence)
  }
  
  # Display the function call (argument values)
  quiet_msg_func("    in_ts                    = ", in_ts_name)
  quiet_msg_func("    problem_specs_df         = ", specs_df_name)
  quiet_msg_func(temp_grp_per_lab)
  quiet_msg_func(temp_grp_start_lab)
  quiet_msg_func(settingsDF_lab)
  quiet_msg_func(displayLevel_lab)
  quiet_msg_func(alterPos_lab)
  quiet_msg_func(alterNeg_lab)
  quiet_msg_func(alterMix_lab)
  quiet_msg_func(alterTmp_lab)
  lab <- paste0("    lower_bound              = ", format(lower_bound, big.mark = ","))
  if (lower_bound == -Inf) {
    lab <- paste0(lab, " (default)")
    lower_bound_label <- "(default)"
  } else {
    lower_bound_label <- "(arg `lower_bound`)"
  }
  quiet_msg_func(lab)
  lab <- paste0("    upper_bound              = ", format(upper_bound, big.mark = ","))
  if (upper_bound == Inf) {
    lab <- paste0(lab, " (default)")
    upper_bound_label <- "(default)"
  } else {
    upper_bound_label <- "(arg `upper_bound`)"
  }
  quiet_msg_func(lab)
  lab <- paste0("    tolV                     = ", format(tolV))
  if (tolV < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(tol_temporal_lab, "\n")
  lab <- paste0("    (*)validation_tol        = ", format(validation_tol))
  if (abs(validation_tol - 0.001) < gs.tolerance) {
    lab <- paste0(lab, " (default)")
  }
  quiet_msg_func(lab)
  quiet_msg_func(zero_trunc_lab)
  quiet_msg_func(valid_only_lab)
  quiet_msg_func(quiet_lab, "\n")
  quiet_msg_func("    (*) indicates new arguments in G-Series 3.0\n")
  
  
  # Build the core elements (building blocks) for the balancing problems (while validating the specified 
  # info), excluding the temporal totals info (will be added later, inside the processing groups loop):
  #   - labels_df: cleaned-up version of the label definition records from `problem_specs_df` 
  #                (rows where `type` is non-missing); extra columns:
  #                  - type.lc : `tolower(type)`
  #                  - row.lc  : `tolower(row)` 
  #                  - con.flag: `type.lc %in% c("eq", "le", "ge")`
  #   - coefs_df : cleaned-up version of the information specification records from `problem_specs_df` 
  #                (rows where `type` is missing); extra columns:
  #                  - row.lc  : `tolower(row)` 
  #                  - con.flag: `labels_df$con.flag` allocated through `row.lc`
  #   - values_ts: reduced version of 'in_ts' with only the relevant series (see vector `ser_names`)
  #   - lb       : lower bound info (`type.lc = "lowerbd"`) for the relevant series; list object with the 
  #                following elements:
  #                  - coefs_ts       : lower bound values for series and period
  #                  - nondated_coefs : vector of nondated lower bounds from `problem_specs_df` (`timeVal` is `NA`)
  #                  - nondated_id_vec: vector of `ser_names` id's associated to vector `nondated_coefs`
  #                  - dated_id_vec   : vector of `ser_names` id's associated to dated lower bounds from 
  #                                     `problem_specs_df` (`timeVal` is not `NA`)
  #   - ub       : same as `lb` but for upper bounds (`type.lc = "upperbd"`)
  #   - alter    : same as `lb` but for period value alterability coefficients (`type.lc = "alter"`)
  #   - altertmp : same as `lb` but for temporal total alterability coefficients (`type.lc = "altertmp"`)
  #   - ser_names: vector of the relevant series names (set of series involved in the balancing constraints)
  #   - pos_ser  : vector of series names that have only positive coefficients across all balancing constraints
  #   - neg_ser  : vector of series names that have only negative coefficients across all balancing constraints
  #   - mix_ser  : vector of series names that have both positive and negative coefficients across all balancing 
  #                constraints
  #   - A1,op1,b1: period level (single-period) balancing constraint elements (`A1 %*% x op1 b1` for 
  #                coherent/reconciled data)
  #   - A2,op2,b2: temporal group level (multi-period) balancing constraint elements (`A2 %*% x op2 b2` for 
  #                coherent/reconciled data)
  #
  # Notes:
  #
  #   - The returned balancing problem elements do not include the implicit temporal totals for multi-period 
  #     processing (i.e., elements `A2`, `op2` and `b2` only contain the balancing constraints info).
  #       
  #   - Multi-period balancing problem elements `A2`, `op2` and `b2` are constructed in "column-major order",
  #     corresponding to the default behaviour of R for converting matrices into vectors. E.g.:
  #       - single-period processing (period `t`):
  #           `A1 %*% as.vector(values_ts[t, ]) op1 b1` for coherent/reconciled data
  #       - multi-period processing (periods `t1:t2` of length `temporal_grp_periodicity`):
  #           `A2 %*% as.vector(values_ts[t1:t2, ]) op2 b2` for coherent/reconciled data
  # 
  #   - Default temporal total alterability coefficients (`altertmp$coefs_ts`) for cases not specified in the 
  #     problem specs data frame (`problem_specs_df`) remain `NA` at this stage (i.e., argument `alter_temporal` 
  #     has not been used yet at this point). When time comes, this will allow for easy identification of the
  #     first specified (non `NA`) temporal total alter coef in the specs inside a complete temporal group.
  # 
  #   - A "wide range" of reserved keywords for column `type` in the specs (for label definition records) 
  #     are accepted in practice (i.e., the list of accepted keywords, in lowercase, include):
  #   - A "wide range" of reserved keywords for column `type` in the specs (for label definition records) 
  #     are accepted in practice. The list of accepted keywords, in lowercase, include:
  #       - "==" and "=" for "eq"
  #       - "<=" and "<" for "le"
  #       - ">=" and ">" for "ge"
  #       - "lower" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "lowerbd"
  #       - "upper" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "upperbd"
  #       - "alter" + ("" or "_" or "-" or "." or " ") + ("tmp" or "temp" or "temporal) for "altertmp"
  #
  pb <- build_balancing_problem(in_ts                    = in_ts,
                                problem_specs_df         = problem_specs_df,
                                in_ts_name               = in_ts_name,
                                ts_freq                  = ts_freq,
                                periods                  = periods,
                                n_per                    = n_per,
                                specs_df_name            = specs_df_name,
                                temporal_grp_periodicity = temporal_grp_periodicity,
                                alter_pos                = alter_pos,
                                alter_neg                = alter_neg,
                                alter_mix                = alter_mix,
                                lower_bound              = lower_bound, 
                                upper_bound              = upper_bound,
                                validation_only          = validation_only)
  
  # Number of series and balancing constraints
  n_ser <- length(pb$ser_names)
  n_con <- length(pb$labels_df$row.lc[pb$labels_df$con.flag])
  
  # Display the problem specs info
  specs_display_func()
  
  
  # Initial temporal aggregation matrix (for all series)
  #   => will be reduced later to the set of non fully binding series only
  #      (temporal totals of fully binding represent redundant constraints)
  dim_A2 <- dim(pb$A2)  # `dim_A2[1]` = number of rows
  # `dim_A2[2]` = number of columns
  A_a <- matrix(0, nrow = n_ser, ncol = dim_A2[2] + n_ser)
  for (ii in 1:n_ser) {
    A_a[ii, ((ii - 1) * temporal_grp_periodicity + 1):(ii * temporal_grp_periodicity)] <- 1
    A_a[ii, dim_A2[2] + ii] <- -1
  }
  
  
  # Define the processing groups (set of balancing problems).
  # Columns of the returned data frame:
  #   - grp         : processing group id (1:<number-of-groups>)
  #   - beg_per     : first period id
  #   - end_per     : last period id
  #   - complete_grp: complete group flag (logical, TRUE if end_per != beg_per)
  grp_df <- gs.build_proc_grps(gs.time2year(pb$values_ts),
                               gs.time2per(pb$values_ts),
                               n_per,
                               ts_freq,
                               temporal_grp_periodicity,
                               temporal_grp_start)
  
  # Activate message display
  n_grps <- nrow(grp_df)
  if (n_grps > 1) {
    solve_header_msg_func <- gs.NULL_func
    grp_msg_func <- message
    final_msg_flag <- TRUE
  } else {
    solve_header_msg_func <- solve_msg_func
    grp_msg_func <- gs.NULL_func
    final_msg_flag <- FALSE
  }
  
  solve_header_msg_func("\n\n", solve_str)
  solve_header_msg_func(strrep("=", nchar(solve_str)), "\n")
  
  
  # Initialize the output objects
  out_mat <- matrix(NA_real_, nrow = n_per, ncol = n_ser,
                    dimnames = list(NULL, pb$ser_names))
  tmp1 <- rep.int(NA_character_, n_grps)
  tmp2 <- rep.int(NA_real_, n_grps)
  tmp3 <- rep.int(NA_integer_, n_grps)
  out_proc_grp_df <- data.frame(
    proc_grp = grp_df$grp,
    proc_grp_type = tmp1,
    proc_grp_label = tmp1,
    sol_status = tmp1,
    sol_status_val = tmp3,
    n_unmet_con = tmp2,
    max_discr = tmp2,
    validation_tol = rep.int(validation_tol, n_grps),
    sol_type = tmp1,
    osqp_attempts = rep.int(0L, n_grps),
    osqp_seqno = tmp3,
    osqp_status = tmp1,
    osqp_polished = rep.int(as.logical(NA), n_grps),
    total_solve_time = tmp3)
  out_prob_val_df <- NULL
  out_prob_con_df <- NULL
  out_osqp_settings_df <- NULL
  out_osqp_sol_info_df <- NULL
  
  
  # Balance each processing group (generate the `balancing_process()` calls)
  for (grp in 1:n_grps) {
    
    # Build the processing group header and balancing problem elements list
    per_id_vec <- grp_df$beg_per[grp]:grp_df$end_per[grp]
    n_per_grp <- length(per_id_vec)
    n_values_grp <- n_ser * n_per_grp
    
    # Initialize the (non-constraint) balancing problem elements
    bl <- list(
      x = as.vector(pb$values_ts[per_id_vec, , drop = FALSE]),
      c = as.vector(pb$alter$coefs_ts[per_id_vec, , drop = FALSE]),
      lb = as.vector(pb$lb$coefs_ts[per_id_vec, , drop = FALSE]),
      ub = as.vector(pb$ub$coefs_ts[per_id_vec, , drop = FALSE]),
      bd_tol = rep.int(0, n_values_grp)
    )
    
    
    # Temporal group processing (multiple periods)
    #   => balancing problem elements must be "augmented" with temporal total info
    #   => initial constraint elements are the "v2" objects
    if (grp_df$complete_grp[grp]) {
      
      out_proc_grp_df$proc_grp_type[grp] <- "temporal group"
      out_proc_grp_df$proc_grp_label[grp] <- paste0(periods[grp_df$beg_per[grp]], " - ", periods[grp_df$end_per[grp]])
      
      # Build the processing group header
      msg_str <- paste0(solve_word, " periods [", out_proc_grp_df$proc_grp_label[grp], "]")
      
      # Reduce matrix `A_a` for non fully binding series only
      # (temporal totals of fully binding series are irrelevant)
      non_fully_binding <- (A_a[, 1:dim_A2[2], drop = FALSE] %*% bl$c) != 0
      n_a <- sum(non_fully_binding)
      A_a2 <- A_a[non_fully_binding, c(rep.int(TRUE, dim_A2[2]), non_fully_binding), drop = FALSE]
      
      # Add the temporal totals info
      a <- A_a2[, 1:dim_A2[2], drop = FALSE] %*% bl$x
      bl$x <- c(bl$x, a)
      c_a <- apply(pb$altertmp$coefs_ts[per_id_vec, pb$ser_names[non_fully_binding], drop = FALSE], 2,
                   function(x) {
                     # Return the first non missing (non `NA`) temporal total alter. coef. of the temporal group.
                     # Otherwise (all `NA`), return the default alter. coef. (argument `alter_temporal`)
                     y <- x[!is.na(x)][1]
                     if (is.na(y)) {
                       alter_temporal
                     } else {
                       y
                     }
                   })
      bl$c <- c(bl$c, c_a)
      names(bl$c) <- NULL
      bl$lb <- c(bl$lb, rep.int(-Inf, n_a))
      bl$ub <- c(bl$ub, rep.int(Inf, n_a))
      bl$bd_tol <- c(bl$bd_tol, rep.int(0, n_a))
      bl$A <- rbind(cbind(pb$A2, matrix(0, nrow = dim_A2[1], ncol = n_a)),
                    A_a2)
      bl$op <- c(pb$op2, rep.int("==", n_a))
      bl$b <- c(pb$b2, rep.int(0, n_a))
      
      # Temporal aggregation constraint tolerances are for binding temporal totals only!
      # (no need for "additional slack" in nonbinding temporal total aggregation constraints:
      # "slack" for nonbinding temporal totals is already accounted for in the optimization
      # function where changes to the initial temporal totals are minimized)
      bl$b_tol <- c(rep.int(tolV, dim_A2[1]), (a * tolP_temporal + tolV_temporal) * (c_a == 0))
      
      
      # Single-period processing
      #   => constraint elements are the "v1" objects
    } else {
      
      out_proc_grp_df$proc_grp_type[grp] <- "period"
      out_proc_grp_df$proc_grp_label[grp] <- periods[grp_df$beg_per[grp]]
      
      # Build the processing group header
      msg_str <- paste0(solve_word, " period [", out_proc_grp_df$proc_grp_label[grp], "]")
      
      # Define the constraint elements
      bl$A <- pb$A1
      bl$op <- pb$op1
      bl$b <- pb$b1
      bl$b_tol <- rep.int(tolV, n_con)
      
      non_fully_binding <- integer(0L)
      n_a <- 0
    }
    
    
    # Display the processing group header
    grp_msg_func("\n\n", msg_str)
    grp_msg_func(strrep("=", nchar(msg_str)), "\n")
    
    
    # Convert the balancing problem into a (reduced) QP problem (for OSQP):
    #   - construct the QP problem's Hessian matrix (`P`) and vector of linear coefficients (`q`)
    #   - rewrite the balancing constraints as `l <= Ax <= u` linear constraints. transferring binding values 
    #     (`c * x = 0`) into the constraints bounds (`l` and `u`)
    #   - add `l <= Ax <= u` linear constraints for and upper/lower bounds
    qp <- build_reduced_qp(bl$x, bl$c, bl$lb, bl$ub, bl$bd_tol,  # problem variables info
                           bl$A, bl$op, bl$b, bl$b_tol)          # problem constraints info
    n_con_qp <- length(qp$l)
    
    
    # Calculate the initial discrepancies
    Ax_ini <- qp$A %*% qp$x
    discr_ini <- calc_discr(Ax_ini, qp$l, qp$u)
    
    
    # Solve the balancing problem
    sol <- solve_func(x = qp$x,                                          # initial problem values (initial solution)
                      Ax = Ax_ini,                                       # evaluated constraint body values with the initial solution
                      discr = discr_ini,                                 # initial constraint discrepancies list
                      validation_tol = validation_tol,                   # solution validation tolerance (max. allowed constraint discr.)
                      P = qp$P, q = qp$q, A = qp$A, l = qp$l, u = qp$u,  # OSQP problem elements
                      settings_df = settings_df,                         # OSQP settings sequence data frame
                      full_sequence = full_sequence,                     # (logical) perform all steps (rows) of `settings_df`
                      solve_msg_func = solve_msg_func,                   # (function) message display function
                      osqpBeg_display_func = osqpBeg_display_func,       # (function) OSQP model and iterations display set up function
                      osqpEnd_display_func = osqpEnd_display_func,       # (function) OSQP model and iterations display wrap up function
                      osqp_output_file = osqp_output_file,               # temporary file (name and path) for the OSQP model and iterations contents
                      trunc_to_zero_tol = trunc_to_zero_tol)             # tolerance for changing nonzero solution data points to 0
    
    # Set the balancing solution:
    #  - initial solution (`bl$x`) for binding values
    #  - returned solution (`sol$x`) for nonbinding values
    x_out <- bl$x
    x_out[qp$id_x] <- sol$x
    
    # Cumulate the solutions
    out_mat[per_id_vec, ] <- matrix(x_out[1:n_values_grp], ncol = n_ser)
    
    
    # Create the problem values data frame
    prob_val_df <- data.frame(
      proc_grp = rep.int(grp, length(bl$x)),
      val_type = rep.int(c("period value", "temporal total"), c(n_values_grp, n_a)),
      name = c(rep(pb$ser_names, each = n_per_grp), pb$ser_names[non_fully_binding]),
      t = c(rep.int(per_id_vec, n_ser), rep.int(per_id_vec[1], n_a)),
      time_val = c(rep.int(time_values[per_id_vec], n_ser), rep.int(time_values[per_id_vec[1]], n_a)),
      lower_bd = bl$lb,
      upper_bd = bl$ub,
      alter = bl$c,
      value_in = bl$x,
      value_out = x_out,
      dif = x_out - bl$x,
      rdif = gs.calc_relDiff(x_out, bl$x)
    )
    
    
    # Create the problem constraints info data frame
    prob_con_df <- data.frame(
      proc_grp = rep.int(grp, n_con_qp),
      con_type = rep.int(c("balancing constraint",
                           "temporal aggregation constraint",
                           "period value bounds"),
                         c(n_con * n_per_grp,
                           n_a,
                           length(qp$id_bd_con))),
      name = c(rep(pb$labels_df$row[pb$labels_df$con.flag], each = n_per_grp),
               pb$ser_names[non_fully_binding],
               prob_val_df$name[qp$id_bd_con]),
      t = c(rep.int(per_id_vec, n_con),
            rep.int(per_id_vec[1], n_a),
            prob_val_df$t[qp$id_bd_con]),
      time_val = c(rep.int(time_values[per_id_vec], n_con),
                   rep.int(time_values[per_id_vec[1]], n_a),
                   prob_val_df$time_val[qp$id_bd_con]),
      l = qp$l,
      u = qp$u,
      Ax_in = as.vector(Ax_ini),
      Ax_out = as.vector(sol$Ax),
      discr_in = discr_ini$discr_vec,
      discr_out = sol$discr$discr_vec,
      validation_tol = rep.int(validation_tol, n_con_qp),
      unmet_flag = (sol$discr$discr_vec > validation_tol)
    )
    
    
    # Fill in the processing groups data frame and both OSQP info data frames
    out_proc_grp_df$sol_status[grp] <- sol$status
    out_proc_grp_df$sol_status_val[grp] <- sol$status_val
    n_unmet <- sum(prob_con_df$unmet_flag)
    out_proc_grp_df$n_unmet_con[grp] <- n_unmet
    out_proc_grp_df$max_discr[grp] <- sol$discr$max_discr
    out_proc_grp_df$sol_type[grp] <- sol$type
    out_proc_grp_df$total_solve_time[grp] <- sol$seq_time
    if (!is.null(sol$osqp_info)) {
      out_proc_grp_df$osqp_attempts[grp] <- sol$osqp_attempts
      out_proc_grp_df$osqp_seqno[grp] <- sol$osqp_seqno
      out_proc_grp_df$osqp_status[grp] <- sol$osqp_info$status
      out_proc_grp_df$osqp_polished[grp] <- sol$osqp_info$status_polish == 1
      out_osqp_settings_df <- rbind(out_osqp_settings_df, as.data.frame(c(list(proc_grp = grp), sol$osqp_settings)))
      out_osqp_sol_info_df <- rbind(out_osqp_sol_info_df,
                                    as.data.frame(c(
                                      list(proc_grp = grp),
                                      sol$osqp_info,
                                      # Calculate the original balancing problem's objective value
                                      list(obj_val_ori_prob = 
                                             sol$osqp_info$obj_val * sol$osqp_info$prior_scaling_factor  # original scale
                                           + sum(-0.5 * qp$q * qp$x)))))                               # constant terms
    }
    
    
    # Sort, display and cumulate the problem values and constraints info data frames
    prob_val_df <- prob_val_df[order(rep.int(1:2, c(n_values_grp, n_a)),
                                     prob_val_df$t,
                                     c(rep(1:n_ser, each = n_per_grp), seq_len(n_a)))
                               , ]
    out_prob_val_df <- rbind(out_prob_val_df, prob_val_df)
    prob_con_df <- prob_con_df[order(
      # 1- constraint type (periods, then temporal totals)
      rep.int(c(1, 2, 1), c(n_con * n_per_grp,
                            n_a,
                            length(qp$id_bd_con))),
      # 2- period
      prob_con_df$t,
      # 3- constraint sub-type
      rep.int(c(1, 3, 2), c(n_con * n_per_grp,
                            n_a,
                            length(qp$id_bd_con))),
      # 4- constraint/series name (keeping this initial order)
      c(rep(1:n_con, each = n_per_grp),
        seq_len(n_a),
        seq_along(qp$id_bd_con)))
      , ]
    out_prob_con_df <- rbind(out_prob_con_df, prob_con_df)
    results_display_func()
    
    # Validate the solution
    if (n_unmet > 0) {
      warning("Constraints were not met in ", n_unmet, " occasion(s). Maximum discrepancy: ",
              format(sol$discr$max_discr, big.mark = ","), ". See constraints with `unmet_flag = TRUE` ",
              "for details.\n", call. = FALSE, immediate. = TRUE)
      warning_flag <- TRUE
    }
  }
  
  
  # Create the output list
  out_ts <- in_ts
  out_ts[, pb$ser_names] <- out_mat
  out_list$out_ts <- out_ts
  row.names(out_proc_grp_df) <- NULL
  out_list$proc_grp_df <- out_proc_grp_df
  out_list$periods_df <- data.frame(
    # `sapply()` is safe: it always returns a numeric vector (`grp_df$grp` is of length minimum 1)
    proc_grp = rep.int(grp_df$grp, sapply(grp_df$grp, function(ii) length(grp_df$beg_per[ii]:grp_df$end_per[ii]))),
    t = 1:n_per,
    time_val = time_values)
  row.names(out_prob_val_df) <- NULL
  out_list$prob_val_df <- out_prob_val_df
  row.names(out_prob_con_df) <- NULL
  out_list$prob_con_df <- out_prob_con_df
  row.names(out_osqp_settings_df) <- NULL
  out_list$osqp_settings_df <- out_osqp_settings_df
  row.names(out_osqp_sol_info_df) <- NULL
  out_list$osqp_sol_info_df <- out_osqp_sol_info_df
  
  
  if (final_msg_flag && warning_flag) {
    warning("Warnings were generated during processing. See relevant message(s) for details.\n",
            call. = FALSE, immediate. = TRUE)
  }
  
  # Output object returned via function `on.exit()`
}


#' Construire les éléments des problèmes d'équilibrage.
#'
#' @description
#' Cette fonction est utilisée à l'interne par [tsbalancing()] pour construire les éléments des problèmes 
#' d'équilibrage. Elle peut également être utile pour dériver manuellement (en dehors du contexte de [tsbalancing()]) 
#' les séries indirectes associées aux contraintes d'équilibrage d'égalité.
#' 
#' 
#' @inheritParams tsbalancing
#' 
#' @param in_ts_name (optionnel) 
#' 
#' Chaîne de caractères contenant la valeur de l'argument `in_ts`.
#'
#' **La valeur par défaut** est `in_ts_name = deparse1(substitute(in_ts))`.
#' 
#' @param ts_freq (optionnel)
#' 
#' Fréquence de l'object the type série chronologique (argument `in_ts`).
#' 
#' **La valeur par défaut** est `ts_freq = stats::frequency(in_ts)`.
#' 
#' @param periods (optionnel) 
#' 
#' Vecteur de chaînes de caractères décrivant les périodes de l'object the type série chronologique (argument `in_ts`).
#' 
#' **La valeur par défaut** est `periods = gs.time2str(in_ts)`.
#' 
#' @param n_per (optionnel) 
#' 
#' Nombre de périodes de l'object the type série chronologique (argument `in_ts`).
#' 
#' **La valeur par défaut** est `n_per = nrow(as.matrix(in_ts))`.
#' 
#' @param specs_df_name (optionnel)
#' 
#' Chaîne de caractères contenant la valeur de l'argument `problem_specs_df`.
#' 
#' **La valeur par défaut** est `specs_df_name = deparse1(substitute(problem_specs_df))`.
#' 
#'
#' @returns
#' Une liste avec les éléments des problèmes d'équilibrage (excluant l'information sur les totaux temporels) :
#' - `labels_df` : version nettoyée des _enregistrements de définition d'étiquette_ provenant de `problem_specs_df` 
#'                (enregistrements où `type` n'est pas manquant (n'est pas `NA`)); colonnes supplémentaires :
#'   - `type.lc`  : `tolower(type)`
#'   - `row.lc`   : `tolower(row)` 
#'   - `con.flag` : `type.lc %in% c("eq", "le", "ge")`
#' - `coefs_df`  : version nettoyée des _enregistrements de spécification d'information_ provenant de `problem_specs_df` 
#'                (enregistrements où `type` est manquant (est `NA`)); colonnes supplémentaires :
#'   - `row.lc`   : `tolower(row)` 
#'   - `con.flag` : `labels_df$con.flag` attribuée à travers `row.lc`
#' - `values_ts`: version réduite de `in_ts` avec seulement les séries pertinentes (voir vecteur `ser_names`)
#' - `lb`        : information sur les bornes inférieures (`type.lc  = "lowerbd"`) des séries pertinentes; liste avec 
#'                les éléments suivants :
#'   - `coefs_ts`        : object « mts » contenant les bornes inférieures des séries pertientes (voir vecteur `ser_names`)
#'   - `nondated_coefs`  : vecteur des bornes non datées de `problem_specs_df` (`timeVal` est `NA`)
#'   - `nondated_id_vec` : vecteur d'identificateurs de `ser_names` associés au vecteur `nondated_coefs`
#'   - `dated_id_vec`    : vecteur d'identificateurs de `ser_names` associés aux bornes inférieures datées de 
#'                         `problem_specs_df` (`timeVal` n'est pas `NA`)
#' - `ub`        : équivalent de `lb` pour les bornes supérieures (`type.lc = "upperbd"`)
#' - `alter`     : équivalent de `lb` pour les coefficients d'altérabilité des valeurs de période (`type.lc = "alter"`)
#' - `altertmp`  : équivalent de `lb` pour les coefficients d'altérabilité des totaux temporels (`type.lc = "altertmp"`)
#' - `ser_names` : vecteur des noms de séries pertinentes (ensemble de séries impliquées dans les contraintes d'équilibrage)
#' - `pos_ser`   : vecteur des noms de séries qui n'ont que des coefficients non nuls positifs à travers toutes les contraintes
#' - `neg_ser`   : vecteur des noms de séries qui n'ont que des coefficients non nuls négatifs à travers toutes les contraintes
#' - `mix_ser`   : vecteur des noms de séries qui ont des coefficients non nuls positifs et négatifs à travers toutes les 
#'                 contraintes
#' - `A1`,`op1`,`b1` : éléments des contraintes d'équilibrage pour les problèmes impliquant une seule période (ex., chacune des 
#'                     périodes d'un groupe temporel incomplet)
#' - `A2`,`op2`,`b2` : éléments des contraintes d'équilibrage pour les problèmes impliquant `temporal_grp_periodicity` périodes 
#'                     (ex., l'ensemble des périodes d'un groupe temporel complet)
#' 
#' 
#' @details
#' Voir [tsbalancing()] pour une description détaillée des problèmes d'_équilibrage de séries chronologiques_.
#' 
#' Toute valeur manquante (`NA`) trouvée dans l'objet de série chronologique d'entrée (argument `in_ts`) serait remplacée par 0 
#' dans `values_ts` et déclencherait un message d'avertissement.
#' 
#' Les éléments renvoyés des problèmes d'équilibrage n'incluent pas les totaux temporels implicites (c.-à-d., les éléments 
#' `A2`, `op2` et `b2` ne contiennent que les contraintes d'équilibrage).
#' 
#' Les éléments `A2`, `op2` et `b2` d'un problème d'équilibrage impliquant plusieurs périodes (lorsque 
#' `temporal_grp_periodicity > 1`) sont construits _colonne par colonne_ (selon le principe « column-major order » en anglais), 
#' ce qui correspond au comportement par défaut de R lors de la conversion d'objets de la classe « matrix » en vecteurs. 
#' Autrement dit, les contraintes d'équilibrage correspondent conceptuellement à :
#' - `A1 %*% values_ts[t, ] op1 b1` pour des problèmes impliquant une seule période (`t`)
#' - `A2 %*% as.vector(values_ts[t1:t2, ]) op2 b2` pour des problèmes impliquant `temporal_grp_periodicity` périodes (`t1:t2`)
#'
#' Notez que l'argument `alter_temporal` n'a pas encore été appliqué à ce stade et que `altertmp$coefs_ts` ne contient que les 
#' coefficients spécifiés dans le _data frame_ des spécifications du problème (argument `problem_specs_df`). Autrement dit, 
#' `altertmp$coefs_ts` contient des valeurs manquantes (`NA`) à l'exception des coefficients d'altérabilité de total temporel  
#' inclus dans (spécifiés avec) `problem_specs_df`. Ceci est fait afin de faciliter l'identification du premier coefficient 
#' d'altérabilité non manquant (non `NA`) de chaque groupe temporel complet (à survenir ultérieurement, le cas échéant, dans 
#' [tsbalancing()]).
#' 
#'
#' @seealso [tsbalancing()] [build_raking_problem()]
#' 
#' @example misc/function_examples/build_balancing_problem-ex.R
#' 
#' @export
build_balancing_problem <- function(in_ts,
                                    problem_specs_df,
                                    in_ts_name = deparse1(substitute(in_ts)),
                                    ts_freq = stats::frequency(in_ts),
                                    periods = gs.time2str(in_ts),
                                    n_per = nrow(as.matrix(in_ts)),
                                    specs_df_name = deparse1(substitute(problem_specs_df)),
                                    temporal_grp_periodicity = 1,
                                    alter_pos = 1,
                                    alter_neg = 1,
                                    alter_mix = 1,
                                    lower_bound = -Inf, 
                                    upper_bound = Inf,
                                    validation_only = FALSE) {
  
  
  # Assign non-constraint coefficients from the problem specs data frame.
  # Note: coefs with time values (`timeval`) outside the time series span are ignored
  #
  # Arguments:
  #   - coefs_ts      : 'ts' object to be updated
  #   - label         : string (`coef_df$type.lc` value) identifying the type of coefs to assign
  #
  # Other main (parent) function objects used in this function:
  #   - coefs_df : problem specs coefficients data frame (rows for which `type` is `NA`)
  #   - ser_names: vector of the series names involved in the balancing problem
  #   - n_per    : `nrow(coefs_ts)` = number of periods in the input 'ts' object
  #   - ts_freq  : `frequency(coefs_ts)` = frequency of the input 'ts' object
  #   - periods  : `gs.time2str(coefs_ts)` = vector of period string labels ("<year>-<per>")
  # 
  # Value:
  #   Returns a list of 4 objects:
  #     - coefs_ts       : updated 'ts' object
  #     - nondated_coefs : vector of nondated coefficients (`timeval` is `NA`)
  #     - nondated_id_vec: vector of `ser_names` id's associated to vector `nondated_coefs`
  #     - dated_id_vec   : vector of `ser_names` id's associated to dated coefficient (`timeval` is not `NA`)
  assign_coefs <- function(coefs_ts, label) {
    
    # All periods (`timeval` is `NA`)
    logi_vec <- coefs_df$type.lc == label & is.na(coefs_df$timeval)
    coefs_ts[, coefs_df$col[logi_vec]] <- rep(coefs_df$coef[logi_vec], each = n_per)
    
    # Specific periods (`timeval` is not `NA`)
    id_vec <- which(coefs_df$type.lc == label & !is.na(coefs_df$timeval))
    for (ii in seq_along(id_vec)) {
      coefs_ts[match(gs.time2str(stats::ts(NA, start = coefs_df$timeval[id_vec[ii]], frequency = ts_freq)),
                     periods, nomatch = 0),
               coefs_df$col[id_vec[ii]]] <- coefs_df$coef[id_vec[ii]]
    }
    
    list(coefs_ts = coefs_ts,
         nondated_coefs = coefs_df$coef[logi_vec],
         nondated_id_vec = match(coefs_df$col[logi_vec], ser_names),
         dated_id_vec = match(unique(coefs_df$col[id_vec]), ser_names))
  }
  
  
  ### Main function ###
  
  
  # Initial clean-up/standardization of the problem specs df:
  #   - convert column names to lowercase
  #   - replace empty strings ("") with `NA` for character columns (`type`, `col`, `row`)
  #   - standardize constraint RHS specification (`col = "_rhs_"`)
  #   - add column `timeval` if not present 
  #     => if column `time_val` is present (without column `timeval`), it is recoded to `timeval`
  in_ts_cols <- colnames(in_ts)
  specsDF_cols <- tolower(names(problem_specs_df))
  names(problem_specs_df) <- specsDF_cols
  core_cols <- c("type", "col", "row", "coef")
  gs.validate_cols(tolower(setdiff(core_cols, specsDF_cols)), NULL, specs_df_name)
  # `sapply()` is safe: it always returns a logical vector of length 3
  logi_vec <- sapply(core_cols[1:3], function(col) !is.character(problem_specs_df[[col]]))
  if (any(logi_vec)) {
    stop("The following problem specs data frame column(s) must be character:",
         paste0("\n  ", core_cols[c(logi_vec, FALSE)], collapse = ""), call. = FALSE)
  }
  if (!is.numeric(problem_specs_df$coef)) {
    stop("Problem specs data frame column `coef` must be numeric.", call. = FALSE)
  }
  problem_specs_df$type <- trimws(problem_specs_df$type)
  problem_specs_df$type[problem_specs_df$type == ""] <- NA
  problem_specs_df$col <- trimws(problem_specs_df$col)
  problem_specs_df$col[problem_specs_df$col == ""] <- NA
  problem_specs_df$col[tolower(problem_specs_df$col) == "_rhs_"] <- "_rhs_"
  problem_specs_df$row <- trimws(problem_specs_df$row)
  problem_specs_df$row[problem_specs_df$row == ""] <- NA
  logi_vec <- c("timeval", "time_val") %in% specsDF_cols
  if (!any(logi_vec)) {
    problem_specs_df$timeval <- NA_real_
  } else {
    if (all(logi_vec == c(FALSE, TRUE))) {
      problem_specs_df$timeval <- problem_specs_df$time_val
    }
    logi_vec <- !is.na(problem_specs_df$timeval)
    if (any(logi_vec)) {
      if (!is.numeric(problem_specs_df$timeval[logi_vec])) {
        stop("Problem specs data frame column `timeVal` must be numeric.", call. = FALSE)
      }
      if (any(!is.finite(problem_specs_df$timeval[logi_vec]))) {
        stop("Invalid time values (column `timeVal`) found in the problem specs data frame (time values must be ",
             "finite real numbers or `NA`).", call. = FALSE)
      }
    } else {
      problem_specs_df$timeval <- NA_real_
    }
  }
  
  
  # Split specs data frame into labels and coefs data frames
  labels_df <- problem_specs_df[!is.na(problem_specs_df$type), c("type", "row"), drop = FALSE]
  coefs_df <- problem_specs_df[is.na(problem_specs_df$type), c("col", "row", "coef", "timeval"), drop = FALSE]
  
  # Initial (basic) problems specs validation
  if (any(is.na(labels_df$row))) {
    stop("Invalid label definition record found in the problem specs data frame (missing `row` value).", call. = FALSE)
  }
  if (any(is.na(coefs_df$col) | is.na(coefs_df$row))) {
    stop("Invalid information specification record found in the problem specs data frame ",
         "(missing `col` or `row` value).", call. = FALSE)
  }
  # Reject (ignore) missing (`NA`) coefs
  coefs_df <- coefs_df[!is.na(coefs_df$coef), , drop = FALSE]
  
  # Cleanup the labels (lowercase version of columns `type` and `row`)
  # => Allow the following lowercase `type` values (convert them to the expected lowercase value):
  #    - "==" and "=" for "eq"
  #    - "<=" and "<" for "le"
  #    - ">=" and ">" for "ge"
  #    - "lower" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "lowerbd"
  #    - "upper" + ("" or "_" or "-" or "." or " ") + ("bd" or "bnd" or "bound) for "upperbd"
  #    - "alter" + ("" or "_" or "-" or "." or " ") + ("tmp" or "temp" or "temporal) for "altertmp"
  labels_df$type.lc <- sub(sub(sub(sub(sub(tolower(labels_df$type), 
                                           pattern = "^(==|=)$", 
                                           replacement = "eq", 
                                           perl = TRUE),
                                       pattern = "^(<=|<)$", 
                                       replacement = "le", 
                                       perl = TRUE),
                                   pattern = "^(>=|>)$", 
                                   replacement = "ge", 
                                   perl = TRUE),
                               pattern = "^(lower|upper)[\\.[:blank:]_-]?(bd|bnd|bound)$", 
                               replacement = "\\1bd", 
                               perl = TRUE),
                           pattern = "^alter[\\.[:blank:]_-]?(tmp|temp|temporal)$", 
                           replacement = "altertmp", 
                           perl = TRUE)
  labels_df$row.lc <- tolower(labels_df$row)
  coefs_df$row.lc <- tolower(coefs_df$row)
  labels_df$con.flag <- labels_df$type.lc %in% c("eq", "le", "ge")
  coefs_df$con.flag <- coefs_df$row.lc %in% unique(labels_df$row.lc[labels_df$con.flag])
  
  # Get the list of series involved in balancing constraints
  ser_names <- unique(coefs_df$col[coefs_df$con.flag & coefs_df$col != "_rhs_" & coefs_df$coef != 0])
  n_ser <- length(ser_names)
  if (n_ser == 0) {
    stop("The problem specs data frame must include at least one valid (non-empty) balancing constraint.", call. = FALSE)
  }
  missing_cols <- setdiff(ser_names, in_ts_cols)
  if (length(missing_cols) > 0) {
    stop("The following series, listed in balancing constraints in the problem specs data frame, are missing from ",
         "input 'ts' object \"", in_ts_name, "\": ", paste0("\n  ", missing_cols, collapse = ""), call. = FALSE)
  }
  # Order `ser_names` according to the input time series columns
  ser_names <- intersect(in_ts_cols, ser_names)
  
  # Keep only the relevant info from the problem specification data frame: info related to the
  # "balancing problem series", i.e., the set of series involved in the balancing constraint.
  coefs_df <- coefs_df[
    # coefs of relevant series (involved in balancing constraints)
    coefs_df$col %in% ser_names & (!coefs_df$con.flag | coefs_df$con.flag & coefs_df$coef != 0)
    # RHS values for relevant constraints (involving at least one series)
    | coefs_df$col == "_rhs_" & coefs_df$row.lc %in% unique(coefs_df$row.lc[coefs_df$con.flag & coefs_df$col %in% ser_names])
    , , drop = FALSE]
  row.names(coefs_df) <- NULL
  labels_df <- labels_df[labels_df$row.lc %in% unique(coefs_df$row.lc), , drop = FALSE]
  row.names(labels_df) <- NULL
  
  # Bring the type labels in the coefs data frame
  coefs_df <- merge(labels_df[c("type.lc", "row.lc")], coefs_df, by = "row.lc", all = TRUE, sort = FALSE)
  
  
  # Extra problems specs validation (more in-depth validation for the remaining relevant info)
  
  # Invalid problem elements
  invalid_types <- setdiff(unique(labels_df$type.lc), c("eq", "le", "ge", "lowerbd", "upperbd", "alter", "altertmp"))
  if (length(invalid_types) > 0) {
    stop("The following invalid problem elements ('type' column values in lowercase) were found in the problem specs data frame: ",
         paste0("\n  ", invalid_types, collapse = ""), call. = FALSE)
  }
  
  # Invalid labels
  invalid_labels <- unique(coefs_df$row.lc[is.na(coefs_df$type.lc)])
  if (length(invalid_labels) > 0) {
    stop("The following labels ('row' column values in lowercase) in the problem specs data frame have not been properly ",
         "defined (no coresponding \"label definition record\"): ", paste0("\n  ", invalid_labels, collapse = ""),
         call. = FALSE)
  }
  
  # Duplicate labels
  if (any(table(labels_df$row.lc) > 1)) {
    stop("The problem specs data frame contains duplicate labels, i.e., same 'row' value used for several ",
         "problem elements (`type` values).", call. = FALSE)
  }
  
  # Duplicate label definition records for non-constraint elements
  if (any(table(labels_df$type.lc[!labels_df$con.flag]) > 1)) {
    stop("The problem specs data frame contains duplicate label definition records for non-constraint elements ",
         "(i.e., a given non-constraint `type` value is assigned a `row` value more than once).", call. = FALSE)
  }
  
  # Specified time values (`timeval`) for constraints
  if (any(coefs_df$con.flag & !is.na(coefs_df$timeval))) {
    stop("Time values (column `timeVal` in the problem specs data frame) cannot be specified for constraint ",
         "coefficients or RHS values.", call. = FALSE)
  }
  
  # Invalid numeric `coef` values:
  #   - constraint coefficients  : infinite
  #   - alterability coefficients: negative or infinite
  #   - lower bound              : Inf
  #   - upper bound              : -Inf
  if (any(!is.finite(coefs_df$coef[coefs_df$con.flag]))) {
    stop("Invalid constraint coefficients (column `coef`) found in the problem specs data frame (constraint ",
         "coefficients must be finite real numbers).", call. = FALSE)
  }
  logi_vec <- (coefs_df$type.lc %in% c("alter", "altertmp"))
  if (any(!is.finite(coefs_df$coef[logi_vec]) | coefs_df$coef[logi_vec] < 0)) {
    stop("Invalid alterability coefficients (column `coef`) found in the problem specs data frame (alterability ",
         "coefficients must be nonnegative finite real numbers).", call. = FALSE)
  }
  if (any(coefs_df$coef[coefs_df$type.lc == "lowerbd"] == Inf)) {
    stop("Invalid period value lower bounds (column `coef`) found in the problem specs data frame (lower bounds ",
         "must be a finite real number or -Inf).", call. = FALSE)
  }
  if (any(coefs_df$coef[coefs_df$type.lc == "upperbd"] == -Inf)) {
    stop("Invalid period value upper bounds (column `coef`) found in the problem specs data frame (upper bounds ",
         "must be a finite real number or Inf).", call. = FALSE)
  }
  
  # Duplicate coefficient specification
  if (any(table(coefs_df[c("col", "row.lc", "timeval")], useNA = "always") > 1)) {
    stop("The problem specs data frame contains duplicate information specification records, i.e., multiple 'coef' values ",
         "for a given set of `col` (time series or constraint RHS), `row` (problem element) and 'timeVal' values.",
         call. = FALSE)
  }
  
  # 'Reduce the input 'ts' 'in_ts' version with only the relevant series
  values_ts <- in_ts[, ser_names, drop = FALSE]
  logi_vec <- is.na(values_ts)
  if (sum(logi_vec) > 0) {
    warning("Missing data were found in the input 'ts' object. They were replaced with 0.",
            call. = FALSE, immediate. = TRUE)
    values_ts[logi_vec] <- 0
  }
  
  
  # Assign the lower/upper bounds
  lb <- list(coefs_ts = values_ts)
  lb$coefs_ts[, ] <- lower_bound
  lb <- assign_coefs(lb$coefs_ts, "lowerbd")
  ub <- list(coefs_ts = values_ts)
  ub$coefs_ts[, ] <- upper_bound
  ub <- assign_coefs(ub$coefs_ts, "upperbd")
  if (any(lb$coefs_ts > ub$coefs_ts)) {
    stop("Incompatible period value bounds (column `coef`) specified in the problem specs data frame (lower bounds ",
         "cannot be greater than upper bounds).", call. = FALSE)
  }
  
  # Assign the alterability coefficients
  alter <- list(coefs_ts = values_ts)
  alter$coefs_ts[, ] <- NA_real_
  altertmp <- alter
  if (!validation_only) {
    
    # Default (function arguments `alter_pos`, `alter_neg` and `alter_mix`)
    pos_ser <- unique(coefs_df$col[coefs_df$con.flag & coefs_df$col != "_rhs_" & coefs_df$coef > 0])
    neg_ser <- unique(coefs_df$col[coefs_df$con.flag & coefs_df$col != "_rhs_" & coefs_df$coef < 0])
    mix_ser <- intersect(pos_ser, neg_ser)
    pos_ser <- setdiff(pos_ser, mix_ser)
    neg_ser <- setdiff(neg_ser, mix_ser)
    alter$coefs_ts[, pos_ser] <- alter_pos
    alter$coefs_ts[, neg_ser] <- alter_neg
    alter$coefs_ts[, mix_ser] <- alter_mix
    
    # From the problem specs data frame
    alter <- assign_coefs(alter$coefs_ts, "alter")
    altertmp <- assign_coefs(altertmp$coefs_ts, "altertmp")
    # Note: as opposed to the period value alter coefs (`alter$coefs_ts`), the default temporal total 
    #       alterability coefficients (`altertmp$coefs_ts`) for cases not specified in the problem specs 
    #       data frame remain `NA` for now (i.e., argument `alter_temporal` is not used right away).
    #       This will allow for easy identification of the first specified temporal total alter coef in the specs 
    #       (when applicable) inside a complete temporal group.
    
  } else {
    pos_ser <- character(0L)
    neg_ser <- character(0L)
    mix_ser <- character(0L)
    alter <- c(alter, list(nondated_coefs = numeric(0L),
                           nondated_id_vec = integer(0L),
                           dated_id_vec = integer(0L)))
    altertmp <- c(altertmp, list(nondated_coefs = numeric(0L),
                                 nondated_id_vec = integer(0L),
                                 dated_id_vec = integer(0L)))
  }
  
  
  # Build the initial version of problem constraints elements:
  #   - matrix `A` : balancing constraint coefficients matrix
  #   - vector `op`: balancing constraint operator strings ("==", "<=" or ">=")
  #   - vector `b` : balancing constraint RHS
  #
  # Two versions of these elements are built:
  #   - <obj>1: for single period processing (incomplete temporal groups or period-by-period processing)
  #   - <obj>2: for multiple periods processing (complete temporal groups)
  #
  # Note: these constraint elements will eventually be "augmented" for OSQP to implement:
  #         - (implicit) temporal aggregation constraints (for complete temporal groups)
  #         - period value (lower/upper) bounds
  #
  con_labels <- labels_df$row.lc[labels_df$con.flag]
  n_con <- length(con_labels)
  A1 <- matrix(0, nrow = n_con, ncol = n_ser)
  A2 <- matrix(0, nrow = n_con * temporal_grp_periodicity, ncol = n_ser * temporal_grp_periodicity)
  for (ii in 1:n_con) {
    logi_vec <- coefs_df$row.lc == con_labels[ii] & coefs_df$col != "_rhs_"
    id_vec <- match(coefs_df$col[logi_vec], ser_names)
    A1[ii, id_vec] <- coefs_df$coef[logi_vec]
    for (jj in 1:temporal_grp_periodicity) {
      A2[(ii - 1) * temporal_grp_periodicity + jj, (id_vec - 1) * temporal_grp_periodicity + jj] <- coefs_df$coef[logi_vec]
    }
  }
  b1 <- rep.int(0, n_con)
  b1[match(coefs_df$row.lc[coefs_df$col == "_rhs_"], con_labels)] <- coefs_df$coef[coefs_df$col == "_rhs_"]
  b2 <- b1[rep(1:n_con, each = temporal_grp_periodicity)]
  op1 <- labels_df$type.lc[labels_df$con.flag]
  op1[op1 == "eq"] <- "=="
  op1[op1 == "le"] <- "<="
  op1[op1 == "ge"] <- ">="
  op2 <- op1[rep(1:n_con, each = temporal_grp_periodicity)]
  
  
  # Return the balancing problem core elements (building blocks)
  list(labels_df = labels_df,
       coefs_df = coefs_df,
       values_ts = values_ts,
       lb = lb,
       ub = ub,
       alter = alter,
       altertmp = altertmp,
       ser_names = ser_names,
       pos_ser = pos_ser,
       neg_ser = neg_ser,
       mix_ser = mix_ser,
       A1 = A1,
       op1 = op1,
       b1 = b1,
       A2 = A2,
       op2 = op2,
       b2 = b2)
}


#' Convert a time series balancing problem into a QP problem for OSQP.
#'
#' Balancing problem values arguments (numeric vectors of size `n`) including time series
#' temporal totals (when applicable)
#' @param x vector of initial values
#' @param c vector of alterability coefficients
#' @param lb,ub vectors of lower/upper bounds (`-Inf` or `Inf` correspond to no bounds)
#' @param bd_tol vector of tolerances for lower/upper bounds (0 corresponds to no tolerance)
#'
#' Balancing problem constraints arguments (matrices and vectors of size `m X n` and `m`)
#' including the implicit temporal aggregation constraints (when applicable)
#' @param A left-hand-side matrix (numeric)
#' @param op vector of operators (character: "==", "<=" or ">=")
#' @param b vector of right-hand side values (numeric)
#' @param b_tol vector of right-hand side value tolerances (0 corresponds to no tolerance)
#'
#' @returns
#' Elements of the (reduced) QP problem for OSQP:
#'   - P    : Hessian (quadratic coefficients) matrix
#'   - q    : vector of linear coefficients
#'   - A,l,u: constraints matrix and bounds (`l <= Ax <= u`)
#' Additional information:
#'   - x        : reduced problem initial values (input vector `x` stripped of the binding values)
#'   - id_x     : id's of input vector `x` corresponding to the reduced problem values
#'   - id_bd_con: id's of input vector `x` corresponding to the lower/upper bound constraints
#'
#' @details
#' The returned QP problem corresponds the balancing problem in its "reduced form" where binding values 
#' (`c * x = 0`) are removed from the problem and transferred into the constraints bounds (`l` and `u`) 
#' instead. 
#' 
#' Construct the reduced QP problem's Hessian matrix (`P`) and vector of linear coefficients (`q`), 
#' rewrite the balancing constraints as `l <= Ax <= u` linear constraints, i.e.,
#'   - `l = b - b_tol` and `u = b + b_tol` for "==" constraints,
#'   - `l = -Inf` and `u = b + b_tol` for "<=" constraints,
#'   - `l = b - b_tol` and `u = Inf` for ">=" constraints,
#' and define additional `l <= Ax <= u` linear constraints for lower/upper bounds, i.e.,
#'   - `l = lb - bd_tol` and `u = Inf` for lower bounds (w/o upper bounds),
#'   - `l = -Inf` and `u = ub + bd_tol` for upper bounds (w/o lower bounds),
#'   - `l = lb - bd_tol` and `u = ub + bd_tol` for both lower AND upper bounds.
#'   
#' Fixed QP problems (`validation_only = TRUE` or all values of `x` are binding) have missing (`NA`) values 
#' for `P` and `q` and should not be sent to OSQP (the initial solution should be returned).
#'
#' @noRd
build_reduced_qp <- function(x, c, lb, ub, bd_tol,  # problem variables info
                             A, op, b, b_tol) {     # problem constraints info
  
  # Initial number of constraints (`dim_A[1]`) and variables (`dim_A[2]`)
  dim_A <- dim(A)
  
  # Identify the set of free (nonbinding) problem values (when in "solving mode", i.e., `validation_only = FALSE`)
  # => alterability coefficients are all `NA` when in "validation mode" (`validation_only = TRUE`)
  logi_vec <- !is.na(c) & (x * c) != 0
  
  # Reduce the problem for fixed (binding) values
  if (any(logi_vec)) {
    id_x <- which(logi_vec)
    
    # Update the constraints given the fixed (binding) values:
    #   - adjust the constraint RHS (`b`) values
    #   - remove the corresponding column from constrain coefficients matrix (`A`)
    b <- b - A[, !logi_vec, drop = FALSE] %*% x[!logi_vec]
    A <- A[, id_x, drop = FALSE]
    dim_A[2] <- length(id_x)
    
    # QP problem quadratic coefficients (Hessian) matrix and vector of linear coefficients
    w <- 1 / abs(c[id_x] * x[id_x])
    P <- diag(2 * w, nrow = dim_A[2])
    q <- -2 * w * x[id_x]
    
    # Fixed problem (`validation_only = TRUE` or all values are binding) => do not reduce the problem
  } else {
    id_x <- seq_along(x)
    
    # (dummy) QP problem quadratic coefficients (Hessian) matrix and vector of linear coefficients
    # (won't be sent to OSQP for solving anyway)
    P <- as.matrix(NA_real_)
    q <- NA_real_
  }
  
  # Transform constraint RHS values (`b`) into `l` and `u` vectors (constraints lower/upper bounds)
  l <- rep.int(-Inf, dim_A[1])
  u <- rep.int(Inf, dim_A[1])
  logi_vec <- op != "<="
  l[logi_vec] <- b[logi_vec] - b_tol[logi_vec]
  logi_vec <- op != ">="
  u[logi_vec] <- b[logi_vec] + b_tol[logi_vec]
  
  # Add constraints for period value lower/upper bounds.
  logi_vec <- lb[id_x] != -Inf | ub[id_x] != Inf
  if (any(logi_vec)) {
    # Note regarding both vectors of id's defined here:
    #   - `id_bd`    : id's of the output 'x' vector (reduced problem)
    #   - `id_bd_con`: id's of the input 'x' vector (full scale problem)
    id_bd <- which(logi_vec)
    id_bd_con <- id_x[id_bd]
    n_bd <- length(id_bd)
    
    # Initial transposed matrix (0 values) for the new rows (new columns in this transposed matrix)
    tmp_mat <- matrix(0, nrow = dim_A[2], ncol = n_bd)
    
    # Set the proper matrix elements to 1 (column-major order)
    tmp_mat[id_bd + seq.int(from = 0, by = dim_A[2], length.out = n_bd)] <- 1
    
    # Add the new constraints
    A <- rbind(A, t(tmp_mat))
    l <- c(l, lb[id_bd_con] - bd_tol[id_bd_con])  # `-Inf` minus any value remains `-Inf`
    u <- c(u, ub[id_bd_con] + bd_tol[id_bd_con])  #  `Inf`  plus any value remains  `Inf`
  } else {
    id_bd_con <- integer(0L)
  }
  
  # Return the reduced QP problem info
  list(P = P,
       q = q,
       A = A,
       l = l,
       u = u,
       x = x[id_x],
       id_x = id_x,
       id_bd_con = id_bd_con)
}


#' Calculate the balancing problem discrepancies
#'
#' @description
#' Calculate the discrepancies of a solution given a set of linear constraints
#' (`l <= Ax <= u`)
#'
#' @param Ax (vector) evaluated constraint body values.
#' @param l,u (vector) constraint lower and upper bounds.
#'
#' @return a list of three elements:
#'   - `discr_vec`: vector of constraint discrepancies (length `n`)
#'   - `max_discr`: maximum constraint discrepancy (`max(discr_vec)`)
#'   - `tot_discr`: sum of all constraint discrepancies (`sum(discr_vec)`)
#'
#' @details
#' Compare the evaluated constraints body (`Ax`) against the constraints bounds
#' (`l` and `u`). Discrepancies are positive values representing constraint bounds 
#' *violations*. A discrepancy of 0 means that the corresponding constraint bounds 
#' are fully respected.
#'   - Equality (`==`) constraints have `l = u`
#'   - Inequality (`<=` or `>=`) constraints either have `l = -Inf` or `u = Inf`
#' A given constraint discrepancy corresponds to `max(l - Ax, Ax - u, 0)`
#'
#' @noRd
calc_discr <- function(Ax, l, u) {
  
  discr_vec <- pmax.int(l - Ax, Ax - u, 0)
  list(discr_vec = discr_vec,
       max_discr = max(discr_vec),
       tot_discr = sum(discr_vec))
}


#' Return the Initial Solution
#' 
#' @description
#' Do not solve the balancing problem. Simply return the initial solution info.
#'
#' @param x (double vector) initial problem values (initial solution).
#' @param Ax (double vector) initial evaluated constraint body values.
#' @param discr (list) initial constraint discrepancies list.
#' @param validation_tol (double) solution validation tolerance (max. allowed constraint discr.).
#' @param ... receptacle for other (ignored) `solve_one_osqp()` arguments.
#'
#' @return a list with the following elements elements:
#'   - `x`: (double vector) initial solution.
#'   - `status`: (string) solution status description.
#'   - `status_val`: (integer) solution status value.
#'   - `Ax`: (double vector) evaluated constraint body values with the initial solution.
#'   - `discr`: (list) initial constraint discrepancies.
#'   - `type`: (string) solution type (`"initial"`).
#'   - `osqp_attempts`: (integer) number of OSQP attempts (`0`).
#'   - `osqp_seqno`: (integer) sequence (iteration) number of the OSQP solution (`NA`).
#'   - `osqp_settings`: (list) OSQP solution settings (`NULL`).
#'   - `osqp_info`: (list) OSQP solution info (`NULL`).
#'   - `seq_time`: solving sequence execution time in seconds.
#'
#' @details
#' This function is used when main argument `validation_only = TRUE`
#'
#' @noRd
return_initial_sol <- function(x,
                               Ax,
                               discr,
                               validation_tol,
                               ...) {
  
  start_time <- Sys.time()
  
  if (discr$max_discr <= validation_tol) {
    status <- "valid initial solution"
    status_val <- 1
  } else {
    status <- "invalid initial solution"
    status_val <- -1
  }
  
  list(x = x,
       status = status,
       status_val = status_val,
       Ax = Ax,
       discr = discr,
       type = "initial",
       osqp_attempts = 0,
       osqp_seqno = NA_integer_,
       osqp_settings = NULL,
       osqp_info = NULL,
       seq_time = Sys.time() - start_time)
}


#' Solve the balancing problem
#' 
#' @description
#' Solve a single balancing problem with OSQP.
#'
#' @param x (double vector) initial problem values (initial solution).
#' @param Ax (double vector) evaluated constraint body values with the initial solution.
#' @param discr (list) initial constraint discrepancies list.
#' @param validation_tol (double) solution validation tolerance (max. allowed constraint discr.).
#' @param P,q,A,l,u (double matrix, vector, matrix, vector and vector) OSQP problem elements.
#' @param settings_df (data.frame) OSQP settings sequence data frame.
#' @param full_sequence (logical) perform all steps (rows) of `settings_df`.
#' @param solve_msg_func (function) message display function.
#' @param osqpBeg_display_func (function) OSQP model and iterations display set up function.
#' @param osqpEnd_display_func (function) OSQP model and iterations display wrap up function.
#' @param osqp_output_file (string) temporary file (name and path) for the OSQP model and iterations contents.
#' @param trunc_to_zero_tol (double) tolerance for changing nonzero solution data points to 0.
#' 
#' @return a list with the following elements elements:
#'   - `x`: (double vector) final solution.
#'   - `status`: (string) solution status description.
#'   - `status_val`: (integer) solution status value.
#'   - `Ax`: (double vector) evaluated constraint body values with the final solution.
#'   - `discr`: (list) final constraint discrepancies list.
#'   - `type`: (string) solution type (`"initial"` or `"osqp"`).
#'   - `osqp_attempts`: (integer) number of OSQP attempts.
#'   - `osqp_seqno`: (integer) sequence (iteration) number of the OSQP solution (`NA` if `type = "initial"`).
#'   - `osqp_settings`: (list) OSQP solution settings (`NULL` if `type = "initial"`).
#'   - `osqp_info`: (list) OSQP solution info (`NULL` if `type = "initial"`).
#'   - `seq_time`: solving sequence execution time in seconds.
#'
#' @details
#' This function is used when main argument `validation_only = FALSE`
#'
#' The settings data frame (argument `settings_df`) dictates the total number of attempts made
#' at solving the problem. Each attempt is made with the list of OSQP settings for the corresponding
#' `settings_df` observation (row). Unless a full sequence is specified (argument `full_sequence = TRUE`), 
#' the solving sequence stops as soon as a valid solution is obtained (a solution for which all constraint 
#' discrepancies are smaller or equal to the tolerance specified with argument `validation_tol`) unless setting 
#' `require_polished = TRUE` is specified in the settings data frame for that step, in which case a polished 
#' solution from OSQP (`status_polish = 1`) would also be required to stop the sequence. 
#' 
#' Note that the constraint discrepancies are calculated on the *zero truncated* solution values, when applicable 
#' (i.e., when argument `trunc_to_zero_tol > 0`), therefore ensuring accurate validation of the final solution.
#'
#' @noRd
solve_one_osqp <- function(x,
                           Ax,
                           discr,
                           validation_tol,
                           P, q, A, l, u,
                           settings_df,
                           full_sequence,
                           solve_msg_func,
                           osqpBeg_display_func,
                           osqpEnd_display_func,
                           osqp_output_file,
                           trunc_to_zero_tol) {
  
  
  start_time <- Sys.time()
  
  # Print the initial solution discrepancies
  solve_msg_func("  Initial solution:\n    - Maximum discrepancy = ", format(discr$max_discr, big.mark = ","),
                 "\n    - Total discrepancy   = ", format(discr$tot_discr, big.mark = ","), "\n")
  
  
  # No initial discrepancies: return the initial solution
  if (discr$tot_discr <= gs.min_tolerance) {
    
    solve_msg_func("  No discrepancies. Returning the intial values.\n")
    
    status <- "valid initial solution"
    status_val <- 1
    type <- "initial"
    osqp_attempts <- 0
    osqp_seqno <- NA_integer_
    osqp_settings <- NULL
    osqp_info <- NULL
    
    
    # Fixed problem (all values are either 0 or binding): return the initial solution
  } else if (any(is.na(q))) {
    
    if (discr$max_discr <= validation_tol) {
      solve_msg_func("  Fixed balancing problem (all values are either 0 or binding) with a valid initial solution (maximum discrepancy <= ", 
                     format(validation_tol), " = `validation_tol`).\n")
      status <- "valid initial solution"
      status_val <- 1
    } else {
      warning("Unsolvable fixed balancing problem (all values are either 0 or binding) with an invalid initial solution (maximum discrepancy > ", 
              format(validation_tol), " = `validation_tol`).", call. = FALSE, immediate. = TRUE)
      message("\n")
      status <- "unsolvable fixed problem"
      status_val <- -4
    }
    type <- "initial"
    osqp_attempts <- 0
    osqp_seqno <- NA_integer_
    osqp_settings <- NULL
    osqp_info <- NULL
    
    
    # At least one free (nonbinding) value: try to solve with OSQP
  } else {
    
    # Note regarding flags `valid` and `satisfactory` used for the OSQP solving loop:
    #  - `valid`       : is TRUE if a valid solution (`max_discr <= validation_tol`) hasbeen found (initial or OSQP).
    #  - `satisfactory`: is TRUE if a satisfactory OSQP solution (`valid & polished` when required, `valid` otherwise) 
    #                    has been found.
    #
    # `satisfactory == TRUE` stops the solving loop (unless 'full_sequence == TRUE`); it is therefore initialized to 
    # `FALSE` here (as we hope to improve the initial solution with OSQP).
    satisfactory <- FALSE
    if (discr$max_discr <= validation_tol) {
      valid <- TRUE
      solve_msg_func("  Valid solution (maximum discrepancy <= ", format(validation_tol), " = `validation_tol`).\n")
      status <- "valid initial solution"
      status_val <- 1
    } else {
      valid <- FALSE
      status <- "invalid initial solution"
      status_val <- -1
    }
    solve_msg_func("  Try to find a better solution with OSQP.\n")
    
    # Calculate the scaling factor
    mean_abs_x <- mean(abs(x))
    
    
    # Solving loop
    best_osqp <- NA_integer_
    for (ii in seq_along(settings_df$verbose)) {
      
      # Set the scaling factor
      if (settings_df$prior_scaling[ii]) {
        factor_ii <- mean_abs_x
      } else {
        factor_ii <- 1
      }
      
      osqpBeg_display_func(osqp_output_file)
      
      # Build the model (ii-th row of `settings_df`)
      model_ii <- osqp::osqp(P * factor_ii, q, A, l / factor_ii, u / factor_ii, as.list(settings_df[ii, , drop = FALSE]))
      
      # Solve
      sol_ii <- model_ii$Solve() 
      sol_ii$x <- sol_ii$x * factor_ii  # original scale
      
      osqpEnd_display_func(osqp_output_file)
      
      # Trunc to zero
      sol_ii$x[abs(sol_ii$x) <= trunc_to_zero_tol] <- 0
      
      
      # Evaluate:
      #  a) update the "current solution" when relevant (smallest `tot_discr` among valid/invalid solutions so far)
      #  b) stop the solving loop if a satisfactory OSQP solution was found and not doing a full OSQP sequence
      Ax_ii <- A %*% sol_ii$x
      discr_ii <- calc_discr(Ax_ii, l, u)
      polished_ii <- sol_ii$info$status_polish == 1
      solve_msg_func("  OSQP iteration ", ii, ":\n    - Maximum discrepancy = ", format(discr_ii$max_discr, big.mark = ","),
                     "\n    - Total discrepancy   = ", format(discr_ii$tot_discr, big.mark = ","), "\n")
      
      # Valid solution (`max_discr <= validation_tol`)
      if (discr_ii$max_discr <= validation_tol) {
        solve_msg_func("  Valid solution (maximum discrepancy <= ", format(validation_tol), " = `validation_tol`).\n")
        
        # Polished solution required
        if (settings_df$require_polished[ii]) {
          if (polished_ii) {
            satisfactory <- TRUE
            solve_msg_func("  Required polished solution achieved.\n")
            status_ii <- "valid polished osqp solution"
            status_val_ii <- 2
          } else {
            solve_msg_func("  Required polished solution NOT achieved.\n")
            status_ii <- "valid unpolished osqp solution"
            status_val_ii <- 3
          }
          
          # Polished solution NOT required
        } else {
          satisfactory <- TRUE
          if (polished_ii) {
            status_ii <- "valid polished osqp solution"
            status_val_ii <- 2
          } else {
            status_ii <- "valid unpolished osqp solution"
            status_val_ii <- 3
          }
        }
        
        # Update the "current (valid) solution"
        if (!valid || discr_ii$tot_discr < discr$tot_discr) {
          valid <- TRUE
          status <- status_ii
          status_val <- status_val_ii
          Ax <- Ax_ii
          discr <- discr_ii
          best_osqp <- ii
          model <- model_ii
          sol <- sol_ii
          scaling_factor <- factor_ii
        }
        
        # Stop the solving loop
        if (satisfactory && !full_sequence) {
          break
        }
        
        # Invalid solution (`max_discr > validation_tol`)
      } else {
        solve_msg_func("  Invalid solution (maximum discrepancy > ", format(validation_tol), " = `validation_tol`).\n")
        
        # Update the "current (invalid) solution"
        if (!valid && discr_ii$tot_discr < discr$tot_discr) {
          if (polished_ii) {
            status <- "invalid polished osqp solution"
            status_val <- -2
          } else {
            status <- "invalid unpolished osqp solution"
            status_val <- -3
          }
          Ax <- Ax_ii
          discr <- discr_ii
          best_osqp <- ii
          model <- model_ii
          sol <- sol_ii
          scaling_factor <- factor_ii
        }
      }
    }
    
    
    # Wrap up the final solution    
    osqp_attempts <- ii
    
    # Initial solution
    if (is.na(best_osqp)) {
      solve_msg_func("  The initial solution could not be improved with OSQP. Returning the initial solution.\n")
      type <- "initial"
      osqp_seqno <- NA_integer_
      osqp_settings <- NULL
      osqp_info <- NULL
      
      # OSQP solution
    } else {
      if (!satisfactory) {
        if (valid) {
          word <-  "valid"
        } else {
          word <-  "all"
        }
        solve_msg_func("  A satisfactory OSQP solution could not be obtained. Returning the solution with the smallest ",
                       "total discrepancy among ", word, " solutions (OSQP iteration ", best_osqp, ").\n")
      }
      x <- sol$x
      type <- "osqp"
      osqp_seqno <- best_osqp
      osqp_settings <- c(model$GetParams(), list(prior_scaling = settings_df$prior_scaling[best_osqp]))
      osqp_info <- c(sol$info, list(prior_scaling_factor = scaling_factor))
    }
  }
  
  
  # Return the final solution
  list(x = x,
       status = status,
       status_val = status_val,
       Ax = Ax,
       discr = discr,
       type = type,
       osqp_attempts = osqp_attempts,
       osqp_seqno = osqp_seqno,
       osqp_settings = osqp_settings,
       osqp_info = osqp_info,
       seq_time = Sys.time() - start_time)
}
