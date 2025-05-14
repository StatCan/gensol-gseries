# Métadonnées de `tsraking()` pour un problème à deux dimensions (table 2 x 2)
mes_metadonnees <- data.frame(series = c("A1", "A2", "B1", "B2"),
                              total1 = c("totA", "totA", "totB", "totB"),
                              total2 = c("tot1", "tot2", "tot1", "tot2"))
mes_metadonnees


# Convertir en spécifications de `tsbalancing()`

# Inclure les coefficients d'altérabilité par défaut de `tsraking()`
rkMeta_to_blSpecs(mes_metadonnees)

# Totaux presque contraignants pour la 1ère marge (petits coef. d'altérabilité pour 
# les colonnes `totA` et `totB`)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterTotal1 = 1e-6))

# Ne pas inclure les coef. d'altérabilité (contraintes d'agrégation uniquement)
rkMeta_to_blSpecs(mes_metadonnees, alterability_df_only = TRUE)

# Avec un fichier de coefficients d'altérabilité (argument `alterability_df`)
mes_coefsAlt = data.frame(B2 = 0.5)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterability_df = mes_coefsAlt))

# N'inclure que les coefficients d'altérabilité du fichier `alterability_df` 
# (c.-à-d. pour la colonne `B2`)
tail(rkMeta_to_blSpecs(mes_metadonnees, alterability_df = mes_coefsAlt,
                       alterability_df_only = TRUE))
