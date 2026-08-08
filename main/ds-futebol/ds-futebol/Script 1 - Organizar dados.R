library(dplyr)
library(stringr)

# Apenas um arquivo
arquivo <- "Resultados.csv"
liga <- "Brasileirão"
ano <- 2025

# Ler os dados
dados <- read.csv2(arquivo, fileEncoding = "latin1", check.names = FALSE)

if (!"Em casa / Fora de casa" %in% names(dados)) {
  stop("Coluna 'Em casa / Fora de casa' não encontrada no arquivo.")
}

times <- dados[["Em casa / Fora de casa"]]
n_times <- length(times)

jogos_validos <- list()

for (j in seq_len(n_times)) {
  time_casa <- times[j]
  for (k in seq_len(n_times)) {
    if (j == k) next
    
    placar <- as.character(dados[j, k + 1])
    
    if (!is.na(placar) && grepl(" x ", placar)) {
      placar_limpo <- trimws(placar)
      gols_raw <- strsplit(placar_limpo, " x ")[[1]]
      
      if (length(gols_raw) == 2 && all(grepl("^[0-9]+$", gols_raw))) {
        gols <- as.numeric(gols_raw)
        time_fora <- times[k]
        jogos_validos[[length(jogos_validos) + 1]] <- data.frame(
          Time_da_casa = time_casa,
          Gols_feitos_pelo_time_da_casa = gols[1],
          Gols_feitos_pelo_time_de_fora_de_casa = gols[2],
          Time_de_fora_de_casa = time_fora,
          Liga = liga,
          Ano = ano,
          stringsAsFactors = FALSE
        )
      }
    }
  }
}

# Consolidar os jogos
dados_organizados <- bind_rows(jogos_validos)

# Salvar em CSV
write.csv2(
  dados_organizados,
  file = "Dados Série B.csv",
  row.names = FALSE,
  fileEncoding = "latin1"
)