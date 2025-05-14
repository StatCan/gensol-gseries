# Set the working directory (for the PDF files)
iniwd <- getwd() 
setwd(tempdir())

# Quarterly car and van sales (indicator series)
qtr_ind <- ts_to_tsDF(
  ts(matrix(c(# Car sales
              1851, 2436, 3115, 2205, 1987, 2635, 3435, 2361, 2183, 2822,
              3664, 2550, 2342, 3001, 3779, 2538, 2363, 3090, 3807, 2631,
              2601, 3063, 3961, 2774, 2476, 3083, 3864, 2773, 2489, 3082,
              # Van sales
              1900, 2200, 3000, 2000, 1900, 2500, 3800, 2500, 2100, 3100,
              3650, 2950, 3300, 4000, 3290, 2600, 2010, 3600, 3500, 2100,
              2050, 3500, 4290, 2800, 2770, 3080, 3100, 2800, 3100, 2860),
            ncol = 2),
     start = c(2011, 1),
     frequency = 4,
     names = c("car_sales", "van_sales")))

# Annual car and van sales (benchmarks)
ann_bmk <- ts_to_bmkDF(
  ts(matrix(c(# Car sales
              10324, 10200, 10582, 11097, 11582, 11092,
              # Van sales
              12000, 10400, 11550, 11400, 14500, 16000),
            ncol = 2),
     start = 2011,
     frequency = 1,
     names = c("car_sales", "van_sales")), 
  ind_frequency = 4)

# Proportional benchmarking without bias correction
out_bench <- benchmarking(qtr_ind, ann_bmk, 
                          rho = 0.729, lambda = 1, biasOption = 1,
                          allCols = TRUE,
                          quiet = TRUE)


# Default set of graphics (the 3 types of plots)
plot_graphTable(out_bench$graphTable, "bench_graphs.pdf")

# Temporarily use ggplot2 `theme_bw()` for the plots
library(ggplot2)
ini_theme <- theme_get()
theme_set(theme_bw())
plot_graphTable(out_bench$graphTable, "bench_graphs_bw.pdf")
theme_set(ini_theme)

# Generate all 4 types of graphics (including the growth rates table)
plot_graphTable(out_bench$graphTable, "bench_graphs_with_GRTable.pdf",
                GR_table_flag = TRUE)

# Reduce execution time by disabling both types of growth rates graphics
plot_graphTable(out_bench$graphTable, "bench_graphs_no_GR.pdf",
                GR_plot_flag = FALSE)


# Reset the working directory to its initial location
setwd(iniwd)
