# Rétablir les contraintes linéaires transversales (contemporaines)

*Réplication de la macro **GSeriesTSBalancing** de G-Séries 2.0 en
SAS\\^\circledR\\. Voir la documentation de G-Séries 2.0 pour plus de
détails (Statistique Canada 2016).*

Cette fonction équilibre (réconcilie) un système de séries
chronologiques selon un ensemble de contraintes linéaires. La solution
d'équilibrage (« *balancing* ») est obtenue en résolvant un ou plusieurs
problèmes de minimisation quadratique (voir la section **Détails**) avec
le solveur OSQP (Stellato et al. 2020). Étant donné la faisabilité du
(des) problème(s) d'équilibrage, les données des séries chronologiques
résultantes respectent les contraintes spécifiées pour chaque période.
Des contraintes linéaires d'égalité et d'inégalité sont permises.
Optionnellement, la préservation des totaux temporels peut également
être spécifiée.

## Utilisation

``` r
tsbalancing(
  in_ts,
  problem_specs_df,
  temporal_grp_periodicity = 1,
  temporal_grp_start = 1,
  osqp_settings_df = default_osqp_sequence,
  display_level = 1,
  alter_pos = 1,
  alter_neg = 1,
  alter_mix = 1,
  alter_temporal = 0,
  lower_bound = -Inf,
  upper_bound = Inf,
  tolV = 0,
  tolV_temporal = 0,
  tolP_temporal = NA,

  # Nouveau dans G-Séries 3.0
  validation_tol = 0.001,
  trunc_to_zero_tol = validation_tol,
  full_sequence = FALSE,
  validation_only = FALSE,
  quiet = FALSE
)
```

## Arguments

- in_ts:

  (obligatoire)

  Objet de type série chronologique (classe « ts » ou « mts ») qui
  contient les données des séries chronologiques à réconcilier. Il
  s'agit des données d'entrée (solutions initiales) des problèmes
  d'équilibrage (« *balancing* »).

