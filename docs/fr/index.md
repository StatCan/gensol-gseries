# Librairie R gseries

## Description

Version R du système généralisé de Statistique Canada (StatCan)
**G‑Séries** initialement développé en SAS^(®). Ce site web est consacré
à la version R de G‑Séries (librairie gseries). Écrivez-nous à
<g-series@statcan.gc.ca> pour obtenir des informations sur les versions
SAS^(®).

> ***Note - intranet de StatCan***  
> Les employés de StatCan peuvent également visiter la page Confluence
> de G‑Séries dans l’intranet de l’agence (cherchez « G-Series \|
> G-Séries » dans Confluence) ainsi que le projet de développement
> GitLab de G‑Séries également hébergé dans l’intranet de l’agence
> (cherchez « G-Series in R - G-Séries en R » dans GitLab). Ce dernier
> inclut une version des informations et instructions contenues dans
> cette page qui sont spécifiques à l’infrastructure TI de StatCan (ex.,
> Artifactory et GitLab) ; voir `index_StatCan.md` dans le répertoire
> racine du projet GitLab.

G‑Séries 3.0 (librairie gseries 3.0.3) est la première version du
logiciel offerte en libre accès (logiciel libre). Elle inclut le
recodage en R de toutes les fonctionalités SAS^(®) de G‑Séries 2.0,
soient PROC BENCHMARKING, PROC TSRAKING et la macro
***GSeriesTSBalancing***, ainsi qu’une fonction pour l’étalonnage de
*séries de stocks* par l’entremise d’interpolations par spline cubique
où les noeuds de la spline correspondent aux ratios ou différences entre
les valeurs des étalons et de la série indicatrice. Il comprend les
*fonctions principales* suivantes:

- [`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)
- [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/stock_benchmarking.md)
- [`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md),
  [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking_driver.md)
- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)  

