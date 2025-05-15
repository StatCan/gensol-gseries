# Derive the 5 marginal totals of a 2 x 3 two-dimensional data cube using `tsraking()` 
# metadata.

my_metadata <- data.frame(series = c("A1", "A2", "A3",
                                     "B1", "B2", "B3"),
                          total1 = c(rep("totA", 3),
                                     rep("totB", 3)),
                          total2 = rep(c("tot1", "tot2", "tot3"), 2))
my_metadata

# 6 periods of data with marginal totals set to `NA` (they MUST exist in the input data 
# but can be `NA`).
my_data <- data.frame(A1 = c(12, 10, 12,  9, 15,  7),
                      B1 = c(20, 21, 15, 17, 19, 18),
                      A2 = c(14,  9,  8,  9, 11, 10),
                      B2 = c(20, 29, 20, 24, 21, 17),
                      A3 = c(13, 15, 17, 14, 16, 12),
                      B3 = c(24, 20, 30, 23, 21, 19),
                      tot1 = rep(NA, 6),
                      tot2 = rep(NA, 6),
                      tot3 = rep(NA, 6),
                      totA = rep(NA, 6),
                      totB = rep(NA, 6))

# Get the raking problem elements.
p <- build_raking_problem(my_data, my_metadata)
str(p)

# Calculate the 5 marginal totals for all 6 periods.
my_data[p$tot_cols] <- p$G %*% p$x
my_data
