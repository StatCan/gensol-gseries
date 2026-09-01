# Package index

## Core functions (by subject)

### Time series benchmarking (alphabetical order)

- [`benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/benchmarking.md)
  : Restore temporal constraints
- [`stock_benchmarking()`](https://StatCan.github.io/gensol-gseries/en/reference/stock_benchmarking.md)
  : Restore temporal constraints for stock series

### Time series reconciliation (alphabetical order)

- [`tsbalancing()`](https://StatCan.github.io/gensol-gseries/en/reference/tsbalancing.md)
  : Restore cross-sectional (contemporaneous) linear constraints

- [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)
  : Restore cross-sectional (contemporaneous) aggregation constraints

- [`tsraking_driver()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking_driver.md)
  :

  Helper function for
  [`tsraking()`](https://StatCan.github.io/gensol-gseries/en/reference/tsraking.md)

## Utility functions (by subject)

### Benchmarking plots (by relevance)

- [`plot_benchAdj()`](https://StatCan.github.io/gensol-gseries/en/reference/plot_benchAdj.md)
  : Plot benchmarking adjustments
- [`plot_graphTable()`](https://StatCan.github.io/gensol-gseries/en/reference/plot_graphTable.md)
  : Generate benchmarking graphics in a PDF file
- [`ori_plot()`](https://StatCan.github.io/gensol-gseries/en/reference/bench_graphs.md)
  [`adj_plot()`](https://StatCan.github.io/gensol-gseries/en/reference/bench_graphs.md)
  [`GR_plot()`](https://StatCan.github.io/gensol-gseries/en/reference/bench_graphs.md)
  [`GR_table()`](https://StatCan.github.io/gensol-gseries/en/reference/bench_graphs.md)
  : Generate a benchmarking graphic

### Metadata conversion

- [`rkMeta_to_blSpecs()`](https://StatCan.github.io/gensol-gseries/en/reference/rkMeta_to_blSpecs.md)
  : Convert reconciliation metadata

### Data manipulation (alphabetical order)

- [`stack_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_bmkDF.md)
  : Stack benchmarks data

- [`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_tsDF.md)
  : Stack time series data

- [`ts_to_bmkDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_bmkDF.md)
  : Convert a "ts" object to a benchmarks data frame

- [`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md)
  : Convert a "ts" object to a time series data frame

- [`tsDF_to_ts()`](https://StatCan.github.io/gensol-gseries/en/reference/tsDF_to_ts.md)
  :

  Reciprocal function of
  [`ts_to_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/ts_to_tsDF.md)

- [`unstack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/unstack_tsDF.md)
  :

  Reciprocal function of
  [`stack_tsDF()`](https://StatCan.github.io/gensol-gseries/en/reference/stack_tsDF.md)

### Miscellaneous (alphabetical order)

- [`build_balancing_problem()`](https://StatCan.github.io/gensol-gseries/en/reference/build_balancing_problem.md)
  : Build the elements of balancing problems.
- [`build_raking_problem()`](https://StatCan.github.io/gensol-gseries/en/reference/build_raking_problem.md)
  : Build the elements of raking problems.
- [`gs.build_proc_grps()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.build_proc_grps.md)
  : Build reconciliation processing groups
- [`gs.gInv_MP()`](https://StatCan.github.io/gensol-gseries/en/reference/gs.gInv_MP.md)
  : Moore-Penrose inverse
- [`gs.time2year()`](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)
  [`gs.time2per()`](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)
  [`gs.time2str()`](https://StatCan.github.io/gensol-gseries/en/reference/time_values_conv.md)
  : Time values conversion functions

## Package data

- [`osqp_settings_sequence`](https://StatCan.github.io/gensol-gseries/en/reference/osqp_settings_sequence.md)
  [`default_osqp_sequence`](https://StatCan.github.io/gensol-gseries/en/reference/osqp_settings_sequence.md)
  [`alternate_osqp_sequence`](https://StatCan.github.io/gensol-gseries/en/reference/osqp_settings_sequence.md)
  : OSQP settings sequence data frame
