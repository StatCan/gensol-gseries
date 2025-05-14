#devtools::test_active_file()
#devtools::test_coverage_active_file()


# Note: these tests also cover script `aliases.R`


test_str1 <- "additive Denton"
ind1 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(0, 4))
bmk1 <- data.frame(startYear = 0, startPeriod = 1, endYear = 0, endPeriod = 4, value = 4)
res1 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(1, 4))
test_that(paste(test_str1, "correct result"), {
  expect_equal(
    # `bias_option = 1`
    benchmarking(ind1, bmk1,
                 rho = 1, lambda = 0, biasOption = 1,
                 quiet = TRUE)$series
    , res1)
  # alias, `bias_option = 2`
  expect_equal(
    proc_benchmarking(ind1, bmk1,
                      rho = 1, lambda = 0, biasOption = 2,
                      quiet = TRUE)$series
    , res1)
  # `bias_option = 3`
  expect_equal(
    benchmarking(ind1, bmk1,
                 rho = 1, lambda = 0, biasOption = 3,
                 quiet = TRUE)$series
    , res1)
  # by-groups (2 groups)
  expect_equal(
    suppressMessages(
      benchmarking(cbind(data.frame(grp = rep(c(1, 2), each = nrow(ind1))),
                         rep(ind1[rep(seq_len(nrow(ind1)), 2), ])), 
                   cbind(data.frame(grp = rep(c(1, 2), each = nrow(bmk1))),
                         rep(bmk1[rep(seq_len(nrow(bmk1)), 2), ])),
                   rho = 1, lambda = 0, biasOption = 1, 
                   by = "grp",
                   quiet = TRUE))$series
    , cbind(data.frame(grp = rep(c(1, 2), each = nrow(res1))),
            rep(res1[rep(seq_len(nrow(res1)), 2), ])))
})


test_str2 <- "proportional Denton"
ind2 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(1, 4))
bmk2 <- data.frame(startYear = 0, startPeriod = 1, endYear = 0, endPeriod = 4, value = 2)
res2 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(0.5, 4))
test_that(paste(test_str2, "correct result"), {
  expect_equal(
    # `bias_option = 1`
    benchmarking(ind2, bmk2,
                 rho = 1, lambda = 1, biasOption = 1,
                 quiet = TRUE)$series
    , res2)
  # `bias_option = 2`
  expect_equal(
    benchmarking(ind2, bmk2,
                 rho = 1, lambda = 1, biasOption = 2,
                 quiet = TRUE)$series
    , res2)
  # `bias_option = 3`
  expect_equal(
    benchmarking(ind2, bmk2,
                 rho = 1, lambda = 1, biasOption = 3,
                 quiet = TRUE)$series
    , res2)
})


test_str3 <- "additive benchmarking"
ind3 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(0, 4))
bmk3 <- data.frame(startYear = 0, startPeriod = 1, endYear = 0, endPeriod = 4, value = 4)
test_that(paste(test_str3, "correct result"), {
  expect_equal(
    sum(benchmarking(ind3, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 1,
                     quiet = TRUE)$series$value)
    , bmk3$value)
})


test_str4 <- "proportional benchmarking"
ind4 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(1, 4))
bmk4 <- data.frame(startYear = 0, startPeriod = 1, endYear = 0, endPeriod = 4, value = 2)
test_that(paste(test_str4, "no condition"), {
  expect_equal(
    sum(benchmarking(ind4, bmk4,
                     rho = 0.729, lambda = 1, biasOption = 1,
                     quiet = TRUE)$series$value)
    , bmk4$value)
})


