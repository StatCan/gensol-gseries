#devtools::test_active_file()
#devtools::test_coverage_active_file()

qtr_vec <- c(1.9, 2.4, 3.1, 2.2, 2.0, 2.6, 3.4, 2.4, 2.3)
my_qtr_ts <- ts(qtr_vec,
                start = c(2015, 1),
                frequency = 4)
ann_vec <- c(10.3, 10.2)
my_ann_ts <- ts(ann_vec,
                start = 2015,
                frequency = 1)

test_that("ann to mth", {
  expect_equal(
    ts_to_bmkDF(my_ann_ts, ind_frequency = 12)$value
    , ann_vec)
})
test_that("ann to qtr", {
  expect_equal(
    ts_to_bmkDF(my_ann_ts, ind_frequency = 4)$value
    , ann_vec
  )
})
test_that("qtr to mth", {
  expect_equal(
    ts_to_bmkDF(my_qtr_ts, ind_frequency = 12)$value
    , qtr_vec
  )
})
test_that("qtr to mth, discrete-b", {
  expect_equal(
    ts_to_bmkDF(my_qtr_ts,
                ind_frequency = 12,
                discrete_flag = TRUE)$value
    , qtr_vec
  )
})
test_that("qtr to mth, discrete-m", {
  expect_equal(
    ts_to_bmkDF(my_qtr_ts,
                ind_frequency = 12,
                discrete_flag = TRUE,
                alignment = "m")$value
    , qtr_vec
  )
})
test_that("qtr to mth, discrete-e", {
  expect_equal(
    ts_to_bmkDF(my_qtr_ts,
                ind_frequency = 12,
                discrete_flag = TRUE,
                alignment = "e")$value
    , qtr_vec
  )
})
test_that("ann to mth, April year start, custom colnames", {
  expect_equal(
    ts_to_bmkDF(my_ann_ts,
                ind_frequency = 12,
                bmk_interval_start = 4,
                startPer_cName = "p1",
                endPer_cName = "p2")[1, c("p1", "p2")]
    , data.frame(p1 = 4, p2 = 3))
})
test_that("qtr to mth, April year start, custom colnames", {
  expect_equal(
    ts_to_bmkDF(my_ann_ts,
                ind_frequency = 4,
                bmk_interval_start = 2,
                startPer_cName = "p1",
                endPer_cName = "p2")[1, c("p1", "p2")]
    , data.frame(p1 = 2, p2 = 1))
})
test_that("ann to mth, discrete-e, April year start, custom colnames", {
  expect_equal(
    ts_to_bmkDF(my_ann_ts,
                ind_frequency = 12,
                discrete_flag = TRUE,
                alignment = "e",
                bmk_interval_start = 4,
                startPer_cName = "p1",
                endPer_cName = "p2")[1, c("p1", "p2")]
    , data.frame(p1 = 3, p2 = 3))
})
test_that("qtr to mth, discrete-e, April year start, custom colnames", {
  expect_equal(
    ts_to_bmkDF(my_ann_ts,
                ind_frequency = 4,
                discrete_flag = TRUE,
                alignment = "e",
                bmk_interval_start = 2,
                startPer_cName = "p1",
                endPer_cName = "p2")[1, c("p1", "p2")]
    , data.frame(p1 = 1, p2 = 1))
})

test_that("error: not a \"ts\" object", {
  expect_error(
    ts_to_bmkDF(1)
  )
})

test_that("\"mts\" object", {
  expect_equal(
    ts_to_bmkDF(cbind(x = my_ann_ts,
                      y = my_ann_ts), 
                ind_frequency = 12)$x
    , ann_vec)
})
