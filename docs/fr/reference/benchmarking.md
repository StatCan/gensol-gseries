# Rétablir les contraintes temporelles

*Réplication de la procédure BENCHMARKING de G-Séries 2.0 en
SAS\\^\circledR\\ (PROC BENCHMARKING). Voir la documentation de G-Séries
2.0 pour plus de détails (Statistique Canada 2016).*

Cette fonction assure la cohérence entre les données de séries
chronologiques d'une même variable cible mesurée à des fréquences
différentes (ex., infra-annuellement et annuellement). L'étalonnage
consiste à imposer le niveau de la série d'étalons (ex., données
annuelles) tout en minimisant, autant que possible, les révisions au
mouvement observé dans la série indicatrice (ex., données
infra-annuelles). La fonction permet également l'étalonnage non
contraignant où la série d'étalons peut également être révisée.

La fonction peut également être utilisée pour des sujets liés à
l'étalonnage tels que la *distribution temporelle* (action réciproque de
l'étalonnage : désagrégation de la série d'étalons en observations plus
fréquentes), la *calendarisation* (cas spécial de distribution
temporelle) et le *raccordement* (« *linking* » : connexion de
différents segments de séries chronologiques en une série chronologique
unique et cohérente).

Plusieurs séries peuvent être étalonnées en un seul appel de fonction.

## Utilisation

``` r
benchmarking(
  series_df,
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

  # Nouveau dans G-Séries 3.0
  constant = 0,
  negInput_option = 0,
  allCols = FALSE,
  quiet = FALSE
)
```

## Arguments

- series_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») qui contient les
  données de la (des) série(s) indicatrice(s) à étalonner. En plus de la
  (des) variable(s) contenant les données, spécifiée(s) avec l'argument
  `var`, le *data frame* doit aussi contenir deux variables numériques,
  `year` et `period`, identifiant les périodes des séries indicatrices.

- benchmarks_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») qui contient les
  étalons. En plus de la (des) variable(s) contenant les données,
  spécifiée(s) avec l'argument `with`, le *data frame* doit aussi
  contenir quatre variables numériques, `startYear`, `startPeriod`,
  `endYear` et `endPeriod`, identifiant les périodes des séries
  indicatrices couvertes par chaque étalon.

- rho:

  (obligatoire)

  Nombre réel compris dans l'intervalle \\\[0,1\]\\ qui spécifie la
  valeur du paramètre autorégressif \\\rho\\. Voir la section
  **Détails** pour plus d'informations sur l'effet du paramètre
  \\\rho\\.

- lambda:

  (obligatoire)

  Nombre réel, avec des valeurs suggérées dans l'intervalle
  \\\[-3,3\]\\, qui spécifie la valeur du paramètre du modèle
  d'ajustement \\\lambda\\. Les valeurs typiques sont `lambda = 0.0`
  pour un modèle additif et `lambda = 1.0` pour un modèle proportionnel.

- biasOption:

  (obligatoire)

  Spécification de l'option d'estimation du biais :

  - `1` : Ne pas estimer le biais. Le biais utilisé pour corriger la
    série indicatrice sera la valeur spécifiée avec l'argument `bias`.

  - `2` : Estimer le biais, afficher le résultat, mais ne pas
    l'utiliser. Le biais utilisé pour corriger la série indicatrice sera
    la valeur spécifiée avec l'argument `bias`.

  - `3` : Estimer le biais, afficher le résultat et utiliser le biais
    estimé pour corriger la série indicatrice. Toute valeur spécifiée
    avec l'argument `bias` sera ignorée.

  L'argument `biasOption` n'est pas utilisé quand `rho = 1.0`. Voir la
  section **Détails** pour plus d'informations sur le biais.

