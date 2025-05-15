#devtools::test_active_file()
#devtools::test_coverage_active_file()


# Note: these tests also cover script `aliases.R`


# Complete test example
test_specs <- data.frame(

  TYPE = c("eq", rep(NA, 4),
           "GE", rep(NA, 2),
           "Le", rep(NA, 2),
           "lE", rep(NA, 2),
           "lowerBD", rep(NA, 3),
           "UpperBd", rep(NA, 3),
           "ALTER", rep(NA, 5),
           "AlterTmp", rep(NA, 3)),

  Col = c(NA, "x", "y", "z", "_rhs_",
          NA, "x", "y",
          NA, "x", "z",
          NA, "y", "z",
          NA, "x", "y", "z",
          NA, "x", "y", "z",
          NA, "x", "x", "z", "z", "z",
          NA, "x", "y", "z"),

  row = c("con1", "CON1", "cOn1", "Con1", "con1",
          rep("con2", 3),
          rep("con3", 3),
          rep("con4", 3),
          "minimum", "Minimum", "miniMum", "MINIMUM",
          "Maximum", "maximum", "MAXIMUM", "maxiMum",
          "Alter Coef", "alter coef", "ALTER COEF", "alter Coef", "alter Coef", "alter Coef",
          "Alter Coef Temporal", "alter coef temporal", "ALTER COEF TEMPORAL", "alter Coef temporal"),

  coef = c(NA, 3, -1, 2, 10,
           NA, 1, 1,
           NA, 1, -1,
           NA, 1, -1,
           NA, -10, 5e-3, 3,
           NA, 100, 2e4, 9999,
           NA, 0.999, 1.1, 0.9, 0.1, 0,
           NA, 0.9, 1, 0.1),

  timeval = c(rep(NA, 5),
              rep(NA, 3),
              rep(NA, 3),
              rep(NA, 3),
              NA, NA, 2010.25, 2011.25,
              NA, 2009.75, 2010.25, 2010.75,
              NA, NA, 2009.75, 2009.75, 2010.25, 2011.25,
              rep(NA, 3), 2010.5)
)
# View(test_specs)

test_ts <- ts(matrix(rep(c(100, 3, 5, 10, 200), 11),
                     ncol = 5,
                     byrow = TRUE,
                     dimnames = list(NULL, c("a", "y", "x", "z", "b"))),
              start = c(2009, 4),
              frequency = 4)
window(test_ts[, "a"], end = c(2010, 4)) <- NA



# Lower/upper bounds mapping bug (discovered with ISQ on 2014-11-21)
test_that("Lower/upper bounds mapping bug", {
  expect_equal(
    tsbalancing(
      in_ts = ts(data.frame(
        c = 30, a = 10, b = 10),
        frequency = 12,
        start = c(2024, 1)),
      problem_specs_df = data.frame(
        type = c("eq", rep(NA, 3), "lowerBd", rep(NA, 3), "upperBd", rep(NA, 3)),
        col = c(NA, "a", "b", "c", NA, "a", "b", "c", NA, "a", "b", "c"),
        row = c(rep("con", 4), rep("lb", 4), rep("ub", 4)),
        coef = c(NA, 1, 1, -1, NA, -100, -200, -300, NA, 100, 200, 300)),
      alter_neg = 0,
      quiet = TRUE)$prob_con_df[["name"]], 
    c("con", "a", "b"))  #early problematic versions would return `c("con", "c", "a")`
  expect_equal(
    macro_gseriestsbalancing(
      in_ts = ts(data.frame(
        c = 30, a = 10, b = 10),
        frequency = 12,
        start = c(2024, 1)),
      problem_specs_df = data.frame(
        type = c("eq", rep(NA, 3), "lowerBd", rep(NA, 3), "upperBd", rep(NA, 3)),
        col = c(NA, "a", "b", "c", NA, "a", "b", "c", NA, "a", "b", "c"),
        row = c(rep("con", 4), rep("lb", 4), rep("ub", 4)),
        coef = c(NA, 1, 1, -1, NA, -100, -200, -300, NA, 100, 200, 300)),
      alter_neg = 0,
      quiet = TRUE)$prob_con_df[["name"]], 
    c("con", "a", "b"))  #early problematic versions would return `c("con", "c", "a")`
})


# Regular tests start here



#---- Normal Execution ----


