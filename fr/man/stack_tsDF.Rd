% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stack_tsDF.R
\name{stack_tsDF}
\alias{stack_tsDF}
\title{Empiler des données de séries chronologiques}
\usage{
stack_tsDF(
  ts_df,
  ser_cName = "series",
  yr_cName = "year",
  per_cName = "period",
  val_cName = "value",
  keep_NA = FALSE
)
}
\arguments{
\item{ts_df}{(obligatoire)

\emph{Data frame} (object de classe « data.frame ») qui contient les données de séries chronologiques multivariées à empiler.}

\item{ser_cName}{(optionnel)

Chaîne de caractères spécifiant le nom de la variable (colonne) du \emph{data frame} empilé de sortie qui contiendra
les nom des séries (nom des variables des séries dans le \emph{data frame} de séries chronologiques multivariées d'entrée).
Cette variable peut ensuite être utilisée comme variable de groupes-BY (argument \code{by}) avec les fonctions d'étalonnage.

\strong{La valeur par défaut} est \code{ser_cName = "series"}.}

\item{yr_cName, per_cName}{(optionnel)

Chaînes de caractères spécifiant le nom des variables (colonnes) numériques du \emph{data frame} de séries chronologiques
multivariées d'entrée qui identifient l'année et la période (cycle) des points de données. Ces variables sont \emph{transférées}
dans le \emph{data frame} empilé de sortie avec les mêmes noms de variable.

\strong{Les valeurs par défaut} sont \code{yr_cName = "year"} et \code{per_cName = "period"}.}

\item{val_cName}{(optionnel)

Chaîne de caractères spécifiant le nom de la variable (colonne) du \emph{data frame} empilé de sortie qui contiendra
la valeur des points de données.

\strong{La valeur par défaut} est \code{val_cName = "value"}.}

\item{keep_NA}{(optionnel)

Argument logique (\emph{logical}) spécifiant si les valeurs de série manquantes (\code{NA}) du \emph{data frame} de séries
chronologiques multivariées d'entrée doivent être conservées dans le \emph{data frame} empilé de sortie.

\strong{La valeur par défaut} est \code{keep_NA = FALSE}.}
}
\value{
La fonction renvoie un \emph{data frame} avec quatre variables :
\itemize{
\item Nom de la série, type caractère (voir l'argument \code{ser_cName})
\item Année du point de données, type numérique (voir argument \code{yr_cName})
\item Période du point de données, type numérique (voir argument \code{per_cName})
\item Valeur du point de données, type numérique (voir argument \code{val_cName})
}

Note : la fonction renvoie un objet « data.frame » qui peut être explicitement converti en un autre
type d'objet avec la fonction \verb{as*()} appropriée (ex., \code{tibble::as_tibble()} le convertirait en tibble).
}
\description{
Convertir un \emph{data frame} de séries chronologiques multivariées (voir \code{\link[=ts_to_tsDF]{ts_to_tsDF()}}) pour les fonctions d'étalonnage
(\code{\link[=benchmarking]{benchmarking()}} et \code{\link[=stock_benchmarking]{stock_benchmarking()}}) en un \emph{data frame} empilé (long) avec quatre variables (colonnes) :
\itemize{
\item une (1) pour le nom de la série
\item deux (2) pour l'identification du point de données (année et période)
\item une (1) pour la valeur du point de données
}

Les valeurs de série manquantes (\code{NA}) ne sont pas incluses par défaut dans le \emph{data frame} empilé renvoyé par
la fonction. Spécifiez l'argument \code{keep_NA = TRUE} pour les conserver.

Cette fonction est utile lorsque l'on souhaite utiliser l'argument \code{by} (mode de traitement \emph{groupes-BY}) des
fonctions d'étalonnage afin d'étalonner plusieurs séries en un seul appel de fonction.
}
\examples{
# Créer un « data frame » de 2 séries indicatrices trimestrielles
# (avec des valeurs manquantes pour les 2 dernières trimestres)
mes_indicateurs <- ts_to_tsDF(ts(data.frame(ser1 = c(1:5 *  10, NA, NA),
                                            ser2 = c(1:5 * 100, NA, NA)), 
                                 start = c(2019, 1), frequency = 4))
mes_indicateurs


# Empiler les séries indicatrices ...

# en rejetant les `NA` dans les données empilées (comportement par défaut)
stack_tsDF(mes_indicateurs)

# en conserver les `NA` dans les données empilées
stack_tsDF(mes_indicateurs, keep_NA = TRUE)

# en utilisant des noms de variables (colonnes) personnalisés
stack_tsDF(mes_indicateurs, ser_cName = "nom_ind", val_cName = "val_ind")
}
\seealso{
\code{\link[=unstack_tsDF]{unstack_tsDF()}} \code{\link[=stack_bmkDF]{stack_bmkDF()}} \code{\link[=ts_to_tsDF]{ts_to_tsDF()}} \code{\link[=benchmarking]{benchmarking()}} \code{\link[=stock_benchmarking]{stock_benchmarking()}}
}
