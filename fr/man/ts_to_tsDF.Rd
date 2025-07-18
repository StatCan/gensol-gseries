% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ts_to_tsDF.R
\name{ts_to_tsDF}
\alias{ts_to_tsDF}
\title{Convertir un objet « ts » en \emph{data frame} de séries chronologiques}
\usage{
ts_to_tsDF(
  in_ts,
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value"
)
}
\arguments{
\item{in_ts}{(obligatoire)

Objet de type série chronologique (classe « ts » ou « mts ») à convertir.}

\item{yr_cName, per_cName}{(optionnel)

Chaînes de caractères spécifiant le nom des variables (colonnes) numériques dans le \emph{data frame} de sortie
qui contiendront les identificateurs d'année et de période du point de données.

\strong{Les valeurs par défaut} sont \code{yr_cName = "year"} et \code{per_cName = "period"}.}

\item{val_cName}{(optionnel)

Chaîne de caractères spécifiant le nom de la variable (colonne) dans le \emph{data frame} de sortie qui contiendra les
valeurs des points de données. Cet argument n'a aucun effet pour les objets « mts » (les noms des variables de
données des séries chronologiques sont automatiquement hérités de l'objet « mts »).

\strong{La valeur par défaut} est \code{val_cName = "value"}.}
}
\value{
La fonction renvoie un \emph{data frame} avec trois variables ou plus :
\itemize{
\item Année du point de données, type numérique (voir argument \code{yr_cName})
\item Période du point de données, type numérique (voir argument \code{per_cName})
\item Valeur du point de données, type numérique (voir argument \code{val_cName})
\item Une (objet « ts ») ou plusieurs (objet « mts ») variable(s) de données de série(s) chronologique(s), type numérique
(voir argument \code{val_cName})
}

Note : la fonction renvoie un objet « data.frame » qui peut être explicitement converti en un autre
type d'objet avec la fonction \verb{as*()} appropriée (ex., \code{tibble::as_tibble()} le convertirait en tibble).
}
\description{
Convertir un objet « ts  » (ou « mts ») en un \emph{data frame} de séries chronologiques pour les fonctions d'étalonnage avec
trois variables (colonnes) ou plus :
\itemize{
\item deux (2) pour l'identification du point de données (année et période)
\item une (1) pour chaque série chronologique
}

Pour des étalons discrets (points d'ancrage couvrant une seule période de la série indicatrice, par exemple, des stocks de
fin d'année), spécifiez \code{discrete_flag = TRUE} et \code{alignment = "b"}, \code{"e"} ou \code{"m"}.
}
\examples{
# Série chronologique Quarterly time series
ma_sc <- ts(1:10 * 100, start = 2019, frequency = 4)
ma_sc


# Noms de variables (colonnes) par défaut
ts_to_tsDF(ma_sc)

# Nom personnalisé pour la variable (colonne) des étalons
ts_to_tsDF(ma_sc, val_cName = "ser_val")


# Séries chronologiques multiples: argument `val_cName` ignoré
# (les noms de colonnes de l'object « mts » sont toujours utilisés)
ts_to_tsDF(ts.union(ser1 = ma_sc,
                    ser2 = ma_sc / 10),
            val_cName = "nom_de_colonne_inutile")
}
\seealso{
\code{\link[=tsDF_to_ts]{tsDF_to_ts()}} \code{\link[=ts_to_bmkDF]{ts_to_bmkDF()}} \code{\link[=stack_tsDF]{stack_tsDF()}} \code{\link[=benchmarking]{benchmarking()}} \code{\link[=stock_benchmarking]{stock_benchmarking()}} \link{time_values_conv}
}