res1 <- NULL
test_that("Period-by-period processing", {
  res1 <<- expect_type(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE)
  ), "list")
})
# View(res1$proc_grp_df)
# View(res1$periods_df)
# View(res1$prob_val_df)
# View(res1$prob_con_df)
# View(res1$osqp_settings_df)
# View(res1$osqp_sol_info_df)

res2 <- NULL
test_that("Temporal group processing", {
  res2 <<- expect_type(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ), "list")
})
# View(res2$out_ts)
# View(res2$proc_grp_df)
# View(res2$periods_df)
# View(res2$prob_val_df)
# View(res2$prob_con_df)
# View(res2$osqp_settings_df)
# View(res2$osqp_sol_info_df)




#---- Parameter Validation  ----


test_that("Mandatory arg `in_ts` not a 'ts' object => error", {
  expect_error(suppressMessages(
    tsbalancing(as.data.frame(test_ts), test_specs, quiet = TRUE)
  ))
  expect_error(suppressMessages(
    tsbalancing(list(test_ts, NULL), test_specs, quiet = TRUE)
  ))
})


test_that("Mandatory arg `problem_specs_df` not a 'data.frame' object => error", {
  expect_error(suppressMessages(
    tsbalancing(test_ts, as.matrix(test_specs), quiet = TRUE)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, list(test_specs, NULL), quiet = TRUE)
  ))
})


test_str1 <- "Optional arg `temporal_grp_periodicity`"
test_that(paste0(test_str1, " not an integer => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 1.5)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = NA_integer_)
  ))
})
test_that(paste0(test_str1, " invalid integer => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 0)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = -1)
  ))
})


test_str1 <- "Optional arg `temporal_grp_start`"
test_that(paste0(test_str1, " not an integer => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = 1.5)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = NA_integer_)
  ))
})
test_that(paste0(test_str1, " invalid integer => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = 0)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                temporal_grp_start = 5)
  ))
})
test_that(paste0(test_str1, "correct result period-by-period"), {
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 1,
                temporal_grp_start = 0)$out_ts
  ), res1$out_ts)
})


test_str1 <- "Optional arg `osqp_settings_df`"
test_that(paste0(test_str1, " not a 'data.frame' object => warning"), {
  expect_warning(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                osqp_settings_df = as.matrix(default_osqp_sequence))
  ))
  expect_warning(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                osqp_settings_df = list(default_osqp_sequence, NULL))
  ))
})


test_str1 <- "Optional arg `display_level`"
test_that(paste0(test_str1, " not an integer => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = 1.5)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = NA_integer_)
  ))
})
test_that(paste0(test_str1, " invalid integer => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = -1)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                display_level = 4)
  ))
})
test_that(paste0(test_str1, " invalid values when `quiet == TRUE` => normal"), {
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                display_level = list(1))$out_ts
  ), res1$out_ts)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                display_level = -1)$out_ts
  ), res1$out_ts)
})


test_str1 <- "Optional arg `alter_pos`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_pos = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_pos = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_pos = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_pos = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_pos = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_pos = NA_real_)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_pos = -1)
  ))
})


test_str1 <- "Optional arg `alter_neg`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_neg = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_neg = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_neg = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_neg = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_neg = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_neg = NA_real_)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_neg = -1)
  ))
})


test_str1 <- "Optional arg `alter_mix`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_mix = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_mix = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_mix = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_mix = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_mix = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_mix = NA_real_)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                alter_mix = -1)
  ))
})


test_str1 <- "Optional arg `alter_temporal`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = NA_real_)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = -1)
  ))
})


test_str1 <- "Optional arg `lower_bound`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                lower_bound = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                lower_bound = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                lower_bound = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                lower_bound = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                lower_bound = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                lower_bound = NA_real_)
  ))
})


test_str1 <- "Optional arg `upper_bound`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                upper_bound = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                upper_bound = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                upper_bound = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                upper_bound = -Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                upper_bound = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                upper_bound = NA_real_)
  ))
})


test_str1 <- "Optional arg `tolV`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                tolV = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                tolV = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                tolV = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                tolV = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                tolV = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                tolV = NA_real_)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                tolV = -1)
  ))
})


test_str1 <- "Optional arg `tolV_temporal`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = NULL)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = -1)
  ))
})


