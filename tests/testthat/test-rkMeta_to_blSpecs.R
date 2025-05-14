#devtools::test_active_file()
#devtools::test_coverage_active_file()


# `tsraking()` example 2
my_metadata <- data.frame(series = c("cars_alb", "cars_sask", "cars_man",
                                     "vans_alb", "vans_sask", "vans_man"),
                          total1 = c(rep("cars_total", 3),
                                     rep("vans_total", 3)),
                          total2 = rep(c("alb_total", "sask_total", "man_total"), 2))

my_alter <- data.frame(vans_sask = 0)
  
my_specs_default_alter <- data.frame(
  type = c("EQ", rep(NA, 4),
           "EQ", rep(NA, 4),
           "EQ", rep(NA, 3),
           "EQ", rep(NA, 3),
           "EQ", rep(NA, 3),
           "alter", rep(NA, 11)),
  
  col = c(NA, "cars_alb", "cars_sask", "cars_man", "cars_total",
          NA, "vans_alb", "vans_sask", "vans_man", "vans_total",
          NA, "cars_alb", "vans_alb", "alb_total",
          NA, "cars_sask", "vans_sask", "sask_total",
          NA, "cars_man", "vans_man", "man_total",
          NA, "cars_alb", "cars_sask", "cars_man",
              "vans_alb", "vans_sask", "vans_man",
              "cars_total", "vans_total",
              "alb_total", "sask_total", "man_total"),
  
  row = c(rep("Marginal Total 1 (cars_total)", 5),
          rep("Marginal Total 2 (vans_total)", 5),
          rep("Marginal Total 3 (alb_total)", 4),
          rep("Marginal Total 4 (sask_total)", 4),
          rep("Marginal Total 5 (man_total)", 4),
          rep("Period Value Alterability", 12)),
  
  coef = c(NA, 1, 1, 1, -1,
           NA, 1, 1, 1, -1,
           NA, 1, 1, -1,
           NA, 1, 1, -1,
           NA, 1, 1, -1,
           NA, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0),
  
  timeVal = rep(NA_real_, 34)
)
my_specs_no_alter <- my_specs_default_alter[my_specs_default_alter$row != "Period Value Alterability", ]
my_specs_alter_df <- my_specs_default_alter
my_specs_alter_df$coef[my_specs_alter_df$row == "Period Value Alterability" & 
                         my_specs_alter_df$col == "vans_sask"] <- 0
my_specs_alter_df_only <- my_specs_alter_df[my_specs_alter_df$row != "Period Value Alterability" | 
                                              my_specs_alter_df$col == "vans_sask" | 
                                              is.na(my_specs_alter_df$col), ]
row.names(my_specs_alter_df_only) <- NULL


test_that("default alter", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata),
    my_specs_default_alter)
})

test_that("no alter", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df_only = TRUE),
    my_specs_no_alter)
})

test_that("alter file", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = my_alter),
    my_specs_alter_df)
})

test_that("alter file only", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = my_alter,
                      alterability_df_only = TRUE),
    my_specs_alter_df_only)
})

test_that("error: `metadata_df` not specified", {
  expect_error(
    rkMeta_to_blSpecs()
    )
})

test_that("error: `metadata_df` not a \"data.frame\" object", {
  expect_error(
    rkMeta_to_blSpecs(1)
  )
})

test_that("error: invalid `alterSeries`", {
  expect_error(
    rkMeta_to_blSpecs(my_metadata,
                      alterSeries = -1)
  )
})

test_that("error: invalid `alterTotal1`", {
  expect_error(
    rkMeta_to_blSpecs(my_metadata,
                      alterTotal1 = NA)
  )
})

test_that("error: invalid `alterTotal2`", {
  expect_error(
    rkMeta_to_blSpecs(my_metadata,
                      alterTotal2 = "0")
  )
})

test_that("error: invalid `alterability_df_only`", {
  expect_error(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df_only = NULL)
  )
})

test_that("period specific alter", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = data.frame(cars_alb = 0,
                                                   timeVal = 0),
                      alterability_df_only = TRUE)
    , rbind(my_specs_no_alter,
            data.frame(type = c("alter", NA_character_),
                       col = c(NA_character_, "cars_alb"),
                       row = rep.int("Period Value Alterability", 2),
                       coef = c(NA_real_, 0),
                       timeVal = c(NA_real_, 0))))
})

test_that("generic (unsdated) and period specific (dater) alter coefs", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = data.frame(cars_alb = c(1, 0),
                                                   timeVal = c(NA_real_, 0)),
                      alterability_df_only = TRUE)
    , rbind(my_specs_no_alter,
            data.frame(type = c("alter", NA_character_, NA_character_),
                       col = c(NA_character_, "cars_alb", "cars_alb"),
                       row = rep.int("Period Value Alterability", 3),
                       coef = c(NA_real_, 1, 0),
                       timeVal = c(NA_real_, NA_real_, 0))))
})

test_that("column `timeVal` with missing values only", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = data.frame(cars_alb = 1,
                                                   timeVal = NA_real_),
                      alterability_df_only = TRUE)
    , rbind(my_specs_no_alter,
            data.frame(type = c("alter", NA_character_),
                       col = c(NA_character_, "cars_alb"),
                       row = rep.int("Period Value Alterability", 2),
                       coef = c(NA_real_, 1),
                       timeVal = c(NA_real_, NA_real_)))
    )
})

test_that("warning: alter file with 2 (undated) rows", {
  expect_warning(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = my_alter[c(1, 1), , drop = FALSE])
  )
})

test_that("warning: alter file not a \"data.frame\" object", {
  expect_warning(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = 1)
  )
})

test_that("`alterability_df = NA`", {
  expect_equal(
    rkMeta_to_blSpecs(my_metadata,
                      alterability_df = NA,
    )
  , my_specs_default_alter)
})

test_that("temporal total ater coefs (col `alterAnnual`", {
  my_metadata2 <- my_metadata
  my_metadata2$alterAnnual <- NA_real_
  my_metadata2$alterAnnual[4] <- 1
  expect_equal(
    rkMeta_to_blSpecs(my_metadata2)
    , rbind(my_specs_default_alter,
            data.frame(type = c("alterTmp", NA_character_),
                       col = c(NA_character_, "vans_alb"),
                       row = rep.int("Temporal Total Alterability", 2),
                       coef = c(NA_real_, 1),
                       timeVal = c(NA_real_, NA_real_)))
    )
})
