#devtools::test_active_file()
#devtools::test_coverage_active_file()


#---- Part 1 - generic functions ----

test_that("`gs.FALSE_func()`", {
  expect_equal(
    gs.FALSE_func()
    , FALSE)
})
test_that("`gs.NULL_func()`", {
  expect_equal(
    gs.NULL_func()
    , NULL)
})
test_that("`gs.passThrough_func()`", {
  expect_equal(
    gs.passThrough_func("test")
    , "test")
})


#---- Part 2 - Generic calculation functions ----

test_that("`gs.calc_ratio()`", {
  expect_equal(
    gs.calc_ratio(
      x = 1, 
      y = 1, 
      tol = gs.tolerance)
    , 1)
})
test_that("`gs.calc_diff()`", {
  expect_equal(
    gs.calc_diff(
      x = 1, 
      y = 1)
    , 0)
})
test_that("`gs.calc_relDiff()`", {
  expect_equal(
    gs.calc_relDiff(
      x = 1, 
      y = 1, 
      tol = gs.tolerance)
    , 0)
})
test_that("`gs.calc_firstDiff()`", {
  expect_equal(
    gs.calc_firstDiff(
      x = c(1, 1))
    , c(NA, 0))
})
test_that("`gs.calc_relFirstDiff()`", {
  expect_equal(
    gs.calc_relFirstDiff(
      x = c(1, 1),
      tol = gs.tolerance)
    , c(NA, 0))
})


#---- Part 3 - Date validation functions ----

test_that("`gs.check_alter()`, all valid", {
  expect_equal(
    gs.check_alter(
      x = 0)
    , FALSE)
})
test_that("`gs.check_alter()`, some invalid", {
  expect_equal(
    gs.check_alter(
      x = c(0, -1))
    , TRUE)
})
test_that("`gs.check_neg()`, all valid", {
  expect_equal(
    gs.check_neg(
      x = 0,
      tol = gs.tolerance)
    , FALSE)
})
test_that("`gs.check_neg()`, some invalid", {
  expect_equal(
    gs.check_neg(
      x = c(0, -1),
      tol = gs.tolerance)
    , TRUE)
})


#---- Part 4 - Moore-Penrose inverse function ----

#gs.gInv_MP <- function(X, tol = NA)
test_that("`gs.gInv_MP()`, `tol` is `NA`", {
  expect_equal(
    gs.gInv_MP(
      X = as.matrix(2),
      tol = NA)
    , as.matrix(0.5))
})
test_that("`gs.gInv_MP()`, `tol` is not `NA`", {
  expect_equal(
    gs.gInv_MP(
      X = as.matrix(2),
      tol = gs.tolerance)
    , as.matrix(0.5))
})


#---- Part 5 - Processing groups function ----

