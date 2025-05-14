# Dériver les totaux de marge d'un cube de données à deux dimensions (2 x 3) 
# en utilisant les métadonnées de `tsraking()`.

mes_meta <- data.frame(series = c("A1", "A2", "A3",
                                  "B1", "B2", "B3"),
                       total1 = c(rep("totA", 3),
                                  rep("totB", 3)),
                       total2 = rep(c("tot1", "tot2", "tot3"), 2))
mes_meta

# 6 périodes de données avec totaux de marge initialisés à `NA` (ces derniers doivent
# OBLIGATOIREMENT exister dans les données d'entrée mais peuvent être `NA`).
mes_series <- data.frame(A1 = c(12, 10, 12,  9, 15,  7),
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

# Obtenir les éléments du problème de ratissage.
p <- build_raking_problem(mes_series, mes_meta)
str(p)

# Calculer les 5 totaux de marge pour les 6 périodes.
mes_series[p$tot_cols] <- p$G %*% p$x
mes_series
