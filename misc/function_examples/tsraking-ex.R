###########
# Example 1: Simple 1-dimensional raking problem where the values of `cars` and `vans`
#            must sum up to the value of `total`.

# Problem metadata
my_metadata1 <- data.frame(series = c("cars", "vans"),
                           total1 = c("total", "total"))
my_metadata1

# Problem data
my_series1 <- data.frame(cars = 25, vans = 5, total = 40)

# Reconcile the data
out_raked1 <- tsraking(my_series1, my_metadata1)

# Initial data
my_series1

# Reconciled data
out_raked1

# Check the output cross-sectional constraint
all.equal(rowSums(out_raked1[c("cars", "vans")]), out_raked1$total)

# Check the control total (fixed)
all.equal(my_series1$total, out_raked1$total)


###########
# Example 2: 2-dimensional raking problem similar to the 1st example but adding
#            regional sales for the 3 prairie provinces (Alb., Sask. and Man.)
#            and where the sales of vans in Sask. are non-alterable
#            (alterability coefficient = 0), with `quiet = TRUE` to avoid
#            displaying the function header.

# Problem metadata
my_metadata2 <- data.frame(series = c("cars_alb", "cars_sask", "cars_man",
                                      "vans_alb", "vans_sask", "vans_man"),
                           total1 = c(rep("cars_total", 3),
                                      rep("vans_total", 3)),
                           total2 = rep(c("alb_total", "sask_total", "man_total"), 2))
my_metadata2

# Problem data
my_series2 <- data.frame(cars_alb = 12, cars_sask = 14, cars_man = 13,
                         vans_alb = 20, vans_sask = 20, vans_man = 24,
                         alb_total = 30, sask_total = 31, man_total = 32,
                         cars_total = 40, vans_total = 53)

# Reconciled data
out_raked2 <- tsraking(my_series2, my_metadata2,
                       alterability_df = data.frame(vans_sask = 0),
                       quiet = TRUE)

# Initial data
my_series2

# Reconciled data
out_raked2

# Check the output cross-sectional constraints
all.equal(rowSums(out_raked2[c("cars_alb", "cars_sask", "cars_man")]), out_raked2$cars_total)
all.equal(rowSums(out_raked2[c("vans_alb", "vans_sask", "vans_man")]), out_raked2$vans_total)
all.equal(rowSums(out_raked2[c("cars_alb", "vans_alb")]), out_raked2$alb_total)
all.equal(rowSums(out_raked2[c("cars_sask", "vans_sask")]), out_raked2$sask_total)
all.equal(rowSums(out_raked2[c("cars_man", "vans_man")]), out_raked2$man_total)

# Check the control totals (fixed)
tot_cols <- union(unique(my_metadata2$total1), unique(my_metadata2$total2))
all.equal(my_series2[tot_cols], out_raked2[tot_cols])

# Check the value of vans in Saskatchewan (fixed at 20)
all.equal(my_series2$vans_sask, out_raked2$vans_sask)
