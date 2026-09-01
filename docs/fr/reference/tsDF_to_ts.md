# Fonction réciproque de [`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md)

Convertir un *data frame* (non empilé) de séries chronologiques (format
de données de
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
et
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md))
en un objet « ts » (ou « mts »).

Cette fonction est utile pour convertir le *data frame* renvoyé par un
appel à
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
ou
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
en un objet « ts », où une ou plusieurs séries ont été étalonnées en
mode de traitement *non groupes-BY*. Les *data frame* empilés de séries
chronologiques associées à des exécutions en mode *groupes-BY* doivent
d'abord être *désempilés* avec
[`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/unstack_tsDF.md).

## Utilisation

``` r
tsDF_to_ts(
  ts_df,
  frequency,
  yr_cName = "year",
  per_cName = "period"
)
```

## Arguments

- ts_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») à convertir.

- frequency:

  (obligatoire)

  Entier spécifiant la fréquence de la (des) série(s) à convertir. La
  fréquence d'une série chronologique correspond au nombre maximum de
  périodes dans une année (par exemple, 12 pour des données mensuelles,
  4 pour des données trimestrielles, 1 pour des données annuelles).

- yr_cName, per_cName:

  (optionnel)

  Chaînes de caractères spécifiant le nom des variables (colonnes)
  numériques dans le *data frame* d'entrée qui contiennent les
  identificateurs d'année et de période du point de données.

  **Les valeurs par défaut** sont `yr_cName = "year"` et
  `per_cName = "period"`.

## Valeur de retour

La fonction renvoie un objet de type série chronologique (classe « ts »
ou « mts »), qui peut être explicitement converti en un autre type
d'objet avec la fonction `as*()` appropriée (ex.,
`tsibble::as_tsibble()` le convertirait en tsibble).

## Voir également

[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md)
[`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/unstack_tsDF.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

## Exemples

``` r
# Série chronologique trimestrielle initiale (série indicatrice à étalonner)
sc_tri <- ts(
  c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3),
  start = c(2015, 1), frequency = 4
)

# Série chronologique annuelle (étalons)
sc_ann <- ts(c(10.3, 10.2), start = 2015, frequency = 1)


# Étalonnage proportionnel
res_eta <- benchmarking(
  ts_to_tsDF(sc_tri),
  ts_to_bmkDF(sc_ann, ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE
)

# Séries chronologiques initiale et finale (étalonnée) - objects « ts » 
sc_tri
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2015  1.9  2.4  3.1  2.2
#> 2016  2.0  2.6  3.4  2.4
#> 2017  2.3               
tsDF_to_ts(res_eta$series, frequency = 4)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2015 2.049326 2.601344 3.337638 2.311691
#> 2016 2.021090 2.554801 3.292193 2.331915
#> 2017 2.268017                           


# Étalonnage proportionnel de stocks de fin d'année - plusieurs (3) séries 
# traitées avec l'argument `by` (en mode groupes-BY)
sc_tri2 <- ts.union(ser1 = sc_tri,     ser2 = sc_tri * 100, ser3 = sc_tri * 10)
sc_ann2 <- ts.union(ser1 = sc_ann / 4, ser2 = sc_ann * 25,  ser3 = sc_ann * 2.5)
res_eta2 <- stock_benchmarking(
  stack_tsDF(ts_to_tsDF(sc_tri2)),
  stack_bmkDF(ts_to_bmkDF(
    sc_ann2, ind_frequency = 4,
    discrete_flag = TRUE, alignment = "e")
  ),
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

# Séries chronologiques initiales et finales (étalonnées) - objects « mts » 
sc_tri2
#>         ser1 ser2 ser3
#> 2015 Q1  1.9  190   19
#> 2015 Q2  2.4  240   24
#> 2015 Q3  3.1  310   31
#> 2015 Q4  2.2  220   22
#> 2016 Q1  2.0  200   20
#> 2016 Q2  2.6  260   26
#> 2016 Q3  3.4  340   34
#> 2016 Q4  2.4  240   24
#> 2017 Q1  2.3  230   23
tsDF_to_ts(unstack_tsDF(res_eta2$series), frequency = 4)
#>             ser1     ser2     ser3
#> 2015 Q1 2.172021 217.2021 21.72021
#> 2015 Q2 2.784446 278.4446 27.84446
#> 2015 Q3 3.633922 363.3922 36.33922
#> 2015 Q4 2.575000 257.5000 25.75000
#> 2016 Q1 2.298694 229.8694 22.98694
#> 2016 Q2 2.903718 290.3718 29.03718
#> 2016 Q3 3.685986 368.5986 36.85986
#> 2016 Q4 2.550000 255.0000 25.50000
#> 2017 Q1 2.437793 243.7793 24.37793
```
