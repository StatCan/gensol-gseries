################################################################################
#
# CAREFUL: this script contains translated (French) roxygen2 comments 
#          for other topics/functions further down below
#
################################################################################


#' Générer des graphiques d'étalonnage dans un fichier PDF 
#'
#'
#' @description
#' Créer un fichier PDF (format de papier lettre US en orientation paysage) contenant des graphiques d'étalonnage pour l'ensemble 
#' des séries contenues dans le *data frame* de sortie **graphTable** (argument `graphTable`) de la fonction d'étalonnage 
#' ([benchmarking()] ou [stock_benchmarking()]) spécifiée. Quatre types de graphiques d'étalonnage peuvent être générés pour chaque 
#' série :
#' - **Échelle originale** (argument `ori_plot_flag`) - graphique superposé des composantes :
#'   - Série indicatrice
#'   - Moyennes de la série indicatrice
#'   - Série indicatrice corrigée pour le biais (lorsque \eqn{\rho < 1})
#'   - Série étalonnée
#'   - Moyennes des étalons
#' - **Échelle d'ajustement** (argument `adj_plot_flag`) - graphique superposé des composantes :
#'   - Ajustements d'étalonnage
#'   - Moyennes des ajustements d'étalonnage
#'   - Ligne du biais (lorsque \eqn{\rho < 1})
#' - **Taux de croissance** (argument `GR_plot_flag`) - diagramme à barres des taux de croissance des séries indicatrice et 
#' étalonnée.
#' - **Tableau des taux de croissance** (argument `GR_table_flag`) - tableau des taux de croissance des séries indicatrice et 
#' étalonnée.
#'
#' Ces graphiques peuvent être utiles pour évaluer la qualité des résultats de l'étalonnage. N'importe lequel des quatre types de 
#' graphiques d'étalonnage peut être activé ou désactivé à l'aide du drapeau (*flag*) correspondant. Les trois premiers types graphiques 
#' sont générés par défaut alors que le quatrième (le tableau des taux de croissance) ne l'est pas. 
#'
#'
#' @param graphTable (obligatoire)
#' 
#' *Data frame*, ou objet compatible, correspondant au *data frame* de sortie **graphTable** de la fonction d'étalonnage.
#'
#' @param pdf_file (obligatoire)
#'
#' Nom (et chemin) du fichier PDF qui contiendra les graphiques d'étalonnage. Le nom doit inclure l'extension de fichier 
#' « .pdf ». Le fichier PDF sera créé dans le répertoire de travail de la session R (tel que renvoyé par `getwd()`) si aucun 
#' chemin n'est spécifié. La sécification de `NULL` annulerait la création d'un fichier PDF.
#'
#' @param ori_plot_flag,adj_plot_flag,GR_plot_flag,GR_table_flag (optionnels)
#'
#' Arguments logiques (*logical*) indiquant si le type de graphique d'étalonnage correspondant doit être généré ou non. Les trois 
#' premiers types de graphiques sont générés par défaut alors que le quatrième (le tableau des taux de croissance) ne l'est pas.
#'
#' **Les valeurs par défaut** sont `ori_plot_flag = TRUE`, `adj_plot_flag = TRUE`, `GR_plot_flag = TRUE` et 
#' `GR_table_flag = FALSE`.
#'
#' @param add_bookmarks
#'
#' Argument logique (*logical*) indiquant si des signets doivent être ajoutés au fichier PDF. Voir **Signets** dans la section
#' **Détails** pour plus d'informations.
#'
#' **La valeur par défaut** est `add_bookmarks = TRUE`.
#'
#'
#' @details
#' Liste des variables du *data frame* **graphTable** (argument `graphTable`) correspondant à chaque élément des quatre 
#' types de graphiques d'étalonnage:
#' - Échelle originale (argument `ori_plot_flag`)
#'   - `subAnnual` pour la ligne *Indicator Series*
#'   - `avgSubAnnual` pour les segments *Avg. Indicator Series*
#'   - `subAnnualCorrected` pour la ligne *Bias Corr. Indicator Series* (lorsque \eqn{\rho < 1})
#'   - `benchmarked` pour la ligne *Benchmarked Series*
#'   - `avgBenchmark` pour les segments *Average Benchmark*
#' - Échelle d'ajustement (argument `adj_plot_flag`)
#'   - `benchmarkedSubAnnualRatio` pour la ligne *BI Ratios (Benchmarked Series / Indicator Series)* \eqn{^{(*)}}{(*)}
#'   - `avgBenchmarkSubAnnualRatio` pour les segments *Average BI Ratios* \eqn{^{(*)}}{(*)}
#'   - `bias` pour la ligne *Bias* (lorsque \eqn{\rho < 1})
#' - Taux de croissance (argument `GR_plot_flag`)
#'   - `growthRateSubAnnual` pour les barres *Growth R. in Indicator Series* \eqn{^{(*)}}{(*)}
#'   - `growthRateBenchmarked` pour les barres *Growth R. in Benchmarked Series* \eqn{^{(*)}}{(*)}
#' - Tableau des taux de croissance (argument `GR_table_flag`)
#'   - `year` pour la colonne *Year*
#'   - `period` pour la colonne *Period*
#'   - `subAnnual` pour la colonne *Indicator Series*
#'   - `benchmarked` pour la colonne *Benchmarked Series*
#'   - `growthRateSubAnnual` pour la colonne *Growth Rate in Indicator Series* \eqn{^{(*)}}{(*)}
#'   - `growthRateBenchmarked` pour la colonne *Growth Rate in Benchmarked Series* \eqn{^{(*)}}{(*)}
#' 
#' \eqn{^{(*)}}{(*)} Les _ratios étalons/indicateurs_ (« BI ratios ») et les _taux de croissance_ (« growth rates ») correspondent 
#' en réalité à des _différences_ lorsque \eqn{\lambda = 0} (étalonnage additif).
#'
#' La fonction utilise les colonnes supplémentaires du *data frame* `graphTable` (colonnes non listées dans la section 
#' **Valeur de retour** de [benchmarking()] et [stock_benchmarking()]), le cas échéant, pour construire les groupes-BY. Voir la 
#' section **Étalonnage de plusieurs séries** de [benchmarking()] pour plus de détails.  
#'
#' ## Performance
#' Les deux types de graphiques de taux de croissance, c'est-à-dire le diagramme à barres (`GR_plot_flag`) et le tableau (`GR_table_flag`), 
#' nécessitent souvent la génération de plusieurs pages dans le fichier PDF, en particulier pour les longues séries mensuelles avec 
#' plusieurs années de données. Cette création de pages supplémentaires ralentit l'exécution de [plot_graphTable()]. C'est pourquoi 
#' seul le diagramme à barres est généré par défaut (`GR_plot_flag = TRUE` et `GR_table_flag = FALSE`). La désactivation des deux 
#' types de graphiques de taux de croissance (`GR_plot_flag = FALSE` et `GR_table_flag = FALSE`) ou la réduction de la taille du 
#' *data frame* d'entrée `graphTable` pour les séries très longues (ex., en ne gardant que les années récentes) pourrait ainsi améliorer 
#' le temps d'exécution. Notez également que l'impact de l'étalonnage sur les taux de croissance peut être déduit du graphique dans 
#' l'échelle d'ajustement (`adj_plot_flag`) en examinant l'ampleur du mouvement vertical (vers le bas ou vers le haut) des ajustements 
#' d'étalonnage entre deux périodes adjacentes : plus le mouvement vertical est important, plus l'impact sur le taux de croissance 
#' correspondant est important. Le temps d'exécution de [plot_graphTable()] pourrait donc être reduit, si nécessaire, en ne générant 
#' que les deux premiers types de graphiques et en se concentrant sur le graphique des d'ajustements d'étalonnage pour évaluer la 
#' préservation du mouvement d'une période à l'autre, c'est-à-dire l'impact de l'étalonnage sur les taux de croissance initiaux.
#' 
#' ## Thèmes de ggplot2
#' Les graphiques sont générés avec la librairie ggplot2 qui est livrée avec un ensemble pratique de 
#' [thèmes complets](https://ggplot2.tidyverse.org/reference/ggtheme.html) pour l'aspect général des graphiques (avec `theme_grey()` 
#' comme thème par défaut). Utilisez la fonction `theme_set()` pour changer le thème appliqué aux graphiques générés par [plot_graphTable()] 
#' (voir les **Exemples**).
#' 
#' ## Signets
#' Des signets sont ajoutés au fichier PDF avec `xmpdf::set_bookmarks()` lorsque l'argument \ifelse{latex}{\code{add _bookmarks = TRUE}}{
#' \code{add_bookmarks = TRUE}} (par défault), ce qui nécessite un outil tiers tel que [Ghostscript](https://www.ghostscript.com/) ou 
#' [PDFtk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/). Voir la section **Installation** dans 
#' `vignette("xmpdf", package = "xmpdf")` pour plus de détails. 
#' 
#' **Important** : les signets seront ajoutés avec succès au fichier PDF **si et seulement si** \ifelse{latex}{\code{xmpdf::supports 
#' _set_bookmarks()}}{\code{xmpdf::supports_set_bookmarks()}} renvoie `TRUE` **et** l'exécution de `xmpdf::set_bookmarks()` est réussie. 
#' Si Ghostscript est installé sur votre machine mais que `xmpdf::supports_set_bookmarks()` renvoie toujours `FALSE`, essayez de 
#' spécifier le chemin de l'exécutable Ghostscript dans la variable d'environnement `R_GSCMD` (ex., \ifelse{latex}{
#' \code{Sys.setenv(R_GSCMD = "C:/Program Files/.../bin/gswin64c .exe")}}{
#' \code{Sys.setenv(R_GSCMD = "C:/Program Files/.../bin/gswin64c.exe")}} avec Windows). D'un autre côté, si 
#' `xmpdf::supports_set_bookmarks()}` renvoie `TRUE` mais que vous rencontrez des problèmes (insolubles) avec `xmpdf::set_bookmarks()` 
#' (ex., erreur liée à l'exécutable Ghostscript), la création de signets peut être désactivée en spécifiant `add_bookmarks = FALSE`.
#'
#' @returns
#' En plus de créer un fichier PDF contenant les graphiques d'étalonnage (sauf si `pdf_file = NULL`), cette fonction renvoie également 
#' de manière invisible une liste comprenant les éléments suivants : 
#' - **pdf_name** : Chaîne de caractères (vecteur de type caractère de longueur un) qui contient le nom complet et le chemin du fichier 
#' PDF s'il a été créé avec succès et `invisible(NA_character_)` dans le cas contraire ou si `pdf_file = NULL` a été spécifié.
#' - **graph_list** : Liste des graphiques d'étalonnage générés (une par série) comprenant les éléments suivants :
#'   - **name** : Chaîne de caractères décrivant la série (concorde avec le nom du signet dans le fichier PDF).
#'   - **page** : Entier représentant le numéro de séquence du premier graphique de la série dans la séquence complète des graphiques 
#'   pour toutes les séries (concorde avec le numéro de page dans le fichier PDF).
#'   - **ggplot_list** : Liste d'objets ggplot (une par graphique ou par page dans le fichier PDF) correspondant aux graphiques 
#'   d'étalonnage générés pour la série. Voir la section **Valeur** dans [bench_graphs] pour plus de détails.
#'
#' Notez que les objets ggplot renvoyés par la fonction peuvent être affichés _manuellement_ avec [print()], auquel cas certaines mises 
#' à jour des paramètres par défaut du thème ggplot2 sont recommandées afin de produire des graphiques ayant une apparence similaire à 
#' ceux générés dans le fichier PDF (voir la section **Valeur** dans [bench_graphs] pour les détails). Gardez également à l'esprit que 
#' ces graphiques sont optimisés pour un format de papier Lettre US en orientation paysage, c.-à-d., 11po de large (27.9cm, 1056px avec 
#' 96 PPP) et 8.5po de haut (21.6cm, 816px avec 96 PPP).
#'
#'
#' @seealso [bench_graphs] [plot_benchAdj()] [benchmarking()] [stock_benchmarking()]
#'
#'
#' @example misc/function_examples/plot_graphTable-ex.R
#'
#'
#' @export
plot_graphTable <- function(graphTable,
                            pdf_file,
                            ori_plot_flag = TRUE,
                            adj_plot_flag = TRUE,
                            GR_plot_flag = TRUE,
                            GR_table_flag = FALSE,
                            add_bookmarks = TRUE) {
  
  
  # Initialize the object to be returned by the function via `on.exit()`
  out_list <- list(pdf_name = NA_character_,
                   graph_list = NULL)
  on.exit(return(invisible(out_list)))
  
  # Turn off debugging/traceback generated by calls to the stop() function inside internal functions
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  # Display warnings immediately (equivalent of `warning(..., immediate. = TRUE)` for warning messages
  # not written/generated by you directly)
  ini_warn_opt <- getOption("warn")
  on.exit(options(warn = ini_warn_opt), add = TRUE)
  options(warn = 1)
  
  
  # Validation
  df_name <- deparse1(substitute(graphTable))
  tmp <- nchar(df_name)
  if (tmp == 0) {
    stop("Argument 'graphTable' is mandatory (it must be specified).\n\n", call. = FALSE)
  } else if (tmp >= 60) {
    df_name <- paste0(substr(df_name, 1, 55), "<...>")
  }
  if (grepl("structure(", df_name, fixed = TRUE)) {
    df_name <- "<argument 'graphTable'>"
  }
  graphTable <- graphTable
  if (!is.data.frame(graphTable)) {
    stop("Argument 'graphTable' is not a 'data.frame' object.\n\n", call. = FALSE)
  }
  graphTable <- as.data.frame(graphTable)
  ori_plot_flag <- gs.validate_arg_logi(ori_plot_flag)
  adj_plot_flag <- gs.validate_arg_logi(adj_plot_flag)
  GR_plot_flag <- gs.validate_arg_logi(GR_plot_flag)
  GR_table_flag <- gs.validate_arg_logi(GR_table_flag)
  add_bookmarks <- gs.validate_arg_logi(add_bookmarks)
  
  
  # Set mandatory argument `pdf_file` to NULL if it's not specified
  # (do not create a PDF file)
  if (nchar(deparse1(substitute(pdf_file))) == 0) {
    pdf_file <- NULL
  }
  
  
  
  # Validate the graph table contents
  df_cols <- names(graphTable)
  mandatory_cols <- c("varSeries",
                      "m",
                      "year",
                      "period",
                      "constant",
                      "rho",
                      "lambda",
                      "bias",
                      "periodicity",
                      "subAnnual",
                      "benchmarked",
                      "avgBenchmark",
                      "avgSubAnnual",
                      "subAnnualCorrected",
                      "benchmarkedSubAnnualRatio",
                      "avgBenchmarkSubAnnualRatio",
                      "growthRateSubAnnual",
                      "growthRateBenchmarked")
  missing_cols <- setdiff(mandatory_cols, df_cols)
  if (length(missing_cols) > 0) {
    stop("The following columns are missing from the 'graphTable' data frame (", df_name, "): ",
         paste0("\n  ", missing_cols, collapse = ""), "\n\n", call. = FALSE)
  }
  
  # Get the by-group columns ("extras" columns)
  by_cols <- setdiff(df_cols, 
                     c("varSeries",
                       "varBenchmarks",
                       "altSeries",
                       "altSeriesValue",
                       "altbenchmarks",
                       "altBenchmarksValue",
                       "t",
                       "m",
                       "year",
                       "period",
                       "constant",
                       "rho",
                       "lambda",
                       "bias",
                       "periodicity",
                       "date",
                       "subAnnual",
                       "benchmarked",
                       "avgBenchmark",
                       "avgSubAnnual",
                       "subAnnualCorrected",
                       "benchmarkedSubAnnualRatio",
                       "avgBenchmarkSubAnnualRatio",
                       "growthRateSubAnnual",
                       "growthRateBenchmarked"))
  
  # Determine the set of series to plot (combination of by-group column values plus column "varSeries" values)
  ser_list_cols <- c(by_cols, "varSeries")
  ser_list_df <- unique(graphTable[ser_list_cols])
  n_ser <- nrow(ser_list_df)
  
  
  if (n_ser == 0) {
    warning("Nothing to plot!\n", call. = FALSE, immediate. = TRUE)
  } else {
    
    if (is.null(pdf_file)) {
      display_flag <- FALSE
    } else {
      
      # Create the temporary (local) PDF file (landscape letter size format with 1 inch borders)
      tmp_pdf <- tempfile(fileext = ".pdf")
      grDevices::pdf(tmp_pdf, onefile = TRUE, width = 11, height = 8.5, encoding = "CP1250")
      # NOTE: encoding CP1250 is used to prevent a warning with the default encoding on Unix-like environments  
      #       (e.g., StatCan GitLab pipeline's Linux Unbuntu) regarding the replacement of characters "..." 
      #       (e.g., long `graphTable` data frame name) with the 'Horizontal Ellipsis' unicode character ("\u2026").
      if (grDevices::dev.cur() == 1) {
        warning("PDF file not created (`grDevices::pdf()` failed)!\n", call. = FALSE, immediate. = TRUE)
        display_flag <- FALSE
      } else {
        display_flag <- TRUE
      }
    }
    
    
    # Display a "starting" message
    message("\nGenerating the benchmarking graphics. Please be patient...\n")
    
    # ggplot2 initialization
    pt_sz <- 2
    ini_theme <- ggplot2::theme_get()
    intialize_theme()
    on.exit(ggplot2::theme_set(ini_theme), add = TRUE)
    
    # Initialize the PDF bookmarks data frame
    bookmarks_df <- data.frame(title = rep.int("", n_ser),
                               page = rep.int(NA_integer_, n_ser))
    
    # Assign the plotting function names according to each individual flag
    # (single "if" instead of repeated "ifs" for each series to plot)
    if (ori_plot_flag) {
      ori_plot_func <- ori_plot
    } else {
      ori_plot_func <- gs.NULL_func
    }
    if (adj_plot_flag) {
      adj_plot_func <- adj_plot
    } else {
      adj_plot_func <- gs.NULL_func
    }
    if (GR_plot_flag) {
      GR_plot_func <- GR_plot
    } else {
      GR_plot_func <- gs.NULL_func
    }
    if (GR_table_flag) {
      GR_table_func <- GR_table
    } else {
      GR_table_func <- gs.NULL_func
    }
    
    
    # Build the plot subtitles and PDF bookmark labels
    plot_subtitle <- rep.int(paste0("Graphics Table <strong>", mask_underscore(df_name), "</strong>"), n_ser)
    
    # Remove unnecessary columns (those with a single value for all rows of the graphTable data frame, if any)
    ser_list_cols <- ser_list_cols[lapply(lapply(ser_list_df, unique), length) > 1]
    if (length(ser_list_cols) == 0) {
      bookmarks_df$title <- rep.int("<Single Series>", n_ser)
      by_cols <- character(0L)
    } else {
      
      # "varSeries" column info
      if ("varSeries" %in% ser_list_cols) {
        bookmarks_df$title <- ser_list_df[["varSeries"]]
        plot_subtitle <- paste0(plot_subtitle, " - Variable <strong>", mask_underscore(bookmarks_df$title), "</strong>")
        label_sep <- " - "
      } else {
        label_sep <- ""
      }
      
      # By-group columns info
      by_cols <- setdiff(ser_list_cols, "varSeries")
      if (length(by_cols) > 0) {
        if (length(by_cols) == 1) {
          byGrp_label <- as.character(ser_list_df[[by_cols]])
        } else {
          # `sapply()` is safe: it always return a character vector (`by_cols` is a vector of minimum length 2)
          byGrp_label <- apply(sapply(by_cols, function(x) paste0(x, "=", ser_list_df[[x]])),
                               1, paste0, collapse = " & ")
        }
        bookmarks_df$title <- paste0(bookmarks_df$title, label_sep, byGrp_label)
        plot_subtitle <- paste0(plot_subtitle, " - BY-Group <strong>", mask_underscore(byGrp_label), "</strong>")
      }
    }
    
    
    # Reduce the data frame to essential columns 
    graphTable <- graphTable[c(by_cols, mandatory_cols)]
    
    
    # Process each series
    
    pdf_page <- 1
    for (ii in 1:n_ser) {
      
      # Set the PDF bookmark page
      bookmarks_df$page[ii] <- pdf_page
      
      # Initialize `graph_list` objects 
      out_list$graph_list <- c(out_list$graph_list, 
                               list(list(name = bookmarks_df$title[ii],
                                         page = bookmarks_df$page[ii],
                                         ggplot_list = NULL)))
      
      # Extract the relevant graphTable rows
      plot_df <- merge(ser_list_df[ii, ser_list_cols, drop = FALSE], 
                       graphTable, 
                       by = ser_list_cols)
      plot_df <- plot_df[order(plot_df$year, plot_df$period), ]
      
      # Extract the benchmarking parms
      parms <- extract_parms(plot_df)
      
      
      # Generate the plots
      
      subtitle_str <- paste0(plot_subtitle[ii], "<br>(", parms$parms_str, ")")
      
      tmp_list <- ori_plot_func(graphTable = plot_df,
                                subtitle_str = subtitle_str,
                                mth_gap = parms$mth_gap,
                                points_set = parms$ori_plot_set,
                                pt_sz = pt_sz,
                                display_ggplot = display_flag,
                                .setup = FALSE)
      out_list$graph_list[[ii]]$ggplot_list <- c(out_list$graph_list[[ii]]$ggplot_list, tmp_list)
      pdf_page <- pdf_page + length(tmp_list)
      
      tmp_list <- adj_plot_func(graphTable = plot_df,
                                subtitle_str = subtitle_str,
                                mth_gap = parms$mth_gap,
                                full_set = parms$adj_plot_set,
                                pt_sz = pt_sz,
                                display_ggplot = display_flag,
                                .setup = FALSE)
      out_list$graph_list[[ii]]$ggplot_list <- c(out_list$graph_list[[ii]]$ggplot_list, tmp_list)
      pdf_page <- pdf_page + length(tmp_list)
      
      tmp_list <- GR_plot_func(graphTable = plot_df,
                               subtitle_str = subtitle_str,
                               factor = parms$GR_factor,
                               type_chars = parms$GR_type_chars,
                               periodicity = parms$periodicity,
                               display_ggplot = display_flag,
                               .setup = FALSE)
      out_list$graph_list[[ii]]$ggplot_list <- c(out_list$graph_list[[ii]]$ggplot_list, tmp_list)
      pdf_page <- pdf_page + length(tmp_list)
      
      tmp_list <- GR_table_func(graphTable = plot_df,
                                subtitle_str = subtitle_str,
                                factor = parms$GR_factor,
                                type_chars = parms$GR_type_chars,
                                display_ggplot = display_flag,
                                .setup = FALSE)
      out_list$graph_list[[ii]]$ggplot_list <- c(out_list$graph_list[[ii]]$ggplot_list, tmp_list)
      pdf_page <- pdf_page + length(tmp_list)
      
    }
    
    
    if (display_flag) {
      
      # Close the temporary PDF file and add bookmarks
      grDevices::dev.off()
      if (add_bookmarks) {
        if (xmpdf::supports_set_bookmarks()) {
          tmp_pdf2 <- try(xmpdf::set_bookmarks(bookmarks_df, tmp_pdf, tempfile(fileext = ".pdf")))
          if (exists("tmp_pdf2") && file.exists(tmp_pdf2)) {
            unlink(tmp_pdf)
            tmp_pdf <- tmp_pdf2
            bookmark_msg_flag <- FALSE
          } else {
            bookmark_msg_flag <- TRUE
          }
        } else {
          bookmark_msg_flag <- TRUE
        }
      } else {
        bookmark_msg_flag <- FALSE
      }
      
      # Create the final (remote) PDF file
      out_pdf <- as.character((unlist(pdf_file))[1])
      if (length(out_pdf) > 0 && !is.na(out_pdf)) {
        len <- nchar(out_pdf)
        if (toupper(substr(out_pdf, len - 3, len)) != ".PDF") {
          out_pdf <- paste0(out_pdf, ".pdf")
        }
        # NOTE: moving a file with `file.copy()` + `unlink()` is safer than with `file.rename()` 
        #       (see section "Warning" in `help(file.rename)`)
        if (file.copy(from = tmp_pdf, to = out_pdf, overwrite = TRUE)) {
          unlink(tmp_pdf)
        } else {
          # `file.copy()` failed, most likely due to a "file locking issue"
          message("")
          out_pdf <- tmp_pdf
        }
      } else {
        warning("Invalid PDF file specification (argument 'pdf_file'). A temporary PDF file will be used instead.\n", 
                call. = FALSE, immediate. = TRUE)
        out_pdf <- tmp_pdf
      }
      
      # Completion message
      out_list$pdf_name <- utils::fileSnapshot(out_pdf)$path
      message("Benchmarking graphics generated for ", format(n_ser), " series in the following PDF file:\n  ",
              normalizePath(out_list$pdf_name), "\n")
      if (bookmark_msg_flag) {
        message("Bookmarks could not be added to the PDF file (see section \"Bookmarks\" in `help(plot_graphTable)`).\n")
      }
      
    } else {
      message("Benchmarking graphics generated for ", format(n_ser), " series.\n")
    }
  }
  
  # Output object returned via function `on.exit()`
}