- bias:

  (optionnel)

  Nombre réel, ou `NA`, spécifiant la valeur du biais défini par
  l'utilisateur à utiliser pour la correction de la série indicatrice
  avant de procéder à l'étalonnage. Le biais est ajouté à la série
  indicatrice avec un modèle additif (argument `lambda = 0.0`) alors
  qu'il est multiplié dans le cas contraire (argument `lambda != 0.0`).
  Aucune correction de biais n'est appliquée lorsque `bias = NA`, ce qui
  équivaut à spécifier `bias = 0.0` lorsque `lambda = 0.0` et
  `bias = 1.0` dans le cas contraire. L'argument `bias` n'est pas
  utilisé lorsque `biasOption = 3` ou `rho = 1.0`. Voir la section
  **Détails** pour plus d'informations sur le biais.

  **La valeur par défaut** est `bias = NA` (pas de biais défini par
  l'utilisateur).

- tolV, tolP:

  (optionnel)

  Nombre réel non négatif, ou `NA`, spécifiant la tolérance, en valeur
  absolue ou en pourcentage, à utiliser pour la validation des étalons
  contraignants (coefficient d'altérabilité de \\0.0\\) en sortie. Cette
  validation consiste à comparer la valeur des étalons contraignants en
  entrée à la valeur équivalente calculée à partir des données de la
  série étalonnée (sortie). Les arguments `tolV` et `tolP` ne peuvent
  pas être spécifiés tous les deux à la fois (l'un doit être spécifié
  tandis que l'autre doit être `NA`).

  **Exemple :** pour une tolérance de 10 *unités*, spécifiez
  `tolV = 10, tolP = NA`; pour une tolérance de 1%, spécifiez
  `tolV = NA, tolP = 0.01`.

  **Les valeurs par défaut** sont `tolV = 0.001` et `tolP = NA`.

- warnNegResult:

  (optionnel)

  Argument logique (*logical*) spécifiant si un message d'avertissement
  doit être affiché lorsqu'une valeur négative créée par la fonction
  dans la série étalonnée (en sortie) est inférieure au seuil spécifié
  avec l'argument `tolN`.

  **La valeur par défaut** est `warnNegResult = TRUE`.

- tolN:

  (optionnel)

  Nombre réel négatif spécifiant le seuil pour l'identification des
  valeurs négatives. Une valeur est considérée négative lorsqu'elle est
  inférieure à ce seuil.

  **La valeur par défaut** est `tolN = -0.001`.

- var:

  (optionnel)

  Vecteur (longueur minimale de 1) de chaînes de caractères spécifiant
  le(s) nom(s) de variable(s) du *data frame* des séries indicatrices
  (argument `series_df`) contenant les valeurs et (optionnellement) les
  coefficients d'altérabilité définis par l'utilisateur de la (des)
  série(s) à étalonner. Ces variables doivent être numériques.

  La syntaxe est
  `var = c("serie1 </ alt_ser1>", "serie2 </ alt_ser2>", ...)`. Des
  coefficients d'altérabilité par défaut de \\1.0\\ sont utilisés
  lorsqu'une variable de coefficients d'altérabilité définie par
  l'utilisateur n'est pas spécifiée à côté d'une variable de série
  indicatrice. Voir la section **Détails** pour plus d'informations sur
  les coefficients d'altérabilité.

  **Exemple :** `var = "value / alter"` étalonnerait la variable `value`
  du *data frame* des séries indicatrices avec les coefficients
  d'altérabilité contenus dans la variable `alter` tandis que
  `var = c("value / alter", "value2")` étalonnerait en plus la variable
  `value2` avec des coefficients d'altérabilité par défaut de \\1.0\\.

  **La valeur par défaut** est `var = "value"` (étalonner la variable
  `value` avec des coefficients d'altérabilité par défaut de \\1.0\\).

- with:

  (optionnel)

  Vecteur (même longueur que l'argument `var`) de chaînes de caractères,
  ou `NULL`, spécifiant le(s) nom(s) de variable(s) du *data frame* des
  étalons (argument `benchmarks_df`) contenant les valeurs et
  (optionnellement) les coefficients d'altérabilité définis par
  l'utilisateur des étalons. Ces variables doivent être numériques. La
  spécification de `with = NULL` entraîne l'utilisation de variable(s)
  d'étalons correspondant à la (aux) variable(s) spécifiée(s) avec
  l'argument `var` sans coefficients d'altérabilité d'étalons définis
  par l'utilisateur (c'est à dire des coefficients d'altérabilité par
  défaut de \\0.0\\ correspondant à des étalons contraignants).

  La syntaxe est `with = NULL` ou
  `with = c("bmk1 </ alt_bmk1>", "bmk2 </ alt_bmk2>", ...)`. Des
  coefficients d'altérabilité par défaut de \\0.0\\ (étalons
  contraignants) sont utilisés lorsqu'une variable de coefficients
  d'altérabilité définie par l'utilisateur n'est pas spécifiée à côté
  d'une variable d'étalon. Voir la section **Détails** pour plus
  d'informations sur les coefficients d'altérabilité.

  **Exemple :** `with = "val_bmk"` utiliserait la variable `val_bmk` du
  *data frame* des étalons avec les coefficients d'altérabilité par
  défaut de \\0.0\\ pour étalonner la série indicatrice tandis que
  `with = c("val_bmk", "val_bmk2 / alt_bmk2")` étalonnerait en plus une
  deuxième série indicatrice en utilisant la variable d'étalons
  `val_bmk2` avec les coefficients d'altérabilité d'étalons contenus
  dans la variable `alt_bmk2`.

  **La valeur par défaut** est `with = NULL` (même(s) variable(s)
  d'étalons que l'argument `var` avec des coefficients d'altérabilité
  d'étalons par défaut de \\0.0\\).

- by:

  (optionnel)

  Vecteur (longueur minimale de 1) de chaînes de caractères, ou `NULL`,
  spécifiant le(s) nom(s) de variable(s) dans les *data frames* d'entrée
  (arguments `series_df` et `benchmarks_df`) à utiliser pour former des
  groupes (pour le traitement « groupes-BY ») et permettre l'étalonnage
  de plusieurs séries en un seul appel de fonction. Les variables
  groupes-BY peuvent être numériques ou caractères (facteurs ou non),
  doivent être présentes dans les deux *data frames* d'entrée et
  apparaîtront dans les trois *data frames* de sortie (voir la section
  **Valeur de retour**). Le traitement groupes-BY n'est pas implémenté
  lorsque `by = NULL`. Voir « Étalonnage de plusieurs séries » dans la
  section **Détails** pour plus d'informations.

  **La valeur par défaut** est `by = NULL` (pas de traitement
  groupes-BY).

- verbose:

  (optionnel)

  Argument logique (*logical*) spécifiant si les informations sur les
  étapes intermédiaires avec le temps d'exécution (temps réel et non le
  temps CPU) doivent être affichées. Notez que spécifier l'argument
  `quiet = TRUE` annulerait l'argument `verbose`.

  **La valeur par défaut** est `verbose = FALSE`.

- constant:

  (optionnel)

  Nombre réel qui spécifie une valeur à ajouter temporairement à la fois
  à la (aux) série(s) indicatrice(s) et aux étalons avant de résoudre
  les problèmes d'étalonnage proportionnels (`lambda != 0.0`). La
  constante temporaire est enlevée de la série étalonnée finale en
  sortie. Par exemple, la spécification d'une (petite) constante
  permettrait l'étalonnage proportionnel avec `rho = 1` (étalonnage de
  Denton proportionnel) sur avec des séries indicatrices qui comprennent
  des valeurs de 0. Sinon, l'étalonnage proportionnel avec des valeurs
  de 0 pour la série indicatrice n'est possible que lorsque `rho < 1`.
  Spécifier une constante avec l'étalonnage additif (`lambda = 0.0`) n'a
  pas d'impact sur les données étalonnées résultantes. Les variables de
  données dans le *data frame* de sortie `graphTable` incluent la
  constante, correspondant au problème d'étalonnage effectivement résolu
  par la fonction.

  **La valeur par défaut** est `constant = 0` (pas de constante additive
  temporaire).

- negInput_option:

  (optionnel)

  Traitement des valeurs négatives dans les données d'entrée pour
  l'étalonnage proportionnel (`lambda != 0.0`) :

  - `0` : Ne pas autoriser les valeurs négatives pour l'étalonnage
    proportionnel. Un message d'erreur est affiché en présence de
    valeurs négatives dans les séries indicatrices ou les étalons
    d'entrée et des valeurs manquantes (`NA`) sont renvoyées pour les
    séries étalonnées. Ceci correspond au comportement de G-Séries 2.0.

  - `1` : Autoriser les valeurs négatives pour l'étalonnage
    proportionnel mais avec l'affichage d'un message d'avertissement.

  - `2` : Autoriser les valeurs négatives pour l'étalonnage
    proportionnel sans afficher de message.

  **La valeur par défaut** est `negInput_option = 0` (ne pas autoriser
  les valeurs négatives pour l'étalonnage proportionnel).

- allCols:

  (optionnel)

  Argument logique (*logical*) spécifiant si toutes les variables du
  *data frame* des séries indicatrices (argument `series_df`), autres
  que `year` et `period`, déterminent l'ensemble des séries à étalonner.
  Les valeurs spécifiées avec les arguments `var` et `with` sont
  ignorées lorsque `allCols = TRUE`, ce qui implique automatiquement des
  coefficients d'altérabilité par défaut, et des variables avec les
  mêmes noms que les séries indicatrices doivent exister dans le *data
  frame* des étalons (argument `benchmarks_df`).

  **La valeur par défaut** est `allCols = FALSE`.

- quiet:

  (optionnel)

  Argument logique (*logical*) spécifiant s'il faut ou non afficher
  uniquement les informations essentielles telles que les messages
  d'avertissements, les messages d'erreurs et les informations sur les
  variables (séries) ou les groupes-BY lorsque plusieurs séries sont
  étalonnées en un seul appel à la fonction. Nous vous déconseillons
  d'*envelopper* votre appel à `benchmarking()` avec
  [`suppressMessages()`](https://rdrr.io/r/base/message.html) afin de
  supprimer l'affichage des informations sur les variables (séries) ou
  les groupes-BY lors du traitement de plusieurs séries, car cela
  compliquerait le dépannage en cas de problèmes avec des séries
  individuelles. Notez que la spécification de `quiet = TRUE` annulera
  également l'argument `verbose`.

  **La valeur par défaut** est `quiet = FALSE`.

## Valeur de retour

La fonction renvoie une liste de trois *data frames* :

- `series` : *data frame* contenant les données étalonnées (sortie
  principale de la fonction). Les variables BY spécifiées avec
  l'argument `by` sont incluses dans le *data frame* mais pas les
  variables de coefficient d'altérabilité spécifiées avec l'argument
  `var`.

- `benchmarks` : copie du *data frame* d'entrée des étalons (à
  l'exclusion des étalons non valides, le cas échéant). Les variables BY
  spécifiées avec l'argument `by` sont incluses dans le *data frame*
  mais pas les variables de coefficient d'altérabilité spécifiées avec
  l'argument `with`.

- `graphTable` : *data frame* contenant des données supplémentaires
  utiles pour produire des tableaux et des graphiques analytiques (voir
  la fonction
  [`plot_graphTable()`](https://StatCan.github.io/gensol-gseries/fr/reference/plot_graphTable.md)).
  Il contient les variables suivantes en plus des variables BY
  spécifiées avec l'argument `by` :

  - `varSeries` : Nom de la variable de la série indicatrice

  - `varBenchmarks` : Nom de la variable des étalons

  - `altSeries` : Nom de la variable des coefficients d'altérabilité
    définis par l'utilisateur pour la série indicatrice

  - `altSeriesValue` : Coefficients d'altérabilité de la série
    indicatrice

  - `altbenchmarks` : Nom de la variable des coefficients d'altérabilité
    définis par l'utilisateur pour les étalons

  - `altBenchmarksValue` : Coefficients d'altérabilité des étalons

  - `t` : Identificateur de la période de la série indicatrice (1 à
    \\T\\)

  - `m` : Identificateur des périodes de couverture de l'étalon (1 à
    \\M\\)

  - `year` : Année civile du point de données

  - `period` : Valeur de la période (du cycle) du point de données (1 à
    `periodicity`)

  - `constant` : Constante additive temporaire (argument `constant`)

  - `rho` : Paramètre autorégressif \\\rho\\ (argument `rho`)

  - `lambda` : Paramètre du modèle d'ajustement \\\lambda\\ (argument
    `lambda`)

  - `bias` : Ajustement du biais (par défaut, défini par l'utilisateur
    ou biais estimé selon les arguments `biasOption` et `bias`)

  - `periodicity` : Le nombre maximum de périodes dans une année (par
    exemple 4 pour une série indicatrice trimestrielle)

  - `date` : Chaîne de caractères combinant les valeurs des variables
    `year` et `period`

  - `subAnnual` : Valeurs de la série indicatrice

  - `benchmarked` : Valeurs de la série étalonnée

  - `avgBenchmark` : Valeurs des étalons divisées par le nombre de
    périodes de couverture

  - `avgSubAnnual` : Valeurs moyennes de la série indicatrice (variable
    `subAnnual`) pour les périodes couvertes par les étalons

  - `subAnnualCorrected` : Valeurs de la série indicatrice corrigée pour
    le biais

  - `benchmarkedSubAnnualRatio` : Différence (\\\lambda = 0\\) ou ratio
    (\\\lambda \ne 0\\) des valeurs des variables `benchmarked` et
    `subAnnual`

  - `avgBenchmarkSubAnnualRatio` : Différence (\\\lambda = 0\\) ou ratio
    (\\\lambda \ne 0\\) des valeurs des variables `avgBenchmark` et
    `avgSubAnnual`

  - `growthRateSubAnnual` : Différence (\\\lambda = 0\\) ou différence
    relative (\\\lambda \ne 0\\) d'une période à l'autre des valeurs de
    la série indicatrice (variable `subAnnual`)

  - `growthRateBenchmarked` : Différence (\\\lambda = 0\\) ou différence
    relative (\\\lambda \ne 0\\) d'une période à l'autre des valeurs de
    la série étalonnée (variable `benchmarked`)

Notes :

- Le *data frame* de sortie `benchmarks` contient toujours les étalons
  originaux fournis dans le *data frame* d'entrée des étalons. Les
  étalons modifiés non contraignants, le cas échéant, peuvent être
  récupérés (calculés) à partir du *data frame* de sortie `series`.

- La fonction renvoie un objet `NULL` si une erreur se produit avant que
  le traitement des données ne puisse commencer. Dans le cas contraire,
  si l'exécution est suffisamment avancée pour que le traitement des
  données puisse commencer, alors un objet incomplet sera renvoyé en cas
  d'erreur (par exemple, un *data frame* de sortie `series` avec des
  valeurs `NA` pour les données étalonnées).

- La fonction renvoie des objets « data.frame » qui peuvent être
  explicitement convertis en d'autres types d'objets avec la fonction
  `as*()` appropriée (ex.,
  [`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
  convertirait n'importe lequel d'entre eux en tibble).

## Détails

Lorsque \\\rho \< 1\\, cette fonction renvoie la solution des moindres
carrés généralisés d'un cas particulier du modèle général d'étalonnage
basé sur la régression proposé par Dagum et Cholette (2006). Le modèle,
sous forme matricielle, est le suivant : \$\$\displaystyle
\begin{bmatrix} s^\dagger \\ a \end{bmatrix} = \begin{bmatrix} I \\ J
\end{bmatrix} \theta + \begin{bmatrix} e \\ \varepsilon \end{bmatrix}
\$\$ où

- \\a\\ est le vecteur de longueur \\M\\ des étalons.

- \\s^\dagger = \left\\ \begin{array}{cl} s + b & \text{si } \lambda = 0
  \\ s \cdot b & \text{sinon} \end{array} \right. \\ est le vecteur de
  longueur \\T\\ des valeurs de la série indicatrice corrigée pour le
  biais, \\s\\ désignant la série indicatrice initiale (d'entrée).

- \\b\\ est le bias, qui est spécifié avec l'argument `bias` lorsque
  `bias_option != 3` ou, lorsque `bias_option = 3`, est estimé par
  \\\hat{b} = \left\\ \begin{array}{cl} \frac{{1_M}^\mathrm{T} (a -
  Js)}{{1_M}^\mathrm{T} J 1_T} & \text{si } \lambda = 0 \\
  \frac{{1_M}^\mathrm{T} a}{{1_M}^\mathrm{T} Js} & \text{sinon}
  \end{array} \right. \\, où \\1_X = (1, ..., 1)^\mathrm{T}\\ est un
  vecteur de \\1\\ de longueur \\X\\.

- \\J\\ est la matrice \\M \times T\\ des contraintes d'agrégation
  temporelles avec les éléments \\j\_{m, t} = \left\\ \begin{array}{cl}
  1 & \text{si l'étalon } m \text{ couvre la période } t \\ 0 &
  \text{sinon} \end{array} \right. \\.

- \\\theta\\ est le vecteur des valeurs de la série finale (étalonnée).

- \\e \sim \left( 0, V_e \right)\\ est le vecteur des erreurs de mesure
  de \\s^\dagger\\ avec matrice de covariance \\V_e = C \Omega_e C\\.

- \\C = \mathrm{diag} \left( \sqrt{c\_{s^\dagger}} \left\| s^\dagger
  \right\|^\lambda \right)\\ où \\c\_{s^\dagger}\\ est le vecteur des
  coefficients d'altérabilité de \\s^\dagger\\, en définissant \\0^0 =
  1\\.

- \\\Omega_e\\ est une matrice \\T \times T\\ avec les éléments
  \\\omega\_{e\_{i,j}} = \rho^{\|i-j\|}\\ représentant l'autocorrelation
  d'un processus AR(1), en définissant encore \\0^0 = 1\\.

- \\\varepsilon \sim (0, V\_\varepsilon)\\ est le vecteur des erreurs de
  mesure des étalons \\a\\ avec matrice de covariance \\V\_\varepsilon =
  \mathrm{diag} \left( c_a a \right)\\ où \\c_a\\ est le vecteur des
  coefficients d'altérabilité des étalons \\a\\.

La solution des moindres carrés généralisés est la suivante :
\$\$\displaystyle \hat{\theta} = s^\dagger + V_e J^{\mathrm{T}} \left( J
V_e J^{\mathrm{T}} + V\_\varepsilon \right)^+ \left( a - J s^\dagger
\right) \$\$ où \\A^{+}\\ désigne l'inverse de Moore-Penrose de la
matrice \\A\\.

Lorsque \\\rho = 1\\, la fonction renvoie la solution de la méthode de
Denton (modifiée) : \$\$\displaystyle \hat{\theta} = s + W \left( a - J
s \right) \$\$ où

- \\W\\ est la matrice du coin supérieur droit du produit matriciel
  suivant \$\$ \left\[\begin{array}{cc} D^{+} \Delta^{\mathrm{T}} \Delta
  D^{+} & J^{\mathrm{T}} \\ J & 0 \end{array} \right\]^{+}
  \left\[\begin{array}{cc} D^{+} \Delta^{\mathrm{T}} \Delta D^{+} & 0 \\
  J & I_M \end{array} \right\] = \left\[\begin{array}{cc} I_T & W \\ 0 &
  W\_\nu \end{array} \right\] \$\$

- \\D = \mathrm{diag} \left( \left\| s \right\|^\lambda \right)\\, en
  définissant \\0^0 = 1\\. Notez que \\D\\ correspond à \\C\\ avec
  \\c\_{s^\dagger} = 1.0\\ et sans correction de biais (arguments
  `bias_option = 1` et `bias = NA`).

- \\\Delta\\ est une matrice \\T-1 \times T\\ avec les éléments
  \\\delta\_{i,j} = \left\\ \begin{array}{cl} -1 & \text{si } i=j \\ 1 &
  \text{si } j=i+1 \\ 0 & \text{sinon} \end{array} \right. \\.

- \\W\_\nu\\ est une matrice \\M \times M\\ associée aux multiplicateurs
  de Lagrange du problème de minimisation correspondant exprimé comme
  suit : \$\$\displaystyle \begin{aligned} &
  \underset{\theta}{\text{minimiser}} & & \sum\_{t \ge 2} \left\[
  \frac{\left( s_t - \theta_t \right)}{\left\| s_t\right\|^\lambda} -
  \frac{\left( s\_{t-1} - \theta\_{t-1} \right)}{\left\|
  s\_{t-1}\right\|^\lambda} \right\]^2 \\ & \text{sous contrainte(s)} &
  & a = J \theta \end{aligned} \$\$

Voir Quenneville et al. (2006) et Dagum and Cholette (2006) pour les
détails.

### Paramètre autorégressif \\\rho\\ et le *biais*

Le paramètre \\\rho\\ (argument `rho`) est associé au changement entre
la série indicatrice (d'entrée) et la série étalonnée (de sortie) pour
deux périodes consécutives et est souvent appelé *paramètre de
préservation du mouvement*. Plus la valeur de \\\rho\\ est grande, plus
les mouvements d'une période à l'autre de la série indicatrice sont
préservés dans la série étalonnée. Avec \\\rho = 0\\, la préservation
des mouvements d'une période à l'autre n'est pas appliquée et les
ajustements d'étalonnage qui en résultent ne sont pas lisses, comme dans
le cas du prorata (\\\rho = 0\\ et \\\lambda = 0.5\\) où les ajustements
prennent la forme d'une *fonction en escalier*. À l'autre extrémité du
spectre on trouve \\\rho = 1\\, appelé *étalonnage de Denton*, où la
préservation du mouvement d'une période à l'autre est maximisée, ce qui
se traduit par l'ensemble le plus lisse possible d'ajustements
d'étalonnage disponibles avec la fonction.

Le *biais* représente l'écart attendu entre les étalons et la série
indicatrice. Il peut être utilisé pour pré-ajuster la série indicatrice
afin de réduire, en moyenne, les écarts entre les deux sources de
données. La correction du biais, qui est spécifiée avec les arguments
`biasOption` et `bias`, peut être particulièrement utile pour les
périodes non couvertes par les étalons lorsque \\\rho \< 1\\. Dans ce
contexte, le paramètre \\\rho\\ dicte la vitesse à laquelle les
ajustements d'étalonnage projetés convergent vers le biais (ou
convergent vers *aucun ajustement* sans correction du biais) pour les
périodes non couvertes par un étalon. Plus la valeur de \\\rho\\ est
petite, plus la convergence vers le biais est rapide, avec convergence
immédiate lorsque \\\rho = 0\\ et aucune convergence (l'ajustement de la
dernière période couverte par un étalon est répété indéfiniment) lorsque
\\\rho = 1\\ (étalonnage de Denton). En fait, les arguments `biasOption`
et `bias` ne sont pas utilisés lorsque \\\rho = 1\\ puisque la
correction du biais n'a pas d'impact sur les résultats de l'étalonnage
de Denton. La valeur suggérée pour \\\rho\\ est \\0.9\\ pour les
indicateurs mensuels et \\0.9^3 = 0.729\\ pour les indicateurs
trimestriels, ce qui représente un compromis raisonnable entre maximiser
la préservation du mouvement et réduire les révisions à mesure que de
nouveaux étalons deviendront disponibles à l'avenir (*problème
d'actualité* de l'étalonnage). En pratique, il convient de noter que
l'étalonnage de Denton pourrait être *approximé* avec le modèle basé sur
la régression en utilisant une valeur de \\\rho\\ inférieure à, mais
très proche de \\1.0\\ (par exemple, \\\rho = 0.999\\). Voir Dagum et
Cholette (2006) pour une discussion complète sur ce sujet.

### Coefficients d'altérabilité

Les coefficients d'altérabilité \\c\_{s^\dagger}\\ et \\c_a\\
représentent conceptuellement les erreurs de mesure associées aux
valeurs de la série indicatrice (corrigée pour le biais) \\s^\dagger\\
et des étalons \\a\\ respectivement. Il s'agit de nombres réels non
négatifs qui, en pratique, spécifient l'ampleur de la modification
permise d'une valeur initiale par rapport aux autres valeurs. Un
coefficient d'altérabilité de \\0.0\\ définit une valeur fixe
(contraignante), tandis qu'un coefficient d'altérabilité supérieur à
\\0.0\\ définit une valeur libre (non contraignante). L'augmentation du
coefficient d'altérabilité d'une valeur initiale entraîne davantage de
changements pour cette valeur dans la solution d'étalonnage et,
inversement, moins de changements lorsque l'on diminue le coefficient
d'altérabilité. Les coefficients d'altérabilité par défaut sont \\0.0\\
pour les étalons (contraignants) et \\1.0\\ pour les valeurs de la série
indicatrice (non contraignantes). Remarques importantes :

- Avec une valeur de \\\rho = 1\\ (argument `rho = 1`, associé à
  l'étalonnage de Denton), seuls les coefficients d'altérabilité par
  défaut (\\0.0\\ pour un étalon et \\1.0\\ pour une valeur de série
  indicatrice) sont valides. La spécification de variables de
  coefficients d'altérabilité définies par l'utilisateur n'est donc pas
  autorisée. Si de telles variables sont spécifiées (voir les arguments
  `var` et `with`), la fonction les ignore et affiche un message
  d'avertissement dans la console.

- Les coefficients d'altérabilité \\c\_{s^\dagger}\\ entrent en jeu
  après que la série indicatrice ait été corrigée pour le biais,
  lorsqu'applicable (\\c\_{s^\dagger}\\ est associé à \\s^\dagger\\ et
  non à \\s\\). Cela signifie que la spécification d'un coefficient
  d'altérabilité de \\0.0\\ pour une valeur de série indicatrice donnée
  **ne se traduira pas** par une valeur inchangée après étalonnage
  **avec correction du biais** (voir les arguments `biasOption` et
  `bias`).

Les étalons non contraignants, le cas échéant, peuvent être récupérés
(calculés) à partir de la série étalonnée (voir le *data frame* de
sortie `series` dans la section **Valeur de retour**). Le *data frame*
de sortie `benchmarks` contient toujours les étalons fournis dans le
*data frame* d'entrée des étalons (argument `benchmarks_df`).

### Étalonnage de plusieurs séries

Plusieurs séries peuvent être étalonnées en un seul appel à
`benchmarking()`, en spécifiant `allCols = TRUE`, en spécifiant
(manuellement) plusieurs variables avec l'argument `var` (et l'argument
`with`) ou avec le traitement groupes-BY (argument `by != NULL`). Une
distinction importante est que toutes les séries indicatrices spécifiées
avec `allCols = TRUE` ou avec l'argument `var` (et les étalons avec
l'argument `with`) doivent avoir la même longueur, c'est-à-dire le même
ensemble de périodes et et le même ensemble (nombre) d'étalons.
L'étalonnage de séries de longueurs différentes (différents ensembles de
périodes) ou avec différents ensembles (nombres) d'étalons doit être
effectué avec un traitement groupes-BY sur des données empilées pour les
*data frames* d'entrée de séries indicatrices et d'étalons (voir les
fonctions utilitaires
[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_tsDF.md)
et
[`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_bmkDF.md)).
Les arguments `by` et `var` peuvent être combinés afin d'implémenter le
traitement groupes-BY pour des séries multiples comme illustré par
l'*Exemple 2* dans la section **Exemples**. Alors que l'utilisation de
variables multiples avec 'argument `var` (ou `allCols = TRUE`) sans
traitement groupes-BY (argument `by = NULL`) est légèrement plus
efficace (plus rapide), une approche groupes-BY avec une seule variable
de série est généralement recommandée car elle est plus générale
(fonctionne dans tous les contextes). Cette dernière est illustrée par
l'*Exemple 3* dans la section **Exemples**. Les variables BY spécifiées
avec l'argument `by` apparaissent dans les trois *data frames* de
sortie.

### Arguments `constant` et `negInput_option`

Ces arguments permettent d'étendre l'utilisation de l'étalonnage
proportionnel à un plus grand nombre de problèmes. Leurs valeurs par
défaut correspondent au comportement de G-Séries 2.0 (SAS\\^\circledR\\
PROC BENCHMARKING) pour lequel des options équivalentes ne sont pas
définies. Bien que l'étalonnage proportionnel ne soit pas nécessairement
l'approche la plus appropriée (l'étalonnage additif pourrait être plus
indiqué) lorsque les valeurs de la série indicatrice approchent de 0
(ratios d'une période à l'autre instables) ou « traversent la ligne de
0 » et peuvent donc passer de positives à négatives et vice-versa
(ratios d'une période à l'autre difficiles à interpréter), ces cas ne
sont pas invalides d'un point de vue mathématique (le problème
d'étalonnage proportionnel associé peut être résolu). Il est toutefois
fortement recommandé d'analyser et de valider soigneusement les données
étalonnées obtenues dans ces situations pour s'assurer qu'elles
correspondent à des solutions raisonnables et interprétables.

### Traitement des valeurs manquantes (`NA`)

- Si une valeur manquante apparaît dans l'une des variables du *data
  frame* d'entrée des étalons (autre que les variables BY), les
  enregistrements avec les valeurs manquantes sont laissés de côté, un
  message d'avertissement est affiché et la fonction s'exécute.

- Si une valeur manquante apparaît dans les variables `year` ou `period`
  du *data frame* d'entrée des séries indicatrices et que des variables
  BY sont spécifiées, le groupe-BY correspondant est ignoré, un message
  d'avertissement s'affiche et la fonction passe au groupe-BY suivant.
  Si aucune variable BY n'est spécifiée, un message d'avertissement
  s'affiche et aucun traitement n'est effectué.

- Si une valeur manquante apparaît dans l'une des variables des données
  de série du *data frame* d'entrée des séries indicatrices et que des
  variables BY sont spécifiées, le groupe-BY correspondant est ignoré,
  un message d'avertissement est affiché et la fonction passe au
  groupe-BY suivant. Si aucune variable BY n'est spécifiée, la série
  indicatrice concernée n'est pas traitée, un message d'avertissement
  est affiché et la fonction passe à la série indicatrice suivante (le
  cas échéant).

## Références

Dagum, E. B. et P. Cholette (2006). **Benchmarking, Temporal
Distribution and Reconciliation Methods of Time Series**.
Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
[doi:10.1007/0-387-35439-5](https://doi.org/10.1007/0-387-35439-5)

Fortier, S. et B. Quenneville (2007). « Theory and Application of
Benchmarking in Business Surveys ». **Proceedings of the Third
International Conference on Establishment Surveys (ICES-III)**.
Montréal, juin 2007.

Latendresse, E., M. Djona et S. Fortier (2007). « Benchmarking
Sub-Annual Series to Annual Totals – From Concepts to SAS\\^\circledR\\
Procedure and Enterprise Guide\\^\circledR\\ Custom Task ».
**Proceedings of the SAS\\^\circledR\\ Global Forum 2007 Conference**.
Cary, NC: SAS Institute Inc.

Quenneville, B., S. Fortier, Z.-G. Chen et E. Latendresse (2006).
« Recent Developments in Benchmarking to Annual Totals in X-12-ARIMA and
at Statistics Canada ». **Proceedings of the Eurostat Conference on
Seasonality, Seasonal Adjustment and Their Implications for Short-Term
Analysis and Forecasting**. Luxembourg, mai 2006.

Quenneville, B., P. Cholette, S. Fortier et J. Bérubé (2010).
« Benchmarking Sub-Annual Indicator Series to Annual Control Totals
(Forillon v1.04.001) ». **Document interne**. Statistique Canada,
Ottawa, Canada.

Quenneville, B. et S. Fortier (2012). « Restoring Accounting Constraints
in Time Series – Methods and Software for a Statistical Agency ».
**Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New
York.

Statistique Canada (2012). **Théorie et application de l’étalonnage
(Code du cours 0436)**. Statistique Canada, Ottawa, Canada.

Statistique Canada (2016). « La procédure BENCHMARKING ». **Guide de
l'utilisateur de G-Séries 2.0**. Statistique Canada, Ottawa, Canada.

## Voir également

[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
[`plot_graphTable()`](https://StatCan.github.io/gensol-gseries/fr/reference/plot_graphTable.md)
[bench_graphs](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
[`plot_benchAdj()`](https://StatCan.github.io/gensol-gseries/fr/reference/plot_benchAdj.md)
[`gs.gInv_MP()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.gInv_MP.md)
[aliases](https://StatCan.github.io/gensol-gseries/fr/reference/aliases.md)

## Exemples

``` r
# Définir le répertoire de travail (pour les fichiers graphiques PDF)
rep_ini <- setwd(tempdir())


###########
# Exemple 1 : Cas simple d'étalonnage d'une série trimestrielle à des valeurs annuelles

# Série indicatrice trimestrielle
mes_ind1 <- ts_to_tsDF(
  ts(
    c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
    start = c(2015, 1),
    frequency = 4
  )
)
mes_ind1
#>   year period value
#> 1 2015      1   1.9
#> 2 2015      2   2.4
#> 3 2015      3   3.1
#> 4 2015      4   2.2
#> 5 2016      1   2.0
#> 6 2016      2   2.6
#> 7 2016      3   3.4
#> 8 2016      4   2.4
#> 9 2017      1   2.3

# Étalons annuels pour données trimestrielles
mes_eta1 <- ts_to_bmkDF(
  ts(
    c(10.3, 10.2),
    start = 2015,
    frequency = 1
  ),
  ind_frequency = 4
)
mes_eta1
#>   startYear startPeriod endYear endPeriod value
#> 1      2015           1    2015         4  10.3
#> 2      2016           1    2016         4  10.2

# Étalonnage avec...
#   - valeur de `rho` recommandée pour des séries trimestrielles (`rho = 0.729`)
#   - modèle proportionnel (`lambda = 1`)
#   - correction de la série indicatrice pour le biais avec estimation du biais 
#     (`biasOption = 3`)
res_eta1 <- benchmarking(
  mes_ind1,
  mes_eta1,
  rho = 0.729,
  lambda = 1,
  biasOption = 3
)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> benchmarking() function:
#>     series_df          = mes_ind1
#>     benchmarks_df      = mes_eta1
#>     rho                = 0.729
#>     lambda             = 1
#>     biasOption         = 3 (Calculate bias, use calculated bias)
#>     bias               (ignored)
#>     tolV               = 0.001 (default)
#>     warnNegResult      = TRUE (default)
#>     tolN               = -0.001 (default)
#>     var                = value (default)
#>     with               = NULL (default)
#>     by                 = NULL (default)
#>     verbose            = FALSE (default)
#>     (*)constant        = 0 (default)
#>     (*)negInput_option = 0 (default)
#>     (*)allCols         = FALSE (default)
#>     (*)quiet           = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> Number of observations in the BENCHMARKS data frame .............: 2
#> Number of valid observations in the BENCHMARKS data frame .......: 2
#> Number of observations in the SERIES data frame .................: 9
#> Number of valid observations in the SERIES data frame ...........: 9
#> BIAS = 1.025 (calculated)

# Générerer les graphiques d'étalonnage
plot_graphTable(res_eta1$graphTable, "Graphs_ex1.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 1 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\RtmpAn0YpJ\Graphs_ex1.pdf


###########
# Exemple 2 : Étalonnage de deux séries trimestrielles à des valeurs annuelles,
#             avec groupes-BY et coef. d'altérabilité définis par l'utilisateur.

# Données sur les ventes (mêmes ventes pour les groupes A et B; seuls les coef. 
# d'alté. pour les ventes de camionnettes diffèrent)
ventes_tri <- ts(
  matrix(
    c(
      # Voitures
      1851, 2436, 3115, 2205, 1987, 2635, 3435, 2361, 2183, 2822,
      3664, 2550, 2342, 3001, 3779, 2538, 2363, 3090, 3807, 2631,
      2601, 3063, 3961, 2774, 2476, 3083, 3864, 2773, 2489, 3082,
      # Camionnettes
      1900, 2200, 3000, 2000, 1900, 2500, 3800, 2500, 2100, 3100,
      3650, 2950, 3300, 4000, 3290, 2600, 2010, 3600, 3500, 2100,
      2050, 3500, 4290, 2800, 2770, 3080, 3100, 2800, 3100, 2860),
    ncol = 2
  ),
  start = c(2011, 1),
  frequency = 4,
  names = c("voitures", "camionnettes")
)

ventes_ann <- ts(
  matrix(
    c(
      # Voitures
      10324, 10200, 10582, 11097, 11582, 11092,
      # Camionnettes
      12000, 10400, 11550, 11400, 14500, 16000),
    ncol = 2
  ),
  start = 2011,
  frequency = 1,
  names = c("voitures", "camionnettes")
)

# Séries indicatrices trimestrielles (avec les coef. d'alté. par défaut pour l'instant)
mes_ind2 <- rbind(
  cbind(
    data.frame(
      groupe = rep("A", nrow(ventes_tri)),
      alt_cam = rep(1, nrow(ventes_tri))
    ),
    ts_to_tsDF(ventes_tri)
  ),
  cbind(
    data.frame(
      groupe = rep("B", nrow(ventes_tri)),
      alt_cam = rep(1, nrow(ventes_tri))
    ),
    ts_to_tsDF(ventes_tri)
  )
)

# Ventes contraignantes de camionnettes (coef. d'alté. = 0) pour 2012 T1 et T2 
# dans le groupe A (lignes 5 et 6)
mes_ind2$alt_cam[c(5,6)] <- 0
head(mes_ind2, n = 10)
#>    groupe alt_cam year period voitures camionnettes
#> 1       A       1 2011      1     1851         1900
#> 2       A       1 2011      2     2436         2200
#> 3       A       1 2011      3     3115         3000
#> 4       A       1 2011      4     2205         2000
#> 5       A       0 2012      1     1987         1900
#> 6       A       0 2012      2     2635         2500
#> 7       A       1 2012      3     3435         3800
#> 8       A       1 2012      4     2361         2500
#> 9       A       1 2013      1     2183         2100
#> 10      A       1 2013      2     2822         3100
tail(mes_ind2)
#>    groupe alt_cam year period voitures camionnettes
#> 55      B       1 2017      1     2476         2770
#> 56      B       1 2017      2     3083         3080
#> 57      B       1 2017      3     3864         3100
#> 58      B       1 2017      4     2773         2800
#> 59      B       1 2018      1     2489         3100
#> 60      B       1 2018      2     3082         2860

# Étalons annuels pour données trimestrielles (sans coef. d'alté.)
mes_eta2 <- rbind(
  cbind(
    data.frame(groupe = rep("A", nrow(ventes_ann))),
    ts_to_bmkDF(ventes_ann, ind_frequency = 4)
  ),
  cbind(
    data.frame(groupe = rep("B", nrow(ventes_ann))),
    ts_to_bmkDF(ventes_ann, ind_frequency = 4)
  )
)
mes_eta2
#>    groupe startYear startPeriod endYear endPeriod voitures camionnettes
#> 1       A      2011           1    2011         4    10324        12000
#> 2       A      2012           1    2012         4    10200        10400
#> 3       A      2013           1    2013         4    10582        11550
#> 4       A      2014           1    2014         4    11097        11400
#> 5       A      2015           1    2015         4    11582        14500
#> 6       A      2016           1    2016         4    11092        16000
#> 7       B      2011           1    2011         4    10324        12000
#> 8       B      2012           1    2012         4    10200        10400
#> 9       B      2013           1    2013         4    10582        11550
#> 10      B      2014           1    2014         4    11097        11400
#> 11      B      2015           1    2015         4    11582        14500
#> 12      B      2016           1    2016         4    11092        16000

# Étalonnage avec...
#   - valeur de `rho` recommandée pour des séries trimestrielles (`rho = 0.729`)
#   - modèle proportionnel (`lambda = 1`)
#   - sans correction du biais (`biasOption = 1` et `bias` non spécifié)
#   - `quiet = TRUE` afin d'éviter l'affichage de l'en-tête de la fonction
res_eta2 <- benchmarking(
  mes_ind2,
  mes_eta2,
  rho = 0.729,
  lambda = 1,
  biasOption = 1,
  var = c("voitures", "camionnettes / alt_cam"),
  with = c("voitures", "camionnettes"),
  by = "groupe",
  quiet = TRUE
)
#> 
#> Benchmarking by-group 1 (groupe=A)
#> ==================================
#> 
#> Benchmarking indicator series [voitures] with benchmarks [voitures]
#> -------------------------------------------------------------------
#> 
#> Benchmarking indicator series [camionnettes] with benchmarks [camionnettes]
#> ---------------------------------------------------------------------------
#> 
#> Benchmarking by-group 2 (groupe=B)
#> ==================================
#> 
#> Benchmarking indicator series [voitures] with benchmarks [voitures]
#> -------------------------------------------------------------------
#> 
#> Benchmarking indicator series [camionnettes] with benchmarks [camionnettes]
#> ---------------------------------------------------------------------------

# Générerer les graphiques d'étalonnage
plot_graphTable(res_eta2$graphTable, "Graphs_ex2.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 4 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\RtmpAn0YpJ\Graphs_ex2.pdf

# Vérifier la valeur des ventes de camionnettes pour 2012 T1 et T2 
# dans le groupe A (valeurs fixes)
all.equal(mes_ind2$camionnettes[c(5,6)], res_eta2$series$camionnettes[c(5,6)])
#> [1] TRUE


###########
# Exemple 3 : identique à l'exemple 2, mais en étalonnant les 4 séries 
#             en tant que groupes-BY (4 groupes-BY au lieu de 2)

ventes_tri2 <- ts.union(A = ventes_tri, B = ventes_tri)
mes_ind3 <- stack_tsDF(ts_to_tsDF(ventes_tri2))
mes_ind3$alter <- 1
mes_ind3$alter[
  mes_ind3$series == "A.camionnettes" & 
    mes_ind3$year == 2012 & 
    mes_ind3$period <= 2
] <- 0
head(mes_ind3)
#>       series year period value alter
#> 1 A.voitures 2011      1  1851     1
#> 2 A.voitures 2011      2  2436     1
#> 3 A.voitures 2011      3  3115     1
#> 4 A.voitures 2011      4  2205     1
#> 5 A.voitures 2012      1  1987     1
#> 6 A.voitures 2012      2  2635     1
tail(mes_ind3)
#>             series year period value alter
#> 115 B.camionnettes 2017      1  2770     1
#> 116 B.camionnettes 2017      2  3080     1
#> 117 B.camionnettes 2017      3  3100     1
#> 118 B.camionnettes 2017      4  2800     1
#> 119 B.camionnettes 2018      1  3100     1
#> 120 B.camionnettes 2018      2  2860     1

ventes_ann2 <- ts.union(A = ventes_ann, B = ventes_ann)
mes_eta3 <- stack_bmkDF(ts_to_bmkDF(ventes_ann2, ind_frequency = 4))
head(mes_eta3)
#>       series startYear startPeriod endYear endPeriod value
#> 1 A.voitures      2011           1    2011         4 10324
#> 2 A.voitures      2012           1    2012         4 10200
#> 3 A.voitures      2013           1    2013         4 10582
#> 4 A.voitures      2014           1    2014         4 11097
#> 5 A.voitures      2015           1    2015         4 11582
#> 6 A.voitures      2016           1    2016         4 11092
tail(mes_eta3)
#>            series startYear startPeriod endYear endPeriod value
#> 19 B.camionnettes      2011           1    2011         4 12000
#> 20 B.camionnettes      2012           1    2012         4 10400
#> 21 B.camionnettes      2013           1    2013         4 11550
#> 22 B.camionnettes      2014           1    2014         4 11400
#> 23 B.camionnettes      2015           1    2015         4 14500
#> 24 B.camionnettes      2016           1    2016         4 16000

res_eta3 <- benchmarking(
  mes_ind3,
  mes_eta3,
  rho = 0.729,
  lambda = 1,
  biasOption = 1,
  var = "value / alter",
  with = "value",
  by = "series",
  quiet = TRUE
)
#> 
#> Benchmarking by-group 1 (series=A.voitures)
#> ===========================================
#> 
#> Benchmarking by-group 2 (series=A.camionnettes)
#> ===============================================
#> 
#> Benchmarking by-group 3 (series=B.voitures)
#> ===========================================
#> 
#> Benchmarking by-group 4 (series=B.camionnettes)
#> ===============================================

# Générerer les graphiques d'étalonnage
plot_graphTable(res_eta3$graphTable, "Graphs_ex3.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 4 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\RtmpAn0YpJ\Graphs_ex3.pdf

# Convertir le « data frame » `res_eta3$series` en un objet « mts »
ventes_tri2_eta <- tsDF_to_ts(unstack_tsDF(res_eta3$series), frequency = 4)

# Afficher les 10 premières observations
ts(ventes_tri2_eta[1:10, ], start = start(ventes_tri2), deltat = deltat(ventes_tri2))
#>         A.voitures A.camionnettes B.voitures B.camionnettes
#> 2011 Q1   1987.762       2470.301   1987.762       2497.155
#> 2011 Q2   2641.222       2956.559   2641.222       2980.984
#> 2011 Q3   3366.003       4031.113   3366.003       4029.901
#> 2011 Q4   2329.013       2542.026   2329.013       2491.960
#> 2012 Q1   2021.161       1900.000   2021.161       2077.268
#> 2012 Q2   2602.064       2500.000   2602.064       2466.739
#> 2012 Q3   3320.486       3636.551   3320.486       3522.652
#> 2012 Q4   2256.289       2363.449   2256.289       2333.342
#> 2013 Q1   2072.168       2071.868   2072.168       2060.533
#> 2013 Q2   2663.309       3112.774   2663.309       3110.631

# Vérifier la valeur des ventes de camionnettes pour 2012 T1 et T2 
# dans le groupe A (valeurs fixes)
all.equal(
  window(ventes_tri2[, "A.camionnettes"], start = c(2012, 1), end = c(2012, 2)),
  window(ventes_tri2_eta[, "A.camionnettes"], start = c(2012, 1), end = c(2012, 2))
)
#> [1] TRUE


# Réinitialiser le répertoire de travail à son emplacement initial
setwd(rep_ini)
```