test_str1 <- "Optional arg `tolP_temporal`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolP_temporal = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolP_temporal = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolP_temporal = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolP_temporal = Inf)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolP_temporal = -1)
  ))
})


test_str1 <- "Optional args `tolV_temporal` and `tolP_temporal`"
test_that(paste0(test_str1, " both specified => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = 0,
                tolP_temporal = 0)
  ))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV_temporal = NA_real_,
                tolP_temporal = 0)$out_ts
  ), res2$out_ts)
})


test_str1 <- "Optional arg `trunc_to_zero_tol`"
test_that(paste0(test_str1, " not a real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                trunc_to_zero_tol = list(1))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                trunc_to_zero_tol = c(1, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                trunc_to_zero_tol = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                trunc_to_zero_tol = Inf)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                trunc_to_zero_tol = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                trunc_to_zero_tol = NA_real_)
  ))
})
test_that(paste0(test_str1, " invalid real number => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                trunc_to_zero_tol = -1)
  ))
})


test_str1 <- "Optional arg `validation_only`"
test_that(paste0(test_str1, " not a logical value => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                validation_only = c(TRUE, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                validation_only = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                validation_only = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                validation_only = NA)
  ))
})
test_that(paste0(test_str1, "valid non-standard logical values"), {
  expect_equal(suppressMessages(
    tsbalancing(res1$out_ts, test_specs, quiet = TRUE,
                validation_only = -1.0)$out_ts
  ), res1$out_ts)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                validation_only = "F")$out_ts
  ), res1$out_ts)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                validation_only = 0)$out_ts
  ), res1$out_ts)
})


test_str1 <- "Optional arg `quiet`"
test_that(paste0(test_str1, " not a logical value => error"), {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                quiet = c(TRUE, NA))
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                validation_only = "1")
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                quiet = NULL)
  ))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs,
                quiet = NA)
  ))
})
test_that(paste0(test_str1, "valid non-standard logical values"), {
  expect_equal(suppressMessages(
    tsbalancing(res1$out_ts, test_specs,
                quiet = -1.0)$out_ts
  ), res1$out_ts)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs,
                quiet = "F")$out_ts
  ), res1$out_ts)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs,
                quiet = 0)$out_ts
  ), res1$out_ts)
})




#---- OSQP settings ----


test_that("Default OSQP settings => warning", {
  expect_warning(suppressMessages(
    tsbalancing(window(test_ts, start = start(test_ts), end = start(test_ts)), test_specs, quiet = TRUE,
                osqp_settings_df = NULL)
  ))
})
test_that("Default OSQP settings with `validation_tol = 0.499` => normal", {
  expect_type(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                osqp_settings_df = NULL,
                validation_tol = 0.499)$out_ts
  ), "double")
})
test_that("Default OSQP settings + forced polishing => normal", {
  expect_equal(suppressMessages(
    tsbalancing(window(test_ts, start = start(test_ts), end = start(test_ts)), test_specs, quiet = TRUE,
                osqp_settings_df = data.frame(polish = TRUE))$osqp_settings_df$polish
  ), TRUE)
})
test_that("Default OSQP settings + forced polishing + invalid option => normal", {
  expect_equal(suppressMessages(
    tsbalancing(window(test_ts, start = start(test_ts), end = start(test_ts)), test_specs, quiet = TRUE,
                osqp_settings_df = data.frame(polish = TRUE, blabla = 0))$osqp_settings_df$polish
  ), TRUE)
})




#---- Alter coefs and bounds ----


# Problem specs for alter coefs abnd bounds testing
# - drop non period specific alter coef for `x`
# - change the sign of the "con1" coefficient for `z`
test_specs2 <- test_specs[-24, , drop = FALSE]
test_specs2$coef[4] <- -test_specs2$coef[4]