test_str5 <- "proportional Denton negative"
ind5 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(-1, 4))
bmk5 <- data.frame(startYear = 0, startPeriod = 1, endYear = 0, endPeriod = 4, value = -2)
res5 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(-0.5, 4))
test_that(paste(test_str5, "`negInput_option = 0` (default): error"), {
  expect_error(
    benchmarking(ind5, bmk5,
                 rho = 1, lambda = 1, biasOption = 1,
                 warnNegResult = FALSE,
                 negInput_option = 0,
                 quiet = TRUE)
    )
})
test_that(paste(test_str5, "`negInput_option = 1`: 2 warnings (indicators and benchmarks)"), {
  expect_warning(expect_warning(
    benchmarking(ind5, bmk5,
                 rho = 1, lambda = 1, biasOption = 1,
                 warnNegResult = FALSE,
                 negInput_option = 1,
                 quiet = TRUE)
  ))
})
test_that(paste(test_str5, "`negInput_option = 2`: ignore the neg. values (correct results)"), {
  expect_equal(
    benchmarking(ind5, bmk5,
                 rho = 1, lambda = 1, biasOption = 1,
                 warnNegResult = FALSE,
                 negInput_option = 2,
                 quiet = TRUE)$series
    , res5)
})


test_str6 <- "proportional benchmarking negative"
ind6 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(-1, 4))
bmk6 <- data.frame(startYear = 0, startPeriod = 1, endYear = 0, endPeriod = 4, value = -2)
test_that(paste(test_str6, "`negInput_option = 0` (default): error"), {
  expect_error(
    benchmarking(ind6, bmk6,
                 rho = 0.729, lambda = 1, biasOption = 1,
                 warnNegResult = FALSE,
                 negInput_option = 0,
                 quiet = TRUE)
  )
})
test_that(paste(test_str6, "`negInput_option = 1`: 2 warnings (indicators and benchmarks)"), {
  expect_warning(expect_warning(
    benchmarking(ind6, bmk6,
                 rho = 0.729, lambda = 1, biasOption = 1,
                 warnNegResult = FALSE,
                 negInput_option = 1,
                 quiet = TRUE)
  ))
})
test_that(paste(test_str6, "`negInput_option = 2`: ignore the neg. values (correct results)"), {
  expect_equal(
    sum(benchmarking(ind6, bmk6,
                     rho = 0.729, lambda = 1, biasOption = 1,
                     warnNegResult = FALSE,
                     negInput_option = 2,
                     quiet = TRUE)$series$value)
    , bmk6$value)
})

test_that("error: invalid `quiet` value", {
  expect_error(
    benchmarking(
      ind1, bmk1,
      rho = 0.729, lambda = 0, biasOption = 3,
      quiet = "a")
  )
})

test_that("`quiet = FALSE`", {
  expect_equal(suppressMessages(
    sum(benchmarking(ind3, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 1,
                     quiet = FALSE)$series$value)
    ), bmk3$value)
})

