#devtools::test_active_file()
#devtools::test_coverage_active_file()


ind1 <- data.frame(year = rep(1, 4), period = 1:4, value = rep(0, 4))
bmk1 <- data.frame(startYear = 1, startPeriod = 1, endYear = 1, endPeriod = 4, value = 4)
pdf <- tempfile("test", fileext = ".pdf")
#pdf <- "test.pdf"

test_that("additive bench, denton, all plots", {
  expect_false(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 1, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf,
                    ori_plot_flag = TRUE,
                    adj_plot_flag = TRUE,
                    GR_plot_flag = TRUE,
                    GR_table_flag = TRUE)
    )$pdf_name))
})

test_that("additive bench, non-denton, no plots", {
  expect_false(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 0.9, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})

test_that("mult bench with constant, non-denton, no plots", {
  expect_false(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 0.9, lambda = 1, biasOption = 1, constant = 1,
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})

test_that("graphTable passed as a \"structure\", no plots", {
  expect_false(is.na(suppressMessages(
    do.call("plot_graphTable",
            list(graphTable = benchmarking(ind1, bmk1,
                                           rho = 0.9, lambda = 1, biasOption = 1, constant = 1,
                                           quiet = TRUE)$graphTable,
                 pdf_file = pdf,
                 ori_plot_flag = FALSE,
                 adj_plot_flag = FALSE,
                 GR_plot_flag = FALSE,
                 GR_table_flag = FALSE))
  )$pdf_name))
})

test_that("multiple series (`var`), no plots", {
  ind2 <- ind1
  ind2$value2 <- ind2$value
  bmk2 <- bmk1
  bmk2$value2 <- bmk2$value
  expect_false(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind2, bmk2,
                                              rho = 0.9, lambda = 0, biasOption = 1,
                                              var = c("value", "value2"),
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})

test_that("multiple series (`by`), no plots", {
  expect_false(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(cbind(data.frame(grp = rep(1:2, each = 4)), ind1), 
                                              cbind(data.frame(grp = 1:2), bmk1),
                                              rho = 0.9, lambda = 0, biasOption = 1,
                                              by = "grp",
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})
test_that("multiple series (`by` - 2 cols), no plots", {
  expect_false(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(cbind(data.frame(grp1 = rep(1:2, each = 8),
                                                               grp2 = rep.int(rep(1:2, each = 4), 2)), 
                                                    ind1[rep(1:4, 4), ]), 
                                              cbind(data.frame(grp1 = rep(1:2, each = 2),
                                                               grp2 = rep.int(1:2, 2)), 
                                                    bmk1[rep(1, 4), ]),
                                              rho = 0.9, lambda = 0, biasOption = 1,
                                              by = c("grp1", "grp2"),
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})

test_that("extra panels for GR plot", {
  ind2 <- ind1[rep.int(1:4, 5), ]
  ind2$year <- rep(1:5, each = 4)
  expect_false(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind2, bmk1,
                                              rho = 0.9, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = TRUE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})

test_that("PDF file without an extension", {
  pdf2 <- tempfile("test", fileext = "")
  #pdf2 <- "test"
  expect_false(is.na(suppressWarnings(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 1, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable,
                    pdf_file = pdf2,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  ))$pdf_name))
  unlink(pdf2)
})

test_that("no PDF created (`pdf_file = NULL` is specified)", {
  expect_true(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 1, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable,
                    pdf_file = NULL,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})

test_that("no PDF created (`pdf_file` is not specified)", {
  expect_true(is.na(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 1, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  )$pdf_name))
})

test_that("warning: invalid PDF file specification", {
  expect_warning(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 1, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable,
                    pdf_file = NA,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  ))
})

test_that("warning: notihng to plot", {
  expect_warning(suppressMessages(
    plot_graphTable(graphTable = benchmarking(ind1, bmk1,
                                              rho = 1, lambda = 0, biasOption = 1,
                                              quiet = TRUE)$graphTable[0, ],
                    pdf_file = pdf,
                    ori_plot_flag = FALSE,
                    adj_plot_flag = FALSE,
                    GR_plot_flag = FALSE,
                    GR_table_flag = FALSE)
  ))
})

test_that("error: no graphtable", {
  expect_error(
    plot_graphTable()
  )
})
test_that("error: graphtable not a data.frame", {
  expect_error(
    plot_graphTable(NULL)
  )
})
test_that("error: missing cols in graphTable", {
  expect_error(
    plot_graphTable(graphTable = data.frame(x = 1))
  )
})

unlink(pdf)


test_that("individual plot functions", {
  
  # Turn off graphics on Unix-like environments (e.g., StatCan GitLab pipeline's Linux Unbuntu)
  #   => Necessary to avoid the warning related to the replacement of characters "..."  with the 
  #      'Horizontal Ellipsis' unicode character ("\u2026") with testthat on Linux (GitLab pipeline).
  #   => That warning is not generated on Linux in the "regular" R environment (the CP1250 encoding 
  #      enforced in the individual graph functions works). But for whatever reason, the CP1250 encoding 
  #      does not seem to work in the testthat environment on Linux, hence `grDevices::graphics.off()`.
  #   => By the way, this is really not a problem since the graphics generated by the individual graph 
  #      functions are not relevant anyway in the testthat environment where `grDevices::interactive()` 
  #      is `FALSE` (i.e., an interactive (screen) device is not in use).
  if (.Platform$OS.type == "unix") {
    grDevices::graphics.off()
  }

  expect_no_condition(
    ori_plot(benchmarking(ind1, bmk1,
                          rho = 1, lambda = 0, biasOption = 1,
                          quiet = TRUE)$graphTable)
  )
  expect_no_condition(
    adj_plot(benchmarking(ind1, bmk1,
                          rho = 1, lambda = 0, biasOption = 1,
                          quiet = TRUE)$graphTable)
  )
  expect_no_condition(
    GR_plot(benchmarking(ind1, bmk1,
                         rho = 1, lambda = 0, biasOption = 1,
                         quiet = TRUE)$graphTable)
  )
  expect_no_condition(
    GR_table(benchmarking(ind1, bmk1,
                          rho = 1, lambda = 0, biasOption = 1,
                          quiet = TRUE)$graphTable)
  )
})
