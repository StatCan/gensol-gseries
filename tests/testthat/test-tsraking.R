#devtools::test_active_file()
#devtools::test_coverage_active_file()


# Note: these tests also cover script `aliases.R`


# 1- Simple 1-dim raking (A + B = C)
test_str1 <- "simple 1-dim"
data1 <- data.frame(A = 20, B = 5, C = 40)
meta1 <- data.frame(series = c("A", "B"), total1 = rep("C", 2))
raked1 <- data.frame(A = 32, B = 8, C = 40)
test_that(paste(test_str1, "correct result"), {
  expect_equal(
    tsraking(data1, meta1, quiet = TRUE)
    , raked1)
  expect_equal(
    proc_tsraking(data1, meta1, quiet = TRUE)
    , raked1)
})


# 2- Binding totals not met (all component series are binding)
data2 <- data.frame(A = 0, B = 0, C = 1)
test_that(paste("warning: binding totals not met"), {
  expect_warning(
    tsraking(data2, meta1, quiet = TRUE)
    )
})


# 3- Negative values
test_str3 <- "negative values"
data3 <- data.frame(A = 3, B = -1, C = 1)
raked3a <- data.frame(A = 1.5, B = -0.5, C = 1)
raked3b <- data.frame(A = 2.25, B = -1.25, C = 1)
test_that(paste(test_str3, "warning input"), {
  expect_warning(
    tsraking(data3,
             meta1,
             warnNegResult = FALSE,
             quiet = TRUE)
    )
})
test_that(paste(test_str3, "warning output"), {
  expect_warning(
    tsraking(data3,
             meta1,
             warnNegInput = FALSE,
             quiet = TRUE)
    )
})
test_that(paste(test_str3, "correct result Vmat=1"), {
  expect_equal(
    tsraking(data3,
             meta1,
             warnNegResult = FALSE,
             warnNegInput = FALSE,
             quiet = TRUE)
    , raked3a)
})
test_that(paste(test_str3, "correct result Vmat=2"), {
  expect_equal(
    tsraking(data3,
             meta1,
             warnNegResult = FALSE,
             Vmat_option = 2,
             warnNegInput = FALSE,
             quiet = TRUE)
    , raked3b)
})

test_that("error: invalid `quiet` value", {
  expect_error(
    tsraking(
      data1,
      meta1,
      quiet = "a")
  )
})

test_that("`quiet = FALSE`", {
  expect_equal(suppressMessages(
    tsraking(
      data1, 
      meta1)
    ), raked1)
})

test_that("error: `data_df` not specified", {
  expect_error(
    tsraking(quiet = TRUE)
  )
})

test_that("long `data_df` argument value", {
  expect_equal(
    tsraking(
      data.frame(A = 20, B = 5, C = 40, 
                 very_very_very_very_very_very_long_column_name = 0), 
      meta1,
      quiet = TRUE)
  , raked1)
})

test_that("`data_df`, `metadata_df` and `alterability_df` passed as a \"structure\"", {
  expect_equal(suppressMessages(
    do.call(
      "tsraking",
      list(
        data1, 
        meta1,
        data.frame(A = 1, B = 1, C = 0)))
    ), raked1)
})

test_that("error: `data_df` is not a \"data.frame\" object", {
  expect_error(
    tsraking(1, quiet = TRUE)
  )
})

test_that("error: `metadata_df` not specified", {
  expect_error(
    tsraking(data1, quiet = TRUE)
  )
})

test_that("error: `metadata_df` is not a \"data.frame\" object", {
  expect_error(
    tsraking(data1, 1, quiet = TRUE)
  )
})

test_that("`alterability_df = NA` (nomal processing)", {
  expect_equal(
    tsraking(
      data1, 
      meta1,
      alterability_df = NA,
      quiet = TRUE)
  , raked1)
})

test_that("warning: `alterability_df` is not a \"data.frame\" object", {
  expect_warning(
    tsraking(
      data1, 
      meta1,
      alterability_df = 1,
      quiet = TRUE)
  )
})

test_that("empty `alterability_df`", {
  expect_equal(
    tsraking(
      data1, 
      meta1,
      alterability_df = data.frame(A = 1, B = 1, C = 0)[0, , drop = FALSE],
      quiet = TRUE)
    , raked1)
})

