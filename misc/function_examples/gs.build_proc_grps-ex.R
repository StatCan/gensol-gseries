#######
# Preliminary setup

# Dummy monthly and quarterly time series (2.5 years long)
mth_ts <- ts(rep(NA, 30), start = c(2019, 1), frequency = 12)
mth_ts
qtr_ts <- ts(rep(NA, 10), start = c(2019, 1), frequency = 4)
qtr_ts

# Summarized time series info
ts_info <- function(ts, sep = "-") {
  list(y = gs.time2year(ts),      # years
       p = gs.time2per(ts),       # periods
       n = length(ts),            # length
       f = frequency(ts),         # frequency
       l = gs.time2str(ts, sep))  # labels
}
mth_info <- ts_info(mth_ts)
qtr_info <- ts_info(qtr_ts, sep = "q")

# Function to add a description label for the processing group
add_desc <- function(grp_df, lab_vec, word) {
  grp_df$description <- ifelse(grp_df$complete_grp,
                               paste0("--- ", grp_df$end_per - grp_df$beg_per + 1, " ", word, "s: ",
                                      lab_vec[grp_df$beg_per], " to ",
                                      lab_vec[grp_df$end_per], " --- "),
                               paste0("--- 1 ", word, ": ", lab_vec[grp_df$beg_per], " ---"))
  grp_df
}




#######
# Common processing group scenarios for monthly data


# 0- Month-by-month processing (every single month is a processing group)
mth_grps0 <- gs.build_proc_grps(mth_info$y, mth_info$p, mth_info$n, mth_info$f,
                                temporal_grp_periodicity = 1,
                                temporal_grp_start = 1)
tmp <- add_desc(mth_grps0, mth_info$l, word = "month")
head(tmp)
tail(tmp)


# Temporal groups corresponding to ...

# 1- calendar years
mth_grps1 <- gs.build_proc_grps(mth_info$y, mth_info$p, mth_info$n, mth_info$f,
                                temporal_grp_periodicity = 12,
                                temporal_grp_start = 1)
add_desc(mth_grps1, mth_info$l, word = "month")

# 2- fiscal years starting on April
mth_grps2 <- gs.build_proc_grps(mth_info$y, mth_info$p, mth_info$n, mth_info$f,
                                temporal_grp_periodicity = 12,
                                temporal_grp_start = 4)
add_desc(mth_grps2, mth_info$l, word = "month")

# 3- regular quarters (starting on Jan, Apr, Jul and Oct)
mth_grps3 <- gs.build_proc_grps(mth_info$y, mth_info$p, mth_info$n, mth_info$f,
                                temporal_grp_periodicity = 3,
                                temporal_grp_start = 1)
add_desc(mth_grps3, mth_info$l, word = "month")

# 4- quarters shifted by one month (starting on Feb, May, Aug and Nov)
mth_grps4 <- gs.build_proc_grps(mth_info$y, mth_info$p, mth_info$n, mth_info$f,
                                temporal_grp_periodicity = 3,
                                temporal_grp_start = 2)
add_desc(mth_grps4, mth_info$l, word = "month")




#######
# Common processing group scenarios for quarterly data


# 0- Quarter-by-quarter processing (every single quarter is a processing group)
qtr_grps0 <- gs.build_proc_grps(qtr_info$y, qtr_info$p, qtr_info$n, qtr_info$f,
                                temporal_grp_periodicity = 1,
                                temporal_grp_start = 1)
add_desc(qtr_grps0, qtr_info$l, word = "quarter")


# Temporal groups corresponding to ...

# 1- calendar years
qtr_grps1 <- gs.build_proc_grps(qtr_info$y, qtr_info$p, qtr_info$n, qtr_info$f,
                                temporal_grp_periodicity = 4,
                                temporal_grp_start = 1)
add_desc(qtr_grps1, qtr_info$l, word = "quarter")

# 2- fiscal years starting on April (2nd quarter)
qtr_grps2 <- gs.build_proc_grps(qtr_info$y, qtr_info$p, qtr_info$n, qtr_info$f,
                                temporal_grp_periodicity = 4,
                                temporal_grp_start = 2)
add_desc(qtr_grps2, qtr_info$l, word = "quarter")
