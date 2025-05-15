# Quarterly time series
my_ts <- ts(1:10 * 100, start = 2019, frequency = 4)
my_ts


# With the default variable (column) names
ts_to_tsDF(my_ts)

# Using a custom name for the time series data variable (column)
ts_to_tsDF(my_ts, val_cName = "ser_val")


# Multiple time series: argument `val_cName` ignored
# (the "mts" object column names are always used)
ts_to_tsDF(ts.union(ser1 = my_ts,
                    ser2 = my_ts / 10),
            val_cName = "useless_column_name")
