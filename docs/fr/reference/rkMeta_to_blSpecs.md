# Convertir des métadonnées de réconciliation

Convertir un *data frame* de métadonnées
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
en un *data frame* de spécifications de problème
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md).

## Utilisation

``` r
rkMeta_to_blSpecs(
  metadata_df,
  alterability_df = NULL,
  alterSeries = 1, 
  alterTotal1 = 0,
  alterTotal2 = 0,
  alterability_df_only = FALSE
)
```

## Arguments

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

- alterability_df_only:

  (optionnel)

  Argument logique (*logical*) spécifiant si oui ou non seul l'ensemble
  des coefficients d'altérabilité trouvés dans le fichier d'altérabilité
  (argument `alterability_df`) doit être inclus dans le *data frame* de
  spécifications de problème
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  renvoyé. Lorsque `alterability_df_only = FALSE` (la valeur par
  défaut), les coefficients d'altérabilité spécifiés avec les arguments
  `alterSeries`, `alterTotal1` et `alterTotal2` sont combinés avec ceux
  trouvés dans `alterability_df` (les derniers coefficients remplaçant
  les premiers) et le *data frame* renvoyé contient donc les
  coefficients d'altérabilité pour toutes les séries composantes et de
  totaux de contrôle transversaux. Cet argument n'affecte pas l'ensemble
  des coefficients d'altérabilité des totaux temporels (associés à
  l'argument `alterAnnual` de
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md))
  qui sont inclus dans le *data frame* de spécifications de problème
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  renvoyé. Ce dernier contient toujours strictement ceux spécifiés dans
  `metadata_df` avec une valeur non manquante (non `NA`) pour la colonne
  `alterAnnual`.

  **La valeur par défaut** est `alterability_df_only = FALSE`.

## Valeur de retour

Un *data frame* de spécifications de problème
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
(argument `problem_specs_df`).

## Détails

La description précédente de l'argument `alterability_df` provient de
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).
Cette fonction (`rkMeta_to_blSpecs()`) modifie légèrement la
spécification des coefficients d'altérabilité avec l'argument
`alterability_df` en permettant

- soit un seul enregistrement, spécifiant l'ensemble des coefficients
  d'altérabilité à utiliser pour toutes les périodes,

- soit un ou plusieurs enregistrements avec une colonne supplémentaire
  nommée `timeVal` permettant de spécifier à la fois des coefficients
  d'altérabilité spécifiques à la période (`timeVal` n'est pas `NA`) et
  des coefficients génériques à utiliser pour toutes les autres périodes
  (`timeVal` est `NA`). Les valeurs de la colonne `timeVal`
  correspondent aux *valeurs de temps* d'un objet « ts » telles que
  renvoyées par [`stats::time()`](https://rdrr.io/r/stats/time.html),
  correspondant conceptuellement à \\ann\acute{e}e +
  (p\acute{e}riode - 1) / fr\acute{e}quence\\.

Une autre différence avec
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
est que des valeurs manquantes (`NA`) sont autorisés dans le *data
frame* des coefficients d'altérabilité (argument `alterability_df`) et
que l'on utiliserait alors les coefficients génériques (enregistrements
pour lesquels `timeVal` est `NA`) ou les coefficients par défaut
(arguments `alterSeries`, `alterTotal1` et `alterTotal2`).

Notez que à part rejeter les coefficients d'altérabilité pour les séries
qui ne sont pas énumérées dans le *data frame* des métadonnées de
ratissage (argument `metadata_df`), cette fonction ne valide pas les
valeurs trouvées dans le *data frame* des coefficients d'altérabilité
(argument `alterability_df`) ni celles trouvées dans la colonne
`alterAnnual` du *data frame* des métadonnées de ratissage (argument
`metadata_df`). La fonction les transfère *telles quelles* dans le *data
frame* des spécifications de problème
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
renvoyé.

## Voir également

[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)

## Exemples

