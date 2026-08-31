# Rétablir les contraintes d'agrégation transversales (contemporaines)

*Réplication de la procédure TSRAKING de G-Séries 2.0 en
SAS\\^\circledR\\ (PROC TSRAKING). Voir la documentation de G-Séries 2.0
pour plus de détails (Statistique Canada 2016).*

Cette fonction rétablit les contraintes d'agrégation transversales dans
un système de séries chronologiques. Les contraintes d'agrégation
peuvent provenir d'une table à 1 ou 2 dimensions. Optionnellement, des
contraintes temporelles peuvent également être préservées.

En pratique, `tsraking()` est généralement appelée à travers
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
afin de réconcilier toutes les périodes du système de séries
chronologiques en un seul appel de fonction.

## Utilisation

``` r
tsraking(
  data_df,
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

  # Nouveau dans G-Séries 3.0
  Vmat_option = 1,
  warnNegInput = TRUE,
  quiet = FALSE
)
```

## Arguments

- data_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») qui contient les
  données des séries chronologiques à réconcilier. Il doit au minimum
  contenir des variables correspondant aux séries composantes et aux
  totaux de contrôle transversaux spécifiés dans le *data frame* des
  métadonnées de ratissage (argument `metadata_df`). Si plus d'un
  enregistrement (plus d'une période) est fournie, la somme des valeurs
  des séries composantes fournies sera également préservée à travers des
  contraintes temporelles implicites.

- metadata_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») qui décrit les
  contraintes d'agrégation transversales (règles d'additivité) pour le
  problème de ratissage (« *raking* »). Deux variables de type caractère
  doivent être incluses dans le *data frame* : `series` et `total1`.
  Deux variables sont optionnelles : `total2` (caractère) et
  `alterAnnual` (numérique). Les valeurs de la variable `series`
  représentent les noms des variables des séries composantes dans le
  *data frame* des données d'entrée (argument `data_df`). De même, les
  valeurs des variables `total1` et `total2` représentent les noms des
  variables des totaux de contrôle transversaux de 1^(ère) et 2^(ème)
  dimension dans le *data frame* des données d'entrée. La variable
  `alterAnnual` contient le coefficient d'altérabilité pour la
  contrainte temporelle associée à chaque série composante. Lorsqu'elle
  est spécifiée, cette dernière remplace le coefficient d'altérabilité
  par défaut spécifié avec l'argument `alterAnnual`.

- alterability_df:

  (optionnel)

  *Data frame* (object de classe « data.frame »), ou `NULL`, qui
  contient les variables de coefficients d'altérabilité. Elles doivent
  correspondre à une série composante ou à un total de contrôle
  transversal, c'est-à-dire qu'une variable portant le même nom doit
  exister dans le *data frame* des données d'entrée (argument
  `data_df`). Les valeurs de ces coefficients d'altérabilité
  remplaceront les coefficients d'altérabilité par défaut spécifiés avec
  les arguments `alterSeries`, `alterTotal1` et `alterTotal2`. Lorsque
  le *data frame* des données d'entrée contient plusieurs
  enregistrements et que le *data frame* des coefficients d'altérabilité
  n'en contient qu'un seul, les coefficients d'altérabilité sont
  utilisés (répétés) pour tous les enregistrements du *data frame* des
  données d'entrée. Le *data frame* des coefficients d'altérabilité peut
  également contenir autant d'enregistrements que le *data frame* des
  données d'entrée.

  **La valeur par défaut** est `alterability_df = NULL` (coefficients
  d'altérabilité par défaut).

- alterSeries:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut pour les valeurs des séries composantes. Il s'appliquera aux
  séries composantes pour lesquelles des coefficients d'altérabilité
  n'ont pas déjà été spécifiés dans le *data frame* des coefficients
  d'altérabilité (argument `alterability_df`).

  **La valeur par défaut** est `alterSeries = 1.0` (valeurs des séries
  composantes non contraignantes).

- alterTotal1:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut pour les totaux de contrôle transversaux de la 1^(ère)
  dimension. Il s'appliquera aux totaux de contrôle transversaux pour
  lesquels des coefficients d'altérabilité n'ont pas déjà été spécifiés
  dans le *data frame* des coefficients d'altérabilité (argument
  `alterability_df`).

  **La valeur par défaut** est `alterTotal1 = 0.0` (totaux de contrôle
  transversaux de 1^(ère) dimension contraignants).

