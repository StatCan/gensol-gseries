#devtools::test_active_file()
#devtools::test_coverage_active_file()


ser1 <- data.frame(yr = c(1, 2), per = c(1, 1), val1 = c(1, 1), val2 = c(2, NA))
test_that("custom names", {
  expect_equal(
    names(stack_tsDF(ts_df = ser1,
                     ser_cName = "ser",
                     yr_cName = "yr",
                     per_cName = "per",
                     val_cName = "val",
                     keep_NA = FALSE))
    , c("ser", "yr", "per", "val"))
})
test_that("custom names keep NA", {
  expect_equal(
    names(stack_tsDF(ts_df = ser1,
                     ser_cName = "ser",
                     yr_cName = "yr",
                     per_cName = "per",
                     val_cName = "val",
                     keep_NA = TRUE))
    , c("ser", "yr", "per", "val"))
})

test_that("error: not a \"data.frame\" object", {
  expect_error(
    stack_tsDF(ts_df = 1)
  )
})

test_that("error: missing column 'year'", {
  expect_error(
    stack_tsDF(ts_df = data.frame(period = 1,
                                  x = 1))
  )
})