test_that("warning: invalid nbr of rows in `alterability_df`", {
  expect_warning(
    tsraking(
      data1, 
      meta1,
      alterability_df = data.frame(A = 1, B = 1, C = 0)[c(1, 1), ],
      quiet = TRUE)
  )
})

test_that("single row `alterability_df` when nbr of period > 1", {
  res <- raked1[c(1, 1), ]
  row.names(res) <- NULL
  expect_equal(
    tsraking(
      data1[c(1, 1), ], 
      meta1,
      alterability_df = data.frame(A = 1, B = 1, C = 0),
      alterAnnual = 1,
      quiet = TRUE)
  , res
  )
})

test_that("error: invalid alter coef argument values", {
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, alterSeries = -1)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, alterTotal1 = -1)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, alterTotal2 = -1)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, alterAnnual = -1)
  )
})

test_that("error: invalid tolerance argument values", {
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             tolV = -1)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             tolV = NA, tolP = -1)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             tolV = 10, tolP = 1)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             tolV = NULL, tolP = NA)
  )
  expect_no_condition(
    tsraking(data1, meta1, quiet = TRUE, 
             tolV = NULL, tolP = 0.1)
  )
  expect_no_condition(
    tsraking(data1, meta1, quiet = TRUE, 
             tolV = 0.1, tolP = NULL)
  )
})

test_that("error: invalid logtical argument values", {
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             warnNegResult = NULL)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             verbose = NA)
  )
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             warnNegInput = "a")
  )
})

test_that("error: invalid `tolN` value", {
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             tolN = 0.1)
  )
})

test_that("error: invalid `Vmat_option` value", {
  expect_error(
    tsraking(data1, meta1, quiet = TRUE, 
             Vmat_option = -1)
  )
})

test_that("`id`", {
  expect_equal(
    tsraking(
      cbind(data1, data.frame(x = "x", y = "y")), 
      meta1,
      id = c("x", "y"),
      quiet = TRUE)
    , cbind(raked1, data.frame(x = "x", y = "y")))
})

test_that("`verbose = TRUE`", {
  expect_equal(suppressMessages(
    tsraking(
      data1, 
      meta1,
      verbose = TRUE)
    ), raked1
  )
})

test_that("error: invalid data or alter values", {
  data_ <- data1
  data_$A <- NA
  expect_error(
    tsraking(data_, meta1, quiet = TRUE)
  )
  expect_error(
    tsraking(data1, meta1,
             alterability_df = data.frame(A = 1, B = NA, C = 0),
             quiet = TRUE)
  )
})

test_that("temporal total alter coefs in the metadata", {
  expect_no_condition(
    tsraking(
      data1[c(1, 1), ], 
      cbind(meta1, data.frame(alterAnnual = c(1, 1))),
      quiet = TRUE)
  )
  expect_error(
    tsraking(
      data1[c(1, 1), ], 
      cbind(meta1, data.frame(alterAnnual = c(1, -1))),
      quiet = TRUE)
  )
})


#---- 2-dim problem ----

meta2dim <- data.frame(series = c("A_1", "B_1",
                                  "A_2", "B_2",
                                  "A_3", "B_3"),
                       total1 = c("_1", "_1",
                                  "_2", "_2",
                                  "_3", "_3"), 
                       total2 = rep(c("A", "B"), 3),
                       alterAnnual = rep.int(0, 6))
data2dim <- as.data.frame(matrix(c(12, 14, 13, 20, 20, 24, 40, 53, 30, 31, 32,
                                   10,  9, 15, 21, 29, 20, 25, 80, 35, 35, 35,
                                   12,  8, 17, 15, 20, 30, 40, 59, 23, 32, 44,
                                   9,  9, 14, 17, 24, 23, 37, 71, 28, 35, 45),
                                 nrow = 4,
                                 byrow = TRUE,
                                 dimnames = list(NULL, c("A_1", "A_2", "A_3", 
                                                         "B_1", "B_2", "B_3", 
                                                         "A", "B", "_1", "_2", "_3"))))