test_that("Specified bounds and alter coefs", {
  tmp <- data.frame(lower_bd = c(-888888, -Inf),
                    upper_bd = c(888888, Inf),
                    alter = c(1.003, 0.001))
  attr(tmp, "row.names") <- c(1L, 33L)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE, temporal_grp_periodicity = 4,
                alter_pos = 1.001,
                alter_neg = 1.002,
                alter_mix = 1.003,
                alter_temporal = 1e-3,
                lower_bound = -888888,
                upper_bound = 888888)$prob_val_df[c(1, 33), c("lower_bd", "upper_bd", "alter"), drop = FALSE]
  ), tmp)

  tmp <- data.frame(lower_bd = c(-10, -888888),
                    upper_bd = c(888888, 888888),
                    alter = c(1.001, 1.002))
  attr(tmp, "row.names") <- c(5L, 6L)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE, temporal_grp_periodicity = 4,
                alter_pos = 1.001,
                alter_neg = 1.002,
                alter_mix = 1.003,
                alter_temporal = 1e-3,
                lower_bound = -888888,
                upper_bound = 888888)$prob_val_df[c(5, 6), c("lower_bd", "upper_bd", "alter"), drop = FALSE]
  ), tmp)
  tmp <- data.frame(lower_bd = c(-Inf, -10, -Inf, -Inf),
                    upper_bd = c(Inf, Inf, Inf, Inf),
                    alter = c(1, 1, 1, 0))
  attr(tmp, "row.names") <- c(1L, 5L, 6L, 33L)
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$prob_val_df[c(1, 5, 6, 33), c("lower_bd", "upper_bd", "alter"), drop = FALSE]
  ), tmp)
})

test_that("Specicied default bounds and alter coefs", {
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE, temporal_grp_periodicity = 4,
                alter_pos = 1,
                alter_neg = 1,
                alter_mix = 1,
                alter_temporal = 0,
                lower_bound = -Inf,
                upper_bound = Inf)$out_ts
  ), res2$out_ts)
})




#---- Tolerances ----


test_that("`trunc_to_zero_tol`", {
  # the 4 values of interest are: 0.89, 0.70, 0.70 and 0.70
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4)$prob_val_df$value_out[c(2, 5, 11, 14)] == 0
  ), c(FALSE, FALSE, FALSE, FALSE))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4,
                trunc_to_zero_tol = 0.8,
                validation_tol    = 2.2)$prob_val_df$value_out[c(2, 5, 11, 14)] == 0
  ), c(FALSE, TRUE, TRUE, TRUE))
})


# Problem specs for tolerance testing
# - drop the temporal total alter coef for `z`
# - set the temporal total alter coef for `y` to 0
test_specs3 <- test_specs[-32, ]
test_specs3$coef[31] <- 0

test_str <- "`tolV`, `tolV_temporal` and `tolP_temporal`"
test_that(paste0(test_str, ": binding tempotal totals, `tolV_temporal`"), {
  expect_type(suppressMessages(
    tsbalancing(test_ts, test_specs3, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV = 1e-9,
                tolV_temporal = 0.01, tolP_temporal = NA)$out_ts
  ), "double")
})
test_that(paste0(test_str, ": nonbinding tempotal totals, `tolV_temporal`"), {
  expect_type(suppressMessages(
    tsbalancing(test_ts, test_specs3, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = 1,
                tolV = 1e-9,
                tolV_temporal = 0.001, tolP_temporal = NA)$out_ts
  ), "double")
})
test_that(paste0(test_str, ": binding tempotal totals, `tolP_temporal`"), {
  expect_type(suppressMessages(
    tsbalancing(test_ts, test_specs3, quiet = TRUE,
                temporal_grp_periodicity = 4,
                tolV = 1e-9,
                tolV_temporal = NA, tolP_temporal = 0.001)$out_ts
  ), "double")
})
test_that(paste0(test_str, ": nonbinding tempotal totals, `tolP_temporal`"), {
  expect_type(suppressMessages(
    tsbalancing(test_ts, test_specs3, quiet = TRUE,
                temporal_grp_periodicity = 4,
                alter_temporal = 1,
                tolV = 1e-6,
                tolV_temporal = NA, tolP_temporal = 0.001)$out_ts
  ), "double")
})




#---- Missing data ----