test_that("error: `series_df` not specified", {
  expect_error(
    benchmarking(benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("error: `series_df` is not a \"data.frame\" object", {
  expect_error(
    benchmarking(1,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("`series_df` and `benchmarks_df` passed as a \"structure\"", {
  expect_equal(
    sum(do.call("benchmarking",
                list(ind3, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 1,
                     quiet = TRUE))$series$value)
  , bmk3$value)
})

test_that("error: `benchmarks_df` not specified", {
  expect_error(
    benchmarking(series_df = ind3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("error: `benchmarks_df` is not a \"data.frame\" object", {
  expect_error(
    benchmarking(series_df = ind3,
                 1,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("error: `rho` not specified", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("error: `rho` is invalid", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = -1, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("error: `lambda` not specified", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("error: `lambda` is invalid", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = NA, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("error: `biasOption` not specified", {
  # Non-denton bench (not allowed)
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0,
                 quiet = TRUE)
  )
  # Denton bench (allowed)
  expect_equal(
    sum(benchmarking(ind3, bmk3,
                     rho = 1, lambda = 0,
                     quiet = TRUE)$series$value)
  , bmk3$value)
})

test_that("error: `biasOption` is invalid", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 0,
                 quiet = TRUE)
  )
})

test_that("`bias` validation", {
  
  # error: invalid `bias`
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 bias = Inf,
                 quiet = TRUE)
  )
  
  # error: invalid `bias` when `lambda = 1`
  expect_error(
    benchmarking(series_df = ind4,
                 benchmarks_df = bmk4,
                 rho = 0.729, lambda = 1, biasOption = 1,
                 bias = -1,
                 quiet = TRUE)
  )
  
  # normal: `bias` is NULL (allowed: same as `NA`)
  expect_equal(
    sum(benchmarking(ind3, bmk3,
                     rho = 1, lambda = 0,
                     bias = NULL,
                     quiet = TRUE)$series$value)
    , bmk3$value)
  
  # normal: user-specified bias
  expect_equal(
    sum(benchmarking(ind3, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 2,
                     bias = 2,
                     quiet = TRUE)$series$value)
    , bmk3$value)
})

test_that("`tolV` and `tolP` validation", {
  # Invalid `tolV`
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 tolV = -1,
                 quiet = TRUE)
  )
  # `tolV` is NULL (allowed: same as `NA`)
  expect_equal(
    sum(benchmarking(ind3, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 1,
                     tolV = NULL, tolP = 1e-6,
                     quiet = TRUE)$series$value)
    , bmk3$value)
  
  # Invalid `tolP`
  expect_error(
    benchmarking(series_df = ind4,
                 benchmarks_df = bmk4,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 tolV = NA, tolP = Inf,
                 quiet = TRUE)
  )
  # `tolP` is NULL (allowed: same as `NA`)
  expect_equal(
    sum(benchmarking(ind3, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 1,
                     tolP = NULL,
                     quiet = TRUE)$series$value)
    , bmk3$value)
  
  # `tolV` and `tolP` both specified
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 tolV = 1e-3, tolP = 1e-6,
                 quiet = TRUE)
  )
  
  # `tolV` and `tolP` both unspecified (`NA`)
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 tolV = NA,
                 quiet = TRUE)
  )
})

test_that("`warnNegResult` validation", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 warnNegResult = NA,
                 quiet = TRUE)
  )
})

test_that("`tolN` validation", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 tolN = 1,
                 quiet = TRUE)
  )
})

test_that("`verbose` validation", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 verbose = NA,
                 quiet = TRUE)
  )
})

test_that("`constant` validation", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 constant = "1",
                 quiet = TRUE)
  )
})

test_that("`negInput_option` validation", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 negInput_option = 3,
                 quiet = TRUE)
  )
})

test_that("`allCols` validation", {
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 allCols = c(FALSE, FALSE),
                 quiet = TRUE)
  )
})

test_that("`verbose` display", {
  expect_equal(suppressMessages(
    sum(benchmarking(ind3, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 1,
                     verbose = TRUE,
                     quiet = FALSE)$series$value)
    ), bmk3$value)
})