- problem_specs_df:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») des spécifications du
  problème d'équilibrage. En utilisant un format clairsemé (épars)
  inspiré de la procédure LP de SAS/OR\\^\circledR\\ (SAS Institute
  2015), il ne contient que les informations pertinentes telles que les
  coefficients non nuls des contraintes d'équilibrage ainsi que les
  coefficients d'altérabilité et les bornes inférieures/supérieures à
  utiliser au lieu des valeurs par défaut (c.-à-d., les valeurs qui
  auraient la priorité sur celles définies avec les arguments
  `alter_pos`, `alter_neg`, `alter_mix`, `alter_temporal`, `lower_bound`
  et `upper_bound`).

  Les informations sont fournies à l'aide de quatre variables
  obligatoires (`type`, `col`, `row` et `coef`) et d'une variable
  facultative (`timeVal`). Un enregistrement (une rangée) dans le *data
  frame* des spécifications du problème définit soit une étiquette pour
  l'un des sept types d'éléments du problème d'équilibrage avec les
  colonnes `type` et `row` (voir *Enregistrements de définition
  d'étiquette* ci-dessous) ou bien spécifie des coefficients (valeurs
  numériques) pour ces éléments du problème d'équilibrage avec les
  variables `col`, `row`, `coef` et `timeVal` (voir *Enregistrements de
  spécification d'information* ci-dessous).

  - **Enregistrements de définition d'étiquette** (`type` n'est pas
    manquant (n'est pas `NA`))

    - `type` (car) : mot-clé réservé identifiant le type d'élément du
      problème en cours de définition :

      - `EQ` : contrainte d'équilibrage d'égalité (\\=\\)

      - `LE` : contrainte d'équilibrage d'inégalité de type inférieure
        ou égale (\\\le\\)

      - `GE` : contrainte d'équilibrage d'inégalité de type supérieure
        ou égale (\\\ge\\)

      - `lowerBd` : borne inférieure des valeurs de période

      - `upperBd` : borne supérieure des valeurs de période

      - `alter` : coefficient d'altérabilité des valeurs de période

      - `alterTmp` : coefficient d'altérabilité des totaux temporels

    - `row` (car) : étiquette à associer à l'élément du problème
      (*mot-clé `type`*)

    - *toutes les autres variables ne sont pas pertinentes et devraient
      contenir des données manquantes (valeurs `NA`)*  
        

  - **Enregistrements de spécification d'information** (`type` est
    manquant (est `NA`))

    - `type` (car) : non applicable (`NA`)

    - `col` (car) : nom de la série ou mot réservé `_rhs_` pour
      spécifier la valeur du côté droit (*RHS* pour ***R**ight-**H**and
      **S**ide*) d'une contrainte d'équilibrage.

    - `row` (car) : étiquette de l'élément du problème.

    - `coef` (num) : valeur de l'élément du problème :

      - coefficient de la série dans la contrainte d'équilibrage ou
        valeur *RHS*

      - borne inférieure ou supérieure des valeurs de période de la
        série

      - coefficient d'altérabilité des valeurs de période ou des totaux
        temporels de la série

    - `timeVal` (num) : valeur de temps optionnelle pour restreindre
      l'application des bornes ou coefficients d'altérabilité des séries
      à une période (ou groupe temporel) spécifique. Elle correspond à
      la valeur de temps, telle que renvoyée par
      [`stats::time()`](https://rdrr.io/r/stats/time.html), pour une
      période (observation) donnée des séries chronologiques d'entrée
      (argument `in_ts`) et correspond conceptuellement à
      \\ann\acute{e}e + (p\acute{e}riode - 1) / fr\acute{e}quence\\.

  Notez que les chaînes de caractères vides (`""` ou `''`) pour les
  variables de type caractère sont interprétées comme manquantes (`NA`)
  par la fonction. La variable `row` identifie les éléments du problème
  d'équilibrage et est la variable clé qui fait le lien entre les deux
  types d'enregistrements. La même étiquette (`row`) ne peut être
  associée à plus d'un type d'éléments du problème (`type`) et plusieurs
  étiquettes (`row`) ne peuvent pas être définies pour un même type
  d'éléments du problème donné (`type`), à l'exception des contraintes
  d'équilibrage (valeurs `"EQ"`, `"LE"` et `"GE"` de la colonne `type`).
  Voici certaines caractéristiques conviviales du *data frame* des
  spécifications du problème :

  - L'ordre des enregistrements (rangées) n'est pas important.

  - Les valeurs des variables de type caractère (`type`, `row` et `col`)
    ne sont pas sensibles à la casse (ex., les chaînes de caractères
    `"Constraint 1"` et `"CONSTRAINT 1"` pour la variable `row` seraient
    considérées comme une même étiquette d'élément du problème), sauf
    lorsque `col` est utilisé pour spécifier un nom de série (une
    colonne de l'objet d'entrée de type série chronologique) où **la
    sensibilité à la casse est appliquée**.

  - Les noms des variables du *data frame* des spécifications du
    problème ne sont pas non plus sensibles à la casse (ex., `type`,
    `Type` ou `TYPE` sont tous des noms de variable valides) et
    `time_val` est un nom de variable accepté (au lieu de `timeVal`).

  Enfin, le tableau suivant dresse la liste des alias valides (acceptés)
  pour les *mots-clés `type`* (type d'éléments du problème) :

  |  |  |
  |----|----|
  | **Mot-clé** | **Alias** |
  | `EQ` | `==`, `=` |
  | `LE` | `<=`, `<` |
  | `GE` | `>=`, `>` |
  | `lowerBd` | `lowerBound`, `lowerBnd`, + *mêmes termes avec '\_', '.' ou ' ' entre les mots* |
  | `upperBd` | `upperBound`, `upperBnd`, + *mêmes termes avec '\_', '.' ou ' ' entre les mots* |
  | `alterTmp` | `alterTemporal`, `alterTemp`, + *mêmes termes avec '\_', '.' ou ' ' entre les mots* |

  L'examen des **Exemples** devrait aider à conceptualiser le *data
  frame* des spécifications du problème d'équilibrage.

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

- osqp_settings_df:

  (optionnel)

  *Data frame* (object de classe « data.frame ») contenant une séquence
  de paramètres d'OSQP pour la résolution des problèmes d'équilibrage.
  La librairie inclut deux *data frames* prédéfinis de séquences de
  paramètres d'OSQP :

  - [default_osqp_sequence](https://StatCan.github.io/gensol-gseries/fr/reference/osqp_settings_sequence.md) :
    rapide et efficace (par défaut);

  - [alternate_osqp_sequence](https://StatCan.github.io/gensol-gseries/fr/reference/osqp_settings_sequence.md) :
    orienté vers la précision au détriment du temps d'exécution.

  Voir la
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md)
  pour plus de détails sur ce sujet et pour voir le contenu de ces deux
  *data frames*. Notez que le concept d'une *séquence de résolution*
  avec différents ensembles de paramètres pour le solveur est nouveau
  dans G-Séries 3.0 (une seule tentative de résolution était effectuée
  dans G-Séries 2.0).

  **La valeur par défaut** est
  `osqp_settings_df = default_osqp_sequence`.

- display_level:

  (optionnel)

  Entier dans l'intervalle \[0 .. 3\] spécifiant le niveau d'information
  à afficher dans la console
  ([`stdout()`](https://rdrr.io/r/base/showConnections.html)). Notez que
  spécifier l'argument `quiet = TRUE` annulerait l'argument
  `display_level` (aucune des informations suivantes ne serait
  affichée).

  |  |  |  |  |  |
  |----|----|----|----|----|
  | **Information affichée** | **`0`** | **`1`** | **`2`** | **`3`** |
  | En-tête de la fonction | \\\checkmark\\ | \\\checkmark\\ | \\\checkmark\\ | \\\checkmark\\ |
  | Éléments du problème d'équilibrage |  | \\\checkmark\\ | \\\checkmark\\ | \\\checkmark\\ |
  | Détails de résolution de chaque problème |  |  | \\\checkmark\\ | \\\checkmark\\ |
  | Résultats de chaque problème (valeurs et contraintes) |  |  |  | \\\checkmark\\ |

  **La valeur par défaut** est `display_level = 1`.

- alter_pos:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut associé aux valeurs des séries chronologiques avec des
  coefficients **positifs** dans toutes les contraintes d'équilibrage
  dans lesquelles elles sont impliquées (ex., les séries composantes
  dans les problèmes de ratissage (« *raking* ») de tables
  d'agrégation). Les coefficients d'altérabilité fournis dans le *data
  frame* des spécifications du problème (argument `problem_specs_df`)
  remplacent cette valeur.

  **La valeur par défaut** est `alter_pos = 1.0` (valeurs non
  contraignantes).

- alter_neg:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut associé aux valeurs des séries chronologiques avec des
  coefficients **négatifs** dans toutes les contraintes d'équilibrage
  dans lesquelles elles sont impliquées (ex., les séries de total de
  marge dans les problèmes de ratissage (« *raking* ») de tables
  d'agrégation). Les coefficients d'altérabilité fournis dans le *data
  frame* des spécifications du problème (argument `problem_specs_df`)
  remplacent cette valeur.

  **La valeur par défaut** est `alter_neg = 1.0` (valeurs non
  contraignantes).

- alter_mix:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut associé aux valeurs des séries chronologiques avec un mélange
  de coefficients **positifs et négatifs** dans les contraintes
  d'équilibrage dans lesquelles elles sont impliquées. Les coefficients
  d'altérabilité fournis dans le *data frame* des spécifications du
  problème (argument `problem_specs_df`) remplacent cette valeur.

  **La valeur par défaut** est `alter_mix = 1.0` (valeurs non
  contraignantes).

- alter_temporal:

  (optionnel)

  Nombre réel non négatif spécifiant le coefficient d'altérabilité par
  défaut associé aux totaux temporels des séries chronologiques. Les
  coefficients d'altérabilité fournis dans le *data frame* des
  spécifications du problème (argument `problem_specs_df`) remplacent
  cette valeur.

  **La valeur par défaut** est `alter_temporal = 0.0` (valeurs
  contraignantes).

- lower_bound:

  (optionnel)

  Nombre réel spécifiant la borne inférieure par défaut pour les valeurs
  des séries chronologiques. Les bornes inférieures fournies dans le
  *data frame* des spécifications du problème (argument
  `problem_specs_df`) remplacent cette valeur.

  **La valeur par défaut** est `lower_bound = -Inf` (non borné).

- upper_bound:

  (optionnel)

  Nombre réel spécifiant la borne supérieure par défaut pour les valeurs
  des séries chronologiques. Les bornes supérieures fournies dans le
  *data frame* des spécifications du problème (argument
  `problem_specs_df`) remplacent cette valeur.

  **La valeur par défaut** est `upper_bound = Inf` (non borné).

- tolV:

  (optionnel)

  Nombre réel non négatif spécifiant la tolérance, en valeur absolue, de
  la valeur du côté droit (*RHS*) des contraintes d'équilibrage :

  - Contraintes `EQ` : \\\quad A\mathbf{x} = \mathbf{b} \quad\\ devient
    \\\quad \mathbf{b} - \epsilon \le A\mathbf{x} \le \mathbf{b} +
    \epsilon\\

  - Contraintes `LE` : \\\quad A\mathbf{x} \le \mathbf{b} \quad\\
    devient \\\quad A\mathbf{x} \le \mathbf{b} + \epsilon\\

  - Contraintes `GE` : \\\quad A\mathbf{x} \ge \mathbf{b} \quad\\
    devient \\\quad A\mathbf{x} \ge \mathbf{b} - \epsilon\\

  où \\\epsilon\\ est la tolérance spécifiée avec `tolV`. Cet argument
  ne s'applique pas aux *bornes (inférieures et supérieures) des valeurs
  de période* spécifiées avec les arguments `lower_bound` et
  `upper_bound` ou dans le *data frame* des spécifications du problème
  (argument `prob_specs_df`). Autrement dit, `tolV` n'affecte pas les
  bornes inférieure et supérieure des valeurs des séries chronologiques,
  à moins qu'elles ne soient spécifiées comme *contraintes
  d'équilibrage* à la place (avec des contraintes `GE` et `LE` dans le
  *data frame* des spécifications du problème).

  **La valeur par défaut** est `tolV = 0.0` (pas de tolérance).

- tolV_temporal, tolP_temporal:

  (optionnel)

  Nombre réel non négatif, ou `NA`, spécifiant la tolérance, en
  pourcentage (`tolP_temporal`) ou en valeur absolue (`tolV_temporal`),
  pour les contraintes implicites d'agrégation temporelle associées aux
  **totaux temporels contraignants** \\\left( \sum_t{x\_{i,t}} =
  \sum_t{y\_{i,t}} \right)\\, qui deviennent : \$\$\sum_t{y\_{i,t}} -
  \epsilon\_\text{abs} \le \sum_t{x\_{i,t}} \le \sum_t{y\_{i,t}} +
  \epsilon\_\text{abs}\$\$ ou \$\$\sum_t{y\_{i,t}} \left( 1 -
  \epsilon\_\text{rel} \right) \le \sum_t{x\_{i,t}} \le \sum_t{y\_{i,t}}
  \left( 1 + \epsilon\_\text{rel} \right)\$\$

  où \\\epsilon\_\text{abs}\\ et \\\epsilon\_\text{rel}\\ sont les
  tolérances absolues et en pourcentage spécifiées respectivement avec
  `tolV_temporal` et `tolP_temporal`. Les deux arguments ne peuvent pas
  être spécifiés tous les deux à la fois (l'un doit être spécifié tandis
  que l'autre doit être `NA`).

  **Exemple :** pour une tolérance de 10 *unités*, spécifiez
  `tolV_temporal = 10, tolP_temporal = NA`; pour une tolérance de 1%,
  spécifiez `tolV_temporal = NA, tolP_temporal = 0.01`.

  **Les valeurs par défaut** sont `tolV_temporal = 0.0` et
  `tolP_temporal = NA` (pas de tolérance).

- validation_tol:

  (optionnel)

  Nombre réel non négatif spécifiant la tolérance pour la validation des
  résultats d'équilibrage. La fonction vérifie si les valeurs finales
  des séries chronologiques (réconciliées) satisfont les contraintes, en
  autorisant des écarts jusqu'à la valeur spécifiée avec cet argument.
  Un avertissement est émis dès qu'une contrainte n'est pas respectée
  (écart supérieur à `validation_tol`).

  Avec des contraintes définies comme \\\mathbf{l} \le A\mathbf{x} \le
  \mathbf{u}\\, où \\\mathbf{l = u}\\ pour les contraintes `EQ`,
  \\\mathbf{l} = -\infty\\ pour les contraintes `LE` et \\\mathbf{u} =
  \infty\\ pour les contraintes `GE`, **les écarts de contraintes**
  correspondent à \\\max \left( 0, \mathbf{l} - A\mathbf{x},
  A\mathbf{x} - \mathbf{u} \right)\\, où les bornes de contraintes
  \\\mathbf{l}\\ et \\\mathbf{u}\\ incluent les tolérances, le cas
  échéant, spécifiées avec les arguments `tolV`, `tolV_temporal` et
  `tolP_temporal`.

  **La valeur par défaut** est `validation_tol = 0.001`.

- trunc_to_zero_tol:

  (optionnel)

  Nombre réel non négatif spécifiant la tolérance, en valeur absolue,
  pour le remplacement par zéro de (petites) valeurs dans les données
  (réconciliées) de séries chronologiques de sortie (objet de sortie
  `out_ts`). Spécifiez `trunc_to_zero_tol = 0` pour désactiver ce
  processus de *troncation à zéro* des données réconciliées. Sinon,
  spécifiez `trunc_to_zero_tol > 0` pour remplacer par \\0.0\\ toute
  valeur dans l'intervalle \\\left\[ -\epsilon, \epsilon \right\]\\, où
  \\\epsilon\\ est la tolérance spécifiée avec `trunc_to_zero_tol`.

  Notez que les écarts de contraintes finaux (voir l'argument
  `validation_tol`) sont calculées sur les séries chronologiques
  réconciliées *tronquées à zéro*, ce qui garantit une validation
  précise des données réconciliées réelles renvoyées par la fonction.

  **La valeur par défaut** est `trunc_to_zero_tol = validation_tol`.

- full_sequence:

  (optionnel)

  Argument logique (*logical*) spécifiant si toutes les étapes du *data
  frame pour la séquence de paramètres d'OSQP* doivent être exécutées ou
  non. Voir l'argument `osqp_settings_df` et la
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md)
  pour plus de détails sur ce sujet.

  **La valeur par défaut** est `full_sequence = FALSE`.

- validation_only:

  (optionnel)

  Argument logique (*logical*) spécifiant si la fonction doit uniquement
  effectuer la validation des données d'entrée ou non. Lorsque
  `validation_only = TRUE`, les *contraintes d'équilibrage* et les
  *bornes (inférieures et supérieures) des valeurs de période*
  spécifiées sont validées par rapport aux données de séries
  chronologiques d'entrée, en permettant des écarts jusqu'à la valeur
  spécifiée avec l'argument `validation_tol`. Sinon, lorsque
  `validation_only = FALSE` (par défaut), les données d'entrée sont
  d'abord réconciliées et les données résultantes (en sortie) sont
  ensuite validées.

  **La valeur par défaut** est `validation_only = FALSE`.

- quiet:

  (optionnel)

  Argument logique (*logical*) spécifiant s'il faut ou non afficher
  uniquement les informations essentielles telles que les
  avertissements, les erreurs et la période (ou l'ensemble de périodes)
  en cours de traitement. Vous pouvez également supprimer, si vous le
  souhaitez, l'affichage des informations relatives à la (aux)
  période(s) en cours de traitement en *enveloppant* votre appel à
  `tsbalancing()` avec
  [`suppressMessages()`](https://rdrr.io/r/base/message.html). Dans ce
  cas, le *data frame* de sortie `proc_grp_df` peut être utilisé pour
  identifier les problèmes d'équilibrage (infructueux) associés aux
  messages d'avertissement (le cas échéant). Notez que la spécification
  de `quiet = TRUE` annulera également l'argument `display_level`.

  **La valeur par défaut** est `quiet = FALSE`.

## Valeur de retour

La fonction renvoie une liste de sept objets :

- `out_ts` : version modifiée de l'objet d'entrée de type série
  chronologique (classe « ts » ou « mts » ; voir l'argument `in_ts`)
  contenant les valeurs réconciliées des séries chronologiques qui
  résultent de l'exécution de la fonction (sortie principale de la
  fonction). Il peut être explicitement converti en un autre type
  d'objet avec la fonction `as*()` appropriée (ex.,
  `tsibble::as_tsibble()` le convertirait en tsibble).

- `proc_grp_df` : *data frame* récapitulatif des groupes de traitement,
  utile pour identifier les problèmes fructueux ou infructueux. Il
  contient un enregistrement (une rangée) pour chaque problème
  d'équilibrage avec les colonnes suivantes :

  - `proc_grp` (num) : identificateur du groupe de traitement.

  - `proc_grp_type` (car) : type de groupe de traitement. Les valeurs
    possibles sont :

    - `"period"` (périodes uniques);

    - `"temporal group"` (groupes temporels).

  - `proc_grp_label` (car) : chaîne de caractères décrivant le groupe de
    traitement dans le format suivant :

    - `"<year>-<period>"` (périodes uniques)

    - `"<start year>-<start period> - <end year>-<end period>"` (groupes
      temporels)

  - `sol_status_val`, `sol_status` (num, car) : valeur numérique
    (entière) et chaîne de caractères associés au statut de la
    solution :

    - ` 1` : `"valid initial solution"` (solution initiale valide);

    - `-1` : `"invalid initial solution"` (solution initiale invalide);

    - ` 2` : `"valid polished osqp solution"` (solution OSQP *raffinée*
      valide);

    - `-2` : `"invalid polished osqp solution"` (solution OSQP
      *raffinée* invalide);

    - ` 3` : `"valid unpolished osqp solution"` (solution OSQP *non
      raffinée* valide);

    - `-3` : `"invalid unpolished osqp solution"` (solution OSQP *non
      raffinée* invalide);

    - `-4` : `"unsolvable fixed problem"` (problème fixe insoluble, avec
      solution initiale invalide).

  - `n_unmet_con` (num) : nombre de contraintes non satisfaites
    (`sum(prob_conf_df$unmet_flag)`).

  - `max_discr` (num) : écart de contrainte maximal
    (`max(prob_conf_df$discr_out)`).

  - `validation_tol` (num) : tolérance spécifiée à des fins de
    validation (argument `validation_tol`).

  - `sol_type` (car) : type de solution renvoyée. Les valeurs possibles
    sont :

    - `"initial"` (solution initiale, c.-à-d., les valeurs des données
      d'entrée);

    - `"osqp"` (solution OSQP).

  - `osqp_attempts` (num) : nombre de tentatives effectuées avec OSQP
    (profondeur atteinte dans la séquence de résolution).

  - `osqp_seqno` (num) : numéro d'étape de la séquence de résolution
    correspondant à la solution renvoyée. `NA` lorsque
    `sol_type = "initial"`.

  - `osqp_status` (car) : chaîne de caractères décrivant le statut OSQP
    (`osqp_sol_info_df$status`). `NA` lorsque `sol_type = "initial"`.

  - `osqp_polished` (logi) : `TRUE` si la solution OSQP renvoyée est
    *raffinée* (`osqp_sol_info_df$status_polish = 1`), `FALSE` sinon.
    `NA` lorsque `sol_type = "initial"`.

  - `total_solve_time` (num) : temps total, en secondes, de la séquence
    de résolution.

  La colonne `proc_grp` constitue une *clé unique* (enregistrements
  distincts) pour le *data frame*. Les problèmes d'équilibrage fructueux
  (problèmes avec une solution valide) correspondent aux enregistrements
  avec `sol_status_val > 0` ou, de manière équivalente, à
  `n_unmet_con = 0` ou à `max_discr <= validation_tol`. La *solution
  initiale* (`sol_type = "initial"`) n'est renvoyée que si **a)** il n'y
  a pas de d'écarts de contraintes initiaux, **b)** le problème est fixé
  (toutes les valeurs sont contraignantes) ou **c)** elle est meilleure
  que la solution OSQP (total des écarts de contraintes plus faible). La
  séquence de résolution est décrite dans la
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md).

- `periods_df` : *data frame* sur les périodes de temps, utile pour
  faire correspondre les périodes aux groupes de traitement. Il contient
  un enregistrement (une rangée) pour chaque période de l'objet d'entrée
  de type série chronologique (argument `in_ts`) avec les colonnes
  suivantes :

  - `proc_grp` (num) : identificateur du groupe de traitement.

  - `t` (num) : identificateur de la période (`1:nrow(in_ts)`).

  - `time_val` (num) : valeur de temps (`stats::time(in_ts)`).
    Correspond conceptuellement à \\ann\acute{e}e +
    (p\acute{e}riode - 1) / fr\acute{e}quence\\.

  Les colonnes `t` et `time_val` constituent toutes deux une *clé
  unique* (enregistrements distincts) pour le *data frame*.

- `prob_val_df` : *data frame* sur les valeurs du problème, utile pour
  analyser les changements entre les valeurs initiales et finales
  (réconciliées). Il contient un enregistrement (une rangée) pour chaque
  valeur impliquée dans chaque problème d'équilibrage, avec les colonnes
  suivantes :

  - `proc_grp` (num) : identificateur du groupe de traitement.

  - `val_type` (car) : type de valeur du problème. Les valeurs possibles
    sont :

    - `"period value"` (valeur de période);

    - `"temporal total"` (total temporel).

  - `name` (car) : nom de la série chronologique (variable).

  - `t` (num) : identificateur de la période (`1:nrow(in_ts)`);
    identificateur de la première période du groupe temporel pour un
    *total temporel*.

  - `time_val` (num) : valeur de temps (`stats::time(in_ts)`); valeur de
    la première période du groupe temporel pour un *total temporel*.
    Correspond conceptuellement à \\ann\acute{e}e +
    (p\acute{e}riode - 1) / fr\acute{e}quence\\.

  - `lower_bd`, `upper_bd` (num) : bornes des valeurs de période;
    toujours `-Inf` et `Inf` pour un *total temporel*.

  - `alter` (num) : coefficient d'altérabilité.

  - `value_in`, `value_out` (num) : valeurs initiales et finales
    (réconciliées).

  - `dif` (num) : `value_out - value_in`.

  - `rdif` (num) : `dif / value_in`; `NA` si `value_in = 0`.

  Les colonnes `val_type + name + t` et `val_type + name + time_val`
  constituent toutes deux une *clé unique* (enregistrements distincts)
  pour le *data frame*. Les valeurs contraignantes (fixes) des problèmes
  correspondent aux enregistrements avec `alter = 0` ou `value_in = 0`.
  Inversement, les valeurs de problèmes non contraignantes (libres)
  correspondent aux enregistrements avec `alter != 0` et
  `value_in != 0`.

- `prob_con_df` : *data frame* sur les contraintes du problème, utile
  pour dépanner les problèmes infructueux (identifier les contraintes
  non satisfaites). Il contient un enregistrement (une rangée) pour
  chaque contrainte impliquée dans chaque problème d'équilibrage, avec
  les colonnes suivantes :

  - `proc_grp` (num) : identificateur du groupe de traitement.

  - `con_type` (car) : type de contrainte. Les valeurs possibles sont :

    - `"balancing constraint"` (contrainte d'équilibrage);

    - `"temporal aggregation constraint"` (contrainte d'agrégation
      temporelle);

    - `"period value bounds"` (bornes de valeur de période).

    Alors que les *contraintes d'équilibrage* sont spécifiées par
    l'utilisateur, les deux autres types de contraintes (*contraintes
    d'agrégation temporelle* et *bornes de valeur de période*) sont
    automatiquement ajoutées au problème par la fonction (le cas
    échéant).

  - `name` (car) : étiquette de la contrainte ou nom de la série
    chronologique (variable).

  - `t` (num) : identificateur de la période (`1:nrow(in_ts)`);
    identificateur de la première période du groupe temporel pour une
    *contrainte d'agrégation temporelle*.

  - `time_val` (num) : valeur de temps (`stats::time(in_ts)`); valeur de
    la première période du groupe temporel pour une *contrainte
    d'agrégation temporelle*. Correspond conceptuellement à
    \\ann\acute{e}e + (p\acute{e}riode - 1) / fr\acute{e}quence\\.

  - `l`, `u`, `Ax_in`, `Ax_out` (num) : éléments de contrainte initiaux
    et finaux \\\left( \mathbf{l} \le A \mathbf{x} \le \mathbf{u}
    \right)\\.

  - `discr_in`, `discr_out` (num) : écarts de contrainte initiaux et
    finaux \\\left( \max \left( 0, \mathbf{l} - A \mathbf{x}, A
    \mathbf{x} - \mathbf{u} \right) \right)\\.

  - `validation_tol` (num) : tolérance spécifiée à des fins de
    validation (argument `validation_tol`).

  - `unmet_flag` (logi) : `TRUE` si la contrainte n'est pas satisfaite
    (`discr_out > validation_tol`), `FALSE` sinon.

  Les colonnes `con_type + name + t` et `con_type + name + time_val`
  constituent toutes deux une *clé unique* (enregistrements distincts)
  pour le *data frame*. Les bornes de contrainte \\\mathbf{l = u}\\ pour
  des contraintes `EQ`, \\\mathbf{l} = -\infty\\ pour des contraintes
  `LE`, \\\mathbf{u} = \infty\\ pour des contraintes `GE`, et incluent
  les tolérances, le cas échéant, spécifiées avec les arguments `tolV`,
  `tolV_temporal` et `tolP_temporal`.

- `osqp_settings_df` : *data frame* des paramètres d'OSQP. Il contient
  un enregistrement (une rangée) pour chaque problème (groupe de
  traitement) résolu avec OSQP (`proc_grp_df$sol_type = "osqp"`), avec
  les colonnes suivantes :

  - `proc_grp` (num) : identificateur du groupe de traitement.

  - une colonne correspondant à chaque élément de la liste renvoyée par
    la méthode `osqp::GetParams()` appliquée à un *objet solveur d'OSQP*
    (objet de classe « OSQP_Model » tel que renvoyé par
    [`osqp::osqp()`](https://rdrr.io/pkg/osqp/man/osqp.html)), ex. :

    - Nombre maximal d'itérations (`max_iter`);

    - Tolérances d'infaisabilité primale et duale (`eps_prim_inf` et
      `eps_dual_inf`);

    - Drapeau d'exécution de l'étape de raffinement de la solution
      (`polishing`);

    - Nombre d'itérations de mise à l'échelle (`scaling`);

    - etc.

  - paramètres supplémentaires spécifiques à `tsbalancing()` :

    - `prior_scaling` (logi) : `TRUE` si les données du problème ont été
      mises à l'échelle (en utilisant la moyenne des valeurs libres (non
      contraignantes) du problème comme facteur d'échelle) avant la
      résolution avec OSQP, `FALSE` sinon.

    - `require_polished` (logi) : `TRUE` si une solution *raffinée*
      d'OSQP (`osqp_sol_info_df$status_polish = 1`) était nécessaire
      pour cette étape afin de terminer la séquence de résolution,
      `FALSE` sinon. Voir la
      [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md)
      pour plus de détails sur la séquence de résolution utilisée par
      `tsbalancing()`.

  La colonne `proc_grp` constitue une *clé unique* (enregistrements
  distincts) pour le *data frame*. Visitez le site
  <https://osqp.org/docs/interfaces/solver_settings.html> pour tous les
  paramètres d'OSQP disponibles. Les problèmes (groupes de traitement)
  pour lesquels la solution initiale a été renvoyée
  (`proc_grp_df$sol_type = "initial"`) ne sont pas inclus dans ce *data
  frame*.

- `osqp_sol_info_df` : *data frame* d'informations sur les solutions
  OSQP. Il contient un enregistrement (une rangée) pour chaque problème
  (groupe de traitement) résolu avec OSQP
  (`proc_grp_df$sol_type = "osqp"`), avec les colonnes suivantes :

  - `proc_grp` (num) : identificateur du groupe de traitement.

  - une colonne correspondant à chaque élément de la liste `info` d'un
    *objet solveur d'OSQP* (objet de classe « OSQP_Model » tel que
    renvoyé par
    [`osqp::osqp()`](https://rdrr.io/pkg/osqp/man/osqp.html)), ex. :

    - Statut de la solution (`status` et `status_val`) ;

    - Statut de raffinement de la solution (`status_polish`) ;

    - Nombre d'itérations (`iter`) ;

    - Valeur de la fonction objectif (`obj_val`) ;

    - Résidus primal et dual (`pri_res` et `dua_res`) ;

    - Temps de résolution (`solve_time`) ;

    - etc.

  - informations supplémentaires spécifiques à `tsbalancing()` :

    - `prior_scaling_factor` (num) : valeur du facteur d'échelle lorsque
      `osqp_settings_df$prior_scaling = TRUE`
      (`prior_scaling_factor = 1.0` sinon).

    - `obj_val_ori_prob` (num) : valeur de la fonction objectif du
      problème d'équilibrage original, qui est la valeur de la fonction
      objectif d'OSQP (`obj_val`) sur l'échelle originale (lorsque
      `osqp_settings_df$prior_scaling = TRUE`) plus le terme constant de
      la fonction objectif du problème d'équilibrage original, c.-à-d.,
      `obj_val_ori_prob = obj_val * prior_scaling_factor + <terme constant>`,
      où `<terme constant>` correspond à \\\mathbf{y}^{\mathrm{T}} W
      \mathbf{y}\\. Voir la section **Détails** pour la définition du
      vecteur \\\mathbf{y}\\, de la matrice \\W\\ et, plus généralement,
      de l'expression complète de la fonction objectif du problème
      d'équilibrage.

  La colonne `proc_grp` constitue une *clé unique* (enregistrements
  distincts) pour le *data frame*. Visitez <https://osqp.org> pour plus
  d'informations sur OSQP. Les problèmes (groupes de traitement) pour
  lesquels la solution initiale a été renvoyée
  (`proc_grp_df$sol_type = "initial"`) ne sont pas inclus dans ce *data
  frame*.

Notez que les objets de type « data.frame » renvoyés par la fonction
peuvent être explicitement convertis en d'autres types d'objets avec la
fonction `as*()` appropriée (ex.,
[`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
convertirait n'importe lequel d'entre eux en tibble).

## Détails

Cette fonction résout un problème d'équilibrage par groupe de traitement
(voir la section **Groupes de traitement** pour plus de détails). Chacun
de ces problèmes d'équilibrage est un problème de minimisation
quadratique de la forme suivante : \$\$\displaystyle \begin{aligned} &
\underset{\mathbf{x}}{\text{minimiser}} & & \mathbf{\left( y - x
\right)}^{\mathrm{T}} W \mathbf{\left( y - x \right)} \\ & \text{sous
contrainte(s)} & & \mathbf{l} \le A \mathbf{x} \le \mathbf{u}
\end{aligned} \$\$ où

- \\\mathbf{y}\\ est le vecteur des valeurs initiales du problème,
  c.-à-d., les valeurs de période initiales et, le cas échéant, les
  totaux temporels initiaux des séries chronologiques;

- \\\mathbf{x}\\ est la version finale (réconciliée) du vecteur
  \\\mathbf{y}\\;

- la matrice \\W = \mathrm{diag} \left( \mathbf{w} \right)\\ avec les
  éléments du vecteur \\\mathbf{w}\\ définis comme \\w_i = \left\\
  \begin{array}{cl} 0 & \text{if } \|c_i y_i\| = 0 \\ \frac{1}{\|c_i
  y_i\|} & \text{sinon} \end{array} \right. \\, où \\c_i\\ est
  coefficient d'altérabilité de la valeur du problème \\y_i\\ et où les
  cas correspondant à \\\|c_i y_i\| = 0\\ sont des valeurs fixes
  (valeurs de période ou totaux temporels contraignants);

- la matrice \\A\\ et les vecteurs \\\mathbf{l}\\ et \\\mathbf{u}\\
  définissent les *contraintes d'équilibrage*, les *contraintes
  implicites d'agrégation temporelle* (le cas échéant), les *bornes
  (inférieures et supérieures) des valeurs de période* et *les
  contraintes \\x_i = y_i\\ pour les valeurs \\y_i\\ fixes* \\\left(
  \left\| c_i y_i \right\| = 0 \right)\\.

En pratique, la fonction objectif du problème résolu par OSQP exclut le
terme constant \\\mathbf{y}^{\mathrm{T}} W \mathbf{y}\\, correspondant
alors à \\\mathbf{x}^{\mathrm{T}} W \mathbf{x} - 2 \left( \mathbf{w}
\mathbf{y} \right)^{\mathrm{T}} \mathbf{x}\\, et les valeurs \\y_i\\
fixes \\\left( \left\| c_i y_i \right\| = 0 \right)\\ sont exclues du
problème, en ajustant les contraintes en conséquence, c.-à-d. :

- les lignes correspondant aux *contraintes \\x_i = y_i\\ pour les
  valeurs \\y_i\\ fixes* sont supprimées de \\A\\, \\\mathbf{l}\\ et
  \\\mathbf{u}\\;

- les colonnes correspondant aux valeurs \\y_i\\ fixes sont supprimées
  de \\A\\ tout en ajustant de manière appropriée \\\mathbf{l}\\ et
  \\\mathbf{u}\\.

### Coefficients d'altérabilité

Les coefficients d'altérabilité sont des nombres non négatifs qui
modifient le coût relatif de la modification d'une valeur initiale du
problème. En modifiant la fonction objectif à minimiser, ils permettent
de générer un large éventail de solutions. Puisqu'ils apparaissent dans
le dénominateur de la fonction objectif (matrice \\W\\), plus le
coefficient d'altérabilité est élevé, moins il est coûteux de modifier
une valeur du problème (valeur de période ou total temporel) et,
inversement, plus le coefficient d'altérabilité est petit, plus il
devient coûteux de le faire. Il en résulte que les valeurs du problème
ayant des coefficients d'altérabilité plus élevés changent
proportionnellement plus que celles ayant des coefficients
d'altérabilité plus petits. Un coefficient d'altérabilité de \\0.0\\
définit une valeur de problème fixe (contraignante), tandis qu'un
coefficient d'altérabilité supérieur à \\0.0\\ définit une valeur libre
(non contraignante). Les coefficients d'altérabilité par défaut sont
\\0.0\\ pour les totaux temporels (argument `alter_temporal`) et \\1.0\\
pour les valeurs de période (arguments `alter_pos`, `alter_neg`,
`alter_mix`). Dans le cas courant des problèmes de ratissage
(« *raking* ») de tables d'agrégation, les valeurs de période des totaux
de marge (séries chronologiques avec un coefficient de \\-1\\ dans les
contraintes d'équilibrage) sont généralement contraignantes (spécifié
avec `alter_neg = 0`) tandis que les valeurs de période des séries
composantes (séries chronologiques avec un coefficient \\1\\ dans les
contraintes d'équilibrage) sont généralement non contraignantes
(spécifié avec `alter_pos > 0`, ex., `alter_pos = 1`). Des valeurs de
problème *presque contraignantes* (ex., pour les totaux de marge ou les
totaux temporels) peuvent être obtenues en pratique en spécifiant de
très petits (presque \\0.0\\) coefficents d'altérabilité par rapport à
ceux des autres valeurs (non contraignantes) du problème.

**La préservation des totaux temporels** fait référence au fait que les
totaux temporels, le cas échéant, sont généralement conservés « aussi
près que possible » de leur valeur initiale. Une *préservation pure* est
obtenue par défaut avec des totaux temporels contraignants, tandis que
le changement est minimisé avec des totaux temporels non contraignants
(conformément à l'ensemble de coefficients d'altérabilité utilisés).

### Validation et dépannage

Les problèmes d'équilibrage fructueux (problèmes avec une solution
valide) ont `sol_status_val > 0` ou, de manière équivalente,
`n_unmet_con = 0` ou `max_discr <= validation_tol` dans le *data frame*
de sortie `proc_grp_df`. Le dépannage des problèmes d'équilibrage
infructueux n'est pas nécessairement simple. Voici quelques
suggestions :

- Examinez les contraintes qui ont échoué (`unmet_flag = TRUE` ou, de
  manière équivalente, `discr_out > validation_tol` dans le *data frame*
  de sortie `prob_con_df`) pour s'assurer qu'elles ne causent pas un
  espace de solution vide (problème infaisable).

- Modifier la séquence de résolution d'OSQP. Par exemple, essayez :

  1.  l' argument `full_sequence = TRUE`

  2.  l' argument `osqp_settings_df = alternate_osqp_sequence`

  3.  les arguments `osqp_settings_df = alternate_osqp_sequence` et
      `full_sequence = TRUE`

  Voir la
  [`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md)
  pour plus de détails sur ce sujet.

- Augmenter (revoir) la valeur de `validation_tol`. Bien que cela puisse
  ressembler à de la *tricherie*, la valeur par défaut de
  `validation_tol` (\\1 \times 10^{-3}\\) peut en fait être trop petite
  pour les problèmes d'équilibrage qui impliquent de très grandes
  valeurs (ex., en milliards) ou, inversement, trop grande avec des
  valeurs de problème très petites (ex., \\\< 1.0\\). Multiplier
  l'échelle moyenne des données du problème par la *tolérance de la
  machine* (`.Machine$double.eps`) donne une approximation de la taille
  moyenne des écarts que `tsbalancing()` devrait être capable de
  détecter (distinguer de \\0\\) et devrait probablement constituer une
  **limite inférieure absolue** pour l'argument `validation_tol`. En
  pratique, une valeur raisonnable de `validation_tol` devrait
  probablement être de \\1 \times 10^3\\ à \\1 \times 10^6\\ fois plus
  grande que cette *limite inférieure*.

- S'attaquer aux contraintes redondantes. Les problèmes de ratissage
  (« *raking* ») de tables d'agrégation multidimensionnelles sont
  surspécifiés (ils impliquent des contraintes redondantes) lorsque tous
  les totaux de toutes les dimensions du *cube de données* sont
  contraignants (fixes) et qu'une contrainte est définie pour chacun
  d'entre eux. La redondance se produit également pour les contraintes
  implicites d'agrégation temporelle dans les tables d'agrégation
  unidimensionnelles ou multidimensionnelles avec des totaux temporels
  contraignants (fixes). La surspécification n'est généralement pas un
  problème pour `tsbalancing()` si les données d'entrée ne sont pas
  contradictoires en ce qui concerne les contraintes redondantes,
  c'est-à-dire, s'il n'y a pas d'incohérences (d'écarts) associées aux
  contraintes redondantes dans les données d'entrée ou si elles sont
  *négligeables* (raisonnablement faibles par rapport à l'échelle des
  données du problème). Dans le cas contraire, cela peut conduire à des
  problèmes d'équilibrage infructueux `tsbalancing()`. Les solutions
  possibles sont alors les suivantes :

  1.  Résoudre (ou réduire) les écarts associés aux contraintes
      redondantes dans les données d'entrée.

  2.  Sélectionner un total de marge dans chaque dimension, sauf une, du
      cube de données et supprimer du problème les contraintes
      d'équilibrage correspondantes. *Cela ne peut pas être fait pour
      les contraintes implicites d'agrégation temporelle.*

  3.  Sélectionnez un total de marge dans chaque dimension, sauf une, du
      cube de données et rendez-les non contraignantes (coefficient
      d'altérabilité de, disons, \\1.0\\).

  4.  Faire la même chose que (3) pour les totaux temporels d'une des
      séries composantes de l'intérieur du cube (les rendre non
      contraignants).

  5.  Rendre tous les totaux de marge de chaque dimension, sauf une, du
      cube de données *presque contraignants*, c.-à-d., spécifier de
      très petits coefficients d'altérabilité (disons \\1 \times
      10^{-6}\\) par rapport à ceux des séries composantes de
      l'intérieur du cube.

  6.  Faire la même chose que (5) pour les totaux temporels de toutes
      les séries composantes de l'intérieur du cube (coefficients
      d'altérabilité très petits, par exemple, avec l'argument
      `alter_temporal`).

  7.  Utilisez
      [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
      (le cas échéant), qui gère ces incohérences en utilisant l'inverse
      de Moore-Penrose (distribution uniforme à travers tous les totaux
      contraignants).

  Les solutions (2) à (7) ci-dessus ne doivent être envisagées que si
  les écarts associés aux contraintes redondantes dans les données
  d'entrée sont *raisonnablement faibles* car ils seraient distribués
  parmi les totaux omis ou non contraignants avec `tsbalancing()` et
  tous les totaux contraignants avec
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).
  Sinon, il faut d'abord étudier la solution (1) ci-dessus.

- Assouplir (relaxer) les bornes des contraintes du problème, par
  exemple :

  - avec l'argument `tolV` pour les contraintes d'équilibrage;

  - avec les arguments `tolV_temporal` et `tolP_temporal` pour les
    contraintes implicites d'agrégation temporelle;

  - avec les arguments `lower_bound` et `upper_bound`.

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

## Comparaison de [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md) et `tsbalancing()`

- [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  est limitée aux problèmes de ratissage (« *raking* ») de tables
  d'agrégation unidimensionnelles et bidimensionnelles (avec
  préservation des totaux temporels si nécessaire) alors que
  `tsbalancing()` traite des problèmes d'équilibrage plus généraux (ex.,
  des problèmes de ratissage de plus grande dimension, solutions non
  négatives, contraintes linéaires générales d'égalité et d'inégalité
  par opposition à des règles d'agrégation uniquement, etc.)

- [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  renvoie la solution des moindres carrés généralisés du modèle de
  ratissage basé sur la régression de Dagum et Cholette (Dagum et
  Cholette 2006) tandis que `tsbalancing()` résout le problème de
  minimisation quadratique correspondant à l'aide d'un solveur
  numérique. Dans la plupart des cas, la *convergence vers le minimum*
  est atteinte et la solution de `tsbalancing()` correspond à la
  solution (exacte) des moindres carrés de
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).
  Cela peut ne pas être le cas, cependant, si la convergence n'a pas pu
  être atteinte après un nombre raisonnable d'itérations. Cela dit, ce
  n'est qu'en de très rares occasions que la solution de `tsbalancing()`
  différera *significativement* de celle de
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).

- `tsbalancing()` est généralement plus rapide que
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md),
  en particulier pour les gros problèmes de ratissage, mais est
  généralement plus sensible à la présence de (petites) incohérences
  dans les données d'entrée associées aux contraintes redondantes des
  problèmes de ratissage *entièrement spécifiés* (ou surspécifiés).
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  gère ces incohérences en utilisant l'inverse de Moore-Penrose
  (distribution uniforme à travers tous les totaux contraignants).

- `tsbalancing()` permet de spécifier des problèmes épars (clairsemés)
  sous leur forme réduite. Ce n'est pas le cas de
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  où les règles d'agrégation doivent toujours être entièrement
  spécifiées étant donné qu'un *cube de données complet*, sans données
  manquantes, est attendu en entrée (chaque série composante de
  l'*intérieur du cube* doit contribuer à toutes les dimensions du cube,
  c.-à-d., à chaque série totale des *faces extérieures du cube*).

- Les deux outils traitent différemment les valeurs négatives dans les
  données d'entrée par défaut. Alors que les solutions des problèmes de
  ratissage obtenues avec `tsbalancing()` et
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  sont identiques lorsque tous les points de données d'entrée sont
  positifs, elles seront différentes si certains points de données sont
  négatifs (à moins que l'argument `Vmat_option = 2` ne soit spécifié
  avec
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)).

- Alors que `tsbalancing()` et
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  permettent toutes les deux de préserver les totaux temporels, la
  gestion du temps n'est pas incorporée dans
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).
  Par exemple, la construction des groupes de traitement (ensembles de
  périodes de chaque problème de ratissage) est laissée à l'utilisateur
  avec
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  et des appels séparés doivent être soumis pour chaque groupe de
  traitement (chaque problème de ratissage). De là l'utilité de la
  fonction d'assistance
  [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
  pour
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md).

- Les totaux marginaux (séries des faces extérieures du cube de données)
  renvoyés par
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  sont toujours recalculés comme la somme des séries composantes
  pertinentes (séries de l'intérieur du cube). Les valeurs de sortie des
  totaux marginaux **contraignants** peuvent donc légèrement différer
  des valeurs d’entrée. L’ampleur des différences dépend des
  incohérences initiales (qui sont uniformément distribuées par
  l’inverse de Moore-Penrose). Ce n’est pas le cas de `tsbalancing()` où
  les totaux marginaux **contraignants** restent toujours parfaitement
  inchangés, ce qui peut se traduire par des (petits) écarts en sortie
  entre la somme des séries composantes et le total marginal
  correspondant.

- `tsbalancing()` renvoie le même ensemble de séries que l'objet
  d'entrée de type série chronologique (argument `in_ts`) alors que
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
  renvoie l'ensemble des séries impliquées dans le problème de ratissage
  plus celles spécifiées avec l'argument `id` (qui pourrait correspondre
  à un sous-ensemble des séries d'entrée).

## Références

Dagum, E. B. et P. Cholette (2006). **Benchmarking, Temporal
Distribution and Reconciliation Methods of Time Series**.
Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
[doi:10.1007/0-387-35439-5](https://doi.org/10.1007/0-387-35439-5)

Ferland, M., S. Fortier et J. Bérubé (2016). « A Mathematical
Optimization Approach to Balancing Time Series: Statistics Canada’s
GSeriesTSBalancing ». Dans **JSM Proceedings, Business and Economic
Statistics Section**. Alexandria, VA: American Statistical Association.
2292-2306.

Ferland, M. (2018). « Time Series Balancing Quadratic Problem — Hessian
matrix and vector of linear objective function coefficients ».
**Document interne**. Statistique Canada, Ottawa, Canada.

Quenneville, B. et S. Fortier (2012). « Restoring Accounting Constraints
in Time Series – Methods and Software for a Statistical Agency ».
**Economic Time Series: Modeling and Seasonality**. Chapman & Hall, New
York.

SAS Institute Inc. (2015). « The LP Procedure Sparse Data Input
Format ». **SAS/OR\\^\circledR\\ 14.1 User's Guide: Mathematical
Programming Legacy Procedures**.
<https://support.sas.com/documentation/cdl/en/ormplpug/68158/HTML/default/viewer.htm#ormplpug_lp_details03.htm>

Statistique Canada (2016). « La macro ***GSeriesTSBalancing*** ».
**Guide de l'utilisateur de G-Séries 2.0**. Statistique Canada, Ottawa,
Canada.

Statistique Canada (2018). **Théorie et application de la réconciliation
(Code du cours 0437)**. Statistique Canada, Ottawa, Canada.

Stellato, B., G. Banjac, P. Goulart et al. (2020). « OSQP: an operator
splitting solver for quadratic programs ». **Math. Prog. Comp. 12**,
637–672 (2020).
[doi:10.1007/s12532-020-00179-2](https://doi.org/10.1007/s12532-020-00179-2)

## Voir également

[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
[`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
[`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/fr/reference/rkMeta_to_blSpecs.md)
[`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/fr/reference/gs.build_proc_grps.md)
[`build_balancing_problem()`](https://StatCan.github.io/gensol-gseries/fr/reference/build_balancing_problem.md)
[aliases](https://StatCan.github.io/gensol-gseries/fr/reference/aliases.md)

## Exemples

``` r
###########
# Exemple 1 : Dans ce premier exemple, l'objectif est d'équilibrer un tableau comptable simple 
#             (`Profits = Revenus - Depenses`), pour 5 trimestres, sans modifier les `Profits` 
#             et où `Revenus >= 0` et `Depenses >= 0`.

# Spécifications du problème
mes_specs1 <- data.frame(
  type = c(
    "EQ", rep(NA, 3), 
    "alter", NA, 
    "lowerBd", NA, NA
  ),
  col = c(
    NA, "Revenus", "Depenses", "Profits", 
    NA, "Profits", 
    NA, "Revenus", "Depenses"
  ),
  row = c(
    rep("Règle comptable", 4), 
    rep("Coefficient d'altérabilité", 2), 
    rep("Borne inférieure", 3)
  ),
  coef = c(
    NA, 1, -1, -1,
    NA, 0,
    NA, 0, 0
  )
)
mes_specs1
#>      type      col                        row coef
#> 1      EQ     <NA>            Règle comptable   NA
#> 2    <NA>  Revenus            Règle comptable    1
#> 3    <NA> Depenses            Règle comptable   -1
#> 4    <NA>  Profits            Règle comptable   -1
#> 5   alter     <NA> Coefficient d'altérabilité   NA
#> 6    <NA>  Profits Coefficient d'altérabilité    0
#> 7 lowerBd     <NA>           Borne inférieure   NA
#> 8    <NA>  Revenus           Borne inférieure    0
#> 9    <NA> Depenses           Borne inférieure    0

# Données du problème
mes_series1 <- ts(
  matrix(
    c( 15,  10,  10,
       4,   8,  -1,
       250, 250,   5,
       8,  12,   0,
       0,  45, -55
    ),
    ncol = 3,
    byrow = TRUE
  ),
  start = c(2022, 1),
  frequency = 4,
  names = c("Revenus", "Depenses", "Profits")
)

# Réconcilier les données
res_equi1 <- tsbalancing(
  in_ts = mes_series1,
  problem_specs_df = mes_specs1,
  display_level = 3
)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsbalancing() function:
#>     in_ts                    = mes_series1
#>     problem_specs_df         = mes_specs1
#>     temporal_grp_periodicity = 1 (default)
#>     temporal_grp_start       (ignored)
#>     osqp_settings_df         = default_osqp_sequence (default)
#>     display_level            = 3
#>     alter_pos                = 1 (default)
#>     alter_neg                = 1 (default)
#>     alter_mix                = 1 (default)
#>     alter_temporal           (ignored)
#>     lower_bound              = -Inf (default)
#>     upper_bound              = Inf (default)
#>     tolV                     = 0 (default)
#>     tolV_temporal            (ignored)
#>     (*)validation_tol        = 0.001 (default)
#>     (*)trunc_to_zero_tol     = validation_tol (default)
#>     (*)validation_only       = FALSE (default)
#>     (*)quiet                 = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Balancing Problem Elements
#> ==========================
#> 
#> 
#>   Balancing Constraints (1)
#>   -------------------------
#> 
#>   Règle comptable:
#>     Revenus - Depenses - Profits == 0
#> 
#> 
#>   Time Series Info
#>   ----------------
#> 
#>         name lowerBd                 upperBd           alter                
#>   1  Revenus       0 (problem specs)     Inf (default)     1 (default)      
#>   2 Depenses       0 (problem specs)     Inf (default)     1 (default)      
#>   3  Profits    -Inf (default)           Inf (default)     0 (problem specs)
#> 
#> 
#> 
#> Balancing period [2022-1]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 5
#>     - Total discrepancy   = 5
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.3898e+00   7.94e-01   8.11e+01  -6.04e+01   8.11e+01   1.00e-01    5.67e-05s
#>     50  -1.9200e+00   9.38e-11   5.19e-10  -4.56e-10   5.19e-10   1.00e-01    1.16e-04s
#>   plsh  -1.9200e+00   1.11e-16   2.22e-16   1.67e-16   2.22e-16  ---------    1.74e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -1.9200
#>   dual objective:       -1.9200
#>   duality gap:          1.6653e-16
#>   primal-dual integral: 6.0431e+01
#>   run time:             1.74e-04s
#>   optimal rho estimate: 5.49e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 0
#>     - Total discrepancy   = 0
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out dif rdif
#>     Revenus 1     2022        0      Inf     1       15        18   3  0.2
#>    Depenses 1     2022        0      Inf     1       10         8  -2 -0.2
#>     Profits 1     2022     -Inf      Inf     0       10        10   0  0.0
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val  l  u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Règle comptable 1     2022 10 10     5     10        5         0          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>     Revenus 1     2022 0 Inf    15     18        0         0          0.001      FALSE
#>    Depenses 1     2022 0 Inf    10      8        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2022-2]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 3
#>     - Total discrepancy   = 3
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.2816e+00   1.57e-01   1.77e+01   2.81e-01   1.77e+01   1.00e-01    4.98e-05s
#>     50  -1.8750e+00   1.33e-11   1.11e-10  -4.76e-11   1.11e-10   1.00e-01    1.05e-04s
#>   plsh  -1.8750e+00   2.78e-17   1.11e-16  -1.39e-16   1.11e-16  ---------    1.64e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -1.8750
#>   dual objective:       -1.8750
#>   duality gap:          -1.3878e-16
#>   primal-dual integral: 2.8069e-01
#>   run time:             1.64e-04s
#>   optimal rho estimate: 5.47e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 8.881784e-16
#>     - Total discrepancy   = 8.881784e-16
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out dif  rdif
#>     Revenus 2  2022.25        0      Inf     1        4         5   1  0.25
#>    Depenses 2  2022.25        0      Inf     1        8         6  -2 -0.25
#>     Profits 2  2022.25     -Inf      Inf     0       -1        -1   0  0.00
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val  l  u Ax_in Ax_out discr_in    discr_out validation_tol unmet_flag
#>    Règle comptable 2  2022.25 -1 -1    -4     -1        3 8.881784e-16          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>     Revenus 2  2022.25 0 Inf     4      5        0         0          0.001      FALSE
#>    Depenses 2  2022.25 0 Inf     8      6        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2022-3]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 5
#>     - Total discrepancy   = 5
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.4512e+00   2.00e-02   3.05e+00   3.15e+00   3.15e+00   1.00e-01    3.82e-05s
#>     50  -1.9998e+00   1.70e-12   1.29e-11  -2.60e-13   1.29e-11   1.00e-01    9.40e-05s
#>   plsh  -1.9998e+00   1.73e-17   1.73e-17  -4.41e-17   1.73e-17  ---------    1.52e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -1.9998
#>   dual objective:       -1.9998
#>   duality gap:          -4.4073e-17
#>   primal-dual integral: 3.1527e+00
#>   run time:             1.52e-04s
#>   optimal rho estimate: 5.13e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 0
#>     - Total discrepancy   = 0
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out  dif  rdif
#>     Revenus 3   2022.5        0      Inf     1      250     252.5  2.5  0.01
#>    Depenses 3   2022.5        0      Inf     1      250     247.5 -2.5 -0.01
#>     Profits 3   2022.5     -Inf      Inf     0        5       5.0  0.0  0.00
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val l u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Règle comptable 3   2022.5 5 5     0      5        5         0          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>     Revenus 3   2022.5 0 Inf   250  252.5        0         0          0.001      FALSE
#>    Depenses 3   2022.5 0 Inf   250  247.5        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2022-4]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 4
#>     - Total discrepancy   = 4
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 2, constraints m = 3
#>             nnz(P) + nnz(A) = 6
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -1.3898e+00   6.04e-03   1.05e+00   3.09e+00   3.09e+00   1.00e-01    3.99e-05s
#>     25  -1.9200e+00   5.09e-08   5.35e-07   3.64e-07   5.35e-07   1.00e-01    9.92e-05s
#>   plsh  -1.9200e+00   0.00e+00   1.11e-16   0.00e+00   1.11e-16  ---------    1.56e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 25
#>   optimal objective:    -1.9200
#>   dual objective:       -1.9200
#>   duality gap:          0.0000e+00
#>   primal-dual integral: 3.0853e+00
#>   run time:             1.56e-04s
#>   optimal rho estimate: 4.88e-02
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 0
#>     - Total discrepancy   = 0
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out  dif rdif
#>     Revenus 4  2022.75        0      Inf     1        8       9.6  1.6  0.2
#>    Depenses 4  2022.75        0      Inf     1       12       9.6 -2.4 -0.2
#>     Profits 4  2022.75     -Inf      Inf     0        0       0.0  0.0   NA
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val l u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Règle comptable 4  2022.75 0 0    -4      0        4         0          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>     Revenus 4  2022.75 0 Inf     8    9.6        0         0          0.001      FALSE
#>    Depenses 4  2022.75 0 Inf    12    9.6        0         0          0.001      FALSE
#> 
#> 
#> 
#> Balancing period [2023-1]
#> =========================
#>   Initial solution:
#>     - Maximum discrepancy = 10
#>     - Total discrepancy   = 10
#>   Try to find a better solution with OSQP.
#> 
#>   -----------------------------------------------------------------
#>              OSQP v1.0.0  -  Operator Splitting QP Solver
#>                 (c) The OSQP Developer Team
#>   -----------------------------------------------------------------
#>   problem:  variables n = 1, constraints m = 2
#>             nnz(P) + nnz(A) = 3
#>   settings: algebra = Built-in,
#>             OSQPInt = 4 bytes, OSQPFloat = 8 bytes,
#>             linear system solver = QDLDL v0.1.8,
#>             eps_abs = 1.0e-06, eps_rel = 1.0e-06,
#>             eps_prim_inf = 1.0e-07, eps_dual_inf = 1.0e-07,
#>             rho = 1.00e-01 (adaptive: 50 iterations),
#>             sigma = 1.00e-09, alpha = 1.60, max_iter = 4000
#>             check_termination: on (interval 25, duality gap: on),
#>             time_limit: 1.00e+10 sec,
#>             scaling: off, scaled_termination: off
#>             warm starting: on, polishing: on, 
#>   iter  objective    prim res   dual res   gap        rel kkt    rho         time
#>      1  -6.1701e-02   1.19e+00   1.21e+02  -1.46e+02   1.21e+02   1.00e-01    3.72e-05s
#>     50  -9.5062e-01   1.37e-10   1.41e-10  -1.43e-10   1.41e-10   1.00e-01    9.23e-05s
#>   plsh  -9.5062e-01   0.00e+00   0.00e+00  -1.11e-16   0.00e+00  ---------    1.49e-04s
#>   
#>   status:               solved
#>   solution polishing:   successful
#>   number of iterations: 50
#>   optimal objective:    -0.9506
#>   dual objective:       -0.9506
#>   duality gap:          -1.1102e-16
#>   primal-dual integral: 1.4561e+02
#>   run time:             1.49e-04s
#>   optimal rho estimate: 1.39e-01
#>   
#>   OSQP iteration 1:
#>     - Maximum discrepancy = 7.105427e-15
#>     - Total discrepancy   = 7.105427e-15
#>   Valid solution (maximum discrepancy <= 0.001 = `validation_tol`).
#>   Required polished solution achieved.
#> 
#>   --------------
#>   Problem Values
#>   --------------
#>        name t time_val lower_bd upper_bd alter value_in value_out dif      rdif
#>     Revenus 5     2023        0      Inf     1        0         0   0        NA
#>    Depenses 5     2023        0      Inf     1       45        55  10 0.2222222
#>     Profits 5     2023     -Inf      Inf     0      -55       -55   0 0.0000000
#> 
#>   ----------------------------------
#>   Problem Constraints (l <= Ax <= u)
#>   ----------------------------------
#>   Balancing Constraints
#>   ---------------------
#>               name t time_val   l   u Ax_in Ax_out discr_in    discr_out validation_tol unmet_flag
#>    Règle comptable 5     2023 -55 -55   -45    -55       10 7.105427e-15          0.001      FALSE
#>   Period Value Bounds
#>   -------------------
#>        name t time_val l   u Ax_in Ax_out discr_in discr_out validation_tol unmet_flag
#>    Depenses 5     2023 0 Inf    45     55        0         0          0.001      FALSE
#> 

# Données initiales
mes_series1
#>         Revenus Depenses Profits
#> 2022 Q1      15       10      10
#> 2022 Q2       4        8      -1
#> 2022 Q3     250      250       5
#> 2022 Q4       8       12       0
#> 2023 Q1       0       45     -55

# Données réconciliées
res_equi1$out_ts
#>         Revenus Depenses Profits
#> 2022 Q1    18.0      8.0      10
#> 2022 Q2     5.0      6.0      -1
#> 2022 Q3   252.5    247.5       5
#> 2022 Q4     9.6      9.6       0
#> 2023 Q1     0.0     55.0     -55

# Vérifier la présence de solutions invalides
any(res_equi1$proc_grp_df$sol_status_val < 0)
#> [1] FALSE

# Afficher les écarts maximaux des contraintes en sortie
res_equi1$proc_grp_df[, c("proc_grp_label", "max_discr")]
#>   proc_grp_label    max_discr
#> 1         2022-1 0.000000e+00
#> 2         2022-2 8.881784e-16
#> 3         2022-3 0.000000e+00
#> 4         2022-4 0.000000e+00
#> 5         2023-1 7.105427e-15


# La solution renvoyée par `tsbalancing()` correspond à des changements proportionnels 
# égaux (au prorata) et est associée aux coefficients d'altérabilité par défaut de 1. 
# Des changements absolus égaux peuvent être obtenus en spécifiant des coefficients 
# d'altérabilité égaux à l'inverse des valeurs initiales. 
# 
# Faisons cela pour le groupe de traitement 2022T2 (`timeVal = 2022.25`), avec le niveau 
# d'information affiché par défaut (`display_level = 1`).

mes_specs1b <- rbind(
  cbind(mes_specs1, data.frame(timeVal = rep(NA_real_, nrow(mes_specs1)))),
  data.frame(
    type = rep(NA, 2),
    col = c("Revenus", "Depenses"),
    row = rep("Coefficient d'altérabilité", 2),
    coef = c(0.25, 0.125),
    timeVal = rep(2022.25, 2)
  )
)
mes_specs1b
#>       type      col                        row   coef timeVal
#> 1       EQ     <NA>            Règle comptable     NA      NA
#> 2     <NA>  Revenus            Règle comptable  1.000      NA
#> 3     <NA> Depenses            Règle comptable -1.000      NA
#> 4     <NA>  Profits            Règle comptable -1.000      NA
#> 5    alter     <NA> Coefficient d'altérabilité     NA      NA
#> 6     <NA>  Profits Coefficient d'altérabilité  0.000      NA
#> 7  lowerBd     <NA>           Borne inférieure     NA      NA
#> 8     <NA>  Revenus           Borne inférieure  0.000      NA
#> 9     <NA> Depenses           Borne inférieure  0.000      NA
#> 10    <NA>  Revenus Coefficient d'altérabilité  0.250 2022.25
#> 11    <NA> Depenses Coefficient d'altérabilité  0.125 2022.25

res_equi1b <- tsbalancing(
  in_ts = mes_series1,
  problem_specs_df = mes_specs1b
)
#> 
#> 
#> --- Package gseries 3.0.3 - Improve the Coherence of Your Time Series Data ---
#> Created on August 31, 2026, at 2:52:43 PM EDT
#> URL: https://StatCan.github.io/gensol-gseries/en/
#>      https://StatCan.github.io/gensol-gseries/fr/
#> Email: g-series@statcan.gc.ca
#> 
#> tsbalancing() function:
#>     in_ts                    = mes_series1
#>     problem_specs_df         = mes_specs1b
#>     temporal_grp_periodicity = 1 (default)
#>     temporal_grp_start       (ignored)
#>     osqp_settings_df         = default_osqp_sequence (default)
#>     display_level            = 1 (default)
#>     alter_pos                = 1 (default)
#>     alter_neg                = 1 (default)
#>     alter_mix                = 1 (default)
#>     alter_temporal           (ignored)
#>     lower_bound              = -Inf (default)
#>     upper_bound              = Inf (default)
#>     tolV                     = 0 (default)
#>     tolV_temporal            (ignored)
#>     (*)validation_tol        = 0.001 (default)
#>     (*)trunc_to_zero_tol     = validation_tol (default)
#>     (*)validation_only       = FALSE (default)
#>     (*)quiet                 = FALSE (default)
#>     (*) indicates new arguments in G-Series 3.0
#> 
#> 
#> 
#> Balancing Problem Elements
#> ==========================
#> 
#> 
#>   Balancing Constraints (1)
#>   -------------------------
#> 
#>   Règle comptable:
#>     Revenus - Depenses - Profits == 0
#> 
#> 
#>   Time Series Info
#>   ----------------
#> 
#>         name lowerBd                 upperBd           alter                  
#>   1  Revenus       0 (problem specs)     Inf (default)     1 * (default)      
#>   2 Depenses       0 (problem specs)     Inf (default)     1 * (default)      
#>   3  Profits    -Inf (default)           Inf (default)     0   (problem specs)
#> 
#>   * indicates cases where period-specific values (`timeVal` is not `NA`) are specified in the problem specs data frame.
#> 
#> 
#> 
#> Balancing period [2022-1]
#> =========================
#> 
#> 
#> Balancing period [2022-2]
#> =========================
#> 
#> 
#> Balancing period [2022-3]
#> =========================
#> 
#> 
#> Balancing period [2022-4]
#> =========================
#> 
#> 
#> Balancing period [2023-1]
#> =========================

# Afficher les valeurs initiales de 2022T2 et les deux solutions
cbind(
  data.frame(Statut = c("initial", "prorata", "changement égal")),
  rbind(
    as.data.frame(mes_series1[2, , drop = FALSE]), 
    as.data.frame(res_equi1$out_ts[2, , drop = FALSE]),
    as.data.frame(res_equi1b$out_ts[2, , drop = FALSE])
  ),
  data.frame(
    Ecart_comptable = c(
      mes_series1[2, 1] - mes_series1[2, 2] - mes_series1[2, 3],
      res_equi1$out_ts[2, 1] - res_equi1$out_ts[2, 2] - 
        res_equi1$out_ts[2, 3],
      res_equi1b$out_ts[2, 1] - res_equi1b$out_ts[2, 2] - 
        res_equi1b$out_ts[2, 3]
    ),
    ChgRel_Rev = c(
      NA, 
      res_equi1$out_ts[2, 1] / mes_series1[2, 1] - 1,
      res_equi1b$out_ts[2, 1] / mes_series1[2, 1] - 1
    ),
    ChgRel_Dep = c(
      NA, 
      res_equi1$out_ts[2, 2] / mes_series1[2, 2] - 1,
      res_equi1b$out_ts[2, 2] / mes_series1[2, 2] - 1
    ),
    ChgAbs_Rev = c(
      NA, 
      res_equi1$out_ts[2, 1] - mes_series1[2, 1],
      res_equi1b$out_ts[2, 1] - mes_series1[2, 1]
    ),
    ChgAbs_Dep = c(
      NA, 
      res_equi1$out_ts[2, 2] - mes_series1[2, 2],
      res_equi1b$out_ts[2, 2] - mes_series1[2, 2]
    )
  )
)
#>            Statut Revenus Depenses Profits Ecart_comptable ChgRel_Rev
#> 1         initial     4.0      8.0      -1   -3.000000e+00         NA
#> 2         prorata     5.0      6.0      -1    8.881784e-16      0.250
#> 3 changement égal     5.5      6.5      -1    0.000000e+00      0.375
#>   ChgRel_Dep ChgAbs_Rev ChgAbs_Dep
#> 1         NA         NA         NA
#> 2    -0.2500        1.0       -2.0
#> 3    -0.1875        1.5       -1.5


###########
# Exemple 2 : Dans ce deuxième exemple, nous considérons les données simulées des  
#             ventes trimestrielles de véhicules par région (Ouest, Centre et Est), 
#             ainsi qu'un total national pour les trois régions, et par type de véhicules 
#             (voitures, camions et un total qui peut inclure d'autres types de véhicules). 
#             Les données correspondent à des données directement désaisonnalisées qui 
#             ont été étalonnées aux totaux annuels des séries originales (non 
#             désaisonnalisées) correspondantes dans le cadre du processus de 
#             désaisonnalisation (par exemple, avec le « spec » FORCE du logiciel 
#             X-13ARIMA-SEATS). 
#
#             L'objectif est de réconcilier les ventes régionales avec les ventes 
#             nationales sans modifier ces dernières, tout en veillant à ce que la somme 
#             des ventes de voitures et de camions ne dépasse pas 95% des ventes de tous 
#             les types de véhicules au cours d'un trimestre donné. À titre d'exemple, 
#             nous supposons que les ventes de camions dans la région Centre pour le 2e 
#             trimestre 2022 ne peuvent pas être modifiées.

# Spécifications du problème
mes_specs2 <- data.frame(
  
  type = c(
    "EQ", rep(NA, 4),
    "EQ", rep(NA, 4),
    "EQ", rep(NA, 4),
    "LE", rep(NA, 3),
    "LE", rep(NA, 3),
    "LE", rep(NA, 3),
    "alter", rep(NA, 4)
  ),
  
  col = c(
    NA, "Ouest_Tous", "Centre_Tous", "Est_Tous", "National_Tous", 
    NA, "Ouest_Autos", "Centre_Autos", "Est_Autos", "National_Autos", 
    NA, "Ouest_Camions", "Centre_Camions", "Est_Camions", "National_Camions", 
    NA, "Ouest_Autos", "Ouest_Camions", "Ouest_Tous", 
    NA, "Centre_Autos", "Centre_Camions", "Centre_Tous", 
    NA, "Est_Autos", "Est_Camions", "Est_Tous",
    NA, "National_Tous", "National_Autos", "National_Camions", "Centre_Camions"
  ),
  
  row = c(
    rep("Total national - Tous les véhicules", 5),
    rep("Total national - Autos", 5),
    rep("Total national - Camions", 5),
    rep("Somme région Ouest", 4),
    rep("Somme région Centre", 4),
    rep("Somme région Est", 4),
    rep("Coefficient d'altérabilité", 5)
  ),
  
  coef = c(
    NA, 1, 1, 1, -1,
    NA, 1, 1, 1, -1,
    NA, 1, 1, 1, -1,
    NA, 1, 1, -.95,
    NA, 1, 1, -.95,
    NA, 1, 1, -.95,
    NA, 0, 0, 0, 0
  ),
  
  time_val = c(rep(NA, 31), 2022.25)
)

# Début et fin du « data frame » des spécifications
head(mes_specs2, n = 10)
#>    type            col                                 row coef time_val
#> 1    EQ           <NA> Total national - Tous les véhicules   NA       NA
#> 2  <NA>     Ouest_Tous Total national - Tous les véhicules    1       NA
#> 3  <NA>    Centre_Tous Total national - Tous les véhicules    1       NA
#> 4  <NA>       Est_Tous Total national - Tous les véhicules    1       NA
#> 5  <NA>  National_Tous Total national - Tous les véhicules   -1       NA
#> 6    EQ           <NA>              Total national - Autos   NA       NA
#> 7  <NA>    Ouest_Autos              Total national - Autos    1       NA
#> 8  <NA>   Centre_Autos              Total national - Autos    1       NA
#> 9  <NA>      Est_Autos              Total national - Autos    1       NA
#> 10 <NA> National_Autos              Total national - Autos   -1       NA
tail(mes_specs2)
#>     type              col                        row  coef time_val
#> 27  <NA>         Est_Tous           Somme région Est -0.95       NA
#> 28 alter             <NA> Coefficient d'altérabilité    NA       NA
#> 29  <NA>    National_Tous Coefficient d'altérabilité  0.00       NA
#> 30  <NA>   National_Autos Coefficient d'altérabilité  0.00       NA
#> 31  <NA> National_Camions Coefficient d'altérabilité  0.00       NA
#> 32  <NA>   Centre_Camions Coefficient d'altérabilité  0.00  2022.25

# Données du problème
mes_series2 <- ts(
  matrix(
    c(
      43, 49, 47, 136, 20, 18, 12, 53, 20, 22, 26, 61,
      40, 45, 42, 114, 16, 16, 19, 44, 21, 26, 21, 59,
      35, 47, 40, 133, 14, 15, 16, 50, 19, 25, 19, 71,
      44, 44, 45, 138, 19, 20, 14, 52, 21, 18, 27, 74,
      46, 48, 55, 135, 16, 15, 19, 51, 27, 25, 28, 54
    ),
    ncol = 12,
    byrow = TRUE
  ),
  start = c(2022, 1),
  frequency = 4,
  names = c(
    "Ouest_Tous", "Centre_Tous", "Est_Tous", "National_Tous", 
    "Ouest_Autos", "Centre_Autos", "Est_Autos", "National_Autos", 
    "Ouest_Camions", "Centre_Camions", "Est_Camions", "National_Camions"
  )
)

# Réconcilier sans afficher l'en-tête de la fonction et imposer des données non négatives
res_equi2 <- tsbalancing(
  in_ts                    = mes_series2,
  problem_specs_df         = mes_specs2,
  temporal_grp_periodicity = frequency(mes_series2),
  lower_bound              = 0,
  quiet                    = TRUE
)
#> 
#> 
#> Balancing periods [2022-1 - 2022-4]
#> ===================================
#> 
#> 
#> Balancing period [2023-1]
#> =========================

# Données initiales
mes_series2
#>         Ouest_Tous Centre_Tous Est_Tous National_Tous Ouest_Autos Centre_Autos
#> 2022 Q1         43          49       47           136          20           18
#> 2022 Q2         40          45       42           114          16           16
#> 2022 Q3         35          47       40           133          14           15
#> 2022 Q4         44          44       45           138          19           20
#> 2023 Q1         46          48       55           135          16           15
#>         Est_Autos National_Autos Ouest_Camions Centre_Camions Est_Camions
#> 2022 Q1        12             53            20             22          26
#> 2022 Q2        19             44            21             26          21
#> 2022 Q3        16             50            19             25          19
#> 2022 Q4        14             52            21             18          27
#> 2023 Q1        19             51            27             25          28
#>         National_Camions
#> 2022 Q1               61
#> 2022 Q2               59
#> 2022 Q3               71
#> 2022 Q4               74
#> 2023 Q1               54

# Données réconciliées
res_equi2$out_ts
#>         Ouest_Tous Centre_Tous Est_Tous National_Tous Ouest_Autos Centre_Autos
#> 2022 Q1   42.10895    47.63734 46.25371           136    21.15646     19.13355
#> 2022 Q2   35.31121    41.40859 37.28019           114    14.00517     13.33816
#> 2022 Q3   38.89464    50.58071 43.52465           133    15.24054     16.84858
#> 2022 Q4   45.68520    45.37335 46.94145           138    18.59783     19.67970
#> 2023 Q1   41.67785    43.48993 49.83221           135    16.32000     15.30000
#>         Est_Autos National_Autos Ouest_Camions Centre_Camions Est_Camions
#> 2022 Q1  12.70999             53      18.56134       18.59359    23.84507
#> 2022 Q2  16.65666             44      16.61497       26.00000    16.38503
#> 2022 Q3  17.91088             50      21.70936       27.22926    22.06138
#> 2022 Q4  13.72247             52      24.11433       19.17715    30.70852
#> 2023 Q1  19.38000             51      18.22500       16.87500    18.90000
#>         National_Camions
#> 2022 Q1               61
#> 2022 Q2               59
#> 2022 Q3               71
#> 2022 Q4               74
#> 2023 Q1               54

# Vérifier la présence de solutions invalides
any(res_equi2$proc_grp_df$sol_status_val < 0)
#> [1] FALSE

# Afficher les écarts maximaux des contraintes en sortie
res_equi2$proc_grp_df[, c("proc_grp_label", "max_discr")]
#>    proc_grp_label    max_discr
#> 1 2022-1 - 2022-4 2.842171e-14
#> 2          2023-1 0.000000e+00


###########
# Exemple 3 : Reproduire le 2ème exemple de `tsraking_driver()` avec `tsbalancing()` 
#             (ratissage à 1 dimension avec préservation des totaux annuels).

# Métadonnées de `tsraking()`
mes_meta3 <- data.frame(
  series = c("autos_alb", "autos_sask", "autos_man"),
  total1 = rep("autos_tot", 3)
)
mes_meta3
#>       series    total1
#> 1  autos_alb autos_tot
#> 2 autos_sask autos_tot
#> 3  autos_man autos_tot

# Spécifications du problème de `tsbalancing()`
mes_specs3 <- rkMeta_to_blSpecs(mes_meta3)
mes_specs3
#>     type        col                          row coef timeVal
#> 1     EQ       <NA> Marginal Total 1 (autos_tot)   NA      NA
#> 2   <NA>  autos_alb Marginal Total 1 (autos_tot)    1      NA
#> 3   <NA> autos_sask Marginal Total 1 (autos_tot)    1      NA
#> 4   <NA>  autos_man Marginal Total 1 (autos_tot)    1      NA
#> 5   <NA>  autos_tot Marginal Total 1 (autos_tot)   -1      NA
#> 6  alter       <NA>    Period Value Alterability   NA      NA
#> 7   <NA>  autos_alb    Period Value Alterability    1      NA
#> 8   <NA> autos_sask    Period Value Alterability    1      NA
#> 9   <NA>  autos_man    Period Value Alterability    1      NA
#> 10  <NA>  autos_tot    Period Value Alterability    0      NA

# Données du problème
mes_series3 <- ts(
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

# Réconcilier les données avec `tsraking()` (via `tsraking_driver()`)
res_ratis3 <- tsraking_driver(
  in_ts = mes_series3,
  metadata_df = mes_meta3,
  temporal_grp_periodicity = frequency(mes_series3),
  quiet = TRUE
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

# Réconcilier les données avec `tsbalancing()`
res_equi3 <- tsbalancing(
  in_ts = mes_series3,
  problem_specs_df = mes_specs3,
  temporal_grp_periodicity = frequency(mes_series3),
  quiet = TRUE
)
#> 
#> 
#> Balancing period [2019-2]
#> =========================
#> 
#> 
#> Balancing period [2019-3]
#> =========================
#> 
#> 
#> Balancing period [2019-4]
#> =========================
#> 
#> 
#> Balancing periods [2020-1 - 2020-4]
#> ===================================
#> 
#> 
#> Balancing period [2021-1]
#> =========================

# Données initiales
mes_series3
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2        14         18        14        58
#> 2019 Q3        17         14        16        44
#> 2019 Q4        14         19        18        58
#> 2020 Q1        20         18        12        53
#> 2020 Q2        16         16        19        44
#> 2020 Q3        14         15        16        50
#> 2020 Q4        19         20        14        52
#> 2021 Q1        16         15        19        51

# Les deux ensembles de données réconciliées
res_ratis3
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2  17.65217   22.69565  17.65217        58
#> 2019 Q3  15.91489   13.10638  14.97872        44
#> 2019 Q4  15.92157   21.60784  20.47059        58
#> 2020 Q1  21.15283   19.04513  12.80204        53
#> 2020 Q2  13.74700   13.75373  16.49927        44
#> 2020 Q3  15.50782   16.62184  17.87034        50
#> 2020 Q4  18.59234   19.57931  13.82835        52
#> 2021 Q1  16.32000   15.30000  19.38000        51
res_equi3$out_ts
#>         autos_alb autos_sask autos_man autos_tot
#> 2019 Q2  17.65217   22.69565  17.65217        58
#> 2019 Q3  15.91489   13.10638  14.97872        44
#> 2019 Q4  15.92157   21.60784  20.47059        58
#> 2020 Q1  21.15283   19.04513  12.80204        53
#> 2020 Q2  13.74700   13.75373  16.49927        44
#> 2020 Q3  15.50782   16.62184  17.87034        50
#> 2020 Q4  18.59234   19.57931  13.82835        52
#> 2021 Q1  16.32000   15.30000  19.38000        51

# Vérifier la présence de solutions de `tsbalancing()` invalides
any(res_equi3$proc_grp_df$sol_status_val < 0)
#> [1] FALSE

# Afficher les écarts maximaux des contraintes en sortie dans les solutions de `tsbalancing()`
res_equi3$proc_grp_df[, c("proc_grp_label", "max_discr")]
#>    proc_grp_label    max_discr
#> 1          2019-2 0.000000e+00
#> 2          2019-3 0.000000e+00
#> 3          2019-4 0.000000e+00
#> 4 2020-1 - 2020-4 1.421085e-14
#> 5          2021-1 0.000000e+00

# Confirmer que les deux solutions (`tsraking() et `tsbalancing()`) sont les mêmes
all.equal(res_ratis3, res_equi3$out_ts)
#> [1] TRUE
```