#' Générer un graphique d'étalonnage
#' 
#' @name bench_graphs
#'
#' @description
#' Fonctions utilisées à l'interne par [plot_graphTable()] pour générer les graphiques d'étalonnage dans un fichier PDF :
#' - [ori_plot()]: Échelle originale (argument `ori_plot_flag = TRUE` de [plot_graphTable()])
#' - [adj_plot()]: Échelle d'ajustement (argument `adj_plot_flag = TRUE` de [plot_graphTable()])
#' - [GR_plot()]: Taux de croissance (argument `GR_plot_flag = TRUE` de [plot_graphTable()])
#' - [GR_table()]: Tableau des taux de croissance (argument `GR_table_flag = TRUE` de [plot_graphTable()])
#' 
#' Lorsque ces fonctions sont appelées directement, le *data frame* **graphTable** (argument `graphTable`) ne devrait 
#' contenir qu'une **série unique** et le graphique est généré dans le périphérique de graphiques courant (actif).
#' 
#' 
#' @inheritParams plot_graphTable
#' 
#' @param title_str,subtitle_str (optionnel)
#' 
#' Chaînes de caractères spécifiant les titre et sous-titre du graphique. `subtitle_str` est construit automatiquement à 
#' partir du contenu du *data frame* `graphTable` lorsque `NULL` et contient le nom *data frame* `graphTable` sur la 2<sup>ème</sup> 
#' ligne et les paramètres d'étalonnage sur la 3<sup>ème</sup> ligne. La spécification de chaînes vides (`""`) supprimerait 
#' les titres. L'utilisation de syntaxe Markdown et HTML simple est permise (ex., pour l'affichage de caractères gras, italiques 
#' ou en couleur) grâce à l'utilisation à l'interne de la librairie [ggtext][ggtext::ggtext] (voir `help(package = "ggtext")`).
#' 
#' **Les valeurs par défaut** sont `subtitle_str = NULL` et un titre propre à chaque fonction pour `title_str` 
#' (voir **Utilisation**).
#' 
#' @param mth_gap (optionnel)
#' 
#' Nombre de mois entre deux périodes consécutives (ex., 1 pour des données mensuelles, 3 pour des données trimestrielles, 
#' etc.). Basé sur le contenu du *data frame* `graphTable` lorsque `NULL` (calculé comme `12 / graphTable$periodicity[1]`).
#' 
#' **La valeur par défaut** est `mth_gap = NULL`.
#' 
#' @param points_set,full_set (optionnel)
#' 
#' Vecteur de chaînes de caractères des éléments (variables du *data frame* `graphTable`) à inclure dans le graphique.
#' Automatiquement construit lorsque `NULL`. Voir [plot_graphTable()] pour la liste des variables utilisées (par défaut) 
#' par chaque type de graphique.
#' 
#' **Les valeurs par défaut** sont `points_set = NULL` et `full_set = NULL`.
#' 
#' @param pt_sz (optionnel)
#' 
#' Taille du pictogramme (symbole) des points de données pour ggplot2.
#' 
#' **La valeur par défaut** est `pt_sz = 2`.
#' 
#' @param factor,type_chars (optionnel)
#' 
#' Facteur de taux de croissance (1 ou 100) et suffixe de l'étiquette des valeurs (« » ou « (%) ») selon le paramètre du 
#' modèle d'ajustement \eqn{\lambda}. Basé sur le contenu du *data frame* `graphTable` lorsque `NULL` (basé sur 
#' `graphTable$lambda[1]`).
#' 
#' **Les valeurs par défaut** sont `factor = NULL` et `type_chars = NULL`.
#' 
#' @param periodicity (optionnel)
#' 
#' Le nombre de périodes dans une année. Basé sur le contenu du *data frame* `graphTable` lorsque `NULL` (défini comme 
#' `graphTable$periodicity[1]`).
#' 
#' **La valeur par défaut** est `periodicity = NULL`.
#'
#' @param display_ggplot (optionnel)
#' 
#' Argument logique (*logical*) indiquant si l'object ggplot doit être affiché dans le périphérique de graphiques courant 
#' (actif).
#'
#' **La valeur par défaut** est `display_ggplot = TRUE`.
#'
#' @param .setup (optionnel)
#' 
#' Argument logique indiquant si les étapes de configuration doivent être exécutées ou non. Doit être `TRUE` lorsque la 
#' fonction est appelée directement (c.-à-d., hors du contexte de [plot_graphTable()]).
#' 
#' **La valeur par défaut** est `.setup = TRUE`.
#'
#'
#' @details
#' Voir [plot_graphTable()] pour une description détaillée des quatre graphiques d'étalonnage associés à ces fonctions 
#' individuelles. Ces graphiques sont optimisés pour un format de papier Lettre US en orientation paysage, c.-à-d., 11po 
#' de large (27.9cm, 1056px avec 96 PPP) et 8.5po de haut (21.6cm, 816px avec 96 PPP). Gardez cela à l'esprit lorsque 
#' vous visualisez ou enregistrez des graphiques générés par des appels à ces fonctions individuelles (c.-à-d., hors du 
#' contexte de [plot_graphTable()]). Notez également que [GR_plot()] et [GR_table()] génèrent souvent plus d'un graphique 
#' (plus d'une *page*), à moins de réduire le nombre de périodes fournies en entrée dans le *data frame* `graphTable` 
#' (ex., en subdivisant le *data frame* par plages d'années civiles). 
#'
#'
#' @returns
#' En plus d'afficher le(s) graphique(s) correspondant(s) dans le périphérique de graphiques actif (sauf si 
#' `display_ggplot = FALSE`), chaque fonction renvoie également de manière invisible une liste contenant les objets ggplot 
#' générés. Notes :
#' - [ori_plot()] et [adj_plot()] génèrent un seul objet ggplot (un seul graphique) alors que [GR_plot()] et [GR_table()] 
#' génèrent souvent plusieurs objets ggplot (plusieurs graphiques).
#' - Les objets ggplot renvoyés peuvent être affichés _manuellement_ avec [print()], auquel cas il est suggéré d'apporter les 
#' mises à jour suivantes au thème ggplot2 (modifications utilisés à l'interne lorsque `display_ggplot = TRUE`) :
#'   ```R
#'   ggplot2::theme_update(
#'     plot.title = ggtext::element_markdown(hjust = 0.5),
#'     plot.subtitle = ggtext::element_markdown(hjust = 0.5),
#'     legend.position = "bottom",
#'     plot.margin = ggplot2::margin(t = 1.5, r = 1.5, b = 1.5, l = 1.5, unit = "cm"))
#'   ```
#'
#'
#' @seealso [plot_graphTable()] [plot_benchAdj()] [benchmarking()] [stock_benchmarking()]
#'
#'
#' @example misc/function_examples/bench_graphs-ex.R
#' 
#' 
#' @importFrom rlang .data


