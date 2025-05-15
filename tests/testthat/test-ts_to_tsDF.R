#devtools::test_active_file()
#devtools::test_coverage_active_file()

data_vec <- c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3)
my_ts <- ts(data_vec,
            start = c(2015, 1),
            frequency = 4)

test_that("qtr ts", {
  expect_equal(
    ts_to_tsDF(my_ts)$value
    , data_vec
  )
})
test_that("qtr ts, custom colnames", {
  expect_equal(
    names(ts_to_tsDF(my_ts,
                     yr_cName = "yr",
                     per_cName = "per",
                     val_cName = "val"))
  , c("yr", "per", "val"))
})

test_that("error: not a \"ts\" object", {
  expect_error(
    ts_to_tsDF(1)
  )
})

test_that("\"mts\" object", {
  expect_equal(
    names(ts_to_tsDF(cbind(x = my_ts,
                           y = my_ts)))
    , c("year", "period", "x", "y"))
})
