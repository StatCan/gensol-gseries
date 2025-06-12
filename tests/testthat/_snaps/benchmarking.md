# by-group processing with muffled errors

    Code
      expect_error(suppressMessages(benchmarking(ind3a[4:8, ], bmk3a, rho = 1,
      lambda = 0, by = "grp", quiet = TRUE)))
    Output
      Error : The minimum number of periods (2) for the indicator series is not met.
      
      

---

    Code
      expect_error(suppressMessages(benchmarking(ind3a, bmk3a[bmk3a$grp == 2, ], rho = 0.729,
      lambda = 0, biasOption = 1, by = "grp", quiet = TRUE)))
    Output
      Error : A minimum of 1 benchmark is required.
      
      