test_that("invalid input data", {
  # missing "year" in `series_df`
  expect_error(
    benchmarking(series_df = ind3[-1],
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
  # missing "endPeriod" in `benchmarks_df`
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk3[-4],
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )

  # negative value `series_df` with `lambda = 1`
  ind_ <- ind4
  ind_$value[2] <- -1
  expect_error(suppressMessages(
    benchmarking(series_df = ind_,
                 benchmarks_df = bmk4,
                 rho = 0.729, lambda = 1, biasOption = 1,
                 quiet = TRUE)
  ))
  
  # warning: missing input series data
  ind_ <- ind3
  ind_$value[2] <- NA
  expect_warning(
    benchmarking(series_df = ind_,
                 benchmarks_df = bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)$graphTable
  )
  
  # error: non-contiguous periods
  # (`NULL` graphTable output data frame)
  expect_error(
    benchmarking(ind3[-2, ],
                 bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
  
  # error: benchmark coverage issue
  # (`NULL` graphTable output data frame)
  bmk_ <- bmk3
  bmk_[c("startYear", "endYear")] <- 1
  expect_error(
    benchmarking(ind3,
                 bmk_,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
  
  # error: invalid periods in series data
  ind_ <- ind3
  ind_$year <- NA
  expect_error(
    benchmarking(ind_, bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
  
  # error: invalid periods in series data
  bmk_ <- bmk3
  bmk_$startYear <- NA
  expect_error(
    benchmarking(ind3, bmk_,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
  )
})

test_that("zeros validation", {
  # error: "all zero" indicator series with `lambda = 1` and `rho = 1`
  # (`NULL` graphTable output data frame)
  expect_error(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk4,
                 rho = 1.0, lambda = 1,
                 quiet = TRUE)
  )
  
  # 2 warnings: nonzero benchmark associated to "all zero" indicator series with `lambda = 1`
  expect_warning(expect_warning(
    benchmarking(series_df = ind3,
                 benchmarks_df = bmk4,
                 rho = 0.729, lambda = 1, biasOption = 1,
                 quiet = TRUE)
  ))
})

test_that("no initial discrepancies", {
  ind_ <- ind3
  ind_$value <- 1
  expect_equal(
    sum(benchmarking(ind_, bmk3,
                     rho = 0.729, lambda = 0, biasOption = 1,
                     quiet = TRUE)$series$value)
  , bmk3$value)
})

test_that("negative results (warning)", {
  ind_ <- ind3
  ind_$value[c(1, 4)] <- 1
  bmk_ <- bmk3
  bmk_$value <- 0
  expect_warning(
    benchmarking(ind_, bmk_,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE)
)
})

test_that("alter coefs", {
  # error: invalid series alter coef 
  #(`NULL` graphTable output data frame)
  ind_ <- ind3
  ind_$alter <- c(1, -1, 1, 1)
  expect_error(
    benchmarking(ind_,
                 bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 var = "value / alter",
                 quiet = TRUE)
  )
  
  # error: invalid benchmark alter coef 
  #(`NULL` graphTable output data frame)
  bmk_ <- bmk3
  bmk_$alter <- NA
  expect_error(
    benchmarking(ind3,
                 bmk_,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 with = "value / alter",
                 quiet = TRUE)
  )
  
  # warning: aler coefs with `rho = 1`
  ind_ <- ind3
  ind_$alter <- 1
  bmk_ <- bmk3
  bmk_$alter <- 0
  expect_warning(
    benchmarking(ind_, bmk_,
                 rho = 1.0, lambda = 0,
                 var = "value / alter", with = "value / alter",
                 quiet = TRUE)
  )
  
  # non-default alter coefs (normal)
  ind_ <- ind3
  ind_$alter <- c(1, 1, 0.9, 1)
  expect_equal(
    sum(benchmarking(ind_, bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 var = "value / alter",
                 quiet = TRUE)$series$value)
  , bmk3$value)
})

test_that("`var` and `with`", {
  expect_error(
    benchmarking(ind3, bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 var = "value / alter / blabla",
                 quiet = TRUE)
    )
  expect_error(
    benchmarking(ind3, bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 with = "value / alter / blabla",
                 quiet = TRUE)
  )
  bmk_ <- bmk3
  bmk_$alter <- 0
  expect_error(
    benchmarking(ind3, bmk_,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 with = c("value", "alter"),
                 quiet = TRUE)
  )
})

test_that("`all_cols`", {
  expect_equal(
  sum(benchmarking(ind3, bmk3,
                   rho = 0.729, lambda = 0, biasOption = 1,
                   allCols = TRUE,
                   quiet = TRUE)$series$value)
  , bmk3$value)
  
  # error: no series left
  expect_error(
    benchmarking(ind3, bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 allCols = TRUE, by = "value",
                 quiet = TRUE)
    )
  
  # 2 series, normal processing
  ind_ <- ind3
  ind_$value2 <- ind3$value
  bmk_ <- bmk3
  bmk_$value2 <- bmk3$value
  expect_equal(suppressMessages(
    colSums(benchmarking(
      ind_, bmk_,
      rho = 0.729, lambda = 0, biasOption = 1,
      allCols = TRUE,
      quiet = TRUE)$series[c("value", "value2")])
    ), colSums(bmk_[c("value", "value2")]))
})

test_that("`by`", {
  # error: confusion with `var`
  expect_error(
    benchmarking(ind3, bmk3,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 by = "value",
                 quiet = TRUE)
  )
  
  # error: confusion with `with`
  bmk_ <- bmk3[-5]
  bmk_$bmkval <- bmk3$value
  ind_ <- ind3
  ind_$bmkval <- NA
  expect_error(
    benchmarking(ind_, bmk_,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 var = "value", with = "bmkval", by = "bmkval",
                 quiet = TRUE)
  )
  
  
  # 2 groups using 2 by variables (one being "dummy/irrelevant")
  ind3a <- cbind(data.frame(grp = rep(c(1, 2), each = nrow(ind3)),
                            grp2 = rep(1, 2 * nrow(ind3))),
                 rep(ind3[rep(seq_len(nrow(ind3)), 2), ]))
  bmk3a <- cbind(data.frame(grp = rep(c(1, 2), each = nrow(bmk3)),
                            grp2 = rep(1, 2 * nrow(bmk3))),
                 rep(bmk3[rep(seq_len(nrow(bmk3)), 2), ]))
  
  # normal
  res <- suppressMessages(benchmarking(
    ind3a, bmk3a,
    rho = 0.729, lambda = 0, biasOption = 3,
    by = c("grp", "grp2"),
    quiet = TRUE))
  expect_equal(
    c(sum(res$series$value[res$series$grp == 1]),
      sum(res$series$value[res$series$grp == 2]))
  , bmk3a$value)

  # error: 1 period for 1st group with Denton benchmarking (`rho = 1`)
  expect_error(suppressMessages(
    benchmarking(
      ind3a[4:8, ], bmk3a,
      rho = 1, lambda = 0,
      by = "grp",
      quiet = TRUE)
    ))
  
  # error: no benchmarks for 1st
  expect_error(suppressMessages(
    benchmarking(
      ind3a, bmk3a[bmk3a$grp == 2, ],
      rho = 0.729, lambda = 0, biasOption = 1,
      by = "grp",
      quiet = TRUE)
  ))
  
  # 2 warnings: one for the 2nd group (invalid benchmarks rejected) 
  #             and the generic one at the end
  bmk_ <- bmk3a[c(1, 2, 2), ]
  bmk_[3, c(3, 5, 7)] <- c(0.5, 0.5, NA)
  expect_warning(expect_warning(suppressMessages(
    benchmarking(
      ind3a, bmk_,
      rho = 0.729, lambda = 0, biasOption = 1,
      by = "grp",
      quiet = TRUE)
  )))
})


test_that("more than 1 benchmark", {
  
  # 2 benchmarks, normal processing
  ind_ <- ind3
  ind_$year <- ind3$year + 1
  ind_ <- rbind(ind3, ind_)
  bmk_ <- bmk3
  bmk_[c(1, 3)] <- bmk3[c(1, 3)] + 1
  bmk_ <- rbind(bmk3, bmk_)
  res <- suppressMessages(benchmarking(
    ind_, bmk_,
    rho = 0.729, lambda = 0, biasOption = 1,
    quiet = FALSE))
  expect_equal(
    c(sum(res$series$value[res$series$year == 0]),
      sum(res$series$value[res$series$year == 1]))
    , bmk_$value)
  
  # warning: rejected (extra) benchmark
  bmk_ <- bmk3[rep(1, 3), ]
  bmk_[2, c(1, 3)] <- 0.5
  bmk_$value[2] <- NA
  bmk_[3, c(1, 3)] <- 1
  expect_warning(
    benchmarking(ind_, bmk_,
                 rho = 0.729, lambda = 0, biasOption = 1,
                 quiet = TRUE) 
  )
})


test_that("empty data (return in input data frames)", {
  
  # Empty input series data frame
  expect_equal(
    benchmarking(
      series_df = ind3[0, ],
      benchmarks_df = bmk3,
      rho = 0.729, lambda = 0, biasOption = 1,
      quiet = TRUE)$series
    , ind3[0, ])
  
  # Empty input benchmarks data frame
  expect_equal(
    benchmarking(
      series_df = ind3,
      benchmarks_df = bmk3[0, ],
      rho = 0.729, lambda = 0, biasOption = 1,
      quiet = TRUE)$series
    , ind3)
})
