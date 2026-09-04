# Configurações do projeto ds-futebol
r_user_library <- file.path(Sys.getenv("HOME"), "R", "library")
if (dir.exists(r_user_library)) {
  .libPaths(unique(c(r_user_library, .libPaths())))
}

liga <- "Série B"
ano <- 2025L
numero_de_campeonatos_ficticios <- 1000L
semente <- 2025L