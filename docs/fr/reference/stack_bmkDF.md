# Empiler des « données étalon »

Convertir un *data frame* d'étalons multivariés (voir
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_bmkDF.md))
pour les fonctions d'étalonnage
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
et
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md))
en un *data frame* empilé (long) avec six variables (colonnes) :

- une (1) pour le nom de l'étalon (ex., nom de série)

- quatre (4) pour la converture de l'étalon

- une (1) pour la valeur de l'étalon

Les valeurs d'étalon manquantes (`NA`) ne sont pas incluses par défaut
dans le *data frame* empilé renvoyé par la fonction. Spécifiez
l'argument `keep_NA = TRUE` pour les conserver.

Cette fonction est utile lorsque l'on souhaite utiliser l'argument `by`
(mode de traitement *groupes-BY*) des fonctions d'étalonnage afin
d'étalonner plusieurs séries en un seul appel de fonction.

## Utilisation

``` r
stack_bmkDF(
  bmk_df,
  ser_cName = "series",
  startYr_cName = "startYear",
  startPer_cName = "startPeriod",
  endYr_cName = "endYear",
  endPer_cName = "endPeriod",
  val_cName = "value",
  keep_NA = FALSE
)
```

## Arguments

- bmk_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») qui contient les
  étalons multivariés à empiler.

- ser_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne) du
  *data frame* empilé de sortie qui contiendra les nom des étalons (nom
  des variables d'étalons dans le *data frame* d'étalons multivariés
  d'entrée). Cette variable peut ensuite être utilisée comme variable de
  groupes-BY (argument `by`) avec les fonctions d'étalonnage.

  **La valeur par défaut** est `ser_cName = "series"`.

- startYr_cName, startPer_cName, endYr_cName, endPer_cName:

  (optionnel)

  Chaînes de caractères spécifiant le nom des variables (colonnes)
  numériques du *data frame* d'étalons multivariés d'entrée qui
  définissent la couverture des étalons, c'est-à-dire les
  identificateurs de l'année et de la période (cycle) de début et de fin
  des étalons. Ces variables sont *transférées* dans le *data frame*
  empilé de sortie avec les mêmes noms de variable.

  **Les valeurs par défaut** sont `startYr_cName = "startYear"`,
  `startPer_cName = "startPeriod"` `endYr_cName = "endYear"` et
  `endPer_Name = "endPeriod"`.

- val_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne) du
  *data frame* empilé de sortie qui contiendra les valeurs des étalons.

  **La valeur par défaut** est `val_cName = "value"`.

- keep_NA:

  (optionnel)

  Argument logique (*logical*) spécifiant si les valeurs d'étalon
  manquantes (`NA`) du *data frame* d'étalons multivariés d'entrée
  doivent être conservées dans le *data frame* empilé de sortie.

  **La valeur par défaut** est `keep_NA = FALSE`.

## Valeur de retour

La fonction renvoie un *data frame* avec six variables :

- Nom de l'étalon (de la série), type caractère (voir l'argument
  `ser_cName`)

- Année de début de la couverture de l'étalon, type numérique (voir
  argument `startYr_cName`)

- Période de début de la couverture de l'étalon, type numérique (voir
  argument `startPer_cName`)

- Année de fin de la couverture de l'étalon, type numérique (voir
  argument `endtYr_cName`)

- Période de fin de la couverture de l'étalon, type numérique (voir
  argument `endPer_cName`)

- Valeur de l'étalon, type numérique (voir argument `val_cName`)

Note : la fonction renvoie un objet « data.frame » qui peut être
explicitement converti en un autre type d'objet avec la fonction `as*()`
appropriée (ex.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
le convertirait en tibble).

## Voir également

[`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_tsDF.md)
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_bmkDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

## Exemples

``` r
# Créer un « data frame » d'étalons annuels pour 2 séries indicatrices trimestrielles 
# (avec des valeurs manquantes pour les étalons des 2 dernières années)
mes_etalons <- ts_to_bmkDF(
  ts(
    data.frame(
      ser1 = c(1:3 *  10, NA, NA), 
      ser2 = c(1:3 * 100, NA, NA)
    ), 
    start = c(2019, 1), frequency = 1
  ),
  ind_frequency = 4
)
mes_etalons
#>   startYear startPeriod endYear endPeriod ser1 ser2
#> 1      2019           1    2019         4   10  100
#> 2      2020           1    2020         4   20  200
#> 3      2021           1    2021         4   30  300
#> 4      2022           1    2022         4   NA   NA
#> 5      2023           1    2023         4   NA   NA


# Empiler les étalons ...

# en rejetant les `NA` dans les données empilées (comportement par défaut)
stack_bmkDF(mes_etalons)
#>   series startYear startPeriod endYear endPeriod value
#> 1   ser1      2019           1    2019         4    10
#> 2   ser1      2020           1    2020         4    20
#> 3   ser1      2021           1    2021         4    30
#> 4   ser2      2019           1    2019         4   100
#> 5   ser2      2020           1    2020         4   200
#> 6   ser2      2021           1    2021         4   300

# en conservant les `NA` dans les données empilées
stack_bmkDF(mes_etalons, keep_NA = TRUE)
#>    series startYear startPeriod endYear endPeriod value
#> 1    ser1      2019           1    2019         4    10
#> 2    ser1      2020           1    2020         4    20
#> 3    ser1      2021           1    2021         4    30
#> 4    ser1      2022           1    2022         4    NA
#> 5    ser1      2023           1    2023         4    NA
#> 6    ser2      2019           1    2019         4   100
#> 7    ser2      2020           1    2020         4   200
#> 8    ser2      2021           1    2021         4   300
#> 9    ser2      2022           1    2022         4    NA
#> 10   ser2      2023           1    2023         4    NA

# en utilisant des noms de variables (colonnes) personnalisés
stack_bmkDF(mes_etalons, ser_cName = "nom_eta", val_cName = "val_eta")
#>   nom_eta startYear startPeriod endYear endPeriod val_eta
#> 1    ser1      2019           1    2019         4      10
#> 2    ser1      2020           1    2020         4      20
#> 3    ser1      2021           1    2021         4      30
#> 4    ser2      2019           1    2019         4     100
#> 5    ser2      2020           1    2020         4     200
#> 6    ser2      2021           1    2021         4     300
```
