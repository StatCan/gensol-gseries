% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-common.R
\name{gs.gInv_MP}
\alias{gs.gInv_MP}
\title{Moore-Penrose inverse}
\usage{
gs.gInv_MP(X, tol = NA)
}
\arguments{
\item{X}{(mandatory)

Matrix to invert.}

\item{tol}{(optional)

Real number that specifies the tolerance for identifying zero singular values. When \code{tol = NA} (default),
the tolerance is calculated as the product of the size (dimension) of the matrix, the norm of the matrix
(largest singular value) and the \emph{machine epsilon} (\code{.Machine$double.eps}).

\strong{Default value} is \code{tol = NA}.}
}
\value{
The Moore-Penrose (pseudo) inverse of matrix \code{X}.
}
\description{
\if{html,text}{(\emph{version française: 
\url{https://StatCan.github.io/gensol-gseries/fr/reference/gs.gInv_MP.html}})}

This function calculates the Moore-Penrose (pseudo) inverse of a square or rectangular matrix
using Singular Value Decomposition (SVD). It is used internally by \code{\link[=tsraking]{tsraking()}} and \code{\link[=benchmarking]{benchmarking()}}.
}
\details{
The default tolerance (argument \code{tol = NA}) is coherent with the tolerance used by the MATLAB and GNU Octave
software in their general inverse functions. In our testing, this default tolerance also produced solutions
(results) comparable to G-Series 2.0 in SAS\eqn{^\circledR}{®}.
}
\examples{
# Invertible matrix
X1 <- matrix(c(3, 2, 8, 
               6, 3, 2,
               5, 2, 4), nrow = 3, byrow = TRUE)
Y1 <- gs.gInv_MP(X1)
all.equal(Y1, solve(X1))
X1 \%*\% Y1

# Rectangular matrix
X2 <- X1[-1, ]
try(solve(X2))
X2 \%*\% gs.gInv_MP(X2)

# Non-invertible square matrix
X3 <- matrix(c(3, 0, 0, 
               0, 0, 0, 
               0, 0, 4), nrow = 3, byrow = TRUE)
try(solve(X3))
X3 \%*\% gs.gInv_MP(X3)

}
\seealso{
\code{\link[=tsraking]{tsraking()}} \code{\link[=benchmarking]{benchmarking()}}
}
