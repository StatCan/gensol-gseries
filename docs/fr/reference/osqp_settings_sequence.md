# *Data frame* pour la séquence de paramètres d'OSQP

*Data frame* contenant une séquence de paramètres d'OSQP pour
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
spécifié avec l'argument `osqp_settings_df`. La librairie inclut deux
*data frames* prédéfinis de séquences de paramètres d'OSQP :

- `default_osqp_sequence` : rapide et efficace (valeur par défaut de
  l'argument `osqp_settings_df`);

- `alternate_osqp_sequence` : orienté vers la précision au détriment du
  temps d'exécution.

Voir
[`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md)
pour le contenu de ces *data frames*.

## Utilisation

``` r
# Séquence par défaut :
# tsbalancing(..., osqp_settings_df = default_osqp_sequence)

# Séquence alternative (plus lente) :
# tsbalancing(..., osqp_settings_df = alternate_osqp_sequence)

# Séquence personnalisée (à utiliser avec précaution !) :
# tsbalancing(..., osqp_settings_df = <mon-dataframe-de-sequence-osqp>)

# Une seule tentative de résolution avec les valeurs par défaut d'OSQP (déconseillé !) :
# tsbalancing(..., osqp_settings_df = NULL)
```

## Format

Un *data frame* avec au moins un enregistrement (une rangée) et au moins
une colonne, les colonnes *les plus courantes* étant :

- max_iter:

  Nombre maximal d'itérations (*integer*)

- sigma:

  Pas sigma (*sigma step*) de la méthode des multiplicateurs à direction
  alternée (MMDA, ou ADMM en anglais pour *alternating direction method
  of multipliers*) (*double*)

- eps_abs:

  Tolérance absolue (*double*)

- eps_rel:

  Tolérance relative (*double*)

- eps_prim_inf:

  Tolérance d'infaisabilité du problème primal (*double*)

- eps_dual_inf:

  Tolérance d'infaisabilité du problème dual (*double*)

- polishing:

  Effectuer l'étape de raffinement de la solution (*logical*)

- scaling:

  Nombre d'itérations de mise à l'échelle (*integer*)

- prior_scaling:

  Mise à l'échelle préalable des données, avant la résolution avec OSQP
  (*logical*)

- require_polished:

  Exiger une solution raffinée (*polished solution*) pour arrêter la
  séquence (*logical*)

- \[*any-other-OSQP-setting*\]:

  Valeur du paramètre OSQP correspondant

## Détails

À l'exception de `prior_scaling` et `require_polished`, toutes les
colonnes du *data frame* doivent correspondre à un paramètre d'OSQP. Les
valeurs par défaut d'OSQP sont utilisées pour tout paramètre non
spécifié dans ce *data frame*. Visitez
<https://osqp.org/docs/interfaces/solver_settings.html> pour connaître
tous les paramètres d'OSQP disponibles. Notez que le paramètre d'OSQP
`verbose` est en fait contrôlé par les arguments `quiet` et
`display_level` de
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
(c'est à dire que la colonne `verbose` dans un *data frame pour la
séquence de paramètres d'OSQP* serait ignorée).

Chaque enregistrement (rangée) d'un *data frame pour la séquence de
paramètres d'OSQP* représente une tentative de résolution d'un problème
d'équilibrage avec les paramètres d'OSQP correspondants. La séquence de
résolution s'arrête dès qu'une solution valide est obtenue (une solution
pour laquelle tous les écarts de contraintes sont inférieurs ou égaux à
la tolérance spécifiée avec l'argument `validation_tol` de
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md))
à moins que la colonne `require_polished = TRUE`, auquel cas une
solution *raffinée* d'OSQP (`status_polish = 1`) serait également
nécessaire pour arrêter la séquence. Les écarts de contraintes
correspondent à \\\mathrm{max}(0, l - Ax, Ax - u)\\ avec des contraintes
définies comme \\l \le Ax \le u\\. Dans le cas où une solution
satisfaisante ne peut être obtenue après avoir parcouru toute la
séquence,
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
renvoie la solution qui a généré le plus petit total d'écarts de
contraintes parmi les solutions valides, le cas échéant, ou parmi toutes
les solutions, dans le cas contraire. Notez que l'exécution de la
séquence de résolution entière peut être *forcée* en spécifiant
l'argument `full_sequence = TRUE` avec
[`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md).
Les enregistrements avec la colonne `prior_scaling = TRUE` ont les
données du problème mises à l'échelle avant la résolution avec OSQP, en
utilisant la moyenne des valeurs libres (non contraignantes) du problème
comme facteur d'échelle.

En plus de spécifier un *data frame pour la séquence de paramètres
d'OSQP* personnalisé avec l'argument `osqp_settings_df`, on peut aussi
spécifier `osqp_settings_df = NULL` ce qui résultera en une seule
tentative de résolution avec les valeurs par défaut d'OSQP pour tous les
paramètres et avec `prior_scaling = FALSE` et
`require_polished = FALSE`. Il est cependant recommandé d'essayer
d'abord les *data frames* `default_osqp_sequence` et
`alternate_osqp_sequence`, avec `full_sequence = TRUE` si nécessaire,
avant d'envisager d'autres alternatives.

La vignette *« Data frame » pour la séquence de paramètres d’OSQP*
([`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md))
contient des informations supplémentaires.
