% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rkMeta_to_blSpecs.R
\name{rkMeta_to_blSpecs}
\alias{rkMeta_to_blSpecs}
\title{Convertir des métadonnées de réconciliation}
\usage{
rkMeta_to_blSpecs(
  metadata_df,
  alterability_df = NULL,
  alterSeries = 1, 
  alterTotal1 = 0,
  alterTotal2 = 0,
  alterability_df_only = FALSE
)
}
\arguments{
\item{metadata_df}{(obligatoire)

\emph{Data frame} (object de classe « data.frame ») qui décrit les contraintes d'agrégation transversales (règles
d'additivité) pour le problème de ratissage (« \emph{raking} »). Deux variables de type caractère doivent être incluses
dans le \emph{data frame} : \code{series} et \code{total1}. Deux variables sont optionnelles : \code{total2} (caractère) et \code{alterAnnual}
(numérique). Les valeurs de la variable \code{series} représentent les noms des variables des séries composantes dans le
\emph{data frame} des données d'entrée (argument \code{data_df}). De même, les valeurs des variables \code{total1} et \code{total2}
représentent les noms des variables des totaux de contrôle transversaux de 1\if{html}{\out{<sup>}}ère\if{html}{\out{</sup>}} et 2\if{html}{\out{<sup>}}ème\if{html}{\out{</sup>}} dimension
dans le \emph{data frame} des données d'entrée. La variable \code{alterAnnual} contient le coefficient d'altérabilité pour la
contrainte temporelle associée à chaque série composante. Lorsqu'elle est spécifiée, cette dernière remplace le
coefficient d'altérabilité par défaut spécifié avec l'argument \code{alterAnnual}.}

\item{alterability_df}{(optionnel)

\emph{Data frame} (object de classe « data.frame »), ou \code{NULL}, qui contient les variables de coefficients d'altérabilité.
Elles doivent correspondre à une série composante ou à un total de contrôle transversal, c'est-à-dire qu'une variable
portant le même nom doit exister dans le \emph{data frame} des données d'entrée (argument \code{data_df}). Les valeurs de
ces coefficients d'altérabilité remplaceront les coefficients d'altérabilité par défaut spécifiés avec les arguments
\code{alterSeries}, \code{alterTotal1} et \code{alterTotal2}. Lorsque le \emph{data frame} des données d'entrée contient plusieurs
enregistrements et que le \emph{data frame} des coefficients d'altérabilité n'en contient qu'un seul, les coefficients
d'altérabilité sont utilisés (répétés) pour tous les enregistrements du \emph{data frame} des données d'entrée. Le
\emph{data frame} des coefficients d'altérabilité peut également contenir autant d'enregistrements que le \emph{data frame}
des données d'entrée.

\strong{La valeur par défaut} est \code{alterability_df = NULL} (coefficients d'altérabilité par défaut).}

\item{alterSeries}{(optionnel)

Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut pour les valeurs des séries composantes.
Il s'appliquera aux séries composantes pour lesquelles des coefficients d'altérabilité n'ont pas déjà été spécifiés
dans le \emph{data frame} des coefficients d'altérabilité (argument \code{alterability_df}).

\strong{La valeur par défaut} est \code{alterSeries = 1.0} (valeurs des séries composantes non contraignantes).}

\item{alterTotal1}{(optionnel)

Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut pour les totaux de contrôle transversaux
de la 1\if{html}{\out{<sup>}}ère\if{html}{\out{</sup>}} dimension. Il s'appliquera aux totaux de contrôle transversaux pour lesquels des coefficients
d'altérabilité n'ont pas déjà été spécifiés dans le \emph{data frame} des coefficients d'altérabilité (argument
\code{alterability_df}).

\strong{La valeur par défaut} est \code{alterTotal1 = 0.0} (totaux de contrôle transversaux de 1\if{html}{\out{<sup>}}ère\if{html}{\out{</sup>}} dimension
contraignants).}

\item{alterTotal2}{(optionnel)

Nombre réel non négatif spécifiant le coefficient d'altérabilité par défaut pour les totaux de contrôle transversaux
de la 2\if{html}{\out{<sup>}}ème\if{html}{\out{</sup>}} dimension. Il s'appliquera aux totaux de contrôle transversaux pour lesquels des coefficients
d'altérabilité n'ont pas déjà été spécifiés dans le \emph{data frame} des coefficients d'altérabilité (argument
\code{alterability_df}).

\strong{La valeur par défaut} est \code{alterTotal2 = 0.0} (totaux de contrôle transversaux de 2\if{html}{\out{<sup>}}ème\if{html}{\out{</sup>}} dimension
contraignants).}

\item{alterability_df_only}{(optionnel)

Argument logique (\emph{logical}) spécifiant si oui ou non seul l'ensemble des coefficients d'altérabilité trouvés dans le
fichier d'altérabilité (argument \code{alterability_df}) doit être inclus dans le \emph{data frame} de spécifications de problème
\code{\link[=tsbalancing]{tsbalancing()}} renvoyé. Lorsque \code{alterability_df_only = FALSE} (la valeur par défaut), les coefficients d'altérabilité
spécifiés avec les arguments \code{alterSeries}, \code{alterTotal1} et \code{alterTotal2} sont combinés avec ceux trouvés dans
\code{alterability_df} (les derniers coefficients remplaçant les premiers) et le \emph{data frame} renvoyé contient donc les
coefficients d'altérabilité pour toutes les séries composantes et de totaux de contrôle transversaux. Cet argument
n'affecte pas l'ensemble des coefficients d'altérabilité des totaux temporels (associés à l'argument \code{alterAnnual} de
\code{\link[=tsraking]{tsraking()}}) qui sont inclus dans le \emph{data frame} de spécifications de problème \code{\link[=tsbalancing]{tsbalancing()}} renvoyé. Ce dernier
contient toujours strictement ceux spécifiés dans \code{metadata_df} avec une valeur non manquante (non \code{NA}) pour la colonne
\code{alterAnnual}.

\strong{La valeur par défaut} est \code{alterability_df_only = FALSE}.}
}
\value{
Un \emph{data frame} de spécifications de problème \code{\link[=tsbalancing]{tsbalancing()}} (argument \code{problem_specs_df}).
}
\description{
Convertir un \emph{data frame} de métadonnées \code{\link[=tsraking]{tsraking()}} en un \emph{data frame} de spécifications de problème \code{\link[=tsbalancing]{tsbalancing()}}.
}
\details{
La description précédente de l'argument \code{alterability_df} provient de \code{\link[=tsraking]{tsraking()}}. Cette fonction (\code{rkMeta_to_blSpecs()})
modifie légèrement la spécification des coefficients d'altérabilité avec l'argument \code{alterability_df} en permettant
\itemize{
\item soit un seul enregistrement, spécifiant l'ensemble des coefficients d'altérabilité à utiliser pour toutes les périodes,
\item soit un ou plusieurs enregistrements avec une colonne supplémentaire nommée \code{timeVal} permettant de spécifier à la fois
des coefficients d'altérabilité spécifiques à la période (\code{timeVal} n'est pas \code{NA}) et des coefficients génériques à
utiliser pour toutes les autres périodes (\code{timeVal} est \code{NA}). Les valeurs de la colonne \code{timeVal} correspondent aux
\emph{valeurs de temps} d'un objet « ts » telles que renvoyées par \code{\link[stats:time]{stats::time()}}, correspondant conceptuellement à
\eqn{ann\acute{e}e + (p\acute{e}riode - 1) / fr\acute{e}quence}.
}

