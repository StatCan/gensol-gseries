#devtools::test_active_file()
#devtools::test_coverage_active_file()

test_that("qtr ts", {
  expect_equal(
    unstack_tsDF(data.frame(series = c(rep("ser1", 4), rep("ser2", 4)),
                            year = rep(1, 8),
                            period = rep(1:4, 2),
                            value = rep(0, 8)))$ser1
  , rep(0, 4))
})

test_that("error: not a \"data.frame\" object", {
  expect_error(
    unstack_tsDF(ts_df = 1)
  )
})

test_that("error: missing column 'year'", {
  expect_error(
    unstack_tsDF(ts_df = data.frame(series = "x",
                                    period = 1,
                                    value = 1))
  )
})