test_that("all components binding message (warning: binding totals not met)", {
  # Single obs
  expect_warning(suppressMessages(
    tsraking(
      data2dim[1, , drop = FALSE], 
      meta2dim,
      alterability_df = data.frame(A_1 = 0, B_1 = 0))
  ))
  # Several obs
  expect_warning(suppressMessages(
    tsraking(
      data2dim, 
      meta2dim,
      alterability_df = data.frame(A_1 = 0, B_1 = 0))
    ))
  
  # Fully fixed problem - Single obs
  expect_warning(suppressMessages(
    tsraking(
      data2dim[1, , drop = FALSE], 
      meta2dim,
      alterSeries = 0)
  ))
  # Fully fixed problem - Several obs
  expect_warning(suppressMessages(
    tsraking(
      data2dim, 
      meta2dim,
      alterSeries = 0)
  ))
})

test_that("unsolvable problem with netagive values (4 warnings: neg input, unsolvable problem, neg output, binding totals not met)", {
  data <- data.frame(a = 1, b = -1, c = 1)
  res <- data
  res$c <- 0
  expect_warning(expect_warning(expect_warning(expect_warning(
    tsraking(
      data, 
      data.frame(series = c("a", "b"), total1 = c("c", "c")),
      quiet = TRUE)
  ))))
})

test_that("initial solution (no discrepancies)", {
  data <- data.frame(a = 1, b = 1, c = 2)
  res <- data
  expect_equal(
    tsraking(
      data, 
      data.frame(series = c("a", "b"), total1 = c("c", "c")),
      quiet = TRUE)
  , res)
})


test_that("error: invalid values in `metadata_df`", {
  expect_error(
    tsraking(
      data.frame(a = 1, b = 1, c = 2), 
      data.frame(series = c(" ", "b"), total1 = c("c", "c")),
      quiet = TRUE)
  )
  expect_error(
    tsraking(
      data.frame(a = 1, b = 1, c = 2), 
      data.frame(series = c("b", "b"), total1 = c("c", "c")),
      quiet = TRUE)
  )
  expect_error(
    tsraking(
      data.frame(a = 1, b = 1, c = 2), 
      data.frame(series = c("a", "b"), total1 = c(NA, "c")),
      quiet = TRUE)
  )
  expect_error(
    tsraking(
      data.frame(a = 1, b = 1, c = 2, d = 0), 
      data.frame(series = c("a", "b"), total1 = c("d", "c")),
      quiet = TRUE)
  )
  
  meta_ <- meta2dim
  meta_$total2[4] <- ""
  expect_error(
    tsraking(
      data2dim[1, , drop = FALSE], 
      meta_,
      quiet = TRUE)
  )
  meta_ <- meta2dim
  meta_$total2 <- "A"
  expect_error(
    tsraking(
      data2dim[1, , drop = FALSE], 
      meta_,
      quiet = TRUE)
  )
  meta_ <- meta2dim
  meta_$total2[4] <- "A"
  expect_error(
    tsraking(
      data2dim[1, , drop = FALSE], 
      meta_,
      quiet = TRUE)
  )
  data_ <- data2dim
  data_$C <- 0
  meta_ <- meta2dim
  meta_$total2[4] <- "C"
  expect_error(
    tsraking(
      data_[1, , drop = FALSE], 
      meta_,
      quiet = TRUE)
  )
})

test_that("empty `total2", {
  expect_equal(
    tsraking(
      data.frame(a = 1, b = 1, c = 4), 
      data.frame(series = c("a", "b"), total1 = c("c", "c"), total2 = c("", "")),
      quiet = TRUE)
  , data.frame(a = 2, b = 2, c = 4))
})

test_that("binding totals not met with `tolP` (warning)", {
  expect_warning(
    tsraking(data1,
             meta1,
             alterSeries = 0,
             tolV = NA, tolP = 1e-6,
             quiet = TRUE)
  )
})

test_that("empty input series data frame", {
  expect_equal(
    tsraking(data1[0, ],
             meta1,
             quiet = TRUE)
    , data1[0, ])
})

test_that("error: empty input metadata data frame", {
  expect_error(
    tsraking(data1,
             meta1[0, ],
             quiet = TRUE)
    )
})
