# Construire les éléments des problèmes de ratissage.

Cette fonction est utilisée à l'interne par
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
pour construire les éléments du problème de ratissage. Elle peut
également être utile pour dériver manuellement (en dehors du contexte de
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md))
les totaux (de marge) transversaux du problème de ratissage.

## Utilisation

``` r
build_raking_problem(
  data_df,
  metadata_df,
  data_df_name = deparse1(substitute(data_df)),
  metadata_df_name = deparse1(substitute(metadata_df)),
  alterability_df = NULL,
  alterSeries = 1,
  alterTotal1 = 0,
  alterTotal2 = 0
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

- data_df_name:

  (optionnel)

  Chaîne de caractères contenant la valeur de l'argument `data_df`.

  **La valeur par défaut** est
  `data_df_name = deparse1(substitute(data_df))`.

- metadata_df_name:

  (optionnel)

  Chaîne de caractères contenant la valeur de l'argument `metadata_df`.

  **La valeur par défaut** est
  `data_df_name = deparse1(substitute(metadata_df))`.

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

## Valeur de retour

Une liste avec les éléments du problème de ratissage (excluant les
totaux temporels implicites) :

- `x`  : vecteur des valeurs initiales des séries composantes

- `c_x`  : vecteur des coefficients d'altérabilité des séries
  composantes

- `comp_cols` : vecteur des noms des séries composantes (colonnes de
  `data_df`)

- `g`  : vecteur des valeurs initiales des totaux transversaux

- `c_g`  : vecteur des coefficients d'altérabilité des totaux
  transversaux

- `tot_cols`  : vecteur des noms des totaux transversaux (colonnes de
  `data_df`)

- `G`  : matrice d'agrégation des totaux transversaux (`g = G %*% x`)

## Détails

Voir
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
pour une description détaillée des problèmes de *ratissage de séries
chronologiques*.

Les éléments du problème de ratissage renvoyés n'incluent pas les totaux
temporels implicites des séries de composantes, le cas échéant (c.-à-d.,
les éléments `g` et `G` ne contiennent que l'information sur les totaux
transversaux).

Lorsque les données d'entrée contiennent plusieurs périodes (scénario de
préservation des totaux temporels), les éléments `x`, `c_x`, `g`, `c_g`
et `G` du problème de ratissage sont construits *colonne par colonne*
(selon le principe « column-major order » en anglais), ce qui correspond
au comportement par défaut de R lors de la conversion d'objets de la
classe « matrix » en vecteurs.

Note : la validation des arguments n'est pas effectuée ici ; on suppose
(carrément) que la fonction est appelée par
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
où une validation complète des arguments est effectuée.

## Voir également

[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
[`build_balancing_problem()`](https://StatCan.github.io/gensol-gseries/fr/reference/build_balancing_problem.md)

## Exemples

``` r
# Dériver les 5 totaux de marge d'un cube de données à deux dimensions 2 x 3 
# en utilisant les métadonnées de `tsraking()`.

mes_meta <- data.frame(
  series = c(
    "A1", "A2", "A3",
    "B1", "B2", "B3"
  ),
  total1 = c(
    rep("totA", 3),
    rep("totB", 3)
  ),
  total2 = rep(c("tot1", "tot2", "tot3"), 2)
)
mes_meta
#>   series total1 total2
#> 1     A1   totA   tot1
#> 2     A2   totA   tot2
#> 3     A3   totA   tot3
#> 4     B1   totB   tot1
#> 5     B2   totB   tot2
#> 6     B3   totB   tot3

# 6 périodes de données avec totaux de marge initialisés à `NA` (ces derniers doivent
# OBLIGATOIREMENT exister dans les données d'entrée mais peuvent être `NA`).
mes_series <- data.frame(
  A1 = c(12, 10, 12,  9, 15,  7),
  B1 = c(20, 21, 15, 17, 19, 18),
  A2 = c(14,  9,  8,  9, 11, 10),
  B2 = c(20, 29, 20, 24, 21, 17),
  A3 = c(13, 15, 17, 14, 16, 12),
  B3 = c(24, 20, 30, 23, 21, 19),
  tot1 = rep(NA, 6),
  tot2 = rep(NA, 6),
  tot3 = rep(NA, 6),
  totA = rep(NA, 6),
  totB = rep(NA, 6)
)

# Obtenir les éléments du problème de ratissage.
p <- build_raking_problem(mes_series, mes_meta)
str(p)
#> List of 7
#>  $ x        : num [1:36] 12 10 12 9 15 7 14 9 8 9 ...
#>  $ c_x      : num [1:36] 1 1 1 1 1 1 1 1 1 1 ...
#>  $ comp_cols: chr [1:6] "A1" "A2" "A3" "B1" ...
#>  $ g        : logi [1:30] NA NA NA NA NA NA ...
#>  $ c_g      : num [1:30] 0 0 0 0 0 0 0 0 0 0 ...
#>  $ tot_cols : chr [1:5] "totA" "totB" "tot1" "tot2" ...
#>  $ G        : num [1:30, 1:36] 1 0 0 0 0 0 0 0 0 0 ...

# Calculer les 5 totaux de marge pour les 6 périodes.
mes_series[p$tot_cols] <- p$G %*% p$x
mes_series
#>   A1 B1 A2 B2 A3 B3 tot1 tot2 tot3 totA totB
#> 1 12 20 14 20 13 24   32   34   37   39   64
#> 2 10 21  9 29 15 20   31   38   35   34   70
#> 3 12 15  8 20 17 30   27   28   47   37   65
#> 4  9 17  9 24 14 23   26   33   37   32   64
#> 5 15 19 11 21 16 21   34   32   37   42   61
#> 6  7 18 10 17 12 19   25   27   31   29   54
```
