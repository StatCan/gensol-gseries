# gseries 3.0.1

(*G-Séries 3.0 en R*)

* Correction d'un bogue dans `tsbalancing()` pour éviter de modifier l'option d'erreur de la session R (`getOption("error")`) après l'exécution de la fonction.

* Validation des objets d'entrée de classe « data.frame » dans les fonctions utilitaires (pertinentes) pour assurer la cohérence avec les fonctions principales.

* Mise à jour de la description des arguments des fonctions concernant la classe attendue des objets d'entrée.

* Changements mineurs pour se conformer aux exigences du CRAN suite au processus de soumission initial.


# gseries 3.0.0

(*G-Séries 3.0 en R*)

* Version initiale de G-Séries en R (librairie gseries).

* Nouvelle fonctionnalité (`stock_benchmarking()`) destinée à l'étalonnage de *séries de stocks* en utilisant une approche d'interpolation par spline cubique.

* Amélioration des fonctionnalités existantes :
  * **Étalonnage** (`benchmarking()`) : 
    * nouvelles options permettant l'étalonnage proportionnel (`lambda != 0`) en présence de valeurs négatives dans les données d'entrée;
    * l'utilisation d'une série indicatrice « plate » composée *entièrement de zéros* est maintenant possible avec l'étalonnage additif (`lambda = 0`).
  * **Ratissage** (`tsrasking()`) :
    * traitement alternatif optionnel des valeurs négatives dans les données d'entrée (même traitement que `tsbalancing()`);
    * fonction d'aide (`tsraking_driver()`) pour simplifier la réconciliation de plusieurs périodes en un seul appel de fonction.
  * **Équilibrage** (`tsbalancing()`) : 
    * séquence de résolution personnalisable (plusieurs tentatives de résolution du problème au lieu d'une seule);
    * amélioration du processus de validation des solutions avec plus d'informations (*data frames* de sortie) disponibles pour faciliter le dépannage de solutions invalides;
    * processus optionnel de *stricte validation* des données d'entrée (sans tenter de résoudre le problème, c.-a-d., résoudre les éventuelles divergences).

* Nouvelles fonctions utilitaires pour faciliter l'utilisation des fonctions principales, par exemple ;
  * pour la génération de graphiques d'étalonnage;
  * pour la conversion des métadonnées de problèmes de réconciliation (`tsrasking()` à `tsbalancing()`) ;
  * pour la manipulation des données de séries chronologiques (préparer ou convertir les objets de données d'entrée et de sortie).


# Version 2.0.0

(*G-Séries 2.0 en SAS<sup>®</sup>*, contactez [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Nouvelle macro ***GSeriesTSBalancing***.


# Version 1.4.0

(*G-Séries 1.04 en SAS<sup>®</sup>*, contactez [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Changement de nom: *Forillon* devient *G-Séries*.

* Introduction des coefficients d'altérabilité pour PROC BENCHMARKING (quand `rho < 1`).

* Nouvel énoncé `WITH` pour PROC BENCHMARKING.

* Nouvelles options `WARNNEGRESULT|NOWARNNEGRESULT` et `TOLNEGRESULT=` pour PROC BENCHMARKING and PROC TSRAKING.


# Version 1.3.0

(*G-Séries 1.03 en SAS<sup>®</sup>*, contactez [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Nouveaux énoncés `VAR` et `BY` pour PROC BENCHMARKING.


# Version 1.2.0

(*G-Séries 1.02 en SAS<sup>®</sup>*, contactez [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Ajout de PROC TSRAKING.


# Version 1.1.0

(*G-Séries 1.01 en SAS<sup>®</sup>*, contactez [g-series@statcan.gc.ca](mailto:g-series@statcan.gc.ca))

* Version initiale avec PROC BENCHMARKING.
