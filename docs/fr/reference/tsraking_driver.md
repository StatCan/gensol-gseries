# Fonction d'assistance pour [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)

Fonction d'assistance pour
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
qui détermine de manière pratique l'ensemble des problèmes de ratissage
(« *raking* ») à résoudre et génère à l'interne les appels individuels à
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).
Cette fonction est particulièrement utile dans le contexte de la
préservation des totaux temporels (ex., totaux annuels) où chaque
problème de ratissage individuel implique une seule période pour les
groupes temporels incomplets (ex., années incomplètes) ou plusieurs
périodes pour les groupes temporels complets (ex., l'ensemble des
périodes d'une année complète).

## Utilisation

``` r
tsraking_driver(
  in_ts,
  ...,  # arguments de `tsraking()` excluant `data_df`
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1
)
```

## Arguments

- in_ts:

  (obligatoire)

  Objet de type série chronologique (classe « ts » ou « mts ») qui
  contient les données des séries chronologiques à réconcilier. Il
  s'agit des données d'entrée (solutions initiales) des problèmes de
  ratissage (« *raking* »).

- ...:

  Arguments transmis à
  [`tsraking`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)

  `metadata_df`

  :   (obligatoire)

      *Data frame* (object de classe « data.frame ») qui décrit les
      contraintes d'agrégation transversales (règles d'additivité) pour
      le problème de ratissage (« *raking* »). Deux variables de type
      caractère doivent être incluses dans le *data frame* : `series` et
      `total1`. Deux variables sont optionnelles : `total2` (caractère)
      et `alterAnnual` (numérique). Les valeurs de la variable `series`
      représentent les noms des variables des séries composantes dans le
      *data frame* des données d'entrée (argument `data_df`). De même,
      les valeurs des variables `total1` et `total2` représentent les
      noms des variables des totaux de contrôle transversaux de 1^(ère)
      et 2^(ème) dimension dans le *data frame* des données d'entrée. La
      variable `alterAnnual` contient le coefficient d'altérabilité pour
      la contrainte temporelle associée à chaque série composante.
      Lorsqu'elle est spécifiée, cette dernière remplace le coefficient
      d'altérabilité par défaut spécifié avec l'argument `alterAnnual`.

  `alterability_df`

  :   (optionnel)

      *Data frame* (object de classe « data.frame »), ou `NULL`, qui
      contient les variables de coefficients d'altérabilité. Elles
      doivent correspondre à une série composante ou à un total de
      contrôle transversal, c'est-à-dire qu'une variable portant le même
      nom doit exister dans le *data frame* des données d'entrée
      (argument `data_df`). Les valeurs de ces coefficients
      d'altérabilité remplaceront les coefficients d'altérabilité par
      défaut spécifiés avec les arguments `alterSeries`, `alterTotal1`
      et `alterTotal2`. Lorsque le *data frame* des données d'entrée
      contient plusieurs enregistrements et que le *data frame* des
      coefficients d'altérabilité n'en contient qu'un seul, les
      coefficients d'altérabilité sont utilisés (répétés) pour tous les
      enregistrements du *data frame* des données d'entrée. Le *data
      frame* des coefficients d'altérabilité peut également contenir
      autant d'enregistrements que le *data frame* des données d'entrée.

      **La valeur par défaut** est `alterability_df = NULL`
      (coefficients d'altérabilité par défaut).

  `alterSeries`

  :   (optionnel)

      Nombre réel non négatif spécifiant le coefficient d'altérabilité
      par défaut pour les valeurs des séries composantes. Il
      s'appliquera aux séries composantes pour lesquelles des
      coefficients d'altérabilité n'ont pas déjà été spécifiés dans le
      *data frame* des coefficients d'altérabilité (argument
      `alterability_df`).

      **La valeur par défaut** est `alterSeries = 1.0` (valeurs des
      séries composantes non contraignantes).

  `alterTotal1`

  :   (optionnel)

      Nombre réel non négatif spécifiant le coefficient d'altérabilité
      par défaut pour les totaux de contrôle transversaux de la 1^(ère)
      dimension. Il s'appliquera aux totaux de contrôle transversaux
      pour lesquels des coefficients d'altérabilité n'ont pas déjà été
      spécifiés dans le *data frame* des coefficients d'altérabilité
      (argument `alterability_df`).

      **La valeur par défaut** est `alterTotal1 = 0.0` (totaux de
      contrôle transversaux de 1^(ère) dimension contraignants).

  `alterTotal2`

  :   (optionnel)

      Nombre réel non négatif spécifiant le coefficient d'altérabilité
      par défaut pour les totaux de contrôle transversaux de la 2^(ème)
      dimension. Il s'appliquera aux totaux de contrôle transversaux
      pour lesquels des coefficients d'altérabilité n'ont pas déjà été
      spécifiés dans le *data frame* des coefficients d'altérabilité
      (argument `alterability_df`).

      **La valeur par défaut** est `alterTotal2 = 0.0` (totaux de
      contrôle transversaux de 2^(ème) dimension contraignants).

  `alterAnnual`

  :   (optionnel)

      Nombre réel non négatif spécifiant le coefficient d'altérabilité
      par défaut pour les contraintes temporelles (ex., totaux annuels)
      des séries composantes. Il s'appliquera aux séries composantes
      pour lesquelles des coefficients d'altérabilité n'ont pas déjà été
      spécifiés dans le *data frame* des métadonnées de ratissage
      (argument `metadata_df`).

      **La valeur par défaut** est `alterAnnual = 0.0` (totaux de
      contrôle temporels contraignants).

  `tolV,tolP`

  :   (optionnel)

      Nombre réel non négatif, ou `NA`, spécifiant la tolérance, en
      valeur absolue ou en pourcentage, à utiliser lors du test ultime
      pour les totaux de contrôle contraignants (coefficient
      d'altérabilité de \\0.0\\ pour les totaux de contrôle temporels ou
      transversaux). Le test compare les totaux de contrôle
      contraignants d'entrée avec ceux calculés à partir des séries
      composantes réconciliées (en sortie). Les arguments `tolV` et
      `tolP` ne peuvent pas être spécifiés tous les deux à la fois (l'un
      doit être spécifié tandis que l'autre doit être `NA`).

      **Exemple :** pour une tolérance de 10 *unités*, spécifiez
      `tolV = 10, tolP = NA`; pour une tolérance de 1%, spécifiez
      `tolV = NA, tolP = 0.01`.

      **Les valeurs par défaut** sont `tolV = 0.001` et `tolP = NA`.

  `warnNegResult`

  :   (optionnel)

      Argument logique (*logical*) spécifiant si un message
      d'avertissement doit être affiché lorsqu'une valeur négative créée
      par la fonction dans une série réconciliée (en sortie) est
      inférieure au seuil spécifié avec l'argument `tolN`.

      **La valeur par défaut** est `warnNegResult = TRUE`.

  `tolN`

  :   (optionnel)

      Nombre réel négatif spécifiant le seuil pour l'identification des
      valeurs négatives. Une valeur est considérée négative lorsqu'elle
      est inférieure à ce seuil.

      **La valeur par défaut** est `tolN = -0.001`.

  `id`

  :   (optionnel)

      Vecteur de chaînes de caractère (longueur minimale de 1), ou
      `NULL`, spécifiant le nom des variables additionnelles à
      transférer du *data frame* d'entrée (argument `data_df`) au *data
      frame* de sortie, c.-à-d., l'objet renvoyé par la fonction (voir
      la section **Valeur de retour**). Par défaut, le *data frame* de
      sortie ne contient que les variables énumérées dans le *data
      frame* des métadonnées de ratissage (argument `metadata_df`).

      **La valeur par défaut** est `id = NULL`.

  `verbose`

  :   (optionnel)

      Argument logique (*logical*) spécifiant si les informations sur
      les étapes intermédiaires avec le temps d'exécution (temps réel et
      non le temps CPU) doivent être affichées. Notez que spécifier
      l'argument `quiet = TRUE` annulerait l'argument `verbose`.

      **La valeur par défaut** est `verbose = FALSE`.

  `Vmat_option`

  :   (optionnel)

      Spécification de l'option pour les matrices de variance (\\V_e\\
      et \\V\_\epsilon\\; voir la section **Détails**) :

      |  |  |
      |----|----|
      | **Valeur** | **Description** |
      | `1` | Utiliser les vecteurs \\x\\ et \\g\\ dans les matrices de variance. |
      | `2` | Utiliser les vecteurs \\\|x\|\\ et \\\|g\|\\ dans les matrices de variance. |

      Voir Ferland (2016) et la sous-section **Arguments `Vmat_option`
      et `warnNegInput`** dans la section **Détails** pour plus
      d'informations.

      **La valeur par défaut** est `Vmat_option = 1`.

  `warnNegInput`

  :   (optionnel)

      Argument logique (*logical*) spécifiant si un message
      d'avertissement doit être affiché lorsqu'une valeur négative plus
      petite que le seuil spécifié par l'argument `tolN` est trouvée
      dans le *data frame* des données d'entrée (argument `data_df`).

      **La valeur par défaut** est `warnNegInput = TRUE`.

  `quiet`

  :   (optionnel)

      Argument logique (*logical*) spécifiant s'il faut ou non afficher
      uniquement les informations essentielles telles que les messages
      d'avertissements et d'erreurs. Spécifier `quiet = TRUE` annulera
      également l'argument `verbose` et est équivalent à *envelopper*
      votre appel à
      [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
      avec [`suppressMessages()`](https://rdrr.io/r/base/message.html).

      **La valeur par défaut** est `quiet = FALSE`.

- temporal_grp_periodicity:

  (optionnel)

  Nombre entier positif définissant le nombre de périodes dans les
  groupes temporels pour lesquels les totaux doivent être préservés. Par
  exemple, spécifiez `temporal_grp_periodicity = 3` avec des séries
  chronologiques mensuelles pour la préservation des totaux trimestriels
  et `temporal_grp_periodicity = 12` (ou
  `temporal_grp_periodicity = frequency(in_ts)`) pour la préservation
  des totaux annuels. Spécifier `temporal_grp_periodicity = 1`
  (*défaut*) correspond à un traitement période par période sans
  préservation des totaux temporels.

  **La valeur par défaut** est `temporal_grp_periodicity = 1`
  (traitement période par période sans préservation des totaux
  temporels).

- temporal_grp_start:

  (optionnel)

  Entier dans l'intervalle \[1 .. `temporal_grp_periodicity`\]
  spécifiant la période (cycle) de départ pour la préservation des
  totaux temporels. Par exemple, des totaux annuels correspondant aux
  années financières définies d'avril à mars de l'année suivante
  seraient spécifiés avec `temporal_grp_start = 4` pour des séries
  chronologiques mensuelles (`frequency(in_ts) = 12`) et
  `temporal_grp_start = 2` pour des séries chronologiques trimestrielles
  (`frequency(in_ts) = 4`). Cet argument n'a pas d'effet pour un
  traitement période par période sans préservation des totaux temporels
  (`temporal_grp_periodicity = 1`).

  **La valeur par défaut** est `temporal_grp_start = 1`.

## Valeur de retour

La fonction renvoie un objet de type série chronologique (classe « ts »
ou « mts ») contenant les séries composantes réconciliées, les totaux de
contrôle transversaux réconciliés et d'autres séries spécifiées avec
l'argument `id` de
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).
Il peut être explicitement converti en un autre type d'objet avec la
fonction `as*()` appropriée (ex., `tsibble::as_tsibble()` le
convertirait en tsibble).

Notez qu'un objet `NULL` est renvoyé si une erreur survient avant que le
traitement des données ne puisse commencer. Dans le cas contraire, si
l'exécution est suffisamment avancée pour que le traitement des données
puisse commencer, alors un objet incomplet (avec des valeurs `NA`) sera
renvoyé en cas d'erreur.

## Détails

Cette fonction résout un problème de ratissage avec
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
par groupe de traitement (voir la section **Groupes de traitement** pour
plus de détails). L'expression mathématique de ces problèmes de
ratissage peut être trouvée dans la section **Détails** de la
documentation de
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).

