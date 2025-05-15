# `tsraking()` metadata for a 2-dimensional raking problem (2 x 2 table)
my_metadata <- data.frame(series = c("A1", "A2", "B1", "B2"),
                          total1 = c("totA", "totA", "totB", "totB"),
                          total2 = c("tot1", "tot2", "tot1", "tot2"))
my_metadata


# Convert to `tsbalancing()` specifications

# Include the default `tsraking()` alterability coefficients
rkMeta_to_blSpecs(my_metadata)

# Almost binding 1st marginal totals (small alter. coef for columns `totA` and `totB`)
tail(rkMeta_to_blSpecs(my_metadata, alterTotal1 = 1e-6))

# Do not include alterability coefficients (aggregation constraints only)
rkMeta_to_blSpecs(my_metadata, alterability_df_only = TRUE)

# With an alterability coefficients file (argument `alterability_df`)
my_alter = data.frame(B2 = 0.5)
tail(rkMeta_to_blSpecs(my_metadata, alterability_df = my_alter))

# Only include the alterability coefficients from `alterability_df` 
# (i.e., for column `B2` only)
tail(rkMeta_to_blSpecs(my_metadata, alterability_df = my_alter,
                       alterability_df_only = TRUE))
