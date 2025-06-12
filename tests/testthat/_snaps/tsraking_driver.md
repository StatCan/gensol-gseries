# muffled error in multi-group processing

    Code
      expect_error(suppressMessages(tsraking_driver(data1, meta1, alterability_df = alter_,
        quiet = TRUE)))
    Output
      Error : The alterability data frame (argument 'alterability_df') contains invalid or NA values.
      
      

