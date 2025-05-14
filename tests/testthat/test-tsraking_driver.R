#devtools::test_active_file()
#devtools::test_coverage_active_file()


# 1- Simple 1-dim raking (A + B = C)
test_str1 <- "simple 1-dim"
data1 <- ts(data.frame(A = rep(20, 4), B = rep(5, 4), C = rep(40, 4)), start = c(0, 1), frequency = 4)
meta1 <- data.frame(series = c("A", "B"), total1 = rep("C", 2))
res1 <- ts(data.frame(A = rep(32, 4), B = rep(8, 4), C = rep(40, 4)), start = c(0, 1), frequency = 4)
test_that(paste(test_str1, "correct result period-by-period"), {
  expect_equal(suppressMessages(
    tsraking_driver(data1, meta1, quiet = TRUE)
    ), res1)
})
test_that(paste(test_str1, "correct result year-by-year"), {
  expect_equal(suppressMessages(
    tsraking_driver(data1, meta1, quiet = TRUE,
                    alterAnnual = 1e6,
                    verbose = TRUE,
                    temporal_grp_periodicity = 4)
    ), res1)
})

test_that("error: `in_ts` not specified", {
  expect_error(
    tsraking_driver()
  )
})

test_that("error: `in_ts` is not a \"ts\" object", {
  expect_error(
    tsraking_driver(1)
  )
})

test_that("error: invalid `temporal_grp_periodicity` value", {
  expect_error(
    tsraking_driver(
      data1,
      meta1,
      temporal_grp_periodicity = "4")
  )
})

test_that("error: invalid `temporal_grp_start` value", {
  expect_error(
    tsraking_driver(
      data1,
      meta1,
      temporal_grp_periodicity = 4,
      temporal_grp_start = "1")
  )
  expect_error(
    tsraking_driver(
      data1,
      meta1,
      temporal_grp_periodicity = 4,
      temporal_grp_start = 5)
  )
})

test_that("error: tsraking() `metadata_df` is not specified", {
  # without dot arguments
  expect_error(
    tsraking_driver(
      data1)
  )
  # with dot arguments
  expect_error(
    tsraking_driver(
      in_ts = data1,
      quiet = TRUE)
  )
})

test_that("error: invalid tsraking() argument", {
  expect_error(
    tsraking_driver(
      data1,
      meta1,
      invalid_arg = 1)
  )
})

test_that("no named dot arg", {
  expect_equal(suppressMessages(
    tsraking_driver(data1, meta1)
  ), res1)
})

test_that("error: tsraking() `data_df` specified", {
  expect_error(
    tsraking_driver(
      data1,
      meta1,
      data_df = as.data.frame(data1))
  )
})

test_that("error: unable to match an unnamed argument to a tsraking() argument", {
  expect_error(
    tsraking_driver(
      data1,
      meta1,
      alterability_df = NULL,
      alterSeries = 1,
      alterTotal1 = 0,
      alterTotal2 = 0,
      alterAnnual = 0,
      tolV = 0.001,
      tolP = NA,
      warnNegResult = TRUE,
      tolN = -0.001,
      id = NULL,
      verbose = FALSE,
      Vmat_option = 1,
      warnNegInput = TRUE,
      quiet = FALSE,
      "extra unamed argument")
  )
})

test_that("error: `metadata_df` is not a \"data.frame\" object", {
  expect_error(
    tsraking_driver(
      data1,
      1)
  )
})

test_that("error: missing columns in `metadata_df`", {
  expect_error(
    tsraking_driver(
      data1,
      meta1[1])
  )
})

test_that("error: `alterability_df` is not a \"data.frame\" object", {
  expect_error(
    tsraking_driver(
      data1,
      meta1,
      alterability_df = 1)
  )
})

test_that("`alterability_df = NULL`", {
  expect_equal(
    tsraking_driver(
      window(data1, end = time(data1)[1]), 
      meta1, 
      alterability_df = NULL,
      quiet = TRUE)
    , window(res1, end = time(data1)[1])
  )
})

test_that("valid `alterability_df`, single row", {
  expect_equal(
    tsraking_driver(
      window(data1, end = time(data1)[1]), 
      meta1, 
      alterability_df = data.frame(A = 1, B = 1, C = 0),
      quiet = TRUE)
  , window(res1, end = time(data1)[1])
  )
})

test_that("valid `alterability_df`, nbr of rows matching the \"ts\" frequency", {
  expect_equal(suppressMessages(
    tsraking_driver(
      data1, 
      meta1, 
      alterability_df = data.frame(A = 1, B = 1, C = 0)[rep.int(1, 4), ],
      quiet = TRUE)
  ), res1
  )
})

test_that("valid `alterability_df`, nbr of rows matching the \"ts\" nbr of obs.", {
  expect_equal(suppressMessages(
    tsraking_driver(
      window(data1, start = time(data1)[1], end = time(data1)[2]), 
      meta1, 
      alterability_df = data.frame(A = 1, B = 1, C = 0)[rep.int(1, 2), ],
      quiet = TRUE)
    ), window(res1, start = time(data1)[1], end = time(data1)[2])
    )
})

test_that("error: invalid nbr of rows in `alterability_df`", {
  expect_error(
    tsraking_driver(
      window(data1, start = time(data1)[1], end = time(data1)[2]), 
      meta1, 
      alterability_df = data.frame(A = 1, B = 1, C = 0)[rep.int(1, 3), ])
  )
})

test_that("`id` argument", {
  expect_equal(
    tsraking_driver(
      ts(cbind(grp = 1, data1[1, , drop = FALSE]), start = 0, frequency = 4),
      meta1,
      id = "grp",
      quiet = TRUE)
    , ts(cbind(grp = 1, res1[1, , drop = FALSE]), start = 0, frequency = 4)
  )
})

test_that("warnings during processing", {
  
  alter_ <- data.frame(A = c(1, 1, 0, 1), 
                       B = c(1, 1, 0, 1), 
                       C = c(0, 0, 0, 0))
  
  # Multiple groups (warnings for some groups only): 2 warnings
  expect_warning(expect_warning(suppressMessages(
    tsraking_driver(
      data1, 
      meta1, 
      alterability_df = alter_,
      quiet = TRUE)
    )))
  
  # Single group (warning for that group): 1 warning
  expect_warning(suppressMessages(
    tsraking_driver(
      window(data1, start = time(data1)[3], end = time(data1)[3]), 
      meta1, 
      alterability_df = alter_[3, ],
      quiet = TRUE)
  ))
})

test_that("errors during processing", {
  
  alter_ <- data.frame(A = c(1, 1, -1, 1), 
                       B = c(1, 1,  1, 1), 
                       C = c(0, 0,  0, 0))
  
  # Multiple groups (errors for some groups only): 1 "true error" (the other one is "muted")
  expect_error(suppressMessages(
    tsraking_driver(
      data1, 
      meta1, 
      alterability_df = alter_,
      quiet = TRUE)
  ))
  
  # Single group (error)
  expect_error(
    tsraking_driver(
      window(data1, start = time(data1)[3], end = time(data1)[3]), 
      meta1, 
      alterability_df = alter_[3, ],
      quiet = TRUE)
  )
})
