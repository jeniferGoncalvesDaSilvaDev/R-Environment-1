if (!exists("numero_de_campeonatos_ficticios", inherits = TRUE)) {
  source("config.R")
}

if (!exists("nome_classificacao_top4", inherits = TRUE)) {
  nome_classificacao_top4 <- if (grepl("Série A", liga, fixed = TRUE)) "G4" else "Acesso"
}

set.seed(semente)

suppressPackageStartupMessages(library(dplyr))

dados <- read.csv2("Dados Série B.csv", fileEncoding = "latin1", check.names = FALSE)
coeficientes <- read.csv2("Coeficientes do modelo.csv", fileEncoding = "latin1")
partidas_faltantes <- read.csv2(
  "Partidas que faltam.csv",
  fileEncoding = "latin1",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

coeficientes_de_ataque <- coeficientes |>
  filter(Fator == "Ataque") |>
  select(Time, Coeficiente)
coeficientes_de_defesa <- coeficientes |>
  filter(Fator == "Defesa") |>
  select(Time, Coeficiente)

previsoes <- partidas_faltantes |>
  left_join(
    coeficientes_de_ataque |>
      rename(Mandante = Time, Fator_de_ataque_do_mandante = Coeficiente),
    by = "Mandante"
  ) |>
  left_join(
    coeficientes_de_ataque |>
      rename(Visitante = Time, Fator_de_ataque_do_visitante = Coeficiente),
    by = "Visitante"
  ) |>
  left_join(
    coeficientes_de_defesa |>
      rename(Mandante = Time, Fator_de_defesa_do_mandante = Coeficiente),
    by = "Mandante"
  ) |>
  left_join(
    coeficientes_de_defesa |>
      rename(Visitante = Time, Fator_de_defesa_do_visitante = Coeficiente),
    by = "Visitante"
  )

previsoes$Intercepto <- coeficientes$Coeficiente[
  match("Intercepto", coeficientes$Fator)
]
previsoes$Mando_de_campo <- coeficientes$Coeficiente[
  match("Mando_de_campo", coeficientes$Fator)
]

if (anyNA(previsoes[c(
  "Fator_de_ataque_do_mandante",
  "Fator_de_ataque_do_visitante",
  "Fator_de_defesa_do_mandante",
  "Fator_de_defesa_do_visitante",
  "Intercepto",
  "Mando_de_campo"
)])) {
  stop("Há times sem coeficientes para calcular as previsões.")
}

previsoes$Media_esperada_de_gols_do_mandante <- exp(
  previsoes$Fator_de_ataque_do_mandante +
    previsoes$Fator_de_defesa_do_visitante +
    previsoes$Intercepto +
    previsoes$Mando_de_campo
)
previsoes$Media_esperada_de_gols_do_visitante <- exp(
  previsoes$Fator_de_ataque_do_visitante +
    previsoes$Fator_de_defesa_do_mandante +
    previsoes$Intercepto
)

placares_esperados <- data.frame(
  Rodada = previsoes$Rodada,
  Mandante = previsoes$Mandante,
  Visitante = previsoes$Visitante,
  Gols_do_mandante = floor(previsoes$Media_esperada_de_gols_do_mandante),
  Gols_do_visitante = floor(previsoes$Media_esperada_de_gols_do_visitante),
  check.names = FALSE
)
write.csv2(
  placares_esperados,
  file = "Placares esperados por partida faltante.csv",
  fileEncoding = "latin1"
)

resultados <- dados
resultados$Saldo_de_gols_do_mandante <-
  resultados$Gols_feitos_pelo_time_da_casa -
  resultados$Gols_feitos_pelo_time_de_fora_de_casa
resultados$Saldo_de_gols_do_visitante <-
  -resultados$Saldo_de_gols_do_mandante
resultados$Pontos_do_mandante <- ifelse(
  resultados$Saldo_de_gols_do_mandante > 0,
  3,
  ifelse(resultados$Saldo_de_gols_do_mandante == 0, 1, 0)
)
resultados$Pontos_do_visitante <- ifelse(
  resultados$Saldo_de_gols_do_visitante > 0,
  3,
  ifelse(resultados$Saldo_de_gols_do_visitante == 0, 1, 0)
)

tabela_mandantes <- resultados |>
  group_by(Time_da_casa) |>
  summarise(
    Jogos_mandante = n(),
    Vitórias_mandante = sum(Saldo_de_gols_do_mandante > 0),
    Empates_mandante = sum(Saldo_de_gols_do_mandante == 0),
    Derrotas_mandante = sum(Saldo_de_gols_do_mandante < 0),
    Gols_feitos_mandante = sum(Gols_feitos_pelo_time_da_casa),
    Gols_sofridos_mandante = sum(Gols_feitos_pelo_time_de_fora_de_casa),
    Saldo_de_gols_mandante = sum(Saldo_de_gols_do_mandante),
    Pontos_mandante = sum(Pontos_do_mandante),
    .groups = "drop"
  )
tabela_visitantes <- resultados |>
  group_by(Time_de_fora_de_casa) |>
  summarise(
    Jogos_visitante = n(),
    Vitórias_visitante = sum(Saldo_de_gols_do_visitante > 0),
    Empates_visitante = sum(Saldo_de_gols_do_visitante == 0),
    Derrotas_visitante = sum(Saldo_de_gols_do_visitante < 0),
    Gols_feitos_visitante = sum(Gols_feitos_pelo_time_de_fora_de_casa),
    Gols_sofridos_visitante = sum(Gols_feitos_pelo_time_da_casa),
    Saldo_de_gols_visitante = sum(Saldo_de_gols_do_visitante),
    Pontos_visitante = sum(Pontos_do_visitante),
    .groups = "drop"
  )
tabela_total <- merge(
  tabela_mandantes,
  tabela_visitantes,
  by.x = "Time_da_casa",
  by.y = "Time_de_fora_de_casa"
)
tabela_total$Jogos <- tabela_total$Jogos_mandante + tabela_total$Jogos_visitante
tabela_total$Vitórias <- tabela_total$Vitórias_mandante + tabela_total$Vitórias_visitante
tabela_total$Empates <- tabela_total$Empates_mandante + tabela_total$Empates_visitante
tabela_total$Derrotas <- tabela_total$Derrotas_mandante + tabela_total$Derrotas_visitante
tabela_total$Gols_feitos <- tabela_total$Gols_feitos_mandante + tabela_total$Gols_feitos_visitante
tabela_total$Gols_sofridos <- tabela_total$Gols_sofridos_mandante + tabela_total$Gols_sofridos_visitante
tabela_total$Saldo_de_gols <- tabela_total$Saldo_de_gols_mandante + tabela_total$Saldo_de_gols_visitante
tabela_total$Pontos <- tabela_total$Pontos_mandante + tabela_total$Pontos_visitante
write.csv2(tabela_total, file = "Tabela atual.csv", fileEncoding = "latin1")

n_simulacoes <- as.integer(numero_de_campeonatos_ficticios)
n_partidas <- nrow(previsoes)
if (n_simulacoes < 1L || n_partidas < 1L) {
  stop("É necessário informar ao menos uma simulação e uma partida pendente.")
}

simulacoes_gols_mandante <- matrix(
  rpois(
    n_partidas * n_simulacoes,
    lambda = rep(previsoes$Media_esperada_de_gols_do_mandante, times = n_simulacoes)
  ),
  nrow = n_partidas,
  ncol = n_simulacoes
)
simulacoes_gols_visitante <- matrix(
  rpois(
    n_partidas * n_simulacoes,
    lambda = rep(previsoes$Media_esperada_de_gols_do_visitante, times = n_simulacoes)
  ),
  nrow = n_partidas,
  ncol = n_simulacoes
)

probabilidades_partidas <- data.frame(
  Mandante = previsoes$Mandante,
  Data = if ("Data" %in% names(previsoes)) previsoes$Data else NA_character_,
  Visitante = previsoes$Visitante,
  Rodada = previsoes$Rodada,
  Probabilidade_de_vitória_do_mandante =
    rowMeans(simulacoes_gols_mandante > simulacoes_gols_visitante),
  Probabilidade_de_empate =
    rowMeans(simulacoes_gols_mandante == simulacoes_gols_visitante),
  Probabilidade_de_vitória_do_visitante =
    rowMeans(simulacoes_gols_mandante < simulacoes_gols_visitante),
  check.names = FALSE
)
write.csv2(
  probabilidades_partidas,
  file = "Previsões por partida.csv",
  fileEncoding = "latin1"
)

team_names <- as.character(tabela_total$Time_da_casa)
n_times <- length(team_names)
team_index <- setNames(seq_len(n_times), team_names)
home_indexes <- unname(team_index[as.character(previsoes$Mandante)])
away_indexes <- unname(team_index[as.character(previsoes$Visitante)])
if (anyNA(home_indexes) || anyNA(away_indexes)) {
  stop("Há partidas pendentes com times ausentes da tabela atual.")
}

inicializar_matriz <- function(coluna) {
  matrix(
    rep(tabela_total[[coluna]], times = n_simulacoes),
    nrow = n_times,
    ncol = n_simulacoes
  )
}

pontos <- inicializar_matriz("Pontos")
vitorias <- inicializar_matriz("Vitórias")
gols_feitos <- inicializar_matriz("Gols_feitos")
gols_sofridos <- inicializar_matriz("Gols_sofridos")

for (partida in seq_len(n_partidas)) {
  gols_casa <- simulacoes_gols_mandante[partida, ]
  gols_fora <- simulacoes_gols_visitante[partida, ]
  venceu_casa <- gols_casa > gols_fora
  venceu_fora <- gols_casa < gols_fora
  empatou <- !venceu_casa & !venceu_fora
  mandante <- home_indexes[partida]
  visitante <- away_indexes[partida]

  pontos[mandante, ] <- pontos[mandante, ] + 3 * venceu_casa + empatou
  pontos[visitante, ] <- pontos[visitante, ] + 3 * venceu_fora + empatou
  vitorias[mandante, ] <- vitorias[mandante, ] + venceu_casa
  vitorias[visitante, ] <- vitorias[visitante, ] + venceu_fora
  gols_feitos[mandante, ] <- gols_feitos[mandante, ] + gols_casa
  gols_feitos[visitante, ] <- gols_feitos[visitante, ] + gols_fora
  gols_sofridos[mandante, ] <- gols_sofridos[mandante, ] + gols_fora
  gols_sofridos[visitante, ] <- gols_sofridos[visitante, ] + gols_casa
}

posicoes <- matrix(NA_integer_, nrow = n_times, ncol = n_simulacoes)
for (simulacao in seq_len(n_simulacoes)) {
  ordem <- order(
    -pontos[, simulacao],
    -vitorias[, simulacao],
    -(gols_feitos[, simulacao] - gols_sofridos[, simulacao]),
    -gols_feitos[, simulacao],
    team_names,
    method = "radix"
  )
  posicoes[ordem, simulacao] <- seq_len(n_times)
}

contagem_posicoes <- t(vapply(
  seq_len(n_times),
  function(indice) tabulate(posicoes[indice, ], nbins = n_times),
  integer(n_times)
))
rownames(contagem_posicoes) <- team_names
colnames(contagem_posicoes) <- as.character(seq_len(n_times))
probabilidades_posicoes <- contagem_posicoes / n_simulacoes
write.csv2(
  probabilidades_posicoes,
  file = "Probabilidades de cada time terminar em cada posição.csv",
  fileEncoding = "latin1"
)

probabilidades_finais <- data.frame(
  Time = team_names,
  probabilidades_posicoes,
  check.names = FALSE
)
probabilidades_finais$Titulo <- probabilidades_finais[["1"]]
probabilidades_finais[[nome_classificacao_top4]] <- rowSums(
  probabilidades_posicoes[, seq_len(min(4L, n_times)), drop = FALSE]
)
probabilidades_finais$Rebaixamento <- rowSums(
  probabilidades_posicoes[, (n_times - 3L):n_times, drop = FALSE]
)
write.csv2(
  probabilidades_finais,
  file = "Probabilidades de final de campeonato.csv",
  fileEncoding = "latin1"
)

max_pontos <- max(pontos)
distribuicao_pontos <- t(vapply(
  seq_len(n_times),
  function(indice) tabulate(pontos[indice, ] + 1L, nbins = max_pontos + 1L),
  integer(max_pontos + 1L)
)) / n_simulacoes
rownames(distribuicao_pontos) <- team_names
colnames(distribuicao_pontos) <- as.character(0:max_pontos)
write.csv2(
  distribuicao_pontos,
  file = "Probabilidades de cada time terminar em cada pontuação.csv",
  fileEncoding = "latin1"
)

gols_possiveis <- 0:10
frequencias_placares <- lapply(seq_len(n_partidas), function(partida) {
  frequencias <- as.data.frame(
    table(
      factor(simulacoes_gols_mandante[partida, ], levels = gols_possiveis),
      factor(simulacoes_gols_visitante[partida, ], levels = gols_possiveis)
    )
  )
  names(frequencias) <- c("gols_mandante", "gols_visitante", "frequencia")
  frequencias$gols_mandante <- as.integer(as.character(frequencias$gols_mandante))
  frequencias$gols_visitante <- as.integer(as.character(frequencias$gols_visitante))
  frequencias$Mandante <- previsoes$Mandante[partida]
  frequencias$Visitante <- previsoes$Visitante[partida]
  frequencias$Data <- if ("Data" %in% names(previsoes)) {
    previsoes$Data[partida]
  } else {
    NA_character_
  }
  frequencias$Rodada <- previsoes$Rodada[partida]
  frequencias
})
frequencias_placares <- bind_rows(frequencias_placares)
write.csv2(
  frequencias_placares,
  file = "Frequências de placares para cada partida.csv",
  fileEncoding = "latin1",
  row.names = FALSE
)
