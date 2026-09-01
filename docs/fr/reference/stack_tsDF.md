# Empiler des données de séries chronologiques

Convertir un *data frame* de séries chronologiques multivariées (voir
[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md))
pour les fonctions d'étalonnage
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
et
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md))
en un *data frame* empilé (long) avec quatre variables (colonnes) :

- une (1) pour le nom de la série

- deux (2) pour l'identification du point de données (année et période)

- une (1) pour la valeur du point de données

Les valeurs de série manquantes (`NA`) ne sont pas incluses par défaut
dans le *data frame* empilé renvoyé par la fonction. Spécifiez
l'argument `keep_NA = TRUE` pour les conserver.

Cette fonction est utile lorsque l'on souhaite utiliser l'argument `by`
(mode de traitement *groupes-BY*) des fonctions d'étalonnage afin
d'étalonner plusieurs séries en un seul appel de fonction.

## Utilisation

``` r
stack_tsDF(
  ts_df,
  ser_cName = "series",
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value",
  keep_NA = FALSE
)
```

## Arguments

- ts_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») qui contient les
  données de séries chronologiques multivariées à empiler.

- ser_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne) du
  *data frame* empilé de sortie qui contiendra les nom des séries (nom
  des variables des séries dans le *data frame* de séries chronologiques
  multivariées d'entrée). Cette variable peut ensuite être utilisée
  comme variable de groupes-BY (argument `by`) avec les fonctions
  d'étalonnage.

  **La valeur par défaut** est `ser_cName = "series"`.

- yr_cName, per_cName:

  (optionnel)

  Chaînes de caractères spécifiant le nom des variables (colonnes)
  numériques du *data frame* de séries chronologiques multivariées
  d'entrée qui identifient l'année et la période (cycle) des points de
  données. Ces variables sont *transférées* dans le *data frame* empilé
  de sortie avec les mêmes noms de variable.

  **Les valeurs par défaut** sont `yr_cName = "year"` et
  `per_cName = "period"`.

- val_cName:

  (optionnel)

  Chaîne de caractères spécifiant le nom de la variable (colonne) du
  *data frame* empilé de sortie qui contiendra la valeur des points de
  données.

  **La valeur par défaut** est `val_cName = "value"`.

- keep_NA:

  (optionnel)

  Argument logique (*logical*) spécifiant si les valeurs de série
  manquantes (`NA`) du *data frame* de séries chronologiques
  multivariées d'entrée doivent être conservées dans le *data frame*
  empilé de sortie.

  **La valeur par défaut** est `keep_NA = FALSE`.

## Valeur de retour

La fonction renvoie un *data frame* avec quatre variables :

- Nom de la série, type caractère (voir l'argument `ser_cName`)

- Année du point de données, type numérique (voir argument `yr_cName`)

- Période du point de données, type numérique (voir argument
  `per_cName`)

- Valeur du point de données, type numérique (voir argument `val_cName`)

Note : la fonction renvoie un objet « data.frame » qui peut être
explicitement converti en un autre type d'objet avec la fonction `as*()`
appropriée (ex.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
le convertirait en tibble).

## Voir également

[`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/unstack_tsDF.md)
[`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_bmkDF.md)
[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

## Exemples

``` r
# Créer un « data frame » de 2 séries indicatrices trimestrielles
# (avec des valeurs manquantes pour les 2 dernières trimestres)
mes_indicateurs <- ts_to_tsDF(
  ts(
    data.frame(
      ser1 = c(1:5 *  10, NA, NA),
      ser2 = c(1:5 * 100, NA, NA)
    ), 
    start = c(2019, 1), frequency = 4
  )
)
mes_indicateurs
#>   year period ser1 ser2
#> 1 2019      1   10  100
#> 2 2019      2   20  200
#> 3 2019      3   30  300
#> 4 2019      4   40  400
#> 5 2020      1   50  500
#> 6 2020      2   NA   NA
#> 7 2020      3   NA   NA


# Empiler les séries indicatrices ...

# en rejetant les `NA` dans les données empilées (comportement par défaut)
stack_tsDF(mes_indicateurs)
#>    series year period value
#> 1    ser1 2019      1    10
#> 2    ser1 2019      2    20
#> 3    ser1 2019      3    30
#> 4    ser1 2019      4    40
#> 5    ser1 2020      1    50
#> 6    ser2 2019      1   100
#> 7    ser2 2019      2   200
#> 8    ser2 2019      3   300
#> 9    ser2 2019      4   400
#> 10   ser2 2020      1   500

# en conserver les `NA` dans les données empilées
stack_tsDF(mes_indicateurs, keep_NA = TRUE)
#>    series year period value
#> 1    ser1 2019      1    10
#> 2    ser1 2019      2    20
#> 3    ser1 2019      3    30
#> 4    ser1 2019      4    40
#> 5    ser1 2020      1    50
#> 6    ser1 2020      2    NA
#> 7    ser1 2020      3    NA
#> 8    ser2 2019      1   100
#> 9    ser2 2019      2   200
#> 10   ser2 2019      3   300
#> 11   ser2 2019      4   400
#> 12   ser2 2020      1   500
#> 13   ser2 2020      2    NA
#> 14   ser2 2020      3    NA

# en utilisant des noms de variables (colonnes) personnalisés
stack_tsDF(mes_indicateurs, ser_cName = "nom_ind", val_cName = "val_ind")
#>    nom_ind year period val_ind
#> 1     ser1 2019      1      10
#> 2     ser1 2019      2      20
#> 3     ser1 2019      3      30
#> 4     ser1 2019      4      40
#> 5     ser1 2020      1      50
#> 6     ser2 2019      1     100
#> 7     ser2 2019      2     200
#> 8     ser2 2019      3     300
#> 9     ser2 2019      4     400
#> 10    ser2 2020      1     500
```
