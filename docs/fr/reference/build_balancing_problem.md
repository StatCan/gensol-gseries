# Construire les éléments des problèmes d'équilibrage.

Cette fonction est utilisée à l'interne par
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
pour construire les éléments des problèmes d'équilibrage. Elle peut
également être utile pour dériver manuellement (en dehors du contexte de
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md))
les séries indirectes associées aux contraintes d'équilibrage d'égalité.

## Utilisation

``` r
build_balancing_problem(
  in_ts,
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
  validation_only = FALSE
)
```

## Arguments

- in_ts:

  (obligatoire)

  Objet de type série chronologique (classe « ts » ou « mts ») qui
  contient les données des séries chronologiques à réconcilier. Il
  s'agit des données d'entrée (solutions initiales) des problèmes
  d'équilibrage (« *balancing* »).

- problem_specs_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») des spécifications du
  problème d'équilibrage. En utilisant un format clairsemé (épars)
  inspiré de la procédure LP de SAS/OR\\^\circledR\\ (SAS Institute
  2015), il ne contient que les informations pertinentes telles que les
  coefficients non nuls des contraintes d'équilibrage ainsi que les
  coefficients d'altérabilité et les bornes inférieures/supérieures à
  utiliser au lieu des valeurs par défaut (c.-à-d., les valeurs qui
  auraient la priorité sur celles définies avec les arguments
  `alter_pos`, `alter_neg`, `alter_mix`, `alter_temporal`, `lower_bound`
  et `upper_bound`).

  Les informations sont fournies à l'aide de quatre variables
  obligatoires (`type`, `col`, `row` et `coef`) et d'une variable
  facultative (`timeVal`). Un enregistrement (une rangée) dans le *data
  frame* des spécifications du problème définit soit une étiquette pour
  l'un des sept types d'éléments du problème d'équilibrage avec les
  colonnes `type` et `row` (voir *Enregistrements de définition
  d'étiquette* ci-dessous) ou bien spécifie des coefficients (valeurs
  numériques) pour ces éléments du problème d'équilibrage avec les
  variables `col`, `row`, `coef` et `timeVal` (voir *Enregistrements de
  spécification d'information* ci-dessous).

  - **Enregistrements de définition d'étiquette** (`type` n'est pas
    manquant (n'est pas `NA`))

    - `type` (car) : mot-clé réservé identifiant le type d'élément du
      problème en cours de définition :

      - `EQ` : contrainte d'équilibrage d'égalité (\\=\\)

      - `LE` : contrainte d'équilibrage d'inégalité de type inférieure
        ou égale (\\\le\\)

      - `GE` : contrainte d'équilibrage d'inégalité de type supérieure
        ou égale (\\\ge\\)

      - `lowerBd` : borne inférieure des valeurs de période

      - `upperBd` : borne supérieure des valeurs de période

      - `alter` : coefficient d'altérabilité des valeurs de période

      - `alterTmp` : coefficient d'altérabilité des totaux temporels

    - `row` (car) : étiquette à associer à l'élément du problème
      (*mot-clé `type`*)

    - *toutes les autres variables ne sont pas pertinentes et devraient
      contenir des données manquantes (valeurs `NA`)*  
        

  - **Enregistrements de spécification d'information** (`type` est
    manquant (est `NA`))

    - `type` (car) : non applicable (`NA`)

    - `col` (car) : nom de la série ou mot réservé `_rhs_` pour
      spécifier la valeur du côté droit (*RHS* pour ***R**ight-**H**and
      **S**ide*) d'une contrainte d'équilibrage.

    - `row` (car) : étiquette de l'élément du problème.

    - `coef` (num) : valeur de l'élément du problème :

      - coefficient de la série dans la contrainte d'équilibrage ou
        valeur *RHS*

      - borne inférieure ou supérieure des valeurs de période de la
        série

      - coefficient d'altérabilité des valeurs de période ou des totaux
        temporels de la série

    - `timeVal` (num) : valeur de temps optionnelle pour restreindre
      l'application des bornes ou coefficients d'altérabilité des séries
      à une période (ou groupe temporel) spécifique. Elle correspond à
      la valeur de temps, telle que renvoyée par
      [`stats::time()`](https://rdrr.io/r/stats/time.html), pour une
      période (observation) donnée des séries chronologiques d'entrée
      (argument `in_ts`) et correspond conceptuellement à
      \\ann\acute{e}e + (p\acute{e}riode - 1) / fr\acute{e}quence\\.

  Notez que les chaînes de caractères vides (`""` ou `''`) pour les
  variables de type caractère sont interprétées comme manquantes (`NA`)
  par la fonction. La variable `row` identifie les éléments du problème
  d'équilibrage et est la variable clé qui fait le lien entre les deux
  types d'enregistrements. La même étiquette (`row`) ne peut être
  associée à plus d'un type d'éléments du problème (`type`) et plusieurs
  étiquettes (`row`) ne peuvent pas être définies pour un même type
  d'éléments du problème donné (`type`), à l'exception des contraintes
  d'équilibrage (valeurs `"EQ"`, `"LE"` et `"GE"` de la colonne `type`).
  Voici certaines caractéristiques conviviales du *data frame* des
  spécifications du problème :

  - L'ordre des enregistrements (rangées) n'est pas important.

  - Les valeurs des variables de type caractère (`type`, `row` et `col`)
    ne sont pas sensibles à la casse (ex., les chaînes de caractères
    `"Constraint 1"` et `"CONSTRAINT 1"` pour la variable `row` seraient
    considérées comme une même étiquette d'élément du problème), sauf
    lorsque `col` est utilisé pour spécifier un nom de série (une
    colonne de l'objet d'entrée de type série chronologique) où **la
    sensibilité à la casse est appliquée**.

  - Les noms des variables du *data frame* des spécifications du
    problème ne sont pas non plus sensibles à la casse (ex., `type`,
    `Type` ou `TYPE` sont tous des noms de variable valides) et
    `time_val` est un nom de variable accepté (au lieu de `timeVal`).

  Enfin, le tableau suivant dresse la liste des alias valides (acceptés)
  pour les *mots-clés `type`* (type d'éléments du problème) :

  |  |  |
  |----|----|
  | **Mot-clé** | **Alias** |
  | `EQ` | `==`, `=` |
  | `LE` | `<=`, `<` |
  | `GE` | `>=`, `>` |
  | `lowerBd` | `lowerBound`, `lowerBnd`, + *mêmes termes avec '\_', '.' ou ' ' entre les mots* |
  | `upperBd` | `upperBound`, `upperBnd`, + *mêmes termes avec '\_', '.' ou ' ' entre les mots* |
  | `alterTmp` | `alterTemporal`, `alterTemp`, + *mêmes termes avec '\_', '.' ou ' ' entre les mots* |

  L'examen des **Exemples** devrait aider à conceptualiser le *data
  frame* des spécifications du problème d'équilibrage.

- in_ts_name:

  (optionnel)

  Chaîne de caractères contenant la valeur de l'argument `in_ts`.

  **La valeur par défaut** est
  `in_ts_name = deparse1(substitute(in_ts))`.

- ts_freq:

  (optionnel)

  Fréquence de l'object the type série chronologique (argument `in_ts`).

  **La valeur par défaut** est `ts_freq = stats::frequency(in_ts)`.

- periods:

  (optionnel)

  Vecteur de chaînes de caractères décrivant les périodes de l'object
  the type série chronologique (argument `in_ts`).

  **La valeur par défaut** est `periods = gs.time2str(in_ts)`.

- n_per:

  (optionnel)

  Nombre de périodes de l'object the type série chronologique (argument
  `in_ts`).

  **La valeur par défaut** est `n_per = nrow(as.matrix(in_ts))`.

- specs_df_name:

  (optionnel)

  Chaîne de caractères contenant la valeur de l'argument
  `problem_specs_df`.

  **La valeur par défaut** est
  `specs_df_name = deparse1(substitute(problem_specs_df))`.

- temporal_grp_periodicity:

  (optionnel)

  Nombre entier positif définissant le nombre de périodes dans les
  groupes temporels pour lesquels les totaux doivent être préservés. Par
  exemple, spécifiez `temporal_grp_periodicity = 3` avec des séries
  chronologiques mensuelles pour la préservation des totaux trimestriels
  et `temporal_grp_periodicity = 12` (ou
  `temporal_grp_periodicity = frequency(in_ts)`) pour la préservation
  des totaux annuels. Spécifier `temporal_grp_periodicity = 1`
  (*défaut*) correspond à un traitement période par période sans
  préservation des totaux temporels.

  **La valeur par défaut** est `temporal_grp_periodicity = 1`
  (traitement période par période sans préservation des totaux
  temporels).

- alter_pos:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut associé aux valeurs des séries chronologiques avec des
  coefficients **positifs** dans toutes les contraintes d'équilibrage
  dans lesquelles elles sont impliquées (ex., les séries composantes
  dans les problèmes de ratissage (« *raking* ») de tables
  d'agrégation). Les coefficients d'altérabilité fournis dans le *data
  frame* des spécifications du problème (argument `problem_specs_df`)
  remplacent cette valeur.

  **La valeur par défaut** est `alter_pos = 1.0` (valeurs non
  contraignantes).

- alter_neg:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut associé aux valeurs des séries chronologiques avec des
  coefficients **négatifs** dans toutes les contraintes d'équilibrage
  dans lesquelles elles sont impliquées (ex., les séries de total de
  marge dans les problèmes de ratissage (« *raking* ») de tables
  d'agrégation). Les coefficients d'altérabilité fournis dans le *data
  frame* des spécifications du problème (argument `problem_specs_df`)
  remplacent cette valeur.

  **La valeur par défaut** est `alter_neg = 1.0` (valeurs non
  contraignantes).

- alter_mix:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut associé aux valeurs des séries chronologiques avec un mélange
  de coefficients **positifs et négatifs** dans les contraintes
  d'équilibrage dans lesquelles elles sont impliquées. Les coefficients
  d'altérabilité fournis dans le *data frame* des spécifications du
  problème (argument `problem_specs_df`) remplacent cette valeur.

  **La valeur par défaut** est `alter_mix = 1.0` (valeurs non
  contraignantes).

- lower_bound:

  (optionnel)

  Nombre réel spécifiant la borne inférieure par défaut pour les valeurs
  des séries chronologiques. Les bornes inférieures fournies dans le
  *data frame* des spécifications du problème (argument
  `problem_specs_df`) remplacent cette valeur.

  **La valeur par défaut** est `lower_bound = -Inf` (non borné).

- upper_bound:

  (optionnel)

  Nombre réel spécifiant la borne supérieure par défaut pour les valeurs
  des séries chronologiques. Les bornes supérieures fournies dans le
  *data frame* des spécifications du problème (argument
  `problem_specs_df`) remplacent cette valeur.

  **La valeur par défaut** est `upper_bound = Inf` (non borné).

- validation_only:

  (optionnel)

  Argument logique (*logical*) spécifiant si la fonction doit uniquement
  effectuer la validation des données d'entrée ou non. Lorsque
  `validation_only = TRUE`, les *contraintes d'équilibrage* et les
  *bornes (inférieures et supérieures) des valeurs de période*
  spécifiées sont validées par rapport aux données de séries
  chronologiques d'entrée, en permettant des écarts jusqu'à la valeur
  spécifiée avec l'argument `validation_tol`. Sinon, lorsque
  `validation_only = FALSE` (par défaut), les données d'entrée sont
  d'abord réconciliées et les données résultantes (en sortie) sont
  ensuite validées.

  **La valeur par défaut** est `validation_only = FALSE`.

## Valeur de retour

Une liste avec les éléments des problèmes d'équilibrage (excluant
l'information sur les totaux temporels) :

- `labels_df` : version nettoyée des *enregistrements de définition
  d'étiquette* provenant de `problem_specs_df` (enregistrements où
  `type` n'est pas manquant (n'est pas `NA`)); colonnes
  supplémentaires :

  - `type.lc`  : `tolower(type)`

  - `row.lc`  : `tolower(row)`

  - `con.flag` : `type.lc %in% c("eq", "le", "ge")`

- `coefs_df`  : version nettoyée des *enregistrements de spécification
  d'information* provenant de `problem_specs_df` (enregistrements où
  `type` est manquant (est `NA`)); colonnes supplémentaires :

  - `row.lc`  : `tolower(row)`

  - `con.flag` : `labels_df$con.flag` attribuée à travers `row.lc`

- `values_ts`: version réduite de `in_ts` avec seulement les séries
  pertinentes (voir vecteur `ser_names`)

- `lb`  : information sur les bornes inférieures (`type.lc = "lowerbd"`)
  des séries pertinentes; liste avec les éléments suivants :

  - `coefs_ts`  : object « mts » contenant les bornes inférieures des
    séries pertientes (voir vecteur `ser_names`)

  - `nondated_coefs`  : vecteur des bornes non datées de
    `problem_specs_df` (`timeVal` est `NA`)

  - `nondated_id_vec` : vecteur d'identificateurs de `ser_names`
    associés au vecteur `nondated_coefs`

  - `dated_id_vec`  : vecteur d'identificateurs de `ser_names` associés
    aux bornes inférieures datées de `problem_specs_df` (`timeVal` n'est
    pas `NA`)

- `ub`  : équivalent de `lb` pour les bornes supérieures
  (`type.lc = "upperbd"`)

- `alter`  : équivalent de `lb` pour les coefficients d'altérabilité des
  valeurs de période (`type.lc = "alter"`)

- `altertmp`  : équivalent de `lb` pour les coefficients d'altérabilité
  des totaux temporels (`type.lc = "altertmp"`)

- `ser_names` : vecteur des noms de séries pertinentes (ensemble de
  séries impliquées dans les contraintes d'équilibrage)

- `pos_ser`  : vecteur des noms de séries qui n'ont que des coefficients
  non nuls positifs à travers toutes les contraintes

- `neg_ser`  : vecteur des noms de séries qui n'ont que des coefficients
  non nuls négatifs à travers toutes les contraintes

- `mix_ser`  : vecteur des noms de séries qui ont des coefficients non
  nuls positifs et négatifs à travers toutes les contraintes

- `A1`,`op1`,`b1` : éléments des contraintes d'équilibrage pour les
  problèmes impliquant une seule période (ex., chacune des périodes d'un
  groupe temporel incomplet)

- `A2`,`op2`,`b2` : éléments des contraintes d'équilibrage pour les
  problèmes impliquant `temporal_grp_periodicity` périodes (ex.,
  l'ensemble des périodes d'un groupe temporel complet)

## Détails

Voir
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
pour une description détaillée des problèmes d'*équilibrage de séries
chronologiques*.

Toute valeur manquante (`NA`) trouvée dans l'objet de série
chronologique d'entrée (argument `in_ts`) serait remplacée par 0 dans
`values_ts` et déclencherait un message d'avertissement.

Les éléments renvoyés des problèmes d'équilibrage n'incluent pas les
totaux temporels implicites (c.-à-d., les éléments `A2`, `op2` et `b2`
ne contiennent que les contraintes d'équilibrage).

Les éléments `A2`, `op2` et `b2` d'un problème d'équilibrage impliquant
plusieurs périodes (lorsque `temporal_grp_periodicity > 1`) sont
construits *colonne par colonne* (selon le principe « column-major
order » en anglais), ce qui correspond au comportement par défaut de R
lors de la conversion d'objets de la classe « matrix » en vecteurs.
Autrement dit, les contraintes d'équilibrage correspondent
conceptuellement à :

- `A1 %*% values_ts[t, ] op1 b1` pour des problèmes impliquant une seule
  période (`t`)

- `A2 %*% as.vector(values_ts[t1:t2, ]) op2 b2` pour des problèmes
  impliquant `temporal_grp_periodicity` périodes (`t1:t2`)

Notes :

- L'argument `alter_temporal` n'a pas encore été appliqué à ce stade et
  `altertmp$coefs_ts` ne contient que les coefficients spécifiés dans le
  *data frame* des spécifications du problème (argument
  `problem_specs_df`). Autrement dit, `altertmp$coefs_ts` contient des
  valeurs manquantes (`NA`) à l'exception des coefficients
  d'altérabilité de total temporel inclus dans (spécifiés avec)
  `problem_specs_df`. Ceci est fait afin de faciliter l'identification
  du premier coefficient d'altérabilité non manquant (non `NA`) de
  chaque groupe temporel complet (à survenir ultérieurement, le cas
  échéant, dans
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)).

- La validation des arguments n'est pas effectuée ici ; on suppose
  (carrément) que la fonction est appelée par
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  où une validation complète des arguments est effectuée.

## Voir également

[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
[`build_raking_problem()`](https://StatCan.github.io/gensol-gseries/fr/reference/build_raking_problem.md)

## Exemples

``` r
######################################################################################
#  Cadre de dérivation des séries indirectes avec les métadonnées de `tsbalancing()`
######################################################################################
#
# Il est supposé (convenu) que...
#
# a) Toutes les contraintes d'équilibrage sont des contraintes d'égalité (`type = EQ`).
# b) Toutes les contraintes n'ont qu'une seule série non contraignante (libre) : la 
#    série à dériver (c.-à-d., toutes les séries ont un coef. d'alt. de 0 sauf la 
#    série à dériver).
# c) Chaque contrainte dérive une série différente (une nouvelle série).
# d) Les contraintes sont les mêmes pour toutes les périodes (c.-à-d., il n'y a pas 
#    de coef. d'alt. « datés » spécifiés à l'aide de la colonne `timeVal`).
######################################################################################


# Dériver les 5 totaux de marge d'un cube de données à deux dimensions 2 x 3 en 
# utilisant les métadonnées de `tsbalancing()` (les contraintes d'agrégation d'un 
# cube de données respectent les hypothèses ci-dessus).


# Construire les spécifications du problème d'équilibrage à travers les métadonnées 
# (plus simples) de ratissage.
mes_specs <- rkMeta_to_blSpecs(
  data.frame(
    series = c(
      "A1", "A2", "A3",
      "B1", "B2", "B3"
    ),
    total1 = c(
      rep("totA", 3),
      rep("totB", 3)
    ),
    total2 = rep(c("tot1", "tot2", "tot3"), 2)
  ),
  alterSeries = 0,  # séries composantes contraignantes (fixes)
  alterTotal1 = 1,  # totaux de marge non contraignants (libres, à dériver)
  alterTotal2 = 1)  # totaux de marge non contraignants (libres, à dériver)
mes_specs
#>     type  col                       row coef timeVal
#> 1     EQ <NA>   Marginal Total 1 (totA)   NA      NA
#> 2   <NA>   A1   Marginal Total 1 (totA)    1      NA
#> 3   <NA>   A2   Marginal Total 1 (totA)    1      NA
#> 4   <NA>   A3   Marginal Total 1 (totA)    1      NA
#> 5   <NA> totA   Marginal Total 1 (totA)   -1      NA
#> 6     EQ <NA>   Marginal Total 2 (totB)   NA      NA
#> 7   <NA>   B1   Marginal Total 2 (totB)    1      NA
#> 8   <NA>   B2   Marginal Total 2 (totB)    1      NA
#> 9   <NA>   B3   Marginal Total 2 (totB)    1      NA
#> 10  <NA> totB   Marginal Total 2 (totB)   -1      NA
#> 11    EQ <NA>   Marginal Total 3 (tot1)   NA      NA
#> 12  <NA>   A1   Marginal Total 3 (tot1)    1      NA
#> 13  <NA>   B1   Marginal Total 3 (tot1)    1      NA
#> 14  <NA> tot1   Marginal Total 3 (tot1)   -1      NA
#> 15    EQ <NA>   Marginal Total 4 (tot2)   NA      NA
#> 16  <NA>   A2   Marginal Total 4 (tot2)    1      NA
#> 17  <NA>   B2   Marginal Total 4 (tot2)    1      NA
#> 18  <NA> tot2   Marginal Total 4 (tot2)   -1      NA
#> 19    EQ <NA>   Marginal Total 5 (tot3)   NA      NA
#> 20  <NA>   A3   Marginal Total 5 (tot3)    1      NA
#> 21  <NA>   B3   Marginal Total 5 (tot3)    1      NA
#> 22  <NA> tot3   Marginal Total 5 (tot3)   -1      NA
#> 23 alter <NA> Period Value Alterability   NA      NA
#> 24  <NA>   A1 Period Value Alterability    0      NA
#> 25  <NA>   A2 Period Value Alterability    0      NA
#> 26  <NA>   A3 Period Value Alterability    0      NA
#> 27  <NA>   B1 Period Value Alterability    0      NA
#> 28  <NA>   B2 Period Value Alterability    0      NA
#> 29  <NA>   B3 Period Value Alterability    0      NA
#> 30  <NA> totA Period Value Alterability    1      NA
#> 31  <NA> totB Period Value Alterability    1      NA
#> 32  <NA> tot1 Period Value Alterability    1      NA
#> 33  <NA> tot2 Period Value Alterability    1      NA
#> 34  <NA> tot3 Period Value Alterability    1      NA

# 6 périodes (trimestres) de données avec totaux de marge initialisés à zéro (0): ces 
# derniers doivent OBLIGATOIREMENT exister dans les données d'entrée ET contenir des 
# données valides (non `NA`).
mes_series <- ts(
  data.frame(
    A1 = c(12, 10, 12,  9, 15,  7),
    B1 = c(20, 21, 15, 17, 19, 18),
    A2 = c(14,  9,  8,  9, 11, 10),
    B2 = c(20, 29, 20, 24, 21, 17),
    A3 = c(13, 15, 17, 14, 16, 12),
    B3 = c(24, 20, 30, 23, 21, 19),
    tot1 = rep(0, 6),
    tot2 = rep(0, 6),
    tot3 = rep(0, 6),
    totA = rep(0, 6),
    totB = rep(0, 6)
  ),
  start = 2019, frequency = 4
)

# Obtenir les éléments du problème d'équilibrage.
n_per <- nrow(mes_series)
p <- build_balancing_problem(
  mes_series, mes_specs, 
  temporal_grp_periodicity = n_per
)

# `A2`, `op2` et `b2` définissent 30 constraintes (5 totaux de marge X 6 périodes) 
# impliquant un total de 66 points de données (11 séries X 6 périodes) desquels 36 
# réfèrent aux 6 séries composantes et 30 réfèrent aux 5 totaux de marge.
dim(p$A2)
#> [1] 30 66

# Obtenir les noms des totaux de marge (séries avec un coef. d'alt. non nul), dans 
# l'ordre où les contraintes correspondantes apparaissent dans les spécifications 
# (ordre de spécification des constraintes).
tmp <- p$coefs_df$col[p$coefs_df$con.flag]
noms_tot <- tmp[
  tmp %in% p$ser_names[p$alter$nondated_id_vec[p$alter$nondated_coefs != 0]]
]

# Définir des drapeaux logiques identifiant les colonnes de total de marge :
# - `col_tot_logi1` : éléments à période unique (de longueur 11 = nombre de séries)
# - `col_tot_logi2` : éléments multi-périodes (de longueur 66 = nombre de points de
#                     données), selon le principe « column-major order » en anglais 
#                     (l'ordre de construction des éléments de la matrice `A2`)
col_tot_logi1 <- p$ser_names %in% noms_tot
col_tot_logi2 <- rep(col_tot_logi1, each = n_per)

# Ordre des totaux de marge à dériver selon
# ... les colonnes des données d'entrée (objet « mts » `mes_series`)
p$ser_names[col_tot_logi1]
#> [1] "tot1" "tot2" "tot3" "totA" "totB"
# ... la spécification des contraintes (« data frame » `mes_specs`)
noms_tot
#> [1] "totA" "totB" "tot1" "tot2" "tot3"


# Calculer les 5 totaux de marge pour les 6 périodes.
# Note : le calcul suivant prend en compte les contraintes d'égalité linéaires 
#        générales, c.-à-d.,
#        a) des valeurs non nulles du côté droit des contraintes (`b2`) et 
#        b) des coefficients de contrainte non nuls autres que 1 pour les séries 
#           composantes et -1 pour la série à dériver. 
mes_series[, noms_tot] <- {
  (
    # Côté droit des contraintes
    p$b2 - 

    # Sommes des composantes (« pondérées » par les coefficients des contraintes)
    p$A2[, !col_tot_logi2, drop = FALSE] %*% as.vector(p$values_ts[, !col_tot_logi1])
  ) /

  # Coefficients des séries dérivées : `t()` permet une recherche « par ligne » dans 
  # la matrice `A2` (c.-à-d., selon l'ordre de spécification des constraintes)
  # Note: `diag(p$A2[, tot_col_logi2])` fonctionnerait si `p$ser_names[col_tot_logi1]` 
  #       et `noms_tot` étaient identiques (même ordre pour les totaux); par contre, 
  #       la recherche « par ligne » ci-dessous fonctionnera toujours (et est 
  #       nécessaire dans le cas qui nous concerne).
  t(p$A2[, col_tot_logi2])[t(p$A2[, col_tot_logi2]) != 0]
}
mes_series
#>         A1 B1 A2 B2 A3 B3 tot1 tot2 tot3 totA totB
#> 2019 Q1 12 20 14 20 13 24   32   34   37   39   64
#> 2019 Q2 10 21  9 29 15 20   31   38   35   34   70
#> 2019 Q3 12 15  8 20 17 30   27   28   47   37   65
#> 2019 Q4  9 17  9 24 14 23   26   33   37   32   64
#> 2020 Q1 15 19 11 21 16 21   34   32   37   42   61
#> 2020 Q2  7 18 10 17 12 19   25   27   31   29   54
```