- alterTotal2:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut pour les totaux de contrôle transversaux de la 2^(ème)
  dimension. Il s'appliquera aux totaux de contrôle transversaux pour
  lesquels des coefficients d'altérabilité n'ont pas déjà été spécifiés
  dans le *data frame* des coefficients d'altérabilité (argument
  `alterability_df`).

  **La valeur par défaut** est `alterTotal2 = 0.0` (totaux de contrôle
  transversaux de 2^(ème) dimension contraignants).

- alterAnnual:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut pour les contraintes temporelles (ex., totaux annuels) des
  séries composantes. Il s'appliquera aux séries composantes pour
  lesquelles des coefficients d'altérabilité n'ont pas déjà été
  spécifiés dans le *data frame* des métadonnées de ratissage (argument
  `metadata_df`).

  **La valeur par défaut** est `alterAnnual = 0.0` (totaux de contrôle
  temporels contraignants).

- tolV, tolP:

  (optionnel)

  Nombre réel non négatif, ou `NA`, spécifiant la tolérance, en valeur
  absolue ou en pourcentage, à utiliser lors du test ultime pour les
  totaux de contrôle contraignants (coefficient d'altérabilité de
  \\0.0\\ pour les totaux de contrôle temporels ou transversaux). Le
  test compare les totaux de contrôle contraignants d'entrée avec ceux
  calculés à partir des séries composantes réconciliées (en sortie). Les
  arguments `tolV` et `tolP` ne peuvent pas être spécifiés tous les deux
  à la fois (l'un doit être spécifié tandis que l'autre doit être `NA`).

  **Exemple :** pour une tolérance de 10 *unités*, spécifiez
  `tolV = 10, tolP = NA`; pour une tolérance de 1%, spécifiez
  `tolV = NA, tolP = 0.01`.

  **Les valeurs par défaut** sont `tolV = 0.001` et `tolP = NA`.

- warnNegResult:

  (optionnel)

  Argument logique (*logical*) spécifiant si un message d'avertissement
  doit être affiché lorsqu'une valeur négative créée par la fonction
  dans une série réconciliée (en sortie) est inférieure au seuil
  spécifié avec l'argument `tolN`.

  **La valeur par défaut** est `warnNegResult = TRUE`.

- tolN:

  (optionnel)

  Nombre réel négatif spécifiant le seuil pour l'identification des
  valeurs négatives. Une valeur est considérée négative lorsqu'elle est
  inférieure à ce seuil.

  **La valeur par défaut** est `tolN = -0.001`.

- id:

  (optionnel)

  Vecteur de chaînes de caractère (longueur minimale de 1), ou `NULL`,
  spécifiant le nom des variables additionnelles à transférer du *data
  frame* d'entrée (argument `data_df`) au *data frame* de sortie,
  c.-à-d., l'objet renvoyé par la fonction (voir la section **Valeur de
  retour**). Par défaut, le *data frame* de sortie ne contient que les
  variables énumérées dans le *data frame* des métadonnées de ratissage
  (argument `metadata_df`).

  **La valeur par défaut** est `id = NULL`.

- verbose:

  (optionnel)

  Argument logique (*logical*) spécifiant si les informations sur les
  étapes intermédiaires avec le temps d'exécution (temps réel et non le
  temps CPU) doivent être affichées. Notez que spécifier l'argument
  `quiet = TRUE` annulerait l'argument `verbose`.

  **La valeur par défaut** est `verbose = FALSE`.

- Vmat_option:

  (optionnel)

  Spécification de l'option pour les matrices de variance (\\V_e\\ et
  \\V\_\epsilon\\; voir la section **Détails**) :

  |  |  |
  |----|----|
  | **Valeur** | **Description** |
  | `1` | Utiliser les vecteurs \\x\\ et \\g\\ dans les matrices de variance. |
  | `2` | Utiliser les vecteurs \\\|x\|\\ et \\\|g\|\\ dans les matrices de variance. |

  Voir Ferland (2016) et la sous-section **Arguments `Vmat_option` et
  `warnNegInput`** dans la section **Détails** pour plus d'informations.

  **La valeur par défaut** est `Vmat_option = 1`.

- warnNegInput:

  (optionnel)

  Argument logique (*logical*) spécifiant si un message d'avertissement
  doit être affiché lorsqu'une valeur négative plus petite que le seuil
  spécifié par l'argument `tolN` est trouvée dans le *data frame* des
  données d'entrée (argument `data_df`).

  **La valeur par défaut** est `warnNegInput = TRUE`.

