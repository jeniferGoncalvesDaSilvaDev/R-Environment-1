# Configurações do projeto ds-futebol
r_user_library <- file.path(Sys.getenv("HOME"), "R", "library")
if (dir.exists(r_user_library)) {
  .libPaths(unique(c(r_user_library, .libPaths())))
}

liga <- "Série B"
ano <- 2025L
numero_de_campeonatos_ficticios <- 1000L
semente <- 2025L
nome_classificacao_top4 <- if (grepl("Série A", liga, fixed = TRUE)) "G4" else "Acesso"