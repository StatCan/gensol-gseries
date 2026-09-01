# Construire des groupes de traitement de réconciliation

Cette fonction construit le *data frame* des groupes de traitement pour
les problèmes de réconciliation. Elle est utilisée à interne par
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
et
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md).

## Utilisation

``` r
gs.build_proc_grps(
  ts_yr_vec,
  ts_per_vec,
  n_per,
  ts_freq,
  temporal_grp_periodicity,
  temporal_grp_start
)
```

## Arguments

- ts_yr_vec:

  (obligatoire)

  Vecteur des valeurs d'année (unité de temps; voir
  [`gs.time2year()`](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)).

- ts_per_vec:

  (obligatoire)

  Vecteur des valeurs de période (cycle; voir
  [`gs.time2per()`](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)).

- n_per:

  (obligatoire)

  Longueur (nombre de périodes) de la série chronologique.

- ts_freq:

  (obligatoire)

  Fréquence de la série chronologique (voir
  [`stats::frequency()`](https://rdrr.io/r/stats/time.html)).

- temporal_grp_periodicity:

  (obligatoire)

  Nombre de périodes dans les groupes temporels.

- temporal_grp_start:

  (obligatoire)

  Première période des groupes temporels.

## Valeur de retour

Un *data frame* avec les variables (colonnes) suivantes :

- `grp`  : vecteur de nombres entiers identifiant le groupe de
  traitement (`1:<nombre-de-groupes>`).

- `beg_per`  : vecteur de nombres entiers identifiant la première
  période du groupe de traitement.

- `end_per`  : vecteur de nombres entiers identifiant la dernière
  période du groupe de traitement.

- `complete_grp` : Vecteur logique indiquant si le groupe de traitement
  correspond à un groupe temporel complet.

## Groupes de traitement

L'ensemble des périodes d'un problème de réconciliation (ratissage ou
équilibrage) donné est appelé *groupe de traitement* et correspond
soit :

- à une **période unique** lors d'un traitement période par période ou,
  lorsque les totaux temporels sont préservés, pour les périodes
  individuelles d'un groupe temporel incomplet (ex., une année
  incomplète)

- ou à l'**ensemble des périodes d'un groupe temporel complet** (ex.,
  une année complète) lorsque les totaux temporels sont préservés.

Le nombre total de groupes de traitement (nombre total de problèmes de
réconciliation) dépend de l'ensemble de périodes des séries
chronologiques d'entrée (objet de type série chronologique spécifié avec
l'argument `in_ts`) et de la valeur des arguments
`temporal_grp_periodicity` et `temporal_grp_start`.

Les scénarios courants incluent `temporal_grp_periodicity = 1` (par
défaut) pour un traitement période par période sans préservation des
totaux temporels et `temporal_grp_periodicity = frequency(in_ts)` pour
la préservation des totaux annuels (années civiles par défaut).
L'argument `temporal_grp_start` permet de spécifier d'autres types
d'années (*non civile*). Par exemple, des années financières commençant
en avril correspondent à `temporal_grp_start = 4` avec des données
mensuelles et à `temporal_grp_start = 2` avec des données
trimestrielles. La préservation des totaux trimestriels avec des données
mensuelles correspondrait à `temporal_grp_periodicity = 3`.

Par défaut, les groupes temporels convrant plus d'une année (c.-à-d.,
correspondant à `temporal_grp_periodicity > frequency(in_ts)`) débutent
avec une année qui est un multiple de
` ceiling(temporal_grp_periodicity / frequency(in_ts))`. Par exemple,
les groupes bisannuels correspondant à
`temporal_grp_periodicity = 2 * frequency(in_ts)` débutent avec une
*année paire* par défaut. Ce comportement peut être modifié avec
l'argument `temporal_grp_start`. Par exemple, la préservation des totaux
bisannuels débutant avec une *année impaire* au lieu d'une *année paire*
(par défaut) correspond à `temporal_grp_start = frequency(in_ts) + 1`
(avec `temporal_grp_periodicity = 2 * frequency(in_ts)`).

Voir les **Exemples** de `gs.build_proc_grps()` pour des scénarios
courants de groupes de traitements.

## Voir également