#' @rdname bench_graphs
#' @export
ori_plot <- function(graphTable, 
                     title_str = "Original Scale",
                     subtitle_str = NULL, 
                     mth_gap = NULL, 
                     points_set = NULL,
                     pt_sz = 2,
                     display_ggplot = TRUE,
                     .setup = TRUE) {
  
  
  # Original Scale graph function (called when `ori_plot_flag = TRUE`)
  # Approach:
  #   - create 3 tall (stacked) data frames for plotting with ggplot:
  #       - data points (geom_point) for series values and repeated average values
  #       - lines (geom_line) for series lines only (not average lines)
  #       - segments (geom_segment) for average lines
  #   - generate "by name (series)" geoms for each type of element to plot
  #     (geom_line, geom_segment and geom_point)
  
  
  # Initialize the object to be returned by the function via `on.exit()`
  ggplot_list <- NULL
  on.exit(return(invisible(ggplot_list)))
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  # Set the display function
  if (gs.validate_arg_logi(display_ggplot)) {
    display_func <- print
  } else {
    display_func <- gs.NULL_func
  }
  
  # Setup part (manual call outside on `plot_graphTable()`)
  if (gs.validate_arg_logi(.setup)) {
    
    # Set PDF encoding to CP1250 to avoid warnings on Unix-like environments 
    # (see `plot_graphTable()` comment above)
    ini_pdf_encoding <- grDevices::pdf.options()$encoding
    on.exit(grDevices::pdf.options(encoding = ini_pdf_encoding), add = TRUE)
    grDevices::pdf.options(encoding = "CP1250")
    
    # ggplot2 initialization
    ini_theme <- ggplot2::theme_get()
    intialize_theme()
    on.exit(ggplot2::theme_set(ini_theme), add = TRUE)
    
    # Data frame name string
    df_name <- deparse1(substitute(graphTable))
    if (nchar(df_name) >= 60) {
      df_name <- paste0(substr(df_name, 1, 55), "<...>")
    }
    if (grepl("structure(", df_name, fixed = TRUE)) {
      df_name <- "<argument 'graphTable'>"
    }
    
    # Set the benchmarking parms
    parms <- extract_parms(graphTable)
    if (is.null(subtitle_str)) {
      subtitle_str <- paste0("Graphics Table <strong>", mask_underscore(df_name), "</strong><br>(", parms$parms_str, ")")
    }
    if (is.null(mth_gap)) {
      mth_gap <- parms$mth_gap
    }
    if (is.null(points_set)) {
      points_set <- parms$ori_plot_set
      segments_set <- c("avgSubAnnual", "avgBenchmark")
    } else {
      segments_set <- intersect(c("avgSubAnnual", "avgBenchmark"), points_set)
    }
    
    graphTable <- graphTable[order(graphTable$year, graphTable$period), ]
  } else {
    ini_theme <- NULL
    segments_set <- c("avgSubAnnual", "avgBenchmark")
  }
  lines_set <- setdiff(points_set, segments_set)
  
  # Create the points data frame for geom_point
  points_df <- stack_tsDF(graphTable[!is.na(graphTable[points_set[1]]), c("year", "period", points_set), drop = FALSE])
  points_df <- points_df[!duplicated(points_df), ]
  points_df$series <- factor(points_df$series, levels = points_set, ordered = TRUE)
  points_df$rDate <- as.Date(paste(points_df$year, 1 + (points_df$period - 1) * mth_gap, "1", sep = "-"), "%Y-%m-%d")
  
  # Extract rows corresponding to lines for geom_line
  lines_df <- points_df[points_df$series %in% lines_set, , drop = FALSE]
  
  # Create the segments data frame for geom_segment
  if (length(segments_set) > 0) {
    df_temp <- graphTable[!is.na(graphTable[segments_set[1]]), c("m", "year", "period", segments_set), drop = FALSE]
    m_vec <- unique(df_temp$m)
    M <- length(m_vec)
    df_beg <- data.frame(matrix(NA_real_, nrow = M, ncol = 2 + length(segments_set)))
    df_end <- df_beg
    names(df_beg) <- c("year", "period", segments_set)
    names(df_end) <- c("year_end", "period_end", segments_set)
    for (kk in m_vec) {
      df_beg[kk, ] <- utils::head(df_temp[df_temp$m == m_vec[kk], c("year", "period", segments_set)], n = 1)
      df_end[kk, ] <- utils::tail(df_temp[df_temp$m == m_vec[kk], c("year", "period", segments_set)], n = 1)
    }
    segments_df <- cbind(stack_tsDF(df_beg), stack_tsDF(df_end,
                                                        yr_cName = "year_end",
                                                        per_cName = "period_end",
                                                        val_cName = "value_end")[, -1])
    segments_df$series <- factor(segments_df$series, levels = segments_set, ordered = TRUE)
    segments_df$rDate <- as.Date(paste(segments_df$year, 1 + (segments_df$period - 1) * mth_gap, "1",
                                       sep = "-"), "%Y-%m-%d")
    segments_df$rDate_end <- as.Date(paste(segments_df$year_end, 1 + (segments_df$period_end - 1) * mth_gap, "1",
                                           sep = "-"), "%Y-%m-%d")
  } else {
    segments_df <- data.frame(rDate = numeric(0L),
                              value = numeric(0L),
                              rDate_end = numeric(0L),
                              value_end = numeric(0L),
                              series = character(0L))
  }
  
  labels <-    c("subAnnual"          = "Indicator Series",
                 "avgSubAnnual"       = "Avg. Indicator Series",
                 "subAnnualCorrected" = "Bias Corr. Indicator Series",
                 "benchmarked"        = "Benchmarked Series",
                 "avgBenchmark"       = "Average Benchmark")
  colors <-    c("subAnnual"          = "blue",
                 "avgSubAnnual"       = "blue",
                 "subAnnualCorrected" = "orange",
                 "benchmarked"        = "red",
                 "avgBenchmark"       = "red")
  pt_shapes <- c("subAnnual"          = "plus",
                 "avgSubAnnual"       = "diamond open",
                 "subAnnualCorrected" = "circle open",
                 "benchmarked"        = "asterisk",
                 "avgBenchmark"       = "triangle open")
  pt_sizes <-  c("subAnnual"          = pt_sz,
                 "avgSubAnnual"       = pt_sz,
                 "subAnnualCorrected" = pt_sz + 0.5,
                 "benchmarked"        = pt_sz,
                 "avgBenchmark"       = pt_sz)
  
  original_scale <- ggplot2::ggplot() +
    
    # Series lines
    ggplot2::geom_line(data = lines_df, ggplot2::aes(x = .data$rDate, y = .data$value,
                                                     color = .data$series)) +
    
    # Average lines (segments)
    ggplot2::geom_segment(data = segments_df, ggplot2::aes(x    = .data$rDate,     y    = .data$value,
                                                           xend = .data$rDate_end, yend = .data$value_end,
                                                           color = .data$series)) +
    
    # Data points for series and repeated average values
    ggplot2::geom_point(data = points_df, ggplot2::aes(x = .data$rDate, y = .data$value,
                                                       color = .data$series,
                                                       shape = .data$series,
                                                       size = .data$series)) +
    
    ggplot2::scale_color_manual(name = NULL, values = colors, limits = points_set, labels = labels) +
    ggplot2::scale_shape_manual(name = NULL, values = pt_shapes, limits = points_set, labels = labels) +
    ggplot2::scale_size_manual(name = NULL, values = pt_sizes, limits = points_set, labels = labels) +
    ggplot2::scale_x_date(name = NULL, date_labels = "%Y", breaks = "1 year", minor_breaks = NULL) +
    ggplot2::labs(title = title_str, subtitle = subtitle_str, y = "Original Scale")
  
  ggplot_list <- list(original_scale)
  display_func(original_scale)
  
  # Output object returned via function `on.exit()`
}


