formatar_percentual <- function(valor) {
  paste0(formatC(100 * as.numeric(valor), format = "f", digits = 1), "%")
}

mostrar_previsoes <- function(project_dir) {
  placares_file <- file.path(project_dir, "Placares esperados por partida faltante.csv")
  partidas_file <- file.path(project_dir, "Previsões por partida.csv")
  probabilidades_file <- file.path(project_dir, "Probabilidades de final de campeonato.csv")

  arquivos_ausentes <- c(placares_file, partidas_file, probabilidades_file)
  if (any(!file.exists(arquivos_ausentes))) {
    stop("Não foi possível exibir as previsões: arquivo de saída ausente.")
  }

  placares <- read.csv2(
    placares_file,
    fileEncoding = "latin1",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  partidas <- read.csv2(
    partidas_file,
    fileEncoding = "latin1",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  probabilidades <- read.csv2(
    probabilidades_file,
    fileEncoding = "latin1",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  cat("\n============================================================\n")
  cat("PREVISÕES DETALHADAS DAS PARTIDAS PENDENTES\n")
  cat("============================================================\n")

  for (indice in seq_len(nrow(placares))) {
    placar <- placares[indice, ]
    probabilidade <- partidas[indice, ]
    cat(
      sprintf(
        "%02d. Rodada %s: %s x %s\n",
        indice,
        placar$Rodada,
        placar$Mandante,
        placar$Visitante
      )
    )
    cat(
      sprintf(
        "    Placar esperado: %s %s x %s %s\n",
        placar$Mandante,
        placar$Gols_do_mandante,
        placar$Gols_do_visitante,
        placar$Visitante
      )
    )
    cat(
      sprintf(
        "    Probabilidades: mandante %s | empate %s | visitante %s\n",
        formatar_percentual(probabilidade$Probabilidade_de_vitória_do_mandante),
        formatar_percentual(probabilidade$Probabilidade_de_empate),
        formatar_percentual(probabilidade$Probabilidade_de_vitória_do_visitante)
      )
    )
  }

  melhores <- probabilidades[
    order(-probabilidades$Titulo, -probabilidades$Acesso),
    c("Time", "Titulo", "Acesso", "Rebaixamento")
  ]

  cat("\n============================================================\n")
  cat("CLASSIFICAÇÃO PROJETADA — TOP 10\n")
  cat("============================================================\n")
  cat("Time                         Título    Acesso    Rebaixamento\n")

  for (indice in seq_len(min(10L, nrow(melhores)))) {
    time <- melhores[indice, ]
    cat(
      sprintf(
        "%-28s %8s %9s %14s\n",
        substr(time$Time, 1L, 28L),
        formatar_percentual(time$Titulo),
        formatar_percentual(time$Acesso),
        formatar_percentual(time$Rebaixamento)
      )
    )
  }

  cat("\nOs arquivos completos foram salvos na pasta de resultados desta execução.\n")
}
