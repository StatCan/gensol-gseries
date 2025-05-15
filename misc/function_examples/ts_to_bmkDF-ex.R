# Annual and quarterly time series
my_ann_ts <- ts(1:5 * 100, start = 2019, frequency = 1)
my_ann_ts
my_qtr_ts <- ts(my_ann_ts, frequency = 4)
my_qtr_ts


# Annual benchmarks for a monthly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 12)

# Annual benchmarks for a quarterly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 4)

# Quarterly benchmarks for a monthly indicator series
ts_to_bmkDF(my_qtr_ts, ind_frequency = 12)

# Start of year stocks for a quarterly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 4, 
            discrete_flag = TRUE)

# End of quarter stocks for a monthly indicator series
ts_to_bmkDF(my_qtr_ts, ind_frequency = 12, 
            discrete_flag = TRUE, alignment = "e")

# April to March annual benchmarks for a ...
# ... monthly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 12, 
            bmk_interval_start = 4)
# ... quarterly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 4, 
            bmk_interval_start = 2)

# End-of-year (April to March) stocks for a ...
# ... monthly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 12, 
            discrete_flag = TRUE, alignment = "e", bmk_interval_start = 4)
# ... quarterly indicator series
ts_to_bmkDF(my_ann_ts, ind_frequency = 4,
            discrete_flag = TRUE, alignment = "e", bmk_interval_start = 2)

# Custom name for the benchmark data variable (column)
ts_to_bmkDF(my_ann_ts, ind_frequency = 12,
            val_cName = "bmk_val")

# Multiple time series: argument `val_cName` ignored
# (the "mts" object column names are always used)
ts_to_bmkDF(ts.union(ser1 = my_ann_ts, ser2 = my_ann_ts / 10), ind_frequency = 12,
            val_cName = "useless_column_name")
