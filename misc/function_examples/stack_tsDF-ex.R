# Create a data frame with 2 quarterly indicators series
# (with missing values for the last 2 quarters)
my_indicators <- ts_to_tsDF(ts(data.frame(ser1 = c(1:5 *  10, NA, NA),
                                          ser2 = c(1:5 * 100, NA, NA)), 
                               start = c(2019, 1), frequency = 4))
my_indicators


# Stack the indicator series ...

# discarding `NA` values in the output stacked data frame (default behavior)
stack_tsDF(my_indicators)

# keeping `NA` values in the output stacked data frame
stack_tsDF(my_indicators, keep_NA = TRUE)

# using custom variable (column) names
stack_tsDF(my_indicators, ser_cName = "ser_name", val_cName = "ser_val")