- quiet:

  (optionnel)

  Argument logique (*logical*) spécifiant s'il faut ou non afficher
  uniquement les informations essentielles telles que les messages
  d'avertissements et d'erreurs. Spécifier `quiet = TRUE` annulera
  également l'argument `verbose` et est équivalent à *envelopper* votre
  appel à `tsraking()` avec
  [`suppressMessages()`](https://rdrr.io/r/base/message.html).

  **La valeur par défaut** est `quiet = FALSE`.

## Valeur de retour

La fonction renvoie un *data frame* contenant les séries composantes
réconciliées, les totaux de contrôle transversaux réconciliés et les
variables spécifiées avec l'argument `id`. Notez que l'objet
« data.frame » peut être explicitement converti en un autre type d'objet
avec la fonction `as*()` appropriée (ex.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
le convertirait en tibble).

## Détails

Cette fonction renvoie la solution des moindres carrés généralisés d'une
variante spécifique, simple du modèle général de ratissage (*raking*)
basé sur la régression proposé par Dagum et Cholette (Dagum et Cholette
2006). Le modèle, sous forme matricielle, est le suivant :
\$\$\displaystyle \begin{bmatrix} x \\ g \end{bmatrix} = \begin{bmatrix}
I \\ G \end{bmatrix} \theta + \begin{bmatrix} e \\ \varepsilon
\end{bmatrix} \$\$ où

- \\x\\ est le vecteur des valeurs initiales des séries composantes.

- \\\theta\\ est le vecteur des valeurs finales (réconciliées) des
  séries composantes.

- \\e \sim \left( 0, V_e \right)\\ est le vecteur des erreurs de mesure
  de \\x\\ avec la matrice de covariance \\V_e = \mathrm{diag} \left(
  c_x x \right)\\, ou \\V_e = \mathrm{diag} \left( \left\| c_x x
  \right\| \right)\\ quand l'argument `Vmat_option = 2`, où \\c_x\\ est
  le vecteur des coefficients d'alterabilité de \\x\\.

- \\g\\ est le vecteur des totaux de contrôle initiaux, incluant les
  totaux temporels des séries composantes (le cas échéant).

- \\\varepsilon \sim (0, V\_\varepsilon)\\ est le vecteur des erreurs de
  mesure de \\g\\ avec la matrice de covariance \\V\_\varepsilon =
  \mathrm{diag} \left( c_g g \right)\\, ou \\V\_\varepsilon =
  \mathrm{diag} \left( \left\| c_g g \right\| \right)\\ quand l'argument
  `Vmat_option = 2`, où \\c_g\\ est le vecteur des coefficients
  d'alterabilité de \\g\\.

- \\G\\ est la matrice des contraintes d'agrégation, y compris les
  contraintes temporelles implicites (le cas échéant).

La solution généralisée des moindres carrés est : \$\$\displaystyle
\hat{\theta} = x + V_e G^{\mathrm{T}} \left( G V_e G^{\mathrm{T}} +
V\_\varepsilon \right)^+ \left( g - G x \right) \$\$ où \\A^{+}\\
désigne l'inverse de Moore-Penrose de la matrice \\A\\.

`tsraking()` résout un seul problème de ratissage à la fois,
c'est-à-dire, soit une seule période du système de séries
chronologiques, ou un seul groupe temporel (ex., toutes les périodes
d'une année donnée) lorsque la préservation des totaux temporels est
requise. Plusieurs appels à `tsraking()` sont donc nécessaires pour
réconcilier toutes les périodes du système de séries chronologiques.
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
peut réaliser cela en un seul appel : il détermine commodément
l'ensemble des problèmes à résoudre et génère à l'interne les appels
individuels à `tsraking()`.

### Coefficients d'altérabilité

Les coefficients d'altérabilité \\c_x\\ et \\c_g\\ représentent
conceptuellement les erreurs de mesure associées aux valeurs d'entrée
des séries composantes \\x\\ et des totaux de contrôle \\g\\
respectivement. Il s'agit de nombres réels non négatifs qui, en
pratique, spécifient l'ampleur de la modification permise d'une valeur
initiale par rapport aux autres valeurs. Un coefficients d'altérabilité
de \\0.0\\ définit une valeur fixe (contraignante), tandis qu'un
coefficient d'altérabilité supérieur à \\0.0\\ définit une valeur libre
(non contraignante). L'augmentation du coefficient d'altérabilité d'une
valeur initiale entraîne davantage de changements pour cette valeur dans
les données réconciliées (en sortie) et, inversement, moins de
changements lorsque l'on diminue le coefficient d'altérabilité. Les
coefficients d'altérabilité par défaut sont \\1.0\\ pour les valeurs des
séries composantes et \\0.0\\ pour les totaux de contrôle transversaux
et, le cas échéant, les totaux temporels des séries composantes. Ces
coefficients d'altérabilité par défaut entraînent une répartition
proportionnelle des écarts entre les séries composantes. En fixant les
coefficients d'altérabilité des séries composantes à l'inverse des
valeurs initiales des séries composantes, on obtiendrait une répartition
uniforme des écarts à la place. Des totaux *presque contraignants*
peuvent être obtenus en pratique en spécifiant des coefficients
d'altérabilité très petits (presque \\0.0\\) par rapport à ceux des
séries composantes (non contraignantes).

**La préservation des totaux temporels** fait référence au fait que les
totaux temporels, le cas échéant, sont généralement conservés « aussi
près que possible » de leur valeur initiale. Une *préservation pure* est
obtenue par défaut avec des totaux temporels contraignants, tandis que
le changement est minimisé avec des totaux temporels non contraignants
(conformément à l'ensemble de coefficients d'altérabilité utilisés).

### Arguments `Vmat_option` et `warnNegInput`

Ces arguments permettent une gestion alternative des valeurs négatives
dans les données d'entrée, similaire à celle de
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md).
Leurs valeurs par défaut correspondent au comportement de G-Séries 2.0
(PROC TSRAKING en SAS\\^\circledR\\) pour lequel des options
équivalentes ne sont pas définies. Ce dernier a été développé en
présumant des « données d'entrée non négatives uniquement », à l'instar
de PROC BENCHMARKING dans G-Séries 2.0 en SAS\\^\circledR\\ qui
n'autorisait pas non plus les valeurs négatives avec l'étalonnage
proportionnel, ce qui explique l'avertissement « suspicious use of
proportional raking » (*utilisation suspecte du ratissage
proportionnel*) en présence de valeurs négatives avec PROC TSRAKING dans
G-Series 2.0 et lorsque `warnNegInput = TRUE` (par défault). Cependant,
le ratissage (proportionnel) en présence de valeurs négatives fonctionne
généralement bien avec `Vmat_option = 2` et produit des solutions
raisonnables et intuitives. Par exemple, alors que l'option par défaut
`Vmat_option = 1` échoue à résoudre la contrainte `A + B = C` avec les
données d'entrée `A = 2`, `B = -2`, `C = 1` et les coefficients
d'altérabilité par défaut, `Vmat_option = 2` renvoie la solution
(intuitive) `A = 2.5`, `B = -1.5`, `C = 1` (augmentation de 25% pour `A`
et `B`). Voir Ferland (2016) pour plus de détails.

### Traitement des valeurs manquantes (`NA`)

Une valeur manquante dans le *data frame* des données d'entrée (argument
`data_df`) ou dans le *data frame* des coefficients d'altérabilité
(argument `alterability_df`) pour n'importe quelle donnée du problème de
ratissage (variables énumérées dans le *data frame* des métadonnées avec
l'argument `metadata_df`) générera un message d'erreur et arrêtera
l'exécution de la fonction.

## Comparaison de `tsraking()` et [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)

- `tsraking()` est limitée aux problèmes de ratissage (« *raking* ») de
  tables d'agrégation unidimensionnelles et bidimensionnelles (avec
  préservation des totaux temporels si nécessaire) alors que
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  traite des problèmes d'équilibrage plus généraux (ex., des problèmes
  de ratissage de plus grande dimension, solutions non négatives,
  contraintes linéaires générales d'égalité et d'inégalité par
  opposition à des règles d'agrégation uniquement, etc.)

