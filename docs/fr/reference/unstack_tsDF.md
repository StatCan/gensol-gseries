# Fonction réciproque de [`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_tsDF.md)

Convertir un *data frame* empilé (long) de séries chronologiques
multivariées (format de données de
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
et
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md))
en un *data frame* non empilé (large) de séries chronologiques
multivariées.

Cette fonction, combinée avec
[`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsDF_to_ts.md),
est utile pour convertir le *data frame* renvoyé par un appel à
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
ou
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
en un objet « mts », où plusieurs séries ont été étalonnées en mode de
traitement *groupes-BY*.

## Utilisation

``` r
unstack_tsDF(
  ts_df,
  ser_cName = "series",
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value"
)
```

## Arguments

- ts_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») contenant les données
  de séries chronologiques multivariées à *désempiler*.

- ser_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne) dans
  le *data frame* d'entrée qui contient le nom des séries chronologiques
  (nom des variables des séries chronologiques dans le *data frame* de
  sortie).

  **La valeur par défaut** est `ser_cName = "series"`.

- yr_cName, per_cName:

  (optionnel)

  Chaînes de caractères spécifiant le nom des variables (colonnes)
  numériques dans le *data frame* d'entrée qui identifient l'année et la
  période des points de données. Ces variables sont *transférées* dans
  le *data frame* de sortie avec les mêmes noms de variable.

  **Les valeurs par défaut** sont `yr_cName = "year"` et
  `per_cName = "period"`.

- val_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne)
  numérique dans le *data frame* d'entrée qui contient la valeur des
  points de données.

  **La valeur par défaut** est `val_cName = "value"`.

## Valeur de retour

La fonction renvoie un *data frame* avec trois variables ou plus :

- Année du point de données, type numérique (voir argument `yr_cName`)

- Période du point de données, type numérique (voir argument
  `per_cName`)

- Une variable de données de série chronologique pour chaque valeur
  distincte de la variable du *data frame* d'entrée spécifiée avec
  l'argument `ser_cName`, type numérique (voir arguments `ser_cName` et
  `val_cName`)

Note : la fonction renvoie un objet « data.frame » qui peut être
explicitement converti en un autre type d'objet avec la fonction `as*()`
appropriée (ex.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
le convertirait en tibble).

## Voir également

[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_tsDF.md)
[`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsDF_to_ts.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

## Exemples

``` r
# Étalonnage proportionnel pour plusieurs (3) séries trimestrielles traitées avec 
# l'argument `by` (en mode groupes-BY)

vec_ind <- c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3)
df_ind <- ts_to_tsDF(
  ts(
    data.frame(
      ser1 = vec_ind,
      ser2 = vec_ind * 100,
      ser3 = vec_ind * 10
    ),
    start = c(2015, 1), frequency = 4
  )
)

vec_eta <- c(10.3, 10.2)
df_eta <- ts_to_bmkDF(
  ts(
    data.frame(
      ser1 = vec_eta,
      ser2 = vec_eta * 100,
      ser3 = vec_eta * 10
    ), 
    start = 2015, frequency = 1
  ),
  ind_frequency = 4
)

res_eta <- benchmarking(
  stack_tsDF(df_ind),
  stack_bmkDF(df_eta),
  rho = 0.729, lambda = 1, biasOption = 3,
  by = "series",
  quiet = TRUE
)
#> 
#> Benchmarking by-group 1 (series=ser1)
#> =====================================
#> 
#> Benchmarking by-group 2 (series=ser2)
#> =====================================
#> 
#> Benchmarking by-group 3 (series=ser3)
#> =====================================

# « Data frame » des séries chronologiques initiales et finales (étalonnés)
df_ind
#>   year period ser1 ser2 ser3
#> 1 2015      1  1.9  190   19
#> 2 2015      2  2.4  240   24
#> 3 2015      3  3.1  310   31
#> 4 2015      4  2.2  220   22
#> 5 2016      1  2.0  200   20
#> 6 2016      2  2.6  260   26
#> 7 2016      3  3.4  340   34
#> 8 2016      4  2.4  240   24
#> 9 2017      1  2.3  230   23
unstack_tsDF(res_eta$series)
#>   year period     ser1     ser2     ser3
#> 1 2015      1 2.049326 204.9326 20.49326
#> 2 2015      2 2.601344 260.1344 26.01344
#> 3 2015      3 3.337638 333.7638 33.37638
#> 4 2015      4 2.311691 231.1691 23.11691
#> 5 2016      1 2.021090 202.1090 20.21090
#> 6 2016      2 2.554801 255.4801 25.54801
#> 7 2016      3 3.292193 329.2193 32.92193
#> 8 2016      4 2.331915 233.1915 23.31915
#> 9 2017      1 2.268017 226.8017 22.68017
```
