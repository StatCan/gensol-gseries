# Convertir un objet « ts » en *data frame* de séries chronologiques

Convertir un objet « ts  » (ou « mts ») en un *data frame* de séries
chronologiques pour les fonctions d'étalonnage avec trois variables
(colonnes) ou plus :

- deux (2) pour l'identification du point de données (année et période)

- une (1) pour chaque série chronologique

Pour des étalons discrets (points d'ancrage couvrant une seule période
de la série indicatrice, par exemple, des stocks de fin d'année),
spécifiez `discrete_flag = TRUE` et `alignment = "b"`, `"e"` ou `"m"`.

## Utilisation

``` r
ts_to_tsDF(
  in_ts,
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value"
)
```

## Arguments

- in_ts:

  (obligatoire)

  Objet de type série chronologique (classe « ts » ou « mts ») à
  convertir.

- yr_cName, per_cName:

  (optionnel)

  Chaînes de caractères spécifiant le nom des variables (colonnes)
  numériques dans le *data frame* de sortie qui contiendront les
  identificateurs d'année et de période du point de données.

  **Les valeurs par défaut** sont `yr_cName = "year"` et
  `per_cName = "period"`.

- val_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne) dans
  le *data frame* de sortie qui contiendra les valeurs des points de
  données. Cet argument n'a aucun effet pour les objets « mts » (les
  noms des variables de données des séries chronologiques sont
  automatiquement hérités de l'objet « mts »).

  **La valeur par défaut** est `val_cName = "value"`.

## Valeur de retour

La fonction renvoie un *data frame* avec trois variables ou plus :

- Année du point de données, type numérique (voir argument `yr_cName`)

- Période du point de données, type numérique (voir argument
  `per_cName`)

- Valeur du point de données, type numérique (voir argument `val_cName`)

- Une (objet « ts ») ou plusieurs (objet « mts ») variable(s) de données
  de série(s) chronologique(s), type numérique (voir argument
  `val_cName`)

Note : la fonction renvoie un objet « data.frame » qui peut être
explicitement converti en un autre type d'objet avec la fonction `as*()`
appropriée (ex.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
le convertirait en tibble).

## Voir également

[`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsDF_to_ts.md)
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_bmkDF.md)
[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_tsDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
[time_values_conv](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)

## Exemples

``` r
# Série chronologique Quarterly time series
ma_sc <- ts(1:10 * 100, start = 2019, frequency = 4)
ma_sc
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2019  100  200  300  400
#> 2020  500  600  700  800
#> 2021  900 1000          


# Noms de variables (colonnes) par défaut
ts_to_tsDF(ma_sc)
#>    year period value
#> 1  2019      1   100
#> 2  2019      2   200
#> 3  2019      3   300
#> 4  2019      4   400
#> 5  2020      1   500
#> 6  2020      2   600
#> 7  2020      3   700
#> 8  2020      4   800
#> 9  2021      1   900
#> 10 2021      2  1000

# Nom personnalisé pour la variable (colonne) des étalons
ts_to_tsDF(ma_sc, val_cName = "ser_val")
#>    year period ser_val
#> 1  2019      1     100
#> 2  2019      2     200
#> 3  2019      3     300
#> 4  2019      4     400
#> 5  2020      1     500
#> 6  2020      2     600
#> 7  2020      3     700
#> 8  2020      4     800
#> 9  2021      1     900
#> 10 2021      2    1000


# Séries chronologiques multiples: argument `val_cName` ignoré
# (les noms de colonnes de l'object « mts » sont toujours utilisés)
ts_to_tsDF(
  ts.union(ser1 = ma_sc, ser2 = ma_sc / 10),
  val_cName = "nom_de_colonne_inutile"
)
#>    year period ser1 ser2
#> 1  2019      1  100   10
#> 2  2019      2  200   20
#> 3  2019      3  300   30
#> 4  2019      4  400   40
#> 5  2020      1  500   50
#> 6  2020      2  600   60
#> 7  2020      3  700   70
#> 8  2020      4  800   80
#> 9  2021      1  900   90
#> 10 2021      2 1000  100
```
