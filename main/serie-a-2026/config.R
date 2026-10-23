r_user_library <- file.path(Sys.getenv("HOME"), "R", "library")
if (dir.exists(r_user_library)) {
  .libPaths(unique(c(r_user_library, .libPaths())))
}

liga <- "Brasileirão Série A"
ano <- 2026L
numero_de_campeonatos_ficticios <- 5000L
semente <- 20261023L
nome_classificacao_top4 <- "G4"