test_that("Missing data for a relevant time series => warning", {
  test_ts2 <- test_ts
  test_ts2[11, "y"] <- NA
  expect_warning(suppressMessages(
    tsbalancing(test_ts2, test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that("Missing series (specified in the problem specs) => error", {
  expect_error(suppressMessages(
    tsbalancing(test_ts[, c("a", "b")], test_specs, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that("Empty problem specs => error", {
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs[NULL, , drop = FALSE], quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})




#---- Problem Specs ----


test_str <- "Problem Specs"
test_that(paste0(test_str, ": duplicate label (same constraint type) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "EQ",
                                  Col = "",
                                  row = "Con1",
                                  coef = NA,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate label (different constraint type) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "LE",
                                  Col = NA,
                                  row = "Con1",
                                  coef = NA,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate label (different type) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "Alter",
                                  Col = NA,
                                  row = "Con1",
                                  coef = NA,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate label (different type) => error"), {
  test_specs2 <- test_specs
  test_specs2$row[tolower(test_specs2$row) == "maximum"] <- "Con1"
  test_specs2$timeval[tolower(test_specs2$row) == "con1"] <- NA
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid problem elements (`type`) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("blabla", NA, "whatever", NA),
                                  Col = c(NA, "x", NA, "y"),
                                  row = c("blabla", "blabla", "whatever", "whatever"),
                                  coef = c(NA, 1, NA, 1),
                                  timeval = rep(NA, 4)))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid problem elements (`type`) but with NA coefs => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("blabla", NA, "whatever", NA),
                                  Col = c(NA, "x", NA, "y"),
                                  row = c("blabla", "blabla", "whatever", "whatever"),
                                  coef = rep(NA, 4),
                                  timeval = rep(NA, 4)))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": invalid problem element labels (`row`) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = rep(NA, 4),
                                  Col = c("z", "x", "z", "y"),
                                  row = c("blabla", "BLABLA", "WHATEVER", "whatever"),
                                  coef = rep(1, 4),
                                  timeval = rep(NA, 4)))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid problem element labels (`row`) but with NA coefs => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = rep(NA, 4),
                                  Col = c("z", "x", "z", "y"),
                                  row = c("blabla", "BLABLA", "WHATEVER", "whatever"),
                                  coef = rep(NA, 4),
                                  timeval = rep(NA, 4)))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": duplicate constraint coef (same value) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "",
                                  Col = "x",
                                  row = "Con1",
                                  coef = 3,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate constraint coef (different value) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "x",
                                  row = "Con1",
                                  coef = 1,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate constraint coef (NA value) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "x",
                                  row = "Con1",
                                  coef = NA,
                                  timeval = NA))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": duplicate constraint RHS (different value) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "_RhS_",
                                  row = "Con1",
                                  coef = 1,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate constraint RHS (NA value) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "_RHS_",
                                  row = "Con1",
                                  coef = NA,
                                  timeval = NA))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": duplicate lower bound => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "x",
                                  row = "Minimum",
                                  coef = -1,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate lower bound (NA value) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "x",
                                  row = "Minimum",
                                  coef = NA,
                                  timeval = NA))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": duplicate period-specific lower bound => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "y",
                                  row = "Minimum",
                                  coef = -1,
                                  timeval = 2010.25))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate period-specific lower bound (NA value) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = NA,
                                  Col = "y",
                                  row = "Minimum",
                                  coef = NA,
                                  timeval = 2010.25))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": duplicate alter => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "",
                                  Col = "x",
                                  row = "ALTER COEF",
                                  coef = 25,
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate alter (NA value) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "",
                                  Col = "x",
                                  row = "ALTER COEF",
                                  coef = NA,
                                  timeval = NA))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": duplicate period-specific alter => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "",
                                  Col = "x",
                                  row = "ALTER COEF",
                                  coef = 2,
                                  timeval = 2009.75))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": duplicate period-specific alter (NA value) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = "",
                                  Col = "x",
                                  row = "ALTER COEF",
                                  coef = NA,
                                  timeval = 2009.75))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": multiple labels for a given non-constraint `type` => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("LOWERBD", NA),
                                  Col = c("", "z"),
                                  row = c("minimum2", "MINIMUM2"),
                                  coef = c(NA, -999),
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid `type` value => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("LOWERBD_", NA),
                                  Col = c("", "z"),
                                  row = c("minimum2", "MINIMUM2"),
                                  coef = c(NA, -999),
                                  timeval = NA))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": empty constraints because of invalid `row` => error"), {
  test_specs2 <- test_specs
  logi_vec <- tolower(substr(test_specs2$row, 1, 3)) == "con" & is.na(test_specs2$TYPE)
  test_specs2$row[logi_vec] <- paste0("_", test_specs2$row[logi_vec])
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid series names => error"), {
  test_specs2 <- test_specs
  logi_vec <- !is.na(test_specs2$Col)
  test_specs2$Col[logi_vec] <- paste0("_", test_specs2$Col[logi_vec])
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": extra empty constraint (RHS only) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("eq", NA),
                                  Col = c("", "_rhs_"),
                                  row = c("RHS Only", "RHS Only"),
                                  coef = c(NA, 0),
                                  timeval = c(NA, NA)))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": extra info for irrelevant series (ignored) => normal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("blabla", rep(NA, 4)),
                                  Col = c("", "blabla1", "blabla1", "blabla2", "blabla2"),
                                  row = c("blabla", "Con10", "blabla", "Con10", "blabla"),
                                  coef = c(NA, 2, 2, 10, 10),
                                  timeval = rep(NA, 5)))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": funky labels (`row` values) => normal"), {
  test_specs2 <- test_specs
  test_specs2$row <- paste(test_specs2$row, "&a %b ' \" ) + - * / < > = ¬= ^= ~= >= <= ; , #")
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})
test_that(paste0(test_str, ": labels (`row` values) with several (embedded) blanks => normal"), {
  test_specs2 <- test_specs
  test_specs2$row <- paste(test_specs2$row, "START          END")
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})

