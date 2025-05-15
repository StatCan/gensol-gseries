#devtools::test_active_file()
#devtools::test_coverage_active_file()


#---- Part 1 - bias functions ----

# `biasOption = 1` (no calc)
test_that("`biasOption = 1`, add bench", {
  # qtr data (all 0), bias = 2 (actual bias = 1) 
  expect_equal(
    bk.apply_biasOption1(msg_f = gs.NULL_func, 
                         calc_f = bk.calc_add_bias, 
                         s_lowFreq = 0, 
                         a = 1, 
                         denom = 1, 
                         tol = gs.tolerance, 
                         apply_f = bk.apply_add_bias, 
                         s = rep.int(0, 4), 
                         bias = 2, 
                         str = "")
    , rep.int(2, 4))
})
test_that("`biasOption = 1`, mult bench", {
  # qtr data (all 1), bias = 3 (actual bias = 2)
  expect_equal(
    bk.apply_biasOption1(msg_f = gs.NULL_func, 
                         calc_f = gs.NULL_func, 
                         s_lowFreq = 4, 
                         a = 8, 
                         denom = NA, 
                         tol = gs.tolerance, 
                         apply_f = bk.apply_mult_bias, 
                         s = rep.int(1, 4), 
                         bias = 3, 
                         str = "")
    , rep.int(3, 4))
})

# `biasOption = 2` (calc, not used)
test_that("`biasOption = 2`, add bench", {
  # qtr data (all 0), bias = 2 (actual bias = 1) 
  expect_equal(
    bk.apply_biasOption2(msg_f = gs.NULL_func, 
                         calc_f = bk.calc_add_bias, 
                         s_lowFreq = 0, 
                         a = 1, 
                         denom = 1, 
                         tol = gs.tolerance, 
                         apply_f = bk.apply_add_bias, 
                         s = rep.int(0, 4), 
                         bias = 2, 
                         str = "")
    , rep.int(2, 4))
})
test_that("`biasOption = 2`, mult bench", {
  # qtr data (all 1), bias = 3 (actual bias = 2)
  expect_equal(
    bk.apply_biasOption2(msg_f = gs.NULL_func, 
                         calc_f = bk.calc_mult_bias, 
                         s_lowFreq = 4, 
                         a = 8, 
                         denom = NA, 
                         tol = gs.tolerance, 
                         apply_f = bk.apply_mult_bias, 
                         s = rep.int(1, 4), 
                         bias = 3, 
                         str = "")
    , rep.int(3, 4))
})
test_that("`biasOption = 2`, mult bench, div by 0 warning", {
  # qtr data (all 0), bias = 3 (actual bias is undefined: warning)
  expect_warning(
    bk.apply_biasOption2(msg_f = gs.NULL_func, 
                         calc_f = bk.calc_mult_bias, 
                         s_lowFreq = 0, 
                         a = 8, 
                         denom = NA, 
                         tol = gs.tolerance, 
                         apply_f = bk.apply_mult_bias, 
                         s = rep.int(0, 4), 
                         bias = 3, 
                         str = "")
    )
})

# `biasOption = 3` (calc, used)
test_that("`biasOption = 3`, add bench", {
  # qtr data (all 0), actual bias = 1 
  expect_equal(
    bk.apply_biasOption3(msg_f = gs.NULL_func, 
                         calc_f = bk.calc_add_bias, 
                         s_lowFreq = 0, 
                         a = 1, 
                         denom = 1, 
                         tol = gs.tolerance, 
                         apply_f = bk.apply_add_bias, 
                         s = rep.int(0, 4), 
                         bias = 2, 
                         str = "")
    , rep.int(1, 4))
})
test_that("`biasOption = 3`, mult bench", {
  # qtr data (all 1), actual bias = 2
  expect_equal(
    bk.apply_biasOption3(msg_f = gs.NULL_func, 
                         calc_f = bk.calc_mult_bias, 
                         s_lowFreq = 4, 
                         a = 8, 
                         denom = NA, 
                         tol = gs.tolerance, 
                         apply_f = bk.apply_mult_bias, 
                         s = rep.int(1, 4), 
                         bias = 3, 
                         str = "")
    , rep.int(2, 4))
})


