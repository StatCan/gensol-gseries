# Convertir un objet « ts » en *data frame* d'étalons

Convertir un objet « ts  » (ou « mts ») en un *data frame* d'étalons
pour les fonctions d'étalonnage avec cinq variables (colonnes) ou plus :

- quatre (4) pour la converture de l'étalon

- une (1) pour chaque série chronologique d'étalons

Pour des étalons discrets (points d'ancrage couvrant une seule période
de la série indicatrice, par exemple, des stocks de fin d'année),
spécifiez `discrete_flag = TRUE` et `alignment = "b"`, `"e"` ou `"m"`.

## Utilisation

``` r
ts_to_bmkDF(
  in_ts,
  ind_frequency,
  discrete_flag = FALSE,
  alignment = "b",
  bmk_interval_start = 1,
  startYr_cName = "startYear",
  startPer_cName = "startPeriod",
  endYr_cName = "endYear",
  endPer_cName = "endPeriod",
  val_cName = "value"
)
```

## Arguments

- in_ts:

  (obligatoire)

  Objet de type série chronologique (classe « ts » ou « mts ») à
  convertir.

- ind_frequency:

  (obligatoire)

  Entier spécifiant la fréquence de la série indicatrice (haute
  fréquence) à laquelle les étalons (séries de basse fréquence) sont
  liés. La fréquence d'une série chronologique correspond au nombre
  maximum de périodes dans une année (par exemple, 12 pour des données
  mensuelles, 4 pour des données trimestrielles, 1 pour des données
  annuelles).

- discrete_flag:

  (optionnel)

  Argument logique (*logical*) précisant si les étalons correspondent à
  des valeurs discrètes (points d'ancrage couvrant une seule période de
  la série indicatrice, par exemple des stocks de fin d'année) ou non.
  `discrete_flag = FALSE` définit des étalons non discrets, c'est-à-dire
  des étalons qui couvrent plusieurs périodes de la série indicatrice
  (par exemple, des étalons annuels couvrent 4 trimestres ou 12 mois,
  des étalons trimestriels couvrent 3 mois, etc.).

  **La valeur par défaut** est `discrete_flag = FALSE`.

- alignment:

  (optionnel)

  Caractère identifiant l'alignement des étalons discrets (argument
  `discrete_flag = TRUE`) dans la fenêtre de couverture de l'intervalle
  de l'étalon (série de basse fréquence) :

  - `alignment = "b"` : début de la fenêtre de l'intervalle de l'étalon
    (première période)

  - `alignment = "e"` : fin de la fenêtre de l'intervalle de l'étalon
    (dernière période)

  - `alignment = "m"` : milieu de la fenêtre de l'intervalle de l'étalon
    (période du milieu)

  Cet argument n'a pas d'effet pour les étalons non discrets
  (`discrete_flag = FALSE`).

  **La valeur par défaut** est `alignment = "b"`.

- bmk_interval_start:

  (optionnel)

  Entier dans l'intervalle \[1 .. `ind_frequency`\] spécifiant la
  période (cycle) de la série indicatrice (haute fréquence) à laquelle
  commence la fenêtre de l'intervalle de l'étalon (série de basse
  fréquence). Par exemple, des étalons annuels correspondant à des
  années financières définies d'avril à mars de l'année suivante
  seraient spécifiés avec `bmk_interval_start = 4` pour une série
  indicatrice mensuelle (`ind_frequency = 12`) et
  `bmk_interval_start = 2` pour une série indicatrice trimestrielle
  (`ind_frequency = 4`).

  **La valeur par défaut** est `bmk_interval_start = 1`.

- startYr_cName, startPer_cName, endYr_cName, endPer_cName:

  (optionnel)

  Chaînes de caractères spécifiant le nom des variables (colonnes)
  numériques dans le *data frame* de sortie qui définiront la couverture
  des étalons, c'est-à-dire les identificateurs de l'année et de la
  période de début et de fin des étalons.

  **Les valeurs par défaut** sont `startYr_cName = "startYear"`,
  `startPer_cName = "startPeriod"` `endYr_cName = "endYear"` et
  `endPer_Name = "endPeriod"`.

- val_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne) dans
  le *data frame* de sortie qui contiendra les valeurs des étalons. Cet
  argument n'a aucun effet pour les objets « mts » (les noms des
  variables d'étalons sont automatiquement hérités de l'objet « mts »).

  **La valeur par défaut** est `val_cName = "value"`.

## Valeur de retour

La fonction renvoie un *data frame* avec cinq variables ou plus :

- Année de début de la couverture de l'étalon, type numérique (voir
  argument `startYr_cName`)

- Période de début de la couverture de l'étalon, type numérique (voir
  argument `startPer_cName`)

- Année de fin de la couverture de l'étalon, type numérique (voir
  argument `endYr_cName`)

- Période de fin de la couverture de l'étalon, type numérique (voir
  argument `endPer_cName`)

- Une (objet « ts ») ou plusieurs (objet « mts ») variable(s) de données
  d'étalons, type numérique (voir argument `val_cName`)

Note : la fonction renvoie un objet « data.frame » qui peut être
explicitement converti en un autre type d'objet avec la fonction `as*()`
appropriée (ex.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
le convertirait en tibble).