test_that(paste0(test_str, ": missing all 4 madatory columns => error"), {
  test_specs2 <- test_specs["timeval"]
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": missing column `type` => error"), {
  test_specs2 <- test_specs[-1]
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": numeric colum `type` => error"), {
  test_specs2 <- test_specs[-1]
  test_specs2$type <- NA_real_
  test_specs2$type[15] <- 1
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": numeric colums `type` and `row` => error"), {
  test_specs2 <- test_specs[-c(1, 3)]
  test_specs2$type <- NA_real_
  test_specs2$type[15] <- 1
  test_specs2$row <- NA_real_
  test_specs2$row[15] <- 1
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": character colum `coef` => error"), {
  test_specs2 <- test_specs
  test_specs2$coef <- as.character(test_specs2$coef)
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": character colum `timeval` => error"), {
  test_specs2 <- test_specs
  test_specs2$timeval <- as.character(test_specs2$timeval)
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})

test_that(paste0(test_str, ": invalid constraint coef => error"), {
  test_specs2 <- test_specs
  test_specs2$coef[2] <- Inf
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid alter coef => error"), {
  test_specs2 <- test_specs
  test_specs2$coef[24] <- -1
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid alter coef => error"), {
  test_specs2 <- test_specs
  test_specs2$coef[24] <- Inf
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid temporal alter coef => error"), {
  test_specs2 <- test_specs
  test_specs2$coef[30] <- -1
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid temporal alter coef => error"), {
  test_specs2 <- test_specs
  test_specs2$coef[30] <- Inf
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid lower bound => error"), {
  test_specs2 <- test_specs
  test_specs2$coef[16] <- Inf
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": invalid lower bound => error"), {
  test_specs2 <- test_specs
  test_specs2$coef[20] <- -Inf
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": constraint coef for invalid series (not in `in_ts`) => error"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("", NA),
                                  Col = c("blabla1", "blabla2"),
                                  row = c("Con1", "CON1"),
                                  coef = c(1, 1),
                                  timeval = c(NA, NA)))
  expect_error(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)
  ))
})
test_that(paste0(test_str, ": irrelevant constraint coef (0 or `NA`) for invalid series (not in `in_ts`) => nomal"), {
  test_specs2 <- rbind(test_specs,
                       data.frame(TYPE = c("", NA),
                                  Col = c("blabla1", "blabla2"),
                                  row = c("Con1", "CON1"),
                                  coef = c(0, NA),
                                  timeval = c(NA, NA)))
  expect_equal(suppressMessages(
    tsbalancing(test_ts, test_specs2, quiet = TRUE,
                temporal_grp_periodicity = 4)$out_ts
  ), res2$out_ts)
})


#---- Complete the test coverage ----

test_that("`display_level > 1`", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, end = time(test_ts)[1]),
      test_specs,
      display_level = 2)$out_ts
  ), window(res1$out_ts, end = time(test_ts)[1])
  )
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, end = time(test_ts)[1]),
      test_specs,
      display_level = 3)$out_ts
  ), window(res1$out_ts, end = time(test_ts)[1])
  )
})

test_that("error: `in_ts` not specified", {
  expect_error(suppressMessages(
    tsbalancing()
  ))
})
test_that("error: `problem_specs_df` not specified", {
  expect_error(suppressMessages(
    tsbalancing(test_ts)
  ))
})