#' @rdname bench_graphs
#' @export
adj_plot <- function(graphTable, 
                     title_str = "Adjustment Scale",
                     subtitle_str = NULL, 
                     mth_gap = NULL, 
                     full_set = NULL,
                     pt_sz = 2,
                     display_ggplot = TRUE,
                     .setup = TRUE) {
  
  
  # Adjustment Scale graph function (called when `adj_plot_flag = TRUE`)
  # Approach:
  #   - create 3 tall (stacked) data frames for plotting with ggplot:
  #       - data points (geom_point) for adjustment values and repeated average adj. values
  #         (no bias values)
  #       - lines (geom_line) for adjustment and bias lines (not average adj. lines)
  #       - segments (geom_segment) for average adj. lines
  #   - generate "by name (series)" geoms for each type of element to plot
  #     (geom_line, geom_segment and geom_point)
  
  
  # Initialize the object to be returned by the function via `on.exit()`
  ggplot_list <- NULL
  on.exit(return(invisible(ggplot_list)))
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  # Set the display function
  if (gs.validate_arg_logi(display_ggplot)) {
    display_func <- print
  } else {
    display_func <- gs.NULL_func
  }
  
  # Setup part (manual call outside on `plot_graphTable()`)
  if (gs.validate_arg_logi(.setup)) {
    
    # Set PDF encoding to CP1250 to avoid warnings on Unix-like environments 
    # (see `plot_graphTable()` comment above)
    ini_pdf_encoding <- grDevices::pdf.options()$encoding
    on.exit(grDevices::pdf.options(encoding = ini_pdf_encoding), add = TRUE)
    grDevices::pdf.options(encoding = "CP1250")
    
    # ggplot2 initialization
    ini_theme <- ggplot2::theme_get()
    intialize_theme()
    on.exit(ggplot2::theme_set(ini_theme), add = TRUE)
    
    # Data frame name string
    df_name <- deparse1(substitute(graphTable))
    if (nchar(df_name) >= 60) {
      df_name <- paste0(substr(df_name, 1, 55), "<...>")
    }
    if (grepl("structure(", df_name, fixed = TRUE)) {
      df_name <- "<argument 'graphTable'>"
    }
    
    # Set the benchmarking parms
    parms <- extract_parms(graphTable)
    if (is.null(subtitle_str)) {
      subtitle_str <- paste0("Graphics Table <strong>", mask_underscore(df_name), "</strong><br>(", parms$parms_str, ")")
    }
    if (is.null(mth_gap)) {
      mth_gap <- parms$mth_gap
    }
    if (is.null(full_set)) {
      full_set <- parms$adj_plot_set
      segments_set <- "avgBenchmarkSubAnnualRatio"
    } else {
      segments_set <- intersect("avgBenchmarkSubAnnualRatio", full_set)
    }
    
    graphTable <- graphTable[order(graphTable$year, graphTable$period), ]
  } else {
    ini_theme <- NULL
    segments_set <- "avgBenchmarkSubAnnualRatio"
  }
  lines_set <- setdiff(full_set, segments_set)
  points_set <- setdiff(full_set, "bias")
  
  # Create the values data frame for lines (geom_lines) and points (geom_point)
  temp_set <- intersect(full_set, union(lines_set, points_set))
  values_df <- stack_tsDF(graphTable[!is.na(graphTable[lines_set[1]]), c("year", "period", temp_set), drop = FALSE])
  values_df <- values_df[!duplicated(values_df), ]
  values_df$series <- factor(values_df$series, levels = temp_set, ordered = TRUE)
  values_df$rDate <- as.Date(paste(values_df$year, 1 + (values_df$period - 1) * mth_gap, "1", sep = "-"), "%Y-%m-%d")
  
  # Extract rows corresponding to lines for geom_line
  lines_df <- values_df[values_df$series %in% lines_set, , drop = FALSE]
  
  # Extract rows corresponding to points for geom_point
  points_df <- values_df[values_df$series %in% points_set, , drop = FALSE]
  
  # Create the segments data frame for geom_segment
  if (length(segments_set) > 0) {
    df_temp <- graphTable[!is.na(graphTable[segments_set[1]]), c("m", "year", "period", segments_set), drop = FALSE]
    m_vec <- unique(df_temp$m)
    M <- length(m_vec)
    df_beg <- data.frame(matrix(NA_real_, nrow = M, ncol = 2 + length(segments_set)))
    df_end <- df_beg
    names(df_beg) <- c("year", "period", segments_set)
    names(df_end) <- c("year_end", "period_end", segments_set)
    for (kk in m_vec) {
      df_beg[kk, ] <- utils::head(df_temp[df_temp$m == m_vec[kk], c("year", "period", segments_set)], n = 1)
      df_end[kk, ] <- utils::tail(df_temp[df_temp$m == m_vec[kk], c("year", "period", segments_set)], n = 1)
    }
    segments_df <- cbind(stack_tsDF(df_beg), stack_tsDF(df_end,
                                                        yr_cName = "year_end",
                                                        per_cName = "period_end",
                                                        val_cName = "value_end")[, -1])
    segments_df$series <- factor(segments_df$series, levels = segments_set, ordered = TRUE)
    segments_df$rDate <- as.Date(paste(segments_df$year, 1 + (segments_df$period - 1) * mth_gap, "1",
                                       sep = "-"), "%Y-%m-%d")
    segments_df$rDate_end <- as.Date(paste(segments_df$year_end, 1 + (segments_df$period_end - 1) * mth_gap, "1",
                                           sep = "-"), "%Y-%m-%d")
  } else {
    segments_df <- data.frame(rDate = numeric(0L),
                              value = numeric(0L),
                              rDate_end = numeric(0L),
                              value_end = numeric(0L),
                              series = character(0L))
  }
  
  labels <-    c("benchmarkedSubAnnualRatio"  = "BI Ratios (Benchmarked Series / Indicator Series)",
                 "avgBenchmarkSubAnnualRatio" = "Avgerage BI Ratios",
                 "bias"                       = "Bias")
  colors <-    c("benchmarkedSubAnnualRatio"  = "blue",
                 "avgBenchmarkSubAnnualRatio" = "black",
                 "bias"                       = "green4")
  ln_types <-  c("benchmarkedSubAnnualRatio"  = "solid",
                 "avgBenchmarkSubAnnualRatio" = "solid",
                 "bias"                       = "longdash")
  pt_shapes <- c("benchmarkedSubAnnualRatio"  = "plus",
                 "avgBenchmarkSubAnnualRatio" = "triangle open",
                 "bias"                       = "")
  pt_sizes  <- c("benchmarkedSubAnnualRatio"  = pt_sz,
                 "avgBenchmarkSubAnnualRatio" = pt_sz,
                 "bias"                       = 0)
  
  adjustment_scale <- ggplot2::ggplot() +
    
    # Adjustment and bias lines
    ggplot2::geom_line(data = lines_df, ggplot2::aes(x = .data$rDate, y = .data$value,
                                                     color = .data$series,
                                                     linetype = .data$series)) +
    
    # Average adjustments (segments)
    ggplot2::geom_segment(data = segments_df, ggplot2::aes(x    = .data$rDate,     y    = .data$value,
                                                           xend = .data$rDate_end, yend = .data$value_end,
                                                           color = .data$series,
                                                           linetype = .data$series)) +
    
    # Data points for adjustment values and repeated average adj. values
    ggplot2::geom_point(data = points_df, ggplot2::aes(x = .data$rDate, y = .data$value,
                                                       color = .data$series,
                                                       shape = .data$series,
                                                       size = .data$series)) +
    
    ggplot2::scale_color_manual(name = NULL, values = colors, limits = full_set, labels = labels) +
    ggplot2::scale_linetype_manual(name = NULL, values = ln_types, limits = full_set, labels = labels) +
    ggplot2::scale_shape_manual(name = NULL, values = pt_shapes, limits = full_set, labels = labels) +
    ggplot2::scale_size_manual(name = NULL, values = pt_sizes, limits = full_set, labels = labels) +
    ggplot2::scale_x_date(name = NULL, date_labels = "%Y", breaks = "1 year", minor_breaks = NULL) +
    ggplot2::labs(title = title_str, subtitle = subtitle_str, y = "Adjustment Scale")
  
  ggplot_list <- list(adjustment_scale)
  display_func(adjustment_scale)
  
  # Output object returned via function `on.exit()`
}


