# Inverse de Moore-Penrose

Cette fonction calcule l'inverse (pseudo inverse) de Moore-Penrose d'une
matrice carrée ou rectangulaire en utilisant la décomposition en valeurs
singulières (SVD, de l'anglais *singular value decomposition*). Elle est
utlilisée à l'interne par
[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
et
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md).

## Utilisation

``` r
gs.gInv_MP(X, tol = NA)
```

## Arguments

- X:

  (obligatoire)

  Matrice à inverser.

- tol:

  (optionnel)

  Nombre réel qui spécifie la tolérance pour l'identification des
  valeurs singulières nulles. Lorsque `tol = NA` (par défaut), la
  tolérance est calculée comme étant le produit de la taille (dimension)
  de la matrice, de la norme de la matrice (plus grande valeur
  singulière) et de l'*epsilon de la machine* (`.Machine$double.eps`).

  **La valeur par défaut** est `tol = NA`.

## Valeur de retour

L'inverse (pseudo inverse) de Moore-Penrose de la matrice `X`.

## Détails

La tolérance utilisée par défaut (argument `tol = NA`) est cohérente
avec la tolérance utilisée par les logiciels MATLAB et GNU Octave dans
leurs fonctions inverses générales. Lors de nos tests, cette tolérance
par défaut a également produit des solutions (résultats) comparables à
G-Series 2.0 en SAS\\^\circledR\\.

## Voir également

[`tsraking()`](https://StatCan.github.io/gensol-gseries/fr/reference/tsraking.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/fr/reference/benchmarking.md)

## Exemples

``` r
# Matrice inversible
X1 <- matrix(c(3, 2, 8, 
               6, 3, 2,
               5, 2, 4), nrow = 3, byrow = TRUE)
Y1 <- gs.gInv_MP(X1)
all.equal(Y1, solve(X1))
#> [1] TRUE
X1 %*% Y1
#>               [,1]          [,2]         [,3]
#> [1,]  1.000000e+00 -1.110223e-15 3.885781e-15
#> [2,] -2.220446e-16  1.000000e+00 1.748601e-15
#> [3,] -8.881784e-16 -8.881784e-16 1.000000e+00

# Matrice rectangulaire
X2 <- X1[-1, ]
try(solve(X2))
#> Error in solve.default(X2) : 'a' (2 x 3) doit être carrée
X2 %*% gs.gInv_MP(X2)
#>               [,1]         [,2]
#> [1,]  1.000000e+00 1.110223e-16
#> [2,] -4.440892e-16 1.000000e+00

# Matrice carrée non inversible
X3 <- matrix(c(3, 0, 0, 
               0, 0, 0, 
               0, 0, 4), nrow = 3, byrow = TRUE)
try(solve(X3))
#> Error in solve.default(X3) : 
#>   Routine Lapack dgesv : le système est exactement singulier : U[2,2] = 0
X3 %*% gs.gInv_MP(X3)
#>      [,1] [,2] [,3]
#> [1,]    1    0    0
#> [2,]    0    0    0
#> [3,]    0    0    1
```