test_that("arguments passed as a \"structure\"", {
  expect_equal(suppressMessages(
    do.call("tsbalancing",
            list(test_ts,
                 test_specs, 
                 osqp_settings_df = default_osqp_sequence,
                 display_level = 0))$out_ts
    ), res1$out_ts)
})

test_that("error: `lower_bound` > `upper_bound`", {
  expect_error(suppressMessages(
    tsbalancing(test_ts,
                test_specs, 
                lower_bound = 1, upper_bound = 0)
  ))
})

test_that("error: invalid `validation_tol`", {
  expect_error(suppressMessages(
    tsbalancing(test_ts,
                test_specs, 
                validation_tol = -1)
  ))
})

test_that("`tolP_temporal = NULL`", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, end = time(test_ts)[4]),
      test_specs,
      temporal_grp_periodicity = 4, 
      tolP_temporal = NULL,
      quiet = TRUE)$out_ts
  ), window(res1$out_ts, end = time(test_ts)[4]))
})

test_that("add \"polish\" option when \"require_polish\" is specified", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, end = time(test_ts)[1]),
      test_specs,
      osqp_settings_df = default_osqp_sequence[setdiff(names(default_osqp_sequence), "polish")],
      display_level = 0)$out_ts
  ), window(res1$out_ts, end = time(test_ts)[1])
  )
})

test_that("error: invalid `full_sequence`", {
  expect_error(suppressMessages(
    tsbalancing(test_ts,
                test_specs, 
                full_sequence = NULL)
  ))
})

test_that("no dated lower/upper bounds", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, end = time(test_ts)[1]),
      test_specs[!(tolower(test_specs$row) %in% c("minimum", "maximum")) |
                   tolower(test_specs$row) %in% c("minimum", "maximum") & is.na(test_specs$timeval), ],
      display_level = 1)$out_ts
  ), window(res1$out_ts, end = time(test_ts)[1])
  )
})

test_that("no dated alter coef", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, start = time(test_ts)[2], end = time(test_ts)[2]),
      test_specs[!(tolower(test_specs$row) == "alter coef") |
                   tolower(test_specs$row) == "alter coef" & is.na(test_specs$timeval), ],
      display_level = 1)$out_ts
  ), window(res1$out_ts, start = time(test_ts)[2], end = time(test_ts)[2])
  )
})

test_that("problem display: temporal alter coef", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, start = time(test_ts)[2], end = time(test_ts)[5]),
      test_specs,
      temporal_grp_periodicity = 4,
      display_level = 1)$out_ts
  ), window(res2$out_ts, start = time(test_ts)[2], end = time(test_ts)[5])
  )
})

test_that("problem display: temporal alter coef without dated coefs", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, start = time(test_ts)[6], end = time(test_ts)[9]),
      test_specs[!(tolower(test_specs$row) == "alter coef temporal") |
                   tolower(test_specs$row) == "alter coef temporal" & is.na(test_specs$timeval), ],
      temporal_grp_periodicity = 4,
      display_level = 1)$out_ts
  ), window(res2$out_ts, start = time(test_ts)[6], end = time(test_ts)[9])
  )
})

test_that("problem display: OSQP solving details and results", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, start = time(test_ts)[2], end = time(test_ts)[5]),
      test_specs,
      temporal_grp_periodicity = 4,
      display_level = 3)$out_ts
  ), window(res2$out_ts, start = time(test_ts)[2], end = time(test_ts)[5])
  )
})

test_that("problem display: OSQP solving details and results, single constraint", {
  expect_equal(suppressMessages(
    tsbalancing(
      window(test_ts, start = time(test_ts)[1], end = time(test_ts)[1]),
      test_specs[tolower(test_specs$row) == "con1", ],
      display_level = 3)$proc_grp_df$proc_grp
  ), 1
  )
})

test_that("unsolved fixed problem: 3 warnings (unsolvable problem, constraints not met, final warning)", {
  expect_warning(expect_warning(expect_warning(suppressMessages(
    tsbalancing(
      window(test_ts, start = time(test_ts)[1], end = time(test_ts)[2]),
      rbind(test_specs[substr(tolower(test_specs$row), 1, 3) == "con", ],
            data.frame(TYPE = c("alter", NA, NA, NA),
                       Col = c(NA, "x", "y", "z"),
                       row = rep.int("alter coef", 4),
                       coef = rep.int(0, 4),
                       timeval = rep.int(2009.75, 4))))
  ))))
})