## Voir également

[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md)
[`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_bmkDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
[time_values_conv](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)

## Exemples

``` r
# Séries chronologiques annuelle et trimestrielle
ma_sc_ann <- ts(1:5 * 100, start = 2019, frequency = 1)
ma_sc_ann
#> Time Series:
#> Start = 2019 
#> End = 2023 
#> Frequency = 1 
#> [1] 100 200 300 400 500
ma_sc_tri <- ts(1:5 * 10, start = c(2019, 1), frequency = 4)
ma_sc_tri
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2019   10   20   30   40
#> 2020   50               


# Étalons annuels pour des séries indicatrices mensuelles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 12)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           1    2019        12   100
#> 2      2020           1    2020        12   200
#> 3      2021           1    2021        12   300
#> 4      2022           1    2022        12   400
#> 5      2023           1    2023        12   500

# Étalons annuels pour des série indicatrices trimestrielles
ts_to_bmkDF(ma_sc_ann, ind_frequency = 4)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           1    2019         4   100
#> 2      2020           1    2020         4   200
#> 3      2021           1    2021         4   300
#> 4      2022           1    2022         4   400
#> 5      2023           1    2023         4   500

# Étalons trimestriels pour des séries indicatrices mensuelles
ts_to_bmkDF(ma_sc_tri, ind_frequency = 12)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           1    2019         3    10
#> 2      2019           4    2019         6    20
#> 3      2019           7    2019         9    30
#> 4      2019          10    2019        12    40
#> 5      2020           1    2020         3    50

# Stocks de début d'année pour des séries indicatrices trimestrielles
ts_to_bmkDF(
  ma_sc_ann, ind_frequency = 4,
  discrete_flag = TRUE
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           1    2019         1   100
#> 2      2020           1    2020         1   200
#> 3      2021           1    2021         1   300
#> 4      2022           1    2022         1   400
#> 5      2023           1    2023         1   500

# Stocks de fin de trimestre pour des séries indicatrices mensuelles
ts_to_bmkDF(
  ma_sc_tri, ind_frequency = 12,
  discrete_flag = TRUE, alignment = "e"
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           3    2019         3    10
#> 2      2019           6    2019         6    20
#> 3      2019           9    2019         9    30
#> 4      2019          12    2019        12    40
#> 5      2020           3    2020         3    50

# Étalons annuels (avril à mars) pour des séries indicatrices ...
# ... mensuelles
ts_to_bmkDF(
  ma_sc_ann, ind_frequency = 12,
  bmk_interval_start = 4
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           4    2020         3   100
#> 2      2020           4    2021         3   200
#> 3      2021           4    2022         3   300
#> 4      2022           4    2023         3   400
#> 5      2023           4    2024         3   500
# ... trimestrielles
ts_to_bmkDF(
  ma_sc_ann, ind_frequency = 4,
  bmk_interval_start = 2
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2019           2    2020         1   100
#> 2      2020           2    2021         1   200
#> 3      2021           2    2022         1   300
#> 4      2022           2    2023         1   400
#> 5      2023           2    2024         1   500

# Stocks de fin d'année (avril à mars) pour des séries indicatrices ...
# ... mensuelles
ts_to_bmkDF(
  ma_sc_ann, ind_frequency = 12,
  discrete_flag = TRUE, alignment = "e", bmk_interval_start = 4
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2020           3    2020         3   100
#> 2      2021           3    2021         3   200
#> 3      2022           3    2022         3   300
#> 4      2023           3    2023         3   400
#> 5      2024           3    2024         3   500
# ... trimestrielles
ts_to_bmkDF(
  ma_sc_ann, ind_frequency = 4,
  discrete_flag = TRUE, alignment = "e", bmk_interval_start = 2
)
#>   startYear startPeriod endYear endPeriod value
#> 1      2020           1    2020         1   100
#> 2      2021           1    2021         1   200
#> 3      2022           1    2022         1   300
#> 4      2023           1    2023         1   400
#> 5      2024           1    2024         1   500

# Nom personnalisé pour la variable (colonne) des étalons
ts_to_bmkDF(
  ma_sc_ann, ind_frequency = 12,
  val_cName = "eta_val"
)
#>   startYear startPeriod endYear endPeriod eta_val
#> 1      2019           1    2019        12     100
#> 2      2020           1    2020        12     200
#> 3      2021           1    2021        12     300
#> 4      2022           1    2022        12     400
#> 5      2023           1    2023        12     500

# Séries chronologiques multiples: argument `val_cName` ignoré
# (les noms des colonnes de l'object « mts » sont toujours utilisés)
ts_to_bmkDF(
  ts.union(ser1 = ma_sc_ann, ser2 = ma_sc_ann / 10), ind_frequency = 12,
  val_cName = "nom_de_colonne_inutile"
)
#>   startYear startPeriod endYear endPeriod ser1 ser2
#> 1      2019           1    2019        12  100   10
#> 2      2020           1    2020        12  200   20
#> 3      2021           1    2021        12  300   30
#> 4      2022           1    2022        12  400   40
#> 5      2023           1    2023        12  500   50
```