- `tsraking()` renvoie la solution des moindres carrés généralisés du
  modèle de ratissage basé sur la régression de Dagum et Cholette (Dagum
  et Cholette 2006) tandis que
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  résout le problème de minimisation quadratique correspondant à l'aide
  d'un solveur numérique. Dans la plupart des cas, la *convergence vers
  le minimum* est atteinte et la solution de
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  correspond à la solution (exacte) des moindres carrés de `tsraking()`.
  Cela peut ne pas être le cas, cependant, si la convergence n'a pas pu
  être atteinte après un nombre raisonnable d'itérations. Cela dit, ce
  n'est qu'en de très rares occasions que la solution de
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  différera *significativement* de celle de `tsraking()`.

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  est généralement plus rapide que `tsraking()`, en particulier pour les
  gros problèmes de ratissage, mais est généralement plus sensible à la
  présence de (petites) incohérences dans les données d'entrée associées
  aux contraintes redondantes des problèmes de ratissage *entièrement
  spécifiés* (ou surspécifiés). `tsraking()` gère ces incohérences en
  utilisant l'inverse de Moore-Penrose (distribution uniforme à travers
  tous les totaux contraignants).

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  permet de spécifier des problèmes épars (clairsemés) sous leur forme
  réduite. Ce n'est pas le cas de `tsraking()` où les règles
  d'agrégation doivent toujours être entièrement spécifiées étant donné
  qu'un *cube de données complet*, sans données manquantes, est attendu
  en entrée (chaque série composante de l'*intérieur du cube* doit
  contribuer à toutes les dimensions du cube, c.-à-d., à chaque série
  totale des *faces extérieures du cube*).