#' @rdname bench_graphs
#' @export
GR_plot <- function(graphTable, 
                    title_str = "Growth Rates",
                    subtitle_str = NULL, 
                    factor = NULL, 
                    type_chars = NULL, 
                    periodicity = NULL,
                    display_ggplot = TRUE,
                    .setup = TRUE) {
  
  
  # Growth Rates graph function (called when `GR_plot_flag = TRUE`)
  # Approach:
  #   - create a tall (stacked) data frame for plotting with ggplot
  #   - generate a "by name (series)" geom_col
  #   - use geom_col position = "dodge" to stick the 2 GR bars (before/after) together
  #   - use facet_wrap to group the GR bars by year
  #   - create separate graphs (PDF pages) depending on the number of years and the periodicity
  #     (4 years per page for quarterly data, 2 years per page for monthly data)
  #   - use the same X and Y scales (1 to # of periods and GR min/max values) to ensure
  #     proper visual comparability across all pages
  #   - complete the last page with "empty years" to ensure the same look for all years
  #     (same yearly graph width across all pages)
  
  
  # Initialize the object to be returned by the function via `on.exit()`
  ggplot_list <- NULL
  on.exit(return(invisible(ggplot_list)))
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  # Set the display function
  if (gs.validate_arg_logi(display_ggplot)) {
    display_func <- print
  } else {
    display_func <- gs.NULL_func
  }
  
  # Setup part (manual call outside on `plot_graphTable()`)
  if (gs.validate_arg_logi(.setup)) {
    
    # Set PDF encoding to CP1250 to avoid warnings on Unix-like environments 
    # (see `plot_graphTable()` comment above)
    ini_pdf_encoding <- grDevices::pdf.options()$encoding
    on.exit(grDevices::pdf.options(encoding = ini_pdf_encoding), add = TRUE)
    grDevices::pdf.options(encoding = "CP1250")
    
    # ggplot2 initialization
    ini_theme <- ggplot2::theme_get()
    intialize_theme()
    on.exit(ggplot2::theme_set(ini_theme), add = TRUE)
    
    # Data frame name string
    df_name <- deparse1(substitute(graphTable))
    if (nchar(df_name) >= 60) {
      df_name <- paste0(substr(df_name, 1, 55), "<...>")
    }
    if (grepl("structure(", df_name, fixed = TRUE)) {
      df_name <- "<argument 'graphTable'>"
    }
    
    # Set the benchmarking parms
    parms <- extract_parms(graphTable)
    if (is.null(subtitle_str)) {
      subtitle_str <- paste0("Graphics Table <strong>", mask_underscore(df_name), "</strong><br>(", parms$parms_str, ")")
    }
    if (is.null(factor)) {
      factor <- parms$GR_factor
    }
    if (is.null(type_chars)) {
      type_chars <- parms$GR_type_chars
    }
    if (is.null(periodicity)) {
      periodicity <- parms$periodicity
    }
    
    graphTable <- graphTable[order(graphTable$year, graphTable$period), ]
  } else {
    ini_theme <- NULL
  }
  bars_set <- c("growthRateSubAnnual", "growthRateBenchmarked")
  temp_df <- stack_tsDF(graphTable[!duplicated(graphTable[c("year", "period")]), c("year", "period", bars_set)])
  temp_df$series <- factor(temp_df$series, levels = bars_set, ordered = TRUE)
  temp_df$value <- temp_df$value * factor
  y_lab <- paste("Growth Rates", type_chars)
  
  labels <- c("growthRateSubAnnual"   = "Growth R. in Indicator Series",
              "growthRateBenchmarked" = "Growth R. in Benchmarked Series")
  colors <- c("growthRateSubAnnual"   = "steelblue",
              "growthRateBenchmarked" = "indianred3")
  y_limits <- c(min(temp_df$value, na.rm = TRUE), max(temp_df$value, na.rm = TRUE))
  
  years <- graphTable[!is.na(graphTable[bars_set[1]]), "year"]
  beg_yr <- min(years)
  end_yr <- max(years)
  step <- ceiling(16 / periodicity)
  
  # Template plot object
  p <- ggplot2::ggplot() +
    ggplot2::scale_fill_manual(name = NULL, values = colors, labels = labels) +
    ggplot2::scale_x_discrete(name = NULL, limits = as.character(1:periodicity)) +
    ggplot2::scale_y_continuous(name = y_lab, limits = y_limits) +
    ggplot2::labs(title = title_str, subtitle = subtitle_str)
  
  seq_beg_yr <- seq(beg_yr, end_yr, step)
  for (kk in seq_beg_yr) {
    end <- kk + step - 1
    bars_df <- temp_df[temp_df$year >= kk & temp_df$year <= end, , drop = FALSE]
    
    # Add missing panels (years) at the end when necessary (more than 1 row/page of GR plots
    # and the last row/page is not full/complete)
    if (kk > beg_yr && end_yr < end) {
      n_xtra_yrs <- end - end_yr
      bars_df <- rbind(bars_df, data.frame(year = rep((end_yr + 1):end, each = 2),
                                           period = rep(1, n_xtra_yrs * 2),
                                           series = rep(bars_set, n_xtra_yrs),
                                           value = rep(NA_real_, n_xtra_yrs * 2)))
    }
    
    # Create the plot object from the template
    gRates_plot <- p +
      ggplot2::geom_col(data = bars_df, ggplot2::aes(x = .data$period, y = .data$value,
                                                     fill = .data$series),
                        position = "dodge", na.rm = TRUE) +
      ggplot2::facet_wrap(~year, ncol = step)
    
    ggplot_list <- c(ggplot_list, list(gRates_plot))
    display_func(gRates_plot)
  }
  
  # Output object returned via function `on.exit()`
}


