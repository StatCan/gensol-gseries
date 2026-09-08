# Générer des graphiques d'étalonnage dans un fichier PDF

Créer un fichier PDF (format de papier lettre US en orientation paysage)
contenant des graphiques d'étalonnage pour l'ensemble des séries
contenues dans le *data frame* de sortie `graphTable` de la fonction
d'étalonnage
([`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
ou
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md))
spécifié. Quatre types de graphiques d'étalonnage peuvent être générés
pour chaque série :

- **Échelle originale** (argument `ori_plot_flag`) - graphique superposé
  des composantes :

  - Série indicatrice

  - Moyennes de la série indicatrice

  - Série indicatrice corrigée pour le biais (lorsque \\\rho \< 1\\)

  - Série étalonnée

  - Moyennes des étalons

- **Échelle d'ajustement** (argument `adj_plot_flag`) - graphique
  superposé des composantes :

  - Ajustements d'étalonnage

  - Moyennes des ajustements d'étalonnage

  - Ligne du biais (lorsque \\\rho \< 1\\)

- **Taux de croissance** (argument `GR_plot_flag`) - diagramme à barres
  des taux de croissance des séries indicatrice et étalonnée.

- **Tableau des taux de croissance** (argument `GR_table_flag`) -
  tableau des taux de croissance des séries indicatrice et étalonnée.

Ces graphiques peuvent être utiles pour évaluer la qualité des résultats
de l'étalonnage. N'importe lequel des quatre types de graphiques
d'étalonnage peut être activé ou désactivé à l'aide du drapeau (*flag*)
correspondant. Les trois premiers types graphiques sont générés par
défaut alors que le quatrième (le tableau des taux de croissance) ne
l'est pas.

## Utilisation

``` r
plot_graphTable(
  graphTable,
  pdf_file,
  ori_plot_flag = TRUE,
  adj_plot_flag = TRUE,
  GR_plot_flag = TRUE,
  GR_table_flag = FALSE,
  add_bookmarks = TRUE
)
```

## Arguments

- graphTable:

  (obligatoire)

  *Data frame* (object de classe « data.frame ») correspondant au *data
  frame* de sortie `graphTable` de la fonction d'étalonnage.

- pdf_file:

  (obligatoire)

  Nom (et chemin) du fichier PDF qui contiendra les graphiques
  d'étalonnage. Le nom doit inclure l'extension de fichier « .pdf ». Le
  fichier PDF sera créé dans le répertoire de travail de la session R
  (tel que renvoyé par [`getwd()`](https://rdrr.io/r/base/getwd.html))
  si aucun chemin n'est spécifié. La sécification de `NULL` annulerait
  la création d'un fichier PDF.

- ori_plot_flag, adj_plot_flag, GR_plot_flag, GR_table_flag:

  (optionnels)

  Arguments logiques (*logical*) indiquant si le type de graphique
  d'étalonnage correspondant doit être généré ou non. Les trois premiers
  types de graphiques sont générés par défaut alors que le quatrième (le
  tableau des taux de croissance) ne l'est pas.

  **Les valeurs par défaut** sont `ori_plot_flag = TRUE`,
  `adj_plot_flag = TRUE`, `GR_plot_flag = TRUE` et
  `GR_table_flag = FALSE`.

- add_bookmarks:

  Argument logique (*logical*) indiquant si des signets doivent être
  ajoutés au fichier PDF. Voir **Signets** dans la section **Détails**
  pour plus d'informations.

  **La valeur par défaut** est `add_bookmarks = TRUE`.

## Valeur de retour

En plus de créer un fichier PDF contenant les graphiques d'étalonnage
(sauf si `pdf_file = NULL`), cette fonction renvoie également de manière
invisible une liste comprenant les éléments suivants :

- `pdf_name` : Chaîne de caractères (vecteur de type caractère de
  longueur un) qui contient le nom complet et le chemin du fichier PDF
  s'il a été créé avec succès et `invisible(NA_character_)` dans le cas
  contraire ou si `pdf_file = NULL` a été spécifié.

- `graph_list` : Liste des graphiques d'étalonnage générés (une par
  série) comprenant les éléments suivants :

  - `name` : Chaîne de caractères décrivant la série (concorde avec le
    nom du signet dans le fichier PDF).

  - `page` : Entier représentant le numéro de séquence du premier
    graphique de la série dans la séquence complète des graphiques pour
    toutes les séries (concorde avec le numéro de page dans le fichier
    PDF).

  - `ggplot_list` : Liste d'objets ggplot (une par graphique ou par page
    dans le fichier PDF) correspondant aux graphiques d'étalonnage
    générés pour la série. Voir la section **Valeur** dans
    [bench_graphs](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
    pour plus de détails.

Notez que les objets ggplot renvoyés par la fonction peuvent être
affichés *manuellement* avec
[`print()`](https://rdrr.io/r/base/print.html), auquel cas certaines
mises à jour des paramètres par défaut du thème ggplot2 sont
recommandées afin de produire des graphiques ayant une apparence
similaire à ceux générés dans le fichier PDF (voir la section **Valeur**
dans
[bench_graphs](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
pour les détails). Gardez également à l'esprit que ces graphiques sont
optimisés pour un format de papier Lettre US en orientation paysage,
c.-à-d., 11po de large (27.9cm, 1056px avec 96 PPP) et 8.5po de haut
(21.6cm, 816px avec 96 PPP).

## Détails

Liste des variables du *data frame* `graphTable` correspondant à chaque
élément des quatre types de graphiques d'étalonnage:

- Échelle originale (argument `ori_plot_flag`)

  - `subAnnual` pour la ligne *Indicator Series*

  - `avgSubAnnual` pour les segments *Avg. Indicator Series*

  - `subAnnualCorrected` pour la ligne *Bias Corr. Indicator Series*
    (lorsque \\\rho \< 1\\)

  - `benchmarked` pour la ligne *Benchmarked Series*

  - `avgBenchmark` pour les segments *Average Benchmark*

- Échelle d'ajustement (argument `adj_plot_flag`)

  - `benchmarkedSubAnnualRatio` pour la ligne *BI Ratios (Benchmarked
    Series / Indicator Series)* \\^{(\*)}\\

  - `avgBenchmarkSubAnnualRatio` pour les segments *Average BI Ratios*
    \\^{(\*)}\\

  - `bias` pour la ligne *Bias* (lorsque \\\rho \< 1\\)

- Taux de croissance (argument `GR_plot_flag`)

  - `growthRateSubAnnual` pour les barres *Growth R. in Indicator
    Series* \\^{(\*)}\\

  - `growthRateBenchmarked` pour les barres *Growth R. in Benchmarked
    Series* \\^{(\*)}\\

- Tableau des taux de croissance (argument `GR_table_flag`)

  - `year` pour la colonne *Year*

  - `period` pour la colonne *Period*

  - `subAnnual` pour la colonne *Indicator Series*

  - `benchmarked` pour la colonne *Benchmarked Series*

  - `growthRateSubAnnual` pour la colonne *Growth Rate in Indicator
    Series* \\^{(\*)}\\

  - `growthRateBenchmarked` pour la colonne *Growth Rate in Benchmarked
    Series* \\^{(\*)}\\

\\^{(\*)}\\ Les *ratios étalons/indicateurs* (« BI ratios ») et les
*taux de croissance* (« growth rates ») correspondent en réalité à des
*différences* lorsque \\\lambda = 0\\ (étalonnage additif).

La fonction utilise les colonnes supplémentaires du *data frame*
`graphTable` (colonnes non listées dans la section **Valeur de retour**
de
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
et
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)),
le cas échéant, pour construire les groupes-BY. Voir la section
**Étalonnage de plusieurs séries** de
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
pour plus de détails.

### Performance

Les deux types de graphiques de taux de croissance, c'est-à-dire le
diagramme à barres (`GR_plot_flag`) et le tableau (`GR_table_flag`),
nécessitent souvent la génération de plusieurs pages dans le fichier
PDF, en particulier pour les longues séries mensuelles avec plusieurs
années de données. Cette création de pages supplémentaires ralentit
l'exécution de `plot_graphTable()`. C'est pourquoi seul le diagramme à
barres est généré par défaut (`GR_plot_flag = TRUE` et
`GR_table_flag = FALSE`). La désactivation des deux types de graphiques
de taux de croissance (`GR_plot_flag = FALSE` et
`GR_table_flag = FALSE`) ou la réduction de la taille du *data frame*
d'entrée `graphTable` pour les séries très longues (ex., en ne gardant
que les années récentes) pourrait ainsi améliorer le temps d'exécution.
Notez également que l'impact de l'étalonnage sur les taux de croissance
peut être déduit du graphique dans l'échelle d'ajustement
(`adj_plot_flag`) en examinant l'ampleur du mouvement vertical (vers le
bas ou vers le haut) des ajustements d'étalonnage entre deux périodes
adjacentes : plus le mouvement vertical est important, plus l'impact sur
le taux de croissance correspondant est important. Le temps d'exécution
de `plot_graphTable()` pourrait donc être reduit, si nécessaire, en ne
générant que les deux premiers types de graphiques et en se concentrant
sur le graphique des d'ajustements d'étalonnage pour évaluer la
préservation du mouvement d'une période à l'autre, c'est-à-dire l'impact
de l'étalonnage sur les taux de croissance initiaux.

### Thèmes de ggplot2

Les graphiques sont générés avec la librairie ggplot2 qui est livrée
avec un ensemble pratique de [thèmes
complets](https://ggplot2.tidyverse.org/reference/ggtheme.html) pour
l'aspect général des graphiques (avec
[`theme_grey()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
comme thème par défaut). Utilisez la fonction
[`theme_set()`](https://ggplot2.tidyverse.org/reference/get_theme.html)
pour changer le thème appliqué aux graphiques générés par
`plot_graphTable()` (voir les **Exemples**).

### Signets

Des signets sont ajoutés au fichier PDF avec
[`xmpdf::set_bookmarks()`](https://trevorldavis.com/R/xmpdf/reference/bookmarks.html)
lorsque l'argument `add_bookmarks = TRUE` (par défault), ce qui
nécessite un outil tiers tel que
[Ghostscript](https://www.ghostscript.com/) ou
[PDFtk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/). Voir la
section **Installation** dans
[`vignette("xmpdf", package = "xmpdf")`](https://trevorldavis.com/R/xmpdf/articles/xmpdf.html)
pour plus de détails.

**Important** : les signets seront ajoutés avec succès au fichier PDF
**si et seulement si**
[`xmpdf::supports_set_bookmarks()`](https://trevorldavis.com/R/xmpdf/reference/supports.html)
renvoie `TRUE` **et** l'exécution de
[`xmpdf::set_bookmarks()`](https://trevorldavis.com/R/xmpdf/reference/bookmarks.html)
est réussie. Si Ghostscript est installé sur votre machine mais que
[`xmpdf::supports_set_bookmarks()`](https://trevorldavis.com/R/xmpdf/reference/supports.html)
renvoie toujours `FALSE`, essayez de spécifier le chemin de l'exécutable
Ghostscript dans la variable d'environnement `R_GSCMD` (ex.,
`Sys.setenv(R_GSCMD = "C:/Program Files/.../bin/gswin64c.exe")` avec
Windows). D'un autre côté, si `xmpdf::supports_set_bookmarks()}` renvoie
`TRUE` mais que vous rencontrez des problèmes (insolubles) avec
[`xmpdf::set_bookmarks()`](https://trevorldavis.com/R/xmpdf/reference/bookmarks.html)
(ex., erreur liée à l'exécutable Ghostscript), la création de signets
peut être désactivée en spécifiant `add_bookmarks = FALSE`.

## Voir également

[bench_graphs](https://StatCan.github.io/gensol-gseries/fr/reference/bench_graphs.md)
[`plot_benchAdj()`](https://StatCan.github.io/gensol-gseries/fr/reference/plot_benchAdj.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
[`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)

## Exemples

``` r
# Définir le répertoire de travail (pour les fichiers graphiques PDF)
rep_ini <- setwd(tempdir())


# Ventes trimestrielles de voitures et camionnettes (séries indicatrices)
ind_tri <- ts_to_tsDF(
  ts(
    matrix(
      c(
        # Voitures
        1851, 2436, 3115, 2205, 1987, 2635, 3435, 2361, 2183, 2822,
        3664, 2550, 2342, 3001, 3779, 2538, 2363, 3090, 3807, 2631,
        2601, 3063, 3961, 2774, 2476, 3083, 3864, 2773, 2489, 3082,
        # Camionnettes
        1900, 2200, 3000, 2000, 1900, 2500, 3800, 2500, 2100, 3100,
        3650, 2950, 3300, 4000, 3290, 2600, 2010, 3600, 3500, 2100,
        2050, 3500, 4290, 2800, 2770, 3080, 3100, 2800, 3100, 2860),
      ncol = 2
    ),
   start = c(2011, 1),
   frequency = 4,
   names = c("voitures", "camionnettes")
  )
)

# Ventes annuelles de voitures et camionnettes (étalons)
eta_tri <- ts_to_bmkDF(
  ts(matrix(c(# Voitures
              10324, 10200, 10582, 11097, 11582, 11092,
              # Camionnettes
              12000, 10400, 11550, 11400, 14500, 16000),
            ncol = 2),
     start = 2011,
     frequency = 1,
     names = c("voitures", "camionnettes")), 
  ind_frequency = 4)
  

# Étalonnage proportionnel sans correction pour le biais
res_eta <- benchmarking(ind_tri, eta_tri,
                        rho = 0.729, lambda = 1, biasOption = 1,
                        allCols = TRUE,
                        quiet = TRUE)
#> 
#> Benchmarking indicator series [voitures] with benchmarks [voitures]
#> -------------------------------------------------------------------
#> 
#> Benchmarking indicator series [camionnettes] with benchmarks [camionnettes]
#> ---------------------------------------------------------------------------


# Ensemble de graphiques par défaut (les 3 premiers types de graphiques)
plot_graphTable(res_eta$graphTable, "graphes_etalonnage.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 2 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\Rtmp4MB8Hw\graphes_etalonnage.pdf

# Utiliser temporairement `theme_bw()` de ggplot2 pour les graphiques
library(ggplot2)
#> Warning: le package 'ggplot2' a été compilé avec la version R 4.5.3
theme_ini <- theme_get()
theme_set(theme_bw())
plot_graphTable(res_eta$graphTable, "graphes_etalonnage_bw.pdf")
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 2 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\Rtmp4MB8Hw\graphes_etalonnage_bw.pdf
theme_set(theme_ini)

# Generer les 4 types de graphiques (incluant le tableau des taux de croissance)
plot_graphTable(res_eta$graphTable, "graphes_etalonnage_avec_tableauTC.pdf",
                GR_table_flag = TRUE)
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 2 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\Rtmp4MB8Hw\graphes_etalonnage_avec_tableauTC.pdf

# Réduire le temps d'exécution en désactivant les deux types de graphiques 
# des taux de croissance
plot_graphTable(res_eta$graphTable, "graphes_etalonnage_sans_TC.pdf",
                GR_plot_flag = FALSE)
#> 
#> Generating the benchmarking graphics. Please be patient...
#> Benchmarking graphics generated for 2 series in the following PDF file:
#>   C:\Users\ferlmic\AppData\Local\Temp\Rtmp4MB8Hw\graphes_etalonnage_sans_TC.pdf


# Réinitialiser le répertoire de travail à son emplacement initial
setwd(rep_ini)
```