- Les deux outils traitent différemment les valeurs négatives dans les
  données d'entrée par défaut. Alors que les solutions des problèmes de
  ratissage obtenues avec
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  et `tsraking()` sont identiques lorsque tous les points de données
  d'entrée sont positifs, elles seront différentes si certains points de
  données sont négatifs (à moins que l'argument `Vmat_option = 2` ne
  soit spécifié avec `tsraking()`).

- Alors que
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  et `tsraking()` permettent toutes les deux de préserver les totaux
  temporels, la gestion du temps n'est pas incorporée dans `tsraking()`.
  Par exemple, la construction des groupes de traitement (ensembles de
  périodes de chaque problème de ratissage) est laissée à l'utilisateur
  avec `tsraking()` et des appels séparés doivent être soumis pour
  chaque groupe de traitement (chaque problème de ratissage). De là
  l'utilité de la fonction d'assistance
  [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
  pour `tsraking()`.

- Les totaux marginaux (séries des faces extérieures du cube de données)
  renvoyés par `tsraking()` sont toujours recalculés comme la somme des
  séries composantes pertinentes (séries de l'intérieur du cube). Les
  valeurs de sortie des totaux marginaux **contraignants** peuvent donc
  légèrement différer des valeurs d’entrée. L’ampleur des différences
  dépend des incohérences initiales (qui sont uniformément distribuées
  par l’inverse de Moore-Penrose). Ce n’est pas le cas de
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  où les totaux marginaux **contraignants** restent toujours
  parfaitement inchangés, ce qui peut se traduire par des (petits)
  écarts en sortie entre la somme des séries composantes et le total
  marginal correspondant.

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  renvoie le même ensemble de séries que l'objet d'entrée de type série
  chronologique (argument `in_ts`) alors que `tsraking()` renvoie
  l'ensemble des séries impliquées dans le problème de ratissage plus
  celles spécifiées avec l'argument `id` (qui pourrait correspondre à un
  sous-ensemble des séries d'entrée).

## Références

Bérubé, J. and S. Fortier (2009). « PROC TSRAKING: An in-house
SAS\\^\circledR\\ procedure for balancing time series ». Dans **JSM
Proceedings, Business and Economic Statistics Section**. Alexandria, VA:
American Statistical Association.

Dagum, E. B. and P. Cholette (2006). **Benchmarking, Temporal
Distribution and Reconciliation Methods of Time Series**.
Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
[doi:10.1007/0-387-35439-5](https://doi.org/10.1007/0-387-35439-5)

Ferland, M. (2016). « Negative Values with PROC TSRAKING ». **Document
interne**. Statistique Canada, Ottawa, Canada.

Fortier, S. and B. Quenneville (2009). « Reconciliation and Balancing of
Accounts and Time Series ». Dans **JSM Proceedings, Business and
Economic Statistics Section**. Alexandria, VA: American Statistical
Association.

Quenneville, B. and S. Fortier (2012). « Restoring Accounting
Constraints in Time Series – Methods and Software for a Statistical
Agency ». **Economic Time Series: Modeling and Seasonality**. Chapman &
Hall, New York.

Statistique Canada (2016). « La procédure TSRAKING ». **Guide de
l'utilisateur de G-Séries 2.0**. Statistique Canada, Ottawa, Canada.

Statistique Canada (2018). **Théorie et application de la réconciliation
(Code du cours 0437)**. Statistique Canada, Ottawa, Canada.

## Voir également

[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
[`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/fr/reference/rkMeta_to_blSpecs.md)
[`gs.gInv_MP()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.gInv_MP.md)
[`build_raking_problem()`](https://StatCan.github.io/gensol-gseries/fr/reference/build_raking_problem.md)
[aliases](https://StatCan.github.io/gensol-gseries/fr/reference/aliases.md)

## Exemples

``` r
###########
# Exemple 1 : Problème simple de ratissage à une dimension dans lequel les valeurs des 
#             `autos` et des `camions` doivent être égales à la valeur du `total`.

# Métadonnées du problème
mes_meta1 <- data.frame(
  series = c("autos", "camions"),
  total1 = c("total", "total")
)
mes_meta1
#>    series total1
#> 1   autos  total
#> 2 camions  total

# Données du problème
mes_series1 <- data.frame(autos = 25, camions = 5, total = 40)

# Réconcilier les données
res_ratis1 <- tsraking(mes_series1, mes_meta1)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = mes_series1
#>     metadata_df     = mes_meta1
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 

# Données initiales
mes_series1
#>   autos camions total
#> 1    25       5    40

# Données réconciliées
res_ratis1
#>      autos  camions total
#> 1 33.33333 6.666667    40

# Vérifier les contraintes transversales en sortie
all.equal(rowSums(res_ratis1[c("autos", "camions")]), res_ratis1$total)
#> [1] TRUE

# Vérifier le total de contrôle (fixe)
all.equal(mes_series1$total, res_ratis1$total)
#> [1] TRUE


###########
# Exemple 2 : problème de ratissage à 2 dimensions similaire au 1er exemple mais 
#             en ajoutant les ventes régionales pour les 3 provinces des prairies 
#             (Alb., Sask. et Man.) et où les ventes de camions en Sask. ne sont 
#             pas modifiables (coefficient d'altérabilité = 0), avec `quiet = TRUE` 
#             pour éviter l'affichage de l'en-tête de la fonction.

# Métadonnées du problème
mes_meta2 <- data.frame(
  series = c(
    "autos_alb", "autos_sask", "autos_man",
    "camions_alb", "camions_sask", "camions_man"
  ),
  total1 = c(
    rep("total_autos", 3),
    rep("total_camions", 3)
  ),
  total2 = rep(c("total_alb", "total_sask", "total_man"), 2)
)

# Données du problème
mes_series2 <- data.frame(
  autos_alb = 12, autos_sask = 14, autos_man = 13,
  camions_alb = 20, camions_sask = 20, camions_man = 24,
  total_alb = 30, total_sask = 31, total_man = 32,
  total_autos = 40, total_camions = 53
)

# Réconcilier les données
res_ratis2 <- tsraking(
  mes_series2, mes_meta2,
  alterability_df = data.frame(camions_sask = 0),
  quiet = TRUE
)

# Données initiales
mes_series2
#>   autos_alb autos_sask autos_man camions_alb camions_sask camions_man total_alb
#> 1        12         14        13          20           20          24        30
#>   total_sask total_man total_autos total_camions
#> 1         31        32          40            53

# Données réconciliées
res_ratis2
#>   autos_alb autos_sask autos_man camions_alb camions_sask camions_man total_alb
#> 1  14.31298         11  14.68702    15.68702           20    17.31298        30
#>   total_sask total_man total_autos total_camions
#> 1         31        32          40            53

# Vérifier les contraintes transversales en sortie
all.equal(
  rowSums(res_ratis2[c("autos_alb", "autos_sask", "autos_man")]), 
  res_ratis2$total_autos
)
#> [1] TRUE
all.equal(
  rowSums(res_ratis2[c("camions_alb", "camions_sask", "camions_man")]), 
  res_ratis2$total_camions
)
#> [1] TRUE
all.equal(
  rowSums(res_ratis2[c("autos_alb", "camions_alb")]), 
  res_ratis2$total_alb
)
#> [1] TRUE
all.equal(
  rowSums(res_ratis2[c("autos_sask", "camions_sask")]), 
  res_ratis2$total_sask
)
#> [1] TRUE
all.equal(
  rowSums(res_ratis2[c("autos_man", "camions_man")]), 
  res_ratis2$total_man
)
#> [1] TRUE

# Vérifier le total de contrôle (fixe)
cols_tot <- union(unique(mes_meta2$total1), unique(mes_meta2$total2))
all.equal(mes_series2[cols_tot], res_ratis2[cols_tot])
#> [1] TRUE

# Vérifier la valeur des camions en Saskatchewan (fixée à 20)
all.equal(mes_series2$camions_sask, res_ratis2$camions_sask)
#> [1] TRUE
```