#---- Part 2 - Benchmarks validation functions ----

# Add bench (diff valid)
test_that("valid benchmark, add bench", {
  # 1 valid binding bmk + 1 nonbinding bmk (n/a)
  expect_no_warning(
    bk.binding_bmk_diff_valid(a = c(1, 1), 
                              theta_lowFreq = c(1, 2), 
                              c_a = c(0, 1), 
                              bmk_start = NA, 
                              bmk_end = NA, 
                              tol = gs.tolerance)
  )
})
test_that("valid benchmark, add bench", {
  # 1 invalid binding bmk + 1 nonbinding bmk (n/a)
  expect_warning(
    bk.binding_bmk_diff_valid(a = c(1, 1), 
                              theta_lowFreq = c(2, 2), 
                              c_a = c(0, 1), 
                              bmk_start = c("2021-1", "2021-2"), 
                              bmk_end = c("2021-4", "2021-4"), 
                              tol = gs.tolerance)
  )
})

# Mult bench (relDiff valid)
test_that("valid benchmark, add bench", {
  # 1 valid binding bmk + 1 nonbinding bmk (n/a)
  expect_no_warning(
    bk.binding_bmk_relDiff_valid(
      a = c(1, 1), 
      theta_lowFreq = c(1, 2), 
      c_a = c(0, 1), 
      bmk_start = NA, 
      bmk_end = NA, 
      tol = gs.tolerance, 
      zero_tol = gs.tolerance)
  )
})
test_that("valid benchmark, add bench", {
  # 1 invalid binding bmk + 1 nonbinding bmk (n/a)
  expect_warning(
    bk.binding_bmk_relDiff_valid(
      a = c(1, 1), 
      theta_lowFreq = c(2, 2), 
      c_a = c(0, 1), 
      bmk_start = c("2021-1", "2021-2"), 
      bmk_end = c("2021-4", "2021-4"), 
      tol = gs.tolerance, 
      zero_tol = gs.tolerance)
  )
})


#---- Part 3 - By-group initialization functions ----

# Without BY-groups
test_that("BY-group initialization, without BY-groups", {
  expect_no_condition(
    bk.noByGrp_ini(
      series_df = data.frame(year = rep.int(1, 4), 
                             period = 1:4), 
      benchmarks_df = data.frame(startYear = 1, startPeriod = 1,
                                 endYear = 1, endPeriod = 4))
  )
})

# With BY-groups
test_that("BY-group initialization, with BY-groups", {
  expect_no_condition(
    bk.byGrp_ini(
      series_df = data.frame(grp = rep(1:2, each = 4),
                             year = rep.int(1, 8), 
                             period = rep.int(1:4, 2)), 
      benchmarks_df = data.frame(grp = 1:2,
                                 startYear = c(1, 1), startPeriod = c(1, 1),
                                 endYear = c(1, 1), endPeriod = c(4, 4)),
      by_grps = data.frame(grp = 1:2), 
      ii = 2, 
      by = "grp")
  )
})

#---- Part 4 - Negative input validation functions ----

# error for negative inputs
test_that("error for negative input, no negative input", {
  expect_equal(
    bk.check_neg_err(
      x = 0, 
      tol = gs.tolerance, 
      data_str = "input data")
  , FALSE)
})
test_that("error for negative input, negative input", {
  expect_equal(
    bk.check_neg_err(
      x = -1, 
      tol = gs.tolerance, 
      data_str = "input data")
    , TRUE)
})

# warning for negative inputs
test_that("warning for negative input, no negative input", {
  expect_equal(
    bk.check_neg_warn(
      x = 0, 
      tol = gs.tolerance, 
      data_str = "input data")
    , FALSE)
})
test_that("warning for negative input, negative input", {
  expect_warning(
    bk.check_neg_warn(
      x = -1, 
      tol = gs.tolerance, 
      data_str = "input data")
  )
})
