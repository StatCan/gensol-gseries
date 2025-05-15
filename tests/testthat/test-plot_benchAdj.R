#devtools::test_active_file()
#devtools::test_coverage_active_file()


ind1 <- data.frame(year = rep(0, 4), period = 1:4, value = rep(1, 4))
bmk1 <- data.frame(startYear = 0, startPeriod = 4, endYear = 0, endPeriod = 4, value = 8)
PB1 <- benchmarking(ind1, bmk1,
                     rho = 1, lambda = 0, biasOption = 1,
                     quiet = TRUE)
SB1 <- stock_benchmarking(ind1, bmk1,
                          rho = 1, lambda = 0, biasOption = 1,
                          quiet = TRUE)
test_str1 <- "additive Denton"
test_that(paste(test_str1, "no condition"), {
  expect_no_condition(
    plot_benchAdj(PB_graphTable = PB1$graphTable,
                  SB_graphTable = SB1$graphTable,
                  SB_splineKnots = SB1$splineKnots,
                  legendPos = "bottomright")
    )
})

test_that("NA for arguments", {
  expect_no_condition(
    plot_benchAdj(PB_graphTable = NA,
                  SB_graphTable = NA,
                  SB_splineKnots = NA,
                  legendPos = "bottomright")
  )
})

test_that("`SB_splineKnots` without column \"extraKnot\"", {
  splineKnots <- SB1$splineKnots[!SB1$splineKnots$extraKnot, ]
  splineKnots <- splineKnots[-5]
  expect_no_condition(
    plot_benchAdj(PB_graphTable = PB1$graphTable,
                  SB_graphTable = NULL,
                  SB_splineKnots = splineKnots,
                  legendPos = "bottomright")
  )
})

test_that("additive benchamrking, with bias", {
  expect_no_condition(
    plot_benchAdj(PB_graphTable = benchmarking(ind1, bmk1,
                                               rho = 0.729, lambda = 0, biasOption = 3,
                                               quiet = TRUE)$graphTable,
                  SB_graphTable = stock_benchmarking(ind1, bmk1,
                                                     rho = 0.729, lambda = 0, biasOption = 3,
                                                     quiet = TRUE)$graphTable,
                  SB_splineKnots = NULL,
                  legendPos = "bottomright")
  )
})

test_that(paste(test_str1, ", without columns 'rho' and 'lambda'"), {
  cols <- setdiff(names(PB1$graphTable), c("rho", "lambda"))
  expect_no_condition(
    plot_benchAdj(PB_graphTable = PB1$graphTable[cols],
                  SB_graphTable = SB1$graphTable[cols],
                  SB_splineKnots = NULL,
                  legendPos = "bottomright")
  )
})

test_that("multiplicative benchmarking, with bias", {
  expect_no_condition(
    plot_benchAdj(PB_graphTable = benchmarking(ind1, bmk1,
                                               rho = 0.729, lambda = 1, biasOption = 3,
                                               quiet = TRUE)$graphTable,
                  SB_graphTable = stock_benchmarking(ind1, bmk1,
                                                     rho = 0.729, lambda = 1, biasOption = 3,
                                                     quiet = TRUE)$graphTable,
                  SB_splineKnots = NULL,
                  legendPos = "bottomright")
  )
})
