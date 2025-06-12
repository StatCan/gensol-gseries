# by-group processing with muffled errors

    Code
      expect_error(suppressMessages(stock_benchmarking(ind3a, bmk3a[bmk3a$grp == 2, ],
      rho = 0.729, lambda = 0, biasOption = 1, by = "grp", quiet = TRUE)))
    Output
      Error : A minimum of 1 benchmark is required.
      
      

