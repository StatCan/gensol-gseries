# Fonctions de conversion de valeurs de temps

Fonctions de conversion de valeurs de temps utilisées à l'interne par
d'autres fonctions de gseries.

## Utilisation

``` r
gs.time2year(ts)

gs.time2per(ts)

gs.time2str(ts, sep = "-")
```

## Arguments

- ts:

  (obligatoire)

  Objet de type série chronologique (classe « ts » ou « mts »).

- sep:

  (optionnel)

  Chaîne de caractères (constante de type caractère) spécifiant le
  séparateur à utiliser entre les valeurs d'année et de période.

  **La valeur par défaut** est `sep = "-"`.

## Valeur de retour

`gs.time2year()` renvoie un vecteur de nombres entiers correspondant à
l'année (l'unité de temps) « la plus proche ». Cette fonction est
l'équivalent de [`stats::cycle()`](https://rdrr.io/r/stats/time.html)
pour les valeurs d'unités de temps.

`gs.time2per()` renvoie un vecteur de nombres entiers contenant les
valeurs des périodes (les cycles ; voir
[`stats::cycle()`](https://rdrr.io/r/stats/time.html))).

`gs.time2str()` renvoie un vecteur de chaînes de caractères
correspondant à `gs.time2year(ts)` lorsque `stats::frequency(ts) == 1`
ou à `gs.time2year(ts)` et `gs.time2per(ts)` séparé par `sep` dans le
cas contraire.

## Voir également

[`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md)
[`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_bmkDF.md)
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.build_proc_grps.md)

## Exemples

``` r
# Série chronologique mensuelle « bidon »
sc_men <- ts(rep(NA, 15), start = c(2019, 1), frequency = 12)
sc_men
#>      Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#> 2019  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#> 2020  NA  NA  NA                                    
gs.time2year(sc_men)
#>  [1] 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2020 2020 2020
gs.time2per(sc_men)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12  1  2  3
gs.time2str(sc_men)
#>  [1] "2019-1"  "2019-2"  "2019-3"  "2019-4"  "2019-5"  "2019-6"  "2019-7" 
#>  [8] "2019-8"  "2019-9"  "2019-10" "2019-11" "2019-12" "2020-1"  "2020-2" 
#> [15] "2020-3" 
gs.time2str(sc_men, sep = "m")
#>  [1] "2019m1"  "2019m2"  "2019m3"  "2019m4"  "2019m5"  "2019m6"  "2019m7" 
#>  [8] "2019m8"  "2019m9"  "2019m10" "2019m11" "2019m12" "2020m1"  "2020m2" 
#> [15] "2020m3" 

# Série chronologique trimestrielle « bidon »
sc_tri <- ts(rep(NA, 5), start = c(2019, 1), frequency = 4)
sc_tri
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2019   NA   NA   NA   NA
#> 2020   NA               
gs.time2year(sc_tri)
#> [1] 2019 2019 2019 2019 2020
gs.time2per(sc_tri)
#> [1] 1 2 3 4 1
gs.time2str(sc_tri)
#> [1] "2019-1" "2019-2" "2019-3" "2019-4" "2020-1"
gs.time2str(sc_tri, sep = "t")
#> [1] "2019t1" "2019t2" "2019t3" "2019t4" "2020t1"
```
