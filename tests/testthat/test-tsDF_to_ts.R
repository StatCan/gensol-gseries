#devtools::test_active_file()
#devtools::test_coverage_active_file()

test_that("qtr ts", {
  expect_equal(
    tsDF_to_ts(data.frame(year = rep(1, 4), period = 1:4, value = rep(0, 4)),
               frequency = 4)
  , ts(rep(0, 4), start = 1, frequency = 4)
  )
})


test_that("error: not a \"data.frame\" object", {
  expect_error(
    tsDF_to_ts(ts_df = 1)
  )
})

test_that("error: missing column 'year'", {
  expect_error(
    tsDF_to_ts(ts_df = data.frame(period = 1,
                                  value = 1))
  )
})

test_that("error: no numeric columns", {
  
  # Character column
  expect_error(
    tsDF_to_ts(ts_df = data.frame(year = rep(1, 4), 
                                  period = 1:4, 
                                  value = rep("0", 4)),
               frequency = 4)
  )
  
  # No "data" column (only the date columns)
  expect_error(
    tsDF_to_ts(ts_df = data.frame(year = rep(1, 4), 
                                  period = 1:4),
               frequency = 4)
  )
})

test_that("error: empty data frame (0 observation)", {
  expect_error(
    tsDF_to_ts(data.frame(year = integer(0L), 
                          period = integer(0L), 
                          value = integer(0L)),
               frequency = 4)
  )
})