``` r
# Métadonnées de `tsraking()` pour un problème à deux dimensions (table 2 x 2)
mes_metadonnees <- data.frame(
  series = c("A1", "A2", "B1", "B2"),
  total1 = c("totA", "totA", "totB", "totB"),
  total2 = c("tot1", "tot2", "tot1", "tot2")
)
mes_metadonnees
#>   series total1 total2
#> 1     A1   totA   tot1
#> 2     A2   totA   tot2
#> 3     B1   totB   tot1
#> 4     B2   totB   tot2


# Convertir en spécifications de `tsbalancing()`

# Inclure les coefficients d'altérabilité par défaut de `tsraking()`
rkMeta_to_blSpecs(mes_metadonnees)
#>     type  col                       row coef timeVal
#> 1     EQ <NA>   Marginal Total 1 (totA)   NA      NA
#> 2   <NA>   A1   Marginal Total 1 (totA)    1      NA
#> 3   <NA>   A2   Marginal Total 1 (totA)    1      NA
#> 4   <NA> totA   Marginal Total 1 (totA)   -1      NA
#> 5     EQ <NA>   Marginal Total 2 (totB)   NA      NA
#> 6   <NA>   B1   Marginal Total 2 (totB)    1      NA
#> 7   <NA>   B2   Marginal Total 2 (totB)    1      NA
#> 8   <NA> totB   Marginal Total 2 (totB)   -1      NA
#> 9     EQ <NA>   Marginal Total 3 (tot1)   NA      NA
#> 10  <NA>   A1   Marginal Total 3 (tot1)    1      NA
#> 11  <NA>   B1   Marginal Total 3 (tot1)    1      NA
#> 12  <NA> tot1   Marginal Total 3 (tot1)   -1      NA
#> 13    EQ <NA>   Marginal Total 4 (tot2)   NA      NA
#> 14  <NA>   A2   Marginal Total 4 (tot2)    1      NA
#> 15  <NA>   B2   Marginal Total 4 (tot2)    1      NA
#> 16  <NA> tot2   Marginal Total 4 (tot2)   -1      NA
#> 17 alter <NA> Period Value Alterability   NA      NA
#> 18  <NA>   A1 Period Value Alterability    1      NA
#> 19  <NA>   A2 Period Value Alterability    1      NA
#> 20  <NA>   B1 Period Value Alterability    1      NA
#> 21  <NA>   B2 Period Value Alterability    1      NA
#> 22  <NA> totA Period Value Alterability    0      NA
#> 23  <NA> totB Period Value Alterability    0      NA
#> 24  <NA> tot1 Period Value Alterability    0      NA
#> 25  <NA> tot2 Period Value Alterability    0      NA

# Totaux presque contraignants pour la 1ère marge (petits coef. d'altérabilité pour 
# les colonnes `totA` et `totB`)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterTotal1 = 1e-6))
#>    type  col                       row  coef timeVal
#> 20 <NA>   B1 Period Value Alterability 1e+00      NA
#> 21 <NA>   B2 Period Value Alterability 1e+00      NA
#> 22 <NA> totA Period Value Alterability 1e-06      NA
#> 23 <NA> totB Period Value Alterability 1e-06      NA
#> 24 <NA> tot1 Period Value Alterability 0e+00      NA
#> 25 <NA> tot2 Period Value Alterability 0e+00      NA

# Ne pas inclure les coef. d'altérabilité (contraintes d'agrégation uniquement)
rkMeta_to_blSpecs(mes_metadonnees, alterability_df_only = TRUE)
#>    type  col                     row coef timeVal
#> 1    EQ <NA> Marginal Total 1 (totA)   NA      NA
#> 2  <NA>   A1 Marginal Total 1 (totA)    1      NA
#> 3  <NA>   A2 Marginal Total 1 (totA)    1      NA
#> 4  <NA> totA Marginal Total 1 (totA)   -1      NA
#> 5    EQ <NA> Marginal Total 2 (totB)   NA      NA
#> 6  <NA>   B1 Marginal Total 2 (totB)    1      NA
#> 7  <NA>   B2 Marginal Total 2 (totB)    1      NA
#> 8  <NA> totB Marginal Total 2 (totB)   -1      NA
#> 9    EQ <NA> Marginal Total 3 (tot1)   NA      NA
#> 10 <NA>   A1 Marginal Total 3 (tot1)    1      NA
#> 11 <NA>   B1 Marginal Total 3 (tot1)    1      NA
#> 12 <NA> tot1 Marginal Total 3 (tot1)   -1      NA
#> 13   EQ <NA> Marginal Total 4 (tot2)   NA      NA
#> 14 <NA>   A2 Marginal Total 4 (tot2)    1      NA
#> 15 <NA>   B2 Marginal Total 4 (tot2)    1      NA
#> 16 <NA> tot2 Marginal Total 4 (tot2)   -1      NA

# Avec un fichier de coefficients d'altérabilité (argument `alterability_df`)
mes_coefsAlt = data.frame(B2 = 0.5)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterability_df = mes_coefsAlt))
#>    type  col                       row coef timeVal
#> 20 <NA>   B1 Period Value Alterability  1.0      NA
#> 21 <NA>   B2 Period Value Alterability  0.5      NA
#> 22 <NA> totA Period Value Alterability  0.0      NA
#> 23 <NA> totB Period Value Alterability  0.0      NA
#> 24 <NA> tot1 Period Value Alterability  0.0      NA
#> 25 <NA> tot2 Period Value Alterability  0.0      NA

# N'inclure que les coefficients d'altérabilité du fichier `alterability_df` 
# (c.-à-d. pour la colonne `B2`)
tail(
  rkMeta_to_blSpecs(
    mes_metadonnees, alterability_df = mes_coefsAlt,
    alterability_df_only = TRUE
  )
)
#>     type  col                       row coef timeVal
#> 13    EQ <NA>   Marginal Total 4 (tot2)   NA      NA
#> 14  <NA>   A2   Marginal Total 4 (tot2)  1.0      NA
#> 15  <NA>   B2   Marginal Total 4 (tot2)  1.0      NA
#> 16  <NA> tot2   Marginal Total 4 (tot2) -1.0      NA
#> 17 alter <NA> Period Value Alterability   NA      NA
#> 18  <NA>   B2 Period Value Alterability  0.5      NA
```
