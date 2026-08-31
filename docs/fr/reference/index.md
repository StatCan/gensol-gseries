# Index du paquet

## Fonctions principales (par sujet)

### Étalonnage de séries chronologiques (ordre alphabétique)

- [`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
  : Rétablir les contraintes temporelles
- [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
  : Rétablir les contraintes temporelles pour des séries de stocks

### Réconciliation de séries chronologiques (ordre alphabétique)

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  : Rétablir les contraintes linéaires transversales (contemporaines)

- [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  : Rétablir les contraintes d'agrégation transversales (contemporaines)

- [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
  :

  Fonction d'assistance pour
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)

## Fonctions utilitaires (par sujet)

### Graphiques d’étalonnage (ordre de pertinence)

- [`plot_benchAdj()`](https://StatCan.github.io/gensol-gseries/fr/reference/plot_benchAdj.md)
  : Tracer les ajustements d'étalonnage
- [`plot_graphTable()`](https://StatCan.github.io/gensol-gseries/fr/reference/plot_graphTable.md)
  : Générer des graphiques d'étalonnage dans un fichier PDF
- [`ori_plot()`](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
  [`adj_plot()`](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
  [`GR_plot()`](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
  [`GR_table()`](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
  : Générer un graphique d'étalonnage

### Conversion de métadonnées

- [`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/fr/reference/rkMeta_to_blSpecs.md)
  : Convertir des métadonnées de réconciliation

### Manipulation de données (ordre alphabétique)

- [`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_bmkDF.md)
  : Empiler des « données étalon »

- [`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_tsDF.md)
  : Empiler des données de séries chronologiques

- [`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_bmkDF.md)
  :

  Convertir un objet « ts » en *data frame* d'étalons

- [`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md)
  :

  Convertir un objet « ts » en *data frame* de séries chronologiques

- [`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsDF_to_ts.md)
  :

  Fonction réciproque de
  [`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/ts_to_tsDF.md)

- [`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/unstack_tsDF.md)
  :

  Fonction réciproque de
  [`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/fr/reference/stack_tsDF.md)

### Divers (ordre alphabétique)

- [`build_balancing_problem()`](https://StatCan.github.io/gensol-gseries/fr/reference/build_balancing_problem.md)
  : Construire les éléments des problèmes d'équilibrage.
- [`build_raking_problem()`](https://StatCan.github.io/gensol-gseries/fr/reference/build_raking_problem.md)
  : Construire les éléments des problèmes de ratissage.
- [`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.build_proc_grps.md)
  : Construire des groupes de traitement de réconciliation
- [`gs.gInv_MP()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.gInv_MP.md)
  : Inverse de Moore-Penrose
- [`gs.time2year()`](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)
  [`gs.time2per()`](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)
  [`gs.time2str()`](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)
  : Fonctions de conversion de valeurs de temps

## Données de la librairie

- [`osqp_settings_sequence`](https://StatCan.github.io/gensol-gseries/fr/reference/osqp_settings_sequence.md)
  [`default_osqp_sequence`](https://StatCan.github.io/gensol-gseries/fr/reference/osqp_settings_sequence.md)
  [`alternate_osqp_sequence`](https://StatCan.github.io/gensol-gseries/fr/reference/osqp_settings_sequence.md)
  :

  *Data frame* pour la séquence de paramètres d'OSQP