#' @rdname bench_graphs
#' @export
GR_table <- function(graphTable, 
                     title_str = "Growth Rates Table",
                     subtitle_str = NULL, 
                     factor = NULL, 
                     type_chars = NULL,
                     display_ggplot = TRUE,
                     .setup = TRUE) {
  
  
  # Growth Rates table function (called when `GR_table_flag = TRUE`)
  # Approach:
  #   - use ggplot to generate page titles that look the same as the previous pages (plots)
  #   - generate a dummy geom (geom_blank) to define an invisible grid to which is attached the
  #     GR table with a tableGrob object (gridExtra package) in an annotation_custom geom
  #   - use element_blank() in the ggplot theme in order to draw nothing else but the GR table
  #     (invisible grid)
  #   - generate as many plots (PDF pages) as necessary in order to display the entire GR table
  #     (21 periods per page, i.e. 23 rows in total including 2 rows for the table header)
  
  
  # Initialize the object to be returned by the function via `on.exit()`
  ggplot_list <- NULL
  on.exit(return(invisible(ggplot_list)))
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  # Set the display function
  if (gs.validate_arg_logi(display_ggplot)) {
    display_func <- print
  } else {
    display_func <- gs.NULL_func
  }
  
  # Setup part (manual call outside on `plot_graphTable()`)
  if (gs.validate_arg_logi(.setup)) {
    
    # Set PDF encoding to CP1250 to avoid warnings on Unix-like environments 
    # (see `plot_graphTable()` comment above)
    ini_pdf_encoding <- grDevices::pdf.options()$encoding
    on.exit(grDevices::pdf.options(encoding = ini_pdf_encoding), add = TRUE)
    grDevices::pdf.options(encoding = "CP1250")
    
    # ggplot2 initialization
    ini_theme <- ggplot2::theme_get()
    intialize_theme()
    on.exit(ggplot2::theme_set(ini_theme), add = TRUE)
    
    # Data frame name string
    df_name <- deparse1(substitute(graphTable))
    if (nchar(df_name) >= 60) {
      df_name <- paste0(substr(df_name, 1, 55), "<...>")
    }
    if (grepl("structure(", df_name, fixed = TRUE)) {
      df_name <- "<argument 'graphTable'>"
    }
    
    # Set the benchmarking parms
    parms <- extract_parms(graphTable)
    if (is.null(subtitle_str)) {
      subtitle_str <- paste0("Graphics Table <strong>", mask_underscore(df_name), "</strong><br>(", parms$parms_str, ")")
    }
    if (is.null(factor)) {
      factor <- parms$GR_factor
    }
    if (is.null(type_chars)) {
      type_chars <- parms$GR_type_chars
    }
    
    graphTable <- graphTable[order(graphTable$year, graphTable$period), ]
  } else {
    ini_theme <- NULL
  }
  
  # Extract the GR table info
  GR_df <- graphTable[!duplicated(graphTable[c("year", "period")]),
                      c("year", "period", "subAnnual", "benchmarked", "growthRateSubAnnual", "growthRateBenchmarked")]
  row.names(GR_df) <- NULL
  GR_df$growthRateSubAnnual <- GR_df$growthRateSubAnnual * factor
  GR_df$growthRateBenchmarked <- GR_df$growthRateBenchmarked * factor
  names(GR_df) <- c("Year", "Period", "Indicator\nSeries", "Benchmarked\nSeries",
                    paste("Growth Rate in\nIndicator Series", type_chars),
                    paste("Growth Rate in \nBenchmarked Series", type_chars))
  # Apply default formatting with commas (thousands separator) to all columns except "Year" and "Period"
  GR_df <- cbind(GR_df[1:2], format(GR_df[-(1:2)], big.mark = ","))
  
  # 22 or even 23 rows (periods) would actually fit on a page, but 21 rows looks better: same
  # location for the top of the table on all pages (full set of 21 periods or fewer periods)
  max_rows <- 21
  max_y <- max_rows + 2
  grid_df <- data.frame(x = 1, y = 1:max_y)
  n_rows <- nrow(GR_df)
  n_pages <- ceiling(n_rows / max_rows)
  
  # Template plot object
  p <- ggplot2::ggplot(grid_df, ggplot2::aes(x = .data$x, y = .data$y)) +
    ggplot2::geom_blank() +
    ggplot2::labs(title = title_str, subtitle = subtitle_str) +
    ggplot2::theme(legend.position = "none",
                   axis.title = ggplot2::element_blank(),
                   axis.text = ggplot2::element_blank(),
                   axis.ticks = ggplot2::element_blank(),
                   axis.line = ggplot2::element_blank(),
                   panel.background = ggplot2::element_blank(),
                   panel.border = ggplot2::element_blank(),
                   panel.grid = ggplot2::element_blank())
  
  for (kk in 1:n_pages) {
    id_vec <- (1 + (kk - 1) * max_rows):min(n_rows, kk * max_rows)
    
    # Create the plot object from the template
    gRates_table <- p +
      ggplot2::annotation_custom(gridExtra::tableGrob(GR_df[id_vec, , drop = FALSE], rows = NULL), 
                                 ymin = max_rows - length(id_vec) + 1, ymax = max_y) 
    
    ggplot_list <- c(ggplot_list, list(gRates_table))
    display_func(gRates_table)
  }
  
  # Output object returned via function `on.exit()`
}




