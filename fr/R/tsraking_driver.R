#' Fonction d'assistance pour [tsraking()]
#'
#'
#' @description
#' Fonction d'assistance pour [tsraking()] qui détermine de manière pratique l'ensemble des problèmes de ratissage 
#' (« *raking* ») à résoudre et génère à l'interne les appels individuels à [tsraking()]. Cette fonction est particulièrement
#' utile dans le contexte de la préservation des totaux temporels (ex., totaux annuels) où chaque problème de ratissage 
#' individuel implique une seule période pour les groupes temporels incomplets (ex., années incomplètes) ou plusieurs 
#' périodes pour les groupes temporels complets (ex., l'ensemble des périodes d'une année complète).
#' 
#'
#' @usage
#' tsraking_driver(
#'   in_ts,
#'   ...,  # arguments de `tsraking()` excluant `data_df`
#'   temporal_grp_periodicity = 1,
#'   temporal_grp_start = 1
#' )
#'
#' 
#' @param in_ts (obligatoire)
#'
#' Objet de type série chronologique (« ts » ou « mts »), ou objet compatible, qui contient les données des séries 
#' chronologiques à réconcilier. Il s'agit des données d'entrée (solutions initiales) des problèmes de ratissage 
#' (« *raking* »).
#' 
#' @inheritDotParams tsraking -data_df
######
# IMPORTANT: manually replace in the RD file (./fr/man/tsraking_driver.Rd) sentence
#                Arguments passed on to
#            with
#                Arguments transmis à
######
#' 
#' @inheritParams tsbalancing
#' 
#' 
#' @details
#' Cette fonction résout un problème de ratissage avec [tsraking()] par groupe de traitement (voir la section __Groupes 
#' de traitement__ pour plus de détails). L'expression mathématique de ces problèmes de ratissage peut être trouvée dans 
#' la section **Détails** de la documentation de [tsraking()].
#' 
#' Le *data frame* des coefficients d'altérabilité (argument `alterability_df`) spécifié avec [tsraking_driver()] peut soit 
#' contenir :
#' - Un seul enregistrement : les coefficients spécifiés seront utilisés pour toutes les périodes de l'objet d'entrée de 
#' type série chronologique (argument `in_ts`).
#' - Un nombre d'enregistrements égal à `frequency(in_ts)` : les coefficients spécifiés seront utilisés pour le *cycle* 
#' correspondant aux périodes de l'objet d'entrée de type série chronologique (argument `in_ts`). Exemple pour des données 
#' mensuelles : 1<sup>er</sup> enregistrement pour janvier, 2<sup>ème</sup> enregistrement pour février, etc.)
#' - Un nombre d'enregistrements égal à `nrow(in_ts)` : les coefficients spécifiés seront utilisés pour les périodes 
#' correspondantes de l'objet d'entrée de type série chronologique (argument `in_ts`), c.-à-d., 1<sup>er</sup> 
#' enregistrement pour la 1<sup>ère</sup> période, 2<sup>ème</sup> enregistrement pour la 2<sup>ème</sup> période, etc.
#' 
#' Spécifier `quiet = TRUE` supprimera les messages de [tsraking()] (ex., l'en-tête de la fonction) et n'affichera que les 
#' informations essentielles telles que les avertissements, les erreurs et la période (ou l'ensemble des périodes) en cours 
#' de traitement. Nous déconseillons d'*envelopper* l'appel à la fonction [tsraking_driver()] avec [suppressMessages()] pour 
#' supprimer l'affichage des informations relatives à la (aux) période(s) en cours de traitement, car cela rendrait 
#' difficile le dépannage de problèmes de ratissage individuels.
#' 
#' Bien que [tsraking()] puisse être appelée avec `*apply()` pour réconcilier successivement toutes les périodes de l'objet 
#' d'entrée de type série chronologique (argument `in_ts`), l'utilisation de [tsraking_driver()] présente quelques avantages, 
#' notamment :
#' - la préservation des totaux temporels (seul un traitement période par période, sans préservation des totaux temporels, 
#' serait possible avec `*apply()`);
#' - une plus grande flexibilité dans la spécification des coefficients d'altérabilité définis par l'utilisateur (ex., des 
#' valeurs spécifiques aux périodes);
#' - affichage de la période en cours de traitement dans la console, ce qui est utile pour dépanner les problèmes de 
#' ratissage individuels;
#' - amélioration de la gestion des erreurs, c.-à-d., une meilleure gestion des avertissements ou des erreurs s'ils ne se 
#' produisent que pour certains problèmes de ratissage (périodes);
#' - renvoi automatique d'un objet de type « ts » (« mts »).
#'
#' 
#' @inheritSection tsbalancing Groupes de traitement
#'
#'
#' @returns
#' La fonction renvoie un objet de type série chronologique (« ts » ou « mts ») contenant les séries composantes 
#' réconciliées, les totaux de contrôle transversaux réconciliés et d'autres séries spécifiées avec l'argument `id` de 
#' [tsraking()]. Il peut être explicitement converti en un autre type d'objet avec la fonction `as*()` appropriée (ex., 
#' `tsibble::as_tsibble()` le convertirait en tsibble).
#' 
#' Notez qu'un objet `NULL` est renvoyé si une erreur survient avant que le traitement des données ne puisse commencer. 
#' Dans le cas contraire, si l'exécution est suffisamment avancée pour que le traitement des données puisse commencer, 
#' alors un objet incomplet (avec des valeurs `NA`) sera renvoyé en cas d'erreur.
#'
#'
#' @references Statistique Canada (2018). "Chapitre : Sujets avancés", **Théorie et application de la réconciliation 
#' (Code du cours 0437)**, Statistique Canada, Ottawa, Canada.
#'
#'
#' @seealso [tsraking()] [tsbalancing()] [rkMeta_to_blSpecs()] [gs.build_proc_grps()]
#'
#'
#' @example misc/function_examples/tsraking_driver-ex.R
#'
#'
#' @export
tsraking_driver <- function(in_ts,                         # input data as a "ts" ("mts") object
                            ...,                           # `tsraking()` arguments excluding `data_df`
                            temporal_grp_periodicity = 1,  # positive integer (number of periods for temporal group preservation)
                            temporal_grp_start = 1) {      # integer in the [1..`temporal_grp_periodicity`] interval
  
  
  
  
  ### Internal functions ###
  
  
  # Generate the `alterability_df` argument data frame
  gen_alter_arg <- function(per_vec) {
    alter_df[per_vec, , drop = FALSE]
  }
  
  
  
  
  ### Main function ###
  
  # Initialize the object to be returned by the function via `on.exit()`
  out_ts <- NULL
  on.exit(return(out_ts))
  try_error <- FALSE
  try_error_msg <- ""
  warning_flag <- FALSE
  
  # Enforce the default R "error" option (`options(error = NULL)`). E.g. this Turns off traceback
  # generated by calls to the stop() function inside internal functions in R Studio.
  ini_error_opt <- getOption("error")
  on.exit(options(error = ini_error_opt), add = TRUE)
  options(error = NULL)
  
  
  # Argument validation
  
  # Mandatory arguments (without default values)
  if (nchar(deparse1(substitute(in_ts))) == 0) {
    stop("Argument 'in_ts' is mandatory (it must be specified).\n\n", call. = FALSE)
  }
  in_ts <- in_ts
  if (!stats::is.ts(in_ts)) {
    stop("Argument 'in_ts' is not a 'ts' object.\n\n", call. = FALSE)
  }
  in_ts <- stats::as.ts(in_ts)
  ts_freq <- stats::frequency(in_ts)
  periods <- gs.time2str(in_ts)
  
  # Optional arguments (with default values)
  tmp <- (unlist(temporal_grp_periodicity))[1]
  if (!identical(temporal_grp_periodicity, tmp) || is.null(tmp) || !is.finite(tmp) ||
      is.finite(tmp) && (tmp <= 0 || tmp != as.integer(tmp))) {
    stop("Argument 'temporal_grp_periodicity' must be a positive integer.\n\n", call. = FALSE)
  }
  temporal_grp_periodicity <- as.integer(temporal_grp_periodicity)
  if (temporal_grp_periodicity > 1) {
    tmp <- (unlist(temporal_grp_start))[1]
    if (!identical(temporal_grp_start, tmp) || is.null(tmp) || !is.finite(tmp) ||
        is.finite(tmp) && (tmp <= 0 || tmp > temporal_grp_periodicity || tmp != as.integer(tmp))) {
      stop("Argument 'temporal_grp_start' must be an integer in the [1..", temporal_grp_periodicity, "] interval.\n\n",
           call. = FALSE)
    }
    temporal_grp_start <- as.integer(temporal_grp_start)
  }
  
  
  # Build the initial version of the input data frame
  n_per <- nrow(in_ts)
  in_df <- data.frame(RK._t_ = 1:n_per,
                      RK._year_ = gs.time2year(in_ts),
                      RK._per_ = gs.time2per(in_ts),
                      as.data.frame(in_ts))
  row.names(in_df) <- NULL
  
  
  # `tsraking()` arguments, i.e. the dot (...) arguments
  n_dot_args <- ...length()
  if (n_dot_args == 0) {
    stop("`tsraking()` argument 'metadata_df' must be specified.\n\n", call. = FALSE)
  }
  dot_args_list <- list(...)
  dot_args <- ...names()
  if (length(dot_args) == 0) {
    dot_args <- rep("", n_dot_args)
    names(dot_args_list) <- dot_args
  }
  tsraking_args <- names(formals("tsraking"))
  
  # "named" arguments
  named_args <- intersect(dot_args, tsraking_args)
  args_list <- dot_args_list[named_args]
  if ("data_df" %in% names(args_list)) {
    stop("`tsraking()` argument 'data_df' must NOT be specified with `tsraking_driver()`. ",
         "Use argument 'in_ts' instead.\n\n", call. = FALSE)
  }
  
  # "unnamed" arguments
  n_unnamed <- n_dot_args - length(args_list)
  if (n_unnamed > 0) {
    temp <- setdiff(dot_args, named_args)
    invalid_args <- temp[temp != ""]
    if (length(invalid_args) > 0) {
      stop("The following arguments are not defined for `tsraking()`:",
           paste0("\n  ", invalid_args, collapse = ""), "\n\n", call. = FALSE)
    }
    remaining_tsraking_args <- setdiff(tsraking_args, c("data_df", named_args))
    if (n_unnamed > length(remaining_tsraking_args)) {
      stop("Unable to match some of the specified dot (...) arguments with `tsraking()` arguments. ",
           "Remember not to specify argument 'data_df' with `tsraking_driver()`. Use argument 'in_ts' instead.\n\n",
           call. = FALSE)
    }
    
    # Assign names to the unnamed `tsraking()` arguments and add them to list `args_list`
    unnamed_args_list <- dot_args_list[which(dot_args == "")]
    names(unnamed_args_list) <- remaining_tsraking_args[1:n_unnamed]
    args_list <- c(args_list, unnamed_args_list)
  }
  specified_args <- names(args_list)
  
  
  # Quick validation of argument `metadata_df`
  if (!("metadata_df" %in% specified_args)) {
    stop("`tsraking()` argument 'metadata_df' must be specified.\n\n", call. = FALSE)
  }
  if (!is.data.frame(args_list$metadata_df)) {
    stop("`tsraking()` argument 'metadata_df' must be a 'data.frame' object.\n\n", call. = FALSE)
  }
  args_list$metadata_df <- as.data.frame(args_list$metadata_df)
  meta_cols <- toupper(names(args_list$metadata_df))
  if (length(intersect(c("SERIES", "TOTAL1"), meta_cols)) < 2) {
    stop("`tsraking()` argument 'metadata_df' contains invalid data. Suspecting argument ",
         "'data_df' to be inadvertently specified for argument 'metadata_df'.\n\n", call. = FALSE)
  }
  meta_df <- args_list$metadata_df
  names(meta_df) <- meta_cols
  
  
  # Process the alterability file (argument 'alterability_df')
  alter_arg_id <- which(specified_args == "alterability_df")
  if (length(alter_arg_id) == 1) {
    if (!is.null(args_list$alterability_df)) {
      
      if (!is.data.frame(args_list$alterability_df)) {
        stop("`tsraking()` argument 'alterability_df' must be a 'data.frame' object.\n\n", call. = FALSE)
      }
      args_list$alterability_df <- as.data.frame(args_list$alterability_df)
      
      
      # Assign the relevant alter coefs to each individual period
      n_alter_obs <- nrow(args_list$alterability_df)
      
      # Single obs: propagate (replicate) the alter coefs for all periods
      if (n_alter_obs == 1) {
        alter_df <- args_list$alterability_df[rep(1, n_per), , drop = FALSE]
        row.names(alter_df) <- NULL
        
        # Number of obs matches the 'ts' frequency: propagate the alter coefs to the corresponding
        # periods (matching cycles) in the 'ts'
      } else if (n_alter_obs == ts_freq) {
        alter_df <- args_list$alterability_df
        row.names(alter_df) <- NULL
        alter_df$RK._per_ <- as.integer(row.names(alter_df))
        temp <- c("RK._per_", "RK._t_")
        alter_df <- merge(alter_df, in_df[temp], by = "RK._per_")
        alter_df <- alter_df[order(alter_df$RK._t_), setdiff(names(alter_df), temp), drop = FALSE]
        row.names(alter_df) <- NULL
        
        # Number of obs matches the number of periods in the 'ts': nothing to do
      } else if (n_alter_obs == n_per)  {
        alter_df <- args_list$alterability_df
        row.names(alter_df) <- NULL
        
        # Incompatible number of obs in the `alterability_df` data frame
      } else {
        stop("`tsraking()` argument 'alterability_df' contains a number of observations ",
             "that is not compatible with the specified time series (argument 'in_ts').\n\n", call. = FALSE)
      }
      alter_arg_func <- gen_alter_arg
      
      # No alterability file
    } else {
      alter_arg_func <- gs.NULL_func
    }
    
    # Temporarily remove `alterability_df` from the list of arguments (will be (re)added for each
    # `tsraking()` call)
    args_list <- args_list[-alter_arg_id]
    
    # No `alterability_df` argument
  } else {
    alter_arg_func <- gs.NULL_func
  }
  
  
  # Set the output time series columns and problem variables (`NA` in case of errors)
  all_cols <- colnames(in_ts)
  prob_cols <- intersect(all_cols, unlist(apply(meta_df[intersect(meta_cols, c("SERIES", "TOTAL1", "TOTAL2"))],
                                                2, unique)))
  names(prob_cols) <- NULL
  if ("id" %in% specified_args) {
    xtra_cols <- intersect(all_cols, gs.cleanup_col_list(args_list$id))
  } else {
    xtra_cols <- character(0)
  }
  out_cols <- intersect(all_cols, unique(c(prob_cols, xtra_cols)))
  
  
  # Define the processing groups (set of raking problems)
  grp_df <- gs.build_proc_grps(in_df$RK._year_,
                               in_df$RK._per_,
                               n_per,
                               ts_freq,
                               temporal_grp_periodicity,
                               temporal_grp_start)
  
  # Activate message display
  n_grps <- nrow(grp_df)
  if (n_grps > 1) {
    msg_func <- message
    final_msg_flag <- TRUE
    try_stop_func <- gs.try_stop
  } else {
    msg_func <- gs.NULL_func
    final_msg_flag <- FALSE
    try_stop_func <- gs.NULL_func
  }
  
  
  # Rake each processing group (generate the `tsraking()` calls)
  out_df <- NULL
  for (grp in 1:n_grps) {
    
    # Print the processing group header
    if (grp_df$complete_grp[grp]) {
      msg_str <- paste0("Raking periods [", periods[grp_df$beg_per[grp]], " - ", periods[grp_df$end_per[grp]], "]")
    } else {
      msg_str <- paste0("Raking period [", periods[grp_df$beg_per[grp]], "]")
    }
    msg_func("\n\n", msg_str)
    msg_func(strrep("=", nchar(msg_str)), "\n")
    
    per_vec <- grp_df$beg_per[grp]:grp_df$end_per[grp]
    grp_data_df <- in_df[per_vec, out_cols, drop = FALSE]
    
    out_df <- rbind(out_df,
                    tryCatch(
                      withCallingHandlers(
                        
                        do.call("tsraking",
                                c(list(data_df = grp_data_df,
                                       alterability_df = alter_arg_func(per_vec)),
                                  args_list)
                        ),
                        
                        warning = function(wCnd) {
                          warning_flag <<- TRUE
                        }
                      ),
                      
                      error = function(eCnd) {
                        try_error_msg <<- conditionMessage(eCnd)
                        try_stop_func(try_error_msg)
                        try_error <<- TRUE
                        df <- grp_data_df
                        df[prob_cols] <- NA
                        df
                      }
                    ))
  }
  
  
  # Create the output ts object
  out_ser <- intersect(all_cols, names(out_df))
  out_ts <- stats::ts(data = out_df[out_ser],
                      start = stats::start(in_ts),
                      frequency = ts_freq)
  
  
  # Display a final warning/error message for multiple processing groups
  if (final_msg_flag) {
    if (warning_flag) {
      warning("Warnings were generated during processing. See relevant message(s) for details.\n",
              call. = FALSE, immediate. = TRUE)
    }
    # Non-muted error message (for proper condition catching by users of the function)
    if (try_error) {
      stop("Problems were encontered during processing. See preceeding error message(s) for details.\n\n",
           call. = FALSE)
    }
    
    # Display the error message for single processing groups
  } else if (try_error) {
    stop(try_error_msg, call. = FALSE)
  }
  
  # Output object returned via function `on.exit()`
}
