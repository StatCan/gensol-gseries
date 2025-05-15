######################################################################################
#  Cadre de dérivation des séries indirectes avec les métadonnées de `tsbalancing()`
######################################################################################
#
# Il est supposé (convenu) que...
#
# a) Toutes les contraintes d'équilibrage sont des contraintes d'égalité (`type = EQ`).
# b) Toutes les contraintes n'ont qu'une seule série non contraignante (libre) : la 
#    série à dériver (c.-à-d., toutes les séries ont un coef. d'alt. de 0 sauf la 
#    série à dériver).
# c) Chaque contrainte dérive une série différente (une nouvelle série).
# d) Les contraintes sont les mêmes pour toutes les périodes (c.-à-d., il n'y a pas 
#    de coef. d'alt. « datés » spécifiés à l'aide de la colonne `timeVal`).
######################################################################################


# Dériver les totaux de marge d'un cube de données à deux dimensions (2 x 3) en 
# utilisant les métadonnées de `tsbalancing()` (les contraintes d'agrégation d'un 
# cube de données respectent les hypothèses ci-dessus).


# Construire les spécifications du problème d'équilibrage à travers les métadonnées 
# (plus simples) de ratissage.
mes_specs <- rkMeta_to_blSpecs(
  data.frame(series = c("A1", "A2", "A3",
                        "B1", "B2", "B3"),
             total1 = c(rep("totA", 3),
                        rep("totB", 3)),
             total2 = rep(c("tot1", "tot2", "tot3"), 2)),
  alterSeries = 0,  # séries composantes contraignantes (fixes)
  alterTotal1 = 1,  # totaux de marge non contraignants (libres, à dériver)
  alterTotal2 = 1)  # totaux de marge non contraignants (libres, à dériver)
mes_specs

# 6 périodes (trimestres) de données avec totaux de marge initialisés à zéro (0): ces 
# derniers doivent OBLIGATOIREMENT exister dans les données d'entrée ET contenir des 
# données valides (non `NA`).
mes_series <- ts(data.frame(A1 = c(12, 10, 12,  9, 15,  7),
                            B1 = c(20, 21, 15, 17, 19, 18),
                            A2 = c(14,  9,  8,  9, 11, 10),
                            B2 = c(20, 29, 20, 24, 21, 17),
                            A3 = c(13, 15, 17, 14, 16, 12),
                            B3 = c(24, 20, 30, 23, 21, 19),
                            tot1 = rep(0, 6),
                            tot2 = rep(0, 6),
                            tot3 = rep(0, 6),
                            totA = rep(0, 6),
                            totB = rep(0, 6)),
                 start = 2019, frequency = 4)

# Obtenir les éléments du problème d'équilibrage.
n_per <- nrow(mes_series)
p <- build_balancing_problem(mes_series, mes_specs, 
                             temporal_grp_periodicity = n_per)

# `A2`, `op2` et `b2` définissent 30 constraintes (5 totaux de marge X 6 périodes) 
# impliquant un total de 66 points de données (11 séries X 6 périodes) desquels 36 
# réfèrent aux 6 séries composantes et 30 réfèrent aux 5 totaux de marge.
dim(p$A2)

# Obtenir les noms des totaux de marge (séries avec un coef. d'alt. non nul), dans 
# l'ordre où les contraintes correspondantes apparaissent dans les spécifications 
# (ordre de spécification des constraintes).
tmp <- p$coefs_df$col[p$coefs_df$con.flag]
noms_tot <- tmp[tmp %in% p$ser_names[p$alter$nondated_id_vec[p$alter$nondated_coefs != 0]]]

# Définir des drapeaux logiques identifiant les colonnes de total de marge :
# - `col_tot_logi1` : éléments à période unique (de longueur 11 = nombre de séries)
# - `col_tot_logi2` : éléments multi-périodes (de longueur 66 = nombre de points de
#                     données), selon le principe « column-major order » en anglais 
#                     (l'ordre de construction des éléments de la matrice `A2`)
col_tot_logi1 <- p$ser_names %in% noms_tot
col_tot_logi2 <- rep(col_tot_logi1, each = n_per)

# Ordre des totaux de marge à dériver selon
# ... les colonnes des données d'entrée (objet « mts » `mes_series`)
p$ser_names[col_tot_logi1]
# ... la spécification des contraintes (« data frame » `mes_specs`)
noms_tot


# Calculer les 5 totaux de marge pour les 6 périodes.
# Note : le calcul suivant prend en compte les contraintes d'égalité linéaires 
#        générales, c.-à-d.,
#        a) des valeurs non nulles du côté droit des contraintes (`b2`) et 
#        b) des coefficients de contrainte non nuls autres que 1 pour les séries 
#           composantes et -1 pour la série à dériver. 
mes_series[, noms_tot] <- {
  (
    # Côté droit des contraintes
    p$b2 - 

    # Sommes des composantes (« pondérées » par les coefficients des contraintes)
    p$A2[, !col_tot_logi2, drop = FALSE] %*% as.vector(p$values_ts[, !col_tot_logi1])
  ) /

  # Coefficients des séries dérivées : `t()` permet une recherche « par ligne » dans 
  # la matrice `A2` (c.-à-d., selon l'ordre de spécification des constraintes)
  # Note: `diag(p$A2[, tot_col_logi2])` fonctionnerait si `p$ser_names[col_tot_logi1]` 
  #       et `noms_tot` étaient identiques (même ordre pour les totaux); par contre, 
  #       la recherche « par ligne » ci-dessous fonctionnera toujours (et est 
  #       nécessaire dans le cas qui nous concerne).
  t(p$A2[, col_tot_logi2])[t(p$A2[, col_tot_logi2]) != 0]
}
mes_series