Le *data frame* des coefficients d'altérabilité (argument
`alterability_df`) spécifié avec `tsraking_driver()` peut soit
contenir :

- Un seul enregistrement : les coefficients spécifiés seront utilisés
  pour toutes les périodes de l'objet d'entrée de type série
  chronologique (argument `in_ts`).

- Un nombre d'enregistrements égal à `frequency(in_ts)` : les
  coefficients spécifiés seront utilisés pour le *cycle* correspondant
  aux périodes de l'objet d'entrée de type série chronologique (argument
  `in_ts`). Exemple pour des données mensuelles : 1^(er) enregistrement
  pour janvier, 2^(ème) enregistrement pour février, etc.)

- Un nombre d'enregistrements égal à `nrow(in_ts)` : les coefficients
  spécifiés seront utilisés pour les périodes correspondantes de l'objet
  d'entrée de type série chronologique (argument `in_ts`), c.-à-d.,
  1^(er) enregistrement pour la 1^(ère) période, 2^(ème) enregistrement
  pour la 2^(ème) période, etc.

Spécifier `quiet = TRUE` supprimera les messages de
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
(ex., l'en-tête de la fonction) et n'affichera que les informations
essentielles telles que les avertissements, les erreurs et la période
(ou l'ensemble des périodes) en cours de traitement. Nous déconseillons
d'*envelopper* l'appel à la fonction `tsraking_driver()` avec
[`suppressMessages()`](https://rdrr.io/r/base/message.html) pour
supprimer l'affichage des informations relatives à la (aux) période(s)
en cours de traitement, car cela rendrait difficile le dépannage de
problèmes de ratissage individuels.

Bien que
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
puisse être appelée avec `*apply()` pour réconcilier successivement
toutes les périodes de l'objet d'entrée de type série chronologique
(argument `in_ts`), l'utilisation de `tsraking_driver()` présente
quelques avantages, notamment :

- la préservation des totaux temporels (seul un traitement période par
  période, sans préservation des totaux temporels, serait possible avec
  `*apply()`);

- une plus grande flexibilité dans la spécification des coefficients
  d'altérabilité définis par l'utilisateur (ex., des valeurs spécifiques
  aux périodes);

- affichage de la période en cours de traitement dans la console, ce qui
  est utile pour dépanner les problèmes de ratissage individuels;

- amélioration de la gestion des erreurs, c.-à-d., une meilleure gestion
  des avertissements ou des erreurs s'ils ne se produisent que pour
  certains problèmes de ratissage (périodes);

- renvoi automatique d'un objet de type « ts » (« mts »).

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

Voir les **Exemples** de
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.build_proc_grps.md)
pour des scénarios courants de groupes de traitements.

## Références

Statistique Canada (2018). "Chapitre : Sujets avancés", **Théorie et
application de la réconciliation (Code du cours 0437)**, Statistique
Canada, Ottawa, Canada.

## Voir également

[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
[`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/fr/reference/rkMeta_to_blSpecs.md)
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.build_proc_grps.md)

## Exemples

``` r
# Problème de ratissage à 1 dimension où les ventes trimestrielles de voitures 
# dans les 3 provinces des Prairies (Alb., Sask. et Man.) pour 8 trimestres, 
# de 2019 T2 à 2021 T1, doivent être égales au total (`cars_tot`).

# Métadonnées du problème
mes_meta <- data.frame(
  series = c("autos_alb", "autos_sask", "autos_man"),
  total1 = rep("autos_tot", 3)
)
mes_meta
#>       series    total1
#> 1  autos_alb autos_tot
#> 2 autos_sask autos_tot
#> 3  autos_man autos_tot

# Données du problème
mes_series <- ts(
  matrix(
    c(
      14, 18, 14, 58,
      17, 14, 16, 44,
      14, 19, 18, 58,
      20, 18, 12, 53,
      16, 16, 19, 44,
      14, 15, 16, 50,
      19, 20, 14, 52,
      16, 15, 19, 51
    ),
    ncol = 4,
    byrow = TRUE
  ),
  start = c(2019, 2),
  frequency = 4,
  names = c("autos_alb", "autos_sask", "autos_man", "autos_tot")
)


###########
# Exemple 1 : Traitement période-par-période sans préservation des totaux annuels.

# Réconcilier les données
res_ratis1 <- tsraking_driver(mes_series, mes_meta)
#> 
#> 
#> Raking period [2019-2]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2019-3]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2019-4]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-1]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-2]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-3]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2020-4]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Raking period [2021-1]
#> ======================
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsraking() function:
#>     data_df         = <argument 'data_df'>
#>     metadata_df     = <argument 'metadata_df'>
#>     alterability_df = NULL (default)
#>     alterSeries     = 1 (default)
#>     alterTotal1     = 0 (default)
#>     alterTotal2     = 0 (default)
#>     alterAnnual     = 0 (default)
#>     tolV            = 0.001 (default)
#>     warnNegResult   = TRUE (default)
#>     tolN            = -0.001 (default)
#>     id              = NULL (default)
#>     verbose         = FALSE (default)
#>     (*)Vmat_option  = 1 (default)
#>     (*)warnNegInput = TRUE (default)
#>     (*)quiet        = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 

# Données initiales
mes_series
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2        14         18        14        58
#> 2019 Q3        17         14        16        44
#> 2019 Q4        14         19        18        58
#> 2020 Q1        20         18        12        53
#> 2020 Q2        16         16        19        44
#> 2020 Q3        14         15        16        50
#> 2020 Q4        19         20        14        52
#> 2021 Q1        16         15        19        51

# Données réconciliées
res_ratis1
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2  17.65217   22.69565  17.65217        58
#> 2019 Q3  15.91489   13.10638  14.97872        44
#> 2019 Q4  15.92157   21.60784  20.47059        58
#> 2020 Q1  21.20000   19.08000  12.72000        53
#> 2020 Q2  13.80392   13.80392  16.39216        44
#> 2020 Q3  15.55556   16.66667  17.77778        50
#> 2020 Q4  18.64151   19.62264  13.73585        52
#> 2021 Q1  16.32000   15.30000  19.38000        51

# Vérifier les contraintes transversales en sortie
all.equal(
  rowSums(res_ratis1[, mes_meta$series]), 
  as.vector(res_ratis1[, "autos_tot"])
)
#> [1] TRUE

# Vérifier le total de contrôle (fixe)
all.equal(mes_series[, "autos_tot"], res_ratis1[, "autos_tot"])
#> [1] TRUE


###########
# Exemple 2 : Préservation des totaux annuels de 2020 (traitement période-par-période 
#             pour les années incomplètes 2019 et 2021), avec `quiet = TRUE` pour 
#             éviter d'afficher l'en-tête de la fonction pour chaque groupe de traitement.

# Vérifions tout d'abord que le total annuel de 2020 de la série totale (`autos_tot`) 
# et de la somme des séries composantes (`autos_alb`, `autos_sask` et `autos_man`) 
# concordent. Dans le cas contraire, il faudrait d'abord résoudre cet écart avant 
# d'exécuter `tsraking_driver()`.
tot2020 <- aggregate.ts(window(mes_series, start = c(2020, 1), end = c(2020, 4)))
all.equal(
  as.numeric(tot2020[, "autos_tot"]), 
  sum(tot2020[, mes_meta$series])
)
#> [1] TRUE

# Réconcilier les données
res_ratis2 <- tsraking_driver(
  in_ts = mes_series,
  metadata_df = mes_meta,
  quiet = TRUE,
  temporal_grp_periodicity = frequency(mes_series)
)
#> 
#> 
#> Raking period [2019-2]
#> ======================
#> 
#> 
#> Raking period [2019-3]
#> ======================
#> 
#> 
#> Raking period [2019-4]
#> ======================
#> 
#> 
#> Raking periods [2020-1 - 2020-4]
#> ================================
#> 
#> 
#> Raking period [2021-1]
#> ======================

# Données initiales
mes_series
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2        14         18        14        58
#> 2019 Q3        17         14        16        44
#> 2019 Q4        14         19        18        58
#> 2020 Q1        20         18        12        53
#> 2020 Q2        16         16        19        44
#> 2020 Q3        14         15        16        50
#> 2020 Q4        19         20        14        52
#> 2021 Q1        16         15        19        51

# Données réconciliées
res_ratis2
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2  17.65217   22.69565  17.65217        58
#> 2019 Q3  15.91489   13.10638  14.97872        44
#> 2019 Q4  15.92157   21.60784  20.47059        58
#> 2020 Q1  21.15283   19.04513  12.80204        53
#> 2020 Q2  13.74700   13.75373  16.49927        44
#> 2020 Q3  15.50782   16.62184  17.87034        50
#> 2020 Q4  18.59234   19.57931  13.82835        52
#> 2021 Q1  16.32000   15.30000  19.38000        51

# Vérifier les contraintes transversales en sortie
all.equal(
  rowSums(res_ratis2[, mes_meta$series]), 
  as.vector(res_ratis2[, "autos_tot"])
)
#> [1] TRUE

# Vérifier les contraintes temporelles en sortie (total annuel de 2020 pour chaque série)
all.equal(
  tot2020,
  aggregate.ts(window(res_ratis2, start = c(2020, 1), end = c(2020, 4)))
)
#> [1] TRUE

# Vérifier le total de contrôle (fixe)
all.equal(mes_series[, "autos_tot"], res_ratis2[, "autos_tot"])
#> [1] TRUE


###########
# Exemple 3 : Préservation des totaux annuels pour les années financières allant  
#             d'avril à mars (2019T2-2020T1 et 2020T2-2021T1).

# Calculer les deux totaux d'années financières (objet « ts » annuel)
tot_annFisc <- ts(
  rbind(
    aggregate.ts(window(mes_series, start = c(2019, 2), end = c(2020, 1))),
    aggregate.ts(window(mes_series, start = c(2020, 2), end = c(2021, 1)))
  ),
  start = 2019,
  frequency = 1
)

# Écarts dans les totaux d'années financières (série totale contre la somme des 
# séries composantes)
as.numeric(tot_annFisc[, "autos_tot"]) - rowSums(tot_annFisc[, mes_meta$series])
#> [1] 19 -2


# 3a) Réconcilier les totaux d'années financières (ratisser les totaux d'années 
#     financières des séries composantes à ceux de la série totale).
tot_annFisc_ratis <- tsraking_driver(
  in_ts = tot_annFisc,
  metadata_df = mes_meta,
  quiet = TRUE
)
#> 
#> 
#> Raking period [2019]
#> ====================
#> 
#> 
#> Raking period [2020]
#> ====================

# Confirmer que les écarts précédents ont disparu (ils sont tous les deux nuls).
as.numeric(tot_annFisc_ratis[, "autos_tot"]) - 
  rowSums(tot_annFisc_ratis[, mes_meta$series])
#> [1] 0 0

# 3b) Étalonner les séries composantes trimestrielles à ces nouveaux totaux (cohérents) 
#     d'années financières.
res_eta <- benchmarking(
  series_df = ts_to_tsDF(mes_series[, mes_meta$series]),
  benchmarks_df = ts_to_bmkDF(
    tot_annFisc_ratis[, mes_meta$series],
    ind_frequency = frequency(mes_series),
    
    # Années financières d'avril à mars (T2 à T1)
    bmk_interval_start = 2
  ),
  rho = 0.729,
  lambda = 1,
  biasOption = 2,
  allCols = TRUE,
  quiet = TRUE
)
#> 
#> Benchmarking indicator series [autos_alb] with benchmarks [autos_alb]
#> ---------------------------------------------------------------------
#> 
#> Benchmarking indicator series [autos_sask] with benchmarks [autos_sask]
#> -----------------------------------------------------------------------
#> 
#> Benchmarking indicator series [autos_man] with benchmarks [autos_man]
#> ---------------------------------------------------------------------
mes_series_eta <- tsDF_to_ts(
  cbind(res_eta$series, autos_tot = mes_series[, "autos_tot"]),
  frequency = frequency(mes_series)
)

# 3c) Réconcilier les données trimestrielles en préservant les totaux d'années finiacières.
res_ratis3 <- tsraking_driver(
  in_ts = mes_series_eta,
  metadata_df = mes_meta,
  temporal_grp_periodicity = frequency(mes_series),
  
  # Années financières d'avril à mars (T2 à T1)
  temporal_grp_start = 2,
  
  quiet = TRUE
)
#> 
#> 
#> Raking periods [2019-2 - 2020-1]
#> ================================
#> 
#> 
#> Raking periods [2020-2 - 2021-1]
#> ================================

# Données initiales
mes_series
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2        14         18        14        58
#> 2019 Q3        17         14        16        44
#> 2019 Q4        14         19        18        58
#> 2020 Q1        20         18        12        53
#> 2020 Q2        16         16        19        44
#> 2020 Q3        14         15        16        50
#> 2020 Q4        19         20        14        52
#> 2021 Q1        16         15        19        51

# Avec totaux d'années finiacières cohérents
mes_series_eta
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2  15.40737   19.84939  15.41097        58
#> 2019 Q3  18.90614   15.54094  17.78267        44
#> 2019 Q4  15.45221   20.98489  19.84697        58
#> 2020 Q1  21.60026   19.38252  12.83568        53
#> 2020 Q2  16.44068   16.41619  19.39307        44
#> 2020 Q3  13.91243   14.89512  15.85700        50
#> 2020 Q4  18.49133   19.47043  13.65082        52
#> 2021 Q1  15.50230   14.55494  18.41569        51

# Données réconciliées
res_ratis3
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2  17.77916   22.53212  17.68872        58
#> 2019 Q3  16.07232   12.91959  15.00808        44
#> 2019 Q4  16.06497   21.42285  20.51217        58
#> 2020 Q1  21.44952   18.88317  12.66732        53
#> 2020 Q2  13.84015   13.79962  16.36024        44
#> 2020 Q3  15.57114   16.65292  17.77593        50
#> 2020 Q4  18.62985   19.59265  13.77750        52
#> 2021 Q1  16.30560   15.29149  19.40291        51

# Vérifier les contraintes transversales en sortie
all.equal(
  rowSums(res_ratis3[, mes_meta$series]), 
  as.vector(res_ratis3[, "autos_tot"])
)
#> [1] TRUE

# Vérifier les contraintes temporelles en sortie (totaux des deux années financières pour 
# chaque série)
all.equal(
  rbind(
    aggregate.ts(window(mes_series_eta, start = c(2019, 2), end = c(2020, 1))),
    aggregate.ts(window(mes_series_eta, start = c(2020, 2), end = c(2021, 1)))
  ),
  rbind(
    aggregate.ts(window(res_ratis3, start = c(2019, 2), end = c(2020, 1))),
    aggregate.ts(window(res_ratis3, start = c(2020, 2), end = c(2021, 1)))
  )
)
#> [1] TRUE

# Vérifier le total de contrôle (fixe)
all.equal(mes_series[, "autos_tot"], res_ratis3[, "autos_tot"])
#> [1] TRUE
```