D’autres *fonctions utilitaires* sont également incluses dans la
librairie. Visitez la page
[Référence](https://StatCan.github.io/gensol-gseries/fr/reference/index.md)
(barre supérieure) pour obtenir la liste complète des fonctions
disponibles.

## Installation

Version publiée sur le CRAN :

``` r
install.packages("gseries")
```

Version de développement sur GitHub :

``` r
install.packages("remotes")
remotes::install_github("StatCan/gensol-gseries")
```

Version spécifique sur GitHub :

``` r
install.packages("remotes")
remotes::install_github("StatCan/gensol-gseries@<release-tag>")
```

où *\<release-tag\>* réfère aux valeurs énumérées sous les
[*Tags*](https://github.com/StatCan/gensol-gseries/tags) (\geq *v3.0.0*)
du projet GitHub.

#### *Alternative*

La librairie peut également être installée à partir des fichiers sources
téléchargés. Cette approche nécessite l’installation préalable des
librairies dont dépend gseries (à cause de `repos = NULL` dans l’appel
[`install.packages()`](https://rdrr.io/r/utils/install.packages.html)).

1.  Accéder au [dépôt](https://github.com/StatCan/gensol-gseries)
    (*repository*) GitHub pertinent (branche *main* ou *tag* \geq
    *v3.0.0*)
2.  Télécharger les fichiers du dépôt (*Code* \> *Download ZIP*).
3.  Décompresser les fichiers téléchargés.
4.  Installer la librairie gseries (et ses librairies dépendantes) :

``` r
install.packages(
  c("ggplot2", "ggtext", "gridExtra", "lifecycle", "osqp", "rlang", "xmpdf")
)
install.packages(
  "<nom & chemin d'accès des fichiers du dépôt téléchargés et décompressés>",
  repos = NULL, type = "source"
)
```

#### *Vignettes*

L’installation de gseries à partir du CRAN
(`install.packages("gseries")`) construit et installe automatiquement
les vignettes de la librairie. Par contre, ce n’est pas le cas par
défaut lors d’une installation à partir de GitHub (avec
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html))
ou à partir des fichiers sources téléchargés (avec
`install.packages(..., repos = NULL, type = "source")`). Bien que les
vignettes ne soient pas nécessaires pour qu’une librairie soit
fonctionnelle, elles contiennent une documentation complémentaire utile.
Les vignettes de la librairie gseries sont disponibles dans le menu
déroulant ***Articles*** (barre supérieure) de ce site web et dans le
dossier `pdf/` du [dépôt](https://github.com/StatCan/gensol-gseries)
GitHub. L’installation des vignettes avec la librairie les rend
également accessibles à partir de R (par exemple, avec
`browseVignettes("gseries")` ou `vignette("<nom-de-la-vignette>")`).

La construction des vignettes de la librairie gseries nécessite le
logiciel (gratuit) [Pandoc](https://pandoc.org/), qui est inclus dans
[RStudio](https://posit.co/downloads/), et une distribution LaTeX (par
exemple, [TinyTex](https://github.com/rstudio/tinytex-releases)). Vous
devez donc éviter d’essayer de construire les vignettes de la librairie
gseries avec l’interface graphique de base de R (à moins que vous n’ayez
une installation autonome de Pandoc) ou sans une distribution LaTeX
fonctionnelle. La construction des vignettes nécessite également les
librairies R knitr et rmarkdown.

Lors de l’installation **à partir de GitHub**, spécifiez les arguments
`build_vignettes = TRUE` et `dependencies = TRUE` afin d’installer
également les dépendances *suggérées* de G-Séries (librairies
nécessaires afin de construire les vignettes qui ne sont pas installées
par défaut par
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)) :

``` r
install.packages("remotes")
remotes::install_github(
  "StatCan/gensol-gseries", 
  build_vignettes = TRUE, dependencies = TRUE
)
```

Lors de l’installation **à partir des fichiers sources téléchargés**,
créez d’abord la version *groupée (« bundled »)* de la librairie avec
[`devtools::build()`](https://devtools.r-lib.org/reference/build.html) :

``` r
install.packages(
  c("devtools", "ggplot2", "ggtext", "gridExtra", "osqp", "xmpdf")
)
devtools::build(
  "<nom & chemin d'accès des fichiers du dépôt téléchargés et décompressés>"
) |> 
  install.packages(repos = NULL, type = "source")
```

Remarque : les librairies knitr, lifecycle, rlang et rmarkdown sont
automatiquement installées avec devtools.

## Documentation

La documentation bilingue (anglaise-française) de la librairie gseries
disponible sur ce site web est également accessible à partir de R. Bien
que R affiche uniquement la version anglaise de la documentation de
gseries, des liens vers les pages françaises équivalentes sur ce site
web sont fournis au début des pages d’aide pertinentes de gseries dans
R.
[`help("gseries")`](https://StatCan.github.io/gensol-gseries/fr/reference/gseries-package.md)
dans R affiche des informations générales sur la librairie, y compris un
lien vers (l’URL de) ce site web. En cliquant sur le lien **Index** au
bas de la page d’aide de la librairie gseries dans RStudio (ou avec
[`help(package = "gseries")`](https://StatCan.github.io/gensol-gseries/fr/reference)),
on obtient la liste de tous les éléments de documentation disponibles
pour la librairie, dont :

- les pages d’aide des sujets/fonctions (page
  [Référence](https://StatCan.github.io/gensol-gseries/fr/reference/index.md)
  de la barre supérieure) ;
- les vignettes, lorsqu’elles sont installées (menu déroulant
  ***Articles*** de la barre supérieure) ;
- les nouvelles de la librairie (page
  [Changements](https://StatCan.github.io/gensol-gseries/fr/news/index.md)
  sous le menu déroulant ***Nouveautés*** de la barre supérieure).

Les pages d’aide individuelles de chaque fonction qui se trouvent dans
la page
[Référence](https://StatCan.github.io/gensol-gseries/fr/reference/index.md)
(barre supérieure) peuvent être accédées directement dans R avec
`help("<nom-de-la-fonction>")`. Elles contiennent des informations
complètes sur chacune des fonctions, y compris des exemples utiles, et
seront votre principale source d’information. Les vignettes du menu
déroulant ***Articles*** (barre supérieure) sont une source
d’information complémentaire qui, lorsqu’elles sont installées avec la
librairie, sont également accessibles à partir de R avec
`browseVignettes("gseries")` ou `vignette("<nom-de-la-vignette>")`.
Elles comprennent :

- un *Livre de recette sur l’étalonnage*
  ([`vignette("benchmarking-cookbook")`](https://StatCan.github.io/gensol-gseries/fr/articles/benchmarking-cookbook.md))
  parcourant les étapes d’un projet d’étalonnage typique ;
- *Un script d’étalonnage pour débutant*
  ([`vignette("benchmarking-demo-script")`](https://StatCan.github.io/gensol-gseries/fr/articles/benchmarking-demo-script.md))
  illustrant l’utilisation des fonctions d’étalonnage dans un contexte
  pratique ;
- une page *« Data frame » pour la séquence de paramètres d’OSQP*
  ([`vignette("osqp-settings-sequence-dataframe")`](https://StatCan.github.io/gensol-gseries/fr/articles/osqp-settings-sequence-dataframe.md))
  décrivant la *séquence de résolution* implémentée dans
  [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsbalancing.md)
  et expliquant comment elle peut être personnalisée.

Enfin, la page [Prise en
main](https://StatCan.github.io/gensol-gseries/fr/articles/gseries.md)
(barre supérieure) fournit des informations générales sur G‑Séries et
est disponible sous la forme d’une vignette dans R
([`vignette("gseries")`](https://StatCan.github.io/gensol-gseries/fr/articles/gseries.md)).

#### *Copie locale du site web de la librairie*

Le dossier `docs/` du [dépôt](https://github.com/StatCan/gensol-gseries)
GitHub (branche *main* ou *tag* \geq *v3.0.0*) contient les fichiers du
site web de la librairie et peut donc être téléchargé afin d’obtenir une
copie locale de ce site web. Ceci peut être utile pour une consultation
hors ligne ou pour accéder à la documentation d’une version spécifique
de la librairie (ex., la version de développement ou une version
antérieure). Après avoir téléchargé (*Code* \> *Download ZIP*) et
décompressé les fichiers du dépôt, ouvrez le fichier
`docs/fr/index.html` dans un navigateur web pour accéder à la copie
locale de la page d’accueil (page actuelle) du site web.
Alternativement, l’outil GitHub [*Download GitHub
directory*](https://download-directory.github.io/) peut être utilisé
pour télécharger uniquement le contenu du dossier `docs/` au lieu de
téléchager tous les fichiers du dépôt :

1.  Ouvrir le dossier `docs/` du
    [dépôt](https://github.com/StatCan/gensol-gseries) GitHub pertinent
    (branche *main* ou *tag* \geq *v3.0.0*).
2.  Copier l’adresse URL du dossier (bar d’adresse) dans le champ texte
    de l’outil [*Download GitHub
    directory*](https://download-directory.github.io/) et appuyer sur
    Retour.
3.  Décompresser le répertoire téléchargé.
4.  Ouvrir le fichier `fr/index.html` dans un navigateur web.

Remarque : la boîte *Rechercher* (barre supérieure) ne fonctionne pas
dans les copies locales du site web de la librairie.

#### *Format PDF*

La documentation bilingue (anglaise-française) en format PDF de
G‑Séries, également utile en mode hors ligne ou pour une version
spécifique de G‑Séries, est disponible dans le dossier `pdf/` du
[dépôt](https://github.com/StatCan/gensol-gseries) GitHub (branche
*main* ou *tag* \geq *v3.0.0* pour les versions R et *tag* \leq *v2.0*
pour les versions SAS^(®)). Là encore, l’outil GitHub [*Download GitHub
directory*](https://download-directory.github.io/) peut être utilisé
pour télécharger uniquement le contenu du dossier `pdf/` au lieu de
téléchager tous les fichiers du dépôt. La décompression du répertoire
téléchargé dévoilera alors les fichiers PDF individuels.