#' Initialize the ggplot2 theme for the benchmarking graphics
#' @noRd
intialize_theme <- function() {
  
  # IMPORTANT: keep roxygen2 @return tag up to date with modifications made here!
  
  ggplot2::theme_update(
    plot.title = ggtext::element_markdown(hjust = 0.5),
    plot.subtitle = ggtext::element_markdown(hjust = 0.5),
    legend.position = "bottom",
    plot.margin = ggplot2::margin(t = 1.5, r = 1.5, b = 1.5, l = 1.5, unit = "cm"))
  
  invisible(NULL)
}




#' Extract benchmarking parms for the plots 
#' @noRd
extract_parms <- function(graphTable) {
  
  periodicity <- graphTable$periodicity[1]
  lambda <- graphTable$lambda[1]
  rho <- graphTable$rho[1]
  bias <- graphTable$bias[1]
  constant <- graphTable$constant[1]
  
  # Define the subtitle and plot elements
  # (bias-related info not displayed for Denton benchmarking (`rho = 1`))
  if (abs(rho - 1) > gs.tolerance) {
    parms_str <- paste0("Lambda = ", format(lambda), ", Rho = ", format(rho), ", Bias = ", format(bias))
    ori_plot_set <- c("subAnnual", "avgSubAnnual", "subAnnualCorrected", "benchmarked", "avgBenchmark")
    adj_plot_set <- c("benchmarkedSubAnnualRatio", "avgBenchmarkSubAnnualRatio", "bias")
  } else {
    parms_str <- paste0("Lambda = ", format(lambda), ", Rho = ", format(rho))
    ori_plot_set <- c("subAnnual", "avgSubAnnual", "benchmarked", "avgBenchmark")
    adj_plot_set <- c("benchmarkedSubAnnualRatio", "avgBenchmarkSubAnnualRatio")
  }
  if (abs(constant) > gs.tolerance) {
    parms_str <- paste0(parms_str, ", Constant = ", format(constant))
  }
  
  # Growth rates scale factor (100 or 1) and type (percent or not) for the plot labels
  # and table headers according to lambda
  if (lambda == 0) {
    GR_factor <- 1
    GR_type_chars <- ""
  } else {
    GR_factor <- 100
    GR_type_chars <- "(%)"
  }
  
  # Return the list of parms
  list(
    periodicity = periodicity,
    mth_gap = 12 / periodicity,
    ori_plot_set = ori_plot_set,
    adj_plot_set = adj_plot_set,
    parms_str = parms_str,
    GR_factor = GR_factor,
    GR_type_chars = GR_type_chars)
}




#' Mask undersores (_) for Markdown markup (prevent them from triggering italic formatting)
#' @noRd
mask_underscore <- function(str) {
  gsub("_", "\\\\_", str)
}