test_that("validation only: invalid initial solution (warning)", {
  expect_warning(suppressMessages(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, "a", "b", "c"),
                 row = rep.int("con", 4),
                 coef = c(NA, 1, 1, -1)),
      alter_neg = 0,
      quiet = TRUE,
      validation_only = TRUE)
  ))
})

test_that("Valid fixed initial solution", {
  my_ts <- ts(data.frame(a = 1, b = 1, c = 2.01), start = 2021, frequency = 4)
  expect_equal(suppressMessages(
    tsbalancing(
      my_ts,
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, "a", "b", "c"),
                 row = rep.int("con", 4),
                 coef = c(NA, 1, 1, -1)),
      alter_pos = 0,
      alter_neg = 0,
      validation_tol = 0.1,
      display_level = 3)$out_ts
  ), my_ts)
})

test_that("invalid polished osqp solution (warning: constraints not met)", {
  expect_warning(suppressMessages(
    tsbalancing(
      window(test_ts, start = time(test_ts)[2], end = time(test_ts)[5]),
      test_specs,
      temporal_grp_periodicity = 4,
      validation_tol = gs.min_tolerance,
      display_level = 3)
  ))
})

test_that("The initial solution cannot be improved with OSQP (warning: constraints not met)", {
  expect_warning(suppressMessages(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = (2 + 1e-15)), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, "a", "b", "c"),
                 row = rep.int("con", 4),
                 coef = c(NA, 1, 1, -1)),
      alter_neg = 0,
      osqp_settings_df = NULL,
      validation_tol = gs.min_tolerance,
      display_level = 3)
  ))
})

test_that("problem_specs: invalid time values specified with \"time_val\"", {
  test_specs_ <- test_specs
  names(test_specs_) <- c(names(test_specs)[-5], "time_val")
  test_specs_$time_val[nrow(test_specs_)] <- Inf
  expect_error(suppressMessages(
    tsbalancing(
      window(test_ts, end = time(test_ts)[1]),
      test_specs_,
      display_level = 0)
  ))
})

test_that("problem_specs: invalid label definition record (\"row\")", {
  expect_error(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, "a", "b", "c"),
                 row = rep.int("", 4),
                 coef = c(NA, 1, 1, -1)),
      quiet = TRUE)
  )
})

test_that("problem_specs: invalid information specification record (\"row\" or \"col\")", {
  expect_error(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, NA, "b", "c"),
                 row = rep.int("con", 4),
                 coef = c(NA, 1, 1, -1)),
      quiet = TRUE)
  )
  expect_error(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, "a", "b", "c"),
                 row = c(rep.int("con", 3), NA),
                 coef = c(NA, 1, 1, -1)),
      quiet = TRUE)
  )
})

test_that("problem_specs: invalid label definition record (\"row\")", {
  expect_error(suppressMessages(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, "a", "b", "c"),
                 row = rep.int("", 4),
                 coef = c(NA, 1, 1, -1)),
      display_level = 0)
  ))
})

test_that("problem_specs: time values for constraints coefs or RHS (not allowed)", {
  expect_error(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA),
                 col = c(NA, "a", "b", "c"),
                 row = rep.int("con", 4),
                 coef = c(NA, 1, 1, -1),
                 timeval = c(NA, 2021, NA, NA)),
      quiet = TRUE)
  )
  expect_error(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA, NA),
                 col = c(NA, "a", "b", "c", "_rhs_"),
                 row = rep.int("con", 5),
                 coef = c(NA, 1, 1, -1, 0),
                 timeval = c(NA, NA, NA, NA, 2021)),
      quiet = TRUE)
  )
})

test_that("problem_specs: lowerBd > upperBd", {
  expect_error(
    tsbalancing(
      ts(data.frame(a = 1, b = 1, c = 1), start = 2021, frequency = 4),
      data.frame(type = c("eq", NA, NA, NA, "lowerBd", NA, "upperBd", NA),
                 col = c(NA, "a", "b", "c", NA, "a", NA, "a"),
                 row = c(rep.int("con", 4), "min", "min", "max", "max"),
                 coef = c(NA, 1, 1, -1, NA, 2, NA, 1)),
      quiet = TRUE)
  )
})