[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
[time_values_conv](https://StatCan.github.io/gensol-gseries/fr/reference/time_values_conv.md)

## Exemples

``` r
#######
# Configuration préalable

# Série chronologique mensuelle et trimestrielle « bidon » (2.5 années de longueur)
sc_men <- ts(rep(NA, 30), start = c(2019, 1), frequency = 12)
sc_men
#>      Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#> 2019  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#> 2020  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#> 2021  NA  NA  NA  NA  NA  NA                        
sc_tri <- ts(rep(NA, 10), start = c(2019, 1), frequency = 4)
sc_tri
#>      Qtr1 Qtr2 Qtr3 Qtr4
#> 2019   NA   NA   NA   NA
#> 2020   NA   NA   NA   NA
#> 2021   NA   NA          

# Information résumée de la série chronologique
ts_info <- function(sc, sep = "-") {
  list(
    a = gs.time2year(sc),     # années
    p = gs.time2per(sc),      # périodes
    n = length(sc),           # longueur
    f = frequency(sc),        # fréquence
    e = gs.time2str(sc, sep)  # étiquettes
  )
}
info_men <- ts_info(sc_men)
info_tri <- ts_info(sc_tri, sep = "t")

# Fonction qui ajoute une étiquette décrivant le groupe de traitement
ajouter_desc <- function(df_gr, vec_eti, mot, suf = "s") {
  df_gr$description <- ifelse(
    df_gr$complete_grp,
    paste0(
      "--- ", df_gr$end_per - df_gr$beg_per + 1, " ", mot, suf, " : ",
      vec_eti[df_gr$beg_per], " à ", vec_eti[df_gr$end_per], " ---"
    ),
    paste0("--- 1 ", mot, " : ", vec_eti[df_gr$beg_per], " ---")
  )
  
  df_gr
}




#######
# Scénarios courants de groupes de traitement pour des données mensuelles


# 0- Traitement mois par mois (chaque mois est un groupe de traitement)
gr_men0 <- gs.build_proc_grps(
  info_men$a, info_men$p, info_men$n, info_men$f,
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1
)
tmp <- ajouter_desc(gr_men0, info_men$e, "mois", "")
head(tmp)
#>   grp beg_per end_per complete_grp             description
#> 1   1       1       1        FALSE --- 1 mois : 2019-1 ---
#> 2   2       2       2        FALSE --- 1 mois : 2019-2 ---
#> 3   3       3       3        FALSE --- 1 mois : 2019-3 ---
#> 4   4       4       4        FALSE --- 1 mois : 2019-4 ---
#> 5   5       5       5        FALSE --- 1 mois : 2019-5 ---
#> 6   6       6       6        FALSE --- 1 mois : 2019-6 ---
tail(tmp)
#>    grp beg_per end_per complete_grp             description
#> 25  25      25      25        FALSE --- 1 mois : 2021-1 ---
#> 26  26      26      26        FALSE --- 1 mois : 2021-2 ---
#> 27  27      27      27        FALSE --- 1 mois : 2021-3 ---
#> 28  28      28      28        FALSE --- 1 mois : 2021-4 ---
#> 29  29      29      29        FALSE --- 1 mois : 2021-5 ---
#> 30  30      30      30        FALSE --- 1 mois : 2021-6 ---


# Groupes temporels correspondant à ...

# 1- des années civiles
gr_men1 <- gs.build_proc_grps(
  info_men$a, info_men$p, info_men$n, info_men$f,
  temporal_grp_periodicity = 12,
  temporal_grp_start = 1
)
ajouter_desc(gr_men1, info_men$e, "mois", "")
#>   grp beg_per end_per complete_grp                        description
#> 1   1       1      12         TRUE --- 12 mois : 2019-1 à 2019-12 ---
#> 2   2      13      24         TRUE --- 12 mois : 2020-1 à 2020-12 ---
#> 3   3      25      25        FALSE            --- 1 mois : 2021-1 ---
#> 4   4      26      26        FALSE            --- 1 mois : 2021-2 ---
#> 5   5      27      27        FALSE            --- 1 mois : 2021-3 ---
#> 6   6      28      28        FALSE            --- 1 mois : 2021-4 ---
#> 7   7      29      29        FALSE            --- 1 mois : 2021-5 ---
#> 8   8      30      30        FALSE            --- 1 mois : 2021-6 ---

# 2- des années financières commençant en avril
gr_men2 <- gs.build_proc_grps(
  info_men$a, info_men$p, info_men$n, info_men$f,
  temporal_grp_periodicity = 12,
  temporal_grp_start = 4
)
ajouter_desc(gr_men2, info_men$e, "mois", "")
#>   grp beg_per end_per complete_grp                       description
#> 1   1       1       1        FALSE           --- 1 mois : 2019-1 ---
#> 2   2       2       2        FALSE           --- 1 mois : 2019-2 ---
#> 3   3       3       3        FALSE           --- 1 mois : 2019-3 ---
#> 4   4       4      15         TRUE --- 12 mois : 2019-4 à 2020-3 ---
#> 5   5      16      27         TRUE --- 12 mois : 2020-4 à 2021-3 ---
#> 6   6      28      28        FALSE           --- 1 mois : 2021-4 ---
#> 7   7      29      29        FALSE           --- 1 mois : 2021-5 ---
#> 8   8      30      30        FALSE           --- 1 mois : 2021-6 ---

# 3- des trimestres réguliers (commençant en janvier, avril, juillet et octobre)
gr_men3 <- gs.build_proc_grps(
  info_men$a, info_men$p, info_men$n, info_men$f,
  temporal_grp_periodicity = 3,
  temporal_grp_start = 1
)
ajouter_desc(gr_men3, info_men$e, "mois", "")
#>    grp beg_per end_per complete_grp                        description
#> 1    1       1       3         TRUE   --- 3 mois : 2019-1 à 2019-3 ---
#> 2    2       4       6         TRUE   --- 3 mois : 2019-4 à 2019-6 ---
#> 3    3       7       9         TRUE   --- 3 mois : 2019-7 à 2019-9 ---
#> 4    4      10      12         TRUE --- 3 mois : 2019-10 à 2019-12 ---
#> 5    5      13      15         TRUE   --- 3 mois : 2020-1 à 2020-3 ---
#> 6    6      16      18         TRUE   --- 3 mois : 2020-4 à 2020-6 ---
#> 7    7      19      21         TRUE   --- 3 mois : 2020-7 à 2020-9 ---
#> 8    8      22      24         TRUE --- 3 mois : 2020-10 à 2020-12 ---
#> 9    9      25      27         TRUE   --- 3 mois : 2021-1 à 2021-3 ---
#> 10  10      28      30         TRUE   --- 3 mois : 2021-4 à 2021-6 ---

# 4- des trimestres décalés d'un mois (commençant en février, mai, août et novembre)
gr_men4 <- gs.build_proc_grps(
  info_men$a, info_men$p, info_men$n, info_men$f,
  temporal_grp_periodicity = 3,
  temporal_grp_start = 2
)
ajouter_desc(gr_men4, info_men$e, "mois", "")
#>    grp beg_per end_per complete_grp                       description
#> 1    1       1       1        FALSE           --- 1 mois : 2019-1 ---
#> 2    2       2       4         TRUE  --- 3 mois : 2019-2 à 2019-4 ---
#> 3    3       5       7         TRUE  --- 3 mois : 2019-5 à 2019-7 ---
#> 4    4       8      10         TRUE --- 3 mois : 2019-8 à 2019-10 ---
#> 5    5      11      13         TRUE --- 3 mois : 2019-11 à 2020-1 ---
#> 6    6      14      16         TRUE  --- 3 mois : 2020-2 à 2020-4 ---
#> 7    7      17      19         TRUE  --- 3 mois : 2020-5 à 2020-7 ---
#> 8    8      20      22         TRUE --- 3 mois : 2020-8 à 2020-10 ---
#> 9    9      23      25         TRUE --- 3 mois : 2020-11 à 2021-1 ---
#> 10  10      26      28         TRUE  --- 3 mois : 2021-2 à 2021-4 ---
#> 11  11      29      29        FALSE           --- 1 mois : 2021-5 ---
#> 12  12      30      30        FALSE           --- 1 mois : 2021-6 ---




#######
# Scénarios courants de groupes de traitement pour des données trimestrielles


# 0- Traitement trimestre par trimestre (chaque trimestre est un groupe de traitement)
gr_tri0 <- gs.build_proc_grps(
  info_tri$a, info_tri$p, info_tri$n, info_tri$f,
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1
)
ajouter_desc(gr_tri0, info_tri$e, "trimestre")
#>    grp beg_per end_per complete_grp                  description
#> 1    1       1       1        FALSE --- 1 trimestre : 2019t1 ---
#> 2    2       2       2        FALSE --- 1 trimestre : 2019t2 ---
#> 3    3       3       3        FALSE --- 1 trimestre : 2019t3 ---
#> 4    4       4       4        FALSE --- 1 trimestre : 2019t4 ---
#> 5    5       5       5        FALSE --- 1 trimestre : 2020t1 ---
#> 6    6       6       6        FALSE --- 1 trimestre : 2020t2 ---
#> 7    7       7       7        FALSE --- 1 trimestre : 2020t3 ---
#> 8    8       8       8        FALSE --- 1 trimestre : 2020t4 ---
#> 9    9       9       9        FALSE --- 1 trimestre : 2021t1 ---
#> 10  10      10      10        FALSE --- 1 trimestre : 2021t2 ---


# Groupes temporels correspondant à ...

# 1- des années civiles
gr_tri1 <- gs.build_proc_grps(
  info_tri$a, info_tri$p, info_tri$n, info_tri$f,
  temporal_grp_periodicity = 4,
  temporal_grp_start = 1
)
ajouter_desc(gr_tri1, info_tri$e, "trimestre")
#>   grp beg_per end_per complete_grp                            description
#> 1   1       1       4         TRUE --- 4 trimestres : 2019t1 à 2019t4 ---
#> 2   2       5       8         TRUE --- 4 trimestres : 2020t1 à 2020t4 ---
#> 3   3       9       9        FALSE           --- 1 trimestre : 2021t1 ---
#> 4   4      10      10        FALSE           --- 1 trimestre : 2021t2 ---

# 2- des années financières commençant en avril (2ième trimestre)
gr_tri2 <- gs.build_proc_grps(
  info_tri$a, info_tri$p, info_tri$n, info_tri$f,
  temporal_grp_periodicity = 4,
  temporal_grp_start = 2
)
ajouter_desc(gr_tri2, info_tri$e, "trimestre")
#>   grp beg_per end_per complete_grp                            description
#> 1   1       1       1        FALSE           --- 1 trimestre : 2019t1 ---
#> 2   2       2       5         TRUE --- 4 trimestres : 2019t2 à 2020t1 ---
#> 3   3       6       9         TRUE --- 4 trimestres : 2020t2 à 2021t1 ---
#> 4   4      10      10        FALSE           --- 1 trimestre : 2021t2 ---
```
