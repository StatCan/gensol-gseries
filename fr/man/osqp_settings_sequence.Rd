% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{osqp_settings_sequence}
\alias{osqp_settings_sequence}
\alias{default_osqp_sequence}
\alias{alternate_osqp_sequence}
\title{\emph{Data frame} pour la séquence de paramètres d'OSQP}
\format{
Un \emph{data frame} avec au moins un enregistrement (une rangée) et au moins une colonne, les colonnes \emph{les plus
courantes} étant :
\describe{
\item{max_iter}{Nombre maximal d'itérations (\emph{integer})}
\item{sigma}{Pas sigma (\emph{sigma step}) de la méthode des multiplicateurs à direction alternée (MMDA, ou ADMM en anglais
pour \emph{alternating direction method of multipliers}) (\emph{double})}
\item{eps_abs}{Tolérance absolue (\emph{double})}
\item{eps_rel}{Tolérance relative (\emph{double})}
\item{eps_prim_inf}{Tolérance d'infaisabilité du problème primal (\emph{double})}
\item{eps_dual_inf}{Tolérance d'infaisabilité du problème dual (\emph{double})}
\item{polish}{Effectuer l'étape de raffinement de la solution (\emph{logical})}
\item{scaling}{Nombre d'itérations de mise à l'échelle (\emph{integer})}
\item{prior_scaling}{Mise à l'échelle préalable des données, avant la résolution avec OSQP (\emph{logical})}
\item{require_polished}{Exiger une solution raffinée (\emph{polished solution}) pour arrêter la séquence (\emph{logical})}
\item{[\emph{any-other-OSQP-setting}]}{Valeur du paramètre OSQP correspondant}
}
}
\usage{
# Séquence par défaut :
# tsbalancing(..., osqp_settings_df = default_osqp_sequence)

# Séquence alternative (plus lente) :
# tsbalancing(..., osqp_settings_df = alternate_osqp_sequence)

# Séquence personnalisée (à utiliser avec précaution !) :
# tsbalancing(..., osqp_settings_df = <mon-dataframe-de-sequence-osqp>)

# Une seule tentative de résolution avec les valeurs par défaut d'OSQP (déconseillé !) :
# tsbalancing(..., osqp_settings_df = NULL)
}
\description{
\emph{Data frame} contenant une séquence de paramètres d'OSQP pour \code{\link[=tsbalancing]{tsbalancing()}} spécifié avec l'argument
\code{osqp_settings_df}. La librairie inclut deux \emph{data frames} prédéfinis de séquences de paramètres d'OSQP :
\itemize{
\item \code{\link[=osqp_settings_sequence]{default_osqp_sequence}} : rapide et efficace (valeur par défaut de l'argument \code{osqp_settings_df});
\item \code{\link[=osqp_settings_sequence]{alternate_osqp_sequence}} : orienté vers la précision au détriment du temps d'exécution.
}

Voir \code{vignette("osqp-settings-sequence-dataframe")} pour le contenu de ces \emph{data frames}.
}
\details{
À l'exception de \code{prior_scaling} et \code{require_polished}, toutes les colonnes du \emph{data frame} doivent correspondre
à un paramètre d'OSQP. Les valeurs par défaut d'OSQP sont utilisées pour tout paramètre non spécifié dans ce \emph{data frame}.
Visitez \url{https://osqp.org/docs/interfaces/solver_settings.html} pour connaître tous les paramètres d'OSQP disponibles.
Notez que le paramètre d'OSQP \code{verbose} est en fait contrôlé par les arguments \code{quiet} et \code{display_level} de \code{tsbalancing()}
(c'est à dire que la colonne \code{verbose} dans un \emph{data frame pour la séquence de paramètres d'OSQP} serait ignorée).

Chaque enregistrement (rangée) d'un \emph{data frame pour la séquence de paramètres d'OSQP} représente une tentative de
résolution d'un problème d'équilibrage avec les paramètres d'OSQP correspondants. La séquence de résolution s'arrête
dès qu'une solution valide est obtenue (une solution pour laquelle tous les écarts de contraintes sont inférieurs ou
égaux à la tolérance spécifiée avec l'argument \code{validation_tol} de \code{tsbalancing()}) à moins que la colonne
\code{require_polished = TRUE}, auquel cas une solution \emph{raffinée} d'OSQP (\code{status_polish = 1}) serait également nécessaire pour
arrêter la séquence. Les écarts de contraintes correspondent à \eqn{\mathrm{max}(0, l - Ax, Ax - u)} avec des contraintes définies
comme \eqn{l \le Ax \le u}. Dans le cas où une solution satisfaisante ne peut être obtenue après avoir parcouru toute la
séquence, \code{tsbalancing()} renvoie la solution qui a généré le plus petit total d'écarts de contraintes parmi les solutions
valides, le cas échéant, ou parmi toutes les solutions, dans le cas contraire. Notez que l'exécution de la séquence de
résolution entière peut être \emph{forcée} en spécifiant l'argument \code{full_sequence = TRUE} avec \code{tsbalancing()}. Les
enregistrements avec la colonne \code{prior_scaling = TRUE} ont les données du problème mises à l'échelle avant la résolution
avec OSQP, en utilisant la moyenne des valeurs libres (non contraignantes) du problème comme facteur d'échelle.

En plus de spécifier un \emph{data frame pour la séquence de paramètres d'OSQP} personnalisé avec l'argument \code{osqp_settings_df},
on peut aussi spécifier \code{osqp_settings_df = NULL} ce qui résultera en une seule tentative de résolution avec les valeurs par
défaut d'OSQP pour tous les paramètres et avec \code{prior_scaling = FALSE} et \code{require_polished = FALSE}. Il est cependant
recommandé d'essayer d'abord les \emph{data frames} \code{default_osqp_sequence} et \code{alternate_osqp_sequence}, avec
\code{full_sequence = TRUE} si nécessaire, avant d'envisager d'autres alternatives.

La vignette \emph{« Data frame » pour la séquence de paramètres d’OSQP} (\ifelse{latex}{\code{vignette("osqp-settings 
-sequence-dataframe")}}{\code{vignette("osqp-settings-sequence-dataframe")}}) contient des informations supplémentaires.
}
\keyword{datasets}
