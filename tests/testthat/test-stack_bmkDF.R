#devtools::test_active_file()
#devtools::test_coverage_active_file()


bmk1 <- data.frame(yr1 = c(1, 2), per1 = c(1, 1), yr2 = c(1, 2), per2 = c(4, 4), val1 = c(1, 1), val2 = c(2, NA))
test_that("custom names", {
  expect_equal(
    names(stack_bmkDF(bmk_df = bmk1,
                      ser_cName = "ser",
                      startYr_cName = "yr1",
                      startPer_cName = "per1",
                      endYr_cName = "yr2",
                      endPer_cName = "per2",
                      val_cName = "val",
                      keep_NA = FALSE))
    , c("ser", "yr1", "per1", "yr2", "per2", "val"))
})
test_that("custom names keep NA", {
  expect_equal(
    names(stack_bmkDF(bmk_df = bmk1,
                      ser_cName = "ser",
                      startYr_cName = "yr1",
                      startPer_cName = "per1",
                      endYr_cName = "yr2",
                      endPer_cName = "per2",
                      val_cName = "val",
                      keep_NA = TRUE))
    , c("ser", "yr1", "per1", "yr2", "per2", "val"))
})

test_that("error: not a \"data.frame\" object", {
  expect_error(
    stack_bmkDF(bmk_df = 1)
  )
})

test_that("error: missing column 'startYear'", {
  expect_error(
    stack_bmkDF(bmk_df = data.frame(startYPriod = 1,
                                    endYear = 1,
                                    endPeriod = 1,
                                    x = 1,
                                    y = 1))
  )
})