ts1 <- ts(rep.int(1, 4), start = 2021, frequency = 4)
test_that("`gs.build_proc_grps()`, period-by-period processing", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts1),
      ts_per_vec = gs.time2per(ts1),
      n_per = length(ts1),
      ts_freq = frequency(ts1),
      temporal_grp_periodicity = 1,
      temporal_grp_start = 1)
    , data.frame(grp = 1:4,
                 beg_per = 1:4,
                 end_per = 1:4,
                 complete_grp = rep.int(FALSE, 4)))
})
test_that("`gs.build_proc_grps()`, 1 complete yearly group", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts1),
      ts_per_vec = gs.time2per(ts1),
      n_per = length(ts1),
      ts_freq = frequency(ts1),
      temporal_grp_periodicity = frequency(ts1),
      temporal_grp_start = 1)
    , data.frame(grp = 1L,
                 beg_per = 1L,
                 end_per = 4L,
                 complete_grp = TRUE))
})
ts2 <- ts(rep.int(1, 8), start = 2021, frequency = 4)
test_that("`gs.build_proc_grps()`, 2 complete yearly groups", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts2),
      ts_per_vec = gs.time2per(ts2),
      n_per = length(ts2),
      ts_freq = frequency(ts2),
      temporal_grp_periodicity = frequency(ts2),
      temporal_grp_start = 1)
    , data.frame(grp = 1:2,
                 beg_per = c(1L, 5L),
                 end_per = c(4L, 8L),
                 complete_grp = c(TRUE, TRUE)))
})
ts3 <- ts(rep.int(1, 6), start = c(2021, 4), frequency = 4)
test_that("`gs.build_proc_grps()`, 3 yearly groups, 1st and 3rd groups incomplete", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts3),
      ts_per_vec = gs.time2per(ts3),
      n_per = length(ts3),
      ts_freq = frequency(ts3),
      temporal_grp_periodicity = frequency(ts3),
      temporal_grp_start = 1)
    , data.frame(grp = 1:3,
                 beg_per = c(1L, 2L, 6L),
                 end_per = c(1L, 5L, 6L),
                 complete_grp = c(FALSE, TRUE, FALSE)))
})
test_that("`gs.build_proc_grps()`, groups shoter than a year", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts1),
      ts_per_vec = gs.time2per(ts1),
      n_per = length(ts1),
      ts_freq = frequency(ts1),
      temporal_grp_periodicity = 2,
      temporal_grp_start = 1)
    , data.frame(grp = 1:2,
                 beg_per = c(1L, 3L),
                 end_per = c(2L, 4L),
                 complete_grp = c(TRUE, TRUE)))
})
test_that("`gs.build_proc_grps()`, groups longer than a year", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts2),
      ts_per_vec = gs.time2per(ts2),
      n_per = length(ts2),
      ts_freq = frequency(ts2),
      temporal_grp_periodicity = 8,
      temporal_grp_start = 5)
    , data.frame(grp = 1L,
                 beg_per = 1L,
                 end_per = 8L,
                 complete_grp = TRUE))
})
test_that("`gs.build_proc_grps()`, groups > year, no occurrrence of the gourp start", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts1),
      ts_per_vec = gs.time2per(ts1),
      n_per = length(ts1),
      ts_freq = frequency(ts1),
      temporal_grp_periodicity = 5,
      temporal_grp_start = 1)
    , data.frame(grp = 1:4,
                 beg_per = 1:4,
                 end_per = 1:4,
                 complete_grp = rep.int(FALSE, 4)))
})
test_that("`gs.build_proc_grps()`, groups > year, no extra years", {
  expect_equal(
    gs.build_proc_grps(
      ts_yr_vec = gs.time2year(ts1),
      ts_per_vec = gs.time2per(ts1),
      n_per = length(ts1),
      ts_freq = 12,
      temporal_grp_periodicity = 24,
      temporal_grp_start = 5)
    , data.frame(grp = 1:4,
                 beg_per = 1:4,
                 end_per = 1:4,
                 complete_grp = rep.int(FALSE, 4)))
})


#---- Part 6 - Other utility functions ----

test_that("`gs.cleanup_col_list()`", {
  expect_equal(
    gs.cleanup_col_list(
      str_vec = c(NA_character_, "x", "  y  ", ""))
    , c("x", "y"))
})

test_that("`gs.display_difftime()`", {
  expect_no_condition(suppressMessages(
    gs.display_difftime(
      time1 = Sys.time(), 
      time2 = Sys.time() + 1, 
      label = "")
    ))
})

test_that("`gs.display_obj()`, `str()`, no title", {
  expect_no_condition(
    gs.display_obj(
      x = 1:10, 
      title = NA, 
      head = FALSE, 
      str = TRUE)
    )
})
test_that("`gs.display_obj()`, no `str()`, title", {
  expect_no_condition(
    gs.display_obj(
      x = 1:10, 
      title = "title", 
      head = FALSE, 
      str = FALSE)
  )
})
test_that("`gs.display_obj()`, no `str()`, no title, `head()`", {
  expect_no_condition(
    gs.display_obj(
      x = 1:10, 
      title = NA, 
      head = TRUE, 
      str = FALSE)
  )
})

test_that("`gs.split_str()`", {
  expect_equal(
    gs.split_str(
      pattern = "-", 
      str = "x-y")
    , list("x", "y"))
})

test_that("`gs.time2str()`, qtr data, 2021-1 to 2021-4", {
  expect_equal(
    gs.time2str(
      ts = ts(rep.int(NA_real_, 4), start = 2021, frequency = 4), 
      sep = "-")
    , paste(2021, 1:4, sep = "-"))
})
test_that("`gs.time2str()`, annual data, 2021 to 2024", {
  expect_equal(
    gs.time2str(
      ts = ts(rep.int(NA_real_, 4), start = 2021, frequency = 1), 
      sep = "-")
    , as.character(2021:2024))
})

#gs.validate_cols <- function(cols, against, df_name, source_str = NA)
test_that("`gs.validate_cols()`, no missing cols", {
  expect_equal(
    gs.validate_cols(
      cols = letters[2:4], 
      against = letters[1:5], 
      df_name = "", 
      source_str = NA)
    , NULL)
})
test_that("`gs.validate_cols()`, missing cols, without `source_str`", {
  expect_error(
    gs.validate_cols(
      cols = "z", 
      against = letters[1:5], 
      df_name = "df", 
      source_str = NA)
    )
})
test_that("`gs.validate_cols()`, missing cols, without `source_str`", {
  expect_error(
    gs.validate_cols(
      cols = "z", 
      against = letters[1:5], 
      df_name = "df", 
      source_str = "argument 'var'")
  )
})
