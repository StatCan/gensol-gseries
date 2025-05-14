#######
# Configuration préalable

# Série chronologique mensuelle et trimestrielle « bidon » (2.5 années de longueur)
sc_men <- ts(rep(NA, 30), start = c(2019, 1), frequency = 12)
sc_men
sc_tri <- ts(rep(NA, 10), start = c(2019, 1), frequency = 4)
sc_tri

# Information résumée de la série chronologique
ts_info <- function(sc, sep = "-") {
  list(a = gs.time2year(sc),      # années
       p = gs.time2per(sc),       # périodes
       n = length(sc),            # longueur
       f = frequency(sc),         # fréquence
       e = gs.time2str(sc, sep))  # étiquettes
}
info_men <- ts_info(sc_men)
info_tri <- ts_info(sc_tri, sep = "t")

# Fonction qui ajoute une étiquette décrivant le groupe de traitement
ajouter_desc <- function(df_gr, vec_eti, mot, suf = "s") {
  df_gr$description <- ifelse(df_gr$complete_grp,
                              paste0("--- ", df_gr$end_per - df_gr$beg_per + 1, " ", mot, suf, " : ",
                                     vec_eti[df_gr$beg_per], " à ",
                                     vec_eti[df_gr$end_per], " ---"),
                              paste0("--- 1 ", mot, " : ", vec_eti[df_gr$beg_per], " ---"))
  df_gr
}




#######
# Scénarios courants de groupes de traitement pour des données mensuelles


# 0- Traitement mois par mois (chaque mois est un groupe de traitement)
gr_men0 <- gs.build_proc_grps(info_men$a, info_men$p, info_men$n, info_men$f,
                              temporal_grp_periodicity = 1,
                              temporal_grp_start = 1)
tmp <- ajouter_desc(gr_men0, info_men$e, "mois", "")
head(tmp)
tail(tmp)


# Groupes temporels correspondant à ...

# 1- des années civiles
gr_men1 <- gs.build_proc_grps(info_men$a, info_men$p, info_men$n, info_men$f,
                              temporal_grp_periodicity = 12,
                              temporal_grp_start = 1)
ajouter_desc(gr_men1, info_men$e, "mois", "")

# 2- des années financières commençant en avril
gr_men2 <- gs.build_proc_grps(info_men$a, info_men$p, info_men$n, info_men$f,
                              temporal_grp_periodicity = 12,
                              temporal_grp_start = 4)
ajouter_desc(gr_men2, info_men$e, "mois", "")

# 3- des trimestres réguliers (commençant en janvier, avril, juillet et octobre)
gr_men3 <- gs.build_proc_grps(info_men$a, info_men$p, info_men$n, info_men$f,
                              temporal_grp_periodicity = 3,
                              temporal_grp_start = 1)
ajouter_desc(gr_men3, info_men$e, "mois", "")

# 4- des trimestres décalés d'un mois (commençant en février, mai, août et novembre)
gr_men4 <- gs.build_proc_grps(info_men$a, info_men$p, info_men$n, info_men$f,
                              temporal_grp_periodicity = 3,
                              temporal_grp_start = 2)
ajouter_desc(gr_men4, info_men$e, "mois", "")




#######
# Scénarios courants de groupes de traitement pour des données trimestrielles


# 0- Traitement trimestre par trimestre (chaque trimestre est un groupe de traitement)
gr_tri0 <- gs.build_proc_grps(info_tri$a, info_tri$p, info_tri$n, info_tri$f,
                              temporal_grp_periodicity = 1,
                              temporal_grp_start = 1)
ajouter_desc(gr_tri0, info_tri$e, "trimestre")


# Groupes temporels correspondant à ...

# 1- des années civiles
gr_tri1 <- gs.build_proc_grps(info_tri$a, info_tri$p, info_tri$n, info_tri$f,
                              temporal_grp_periodicity = 4,
                              temporal_grp_start = 1)
ajouter_desc(gr_tri1, info_tri$e, "trimestre")

# 2- des années financières commençant en avril (2ième trimestre)
gr_tri2 <- gs.build_proc_grps(info_tri$a, info_tri$p, info_tri$n, info_tri$f,
                              temporal_grp_periodicity = 4,
                              temporal_grp_start = 2)
ajouter_desc(gr_tri2, info_tri$e, "trimestre")
