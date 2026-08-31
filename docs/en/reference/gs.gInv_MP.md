# Moore-Penrose inverse

This function calculates the Moore-Penrose (pseudo) inverse of a square
or rectangular matrix using Singular Value Decomposition (SVD). It is
used internally by
[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
and
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md).

## Usage

``` r
gs.gInv_MP(X, tol = NA)
```

## Arguments

- X:

  (mandatory)

  Matrix to invert.

- tol:

  (optional)

  Real number that specifies the tolerance for identifying zero singular
  values. When `tol = NA` (default), the tolerance is calculated as the
  product of the size (dimension) of the matrix, the norm of the matrix
  (largest singular value) and the *machine epsilon*
  (`.Machine$double.eps`).

  **Default value** is `tol = NA`.

## Value

The Moore-Penrose (pseudo) inverse of matrix `X`.

## Details

The default tolerance (argument `tol = NA`) is coherent with the
tolerance used by the MATLAB and GNU Octave software in their general
inverse functions. In our testing, this default tolerance also produced
solutions (results) comparable to G-Series 2.0 in SAS\\^\circledR\\.

## See also

[`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
[`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)

## Examples

``` r
# Invertible matrix
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

# Rectangular matrix
X2 <- X1[-1, ]
try(solve(X2))
#> Error in solve.default(X2) : 'a' (2 x 3) must be square
X2 %*% gs.gInv_MP(X2)
#>               [,1]         [,2]
#> [1,]  1.000000e+00 1.110223e-16
#> [2,] -4.440892e-16 1.000000e+00

# Non-invertible square matrix
X3 <- matrix(c(3, 0, 0, 
               0, 0, 0, 
               0, 0, 4), nrow = 3, byrow = TRUE)
try(solve(X3))
#> Error in solve.default(X3) : 
#>   Lapack routine dgesv: system is exactly singular: U[2,2] = 0
X3 %*% gs.gInv_MP(X3)
#>      [,1] [,2] [,3]
#> [1,]    1    0    0
#> [2,]    0    0    0
#> [3,]    0    0    1
```
