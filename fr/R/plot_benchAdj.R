#' Tracer les ajustements d'étalonnage
#'
#'
#' @description
#' Tracer les ajustements d'étalonnage pour une série unique dans le périphérique graphique courant (actif). Il est possible 
#' de superposer jusqu'à trois types d'ajustements dans le même graphique :
#' - Ajustements générés par la fonction [benchmarking()]
#' - Ajustements générés par la fonction [stock_benchmarking()]
#' - Spline cubique associée aux ajustements générés par la fonction [stock_benchmarking()]
#' 
#' Ces graphiques peuvent être utiles pour évaluer la qualité des résultats d'étalonnage et comparer les ajustements générés par 
#' les deux fonctions d'étalonnage ([benchmarking()] et [stock_benchmarking()]) pour des séries de stocks.
#'
#'
#' @param PB_graphTable (optionnel)
#'
#' *Data frame*, ou objet compatible, correspondant au *data frame* de sortie `graphTable` de la fonction [benchmarking()] (PB pour 
#' approche « Proc Benchmarking »). Spécifiez `NULL` pour ne pas inclure les ajustements de [benchmarking()] dans le graphique.
#'
#' **La valeur par défaut** est `PB_graphTable = NULL`.
#'
#' @param SB_graphTable (optionnel)
#'
#' *Data frame*, ou objet compatible, correspondant au *data frame* de sortie `graphTable` de la fonction [stock_benchmarking()] 
#' (SB). Spécifiez `NULL` pour ne pas inclure les ajustements de [stock_benchmarking()] dans le graphique.
#'
#' **La valeur par défaut** est `SB_graphTable = NULL`.
#'
#' @param SB_splineKnots (optionnel)
#'
#' *Data frame*, ou objet compatible, correspondant au *data frame* de sortie `splineKnots` de la fonction [stock_benchmarking()] 
#' (SB). Spécifiez `NULL` pour ne pas inclure la spline cubique de [stock_benchmarking()] dans le graphique.
#'
#' **La valeur par défaut** est `SB_splineKnots = NULL`.
#'
#' @param legendPos (optionnel)
#'
#' Chaîne de caractères (mot-clé) spécifiant l'emplacement de la légende dans le graphique. Voir la description de l'argument `x` 
#' dans la documentation de `graphics::legend()` pour la liste des mots-clés valides. Spécifiez `NULL` pour ne pas inclure de 
#' légende dans le graphique.
#'
#' **La valeur par défaut** est `legendPos = "bottomright"` (en bas à droite).
#'
#'
#' @details
#' Variables du *data frame* `graphTable` (arguments `PB_graphTable` et `SB_graphTable`) utilisées dans le graphique :
#' - `t` pour l'axe des x (*t*)
#' - `benchmarkedSubAnnualRatio` pour les lignes *Stock Bench. (SB)* et *Proc Bench. (PB)*
#' - `bias` pour la ligne *Bias* (lorsque \eqn{\rho < 1})
#' 
#' Variables du *data frame* `splineKnots` (argument `SB_splineKnots`) utilisées dans le graphique :
#' - `x` pour l'axe des x (*t*)
#' - `y` pour la ligne *Cubic spline* et les points *Extra knot* et *Original knot*
#' - `extraKnot` pour le type de nœud (*Extra knot* contre *Original knot*)
#' 
#' Voir la section **Valeur de retour** de [benchmarking()] et [stock_benchmarking()] pour plus d'informations sur ces 
#' *data frames*.
#'
#'
#' @returns
#' Cette fonction ne renvoie rien (`invisible(NULL)`).
#'
#'
#' @seealso [plot_graphTable()] [bench_graphs] [benchmarking()] [stock_benchmarking()]
#'
#'
#' @example misc/function_examples/plot_benchAdj-ex.R
#'
#'
#' @export
plot_benchAdj <- function(PB_graphTable = NULL,
                          SB_graphTable = NULL,
                          SB_splineKnots = NULL,
                          legendPos = "bottomright") {
  
  # Initialize info
  lab_list <- NULL
  col_list <- NULL
  lty_list <- NULL
  lwd_list <- NULL
  pch_list <- NULL
  pt.cex_list <- NULL
  min_x <- .Machine$double.xmax
  max_x <- .Machine$double.xmin
  min_y <- .Machine$double.xmax
  max_y <- .Machine$double.xmin
  bias <- NULL
  BI_string <- ""
  
  # Process `stock_benchmarking()` `splineKnots` data frame info
  if (!is.null(SB_splineKnots)) {
    
    # Accept `SB_splineKnots = NA` as `SB_splineKnots = NULL`
    tmp <- (unlist(SB_splineKnots))[1]
    if (identical(SB_splineKnots, tmp) && is.na(tmp)) {
      SB_splineKnots <- NULL
    } else {
      
      SB_splineKnots <- as.data.frame(SB_splineKnots)
      var_list <- names(SB_splineKnots)
      if ("extraKnot" %in% var_list) {
        extraKnot_flag <- TRUE
        lab_list <- c(lab_list, "Cubic spline", "Extra knot", "Original knot")
        col_list <- c(col_list, "black", "black", "green3")
        lty_list <- c(lty_list, 1, NA, NA)
        lwd_list <- c(lwd_list, 1, NA, NA)
        pch_list <- c(pch_list, NA, 1, 19)
        pt.cex_list <- c(pt.cex_list, NA, 1.5, 1.5)
      } else {
        extraKnot_flag <- FALSE
        lab_list <- c(lab_list, "Cubic spline")
        col_list <- c(col_list, "black")
        lty_list <- c(lty_list, 1)
        lwd_list <- c(lwd_list, 1)
        pch_list <- c(pch_list, 1)
        pt.cex_list <- c(pt.cex_list, 1.5)
      }
      interpol <- stats::spline(SB_splineKnots$x, SB_splineKnots$y, method = "natural")
      min_x <- min(min_x, interpol$x, na.rm = TRUE)
      max_x <- max(max_x, interpol$x, na.rm = TRUE)
      min_y <- min(min_y, interpol$y, na.rm = TRUE)
      max_y <- max(max_y, interpol$y, na.rm = TRUE)
    }
  }
  
  # Process `stock_benchmarking()` `graphTable` data frame info
  if (!is.null(SB_graphTable)) {
    
    # Accept `SB_graphTable = NA` as `SB_graphTable = NULL`
    tmp <- (unlist(SB_graphTable))[1]
    if (identical(SB_graphTable, tmp) && is.na(tmp)) {
      SB_graphTable <- NULL
    } else {
      
      SB_graphTable <- as.data.frame(SB_graphTable)
      lab_list <- c(lab_list, "Stock Bench. (SB)")
      col_list <- c(col_list, "red")
      lty_list <- c(lty_list, 1)
      lwd_list <- c(lwd_list, 1)
      pch_list <- c(pch_list, 1)
      pt.cex_list <- c(pt.cex_list, 1)
      min_x <- min(min_x, SB_graphTable$t, na.rm = TRUE)
      max_x <- max(max_x, SB_graphTable$t, na.rm = TRUE)
      min_y <- min(min_y, SB_graphTable$benchmarkedSubAnnualRatio, na.rm = TRUE)
      max_y <- max(max_y, SB_graphTable$benchmarkedSubAnnualRatio, na.rm = TRUE)
      var_list <- names(SB_graphTable)
      if ("bias" %in% var_list) {
        
        # Display the bias line only for non-Denton benchmarking (`rho < 1`)
        if ("rho" %in% var_list) {
          if (abs(SB_graphTable$rho[1] - 1) > gs.tolerance) {
            bias <- SB_graphTable$bias[1]
          }
        } else {
          bias <- SB_graphTable$bias[1]
        }
      }
      if ("lambda" %in% var_list) {
        if (SB_graphTable$lambda[1] == 0) {
          BI_string <- "(BI differences)"
        } else {
          BI_string <- "(BI ratios)"
        }
      }
    }
    
  }
  
  # Process `benchmarking()` `graphTable` data frame info
  if (!is.null(PB_graphTable)) {
    
    # Accept `PB_graphTable = NA` as `PB_graphTable = NULL`
    tmp <- (unlist(PB_graphTable))[1]
    if (identical(PB_graphTable, tmp) && is.na(tmp)) {
      PB_graphTable <- NULL
    } else {
      
      PB_graphTable <- as.data.frame(PB_graphTable)
      PB_graphTable <- PB_graphTable[!duplicated(PB_graphTable[c("t", "benchmarkedSubAnnualRatio")]), ]
      lab_list <- c(lab_list, "Proc Bench. (PB)")
      col_list <- c(col_list, "blue")
      lty_list <- c(lty_list, 1)
      lwd_list <- c(lwd_list, 1)
      pch_list <- c(pch_list, 1)
      pt.cex_list <- c(pt.cex_list, 1)
      min_x <- min(min_x, PB_graphTable$t, na.rm = TRUE)
      max_x <- max(max_x, PB_graphTable$t, na.rm = TRUE)
      min_y <- min(min_y, PB_graphTable$benchmarkedSubAnnualRatio, na.rm = TRUE)
      max_y <- max(max_y, PB_graphTable$benchmarkedSubAnnualRatio, na.rm = TRUE)
      var_list <- names(PB_graphTable)
      if ("bias" %in% var_list) {
        
        # Display the bias line only for non-Denton benchmarking (`rho < 1`)
        if ("rho" %in% var_list) {
          if (abs(PB_graphTable$rho[1] - 1) > gs.tolerance) {
            bias <- PB_graphTable$bias[1]
          }
        } else {
          bias <- PB_graphTable$bias[1]
        }
      }
      if ("lambda" %in% var_list) {
        if (PB_graphTable$lambda[1] == 0) {
          BI_string <- "(BI differences)"
        } else {
          BI_string <- "(BI ratios)"
        }
      }
    }
  }
  
  if (!is.null(lab_list)) {
    
    # Impose a minimum range for the 'x' and y' axis values
    # (to avoid "new" warning messages introduced after R-4.2.3)
    if (max_x - min_x < gs.tolerance) {
      # E.g., single adjustment value
      min_x <- min_x - gs.tolerance / 2
      max_x <- max_x + gs.tolerance / 2
    }
    if (max_y - min_y < gs.tolerance) {
      # E.g., identical/repeated adjustment values
      min_y <- min_y - gs.tolerance / 2
      max_y <- max_y + gs.tolerance / 2
    }
    
    # Initialize the plot
    plot(min_x, min_y, type = "n", xlim = c(min_x, max_x), ylim = c(min_y, max_y),
         xlab = "t", ylab = paste("Adjustments", BI_string))
    graphics::title(paste("Benchmarking Adjustments", BI_string))
    
    # Plot the cubic spline with knots
    if (!is.null(SB_splineKnots)) {
      graphics::lines(interpol, type = "l")
      graphics::points(SB_splineKnots$x, SB_splineKnots$y, cex = 1.5)
      if (extraKnot_flag) {
        graphics::points(SB_splineKnots$x[SB_splineKnots$extraKnot == FALSE],
                         SB_splineKnots$y[SB_splineKnots$extraKnot == FALSE],
                         pch = 19, cex = 1.5, col = "green3")
      }
    }
    
    # Plot the stock_benchmarking() adjustments
    if (!is.null(SB_graphTable)) {
      graphics::lines(SB_graphTable$t, SB_graphTable$benchmarkedSubAnnualRatio,
                      type = "l", col = "red", lwd = 2)
      graphics::points(SB_graphTable$t, SB_graphTable$benchmarkedSubAnnualRatio,
                       col = "red")
    }
    
    # Plot the benchmarking() adjustments
    if (!is.null(PB_graphTable)) {
      graphics::lines(PB_graphTable$t, PB_graphTable$benchmarkedSubAnnualRatio,
                      type = "l", col = "blue", lwd = 2)
      graphics::points(PB_graphTable$t, PB_graphTable$benchmarkedSubAnnualRatio,
                       col = "blue")
    }
    
    # Plot the bias line
    if (!is.null(bias)) {
      bias_line <- data.frame(x = seq(min_x, max_x),
                              y = rep(bias, max_x - min_x + 1))
      graphics::lines(bias_line, col = "green4", lty = 2)
      lab_list <- c(lab_list, "Bias")
      col_list <- c(col_list, "green4")
      lty_list <- c(lty_list, 2)
      lwd_list <- c(lwd_list, 1)
      pch_list <- c(pch_list, NA)
      pt.cex_list <- c(pt.cex_list, NA)
    }
    
    # Add the legend
    if (!is.null(legendPos)) {
      graphics::legend(x = legendPos,
                       bty = "n",
                       inset = c(0.025, 0.025),
                       cex = 0.8,
                       legend = lab_list,
                       col = col_list,
                       lty = lty_list,
                       lwd = lwd_list,
                       pch = pch_list,
                       pt.cex = pt.cex_list)
    }
  }
  
  invisible(NULL)
}
