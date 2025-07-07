<!-- README.md is generated from README.Rmd. Please edit that file -->

# G-Series in R (package gseries)

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/gseries)](https://cran.r-project.org/package=gseries)
[![Lifecycle:
stable](man/figures/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R-CMD-check
status](https://github.com/StatCan/gensol-gseries/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/StatCan/gensol-gseries/actions/workflows/R-CMD-check.yaml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/StatCan/gensol-gseries/branch/main/graph/badge.svg?token=ZUL7LPM7EV)](https://app.codecov.io/gh/StatCan/gensol-gseries?branch=main)
[![Mentioned in Awesome Official
Statistics](https://awesome.re/mentioned-badge.svg)](https://github.com/SNStatComp/awesome-official-statistics-software)

<!-- badges: end -->

([Français](#g-s%C3%A9ries-en-r-librairie-gseries))

## Description

R version of Statistics Canada’s (StatCan) generalized system
**G‑Series** initially developed in SAS<sup>®</sup>. This project is
devoted to G‑Series in R (package gseries). Email us at
<g-series@statcan.gc.ca> for information about the SAS<sup>®</sup>
versions.

> ***Note - StatCan intranet***  
> StatCan employees can also visit the G‑Series Confluence page on the
> agency’s intranet (search for “G-Series \| G-Séries” in Confluence) as
> well as the G‑Series GitLab development project also hosted on the
> agency’s intranet (search for “G-Series in R - G-Séries en R” in
> GitLab). The latter includes information and instructions specific to
> the StatCan IT infrastructure (e.g., Artifactory and GitLab); see file
> `index_StatCan.md` in the GitLab project root folder.

G‑Series 3.0 (package gseries 3.0.2) is the initial open-source version
of the software. It includes the rewriting in R of all SAS<sup>®</sup>
G‑Series 2.0 functionalities, that is PROC BENCHMARKING, PROC TSRAKING
and macro ***GSeriesTSBalancing*** along with a function for
benchmarking *stocks* using a spline interpolation approach where the
spline knots correspond to the benchmark-to-indicator ratios or
differences.

<https://StatCan.github.io/gensol-gseries/en/> (the gseries package
website) is your *go-to* place for everything there is to know about
this package:

- installation instructions (home page);
- complete function documentation with examples (**Reference** page);
- package vignettes containing complementary documentation (**Articles**
  menu);
- G‑Series version *changelog* (**News** \> **Changelog** page);
- how to download local copies of the G‑Series HTML and PDF
  documentation (home page);
- etc.

## Project Structure

With the exception of the following directories, the files in this
project follow the common structure of a R package with a pkgdown
website:

- `docs/` (\*): bilingual pkgdown website files (usually built in a
  GitHub Actions workflow or a GitLab CI/CD pipeline rather than being
  saved with the project files).
- `fr/`: files required to generate the French version of the complete
  HTML and PDF package documentation (function reference, vignettes,
  etc.). The contents of the `fr/` directory resemble those of the root
  project directory.
- `misc/`: various files related to the package maintenance.
- `pdf/` (\*): bilingual package documentation and vignettes in PDF
  format.

(\*) The purpose of directories `docs/` and `pdf/` is to provide access
to the complete library of available G‑Series documentation in HTML and
PDF formats, as opposed to only the CRAN version for the package website
or the installed version through R and RStudio. So whether one is
interested in the documentation for a previous version of G‑Series
(*tag* \< CRAN version) or for the development version (when *main*
branch version \> CRAN version), the contents of these folders can be
downloaded for offline consultation.

## Contact - Support

User support for G‑Series is provided by the Time Series Research and
Analysis Centre (TSRAC) in the Economic Statistics Methods Division
(ESMD) and the Digital Processing Solutions Division (DPSD). Email us at
<g-series@statcan.gc.ca> for information or help using G‑Series. GitHub
account holders can also request information, ask questions or report
problems through the G‑Series GitHub project
[Issues](https://github.com/StatCan/gensol-gseries/issues) page. StatCan
employees can do the same through the **Issues** page of the G‑Series
GitLab development project hosted on the StatCan intranet (search for
“G-Series in R - G-Séries en R” in GitLab).

<br>

------------------------------------------------------------------------

<br>

# G-Séries en R (librairie gseries)

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/gseries)](https://cran.r-project.org/package=gseries)
[![Lifecycle:
stable](man/figures/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R-CMD-check
status](https://github.com/StatCan/gensol-gseries/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/StatCan/gensol-gseries/actions/workflows/R-CMD-check.yaml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/StatCan/gensol-gseries/branch/main/graph/badge.svg?token=ZUL7LPM7EV)](https://app.codecov.io/gh/StatCan/gensol-gseries?branch=main)
[![Mentioned in Awesome Official
Statistics](https://awesome.re/mentioned-badge.svg)](https://github.com/SNStatComp/awesome-official-statistics-software)

<!-- badges: end -->

([English](#g-series-in-r-package-gseries))

## Description

Version R du système généralisé de Statistique Canada (StatCan)
**G‑Séries** initialement développé en SAS<sup>®</sup>. Ce projet est
consacré à la version R de G‑Séries (librairie gseries). Écrivez-nous à
<g-series@statcan.gc.ca> pour obtenir des informations sur les versions
SAS<sup>®</sup>.

> ***Note - intranet de StatCan***  
> Les employés de StatCan peuvent également visiter la page Confluence
> de G‑Séries dans l’intranet de l’agence (cherchez « G-Series \|
> G-Séries » dans Confluence) ainsi que le projet de développement
> GitLab de G‑Séries également hébergé dans l’intranet de l’agence
> (cherchez « G-Series in R - G-Séries en R » dans GitLab). Ce dernier
> inclut des informations et instructions qui sont spécifiques à
> l’infrastructure TI de StatCan (ex., Artifactory et GitLab) ; voir le
> fichier `index_StatCan.md` dans le répertoire racine du projet GitLab.

G‑Séries 3.0 (librairie gseries 3.0.2) est la première version du
logiciel offerte en libre accès (logiciel libre). Elle inclut le
recodage en R de toutes les fonctionalités SAS<sup>®</sup> de G‑Séries
2.0, soit PROC BENCHMARKING, PROC TSRAKING et la macro
***GSeriesTSBalancing***, ainsi qu’une fonction pour l’étalonnage de
*séries de stocks* par l’entremise d’interpolations par spline cubique
où les noeuds de la spline correspondent aux ratios ou différences entre
les valeurs des étalons et de la série indicatrice.

<https://StatCan.github.io/gensol-gseries/fr/> (le site web de la
librairie gseries) est l’endroit de prédilection pour tout ce qu’il y a
à savoir sur la librairie :

- instructions d’installation (page d’accueil) ;
- documentation complète des fonctions avec des exemples (page
  **Référence**) ;
- vignettes de la librairie contenant de la documentation complémentaire
  (menu **Articles**) ;
- historique des versions de G‑Séries (page **Nouveautés** \>
  **Changements**) ;
- comment télécharger une copie locale de la documentation HTML et PDF
  de G‑Séries (page d’accueil) ;
- etc.

## Structure du projet

A l’exception des répertoires suivants, les fichiers de ce projet
suivent la structure commune (habituelle) d’une librairie R avec un site
web pkgdown :

- `docs/` (\*) : fichiers du site web pkgdown (habituellement construits
  dans un *GitHub Actions workflow* ou un *GitLab CI/CD pipeline* plutôt
  que d’être sauvegardés avec les fichiers du projet).
- `fr/` : fichiers nécessaires pour générer la version française de la
  documentation complète de la librairie gseries en format HTML et PDF
  (référence des fonctions, vignettes, etc.). Le contenu du répertoire
  `fr/` ressemble à celui du répertoire racine du projet.
- `misc/` : divers fichiers liés à la maintenance de la librairie.
- `pdf/` (\*) : documentation et vignettes de la librairie gseries en
  format PDF.

(\*) La raison d’être des répertoires `docs/` et `pdf/` est de fournir
un accès à la bibliothèque complète de la documentation disponible de
G‑Séries en format HTML et PDF, par opposition à uniquement la version
CRAN pour le site web de la librairie ou la version installée via R et
RStudio. Ainsi, que l’on soit intéressé par la documentation d’une
version précédente de G‑Séries (*tag* \< version CRAN) ou de la version
de développement (lorsque version branche *main* \> version CRAN), le
contenu de ces répertoires peut être téléchargé pour consultation hors
ligne.

## Contact - Assistance

L’assistance aux utilisateurs de G‑Séries assurée par le Centre de
recherche et d’analyse en séries chronologiques (CRASC) de la Division
des méthodes de la statistique économique (DMSE) et par la Division des
solutions de traitement numérique (DSTN). Écrivez-nous à
<g-series@statcan.gc.ca> pour obtenir des informations ou de l’aide sur
l’utilisation de G‑Séries. Les détenteurs d’un compte GitHub peuvent
également demander des informations, poser des questions ou signaler des
problèmes via la page
[*Issues*](https://github.com/StatCan/gensol-gseries/issues) du projet
GitHub de G‑Séries. Les employés de StatCan peuvent faire de même via la
page **Tickets** du projet de développement GitLab de G‑Séries hébergé
dans l’intranet de StatCan (recherchez « G-Series in R - G-Séries en R »
dans GitLab).