Une autre différence avec \code{\link[=tsraking]{tsraking()}} est que des valeurs manquantes (\code{NA}) sont autorisés dans le \emph{data frame} des
coefficients d'altérabilité (argument \code{alterability_df}) et que l'on utiliserait alors les coefficients génériques
(enregistrements pour lesquels \code{timeVal} est \code{NA}) ou les coefficients par défaut (arguments \code{alterSeries}, \code{alterTotal1}
et \code{alterTotal2}).

Notez que à part rejeter les coefficients d'altérabilité pour les séries qui ne sont pas énumérées dans le \emph{data frame}
des métadonnées de ratissage (argument \code{metadata_df}), cette fonction ne valide pas les valeurs trouvées dans le
\emph{data frame} des coefficients d'altérabilité (argument \code{alterability_df}) ni celles trouvées dans la colonne \code{alterAnnual}
du \emph{data frame} des métadonnées de ratissage (argument \code{metadata_df}). La fonction les transfère \emph{telles quelles} dans le
\emph{data frame} des spécifications de problème \code{\link[=tsbalancing]{tsbalancing()}} renvoyé.
}
\examples{
# Métadonnées de `tsraking()` pour un problème à deux dimensions (table 2 x 2)
mes_metadonnees <- data.frame(series = c("A1", "A2", "B1", "B2"),
                              total1 = c("totA", "totA", "totB", "totB"),
                              total2 = c("tot1", "tot2", "tot1", "tot2"))
mes_metadonnees


# Convertir en spécifications de `tsbalancing()`

# Inclure les coefficients d'altérabilité par défaut de `tsraking()`
rkMeta_to_blSpecs(mes_metadonnees)

# Totaux presque contraignants pour la 1ère marge (petits coef. d'altérabilité pour 
# les colonnes `totA` et `totB`)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterTotal1 = 1e-6))

# Ne pas inclure les coef. d'altérabilité (contraintes d'agrégation uniquement)
rkMeta_to_blSpecs(mes_metadonnees, alterability_df_only = TRUE)

# Avec un fichier de coefficients d'altérabilité (argument `alterability_df`)
mes_coefsAlt = data.frame(B2 = 0.5)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterability_df = mes_coefsAlt))

# N'inclure que les coefficients d'altérabilité du fichier `alterability_df` 
# (c.-à-d. pour la colonne `B2`)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterability_df = mes_coefsAlt,
                       alterability_df_only = TRUE))
}
\seealso{
\code{\link[=tsraking]{tsraking()}} \code{\link[=tsbalancing]{tsbalancing()}}
}
