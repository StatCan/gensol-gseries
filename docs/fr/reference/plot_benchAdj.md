# Tracer les ajustements d'étalonnage

Tracer les ajustements d'étalonnage pour une série unique dans le
périphérique graphique courant (actif). Il est possible de superposer
jusqu'à trois types d'ajustements dans le même graphique :

- Ajustements générés par la fonction
  [`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)

- Ajustements générés par la fonction
  [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

- Spline cubique associée aux ajustements générés par la fonction
  [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

Ces graphiques peuvent être utiles pour évaluer la qualité des résultats
d'étalonnage et comparer les ajustements générés par les deux fonctions
d'étalonnage
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
et
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md))
pour des séries de stocks.

## Utilisation

``` r
plot_benchAdj(
  PB_graphTable = NULL,
  SB_graphTable = NULL,
  SB_splineKnots = NULL,
  legendPos = "bottomright"
)
```

## Arguments

- PB_graphTable:

  (optionnel)

  *Data frame* (object de classe « data.frame ») correspondant au *data
  frame* de sortie `graphTable` de la fonction
  [`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
  (PB pour approche « Proc Benchmarking »). Spécifiez `NULL` pour ne pas
  inclure les ajustements de
  [`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
  dans le graphique.

  **La valeur par défaut** est `PB_graphTable = NULL`.

- SB_graphTable:

  (optionnel)

  *Data frame* (object de classe « data.frame ») correspondant au *data
  frame* de sortie `graphTable` de la fonction
  [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
  (SB). Spécifiez `NULL` pour ne pas inclure les ajustements de
  [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
  dans le graphique.

  **La valeur par défaut** est `SB_graphTable = NULL`.

- SB_splineKnots:

  (optionnel)

  *Data frame* (object de classe « data.frame ») correspondant au *data
  frame* de sortie `splineKnots` de la fonction
  [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
  (SB). Spécifiez `NULL` pour ne pas inclure la spline cubique de
  [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
  dans le graphique.

  **La valeur par défaut** est `SB_splineKnots = NULL`.

- legendPos:

  (optionnel)

  Chaîne de caractères (mot-clé) spécifiant l'emplacement de la légende
  dans le graphique. Voir la description de l'argument `x` dans la
  documentation de
  [`graphics::legend()`](https://rdrr.io/r/graphics/legend.html) pour la
  liste des mots-clés valides. Spécifiez `NULL` pour ne pas inclure de
  légende dans le graphique.

  **La valeur par défaut** est `legendPos = "bottomright"` (en bas à
  droite).

## Valeur de retour

Cette fonction ne renvoie rien (`invisible(NULL)`).

## Détails

Variables du *data frame* `graphTable` (arguments `PB_graphTable` et
`SB_graphTable`) utilisées dans le graphique :

- `t` pour l'axe des x (*t*)

- `benchmarkedSubAnnualRatio` pour les lignes *Stock Bench. (SB)* et
  *Proc Bench. (PB)*

- `bias` pour la ligne *Bias* (lorsque \\\rho \< 1\\)

Variables du *data frame* `splineKnots` (argument `SB_splineKnots`)
utilisées dans le graphique :

- `x` pour l'axe des x (*t*)

- `y` pour la ligne *Cubic spline* et les points *Extra knot* et
  *Original knot*

- `extraKnot` pour le type de nœud (*Extra knot* contre *Original knot*)

Voir la section **Valeur de retour** de
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
et
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
pour plus d'informations sur ces *data frames*.

## Voir également

[`plot_graphTable()`](https://StatCan.github.io/gensol-gseries/fr/reference/plot_graphTable.md)
[bench_graphs](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

## Exemples

``` r
#######
# Étapes préliminaires

# Stocks trimestriels (même patron répété pour 7 années)
sc_tri <- ts(rep(c(85, 95, 125, 95), 7), start = c(2013, 1), frequency = 4)

# Stocks de fin d'année
sc_ann <- ts(c(135, 125, 155, 145, 165), start = 2013, frequency = 1)

# Étalonnage proportionnel
# ... avec `benchmarking()` (approche "Proc Benchmarking")
res_PB <- benchmarking(
  ts_to_tsDF(sc_tri), 
  ts_to_bmkDF(sc_ann, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE
)
# ... avec `stock_benchmarking()`
res_SB <- stock_benchmarking(
  ts_to_tsDF(sc_tri), 
  ts_to_bmkDF(sc_ann, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  quiet = TRUE
)


#######
# Tracer les ajustements d'étalonnage

# Ajustements de `benchmarking()` (`res_PB`), sans légende
plot_benchAdj(
  PB_graphTable = res_PB$graphTable,
  legendPos = NULL
)


# Ajouter les de `stock_benchmarking()` (`res_SB`), avec une légende cette fois
plot_benchAdj(
  PB_graphTable = res_PB$graphTable,
  SB_graphTable = res_SB$graphTable
)


# Ajouter la spline cubique de `stock_benchmarking()` utilisée pour générer les ajustements
# (incluant les nœuds supplémentaires aux deux extrémités), avec légende en haut à gauche
plot_benchAdj(
  PB_graphTable = res_PB$graphTable,
  SB_graphTable = res_SB$graphTable,
  SB_splineKnots = res_SB$splineKnots,
  legendPos = "topleft"
)



#######
# Simuler l'étalonnage de plusieurs séries (3 séries de stocks)

sc_tri2 <- ts.union(ser1 = sc_tri, ser2 = sc_tri * 100, ser3 = sc_tri * 10)
sc_ann2 <- ts.union(ser1 = sc_ann, ser2 = sc_ann * 100, ser3 = sc_ann * 10)

# Avec l'argument `allCols = TRUE` (stocks identifiés avec la colonne `varSeries`)
res_SB2 <- stock_benchmarking(
  ts_to_tsDF(sc_tri2),
  ts_to_bmkDF(sc_ann2, discrete_flag = TRUE, alignment = "e", ind_frequency = 4),
  rho = 0.729, lambda = 1, biasOption = 3,
  allCols = TRUE,
  quiet = TRUE
)
#> 
#> Benchmarking indicator series [ser1] with benchmarks [ser1]
#> -----------------------------------------------------------
#> 
#> Benchmarking indicator series [ser2] with benchmarks [ser2]
#> -----------------------------------------------------------
#> 
#> Benchmarking indicator series [ser3] with benchmarks [ser3]
#> -----------------------------------------------------------

# Ajustements d'étalonnage pour le 2ième stock (ser2)
plot_benchAdj(
  SB_graphTable = res_SB2$graphTable[res_SB2$graphTable$varSeries == "ser2", ]
)


# Avec l'argument `by = "series"` (stocks identifiés avec la colonne `series`)
res_SB3 <- stock_benchmarking(
  stack_tsDF(ts_to_tsDF(sc_tri2)),
  stack_bmkDF(ts_to_bmkDF(
    sc_ann2, discrete_flag = TRUE, alignment = "e", ind_frequency = 4)
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

# Spline cubique pour le 3ième stock (ser3)
plot_benchAdj(
  SB_splineKnots = res_SB3$splineKnots[res_SB3$splineKnots$series == "ser3", ]
)
```
